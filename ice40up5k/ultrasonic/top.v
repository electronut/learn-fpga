/*
    hc-sr04_test.v

    
    
    electronut.in

*/
module top (
        input  clk,
        input echo,
        output LED2,
        output LED3,
        output trig,

        output A,
        output B,
        output C,
        output D,
        output E,
        output F,
        output G,
        output DP,

        output D1,
        output D2,
        output D3,
        output D4
);  

        // clk is at 3.3 MHz 
        reg [19:0] counter;

        reg l2;
        reg l3;
        reg tr;

        reg [19:0] pulse_count;

        wire [3:0] cathodes;
        wire [6:0] anodes;
        
        reg [13:0] distance;

        // state machine
        parameter sIDLE =       2'b00;
        parameter sMEASURING =  2'b01;
        reg [1:0] state;

        seven_seg_cc_4d seg7 (
            .clk(clk),
            .value(distance), 
            .cathodes(cathodes),
            .anodes(anodes)
        );    

        // edge detector
        wire pos;
        wire neg;
        edge_detect ed1 (
            .clk(clk),
            .sig(echo),
            .pos(pos),
            .neg(neg)
        );

        always @(posedge clk) 
        begin
            // send data periodically
            counter <= counter + 1;

            if (counter < 33)
                begin   
                    tr <= 1;

                    // set waiting 
                    state <= sMEASURING;

                    //pulse_count <= 0;
                end
            else
                begin   
                    tr <= 0;
                end

            if (!counter) 
                begin
                    l2 <= ~l2;
                end
            
        end

        always @(posedge clk) 
        begin

            if (state == sMEASURING)
                begin 
                   
                    pulse_count <= pulse_count + 1;

                    if (pos)
                        begin 
                            pulse_count <= 0;
                            l3 <= 1;
                        end

                    if (neg)
                        begin
                            // dt = 1/f
                            // t = n*(1/f)*10^6  us
                            // d  =  n*(1/f)*10^6  / 58 cm
                            // f = 2.96 Hz
                            // d = N/(2.96*58) ~ N/172
                            // N/172 = N * (65536/172) / 65536 = N*381 >> 16
                            distance <= (pulse_count*381) >> 16;

                            state <= sIDLE;

                            l3 <= 0;
                        end
                end
            
        end

        assign {LED2, LED3} = {l2, l3};
        assign trig = tr;

        assign {A, B, C, D, E, F, G, DP} = {anodes, 1'b0};
        assign {D1, D2, D3, D4} = cathodes; 

endmodule
