
cdef extern from "AMReX_Geometry.H" namespace "amrex" nogil:
    cdef cppclass Geometry:
        Geometry()
        Geometry(const Box&)
        Geometry(const Box&, const RealBox*)

        const RealBox& ProbDomain()
        const Real* ProbLo()
        const Real* ProbHi()
        Real ProbLo(int)
        Real ProbHi(int)
        Real ProbSize()

        const Box& Domain()
        bint isPeriodic(int dir)
        bint isAllPeriodic()
        bint isAnyPeriodic()
        int period(int dir)
        Periodicity periodicity()
        Periodicity periodicity(const Box&)

        const Real* CellSize()
        Real CellSize(int dir)

        const Real* InvCellSize()
        Real InvCellSize(int dir)
