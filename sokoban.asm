#include "gamepock.asm"

VERSION_FINAL = 0
VERSION_PRE0125 = 1_25
VERSION = VERSION_FINAL

#bankdef rom
{
    addr = $4000
    size = $2000
    fill = true
    outp = 0
}

LVL_W_NIBBLES   = 19                       ;
LVL_W_BYTES     = (LVL_W_NIBBLES + 1) / 2  ; = 10
LVL_H           = 17                       ;
LVL_SZ_BYTES    = LVL_W_BYTES * LVL_H      ; = 170
LVL_FIRST_ROW   = 0
LVL_SECOND_ROW  = LVL_W_BYTES
LVL_LAST_ROW    = LVL_SZ_BYTES - LVL_W_BYTES
LVL_FIRST       = 1
LVL_LAST        = 65

TILE_EMPTY   = $0
TILE_WALL    = $1
TILE_TARGET  = $2
TILE_PLAYER  = $4
TILE_CRATE   = $8

var_lvlmap   = OBJ.END
var_backup  = var_lvlmap + LVL_SZ_BYTES
var_loaded  = var_backup + LVL_SZ_BYTES

FLAG0_0  = $01
FLAG0_1  = $02
FLAG0_2  = $04
FLAG0_3  = $08
FLAG0_4  = $10
FLAG0_5  = $20
FLAG0_6  = $40
FLAG0_7  = $80

FLAG1_0        = $01
FLAG1_1        = $02
FLAG1_FORFEIT  = $40  ; start level select from forfeited level
FLAG1_7        = $80

MODE_PLAY    = $00
MODE_EDITOR  = $01
MODE_EPLAY   = $02
MODE_MAX     = MODE_EPLAY

var_flags0       = $ffd0
var_flags1       = $ffd1
var_mode         = $ffd2  ; 0 = play, 1 = editor, 2 = eplay
var_level        = $ffd3  ; 0~65
var_attempts     = $ffd4  ; 1~5
var_player_x0    = $ffdc
var_player_y0    = $ffdd
var_player_x1    = $ffe5
var_player_y1    = $ffe6
var_player_x2    = $ffde
var_player_y2    = $ffdf
var_edit_x       = $ffe0
var_edit_y       = $ffe1
var_edit_crates  = $ffe2
var_demo0        = $ffe7
var_demo1        = $ffe9
var_demo2        = $ffea
var_rle_data     = $ffee
var_rle_len      = $ffef
var_unknown0     = $ffd9
var_unknown1     = $ffda
var_unknown2     = $ffdb
var_unknown3     = $fff0
var_unknown4     = $ffe3
var_unknown5     = $ffe4
var_unknown6     = $ffeb
var_unknown7     = $ffec

header:
    db CART.MAGIC
    dw setup
    dw setup
    dw font
    dw 0

    jre interrupt

#addr $4030
interrupt:
    oniw [var_flags0], FLAG0_7
.jr4033:
    jmp $0128
    calt JOYREAD
    neiw [JOY.BTN.CURR], JOY.BTN.STA | JOY.BTN.SEL
    jr reset
    neiw [JOY.BTN.CURR], JOY.BTN.STA
    jr reset
    eqiw [JOY.BTN.CURR], JOY.BTN.SEL
    jr .jr4033
    lxi hl, music_step
    calt MUSPLAY
    ; fall through

reset:
    oniw [var_flags1], FLAG1_7
    jr .jr4050
    offiw [$ff80], $03
    calf $0e4d
.jr4050:
    lxi sp, $c800
    jr start

setup:
    di
    calt WRAMCLR
    lxi sp, $c800
    call call409e

start:
    call clear_mem
    ei
.jr4062:
    call draw_title
.jr4065:
    call call491c
    call call4928
.jr406b:
    call call4924
    call show_title
.jr4071:
    calt JOYREAD
    eqiw [JOY.BTN.CURR], JOY.BTN.SEL
    jr .jr407e
    oniw [JOY.BTN.EDGE], JOY.BTN.SEL
    jr .jr4094
    call cycle_menu
    jr .jr4065
.jr407e:
    eqiw [JOY.BTN.CURR], JOY.BTN.STA
    jr .jr408b
    oniw [JOY.BTN.EDGE], JOY.BTN.STA
    jr .jr4094
    call invoke_menu
    jre .jr4062
.jr408b:
    eqiw [$ff89], $0a
    jr .jr4097
    call run_demo
    jre .jr4062
.jr4094:
    call call4928
.jr4097:
    ltiw [$ff8b], $1e
    jre .jr406b
    jre .jr4071

call409e:
    calt OBJCLR
    staw [var_mode]
    lxi hl, tiles2
    lxi de, OBJ.BEGIN
    mvi c, $0f
.jr40a9:
    mvi b, $03
    calt MEMCOPY
    inx de
    inx de
    inx de
    inx de
    dcr c
    jr .jr40a9
    call clear_obj
    call place_border
    ret

place_border:
    lxi hl, var_loaded
    mvi b, $a9
    calt MEMCLR
    mvi c, $01
.jr40c1:
    mov a, c
    eqi a, $01
    lxi hl, var_loaded + LVL_LAST_ROW
    lxi hl, var_loaded + LVL_FIRST_ROW
    mvi a, TILE_WALL @ TILE_WALL
    mvi b, LVL_W_BYTES - 1
    calt MEMSET
    dcr c
    jr .jr40c1
    lxi hl, var_loaded + LVL_SECOND_ROW  ; second row, first column
    lxi de, LVL_W_BYTES - 1              ; offset first to last column
    mvi b, LVL_H - 3
.jr40d9:
    mvi a, TILE_EMPTY @ TILE_WALL
    stax [hl]
    calt ADDRHLDE
    mvi a, $01
    stax [hl+]
    dcr b
    jr .jr40d9
    ret

clear_mem:
    ; Clear $ffd0 to $ffff, but preserve var_mode
    ldaw [var_mode]
    mov c, a
    lxi hl, var_flags0
    mvi b, $2f
    calt MEMCLR
    mov a, c
    staw [var_mode]
    ret

draw_title:
    calt SCR2CLR

    lxi hl, text_logo_top
    calt DRAWTEXT
    db $0c, $01, text_logo_top.size

    lxi hl, text_logo_bottom
    calt DRAWTEXT
    db $0c, $09, text_logo_bottom.size

    lxi hl, text_store
    calt DRAWTEXT
    db $17, $12, $10 | text_store.size

    lxi hl, text_keepers
    calt DRAWTEXT
    db $11, $19, $10 | text_keepers.size

    lxi hl, SCR2.BEGIN + 2*75 + 13
    mvi a, $f8
    stax [hl+]
    mvi a, $04
    stax [hl]
    lxi hl, SCR2.BEGIN + 2*75 + 60
    stax [hl+]
    mvi a, $f8
    stax [hl]
    lxi hl, SCR2.BEGIN + 3*75 + 13
    mvi a, $1f
    stax [hl+]
    mvi a, $20
    stax [hl]
    lxi hl, SCR2.BEGIN + 3*75 + 60
    stax [hl+]
    mvi a, $1f
    stax [hl]

    lxi hl, text_play
    calt DRAWTEXT
    db $11, $22, $10 | text_play.size

    lxi hl, text_editor
    calt DRAWTEXT
    db $11, $2c, $10 | 3

    lxi hl, text_editor + 3
    calt DRAWTEXT
    db $22, $2c, 1

    lxi hl, text_editor + 4
    calt DRAWTEXT
    db $27, $2c, $10 | (text_editor.size - 4)

    lxi hl, text_eplay
    calt DRAWTEXT
    db $11, $36, $10 | 3

    lxi hl, text_eplay + 3
    calt DRAWTEXT
    db $22, $36, $10 | (text_eplay.size - 3)

    ret

show_title:
    calt SCR2COPY
    oniw [var_flags0], FLAG0_2
    jr .jr4170
    ldaw [var_mode]
    mov b, a
    mvi a, $17
    mvi c, $0a
.jr4164:
    add a, c
    dcr b
    jr .jr4164
    mov c, a
    mvi b, $11
    mvi a, $28
    call call4c36
.jr4170:
    calt SCRN2LCD
    call call498b
    ret

cycle_menu:
    lxi hl, music_step
    calt MUSPLAY
    ldaw [var_mode]
    inr a
    nop
    gti a, MODE_MAX
    jr .save
    calt ACCCLR
.save:
    staw [var_mode]
    ret

invoke_menu:
    eqiw [var_mode], MODE_PLAY
    jr .jr418c
    call invoke_game
    jr .jr4196
.jr418c:
    eqiw [var_mode], MODE_EDITOR
    jr .jr4193
    call invoke_editor
.jr4193:
    call invoke_eplay
.jr4196:
    ret

run_demo:
    ldaw [var_level]
    push va
    calt ACCCLR
    staw [var_level]
    call call493d
    call call491c
    call call4920
    oriw [var_flags0], FLAG0_7
    lxi hl, demo_input
    ldax [hl+]
    staw [var_demo2]
    shld [var_demo0]
    mvi a, $03
    staw [var_demo1]
    call call46b7
    call call4a2d
    lxi hl, text_dis
    calt DRAWTEXT
    db $12, $04, text_dis.size
    lxi hl, text_play3
    calt DRAWTEXT
    db $22, $04, $10 | 4
    call call4902
    mvi b, $05
    call call4967
    call call4924
.jr41d7:
    gtiw [var_demo2], $00
    jre .jr4229
    gtiw [var_unknown4], $00
    jre .jr4229
    gtiw [var_unknown5], $00
    jre .jr4229
    mvi a, $00
    staw [var_unknown6]
.jr41ea:
    gtiw [var_unknown6], $00
    jr .jr41f9
.jr41ee:
    gtiw [$ff8b], $1d
    jr .jr41ee
    call call48fc
    dcrw [var_unknown6]
    nop
    jr .jr41ea
.jr41f9:
    lhld [var_demo0]
    ldaw [var_demo1]
    mov b, a
    ldax [hl]
.jr4201:
    dcr b
    jr .jr4204
    jr .jr4209
.jr4204:
    rar
    rar
    jr .jr4201
.jr4209:
    ani a, FLAG0_0 | FLAG0_1
    mov b, a
    ldaw [var_flags0]
    ani a, !(FLAG0_0 | FLAG0_1)
    ora a, b
    staw [var_flags0]
    dcrw [var_demo1]
    jr .jr4220
    mvi a, $03
    staw [var_demo1]
    inx hl
    shld [var_demo0]
.jr4220:
    dcrw [var_demo2]
    nop
    call try43f5
    nop
    jre .jr41d7
.jr4229:
    call win_level
    mvi b, $03
    call call4967
    pop va
    staw [var_level]
    ret

invoke_game:
    offiw [var_flags1], FLAG1_FORFEIT
    jr .start
    mvi a, LVL_FIRST
    staw [var_level]

