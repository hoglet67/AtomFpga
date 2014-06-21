;=================================================================
; INT.INC
; #Axxx command interpreter
;=================================================================

;=================================================================
; VARIABLE DECLARATION
;=================================================================

stackpointer	= $4		; Standard Atom address
stack1		= $16
stack2		= $25
stack3		= $34
stack4		= $43
tmp_ptr3	= $D5
tmp_ptr5	= $D6
tmp_ptr6	= $D7
shadowl     = $FD		; Shadow ROM Latch

dlg_buffer	= $140

next_param	= $C231		; OS calls
read_text	= $CEB1
read_param	= $C8BC
no_com		= $C558
command_error	= $F926

skip_spc	= $F876

prtdec		= $C589
prttxt		= $F7D1
prtspc		= $F7FD
prthex		= $F802
prtdigit	= $F80B

OSRDCH      = $FFE3
OSWRCH		= $FFF4
OSCRLF      = $FFED

;=================================================================
; ROM IDENTIFIER
;=================================================================

romid:
	.byte $40,$BF

;=================================================================
; COMMAND INTERPRETER
;=================================================================

comint:
	LDX #$FF		; Set up pointers
comint1:
	LDY $5E
	DEY
comint2:
	INX
	INY
comint3:
	LDA com_tab,X		; Lookup command
	BMI comint5
	CMP ($05),Y
	BEQ comint2
comint4:
	INX
	LDA com_tab-1,X
	BPL comint4
	LDA  ($05),Y
	CMP #'.'
	BNE comint1
	INY
	DEX
	BCS comint3
comint5:
	STY $3			; Store addresspointer
	STA $53
	LDA com_tab+1,X
	STA $52
	LDX #0
	STX $4
	JSR comint6		; Execute command
	LDX #0
	STX $4
	JMP no_com
comint6:
	JMP ($0052)

;=================================================================
; STAR-COMMAND INTERPRETER
;=================================================================

star_com:
	LDX #$FF		; Set up pointers
	CLD
star_com1:
	LDY #0
	JSR skip_spc
	DEY
star_com2:
	INY
	INX
star_com3:
	LDA starcom_tab,X	; Look up star-command
	BMI star_com5
	CMP $100,Y
	BEQ star_com2
	DEX
star_com4:
	INX
	LDA starcom_tab,X
	BPL star_com4
	INX
	LDA $100,Y
	CMP #'.'
	BNE star_com1
	INY
	DEX
	BCS star_com3
star_com5:
	STY $9A

	LDY $3			; Save command pointers
	STY tmp_ptr3
	LDY $5
	STY tmp_ptr5
	LDY $6
	STY tmp_ptr6
	LDY #<$100
	STY $5
	LDY #>$100
	STY $6
	LDY $9A
	STY $3

	STA $53			; Execute star command
	LDA com_tab+1,X
	STA $52
	JSR comint6

	LDY tmp_ptr5		; Restore command pointers
	STY $5
	LDY tmp_ptr6
	STY $6
	LDY tmp_ptr3
	STY $3

	LDA #$0D
	STA ($5),Y

	RTS 

;=================================================================
; COMMAND TABLE
;=================================================================

.macro commands
	.byte "UPLOAD"
	.byte >upload,<upload

	.byte "DNLOAD"
	.byte >download,<download

	.byte "FLASH"
	.byte >flash,<flash

	.byte "CRC"
	.byte >atomCRC,<atomCRC

	.byte "BAUD"
	.byte >baud,<baud

	.byte "BEEB"
	.byte >beeb,<beeb

	.byte "FPGAHELP"
	.byte >fpgahelp,<fpgahelp

.endmacro


help_tab:
	; Upload
	.byte "<START>,<END>",0

	; Download
	.byte "<START>",0

	; Flash
	.byte "<START>,<BANK>",0

    ; Crc
	.byte "<START>,<END>",0

    ; Baud
	.byte "<BAUD RATE>",0

	; Beeb
	.byte 0

	; FHELP
    .byte 0

com_tab:

	commands

	.byte >no_com,<no_com 	; No command

; STAR commands

starcom_tab:

	commands

	.byte >command_error,<command_error	; No star commands

;=================================================================
; Read variabele routine
;=================================================================

read_var:
	LDY $3
	JSR skip_spc		; Negeer spaties

	CMP #'A'		; Test of karakter, letter is
	BMI no_var
	CMP #'['
	BPL no_var
	STA stack1

	INY			; Spring naar einde parameter
	STY $3
	JMP next_param
no_var:
	BRK

;=================================================================
; Read number or calculation routine
;=================================================================

read_num:
	JSR read_param		; Lees expressie
	JSR next_param		; Spring naar einde expressie

	LDA stack1		; Zet lo-byte in accu
	LDY #0			; Reset stackpointer
	STY stackpointer
	RTS

;=================================================================
; Read text routine
;=================================================================

read_txt:
	JSR read_text		; Lees string in buffer
copy_text:
	LDX #0			; Kopieer string naar buffer
	LDY #0
next_letter:
	LDA ($52),Y
	STA dlg_buffer,X
	INX
	INY
	CMP #$0D
	BNE next_letter
var_ok:
	JMP next_param		; Spring naar einde string
