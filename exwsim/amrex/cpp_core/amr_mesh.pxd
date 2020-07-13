# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from ..cpp cimport amrex as crx

cdef extern from "AMReX_TagBox.H" namespace "amrex" nogil:
    cdef cppclass TagBox:
        pass

    cdef cppclass TagBoxArray:
        pass

cdef extern from "AMReX_AmrMesh.H" namespace "amrex" nogil:
    cdef cppclass AmrMesh:
        int Verbose()
        int maxLevel()
        int finestLevel()
        crx.IntVect refRatio(int lev)
        int MaxRefRatio(int lev)

        void SetMaxGridSize(int)
        void SetMaxGridSize(const crx.IntVect&)
        void SetBlockingFactor(int)

cdef extern from "AMReX_AmrCore.H" namespace "amrex" nogil:
    cdef cppclass AmrCore(AmrMesh):
        crx.Vector[crx.Geometry]& Geom()
        crx.Vector[crx.DistributionMapping]& DistributionMap()
        crx.Vector[crx.BoxArray]& boxArray()

        const crx.Geometry& Geom(int lev)
        const crx.DistributionMapping& DistributionMap(int lev)
        const crx.BoxArray& boxArray(int lev)

        void SetMaxGridSize(int)
        void SetMaxGridSize(const crx.IntVect&)
        void SetBlockingFactor(int)
        void InitFromScratch(crx.Real time)
        void regrid(int lcrx, crx.Real time)
        void regrid(int lcrx, crx.Real time, bint initial)
