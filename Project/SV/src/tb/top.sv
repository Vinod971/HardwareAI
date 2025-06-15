`timescale 1ns/1ps

module top;
    // Parameters
    parameter N = 8;                // Data width
    parameter ROWS = 402;           // MFCC rows
    parameter COLUMNS = 26;         // MFCC columns
    parameter W_COL = 128;          // Weight columns
    parameter HIDDEN_SIZE = 64;     // LSTM hidden size
    parameter NUM_LSTM_CELLS = 4;   // Number of LSTM cells
    
    // File Path Configuration - USING ABSOLUTE PATHS
    parameter string DATA_DIR = "/home/vinodk/Documents/HardwareAI/Project/Project/LSTMdesign.sv/data/";
    parameter string MFCC_FILE = "mfcc_bitstream_output.txt";
    parameter string WEIGHT_FILE = "weights_binary.txt";
    parameter string LSTM_WEIGHT_DIR = "weights/";
    
    // Derived Paths
    parameter string MFCC_PATH = {DATA_DIR, MFCC_FILE};
    parameter string WEIGHT_PATH = {DATA_DIR, WEIGHT_FILE};
    parameter string LSTM_WEIGHT_PREFIX = {DATA_DIR, LSTM_WEIGHT_DIR, "lstm_cell"};
    
    // Control Signals
    reg Reset;
    reg Start;
    bit Clock = '1;
    wire Ready;
    bit Error;
    
    // Data Path
    reg [N-1:0] Multiplicand, Multiplier;
    wire [2*N-1:0] Product;
    
    // Memory Arrays
    logic signed [N-1:0] M1 [0:ROWS-1][0:COLUMNS-1];  // MFCC data
    logic signed [N-1:0] W1 [0:COLUMNS-1][0:W_COL-1];  // Weight data
    
    // LSTM Interface
    logic [W_COL-1:0] relu_output;
    logic [HIDDEN_SIZE-1:0] lstm_out;
    
    // Instantiate Multiplier
    SequentialMultiplier #(N) SM(
        .clock(Clock),
        .reset(Reset),
        .multiplicand(Multiplicand),
        .multiplier(Multiplier),
        .product(Product),
        .ready(Ready),
        .start(Start)
    );
    
    // Instantiate ReLU-to-LSTM Pipeline
    relu_to_lstm #(
        .N(N),
        .INPUT_SIZE(W_COL),
        .HIDDEN_SIZE(HIDDEN_SIZE),
        .NUM_CELLS(NUM_LSTM_CELLS),
        .WEIGHT_FILE_PREFIX(LSTM_WEIGHT_PREFIX)
    ) u_relu_lstm (
        .clk(Clock),
        .reset(Reset),
        .relu_output(relu_output),
        .lstm_output(lstm_out)
    );
    
    // Clock Generator
    initial begin
        `ifdef DEBUG
        $dumpfile("dump.vcd"); 
        $dumpvars(0, top);
        `endif
        forever #50 Clock <= ~Clock;
    end
    
    // Wait for Multiplier Ready
    task WaitForReady;
        fork
            wait(Ready);
            repeat(2 * N + 4) @(negedge Clock);
        join_any
        
        if (!Ready) begin
            $display("Error: Timeout waiting for ready, Multiplicand = %b, Multiplier = %b", 
                    Multiplicand, Multiplier);
            Error = '1;
        end
    endtask
    
    // Apply Operands and Check Results
    task ApplyOperands(input signed [N-1:0] M1, input signed [N-1:0] M2);
        bit [2*N-1:0] ExpectedProduct;
        reg signed [2*N-1:0] Expected_activation;
        
        Multiplicand = M1;
        Multiplier = M2;
        ExpectedProduct = M1 * M2;
        Expected_activation = (ExpectedProduct < 0) ? 0 : ExpectedProduct;

        WaitForReady;
        Start = '1;
        @(negedge Clock);
        Start = '0;
        @(negedge Clock);
        
        if (Ready) begin
            $display("Error: Ready still asserted after start, Multiplicand = %b, Multiplier = %b", 
                    Multiplicand, Multiplier);
            Error = '1;
        end
        
        WaitForReady;
        
        if (Expected_activation !== Product) begin
            $display("*** Error: Expected = %b, Actual = %b",
                    Expected_activation, Product);
            Error = '1;
        end
    endtask
    
    // Verify LSTM Weight Files Exist
    function void verify_lstm_weights();
        const static string gates[4] = '{"Wf", "Wi", "Wc", "Wo"};
        int file_handle;
        static bit all_files_exist = 1;
        
        $display("\nChecking LSTM weight files in directory: %s", LSTM_WEIGHT_PREFIX);
        
        for (int i = 0; i < NUM_LSTM_CELLS; i++) begin
            for (int j = 0; j < 4; j++) begin
                automatic string filename = $sformatf("%s%0d_%s.mem", 
                    LSTM_WEIGHT_PREFIX, i, gates[j]);
                
                file_handle = $fopen(filename, "r");
                if (file_handle == 0) begin
                    $display("Error: LSTM weight file not found: %s", filename);
                    all_files_exist = 0;
                end else begin
                    $fclose(file_handle);
                    `ifdef DEBUG
                    $display("Found weight file: %s", filename);
                    `endif
                end
            end
        end
        
        if (!all_files_exist) begin
            $display("\nError: Missing one or more LSTM weight files");
            $display("Please ensure all weight files exist in the specified directory");
            $finish();
        end else begin
            $display("All LSTM weight files verified successfully\n");
        end
    endfunction
    
task read_matrices();
    // Declare all variables at the task level
    int mfcc_file, weight_file;
    string current_line;
    string temp_str;
    int pos;
    int space_pos;
    int row;
    int col;
    
    // Verify paths before attempting to open files
    $display("\nVerifying file paths...");
    $display("Looking for MFCC file at: %s", MFCC_PATH);
    $display("Looking for weights file at: %s", WEIGHT_PATH);
    
    // Try to open MFCC file
    mfcc_file = $fopen(MFCC_PATH, "r");
    if (mfcc_file == 0) begin
        $display("\nERROR: MFCC file not found at: %s", MFCC_PATH);
        $display("Possible solutions:");
        $display("1. Run the simulation from the correct directory");
        $display("2. Check the file exists at that path");
        $display("3. Verify relative path from simulation directory");
        $display("Current relative path should be: ../../data/mfcc_bitstream_output.txt");
        $finish();
    end
    
    // Initialize row counter
    row = 0;
    
    // Read MFCC data
    while (!$feof(mfcc_file) && row < ROWS) begin
        current_line = "";
        void'($fgets(current_line, mfcc_file));
        
        if (current_line.len() == 0) continue;
        
        // Remove trailing newline
        if (current_line.getc(current_line.len()-1) == "\n")
            current_line = current_line.substr(0, current_line.len()-2);

        // Parse space-separated values
        pos = 0;
        col = 0;
        while (pos < current_line.len() && col < COLUMNS) begin
            space_pos = current_line.len();
            for (int i = pos; i < current_line.len(); i++) begin
                if (current_line.getc(i) == " ") begin
                    space_pos = i;
                    break;
                end
            end
            
            if (space_pos > pos) begin
                temp_str = current_line.substr(pos, space_pos-1);
                if (temp_str.len() > 0) begin
                    if ($sscanf(temp_str, "%b", M1[row][col]) != 1) begin
                        $display("Warning: Error parsing MFCC at row %0d col %0d: %s", 
                                row, col, temp_str);
                        M1[row][col] = 0;
                    end
                    col++;
                end
            end
            pos = space_pos + 1;
        end
        
        // Check if we got all expected columns
        if (col != COLUMNS) begin
            $display("Warning: Row %0d has only %0d columns (expected %0d)", 
                    row, col, COLUMNS);
        end
        row++;
    end
    
    if (row != ROWS) begin
        $display("Warning: Read %0d MFCC rows (expected %0d)", row, ROWS);
    end
    $fclose(mfcc_file);
    
    // Try to open weights file
    weight_file = $fopen(WEIGHT_PATH, "r");
    if (weight_file == 0) begin
        $display("\nERROR: Weights file not found at: %s", WEIGHT_PATH);
        $finish();
    end
    
    // Read weight data
    row = 0;
    while (!$feof(weight_file) && row < COLUMNS) begin
        current_line = "";
        void'($fgets(current_line, weight_file));
        
        if (current_line.len() == 0) continue;
        
        // Remove trailing newline and spaces
        if (current_line.getc(current_line.len()-1) == "\n")
            current_line = current_line.substr(0, current_line.len()-2);
        
        temp_str = "";
        for (int i = 0; i < current_line.len(); i++) begin
            if (current_line.getc(i) != " ")
                temp_str = {temp_str, current_line.substr(i, i)};
        end
        current_line = temp_str;

        // Parse 128 bytes (1024 bits)
        if (current_line.len() < 1024) begin
            $display("Warning: Weight row %0d too short (%0d bits)", 
                    row, current_line.len());
            for (col = 0; col < W_COL; col++)
                W1[row][col] = 0;
        end
        else begin
            for (int byte_idx = 0; byte_idx < W_COL; byte_idx++) begin
                temp_str = current_line.substr(byte_idx*8, byte_idx*8 + 7);
                if ($sscanf(temp_str, "%b", W1[row][byte_idx]) != 1) begin
                    $display("Warning: Error parsing weight byte at row %0d pos %0d", 
                            row, byte_idx);
                    W1[row][byte_idx] = 0;
                end
            end
        end
        row++;
    end
    
    if (row != COLUMNS) begin
        $display("Warning: Read %0d weight rows (expected %0d)", row, COLUMNS);
    end
    $fclose(weight_file);
    
    $display("Data loading completed successfully\n");
endtask
    
    // Main Test Sequence
    initial begin
        // Initialize
        Reset = '1;
        Start = '0;
        Error = '0;
        @(negedge Clock);
        Reset = '0;
        @(negedge Clock);
        
        $display("\n===== Starting MFCC-LSTM Test =====\n");
        
        // Verify files before proceeding
        verify_lstm_weights();
        read_matrices();
        
        $display("Beginning MFCC-LSTM processing...");
        $display("Processing %0d frames with %0d features each...\n", ROWS, COLUMNS);
        
        // Process Each Frame
        for (int i = 0; i < ROWS; i++) begin
            // Initialize ReLU output
            relu_output = '0;
            
            // Process Each Output Dimension
            for (int j = 0; j < W_COL; j++) begin
                automatic logic [2*N-1:0] acc = '0;
                
                // Matrix Multiplication
                for (int k = 0; k < COLUMNS; k++) begin
                    ApplyOperands(M1[i][k], W1[k][j]);
                    acc = acc + Product;
                    @(negedge Clock);
                end
                
                // ReLU Activation
                relu_output[j*N +: N] = (acc < 0) ? 0 : acc[N-1:0];
            end
            
            // LSTM Processing (wait for pipeline)
            repeat(HIDDEN_SIZE/2) @(negedge Clock);
            
            `ifdef DEBUG
            if (i % 50 == 0) begin
                $display("Processed frame %4d/%0d, LSTM Output = %h", i, ROWS, lstm_out);
            end
            `endif
        end
        
        // Test Summary
        $display("\n===== Test Complete =====\n");
        if (Error)
            $display("*** TEST FAILED ***");
        else
            $display("*** TEST PASSED ***");
        
        $display("\nProcessed %0d frames successfully", ROWS);
        $finish();
    end
endmodule