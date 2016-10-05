#!/usr/bin/python

import os.path
import unittest
from distutils.core import Extension

from pypi.tools.extract import extract_spec

_EXAMPLES = {
    "simple": {
        "name": "simple",
        "version": "0.1",
        "packages": ["simple"],
        "package_dir": {"simple": "lib"},
    },
    "setuptools": {
        "name": "with-setuptools",
        "version": "0.1",
        "packages": ["using.setuptools.deep", "using.setuptools"],
        "package_dir": {"using.setuptools": "lib"},
    },
    "extension": {
        "name": "extension",
        "version": "0.1",
        "pacakges": ["extension", "extension.ham"],
        "package_dir": {"extension": "lib"},
        "ext_modules": [Extension("ext.spam", ["ext/spam.c"])],
    },
}

class TestExtraction(unittest.TestCase):
    def test_extract_spec(self):
        for pkg in ["simple", "setuptools"]:
            spec = extract_spec(self._test_script(pkg))
            expected = _EXAMPLES[pkg]
            self.assertDictContainsSubset(expected, spec)

    @staticmethod
    def _test_script(pkg):
        return os.path.join("pypi/tools/testdata", pkg, "setup.py")


if __name__ == "__main__":
    unittest.main()
