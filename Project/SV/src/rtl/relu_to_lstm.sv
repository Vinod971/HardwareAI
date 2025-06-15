module relu_to_lstm #(
    parameter N = 8,
    parameter INPUT_SIZE = 128,
    parameter HIDDEN_SIZE = 64,
    parameter NUM_CELLS = 4,
    parameter string WEIGHT_FILE_PREFIX = "weights/lstm_cell"  // Add this line
)(
    input logic clk,
    input logic reset,
    input logic [INPUT_SIZE-1:0] relu_output,
    output logic [HIDDEN_SIZE-1:0] lstm_output
);

    // LSTM input register
    logic [INPUT_SIZE-1:0] lstm_input;

    // Instantiate LSTM layer
    lstm_layer #(
        .N(N),
        .INPUT_SIZE(INPUT_SIZE),
        .HIDDEN_SIZE(HIDDEN_SIZE),
        .NUM_CELLS(NUM_CELLS)
    ) u_lstm_layer (
        .clk(clk),
        .reset(reset),
        .x_t(lstm_input),
        .h_t(lstm_output)
    );

    // Register ReLU output
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            lstm_input <= '0;
        end else begin
            lstm_input <= relu_output;
        end
    end

endmodule