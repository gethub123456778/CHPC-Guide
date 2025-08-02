# Data Management Guide

This guide covers efficient data management strategies for the CHPC cluster, including storage systems, data transfer, and best practices.

## Storage Systems

### Available Storage

The CHPC cluster provides several storage options:

```bash
# Home directory (persistent, limited quota)
/home/$USER

# Scratch directory (temporary, larger space)
/scratch/$USER

# Project storage (shared, persistent)
/projects/project_name

# Archive storage (long-term, tape backup)
/archive/$USER
```

### Storage Quotas and Limits

```bash
# Check your quota
quota

# Check disk usage
df -h

# Check directory sizes
du -sh /home/$USER/*
du -sh /scratch/$USER/*

# Find large files
find /home/$USER -type f -size +100M -exec ls -lh {} \;
```

### Storage Best Practices

1. **Use Appropriate Storage**
   - Home: Small files, scripts, configuration
   - Scratch: Large datasets, temporary files
   - Projects: Shared data, collaborative work
   - Archive: Long-term storage, backups

2. **Regular Cleanup**
   ```bash
   # Remove old temporary files
   find /scratch/$USER -name "*.tmp" -mtime +7 -delete
   
   # Remove old log files
   find /home/$USER -name "*.log" -mtime +30 -delete
   
   # Archive old results
   tar -czf old_results_$(date +%Y%m%d).tar.gz old_results/
   ```

## Data Transfer

### Local to Cluster Transfer

```bash
# Single file transfer
scp local_file.txt username@login.chpc.ac.za:/home/username/

# Directory transfer
scp -r local_directory/ username@login.chpc.ac.za:/home/username/

# Compressed transfer
tar -czf data.tar.gz data_directory/
scp data.tar.gz username@login.chpc.ac.za:/home/username/
ssh username@login.chpc.ac.za "cd /home/username && tar -xzf data.tar.gz"
```

### Using RSYNC (Recommended)

```bash
# Basic sync
rsync -avz local_directory/ username@login.chpc.ac.za:/home/username/remote_directory/

# Sync with progress
rsync -avz --progress local_directory/ username@login.chpc.ac.za:/home/username/remote_directory/

# Resume interrupted transfer
rsync -avz --partial --progress local_directory/ username@login.chpc.ac.za:/home/username/remote_directory/

# Exclude certain files
rsync -avz --exclude='*.tmp' --exclude='*.log' local_directory/ username@login.chpc.ac.za:/home/username/remote_directory/

# Dry run (see what would be transferred)
rsync -avz --dry-run local_directory/ username@login.chpc.ac.za:/home/username/remote_directory/
```

### Cluster to Local Transfer

```bash
# Download single file
scp username@login.chpc.ac.za:/home/username/result.txt ./

# Download directory
scp -r username@login.chpc.ac.za:/home/username/results/ ./

# Download with rsync
rsync -avz username@login.chpc.ac.za:/home/username/results/ local_results/
```

### Large File Transfer

```bash
# Split large files
split -b 1G large_file.dat large_file.part

# Transfer parts
for part in large_file.part*; do
    scp $part username@login.chpc.ac.za:/home/username/
done

# Reassemble on cluster
cat large_file.part* > large_file.dat

# Use screen for long transfers
screen -S transfer
rsync -avz --progress large_directory/ username@login.chpc.ac.za:/home/username/
# Press Ctrl+A, then D to detach
# Use 'screen -r transfer' to reattach
```

## Data Organization

### Directory Structure

```bash
# Create organized directory structure
mkdir -p ~/projects
mkdir -p ~/data/{raw,processed,results}
mkdir -p ~/scripts
mkdir -p ~/logs
mkdir -p ~/backups

# Project-specific structure
mkdir -p ~/projects/my_project/{data,scripts,results,logs,docs}
mkdir -p ~/projects/my_project/data/{raw,processed,intermediate}
```

### File Naming Conventions

```bash
# Use descriptive names with dates
results_2024_01_15_v1.csv
data_processed_2024_01_15_14_30.txt

# Use consistent naming patterns
experiment_001_condition_A_replicate_1.dat
simulation_001_timestep_1000.out

# Avoid spaces and special characters
# Good: experiment_001_results.csv
# Bad: experiment 001 results.csv
```

