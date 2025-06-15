module lstm_cell #(
    parameter N = 8,                // Data width
    parameter HIDDEN_SIZE = 64,     // Hidden state size
    parameter string WEIGHT_FILE = ""  // Weight file prefix
)(
    input logic clk,
    input logic reset,
    input logic [N-1:0] x_t,        // Current input
    input logic [HIDDEN_SIZE-1:0] h_prev,  // Previous hidden state
    input logic [HIDDEN_SIZE-1:0] c_prev,  // Previous cell state
    output logic [HIDDEN_SIZE-1:0] h_t,    // Current hidden state
    output logic [HIDDEN_SIZE-1:0] c_t     // Current cell state
);

    // Weight memory
    logic signed [N-1:0] Wf [0:HIDDEN_SIZE-1];  // Forget gate weights
    logic signed [N-1:0] Wi [0:HIDDEN_SIZE-1];  // Input gate weights
    logic signed [N-1:0] Wc [0:HIDDEN_SIZE-1];  // Cell gate weights
    logic signed [N-1:0] Wo [0:HIDDEN_SIZE-1];  // Output gate weights

    // Initialize weights from file
    initial begin
        if (WEIGHT_FILE != "") begin
            $readmemb({WEIGHT_FILE, "_Wf.mem"}, Wf);
            $readmemb({WEIGHT_FILE, "_Wi.mem"}, Wi);
            $readmemb({WEIGHT_FILE, "_Wc.mem"}, Wc);
            $readmemb({WEIGHT_FILE, "_Wo.mem"}, Wo);
        end else begin
            foreach(Wf[i]) Wf[i] = '0;
            foreach(Wi[i]) Wi[i] = '0;
            foreach(Wc[i]) Wc[i] = '0;
            foreach(Wo[i]) Wo[i] = '0;
        end
    end

    // Gate computations
    logic [HIDDEN_SIZE-1:0] f_t, i_t, o_t, c_tilde_t;

    // Piecewise linear approximations for activations
    function automatic logic signed [N-1:0] sigmoid(input logic signed [2*N-1:0] x);
        // Simple approximation: 1/(1+e^-x)
        if (x > (2 << (N-2))) return {1'b0, {(N-1){1'b1}}};  // Saturate at ~1.0
        else if (x < -(2 << (N-2))) return '0;               // Saturate at 0.0
        else return (x >>> (N-1)) + (1 << (N-2));            // Linear approximation
    endfunction

    function automatic logic signed [N-1:0] tanh_approx(input logic signed [2*N-1:0] x);
        if (x > (3 << (N-2))) return {1'b0, {(N-1){1'b1}}};  // Saturate at 1.0
        else if (x < -(3 << (N-2))) return {1'b1, {(N-1){1'b1}}}; // -1.0
        else return (x >>> N);                                // Linear approximation
    endfunction

    // Compute gates
    always_comb begin
        for (int j = 0; j < HIDDEN_SIZE; j++) begin
            // Simplified MAC operations (would use proper multipliers in real implementation)
            automatic logic signed [2*N-1:0] f_raw = h_prev[j] * Wf[j] + x_t * Wf[j];
            automatic logic signed [2*N-1:0] i_raw = h_prev[j] * Wi[j] + x_t * Wi[j];
            automatic logic signed [2*N-1:0] o_raw = h_prev[j] * Wo[j] + x_t * Wo[j];
            automatic logic signed [2*N-1:0] c_raw = h_prev[j] * Wc[j] + x_t * Wc[j];

            // Apply activation functions
            f_t[j] = sigmoid(f_raw);
            i_t[j] = sigmoid(i_raw);
            o_t[j] = sigmoid(o_raw);
            c_tilde_t[j] = tanh_approx(c_raw);
        end
    end

    // Update states
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            c_t <= '0;
            h_t <= '0;
        end else begin
            // Update cell state
            for (int j = 0; j < HIDDEN_SIZE; j++) begin
                c_t[j] <= (f_t[j] & c_prev[j]) + (i_t[j] & c_tilde_t[j]);
                
                // Update hidden state
                h_t[j] <= o_t[j] & tanh_approx(c_t[j]);
            end
        end
    end

endmodule