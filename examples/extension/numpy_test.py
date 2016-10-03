import unittest

import numpy


class TestNumpy(unittest.TestCase):
    def testUseNumpy(self):
        numpy.array([[1, 2], [3, 4]])

if __name__ == "__main__":
    unittest.main()
