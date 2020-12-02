# Example: coupling Nalu-Wind and AMR-Wind

This directory contains the input file and the driver Python3 script that
demonstrates using the ExaWind simulation API to couple Nalu-Wind and AMR-Wind
for overset simulations. 

## Files

- [ctv.py](./ctv.py) Driver script for overset simulation using ExaWind simulation environment

- [ctv_amr_nalu.py](./ctv_amr_nalu.py) -- Driver script demonstrating low-level API for coupling Nalu-Wind and AMR-Wind
  
- [ctv-amr.inp](./ctv-amr.inp) -- Input file for AMR-Wind

- [ctv-mesh.yaml](./ctv-mesh.yaml) -- Input file for Nalu-Wind mesh generation

- [ctv-nalu.yaml](./ctv-nalu.yaml) -- Input file for Nalu-Wind

## Running the case

Running this case requires generating an exodus mesh

```bash
# Copy files to execution directory
cd exawind-sim/examples/nalu-amr/
cp -R ctv_amr_nalu /scratch/${USER}/
cd /scratch/${USER}/ctv_amr_nalu

# generate mesh
mpiexec -np 1 /projects/hfm/shreyas/exawind/install/gcc/wind-utils/bin/abl_mesh -i ctv-mesh.yaml


# Execute python script
mpiexec -np 1 python3 ctv.py
```
