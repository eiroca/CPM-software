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

	.include "libUtils.8080.asm"
	.include "libDebug.8080.asm"

	.if APP_TYPE == 1
		.include "libCPM.8080.asm"
	.endif

	.include "libText.8080.asm"

.lib

PROGSTART	.var	$0200	;
.if IS_CPM == 1
	PROGSTART = $0100	; COM start Address
.endif

.macro App_Init()
	.if APP_MODE == 1
	Text_Init()
	.endif
.endmacro

.macro App_Exit(status = 0)
	mvi	A, status
	EXIT()
.endmacro
