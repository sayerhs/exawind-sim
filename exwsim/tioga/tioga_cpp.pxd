# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from libc.stdint cimport int64_t, uint64_t
from libcpp cimport bool
from libcpp.vector cimport vector

cdef extern from "mpi.h" nogil:
    ctypedef struct _mpi_comm_t
    ctypedef _mpi_comm_t* MPI_Comm
    MPI_Comm MPI_COMM_WORLD


cdef extern from "tioga.h" namespace "TIOGA" nogil:
    cdef cppclass tioga:
        tioga()

        void setCommunicator(MPI_Comm, int, int)
        void profile()
        void performConnectivity()
        void performConnectivityAMR()
        void dataUpdate(int nvar, int interptype, int at_points)
        void dataUpdate(int nvar, int interptype)
        void dataUpdate_AMR()

        void registerGridData(
            int btag, int nnodes, double* xyz, int* ibl,
            int nwbc, int nobc, int* wbcnode, int* obcnode,
            int ntypes, int* nv, int* nc, int** vconn,
            uint64_t* cell_gid=NULL, uint64_t* node_gid=NULL)
        void registerSolution(int btag, double* q)
        void set_cell_iblank(int*)

        void register_amr_global_data(int, int*, double*, int)
        void set_amr_patch_count(int)
        void register_amr_local_data(int, int, int*, int*)
        void register_amr_solution(int, double*, int, int)

        void getDonorCount(int btag, int* dcount, int* fcount)
        void getDonorInfo(int btag, int* receptors, int* indices,
                          double* frac, int* dcount)
        void getReceptorInfo(vector[int]&)

        void setSymmetry(int sym)
        void setResolutions(int btag, double* nres, double* cres)

        void setMexclude(int*)
        void setNfringe(int*)
