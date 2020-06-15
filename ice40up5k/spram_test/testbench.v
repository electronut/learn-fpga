/*

    Simulation:

    iverilog -o tb.out -s tb testbench.v simple_uart.v 
    vvp tb.out 
    Then open with GTKWave
*/

// Never forget this!
`default_nettype none

module tb ();

    reg clk;
    reg resetn;
    wire w_resetn = resetn;


    initial begin
        
        // initialise values
        clk = 1'b0;

        // reset 
        resetn = 1'b1;
        #5
        resetn = 1'b0;
        #5
        resetn = 1'b1;
    end

    wire [9:0] hpos;
    wire [9:0] vpos;
    wire hsync;
    wire vsync;

    wire display_valid;

    // instantiate VGA module 
    vga_640x480 vga (
        .clk_25mhz(clk),
        .resetn(resetn),
        .hpos(hpos),
        .vpos(vpos),
        .hsync(hsync),
        .vsync(vsync),
        .display_valid(display_valid)
    );

    wire data_ready;
    wire [3:0] r1;
    wire [3:0] g1;
    wire [3:0] b1;
    spram_io sprio(
        .clk(clk),
        .resetn(resetn),
        .hpos(hpos),
        .vpos(vpos),
        .r(r1),
        .g(g1),
        .b(b1),
        .data_ready(data_ready)     // high when ram is ready to be read
    );


    // generate clk
    always @ ( * ) begin
        #1
        clk <= ~clk; 
    end

    integer jj;
    
    initial begin
        $dumpfile("testbench.vcd");
        $dumpvars;

        for( jj = 0; jj < 16; jj = jj + 1) begin
            $dumpvars(0, sprio.spr.mem[jj]);
        end

        #10000
        $finish;
    end
    

endmodule
