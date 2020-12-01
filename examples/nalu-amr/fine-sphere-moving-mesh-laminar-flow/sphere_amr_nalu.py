# -*- coding: utf-8 -*-

"""\
AMR/Nalu integration
"""

import time
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
base.AMReX.initialize("sphere-amr.inp")
awind = AMRWind(tg)
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
nalu.prepare_for_time_integration()

ncomp = nalu.register_solution()
awind.register_solution()
tg.data_update_amr()
nalu.update_solution()
awind.update_solution()

awind.prepare_for_time_integration()

rank = comm.Get_rank()
comm.Barrier()

num_timesteps = 20 
for nt in range(num_timesteps):

    comm.Barrier()
    t0 = time.perf_counter()

    nalu.pre_advance_stage1()
    awind.pre_advance_stage1()

    comm.Barrier()
    t1 = time.perf_counter()

    nalu.pre_overset_conn_work()
    awind.pre_overset_conn_work()
    tg.profile()
    tg.perform_connectivity()
    tg.perform_connectivity_amr()
    nalu.post_overset_conn_work()
    awind.post_overset_conn_work()

    comm.Barrier()
    t2 = time.perf_counter()

    nalu.pre_advance_stage2()
    awind.pre_advance_stage2()

    comm.Barrier()
    t3 = time.perf_counter()

    nalu.register_solution()
    awind.register_solution()
    tg.data_update_amr()
    nalu.update_solution()
    awind.update_solution()
  
    comm.Barrier()
    t4 = time.perf_counter()

    nalu.advance_timestep()

    comm.Barrier()
    t5 = time.perf_counter()

    awind.advance_timestep()
 
    comm.Barrier()
    t6 = time.perf_counter()

    nalu.post_advance()
    awind.post_advance()
    comm.Barrier()
    t7 = time.perf_counter()

    if rank == 0:
        print(f"WallClockTime: {nt} Pre1: {t1-t0:.6f} TiogaConn: {t2-t1:.6f} Pre2: {t3-t2:.6f} Update: {t4-t3:.6f} nalu timestep: {t5-t4:.6f} amr-wind timestep: {t6-t5:.6f} Post: {t7-t6:.6f} Total: {t7-t0:.6f}", flush=True)

del awind
del nalu
