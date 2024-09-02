	icl "..\..\asm\Fixes.asm"

	org $2000

	opt h-
	ins 'D256HZ-Original.xex'
	
	opt h+
	org $2200

	.proc loader
	lda #125
	jsr print_char
	rts

	.proc print_char;IN: <A>=char, changes <A>, <X>, <Y>
	tax
	lda $e407	;Use PUT_CHAR from E: handler
	pha
	lda $e406
	pha
	txa
	rts
	.endp
	.endp

	ini loader
	