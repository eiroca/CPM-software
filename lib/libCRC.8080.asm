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
;
; compile with RetroAssembler
; Tab Size = 10
;

.segment "Constants"
crctab	.byte	$00,$00,$00,$00
	.byte	$77,$07,$30,$96
	.byte	$EE,$0E,$61,$2C
	.byte	$99,$09,$51,$BA
	.byte	$07,$6D,$C4,$19
	.byte	$70,$6A,$F4,$8F
	.byte	$E9,$63,$A5,$35
	.byte	$9E,$64,$95,$A3
	.byte	$0E,$DB,$88,$32
	.byte	$79,$DC,$B8,$A4
	.byte	$E0,$D5,$E9,$1E
	.byte	$97,$D2,$D9,$88
	.byte	$09,$B6,$4C,$2B
	.byte	$7E,$B1,$7C,$BD
	.byte	$E7,$B8,$2D,$07
	.byte	$90,$BF,$1D,$91
	.byte	$1D,$B7,$10,$64
	.byte	$6A,$B0,$20,$F2
	.byte	$F3,$B9,$71,$48
	.byte	$84,$BE,$41,$DE
	.byte	$1A,$DA,$D4,$7D
	.byte	$6D,$DD,$E4,$EB
	.byte	$F4,$D4,$B5,$51
	.byte	$83,$D3,$85,$C7
	.byte	$13,$6C,$98,$56
	.byte	$64,$6B,$A8,$C0
	.byte	$FD,$62,$F9,$7A
	.byte	$8A,$65,$C9,$EC
	.byte	$14,$01,$5C,$4F
	.byte	$63,$06,$6C,$D9
	.byte	$FA,$0F,$3D,$63
	.byte	$8D,$08,$0D,$F5
	.byte	$3B,$6E,$20,$C8
	.byte	$4C,$69,$10,$5E
	.byte	$D5,$60,$41,$E4
	.byte	$A2,$67,$71,$72
	.byte	$3C,$03,$E4,$D1
	.byte	$4B,$04,$D4,$47
	.byte	$D2,$0D,$85,$FD
	.byte	$A5,$0A,$B5,$6B
	.byte	$35,$B5,$A8,$FA
	.byte	$42,$B2,$98,$6C
	.byte	$DB,$BB,$C9,$D6
	.byte	$AC,$BC,$F9,$40
	.byte	$32,$D8,$6C,$E3
	.byte	$45,$DF,$5C,$75
	.byte	$DC,$D6,$0D,$CF
	.byte	$AB,$D1,$3D,$59
	.byte	$26,$D9,$30,$AC
	.byte	$51,$DE,$00,$3A
	.byte	$C8,$D7,$51,$80
	.byte	$BF,$D0,$61,$16
	.byte	$21,$B4,$F4,$B5
	.byte	$56,$B3,$C4,$23
	.byte	$CF,$BA,$95,$99
	.byte	$B8,$BD,$A5,$0F
	.byte	$28,$02,$B8,$9E
	.byte	$5F,$05,$88,$08
	.byte	$C6,$0C,$D9,$B2
	.byte	$B1,$0B,$E9,$24
	.byte	$2F,$6F,$7C,$87
	.byte	$58,$68,$4C,$11
	.byte	$C1,$61,$1D,$AB
	.byte	$B6,$66,$2D,$3D
	.byte	$76,$DC,$41,$90
	.byte	$01,$DB,$71,$06
	.byte	$98,$D2,$20,$BC
	.byte	$EF,$D5,$10,$2A
	.byte	$71,$B1,$85,$89
	.byte	$06,$B6,$B5,$1F
	.byte	$9F,$BF,$E4,$A5
	.byte	$E8,$B8,$D4,$33
	.byte	$78,$07,$C9,$A2
	.byte	$0F,$00,$F9,$34
	.byte	$96,$09,$A8,$8E
	.byte	$E1,$0E,$98,$18
	.byte	$7F,$6A,$0D,$BB
	.byte	$08,$6D,$3D,$2D
	.byte	$91,$64,$6C,$97
	.byte	$E6,$63,$5C,$01
	.byte	$6B,$6B,$51,$F4
	.byte	$1C,$6C,$61,$62
	.byte	$85,$65,$30,$D8
	.byte	$F2,$62,$00,$4E
	.byte	$6C,$06,$95,$ED
	.byte	$1B,$01,$A5,$7B
	.byte	$82,$08,$F4,$C1
	.byte	$F5,$0F,$C4,$57
	.byte	$65,$B0,$D9,$C6
	.byte	$12,$B7,$E9,$50
	.byte	$8B,$BE,$B8,$EA
	.byte	$FC,$B9,$88,$7C
	.byte	$62,$DD,$1D,$DF
	.byte	$15,$DA,$2D,$49
	.byte	$8C,$D3,$7C,$F3
	.byte	$FB,$D4,$4C,$65
	.byte	$4D,$B2,$61,$58
	.byte	$3A,$B5,$51,$CE
	.byte	$A3,$BC,$00,$74
	.byte	$D4,$BB,$30,$E2
	.byte	$4A,$DF,$A5,$41
	.byte	$3D,$D8,$95,$D7
	.byte	$A4,$D1,$C4,$6D
	.byte	$D3,$D6,$F4,$FB
	.byte	$43,$69,$E9,$6A
	.byte	$34,$6E,$D9,$FC
	.byte	$AD,$67,$88,$46
	.byte	$DA,$60,$B8,$D0
	.byte	$44,$04,$2D,$73
	.byte	$33,$03,$1D,$E5
	.byte	$AA,$0A,$4C,$5F
	.byte	$DD,$0D,$7C,$C9
	.byte	$50,$05,$71,$3C
	.byte	$27,$02,$41,$AA
	.byte	$BE,$0B,$10,$10
	.byte	$C9,$0C,$20,$86
	.byte	$57,$68,$B5,$25
	.byte	$20,$6F,$85,$B3
	.byte	$B9,$66,$D4,$09
	.byte	$CE,$61,$E4,$9F
	.byte	$5E,$DE,$F9,$0E
	.byte	$29,$D9,$C9,$98
	.byte	$B0,$D0,$98,$22
	.byte	$C7,$D7,$A8,$B4
	.byte	$59,$B3,$3D,$17
	.byte	$2E,$B4,$0D,$81
	.byte	$B7,$BD,$5C,$3B
	.byte	$C0,$BA,$6C,$AD
	.byte	$ED,$B8,$83,$20
	.byte	$9A,$BF,$B3,$B6
	.byte	$03,$B6,$E2,$0C
	.byte	$74,$B1,$D2,$9A
	.byte	$EA,$D5,$47,$39
	.byte	$9D,$D2,$77,$AF
	.byte	$04,$DB,$26,$15
	.byte	$73,$DC,$16,$83
	.byte	$E3,$63,$0B,$12
	.byte	$94,$64,$3B,$84
	.byte	$0D,$6D,$6A,$3E
	.byte	$7A,$6A,$5A,$A8
	.byte	$E4,$0E,$CF,$0B
	.byte	$93,$09,$FF,$9D
	.byte	$0A,$00,$AE,$27
	.byte	$7D,$07,$9E,$B1
	.byte	$F0,$0F,$93,$44
	.byte	$87,$08,$A3,$D2
	.byte	$1E,$01,$F2,$68
	.byte	$69,$06,$C2,$FE
	.byte	$F7,$62,$57,$5D
	.byte	$80,$65,$67,$CB
	.byte	$19,$6C,$36,$71
	.byte	$6E,$6B,$06,$E7
	.byte	$FE,$D4,$1B,$76
	.byte	$89,$D3,$2B,$E0
	.byte	$10,$DA,$7A,$5A
	.byte	$67,$DD,$4A,$CC
	.byte	$F9,$B9,$DF,$6F
	.byte	$8E,$BE,$EF,$F9
	.byte	$17,$B7,$BE,$43
	.byte	$60,$B0,$8E,$D5
	.byte	$D6,$D6,$A3,$E8
	.byte	$A1,$D1,$93,$7E
	.byte	$38,$D8,$C2,$C4
	.byte	$4F,$DF,$F2,$52
	.byte	$D1,$BB,$67,$F1
	.byte	$A6,$BC,$57,$67
	.byte	$3F,$B5,$06,$DD
	.byte	$48,$B2,$36,$4B
	.byte	$D8,$0D,$2B,$DA
	.byte	$AF,$0A,$1B,$4C
	.byte	$36,$03,$4A,$F6
	.byte	$41,$04,$7A,$60
	.byte	$DF,$60,$EF,$C3
	.byte	$A8,$67,$DF,$55
	.byte	$31,$6E,$8E,$EF
	.byte	$46,$69,$BE,$79
	.byte	$CB,$61,$B3,$8C
	.byte	$BC,$66,$83,$1A
	.byte	$25,$6F,$D2,$A0
	.byte	$52,$68,$E2,$36
	.byte	$CC,$0C,$77,$95
	.byte	$BB,$0B,$47,$03
	.byte	$22,$02,$16,$B9
	.byte	$55,$05,$26,$2F
	.byte	$C5,$BA,$3B,$BE
	.byte	$B2,$BD,$0B,$28
	.byte	$2B,$B4,$5A,$92
	.byte	$5C,$B3,$6A,$04
	.byte	$C2,$D7,$FF,$A7
	.byte	$B5,$D0,$CF,$31
	.byte	$2C,$D9,$9E,$8B
	.byte	$5B,$DE,$AE,$1D
	.byte	$9B,$64,$C2,$B0
	.byte	$EC,$63,$F2,$26
	.byte	$75,$6A,$A3,$9C
	.byte	$02,$6D,$93,$0A
	.byte	$9C,$09,$06,$A9
	.byte	$EB,$0E,$36,$3F
	.byte	$72,$07,$67,$85
	.byte	$05,$00,$57,$13
	.byte	$95,$BF,$4A,$82
	.byte	$E2,$B8,$7A,$14
	.byte	$7B,$B1,$2B,$AE
	.byte	$0C,$B6,$1B,$38
	.byte	$92,$D2,$8E,$9B
	.byte	$E5,$D5,$BE,$0D
	.byte	$7C,$DC,$EF,$B7
	.byte	$0B,$DB,$DF,$21
	.byte	$86,$D3,$D2,$D4
	.byte	$F1,$D4,$E2,$42
	.byte	$68,$DD,$B3,$F8
	.byte	$1F,$DA,$83,$6E
	.byte	$81,$BE,$16,$CD
	.byte	$F6,$B9,$26,$5B
	.byte	$6F,$B0,$77,$E1
	.byte	$18,$B7,$47,$77
	.byte	$88,$08,$5A,$E6
	.byte	$FF,$0F,$6A,$70
	.byte	$66,$06,$3B,$CA
	.byte	$11,$01,$0B,$5C
	.byte	$8F,$65,$9E,$FF
	.byte	$F8,$62,$AE,$69
	.byte	$61,$6B,$FF,$D3
	.byte	$16,$6C,$CF,$45
	.byte	$A0,$0A,$E2,$78
	.byte	$D7,$0D,$D2,$EE
	.byte	$4E,$04,$83,$54
	.byte	$39,$03,$B3,$C2
	.byte	$A7,$67,$26,$61
	.byte	$D0,$60,$16,$F7
	.byte	$49,$69,$47,$4D
	.byte	$3E,$6E,$77,$DB
	.byte	$AE,$D1,$6A,$4A
	.byte	$D9,$D6,$5A,$DC
	.byte	$40,$DF,$0B,$66
	.byte	$37,$D8,$3B,$F0
	.byte	$A9,$BC,$AE,$53
	.byte	$DE,$BB,$9E,$C5
	.byte	$47,$B2,$CF,$7F
	.byte	$30,$B5,$FF,$E9
	.byte	$BD,$BD,$F2,$1C
	.byte	$CA,$BA,$C2,$8A
	.byte	$53,$B3,$93,$30
	.byte	$24,$B4,$A3,$A6
	.byte	$BA,$D0,$36,$05
	.byte	$CD,$D7,$06,$93
	.byte	$54,$DE,$57,$29
	.byte	$23,$D9,$67,$BF
	.byte	$B3,$66,$7A,$2E
	.byte	$C4,$61,$4A,$B8
	.byte	$5D,$68,$1B,$02
	.byte	$2A,$6F,$2B,$94
	.byte	$B4,$0B,$BE,$37
	.byte	$C3,$0C,$8E,$A1
	.byte	$5A,$05,$DF,$1B
	.byte	$2D,$02,$EF,$8D

