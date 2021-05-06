; Interrupt Handling Sample
; (c) Mike Brady, 2021.

	area	tcd,code,readonly
	export	__main
__main

; Definitions  -- references to 'UM' are to the User Manual.

; Timer Stuff -- UM, Table 173

T0	equ	0xE0004000		; Timer 0 Base Address
T1	equ	0xE0008000

IR	equ	0			; Add this to a timer's base address to get actual register address
TCR	equ	4
MCR	equ	0x14
MR0	equ	0x18

TimerCommandReset	equ	2
TimerCommandRun	equ	1
TimerModeResetAndInterrupt	equ	3
TimerResetTimer0Interrupt	equ	1
TimerResetAllInterrupts	equ	0xFF

; VIC Stuff -- UM, Table 41
VIC	equ	0xFFFFF000		; VIC Base Address
IntEnable	equ	0x10
VectAddr	equ	0x30
VectAddr0	equ	0x100
VectCtrl0	equ	0x200

Timer0ChannelNumber	equ	4	; UM, Table 63
Timer0Mask	equ	1<<Timer0ChannelNumber	; UM, Table 63
IRQslot_en	equ	5		; UM, Table 58

; initialisation code

; Initialise the VIC
	ldr	r0,=VIC			; looking at you, VIC!

	ldr	r1,=irqhan
	str	r1,[r0,#VectAddr0] 	; associate our interrupt handler with Vectored Interrupt 0

	mov	r1,#Timer0ChannelNumber+(1<<IRQslot_en)
	str	r1,[r0,#VectCtrl0] 	; make Timer 0 interrupts the source of Vectored Interrupt 0

	mov	r1,#Timer0Mask
	str	r1,[r0,#IntEnable]	; enable Timer 0 interrupts to be recognised by the VIC

	mov	r1,#0
	str	r1,[r0,#VectAddr]   	; remove any pending interrupt (may not be needed)

; Initialise Timer 0
	ldr	r0,=T0			; looking at you, Timer 0!

	mov	r1,#TimerCommandReset
	str	r1,[r0,#TCR]

	mov	r1,#TimerResetAllInterrupts
	str	r1,[r0,#IR]

	ldr	r1,=(14745600/1)-1	 ; 1 second
	str	r1,[r0,#MR0]

	mov	r1,#TimerModeResetAndInterrupt
	str	r1,[r0,#MCR]

	mov	r1,#TimerCommandRun
	str	r1,[r0,#TCR]

;from here, initialisation is finished, so it should be the main body of the main program
IO1PIN	equ	0xE0028010

loop
	ldr	r0, =counter
	ldr	r1, [r0]
	bl	getTime
	
	mov	r4, r3
	bl	deToBi
	lsl	r7, r5, #24		; hours
	
	mov	r4, r2
	bl	deToBi
	lsl	r8, r5, #12		; minutes
	
	mov	r4, r1
	bl	deToBi
	mov	r9, r5			; seconds
	
	orr	r9, r9, r8
	orr	r9, r9, r7
	ldr	r1, =0x00F00F00
	orr	r1, r1, r9
	
	ldr	r0, =IO1PIN
	str	r1, [r0]

	b	loop

; subroutine for transferring decimal numbers into binary representation
; r4:	decimal number
; r5:	binary representation
; r6:	10
deToBi
	stmfd	sp!, {lr}
	mov	r6, #10
	mov	r5, #0
	
tens
	cmp	r4, r6
	blt	ones
	add	r5, #1
	sub	r4, r4, r6
	bl	tens
ones
	lsl	r5, r5, #4
	add	r5, r5, r4
	
	ldmfd	sp!, {pc}^

; subroutine for getting the elapsed time in hours, minutes and seconds
; r1:	the seconds
; r2:	the minutes
; r3:	the hours
; r4:	60
; r5:	24
getTime
	stmfd	sp!, {lr}
	mov	r2, #0
	mov	r3, #0
	mov	r4, #60
	mov	r5, #24
	
secondsLoop
	cmp	r1, r4
	blt	minutesLoop
	add	r2, #1
	sub	r1, r1, r4
	bl	secondsLoop
minutesLoop
	cmp	r2, r4
	blt	hoursLoop
	add	r3, #1
	sub	r2, r2, r4
	bl	minutesLoop
hoursLoop
	cmp	r3, r5
	blt	endSub
	sub	r3, r3, r5
endSub
	ldmfd	sp!, {pc}^

	AREA	InterruptStuff, CODE, READONLY
irqhan	sub	lr,lr,#4
	stmfd	sp!,{r0-r1,lr}	; the lr will be restored to the pc

;this is the body of the interrupt handler

;here you'd put the unique part of your interrupt handler
;all the other stuff is "housekeeping" to save registers and acknowledge interrupts

;this is where we stop the timer from making the interrupt request to the VIC
;i.e. we 'acknowledge' the interrupt
	ldr	r0,=T0
	mov	r1,#TimerResetTimer0Interrupt
	str	r1,[r0,#IR]	   	; remove MR0 interrupt request from timer

;here we stop the VIC from making the interrupt request to the CPU:
	ldr	r0,=VIC
	mov	r1,#0
	str	r1,[r0,#VectAddr]	; reset VIC
	
	; After each second, the counter++
	ldr	r0, =counter
	ldr	r1, [r0]
	add	r1, #1
	str	r1, [r0]

	ldmfd	sp!,{r0-r1,pc}^	; return from interrupt, restoring pc from lr
				; and also restoring the CPSR
	AREA	InterruptData, DATA, READWRITE
counter space 4			; this will be our counter
	
                END
