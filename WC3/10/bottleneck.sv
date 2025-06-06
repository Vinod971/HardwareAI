module q_update_unit (
    input logic clk,
    input logic rst,
    input logic [31:0] current_q,
    input logic [31:0] reward,
    input logic [31:0] next_q_max,
    input logic [31:0] alpha,
    input logic [31:0] gamma,
    output logic [31:0] updated_q
);

    logic [31:0] temp1, temp2, temp3;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            updated_q <= 0;
        end else begin
            temp1 = gamma * next_q_max;
            temp2 = reward + temp1 - current_q;
            temp3 = alpha * temp2;
            updated_q <= current_q + temp3;
        end
    end

endmodule
