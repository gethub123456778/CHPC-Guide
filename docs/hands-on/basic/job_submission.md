# Exercise: Job Submission Systems

## Objective

Learn how to submit jobs using different job schedulers on the CHPC cluster: SLURM and PBS (Portable Batch System).

## Prerequisites

- Completed [First Login Exercise](first_login.md)
- Basic knowledge of Linux command line
- Understanding of job scheduling concepts

## Step-by-Step Instructions

### Step 1: Understanding Job Schedulers

The CHPC cluster supports multiple job scheduling systems:

1. **SLURM** (Simple Linux Utility for Resource Management)
2. **PBS** (Portable Batch System)

### Step 2: SLURM Job Submission

#### Create a SLURM Job Script

```bash
# Create a simple SLURM job script
cat > slurm_job.sh << 'EOF'
#!/bin/bash
#SBATCH --job-name=test_job
#SBATCH --output=test_job_%j.out
#SBATCH --error=test_job_%j.err
#SBATCH --time=01:00:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=4
#SBATCH --partition=compute

# Load required modules
module purge
module load python/3.9.0

# Your commands here
echo "Hello from SLURM job!"
python --version
hostname
date
EOF

# Make it executable
chmod +x slurm_job.sh
```

#### Submit SLURM Job

```bash
# Submit the job
sbatch slurm_job.sh

# Check job status
squeue -u $USER

# Check job details
scontrol show job <job_id>
```

### Step 3: PBS Job Submission

#### Create a PBS Job Script

```bash
# Create a PBS job script
cat > pbs_job.sh << 'EOF'
#!/bin/bash
#PBS -P MATS1366                    # Project allocation code
#PBS -N test_job                    # Job name
#PBS -l select=1:ncpus=4:mem=4gb   # Request 1 node, 4 CPUs, 4GB memory
#PBS -l walltime=01:00:00           # Maximum wall clock time (1 hour)
#PBS -q normal                      # Queue name
#PBS -m e                           # Email notification on end
#PBS -M user@example.com            # Email address
#PBS -o test_job.out                # Standard output file
#PBS -e test_job.err                # Standard error file

# Load required modules
module purge
module load python/3.9.0

# Your commands here
echo "Hello from PBS job!"
python --version
hostname
date
EOF

# Make it executable
chmod +x pbs_job.sh
```

#### Submit PBS Job

```bash
# Submit the job
qsub pbs_job.sh

# Check job status
qstat -u $USER

# Check job details
qstat -f <job_id>
```

### Step 4: Advanced PBS Job Script (Quantum ESPRESSO Example)

#### Create Advanced PBS Script

```bash
# Create an advanced PBS job script for Quantum ESPRESSO
cat > qe_pbs_job.sh << 'EOF'
#!/bin/bash
#PBS -P MATS1366                    # Project allocation code
#PBS -N vc                          # Job name (vc = variable cell)
#PBS -l select=2:ncpus=24:mpiprocs=24  # Request 2 nodes, 24 CPUs per node, 24 MPI processes
#PBS -l walltime=24:00:00           # Maximum wall clock time (24 hours)
#PBS -q normal                      # Queue name (normal priority queue)
#PBS -m be                          # Email notifications: b=begin, e=end
#PBS -M user@example.com            # Email address for notifications
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
EOF

# Make it executable
chmod +x qe_pbs_job.sh
```

### Step 5: Detailed Explanation of PBS Directives

#### Project and Job Information
```bash
#PBS -P MATS1366                    # Project allocation code
#PBS -N vc                          # Job name (vc = variable cell)
```
- **`-P`**: Specifies the project allocation code for billing/accounting
- **`-N`**: Sets a descriptive name for your job (appears in queue listings)

#### Resource Requirements
```bash
#PBS -l select=2:ncpus=24:mpiprocs=24  # Request 2 nodes, 24 CPUs per node, 24 MPI processes
#PBS -l walltime=24:00:00           # Maximum wall clock time (24 hours)
```
- **`select=2`**: Request 2 compute nodes
- **`ncpus=24`**: 24 CPUs per node
- **`mpiprocs=24`**: 24 MPI processes per node
- **`walltime`**: Maximum time the job can run (format: HH:MM:SS)

#### Queue and Notifications
```bash
#PBS -q normal                      # Queue name (normal priority queue)
#PBS -m be                          # Email notifications: b=begin, e=end
#PBS -M user@example.com            # Email address for notifications
```
- **`-q`**: Specifies the queue (normal, express, debug, etc.)
- **`-m`**: Email notification options:
  - `b`: when job begins
  - `e`: when job ends
  - `a`: when job aborts
  - `n`: no notifications
- **`-M`**: Email address for notifications

#### Job Control and Output
```bash
#PBS -r n                           # Do not restart job if it fails
#PBS -o /home/dsolomon/lustre/2D/MoSeTe_kpt  # Standard output file path
#PBS -e /home/dsolomon/lustre/2D/MoSeTe_kpt  # Standard error file path
```
- **`-r`**: Restart policy (`y` for yes, `n` for no)
- **`-o`**: Path for standard output (stdout)
- **`-e`**: Path for standard error (stderr)

