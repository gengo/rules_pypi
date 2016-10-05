py_library(
    name = "generator_lib",
    srcs = [
        "extract.py",
        "rules.py",
    ],
)

py_binary(
    name = "generate_build",
    srcs = ["generate_build.py"],
    deps = [":generator_lib"],
)

py_test(
    name = "rules_test",
    srcs = ["rules_test.py"],
    deps = [":generator_lib"],
)

py_test(
    name = "extract_test",
    srcs = ["extract_test.py"],
    data = glob(["testdata/**/*"]),
    deps = [
        "@python_pip_tools//:pip_lib",
        ":generator_lib",
    ],
)
