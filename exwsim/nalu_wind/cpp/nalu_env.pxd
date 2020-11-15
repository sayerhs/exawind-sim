# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from libcpp.string cimport string
from ...utils cimport iostream

cdef extern from "mpi.h" nogil:
    ctypedef struct _mpi_comm_t
    ctypedef _mpi_comm_t* MPI_Comm
    MPI_Comm MPI_COMM_WORLD

cdef extern from "NaluEnv.h" namespace "sierra::nalu" nogil:
    cdef cppclass NaluEnv:
        @staticmethod
        NaluEnv& self()

        void set_log_file_stream(string, bint)

        iostream.ostream& naluOutputP0()
        iostream.ostream& naluOutput()

        MPI_Comm parallel_comm()
        int parallel_rank()
        int parallel_size()

        MPI_Comm parallelCommunicator_
        int pSize_
        int pRank_
