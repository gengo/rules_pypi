workspace(name = "com_github_gengo_rules_pypi")

load("//pypi:def.bzl", "pypi_repositories", "pypi_universal_repository", "pypi_wheel_repository")

pypi_repositories()

pypi_universal_repository(
    name = "org_python_pypi_simplejson",
    pkg = "simplejson",
    version = "3.8.2",
)

pypi_wheel_repository(
    name = "org_python_pypi_msgpack",
    modules = ["msgpack"],
    pkg = "msgpack-python",
    srcs_version = "PY2AND3",
    version = "0.4.7",
)

local_repository(
    name = "com_github_gengo_rules_pypi",
    path = ".",
)
