DATA       = $b500
STATUS     = $b501
DIVIDER_LO = $b502
DIVIDER_HI = $b503

PORTC      = $b002

CLOCK      = 16000000
BAUD       = 115200
DIVIDER    = CLOCK / 4 / BAUD

start      = $80
mem        = $82
ptr		   = $84
crc        = $86
fcrc	   = $88

tmpa       = $8a

read_start_end:
	JSR read_param
	JSR next_param
	JSR read_param
	JSR next_param

	LDA stack1
	STA start
	LDA stack2
	STA start + 1

	LDA stack1 + 1
	STA mem
	LDA stack2 + 1
	STA mem + 1
	RTS

print_fast_crc:
	LDA fcrc + 1
	JSR prthex
	LDA fcrc
	JSR prthex
    JMP OSCRLF

;set_baud:
;    LDA #<DIVIDER
;    STA DIVIDER_LO
;    LDA #>DIVIDER
;    STA DIVIDER_HI
;	RTS

;=================================================================
; Command: BAUD <Baud Rate>
;
; Sets the divider to (CLOCK / 4) / BAUD
;=================================================================


baud:

	JSR read_param
	JSR next_param

	LDA stack1
	STA $53
	LDA stack2
	STA $54
	LDA stack3
	STA $55
	LDA stack4
	STA $56

	LDA #(((CLOCK / 4) >> 0) & 255)
	STA $57
	LDA #(((CLOCK / 4) >> 8) & 255)
	STA $58
	LDA #(((CLOCK / 4) >> 16) & 255)
	STA $59
	LDA #(((CLOCK / 4) >> 24) & 255)
	STA $5a

	LDA #0
	STA $5b
	STA $5c
	STA $5d
	STA $5e

	JSR $C68C
	ROL $57
	ROL $58
	ROL $59
	ROL $5a

	LDA $58
	STA DIVIDER_HI
	JSR prthex
	LDA $57
	STA DIVIDER_LO
	JSR prthex

    JMP OSCRLF


;=================================================================
; Command: CRC <Start>,<End>
;=================================================================

atomCRC:

	JSR read_start_end
	JSR fastCRC
	JMP print_fast_crc


;=================================================================
; Command: UPLOAD <Start>, <End>
;=================================================================

upload:

	JSR read_start_end
	JSR fastCRC
	JSR print_fast_crc

;	JSR set_baud

    LDA start
    STA ptr
    LDA start + 1
    STA ptr + 1

    LDY #$00
upload1:
	LDA STATUS
	AND #$01
    BEQ upload1
    LDA (ptr),Y
	STA DATA        
    INC ptr
    BNE upload2
    INC ptr + 1
upload2:
    LDA ptr
    CMP mem
    BNE upload1
    LDA ptr + 1
    CMP mem + 1
    BNE upload1

	RTS

;=================================================================
; Command: DNLOAD <Start>
;=================================================================

download:	

	jsr read_num

	lda stack1
    STA start    
	lda stack2
    STA start + 1    

    JSR prttxt
    .byte "SEND DATA", 10, 13
	NOP

;	JSR set_baud

    LDA start
    STA mem
    LDA start + 1
    STA mem + 1
    LDY #$00
    STY fcrc
    STY fcrc + 1
waitForFirstByte:
    LDA STATUS
    AND #$02
    BEQ waitForFirstByte
    BNE gotByte
waitForByte:
	LDX #$00
loop:    
    LDA STATUS
    AND #$02
    BNE gotByte
    DEX    
    BNE loop
    DEY    
    BNE loop
    BEQ end
        
gotByte:
    LDY #$00

    LDA PORTC
    EOR #$04
    STA PORTC

    LDX fcrc             ; 3
    LDA fcrc + 1         ; 3
    EOR crcTableLo, X    ; 4*
    STA fcrc             ; 3

    LDA DATA
    STA (mem),Y

    EOR crcTableHi, X    ; 4*
    STA fcrc + 1         ; 3

    INC mem
    BNE waitForByte
    INC mem+1
    BNE waitForByte
end:
    JSR prttxt
    .byte "START: "
	NOP
    LDA start + 1
    JSR prthex
    LDA start
    JSR prthex
    JSR prttxt
    .byte 10, 13, "  END: "
	NOP
    LDA mem + 1
    JSR prthex
    LDA mem
    JSR prthex
	JSR mirrorFastCRC
    JSR prttxt    
    .byte 10, 13, "  CRC: "
	NOP
	JMP print_fast_crc
        

fastCRC:
    LDA start
    STA ptr
    LDA start + 1
    STA ptr + 1
    LDA #$00
    STA fcrc
    STA fcrc + 1
    LDY #$00
fastCRC1:        
    ;;  crc = (crc >> 8) ^ CRCtbl[(crc & 0xFF)] ^ ((b & 0xff) << 8); 
    LDX fcrc             ; 3
    LDA fcrc + 1         ; 3
    EOR crcTableLo, X    ; 4*
    STA fcrc             ; 3
    LDA (ptr),Y          ; 5*
    EOR crcTableHi, X    ; 4*
    STA fcrc + 1         ; 3
        
    INC ptr              ; 3
    BNE fastCRC4         ; 3
    INC ptr + 1          ; 3
fastCRC4:
    LDA ptr              ; 3
    CMP mem              ; 3
    BNE fastCRC1         ; 3
    LDA ptr + 1          ; 3
    CMP mem + 1          ; 3
    BNE fastCRC1         ; 3

