module TimerEcclesiaMorain (
  input CLOCK_50,
  input FPGA_RESET_N,
  input [9:0] SW,
  input [3:0] KEY,
  output [6:0] HEX0,
  output [6:0] HEX1,
  output [6:0] HEX2,
  output [6:0] HEX3,
  output [6:0] HEX4,
  output [6:0] HEX5,
  output [9:0] LEDR
);

// ==============================================
// CLOCK
// ==============================================
// wire clk_1Hz;
//clk_divider clk_div(CLOCK_50, clk_1Hz);
// ==============================================

// ==============================================
// Sequence Detector
// ==============================================
wire [3:0] state;
wire [3:0] ones_Secs,
			  tens_Secs,
			  ones_Mins,
			  tens_Mins;
//
seq_detector seqdet(
	.clock				(CLOCK_50),
	.reset				(FPGA_RESET_N),
	.input_0				(key0_press),
	.input_1				(key1_press),
	.SW					(SW),
	.y						(LEDR[0]),
	.onesSecDisp      (ones_Secs),
	.tensSecDisp      (tens_Secs),
	.onesMinDisp      (ones_Mins),
	.tensMinDisp      (tens_Mins),
	.state				(state)
);
// ==============================================

// ==============================================
// Key Press 0
// ==============================================
wire key0_press;
//
key_press key0p(
	.clock				(CLOCK_50),
	.key					(KEY[0]),
	.key_press			(key0_press)
);
// ==============================================

// ==============================================
// Key Press 1
// ==============================================
wire key1_press;
//
key_press key1p(
	.clock				(CLOCK_50),
	.key					(KEY[1]),
	.key_press			(key1_press)
);
// ==============================================

//seq_detector seqdet(CLOCK_50, ~FPGA_RESET_N, key0_press, key1_press, LEDR[0], state);


// Display the current state
dec2_7seg disp4(1'b0, HEX4);
dec2_7seg disp(state, HEX5);

//Display Seconds and Minutes
dec2_7seg disp0(ones_Secs, HEX0);
dec2_7seg disp1(tens_Secs, HEX1);
dec2_7seg disp2(ones_Mins, HEX2);
dec2_7seg disp3(tens_Mins, HEX3);

// Show the status of keys
assign LEDR[1] = ~FPGA_RESET_N;
assign LEDR[2] = KEY[0];
assign LEDR[3] = KEY[1];
// ==============================================

endmodule
