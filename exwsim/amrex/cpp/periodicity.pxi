
cdef extern from "AMReX_Periodicity.H" namespace "amrex":
    cdef cppclass Periodicity:
        Periodicity()
        Periodicity(const IntVect&)
        bint isAnyPeriodic()
        bint isAllPeriodic()
        bint isPeriodic(int dir)
        Box Domain()

        @staticmethod
        const Periodicity& NonPeriodic()
