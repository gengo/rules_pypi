_PACKAGES = {
    "pip": struct(
        url = "https://pypi.python.org/packages/9c/32/004ce0852e0a127f07f358b715015763273799bd798956fa930814b60f39/pip-8.1.2-py2.py3-none-any.whl#md5=0570520434c5b600d89ec95393b2650b",
        sha256 = "6464dd9809fb34fc8df2bf49553bb11dac4c13d2ffa7a4f8038ad86a4ccb92a1",
    ),
    "wheel": struct(
        url = "https://pypi.python.org/packages/83/53/e120833aa2350db333df89a40dea3b310dd9dabf6f29eaa18934a597dc79/wheel-0.30.0a0-py2.py3-none-any.whl#md5=ffa1ee60be515c04b4c13fd13feea27a",
        sha256 = "cd19aa9325d3af1c641b0a23502b12696159171d2a2f4b84308df9a075c2a4a0",
    ),
    "setuptools": struct(
        url = "https://pypi.python.org/packages/10/46/2a5a1fa61982a622d803d3744ce5fc551ddbb35b26a4c0e1115a428f879c/setuptools-28.0.0-py2.py3-none-any.whl#md5=6e5dc897cda9db12d17911763171099e",
        sha256 = "a622eeec9eff4c9b293e08160c912d5c87f326b54f58365eca1c60ee01a4a62f",
    ),
}

_PIP_ENTRYPOINT = """#!/usr/bin/python
import os
from os.path import dirname, join, normpath
import sys

def run():
  import pip
  sys.exit(pip.main())

libdir = normpath(join(dirname(__file__), "site-packages"))
sys.path.insert(0, libdir)
os.environ["PYTHONPATH"] = libdir

run()
"""

_PIP_BUILD_FILE = """
py_binary(
    name = "pip",
    srcs = ["pip.py"],
    data = glob(
        include = ["site-packages/**/*"],
        exclude = [
            # These file names are illegal as Bazel labels but they are not
            # required by pip.
            "site-packages/setuptools/command/launcher manifest.xml",
            "site-packages/setuptools/*.tmpl",
        ],
    ),
    srcs_version = "PY2AND3",
    visibility = ["//visibility:public"],
)
"""

def _pip_impl(ctx):
  for name, remote in _PACKAGES.items():
    ctx.download_and_extract(remote.url, ctx.path("site-packages"), remote.sha256, "zip", "")
    # ctx.download(remote.url, "%s.whl" % name, remote.sha256, False)

  ctx.file("pip.py", _PIP_ENTRYPOINT, True)
  ctx.file("BUILD", _PIP_BUILD_FILE, False)

_pip = repository_rule(_pip_impl)

def pypi_repositories():
  _pip(name = "python_pip_tools")

  native.bind(
      name = "pip",
      actual = "@python_pip_tools//:pip",
  )
