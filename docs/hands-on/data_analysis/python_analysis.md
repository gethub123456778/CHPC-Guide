# Exercise: Python Data Analysis

## Objective

Learn how to perform data analysis using Python on the CHPC cluster, including job submission and parallel processing.

## Prerequisites

- Completed [First Login Exercise](basic/first_login.md)
- Basic knowledge of Python
- Understanding of job submission (see [Basic Job Submission](basic/job_submission.md))

## Step-by-Step Instructions

### Step 1: Prepare Your Environment

```bash
# Connect to CHPC cluster
ssh username@login.chpc.ac.za

# Load Python module
module load python/3.9.0

# Create exercise directory
mkdir -p ~/exercises/python_analysis
cd ~/exercises/python_analysis
```

### Step 2: Create Sample Data

```bash
# Create a Python script to generate sample data
cat > generate_data.py << 'EOF'
#!/usr/bin/env python3
import numpy as np
import pandas as pd
import os

# Set random seed for reproducibility
np.random.seed(42)

# Generate sample data
n_samples = 10000
data = {
    'x': np.random.normal(0, 1, n_samples),
    'y': np.random.normal(0, 1, n_samples),
    'z': np.random.normal(0, 1, n_samples),
    'category': np.random.choice(['A', 'B', 'C'], n_samples),
    'value': np.random.exponential(1, n_samples)
}

# Create DataFrame
df = pd.DataFrame(data)

# Add some correlations
df['y'] = 0.7 * df['x'] + 0.3 * df['y']
df['z'] = 0.5 * df['x'] + 0.5 * df['z']

# Save to CSV
df.to_csv('sample_data.csv', index=False)
print(f"Generated {len(df)} samples")
print("Data shape:", df.shape)
print("Columns:", list(df.columns))
EOF

# Run the script
python generate_data.py
```

### Step 3: Create Analysis Script

