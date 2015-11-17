module SoloMaster (CLOCK_50, speaker);
	input CLOCK_50;
	output reg speaker; 
	wire [12:0][3:0] probability_vector;
	reg [0:99] pool;
	//probably not right
endmodule

module determineProbability (select, probability_vector);
	input [2:0] select;
	always @ *
		case (select)
			1: probability_vector = 0;
		endcase
endmodule

module fillPool (probability_vector, pool)
	int i;
	for (i = 0; i < 99; i=i+1)
endmodule
