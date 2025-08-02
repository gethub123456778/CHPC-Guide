# Exercise: Quantum ESPRESSO Calculations

## Objective

Learn how to perform various Quantum ESPRESSO calculations on the CHPC cluster, including SCF calculations, convergence testing, structure optimization, and post-processing analysis.

## Prerequisites

- Completed [First Login Exercise](../basic/first_login.md)
- Basic knowledge of Quantum ESPRESSO
- Understanding of DFT concepts
- Completed [PBS Job Submission](../basic/pbs_job_submission.md)

## Step-by-Step Instructions

### Step 1: Prepare Your Environment

```bash
# Connect to CHPC cluster
ssh username@login.chpc.ac.za

# Load Quantum ESPRESSO module
module load chpc/qespresso/6.7/parallel_studio/2020u1

# Create exercise directory
mkdir -p ~/exercises/quantum_espresso
cd ~/exercises/quantum_espresso

# Create subdirectories
mkdir -p silicon pseudos results
cd silicon
```

### Step 2: Self-Consistent Field (SCF) Calculation for Silicon

#### Understanding Quantum ESPRESSO Input Files

Quantum ESPRESSO input files consist of:
- **NAMELISTS**: Variables with default values that can be customized
- **INPUT_CARDS**: Mandatory specifications in specific order

**Mandatory NAMELISTS in PWscf:**
1. `&CONTROL`: Specifies computation flow
2. `&SYSTEM`: Specifies the system
3. `&ELECTRONS`: Specifies algorithms for solving Kohn-Sham equations

**Optional NAMELISTS:**
- `&IONS`: For ionic relaxation
- `&CELL`: For cell optimization

**Mandatory INPUT_CARDS:**
- `ATOMIC_SPECIES`: Atomic species and pseudopotentials
- `ATOMIC_POSITIONS`: Atomic coordinates
- `K_POINTS`: K-point sampling

#### Create SCF Input File

```bash
# Create SCF input file for silicon
cat > pw.scf.silicon.in << 'EOF'
&CONTROL
! we want to perform self consistent field calculation
  calculation = 'scf',

! prefix is reference to the output files
  prefix = 'silicon',

! output directory. Note that it is deprecated.
  outdir = './tmp/'

! directory for the pseudo potential directory
  pseudo_dir = '../pseudos/'

! verbosity high will give more details on the output file
  verbosity = 'high'
/

&SYSTEM
! Bravais lattice index, which is 2 for FCC structure
  ibrav =  2,

! Lattice constant in BOHR
  celldm(1) = 10.26,

! number of atoms in an unit cell
  nat =  2,

! number of different types of atom in the cell
  ntyp = 1,

! kinetic energy cutoff for wavefunction in Ry
  ecutwfc = 30

! number of bands to calculate
  nbnd = 8
/

&ELECTRONS
! Mixing factor used in the self-consistent method
  mixing_beta = 0.6
/

ATOMIC_SPECIES
  Si 28.086 Si.pz-vbc.UPF

ATOMIC_POSITIONS (alat)
  Si 0.0 0.0 0.0
  Si 0.25 0.25 0.25

K_POINTS (automatic)
  6 6 6 0 0 0
EOF
```

#### Download Pseudopotential

```bash
# Download silicon pseudopotential
cd ../pseudos
wget https://www.quantum-espresso.org/upf_files/Si.pz-vbc.UPF

# Verify download
ls -la Si.pz-vbc.UPF
cd ../silicon
```

#### Create PBS Job Script for SCF

```bash
# Create PBS job script for SCF calculation
cat > scf_silicon_job.sh << 'EOF'
#!/bin/bash
#PBS -P MATS1366                    # Project allocation code
#PBS -N silicon_scf                 # Job name
#PBS -l select=1:ncpus=8:mem=8gb   # Request 1 node, 8 CPUs, 8GB memory
#PBS -l walltime=02:00:00           # Maximum wall clock time (2 hours)
#PBS -q normal                      # Queue name
#PBS -m e                           # Email notification on end
#PBS -M user@example.com            # Email address
#PBS -o scf_silicon.out             # Standard output file
#PBS -e scf_silicon.err             # Standard error file

# Load required modules
module purge
module load chpc/qespresso/6.7/parallel_studio/2020u1

# Set unlimited stack size for better performance
ulimit -s unlimited

# Change to working directory
cd $PBS_O_WORKDIR

# Create output directory
mkdir -p tmp

# Run Quantum ESPRESSO SCF calculation
mpirun -np 8 pw.x < pw.scf.silicon.in > pw.scf.silicon.out

echo "SCF calculation completed!"
EOF

# Make job script executable
chmod +x scf_silicon_job.sh
```

