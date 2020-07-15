# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from .cpp cimport incflo
from .cpp cimport cfd_sim
from .cpp cimport field

cdef class AMRWind:
    cdef incflo.incflo* obj

cdef class CFDSim:
    cdef cfd_sim.CFDSim* sim
    cdef bint owner

    @staticmethod
    cdef wrap_instance(cfd_sim.CFDSim* sim, bint owner=*)

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
