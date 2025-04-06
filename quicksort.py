import py_compile
import dis
import cProfile

# Quicksort implementation
def quicksort(arr):
    if len(arr) <= 1:
        return arr
    pivot = arr[-1]
    left = [x for x in arr[:-1] if x <= pivot]
    right = [x for x in arr[:-1] if x > pivot]
    return quicksort(left) + [pivot] + quicksort(right)

# Step 1: Compile the Python script to bytecode
def compile_to_bytecode():
    py_compile.compile('quicksort.py')  # Replace with your filename

# Step 2: Disassemble the bytecode of the quicksort function
def disassemble_bytecode():
    print("Disassembling quicksort function:")
    dis.dis(quicksort)

# Step 3: Count arithmetic instructions in the quicksort function
def count_arithmetic_instructions():
    arithmetic_ops = ['BINARY_ADD', 'BINARY_SUBTRACT', 'BINARY_MULTIPLY', 'BINARY_DIVIDE']
    instruction_count = {op: 0 for op in arithmetic_ops}

    for instruction in dis.get_instructions(quicksort):
        if instruction.opname in arithmetic_ops:
            instruction_count[instruction.opname] += 1

    return instruction_count

# Step 4: Profile the execution of quicksort
def profile_execution(arr):
    print("Profiling quicksort execution:")
    cProfile.run(f'quicksort({arr})')

# Step 5: Main function to execute all steps with user input
def main():
    # Step 1: Get user input for the array
    user_input = input("Enter numbers separated by commas (e.g., 10,7,8,9,1,5): ")
    
    # Convert user input into a list of integers
    try:
        arr = [int(x) for x in user_input.split(',')]
    except ValueError:
        print("Invalid input. Please enter a list of integers.")
        return

    # Step 2: Compile the Python code to bytecode
    print("Compiling Python code to bytecode...")
    compile_to_bytecode()

    # Step 3: Disassemble the bytecode to inspect instructions
    disassemble_bytecode()

    # Step 4: Count arithmetic operations in the bytecode
    arithmetic_count = count_arithmetic_instructions()
    print("Arithmetic Instruction Counts:", arithmetic_count)

    # Step 5: Profile the execution of quicksort with user input
    profile_execution(arr)

    # Step 6: Sort the array using quicksort and display the result
    sorted_arr = quicksort(arr)
    print("Sorted array:", sorted_arr)

# Run the program
if __name__ == "__main__":
    main()
