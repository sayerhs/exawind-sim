# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from .yaml_cpp cimport Node as YNode
from .nalufwd cimport Realms
from .time_integrator cimport TimeIntegrator

cdef extern from "Simulation.h" namespace "sierra::nalu":
    cdef cppclass Simulation:
        Simulation(const YNode&)
        void load(const YNode&)
        void breadboard()
        void initialize()
        void run()

        TimeIntegrator* timeIntegrator_
        Realms* realms_
