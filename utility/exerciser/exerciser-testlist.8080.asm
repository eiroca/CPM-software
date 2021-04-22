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
; For the purposes of this test program, the machine state consists of  a 2 byte
; memory operand, followed by the registers hl,de,bc,af,sp for a total of
; STATESIZE bytes.
;
; The program tests instructions (or groups of similar instructions)
; by cycling through a sequence of machine states, executing the test
; instruction for each one and running a 32-bit crc over the resulting
; machine states.  At the end of the sequence the crc is compared to
; an expected value that was found empirically on a real 8080/8085.

; A test case is defined by a descriptor which consists of:
;	the base case,
;	the incement vector,
;	the shift vector,
;	the result mask vector,
;	the expected crc,
;	a short descriptive message.
;
; The result mask vector is used to prevent undefined flag bits or program
; memory addresses from influencing the results.
;
; The first three parts of the descriptor are TEST_SIZE byte vectors
; corresponding to a IUT_SIZE byte instruction and a STATESIZE byte machine state.
; The first part is the base case, which is the first test case of
; the sequence.  This base is then modified according to the next 2
; vectors.  Each 1 bit in the increment vector specifies a bit to be
; cycled in the form of a binary counter.  For instance, if the byte
; corresponding to the accumulator is set to $FF in the increment
; vector, the test will be repeated for all 256 values of the
; accumulator.  Note that 1 bits don't have to be contiguous.  The
; number of test cases 'caused' by the increment vector is equal to
; 2^(number of 1 bits).  The shift vector is similar, but specifies a
; set of bits in the test case that are to be successively inverted.
; Thus the shift vector 'causes' a number of test cases equal to the
; number of 1 bits in it.

; The total number of test cases is the product of those caused by the
; counter and shift vectors and can easily become unweildy.  Each
; individual test case can take a few milliseconds to execute, due to
; the overhead of test setup and crc calculation, so test design is a
; compromise between coverage and execution time.

; This program is designed to detect differences between
; implementations and is not ideal for diagnosing the causes of any
; discrepancies.  However, provided a reference implementation (or
; real system) is available, a failing test case can be isolated by
; hand using a binary search of the test space.
;
;******************************************************************************
;
; compile with RetroAssembler
; Tab Size = 10
;

.segment "Constants"

TestList8080
	.word	tt80_flag
	.word	test_add
	.word	test_adi
	.word	test_sub
	.word	test_sui
	.word	tt80_ana
	.word	tt80_ani
	.word	test_ora
	.word	test_ori
	.word	test_adc
	.word	test_aci
	.word	test_sbb
	.word	test_sbi
	.word	test_xra
	.word	test_xri
	.word	test_cmp
	.word	test_cpi
	.word	test_daa
	.word	test_rot
	.word	test_dad
	.word	test_inca
	.word	test_incb
	.word	test_incc
	.word	test_incd
	.word	test_ince
	.word	test_inch
	.word	test_incl
	.word	test_incm
	.word	test_inxb
	.word	test_inxd
	.word	test_inxh
	.word	test_inxs
	.word	test_ldhl
	.word	test_sthl
	.word	test_lxi
	.word	test_mov
	.word	test_mvi
	.word	test_ldax
	.word	test_stax
	.word	test_ldst
	.word	0

TestList8085
	.word	tt85_flag
	.word	test_add
	.word	test_adi
	.word	test_sub
	.word	test_sui
	.word	tt85_ana
	.word	tt85_ani
	.word	test_ora
	.word	test_ori
	.word	test_adc
	.word	test_aci
	.word	test_sbb
	.word	test_sbi
	.word	test_xra
	.word	test_xri
	.word	test_cmp
	.word	test_cpi
	.word	test_daa
	.word	test_rot
	.word	test_dad
	.word	test_inca
	.word	test_incb
	.word	test_incc
	.word	test_incd
	.word	test_ince
	.word	test_inch
	.word	test_incl
	.word	test_incm
	.word	test_inxb
	.word	test_inxd
	.word	test_inxh
	.word	test_inxs
	.word	test_ldhl
	.word	test_sthl
	.word	test_lxi
	.word	test_mov
	.word	test_mvi
	.word	test_ldax
	.word	test_stax
	.word	test_ldst
	.word	0

