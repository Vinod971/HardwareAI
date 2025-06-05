# Step 1: Check GPU availability
import torch
print(f"PyTorch version: {torch.__version__}")
print(f"CUDA available: {torch.cuda.is_available()}")
print(f"GPU: {torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'None'}")

# Step 2: Define the neural network
class NeuralNetwork(torch.nn.Module):
    def __init__(self):
        super().__init__()
        self.hidden = torch.nn.Linear(4, 5)  # 4 inputs → 5 hidden neurons
        self.output = torch.nn.Linear(5, 1)   # 5 hidden → 1 output
        
        # Initialize weights similarly to your CUDA version
        torch.nn.init.uniform_(self.hidden.weight, -1, 1)
        torch.nn.init.uniform_(self.hidden.bias, -1, 1)
        torch.nn.init.uniform_(self.output.weight, -1, 1)
        torch.nn.init.uniform_(self.output.bias, -1, 1)
    
    def forward(self, x):
        x = torch.sigmoid(self.hidden(x))
        x = torch.sigmoid(self.output(x))
        return x

# Step 3: Create and move to GPU
device = 'cuda' if torch.cuda.is_available() else 'cpu'
model = NeuralNetwork().to(device)

# Step 4: Run a forward pass with your example input
input_data = [0.1, 0.2, 0.3, 0.4]
input_tensor = torch.tensor(input_data, dtype=torch.float32).to(device)

with torch.no_grad():  # Inference mode (no gradients needed)
    output = model(input_tensor)

# Step 5: Print results
print(f"\nInput: {input_data}")
print(f"Output: {output.item():.6f}")

# (Optional) Print weights to compare with CUDA version
print("\nHidden layer weights:")
print(model.hidden.weight)
print("\nHidden layer biases:")
print(model.hidden.bias)