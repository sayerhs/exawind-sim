
cdef extern from "AMReX_Orientation.H" namespace "amrex" nogil:
    cpdef enum Direction:
        x
        y
        z

cdef extern from "AMReX_Orientation.H" namespace "amrex::Orientation" nogil:
    cpdef enum Side:
        low
        high

cdef extern from "AMReX_Orientation.H" namespace "amrex" nogil:
    cdef cppclass Orientation:
        Orientation()
        Orientation(int dir, Side side)
        Orientation(Direction dir, Side side)

        bint operator==(const Orientation&)
        bint operator!=(const Orientation&)

        bint operator<(const Orientation&)
        bint operator>(const Orientation&)

        bint operator<=(const Orientation&)
        bint operator>=(const Orientation&)

        Orientation flip()
        int coordDir()
        Side faceDir()
        bint isLow()
        bint isHigh()
