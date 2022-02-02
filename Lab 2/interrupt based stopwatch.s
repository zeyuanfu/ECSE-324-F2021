.global _start

//lab 2 part 3 final

.section .vectors, "ax"
B _start
B SERVICE_UND       // undefined instruction vector
B SERVICE_SVC       // software interrupt vector
B SERVICE_ABT_INST  // aborted prefetch vector
B SERVICE_ABT_DATA  // aborted data vector
.word 0 			// unused vector
B SERVICE_IRQ       // IRQ interrupt vector
B SERVICE_FIQ       // FIQ interrupt vector

PB_int_flag: .word 0x0
tim_int_flag: .word 0x0

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


ARM_TIM_clear_INT_ASM:
ldr r1, =TIMER_INTERRUPT
mov r2, #1
str r2, [r1]				//clear the F bit by writing 1 to it
bx lr


/*--- Undefined instructions ---------------------------------------- */
SERVICE_UND:
B SERVICE_UND


/*--- Software interrupts ------------------------------------------- */
SERVICE_SVC:
B SERVICE_SVC


/*--- Aborted data reads -------------------------------------------- */
SERVICE_ABT_DATA:
B SERVICE_ABT_DATA


/*--- Aborted instruction fetch ------------------------------------- */
SERVICE_ABT_INST:
B SERVICE_ABT_INST


/*--- IRQ ----------------------------------------------------------- */
SERVICE_IRQ:
PUSH {R0-R7, LR}

