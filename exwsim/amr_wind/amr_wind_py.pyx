# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from cython.operator cimport dereference as deref
from libcpp.string cimport string
from libcpp.cast cimport dynamic_cast
from amrex.amrex_core cimport AmrCore
from amrex.amrex_base cimport MultiFab
from ..tioga.tioga_api cimport TiogaAPI

cpdef enum FieldState:
    NP1 = <int>field.FieldState.NP1
    N = <int>field.FieldState.N
    NM1 = <int>field.FieldState.NM1
    NPH = <int>field.FieldState.NPH
    NMH = <int>field.FieldState.NMH
    New = <int>field.FieldState.New
    Old = <int>field.FieldState.Old

cpdef enum FieldLoc:
    CELL = <int>field.FieldLoc.CELL
    NODE = <int>field.FieldLoc.NODE
    XFACE = <int>field.FieldLoc.XFACE
    YFACE = <int>field.FieldLoc.YFACE
    ZFACE = <int>field.FieldLoc.ZFACE

cdef class AMRWind:
    """AMR-Wind interface

    This class represents the entrypoint from Python to excute the AMR-Wind solver.
    """

    def __cinit__(AMRWind self, TiogaAPI tg = None):
        self.obj = new incflo.incflo()
        if tg is not None:
            self.obj.sim().activate_overset()
            self.tgiface.reset(new amr_tioga_iface.AMRTiogaIface(
                self.obj.sim(), deref(tg.tg)))

    def __dealloc__(AMRWind self):
        del self.obj

    def init_prolog(AMRWind self):
        """Initialization actions before overset connectivity"""
        self.obj.init_mesh()
        self.obj.init_amr_wind_modules()

    def init_epilog(AMRWind self):
        """Initialization actions after overset connectivity"""

    def pre_overset_conn_work(AMRWind self):
        """Register mesh for TIOGA connectivity"""
        if not self.tgiface:
            raise RuntimeError("Overset capability not activated in AMR-Wind")
        deref(self.tgiface).pre_overset_conn_work()

    def post_overset_conn_work(AMRWind self):
        """Register mesh for TIOGA connectivity"""
        if not self.tgiface:
            raise RuntimeError("Overset capability not activated in AMR-Wind")
        deref(self.tgiface).post_overset_conn_work()

    def prepare_for_time_integration(AMRWind self):
        """Actions after overset connectivity has been established"""
        self.obj.prepare_for_time_integration()

    @property
    def incflo(AMRWind self):
        return Incflo.wrap_instance(self.obj)

    @property
    def sim(AMRWind self):
        """Return the CFDSim instance associated with the solver"""
        return CFDSim.wrap_instance(&(self.obj.sim()))

    @property
    def repo(AMRWind self):
        """Return the FieldRepository instance associated with the solver"""
        return FieldRepo.wrap_instance(&(self.obj.repo()))

ctypedef incflo.incflo* _CppIncfloPtr

cdef class Incflo(AmrCore):

    cdef incflo.incflo* cls(Incflo self):
        return dynamic_cast[_CppIncfloPtr](self.ptr)

    @staticmethod
    cdef Incflo wrap_instance(incflo.incflo* ptr, bint owner=False):
        cdef Incflo self = Incflo.__new__(Incflo)
        self.ptr = ptr
        self.owner = False
        return self

cdef class CFDSim:
    """CFDSim wrapper"""

    def __cinit__(CFDSim self):
        self.sim = NULL
        self.owner = False

    def __dealloc__(CFDSim self):
        if self.sim is not NULL and self.owner is True:
            del self.sim

    @staticmethod
    cdef wrap_instance(cfd_sim.CFDSim* in_sim, bint owner=False):
        cdef CFDSim self = CFDSim.__new__(CFDSim)
        self.sim = in_sim
        self.owner = owner
        return self

    def create_turbulence_model(CFDSim self):
        """Initialize the turbulence model instance"""
        self.sim.create_turbulence_model()

    def init_physics(CFDSim self):
        """Initialize all available physics models"""
        self.sim.init_physics()

    def activate_overset(CFDSim self):
        """Activate overset data structures"""
        self.sim.activate_overset()

    @property
    def mesh(CFDSim self):
        return AmrCore.wrap_instance(&self.sim.mesh())

    @property
    def repo(CFDSim self):
        return FieldRepo.wrap_instance(&self.sim.repo())

    @property
    def has_overset(CFDSim self):
        return self.sim.has_overset()

