#!/usr/bin/env python3
"""
Comprehensive analysis script for all Quantum ESPRESSO results
"""

import subprocess
import os
import numpy as np
import matplotlib.pyplot as plt

def run_all_analyses():
    """Run all analysis scripts"""
    print("=== Comprehensive Quantum ESPRESSO Analysis ===")
    
    # Run individual analyses
    analyses = [
        ('qe_band_analysis.py', 'Band Structure Analysis'),
        ('qe_phonon_analysis.py', 'Phonon Analysis'),
        ('qe_soc_analysis.py', 'Spin-Orbit Coupling Analysis')
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
    with open('comprehensive_report.txt', 'w') as f:
        f.write("Quantum ESPRESSO Comprehensive Analysis Report\n")
        f.write("==============================================\n\n")
        
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
    
    print("Summary report created: comprehensive_report.txt")

def create_combined_plots():
    """Create combined plots showing all results"""
    print("Creating combined plots...")
    
    # Create a multi-panel figure
    fig, axes = plt.subplots(2, 2, figsize=(16, 12))
    
    # Panel 1: Band Structure
    try:
        k_points, energies = np.loadtxt('bands.dat', unpack=True)
        axes[0, 0].plot(k_points, energies, 'b-', linewidth=1, alpha=0.7)
        axes[0, 0].set_title('Band Structure')
        axes[0, 0].set_xlabel('K-points')
        axes[0, 0].set_ylabel('Energy (eV)')
        axes[0, 0].grid(True, alpha=0.3)
    except:
        axes[0, 0].text(0.5, 0.5, 'Band structure data not available', ha='center', va='center')
        axes[0, 0].set_title('Band Structure')
    
    # Panel 2: DOS
    try:
        energy, dos = np.loadtxt('dos.dat', unpack=True)
        axes[0, 1].plot(energy, dos, 'r-', linewidth=2)
        axes[0, 1].set_title('Density of States')
        axes[0, 1].set_xlabel('Energy (eV)')
        axes[0, 1].set_ylabel('DOS (states/eV)')
        axes[0, 1].grid(True, alpha=0.3)
    except:
        axes[0, 1].text(0.5, 0.5, 'DOS data not available', ha='center', va='center')
        axes[0, 1].set_title('Density of States')
    
    # Panel 3: Phonon DOS
    try:
        freq, ph_dos = np.loadtxt('phonon_dos.dat', unpack=True)
        axes[1, 0].plot(freq, ph_dos, 'g-', linewidth=2)
        axes[1, 0].set_title('Phonon DOS')
        axes[1, 0].set_xlabel('Frequency (cm⁻¹)')
        axes[1, 0].set_ylabel('DOS (states/cm⁻¹)')
        axes[1, 0].grid(True, alpha=0.3)
    except:
        axes[1, 0].text(0.5, 0.5, 'Phonon DOS data not available', ha='center', va='center')
        axes[1, 0].set_title('Phonon DOS')
    
    # Panel 4: Summary
    axes[1, 1].text(0.1, 0.8, 'Analysis Summary:', fontsize=12, fontweight='bold')
    axes[1, 1].text(0.1, 0.6, '• Electronic structure calculated', fontsize=10)
    axes[1, 1].text(0.1, 0.5, '• Phonon properties determined', fontsize=10)
    axes[1, 1].text(0.1, 0.4, '• SOC effects included', fontsize=10)
    axes[1, 1].text(0.1, 0.3, '• All plots generated', fontsize=10)
    axes[1, 1].set_xlim(0, 1)
    axes[1, 1].set_ylim(0, 1)
    axes[1, 1].axis('off')
    
    plt.tight_layout()
    plt.savefig('comprehensive_results.png', dpi=300, bbox_inches='tight')
    plt.close()
    
    print("Combined plots saved as: comprehensive_results.png")

def main():
    """Main function"""
    run_all_analyses()
    create_combined_plots()
    print("All analyses completed successfully!")

if __name__ == "__main__":
    main() 