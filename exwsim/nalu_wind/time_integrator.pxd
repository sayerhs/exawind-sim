# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from .cpp.time_integrator cimport TimeIntegrator as _TI

cdef class TimeIntegrator:
    cdef _TI* ti

    @staticmethod
    cdef wrap_instance(_TI* in_ti)
