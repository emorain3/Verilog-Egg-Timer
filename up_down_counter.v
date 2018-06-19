`timescale 1ns/1ps
/*
* up_down_counter module
* Counts up/down to a max/min value.
*/
module up_down_counter #(
  parameter COUNTER_WIDTH           = 4
)
(
  input                             clk,
  input                             reset,

  input                             enable,

  input                             up_down,

  input  [ COUNTER_WIDTH -1 : 0 ]   max_count,

  output                            done,

  output [ COUNTER_WIDTH -1 : 0 ]   count_out
);

  reg [ COUNTER_WIDTH -1 : 0 ] count = 'b0;

  always@(posedge clk)
  begin
    if (reset)
      count <= 0;
    else if (enable)
    begin
      if (up_down)
      begin: COUNT_UP
        if (done)
          count <= 'b0;
        else
          count <= count + 1'b1;
      end
      else
      begin: COUNT_DOWN
        if (done)
          count <= max_count;
        else
          count <= count - 1;
      end
    end
  end

  assign count_out = count;
  assign done = up_down ? count == max_count : count == 'b0;

endmodule
