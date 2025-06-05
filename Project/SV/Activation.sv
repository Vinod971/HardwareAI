module Activation #(
    parameter N = 8  // Single width parameter
)(
    input wire clock,
    input wire reset,
    input signed [2*N-1:0] product,  // 16-bit input from multiplier
    output reg signed [2*N-1:0] activated_out  // 8-bit clipped output
);

always_ff @(posedge clock or posedge reset) begin
    if (reset)
        activated_out <= 0;
    else
        activated_out <= (product < 0) ? 0 : product;
end

endmodule