.equ SWITCH_ADDR, 0x00000200
.equ LED_ADDR, 0x00000100
.equ RESET_ADDR, 0x00000300
.equ DELAY_COUNT, 3
.text
.globl _start
_start:
 # Initialize base address registers for peripherals
 li s1, SWITCH_ADDR
 li s2, LED_ADDR
 li s3, RESET_ADDR
WAIT_INPUT:
 lw t0, 0(s1) # Read switches into temporary register
 
 beqz t0, WAIT_INPUT 
 
 mv a0, t0 # Move switch value to argument register a0
 sw a0, 0(s2) # Display captured value on LEDs [cite: 49]
 
 jal ra, DO_COUNTDOWN
 
 j WAIT_INPUT
DO_COUNTDOWN:
 addi sp, sp, -16 # Allocate 16 bytes on the stack
 sw ra, 12(sp) # Save return address
 sw s0, 8(sp) # Save s0 (we will use it for the delay loop)
COUNT_LOOP:
 sw a0, 0(s2)
 
 li s0, DELAY_COUNT 
DELAY_LOOP:
 lw t1, 0(s3) 
 bnez t1, HANDLE_RESET
 
 addi s0, s0, -1
 bnez s0, DELAY_LOOP # Loop until delay counter is 0
 addi a0, a0, -1
 bnez a0, COUNT_LOOP 
 lw s0, 8(sp) 
 lw ra, 12(sp) 
 addi sp, sp, 16 
 ret 
HANDLE_RESET:
 li a0, 0
 sw a0, 0(s2) 
 
 lw s0, 8(sp) # Restore s0
 lw ra, 12(sp) # Restore return address
 addi sp, sp, 16 # Deallocate stack space
 ret # Return to main loop
