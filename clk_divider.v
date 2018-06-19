`timescale 1ns/1ps
/*
* clk_divider module
*/
module clk_divider #(
  parameter INPUT_FREQUENCY         = 50000000,
  parameter OUTPUT_FREQUENCY        = 1
)
(
  input  wire                       clk_in,
  output reg                        clk_out
);

//==================================
  localparam COUNTER_WIDTH = $clog2(INPUT_FREQUENCY / OUTPUT_FREQUENCY / 2);
 //==================================
 
 //==================================
  wire [COUNTER_WIDTH-1:0] max_count;
  wire done;
//==================================

//==================================
  assign max_count = INPUT_FREQUENCY / OUTPUT_FREQUENCY / 2;
//==================================

//==================================
  up_down_counter #(
    .COUNTER_WIDTH                ( COUNTER_WIDTH         )
  ) clk_divider_counter (
    .clk                          ( clk_in                ),
    .reset                        ( 1'b0                  ),
    .enable                       ( 1'b1                  ),
    .up_down                      ( 1'b1                  ),
    .max_count                    ( max_count             ),
    .done                         ( done                  ),
    .count_out                    (                       )
  );
//==================================

//==================================
  always @(posedge clk_in)
  begin: GENERATE_OUTPUT_CLOCK
    if (done)
      clk_out <= !clk_out;
  end
//==================================

endmodule
