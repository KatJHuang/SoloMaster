module SoloMaster (); // top entity

endmodule 

module song_generator (CLOCK_50, song);
	//numerical representation of different pitches
	parameter REST = 4'd0, D1 = 4'd1, B1 = 4'd2, Db2 = 4'd3, D2 = 4'd4, 
		E2 = 4'd5, F2 = 4'd6, Gb2 = 4'd7, G2 = 4'd8, A2 = 4'd9,
		Bb2 = 4'd10, B2 = 4'd11, C3 = 4'd12, Db3 = 4'd13, D3 = 4'd14, 
		E3 = 4'd15; 
		
	//states: one hot encoding 
	parameter new_song = 3'b001, create_new_note = 3'b010, stop = 3'b100;
	input CLOCK_50; 
	wire [0:13] pool;
	wire [3:0] cur_note, next_note;
	reg loadn, reset_n;//control signals for data path
	reg [7:0] counter;
	reg [2:0] cur_state, next_state;
	output reg [1023:0] song; // stores all the pitches 
	
	assign cur_note = REST;
   counter = 0; 
	
	//state transitions
	always @ *
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
				if (reset_n == 0)
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
	//vector_generator vec_gen (cur_note, next_vector);
	populate_pool populator (cur_note, pool);
	next_note_generator note_gen (pool, next_note);
endmodule

module populate_pool (cur_note, pool);
parameter REST = 4'd0, D1 = 4'd1, B1 = 4'd2, Db2 = 4'd3, D2 = 4'd4, 
		E2 = 4'd5, F2 = 4'd6, Gb2 = 4'd7, G2 = 4'd8, A2 = 4'd9,
		Bb2 = 4'd10, B2 = 4'd11, C3 = 4'd12, Db3 = 4'd13, D3 = 4'd14, 
		E3 = 4'd15;
	assign counter = 0;
	input [3:0] cur_note;
	output reg [0:13] pool; 
	//pool is 128 * 4 bits
	//[100 spots for possible next notes] * [each note is 4 bits long]
	always @ (*)
	case (cur_note)
		REST:
			pool = {REST, REST, REST, REST, REST,
					  REST, REST, REST, REST, REST};
		D1:
			pool = {REST, REST, REST, REST, REST,
					  REST, REST, REST, REST, REST};
		B1:
			pool = {REST, REST, REST, REST, REST,
					  REST, REST, REST, REST, REST};
		Db2:
			pool = {REST, REST, REST, REST, REST,
					  REST, REST, REST, REST, REST};
		D2:
			pool = {REST, REST, REST, REST, REST,
					  REST, REST, REST, REST, REST};
		E2:
			pool = {REST, REST, REST, REST, REST,
					  REST, REST, REST, REST, REST};
		F2:
			pool = {REST, REST, REST, REST, REST,
					  REST, REST, REST, REST, REST};
		Gb2:
			pool = {REST, REST, REST, REST, REST,
					  REST, REST, REST, REST, REST};
		G2:
			pool = {REST, REST, REST, REST, REST,
					  REST, REST, REST, REST, REST};
		A2:
			pool = {REST, REST, REST, REST, REST,
					  REST, REST, REST, REST, REST};
		Bb2:
			pool = {REST, REST, REST, REST, REST,
					  REST, REST, REST, REST, REST};
		B2:
			pool = {REST, REST, REST, REST, REST,
					  REST, REST, REST, REST, REST};
		C3:
			pool = {REST, REST, REST, REST, REST,
					  REST, REST, REST, REST, REST};
		Db3:
			pool = {REST, REST, REST, REST, REST,
					  REST, REST, REST, REST, REST};
		D3:
			pool = {REST, REST, REST, REST, REST,
					  REST, REST, REST, REST, REST};
		E3:
			pool = {REST, REST, REST, REST, REST,
					  REST, REST, REST, REST, REST};
	endcase
endmodule

module next_note_generator (pool, next_note);
	input [0:13] pool;
	output reg [3:0] next_note;
	reg [6:0] rand_num = 5; // 0 <= rand_num <= 99
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