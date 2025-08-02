# Exercise: Convergence Testing for Quantum ESPRESSO

## Objective

Learn how to systematically test convergence of various parameters in Quantum ESPRESSO calculations to ensure accurate and reliable results.

## Prerequisites

- Completed [Quantum ESPRESSO Basics](quantum_espresso.md)
- Understanding of SCF calculations
- Basic knowledge of Python for analysis

## Step-by-Step Instructions

### Step 1: Understanding Convergence Parameters

Key parameters that need convergence testing:

1. **Energy Cutoff (`ecutwfc`)**: Kinetic energy cutoff for wavefunctions
2. **K-points**: Brillouin zone sampling
3. **Lattice Constant**: For structure optimization
4. **Charge Density Cutoff (`ecutrho`)**: Usually 4×`ecutwfc`

### Step 2: Energy Cutoff Convergence

#### Create Energy Cutoff Testing Script

```bash
# Create PWTK script for energy cutoff convergence
cat > ecut_convergence.pwtk << 'EOF'
# Load base input file
load_fromPWI pw.scf.silicon.in

# Open output file for results
set fid [open ecut_convergence.dat w]

# Test different energy cutoffs
foreach ecut { 12 16 20 24 28 32 36 40 } {
    
    # Set energy cutoff
    SYSTEM "ecutwfc = $ecut"
    
    # Set output file names
    set name "si_ecut_${ecut}"
    
    # Run calculation
    runPW $name.in
    
    # Extract total energy
    set Etot [::pwtk::pwo::totene $name.out]
    
    # Write results
    puts $fid "$ecut $Etot"
    
    # Print progress
    puts "Completed ecutwfc = $ecut Ry, Etot = $Etot Ry"
}

close $fid
puts "Energy cutoff convergence test completed!"
EOF
```

#### Create PBS Job for Energy Cutoff Testing

```bash
# Create PBS job script
cat > ecut_convergence_job.sh << 'EOF'
#!/bin/bash
#PBS -P MATS1366
#PBS -N ecut_conv
#PBS -l select=1:ncpus=8:mem=8gb
#PBS -l walltime=06:00:00
#PBS -q normal
#PBS -m e
#PBS -M user@example.com
#PBS -o ecut_conv.out
#PBS -e ecut_conv.err

# Load modules
module purge
module load chpc/qespresso/6.7/parallel_studio/2020u1

# Set working directory
cd $PBS_O_WORKDIR

# Run convergence test
pwtk ecut_convergence.pwtk

echo "Energy cutoff convergence test completed!"
EOF

chmod +x ecut_convergence_job.sh
qsub ecut_convergence_job.sh
```

### Step 3: K-Points Convergence

#### Create K-Points Testing Script

```bash
# Create PWTK script for k-points convergence
cat > kpoints_convergence.pwtk << 'EOF'
# Load base input file
load_fromPWI pw.scf.silicon.in

# Set converged energy cutoff
SYSTEM "ecutwfc = 30"

# Open output file for results
set fid [open kpoints_convergence.dat w]

# Test different k-point meshes
foreach k { 2 3 4 5 6 7 8 10 } {
    
    # Set k-points
    K_POINTS automatic "$k $k $k 1 1 1"
    
    # Set output file names
    set name "si_kpoints_${k}x${k}x${k}"
    
    # Run calculation
    runPW $name.in
    
    # Extract total energy
    set Etot [::pwtk::pwo::totene $name.out]
    
    # Write results
    puts $fid "$k $Etot"
    
    # Print progress
    puts "Completed k-points = ${k}x${k}x${k}, Etot = $Etot Ry"
}

close $fid
puts "K-points convergence test completed!"
EOF
```

#### Create PBS Job for K-Points Testing

```bash
# Create PBS job script
cat > kpoints_convergence_job.sh << 'EOF'
#!/bin/bash
#PBS -P MATS1366
#PBS -N kpoints_conv
#PBS -l select=1:ncpus=8:mem=8gb
#PBS -l walltime=04:00:00
#PBS -q normal
#PBS -m e
#PBS -M user@example.com
#PBS -o kpoints_conv.out
#PBS -e kpoints_conv.err

# Load modules
module purge
module load chpc/qespresso/6.7/parallel_studio/2020u1

# Set working directory
cd $PBS_O_WORKDIR

# Run convergence test
pwtk kpoints_convergence.pwtk

echo "K-points convergence test completed!"
EOF

chmod +x kpoints_convergence_job.sh
qsub kpoints_convergence_job.sh
```

