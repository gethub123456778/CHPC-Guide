# Exercise 1: First Login and Environment Setup

## Objective

Learn how to connect to the CHPC cluster for the first time and set up your working environment.

## Prerequisites

- CHPC cluster account (username and password)
- SSH client installed on your local machine
- Basic knowledge of Linux command line

## Step-by-Step Instructions

### Step 1: Connect to CHPC Cluster

```bash
# Connect to the cluster
ssh username@login.chpc.ac.za

# You'll be prompted for your password
# Enter your CHPC account password
```

**Expected Output:**
```
Welcome to CHPC Cluster
Last login: Mon Aug  2 13:45:32 2024 from your.ip.address
[username@login ~]$
```

### Step 2: Change Your Password

```bash
# Change your password on first login
passwd

# Follow the prompts to set a new password
# Make sure to use a strong password
```

### Step 3: Explore Your Environment

```bash
# Check your current directory
pwd

# List files in your home directory
ls -la

# Check available disk space
df -h

# Check your quota
quota

# Check system information
uname -a
```

**Expected Output:**
```
/home/username
total 8
drwx------ 2 username username 4096 Aug  2 13:45 .
drwxr-xr-x 3 root     root     4096 Aug  2 13:45 ..
-rw-r--r-- 1 username username  124 Aug  2 13:45 .bash_logout
-rw-r--r-- 1 username username  176 Aug  2 13:45 .bash_profile
-rw-r--r-- 1 username username  124 Aug  2 13:45 .bashrc
```

### Step 4: Check Available Software

```bash
# Check available modules
module avail

# This will show a long list of available software
# Look for common modules like python, gcc, r, etc.
```

### Step 5: Set Up Your Environment

```bash
# Create organized directory structure
mkdir -p ~/projects
mkdir -p ~/data
mkdir -p ~/scripts
mkdir -p ~/results
mkdir -p ~/logs

# Verify directories were created
ls -la ~/
```

### Step 6: Test Basic Commands

```bash
# Test Python (if available)
module load python/3.9.0
python --version

# Test basic Linux commands
echo "Hello from CHPC cluster!"
date
whoami
hostname
```

### Step 7: Create Your First Script

```bash
# Create a simple test script
cat > ~/scripts/test_environment.sh << 'EOF'
#!/bin/bash
echo "=== CHPC Environment Test ==="
echo "User: $(whoami)"
echo "Host: $(hostname)"
echo "Date: $(date)"
echo "Current directory: $(pwd)"
echo "Available modules:"
module avail 2>&1 | head -10
echo "=== Test Complete ==="
EOF

# Make it executable
chmod +x ~/scripts/test_environment.sh

# Run the script
~/scripts/test_environment.sh
```

## Expected Output

After completing all steps, you should see:
- Successful login to the cluster
- Organized directory structure in your home directory
- Available software modules listed
- Your test script running successfully

## Verification

Run these commands to verify your setup:

```bash
# Check directory structure
ls -la ~/

# Should show: projects, data, scripts, results, logs directories

# Test module system
module list

# Should show currently loaded modules (if any)

# Test your script
~/scripts/test_environment.sh

# Should display environment information
```

## Troubleshooting

### Connection Issues

**Problem**: Cannot connect to cluster
```bash
# Check your internet connection
ping google.com

# Test SSH connection
ssh -v username@login.chpc.ac.za
```

**Solution**: Verify your username and password, check internet connection

### Module Issues

**Problem**: Module command not found
```bash
# Load the module system
source /etc/profile.d/modules.sh

# Or add to your .bashrc
echo "source /etc/profile.d/modules.sh" >> ~/.bashrc
source ~/.bashrc
```

**Solution**: The module system should be available by default

### Permission Issues

**Problem**: Cannot create directories
```bash
# Check your home directory permissions
ls -ld ~/

# Should show: drwx------ (your home directory)
```

**Solution**: Contact CHPC support if you have permission issues

## Further Reading

- [Installation Guide](../setup/install.md)
- [Basic Usage Guide](../usage/basic.md)
- [Module System Documentation](module_system.md)

## Next Exercise

Once you've completed this exercise successfully, proceed to:
[Exercise 2: File Management and Transfer](file_management.md)

---

**Congratulations!** You've successfully logged into the CHPC cluster and set up your basic environment. You're now ready to start using the cluster for your computational work! 