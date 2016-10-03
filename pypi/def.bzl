load("//pypi:repositories.bzl", "pypi_repositories")


_PKG_BUILD_FILE = """
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

def _pure_python_install_action(ctx, pip, spec):
  result = ctx.execute([
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
    fail("Failed to fetch %s: %s\n%s " % (ctx.attr.pkg,
                                          result.stdout, result.stderr))

def _pypi_repository_impl(ctx):
  pip = ctx.attr.pip
  spec = "%s==%s" % (ctx.attr.pkg, ctx.attr.version)
  _pure_python_install_action(ctx, pip, spec)

  build = _PKG_BUILD_FILE.format(
      deps = repr(ctx.attr.deps),
      srcs_version = repr(ctx.attr.srcs_version),
  )
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

        "deps": attr.string_list(),
        "srcs_version": attr.string(),

        "pip": attr.label(
            default = Label("@python_pip_tools//:pip.py"),
            allow_single_file = True,
            executable = True,
            cfg = "host",
        ),
    },
)
