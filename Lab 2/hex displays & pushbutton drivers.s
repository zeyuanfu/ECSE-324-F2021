.global _start

//lab 2 part 1.2 final

.equ LED_MEMORY, 0xFF200000
.equ SW_MEMORY, 0xFF200040
.equ HEX_MEMORY_03, 0xFF200020
.equ HEX_MEMORY_45, 0xFF200030
.equ PB_DATA, 0xFF200050
.equ PB_MASK, 0xFF200058
.equ PB_EDGE, 0xFF20005C


read_slider_switches_ASM:	//read operation driver
ldr r0, =SW_MEMORY
ldr r0, [r0]
bx lr


write_LEDs_ASM:	//write operation driver
ldr r1, =LED_MEMORY
str r0, [r1]
bx lr


HEX_clear_ASM:
ldr r1, =HEX_MEMORY_03		//load the contents of the HEX_MEMORY_03
ldr r2, [r1]

tst r0, #0b1				//clear 0 if high
bicne r2, r2, #0b1111111
tst r0, #0b10				//clear 1 if high
bicne r2, r2, #0b111111100000000
tst r0, #0b100				//clear 2 if high
bicne r2, r2, #0b11111110000000000000000
tst r0, #0b1000				//clear 3 if high
bicne r2, r2, #0b1111111000000000000000000000000
str r2, [r1]				//store the new value to HEX_MEMORY_03

ldr r2, [r1, #0x10]			//load the contents of the HEX_MEMORY_45
tst r0, #0b10000			//clear 4 if high
bicne r2, r2, #0b1111111
tst r0, #0b100000			//clear 5 if high
bicne r2, r2, #0b111111100000000
str r2, [r1, #0x10]			//store the new value to HEX_MEMORY_45

bx lr


HEX_flood_ASM:
ldr r1, =HEX_MEMORY_03
ldr r2, [r1]				//load contents of HEX_MEMORY_03

tst r0, #0b1				//flood 0 if high
orrne r2, r2, #0b1111111
tst r0, #0b10				//flood 1 if high
orrne r2, r2, #0b111111100000000
tst r0, #0b100				//flood 2 if high
orrne r2, r2, #0b11111110000000000000000
tst r0, #0b1000				//flood 3 if high
orrne r2, r2, #0b1111111000000000000000000000000
str r2, [r1]				//store the new value in HEX_MEMORY_03

ldr r2, [r1, #0x10]			//load the contents of HEX_MEMORY_45
tst r0, #0b10000			//flood 4 if high
orrne r2, r2, #0b1111111
tst r0, #0b100000			//flood 5 if high
orrne r2, r2, #0b111111100000000
str r2, [r1, #0x10]			//store the new value in HEX_MEMORY_45

bx lr


HEX_write_ASM:
push {r4, lr}

cmp r1, #8				
bleq HEX_flood_ASM				//writing 8 = flooding display
popeq {r4, lr}
bxeq lr

cmp r1, #0						//determine positions of segments to be set high
moveq r1, #0x3F
beq write
cmp r1, #1
moveq r1, #0x06
beq write
cmp r1, #2
moveq r1, #0x5B
beq write
cmp r1, #3
moveq r1, #0x4F
beq write
cmp r1, #4
moveq r1, #0x66
beq write
cmp r1, #5
moveq r1, #0x6D
beq write
cmp r1, #6
moveq r1, #0x7D
beq write
cmp r1, #7
moveq r1, #0x07
beq write
cmp r1, #9
moveq r1, #0x6F
beq write
cmp r1, #10
moveq r1, #0x77
beq write
cmp r1, #11
moveq r1, #0x7C
beq write
cmp r1, #12
moveq r1, #0x39
beq write
cmp r1, #13
moveq r1, #0x5E
beq write
cmp r1, #14
moveq r1, #0x79
beq write
cmp r1, #15
moveq r1, #0x71

write:
mov r2, r1
ldr r3, =HEX_MEMORY_03
ldr r4, [r3]					//load the contents of HEX_MEMORY_03

tst r0, #0b1					//write to 0 if high
bicne r4, r4, #0b1111111
orrne r4, r4, r2
lsl r2, r2, #8
tst r0, #0b10					//write to 1 if high
bicne r4, r4, #0b111111100000000
orrne r4, r4, r2
lsl r2, r2, #8
tst r0, #0b100					//write to 2 if high
bicne r4, r4, #0b11111110000000000000000
orrne r4, r4, r2
lsl r2, r2, #8
tst r0, #0b1000					//write to 3 if high
bicne r4, r4, #0b1111111000000000000000000000000
orrne r4, r4, r2
str r4, [r3]					//store the new value in HEX_MEMORY_03

ldr r4, [r3, #0x10]				//load the contents of HEX_MEMORY_45
mov r2, r1
tst r0, #0b10000				//write to 4 if high
bicne r4, r4, #0b1111111
orrne r4, r4, r2
lsl r2, r2, #8
tst r0, #0b100000				//write to 5 if high
bicne r4, r4, #0b111111100000000
orrne r4, r4, r2
str r4, [r3, #0x10]				//store the new value in HEX_MEMORY_45

pop {r4, lr}
bx lr


read_PB_data_ASM:
ldr r0, =PB_DATA			//load address of data register
ldr r0, [r0]				//load contents of data register
bx lr


read_PB_edgecp_ASM:
ldr r0, =PB_EDGE			//load address of edgecapture register
ldr r0, [r0]				//load contents of edgecapture register
bx lr


PB_clear_edgecp_ASM:
ldr r1, =PB_EDGE			//load address of edgecapture register
ldr r0, [r1]				//load contents of edgecapture register
mov r2, #0b1111
str r2, [r1]				//reset edgecapture register by writing 0b1111 to it
bx lr


enable_PB_INT_ASM:
ldr r1, =PB_MASK			//load contents of mask register
ldr r2, [r1]

tst r0, #0b1				//set 1st bit if high
orrne r2, r2, #0b1
tst r0, #0b10				//set 2nd bit if high
orrne r2, r2, #0b10
tst r0, #0b100				//set 3rd bit if high
orrne r2, r2, #0b100
tst r0, #0b1000				//set 4th bit if high
orrne r2, r2, #0b1000
str r2, [r1]				//store new values to mask register

bx lr


disable_PB_INT_ASM:
ldr r1, =PB_MASK			//load contents of mask register
ldr r2, [r1]

tst r0, #0b1				//clear 1st bit if high
bicne r2, #0b1
tst r0, #0b10				//clear 2nd bit if high
bicne r2, #0b10
tst r0, #0b100				//clear 3rd bit if high
bicne r2, #0b100
tst r0, #0b1000				//clear 4th bit if high
bicne r2, #0b1000
str r2, [r1]				//store new values to mask register

bx lr


_start:
mov r0, #0b111111
bl HEX_clear_ASM
mov r0, #0b110000				//flood the 5th and 6th displays
bl HEX_flood_ASM

loop:
bl read_slider_switches_ASM		//read contents of slider switch register
bl write_LEDs_ASM				//writes contents of slider switch register to LED register

mov r12, r0
tst r12, #0x200					//if switch 9 is asserted, clear all displays
movne r0, #0b111111
blne HEX_clear_ASM

bl PB_clear_edgecp_ASM			//read the edgecapture register
bic r1, r12, #0b1111110000		//clear all but the four LSBs and store it in R1
bl HEX_write_ASM				//write the value in R1 to the displays specified by the edgecapture return

b loop							//branch back to beginning of loop
