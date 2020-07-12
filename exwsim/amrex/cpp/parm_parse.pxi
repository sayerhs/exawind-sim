from ...utils cimport iostream

cdef extern from "AMReX_ParmParse.H" namespace "amrex" nogil:
    cdef cppclass ParmParse:
        @staticmethod
        void Finalize()

        @staticmethod
        void dumpTable(iostream.ostream&)

        ParmParse()
        ParmParse(const string&)
        bint contains (const char* name)
        int countval(const char* name)
        int countname(const char* name)

        void add(const char*, const int)
        void add(const char*, const long)
        void add(const char*, const double)
        void add(const char*, const string&)

        void addarr(const char*, const vector[int]&)
        void addarr(const char*, const vector[long]&)
        void addarr(const char*, const vector[double]&)
        void addarr(const char*, const vector[string]&)

        int query(const char*, int&)
        int query(const char*, long&)
        int query(const char*, double&)
        int query(const char*, string&)

        int queryarr(const char*, vector[int]&)
        int queryarr(const char*, vector[long]&)
        int queryarr(const char*, vector[double]&)
        int queryarr(const char*, vector[string]&)

        void get(const char*, int&) except +
        void get(const char*, long&) except +
        void get(const char*, double&) except +
        void get(const char*, string&) except +

        void getarr(const char*, vector[int]&) except+
        void getarr(const char*, vector[long]&) except+
        void getarr(const char*, vector[double]&) except+
        void getarr(const char*, vector[string]&) except+
