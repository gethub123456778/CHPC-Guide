# Quantum ESPRESSO Calculations on CHPC

## Objective

Learn how to perform electronic structure calculations using Quantum ESPRESSO (QE) on the CHPC cluster, including SCF calculations, DOS analysis, and convergence testing.

## Prerequisites

- Basic understanding of quantum chemistry and solid-state physics
- Familiarity with Linux command line
- Understanding of PBS job submission system

## Overview

Quantum ESPRESSO is a suite of open-source computer codes for electronic-structure calculations and materials modeling at the nanoscale. This guide covers:

1. **Basic SCF Calculations** - Self-consistent field calculations
2. **DOS Analysis** - Density of States calculations
3. **Convergence Testing** - Parameter optimization
4. **Job Submission** - Efficient cluster usage

## Step 1: Environment Setup

### Load Required Modules

```bash
# Clear any existing modules
module purge

# Load Quantum ESPRESSO with Intel parallel studio
module load chpc/qespresso/7.0/parallel_studio/2020u1

# Verify installation
which pw.x
which dos.x
which projwfc.x
```

### Set Up Working Directory

```bash
# Create project directory
mkdir -p ~/qe_calculations
cd ~/qe_calculations

# Create subdirectories for different calculation types
mkdir scf dos convergence
```

## Step 2: Basic SCF Calculation

### Create Input File for WSe2 System

```bash
# Create SCF input file for WSe2 monolayer
cat > scf_wse2.in << 'EOF'
&CONTROL
 calculation = 'scf'           ! Self-consistent field calculation
 restart_mode = 'from_scratch' ! Start fresh calculation
 prefix = 'wse2'              ! Prefix for output files
 outdir = './'                ! Output directory
 pseudo_dir = './pseudo/'     ! Pseudopotential directory
 verbosity = 'high'           ! Detailed output
/

&SYSTEM
 ibrav = 0                    ! Free lattice (not using predefined Bravais lattice)
 nat = 3                      ! Number of atoms
 ntyp = 3                     ! Number of atom types
 ecutwfc = 80                 ! Wavefunction cutoff (Ry)
 ecutrho = 1200               ! Charge density cutoff (Ry)
 occupations = 'smearing'     ! Electronic occupation method
 smearing = 'methfessel-paxton' ! Smearing type
 degauss = 0.02               ! Smearing width (Ry)
 vdw_corr = 'grimme-d2'       ! Van der Waals correction
 nbnd = 40                    ! Number of bands
/

&ELECTRONS
 conv_thr = 1.0d-8           ! Convergence threshold for SCF
 mixing_beta = 0.7           ! Mixing parameter for charge density
 electron_maxstep = 100      ! Maximum SCF iterations
/

&IONS
 ion_dynamics = 'bfgs'        ! Ionic relaxation method
 ion_positions = 'from_input' ! Use atomic positions from input
/

&CELL
 cell_dynamics = 'bfgs'       ! Cell relaxation method
 cell_parameters = 'bohr'     ! Units for cell parameters
/

! Atomic species with pseudopotentials
ATOMIC_SPECIES
W    183.84 w_pbesol_v1.2.uspp.F.UPF    ! Tungsten atom
S    32.065 s_pbesol_v1.4.uspp.F.UPF    ! Sulfur atom  
Se   78.96  se_pbesol_v1.uspp.F.UPF     ! Selenium atom

! Atomic positions in crystal coordinates
ATOMIC_POSITIONS (crystal)
W    0.0000000000  0.0000000000  0.5047327054    ! W atom position
S    0.6666666700  0.3333333300  0.5878091351    ! S atom position
Se   0.6666666700  0.3333333300  0.4122774795    ! Se atom position

! K-points mesh for Brillouin zone sampling
K_POINTS automatic
18 18 1 0 0 0    ! 18x18x1 k-point mesh with no offset

! Unit cell parameters in Angstrom
CELL_PARAMETERS angstrom
    3.2521423200     0.0000000000     0.0000000000
   -1.6260711600     2.8164378658     0.0000000000
    0.0000000000     0.0000000000    18.2324859800
EOF
```

### Create PBS Job Script for SCF

```bash
# Create PBS job script for SCF calculation
cat > scf_wse2_job.sh << 'EOF'
#!/bin/bash
#PBS -P MATS1366                    ! Project allocation
#PBS -N WSe2_SCF                    ! Job name
#PBS -l select=2:ncpus=24:mpiprocs=24  ! Request 2 nodes, 24 cores each
#PBS -l walltime=24:00:00           ! Maximum runtime
#PBS -q normal                      ! Queue name
#PBS -m be                          ! Email notifications (begin/end)
#PBS -M your.email@example.com      ! Email address
#PBS -r n                           ! Do not restart if job fails
#PBS -o scf_wse2.out               ! Standard output file
#PBS -e scf_wse2.err               ! Standard error file

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
mpirun -np 48 pw.x < scf_wse2.in > scf_wse2.out

echo "SCF calculation completed!"
EOF

# Make job script executable
chmod +x scf_wse2_job.sh

## Step 3: Non-SCF Calculation for DOS

### Create Non-SCF Input File

```bash
# Create non-SCF input file for DOS calculation
cat > nscf_wse2.in << 'EOF'
&CONTROL
 calculation = 'nscf'         ! Non-self-consistent field calculation
 restart_mode = 'from_scratch' ! Start fresh calculation
 prefix = 'wse2'              ! Same prefix as SCF calculation
 outdir = './'                ! Output directory
 pseudo_dir = './pseudo/'     ! Pseudopotential directory
 tprnfor = .true.             ! Print forces
 tstress = .true.             ! Print stress tensor
 verbosity = 'high'           ! Detailed output
/