/* Read the ICCIAR from the CPU Interface */
LDR R4, =0xFFFEC100
LDR R5, [R4, #0x0C] 	// read from ICCIAR

/* Check which interrupt has occurred (check interrupt IDs)
   Then call the corresponding ISR
   If the ID is not recognized, branch to UNEXPECTED */
   
key_check:
cmp R5, #73
bne timer_check			//if ID = 73, call key isr, else go to next check
bl KEY_ISR
b EXIT_IRQ

timer_check:
cmp R5, #29
bne UNEXPECTED			//if ID = 29, call timer isr, else go to unexpected
bl ARM_TIM_ISR
b EXIT_IRQ

UNEXPECTED:
BNE UNEXPECTED      	// if not recognized, stop here

EXIT_IRQ:
/* Write to the End of Interrupt Register (ICCEOIR) */
STR R5, [R4, #0x10] // write to ICCEOIR
POP {R0-R7, LR}
SUBS PC, LR, #4


/*--- FIQ ----------------------------------------------------------- */
SERVICE_FIQ:
B SERVICE_FIQ


CONFIG_GIC:
PUSH {LR}

/* To configure the FPGA KEYS interrupt (ID 73):
* 1. set the target to cpu0 in the ICDIPTRn register
* 2. enable the interrupt in the ICDISERn register */
/* CONFIG_INTERRUPT (int_ID (R0), CPU_target (R1)); */
/* To Do: you can configure different interrupts
   by passing their IDs to R0 and repeating the next 3 lines */
MOV R0, #73            // KEY port (Interrupt ID = 73)
MOV R1, #1             // this field is a bit-mask; bit 0 targets cpu0
BL CONFIG_INTERRUPT

MOV R0, #29            // TIMER port (Interrupt ID = 29)
MOV R1, #1             // this field is a bit-mask; bit 0 targets cpu0
BL CONFIG_INTERRUPT

/* configure the GIC CPU Interface */
LDR R0, =0xFFFEC100    // base address of CPU Interface

/* Set Interrupt Priority Mask Register (ICCPMR) */
LDR R1, =0xFFFF        // enable interrupts of all priorities levels
STR R1, [R0, #0x04]

/* Set the enable bit in the CPU Interface Control Register (ICCICR).
* This allows interrupts to be forwarded to the CPU(s) */
MOV R1, #1
STR R1, [R0]

/* Set the enable bit in the Distributor Control Register (ICDDCR).
* This enables forwarding of interrupts to the CPU Interface(s) */
LDR R0, =0xFFFED000
STR R1, [R0]
POP {PC}

/*
* Configure registers in the GIC for an individual Interrupt ID
* We configure only the Interrupt Set Enable Registers (ICDISERn) and
* Interrupt Processor Target Registers (ICDIPTRn). The default (reset)
* values are used for other registers in the GIC
* Arguments: R0 = Interrupt ID, N
* R1 = CPU target
*/


CONFIG_INTERRUPT:
PUSH {R4-R5, LR}

/* Configure Interrupt Set-Enable Registers (ICDISERn).
* reg_offset = (integer_div(N / 32) * 4
* value = 1 << (N mod 32) */
LSR R4, R0, #3    // calculate reg_offset
BIC R4, R4, #3    // R4 = reg_offset
LDR R2, =0xFFFED100
ADD R4, R2, R4    // R4 = address of ICDISER
AND R2, R0, #0x1F // N mod 32
MOV R5, #1        // enable
LSL R2, R5, R2    // R2 = value

/* Using the register address in R4 and the value in R2 set the
* correct bit in the GIC register */
LDR R3, [R4]      // read current register value
ORR R3, R3, R2    // set the enable bit
STR R3, [R4]      // store the new register value

/* Configure Interrupt Processor Targets Register (ICDIPTRn)
* reg_offset = integer_div(N / 4) * 4
* index = N mod 4 */
BIC R4, R0, #3    // R4 = reg_offset
LDR R2, =0xFFFED800
ADD R4, R2, R4    // R4 = word address of ICDIPTR
AND R2, R0, #0x3  // N mod 4
ADD R4, R2, R4    // R4 = byte address in ICDIPTR

/* Using register address in R4 and the value in R2 write to
* (only) the appropriate byte */
STRB R1, [R4]
POP {R4-R5, PC}


KEY_ISR:
push {lr}
bl PB_clear_edgecp_ASM				//read and clear edgecapture register
ldr r1, =PB_int_flag 
str r0, [r1]						//load value of edgecapture register into PB_int_flag
pop {lr}
bx lr


ARM_TIM_ISR:
push {lr}
mov r0, #1
ldr r1, =tim_int_flag				//write '1' to tim_int_flag
str r0, [r1]
bl ARM_TIM_clear_INT_ASM			//clear timer interrupt register
pop {lr}
bx lr


_start:

/* Set up stack pointers for IRQ and SVC processor modes */
MOV        R1, #0b11010010		// interrupts masked, MODE = IRQ
MSR        CPSR_c, R1           // change to IRQ mode
LDR        SP, =0xFFFFFFFF - 3  // set IRQ stack to A9 onchip memory

/* Change to SVC (supervisor) mode with interrupts disabled */
MOV        R1, #0b11010011      // interrupts masked, MODE = SVC
MSR        CPSR, R1             // change to supervisor mode
LDR        SP, =0x3FFFFFFF - 3  // set SVC stack to top of DDR3 memory
BL         CONFIG_GIC          	// configure the ARM GIC

/* Enable pushbutton interrupts*/
mov r0, #0xf
bl enable_PB_INT_ASM

/* Enable timer interrupts*/
mov r1, #0b100
bl ARM_TIM_config_ASM

// enable IRQ interrupts in the processor
MOV        R0, #0b01010011      // IRQ unmasked, MODE = SVC
MSR        CPSR_c, R0

/* Stopwatch setup */
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
mov r1, #0b110				//prescaler = 0, I = 1, A = 1, E = 0
bl ARM_TIM_config_ASM		//set timer configuration
ldr r6, =PB_int_flag		//load address of PB_int_flag
ldr r5, =tim_int_flag		//load address of tim_int_flag


IDLE:
ldr r4, [r6]				//load contents of PB_int_flag

cmp r4, #0b1				//if = 0b1, start timer
bne stop_check
mov r4, #0
str r4, [r6]				//reset PB_int_flag
ldr r0, =0x1E8480			
mov r1, #0b111		
bl ARM_TIM_config_ASM
b loop

stop_check:
cmp r4, #0b10				//if = 0b10, stop timer
bne reset_check
mov r4, #0
str r4, [r6]				//reset PB_int_flag
ldr r0, =0x1E8480			
mov r1, #0b110				
bl ARM_TIM_config_ASM
b loop

reset_check:
cmp r4, #0b100				//if = 0b100, reset counter and display new values
bne loop
moveq r4, #0
streq r4, [r6]				//reset PB_int_flag
moveq r7, #0
moveq r8, #0				
moveq r9, #0				
moveq r10, #0				
moveq r11, #0				
moveq r12, #0				
moveq r0, #0b111111
moveq r1, #0				
bleq HEX_write_ASM	

loop:
ldr r4, [r5]				//load contents of tim_int_flag

cmp r4, #0b1				//if equal to 1, continue, else branch back to input check
bne IDLE
mov r4, #0
str r4, [r5]				//reset tim_int_flag

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
beq IDLE					//branch back to input check

mov r0, #0b100000			
mov r1, r7
bl HEX_write_ASM			//otherwise display counter value on sixth hex display

B IDLE 						//branch back to input check