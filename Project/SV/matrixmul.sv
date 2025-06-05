// 3 state Moore FSM-based sequential multiplier


module SequentialMultiplier#(parameter N = 4)(clock, reset, multiplicand, multiplier, product, ready, start);

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
	//output reg signed [2*N-1:0] activated_out;
	
	
	
	/*assign 	product = {A,Q};
		//Activation
    assign activated_out =(product<0)? 0: product;*/
	//Activation
	assign product = ({A,Q} < 0) ? 0 : {A, Q};


	assign {CarryOut, Sum} = A + (AdderMuxSelect ? M : 0);
	
	// C and A register
	always_ff @(posedge clock)
	begin
	if (ClearA)
		{C,A} <= 0;
	else if (ShiftAdd)
		A <=  {CarryOut, Sum[N-1:1]};
	else
		{C,A} <= {C,A};
	end
	
	// Q register
	always_ff @(posedge clock)
	begin
	if (LoadOperands)
		Q <= multiplier;
	else if (ShiftAdd)
		Q <= {Sum[0], Q[N-1:1]};
	else
		Q <= Q;
	end
	
	// M register
	always_ff @(posedge clock)
	begin
	if (LoadOperands)
		M <= multiplicand;
	else 
		M <= M;
	end
	
	// Counter
	always_ff @(posedge clock)
	begin
	if (LoadCounter)
		Counter <= N-1;
	else if (DecrCounter)
		Counter <= Counter - 1;
	else
		Counter <= Counter;
	end
	
	assign Zero = (Counter == 0);
	
	FSM F(clock, reset, ready, start, Q[0], AdderMuxSelect, ClearA, ShiftAdd, LoadOperands, Zero, LoadCounter, DecrCounter);
	
	//Activation DUT(clock, reset, product, activated_out);
	`ifdef DEBUG
	always @(posedge clock)
		$strobe("%t %b %b %b %b", $time, M, C, A, Q);
	`endif
	
	endmodule
	
	
	
	
	
	
	module FSM(Clock, Reset, Ready, Start, MultiplierLSB, AdderMuxSelect, ClearA, ShiftAdd, LoadOperands, Zero, LoadCounter, DecrCounter);
	input Clock;
	input Reset;
	output reg Ready;
	input Start;
	input MultiplierLSB;
	output reg AdderMuxSelect;
	output reg ClearA;
	output reg ShiftAdd;
	output reg LoadOperands;
	input Zero;
	output reg LoadCounter;
	output reg DecrCounter;
	
	
	enum logic [2:0] {
		INIT		= 3'b001,
		LOAD		= 3'b010,
		SHIFTADD	= 3'b100	
	} State, NextState;
	
	
	assign AdderMuxSelect = MultiplierLSB;
	
	always_ff @(posedge Clock)
	begin
	if (Reset)
		State <= INIT;
	else
		State <= NextState;
	end
	
	always_comb
	begin
	{Ready, ClearA, ShiftAdd, LoadOperands, LoadCounter, DecrCounter} = '0;
	case (State)
		INIT:	begin
				Ready = '1;
				end
				
		LOAD:	begin
				ClearA = '1;
				LoadOperands = '1;
				LoadCounter = '1;
				end
				
		SHIFTADD:
				begin
				DecrCounter = '1;
				ShiftAdd = '1;
				end
	
	endcase
	end
	
	
	always_comb
	begin
	NextState = State;
	case (State)
		INIT:	if (Start)
					NextState = LOAD;
		
		LOAD:	NextState = SHIFTADD;
		
		SHIFTADD:
				if (Zero)
					NextState = INIT;
	
	endcase
	end
	endmodule
	