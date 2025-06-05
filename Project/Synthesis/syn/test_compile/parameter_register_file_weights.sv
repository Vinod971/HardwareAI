module parameter_register_file #(
    parameter integer WIDTH = 16,
    parameter integer NUM_NEURONS_LAYER_1 = 4,
    parameter integer NUM_NEURONS_LAYER_2 = 3,
    parameter signed [WIDTH-1:0] WEIGHTS [NUM_NEURONS_LAYER_1-1:0][NUM_NEURONS_LAYER_2-1:0] = '{default: 0}
)(
    input  logic clk,
    input  logic rst,

    // Register interface
    input  logic wr_en,
    input  logic [15:0] addr,
    input  logic signed [WIDTH-1:0] wr_data,
    output logic signed [WIDTH-1:0] rd_data,

    // Outputs to the neural network
    output logic signed [WIDTH-1:0] threshold,
    output logic signed [WIDTH-1:0] leak,
    output logic signed [WIDTH-1:0] reset_potential,
    output logic signed [WIDTH-1:0] refractory_cycles,
    output logic signed [WIDTH-1:0] synaptic_weights [NUM_NEURONS_LAYER_1-1:0][NUM_NEURONS_LAYER_2-1:0]
);

    // Internal registers
    logic signed [WIDTH-1:0] threshold_reg, leak_reg, reset_reg, refractory_reg;
    logic signed [WIDTH-1:0] weight_mem [NUM_NEURONS_LAYER_1-1:0][NUM_NEURONS_LAYER_2-1:0];

    // Write logic
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            threshold_reg   <= 16'd1000;
            leak_reg        <= 16'd10;
            reset_reg       <= 16'd0;
            refractory_reg  <= 16'd10;

            for (int m = 0; m < NUM_NEURONS_LAYER_1; m++) begin
                for (int n = 0; n < NUM_NEURONS_LAYER_2; n++) begin
                    weight_mem[m][n] <= WEIGHTS[m][n];
                end
            end

        end else if (wr_en) begin
            case (addr)
                16'h0000: threshold_reg  <= wr_data;
                16'h0001: leak_reg       <= wr_data;
                16'h0002: reset_reg      <= wr_data;
                16'h0003: refractory_reg <= wr_data;
                default: begin
                    if (addr >= 16'h1000 && addr < 16'h1000 + NUM_NEURONS_LAYER_1 * NUM_NEURONS_LAYER_2) begin
                        int idx = addr - 16'h1000;
                        int i = idx / NUM_NEURONS_LAYER_2;
                        int j = idx % NUM_NEURONS_LAYER_2;
                        weight_mem[i][j] <= wr_data;
                    end
                end
            endcase
        end
    end

    // Read logic
    always_comb begin
        case (addr)
            16'h0000: rd_data = threshold_reg;
            16'h0001: rd_data = leak_reg;
            16'h0002: rd_data = reset_reg;
            16'h0003: rd_data = refractory_reg;
            default: begin
                if (addr >= 16'h1000 && addr < 16'h1000 + NUM_NEURONS_LAYER_1 * NUM_NEURONS_LAYER_2) begin
                    int idx_r = addr - 16'h1000;
                    int i_r = idx_r / NUM_NEURONS_LAYER_2;
                    int j_r = idx_r % NUM_NEURONS_LAYER_2;
                    rd_data = weight_mem[i_r][j_r];
                end else begin
                    rd_data = '0;
                end
            end
        endcase
    end

    // Output assignments
    assign threshold          = threshold_reg;
    assign leak               = leak_reg;
    assign reset_potential    = reset_reg;
    assign refractory_cycles  = refractory_reg;
    assign synaptic_weights   = weight_mem;

endmodule

