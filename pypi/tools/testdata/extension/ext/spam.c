#include <Python.h>

static PyObject* Spam(PyObject* self, PyObject* args) {
  Py_INCREF(Py_None);
  return Py_None;
}

static PyMethodDef kMethodDef = {
  {"spam", Spam, METH_VARARGS, "example method"},
  {NULL, NULL, 0, NULL},
};

PyMODINIT_FUNC initspam(void) {
  Py_InitModule("spam", &kMethodDef);
}