&SYSTEM
 degauss = 0.014699723600     ! Smearing width (Ry)
 ecutwfc = 80                 ! Wavefunction cutoff (Ry)
 ecutrho = 1200               ! Charge density cutoff (Ry)
 ibrav = 0                    ! Free lattice
 nat = 3                      ! Number of atoms
 nosym = .false.              ! Use symmetry
 ntyp = 3                     ! Number of atom types
 occupations = 'tetrahedra'   ! Tetrahedron method for DOS
 smearing = 'methfessel-paxton' ! Smearing type
 vdw_corr = 'grimme-d2'       ! Van der Waals correction
 nbnd = 40                    ! Number of bands (increased for DOS)
/

&ELECTRONS
 conv_thr = 6.0d-10          ! Convergence threshold
 electron_maxstep = 80       ! Maximum SCF iterations
 mixing_beta = 0.4           ! Mixing parameter
/

&IONS
 ion_dynamics = 'bfgs'        ! Ionic relaxation method
 ion_positions = 'from_input' ! Use atomic positions from input
/

&CELL
 cell_parameters = 'bohr'     ! Units for cell parameters
 cell_dynamics = 'bfgs'       ! Cell relaxation method
/

! Atomic species (same as SCF)
ATOMIC_SPECIES
W    183.84 w_pbesol_v1.2.uspp.F.UPF
S    32.065 s_pbesol_v1.4.uspp.F.UPF
Se   78.96  se_pbesol_v1.uspp.F.UPF

! Atomic positions (same as SCF)
ATOMIC_POSITIONS (crystal)
W    0.0000000000  0.0000000000  0.5047327054
S    0.6666666700  0.3333333300  0.5878091351
Se   0.6666666700  0.3333333300  0.4122774795

! K-points (same as SCF)
K_POINTS automatic
18 18 1 0 0 0

! Cell parameters (same as SCF)
CELL_PARAMETERS angstrom
    3.2521423200     0.0000000000     0.0000000000
   -1.6260711600     2.8164378658     0.0000000000
    0.0000000000     0.0000000000    18.2324859800
EOF
```

### Create PBS Job for Non-SCF

```bash
# Create PBS job script for non-SCF calculation
cat > nscf_wse2_job.sh << 'EOF'
#!/bin/bash
#PBS -P MATS1366
#PBS -N WSe2_NSCF
#PBS -l select=2:ncpus=24:mpiprocs=24
#PBS -l walltime=12:00:00
#PBS -q normal
#PBS -m be
#PBS -M your.email@example.com
#PBS -r n
#PBS -o nscf_wse2.out
#PBS -e nscf_wse2.err

# Load modules
module purge
module load chpc/qespresso/7.0/parallel_studio/2020u1

# Set unlimited stack size
ulimit -s unlimited

# Change to working directory
cd $PBS_O_WORKDIR

# Optimize file system
lfs setstripe -d .
lfs setstripe -c 12 ./

# Run non-SCF calculation
mpirun -np 48 pw.x < nscf_wse2.in > nscf_wse2.out

echo "Non-SCF calculation completed!"
EOF

chmod +x nscf_wse2_job.sh
```

## Step 4: Density of States (DOS) Calculation

### Create DOS Input File

```bash
# Create DOS calculation input file
cat > dos_wse2.in << 'EOF'
&DOS
 prefix = 'wse2'              ! Prefix from SCF/NSCF calculations
 outdir = './'                ! Output directory
 fildos = 'dos_wse2.dat'      ! DOS output file name
 emin = -9.0                  ! Minimum energy (eV)
 emax = 9.0                   ! Maximum energy (eV)
 deltaE = 0.01                ! Energy step (eV)
 degauss = 0.02               ! Gaussian broadening (Ry)
/
EOF
```

### Create PBS Job for DOS

```bash
# Create PBS job script for DOS calculation
cat > dos_wse2_job.sh << 'EOF'
#!/bin/bash
#PBS -P MATS1366
#PBS -N WSe2_DOS
#PBS -l select=1:ncpus=24:mpiprocs=24
#PBS -l walltime=02:00:00
#PBS -q normal
#PBS -m be
#PBS -M your.email@example.com
#PBS -r n
#PBS -o dos_wse2.out
#PBS -e dos_wse2.err

# Load modules
module purge
module load chpc/qespresso/7.0/parallel_studio/2020u1

# Set unlimited stack size
ulimit -s unlimited

# Change to working directory
cd $PBS_O_WORKDIR

# Optimize file system
lfs setstripe -d .
lfs setstripe -c 12 ./

# Run DOS calculation
mpirun -np 24 dos.x < dos_wse2.in > dos_wse2.out

echo "DOS calculation completed!"
EOF

chmod +x dos_wse2_job.sh
```

## Step 5: Band Structure Calculation

### Create Band Structure Input File

```bash
# Create band structure calculation input file
cat > bands_wse2.in << 'EOF'
&CONTROL
 calculation = 'bands'        ! Band structure calculation
 restart_mode = 'from_scratch' ! Start fresh calculation
 prefix = 'wse2'              ! Same prefix as SCF calculation
 outdir = './'                ! Output directory
 pseudo_dir = './pseudo/'     ! Pseudopotential directory
 verbosity = 'high'           ! Detailed output
/

&SYSTEM
 ibrav = 0                    ! Free lattice
 nat = 3                      ! Number of atoms
 ntyp = 3                     ! Number of atom types
 ecutwfc = 80                 ! Wavefunction cutoff (Ry)
 ecutrho = 1200               ! Charge density cutoff (Ry)
 occupations = 'fixed'        ! Fixed occupations for band structure
 vdw_corr = 'grimme-d2'       ! Van der Waals correction
 nbnd = 40                    ! Number of bands
/

&ELECTRONS
 conv_thr = 1.0d-8           ! Convergence threshold
 mixing_beta = 0.7           ! Mixing parameter
 electron_maxstep = 100      ! Maximum SCF iterations
/

! Atomic species (same as SCF)
ATOMIC_SPECIES
W    183.84 w_pbesol_v1.2.uspp.F.UPF
S    32.065 s_pbesol_v1.4.uspp.F.UPF
Se   78.96  se_pbesol_v1.uspp.F.UPF

