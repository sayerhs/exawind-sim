# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from stk.api.mesh.meta cimport StkMetaData
from stk.api.mesh.bulk cimport StkBulkData

cdef class Realm:

    @staticmethod
    cdef wrap_instance(_Realm* realm_in):
        cdef Realm obj = Realm.__new__(Realm)
        obj.realm = realm_in
        return obj

    @property
    def name(Realm self):
        """Return realm name"""
        return self.realm.name().decode('UTF-8')

    @property
    def meta(Realm self):
        """Return STK MetaData instance"""
        return StkMetaData.wrap_instance(&self.realm.meta_data())

    @property
    def bulk(Realm self):
        """Return STK BulkData instance"""
        return StkBulkData.wrap_instance(&self.realm.bulk_data())

    @property
    def has_mesh_motion(Realm self):
        """Flag indicating if there is mesh motion"""
        return self.realm.does_mesh_move()

    def __repr__(Realm self):
        return "<%s: %s>"%(self.__class__.__name__, self.name)
