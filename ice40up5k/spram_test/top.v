/*
    top.v

    Top module for VGA test 

*/

// Never forget this!
`default_nettype none

module top (    
    input  clk,

    output [3:0] r,
    output [3:0] g,
    output [3:0] b,
    output hsync_out,
    output vsync_out,
    
    output reg LED_B // debug 
);  

    // generate 25 MHz clock 
    wire locked;
    wire pll_clk;
    pll pll_25mhz(
        .clock_in(clk),
        .clock_out(pll_clk),
        .locked(locked)
        );

    // BEGIN - init hack
    // iCE40 does not allow registers to initialised to 
    // anything other than 0
    // For workaround see:
    // https://github.com/YosysHQ/yosys/issues/103
    reg [7:0] resetn_counter = 0;
    wire resetn = &resetn_counter;

    always @(posedge pll_clk) 
    begin
        if (!resetn)
            resetn_counter <= resetn_counter + 1;
    end
    // END - init hack

    wire [9:0] hpos;
    wire [9:0] vpos;

    wire hsync;
    wire vsync;

    wire display_valid;

    // instantiate VGA module 
    vga_640x480 vga (
        .clk_25mhz(pll_clk),
        .resetn(resetn),
        .hpos(hpos),
        .vpos(vpos),
        .hsync(hsync),
        .vsync(vsync),
        .display_valid(display_valid)
    );


    // delay VGA signal to give a chance to read from BRAM
    parameter NSR = 3;
    reg [NSR-1:0] hsync_sr;
    reg [NSR-1:0] vsync_sr;
    
    always @ (posedge pll_clk) begin
        
        if (!resetn) begin

            // reset values
            hsync_sr <= 0;
            vsync_sr <= 0;

        end
        else begin
            
            // shift in 
            hsync_sr <= {hsync_sr[NSR-2:0], hsync};
            vsync_sr <= {vsync_sr[NSR-2:0], vsync};
            
        end

    end

    // assign output    
    assign hsync_out = hsync_sr[NSR-1];
    assign vsync_out = vsync_sr[NSR-1];

    wire data_ready;
    wire [3:0] r1;
    wire [3:0] g1;
    wire [3:0] b1;
    spram_io sprio(
        .clk(pll_clk),
        .resetn(resetn),
        .hpos(hpos),
        .vpos(vpos),
        .r(r1),
        .g(g1),
        .b(b1),
        .data_ready(data_ready)     // high when ram is ready to be read
    );

//`define VGA_TEST
`ifdef VGA_TEST
    assign r = display_valid ? (hpos > 320 ? 4'b1111 : 4'b0000) : 4'b0000;
    assign g = display_valid ? (hpos > 320 ? 4'b0000 : 4'b1111) : 4'b0000;
    assign b = 4'b0000;
`else  // VGA_TEST


    // set VGA colours 
    reg [3:0] red;
    reg [3:0] green;
    reg [3:0] blue;

    // clocked VGA output
    always @ (posedge pll_clk) begin

        if (!resetn) begin 
            //index <= 0;
            red <= 0;
            green <= 0;
            blue <= 0;
            
        end 
        else if (display_valid) begin     
            // 320x240 
            if (hpos >= 320 || vpos >= 240) begin
                red <= 4'b0000;
                green <= 4'b0000;
                blue <= 4'b1111;
            end 
            else  begin 
                if (data_ready) begin 
                    {red, green, blue} = {r1, g1, b1};
                end 
                else begin
                    red <= 4'b1100;
                    green <= 4'b1100;
                    blue <= 4'b1100;
                end 
            end
        end 
        else begin 
            red <= 4'b0000;
            green <= 4'b0000;
            blue <= 4'b0000;
        end 
    end    

    // assign colours 
    assign {r, g, b} = {red, green, blue};
                                    

`endif // VGA_TEST

    // blinky for debug 
//`define ENABLE_BLINKY
`ifdef ENABLE_BLINKY
    reg [22:0] counter;
    always @ (posedge pll_clk)
    begin

        if (!resetn) begin 
            counter <= 0;
        end

        counter <= counter + 1;

        if (!counter) begin 
            LED_B <= ~LED_B;
        end
    end
`endif // ENABLE_BLINKY

endmodule