### Step 4: Lattice Constant Convergence

#### Create Lattice Constant Testing Script

```bash
# Create PWTK script for lattice constant convergence
cat > alat_convergence.pwtk << 'EOF'
# Load base input file
load_fromPWI pw.scf.silicon.in

# Set converged parameters
SYSTEM "ecutwfc = 30"
K_POINTS automatic "6 6 6 1 1 1"

# Open output file for results
set fid [open alat_convergence.dat w]

# Test different lattice constants
foreach alat { 10.0 10.1 10.2 10.3 10.4 10.5 10.6 10.7 } {
    
    # Set lattice constant
    SYSTEM "celldm(1) = $alat"
    
    # Set output file names
    set name "si_alat_${alat}"
    
    # Run calculation
    runPW $name.in
    
    # Extract total energy
    set Etot [::pwtk::pwo::totene $name.out]
    
    # Write results
    puts $fid "$alat $Etot"
    
    # Print progress
    puts "Completed alat = $alat Bohr, Etot = $Etot Ry"
}

close $fid
puts "Lattice constant convergence test completed!"
EOF
```

#### Create PBS Job for Lattice Constant Testing

```bash
# Create PBS job script
cat > alat_convergence_job.sh << 'EOF'
#!/bin/bash
#PBS -P MATS1366
#PBS -N alat_conv
#PBS -l select=1:ncpus=8:mem=8gb
#PBS -l walltime=04:00:00
#PBS -q normal
#PBS -m e
#PBS -M user@example.com
#PBS -o alat_conv.out
#PBS -e alat_conv.err

# Load modules
module purge
module load chpc/qespresso/6.7/parallel_studio/2020u1

# Set working directory
cd $PBS_O_WORKDIR

# Run convergence test
pwtk alat_convergence.pwtk

echo "Lattice constant convergence test completed!"
EOF

chmod +x alat_convergence_job.sh
qsub alat_convergence_job.sh
```

### Step 5: Automated Convergence Testing

#### Create Comprehensive Testing Script

