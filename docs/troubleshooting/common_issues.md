# Troubleshooting Guide

This guide helps you resolve common issues encountered when using the CHPC cluster.

## Connection Issues

### SSH Connection Problems

**Problem**: Cannot connect to the cluster

```bash
# Check your internet connection
ping google.com

# Check if the cluster is reachable
ping login.chpc.ac.za

# Test SSH connection with verbose output
ssh -v username@login.chpc.ac.za

# Check SSH key permissions
ls -la ~/.ssh/
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub

# Try connecting with specific SSH key
ssh -i ~/.ssh/id_rsa username@login.chpc.ac.za
```

**Solutions**:
- Verify your username and password
- Check if your SSH key is properly configured
- Ensure your account is active and not expired
- Contact CHPC support if the issue persists

### Slow Connection

**Problem**: Very slow SSH connection or file transfers

```bash
# Use compression for slow connections
ssh -C username@login.chpc.ac.za

# Use specific SSH options for slow networks
ssh -o Compression=yes -o TCPKeepAlive=yes username@login.chpc.ac.za

# For file transfers, use rsync with compression
rsync -avz --compress-level=9 local_file username@login.chpc.ac.za:/home/username/
```

## Job Submission Issues

### Job Stuck in Queue

**Problem**: Job remains in PENDING state for a long time

```bash
# Check job status
squeue -u $USER

# Check detailed job information
scontrol show job <job_id>

# Check partition availability
sinfo -s

# Check queue status
squeue

# Check your account limits
sacctmgr show user $USER
```

**Solutions**:
- Reduce resource requests (memory, time, CPUs)
- Try a different partition
- Check if you've exceeded your account limits
- Contact support if the issue persists

### Job Fails Immediately

**Problem**: Job fails with error messages

```bash
# Check job error log
cat job_name_*.err

# Check job output log
cat job_name_*.out

# Check job details
scontrol show job <job_id>

# Test job script syntax
bash -n job_script.sh
```

**Common Causes and Solutions**:

1. **Invalid SLURM directives**
   ```bash
   # Check SLURM syntax
   #SBATCH --mem=8G  # Correct
   #SBATCH --mem=8   # Incorrect (missing unit)
   ```

2. **Module not found**
   ```bash
   # Check available modules
   module avail
   
   # Load dependencies first
   module load gcc/9.3.0
   module load python/3.9.0
   ```

3. **File not found**
   ```bash
   # Check if input files exist
   ls -la input_file.txt
   
   # Use absolute paths in job scripts
   /home/$USER/data/input_file.txt
   ```

### Out of Memory Errors

**Problem**: Job fails with "Out of memory" or "Killed" messages

```bash
# Check memory usage in your code
# Add memory monitoring to your script
free -h
ps aux | grep $USER
```

**Solutions**:
- Increase memory request: `#SBATCH --mem=16G`
- Optimize your code to use less memory
- Use memory profiling tools
- Process data in smaller chunks

### Time Limit Exceeded

**Problem**: Job is killed due to time limit

```bash
# Check job time limit
scontrol show job <job_id> | grep TimeLimit

# Increase time limit in job script
#SBATCH --time=04:00:00  # 4 hours
```

**Solutions**:
- Increase time limit in job script
- Optimize your code for faster execution
- Split large jobs into smaller chunks
- Use more efficient algorithms

## Module and Software Issues

### Module Not Found

**Problem**: Cannot load required software modules

```bash
# Check available modules
module avail

# Search for specific module
module spider python

# Check module dependencies
module spider python/3.9.0

# Load dependencies first
module load gcc/9.3.0
module load python/3.9.0
```

**Solutions**:
- Check module name and version
- Load required dependencies first
- Contact CHPC support if module is missing
- Consider installing software locally if needed

### Software Version Conflicts

**Problem**: Software behaves differently than expected

```bash
# Check loaded modules
module list

# Check software versions
python --version
gcc --version

# Clear all modules and reload
module purge
module load python/3.9.0
```

**Solutions**:
- Use specific module versions
- Clear and reload modules
- Check module compatibility
- Use virtual environments for Python

## File and Storage Issues

### Out of Disk Space

**Problem**: Cannot write files due to disk space

```bash
# Check disk usage
df -h

# Check your quota
quota

# Find large files
du -sh /home/$USER/*
find /home/$USER -type f -size +100M -exec ls -lh {} \;

# Clean up temporary files
find /home/$USER -name "*.tmp" -delete
find /home/$USER -name "*.log" -mtime +7 -delete
```

