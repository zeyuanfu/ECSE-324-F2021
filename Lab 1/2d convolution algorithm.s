.global _start

//lab 1 part 2 final

fx: .word 183, 207, 128, 30, 109, 0, 14, 52, 15, 210, 228, 76, 48, 82, 179, 194, 22, 168, 58, 116, 228, 217, 180, 181, 243, 65, 24, 127, 216, 118, 64, 210, 138, 104, 80, 137, 212, 196, 150, 139, 155, 154, 36, 254, 218, 65, 3, 11, 91, 95, 219, 10, 45, 193, 204, 196, 25, 177, 188, 170, 189, 241, 102, 237, 251, 223, 10, 24, 171, 71, 0, 4, 81, 158, 59, 232, 155, 217, 181, 19, 25, 12, 80, 244, 227, 101, 250, 103, 68, 46, 136, 152, 144, 2, 97, 250, 47, 58, 214, 51
kx: .word 1, 1, 0, -1, -1, 0, 1, 0, -1, 0, 0, 0, 1, 0, 0, 0, -1, 0, 1, 0, -1, -1, 0, 1, 1
gx: .space 400	//result, address begins at 000001f4

.equ ih, 10		//image height parameter
.equ iw, 10		//image width parameter
.equ kh, 5		//kernel height parameter
.equ kw, 5		//kernel width parameter

_start:

ldr r9, =fx		//load address of first element of fx
ldr r10, =kx	//load address of first element of kx
mov r11, #kh	//kernel height for array calculations
mov r12, #ih	//image height for array calculations
mov r4, #kh-1	//kernel height stride (khw) calculation
lsr r4, #1
mov r5, #kw-1	//kernel width stride (ksw) calculation
lsr r5, #1

mov r0, #0		//set imageheight counter (y)

_imageheight:

mov r1, #0		//reset imagewidth counter (x)

_imagewidth:

mov r2, #0		//reset kernelwidth counter (i)
mov r6, #0		//reset sum accumulator

_kernelwidth:

mov r3, #0		//reset kernelheight counter (j)

_kernelheight:

mov r7, #0			//reset registers
mov r8, #0
add r7, r1, r3		//temp1 = iw(x) + kh(j)
add r8, r0, r2		//temp2 = ih(y) + kw(i)
sub r7, r7, r5		//temp1 = temp1 - ksw
sub r8, r8, r4		//temp2 = temp2 - khw

cmp r7, #0				//check if temp1 >= 0, branch to end of kh loop if not
blt _incrementheight
cmp r7, #iw				//check if temp1 < iw, branch to end of kh loop if not
bge _incrementheight
cmp r8, #0				//check if temp2 >= 0, branch to end of kh loop if not
blt _incrementheight
cmp r8, #ih				//check if temp2 < ih, branch to end of kh loop if not
bge _incrementheight

mla r7, r7, r12, r8		//calculate offset (in addresses) from address zero of array fx
mla r8, r3, r11, r2		//calculate offset (in addresses) from address zero of array kx

ldr r7, [r9, r7, lsl#2]		//load the value of fx at temp1*ih+temp2
ldr r8, [r10, r8, lsl#2]	//load the value of kx at j*kh+i

mla r6, r7, r8, r6		//add product of r7 and r8 to the sum accumulator

_incrementheight:

add r3, r3, #1			//increment kernelheight counter (j)
cmp r3, #kh				//check if j >= #kh, branch to beginning of kh loop if not
blt _kernelheight
add r2, r2, #1			//increment kernelwidth counter (i)
cmp r2, #kw				//check if i >= #kw, branch to begining of kw loop if not
blt _kernelwidth

ldr r7, =gx					//load address of first element of gx
mov r8, #0					//reset r8
mla r8, r1, r12, r0			//calculate offset from address zero of array gx
str r6, [r7, r8, lsl#2]		//store the accumulated sum at x*ih+y

add r1, r1, #1			//increment imagewidth counter (x)
cmp r1, #iw				//check if x >= #iw, branch to beginning of iw loop if not
blt _imagewidth
add r0, r0, #1			//increment imageheight counter (y)
cmp r0, #ih				//check if y >= #ih, branch to beginning of ih loop if not
blt _imageheight		//otherwise, program finished

_end:

b _end
.end

//convert with https://www.convzone.com/hex-to-decimal/
//results: 	00000290 000000a0 00000071 00000048 ffffffcd fffffe52 00000017 0000014d ffffffba ffffff41 
			0000024a 00000105 00000063 00000021 000000c8 00000126 000000a1 0000012b fffffe86 fffffe51 
			000000d9 00000277 000001e2 00000137 00000056 ffffffe1 ffffffe2 ffffffc0 00000094 fffffff7 
			ffffffbc 00000100 000001e5 0000013f ffffffa0 00000011 000000d0 0000010f 0000011d 0000007d 
			ffffff9d ffffffb3 00000194 000002b3 00000162 fffffe55 fffffe7b 00000000 000000d3 000000cd 
			0000002b 00000067 000000f4 000001f1 000001a4 00000065 ffffff72 0000007b 00000043 00000026 
			00000055 00000294 00000158 000000c7 0000023b 00000346 00000026 fffffe2c fffffe68 00000009 
			0000000c 00000089 ffffffd8 ffffff76 00000062 000002b9 0000013c fffffed9 00000037 000000d7 
			ffffff56 ffffff2d fffffee6 00000058 000001fb 00000199 00000160 000000eb 000000de 000000d0 
			00000027 ffffff72 fffffed3 fffffea1 0000005c 00000048 ffffffc2 000001ab 00000270 00000205 