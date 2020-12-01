# -*- coding: utf-8 -*-

"""\
Parallel printer utility
-------------------------
"""

class ParallelPrinter:

    def __init__(self, comm, io_rank=0):
        """
        Args:
            comm: MPI communicator instance
        """
        self.comm = comm
        self.rank = comm.Get_rank()
        self.io_rank = io_rank

    def echo(self, *args, **kwargs):
        """Print on root process"""
        if self.rank == self.io_rank:
            flush = kwargs.pop("flush", True)
            print(*args, flush=flush, **kwargs)
