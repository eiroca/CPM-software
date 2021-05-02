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

IAC	.equ	$E3
VRAMPTR	.equ	$02A5

OUTC	.equ	$DD60
CRLF	.equ	$DD5E
FGETC	.equ	$D6BB

R0PRINTC	.equ 	$D695
R0PRINT	.equ 	$DB32
R0IAC2HEX .equ	$C653

VRAM_END	.equ	$BFFF

.lib
	IS_DAI = 1

; Exit to BASIC
.macro DAI_mode(md=$FF)
.if md == $00
	md = $FF
.endif
	mvi	A, md
	rst	5
	.byte	$18
.endmacro

.macro DAI_printC(ch)
	mvi	A, ch
	call	R0PRINTC
.endmacro

.macro DAI_print(msgAddr)
	lxi	H, msgAddr
	call	R0PRINT
.endmacro

.macro DAI_printMSG_H()
	call	R0PRINT
.endmacro

.macro DAI_getC(allowBreak=1)
@KeyLoop	call	FGETC
	jz	@KeyLoop
.if allowBreak == 1
	jnc	@Exit
	; Break pressed, so move 0 to A
	mvi	A,$00
.endif
@Exit
.endmacro

.macro DAI_mathRegToIAC()
	rst	4
	.byte	$12
.endmacro

.macro DAI_printHEXinA()
	mov	D, A
	xra	A
	mov	B, A
	mov	C, A
	DAI_mathRegToIAC()
	call	R0IAC2HEX
	lxi	H, IAC
	call	R0PRINT
.endmacro

.macro DAI_printHEXinHL()
	mov	D, L
	mov	C, H
	xra	A
	mov	B, A
	DAI_mathRegToIAC()
	call	R0IAC2HEX
	lxi	H, IAC
	call	R0PRINT
.endmacro
