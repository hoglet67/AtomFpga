;=================================================================
; Command: FLASH <Start>,<Bank>
;
; Programs one of the 32 4K pages (banks) in the 128K FLASH Memory
;=================================================================

flash:

	;; Read the Address of the data to program
	JSR read_param
	JSR next_param
	JSR read_param
	JSR next_param

	JSR prttxt
	.byte "PROGRAM BANK "
	NOP

	LDA stack1+1
	STA bank
	JSR prthex

	JSR prttxt
	.byte " FROM "
	NOP

	LDA stack2
	STA src + 1
	JSR prthex
	LDA stack1
	STA src
	JSR prthex
 
	JSR OSCRLF

	JSR prttxt
	.byte "CONFIRM (Y/N)? "
	NOP

	JSR OSRDCH
	CMP #'Y'
	BEQ continue
	
	JSR prttxt
	.byte "N",10,13,"ABORTED",10,13
	NOP
	RTS

continue:

	JSR prttxt
	.byte "Y",10,13,"PROGRAMMING...",10,13
	NOP

	;; Relocate the programming routine to RAM

	LDY #$00
relLoop:
	LDA relCodeStart,Y
	STA relocate,Y
	INY
	CPY #(relCodeEnd-relCodeStart)
	BNE relLoop

	JMP relocate


;; =========================================
;; Macro to initializize a flash command
;; =========================================

.macro flashcmd
	LDA #$05
	STA romlatch
	LDA #$AA
	STA $A555
	LDA #$02
	STA romlatch
	LDA #$55
	STA $AAAA
.endmacro


;; =========================================
;; Start of code that will be relocated to RAM
;; This must be fully relocatable!!
;; =========================================

relCodeStart:

	SEI

;; =========================================
;; Code to Erase the whole page
;; =========================================

flasherase:
	flashcmd
	LDA #$05
	STA romlatch
	LDA #$80
	STA $A555
	flashcmd
	LDA bank
	STA romlatch
	LDA #$30
	STA $A000
	LDY #$00
flasherase1:
	LDX #$00
flasherase2:
	DEX
	BNE flasherase2
	DEY
	BNE flasherase1


;; =========================================
;; Code to Re-program the whole page
;; =========================================

flashprog:
	LDA #<romstart
	STA dst
	LDA #>romstart
	STA dst + 1

	LDY #$00
flashprog1:
	flashcmd
	LDA #$05
	STA romlatch
	LDA #$A0
	STA $A555
	LDA bank
	STA romlatch
	LDA (src),Y
	STA (dst),Y
	LDX #$08
flashprog2:
	DEX
	BNE flashprog2
	INY
	BNE flashprog1
	INC src + 1
	INC dst + 1
	LDA dst + 1
	CMP #>romend
	BNE flashprog1

	; Restore the original value of the ROM Latch
	
	LDA shadowl
	AND #$0F
	STA romlatch	

	CLI

	; Pop the return address from "JSR comint6"
	PLA
	PLA

	; Return directly to the Basic interpreter
	; rather than via the Utility ROM, in case it has been re-written

	LDX #0
	STX $4
	JMP no_com



relCodeEnd:
