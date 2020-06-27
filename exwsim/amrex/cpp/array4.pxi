
cdef extern from "AMReX_Array4.H" namespace "amrex" nogil:
    cdef cppclass Array4[T]:
        Array4()
        T& operator()(int i, int j, int k)
        T& operator()(int i, int j, int k, int n)
        T& operator()(const IntVect&)
        T& operator()(const IntVect&, int n)

        T* dataPtr()
        size_t size()
        int nComp()
        T* ptr(int i, int j, int k)
        T* ptr(int i, int j, int k, int n)

    Dim3 lbound[T](const Array4[T]&)
    Dim3 ubound[T](const Array4[T]&)
    Dim3 length[T](const Array4[T]&)
