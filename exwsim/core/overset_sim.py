# -*- coding: utf-8 -*-

"""\
Overset simulation interface
-----------------------------
"""

import numpy as np
from mpi4py import MPI
from .. import tioga
from .par_printer import ParallelPrinter
from .par_timer import ParTimer

class OversetSimulation:
    """Representation of an overset simulation"""

    def __init__(self, comm):
        """
        Args:
            comm: MPI communicator instance
        """
        #: World communicator instance
        self.comm = comm
        #: Parallel printer utility
        self.printer = ParallelPrinter(comm)
        #: TIOGA overset connectivity instance
        self.tioga = tioga.get_instance()
        self.tioga.set_communicator(comm)

        #: List of solvers active in this overset simulation
        self.solvers = []
        #: Flag indicating whether an AMR solver is active in this simulation
        self.has_amr = False
        #: Flag indicating whether an unstructured solver is active in this simulation
        self.has_unstructured = False
        #: Interval for overset updates during timestepping
        self.overset_update_interval = 100000000
        #: Last timestep run during this simulation
        self.last_timestep = 0
        #: Flag indicating whether initialization tasks have been performed
        self.initialized = False
        #: Parallel timer instance
        self.timer = ParTimer(comm)

    def register_solver(self, solver):
        """Register a solver"""
        self.solvers.append(solver)

    def _check_solver_types(self):
        """Determine unstructured and structured solver types"""
        flag = np.empty((2,), dtype=np.int)
        gflag = np.empty((2,), dtype=np.int)
        flag[0] = 1 if any(ss.is_amr for ss in self.solvers) else 0
        flag[1] = 1 if any(ss.is_unstructured for ss in self.solvers) else 0
        self.comm.Allreduce(flag, gflag, MPI.MAX)
        self.has_amr = (gflag[0] == 1)
        self.has_unstructured = (gflag[1] == 1)

    def _determine_overset_interval(self):
        """Determine if we should update connectivity during time integration"""
        flag = np.empty((1,), dtype=np.int)
        gflag = np.empty((1,), dtype=np.int)

        flag[0] = min(ss.overset_update_interval for ss in self.solvers)
        self.comm.Allreduce(flag, gflag, MPI.MIN)
        self.overset_update_interval = gflag[0]
        self.printer.echo("Overset update interval = ", self.overset_update_interval)

    def _do_connectivity(self, tstep):
        """Return True if connectivity must be updated at a given timestep"""
        return ((tstep > 0) and (tstep % self.overset_update_interval) == 0)

    def initialize(self):
        """Initialize all solvers"""
        self._check_solver_types()
        if not self.has_unstructured:
            raise RuntimeError("OversetSimulation requires at least one unstructured solver")

        with self.timer("Init"):
            for ss in self.solvers:
                ss.init_prolog(multi_solver_mode=True)

            self._determine_overset_interval()

            self.perform_overset_connectivity()

            for ss in self.solvers:
                ss.init_epilog()
                ss.prepare_solver_prolog()

            self.exchange_solution()

            for ss in self.solvers:
                ss.prepare_solver_epilog()

        self.comm.Barrier()
        self.initialized = True

    def perform_overset_connectivity(self):
        """Determine field, fringe, hole information"""
        for ss in self.solvers:
            ss.pre_overset_conn_work()

        tg = self.tioga
        if self.has_amr:
            tg.preprocess_amr_data()

        tg.profile()
        tg.perform_connectivity()
        if self.has_amr:
            tg.perform_connectivity_amr()

        for ss in self.solvers:
            ss.post_overset_conn_work()

    def exchange_solution(self):
        """Exchange solution between solvers"""
        for ss in self.solvers:
            ss.register_solution()

        if self.has_amr:
            self.tioga.data_update_amr()
        else:
            raise NotImplementedError("Invalid overset exchange")

        for ss in self.solvers:
            ss.update_solution()

    def run_timesteps(self, nsteps=1):
        """Run prescribed number of timesteps"""
        if not self.initialized:
            raise RuntimeError("OversetSimulation has not been initialized")

        wclabels = "Pre Conn Solve Post".split()
        tstart = self.last_timestep + 1
        tend = self.last_timestep + 1 + nsteps
        self.printer.echo("Running %d timesteps starting from %d"%(nsteps, tstart))
        for nt in range(tstart, tend):
            with self.timer("Pre", incremental=True):
                for ss in self.solvers:
                    ss.pre_advance_stage1()

            with self.timer("Conn", incremental=True):
                if self._do_connectivity(nt):
                    self.perform_overset_connectivity()

            with self.timer("Pre", incremental=False):
                for ss in self.solvers:
                    ss.pre_advance_stage2()

            with self.timer("Conn"):
                self.exchange_solution()

            with self.timer("Solve"):
                for ss in self.solvers:
                    ss.advance_timestep()

            with self.timer("Post"):
                for ss in self.solvers:
                    ss.post_advance()

            self.comm.Barrier()
            wctime = self.timer.get_timings(wclabels)
            wctime_str = ' '.join("%s: %.4f"%(k, v) for k, v in wctime.items())
            self.printer.echo("WCTime:", "%5d"%nt, wctime_str, "Total:",
                              "%.4f"%sum(wctime.values()))
        self.last_timestep = tend

    def summarize_timings(self):
        """Summarize timers"""
        tt = self.timer.timers
        labels = "Init Pre Conn Solve Post".split()
        sep = "-"*80
        hdr = "%-20s %5s %12s %12s %12s %12s"%(
            "Timer", "Calls", "Tot.", "Avg.", "Min.", "Max.")
        self.printer.echo("\n" + sep + "\n" + hdr + "\n")
        for kk in labels:
            tvals = tt[kk]
            self.printer.echo("%-20s %5d %12.4f %12.4f %12.4f %12.4f"%(
                kk, tvals[0], tvals[-1], (tvals[-1]/tvals[0]), tvals[2], tvals[3]))
        self.printer.echo(sep + "\n")
