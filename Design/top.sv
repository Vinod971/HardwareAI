module top;
    parameter N = 8;
    parameter ROWS = 402;
    parameter COLUMNS = 26;
    parameter W_COL = 128;
    
    reg Reset;
    reg [N-1:0] Multiplicand, Multiplier;
    wire [2*N-1:0] Product;
    reg Start;
    bit Clock = '1;
    wire Ready;
    bit Error;
    
    logic signed [N-1:0] M1 [0:ROWS-1][0:COLUMNS-1];  // MFCC data
    logic signed [N-1:0] W1 [0:COLUMNS-1][0:W_COL-1];  // Weight data
    
    // Instantiate the multiplier
    SequentialMultiplier #(N) SM(Clock, Reset, Multiplicand, Multiplier, Product, Ready, Start);
    
    // Clock generator
    initial begin
        `ifdef DEBUG
        $dumpfile("dump.vcd"); $dumpvars;
        `endif
        forever #50 Clock <= ~Clock;
    end
    
    // Wait for ready but timeout with error if too long
    task WaitForReady;
    begin
        fork
            wait(Ready);
            repeat(2 * (N) + 4) @(negedge Clock);
        join_any
        
        if (!Ready) begin
            $display("Error: timeout while waiting for ready, Multiplicand = %b, Multiplier = %b", 
                    Multiplicand, Multiplier);
            Error = '1;
        end
    end
    endtask
    
    // Apply the operands, waiting for Ready, assert Start, waiting for Ready, checking results
    task ApplyOperands(input signed [N-1:0] M1, input signed [N-1:0] M2);
        bit [2*N-1:0] ExpectedProduct;
        
        Multiplicand = M1;
        Multiplier = M2;
        ExpectedProduct = M1 * M2;
        
        WaitForReady;
        Start = '1;
        @(negedge Clock);
        Start = '0;
        @(negedge Clock);
        
        if (Ready) begin
            $display("Error: ready still asserted one cycle after start asserted, Multiplicand = %b, Multiplier = %b", 
                    Multiplicand, Multiplier);
            Error = '1;
        end
        
        WaitForReady;
        
        if (Product !== ExpectedProduct) begin
            $display("*** Error: Multiplicand = %b, Multiplier = %b, Product = %b, Expected Product = %b", 
                    M1, M2, Product, ExpectedProduct);
            Error = '1;
        end
    endtask
    
    // Read matrix data from files
    task read_matrices;
        int mfcc_file, weight_file;
        string current_line;
        string temp_str;
        int pos, space_pos;
        int row, col;
        
        // Read MFCC data
        mfcc_file = $fopen("mfcc_bitstream_output.txt", "r");
        if (mfcc_file == 0) begin
            $display("Error: Could not open mfcc_bitstream_output.txt");
            $finish;
        end
        
        row = 0;
        while (!$feof(mfcc_file) && row < ROWS) begin
            current_line = "";
            void'($fgets(current_line, mfcc_file));
            
            if (current_line.len() == 0) continue;
            
            // Remove trailing newline
            if (current_line.getc(current_line.len()-1) == "\n")
                current_line = current_line.substr(0, current_line.len()-2);

            // Parse space-separated binary values
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
                            $display("Error parsing MFCC value at row %0d col %0d: %s", 
                                    row, col, temp_str);
                            M1[row][col] = 0;
                        end
                        col++;
                    end
                end
                pos = space_pos + 1;
            end
            row++;
        end
        $fclose(mfcc_file);
        
        // Read weight data
        weight_file = $fopen("weights_binary.txt", "r");
        if (weight_file == 0) begin
            $display("Error: Could not open weights_binary.txt");
            $finish;
        end
        
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
                $display("Error: Weight row %0d too short (%0d bits, expected 1024)", 
                        row, current_line.len());
                for (col = 0; col < W_COL; col++)
                    W1[row][col] = 0;
            end
            else begin
                for (int byte_idx = 0; byte_idx < W_COL; byte_idx++) begin
                    temp_str = current_line.substr(byte_idx*8, byte_idx*8 + 7);
                    if ($sscanf(temp_str, "%b", W1[row][byte_idx]) != 1) begin
                        $display("Error parsing weight byte at row %0d pos %0d: %s", 
                                row, byte_idx, temp_str);
                        W1[row][byte_idx] = 0;
                    end
                end
            end
            row++;
        end
        $fclose(weight_file);
    endtask
    
    initial begin
        Reset = '1;
        @(negedge Clock);
        Reset = '0;
        @(negedge Clock);
        
        // Read the matrix data from files
        read_matrices();
        
        $display("Starting matrix multiplication test...");
        
        // Test all combinations
        for (int i = 0; i < ROWS; i++) begin
            for (int j = 0; j < W_COL; j++) begin
                for (int k = 0; k < COLUMNS; k++) begin
                    ApplyOperands(M1[i][k], W1[k][j]);
                    `ifdef DEBUG
                    $strobe("M1[%0d][%0d] x W1[%0d][%0d] = %0d", i, k, k, j, Product);
                    `endif
                    @(negedge Clock);
                end
            end
        end
        
        if (Error)
            $display("\n\n *** TEST FAILED *** \n\n");
        else
            $display("\n\n *** TEST PASSED *** \n\n");
        
        $finish();
    end
endmodule