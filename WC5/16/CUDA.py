%%writefile neural_network.cu
#include <iostream>
#include <cmath>
#include <cstdlib>
#include <ctime>
#include <cuda_runtime.h>

// CUDA error checking macro
#define CUDA_CHECK(call) \
do { \
    cudaError_t err = call; \
    if (err != cudaSuccess) { \
        std::cerr << "CUDA error at " << __FILE__ << ":" << __LINE__ \
                  << ": " << cudaGetErrorString(err) << std::endl; \
        exit(EXIT_FAILURE); \
    } \
} while (0)

// Neural network dimensions
const int INPUT_SIZE = 4;
const int HIDDEN_SIZE = 5;
const int OUTPUT_SIZE = 1;

// Activation function (sigmoid)
__device__ float sigmoid(float x) {
    return 1.0f / (1.0f + expf(-x));
}

// Forward pass kernel for hidden layer
__global__ void hiddenLayerForward(const float* input, const float* weights, 
                                  float* hidden_output, int input_size, int hidden_size) {
    int neuron_idx = blockIdx.x * blockDim.x + threadIdx.x;
    
    if (neuron_idx < hidden_size) {
        float sum = 0.0f;
        for (int i = 0; i < input_size; i++) {
            sum += input[i] * weights[neuron_idx * input_size + i];
        }
        // Apply bias (last weight) and activation
        sum += weights[hidden_size * input_size + neuron_idx]; // bias
        hidden_output[neuron_idx] = sigmoid(sum);
    }
}

// Forward pass kernel for output layer
__global__ void outputLayerForward(const float* hidden_output, const float* weights, 
                                  float* output, int hidden_size, int output_size) {
    int neuron_idx = blockIdx.x * blockDim.x + threadIdx.x;
    
    if (neuron_idx < output_size) {
        float sum = 0.0f;
        for (int i = 0; i < hidden_size; i++) {
            sum += hidden_output[i] * weights[neuron_idx * hidden_size + i];
        }
        // Apply bias (last weight) and activation
        sum += weights[output_size * hidden_size + neuron_idx]; // bias
        output[neuron_idx] = sigmoid(sum);
    }
}

class NeuralNetwork {
private:
    // Host (CPU) pointers
    float* h_input;
    float* h_hidden_weights;
    float* h_output_weights;
    float* h_hidden_output;
    float* h_output;
    
    // Device (GPU) pointers
    float* d_input;
    float* d_hidden_weights;
    float* d_output_weights;
    float* d_hidden_output;
    float* d_output;
    
public:
    NeuralNetwork() {
        // Allocate host memory
        h_input = new float[INPUT_SIZE];
        h_hidden_weights = new float[HIDDEN_SIZE * (INPUT_SIZE + 1)]; // +1 for biases
        h_output_weights = new float[OUTPUT_SIZE * (HIDDEN_SIZE + 1)]; // +1 for biases
        h_hidden_output = new float[HIDDEN_SIZE];
        h_output = new float[OUTPUT_SIZE];
        
        // Initialize weights randomly
        std::srand(std::time(0));
        for (int i = 0; i < HIDDEN_SIZE * (INPUT_SIZE + 1); i++) {
            h_hidden_weights[i] = (float)std::rand() / RAND_MAX * 2.0f - 1.0f;
        }
        for (int i = 0; i < OUTPUT_SIZE * (HIDDEN_SIZE + 1); i++) {
            h_output_weights[i] = (float)std::rand() / RAND_MAX * 2.0f - 1.0f;
        }
        
        // Allocate device memory
        CUDA_CHECK(cudaMalloc(&d_input, INPUT_SIZE * sizeof(float)));
        CUDA_CHECK(cudaMalloc(&d_hidden_weights, HIDDEN_SIZE * (INPUT_SIZE + 1) * sizeof(float)));
        CUDA_CHECK(cudaMalloc(&d_output_weights, OUTPUT_SIZE * (HIDDEN_SIZE + 1) * sizeof(float)));
        CUDA_CHECK(cudaMalloc(&d_hidden_output, HIDDEN_SIZE * sizeof(float)));
        CUDA_CHECK(cudaMalloc(&d_output, OUTPUT_SIZE * sizeof(float)));
        
        // Copy weights to device
        CUDA_CHECK(cudaMemcpy(d_hidden_weights, h_hidden_weights, 
                             HIDDEN_SIZE * (INPUT_SIZE + 1) * sizeof(float), 
                             cudaMemcpyHostToDevice));
        CUDA_CHECK(cudaMemcpy(d_output_weights, h_output_weights, 
                             OUTPUT_SIZE * (HIDDEN_SIZE + 1) * sizeof(float), 
                             cudaMemcpyHostToDevice));
    }
    
