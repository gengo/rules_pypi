#!/usr/bin/python2.7

import unittest

import msgpack


class MsgpackTest(unittest.TestCase):
    def test_packb(self):
        self.assertEqual(b"\x93\x01\x02\x03", msgpack.packb([1, 2, 3]))


if __name__ == "__main__":
    unittest.main()


