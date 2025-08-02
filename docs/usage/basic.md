# Basic Usage Guide

This guide covers the fundamental operations you'll perform daily on the CHPC cluster.

## Connecting to the Cluster

### SSH Connection

```bash
# Basic connection
ssh username@login.chpc.ac.za

# With specific SSH key
ssh -i ~/.ssh/id_rsa username@login.chpc.ac.za

# With verbose output (for debugging)
ssh -v username@login.chpc.ac.za
```

### Connection Tips

- Use SSH keys instead of passwords for better security
- Keep your SSH key secure and don't share it
- Use `screen` or `tmux` for long-running sessions

## File Management

### Basic Commands

```bash
# List files and directories
ls -la

# Change directory
cd /path/to/directory

# Create directory
mkdir new_directory

# Copy files
cp source_file destination_file
cp -r source_directory destination_directory

# Move/rename files
mv old_name new_name

# Remove files
rm filename
rm -r directory_name

# View file contents
cat filename
less filename
head -n 10 filename
tail -n 10 filename
```

### File Transfer

```bash
# Upload file from local machine
scp local_file.txt username@login.chpc.ac.za:/home/username/

# Download file to local machine
scp username@login.chpc.ac.za:/home/username/remote_file.txt ./

# Sync directory (recommended for large files)
rsync -avz local_directory/ username@login.chpc.ac.za:/home/username/remote_directory/

# Use SFTP for interactive file management
sftp username@login.chpc.ac.za
```

### Storage Management

```bash
# Check disk usage
df -h

# Check your quota
quota

# Check directory size
du -sh directory_name

# Find large files
find /home/username -type f -size +100M

# Archive files to save space
tar -czf archive.tar.gz directory_name/
```

## Job Submission

### Creating Job Scripts

Job scripts are bash scripts with SLURM directives at the top:

```bash
#!/bin/bash
#SBATCH --job-name=my_job
#SBATCH --output=my_job_%j.out
#SBATCH --error=my_job_%j.err
#SBATCH --time=01:00:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=2

# Your commands here
echo "Starting job..."
python my_script.py
echo "Job completed!"
```

### Common SLURM Directives

```bash
#SBATCH --job-name=job_name          # Job name
#SBATCH --output=output_%j.out       # Output file (%j = job ID)
#SBATCH --error=error_%j.err         # Error file
#SBATCH --time=HH:MM:SS              # Time limit
#SBATCH --mem=4G                     # Memory limit
#SBATCH --cpus-per-task=4            # CPUs per task
#SBATCH --nodes=2                    # Number of nodes
#SBATCH --ntasks-per-node=8          # Tasks per node
#SBATCH --partition=compute          # Partition name
#SBATCH --array=1-10                 # Array job
#SBATCH --mail-type=ALL              # Email notifications
#SBATCH --mail-user=user@email.com   # Email address
```

### Submitting Jobs

```bash
# Submit a job script
sbatch job_script.sh

# Submit with command line options
sbatch --mem=8G --time=02:00:00 job_script.sh

# Submit to specific partition
sbatch -p compute job_script.sh

# Submit array job
sbatch --array=1-100 job_script.sh
```

### Monitoring Jobs

```bash
# Check job status
squeue -u $USER

# Check all jobs in queue
squeue

# Check detailed job information
scontrol show job <job_id>

# Check job history
sacct -u $USER --starttime=2024-01-01

# Cancel a job
scancel <job_id>

# Cancel all your jobs
scancel -u $USER
```

## Module System

### Loading Software

```bash
# List available modules
module avail

# Search for specific software
module spider python

# Load a module
module load python/3.9.0

# List loaded modules
module list

# Unload a module
module unload python/3.9.0

# Clear all modules
module purge
```

### Common Modules

```bash
# Programming languages
module load python/3.9.0
module load r/4.1.0
module load julia/1.6.0

# Compilers
module load gcc/9.3.0
module load intel/2020.4

# MPI libraries
module load openmpi/4.0.5
module load mpich/3.3.2

# Scientific libraries
module load mkl/2020.4
module load fftw/3.3.8
module load hdf5/1.12.0
```

### Module Management

```bash
# Save current module configuration
module save my_environment

# Restore saved configuration
module restore my_environment

# Show module details
module show python/3.9.0

# Check module dependencies
module spider python/3.9.0
```

## Working with Data

### Data Organization

