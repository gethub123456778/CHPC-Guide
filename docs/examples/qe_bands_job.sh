#!/bin/bash
#PBS -P MATS1366
#PBS -N QE_Bands
#PBS -l select=2:ncpus=24:mpiprocs=24
#PBS -l walltime=12:00:00
#PBS -q normal
#PBS -m be
#PBS -M your.email@example.com
#PBS -r n
#PBS -o qe_bands.out
#PBS -e qe_bands.err

# Load modules
module purge
module load chpc/qespresso/7.0/parallel_studio/2020u1

# Set unlimited stack size
ulimit -s unlimited

# Change to working directory
cd $PBS_O_WORKDIR

# Optimize file system
lfs setstripe -d .
lfs setstripe -c 12 ./

# Run band structure calculation
mpirun -np 48 pw.x < bands_input.in > bands_output.out

echo "Band structure calculation completed!" 