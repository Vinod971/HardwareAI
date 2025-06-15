import os
import random
from pathlib import Path

def generate_lstm_weights(num_cells=4, hidden_size=64, bit_width=8, output_dir="weights"):
    """
    Generate LSTM weight files for all gates of each cell
    Args:
        num_cells: Number of LSTM cells (default: 4)
        hidden_size: Size of hidden layer (default: 64)
        bit_width: Bit width of weights (default: 8)
        output_dir: Output directory (default: "weights")
    """
    # Create output directory if it doesn't exist
    Path(output_dir).mkdir(parents=True, exist_ok=True)
    
    # Generate weights for each cell and each gate
    for cell in range(num_cells):
        for gate in ['Wf', 'Wi', 'Wc', 'Wo']:
            filename = f"{output_dir}/lstm_cell{cell}_{gate}.mem"
            
            with open(filename, 'w') as f:
                # Generate 'hidden_size' random binary values
                for _ in range(hidden_size):
                    # Generate random value with proper bit width
                    value = random.getrandbits(bit_width)
                    
                    # Convert to binary string with leading zeros
                    binary_str = f"{value:0{bit_width}b}"
                    
                    # Write to file
                    f.write(binary_str + '\n')
            
            print(f"Generated {filename}")

if __name__ == "__main__":
    # Generate weights with default parameters
    generate_lstm_weights()
    
    print("\nAll weight files generated successfully!")