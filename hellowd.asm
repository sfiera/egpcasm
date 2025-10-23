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
    dw main
    dw main

#addr CART.BEGIN
main:
    ; Set up stack pointer
    lxi sp, $0000

    ; Draw greeting text to screen 1 and send to LCD
    lxi hl, str_greeting
    calt DRAWTEXT
    db 3, 28, %1001 @ str_greeting.len`4
    calt SCRN2LCD

    ; Loop forever
.loop:
    jr .loop

str_greeting:
    #d8 "H"-$20, "E"-$20, "L"-$20, "L"-$20, "O"-$20, " "-$20
    #d8 "W"-$20, "O"-$20, "R"-$20, "L"-$20, "D"-$20, "!"-$20
.len = $ - str_greeting
