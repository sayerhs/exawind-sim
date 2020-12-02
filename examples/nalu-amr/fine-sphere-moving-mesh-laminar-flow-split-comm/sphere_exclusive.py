# -*- coding: utf-8 -*-

"""\
Laminar flow past a sphere example

This script demonstrates an overset simulation using Nalu-Wind and AMR-Wind. It
uses a high-level API provided in exawind-sim.

In this example, the Nalu-Wind instance is running on a sub-communicator that
does not span all available processes. AMR-Wind is running on all processes
available in MPI_COMM_WORLD. All nalu-wind instances overlap with AMR-Wind
instances and are executed sequentially on the subcommunicator ranks.

The ``sphere_overlapping.py`` shows an example where Nalu-Wind and AMR-Wind
share the communicators.

"""

from mpi4py import MPI
import amrex
from exwsim import tioga
from exwsim.amr_wind.amr_wind_py import AMRWind
import exwsim.nalu_wind as nw
from exwsim.core.overset_sim import OversetSimulation

def create_subcomm(comm, num_ranks, start_rank=0):
    """Create a subcommunicator"""
    mpi_size = comm.Get_size()
    if (start_rank + num_ranks) > mpi_size:
        raise ValueError("Number of MPI ranks requested for Nalu-Wind greater than available ranks: MPI size = %d; Num ranks requested = "%(mpi_size, num_ranks))
    group = comm.Get_group()
    sub_group = group.Range_incl([(start_rank, num_ranks-1, 1),])
    subcomm = comm.Create(sub_group)
    return subcomm

def main():
    """Driver"""
    comm = MPI.COMM_WORLD
    rank = comm.Get_rank()
    mpi_size = comm.Get_size()
    num_nalu_ranks = 8
    if mpi_size < 2 * num_nalu_ranks:
        raise ValueError("Must run on at least %d MPI ranks"%(2 * num_nalu_ranks))
    num_amr_ranks = mpi_size - num_nalu_ranks

    nw.kokkos_initialize()
    sim = OversetSimulation(comm)

    sim.printer.echo("Initializing AMR-Wind on %d MPI ranks"%num_amr_ranks)
    amr_comm = create_subcomm(comm, num_amr_ranks, 0)
    if amr_comm != MPI.COMM_NULL:
        pamrex = amrex.PyAMReX(amr_comm, "sphere-amr.inp")
        awind = AMRWind(pamrex, sim.tioga)
        sim.register_solver(awind)

    sim.printer.echo("Initializing Nalu-Wind on %d MPI ranks"%num_nalu_ranks)
    nalu_comm = create_sub_comm(num_nalu_ranks, start_rank=num_amr_ranks)
    if nalu_comm != MPI.COMM_NULL:
        nalu = nw.NaluWind(nalu_comm, "sphere-nalu.yaml", sim.tioga)
        sim.register_solver(nalu)

    num_timesteps = 20

    sim.printer.echo("Initializing overset simulation")
    sim.initialize()
    sim.printer.echo("Initialization successful")
    sim.run_timesteps(num_timesteps)
    sim.summarize_timings()

if __name__ == "__main__":
    main()
