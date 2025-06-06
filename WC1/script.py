import dis

# Define the function for matrix multiplication
def matrix_multiply(A, B):
    import numpy as np
    A = np.array(A)
    B = np.array(B)

    if A.shape[1] != B.shape[0]:
        raise ValueError('Number of columns in A must be equal to number of rows in B (nxm * mxp)')

    return np.dot(A, B).tolist()

# Disassemble the bytecode of the matrix_multiply function
bytecode = dis.Bytecode(matrix_multiply)

# Define counters for different types of instructions
arithmetic_instructions = 0
load_instructions = 0
store_instructions = 0
function_calls = 0

# Classify the instructions based on opcodes
for instruction in bytecode:
    if instruction.opname == 'LOAD_FAST' or instruction.opname == 'LOAD_GLOBAL' or instruction.opname == 'LOAD_ATTR':
        load_instructions += 1
    elif instruction.opname == 'STORE_FAST':
        store_instructions += 1
    elif instruction.opname == 'CALL_FUNCTION' or instruction.opname == 'CALL_METHOD':
        function_calls += 1
    elif instruction.opname in ['BINARY_ADD', 'BINARY_SUBSCR', 'COMPARE_OP', 'BINARY_MULTIPLY']:
        arithmetic_instructions += 1

# Prepare the report
report = f"""
Instruction Report for Function: matrix_multiply

Arithmetic Instructions: {arithmetic_instructions}
Load Instructions: {load_instructions}
Store Instructions: {store_instructions}
Function Calls: {function_calls}
"""

# Write the report to a text file
with open("instruction_report.txt", "w") as file:
    file.write(report)

print("Instruction report has been generated and saved to 'instruction_report.txt'.")