    ~NeuralNetwork() {
        // Free host memory
        delete[] h_input;
        delete[] h_hidden_weights;
        delete[] h_output_weights;
        delete[] h_hidden_output;
        delete[] h_output;
        
        // Free device memory
        CUDA_CHECK(cudaFree(d_input));
        CUDA_CHECK(cudaFree(d_hidden_weights));
        CUDA_CHECK(cudaFree(d_output_weights));
        CUDA_CHECK(cudaFree(d_hidden_output));
        CUDA_CHECK(cudaFree(d_output));
    }
    
    float* forward(const float* input) {
        // Copy input to device
        CUDA_CHECK(cudaMemcpy(d_input, input, INPUT_SIZE * sizeof(float), cudaMemcpyHostToDevice));
        
        // Launch hidden layer kernel
        dim3 blockSize(16);
        dim3 gridSize((HIDDEN_SIZE + blockSize.x - 1) / blockSize.x);
        hiddenLayerForward<<<gridSize, blockSize>>>(d_input, d_hidden_weights, 
                                                  d_hidden_output, INPUT_SIZE, HIDDEN_SIZE);
        CUDA_CHECK(cudaGetLastError());
        CUDA_CHECK(cudaDeviceSynchronize());
        
        // Launch output layer kernel
        gridSize = dim3((OUTPUT_SIZE + blockSize.x - 1) / blockSize.x);
        outputLayerForward<<<gridSize, blockSize>>>(d_hidden_output, d_output_weights, 
                                                  d_output, HIDDEN_SIZE, OUTPUT_SIZE);
        CUDA_CHECK(cudaGetLastError());
        CUDA_CHECK(cudaDeviceSynchronize());
        
        // Copy results back to host
        CUDA_CHECK(cudaMemcpy(h_output, d_output, OUTPUT_SIZE * sizeof(float), cudaMemcpyDeviceToHost));
        
        return h_output;
    }
    
    void printWeights() {
        std::cout << "Hidden Layer Weights:" << std::endl;
        for (int i = 0; i < HIDDEN_SIZE; i++) {
            for (int j = 0; j < INPUT_SIZE; j++) {
                std::cout << h_hidden_weights[i * INPUT_SIZE + j] << " ";
            }
            std::cout << "| Bias: " << h_hidden_weights[HIDDEN_SIZE * INPUT_SIZE + i] << std::endl;
        }
        
        std::cout << "\nOutput Layer Weights:" << std::endl;
        for (int i = 0; i < OUTPUT_SIZE; i++) {
            for (int j = 0; j < HIDDEN_SIZE; j++) {
                std::cout << h_output_weights[i * HIDDEN_SIZE + j] << " ";
            }
            std::cout << "| Bias: " << h_output_weights[OUTPUT_SIZE * HIDDEN_SIZE + i] << std::endl;
        }
    }
};

int main() {
    NeuralNetwork nn;
    
    // Example input
    float input[INPUT_SIZE] = {0.1f, 0.2f, 0.3f, 0.4f};
    
    // Perform forward pass
    float* output = nn.forward(input);
    
    // Print results
    std::cout << "Input: ";
    for (int i = 0; i < INPUT_SIZE; i++) {
        std::cout << input[i] << " ";
    }
    std::cout << "\nOutput: " << output[0] << std::endl;
    
    return 0;
}