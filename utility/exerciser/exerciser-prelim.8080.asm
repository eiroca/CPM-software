;******************************************************************************
;
; prelim.z80 - Preliminary Z80 tests - Copyright (C) 1994  Frank D. Cringle
; zexlax.z80 - Z80 instruction set exerciser - Copyright (C) 1994  Frank D. Cringle
; 8080 CPU support - Copyright (C) Ian Bartholomew
; Revision and improvements - Copyright (C) Enrico Croce
;
; This program is free software; you can redistribute it and/or
; modify it under the terms of the GNU General Public License
; as published by the Free Software Foundation; either version 2
; of the License, or (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
;
;******************************************************************************
;
; Preliminary checks. To test the minimum instructions needed to proceed
; Errors are 'reported' by "jmp TestError".
;
;******************************************************************************
;
; compile with RetroAssembler
; Tab Size = 10
;
	.target	"8080"

.data
Var1	.var	0
regs1	.loop	8
	.byte 2*(Var1+1)
	Var1 = Var1 + 1
	.endloop
regs2	.byte	$00, $00, $00, $00, $00, $00, $00, $00
hlval	.word	$3CA5
stksav	.ds	2

.lib
.macro	TestCond_C()
	lxi	h,1
	push	h
	pop	psw
	cc	@lab1
	jmp	TestError
@lab1	pop	h
	lxi	h,$D7 ^ 1
	push	h
	pop	psw
	cnc	@lab2
	jmp	TestError
@lab2	pop	h
	lxi	h,@lab3
	push	h
	lxi	h,1
	push	h
	pop	psw
	rc
	call	TestError
@lab3	lxi	h,@lab4
	push	h
	lxi	h,$D7 ^ 1
	push	h
	pop	psw
	rnc
	call	TestError
@lab4	lxi	h,1
	push	h
	pop	psw
	jc	@lab5
	call	TestError
@lab5	lxi	h,$D7 ^ 1
	push	h
	pop	psw
	jnc	@lab6
	call	TestError
@lab6:
.endmacro

.macro	TestCond_P()
	lxi	h,4
	push	h
	pop	psw
	cpe	@lab1
	jmp	TestError
@lab1	pop	h
	lxi	h,$D7 ^ 4
	push	h
	pop	psw
	cpo	@lab2
	jmp	TestError
@lab2	pop	h
	lxi	h,@lab3
	push	h
	lxi	h,4
	push	h
	pop	psw
	rpe
	call	TestError
@lab3	lxi	h,@lab4
	push	h
	lxi	h,$D7 ^ 4
	push	h
	pop	psw
	rpo
	call	TestError
@lab4	lxi	h,4
	push	h
	pop	psw
	jpe	@lab5
	call	TestError
@lab5	lxi	h,$D7 ^ 4
	push	h
	pop	psw
	jpo	@lab6
	call	TestError
@lab6
.endmacro

.macro	TestCond_Z()
	lxi	h,$40
	push	h
	pop	psw
	cz	@lab1
	jmp	TestError
@lab1	pop	h
	lxi	h,$D7 ^ $40
	push	h
	pop	psw
	cnz	@lab2
	jmp	TestError
@lab2	pop	h
	lxi	h,@lab3
	push	h
	lxi	h,$40
	push	h
	pop	psw
	rz
	call	TestError
@lab3	lxi	h,@lab4
	push	h
	lxi	h,$D7 ^ $40
	push	h
	pop	psw
	rnz
	call	TestError
@lab4	lxi	h,$40
	push	h
	pop	psw
	jz	@lab5
	call	TestError
@lab5	lxi	h,$D7 ^ $40
	push	h
	pop	psw
	jnz	@lab6
	call	TestError
@lab6
.endmacro

.macro	TestCond_S()
	lxi	h,$80
	push	h
	pop	psw
	cm	@lab1
	jmp	TestError
@lab1	pop	h
	lxi	h,$D7 ^ $80
	push	h
	pop	psw
	cp	@lab2
	jmp	TestError
@lab2	pop	h
	lxi	h,@lab3
	push	h
	lxi	h,$80
	push	h
	pop	psw
	rm
	call	TestError
@lab3	lxi	h,@lab4
	push	h
	lxi	h,$D7 ^ $80
	push	h
	pop	psw
	rp
	call	TestError
@lab4	lxi	h,$80
	push	h
	pop	psw
	jm	@lab5
	call	TestError
@lab5	lxi	h,$D7 ^ $80
	push	h
	pop	psw
	jp	@lab6
	call	TestError
@lab6
.endmacro

.function PreChecks()
Test_P00	WriteTrace()
	mvi	a,$01		; test simple compares and z/nz jumps
	cpi	$02
	jz	PreTestKO
	cpi	$01
	jnz	PreTestKO
Test_P01	call	@lab2		; does a simple call work?
	@lab1	jmp	PreTestKO		; fail
@lab2	pop	h		; check return address
	mov	a,h
	cpi	>@lab1
	jz	@lab3
	jmp	PreTestKO
@lab3	mov	a,l
	cpi	<@lab1
	jz	Test_P02
	jmp	PreTestKO

; test presence and uniqueness of all machine registers (except ir)
Test_P02	WriteTrace()
	_HLSP()
	shld	stksav
	lxi	sp,regs1
	pop	psw
	pop	b
	pop	d
	pop	h
	lxi	sp,regs2+8
	push	h
	push	d
	push	b
	push	psw

	lhld	stksav
	sphl

	Var1 = 0
	.loop	8
	lda	regs2+Var1
	cpi 	2*(Var1+1)
	jnz	PreTestKO
	Var1 = Var1 + 1
	.endloop

; test access to memory via (hl)
Test_P03	WriteTrace()
	lxi	h,hlval
	mov	a,m
	cpi	$A5
	jnz	PreTestKO
	lxi	h,hlval+1
	mov	a,m
	cpi	$3C
	jnz	PreTestKO

; test unconditional return
Test_P04	WriteTrace()
	lxi	h,Test_P05
	push	h
	ret
	jmp	PreTestKO

; test instructions needed for hex output
Test_P05	WriteTrace()
	mvi	a,$FF
	ani	$0F
	cpi	$0F
	jnz	PreTestKO
	mvi	a,$5A
	ani	$0F
	cpi	$0A
	jnz	PreTestKO
	rrc
	cpi	$05
	jnz	PreTestKO
	rrc
	cpi	$82
	jnz	PreTestKO
	rrc
	cpi	$41
	jnz	PreTestKO
	rrc
	cpi	$A0
	jnz	PreTestKO
	lxi	h,$1234
	push	h
	pop	b
	mov	a,b
	cpi	$12
	jnz	PreTestKO
	mov	a,c
	cpi	$34
	jnz	PreTestKO

; from now on we can report errors by displaying an address

; test conditional call, ret, jp, jr
Test_P06	WriteTrace()
	TestCond_C()
	TestCond_P()
	TestCond_Z()
	TestCond_S()

; test indirect jumps
Test_P07	WriteTrace()
	lxi	h,Test_P08
	pchl
	call	TestError

; djnz (and (partially) inc a, inc hl)
Test_P08	WriteTrace()
	mvi	a,$a5
	mvi	b,4
@lab8	rrc
	dcr	b
	jnz	@lab8
	cpi	$5A
	cnz	TestError
	mvi	b,16
@lab9	inr	a
	dcr	b
	jnz	@lab9
	cpi	$6A
	cnz	TestError
	mvi	b,0
	lxi	h,0
@lab10	inx	h
	dcr	b
	jnz	@lab10
	mov	a,h
	cpi	1
	cnz	TestError
	mov	a,l
	cpi	0
	cnz	TestError

PreChkEnd	WriteTrace()

.endfunction
