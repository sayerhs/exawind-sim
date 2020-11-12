# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from libcpp.vector cimport vector
from libcpp.string cimport string
from ..tioga.tioga_cpp cimport tioga
from .cpp.cfd_sim cimport CFDSim

cdef extern from "AMRTiogaIface.h" namespace "exwsim" nogil:
    cdef cppclass AMRTiogaIface:
        AMRTiogaIface(CFDSim&, tioga&)
        void pre_overset_conn_work()
        void post_overset_conn_work()
        void register_solution(const vector[string]&, const vector[string]&)
        void update_solution()
