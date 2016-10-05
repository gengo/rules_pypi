import os.path

from setuptools import setup, find_packages

def readme():
    with open(os.path.join(os.path.dirname(__file__), "README.rst")) as f:
        return f.read()

setup(
    name="with-setuptools",
    version="0.1",
    description=readme(),
    packages=(["using.setuptools.%s" % p for p in find_packages("lib")] +
        ["using.setuptools"]),
    package_dir={"using.setuptools": "lib"},
)
