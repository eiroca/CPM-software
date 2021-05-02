;******************************************************************************
;
; prelim.z80 - Preliminary Z80 tests - Copyright (C) 199\  Frank D. Cringle
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
;
; Modified to exercise an 8080 by Ian Bartholomew, February 2009
;
; I have made the following changes -
;
; Converted all mnemonics to 8080 and rewritten any Z80 code used
; in the original exerciser.  Changes are tagged with a #idb in the
; source code listing.
;
; Removed any test descriptors that are not used.
;
; Changed the macro definitions to work in M80
;
; The machine state snapshot has been changed to remove the IX/IY registers.
; They have been replaced by two more copies of HL to obviate the need
; for major changes in the exerciser code.
;
; Changed flag mask in all tests to $FF to reflect that the 8080, unlike the 8085
; and Z80, does define the unused bits in the flag register - [S Z 0 AC 0 P 1 C]
;
;******************************************************************************
; compile with RetroAssembler
; Tab Size = 10
;

.segment "Resources"
.if	IS_DAI==1
okmsg	Text_MSG(" OK")
.endif
.if	IS_CPM==1
okmsg	Text_STR("\r")
.endif
ermsg1	Text_STR(" KO CRC:")
ermsg2	Text_STR(" found:")

.segment "Constants"
IUT_SIZE	.equ	4
STATESIZE	.equ	12
TESTSIZE	.equ	IUT_SIZE+STATESIZE
MASKSIZE	.equ	20
OP_HLT	.equ	$76

.data
TestOKs	.ds	1	; Results of the test(s) ($00=OK)
curTest	.ds	2	; current test
tstcnt	.ds	2	; test counter
PTestIUT	.ds	2
PTestSta	.ds	2
PIncMask	.ds	2
PShtMask	.ds	2
PAndMask	.ds	2
hlsav	.ds	2
spsav	.ds	2	; saved stack pointer
counter	.ds	MASKSIZE, $00
 	.ds	MASKSIZE, $00
cntbyt	.ds	2
cntbit	.ds	1
shifter	.ds	MASKSIZE, $00
	.ds	MASKSIZE, $00
shfbyt	.ds	2
shfbit	.ds	1
crcval	.ds	4


.lib
.function TestSuite()
; Init TestSuite
	DebugTrace(0)
	xra	A
	sta	TestOKs
	is8085()
	jz	@tst8085
	lxi	H, TestList8080-2
	jmp	@testIt
@tst8085	lxi	H, TestList8085-2
@testIt	shld	curTest
	lda	CTestRun
	cpi	$00
	jz	@TestLoop
; Single Test in the testsuite (index 1..)
	mov	E,A
	mvi	D,$00
	dad	D
	dad	D
	_HL_ind()			; HL <- (TestList + 2*D - 2)
	RunTest()
	jmp	@TestsDone
; Test all the testsuite
@TestLoop	lhld	curTest
	inx	H
	inx	H
	WriteStatus()
	shld	curTest
	_HL_ind()			; curTest++; HL<-(curTest)
	mov	A, H
	ora	L
	jz	@TestsDone
	RunTest()
	lda	CBrkOnErr
	ora	A
	jz	@TestLoop
	lda	TestOKs
	ora	A
	lxi	H,TestOKs
	mov	B,M
	mvi	C,0
	WriteStatus()
	jz	@TestLoop
@TestsDone
.endfunction

; start test pointed to by (hl)
.function RunTest()
TestStat	WriteStatus()

	shld	PTestIUT		; + 00
	lxi	d, IUT_SIZE
	dad	d
	shld	PTestSta		; + 04
	lxi	d, STATESIZE
	dad	d
	shld	PIncMask		; +20
	lxi	d, TESTSIZE
	dad	d
	shld	PShtMask		; +40
	lxi	d, TESTSIZE
	dad	d
	shld	PAndMask		; +64

	_HL_ptr(PTestIUT, TESTSIZE*4)		; pointer to test description
	Text_printMSG_H()			; show test name

	; copy initial instruction under test
	lhld	PTestIUT
	lxi	d,iut
	lxi	b,IUT_SIZE
	_ldir()

	; copy initial machine state
	lhld	PTestSta
	lxi	d,msbt
	lxi	b,STATESIZE
	_ldir()

	lhld	PIncMask		; point to incmask
	lxi	d,counter
	initmask()

	lhld	PShtMask		; point to scanmask
	lxi	d,shifter
	initmask()
	lxi	h,shifter
	mvi	m,1		; first bit

	DebugTrace(3)
	DebugTrace(4)

	lxi	H,crcval
	CRC_init()		; initialise crc

	xra	A	; Reset Test Counter
	sta	tstcnt+0
	sta	tstcnt+1

