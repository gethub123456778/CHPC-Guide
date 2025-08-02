# Parallel Computing Guide

This guide covers advanced parallel computing techniques on the CHPC cluster, including OpenMP, MPI, and hybrid approaches.

## Overview

The CHPC cluster supports multiple parallel computing paradigms:

- **OpenMP**: Shared memory parallelism on single nodes
- **MPI**: Distributed memory parallelism across nodes
- **Hybrid**: Combination of OpenMP and MPI
- **GPU Computing**: CUDA and OpenACC

## OpenMP Programming

### Basic OpenMP Concepts

OpenMP is ideal for shared memory parallelism on a single node:

```c
#include <omp.h>
#include <stdio.h>

int main() {
    #pragma omp parallel
    {
        int thread_id = omp_get_thread_num();
        printf("Hello from thread %d\n", thread_id);
    }
    return 0;
}
```

### Compiling OpenMP Programs

```bash
# Load compiler module
module load gcc/9.3.0

# Compile with OpenMP support
gcc -fopenmp -O3 my_program.c -o my_program

# Set number of threads
export OMP_NUM_THREADS=8
```

### OpenMP Job Script

```bash
#!/bin/bash
#SBATCH --job-name=openmp_job
#SBATCH --output=openmp_job_%j.out
#SBATCH --error=openmp_job_%j.err
#SBATCH --time=01:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=8
#SBATCH --partition=compute

module load gcc/9.3.0

# Set number of OpenMP threads
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

# Run the program
./my_openmp_program
```

### OpenMP Directives

```c
// Parallel region
#pragma omp parallel
{
    // Code executed by all threads
}

// Parallel for loop
#pragma omp parallel for
for (int i = 0; i < n; i++) {
    // Loop body
}

// Parallel for with reduction
#pragma omp parallel for reduction(+:sum)
for (int i = 0; i < n; i++) {
    sum += array[i];
}

// Critical section
#pragma omp critical
{
    // Thread-safe code
}

// Atomic operation
#pragma omp atomic
counter++;
```

## MPI Programming

### Basic MPI Concepts

MPI enables distributed memory parallelism across multiple nodes:

```c
#include <mpi.h>
#include <stdio.h>

int main(int argc, char** argv) {
    int rank, size;
    
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    
    printf("Hello from process %d of %d\n", rank, size);
    
    MPI_Finalize();
    return 0;
}
```

### Compiling MPI Programs

```bash
# Load MPI module
module load openmpi/4.0.5

# Compile MPI program
mpicc -O3 my_program.c -o my_program

# Run MPI program
mpirun -np 8 ./my_program
```

### MPI Job Script

```bash
#!/bin/bash
#SBATCH --job-name=mpi_job
#SBATCH --output=mpi_job_%j.out
#SBATCH --error=mpi_job_%j.err
#SBATCH --time=02:00:00
#SBATCH --mem=16G
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=8
#SBATCH --partition=compute

module load openmpi/4.0.5

# Run MPI program
mpirun -np $SLURM_NTASKS ./my_mpi_program
```

### Common MPI Functions

```c
// Point-to-point communication
MPI_Send(buffer, count, datatype, dest, tag, comm);
MPI_Recv(buffer, count, datatype, source, tag, comm, status);

// Collective communication
MPI_Bcast(buffer, count, datatype, root, comm);
MPI_Reduce(sendbuf, recvbuf, count, datatype, op, root, comm);
MPI_Allreduce(sendbuf, recvbuf, count, datatype, op, comm);
MPI_Gather(sendbuf, sendcount, sendtype, recvbuf, recvcount, recvtype, root, comm);
MPI_Scatter(sendbuf, sendcount, sendtype, recvbuf, recvcount, recvtype, root, comm);
```

## Hybrid OpenMP/MPI

### Hybrid Programming Model

Combine OpenMP and MPI for optimal performance:

```c
#include <mpi.h>
#include <omp.h>
#include <stdio.h>

int main(int argc, char** argv) {
    int rank, size;
    
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    
    #pragma omp parallel
    {
        int thread_id = omp_get_thread_num();
        int num_threads = omp_get_num_threads();
        printf("Process %d, Thread %d of %d\n", rank, thread_id, num_threads);
    }
    
    MPI_Finalize();
    return 0;
}
```

### Hybrid Job Script

```bash
#!/bin/bash
#SBATCH --job-name=hybrid_job
#SBATCH --output=hybrid_job_%j.out
#SBATCH --error=hybrid_job_%j.err
#SBATCH --time=02:00:00
#SBATCH --mem=16G
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=4
#SBATCH --partition=compute

module load gcc/9.3.0
module load openmpi/4.0.5

# Set OpenMP threads per MPI process
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

# Run hybrid program
mpirun -np $SLURM_NTASKS --map-by node:pe=$SLURM_CPUS_PER_TASK ./hybrid_program
```

