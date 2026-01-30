#include "pd7806.asm"

CARTCHK   = $0080  ; [PC+1] Check for cartridge and run if present
SCRN2LCD  = $0082  ; Send contents of screen 1 to LCD controllers
SNDPLAY   = $0084  ; [PC+2] Start playing single tone
MUSPLAY   = $0086  ; Start playing music track
JOYREAD   = $0088  ; Read controller data to JOY.{DIR,BTN}.{PREV,CURR,EDGE}
ACCCLR    = $008A  ; Clear accumulator register (a)
SCR2CLR   = $008C  ; Clear screen 2 area of WRAM
SCR1CLR   = $008E  ; Clear screen 1 area of WRAM
OBJCLR    = $0090  ; Clear object tile and data area of WRAM
WRAMCLR   = $0092  ; Clear general purpose area of WRAM
MEMCLR    = $0094  ; Clear memory in hl..hl+b
ADDRHLDE  = $0096  ; hl += de
ADDRHLI   = $0098  ; [PC+1] hl += immediate value
ADDRHLE   = $009A  ; hl += e
SCRNSWAP  = $009C  ; Swap screen 1 and screen 2
SCR1COPY  = $009E  ; Copy screen 1 from screen 2
SCR2COPY  = $00A0  ; Copy screen 2 from screen 1
SCRNCOMP  = $00A2  ; Composite screen 2 and objects into screen 1
OBJDRAW   = $00A4  ; Draw objects into screen 1
MULTIPLY  = $00A6  ; hl = a*e
XCHGHLDE  = $00A8  ; hl, de = de, hl
MEMCOPY   = $00AA  ; Copy memory from hl..hl+b to de..de+b
MEMRCPY   = $00AC  ; Copy memory from hl-b..hl to de-b..de
MEMSWAP   = $00AE  ; Swap memory between hl..hl+b and de..de+b
DRAWDOT   = $00B0  ; Draw screen 2 pixel at (x, y) position (b, c)
DRAWLINE  = $00B2  ; [PC+2]
DRAWHEX   = $00B4  ; [PC+3]
DRAWTEXT  = $00B6  ; [PC+3]
FONTGET   = $00B8  ; Get address of font data
SCR1LOC   = $00BA  ; Get screen 1 address of (x, y) position (b, c)
TILELOC   = $00BC  ; Get address of object tile index a
MEMSET    = $00BE  ; Set memory in hl..hl+b to a
ACC4RAR   = $00C0  ; Rotate accumulator register (a) right 4 times
MEMSUB    = $00C2  ; a = *(de+) - *(hl+)
MEMCMP    = $00C4
MEMCCPY   = $00C6
ARITHMTC  = $00C8
TILEINV   = $00CA  ; Invert object tile at index a
SCR1INV   = $00CC  ; Invert screen 1
SCR2INV   = $00CE  ; Invert screen 2
TILEHFLP  = $00D0  ; [PC+1] Flip object tile horizontally
TILEVFLP  = $00D2  ; [PC+1] Flip object tile vertically
TILEFLIP  = $00D4  ; [PC+1] Flip object tile across both axes
OBJMOVE   = $00D6  ; [PC+1+N] Move multiple objects
MEMBUMP   = $00D8
ERASDOT   = $00DA  ; Clear screen 2 pixel at (x, y) position (b, c)

USER0     = $00DC
USER1     = $00DE
USER2     = $00E0
USER3     = $00E2
USER4     = $00E4
USER5     = $00E6
USER6     = $00E8
USER7     = $00EA
USER8     = $00EC
USER9     = $00EE

#fn reduce(input, chunk, initial, callback) => {
    len = $sizeof(input)
    $assert(len % chunk == 0)
    len == chunk ? {
        callback(initial, input)
    } : {
        split = (len / chunk / 2) * chunk
        $assert(split < len)
        $assert(split > 0)
        middle = reduce(input[len-1:split], chunk, initial, callback)
        final = reduce(input[split-1:0], chunk, middle, callback)
        final
    }
}

