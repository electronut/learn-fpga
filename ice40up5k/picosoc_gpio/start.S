// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.


#include "custom_ops.S"

.section .text
.global init

reset_vec:
	// no more than 16 bytes here !
	picorv32_waitirq_insn(zero)
	picorv32_maskirq_insn(zero, zero)
	j start

.balign 16
irq_vec:

	picorv32_setq_insn(q2, x1)  // q2 = ra
	picorv32_setq_insn(q3, sp)  // q3 = stack pointer

	// x2 is the stack pointer
	// stack normally is consumed from top downwards, but
	// irq handler uses stack right at bottom of stack range
	// (leaving top of stack for normal programs)..

	addi sp, zero, 0

	picorv32_getq_insn(x1, q0)
	sw x1,   0*4(sp)            // Q0 = return address from IRQ vector

	picorv32_getq_insn(x1, q2)
	sw x1,   1*4(sp)            // Q2 = X1 = RA

	picorv32_getq_insn(x1, q3)
	sw x1,   2*4(sp)            // Q3 = SP

	sw x3,   3*4(sp)
	sw x4,   4*4(sp)
	sw x5,   5*4(sp)
	sw x6,   6*4(sp)
	sw x7,   7*4(sp)
	sw x8,   8*4(sp)
	sw x9,   9*4(sp)
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

	/* call interrupt handler C function */

	// arg1 = pointer to stored registers
	mv x11, sp

	// arg0 = interrupt type bitmask
	picorv32_getq_insn(x10, q1)					// Q1 contains bitmask of interrupts that were triggered

	// make some room on the stack for the interrupt handler
	addi sp, sp, 384   // 128 bytes for register file, 256 bytes for interrupt handler stack

	// jump to irq handler
	jal ra, irq_handler

cleanup:

	//addi sp, sp, -384
	addi sp, zero, 0

	/* restore registers */
	lw x1,   0*4(sp)
	picorv32_setq_insn(q0, x1)	// Q0

	lw x1,   1*4(sp)
	picorv32_setq_insn(q3, x1)   // RA

	lw x1,   2*4(sp)
	picorv32_setq_insn(q2, x1)   // SP

	// the following was essential or interrupts hang
	picorv32_getq_insn(x1, q2)
	picorv32_getq_insn(x2, q3)

	lw x3,   3*4(sp)	
	lw x4,   4*4(sp)
	lw x5,   5*4(sp)
	lw x6,   6*4(sp)
	lw x7,   7*4(sp)
	lw x8,   8*4(sp)
	lw x9,   9*4(sp)
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

	picorv32_retirq_insn()

/* Main program
 **********************************/

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
