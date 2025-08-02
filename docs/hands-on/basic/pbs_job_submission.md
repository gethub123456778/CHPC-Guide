# Exercise: PBS Job Submission

## Objective

Learn how to create and submit PBS (Portable Batch System) job scripts on the CHPC cluster, with detailed explanations of each component.

## Prerequisites

- Completed [First Login Exercise](first_login.md)
- Basic knowledge of Linux command line
- Understanding of job scheduling concepts

## Step-by-Step Instructions

### Step 1: Understand PBS Job Script Structure

A PBS job script consists of two main parts:
1. **PBS directives** (lines starting with #PBS)
2. **Execution commands** (the actual job commands)

### Step 2: Create a PBS Job Script

```bash
# Connect to CHPC cluster
ssh username@login.chpc.ac.za

# Create exercise directory
mkdir -p ~/exercises/pbs_jobs
cd ~/exercises/pbs_jobs

# Create a PBS job script
cat > my_pbs_job.sh << 'EOF'
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
EOF
```

### Step 3: Detailed Explanation of PBS Directives

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
#PBS -M user@example.com             # Email address for notifications
```
- **`-q`**: Specifies the queue (normal, express, debug, etc.)
- **`-m`**: Email notification options:
  - `b`: when job begins
  - `e`: when job ends
  - `a`: when job aborts
  - `n`: no notifications
- **`-M`**: Email address for notifications

#### Job Control
```bash
#PBS -r n                           # Do not restart job if it fails
```
- **`-r`**: Restart policy (`y` for yes, `n` for no)

#### Output Files
```bash
#PBS -o /home/dsolomon/lustre/2D/MoSeTe_kpt  # Standard output file path
#PBS -e /home/dsolomon/lustre/2D/MoSeTe_kpt  # Standard error file path
```
- **`-o`**: Path for standard output (stdout)
- **`-e`**: Path for standard error (stderr)

### Step 4: Understanding Execution Commands

#### Module Management
```bash
module purge                        # Clear all loaded modules
module load chpc/qespresso/6.7/parallel_studio/2020u1  # Load Quantum ESPRESSO
```
- **`module purge`**: Removes all loaded modules to start with a clean environment
- **`module load`**: Loads specific software modules

#### System Configuration
```bash
ulimit -s unlimited                 # Set unlimited stack size
```
- **`ulimit -s unlimited`**: Prevents stack overflow errors in large calculations

#### Directory Management
```bash
pushd /home/fasefa/lustre/2D/MoSeTe_kpt  # Change to working directory
# ... job commands ...
popd                                # Return to original directory
```
- **`pushd`**: Changes directory and saves current location
- **`popd`**: Returns to the saved location

#### File System Optimization
```bash
lfs setstripe -d /home/dsolomon/lustre/2D/MoSeTe_kpt  # Remove existing stripe settings
lfs setstripe -c 12 ./                                # Set stripe count to 12 for parallel I/O
```
- **`lfs setstripe`**: Configures Lustre file system for optimal parallel I/O
- **`-c 12`**: Sets stripe count to 12 (number of OSTs to use)

#### Running the Application
```bash
mpirun -np 24 pw.x < MoSeTe-kpt3.in > MoSeTe-kpt3.out
```
- **`mpirun -np 24`**: Run MPI program with 24 processes
- **`pw.x`**: Quantum ESPRESSO plane-wave self-consistent field program
- **`< MoSeTe-kpt3.in`**: Input file (redirected as stdin)
- **`> MoSeTe-kpt3.out`**: Output file (redirected as stdout)

### Step 5: Submit Your Job

```bash
# Make the script executable
chmod +x my_pbs_job.sh

# Submit the job using qsub
qsub my_pbs_job.sh
```

**Expected Output:**
```
12345.login.chpc.ac.za
```
The number (12345) is your job ID.

### Step 6: Monitor Your Job

```bash
# Check job status
qstat -u $USER

# Check detailed job information
qstat -f <job_id>

# Check job history
qhist -u $USER

# Delete a job if needed
qdel <job_id>
```

### Step 7: Check Job Output

```bash
# Check if output files were created
ls -la /home/dsolomon/lustre/2D/MoSeTe_kpt/

# View job output
cat /home/dsolomon/lustre/2D/MoSeTe_kpt/MoSeTe-kpt3.out

# Check for errors
cat /home/dsolomon/lustre/2D/MoSeTe_kpt/*.err
```

## Common PBS Directives

### Resource Specifications
```bash
#PBS -l select=1:ncpus=8:mem=16gb    # 1 node, 8 CPUs, 16GB memory
#PBS -l select=4:ncpus=16:mpiprocs=16 # 4 nodes, 16 CPUs/MPI processes each
#PBS -l walltime=02:30:00            # 2 hours 30 minutes
#PBS -l mem=32gb                     # 32GB memory
```

### Queue Options
```bash
#PBS -q normal                       # Normal priority queue
#PBS -q express                      # Express queue (higher priority)
#PBS -q debug                        # Debug queue (short jobs)
#PBS -q gpu                          # GPU queue
```

### Email Notifications
```bash
#PBS -m bea                          # Notify on begin, end, abort
#PBS -m e                            # Notify only on end
#PBS -m n                            # No notifications
```

## Job Submission Commands

### Basic Submission
```bash
qsub job_script.sh                   # Submit job
qsub -N "my_job" job_script.sh       # Submit with custom name
qsub -q express job_script.sh        # Submit to specific queue
```

### Advanced Submission
```bash
qsub -W depend=afterok:12345 job_script.sh  # Submit after job 12345 completes
qsub -W depend=afterany:12345 job_script.sh # Submit after job 12345 finishes (success or fail)
qsub -W depend=afternotok:12345 job_script.sh # Submit only if job 12345 fails
```

## Troubleshooting

### Common Issues

1. **Job stuck in queue**
   ```bash
   # Check queue status
   qstat -Q
   
   # Check your job priority
   qstat -f <job_id> | grep Priority
   ```

2. **Job fails immediately**
   ```bash
   # Check error file
   cat job_name.err
   
   # Check PBS logs
   qstat -f <job_id>
   ```

3. **Module not found**
   ```bash
   # Check available modules
   module avail
   
   # Check module path
   module show module_name
   ```

4. **Permission denied**
   ```bash
   # Check file permissions
   ls -la job_script.sh
   
   # Make executable
   chmod +x job_script.sh
   ```

## Best Practices

1. **Always test with small jobs first**
2. **Use appropriate resource requests**
3. **Set reasonable walltime limits**
4. **Use descriptive job names**
5. **Monitor your jobs regularly**
6. **Clean up output files**
7. **Use email notifications for long jobs**

## Verification

Run these commands to verify your setup:

```bash
# Check if job was submitted
qstat -u $USER

# Check job output
ls -la /home/dsolomon/lustre/2D/MoSeTe_kpt/

# Verify job completed successfully
grep "JOB DONE" /home/dsolomon/lustre/2D/MoSeTe_kpt/MoSeTe-kpt3.out
```

## Further Reading

- [Basic Job Submission](job_submission.md)
- [Module System Usage](module_system.md)
- [File Management](file_management.md)

## Next Exercise

Once you've completed this exercise successfully, proceed to:
[Exercise: Advanced PBS Job Scripts](../advanced/advanced_pbs.md)

---

**Congratulations!** You've successfully learned how to create and submit PBS job scripts on the CHPC cluster. You can now run your computational jobs efficiently! 