; CRC computed for msbt=$0105

; 8080/8085 tests
test_add	defTest($80,$00,$00,$00, $C53E,  msbt,$E309,$A666,$D0,$3B,$ADBB)	; ADD
	defData($07,$00,$00,$00, $0000, $0000,$0000,$0000,$00,$FF,$0000)	; x 2048 cycles
	defData($00,$00,$00,$00, $00FF, $0000,$FFFF,$FFFF,$D7,$00,$0000)	; x 46 cycles
	defMask(                 $FFFF, $0000,$FFFF,$FFFF,$D5,$FF,$FFFF)
	defCRC($E7,$37,$9F,$F1)
	.ascii	"add <b,c,d,e,h,l,m,a> .... $"

test_adi	defTest($C6,$00,$00,$00, $9140, $DF6D,$5B61,$0B29,$10,$66,$85B2)	; ADI
	defData($00,$00,$00,$00, $0000, $0000,$0000,$0000,$00,$FF,$0000)	; x 256 cycles
	defData($00,$FF,$00,$00, $0000, $0000,$0000,$0000,$D7,$00,$0000)	; x 14 cycles
	defMask(                 $FFFF, $FFFF,$FFFF,$FFFF,$D5,$FF,$FFFF)
	defCRC($E4,$B1,$1E,$64)
	.ascii	"adi nn ................... $"

test_sub	defTest($90,$00,$00,$00, $C53E,  msbt,$E309,$A666,$D0,$3B,$ADBB)	; SUB
	defData($07,$00,$00,$00, $0000, $0000,$0000,$0000,$00,$FF,$0000)	; x 2048 cycles
	defData($00,$00,$00,$00, $00FF, $0000,$FFFF,$FFFF,$D7,$00,$0000)	; x 46 cycles
	defMask(                 $FFFF, $0000,$FFFF,$FFFF,$D5,$FF,$FFFF)
	defCRC($05,$49,$3C,$28)
	.ascii	"sub <b,c,d,e,h,l,m,a> .... $"

test_sui	defTest($D6,$00,$00,$00, $9140, $DF6D,$5B61,$0B29,$10,$66,$85B2)	; SUI
	defData($00,$00,$00,$00, $0000, $0000,$0000,$0000,$00,$FF,$0000)	; x 256 cycles
	defData($00,$FF,$00,$00, $0000, $0000,$0000,$0000,$D7,$00,$0000)	; x 14 cycles
	defMask(                 $FFFF, $FFFF,$FFFF,$FFFF,$D5,$FF,$FFFF)
	defCRC($26,$8E,$D6,$4E)
	.ascii	"sui nn ................... $"

test_ora	defTest($B0,$00,$00,$00, $C53E,  msbt,$E309,$A666,$D0,$3B,$ADBB)	; ORA
	defData($07,$00,$00,$00, $0000, $0000,$0000,$0000,$00,$FF,$0000)	; x 2048 cycles
	defData($00,$00,$00,$00, $00FF, $0000,$FFFF,$FFFF,$D7,$00,$0000)	; x 46 cycles
	defMask(                 $FFFF, $0000,$FFFF,$FFFF,$D5,$FF,$FFFF)
	defCRC($9D,$90,$7C,$B8)
	.ascii	"ora <b,c,d,e,h,l,m,a> .... $"

test_ori	defTest($F6,$00,$00,$00, $9140, $DF6D,$5B61,$0B29,$10,$66,$85B2)	; ORI
	defData($00,$00,$00,$00, $0000, $0000,$0000,$0000,$00,$FF,$0000)	; x 256 cycles
	defData($00,$FF,$00,$00, $0000, $0000,$0000,$0000,$D7,$00,$0000)	; x 14 cycles
	defMask(                 $FFFF, $FFFF,$FFFF,$FFFF,$D5,$FF,$FFFF)
	defCRC($28,$C3,$4E,$3D)
	.ascii	"ori nn ................... $"