#fn largereducer(out, ch) => {
    $assert((" " <= ch) && (ch <= "_"))
    out @ (ch - $20)`8
}

#fn smallreducer(out, ch) => {
    is_space = (ch`8 == $20)
    is_number = ("0" <= ch) && (ch <= "9")
    is_upper = ("A" <= ch) && (ch <= "Z")
    $assert(is_space || is_number || is_upper)
    out @ (is_space ? 0 : is_number ? (ch - "0" + $40) : (ch - "A" + $4A))`8
}

#fn largetext(s) => reduce(s, 8, "", largereducer)
#fn smalltext(s) => reduce(s, 8, "", smallreducer)

#const CART = struct {
    HEADER  = $4000  ; [1B] must be CART.MAGIC ($55)
    MAIN    = $4001  ; [2B] proc address for normal startup
    MAIN2   = $4003  ; [2B] proc address for hot-swap startup
    FONT    = $4005  ; [2B] address of font table
    UNKN    = $4007  ; [2B] proc address of unknown procedure
    INTT    = $4009  ; [3B] handler, usually “jmp $4XXX”
    INT0    = $400C  ; [3B] handler, usually “jmp $4XXX”
    INT1    = $400F  ; [3B] handler, usually “jmp $4XXX”
    USER0   = $4012  ; [3B] handler, usually “jmp $4XXX”
    USER1   = $4015  ; [3B] handler, usually “jmp $4XXX”
    USER2   = $4018  ; [3B] handler, usually “jmp $4XXX”
    USER3   = $401B  ; [3B] handler, usually “jmp $4XXX”
    USER4   = $401E  ; [3B] handler, usually “jmp $4XXX”
    USER5   = $4021  ; [3B] handler, usually “jmp $4XXX”
    USER6   = $4024  ; [3B] handler, usually “jmp $4XXX”
    USER7   = $4027  ; [3B] handler, usually “jmp $4XXX”
    USER8   = $402A  ; [3B] handler, usually “jmp $4XXX”
    USER9   = $402D  ; [3B] handler, usually “jmp $4XXX”
    BEGIN   = $4030  ; End of header, start of code

    MAGIC = $55
}

#const LCD = struct {
    WIDTH   = 50
    HEIGHT  = 32

    RW   = %00000001  ; Hypothetical
    E    = %00000010
    DI   = %00000100
    CS1  = %00001000
    CS2  = %00010000
    CS3  = %00100000
    I = struct {
        ON     = %00111001   ; Turn LCD on
        OFF    = %00111000   ; Turn LCD off
        START  = %00111110   ; Show page N first
        P1     = (0 << 6)`8  ; Top 50x8 slice of LCD
        P2     = (1 << 6)`8  ; Second 50x8 slice of LCD
        P3     = (2 << 6)`8  ; Third 50x8 slice of LCD
        P4     = (3 << 6)`8  ; Bottom 50x8 slice of LCD
        POFF   = (1 << 6)`8  ; Offset between pages
    }
}

#const SCRN = struct {
    WIDTH   = 75
    HEIGHT  = 64
    AREA    = 75 * 64   ; 4800 = WIDTH * HEIGHT
    BYTES   = 4800 / 8  ; 600 = AREA / 8
}

#const SCR1 = struct {
    BEGIN        = $C000
    END          = $C000 + SCRN.BYTES
    SIZE         = SCRN.BYTES
    LCD1_START   = $C000 + LCD.WIDTH - 1
    LCD2_START   = $C000 + SCRN.BYTES/2
    LCD3A_START  = $C000 + LCD.WIDTH
    LCD3B_START  = $C000 + SCRN.BYTES/2 + LCD.WIDTH
}

#const SCR2 = struct {
    BEGIN  = SCR1.END
    END    = SCR1.END + SCRN.BYTES
    SIZE   = SCRN.BYTES
}

#const OBJ = struct {
    BEGIN  = SCR2.END
    END    = SCR2.END + 16*12 + 3*12

    ; 8 bytes to draw white (mask), then 8 bytes to draw black (set)
    TILE = struct {
        SIZE = 16
        COUNT = 12
        BEGIN = SCR2.END
        END = SCR2.END + 16*12
    }

    COUNT   = 12
    WIDTH   = 8
    HEIGHT  = 8

    O0   = struct { X = $C570, Y = $C571, TILE = $C572 }
    O1   = struct { X = $C573, Y = $C574, TILE = $C575 }
    O2   = struct { X = $C576, Y = $C577, TILE = $C578 }
    O3   = struct { X = $C579, Y = $C57A, TILE = $C57B }
    O4   = struct { X = $C57C, Y = $C57D, TILE = $C57E }
    O5   = struct { X = $C57F, Y = $C580, TILE = $C581 }
    O6   = struct { X = $C582, Y = $C583, TILE = $C584 }
    O7   = struct { X = $C585, Y = $C586, TILE = $C587 }
    O8   = struct { X = $C588, Y = $C589, TILE = $C58A }
    O9   = struct { X = $C58B, Y = $C58C, TILE = $C58D }
    O10  = struct { X = $C58E, Y = $C58F, TILE = $C590 }
    O11  = struct { X = $C591, Y = $C592, TILE = $C593 }
}

