;************************************************************
;                8080/8085 CPU TEST/DIAGNOSTIC
;************************************************************
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
Main	lxi 	SP, StackEnd
	App_Init()
	Text_Home()
	Text_Print(WelcomMsg)

; TEST JUMP INSTRUCTIONS AND FLAGS
JUMPTest	Text_Print(JMPTstMsg)
	.include "cpudiag_JMP.8080.asm"
	Text_Print(OKMsg)

; TEST ACCUMULATOR IMMEDIATE INSTRUCTIONS
AIMMTest	Text_Print(AIMTstMsg)
	.include "cpudiag_AIM.8080.asm"
	Text_Print(OKMsg)

; TEST CALLS AND RETURNS
CALLTest	Text_Print(CALTstMsg)
	.include "cpudiag_CAL.8080.asm"
	Text_Print(OKMsg)

; TEST "MOV","INR",AND "DCR" INSTRUCTIONS
MOVITest	Text_Print(MVITstMsg)
	.include "cpudiag_MVI.8080.asm"
	Text_Print(OKMsg)

; TEST ARITHMETIC AND LOGIC INSTRUCTIONS
AritTest	Text_Print(ALUTstMsg)
	.include "cpudiag_ALU.8080.asm"
	Text_Print(OKMsg)

Epilogue	Text_Print(CPUOKMsg)
	App_Exit(0)

; Report Failure to the console
CPUError:	Text_Print(KOMsg)
	Text_Print(ErrorMsg)
	xthl		; Recover Caller Address
	Text_PrintHex4()
	Text_NL()
	App_Exit(1)

.data
WelcomMsg	Text_MSG("8080/8085 CPU Diagnostic\r\n")
JMPTstMsg	Text_MSG("JMP tests: ")
AIMTstMsg	Text_MSG("Accumulator and immediates tests: ")
CALTstMsg	Text_MSG("Call & Rets tests: ")
MVITstMsg	Text_MSG("MOV, INR and DCR tests: ")
ALUTstMsg	Text_MSG("Arithmetic and logic tests: ")
CPUOKMsg	Text_MSG("CPU tests passed!\r\n")
ErrorMsg	Text_MSG("ERROR @")
KOMsg	Text_MSG("failed!\r\n")
OKMsg	Text_MSG("OK\r\n")

.segment "Stack"
StackStrt	.ds 256, 0	; 256 bytes of stack
StackEnd	.dw $A5A5