; test loop
TestLoop	push	H
	lhld	tstcnt
	inx	H
	shld	tstcnt
	pop	H
	lda	IUT
	cpi	OP_HLT		; pragmatically avoid halt intructions
	jz	TestDone
	ani	$DF		; skip illegal instructions
	cpi	$DD
	jz	TestDone

; execute the test instruction
test	DebugTrace(1)
	di			; disable interrupts
	_HLSP()		; save stack pointer
	shld	spsav
	lxi	sp,StkMrkBT	; point to test-case machine state
	pop	h
	pop	d
	pop	b
	pop	psw
	shld	hlsav
	lhld	spbt
	sphl
	lhld	hlsav
IUT	.ds	IUT_SIZE, $00	; max IUT_SIZE byte instruction under test
	shld	hlsav
	lxi	h,0
	jc	@temp1		;jump on the state of the C flag set in the test
	dad	sp		;this code will clear the C flag (0 + nnnn = nc)
	jmp	@temp2		;C flag is same state as before
@temp1	dad	sp		;this code will clear the C flag (0 + nnnn = nc)
	stc			;C flage needs re-setting to preserve state
@temp2	shld	spat
	lhld	hlsav
	lxi	sp,StkMrkAT
	push	psw		; save other registers
	push	b
	push	d
	push	h
	lhld	spsav		; restore stack pointer
	sphl
	ei			; enable interrupts
	lhld	msbt		; copy memory operand
	shld	msat

; Mask result after test
@MaskStrt	DebugTrace(6, '>')
	pushRegs()
	lhld	PAndMask
	xchg			; D points to mask
	lxi	H, msat		; M points to state after test
	mvi	B, STATESIZE
@MaskLoop	ldax	D		; mask a byte
	mov	C, A
	mov	A, M
	ana	C
	mov	M, A
	dcr	B
	jz	@MaskEnd
	inx	D
	inx	H
	jmp	@MaskLoop
@MaskEnd	DebugTrace(6, '<')
	popRegs()

; update CRC
@updatCRC	mvi	B, STATESIZE	; total of STATESIZE bytes of state
	lxi	D, msat
	lxi	H, crcval
@crcLoop	ldax	d
	inx	d
	CRC_upd()			; accumulate crc of this test case
	dcr	b
	jnz	@crcLoop
	DebugTrace(2)

; Update test status
TestDone	NextCounter()		; increment the counter
	jz	@SkipShft		; shift the scan bit
	NextShifter()
@SkipShft	jnz	TestExit		; done if shift returned NZ
	mvi	a,1		; initialise count and shift scanners
	sta	cntbit
	sta	shfbit
	lxi	h,counter
	shld	cntbyt
	lxi	h,shifter
	shld	shfbyt
	; setup iut
	lhld	PTestIUT		; pointer to test case IUT
	lxi	d,iut
	mvi	b,IUT_SIZE	; bytes in iut field
	setup()
	; setup machine state
	lhld	PTestSta		; pointer to test case STATE
	lxi	d,msbt
	mvi	b,STATESIZE	; bytes in machine state
	setup()
	jmp	TestLoop

; Test Finalization
TestExit	_HL_ptr(PTestIUT, TESTSIZE*4-4)	; point to expected crc
	lxi	D,crcval
	CRC_cmp()
	DebugTrace(7)
	jnz	@tlnotok
	Text_Print(okmsg)
	ret
@tlnotok	mvi 	A, 1		; Mark test failed
	sta	TestOKs
	push	H
	Text_Print(ermsg1)
	pop	H
	phex8()
	Text_Print(ermsg2)
	lxi	h,crcval
	phex8()
	Text_NL()
.endfunction

; initialise counter or shifter
; de = pointer to work area for counter or shifter
; hl = pointer to mask
.function initmask()
	DebugTrace(0)
	push	d
	xchg
	lxi	b,MASKSIZE*2
	clrmem()		; clear work area
	xchg
	mvi	b,TESTSIZE	; byte counter
	mvi	c,1		; first bit
	mvi	d,0		; bit counter
; Count "1" bit in mask
@imlp	mov	e,m
@imlp1	mov	a,e
	ana	c
	jz	@Loop2
	inr	d
