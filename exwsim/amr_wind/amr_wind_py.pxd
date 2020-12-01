# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from libcpp.memory cimport unique_ptr
from .cpp cimport incflo
from .cpp cimport cfd_sim
from .cpp cimport field
from . cimport amr_tioga_iface
from amrex.pyamrex cimport PyAMReX
from amrex.amrex_core cimport AmrCore

cdef class AMRWind:
    cdef PyAMReX amrex
    cdef incflo.incflo* obj
    cdef unique_ptr[amr_tioga_iface.AMRTiogaIface] tgiface
    cdef public list cell_vars
    cdef public list node_vars

cdef class CFDSim:
    cdef cfd_sim.CFDSim* sim
    cdef bint owner

    @staticmethod
    cdef wrap_instance(cfd_sim.CFDSim* sim, bint owner=*)

cdef class Incflo(AmrCore):

    cdef incflo.incflo* cls(Incflo self)

    @staticmethod
    cdef Incflo wrap_instance(incflo.incflo* ptr, bint owner=*)

cdef class Field:
    cdef field.Field* fld

    @staticmethod
    cdef wrap_instance(field.Field* fld)

cdef class IntField:
    cdef field.IntField* fld

    @staticmethod
    cdef wrap_instance(field.IntField* fld)

cdef class FieldRepo:
    cdef field.FieldRepo* repo
    cdef bint owner

    @staticmethod
    cdef wrap_instance(field.FieldRepo* repo, bint owner=*)