```bash
# Create organized directory structure
mkdir -p ~/projects
mkdir -p ~/data
mkdir -p ~/scripts
mkdir -p ~/results
mkdir -p ~/logs

# Create project-specific directories
mkdir -p ~/projects/my_project/{data,scripts,results,logs}
```

### Data Transfer Best Practices

```bash
# Compress large files before transfer
tar -czf large_dataset.tar.gz large_dataset/

# Use rsync for large transfers
rsync -avz --progress local_data/ username@login.chpc.ac.za:/home/username/data/

# Resume interrupted transfers
rsync -avz --partial --progress local_data/ username@login.chpc.ac.za:/home/username/data/

# Exclude unnecessary files
rsync -avz --exclude='*.tmp' --exclude='*.log' local_data/ username@login.chpc.ac.za:/home/username/data/
```

### Using Scratch Space

```bash
# Create scratch directory
mkdir -p /scratch/$USER/tmp

# Set environment variable
export TMPDIR=/scratch/$USER/tmp

# Use in job scripts
#SBATCH --tmp=10G  # Request temporary storage
```

## Environment Setup

### Shell Configuration

```bash
# Edit bash configuration
nano ~/.bashrc

# Add custom aliases
alias ll='ls -la'
alias squeue='squeue -u $USER'
alias sinfo='sinfo -s'

# Add custom functions
function job_status() {
    squeue -u $USER
    echo "--- Job History ---"
    sacct -u $USER --starttime=$(date -d '7 days ago' +%Y-%m-%d)
}

# Source configuration
source ~/.bashrc
```

### Python Environment

```bash
# Load Python module
module load python/3.9.0

# Create virtual environment
python -m venv my_env

# Activate virtual environment
source my_env/bin/activate

# Install packages
pip install numpy pandas matplotlib

# Deactivate virtual environment
deactivate
```

### R Environment

```bash
# Load R module
module load r/4.1.0

# Start R session
R

# Install packages in R
install.packages("ggplot2")
install.packages("dplyr")

# Exit R
q()
```

## Common Workflows

### Daily Workflow

```bash
# 1. Connect to cluster
ssh username@login.chpc.ac.za

# 2. Check job status
squeue -u $USER

# 3. Check results
ls -la ~/results/

# 4. Submit new jobs
sbatch new_job.sh

# 5. Monitor progress
tail -f job_output.out
```

### Data Analysis Workflow

```bash
# 1. Transfer data
rsync -avz local_data/ username@login.chpc.ac.za:/home/username/data/

# 2. Create analysis script
nano analysis_script.py

# 3. Create job script
nano analysis_job.sh

# 4. Submit job
sbatch analysis_job.sh

# 5. Monitor progress
squeue -u $USER

# 6. Download results
scp username@login.chpc.ac.za:/home/username/results/ ./
```

## Troubleshooting

### Common Issues

1. **Job stuck in queue**
   ```bash
   # Check partition availability
   sinfo
   
   # Check queue status
   squeue
   
   # Adjust resource requirements
   sbatch --mem=4G --time=01:00:00 job_script.sh
   ```

2. **Out of memory errors**
   ```bash
   # Increase memory request
   #SBATCH --mem=8G
   
   # Check memory usage in your code
   # Use memory profiling tools
   ```

3. **Module not found**
   ```bash
   # Check available modules
   module avail
   
   # Search for specific module
   module spider module_name
   
   # Load dependencies first
   module load dependency_module
   module load target_module
   ```

4. **File transfer issues**
   ```bash
   # Check disk space
   df -h
   
   # Check file permissions
   ls -la filename
   
   # Use rsync instead of scp
   rsync -avz local_file username@login.chpc.ac.za:/home/username/
   ```

### Getting Help

- **Check job logs**: `cat job_name_*.err`
- **Check system status**: `sinfo`
- **Contact support**: support@chpc.ac.za
- **Check documentation**: [https://wiki.chpc.ac.za](https://wiki.chpc.ac.za)

## Best Practices

1. **Always use job scripts** instead of running directly on login nodes
2. **Request appropriate resources** - don't over-request
3. **Use descriptive job names** and output files
4. **Monitor your jobs** regularly
5. **Clean up temporary files** after jobs complete
6. **Use scratch space** for temporary files
7. **Archive old results** to save space
8. **Test small jobs first** before submitting large ones

---

**Next**: Learn about [Advanced Topics](../advanced/parallel.md) for more complex workflows. 