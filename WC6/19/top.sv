`timescale 1ns/1ps

module top;
    
    // Testbench signals
    reg clk;
    reg reset_n;
    reg binary_input;
    wire spike_out;
    
    // Instantiate the LIF neuron
    lif_neuron dut (
        .clk(clk),
        .reset_n(reset_n),
        .binary_input(binary_input),
        .spike_out(spike_out)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100MHz clock
    end
    
    // Test scenarios
    initial begin
        // Initialize
        reset_n = 0;
        binary_input = 0;
        #20;
        
        // Release reset
        reset_n = 1;
        
        // Scenario 1: Constant input below threshold
        $display("\n--- Scenario 1: Constant sub-threshold input ---");
        binary_input = 1;  // Input that won't reach threshold alone
        #100;
        
        // Scenario 2: Input that accumulates to threshold
        $display("\n--- Scenario 2: Accumulating to threshold ---");
        repeat(5) begin
            binary_input = 1;
            #10;
            binary_input = 0;
            #10;
        end
        
        // Scenario 3: Leakage with no input
        $display("\n--- Scenario 3: Leakage demonstration ---");
        binary_input = 0;
        #100;
        
        // Scenario 4: Strong input causing immediate spiking
        $display("\n--- Scenario 4: Strong immediate input ---");
        binary_input = 1;
        #10;
        binary_input = 0;
        #50;
        
        // End simulation
        $display("\nSimulation complete");
        $finish;
    end
    
    // Monitor potential and spikes
    real potential;
    always @(posedge clk) begin
        potential = dut.potential;
        $display("Time: %0t, Input: %b, Potential: %f, Spike: %b", 
                $time, binary_input, potential, spike_out);
    end
    
endmodule