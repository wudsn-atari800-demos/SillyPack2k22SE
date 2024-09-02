//------------------------------------------------------------------------
//	grzegorzsun@gmail.com
//  silly invaders a 256b compo game
//------------------------------------------------------------------------
Colpf0   equ $D016;
Colpf1   equ $D017;
Colpf2   equ $D018;
Colpf3   equ $D019; 
COLBAK   equ $D01A; colbak
CONSOL = $d01f

SDMCTL   equ $022f; $D400

WSYNC    equ $D40A
VCOUNT   equ $D40B

GPRIOR   equ $26f; 
;Display Priority
;1 - All players in front of all playfields.
;2 - Players 2 and 3 behind playfields; players 0 and 1 in front of playfields.
;4 - All playfields in front.
;8 - Players in front of some play-fields, but behind others.
GRACTL   equ $D01D; To turn on missiles        1       0      To turn on players         2       1     To latch trigger inputs    4       2
HITCLR   equ $D01E; czyscimy do wykrycia kolizji, np. czysc, rusz joy, sprawdz kolizje
PPLAYER0 equ $D000 ; pozycja gracza 0
SPLAYER0 equ $D008 ; size player0
GPLAYER0 equ $D00D ; rejestr grafiki gracza 0    
CPLAYER0 equ $D012 ; kolor gracza 0 i pocisku 0
SCPLAYER0 equ 704; cieñ koloru 0

PMISS0 = $D004; pozycja missile 0
SMISS = $D00C; szerokosc pociskow

;The fourth section, starting at offset $0180 or $0300 from PMBASE, contains the four missiles; bits 7-6
;correspond to missile 3 and bits 0-1 correspond to missile 0. The last four sections starting at $0200 or $0400
;contain the graphics for players 0-3. Within each section, bits 0-7 or bits 1-7 of the vertical scan counter are used
;as the offset for fetching graphics data.
PMBASE = $D407; 
osgraph	equ $ef9c

;collisions
CP0PF = $D004; odczyt - kolizja player 0 z playfield
CM0PF = $D000; odczyt - kolizka pocisku 0 z playfield

RTCLOCK equ $0012;
RANDOM  equ $D20A

STICK0	EQU $278
;STRIG0
;0 when trigger pressed
;1 when trigger released 
STRIG0	EQU $284
TRIG0  EQU $D010

minx = 44;
maxx = 204;
SCHBASE	= $2f4
CHBASE	= $D409
char   = $a000
players = $3000; $8000;
; offset https://www.atarimagazines.com/compute/issue8/3060_1_THE_ATARI_GAZETTE.php
; double pmbase +384 - missiles, +512 p0, +640 p1, +768 p2, +896 p3 ->1024
; single +768 missiles, +1024 p0 (25, +1280 p1, +1536 p2, +1792 p3 ->2048
player0 = players + 768;
play0 = player0+492; 1260;
miss0 = player0+480;
miss0roll = miss0-100;
; single $0308-$03F7 
missile0 = players+308;
ms0 = missile0;

char_rom = $e000
SAVMSC = $58
ekran = $bc40
ekran2 = $be70;

; SPRITE COLORS 0
COL_0 = $b4
xpos = $83

   org	$80
   
start	
    lda #$02
	jsr osgraph
    lda #$0f
    sta 708; aliens
    
;	ldy #$01		; not necessary, since Y=1 after "jsr osgraph"
    lda #>char
    sta schbase

;pmg
    lda #>players
    sta pmbase
    lda #%00111111; single wide p+m
;    lda #%00111011; single wide p
;    lda #%00111010; single normal p
;    lda #%00111110; single normal p+m
;    lda #%00111001; single narrow p
    sta SDMCTL
    sta GRACTL    

;statek
    lda #col_0
    sta SCPLAYER0

;put some aliens
    ldy #0; 10 po 4
put_lines    
    tya
    and #3
ekr    
    sta $be70,y
    adc #4
ekr2
    sta $be70+24,y
next
    iny
    cpy #22
    bne put_lines

;reshot
    ldy #$ff
loop
    ldx xpos
    stx PPLAYER0
;strzelanie - autofire
;    lda STRIG0
    
;stick
    lda #%00000100; lewo
    bit STICK0
    bne right
    cpx #minx
    beq right
    dex
    
right
    asl @; prawo
    bit STICK0
    bne exit
    cpx #maxx
    beq exit
    inx
    
exit
    stx xpos
    
move_missile
    ldx #3  
put_new_missile
    lda #%00010000
    sta miss0-254,y
    dey
del_old_missile
    lda #0
    sta miss0-250,y
    dex
    bne put_new_missile

;check collisions
    lda CP0PF; $D000
    beq no_collision
;kolizja
;dzwiek
    sta consol
    lda xpos
    lsr @
    lsr @
    lsr @
    lsr @
    lsr @
;uzyskujemy index znaku 1,2,3,4,5    
    sbc #1
    asl @
    asl @
    tax; pozycja znaku w x
    
    lda #0; stawiamy spacje
;sprawdzmy y pocisku, ktora to linia?
    cpy #$48
    bcc line2
    sta $be72+24,x
    sta $be73+24,x
;    jmp pdmissile
    bne pdmissile
line2    
    sta $be72,x
    sta $be73,x
;    sta xpchar; testowo
;delete missile
pdmissile
    ldx #10
;    lda #0; jest wyzej
delmis
    sta miss0-245,y
    dey
    dex
    bne delmis
;restart shoot    
    ldy #$ff
    sta hitclr; kasuj kolizje i zrob cos z tym faktem
;ubite wszystkie obiekty?
    dec aliens
    lda aliens
;    bne no_collision
    beq game_over
no_collision
;clock sync
    lda rtclock+2;
wait
    cmp rtclock+2;
    beq wait  
    bmi loop

;end od game    rts
game_over
;    lda #$02
	jsr osgraph
    sta PPLAYER0

    ldx #6
putgo
    lda go-1,x
    sta $be73+48,x
    sta consol
    dex
    bne putgo
    bpl putgo-2

aliens dta b(10); 10 sztuk obcych
go dta d'sv2022'
; SPRITE 0
    org play0
SHIP
    dta $18, $18, $3c, $7e, $66, $c3, $e7, $a5

    org $a000+16
alien1
	dta $03,$07,$0F,$19,$3F,$1F,$0A,$14
	dta $80,$C0,$E0,$30,$F8,$F0,$50,$28
;	dta $80,$C0,$E0,$30,$F8,$F0,$50,$28
;	dta $03,$07,$0F,$19,$3F,$1F,$0A,$14

    org alien1+32
alien2
	dta $08,$06,$4F,$59,$3F,$0F,$10,$20
	dta $10,$60,$F2,$9A,$FC,$F0,$08,$04
;	dta $10,$60,$F2,$9A,$FC,$F0,$08,$04
;	dta $08,$06,$4F,$59,$3F,$0F,$10,$20
  
;    run start