.start:
    call call491c
    call call493d
    calt SNDPLAY
    db PITCH.A4, 6

.load:
    call call46b7
    call call4a2d
    call call4a9a
    mvi b, $04
    mvi c, $00
    mvi a, $43
    call call4c36
    mvi c, $01
    call call4c36
    lxi hl, text_start
    calt DRAWTEXT
    db $06, $01, $90 | text_start.size
    lxi hl, text_no
    calt DRAWTEXT
    db $28, $01, $90 | text_no.size
    lxi hl, var_level
    calt DRAWHEX
    db $3a, $01, $99
    calt SCRN2LCD

.change:
    calt JOYREAD

    neiw [JOY.BTN.CURR], JOY.BTN.STA | JOY.BTN.SEL
    jmp reset
    eqiw [JOY.BTN.CURR], JOY.BTN.STA
    jr ..by10
    oniw [JOY.BTN.EDGE], JOY.BTN.STA
    jr .change

    call play_level
    jre .done

..by10:
    eqiw [JOY.BTN.CURR], JOY.BTN.BT1
    jr ..by1
    oniw [JOY.BTN.EDGE], JOY.BTN.BT1
    jr .change
    call inc_level10
    jr ..modified

..by1:
    eqiw [JOY.BTN.CURR], JOY.BTN.BT2
    jre .change
    oniw [JOY.BTN.EDGE], JOY.BTN.BT2
    jre .change
    call inc_level1

..modified:
    lxi hl, music_step
    calt MUSPLAY
    jre .load

.done:
    ret

; Increase [var_level] by 1 and handle boundary conditions:
;
; * if level == 65, then level = 60
; * else if level == 9, then level = 1
; * else if level % 10 == 9, then level -= 9
; * else level += 1
inc_level1:
    call set_cb_from_level  ; a = c = tens, b = ones
    inr b                   ; ones += 1
    nop

    gti a, (LVL_LAST / 10) - 1  ; test tens >= 6
    jr .not_sixty               ; else goto .not_sixty
    mov a, b                    ;
    gti a, LVL_LAST % 10        ; test ones >= 5
    jr .done                    ; else goto .done
    mvi b, 0                    ; ones = 0
    jr .done                    ; goto .done

.not_sixty:
    mov a, b  ;
    gti a, 9  ; test ones >= 9
    jr .done  ; else goto .done
    mvi b, 0  ; ones = 0
    mov a, c  ;
    dcr a     ; test tens > 0
    jr .done  ; else goto .done
    inr b     ; ones += 1
    nop       ;

.done:
    call set_level_from_cb
    ret

; Increase [var_level] by 10 and handle boundary conditions:
;
; * if level == 60, then level = 1
; * else if level > 60, then level = level - 60
; * else if level > 55, then level = level - 50
; * else level = level + 10
inc_level10:
    call set_cb_from_level  ; c = tens, b = ones
    inr c                   ; tens += 1
    nop
    mov a, c

    gti a, LVL_LAST / 10  ; test tens > 6
    jr .not_sixty         ; else goto .not_sixty
    mvi c, 0              ; tens = 0
    mov a, b              ;
    nei a, 0              ; test ones != 0
    mvi b, 1              ; else ones = 1
    jr .done              ; goto .done

.not_sixty:
    eqi a, LVL_LAST / 10  ; test tens != 6
    jr .done              ; else goto .done
    mov a, b              ;
    gti a, LVL_LAST % 10  ; test ones > 5
    jr .done              ; else goto .done
    mvi c, 0              ; tens = 0

.done:
    call set_level_from_cb
    ret

; a = c = [var_level] / 10
; b = [var_level] % 10
set_cb_from_level:
    lxi hl, var_level
    calt ACCCLR
    rrd
    mov b, a
    rrd
    mov c, a
    ret

; [var_level] = c*10 + b
set_level_from_cb:
    mov a, b
    rrd
    mov a, c
    rrd
    ret

play_level:
    mvi a, $01
    staw [var_attempts]
.jr42fa:
    call begin_level
    call call491c
    call call4920
.jr4303:
    neiw [var_player_x0], $00
    jr .jr4311
    gtiw [var_unknown4], $00
    jre .jr4363
    gtiw [var_unknown5], $00
    jre .jr4363
.jr4311:
    calt JOYREAD
    neiw [JOY.BTN.CURR], JOY.BTN.STA | JOY.BTN.SEL
    jmp reset
    eqiw [JOY.BTN.CURR], JOY.BTN.BT3
    jr .jr432c
    offiw [JOY.BTN.EDGE], JOY.BTN.BT3
    jr .jr4325
    oniw [var_flags1], FLAG1_7
    jre .jr4359
.jr4325:
    call try_undo
    jre .jr4359
    jre .jr434d
.jr432c:
    eqiw [JOY.BTN.CURR], JOY.BTN.STA
    jr .jr433b
    oniw [JOY.BTN.EDGE], JOY.BTN.STA
    jr .jr434d
    call try_forfeit
    jre .jr4369
    jre .jr42fa
.jr433b:
    offiw [JOY.BTN.CURR], JOY.BTN.ANY
    jr .jr4354
    oniw [JOY.DIR.CURR], JOY.DIR.ANY
    jr .jr434d
    call try_move
    jr .jr434d
    call try43f5
    jr .jr4359
    jre .jr4303
.jr434d:
    oniw [var_flags1], FLAG1_7
    jr .jr4359
    aniw [var_flags1], !FLAG1_7`8
.jr4354:
    offiw [$ff80], $03
    calf $0e4d
.jr4359:
    gtiw [$ff8b], $1d
    jre .jr4311
    call call48fc
    jre .jr4311
.jr4363:
    call try44fc
    jr .jr4369
    jre .jr42fa
.jr4369:
    ret

begin_level:
    call call491c
    neiw [var_mode], MODE_PLAY
    jr .jr437e
    lxi hl, var_loaded
    lxi de, var_lvlmap
    mvi b, $a9
    calt MEMCOPY
    call call4bd3
    jr .jr4381
.jr437e:
    call call46b7
.jr4381:
    call call4a2d
    call call4a9a
    neiw [var_mode], MODE_PLAY
    jr .jr43a8
    mvi b, $0f
    mvi c, $08
    mvi a, $2e
    call call4c36
    mvi c, $0a
    call call4c36

    lxi hl, text_e2
    calt DRAWTEXT
    db $0f, $0a, $90 | text_e2.size

    lxi hl, text_play3
    calt DRAWTEXT
    db $20, $0a, $90 | text_play3.size

    jr .jr43c4
.jr43a8:
    mvi b, $11
    mvi c, $08
    mvi a, $29
    call call4c36
    mvi c, $0a
    call call4c36
    lxi hl, text_no2
    calt DRAWTEXT
    db $11, $0a, $90 | text_no2.size
    lxi hl, var_level
    calt DRAWHEX
    db $29, $0a, $99
.jr43c4:
    mvi b, $04
    mvi c, $18
    mvi a, $43
    call call4c36
    mvi c, $1a
    call call4c36
    lxi hl, text_challenge
    calt DRAWTEXT
    db $06, $1a, $90 | text_challenge.size
    lxi hl, var_attempts
    calt DRAWHEX
    db $40, $1a, $80
    calt SCRN2LCD
    lxi hl, music_start
    calt MUSPLAY
    call call4986
    oriw [var_flags0], FLAG0_6
    call call4a2d
    call call48ff
    calt SNDPLAY
    db PITCH.A4, 6
    ret

try43f5:
    call try448d
    jre .jr4488
    aniw [var_flags0], !FLAG0_2
    oriw [var_flags0], FLAG0_3
    neiw [var_player_x2], $00
    jr .jr4413
    call call49a4
    call call484e
    oni a, $02
    mvi a, $04
    mvi a, $02
    call call4b18
.jr4413:
    offiw [var_flags0], FLAG0_7
    jr .jr441f
    oniw [JOY.DIR.EDGE], JOY.DIR.ANY
    jr .jr441f
    offiw [var_flags0], FLAG0_3
    jr .jr442c
.jr441f:
    neiw [var_player_x2], $00
    mvi a, $0c
    mvi a, $10
    mov b, a
.jr4427:
    ldaw [$ff8b]
    gta a, b
    jr .jr4427
.jr442c:
    oniw [var_flags0], FLAG0_3
    jr .jr4434
    lxi hl, music4fb1
    calt MUSPLAY
.jr4434:
    call call48ff
    oniw [var_flags0], FLAG0_3
    jre .jr448c
    lxi hl, var_lvlmap
    lxi de, var_backup
    mvi b, $a9
    calt MEMCOPY
    call call4992
    mvi a, $8b
    call call4878
    call call49f2
    call call499b
    mvi a, $04
    call call4878
    oni a, $08
    jre .jr4480
    oni a, $02
    jr .jr4465
    inrw [var_unknown4]
    nop
    inrw [var_unknown5]
    nop
.jr4465:
    mvi a, $87
    call call4878
    call call49f2
    mvi a, $08
    call call4878
    oni a, $02
    jr .jr447b
    dcrw [var_unknown4]
    nop
    dcrw [var_unknown5]
    nop
.jr447b:
    mvi a, $08
    call call4b18
.jr4480:
    oriw [var_flags0], FLAG0_4
    aniw [var_flags0], !FLAG0_3
    jre .jr4413
.jr4488:
    call play_err_beep
    ret
.jr448c:
    rets

try448d:
    call call4992
    call try49c8
    jre .jr44be
    call call49f2
    call try49c8
    jre .jr44be
    call call484e
    offi a, $01
    jr .jr44be
    oni a, $08
    jr .jr44ba
    call call49ad
    call call49f2
    call try49c8
    jr .jr44be
    call call484e
    offi a, $01
    jr .jr44be
    offi a, $08
    jr .jr44be
    jr .jr44bd
.jr44ba:
    call call4941
.jr44bd:
    rets
.jr44be:
    ret

try_undo:
    oniw [var_flags0], FLAG0_4
    jr .jr44e0
    lxi hl, music_undo
    calt MUSPLAY
    call call4986
    call call491c
    lxi hl, var_backup
    lxi de, var_lvlmap
    mvi b, $a9
    calt MEMCOPY
    call call4bd3
    call call4a2d
    call call48ff
    rets
.jr44e0:
    call play_err_beep
    ret

try_forfeit:
    inrw [var_attempts]
    nop
    gtiw [var_attempts], $05
    jr .jr44f8
    neiw [var_mode], MODE_PLAY
    oriw [var_flags1], FLAG1_FORFEIT
    call lose_level
    call call4970
    ret
.jr44f8:
    calt SNDPLAY
    db PITCH.G4, 20
    rets

try44fc:
    eqiw [var_mode], MODE_PLAY
    jr .jr4518
    call set_cb_from_level
    mov a, b
    inr a
    nop
    gti a, $09
    jr .jr450c
    calt ACCCLR
    inr c
    nop
.jr450c:
    mov b, a
    call set_level_from_cb
    mov a, c
    gti a, $05
    jr .jr451f
    mov a, b
    gti a, $05
    jr .jr451f
.jr4518:
    call win_level
    call call4970
    ret
.jr451f:
    call win_level
    mvi b, $03
    call call4967
    mvi a, $01
    staw [var_attempts]
    rets

invoke_eplay:
    calt SNDPLAY
    db PITCH.A4, 6
    call call492e
    call call493d
    call play_level
    ret

invoke_editor:
    calt SNDPLAY
    db PITCH.A4, 6
    call call492e
.jr453f:
    mvi a, $02
    staw [var_edit_x]
    mvi a, $10
    staw [var_edit_y]
    lxi hl, var_loaded
    lxi de, var_lvlmap
    mvi b, $a9
    calt MEMCOPY
    call call4bd3
    neiw [var_player_x0], $00
    jr .jr4562
    call call4992
    mvi a, $8b
    call call4878
    call call4939
.jr4562:
    call call491c
    call call4920
    call call4a2d
    call call48ff
.jr456e:
    aniw [var_flags0], !(FLAG0_4 | FLAG0_5)
    calt JOYREAD
    eqiw [JOY.BTN.CURR], JOY.BTN.STA | JOY.BTN.SEL
    jr .jr4582
    lxi hl, var_lvlmap
    lxi de, var_loaded
    mvi b, $a9
    calt MEMCOPY
    jmp reset
.jr4582:
    eqiw [JOY.BTN.CURR], JOY.BTN.STA
    jr .jr4592
    offiw [JOY.BTN.EDGE], JOY.BTN.STA
    jre .jr45cd
    offiw [var_flags1], FLAG1_7
    jre .jr45cd
    jre .jr45c3
.jr4592:
    eqiw [JOY.BTN.CURR], JOY.BTN.BT2 | JOY.BTN.STA
    jr .jr459f
    oniw [JOY.BTN.EDGE], JOY.BTN.BT2 | JOY.BTN.STA
    jr .jr45b7
    call clear_editor
    jre .jr453f
.jr459f:
    offiw [JOY.BTN.CURR], JOY.BTN.STA | JOY.BTN.SEL
    jr .jr45be
    oniw [JOY.BTN.CURR], JOY.BTN.BT1 | JOY.BTN.BT2 | JOY.BTN.BT3 | JOY.BTN.BT4
    jr .jr45ab
    call try_apply_edit
    jr .jr45be
.jr45ab:
    oniw [JOY.DIR.CURR], JOY.DIR.ANY
    jr .jr45b7
    call try_move
    jr .jr45be
    call call4664
    jr .jr45c3
.jr45b7:
    oniw [var_flags1], FLAG1_7
    jr .jr45c3
    aniw [var_flags1], !FLAG1_7`8
.jr45be:
    offiw [$ff80], $03
    calf $0e4d
.jr45c3:
    gtiw [$ff8b], $1d
    jre .jr456e
    call call48fc
    jre .jr456e
.jr45cd:
    call try_chk_start
    jr .jr45c3
    ret

try_apply_edit:
    neiw [JOY.BTN.CURR], JOY.BTN.BT1
    jr .jr45e2
    neiw [JOY.BTN.CURR], JOY.BTN.BT3
    jr .jr45e2
    neiw [JOY.BTN.CURR], JOY.BTN.BT4
    jr .jr45e2
    eqiw [JOY.BTN.CURR], JOY.BTN.BT2
    ret
.jr45e2:
    offiw [var_flags1], FLAG1_7
    jre .jr4631
    call call49b6
    call call484e
    eqiw [JOY.BTN.CURR], JOY.BTN.BT1
    jr .jr45f7
    call try_place_wall
    jre .jr462e
    jr .jr460f
.jr45f7:
    eqiw [JOY.BTN.CURR], JOY.BTN.BT3
    jr .jr4601
    call try_place_target
    jre .jr462e
    jr .jr460f
.jr4601:
    eqiw [JOY.BTN.CURR], JOY.BTN.BT4
    jr .jr460b
    call try_place_crate
    jre .jr462e
    jr .jr460f
.jr460b:
    call try_erase_object
    jr .jr462e
.jr460f:
    push va
    call call4859
    pop va
    oni a, $0f
    mvi a, $04
    offi a, $08
    mvi a, $08
    call call4b18
    lxi hl, music_step
    calt MUSPLAY
    aniw [var_flags0], !FLAG0_2
    call call48ff
    oriw [var_flags0], FLAG0_5
.jr462e:
    oriw [var_flags0], FLAG0_4
.jr4631:
    rets

try_place_wall:
    offi a, $01
    ret
    oni a, $08
    jr .jr463b
    dcrw [var_edit_crates]
    nop
.jr463b:
    mvi a, $01
    rets

try_place_target:
    offi a, $02
    ret
    oni a, $08
    jr .jr4647
    ori a, $02
    jr .jr4649
.jr4647:
    mvi a, $02
.jr4649:
    rets

try_place_crate:
    offi a, $08
    ret
    oni a, $02
    jr .jr4653
    ori a, $08
    jr .jr4655
.jr4653:
    mvi a, $08
.jr4655:
    inrw [var_edit_crates]
    nop
    rets

try_erase_object:
    oni a, $0f
    ret
    oni a, $08
    jr .jr4662
    dcrw [var_edit_crates]
    nop
.jr4662:
    calt ACCCLR
    rets

