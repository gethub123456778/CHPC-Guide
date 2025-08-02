#!/bin/bash
#PBS -P MATS1366
#PBS -N QE_DOS
#PBS -l select=1:ncpus=24:mpiprocs=24
#PBS -l walltime=02:00:00
#PBS -q normal
#PBS -m be
#PBS -M your.email@example.com
#PBS -r n
#PBS -o qe_dos.out
#PBS -e qe_dos.err

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

# Run DOS calculation
mpirun -np 24 dos.x < dos_input.in > dos_output.out

echo "DOS calculation completed!" 