test_adc	defTest($88,$00,$00,$00, $C53E,  msbt,$E309,$A666,$D0,$3B,$ADBB)	; ADC
	defData($07,$00,$00,$00, $0000, $0000,$0000,$0000,$00,$FF,$0000)	; x 2048 cycles
	defData($00,$00,$00,$00, $00FF, $0000,$FFFF,$FFFF,$D7,$00,$0000)	; x 46 cycles
	defMask(                 $FFFF, $0000,$FFFF,$FFFF,$D5,$FF,$FFFF)
	defCRC($B8,$55,$BC,$D9)
	.ascii	"adc <b,c,d,e,h,l,m,a> .... $"

test_aci	defTest($CE,$00,$00,$00, $9140, $DF6D,$5B61,$0B29,$10,$66,$85B2)	; ACI
	defData($00,$00,$00,$00, $0000, $0000,$0000,$0000,$00,$FF,$0000)	; x 256 cycles
	defData($00,$FF,$00,$00, $0000, $0000,$0000,$0000,$D7,$00,$0000)	; x 14 cycles
	defMask(                 $FFFF, $FFFF,$FFFF,$FFFF,$D5,$FF,$FFFF)
	defCRC($C2,$BA,$42,$C5)
	.ascii	"aci nn ................... $"

test_sbb	defTest($98,$00,$00,$00, $C53E,  msbt,$E309,$A666,$D0,$3B,$ADBB)	; SBB
	defData($07,$00,$00,$00, $0000, $0000,$0000,$0000,$00,$FF,$0000)	; x 2048 cycles
	defData($00,$00,$00,$00, $00FF, $0000,$FFFF,$FFFF,$D7,$00,$0000)	; x 46 cycles
	defMask(                 $FFFF, $0000,$FFFF,$FFFF,$D5,$FF,$FFFF)
	defCRC($73,$51,$A9,$38)
	.ascii	"sbb <b,c,d,e,h,l,m,a> .... $"

test_sbi	defTest($DE,$00,$00,$00, $9140, $DF6D,$5B61,$0B29,$10,$66,$85B2)	; SBI
	defData($00,$00,$00,$00, $0000, $0000,$0000,$0000,$00,$FF,$0000)	; x 256 cycles
	defData($00,$FF,$00,$00, $0000, $0000,$0000,$0000,$D7,$00,$0000)	; x 14 cycles
	defMask(                 $FFFF, $FFFF,$FFFF,$FFFF,$D5,$FF,$FFFF)
	defCRC($E6,$6C,$87,$F7)
	.ascii	"sbi nn ................... $"

test_xra	defTest($A8,$00,$00,$00, $C53E,  msbt,$E309,$A666,$D0,$3B,$ADBB)	; XRA
	defData($07,$00,$00,$00, $0000, $0000,$0000,$0000,$00,$FF,$0000)	; x 2048 cycles
	defData($00,$00,$00,$00, $00FF, $0000,$FFFF,$FFFF,$D7,$00,$0000)	; x 46 cycles
	defMask(                 $FFFF, $0000,$FFFF,$FFFF,$D5,$FF,$FFFF)
	defCRC($B5,$6B,$29,$40)
	.ascii	"xra <b,c,d,e,h,l,m,a> .... $"

test_xri	defTest($EE,$00,$00,$00, $9140, $DF6D,$5B61,$0B29,$10,$66,$85B2)	; XRI
	defData($00,$00,$00,$00, $0000, $0000,$0000,$0000,$00,$FF,$0000)	; x 256 cycles
	defData($00,$FF,$00,$00, $0000, $0000,$0000,$0000,$D7,$00,$0000)	; x 14 cycles
	defMask(                 $FFFF, $FFFF,$FFFF,$FFFF,$D5,$FF,$FFFF)
	defCRC($86,$D0,$7D,$4C)
	.ascii	"xri nn ................... $"

test_cmp	defTest($B8,$00,$00,$00, $C53E,  msbt,$E309,$A666,$D0,$3B,$ADBB)	; CMP
	defData($07,$00,$00,$00, $0000, $0000,$0000,$0000,$00,$FF,$0000)	; x 2048 cycles
	defData($00,$00,$00,$00, $00FF, $0000,$FFFF,$FFFF,$D7,$00,$0000)	; x 46 cycles
	defMask(                 $FFFF, $0000,$FFFF,$FFFF,$D5,$FF,$FFFF)
	defCRC($6F,$63,$A7,$11)
	.ascii	"cmp <b,c,d,e,h,l,m,a> .... $"

