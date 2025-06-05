module tb_q_learning_update;

    // Testbench signals
    logic clk;
    logic reset;
    logic [7:0] state;
    logic [3:0] action;
    logic [15:0] reward;
    logic [15:0] alpha;
    logic [15:0] gamma;
    logic [15:0] updated_q_value;

    // Instantiate the Device Under Test (DUT)
    q_learning_update uut (
        .clk(clk),
        .reset(reset),
        .state(state),
        .action(action),
        .reward(reward),
        .alpha(alpha),
        .gamma(gamma),
        .updated_q_value(updated_q_value)
    );

    // Clock generation (period = 10)
    always begin
        #5 clk = ~clk;
    end

    // Test sequence
    initial begin
        // Initialize signals
        clk = 0;
        reset = 0;
        state = 0;
        action = 0;
        reward = 0;
        alpha = 16'h0001;   // Example alpha value
        gamma = 16'h0001;   // Example gamma value

        // Apply reset
        reset = 1;
        #10 reset = 0;

        // Apply test vectors
        // Time = 0
        state = 0; action = 0; reward = 0;
        #10;

        // Time = 10
        state = 0; action = 1; reward = 10;
        #10;

        // Time = 15
        state = 0; action = 1; reward = 10;
        #10;

        // Time = 20
        state = 1; action = 2; reward = 20;
        #10;

        // Time = 30
        state = 2; action = 0; reward = 5;
        #10;

        // Time = 35
        state = 2; action = 0; reward = 5;
        #10;

        // Time = 40
        state = 0; action = 1; reward = 0;
        #10;

        // Time = 45
        state = 0; action = 1; reward = 0;
        #10;

        // Time = 50
        state = 3; action = 3; reward = 30;
        #10;

        // Time = 55
        state = 3; action = 3; reward = 30;
        #10;

        // Finish simulation
        $finish;
    end

    // Display outputs
    initial begin
        $monitor("Time: %0t | State: %0d | Action: %0d | Reward: %0d | Updated Q-value: %0d", 
                 $time, state, action, reward, updated_q_value);
    end

endmodule