.lib

; entry: hl points to crc
.function CRC_init()
	push	PSW
	push	H
	mvi	A, $FF
	mov	M, A
	inx	H
	mov	M, A
	inx	H
	mov	M, A
	inx	H
	mov	M, A
	pop	H
	pop	PSW
.endfunction

; 32-bit crc routine
; entry: a contains next byte, hl points to crc
; exit:  crc updated
.function CRC_upd()
	push	psw
	push	b
	push	d
	push	h
	push	h
	lxi	d,3
	dad	d	; point to low byte of old crc
	xra	m	; xor with new byte
	mov	l,a
	mvi	h,0
	dad	h	; use result as index into table of 4 byte entries
	dad	h
	xchg
	lxi	h,crctab
	dad	d	; point to selected entry in crctab
	xchg
	pop	h
	lxi	b,$0004	; c = byte count, b = accumulator
@Loop	ldax	d
	xra	b
	mov	b,m
	mov	m,a
	inx	d
	inx	h
	dcr	c
	jnz	@Loop
	pop	h
	pop	d
	pop	b
	pop	psw
.endfunction

; compare crc
; HL points to crc1
; DE points to crc2
; on exit Z is the result of the compare
.function CRC_cmp()
	push	b
	push	d
	push	h
	mvi	b,4
@Loop	ldax	d
	cmp	m
	jnz	@Exit
	inx	h
	inx	d
	dcr	b
	jnz	@Loop
@Exit	pop	h
	pop	d
	pop	b
.endfunction

; entry: hl points to crc
.function CRC_done()
	push	PSW
	push	H
	push	B
	mvi	B, 4
	mvi	C, $FF
@Loop	mov	A, M
	xra	C
	mov	M, A
	inx	H
	dcr	b
	jnz	@Loop
	pop	B
	pop	H
	pop	PSW
.endfunction
