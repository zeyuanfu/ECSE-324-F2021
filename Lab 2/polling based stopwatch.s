.global _start

//lab 2 part 2.2

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


read_PB_edgecp_ASM:
ldr r0, =PB_EDGE			//load address of edgecapture register
ldr r0, [r0]				//load value of edgecapture register
bx lr


PB_clear_edgecp_ASM:
ldr r1, =PB_EDGE			//load address of edgecapture register
ldr r0, [r1]				//load contents of edgecapture register
mov r2, #0b1111
str r2, [r1]				//reset edgecapture register by writing 0b1111 to it
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

mov r0, #0b111111			//index of all hex displays
mov r1, #0					//starting counting value
mov r7, #0					//10-minute counter
mov r8, #0					//minute counter
mov r9, #0					//10-second counter
mov r10, #0					//seconds counter
mov r11, #0					//100-millisecond counter
mov r12, #0					//10-millisecond counter
bl HEX_write_ASM			//display starting values on all hex displays
ldr r0, =0x1E8480			//load = 2,000,000 clock cycles (10 milliseconds)
mov r1, #0b10				//prescaler = 0, I = 0, A = 1, E = 0
bl ARM_TIM_config_ASM		//set timer configuration


check:

bl PB_clear_edgecp_ASM		//poll edgecapture register
mov r6, r0

cmp r6, #0b1
ldreq r0, =0x1E8480			
moveq r1, #0b11		
bleq ARM_TIM_config_ASM		//if button 0 was pressed, set E bit to 1
beq loop

cmp r6, #0b10
ldreq r0, =0x1E8480			
moveq r1, #0b10				
bleq ARM_TIM_config_ASM		//if button 1 was pressed, set E bit to 0
beq loop

cmp r6, #0b100				
moveq r7, #0				//if button 2 was pressed, reset all counters
moveq r8, #0				
moveq r9, #0				
moveq r10, #0				
moveq r11, #0				
moveq r12, #0				
moveq r0, #0b111111			//and reset all hex displays to zero
moveq r1, #0				
bleq HEX_write_ASM	


loop:

bl ARM_TIM_read_INT_ASM		//read F bit
cmp r0, #1
bne check					//if not set, branch back to edgecapture check loop, otherwise continue since 10 ms have passed

bl ARM_TIM_clear_INT_ASM	//clear F bit

cmp r12, #9
moveq r12, #0				//if 10 ms counter is at max value (9), set to 0 and add 1 to 100 ms counter
addeq r11, r11, #1
addne r12, r12, #1			//otherwise increment counter
mov r0, #0b1				
mov r1, r12					
bl HEX_write_ASM			//display counter value on first hex display

cmp r11, #10				//if 100 ms counter reaches max value (10), set to 0 and add 1 to seconds counter
moveq r11, #0
addeq r10, r10, #1
mov r0, #0b10
mov r1, r11
bl HEX_write_ASM			//display counter value on second hex display

cmp r10, #10				//if seconds counter reaches max value (10), set to 0 and add 1 to 10 secs counter
moveq r10, #0
addeq r9, r9, #1
mov r0, #0b100
mov r1, r10
bl HEX_write_ASM			//display counter value on third hex display

cmp r9, #6					//if 10 secs counter reaches max value (6), set to 0 and add 1 to minutes counter
moveq r9, #0
addeq r8, r8, #1
mov r0, #0b1000
mov r1, r9
bl HEX_write_ASM			//display counter value on fourth hex display

cmp r8, #10					//if minutes counter reaches max value (10), set to 0 and add 1 to 10 mins counter
moveq r8, #0
addeq r7, r7, #1
mov r0, #0b10000
mov r1, r8
bl HEX_write_ASM			//display counter value on fifth hex display

cmp r7, #6					//if 10 mins counter reaches max value (10), reset all counters to zero
moveq r7, #0
moveq r8, #0
moveq r9, #0
moveq r10, #0
moveq r11, #0
moveq r12, #0
moveq r0, #0b111111
moveq r1, #0
bleq HEX_write_ASM			//and display the value of all counters (0)
beq check					//branch back to edgecapture check loop

mov r0, #0b100000			
mov r1, r7
bl HEX_write_ASM			//otherwise display counter value on sixth hex display

b check						//branch back to edgecapture check loop


