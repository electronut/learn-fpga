/*
    simple_uart_tx.v

    Simple UART (TX only).
    
    electronut.in

*/
module top (
       input  clk,
       output tx
);

        // clk is at 3.3 MHz 
        reg [21:0] counter;
        reg [7:0] count;

        reg clk_9600;               // 9600 Hz
        reg [21:0] bcounter;        // counter for generating baud rate clock

        // for UART transmission
        reg data_ready = 1;
        wire tx_busy;

        reg [7:0] data = 8'd0;
        wire [7:0] dataIn = data;

        always @(posedge clk) 
        begin
            bcounter <= bcounter + 1;

            // generate 9600 baud clock
            if (bcounter == 154)
            begin
                clk_9600 <= ~clk_9600;
                bcounter <= 0;
            end

        end

        always @(posedge clk) 
        begin
            // send data periodically
            counter <= counter + 1;

            if (!counter) 
                begin
                    data_ready <= 1;
                    data <= count;
                    count <= count + 1;
                end
        end

        // instantiate UART module
        simple_uart uart1(
            .uclk(clk_9600),
            .dataIn(dataIn),
            .data_ready(data_ready),
            .tx(tx),
            .tx_busy(tx_busy)
        );

endmodule
