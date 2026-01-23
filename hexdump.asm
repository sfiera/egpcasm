#include "gamepock.asm"

#bankdef rom
{
    addr = $4000
    size = $2000
    fill = true
    outp = 0
}

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

    ; Switch LCD 1 to count-down mode instead of count-up.
    ; This makes it simpler to draw directly to that LCD.
    ori pa, LCD.CS1   ; Select LCD 1
    ani pa, !LCD.DI   ; Switch to instruction mode
    mvi a, %00111010  ; Count-down mode
    mov pb, a         ;
    ori pa, LCD.E     ; Send command
    ani pa, !LCD.E    ; Command sent
    ani pa, !LCD.CS1  ; Deselect LCD 1

    ; Copy the hexdump code into WRAM, so it remains
    ; even after the cartridge is swapped.
    lxi hl, loop
    lxi de, $c000
    mvi b, end - loop - 1
    calt MEMCOPY

#fn relo(symbol) => (symbol - loop + $c000)
    lxi hl, $0000
    jmp relo(loop)

loop:
    push hl
    call relo(drawaddr)
    mvi b, LCD.CS1
    mvi c, LCD.I.P1 | 48
    call relo(drawrow)
    call relo(drawrow)
    call relo(drawrow)
    call relo(drawrow)
    mvi b, LCD.CS2
    mvi c, LCD.I.P1 | 1
    call relo(drawrow)
    call relo(drawrow)
    call relo(drawrow)
    call relo(drawrow)

    calt JOYREAD
    pop hl
    call relo(navigate)

    jre loop

navigate:
    ; Move hl to de for later.
    mov a, h
    mov d, a
    mov a, l
    mov e, a

    ldaw [JOY.DIR.EDGE]
    mov b, a
    ldaw [JOY.DIR.CURR]
    ana a, b

    offi a, JOY.DIR.UP
    jr .plus0010
    offi a, JOY.DIR.DN
    jr .minus0010

    ldaw [JOY.BTN.EDGE]
    mov c, a
    ldaw [JOY.BTN.CURR]
    ana a, c

    offi a, JOY.BTN.BT1
    jr .plus1000
    offi a, JOY.BTN.BT2
    jr .plus0100
    offi a, JOY.BTN.BT3
    jr .minus1000
    offi a, JOY.BTN.BT4
    jr .minus0100

    ; Only the first statement reached will execute.
    ; (this is why hl was moved to de beforehand)
    lxi hl, 0
.plus0010:
    lxi hl, $0010
.minus0010:
    lxi hl, -$0010
.plus0100:
    lxi hl, $0100
.plus1000:
    lxi hl, $1000
.minus1000:
    lxi hl, -$1000
.minus0100:
    lxi hl, -$0100

    calt ADDRHLDE
    ret

drawrow:
    push bc
    mov a, pa
    ora a, b
    mov pa, a
    mov a, c
    mov pb, a
    ori pa, LCD.E     ; Send command
    ani pa, !LCD.E    ; Command sent

    ori pa, LCD.DI    ; Switch to data mode

    call relo(drawbyte)
    call relo(drawbyte)
    call relo(drawbyte)
    call relo(drawbyte)

    ani pa, !LCD.DI & !LCD.CS1 & !LCD.CS2 & !LCD.CS3
    pop bc
    mvi a, LCD.I.POFF
    add a, c
    mov c, a
    ret

drawaddr:
    ori pa, LCD.CS3
    mvi a, LCD.I.P1 | 2
    mov pb, a
    ori pa, LCD.E     ; Send command
    ani pa, !LCD.E    ; Command sent

    ori pa, LCD.DI    ; Switch to data mode

    mov a, h
    calt ACC4RAR
    call relo(drawdigit)
    mov a, h
    call relo(drawdigit)
    mov a, l
    calt ACC4RAR
    call relo(drawdigit)
    mov a, l
    call relo(drawdigit)

    ani pa, !LCD.DI & !LCD.CS1 & !LCD.CS2 & !LCD.CS3
    ret

drawbyte:
    ldax [hl+]
    push va
    calt ACC4RAR
    call relo(drawdigit)
    pop va
    call relo(drawdigit)
    ret

drawdigit:
    ani a, $0f
    mov c, a
    clc
    ral
    ral
    add a, c
    lxi de, $02c4 + 5*$40
    add a, e
    mov e, a
    xra a, a
    adc a, d
    mov d, a

    mvi c, 4
.nextbyte:
    ldax [de+]
    ral
    mov pb, a
    ori pa, LCD.E
    ani pa, !LCD.E
    dcr c
    jr .nextbyte
    ani pb, 0
    ori pa, LCD.E
    ani pa, !LCD.E
    ret

end:
