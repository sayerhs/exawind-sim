# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from libcpp cimport bool
from libcpp.string cimport string
from .yaml_cpp cimport Node as YNode
from stk.api.mesh.bulk cimport BulkData
from stk.api.mesh.meta cimport MetaData

cdef extern from "Realm.h" namespace "sierra::nalu":
    cdef cppclass Realm:
        string name()
        MetaData& meta_data()
        BulkData& bulk_data()
        void load(const YNode&)
        void look_ahead_and_creation(const YNode&)
        void breadboard()
        void initialize()

        bool query_for_overset()
        bool does_mesh_move() const
        string get_coordinates_name()

        void advance_time_step()
        void populate_initial_condition()
        void populate_boundary_data()
        void boundary_data_to_state_data()

        double populate_variables_from_input(double)
        double populate_restart(double, double)

        void process_initialization_transfer()
        void process_io_transfer()

        void populate_external_variables_from_input(double)
        void process_external_data_transfer()
        void populate_derived_quantities()
        void evaluate_properties()
        void initial_work()
        void process_multi_physics_transfer()
        void output_converged_results()
