;=================================================================
; Command: MAN [<keyword>]
;
; Opens a manual page and displays its contents
;=================================================================

man:
    lda GodilVersion            ; Test GODIL version is 1x
    and #$F0
    cmp #$10
    bne NoGodil
    lda ModeExtension           ; Test GODIL 80x40 mode
    bpl NoGodil
    lda #$80		            ; Allow lower case characters to be output
    ldy #81
    bne UpdateGodilFlag
NoGodil:
    lda #$00
    ldy #33
UpdateGodilFlag:
    sta GodilFlag
    sty ScreenWidth
    lda attrib                  ; load current video attribute
    sta attribSave              ; save it for later use

    ; Read keyword from command line
    ldx #0                      ; reset x index
    ldy cmdindex                ; load index to command
    dey
man1:
    iny
    lda (cmdpointer),y          ; load character from statement
    cmp #$20                    ; is it a space
    beq man1                    ; yes, read next
    cmp #$0D                    ; is it end of line
    beq man2                    ; yes, execute the statement
    sta dlg_buffer+10,x         ; store in string buffer
    inx                         ; increment x
    cpx #9                      ; check for maximum length
    bmi man1                    ; if less then continue for next character
    brk                         ; generate and error
    
    ; At this point the keyword has been copied into the string buffer. Now
    ; append the extension, or if no keyword was provided append the default
    ; keyword MAN.
man2:
    ldy #4                      ; load pointer
    cpx #0                      ; parameter given?
    bne man3                    ; yes there is, continue
    ldy #7                      ; reload pointer
man3:
    lda manLbl,y                ; load remaining char for filename
    sta dlg_buffer+10,x         ; store in stringbuffer
    inx                         ; increment index
    dey                         ; decrement pointer
    bpl man3                    ; continue if not finished copying
    
    ; Now we have the filename in the string buffer and we're ready to prepend
    ; the path
man4:
    iny                         ; increment pointer (on first run this will become 0)
    lda manPath,y               ; load character of path
    sta dlg_buffer,y            ; store in string buffer
    cpy #9                      ; all done?
    bne man4                    ; no, continue
    
    ; In the stringbuffer is now the absolute path to the manpage file. We can
    ; try to open it.
    lda #<dlg_buffer            ; store filename into zeropage
    sta start
    lda #>dlg_buffer
    sta start+1
    ldx #start                  ; load zeropage address in start
    sec                         ; set carry for opening file in read mode
    jsr OSFIND                  ; open the file
    sta ptr                     ; store file pointer
    cmp #0                      ; test file pointer
    bne manPgMod                ; jump if file is opened
    jsr prttxt                  ; otherwise print error message
    .byte "MAN PAGE NOT FOUND"
    nop
    jmp manEnd
    
    ; save page mode
manPgMod:
    lda pmflag
    sta pmsave
    lda #14
    jsr OSWRCH
    
    ; Dump contents of man file
manRead:
    ldx #0                      ; reset counter
    lda attribSave
    sta attrib
manRead1:
    ldy ptr                     ; load file pointer
    jsr OSBGET                  ; read character
    bcs manPrint0               ; if end of file then goto print routine
    bpl manRead3                ; continue if positive value
    jmp manImage                ; jump to load image
manRead3:
    cmp #$0A                    ; ignore LF 
    beq manRead1
    cmp #$20                    ; ignore spaces at beginning of the line (X=0)
    bne manRead2
    cpx #0
    beq manRead1
manRead2:
    sta dlg_buffer,x            ; store in buffer
    inx                         ; increment counter
    cmp #$0D                    ; test for end-of-line
    beq manPrint                ; go to print routine
    cpx ScreenWidth             ; test for max line length
    bmi manRead1                ; continue with next character
    
manPrint:
    clc                         ; clear carry (it was not end-of-file)
    bcc manPrint1
manPrint0:
    lda #$0D                    ; write an end-of-line to the buffer 
    sta dlg_buffer,x
    inx
manPrint1:
    php                         ; save processor status (carry contains end-of-file flag!)
