#include <stdio.h>
#include <stdlib.h>
#include <math.h>

__global__
void saxpy(int n, float a, float *x, float *y)
{
  int i = blockIdx.x * blockDim.x + threadIdx.x;
  if (i < n) y[i] = a * x[i] + y[i];
}

int main(void)
{
  int N = 1 << 20; // 1 million elements
  float *x, *y, *d_x, *d_y;

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

  // Copy data from host to device
  cudaMemcpy(d_x, x, N * sizeof(float), cudaMemcpyHostToDevice);
  cudaMemcpy(d_y, y, N * sizeof(float), cudaMemcpyHostToDevice);

  // Launch SAXPY kernel on the GPU
  saxpy<<<(N + 255) / 256, 256>>>(N, 2.0f, d_x, d_y);

  // Copy result back to host
  cudaMemcpy(y, d_y, N * sizeof(float), cudaMemcpyDeviceToHost);

  // Verify result
  float maxError = 0.0f;
  for (int i = 0; i < N; i++) {
    maxError = fmax(maxError, fabs(y[i] - 4.0f));
  }
  printf("Max error: %f\n", maxError);

  // Free memory
  cudaFree(d_x);
  cudaFree(d_y);
  free(x);
  free(y);

  return 0;
}
