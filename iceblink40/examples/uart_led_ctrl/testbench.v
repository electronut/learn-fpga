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

    initial begin
        $dumpfile("testbench.vcd");
        $dumpvars;
        #10000
        $finish;
    end

    simple_uart uart1(
        .uclk(clk),
        .dataIn(dataIn),
        .tx(tx)
    );

    always @ ( * ) begin
        #5 clk <= ~clk; // 100 ns clock
    end

endmodule