test_cpi	defTest($FE,$00,$00,$00, $9140, $DF6D,$5B61,$0B29,$10,$66,$85B2)	; CPI
	defData($00,$00,$00,$00, $0000, $0000,$0000,$0000,$00,$FF,$0000)	; x 256 cycles
	defData($00,$FF,$00,$00, $0000, $0000,$0000,$0000,$D7,$00,$0000)	; x 14 cycles
	defMask(                 $FFFF, $FFFF,$FFFF,$FFFF,$D5,$FF,$FFFF)
	defCRC($93,$D3,$68,$08)
	.ascii	"cpi nn ................... $"

test_daa	defTest($27,$00,$00,$00, $2141, $A559,$8D5B,$9079,$04,$8E,$299D)	; DAA,CMA,STC,CMC
	defData($18,$00,$00,$00, $0000, $0000,$0000,$0000,$D7,$FF,$0000)	; x 65,536 cycles
	defData($00,$00,$00,$00, $0000, $0000,$0000,$0000,$00,$00,$0000)	; x 1 cycle
	defMask(                 $FFFF, $FFFF,$FFFF,$FFFF,$D5,$FF,$FFFF)
	defCRC($DF,$71,$5C,$B3)
	.ascii	"<daa,cma,stc,cmc> ........ $"

test_rot	defTest($07,$00,$00,$00, $CB92, $C284,$0C53,$F50E,$91,$EB,$40FC)	; RLC,RRC,RAL,RAR
	defData($18,$00,$00,$00, $0000, $0000,$0000,$0000,$00,$FF,$0000)	; x 1024 cycles
	defData($00,$00,$00,$00, $0000, $0000,$0000,$0000,$D7,$00,$0000)	; x 6 cycles
	defMask(                 $FFFF, $FFFF,$FFFF,$FFFF,$D5,$FF,$FFFF)
	defCRC($2B,$15,$8F,$AC)
	.ascii	"<rlc,rrc,ral,rar> ........ $"

test_dad	defTest($09,$00,$00,$00, $C4A5, $A050,$58EA,$8566,$C6,$DE,$9BC9)	; DAD
	defData($30,$00,$00,$00, $0000, $F821,$0000,$0000,$00,$00,$0000)	; x 512 cycles
	defData($00,$00,$00,$00, $0000, $FFFF,$FFFF,$FFFF,$D7,$00,$FFFF)	; x 38 cycles
	defMask(                 $FFFF, $FFFF,$FFFF,$FFFF,$D5,$FF,$FFFF)
	defCRC($DF,$62,$92,$9B)
	.ascii	"dad <b,d,h,sp> ........... $"

test_inca	defTest($3C,$00,$00,$00, $4ADF, $8A2B,$A7B0,$431B,$44,$5A,$D030)	; INR,DCR A
	defData($01,$00,$00,$00, $0000, $0000,$0000,$0000,$00,$FF,$0000)	; x 512 cycles
	defData($00,$00,$00,$00, $0000, $0000,$0000,$0000,$D7,$00,$0000)	; x 6 cycles
	defMask(                 $FFFF, $FFFF,$FFFF,$FFFF,$D5,$FF,$FFFF)
	defCRC($E5,$D7,$46,$41)
	.ascii	"<inr,dcr> a .............. $"

test_incb	defTest($04,$00,$00,$00, $D623, $8180,$5A86,$1E85,$86,$58,$9BBB)	; INR,DCR B
	defData($01,$00,$00,$00, $0000, $0000,$0000,$FF00,$00,$00,$0000)	; x 512 cycle
	defData($00,$00,$00,$00, $0000, $0000,$0000,$0000,$D7,$00,$0000)	; x 6 cycles
	defMask(                 $FFFF, $FFFF,$FFFF,$FFFF,$D5,$FF,$FFFF)
	defCRC($BE,$2C,$B9,$D4)
	.ascii	"<inr,dcr> b .............. $"

