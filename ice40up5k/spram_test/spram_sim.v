/*
    spram_sim.v

    Simulate the 1024Kbit SPRAM on the ice40up5k.

*/

// Never forget this!
`default_nettype none

module spram_sim(
    input clk,
    input resetn,

    input [16:0] addr,      // 17 bit address - 256K bits x 4 
    input wren,             // write enable
    input [15:0] data_in,   // 16 bit data input 
    output [15:0] w_data_out  // 16 bit data output
);


// simulated memory just has 16 x 16-bit words 
// will use LSB 4 bits of addr to read/write 
reg [15:0] mem [0:15];

reg [15:0] data_out;
assign w_data_out = data_out;

integer ii;
initial begin 

    for (ii = 0; ii < 16; ii = ii + 1) begin 
        mem[ii] = 16'd10;
    end 

end 

always @ (posedge clk) begin 

    if (!resetn) begin 
        data_out <= 16'd0;
    end 
    else begin
        if (wren) begin 
            mem[addr[3:0]] <= data_in;
        end 
        // set output 
        data_out <= mem[addr[3:0]];
    end 
end 


endmodule