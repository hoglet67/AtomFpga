;=================================================================
; Command: SINOUT
;
; Equivalent to SIN and SOUT
;=================================================================

sinout:
	JSR sout

;=================================================================
; Command: SIN
;
; Revector OSRDCH to read from the serial port
;=================================================================

sin:
	LDA #<sinhandler
	STA rdcvec
	LDA #>sinhandler
	STA rdcvec+1
	RTS

sinhandler:
	LDA STATUS
	AND #$02
	BEQ sinhandler
	LDA DATA
	RTS

;=================================================================
; Command: SOUT
;
; Revector OSWRCD to write to the serial port
;=================================================================

sout:
	LDA #<southandler
	STA wrcvec
	LDA #>southandler
	STA wrcvec+1
	RTS

southandler:
	PHA
southandler1:
	LDA STATUS
	AND #$01
	BEQ southandler1
	PLA
	STA DATA
	JMP $FE52

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
; Command: UPLOAD <Start>, <End>
;=================================================================

upload:

	JSR read_start_end
	JSR fastCRC
	JSR print_fast_crc

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

	JSR read_param
	JSR next_param

	lda stack1
	STA start	
	lda stack2
	STA start + 1	

	JSR prttxt
	.byte "SEND DATA", 10, 13
	NOP

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

	LDX fcrc		 ; 3
	LDA fcrc + 1		 ; 3
	EOR crcTableLo, X	 ; 4*
	STA fcrc		 ; 3

	LDA DATA
	STA (mem),Y

	EOR crcTableHi, X	 ; 4*
	STA fcrc + 1		 ; 3

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

	mirrorFastCRC

	JSR prttxt	
	.byte 10, 13, "  CRC: "
	NOP
	JMP print_fast_crc
