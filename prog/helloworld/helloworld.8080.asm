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
	.format	"bin"
	.setting "OmitUnusedFunctions", true

DEBUG	.var	0	; 0 -> OFF
APP_TYPE	.var	1	; CP/M app
APP_MODE	.var	1	; Simple text app

.include "../../lib/libApp.8080.asm"

.code
	.org	PROGSTART
Main	App_Init()
	Text_Home()
	Text_Print(Message)
	App_Exit(1)

.segment "Resources"
Message	Text_MSG("Hello world!\r\n")
