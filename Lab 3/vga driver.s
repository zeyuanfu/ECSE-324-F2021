.global _start

//lab 3 part 1


.equ pix_buf, 0xC8000000
.equ char_buf, 0xC9000000

_start:
        bl      draw_test_screen
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

add r0, r0, #1			//increment x counter, branch back to x loop 
cmp r0, #320			//if less than 320, else proceed to increment y loop
blt cp_x_loop

add r1, r1, #1			//increment y counter, branch back to y loop 
cmp r1, #240			//if less than 240, else end subroutine
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

add r0, r0, #1			//increment x counter, branch back to x loop 
cmp r0, #80				//if less than 80, else proceed to increment y loop
blt cc_x_loop

add r1, r1, #1			//increment y counter, branch back to y loop 
cmp r1, #60				//if less than 60, else end subroutine
blt cc_y_loop

pop {r1, r2, lr}
bx lr


draw_test_screen:
        push    {r4, r5, r6, r7, r8, r9, r10, lr}
        bl      VGA_clear_pixelbuff_ASM
        bl      VGA_clear_charbuff_ASM
        mov     r6, #0
        ldr     r10, .draw_test_screen_L8
        ldr     r9, .draw_test_screen_L8+4
        ldr     r8, .draw_test_screen_L8+8
        b       .draw_test_screen_L2
.draw_test_screen_L7:
        add     r6, r6, #1
        cmp     r6, #320
        beq     .draw_test_screen_L4
.draw_test_screen_L2:
        smull   r3, r7, r10, r6
        asr     r3, r6, #31
        rsb     r7, r3, r7, asr #2
        lsl     r7, r7, #5
        lsl     r5, r6, #5
        mov     r4, #0
.draw_test_screen_L3:
        smull   r3, r2, r9, r5
        add     r3, r2, r5
        asr     r2, r5, #31
        rsb     r2, r2, r3, asr #9
        orr     r2, r7, r2, lsl #11
        lsl     r3, r4, #5
        smull   r0, r1, r8, r3
        add     r1, r1, r3
        asr     r3, r3, #31
        rsb     r3, r3, r1, asr #7
        orr     r2, r2, r3
        mov     r1, r4
        mov     r0, r6
        bl      VGA_draw_point_ASM
        add     r4, r4, #1
        add     r5, r5, #32
        cmp     r4, #240
        bne     .draw_test_screen_L3
        b       .draw_test_screen_L7
.draw_test_screen_L4:
        mov     r2, #72
        mov     r1, #5
        mov     r0, #20
        bl      VGA_write_char_ASM
        mov     r2, #101
        mov     r1, #5
        mov     r0, #21
        bl      VGA_write_char_ASM
        mov     r2, #108
        mov     r1, #5
        mov     r0, #22
        bl      VGA_write_char_ASM
        mov     r2, #108
        mov     r1, #5
        mov     r0, #23
        bl      VGA_write_char_ASM
        mov     r2, #111
        mov     r1, #5
        mov     r0, #24
        bl      VGA_write_char_ASM
        mov     r2, #32
        mov     r1, #5
        mov     r0, #25
        bl      VGA_write_char_ASM
        mov     r2, #87
        mov     r1, #5
        mov     r0, #26
        bl      VGA_write_char_ASM
        mov     r2, #111
        mov     r1, #5
        mov     r0, #27
        bl      VGA_write_char_ASM
        mov     r2, #114
        mov     r1, #5
        mov     r0, #28
        bl      VGA_write_char_ASM
        mov     r2, #108
        mov     r1, #5
        mov     r0, #29
        bl      VGA_write_char_ASM
        mov     r2, #100
        mov     r1, #5
        mov     r0, #30
        bl      VGA_write_char_ASM
        mov     r2, #33
        mov     r1, #5
        mov     r0, #31
        bl      VGA_write_char_ASM
        pop     {r4, r5, r6, r7, r8, r9, r10, pc}
.draw_test_screen_L8:
        .word   1717986919
        .word   -368140053
        .word   -2004318071
