from distutils.core import setup, Extension

setup(
    name="extension",
    version="0.1",
    packages=["extension", "extension.ham"],
    package_dir={"extension": "lib"},
    ext_modules=[Extension("extension.spam", ["ext/spam.c"])],
)
