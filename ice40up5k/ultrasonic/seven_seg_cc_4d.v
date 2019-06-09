/*

  seven_seg_cc_4d.v

  Sends data to a 4 digit Common Cathode Seven Segment LED display.

*/

module seven_seg_cc_4d(

  input clk,                  // 2.96 MHz clock
  input [13:0] value,         // a 4 digit number

  output [3:0] cathodes,      // 0 (enable), 1 (disable)
  output [6:0] anodes        // Anodes - 7 lines 

);

  reg [3:0] reg_cathodes;
  reg [6:0] reg_anodes;

  reg [3:0] curr_digit_value = 0;
  reg [1:0] curr_digit_index = 0;

  // overflow at 2^16 - about 60 Hz at clk 2.96 MHz
`ifdef __ICARUS__
  reg [5:0] counter = 0;
`else 
  reg [13:0] counter = 0 ;
`endif

  // Currently shown digit index
  // D1 (MSD) D2 D3 D4 (LSD) 
  parameter D1 = 3;
  parameter D2 = 2;
  parameter D3 = 1;
  parameter D4 = 0;

  wire done;
  wire [19:0] value_bcd;

  bin_to_bcd bb1 (
    .clk(clk),
    .value_bin(value),
    .start(1'b1),
    .value_bcd(value_bcd),
    .done(done)
  );

  // turn on the current digit 
  always @ (posedge clk)
    begin 

      counter <= counter + 1;

      if (!counter)
        begin
          curr_digit_index <= curr_digit_index + 1;
        end
    end
/* - inefficient!

  // compute digit value and cathode lines
  // for current digit  
  always @ (*)
    begin
      case (curr_digit_index)
      D1: 
        begin
          curr_digit_value = (value / 1000) % 10;
          reg_cathodes = 4'b0111;
        end

      D2: 
        begin
          curr_digit_value = (value / 100) % 10;
          reg_cathodes = 4'b1011;
        end
      
      D3: 
        begin
          curr_digit_value = (value / 10) % 10;
          reg_cathodes = 4'b1101;
        end

      D4: 
        begin
          curr_digit_value = value % 10;
          reg_cathodes = 4'b1110;
        end

      endcase
    end
*/

  always @ (*)
    begin
      reg_cathodes = ~(4'b0001 << curr_digit_index);
      curr_digit_value = value_bcd[4*curr_digit_index +: 4];
    end

  //  digit to anode bits
  always @ (*)
    begin
      case (curr_digit_value)
        0: reg_anodes = 7'b1111110; // "0"
        1: reg_anodes = 7'b0110000; // "1"
        2: reg_anodes = 7'b1101101; // "2"
        3: reg_anodes = 7'b1111001; // "3"
        4: reg_anodes = 7'b0110011; // "4"
        5: reg_anodes = 7'b1011011; // "5"
        6: reg_anodes = 7'b1011111; // "6"
        7: reg_anodes = 7'b1110000; // "7"
        8: reg_anodes = 7'b1111111; // "8"
        9: reg_anodes = 7'b1111011; // "9"
        default: reg_anodes = 7'b1111110; // "0"
      endcase
    end

  assign cathodes = reg_cathodes;
  assign anodes = reg_anodes;

endmodule

