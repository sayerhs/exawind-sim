# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

"""\
Nalu-Wind Interface
-------------------
"""

from cython.operator cimport dereference as deref
from libcpp.string cimport string
from libcpp.vector cimport vector
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
    """Initialize Kokkos

    This function must be invoked before any Nalu-Wind data structures are
    accessed. This will automatically register a function that will call the
    finalize action when the python script quits. So it is not necessary for
    the user to explicitly call :func:`kokkos_finalize` in their scripts.

    Args:
        num_devices (int): Number of devices used per compute node
    """
    if _kokkos.is_initialized():
        return

    cdef _kokkos.InitArguments args
    args.ndevices = num_devices
    _kokkos.initialize(args)

    atexit.register(kokkos_finalize)

cpdef kokkos_finalize():
    """Finalize Kokkos

    This function is automatically registered by the initialize call to be
    executed when Python interpreter exits. However, user can also call this
    function manually to finalize Kokkos environment.
    """
    if _kokkos.is_initialized():
        _kokkos.finalize()

cdef class NaluWind:
    """Interface to drive Nalu-Wind through Python

    If ``log_file`` is not provided, then the base name YAML input file is used
    with a ``.log`` extension for the log file.

    Args:
        comm: A valid MPI communicator instance
        yaml_file (path): Path to the Nalu-Wind input file
        tg (TIOGA): External TIOGA instance for use in multi-solver mode
        log_file (path): Path to the redirect outputs
        parallel_print (bool): If True, enables output from all MPI ranks
    """

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
        """Perform all the initialization steps before time integration.

        This function should only be called in a standalone Nalu-Wind solution
        mode. When using Nalu-Wind in multi-solver mode with another instance
        of Nalu-Wind or another CFD solver, e.g., AMR-Wind, use
        :meth:`init_prolog` and :meth:`init_epilog` instead to perform actions
        before and after overset connectivity steps.
        """
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
        """Perform time-integration for prescribed number of timesteps in input file

        Together with :meth:`initialize` this method represents the equivalent
        of the C++ executable that can be executed within the Python script.
        """
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
        """Advances all participating realms by one non-linear iteration"""
        for realm in self.sim.timeIntegrator_.realmVec_:
            realm.advance_time_step()

    def post_advance(NaluWind self):
        """Perform actions after advancing a timestep

        Examples include writing output and restart files to disk
        """
        self.sim.timeIntegrator_.post_realm_advance()

    def pre_overset_conn_work(NaluWind self):
        """Register the latest mesh data before performing overset connectivity"""
        deref(self.sim.timeIntegrator_.overset_).pre_overset_conn_work()

    def post_overset_conn_work(NaluWind self):
        """Perform necessary updates within Nalu-Wind after overset connectivity step"""
        deref(self.sim.timeIntegrator_.overset_).post_overset_conn_work()

    def register_solution(NaluWind self, list field_names = None):
        """Register the latest solution fields with TIOGA for solution exchange"""
        cdef list finp = field_names or ["velocity", "pressure"]
        cdef vector[string] fnames
        for ff in finp:
            fnames.push_back(ff.encode('UTF-8'))
        return deref(self.sim.timeIntegrator_.overset_).register_solution(fnames)

    def update_solution(NaluWind self):
        """Update Nalu-Wind solution fields after an overset solution exchange step"""
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
