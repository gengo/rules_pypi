def pypi_internal_download_action(ctx, python, pip_lib, pkg, version,
                                  source=False, wheel=False):
  cmd = [python, ctx.path(ctx.attr._locate_archive)]
  if wheel:
    cmd += ["--wheel"]
  if source:
    cmd += ["--source"]
  cmd += [pkg, version]
  result = ctx.execute(cmd, 600, {"PYTHONPATH": str(pip_lib)})
  if result.return_code:
    fail("Failed to locate %s==%s: %s" % (pkg, version, result.stderr))

  url, fname = result.stdout.strip().split("\n")
  ctx.download(url, fname, "", False)
  return fname