call4664:
    call call49b6
    call call49f2
    call try49c8
    jre .jr4690
    aniw [var_flags1], !FLAG1_7`8
    offiw [var_flags0], FLAG0_5
    jr .jr4679
    calt SNDPLAY
    db PITCH.E4, 6
.jr4679:
    call call49bf
    aniw [var_flags0], !FLAG0_2
    call call48ff
    offiw [JOY.DIR.EDGE], JOY.DIR.ANY
    mvi a, $13
    mvi a, $09
    mov b, a
.jr468a:
    ldaw [$ff8b]
    gta a, b
    jr .jr468a
    jr .jr4693
.jr4690:
    call play_err_beep
.jr4693:
    ret

clear_editor:
    calt SNDPLAY
    db PITCH.C5, 20
    call place_border
    ret

try_chk_start:
    call call49b6
    call call484e
    offi a, $09
    jr .jr46b3
    mvi a, $04
    call call4878
    lxi hl, var_lvlmap
    lxi de, var_loaded
    mvi b, $a9
    calt MEMCOPY
    rets
.jr46b3:
    call play_err_beep
    ret

call46b7:
    call call4c1c
    ldaw [var_level]
    mov b, a
    ani a, $0f
    mov c, a
    mov a, b
    calt ACC4RAR
    ani a, $0f
    call call4962
    mov b, a
    call call495e
    add a, b
    add a, c
    lti a, LVL_LAST + 1
    jre .done
    call call4962
    mov e, a
    lxi hl, levels
    calt ADDRHLE
    ldax [hl+]
    mov e, a
    ldax [hl]
    mov d, a
    ldax [de+]
    gti a, $00
    jre .done
    lti a, $12
    jre .done
    staw [var_unknown0]
    ldax [de+]
    gti a, $00
    jre .done
    lti a, $10
    jre .done
    staw [var_unknown1]
    ldax [de+]
    gti a, $02
    jre .done
    lti a, $14
    jre .done
    staw [var_unknown2]
    call call49e5
    oriw [var_flags1], FLAG1_0
.nibble:
    ldax [de]
    oniw [var_flags1], FLAG1_0
    jr ..lower
    calt ACC4RAR
..lower:
    ani a, $0f
    nei a, $0f
    jre ..jr4738
    push de
    mov b, a
    calf $0c72  ; rar x2
    ani a, $03
    staw [var_rle_data]  ; rle_data = (a & %1100) >> 2
    mov a, b
    ani a, $03
    inr a
    nop
    staw [var_rle_len]  ; rle_len = (a & %0011) + 1
    call try4740
    jr ..done
    call try4760
    jr ..done
    ldaw [var_flags1]
    xri a, FLAG1_0
    staw [var_flags1]
    pop de
    oni a, $01
    jr ..no_advance
    inx de
..no_advance:
    jre .nibble
..jr4738:
    inx de
    call call47db
    jr .done
..done:
    pop de

.done:
    ret

try4740:
    eqiw [var_rle_data], $03
    jr .jr475f
    eqiw [var_unknown3], $00
    jr .jr4750
    call call49d9
    gtiw [var_player_y1], $11
    jr .jr4750
    ret
.jr4750:
    call call499b
    eqiw [var_rle_len], $02
    jr .jr475b
    mvi a, $04
    staw [var_rle_data]
.jr475b:
    mvi a, $01
    staw [var_rle_len]
.jr475f:
    rets

try4760:
    ldaw [var_rle_len]
    mov b, a
    ldaw [var_unknown3]
    mov c, a
    subnb a, b
    jr .jr4779
    staw [var_unknown3]
    call call479a
    oni a, $02
    jr .jr4777
    ldaw [var_unknown5]
    add a, b
    staw [var_unknown5]
.jr4777:
    jre .jr4799
.jr4779:
    xri a, $ff
    inr a
    nop
    staw [var_rle_len]
    mov a, c
    gti a, $00
    jr .jr4790
    mov b, a
    call call479a
    oni a, $02
    jr .jr4790
    ldaw [var_unknown5]
    add a, b
    staw [var_unknown5]
.jr4790:
    call call49d9
    gtiw [var_player_y1], $11
    jre try4760
    ret
.jr4799:
    rets

call479a:
    ldaw [var_rle_data]
    nei a, $03
    jr .jr47a4
    eqi a, $04
    jr .jr47a6
    mvi a, $06
.jr47a4:
    mvi a, $04
.jr47a6:
    nei a, $00
    jre .jr47d0
    push va
    push bc
    call call482a
    pop bc
    mov a, b
    mov c, a
    pop va
    push bc
.jr47b9:
    dcr c
    jr .jr47bc
    jr .jr47ce
.jr47bc:
    push va
    call call4859
    ldaw [var_flags1]
    xri a, FLAG1_1
    staw [var_flags1]
    offi a, $02
    jr .jr47cb
    inx hl
.jr47cb:
    pop va
    jr .jr47b9
.jr47ce:
    pop bc
.jr47d0:
    push va
    ldaw [var_player_x1]
    add a, b
    staw [var_player_x1]
    pop va
    ret

call47db:
    call call49e5
.jr47de:
    ldax [de+]
    nei a, $00
    jre .jr4829
    staw [var_rle_len]
    push de
.jr47e7:
    ldaw [var_rle_len]
    mov b, a
    ldaw [var_unknown3]
    mov c, a
    subnb a, b
    jre .jr4819
    nei a, $00
    jre .jr4819
    staw [var_unknown3]
    ldaw [var_player_x1]
    add a, b
    staw [var_player_x1]
    call call484e
    offi a, $05
    jr .jr4815
    oni a, $02
    jr .jr480a
    dcrw [var_unknown5]
    nop
    jr .jr480d
.jr480a:
    inrw [var_unknown4]
    nop
.jr480d:
    inrw [var_edit_crates]
    nop
    ori a, $08
    call call4859
.jr4815:
    pop de
    jre .jr47de
.jr4819:
    xri a, $ff
    inr a
    nop
    staw [var_rle_len]
    call call49d9
    gtiw [var_player_y1], $11
    jre .jr47e7
    pop de
.jr4829:
    ret

call482a:
    ldaw [var_player_x1]
    dcr a
    nop
    clc
    rar
    aniw [var_flags1], !FLAG1_1
    sknc
    oriw [var_flags1], FLAG1_1
    mvi d, $00
    mov e, a
    push de
    ldaw [var_player_y1]
    dcr a
    nop
    mvi e, $0a
    calt MULTIPLY
    pop de
    calt ADDRHLDE
    lxi de, var_lvlmap
    calt ADDRHLDE
    ret

call484e:
    call call482a
    ldax [hl]
    offiw [var_flags1], FLAG1_1
    calt ACC4RAR
    ani a, $0f
    ret

call4859:
    oniw [var_flags1], FLAG1_1
    jr .jr486a
    clc
    ral
    ral
    ral
    ral
    mvi b, $0f
    jr .jr486c
.jr486a:
    mvi b, $f0
.jr486c:
    push va
    ldax [hl]
    ana a, b
    mov b, a
    pop va
    ora a, b
    stax [hl]
    ret

call4878:
    push va
    call call484e
    mov b, a
    pop va
    oni a, $80
    jr .jr4886
    ana a, b
    jr .jr4888
.jr4886:
    ora a, b
.jr4888:
    ani a, $0f
    push va
    call call4859
    pop va
    ret

win_level:
    lxi hl, music_win
    calt MUSPLAY
    call call4986
    mvi b, $16
    mvi c, $1a
    mvi a, $21
    call call4c36
    mvi c, $1c
    call call4c36
    lxi hl, text_good
    calt DRAWTEXT
    db $18, $1c, $90 | text_good.size
    calt SCRN2LCD
    ret

lose_level:
    lxi hl, music_lose
    calt MUSPLAY
    call call4986
    call call48df
    mvi b, $0f
    mvi c, $22
    mvi a, $2f
    call call4c36
    mvi c, $24
    call call4c36
    lxi hl, text_give
    calt DRAWTEXT
    db $11, $24, $80 | 2
    lxi hl, text_give + 2
    calt DRAWTEXT
    db $1b, $24, $90 | (text_give.size - 2)
    lxi hl, text_up
    calt DRAWTEXT
    db $2b, $24, $90 | text_up.size
    calt SCRN2LCD
    ret

call48df:
    mvi b, $0a
    mvi c, $08
    mvi a, $37
    call call4c36
    mvi c, $0a
    call call4c36
    lxi hl, text_game
    calt DRAWTEXT
    db $0c, $0a, $90 | text_game.size
    lxi hl, text_over
    calt DRAWTEXT
    db $28, $0a, $90 | text_over.size
    ret

call48fc:
    call call498b

call48ff:
    call call4924

call4902:
    call call4a9a
    calt SCRN2LCD
    ret

play_err_beep:
    offiw [var_flags1], FLAG1_7
    jr .jr4914
    oriw [var_flags1], FLAG1_7
    offiw [$ff80], $03
    calf $0e4d
    jr .jr4918
.jr4914:
    offiw [$ff80], $03
    jr .jr491b
.jr4918:
    calt SNDPLAY
    db PITCH.G3, 255
.jr491b:
    ret

call491c:
    calt ACCCLR
    staw [var_flags0]
    ret

call4920:
    calt ACCCLR
    staw [var_flags1]
    ret

call4924:
    calt ACCCLR
    staw [$ff8b]
    ret

call4928:
    calt ACCCLR
    staw [$ff88]
    staw [$ff89]
    ret

call492e:
    mvi a, $01
    staw [var_unknown0]
    staw [var_unknown1]
    mvi a, $13
    staw [var_unknown2]
    ret

call4939:
    calt ACCCLR
    staw [var_player_x0]
    ret

call493d:
    calt ACCCLR
    staw [var_edit_x]
    ret

call4941:
    calt ACCCLR
    staw [var_player_x2]
    ret

call4945:
    clc
    rar

call4949:
    clc
    rar
    clc
    rar
call4951:
    clc
    rar
    ret

call4956:
    clc
    ral

call495a:
    clc
    ral

call495e:
    clc
    ral

call4962:
    clc
    ral
    ret

call4967:
    call call4928
.jr496a:
    ldaw [$ff89]
    eqa a, b
    jr .jr496a
    ret

call4970:
    call call4928
.jr4973:
    calt JOYREAD
    neiw [JOY.BTN.CURR], JOY.BTN.STA
    jr .jr4985
    eqiw [JOY.BTN.CURR], JOY.BTN.SEL
    jr .jr4981
    lxi hl, music_step
    calt MUSPLAY
    jr .jr4985
.jr4981:
    gtiw [$ff89], $09
    jr .jr4973
.jr4985:
    ret

call4986:
    offiw [$ff80], $03
    jr call4986
    ret

call498b:
    ldaw [var_flags0]
    xri a, FLAG0_2
    staw [var_flags0]
    ret

call4992:
    ldaw [var_player_x0]
    staw [var_player_x1]
    ldaw [var_player_y0]
    staw [var_player_y1]
    ret

call499b:
    ldaw [var_player_x1]
    staw [var_player_x0]
    ldaw [var_player_y1]
    staw [var_player_y0]
    ret

call49a4:
    ldaw [var_player_x2]
    staw [var_player_x1]
    ldaw [var_player_y2]
    staw [var_player_y1]
    ret

call49ad:
    ldaw [var_player_x1]
    staw [var_player_x2]
    ldaw [var_player_y1]
    staw [var_player_y2]
    ret

call49b6:
    ldaw [var_edit_x]
    staw [var_player_x1]
    ldaw [var_edit_y]
    staw [var_player_y1]
    ret

call49bf:
    ldaw [var_player_x1]
    staw [var_edit_x]
    ldaw [var_player_y1]
    staw [var_edit_y]
    ret

try49c8:
    gtiw [var_player_x1], $01
    jr .jr49d7
    ltiw [var_player_x1], $13
    jr .jr49d7
    gtiw [var_player_y1], $01
    jr .jr49d7
    ltiw [var_player_y1], $11
.jr49d7:
    ret
    rets

call49d9:
    ldaw [var_unknown2]
    staw [var_unknown3]
    ldaw [var_unknown0]
    staw [var_player_x1]
    inrw [var_player_y1]
    nop
    ret

call49e5:
    ldaw [var_unknown2]
    staw [var_unknown3]
    ldaw [var_unknown0]
    staw [var_player_x1]
    ldaw [var_unknown1]
    staw [var_player_y1]
    ret

call49f2:
    ldaw [var_flags0]
    oni a, FLAG0_1
    jr .jr4a02
    oni a, FLAG0_0
    jr .jr49fe
    dcrw [var_player_y1]
    nop
    jr .jr4a0c
.jr49fe:
    inrw [var_player_y1]
    nop
    jr .jr4a0c
.jr4a02:
    oni a, $01
    jr .jr4a09
    dcrw [var_player_x1]
    nop
    jr .jr4a0c
.jr4a09:
    inrw [var_player_x1]
    nop
.jr4a0c:
    ret

try_move:
    ldaw [var_flags0]
    ani a, !(FLAG0_0 | FLAG0_1)
    eqiw [JOY.DIR.CURR], JOY.DIR.UP
    jr .jr4a18
    ori a, FLAG0_0 | FLAG0_1
    jr .jr4a2a
.jr4a18:
    eqiw [JOY.DIR.CURR], JOY.DIR.LT
    jr .jr4a1f
    ori a, FLAG0_0
    jr .jr4a2a
.jr4a1f:
    eqiw [JOY.DIR.CURR], JOY.DIR.DN
    jr .jr4a26
    ori a, FLAG0_1
    jr .jr4a2a
.jr4a26:
    eqiw [JOY.DIR.CURR], JOY.DIR.RT
    ret
.jr4a2a:
    staw [var_flags0]
    rets

call4a2d:
    calt SCR2CLR
    oniw [var_flags0], FLAG0_6
    mvi a, $0b
    mvi a, $01
    staw [var_rle_data]
.jr4a37:
    ldaw [var_unknown0]
    staw [var_player_x1]
.jr4a3b:
    ldaw [var_player_x1]
    mov c, a
    ldaw [var_unknown0]
    mov b, a
    ldaw [var_unknown2]
    add a, b
    gta a, c
    jre .jr4a8c
    ldaw [var_unknown1]
    staw [var_player_y1]
    call call482a
.jr4a50:
    gtiw [var_player_y1], $11
    jr .jr4a6a
    oniw [var_flags0], FLAG0_6
    jr .jr4a65
    push hl
    call call4924
    calt SCR2COPY
    calt SCRN2LCD
    pop hl
.jr4a61:
    gtiw [$ff8b], $04
    jr .jr4a61
.jr4a65:
    inrw [var_player_x1]
    nop
    jre .jr4a3b
.jr4a6a:
    ldax [hl]
    offiw [var_flags1], FLAG1_1
    calt ACC4RAR
    ani a, $0f
    mov b, a
    ldaw [var_rle_data]
    ana a, b
    oni a, $0b
    jr .jr4a84
    offi a, $08
    mvi a, $08
    push hl
    call call4b18
    pop hl
.jr4a84:
    inrw [var_player_y1]
    nop
    mvi e, $0a
    calt ADDRHLE
    jre .jr4a50
.jr4a8c:
    oniw [var_flags0], FLAG0_6
    jr .jr4a99
    mvi a, $0a
    staw [var_rle_data]
    aniw [var_flags0], !FLAG0_6
    jre .jr4a37
.jr4a99:
    ret

call4a9a:
    calt SCR2COPY
    call call4aa5
    call call4abc
    call call4add
    ret

call4aa5:
    oniw [var_flags0], FLAG0_3
    jr .jr4abb
    neiw [var_player_x2], $00
    jr .jr4abb
    call call49a4
    call call4bab
    mvi a, $05
    stax [hl-]
    dcx hl
    call call4bc1
    calt OBJDRAW
.jr4abb:
    ret

call4abc:
    neiw [var_player_x0], $00
    jr .jr4adc
    call call4992
    offiw [var_flags0], FLAG0_2
    jr .jr4adc
    call call4bab
    calt ACCCLR
    stax [hl]
    ldaw [var_flags0]
    oni a, FLAG0_3
    jr .jr4adb
    ani a, FLAG0_0 | FLAG0_1
    inr a
    nop
    stax [hl]
    dcx hl
    dcx hl
    call call4bc1
.jr4adb:
    calt OBJDRAW
.jr4adc:
    ret

call4add:
    neiw [var_edit_x], $00
    jre .jr4b17
    call call49b6
    call call4bab
    push hl
    call call484e
    pop hl
    nei a, $00
    jr .jr4b0f
    oniw [var_flags0], FLAG0_2
    jr .jr4afa
    mvi a, $07
    stax [hl]
    jr .jr4b16
.jr4afa:
    oniw [JOY.DIR.CURR], JOY.DIR.ANY
    jr .jr4b17
    call try_move
    jr .jr4b17
    offiw [var_flags1], FLAG1_7
    jr .jr4b17
    oniw [JOY.BTN.CURR], JOY.BTN.ANY
    jr .jr4b13
    offiw [var_flags0], FLAG0_4
    jr .jr4b13
    jr .jr4b17
.jr4b0f:
    offiw [var_flags0], FLAG0_2
    jr .jr4b17
.jr4b13:
    mvi a, $06
    stax [hl]
.jr4b16:
    calt OBJDRAW
.jr4b17:
    ret

call4b18:
    lxi hl, tiles1
    mvi e, $04
    mvi b, $03
.jr4b1f:
    rar
    sknc
    jr .jr4b2d
    push va
    calt ADDRHLE
    pop va
    dcr b
    jr .jr4b1f
    jre .jr4ba1
.jr4b2d:
    push hl
    ldaw [var_player_y1]
    call call4951
    dcr a
    jr .jr4b3a
    lxi hl, $ffb5
    jr .jr4b3d
.jr4b3a:
    mvi e, $4b
    calt $a6
.jr4b3d:
    ldaw [var_player_x1]
    mov b, a
    dcr a
    nop
    call call495e
    mov e, a
    calt $9a
    lxi de, SCR2.BEGIN
    calt $96
    pop de
    mov a, b
    lti a, $13
    mvi a, $02
    mvi a, $03
    staw [var_unknown7]
.jr4b56:
    ldax [hl]
    mov b, a
    ldax [de]
    mov c, a
    ldaw [var_player_y1]
    oni a, $01
    jre .jr4b8d
    gti a, $01
    jr .jr4b71
    mov a, c
    calf $0c70
    ani a, $c0
    mov c, a
    mov a, b
    ani a, $3f
    ora a, c
    stax [hl]
    ldaw [var_player_y1]
.jr4b71:
    lti a, $11
    jre .jr4b9b
    push hl
    push de
    mvi e, $4b
    calt $9a
    ldax [hl]
    ani a, $fc
    mov b, a
    pop de
    ldax [de]
    calf $0c72
    ani a, $03
    ora a, b
    stax [hl]
    pop hl
    jr .jr4b9b
.jr4b8d:
    mov a, c
    ral
    ral
    ani a, $3c
    mov c, a
    mov a, b
    ani a, $c3
    ora a, c
    stax [hl]
.jr4b9b:
    inx hl
    inx de
    dcrw [var_unknown7]
    jre .jr4b56
.jr4ba1:
    ret

clear_obj:
    lxi hl, OBJ.O0.X
    mvi a, $80
    mvi b, OBJ.END - OBJ.O0.X - 1
    calt MEMSET
    ret

call4bab:
    lxi hl, OBJ.O0.X
    ldaw [var_player_x1]
    dcr a
    nop
    call call495e
    stax [hl+]
    ldaw [var_player_y1]
    dcr a
    nop
    call call495e
    sui a, $02
    stax [hl+]
    ret

call4bc1:
    oniw [var_flags0], FLAG0_1
    jr .jr4bc6
    inx hl
.jr4bc6:
    mvi b, $02
    oniw [var_flags0], FLAG0_0
    jr .jr4bce
    mvi b, $fe
.jr4bce:
    ldax [hl]
    add a, b
    stax [hl]
    ret

call4bd3:
    call call4c2a
    ldaw [var_unknown0]
    staw [var_player_x1]
.jr4bda:
    ldaw [var_player_x1]
    mov c, a
    ldaw [var_unknown0]
    mov b, a
    ldaw [var_unknown2]
    add a, b
    gta a, c
    jre .jr4c1b
    ldaw [var_unknown1]
    staw [var_player_y1]
.jr4bec:
    gtiw [var_player_y1], $11
    jr .jr4bf4
    inrw [var_player_x1]
    nop
    jr .jr4bda
.jr4bf4:
    call call484e
    oni a, $02
    jr .jr4bfd
    inrw [var_unknown5]
    nop
.jr4bfd:
    oni a, $08
    jr .jr4c06
    inrw [var_unknown4]
    nop
    inrw [var_edit_crates]
    nop
.jr4c06:
    oni a, $04
    jr .jr4c0d
    call call499b
    jr .jr4c16
.jr4c0d:
    eqi a, $0a
    jr .jr4c16
    dcrw [var_unknown5]
    nop
    dcrw [var_unknown4]
    nop
.jr4c16:
    inrw [var_player_y1]
    nop
    jre .jr4bec
.jr4c1b:
    ret

call4c1c:
    lxi hl, var_lvlmap
    mvi b, $a9
    calt MEMCLR
    staw [var_flags1]
    staw [var_unknown0]
    staw [var_unknown1]
    staw [var_unknown2]

call4c2a:
    calt ACCCLR
    staw [var_player_x0]
    staw [var_player_y0]
    staw [var_edit_crates]
    staw [var_unknown4]
    staw [var_unknown5]
    ret

call4c36:
    push va
    push bc
    dcr a
    jr .jr4c3e
    jre .jr4c8a
.jr4c3e:
    push va
    push bc
    mov a, c
    call call4949
    call call495a
    mov b, a
    mov a, c
    sub a, b
    mov b, a
    mov c, a
    inr c
    nop
    calt ACCCLR
.jr4c52:
    dcr b
    jr .jr4c55
    jr .jr4c5a
.jr4c55:
    stc
    ral
    jr .jr4c52
.jr4c5a:
    mov d, a
    mvi a, $ff
.jr4c5d:
    dcr c
    jr .jr4c60
    jr .jr4c65
.jr4c60:
    clc
    ral
    jr .jr4c5d
.jr4c65:
    mov e, a
    pop bc
    push de
    calt SCR1LOC
    pop de
    mov a, d
    mov c, a
    pop va
    mov b, a
    push va
    push hl
    call call4c8f
    pop hl
    push de
    mvi e, $4b
    calt ADDRHLE
    pop de
    pop va
    mov b, a
    mov a, e
    mov c, a
    call call4c8f
.jr4c8a:
    pop bc
    pop va
    ret

call4c8f:
    ldax [hl]
    ana a, c
    stax [hl+]
    dcr b
    jr call4c8f
    ret

#addr $4e00
font:
    #d incbin("sokoban/font.1bpp")[447:208]
    #d incbin("sokoban/font.1bpp")[895:496]
    #d incbin("sokoban/font.1bpp")[1343:944]

text_logo_top:
    #d $6a6b6c6d6e6f70717273
.size = $ - text_logo_top

text_logo_bottom:
    #d $7475767778797a7b7c7d
.size = $ - text_logo_bottom

text_store:
    #d smalltext("STORE")
.size = $ - text_store

text_keepers:
    #d smalltext("KEEPERS")
.size = $ - text_keepers

text_play:
    #d $64, largetext("PLAY")
.size = $ - text_play

text_editor:
    #d $64, largetext("EDITOR")
.size = $ - text_editor

text_eplay:
    #d $64, largetext("E"), $65, largetext("PLAY")
.size = $ - text_eplay

text_start:
    #d largetext("START")
.size = $ - text_start

text_no:
    #d largetext("NO"), $66
.size = $ - text_no

text_no2:
    #d $67, largetext("NO"), $68, $00, $00, $69
.size = $ - text_no2

text_challenge:
    #d largetext("CHALLENGE")
.size = $ - text_challenge

text_good:
    #d largetext("GOOD!")
.size = $ - text_good

text_game:
    #d largetext("GAME")
.size = $ - text_game

text_over:
    #d largetext("OVER")
.size = $ - text_over

text_give:
    #d largetext("GIVE")
.size = $ - text_give

text_up:
    #d largetext("UP?")
.size = $ - text_up

text_e2:
    #d $67, largetext("E"), $65
.size = $ - text_e2

text_play3:
    #d largetext("PLAY"), $69
.size = $ - text_play3

text_dis:
    #d largetext("DIS")
.size = $ - text_dis

tiles1:
    #d incbin("sokoban/tiles1.1bpp")

tiles2:
    #d incbin("sokoban/tiles2.1bpp")

music_start:
    db PITCH.GS4, 8
    db PITCH.A4, 20
    db PITCH.GS4, 8
    db PITCH.A4, 20
    db PITCH.A3, 20
    db PITCH.G4, 8
    db PITCH.GS4, 20
    db PITCH.FS4, 8
    db PITCH.GS4, 20
    db PITCH.A3, 20
    db PITCH.E4, 8
    db PITCH.E4, 20
    db PITCH.E4, 8
    db PITCH.FS4, 20
    db PITCH.G4, 20
    db PITCH.GS4, 10
    db $ff

music_win:
    db PITCH.C4, 10
    db PITCH.C4, 10
    db PITCH.E4, 10
    db PITCH.G4, 30
    db PITCH.D4, 10
    db PITCH.D4, 10
    db PITCH.F4, 10
    db PITCH.A4, 30
    db PITCH.B4, 10
    db PITCH.B4, 10
    db PITCH.B4, 10
    db PITCH.B4, 10
    db PITCH.A4, 10
    db PITCH.B4, 10
    db PITCH.C5, 30
    db $ff

music_lose:
    db PITCH.C4, 10
    db PITCH.D4, 10
    db PITCH.E4, 10
    db PITCH.F4, 20
    db PITCH.A4, 10
    db PITCH.F4, 20
    db PITCH.A4, 10
    db PITCH.C5, 20
    db PITCH.AS4, 10
    db PITCH.A4, 20
    db PITCH.G4, 10
    db PITCH.F4, 10
    db PITCH.D4, 10
    db PITCH.C4, 10
    db PITCH.E4, 20
    db PITCH.F4, 40
    db $ff

music_undo:
    db PITCH.E4, 10
    db PITCH.D4, 10
    db PITCH.C4, 10
    db PITCH.E4, 10
    db PITCH.D4, 10
    db PITCH.C4, 10
    db $ff

music_step:
    db PITCH.C5, 2
    db PITCH.E5, 0
    db PITCH.NONE, 15
    db $ff

music4fb1:
    db PITCH.E4, 8
    db PITCH.G4, 1
    db PITCH.NONE, 1
    db $ff

#fn demo_reducer(out, ch) => {
    suffix = (
        (ch == "R"`8) ? %00 :
        (ch == "L"`8) ? %01 :
        (ch == "D"`8) ? %10 :
        (ch == "U"`8) ? %11 :
        ""
    )
    assert(sizeof(suffix) == 2)
    out @ suffix
}

demo_input:
    db (.end - .start) * 4
.start:
    #d reduce(
        "LLUUULLLLLDDDRRD" @
        "DDDRDLUUUUULLUUU" @
        "RRDDDDDDDUUUUURD" @
        "LUUURRRDDDLLULDD" @
        "DDLDRURDLUUUURRD" @
        "LULDDDRDLUUUURRR" @
        "RRULDLLLLUUURRRD" @
        "DRDLLLULDDDD",
        8,
        "",
        demo_reducer
    )
.end:

levels:
    dw level00
    dw level01
    dw level02
    dw level03
    dw level04
    dw level05
    dw level06
    dw level07
    dw level08
    dw level09
    dw level10
    dw level11
    dw level12
    dw level13
    dw level14
    dw level15
    dw level16
    dw level17
    dw level18
    dw level19
    dw level20
    dw level21
    dw level22
    dw level23
    dw level24
    dw level25
    dw level26
    dw level27
    dw level28
    dw level29
    dw level30
    dw level31
    dw level32
    dw level33
    dw level34
    dw level35
    dw level36
    dw level37
    dw level38
    dw level39
    dw level40
    dw level41
    dw level42
    dw level43
    dw level44
    dw level45
    dw level46
    dw level47
    dw level48
    dw level49
    dw level50
    dw level51
    dw level52
    dw level53
    dw level54
    dw level55
    dw level56
    dw level57
    dw level58
    dw level59
    dw level60
    dw level61
    dw level62
    dw level63
    dw level64
    dw level65

#fn tile_reducer(out, ch) => {
    nibble = (
        (ch == " "`8) ? %111100 :
        (ch == "*"`8) ? %111100 :
        (ch == "#"`8) ? %111101 :
        (ch == "O"`8) ? %111110 :
        (ch == "@"`8) ? %111110 :
        (ch == "P"`8) ? %111111 :

        (ch == "?"`8) ? %101100 :
        (ch == "_"`8) ? %111000 :
        (ch == "$"`8) ? %111001 :

        %000000
    )
    valid =
        (VERSION == VERSION_PRE0125)
        ? nibble[4:4] == %1
        : nibble[5:5] == %1
    extensible =
        (VERSION == VERSION_PRE0125)
        ? nibble[2:2] == %1
        : nibble[3:3] == %1
    len = sizeof(out)
    extend =
        valid && extensible && (len > 0) &&
        (out[3:2] == nibble`2) && (out[1:0] < %11)
    extend ? {
        out[len - 1:4] @ nibble`2 @ (out[1:0] + 1)`2
    } : valid ? {
        out @ nibble`2 @ %00
    } : {
        out
    }
}

