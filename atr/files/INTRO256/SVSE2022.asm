//------------------------------------------------------------------------
//	grzegorzsun@gmail.com
//  SV SE 2022
//------------------------------------------------------------------------
Colpf0   equ $D016;
Colpf1   equ $D017;
Colpf2   equ $D018;
Colpf3   equ $D019; 
COLBAK   equ $D01A; colbak
CONSOL = $d01f

SDMCTL  equ $022f; $D400

WSYNC   equ $D40A
VCOUNT  equ $D40B

PPLAYER0 equ $D000 ; pozycja gracza 0
SPLAYER0 equ $D008 ; size player0
GPLAYER0 equ $D00D ; rejestr grafiki gracza 0    
CPLAYER0 equ $D012 ; kolor gracza 0

RTCLOCK  equ $0012;
RANDOM  equ $D20A
sin_t	= $2000 ; <- adres tabicy sinusa (tablica zajmuje 1 stronê pamiêci)
tmp		= $80 ; <- taka zmienna na ZP w której jest 0 na pocz¹tku
cm  = $81
   org	$82
;one line + dma for players
    lsr SDMCTL

;procka zajmuje 25b na ZP albo 27b poza ZP 
;amplituda cosinusa: $00-$20
	ldx #0
;    stx cm
	ldy #0
loop
	txa
	asl @
	adc tmp
	sta tmp
	bvc __1
	inc __1+1
__1	lda #$70 ;<- wartoœæ centruj¹ca (mo¿na zmieniaæ aby przesun¹æ œrodek amplitudy)
a_sin_t equ *+1
	sta sin_t,x
	dey
.IF	a_sin_t<255
	sta (a_sin_t),y
.ELSE
	sta sin_t,y
.ENDIF
	inx
	bpl loop

    ldy #1
    
    sty GPLAYER0;
    sty GPLAYER0+1;
    sty rtclock+2
    dey
    sty splayer0;
    sty splayer0+1;

ef1
   LDA VCOUNT;
   ADC rtclock+2;
   STA CPLAYER0;
   STA PPLAYER0;
   EOR #$FF
   STA CPLAYER0+1;
   STA PPLAYER0+1;
   lda rtclock+2
   bne ef1

vco ;jmp vco
    lda vcount
    bne vco
	tay

next_char
    lda silly_venture,y
    sta font_lo+1

font_lo
	lda $e100 ;charset
    sta wsync
	eor #$ff
    sta GPLAYER0
	sta GPLAYER0+1
	sta GPLAYER0+2
	sta GPLAYER0+3
    sta wsync
;    adc vcount
    lda vcount
    adc rtclock+2
    sta CPLAYER0;
    sta CPLAYER0+1;
    sta CPLAYER0+2;
    sta CPLAYER0+3;
  
	tax
    //color
;    and #$f
;    eor #$ff
;    sta COLBAK
 	lda random
andzik equ*+1   
    and #0
    
    adc sin_t,x
	sta PPLAYER0
    eor #$ff
;    sbc #10
    sta PPLAYER0+1

    adc rtclock+2
    sta PPLAYER0+2
    sta consol;
    eor #$ff
    sta PPLAYER0+3
    
	inc font_lo+1
	lda font_lo+1
	and #7
	bne font_lo

	iny
	cpy #24; ile tekstu
	bne next_char
    
;przelacznik tablicy offsetow pozycji    
    dec cm
    bne loopek
    lda x
    tay ;do licznika offestow tekstu
    
    and #7
    tax
    lda atab,x
    sta andzik
;offset tekstu
    lda next_char+1 
    cmp #<silly_venture
    beq txt2
txt1
    lda #<silly_venture
    bne stta
txt2
    lda #<summer
stta
    sta next_char+1    
    inc x
loopek    
	jmp vco

x       dta $0
atab
        dta 0,8,16,24,32,40,48,64

silly_venture
;spacje
        dta $f6,$f6,$f6,$f6,$f6,$f6
; s i l l y
		dta $98,$48,$60,$60,$c8,$f6,$f6
; v e n t u r e
		dta $b0,$28,$70,$a0,$a8,$90,$28
summer
;spacje
        dta $f6,$f6,$f6,$f6,$f6
;summer
        dta $98,$a8,$68,$68,$28,$90,$f6,$f6
;edition        
        dta $28,$20,$48,$a0,$48,$78,$70,$f6,$f6
