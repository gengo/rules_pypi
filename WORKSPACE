workspace(name = "com_github_gengo_rules_pypi")

load("//pypi:def.bzl", "pypi_repositories", "pypi_repository")

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
    modules = ["numpy"],
    pkg = "numpy",
    srcs_version = "PY2ONLY",
    version = "1.11.1",
)

local_repository(
    name = "com_github_gengo_rules_pypi",
    path = ".",
)
