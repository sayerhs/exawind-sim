# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from .cpp cimport amrex as crx

cdef extern from "AMReX_Orientation.H" namespace "amrex::Orientation" nogil:
    cpdef enum Side:
        low, high

cdef extern from "AMReX_IndexType.H" namespace "amrex::IndexType" nogil:
    cpdef enum CellIndex:
        CELL, NODE

cdef class Box:
    cdef crx.Box bx

    @staticmethod
    cdef wrap(crx.Box bx)

cdef class RealBox:
    cdef crx.RealBox rbx

    @staticmethod
    cdef wrap(crx.RealBox rbx)

cdef class Geometry:
    cdef crx.Geometry* geom
    cdef bint owner

    @staticmethod
    cdef wrap_instance(crx.Geometry* geom, bint owner=*)

cdef class BoxArray:
    cdef crx.BoxArray* ba
    cdef bint owner

    @staticmethod
    cdef wrap_instance(crx.BoxArray* ba, bint owner=*)

cdef class DistributionMapping:
    cdef crx.DistributionMapping* dm
    cdef bint owner

    @staticmethod
    cdef wrap_instance(crx.DistributionMapping* dm, bint owner=*)

cdef class MultiFab:
    cdef crx.MultiFab* mfab
    cdef owner

    @staticmethod
    cdef wrap_instance(crx.MultiFab* mfab, bint owner=*)

cdef class IMultiFab:
    cdef crx.iMultiFab* mfab
    cdef owner

    @staticmethod
    cdef wrap_instance(crx.iMultiFab* mfab, bint owner=*)

cdef class MFIter:
    cdef crx.MFIter* mfi
    cdef bint owner

    @staticmethod
    cdef new_real(crx.MultiFab*)

    @staticmethod
    cdef new_int(crx.iMultiFab*)

    @staticmethod
    cdef wrap_instance(crx.MFIter* mfi, bint owner=*)

cdef class Array4Real:
    cdef crx.Array4[crx.Real] arr

    @staticmethod
    cdef wrap_instance(crx.Array4[crx.Real] arr)

cdef class Array4Int:
    cdef crx.Array4[int] arr

    @staticmethod
    cdef wrap_instance(crx.Array4[int] arr)

cdef class ParmParse:
    cdef crx.ParmParse* pp
