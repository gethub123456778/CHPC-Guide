#!/usr/bin/env python3
"""
Simple Projected Density of States (PDOS) Analysis Script
for Quantum ESPRESSO Results

This script creates publication-quality PDOS plots with detailed explanations
of each step in the analysis process.
"""

import matplotlib.pyplot as plt
import numpy as np

# ============================================================================
# DATA LOADING FUNCTION
# ============================================================================
def data_loader(fname):
    """
    Load PDOS data from Quantum ESPRESSO output files
    
    Input file format:
    Column 1: Energy (eV) - Energy values relative to Fermi level
    Column 2: PDOS (states/eV) - Projected density of states
    
    Returns:
    - energy: Energy values in eV
    - pdos: PDOS values in states/eV
    """
    import numpy as np
    data = np.loadtxt(fname)
    energy = data[:, 0]      # Extract energy values (1st column)
    pdos = data[:, 1]        # Extract PDOS values (2nd column)
    return energy, pdos

# ============================================================================
# LOAD DATA FOR EACH ATOM TYPE
# ============================================================================
print("Loading PDOS data for different atomic species...")

# Load PDOS data for each atom type
# Each file contains the total PDOS contribution from that atom
energy, pdos_d = data_loader('atom_W_tot.dat')    # Tungsten (W) atom PDOS
_, pdos_p = data_loader('atom_Se_tot.dat')        # Selenium (Se) atom PDOS  
_, pdos_s = data_loader('atom_S_tot.dat')         # Sulfur (S) atom PDOS
_, pdos_v = data_loader('atom_V_tot.dat')         # Vanadium (V) dopant atom PDOS

# ============================================================================
# PLOT STYLING AND CONFIGURATION
# ============================================================================
# Define background color for better visualization
background_color = '#F7F9F9'

# Energy shift to align Fermi level at 0 eV
# This shifts the energy scale so that the Fermi level appears at 0
shift_value = -0.21
energy_shifted = energy - shift_value

# ============================================================================
# CREATE THE PLOT
# ============================================================================
print("Creating PDOS plot...")

# Create figure with specified size and background
plt.figure(figsize=(8, 4), facecolor=background_color)

# Set plot title
plt.title("V-doped WSSe - Projected Density of States", fontsize=14, fontweight='bold')

# ============================================================================
# PLOT PDOS FOR EACH ATOM TYPE
# ============================================================================
# Plot PDOS lines for each atom with different colors
plt.plot(energy_shifted, pdos_d, linewidth=1.25, color='#000000', label='W (Tungsten)')
plt.plot(energy_shifted, pdos_s, linewidth=1.25, color='#006699', label='Se (Selenium)')
plt.plot(energy_shifted, pdos_p, linewidth=1.25, color='#99ff99', label='S (Sulfur)')
plt.plot(energy_shifted, pdos_v, linewidth=1.25, color='#ff9999', label='V (Vanadium)')

# ============================================================================
# ADD FILLED AREAS FOR BETTER VISUALIZATION
# ============================================================================
# Fill areas below Fermi level (valence band) with transparency
plt.fill_between(energy_shifted, 0, pdos_s, where=(energy_shifted < 0), 
                facecolor='#000000', alpha=0.25)
plt.fill_between(energy_shifted, 0, pdos_p, where=(energy_shifted < 0), 
                facecolor='#006699', alpha=0.25)
plt.fill_between(energy_shifted, 0, pdos_d, where=(energy_shifted < 0), 
                facecolor='#99ff99', alpha=0.25)
plt.fill_between(energy_shifted, 0, pdos_v, where=(energy_shifted < 0), 
                facecolor='#ff9999', alpha=0.25)

# Fill areas above Fermi level (conduction band) with transparency
plt.fill_between(energy_shifted, 0, pdos_s, where=(energy_shifted > 0), 
                facecolor='#000000', alpha=0.25)
plt.fill_between(energy_shifted, 0, pdos_p, where=(energy_shifted > 0), 
                facecolor='#006699', alpha=0.25)
plt.fill_between(energy_shifted, 0, pdos_d, where=(energy_shifted > 0), 
                facecolor='#99ff99', alpha=0.25)
plt.fill_between(energy_shifted, 0, pdos_v, where=(energy_shifted > 0), 
                facecolor='#ff9999', alpha=0.25)

# ============================================================================
# CUSTOMIZE PLOT APPEARANCE
# ============================================================================
# Set y-axis ticks and labels
plt.yticks([0, 5, 10, 15, 20, 25], ["0", "5", "10", "15", "20", "25"])

# Set axis labels
plt.xlabel('Energy (eV)', fontsize=12)
plt.ylabel('PDOS (eV⁻¹)', fontsize=12)

# Add Fermi level reference line (dashed line at 0 eV)
plt.axvline(x=0, linewidth=0.5, color='k', linestyle=(0, (8, 15)))

# Add Fermi level label
plt.text(-0.215, 4, 'Fermi Level', fontsize='medium', rotation=90)

# Set axis limits for better visualization
plt.xlim(-3.5, 3.5)    # Energy range from -3.5 to 3.5 eV
plt.ylim(0, 15)        # PDOS range from 0 to 15 states/eV

# Add legend without frame
plt.legend(frameon=False, loc='upper right')

# ============================================================================
# SAVE THE PLOT
# ============================================================================
print("Saving plot...")
plt.savefig('V_doped_WSSe_PDOS.png', dpi=300, transparent=False, bbox_inches='tight')
print("Plot saved as: V_doped_WSSe_PDOS.png")

# Display the plot
plt.show()

# ============================================================================
# PRINT ANALYSIS SUMMARY
# ============================================================================
print("\n=== PDOS Analysis Summary ===")
print("This plot shows the projected density of states for V-doped WSSe:")
print("- Black line: W (Tungsten) atom contributions")
print("- Blue line: Se (Selenium) atom contributions") 
print("- Green line: S (Sulfur) atom contributions")
print("- Red line: V (Vanadium) dopant atom contributions")
print("\nKey features:")
print("- Fermi level is at 0 eV (dashed vertical line)")
print("- Valence band: Energy < 0 eV (left side)")
print("- Conduction band: Energy > 0 eV (right side)")
print("- Filled areas show the magnitude of each atom's contribution")
print("- Peak heights indicate strong orbital hybridization") 