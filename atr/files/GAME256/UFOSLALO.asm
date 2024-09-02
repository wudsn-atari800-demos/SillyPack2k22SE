; "UFO Slalom", Atari XL/XE Game 256B
;
; code by tr1x / Agenda
; requirements: original Atari XL/XE 64KB PAL
; version: 1.0
; release date: 2022-08-13

; levels: EASY, NORMAL, HARD

gate	equ $0000		; layout of gates is a barrier
posy	equ $0001		; Y position of UFO
bcntr	equ $0002		; UFO shape, reverse bit order, loop counter
btemp	equ $0003		; UFO shape, reverse bit order, temp
starpos	equ $2000		; positions of stars
scradr	equ $bc40		; screen address
pmgadr	equ $4200		; PMG address

miny	equ $18
maxy	equ $f6

rtclok	equ $0012
sdmctl	equ $022f
stick0	equ $0278
pcolr0	equ $02c0
color2	equ $02c6
hposp0	equ $d000
hposp1	equ $d001
hposp2	equ $d002
hposm0	equ $d004
grafm	equ $d011
consol	equ $d01f
p2pl	equ $d00e
hitclr	equ $d01e
gractl	equ $d01d
random	equ $d20a
pmbase	equ $d407
wsync	equ $d40a
vcount	equ $d40b


	org $0080

	bvc start

colors	.byte $2c, $2c, $36, $42, $00, $f8

ufoleft	.byte $00, $00, $00
	.byte %00000001
	.byte %00000010
	.byte %00000100
	.byte %00000100
	.byte %00011110
	.byte %00111111
	.byte %01101111
	.byte %01111101
	.byte %00111111
	.byte %00001111
	.byte $00, $00, $00

start	lda #>pmgadr
	sta hposp1
	sta pmbase
	sta posy

start2	ldx #$3a
	stx hposp0
	stx gractl
	stx sdmctl

	; initialization of positions of stars
	ldx #$00
	stx rtclok+2
	stx hposp2
loopx2	lda random
	sta starpos,x
	lda #$00
	sta scradr,x
	dex
	bne loopx2

	sta hitclr		; clear all player/missile collision registers

	; stars animation
loopx3	ldx vcount
	bne loopx3
	lda #%01010101
	sta grafm
loopx4	dec starpos,x
	lda starpos,x	
	ldy #$02
	sta wsync
loopx5	sta hposm0+1,y
	asl
	dey
	bpl loopx5
	dex
	bne loopx4

	sta consol		; sound

	; game over, we hit a barrier
	lda p2pl
	beq skipx1
	sta grafm
loopx6	lda rtclok+2
	sta color2
	sta consol		; sound
	bne loopx6
	beq start2

	; draw UFO in current Y position
skipx1	ldy posy
	ldx #$0f
loopx7	lda #$08
	sta bcntr
	lda ufoleft,x
	sta pmgadr+$200,y
	sta btemp
loopx8:	lsr btemp
	rol
	dec bcntr
	bne loopx8
	sta pmgadr+$300,y
	lda colors,x
	sta pcolr0,x
	dey
	dex
	bpl loopx7

	; joystick
	lda stick0
	eor #%00001111
	beq skipx3		; stick in the upright (neutral) position
	lsr
.if .def HARD
	lda #$02
.else
	lda #$03
.endif
	bcc skipx2
.if .def HARD
	lda #$fd
.else
	lda #$fc
.endif
skipx2	adc posy
	cmp #maxy
	beq skipx3
	cmp #miny
	beq skipx3
	sta posy

	; move a barrier
skipx3	lda rtclok+2
	eor #$ff
	asl
.if .not .def EASY
	asl
.else
	nop
.endif
	sta hposp2
	bne skipx6

	sta grafm		; hide stars for a while to avoid glitches

	; increase barrier counter
	sec
	ldx #$03
loopx9	lda scradr+36,x
	adc #$00
	cmp #"0"+10
	bcc skipx4
	lda #$00
skipx4	ora #$10
	sta scradr+36,x
	dex
	bpl loopx9

	; draw a barrier with random gates
	lda random
	and #%01100000
	sta gate
 	ldy #$00
loopx10	ldx #$00
	tya
	and #%01100000
	cmp gate
	beq skipx5
	ldx #$5a
skipx5	txa
	sta pmgadr+$400,y
	dey 
	bne loopx10

skipx6	jmp loopx3