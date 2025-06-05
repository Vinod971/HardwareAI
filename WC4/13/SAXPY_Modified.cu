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

int main(void)
{
    for (int power = 15; power <= 25; ++power) {
        int N = 1 << power;
        size_t size = N * sizeof(float);
        float *x, *y, *d_x, *d_y;

        // Allocate host memory
        x = (float*)malloc(size);
        y = (float*)malloc(size);

        // Initialize host arrays
        for (int i = 0; i < N; i++) {
            x[i] = 1.0f;
            y[i] = 2.0f;
        }

        // Allocate device memory
        cudaMalloc(&d_x, size);
        cudaMalloc(&d_y, size);

        // Copy data from host to device
        cudaMemcpy(d_x, x, size, cudaMemcpyHostToDevice);
        cudaMemcpy(d_y, y, size, cudaMemcpyHostToDevice);

        // Setup CUDA events for timing
        cudaEvent_t start, stop;
        cudaEventCreate(&start);
        cudaEventCreate(&stop);

        // Launch SAXPY kernel and time it
        cudaEventRecord(start);
        saxpy<<<(N + 255) / 256, 256>>>(N, 2.0f, d_x, d_y);
        cudaEventRecord(stop);

        // Wait for kernel to finish and measure elapsed time
        cudaEventSynchronize(stop);
        float milliseconds = 0;
        cudaEventElapsedTime(&milliseconds, start, stop);

        // Output result
        printf("N = 2^%d (%d): Execution Time = %.3f ms\n", power, N, milliseconds);

        // Cleanup
        cudaEventDestroy(start);
        cudaEventDestroy(stop);
        cudaFree(d_x);
        cudaFree(d_y);
        free(x);
        free(y);
    }

    return 0;
}