#### Submit and Monitor SCF Job

```bash
# Submit the job
qsub scf_silicon_job.sh

# Check job status
qstat -u $USER

# Monitor job progress
tail -f pw.scf.silicon.out
```

#### Analyze SCF Results

```bash
# Check convergence
grep -e 'total energy' -e 'estimate' pw.scf.silicon.out

# Check bandgap
grep -A 1 "highest occupied, lowest unoccupied level" pw.scf.silicon.out

# Check exchange-correlation functional
grep "Exchange-correlation" pw.scf.silicon.out

# Check number of plane waves
grep -A 10 "Parallelization info" pw.scf.silicon.out
```

### Step 3: Convergence Testing

#### Energy Cutoff Convergence

```bash
# Create convergence testing script
cat > convergence_ecut.pwtk << 'EOF'
# load the pw.x input from file
load_fromPWI pw.scf.silicon.in

# open a file for writing resulting total energies
set fid [open etot_vs_ecutwfc.dat w]

# loop over different "ecut" values
foreach ecut { 12 16 20 24 28 32 } {

    # name of I/O files: $name.in & $name.out
    set name si_scf_ecutwfc-$ecut

    # set the pw.x "ecutwfc" variable
    SYSTEM "ecutwfc = $ecut"

    # run the pw.x calculation
    runPW $name.in

    # extract the "total energy" and write it to file
    set Etot [::pwtk::pwo::totene $name.out]
    puts $fid "$ecut $Etot"
}

close $fid
EOF

# Create PBS job for convergence testing
cat > convergence_ecut_job.sh << 'EOF'
#!/bin/bash
#PBS -P MATS1366
#PBS -N conv_ecut
#PBS -l select=1:ncpus=8:mem=8gb
#PBS -l walltime=04:00:00
#PBS -q normal
#PBS -m e
#PBS -M user@example.com
#PBS -o conv_ecut.out
#PBS -e conv_ecut.err

module purge
module load chpc/qespresso/6.7/parallel_studio/2020u1

cd $PBS_O_WORKDIR

# Run convergence test
pwtk convergence_ecut.pwtk

echo "Convergence testing completed!"
EOF

chmod +x convergence_ecut_job.sh
qsub convergence_ecut_job.sh
```

#### K-Points Convergence

```bash
# Create k-points convergence script
cat > convergence_kpoints.pwtk << 'EOF'
load_fromPWI pw.scf.silicon.in

set fid [open etot_vs_kpoint.dat w]

foreach k { 2 4 6 8 } {

    set name si_scf_kpoints-$k

    K_POINTS automatic "$k $k $k 1 1 1"
    runPW $name.in

    set Etot [::pwtk::pwo::totene $name.out]
    puts $fid "$k $Etot"
}

close $fid
EOF

# Create PBS job for k-points convergence
cat > convergence_kpoints_job.sh << 'EOF'
#!/bin/bash
#PBS -P MATS1366
#PBS -N conv_kpoints
#PBS -l select=1:ncpus=8:mem=8gb
#PBS -l walltime=04:00:00
#PBS -q normal
#PBS -m e
#PBS -M user@example.com
#PBS -o conv_kpoints.out
#PBS -e conv_kpoints.err

module purge
module load chpc/qespresso/6.7/parallel_studio/2020u1

cd $PBS_O_WORKDIR

# Run k-points convergence test
pwtk convergence_kpoints.pwtk

echo "K-points convergence testing completed!"
EOF

chmod +x convergence_kpoints_job.sh
qsub convergence_kpoints_job.sh
```

### Step 4: Structure Optimization

#### Ionic Relaxation

```bash
# Create ionic relaxation input file
cat > pw.relax.silicon.in << 'EOF'
&CONTROL
  calculation = 'relax',
  prefix = 'silicon',
  outdir = './tmp/',
  pseudo_dir = '../pseudos/',
  verbosity = 'high'
/

&SYSTEM
  ibrav =  2,
  celldm(1) = 10.26,
  nat =  2,
  ntyp = 1,
  ecutwfc = 30,
  nbnd = 8
/

&ELECTRONS
  mixing_beta = 0.6
/

&IONS
  ion_dynamics = 'bfgs'
/

ATOMIC_SPECIES
  Si 28.086 Si.pz-vbc.UPF

ATOMIC_POSITIONS (alat)
  Si 0.0 0.0 0.0
  Si 0.25 0.25 0.25

K_POINTS (automatic)
  6 6 6 0 0 0
EOF

# Create PBS job for ionic relaxation
cat > relax_silicon_job.sh << 'EOF'
#!/bin/bash
#PBS -P MATS1366
#PBS -N silicon_relax
#PBS -l select=1:ncpus=8:mem=8gb
#PBS -l walltime=04:00:00
#PBS -q normal
#PBS -m e
#PBS -M user@example.com
#PBS -o relax_silicon.out
#PBS -e relax_silicon.err

module purge
module load chpc/qespresso/6.7/parallel_studio/2020u1

cd $PBS_O_WORKDIR

# Run ionic relaxation
mpirun -np 8 pw.x < pw.relax.silicon.in > pw.relax.silicon.out

echo "Ionic relaxation completed!"
EOF

chmod +x relax_silicon_job.sh
qsub relax_silicon_job.sh
```

