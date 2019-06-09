/*

    bin_to_bcd.v

*/

module bin_to_bcd #(
    parameter N = 14,  // no of bits in input 
    parameter M = 20,  // BCD width = 4 * ceil (N/3)
    parameter D = 5   // no of digits ceil(N/3) 
)
(
    input clk,
    input [N-1:0] value_bin,
    input start,

    output [M-1:0] value_bcd,

    output done // done signal
);

    parameter W = 34;  // buffer width = N + 4 * ceil (N/3)

    // state machine
    parameter sIDLE =       3'b000;
    parameter sSTART =      3'b001;
    parameter sSHIFT =      3'b010;
    parameter sADDLOOP =    3'b011;
    parameter sADD =        3'b100;
    parameter sDONE =       3'b101;

    reg [2:0] curr_state = 0;
    reg [W-1:0] buffer = 0;
    reg reg_done = 0;
    reg [7:0] shift_count = 0;
    reg [D-1:0] digit_index = 0; // current digit

    wire[3:0] digit;

    wire [3:0] curr_digit = 0;

    reg [M-1:0] reg_value_bcd = 0;  

    always @ (posedge clk)
        begin 

            case (curr_state)

                sIDLE:
                    begin
                        if (start)
                            curr_state <= sSTART;
                    end

                sSTART:
                    begin

                        // initialise 
                        buffer <= value_bin;

                        // change state
                        curr_state <= sSHIFT;

                        // set done 
                        reg_done <= 0;

                    end

                sSHIFT:
                    begin
                        // shift 1 left
                        buffer <= buffer << 1;

                        // keep track of shifts
                        shift_count <= shift_count + 1;

                        if (shift_count == (N-1))
                            curr_state <= sDONE;
                        else
                            curr_state <= sADD;
                    end

                sADDLOOP:
                    begin

                        if (digit_index == (D-1)) 
                            curr_state <= sSHIFT;
                        else
                            begin
                                if (digit > 4) 
                                    buffer[N + 4*digit_index +: 4] <= digit + 3;
                                
                                digit_index <= digit_index + 1;
                            end
                    end

                sADD:
                    begin

                        digit_index <= 0;

                        curr_state <= sADDLOOP;

                    end


                sDONE:
                    begin

                        // set idle state
                        curr_state <= sIDLE;

                        // reset shift count
                        shift_count <= 0;

                        // set done 
                        reg_done <= 1;

                        // copy bcd value
                        reg_value_bcd <= buffer[N +: M];

                    end

                default
                    curr_state <= sIDLE;

            endcase

        end

    assign digit = buffer[N + 4*digit_index +: 4]; 
    assign done = reg_done;
    assign value_bcd = reg_value_bcd;

endmodule