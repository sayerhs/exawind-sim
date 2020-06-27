# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from libcpp cimport bool
from libcpp.vector cimport vector

cdef extern from "AMReX.H" namespace "amrex":
    cdef cppclass AMReX:
        AMReX()

        @staticmethod
        bint empty()

        @staticmethod
        int size()

        @staticmethod
        AMReX* top()

    AMReX* Initialize(int& argc, char**& argv, bint)

include "numeric.pxi"
include "array4.pxi"
include "intvect.pxi"
include "vector.pxi"
include "orientation.pxi"
include "indextype.pxi"
include "box.pxi"
include "realvect.pxi"
include "realbox.pxi"
include "periodicity.pxi"
include "coordsys.pxi"
include "geometry.pxi"
include "multifab.pxi"
include "imultifab.pxi"
include "mfiter.pxi"
include "boxarray.pxi"
include "distributionmapping.pxi"