test_incc	defTest($0C,$00,$00,$00, $D789, $9F85,$8B27,$D208,$95,$05,$0660)	; INR,DCR C
	defData($01,$00,$00,$00, $0000, $0000,$0000,$00FF,$00,$00,$0000)	; x 512 cycles
	defData($00,$00,$00,$00, $0000, $0000,$0000,$0000,$D7,$00,$0000)	; x 6 cycles
	defMask(                 $FFFF, $FFFF,$FFFF,$FFFF,$D5,$FF,$FFFF)
	defCRC($82,$F4,$4B,$17)
	.ascii	"<inr,dcr> c .............. $"

test_incd	defTest($14,$00,$00,$00, $A0EA, $981C,$38CC,$DEBC,$43,$5C,$03BD)	; INR,DCR D
	defData($01,$00,$00,$00, $0000, $0000,$FF00,$0000,$00,$00,$0000)	; x 512 cycles
	defData($00,$00,$00,$00, $0000, $0000,$0000,$0000,$D7,$00,$0000)	; x 6 cycles
	defMask(                 $FFFF, $FFFF,$FFFF,$FFFF,$D5,$FF,$FFFF)
	defCRC($2A,$51,$8F,$7D)
	.ascii	"<inr,dcr> d .............. $"

test_ince	defTest($1C,$00,$00,$00, $602f, $E2F5,$A0F4,$A10A,$13,$32,$5925)	; INR,DCR E
	defData($01,$00,$00,$00, $0000, $0000,$00FF,$0000,$00,$00,$0000)	; x 512 cycles
	defData($00,$00,$00,$00, $0000, $0000,$0000,$0000,$D7,$00,$0000)	; x 6 cycles
	defMask(                 $FFFF, $FFFF,$FFFF,$FFFF,$D5,$FF,$FFFF)
	defCRC($B7,$BF,$26,$5A)
	.ascii	"<inr,dcr> e .............. $"

test_inch	defTest($24,$00,$00,$00, $1506, $262B,$11A6,$BC1A,$17,$06,$2818)	; INR,DCR H
	defData($01,$00,$00,$00, $0000, $FF00,$0000,$0000,$00,$00,$0000)	; x 512 cycles
	defData($00,$00,$00,$00, $0000, $0000,$0000,$0000,$D7,$00,$0000)	; x 6 cycles
	defMask(                 $FFFF, $FFFF,$FFFF,$FFFF,$D5,$FF,$FFFF)
	defCRC($C9,$08,$5D,$7E)
	.ascii	"<inr,dcr> h .............. $"

test_incl	defTest($2C,$00,$00,$00, $8031, $B409,$F4C1,$DFA2,$D1,$3C,$3EA2)	; INR,DCR L
	defData($01,$00,$00,$00, $0000, $00FF,$0000,$0000,$00,$00,$0000)	; x 512 cycles
	defData($00,$00,$00,$00, $0000, $0000,$0000,$0000,$D7,$00,$0000)	; x 6 cycles
	defMask(                 $FFFF, $FFFF,$FFFF,$FFFF,$D5,$FF,$FFFF)
	defCRC($99,$48,$5A,$00)
	.ascii	"<inr,dcr> l .............. $"

test_incm	defTest($34,$00,$00,$00, $B856,  msbt,$877E,$DA58,$15,$5C,$1F37)	; INR,DCR M
	defData($01,$00,$00,$00, $00FF, $0000,$0000,$0000,$00,$00,$0000)	; x 512 cycles
	defData($00,$00,$00,$00, $0000, $0000,$0000,$0000,$D7,$00,$0000)	; x 6 cycles
	defMask(                 $FFFF, $0000,$FFFF,$FFFF,$D5,$FF,$FFFF)
	defCRC($00,$D9,$E5,$C1)
	.ascii	"<inr,dcr> m .............. $"

