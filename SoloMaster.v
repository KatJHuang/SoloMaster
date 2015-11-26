module SoloMaster (); // top entity

endmodule 

module song_generator (CLOCK_50, song);
	//numerical representation of different pitches
	parameter REST = 4'b0, D1 = 4'b1, B1 = 4'b2, Db2 = 4'b3, D2 = 4'b4, 
		E2 = 4'b5, F2 = 4'b6, Gb2 = 4'b7, G2 = 4'b8, A2 = 4'b9,
		Bb2 = 4'b10, B2 = 4'b11, C3 = 4'b12, Db3 = 4'b13, D3 = 4'b14, 
		E3 = 4'b15; 
		
	//states: one hot encoding 
	parameter new_song = 3'b001, create_new_note = 3'b010, stop = 3'b100;
	input CLOCK_50; 
	wire [0:13] pool;
	wire [3:0] cur_note, next_note;
	wire loadn, reset_n;//control signals for data path
   wire [0:27] next_vector;
	reg [7:0] counter;
	reg [2:0] cur_state, next_state;
	output reg [1023:0] song; // stores all the pitches 
	
	assign cur_note = REST;
	assign counter = 8'b0; 
	
	//state transitions
	case (cur_state)
		new_song: 
			begin
				if (reset_n == 0)
					next_state = new_song;
				else
					next_state = create_new_note;
			end
		create_new_note:
			begin 
				if (counter < 256)
					next_state = create_new_note;	
				else 
					next_state = stop;
			end
		stop: 
			begin 
				if (make_new_song == 1)
					next_state = new_song;
				else 
					next_state = stop;
			end
	endcase
	
	//state flip flops
	always @ (posedge CLOCK_50)
		cur_state <= next_state;
		
	//logic output
	always @ *
	case (cur_state)
		new_song:
			begin
				counter = 0;
				reset_n = 1; // depends on the input
				loadn = 1;
			end
		create_new_note:
			begin
				counter = counter + 1;
				reset_n = 1;
				loadn = 1;
			end
		stop:
			begin
				counter = 0;
				reset_n = 1;
				loadn = 0;
			end
	endcase
		
	note_recorder note_rec (clock, next_note, cur_note, loadn);
	song_recorder song_rec (reset_n, cur_note, song);
	vector_generator vec_gen (cur_note, next_vector);
	populate_pool populator (next_vector, pool);
	next_note_generator note_gen (pool, next_note);
endmodule

module vector_generator (cur_note, next_vector, do);
//it's essentially a huge mux
//outputs a probability vector containing possible next notes
//given current note. 
	input [4:0] cur_note; 
	output reg [0:27] next_vector;
	//format of next vector:
	//[16 bits for all posible states]*[128 bits to represent percentage] 
	parameter REST = 4'b0, D1 = 4'b1, B1 = 4'b2, Db2 = 4'b3, D2 = 4'b4, 
		E2 = 4'b5, F2 = 4'b6, Gb2 = 4'b7, G2 = 4'b8, A2 = 4'b9,
		Bb2 = 4'b10, B2 = 4'b11, C3 = 4'b12, Db3 = 4'b13, D3 = 4'b14, 
		E3 = 4'b15; REST = 0, D1 = 1, B1 = 2, Db2 = 3, D2 = 4, 
		E2 = 5, F2 = 6, Gb2 = 7, G2 = 8, A2 = 9,
		Bb2 = 10, B2 = 11, C3 = 12, Db3 = 13, D3 = 14, 
		E3 = 15;
	always @ (*)
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
			next_vector = {7'd100,  7'd0,  7'd0,  7'd0,   7'd0,
							     7'd0,  7'd0,  7'd0,  7'd0,   7'd0, 
								  7'd0,  7'd0,  7'd0,  7'd0,   7'd0, 
								  7'd0}; // E2
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
	int i, j, counter;
	assign counter = 0;
	input [0:27] next_vector;
	output reg [0:13] pool; 
	//pool is 128 * 4 bits
	//[100 spots for possible next notes] * [each note is 4 bits long]
	always @ (*)
		for (i = 0; i < 12; i = i + 1)
			for (j = 0; j < next_vector[(7 * i):(7 * i + 6)]; j = j + 1)
			//separate out each probability from the vector
				begin 
					pool [(4 * counter):(4 * counter + 3)] = i;
					counter = counter + 1;
				end
endmodule

module next_note_generator (pool, next_note);
	input [0:13] pool;
	output reg [3:0] next_note;
	reg [6:0] rand_num = $rand % 100; // 0 <= rand_num <= 99
	//write something to generate a random number
	always @ *
		assign next_note = pool [(rand_num * 4):(rand_num * 4 + 3)]; 
endmodule

module note_recorder(clock, D, Q, loadn);
//essentially a flip flop that saves the generated notes
//the load signal is controlled by a FSM
	input clock, loadn;
	input [3:0] D;
	output reg [3:0] Q;
	always @ (posedge clock)
	begin
		if (loadn != 0)
			Q <= D;
	end		
endmodule

module song_recorder(reset_n, cur_note, song);
	input [3:0] cur_note;
	input reset_n;
	output [1023:0] song;
	always @ (cur_note)
	if (reset_n == 0)
		song <= 1024'b0;
	else
		begin
			song >> 4; // right shift all the pitches by 4 bits
			song [1023:1020] <= cur_note;
		end
endmodule

