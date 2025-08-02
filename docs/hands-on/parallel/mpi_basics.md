# Exercise: MPI Programming Basics

## Objective

Learn how to write, compile, and run MPI (Message Passing Interface) programs on the CHPC cluster for distributed memory parallel computing.

## Prerequisites

- Completed [First Login Exercise](basic/first_login.md)
- Basic knowledge of C programming
- Understanding of parallel computing concepts
- Completed [Basic Job Submission](basic/job_submission.md)

## Step-by-Step Instructions

### Step 1: Prepare Your Environment

```bash
# Connect to CHPC cluster
ssh username@login.chpc.ac.za

# Load required modules
module load gcc/9.3.0
module load openmpi/4.0.5

# Create exercise directory
mkdir -p ~/exercises/mpi_basics
cd ~/exercises/mpi_basics
```

### Step 2: Create Your First MPI Program

```bash
# Create a simple "Hello World" MPI program
cat > mpi_hello.c << 'EOF'
#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char** argv) {
    int rank, size;
    char hostname[256];
    
    // Initialize MPI
    MPI_Init(&argc, &argv);
    
    // Get process rank and total number of processes
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    
    // Get hostname
    gethostname(hostname, sizeof(hostname));
    
    // Print information from each process
    printf("Hello from process %d of %d on node %s\n", rank, size, hostname);
    
    // Synchronize all processes
    MPI_Barrier(MPI_COMM_WORLD);
    
    // Only rank 0 prints summary
    if (rank == 0) {
        printf("\n=== MPI Program Summary ===\n");
        printf("Total processes: %d\n", size);
        printf("Program completed successfully!\n");
    }
    
    // Finalize MPI
    MPI_Finalize();
    return 0;
}
EOF
```

### Step 3: Compile the MPI Program

```bash
# Compile the program
mpicc -O3 -o mpi_hello mpi_hello.c

# Check if compilation was successful
ls -la mpi_hello
```

### Step 4: Test Locally

```bash
# Test with 4 processes on login node (for small tests only)
mpirun -np 4 ./mpi_hello
```

### Step 5: Create MPI Job Script

```bash
# Create SLURM job script for MPI
cat > mpi_hello_job.sh << 'EOF'
#!/bin/bash
#SBATCH --job-name=mpi_hello
#SBATCH --output=mpi_hello_%j.out
#SBATCH --error=mpi_hello_%j.err
#SBATCH --time=00:10:00
#SBATCH --mem=2G
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=4
#SBATCH --partition=compute

# Load required modules
module purge
module load gcc/9.3.0
module load openmpi/4.0.5

# Print job information
echo "Job ID: $SLURM_JOB_ID"
echo "Nodes: $SLURM_NODELIST"
echo "Total tasks: $SLURM_NTASKS"
echo "Tasks per node: $SLURM_NTASKS_PER_NODE"
echo "Start time: $(date)"

# Run MPI program
mpirun -np $SLURM_NTASKS ./mpi_hello

# Print completion information
echo "End time: $(date)"
echo "Job completed successfully!"
EOF

# Make job script executable
chmod +x mpi_hello_job.sh
```

### Step 6: Submit and Monitor Job

```bash
# Submit the job
sbatch mpi_hello_job.sh

# Check job status
squeue -u $USER

# Monitor job output (replace JOB_ID with actual job ID)
# tail -f mpi_hello_JOB_ID.out
```

### Step 7: Create Advanced MPI Program

```bash
# Create a more complex MPI program for matrix-vector multiplication
cat > mpi_matrix_vector.c << 'EOF'
#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

int main(int argc, char** argv) {
    int rank, size, i, j;
    int n = 1000;  // Matrix size
    double *matrix, *vector, *result, *local_result;
    double start_time, end_time, total_time;
    
    // Initialize MPI
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    
    // Calculate rows per process
    int rows_per_process = n / size;
    int remainder = n % size;
    
    // Adjust for remainder
    if (rank < remainder) {
        rows_per_process++;
    }
    
    // Allocate memory
    matrix = (double*)malloc(rows_per_process * n * sizeof(double));
    vector = (double*)malloc(n * sizeof(double));
    local_result = (double*)malloc(rows_per_process * sizeof(double));
    
    if (rank == 0) {
        result = (double*)malloc(n * sizeof(double));
    }
    
    // Initialize data on rank 0
    if (rank == 0) {
        srand(time(NULL));
        
        // Initialize matrix
        for (i = 0; i < n; i++) {
            for (j = 0; j < n; j++) {
                matrix[i * n + j] = (double)rand() / RAND_MAX;
            }
        }
        
        // Initialize vector
        for (i = 0; i < n; i++) {
            vector[i] = (double)rand() / RAND_MAX;
        }
        
        printf("Matrix size: %d x %d\n", n, n);
        printf("Number of processes: %d\n", size);
    }
    
    // Broadcast vector to all processes
    MPI_Bcast(vector, n, MPI_DOUBLE, 0, MPI_COMM_WORLD);
    
    // Scatter matrix rows to all processes
    int *sendcounts = (int*)malloc(size * sizeof(int));
    int *displs = (int*)malloc(size * sizeof(int));
    
    int current_displ = 0;
    for (i = 0; i < size; i++) {
        sendcounts[i] = (n / size + (i < remainder ? 1 : 0)) * n;
        displs[i] = current_displ;
        current_displ += sendcounts[i];
    }
    
    MPI_Scatterv(matrix, sendcounts, displs, MPI_DOUBLE,
                 matrix, rows_per_process * n, MPI_DOUBLE,
                 0, MPI_COMM_WORLD);
    
    // Synchronize and start timing
    MPI_Barrier(MPI_COMM_WORLD);
    start_time = MPI_Wtime();
    
    // Perform local matrix-vector multiplication
    for (i = 0; i < rows_per_process; i++) {
        local_result[i] = 0.0;
        for (j = 0; j < n; j++) {
            local_result[i] += matrix[i * n + j] * vector[j];
        }
    }
    
    // Gather results back to rank 0
    MPI_Gather(local_result, rows_per_process, MPI_DOUBLE,
               result, rows_per_process, MPI_DOUBLE,
               0, MPI_COMM_WORLD);
    
    // End timing
    end_time = MPI_Wtime();
    total_time = end_time - start_time;
    
    // Print results on rank 0
    if (rank == 0) {
        printf("Matrix-vector multiplication completed!\n");
        printf("Computation time: %.6f seconds\n", total_time);
        printf("Performance: %.2f MFLOPS\n", (2.0 * n * n) / (total_time * 1e6));
        
        // Verify result (compute first few elements)
        printf("First 5 elements of result: ");
        for (i = 0; i < 5; i++) {
            printf("%.6f ", result[i]);
        }
        printf("\n");
    }
    
    // Clean up
    free(matrix);
    free(vector);
    free(local_result);
    free(sendcounts);
    free(displs);
    
    if (rank == 0) {
        free(result);
    }
    
    MPI_Finalize();
    return 0;
}
EOF
```

