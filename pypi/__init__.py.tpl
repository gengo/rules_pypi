import atexit
import os
import os.path
import sys
import tempfile
import zipfile

PY2 = sys.version_info[0] == 2

if not PY2:
    from importlib import reload

tempdir = tempfile.mkdtemp()
atexit.register(lambda: os.remove(tempdir))

fname = "py3.whl"
if PY2:
    fname = "py2.whl"
wheel = os.path.join(os.path.dirname(__file__), "..", "..", fname)
with zipfile.ZipFile(wheel) as z:
    z.extractall(tempdir)

sys.path.insert(0, tempdir)
reload(sys.modules[__name__])

# vim: set ft=python :
