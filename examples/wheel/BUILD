py_test(
    name = "msgpack_test",
    srcs = ["msgpack_test.py"],
    srcs_version = "PY2AND3",
    deps = ["@org_python_pypi_msgpack//:library"],
)

py_test(
    name = "msgpack_test_py3",
    srcs = ["msgpack_test.py"],
    default_python_version = "PY3",
    main = "msgpack_test.py",
    srcs_version = "PY2AND3",
    deps = ["@org_python_pypi_msgpack//:library"],
)
