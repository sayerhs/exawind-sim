
cdef extern from "AMReX_FabFactory.H" namespace "amrex" nogil:
    cpdef enum FabType:
        covered
        regular
        singlevalued
        multivalued
        undefined

    cdef cppclass FabInfo:
        pass

    cdef cppclass DefaultFabFactory[FAB]:
        FAB* create(const Box&, int, const FabInfo&, int)
        FAB* create_alias(const FAB&, int, int)
        void destroy(FAB*)
        DefaultFabFactory[FAB]* clone()

cdef extern from "AMReX_BoxArray.H" namespace "amrex" nogil:
    cdef cppclass BoxArray

cdef extern from "AMReX_DistributionMapping.H" namespace "amrex" nogil:
    cdef cppclass DistributionMapping

cdef extern from "AMReX_FabArrayBase.H" namespace "amrex" nogil:
    cdef cppclass FabArrayBase:
        pass

cdef extern from "AMReX_FabArray.H" namespace "amrex" nogil:
    cdef cppclass FabArray[FAB](FabArrayBase):
        pass

cdef extern from "AMReX_FArrayBox.H" namespace "amrex" nogil:
    cdef cppclass FArrayBox:
        FArrayBox()

        int nComp()
        Long numPts()
        Long size()
        const Box& box()
        const int* loVect()
        const int* hiVect()
        Real* dataPtr()
        Real* dataPtr(int)
        Real& operator()(const IntVect&)
        Real& operator()(const IntVect&, int n)
        Array4[Real] array()
        Array4[Real] array(int start_comp)
        Array4[const Real] const_array()
        Array4[const Real] const_array(int start_comp)
        bint isAllocated()

cdef extern from "AMReX_MFIter.H" namespace "amrex" nogil:
    cdef cppclass MFIter

cdef extern from "AMReX_MultiFab.H" namespace "amrex":
    cdef cppclass MultiFab(FabArray[FArrayBox]):
        ctypedef FArrayBox FAB

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

        Array4[Real] array(const MFIter&)
        Array4[const Real] const_array(const MFIter&)

        void setVal(Real val)
        void setVal(Real val, int comp, int num_comp)
        void setVal(Real val, int comp, int num_comp, int nghost)
        void setVal(Real val, int comp, int num_comp, const IntVect& nghost)
        void setVal(Real, int)
        void setVal(Real, const IntVect&)
        void operator=(Real val)

        void abs(int comp, int num_comp)
        void abs(int comp, int num_comp, int nghost)
        void plus(Real val, int comp, int num_comp)
        void plus(Real val, int comp, int num_comp, int nghost)
        void mult(Real val, int comp, int num_comp)
        void mult(Real val, int comp, int num_comp, int nghost)
        void invert(Real val, int comp, int num_comp)
        void invert(Real val, int comp, int num_comp, int nghost)

        void setBndry(Real val)
        void setDomainBndry(Real val, const Geometry& geom)
        void setDomainBndry(Real val, int scomp, int ncomp, const Geometry& geom)

        void FillBoundary()
        void FillBoundary(bint)
        void FillBoundary(const Periodicity&)
        void FillBoundary(const Periodicity&, bint)
        void FillBoundary(int scomp, int ncomp)
        void FillBoundary(int scomp, int ncomp, bint)

        ##### END from base class FabArray

        MultiFab()
        MultiFab(const BoxArray&,
                 const DistributionMapping&,
                 int ncomp, int ngrow)

        void define(const BoxArray&,
                    const DistributionMapping&,
                    int ncomp, int ngrow)
        void operator=(Real r)

        Real min(int comp)
        Real min(int comp, int nghost)
        Real min(const Box& b, int comp)
        Real min(const Box& b, int comp, int nghost)

        Real max(int comp)
        Real max(int comp, int nghost)
        Real max(const Box& b, int comp)
        Real max(const Box& b, int comp, int nghost)

        Real sum()
        Real sum(int comp)

        @staticmethod
        Real Dot(const MultiFab& x, int xcomp,
                 const MultiFab& y, int ycomp,
                 int num_comp, int nghost)

        @staticmethod
        void Add(MultiFab& dst, const MultiFab& src,
                 int srccomp, int dstcomp,
                 int numcomp, int nghost)

        # @staticmethod
        # void Add(MultiFab& dst, const MultiFab& src,
        #          int srccomp, int dstcomp,
        #          int numcomp, const IntVect& nghost)

        @staticmethod
        void Copy(MultiFab& dst, const MultiFab& src,
                 int srccomp, int dstcomp,
                 int numcomp, int nghost)

        # @staticmethod
        # void Copy(MultiFab& dst, const MultiFab& src,
        #          int srccomp, int dstcomp,
        #          int numcomp, const IntVect& nghost)

        @staticmethod
        void Swap(MultiFab& dst, const MultiFab& src,
                  int srccomp, int dstcomp,
                  int numcomp, int nghost)

        # @staticmethod
        # void Swap(MultiFab& dst, const MultiFab& src,
        #           int srccomp, int dstcomp,
        #           int numcomp, const IntVect& nghost)

        @staticmethod
        void Subtract(MultiFab& dst, const MultiFab& src,
                  int srccomp, int dstcomp,
                  int numcomp, int nghost)

        # @staticmethod
        # void Subtract(MultiFab& dst, const MultiFab& src,
        #           int srccomp, int dstcomp,
        #           int numcomp, const IntVect& nghost)

        @staticmethod
        void Multiply(MultiFab& dst, const MultiFab& src,
                      int srccomp, int dstcomp,
                      int numcomp, int nghost)

        # @staticmethod
        # void Multiply(MultiFab& dst, const MultiFab& src,
        #               int srccomp, int dstcomp,
        #               int numcomp, const IntVect& nghost)

        @staticmethod
        void Divide(MultiFab& dst, const MultiFab& src,
                    int srccomp, int dstcomp,
                    int numcomp, int nghost)

        # @staticmethod
        # void Divide(MultiFab& dst, const MultiFab& src,
        #             int srccomp, int dstcomp,
        #             int numcomp, const IntVect& nghost)

        @staticmethod
        void Saxpy(MultiFab& dst, Real a,
                   const MultiFab& src,
                   int srccomp, int dstcomp,
                   int numcomp, int nghost)

        # @staticmethod
        # void Saxpy(MultiFab& dst, Real a,
        #            const MultiFab& src,
        #            int srccomp, int dstcomp,
        #            int numcomp, const IntVect& nghost)

        @staticmethod
        void Xpay(MultiFab& dst, Real a,
                   const MultiFab& src,
                   int srccomp, int dstcomp,
                   int numcomp, int nghost)

        # @staticmethod
        # void Xpay(MultiFab& dst, Real a,
        #            const MultiFab& src,
        #            int srccomp, int dstcomp,
        #            int numcomp, const IntVect& nghost)

        @staticmethod
        void LinComb(MultiFab& dst,
                     Real a, const MultiFab& x, int xcomp,
                     Real b, const MultiFab& y, int ycomp,
                     int dstcomp, int numcomp, int nghost)

        # @staticmethod
        # void LinComb(MultiFab& dst,
        #              Real a, const MultiFab& x, int xcomp,
        #              Real b, const MultiFab& y, int ycomp,
        #              int dstcomp, int numcomp, const IntVect& nghost)