#fn crate_reducer(out, ch) => {
    len = sizeof(out)
    (ch == "*"`8 || ch == "@"`8) ? {
        out @ $01
    } : {
        out[len-1:8] @ (out[7:0] + 1)`8
    }
}

#fn level(w, h, y_off, grid) => {
    assert(sizeof(grid) == (w * h * 8))
    x = (21 - w) / 2
    y = (20 - h) / 2 + y_off

    raw_tiles = reduce(grid, 8, "", tile_reducer)
    tiles = raw_tiles @ ((sizeof(raw_tiles) % 8 == 4) ? $f : $f0)

    raw_crates = reduce(grid, 8, $00, crate_reducer)
    crates = raw_crates[sizeof(raw_crates)-1:8] @ $00

    x`8 @ y`8 @ w`8 @ tiles @ crates
}

level00:
    #d level(
        10, 11, 1,
        "########  " @
        "#      #  " @
        "# #*## ###" @
        "# #  # * #" @
        "#  *   *P#" @
        "###   ####" @
        " ##*###   " @
        " #   #    " @
        " #OO #    " @
        " #OOO#    " @
        " #####    "
    )

level01:
    #d level(
        17, 9, 0,
        "######           " @
        "#    ###   ######" @
        "# #  * # ###  OO#" @
        "# #  * ###P#  OO#" @
        "#  ***   *   OOO#" @
        "###  *  *###  OO#" @
        "  #* * * # #  OO#" @
        "  #      # ######" @
        "  ########       "
    )

