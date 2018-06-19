// CS3220 - Fall 2017
///////////////////////////////
// Amir Yazdanbakhsh
// Oct. 17th, 2017
// a.yazdanbakhsh@gatech.edu
///////////////////////////////
module key_press(
	// inputs and output
	input 					clock,
	input 					key,
	output 	 				key_press
);


reg key_sync;
reg key_sync_d;

always @(posedge clock)
begin
	key_sync 	<= ~key;
	key_sync_d 	<= key_sync;
end

assign key_press = key_sync && !key_sync_d;

endmodule