STARHELP:
	jsr print		; Print text
;	       01234567890123456789012345678901
	.byte 13,"BBCMMC ROM V1.0",13
	.byte "  CAT (<FILTER>)",13
	.byte "  EXEC <FILENAME>",13
	.byte "  HELP (<ROM>)",13
	.byte "OS 1.00",13
	NOP
	RTS
