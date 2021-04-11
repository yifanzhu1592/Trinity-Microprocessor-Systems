; Sample program makes the 4 LEDs P1.16, P1.17, P1.18, P1.19 go on and off in sequence
; (c) Mike Brady, 2020.

	area	tcd,code,readonly
	export	__main
__main

IO1DIR	EQU	0xE0028018
IO1PIN	EQU	0xE0028010

	ldr	r0, =IO1DIR
	ldr	r1, =0x00000000
	str	r1, [r0]
	ldr	r0, =IO1PIN
continue
	ldr	r1, =0x0f000000		; p.27 - p.24
	ldr	r2, [r0]
	and	r2, r1
	cmp	r2, r1
	beq	continue		; no buttons have been pressed
	
	ldr	r1, =0x0e000000		; test if p.24 has been pressed
	cmp	r2, r1
	bne	test2
	bl	action1
test2
	ldr	r1, =0x0d000000		; test if p.25 has been pressed
	cmp	r2, r1
	bne	test3
	bl	action2
test3
	ldr	r1, =0x0b000000		; test if p.26 has been pressed
	cmp	r2, r1
	bne	test4
	bl	action3
test4
	ldr	r1, =0x07000000		; test if p.27 has been pressed
	cmp	r2, r1
	bne	test5
	bl	action4
test5

	bl	continue
	
fin	b	fin

; subroutine 1
action1
	stmfd	sp!, {r0}
	ldr	r0, =IO1DIR
	ldr	r1, [r0]
	add	r1, r1, #0x00010000	; add 1 to the value of D
	ldr	r2, =0x01000000		; test if the value of "D" has reached the upper bound
	cmp	r1, r2
	bne	normal
	ldr	r1, =0x00000000
normal
	str	r1, [r0]
	ldr	r0, =IO1PIN
wait
	ldr	r1, =0x0f000000		; p.27 - p.24
	ldr	r2, [r0]
	and	r2, r1
	cmp	r2, r1
	bne	wait			; the button has not been released
	ldmfd	sp!, {r0}
	bx	lr

; subroutine 2
action2
	stmfd	sp!, {r0}
	ldr	r0, =IO1DIR
	ldr	r1, [r0]
	sub	r1, r1, #0x00010000	; subtract 1 from the value of D
	ldr	r2, =0xffff0000		; test if the value of "D" has reached the lower bound
	cmp	r1, r2
	bne	normal1
	ldr	r1, =0x00ff0000
normal1
	str	r1, [r0]
	ldr	r0, =IO1PIN
wait1
	ldr	r1, =0x0f000000		; p.27 - p.24
	ldr	r2, [r0]
	and	r2, r1
	cmp	r2, r1
	bne	wait1			; the button has not been released
	ldmfd	sp!, {r0}
	bx	lr

; subroutine 3
action3
	stmfd	sp!, {r0}
	ldr	r0, =IO1DIR
	ldr	r1, [r0]
	mov	r1, r1, lsl #1		; shift the bits in D to the left by one bit position
	ldr	r2, =0x01000000		; test if the value of "D" has reached the upper bound
	ldr	r3, =0x01000000
	and	r2, r1
	cmp	r2, r3
	bne	normal2
	ldr	r3, =0xfeffffff
	and	r1, r3
normal2
	str	r1, [r0]
	ldr	r0, =IO1PIN
wait2
	ldr	r1, =0x0f000000		; p.27 - p.24
	ldr	r2, [r0]
	and	r2, r1
	cmp	r2, r1
	bne	wait2			; the button has not been released
	ldmfd	sp!, {r0}
	bx	lr

; subroutine 4
action4
	stmfd	sp!, {r0}
	ldr	r0, =IO1DIR
	ldr	r1, [r0]
	mov	r1, r1, lsr #1		; shift the bits in D to the right by one bit position
	ldr	r2, =0x00008000		; test if the value of "D" has reached the lower bound
	ldr	r3, =0x00008000
	and	r2, r1
	cmp	r2, r3
	bne	normal3
	ldr	r3, =0xffff7fff
	and	r1, r3
normal3
	str	r1, [r0]
	ldr	r0, =IO1PIN
wait3
	ldr	r1, =0x0f000000		; p.27 - p.24
	ldr	r2, [r0]
	and	r2, r1
	cmp	r2, r1
	bne	wait3			; the button has not been released
	ldmfd	sp!, {r0}
	bx	lr

	end
