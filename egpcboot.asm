;"Pokekon" BIOS disassembly & comments by Chris Covell

#include "gamepock.asm"

; This is a disassembly of the Epoch Game Pocket Computer's BIOS ROM.
; The BIOS is internal to the uPD78c06 CPU, but is completely accessible to
; all game ROMs, and provides vital support functions for games (reading
; the joypad, updating the LCD, offering music-playing routines...)
;
; Not all of the functions of the BIOS are understood, but a good many
; of them have been documented.  Much of the ROM space is taken up by
; the internal demonstration, puzzle, and "paint" programs of the Pokekon
; so it is not relevant to game programmers, necessarily.
;
; I can't guarantee that this disassembly is completely error-free, so
; bear with me.  Many thanks to Judge, the Guru, and John Dyer for their help!

;General BIOS breakdown:
;0000 - 007F:  Startup Routine
;0080 - 00EF:  CPU CALT Table
;00F0 - 018D:  INTT (timer) Routine
;018E - 0277:  Support Routines
;0278 - 057E:  Data (music/font/text)
;057F - 05D0:  Main (Demo) Loop
;05D1 - 06EB:  Paint Program
;06EC - 089C:  Puzzle Program
;089D - 0FFB:  Support Routines & Subroutines
;------------------------------------------------------------
;                  EPOCH GAME MASK ROM
;------------------------------------------------------------

#bankdef rom
{
    addr = 0x0000
    size = 0x1000
    outp = 0
}

reset:
    nop
    di
    jr cont
;------------------------------------------------------------
INT0:
    jmp CART.INT0
    nop
;------------------------------------------------------------
INTT:
    jre timer
;------------------------------------------------------------
;((HL-) ==> (DE-))xB
; Copies the data pointed to by HL "(HL)" to (DE).
; B holds a single byte for the copy loop count.
memrcpy:
    ldax [hl-]
    stax [de-]
    dcr b
    jr memrcpy
    ret
    nop
;------------------------------------------------------------
INT1:
    jmp CART.INT1
;------------------------------------------------------------
cont:
    lxi sp, $0000
    per                                             ;Set Port E to AB mode
    mvi a, $C1
    mov pa, a
    ani pa, !LCD.RW
    ori pa, LCD.RW
    calt ACCCLR                                     ; "Clear A"
    mov mb, a                                       ;Mode B = All outputs
    ori pa, LCD.CS1 | LCD.CS2 | LCD.CS3

    mvi a, LCD.I.ON                                 ; All LCDs: turn on
    mov pb, a
    ori pa, LCD.E
    ani pa, !LCD.E
    mvi a, LCD.I.START |  LCD.I.P1                  ; All LCDs: show page 1 first
    mov pb, a
    ori pa, LCD.E
    ani pa, !LCD.E
    ani pa, !LCD.CS1 & !LCD.CS2 & !LCD.CS3
    ori pa, LCD.DI
    mvi a, $07
    mov tmm, a                                      ;Timer register = #$7
    mvi a, $74
    mov tm0, a                                      ;Timer option reg = #$74
    calt SCR1CLR                                    ; "Clear Screen RAM"
    calt OBJCLR                                     ; "Clear C4B0~C593"
    calt WRAMCLR                                    ; "Clear C594~C86F?"
    lxi hl, CART_FLAGS
    mvi b, $49
    calt MEMCLR                                     ; "Clear RAM (HL+)xB"
    calt SCRN2LCD                                   ; Copy Screen RAM to LCD Driver
    mvi a, $05
    mov mk, a                                       ;Mask = IntT,1 ON
    ei
    calt CARTCHK                                    ; [PC+1] Check Cartridge
    db $C0                                          ;Jump to ($4001) in cartridge
    jmp startup                                     ;Flow continues if no cartridge is present.
;------------------------------------------------------------
;(DE+)-(HL+) ==> A
; Loads A with (DE), increments DE, then subtracts (HL) from A and increments HL.
memsub:
    ldax [de+]
    subx [hl+]
    ret
;------------------------------------------------------------
;?? (Find 1st diff. byte in (HL),(DE)xB)  (Matching byte perhaps?)
; I don't know how useful this is, but I guess it's for advancing pointers to
; the first difference between 2 buffers, etc.
memcmp:
    calt MEMSUB                                     ; "(DE+)-(HL+) ==> A"
    sknz
    jr .a0068
    ret

.a0068:
    dcr b
    jr memcmp
    xra a, a
    ret
;------------------------------------------------------------
;?? (Find diff. & Copy bytes)
; I have no idea what purpose this serves...
memccpy:
    push hl
    push de
    push bc
    calt MEMCMP                                     ; "?? (Find 1st diff. byte in (HL),(DE)xB)"
    pop bc
    pop de
    pop hl
    sknc
    jr .a007E
    ret

.a007E:
    calt MEMCOPY                                    ; "((HL+) ==> (DE+))xB"
    ret

;------------------------------------------------------------
;This is the call table provided by the CALT instruction in the uPD78xx CPU.
;It provides a way for programs to call commonly-used routines using a single-byte opcode.
;The numbers in the parentheses refer to the opcode for each entry in the table.
;Each table entry contains an address to jump to.  (Quite simple.)

;Opcodes $80-$AD point to routines hard-coded in the uPD78c06 CPU ROM.
;Opcodes $AE-$B7 point to cartridge ROM routines (whose jump tables are at $4012-$402F.)

; "[PC+X]" means the subroutine uses the bytes after its call as parameters.
; the subroutine then usually advances the return address by X bytes before returning.

    dw cartchk   ;[PC+1] Check Cartridge
    dw scrn2lcd  ;Copy Screen RAM to LCD Driver
    dw sndplay   ;[PC+2] Setup/Play Sound
    dw musplay   ;Setup/Play Music
    dw joyread   ;Read Controller FF90-FF95
    dw accclr    ;Clear A
    dw scr2clr   ;Clear Screen 2 RAM
    dw scr1clr   ;Clear Screen RAM
    dw objclr    ;Clear C4B0~C593
    dw wramclr   ;Clear C594~C7FF
    dw memclr    ;Clear RAM (HL+)xB
    dw addrhlde  ;HL <== HL+DE
    dw addrhli   ;[PC+1] HL +- byte
    dw addrhle   ;HL <== HL+E
    dw scrnswap  ;Swap C258+ <==> C000+
    dw scr1copy  ;C000+ ==> C258+
    dw scr2copy  ;C258+ ==> C000+
    dw scrncomp  ;CALT 00A0, CALT 00A4
    dw objdraw   ;?? (Move some RAM around...)
    dw multiply  ;HL <== AxE
    dw xchghlde  ;XCHG HL,DE
    dw memcopy   ;((HL+) ==> (DE+))xB
    dw memrcpy   ;((HL-) ==> (DE-))xB
    dw memswap   ;((HL+) <==> (DE+))xB
    dw drawdot   ;Set Dot; B,C = X-,Y-position
    dw drawline  ;[PC+2] Draw Horizontal Line
    dw drawhex   ;[PC+3] Print Bytes on-Screen
    dw drawtext  ;[PC+3] Print Text on-Screen
    dw fontget   ;Byte -> Point to Font Graphic
    dw scr1loc   ;Set HL to screen (B,C)
    dw tileloc   ;HL=C4B0+(A*$10)
    dw memset    ;A ==> (HL+)xB
    dw niblswap  ;(RLR A)x4
    dw memsub    ;(DE+)-(HL+) ==> A
    dw memcmp    ;?? (Find 1st diff. byte in (HL),(DE)xB)
    dw memccpy   ;?? (Find diff. & Copy bytes)
    dw arithmtc  ;[PC+1] 8~32-bit Add/Subtract (dec/hex)
    dw tileinv   ;[PC+1] Invert 8 bytes at (C4B0+A*$10)
    dw scr1inv   ;Invert Screen RAM (C000~)
    dw scr2inv   ;Invert Screen 2 RAM (C258~)
    dw caltd0    ;[PC+1] ?? (Unpack 8 bytes -> 64 bytes (Twice!))
    dw caltd2    ;[PC+1] ?? (Unpack & Roll 8 bits)
    dw caltd4    ;[PC+1] ?? (Roll 8 bits -> Byte?)
    dw caltd6    ;[PC+x] ?? (Add/Sub multiple bytes)
    dw membump   ;[PC+1] INC/DEC Range of bytes from (HL)
    dw erasdot   ;Clear Dot; B,C = X-,Y-position

    dw CART.USER0  ;Jump table for cartridge routines
    dw CART.USER1
    dw CART.USER2
    dw CART.USER3
    dw CART.USER4
    dw CART.USER5
    dw CART.USER6
    dw CART.USER7
    dw CART.USER8
    dw CART.USER9

;-----------------------------------------------------------
;                        Timer Interrupt
timer:
    oniw [CART_FLAGS], $01
    jre .a015B

    dcrw [$FF9A]
    jre .done

    push va
    ldaw [$FF8F]
    staw [$FF9A]
    dcrw [$FF99]
    jre .inctime

    push bc
    push de
    push hl
    mvi a, $03
    mov tmm, a                                      ;Adjust timer
    mvi a, $53

.a010F:
    dcr a
    jr .a010F
    oniw [CART_FLAGS], $02
    jr .a011C

    lhld [MUSIC_PTR]
    calf a08A9                               ;Music-playing code...
    jr .a0128

.a011C:
    aniw [CART_FLAGS], $fc
    mvi a, $07
    mov tmm, a
    mvi a, $74
    mov tm0, a
    stm

.a0128:
    pop hl
    pop de
    pop bc

.inctime:
    ldaw [TIME.BCD.SUB]
    adi a, $01
    daa
    staw [TIME.BCD.SUB]
    sknc
    jr ..sec
    jr ..user

..sec:
    inrw [TIME.SEC]
    nop
    ldaw [TIME.BCD.SEC]
    adi a, $01
    daa
    staw [TIME.BCD.SEC]
    sknc
    jr ..hun
    jr ..user

..hun:
    ldaw [TIME.BCD.HUN]
    adi a, $01
    daa
    staw [TIME.BCD.HUN]

..user:
    oniw [$FF8A], $80
    inrw [$FF8A]
    inrw [$FF8B]
    nop
    pop va

;--------
.done:
    ei
    reti
;------------------------------------------------------------
.a015B:
    push va
    push bc
    push de
    push hl
    offiw [CART_FLAGS], $80                         ;If 0, don't go to cart's INT routine
    jmp CART.INTT
;---------------------------------------
    adc a, b                                        ;Probably a simple random-number generator.
    adc a, c
    adc a, d
    adc a, e
    adc a, h
    adc a, l
    staw [$FF8C]
    ral
    ral
    mov b, a
    pop de
    push de
    adc a, e
    staw [$FF8D]
    rar
    rar
    adc a, b
    staw [$FF8E]
    jre .a0128

