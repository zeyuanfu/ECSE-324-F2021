.global _start

//lab 3 part 1.1 final

.equ LED_MEMORY, 0xFF200000
.equ SW_MEMORY, 0xFF200040

read_slider_switches_ASM:		//read operation driver
ldr r0, =SW_MEMORY
ldr r0, [r0]
bx lr

write_LEDs_ASM:					//write operation driver
ldr r1, =LED_MEMORY
str r0, [r1]
bx lr

_start:

bl read_slider_switches_ASM		//read contents of slider switch register
bl write_LEDs_ASM				//writes contents of slider switch register to LED register

b _start						//branch back to beginning of loop
