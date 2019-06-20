`timescale 1ns / 1ps
`default_nettype none

//////////////////////////////////////////////////////////////////////////////////
// Company: Electronut Labs
// Engineer: Mahesh Venkitachalam
// 
// Create Date: 17.06.2019 10:15:49
// Design Name: 
// Module Name: vga
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Simple VGA demo with Zynq. 
//              
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module vga(
    input wire reset,
    input wire clk,        // assumes 100 MHz clock
    output reg [3:0] r,
    output reg [3:0] g,
    output reg [3:0] b,
    output reg hsync,
    output reg vsync,
    output reg LED,
    output wire debug
    );
    
    // create a strobe for 25 MHz VGA clock
    // from: http://zipcpu.com/blog/2017/06/02/generating-timing.html
    reg ck_stb;
    reg	[15:0]	counter;
    always @(posedge clk) begin
	   { ck_stb, counter } <= counter + 16'h4000;
    end
        
    // generate hsync and vsync
    // Part of this code is adapted from the VGA example from http://8bitworkshop.com/
    reg [10:0] hpos;
    reg [10:0] vpos;

    // declarations for TV-simulator sync parameters
    // horizontal constants
    parameter H_DISPLAY       = 640; // horizontal display width
    parameter H_BACK          =  48; // horizontal left border (back porch)
    parameter H_FRONT         =   16; // horizontal right border (front porch)
    parameter H_SYNC          =  96; // horizontal sync width
    // vertical constants
    parameter V_DISPLAY       = 480; // vertical display height
    parameter V_TOP           =   33; // vertical top border
    parameter V_BOTTOM        =  10; // vertical bottom border
    parameter V_SYNC          =   2; // vertical sync # lines
    // derived constants
    parameter H_SYNC_START    = H_DISPLAY + H_FRONT;
    parameter H_SYNC_END      = H_DISPLAY + H_FRONT + H_SYNC - 1;
    parameter H_MAX           = H_DISPLAY + H_BACK + H_FRONT + H_SYNC - 1;
    parameter V_SYNC_START    = V_DISPLAY + V_BOTTOM;
    parameter V_SYNC_END      = V_DISPLAY + V_BOTTOM + V_SYNC - 1;
    parameter V_MAX           = V_DISPLAY + V_TOP + V_BOTTOM + V_SYNC - 1;
    
    wire hmaxxed = (hpos == H_MAX) || !reset;	// set when hpos is maximum
    wire vmaxxed = (vpos == V_MAX) || !reset;	// set when vpos is maximum
          
          
    // horizontal position counter
    always @(posedge clk)
    begin
    
        if (!reset) begin
            hpos <= 0;
        end
    
        if (ck_stb) begin
            hsync <= ~(hpos>=H_SYNC_START && hpos<=H_SYNC_END);
            if(hmaxxed)
              hpos <= 0;
            else
              hpos <= hpos + 1;
        end
    end
    
    // vertical position counter
    always @(posedge clk)
    begin
    
        if (!reset) begin
            vpos <= 0;
        end
        
        if (ck_stb) begin
            vsync <= ~(vpos>=V_SYNC_START && vpos<=V_SYNC_END);
            if(hmaxxed)
              if (vmaxxed)
                vpos <= 0;
              else
                vpos <= vpos + 1;
        end
    end
    
    // display_on is set when beam is in "safe" visible frame
    wire display_on = (hpos<H_DISPLAY) && (vpos<V_DISPLAY);
  
    // LED blink
    reg [23:0] counter_led;
    always @ (posedge clk) begin
    
        counter_led <= counter_led + 1;

        if (!counter_led) begin
            LED = ~LED;
        end
    end
    
    // "ball" position
    reg [10:0] px;
    reg [10:0] py;
    
    // half ball width
    parameter B = 10;
  
    
    // clocked VGA output
    always @ (posedge clk) begin
    
        if (!reset) begin
            px <= 100;
            py <= 100;
        end
        
        if (display_on) begin 
            
          // move
          if (!counter_led) begin
          
            // move
            px <= px + 4;
            
            if (px >= 640)
                px <= 0;          
          end
            
          // display 
          if ( (hpos > (px - B) && hpos < (px + B)) && 
                (vpos > (py - B) && vpos < (py + B))) begin
                r <= {4{1'b1}};
                g <= {4{1'b1}};
                b <= {4{1'b0}};
          end 
          else begin 
              r <= {4{(((hpos&7)==0) || ((vpos&7)==0))}};
              g <= {4{1'b0}};
              b <= {4{1'b0}};
          end
          
        end
    end    
   
    // use this for debugging 
    assign debug = ck_stb;
    
endmodule
