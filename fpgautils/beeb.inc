

beeb:

	LDY #$00
beeb1:
	LDA beebStart,Y
	STA relocate,Y
	INY
	CPY #(beebEnd-beebStart)
	BNE beeb1

	JMP relocate

beebStart:

	LDA #$08
	STA $BFFE
	JMP ($FFFC)

beebEnd: