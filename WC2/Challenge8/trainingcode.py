import numpy as np

# Sigmoid activation function
def sigmoid(x):
    return 1 / (1 + np.exp(-x))

# Derivative of sigmoid function
def sigmoid_derivative(x):
    return x * (1 - x)

# Initialize the network architecture
input_neurons = 2  # Two input neurons
hidden_neurons = 2  # Two hidden neurons
output_neurons = 1  # One output neuron

# Seed for reproducibility
np.random.seed(1)

# Randomly initialize weights and biases
# Weights from input layer to hidden layer (2 inputs -> 2 hidden neurons)
weights_input_hidden = np.random.rand(input_neurons, hidden_neurons)
bias_hidden = np.random.rand(1, hidden_neurons)

# Weights from hidden layer to output layer (2 hidden neurons -> 1 output neuron)
weights_hidden_output = np.random.rand(hidden_neurons, output_neurons)
bias_output = np.random.rand(1, output_neurons)

# Training data: XOR function (input and output)
inputs = np.array([[0, 0],
                   [0, 1],
                   [1, 0],
                   [1, 1]])

# Expected output (for XOR)
outputs = np.array([[0],
                    [1],
                    [1],
                    [0]])

# Learning rate
learning_rate = 0.1

# Training loop (Epochs)
epochs = 10000
for epoch in range(epochs):
    # Forward propagation
    # Hidden layer activation
    hidden_layer_input = np.dot(inputs, weights_input_hidden) + bias_hidden
    hidden_layer_output = sigmoid(hidden_layer_input)

    # Output layer activation
    output_layer_input = np.dot(hidden_layer_output, weights_hidden_output) + bias_output
    output_layer_output = sigmoid(output_layer_input)

    # Calculate error (Mean Squared Error)
    error = outputs - output_layer_output
    if epoch % 1000 == 0:
        print(f"Epoch {epoch}, Error: {np.mean(np.abs(error))}")

    # Backpropagation
    # Output layer error term (delta)
    output_layer_error = error * sigmoid_derivative(output_layer_output)

    # Hidden layer error term (delta)
    hidden_layer_error = output_layer_error.dot(weights_hidden_output.T) * sigmoid_derivative(hidden_layer_output)

    # Update weights and biases using the gradient descent
    weights_hidden_output += hidden_layer_output.T.dot(output_layer_error) * learning_rate
    bias_output += np.sum(output_layer_error, axis=0, keepdims=True) * learning_rate

    weights_input_hidden += inputs.T.dot(hidden_layer_error) * learning_rate
    bias_hidden += np.sum(hidden_layer_error, axis=0, keepdims=True) * learning_rate

# Output final results after training
print("Final Output after training:")
hidden_layer_input = np.dot(inputs, weights_input_hidden) + bias_hidden
hidden_layer_output = sigmoid(hidden_layer_input)
output_layer_input = np.dot(hidden_layer_output, weights_hidden_output) + bias_output
output_layer_output = sigmoid(output_layer_input)

print(output_layer_output)
