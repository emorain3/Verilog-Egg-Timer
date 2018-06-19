// CS3220 - Fall 2017
///////////////////////////////
// Amir Yazdanbakhsh and Ecclesia Morain
// Oct. 17th, 2017
// a.yazdanbakhsh@gatech.edu
///////////////////////////////
module seq_detector(
	// inputs and output
	input 				clock,
	input					reset,
	input 				input_0, // KEY[0]
	input					input_1, // KEY[1]
	input	[9:0]			SW, //SW
	output reg 			y, // blink LED
	output reg [3:0]		onesSecDisp,
	output reg [3:0]		tensSecDisp,
	output reg [3:0]		onesMinDisp,
	output reg [3:0]		tensMinDisp,
	output reg [3:0]	state 
);

// internal constants
parameter SIZE 	= 4;
parameter RESET 	= 4'b0000,
		SET_SEC 		= 4'b0001,
		SET_MIN 		= 4'b0010,
		COUNTDOWN_SEC_ONES 	= 4'b0011,
		COUNTDOWN_SEC_TENS	= 4'b0100,
		COUNTDOWN_MIN_ONES	= 4'b0101,
		COUNTDOWN_MIN_TENS	= 4'b0110,
		TIMER_DONE	= 4'b0111,
		TIMER_PAUSE	= 4'b1000;
///////////////////////////////

// internal variables
//wire 	 w1, w2, w3, w4, d1, d2, d3, d4;
reg 	[SIZE - 1 : 0] 		next_state, 
									paused_state;
reg				next_y,
					//enable_sec_ones,
					secs_complete,
					mins_complete,
					ten_mins_complete,
					sec_tens_updated,
					min_ones_updated,
					min_tens_updated;
reg[3:0] next_tensMin,
			next_onesMin,
			next_tensSec,
			next_onesSec;
wire clk_1Hz;
clk_divider clk_div(clock, clk_1Hz);
///////////////////////////////
//COUNTERS

///////////////////////////////

// Handle State Control 
always @(posedge clock)
begin
	if (reset == 1'b0) begin
		state <= RESET;
	end
	else
		state <= next_state;
		
		//y <= next_y;
end



// Output Control | Update Display
always @(posedge clock)
begin
			tensMinDisp = next_tensMin;
			onesMinDisp = next_onesMin;
			tensSecDisp = next_tensSec;
			onesSecDisp = next_onesSec;
end



// Internal State Operations 
always @(posedge clk_1Hz)
begin
	case(state)
		RESET: begin 
			next_tensMin = 0;
			next_onesMin = 0;
			next_tensSec = 0;
			next_onesSec = 0;
		end
		SET_SEC: begin 
			if(SW[7:4] >= 5) begin
						next_tensSec = 5;
					end
			else begin
						next_tensSec = SW[7:4];
					end
					
			if(SW[3:0] >= 9) begin
						next_onesSec = 9;
					end
			else begin
						next_onesSec= SW[3:0];
					end
		end
		SET_MIN: begin 
			if(SW[7:4] >= 9) begin
						next_tensMin = 9;
					end
			else begin
						next_tensMin = SW[7:4];
					end
					
			if(SW[3:0] >= 9) begin
						next_onesMin = 9;
					end
			else begin
						next_onesMin = SW[3:0];
					end
		end
		COUNTDOWN_SEC_ONES: begin 
			next_onesSec = next_onesSec - 1;
			sec_tens_updated = 0;
			min_ones_updated = 0;
			min_tens_updated = 0;
			if (next_tensSec == 0) begin
				secs_complete = 1;
			end
			if (next_onesMin == 0) begin
				mins_complete = 1;
			end
			if (next_tensMin == 0) begin
				ten_mins_complete = 1;
			end
		end
		COUNTDOWN_SEC_TENS: begin 
			next_tensSec = next_tensSec - 1;
			next_onesSec = 9;
			if (next_tensSec == 0) begin
				secs_complete = 1;
			end
			sec_tens_updated = 1;
		end
		COUNTDOWN_MIN_ONES: begin
			next_onesMin = next_onesMin - 1;
			next_onesSec = 9;
			next_tensSec = 5;
			if (next_onesMin == 0) begin
				mins_complete = 1;
			end
			secs_complete = 0;
			min_ones_updated = 1;
		end
		COUNTDOWN_MIN_TENS: begin
			next_tensMin = next_tensMin - 1;
			next_onesSec = 9;
			next_tensSec = 5;
			next_onesMin = 9;
			if (next_tensMin == 0) begin
				ten_mins_complete = 1;
			end
			mins_complete = 0;
			min_tens_updated = 1;
		end
		TIMER_DONE: begin
			y = ~next_y;
			secs_complete = 0;
			mins_complete = 0;
			ten_mins_complete = 0;
		end
	endcase
end



// Control Flow
always @(*) // Updates whenever any of the control signals w/in block update. I think.
begin
	next_state = state;
	next_y = y;
	case(state)
		RESET: begin
			if (input_1) begin		
				next_state = SET_SEC;
			end
			else if (input_0) begin
				next_state = RESET;
			end		
		end
		SET_SEC: begin
			if (input_1)
				next_state = SET_MIN;
			else if (input_0)
				next_state = RESET;
		end
		SET_MIN: begin // When we enter this state the onseSec is detracted by one.
			if (input_1)
				next_state = COUNTDOWN_SEC_ONES;
			else if (input_0)
				next_state = RESET;
		end
		COUNTDOWN_SEC_ONES: begin 
			
			if (input_0) begin
				next_state = RESET;
				end
			else if (input_1) begin
				paused_state = COUNTDOWN_SEC_ONES;
				next_state = TIMER_PAUSE;
				end
			else if (next_onesSec != 0) begin 
				next_state = COUNTDOWN_SEC_ONES;
				end
			else if (next_onesSec == 0 && secs_complete == 0) begin
				next_state = COUNTDOWN_SEC_TENS;
				end
			else if (next_onesSec == 0 && secs_complete == 1 && mins_complete == 0) begin
				next_state = COUNTDOWN_MIN_ONES;
			end
			else if (next_onesSec == 0 && secs_complete == 1 && mins_complete == 1 && ten_mins_complete == 0) begin
				next_state = COUNTDOWN_MIN_TENS;
			end
			else if (next_onesSec == 0 && secs_complete == 1 && mins_complete == 1 && ten_mins_complete == 1) begin
				next_state = TIMER_DONE;
			end
	
		end
		
		COUNTDOWN_SEC_TENS: begin
		
			if (input_0) begin
				next_state = RESET;
				end
			else if (sec_tens_updated == 1) begin // Prevents changing to SEC_ONES state before this state's completion
				next_state = COUNTDOWN_SEC_ONES;
			end			
		end
		COUNTDOWN_MIN_ONES: begin
			
			if (input_0) begin
					next_state = RESET;
					end
			else if (min_ones_updated == 1) begin // Prevents changing to SEC_ONES state before this state's completion
				next_state = COUNTDOWN_SEC_ONES;
			end		
		end
		COUNTDOWN_MIN_TENS: begin
			
			if (input_0) begin
					next_state = RESET;
					end
			else if (min_tens_updated == 1) begin
				next_state = COUNTDOWN_SEC_ONES;
			end				
		end
		TIMER_PAUSE: begin
			if (input_0) begin
				next_state = RESET;
				end
			else if (input_1) begin
				next_state = paused_state;
				end
		end
		TIMER_DONE: begin
			
			if (input_0) begin
				next_state = RESET;
			end
		end
		default: next_state = RESET;
	endcase
end

endmodule
