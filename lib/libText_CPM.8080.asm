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

.macro Text_MSG(message)
	.ascii message
	.ascii "$"
.endmacro

.macro Text_Init()
.endmacro

.macro Text_Home()
	mvi	C, 2
	mvi	E, 12
	call	BDOS
.endmacro

.macro Text_NL()
	mvi	C, 2
	mvi	E, 13
	call	BDOS
	mvi	E, 10
	call	BDOS
.endmacro

.macro Text_Print(msgAddr)
	mvi	C, 9
	lxi	D, msgAddr
	call	BDOS
.endmacro

.macro Text_PrintChar(char)
	mvi	C, 2
	mvi	E, char
	call	BDOS
.endmacro

; Print 1 HEX digit in lower nible of A
.function Text_PrintHex1()
	ani	$0F
	cpi	$0A
	jm	@Lower9
	adi	'a'-'9'-1
@Lower9	adi	'0'
	C_WRITE_A()
@Exit	.endfunction