### Step 6: Job Submission Commands

#### SLURM Commands
```bash
# Submit job
sbatch job_script.sh

# Check job status
squeue -u $USER

# Check job details
scontrol show job <job_id>

# Cancel job
scancel <job_id>

# Check job history
sacct -u $USER
```

#### PBS Commands
```bash
# Submit job
qsub job_script.sh

# Check job status
qstat -u $USER

# Check job details
qstat -f <job_id>

# Cancel job
qdel <job_id>

# Check job history
qhist -u $USER
```

### Step 7: Monitor and Manage Jobs

#### Check Queue Status
```bash
# SLURM
sinfo                    # Show cluster status
squeue                   # Show all jobs in queue

# PBS
qstat -Q                 # Show queue status
qstat                    # Show all jobs in queue
```

#### Monitor Job Progress
```bash
# Check job output in real-time
tail -f job_name.out

# Check for errors
tail -f job_name.err

# Check job resource usage
# SLURM
scontrol show job <job_id> | grep -E "(CPU|Memory|Node)"

# PBS
qstat -f <job_id> | grep -E "(resources_used|exec_host)"
```

### Step 8: Job Dependencies

#### SLURM Dependencies
```bash
# Submit job that depends on another job
sbatch --dependency=afterok:12345 job_script.sh

# Submit job that depends on any completion
sbatch --dependency=afterany:12345 job_script.sh

# Submit job only if previous job fails
sbatch --dependency=afternotok:12345 job_script.sh
```

#### PBS Dependencies
```bash
# Submit job that depends on another job
qsub -W depend=afterok:12345 job_script.sh

# Submit job that depends on any completion
qsub -W depend=afterany:12345 job_script.sh

# Submit job only if previous job fails
qsub -W depend=afternotok:12345 job_script.sh
```

## Comparison: SLURM vs PBS

| Feature | SLURM | PBS |
|---------|-------|-----|
| Job submission | `sbatch script.sh` | `qsub script.sh` |
| Job status | `squeue -u $USER` | `qstat -u $USER` |
| Job cancellation | `scancel <job_id>` | `qdel <job_id>` |
| Resource specification | `#SBATCH --mem=4G` | `#PBS -l mem=4gb` |
| Time limit | `#SBATCH --time=01:00:00` | `#PBS -l walltime=01:00:00` |
| Queue specification | `#SBATCH --partition=compute` | `#PBS -q normal` |
| Email notifications | `#SBATCH --mail-type=END` | `#PBS -m e` |

## Best Practices

### General Guidelines
1. **Always test with small jobs first**
2. **Use appropriate resource requests**
3. **Set reasonable time limits**
4. **Use descriptive job names**
5. **Monitor your jobs regularly**

### Resource Optimization
```bash
# Request only what you need
#SBATCH --mem=4G                    # Request 4GB memory
#SBATCH --cpus-per-task=4           # Request 4 CPUs
#SBATCH --time=01:00:00             # Request 1 hour

# PBS equivalent
#PBS -l mem=4gb                     # Request 4GB memory
#PBS -l ncpus=4                     # Request 4 CPUs
#PBS -l walltime=01:00:00           # Request 1 hour
```

### File Management
```bash
# Use scratch directories for temporary files
export TMPDIR=/scratch/$USER/tmp
mkdir -p $TMPDIR

# Clean up after job completion
rm -rf $TMPDIR
```

## Troubleshooting

### Common Issues

1. **Job stuck in queue**
   ```bash
   # Check queue status
   sinfo                    # SLURM
   qstat -Q                 # PBS
   
   # Check your job priority
   squeue -u $USER -o "%.10i %.9P %.20j %.8u %.2t %.10M %.6D %R"  # SLURM
   qstat -u $USER           # PBS
   ```

2. **Job fails immediately**
   ```bash
   # Check error files
   cat job_name.err
   
   # Check job logs
   scontrol show job <job_id>  # SLURM
   qstat -f <job_id>           # PBS
   ```

3. **Out of memory errors**
   ```bash
   # Increase memory request
   #SBATCH --mem=8G              # SLURM
   #PBS -l mem=8gb               # PBS
   ```

## Verification

Run these commands to verify your setup:

```bash
# Test SLURM submission
sbatch slurm_job.sh
squeue -u $USER

# Test PBS submission
qsub pbs_job.sh
qstat -u $USER

# Check job outputs
ls -la *.out *.err
```

## Further Reading

- [PBS Job Submission](pbs_job_submission.md)
- [Module System Usage](module_system.md)
- [File Management](file_management.md)

## Next Exercise

Once you've completed this exercise successfully, proceed to:
[Exercise: Advanced Job Scripts](../advanced/advanced_job_scripts.md)

---

**Congratulations!** You've successfully learned how to submit jobs using both SLURM and PBS systems on the CHPC cluster. You can now choose the appropriate system for your computational needs! 