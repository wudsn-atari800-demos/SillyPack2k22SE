; "Cactus Billy", Atari XL/XE Game 256B
;
; A tribute to legendary video game "Outlaw".
;
; code by tr1x / Agenda
; requirements: original Atari XL/XE 64KB PAL
; version: 1.0
; release date: 2022-08-13

posy	equ $0001		; Y position of Billy
scradr	equ $be70		; screen address
pmgadr	equ $3800		; PMG address

miny	equ $20
maxy	equ $7a

rtclok	equ $0012
sdmctl	equ $022f
gprior	equ $026f
stick0	equ $0278
pcolr0	equ $02c0
color2	equ $02c6
hposp0	equ $d000
hposp1	equ $d001
hposp2	equ $d002
sizep0	equ $d008
sizep1	equ $d009
consol	equ $d01f
p0pl	equ $d00c
hitclr	equ $d01e
gractl	equ $d01d
random	equ $d20a
pmbase	equ $d407
wsync	equ $d40a
vcount	equ $d40b
osgraph	equ $ef9c
aub	equ $fdfc		; AUB - Alert User with Beep


	org $0080

	bvc start

loser	.byte "haha, loser!"

colors	.byte $ef, $c2, $c2, $c2, $ec, $82, $f8, $00, $f8

legs2	.byte %00100100
	.byte %00110110

billy	.byte %00000000
	.byte %00011000
	.byte %00111110
	.byte %00011100
	.byte %00011000
	.byte %01111110
	.byte %10011001
	.byte %10011001
	.byte %10011001
	.byte %10011001
	.byte %01011010
	.byte %00111100
	.byte %01100110
	.byte %11000011
	.byte %00000000

cactus	.byte %00000101
	.byte %00000101
	.byte %00010111
	.byte %00010100
	.byte %00011100
	.byte %00000100
	.byte %00000100
	.byte %00000100


start	lda #>pmgadr
	sta pmbase
	sta posy
	sta hposp0

start2	lda #$02
	jsr osgraph
	sty gprior
	sty rtclok+2

	ldx #$2a
	stx sdmctl
	stx gractl

	; draw cactuses
	ldy #$1f
loopa1	tya
	lsr
	lsr
	tax
	lda cactus,x
	sta pmgadr+$280+8,y
	sta pmgadr+$280+88,y
	sta pmgadr+$300+8,y
	sta pmgadr+$300+48,y
	sta pmgadr+$380+48,y
	sta pmgadr+$380+88,y
	lda colors,y
	sta pcolr0,y
	dey
	bpl loopa1

	sta hitclr		; clear all player/missile collision registers

loopa2	ldy vcount
	bne loopa2

	; game over, we hit a cactus
	lda p0pl
	beq skipa1
	ldx #$ff-$0b
loopa3	lda loser-($ff-$0b),x
	sta scradr-($ff-$0b)+125,x
	inx
	bne loopa3
	jsr aub			; "!" from "loser" is used for "aub" 
	bne start2

	; draw Billy in current Y position
skipa1	ldy posy
	ldx #$0e
loopa4	cpx #$0e-2
	bcc skipa2
	lda rtclok+2
	and #%00001000
	bne skipa2
	lda legs2-$0e+2,x
	bne skipa3
skipa2	lda billy,x
skipa3	sta pmgadr+$200+0,y
	sta pmgadr+$200+1,y
	lda #$03
	sta sizep1-6,x
	dey
	dey
	dex
	bpl loopa4

	lda #$01
	sta sizep0

	; joystick
	lda posy
	lsr stick0
	bcc skipa4
	cmp #maxy
	beq skipa6
	adc #$04
skipa4	cmp #miny
	beq skipa5
	adc #$fd
skipa5	sta posy
	sta consol		; sound

	; move cactuses
skipa6	lda rtclok+2
	eor #$ff
	asl
	asl
opcoda1	sta hposp1
	bne skipa8

	; random number <1,3>
loopa5	lda random
	and #%00000011
	beq loopa5
	sta opcoda1+1

	; increase cactuses counter
	sec
	ldx #$03
loopa6	lda scradr+16,x
	adc #$00
	cmp #"0"+10
	bcc skipa7
	lda #$00
skipa7	ora #$10
	sta scradr+16,x
	dex
	bpl loopa6

skipa8	jmp loopa2