
cdef extern from "AMReX_CoordSys.H" namespace "amrex::CoordSys" nogil:
    cpdef enum CoordType:
        undef
        cartesian
        RZ
        SPHERICAL

cdef extern from "AMReX_CoordSys.H" namespace "amrex" nogil:
    cdef cppclass CoordSys:
        CoordSys()
        SetCoord(CoordType)
        CoordType Coord()
        int CoordInt()
        bint isSPHERICAL()
        bint isRZ()
        bint isCartesian()

        void setOffset(const Real*)
        const Real* Offset()
        Real Offset(int dir)
        const Real* CellSize()
        Real CellSize(int dir)

        const Real* InvCellSize()
        Real InvCellSize(int dir)
