/*
    uart_led_ctrl.v

    Control LEDs via UART.
    
    electronut.in

*/
module top (
       input  clk,
       output LED2,
       output LED3,
       output LED4,
       output LED5
);

        // clk is at 3.3 MHz 

        reg 9600_clk;               // 9600 Hz
        reg [7:0] bcounter;         // counter for generating baud rate clock

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

        // generate 9600 baud clock
        always @(posedge clk) 
        begin
            if (bcounter == 172)
                begin
                    9600_clk <= 1;
                    bcounter <= 0;
                end
            else 
                begin
                    9600_clk <= 0;
                    bcounter <= bcounter + 1;
                end
        end

        // instantiate UART module
        simple_uart uart1(
            .uclk(9600_clk),
            .dataIn(dataIn),
            .data_ready(data_ready),
            .tx(tx),
            .tx_busy(tx_busy)
        );

        always @(posedge clk) 
        begin
            
        end

        // set LED output
        assign {LED2, LED3, LED4, LED5} = rot;

endmodule