test_inxb	defTest($03,$00,$00,$00, $CD97, $E3E3,$11CC,$E8A4,$02,$49,$2A4D)	; INX,DCX B
	defData($08,$00,$00,$00, $0000, $0000,$0000,$F821,$00,$00,$0000)	; x 256 cycles
	defData($00,$00,$00,$00, $0000, $0000,$0000,$0000,$D7,$00,$0000)	; x 6 cycles
	defMask(                 $FFFF, $FFFF,$FFFF,$FFFF,$D5,$FF,$FFFF)
	defCRC($D2,$12,$34,$20)
	.ascii	"<inx,dcx> b .............. $"

test_inxd	defTest($13,$00,$00,$00, $342E, $0ACA,$9967,$3A2E,$92,$F6,$9D54)	; INX,DCX D
	defData($08,$00,$00,$00, $0000, $0000,$F821,$0000,$00,$00,$0000)	; x 256 cycles
	defData($00,$00,$00,$00, $0000, $0000,$0000,$0000,$D7,$00,$0000)	; x 6 cycles
	defMask(                 $FFFF, $FFFF,$FFFF,$FFFF,$D5,$FF,$FFFF)
	defCRC($2F,$D9,$8C,$9A)
	.ascii	"<inx,dcx> d .............. $"

test_inxh	defTest($23,$00,$00,$00, $C3F4, $4F04,$E2C2,$822A,$57,$E0,$C3E1)	; INX,DCX H
	defData($08,$00,$00,$00, $0000, $F821,$0000,$0000,$00,$00,$0000)	; x 256 cycles
	defData($00,$00,$00,$00, $0000, $0000,$0000,$0000,$D7,$00,$0000)	; x 6 cycles
	defMask(                 $FFFF, $FFFF,$FFFF,$FFFF,$D5,$FF,$FFFF)
	defCRC($30,$C7,$97,$C6)
	.ascii	"<inx,dcx> h .............. $"

test_inxs	defTest($33,$00,$00,$00, $346F, $DEB6,$A494,$F476,$53,$02,$855B)	; INX,DCX SP
	defData($08,$00,$00,$00, $0000, $0000,$0000,$0000,$00,$00,$f821)	; x 256 cycles
	defData($00,$00,$00,$00, $0000, $0000,$0000,$0000,$D7,$00,$0000)	; x 6 cycles
	defMask(                 $FFFF, $FFFF,$FFFF,$FFFF,$D5,$FF,$FFFF)
	defCRC($C2,$06,$94,$EB)
	.ascii	"<inx,dcx> sp ............. $"

test_ldhl	defTest($2a,<msbt,>msbt,$00, $9863, $B1FE,$B9FA,$ABB8,$04,$06,$6015)	; LHLD
	defData($00,$00,$00,$00,     $0000, $0000,$0000,$0000,$00,$00,$0000)	; (1 cycle)
	defData($00,$00,$00,$00,     $FFFF, $0000,$0000,$0000,$00,$00,$0000)	; (16 cycles)
	defMask(                     $FFFF, $FFFF,$FFFF,$FFFF,$D5,$FF,$FFFF)
	defCRC($B3,$FA,$54,$20)
	.ascii	"lhld nnnn ................ $"

test_sthl	defTest($22,<msbt,>msbt,$00, $D003, $3F72,$64EA,$E180,$10,$2D,$35E9)	; SHLD
	defData($00,$00,$00,$00,     $0000, $0000,$0000,$0000,$00,$00,$0000)	; (1 cycle)
	defData($00,$00,$00,$00,     $0000, $FFFF,$0000,$0000,$00,$00,$0000)	; (16 cycles)
	defMask(                     $FFFF, $FFFF,$FFFF,$FFFF,$D5,$FF,$FFFF)
	defCRC($11,$DA,$8C,$6B)
	.ascii	"shld nnnn ................ $"

test_lxi	defTest($01,$AA,$55,$00, $5C1C, $6078,$74B1,$B30E,$46,$D1,$30CC)	; LXI
	defData($30,$00,$00,$00, $0000, $0000,$0000,$0000,$00,$00,$0000)	; x 4 cycles
	defData($00,$FF,$FF,$00, $0000, $0000,$0000,$0000,$00,$00,$0000)	; x 16 cycles
	defMask(                 $FFFF, $FFFF,$FFFF,$FFFF,$D5,$FF,$FFFF)
	defCRC($64,$CF,$69,$05)
	.ascii	"lxi <b,d,h,sp>,nnnn ...... $"

