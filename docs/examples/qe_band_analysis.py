#!/usr/bin/env python3
"""
Band structure analysis script for Quantum ESPRESSO results
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
    plt.savefig('band_structure.png', dpi=300, bbox_inches='tight')
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
    print("=== Band Structure Analysis ===")
    
    # Read band structure
    k_points, energies = read_band_structure('bands.dat')
    if k_points is not None:
        plot_band_structure(k_points, energies, "Band Structure")
        band_gap = analyze_band_gap_from_bands(energies)
    
    print("Band structure analysis completed!")

if __name__ == "__main__":
    main() 