### Step 5: Post-Processing Calculations

#### Density of States (DOS)

```bash
# Create DOS calculation input
cat > dos.silicon.in << 'EOF'
&DOS
  prefix = 'silicon',
  outdir = './tmp/',
  fildos = 'silicon.dos',
  degauss = 0.01,
  deltae = 0.01,
  emin = -10.0,
  emax = 20.0
/
EOF

# Create PBS job for DOS
cat > dos_silicon_job.sh << 'EOF'
#!/bin/bash
#PBS -P MATS1366
#PBS -N silicon_dos
#PBS -l select=1:ncpus=4:mem=4gb
#PBS -l walltime=01:00:00
#PBS -q normal
#PBS -m e
#PBS -M user@example.com
#PBS -o dos_silicon.out
#PBS -e dos_silicon.err

module purge
module load chpc/qespresso/6.7/parallel_studio/2020u1

cd $PBS_O_WORKDIR

# Run DOS calculation
dos.x < dos.silicon.in > dos.silicon.out

echo "DOS calculation completed!"
EOF

chmod +x dos_silicon_job.sh
qsub dos_silicon_job.sh
```

#### Band Structure

```bash
# Create band structure calculation
cat > bands.silicon.in << 'EOF'
&CONTROL
  calculation = 'bands',
  prefix = 'silicon',
  outdir = './tmp/',
  pseudo_dir = '../pseudos/',
  verbosity = 'high'
/

&SYSTEM
  ibrav =  2,
  celldm(1) = 10.26,
  nat =  2,
  ntyp = 1,
  ecutwfc = 30,
  nbnd = 8
/

&ELECTRONS
  mixing_beta = 0.6
/

ATOMIC_SPECIES
  Si 28.086 Si.pz-vbc.UPF

ATOMIC_POSITIONS (alat)
  Si 0.0 0.0 0.0
  Si 0.25 0.25 0.25

K_POINTS (crystal_b)
  50
  0.0 0.0 0.0   1
  0.5 0.0 0.0   1
  0.5 0.5 0.0   1
  0.0 0.0 0.0   1
  0.5 0.5 0.5   1
EOF

# Create PBS job for band structure
cat > bands_silicon_job.sh << 'EOF'
#!/bin/bash
#PBS -P MATS1366
#PBS -N silicon_bands
#PBS -l select=1:ncpus=8:mem=8gb
#PBS -l walltime=02:00:00
#PBS -q normal
#PBS -m e
#PBS -M user@example.com
#PBS -o bands_silicon.out
#PBS -e bands_silicon.err

module purge
module load chpc/qespresso/6.7/parallel_studio/2020u1

cd $PBS_O_WORKDIR

# Run band structure calculation
mpirun -np 8 pw.x < bands.silicon.in > bands.silicon.out

echo "Band structure calculation completed!"
EOF

chmod +x bands_silicon_job.sh
qsub bands_silicon_job.sh
```

### Step 6: Analysis and Visualization

#### Create Analysis Script

