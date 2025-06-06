module q_learning_update (
    input logic clk,
    input logic reset,
    input logic [7:0] state,
    input logic [3:0] action,
    input logic [15:0] reward,
    input logic [15:0] alpha,
    input logic [15:0] gamma,
    output logic [15:0] updated_q_value
);

    // Internal signals
    logic [15:0] current_q_value;
    logic [15:0] max_q_value;
    logic [15:0] new_q_value;

    // Memory for Q-table (state x action)
    logic [15:0] q_table [0:15][0:3];

    // Update Q-value logic within always_ff block
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            // Initialize Q-table to 0 during reset
            for (int i = 0; i < 16; i++) begin
                for (int j = 0; j < 4; j++) begin
                    q_table[i][j] <= 16'b0; // Use non-blocking assignment
                end
            end
            updated_q_value <= 16'b0; // Ensure updated Q-value is initialized
            current_q_value <= 16'b0; // Initialize the current Q-value
            max_q_value <= 16'b0;     // Initialize the max Q-value
            new_q_value <= 16'b0;     // Initialize the new Q-value
        end else begin
            // Ensure all registers are assigned a valid value
            current_q_value <= q_table[state][action];

            // Find the maximum Q-value for the next state (simplified to same state here)
            max_q_value <= 16'b0;
            for (int i = 0; i < 4; i++) begin
                if (q_table[state][i] > max_q_value) begin
                    max_q_value <= q_table[state][i];
                end
            end

            // Compute the new Q-value based on the Q-learning update formula
            new_q_value <= current_q_value + alpha * (reward + gamma * max_q_value - current_q_value);

            // Update the Q-table with the new Q-value
            q_table[state][action] <= new_q_value;

            // Output the updated Q-value
            updated_q_value <= new_q_value;
        end
    end

endmodule
