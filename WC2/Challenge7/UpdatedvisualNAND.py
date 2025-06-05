import matplotlib.pyplot as plt
import numpy as np
import random
import matplotlib.animation as animation

# Step activation function
def step(x):
    return 1 if x >= 0 else 0

# Predict function
def predict(x1, x2, w1, w2, bias):
    return step(w1 * x1 + w2 * x2 + bias)

# NAND data (input and output)
data = np.array([
    [0, 0, 1],
    [0, 1, 1],
    [1, 0, 1],
    [1, 1, 0]
])

# Initialize random weights and bias
w1 = random.uniform(-1, 1)
w2 = random.uniform(-1, 1)
bias = random.uniform(-1, 1)
lr = 0.1
epochs = 30

# For storing boundaries
boundaries = []

# Training loop with weight updates
for epoch in range(epochs):
    total_error = 0
    for x1, x2, y in data:
        y_pred = predict(x1, x2, w1, w2, bias)
        error = y - y_pred
        w1 += lr * error * x1
        w2 += lr * error * x2
        bias += lr * error
        total_error += abs(error)
    if epoch % 5 == 0:  # Store boundary every 5 epochs
        boundaries.append((w1, w2, bias))
    if total_error == 0:
        print(f"Converged at epoch {epoch}")
        break

# Visualization with animation
fig, ax = plt.subplots(figsize=(8, 6))
ax.set_xlim(-0.2, 1.2)
ax.set_ylim(-0.2, 1.2)

# Plot data points (NAND: red = 0, green = 1)
colors = ['red' if y == 0 else 'green' for _, _, y in data]
for x1, x2, y in data:
    ax.scatter(x1, x2, c='green' if y == 1 else 'red', edgecolors='k', s=100)

# Line plot function for updating the decision boundary
def update_line(epoch):
    ax.clear()
    for x1, x2, y in data:
        ax.scatter(x1, x2, c='green' if y == 1 else 'red', edgecolors='k', s=100)
    if epoch < len(boundaries):
        w1, w2, b = boundaries[epoch]
        x_vals = np.linspace(-0.2, 1.2, 100)
        y_vals = -(w1 * x_vals + b) / w2
        ax.plot(x_vals, y_vals, label=f'Epoch {epoch * 5}', color='blue')
    ax.set_xlim(-0.2, 1.2)
    ax.set_ylim(-0.2, 1.2)
    ax.set_title("Perceptron Learning (NAND) Decision Boundary")
    ax.set_xlabel("x1")
    ax.set_ylabel("x2")
    ax.legend()
    ax.grid(True)

# Animation function
ani = animation.FuncAnimation(fig, update_line, frames=range(len(boundaries)), repeat=False)

# Show or save the animation
plt.show()

# To save as a .mp4 file (optional):
ani.save('nand_learning_animation.gif', writer='pillow', fps=1)

