#!/bin/bash
#SBATCH --job-name=array_processing
#SBATCH --output=array_%A_%a.out
#SBATCH --error=array_%A_%a.err
#SBATCH --time=00:30:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=2
#SBATCH --array=1-10
#SBATCH --partition=compute

# Load required modules
module purge
module load python/3.9.0
module load gcc/9.3.0

# Print job information
echo "Job ID: $SLURM_JOB_ID"
echo "Array Job ID: $SLURM_ARRAY_JOB_ID"
echo "Array Task ID: $SLURM_ARRAY_TASK_ID"
echo "Node: $SLURM_NODELIST"
echo "CPUs: $SLURM_CPUS_PER_TASK"
echo "Memory: $SLURM_MEM_PER_NODE"
echo "Start time: $(date)"

# Create scratch directory for temporary files
export TMPDIR=/scratch/$USER/tmp
mkdir -p $TMPDIR

# Define input and output files based on array index
INPUT_FILE="data_${SLURM_ARRAY_TASK_ID}.txt"
OUTPUT_FILE="results_${SLURM_ARRAY_TASK_ID}.txt"
LOG_FILE="log_${SLURM_ARRAY_TASK_ID}.txt"

# Generate sample input data if it doesn't exist
if [ ! -f "$INPUT_FILE" ]; then
    echo "Generating sample input data for task $SLURM_ARRAY_TASK_ID..."
    python << EOF
import numpy as np
import pandas as pd

# Generate sample data
np.random.seed(${SLURM_ARRAY_TASK_ID})
n_samples = 10000

data = pd.DataFrame({
    'x': np.random.normal(0, 1, n_samples),
    'y': np.random.normal(0, 1, n_samples),
    'z': np.random.normal(0, 1, n_samples),
    'category': np.random.choice(['A', 'B', 'C'], n_samples),
    'value': np.random.exponential(1, n_samples)
})

# Add some task-specific variation
data['x'] += ${SLURM_ARRAY_TASK_ID} * 0.1
data['y'] += ${SLURM_ARRAY_TASK_ID} * 0.05

# Save to file
data.to_csv('$INPUT_FILE', index=False)
print(f"Generated {len(data)} samples for task {${SLURM_ARRAY_TASK_ID}}")
EOF
fi

# Process the data
echo "Processing data for task $SLURM_ARRAY_TASK_ID..."
python << 'EOF'
import pandas as pd
import numpy as np
import time
import sys

# Get task ID from environment
task_id = int(sys.argv[1]) if len(sys.argv) > 1 else 1
input_file = f"data_{task_id}.txt"
output_file = f"results_{task_id}.txt"
log_file = f"log_{task_id}.txt"

print(f"Processing task {task_id}...")

# Read input data
try:
    data = pd.read_csv(input_file)
    print(f"Loaded {len(data)} records from {input_file}")
except Exception as e:
    print(f"Error reading {input_file}: {e}")
    exit(1)

# Perform analysis
start_time = time.time()

# Basic statistics
stats = {
    'task_id': task_id,
    'n_records': len(data),
    'mean_x': data['x'].mean(),
    'std_x': data['x'].std(),
    'mean_y': data['y'].mean(),
    'std_y': data['y'].std(),
    'mean_z': data['z'].mean(),
    'std_z': data['z'].std(),
    'mean_value': data['value'].mean(),
    'std_value': data['value'].std()
}

# Category analysis
category_stats = data.groupby('category').agg({
    'value': ['mean', 'std', 'count']
}).round(4)

# Correlation analysis
correlations = data[['x', 'y', 'z', 'value']].corr().round(4)

# Linear regression
from sklearn.linear_model import LinearRegression
from sklearn.metrics import r2_score

X = data[['x', 'y', 'z']].values
y = data['value'].values

model = LinearRegression()
model.fit(X, y)
y_pred = model.predict(X)
r2 = r2_score(y, y_pred)

stats['r2_score'] = r2
stats['coef_x'] = model.coef_[0]
stats['coef_y'] = model.coef_[1]
stats['coef_z'] = model.coef_[2]
stats['intercept'] = model.intercept_

end_time = time.time()
stats['processing_time'] = end_time - start_time

# Save results
results_df = pd.DataFrame([stats])
results_df.to_csv(output_file, index=False)

# Save detailed results
with open(log_file, 'w') as f:
    f.write(f"Task {task_id} Processing Results\n")
    f.write("=" * 40 + "\n\n")
    
    f.write("Basic Statistics:\n")
    f.write(f"Number of records: {stats['n_records']}\n")
    f.write(f"Processing time: {stats['processing_time']:.4f} seconds\n\n")
    
    f.write("Variable Statistics:\n")
    f.write(f"X - Mean: {stats['mean_x']:.4f}, Std: {stats['std_x']:.4f}\n")
    f.write(f"Y - Mean: {stats['mean_y']:.4f}, Std: {stats['std_y']:.4f}\n")
    f.write(f"Z - Mean: {stats['mean_z']:.4f}, Std: {stats['std_z']:.4f}\n")
    f.write(f"Value - Mean: {stats['mean_value']:.4f}, Std: {stats['std_value']:.4f}\n\n")
    
    f.write("Category Analysis:\n")
    f.write(category_stats.to_string())
    f.write("\n\n")
    
    f.write("Correlation Matrix:\n")
    f.write(correlations.to_string())
    f.write("\n\n")
    
    f.write("Linear Regression Results:\n")
    f.write(f"R² Score: {r2:.4f}\n")
    f.write(f"Coefficients: X={model.coef_[0]:.4f}, Y={model.coef_[1]:.4f}, Z={model.coef_[2]:.4f}\n")
    f.write(f"Intercept: {model.intercept_:.4f}\n")

print(f"Task {task_id} completed successfully!")
print(f"Results saved to {output_file}")
print(f"Log saved to {log_file}")
EOF

# Clean up temporary files
rm -rf $TMPDIR

# Print completion information
echo "End time: $(date)"
echo "Array task $SLURM_ARRAY_TASK_ID completed successfully!" 