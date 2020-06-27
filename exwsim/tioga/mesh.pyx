# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

cimport numpy as np
import numpy as np

cdef class UnstructuredMesh:
    """Data structure representing an unstructured mesh block for TIOGA"""

    def __cinit__(UnstructuredMesh self):
        self.mesh_tag = -1

    def __init__(UnstructuredMesh self):
        try:
            print(self.xyz)
        except AttributeError:
            print("xyz not initialized")
