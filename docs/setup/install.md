# Installation and Setup Guide

This guide will walk you through the complete setup process for accessing and using the CHPC cluster.

## Prerequisites

Before you begin, ensure you have:

- A valid email address
- SSH client installed on your local machine
- Basic knowledge of Linux command line
- Research project that requires HPC resources

## Step 1: Account Application

### 1.1 Apply for CHPC Account

1. Visit the [CHPC User Portal](https://www.chpc.ac.za/index.php/accounts)
2. Click on "Apply for Account"
3. Fill out the application form with:
   - Personal information
   - Research project details
   - Justification for HPC resources
   - Expected resource requirements

### 1.2 Account Approval Process

- **Review Period**: 1-2 business days
- **Notification**: You'll receive an email with account details
- **Account Details**: Username, initial password, and access instructions

## Step 2: SSH Key Setup (Recommended)

### 2.1 Generate SSH Key Pair

```bash
# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# Press Enter to accept default location
# Enter a passphrase (recommended) or press Enter for no passphrase
```

### 2.2 Copy Public Key to CHPC

```bash
# Display your public key
cat ~/.ssh/id_rsa.pub

# Copy the output and add it to your CHPC account
# (You'll receive instructions in your account approval email)
```

### 2.3 Test SSH Connection

```bash
# Test connection with SSH key
ssh username@login.chpc.ac.za

# If successful, you should see the CHPC welcome message
```

## Step 3: Initial Login and Setup

### 3.1 First Login

```bash
# Connect to CHPC cluster
ssh username@login.chpc.ac.za

# Change your password on first login
passwd
```

### 3.2 Environment Setup

```bash
# Check your home directory
pwd
ls -la

# Check available modules
module avail

# Set up your shell environment
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=$HOME/lib:$LD_LIBRARY_PATH' >> ~/.bashrc
source ~/.bashrc
```

## Step 4: Software Environment

### 4.1 Module System

CHPC uses the Environment Modules system to manage software:

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

### 4.2 Common Software Modules

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
```

### 4.3 Custom Environment

```bash
# Save your module configuration
module save my_environment

# Restore saved configuration
module restore my_environment

# Create a startup script
cat > ~/setup_env.sh << 'EOF'
#!/bin/bash
module purge
module load python/3.9.0
module load gcc/9.3.0
module load openmpi/4.0.5
EOF

chmod +x ~/setup_env.sh
```

## Step 5: File Transfer Setup

### 5.1 Using SCP

```bash
# Upload a file
scp local_file.txt username@login.chpc.ac.za:/home/username/

# Upload a directory
scp -r local_directory/ username@login.chpc.ac.za:/home/username/

# Download a file
scp username@login.chpc.ac.za:/home/username/remote_file.txt ./
```

### 5.2 Using RSYNC (Recommended)

```bash
# Sync directory (more efficient for large files)
rsync -avz local_directory/ username@login.chpc.ac.za:/home/username/remote_directory/

# Sync with progress bar
rsync -avz --progress local_directory/ username@login.chpc.ac.za:/home/username/remote_directory/

# Exclude certain files
rsync -avz --exclude='*.tmp' --exclude='*.log' local_directory/ username@login.chpc.ac.za:/home/username/remote_directory/
```

### 5.3 Using SFTP

```bash
# Start SFTP session
sftp username@login.chpc.ac.za

# SFTP commands
put local_file.txt
get remote_file.txt
mput *.txt
mget *.txt
quit
```

## Step 6: Job Scheduler Setup

### 6.1 Understanding SLURM

CHPC uses SLURM (Simple Linux Utility for Resource Management) as the job scheduler:

```bash
# Check cluster status
sinfo

# Check available partitions
sinfo -s

# Check your account information
sacctmgr show user $USER
```

### 6.2 Creating Your First Job Script

```bash
# Create a simple job script
cat > my_first_job.sh << 'EOF'
#!/bin/bash
#SBATCH --job-name=test_job
#SBATCH --output=test_job_%j.out
#SBATCH --error=test_job_%j.err
#SBATCH --time=00:10:00
#SBATCH --mem=1G
#SBATCH --cpus-per-task=1

# Load required modules
module load python/3.9.0

# Your commands here
echo "Hello from CHPC cluster!"
python --version
hostname
date
EOF

# Make it executable
chmod +x my_first_job.sh
```

### 6.3 Submit and Monitor Your First Job

```bash
# Submit the job
sbatch my_first_job.sh

# Check job status
squeue -u $USER

# Check job output
cat test_job_*.out
```

## Step 7: Data Management Setup

### 7.1 Understanding Storage

```bash
# Check available storage
df -h

# Check your quota
quota

# Create organized directory structure
mkdir -p ~/projects
mkdir -p ~/data
mkdir -p ~/scripts
mkdir -p ~/results
mkdir -p ~/logs
```

### 7.2 Scratch Directory Setup

```bash
# Create scratch directory for temporary files
mkdir -p /scratch/$USER/tmp

# Set environment variable
echo 'export TMPDIR=/scratch/$USER/tmp' >> ~/.bashrc
source ~/.bashrc
```

## Step 8: Testing Your Setup

### 8.1 Basic Functionality Test

```bash
# Test module loading
module load python/3.9.0
python -c "print('Python is working!')"

# Test job submission
sbatch my_first_job.sh

# Test file transfer
echo "test" > test_file.txt
scp test_file.txt username@login.chpc.ac.za:/home/username/
```

### 8.2 Performance Test

```bash
# Create a simple performance test
cat > performance_test.sh << 'EOF'
#!/bin/bash
#SBATCH --job-name=perf_test
#SBATCH --output=perf_test_%j.out
#SBATCH --error=perf_test_%j.err
#SBATCH --time=00:05:00
#SBATCH --mem=2G
#SBATCH --cpus-per-task=4

module load python/3.9.0

# Simple performance test
python -c "
import time
import multiprocessing as mp

def worker(x):
    return x * x

if __name__ == '__main__':
    start_time = time.time()
    with mp.Pool(4) as pool:
        results = pool.map(worker, range(1000000))
    end_time = time.time()
    print(f'Computation time: {end_time - start_time:.2f} seconds')
    print(f'Number of cores: {mp.cpu_count()}')
"
EOF

chmod +x performance_test.sh
sbatch performance_test.sh
```

## Troubleshooting

### Common Setup Issues

1. **SSH Connection Failed**
   - Check your internet connection
   - Verify username and hostname
   - Ensure SSH key is properly configured

2. **Module Not Found**
   - Check available modules: `module avail`
   - Load dependencies first
   - Contact CHPC support

3. **Job Submission Failed**
   - Check SLURM syntax
   - Verify resource requests
   - Check partition availability

4. **File Transfer Issues**
   - Check disk space
   - Verify file permissions
   - Use rsync for large files

### Getting Help

- **CHPC Support**: support@chpc.ac.za
- **Documentation**: [https://wiki.chpc.ac.za](https://wiki.chpc.ac.za)
- **User Forum**: [CHPC User Community](https://community.chpc.ac.za)

## Next Steps

After completing this setup:

1. Read the [Basic Usage Guide](../usage/basic.md)
2. Explore [Advanced Topics](../advanced/parallel.md)
3. Check out [Example Scripts](../examples/)
4. Join the [CHPC User Community](https://community.chpc.ac.za)

---

**Note**: This setup guide assumes you have basic Linux command line knowledge. If you need help with Linux basics, consider taking an introductory Linux course or tutorial. 