### Data Versioning

```bash
# Create versioned backups
cp results.csv results_v1.0.csv
cp results.csv results_v1.1.csv

# Use timestamps
cp results.csv results_$(date +%Y%m%d_%H%M%S).csv

# Create symbolic links for current version
ln -sf results_v1.1.csv results_current.csv
```

## Data Processing Workflows

### Batch Processing

```bash
#!/bin/bash
#SBATCH --job-name=data_processing
#SBATCH --output=processing_%j.out
#SBATCH --error=processing_%j.err
#SBATCH --time=04:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=8
#SBATCH --partition=compute

# Set up environment
module load python/3.9.0

# Create scratch directory
export TMPDIR=/scratch/$USER/tmp
mkdir -p $TMPDIR

# Process data
python process_data.py --input /home/$USER/data/raw/ \
                      --output /home/$USER/data/processed/ \
                      --temp-dir $TMPDIR

# Clean up
rm -rf $TMPDIR
```

### Data Pipeline

```bash
#!/bin/bash
#SBATCH --job-name=data_pipeline
#SBATCH --output=pipeline_%j.out
#SBATCH --error=pipeline_%j.err
#SBATCH --time=08:00:00
#SBATCH --mem=32G
#SBATCH --cpus-per-task=16
#SBATCH --partition=compute

# Step 1: Data preprocessing
python preprocess.py --input raw_data/ --output preprocessed/

# Step 2: Feature extraction
python extract_features.py --input preprocessed/ --output features/

# Step 3: Model training
python train_model.py --input features/ --output models/

# Step 4: Evaluation
python evaluate.py --input features/ --model models/ --output results/

# Step 5: Cleanup
rm -rf preprocessed/ features/
```

## Data Compression and Archiving

### Compression Tools

```bash
# Compress single files
gzip large_file.txt
bzip2 large_file.txt
xz large_file.txt

# Compress directories
tar -czf archive.tar.gz directory/
tar -cjf archive.tar.bz2 directory/
tar -cJf archive.tar.xz directory/

# Extract archives
tar -xzf archive.tar.gz
tar -xjf archive.tar.bz2
tar -xJf archive.tar.xz
```

### Efficient Compression

```bash
# Use parallel compression for large files
pigz -p 8 -c large_file.txt > large_file.txt.gz

# Use parallel bzip2
pbzip2 -p8 large_file.txt

# Use parallel xz
pxz -T8 large_file.txt
```

### Archive Management

```bash
# Create dated archives
tar -czf backup_$(date +%Y%m%d).tar.gz important_data/

# Create incremental backups
tar -czf backup_$(date +%Y%m%d_%H%M%S).tar.gz --newer-mtime="1 day ago" data/

# List archive contents
tar -tzf archive.tar.gz

# Extract specific files
tar -xzf archive.tar.gz specific_file.txt
```

## Data Validation and Integrity

### Checksums

```bash
# Generate checksums
md5sum large_file.dat > large_file.dat.md5
sha256sum large_file.dat > large_file.dat.sha256

# Verify checksums
md5sum -c large_file.dat.md5
sha256sum -c large_file.dat.sha256

# Verify multiple files
find . -name "*.dat" -exec md5sum {} \; > checksums.md5
md5sum -c checksums.md5
```

### Data Validation Scripts

