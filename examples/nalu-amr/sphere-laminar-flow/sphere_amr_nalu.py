# -*- coding: utf-8 -*-

"""\
AMR/Nalu integration
"""

from mpi4py import MPI
from amrex import base
from exwsim import tioga
from exwsim.amr_wind.amr_wind_py import AMRWind
import exwsim.nalu_wind as nw

comm = MPI.COMM_WORLD
nw.kokkos_initialize()
tg = tioga.get_instance()
tg.set_communicator(comm)

print("Initializing AMR-Wind", flush=True)
pamrex = amrex.PyAMReX(comm, "sphere-amr.inp")
awind = AMRWind(pamrex, tg)
awind.init_prolog()

print("Initializing Nalu-Wind", flush=True)
nalu = nw.NaluWind(comm, "sphere-nalu.yaml", tg)
nalu.init_prolog(multi_solver_mode=True)
nalu.pre_overset_conn_work()
awind.pre_overset_conn_work()
tg.profile()
tg.perform_connectivity()
tg.perform_connectivity_amr()
nalu.post_overset_conn_work()
awind.post_overset_conn_work()
nalu.init_epilog()

nalu.prepare_solver_prolog()
awind.prepare_solver_prolog()

ncomp = nalu.register_solution()
awind.register_solution()
tg.data_update_amr()
nalu.update_solution()
awind.update_solution()

nalu.prepare_solver_epilog()
awind.prepare_solver_epilog()

comm.Barrier()

num_timesteps = 10
for nt in range(num_timesteps):
    nalu.pre_advance_stage1()
    awind.pre_advance_stage1()

    nalu.pre_advance_stage2()
    awind.pre_advance_stage2()

    nalu.register_solution()
    awind.register_solution()
    tg.data_update_amr()
    nalu.update_solution()
    awind.update_solution()
    comm.Barrier()

    nalu.advance_timestep()
    awind.advance_timestep()
    comm.Barrier()

    nalu.post_advance()
    awind.post_advance()
    comm.Barrier()



del awind
del nalu
