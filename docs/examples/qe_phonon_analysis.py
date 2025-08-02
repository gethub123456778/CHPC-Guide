#!/usr/bin/env python3
"""
Phonon analysis script for Quantum ESPRESSO results
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
    plt.savefig('phonon_dos.png', dpi=300, bbox_inches='tight')
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
    plt.savefig('phonon_dispersion.png', dpi=300, bbox_inches='tight')
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
    print("=== Phonon Analysis ===")
    
    # Read phonon DOS
    frequency, dos = read_phonon_dos('phonon_dos.dat')
    if frequency is not None:
        plot_phonon_dos(frequency, dos, "Phonon Density of States")
        max_freq, avg_freq, total_states = analyze_phonon_properties(frequency, dos)
    
    # Read phonon dispersion
    q_points, frequencies = read_phonon_modes('phonon_frequencies.dat')
    if q_points is not None:
        plot_phonon_dispersion(q_points, frequencies, "Phonon Dispersion")
    
    print("Phonon analysis completed!")

if __name__ == "__main__":
    main() 