#include "7806.asm"

CARTCHK   = $0080
SCRN2LCD  = $0082
SNDPLAY   = $0084
MUSPLAY   = $0086
JOYREAD   = $0088
ACCCLR    = $008A
SCR2CLR   = $008C
SCR1CLR   = $008E
TILECLR   = $0090
CALT92    = $0092
MEMCLR    = $0094
ADDRHLDE  = $0096
ADDRHLI   = $0098
ADDRHLE   = $009A
SCRNSWAP  = $009C
SCR1COPY  = $009E
SCR2COPY  = $00A0
CALTA2    = $00A2
CALTA4    = $00A4
MULTIPLY  = $00A6
BYTEXCHG  = $00A8
MEMCOPY   = $00AA
MEMRCPY   = $00AC
MEMSWAP   = $00AE
DRAWDOT   = $00B0
DRAWLINE  = $00B2
DRAWHEX   = $00B4
DRAWTEXT  = $00B6
FONTGET   = $00B8
SCR1LOC   = $00BA
TILELOC   = $00BC
MEMSET    = $00BE
NIBLSWAP  = $00C0
MEMSUB    = $00C2
MEMCMP    = $00C4
MEMCCPY   = $00C6
ARITHMTC  = $00C8
TILEINV   = $00CA
SCR1INV   = $00CC
SCR2INV   = $00CE
CALTD0    = $00D0
CALTD2    = $00D2
CALTD4    = $00D4
CALTD6    = $00D6
MEMBUMP   = $00D8
ERASDOT   = $00DA

USER4012  = $00DC
USER4015  = $00DE
USER4018  = $00E0
USER401B  = $00E2
USER401E  = $00E4
USER4021  = $00E6
USER4024  = $00E8
USER4027  = $00EA
USER402A  = $00EC
USER402D  = $00EE

#const LCD = struct {
    WIDTH   = 50
    HEIGHT  = 32
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
}

#const TIME = struct {
    BCD = struct {
        HUN = $FF86
        SEC = $FF87
        SUB = $FF88
    }
    SEC = $FF89
}
