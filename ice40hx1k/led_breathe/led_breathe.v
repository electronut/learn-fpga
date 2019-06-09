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

        reg [10:0] pwm_value_1, pwm_value_2, pwm_value_3, pwm_value_4;
        reg led_on_1, led_on_2, led_on_3, led_on_4;
        reg [24:0] delay1, delay2, delay3;

        // set LED on/off
        always @(posedge clk) 
        begin
            // initialise rot
            if (!resetn) 
                begin 
                    pwm_value_1 <= 1;
                    pwm_value_2 <= 1;
                    pwm_value_3 <= 1;
                    pwm_value_4 <= 1;
                    delay1 <= 200000;
                    delay2 <= 400000;
                    delay3 <= 600000;
                end
            else  
                begin
                    // set PWM value
                    if (!counter[17:0])
                        begin
                            pwm_value_1 <= pwm_value_1 << 1;
                            if (pwm_value_1 == 0)
                                pwm_value_1 <= 1;
                        end

                    // LED 2 
                    if (!counter[17:0] && (counter > delay1))
                        begin
                            pwm_value_2 <= pwm_value_2 << 1;
                            if (pwm_value_2 == 0)
                                pwm_value_2 <= 1;
                        end

                    // LED 3
                    if (!counter[17:0] && (counter > delay2))
                        begin
                            pwm_value_3 <= pwm_value_3 << 1;
                            if (pwm_value_3 == 0)
                                pwm_value_3 <= 1;
                        end

                    // LED 4
                    if (!counter[17:0] && (counter > delay3))
                        begin
                            pwm_value_4 <= pwm_value_4 << 1;
                            if (pwm_value_4 == 0)
                                pwm_value_4 <= 1;
                        end

                    // F = 3.3 MHz clk 
                    // 0 th bit of counter will change at F/2 
                    // Nth bit of counter will change at F/2/(2^N)

                    // counter[10:0] is a 11 bit value 
                    // splitting it in half will give a 
                    // 50% duty cycle at ~1600 Hz

                    // inc counter and set PWM
                    counter <= counter + 1;

                    // LED 1
                    if (counter[10:0] < pwm_value_1)
                        led_on_1 <= 1;
                    else 
                        led_on_1 <= 0;

                    // LED 2
                    if (counter[10:0] < pwm_value_2)
                        led_on_2 <= 1;
                    else 
                        led_on_2 <= 0;

                    // LED 3
                    if (counter[10:0] < pwm_value_3)
                        led_on_3 <= 1;
                    else 
                        led_on_3 <= 0;

                    // LED 3
                    if (counter[10:0] < pwm_value_4)
                        led_on_4 <= 1;
                    else 
                        led_on_4 <= 0;
                end        
        end

        // set LED output
        assign {LED2, LED3, LED4, LED5} = {led_on_1, led_on_2, led_on_3, led_on_4};

endmodule
