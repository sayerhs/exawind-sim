from libc cimport float

cdef extern from *:
    ctypedef double amrex_real
    ctypedef long long amrex_long
    ctypedef unsigned long long amrex_ulong
    cdef double AMREX_REAL_MIN
    cdef double AMREX_REAL_MAX
    cdef double AMREX_REAL_LOWEST

cdef extern from "AMReX_REAL.H" namespace "amrex" nogil:
    ctypedef double Real

cdef extern from "AMReX_INT.H" namespace "amrex" nogil:
    ctypedef long long Long
    ctypedef unsigned long long ULong

cdef extern from "AMReX_SPACE.H":
    cdef int BL_SPACEDIM
    cdef int AMREX_SPACEDIM

cdef extern from "AMReX_Array.H" namespace "amrex" nogil:
    cdef cppclass RealArray "amrex::Array<amrex::Real, AMREX_SPACEDIM>":
        pass

cdef extern from "AMReX_Dim3.H" namespace "amrex" nogil:
    cdef cppclass Dim3:
        int x
        int y
        int z

    cdef cppclass XDim3:
        amrex_real x
        amrex_real y
        amrex_real z
