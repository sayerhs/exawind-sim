# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from amrex.cpp_core.amr_mesh cimport AmrCore
from .cfd_sim cimport CFDSim
from .field cimport FieldRepo

cdef extern from "amr-wind/incflo.H" nogil:
    cdef cppclass incflo(AmrCore):
        incflo()

        void init_mesh()
        void init_amr_wind_modules()
        void prepare_for_time_integration()
        void regrid_and_update()
        void pre_advance_stage1()
        void pre_advance_stage2()
        void advance()
        void post_advance_work()

        void InitData()
        void Evolve()

        void ComputeDt(bool)
        void ApplyPredictor(bool)
        void ApplyCorrector()

        CFDSim& sim()
        FieldRepo& repo()
