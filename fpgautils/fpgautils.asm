;----------------------------------------------
;DEMOROM
; Code to demonstrate the structure
; of a #Axxx ROM
;----------------------------------------------
	.DEFINE asm_code $A000
	.DEFINE header   0		; Header Atomulator
	.DEFINE Atom15k  1      ; Assemble for Atom15k or for AtomFpga
	.DEFINE filenaam "FPGAUTIL.ROM"

.org asm_code-22*header

.IF header
;********************************************************************
; ATM Header for Atomulator

name_start:
	.byte filenaam			; Filename
name_end:
	.repeat 16-name_end+name_start	; Fill with 0 till 16 chars
	  .byte $0
	.endrep

	.word start_asm			; 2 bytes startaddress
	.word start_asm			; 2 bytes linkaddress
	.word eind_asm-start_asm	; 2 bytes filelength

;********************************************************************
.ENDIF


exec:
start_asm:
	.include "int.inc"
	.include "fastCRC.inc"
	.include "serial.inc"
	.include "fpgahelp.inc"
	.include "constants.inc"
    .include "man.inc"
	
.IF Atom15k
	.include "vga80.inc"
.ELSE
	.include "roms.inc"
	.include "flash.inc"
	.include "beeb.inc"
	.include "vga80tiny.inc"
.ENDIF
	
	.byte <sinout, >sinout	
	
eind_asm:
