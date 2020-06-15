/*
    spram.v

    Access the 1024Kbit SPRAM on the ice40up5k.

*/

// Never forget this!
`default_nettype none

module spram(
    input clk,
    input resetn,

    input [16:0] addr,      // 17 bit address - 256K bits x 4 
    input wren,             // write enable
    input [15:0] data_in,   // 16 bit data input 
    output [15:0] data_out  // 16 bit data output
);

wire cs = 1'b1;
wire standby = 1'b0;
wire sleep = 1'b0;
wire pwroff = 1'b1;

wire [15:0] data_out0;
wire [15:0] data_out1;
wire [15:0] data_out2;
wire [15:0] data_out3;

// set mask based on high bits of address
wire [3:0] mask = 4'b1111; // this can be replaced by an input 

// The memory is used up in the following order
// spram0 -  {1'b0, 1b'0, 1'b0, addr[13:0]}
// spram1 -  {1'b0, 1b'0, 1'b1, addr[13:0]}
// spram2 -  {1'b0, 1b'1, 1'b0, addr[13:0]}
// spram3 -  {1'b1, 1b'1, 1'b1, addr[13:0]}

// so the write enable needs to only look at addr[15] and addr[14]
wire [3:0] wren_spram;
assign wren_spram[0] = ~addr[15] & ~addr[14] & wren;
assign wren_spram[1] = ~addr[15] &  addr[14] & wren;
assign wren_spram[2] =  addr[15] & ~addr[14] & wren;
assign wren_spram[3] =  addr[15] &  addr[14] & wren;

// data output is selected based on same memory order selection as above
reg [15:0] r_data_out;
assign data_out = r_data_out;
always @ (*) begin 
    case (addr[15:14])
        2'b00:      r_data_out = data_out0;

        2'b01:      r_data_out = data_out1;

        2'b10:      r_data_out = data_out2;

        2'b11:      r_data_out = data_out3;

        default:    r_data_out = data_out0;
    endcase
end 

SB_SPRAM256KA  spram0 (
    .DATAIN(data_in),
    .ADDRESS(addr[13:0]),
    .MASKWREN(mask),
    .WREN(wren),
    .CHIPSELECT(cs),
    .CLOCK(clk),
    .STANDBY(standby),
    .SLEEP(sleep),
    .POWEROFF(pwroff),
    .DATAOUT(data_out0)
);

SB_SPRAM256KA  spram1 (
    .DATAIN(data_in),
    .ADDRESS(addr[13:0]),
    .MASKWREN(mask),
    .WREN(wren),
    .CHIPSELECT(cs),
    .CLOCK(clk),
    .STANDBY(standby),
    .SLEEP(sleep),
    .POWEROFF(pwroff),
    .DATAOUT(data_out1)
);

SB_SPRAM256KA  spram2 (
    .DATAIN(data_in),
    .ADDRESS(addr[13:0]),
    .MASKWREN(mask),
    .WREN(wren),
    .CHIPSELECT(cs),
    .CLOCK(clk),
    .STANDBY(standby),
    .SLEEP(sleep),
    .POWEROFF(pwroff),
    .DATAOUT(data_out2)
);

SB_SPRAM256KA  spram3 (
    .DATAIN(data_in),
    .ADDRESS(addr[13:0]),
    .MASKWREN(mask),
    .WREN(wren),
    .CHIPSELECT(cs),
    .CLOCK(clk),
    .STANDBY(standby),
    .SLEEP(sleep),
    .POWEROFF(pwroff),
    .DATAOUT(data_out3)
);

endmodule