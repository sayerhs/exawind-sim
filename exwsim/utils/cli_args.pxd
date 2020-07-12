# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from libcpp.vector cimport vector
from libcpp.string cimport string

cdef class CLIArgs:
    cdef vector[string] sargs
    cdef vector[char*] cargs

    cdef int argc(CLIArgs self)
    cdef char** argv(CLIArgs self)