```bash
# Create the main analysis script
cat > analyze_data.py << 'EOF'
#!/usr/bin/env python3
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import time
import sys
from sklearn.linear_model import LinearRegression
from sklearn.metrics import r2_score
import multiprocessing as mp

def load_data(filename):
    """Load data from CSV file"""
    print(f"Loading data from {filename}")
    df = pd.read_csv(filename)
    print(f"Loaded {len(df)} samples")
    return df

def basic_statistics(df):
    """Calculate basic statistics"""
    print("\n=== Basic Statistics ===")
    print(df.describe())
    
    print("\n=== Category Distribution ===")
    print(df['category'].value_counts())
    
    return df.describe()

def correlation_analysis(df):
    """Perform correlation analysis"""
    print("\n=== Correlation Analysis ===")
    numeric_cols = ['x', 'y', 'z', 'value']
    corr_matrix = df[numeric_cols].corr()
    print(corr_matrix)
    
    # Create correlation plot
    plt.figure(figsize=(10, 8))
    sns.heatmap(corr_matrix, annot=True, cmap='coolwarm', center=0)
    plt.title('Correlation Matrix')
    plt.tight_layout()
    plt.savefig('correlation_matrix.png', dpi=300, bbox_inches='tight')
    plt.close()
    
    return corr_matrix

def regression_analysis(df):
    """Perform linear regression analysis"""
    print("\n=== Regression Analysis ===")
    
    # Prepare data
    X = df[['x', 'y', 'z']].values
    y = df['value'].values
    
    # Fit model
    model = LinearRegression()
    model.fit(X, y)
    
    # Predictions
    y_pred = model.predict(X)
    r2 = r2_score(y, y_pred)
    
    print(f"R² Score: {r2:.4f}")
    print(f"Coefficients: X={model.coef_[0]:.4f}, Y={model.coef_[1]:.4f}, Z={model.coef_[2]:.4f}")
    print(f"Intercept: {model.intercept_:.4f}")
    
    # Create regression plot
    plt.figure(figsize=(10, 6))
    plt.scatter(y, y_pred, alpha=0.6)
    plt.plot([y.min(), y.max()], [y.min(), y.max()], 'r--', lw=2)
    plt.xlabel('Actual Values')
    plt.ylabel('Predicted Values')
    plt.title(f'Regression Results (R² = {r2:.4f})')
    plt.tight_layout()
    plt.savefig('regression_results.png', dpi=300, bbox_inches='tight')
    plt.close()
    
    return model, r2

def parallel_processing(df, n_processes=4):
    """Demonstrate parallel processing"""
    print(f"\n=== Parallel Processing ({n_processes} processes) ===")
    
    # Split data for parallel processing
    chunk_size = len(df) // n_processes
    chunks = [df[i:i+chunk_size] for i in range(0, len(df), chunk_size)]
    
    def process_chunk(chunk):
        """Process a chunk of data"""
        return {
            'mean_x': chunk['x'].mean(),
            'mean_y': chunk['y'].mean(),
            'mean_z': chunk['z'].mean(),
            'mean_value': chunk['value'].mean(),
            'count': len(chunk)
        }
    
    # Process in parallel
    start_time = time.time()
    with mp.Pool(n_processes) as pool:
        results = pool.map(process_chunk, chunks)
    end_time = time.time()
    
    print(f"Parallel processing time: {end_time - start_time:.4f} seconds")
    
    # Aggregate results
    aggregated = {}
    for key in ['mean_x', 'mean_y', 'mean_z', 'mean_value']:
        aggregated[key] = np.mean([r[key] for r in results])
    
    print("Aggregated results:", aggregated)
    return results

def create_visualizations(df):
    """Create various visualizations"""
    print("\n=== Creating Visualizations ===")
    
    # Set style
    plt.style.use('default')
    sns.set_palette("husl")
    
    # 1. Distribution plots
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    fig.suptitle('Data Distributions', fontsize=16)
    
    axes[0, 0].hist(df['x'], bins=30, alpha=0.7, edgecolor='black')
    axes[0, 0].set_title('Distribution of X')
    axes[0, 0].set_xlabel('X')
    axes[0, 0].set_ylabel('Frequency')
    
    axes[0, 1].hist(df['y'], bins=30, alpha=0.7, edgecolor='black')
    axes[0, 1].set_title('Distribution of Y')
    axes[0, 1].set_xlabel('Y')
    axes[0, 1].set_ylabel('Frequency')
    
    axes[1, 0].hist(df['z'], bins=30, alpha=0.7, edgecolor='black')
    axes[1, 0].set_title('Distribution of Z')
    axes[1, 0].set_xlabel('Z')
    axes[1, 0].set_ylabel('Frequency')
    
    axes[1, 1].hist(df['value'], bins=30, alpha=0.7, edgecolor='black')
    axes[1, 1].set_title('Distribution of Value')
    axes[1, 1].set_xlabel('Value')
    axes[1, 1].set_ylabel('Frequency')
    
    plt.tight_layout()
    plt.savefig('distributions.png', dpi=300, bbox_inches='tight')
    plt.close()
    
    # 2. Scatter plots
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    fig.suptitle('Scatter Plots', fontsize=16)
    
    axes[0].scatter(df['x'], df['y'], alpha=0.6)
    axes[0].set_xlabel('X')
    axes[0].set_ylabel('Y')
    axes[0].set_title('X vs Y')
    
    axes[1].scatter(df['x'], df['z'], alpha=0.6)
    axes[1].set_xlabel('X')
    axes[1].set_ylabel('Z')
    axes[1].set_title('X vs Z')
    
    axes[2].scatter(df['y'], df['z'], alpha=0.6)
    axes[2].set_xlabel('Y')
    axes[2].set_ylabel('Z')
    axes[2].set_title('Y vs Z')
    
    plt.tight_layout()
    plt.savefig('scatter_plots.png', dpi=300, bbox_inches='tight')
    plt.close()
    
    # 3. Box plots by category
    plt.figure(figsize=(10, 6))
    df.boxplot(column=['x', 'y', 'z', 'value'], by='category', figsize=(12, 8))
    plt.suptitle('Box Plots by Category')
    plt.tight_layout()
    plt.savefig('box_plots.png', dpi=300, bbox_inches='tight')
    plt.close()
    
    print("Visualizations saved: distributions.png, scatter_plots.png, box_plots.png")

def main():
    """Main analysis function"""
    print("=== Python Data Analysis on CHPC Cluster ===")
    print(f"Python version: {sys.version}")
    print(f"Number of CPU cores: {mp.cpu_count()}")
    
    # Load data
    df = load_data('sample_data.csv')
    
    # Perform analyses
    stats = basic_statistics(df)
    corr_matrix = correlation_analysis(df)
    model, r2 = regression_analysis(df)
    parallel_results = parallel_processing(df)
    create_visualizations(df)
    
    # Save results
    results = {
        'statistics': stats.to_dict(),
        'correlation_matrix': corr_matrix.to_dict(),
        'regression': {
            'r2_score': r2,
            'coefficients': model.coef_.tolist(),
            'intercept': model.intercept_
        },
        'parallel_processing': parallel_results
    }
    
    # Save results to JSON
    import json
    with open('analysis_results.json', 'w') as f:
        json.dump(results, f, indent=2, default=str)
    
    print("\n=== Analysis Complete ===")
    print("Results saved to: analysis_results.json")
    print("Plots saved: correlation_matrix.png, regression_results.png, distributions.png, scatter_plots.png, box_plots.png")

if __name__ == "__main__":
    main()
EOF
```