```python
#!/usr/bin/env python3
import hashlib
import os
import sys

def calculate_checksum(filename):
    """Calculate SHA256 checksum of a file"""
    sha256_hash = hashlib.sha256()
    with open(filename, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            sha256_hash.update(chunk)
    return sha256_hash.hexdigest()

def validate_data(data_dir):
    """Validate all files in a directory"""
    checksums = {}
    
    # Read existing checksums
    checksum_file = os.path.join(data_dir, "checksums.txt")
    if os.path.exists(checksum_file):
        with open(checksum_file, 'r') as f:
            for line in f:
                checksum, filename = line.strip().split('  ')
                checksums[filename] = checksum
    
    # Validate files
    for root, dirs, files in os.walk(data_dir):
        for file in files:
            if file == "checksums.txt":
                continue
                
            filepath = os.path.join(root, file)
            current_checksum = calculate_checksum(filepath)
            
            if file in checksums:
                if checksums[file] != current_checksum:
                    print(f"ERROR: Checksum mismatch for {file}")
                    return False
                else:
                    print(f"OK: {file}")
            else:
                print(f"NEW: {file} - {current_checksum}")
    
    return True

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python validate_data.py <data_directory>")
        sys.exit(1)
    
    data_dir = sys.argv[1]
    if validate_data(data_dir):
        print("Data validation completed successfully!")
    else:
        print("Data validation failed!")
        sys.exit(1)
```

## Performance Optimization

### I/O Optimization

```bash
# Use appropriate block sizes for rsync
rsync -avz --block-size=1M large_file.dat username@login.chpc.ac.za:/home/username/

# Use parallel I/O tools
parallel -j 8 rsync -avz {} username@login.chpc.ac.za:/home/username/ ::: file1.dat file2.dat file3.dat

# Use compression for network transfer
rsync -avz --compress-level=9 data/ username@login.chpc.ac.za:/home/username/
```

### Storage Optimization

```bash
# Use symbolic links to save space
ln -s /scratch/$USER/large_data ~/data/large_data

# Use hard links for identical files
ln large_file.dat large_file_copy.dat

# Use sparse files for large datasets
dd if=/dev/zero of=sparse_file.dat bs=1M seek=1000 count=0
```

## Backup Strategies

### Automated Backups

```bash
#!/bin/bash
# Backup script
BACKUP_DIR="/archive/$USER/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup important data
tar -czf $BACKUP_DIR/home_backup_$DATE.tar.gz /home/$USER/important_data/

# Keep only last 7 backups
find $BACKUP_DIR -name "home_backup_*.tar.gz" -mtime +7 -delete

echo "Backup completed: $BACKUP_DIR/home_backup_$DATE.tar.gz"
```

### Incremental Backups

```bash
#!/bin/bash
# Incremental backup script
SOURCE_DIR="/home/$USER/important_data"
BACKUP_DIR="/archive/$USER/backups"
SNAPSHOT_FILE="$BACKUP_DIR/last_snapshot"

# Create full backup if no snapshot exists
if [ ! -f "$SNAPSHOT_FILE" ]; then
    tar -czf $BACKUP_DIR/full_backup_$(date +%Y%m%d).tar.gz $SOURCE_DIR
    find $SOURCE_DIR -type f -exec md5sum {} \; > $SNAPSHOT_FILE
else
    # Create incremental backup
    tar -czf $BACKUP_DIR/incremental_backup_$(date +%Y%m%d).tar.gz \
        --newer-mtime="$(stat -c %Y $SNAPSHOT_FILE)" $SOURCE_DIR
    find $SOURCE_DIR -type f -exec md5sum {} \; > $SNAPSHOT_FILE
fi
```

## Troubleshooting

### Common Issues

1. **Out of Disk Space**
   ```bash
   # Check disk usage
   df -h
   du -sh /home/$USER/*
   
   # Find large files
   find /home/$USER -type f -size +100M -exec ls -lh {} \;
   
   # Clean up temporary files
   find /home/$USER -name "*.tmp" -delete
   ```

2. **Transfer Failures**
   ```bash
   # Check network connectivity
   ping login.chpc.ac.za
   
   # Use rsync with resume capability
   rsync -avz --partial --progress file.dat username@login.chpc.ac.za:/home/username/
   
   # Split large files
   split -b 1G large_file.dat
   ```

3. **Permission Issues**
   ```bash
   # Check file permissions
   ls -la filename
   
   # Fix permissions
   chmod 644 filename
   chmod 755 directory
   
   # Check quota
   quota
   ```

### Getting Help

- **Storage Issues**: Contact CHPC support
- **Transfer Problems**: Check network connectivity
- **Performance Issues**: Use profiling tools

---

**Next**: Learn about [Performance Optimization](../advanced/optimization.md) for maximizing cluster efficiency. 