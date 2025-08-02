#!/usr/bin/env python3
"""
Enhanced Projected Density of States (PDOS) Analysis Script
for Quantum ESPRESSO Results

This script analyzes and visualizes the projected density of states
for different atomic species in a material system.

Key Features:
- Loads PDOS data for different atoms (W, Se, S, V)
- Creates publication-quality plots with proper styling
- Shows orbital contributions with filled areas
- Includes Fermi level reference
- Supports energy shifting for better visualization
"""

import matplotlib.pyplot as plt
from matplotlib import rcParamsDefault
import numpy as np

def data_loader(fname):
    """
    Load PDOS data from Quantum ESPRESSO output files
    
    Parameters:
    fname (str): Filename containing PDOS data
    
    Returns:
    tuple: (energy, pdos) - Energy values and corresponding PDOS values
    
    File format expected:
    Column 1: Energy (eV)
    Column 2: PDOS (states/eV)
    """
    try:
        data = np.loadtxt(fname)
        energy = data[:, 0]      # Energy values in eV
        pdos = data[:, 1]        # PDOS values in states/eV
        return energy, pdos
    except FileNotFoundError:
        print(f"Warning: File {fname} not found")
        return None, None
    except Exception as e:
        print(f"Error loading {fname}: {e}")
        return None, None

def create_pdos_plot(energy, pdos_data, atom_labels, colors, title="Projected Density of States"):
    """
    Create a publication-quality PDOS plot
    
    Parameters:
    energy (array): Energy values
    pdos_data (dict): Dictionary of PDOS data for each atom
    atom_labels (list): Labels for each atom type
    colors (list): Colors for each atom type
    title (str): Plot title
    """
    
    # Define background color for better visualization
    background_color = '#F7F9F9'
    
    # Energy shift for better alignment (adjust as needed)
    shift_value = -0.21
    energy_shifted = energy - shift_value
    
    # Create figure with specified background
    plt.figure(figsize=(10, 6), facecolor=background_color)
    
    # Set title and labels
    plt.title(title, fontsize=16, fontweight='bold')
    plt.xlabel('Energy (eV)', fontsize=12)
    plt.ylabel('PDOS (eV⁻¹)', fontsize=12)
    
    # Plot PDOS for each atom type
    for i, (atom, pdos) in enumerate(pdos_data.items()):
        if pdos is not None:
            # Main PDOS line
            plt.plot(energy_shifted, pdos, 
                    linewidth=1.5, 
                    color=colors[i], 
                    label=atom_labels[i])
            
            # Fill areas below Fermi level (valence band)
            plt.fill_between(energy_shifted, 0, pdos, 
                           where=(energy_shifted < 0), 
                           facecolor=colors[i], 
                           alpha=0.3)
            
            # Fill areas above Fermi level (conduction band)
            plt.fill_between(energy_shifted, 0, pdos, 
                           where=(energy_shifted > 0), 
                           facecolor=colors[i], 
                           alpha=0.3)
    
    # Add Fermi level reference line
    plt.axvline(x=0, linewidth=1.0, color='black', linestyle='--', alpha=0.7)
    plt.text(-0.1, plt.ylim()[1]*0.9, 'Fermi Level', 
             fontsize=10, rotation=90, ha='right', va='top')
    
    # Customize plot appearance
    plt.grid(True, alpha=0.2)
    plt.legend(frameon=False, loc='upper right', fontsize=10)
    
    # Set axis limits and ticks
    plt.xlim(-3.5, 3.5)
    plt.ylim(0, 15)
    plt.yticks([0, 5, 10, 15], ["0", "5", "10", "15"])
    
    # Remove top and right spines for cleaner look
    plt.gca().spines['top'].set_visible(False)
    plt.gca().spines['right'].set_visible(False)
    
    plt.tight_layout()
    return plt.gcf()

