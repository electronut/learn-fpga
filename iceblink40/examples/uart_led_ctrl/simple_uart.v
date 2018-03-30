/*
    simple_uart.v

    Simple UART implementation
    
    electronut.in

*/

module simple_uart (
    input uclk,          // UART clock at baud rate
    input [7:0] dataIn,  // 8-bit input data
    output tx            // serial output
);

    // current bit being transmitted
    reg [4:0] curr_bit = 0;

    // bits
    // 0 -> Idle HIGH
    // 1 -> Start LOW
    // 2:9 -> Data
    // 10 -> HIGH
    wire [10:0] data_in = {1'd1, 1'd0, dataIn, 1'd1};
    wire tx_data = data_in[curr_bit];

    always @(posedge uclk) 
        begin
            // end of data - go high
            if (curr_bit == 10)
                curr_bit <= 0;
            else
                // increment bit 
                curr_bit <= curr_bit + 1;
        end

    assign tx = curr_bit[0];

endmodule