`include "../rtl/spi_slave_interface.sv"
`include "../rtl/fully_connected_neural_network_synapses.sv"
`include "../rtl/parameter_register_file_weights.sv"

module top #(
    parameter integer WIDTH = 16,
    parameter integer NUM_NEURONS_LAYER_1 = 4,
    parameter integer NUM_NEURONS_LAYER_2 = 3
)(
    input  logic clk,
    input  logic rst,

    // SPI Interface
    input  logic sclk,
    input  logic cs_n,
    input  logic mosi,
    output logic miso,

    // External input to the neural network
    input  logic signed [WIDTH-1:0] input_current,

    // Output spikes from layer 2
    output logic [NUM_NEURONS_LAYER_2-1:0] spikes
);

    // SPI to Register File wires
    logic wr_en;
    logic [15:0] addr;
    logic signed [WIDTH-1:0] wr_data;
    logic signed [WIDTH-1:0] rd_data;

    // Configurable parameters from register file
    logic signed [WIDTH-1:0] threshold;
    logic signed [WIDTH-1:0] leak;
    logic signed [WIDTH-1:0] reset_potential;
    logic signed [WIDTH-1:0] refractory_cycles;
    logic signed [WIDTH-1:0] synaptic_weights [NUM_NEURONS_LAYER_1-1:0][NUM_NEURONS_LAYER_2-1:0];

    // SPI interface
    spi_slave_interface #(
        .WIDTH(WIDTH)
    ) spi_inst (
        .clk(clk),
        .rst(rst),
        .sclk(sclk),
        .cs_n(cs_n),
        .mosi(mosi),
        .miso(miso),
        .wr_en(wr_en),
        .addr(addr),
        .wr_data(wr_data),
        .rd_data(rd_data)
    );

    // Register file
    parameter_register_file #(
        .WIDTH(WIDTH),
        .NUM_NEURONS_LAYER_1(NUM_NEURONS_LAYER_1),
        .NUM_NEURONS_LAYER_2(NUM_NEURONS_LAYER_2)
    ) reg_file (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .addr(addr),
        .wr_data(wr_data),
        .rd_data(rd_data),
        .threshold(threshold),
        .leak(leak),
        .reset_potential(reset_potential),
        .refractory_cycles(refractory_cycles),
        .synaptic_weights(synaptic_weights)
    );

    // Neural network
    fully_connected_neural_network #(
        .WIDTH(WIDTH),
        .NUM_NEURONS_LAYER_1(NUM_NEURONS_LAYER_1),
        .NUM_NEURONS_LAYER_2(NUM_NEURONS_LAYER_2)
    ) nn_inst (
        .clk(clk),
        .rst(rst),
        .input_current(input_current),
        .threshold(threshold),
        .leak(leak),
        .reset_potential(reset_potential),
        .refractory_cycles(refractory_cycles),
        .synaptic_weights(synaptic_weights),
        .spikes_layer_2(spikes)
    );

endmodule

