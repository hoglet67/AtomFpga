;=================================================================
; Constants used by oswrch80
;=================================================================

; GODIL related addresses
GODIL         = $BDE0

DefaultAttrib = $17

ModeExtension = GODIL + 0
CursorCol     = GODIL + 2
CursorRow     = GODIL + 3
VgaCtrl       = GODIL + 4
GodilVersion  = GODIL + 15


; Workspace
vduque   = $4e0
ctrlcode = vduque+0
quelen   = vduque+1
queue    = vduque+2
attrib   = vduque+15
topY     = vduque+16
rightX   = vduque+17
bottomY  = vduque+18
leftX    = vduque+19

; MOS Entry addresses
WRCVEC = $0208
RDCVEC = $020A

NUMROWS = 40
NUMCOLS = 80

SCREEN = $8000
SCREENEND = SCREEN + (NUMROWS - 1) * NUMCOLS

; Send character in accumulator to the VIA
LFEFB = $FEFB

; Wait 0.1 second for debounce
LFB8A = $fB8A
	
; Scan keyboard	
LFE71 = $FE71

; Keyboard Control Code Handlers
; use Kernel for all except cursor handling (FDA2)
LFD9A = $FD9A
LFDAE = $FDAE
LFDC0 = $FDC0
LFDC2 = $FDC2
LFDC6 = $FDC6
LFDC8 = $FDC8
LFDD2 = $FDD2
LFDD6 = $FDD6
LFDD8 = $FDD8
LFDDF = $FDDF
LFDE2 = $FDE2

; Flyback
LFE66 = $FE66
LFE6B = $FE6B

