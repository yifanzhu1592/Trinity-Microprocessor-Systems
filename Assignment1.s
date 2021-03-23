	area	tcd,code,readonly
	export	__main
__main
	
	ldr	r2, =result



	mov	r0, #5
	mov	r4, #0
	mov	r5, #1
	mov	r10, #0
	bl	fact
	str	r0, [r2], #4
	str	r1, [r2], #4

	mov	r0, #14
	mov	r4, #0
	mov	r5, #1
	mov	r10, #0
	bl	fact
	str	r0, [r2], #4
	str	r1, [r2], #4

	mov	r0, #20
	mov	r4, #0
	mov	r5, #1
	mov	r10, #0
	bl	fact
	str	r0, [r2], #4
	str	r1, [r2], #4

	mov	r0, #30
	mov	r4, #0
	mov	r5, #1
	mov	r10, #0
	bl	fact
	str	r0, [r2], #4
	str	r1, [r2], #4
	
	

fin	b	fin



fact
	push	{lr}
	umull	r7, r6, r0, r4
	umull	r9, r8, r0, r5
	cmp	r6, #0
	bne	setC
	add	r4, r7, r8
	mov	r5, r9
	bl	notSetC
setC
	mov	r10, #1
	pop	{pc}
notSetC
	sub	r0, r0, #1
	cmp	r0, #0
	beq	c
	bl	fact
c
	cmp	r10, #0
	beq	clearC
	
	; set the C bit
	mrs	r3, cpsr
	orr	r3, #0x20000000	; turn on the equivalent of the C bit in R0 if R4 is not cleared
	msr 	cpsr_f, r3 	; put it into the C bit (f -> condition Flags, I think!)
	mov	r0, #0
	mov	r1, #0
	pop	{pc}
clearC
	; clear the C bit
	mrs	r3, cpsr
	and	r3, #0xDFFFFFFF	; turn off the equivalent of the C bit in R0
	msr 	cpsr_f, r3 	; put it into the C bit (f -> condition Flags, I think!)
	
	mov	r0, r4
	mov	r1, r5

	pop	{pc}



	area	tcdresult,data,readwrite
result	space	4 * 8		; space for four eight-byte elements
	end
