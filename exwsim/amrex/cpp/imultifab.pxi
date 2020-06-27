
cdef extern from "AMReX_IArrayBox.H" namespace "amrex" nogil:
    cdef cppclass IArrayBox:
        IArrayBox()

        int nComp()
        Long numPts()
        Long size()
        const Box& box()
        const int* loVect()
        const int* hiVect()
        int* dataPtr()
        int* dataPtr(int)
        int& operator()(const IntVect&)
        int& operator()(const IntVect&, int n)
        Array4[int] array()
        Array4[int] array(int start_comp)
        Array4[const int] const_array()
        Array4[const int] const_array(int start_comp)
        bint isAllocated()

cdef extern from "AMReX_iMultiFab.H" namespace "amrex":
    cdef cppclass iMultiFab:
        ctypedef IArrayBox FAB

        ### From FabArrayBase
        int nComp()
        IndexType ixType()
        bint empty()
        int size()
        bint is_nodal()
        bint is_nodal(int dir)
        bint is_cell_centered()
        const BoxArray& boxArray()
        const DistributionMapping& DistributionMap()
        ### END FabArrayBase

        ##### From Base class FabArray
        bint hasEBFabFactory()
        bint isAllRegular()
        bint ok()

        const FAB& const_get "get"(const MFIter&)
        FAB& operator[](const MFIter&)
        FAB& get(const MFIter&)
        FAB& operator[](int k)
        FAB& get(int k)

        FAB* fabPtr(const MFIter&)
        const FAB* const_fabPtr "fabPtr"(const MFIter&)

        FAB* fabPtr(int)
        const FAB* const_fabPtr "fabPtr"(int)

        void prefetchToDevice(const MFIter&)

        Array4[int] array(const MFIter&)
        Array4[const int] const_array(const MFIter&)

        void setVal(int val)
        void setVal(int val, int comp, int num_comp)
        void setVal(int val, int comp, int num_comp, int nghost)
        void setVal(int val, int comp, int num_comp, const IntVect& nghost)
        void setVal(int, int)
        void setVal(int, const IntVect&)
        void operator=(int val)

        void abs(int comp, int num_comp)
        void abs(int comp, int num_comp, int nghost)
        void plus(int val, int comp, int num_comp)
        void plus(int val, int comp, int num_comp, int nghost)
        void mult(int val, int comp, int num_comp)
        void mult(int val, int comp, int num_comp, int nghost)
        void invert(int val, int comp, int num_comp)
        void invert(int val, int comp, int num_comp, int nghost)

        void setBndry(int val)
        void setDomainBndry(int val, const Geometry& geom)
        void setDomainBndry(int val, int scomp, int ncomp, const Geometry& geom)

        void FillBoundary()
        void FillBoundary(bint)
        void FillBoundary(const Periodicity&)
        void FillBoundary(const Periodicity&, bint)
        void FillBoundary(int scomp, int ncomp)
        void FillBoundary(int scomp, int ncomp, bint)

        ##### END from base class FabArray

        iMultiFab()
        iMultiFab(const BoxArray&,
                 const DistributionMapping&,
                 int ncomp, int ngrow)

        void define(const BoxArray&,
                    const DistributionMapping&,
                    int ncomp, int ngrow)
        void operator=(int r)

        int min(int comp)
        int min(int comp, int nghost)
        int min(const Box& b, int comp)
        int min(const Box& b, int comp, int nghost)

        int max(int comp)
        int max(int comp, int nghost)
        int max(const Box& b, int comp)
        int max(const Box& b, int comp, int nghost)

        Long sum()
        Long sum(int comp)

        @staticmethod
        void Add(iMultiFab& dst, const iMultiFab& src,
                 int srccomp, int dstcomp,
                 int numcomp, int nghost)

        @staticmethod
        void Copy(iMultiFab& dst, const iMultiFab& src,
                  int srccomp, int dstcomp,
                  int numcomp, int nghost)

        @staticmethod
        void Swap(iMultiFab& dst, const iMultiFab& src,
                  int srccomp, int dstcomp,
                  int numcomp, int nghost)

        @staticmethod
        void Subtract(iMultiFab& dst, const iMultiFab& src,
                      int srccomp, int dstcomp,
                      int numcomp, int nghost)

        @staticmethod
        void Multiply(iMultiFab& dst, const iMultiFab& src,
                      int srccomp, int dstcomp,
                      int numcomp, int nghost)

        @staticmethod
        void Divide(iMultiFab& dst, const iMultiFab& src,
                    int srccomp, int dstcomp,
                    int numcomp, int nghost)
