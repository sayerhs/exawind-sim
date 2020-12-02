# Example: coupling Nalu-Wind and AMR-Wind

This directory contains the input file and the driver Python3 script that
demonstrates using the ExaWind simulation API to couple Nalu-Wind and AMR-Wind
for overset simulations. 

## Files

- [sphere_exclusive.py](./sphere_exclusive.py) -- Driver script demonstrating
  hybrid-overset simulation using sub-communicators. In this example, Nalu-Wind
  and AMR-Wind run on MPI ranks that are mutually exclusive. The
  subcommunicators are created such that Nalu-Wind will run on the last 8 MPI
  ranks and AMR-Wind will run on the remaining ranks starting from rank 0.
  
- [sphere_overlapping.py](./sphere_overlapping.py) -- Driver script
  demonstrating hybrid-overset simulation where Nalu-Wind and AMR-Wind are
  running on different number of MPI ranks. The example is setup such that
  Nalu-Wind will run on the first 8 ranks while AMR-Wind runs on all available
  ranks. On the first 8 ranks, Nalu-Wind and AMR-Wind will run sequentially
  within a time stepping loop.

- [sphere_amr_nalu.py](./sphere_amr_nalu.py) -- Driver script demonstrating
  coupling Nalu-Wind and AMR-Wind using low-level solver API
  
- [sphere-amr.inp](./sphere-amr.inp) -- Input file for AMR-Wind

- [sphere-nalu.yaml](./sphere-nalu.yaml) -- Input file for Nalu-Wind

- [static_box.txt](./static_box.txt) -- Input file for AMR-Wind static box refinement

## Running the case

Running this case requires the overset sphere: /projects/hfm/ashesh/sphere_w_amr/sphere.exo 

```bash
# Copy files to execution directory
cd exawind-sim/examples/nalu-amr/
cp -R fine-sphere-moving-mesh-laminar-flow-split-comm /scratch/${USER}/
cd /scratch/${USER}/fine-sphere-moving-mesh-laminar-flow-split-comm

# Create symlink to mesh file
ln -s /projects/hfm/ashesh/sphere_w_amr/sphere.exo

# Execute the overlapping example
mpiexec -np 72 python3 sphere_overlapping.py

# Execute the non-overlapping example
mpiexec -np 80 python3 sphere_exclusive.python3

# Execute the low-level API example
mpiexec -np 72 python3 sphere_amr_nalu.py
```

