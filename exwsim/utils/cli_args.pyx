# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

cdef class CLIArgs:

    def __cinit__(CLIArgs self, list pyargs):
        """
        Args:
            pyargs (list): List of string arguments
        """
        cdef str parg
        cdef string sarg
        cdef int argc = len(pyargs)
        self.sargs.reserve(argc)
        self.cargs.reserve(argc)

        for parg in pyargs:
            sarg = parg.encode('UTF-8')
            self.sargs.push_back(sarg)
            self.cargs.push_back(&self.sargs.back()[0])

    cdef int argc(CLIArgs self):
        return <int>(self.sargs.size())

    cdef char** argv(CLIArgs self):
        return self.cargs.data()
