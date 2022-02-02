.global _start

//lab 3 part 3 final

.equ pix_buf, 0xC8000000
.equ char_buf, 0xC9000000
.equ ps2_data, 0xff200100

x_coords: .word 0, 89, 160, 230, 89, 160, 230, 89, 160, 230		//coordinates for center of squares
y_coords: .word 0, 49, 49, 49, 120, 120, 120, 190, 190, 190

kb_nextchar: .space 4	//space to store characters from keyboard


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

add r0, r0, #1			//increment x counter, branch back to x loop if less than 320
cmp r0, #320			//else proceed to increment y loop
blt cp_x_loop

add r1, r1, #1			//increment y counter, branch back to y loop if less than 240
cmp r1, #240			//else end subroutine
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

add r0, r0, #1			//increment x counter, branch back to x loop if less than 80 
cmp r0, #80				//else proceed to increment y loop
blt cc_x_loop

add r1, r1, #1			//increment y counter, branch back to y loop if less than 60
cmp r1, #60				//else end subroutine
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


get_next_digit:				//returns the next number key pressed
push {r4, lr}

mov r4, #3					//read counter

read_loop:					//read keyboard fifo three times 
ldr r0, =kb_nextchar		//(make code + 2 bytes of break code)
bl read_PS2_data_ASM
cmp r0, #0
beq read_loop
subs r4, r4, #1
bne read_loop

ldr r4, =kb_nextchar		//read scan code of digit
ldr r4, [r4]

cmp r4, #0x45				//check for '0'
moveq r0, #0
popeq {r4, lr}
bxeq lr

cmp r4, #0x16				//check for '1'
moveq r0, #1
popeq {r4, lr}
bxeq lr

cmp r4, #0x1e				//check for '2'
moveq r0, #2
popeq {r4, lr}
bxeq lr

cmp r4, #0x26				//check for '3'
moveq r0, #3
popeq {r4, lr}
bxeq lr

cmp r4, #0x25				//check for '4'
moveq r0, #4
popeq {r4, lr}
bxeq lr

cmp r4, #0x2e				//check for '5'
moveq r0, #5
popeq {r4, lr}
bxeq lr

cmp r4, #0x36				//check for '6'
moveq r0, #6
popeq {r4, lr}
bxeq lr

cmp r4, #0x3d				//check for '7'
moveq r0, #7
popeq {r4, lr}
bxeq lr

cmp r4, #0x3e				//check for '8'
moveq r0, #8
popeq {r4, lr}
bxeq lr

cmp r4, #0x46				//check for '9'
moveq r0, #9
popeq {r4, lr}
bxeq lr

mov r0, #0xf				//otherwise return 'f'
pop {r4, lr}
bx lr


