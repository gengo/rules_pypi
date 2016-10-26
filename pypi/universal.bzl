load("//pypi:download.bzl", "pypi_internal_download_action")

def _universal_install_action(ctx, python, pip, pkg, version):
  pip_lib = ctx.path(pip).dirname.get_child("site-packages")
  fname = pypi_internal_download_action(ctx, python, pip_lib, pkg, version,
                                        source=True)

  # Kills platform-dependent builds placed by mistake as well as possible
  envs = ["CC", "CXX", "CPP", "LD", "AS"]
  cmd = ["env"] + ["%s=/dev/null" % e for e in envs]
  result = ctx.execute(cmd + [
      python, ctx.path(pip), "install",
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
      fname])
  if result.return_code:
    fail("Failed to install %s=%s: %s\n%s " % (pkg, version, result.stdout, result.stderr))

_UNIVERSAL_BUILD_FILE = """
py_library(
    name = "library",
    srcs = glob(["lib/**/*.py"]),
    deps = {deps},
    srcs_version = "PY2AND3",
    data = glob(["data/**/*"]),
    imports = ["lib"],
    visibility = ["//visibility:public"],
)
"""

def _pypi_universal_repository_impl(ctx):
  _universal_install_action(ctx, ctx.attr.python, ctx.attr.pip,
                            ctx.attr.pkg, ctx.attr.version)

  build = _UNIVERSAL_BUILD_FILE.format(
      deps = repr(ctx.attr.deps),
  )
  ctx.file("BUILD", build, False)


pypi_universal_repository = repository_rule(
    _pypi_universal_repository_impl,
    attrs = {
        "pkg": attr.string(
            mandatory = True,
        ),
        "version": attr.string(
            mandatory = True,
        ),

        "deps": attr.string_list(),
        # path to python
        "python": attr.string(
            default = "python",
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
