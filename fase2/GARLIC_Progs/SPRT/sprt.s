	.arch armv5te
	.eabi_attribute 23, 1
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 1
	.eabi_attribute 30, 6
	.eabi_attribute 34, 0
	.eabi_attribute 18, 4
	.file	"SPRT.c"
	.text
	.align	2
	.global	_start
	.syntax unified
	.arm
	.fpu softvfp
	.type	_start, %function
_start:
	@ args = 0, pretend = 0, frame = 128
	@ frame_needed = 0, uses_anonymous_args = 0
	str	lr, [sp, #-4]!
	sub	sp, sp, #132
	str	r0, [sp, #4]
	mov	r3, #256
	strh	r3, [sp, #102]	@ movhi
	mov	r3, #192
	strh	r3, [sp, #100]	@ movhi
	mov	r3, #16
	strh	r3, [sp, #98]	@ movhi
	ldrh	r3, [sp, #98]
	rsb	r3, r3, #0
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	strh	r3, [sp, #96]	@ movhi
	ldrh	r2, [sp, #102]
	ldrh	r3, [sp, #98]
	sub	r3, r2, r3
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	strh	r3, [sp, #94]	@ movhi
	ldrh	r3, [sp, #98]
	rsb	r3, r3, #0
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	strh	r3, [sp, #92]	@ movhi
	ldrh	r2, [sp, #100]
	ldrh	r3, [sp, #98]
	sub	r3, r2, r3
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	strh	r3, [sp, #90]	@ movhi
	ldr	r3, [sp, #4]
	and	r3, r3, #3
	str	r3, [sp, #84]
	mov	r3, #1
	str	r3, [sp, #124]
	ldr	r3, [sp, #84]
	cmp	r3, #1
	bne	.L2
	mov	r3, #2
	str	r3, [sp, #124]
	b	.L3
.L2:
	ldr	r3, [sp, #84]
	cmp	r3, #2
	bne	.L4
	mov	r3, #2
	str	r3, [sp, #124]
	b	.L3
.L4:
	ldr	r3, [sp, #84]
	cmp	r3, #3
	bne	.L3
	mov	r3, #8
	str	r3, [sp, #124]
.L3:
	ldr	r3, [sp, #84]
	cmp	r3, #2
	bne	.L5
	mov	r3, #128
	strh	r3, [sp, #102]	@ movhi
	mov	r3, #96
	strh	r3, [sp, #100]	@ movhi
.L5:
	ldr	r3, [sp, #84]
	cmp	r3, #3
	bne	.L6
	mov	r3, #64
	strh	r3, [sp, #102]	@ movhi
	mov	r3, #48
	strh	r3, [sp, #100]	@ movhi
.L6:
	mov	r3, #0
	str	r3, [sp, #120]
	b	.L7
.L8:
	ldr	r3, [sp, #120]
	and	r3, r3, #255
	mov	r2, r3
	lsl	r2, r2, #3
	sub	r3, r2, r3
	and	r3, r3, #255
	add	r3, r3, #3
	and	r3, r3, #255
	and	r3, r3, #63
	strb	r3, [sp, #83]
	ldr	r3, [sp, #120]
	and	r3, r3, #255
	ldrb	r2, [sp, #83]	@ zero_extendqisi2
	mov	r1, r2
	mov	r0, r3
	bl	GARLIC_spriteSet
	ldr	r3, [sp, #120]
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	and	r3, r3, #3
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	mov	r2, r3	@ movhi
	lsl	r2, r2, #4
	sub	r3, r2, r3
	lsl	r3, r3, #2
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	add	r3, r3, #20
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	lsl	r3, r3, #16
	asr	r2, r3, #16
	ldr	r3, [sp, #120]
	lsl	r3, r3, #1
	add	r1, sp, #128
	add	r3, r1, r3
	sub	r3, r3, #68
	strh	r2, [r3]	@ movhi
	ldr	r3, [sp, #120]
	asr	r3, r3, #2
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	mov	r2, r3	@ movhi
	lsl	r2, r2, #4
	sub	r3, r2, r3
	lsl	r3, r3, #2
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	add	r3, r3, #20
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	lsl	r3, r3, #16
	asr	r2, r3, #16
	ldr	r3, [sp, #120]
	lsl	r3, r3, #1
	add	r1, sp, #128
	add	r3, r1, r3
	sub	r3, r3, #84
	strh	r2, [r3]	@ movhi
	ldr	r3, [sp, #120]
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	and	r3, r3, #1
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	add	r3, r3, #1
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	lsl	r3, r3, #16
	asr	r2, r3, #16
	ldr	r3, [sp, #120]
	lsl	r3, r3, #1
	add	r1, sp, #128
	add	r3, r1, r3
	sub	r3, r3, #100
	strh	r2, [r3]	@ movhi
	ldr	r3, [sp, #120]
	asr	r3, r3, #1
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	and	r3, r3, #1
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	add	r3, r3, #1
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	lsl	r3, r3, #16
	asr	r2, r3, #16
	ldr	r3, [sp, #120]
	lsl	r3, r3, #1
	add	r1, sp, #128
	add	r3, r1, r3
	sub	r3, r3, #116
	strh	r2, [r3]	@ movhi
	ldr	r3, [sp, #120]
	and	r0, r3, #255
	ldr	r3, [sp, #120]
	lsl	r3, r3, #1
	add	r2, sp, #128
	add	r3, r2, r3
	sub	r3, r3, #68
	ldrsh	r1, [r3]
	ldr	r3, [sp, #120]
	lsl	r3, r3, #1
	add	r2, sp, #128
	add	r3, r2, r3
	sub	r3, r3, #84
	ldrsh	r3, [r3]
	mov	r2, r3
	bl	GARLIC_spriteMove
	ldr	r3, [sp, #120]
	and	r3, r3, #255
	mov	r0, r3
	bl	GARLIC_spriteShow
	ldr	r3, [sp, #120]
	add	r3, r3, #1
	str	r3, [sp, #120]
.L7:
	ldr	r2, [sp, #120]
	ldr	r3, [sp, #124]
	cmp	r2, r3
	blt	.L8
	mov	r3, #0
	str	r3, [sp, #116]
	mov	r3, #20
	str	r3, [sp, #76]
	mov	r3, #0
	str	r3, [sp, #112]
	mov	r3, #0
	str	r3, [sp, #108]
.L17:
	mov	r3, #0
	str	r3, [sp, #104]
	b	.L9
.L14:
	ldr	r3, [sp, #104]
	lsl	r3, r3, #1
	add	r2, sp, #128
	add	r3, r2, r3
	sub	r3, r3, #68
	ldrsh	r3, [r3]
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldr	r3, [sp, #104]
	lsl	r3, r3, #1
	add	r1, sp, #128
	add	r3, r1, r3
	sub	r3, r3, #100
	ldrsh	r3, [r3]
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	add	r3, r2, r3
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	lsl	r3, r3, #16
	asr	r2, r3, #16
	ldr	r3, [sp, #104]
	lsl	r3, r3, #1
	add	r1, sp, #128
	add	r3, r1, r3
	sub	r3, r3, #68
	strh	r2, [r3]	@ movhi
	ldr	r3, [sp, #104]
	lsl	r3, r3, #1
	add	r2, sp, #128
	add	r3, r2, r3
	sub	r3, r3, #84
	ldrsh	r3, [r3]
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldr	r3, [sp, #104]
	lsl	r3, r3, #1
	add	r1, sp, #128
	add	r3, r1, r3
	sub	r3, r3, #116
	ldrsh	r3, [r3]
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	add	r3, r2, r3
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	lsl	r3, r3, #16
	asr	r2, r3, #16
	ldr	r3, [sp, #104]
	lsl	r3, r3, #1
	add	r1, sp, #128
	add	r3, r1, r3
	sub	r3, r3, #84
	strh	r2, [r3]	@ movhi
	ldr	r3, [sp, #104]
	lsl	r3, r3, #1
	add	r2, sp, #128
	add	r3, r2, r3
	sub	r3, r3, #68
	ldrsh	r3, [r3]
	ldrsh	r2, [sp, #96]
	cmp	r2, r3
	blt	.L10
	ldr	r3, [sp, #104]
	lsl	r3, r3, #1
	add	r2, sp, #128
	add	r3, r2, r3
	sub	r3, r3, #68
	ldrh	r2, [sp, #96]	@ movhi
	strh	r2, [r3]	@ movhi
	ldr	r3, [sp, #104]
	lsl	r3, r3, #1
	add	r2, sp, #128
	add	r3, r2, r3
	sub	r3, r3, #100
	ldrsh	r3, [r3]
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	rsb	r3, r3, #0
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	lsl	r3, r3, #16
	asr	r2, r3, #16
	ldr	r3, [sp, #104]
	lsl	r3, r3, #1
	add	r1, sp, #128
	add	r3, r1, r3
	sub	r3, r3, #100
	strh	r2, [r3]	@ movhi
	b	.L11
.L10:
	ldr	r3, [sp, #104]
	lsl	r3, r3, #1
	add	r2, sp, #128
	add	r3, r2, r3
	sub	r3, r3, #68
	ldrsh	r3, [r3]
	ldrsh	r2, [sp, #94]
	cmp	r2, r3
	bgt	.L11
	ldr	r3, [sp, #104]
	lsl	r3, r3, #1
	add	r2, sp, #128
	add	r3, r2, r3
	sub	r3, r3, #68
	ldrh	r2, [sp, #94]	@ movhi
	strh	r2, [r3]	@ movhi
	ldr	r3, [sp, #104]
	lsl	r3, r3, #1
	add	r2, sp, #128
	add	r3, r2, r3
	sub	r3, r3, #100
	ldrsh	r3, [r3]
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	rsb	r3, r3, #0
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	lsl	r3, r3, #16
	asr	r2, r3, #16
	ldr	r3, [sp, #104]
	lsl	r3, r3, #1
	add	r1, sp, #128
	add	r3, r1, r3
	sub	r3, r3, #100
	strh	r2, [r3]	@ movhi
.L11:
	ldr	r3, [sp, #104]
	lsl	r3, r3, #1
	add	r2, sp, #128
	add	r3, r2, r3
	sub	r3, r3, #84
	ldrsh	r3, [r3]
	ldrsh	r2, [sp, #92]
	cmp	r2, r3
	blt	.L12
	ldr	r3, [sp, #104]
	lsl	r3, r3, #1
	add	r2, sp, #128
	add	r3, r2, r3
	sub	r3, r3, #84
	ldrh	r2, [sp, #92]	@ movhi
	strh	r2, [r3]	@ movhi
	ldr	r3, [sp, #104]
	lsl	r3, r3, #1
	add	r2, sp, #128
	add	r3, r2, r3
	sub	r3, r3, #116
	ldrsh	r3, [r3]
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	rsb	r3, r3, #0
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	lsl	r3, r3, #16
	asr	r2, r3, #16
	ldr	r3, [sp, #104]
	lsl	r3, r3, #1
	add	r1, sp, #128
	add	r3, r1, r3
	sub	r3, r3, #116
	strh	r2, [r3]	@ movhi
	b	.L13
.L12:
	ldr	r3, [sp, #104]
	lsl	r3, r3, #1
	add	r2, sp, #128
	add	r3, r2, r3
	sub	r3, r3, #84
	ldrsh	r3, [r3]
	ldrsh	r2, [sp, #90]
	cmp	r2, r3
	bgt	.L13
	ldr	r3, [sp, #104]
	lsl	r3, r3, #1
	add	r2, sp, #128
	add	r3, r2, r3
	sub	r3, r3, #84
	ldrh	r2, [sp, #90]	@ movhi
	strh	r2, [r3]	@ movhi
	ldr	r3, [sp, #104]
	lsl	r3, r3, #1
	add	r2, sp, #128
	add	r3, r2, r3
	sub	r3, r3, #116
	ldrsh	r3, [r3]
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	rsb	r3, r3, #0
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	lsl	r3, r3, #16
	asr	r2, r3, #16
	ldr	r3, [sp, #104]
	lsl	r3, r3, #1
	add	r1, sp, #128
	add	r3, r1, r3
	sub	r3, r3, #116
	strh	r2, [r3]	@ movhi
.L13:
	ldr	r3, [sp, #104]
	and	r0, r3, #255
	ldr	r3, [sp, #104]
	lsl	r3, r3, #1
	add	r2, sp, #128
	add	r3, r2, r3
	sub	r3, r3, #68
	ldrsh	r1, [r3]
	ldr	r3, [sp, #104]
	lsl	r3, r3, #1
	add	r2, sp, #128
	add	r3, r2, r3
	sub	r3, r3, #84
	ldrsh	r3, [r3]
	mov	r2, r3
	bl	GARLIC_spriteMove
	ldr	r3, [sp, #104]
	add	r3, r3, #1
	str	r3, [sp, #104]
.L9:
	ldr	r2, [sp, #104]
	ldr	r3, [sp, #124]
	cmp	r2, r3
	blt	.L14
	ldr	r3, [sp, #84]
	cmp	r3, #2
	bne	.L15
	ldr	r3, [sp, #116]
	add	r3, r3, #1
	str	r3, [sp, #116]
	ldr	r2, [sp, #116]
	ldr	r3, [sp, #76]
	cmp	r2, r3
	bcc	.L15
	mov	r3, #0
	str	r3, [sp, #116]
	ldr	r3, [sp, #108]
	cmp	r3, #0
	bne	.L16
	ldr	r3, [sp, #112]
	and	r3, r3, #255
	mov	r0, r3
	bl	GARLIC_spriteHide
	mov	r3, #1
	str	r3, [sp, #108]
	b	.L15
.L16:
	ldr	r3, [sp, #112]
	and	r3, r3, #255
	mov	r0, r3
	bl	GARLIC_spriteShow
	mov	r3, #0
	str	r3, [sp, #108]
	ldr	r3, [sp, #112]
	add	r3, r3, #1
	str	r3, [sp, #112]
	ldr	r2, [sp, #112]
	ldr	r3, [sp, #124]
	cmp	r2, r3
	blt	.L15
	mov	r3, #0
	str	r3, [sp, #112]
.L15:
	mov	r0, #0
	bl	GARLIC_delay
	b	.L17
	.size	_start, .-_start
	.ident	"GCC: (devkitARM release 46) 6.3.0"
