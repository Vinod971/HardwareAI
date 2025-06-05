module lif_neuron #(
    parameter integer WIDTH = 16,
    parameter integer THRESHOLD = 1000,
    parameter integer LEAK = 10,
    parameter integer RESET_POTENTIAL = 0,
    parameter integer REFRACTORY_CYCLES = 10
)(
    input  logic                      clk,
    input  logic                      rst,
    input  logic signed [WIDTH-1:0]   input_current,
    output reg                        spike
);

    localparam signed [WIDTH-1:0] MAX_POTENTIAL = 2**(WIDTH-1) - 1;
    localparam signed [WIDTH-1:0] MIN_POTENTIAL = -(2**(WIDTH-1));

    // State
    logic signed [WIDTH-1:0] membrane_potential;
    logic [$clog2(REFRACTORY_CYCLES+1)-1:0] refractory_counter;
    logic in_refractory;

    // Computation
    logic signed [WIDTH:0] extended_sum;  // One extra bit for overflow detection
    logic signed [WIDTH-1:0] next_potential;
    logic spike_next;

    always_comb begin
        // Perform extended-width signed math
        extended_sum = $signed(membrane_potential) + $signed(input_current) - $signed(LEAK);

        // Clamp to legal signed range before using result
        if (extended_sum > MAX_POTENTIAL)
            next_potential = MAX_POTENTIAL;
        else if (extended_sum < MIN_POTENTIAL)
            next_potential = MIN_POTENTIAL;
        else
            next_potential = extended_sum[WIDTH-1:0];

        // Determine spike only after clamping
        spike_next = (!in_refractory && next_potential >= THRESHOLD);
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            membrane_potential <= 0;
            spike <= 0;
            refractory_counter <= 0;
            in_refractory <= 0;
        end else begin
            spike <= 0;

            if (in_refractory) begin
                if (refractory_counter == 0)
                    in_refractory <= 0;
                else
                    refractory_counter <= refractory_counter - 1;
            end else begin
                if (spike_next) begin
                    spike <= 1;
                    membrane_potential <= RESET_POTENTIAL;
                    in_refractory <= 1;
                    refractory_counter <= REFRACTORY_CYCLES - 1;
                end else begin
                    membrane_potential <= next_potential;
                end
            end
        end
    end

endmodule