! Atomic positions (same as SCF)
ATOMIC_POSITIONS (crystal)
W    0.0000000000  0.0000000000  0.5047327054
S    0.6666666700  0.3333333300  0.5878091351
Se   0.6666666700  0.3333333300  0.4122774795

! K-points for band structure (high-symmetry path)
K_POINTS crystal_b
60
0.000000  0.000000  0.000000  20    ! Gamma point
0.333333  0.333333  0.000000  20    ! K point
0.500000  0.000000  0.000000  20    ! M point
0.000000  0.000000  0.000000  20    ! Back to Gamma

! Cell parameters (same as SCF)
CELL_PARAMETERS angstrom
    3.2521423200     0.0000000000     0.0000000000
   -1.6260711600     2.8164378658     0.0000000000
    0.0000000000     0.0000000000    18.2324859800
EOF
```

### Create PBS Job for Band Structure

```bash
# Create PBS job script for band structure calculation
cat > bands_wse2_job.sh << 'EOF'
#!/bin/bash
#PBS -P MATS1366
#PBS -N WSe2_Bands
#PBS -l select=2:ncpus=24:mpiprocs=24
#PBS -l walltime=12:00:00
#PBS -q normal
#PBS -m be
#PBS -M your.email@example.com
#PBS -r n
#PBS -o bands_wse2.out
#PBS -e bands_wse2.err

# Load modules
module purge
module load chpc/qespresso/7.0/parallel_studio/2020u1

# Set unlimited stack size
ulimit -s unlimited

# Change to working directory
cd $PBS_O_WORKDIR

# Optimize file system
lfs setstripe -d .
lfs setstripe -c 12 ./

# Run band structure calculation
mpirun -np 48 pw.x < bands_wse2.in > bands_wse2.out

echo "Band structure calculation completed!"
EOF

chmod +x bands_wse2_job.sh
```

## Step 6: Projected DOS (PDOS) Calculation

### Create PDOS Input File

```bash
# Create projected DOS calculation input file
cat > projwfc_wse2.in << 'EOF'
&projwfc
 outdir = './'                ! Output directory
 prefix = 'wse2'              ! Prefix from previous calculations
 ngauss = 0                   ! Gaussian type (0 = Gaussian)
 degauss = 0.036748           ! Gaussian broadening (Ry)
 DeltaE = 0.005               ! Energy step (Ry)
 kresolveddos = .true.        ! K-resolved DOS
 filpdos = 'wse2.pdos'        ! PDOS output file prefix
/
EOF
```

### Create PBS Job for PDOS

```bash
# Create PBS job script for PDOS calculation
cat > projwfc_wse2_job.sh << 'EOF'
#!/bin/bash
#PBS -P MATS1366
#PBS -N WSe2_PDOS
#PBS -l select=1:ncpus=24:mpiprocs=24
#PBS -l walltime=04:00:00
#PBS -q normal
#PBS -m be
#PBS -M your.email@example.com
#PBS -r n
#PBS -o projwfc_wse2.out
#PBS -e projwfc_wse2.err

# Load modules
module purge
module load chpc/qespresso/7.0/parallel_studio/2020u1

# Set unlimited stack size
ulimit -s unlimited

# Change to working directory
cd $PBS_O_WORKDIR

# Optimize file system
lfs setstripe -d .
lfs setstripe -c 12 ./

# Run projected DOS calculation
mpirun -np 24 projwfc.x < projwfc_wse2.in > projwfc_wse2.out

echo "Projected DOS calculation completed!"
EOF

chmod +x projwfc_wse2_job.sh
```

## Step 7: Phonon Calculations

### Create Phonon Input File

```bash
# Create phonon calculation input file
cat > ph_wse2.in << 'EOF'
phonons of WSe2
 &inputph
  tr2_ph = 1.0d-12,           ! Convergence threshold for phonons
  alpha_mix(1) = 0.7,         ! Mixing parameter for phonon calculation
  niter_ph = 50,              ! Maximum iterations for phonon calculation
  outdir = './',              ! Output directory
  prefix = 'wse2',            ! Prefix from SCF calculation
  fildyn = 'wse2.dyn',        ! Dynamical matrix file
  fildvscf = 'wse2.dvscf',    ! Change in self-consistent potential
  ldisp = .true.,             ! Calculate phonons at different q-points
  nq1 = 4, nq2 = 4, nq3 = 1,  ! Q-point mesh for phonon calculation
  epsil = .true.,             ! Calculate dielectric constant
  trans = .true.,             ! Calculate infrared intensities
 /
EOF
```

### Create PBS Job for Phonons

```bash
# Create PBS job script for phonon calculation
cat > ph_wse2_job.sh << 'EOF'
#!/bin/bash
#PBS -P MATS1366
#PBS -N WSe2_Phonons
#PBS -l select=2:ncpus=24:mpiprocs=24
#PBS -l walltime=48:00:00
#PBS -q normal
#PBS -m be
#PBS -M your.email@example.com
#PBS -r n
#PBS -o ph_wse2.out
#PBS -e ph_wse2.err

# Load modules
module purge
module load chpc/qespresso/7.0/parallel_studio/2020u1

# Set unlimited stack size
ulimit -s unlimited

# Change to working directory
cd $PBS_O_WORKDIR

# Optimize file system
lfs setstripe -d .
lfs setstripe -c 12 ./

# Run phonon calculation
mpirun -np 48 ph.x < ph_wse2.in > ph_wse2.out

echo "Phonon calculation completed!"
EOF

chmod +x ph_wse2_job.sh
```

### Create Phonon DOS Input File

```bash
# Create phonon DOS calculation input file
cat > matdyn_wse2.in << 'EOF'
&input
  asr = 'simple',             ! Acoustic sum rule
  dos = .true.,               ! Calculate phonon DOS
  nk1 = 20, nk2 = 20, nk3 = 1, ! K-point mesh for DOS
  deltaE = 0.5,               ! Energy step for DOS (cm^-1)
  fldos = 'wse2.phdos',       ! Phonon DOS output file
  flfrc = 'wse2.fc',          ! Force constants file
