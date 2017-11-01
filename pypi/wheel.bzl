def _linker_options(ctx):
  cpp = ctx.fragments.cpp
  features = ctx.features
  options = cpp.compiler_options(features)
  options += cpp.unfiltered_compiler_options(features)
  options += cpp.link_options
  options += cpp.mostly_static_link_options(features, False)
  options += ctx.attr.linkopts
  return options

def _wheel_impl(ctx):
  pip = ctx.executable.pip
  cc = ctx.fragments.cpp.compiler_executable
  copts = ctx.fragments.cpp.c_options + ctx.attr.copts

  outwheel = ctx.outputs.wheel
  outdir = ctx.outputs.wheel.dirname

  cpp = ctx.fragments.cpp
  features = ctx.features
  options = cpp.compiler_options(features)
  options += cpp.unfiltered_compiler_options(features)
  cc = "%s %s" % (cc, " ".join(options))

  cmds = [
      " ".join([pip.path, "wheel", "-w", outdir, ctx.file.archive.path]),
      "mv {outdir}/*.whl {out}".format(outdir = outdir, out = outwheel.path),
  ]
  cmd = " ".join([pip.path, "wheel", "-w", outdir, ctx.file.archive.path])
  ctx.action(
      inputs = ctx.files.pip + ctx.files.archive + ctx.files._crosstool,
      outputs = [outwheel],
      command = ["sh", "-c", cmd],
      mnemonic = "PyWheel",
      env = {
          "CC": cc,
          "CXX": cc,
          "CFLAGS": " ".join(copts),
          "LDFLAGS": " ".join(_linker_options(ctx)),
      },
  )

pypi_internal_wheel = rule(
    _wheel_impl,
    attrs = {
        "archive": attr.label(
            mandatory = True,
            allow_single_file = True,
        ),
        "pip": attr.label(
            default = Label("@python_pip_tools//:pip"),
            executable = True,
            cfg = "host",
        ),
        "copts": attr.string_list(
            default = [],
        ),
        "linkopts": attr.string_list(
            default = [],
        ),
        "_crosstool": attr.label(
            default = Label("//tools/defaults:crosstool"),
        ),
    },
    fragments = ["cpp"],
    outputs = {
        "wheel": "%{name}.whl",
    },
)
