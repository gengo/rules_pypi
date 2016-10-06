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
    copts = {copts},
    linkopts = {linkopts},
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

def _archive_download_action(ctx, pip_lib, pkg, version, wheel=False):
  cmd = ["python", ctx.path(ctx.attr._locate_archive)]
  if wheel:
    cmd += ["--wheel"]
  cmd += [pkg, version]
  result = ctx.execute(cmd, 600, {"PYTHONPATH": str(pip_lib)})
  if result.return_code:
    fail("Failed to locate %s==%s: %s" % (pkg, version, result.stderr))

  url, fname = result.stdout.strip().split("\n")
  ctx.download(url, fname, "", False)
  return fname

def _pypi_repository_impl(ctx):
  pip = ctx.attr.pip
  pip_lib = ctx.path(pip).dirname.get_child("site-packages")

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

  archive = _archive_download_action(ctx, pip_lib, ctx.attr.pkg, ctx.attr.version)
  build = _GENERIC_BUILD_FILE.format(
      deps = repr(ctx.attr.deps),
      srcs_version = repr(ctx.attr.srcs_version),
      archive = repr(archive),
      copts = repr(ctx.attr.copts),
      linkopts = repr(ctx.attr.linkopts),
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

        "copts": attr.string_list(
            default = [],
        ),
        "linkopts": attr.string_list(
            default = [],
        ),

        "deps": attr.string_list(),
        "srcs_version": attr.string(),

        "_init_template": attr.label(
            default = Label("//pypi:__init__.py.tpl"),
        ),
        "_locate_archive": attr.label(
            default = Label("//pypi/tools:locate_archive.py"),
            allow_single_file = True,
            cfg = "host",
        ),
        "pip": attr.label(
            default = Label("@python_pip_tools//:pip.py"),
            allow_single_file = True,
            executable = True,
            cfg = "host",
        ),
    },
)

_WHEEL_BUILD_FILE = """
filegroup(
    name = "wheel",
    srcs = ["package.whl"],
)

py_library(
    name = "library",
    srcs = glob(["lib/*/__init__.py"]),
    data = [":wheel"],
    imports = ["lib"],
    visibility = ["//visibility:public"],
    deps = {deps},
    srcs_version = {srcs_version}
)
"""

def _pypi_wheel_repository_impl(ctx):
  pip = ctx.attr.pip
  pip_lib = ctx.path(pip).dirname.get_child("site-packages")

  spec = "%s==%s" % (ctx.attr.pkg, ctx.attr.version)
  if ctx.attr.srcs_version not in ["PY2ONLY", "PY3"]:
    fail("abi-depndent pacakge cannot support both of PY2 and PY3 by definition",
         "srcs_version")
    # TODO(yugui) support building both versions depending on srcs_version

  archive = _archive_download_action(ctx, pip_lib, ctx.attr.pkg, ctx.attr.version,
                                     wheel=True)
  ctx.symlink(ctx.path(archive), ctx.path("package.whl"))
  build = _WHEEL_BUILD_FILE.format(
      deps = repr(ctx.attr.deps),
      srcs_version = repr(ctx.attr.srcs_version),
  )

  tpl = ctx.attr._init_template
  for mod in ctx.attr.modules:
    ctx.symlink(ctx.path(tpl), ctx.path("lib/%s/__init__.py" % mod))
  ctx.file("BUILD", build, False)

pypi_wheel_repository = repository_rule(
    _pypi_wheel_repository_impl,
    attrs = {
        "pkg": attr.string(
            mandatory = True,
        ),
        "version": attr.string(
            mandatory = True,
        ),
        "modules": attr.string_list(),
        "deps": attr.string_list(),
        "srcs_version": attr.string(),

        "_init_template": attr.label(
            default = Label("//pypi:__init__.py.tpl"),
        ),
        "_locate_archive": attr.label(
            default = Label("//pypi/tools:locate_archive.py"),
            allow_single_file = True,
            cfg = "host",
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
