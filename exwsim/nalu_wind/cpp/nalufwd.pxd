# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

cdef extern from * namespace "sierra::nalu":
    cdef cppclass NaluEnv
    cdef cppclass Simulation
    cdef cppclass TimeIntegrator
    cdef cppclass Realm
    cdef cppclass Realms