## Performance Optimization

### Profiling Tools

```bash
# Load profiling modules
module load gprof
module load valgrind

# Profile with gprof
gcc -pg -O3 my_program.c -o my_program
./my_program
gprof my_program gmon.out

# Profile with Valgrind
valgrind --tool=callgrind ./my_program
```

### Performance Monitoring

```bash
# Monitor CPU usage
top -p $SLURM_JOB_ID

# Monitor memory usage
free -h

# Monitor I/O
iotop

# Monitor network
iftop
```

### Optimization Techniques

1. **Memory Access Patterns**
   ```c
   // Good: Sequential access
   for (int i = 0; i < n; i++) {
       sum += array[i];
   }
   
   // Bad: Strided access
   for (int i = 0; i < n; i += stride) {
       sum += array[i];
   }
   ```

2. **Cache Optimization**
   ```c
   // Block matrix multiplication
   #pragma omp parallel for collapse(2)
   for (int i = 0; i < n; i += block_size) {
       for (int j = 0; j < n; j += block_size) {
           for (int k = 0; k < n; k += block_size) {
               // Process block
           }
       }
   }
   ```

3. **Load Balancing**
   ```c
   // Dynamic scheduling for irregular workloads
   #pragma omp parallel for schedule(dynamic, chunk_size)
   for (int i = 0; i < n; i++) {
       // Workload varies by iteration
   }
   ```

## GPU Computing

### CUDA Programming

```cuda
#include <cuda_runtime.h>
#include <stdio.h>

__global__ void vectorAdd(float* a, float* b, float* c, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) {
        c[i] = a[i] + b[i];
    }
}

int main() {
    // CUDA kernel launch
    int blockSize = 256;
    int numBlocks = (n + blockSize - 1) / blockSize;
    vectorAdd<<<numBlocks, blockSize>>>(d_a, d_b, d_c, n);
    
    return 0;
}
```

### GPU Job Script

```bash
#!/bin/bash
#SBATCH --job-name=gpu_job
#SBATCH --output=gpu_job_%j.out
#SBATCH --error=gpu_job_%j.err
#SBATCH --time=01:00:00
#SBATCH --mem=8G
#SBATCH --gres=gpu:1
#SBATCH --partition=gpu

module load cuda/11.0

# Run GPU program
./my_gpu_program
```

## Best Practices

### General Guidelines

1. **Start Small**: Begin with small problem sizes and few processes
2. **Profile First**: Use profiling tools to identify bottlenecks
3. **Measure Performance**: Always benchmark your optimizations
4. **Test Thoroughly**: Verify correctness before scaling up

### OpenMP Best Practices

1. **Avoid False Sharing**
   ```c
   // Good: Private variables
   #pragma omp parallel for private(temp)
   for (int i = 0; i < n; i++) {
       temp = compute(i);
       result[i] = temp;
   }
   ```

2. **Use Appropriate Scheduling**
   ```c
   // Static for regular workloads
   #pragma omp parallel for schedule(static)
   
   // Dynamic for irregular workloads
   #pragma omp parallel for schedule(dynamic)
   ```

### MPI Best Practices

1. **Minimize Communication**
   ```c
   // Batch communications
   MPI_Allreduce(local_sum, global_sum, 1, MPI_DOUBLE, MPI_SUM, MPI_COMM_WORLD);
   ```

2. **Use Non-blocking Operations**
   ```c
   MPI_Request request;
   MPI_Isend(buffer, count, MPI_DOUBLE, dest, tag, MPI_COMM_WORLD, &request);
   // Do other work while sending
   MPI_Wait(&request, MPI_STATUS_IGNORE);
   ```

### Hybrid Best Practices

1. **Balance MPI Processes and OpenMP Threads**
   ```bash
   # Example: 2 nodes, 4 MPI processes per node, 4 threads per process
   #SBATCH --nodes=2
   #SBATCH --ntasks-per-node=4
   #SBATCH --cpus-per-task=4
   ```

2. **Avoid Over-subscription**
   ```bash
   # Ensure total threads don't exceed available cores
   export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
   ```

## Troubleshooting

### Common Issues

1. **Race Conditions**
   - Use critical sections or atomic operations
   - Ensure proper synchronization

2. **Load Imbalance**
   - Use dynamic scheduling
   - Redistribute work evenly

3. **Memory Issues**
   - Check for memory leaks
   - Monitor memory usage

4. **Communication Deadlocks**
   - Ensure matching send/receive pairs
   - Use non-blocking operations carefully

### Debugging Tools

```bash
# Load debugging modules
module load gdb
module load valgrind

# Debug with GDB
gdb ./my_program

# Check for memory errors
valgrind --tool=memcheck ./my_program
```

---

**Next**: Learn about [Data Management](../data/management.md) for handling large datasets efficiently. 