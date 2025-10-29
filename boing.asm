#include "gamepock.asm"

#const VARS = $FFD0
#const BALL = struct {
    X   = VARS - vars + vars.ballx
    Y   = VARS - vars + vars.bally
    DX  = VARS - vars + vars.balldx
    DY  = VARS - vars + vars.balldy

    SIZE = 16
}

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

    lxi hl, vars
    lxi de, VARS
    mvi b, vars.len - 1
    calt MEMCOPY

    lxi de, OBJ.TILE.BEGIN
    mvi b, tile.len - 1
    calt MEMCOPY

    lxi de, OBJ.O0.X
    mvi b, obj.len - 1
    calt MEMCOPY

    lxi hl, OBJ.O0.X + obj.len
    mvi a, $80
    mvi b, OBJ.END - OBJ.O0.X - obj.len - 1
    calt MEMSET

    ; A simple decompression routine built on `calt MEMCOPY`:
    ; * N in [0, 15] indicates the next N+1 bytes are literal
    ; * N in [16, 254] followed by D indicates the next N-15 bytes
    ;   should be copied from the position D bytes before.
    ;   If D == 1, that’s essentially RLE for a single byte.
    ; * N == 255 indicates the end of the compressed stream.
.grid:
    lxi de, SCR2.BEGIN
    lxi hl, grid
..next:
    ldax [hl+]
    nei a, $FF
    jr ..done  ; if a == $FF
    lti a, MAX_LIT
    jr ..run  ; if a >= $10
    mov b, a
    calt MEMCOPY
    jr ..next
..run:
    sbi a, MAX_LIT
    mov b, a
    ldax [hl+]
    mov c, a
    push hl
    mov a, e
    sub a, c
    mov l, a
    mov a, d
    sbi a, 0
    mov h, a
    calt MEMCOPY
    pop hl
    jr ..next
..done:

.loop:
    ; Update ball obj positions.
    ; First load (y, x) to (b, c) and (y+8, x+8) to (d, e).
    ; Write bc and de to the positions for objects 0 and 3.
    ; Then swap b and d, and write to objects 2 and 1.
    ldaw [BALL.X]
    mov c, a
    adi a, 8
    mov e, a
    ldaw [BALL.Y]
    mov b, a
    adi a, 8
    mov d, a
    sbcd [OBJ.O0.X]
    sded [OBJ.O3.X]
    mov b, a
    ldaw [BALL.Y]
    mov d, a
    sbcd [OBJ.O2.X]
    sded [OBJ.O1.X]

    ; Composite ball onto background and send to LCD.
    ; This takes ~130ms, so games that use sprite compositing
    ; are limited to 6-7 FPS.
    calt SCRNCOMP

    ; Wait until 150ms has passed since last user timer reset.
.wait:
    ldaw [$FF8A]
    oniw [$FF8A], $80
    jr .wait
    ; Reset user timer to track 150 ms.
    mvi a, $80 - 15
    staw [$FF8A]

    ; Add ball delta-x and x-position.
.x:
    ldaw [BALL.DX]
    mov b, a
    ldaw [BALL.X]
    add a, b
    mov b, a

    ; Bounce left if ball is at right edge of screen.
..rbounce:
    gti a, SCRN.WIDTH - BALL.SIZE - 1
    jr ..lbounce  ; if a <= 58
    ldaw [BALL.DX]
    mvi a, -1
    staw [BALL.DX]
    jr ..sound

    ; Bounce right if ball is at left edge of screen.
..lbounce:
    eqi a, 0
    jr ..store  ; if a != 0
    ldaw [BALL.DX]
    mvi a, 1
    staw [BALL.DX]

    ; Play sound if bounce occurred on either side.
..sound:
    push bc
    calt SNDPLAY
    db PITCH.A4, 5
    pop bc

    ; Save updated position back to memory.
..store:
    mov a, b
    staw [BALL.X]

    ; Add ball delta-y and y-position.
.y:
    ldaw [BALL.DY]
    adi a, 1
    staw [BALL.DY]
    mov c, a
    ldaw [BALL.Y]
    add a, c
    mov c, a

    ; Bounce if ball is at bottom of screen.
    gti a, SCRN.HEIGHT - 2 - BALL.SIZE - 1
    jr ..store  ; if a <= 45
    ldaw [BALL.DY]
    mov d, a
    mvi a, $FF
    sub a, d
    staw [BALL.DY]

    ; Play sound if bounce occurred.
    push bc
    calt SNDPLAY
    db PITCH.A3, 5
    pop bc

    ; Save updated position back to memory.
..store:
    mov a, c
    staw [BALL.Y]

    jmp .loop


vars:
.ballx:
    db 4
.bally:
    db 1
.balldx:
    db 1
.balldy:
    db 0
.len = $ - vars

#fn tile2bpp(data, n) => {
    begin = sizeof(data) - n*128
    tile = data[begin-1:begin-128]
    white = (
        tile[127:120] @
        tile[111:104] @
        tile[95:88] @
        tile[79:72] @
        tile[63:56] @
        tile[47:40] @
        tile[31:24] @
        tile[15:8]
    )
    black = (
        tile[119:112] @
        tile[103:96] @
        tile[87:80] @
        tile[71:64] @
        tile[55:48] @
        tile[39:32] @
        tile[23:16] @
        tile[7:0]
    )
    white @ black
}

tile:
.ball = incbin("ball.2bpp")
    #d tile2bpp(.ball, 2)
    #d tile2bpp(.ball, 3)
    #d tile2bpp(.ball, 0)
    #d tile2bpp(.ball, 1)
.len = $ - tile

obj:
    db $80, $80, $00
    db $80, $80, $01
    db $80, $80, $02
    db $80, $80, $03
.len = $ - obj

MAX_LIT = $10
#fn LIT(cols) => {
    assert(sizeof(cols) % 8 == 0)
    n = sizeof(cols) / 8
    assert((n > 0) && (n <= MAX_LIT))
    (n - 1)`8 @ cols
}
#fn RUN(n, off) => {
    assert((n > 0) && (n <= $FF - MAX_LIT - 1))
    (MAX_LIT + (n - 1))`8 @ off`8
}
#const END = 0xFF

grid:
    #d RUN(4, 1)
    #d LIT(%11110000_00010000)
    #d RUN(4, 1)
    #d RUN(61, 6)
    #d RUN(8, 75)
    #d LIT(%11111111_00000100)
    #d RUN(4, 1)
    #d RUN(61, 6)
    #d RUN(8, 75)
    #d LIT(%11111111_01000001)
    #d RUN(4, 1)
    #d RUN(61, 6)
    #d RUN(8, 75)
    #d LIT(%11111111_00010000)
    #d RUN(4, 1)
    #d RUN(61, 6)
    #d RUN(230, 225)
    #d LIT(%10000000_01100000_01011000_01010111_01010100_01010100_11010100_01110100_01011100)
    #d RUN(9, 6)
    #d LIT(%01010100_01010100_11110100_01011111)
    #d RUN(12, 6)
    #d LIT(%01010100)
    #d RUN(4, 1)
    #d LIT(%01011111_11110100)
    #d RUN(16, 6)
    #d LIT(%01010111_01011100_01110100_11010100)
    #d RUN(9, 6)
    #d LIT(%01011000_01100000_10000000)
    #d END