level02:
    #d level(
        16, 13, 0,
        "       #########" @
        "       #       #" @
        "       # # # # #" @
        "       #  * *# #" @
        "       #   *   #" @
        "       ## * *# #" @
        " ###    # * *  #" @
        "##O###### ######" @
        "#OOO  # * * #   " @
        "##OO     *  #   " @
        "#OOO  #  P###   " @
        "##O####  ##     " @
        " ###  ####      "
    )

level03:
    #d level(
        16, 12, 0,
        "       #########" @
        "########P##  OO#" @
        "#      *     OO#" @
        "# * #* #*##  OO#" @
        "## ##    ####OO#" @
        " # * *## #  ####" @
        " # ## #  #      " @
        "## #    ##      " @
        "#  *   ##       " @
        "#  ##* #        " @
        "#  ##  #        " @
        "########????????"
    )

level04:
    #d level(
        17, 11, 0,
        "    #####        " @
        "    #   #        " @
        "    #*  #        " @
        "  ###  *###      " @
        "  #  *  * #      " @
        "### # ### #######" @
        "#   # ### ##  OO#" @
        "# *  *      P OO#" @
        "##### #### #  OO#" @
        "    #      ######" @
        "    ########     "
    )

level05:
    #d level(
        10, 12, 0,
        "   #######" @
        " ###     #" @
        "##   # # #" @
        "#  #O*** #" @
        "# #O@# ###" @
        "#  OO# #  " @
        "###OO* ## " @
        "  #O# * # " @
        " ## # #P# " @
        " # *  * # " @
        " #     ## " @
        " #######  "
    )

level06:
    #d level(
        17, 13, 0,
        "        ######## " @
        "        #      # " @
        "        #  * * # " @
        " ######## * *  # " @
        "##OOO  #### ## # " @
        "#OOOO       ## # " @
        "##OOO  ## **## ##" @
        " ######## *    P#" @
        "      ### #### ##" @
        "      # * *    # " @
        "      #  * ##### " @
        "      ##   #     " @
        "       #####     "
    )

level07:
    #d level(
        14, 10, 0,
        "############  " @
        "#OO  #     ###" @
        "#OO  # *  *  #" @
        "#OO  #*####  #" @
        "#OO    P ##  #" @
        "#OO  # #  * ##" @
        "###### ##* * #" @
        "  # *  * * * #" @
        "  #    #     #" @
        "  ############"
    )

level08:
    #d level(
        16, 16, 0,
        "  ####          " @
        "  #  ###########" @
        "  #    *   * * #" @
        "  # *# * #  *  #" @
        "  #  * *  #    #" @
        "### *# #  #### #" @
        "#P#* * *  ##   #" @
        "#    * #*#   # #" @
        "##  *    * * * #" @
        " #### ##########" @
        " #OOOO  #       " @
        " #OOOO  #       " @
        " #OOOO  #       " @
        " #OOO####       " @
        " #OOO#          " @
        " #####          "
    )

level09:
    #d level(
        14, 13, 0,
        "       ####   " @
        "########  ####" @
        "#   ##OOOOO  #" @
        "#  *  ##OOO# #" @
        "##  *  ### # #" @
        " # # *  #    #" @
        " #  # *  #   #" @
        " #   # *  #  #" @
        " #    # * # ##" @
        " ####  # *  # " @
        "    ##  # * # " @
        "     ##P#   # " @
        "      ####### "
    )

level10:
    #d level(
        14, 12, 0,
        " ############ " @
        "##P#  ###   ##" @
        "#    *  # *  #" @
        "#  *  #    * #" @
        "### ######   #" @
        "### ######*###" @
        "# *  #### OO# " @
        "# * * *  OOO# " @
        "#    ####OOO# " @
        "# ** # ##OOO# " @
        "#  ### ###### " @
        "####          "
    )

level11:
    #d level(
        17, 13, 0,
        "        #####    " @
        "        #   #####" @
        "        # #*##  #" @
        "        #     * #" @
        "######### ###   #" @
        "#OOOO  ## *  *###" @
        "#OOOO    * ** ## " @
        "#OOOO  ##*  * P# " @
        "#########  *  ## " @
        "        # * *  # " @
        "        ### ## # " @
        "          #    # " @
        "          ###### "
    )

level12:
    #d level(
        17, 10, 0,
        "        ######## " @
        "        #     P# " @
        "        # *#* ## " @
        "        # *  *#  " @
        "        ##* * #  " @
        "######### * # ###" @
        "#OOOO  ## *  *  #" @
        "##OOO    *  *   #" @
        "#OOOO  ##########" @
        "########         "
    )

level13:
    #d level(
        12, 11, 0,
        "######  ### " @
        "#OO  # ##P##" @
        "#OO  ###   #" @
        "#OO     ** #" @
        "#OO  # # * #" @
        "#OO### # * #" @
        "#### * #*  #" @
        "   #  *# * #" @
        "   # *  *  #" @
        "   #  ##   #" @
        "   #########"
    )

level14:
    #d level(
        15, 9, 0,
        "  #####        " @
        "  #   #########" @
        "  # * *       #" @
        "#####  * #**  #" @
        "#   # ##    ###" @
        "#OOO   ##  *#  " @
        "#OOO#**  *  #  " @
        "#OOO#  P#  ##  " @
        "############   "
    )

level15:
    #d level(
        16, 14, 0,
        " ####### ###### " @
        " #     ###    # " @
        " #  ## #  **# #$" @
        " #* * * * *    #" @
        " # * * #   #   #" @
        "##  ** ######O##" @
        "# *    #  _#OOO#" @
        "#P#** ##   #OOO#" @
        "#  *   #   #OOO#" @
        "##  #* #   #OOO#" @
        " #**#  #####OOO#" @
        " #     *    OOO#" @
        " ###########   #" @
        "           #####"
    )

level16:
    #d level(
        18, 14, 0,
        "           ####   " @
        "  ##########  #   " @
        "###   #   ##* ####" @
        "#  ** #     * #P #" @
        "# #   #   ##* OOO#" @
        "# #   # ** #  ##O#" @
        "# # #### # #####O#" @
        "# #* ### #  #  #O#" @
        "# #  #    # #  #O#" @
        "#     *   # #  #O#" @
        "# #  ### ## #  #O#" @
        "# ####      #  ###" @
        "#      ######     " @
        "########          "
    )

