
cdef extern from "AMReX_MFIter.H" namespace "amrex::MFIter" nogil:
    cpdef enum MFIterFlags "Flags":
        Tiling
        AllBoxes
        NoTeamBarrier
        SkipInit

    cpdef enum MFIterREducer "MFReducer":
        SUM
        MAX
        MIN

cdef extern from "AMReX_MFIter.H" namespace "amrex" nogil:
    cdef cppclass MFItInfo:
        MFITInfo()
        MFItInfo& EnableTiling()
        MFItInfo& SetDynamic(bint)
        MFItInfo& DisableDeviceSync()
        MFItInfo& SetDeviceSync(bint)
        MFItInfo& SetNumStreams(int)
        MFItInfo& UseDefaultStream()

    cdef cppclass MFIter:
        MFIter(const FabArrayBase&)
        MFIter(const FabArrayBase&, const MFItInfo&)

        MFIter(const MultiFab&)
        MFIter(const MultiFab&, const MFItInfo&)

        MFIter(const iMultiFab&)
        MFIter(const iMultiFab&, const MFItInfo&)

        Box tilebox()
        Box tilebox(const IntVect& nodal)
        Box tilebox(const IntVect& nodal, const IntVect& ngrow)
        Box nodaltilebox()
        Box nodaltilebox(int dir)
        Box growntilebox()
        Box growntilebox(const IntVect&)
        Box grownnodaltilebox()
        Box grownnodaltilebox(int dir)
        Box grownnodaltilebox(int dir, int ng)
        Box grownnodaltilebox(int dir, const IntVect&)

        Box validbox()
        Box fabbox()

        void operator++()
        bint isValid()
        int index()
        int length()

    bool TilingIfNotGPU()
