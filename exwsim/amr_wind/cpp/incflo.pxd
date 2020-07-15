# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from ...amrex.cpp_core.amr_mesh cimport AmrCore
from .cfd_sim cimport CFDSim
from .field cimport FieldRepo

cdef extern from "amr-wind/incflo.H" nogil:
    cdef cppclass incflo(AmrCore):
        incflo()

        void InitData()
        void Evolve()
        void Advance()

        void ComputeDt(bool)
        void ApplyPredictor(bool)
        void ApplyCorrector()

        CFDSim& sim()
        FieldRepo& repo()
