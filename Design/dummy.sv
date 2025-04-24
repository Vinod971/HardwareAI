module read_matrix;
  // File handles and counters
  int mfcc_file, weight_file;
  int mfcc_row, weight_row, col;
  
  // Data storage
  bit signed [7:0] mfcc_data[0:401][0:25];    // 402 frames × 26 coefficients
  bit signed [7:0] weight_data[0:25][0:127];   // 26 rows × 128 columns
  
  // Temporary variables
  string current_line;
  string temp_str;
  string byte_str;
  bit signed [7:0] tmp_byte;
  int pos, space_pos;
  int byte_idx;

  initial begin
   `ifdef FILEREAD
    mfcc_file = $fopen("mfcc_bitstream_output.txt", "r");
    if (mfcc_file == 0) begin
      $display("Error: Could not open mfcc_bitstream_output.txt");
      $finish;
    end

    mfcc_row = 0;
    while (!$feof(mfcc_file) && mfcc_row < 402) begin
      current_line = "";
      void'($fgets(current_line, mfcc_file));
      
      // Skip empty lines
      if (current_line.len() == 0) continue;
      
      // Remove trailing newline
      if (current_line.getc(current_line.len()-1) == "\n")
        current_line = current_line.substr(0, current_line.len()-2);

      // Split line into space-separated bytes
      pos = 0;
      col = 0;
      while (pos < current_line.len() && col < 26) begin
        // Find next space
        space_pos = current_line.len();
        for (int i = pos; i < current_line.len(); i++) begin
          if (current_line.getc(i) == " ") begin
            space_pos = i;
            break;
          end
        end
        
        // Extract and parse byte
        if (space_pos > pos) begin
          temp_str = current_line.substr(pos, space_pos-1);
          if (temp_str.len() > 0) begin
            if ($sscanf(temp_str, "%b", mfcc_data[mfcc_row][col]) != 1) begin
              $display("Error parsing MFCC value at row %0d col %0d: %s", 
                      mfcc_row, col, temp_str);
              mfcc_data[mfcc_row][col] = 0;
            end
            col = col + 1;
          end
        end
        pos = space_pos + 1;
      end
      
      if (col != 26) begin
        $display("Warning: MFCC frame %0d has %0d values (expected 26)", mfcc_row, col);
      end
      
      mfcc_row = mfcc_row + 1;
    end
    $fclose(mfcc_file);

    // Display MFCC samples
    $display("\nMFCC Samples:");
    $display("mfcc_data[0][0]   = %0d (bin: %08b)", mfcc_data[0][0], mfcc_data[0][0]);
    $display("mfcc_data[13][25] = %0d (bin: %08b)", mfcc_data[13][25], mfcc_data[13][25]);

    weight_file = $fopen("weights_binary.txt", "r");
    if (weight_file == 0) begin
      $display("Error: Could not open weights_binary.txt");
      $finish;
    end

    weight_row = 0;
    while (!$feof(weight_file) && weight_row < 26) begin
      current_line = "";
      void'($fgets(current_line, weight_file));
      
      // Skip empty lines
      if (current_line.len() == 0) continue;
      
      // Remove trailing newline and spaces
      if (current_line.getc(current_line.len()-1) == "\n")
        current_line = current_line.substr(0, current_line.len()-2);
      
      // Remove all spaces
      temp_str = "";
      for (int i = 0; i < current_line.len(); i++) begin
        if (current_line.getc(i) != " ")
          temp_str = {temp_str, current_line.substr(i, i)};
      end
      current_line = temp_str;

      // Verify line length (128 bytes × 8 bits = 1024 characters)
      if (current_line.len() < 1024) begin
        $display("Error: Weight row %0d too short (%0d bits, expected 1024)", 
                weight_row, current_line.len());
        for (col = 0; col < 128; col++)
          weight_data[weight_row][col] = 0;
      end
      else begin
        // Parse 128 bytes (8-bit each)
        for (byte_idx = 0; byte_idx < 128; byte_idx++) begin
          byte_str = current_line.substr(byte_idx*8, byte_idx*8 + 7);
          if ($sscanf(byte_str, "%b", weight_data[weight_row][byte_idx]) != 1) begin
            $display("Error parsing weight byte at row %0d pos %0d: %s", 
                    weight_row, byte_idx, byte_str);
            weight_data[weight_row][byte_idx] = 0;
          end
        end
      end
      
      weight_row = weight_row + 1;
    end
    $fclose(weight_file);

    // Display Weight samples
    $display("\nWeight Samples:");
    $display("weight_data[0][0]    = %0d (bin: %08b)", weight_data[0][0], weight_data[0][0]);
    $display("weight_data[0][1]    = %0d (bin: %08b)", weight_data[0][1], weight_data[0][1]);
    $display("weight_data[13][127] = %0d (bin: %08b)", weight_data[13][127], weight_data[13][127]);
    `endif
  end
  
endmodule