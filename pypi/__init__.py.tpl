import atexit
import os
import os.path
import sys
import tempfile
import zipfile

if sys.version_info[0] == 3:
    from importlib import reload

tempdir = tempfile.mkdtemp()
atexit.register(lambda: os.remove(tempdir))

wheel = os.path.join(os.path.dirname(__file__), "..", "..", "package.whl")
with zipfile.ZipFile(wheel) as z:
    z.extractall(tempdir)

sys.path.insert(0, tempdir)
reload(sys.modules[__name__])

# vim: set ft=python :