test_mov	defTest($40,$00,$00,$00, $72A4,  msbt,$82C7,$718F,$97,$8F,$EF8E)	; MOV
	defData($3f,$00,$00,$00, $0000, $0000,$0000,$0000,$00,$00,$0000)	; x 64 cycles
	defData($00,$00,$00,$00, $00FF, $0000,$FFFF,$FFFF,$D7,$FF,$0000)	; x 54 cycles
	defMask(                 $FFFF, $0000,$FFFF,$FFFF,$D5,$FF,$FFFF)
	defCRC($AC,$91,$4E,$14)
	.ascii	"mov <R,m>,<R,m> .......... $"

test_mvi	defTest($06,$A5,$00,$00, $C407,  msbt,$DE89,$7455,$53,$A5,$5509)	; MVI
	defData($38,$00,$00,$00, $0000, $0000,$0000,$0000,$00,$00,$0000)	; x 8 cycles
	defData($00,$FF,$00,$00, $0000, $0000,$0000,$0000,$00,$FF,$0000)	; x 16 cycles
	defMask(                 $FFFF, $0000,$FFFF,$FFFF,$D5,$FF,$FFFF)
	defCRC($4C,$87,$D6,$E5)
	.ascii	"mvi <b,c,d,e,h,l,m,a>,nn . $"

test_ldax	defTest($0A,$00,$00,$00, $B3A8, $42AC, msbt, msbt,$C6,$B1,$EF8E)	; LDAX
	defData($10,$00,$00,$00, $0000, $0000,$0000,$0000,$00,$00,$0000)	; x 2 cycles
	defData($00,$00,$00,$00, $00FF, $0000,$0000,$0000,$D7,$FF,$0000)	; x 22 cycles
	defMask(                 $FFFF, $FFFF,$0000,$0000,$D5,$FF,$FFFF)
	defCRC($19,$4D,$55,$A0)
	.ascii	"ldax <b,d> ............... $"

test_stax	defTest($02,$00,$00,$00, $0C3B, $959E,msbt,msbt+1,$C1,$21,$BDE7)	; STAX
	defData($18,$00,$00,$00, $0000, $0000,$0000,$0000,$00,$00,$0000)	; x 4 cycles
	defData($00,$00,$00,$00, $FFFF, $0000,$0000,$0000,$00,$FF,$0000)	; x 24 cycles
	defMask(                 $FFFF, $FFFF,$0000,$0000,$D5,$FF,$FFFF)
	defCRC($03,$CE,$80,$55)
	.ascii	"stax <b,d> ............... $"

test_ldst	defTest($32,<msbt,>msbt,$00, $FD68, $B543,$0653,$CDBA,$D2,$4F,$1FD8)	; LDA/STA
	defData($08,$00,$00,$00,     $0000, $0000,$0000,$0000,$00,$00,$0000)	; x 2 cycle
	defData($00,$00,$00,$00,     $00FF, $0000,$0000,$0000,$D7,$FF,$0000)	; x 22 cycles
	defMask(                     $FFFF, $FFFF,$FFFF,$FFFF,$D5,$FF,$FFFF)
	defCRC($03,$57,$8D,$7D)
	.ascii	"sta nnnn / lda nnnn ...... $"

; 8080 specific tests
tt80_flag	defTest($F5,$C1,$C5,$F1, $9140, $DF6D,$5B61,$0B29,$02,$A5,$85B2)	; 8080 flags
	defData($00,$00,$00,$00, $0000, $0000,$0000,$0000,$00,$00,$0000)	; x 1 cycles
	defData($00,$00,$00,$00, $0000, $0000,$0000,$0000,$FF,$FF,$0000)	; x 16 cycles
	defMask(                 $FFFF, $FFFF,$FFFF,$FFFF,$FF,$FF,$FFFF)
	defCRC($DF,$E1,$5F,$DE)
	.ascii	"8080 flags ............... $"

