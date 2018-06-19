// Georgia Institute of Technology
// School of Computer Science
// CS 3220
// Verilog Code for BCD to 7-Segment Conversion

module dec2_7seg (
	input		[3:0] 		num,
	output		[6:0]		display
);

assign display = 
		num == 0 ? ~7'b011_1111 :
		num == 1 ? ~7'b000_0110 :
		num == 2 ? ~7'b101_1011 :
		num == 3 ? ~7'b100_1111 :
		num == 4 ? ~7'b110_0110 :
		num == 5 ? ~7'b110_1101 :
		num == 6 ? ~7'b111_1101 :
		num == 7 ? ~7'b000_0111 :
		num == 8 ? ~7'b111_1111 :
		num == 9 ? ~7'b110_0111 :
					7'bxxx_xxxx ; // Output is a don't care if illegal input is provided

endmodule
