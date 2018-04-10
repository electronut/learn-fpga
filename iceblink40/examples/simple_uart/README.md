Simple UART (TX only).

## Testbench

Run the following:

```
iverilog -o tb.out -s tb testbench.v simple_uart.v 
vvp tb.out
```

Then view output testbench.vcd on GTKWave 

![testbench output](tb.png)
