/*
    led_chaser.v

    Basic LED sequencer on the Lattice iCEBlink40 board.

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
        reg [21:0] counter;
        reg [3:0] rot;

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
            // initialise rot
            if (!resetn) 
                rot <= 4'b0001;
            else  
                // inc counter and rotate
                begin
                    counter <= counter + 1;
                    if (!counter) 
                        rot <= {rot[2:0], rot[3]};
                end        
        end

        // set LED output
        assign {LED2, LED3, LED4, LED5} = rot;

endmodule
