	.arch armv5te
	.eabi_attribute 23, 1
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 1
	.eabi_attribute 30, 6
	.eabi_attribute 34, 0
	.eabi_attribute 18, 4
	.file	"usr1.c"
	.text
	.align	2
	.syntax unified
	.arm
	.fpu softvfp
	.type	str_len, %function
str_len:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	sub	sp, sp, #16
	str	r0, [sp, #4]
	mov	r3, #0
	str	r3, [sp, #12]
	b	.L2
.L3:
	ldr	r3, [sp, #12]
	add	r3, r3, #1
	str	r3, [sp, #12]
.L2:
	ldr	r3, [sp, #12]
	ldr	r2, [sp, #4]
	add	r3, r2, r3
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #0
	bne	.L3
	ldr	r3, [sp, #12]
	mov	r0, r3
	add	sp, sp, #16
	@ sp needed
	bx	lr
	.size	str_len, .-str_len
	.section	.rodata
	.align	2
.LC0:
	.ascii	"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789\000"
	.text
	.align	2
	.syntax unified
	.arm
	.fpu softvfp
	.type	generar_matriu_adfgvx, %function
generar_matriu_adfgvx:
	@ args = 0, pretend = 0, frame = 208
	@ frame_needed = 0, uses_anonymous_args = 0
	str	lr, [sp, #-4]!
	sub	sp, sp, #212
	str	r0, [sp, #4]
	ldr	r3, .L12
	add	ip, sp, #152
	mov	lr, r3
	ldmia	lr!, {r0, r1, r2, r3}
	stmia	ip!, {r0, r1, r2, r3}
	ldmia	lr!, {r0, r1, r2, r3}
	stmia	ip!, {r0, r1, r2, r3}
	ldm	lr, {r0, r1}
	str	r0, [ip]
	add	ip, ip, #4
	strb	r1, [ip]
	mov	r3, #0
	str	r3, [sp, #204]
	b	.L6
.L7:
	ldr	r3, [sp, #204]
	lsl	r3, r3, #2
	add	r2, sp, #208
	add	r3, r2, r3
	mov	r2, #0
	str	r2, [r3, #-200]
	ldr	r3, [sp, #204]
	add	r3, r3, #1
	str	r3, [sp, #204]
.L6:
	ldr	r3, [sp, #204]
	cmp	r3, #35
	ble	.L7
	mov	r3, #0
	str	r3, [sp, #200]
	b	.L8
.L11:
	mov	r3, #0
	str	r3, [sp, #196]
	b	.L9
.L10:
	bl	GARLIC_random
	mov	r2, r0
	ldr	r3, .L12+4
	smull	r1, r3, r2, r3
	asr	r1, r3, #3
	asr	r3, r2, #31
	sub	r1, r1, r3
	mov	r3, r1
	lsl	r3, r3, #3
	add	r3, r3, r1
	lsl	r3, r3, #2
	sub	r3, r2, r3
	str	r3, [sp, #192]
	ldr	r3, [sp, #192]
	lsl	r3, r3, #2
	add	r2, sp, #208
	add	r3, r2, r3
	ldr	r3, [r3, #-200]
	cmp	r3, #0
	bne	.L10
	ldr	r3, [sp, #192]
	lsl	r3, r3, #2
	add	r2, sp, #208
	add	r3, r2, r3
	mov	r2, #1
	str	r2, [r3, #-200]
	ldr	r2, [sp, #200]
	mov	r3, r2
	lsl	r3, r3, #1
	add	r3, r3, r2
	lsl	r3, r3, #1
	mov	r2, r3
	ldr	r3, [sp, #4]
	add	r2, r3, r2
	add	r1, sp, #152
	ldr	r3, [sp, #192]
	add	r3, r1, r3
	ldrb	r1, [r3]	@ zero_extendqisi2
	ldr	r3, [sp, #196]
	add	r3, r2, r3
	mov	r2, r1
	strb	r2, [r3]
	ldr	r3, [sp, #196]
	add	r3, r3, #1
	str	r3, [sp, #196]
.L9:
	ldr	r3, [sp, #196]
	cmp	r3, #5
	ble	.L10
	ldr	r3, [sp, #200]
	add	r3, r3, #1
	str	r3, [sp, #200]
.L8:
	ldr	r3, [sp, #200]
	cmp	r3, #5
	ble	.L11
	nop
	add	sp, sp, #212
	@ sp needed
	ldr	pc, [sp], #4
.L13:
	.align	2
.L12:
	.word	.LC0
	.word	954437177
	.size	generar_matriu_adfgvx, .-generar_matriu_adfgvx
	.section	.rodata
	.align	2
.LC1:
	.ascii	"Matriu ADFGVX generada:\012\000"
	.align	2
.LC2:
	.ascii	"%c \000"
	.align	2
.LC3:
	.ascii	"\012\000"
	.text
	.align	2
	.syntax unified
	.arm
	.fpu softvfp
	.type	imprimir_matriu_adfgvx, %function
imprimir_matriu_adfgvx:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 0, uses_anonymous_args = 0
	str	lr, [sp, #-4]!
	sub	sp, sp, #20
	str	r0, [sp, #4]
	ldr	r0, .L19
	bl	GARLIC_printf
	mov	r3, #0
	str	r3, [sp, #12]
	b	.L15
.L18:
	mov	r3, #0
	str	r3, [sp, #8]
	b	.L16
.L17:
	ldr	r2, [sp, #12]
	mov	r3, r2
	lsl	r3, r3, #1
	add	r3, r3, r2
	lsl	r3, r3, #1
	mov	r2, r3
	ldr	r3, [sp, #4]
	add	r2, r3, r2
	ldr	r3, [sp, #8]
	add	r3, r2, r3
	ldrb	r3, [r3]	@ zero_extendqisi2
	mov	r1, r3
	ldr	r0, .L19+4
	bl	GARLIC_printf
	ldr	r3, [sp, #8]
	add	r3, r3, #1
	str	r3, [sp, #8]
.L16:
	ldr	r3, [sp, #8]
	cmp	r3, #5
	ble	.L17
	ldr	r0, .L19+8
	bl	GARLIC_printf
	ldr	r3, [sp, #12]
	add	r3, r3, #1
	str	r3, [sp, #12]
.L15:
	ldr	r3, [sp, #12]
	cmp	r3, #5
	ble	.L18
	nop
	add	sp, sp, #20
	@ sp needed
	ldr	pc, [sp], #4
.L20:
	.align	2
.L19:
	.word	.LC1
	.word	.LC2
	.word	.LC3
	.size	imprimir_matriu_adfgvx, .-imprimir_matriu_adfgvx
	.section	.rodata
	.align	2
.LC4:
	.ascii	"ADFGVX\000"
	.text
	.align	2
	.syntax unified
	.arm
	.fpu softvfp
	.type	adfgvx_encrypt, %function
adfgvx_encrypt:
	@ args = 0, pretend = 0, frame = 48
	@ frame_needed = 0, uses_anonymous_args = 0
	str	lr, [sp, #-4]!
	sub	sp, sp, #52
	str	r0, [sp, #12]
	str	r1, [sp, #8]
	str	r2, [sp, #4]
	str	r3, [sp]
	ldr	r2, .L34
	add	r3, sp, #16
	ldm	r2, {r0, r1}
	str	r0, [r3]
	add	r3, r3, #4
	strh	r1, [r3]	@ movhi
	add	r3, r3, #2
	lsr	r2, r1, #16
	strb	r2, [r3]
	ldr	r0, [sp, #8]
	bl	str_len
	str	r0, [sp, #24]
	mov	r3, #0
	str	r3, [sp, #44]
	mov	r3, #0
	str	r3, [sp, #40]
	b	.L22
.L32:
	ldr	r3, [sp, #40]
	ldr	r2, [sp, #8]
	add	r3, r2, r3
	ldrb	r3, [r3]
	strb	r3, [sp, #23]
	mov	r3, #0
	str	r3, [sp, #36]
	mov	r3, #0
	str	r3, [sp, #32]
	b	.L23
.L31:
	mov	r3, #0
	str	r3, [sp, #28]
	b	.L24
.L29:
	ldr	r2, [sp, #32]
	mov	r3, r2
	lsl	r3, r3, #1
	add	r3, r3, r2
	lsl	r3, r3, #1
	mov	r2, r3
	ldr	r3, [sp, #12]
	add	r2, r3, r2
	ldr	r3, [sp, #28]
	add	r3, r2, r3
	ldrb	r3, [r3]	@ zero_extendqisi2
	ldrb	r2, [sp, #23]	@ zero_extendqisi2
	cmp	r2, r3
	bne	.L25
	ldr	r3, [sp, #44]
	add	r2, r3, #2
	ldr	r3, [sp]
	cmp	r2, r3
	blt	.L26
	ldr	r3, [sp, #44]
	ldr	r2, [sp, #4]
	add	r3, r2, r3
	mov	r2, #0
	strb	r2, [r3]
	b	.L21
.L26:
	ldr	r3, [sp, #44]
	add	r2, r3, #1
	str	r2, [sp, #44]
	mov	r2, r3
	ldr	r3, [sp, #4]
	add	r3, r3, r2
	add	r1, sp, #16
	ldr	r2, [sp, #32]
	add	r2, r1, r2
	ldrb	r2, [r2]	@ zero_extendqisi2
	strb	r2, [r3]
	ldr	r3, [sp, #44]
	add	r2, r3, #1
	str	r2, [sp, #44]
	mov	r2, r3
	ldr	r3, [sp, #4]
	add	r3, r3, r2
	add	r1, sp, #16
	ldr	r2, [sp, #28]
	add	r2, r1, r2
	ldrb	r2, [r2]	@ zero_extendqisi2
	strb	r2, [r3]
	mov	r3, #1
	str	r3, [sp, #36]
	b	.L28
.L25:
	ldr	r3, [sp, #28]
	add	r3, r3, #1
	str	r3, [sp, #28]
.L24:
	ldr	r3, [sp, #28]
	cmp	r3, #5
	ble	.L29
.L28:
	ldr	r3, [sp, #32]
	add	r3, r3, #1
	str	r3, [sp, #32]
.L23:
	ldr	r3, [sp, #32]
	cmp	r3, #5
	bgt	.L30
	ldr	r3, [sp, #36]
	cmp	r3, #0
	beq	.L31
.L30:
	ldr	r3, [sp, #40]
	add	r3, r3, #1
	str	r3, [sp, #40]
.L22:
	ldr	r2, [sp, #40]
	ldr	r3, [sp, #24]
	cmp	r2, r3
	blt	.L32
	ldr	r3, [sp, #44]
	ldr	r2, [sp, #4]
	add	r3, r2, r3
	mov	r2, #0
	strb	r2, [r3]
.L21:
	add	sp, sp, #52
	@ sp needed
	ldr	pc, [sp], #4
.L35:
	.align	2
.L34:
	.word	.LC4
	.size	adfgvx_encrypt, .-adfgvx_encrypt
	.section	.rodata
	.align	2
.LC5:
	.ascii	"-- Programa USR1 -- PID(%d) arg(%d)\012\000"
	.align	2
.LC7:
	.ascii	"Missatge original 1: %s\012\000"
	.align	2
.LC8:
	.ascii	"Text xifrat 1: %s\012\000"
	.align	2
.LC10:
	.ascii	"Missatge original 2: %s\012\000"
	.align	2
.LC11:
	.ascii	"Text xifrat 2: %s\012\000"
	.align	2
.LC6:
	.ascii	"HELLO\000"
	.align	2
.LC9:
	.ascii	"ESTRUCTURA DE SISTEMES OPERATIUS\000"
	.text
	.align	2
	.global	_start
	.syntax unified
	.arm
	.fpu softvfp
	.type	_start, %function
_start:
	@ args = 0, pretend = 0, frame = 472
	@ frame_needed = 0, uses_anonymous_args = 0
	str	lr, [sp, #-4]!
	sub	sp, sp, #476
	str	r0, [sp, #4]
	ldr	r3, [sp, #4]
	cmp	r3, #0
	bge	.L37
	mov	r3, #0
	str	r3, [sp, #4]
.L37:
	ldr	r3, [sp, #4]
	cmp	r3, #3
	ble	.L38
	mov	r3, #3
	str	r3, [sp, #4]
.L38:
	bl	GARLIC_pid
	mov	r1, r0
	ldr	r3, [sp, #4]
	mov	r2, r3
	ldr	r0, .L40
	bl	GARLIC_printf
	add	r3, sp, #436
	mov	r0, r3
	bl	generar_matriu_adfgvx
	add	r3, sp, #436
	mov	r0, r3
	bl	imprimir_matriu_adfgvx
	ldr	r2, .L40+4
	add	r3, sp, #428
	ldm	r2, {r0, r1}
	str	r0, [r3]
	add	r3, r3, #4
	strh	r1, [r3]	@ movhi
	add	r2, sp, #300
	add	r1, sp, #428
	add	r0, sp, #436
	mov	r3, #128
	bl	adfgvx_encrypt
	add	r3, sp, #428
	mov	r1, r3
	ldr	r0, .L40+8
	bl	GARLIC_printf
	add	r3, sp, #300
	mov	r1, r3
	ldr	r0, .L40+12
	bl	GARLIC_printf
	ldr	r3, .L40+16
	add	ip, sp, #264
	mov	lr, r3
	ldmia	lr!, {r0, r1, r2, r3}
	stmia	ip!, {r0, r1, r2, r3}
	ldmia	lr!, {r0, r1, r2, r3}
	stmia	ip!, {r0, r1, r2, r3}
	ldr	r3, [lr]
	strb	r3, [ip]
	add	r2, sp, #8
	add	r1, sp, #264
	add	r0, sp, #436
	mov	r3, #256
	bl	adfgvx_encrypt
	add	r3, sp, #264
	mov	r1, r3
	ldr	r0, .L40+20
	bl	GARLIC_printf
	add	r3, sp, #8
	mov	r1, r3
	ldr	r0, .L40+24
	bl	GARLIC_printf
	mov	r3, #0
	mov	r0, r3
	add	sp, sp, #476
	@ sp needed
	ldr	pc, [sp], #4
.L41:
	.align	2
.L40:
	.word	.LC5
	.word	.LC6
	.word	.LC7
	.word	.LC8
	.word	.LC9
	.word	.LC10
	.word	.LC11
	.size	_start, .-_start
	.ident	"GCC: (devkitARM release 46) 6.3.0"
