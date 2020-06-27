# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from .tioga_cpp cimport tioga as _tioga

cdef class TiogaAPI:
    cdef _tioga* tg
    cdef bint owner
    cdef public bint mpi_comm_set
    cdef public int mpi_rank
    cdef public int mpi_size

    @staticmethod
    cdef wrap_instance(_tioga* tg, bint owner=*)
