#!/usr/bin/python

from contextlib import contextmanager
import distutils.core
import os
import os.path
import sys


class SetupPuller:
    """Provides access to parameters of distutils.core.setup

    It fakes setup() to access to the paramters.
    """
    def __init__(self, real_setup):
        self._real = real_setup
        self.metadata = None

    def fake_setup(self, **kwargs):
        self.metadata = kwargs
        return self._real(**kwargs)


@contextmanager
def _chdir(wd):
    orig_wd = os.getcwd()
    os.chdir(wd)
    try:
        yield
    finally:
        os.chdir(orig_wd)


def extract_spec(script):
    """extracts ext_module option from the given setup.py.

    Uses a simlar technique as distutils.core.run_setup but
    works even if setup() is guarded by "__name__ == '__main__'".
    """
    puller = SetupPuller(distutils.core.setup)
    distutils.core.setup = puller.fake_setup

    base = os.path.basename(script)
    wd = os.path.dirname(script)

    sys.argv[:] = [base, "config"]
    with open(script) as f:
        setup = f.read()
    with _chdir(wd):
        exec(setup, {"__file__": base, "__name__": "__main__"})

    return puller.metadata

