# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from libcpp cimport bool
from libcpp.vector cimport vector
from libcpp.string cimport string
from ...tioga.tioga_cpp cimport tioga

cdef extern from "overset/ExtOverset.h" namespace "sierra::nalu" nogil:
    cdef cppclass ExtOverset:
        void update_connectivity()
        void exchange_solution()
        void pre_overset_conn_work()
        void post_overset_conn_work()
        int register_solution(const vector[string]&)
        void update_solution()

        bool multi_solver_mode()
        void set_multi_solver_mode(const bool)
        bool is_external_overset()

cdef extern from "overset/TiogaRef.h" namespace "tioga_nalu" nogil:
    cdef cppclass TiogaRef:
        @staticmethod
        TiogaRef& self(tioga*)
