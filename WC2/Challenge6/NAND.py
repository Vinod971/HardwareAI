import random

# Step activation
def step(x):
    return 1 if x >= 0 else 0

# Perceptron function
def predict(x1, x2, w1, w2, bias):
    z = w1 * x1 + w2 * x2 + bias
    return step(z)

# NAND training data
training_data = [
    (0, 0, 1),
    (0, 1, 1),
    (1, 0, 1),
    (1, 1, 0)
]

# Initialize weights and bias
w1 = random.uniform(-1, 1)
w2 = random.uniform(-1, 1)
bias = random.uniform(-1, 1)
learning_rate = 0.1
epochs = 20

# Training loop
for epoch in range(epochs):
    total_error = 0
    for x1, x2, y_true in training_data:
        y_pred = predict(x1, x2, w1, w2, bias)
        error = y_true - y_pred
        w1 += learning_rate * error * x1
        w2 += learning_rate * error * x2
        bias += learning_rate * error
        total_error += abs(error)
    if total_error == 0:
        print(f"Training converged at epoch {epoch}")
        break

# Final weights
print(f"\nFinal weights and bias for NAND:")
print(f"w1 = {w1:.2f}, w2 = {w2:.2f}, bias = {bias:.2f}")

# Test
print("\nTesting NAND Perceptron:")
for x1, x2, _ in training_data:
    print(f"Input: {x1}, {x2} → Output: {predict(x1, x2, w1, w2, bias)}")
