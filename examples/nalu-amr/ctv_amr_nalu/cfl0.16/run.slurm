#!/bin/bash

#SBATCH --job-name=ctv
#SBATCH --nodes=2
#SBATCH --time=2:00:00
#SBATCH --output=out.%x_%j
#SBATCH --account=hfm

export OMP_NUM_THREADS=1  # Max hardware threads = 4
export OMP_PLACES=threads
export OMP_PROC_BIND=spread

echo "Job name       = $SLURM_JOB_NAME"
echo "Num. nodes     = $SLURM_JOB_NUM_NODES"
echo "Num. MPI Ranks = $mpi_ranks"
echo "Num. threads   = $OMP_NUM_THREADS"
echo "Working dir    = $PWD"

source /projects/hfm/shreyas/exawind/scripts/exawind-env-intel.sh

mpiexec -n 1 /nopt/nrel/ecom/exawind/exawind/install/intel/wind-utils/bin/abl_mesh -i ctv-mesh0.yaml
mpiexec -n 1 /nopt/nrel/ecom/exawind/exawind/install/intel/wind-utils/bin/abl_mesh -i ctv-mesh1.yaml
mpiexec -n 1 /nopt/nrel/ecom/exawind/exawind/install/intel/wind-utils/bin/abl_mesh -i ctv-mesh2.yaml
mpiexec -n 1 /nopt/nrel/ecom/exawind/exawind/install/intel/wind-utils/bin/abl_mesh -i ctv-mesh3.yaml

source /scratch/${USER}/exw-sim/scripts/exwsim-env-gcc.sh

mpiexec -n 1 python3 ctv.py 0 > log0
mpiexec -n 8 python3 ctv.py 1 > log1
mpiexec -n 36 python3 ctv.py 2 > log2
mpiexec -n 72 python3 ctv.py 3 > log3


