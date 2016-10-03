import unittest

import simplejson


class TestSimpleJson(unittest.TestCase):
    def testUseSimpleJson(self):
        loaded = simplejson.loads('{"foo": 1}')
        self.assertEqual(loaded, {"foo": 1})


if __name__ == "__main__":
    unittest.main()
