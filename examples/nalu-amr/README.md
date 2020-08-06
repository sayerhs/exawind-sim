# Example: coupling Nalu-Wind and AMR-Wind

This directory contains the input file and the driver Python3 script that
demonstrates using the ExaWind simulation API to couple Nalu-Wind and AMR-Wind
for overset simulations. 

## Files

- [nalu_amr.py](./nalu_amr.py) -- Driver script demonstrating coupling Nalu-Wind
  and AMR-Wind
  
- [amr_ovset.inp](./amr_ovset.inp) -- Input file for AMR-Wind

- [sphere.yaml](./sphere.yaml) -- Input file for Nalu-Wind

## Running the case

Running this case requires the overset sphere
[mesh](https://github.com/Exawind/meshes/blob/master/oversetSphereTioga.g) from
the Nalu-Wind regression test suite.

```bash
# Copy files to execution directory
cd exawind-sim/examples
cp -R nalu-amr /scratch/${USER}/
cd /scratch/${USER}/nalu-amr

# Create symlink to mesh file
ln -s ${NALU_DIR}/reg_tests/mesh/oversetSphereTIOGA.g

# Execute python script
mpiexec -np 1 python nalu_amr.py
```
