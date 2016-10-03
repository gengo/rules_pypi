def _wheel_impl(ctx):
  pip = ctx.executable.pip
  cc = ctx.fragments.cpp.compiler_executable
  copts = ctx.fragments.cpp.c_options # + ctx.attr.copts

  outwheel = ctx.outputs.wheel
  outdir = ctx.outputs.wheel.dirname

  cmds = [
      # We cannot use env for CC because $(CC) on OSX is relative
      # and '../' does not work fine due to symlinks.
      "export CC=$(cd $(dirname {cc}); pwd)/$(basename {cc})".format(cc=cc),
      "export CXX=$CC",
      " ".join([pip.path, "wheel", "-w", outdir, ctx.file.archive.path]),
      "mv {outdir}/*.whl {out}".format(outdir = outdir, out = outwheel.path),
  ]
  ctx.action(
      inputs = ctx.files.pip + ctx.files.archive,
      outputs = [outwheel],
      command = ["sh", "-c", " && ".join(cmds)],
      mnemonic = "PyWheel",
      env = {
          "CFLAGS": " ".join(copts),
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
        )
    },
    fragments = ["cpp"],
    outputs = {
        "wheel": "%{name}.whl",
    },
)
