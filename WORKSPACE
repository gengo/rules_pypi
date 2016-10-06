workspace(name = "com_github_gengo_rules_pypi")

load("//pypi:def.bzl", "pypi_repositories", "pypi_repository", "pypi_wheel_repository")

pypi_repositories()

pypi_repository(
    name = "org_python_pypi_simplejson",
    pkg = "simplejson",
    pure = 1,
    srcs_version = "PY2AND3",
    version = "3.8.2",
)

pypi_repository(
    name = "org_python_pypi_numpy",
    linkopts = [
        "-B/usr/lib/gcc/x86_64-linux-gnu/4.8/",
        "-B/usr/lib/gcc/x86_64-linux-gnu/4.7/",
        "-B/usr/lib/gcc/x86_64-linux-gnu/4.6/",
    ],
    modules = ["numpy"],
    pkg = "numpy",
    srcs_version = "PY2ONLY",
    version = "1.11.1",
)

pypi_wheel_repository(
    name = "org_python_pypi_msgpack",
    modules = ["msgpack"],
    pkg = "msgpack-python",
    srcs_version = "PY2ONLY",
    version = "0.4.7",
)

local_repository(
    name = "com_github_gengo_rules_pypi",
    path = ".",
)
