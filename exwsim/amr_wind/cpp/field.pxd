# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from libcpp.string cimport string
from libcpp.memory cimport unique_ptr
from ...amrex.cpp cimport amrex as crx
from ...amrex.cpp_core.amr_mesh cimport AmrCore

cdef extern from "amr-wind/core/FieldDescTypes.H" namespace "amr_wind::FieldState" nogil:
    cpdef enum FieldState "amr_wind::FieldState":
        NP1
        N
        NM1
        NPH
        NMH
        New
        Old

cdef extern from "amr-wind/core/FieldDescTypes.H" namespace "amr_wind::FieldLoc" nogil:
    cpdef enum FieldLoc "amr_wind::FieldLoc":
        CELL
        NODE
        XFACE
        YFACE
        ZFACE

cdef extern from * namespace "cy_exw" nogil:
    """
    #include "amr-wind/core/FieldDescTypes.H"

    inline int operator-(const amr_wind::FieldLoc a, const amr_wind::FieldLoc b)
    { return (static_cast<int>(a) - static_cast<int>(b));}

    inline int operator-(const amr_wind::FieldState a, const amr_wind::FieldState b)
    { return (static_cast<int>(a) - static_cast<int>(b));}

    inline int operator*(const amr_wind::FieldState a, const int b)
    { return (static_cast<int>(a) * static_cast<int>(b));}
    inline int operator*(const int a, const amr_wind::FieldState b)
    { return (static_cast<int>(a) * static_cast<int>(b));}

    inline int operator|(const amr_wind::FieldState a, const int b)
    { return (static_cast<int>(a) | static_cast<int>(b));}
    inline int operator|(const int a, const amr_wind::FieldState b)
    { return (static_cast<int>(a) | static_cast<int>(b));}
    inline int operator<<(const amr_wind::FieldState a, const int b)
    { return (static_cast<int>(a) << (b));}
    inline long operator<<(const amr_wind::FieldState a, const long b)
    { return (static_cast<int>(a) << (b));}
    """

cdef extern from "amr-wind/core/FieldRepo.H" namespace "amr_wind" nogil:
    cdef cppclass FieldRepo

cdef extern from "amr-wind/core/Field.H" namespace "amr_wind" nogil:
    cdef cppclass Field:
        const string& name()
        const string& base_name()
        unsigned id()
        int num_comp()
        const crx.IntVect& num_grow()
        int num_time_states()
        int num_states()
        FieldLoc field_location()
        FieldState field_state()
        const FieldRepo& repo()

        crx.MultiFab& operator()(int lev)
        crx.Vector[crx.MultiFab*] vec_ptrs()
        crx.Vector[const crx.MultiFab*] vec_const_ptrs()

cdef extern from "amr-wind/core/IntField.H" namespace "amr_wind" nogil:
    cdef cppclass IntField:
        const string& name()
        unsigned id()
        int num_comp()
        const crx.IntVect& num_grow()
        FieldLoc field_location()
        const FieldRepo& repo()

        crx.iMultiFab& operator()(int lev)
        crx.Vector[crx.iMultiFab*] vec_ptrs()
        crx.Vector[const crx.iMultiFab*] vec_const_ptrs()

cdef extern from "amr-wind/core/ScratchField.H" namespace "amr_wind" nogil:
    cdef cppclass ScratchField:
        const string& name()
        unsigned id()
        int num_comp()
        const crx.IntVect& num_grow()
        FieldLoc field_location()
        const FieldRepo& repo()

        crx.MultiFab& operator()(int lev)
        crx.Vector[crx.MultiFab*] vec_ptrs()
        crx.Vector[const crx.MultiFab*] vec_const_ptrs()

cdef extern from "amr-wind/core/FieldRepo.H" namespace "amr_wind" nogil:
    cdef cppclass FieldRepo:
        Field& declare_field(
            const string&, const int ncomp, const int ngrow, const int nstates,
            const FieldLoc) except +
        Field& declare_cc_field(
            const string&, const int ncomp, const int ngrow, const int nstates)
        Field& declare_nd_field(
            const string&, const int ncomp, const int ngrow, const int nstates)
        Field& declare_xf_field(
            const string&, const int ncomp, const int ngrow, const int nstates)
        Field& declare_yf_field(
            const string&, const int ncomp, const int ngrow, const int nstates)
        Field& declare_zf_field(
            const string&, const int ncomp, const int ngrow, const int nstates)
        crx.Vector[Field*] declare_face_normal_field(
            const string&, const int ncomp, const int ngrow, const int nstates)
        Field& get_field(const string&, const FieldState) except +
        bint field_exists(const string&, const FieldState)

        IntField& declare_int_field(
            const string&, const int ncomp, const int ngrow, const int nstates,
            const FieldLoc) except +

        IntField& get_int_field(const string&, const FieldState) except +
        bint int_field_exists(const string&, const FieldState)

        void advance_states()

        const AmrCore& mesh()
