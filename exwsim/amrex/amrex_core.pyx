# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from cython.operator cimport dereference as deref
from libcpp.vector cimport vector
from .cpp cimport amrex as crx
from .amrex_base cimport Geometry, DistributionMapping, BoxArray

cdef extern from * namespace "cy_exw" nogil:
    """
    #include "AMReX_AmrCore.H"

    namespace cy_exw {
    inline amrex::Vector<amrex::BoxArray>& amr_core_ba(const amrex::AmrCore& acore)
    { return const_cast<amrex::Vector<amrex::BoxArray>&>(acore.boxArray()); }

    inline amrex::Vector<amrex::DistributionMapping>& amr_core_dmap
    (const amrex::AmrCore& acore)
    { return const_cast<amrex::Vector<amrex::DistributionMapping>&>(acore.DistributionMap()); }
    }
    """
    crx.Vector[crx.DistributionMapping]& amr_core_dmap(_AmrCore&)
    crx.Vector[crx.BoxArray]& amr_core_ba(_AmrCore&)

cdef class AmrCore:
    """AmrCore wrapper"""

    @staticmethod
    cdef wrap_instance(_AmrCore* ptr):
        cdef AmrCore self = AmrCore.__new__(AmrCore)
        self.ptr = ptr
        return self

    @property
    def verbose(AmrCore self):
        """Return verbosity"""
        return self.ptr.Verbose()

    @property
    def max_level(AmrCore self):
        """Return the maximum level possible"""
        return self.ptr.maxLevel()

    @property
    def finest_level(AmrCore self):
        """Current finest level"""
        return self.ptr.finestLevel()

    @property
    def num_levels(AmrCore self):
        """Total number of levels"""
        return self.finest_level + 1

    def geom(AmrCore self, lev = None):
        """Return geometry instance"""
        cdef int clev = 0
        cdef crx.Vector[crx.Geometry]* geom = &self.ptr.Geom()
        if lev is None:
            return [Geometry.wrap_instance(&gg)
                    for gg in deref(geom)]
        else:
            clev = <int>lev
            return Geometry.wrap_instance(&deref(geom)[clev])

    def dmap(AmrCore self, lev = None):
        """Return distribution mapping"""
        cdef int clev = 0
        cdef crx.Vector[crx.DistributionMapping]* dmap = &amr_core_dmap(deref(self.ptr))
        if lev is None:
            return [DistributionMapping.wrap_instance(&dm)
                    for dm in deref(dmap)]
        else:
            clev = <int>lev
            return DistributionMapping.wrap_instance(&deref(dmap)[clev])

    def boxarray(AmrCore self, lev=None):
        """Return BoxArray"""
        cdef int clev = 0
        cdef crx.Vector[crx.BoxArray]* bavec = &amr_core_ba(deref(self.ptr))
        if lev is None:
            return [BoxArray.wrap_instance(&ba)
                    for ba in deref(bavec)]
        else:
            clev = <int>lev
            return BoxArray.wrap_instance(&deref(bavec)[clev])
