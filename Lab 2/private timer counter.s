.global _start

//lab 2 part 2.1 final

.equ LED_MEMORY, 0xFF200000
.equ SW_MEMORY, 0xFF200040
.equ HEX_MEMORY_03, 0xFF200020
.equ HEX_MEMORY_45, 0xFF200030
.equ PB_DATA, 0xFF200050
.equ PB_MASK, 0xFF200058
.equ PB_EDGE, 0xFF20005C
.equ TIMER_LOAD, 0xFFFEC600
.equ TIMER_COUNTER, 0xFFFEC604
.equ TIMER_CONTROL, 0xFFFEC608
.equ TIMER_INTERRUPT, 0xFFFEC60C


write_LEDs_ASM:	//write operation driver
ldr r1, =LED_MEMORY
str r0, [r1]
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


ARM_TIM_config_ASM:
ldr r2, =TIMER_LOAD
str r0, [r2]				//write contents of R0 to load register
str r1, [r2, #0x8]			//write contents of R1 to control register
bx lr


ARM_TIM_read_INT_ASM:
ldr r0, =TIMER_INTERRUPT
ldr r0, [r0]				//load the F bit into R0
bx lr


ARM_TIM_clear_INT_ASM:
ldr r1, =TIMER_INTERRUPT
mov r2, #1
str r2, [r1]				//clear the F bit by writing 1 to it
bx lr


_start:

mov r0, #1					//index of first hex display
mov r1, #0					//starting counting value
mov r12, #0					//value counter (to be incremented)
bl HEX_write_ASM			//display starting value on first hex display
ldr r0, =0xBEBC200			//load = 200,000,000 clock cycles (1 second)
mov r1, #0b11				//prescaler = 0, I = 0, A = 1, E = 1
bl ARM_TIM_config_ASM		//set timer configuration


loop:
bl ARM_TIM_read_INT_ASM		//read F bit
cmp r0, #1
bne loop					//if not set, branch back to beginning of loop, otherwise continue since 1 second has passed

bl ARM_TIM_clear_INT_ASM	//clear F bit
cmp r12, #15
moveq r12, #0				//if counter is at max value (15), set to 0
addne r12, r12, #1			//otherwise increment counter
mov r0, r12					//move value to be displayed on LEDs
bl write_LEDs_ASM			//display value on LEDs
mov r0, #1					//index of first display
mov r1, r12					//value to be displayed on hex display
bl HEX_write_ASM			//display value on first hex display

b loop						//branch back to beginning of loop
