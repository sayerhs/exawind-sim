
cdef extern from "AMReX_RealVect.H" namespace "amrex" nogil:
    cdef cppclass RealVect:
        RealVect()
        RealVect(const vector[amrex_real]&)
        RealVect(amrex_real i, amrex_real j, amrex_real k)
        RealVect(amrex_real i)
        RealVect(const amrex_real* a)
        RealVect(const IntVect&)

        amrex_real& operator[](int)
        amrex_real* begin()
        amrex_real* end()
