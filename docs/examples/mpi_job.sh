#!/bin/bash
#SBATCH --job-name=mpi_example
#SBATCH --output=mpi_example_%j.out
#SBATCH --error=mpi_example_%j.err
#SBATCH --time=01:00:00
#SBATCH --mem=16G
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
echo "Memory per node: $SLURM_MEM_PER_NODE"
echo "Start time: $(date)"

# Create scratch directory for temporary files
export TMPDIR=/scratch/$USER/tmp
mkdir -p $TMPDIR

# Compile MPI program (if needed)
cat > mpi_example.c << 'EOF'
#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

int main(int argc, char** argv) {
    int rank, size, i;
    double local_sum = 0.0, global_sum = 0.0;
    double start_time, end_time;
    
    // Initialize MPI
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    
    if (rank == 0) {
        printf("MPI Example: Computing Pi using Monte Carlo method\n");
        printf("Number of processes: %d\n", size);
    }
    
    // Synchronize all processes
    MPI_Barrier(MPI_COMM_WORLD);
    start_time = MPI_Wtime();
    
    // Monte Carlo Pi calculation
    int n_points = 1000000;  // Total points
    int local_points = n_points / size;
    int local_inside = 0;
    
    // Seed random number generator differently for each process
    srand(rank + 1);
    
    // Generate random points and count those inside circle
    for (i = 0; i < local_points; i++) {
        double x = (double)rand() / RAND_MAX * 2.0 - 1.0;
        double y = (double)rand() / RAND_MAX * 2.0 - 1.0;
        
        if (x*x + y*y <= 1.0) {
            local_inside++;
        }
    }
    
    // Reduce results to root process
    int global_inside;
    MPI_Reduce(&local_inside, &global_inside, 1, MPI_INT, MPI_SUM, 0, MPI_COMM_WORLD);
    
    // Calculate Pi on root process
    if (rank == 0) {
        double pi = 4.0 * (double)global_inside / n_points;
        end_time = MPI_Wtime();
        
        printf("Points inside circle: %d\n", global_inside);
        printf("Total points: %d\n", n_points);
        printf("Calculated Pi: %.10f\n", pi);
        printf("Actual Pi: %.10f\n", M_PI);
        printf("Error: %.10f\n", fabs(pi - M_PI));
        printf("Computation time: %.6f seconds\n", end_time - start_time);
        
        // Save results to file
        FILE *fp = fopen("pi_results.txt", "w");
        if (fp != NULL) {
            fprintf(fp, "MPI Pi Calculation Results\n");
            fprintf(fp, "========================\n");
            fprintf(fp, "Number of processes: %d\n", size);
            fprintf(fp, "Total points: %d\n", n_points);
            fprintf(fp, "Points inside circle: %d\n", global_inside);
            fprintf(fp, "Calculated Pi: %.10f\n", pi);
            fprintf(fp, "Actual Pi: %.10f\n", M_PI);
            fprintf(fp, "Error: %.10f\n", fabs(pi - M_PI));
            fprintf(fp, "Computation time: %.6f seconds\n", end_time - start_time);
            fclose(fp);
            printf("Results saved to pi_results.txt\n");
        }
    }
    
    // Finalize MPI
    MPI_Finalize();
    return 0;
}
EOF

# Compile the MPI program
echo "Compiling MPI program..."
mpicc -O3 -o mpi_example mpi_example.c -lm

if [ $? -eq 0 ]; then
    echo "Compilation successful!"
    
    # Run the MPI program
    echo "Running MPI program..."
    mpirun -np $SLURM_NTASKS ./mpi_example
    
    echo "MPI program completed!"
else
    echo "Compilation failed!"
    exit 1
fi

# Clean up
rm -f mpi_example.c mpi_example
rm -rf $TMPDIR

# Print completion information
echo "End time: $(date)"
echo "Job completed successfully!" 