# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from .cpp.realm cimport Realm as _Realm

cdef class Realm:
    cdef _Realm* realm

    @staticmethod
    cdef wrap_instance(_Realm* in_realm)
