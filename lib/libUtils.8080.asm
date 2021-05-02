; Copyright (C) 2020-2021 Enrico Croce - AGPL >= 3.0
;
; This program is free software: you can redistribute it and/or modify it under the terms of the
; GNU Affero General Public License as published by the Free Software Foundation, either version 3
; of the License, or (at your option) any later version.
;
; This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
; even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
; Affero General Public License for more details.
;
; You should have received a copy of the GNU Affero General Public License along with this program.
; If not, see <http://www.gnu.org/licenses/>.
;
;
; compile with RetroAssembler
; Tab Size = 10

	.target	"8080"

.lib

; Push all the registers
.macro pushRegs()
	push	PSW
	push	B
	push	D
	push	H
.endmacro

; Pull all the registers
.macro popRegs()
	pop	H
	pop	D
	pop	B
	pop	PSW
.endmacro

; HL <- SP
.macro _HLSP()
	lxi	H, 0
	dad	SP
.endmacro

; HL <- BC
.macro _HLBC()
	mov       H, B
	mov	L, C
.endmacro
; HL <- DE
.macro _HLDE()
	mov       H, D
	mov	L, E
.endmacro

; Z80 LDI emulation (but destroy A)
; A <- (HL)
; (DE) <- A
; DE <- DE + 1
; HL <- HL + 1
; BC <- BC - 1
.macro _LDI()
	mov	A, M
	stax	D
	inx	H
	inx	D
	dcx	B
.endmacro

; Repeats LDI until BC=0. Note that if BC=0 before this instruction is called, it will loop around until BC=0 again.
; Destroys A (A <- 0)
.macro _LDIR()
@Loop1	_LDI()
	mov	A, B
	ora	C
	jnz	@Loop1
.endmacro

; Z80 LDI emulation (but destroy A)
; A <- (HL)
; (DE) <- A
; DE <- DE - 1
; HL <- HL - 1
; BC <- BC - 1
.macro _LDD()
	mov	A, M
	stax	D
	dcx	H
	dcx	D
	dcx	B
.endmacro

; Repeats LDI until BC=0. Note that if BC=0 before this instruction is called, it will loop around until BC=0 again.
; Destroys A (A <- 0)
.macro _LDDR()
@Loop1	_LDD()
	mov	A, B
	ora	C
	jnz	@Loop1
.endmacro

; HL <- (HL)
; destroys A (A<-L)
.macro _HL_ind()
	mov	A, M
	inx	H
	mov	H, M
	mov	L, A
.endmacro

; HL <- (addr)+off
; destroys D (D <-off)
.macro _HL_ptr(addr, off)
	lhld	addr
	lxi	D, off
	dad	D
.endmacro

; Swap the nibble in A  $1F -> $F1
.macro SwapNibble()
	rlc
	rlc
	rlc
	rlc
.endmacro

; Compare HL and DE
; Destroys A
.macro cmp_DH()
	mov	A, D
	xra	H
	jnz	@Exit
	mov	A, E
	xra	L
@Exit
.endmacro

; Check if _is8085;
; Z=0 -> 8085 Z=1 -> 8080
.macro is8085()
	mvi	A,2
	ana	A	; V=0 for 8085
	push	PSW	; V=1 for 8080, unchanged for 8085
	pop	B
	ana	C
.endmacro

; fill memory at hl, bc bytes with value in E
.function fillMem()
	pushRegs()
	mov	m, E
	mov	d, h
	mov	e, l
	inx	d
	dcx	b
@Loop	mov	a, m
	stax	d
	inx	h
	inx	d
	dcx	b
	mov	a, b
	ora	c
	jnz	@Loop
	popRegs()
.endfunction

; clear memory at hl, bc bytes
.function clrMem()
	pushRegs()
	mvi	E, 0
@Loop	mov	M, E
	inx	h
	dcx	b
	mov	a, b
	ora	c
	jnz	@Loop
	popRegs()
.endfunction

; clear dword at HL
.function clrDWord()
	push	PSW
	push	H
	xra	A
	mov	M, A
	inx	H
	mov	M, A
	inx	H
	mov	M, A
	inx	H
	mov	M, A
	pop	H
	pop	PSW
.endfunction

; fill dword at HL with A
.function fillDWord()
	push	H
	mov	M, A
	inx	H
	mov	M, A
	inx	H
	mov	M, A
	inx	H
	mov	M, A
	pop	H
.endfunction
