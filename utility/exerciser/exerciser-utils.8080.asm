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
; compile with RetroAssembler
; Tab Size = 10
;
	.target	"8080"

; display low nibble in a
.function phex1()
	pushRegs()
	Text_PrintHex1()
	popRegs()
.endfunction

; display byte in a
.function phex2()
	pushRegs()
	Text_PrintHex2()
	popRegs()
.endfunction

; display word in HL
.function phex4()
	pushRegs()
	Text_PrintHex4()
	popRegs()
.endfunction

; display hex
; display the big-endian 32-bit value pointed to by hl
.function phex8()
	pushRegs()
	Text_PrintHex8()
	popRegs()
.endfunction

.macro	DebugTrace(msg, data=' ')
	WriteTrace()
.if	(msg == 1)  && (DEBUG >= 1)
 	; Print Instruction and state
	pushRegs()
	C_WRITESTR(crlf)
	lxi	h,iut
	mvi	b,IUT_SIZE
	Text_PrintHexStr()
    	C_WRITE(' ')
    	mvi	b,STATESIZE
    	lxi	h,msbt
	Text_PrintHexStr()
	popRegs()
.endif
.if	(msg == 2)  && (DEBUG >= 2)
	; Print CRC and state
	pushRegs()
	C_WRITESTR(crlf)
	lxi	h,crcval
	phex8()
	C_WRITE(' ')
	lxi	h,msat
	mvi	b,STATESIZE
	Text_PrintHexStr()
	popRegs()
.endif
.if	(msg == 3) && (DEBUG >= 3)
	pushRegs()
	C_WRITESTR(crlf)
	lxi	h,counter
	mvi	b,MASKSIZE
	Text_PrintHexStr()
	C_WRITESTR(crlf)
	lxi	h,counter+MASKSIZE
	mvi	b,MASKSIZE
	Text_PrintHexStr()
	popRegs()
.endif
.if	(msg == 4) && (DEBUG >= 4)
	pushRegs()
	C_WRITESTR(crlf)
	lxi	h,shifter
	mvi	b,MASKSIZE
	Text_PrintHexStr()
	C_WRITESTR(crlf)
	lxi	h,shifter+MASKSIZE
	mvi	b,MASKSIZE
	Text_PrintHexStr()
	popRegs()
.endif
.if	(msg == 6) && (DEBUG >= 6)
	pushRegs()
	C_WRITESTR(crlf)
	C_WRITE(data)
	lxi	h,msat
	mvi	b,STATESIZE
	Text_PrintHexStr()
	popRegs()
.endif
.if	(msg == 7) && (DEBUG >= 7)
	pushRegs()
	lhld	tstcnt
	Text_PrintHex4()
	popRegs()
.endif
.endMacro
