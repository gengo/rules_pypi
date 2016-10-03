load("//pypi:repositories.bzl", "pypi_repositories")
load("//pypi:wheel.bzl", "pypi_internal_wheel")

def _pure_python_install_action(ctx, pip, spec):
  # Kills platform-dependent builds placed by mistake as well as possible
  envs = ["CC", "CXX", "CPP", "LD", "AS"]
  cmd = ["env"] + ["%s=/dev/null" % e for e in envs]

  result = ctx.execute(cmd + [
      ctx.path(pip), "install",
      "--isolated", "--no-deps",
      "--root=%s" % ctx.path(''),
      "--ignore-installed",
      "--no-compile",
      "--install-option=--prefix=",
      "--install-option=--home=",
      "--install-option=--install-purelib=lib",
      "--install-option=--install-platlib=lib",
      "--install-option=--install-scripts=bin",
      "--install-option=--install-data=data",
      spec])
  if result.return_code:
    fail("Failed to fetch %s: %s\n%s " % (spec, result.stdout, result.stderr))

def _is_archive(path):
  base = path.basename
  for ext in [".tar.gz", ".tar.bz2", ".tar.xz", ".zip"]:
    if base.endswith(ext):
      return True
  return False

def _source_download_action(ctx, pip, spec):
  src = ctx.path('src')
  result = ctx.execute([
      ctx.path(pip), "download",
      "--isolated", "--no-deps",
      "--no-binary", ":all:",
      "-d", src,
      spec])
  if result.return_code:
    fail("Failed to fetch %s: %s\n%s " % (spec, result.stdout, result.stderr))
  archives = [f for f in src.readdir() if _is_archive(f)]
  if not archives:
    fail("Cannot find any buildable source archive in %s" % src.readdir)
  return "src/" + archives[0].basename

_PURE_BUILD_FILE = """
py_library(
    name = "library",
    srcs = glob(["lib/**/*.py"]),
    deps = {deps},
    srcs_version = {srcs_version},
    data = glob(["data/**/*"]),
    imports = ["lib"],
    visibility = ["//visibility:public"],
)
"""

def _pypi_pure_repository_impl(ctx, pip, spec):
  _pure_python_install_action(ctx, pip, spec)

  build = _PURE_BUILD_FILE.format(
      deps = repr(ctx.attr.deps),
      srcs_version = repr(ctx.attr.srcs_version),
  )
  ctx.file("BUILD", build, False)


_GENERIC_BUILD_FILE = """
load("@com_github_gengo_rules_pypi//pypi:wheel.bzl", "pypi_internal_wheel")

filegroup(
    name = "source",
    srcs = [{archive}],
)

pypi_internal_wheel(
    name = "package",
    archive = ":source",
)

py_library(
    name = "library",
    srcs = glob(["lib/*/__init__.py"]),
    data = ["package.whl"],
    imports = ["lib"],
    visibility = ["//visibility:public"],
    deps = {deps},
    srcs_version = {srcs_version}
)
"""

def _pypi_repository_impl(ctx):
  pip = ctx.attr.pip
  spec = "%s==%s" % (ctx.attr.pkg, ctx.attr.version)
  if ctx.attr.pure:
    _pypi_pure_repository_impl(ctx, pip, spec)
    return 

  if not ctx.attr.modules:
    fail("must specify either modules or pure", "modules")
  if ctx.attr.srcs_version not in ["PY2ONLY", "PY3"]:
    fail("abi-depndent pacakge cannot support both of PY2 and PY3 by definition",
         "srcs_version")
    # TODO(yugui) support building both versions depending on srcs_version

  archive = _source_download_action(ctx, pip, spec)
  build = _GENERIC_BUILD_FILE.format(
      deps = repr(ctx.attr.deps),
      srcs_version = repr(ctx.attr.srcs_version),
      archive = repr(archive),
  )

  tpl = ctx.attr._init_template
  for mod in ctx.attr.modules:
    ctx.symlink(ctx.path(tpl), ctx.path("lib/%s/__init__.py" % mod))
  ctx.file("BUILD", build, False)

pypi_repository = repository_rule(
    _pypi_repository_impl,
    attrs = {
        "pkg": attr.string(
            mandatory = True,
        ),
        "version": attr.string(
            mandatory = True,
        ),

        "pure": attr.bool(),
        "modules": attr.string_list(),

        "deps": attr.string_list(),
        "srcs_version": attr.string(),

        "_init_template": attr.label(
            default = Label("//pypi:__init__.py.tpl"),
        ),
        "pip": attr.label(
            default = Label("@python_pip_tools//:pip.py"),
            allow_single_file = True,
            executable = True,
            cfg = "host",
        ),
    },
)

# TODO(yugui) Support platform wheel?
