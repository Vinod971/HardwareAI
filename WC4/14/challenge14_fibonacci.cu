
#include <iostream>
#include <cuda.h>
#include <chrono>

// CPU Fibonacci
void fibonacci_cpu(int* fib, int n) {
    fib[0] = 0;
    fib[1] = 1;
    for (int i = 2; i < n; ++i) {
        fib[i] = fib[i - 1] + fib[i - 2];
    }
}

// GPU Fibonacci Kernel
__global__ void fibonacci_gpu(int* fib, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) {
        if (i == 0) fib[i] = 0;
        else if (i == 1) fib[i] = 1;
        else {
            int a = 0, b = 1, c;
            for (int j = 2; j <= i; ++j) {
                c = a + b;
                a = b;
                b = c;
            }
            fib[i] = b;
        }
    }
}

int main() {
    const int N = 1000;
    int* h_fib_cpu = new int[N];
    int* h_fib_gpu = new int[N];

    // CPU Benchmark
    auto start_cpu = std::chrono::high_resolution_clock::now();
    fibonacci_cpu(h_fib_cpu, N);
    auto end_cpu = std::chrono::high_resolution_clock::now();
    double time_cpu = std::chrono::duration<double, std::milli>(end_cpu - start_cpu).count();

    // Allocate device memory
    int* d_fib;
    cudaMalloc((void**)&d_fib, N * sizeof(int));

    // GPU Benchmark
    auto start_gpu = std::chrono::high_resolution_clock::now();
    fibonacci_gpu<<<(N + 255)/256, 256>>>(d_fib, N);
    cudaDeviceSynchronize();
    auto end_gpu = std::chrono::high_resolution_clock::now();
    double time_gpu = std::chrono::duration<double, std::milli>(end_gpu - start_gpu).count();

    // Copy results back to host
    cudaMemcpy(h_fib_gpu, d_fib, N * sizeof(int), cudaMemcpyDeviceToHost);

    // Verify correctness
    bool match = true;
    for (int i = 0; i < N; ++i) {
        if (h_fib_cpu[i] != h_fib_gpu[i]) {
            match = false;
            break;
        }
    }

    std::cout << "CPU Time: " << time_cpu << " ms\n";
    std::cout << "GPU Time: " << time_gpu << " ms\n";
    std::cout << "Results Match: " << (match ? "Yes" : "No") << std::endl;

    // Cleanup
    delete[] h_fib_cpu;
    delete[] h_fib_gpu;
    cudaFree(d_fib);

    return 0;
}
