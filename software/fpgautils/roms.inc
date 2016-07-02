
roms:


	;; Start by relocating the CRC Routine to RAM

	LDY #0

	;; Copy the CRC tables to RAM
roms1:
	LDA crcTableLo,Y
	STA ramCrcTableLo,Y
	LDA crcTableHi,Y
	STA ramCrcTableHi,Y
	INY
	BNE roms1

	;; Copy the CRC code to RAM
roms2:
	LDA fastCRC,Y
	STA relocate,Y
	INY
	CPY #(fastCRCend - fastCRC)
	BNE roms2

	;; Relocate the absolute reference to the 
	LDA #<ramCrcTableLo
	STA relocate + eor1 + 1 - fastCRC
	LDA #>ramCrcTableLo
	STA relocate + eor1 + 2 - fastCRC
	LDA #<ramCrcTableHi
	STA relocate + eor2 + 1 - fastCRC
	LDA #>ramCrcTableHi
	STA relocate + eor2 + 2 - fastCRC

	;; Setup region to be CRC'd A000->B000
	LDA #$00
	STA start
	STA mem

	LDA #$A0
	STA start + 1
	LDA #$B0
	STA mem + 1

	;; First calculate our own CRC
	LDX #$00
	JSR relocate
	LDA fcrc
	STA mycrc
	LDA fcrc + 1
	STA mycrc + 1

	LDX #$80
roms3:

	; Compute the CRC, bank switching if necessary
	JSR relocate

	; Skip blank slots (CRC=$2A84)
	LDA fcrc
	CMP #$84
	BNE roms4
	LDA fcrc+1
	CMP #$2A
	BEQ roms5

roms4:
	TXA
	AND #$1F
	JSR prthex
	LDA #' '
	JSR OSWRCH
	LDA fcrc+1
	JSR prthex
	LDA fcrc
	JSR prthex
	LDA #' '
	JSR OSWRCH
	
	JSR lookup_crc
	JSR OSCRLF

roms5:
	INX
	CPX #$A0
	BNE roms3

	RTS

lookup_crc:

	LDA fcrc
	CMP mycrc
	BNE lookup_in_table
	LDA fcrc + 1
	CMP mycrc + 1
	BNE lookup_in_table

	JMP print_name_version

lookup_in_table:
	LDA #<known_crc_table
	STA ptr
	LDA #>known_crc_table
	STA ptr +1
	
	LDY #0

lookup_next:
	LDA (ptr), Y
	INY
	CMP fcrc
	BNE nomatch
	LDA (ptr), Y
	CMP fcrc + 1	
	BNE nomatch
	INY

match:
	LDA (ptr), Y
	BEQ return
	JSR OSWRCH
	INY
	BNE match
return:
	RTS

nomatch:
	LDA (ptr), Y
	DEY
	AND (ptr), Y
	INY
	INY
	CMP #$FF
	BEQ match

nomatch_skip1:
	LDA (ptr), Y
	BEQ nomatch_skip2
	INY
	BNE nomatch_skip1

nomatch_skip2:
	INY
	TYA
	CLC
	ADC ptr
	STA ptr
	LDA #$00
	TAY
	ADC ptr + 1
	STA ptr + 1 
	BNE lookup_next

known_crc_table:

;; these are the standard atom ROMs

   	 .word $D67D
	 .byte "ABASIC ORIG", 0

   	 .word $AAA1
	 .byte "AFLOAT ORIG", 0

   	 .word $E386
	 .byte "AKERNEL ORIG", 0

	 .word $4C45
	 .byte "ADOS ORIG",0

;; these are the ones I'm including in the AtomFPGA FLASH ROM
	.word $14F6
	.byte "BBC BASIC 1/4", 0

	.word $E655
	.byte "BBC BASIC 2/4", 0

	.word $DA5C
	.byte "BBC BASIC 3/4", 0

	.word $2B1F
	.byte "BBC BASIC 4/4", 0

	.word $4958
	.byte "AFLOAT PATCHED", 0

	.word $F0B9
	.byte "AKERNEL PATCHED", 0

	.word $982A
	.byte "ATOMMC2 AVR V2.95", 0

	.word $B449
	.byte "SDDOS AVR V3.25", 0

	.word $BE19
	.byte "GAGS V2.3", 0

	.word $EAB4
	.byte "BBC MOS HOGLET V3", 0

;; these are recent builds

	.word $5717
	.byte "SDDOS V3.25", 0

;; These are the ones in the Atom Software Archive

	.word $4B9A
	.byte "ACORN CALC", 0

	.word $5B16
	.byte "ACORN CALC", 0

	.word $B1C5
	.byte "ACORN CALC", 0

	.word $F4E2
	.byte "ACORN CALC", 0

	.word $49F5
	.byte "ACORN DEMO", 0

	.word $B0F1
	.byte "ACORN ED64", 0

	.word $CEFA
	.byte "ACORN ED80", 0

	.word $B326
	.byte "ACORN WORD", 0

	.word $9243
	.byte "AEK MONITOR", 0

	.word $1201
	.byte "AEK SCREEN", 0

	.word $F3E9
	.byte "AEK SCREEN", 0

	.word $7261
	.byte "A&F UTILITY", 0

	.word $E1FB
	.byte "ACE V2.0", 0

	.word $97BE
	.byte "ACE V2.2", 0

	.word $2BBB
	.byte "ACE V3.0", 0

	.word $4234
	.byte "ATOMIC WINDOWS V1.1", 0

	.word $7D81
	.byte "ATOMIC WINDOWS V1.2BD", 0

	.word $CCEB
	.byte "AXR1", 0

	.word $54D4
	.byte "COMBOX", 0

	.word $B2F9
	.byte "DISKROM", 0

	.word $1B3B
	.byte "DISKROM", 0

	.word $CB78
	.byte "DISKROM", 0

	.word $9F4C
	.byte "GAGS V2.4", 0

	.word $6206
	.byte "JOSBOX", 0

	.word $6D90
	.byte "MOUSEBOX V1.01", 0

	.word $C16B
	.byte "PCHARME V1.73", 0

	.word $46E6
	.byte "RXBOX V1.1", 0

	.word $9F75
	.byte "SALFAA V2.6", 0

	.word $5F26
	.byte "SDROM V2.3", 0

	.word $CEE2
	.byte "SDROM V3.24", 0

	.word $B1BD
	.byte "PP SUPERBASIC", 0

	.word $660E
	.byte "PP TOOLBOX", 0

	.word $6C9E
	.byte "PP TOOLBOX", 0

	.word $7049
	.byte "PROCYON DISATOM", 0

	.word $851E
	.byte "PROCYON DISATOM", 0

	.word $0160
	.byte "PSION DEBUG", 0

	.word $129F
	.byte "PSION EDIT", 0

	.word $5B45
	.byte "PSION EDIT", 0

	.word $5BA1
	.byte "PSION EDIT", 0

	.word $4B99
	.byte "ROSS UTILITY", 0

	.word $F545
	.byte "WATFORD WEROM", 0

	.word $F315
	.byte "WILLOW UTILITY V1.1", 0

;; End Delimiter

	.word $FFFF
	.byte "UNKNOWN", 0

