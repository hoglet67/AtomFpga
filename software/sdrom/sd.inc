;=================================================================
; SD.INC
; v01.00 !!!!!!!!!!! FINAL VERSION FOR SDROM v1 !!!!!!!!!!!!!!!!!!
; v02.00 !!!!!!!!!!! FINAL VERSION FOR SDROM v2 !!!!!!!!!!!!!!!!!!
; v02.10 !!!!!!!!!!! FINAL VERSION FOR SDROM v2.1 !!!!!!!!!!!!!!!!
; v02.20 !!!!!!!!!!! FINAL VERSION FOR SDROM v2.2 !!!!!!!!!!!!!!!!
;=================================================================

;=================================================================
; SD-CARD:
;=================================================================
; The format of the SD-card is:
;
;       sector        Description
;------------------------------------------------------
;      0 -     31    DISKTABLE + DISK INFORMATION TABLE
;     32 -    231    DISK IMAGE 0000
;    232 -    463    DISK IMAGE 0001
;   ..        ..           ..
;   ..        ..           ..
; 104432 - 204631    DISK IMAGE 1022
;
;------------------------------------------------------
; DISKTABLE (16 bytes)
;------------------------------------------------------
;  0,1 - Current diskette number in drive 0
;  2,3 - Current diskette number in drive 1
;  4,5 - Current diskette number in drive 2
;  6,7 - Current diskette number in drive 3
;  8-F - Unused
;------------------------------------------------------
;
;------------------------------------------------------
; DISKINFO TABLE (1023 * 16 bytes)
;------------------------------------------------------
; 0-C - Diskname
; D,E - Unused
; F   - Diskette Status  00 = Read Only
;                        0F = R/W
;                        F0 = Unformatted
;                        FF = No valid diskno.
;------------------------------------------------------
;
;------------------------------------------------------
; SD-CARD CAPACITY
;------------------------------------------------------
; DISKTABLE      :                           16 bytes
; DISKINFO TABLE : 1023 *      16 =      16.368 bytes
; DISK IMAGES    : 1023 * 102.400 = 104.755.200 bytes
;------------------------------------------------------
; Total data     :                  104.771.584 bytes
; Total sectors  :                      204.632 sect
; Total mB       :                          100 mB
;-----------------------------------------------------------------

;===========================================================================
;INIT VARIABLES
;===========================================================================

MOSI        equ $80
CLK         equ $40
CS          equ $20

IFTYPE      equ $22b  ; B - detected interface type 0x80 = PL8, 0x40 = VIA, 0 = none
.IFTRUE INCLUDE_SDHC
CARDTYPE    equ $22c  ; B - detected card type 0x00 = SD, 0x40 = SDHC
.ENDIF
RWTEMP      equ $3d1  ; W - temporary copy of RWLEN used in loadbytes
XBTEMP      equ $3d4  ; [3] - temp storage for XFERBYTE

.IFTRUE INCLUDE_VIA
VIA         equ $b800
XFERV       equ $23e  ; W - transfer byte function vector
.ENDIF

;-----------------------------------------------------------------
; SD_INIT
;
;  Init SD-card
;-----------------------------------------------------------------
;
; called when cold start detected or forced
;
; exits with
;  IFTYPE = 0x80 for PL8
;           0x40 for VIA
;           0    if no interface detected
;
;  XFERV set to point to the appropriate byte xfer routine if interface detected OK
;        set to point to a BRK if not
;
;===========================================================================

sd_init

; the PL8 interface does the card idle initialisation so we can go straight for
; the reset card command(4)1...


.IFTRUE INCLUDE_VIA
           lda #<xferbyte_pl8
           sta XFERV
           lda #>xferbyte_pl8
           sta XFERV+1
.ENDIF
           lda #$80                         ; interface type PL8
           sta IFTYPE
           jsr init_card                    ; carry set if card reset OK

           bcs di_detected

.IFTRUE INCLUDE_VIA
forcevia:
           lda #<xferbyte_via
           sta XFERV
           lda #>xferbyte_via
           sta XFERV+1

           lda #$40                         ; interface type VIA
           sta IFTYPE

           jsr wakemmc_via                  ; initialisation sequence for VIA type interface
           jsr init_card
           bcs di_detected

           lda #<iferr                      ; no interface detected
           sta XFERV
           lda #>iferr
           sta XFERV+1
.ENDIF

           lda #0
           sta IFTYPE

           jmp iferr

di_detected:
           rts

iferr:
           jsr deselectcard
           jsr prttxt
           .db "INTERFACE?"
           nop
           brk

;-----------------------------------------------------------------
; SD_sector_R
;
;   Read sector (512 bytes) sector from SD-card into address RWPTR
;
;   Input : sector = 3 bytes with sector nr
;           RWPTR  = loadaddress
;   Output: -
;-----------------------------------------------------------------

sd_sector_r
           jsr read_start
           ldx #2
           ldy #0
rx1        jsr OSXFERFF
           sta (RWPTR),y
           iny
           bne rx1
           inc RWPTR+1
           dex
           bne rx1
           jmp read_end

;-----------------------------------------------------------------
; SD_sector_W
;
;   Write sector (512 bytes) sector from address RWPTR to SD-card
;
;   Input : sector = 3 bytes with sector nr
;           RWPTR  = loadaddress
;   Output: -
;-----------------------------------------------------------------

sd_sector_w
           jsr write_start
           ldx #2
           ldy #0
wx1        lda (RWPTR),y
           jsr OSXFER
           iny
           bne wx1
           inc RWPTR+1
           dex
           bne wx1
           jmp write_end

;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~
; read_start
;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~

read_start
           jsr sectortocmdbuf

           lda #$40+$11               ; do command $11 - read sector
           jsr sendcommand
           bne notreadyerror

           lda #$fe
           jmp awaitvalue             ; fails with response error

;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~
; read_end
;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~

read_end   jsr OSXFERFF
           jsr OSXFERFF

           jmp deselectcard

;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~
; write_start
;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~

write_start
           jsr sectortocmdbuf

           lda #$40+$18               ; do command $18 - write sector
           jsr sendcommand
           beq bw_isready

           jmp notreadyerror
bw_isready
           lda #$fe
           jmp OSXFER

notreadyerror:
           jsr prttxt
           .db "NOT READY"
           nop
           brk

;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~
; write_end
;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~

write_end
           jsr OSXFERFF
           jsr OSXFERFF

           jsr OSXFERFF

           lda #$FF
           jsr awaitvalue             ; fails with response error
           jsr OSXFERFF               ; finish cycle
           jmp deselectcard

;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~
;
; on entry
;  A = byte to transmit
;
; on exit
;  A = received byte, X,Y preserved
;
xferbyte_pl8:
           sta SPI_PORT
           nop
           nop
           nop
           nop
           nop
           nop
           lda SPI_PORT
           rts

.IFTRUE INCLUDE_VIA

;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~
;
; initiate an spi transfer. this is spi mode 0, where we sample on the rising edge.
; the data bit is already present when we enter here.
;
; on entry
;  A = byte to transmit
;
; on exit
;  A = received byte, Y preserved, X trashed
;
xferbyte_via:
           stx XBTEMP
           sty XBTEMP+1

           ldy #8

xb_xferbit:
           pha

           and #MOSI         ; present data with CS, CLK low
           sta VIA           ; it's necessary to write this before the clock rises
           ora #CLK          ; bring clock high
           sta VIA

           ldx VIA           ; read data

           eor #CLK          ; bring clock low
           sta VIA

           txa               ; rx'd data into carry
           ror a

           pla
           rol a             ; 7<-next bit, 0<-rx'd data

           dey
           bne xb_xferbit

           ldy XBTEMP+1
           ldx XBTEMP
           rts

.ENDIF

;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~
;
; pump up the card
;
;  fails with ERROR, succeeds quietly
;
init_card:
           ldx #1
           stx 4
           lda #0
.IFTRUE INCLUDE_SDHC
           sta CARDTYPE
.ENDIF
           sta $16,x
           sta $25,x
           sta $34,x
           sta $43,x

; send CMD0
           lda #$40
           jsr sendcommand
           cmp #1                  ; expect response 'card gone idle'
           bne ic_noresponse


.IF INCLUDE_SDHC

; After the card enters idle state with a CMD0, send a CMD8 with
; argument of 0x000001AA and correct CRC prior to initialization
; process.

; send CMD8
           lda #$01
           sta $25,x
           lda #$aa
           sta $16,x
           lda #$40 + 8
           ldy #$87
           jsr sendcommand_with_crc

; If the CMD8 is rejected with illigal command error (0x05), the card
; is SDC version 1 or MMC version 3.

           cmp #5
           beq card_type_sd
           cmp #1
           bne ic_noresponse

; If accepted, R7 response (R1(0x01) + 32-bit return value) will be
; returned. The lower 12 bits in the return value 0x1AA means that the
; card is SDC version 2 and it can work at voltage range of 2.7 to 3.6
; volts. If not the case, the card should be rejected.

           jsr OSXFERFF
           jsr OSXFERFF
           jsr OSXFERFF
           cmp #$01
           bne ic_noresponse
           jsr OSXFERFF
           cmp #$AA
           bne ic_noresponse

; And then initiate initialization with ACMD41 with HCS flag (bit
; 30).

           ldy #$00
           sty RWTEMP
           sty $25,x
           sty $16,x

; send ACMD41 with HCS bit set
send_acmd41:
           lda #$00
           sta $43,x
           lda #$40 + 55
           jsr sendcommand

           lda #$40
           sta $43,x
           lda #$40 + 41
           jsr sendcommand
           beq send_cmd58

           dec RWTEMP
           bne send_acmd41
           beq ic_noresponse


card_type_sd:

.ENDIF ; INCLUDE_SDHC

; reset card - try ACMD1 first
           lda #$40+41
           jsr sendcommand
           beq ic_initaccepted

; try CMD1
           lda #0
           sta RWTEMP

ic_sendcmd1:
           lda #$40+1
           jsr sendcommand
           beq ic_initaccepted
           dec RWTEMP
           bne ic_sendcmd1

