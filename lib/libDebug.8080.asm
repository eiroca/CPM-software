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

.if DEBUG > 0
.segment "Resources"
CllEntMsg	.ascii "Trace @$"
CllExtMsg	.ascii "Exiting call"
.endif

.lib

.macro WriteTrace()
.if 0 || (DEBUG >= 9) && 1
	pushRegs()
	Text_Print(CllEntMsg)
	call @me
@me	pop  H
	lxi  B, $FFF1	; -15
	dad  B
	Text_PrintHex4()
	Text_NL()
	popRegs()
.endif
.endmacro

.macro WriteStatus()
.if 0 || (DEBUG >= 5) && 1
	pushRegs()
	C_WRITE('A')
	C_WRITE(' ')
	popRegs()
	pushRegs()
	push	PSW
	Text_PrintHex2()
	C_WRITE(' ')
	pop	B
	mov	A,C
	Text_PrintHex2()
	C_WRITE(' ')
	C_WRITE('B')
	C_WRITE(' ')
	popRegs()
	pushRegs()
	mov	H,B
	mov	L,C
	Text_PrintHex4()
	C_WRITE(' ')
	C_WRITE('D')
	C_WRITE(' ')
	popRegs()
	pushRegs()
	xchg
	Text_PrintHex4()
	C_WRITE(' ')
	C_WRITE('H')
	C_WRITE(' ')
	popRegs()
	pushRegs()
	Text_PrintHex4()
	Text_NL()
	popRegs()
.endif
.endMacro
