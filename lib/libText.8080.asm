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
.if APP_TYPE == 1
	.include "libText_CPM.8080.asm"
.endif

; Print 2 HEX digits in A
.function Text_PrintHex2()
	push	PSW
	rrc
	rrc
	rrc
	rrc
	Text_PrintHex1()
	pop	PSW
	Text_PrintHex1()
@Exit	.endfunction

; Print 4 HEX digits in HL
.function Text_PrintHex4()
	push	H
	mov	A, H
	Text_PrintHex2()
	pop	H
	mov	A, L
	Text_PrintHex2()
@Exit	.endfunction

; display hex
; display the big-endian 32-bit value pointed to by hl
.function Text_PrintHex8()
	mvi	B, 4
@Loop	mov	A, M
	push	H
	push	B
	Text_PrintHex2()
	pop	B
	pop	H
	inx	H
	dcr	B
	jnz	@Loop
.endfunction

; display hex string (pointer in hl, byte count in b)
.function Text_PrintHexStr()
@Loop	mov	A, M
	push	H
	push	B
	Text_PrintHex2()
	pop	B
	pop	H
	inx	H
	dcr	B
	jnz	@Loop
.endfunction
