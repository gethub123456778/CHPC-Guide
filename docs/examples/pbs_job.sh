#!/bin/bash
#PBS -P MATS1366                    # Project allocation code
#PBS -N vc                          # Job name (vc = variable cell)
#PBS -l select=2:ncpus=24:mpiprocs=24  # Request 2 nodes, 24 CPUs per node, 24 MPI processes
#PBS -l walltime=24:00:00           # Maximum wall clock time (24 hours)
#PBS -q normal                      # Queue name (normal priority queue)
#PBS -m be                          # Email notifications: b=begin, e=end
#PBS -M user@example.com             # Email address for notifications
#PBS -r n                           # Do not restart job if it fails
#PBS -o /home/dsolomon/lustre/2D/MoSeTe_kpt  # Standard output file path
#PBS -e /home/dsolomon/lustre/2D/MoSeTe_kpt  # Standard error file path
#PBS

# Load required modules
module purge                        # Clear all loaded modules
#module load chpc/python/anaconda/3-2019.10  # Python module (commented out)
module load chpc/qespresso/6.7/parallel_studio/2020u1  # Quantum ESPRESSO module

# Set unlimited stack size for better performance
ulimit -s unlimited

# Change to working directory
pushd /home/fasefa/lustre/2D/MoSeTe_kpt

# Configure Lustre file system for optimal I/O performance
lfs setstripe -d /home/dsolomon/lustre/2D/MoSeTe_kpt  # Remove existing stripe settings
lfs setstripe -c 12 ./                                # Set stripe count to 12 for parallel I/O

# Run Quantum ESPRESSO calculation
mpirun -np 24 pw.x < MoSeTe-kpt3.in > MoSeTe-kpt3.out

# Return to original directory
popd 