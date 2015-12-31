module SoloMaster(
    // Inputs
    CLOCK_50,
    KEY,
    AUD_ADCDAT,
    // Bidirectionals
    AUD_BCLK,
    AUD_ADCLRCK,
    AUD_DACLRCK,
    I2C_SDAT,
    // Outputs
    AUD_XCK,
    AUD_DACDAT,
    I2C_SCLK,
    SW
);

// Inputs
input	CLOCK_50;
input	CLOCK_27;
input  [3:0] KEY;
input  [9:0] SW;
input	AUD_ADCDAT;

// Bidirectionals
inout	AUD_BCLK;
inout	AUD_ADCLRCK;
inout	AUD_DACLRCK;
inout	I2C_SDAT;

// Outputs
output	AUD_XCK;
output	AUD_DACDAT;
output	I2C_SCLK;

// Internal Wires
wire	audio_in_available;
wire  [31:0] left_channel_audio_in;
wire  [31:0] right_channel_audio_in;
wire	read_audio_in;
wire	audio_out_allowed;
wire  [31:0] left_channel_audio_out;
wire  [31:0] right_channel_audio_out;
wire	write_audio_out;

// Internal Registers
reg [18:0] delay_cnt, delay;
reg snd;

// Tempo
reg [25:0] tempo_count,temp,tempo;
reg pass_note;
wire [1:0] rand_tempo;

always @ *
case(SW[9:8])
1:temp=26'd 37500000;   //80
2:temp=26'd 33333333;   //90
3:temp=26'd 30000000;   //100
default temp=19'd 0;
endcase

tempo_random tr (CLOCK_50,SW[0],rand_tempo);

always @ *
begin
 tempo = temp/rand_tempo;
end

//Tempo register
always @(posedge CLOCK_50)
begin
if(tempo_count == tempo)
  begin
	tempo_count <=0;
	pass_note=1;
  end
else
  begin
	tempo_count=tempo_count+1;
	pass_note =0;
  end
end

// Pass note
reg [3:0] note;
integer i;

song_generator s (pass_note, SW[0], note);

// Note register
always @(posedge CLOCK_50)
     if(delay_cnt == delay) 
        begin
        delay_cnt <= 0;
        snd <= !snd;
        end 
     else  
         delay_cnt <= delay_cnt + 1;

 always @ *
    case (note)
        1: delay = 19'd 342466/2;
        2: delay = 19'd 202477/2;
        3: delay = 19'd 180386/2;
        4: delay = 19'd 170262/2;
        5: delay = 19'd 151686/2;
        6: delay = 19'd 143173/2;
        7: delay = 19'd 135137/2;
        8: delay = 19'd 127552/2;
        9: delay = 19'd 113636/2;
        10: delay = 19'd 107258/2;
        11: delay = 19'd 101238/2;
        12: delay = 19'd 95556/2;
        13: delay = 19'd 90193/2;
        14: delay = 19'd 85131/2;
        15: delay = 19'd 75843/2;
        default: delay = 19'd 0;
    endcase
                
wire [31:0] sound = (delay == 0) ? 0 : snd ? 32'd10000000 : -32'd10000000;

// Audio controller
assign read_audio_in   = audio_in_available & audio_out_allowed;
assign left_channel_audio_out = left_channel_audio_in+sound;
assign right_channel_audio_out = right_channel_audio_in+sound;
assign write_audio_out   = audio_in_available & audio_out_allowed;

Audio_Controller Audio_Controller (
 // Inputs
 .CLOCK_50  	(CLOCK_50),
 .reset  	(~KEY[0]),
 .clear_audio_in_memory  (),
 .read_audio_in	(read_audio_in),

 .clear_audio_out_memory  (),
 .left_channel_audio_out  (left_channel_audio_out),
 .right_channel_audio_out (right_channel_audio_out),
 .write_audio_out   (write_audio_out),
 .AUD_ADCDAT 	(AUD_ADCDAT),

 // Bidirectionals
 .AUD_BCLK 	(AUD_BCLK),
 .AUD_ADCLRCK	(AUD_ADCLRCK),
 .AUD_DACLRCK	(AUD_DACLRCK),

 // Outputs
 .audio_in_available   (audio_in_available),
 .left_channel_audio_in  (left_channel_audio_in),
 .right_channel_audio_in  (right_channel_audio_in),
 .audio_out_allowed   (audio_out_allowed),
 .AUD_XCK 	(AUD_XCK),
 .AUD_DACDAT 	(AUD_DACDAT),
);
avconf #(.USE_MIC_INPUT(1)) avc (
 .I2C_SCLK 	(I2C_SCLK),
 .I2C_SDAT 	(I2C_SDAT),
 .CLOCK_50 	(CLOCK_50),
 .reset  	(~KEY[0])
);
endmodule

