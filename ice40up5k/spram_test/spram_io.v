/*
    spram_io.v

    read/write module for spram

*/

// Never forget this!
`default_nettype none

module spram_io(
    input clk,
    input resetn,

    input [9:0] hpos,     // [0, 639]
    input [9:0] vpos,     // [0, 479]

    output [3:0] r,
    output [3:0] g,
    output [3:0] b,

    output data_ready     // high when ram is ready to be read
);

reg [16:0] addr;      // 17 bit address - 256K bits x 4 
wire [16:0] w_addr = addr;
reg wren;             // write enable
wire w_wren = wren;
reg [15:0] data_in;   // 16 bit data input 
wire [15:0] w_data_in = data_in;
wire [15:0] data_out;  // 16 bit data output

`ifdef __ICARUS__
spram_sim spr (
    .clk(clk),
    .resetn(resetn),
    .addr(w_addr),
    .wren(w_wren),
    .data_in(w_data_in),
    .w_data_out(data_out)
);
`else
// instantiate spram 
spram spr (
    .clk(clk),
    .resetn(resetn),
    .addr(w_addr),
    .wren(w_wren),
    .data_in(w_data_in),
    .data_out(data_out)
);
`endif

// 4 bit colour map 
wire [3:0] cin;    // 4 bit index
reg [11:0] cout;    // 12 bit RGB 444 output

always @ (*) begin 

    case (cin)

    0:  cout = {4'b1111, 4'b0000, 4'b0000}; // red 
    1:  cout = {4'b0000, 4'b1111, 4'b0000}; // green 
    2:  cout = {4'b0000, 4'b0000, 4'b1111}; // blue  
    3:  cout = {4'b1111, 4'b1111, 4'b1111}; // white
    4:  cout = {4'b0000, 4'b0000, 4'b0000}; // black
    5:  cout = {4'b1000, 4'b1000, 4'b1000}; // gray
    6:  cout = {4'b1111, 4'b0000, 4'b1111}; // violet  
    7:  cout = {4'b1111, 4'b1111, 4'b0000}; // yellow
    8:  cout = {4'b0000, 4'b1111, 4'b1111}; // cyan
    9:  cout = {4'b1100, 4'b1100, 4'b1100}; // silver
    10:  cout = {4'b1000, 4'b0000, 4'b0000}; // maroon
    11:  cout = {4'b1000, 4'b1000, 4'b0000}; // olive
    12:  cout = {4'b0000, 4'b1000, 4'b0000}; // green 2    
    13:  cout = {4'b0000, 4'b1000, 4'b1000}; // teal
    14:  cout = {4'b0000, 4'b0000, 4'b1000}; // navy
    15:  cout = {4'b0111, 4'b0000, 4'b0111}; // purple

    default: cout = {4'b0000, 4'b1100, 4'b0000};  
    endcase

end 

parameter sSTART    = 3'd0;
parameter sLOAD     = 3'd1;
parameter sWAIT     = 3'd2;
parameter sREADY    = 3'd3;
reg [2:0] state;

// high when loading is done 
assign data_ready = (state == sREADY) ? 1'b1 : 1'b0;

// get data index - frame is 320x240
// (data) index = (pixel_index*4) / 16 = pixel_index >> 2
wire [16:0] pixel_index = vpos*320 + hpos;
wire [16:0] index = pixel_index >> 2;

// extract 4-bit value colour from stored 16-bit data
assign cin  = data_out[4*pixel_index[1:0] +: 4];
                    
// set colour value 
assign {r, g, b} = {cout[11:8], cout[7:4], cout[3:0]};

// color index
reg [3:0] cindex;

`ifdef __ICARUS__
parameter ADDR_MAX = 17'd32; // (320*240*4)/16
`else 
parameter ADDR_MAX = 17'd19200; // (320*240*4)/16
`endif

// no. of clock cycles to wait after write 
reg [10:0] nwait;

always @ (posedge clk) begin 

    if (!resetn) begin 

        // set to write
        wren <= 1'b1;

        cindex <= 0;

        // initial state 
        state <= sSTART;

        // init address
        addr <= 17'd0;

        // data in
        data_in <= 16'd0; 

        nwait <= 0;

        cindex <= 0;

    end 
    else begin 

        case (state)  

            sSTART: begin 

                // set to write mode
                wren <= 1'b1;

                // switch to ready state 
                state <= sLOAD;

            end 

            sLOAD: begin 

                // done loading 
                if (addr == (ADDR_MAX-1)) begin 

                    // set to read mode
                    wren <= 1'b0;

                    // set addr
                    addr <= index; 

                    // switch to ready state 
                    state <= sWAIT;
                end 
                else begin
                    // fill with colour indices
                    addr <= addr + 17'd1;
                    
                    data_in <= {4{cindex + 4'd1}}; 

                    cindex <= cindex + 4'd1;
                end 

            end 

            sWAIT: begin 

                // wait for n cycles
                // then switch to next state
                if (nwait == 7) begin 
                    // next state 
                    state <= sREADY;
                end 
                else begin 
                    // count 
                    nwait <= nwait + 1;
                end 
            end 

            sREADY: begin

                // set read address
                addr <= index; 
            end 

            default:
                state <= sLOAD;

        endcase

    end 
end 

endmodule
