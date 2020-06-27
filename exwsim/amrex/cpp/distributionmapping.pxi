
cdef extern from "AMReX_DistributionMapping.H" namespace "amrex" nogil:
    cdef cppclass DistributionMapping:
        DistributionMapping()
        DistributionMapping(const BoxArray&)
        DistributionMapping(const BoxArray&, int)

        void define(const BoxArray&)
        void define(const BoxArray&, int)

        const Vector[int]& ProcessorMap()
        Long size()
        Long capacity()
        bint empty()

        Long linkCount()
        int operator[](int index)
