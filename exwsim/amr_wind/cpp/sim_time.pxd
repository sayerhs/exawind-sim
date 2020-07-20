# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from amrex.cpp cimport amrex as crx

cdef extern from "amr-wind/core/SimTime.H" namespace "amr_wind" nogil:
    cdef cppclass SimTime:
        SimTime()

        bint new_timestep()
        bint continue_simulation()
        bint do_regrid()
        bint write_plot_file()
        bint write_checkpoint()
        bint write_last_plot_file()
        bint write_last_checkpoint()

        void set_current_cfl(crx.Real)
        void set_restart_time(int, crx.Real)
        crx.Real deltaT()
        crx.Real deltaTNm1()
        crx.Real deltaTNm2()
        crx.Real current_time()
        crx.Real new_time()
        crx.Real max_cfl()
        int time_index()
        bint adaptive_timesetp()
        bint use_force_cfl()
        void parse_parameters()