module note_generator(
  input  CLOCK,
  input  [0:0]SW,
  output reg [3:0] cur_note
);
    reg [3:0] note;
    wire feedback = note[3] ^ note[1] ;

    reg [3:0] next_note;
    always @(posedge CLOCK)
    begin
        if (~SW[0])
            note <= 4'hf;
        else
            note <= {note[2:0], feedback} ;
        cur_note <= next_note;
    end

    parameter REST = 4'd0, D1 = 4'd1, B1 = 4'd2, Db2 = 4'd3, D2 = 4'd4,
            E2 = 4'd5, F2 = 4'd6, Gb2 = 4'd7, G2 = 4'd8, A2 = 4'd9,
            Bb2 = 4'd10, B2 = 4'd11, C3 = 4'd12, Db3 = 4'd13, D3 = 4'd14,
            E3 = 4'd15;

    reg [59:0] pool;
        //pool is 15 * 4 bits
        //[15 spots for possible next notes] * [each note is 4 bits long]
    always @ (*)
        case (cur_note)
            REST:
                    pool = {D1, D1, Db3, Db2, Db2,
                            D2, Gb2, Db3, Db3, A2,
                            D2, Gb2, Db3, Db3, A2};
            D1:
                    pool = {A2, A2, A2, A2, A2,
                            A2, A2, A2, A2, A2,
                            A2, A2, A2, A2, A2};
            B1:
                    pool = {D1, Db2, D2, D2, D2,
                            D2, Bb2, Bb2, D1, Db2,
                            D2, Bb2, D2, D1, Db2};
            Db2:
                    pool = {D2, Bb2, D2, Bb2, D2,
                            Gb2, Gb2, Gb2, Gb2, Gb2,
                            D2, Bb2, D2,Gb2, Gb2};
            D2:
                    pool = {REST, B1, B1, B1, REST,
                            Gb2, Gb2, Gb2, A2, A2,
                            A2, A2, B2, B2, B2};
            E2:
                    pool = {REST, Bb2, Bb2, REST, REST,
                            REST, D1, D1, D1, REST,
                            REST, REST, REST, REST, REST};
            F2:
                    pool = {Db3, Db3, Db3, REST, REST,
                            G2, G2, REST, REST, REST,
                            G2, Db3, G2, Db3, G2};
            Gb2:
                    pool = {REST, B1, D2, D2, D2,
                            A2, Bb2, A2, Bb2, Db3,
                            A2, A2, A2, Bb2, Db3};
            G2:
                    pool = {F2, F2, F2, Gb2, Gb2,
                            Gb2, A2, E2, A2, A2,
                            Gb2, Gb2, Gb2, A2, A2};
            A2:
                    pool = {REST, REST, REST, F2, Gb2,
                            Gb2, Gb2, Gb2, G2, C3,
                            Gb2, Gb2, Gb2, G2, C3};
            Bb2:
                    pool = {REST, A2, REST, REST, REST,
                            REST, E2, E2, E2, REST,
                            Db3, Db3, Db3, REST, REST};//
            B2:
                    pool = {REST, A2, A2, A2, A2,
                            A2, A2, A2, A2, E3,
                            A2, A2, A2, A2, E3};//
            C3:
                    pool = {A2, A2, A2, A2, A2,
                            E3, C3, C3, E3, E3, 
                            C3, C3, A2, E3, E3};//
            Db3:
                    pool = {REST, D2, A2, Bb2, B2,
                            B2, D3, D3, E3, E3,
                            B2, D3, D3, E3, E3};//
            D3:
                    pool = {A2, B2, B2, B2, B2,
                            B2, B2, B2, B2, B2,
                            A2, B2, B2, B2, B2,};
            E3:
                    pool = {REST, C3, REST, REST, REST,
                            REST, C3, C3, REST,  D3,
                            C3, C3, REST, REST,  D3};
        endcase
   
 always @ *
        next_note = pool [(note * 4)+: 4];
 
endmodule

module tempo_random(
  input  CLOCK,
  input  [0:0]SW,
  output reg [1:0] tempo
);//generate a random tempo

wire feedback = tempo[0] ^ tempo[1] ;

always @(posedge CLOCK)
    if (~SW[0])
	tempo <= 4'hf;
    else
	tempo <= {tempo[0:0], feedback} ;
endmodule

