#!/usr/bin/env python3
"""
Spin-orbit coupling analysis script for Quantum ESPRESSO results
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
    plt.savefig('soc_comparison.png', dpi=300, bbox_inches='tight')
    plt.close()

def analyze_soc_effects():
    """Analyze SOC effects on electronic structure"""
    print("=== Spin-Orbit Coupling Analysis ===")
    
    # Read SOC energies
    k_points, soc_energies = read_soc_energies('soc_bands.dat')
    if k_points is not None:
        # Compare with non-SOC calculation
        _, no_soc_energies = read_soc_energies('bands.dat')
        if no_soc_energies is not None:
            avg_splitting, max_splitting = compare_with_without_soc(soc_energies, no_soc_energies)
            plot_soc_comparison(k_points, soc_energies, no_soc_energies, "SOC Comparison")
    
    print("SOC analysis completed!")

if __name__ == "__main__":
    analyze_soc_effects() 