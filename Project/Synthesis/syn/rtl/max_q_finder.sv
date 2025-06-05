module max_q_finder #(
    parameter DATA_WIDTH = 16    // Width of Q-value (fixed-point or float)
)(
    input  logic                    clk,         // Clock
    input  logic                    rst_n,       // Active-low reset
    input  logic                    enable,      // Start signal
    input  logic [DATA_WIDTH-1:0]    Q_values [3:0], // 4 Q-values (up, down, left, right)
    output logic [1:0]               best_action, // Best action index
    output logic [DATA_WIDTH-1:0]    max_Q_value, // Max Q-value
    output logic                     valid        // Output valid flag
);

    // Internal registers
    logic [DATA_WIDTH-1:0] q0, q1, q2, q3;
    logic [1:0]            max_idx;
    logic [DATA_WIDTH-1:0] max_val;
    logic                  done;

    // Combinational logic to find max Q
    always_comb begin
        q0 = Q_values[0];
        q1 = Q_values[1];
        q2 = Q_values[2];
        q3 = Q_values[3];

        // Assume q0 is max initially
        max_val = q0;
        max_idx = 2'd0;

        if (q1 >= max_val) begin
            max_val = q1;
            max_idx = 2'd1;
        end
        if (q2 >= max_val) begin
            max_val = q2;
            max_idx = 2'd2;
        end
        if (q3 >= max_val) begin
            max_val = q3;
            max_idx = 2'd3;
        end
    end

    // Sequential logic to register outputs
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            best_action <= 2'd0;
            max_Q_value <= {DATA_WIDTH{1'b0}};
            valid       <= 1'b0;
        end
        else begin
            if (enable) begin
                best_action <= max_idx;
                max_Q_value <= max_val;
                valid       <= 1'b1;
            end else begin
                valid <= 1'b0; // Clear valid if not enabled
            end
        end
    end

endmodule