mirrorFastCRC:
;; reverse the result bits to get the standard Atom CRC
    LDA fcrc
    JSR mirror
    PHA
    LDA fcrc + 1
    JSR mirror
    STA fcrc
    PLA
    STA fcrc + 1
        
    RTS


mirror:
    LDX #7
mirror1:
    ASL A
    ROR tmpa
    DEX
    BPL mirror1
    LDA tmpa
    RTS

    ;; low byte
crcTableLo:
    .byte $00, $68, $d0, $b8, $a0, $c8, $70, $18
    .byte $40, $28, $90, $f8, $e0, $88, $30, $58
    .byte $80, $e8, $50, $38, $20, $48, $f0, $98
    .byte $c0, $a8, $10, $78, $60, $08, $b0, $d8
    .byte $00, $68, $d0, $b8, $a0, $c8, $70, $18
    .byte $40, $28, $90, $f8, $e0, $88, $30, $58
    .byte $80, $e8, $50, $38, $20, $48, $f0, $98
    .byte $c0, $a8, $10, $78, $60, $08, $b0, $d8
    .byte $00, $68, $d0, $b8, $a0, $c8, $70, $18
    .byte $40, $28, $90, $f8, $e0, $88, $30, $58
    .byte $80, $e8, $50, $38, $20, $48, $f0, $98
    .byte $c0, $a8, $10, $78, $60, $08, $b0, $d8
    .byte $00, $68, $d0, $b8, $a0, $c8, $70, $18
    .byte $40, $28, $90, $f8, $e0, $88, $30, $58
    .byte $80, $e8, $50, $38, $20, $48, $f0, $98
    .byte $c0, $a8, $10, $78, $60, $08, $b0, $d8
    .byte $00, $68, $d0, $b8, $a0, $c8, $70, $18
    .byte $40, $28, $90, $f8, $e0, $88, $30, $58
    .byte $80, $e8, $50, $38, $20, $48, $f0, $98
    .byte $c0, $a8, $10, $78, $60, $08, $b0, $d8
    .byte $00, $68, $d0, $b8, $a0, $c8, $70, $18
    .byte $40, $28, $90, $f8, $e0, $88, $30, $58
    .byte $80, $e8, $50, $38, $20, $48, $f0, $98
    .byte $c0, $a8, $10, $78, $60, $08, $b0, $d8
    .byte $00, $68, $d0, $b8, $a0, $c8, $70, $18
    .byte $40, $28, $90, $f8, $e0, $88, $30, $58
    .byte $80, $e8, $50, $38, $20, $48, $f0, $98
    .byte $c0, $a8, $10, $78, $60, $08, $b0, $d8
    .byte $00, $68, $d0, $b8, $a0, $c8, $70, $18
    .byte $40, $28, $90, $f8, $e0, $88, $30, $58
    .byte $80, $e8, $50, $38, $20, $48, $f0, $98
    .byte $c0, $a8, $10, $78, $60, $08, $b0, $d8

    ;; high byte
crcTableHi:
    .byte $00, $01, $02, $03, $05, $04, $07, $06
    .byte $0b, $0a, $09, $08, $0e, $0f, $0c, $0d
    .byte $16, $17, $14, $15, $13, $12, $11, $10
    .byte $1d, $1c, $1f, $1e, $18, $19, $1a, $1b
    .byte $2d, $2c, $2f, $2e, $28, $29, $2a, $2b
    .byte $26, $27, $24, $25, $23, $22, $21, $20
    .byte $3b, $3a, $39, $38, $3e, $3f, $3c, $3d
    .byte $30, $31, $32, $33, $35, $34, $37, $36
    .byte $5a, $5b, $58, $59, $5f, $5e, $5d, $5c
    .byte $51, $50, $53, $52, $54, $55, $56, $57
    .byte $4c, $4d, $4e, $4f, $49, $48, $4b, $4a
    .byte $47, $46, $45, $44, $42, $43, $40, $41
    .byte $77, $76, $75, $74, $72, $73, $70, $71
    .byte $7c, $7d, $7e, $7f, $79, $78, $7b, $7a
    .byte $61, $60, $63, $62, $64, $65, $66, $67
    .byte $6a, $6b, $68, $69, $6f, $6e, $6d, $6c
    .byte $b4, $b5, $b6, $b7, $b1, $b0, $b3, $b2
    .byte $bf, $be, $bd, $bc, $ba, $bb, $b8, $b9
    .byte $a2, $a3, $a0, $a1, $a7, $a6, $a5, $a4
    .byte $a9, $a8, $ab, $aa, $ac, $ad, $ae, $af
    .byte $99, $98, $9b, $9a, $9c, $9d, $9e, $9f
    .byte $92, $93, $90, $91, $97, $96, $95, $94
    .byte $8f, $8e, $8d, $8c, $8a, $8b, $88, $89
    .byte $84, $85, $86, $87, $81, $80, $83, $82
    .byte $ee, $ef, $ec, $ed, $eb, $ea, $e9, $e8
    .byte $e5, $e4, $e7, $e6, $e0, $e1, $e2, $e3
    .byte $f8, $f9, $fa, $fb, $fd, $fc, $ff, $fe
    .byte $f3, $f2, $f1, $f0, $f6, $f7, $f4, $f5
    .byte $c3, $c2, $c1, $c0, $c6, $c7, $c4, $c5
    .byte $c8, $c9, $ca, $cb, $cd, $cc, $cf, $ce
    .byte $d5, $d4, $d7, $d6, $d0, $d1, $d2, $d3
    .byte $de, $df, $dc, $dd, $db, $da, $d9, $d8

endOfCode:
