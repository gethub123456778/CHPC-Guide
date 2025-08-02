#!/bin/bash
#SBATCH --job-name=python_analysis
#SBATCH --output=python_analysis_%j.out
#SBATCH --error=python_analysis_%j.err
#SBATCH --time=02:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=4
#SBATCH --partition=compute

# Load required modules
module purge
module load python/3.9.0
module load gcc/9.3.0

# Set environment variables
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export PYTHONPATH=$HOME/lib/python3.9/site-packages:$PYTHONPATH

# Print job information
echo "Job ID: $SLURM_JOB_ID"
echo "Node: $SLURM_NODELIST"
echo "CPUs: $SLURM_CPUS_PER_TASK"
echo "Memory: $SLURM_MEM_PER_NODE"
echo "Start time: $(date)"

# Create scratch directory for temporary files
export TMPDIR=/scratch/$USER/tmp
mkdir -p $TMPDIR

# Your Python analysis code here
python << 'EOF'
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import os
import time
from multiprocessing import Pool

def process_data_chunk(data):
    """Process a chunk of data"""
    return np.mean(data), np.std(data)

def main():
    print("Starting Python analysis...")
    
    # Generate sample data
    print("Generating sample data...")
    data = np.random.normal(0, 1, 1000000)
    
    # Split data into chunks for parallel processing
    chunk_size = len(data) // 4
    chunks = [data[i:i+chunk_size] for i in range(0, len(data), chunk_size)]
    
    # Process data in parallel
    print("Processing data in parallel...")
    start_time = time.time()
    
    with Pool(4) as pool:
        results = pool.map(process_data_chunk, chunks)
    
    end_time = time.time()
    
    # Calculate overall statistics
    means = [r[0] for r in results]
    stds = [r[1] for r in results]
    
    overall_mean = np.mean(means)
    overall_std = np.mean(stds)
    
    print(f"Overall mean: {overall_mean:.6f}")
    print(f"Overall std: {overall_std:.6f}")
    print(f"Processing time: {end_time - start_time:.2f} seconds")
    
    # Create a simple plot
    plt.figure(figsize=(10, 6))
    plt.hist(data, bins=50, alpha=0.7, edgecolor='black')
    plt.axvline(overall_mean, color='red', linestyle='--', label=f'Mean: {overall_mean:.3f}')
    plt.xlabel('Value')
    plt.ylabel('Frequency')
    plt.title('Data Distribution')
    plt.legend()
    plt.grid(True, alpha=0.3)
    
    # Save plot
    plot_file = 'data_distribution.png'
    plt.savefig(plot_file, dpi=300, bbox_inches='tight')
    print(f"Plot saved as: {plot_file}")
    
    # Save results to file
    results_df = pd.DataFrame({
        'chunk': range(len(results)),
        'mean': means,
        'std': stds
    })
    results_df.to_csv('analysis_results.csv', index=False)
    print("Results saved to: analysis_results.csv")
    
    print("Analysis completed successfully!")

if __name__ == "__main__":
    main()
EOF

# Clean up temporary files
rm -rf $TMPDIR

# Print completion information
echo "End time: $(date)"
echo "Job completed successfully!" 