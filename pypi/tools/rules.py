#!/usr/bin/python

import os.path

_RULE_TEMPLATE = """{kind}(
{attrs}
)"""


class Rule(object):
    def __init__(self, kind, name, attrs):
        self.kind = kind
        self.name = name
        self.attrs = attrs

    def __str__(self):
        attrs = ["    name = %s," % repr(self.name)]
        attrs += ["    %s = %s," % (k, repr(v)) for k, v in self.attrs.items()]
        return _RULE_TEMPLATE.format(kind=self.kind, attrs="\n".join(attrs))


class RuleGenerator(object):
    def __init__(self, spec):
        self._spec = spec

    def generate(self):
        return self._ext_rules()

    def _ext_rules(self):
        rules = []
        manifests = {}
        for ext in self._spec['ext_modules']:
            # print ext.sources
            name = "lib/" + ext.name.replace(".", "/")
            srcs = ext.sources + ext.extra_objects
            srcs = ["src/%s" % s for s in srcs]

            copts = ["-I%s" % d for d in ext.include_dirs]
            copts += [self._define_flag(k, v) for k, v in ext.define_macros]
            copts += ["-L%s" for l in ext.library_dirs]
            copts += ["-Wl,-r,%s" for l in ext.runtime_library_dirs]
            copts += ["-isystem /usr/include/python2.7"]
            # TODO(yugui) Support more options in distutils.core.Extension

            attrs = {"srcs": srcs, "copts": copts}
            rules.append(Rule("cc_library", name, attrs))
            manifests["%s.so" % name] = "%s.so" % name
        return rules

    @staticmethod
    def _define_flag(name, value):
        if value:
            return "-D%s=%s" % (name, value)
        else:
            return "-D%s" % name

    def _location(self, refname):
        mapping = self._spec["package_dir"] or []
        components = refname.split(".")
        rest = []
        while components:
            pkg = ".".join(components)
            if pkg in mapping:
                return os.path.join(pkg, *rest)
            rest.insert(0, components.pop())
        return os.path.join(*rest)
