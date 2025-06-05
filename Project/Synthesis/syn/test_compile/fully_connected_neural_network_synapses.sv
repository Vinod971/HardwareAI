module fully_connected_neural_network #(
    parameter integer WIDTH = 16,
    parameter integer NUM_NEURONS_LAYER_1 = 4,
    parameter integer NUM_NEURONS_LAYER_2 = 3
)(
    input  logic clk,
    input  logic rst,
    input  logic signed [WIDTH-1:0] input_current,
    input  logic signed [WIDTH-1:0] threshold,
    input  logic signed [WIDTH-1:0] leak,
    input  logic signed [WIDTH-1:0] reset_potential,
    input  logic signed [WIDTH-1:0] refractory_cycles,
    input  logic signed [WIDTH-1:0] synaptic_weights [NUM_NEURONS_LAYER_1-1:0][NUM_NEURONS_LAYER_2-1:0],
    output logic [NUM_NEURONS_LAYER_2-1:0] spikes_layer_2
);

    logic spike_layer_1 [NUM_NEURONS_LAYER_1-1:0];
    logic signed [WIDTH-1:0] input_current_layer_2 [NUM_NEURONS_LAYER_2-1:0];
    logic spike_layer_2_int [NUM_NEURONS_LAYER_2-1:0];

    genvar i;
    generate
        for (i = 0; i < NUM_NEURONS_LAYER_1; i++) begin : layer_1_neurons
            lif_neuron #(
                .WIDTH(WIDTH)
            ) neuron_layer_1 (
                .clk(clk),
                .rst(rst),
                .input_current(input_current),
                .threshold(threshold),
                .leak(leak),
                .reset_potential(reset_potential),
                .refractory_cycles(refractory_cycles),
                .spike(spike_layer_1[i])
            );
        end
    endgenerate

    always_comb begin
        integer j, k;
        for (j = 0; j < NUM_NEURONS_LAYER_2; j++) begin
            input_current_layer_2[j] = 0;
            for (k = 0; k < NUM_NEURONS_LAYER_1; k++) begin
                if (spike_layer_1[k]) begin
                    input_current_layer_2[j] += synaptic_weights[k][j];
                end
            end
        end
    end

    generate
        for (i = 0; i < NUM_NEURONS_LAYER_2; i++) begin : layer_2_neurons
            lif_neuron #(
                .WIDTH(WIDTH)
            ) neuron_layer_2 (
                .clk(clk),
                .rst(rst),
                .input_current(input_current_layer_2[i]),
                .threshold(threshold),
                .leak(leak),
                .reset_potential(reset_potential),
                .refractory_cycles(refractory_cycles),
                .spike(spike_layer_2_int[i])
            );
        end
    endgenerate

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            spikes_layer_2 <= '0;
        end else begin
            for (int s = 0; s < NUM_NEURONS_LAYER_2; s++) begin
                spikes_layer_2[s] <= spike_layer_2_int[s];
            end
        end
    end

endmodule

