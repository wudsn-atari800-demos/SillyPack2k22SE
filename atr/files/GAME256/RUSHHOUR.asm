; "Rush Hour Race", Atari XL/XE Game 256B
;
; code by tr1x / Agenda
; requirements: original Atari XL/XE 64KB PAL
; version: 1.0
; release date: 2022-08-13

; levels: EASY, NORMAL, HARD

dladr	equ $be50		; display list address
scradr	equ $be70		; screen address
pmgadr	equ $3800		; PMG address

posy	equ $6c
posmid	equ $7c
posleft	equ $60
posrght	equ $98

rtclok	equ $0012
sdmctl	equ $022f
gprior	equ $026f
stick0	equ $0278
pcolr0	equ $02c0
color0	equ $02c4
color4	equ $02c8
hposp0	equ $d000
hposp1	equ $d001
grafm	equ $d011
colpf1	equ $d017
colpf2	equ $d018
consol	equ $d01f
p0pl	equ $d00c
hitclr	equ $d01e
gractl	equ $d01d
random	equ $d20a
pmbase	equ $d407
wsync	equ $d40a
vcount	equ $d40b
osgraph	equ $ef9c


	org $0080

	bvc start

adrs	.byte <(pmgadr+$200), >(pmgadr+$200), <(pmgadr+$280), >(pmgadr+$280)
	.byte <(pmgadr+$300), >(pmgadr+$300), <(pmgadr+$380), >(pmgadr+$380)

road	.byte %10100101, %01010101, %11010101, %01010111, %01010101, %01011010
	.byte $00

car	.byte $00
	.byte %01111110
	.byte %11000011
	.byte %11111111
	.byte %01111110
	.byte %01111110
	.byte %11111111
	.byte %11000011
	.byte %01111110

start	lda #$03
	jsr osgraph
	sty gprior

	; set horizontal positions of cars
	iny
	lda #posleft
loopv1	sta hposp1,y
	clc
	adc #$1c
	dey
	bpl loopv1

	; draw a road
	ldy #$f0
loopv2	ldx #$07
	stx dladr+1		; set one line of text mode for score
loopv3	lda road,x
	sta scradr-1,y
	dey
	dex
	bpl loopv3	
	dey
	dey
	bne loopv2

	ldx #$2a
	stx pcolr0
	stx sdmctl
	stx gractl
	lda #>pmgadr
	sta pmbase
	lda #$b5
	sta color4
	lda #$06
	sta color0

	ldy #posy
	bne drawcar

loopv4	ldx vcount
	bne loopv4

	sta hitclr		; clear all player/missile collision registers

	; animation of the road
loopv5	ldy vcount
	tya
	sbc rtclok+2
	and #%00001000
	beq skipv1
	ora #$0f
	bne skipv2
skipv1	ora #$26
skipv2	sta wsync
	sta colpf1
	and #$0f
	sta colpf2
	cpy #$82
	bcc loopv5

	stx consol		; sound

	; joystick
	ldx #posmid
	lda stick0
	eor #%00001111
	beq skipv3		; stick in the upright (neutral) position
	lsr
	lsr
	lsr
	ldx #posrght
	bcc skipv3
	ldx #posleft
skipv3	stx hposp0

	; move cars
	ldy #$64
loopv6
.if .not .def HARD
	lda pmgadr+$280-2+15,y
	sta pmgadr+$280+0+15,y
	lda pmgadr+$300-2+15,y
	sta pmgadr+$300+0+15,y
	lda pmgadr+$380-2+15,y
	sta pmgadr+$380+0+15,y
.else
	lda pmgadr+$280-3+15,y
	sta pmgadr+$280+0+15,y
	lda pmgadr+$300-3+15,y
	sta pmgadr+$300+0+15,y
	lda pmgadr+$380-3+15,y
	sta pmgadr+$380+0+15,y
.endif
	dey
	bpl loopv6

	; score reset, we hit a car
	lda p0pl
	beq skipv4
	lda #adrs
	sta opcodv1+1
	jmp start

	; draw more cars
skipv4	lda rtclok+2
.if .not .def EASY
	and #%00100111
.else
	and #%00010111 
.endif
	bne loopv4

	; random number <0,3>
	lda random
	and #%00000011
	asl
	adc #adrs+2
	sta opcodv1+1

	; draw a car
	ldy #$1c
drawcar	ldx #$08
loopv7	lda car,x
opcodv1	sta (adrs),y
	dey
	dex
	bpl loopv7

	; increase score
	sec
	ldx #$05
loopv8	lda scradr+$f7,x
	adc #$00
	cmp #"0"+10
	bcc skipx4
	lda #$00
skipx4	ora #$10
	sta scradr+$f7,x
	dex
	bpl loopv8

skipa8	jmp loopv4