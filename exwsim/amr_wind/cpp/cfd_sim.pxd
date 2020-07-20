# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from amrex.cpp_core.amr_mesh cimport AmrCore
from .incflo cimport incflo
from .field cimport FieldRepo
from .sim_time cimport SimTime

cdef extern from "amr-wind/CFDSim.H" namespace "amr_wind" nogil:
    cdef cppclass CFDSim:
        CFDSim(AmrCore&)

        AmrCore& mesh()
        SimTime& time()
        FieldRepo& repo()

        void create_turbulence_model()
        void init_physics()
