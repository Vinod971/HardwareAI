# WC5 - Week 5 Challenges

This folder includes benchmarking and algorithm simulation challenges using CUDA and systolic arrays.

---

## 🔧 Challenge 16: Benchmarking SAXPY with PyTorch vs CUDA

**Description**:
- Compare a small feedforward neural network implemented in:
  - Raw CUDA (`CUDA.py`)
  - PyTorch (`pytorch.py`)
- Benchmark both and visualize execution time.

**Files**:
- `CUDA.py`: Neural network forward pass in CUDA.
- `pytorch.py`: PyTorch-based implementation.
- `download.png`: Benchmark result chart.
- `Challenge16_Report_with_Chart.pdf`: Summary and comparison.

**How to Run**:
```bash
python CUDA.py
python pytorch.py
```

**Platform Recommendation**: Local machine with NVIDIA GPU or Google Colab with GPU runtime.

---

## 🔃 Challenge 17: Bubble Sort Using a Systolic Array

**Description**:
- Simulate a bubble sort using a systolic array architecture.
- Analyze and plot sorting time for varying input sizes.

**Files**:
- `sort.py`: Python implementation and timing benchmark.
- `Challenge17_Systolic_Sort_Report.pdf`: Report with performance chart and analysis.

**How to Run**:
```bash
python sort.py
```

**Platform Recommendation**: Local machine or Google Colab (for visualization support)

---

Ensure Python 3.8+ and install required packages such as `matplotlib`, `numpy` if missing.
