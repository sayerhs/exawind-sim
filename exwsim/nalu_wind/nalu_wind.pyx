# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from libcpp.string cimport string
from mpi4py cimport MPI
from mpi4py cimport libmpi as mpi
from .cpp cimport kokkos_wrapper as _kokkos
from .cpp cimport yaml_cpp
from stk.api.util.parallel cimport Parallel

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
    print("Finalizing Kokkos")
    if _kokkos.is_initialized():
        _kokkos.finalize()

cdef class NaluWind:
    """Wrapper for Nalu-Wind"""

    def __cinit__(NaluWind self, MPI.Comm comm, str yaml_file):
        self.env = &NaluEnv.self()
        cdef mpi.MPI_Comm comm_obj = comm.ob_mpi
        self.env.parallelCommunicator_ = comm_obj
        mpi.MPI_Comm_size(comm_obj, &self.env.pSize_)
        mpi.MPI_Comm_rank(comm_obj, &self.env.pRank_)

        cdef string fname = yaml_file.encode('UTF-8')
        self.doc = yaml_cpp.LoadFile(fname)
        self.sim = new _Sim(self.doc)

    def __dealloc__(NaluWind self):
        if self.sim is not NULL:
            del self.sim

    def initialize(NaluWind self):
        """Initialize the solver"""
        self.sim.load(self.doc)
        self.sim.breadboard()
        self.sim.initialize()

    def run(NaluWind self):
        """Run simulation"""
        self.sim.run()

    def prepare_for_timestep(NaluWind self):
        """Perform one time pre-timestep actions"""
        self.sim.timeIntegrator_.prepare_for_timestep()

    def pre_advance_stage1(NaluWind self):
        """Pre-advance work done before overset connectivity"""
        self.sim.timeIntegrator_.pre_advance_timestep_stage1()

    def pre_advance_stage2(NaluWind self):
        """Pre-advance work done before overset connectivity"""
        self.sim.timeIntegrator_.pre_advance_timestep_stage2()

    def advance_timestep(NaluWind self):
        for realm in self.sim.timeIntegrator_.realmVec_:
            realm.advance_time_step()

    def post_advance(NaluWind self):
        self.sim.timeIntegrator_.post_advance_timestep()

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