```bash
# Create Python analysis script
cat > analyze_results.py << 'EOF'
#!/usr/bin/env python3
import numpy as np
import matplotlib.pyplot as plt

def plot_convergence():
    """Plot convergence results"""
    try:
        # Plot energy cutoff convergence
        ecut_data = np.loadtxt('etot_vs_ecutwfc.dat')
        plt.figure(figsize=(10, 6))
        plt.subplot(2, 2, 1)
        plt.plot(ecut_data[:, 0], ecut_data[:, 1], 'o-')
        plt.xlabel('Energy Cutoff (Ry)')
        plt.ylabel('Total Energy (Ry)')
        plt.title('Energy Cutoff Convergence')
        plt.grid(True)
        
        # Plot k-points convergence
        kpt_data = np.loadtxt('etot_vs_kpoint.dat')
        plt.subplot(2, 2, 2)
        plt.plot(kpt_data[:, 0], kpt_data[:, 1], 's-')
        plt.xlabel('K-points')
        plt.ylabel('Total Energy (Ry)')
        plt.title('K-points Convergence')
        plt.grid(True)
        
        plt.tight_layout()
        plt.savefig('convergence_plots.png', dpi=300, bbox_inches='tight')
        plt.close()
        
        print("Convergence plots saved as 'convergence_plots.png'")
        
    except FileNotFoundError:
        print("Convergence data files not found. Run convergence tests first.")

def analyze_scf_output():
    """Analyze SCF output"""
    try:
        with open('pw.scf.silicon.out', 'r') as f:
            content = f.read()
        
        # Extract total energy
        import re
        energy_match = re.search(r'total energy\s*=\s*([-\d.]+)', content)
        if energy_match:
            total_energy = float(energy_match.group(1))
            print(f"Total Energy: {total_energy} Ry")
        
        # Extract bandgap
        gap_match = re.search(r'highest occupied, lowest unoccupied level.*?(\d+\.\d+)\s+(\d+\.\d+)', content)
        if gap_match:
            homo = float(gap_match.group(1))
            lumo = float(gap_match.group(2))
            bandgap = lumo - homo
            print(f"Bandgap: {bandgap:.4f} eV")
        
    except FileNotFoundError:
        print("SCF output file not found.")

if __name__ == "__main__":
    print("=== Quantum ESPRESSO Results Analysis ===")
    analyze_scf_output()
    plot_convergence()
    print("Analysis completed!")
EOF

# Create PBS job for analysis
cat > analysis_job.sh << 'EOF'
#!/bin/bash
#PBS -P MATS1366
#PBS -N qe_analysis
#PBS -l select=1:ncpus=4:mem=4gb
#PBS -l walltime=00:30:00
#PBS -q normal
#PBS -m e
#PBS -M user@example.com
#PBS -o analysis.out
#PBS -e analysis.err

module purge
module load python/3.9.0

cd $PBS_O_WORKDIR

# Run analysis
python analyze_results.py

echo "Analysis completed!"
EOF

chmod +x analysis_job.sh
qsub analysis_job.sh
```

## Expected Output

After successful completion, you should have:

1. **SCF calculation results**: `pw.scf.silicon.out`
2. **Convergence data**: `etot_vs_ecutwfc.dat`, `etot_vs_kpoint.dat`
3. **Structure optimization**: `pw.relax.silicon.out`
4. **DOS results**: `silicon.dos`
5. **Band structure**: `bands.silicon.out`
6. **Analysis plots**: `convergence_plots.png`

## Verification

Run these commands to verify your results:

```bash
# Check SCF convergence
grep -e 'total energy' -e 'estimate' pw.scf.silicon.out

# Check convergence data
head -5 etot_vs_ecutwfc.dat
head -5 etot_vs_kpoint.dat

# Check DOS file
head -10 silicon.dos

# Check analysis plots
ls -la *.png
```

## Troubleshooting

### Common Issues

1. **SCF not converging**
   ```bash
   # Reduce mixing_beta
   # In input file: mixing_beta = 0.3
   
   # Increase energy cutoff
   # In input file: ecutwfc = 40
   ```

2. **Pseudopotential not found**
   ```bash
   # Check pseudopotential path
   ls -la ../pseudos/Si.pz-vbc.UPF
   
   # Update pseudo_dir in input file
   ```

3. **Job fails due to memory**
   ```bash
   # Increase memory request in PBS script
   #PBS -l mem=16gb
   ```

## Tips for Convergence

1. **Energy Cutoff**: Start with 30 Ry, increase if needed
2. **K-points**: Use 6x6x6 for semiconductors, higher for metals
3. **Mixing**: Use 0.6 for semiconductors, 0.3 for metals
4. **Convergence Threshold**: 1.0d-7 for SCF, 1.0d-8 for forces

## Further Reading

- [Quantum ESPRESSO Documentation](https://www.quantum-espresso.org/Doc/)
- [PWscf User Guide](https://www.quantum-espresso.org/Doc/pw_user_guide/)
- [Convergence Testing](convergence_testing.md)
- [Advanced QE Calculations](advanced_qe.md)

## Next Exercise

Once you've completed this exercise successfully, proceed to:
[Exercise: Advanced Quantum ESPRESSO Calculations](advanced_qe.md)

---

**Congratulations!** You've successfully performed Quantum ESPRESSO calculations on the CHPC cluster. You can now apply these techniques to your own materials! 