ic_noresponse:
           clc
           rts

.IFTRUE INCLUDE_SDHC
; After the initialization completed, read OCR register with CMD58 and
; check CCS flag (bit 30). When it is set, the card is a high-capacity
; card known as SDHC/SDXC. The data read/write operations described
; below are commanded in block addressing insted of byte
; addressing. The size of data block at block addressing mode is fixed
; to 512 bytes.

send_cmd58
           lda #$00
           sta $43,x
           lda #$40 + 58
           jsr sendcommand
           bne ic_noresponse
           jsr OSXFERFF
           and #$40
           sta CARDTYPE
           jsr OSXFERFF
           jsr OSXFERFF
           jsr OSXFERFF
.ENDIF

ic_initaccepted:
           sec
           rts

.IFTRUE INCLUDE_VIA

;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~
;
; wakemmc_via
;
; send 80 clock pulses with card deselected. can't use xferbyte as this asserts /cs.
; two things to watch for:
;  ensure clk is low for a wee while before starting the clockings
;  ensure the clocking proceeds at a slow rate, between 100-400 khz.
;
wakemmc_via:
          lda #CS+CLK+MOSI
          sta VIA              ; clk=high, cs=high, mosi=high

          lda #$fe
          sta VIA+2            ; ddrb = %1111-1110. bit 0 input, rest output

          lda #CS+CLK+MOSI
          ldx #CS+MOSI
          ldy #88

wm_clockit:
          sta VIA
          stx VIA
          dey
          bne wm_clockit

          rts
.ENDIF

;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~
;
; transmit a command to the card
;
;  ERROR if status reply not received back from card
;
; on entry
;  A = command to send, command buffer set up appropriately
;  Y = checksum

; on exit
;  A,X,Y trashed
;
sendcommand:
.IFTRUE INCLUDE_SDHC
            ldy #$95
.ENDIF
sendcommand_with_crc:
            pha

            lda IFTYPE
            beq sc_goforth

            jsr selectcard
            jsr OSXFERFF      ; shoot a blank
            pla
            jsr OSXFER        ; command byte
            ldx 4
            lda $43,x         ; pipe out the parameter bytes
            jsr OSXFER
            lda $34,x
            jsr OSXFER
            lda $25,x
            jsr OSXFER
            lda $16,x
            jsr OSXFER
.IFTRUE INCLUDE_SDHC
            tya
.ELSE
            lda #$95         ; dummy checksum, only required for cmd0.
.ENDIF
            jsr OSXFER

; wait to receive a byte with bit 7 clear

            ldy #0

sc_wn:
            dey
            beq sc_ou

            jsr OSXFERFF
            and #$ff
            bmi sc_wn

sc_ou:
            cmp #0
            rts

sc_goforth:
            jmp iferr         ; error0329

;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~
;
; select card
;
selectcard:
            lda #MOSI            ; select card, set MOSI high
            bne cd_setstate      ; always

;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~
;
; deselect card
;
deselectcard:
           lda #MOSI+CS

cd_setstate:
.IFTRUE INCLUDE_VIA
           bit IFTYPE
           bmi sc_pl8
           sta VIA
           ldx #0
           dex
           bne *-1
sc_pl8:
           rts
.ELSE
           and #CS
           bne sc_pl8_deselect
sc_pl8_select:
           sta SPI_PORT + 4 ; CS = 0
           rts
sc_pl8_deselect:
           sta SPI_PORT + 3 ; CS = 1
           rts
.ENDIF

;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~
;
; wait for the card to return a particular value, or report response error
;
awaitvalue:
           ldx #$10
           ldy #0
           sta RWTEMP

av_await:
           dey
           bne av_await2:
           dex
           beq responseerror
av_await2:

           jsr OSXFERFF
           cmp RWTEMP
           bne av_await

           rts

responseerror:
           jsr prttxt                 ; bail if we just can't get it
.IFTRUE INCLUDE_SDHC
           .db "RESP?"
.ELSE
           .db "  RESPONSE ERROR"
.ENDIF
           nop
           brk

;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~;~~
;
; convert lba to byte address of data on card - mul by 512
; buffer is initialised lsb->msb, but is written out in reverse.
; uses the workspace stack
;
sectortocmdbuf:
           ldx 4
           lda sector
.IFTRUE INCLUDE_SDHC
           bit CARDTYPE
           bvs sectortocmdbuf_sdhc
.ENDIF
           asl a
           sta $25,x
           lda sector+1
           rol a
           sta $34,x
           lda sector+2
           rol a
           sta $43,x
           lda #0
           sta $16,x
           rts

.IFTRUE INCLUDE_SDHC
.sectortocmdbuf_sdhc:
           sta $16,x
           lda sector+1
           sta $25,x
           lda sector+2
           sta $34,x
           lda #0
           sta $43,x
           rts
.ENDIF

;-----------------------------------------------------------------------------------
OSXFERFF:
            lda #$ff
OSXFER:
.IFTRUE INCLUDE_VIA
            jmp (XFERV)
.ELSE
            jmp xferbyte_pl8
.ENDIF
