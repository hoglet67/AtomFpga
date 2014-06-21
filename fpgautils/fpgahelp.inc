fpgahelp:

		JSR prttxt
		
		.byte "HOGLET'S ATOMFPGA UTILS V0.12",10,13
		NOP


		LDX #0
		LDY #0

help1:
		LDA #32
		JSR OSWRCH

help2:
		LDA com_tab,X
		BMI help3
		JSR OSWRCH
		INX
		BNE help2

help3:
		LDA #32
		JSR OSWRCH
help4:
		LDA help_tab,Y
	   	BEQ help5
		JSR OSWRCH
		INY
		BNE help4

help5:
		JSR OSCRLF
		INY
		INX
		INX
		LDA com_tab,X
		BPL help1

		JSR prttxt
		
		.byte "E.G. FLASH #8200,1",10,10,13
		NOP

		RTS
