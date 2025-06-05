import numpy as np

# Activation functions
def sigmoid(x):
    return 1 / (1 + np.exp(-x))

def sigmoid_derivative(x):
    return x * (1 - x)

# XOR input and output
X = np.array([
    [0, 0],
    [0, 1],
    [1, 0],
    [1, 1]
])
y = np.array([[0], [1], [1], [0]])

# Initialize weights and biases
np.random.seed(42)
input_size = 2
hidden_size = 2
output_size = 1
learning_rate = 0.5
epochs = 10000

# Weights
W1 = np.random.randn(input_size, hidden_size)
b1 = np.zeros((1, hidden_size))
W2 = np.random.randn(hidden_size, output_size)
b2 = np.zeros((1, output_size))

# Training loop
for epoch in range(epochs):
    # Forward pass
    z1 = X @ W1 + b1
    a1 = sigmoid(z1)

    z2 = a1 @ W2 + b2
    a2 = sigmoid(z2)

    # Backpropagation
    error = y - a2
    d_output = error * sigmoid_derivative(a2)
    
    error_hidden = d_output @ W2.T
    d_hidden = error_hidden * sigmoid_derivative(a1)

    # Update weights and biases
    W2 += a1.T @ d_output * learning_rate
    b2 += np.sum(d_output, axis=0, keepdims=True) * learning_rate
    W1 += X.T @ d_hidden * learning_rate
    b1 += np.sum(d_hidden, axis=0, keepdims=True) * learning_rate

    # Print loss occasionally
    if epoch % 1000 == 0:
        loss = np.mean(np.square(error))
        print(f"Epoch {epoch} Loss: {loss:.4f}")

# Test output
print("\nTrained XOR MLP Output:")
for i in range(4):
    print(f"Input: {X[i]} → Output: {a2[i][0]:.4f} → Rounded: {round(a2[i][0])}")
