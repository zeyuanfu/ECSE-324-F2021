.global _start

//lab 1 part 1.2 finalv3

.equ number, 20 //nth fibonacci number
sum: .space 4	//result

_start:

mov r0, #number	//input parameter of the function
bl _fib			//branch to fib loop
str r0, sum		//store the result in memory

_end:

b _end			//branch to end

_fib:

cmp r0, #1			//base case check
bxle lr				//if yes, branch to LR, returning the input argument
push {r0, lr}		//push original input parameter and LR to stack
sub r0, r0, #1		//calculate n-1
bl _fib				//call fib with parameter n-1
add r2, r2, r0		//r2 will temporarily hold the result of fib(n-1)
pop {r0}			//pop original input parameter to perform n-2
sub r0, r0, #2		//calculate n-2
bl _fib				//call fib with parameter n-2
add r0, r0, r2		//store the value of fib(n-1) + fib(n-2) in r0
pop {lr}			//pop LR
mov r2, #0			//clear r2
bx lr				//branch to LR

.end