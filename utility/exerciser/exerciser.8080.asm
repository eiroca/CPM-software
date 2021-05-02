;******************************************************************************
;
; prelim.z80 - Preliminary Z80 tests - Copyright (C) 1994 Frank D. Cringle
; zexlax.z80 - Z80 instruction set exerciser - Copyright (C) 1994 Frank D. Cringle
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
;
; Run a diagnostic test on an 8080/8085 CPU (emulator)
;
; It uses calls to BDOS (C_WRITE and C_WRITESTR) to report progess and status
; and this calls are assumed intercepted by the emulator (always work).
;
; These exerciser is split in two
; 1. Preliminary check. To test the minimum instructions needed to proceed
; 2. A full test list is executed using
;
; Initially errors are 'reported' by halting.
; Later errors are reported by outputting an address
;
;******************************************************************************
;
; compile with RetroAssembler
; Tab Size = 10
;
.target	"8080"
.format	"bin"
.setting "OmitUnusedFunctions", true

.include "../../lib/libConst.8080.asm"
.include "../../lib/CPM/libCPM.8080.asm"
.include "../../lib/CPM/libCPMext.8080.asm"
.include "../../lib/libApp.8080.asm"

.include "../../lib/libCRC.8080.asm"

.include "exerciser-utils.8080.asm"
.include "exerciser-prelim.8080.asm"
.include "exerciser-tester.8080.asm"
.include "testlist/CPM-testlist.8080.asm"

.code
	.org	PROGSTART

; Run Exerciser
Main	App_Init(30)
	Text_Home()
	Text_Print(WelcmMsg1)
	Text_Print(WelcmMsg2)
Phase1	WriteTrace()
	PreChecks()
	Text_Print(PreOKMsg)
Phase2	WriteTrace()
	TestSuite()
	lda	TestOKs
	ora	A
	jz	@AllOk
	Text_Print(TestKOMsg)
	jmp	@Exit
@AllOk	Text_Print(TestOKMsg)
@Exit	App_Exit(0)

; Report prechecks failure to the console
PreTestKO	Text_Print(PreKOMsg)
	App_Exit(1)

; Report testsuite failure to the console
TestError	Text_Print(ErrorMsg)
	xthl		; Recover Caller Address
	Text_PrintHex4()
	Text_NL()
	App_Exit(1)

.segment "Resources"
WelcmMsg1	Text_MSG("8080/8085 instruction set exerciser (2021)")
WelcmMsg2	Text_MSG("This program is free software under GNU AGPL v3")
ErrorMsg	Text_STR("Test Error @")
PreKOMsg	Text_MSG("Preliminary tests: failed!")
PreOKMsg	Text_MSG("Preliminary tests: OK")
TestOKMsg	Text_MSG("Test suite passed successfully!")
TestKOMsg	Text_MSG("Test suite failed!             ")

; Configuration
.code
.org	PROGSTART + LOADER_SIZE

CTestRun	.byte	$00	; test to run ($00= all)
CBrkOnErr	.byte	$00	; break on errors ($00= no, $FF=yes)

; MUST BE in a well knwon orign segment (otherwise CRC in testsuite fail)
; machine state before test
msbt	.ds	2	; memop
	.ds	6	; HL,DE,BC
flgsbt	.ds	1	; F
	.ds	1	; A
spbt	.ds	2	; stack pointer

; machine state after test
msat	.ds	2	; memop
msatSt	.ds	6	; HL,DE,BC
flgsat	.ds	1	; F
	.ds	1	; A
spat	.ds	2	; stack pointer

StkMrkBT	.equ	msbt+2
StkMrkAT	.equ	msat+STATESIZE-2
