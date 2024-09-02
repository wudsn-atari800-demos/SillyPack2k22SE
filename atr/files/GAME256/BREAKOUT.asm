; "Breakout+", Atari XL/XE Game 256B
; code by tr1x / Agenda
; requirements: original Atari XL/XE 64KB PAL
; version: 1.0
; release date: 2022-08-13
;
; levels: EASY, NORMAL, HARD

pmgaddr	equ $5400
dispadr	equ $be70

racketx	equ $0050
ballx	equ $00a7
bally	equ $00a8

sdmctl	equ $022f
stick0	equ $0278
pcolr0	equ $02c0
m0pf	equ $d000
hposp0	equ $d000
hposm0	equ $d004
m0pl	equ $d008
sizep0	equ $d008
colpf0	equ $d016
gractl	equ $d01d
hitclr	equ $d01e
consol	equ $d01f
pmbase	equ $d407
wsync	equ $d40a
vcount	equ $d40b
osgraph	equ $ef9c


	org $0080

	bvc start

ballshp	.byte 0, %01100000, %00001001, 0	; ball's shape
brckofs	.byte $7a, $86, $92, $9e, $aa, $b6, $c2	; bricks' lines offsets
dirstep	.byte $ff, $ff, $01			; , $01
ballofs	.byte 1, 0, 0, 1, 1	; horizontal: 1, 0, 0, 1, vertical: 0, 0, 1, 1
dirh	.byte $01		; horizontal step (1 => +1, $ff => -1)
dirv	.byte $ff 		; vertical step (1 => +1, $ff => -1)

start	lda #$03
	jsr osgraph

	; PMG setup
	;ldx #$03		; not necessary, since X=3 after "jsr osgraph"
	stx gractl
	;ldy #$01		; not necessary, since Y=1 after "jsr osgraph"
	sty sizep0
	lda #$2f
	sta sdmctl
	ldx #>pmgaddr
	stx pmbase

	; draw top horizontal bar and bricks
	;ldx #$54		; not necessary; $54=12*7
loopx1	lda #%10101010
	sta pcolr0-$50,x	; colors of the racket and the ball
	sta dispadr-$02,x	; top horizontal bar
	lsr			; lda #%01010101
	sta dispadr+$0c,x	; bricks
	dex
	bne loopx1

	; draw left and right vertical bars
loopx2	lda #%10000010
	sta dispadr,x
	sta dispadr+$0b,x
	txa
	clc
	adc #$0c
	tax
	cpx #$09
	bcs loopx2

loopx3	lda vcount
	tay

	; rainbow on bricks
	sec
	sbc #$14
	lsr
	ora #%01010000
	sta colpf0
	sta wsync

	tya
	bne loopx3

	; the ball consists of four missiles (m0..m3)
	;  +----+----+
	;  | m1 | m0 |
	;  +----+----+   <- the ball
	;  | m2 | m3 |
	;  +----+----+
	; I use missiles to playfield collisions in order to detect
	; which side a hit came from
	; e.g. if both m0 and m1 detected an obstacle it means the ball
	; hit an object from the bottom
	; e.g. if both m0 and m3 detected an obstacle it means the ball
	; hit an object from the left
	ldx #$03		; Y=0
loopx4	lda m0pf,y
	iny
	pha
	tya
	and #$03
	tay
	pla
	and m0pf,y
	beq skipx2
	sta consol		; sound
	txa
	pha
	lda dirstep,x
	pha
	txa
	and #$01
	tax
	pla
	sta dirh,x
	lda m0pf,y		; if m0pf=1 (bricks)
	lsr
	bne skipx1
	lda ballx
	clc
	adc ballofs,y
	lsr
	lsr
	lsr
	lsr
	pha
	lda bally
	clc
	adc ballofs+1,y
	sec
	sbc #$13
	lsr
	lsr
	tax
	lda brckofs,x
	sta opcodx1+1
	pla
	tax
	lda #$00
opcodx1	sta dispadr+$46,x
skipx1	pla
	tax
skipx2	dex
	bpl loopx4

	; I use missile to player collision in order to detect that the ball
	; hit the racket
	lda m0pl+2
	beq skipx3
	sta consol		; sound
	stx dirv		; X=$ff
skipx3

	sta hitclr		; clear collisions register

	; move the ball horizontally and vertically
	ldx #01
loopx5	
.if .def HARD
	lda #%00111100
.elif .def NORMAL
	lda #%01111110
.else
	lda #%11111111
.endif
	sta pmgaddr+$268,x	; draw racket's shape
	lda dirh,x
	clc
	adc ballx,x
	sta ballx,x
	dex
	bpl loopx5

loopx6	ldy bally
	bmi loopx6		; game over
	ldx #$03
loopx7	lda ballx
	sta hposm0,x		; set ball's horizontal positions
	lda ballshp,x
	sta pmgaddr+$180,y	; draw ball's shape
	iny
	dex
	bpl loopx7

	; joystick
	lda racketx
	ldx stick0
	cpx #$0f
	beq skipx5
	lda #$fd
	cpx #$0b
	beq skipx4
	lda #$02
skipx4	adc racketx
	sta racketx
skipx5	sta hposp0

	jmp loopx3