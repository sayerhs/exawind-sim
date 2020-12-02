# -*- coding: utf-8 -*-

"""
Laminar flow past a sphere example

This script demonstrates an overset simulation using Nalu-Wind and AMR-Wind. It
uses a high-level API provided in exawind-sim

"""

from mpi4py import MPI
import amrex
from exwsim import tioga
from exwsim.amr_wind.amr_wind_py import AMRWind
import exwsim.nalu_wind as nw
from exwsim.core.overset_sim import OversetSimulation

def main():
    """Driver"""
    comm = MPI.COMM_WORLD
    rank = comm.Get_rank()

    nw.kokkos_initialize()
    sim = OversetSimulation(comm)

    sim.printer.echo("Initializing AMR-Wind")
    pamrex = amrex.PyAMReX(comm, "sphere-amr.inp")
    awind = AMRWind(pamrex, sim.tioga)
    sim.register_solver(awind)

    sim.printer.echo("Initializing Nalu-Wind")
    nalu = nw.NaluWind(comm, "sphere-nalu.yaml", sim.tioga)
    sim.register_solver(nalu)

    num_timesteps = 20

    sim.printer.echo("Initializing overset simulation")
    sim.initialize()
    sim.printer.echo("Initialization successful")
    sim.run_timesteps(num_timesteps)
    sim.summarize_timings()

if __name__ == "__main__":
    main()