draw_rectangle:
        push    {r4, r5, r6, r7, r8, r9, r10, lr}
        ldr     r7, [sp, #32]
        add     r9, r1, r3
        cmp     r1, r9
        popge   {r4, r5, r6, r7, r8, r9, r10, pc}
        mov     r8, r0
        mov     r5, r1
        add     r6, r0, r2
        b       .line_L2
.line_L5:
        add     r5, r5, #1
        cmp     r5, r9
        popeq   {r4, r5, r6, r7, r8, r9, r10, pc}
.line_L2:
        cmp     r8, r6
        movlt   r4, r8
        bge     .line_L5
.line_L4:
        mov     r2, r7
        mov     r1, r5
        mov     r0, r4
        bl      VGA_draw_point_ASM
        add     r4, r4, #1
        cmp     r4, r6
        bne     .line_L4
        b       .line_L5


VGA_fill_ASM:
push {lr}

mov r0, #0
mov r1, #0
ldr r2, =320
ldr r3, =#0b1111100000000000		//color of background
push {r3}
mov r3, #240
bl draw_rectangle					//draw rectangle with length and width of screen
pop {r3}

pop {lr}
bx lr


/*top left corner: 56,16
top right corner: 263, 16
bottom left corner: 56, 223
bottom right corner: 263, 223
length & width: 207
width of square: 65
thickness: 6
first vert: 121,16
second vert: 192, 16
first hor: 56, 81
second hor: 56, 152

center of top left square: 89, 49
center of top center square: 160, 49
center of top right square: 230, 49
center of middle left square: 89, 120
center of center square: 160, 120
center of middle right square: 230, 120
center of bottom left square: 89, 190
center of bottom center square: 160, 190
center of bottom right square: 230, 190

*/
draw_grid_ASM:
push {lr}
mov r0, #0				//set color of grid
push {r0}
mov r0, #121
mov r1, #16
mov r2, #6
mov r3, #207
bl draw_rectangle		//draw left vertical line
mov r0, #192
mov r1, #16
mov r2, #6
mov r3, #207
bl draw_rectangle		//draw right vertical line

mov r0, #56
mov r1, #81
mov r2, #207
mov r3, #6
bl draw_rectangle		//draw top horizontal line
mov r0, #56
mov r1, #152
mov r2, #207
mov r3, #6
bl draw_rectangle		//draw bottom horizontal line

pop {r0}
pop {lr}
bx lr


draw_plus_ASM:
push {r4, lr}
push {r0, r1}
sub r0, r0, #3
sub r1, r1, #15
mov r2, #6
mov r3, #30
mov r4, #0				//color of lines
push {r4}
bl draw_rectangle		//draw vertical line
pop {r4}
pop {r0, r1}
sub r0, #15
sub r1, #3
mov r2, #30
mov r3, #6
push {r4}
bl draw_rectangle		//draw horizontal line
pop {r4}
pop {r4, lr}
bx lr


draw_square_ASM:
push {r4, lr}

push {r0, r1}
sub r0, r0, #15
sub r1, r1, #15
mov r2, #30
mov r3, #6
mov r4, #0				//color of lines
push {r4}
bl draw_rectangle		//draw top horizontal line
pop {r4}
pop {r0, r1}

push {r0, r1}
sub r0, r0, #15
sub r1, r1, #15
mov r2, #6
mov r3, #30
push {r4}
bl draw_rectangle		//draw left vertical line
pop {r4}
pop {r0, r1}

push {r0, r1}
sub r0, r0, #15
add r1, r1, #9
mov r2, #30
mov r3, #6
push {r4}
bl draw_rectangle		//draw bottom horizontal line
pop {r4}
pop {r0, r1}

add r0, r0, #9
sub r1, r1, #15
mov r2, #6
mov r3, #30
push {r4}
bl draw_rectangle		//draw right vertical line
pop {r4}

pop {r4, lr}
bx lr


display_player_action:			//r0: player id (0 = p1, 1 = p2), r1: # of square (1-9)
push {r4, r5, r6, r7, lr}

ldr r4, =x_coords
ldr r5, =y_coords
mov r6, r0
mov r7, r1
ldr r0, [r4, r7, lsl#2]			//calculate x coord of center of chosen square
ldr r1, [r5, r7, lsl#2]			//calculate y coord of center of chosen square
cmp r6, #0
bleq draw_plus_ASM				//if r0 = 0, draw player 1 mark
blne draw_square_ASM			//if r0 = 1, draw player 2 mark

pop {r4, r5, r6, r7, lr}
bx lr


check_player_win:				//r0: board state, returns 0 if player 1 win, 
push {r4, r5, lr}				//1 if player 2 win and 2 if no one wins 

ldr r5, =#0b11111111110000000000
bic r4, r0, r5					//isolate player 1's marks
lsr r5, r0, #10					//isolate player 2's marks

mov r0, r4
bl check_winning_pattern		//check if player 1 wins, return 0 if yes
cmp r0, #1
moveq r0, #0
popeq {r4, r5, lr}
bxeq lr

mov r0, r5
bl check_winning_pattern		//check if player 2 wins, return 1 if yes
cmp r0, #1
popeq {r4, r5, lr}
bxeq lr

mov r0, #2						//return 2 if no winning board state
pop {r4, r5, lr}
bx lr


check_winning_pattern:			//r0: sequence of 10 one-hot encoded bits representing a player's marks
push {r4, r5, lr}				//returns 0 if not winning and 1 if winning

lsr r0, r0, #1

bic r4, r0, #0b111111000		//test three horizontal wincons
cmp r4, #0b111
beq winning

ldr r5, =#0b111000111
bic r4, r0, r5
cmp r4, #0b111000
beq winning

bic r4, r0, #0b000111111
cmp r4, #0b111000000
beq winning

ldr r5, =#0b110110110
bic r4, r0, r5					//test three vertical wincons
cmp r4, #0b001001001
beq winning

ldr r5, =#0b101101101
bic r4, r0, r5
cmp r4, #0b010010010
beq winning

bic r4, r0, #0b011011011
cmp r4, #0b100100100
beq winning

bic r4, r0, #0b011101110		//test two diagonal wincons
ldr r5, =#0b100010001
cmp r4, r5
beq winning

ldr r5, =#0b110101011
bic r4, r0, r5
cmp r4, #0b001010100
beq winning

mov r0, #0						//return 0 if no winning pattern
pop {r4, r5, lr}
bx lr

winning:						//return 1 if winning pattern
mov r0, #1
pop {r4, r5, lr}
bx lr


update_board_state:			//r0: board state, r1: player id (0 = player 1, 1 = player 2)
push {r4}					//r2: id of square, returns updated board state

mov r4, #1					//'1' = mark at one-hot encoded square
cmp r1, #1					//if player 2, shift left by 10
lsleq r4, r4, #10
lsl r4, r4, r2				//shift new mark position by id of square
orr r0, r0, r4				//update board state with new mark

pop {r4}
bx lr


is_valid_move:				//r0: board state, r1: square id
push {r4}					//returns 0 if move is invalid, 1 if move is valid

cmp r1, #1					//if input < 1, return 0
movlt r0, #0
poplt {r4}
bxlt lr

cmp r1, #9					//if input > 9, return 0
movgt r0, #0
popgt {r4}
bxgt lr

mov r4, #0b1				//if occupied by player 1, return 0
lsl r4, r4, r1
tst r0, r4
movne r0, #0
popne {r4}
bxne lr

lsl r4, r4, #10				//if occupied by player 2, return 0
tst r0, r4
movne r0, #0
popne {r4}
bxne lr

mov r0, #1					//otherwise, return 1
pop {r4}
bx lr


check_board_full:			//r0: board state
push {r4, r5}				//return 0 if board not full, 1 if board full

mov r4, #0					//number of filled squares
mov r5, #20					//iterated bits counter

test:
tst r0, #0b1				//add 1 to filled square counter if high
addne r4, r4, #1
lsr r0, r0, #1				//shift right by one for next bit
subs r5, r5, #1				//repeat 20 times for 20 bits in board state
bne test

cmp r4, #9					//if # filled squares = 9, return 1, else return 0
moveq r0, #1
movne r0, #0

pop {r4, r5}
bx lr


Player_turn_ASM:
push {r4, lr}
mov r4, r0

bl VGA_clear_charbuff_ASM	//clear charbuff

mov r0, #32
mov r1, #2
mov r2, #0x50
bl VGA_write_char_ASM		//print 'p'
mov r0, #33
mov r2, #0x4c
bl VGA_write_char_ASM		//print 'l'
mov r0, #34
mov r2, #0x41
bl VGA_write_char_ASM		//print 'a'
mov r0, #35
mov r2, #0x59
bl VGA_write_char_ASM		//print 'y'
mov r0, #36
mov r2, #0x45
bl VGA_write_char_ASM		//print 'e'
mov r0, #37
mov r2, #0x52
bl VGA_write_char_ASM		//print 'r'
mov r0, #38
mov r2, #0x20
bl VGA_write_char_ASM		//print ' '
mov r0, #39
cmp r4, #0
moveq r2, #0x31
movne r2, #0x32
bl VGA_write_char_ASM		//print '1' or '2' depending on input
mov r0, #40
mov r2, #0x27
bl VGA_write_char_ASM		//print '''
mov r0, #41
mov r2, #0x53
bl VGA_write_char_ASM		//print 's'
mov r0, #42
mov r2, #0x20
bl VGA_write_char_ASM		//print ' '
mov r0, #43
mov r2, #0x54
bl VGA_write_char_ASM		//print 't'
mov r0, #44
mov r2, #0x55
bl VGA_write_char_ASM		//print 'u'
mov r0, #45
mov r2, #0x52
bl VGA_write_char_ASM		//print 'r'
mov r0, #46
mov r2, #0x4e
bl VGA_write_char_ASM		//print 'n'

pop {r4, lr}
bx lr


result_ASM:
push {r4, lr}
mov r4, r0

bl VGA_clear_charbuff_ASM	//clear charbuff

cmp r4, #0
beq win
cmp r4, #1
beq win

mov r0, #38					//if input is not 0 or 1, print "draw"
mov r1, #2
mov r2, #0x44
bl VGA_write_char_ASM		//print 'd'
mov r0, #39
mov r2, #0x52
bl VGA_write_char_ASM		//print 'r'
mov r0, #40
mov r2, #0x41
bl VGA_write_char_ASM		//print 'a'
mov r0, #41
mov r2, #0x57
bl VGA_write_char_ASM		//print 'w'
pop {r4, lr}
bx lr

win:
mov r0, #33
mov r1, #2
mov r2, #0x50
bl VGA_write_char_ASM		//print 'p'
mov r0, #34
mov r2, #0x4c
bl VGA_write_char_ASM		//print 'l'
mov r0, #35
mov r2, #0x41
bl VGA_write_char_ASM		//print 'a'
mov r0, #36
mov r2, #0x59
bl VGA_write_char_ASM		//print 'y'
mov r0, #37
mov r2, #0x45
bl VGA_write_char_ASM		//print 'e'
mov r0, #38
mov r2, #0x52
bl VGA_write_char_ASM		//print 'r'
mov r0, #39
mov r2, #0x20
bl VGA_write_char_ASM		//print ' '
mov r0, #40
cmp r4, #0
moveq r2, #0x31
movne r2, #0x32
bl VGA_write_char_ASM		//print '1' or '2' depending on input
mov r0, #41
mov r2, #0x20
bl VGA_write_char_ASM		//print ' '
mov r0, #42
mov r2, #0x57
bl VGA_write_char_ASM		//print 'w'
mov r0, #43
mov r2, #0x49
bl VGA_write_char_ASM		//print 'i'
mov r0, #44
mov r2, #0x4e
bl VGA_write_char_ASM		//print 'n'
mov r0, #45
mov r2, #0x53
bl VGA_write_char_ASM		//print 's'

pop {r4, lr}
bx lr


_start:
bl VGA_clear_pixelbuff_ASM	//set up board
bl VGA_clear_charbuff_ASM
bl VGA_fill_ASM
bl draw_grid_ASM
mov r12, #0					//board state register

wait_for_zero_to_start:
bl get_next_digit			//wait for '0' to start, loop if input is not '0'
cmp r0, #0
bne wait_for_zero_to_start

player_1_turn:
mov r0, #0
bl Player_turn_ASM			//display player turn above board

p1_get_input:
bl get_next_digit			//get player input
mov r4, r0

mov r0, r12
mov r1, r4
bl is_valid_move
cmp r0, #0
beq p1_get_input			//branch back to get_input if input is not a valid move

mov r0, #0
mov r1, r4
bl display_player_action	//draw player 1 mark on board

mov r0, r12
mov r1, #0
mov r2, r4
bl update_board_state		//update board state with new mark
mov r12, r0

bl check_player_win			//check if player wins, if yes, end game
cmp r0, #0
beq game_end

mov r0, r12
bl check_board_full			//check if board is full, if yes, end game
cmp r0, #1
moveq r0, #2
beq game_end

player_2_turn:
mov r0, #1
bl Player_turn_ASM			//display player turn above board

p2_get_input:
bl get_next_digit			//get player input
mov r4, r0

mov r0, r12
mov r1, r4
bl is_valid_move
cmp r0, #0
beq p2_get_input			//branch back to get_input if input is not a valid move

mov r0, #1
mov r1, r4
bl display_player_action	//draw player 2 mark on board

mov r0, r12
mov r1, #1
mov r2, r4
bl update_board_state		//update board state with new mark
mov r12, r0

bl check_player_win			//check if player wins, if yes, end game
cmp r0, #1
beq game_end
b player_1_turn				//board cannot become full on player 2's turn

game_end:
bl result_ASM				//display result of game

wait_for_zero_to_reset:
bl get_next_digit			//wait for '0' to reset game, loop if input is not '0'
cmp r0, #0
bne wait_for_zero_to_reset
b _start