manPrint2:
    dex                         ; decrement counter, search the last space
    bmi manPrintErr             ; if the line is too long, generate an error
    lda dlg_buffer,x            ; load character
    cmp #$20                    ; is it a space
    beq manPrint3               ; yes, goto print line
    cmp #$0D                    ; is it an end of line
    beq manPrint3               ; yes, goto print line
    jsr manDecPtr
    jmp manPrint2               ; continue search for space
manPrint3:
    lda #$0D
    sta dlg_buffer,x
    stx mem                     ; save length in zero page memory
    ldx #0                      ; reset counter
manPrint4:
    lda dlg_buffer,x            ; load character from buffer
    bit GodilFlag               ; Check if running in 80x40 mode
    bmi manPrint6
    cmp #$60                    ; Mask lower case
    bcc manPrint6
    and #$DF
    jmp manPrint9
manPrint6:
    cmp #96                     ; is it a backtick
    bne manPrint7
    lda attrib                  ; change the attribute
    ora #$08
    sta attrib
    bne manPrint10
manPrint7:
    cmp #32                     ; is it a space
    bne manPrint8
    lda attribSave              ; restore the attribute
    sta attrib
    lda #32
    bne manPrint9
manPrint8:
    cmp #13                     ; it is a crlf
    bne manPrint9
    lda attribSave              ; restore the attribute
    sta attrib
    lda #13
manPrint9:
    jsr OSWRCH                  ; print it
manPrint10:
    inx                         ; increment x
    cpx mem                     ; test on line length
    bmi manPrint4               ; jmp if not end of line
    inx                         ; increment x for next test
    cpx ScreenWidth             ; exactly last position of the line
    beq manPrint5               ; yes, so don't print a new line
    lda attribSave              ; restore the text attribute
    sta attrib
    jsr OSCRLF                  ; print newline
manPrint5:
    plp                         ; restore processor status
    bcs man6                    ; if end-of-file then goto end
    jmp manRead                 ; read next line
    
    ; Close manual page
man6:
    jsr OSSHUT                  ; close the file
    
    
manEnd:
    lda attribSave
    sta attrib
    lda pmsave
    sta pmflag
    jsr OSCRLF                  ; print newline
    jmp $C55B                   ; end of statement

manPrintErr:
    jsr prttxt
    .byte $0D, $0A, "Man page format?", $EA
    jmp man6                    ; end it

manImage:
    ldx ModeExtension           ; save Godil settings
    stx tmpa+2
    ldx VgaCtrl
    stx tmpa+3
    ldx #$00                    ; switch to standard atom vdu
    stx ModeExtension
    stx VgaCtrl

    ldx #$F0                    ; switch to graphics mode
    stx $B000
    ldx #$80                    ; set pointer
    stx tmpa+1
    ldx #0
    stx tmpa
manImage1:
    sta (tmpa,x)                 ; store in memory
    inc tmpa                    ; increment pointer low byte
    bne manImage2
    inc tmpa+1                  ; increment pointer hi byte
    lda tmpa+1                  ; end-of-memory block?
    cmp #$98
    beq manImage3
manImage2:
    jsr OSBGET                  ; read next byte
    bcc manImage1               ; continue if not end-of-file
manImage3:
    jsr OSRDCH                  ; wait for keypress
    ldx tmpa+2                  ; restore Godil settings
    stx ModeExtension
    ldx tmpa+3
    stx VgaCtrl
    lda #12                     ; switch to text mode and clear the screen
    jsr OSWRCH
    jmp man6                    ; close file and end of routine
    
manDecPtr:
    pha                         ; save registers
    txa
    pha
    ldy ptr                     ; load file pointer
    ldx #tmpa                   ; load zp address for data
    lda #0                      ; load command
    jsr OSARG                   ; read current file pointer
    sec                         ; set carry for subtraction
    lda tmpa                    ; subtract 1 from the pointer
    sbc #1
    sta tmpa
    lda tmpa+1                  ; subtract 1 from the pointer
    sbc #0
    sta tmpa+1                  ; we assume a man page not > 64kB so we can quit here
    jsr OSPTR                   ; set new pointer
    pla                         ; restore registers
    tax
    pla
    rts                         ; return
    
    
manLbl:
    .byte $0D, "NAM.NAM"
manPath:
    .byte "/MANPAGES/"