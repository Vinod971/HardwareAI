module HardTanh (
    input  signed [7:0] data_in,  // 8-bit signed input
    output signed [7:0] data_out  // 8-bit clipped output
);
    // Define constants for +1.0 and -1.0 in Q1.6.1 format
    localparam signed [7:0] POS_ONE = 8'b01000000; // +1.0
    localparam signed [7:0] NEG_ONE = 8'b11000000; // -1.0

    assign data_out = (data_in < NEG_ONE) ? NEG_ONE : 
                     (data_in > POS_ONE) ? POS_ONE : 
                     data_in;
    
endmodule