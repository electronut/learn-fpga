/*
    hvsync.v

    VGA module - 640 x 480

*/

// Never forget this!
`default_nettype none

module vga_640x480(
    input clk_25mhz,
    input resetn,
    
    output [9:0] hpos,     // [0, 639]
    output [9:0] vpos,     // [0, 479]
    output hsync,
    output vsync,    
    output display_valid   // 
); 

// Front Porch (FP)

parameter WIDTH = 640;
parameter HEIGHT = 480;

parameter H_FP = 16;   // pixels
parameter H_BP = 48;   // pixels
parameter H_PW = 96;   // pixels

parameter V_FP = 10;   // lines
parameter V_BP = 33;   // lines
parameter V_PW = 2;    // lines

parameter HSYNC_START = WIDTH + H_FP;
parameter HSYNC_END = WIDTH + H_FP + H_PW;

parameter VSYNC_START = HEIGHT + V_FP;
parameter VSYNC_END = HEIGHT + V_FP + V_PW;

// counters for horizontal and vertical 
reg [9:0] hpos;
reg [9:0] vpos;

// horizontal sync 
assign hsync = ~((hpos >= HSYNC_START) && (hpos <= HSYNC_END));
// vertical sync 
assign vsync = ~((vpos >= VSYNC_START) && (vpos < VSYNC_END));

// display valid only in certain range
assign display_valid = (hpos >= 0 && hpos < WIDTH) && 
    (vpos >= 0 && vpos < HEIGHT);

always @ (posedge clk_25mhz) begin 

    if (!resetn) begin 
       hpos <= 10'd0;
       vpos <= 10'd0;
    end
    else begin 

        // increment horizontal count
        hpos <= hpos + 1;

        // reset hpos end of the line 
        if (hpos == (H_FP + H_PW + H_BP + WIDTH - 1)) begin 
            // reset 
            hpos <= 10'd0;
            // add a line
            vpos <= vpos + 1;
        end 

        // reset line count end of video frame 
        if (vpos == (V_FP + V_PW + V_BP + HEIGHT - 1)) begin 
            vpos <= 10'd0;
        end 

    end 

end 

endmodule