@Loop2	mov	a,c
	rlc
	mov	c,a
	cpi	$01
	jnz	@imlp1
	inx	h
	dcr	b
	jnz	@imlp
; got number of 1-bits in mask in reg d
	mov	a,d
	ani	$F8
	rrc
	rrc
	rrc			; divide by 8 (get byte offset)
	mov	l,a
	mvi	h,0
	mov	a,d
	ani	$07		; bit offset
	inr	a
	mov	b,a
	mvi	a,$80
;
@imlp3	rlc
	dcr	b
	jnz	@imlp3		; A <- 2 ^ (count(1 in mask) % 8)
	pop	d
	dad	d
	lxi	d,MASKSIZE
	dad	d		; HL = @Shifter + count(1 in mask) / 8 + MASKSIZE
	mov	m,a
.endfunction

; multi-byte counter
.function NextCounter()
	DebugTrace(0)
	lxi	h,counter		; 20 byte counter starts here
	lxi	d,MASKSIZE	; somewhere in here is the stop bit
	xchg
	dad	d
	xchg
@Loop	inr	m
	mov	a,m
	cpi	$00
	jnz	@break	; overflow to next byte
	inx	h
	inx	d
	jmp	@Loop
@break	mov	b,a
	ldax	d
	ana	b		; test for terminal value
	jz	@cntend
	mvi	m,0		; reset to zero
@cntend	DebugTrace(3)
.endfunction

; multi-byte shifter
.function NextShifter()
	DebugTrace(4)
	lxi	h,shifter	; 20 byte shift register starts here
	lxi	d,shifter+MASKSIZE
@shflp	mov	a,m
	ora	a
	jnz	@shflp1
	inx	h
	inx	d
	jmp	@shflp
@shflp1	mov	b,a
	ldax	d
	ana	b
	jnz	@shlpe
	mov	a,b
	rlc
	cpi	1
	jnz	@shflp2
	mvi	m,0
	inx	h
	inx	d
@shflp2	mov	m,a
	xra	a		; set Z
@shlpe
.endfunction

; setup a field of the test case
; B  = number of bytes
; HL = pointer to base case
; DE = destination
.function setup()
@Loop
	push	b
	push	d
	push	h
	mov	c,m		; get base byte
	lxi	d,TESTSIZE
	dad	d		; point to incmask
; Process IncMask
	mov	a,m
	cpi	0
	jz	@subshf
	mvi	b,8		; 8 bits
@subclp	rrc
	push	psw
	mvi	a,0
	jnc	@Change1	; get next counter bit if mask bit was set
	nxtcbit()
@Change1	xra	c		; flip bit if counter bit was set
	rrc
	mov	c,a
	pop	psw
	dcr	b
	jnz	@subclp
	mvi	b,8
; Process ShiftMask
@subshf	lxi	d,TESTSIZE
	dad	d		; point to shift mask
	mov	a,m
	cpi	0
	jz	@substr
	mvi	b,8		; 8 bits
@sbshf1	rrc
	push	psw
	mvi	a,0
	jnc	@Change2	; get next shifter bit if mask bit was set
	nxtsbit()
@Change2	xra	c		; flip bit if shifter bit was set
	rrc
	mov	c,a
	pop	psw
	dcr	b
	jnz	@sbshf1
;
@substr	pop	h
	pop	d
	mov	a,c
	stax	d		; mangled byte to destination
	inx	d
	inx	h
	pop	b
	dcr	b
	jnz	@Loop
.endfunction

; get next counter bit in low bit of a
.function nxtcbit()
	DebugTrace(0)
 	push	b
	push	h
	lhld	cntbyt
	mov	b,m		; B<- (cntbyt)
	lxi	h,cntbit
	mov	a,m
	mov	c,a		; C<- cntbit
	rlc
	mov	m,a
	cpi	1
	jnz	@ncb1
	lhld	cntbyt
	inx	h
	shld	cntbyt
@ncb1	mov	a,b
	ana	c
	pop	h
	pop	b
	rz
	mvi	a,1
.endfunction

; get next shifter bit in low bit of a
.function nxtsbit()
	DebugTrace(0)
 	push	b
	push	h
	lhld	shfbyt
	mov	b,m
	lxi	h,shfbit
	mov	a,m
	mov	c,a
	rlc
	mov	m,a
	cpi	1
	jnz	@nsb1
	lhld	shfbyt
	inx	h
	shld	shfbyt
@nsb1	mov	a,b
	ana	c
	pop	h
	pop	b
	rz
	mvi	a,1
.endfunction
