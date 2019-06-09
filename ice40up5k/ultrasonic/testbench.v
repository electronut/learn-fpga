/*

    Simulation:

    iverilog -o tb.out -s tb testbench.v simple_uart.v 
    vvp tb.out 
    Then open with GTKWave
*/

module tb ();
    reg clk = 0;
    wire [7:0] dataIn = 8'd9;
    wire tx;
    wire data_ready = 1;
    wire tx_busy;

    initial begin
        $dumpfile("testbench.vcd");
        $dumpvars;
        #10000
        $finish;
    end

    
    reg [13:0] value = 2233;
    wire [19:0] value_bcd;
    wire [3:0] cathodes;
    wire [6:0] anodes;
    
    seven_seg_cc_4d s7 (
        .clk(clk),
        .value(value),
        .cathodes(cathodes),
        .anodes(anodes)
    );
    
    
    /*
    bin_to_bcd bb1 (

        .clk(clk),
        .value_bin(value),
        .start(1'b1),
        .value_bcd(value_bcd),
        .done(done)
    );
    */

    always @ ( * ) begin
        #5 clk <= ~clk; // 100 ns clock
    end

endmodule
