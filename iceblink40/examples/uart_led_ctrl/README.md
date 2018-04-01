LED control over UART.

## Testbench

iverilog -o tb.out -s tb testbench.v simple_uart.v 

vvp tb.out

View output testbench.vcd on GTKWave 
