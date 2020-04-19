# 1 "start.S"
# 1 "<built-in>"
# 1 "<command-line>"
# 31 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 32 "<command-line>" 2
# 1 "start.S"
# 9 "start.S"
# 1 "custom_ops.S" 1
# 10 "start.S" 2

.section .text
.global init

reset_vec:

 .word (((0b0000100) << 25) | ((0) << 20) | ((0) << 15) | ((0b100) << 12) | ((0) << 7) | ((0b0001011) << 0))
 .word (((0b0000011) << 25) | ((0) << 20) | ((0) << 15) | ((0b110) << 12) | ((0) << 7) | ((0b0001011) << 0))
 j start

.balign 16
irq_vec:

 .word (((0b0000001) << 25) | ((0) << 20) | ((1) << 15) | ((0b010) << 12) | ((2) << 7) | ((0b0001011) << 0))
 .word (((0b0000001) << 25) | ((0) << 20) | ((2) << 15) | ((0b010) << 12) | ((3) << 7) | ((0b0001011) << 0))






 addi sp, zero, 0

 .word (((0b0000000) << 25) | ((0) << 20) | ((0) << 15) | ((0b100) << 12) | ((1) << 7) | ((0b0001011) << 0))
 sw x1, 0*4(sp)

 .word (((0b0000000) << 25) | ((0) << 20) | ((2) << 15) | ((0b100) << 12) | ((1) << 7) | ((0b0001011) << 0))
 sw x1, 1*4(sp)

 .word (((0b0000000) << 25) | ((0) << 20) | ((3) << 15) | ((0b100) << 12) | ((1) << 7) | ((0b0001011) << 0))
 sw x1, 2*4(sp)

 sw x3, 3*4(sp)
 sw x4, 4*4(sp)
 sw x5, 5*4(sp)
 sw x6, 6*4(sp)
 sw x7, 7*4(sp)
 sw x8, 8*4(sp)
 sw x9, 9*4(sp)
 sw x10, 10*4(sp)
 sw x11, 11*4(sp)
 sw x12, 12*4(sp)
 sw x13, 13*4(sp)
 sw x14, 14*4(sp)
 sw x15, 15*4(sp)
 sw x16, 16*4(sp)
 sw x17, 17*4(sp)
 sw x18, 18*4(sp)
 sw x19, 19*4(sp)
 sw x20, 20*4(sp)
 sw x21, 21*4(sp)
 sw x22, 22*4(sp)
 sw x23, 23*4(sp)
 sw x24, 24*4(sp)
 sw x25, 25*4(sp)
 sw x26, 26*4(sp)
 sw x27, 27*4(sp)
 sw x28, 28*4(sp)
 sw x29, 29*4(sp)
 sw x30, 30*4(sp)
 sw x31, 31*4(sp)




 mv x11, sp


 .word (((0b0000000) << 25) | ((0) << 20) | ((1) << 15) | ((0b100) << 12) | ((10) << 7) | ((0b0001011) << 0))


 addi sp, sp, 384


 jal ra, irq_handler

cleanup:


 addi sp, zero, 0


 lw x1, 0*4(sp)
 .word (((0b0000001) << 25) | ((0) << 20) | ((1) << 15) | ((0b010) << 12) | ((0) << 7) | ((0b0001011) << 0))

 lw x1, 1*4(sp)
 .word (((0b0000001) << 25) | ((0) << 20) | ((1) << 15) | ((0b010) << 12) | ((3) << 7) | ((0b0001011) << 0))

 lw x1, 2*4(sp)
 .word (((0b0000001) << 25) | ((0) << 20) | ((1) << 15) | ((0b010) << 12) | ((2) << 7) | ((0b0001011) << 0))


 .word (((0b0000000) << 25) | ((0) << 20) | ((2) << 15) | ((0b100) << 12) | ((1) << 7) | ((0b0001011) << 0))
 .word (((0b0000000) << 25) | ((0) << 20) | ((3) << 15) | ((0b100) << 12) | ((2) << 7) | ((0b0001011) << 0))

 lw x3, 3*4(sp)
 lw x4, 4*4(sp)
 lw x5, 5*4(sp)
 lw x6, 6*4(sp)
 lw x7, 7*4(sp)
 lw x8, 8*4(sp)
 lw x9, 9*4(sp)
 lw x10, 10*4(sp)
 lw x11, 11*4(sp)
 lw x12, 12*4(sp)
 lw x13, 13*4(sp)
 lw x14, 14*4(sp)
 lw x15, 15*4(sp)
 lw x16, 16*4(sp)
 lw x17, 17*4(sp)
 lw x18, 18*4(sp)
 lw x19, 19*4(sp)
 lw x20, 20*4(sp)
 lw x21, 21*4(sp)
 lw x22, 22*4(sp)
 lw x23, 23*4(sp)
 lw x24, 24*4(sp)
 lw x25, 25*4(sp)
 lw x26, 26*4(sp)
 lw x27, 27*4(sp)
 lw x28, 28*4(sp)
 lw x29, 29*4(sp)
 lw x30, 30*4(sp)
 lw x31, 31*4(sp)

 .word (((0b0000010) << 25) | ((0) << 20) | ((0) << 15) | ((0b000) << 12) | ((0) << 7) | ((0b0001011) << 0))




start:
 # zero initialize entire scratchpad memory
 li a0, 0x00000000
 li a1, 0x00001000
setmemloop:
 sw a0, 0(a0)
 addi a0, a0, 4
 blt a0, a1, setmemloop

 # copy data section
 la a0, _sidata
 la a1, _sdata
 la a2, _edata
 bge a1, a2, end_init_data
loop_init_data:
 lw a3, 0(a0)
 sw a3, 0(a1)
 addi a0, a0, 4
 addi a1, a1, 4
 blt a1, a2, loop_init_data
end_init_data:

 # zero-initialize register file
 addi x1, zero, 0
 # x2 (sp) is initialized by reset
 addi x3, zero, 0
 addi x4, zero, 0
 addi x5, zero, 0
 addi x6, zero, 0
 addi x7, zero, 0
 addi x8, zero, 0
 addi x9, zero, 0
 addi x10, zero, 0
 addi x11, zero, 0
 addi x12, zero, 0
 addi x13, zero, 0
 addi x14, zero, 0
 addi x15, zero, 0
 addi x16, zero, 0
 addi x17, zero, 0
 addi x18, zero, 0
 addi x19, zero, 0
 addi x20, zero, 0
 addi x21, zero, 0
 addi x22, zero, 0
 addi x23, zero, 0
 addi x24, zero, 0
 addi x25, zero, 0
 addi x26, zero, 0
 addi x27, zero, 0
 addi x28, zero, 0
 addi x29, zero, 0
 addi x30, zero, 0
 addi x31, zero, 0

 lui sp, %hi(0x400);
 addi sp, sp, %lo(0x400);
 # call main
 call main
loop:
 j loop

.balign 4
