import numpy as np

# Function to manually compute matrix multiplication
def manual_matrix_multiplication(A, B):
    # Get dimensions of A and B
    rows_A, cols_A = A.shape
    rows_B, cols_B = B.shape

    # Check if multiplication is possible (A's columns must be equal to B's rows)
    if cols_A != rows_B:
        raise ValueError("Number of columns of A must be equal to number of rows of B.")
    
    # Initialize the result matrix with zeros
    C = np.zeros((rows_A, cols_B))
    
    # Perform matrix multiplication manually using nested loops
    for i in range(rows_A):
        for j in range(cols_B):
            # Calculate dot product for element C[i][j]
            C[i, j] = np.dot(A[i, :], B[:, j])  # Dot product of row i of A and column j of B
    
    return C

# Function to get matrix input from user
def get_matrix_input():
    rows = int(input("Enter number of rows: "))
    cols = int(input("Enter number of columns: "))
    
    matrix = []
    print(f"Enter elements of the {rows}x{cols} matrix:")
    for i in range(rows):
        row = list(map(int, input(f"Enter row {i+1} (space-separated): ").split()))
        if len(row) != cols:
            print(f"Row must have {cols} elements, try again.")
            return get_matrix_input()  # Recursive call if input is invalid
        matrix.append(row)
    
    return np.array(matrix)

if __name__ == "__main__":
    # Get matrix A from user
    print("Matrix A:")
    A = get_matrix_input()

    # Get matrix B from user
    print("Matrix B:")
    B = get_matrix_input()

    # Perform manual matrix multiplication
    try:
        result = manual_matrix_multiplication(A, B)
        print("Resultant Matrix C:")
        print(result)
    except ValueError as e:
        print(e)
