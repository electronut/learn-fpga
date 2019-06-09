/*
    simple_uart.v

    Simple UART implementation
    
    electronut.in

*/

module simple_uart (
    input clk,           // assumes 2.96 MHz clock
    input [7:0] dataIn,  // 8-bit input data
    input data_ready,    // flag to indicate data is ready for transmission
    output tx,           // serial output
    output tx_busy       // high when tx is busy transmitting
);

    // current bit being transmitted
    reg [4:0] curr_bit = 0;

    // bits
    // 0 -> Idle HIGH
    // 1 -> Start LOW
    // 2:9 -> Data
    // 10 -> HIGH
    wire [11:0] data_in = {1'd1, 1'd1, dataIn, 1'd0, 1'd1};
    wire tx_data = data_in[curr_bit];
    reg busy_tx = 0;

    // counter for baud rate
    reg [21:0] bcounter; 
    reg clk_9600;

    reg [7:0] counter;

    // for state machine
    reg [1:0] state;
    parameter IDLE = 2'b00;
    parameter RUNNING = 2'b01;

    // counter for 9600 baud
    // assumes clk is 2.96 MHz
    always @(posedge clk) 
      begin
        bcounter <= bcounter + 1;
        counter <= counter + 1;
        if (bcounter == 16)
            begin
                clk_9600 <= ~clk_9600;
                bcounter <= 0;
            end
      end

    

    assign tx = tx_data;
    assign tx_busy = busy_tx;

endmodule