/
EOF
```

### Create PBS Job for Phonon DOS

```bash
# Create PBS job script for phonon DOS calculation
cat > matdyn_wse2_job.sh << 'EOF'
#!/bin/bash
#PBS -P MATS1366
#PBS -N WSe2_PhononDOS
#PBS -l select=1:ncpus=24:mpiprocs=24
#PBS -l walltime=02:00:00
#PBS -q normal
#PBS -m be
#PBS -M your.email@example.com
#PBS -r n
#PBS -o matdyn_wse2.out
#PBS -e matdyn_wse2.err

# Load modules
module purge
module load chpc/qespresso/7.0/parallel_studio/2020u1

# Set unlimited stack size
ulimit -s unlimited

# Change to working directory
cd $PBS_O_WORKDIR

# Optimize file system
lfs setstripe -d .
lfs setstripe -c 12 ./

# Run phonon DOS calculation
mpirun -np 24 matdyn.x < matdyn_wse2.in > matdyn_wse2.out

echo "Phonon DOS calculation completed!"
EOF

chmod +x matdyn_wse2_job.sh
```

## Step 8: Spin-Orbit Coupling Calculations

### Create SOC Input File

```bash
# Create spin-orbit coupling calculation input file
cat > soc_wse2.in << 'EOF'
&CONTROL
 calculation = 'nscf'         ! Non-self-consistent field calculation
 restart_mode = 'from_scratch' ! Start fresh calculation
 prefix = 'wse2'              ! Same prefix as SCF calculation
 outdir = './'                ! Output directory
 pseudo_dir = './pseudo/'     ! Pseudopotential directory
 verbosity = 'high'           ! Detailed output
/

&SYSTEM
 ibrav = 0                    ! Free lattice
 nat = 3                      ! Number of atoms
 ntyp = 3                     ! Number of atom types
 ecutwfc = 80                 ! Wavefunction cutoff (Ry)
 ecutrho = 1200               ! Charge density cutoff (Ry)
 occupations = 'smearing'     ! Electronic occupation method
 smearing = 'methfessel-paxton' ! Smearing type
 degauss = 0.02               ! Smearing width (Ry)
 vdw_corr = 'grimme-d2'       ! Van der Waals correction
 nbnd = 40                    ! Number of bands
 noncolin = .true.,           ! Enable non-collinear magnetism
 lspinorb = .true.,           ! Enable spin-orbit coupling
/

&ELECTRONS
 conv_thr = 1.0d-8           ! Convergence threshold
 mixing_beta = 0.7           ! Mixing parameter
 electron_maxstep = 100      ! Maximum SCF iterations
/

! Atomic species (same as SCF)
ATOMIC_SPECIES
W    183.84 w_pbesol_v1.2.uspp.F.UPF
S    32.065 s_pbesol_v1.4.uspp.F.UPF
Se   78.96  se_pbesol_v1.uspp.F.UPF

! Atomic positions (same as SCF)
ATOMIC_POSITIONS (crystal)
W    0.0000000000  0.0000000000  0.5047327054
S    0.6666666700  0.3333333300  0.5878091351
Se   0.6666666700  0.3333333300  0.4122774795

! K-points (same as SCF)
K_POINTS automatic
18 18 1 0 0 0

! Cell parameters (same as SCF)
CELL_PARAMETERS angstrom
    3.2521423200     0.0000000000     0.0000000000
   -1.6260711600     2.8164378658     0.0000000000
    0.0000000000     0.0000000000    18.2324859800
EOF
```

### Create PBS Job for SOC

```bash
# Create PBS job script for spin-orbit coupling calculation
cat > soc_wse2_job.sh << 'EOF'
#!/bin/bash
#PBS -P MATS1366
#PBS -N WSe2_SOC
#PBS -l select=2:ncpus=24:mpiprocs=24
#PBS -l walltime=24:00:00
#PBS -q normal
#PBS -m be
#PBS -M your.email@example.com
#PBS -r n
#PBS -o soc_wse2.out
#PBS -e soc_wse2.err

# Load modules
module purge
module load chpc/qespresso/7.0/parallel_studio/2020u1

# Set unlimited stack size
ulimit -s unlimited

# Change to working directory
cd $PBS_O_WORKDIR

# Optimize file system
lfs setstripe -d .
lfs setstripe -c 12 ./

# Run spin-orbit coupling calculation
mpirun -np 48 pw.x < soc_wse2.in > soc_wse2.out

echo "Spin-orbit coupling calculation completed!"
EOF

chmod +x soc_wse2_job.sh
```

## Step 9: Complete Workflow Script

### Create Automated Workflow

```bash
# Create complete workflow script
cat > wse2_complete_workflow.sh << 'EOF'
#!/bin/bash
# Complete workflow for WSe2 calculations

echo "=== WSe2 Quantum ESPRESSO Workflow ==="
echo "Starting calculations..."

# Step 1: SCF calculation
echo "Step 1: Running SCF calculation..."
scf_job_id=$(qsub scf_wse2_job.sh | cut -d'.' -f1)
echo "SCF job submitted with ID: $scf_job_id"

# Wait for SCF to complete
echo "Waiting for SCF calculation to complete..."
while qstat $scf_job_id >/dev/null 2>&1; do
    sleep 60
    echo "SCF job still running..."
done

# Check if SCF completed successfully
if grep -q "JOB DONE" scf_wse2.out; then
    echo "SCF calculation completed successfully!"
else
    echo "ERROR: SCF calculation failed!"
    exit 1
fi

# Step 2: Non-SCF calculation
echo "Step 2: Running non-SCF calculation..."
nscf_job_id=$(qsub nscf_wse2_job.sh | cut -d'.' -f1)
echo "Non-SCF job submitted with ID: $nscf_job_id"

# Wait for non-SCF to complete
while qstat $nscf_job_id >/dev/null 2>&1; do
    sleep 60
    echo "Non-SCF job still running..."
done