```bash
# Create comprehensive convergence testing script
cat > comprehensive_convergence.py << 'EOF'
#!/usr/bin/env python3
import numpy as np
import matplotlib.pyplot as plt
import subprocess
import os

def run_convergence_test(test_type, parameters, input_file):
    """Run convergence test for given parameters"""
    results = []
    
    for param in parameters:
        # Create modified input file
        with open(input_file, 'r') as f:
            content = f.read()
        
        if test_type == 'ecutwfc':
            # Replace energy cutoff
            import re
            content = re.sub(r'ecutwfc\s*=\s*\d+', f'ecutwfc = {param}', content)
        elif test_type == 'kpoints':
            # Replace k-points
            content = re.sub(r'K_POINTS \(automatic\)\s*\n\s*\d+\s+\d+\s+\d+', 
                           f'K_POINTS (automatic)\n  {param} {param} {param} 1 1 1', content)
        
        # Write modified input file
        output_file = f'si_{test_type}_{param}.in'
        with open(output_file, 'w') as f:
            f.write(content)
        
        # Run calculation
        cmd = f'mpirun -np 4 pw.x < {output_file} > si_{test_type}_{param}.out'
        subprocess.run(cmd, shell=True)
        
        # Extract total energy
        try:
            with open(f'si_{test_type}_{param}.out', 'r') as f:
                for line in f:
                    if 'total energy' in line and '=' in line:
                        energy = float(line.split('=')[1].split('Ry')[0].strip())
                        results.append([param, energy])
                        break
        except:
            print(f"Warning: Could not extract energy for {test_type} = {param}")
    
    return np.array(results)

def plot_convergence_results():
    """Plot all convergence results"""
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    
    # Energy cutoff convergence
    try:
        ecut_data = np.loadtxt('ecut_convergence.dat')
        axes[0, 0].plot(ecut_data[:, 0], ecut_data[:, 1], 'o-', linewidth=2, markersize=6)
        axes[0, 0].set_xlabel('Energy Cutoff (Ry)')
        axes[0, 0].set_ylabel('Total Energy (Ry)')
        axes[0, 0].set_title('Energy Cutoff Convergence')
        axes[0, 0].grid(True, alpha=0.3)
    except:
        axes[0, 0].text(0.5, 0.5, 'No data available', ha='center', va='center')
        axes[0, 0].set_title('Energy Cutoff Convergence')
    
    # K-points convergence
    try:
        kpt_data = np.loadtxt('kpoints_convergence.dat')
        axes[0, 1].plot(kpt_data[:, 0], kpt_data[:, 1], 's-', linewidth=2, markersize=6)
        axes[0, 1].set_xlabel('K-points')
        axes[0, 1].set_ylabel('Total Energy (Ry)')
        axes[0, 1].set_title('K-points Convergence')
        axes[0, 1].grid(True, alpha=0.3)
    except:
        axes[0, 1].text(0.5, 0.5, 'No data available', ha='center', va='center')
        axes[0, 1].set_title('K-points Convergence')
    
    # Lattice constant convergence
    try:
        alat_data = np.loadtxt('alat_convergence.dat')
        axes[1, 0].plot(alat_data[:, 0], alat_data[:, 1], '^-', linewidth=2, markersize=6)
        axes[1, 0].set_xlabel('Lattice Constant (Bohr)')
        axes[1, 0].set_ylabel('Total Energy (Ry)')
        axes[1, 0].set_title('Lattice Constant Convergence')
        axes[1, 0].grid(True, alpha=0.3)
    except:
        axes[1, 0].text(0.5, 0.5, 'No data available', ha='center', va='center')
        axes[1, 0].set_title('Lattice Constant Convergence')
    
    # Convergence summary
    axes[1, 1].text(0.1, 0.8, 'Convergence Summary:', fontsize=12, fontweight='bold')
    axes[1, 1].text(0.1, 0.6, '• Energy Cutoff: Check for plateau', fontsize=10)
    axes[1, 1].text(0.1, 0.5, '• K-points: Check for convergence', fontsize=10)
    axes[1, 1].text(0.1, 0.4, '• Lattice Constant: Find minimum', fontsize=10)
    axes[1, 1].text(0.1, 0.3, '• Recommended thresholds:', fontsize=10)
    axes[1, 1].text(0.1, 0.2, '  - Energy: 1 meV/atom', fontsize=10)
    axes[1, 1].text(0.1, 0.1, '  - K-points: 1 meV/atom', fontsize=10)
    axes[1, 1].set_xlim(0, 1)
    axes[1, 1].set_ylim(0, 1)
    axes[1, 1].axis('off')
    
    plt.tight_layout()
    plt.savefig('comprehensive_convergence.png', dpi=300, bbox_inches='tight')
    plt.close()
    
    print("Comprehensive convergence plot saved as 'comprehensive_convergence.png'")

def analyze_convergence():
    """Analyze convergence results and provide recommendations"""
    print("=== Convergence Analysis ===")
    
    # Energy cutoff analysis
    try:
        ecut_data = np.loadtxt('ecut_convergence.dat')
        energies = ecut_data[:, 1]
        energy_diff = np.abs(np.diff(energies))
        
        # Find where energy difference is less than 1 meV/atom
        threshold = 0.001  # 1 meV in Ry
        converged_idx = np.where(energy_diff < threshold)[0]
        
        if len(converged_idx) > 0:
            recommended_ecut = ecut_data[converged_idx[0], 0]
            print(f"Recommended energy cutoff: {recommended_ecut} Ry")
        else:
            print("Energy cutoff not converged within 1 meV/atom")
    except:
        print("Energy cutoff data not available")
    
    # K-points analysis
    try:
        kpt_data = np.loadtxt('kpoints_convergence.dat')
        energies = kpt_data[:, 1]
        energy_diff = np.abs(np.diff(energies))
        
        converged_idx = np.where(energy_diff < threshold)[0]
        
        if len(converged_idx) > 0:
            recommended_kpts = kpt_data[converged_idx[0], 0]
            print(f"Recommended k-points: {recommended_kpts}x{recommended_kpts}x{recommended_kpts}")
        else:
            print("K-points not converged within 1 meV/atom")
    except:
        print("K-points data not available")
    
    # Lattice constant analysis
    try:
        alat_data = np.loadtxt('alat_convergence.dat')
        min_idx = np.argmin(alat_data[:, 1])
        optimal_alat = alat_data[min_idx, 0]
        print(f"Optimal lattice constant: {optimal_alat} Bohr")
    except:
        print("Lattice constant data not available")

if __name__ == "__main__":
    plot_convergence_results()
    analyze_convergence()
    print("Convergence analysis completed!")
EOF
```

#### Create PBS Job for Analysis

