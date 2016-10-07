load("//pypi:download.bzl", "pypi_internal_download_action")

_WHEEL_BUILD_FILE = """
filegroup(
    name = "wheel",
    srcs = glob(["py2.whl", "py3.whl"]),
)

py_library(
    name = "library",
    srcs = glob(["lib/*/__init__.py"]),
    data = [":wheel"],
    imports = ["lib"],
    visibility = ["//visibility:public"],
    deps = {deps},
    srcs_version = {srcs_version},
)
"""

def _platform_wheel_install_action(ctx, python, dest):
  pip = ctx.attr.pip
  pip_lib = ctx.path(pip).dirname.get_child("site-packages")
  fname = pypi_internal_download_action(ctx,
                                        python=python, pip_lib=pip_lib,
                                        pkg=ctx.attr.pkg, version=ctx.attr.version,
                                        wheel=True)
  ctx.symlink(ctx.path(fname), ctx.path(dest))

def _generate_build_action(ctx):
  build = _WHEEL_BUILD_FILE.format(
      deps = repr(ctx.attr.deps),
      srcs_version = repr(ctx.attr.srcs_version),
  )
  ctx.file("BUILD", build, False)

def _stub_init_action(ctx):
  tpl = ctx.attr._init_template
  for mod in ctx.attr.modules:
    ctx.symlink(ctx.path(tpl), ctx.path("lib/%s/__init__.py" % mod))

def _platfrom_wheel_repository_impl(ctx):
  if ctx.attr.python2:
    _platform_wheel_install_action(ctx, ctx.attr.python2, "py2.whl")
  if ctx.attr.python3:
    _platform_wheel_install_action(ctx, ctx.attr.python3, "py3.whl")
  _stub_init_action(ctx)
  _generate_build_action(ctx)

plat_base_attrs =  {
    "deps": attr.string_list(),
    "srcs_version": attr.string(default = "PY2"),

    "modules": attr.string_list(),
    "_init_template": attr.label(
        default = Label("//pypi:__init__.py.tpl"),
    ),
}

pypi_wheel_repository = repository_rule(
    _platfrom_wheel_repository_impl,
    attrs = plat_base_attrs + {
        "pkg": attr.string(
            mandatory = True,
        ),
        "version": attr.string(
            mandatory = True,
        ),
        "python2": attr.string(default = "python"),
        "python3": attr.string(default = "python3"),
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

def _local_wheel_repository_impl(ctx):
  if ctx.attr.wheel_py2:
    ctx.symlink(ctx.path(ctx.attr.wheel_py2), "py2.whl")
  if ctx.attr.wheel_py3:
    ctx.symlink(ctx.path(ctx.attr.wheel_py2), "py3.whl")
  _stub_init_action(ctx)
  _generate_build_action(ctx)

local_wheel_repository = repository_rule(
    _local_wheel_repository_impl,
    attrs = plat_base_attrs + {
        "wheel_py2": attr.label(
            allow_single_file = True,
        ),
        "wheel_py3": attr.label(
            allow_single_file = True,
        ),
    }
)
