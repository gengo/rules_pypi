from __future__ import print_function
import argparse
from contextlib import contextmanager
import os
import sys

import extract
import rules

@contextmanager
def _redirect_stdout():
    """Tentatively redirects stdout to stderr and restores
    
    This allows us to evaluate setup.py which outputs something to stdout
    without polluting the output of this script.
    """
    orig_stdout = os.dup(sys.stdout.fileno())
    try:
        os.close(sys.stdout.fileno())
        os.dup2(sys.stderr.fileno(), sys.stdout.fileno())
        yield
    finally:
        os.dup2(orig_stdout, sys.stdout.fileno())


def run(script, copt=[], linkopt=[], deps=[]):
    with _redirect_stdout():
        spec = extract.extract_spec(script)
    gen = rules.RuleGenerator(spec)
    print("\n".join([str(r) for r in gen.generate()]))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("setup_script", default="setup.py",
            help="path to the target setup.py")
    parser.add_argument("--copt", action="append",
            help="copt attr to be added to the generated cc_library rules")
    parser.add_argument("--linkopt", action="append",
            help="linkopt attr to be added to the generated cc_library rules")
    parser.add_argument("--deps", action="append",
            help="deps attr to be added to the generated cc_library rules")
    args = parser.parse_args()
    run(args.setup_script,
            copt=args.copt, linkopt=args.linkopt, deps=args.deps)

if __name__ == "__main__":
    main()