def analyze_pdos_contributions(energy, pdos_data, atom_labels):
    """
    Analyze PDOS contributions for each atom type
    
    Parameters:
    energy (array): Energy values
    pdos_data (dict): Dictionary of PDOS data for each atom
    atom_labels (list): Labels for each atom type
    
    Returns:
    dict: Analysis results for each atom
    """
    analysis_results = {}
    
    for i, (atom, pdos) in enumerate(pdos_data.items()):
        if pdos is not None:
            # Find Fermi level (closest to 0)
            fermi_idx = np.argmin(np.abs(energy))
            
            # Calculate contributions
            valence_contribution = np.trapz(pdos[:fermi_idx], energy[:fermi_idx])
            conduction_contribution = np.trapz(pdos[fermi_idx:], energy[fermi_idx:])
            total_contribution = valence_contribution + conduction_contribution
            
            # Find peak positions
            valence_peak_idx = np.argmax(pdos[:fermi_idx])
            conduction_peak_idx = fermi_idx + np.argmax(pdos[fermi_idx:])
            
            analysis_results[atom_labels[i]] = {
                'valence_contribution': valence_contribution,
                'conduction_contribution': conduction_contribution,
                'total_contribution': total_contribution,
                'valence_peak_energy': energy[valence_peak_idx],
                'conduction_peak_energy': energy[conduction_peak_idx],
                'max_pdos': np.max(pdos)
            }
    
    return analysis_results

def main():
    """
    Main function to run PDOS analysis
    """
    print("=== Enhanced PDOS Analysis ===")
    
    # Define atom types and their corresponding data files
    atom_files = {
        'W': 'atom_W_tot.dat',      # Tungsten atom PDOS
        'Se': 'atom_Se_tot.dat',    # Selenium atom PDOS
        'S': 'atom_S_tot.dat',      # Sulfur atom PDOS
        'V': 'atom_V_tot.dat'       # Vanadium atom PDOS (dopant)
    }
    
    # Define colors for each atom type
    colors = ['#000000', '#006699', '#99ff99', '#ff9999']  # Black, Blue, Green, Red
    atom_labels = ['W', 'Se', 'S', 'V']
    
    # Load PDOS data for all atoms
    pdos_data = {}
    energy = None
    
    print("Loading PDOS data...")
    for atom, filename in atom_files.items():
        print(f"  Loading {atom} data from {filename}")
        e, pdos = data_loader(filename)
        if e is not None:
            energy = e  # Use energy from first successful load
            pdos_data[atom] = pdos
        else:
            pdos_data[atom] = None
    
    if energy is None:
        print("Error: No valid PDOS data found!")
        return
    
    # Create the PDOS plot
    print("Creating PDOS plot...")
    fig = create_pdos_plot(energy, pdos_data, atom_labels, colors, 
                          title="V-doped WSSe - Projected Density of States")
    
    # Save the plot
    output_filename = 'V_doped_WSSe_PDOS.png'
    plt.savefig(output_filename, dpi=300, bbox_inches='tight', facecolor='white')
    print(f"Plot saved as: {output_filename}")
    
    # Analyze PDOS contributions
    print("Analyzing PDOS contributions...")
    analysis = analyze_pdos_contributions(energy, pdos_data, atom_labels)
    
    # Print analysis results
    print("\n=== PDOS Analysis Results ===")
    for atom, results in analysis.items():
        print(f"\n{atom} Atom:")
        print(f"  Total contribution: {results['total_contribution']:.3f} states")
        print(f"  Valence band contribution: {results['valence_contribution']:.3f} states")
        print(f"  Conduction band contribution: {results['conduction_contribution']:.3f} states")
        print(f"  Valence peak energy: {results['valence_peak_energy']:.3f} eV")
        print(f"  Conduction peak energy: {results['conduction_peak_energy']:.3f} eV")
        print(f"  Maximum PDOS: {results['max_pdos']:.3f} states/eV")
    
    # Create analysis report
    with open('pdos_analysis_report.txt', 'w') as f:
        f.write("PDOS Analysis Report\n")
        f.write("===================\n\n")
        f.write(f"System: V-doped WSSe\n")
        f.write(f"Analysis date: {plt.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
        
        for atom, results in analysis.items():
            f.write(f"{atom} Atom Analysis:\n")
            f.write(f"  Total contribution: {results['total_contribution']:.3f} states\n")
            f.write(f"  Valence band contribution: {results['valence_contribution']:.3f} states\n")
            f.write(f"  Conduction band contribution: {results['conduction_contribution']:.3f} states\n")
            f.write(f"  Valence peak energy: {results['valence_peak_energy']:.3f} eV\n")
            f.write(f"  Conduction peak energy: {results['conduction_peak_energy']:.3f} eV\n")
            f.write(f"  Maximum PDOS: {results['max_pdos']:.3f} states/eV\n\n")
    
    print(f"\nAnalysis report saved as: pdos_analysis_report.txt")
    print("PDOS analysis completed successfully!")

if __name__ == "__main__":
    main() 