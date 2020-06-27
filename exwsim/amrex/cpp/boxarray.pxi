
cdef extern from "AMReX_BoxArray.H" namespace "amrex" nogil:
    cdef cppclass BoxArray:
        BoxArray()
        BoxArray(const Box&)

        void define(const Box&)

        void clear()
        void resize(Long len)
        Long size()
        Long capacity()
        bint empty()
        Long numPts()

        BoxArray& maxSize(int block_size)
        BoxArray& maxSize(const IntVect&)
        BoxArray& refine(int)
        BoxArray& refine(const IntVect&)
        BoxArray& coarsen(int)
        BoxArray& coarsen(const IntVect&)

        BoxArray& grow(int n)
        BoxArray& grow(const IntVect&)
        BoxArray& grow(int dir, int n_cell)
        BoxArray& growLo(int dir, int n_cell)
        BoxArray& growHi(int dir, int n_cell)

        BoxArray& surroundingNodes()
        BoxArray& surroundingNodes(int dir)
        BoxArray& enclosedCells()
        BoxArray& enclosedCells(int dir)

        BoxArray& convert(IndexType)
        BoxArray& convert(const IntVect&)

        Box operator[](int)
        Box operator[](const MFIter&)
        Box get(int)

        bint ok()
        bint isDisjoint()
        bint contains(const IntVect&)
