
              .org $A000
;              .org $A000-22

;****************************************
; Header for Atom emulator Wouter Ras
;		 .db "SDROM           "
;		 .dw $A000
;		 .dw $A000
;		 .dw eind_asm-start_asm
;****************************************

start_asm    
             include math-lib.inc
             include int.inc
             include sd.inc

end_asm

.IFTRUE end_asm<$B000
             .org $AFFF
             RTS
.ENDIF
eind_asm
