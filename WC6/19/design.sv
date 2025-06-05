`timescale 1ns/1ps

module lif_neuron (
    input wire clk,
    input wire reset_n,
    input wire binary_input,
    output reg spike_out
);
    
    // Parameters
    parameter LAMBDA = 0.9;       // Leak factor (0 < λ < 1)
    parameter THRESHOLD = 1.0;    // Spiking threshold (θ)
    parameter RESET_VALUE = 0.2;   // Reset potential after spike
    
    // Internal state variables
    real potential = 0.0;  // Membrane potential (P(t))
    
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            // Reset state
            potential <= 0.0;
            spike_out <= 0;
        end
        else begin
            // Update potential with leak and input
            potential <= LAMBDA * potential + binary_input;
            
            // Threshold function
            if (potential >= THRESHOLD) begin
                spike_out <= 1;
                potential <= RESET_VALUE;  // Reset mechanism
            end
            else begin
                spike_out <= 0;
            end
        end
    end
    
endmodule