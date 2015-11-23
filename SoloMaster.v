module SoloMaster (); // top entity

endmodule 

module song_generator (CLOCK_50, song); 
	parameter REST = 0, D1 = 1, B1 = 2, Db2 = 3, D2 = 4, 
		E2 = 5, F2 = 6, Gb2 = 7, G2 = 8, A2 = 9,
		Bb2 = 10, B2 = 11, C3 = 12, Db3 = 13, D3 = 14, 
		E3 = 15; 
	input CLOCK_50; 
	reg [0:13] pool;
	reg [3:0] cur_note, next_note;
	output reg [1023:0] song; // stores all the pitches 
	assign cur_note = REST;
	
	always @ (posedge CLOCK_50)
	begin
	
	end
	song >> 4; // right shift all the pitches by 4 bits
endmodule

module vector_generator (cur_note, next_vector);
//it's essentially a huge mux
//outputs a probability vector containing possible next notes
//given current note. 
	input [4:0] cur_note; 
	output reg [0:27] next_vector;
	//format of next vector:
	//[16 bits for all posible states]*[128 bits to represent percentage] 
	parameter REST = 0, D1 = 1, B1 = 2, Db2 = 3, D2 = 4, 
		E2 = 5, F2 = 6, Gb2 = 7, G2 = 8, A2 = 9,
		Bb2 = 10, B2 = 11, C3 = 12, Db3 = 13, D3 = 14, 
		E3 = 15;
	always @ *
	case (cur_note)
		REST:
			next_vector = { 7'd52,  7'd0, 7'd10,  7'd1,   7'd2,
							     7'd1,  7'd0,  7'd8,  7'd0,   7'd7, 
								  7'd0,  7'd3,  7'd2,  7'd5,   7'd3, 
								  7'd1}; // rest
		D1:
			next_vector = {  7'd0,  7'd0,  7'd0,  7'd0,   7'd0,
							     7'd0,  7'd0,  7'd0,  7'd0, 7'd100, 
								  7'd0,  7'd0,  7'd0,  7'd0,   7'd0, 
								  7'd0}; // D1
		B1:
			next_vector = {  7'd0, 7'd14,  7'd0, 7'd14,   7'd71,
							     7'd0,  7'd0,  7'd0,  7'd0,   7'd0, 
								  7'd0,  7'd0,  7'd0,  7'd0,   7'd0, 
								  7'd0}; // B1
		Db2:
			next_vector = {  7'd0,  7'd0,  7'd0,  7'd0,  7'd50,
							     7'd0,  7'd0, 7'd50,  7'd0,   7'd0, 
								  7'd0,  7'd0,  7'd0,  7'd0,   7'd0, 
								  7'd0};  // Db2
		D2:
			next_vector = {  7'd4,  7'd0, 7'd20,  7'd0,   7'd0,
							     7'd0,  7'd0, 7'd36,  7'd0,  7'd36, 
								  7'd0,  7'd4,  7'd0,  7'd0,   7'd0, 
								  7'd0}; // D2
		E2:
			next_vector = {  7'd0,  7'd0,  7'd0,  7'd0,   7'd0,
							     7'd0,  7'd0,  7'd0,  7'd0,   7'd0, 
								  7'd0,  7'd0,  7'd0,  7'd0,   7'd0, 
								  7'd0};
		F2:
			next_vector = {  7'd0,  7'd0,  7'd0,  7'd0,   7'd0,
							     7'd0,  7'd0,  7'd0,  7'd0,   7'd0, 
								  7'd0,  7'd0,  7'd0,  7'd0,   7'd0, 
								  7'd0};
		Gb2:
			next_vector = {  7'd0,  7'd0,  7'd0,  7'd0,   7'd0,
							     7'd0,  7'd0,  7'd0,  7'd0,   7'd0, 
								  7'd0,  7'd0,  7'd0,  7'd0,   7'd0, 
								  7'd0};
		G2:
			next_vector = {  7'd0,  7'd0,  7'd0,  7'd0,   7'd0,
							     7'd0,  7'd0,  7'd0,  7'd0,   7'd0, 
								  7'd0,  7'd0,  7'd0,  7'd0,   7'd0, 
								  7'd0};
		A2:
			next_vector = {  7'd0,  7'd0,  7'd0,  7'd0,   7'd0,
							     7'd0,  7'd0,  7'd0,  7'd0,   7'd0, 
								  7'd0,  7'd0,  7'd0,  7'd0,   7'd0, 
								  7'd0};
		Bb2:
			next_vector = {  7'd0,  7'd0,  7'd0,  7'd0,   7'd0,
							     7'd0,  7'd0,  7'd0,  7'd0,   7'd0, 
								  7'd0,  7'd0,  7'd0,  7'd0,   7'd0, 
								  7'd0};
		B2:
			next_vector = {  7'd0,  7'd0,  7'd0,  7'd0,   7'd0,
							     7'd0,  7'd0,  7'd0,  7'd0,   7'd0, 
								  7'd0,  7'd0,  7'd0,  7'd0,   7'd0, 
								  7'd0};
		C3:
			next_vector = {  7'd0,  7'd0,  7'd0,  7'd0,   7'd0,
							     7'd0,  7'd0,  7'd0,  7'd0,   7'd0, 
								  7'd0,  7'd0,  7'd0,  7'd0,   7'd0, 
								  7'd0};
		Db3:
			next_vector = {  7'd0,  7'd0,  7'd0,  7'd0,   7'd0,
							     7'd0,  7'd0,  7'd0,  7'd0,   7'd0, 
								  7'd0,  7'd0,  7'd0,  7'd0,   7'd0, 
								  7'd0};
		D3:
			next_vector = {  7'd0,  7'd0,  7'd0,  7'd0,   7'd0,
							     7'd0,  7'd0,  7'd0,  7'd0,   7'd0, 
								  7'd0,  7'd0,  7'd0,  7'd0,   7'd0, 
								  7'd0};
		E3:
			next_vector = {  7'd0,  7'd0,  7'd0,  7'd0,   7'd0,
							     7'd0,  7'd0,  7'd0,  7'd0,   7'd0, 
								  7'd0,  7'd0,  7'd0,  7'd0,   7'd0, 
								  7'd0};
	endcase
endmodule

module populate_pool (next_vector, pool);
	int i, j;
	input [0:27] next_vector;
	output reg [0:13] pool; 
	//pool is 128 * 4 bits
	//[100 spots for possible next notes] * [each note is 4 bits long]
	always @*
		for (i = 0; i < 12; i = i + 1)
			for (j = 0; j < next_vector[(7 * i):(7 * i + 6)]; j = j + 1)
			//separate out each probability from the vector
				begin 
					pool [(4 * i):(4 * i + 3)] = i;
				end
endmodule

module next_note_generator (pool, next_note);
	input [0:13] pool;
	output reg [3:0] next_note;
	int rand_num; // 0 <= rand_num <= 99
	//write something to generate a random number
	always @ *
		next_note = pool [(rand_num * 4):(rand_num * 4 + 3)]; 
endmodule

module song_recorder(clock, D, Q, reset_n);
//essentially a flip flop that saves the generated notes
	input clock, reset_n;
	input [3:0] D;
	output reg [3:0] Q;
	always @ (posedge clock)
	begin
		if (reset_n == 0)
			Q <= 0;
		else
			Q <= D;
	end		
endmodule
