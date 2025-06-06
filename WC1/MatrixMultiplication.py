import cProfile
import numpy as np
import time

def matrix_multiplication(A, B):
    A, B = np.array(A), np.array(B)
    if A.shape[1] != B.shape[0]:
        raise ValueError("Number of columns in A must be equal to number of rows in B (nxm * mxp)")
    return np.dot(A, B).tolist()

if __name__ == "__main__":
    n = int(input("Enter the number of rows for matrix A: "))
    m = int(input("Enter the number of columns for matrix A (and rows for B): "))
    p = int(input("Enter the number of columns for matrix B: "))
    
    print("Enter elements of matrix A:")
    A = [[int(input(f"A[{i}][{j}]: ")) for j in range(m)] for i in range(n)]
    
    print("Enter elements of matrix B:")
    B = [[int(input(f"B[{i}][{j}]: ")) for j in range(p)] for i in range(m)]
    
    # Profiling the matrix multiplication with cProfile
    command = """matrix_multiplication(A, B)"""
    cProfile.runctx(command, globals(), locals(), filename="matrix_multiplication.profile")
    
    # Now execute the matrix multiplication and track the time
    start_time = time.time()
    result = matrix_multiplication(A, B)
    end_time = time.time()
    elapsed_time = end_time - start_time
    
    print("Resultant Matrix:")
    for row in result:
        print(row)
    print('Execution time:', elapsed_time, 'seconds')
