#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <cuda_runtime.h>

__global__
void saxpy(int n, float a, float *x, float *y)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) y[i] = a * x[i] + y[i];
}

void run_saxpy(int N) {
    float *x, *y, *d_x, *d_y;
    cudaEvent_t start, stop, memoryStart, memoryStop, kernelStart, kernelStop;

    // Allocate host memory
    x = (float*)malloc(N * sizeof(float));
    y = (float*)malloc(N * sizeof(float));

    // Initialize host arrays
    for (int i = 0; i < N; i++) {
        x[i] = 1.0f;
        y[i] = 2.0f;
    }

    // Allocate device memory
    cudaMalloc(&d_x, N * sizeof(float));
    cudaMalloc(&d_y, N * sizeof(float));

    // Create events to measure time
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventCreate(&memoryStart);
    cudaEventCreate(&memoryStop);
    cudaEventCreate(&kernelStart);
    cudaEventCreate(&kernelStop);

    // Record the start event
    cudaEventRecord(start);

    // Measure memory allocation and transfer time
    cudaEventRecord(memoryStart);

    // Copy data from host to device
    cudaMemcpy(d_x, x, N * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_y, y, N * sizeof(float), cudaMemcpyHostToDevice);

    cudaEventRecord(memoryStop);
    cudaEventSynchronize(memoryStop);

    // Measure kernel execution time
    cudaEventRecord(kernelStart);

    // Launch SAXPY kernel on the GPU
    saxpy<<<(N + 255) / 256, 256>>>(N, 2.0f, d_x, d_y);

    cudaEventRecord(kernelStop);
    cudaEventSynchronize(kernelStop);

    // Record the stop event
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    // Calculate the elapsed times
    float totalMilliseconds = 0;
    float memoryMilliseconds = 0;
    float kernelMilliseconds = 0;

    cudaEventElapsedTime(&totalMilliseconds, start, stop);
    cudaEventElapsedTime(&memoryMilliseconds, memoryStart, memoryStop);
    cudaEventElapsedTime(&kernelMilliseconds, kernelStart, kernelStop);

    printf("Execution time for N=%d:\n", N);
    printf("  Total time: %f ms\n", totalMilliseconds);
    printf("  Memory transfer time: %f ms\n", memoryMilliseconds);
    printf("  GPU computation time (kernel): %f ms\n", kernelMilliseconds);

    // Free memory
    cudaFree(d_x);
    cudaFree(d_y);
    free(x);
    free(y);

    // Destroy events
    cudaEventDestroy(start);
    cudaEventDestroy(stop);
    cudaEventDestroy(memoryStart);
    cudaEventDestroy(memoryStop);
    cudaEventDestroy(kernelStart);
    cudaEventDestroy(kernelStop);
}

int main(void)
{
    // Matrix sizes: N = 2^15, 2^16, ..., 2^25
    int sizes[] = { 1 << 15, 1 << 16, 1 << 17, 1 << 18, 1 << 19, 1 << 20, 1 << 21, 1 << 22, 1 << 23, 1 << 24, 1 << 25 };
    int num_sizes = sizeof(sizes) / sizeof(sizes[0]);

    // Run SAXPY for each matrix size
    for (int i = 0; i < num_sizes; i++) {
        run_saxpy(sizes[i]);
    }

    return 0;
}
