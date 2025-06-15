module lstm_layer #(
    parameter N = 8,
    parameter INPUT_SIZE = 128,
    parameter HIDDEN_SIZE = 64,
    parameter NUM_CELLS = 4,
    parameter string WEIGHT_FILE_PREFIX = "weights/lstm_"
)(
    input logic clk,
    input logic reset,
    input logic [INPUT_SIZE-1:0] x_t,
    output logic [HIDDEN_SIZE-1:0] h_t
);

    // State registers (remove the extra arrays)
    logic [HIDDEN_SIZE-1:0] h_state [0:NUM_CELLS-1];
    logic [HIDDEN_SIZE-1:0] c_state [0:NUM_CELLS-1];
    
    // Previous states (no longer need separate arrays)
    logic [HIDDEN_SIZE-1:0] h_prev = '0;
    logic [HIDDEN_SIZE-1:0] c_prev = '0;

    generate
        for (genvar i = 0; i < NUM_CELLS; i++) begin : gen_lstm_cells
            lstm_cell #(
                .N(N),
                .HIDDEN_SIZE(HIDDEN_SIZE),
                .WEIGHT_FILE({WEIGHT_FILE_PREFIX, $sformatf("cell%0d", i)})
            ) u_cell (
                .clk(clk),
                .reset(reset),
                .x_t(x_t[i*N +: N]),
                .h_prev(i == 0 ? '0 : h_state[i-1]),
                .c_prev(i == 0 ? '0 : c_state[i-1]),
                .h_t(h_state[i]),
                .c_t(c_state[i])
            );
        end
    endgenerate

    // Final output
    assign h_t = h_state[NUM_CELLS-1];

endmodule