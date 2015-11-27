module SoloMaster();
endmodule

module song_generator (CLOCK_50, SW, song);
	//numerical representation of different pitches
	parameter REST = 4'd0, D1 = 4'd1, B1 = 4'd2, Db2 = 4'd3, D2 = 4'd4, 
		E2 = 4'd5, F2 = 4'd6, Gb2 = 4'd7, G2 = 4'd8, A2 = 4'd9,
		Bb2 = 4'd10, B2 = 4'd11, C3 = 4'd12, Db3 = 4'd13, D3 = 4'd14, 
		E3 = 4'd15; 
		
	//states: one hot encoding 
	parameter start_new_song = 2'b01, create_new_note = 2'b01;
	input CLOCK_50; 
	input [3:0] SW;
	reg loadn, reset_n;//control signals for data path
	wire [0:39] pool;
	wire [3:0] cur_note, next_note, rand_num;
	wire new; //boolean representing whether a new song should be generated
	wire [7:0] count;
	reg [2:0] cur_state, next_state;
	
	output reg [1023:0] song; // stores all the pitches 
	
	assign cur_note = REST;
	
	assign new = SW[3:3]; //switch 3 determines whether or not to start a new song
	
	//state transitions
	always @ *
	case (cur_state)
		start_new_song: 
			begin
				if (new == 1)
					next_state = start_new_song;
				else
					next_state = create_new_note;
			end
		create_new_note:
			begin 
				if (count < 256)
					next_state = create_new_note;	
				else 
					next_state = start_new_song;
			end
	endcase
	
	//state flip flops
	always @ (posedge CLOCK_50)
		cur_state <= next_state;
		
	//logic output
	always @ *
	case (cur_state)
		start_new_song:
			begin
				 reset_n = 0; //set count to 0
				 loadn = 1; //don't start clock in new notes yet
			end
		create_new_note:
			begin
				 reset_n = 1; //allows counter to run
				 loadn = 0; //clock in new notes
			end
	endcase
	
	counter c (count, CLOCK_50, reset_n);
	note_recorder note_rec (clock, next_note, cur_note, loadn);
	song_recorder song_rec (reset_n, cur_note, song);
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
	output reg [0:39] pool; 
	//pool is 10 * 4 bits
	//[10 spots for possible next notes] * [each note is 4 bits long]
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
					  REST, REST, REST, REST,  D3};
	endcase
endmodule

module next_note_generator (pool, next_note);
	input [0:39] pool;
	output reg [3:0] next_note;
	reg [3:0] rand_num;
	//input [3:0] rand_num; // 0 <= rand_num <= 9
	//write something to generate a random number
	always @ *
	begin
		rand_num = $random % 10;
		next_note = pool [(rand_num * 4)+: 4]; 
	end
endmodule

module note_recorder(clock, D, Q, loadn);
//essentially a flip flop that saves the generated notes
//the load signal is controlled by a FSM
	input clock, loadn;
	input [3:0] D;
	output reg [3:0] Q;
	always @ (negedge clock)
	begin
		if (loadn == 0)
			Q <= D;
	end		
endmodule

module song_recorder(reset_n, cur_note, song);
	input [3:0] cur_note;
	input reset_n;
	output reg [1023:0] song;
	always @ (cur_note)
	if (reset_n == 0)
		song <= 1024'b0;
	else
		begin
			song <= song >> 4; 
			// right shift all the pitches by 4 bits
			song [1023:1020] <= cur_note;
		end
endmodule

module counter (Q, clk, reset_n);
	input clk, reset_n;
	output reg [7:0] Q; //each song is 256 notes long 
	always @ (posedge clk)
	if (reset_n == 0)
		Q <= 7'b0;
	else 
		Q <= Q + 1;
endmodule

module fibonacci_lfsr(
  input  clk,
  input  rst_n,
  output reg [4:0] data
);

wire feedback = data[4] ^ data[1] ;

always @(posedge clk or negedge rst_n)
  if (~rst_n) 
    data <= 4'hf;
  else
    data <= {data[3:0], feedback} ;
endmodule
