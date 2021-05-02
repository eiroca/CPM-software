; Copyright (C) 2020-2021 Enrico Croce - BSD 3-Clause License
; Based on ZX0 z80 decoder by Einar Saukas - Copyright (c) 2021, Einar Saukas - All rights reserved.
; Based on ZX0 8080 decoder by Ivan Gorodetsky
;
; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions are met:
;
; 1. Redistributions of source code must retain the above copyright notice, this
;   list of conditions and the following disclaimer.
;
; 2. Redistributions in binary form must reproduce the above copyright notice,
;   this list of conditions and the following disclaimer in the documentation
;   and/or other materials provided with the distribution.
;
; 3. Neither the name of the copyright holder nor the names of its
;   contributors may be used to endorse or promote products derived from
;   this software without specific prior written permission.
;
; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
; DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
; FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
; SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
; CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
; OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
; OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.;
;
; -----------------------------------------------------------------------------
;
; compile with RetroAssembler
; Tab Size = 10
;
	.target	"8080"

.lib

; forward decompressing
;  HL: source address (compressed data)
;  BC: destination address (decompressing)
.function dzx0()
        	lxi	D, $FFFF
	push	D
	inx	D
	mvi	A, $80
@literals
	call	@elias
	call	@ldir
	add	A
	jc	@new_offset
	call	@elias
@copy
	xthl
	push	H
	dad	B
	call	@ldir
	pop	H
	xthl
	add	A
	jnc	@literals
@new_offset
	call	@elias
	mov	D, A
	pop	PSW
	xra	A
	sub	E
	rz
	mov	E, D
	mov	D, A
	mov	A, E
	push	B
	mov	B, A
	mov	A, D
	rar
	mov	D, A
	mov	A, M
	rar
	mov	E, A
	mov	A, B
	pop	B
	inx	H
	push	D
	lxi	D, 1
	cnc	@elias_backtrack
	inx	D
	jmp	@copy
@elias
	inr	E
@elias_loop
	add	A
	jnz	@elias_skip
	mov	A, M
	inx	H
	ral
@elias_skip
	rc
@elias_backtrack
	xchg
	dad	H
	xchg
	add	A
	jnc	@elias_loop
	inr	E
	jmp	@elias_loop
@ldir
	push	PSW
@ldirloop
	mov	A, M
	stax	B
	inx	H
	inx	B
	dcx	D
	mov	A, D
	ora	E
	jnz	@ldirloop
	pop	PSW
.endfunction

; backward decompressing
;  HL: last source address (compressed data)
;  BC: last destination address (decompressing)
.function dzx0_back()
	lxi	D,1
	push	D
	dcr	E
	mvi	A, $80
@literals
	call	@elias
	call	@ldir
	add	A
	jc	@new_offset
	call	@elias
@copy
	xthl
	push	H
	dad	B
	call	@ldir
	pop	H
	xthl
	add	A
	jnc	@literals
@new_offset
	call	@elias
	inx	SP
	inx	SP
	dcr	D
	rz
	dcr	E
	mov	D, E
	push	B
	mov	B, A
	mov	A, D
	rar
	mov	D, A
	mov	A, M
	rar
	mov	E, A
	mov	A, B
	pop	B
	dcx	H
	inx	D
	push	D
	lxi	D, 1
	cc	@elias_backtrack
	inx	D
	jmp	@copy
@elias
	inr	E
@elias_loop
	add	A
	jnz	@elias_skip
	mov	A, M
	dcx	H
	ral
@elias_skip
	rnc
@elias_backtrack
	xchg
	dad	H
	xchg
	add	A
	jnc	@elias_loop
	inr	E
	jmp	@elias_loop
@ldir
	push	PSW
@ldirloop
	mov	A, M
	stax	B
	dcx	H
	dcx	B
	dcx	D
	mov	A, D
	ora	E
	jnz	@ldirloop
	pop	PSW
.endfunction
