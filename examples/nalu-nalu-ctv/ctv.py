# -*- coding: utf-8 -*-

"""
Nalu-Wind overset simulation
"""

import time
from mpi4py import MPI
import exwsim.nalu_wind as nw
from exwsim import tioga

def main():
    """Run overset simulation"""
    num_timesteps = 16 
    num_non_lin_iters = 4 
    tg = tioga.get_instance()
    tg.set_communicator(MPI.COMM_WORLD)

    comm = MPI.COMM_WORLD
    rank = comm.Get_rank()
    size = comm.Get_size()
    split = 2 if size > 2 else 1
    color = rank // split
    scomm = comm.Split(color, rank)

    inpfile = "ctv-nalu-inner.yaml" if color == 1 else "ctv-nalu-outer.yaml"
    if scomm.Get_rank() == 0:
        print("Initializing Nalu-Wind with %s on %d ranks"%(
            inpfile, scomm.Get_size()),
              flush=True)
    nalu = nw.NaluWind(scomm, inpfile, tg)
    nalu.init_prolog(multi_solver_mode=True)
    nalu.pre_overset_conn_work()
    tg.profile()
    tg.perform_connectivity()
    nalu.post_overset_conn_work()
    nalu.init_epilog()
    nalu.prepare_for_time_integration()

    comm.Barrier()
    for nt in range(num_timesteps):
        tinit = time.perf_counter()
        nalu.pre_advance_stage1()
        nalu.pre_overset_conn_work()
        tg.profile()
        tg.perform_connectivity()
        nalu.post_overset_conn_work()
        nalu.pre_advance_stage2()
        comm.Barrier()
        tprep = time.perf_counter()

        for nli in range(num_non_lin_iters):
            ncomp = nalu.register_solution()
            tg.data_update(ncomp)
            nalu.update_solution()
            nalu.advance_timestep()
        comm.Barrier()
        tsolve = time.perf_counter()
        nalu.post_advance()
        tpost = time.perf_counter()
        comm.Barrier()
        if rank == 0:
            print(f"WallClockTime: {nt} Pre: {tprep-tinit:.6f} NLI: {tsolve-tprep:.6f} Post: {tpost-tsolve:.6f} Total: {tpost-tinit:.6f}", flush=True)

if __name__ == "__main__":
    comm = MPI.COMM_WORLD
    if comm.Get_size() < 2:
        raise RuntimeError("Nalu-Wind test requires at least 2 MPI ranks")
    nw.kokkos_initialize()
    main()
