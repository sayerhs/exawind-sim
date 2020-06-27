
cdef extern from "AMReX_RealBox.H" namespace "amrex" nogil:
    cdef cppclass RealBox:
        RealBox()
        RealBox(const amrex_real*, const amrex_real*)
        RealBox(Real x0, Real y0, Real z0,
                Real x1, Real y1, Real z1)

        const Real* lo()
        const Real* hi()
        Real lo(int dir)
        Real hi(int dir)
        Real length(int dir)
        bint ok()
        Real volume()
