/*
    uart_led_ctrl.v

    Control LEDs via UART.
    
    electronut.in

*/
module top (
       input  clk,
       output tx_out
);

        // clk is at 3.3 MHz 
        reg [21:0] counter;
        reg [7:0] count;

        reg clk_9600;               // 9600 Hz
        reg [21:0] bcounter;         // counter for generating baud rate clock

        // for UART transmission
        wire [7:0] dataIn = 8'd9;
        wire tx;
        wire data_ready = 1;
        wire tx_busy;

        // BEGIN - init hack
        // iCE40 does not allow registers to initialised to 
        // anything other than 0
        // For workaround see:
        // https://github.com/YosysHQ/yosys/issues/103
        reg [7:0] resetn_counter = 0;
        assign resetn = &resetn_counter;

        always @(posedge clk) 
        begin
            if (!resetn)
                resetn_counter <= resetn_counter + 1;
        end
        // END - init hack 

        
        always @(posedge clk) 
        begin
            // generate 9600 baud clock
            if (bcounter == 86)
                clk_9600 <= ~clk_9600;
            bcounter <= bcounter + 1;

            // send data periodically
            counter <= counter + 1;
            if (!counter) 
                begin
                    dataIn = count;
                    data_ready = 1;
                    count = count + 1;
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

    assign tx_out = clk_9600;

endmodule
