import py_compile
import dis
import cProfile
import tensorflow as tf
from tensorflow.keras import layers, models
import numpy as np
from tensorflow.keras.datasets import mnist
import time
import os

# Step 1: Define a simple CNN model
def create_cnn_model(input_shape=(28, 28, 1), num_classes=10):
    model = models.Sequential()
    model.add(layers.Conv2D(32, (3, 3), activation='relu', input_shape=input_shape))
    model.add(layers.MaxPooling2D((2, 2)))
    model.add(layers.Conv2D(64, (3, 3), activation='relu'))
    model.add(layers.MaxPooling2D((2, 2)))
    model.add(layers.Conv2D(64, (3, 3), activation='relu'))
    model.add(layers.Flatten())
    model.add(layers.Dense(64, activation='relu'))
    model.add(layers.Dense(num_classes, activation='softmax'))
    model.compile(optimizer='adam',
                  loss='sparse_categorical_crossentropy',
                  metrics=['accuracy'])
    return model

# Step 2: Load dataset (MNIST as an example)
def load_data():
    (train_images, train_labels), (test_images, test_labels) = mnist.load_data()
    train_images = train_images.reshape((train_images.shape[0], 28, 28, 1)).astype('float32') / 255
    test_images = test_images.reshape((test_images.shape[0], 28, 28, 1)).astype('float32') / 255
    return (train_images, train_labels), (test_images, test_labels)

# Step 3: Compile the current Python script to bytecode
def compile_to_bytecode():
    script_name = os.path.basename(__file__)  # Get the current script name
    py_compile.compile(script_name)  # Compile the current script

# Step 4: Disassemble the bytecode of the CNN model code
def disassemble_bytecode():
    print("Disassembling create_cnn_model function:")
    dis.dis(create_cnn_model)

# Step 5: Count arithmetic instructions in the CNN model code
def count_arithmetic_instructions():
    arithmetic_ops = ['BINARY_ADD', 'BINARY_SUBTRACT', 'BINARY_MULTIPLY', 'BINARY_DIVIDE']
    instruction_count = {op: 0 for op in arithmetic_ops}

    for instruction in dis.get_instructions(create_cnn_model):
        if instruction.opname in arithmetic_ops:
            instruction_count[instruction.opname] += 1

    return instruction_count

# Step 6: Profile the execution of CNN training
def profile_execution(model, train_images, train_labels):
    print("Profiling CNN training execution:")
    start_time = time.time()
    model.fit(train_images, train_labels, epochs=5, batch_size=64)
    end_time = time.time()
    print(f"Training time: {end_time - start_time:.2f} seconds")

# Step 7: Main function to execute all steps with user input for training
def main():
    # Step 1: Get user input for number of epochs and batch size
    epochs = int(input("Enter the number of epochs for training (e.g., 5): "))
    batch_size = int(input("Enter the batch size for training (e.g., 64): "))

    # Step 2: Load the dataset (MNIST example)
    (train_images, train_labels), (test_images, test_labels) = load_data()

    # Step 3: Create the CNN model
    model = create_cnn_model(input_shape=(28, 28, 1), num_classes=10)
    model.summary()  # Display model architecture

    # Step 4: Compile the current Python code to bytecode
    print("Compiling Python code to bytecode...")
    compile_to_bytecode()

    # Step 5: Disassemble the bytecode to inspect instructions
    disassemble_bytecode()

    # Step 6: Count arithmetic operations in the bytecode
    arithmetic_count = count_arithmetic_instructions()
    print("Arithmetic Instruction Counts:", arithmetic_count)

    # Step 7: Profile the execution of CNN training with user input
    profile_execution(model, train_images, train_labels)

    # Step 8: Train the CNN model with the user-provided number of epochs and batch size
    model.fit(train_images, train_labels, epochs=epochs, batch_size=batch_size)

    # Step 9: Evaluate the model on the test set
    test_loss, test_acc = model.evaluate(test_images, test_labels)
    print(f"Test accuracy: {test_acc:.4f}")

# Run the program
if __name__ == "__main__":
    main()
