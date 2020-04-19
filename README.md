![ice40](iceblink40.jpg)

# Learn FGPA

I think the best way to understand something is to try and build something interesting with it. This is a repository of hardware projects using FPGAs.

# Project Index

This is a summary of projects you will find in this repository.

## Latice iCE40HX1k

These projects use the Lattice iCE40HX1k and the *icestorm* open source FPGA toolchain.

- **led_chaser** - a "hello world" for FPGA
- **led_breathe** - LEDs and PWM 

## Latice iCE40UP5k

These projects use the Lattice iCE40HX1k and the *icestorm* open source FPGA toolchain.

- **ultrasonic** - talking to ultrasonic sensor HC-SR04 and displaying distance on a 4-digit 7-segment display

  **picosoc_gpio** - simpe RISC-V based Picosoc demo that shows how to enable interrupts.

## Migen Examples

- **blinky** - a simple blinky in Migen/Python

## Xilinx Zynq

These projects use the Xilinx Zynq SoCs which combine FPGA (PL) with ARM cores (PS).

- **blinky** - this project (video, text, no source) shows you how to create a blinky on the PL of Xilinx XC7Z007S using the clock from the PS, using Vivado 2018.3.

- **simple_vga** - a simple VGA project with a red grid and a yellow moving square.

- **video_ip_test** - using Xilinx video IPs to show test patterns via VGA.

- **thermal_vga** - displaying thermal sensor data via VGA