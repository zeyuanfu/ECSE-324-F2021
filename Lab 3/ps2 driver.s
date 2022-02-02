.global _start

//lab 3 part 2


.equ pix_buf, 0xC8000000
.equ char_buf, 0xC9000000
.equ ps2_data, 0xff200100

_start:
        bl      input_loop
end:
        b       end


VGA_draw_point_ASM:
push {r4, r5, r6}
ldr r4, =319			//load constant to check for parameter validity
cmp r0, r4				//check for parameter validity, terminate if invalid
popgt {r4, r5, r6}
bxgt lr
cmp r1, #239
popgt {r4, r5, r6}
bxgt lr

lsl r5, r0, #1			//calculate pixel buffer offset
lsl r6, r1, #10
ldr r4, =pix_buf
add r4, r4, r5
add r4, r4, r6
strh r2, [r4]			//store pixel value in memory

pop {r4, r5, r6}
bx lr


VGA_clear_pixelbuff_ASM:
push {r1, r2, lr}
mov r2, #0				//value to store in pixel buffer

mov r1, #0				//y loop counter

cp_y_loop:

mov r0, #0				//x loop counter

cp_x_loop:

bl VGA_draw_point_ASM	//draw 0 at r0, r1

add r0, r0, #1			//increment x counter, branch back to x loop if less than 320, else proceed to increment y loop
cmp r0, #320
blt cp_x_loop

add r1, r1, #1			//increment y counter, branch back to y loop if less than 240, else end subroutine
cmp r1, #240
blt cp_y_loop

pop {r1, r2, lr}
bx lr


VGA_write_char_ASM:
push {r4, r5}
cmp r0, #79				//check for parameter validity, terminate if invalid
popgt {r4, r5}
bxgt lr
cmp r1, #59
popgt {r4, r5}
bxgt lr

lsl r4, r1, #7			//calculate character buffer offset
ldr r5, =char_buf
add r5, r5, r0
add r5, r5, r4
strb r2, [r5]			//store character value in memory

pop {r4, r5}
bx lr


VGA_clear_charbuff_ASM:
push {r1, r2, lr}
mov r2, #0				//value to store in character buffer

mov r1, #0				//y loop counter

cc_y_loop:

mov r0, #0				//x loop counter

cc_x_loop:

bl VGA_write_char_ASM	//draw blank character at r0, r1

add r0, r0, #1			//increment x counter, branch back to x loop if less than 80, else proceed to increment y loop
cmp r0, #80
blt cc_x_loop

add r1, r1, #1			//increment y counter, branch back to y loop if less than 60, else end subroutine
cmp r1, #60
blt cc_y_loop

pop {r1, r2, lr}
bx lr


read_PS2_data_ASM:
push {r4, r5}
ldr r4, =ps2_data
ldr r4, [r4]				//load contents of ps/2 data register

lsr r5, r4, #15				//if RVALID = 1, proceed, otherwise return 0
tst r5, #1
moveq r0, #0
popeq {r4, r5}
bxeq lr

bic r4, r4, #0xFFFFFF00		//clear all but the 8 least significant bits
strb r4, [r0]				//store char in memory at address r0
mov r0, #1					//return 1
pop {r4, r5}
bx lr


write_hex_digit:
        push    {r4, lr}
        cmp     r2, #9
        addhi   r2, r2, #55
        addls   r2, r2, #48
        and     r2, r2, #255
        bl      VGA_write_char_ASM
        pop     {r4, pc}
write_byte:
        push    {r4, r5, r6, lr}
        mov     r5, r0
        mov     r6, r1
        mov     r4, r2
        lsr     r2, r2, #4
        bl      write_hex_digit
        and     r2, r4, #15
        mov     r1, r6
        add     r0, r5, #1
        bl      write_hex_digit
        pop     {r4, r5, r6, pc}
input_loop:
        push    {r4, r5, lr}
        sub     sp, sp, #12
        bl      VGA_clear_pixelbuff_ASM
        bl      VGA_clear_charbuff_ASM
        mov     r4, #0
        mov     r5, r4
        b       .input_loop_L9
.input_loop_L13:
        ldrb    r2, [sp, #7]
        mov     r1, r4
        mov     r0, r5
        bl      write_byte
        add     r5, r5, #3
        cmp     r5, #79
        addgt   r4, r4, #1
        movgt   r5, #0
.input_loop_L8:
        cmp     r4, #59
        bgt     .input_loop_L12
.input_loop_L9:
        add     r0, sp, #7
        bl      read_PS2_data_ASM
        cmp     r0, #0
        beq     .input_loop_L8
        b       .input_loop_L13
.input_loop_L12:
        add     sp, sp, #12
        pop     {r4, r5, pc}
