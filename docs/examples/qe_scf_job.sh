#!/bin/bash
#PBS -P MATS1366                    ! Project allocation
#PBS -N QE_SCF                      ! Job name
#PBS -l select=2:ncpus=24:mpiprocs=24  ! Request 2 nodes, 24 cores each
#PBS -l walltime=24:00:00           ! Maximum runtime
#PBS -q normal                      ! Queue name
#PBS -m be                          ! Email notifications (begin/end)
#PBS -M your.email@example.com      ! Email address
#PBS -r n                           ! Do not restart if job fails
#PBS -o qe_scf.out                 ! Standard output file
#PBS -e qe_scf.err                 ! Standard error file

# Load required modules
module purge
module load chpc/qespresso/7.0/parallel_studio/2020u1

# Set unlimited stack size for large calculations
ulimit -s unlimited

# Change to working directory
cd $PBS_O_WORKDIR

# Optimize file system performance for Lustre
lfs setstripe -d .                    ! Remove existing stripe settings
lfs setstripe -c 12 ./               ! Set stripe count to 12

# Run SCF calculation
mpirun -np 48 pw.x < scf_input.in > scf_output.out

echo "SCF calculation completed!" 