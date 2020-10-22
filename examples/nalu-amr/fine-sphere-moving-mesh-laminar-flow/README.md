# Example: coupling Nalu-Wind and AMR-Wind

This directory contains the input file and the driver Python3 script that
demonstrates using the ExaWind simulation API to couple Nalu-Wind and AMR-Wind
for overset simulations. 

## Files

- [sphere_amr_nalu.py](./sphere_amr_nalu.py) -- Driver script demonstrating coupling Nalu-Wind
  and AMR-Wind
  
- [sphere-amr.inp](./sphere-amr.inp) -- Input file for AMR-Wind

- [sphere-nalu.yaml](./sphere-nalu.yaml) -- Input file for Nalu-Wind

- [static_box.txt](./static_box.txt) -- Input file for AMR-Wind static box refinement
## Running the case

Running this case requires the overset sphere
[mesh](/projects/hfm/ashesh/sphere_w_amr/sphere.exo) 

```bash
# Copy files to execution directory
cd exawind-sim/examples/nalu-amr/
cp -R fine-sphere-moving-mesh-laminar-flow /scratch/${USER}/
cd /scratch/${USER}/fine-sphere-moving-mesh-laminar-flow

# Create symlink to mesh file
ln -s /projects/hfm/ashesh/sphere_w_amr/sphere.exo

# Execute python script
mpiexec -np 8 python3 sphere_amr_nalu.py
```
