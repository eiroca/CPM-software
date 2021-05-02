;************************************************************
;                8080/8085 CPU TEST/DIAGNOSTIC
;************************************************************
;
; compile with RetroAssembler
; Tab Size = 10

.target	"8080"
.format	"bin"
.setting "OmitUnusedFunctions", true

.include "../../lib/libConst.8080.asm"
.include "../../lib/CPM/libCPM.8080.asm"
.include "../../lib/CPM/libCPMext.8080.asm"
.include "../../lib/libApp.8080.asm"

.code
	.org	PROGSTART
Main	App_Init()
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
CPUError	Text_Print(KOMsg)
	Text_Print(ErrorMsg)
	xthl		; Recover Caller Address
	Text_PrintHex4()
	Text_NL()
	App_Exit(1)

.data
WelcomMsg	Text_MSG("8080/8085 CPU Diagnostic")
JMPTstMsg	Text_STR("JMP tests: ")
AIMTstMsg	Text_STR("Accumulator and immediates tests: ")
CALTstMsg	Text_STR("Call and Rets tests: ")
MVITstMsg	Text_STR("MOV, INR and DCR tests: ")
ALUTstMsg	Text_STR("Arithmetic and logic tests: ")
CPUOKMsg	Text_MSG("CPU tests passed!")
ErrorMsg	Text_STR("ERROR @")
KOMsg	Text_MSG("failed!")
OKMsg	Text_MSG("OK")

.segment "Stack"
StackStrt	.ds 256, 0	; 256 bytes of stack
StackEnd	.byte $FF
OldStack	.word 0
