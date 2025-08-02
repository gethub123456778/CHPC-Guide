#!/bin/bash
#PBS -P MATS1366
#PBS -N QE_PDOS
#PBS -l select=1:ncpus=24:mpiprocs=24
#PBS -l walltime=04:00:00
#PBS -q normal
#PBS -m be
#PBS -M your.email@example.com
#PBS -r n
#PBS -o qe_pdos.out
#PBS -e qe_pdos.err

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

# Run projected DOS calculation
mpirun -np 24 projwfc.x < projwfc_input.in > projwfc_output.out

echo "Projected DOS calculation completed!" 