#!/usr/bin/python

from __future__ import print_function
from argparse import ArgumentParser
import sys

from pip.index import PackageFinder, FormatControl
from pip.download import PipSession

def lookup_candidates(pkg, version):
    finder = PackageFinder(
            find_links=[],
            format_control=FormatControl(set([":all:"]), set()),
            index_urls=["https://pypi.python.org/simple"],
            session=PipSession())
    for candidate in finder.find_all_candidates(pkg):
        if str(candidate.version) == version:
            return candidate.location
    return None


def run(pkg, version):
    location = lookup_candidates(pkg, version)
    if not location:
        sys.exit("Failed to lookup package: %s==%s" % (pkg, version))
    print(location)


def main():
    parser = ArgumentParser()
    parser.add_argument("package", help="Name of the target PyPI package")
    parser.add_argument("pkgver", help="Version of the target PyPI package")
    args = parser.parse_args()
    run(args.package, args.pkgver)


if __name__ == "__main__":
    main()
