
cdef extern from "AMReX_Box.H" namespace "amrex":
    cdef cppclass Box:
        Box()
        Box(const IntVect&, const IntVect&)
        Box(const IntVect&, const int*)
        Box(const IntVect&, const IntVect&, const IntVect&)
        Box(const IntVect&, const IntVect&, IndexType)

        const IntVect& smallEnd()
        const IntVect& bigEnd()

        int smallEnd(int dir)
        int bigEnd(int dir)

        IndexType ixType()
        IntVect type()
        CellIndex type(int dir)
        IntVect size()
        IntVect length()
        int length(int dir)

        const int* loVect()
        const int* hiVect()

        int operator[](Orientation face)
        bint isEmpty()
        bint ok()
        bint contains(const IntVect&)
        bint contains(const Box&)
        bint strictly_contains(const IntVect&)
        bint strictly_contains(const Box&)
        bint intersects(const Box&)
        bint sameSize(const Box&)
        bint sameType(const Box&)

        amrex_long numPts()
        amrex_long volume()
        int longside(int& dir)
        int longside()
        int shortside(int& dir)
        int shortside()
        amrex_long index(const IntVect&)
        IntVect atOffset(amrex_long offset)

        Box& convert(IndexType)
        Box& convert(const IntVect&)

        Box& surroundingNodes()
        Box& surroundingNodes(int dir)
        Box& enclosedCells()
        Box& enclosedCells(int dir)

        Box& grow(int i)
        Box& grow(const IntVect&)
        Box& growLo(int dir)
        Box& growLo(int dir, int n_cell)
        Box& growHi(int dir)
        Box& growHi(int dir, int n_cell)
        Box& grow(Orientation face)
        Box& grow(Orientation face, int n_cell)

        bint isSquare()
        void normalize()

    Dim3 lbound(const Box&)
    Dim3 ubound(const Box&)
    Dim3 begin(const Box&)
    Dim3 end(const Box&)
    Dim3 length(const Box&)

    Box minBox(const Box&, const Box&, IndexType)
