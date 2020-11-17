# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from cython.operator cimport dereference as deref
from mpi4py cimport MPI
from mpi4py cimport libmpi as mpi

cdef class TiogaAPI:
    """TiogaAPI wrapper"""

    def __cinit__(TiogaAPI self):
        self.tg = NULL
        self.owner = False
        self.mpi_comm_set = False
        self.mpi_rank = 0
        self.mpi_size = 1

    def __dealloc__(TiogaAPI self):
        if self.tg is not NULL and self.owner is True:
            del self.tg

    @staticmethod
    cdef wrap_instance(_tioga* in_tg, bint owner=False):
        cdef TiogaAPI obj = TiogaAPI.__new__(TiogaAPI)
        obj.tg = in_tg
        obj.owner = owner
        return obj

    def __init__(TiogaAPI self):
        self.tg = new _tioga()
        self.owner = True

    def set_communicator(TiogaAPI self, MPI.Comm comm):
        """Set communicator instance

        Args:
            comm: Instance of mpi4py comm
        """
        cdef mpi.MPI_Comm comm_obj = comm.ob_mpi
        cdef int ierr = 0
        cdef int size, rank
        ierr = mpi.MPI_Comm_size(comm_obj, &size)
        ierr = mpi.MPI_Comm_rank(comm_obj, &rank)
        self.tg.setCommunicator(comm_obj, rank, size)
        self.mpi_comm_set = True
        self.mpi_rank = rank
        self.mpi_size = size

    def profile(TiogaAPI self):
        """Profile"""
        self.tg.profile()

    def perform_connectivity(TiogaAPI self):
        """Call to native perform connectivity routine"""
        self.tg.performConnectivity()

    def perform_connectivity_amr(TiogaAPI self):
        """Call to native perform connectivity routine"""
        self.tg.performConnectivityAMR()

    def preprocess_amr_data(TiogaAPI self, int root = 0):
        self.tg.preprocess_amr_data(root)

    def data_update(TiogaAPI self, int num_comp, bint row_major=True):
        """Perform solution interpolation"""
        cdef int interptype = 0 if row_major else 1
        self.tg.dataUpdate(num_comp, interptype)

    def data_update_amr(TiogaAPI self):
        self.tg.dataUpdate_AMR()

tioga_instance = TiogaAPI()

def get_instance():
    """Return the TiogaAPI singleton instance"""
    return tioga_instance
