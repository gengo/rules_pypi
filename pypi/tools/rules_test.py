#!/usr/bin/python

import unittest

from pypi.tools.rules import Rule


class RuleTest(unittest.TestCase):
    def test_str(self):
        rule = Rule(kind="cc_library", name="foo", attrs={"srcs": ["foo.cc"]})
        expected = ("cc_library(\n" +
                    "    name = 'foo',\n" +
                    "    srcs = ['foo.cc'],\n" +
                    ")")
        self.assertEqual(str(rule), expected)


if __name__ == "__main__":
    unittest.main()