#const FONT = struct {
    WIDTH = 5
    COUNT = $64
}

#const TEXT = struct {
    ; Screen: DRAWHEX or DRAWTEXT
    SCR1 = $80
    SCR2 = $00

    ; Spacing: 0-3: DRAWHEX or DRAWTEXT; 4-7: DRAWTEXT only
    SPC0 = $00
    SPC1 = $10
    SPC2 = $20
    SPC3 = $30
    SPC4 = $40
    SPC5 = $50
    SPC6 = $60
    SPC7 = $70

    ; Font: DRAWHEX only
    LARGE = $00
    SMALL = $40

    ; Alignment: DRAWHEX only
    RALIGN = $00
    LALIGN = $08
}

#const ARITH = struct {
    BCD = $00  ; binary-coded decimal
    BIN = $80  ; binary value

    ADD = $00  ; add [de] to [hl]
    SUB = $40  ; subtract [de] from [hl]

    HL1 = $00  ; sizeof(hl) = 1
    HL2 = $10  ; sizeof(hl) = 2
    HL3 = $20  ; sizeof(hl) = 3
    HL4 = $30  ; sizeof(hl) = 4

    DE1 = $00  ; sizeof(hl) = 1
    DE2 = $04  ; sizeof(hl) = 2
    DE3 = $08  ; sizeof(hl) = 3
    DE4 = $0c  ; sizeof(hl) = 4

    HLW = $02  ; HL gets bytes from $FFB1
    DEW = $01  ; DE gets bytes from $FFA2
}

#const JOY = struct {
    DIR = struct {
        PREV = $FF90
        CURR = $FF92
        EDGE = $FF94

        UP_F = 0
        LT_F = 1
        DN_F = 2
        RT_F = 3

        UP = %00000001  ; 1 << UP_F
        LT = %00000010  ; 1 << LT_F
        DN = %00000100  ; 1 << DN_F
        RT = %00001000  ; 1 << RT_F

        ANY = %00001111  ; UP | LT | DN | RT
    }
    BTN = struct {
        PREV = $FF91
        CURR = $FF93
        EDGE = $FF95

        SEL_F = 0
        BT1_F = 1
        BT3_F = 2
        STA_F = 3
        BT2_F = 4
        BT4_F = 5

        SEL = %00000001  ; 1 < SEL
        BT1 = %00000010  ; 1 < BT1
        BT3 = %00000100  ; 1 < BT3
        STA = %00001000  ; 1 < STA
        BT2 = %00010000  ; 1 < BT2
        BT4 = %00100000  ; 1 < BT4

        ANY = %00111111  ; STA | SEL | BT1 | BT2 | BT3 | BT4
    }

    CS1 = %01000000
    CS2 = %10000000
}

#const TIME = struct {
    BCD = struct {
        HUN = $FF86
        SEC = $FF87
        SUB = $FF88
    }
    SEC = $FF89
}

#const PITCH = struct {
    NONE  = 0
    G3    = 1
    GS3   = 2
    A3    = 3
    AS3   = 4
    B3    = 5
    C4    = 6
    CS4   = 7
    D4    = 8
    DS4   = 9
    E4    = 10
    F4    = 11
    FS4   = 12
    G4    = 13
    GS4   = 14
    A4    = 15
    AS4   = 16
    B4    = 17
    C5    = 18
    CS5   = 19
    D5    = 20
    DS5   = 21
    E5    = 22
    F5    = 23
    FS5   = 24
    G5    = 25
    GS5   = 26
    A5    = 27
    AS5   = 28
    B5    = 29
    C6    = 30
    CS6   = 31
    D6    = 32
    DS6   = 33
    E6    = 34
    F6    = 35
    FS6   = 36
    G6    = 37
}