cdef class Field:
    """Field"""

    def __init__(Field self, *args, **kwargs):
        raise RuntimeError("Cannot instantiate field")

    @staticmethod
    cdef wrap_instance(field.Field* in_fld):
        cdef Field self = Field.__new__(Field)
        self.fld = in_fld
        return self

    def __call__(Field self, int lev):
        """Return MultiFab at level"""
        return MultiFab.wrap_instance(&deref(self.fld)(lev))

    @property
    def name(Field self):
        return self.fld.name().decode('UTF-8')

    @property
    def base_name(Field self):
        return self.fld.base_name().decode('UTF-8')

    @property
    def num_comp(Field self):
        return self.fld.num_comp()

    @property
    def num_states(Field self):
        return self.fld.num_states()

    @property
    def field_loc(Field self):
        return <FieldLoc>self.fld.field_location()

    @property
    def field_state(Field self):
        return <FieldState>self.fld.field_state()

    def __repr__(Field self):
        return "<%s: %s>"%(self.__class__.__name__, self.name)

cdef class IntField:
    """IntField"""

    def __init__(IntField self, *args, **kwargs):
        raise RuntimeError("Cannot instantiate field")

    @staticmethod
    cdef wrap_instance(field.IntField* in_fld):
        cdef IntField self = IntField.__new__(IntField)
        self.fld = in_fld
        return self

    @property
    def name(IntField self):
        return self.fld.name().decode('UTF-8')

    @property
    def num_comp(IntField self):
        return self.fld.num_comp()

    @property
    def field_loc(IntField self):
        return <FieldLoc>self.fld.field_location()

    def __repr__(IntField self):
        return "<%s: %s>"%(self.__class__.__name__, self.name)

cdef class FieldRepo:
    """Field Repository"""

    def __cinit__(FieldRepo self):
        self.repo = NULL
        self.owner = False

    def __dealloc__(FieldRepo self):
        if self.repo is not NULL and self.owner is True:
            del self.repo

    @staticmethod
    cdef wrap_instance(field.FieldRepo* in_repo, bint owner=False):
        cdef FieldRepo self = FieldRepo.__new__(FieldRepo)
        self.repo = in_repo
        self.owner = owner
        return self

    def declare_field(FieldRepo self, str fname,
                      int ncomp=1, int nghost=0, int nstate=1,
                      FieldLoc floc=FieldLoc.CELL):
        """
        Declare a new real-valued field

        Args:
            fname (str): Name of the field
            ncomp (int): Number of components
            nghost (int): Number of ghost cells/nodes
            nstate (int): Number of states for this field
            floc (FieldLoc): Location of the field (cell, node, face)
        """
        cdef string cname = fname.encode('UTF-8')
        cdef field.FieldLoc cfloc = <field.FieldLoc>(floc)
        cdef field.Field* fld = &self.repo.declare_field(
            cname, ncomp, nghost, nstate, cfloc)
        return Field.wrap_instance(fld)

    def get_field(FieldRepo self, str fname, FieldState fstate = FieldState.New):
        """Return field by name"""
        cdef string cname = fname.encode('UTF-8')
        cdef field.FieldState cfs = <field.FieldState>(fstate)
        return Field.wrap_instance(&(self.repo.get_field(cname, cfs)))

    def field_exists(FieldRepo self, str fname, FieldState fstate=FieldState.New):
        """Return True if the field by name exists and has requested state

        Args:
            fname (str): Base name of the field
            fstate (FieldState): State of the field
        """
        cdef string cname = fname.encode('UTF-8')
        cdef field.FieldState cfs = <field.FieldState>(fstate)
        return self.repo.field_exists(cname, cfs)

    def declare_int_field(FieldRepo self, str fname,
                          int ncomp=1, int nghost=0, int nstate=1,
                          FieldLoc floc=FieldLoc.CELL):
        """
        Declare a new int-valued field

        Args:
            fname (str): Name of the field
            ncomp (int): Number of components
            nghost (int): Number of ghost cells/nodes
            nstate (int): Number of states for this field
            floc (FieldLoc): Location of the field (cell, node, face)
        """
        cdef string cname = fname.encode('UTF-8')
        cdef field.FieldLoc cfloc = <field.FieldLoc>(floc)
        cdef field.IntField* fld = &self.repo.declare_int_field(
            cname, ncomp, nghost, nstate, cfloc)
        return IntField.wrap_instance(fld)

    def get_int_field(FieldRepo self, str fname, FieldState fstate = FieldState.New):
        """Return field by name"""
        cdef string cname = fname.encode('UTF-8')
        cdef field.FieldState cfs = <field.FieldState>(fstate)
        return IntField.wrap_instance(&(self.repo.get_int_field(cname, cfs)))

    def int_field_exists(FieldRepo self, str fname, FieldState fstate=FieldState.New):
        """Does the field exist"""
        cdef string cname = fname.encode('UTF-8')
        cdef field.FieldState cfs = <field.FieldState>(fstate)
        return self.repo.int_field_exists(cname, cfs)