### Step 8: Compile and Test Advanced Program

```bash
# Compile the advanced program
mpicc -O3 -o mpi_matrix_vector mpi_matrix_vector.c -lm

# Create job script for advanced program
cat > mpi_matrix_job.sh << 'EOF'
#!/bin/bash
#SBATCH --job-name=mpi_matrix
#SBATCH --output=mpi_matrix_%j.out
#SBATCH --error=mpi_matrix_%j.err
#SBATCH --time=00:15:00
#SBATCH --mem=4G
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=8
#SBATCH --partition=compute

# Load required modules
module purge
module load gcc/9.3.0
module load openmpi/4.0.5

# Print job information
echo "Job ID: $SLURM_JOB_ID"
echo "Nodes: $SLURM_NODELIST"
echo "Total tasks: $SLURM_NTASKS"
echo "Tasks per node: $SLURM_NTASKS_PER_NODE"
echo "Start time: $(date)"

# Run MPI matrix-vector multiplication
mpirun -np $SLURM_NTASKS ./mpi_matrix_vector

# Print completion information
echo "End time: $(date)"
echo "Job completed successfully!"
EOF

# Make job script executable
chmod +x mpi_matrix_job.sh

# Submit the job
sbatch mpi_matrix_job.sh
```

### Step 9: Create Performance Testing Script

```bash
# Create a script to test different numbers of processes
cat > performance_test.sh << 'EOF'
#!/bin/bash
#SBATCH --job-name=mpi_performance
#SBATCH --output=performance_%j.out
#SBATCH --error=performance_%j.err
#SBATCH --time=00:30:00
#SBATCH --mem=8G
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=8
#SBATCH --partition=compute

# Load required modules
module purge
module load gcc/9.3.0
module load openmpi/4.0.5

echo "=== MPI Performance Test ==="
echo "Testing different numbers of processes..."

# Test with different numbers of processes
for np in 1 2 4 8 16; do
    echo "Testing with $np processes..."
    mpirun -np $np ./mpi_matrix_vector > output_${np}procs.txt 2>&1
    
    # Extract timing information
    if [ -f "output_${np}procs.txt" ]; then
        time=$(grep "Computation time:" output_${np}procs.txt | awk '{print $3}')
        mflops=$(grep "Performance:" output_${np}procs.txt | awk '{print $2}')
        echo "Processes: $np, Time: $time s, Performance: $mflops MFLOPS"
    fi
done

echo "Performance test completed!"
EOF

chmod +x performance_test.sh
```

## Expected Output

After successful completion, you should see:

1. **Hello World output**: Messages from each MPI process
2. **Matrix-vector results**: Computation time and performance metrics
3. **Performance data**: Timing for different numbers of processes
4. **Job logs**: Various `.out` and `.err` files

## Verification

Run these commands to verify your results:

```bash
# Check if programs were compiled successfully
ls -la mpi_hello mpi_matrix_vector

# Test MPI program locally
mpirun -np 4 ./mpi_hello

# Check job outputs
cat mpi_hello_*.out
cat mpi_matrix_*.out

# Check performance results
ls -la output_*procs.txt
```

## Troubleshooting

### Compilation Issues

**Problem**: MPI compilation fails
```bash
# Check if MPI is loaded
module list

# Check MPI compiler
which mpicc
mpicc --version
```

### Runtime Issues

**Problem**: MPI program fails to run
```bash
# Check SLURM environment variables
echo $SLURM_NTASKS
echo $SLURM_NODELIST

# Test with fewer processes
mpirun -np 2 ./mpi_hello
```

### Performance Issues

**Problem**: Poor scaling
```bash
# Check if processes are distributed across nodes
# In job script, add:
mpirun --map-by node -np $SLURM_NTASKS ./mpi_matrix_vector
```

## Further Reading

- [OpenMP Programming](openmp_basics.md)
- [Hybrid OpenMP/MPI](hybrid_computing.md)
- [Performance Optimization](optimization.md)

## Next Exercise

Once you've completed this exercise successfully, proceed to:
[Exercise: Hybrid OpenMP/MPI Programming](hybrid_computing.md)

---

**Congratulations!** You've successfully learned MPI programming basics on the CHPC cluster. You can now write distributed memory parallel programs! 