import time

# Basic implementation of a custom thread management system
class MyThread:
    def __init__(self, target, args=()):
        self.target = target
        self.args = args
        self.result = None
        self.thread = None

    def run(self):
        self.result = self.target(*self.args)

    def start(self):
        self.thread = time.time()
        self.run()  # Simulate thread start
        return self.thread

    def join(self):
        # Simulate waiting for the thread to finish
        while (time.time() - self.thread) < 0.1:
            pass  # Simulate work being done
        return self.result

# Quicksort with manual parallelism
def parallel_quicksort(arr):
    if len(arr) <= 1:
        return arr

    pivot = arr[-1]
    left = [x for x in arr[:-1] if x <= pivot]
    right = [x for x in arr[:-1] if x > pivot]

    # Create threads to sort the left and right subarrays concurrently
    left_thread = MyThread(target=parallel_quicksort, args=(left,))
    right_thread = MyThread(target=parallel_quicksort, args=(right,))

    # Start both threads
    left_thread.start()
    right_thread.start()

    # Wait for both threads to finish and get the results
    left_sorted = left_thread.join()
    right_sorted = right_thread.join()

    return left_sorted + [pivot] + right_sorted

# Input from user
def get_input():
    user_input = input("Enter numbers separated by commas (e.g., 10,7,8,9,1,5): ")
    try:
        arr = [int(x) for x in user_input.split(',')]
        return arr
    except ValueError:
        print("Invalid input. Please enter a list of integers.")
        return []

# Main function to execute the parallel quicksort
def main():
    arr = get_input()
    if arr:
        print("Original array:", arr)
        start_time = time.time()
        sorted_arr = parallel_quicksort(arr)
        end_time = time.time()
        print("Sorted array:", sorted_arr)
        print("Execution time:", end_time - start_time, "seconds")

if __name__ == "__main__":
    main()
