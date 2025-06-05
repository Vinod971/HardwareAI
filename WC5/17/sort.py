import time
import numpy as np

# Simulated systolic array Bubble Sort (1D array of comparators)
def systolic_bubble_sort(arr):
    n = len(arr)
    data = arr.copy()
    for _ in range(n):
        for i in range(1, n, 2):  # Odd phase
            if i < n and data[i - 1] > data[i]:
                data[i - 1], data[i] = data[i], data[i - 1]
        for i in range(2, n, 2):  # Even phase
            if i < n and data[i - 1] > data[i]:
                data[i - 1], data[i] = data[i], data[i - 1]
    return data

# Benchmark function
def benchmark_systolic_sort(sizes):
    results = []
    for size in sizes:
        arr = np.random.randint(0, 100000, size)
        start = time.time()
        systolic_bubble_sort(arr)
        end = time.time()
        elapsed = (end - start) * 1000  # ms
        results.append((size, elapsed))
    return results

# Define test sizes
test_sizes = [10, 100, 1000, 2000]

# Run benchmark
benchmark_results = benchmark_systolic_sort(test_sizes)

import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

# Convert to DataFrame
df = pd.DataFrame(benchmark_results, columns=["Input Size", "Execution Time (ms)"])

# Plot the results
plt.figure(figsize=(8, 5))
sns.lineplot(data=df, x="Input Size", y="Execution Time (ms)", marker="o")
plt.title("Systolic Array Bubble Sort Performance")
plt.grid(True)
plt.tight_layout()

# Save chart
systolic_chart_path = "/mnt/data/systolic_sort_chart.png"
plt.savefig(systolic_chart_path)

import ace_tools as tools; tools.display_dataframe_to_user(name="Systolic Sort Benchmark", dataframe=df)

systolic_chart_path
