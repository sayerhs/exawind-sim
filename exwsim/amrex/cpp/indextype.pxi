from libcpp cimport bool

cdef extern from "AMReX_IndexType.H" namespace "amrex::IndexType" nogil:
    cpdef enum CellIndex:
        CELL
        NODE

cdef extern from "AMReX_IndexType.H" namespace "amrex" nogil:
    cdef cppclass IndexType:
        IndexType()
        IndexType(const IntVect&)
        IndexType(CellIndex i, CellIndex j, CellIndex k)
        void set(int dir)
        void unset(int dir)
        bool test(int dir)
        void setall()
        void clear()
        bool any()
        bool ok()
        void flip(int i)
        bool operator==(const IndexType&)
        bool operator!=(const IndexType&)
        bool cellCentered()
        bool cellCentered(int dir)
        bool nodeCentered()
        bool nodeCentered(int dir)
        void setType(int dir, CellIndex t)
        CellIndex ixType(int dir)
        int operator[](int dir)
        IntVect ixType()
        @staticmethod
        IndexType TheCellType()
        @staticmethod
        IndexType TheNodeType()