if grep -q "JOB DONE" nscf_wse2.out; then
    echo "Non-SCF calculation completed successfully!"
else
    echo "ERROR: Non-SCF calculation failed!"
    exit 1
fi

# Step 3: DOS calculation
echo "Step 3: Running DOS calculation..."
dos_job_id=$(qsub dos_wse2_job.sh | cut -d'.' -f1)
echo "DOS job submitted with ID: $dos_job_id"

# Wait for DOS to complete
while qstat $dos_job_id >/dev/null 2>&1; do
    sleep 30
    echo "DOS job still running..."
done

if grep -q "JOB DONE" dos_wse2.out; then
    echo "DOS calculation completed successfully!"
else
    echo "ERROR: DOS calculation failed!"
    exit 1
fi

# Step 4: Projected DOS calculation
echo "Step 4: Running projected DOS calculation..."
projwfc_job_id=$(qsub projwfc_wse2_job.sh | cut -d'.' -f1)
echo "Projected DOS job submitted with ID: $projwfc_job_id"

# Wait for projected DOS to complete
while qstat $projwfc_job_id >/dev/null 2>&1; do
    sleep 30
    echo "Projected DOS job still running..."
done

if grep -q "JOB DONE" projwfc_wse2.out; then
    echo "Projected DOS calculation completed successfully!"
else
    echo "ERROR: Projected DOS calculation failed!"
    exit 1
fi

echo "=== All calculations completed successfully! ==="
echo "Results available in:"
echo "  - Total DOS: dos_wse2.dat"
echo "  - Projected DOS: wse2.pdos.*"
echo "  - Wavefunctions: wse2.wfc*"
echo "  - Charge density: wse2.charge-density.dat"
EOF

chmod +x wse2_complete_workflow.sh
```

## Step 7: Analysis and Visualization

### Create Analysis Script

```bash
# Create Python analysis script
cat > analyze_wse2_results.py << 'EOF'
#!/usr/bin/env python3
"""
Analysis script for WSe2 Quantum ESPRESSO results
"""

import numpy as np
import matplotlib.pyplot as plt
import os

def read_dos(filename):
    """Read DOS data from Quantum ESPRESSO output"""
    try:
        data = np.loadtxt(filename)
        energy = data[:, 0]  # Energy in eV
        dos = data[:, 1]     # DOS in states/eV
        return energy, dos
    except:
        print(f"Error reading DOS file: {filename}")
        return None, None

def read_pdos(prefix):
    """Read projected DOS data"""
    pdos_files = []
    for file in os.listdir('.'):
        if file.startswith(prefix) and file.endswith('.pdos'):
            pdos_files.append(file)
    
    pdos_data = {}
    for file in pdos_files:
        try:
            data = np.loadtxt(file)
            atom_type = file.split('.')[1]  # Extract atom type
            pdos_data[atom_type] = {
                'energy': data[:, 0],
                'pdos': data[:, 1]
            }
        except:
            print(f"Error reading PDOS file: {file}")
    
    return pdos_data

def plot_dos(energy, dos, title="Density of States"):
    """Plot total DOS"""
    plt.figure(figsize=(10, 6))
    plt.plot(energy, dos, 'b-', linewidth=2, label='Total DOS')
    plt.axvline(x=0, color='k', linestyle='--', alpha=0.5, label='Fermi Level')
    plt.xlabel('Energy (eV)')
    plt.ylabel('DOS (states/eV)')
    plt.title(title)
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('wse2_total_dos.png', dpi=300, bbox_inches='tight')
    plt.close()

def plot_pdos(pdos_data, title="Projected Density of States"):
    """Plot projected DOS"""
    plt.figure(figsize=(12, 8))
    
    colors = ['red', 'blue', 'green', 'orange', 'purple']
    for i, (atom, data) in enumerate(pdos_data.items()):
        plt.plot(data['energy'], data['pdos'], 
                color=colors[i % len(colors)], 
                linewidth=2, label=f'{atom} PDOS')
    
    plt.axvline(x=0, color='k', linestyle='--', alpha=0.5, label='Fermi Level')
    plt.xlabel('Energy (eV)')
    plt.ylabel('PDOS (states/eV)')
    plt.title(title)
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('wse2_projected_dos.png', dpi=300, bbox_inches='tight')
    plt.close()

def analyze_band_gap(energy, dos):
    """Analyze band gap from DOS"""
    fermi_index = np.argmin(np.abs(energy))
    
    # Find conduction band minimum
    cb_dos = dos[fermi_index:]
    cb_energy = energy[fermi_index:]
    cb_min_idx = np.argmin(cb_dos)
    
    # Find valence band maximum
    vb_dos = dos[:fermi_index]
    vb_energy = energy[:fermi_index]
    vb_max_idx = np.argmax(vb_dos)
    
    band_gap = cb_energy[cb_min_idx] - vb_energy[vb_max_idx]
    
    print(f"Band gap analysis:")
    print(f"  Valence band maximum: {vb_energy[vb_max_idx]:.3f} eV")
    print(f"  Conduction band minimum: {cb_energy[cb_min_idx]:.3f} eV")
    print(f"  Band gap: {band_gap:.3f} eV")
    
    return band_gap

def main():
    """Main analysis function"""
    print("=== WSe2 Quantum ESPRESSO Results Analysis ===")
    
    # Read total DOS
    energy, dos = read_dos('dos_wse2.dat')
    if energy is not None:
        plot_dos(energy, dos, "WSe2 Total Density of States")
        band_gap = analyze_band_gap(energy, dos)
    
    # Read projected DOS
    pdos_data = read_pdos('wse2')
    if pdos_data:
        plot_pdos(pdos_data, "WSe2 Projected Density of States")
    
    # Create summary report
    with open('wse2_analysis_report.txt', 'w') as f:
        f.write("WSe2 Quantum ESPRESSO Analysis Report\n")
        f.write("=====================================\n\n")
        
        if energy is not None:
            f.write(f"Total DOS range: {energy.min():.2f} to {energy.max():.2f} eV\n")
            f.write(f"DOS maximum: {dos.max():.3f} states/eV\n")
            f.write(f"Band gap: {band_gap:.3f} eV\n\n")
        
        f.write("Files generated:\n")
        f.write("- wse2_total_dos.png: Total DOS plot\n")
        f.write("- wse2_projected_dos.png: Projected DOS plot\n")
        f.write("- wse2_analysis_report.txt: This report\n")
    
    print("Analysis completed! Check generated files.")

