# Example: coupling Nalu-Wind and AMR-Wind

This directory contains the input file and the driver Python3 script that
demonstrates using the ExaWind simulation API to couple Nalu-Wind and AMR-Wind
for overset simulations. 

## Files

- [sphere.py](./sphere.py) -- Driver script demonstrating overset simulation using ExaWind hybrid solver API

- [sphere_amr_nalu.py](./sphere_amr_nalu.py) -- Driver script demonstrating coupling using low-level API
  
- [sphere-amr.inp](./sphere-amr.inp) -- Input file for AMR-Wind

- [sphere-nalu.yaml](./sphere-nalu.yaml) -- Input file for Nalu-Wind

## Running the case

Running this case requires the overset sphere
[mesh](https://github.com/Exawind/meshes/blob/master/oversetSphereTioga.g) from
the Nalu-Wind regression test suite.

```bash
# Copy files to execution directory
cd exawind-sim/examples/nalu-amr/
cp -R sphere-laminar-flow /scratch/${USER}/
cd /scratch/${USER}/sphere-laminar-flow

# Create symlink to mesh file
ln -s ${NALU_DIR}/reg_tests/mesh/oversetSphereTIOGA.g

# Execute python script
mpiexec -np 1 python3 sphere.py
```
