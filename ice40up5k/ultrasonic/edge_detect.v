/*

    edge_detect.v

*/

module edge_detect(
    input clk, 
    input sig,
    output pos,
    output neg
);

  reg sig_delay = 0;

  // delay by one clock
  always @ (posedge clk)
    begin

      sig_delay <= sig;

    end

  // detect positive edge
  assign pos = sig & ~sig_delay;

  // detect negative edge
  assign neg = ~sig & sig_delay;

endmodule