tt80_ana	defTest($A0,$00,$00,$00, $C53E,  msbt,$E309,$A666,$D0,$3B,$ADBB)	; ANA
	defData($07,$00,$00,$00, $0000, $0000,$0000,$0000,$00,$FF,$0000)	; x 2048 cycles
	defData($00,$00,$00,$00, $00FF, $0000,$FFFF,$FFFF,$D7,$00,$0000)	; x 46 cycles
	defMask(                 $FFFF, $0000,$FFFF,$FFFF,$FF,$FF,$FFFF)
	defCRC($4F,$BC,$6A,$9F)
	.ascii	"ana <b,c,d,e,h,l,m,a> .... $"

tt80_ani	defTest($E6,$00,$00,$00, $9140, $DF6D,$5B61,$0B29,$10,$66,$85B2)	; ANI
	defData($00,$00,$00,$00, $0000, $0000,$0000,$0000,$00,$FF,$0000)	; x 256 cycles
	defData($00,$FF,$00,$00, $0000, $0000,$0000,$0000,$D7,$00,$0000)	; x 14 cycles
	defMask(                 $FFFF, $FFFF,$FFFF,$FFFF,$FF,$FF,$FFFF)
	defCRC($C5,$66,$F5,$D6)
	.ascii	"ani nn ................... $"

; 8085 specific tests
tt85_flag	defTest($F5,$C1,$C5,$F1, $9140, $DF6D,$5B61,$0B29,$02,$A5,$85B2)	; 8080 flags
	defData($00,$00,$00,$00, $0000, $0000,$0000,$0000,$00,$00,$0000)	; x 1 cycles
	defData($00,$00,$00,$00, $0000, $0000,$0000,$0000,$FF,$FF,$0000)	; x 16 cycles
	defMask(                 $FFFF, $FFFF,$FFFF,$FFFF,$FF,$FF,$FFFF)
	defCRC($33,$A3,$47,$BA)
	.ascii	"8085 flags ............... $"

tt85_ana	defTest($A0,$00,$00,$00, $C53E,  msbt,$E309,$A666,$D0,$3B,$ADBB)	; ANA
	defData($07,$00,$00,$00, $0000, $0000,$0000,$0000,$00,$FF,$0000)	; x 2048 cycles
	defData($00,$00,$00,$00, $00FF, $0000,$FFFF,$FFFF,$D7,$00,$0000)	; x 46 cycles
	defMask(                 $FFFF, $0000,$FFFF,$FFFF,$FF,$FF,$FFFF)
	defCRC($E5,$74,$9A,$AB)
	.ascii	"ana <b,c,d,e,h,l,m,a> .... $"

tt85_ani	defTest($E6,$00,$00,$00, $9140, $DF6D,$5B61,$0B29,$10,$66,$85B2)	; ANI
	defData($00,$00,$00,$00, $0000, $0000,$0000,$0000,$00,$FF,$0000)	; x 256 cycles
	defData($00,$FF,$00,$00, $0000, $0000,$0000,$0000,$D7,$00,$0000)	; x 14 cycles
	defMask(                 $FFFF, $FFFF,$FFFF,$FFFF,$FF,$FF,$FFFF)
	defCRC($01,$E4,$C1,$26)
	.ascii	"ani nn ................... $"

.macro defTest(_iut1,_iut2,_iut3,_iut4,_memop,_hl,_de,_bc,_flags,_acc,_sp)
	.byte	_iut1, _iut2, _iut3, _iut4
	.word	_memop
	.word	_hl, _de, _bc
	.byte	_flags, _acc
	.word	_sp
.endmacro

.macro defData(b1,b2,b3,b4,w1,w2,w3,w4,b5,b6,w5)
	.byte	b1,b2,b3,b4
	.word	w1,w2,w3,w4
	.byte	b5,b6
	.word	w5
.endmacro

.macro defMask(_memop,_hl,_de,_bc,_flags,_acc,_sp)
	.word	_memop
	.word	_hl, _de, _bc
	.byte	_flags, _acc
	.word	_sp
.endmacro

.macro defCRC(b1,b2,b3,b4)
	.byte	b1,b2,b3,b4
.endmacro
