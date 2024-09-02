; 256-byte music intro
; Written by Jakub Husak
; for SillyVenture 2022 Summer Edition
; 256-byte compo
;
; It plays 4-channel music and shows simple random effects.

	org $e4

RANDOM  =	$d20a
AUDC	=	$d201
AUDF	=	$d200
AUDCTL	=	$d208
DMACTL	=	$d400

note	=	712
notecnt	=	$80
notelen	=	$81
notevol	=	$12
tmp	=	710

; offsets
BASS	=	4
SOLO	=	6
PERC	=	0
PAD	=	2

; here the code starts
init
	lda #3
	sta $d20f
	
	lda #124
	sta 19
main

val=*+1
	lda #2
	sta AUDCTL
	eor #$2
	sta val
	clc
	; gfx mode
	adc #1
	jsr $ef90
	sta 20
	; after exit: a=0, x=2
	; x - music counter; 0-255 - whole tact CGda
	tax
	; main melody counter, starts from 56 downwards
	lda #56
	sta notecnt
loop
	; wait for next frame
	; repeat every frame
	txa
	and #7
	bne cont

	; move screen base
	; inc 88

	; decrease solo volume
	dec notevol
	; not needed as note never go to negative value
	;spl
	;inc notevol

	; next noteslot
	dec notelen
	bpl cont
	; note ended, get next one
	lda #6
	sta notevol
	dec notecnt
	bmi main
	ldy notecnt ; for  future needs
	lda themenotes,y
	; store note length - 1
	and #$7
	sta notelen

	; every frame
cont
	ldy notecnt ; for  future needs
	lda themenotes,y
	lsr
	lsr
	lsr
	tay
	;vibrato to 1
	txa
	and #2
	clc
	; get note pitch
	adc themenotevalues,y
	sta AUDF+SOLO
	lda notevol
	ora #$a0
	; play solo and pads
	sta AUDC+SOLO
	sta AUDC+PAD

	lda 19
	bpl end

	txa
	and #7
	eor #7
	sta tmp
	; bass control
	ora #$c0
	sta AUDC+BASS

	txa
	; draw some bytes at random places
	;ldy RANDOM
	;sta(88),y
	; get bass for quarter
	and #$c0
	asl
	rol
	rol
	tay
	lda bassnotes,y
	sta AUDF+BASS
	sta note
	; and pads
	lda padnotes,y
	sta AUDF+PAD

	; perc
	txa
	and #$08
	bne n1
	txa
	and #$10
	eor #$10
	sta AUDF+PERC
	lda tmp
	bpl n2a
n1
	lda tmp
	cmp #7
	seq
	lda #0
n2
	sta AUDF+PERC
n2a
	sta AUDC+PERC
end
	inx
	ldy RANDOM
	sta(88),y
	lda:cmp:req 20
	lda #33
	sta DMACTL
	jmp loop
	

bassnotes	dta	51,67,45,61
themenotes
	dta	0*8+1, $5*8+6, $4*8+0, $5*8+1, $4*8+0, $5*8+1, $5*8+0, $4*8+1, $5*8+1, $2*8+1, $2*8+2, $1*8+0, $3*8+1, $3*8+1

	dta	$2*8+3, $1*8+1, $0*8+1, $1*8+2, $3*8+0, $2*8+1, $2*8+3, $1*8+1, $2*8+1, $2*8+1, $2*8+2, $1*8+0, $3*8+1, $3*8+3

	dta	$2*8+1, $1*8+1, $5*8+2, $5*8+0, $4*8+1, $5*8+1, $4*8+0, $5*8+1, $5*8+0, $4*8+1, $5*8+1, $2*8+3, $1*8+1, $3*8+1, $3*8+0, $3*8+1, $3*8+0

	dta	$0*8+6, $1*8+1, $3*8+0, $2*8+1, $2*8+3, $1*8+1, $2*8+6, $1*8+0, $3*8+1, $3*8+2, $3*8+0
themenotevalues
	dta 	113,94,83,74,62,55
padnotes
	dta 	192,255,170,152
	

	run init

