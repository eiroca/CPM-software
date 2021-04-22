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

; Input  A in BCD format
; Output A in binary format
; destroys BC
; no checks if BCD is valid
.function bcd2bin()
	mov	b, a
	ani	$F0	; tens bcd part
	jz	@less10
	; convert to tens and keep it in "c"
	SwapNibble()
	mov	c, a
	mov	a, b
	ani	$0F	; units
	mvi	b, 10	; do tens x 10
@loop	add	b
	dcr	c
	jnz	@loop
	ret
@less10	mov	a, b
.endfunction
