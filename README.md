# CHPC Cluster Usage Guide

A comprehensive guide for using the Centre for High Performance Computing (CHPC) cluster, covering everything from initial setup to advanced usage patterns.

## Table of Contents

- [Quick Start](#quick-start)
- [Getting Started](#getting-started)
  - [Account Setup](#account-setup)
  - [SSH Connection](#ssh-connection)
  - [Environment Setup](#environment-setup)
- [Basic Usage](#basic-usage)
  - [File Management](#file-management)
  - [Job Submission](#job-submission)
  - [Monitoring Jobs](#monitoring-jobs)
- [Advanced Topics](#advanced-topics)
  - [Parallel Computing](#parallel-computing)
  - [Data Management](#data-management)
  - [Performance Optimization](#performance-optimization)
- [Hands-on Exercises](#hands-on-exercises)
  - [Basic Operations](#basic-operations)
  - [Data Analysis](#data-analysis)
  - [Parallel Computing](#parallel-computing-1)
  - [Scientific Computing](#scientific-computing)
  - [Advanced Topics](#advanced-topics-1)
- [Examples](#examples)
  - [Basic Job Scripts](#basic-job-scripts)
  - [Parallel Job Scripts](#parallel-job-scripts)
  - [Data Processing Workflows](#data-processing-workflows)
- [Troubleshooting](#troubleshooting)
- [Resources](#resources)

## Quick Start

```bash
# Connect to CHPC cluster
ssh username@lengau.chpc.ac.za

# Check available modules
module avail

# Load required software
module load python/3.9.0

# Submit a job
sbatch my_job.sh

# Check job status
squeue -u $USER
```

## Getting Started

### Account Setup

1. **Apply for an account** at [CHPC User Portal](https://www.chpc.ac.za/index.php/accounts)
2. **Wait for approval** (typically 1-2 business days)
3. **Set up SSH keys** for secure access
4. **Configure your environment** with required software

### SSH Connection

```bash
# Basic connection
ssh username@login.chpc.ac.za

# With SSH key (recommended)
ssh -i ~/.ssh/id_rsa username@login.chpc.ac.za

# For file transfer
scp local_file.txt username@login.chpc.ac.za:/home/username/
```

### Environment Setup

```bash
# Check available modules
module avail

# Load commonly used modules
module load python/3.9.0
module load gcc/9.3.0
module load openmpi/4.0.5

# Save module configuration
module save my_env

# Restore saved configuration
module restore my_env
```

## Basic Usage

### File Management

```bash
# Check disk usage
df -h
du -sh /home/username/

# Transfer files
rsync -avz local_dir/ username@login.chpc.ac.za:/home/username/remote_dir/

# Archive large datasets
tar -czf dataset.tar.gz dataset/
```

### Job Submission

```bash
# Submit a job
sbatch job_script.sh

# Submit with specific partition
sbatch -p compute job_script.sh

# Submit with resource requirements
sbatch --mem=8G --cpus-per-task=4 job_script.sh

# Submit array job
sbatch --array=1-10 job_script.sh
```

### Monitoring Jobs

```bash
# Check job status
squeue -u $USER

# Check detailed job information
scontrol show job <job_id>

# Cancel a job
scancel <job_id>

# Check job history
sacct -u $USER --starttime=2024-01-01
```

## Advanced Topics

### Parallel Computing

```bash
# OpenMP example
export OMP_NUM_THREADS=4
./my_parallel_program

# MPI example
mpirun -np 8 ./my_mpi_program

# Hybrid OpenMP/MPI
mpirun -np 4 --map-by node:pe=4 ./hybrid_program
```

### Data Management

```bash
# Use scratch directory for temporary files
export TMPDIR=/scratch/$USER/tmp
mkdir -p $TMPDIR

# Archive old results
tar -czf results_$(date +%Y%m%d).tar.gz results/

# Clean up old files
find /home/$USER -name "*.tmp" -mtime +7 -delete
```

### Performance Optimization

```bash
# Profile your code
module load gprof
gprof ./my_program gmon.out

# Use optimized libraries
module load intel/2020.4
module load mkl/2020.4
```

## Hands-on Exercises

### Basic Operations
- [First Login and Environment Setup](docs/hands-on/basic/first_login.md)
- [File Management and Transfer](docs/hands-on/basic/file_management.md)
- [Module System Usage](docs/hands-on/basic/module_system.md)
- [Basic Job Submission](docs/hands-on/basic/job_submission.md)

### Data Analysis
- [Python Data Processing](docs/hands-on/data_analysis/python_analysis.md)
- [R Statistical Analysis](docs/hands-on/data_analysis/r_analysis.md)
- [Batch Processing Workflows](docs/hands-on/data_analysis/batch_processing.md)
- [Data Visualization](docs/hands-on/data_analysis/visualization.md)

### Parallel Computing
- [OpenMP Programming](docs/hands-on/parallel/openmp_basics.md)
- [MPI Programming](docs/hands-on/parallel/mpi_basics.md)
- [Hybrid OpenMP/MPI](docs/hands-on/parallel/hybrid_computing.md)
- [Performance Optimization](docs/hands-on/parallel/optimization.md)

### Scientific Computing
- [Quantum ESPRESSO Calculations](docs/hands-on/scientific/quantum_espresso.md)
- [Convergence Testing](docs/hands-on/scientific/convergence_testing.md)
- [Molecular Dynamics](docs/hands-on/scientific/molecular_dynamics.md)
- [Monte Carlo Simulations](docs/hands-on/scientific/monte_carlo.md)
- [Machine Learning](docs/hands-on/scientific/machine_learning.md)
- [Image Processing](docs/hands-on/scientific/image_processing.md)

### Advanced Topics
- [GPU Computing](docs/hands-on/advanced/gpu_computing.md)
- [Big Data Processing](docs/hands-on/advanced/big_data.md)
- [Workflow Automation](docs/hands-on/advanced/workflow_automation.md)
- [Performance Profiling](docs/hands-on/advanced/profiling.md)

## Examples

### Basic Job Scripts

#### Simple Python Job

```bash
#!/bin/bash
#SBATCH --job-name=python_job
#SBATCH --output=python_job_%j.out
#SBATCH --error=python_job_%j.err
#SBATCH --time=01:00:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=2

module load python/3.9.0

python my_script.py
```

#### R Job Script

```bash
#!/bin/bash
#SBATCH --job-name=r_job
#SBATCH --output=r_job_%j.out
#SBATCH --error=r_job_%j.err
#SBATCH --time=02:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=4

module load r/4.1.0

Rscript my_analysis.R
```

### Parallel Job Scripts

#### MPI Job

```bash
#!/bin/bash
#SBATCH --job-name=mpi_job
#SBATCH --output=mpi_job_%j.out
#SBATCH --error=mpi_job_%j.err
#SBATCH --time=04:00:00
#SBATCH --mem=16G
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=8

module load openmpi/4.0.5

mpirun -np 16 ./my_mpi_program
```

#### OpenMP Job

```bash
#!/bin/bash
#SBATCH --job-name=openmp_job
#SBATCH --output=openmp_job_%j.out
#SBATCH --error=openmp_job_%j.err
#SBATCH --time=02:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=8

module load gcc/9.3.0

export OMP_NUM_THREADS=8
./my_openmp_program
```

### Quantum ESPRESSO Job Scripts

#### SCF Calculation

```bash
#!/bin/bash
#PBS -P MATS1366
#PBS -N QE_SCF
#PBS -l select=2:ncpus=24:mpiprocs=24
#PBS -l walltime=24:00:00
#PBS -q normal
#PBS -m be
#PBS -M your.email@example.com

module purge
module load chpc/qespresso/7.0/parallel_studio/2020u1

ulimit -s unlimited
cd $PBS_O_WORKDIR

lfs setstripe -d .
lfs setstripe -c 12 ./

mpirun -np 48 pw.x < scf_input.in > scf_output.out
```

#### DOS Calculation

```bash
#!/bin/bash
#PBS -P MATS1366
#PBS -N QE_DOS
#PBS -l select=1:ncpus=24:mpiprocs=24
#PBS -l walltime=02:00:00
#PBS -q normal

module purge
module load chpc/qespresso/7.0/parallel_studio/2020u1

ulimit -s unlimited
cd $PBS_O_WORKDIR

lfs setstripe -d .
lfs setstripe -c 12 ./

mpirun -np 24 dos.x < dos_input.in > dos_output.out
```

#### Projected DOS Calculation

```bash
#!/bin/bash
#PBS -P MATS1366
#PBS -N QE_PDOS
#PBS -l select=1:ncpus=24:mpiprocs=24
#PBS -l walltime=04:00:00
#PBS -q normal

module purge
module load chpc/qespresso/7.0/parallel_studio/2020u1

ulimit -s unlimited
cd $PBS_O_WORKDIR

lfs setstripe -d .
lfs setstripe -c 12 ./

mpirun -np 24 projwfc.x < projwfc_input.in > projwfc_output.out
```

#### Band Structure Calculation

```bash
#!/bin/bash
#PBS -P MATS1366
#PBS -N QE_Bands
#PBS -l select=2:ncpus=24:mpiprocs=24
#PBS -l walltime=12:00:00
#PBS -q normal

module purge
module load chpc/qespresso/7.0/parallel_studio/2020u1

ulimit -s unlimited
cd $PBS_O_WORKDIR

lfs setstripe -d .
lfs setstripe -c 12 ./

mpirun -np 48 pw.x < bands_input.in > bands_output.out
```

#### Phonon Calculation

```bash
#!/bin/bash
#PBS -P MATS1366
#PBS -N QE_Phonons
#PBS -l select=2:ncpus=24:mpiprocs=24
#PBS -l walltime=48:00:00
#PBS -q normal

module purge
module load chpc/qespresso/7.0/parallel_studio/2020u1

ulimit -s unlimited
cd $PBS_O_WORKDIR

lfs setstripe -d .
lfs setstripe -c 12 ./

mpirun -np 48 ph.x < phonon_input.in > phonon_output.out
```

#### Spin-Orbit Coupling Calculation

```bash
#!/bin/bash
#PBS -P MATS1366
#PBS -N QE_SOC
#PBS -l select=2:ncpus=24:mpiprocs=24
#PBS -l walltime=24:00:00
#PBS -q normal

module purge
module load chpc/qespresso/7.0/parallel_studio/2020u1

ulimit -s unlimited
cd $PBS_O_WORKDIR

lfs setstripe -d .
lfs setstripe -c 12 ./

mpirun -np 48 pw.x < soc_input.in > soc_output.out
```

### Data Processing Workflows

#### Batch Processing

```bash
#!/bin/bash
#SBATCH --job-name=batch_process
#SBATCH --output=batch_%j.out
#SBATCH --error=batch_%j.err
#SBATCH --time=06:00:00
#SBATCH --mem=16G
#SBATCH --array=1-100

module load python/3.9.0

# Process file based on array index
input_file="data_${SLURM_ARRAY_TASK_ID}.txt"
output_file="results_${SLURM_ARRAY_TASK_ID}.txt"

python process_data.py $input_file $output_file
```

## Troubleshooting

### Common Issues

1. **Job stuck in queue**
   - Check partition availability: `sinfo`
   - Adjust resource requirements
   - Use different partition if available

2. **Out of memory errors**
   - Increase `--mem` parameter
   - Check memory usage in your code
   - Use memory profiling tools

3. **Module not found**
   - Check available modules: `module avail`
   - Load required dependencies first
   - Contact CHPC support if module is missing

4. **Slow file transfers**
   - Use `rsync` instead of `scp`
   - Compress files before transfer
   - Use `screen` or `tmux` for long transfers

### Getting Help

- **CHPC Documentation**: [https://wiki.chpc.ac.za](https://wiki.chpc.ac.za)
- **Support Email**: support@chpc.ac.za
- **User Forum**: [CHPC User Community](https://community.chpc.ac.za)

## Resources

### Useful Commands

```bash
# System information
sinfo                    # Show cluster status
squeue                   # Show job queue
scontrol show partition  # Show partition details

# User information
id                       # Show user info
groups                   # Show user groups
quota                    # Show disk quota

# Module management
module list              # Show loaded modules
module spider            # Search for modules
module show <module>     # Show module details
```

### Best Practices

1. **Always use job scripts** instead of running directly on login nodes
2. **Request appropriate resources** - don't over-request
3. **Use scratch directories** for temporary files
4. **Archive old results** to save space
5. **Test small jobs first** before submitting large ones
6. **Monitor your jobs** regularly
7. **Clean up after yourself** - remove temporary files

### Performance Tips

1. **Use appropriate number of cores** for your workload
2. **Optimize I/O operations** - minimize file access
3. **Use parallel libraries** when available
4. **Profile your code** to identify bottlenecks
5. **Consider using GPUs** for suitable workloads

---

**Note**: This guide is supportive of the CHPC clustore . For official documentation, please refer to the [CHPC Wiki](https://wiki.chpc.ac.za).

## Contributing

To contribute to this guide:

1. Fork this repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This documentation is provided under the MIT License. See LICENSE file for details. 