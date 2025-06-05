interface in_speech; 

    reg Reset;
    reg [N-1:0] Multiplicand, Multiplier;
    wire [2*N-1:0] Product;
    reg Start;
    bit Clock = '1;
    wire Ready;
    bit Error;
    
    input clock;
	input reset;
	input [N-1:0] multiplicand, multiplier;
	output [2*N-1:0] product;
	output ready;
	input start;
	
	reg signed [N-1:0] A, Q, M;
	reg C;
	reg [N-1:0] Counter;
	   
	wire CarryOut;
	wire [N-1:0] Sum;
	wire ClearA;
	wire ShiftAdd;
	wire Zero;
	wire AdderMuxSelect;
	wire LoadCounter;
	wire DecrCounter;
	wire LoadOperands;


endinterface 