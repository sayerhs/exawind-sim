# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from libcpp.memory cimport unique_ptr
from .cpp.simulation cimport Simulation as _Sim
from .cpp.nalu_env cimport NaluEnv
from .cpp.yaml_cpp cimport Node as YNode

cdef class NaluWind:
    cdef YNode doc
    cdef NaluEnv* env
    cdef _Sim* sim
