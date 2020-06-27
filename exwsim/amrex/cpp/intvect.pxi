cdef extern from "AMReX_IntVect.H" namespace "amrex":
    cdef cppclass IntVect:
        IntVect()
        IntVect(int i, int j, int k)
        IntVect(int i)
        IntVect(const int*)
        int sum() const
        int max() const
        int min() const

    IntVect IntVect_Zero "IntVect::Zero"
    IntVect IntVect_Unit "IntVect::Unit"
