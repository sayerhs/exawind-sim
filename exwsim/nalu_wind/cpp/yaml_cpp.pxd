# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from libcpp cimport bool
from libcpp.string cimport string

cdef extern from "yaml-cpp/yaml.h" namespace "YAML" nogil:
    cdef cppclass Node:
        Node()
        bool IsDefined() const
        bool IsNull() const
        bool IsScalar() const
        bool IsSequence() const
        bool IsMap() const

        T as[T]() const
        const string& Scalar() const

    Node LoadFile(const string&) except +
    Node Load(const string&) except +
