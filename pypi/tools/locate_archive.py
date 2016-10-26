from __future__ import print_function
from argparse import ArgumentParser
import os.path
import sys
if sys.version_info[0] == 2:
    from urlparse import urlsplit
else:
    from urllib.parse import urlsplit
from pip.index import PackageFinder, FormatControl
from pip.download import PipSession


_DEFAULT_INDEX = "https://pypi.python.org/simple"

def lookup_candidates(pkg, version):
    finder = PackageFinder(
            find_links=[],
            format_control=FormatControl(set([":all:"]), set()),
            index_urls=[_DEFAULT_INDEX],
            session=PipSession())
    for candidate in finder.find_all_candidates(pkg):
        if str(candidate.version) == version:
            return candidate.location
    return None


def lookup_wheel_candidates(pkg, version):
    finder = PackageFinder(
            find_links=[],
            format_control=FormatControl(set(), set([":all:"])),
            index_urls=[_DEFAULT_INDEX],
            session=PipSession())
    for candidate in finder.find_all_candidates(pkg):
        if str(candidate.version) == version:
            if candidate.location.is_wheel:
                return candidate.location
    return None


def run(pkg, version, source, wheel):
    location = None
    if wheel:
        location = lookup_wheel_candidates(pkg, version)
    if not location and source:
        location = lookup_candidates(pkg, version)
    if not location:
        sys.exit("Failed to lookup package: %s==%s" % (pkg, version))

    location = str(location)
    fname = os.path.basename(urlsplit(location).path)
    print(location)
    print(fname)


def main():
    parser = ArgumentParser()
    parser.add_argument("package", help="Name of the target PyPI package")
    parser.add_argument("pkgver", help="Version of the target PyPI package")
    parser.add_argument("--source", action="store_true",
            help="Try to locate source tarball")
    parser.add_argument("--wheel", action="store_true",
            help="Try to locate wheel")
    args = parser.parse_args()
    run(args.package, args.pkgver, source=args.source, wheel=args.wheel)


if __name__ == "__main__":
    main()
