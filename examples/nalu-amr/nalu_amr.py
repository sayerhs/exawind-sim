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
base.AMReX.initialize("amr_ovset.inp")
awind = AMRWind(tg)
awind.init_prolog()

print("Initializing Nalu-Wind", flush=True)
nalu = nw.NaluWind(comm, "sphere.yaml", tg)
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
awind.prepare_for_time_integration()

del awind
del nalu
