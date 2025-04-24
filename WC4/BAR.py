import matplotlib.pyplot as plt

# Matrix sizes
sizes = [2**15, 2**16, 2**17, 2**18, 2**19, 2**20, 2**21, 2**22, 2**23, 2**24, 2**25]

# Execution times (replace these values with the actual times from your output)
execution_times = [
    11.806, 0.002, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003, 0.003  # Example times in milliseconds
]


# Create a bar plot
plt.figure(figsize=(10,6))
plt.bar(sizes, execution_times, width=50000, color='b', alpha=0.7)

# Set the labels and title
plt.xlabel('Matrix Size (N)')
plt.ylabel('Execution Time (ms)')
plt.title('SAXPY Execution Time vs Matrix Size')

# Show the plot
plt.xscale('log', base=2)  # Log scale for x-axis
plt.show()