;------------------------------------------------------------
;[PC+2] Setup/Play Sound
; 1st byte is sound pitch (00[silence] to $25); 2nd byte is length.
; Any pitch out of range could overrun the timers & sap the CPU.
sndplay:
    di
    pop hl
    ldax [hl+]                                      ;(PC+1)
    mov b, a
    ldax [hl+]                                      ;(PC+1)
    push hl
    staw [$FF99]
    calf a08B6                                      ;Set note timers
    jr a01A3
;------------------------------------------------------------
;Setup/Play Music
;HL should already contain the address of the music data.
;Format of the data string is the same as "Play Sound", with $FF terminating the song.
musplay:
    di
    oriw [CART_FLAGS], $02
    calf a08A9                                      ;Read notes & set timers
a01A3:
    ei                                              ;(sometimes skipped)
    ret
;------------------------------------------------------------
;[PC+1] Check Cartridge
; Checks if the cart is present, and possibly jumps to ($4001) or ($4003)
; The parameter $C0 sends it to $4001, $C1 to $4003, etc...
cartchk:
    lxi hl, CART.HEADER
    ldax [hl]
    eqi a, CART.MAGIC
    rets

    calt ACCCLR                                     ; "Clear A"
    staw [TIME.SEC]
.a01B0:
    ldax [hl]
    eqi a, CART.MAGIC
    rets
;----------------------------------
    eqiw [TIME.SEC], $03
    jr .a01B0

    calf a0E4D                                      ;Sets a timer
    oriw [CART_FLAGS], $80
    inx hl                                          ;->$4001
    pop bc
    ldax [bc]
.a01C1:
    nei a, $C0                                      ;To cart if it's $C0
    jr .a01C8

    inx hl                                          ;->$4003
    inx hl
    dcr a
    jr .a01C1

.a01C8:
    ldax [hl+]
    mov c, a
    ldax [hl]
    mov b, a
    jb
;-----------------------------------------------------------
;CALT 00A0, CALT 00A4
; Copies the 2nd screen to the screen buffer & moves some text around
; And updates the LCD...
scrncomp:
    calt SCR2COPY                                   ; "C258+ ==> C000+"
    calt OBJDRAW                                    ; "?? (Move some RAM around...)"
;-----------------------------------------------------------
;Copy Screen RAM to LCD Driver
; A very important and often-used function.  The LCD won't show anything without it...

    ;Set up writing for LCD controller #1
scrn2lcd:
.lcd1:
    ori pa, LCD.CS1                                 ;Select LCD chip 1
    lxi hl, SCR1.LCD1_START
    lxi de, SCRN.WIDTH + LCD.WIDTH
    mvi b, LCD.I.P1 | 0
..nextpage:
    ani pa, !LCD.DI                                 ;Switch to instruction mode
    mov a, b
    mov pb, a                                       ;Select next page
    ori pa, LCD.E                                   ;Send instruction...
    ani pa, !LCD.E                                  ;...with falling edge of E
    mvi c, LCD.WIDTH - 1
    ori pa, LCD.DI                                  ;Switch to data mode
..nextcol:
    ldax [hl-]                                      ;Screen data...
    mov pb, a                                       ;...to Port B
    ori pa, LCD.E                                   ;Send data...
    ani pa, !LCD.E                                  ;...with falling edge of E
    dcr c
    jr ..nextcol
    calt ADDRHLDE                                   ; "HL <== HL+DE"
    mov a, b
    adinc a, LCD.I.POFF
    jr .lcd2
    mov b, a
    jre ..nextpage

    ;Set up writing for LCD controller #2
.lcd2:
    ani pa, !LCD.CS1                                ;Deselect LCD chip 1
    ori pa, LCD.CS2                                 ;Select LCD chip 2
    lxi hl, SCR1.LCD2_START
    lxi de, SCRN.WIDTH - LCD.WIDTH
    mvi b, LCD.I.P1 | 0
..nextpage:
    ani pa, !LCD.DI
    mov a, b
    mov pb, a
    ori pa, LCD.E
    ani pa, !LCD.E
    mvi c, LCD.WIDTH - 1
    ori pa, LCD.DI
..nextcol:
    ldax [hl+]
    mov pb, a
    ori pa, LCD.E
    ani pa, !LCD.E
    dcr c
    jr ..nextcol
    calt ADDRHLDE                                   ; "HL <== HL+DE"
    mov a, b
    adinc a, LCD.I.POFF
    jr .lcd3
    mov b, a
    jre ..nextpage

.lcd3:
    calt ACCCLR                                     ; "Clear A"
    staw [$FF96]

    ;Set up writing for LCD controller #3
    ani pa, !LCD.CS2                                ;Deselect LCD chip 2
    ori pa, LCD.CS3                                 ;Select LCD chip 3
    lxi hl, SCR1.LCD3A_START
    lxi de, SCR1.LCD3B_START
    mvi b, LCD.I.P1 | 0
..nextpage:
    ani pa, !LCD.DI
    mov a, b
    mov pb, a
    ori pa, LCD.E
    ani pa, !LCD.E
    nop
    ori pa, LCD.DI

..nexthalf:
    mvi c, (LCD.WIDTH / 2) - 1

..nextcol:
    ldax [hl+]
    mov pb, a
    ori pa, LCD.E
    ani pa, !LCD.E
    dcr c
    jr ..nextcol

    push de
    lxi de, LCD.WIDTH
    calt ADDRHLDE                                   ; "HL <== HL+DE"
    pop de
    calt XCHGHLDE                                   ; "XCHG HL,DE"
    inrw [$FF96]                                    ;Skip if a carry...
    offiw [$FF96], $01                              ;Do alternating lines
    jr ..nexthalf

    mov a, b
    adinc a, LCD.I.POFF
    jr .done
    mov b, a
    jre ..nextpage

.done:
    ani pa, !LCD.CS3                                ;bit 5 off
    ret

;-----------------------------------------------------------
    ;Sound note and timer data...
a0278:
    #d8 $B2, $0A  ; 0 = silent
    #d8 $EE, $07  ; 1 = G3
    #d8 $E1, $08  ; 2 = G#3
    #d8 $D4, $09  ; 3 = A3
    #d8 $C8, $09  ; 4 = A#3
    #d8 $BD, $0A  ; 5 = B3
    #d8 $B2, $0A  ; 6 = C4
    #d8 $A8, $0B  ; 7 = C#4
    #d8 $9E, $0C  ; 8 = D4
    #d8 $96, $0C  ; 9 = D#4
    #d8 $8D, $0D  ; 10 = E4
    #d8 $85, $0E  ; 11 = F4
    #d8 $7E, $0F  ; 12 = F#4
    #d8 $77, $10  ; 13 = G4
    #d8 $70, $11  ; 14 = G#4
    #d8 $6A, $12  ; 15 = A4
    #d8 $64, $13  ; 16 = A#4
    #d8 $5E, $14  ; 17 = B4
    #d8 $59, $15  ; 18 = C5
    #d8 $54, $16  ; 19 = C#5
    #d8 $4F, $17  ; 20 = D5
    #d8 $4A, $19  ; 21 = D#5
    #d8 $46, $1A  ; 22 = E5
    #d8 $42, $1C  ; 23 = F5
    #d8 $3E, $1E  ; 24 = F#5
    #d8 $3B, $1F  ; 25 = G5
    #d8 $37, $22  ; 26 = G#5
    #d8 $34, $23  ; 27 = A5
    #d8 $31, $26  ; 28 = A#5
    #d8 $2E, $28  ; 29 = B5
    #d8 $2C, $2A  ; 30 = C6
    #d8 $29, $2D  ; 31 = C#6
    #d8 $27, $2F  ; 32 = D6
    #d8 $25, $31  ; 33 = D#6
    #d8 $23, $34  ; 34 = E6
    #d8 $21, $37  ; 35 = F6
    #d8 $1F, $3B  ; 36 = F#6
    #d8 $1D, $3F  ; 37 = G6

;-----------------------------------------------------------
    ;Graphic Font Data
a02C4:
    #d incbin("font.1bpp")[3999+480:480]

;-----------------------------------------------------------
    ;Text data