```bash
# Create PBS job for analysis
cat > convergence_analysis_job.sh << 'EOF'
#!/bin/bash
#PBS -P MATS1366
#PBS -N conv_analysis
#PBS -l select=1:ncpus=4:mem=4gb
#PBS -l walltime=01:00:00
#PBS -q normal
#PBS -m e
#PBS -M user@example.com
#PBS -o conv_analysis.out
#PBS -e conv_analysis.err

# Load modules
module purge
module load python/3.9.0
module load chpc/qespresso/6.7/parallel_studio/2020u1

# Set working directory
cd $PBS_O_WORKDIR

# Run analysis
python comprehensive_convergence.py

echo "Convergence analysis completed!"
EOF

chmod +x convergence_analysis_job.sh
qsub convergence_analysis_job.sh
```

### Step 6: Convergence Criteria and Best Practices

#### Convergence Thresholds

```bash
# Create convergence criteria guide
cat > convergence_criteria.txt << 'EOF'
CONVERGENCE CRITERIA FOR QUANTUM ESPRESSO

1. ENERGY CUTOFF (ecutwfc)
   - Target: Energy difference < 1 meV/atom
   - Typical range: 20-50 Ry
   - Metals: Higher cutoff needed
   - Semiconductors: Lower cutoff sufficient

2. K-POINTS
   - Target: Energy difference < 1 meV/atom
   - Metals: Denser k-point mesh needed
   - Semiconductors: 6x6x6 often sufficient
   - Use Monkhorst-Pack mesh for bulk

3. LATTICE CONSTANT
   - Target: Find energy minimum
   - Use parabolic fit around minimum
   - Consider thermal expansion

4. SCF CONVERGENCE
   - Energy threshold: 1.0d-7 Ry
   - Force threshold: 1.0d-8 Ry/bohr
   - Stress threshold: 1.0d-9 Ry/bohr³

5. MIXING PARAMETERS
   - Semiconductors: mixing_beta = 0.6
   - Metals: mixing_beta = 0.3
   - Insulators: mixing_beta = 0.8

6. CHARGE DENSITY CUTOFF
   - Usually: ecutrho = 4 * ecutwfc
   - For ultrasoft pseudopotentials: ecutrho = 8 * ecutwfc

RECOMMENDED WORKFLOW:
1. Start with moderate parameters
2. Test energy cutoff first
3. Test k-points with converged cutoff
4. Optimize structure with converged parameters
5. Perform final calculations with all converged parameters
EOF
```

## Expected Output

After successful completion, you should have:

1. **Convergence data files**:
   - `ecut_convergence.dat`
   - `kpoints_convergence.dat`
   - `alat_convergence.dat`

2. **Analysis plots**:
   - `comprehensive_convergence.png`

3. **Convergence recommendations** in the output

## Verification

Run these commands to verify your results:

```bash
# Check convergence data
head -5 ecut_convergence.dat
head -5 kpoints_convergence.dat
head -5 alat_convergence.dat

# Check analysis plots
ls -la *.png

# Check job outputs
grep "completed" *.out
```

## Troubleshooting

### Common Issues

1. **Convergence not reached**
   ```bash
   # Increase parameter range
   # Check for oscillations in energy
   # Reduce mixing_beta if oscillating
   ```

2. **Jobs taking too long**
   ```bash
   # Use smaller parameter ranges initially
   # Start with lower precision
   # Use fewer k-points for initial tests
   ```

3. **Memory issues**
   ```bash
   # Reduce number of processes
   # Use smaller supercells
   # Check available memory
   ```

## Best Practices

1. **Systematic Testing**: Test one parameter at a time
2. **Reasonable Ranges**: Don't test unnecessary extremes
3. **Documentation**: Keep track of all tested parameters
4. **Reproducibility**: Use same pseudopotentials throughout
5. **Validation**: Compare with literature when possible

## Further Reading

- [Quantum ESPRESSO Documentation](https://www.quantum-espresso.org/Doc/)
- [Convergence Testing Guide](https://www.quantum-espresso.org/Doc/pw_user_guide/)
- [Structure Optimization](structure_optimization.md)
- [Advanced QE Calculations](advanced_qe.md)

## Next Exercise

Once you've completed this exercise successfully, proceed to:
[Exercise: Structure Optimization](structure_optimization.md)

---

**Congratulations!** You've successfully learned how to perform systematic convergence testing for Quantum ESPRESSO calculations. This is crucial for obtaining reliable and accurate results! 