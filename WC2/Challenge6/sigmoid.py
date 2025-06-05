import math

# Sigmoid activation function
def sigmoid(x):
    return 1 / (1 + math.exp(-x))

# Simple neuron (perceptron) with 2 inputs
def neuron(x1, x2, w1, w2, bias):
    z = w1 * x1 + w2 * x2 + bias
    return sigmoid(z)

# Get user input
x1 = float(input("Enter value for x1: "))
x2 = float(input("Enter value for x2: "))
w1 = float(input("Enter weight w1: "))
w2 = float(input("Enter weight w2: "))
bias = float(input("Enter bias: "))

# Compute output
output = neuron(x1, x2, w1, w2, bias)
print(f"\nNeuron output: {output:.4f}")