level17:
    #d level(
        15, 14, 0,
        "####           " @
        "#  ###         " @
        "# *  ###       " @
        "# * *  ###     " @
        "# * * *  ###   " @
        "# * * *    #   " @
        "# * *  #   ##  " @
        "# *  ## *** #  " @
        "#P ####     ## " @
        "## # #O*****O# " @
        " # ###OOOOOOO##" @
        " #   O@@@@@@@O#" @
        " ####OOOOOOOOO#" @
        "    ###########"
    )

level18:
    #d level(
        14, 10, 0,
        "####      ####" @
        "#OO########OO#" @
        "#@O@OOOOO@O@O#" @
        "# * * * * * *#" @
        "#* * *P* * * #" @
        "# * * * * * *#" @
        "#* * * * * * #" @
        "#O@O@OOOOO@O@#" @
        "#OO########OO#" @
        "####      ####"
    )

level19:
    #d level(
        14, 15, 0,
        " #########    " @
        " #OOOO   ##   " @
        " #O#O#  * ##  " @
        "##OOOO# # P## " @
        "# OOOO#  #  ##" @
        "#     #* ##* #" @
        "## ###  *    #" @
        " #*  * * *#  #" @
        " # #  * * ## #" @
        " #  ###  ##  #" @
        " #    ## ## ##" @
        " #  * #  *  # " @
        " ###* *   ### " @
        "   #  #####   " @
        "   ####       "
    )

level20:
    #d level(
        17, 16, 0,
        "        #########" @
        "      ###    OOO#" @
        "      #      OOO#" @
        "      #  ### OOO#" @
        "     ### ####OOO#" @
        "     # *** ##OOO#" @
        " #####  * * #####" @
        "##   #* *   #   #" @
        "#P *  *    *  * #" @
        "###### ** * #####" @
        "     # *    #    " @
        "     #### ###    " @
        "        #  #     " @
        "        #  #     " @
        "        #  #     " @
        "        ####     "
    )

level21:
    #d level(
        15, 14, 0,
        "#####      ####" @
        "#P  ########  #" @
        "## *       *  #" @
        " # # #  ####  #" @
        " #  *   ####*##" @
        " #* ## # * * # " @
        "## *  *#     # " @
        "#   #      # # " @
        "#   #####*#### " @
        "#####   #   #  " @
        "    #OOO  * #  " @
        "    #OOOO#  #  " @
        "    #OOOO####  " @
        "    ######     "
    )

level22:
    #d level(
        12, 15, 0,
        "############" @
        "##     ##  #" @
        "##   *   * #" @
        "#### ## ** #" @
        "#   * #    #" @
        "# *** # ####" @
        "#   # # * ##" @
        "#  #  #  * #" @
        "# *# *#    #" @
        "#   OO# ####" @
        "####OO * #P#" @
        "#OOOOO# *# #" @
        "##OOOO#  * #" @
        "###OO##    #" @
        "############"
    )

level23:
    #d level(
        13, 15, 0,
        "      ####   " @
        "  #####  #   " @
        " ##     *#   " @
        "## *  ## ### " @
        "#P* * # *  # " @
        "#### ##   *# " @
        " #OOOO#* * # " @
        " #OOOO#   *# " @
        " #OOOO  ** ##" @
        " #OOO # *   #" @
        " ######* *  #" @
        "      #   ###" @
        "      #* ### " @
        "      #  #   " @
        "      ####   "
    )

level24:
    #d level(
        17, 12, 0,
        "  ########       " @
        "  #      #       " @
        "  #  *   #####   " @
        "  ####   *   #   " @
        "  #  ##*# *  #   " @
        "  #    P# # #####" @
        " ## ## * * **   #" @
        " #   #  #   #   #" @
        "##   ############" @
        "#OOOO#           " @
        "#OOOO#           " @
        "######           "
    )

level25:
    #d level(
        17, 13, 0,
        "     #####       " @
        "     #P  ####### " @
        "   #### *  *   # " @
        " ###   ** * *  # " @
        " #   #  *# ##### " @
        " #*####  *   * # " @
        " # *  *  *   * # " @
        " #  *  ###*### ##" @
        "##  ## #OOOOO#  #" @
        "#  * * #OOOOO   #" @
        "# *   * OOOOO####" @
        "########OOOOO#   " @
        "       #######   "
    )

level26:
    #d level(
        18, 16, 0,
        "  ####            " @
        "  #  #########    " @
        " ##  ## P#   #    " @
        " #  *# * *   #### " @
        " #*  *  # * *#  ##" @
        "##  *## #* *     #" @
        "#  #  # #   ***  #" @
        "# *    *  *## ####" @
        "# * * #*#  #  #   " @
        "##  ###  ###* #   " @
        " #  #OOOO     #   " @
        " ####OOOOOO####   " @
        "   #OOOO####      " @
        "   #OOO##         " @
        "   #OOO#          " @
        "   #####          "
    )

level27:
    #d level(
        9, 12, 0,
        " ####    " @
        " #  #### " @
        " #* P  # " @
        "##  ##*##" @
        "# @#O#  #" @
        "# OO@** #" @
        "# O#O#  #" @
        "##   # ##" @
        " ### *  #" @
        "   # #  #" @
        "   #   ##" @
        "   ##### "
    )

level28:
    #d level(
        15, 12, 0,
        " #######       " @
        " #  #  #####   " @
        "##  #  #OOO### " @
        "#  *#  #OOO  # " @
        "# * #** OOO  # " @
        "#  *#  #OOO O# " @
        "#   # *########" @
        "##*       * * #" @
        "##  #  ** #   #" @
        " ######  ##**P#" @
        "      #      ##" @
        "      ######## "
    )

level29:
    #d level(
        13, 16, 0,
        "  #########  " @
        "  #@O@#@O@#  " @
        "  #O@O@O@O#  " @
        "  #@O@O@O@#  " @
        "  #O@O@O@O#  " @
        "  #@O@O@O@#  " @
        "  ###   ###  " @
        "    #   #    " @
        "###### ######" @
        "#           #" @
        "# * * * * * #" @
        "## * * * * ##" @
        " #* * * * *# " @
        " #   *P*   # " @
        " #  #####  # " @
        " ####   #### "
    )

level30:
    #d level(
        17, 13, 0,
        "    #########    " @
        "    #       #    " @
        "    #** **# #### " @
        "#####  #  * #  # " @
        "#OO#  ## *  *  # " @
        "#OO# **     #  # " @
        "#OO#  ##*#### ## " @
        "#OO## ##    # #  " @
        "#OOO   ## ### ###" @
        "#   ##   *      #" @
        "######P#   ## # #" @
        "     ########   #" @
        "            #####"
    )

level31:
    #d level(
        13, 12, 0,
        "#############" @
        "#  * * *O@OO#" @
        "# * * * @OOO#" @
        "#  * * *O@OO#" @
        "# * * * @OOO#" @
        "#  * * *O@OO#" @
        "# * * * @OOO#" @
        "#  * * *O@OO#" @
        "# * * * @OOO#" @
        "#  * * *O@OO#" @
        "#P* * * @OOO#" @
        "#############"
    )

level32:
    #d level(
        11, 10, 0,
        "     ######" @
        " #####O   #" @
        " #  #OO## #" @
        " #  *OO   #" @
        " #  # O# ##" @
        "### ##*#  #" @
        "# *    ** #" @
        "# #*#  #  #" @
        "#P  #######" @
        "#####      "
    )

level33:
    #d level(
        15, 15, 0,
        "#########      " @
        "#       #      " @
        "#       ####   " @
        "## #### #  #   " @
        "## #P##    #   " @
        "# *** *  **#   " @
        "#  # ## *  #   " @
        "#  # ##  * ####" @
        "####  *** *#  #" @
        " #   ##   OOOO#" @
        " # #   # #OO O#" @
        " #   # # ##OOO#" @
        " ##### *  #OOO#" @
        "     ##   #####" @
        "      #####    "
    )

level34:
    #d level(
        18, 15, 0,
        "      ########### " @
        "      #     #   ##" @
        "      # *      OO#" @
        "      #     #*#OO#" @
        "  ###########  OO#" @
        "  #      *     OO#" @
        "  # # # *## # #OO#" @
        "  #   #*    #  OO#" @
        " ##*# * #######  #" @
        "##   *  #    # * #" @
        "#   *#  #    #   #" @
        "#  *   ##    #####" @
        "# *#####          " @
        "# P#              " @
        "####              "
    )

level35:
    #d level(
        17, 13, 0,
        "        #########" @
        "      ###   #   #" @
        "      #P*  * ** #" @
        "### ######      #" @
        "#O###   ##  ##* #" @
        "#OOOOO@O  ## *  #" @
        "# @##  #* #  *  #" @
        "#   #  *  OOOOOO#" @
        "## *##  #########" @
        " # * ####        " @
        " # * * #         " @
        " #     #         " @
        " #######         "
    )

level36:
    #d level(
        18, 14, 0,
        "########          " @
        "#OOO   ########   " @
        "#OOOO     *   ##  " @
        "#OOOOO## * #*  #  " @
        "#OOOOO#  #  *  #  " @
        "#######* ##  * ###" @
        " #        ### *  #" @
        " #  * # *  #  *  #" @
        " #  ### ##  # ####" @
        " #  #  *  * #   # " @
        " #### #*#  ##*  # " @
        "  #P*    *   *  # " @
        "  #####   ####### " @
        "      #####       "
    )

level37:
    #d level(
        16, 15, 0,
        "    ######      " @
        "    #    #      " @
        "  ### ## #      " @
        "###  *  *#######" @
        "#   * *  #  OOO#" @
        "# #* #  *#  OOO#" @
        "# #  #*     OOO#" @
        "# #* #   #  OOO#" @
        "# # *# **#  OOO#" @
        "# #P #*  #######" @
        "# # * * ##      " @
        "# #  *  #       " @
        "# ### ###       " @
        "#     #         " @
        "#######         "
    )

level38:
    #d level(
        16, 14, 0,
        "   ##########   " @
        "   #OO  #   #   " @
        "   #OO      #   " @
        "   #OO  #  #### " @
        "  #######  #  ##" @
        "  #            #" @
        "  #  #  ##  #  #" @
        "#### ##  #### ##" @
        "#  *  ##### #  #" @
        "# # *  *  # *  #" @
        "# P*  *   #   ##" @
        "#### ## ####### " @
        "   #    #       " @
        "   ######       "
    )

level39:
    #d level(
        16, 15, 0,
        "       ####     " @
        "       #  ##    " @
        "       #   ##   " @
        "       # ** ##  " @
        "     ###*  * ## " @
        "  ####    *   # " @
        "###  # #####  # " @
        "#    # #OOOO* # " @
        "# #   * OOOO# # " @
        "#  * # #O@OO# # " @
        "###  #### ### # " @
        "  #### P*  ##*##" @
        "     ### *     #" @
        "       #  ##   #" @
        "       #########"
    )

