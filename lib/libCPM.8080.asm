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

IS_CPM	.equ	1

WBOOT	.equ	$0000	; RE-ENTRY TO CP/M WARM BOOT
BDOS	.equ	$0005	; BDOS ENTRY TO CP/M

; Calls a BDOS function
.macro C_BDOS(func)
	mvi	C, func
	call	BDOS
.endmacro

; BDOS print char
.macro C_WRITE(char)
	mvi	C, 2
	mvi	E, char
	call	BDOS
.endmacro

.macro C_WRITE_E()
	mvi	C, 2
	call	BDOS
.endmacro

.macro C_WRITE_A()
	mvi	C, 2
	mov	E, A
	call	BDOS
.endmacro

; BDOS print string (Terminated with $)
.macro C_WRITESTR(addr)
	mvi	C, 9
	lxi	D, addr
	call	BDOS
.endmacro

.macro C_WRITESTR_D()
	mvi	C, 9
	call	BDOS
.endmacro

.macro C_WRITESTR_H()
	xchg
	mvi	C, 9
	call	BDOS
.endmacro

; Exit to CP/M (Warm Boot)
.macro EXIT()
	jmp	WBOOT
.endmacro

.macro bdos_safe(CllNum, saveD=0)
	push	psw
	push	b
	.if saveD !=0
	push	d
	.endif
	push	h
	mvi	C, CllNum
	call	$0005
	pop	h
	.if saveD !=0
	pop	d
	.endif
	pop	b
	pop	psw
.endmacro
