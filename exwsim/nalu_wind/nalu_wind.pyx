# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from cython.operator cimport dereference as deref
from libcpp.string cimport string
from mpi4py cimport MPI
from mpi4py cimport libmpi as mpi
from stk.api.util.parallel cimport Parallel
from .cpp cimport kokkos_wrapper as _kokkos
from .cpp cimport ext_overset
from .cpp cimport yaml_cpp
from ..tioga cimport tioga_api

from pathlib import Path

import atexit

cpdef kokkos_initialize(int num_devices=-1):
    """Initialize Kokkos"""
    if _kokkos.is_initialized():
        return

    cdef _kokkos.InitArguments args
    args.ndevices = num_devices
    _kokkos.initialize(args)

    atexit.register(kokkos_finalize)

cpdef kokkos_finalize():
    """Finalize Kokkos"""
    if _kokkos.is_initialized():
        _kokkos.finalize()

cdef class NaluWind:
    """Wrapper for Nalu-Wind"""

    def __cinit__(NaluWind self,
                  MPI.Comm comm,
                  str yaml_file,
                  tioga_api.TiogaAPI tg = None,
                  str log_file = None,
                  bint parallel_print = False):
        self.env = &NaluEnv.self()
        cdef mpi.MPI_Comm comm_obj = comm.ob_mpi
        self.env.parallelCommunicator_ = comm_obj
        mpi.MPI_Comm_size(comm_obj, &self.env.pSize_)
        mpi.MPI_Comm_rank(comm_obj, &self.env.pRank_)

        cdef string fname = yaml_file.encode('UTF-8')
        self.doc = yaml_cpp.LoadFile(fname)
        self.sim = new _Sim(self.doc)
        if tg is not None:
            ext_overset.TiogaRef.self(tg.tg)

        cdef string lgfile = str(Path(yaml_file).stem + ".log").encode('UTF-8')
        if log_file is not None:
            lgfile = log_file.encode('UTF-8')
        self.env.set_log_file_stream(lgfile, parallel_print)

    def __dealloc__(NaluWind self):
        if self.sim is not NULL:
            del self.sim

    def initialize(NaluWind self):
        """Initialize the solver"""
        self.sim.load(self.doc)
        self.sim.breadboard()
        self.sim.initialize()

    def init_prolog(NaluWind self, bint multi_solver_mode=False):
        """Perform init tasks before overset connectivity"""
        self.sim.load(self.doc)
        deref(self.sim.timeIntegrator_.overset_).set_multi_solver_mode(multi_solver_mode)
        self.sim.breadboard()
        self.sim.init_prolog()

    def init_epilog(NaluWind self):
        """Perform post overset connectivity init tasks"""
        self.sim.init_epilog()

    def run(NaluWind self):
        """Run simulation"""
        self.sim.run()

    def prepare_for_time_integration(NaluWind self):
        """Perform one time pre-timestep actions"""
        self.sim.timeIntegrator_.prepare_for_time_integration()

    def pre_advance_stage1(NaluWind self):
        """Pre-advance work done before overset connectivity"""
        self.sim.timeIntegrator_.pre_realm_advance_stage1()

    def pre_advance_stage2(NaluWind self):
        """Pre-advance work done before overset connectivity"""
        self.sim.timeIntegrator_.pre_realm_advance_stage2()

    def advance_timestep(NaluWind self):
        for realm in self.sim.timeIntegrator_.realmVec_:
            realm.advance_time_step()

    def post_advance(NaluWind self):
        self.sim.timeIntegrator_.post_realm_advance()

    def pre_overset_conn_work(NaluWind self):
        deref(self.sim.timeIntegrator_.overset_).pre_overset_conn_work()

    def post_overset_conn_work(NaluWind self):
        deref(self.sim.timeIntegrator_.overset_).post_overset_conn_work()

    def register_solution(NaluWind self):
        return deref(self.sim.timeIntegrator_.overset_).register_solution()

    def update_solution(NaluWind self):
        deref(self.sim.timeIntegrator_.overset_).update_solution()

    # @property
    # def time_integrator(NaluWind self):
    #     """Return time integrator instance"""
    #     return TimeIntegrator.wrap_instance(self.sim.timeIntegrator_)

    # @property
    # def realms(NaluWind self):
    #     """Return a list of realms"""
    #     return [Realm.wrap_instance(r)
    #             for r in self.sim.timeIntegrator_.realmVec_]

    @property
    def parallel(NaluWind self):
        """Return the MPI communicator object"""
        cdef Parallel par = Parallel()
        par.comm = self.env.parallelCommunicator_
        par.rank = self.env.pRank_
        par.size = self.env.pSize_
        return par
