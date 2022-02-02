.global _start

//lab 1 part 1.1 final

.equ number, 25 //nth fibonacci number
sum: .space 4	//result

_start:

mov r0, #0	//1st fibonacci number
mov r1, #1	// 2nd fibonacci number
mov r12, #2	//current fibonacci number counter (starting at 2)

_addition:

add r2, r1, r0		//add n-1th and n-2th fibonacci number
cmp r12, #number	//compare counter to specified number
bge _store			//branch if counter => number

add r12, r12, #1	//else, add 1 to counter
mov r0, r1			//move n-1th number to n-2th position
mov r1, r2			//move nth number to n-1th position
b _addition			//branch back to beginning of loop

_store:
str r2, sum			//store result in memory

_end:
b _end
.end