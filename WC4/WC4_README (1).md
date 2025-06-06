# WC4 - Week 4 Challenges

This folder focuses on CUDA programming for benchmarking and numerical computing.

---

## ⚙️ Challenge 13: SAXPY Benchmarking with CUDA

**Description**:
- Implement the SAXPY operation using CUDA.
- Modify and profile for different input sizes.
- Visualize performance across problem scales.

**Files**:
- `SAXPY.cu`, `SAXPY_Modified.cu`, `SAXPY_UPDATED.cu`: Different versions of SAXPY CUDA implementation.
- `BAR.py`: Python script to generate performance bar chart.
- `plot.png`: Visual output of benchmark.
- `Challenge13_SAXPY_Benchmark_Report.pdf`: Report summarizing benchmark and insights.

**How to Run**:
1. Compile CUDA code:
   ```bash
   nvcc SAXPY_UPDATED.cu -o saxpy
   ./saxpy
   ```
2. Plot results:
   ```bash
   python BAR.py
   ```

**Platform Recommendation**: Local machine with NVIDIA GPU or Google Colab with GPU runtime.

---

## 🔢 Challenge 14: Fibonacci Sequence in CUDA

**Description**:
- Implement Fibonacci number generation using CUDA.
- Compare CUDA vs CPU implementation (in analysis).

**Files**:
- `challenge14_fibonacci.cu`: CUDA implementation.
- `Challenge14_Fibonacci_Report.pdf`: Report with analysis and simulated benchmarks.

**How to Run**:
```bash
nvcc challenge14_fibonacci.cu -o fib
./fib
```

**Platform Recommendation**: Local CUDA-capable system or Google Colab with CUDA runtime.

---

Use `nvcc` (NVIDIA CUDA compiler) and Python 3.8+ with matplotlib for visualization.