### Step 4: Create Job Script

```bash
# Create SLURM job script
cat > python_analysis_job.sh << 'EOF'
#!/bin/bash
#SBATCH --job-name=python_analysis
#SBATCH --output=python_analysis_%j.out
#SBATCH --error=python_analysis_%j.err
#SBATCH --time=00:30:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=4
#SBATCH --partition=compute

# Load required modules
module purge
module load python/3.9.0

# Set environment variables
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

# Print job information
echo "Job ID: $SLURM_JOB_ID"
echo "Node: $SLURM_NODELIST"
echo "CPUs: $SLURM_CPUS_PER_TASK"
echo "Memory: $SLURM_MEM_PER_NODE"
echo "Start time: $(date)"

# Create scratch directory for temporary files
export TMPDIR=/scratch/$USER/tmp
mkdir -p $TMPDIR

# Generate data if it doesn't exist
if [ ! -f "sample_data.csv" ]; then
    echo "Generating sample data..."
    python generate_data.py
fi

# Run analysis
echo "Running Python analysis..."
python analyze_data.py

# Clean up
rm -rf $TMPDIR

# Print completion information
echo "End time: $(date)"
echo "Job completed successfully!"
EOF

# Make job script executable
chmod +x python_analysis_job.sh
```

### Step 5: Submit and Monitor Job

```bash
# Submit the job
sbatch python_analysis_job.sh

# Check job status
squeue -u $USER

# Monitor job output (replace JOB_ID with actual job ID)
# tail -f python_analysis_JOB_ID.out
```

### Step 6: Check Results

```bash
# List generated files
ls -la *.png *.json *.csv

# View results summary
cat analysis_results.json | head -20

# Check job output
cat python_analysis_*.out
```

## Expected Output

After successful completion, you should see:

1. **Data files**: `sample_data.csv`
2. **Results**: `analysis_results.json`
3. **Visualizations**: 
   - `correlation_matrix.png`
   - `regression_results.png`
   - `distributions.png`
   - `scatter_plots.png`
   - `box_plots.png`
4. **Job logs**: `python_analysis_*.out`, `python_analysis_*.err`

## Verification

Run these commands to verify your results:

```bash
# Check if all files were created
ls -la *.png *.json *.csv

# Verify data was generated
head -5 sample_data.csv

# Check analysis results
python -c "
import json
with open('analysis_results.json', 'r') as f:
    results = json.load(f)
print('R² Score:', results['regression']['r2_score'])
print('Number of samples processed:', len(results['parallel_processing']))
"
```

## Troubleshooting

### Module Issues

**Problem**: Python module not found
```bash
# Check available Python versions
module avail python

# Load specific version
module load python/3.9.0
```

### Memory Issues

**Problem**: Job fails due to memory
```bash
# Increase memory in job script
#SBATCH --mem=8G
```

### Import Errors

**Problem**: Missing Python packages
```bash
# Check if packages are available
python -c "import numpy, pandas, matplotlib, seaborn, sklearn; print('All packages available')"

# Install packages if needed (in user space)
pip install --user package_name
```

## Further Reading

- [Basic Job Submission](basic/job_submission.md)
- [Parallel Computing](parallel/openmp_basics.md)
- [Data Management](../data/management.md)

## Next Exercise

Once you've completed this exercise successfully, proceed to:
[Exercise: R Statistical Analysis](r_analysis.md)

---

**Congratulations!** You've successfully performed Python data analysis on the CHPC cluster. You can now apply these techniques to your own datasets! 