level40:
    #d level(
        18, 8, 0,
        "##################" @
        "#         ## #OOO#" @
        "# * **#    * #OOO#" @
        "# *   #*##** #OOO#" @
        "# **#*  P     OOO#" @
        "# * * *#* ####  O#" @
        "#   ##       *OOO#" @
        "##################"
    )

level41:
    #d level(
        14, 13, 0,
        "##############" @
        "#   ## OOOOOO#" @
        "#  ### OO#O# #" @
        "# *#  OO##O O#" @
        "## # *# #    #" @
        "# *  *    # ##" @
        "# *# # *###* #" @
        "#P # # *  #  #" @
        "# *# ##*# #* #" @
        "# *   #      #" @
        "###   # ##* ##" @
        "  #####     # " @
        "      ####### "
    )

level42:
    #d level(
        17, 13, 0,
        "################ " @
        "#              # " @
        "# # ######     # " @
        "# #  * * * *#  # " @
        "# #   *P*   ## ##" @
        "# # #* * *###OOO#" @
        "# #   * *  ##OOO#" @
        "# ###*** * ##OOO#" @
        "#     # ## ##OOO#" @
        "#####   ## ##OOO#" @
        "    #####     ###" @
        "        #     #  " @
        "        #######  "
    )

level43:
    #d level(
        18, 16, 0,
        "       #######    " @
        " #######     #    " @
        " #     # *P* #    " @
        " #** #   #########" @
        " # ###OOOOOO##   #" @
        " #   *OOOOOO## # #" @
        " # ###OOOOOO     #" @
        "##   #### ### #*##" @
        "#  #*   #  *  # # " @
        "#  * ***  # *## # " @
        "#   * * ###** # # " @
        "#####     *   # # " @
        "    ### ###   # # " @
        "      #     #   # " @
        "      ########  # " @
        "             #### "
    )

level44:
    #d level(
        11, 10, 0,
        "   #####   " @
        " ###   ### " @
        "##  P* * # " @
        "#  ## ## ##" @
        "# *O#O*   #" @
        "# #O#@#   #" @
        "# *OOO  ###" @
        "###*# ###  " @
        "  #   #    " @
        "  #####    "
    )

level45:
    #d level(
        10, 9, 0,
        " ####     " @
        " #  ##### " @
        "##* ##  # " @
        "#  *P*  # " @
        "#   ##* # " @
        "###O## ###" @
        " #OOO* * #" @
        " ##OO    #" @
        "  ########"
    )

level46:
    #d level(
        14, 15, 0,
        "#####         " @
        "#   ##        " @
        "#    #  ####  " @
        "# *  ####  #  " @
        "#  ** *   *#  " @
        "###P #*    ## " @
        " #  ##  * * ##" @
        " # *  ## ## O#" @
        " #  #*##*  #O#" @
        " ###   *OO##O#" @
        "  #    #O@OOO#" @
        "  # ** #OOOOO#" @
        "  #  #########" @
        "  #  #        " @
        "  ####        "
    )

level47:
    #d level(
        16, 14, 0,
        "##### ####      " @
        "#OOO# #  ####   " @
        "#OOO###  *  #   " @
        "#OOOO## *  *### " @
        "##OOOO##   *  # " @
        "###OOO ## * * # " @
        "# ##    #  *  # " @
        "#  ## # ### ####" @
        "# * # #*  *    #" @
        "#  * P *    *  #" @
        "#   # * ** * ###" @
        "#  ######  ###  " @
        "# ##    ####    " @
        "###             "
    )

level48:
    #d level(
        18, 14, 0,
        "       #### ####  " @
        "     ###  # #  #  " @
        "  ####  * ### *#  " @
        "  # *   *      #  " @
        "###  ## *  *  *#  " @
        "#       # * ## #  " @
        "# #****# ** *  #  " @
        "#    * ** #### ###" @
        "####    * P## OOO#" @
        " #  **## #### OOO#" @
        " # *  #OOOO## OOO#" @
        " # #  *OOOO####OO#" @
        " ####  OOOO#  ####" @
        "    ########      "
    )

level49:
    #d level(
        10, 10, 0,
        "######### " @
        "#   ##  # " @
        "# # * * # " @
        "#  @O#  # " @
        "## #OPO## " @
        "##*###@###" @
        "#        #" @
        "#   ## # #" @
        "######   #" @
        "     #####"
    )

level50:
    #d level(
        11, 11, 0,
        "      #### " @
        "####### P# " @
        "#     *  # " @
        "#   *## *# " @
        "##*#OOO# # " @
        " # *OOO  # " @
        " # #O O# ##" @
        " #   # #* #" @
        " #*  *    #" @
        " #  #######" @
        " ####      "
    )

level51:
    #d level(
        9, 12, 0,
        "#### ####" @
        "#  ###  #" @
        "#    *  #" @
        "#  # #  #" @
        "## # #*##" @
        "#  #O#P #" @
        "#  @O@  #" @
        "#  #O# ##" @
        "####   # " @
        "   # #*# " @
        "   #   # " @
        "   ##### "
    )

level52:
    #d level(
        12, 12, 0,
        "       #####" @
        "  ######   #" @
        "###    O * #" @
        "# *  #*O#*##" @
        "#  #   O#  #" @
        "## ####OP  #" @
        " # *  #@####" @
        " # ## #O  # " @
        " #     O# # " @
        " ###*     # " @
        "   #  ##### " @
        "   ####     "
    )

level53:
    #d level(
        13, 10, 0,
        "######  #####" @
        "#    ####   #" @
        "# *   *   # #" @
        "##  # ### * #" @
        " #**  ###*# #" @
        "##   #  OOO #" @
        "#  # *  *OOO#" @
        "#  #####OO###" @
        "# P#   ####  " @
        "####         "
    )

level54:
    #d level(
        12, 15, 0,
        "#######     " @
        "# OOOO#     " @
        "# OOOO#     " @
        "# OOOO#     " @
        "##*#########" @
        "# * *      #" @
        "#   # ** * #" @
        "### #   #* #" @
        "  # # **   #" @
        "  # # # ** #" @
        "  # #  * ###" @
        "  # ###  #  " @
        "  #    #P#  " @
        "  ####   #  " @
        "     #####  "
    )

level55:
    #d level(
        9, 12, 0,
        " ####    " @
        " #  #    " @
        " #* ###  " @
        " #   P#  " @
        "## #O ###" @
        "#  #@O* #" @
        "# **OO# #" @
        "## ##O  #" @
        " # *  ###" @
        " #  ###  " @
        " #  #    " @
        " ####    "
    )

level56:
    #d level(
        18, 13, 0,
        "     #########    " @
        "     #    OOO#    " @
        "     # #  OOO#    " @
        "     # ##  OO#    " @
        "###### * * ###    " @
        "#OOO* * *P##      " @
        "#OO# * * *########" @
        "#OOO# * *        #" @
        "#OOO * *  #*#*## #" @
        "#  #### * * * #  #" @
        "#  #  #  *   *   #" @
        "####  ##   #######" @
        "       #####      "
    )

level57:
    #d level(
        11, 10, 0,
        " #####     " @
        " # P ######" @
        " # #OO@   #" @
        " # OOO#   #" @
        "##*## * * #" @
        "#   #*#####" @
        "#   *   #  " @
        "##### # #  " @
        "    #   #  " @
        "    #####  "
    )

level58:
    #d level(
        14, 13, 0,
        "     ######   " @
        "   ###    ##  " @
        "   #   ##  #  " @
        " ###*##  # #  " @
        "##     OO# #  " @
        "#  *#*#@O# #  " @
        "# **P #O@# ###" @
        "#  ** #OO#   #" @
        "##    #OO*   #" @
        " ###*##O # ###" @
        "   #  ###  #  " @
        "   ##     ##  " @
        "    #######   "
    )

level59:
    #d level(
        14, 16, 0,
        "##########    " @
        "#        #### " @
        "# ###### #  ##" @
        "# # * * *  * #" @
        "#       #*   #" @
        "###*  **#  ###" @
        "  #  ## # *## " @
        "  ##*#   * P# " @
        "   #  * * ### " @
        "   # #   *  # " @
        "   # ##   # # " @
        "  ##  ##### # " @
        "  #         # " @
        "  #OOOOOOO### " @
        "  #OOOOOOO#   " @
        "  #########   "
    )

level60:
    #d level(
        17, 16, 0,
        "    ############ " @
        "    #          ##" @
        "    #  # #** *  #" @
        "    #* #*#  ## P#" @
        "   ## ## # * # ##" @
        "   #   * #*  # # " @
        "   #   # *   # # " @
        "   ## * *   ## # " @
        "   #  #  ##  * # " @
        "   #    ## **# # " @
        "######**   #   # " @
        "#OOOO#  ######## " @
        "#O#OOO ##        " @
        "#OOOO   #        " @
        "#OOOO   #        " @
        "#########        "
    )

level61:
    #d level(
        18, 11, 0,
        "         ####     " @
        " #########  ##    " @
        "##  *      * #####" @
        "#   ## ##   ##OOO#" @
        "# #** * **#*##OOO#" @
        "# #    P  #   OOO#" @
        "#  *# ###**   OOO#" @
        "# *  **  * ##OOOO#" @
        "###*       #######" @
        "  #  #######      " @
        "  ####            "
    )

level62:
    #d level(
        12, 13, 0,
        " ####       " @
        " #  ######  " @
        " #     *P#  " @
        "## ##O##*#  " @
        "#  # O # ###" @
        "#   @OO#   #" @
        "## # O * # #" @
        "## ##O#  * #" @
        "#  ##O# ####" @
        "# ** *#  #  " @
        "#  #     #  " @
        "#######  #  " @
        "      ####  "
    )

level63:
    #d level(
        11, 9, 0,
        " ######### " @
        " #   #   # " @
        " # ***** # " @
        "## * * * # " @
        "# *  P   # " @
        "# * #### ##" @
        "#  #OOOOO #" @
        "##  OOOOO #" @
        " ##########"
    )

level64:
    #d level(
        6, 10, 0,
        " #####" @
        " # P #" @
        " #***#" @
        " # * #" @
        " #OOO#" @
        "##OOO#" @
        "#    #" @
        "# ** #" @
        "#  ###" @
        "####  "
    )

level65:
    #d level(
        14, 16, 0,
        "      ###     " @
        " ######P##### " @
        " #OOOOOOOOOO# " @
        "##O@@@@@@@@O##" @
        "#OO@OOOOOO@OO#" @
        "#OO@O@@@@O@OO#" @
        "######OO######" @
        " #          # " @
        " # * **** * # " @
        " #***    ***# " @
        " #   ****   # " @
        " #* *    * *# " @
        "##   ****   ##" @
        "# ***    *** #" @
        "#     #      #" @
        "##############"
    )