if __name__ == "__main__":
    main()
EOF

chmod +x analyze_wse2_results.py
```

## Step 8: Enhanced Analysis Scripts

### Band Structure Analysis

```bash
# Create band structure analysis script
cat > analyze_band_structure.py << 'EOF'
#!/usr/bin/env python3
"""
Band structure analysis script for WSe2 Quantum ESPRESSO results
"""

import numpy as np
import matplotlib.pyplot as plt
import os

def read_band_structure(filename):
    """Read band structure data from Quantum ESPRESSO output"""
    try:
        # Read band structure data
        data = np.loadtxt(filename)
        k_points = data[:, 0]  # K-point coordinates
        energies = data[:, 1:] # Band energies
        
        return k_points, energies
    except:
        print(f"Error reading band structure file: {filename}")
        return None, None

def plot_band_structure(k_points, energies, title="Band Structure"):
    """Plot band structure"""
    plt.figure(figsize=(12, 8))
    
    # Plot each band
    for i in range(energies.shape[1]):
        plt.plot(k_points, energies[:, i], 'b-', linewidth=1, alpha=0.7)
    
    # Add Fermi level line
    plt.axhline(y=0, color='k', linestyle='--', alpha=0.5, label='Fermi Level')
    
    # Add high-symmetry point labels
    plt.axvline(x=k_points[0], color='r', linestyle=':', alpha=0.5)
    plt.axvline(x=k_points[len(k_points)//3], color='r', linestyle=':', alpha=0.5)
    plt.axvline(x=k_points[2*len(k_points)//3], color='r', linestyle=':', alpha=0.5)
    plt.axvline(x=k_points[-1], color='r', linestyle=':', alpha=0.5)
    
    plt.text(k_points[0], plt.ylim()[1], 'Γ', fontsize=12, ha='center')
    plt.text(k_points[len(k_points)//3], plt.ylim()[1], 'K', fontsize=12, ha='center')
    plt.text(k_points[2*len(k_points)//3], plt.ylim()[1], 'M', fontsize=12, ha='center')
    plt.text(k_points[-1], plt.ylim()[1], 'Γ', fontsize=12, ha='center')
    
    plt.xlabel('K-points')
    plt.ylabel('Energy (eV)')
    plt.title(title)
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('wse2_band_structure.png', dpi=300, bbox_inches='tight')
    plt.close()

def analyze_band_gap_from_bands(energies):
    """Analyze band gap from band structure"""
    # Find valence band maximum and conduction band minimum
    vb_max = np.max(energies[:, :20])  # Assuming first 20 bands are valence
    cb_min = np.min(energies[:, 20:])  # Assuming remaining bands are conduction
    
    band_gap = cb_min - vb_max
    
    print(f"Band structure analysis:")
    print(f"  Valence band maximum: {vb_max:.3f} eV")
    print(f"  Conduction band minimum: {cb_min:.3f} eV")
    print(f"  Band gap: {band_gap:.3f} eV")
    
    return band_gap

def main():
    """Main band structure analysis function"""
    print("=== WSe2 Band Structure Analysis ===")
    
    # Read band structure
    k_points, energies = read_band_structure('wse2.bands.dat')
    if k_points is not None:
        plot_band_structure(k_points, energies, "WSe2 Band Structure")
        band_gap = analyze_band_gap_from_bands(energies)
    
    print("Band structure analysis completed!")

if __name__ == "__main__":
    main()
EOF

chmod +x analyze_band_structure.py
```

### Phonon Analysis

```bash
# Create phonon analysis script
cat > analyze_phonons.py << 'EOF'
#!/usr/bin/env python3
"""
Phonon analysis script for WSe2 Quantum ESPRESSO results
"""

import numpy as np
import matplotlib.pyplot as plt
import os

def read_phonon_dos(filename):
    """Read phonon DOS data"""
    try:
        data = np.loadtxt(filename)
        frequency = data[:, 0]  # Frequency in cm^-1
        dos = data[:, 1]        # Phonon DOS
        
        return frequency, dos
    except:
        print(f"Error reading phonon DOS file: {filename}")
        return None, None

def read_phonon_modes(filename):
    """Read phonon mode frequencies"""
    try:
        data = np.loadtxt(filename)
        q_points = data[:, 0]   # Q-point coordinates
        frequencies = data[:, 1:] # Phonon frequencies
        
        return q_points, frequencies
    except:
        print(f"Error reading phonon modes file: {filename}")
        return None, None

def plot_phonon_dos(frequency, dos, title="Phonon Density of States"):
    """Plot phonon DOS"""
    plt.figure(figsize=(10, 6))
    plt.plot(frequency, dos, 'g-', linewidth=2, label='Phonon DOS')
    plt.xlabel('Frequency (cm⁻¹)')
    plt.ylabel('DOS (states/cm⁻¹)')
    plt.title(title)
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('wse2_phonon_dos.png', dpi=300, bbox_inches='tight')
    plt.close()

def plot_phonon_dispersion(q_points, frequencies, title="Phonon Dispersion"):
    """Plot phonon dispersion"""
    plt.figure(figsize=(12, 8))
    
    # Plot each phonon branch
    for i in range(frequencies.shape[1]):
        plt.plot(q_points, frequencies[:, i], 'g-', linewidth=1, alpha=0.7)
    
    # Add high-symmetry point labels
    plt.axvline(x=q_points[0], color='r', linestyle=':', alpha=0.5)
    plt.axvline(x=q_points[len(q_points)//3], color='r', linestyle=':', alpha=0.5)
    plt.axvline(x=q_points[2*len(q_points)//3], color='r', linestyle=':', alpha=0.5)
    plt.axvline(x=q_points[-1], color='r', linestyle=':', alpha=0.5)
    
    plt.text(q_points[0], plt.ylim()[1], 'Γ', fontsize=12, ha='center')
    plt.text(q_points[len(q_points)//3], plt.ylim()[1], 'K', fontsize=12, ha='center')
    plt.text(q_points[2*len(q_points)//3], plt.ylim()[1], 'M', fontsize=12, ha='center')
    plt.text(q_points[-1], plt.ylim()[1], 'Γ', fontsize=12, ha='center')
    
    plt.xlabel('Q-points')
    plt.ylabel('Frequency (cm⁻¹)')
    plt.title(title)
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('wse2_phonon_dispersion.png', dpi=300, bbox_inches='tight')
    plt.close()

def analyze_phonon_properties(frequency, dos):
    """Analyze phonon properties"""
    # Calculate total number of states
    total_states = np.trapz(dos, frequency)
    
    # Find maximum frequency
    max_freq = np.max(frequency)
    
    # Calculate average frequency
    avg_freq = np.trapz(frequency * dos, frequency) / total_states
    
    print(f"Phonon analysis:")
    print(f"  Maximum frequency: {max_freq:.1f} cm⁻¹")
    print(f"  Average frequency: {avg_freq:.1f} cm⁻¹")
    print(f"  Total phonon states: {total_states:.1f}")
    
    return max_freq, avg_freq, total_states

def main():
    """Main phonon analysis function"""
    print("=== WSe2 Phonon Analysis ===")
    
    # Read phonon DOS
    frequency, dos = read_phonon_dos('wse2.phdos')
    if frequency is not None:
        plot_phonon_dos(frequency, dos, "WSe2 Phonon Density of States")
        max_freq, avg_freq, total_states = analyze_phonon_properties(frequency, dos)
    
    # Read phonon dispersion
    q_points, frequencies = read_phonon_modes('wse2.freq')
    if q_points is not None:
        plot_phonon_dispersion(q_points, frequencies, "WSe2 Phonon Dispersion")
    
    print("Phonon analysis completed!")

if __name__ == "__main__":
    main()
EOF

chmod +x analyze_phonons.py
```

### Spin-Orbit Coupling Analysis

```bash
# Create spin-orbit coupling analysis script
cat > analyze_soc.py << 'EOF'
#!/usr/bin/env python3
"""
Spin-orbit coupling analysis script for WSe2 Quantum ESPRESSO results
"""

import numpy as np
import matplotlib.pyplot as plt
import os

def read_soc_energies(filename):
    """Read SOC energy levels"""
    try:
        data = np.loadtxt(filename)
        k_points = data[:, 0]  # K-point coordinates
        energies = data[:, 1:] # Energy levels with SOC
        
        return k_points, energies
    except:
        print(f"Error reading SOC energies file: {filename}")
        return None, None

def compare_with_without_soc(soc_energies, no_soc_energies):
    """Compare energies with and without SOC"""
    if soc_energies is None or no_soc_energies is None:
        return None
    
    # Calculate energy differences
    energy_diff = soc_energies - no_soc_energies
    
    # Calculate average SOC splitting
    avg_splitting = np.mean(np.abs(energy_diff))
    max_splitting = np.max(np.abs(energy_diff))
    
    print(f"SOC analysis:")
    print(f"  Average SOC splitting: {avg_splitting:.3f} eV")
    print(f"  Maximum SOC splitting: {max_splitting:.3f} eV")
    
    return avg_splitting, max_splitting

def plot_soc_comparison(k_points, soc_energies, no_soc_energies, title="SOC Comparison"):
    """Plot comparison of band structures with and without SOC"""
    plt.figure(figsize=(12, 8))
    
    # Plot bands without SOC
    for i in range(no_soc_energies.shape[1]):
        plt.plot(k_points, no_soc_energies[:, i], 'b-', linewidth=1, alpha=0.5, label='Without SOC' if i == 0 else "")
    
    # Plot bands with SOC
    for i in range(soc_energies.shape[1]):
        plt.plot(k_points, soc_energies[:, i], 'r-', linewidth=1, alpha=0.7, label='With SOC' if i == 0 else "")
    
    plt.axhline(y=0, color='k', linestyle='--', alpha=0.5, label='Fermi Level')
    
    plt.xlabel('K-points')
    plt.ylabel('Energy (eV)')
    plt.title(title)
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('wse2_soc_comparison.png', dpi=300, bbox_inches='tight')
    plt.close()

def analyze_soc_effects():
    """Analyze SOC effects on electronic structure"""
    print("=== WSe2 Spin-Orbit Coupling Analysis ===")
    
    # Read SOC energies
    k_points, soc_energies = read_soc_energies('wse2_soc.bands.dat')
    if k_points is not None:
        # Compare with non-SOC calculation
        _, no_soc_energies = read_soc_energies('wse2.bands.dat')
        if no_soc_energies is not None:
            avg_splitting, max_splitting = compare_with_without_soc(soc_energies, no_soc_energies)
            plot_soc_comparison(k_points, soc_energies, no_soc_energies, "WSe2 SOC Comparison")
    
    print("SOC analysis completed!")

if __name__ == "__main__":
    analyze_soc_effects()
EOF

chmod +x analyze_soc.py
```

### Comprehensive Analysis Script

```bash
# Create comprehensive analysis script
cat > comprehensive_analysis.py << 'EOF'
#!/usr/bin/env python3
"""
Comprehensive analysis script for all WSe2 Quantum ESPRESSO results
"""

import subprocess
import os

def run_all_analyses():
    """Run all analysis scripts"""
    print("=== Comprehensive WSe2 Analysis ===")
    
    # Run individual analyses
    analyses = [
        ('analyze_wse2_results.py', 'Electronic DOS Analysis'),
        ('analyze_band_structure.py', 'Band Structure Analysis'),
        ('analyze_phonons.py', 'Phonon Analysis'),
        ('analyze_soc.py', 'Spin-Orbit Coupling Analysis')
    ]
    
    for script, description in analyses:
        if os.path.exists(script):
            print(f"Running {description}...")
            try:
                subprocess.run(['python', script], check=True)
                print(f"✓ {description} completed successfully")
            except subprocess.CalledProcessError:
                print(f"✗ {description} failed")
        else:
            print(f"⚠ {script} not found, skipping {description}")
    
    # Create summary report
    create_summary_report()
    
    print("Comprehensive analysis completed!")

def create_summary_report():
    """Create a summary report of all results"""
    with open('wse2_comprehensive_report.txt', 'w') as f:
        f.write("WSe2 Quantum ESPRESSO Comprehensive Analysis Report\n")
        f.write("==================================================\n\n")
        
        f.write("Calculations Performed:\n")
        f.write("1. Self-Consistent Field (SCF) calculation\n")
        f.write("2. Non-SCF calculation for DOS\n")
        f.write("3. Density of States (DOS) calculation\n")
        f.write("4. Projected DOS (PDOS) calculation\n")
        f.write("5. Band structure calculation\n")
        f.write("6. Phonon calculation\n")
        f.write("7. Phonon DOS calculation\n")
        f.write("8. Spin-orbit coupling calculation\n\n")
        
        f.write("Generated Files:\n")
        f.write("- Electronic DOS plots\n")
        f.write("- Band structure plots\n")
        f.write("- Phonon DOS and dispersion plots\n")
        f.write("- SOC comparison plots\n")
        f.write("- Analysis reports\n\n")
        
        f.write("Key Physical Properties:\n")
        f.write("- Electronic band gap\n")
        f.write("- Phonon frequencies and modes\n")
        f.write("- Spin-orbit coupling effects\n")
        f.write("- Density of states\n\n")
        
        f.write("Next Steps:\n")
        f.write("1. Analyze optical properties\n")
        f.write("2. Calculate transport properties\n")
        f.write("3. Study temperature effects\n")
        f.write("4. Investigate strain effects\n")
    
    print("Summary report created: wse2_comprehensive_report.txt")

if __name__ == "__main__":
    run_all_analyses()
EOF

chmod +x comprehensive_analysis.py
```

## Step 9: Submit Complete Workflow

### Run the Complete Calculation

```bash
# Submit the complete workflow
./wse2_complete_workflow.sh

# Monitor job progress
qstat -u $USER

# Check job outputs
tail -f scf_wse2.out
tail -f nscf_wse2.out
tail -f dos_wse2.out
tail -f projwfc_wse2.out
```

## Step 9: Results Analysis

### Run Analysis After Completion

```bash
# Load Python module for analysis
module load python/3.9.0

# Run analysis script
python analyze_wse2_results.py

# View results
ls -la *.png *.dat *.txt
```

## Key Parameters Explained

### Control Parameters
- **`calculation`**: Type of calculation ('scf', 'nscf', 'relax', etc.)
- **`prefix`**: Prefix for output files
- **`outdir`**: Directory for output files
- **`pseudo_dir`**: Directory containing pseudopotentials

### System Parameters
- **`ecutwfc`**: Wavefunction cutoff energy (Ry)
- **`ecutrho`**: Charge density cutoff energy (Ry)
- **`nat`**: Number of atoms
- **`ntyp`**: Number of atom types
- **`nbnd`**: Number of bands to calculate
- **`occupations`**: Electronic occupation method

### Electronic Parameters
- **`conv_thr`**: Convergence threshold for SCF
- **`mixing_beta`**: Mixing parameter for charge density
- **`electron_maxstep`**: Maximum SCF iterations

## Best Practices

1. **Start with SCF**: Always perform SCF calculation first
2. **Use appropriate k-points**: Dense k-point mesh for metals, moderate for semiconductors
3. **Check convergence**: Monitor SCF convergence carefully
4. **Use proper pseudopotentials**: Ensure pseudopotentials are appropriate for your system
5. **Monitor resources**: Check memory and CPU usage
6. **Backup results**: Save important output files

## Troubleshooting

### Common Issues

1. **SCF not converging**
   ```bash
   # Reduce mixing_beta
   # Increase electron_maxstep
   # Check pseudopotentials
   ```

2. **Out of memory**
   ```bash
   # Reduce number of processes
   # Use smaller k-point mesh
   # Check available memory
   ```

3. **Job taking too long**
   ```bash
   # Use fewer k-points initially
   # Reduce energy cutoff
   # Use faster queue if available
   ```

## Expected Output Files

After successful completion, you should have:

1. **SCF calculation**:
   - `wse2.save/`: Directory with wavefunctions and charge density
   - `wse2.xml`: XML output file
   - `scf_wse2.out`: Text output file

2. **DOS calculation**:
   - `dos_wse2.dat`: Total DOS data
   - `dos_wse2.out`: DOS calculation output

3. **Projected DOS**:
   - `wse2.pdos.*`: Projected DOS for each atom type
   - `projwfc_wse2.out`: Projected DOS calculation output

4. **Analysis**:
   - `wse2_total_dos.png`: Total DOS plot
   - `wse2_projected_dos.png`: Projected DOS plot
   - `wse2_analysis_report.txt`: Analysis summary

## Next Steps

Once you've completed this exercise successfully, you can:

1. **Modify the system**: Change atomic positions or cell parameters
2. **Test convergence**: Vary energy cutoff and k-points
3. **Analyze different properties**: Calculate band structure, optical properties
4. **Study other materials**: Apply the same workflow to different systems

## Resources

- [Quantum ESPRESSO Documentation](https://www.quantum-espresso.org/Doc/)
- [CHPC Quantum ESPRESSO Guide](https://wiki.chpc.ac.za/quantum_espresso)
- [Pseudopotential Library](https://www.quantum-espresso.org/pseudopotentials/)

---

**Congratulations!** You've successfully learned how to perform electronic structure calculations using Quantum ESPRESSO on the CHPC cluster!
``` 