# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from libcpp cimport bool
from libcpp.vector cimport vector
from .yaml_cpp cimport Node as YNode
from .realm cimport Realm

cdef extern from "TimeIntegrator.h" namespace "sierra::nalu":
    cdef cppclass TimeIntegrator:
        void load(const YNode&)
        void breadboard()
        void initialize()
        void integrate_realm()
        void prepare_for_timestep()
        void pre_advance_timestep_stage1()
        void pre_advance_timestep_stage2()
        void post_advance_timestep()
        bool simulation_proceeds()

        double get_time_step()
        double get_current_time()
        double get_gamma1()
        double get_gamma2()
        double get_gamma3()
        int get_time_step_count()
        bool get_is_fixed_time_step()
        bool get_is_terminate_based_on_time()
        double get_total_sim_time()
        int get_max_time_step_count()
        void compute_gamma()

        vector[Realm*] realmVec_
