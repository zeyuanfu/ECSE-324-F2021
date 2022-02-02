.global _start

//lab 1 part 3 final

input: .word -1, 23, 0, 12, -7, -99, 258, 38, 94, 200, 976, 2057, 4719, 2
.equ size, 14

_start:

ldr r12, =input		//load address of first element of input (ptr)
mov r11, #size-1	//calculate size-1 for loops

mov r0, #0			//set step counter (step)

_steploop:

mov r1, #0			//reset address offset counter (i)

_innerloop:

mov r2, r1						//set up register for i+1
add r2, r2, #1					//r2 = i+1
ldr r3, [r12, r1, lsl#2]		//load ptr+i
ldr r4, [r12, r2, lsl#2]		//load ptr+i+1

cmp r3, r4						//compare values to be compared
strgt r3, [r12, r2, lsl#2]		//if r3 > r4, swap the position of the two values
strgt r4, [r12, r1, lsl#2]

mov r2, r11			//set up register for size-step-1
sub r2, r2, r0		//r2 = size-1-step
add r1, r1, #1		//increment address offset counter (i)
cmp r1, r2			//check if i < size-1-step, branch back to inner loop if yes
blt _innerloop

add r0, r0, #1		//increment step counter (step)
cmp r0, r11			//check if step < size-1, branch back to step loop if yes
blt _steploop		//otherwise, program finished

_end:

b _end
.end