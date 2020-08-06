# Example: coupling two Nalu-Wind instances

This directory contains the input files and the driver Python3 script that
demonstrates using the ExaWind simulation API to couple two Nalu-Wind instances
for performing overset simulation. The example recreates the flow past a
rotating cylinder that is part of the [Nalu-Wind regression test
suite](https://github.com/Exawind/nalu-wind/tree/master/reg_tests/test_files/oversetRotCylNGPHypre).

## Files

- [rotating_cylinder.py](./rotating_cylinder.py) -- Driver script that uses the ExaWind-Sim API to solve
  flow past rotating cylinder with two Nalu-Wind instances.
  
- [rotcyl-cyl.yaml](./rotcyl-cyl.yaml) -- Nalu-Wind input file for the instance solving the cylinder mesh

- [rotcyl-back.yaml](./rotcyl-back.yaml) -- Nalu-Wind input file for the instance solving the background mesh

## Running the case

Running this case requires the overset cylinder
[mesh](https://github.com/Exawind/meshes/blob/master/oversetCylinder.g)
distributed with the Nalu-Wind regression test suite. 

```bash
# Copy files to execution directory
cd exawind-sim/examples
cp -R nalu-nalu /scratch/${USER}/
cd /scratch/${USER}/nalu-nalu

# Create symlink to mesh file
ln -s ${NALU_DIR}/reg_tests/mesh/oversetCylinder.g

# Run on at least two MPI ranks
mpiexec -np 2 python rotating_cylinder.py
```
