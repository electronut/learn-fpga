/*
    led_breathe.v

    Each of the LEDs breathe (PWM duty cycle varies) at a different rate.

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
        // 21 < log(3300000) < 22 
        reg [24:0] counter;

        // BEGIN - init hack
        // iCE40 does not allow registers to be initialised to 
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

        // generate a 2 KHz clock
        reg [10:0] pwm_value;

        reg led_on;

        // set LED on/off
        always @(posedge clk) 
        begin
            // initialise rot
            if (!resetn) 
                begin 
                    led_on <= 0;
                    pwm_value <= 10;
                end
            else  
                begin
                    // set PWM vakue
                    if (counter[18])
                        pwm_value <= pwm_value + 100;

                    
                    // F = 3.3 MHz clk 
                    // 0 th bit of counter will change at F/2 
                    // Nth bit of counter will change at F/2/(2^N)

                    // counter[10:0] is a 11 bit value 
                    // splitting it in half will give a 
                    // 50% duty cycle at ~1600 Hz

                    // inc counter and set PWM
                    counter <= counter + 1;
                    if (counter[10:0] < pwm_value)
                        led_on <= 1;
                    else 
                        led_on <= 0;
                end        
        end

        // set LED output
        assign {LED2, LED3, LED4, LED5} = {4{led_on}};

endmodule