**Solutions**:
- Remove unnecessary files
- Archive old results
- Use scratch directory for temporary files
- Request quota increase if needed

### Permission Denied

**Problem**: Cannot access or modify files

```bash
# Check file permissions
ls -la filename

# Check directory permissions
ls -ld directory

# Fix permissions
chmod 644 filename
chmod 755 directory

# Check ownership
ls -la filename
```

**Solutions**:
- Check file ownership and permissions
- Use appropriate file permissions
- Contact support for permission issues
- Use proper file paths

## Performance Issues

### Slow Job Execution

**Problem**: Jobs take longer than expected

```bash
# Check system load
top
htop

# Check job resource usage
scontrol show job <job_id>

# Profile your code
# Add timing information to your scripts
time ./my_program
```

**Solutions**:
- Optimize your code
- Use appropriate number of cores
- Check for I/O bottlenecks
- Use profiling tools

### Poor Parallel Performance

**Problem**: Parallel jobs don't scale well

```bash
# Check OpenMP settings
echo $OMP_NUM_THREADS

# Check MPI settings
echo $SLURM_NTASKS
echo $SLURM_NTASKS_PER_NODE
```

**Solutions**:
- Ensure proper parallelization
- Check load balancing
- Use appropriate scheduling
- Profile parallel performance

## Network and Transfer Issues

### File Transfer Failures

**Problem**: Cannot transfer files to/from cluster

```bash
# Check network connectivity
ping login.chpc.ac.za

# Test with different tools
scp file.txt username@login.chpc.ac.za:/home/username/
rsync -avz file.txt username@login.chpc.ac.za:/home/username/

# Use screen for long transfers
screen -S transfer
rsync -avz --progress large_directory/ username@login.chpc.ac.za:/home/username/
# Press Ctrl+A, then D to detach
```

**Solutions**:
- Use rsync instead of scp for large files
- Split large files before transfer
- Use screen or tmux for long transfers
- Check network stability

### Slow File Transfers

**Problem**: File transfers are very slow

```bash
# Use compression
rsync -avz --compress-level=9 data/ username@login.chpc.ac.za:/home/username/

# Use parallel transfer
parallel -j 4 rsync -avz {} username@login.chpc.ac.za:/home/username/ ::: file1 file2 file3

# Use appropriate block size
rsync -avz --block-size=1M large_file username@login.chpc.ac.za:/home/username/
```

## Environment Issues

### Shell Configuration Problems

**Problem**: Environment variables or aliases not working

```bash
# Check shell configuration
cat ~/.bashrc
cat ~/.bash_profile

# Reload configuration
source ~/.bashrc

# Check environment variables
env | grep VARIABLE_NAME

# Check PATH
echo $PATH
```

**Solutions**:
- Check shell configuration files
- Reload configuration
- Use absolute paths if needed
- Check for syntax errors

### Python Environment Issues

**Problem**: Python packages or versions not working

```bash
# Check Python version
python --version

# Check installed packages
pip list

# Create virtual environment
python -m venv my_env
source my_env/bin/activate

# Install packages
pip install package_name
```

**Solutions**:
- Use virtual environments
- Check Python version compatibility
- Install packages in user space
- Use conda if available

## Getting Help

### When to Contact Support

Contact CHPC support when:
- Connection issues persist after troubleshooting
- Job submission problems continue
- Software modules are missing
- Account or quota issues
- System-wide problems

### Information to Provide

When contacting support, provide:
- Your username
- Detailed error messages
- Job IDs (if applicable)
- Steps to reproduce the issue
- What you've already tried

### Support Contact

- **Email**: support@chpc.ac.za
- **Documentation**: [https://wiki.chpc.ac.za](https://wiki.chpc.ac.za)
- **User Forum**: [CHPC User Community](https://community.chpc.ac.za)

### Self-Help Resources

```bash
# Check system status
sinfo
squeue

# Check your account
sacctmgr show user $USER

# Check documentation
man sbatch
man squeue
man sinfo
```

## Prevention Tips

### Best Practices

1. **Test small jobs first**
   - Start with minimal resources
   - Verify job scripts work
   - Scale up gradually

2. **Monitor your jobs**
   - Check job status regularly
   - Monitor resource usage
   - Clean up completed jobs

3. **Keep organized**
   - Use consistent naming
   - Organize files properly
   - Document your workflows

4. **Backup important data**
   - Regular backups
   - Version control for scripts
   - Archive old results

5. **Stay informed**
   - Check system announcements
   - Read documentation updates
   - Join user community

---

**Next**: Check the [Resources](../resources/) section for additional help and documentation. 