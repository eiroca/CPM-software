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

	APP_SVREG = 1	; Save Registers on start

.macro App_HWexit(status=0)
	lxi	H, status
	ret
.endmacro

.macro App_HWinit()
.endmacro

LOADER_SIZE = 11
.macro App_HWloader(hdSz=0)
; Basic program to lauch Machine Language Part
	.byte	$09,$00,$01,$B3,$15,$00,$00,>@start,<@start,$FF	; 1 CALLM #start
	.byte 	$00
	.if hdSz>0
	.ds	hdSz, 0
	.endif
@start
.endmacro

.macro Text_MSG(message)
	.byte @end-@start
@start	.ascii message
	.ascii "\r"
@end
.endmacro

.macro Text_STR(message)
	.byte @end-@start
@start	.ascii message
@end
.endmacro

.macro Text_Init()
	DAI_mode()
.endmacro

.macro Text_Home()
	DAI_printC($0C)
.endmacro

.macro Text_NL()
	DAI_printC($0D)
.endmacro

.macro Text_Print(msgAddr)
	DAI_print(msgAddr)
.endmacro

.macro Text_PrintChar(char)
	DAI_printC(char)
.endmacro

.macro Text_PrintMSG_H()
	DAI_printMSG_H()
.endmacro

.macro Text_GetC()
	DAI_getC()
.endmacro

.function Text_PrintHex1()
	ani	$0F
	cpi	$0A
	jm	@Lower9
	adi	'A'-'9'-1
@Lower9	adi	'0'
	call	R0PRINTC
.endfunction

.function Text_PrintHex2()
	push	PSW
	rrc
	rrc
	rrc
	rrc
	Text_PrintHex1()
	pop	PSW
	Text_PrintHex1()
.endfunction

.function Text_PrintHex4()
	push	H
	mov	A, H
	Text_PrintHex2()
	pop	H
	mov	A, L
	Text_PrintHex2()
.endfunction
