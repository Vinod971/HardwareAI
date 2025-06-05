import matplotlib.pyplot as plt
import numpy as np
import random

# Step activation
def step(x):
    return 1 if x >= 0 else 0

# Predict function
def predict(x1, x2, w1, w2, bias):
    return step(w1 * x1 + w2 * x2 + bias)

# NAND data
data = np.array([
    [0, 0, 1],
    [0, 1, 1],
    [1, 0, 1],
    [1, 1, 0]
])

# Initialize
w1 = random.uniform(-1, 1)
w2 = random.uniform(-1, 1)
bias = random.uniform(-1, 1)
lr = 0.1
epochs = 30

# For plotting boundaries
boundaries = []

# Training loop
for epoch in range(epochs):
    total_error = 0
    for x1, x2, y in data:
        y_pred = predict(x1, x2, w1, w2, bias)
        error = y - y_pred
        w1 += lr * error * x1
        w2 += lr * error * x2
        bias += lr * error
        total_error += abs(error)
    if epoch % 5 == 0:
        boundaries.append((w1, w2, bias))
    if total_error == 0:
        print(f"Converged at epoch {epoch}")
        break

# Plotting
colors = ['red' if y == 0 else 'green' for _, _, y in data]
plt.figure(figsize=(8, 6))
plt.title("Perceptron Learning (NAND) Decision Boundary")

# Plot data points
for x1, x2, y in data:
    plt.scatter(x1, x2, c='green' if y == 1 else 'red', edgecolors='k', s=100)

# Draw decision boundaries
x_vals = np.linspace(-0.2, 1.2, 100)
for i, (w1, w2, b) in enumerate(boundaries):
    if w2 != 0:
        y_vals = -(w1 * x_vals + b) / w2
        plt.plot(x_vals, y_vals, label=f'Epoch {i*5}')

plt.xlabel("x1")
plt.ylabel("x2")
plt.xlim(-0.2, 1.2)
plt.ylim(-0.2, 1.2)
plt.legend()
plt.grid(True)
plt.show()

plt.savefig("nand_decision_boundary.png")
print("Plot saved as nand_decision_boundary.png")