a04B8:
    #d8 $2C, $23, $24, $00, $24, $2F, $34, $00, $2D, $21, $34, $32, $29, $38, $00, $33  ;LCD DOT MATRIX SYSTEM
    #d8 $39, $33, $34, $25, $2D, $00, $26, $35, $2C, $2C, $00, $27, $32, $21, $30, $28  ;FULL GRAPHIC
    #d8 $29, $23, $00, $08, $17, $15, $0A, $16, $14, $00, $24, $2F, $34, $33, $09, $00  ;(75*64 DOTS)
    #d8 $00, $00, $00, $FF

    ; Music notation data:
    ;     |: zCFA | c2 c2 c2 c2 | E2 E2    F2 (3FGF | B2 B2 A2 A2 |
    ;     G4 zCFA | c2 c2 c2 c2 | E2 (3EFE F2 (3FGF | G2 G2 C2 DE |
    ;     F6 z2 | z6 :|
a04EC:
    #d8 PITCH.NONE, 10, PITCH.C4, 10, PITCH.F4, 10, PITCH.A4, 10
    #d8 PITCH.C5, 20, PITCH.C5, 20, PITCH.C5, 20, PITCH.C5, 20
    #d8 PITCH.E4, 20, PITCH.E4, 20, PITCH.F4, 20, PITCH.F4, 7, PITCH.G4, 7, PITCH.F4, 7
    #d8 PITCH.AS4, 20, PITCH.AS4, 20, PITCH.A4, 20, PITCH.A4, 20
    #d8 PITCH.G4, 40, PITCH.NONE, 10, PITCH.C4, 10, PITCH.F4, 10, PITCH.A4, 10
    #d8 PITCH.C5, 20, PITCH.C5, 20, PITCH.C5, 20, PITCH.C5, 20
    #d8 PITCH.E4, 20, PITCH.E4, 7, PITCH.F4, 7, PITCH.E4, 7
    #d8 PITCH.F4, 20, PITCH.F4, 7, PITCH.G4, 7, PITCH.F4, 7
    #d8 PITCH.G4, 20, PITCH.G4, 20, PITCH.C4, 20, PITCH.D4, 10, PITCH.E4, 10
    #d8 PITCH.F4, 60
    #d8 PITCH.NONE, 80
    #d8 $FF

    ;Text data
str_cursor:
    #d8 $27, $32, $21, $0E, $00, $38, $10, $10, $0C, $39, $10, $10  ;GRA. X00,Y00
.len = ($ - str_cursor)`4

str_puzzle:
    #d8 $30, $35, $3A, $3A, $2C, $25                ;PUZZLE
.len = ($ - str_puzzle)`4

str_time:
    #d8 $34, $29, $2D, $25, $1B, $10, $10, $10, $0E, $10  ;TIME:000.0
.len = ($ - str_time)`4

    ;Grid data, probably
a055D:
    #d8 $04, $04, $08, $01, $01, $08, $04, $04, $08, $01, $01, $02, $04, $04, $02, $01
    #d8 $01, $02

a056F:
    #d8 $08, $04, $02, $04, $08, $08, $08, $01, $02, $01, $08, $04, $02, $02, $04, $02
;-----------------------------------------------------------
;from 005C -

startup:
    calt SCR2CLR                                    ;Clear Screen 2 RAM
    staw [$FFD8]                                    ;Set mem locations to 0
    staw [$FF82]
    staw [$FFA5]
    lxi hl, a04B8                                   ;Start of scrolltext
    shld [$FFD6]                                    ;Save pointer
    calf a0D68                                      ;Setup RAM vars
    calt SCR2COPY                                   ; "C258+ ==> C000+"
    calt SCRN2LCD                                   ;Copy Screen RAM to LCD Driver
.a0591:
    calt ACCCLR                                     ; "Clear A"
    staw [$FFDA]
    staw [$FFD1]
    staw [$FFD2]
    staw [$FFD5]
    mvi a, $FF
    staw [$FFD0]
    lxi hl, $FFD8
    xrax [hl]                                       ;A=$FF XOR ($FFD8)
    staw [$FFD8]
.a05A5:
    mvi a, $60                                      ;A delay value for the scrolltext
    staw [$FF8A]

;Main Loop starts here!
.a05A9:
    calt CARTCHK                                    ;[PC+1] Check Cartridge
    db $C1                                          ;Jump to ($4003) in cartridge

    offiw [CART_FLAGS], $02                         ;If bit 1 is on, no music
    jr .a05B2
    calf a0E64                                      ;Point HL to the music data
    calt MUSPLAY                                    ;Setup/Play Music
.a05B2:
    calt JOYREAD                                    ;Read Controller FF90-FF95
    neiw [JOY.BTN.CURR], JOY.BTN.SEL                ;If Select is pressed...
    jmp puzzle                                      ;Setup puzzle
    neiw [$FFD2], $0F
    jre .a0591                                      ;(go to main loop setup)
    calf a0D1F                                      ;Draw spiral dot-by-dot
    calf a0D1F                                      ;Draw spiral dot-by-dot
    calt SCR2COPY                                   ; "C258+ ==> C000+"
    calt SCRN2LCD                                   ;Copy Screen RAM to LCD Driver
    neiw [JOY.BTN.CURR], JOY.BTN.STA                ;If Start is pressed...
    jr paint                                        ;Jump to graphic program

    eqiw [$FF8A], $80                               ;Delay for the scrolltext
    jre .a05A9                                      ;JRE Main Loop
    calf a0CE2                                      ;Scroll Text routine
    jre .a05A5                                      ;Reset scrolltext delay...

;-----------------------------------------------------------
;"Paint" program setup routines
paint:
    calf a0E4D                                      ;Turn timer on
    calt SCR2CLR                                    ; "Clear Screen 2 RAM"
    calt OBJCLR                                     ; "Clear C4B0~C593"
    lxi hl, str_cursor                              ;"GRA"
    calt DRAWTEXT                                   ; "[PC+3] Print Text on-Screen"
    db $02, $00, $1 @ str_cursor.len                ;Parameters for the text routine
.clear:
    mvi a, %101                                     ; a=5
    lxi hl, PAINT.CURSOR.TILE + 8
    stax [hl+]
    inx hl
    stax [hl]
    inr a                                           ; a=6 (PAINT.LEFT - 1)
    lxi hl, PAINT.CURSOR.SPRITE.X
    stax [hl+]
    inr a                                           ; a=7 (PAINT.LEFT)
    staw [PAINT.CURSOR.X]
    mvi a, $39                                      ; a=57 (PAINT.BOTTOM - 2)
    stax [hl+]
    inr a                                           ; a=58 (PAINT.BOTTOM - 1)
    staw [PAINT.CURSOR.Y]
    calt ACCCLR                                     ; "Clear A"
    stax [hl+]
    staw [PAINT.CURSOR.BCD.X]                       ;X,Y position for cursor
    staw [PAINT.CURSOR.BCD.Y]
    mvi a, $99                                      ;Marker for no sprite?
    mvi b, $0A
    inx hl
    inx hl
.a05FE:
    stax [hl+]                                      ;Clear remaining 11 sprites
    inx hl
    inx hl
    dcr b
    jr .a05FE
    calf a0D68                                      ;Draw Border

.loop:
    mvi a, $70
    staw [$FF8A]
    lxi hl, PAINT.CURSOR.BCD.X                      ;Print the X-, Y- position
    calt DRAWHEX                                    ; "[PC+3] Print Bytes on-Screen"
    db $26, $00, $19                                ;Parameters for the print routine
    lxi hl, PAINT.CURSOR.BCD.Y
    calt DRAWHEX                                    ; "[PC+3] Print Bytes on-Screen"
    db $3E, $00, $19                                ;Parameters for the print routine
    calt SCRNCOMP                                   ; "CALT A0, CALT A4"
.a0618:
    calt CARTCHK                                    ;[PC+1] Check Cartridge
    db $C1                                          ;Jump to ($4003) in cartridge

    oniw [$FF8A], $80
    jr .a0618
    lxi hl, PAINT.CURSOR.SPRITE.TILE
    ldax [hl]
    xri a, $FF
    stax [hl]
    calt JOYREAD                                    ;Read Controller FF90-FF95
    ldaw [JOY.BTN.CURR]
    offi a, JOY.BTN.ANY                             ;Test Buttons 1,2,3,4
    jr .input.btn
    ldaw [JOY.DIR.CURR]
    offi a, JOY.DIR.ANY                             ;Test U,D,L,R
    jre .input.joy
    jre .loop

.input:
..btn:
;------------------------------------------------------------
    oniw [JOY.BTN.EDGE], JOY.BTN.STA | JOY.BTN.SEL
    jr ..button1
    eqi a, JOY.BTN.STA                              ;Start clears the screen
    jr ..select

    calt SNDPLAY                                    ;[PC+2] Setup/Play Sound
    db PITCH.E6, $03
    jre .clear                                      ;Clear screen

..select:
    eqi a, JOY.BTN.SEL                              ;Select goes to the Puzzle
    jr ..button1

    calt SNDPLAY                                    ;[PC+2] Setup/Play Sound
    db PITCH.F6, $03
    jre a06EE                                       ;To Puzzle Setup

..button1:
    eqi a, JOY.BTN.BT1                              ;Button 1
    jr ..button2
    calt SNDPLAY                                    ;[PC+2] Setup/Play Sound
    db PITCH.G5, $03
    jr ..erasedot                                   ;Clear a dot

..button2:
    eqi a, JOY.BTN.BT2                              ;Button 2
    jr ..button3
    calt SNDPLAY                                    ;[PC+2] Setup/Play Sound
    db PITCH.A5, $03
    jr ..erasedot                                   ;Clear a dot

..button3:
    eqi a, JOY.BTN.BT3                              ;Button 3
    jr ..button4
    calt SNDPLAY                                    ;[PC+2] Setup/Play Sound
    db PITCH.B5, $03
    jr ..drawdot                                    ;Set a dot

..button4:
    eqi a, JOY.BTN.BT4                              ;Button 4
    jre ..up.error
    calt SNDPLAY                                    ;[PC+2] Setup/Play Sound
    db PITCH.C6, $03
    jr ..drawdot                                    ;Set a dot

..erasedot:
    ldaw [PAINT.CURSOR.X]
    mov b, a
    ldaw [PAINT.CURSOR.Y]
    mov c, a
    calt ERASDOT                                    ; "Clear Dot; B,C = X-,Y-position"
    jr ..joy

..drawdot:
    ldaw [PAINT.CURSOR.X]
    mov b, a
    ldaw [PAINT.CURSOR.Y]
    mov c, a
    calt DRAWDOT                                    ; "Set Dot; B,C = X-,Y-position"

..joy:
..up:
    ldaw [JOY.DIR.CURR]
    nei a, JOY.DIR.ANY                              ;Check if U,D,L,R pressed at once??
    jre .loop
    oni a, JOY.DIR.UP                               ;Up
    jr ..down

    ldaw [PAINT.CURSOR.Y]
    nei a, PAINT.TOP                                ;Check lower limits of X-pos
...error:
    jr ..down.error

    dcr a
    staw [PAINT.CURSOR.Y]
    dcr a
    mov [PAINT.CURSOR.SPRITE.Y], a
    ldaw [PAINT.CURSOR.BCD.Y]
    adi a, $01
    daa
    staw [PAINT.CURSOR.BCD.Y]
    calt SNDPLAY                                    ;[PC+2] Setup/Play Sound
    db PITCH.C5, $03
    jr ..right

..down:
    oni a, JOY.DIR.DN                               ;Down
    jr ..right

    ldaw [PAINT.CURSOR.Y]
    nei a, PAINT.BOTTOM - 1                         ;Check lower cursor limit
...error:
    jr ..right.error

    inr a
    staw [PAINT.CURSOR.Y]
    dcr a
    mov [PAINT.CURSOR.SPRITE.Y], a
    ldaw [PAINT.CURSOR.BCD.Y]
    adi a, $99                                      ; BCD "-1"
    daa
    staw [PAINT.CURSOR.BCD.Y]
    calt SNDPLAY                                    ;[PC+2] Setup/Play Sound
    db PITCH.D5, $03

..right:
    ldaw [JOY.DIR.CURR]
    oni a, JOY.DIR.RT                               ;Right
    jr ..left

    ldaw [PAINT.CURSOR.X]
    nei a, PAINT.RIGHT - 1
...error:
    jr ..left.error

    inr a
    staw [PAINT.CURSOR.X]
    dcr a
    mov [PAINT.CURSOR.SPRITE.X], a
    ldaw [PAINT.CURSOR.BCD.X]
    adi a, $01
    daa
    staw [PAINT.CURSOR.BCD.X]
    calt SNDPLAY                                    ;[PC+2] Setup/Play Sound
    db PITCH.F5, $03
..loop2:
    jre .loop

..left:
    oni a, JOY.DIR.LT                               ;Left
    jre .loop
    ldaw [PAINT.CURSOR.X]
    nei a, PAINT.LEFT
...error:
    jr ..error

    dcr a
    staw [PAINT.CURSOR.X]
    dcr a
    mov [PAINT.CURSOR.SPRITE.X], a
    ldaw [PAINT.CURSOR.BCD.X]
    adi a, $99                                      ; BCD "-1"
    daa
    staw [PAINT.CURSOR.BCD.X]
    calt SNDPLAY                                    ;[PC+2] Setup/Play Sound
    db PITCH.E5, $03
..loop3:
    jr ..loop2
;------------------------------------------------------------
..error:
    calt SNDPLAY                                    ;[PC+2] Setup/Play Sound
    db PITCH.G3, $03
    jr ..loop3

;------------------------------------------------------------
;Puzzle Setup Routines...
puzzle:
    calf a0E4D                                      ;Reset the timer?
a06EE:
    mvi a, $21
    mvi b, $0A
    calf a0E67                                      ;LXI H,$C7F2
.a06F4:
    stax [hl+]
    inr a                                           ;Set up the puzzle tiles in RAM
    dcr b
    jr .a06F4
    mov a, b                                        ;$FF
    stax [hl+]
    calf a0E67
    mvi b, $0B
    lxi de, $C75E
    calt MEMCOPY                                    ; "((HL+) ==> (DE+))xB"
    mvi b, $0B
    lxi hl, $C75E
    lxi de, $C752
    calt MEMCOPY                                    ; "((HL+) ==> (DE+))xB"
    calt SCR2CLR                                    ; "Clear Screen 2 RAM"
    calf a0D68                                      ;Draw Border
    calf a0D92                                      ;Draw the grid
    calf a0C7B                                      ;Write "PUZZLE"
.a0712:
    aniw [TIME.SEC], $00
.a0715:
    mvi a, $60
    staw [$FF8A]
.a0719:
    calt CARTCHK                                    ;[PC+1] Check Cartridge
    db $C1                                          ;Jump to ($4003) in cartridge
;------------------------------------------------------------
    mvi b, $0B
    lxi hl, $C752
    lxi de, $C7F2
    calt MEMCOPY                                    ; "((HL+) ==> (DE+))xB"
    mvi b, $11
    lxi hl, a055D                                   ;Point to "grid" data
.a0729:
    ldax [hl+]
    push bc
    push hl
    calf a0DD3                                      ;This probably draws the tiles
    nop                                             ;Or randomizes them??
    pop hl
    pop bc
    dcr b
    jr .a0729
    mvi b, $0B
    calf a0E67                                      ;LXI H,$C7F2
    lxi de, $C752
    calt MEMCOPY                                    ; "((HL+) ==> (DE+))xB"
    calt JOYREAD                                    ;Read Controller FF90-FF95
    neiw [JOY.BTN.CURR], JOY.BTN.SEL                ;Select
    oniw [JOY.BTN.EDGE], JOY.BTN.SEL                ;Select trigger
    jr .a074D
.a0747:
    calt SNDPLAY                                    ;[PC+2] Setup/Play Sound
    db PITCH.D5, $03
    jmp paint                                       ;Go to Paint Program
.a074D:
    neiw [JOY.BTN.CURR], JOY.BTN.STA                ;Start
    oniw [JOY.BTN.EDGE], JOY.BTN.STA
    jr .a0758
.a0754:
    calt SNDPLAY                                    ;[PC+2] Setup/Play Sound
    db PITCH.E5, $03
    jr .a0765
;------------------------------------------------------------
.a0758:
    eqiw [$FF8A], $80
    jre .a0719                                      ;Draw Tiles
    eqiw [TIME.SEC], $3C
    jre .a0715                                      ;Reset timer?
    jmp startup                                     ;Go back to startup screen(?)
;------------------------------------------------------------
.a0765:
    calt SCR2CLR                                    ; "Clear Screen 2 RAM"
    lxi hl, str_time                                ;"TIME"
    calt DRAWTEXT                                   ; "[PC+3] Print Text on-Screen"
    db $0E, $00, $1 @ str_time.len
    lxi hl, TIME.BCD.HUN
    mvi b, $02
    calt MEMCLR                                     ; "Clear RAM (HL+)xB"
    ldaw [$FF8C]
    ani a, $0F
    mov b, a
    lxi hl, a056F
.a077B:
    ldax [hl+]
    push bc
    push hl
    calf a0DD3                                      ;Draw Tiles
    nop
    pop hl
    pop bc
    dcr b
    jr .a077B
    calf a0D68                                      ;Draw Border (again)
    calf a0D92                                      ;Draw the grid (again)
    calf a0C82                                      ;Scroll text? Write time in decimal?
.a078F:
    mvi a, $60
    staw [$FF8A]
.a0793:
    calt CARTCHK                                    ;[PC+1] Check Cartridge
    db $C1                                          ;Jump to ($4003) in cartridge
;------------------------------------------------------------
    lxi hl, TIME.BCD.HUN
    calt DRAWHEX                                    ; "[PC+3] Print Bytes on-Screen"
    db $2C, $00, $12
    lxi hl, TIME.BCD.SUB
    calt DRAWHEX                                    ; "[PC+3] Print Bytes on-Screen"
    db $44, $00, $08
    calt SCR2COPY                                   ; "C258+ ==> C000+"
    calt SCRN2LCD                                   ;Copy Screen RAM to LCD Driver
    calt JOYREAD                                    ;Read Controller FF90-FF95
    neiw [JOY.BTN.CURR], JOY.BTN.SEL                ;Select
    jre .a0747                                      ;To Paint Program
    neiw [JOY.BTN.CURR], JOY.BTN.STA                ;Start
    oniw [JOY.BTN.EDGE], JOY.BTN.STA                ;Start trigger
    jr .a07B4
    jre .a0754                                      ;Restart puzzle
;------------------------------------------------------------
.a07B4:
    eqiw [$FF8A], $80
    jre .a0793
    ldaw [JOY.DIR.CURR]                             ;Joypad
    oni a, $0F
.a07BD:
    jre .a078F                                      ;Keep looping
    calf a0DD3                                      ;Draw Tiles
    jr .a07C6
;------------------------------------------------------------
    calt SNDPLAY                                    ;[PC+2] Setup/Play Sound
    db PITCH.G3, $03
.a07C5:
    jr .a07BD
;------------------------------------------------------------
.a07C6:
    push va
    mvi a, $03
    staw [$FF99]
    di
    calf a08B6                                      ;Play Music (Snd)
    ei
    lxi hl, $C7FE
    ldax [hl+]
    mov b, a
    ldax [hl-]
    lta a, b
    jr .a07DD
    mov b, a
    ldax [hl]
.a07DD:
    push bc
    eqiw [$FFA2], $00
    jre .a0823
    calf a0CBF                                      ;Write Text(?)
    inx hl
    calt DRAWLINE                                   ; "[PC+2] Draw Horizontal Line"
    db $00, $8E
    calf a0C77                                      ;HL + $3C
    push hl
    calt DRAWLINE                                   ; "[PC+2] Draw Horizontal Line"
    db $F0, $0E
    pop hl
    calt DRAWLINE                                   ; "[PC+2] Draw Horizontal Line"
    db $F0, $8E
    calf a0C77                                      ;HL + $3C
    calt DRAWLINE                                   ; "[PC+2] Draw Horizontal Line"
    db $1F, $0F
    pop bc
    mov a, b
    calf a0CBF                                      ;Write Text(?)
    calt DRAWLINE                                   ; "[PC+2] Draw Horizontal Line"
    db $F0, $0F
    calf a0C77                                      ;HL + $3C
    push hl
    calt DRAWLINE                                   ; "[PC+2] Draw Horizontal Line"
    db $0F, $0E
    pop hl
    calt DRAWLINE                                   ; "[PC+2] Draw Horizontal Line"
    db $0F, $8E
    mvi e, $41
    calt ADDRHLE                                    ; "HL <== HL+E"
    pop va
    push hl
    calt FONTGET                                    ;Byte -> Point to Font Graphic
    pop de
    mvi b, $04
.a081B:
    ldax [hl+]
    ral
    stax [de+]
    dcr b
    jr .a081B
    jre .a0875
;------------------------------------------------------------
.a0823:
    calf a0CBF                                      ;Write Text(?)
    mvi b, $07
.a0827:
    inx hl
    dcr b
    jr .a0827
    mvi a, $01
    staw [$FFA5]
.a082E:
    calt DRAWLINE                                   ; "[PC+2] Draw Horizontal Line"
    db $E0, $08
    mvi e, $42
    calt ADDRHLE                                    ; "HL <== HL+E"
    calt DRAWLINE                                   ; "[PC+2] Draw Horizontal Line"
    db $FF, $08
    mvi e, $42
    calt ADDRHLE                                    ; "HL <== HL+E"
    calt DRAWLINE                                   ; "[PC+2] Draw Horizontal Line"
    db $1F, $08
    ldaw [$FFA5]
    dcr a
    jr .a0842
    jr .a084C

.a0842:
    staw [$FFA5]
    pop bc
    mov a, b
    staw [$FFA2]
    calf a0CBF                                      ;Write Text(?)
    jr .a082E

.a084C:
    ldaw [$FFA2]
    calf a0CBF                                      ;Write Text(?)
    mvi e, $09
    calt ADDRHLE                                    ; "HL <== HL+E"
    calt DRAWLINE                                   ; "[PC+2] Draw Horizontal Line"
    db $1F, $8E
    calf a0C77                                      ;HL + $3C
    calt DRAWLINE                                   ; "[PC+2] Draw Horizontal Line"
    db $00, $8E
    calf a0C77                                      ;HL + $3C
    calt DRAWLINE                                   ; "[PC+2] Draw Horizontal Line"
    db $F0, $8E
    mvi b, $54                                      ;Decrement HL 55 times!
.a0862:
    dcx hl                                          ;Is this a delay or something?
    dcr b                                           ;There's already a CALT that subs HL...
    jr .a0862
    calt XCHGHLDE                                   ; "XCHG HL,DE"
    pop va
    push de
    calt FONTGET                                    ;Byte -> Point to Font Graphic
    pop de
    mvi b, $04
.a086F:
    ldax [hl+]
    ral
    stax [de+]
    dcr b
    jr .a086F
.a0875:
    lxi hl, TIME.BCD.SUB
    calt DRAWHEX                                    ; "[PC+3] Print Bytes on-Screen"
    db $44, $00, $08
    calt SCR2COPY                                   ; "C258+ ==> C000+"
    calt SCRN2LCD                                   ;Copy Screen RAM to LCD Driver
    calf a0D68                                      ;Draw Border
    calf a0D92                                      ;Draw Puzzle Grid
    calf a0C82                                      ;Scroll text? Write time in decimal?
    mvi b, $0B
    lxi hl, $C75E
    lxi de, $C7F2
.a088C:
    ldax [hl+]
    eqax [de+]
    jre .a07C5
    dcr b
    jr .a088C
    calf a0E64                                      ;Point HL to music data
    calt MUSPLAY                                    ;Setup/Play Music
.a0896:
    oniw [CART_FLAGS], $03
    jmp .a0712                                      ;Continue puzzle
    jr .a0896
;End of Puzzle Code

;------------------------------------------------------------
;Clear A
accclr:
    mvi a, $00
    ret
;------------------------------------------------------------
;XCHG HL,DE
xchghlde:
    push hl
    push de
    pop hl
    pop de
    ret
;------------------------------------------------------------
;Music-playing code...
a08A9:
    ldax [hl+]
    mov b, a
    ldax [hl+]
    staw [$FF99]
    shld [MUSIC_PTR]
    mov a, b
    inr a
    jr a08B6
    rets                                            ;Return & Skip if read "$FF"

;Move "note" into TM0
a08B6:
    lxi hl, a0278                                   ;Table Start
    mov a, b
.a08BA:
    suinb a, $01
    jr .a08C0
    inx hl                                          ;Add A*2 to HL (wastefully)
    inx hl
    jr .a08BA

.a08C0:
    ldax [hl+]
    mov tm0, a
    ldax [hl]
    staw [$FF9A]
    staw [$FF8F]
    dcr b
    mvi a, $00                                      ;Sound?
    mvi a, $03                                      ;Silent
    mov tmm, a
    oriw [CART_FLAGS], $01
    stm
    ret

;------------------------------------------------------------
;Load a "multiplication table" for A,E from (HL) and do AxE
;Is this ever used?
    ldax [hl+]
    mov e, a
    ldax [hl]
;HL <== AxE
multiply:
    lxi hl, $0000
    mvi d, $00
.a08DC:
    gti a, $00
    ret
    clc
    rar
    push va
    sknc
    calt ADDRHLDE                                   ; "HL <== HL+DE"
    mov a, e
    add a, a
    mov e, a
    mov a, d
    ral
    mov d, a
    pop va
    jr .a08DC
;-----------------------------
;((HL+) <==> (DE+))xB
;This function swaps the contents of (HL)<->(DE) B times
memswap:
    calf a08F8                                      ;Swap (HL+)<->(DE+)
    dcr b
    jr memswap
    ret
;------------------------------------------------------------
;Swap (HL+)<->(DE+)
a08F8:
    ldax [hl]
    mov c, a
    ldax [de]
    stax [hl+]
    mov a, c
    stax [de+]
    ret
;------------------------------------------------------------
;Clear Screen 2 RAM
scr2clr:
    lxi hl, SCR2.BEGIN                              ;RAM for screen 2
;Clear Screen RAM
scr1clr:
    lxi hl, SCR1.BEGIN                              ;RAM for screen 1
a0905:
    mvi c, $02
.a0907:
    mvi b, $C7                                      ;$C8 bytes * 3 loops
    calt MEMCLR                                     ; "Clear RAM (HL+)xB"
    dcr c
    jr .a0907
    ret
;------------------------------------------------------------
;Clear C594~C7FF
wramclr:
    lxi hl, OBJ.END                                 ;Set HL
    calf a0905                                      ;And jump to above routine
    mvi b, $13                                      ;Then clear $14 more bytes
    jr memclr                                       ;Clear RAM (HL+)xB

;Clear C4B0~C593
objclr:
    lxi hl, OBJ.BEGIN                               ;Set RAM pointer
    mvi b, $E3                                      ;and just drop into the func.

;Clear RAM (HL+)xB
memclr:
    calt ACCCLR                                     ; "Clear A"
;A ==> (HL+)xB
memset:
    stax [hl+]
    dcr b
    jr memset
    ret
;------------------------------------------------------------
;Read Controller FF90-FF95
joyread:
    lxi hl, JOY.DIR.CURR                            ;Current joy storage
    lxi de, JOY.DIR.PREV                            ;Old joy storage
    mvi b, $01                                      ;Copy 2 bytes from curr->old
    calt MEMCOPY                                    ; "((HL+) ==> (DE+))xB"
    ani pa, !JOY.CS1                                ;PA Bit 6 off
    mov a, pc                                       ;Get port C
    xri a, $FF
.a092F:
    mov c, a
    mvi b, $40                                      ;Debouncing delay
.a0932:
    dcr b
    jr .a0932
    mov a, pc                                       ;Get port C a 2nd time
    xri a, $FF
    eqa a, c                                        ;Check if both reads are equal
    jr .a092F
    ori pa, JOY.CS1                                 ;PA Bit 6 on
    ani a, $03
    stax [de+]                                      ;Save controller read in 92
    mov a, c
    calf rar2x                                      ;RLR A x2
    ani a, $07
    stax [de-]                                      ;Save cont in 93
    ani pa, JOY.CS2 ^ $FF                           ;PA bit 7 off
    mov a, pc                                       ;Get other controller bits
    xri a, $FF
.a094E:
    mov c, a
    mvi b, $40                                      ;...and debounce
.a0951:
    dcr b
    jr .a0951
    mov a, pc
    xri a, $FF
    eqa a, c                                        ;...check again
    jr .a094E
    ori pa, JOY.CS2                                 ;PA bit 7 on
    ral
    ral
    ani a, $0C
    orax [de]                                       ;Or with FF92
    stax [de+]                                      ;...and save
    mov a, c
    ral
    ani a, $38
    orax [de]                                       ;Or with FF93
    stax [de-]                                      ;...and save
    lxi hl, JOY.DIR.PREV                            ;Get our new,old
    lxi bc, JOY.DIR.EDGE
    ldax [hl+]                                      ;And XOR to get controller strobe
    xrax [de+]                                      ;But this strobe function is stupid:
    stax [bc]                                       ;Bits go to 1 whenever the button is
    inx bc                                          ;initially pressed AND released...
    ldax [hl]
    xrax [de]
    stax [bc]
    ret

;------------------------------------------------------------
;C258+ ==> C000+
scr2copy:
    calf a0E5E
    jr a0984
;C000+ ==> C258+
scr1copy:
    calf a0E5E
    calt XCHGHLDE                                   ; "XCHG HL,DE"
a0984:
    mvi c, $02
.a0986:
    mvi b, $C7
    calt MEMCOPY                                    ; "((HL+) ==> (DE+))xB"
    dcr c
    jr .a0986
    ret
;------------------------------------------------------------
;Swap C258+ <==> C000+
scrnswap:
    calf a0E5E
    lxi bc, $C702
.a0991:
    push bc
    calt MEMSWAP                                    ; "((HL+) <==> (DE+))xB"
    pop bc
    dcr c
    jr .a0991
    ret
;------------------------------------------------------------
;Set Dot; B,C = X-,Y-position
;(Oddly enough, this writes dots to the 2nd screen RAM area!)
drawdot:
    push bc
    calf scr2loc                                    ;Point to 2nd screen
    pop bc
    mov a, c
    ani a, $07
    mov c, a
    calt ACCCLR                                     ; "Clear A"
    stc
.a09A6:
    ral
    dcr c
    jr .a09A6
    orax [hl]
    jr a09C5

;------------------------------------------------------------
a09AD:
    eqiw [$FFD8], $00                               ;"Invert Dot", then...
    jr drawdot

;Clear Dot; B,C = X-,Y-position
erasdot:
    push bc
    calf scr2loc                                    ;Point to 2nd screen
    pop bc
    mov a, c
    ani a, $07
    mov c, a
    mvi a, $FF
    clc
.a09BF:
    ral
    dcr c
    jr .a09BF
    anax [hl]
a09C5:
    stax [hl]
    ret
;------------------------------------------------------------
;[PC+2] Draw Horizontal Line
; 1st byte is the bit-pattern (of the 8-dot vertical "char" of the LCD)
; 2nd byte is the length: 00-7F draws black lines; 80-FF draws white lines
drawline:
    pop de
    ldax [de+]                                      ;SP+1
    mov c, a
    ldax [de+]                                      ;SP+2
    push de
    mov d, a
    ani a, $7F
    mov b, a
    mov a, d
    oni a, $80
    jr .a09DD

.a09D6:
    ldax [hl]
    ana a, c
    stax [hl+]
    dcr b
    jr .a09D6
    ret

.a09DD:
    ldax [hl]
    ora a, c
    stax [hl+]
    dcr b
    jr .a09DD
    ret

;------------------------------------------------------------
;[PC+3] Print Bytes on-Screen
;This prints bytes (pointed to by HL) as HEX anywhere on-screen.
;1st byte (after the call) is X-position, 2nd byte is Y-position.
;3rd byte sets a few options:
; bit: 76543210    S = write to screen 1/0
;      SFbbN###    F = Use 5x8 / 5x5 font
;                  bb = blank space between digits (0..3)
;                  N = start at right nybble (LSB) /
;                  start at left nybble (MSB) (more desirable)
;                  ### = 1..8 nybbles to write
;
drawhex:
    pop de
    ldax [de+]
    mov b, a
    staw [DRAW.X]
    ldax [de+]
    mov c, a
    ani a, $07
    staw [DRAW.YOFF]
    ldax [de+]
    push de
    staw [DRAW.DATA]
    ani a, $07
    inr a
    push bc
    staw [$FF98]
    lxi de, $FFA8
    sded [$FFC0]
    mov b, a
    mvi c, $40
    oniw [DRAW.DATA], $40
    mvi c, $10
    oniw [DRAW.DATA], $08
    jr .a0A19
.a0A0F:
    dcr b
    jr .a0A12
    jr .a0A23

.a0A12:
    ldax [hl]
    calt NIBLSWAP                                   ; "(RLR A)x4"
    ani a, $0F
    ora a, c
    stax [de+]
.a0A19:
    dcr b
    jr .a0A1C
    jr .a0A23

.a0A1C:
    ldax [hl+]
    ani a, $0F
    ora a, c
    stax [de+]
    jr .a0A0F

.a0A23:
    pop bc
    aniw [DRAW.DATA], $BF
    jr drawstr

;-----------------------------------------------------------
;[PC+3] Print Text on-Screen
;This prints a text string (pointed to by HL) anywhere on-screen.
;1st byte (after the call) is X-position, 2nd byte is Y-position.
;3rd byte sets a few options:
; bit: 76543210    S = write to screen 1/0
;      Sbbb####    bbb = blank space between digits (0..7)
;                  #### = 1..F nybbles to write
;
drawtext:
    pop de
    ldax [de+]
    mov b, a
    staw [DRAW.X]
    ldax [de+]
    mov c, a                                        ;Save X,Y position in BC
    ani a, $07
    staw [DRAW.YOFF]
    ldax [de+]
    push de
    staw [DRAW.DATA]
    ani a, $0F                                      ;Get # of characters to write
    shld [$FFC0]
    staw [$FF98]                                    ;# saved in 98
    ; fall through to drawstr

drawstr:
    ldaw [DRAW.DATA]
    oni a, $80                                      ;Check if 0 (2nd screen) or 1 (1st screen)
    jr .screen2
    calt SCR1LOC                                    ; "Set HL to screen (B,C)"
    jr .start

.screen2:
    calf scr2loc
.start:
    mov [$FFC6], c
    shld [$FFC2]
    lxi de, SCRN.WIDTH
    calt ADDRHLDE                                   ; "HL <== HL+DE"
    shld [$FFC4]
    ldaw [DRAW.DATA]
    calt NIBLSWAP                                   ; "(RLR A)x4"
    ani a, $07                                      ;Get text spacing (0-7)
    staw [DRAW.DATA]                                ;Save in 9D

;--
.nextchar:
    dcrw [$FF98]                                    ;The loop starts here
    jr .notdone
    ret

.notdone:
    oniw [$FFC6], $FF
    jr .a0A85
    lhld [$FFC2]
    shld [$FFC7]
    lxi de, -(SCRN.WIDTH + FONT.WIDTH)
    mvi b, FONT.WIDTH - 1
    calf drawstripe
    offi a, $80
    jr .a0A85
    lded [DRAW.DATA]
    calt ADDRHLE                                    ; "HL <== HL+E"
    shld [$FFC2]
.a0A85:
    lhld [$FFC4]
    shld [$FFC9]
    lxi de, -SCRN.WIDTH
    mvi b, FONT.WIDTH - 1
    calf drawstripe                                 ;Copy B*A bytes?
    offi a, $80
    jr .a0AA0
    lded [DRAW.DATA]
    calt ADDRHLE                                    ; "HL <== HL+E"
    shld [$FFC4]
.a0AA0:
    mov b, [DRAW.YOFF]
    calt ACCCLR                                     ; "Clear A"
.a0AA5:
    dcr b
    jr .a0AA8
    jr .a0AAD

.a0AA8:
    stc
    ral
    jr .a0AA5

.a0AAD:
    push va
    mov c, a
    calf a0E6A                                      ;(FFB0 -> HL)
    mvi b, $04
.a0AB4:
    ldax [hl]
    ana a, c
    stax [hl+]
    dcr b
    jr .a0AB4
    pop va
    xri a, $FF
    mov c, a
    mvi b, $04
.a0AC1:
    ldax [hl]
    ana a, c
    stax [hl+]
    dcr b
    jr .a0AC1
    lhld [$FFC0]
    ldax [hl+]
    shld [$FFC0]
    calt FONTGET                                    ;Byte -> Point to Font Graphic
    lxi de, $FFB0
    lxi bc, $FFB5
    mvi a, $04
    oriw [CART_FLAGS], $08
    calf a0C31                                      ;Roll graphics a bit (shift up/dn)
    oniw [$FFC6], $FF
    jr .a0AEF
    lded [$FFC7]
    calf a0E6A                                      ;(FFB0 -> HL)
    mvi b, FONT.WIDTH - 1
    oriw [CART_FLAGS], $10
    calf drawstripe                                 ;Copy B*A bytes?
.a0AEF:
    offiw [$FFC6], $08
    jr .a0B01
    lded [$FFC9]
    lxi hl, $FFB5
    mvi b, FONT.WIDTH - 1
    oriw [CART_FLAGS], $10
    calf drawstripe                                 ;Copy B*A bytes?
.a0B01:
    ldaw [DRAW.X]
    adi a, $05
    mov b, a
    ldaw [DRAW.DATA]
    add a, b
    staw [DRAW.X]
    jre .nextchar

;------------------------------------------------------------
;Byte -> Point to Font Graphic
fontget:
    lti a, FONT.COUNT                               ;If it's greater than 64, use cart font
    jr .a0B15                                       ;or...
    lxi de, a02C4                                   ;Point to built-in font
    jr .a0B1B

.a0B15:
    lded [CART.FONT]                                ;4005-6 on cart is the font pointer
    sui a, FONT.COUNT
.a0B1B:
    sded [$FF96]
    mov c, a
    ani a, $0F
    mvi e, $05
    calt MULTIPLY                                   ; "Add A to "Pointer""
    push hl
    mov a, c
    calt NIBLSWAP                                   ; "(RLR A)x4"
    ani a, $0F
    mvi e, $50
    calt MULTIPLY                                   ; "Add A to "Pointer""
    pop de
    calt ADDRHLDE                                   ; "HL <== HL+DE"
    lded [$FF96]
    calt ADDRHLDE                                   ; "HL <== HL+DE"
    ret

;------------------------------------------------------------
;?? (Move some RAM around...)
objdraw:
    lxi hl, OBJ.O11.X
    mvi b, OBJ.COUNT - 1

.loop:
    push hl
    push bc
    calf .draw
    pop bc
    pop hl
    dcx hl
    dcx hl
    dcx hl
    dcr b
    jr .loop
    ret

;------------------------------------------------------------
.draw:
    ldax [hl+]
    staw [DRAW.X]
    mov b, a
    adi a, OBJ.WIDTH - 1
    lti a, SCRN.WIDTH + OBJ.WIDTH
    ret
    ldax [hl+]
    mov c, a
    ani a, $07
    staw [DRAW.YOFF]
    mov a, c
    adi a, OBJ.HEIGHT - 1
    lti a, SCRN.HEIGHT + OBJ.HEIGHT - 1
    ret
    ldax [hl]
    staw [DRAW.DATA]
    lti a, OBJ.TILE.COUNT
    ret
    calt SCR1LOC                                    ; "Set HL to screen (B,C)"
    shld [DRAW.LOC]
    mov a, h
    oni a, $40                                      ; Not clipped by top of screen
    jr .a0B75
    lxi de, $FFB0
    calf drawtile
.a0B75:
    lhld [DRAW.LOC]
    lxi de, SCRN.WIDTH
    calt ADDRHLDE                                   ; "HL <== HL+DE"
    push hl
    lxi de, $FFB8
    calf drawtile
    calf a0E6A
    lxi de, $FFC0
    mvi b, OBJ.TILE.SIZE - 1
    calt MEMCOPY                                    ; "((HL+) ==> (DE+))xB"
    ldaw [DRAW.DATA]
    calt TILELOC                                    ; "HL=C4B0+(A*$10)"
    lxi de, $FFB0
    lxi bc, $FFB8
    calf a0C2F
    push hl
    calf a0E6A
    lxi de, $FFC0
    mvi b, OBJ.TILE.SIZE - 1
..loop:
    ldax [hl]
    xrax [de+]
    stax [hl+]
    dcr b
    jr ..loop
    pop hl
    oriw [CART_FLAGS], $08
    lxi de, $FFB0
    lxi bc, $FFB8
    calf a0C2F
    lded [DRAW.LOC]
    mov a, d
    oni a, $40                                      ; Not clipped by top of screen
    jr .a0BC2
    calf a0E6A
    oriw [CART_FLAGS], $10
    calf drawtile
.a0BC2:
    pop de
    lxi hl, $4000 - SCRN.BYTES
    calt ADDRHLDE                                   ; "HL <== HL+DE"
    sknc
    ret
    lxi hl, $FFB8
    oriw [CART_FLAGS], $10
    ; fall through to drawtile

;------------------------------------------------------------
; drawtile: Draw 8x8 tile as a stripe of width 8.
drawtile:
    mvi b, OBJ.WIDTH - 1
    ; fall through to drawstripe

;------------------------------------------------------------
; drawstripe: Copy bytes to a place in the screen.
; The tile must be aligned in a single 8-bit vertical band,
; but the tile can have a variable width set by b.
;
;   Inputs:
;     [DRAW.X]:   Horizontal position of first column on screen.
;                 May be negative or greater than the screen’s width.
;                 In this case, part of the tile will be cut off.
;     b:          Columns to draw, minus 1
;     [hl..hl+b]  Tile data to draw
;     [de..de+b]  Location in screen to draw data
drawstripe:
    ldaw [DRAW.X]
.loop:
    offi a, $80                                     ; Past left edge of screen (negative)
    jr .a0BE2
    lti a, SCRN.WIDTH                               ; Past right edge of screen
    jr .done
    push va
    ldax [hl+]
    stax [de+]
    pop va
    jr .next
.a0BE2:
    oniw [CART_FLAGS], $10
    jr .a0BE8
    inx hl
    jr .next

.a0BE8:
    inx de
.next:
    inr a
    nop
    dcr b
    jr .loop
.done:
    aniw [CART_FLAGS], $EF
    ret

;------------------------------------------------------------
;Set HL to screen (B,C)
scr1loc:
    lxi hl, SCR1.BEGIN - 75                         ;Point before Sc. RAM
    ; fall through to scr2loc (skip first instruction)

scr2loc:
    lxi hl, SCR2.BEGIN - 75                         ;Point before Sc.2 RAM
    mvi e, SCRN.WIDTH
    mov a, c
    mvi c, $00
    adi a, $08
.a0BFE:
    suinb a, $08
    jr .a0C08
    push va
    calt ADDRHLE                                    ; "HL <== HL+E"
    pop va
    inr c
    jr .a0BFE
.a0C08:
    mov a, b
    offi a, $80
    ret
    mov e, a
    jr addrhle
;------------------------------------------------------------
;[PC+1] HL +- byte
addrhli:
    pop de
    ldax [de+]                                      ;Get byte after PC
    push de
    mov e, a
    lti a, $80                                      ;Add or subtract that byte
    mvi a, $FF
;HL <== HL+E
addrhle:
    mvi a, $00
    mov d, a
;HL <== HL+DE
addrhlde:
    mov a, e
    add a, l
    mov l, a
    mov a, d
    adc a, h
    mov h, a
    ret

;------------------------------------------------------------
;HL=C4B0+(A*$10)
tileloc:
    lxi hl, OBJ.BEGIN
    mvi e, OBJ.TILE.SIZE
    mov b, a
.loop:
    dcr b
    jr .continue
    ret

.continue:
    calt ADDRHLE                                    ; "HL <== HL+E"
    jr .loop

;------------------------------------------------------------
a0C2F:
    mvi a, $07

a0C31:
    staw [$FF96]

.a0C33:
    ldaw [DRAW.YOFF]
    staw [$FF97]
    push bc
    mvi c, $00
    ldax [hl+]

.loop:
    dcrw [$FF97]
    jr .a0C40
    jr .a0C4D

.a0C40:
    clc
    ral
    push va
    mov a, c
    ral
    mov c, a
    pop va
    jr .loop

.a0C4D:
    oniw [CART_FLAGS], $08
    jr .a0C54
    orax [de]
    jr .a0C56

.a0C54:
    anax [de]
.a0C56:
    stax [de]
    mov a, c
    pop bc
    oniw [CART_FLAGS], $08
    jr .a0C61
    orax [bc]
    jr .a0C63

.a0C61:
    anax [bc]
.a0C63:
    stax [bc]
    inx bc
    inx de
    dcrw [$FF96]
    jre .a0C33
    aniw [CART_FLAGS], $F7
    ret

;------------------------------------------------------------
;(RLR A)x4 (Divides A by 16)
niblswap:
    rar
    rar
rar2x:
    rar
    rar
    ret
;------------------------------------------------------------
a0C77:
    mvi e, $3C                                      ; 60 decimal...
    calt ADDRHLE                                    ; "HL <== HL+E"
    ret
;------------------------------------------------------------
a0C7B:
    lxi hl, str_puzzle                              ;"PUZZLE"
    calt DRAWTEXT                                   ; "[PC+3] Print Text on-Screen"
    db $03, $00, $1 @ str_puzzle.len
a0C82:
    calf a0E67                                      ;(C7F2 -> HL)
    mvi a, $01
    staw [$FF83]
.a0C88:
    ldax [hl+]
    push hl
    nei a, $FF                                      ;If it's a terminator, loop
    jre .a0CB6
    calt FONTGET                                    ;Byte -> Point to Font Graphic
    calt XCHGHLDE                                   ; "XCHG HL,DE"
    ldaw [$FF83]
    calf a0CBF                                      ;(Scroll text)
    push de
    mvi e, $51
    calt ADDRHLE                                    ; "HL <== HL+E"
    pop de
    mvi b, $04
.a0C9E:
    ldax [de+]
    ral
    stax [hl+]
    dcr b
    jr .a0C9E
.a0CA4:
    inrw [$FF83]
    pop hl
    eqiw [$FF83], $0D
    jre .a0C88
    lxi hl, $C7FF
    ldax [hl]
    calf a0E3B                                      ;Scroll text; XOR RAM
    calt SCR2COPY                                   ; "C258+ ==> C000+"
    calt SCRN2LCD                                   ;Copy Screen RAM to LCD Driver
    ret
;------------------------------------------------------------
.a0CB6:
    mov a, [$FF83]                                  ;A "LDAW 83" would've been faster here...
    mov [$C7FF], a
    jr .a0CA4
;------------------------------------------------------------
a0CBF:
    lti a, $09
    jr .a0CD2
    lti a, $05
    jr .a0CD8
    lxi hl, SCR2.BEGIN + 1*75 + 53
.a0CC8:
    nei a, $04
    ret
    mvi b, $0F
.a0CCD:
    dcx hl
    dcr b
    jr .a0CCD
    inr a
    jr .a0CC8
.a0CD2:
    lxi hl, SCR2.BEGIN + 5*75 + 53
    sui a, $08
    jr .a0CC8
;------------------------------------------------------------
.a0CD8:
    lxi hl, SCR2.BEGIN + 3*75 + 53
    sui a, $04
    jr .a0CC8
;------------------------------------------------------------
a0CDE:
    lxi hl, a04B8                                   ;Point to scroll text
    jr a0CFA
;------------------------------------------------------------
    ;Slide the top line for the scroller.
a0CE2:
    inrw [$FF82]
    nop
    lxi hl, SCR2.BEGIN + 3
    lxi de, SCR2.BEGIN
    mvi b, $47
    calt MEMCOPY                                    ; "((HL+) ==> (DE+))xB"
    offiw [$FF82], $01
    jr .a0CF6
    lxi hl, $FFA3
    jr a0D0C

.a0CF6:
    lhld [$FFD6]
a0CFA:
    ldax [hl+]
    nei a, $FF                                      ;If terminator...
    jr a0CDE                                        ;...reset scroll
    shld [$FFD6]
    calt FONTGET                                    ;Byte -> Point to Font Graphic
    mvi b, $04                                      ;(5 pixels wide)
    lxi de, PAINT.CURSOR.BCD.X
    calt MEMCOPY                                    ; "((HL+) ==> (DE+))xB"
    lxi hl, PAINT.CURSOR.BCD.X                      ;First copy it to RAM...

a0D0C:
    lxi de, SCR2.BEGIN + 72                         ;Then put it on screen, 3 pixels at a time.
    mvi b, $02

;((HL+) ==> (DE+))xB
memcopy:
    ldax [hl+]
    stax [de+]
    dcr b
    jr memcopy
    ret
;------------------------------------------------------------
a0D16:
    inrw [$FFDA]
    lxi hl, $FFDA
    ldax [hl]
    staw [$FFD0]
    jr a0D23

;Draw a spiral dot-by-dot
a0D1F:
    neiw [$FFD0], $FF
    jr a0D16
a0D23:
    ldaw [$FFD1]                                    ;This stores the direction
    nei a, $00                                      ;that the spiral draws in...
    jr .a0D46
    lbcd [$FFD2]
    nei a, $01
    jre .a0D52
    nei a, $02
    jre .a0D57
    nei a, $03
    jre .a0D5C

    dcr b
    mov a, b
    staw [$FFD3]
    calf a09AD                                      ;Draw a dot on-screen
    dcrw [$FFD0]                                    ;Decrement length counter...
    ret
    mvi a, $01                                      ;If zero, turn corners
    staw [$FFD1]
    ret
;------------------------------------------------------------
.a0D46:
    lxi bc, $2524
    sbcd [$FFD2]
    calf a09AD
    inrw [$FFD1]
    ret
.a0D52:
    dcr c
    mov a, c
    staw [$FFD2]
    jr .a0D60
;------------------------------------------------------------
.a0D57:
    inr b
    mov a, b
    staw [$FFD3]
    jr .a0D60
;------------------------------------------------------------
.a0D5C:
    inr c
    mov a, c
    staw [$FFD2]
.a0D60:
    calf a09AD
    dcrw [$FFD0]
    ret
    inrw [$FFD1]
    ret

;------------------------------------------------------------
;Draw a thick black frame around the screen
a0D68:
    lxi hl, SCR2.BEGIN + 1*75                       ;Point to 2nd screen
    mvi a, $FF                                      ;Black character
    mvi b, $05                                      ;Write 6 characters
    calt MEMSET                                     ; "A ==> (HL+)xB"
    mvi a, $1F                                      ;Then a char with 5 upper dots filled
    mvi b, $3E                                      ;Times 63
    calt MEMSET                                     ; "A ==> (HL+)xB"
    mvi c, $04
.a0D77:
    mvi b, $0B
    mvi a, $FF
    calt MEMSET                                     ; "A ==> (HL+)xB"
    calt ACCCLR                                     ; "Clear A"
    mvi b, $3E
    calt MEMSET                                     ; "A ==> (HL+)xB"
    dcr c
    jr .a0D77
    mvi a, $FF
    mvi b, $0B
    calt MEMSET                                     ; "A ==> (HL+)xB"
    mvi a, $F0
    mvi b, $3E
    calt MEMSET                                     ; "A ==> (HL+)xB"
    mvi a, $FF
    mvi b, $05
    calt MEMSET                                     ; "A ==> (HL+)xB"
    ret
;------------------------------------------------------------
;This draws the puzzle grid, I think...
a0D92:
    neiw [$FFD5], $00
    jr .a0DA2
    neiw [$FFD5], $01
    jr .a0DA5
    eqiw [$FFD5], $02
    jre .a0DC3
    lxi hl, SCR2.BEGIN + 1*75 + 53
.a0DA2:
    lxi hl, SCR2.BEGIN + 1*75 + 21
.a0DA5:
    lxi hl, SCR2.BEGIN + 1*75 + 75/2
    calt DRAWLINE                                   ; "[PC+2] Draw Horizontal Line"
    db $F0, $00
    mvi b, $04
.a0DAD:
    push bc
    mvi e, $4A
    calt ADDRHLE                                    ; "HL <== HL+E"
    calt DRAWLINE                                   ; "[PC+2] Draw Horizontal Line"
    db $FF, $00
    pop bc
    dcr b
    jr .a0DAD
    mvi e, $4A
    calt ADDRHLE                                    ; "HL <== HL+E"
    calt DRAWLINE                                   ; "[PC+2] Draw Horizontal Line"
    db $1F, $00
    inrw [$FFD5]
    jre a0D92
.a0DC3:
    lxi hl, SCR2.BEGIN + 3*75 + 5
    calt DRAWLINE                                   ; "[PC+2] Draw Horizontal Line"
    db $10, $40
    lxi hl, SCR2.BEGIN + 5*75 + 5
    calt DRAWLINE                                   ; "[PC+2] Draw Horizontal Line"
    db $10, $40
    calt ACCCLR                                     ; "Clear A"
    staw [$FFD5]
    ret
;------------------------------------------------------------
a0DD3:
    nei a, $01
    jr .a0DEE
    nei a, $04
    jre .a0DFC
    nei a, $02
    jre .a0E0A

    mov a, [$C7FF]                                  ;More puzzle grid drawing, probably...
    ani a, $03
    nei a, $01
    rets

    lxi bc, $12FF
    oriw [$FFA2], $FF
    jr .a0DFB
;------------------------------------------------------------
.a0DEE:
    mov a, [$C7FF]
    lti a, $09
    rets

    lxi bc, $0D04
    aniw [$FFA2], $00
.a0DFB:
    jr .a0E17
;------------------------------------------------------------
.a0DFC:
    mov a, [$C7FF]
    gti a, $04
    rets
    lxi bc, $0FFC
    aniw [$FFA2], $00
    jr .a0E17
;------------------------------------------------------------
.a0E0A:
    mov a, [$C7FF]
    oni a, $03
    rets

    lxi bc, $1101
    oriw [$FFA2], $FF
.a0E17:
    mov a, [$C7FF]
    mov e, a
    mov [$C7FE], a
    add a, c
    mov d, a
    mov [$C7FF], a
    lxi hl, $C7F1
    mov a, d
.a0E2B:
    dcr a
    jr .a0E2E
    jr .a0E30

.a0E2E:
    inx hl
    jr .a0E2B

.a0E30:
    mov a, e
    lxi de, $C7F1
.a0E34:
    dcr a
    jr .a0E39
    jmp a08F8

.a0E39:
    inx de
    jr .a0E34
;------------------------------------------------------------
a0E3B:
    calf a0CBF
    calt DRAWLINE                                   ; "[PC+2] Draw Horizontal Line"
    db $F0, $10
    mvi e, $3A
    calt ADDRHLE                                    ; "HL <== HL+E"
    calt DRAWLINE                                   ; "[PC+2] Draw Horizontal Line"
    db $FF, $10
    mvi e, $3A
    calt ADDRHLE                                    ; "HL <== HL+E"
    calt DRAWLINE                                   ; "[PC+2] Draw Horizontal Line"
    db $1F, $10
    ret
;------------------------------------------------------------
; Turns on a hardware timer
a0E4D:
    di
    mvi a, $07
    mov tmm, a
    mvi a, $74
    mov tm0, a
    aniw [CART_FLAGS], $FC
    stm
    ei
    ret
;------------------------------------------------------------
; Loads (DE/)HL with various common addresses
a0E5E:
    lxi de, SCR1.BEGIN
    lxi hl, SCR2.BEGIN
a0E64:
    lxi hl, a04EC
a0E67:
    lxi hl, $C7F2
a0E6A:
    lxi hl, $FFB0
    ret
;------------------------------------------------------------

;[PC+1] ?? (Unpack 8 bytes -> 64 bytes (Twice!))
caltd0:
    pop hl
    ldax [hl+]
    push hl
a0E73:
    calt TILELOC                                    ; "HL=C4B0+(A*$10)"
    calt XCHGHLDE                                   ; "XCHG HL,DE"
    call .a0E78                                     ;This call means the next code runs twice

.a0E78:
    mvi b, $7
.a0E7A:
    mvi c, $7
    calf a0E6A                                      ;(FFB0->HL)
    ldax [de]                                       ;In this loop, the byte at (FFB0)
.a0E7F:
    ral                                             ;Has its bits split up into 8 bytes
    push va                                         ;And this loop runs 8 times...
    ldax [hl]
    rar
    stax [hl+]
    pop va
    dcr c
    jr .a0E7F
    inx de
    dcr b
    jr .a0E7A

    push de
    dcx hl
    dcx de
    mvi b, $7
    calt MEMRCPY                                    ; "((HL-) ==> (DE-))xB"
    pop de
    ret
;------------------------------------------------------------
;[PC+1] ?? (Unpack & Roll 8 bits)
caltd2:
    pop hl
    ldax [hl+]
    push hl
    push va
    calf a0E73
    pop va
    jr a0EA9
;-----------------------------------------------------------
;[PC+1] ?? (Roll 8 bits -> Byte?)
caltd4:
    pop hl
    ldax [hl+]
    push hl
a0EA9:
    calt TILELOC                                    ; "HL=C4B0+(A*$10)"
    lxi de, $FFBF
    calt XCHGHLDE                                   ; "XCHG HL,DE"
    push de
    mvi c, $0F
.a0EB2:
    mvi b, $8-1
    ldax [de]
.a0EB5:
    ral
    push va
    ldax [hl]
    rar
    stax [hl]
    pop va
    dcr b
    jr .a0EB5
    dcx hl
    inx de
    dcr c
    jr .a0EB2
    pop de
    lxi hl, $FFB8
    calf .a0ECE
    calf a0E6A

.a0ECE:
    mvi b, $8-1
    calt MEMCOPY                                    ; "((HL+) ==> (DE+))xB"
    ret
;------------------------------------------------------------
;[PC+x] ?? (Add/Sub multiple bytes)
caltd6:
    pop hl
    ldax [hl+]
    push hl
    mov b, a
    ani a, $0F
    staw [$FF96]
    mov a, b
    calt NIBLSWAP                                   ; "(RLR A)x4"
    ani a, $0F
    lti a, $0D
    ret
    staw [$FF97]
.a0EE5:
    dcrw [$FF97]
    jr .a0EF0                                       ;Based on 97, jump to cart (4007)!
    calt SCRNCOMP                                   ; "CALT A0, CALT A4"
    pop bc
    lbcd [CART.UNKN]                                ;Read vector from $4007 on cart, however...
    jb                                              ;...all 5 Pokekon games have "0000" there!
.a0EF0:
    pop hl
    ldax [hl+]
    push hl
    staw [$FF98]
    ani a, $0F
    lti a, $0C
    jr .a0EE5
    lxi hl, OBJ.TILE.END - 2
.a0EFF:
    inx hl
    inx hl
    inx hl
    dcr a
    jr .a0EFF
    lxi de, $FF96
    oniw [$FF98], $80
    jr .a0F10
    ldax [hl]
    subx [de]
    stax [hl]
    jr .a0F18

.a0F10:
    oniw [$FF98], $40
    jr .a0F18
    ldax [hl]
    addx [de]
    stax [hl]
.a0F18:
    dcx hl
    oniw [$FF98], $10
    jr .a0F23

    ldax [hl]
    addx [de]
    stax [hl]
.a0F21:
    jre .a0EE5

.a0F23:
    oniw [$FF98], $20
    jr .a0F21
    ldax [hl]
    subx [de]
    stax [hl]
    jr .a0F21
;------------------------------------------------------------
;Invert Screen RAM (C000~)
scr1inv:
    lxi hl, SCR1.BEGIN
;Invert Screen 2 RAM (C258~)
scr2inv:
    lxi hl, SCR2.BEGIN
    mvi c, $02

.a0F34:
    mvi b, $C7
    calf a0F3B
    dcr c
    jr .a0F34
    ret
;------------------------------------------------------------
;Invert bytes xB
a0F3B:
    ldax [hl]
    xri a, $FF
    stax [hl+]
    dcr b
    jr a0F3B
    ret
;------------------------------------------------------------
;[PC+1] Invert 8 bytes at (C4B0+A*$10)
tileinv:
    pop hl
    ldax [hl+]
    push hl
    lti a, $0C
    ret

    calt TILELOC                                    ; "HL=C4B0+(A*$10)"
    mvi e, $08
    calt ADDRHLE                                    ; "HL <== HL+E"
    mvi b, $07
    jr a0F3B
;------------------------------------------------------------
;for the addition routine below...
a0F51:
    mov a, h
    staw [$FFB0]
    mov a, l
    staw [$FFB1]
    lxi hl, $FFB1
    ldaw [$FF96]
    jr a0F6D
;------------------------------------------------------------
;[PC+1] 8~32-bit Add/Subtract (dec/hex)
;Source pointed to by HL & DE.  Extra byte sets a few options:
; bit: 76543210    B = 0/1: Work in decimal (BCD) / regular Hex
;      BA2211HD    0/1: Add / Subtract numbers
;                  22 = byte length of (HL)
;                  11 = byte length of (DE)
;                  H = 1: HL gets bytes from $FFB1
;                  D = 1: DE gets bytes from $FFA2
arithmtc:
    pop bc
    ldax [bc]
    inx bc
    push bc
    staw [$FF96]                                    ;Get extra byte, keep in 96
    offi a, $01                                     ;If set, load from $FFA2 instead
    lxi de, $FFA2
    offi a, $02                                     ;If set, load from $FFB1
    jr a0F51

a0F6D:
    calf rar2x                                      ;"RLR A" x2
    mov b, a                                        ;Get our length bits (8-32 bits)
    ani a, $03
    mov c, a
    mov a, b
    calf rar2x                                      ;"RLR A" x2
    ani a, $03
    mov b, a
    oniw [$FF96], $40                               ;Do we subtract instead of add?
    jr .a0F83
    oniw [$FF96], $80                               ;Do we work in binary-coded decimal?
    jr .a0F99
    jre .a0FB0

.a0F83:
    oniw [$FF96], $80
    jre .a0FC1

    clc
.a0F8A:
    ldax [de]
    adcx [hl]                                       ;Add HL-,DE-
    stax [de]
    dcr b
    jr .a0F91
    ret

.a0F91:
    dcx de
    dcr c
    jr .a0F97
    calf .a0FD3                                     ;Clear C,HL
    jr .a0F8A

.a0F97:
    dcx hl
    jr .a0F8A

.a0F99:
    stc
.a0F9B:
    mvi a, $99
    aci a, $00
    subx [hl]
    addx [de]
    daa
    stax [de]
    dcr b
    jr .a0FA8
    ret

.a0FA8:
    dcx de
    dcr c
    jr .a0FAE
    calf .a0FD3
    jr .a0F9B

.a0FAE:
    dcx hl
    jr .a0F9B
;-----
.a0FB0:
    clc
.a0FB2:
    ldax [de]
    sbbx [hl]
    stax [de]
    dcr b
    jr .a0FB9
    ret

.a0FB9:
    dcx de
    dcr c
    jr .a0FBF
    calf .a0FD3
    jr .a0FB2

.a0FBF:
    dcx hl
    jr .a0FB2
;------
.a0FC1:
    clc
.a0FC3:
    ldax [de]
    adcx [hl]
    daa
    stax [de]
    dcr b
    jr .a0FCB
    ret

.a0FCB:
    dcx de
    dcr c
    jr .a0FD1
    calf .a0FD3
    jr .a0FC3

.a0FD1:
    dcx hl
    jr .a0FC3
;------------------------------------------------------------
;Clear C,HL (for the add/sub routine above)
.a0FD3:
    mvi c, $00
    lxi hl, $0000
    ret
;------------------------------------------------------------
;[PC+1] INC/DEC Range of bytes from (HL)
;Extra byte's high bit sets Inc/Dec; rest is the byte counter.
membump:
    pop bc
    ldax [bc]
    inx bc
    push bc
    mov b, a
    oni a, $80                                      ;do we Dec?
    jr .a0FF1

    ani a, $7F                                      ;Counter can be 00-7F
    mov b, a
.a0FE6:
    ldax [hl]                                       ;Load a byte
    sui a, $01                                      ;Decrement it
    stax [hl-]
    sknc                                            ;Quit our function if any byte= -1!
    jr .a0FEE
    ret

.a0FEE:
    dcr b
    jr .a0FE6
    ret

.a0FF1:
    ldax [hl]                                       ;or Load a byte
    adi a, $01
    stax [hl-]
    sknc                                            ;Quit if any byte overflows!
    jr .a0FF9
    ret

.a0FF9:
    dcr b
    jr .a0FF1
    ret                                             ;What a weird way to end a BIOS...
;------------------------------------------------------------
    db $00, $00, $00, $00                           ;Unused bytes (and who could blame 'em?)

#bankdef wram
{
    addr = 0xc000
    size = 0x0800
}

#bankdef hram
{
    addr = 0xff80
    size = 0x0080
}

CART_FLAGS = $FF80
MUSIC_PTR = $FF84

#const PAINT = struct {
    CURSOR = struct {
        X = $FFA6
        Y = $FFA7
        BCD = struct {
            X = $FFA0
            Y = $FFA1
        }
        SPRITE = OBJ.O0
        TILE = OBJ.BEGIN
    }
    LEFT    = 7
    TOP     = 14
    RIGHT   = 75 - 7   ; 68 = SCRN.WIDTH - LEFT
    BOTTOM  = 64 - 5   ; 59 = SCRN.HEIGHT - 5
    WIDTH   = 68 - 7   ; 61 = RIGHT - LEFT
    HEIGHT  = 59 - 14  ; 45 = BOTTOM - TOP
}

#const DRAW = struct {
    X     = $FF9B
    YOFF  = $FF9C
    DATA  = $FF9D
    LOC   = $FF9E
}
