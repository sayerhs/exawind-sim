# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from libcpp cimport bool

cdef extern from "Kokkos_Core.hpp" namespace "Kokkos" nogil:
    cdef cppclass InitArguments:
        int num_threads
        int num_numa
        int device_id
        int ndevices
        int skip_device
        bool disable_warnings

    void initialize()
    void initialize(int&, char* arg[])
    void initialize(const InitArguments&)
    void finalize()
    bool is_initialized()
