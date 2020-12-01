# -*- coding: utf-8 -*-

"""\
Parallel timer utility
----------------------
"""

from collections import defaultdict
from contextlib import contextmanager
import numpy as np
from mpi4py import MPI

class ParTimer:
    """Parallel timer utility"""

    #: Counter for timers
    CTR = 0
    #: Index of the current timer
    IDX = 1
    #: Index of the min time
    IMIN = 2
    #: Index of the max time
    IMAX = 3
    #: Index of the total timer
    ITOT = 4
    #: Total number of timer entries
    NTARR = 5

    def __init__(self, comm, barrier=True):
        """
        Args:
            comm: Parallel communicator instance
        """
        self.comm = comm
        self.barrier = barrier
        self.timers = defaultdict(lambda: np.zeros((self.NTARR,)))

    @contextmanager
    def __call__(self, label, incremental=False):
        """Yield a timer for timing a block"""
        if not incremental:
            tarr = self.timers[label]
            tarr[self.IDX] = 0.0

        t1 = MPI.Wtime()

        yield

        if self.barrier:
            self.comm.Barrier()
        t2 = MPI.Wtime()

        tdiff = t2 - t1
        self.timers[label][self.IDX] += tdiff
        if not incremental:
            tarr = self.timers[label]
            ttime = tarr[self.IDX]
            tarr[self.IMIN] = min(tarr[self.IMIN], ttime) if tarr[self.IMIN] > 0.0 else ttime
            tarr[self.IMAX] = max(tarr[self.IMAX], ttime)
            tarr[self.ITOT] += ttime
            tarr[self.CTR] += 1

    def get_timings(self, labels=None):
        """Return timings"""
        keys = labels or self.timers.keys()
        return {k : self.timers[k][self.IDX] for k in keys}
