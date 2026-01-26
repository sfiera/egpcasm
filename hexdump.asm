#include "gamepock.asm"

#bankdef rom
{
    addr = $4000
    size = $2000
    fill = true
    outp = 0
}

#fn relo(symbol) => (symbol - loop + $c000)

header:
    db CART.MAGIC
    dw main    ; normal startup
    dw main    ; hot-swap startup
    dw 0       ; no font
    dw 0       ; unknown
    jmp $0128  ; no cartridge-specific interrupt code

#addr CART.BEGIN
main:
    ; Set up stack pointer
    lxi sp, $0000

    ; Disable interrupts permanently.
    ; Otherwise, when another cartridge is inserted,
    ; the interrupt might take over and run its code.
    di

    ; Copy the hexdump code into WRAM, so it remains
    ; even after the cartridge is swapped.
    lxi hl, loop
    lxi de, relo(loop)
    mvi b, end - loop - 1
    calt MEMCOPY

    ; Switch LCD 1 to count-down mode instead of count-up.
    ; This makes it simpler to draw directly to that LCD.
    ori pa, LCD.CS1     ; Select LCD 1
    ani pa, !LCD.DI     ; Switch to instruction mode
    mvi a, %00111010    ; Command to set count-down mode
    call relo(lcdexec)  ; Execute command
    ani pa, !LCD.CS1    ; Deselect LCD 1

    lxi hl, $0000       ; Set initial address for viewer
    jmp relo(loop)      ; Switch to code in WRAM


    ; main code, executed from WRAM.
loop:
    push hl

    mvi a, LCD.I.P1 | 2                     ; LCD3, page 1A, column 2
    call relo(drawaddr)                     ; Draw first address
    lxi bc, (LCD.CS1 << 8) | LCD.I.P1 | 49  ; LCD1, page 1, leftmost column
    call relo(drawrow4)                     ; Draw 4 rows of hex (16 bytes)
    mvi a, LCD.I.P1 | 2 + 25                ; LCD3, page 1B, column 2
    call relo(drawaddr)                     ; Draw second address
    lxi bc, (LCD.CS2 << 8) | LCD.I.P1 | 0   ; LCD2, page1, leftmost column
    call relo(drawrow4)                     ; Draw 4 rows of hex (16 bytes)

    calt JOYREAD
    pop hl

    lxi de, 0

    ldaw [JOY.DIR.EDGE]
    mov b, a
    ldaw [JOY.DIR.CURR]
    ana a, b

    offi a, JOY.DIR.UP  ; if up pressed
    mvi e, $10          ; then de = $0010
    offi a, JOY.DIR.DN  ; if down pressed
    lxi de, $fff0       ; then de = -$0010 ($fff0)

    ldaw [JOY.BTN.EDGE]
    mov b, a
    ldaw [JOY.BTN.CURR]
    ana a, b

    offi a, JOY.BTN.BT1  ; if button 1 pressed
    mvi d, $10           ; then de = $1000
    offi a, JOY.BTN.BT2  ; if button 2 pressed
    mvi d, $01           ; then de = $0100
    offi a, JOY.BTN.BT3  ; if button 3 pressed
    mvi d, $f0           ; then de = -$1000 ($f000)
    offi a, JOY.BTN.BT4  ; if button 4 pressed
    mvi d, $ff           ; then de = -$0100 ($ff00)

    calt ADDRHLDE
    jre loop

drawrow4:
    call relo(drawrow2)
    ; fall through

drawrow2:
    call relo(drawrow)
    ; fall through

drawrow:
    push bc
    mov a, pa
    ora a, b
    mov pa, a
    mov a, c
    call relo(lcdexec)

    ori pa, LCD.DI    ; Switch to data mode

    call relo(drawbyte4)

    mvi a, LCD.I.POFF
    pop bc
    add a, c
    mov c, a

    jr deselect

drawaddr:
    ori pa, LCD.CS3
    call relo(lcdexec)
    ori pa, LCD.DI    ; Switch to data mode

    mov a, h
    call relo(drawacc)
    mov a, l
    call relo(drawacc)
    ; fall through

deselect:
    ani pa, !LCD.DI & !LCD.CS1 & !LCD.CS2 & !LCD.CS3
    ret

drawbyte4:
    call relo(drawbyte2)
    ; fall through

drawbyte2:
    call relo(drawbyte)
    ; fall through

drawbyte:
    ldax [hl+]
    ; fall through

; Draw the pair of hex digits in a.
drawacc:
    push va
    calt ACC4RAR
    call relo(drawdigit)
    pop va
    ; fall through

; Draw the hex digit in the lower nibble of a.
drawdigit:
    ; a = (a & 0x0f) * 5
    ani a, $0f
    mov c, a
    clc
    ral
    ral
    add a, c

    lxi de, $02c4 + 5*$40
    add a, e
    mov e, a
    calt ACCCLR
    adc a, d
    mov d, a

    mvi c, 4
.nextbyte:
    ldax [de+]
    ral
    call relo(lcdexec)
    dcr c
    jr .nextbyte
    calt ACCCLR
    ; fall through

; Send and execute the LCD data in register a.
lcdexec:
    mov pb, a
    ori pa, LCD.E
    ani pa, !LCD.E
    ret

end:
