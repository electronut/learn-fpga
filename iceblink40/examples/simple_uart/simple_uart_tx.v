/*
    simple_uart.v

    Simple UART implementation
    
    electronut.in

*/

module simple_uart (
    input uclk,          // UART clock at baud rate

    //
    // TX:
    //
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

    always @(posedge uclk) 
        begin
            if (data_ready)
                begin
                    // set busy flag
                    busy_tx <= 1;
                    // end of data  
                    if (curr_bit == 11)
                        begin 
                            // done
                            busy_tx <= 0;
                            // reset bit
                            curr_bit <= 0;
                        end
                    else
                        // increment bit 
                        curr_bit <= curr_bit + 1;
                end
        end

    assign tx = tx_data;
    assign tx_busy = busy_tx;

endmodule