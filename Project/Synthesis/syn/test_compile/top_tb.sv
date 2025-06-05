module top_tb;

    // Parameters for the testbench
    parameter integer WIDTH = 16;
    parameter integer NUM_NEURONS_LAYER_1 = 4;
    parameter integer NUM_NEURONS_LAYER_2 = 3;

    // Testbench signals
    logic clk;
    logic rst;

    // SPI signals
    logic sclk;
    logic cs_n;
    logic mosi;
    logic miso;

    // Input current for the neural network
    logic signed [WIDTH-1:0] input_current;

    // Output spikes from layer 2
    logic [NUM_NEURONS_LAYER_2-1:0] spikes;

    // Instantiate the top module
    top #(
        .WIDTH(WIDTH),
        .NUM_NEURONS_LAYER_1(NUM_NEURONS_LAYER_1),
        .NUM_NEURONS_LAYER_2(NUM_NEURONS_LAYER_2)
    ) uut (
        .clk(clk),
        .rst(rst),
        .sclk(sclk),
        .cs_n(cs_n),
        .mosi(mosi),
        .miso(miso),
        .input_current(input_current),
        .spikes(spikes)
    );

    // Clock generation
    always begin
        #5 clk = ~clk;
    end

    // SPI clock generation
    always begin
        #10 sclk = ~sclk;
    end

    // Stimulus process
    initial begin
        // Initialize signals
        clk = 0;
        rst = 0;
        sclk = 0;
        cs_n = 1;
        mosi = 0;
        input_current = 0;
        
        // Apply reset
        rst = 1;
        #20 rst = 0;
        
        // Test SPI Write - Write parameters to register file
        // Write THRESHOLD (16'h0000) = 1000
        write_spi(16'h0000, 16'd1000);
        
        // Write LEAK (16'h0001) = 10
        write_spi(16'h0001, 16'd10);
        
        // Write RESET_POTENTIAL (16'h0002) = 0
        write_spi(16'h0002, 16'd0);
        
        // Write REFRACTORY_CYCLES (16'h0003) = 10
        write_spi(16'h0003, 16'd10);

        // Write Synaptic weights for Layer 1 to Layer 2 (address starts from 16'h1000)
        write_spi(16'h1000, 16'd50);  // Synaptic weight for 1st neuron of Layer 1 to 1st neuron of Layer 2
        write_spi(16'h1001, 16'd60);  // Synaptic weight for 2nd neuron of Layer 1 to 1st neuron of Layer 2
        write_spi(16'h1002, 16'd70);  // Synaptic weight for 3rd neuron of Layer 1 to 1st neuron of Layer 2
        write_spi(16'h1003, 16'd80);  // Synaptic weight for 4th neuron of Layer 1 to 1st neuron of Layer 2
        
        // Apply some input current to layer 1
        input_current = 16'd500;
        #20 input_current = 16'd700;
        #20 input_current = 16'd1000;
        #20 input_current = 16'd0;

        // Check output spikes (spikes should be 0 initially)
        #20 $display("Layer 2 spikes: %b", spikes);

        // Finish the simulation
        #100 $finish;
    end

    // SPI write task (used to send data over SPI)
    task write_spi(input [15:0] addr, input [15:0] data);
        integer i;
        begin
            // Set CS low to start SPI communication
            cs_n = 0;
            
            // Send address (16-bits)
            for (i = 15; i >= 0; i = i - 1) begin
                mosi = addr[i];
                #10; // Wait for SCLK
                sclk = 1;
                #10;
                sclk = 0;
            end
            
            // Send data (16-bits)
            for (i = 15; i >= 0; i = i - 1) begin
                mosi = data[i];
                #10; // Wait for SCLK
                sclk = 1;
                #10;
                sclk = 0;
            end
            
            // Set CS high to end SPI communication
            cs_n = 1;
            #20;
        end
    endtask

endmodule

