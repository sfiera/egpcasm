#include "gamepock.asm"

#bankdef rom
{
    addr = CART.HEADER
    size = $2000
    fill = true
    outp = 0
}

ADD_HL_A = USER0
ADD_DE_A = USER1
ASTRO2 = USER2
ASTRO3 = USER3
ASTRO4 = USER4
ASTRO5 = USER5
ASTRO6 = USER6
GET_BOMBER_X = USER7
GET_BOMBER_Y = USER8
ASTRO9 = USER9

var_score     = $ffa0
var_hiscore   = $ffa3
var_mode      = $ffe7
var_level     = $fff4
var_zone      = $fff6
var_energy    = $fffc
var_lives     = $fffd
var_bomber_x  = $c5a2
var_bomber_y  = $c5a3

MODE_PLAYER   = 0
MODE_ATTRACT  = 1

ZONE_MURK  = 1
ZONE_CITY  = 2
ZONE_CAVE  = 3
ZONE_MAZE  = 4
ZONE_BOSS  = 5

header:
    db CART.MAGIC
    dw main
    dw main
    dw 0
    dw 0
    jmp interrupt

#addr CART.USER0
    jmp add_hl_a
    jmp add_de_a
    jmp astro2
    jmp astro3
    jmp astro4
    jmp astro5
    jmp astro6
    jmp get_bomber_x
    jmp get_bomber_y
    jmp astro9

#addr CART.BEGIN
main:
    lxi sp, $c7ff
    call init_level

start:
    lxi sp, $c7ff
    calt ACCCLR
    staw [$fff1]
    staw [$fff0]
    mvi a, ZONE_MURK
    staw [var_zone]
    call do_title

    mvi a, ZONE_MURK
    staw [var_zone]
.next_round:
    call start_round
.next_zone:
    neiw [var_zone], ZONE_MURK
    call play_basic
    neiw [var_zone], ZONE_CITY
    call play_basic
    neiw [var_zone], ZONE_CAVE
    call play_basic
    neiw [var_zone], ZONE_MAZE
    call play_maze
    neiw [var_zone], ZONE_BOSS
    call play_boss
    eqiw [$fff0], $00
    jr .jr4076
    call call42ed
    call call4303
    jre .next_zone
.jr4076:
    eqiw [$fff0], $01
    jr .jr407f
    call call40dd
    jre .next_zone
.jr407f:
    lxi hl, var_score
    lxi de, var_hiscore
    mvi b, $03
    calt MEMCCPY
    lxi de, var_hiscore
    neiw [var_level], $01
    lxi hl, $c692
    lxi hl, $c695
    mvi b, $02
.jr4096:
    ldax [de+]
    stax [hl+]
    dcr b
    jr .jr4096
    eqiw [$fff0], $09
    jr .jr40a3
    call call4329
    jre start
.jr40a3:
    call try436f
    jre .next_round
    jre start

play_basic:
    call init_basic
.loop:
    call call4bde
    call call4d75
    call update_screen
    neiw [$fff1], $00
    jr .loop
    ret

play_maze:
    call init_maze
.loop:
    call call5552
    call call55cf
    call update_screen
    neiw [$fff1], $00
    jr .loop
    ret

play_boss:
    call init_boss
.loop:
    call call5778
    call call578a
    call update_screen
    neiw [$fff1], $00
    jr .loop
    ret

call40dd:
    mvi a, $01
    inrw [var_zone]
    ltiw [var_zone], ZONE_BOSS + 1
    staw [var_zone]
    call call4307
    eqiw [var_zone], ZONE_MURK
    ret
    eqiw [var_level], $01
    jr .jr40f7
    gtiw [$fff5], $02
    inrw [$fff5]
    ret
.jr40f7:
    gtiw [$fff5], $04
    inrw [$fff5]
    ret

do_title:
    calt SCR1CLR
    aniw [TIME.SEC], $00
    call call4194
    call call41b9

    ; Draw ASTRO BOMBER title text
    lxi de, $c061
    lxi hl, gfx_astro
    mvi b, $1e
    calt MEMCOPY
    lxi de, $c0a9
    lxi hl, gfx_bomber
    mvi b, $24
    calt MEMCOPY

    ; Draw LEVEL-N and lives text
    lxi hl, str_level
    calt DRAWTEXT
    db $10, $1d, TEXT.SCR1 | TEXT.SPC1 | str_level.len
    lxi hl, var_level
    calt DRAWHEX
    db $35, $1d, TEXT.SCR1 | TEXT.SMALL
    lxi hl, var_lives
    calt DRAWHEX
    db $2c, $24, TEXT.SCR1 | TEXT.SMALL

    aniw [$ffde], $00
    oriw [$ffdf], $01
    call update_screen

.config:
    ; Check for Start; return if pressed.
    calt JOYREAD
    offiw [JOY.BTN.EDGE], JOY.BTN.STA
    ret
    ; Check for Select; toggle level if pressed
    ; and then go back to the top to redraw and restart.
    call try_config
    jre do_title
    ; Check for >15 seconds waiting; loop if not.
    gtiw [TIME.SEC], $0f
    jr .config

    ; After 15 seconds, start attract mode.
    ; Cycle through each of the zones.
    mvi a, MODE_ATTRACT
    staw [var_mode]
.attract:
    calt ACCCLR
    staw [$fff1]
    calt ASTRO5
    mvi a, $80
    stax [hl+]
    mvi a, $01
    stax [hl+]
    calt ACCCLR
    stax [hl+]
    stax [hl]
    call call4303
    neiw [var_zone], ZONE_MURK
    call play_basic
    neiw [var_zone], ZONE_CITY
    call play_basic
    neiw [var_zone], ZONE_CAVE
    call play_basic
    neiw [var_zone], ZONE_MAZE
    call play_maze
    neiw [var_zone], ZONE_BOSS
    call play_boss
    eqiw [$fff1], $03
    jr .jr4185
    inrw [var_zone]
    gtiw [var_zone], ZONE_BOSS
    jre .attract
    jmp start
.jr4185:
    eqiw [$fff1], $01
    jre do_title
    ldaw [var_level]
    xri a, $03
    staw [var_level]
    call toggle_level
    ret

call4194:
    call call488c
    lxi bc, data4d50
    lxi de, $c666
    lxi hl, data41db
    mvi a, $25
    staw [$ffe0]
.jr41a4:
    ldax [hl+]
    staw [$ffe1]
.jr41a7:
    ldax [bc]
    stax [de+]
    dcrw [$ffe0]
    jr .jr41ad
    jr .jr41b2
.jr41ad:
    dcrw [$ffe1]
    jr .jr41a7
    inx bc
    jr .jr41a4
.jr41b2:
    aniw [$fff2], $00
    call call4c33
    ret

call41b9:
    call call41c6
    lxi de, $c5b4
    lxi hl, data41ec
    mvi b, $17
    calt MEMCOPY
    ret

call41c6:
    lxi hl, $c5a0
    mvi b, $4f
    calt ACCCLR
    calt MEMSET
    ret

call41ce:
    call call41c6
    lxi de, $c5b4
    lxi hl, data41f4
    mvi b, $0f
    calt MEMCOPY
    ret

data41db:
    #d $0500010004000200000300040101000000

data41ec:
    #d $8003142580162223

data41f4:
    #d $800804348007152e80082c2e80073634

gfx_astro:
    #d $incbin("astrobom/title.1bpp")[575:328]
gfx_bomber:
    #d $incbin("astrobom/title.1bpp")[327:24]

str_level:
    #d smalltext("LEVEL"), largetext("-")
.len = $ - str_level

str_hiscore:
    #d largetext("HIGH SCORE")
.len = $ - str_hiscore
str_gameover:
    #d largetext("GAME OVER")
.len = $ - str_gameover
str_perfect:
    #d largetext("[PERFECT]")
.len = $ - str_perfect
str_verygood:
    #d largetext("VERY GOOD!")
.len = $ - str_verygood
str_4800:
    #d largetext("=4800=")
.len = $ - str_4800

start_round:
    lxi hl, music_start
    calt MUSPLAY
    calt ACCCLR
    staw [var_mode]
    mov [$c6ec], a
    staw [TIME.SEC]
    call call4300
    calt SCR1CLR
    call call4194
    call call41ce
    oriw [$ffdf], $01
    call update_screen
    lxi hl, str_hiscore
    calt DRAWTEXT
    db $08, $14, TEXT.SCR1 | TEXT.SPC1 | str_hiscore.len
    call call431a
    neiw [var_level], $01
    lxi hl, $c692
    lxi hl, $c695
    lxi de, var_hiscore
    mvi b, $02
    calt MEMCOPY
    lxi hl, var_hiscore
    calt DRAWHEX
    db $17, $1e, TEXT.SCR1 | TEXT.SPC1 | 4
    calt SCRN2LCD
.jr42b9:
    eqiw [TIME.SEC], $04
    jr .jr42b9
    aniw [$fff1], $00
    aniw [$fff0], $00
    aniw [TIME.SEC], $00
    call call41c6
    call call42ed
    ret

try_config:
    oniw [JOY.BTN.EDGE], JOY.BTN.SEL
    rets
    oniw [JOY.BTN.CURR], JOY.BTN.SEL
    rets

toggle_level:
    lxi hl, music_select
    calt MUSPLAY
    eqiw [var_level], $01
    ; fall through

init_level:
    mvi a, $01
    mvi a, $02
    staw [var_level]
    call call4a6b
    ; fall through

clear_score:
    lxi hl, var_score
    calt ACCCLR
    stax [hl+]
    stax [hl+]
    stax [hl]
    ret

call42ed:
    lxi hl, $c5a0
    lxi hl, $ffd0
    mvi a, $80
    stax [hl+]
    mvi a, $01
    stax [hl+]
    mvi a, $0a
    stax [hl+]
    mvi a, $1c
    stax [hl]
    ret

call4300:
    call clear_score

call4303:
    mvi a, $1e
    staw [var_energy]

call4307:
    lxi hl, $c5a4
    calt ACCCLR
    mvi b, $4b
    calt MEMSET
    calt ACCCLR
    staw [$fffe]
    staw [$ffff]
    mvi a, $04
    mov [$c6a8], a
    ret

call431a:
    lxi hl, str_level
    calt DRAWTEXT
    db $05, $00, TEXT.SCR1 | TEXT.SPC1 | str_level.len
    lxi hl, var_level
    calt DRAWHEX
    db $28, $00, TEXT.SCR1 | TEXT.SMALL
    ret

call4329:
    oriw [var_mode], MODE_ATTRACT
    lxi hl, music_perfect
    calt MUSPLAY
    call call4a6b
.jr4333:
    offiw [$ff80], $07
    jr .jr4333
.jr4337:
    calt SCR1CLR
    lxi de, $c061
    lxi hl, gfx_astro
    mvi b, $1e
    calt MEMCOPY
    lxi de, $c0a9
    lxi hl, gfx_bomber
    mvi b, $24
    calt MEMCOPY
    lxi hl, str_perfect
    calt DRAWTEXT
    db $0b, $1c, TEXT.SCR1 | TEXT.SPC1 | str_perfect.len
    lxi hl, str_verygood
    calt DRAWTEXT
    db $0b, $29, TEXT.SCR1 | TEXT.SPC1 | str_verygood.len
    eqiw [var_level], $02
    jr .jr4367
    gtiw [$ff88], $40
    jr .jr4367
    lxi hl, str_4800
    calt DRAWTEXT
    db $14, $36, TEXT.SCR1 | TEXT.SPC1 | str_4800.len
.jr4367:
    calt SCRN2LCD
    calt JOYREAD
    oniw [JOY.BTN.EDGE], JOY.BTN.SEL | JOY.BTN.STA
    jre .jr4337
    ret

try436f:
    call call4a6b
.jr4372:
    offiw [$ff88], $40
    jr .jr437f
    eqiw [$ffe4], $01
    jr .jr4387
    aniw [$ffe4], $00
    calt SCR1INV
    jr .jr4387
.jr437f:
    eqiw [$ffe4], $00
    jr .jr4387
    oriw [$ffe4], $01
    calt SCR1INV
.jr4387:
    calt SCRN2LCD
    gtiw [TIME.SEC], $05
    jr .jr4372
    eqiw [$ffe4], $01
    calt SCR1INV
    oriw [var_mode], MODE_ATTRACT
    lxi hl, music_gameover
    calt MUSPLAY
.jr4397:
    oriw [$ffde], $01
    call update_screen
    lxi hl, $c0ea
    calt ACCCLR
    mvi b, $37
    calt MEMSET
    gtiw [$ff88], $40
    jr .jr43af
    lxi hl, str_gameover
    calt DRAWTEXT
    db $0a, $18, TEXT.SCR1 | TEXT.SPC1 | str_gameover.len
.jr43af:
    calt SCRN2LCD
    calt JOYREAD
    oniw [JOY.BTN.EDGE], JOY.BTN.STA
    jr .jr43ba
    gtiw [TIME.SEC], $0a
    ret
    rets
.jr43ba:
    offiw [JOY.BTN.CURR], JOY.BTN.SEL
    rets
    gtiw [TIME.SEC], $14
    jre .jr4397
    rets

update_screen:
    calt ASTRO5
    mvi a, $13
    staw [$ffd8]
.jr43c9:
    call try43e6
    jr .jr43d5
    push hl
    call call4424
    pop hl
    jr .jr43c9
.jr43d5:
    neiw [$ffdf], $00
    call update_header
    aniw [$ffdf], $00
    neiw [$ffde], $00
    calt SCRN2LCD
    aniw [$ffde], $00
    ret

try43e6:
    ldax [hl+]
    offi a, $80
    jr .jr43f1
.jr43ea:
    mvi a, $03
    calt ADD_HL_A
    dcrw [$ffd8]
    jr try43e6
    ret
.jr43f1:
    offi a, $10
    jr .jr43ea
    staw [$ffd0]
    ldax [hl+]
    staw [$ffd1]
    ldax [hl+]
    staw [$ffd2]
    gti a, $4b
    jr .jr4408
    lti a, $f6
    jr .jr4408
    neiw [$ffd1], $10
    jr .jr4408
    inx hl
    jr .jr440e
.jr4408:
    ldax [hl+]
    staw [$ffd3]
    gti a, $3f
    rets
.jr440e:
    mvi a, $fc
    add a, l
    mov l, a
    calt ACCCLR
    stax [hl+]
    gtiw [$ffd1], $08
    jre .jr43ea
    ltiw [$ffd1], $0e
    jre .jr43ea
    dcrw [$fffe]
    nop
    jre .jr43ea

call4424:
    ldaw [$ffd1]
    dcr a
    lxi de, gfx_size
    calt ADD_DE_A
    ldaw [$ffd1]
    dcr a
    clc
    ral
    mov b, a
    ldax [de]
    mov c, a
    ani a, $0f
    staw [$ffd5]
    mov a, c
    clc
    ani a, $f0
    calt ACC4RAR
    staw [$ffd4]
    mov a, b
    lxi de, gfx_addr
    calt ADD_DE_A
    ldax [de+]
    mov [$c68e], a
    ldax [de]
    mov [$c68f], a
    oniw [$ffd2], $80
    jre .jr447d
    ldaw [$ffd2]
    dcr a
    xri a, $ff
    mov b, a
    ldaw [$ffd4]
    gta a, b
    ret
    mov a, b
    lbcd [$c68e]
    call call46ab
    sbcd [$c68e]
    ldaw [$ffd4]
    mov b, a
    ldaw [$ffd2]
    add a, b
    staw [$ffda]
    inr b
    lta a, b
    ret
    aniw [$ffd2], $00
    jr .jr448c
.jr447d:
    ldaw [$ffd2]
    mov b, a
    ldaw [$ffd4]
    add a, b
    lti a, $4c
    mvi a, $4b
    sub a, b
    staw [$ffda]
.jr448c:
    ldaw [$ffd3]
    ani a, $07
    staw [$ffd6]
    mov b, a
    mvi a, $08
    sub a, b
    ani a, $07
    staw [$ffd7]
    ldaw [$ffd2]
    mov h, a
    ldaw [$ffd3]
    mov l, a
    call call46ca
    shld [$c690]
    mov a, h
    nei a, $00
    ret
    call call470a
    gtiw [$ffd5], $08
    jr .jr44d0
    ldaw [$ffd3]
    adi a, $08
    staw [$ffd3]
    lti a, $40
    jr .jr44d0
    lhld [$c68e]
    ldaw [$ffd4]
    calt ADD_HL_A
    shld [$c68e]
    ldaw [$ffd5]
    sui a, $08
    staw [$ffd5]
    call call470a
.jr44d0:
    ret

update_header:
    lxi hl, $c000
    mvi b, $4a
    calt ACCCLR
    calt MEMSET
    neiw [var_mode], MODE_PLAYER
    jr .jr44e1
    call call431a
    jre .jr451c
.jr44e1:
    lxi hl, var_lives
    calt DRAWHEX
    db $00, $00, TEXT.SCR1 | TEXT.SMALL
    lxi hl, str_energy
    calt DRAWTEXT
    db $0d, $00, TEXT.SCR1 | TEXT.SPC4 | str_energy.len
    lxi de, $c6a8
    ldax [de]
    mov b, [TIME.SEC]
    lta a, b
    jr .jr4506
    inr a
    inr a
    stax [de]
    ltiw [TIME.SEC], $3c
    jr .jr4506
    eqiw [var_energy], $00
    dcrw [var_energy]
.jr4506:
    ltiw [var_energy], $06
    jr .jr450e
    gtiw [$ff88], $50
    jr .jr4518
.jr450e:
    ldaw [var_energy]
    mov b, a
    lxi hl, $c013
    mvi a, $1f
    dcr b
    calt MEMSET
.jr4518:
    neiw [var_zone], ZONE_BOSS
    jr .jr4524
.jr451c:
    lxi hl, var_score
    calt DRAWHEX
    db $32, $00, TEXT.SCR1 | TEXT.SMALL | 5
    jr .jr453c
.jr4524:
    lxi hl, str_time
    calt DRAWTEXT
    db $33, $00, TEXT.SCR1 | TEXT.SPC4 | str_time.len
    call call5f4b
    lxi hl, $c6fb
    calt DRAWHEX
    db $3c, $00, TEXT.SCR1 | TEXT.SMALL | 2
    lxi hl, $c039
    mvi a, $04
    stax [hl+]
    stax [hl]
.jr453c:
    ret

str_energy:
    #d smalltext("E")
.len = $ - str_energy

str_time:
    #d smalltext("T"), largetext(".")
.len = $ - str_time

sprite_data = $incbin("astrobom/sprites.1bpp")
#fn sprite(addr, w, h, begin) => {
    end = begin + w * ((h + 7) / 8)
    first = $sizeof(sprite_data) - 8*begin - 1
    last = $sizeof(sprite_data) - 8*end
    struct{
        addr = addr
        size = w`4 @ h`4
        begin = begin
        end = end
        data = sprite_data[first:last]
    }
}

bomber1      = sprite(gfx_data.bomber1,         11,  3,   0)
bomber2      = sprite(gfx_data.bomber2,         11,  3,   bomber1.end)
bomber3      = sprite(gfx_data.bomber3,         11,  3,   bomber2.end)
bomb_rt      = sprite(gfx_data.bomb_rt,         3,   3,   bomber3.end)
bomb_dn      = sprite(gfx_data.bomb_dn,         3,   3,   bomb_rt.end)
bullet       = sprite(gfx_data.bullet,          2,   1,   bomb_dn.end)
depot        = sprite(gfx_data.depot,           7,   6,   bullet.end)
rocket       = sprite(gfx_data.rocket,          5,   8,   depot.end)
haze1        = sprite(gfx_data.haze1,           13,  7,   rocket.end)
haze2        = sprite(gfx_data.haze2,           11,  7,   haze1.end)
haze3        = sprite(gfx_data.haze3,           10,  6,   haze2.end)
haze4        = sprite(gfx_data.haze4,           9,   5,   haze3.end)
bouncer      = sprite(gfx_data.bouncer,         7,   7,   haze4.end)
ameba_whole  = sprite(gfx_data.ameba_whole,     5,   9,   bouncer.end)
ameba_split  = sprite(gfx_data.ameba_split,     3,   5,   ameba_whole.end)
boss_shot    = sprite(gfx_data.boss_bullet,     6,   3,   ameba_split.end)
boss_armed   = sprite(gfx_data.boss_armed,      9,   15,  boss_shot.end)
boss_fired   = sprite(gfx_data.boss_fired,      8,   15,  boss_armed.end)
boss_bottom  = sprite(gfx_data.boss_fired + 8,  8,   7,   boss_fired.begin + 8)
boss_top     = sprite(gfx_data.boss_top,        8,   7,   boss_fired.end)
explode1     = sprite(gfx_data.explode1,        5,   5,   boss_top.end)
explode2     = sprite(gfx_data.explode2,        6,   6,   explode1.end)
explode3     = sprite(gfx_data.explode3,        7,   7,   explode2.end)
explode4     = sprite(gfx_data.explode4,        7,   7,   explode3.end)
shield       = sprite(gfx_data.shield,          14,  3,   explode4.end)
block        = sprite(gfx_data.block,           8,   8,   shield.end)

gfx_size:
    db bomber1.size
    db bomber2.size
    db bomber3.size
    db bomb_rt.size
    db bomb_dn.size
    db bullet.size
    db depot.size
    db rocket.size
    db haze1.size
    db haze2.size
    db haze3.size
    db haze4.size
    db bouncer.size
    db ameba_whole.size
    db ameba_split.size
    db boss_shot.size
    db boss_armed.size
    db boss_fired.size
    db boss_top.size
    db boss_bottom.size
    db explode1.size
    db explode2.size
    db explode3.size
    db explode1.size
    db explode2.size
    db explode3.size
    db explode1.size
    db explode2.size
    db explode3.size
    db explode4.size
    db shield.size
    db explode1.size
    db explode2.size
    db explode1.size
    db explode2.size
    db block.size

gfx_addr:
    dw bomber1.addr
    dw bomber2.addr
    dw bomber3.addr
    dw bomb_rt.addr
    dw bomb_dn.addr
    dw bullet.addr
    dw depot.addr
    dw rocket.addr
    dw haze1.addr
    dw haze2.addr
    dw haze3.addr
    dw haze4.addr
    dw bouncer.addr
    dw ameba_whole.addr
    dw ameba_split.addr
    dw boss_shot.addr
    dw boss_armed.addr
    dw boss_fired.addr
    dw boss_top.addr
    dw boss_bottom.addr
    dw explode1.addr
    dw explode2.addr
    dw explode3.addr
    dw explode1.addr
    dw explode2.addr
    dw explode3.addr
    dw explode1.addr
    dw explode2.addr
    dw explode3.addr
    dw explode4.addr
    dw shield.addr
    dw explode1.addr
    dw explode2.addr
    dw explode1.addr
    dw explode2.addr
    dw block.addr

gfx_data:
.bomber1:
    #d bomber1.data
.bomber2:
    #d bomber2.data
.bomber3:
    #d bomber3.data
.bomb_rt:
    #d bomb_rt.data
.bomb_dn:
    #d bomb_dn.data
.bullet:
    #d bullet.data
.depot:
    #d depot.data
.rocket:
    #d rocket.data
.haze1:
    #d haze1.data
.haze2:
    #d haze2.data
.haze3:
    #d haze3.data
.haze4:
    #d haze4.data
.bouncer:
    #d bouncer.data
.ameba_whole:
    #d ameba_whole.data
.ameba_split:
    #d ameba_split.data
.boss_bullet:
    #d boss_shot.data
.boss_armed:
    #d boss_armed.data
.boss_fired:
    #d boss_fired.data
.boss_top:
    #d boss_top.data
.explode1:
    #d explode1.data
.explode2:
    #d explode2.data
.explode3:
    #d explode3.data
.explode4:
    #d explode4.data
.shield:
    #d shield.data
.block:
    #d block.data

call467f:
    push bc
    mov b, a
    ldax [hl]
.jr4683:
    dcr b
    jr .jr4688
    pop bc
    ret
.jr4688:
    clc
    ral
    jr .jr4683

call468d:
    push bc
    mov b, a
    ldax [hl]
.jr4691:
    dcr b
    jr .jr4696
    pop bc
    ret
.jr4696:
    clc
    rar
    jr .jr4691

add_hl_a:
    add a, l
    mov l, a
    mov a, h
    aci a, $00
    mov h, a
    ret

add_de_a:
    add a, e
    mov e, a
    mov a, d
    aci a, $00
    mov d, a
    ret

call46ab:
    add a, c
    mov c, a
    sknc
    inr b
    ret

astro5:
    lxi hl, $c5a0
    ret

astro6:
    mov a, [$c5a0]
    ret

get_bomber_x:
    mov a, [var_bomber_x]
    ret

get_bomber_y:
    mov a, [var_bomber_y]
    ret

astro9:
    mov a, [$c6cb]
    ret

call46ca:
    mov a, l
    clc
    ani a, $f8
    calf $0c70
    mov c, a
    lti a, $08
    jr .jr46e6
    mov a, h
    lti a, $4b
    jr .jr46e6
    mov b, a
    lxi hl, $c000
.jr46dd:
    dcr c
    jr .jr46e2
    mov a, b
    calt ADD_HL_A
    ret
.jr46e2:
    mvi a, $4b
    calt ADD_HL_A
    jr .jr46dd
.jr46e6:
    lxi hl, $0000
    ret

call46ea:
    push va
    mov a, b
    oni a, $04
    jr .jr46fd
    pop va
    dcr a
    lti a, $09
    ret
.jr46f6:
    mov a, b
    ani a, $fb
    mov b, a
    mvi a, $0a
    ret
.jr46fd:
    pop va
    inr a
    gti a, $0c
    ret
.jr4703:
    mov a, b
    ori a, $04
    mov b, a
    mvi a, $0b
    ret

call470a:
    ldaw [$ffd6]
    nei a, $00
    jr .jr4718
    mov b, a
    ldaw [$ffd5]
    add a, b
    gti a, $08
    mvi a, $00
.jr4718:
    staw [$ffd9]
    ltiw [$ffd3], $38
    aniw [$ffd9], $00
    lbcd [$c690]
    lded [$c690]
    mvi a, $4b
    call call46ab
    sbcd [$c690]
    lhld [$c68e]
    ldaw [$ffda]
    dcr a
    staw [$ffdb]
.jr473a:
    ldaw [$ffd6]
    call call467f
    orax [de]
    stax [de+]
    neiw [$ffd9], $00
    jr .jr474f
    ldaw [$ffd7]
    call call468d
    orax [bc]
    stax [bc]
    inx bc
.jr474f:
    inx hl
    dcrw [$ffdb]
    jr .jr473a
    ret

call4754:
    calt ASTRO2
    eqiw [var_mode], MODE_PLAYER
    ret
    eqiw [var_energy], $00
    jre .jr4781
    mvi b, $00
    mvi a, $03
    mov [$c5a1], a
    mov a, [$c6f2]
    inr a
    mov [$c6f2], a
    gti a, $01
    jr .jr477f
    calt ACCCLR
    mov [$c6f2], a
    calt GET_BOMBER_Y
    inr a
    mov [var_bomber_y], a
    mvi b, $00
.jr477f:
    jre .jr47c1
.jr4781:
    lxi hl, $c5a1
    ldax [hl]
    eqi a, $01
    mvi a, $01
    mvi a, $02
    stax [hl]
    calt ACCCLR
    mov [$c6f2], a
    mov a, [$c6ca]
    inr a
    nop
    mov [$c6ca], a
    eqi a, $01
    jre .jr47c1
    calt ACCCLR
    mov [$c6ca], a
    mov a, [$c6c8]
    sui a, $01
    lti a, $0c
    jre .jr47da
    clc
    ral
    lxi hl, data47f2
    calt ADD_HL_A
    lxi de, var_bomber_x
    ldax [hl+]
    addx [de]
    stax [de+]
    ldax [hl]
    addx [de]
    stax [de]
.jr47c1:
    calt GET_BOMBER_X
    oni a, $80
    jr .jr47c7
    calt ACCCLR
    jr .jr47cc
.jr47c7:
    gti a, $28
    jr .jr47d0
    mvi a, $29
.jr47cc:
    mov [var_bomber_x], a
.jr47d0:
    calt GET_BOMBER_Y
    lti a, $08
    jr .jr47da
    mvi a, $08
    mov [var_bomber_y], a
.jr47da:
    calt GET_BOMBER_Y
    lti a, $3c
    mvi a, $3c
    mov [var_bomber_y], a
    mov a, [$c6e6]
    eqi a, $00
    call call480a
    calt ACCCLR
    mov [$c6e6], a
    ret

data47f2:
    #d $00fefd
    #d $00fdfe
    #d $000200
    #d $00fd02
    #d $000003
    #d $0003fe
    #d $000000
    #d $000302

call480a:
    calt ASTRO6
    nei a, $00
    ret
    mvi b, $02
    lxi hl, $c5a8
.jr4813:
    ldax [hl]
    offi a, $80
    jr .jr4826
    mvi a, $a0
    stax [hl+]
    mvi a, $06
    stax [hl+]
    calt GET_BOMBER_X
    adi a, $0c
    stax [hl+]
    calt GET_BOMBER_Y
    adi a, $02
    stax [hl]
    jr .jr482c
.jr4826:
    mvi a, $04
    calt ADD_HL_A
    dcr b
    jr .jr4813
    ret
.jr482c:
    lxi hl, $c5a4
    ldax [hl-]
    offi a, $80
    jr .jr4844
    lxi de, $c5a7
    ldax [hl-]
    adi a, $02
    stax [de-]
    ldax [hl-]
    adi a, $05
    stax [de-]
    mvi a, $04
    stax [de-]
    mvi a, $80
    stax [de]
.jr4844:
    lxi hl, music_shoot
    calt MUSPLAY
    calt ASTRO2
    ret

call484a:
    calt ASTRO5
    ldaw [$ffdc]
    calt ASTRO4
    inx hl
    ldax [hl-]
    nei a, $1f
    jr .jr4856
    calt ACCCLR
    stax [hl+]
    ldax [hl]
.jr4856:
    mov b, a
    ; fall through

call4857:
    push bc
    call call52c6
    pop bc
    mov a, b
    nei a, $07
    jr .jr4868
    eqi a, $10
    mvi a, $00
    mvi a, $80
.jr4868:
    mvi a, $19
    call call4a59
    lxi hl, music_crash
    calt MUSPLAY
    call call4a3e
    ret

call4875:
    calt ACCCLR
    staw [$fff2]
    staw [$fff9]
    staw [$fffb]
    staw [$fff8]
    staw [$fffa]
    lxi hl, $c69a
    stax [hl+]
    stax [hl+]
    stax [hl+]
    stax [hl]
    lxi hl, $c6bd
    stax [hl+]
    stax [hl]
    ; fall through

call488c:
    mvi b, $26
    lxi hl, $c666
    lxi de, $c640
.jr4894:
    stax [hl+]
    stax [de+]
    dcr b
    jr .jr4894
    calt SCR1CLR
    calt SCR2CLR
    ret

call489b:
    push hl
    push bc
    push de
    push va
    calt JOYREAD
    eqiw [var_mode], MODE_PLAYER
    jre .jr48ef
    calt ASTRO6
    oni a, $80
    jre .jr48e6
    lhld [JOY.DIR.CURR]
    lded [$c6c8]
    mov a, d
    ora a, h
    mov b, a
    mov a, e
    ora a, l
    mov c, a
    shld [$c6c8]
    mov a, h
    offi a, $36
    jr .jr48cc
    calt ACCCLR
    mov [$c6fd], a
    jr .jr48dd
.jr48cc:
    mov a, [$c6fd]
    eqi a, $00
    jr .jr48dd
    mvi a, $01
    mov [$c6e6], a
    mov [$c6fd], a
.jr48dd:
    ldaw [JOY.BTN.CURR]
    ani a, JOY.BTN.SEL | JOY.BTN.STA
    eqi a, JOY.BTN.SEL | JOY.BTN.STA
    jr .jr48e6
    jre .jr4908
.jr48e6:
    pop va
    pop de
    pop bc
    pop hl
    ret
.jr48ef:
    ldaw [JOY.BTN.CURR]
    mov b, a
    ldaw [JOY.BTN.EDGE]
    ana a, b
    oni a, JOY.BTN.STA
    jr .jr48fe
    mvi a, $01
.jr48fb:
    staw [$fff1]
    jr .jr48e6
.jr48fe:
    oni a, $01
    jr .jr48e6
    lxi hl, music_select
    calt MUSPLAY
    mvi a, $02
    jr .jr48fb
.jr4908:
    oriw [var_mode], MODE_ATTRACT
    calf $0e4d
    calt ACCCLR
    mov [$c6ec], a
    mov [$c6e7], a
.jr4916:
    calt JOYREAD
    ldaw [JOY.BTN.CURR]
    eqi a, $00
    jr .jr4916
    jmp main

interrupt:
    push hl
    push bc
    push de
    push va
    mov a, [$c6e8]
    eqi a, $00
    jre .jr4950
    calt ASTRO6
    oni a, $80
    jr .jr4950
    mov a, [$c6ec]
    nei a, $00
    jr .jr493f
    lxi hl, music_bossgun
    calt MUSPLAY
    jr .jr4950
.jr493f:
    eqiw [var_mode], MODE_PLAYER
    jr .jr4950
    calt ASTRO5
    ldax [hl+]
    oni a, $80
    jr .jr4950
    ldax [hl]
    nei a, $03
    jr .jr4950
    lxi hl, music_engine
    calt MUSPLAY
.jr4950:
    pop va
    pop de
    pop bc
    pop hl
    jmp $0169

try495b:
    ldaw [$ffda]
    mov b, a
    ldaw [$ffd0]
    gta a, b
    jr .jr4964
    rets
.jr4964:
    ldaw [$ffd9]
    mov b, a
    ldaw [$ffd1]
    gta a, b
    jr .jr496d
    rets
.jr496d:
    ldaw [$ffd7]
    mov b, a
    ldaw [$ffd3]
    lta a, b
    jr .jr4976
    rets
.jr4976:
    ldaw [$ffd6]
    mov b, a
    ldaw [$ffd4]
    lta a, b
    ret
    rets

try497f:
    ldaw [$ffd0]
    gta a, d
    jr .jr4985
    rets
.jr4985:
    ldaw [$ffd4]
    lta a, d
    jr .jr498b
    rets
.jr498b:
    ldaw [$ffd1]
    gta a, e
    jr .jr4991
    rets
.jr4991:
    ldaw [$ffd3]
    lta a, e
    ret
    rets

astro2:
    push hl
    push bc
    lxi hl, $c6fe
    ldax [hl]
    rar
    stax [hl+]
    ldax [hl]
    ral
    stax [hl+]
    ldax [hl]
    rar
    rar
    sknc
    ori a, $40
    stax [hl]
    lxi de, $c6fe
    mvi b, $02
.jr49b5:
    lxi hl, $c6fe
    stc
    ldax [hl+]
    adcx [hl+]
    adcx [hl]
    stax [de+]
    dcr b
    jr .jr49b5
    lxi hl, $c6fe
    ldax [hl+]
    adcx [hl+]
    adcx [hl]
    pop bc
    pop hl
    ret

call49cf:
    nei a, $01
    jr .jr49dc
    nei a, $02
    jre .jr49f9
    nei a, $03
    jr .jr49e4
    mvi h, $00
    ret
.jr49dc:
    lxi hl, $c5b4
    mvi a, $0d
    staw [$ffe0]
    jr .jr49eb
.jr49e4:
    lxi hl, $c5c8
    mvi a, $08
    staw [$ffe0]
.jr49eb:
    mvi a, $80
    onax [hl]
    ret
    mvi a, $04
    calt ADD_HL_A
    dcrw [$ffe0]
    jr .jr49eb
    mvi h, $00
    ret
.jr49f9:
    lxi hl, $c5b4
    mvi a, $0d
    staw [$ffe0]
.jr4a00:
    mvi a, $80
    onax [hl]
    jr .jr4a0e
    mvi a, $04
    calt ADD_HL_A
    dcrw [$ffe0]
    jr .jr4a00
    mvi h, $00
    ret
.jr4a0e:
    mvi a, $04
    calt ADD_HL_A
    dcrw [$ffe0]
    jr .jr4a17
    mvi h, $00
    ret
.jr4a17:
    mvi a, $80
    onax [hl]
    jr .jr4a26
    mvi a, $04
    calt ADD_HL_A
    dcrw [$ffe0]
    jre .jr4a00
    mvi h, $00
    ret
.jr4a26:
    mvi a, $04
    call call4a2c
    ret

call4a2c:
    push bc
    mov c, a
    mov a, l
    clc
    sub a, c
    mov l, a
    mov a, h
    mvi h, $00
    sbb a, h
    mov h, a
    pop bc
    ret

call4a3e:
    ldaw [var_score]
    gti a, $09
    ret
    mvi a, $01
    staw [$fff1]
    mvi a, $09
    staw [$fff0]
    staw [var_score]
    mvi a, $99
    staw [$ffa1]
    staw [$ffa2]
    calt ACCCLR
    mov [$c6ec], a
    ret

call4a59:
    push bc
    push de
    push hl
    mov l, a
    mvi h, $00
    calt ARITHMTC
    db ARITH.BCD | ARITH.HL3 | ARITH.HLW | ARITH.DE2 | ARITH.DEW
    pop hl
    pop de
    pop bc
    ret

call4a6b:
    eqiw [var_level], $02
    mvi a, $06
    mvi a, $04
    staw [var_lives]
    aniw [TIME.SEC], $00
    mvi a, $01
    staw [$ffe4]
    eqiw [var_level], $02
    mvi a, $00
    mvi a, $02
    staw [$fff5]
    ret

music_start:
    db PITCH.C4, $12
    db PITCH.C4, $09
    db PITCH.F4, $36
    db PITCH.A4, $09
    db PITCH.G4, $09
    db PITCH.F4, $09
    db PITCH.G4, $1b
    db PITCH.A4, $09
    db PITCH.C5, $36
    db PITCH.C5, $09
    db PITCH.D5, $09
    db PITCH.A4, $09
    db PITCH.C5, $1b
    db PITCH.AS4, $1b
    db PITCH.A4, $1b
    db PITCH.A4, $09
    db PITCH.F4, $09
    db PITCH.A4, $09
    db PITCH.G4, $36
    db $ff

music_fanfare:
    db PITCH.C4, $12
    db PITCH.C4, $09
    db PITCH.F4, $2d
    db PITCH.F4, $09
    db PITCH.G4, $24
    db PITCH.GS4, $09
    db PITCH.AS4, $09
    db PITCH.GS4, $36
    db PITCH.C4, $1b
    db PITCH.C4, $12
    db PITCH.C4, $09
    db PITCH.F4, $2d
    db PITCH.G4, $09
    db PITCH.GS4, $12
    db PITCH.F4, $09
    db PITCH.GS4, $09
    db PITCH.F4, $09
    db PITCH.C5, $09
    db PITCH.AS4, $36
    db $ff

music_gameover:
    db PITCH.F4, $09
    db PITCH.C4, $09
    db PITCH.F4, $09
    db PITCH.A4, $24
    db PITCH.F4, $12
    db PITCH.A4, $09
    db PITCH.F4, $09
    db PITCH.A4, $09
    db PITCH.C5, $24
    db PITCH.A4, $12
    db PITCH.C5, $09
    db PITCH.A4, $09
    db PITCH.C5, $09
    db PITCH.E5, $24
    db PITCH.E4, $12
    db PITCH.E4, $12
    db PITCH.E4, $09
    db PITCH.A4, $36
    db $ff

music_perfect:
    db PITCH.C4, $12
    db PITCH.C4, $09
    db PITCH.F4, $2d
    db PITCH.F4, $09
    db PITCH.A4, $1b
    db PITCH.A4, $09
    db PITCH.G4, $09
    db PITCH.F4, $09
    db PITCH.G4, $12
    db PITCH.C5, $09
    db PITCH.C5, $36
    db $ff

music_crash:
    db PITCH.A3, $01
    db PITCH.GS3, $01
    db PITCH.NONE, $01
    db PITCH.A3, $01
    db PITCH.GS3, $01
    db PITCH.NONE, $05
    db PITCH.E4, $04
    db PITCH.NONE, $03
    db PITCH.AS3, $03
    db PITCH.NONE, $03
    db PITCH.GS3, $03
    db PITCH.NONE, $02
    db PITCH.G3, $05
    db $ff

music_explode:
    db PITCH.AS3, $01
    db PITCH.A3, $01
    db PITCH.G3, $01
    db $ff

music_shoot:
    db PITCH.D5, $02
    db PITCH.NONE, $01
    db PITCH.D5, $03
    db PITCH.NONE, $01
    db $ff

music_launch:
    db PITCH.G3, $05
    db PITCH.NONE, $03
    db PITCH.A3, $05
    db PITCH.NONE, $03
    db PITCH.B3, $05
    db PITCH.NONE, $03
    db PITCH.C4, $06
    db PITCH.NONE, $03
    db PITCH.D4, $07
    db PITCH.NONE, $03
    db $ff

music_bounce:
    db PITCH.C5, $05
    db PITCH.CS5, $04
    db PITCH.D5, $03
    db PITCH.DS5, $02
    db PITCH.CS5, $04
    db PITCH.B4, $05
    db PITCH.AS4, $06
    db $ff

music_split:
    db PITCH.C5, $00
    db PITCH.A4, $00
    db PITCH.E5, $00
    db $ff

music_bossgun:
    db PITCH.C4, $04
    db PITCH.B3, $03
    db PITCH.C4, $04
    db PITCH.CS4, $03
    db PITCH.D4, $04
    db PITCH.DS4, $03
    db PITCH.D4, $04
    db PITCH.CS4, $03
    db PITCH.C4, $04
    db PITCH.B3, $03
    db $ff

music_engine:
    db PITCH.GS3, $01
    db PITCH.G3, $01
    db PITCH.NONE, $01
    db $ff

music_bosshit:
    db PITCH.C5, $02
    db PITCH.E5, $01
    db PITCH.NONE, $01

music_haze:
    db PITCH.C5, $02
    db PITCH.E5, $01
    db PITCH.NONE, $01

music_select:
    db PITCH.C5, $02
    db PITCH.E5, $01
    db $ff

init_basic:
    neiw [var_zone], ZONE_MURK
    jr .jr4b9d
    eqiw [$fff0], $00
    jr .jr4ba0
    neiw [var_mode], MODE_PLAYER
.jr4b9d:
    call call4875
.jr4ba0:
    calt ACCCLR
    staw [$fff0]
    staw [$fff1]
    staw [TIME.SEC]
    ldaw [var_zone]
    mov b, a
    clc
    ral
    ral
    add a, b
    lxi hl, data4bcf - 5
    calt ADD_HL_A
    lxi de, $c6ab
    calt ACCCLR
    stax [de+]
    mvi b, $03
.jr4bbd:
    ldax [hl+]
    stax [de+]
    dcr b
    jr .jr4bbd
    ldax [hl]
    neiw [var_level], $02
    jr .jr4bcd
    eqiw [var_zone], ZONE_CITY
    mvi a, $03
    mvi a, $04
.jr4bcd:
    stax [de]
    ret

data4bcf:
    #d $280a0409042800020d052314030e04

call4bde:
    call call489b
    calt ASTRO6
    oni a, $80
    jr .jr4bf0
    lxi hl, $c6be
    ldax [hl]
    inr a
    lti a, $02
    calt ACCCLR
    stax [hl]
    eqi a, $00
.jr4bf0:
    jmp call4cf3
    eqiw [$fff8], $00
    jr .jr4bfb
    call call4cf5
    jr .jr4bfd
.jr4bfb:
    dcrw [$fff8]
.jr4bfd:
    eqiw [var_zone], ZONE_CAVE
    jr .jr4c1e
    eqiw [$fffa], $00
    jr .jr4c09
    call call4d27
    jr .jr4c0b
.jr4c09:
    dcrw [$fffa]
.jr4c0b:
    ltiw [TIME.SEC], $37
    jr .jr4c17
    neiw [var_mode], MODE_PLAYER
    jr .jr4c1e
    gtiw [TIME.SEC], $15
    jr .jr4c1e
.jr4c17:
    mvi a, $04
    staw [$fff9]
    calt ACCCLR
    staw [$fffb]
.jr4c1e:
    lxi hl, $c666
    ldaw [$fff2]
    calt ADD_HL_A
    ldaw [$fff9]
    stax [hl]
    lxi hl, $c640
    ldaw [$fff2]
    calt ADD_HL_A
    ldaw [$fffb]
    stax [hl]
    call call5518

call4c33:
    lxi hl, $c2a3
    calt ACCCLR
    mvi b, $06
.jr4c39:
    mvi c, $4a
.jr4c3b:
    stax [hl+]
    dcr c
    jr .jr4c3b
    dcr b
    jr .jr4c39
    lxi hl, $c465
    shld [$c6a9]
    mvi a, $4a
    staw [$ffe0]
.jr4c4b:
    mvi a, $01
    staw [$ffe1]
    lxi de, $c666
    ldaw [$fff2]
    calt ADD_DE_A
    ldax [de]
    mov c, a
.jr4c57:
    mov a, c
.jr4c58:
    nei a, $00
    jre .jr4c7f
    nei a, $01
    jr .jr4c76
    nei a, $02
    jr .jr4c78
    nei a, $03
    jr .jr4c7a
    nei a, $04
    jr .jr4c7c
    mov b, a
    sui a, $04
    mov b, a
    mvi a, $ff
    stax [hl]
    mvi a, $4b
    call call4a2c
    mov a, b
    jr .jr4c58
.jr4c76:
    mvi a, $c0
.jr4c78:
    mvi a, $f0
.jr4c7a:
    mvi a, $fc
.jr4c7c:
    mvi a, $ff
    stax [hl]
.jr4c7f:
    lhld [$c6a9]
    inx hl
    shld [$c6a9]
    dcrw [$ffe0]
    jr .jr4c8c
    jr .jr4c95
.jr4c8c:
    dcrw [$ffe1]
    jre .jr4c57
    call call5518
    jre .jr4c4b
.jr4c95:
    call call5518
    eqiw [var_zone], ZONE_CAVE
    jre call4cf3
    lxi hl, $c2a3
    shld [$c6a9]
    mvi a, $4a
    staw [$ffe0]
.jr4ca8:
    mvi a, $01
    staw [$ffe1]
    lxi de, $c640
    ldaw [$fff2]
    calt ADD_DE_A
    ldax [de]
    mov c, a
.jr4cb4:
    mov a, c
.jr4cb5:
    nei a, $00
    jre .jr4cda
    nei a, $01
    jr .jr4cd1
    nei a, $02
    jr .jr4cd3
    nei a, $03
    jr .jr4cd5
    nei a, $04
    jr .jr4cd7
    mov b, a
    sui a, $04
    mov b, a
    mvi a, $ff
    stax [hl]
    mvi a, $4b
    calt ADD_HL_A
    mov a, b
    jr .jr4cb5
.jr4cd1:
    mvi a, $03
.jr4cd3:
    mvi a, $0f
.jr4cd5:
    mvi a, $3f
.jr4cd7:
    mvi a, $ff
    stax [hl]
.jr4cda:
    lhld [$c6a9]
    inx hl
    shld [$c6a9]
    dcrw [$ffe0]
    jr .jr4ce7
    jr .jr4cf0
.jr4ce7:
    dcrw [$ffe1]
    jre .jr4cb4
    call call5518
    jre .jr4ca8
.jr4cf0:
    call call5518
    ; fall through

call4cf3:
    calt SCR2COPY
    ret

call4cf5:
    lxi hl, $c69a
    ldax [hl]
    inr a
    lti a, $27
    calt ACCCLR
    stax [hl]
    lxi hl, data4d4e
    calt ADD_HL_A
    ldax [hl]
    staw [$fff9]
    lxi hl, $c69b
    ldax [hl]
    inr a
    lti a, $03
    calt ACCCLR
    stax [hl]
    gti a, $01
    jr .jr4d22
    ltiw [$fff9], $0c
    jr .jr4d20
    calt ASTRO2
    gti a, $55
    jr .jr4d20
    gti a, $aa
    jr .jr4d1e
    mvi a, $0a
.jr4d1e:
    mvi a, $08
.jr4d20:
    mvi a, $04
.jr4d22:
    mvi a, $00
    staw [$fff8]
    ret

call4d27:
    lxi hl, $c69c
    ldax [hl]
    inr a
    ani a, $0f
    stax [hl]
    lxi hl, data4d4e
    calt ADD_HL_A
    ldax [hl]
    staw [$fffb]
    lxi hl, $c69d
    ldax [hl]
    inr a
    ani a, $03
    stax [hl]
    gti a, $02
    jr .jr4d49
    calt ASTRO2
    gti a, $c8
    jr .jr4d47
    mvi a, $04
.jr4d47:
    mvi a, $03
.jr4d49:
    mvi a, $01
    staw [$fffa]
    ret

data4d4e:
    #d $0201

data4d50:
    #d $02030405060708070605040304030405
    #d $060708090a0b0c0e0f0f0e0d0c0b0a09
    #d $0807060504

call4d75:
    calt ASTRO6
    oni a, $80
    jr .jr4d8c
    call call4fe0
    calt ASTRO6
    oni a, $80
    jr .jr4d8c
    call call4dac
    call call4754
    call call4e1d
    call call4e7b
.jr4d8c:
    call call4f6f
    lxi hl, $c6bd
    gtiw [$fff5], $03
    jr .jr4d9a
    mvi a, $00
    stax [hl]
    ret
.jr4d9a:
    gtiw [$fff5], $01
    jr .jr4da5
    ldax [hl]
    inr a
    lti a, $02
    calt ACCCLR
    stax [hl]
    ret
.jr4da5:
    ldax [hl]
    inr a
    lti a, $03
    calt ACCCLR
    stax [hl]
    ret

call4dac:
    call call489b
    mvi a, $11
    staw [$ffe0]
    lxi hl, $c5a4
.jr4db6:
    ldax [hl+]
    oni a, $80
    jre .jr4e15
    ldax [hl]
    gti a, $03
    jr .jr4dc7
    lti a, $06
    jr .jr4dc7
    call call52e1
    jre .jr4e15
.jr4dc7:
    eqi a, $06
    jr .jr4dd1
    inx hl
    ldax [hl]
    adi a, $05
    stax [hl-]
    jre .jr4e15
.jr4dd1:
    eqi a, $07
    jr .jr4de3
    mov a, [$c6be]
    eqi a, $00
    jre .jr4e15
    inx hl
    ldax [hl]
    sui a, $02
    stax [hl-]
    jre .jr4e15
.jr4de3:
    eqi a, $08
    jr .jr4deb
    call call5300
    jre .jr4e15
.jr4deb:
    gti a, $08
    jr .jr4df6
    lti a, $0d
    jr .jr4df6
    call call534a
    jre .jr4e15
.jr4df6:
    eqi a, $0d
    jr .jr4dfd
    call call539f
    jr .jr4e15
.jr4dfd:
    eqi a, $0e
    jr .jr4e04
    call call5435
    jr .jr4e15
.jr4e04:
    eqi a, $0f
    jr .jr4e0b
    call call54cb
    jr .jr4e15
.jr4e0b:
    gti a, $1f
    jr .jr4e15
    lti a, $24
    jr .jr4e15
    call call533b
    jr .jr4e15
.jr4e15:
    inx hl
    inx hl
    inx hl
    dcrw [$ffe0]
    jre .jr4db6
    ret

call4e1d:
    lxi de, $c5a4
    ldax [de]
    oni a, $80
    jr .jr4e3f
    offi a, $40
    jr .jr4e3f
    call call516d
    call try50a9
    jr .jr4e31
    calt ACCCLR
    stax [de]
    jr .jr4e3f
.jr4e31:
    call call523d
    call try495b
    jr .jr4e39
    jr .jr4e3f
.jr4e39:
    mvi a, $c0
    stax [de+]
    mvi a, $22
    stax [de]
.jr4e3f:
    mvi a, $02
    staw [$ffe1]
    lxi de, $c5a8
.jr4e46:
    ldax [de]
    oni a, $80
    jre .jr4e72
    offi a, $40
    jre .jr4e72
    call call517f
    call try50a9
    jr .jr4e59
    calt ACCCLR
    stax [de]
    jr .jr4e72
.jr4e59:
    call call526b
    call try495b
    jr .jr4e6c
    eqiw [var_zone], ZONE_CAVE
    jr .jr4e72
    call call529a
    call try495b
    jr .jr4e6c
    jr .jr4e72
.jr4e6c:
    mvi a, $c0
    stax [de+]
    mvi a, $22
    stax [de-]
.jr4e72:
    inx de
    inx de
    inx de
    inx de
    dcrw [$ffe1]
    jre .jr4e46
    ret

call4e7b:
    calt ASTRO6
    oni a, $80
    ret
    neiw [var_mode], MODE_PLAYER
    jr .jr4e87
    ltiw [TIME.SEC], $13
    ret
.jr4e87:
    ltiw [TIME.SEC], $35
    ret
    neiw [$fff9], $00
    ret
    ldaw [$fffe]
    offi a, $80
    calt ACCCLR
    lxi bc, $c6b0
    ltax [bc]
    jre .jr4f1c
    mov a, [$c6ae]
    lxi bc, $c6ab
    gtax [bc]
    jr .jr4eb2
    mov a, [$c6bd]
    eqi a, $00
    jre .jr4f1c
    ldax [bc]
    inr a
    stax [bc]
    jre .jr4f1c
.jr4eb2:
    calt ASTRO2
    ani a, $7f
    eqiw [var_mode], MODE_PLAYER
    ani a, $3f
    mov d, a
    lxi hl, $c6ac
    ltax [hl+]
    jre .jr4f1c
    gtax [hl]
    jre .jr4f1c
    calt ACCCLR
    stax [bc]
    eqiw [var_zone], ZONE_CAVE
    jre .jr4eff
    mvi a, $02
    call call49cf
    mov a, h
    nei a, $00
    jre .jr4f1c
    mov a, l
    sui a, $b4
    clc
    rar
    clc
    rar
    lxi bc, $c701
    calt ADD_DE_A
    mov a, d
    lti a, $1f
    mvi a, $00
    mvi a, $03
    stax [bc]
    mvi a, $a0
    stax [hl+]
    mvi a, $0e
    stax [hl+]
    mvi a, $48
    stax [hl+]
    mov a, d
    stax [hl+]
    mvi a, $90
    stax [hl]
    inrw [$fffe]
    jr .jr4f1c
.jr4eff:
    mvi a, $01
    call call49cf
    mov a, h
    nei a, $00
    ret
    mov a, d
    lti a, $14
    mvi a, $ac
    mvi a, $a4
    stax [hl+]
    mov a, [$c6af]
    stax [hl+]
    mvi a, $48
    stax [hl+]
    mov a, d
    stax [hl]
    inrw [$fffe]
.jr4f1c:
    mvi a, $03
    call call49cf
    mov a, h
    nei a, $00
    ret
    gtiw [$fff8], $02
    ret
    neiw [$fff9], $00
    ret
    ltiw [$ffff], $04
    jr .jr4f3a
    mov a, [$c6be]
    nei a, $00
    inrw [$ffff]
    ret
.jr4f3a:
    mvi a, $00
    staw [$ffff]
    mvi a, $a0
    stax [hl+]
    calt ASTRO2
    lti a, $64
    mvi a, $07
    mvi a, $08
    gtiw [var_zone], ZONE_CITY
    jr .jr4f53
    eqi a, $08
    jr .jr4f53
    dcx hl
    calt ACCCLR
    stax [hl]
    ret
.jr4f53:
    mov e, a
    stax [hl+]
    mvi a, $4a
    stax [hl+]
    ldaw [$fff9]
    clc
    ral
    mov b, a
    mov a, e
    eqi a, $07
    mvi a, $08
    mvi a, $06
    add a, b
    mov b, a
    mvi a, $40
    sub a, b
    stax [hl]
    ret

call4f6f:
    call call489b
    neiw [var_mode], MODE_PLAYER
    jr .jr4f87
    gtiw [TIME.SEC], $22
    ret
    eqiw [$fff8], $00
    ret
    eqiw [$fff1], $00
    ret
    mvi a, $03
    staw [$fff1]
    ret
.jr4f87:
    call call4a3e
    call call4fbc
    calt ASTRO6
    oni a, $80
    jr .jr4f9d
    gtiw [TIME.SEC], $45
    ret
    mvi a, $01
    staw [$fff1]
    staw [$fff0]
    ret
    ret
.jr4f9d:
    lxi hl, $c5ed
    ldax [hl]
    inr a
    lti a, $1f
    jr .jr4fa7
    stax [hl]
    ret
.jr4fa7:
    mvi a, $01
    staw [$fff1]
    ldaw [var_lives]
    dcr a
    jr .jr4fb1
    mvi a, $00
.jr4fb1:
    staw [var_lives]
    eqi a, $00
    mvi a, $00
    mvi a, $02
    staw [$fff0]
    ret

call4fbc:
    ldaw [$ffa1]
    nei a, $00
    jr .jr4fc5
    nei a, $50
    jr .jr4fc5
    ret
.jr4fc5:
    lxi hl, $c6b4
    neax [hl]
    ret
    stax [hl]
    ldaw [var_level]
    eqi a, $01
    mvi a, $04
    mvi a, $06
    mov b, a
    ldaw [var_lives]
    inr a
    lta a, b
    mov a, b
    staw [var_lives]
    jmp call489b

call4fe0:
    eqiw [var_mode], MODE_PLAYER
    ret
    mvi a, $0d
    staw [$ffe0]
    lxi hl, var_bomber_x
    ldax [hl+]
    adi a, $04
    staw [$ffd6]
    adi a, $06
    staw [$ffda]
    ldax [hl]
    staw [$ffd7]
    adi a, $02
    staw [$ffd9]
    lxi hl, $c5b4
.jr4ffe:
    ldax [hl+]
    oni a, $80
    jre .jr507c
    offi a, $10
    jre .jr507c
    ldax [hl]
    eqi a, $07
    jr .jr5016
    calt ASTRO3
    call try495b
    jr .jr5012
    jre .jr507c
.jr5012:
    mvi a, $19
    jre .jr5084
.jr5016:
    eqi a, $08
    jr .jr502a
    calt ASTRO3
    call try495b
    jr .jr5020
    jre .jr507c
.jr5020:
    dcx hl
    ldax [hl+]
    oni a, $08
    mvi a, $30
    mvi a, $60
    jre .jr5084
.jr502a:
    gti a, $08
    jre .jr5057
    lti a, $0d
    jre .jr5057
    dcx hl
    ldax [hl+]
    offi a, $40
    jre .jr507c
    ldax [hl]
    calt ASTRO3
    call try495b
    jr .jr5040
    jre .jr507c
.jr5040:
    ldaw [var_energy]
    sui a, $0a
    offi a, $80
    calt ACCCLR
    staw [var_energy]
    push hl
    lxi hl, music_haze
    calt MUSPLAY
    pop hl
    dcx hl
    mvi a, $c0
    stax [hl+]
    jre .jr507c
.jr5057:
    eqi a, $0d
    jr .jr5064
    calt ASTRO3
    call try495b
    jr .jr5060
    jr .jr507c
.jr5060:
    mvi a, $40
    jre .jr5084
.jr5064:
    eqi a, $0e
    jr .jr5070
    calt ASTRO3
    call try495b
    jr .jr506d
    jr .jr507c
.jr506d:
    mvi a, $80
    jr .jr5084
.jr5070:
    eqi a, $0f
    jr .jr507c
    calt ASTRO3
    call try495b
    jr .jr5079
    jr .jr507c
.jr5079:
    mvi a, $40
    jr .jr5084
.jr507c:
    inx hl
    inx hl
    inx hl
    dcrw [$ffe0]
    jre .jr4ffe
    jr .jr5092
.jr5084:
    call call4a59
    dcx hl
    calt ACCCLR
    stax [hl]
.jr508a:
    call call52c6
    lxi hl, music_crash
    calt MUSPLAY
    ret
.jr5092:
    mvi a, $01
    call call51e5
    call try495b
    jr .jr508a
    eqiw [var_zone], ZONE_CAVE
    ret
    mvi a, $02
    call call51e5
    call try495b
    jr .jr508a
    ret

try50a9:
    mvi a, $0d
    staw [$ffe0]
    lxi hl, $c5b4
.jr50b0:
    ldax [hl+]
    oni a, $80
    jre .jr5152
    offi a, $10
    jre .jr5152
    ldax [hl]
    eqi a, $07
    jr .jr50d2
    calt ASTRO3
    call try495b
    jr .jr50c4
    jre .jr5152
.jr50c4:
    ldaw [var_energy]
    adi a, $03
    lti a, $1e
    mvi a, $1e
    staw [var_energy]
    mvi a, $19
    jre .jr515a
.jr50d2:
    eqi a, $08
    jr .jr50e6
    calt ASTRO3
    call try495b
    jr .jr50dc
    jre .jr5152
.jr50dc:
    dcx hl
    ldax [hl+]
    oni a, $08
    mvi a, $30
    mvi a, $60
    jre .jr515a
.jr50e6:
    eqi a, $0d
    jr .jr50f7
    calt ASTRO3
    call try495b
    jr .jr50f0
    jre .jr5152
.jr50f0:
    dcrw [$fffe]
    nop
    mvi a, $40
    jre .jr515a
.jr50f7:
    eqi a, $0e
    jre .jr5146
    calt ASTRO3
    call try495b
    jr .jr5102
    jre .jr5152
.jr5102:
    dcx hl
    mov a, l
    sui a, $b4
    clc
    rar
    clc
    rar
    lxi bc, $c701
    call call46ab
    calt ACCCLR
    stax [bc]
    mvi a, $03
    inx bc
    stax [bc]
    mvi a, $a5
    stax [hl+]
    mvi a, $0f
    stax [hl+]
    ldax [hl+]
    mov b, a
    ldax [hl]
    mov c, a
    sui a, $01
    stax [hl+]
    mvi a, $ad
    stax [hl+]
    mvi a, $0f
    stax [hl+]
    mov a, b
    stax [hl+]
    mov a, c
    adi a, $0a
    stax [hl-]
    push hl
    lxi hl, music_split
    calt MUSPLAY
    pop hl
    mvi a, $80
    call call4a59
    calt ACCCLR
    stax [de]
    dcrw [$fffe]
    nop
    rets
.jr5146:
    eqi a, $0f
    jr .jr5152
    calt ASTRO3
    call try495b
    jr .jr514f
    jr .jr5152
.jr514f:
    mvi a, $40
    jr .jr515a
.jr5152:
    inx hl
    inx hl
    inx hl
    dcrw [$ffe0]
    jre .jr50b0
    ret
.jr515a:
    call call4a59
    push hl
    lxi hl, music_explode
    calt MUSPLAY
    pop hl
    dcx hl
    mvi a, $c0
    stax [hl+]
    mvi a, $20
    stax [hl]
    rets

call516d:
    lxi hl, $c5a6
    ldax [hl+]
    staw [$ffd6]
    adi a, $02
    staw [$ffda]
    ldax [hl]
    staw [$ffd7]
    adi a, $02
    staw [$ffd9]
    ret

call517f:
    inx de
    inx de
    ldax [de+]
    sui a, $02
    staw [$ffd6]
    adi a, $04
    staw [$ffda]
    ldax [de-]
    staw [$ffd7]
    staw [$ffd9]
    dcx de
    dcx de
    ret

astro3:
    sui a, $07
    clc
    ral
    push de
    lxi de, data51c1
    calt ADD_DE_A
    ldax [de+]
    mov b, a
    inx hl
    ldax [hl+]
    mov c, a
    add a, b
    staw [$ffd0]
    ldax [de]
    add a, c
    staw [$ffd4]
    mvi a, $11
    calt ADD_DE_A
    ldax [de+]
    mov b, a
    ldax [hl]
    mov c, a
    add a, b
    staw [$ffd1]
    ldax [de]
    add a, c
    staw [$ffd3]
    pop de
    dcx hl
    dcx hl
    ret

data51c1:
    #d $01060105020b030a0409050800060004
    #d $00020005000700060005010502040006
    #d $00080004

call51e5:
    eqi a, $02
    lxi hl, $c666
    lxi hl, $c640
    shld [$c6a9]
    push va
    calt GET_BOMBER_X
    adi a, $04
    staw [$ffd0]
    mov b, a
    adi a, $06
    staw [$ffd4]
    mov a, b
    clc
    rar
    mov b, a
    mvi d, $00
    ldaw [$fff2]
    add a, b
    mov b, a
    mvi c, $02
.jr520c:
    lti a, $26
    sui a, $26
    lhld [$c6a9]
    calt ADD_HL_A
    ldax [hl]
    lta a, d
    mov d, a
    inr b
    mov a, b
    dcr c
    jr .jr520c
    mov a, d
    clc
    ral
    mov b, a
    pop va
    eqi a, $01
    jr .jr5233
    mvi a, $40
    sub a, b
    staw [$ffd1]
    mvi a, $3f
    staw [$ffd3]
    ret
.jr5233:
    mov a, b
    adi a, $07
    staw [$ffd3]
    mvi a, $08
    staw [$ffd1]
    ret

call523d:
    mov a, [$c5a6]
    staw [$ffd0]
    mov b, a
    adi a, $02
    staw [$ffd4]
    mov a, b
    clc
    rar
    mov b, a
    ldaw [$fff2]
    add a, b
    lti a, $26
    sui a, $26
    lxi hl, $c666
    calt ADD_HL_A
    ldax [hl]
    clc
    ral
    mov b, a
    mvi a, $3f
    sub a, b
    staw [$ffd1]
    mvi a, $3f
    staw [$ffd3]
    ret

call526b:
    inx de
    inx de
    ldax [de]
    staw [$ffd0]
    mov b, a
    adi a, $02
    staw [$ffd4]
    mov a, b
    clc
    rar
    mov b, a
    ldaw [$fff2]
    add a, b
    lti a, $26
    sui a, $26
    lxi hl, $c666
    calt ADD_HL_A
    ldax [hl]
    clc
    ral
    mov b, a
    mvi a, $40
    sub a, b
    staw [$ffd1]
    mvi a, $3f
    staw [$ffd3]
    dcx de
    dcx de
    ret

call529a:
    inx de
    inx de
    ldax [de]
    staw [$ffd0]
    mov b, a
    adi a, $02
    staw [$ffd4]
    mov a, b
    clc
    rar
    mov b, a
    ldaw [$fff2]
    add a, b
    lti a, $26
    sui a, $26
    lxi hl, $c640
    calt ADD_HL_A
    ldax [hl]
    clc
    ral
    adi a, $07
    staw [$ffd3]
    mvi a, $08
    staw [$ffd1]
    dcx de
    dcx de
    ret

call52c6:
    calt ASTRO5
    mvi a, $00
    stax [hl+]
    inx hl
    ldax [hl+]
    mov b, a
    ldax [hl]
    mov c, a
    lxi hl, $c5ec
    mvi a, $c1
    stax [hl+]
    mvi a, $15
    stax [hl+]
    mov a, b
    adi a, $04
    stax [hl+]
    mov a, c
    sui a, $02
    stax [hl]
    ret

call52e1:
    dcx hl
    ldax [hl]
    oni a, $20
    jr .jr52f3
    xri a, $20
    stax [hl+]
    inx hl
    ldax [hl]
    inr a
    stax [hl+]
    ldax [hl]
    adi a, $02
    stax [hl-]
    dcx hl
    ret
.jr52f3:
    inx hl
    mvi a, $05
    stax [hl+]
    ldax [hl]
    inr a
    stax [hl+]
    ldax [hl]
    adi a, $03
    stax [hl-]
    dcx hl
    ret

call5300:
    mov a, [$c6be]
    eqi a, $00
    ret
    inx hl
    ldax [hl]
    sui a, $02
    stax [hl-]
    mov b, a
    dcx hl
    ldax [hl+]
    offi a, $08
    jr .jr532b
    mov a, b
    lti a, $37
    ret
    calt ASTRO2
    lti a, $c8
    jr .jr531e
    mov a, b
    lti a, $19
    ret
.jr531e:
    push hl
    lxi hl, music_launch
    calt MUSPLAY
    pop hl
    dcx hl
    mvi a, $88
    stax [hl+]
    ret
.jr532b:
    inx hl
    inx hl
    eqiw [var_level], $02
    mvi a, $04
    mvi a, $05
    mov b, a
    ldax [hl]
    sub a, b
    stax [hl-]
    dcx hl
    ret

call533b:
    ldax [hl]
    inr a
    lti a, $24
    jr .jr5346
    stax [hl+]
    ldax [hl]
    sui a, $02
    stax [hl-]
    ret
.jr5346:
    dcx hl
    calt ACCCLR
    stax [hl+]
    ret

call534a:
    dcx hl
    ldax [hl]
    mov b, a
    oni a, $40
    jre .jr5382
    lxi de, $c6b5
    mvi c, $03
    mov a, l
.jr5357:
    neax [de+]
    jr .jr535e
    inx de
    dcr c
    jr .jr5357
    jr .jr536f
.jr535e:
    ldax [de-]
    eqi a, $00
    jr .jr5367
    stax [hl+]
    stax [de]
    dcrw [$fffe]
    ret
.jr5367:
    inx de
    dcr a
    stax [de]
    ldax [hl]
    xri a, $10
    stax [hl]
    jr .jr5382
.jr536f:
    mvi c, $03
    lxi de, $c6b5
.jr5374:
    ldax [de]
    nei a, $00
    jr .jr537d
    inx de
    inx de
    dcr c
    jr .jr5374
    jr .jr5382
.jr537d:
    mov a, l
    stax [de+]
    mvi a, $06
    stax [de]
.jr5382:
    inx hl
    ldax [hl]
    call call46ea
    stax [hl-]
    mov a, b
    stax [hl+]
    mov a, [$c6bd]
    eqi a, $00
    ret
    inx hl
    oniw [$fff5], $01
    mvi a, $04
    mvi a, $05
    mov b, a
    ldax [hl]
    sub a, b
    stax [hl-]
    ret

call539f:
    mov a, [$c6bd]
    eqi a, $00
    ret
    inx hl
    oniw [$fff5], $01
    mvi a, $04
    mvi a, $05
    mov b, a
    ldax [hl]
    sub a, b
    stax [hl-]
    dcx hl
    ldax [hl+]
    inx hl
    inx hl
    oni a, $08
    jre .jr53e1
    oniw [$fff5], $01
    mvi a, $06
    mvi a, $07
    mov b, a
    ldax [hl]
    sub a, b
    stax [hl-]
    lti a, $0a
    jr .jr53d0
    dcx hl
    dcx hl
    mvi a, $80
    stax [hl+]
    ret
.jr53d0:
    lti a, $19
    jr .jr53df
    call $00e0
    lti a, $6e
    jr .jr53df
    dcx hl
    dcx hl
    mvi a, $80
    stax [hl+]
    ret
.jr53df:
    dcx hl
    ret
.jr53e1:
    ldax [hl]
    adi a, $05
    stax [hl-]
    dcx hl
    mvi a, $0d
    calt ASTRO3
    inx hl
    ldax [hl-]
    staw [$ffd6]
    mov b, a
    adi a, $02
    staw [$ffda]
    mov a, b
    clc
    rar
    mov b, a
    ldaw [$fff2]
    add a, b
    lti a, $26
    sui a, $26
    lxi de, $c666
    calt ADD_DE_A
    ldax [de+]
    mov b, a
    ldax [de]
    gta a, b
    mov a, b
    clc
    ral
    mov b, a
    mvi a, $3f
    sub a, b
    staw [$ffdc]
    staw [$ffd7]
    mvi a, $3f
    staw [$ffd9]
    call try495b
    jr .jr5420
    ret
.jr5420:
    push hl
    lxi hl, music_bounce
    calt MUSPLAY
    pop hl
    dcx hl
    mvi a, $88
    stax [hl+]
    inx hl
    inx hl
    ldaw [$ffdc]
    sui a, $06
    stax [hl-]
    dcx hl
    ret

call5435:
    mov a, [$c6bd]
    eqi a, $00
    jre .jr54b9
    dcx hl
    mov a, l
    inx hl
    sui a, $b4
    clc
    rar
    clc
    rar
    lxi de, $c701
    calt ADD_DE_A
    ldax [de]
    mov b, a
    inr a
    lti a, $06
    calt ACCCLR
    stax [de]
    oniw [$fff5], $01
    mvi a, $02
    mvi a, $03
    mov c, a
    inx hl
    ldax [hl]
    sub a, c
    stax [hl+]
    mov c, a
    oniw [$fff5], $01
    mvi a, $00
    mvi a, $06
    lxi de, data54bf
    calt ADD_DE_A
    mov a, b
    calt ADD_DE_A
    ldax [de]
    mov b, a
    ldax [hl]
    add a, b
    stax [hl-]
    ldax [hl-]
    lti a, $23
    jre .jr54b9
    dcrw [$fffe]
    nop
    dcx hl
    mov a, l
    sui a, $b4
    clc
    rar
    clc
    rar
    lxi bc, $c701
    call call46ab
    calt ACCCLR
    stax [bc]
    inx bc
    mvi a, $01
    stax [bc]
    mvi a, $a5
    stax [hl+]
    mvi a, $0f
    stax [hl+]
    ldax [hl+]
    mov b, a
    ldax [hl]
    mov c, a
    sui a, $03
    stax [hl+]
    mvi a, $ad
    stax [hl+]
    mvi a, $0f
    stax [hl+]
    mov a, b
    stax [hl+]
    mov a, c
    adi a, $0a
    stax [hl-]
    dcx hl
    push hl
    lxi hl, music_split
    calt MUSPLAY
    pop hl
    ret
.jr54b9:
    mvi a, $04
    calt ADD_HL_A
    dcrw [$ffe0]
    ret

data54bf:
    #d $ffffff
    #d $010101
    #d $fefefe
    #d $020202

call54cb:
    mov a, [$c6bd]
    eqi a, $00
    ret
    dcx hl
    mov a, l
    inx hl
    sui a, $b4
    clc
    rar
    clc
    rar
    lxi de, $c701
    calt ADD_DE_A
    ldax [de]
    mov c, a
    inr a
    lti a, $06
    calt ACCCLR
    stax [de]
    oniw [$fff5], $01
    mvi a, $04
    mvi a, $05
    mov b, a
    inx hl
    ldax [hl]
    sub a, b
    stax [hl+]
    oniw [$fff5], $01
    mvi a, $00
    mvi a, $06
    lxi de, data550c
    calt ADD_DE_A
    mov a, c
    calt ADD_DE_A
    ldax [de]
    mov b, a
    ldax [hl]
    add a, b
    stax [hl-]
    dcx hl
    ret

data550c:
    #d $ffffff
    #d $010101
    #d $fefefe
    #d $020202

call5518:
    ldaw [$fff2]
    inr a
    lti a, $26
    calt ACCCLR
    staw [$fff2]
    ret

init_maze:
    calt ACCCLR
    staw [$fff1]
    staw [$fff0]
    staw [TIME.SEC]
    mov [$c69e], a
    staw [$ffdd]
    mvi a, $0a
    mov [$c69f], a
    lxi hl, $c4b0
    mvi b, $0b
    mvi a, $40
    calt MEMSET
    mvi a, $02
    ltiw [$fff5], $03
    mvi a, $01
    neiw [var_mode], MODE_ATTRACT
    mvi a, $01
    mov [$c6d1], a
    calt ACCCLR
    mov [$c6e7], a
    ret

call5552:
    call call489b
    calt ASTRO6
    oni a, $80
    jre .jr55cb
    inrw [$ffdd]
    mov b, [$c6d1]
    ldaw [$ffdd]
    eqa a, b
    jre .jr55cb
    aniw [$ffdd], $00
    mov a, [$c69e]
    eqi a, $03
    jre .jr55c5
    mov a, [$c69f]
    eqi a, $0a
    jr .jr5584
    calt ASTRO2
    ani a, $07
    mov [$c6f3], a
    calt ACCCLR
    mov [$c69f], a
.jr5584:
    mov a, [$c69f]
    inr a
    mov [$c69f], a
    calt ACCCLR
    mov [$c69e], a
    mvi a, $0a
    mov e, [$c6f3]
    calt MULTIPLY
    mov a, [$c69f]
    add a, l
    lxi hl, data5faa
    calt ADD_HL_A
    push hl
    lxi hl, $c4b1
    lxi de, $c4b0
    mvi b, $0b
    calt MEMCOPY
    pop hl
    ldax [hl]
    eqiw [$fff0], $00
    calt ACCCLR
    mov [$c4bb], a
    calt ACCCLR
    mov [$c69e], a
    neiw [$fff0], $00
    call call5ac1
    jr .jr55cb
.jr55c5:
    lxi hl, $c69e
    ldax [hl]
    inr a
    stax [hl]
.jr55cb:
    calt SCR1CLR
    jmp call5a34

call55cf:
    call call489b
    calt ASTRO6
    oni a, $80
    jmp .jr56e7
    call call5f71
    neiw [$ffdd], $00
    call call5b19
    call call4754
    calt GET_BOMBER_Y
    eqi a, $3a
    jr .jr55f3
    mvi b, $00
    call call4857
    mvi a, $37
    mov [$c5ef], a
.jr55f3:
    call call489b
    mvi a, $01
    mov [$c6cb], a
.jr55fc:
    calt ASTRO9
    calt ASTRO4
    ldax [hl+]
    oni a, $80
    jre .jr5652
    ldax [hl+]
    nei a, $04
    jr .jr560e
    nei a, $05
    jr .jr560e
    eqi a, $06
    jre .jr5652
.jr560e:
    ldax [hl+]
    mov d, a
    ldax [hl]
    mov e, a
    push de
    call call5afb
    jmp call5b5a
    pop de
    mov a, d
    staw [$ffd6]
    adi a, $02
    staw [$ffda]
    mov a, e
    staw [$ffd7]
    staw [$ffd9]
    mvi a, $05
    staw [$ffdc]
.jr562c:
    ldaw [$ffdc]
    calt ASTRO4
    ldax [hl+]
    oni a, $80
    jr .jr564b
    ldax [hl+]
    eqi a, $07
    jr .jr564b
    ldax [hl+]
    staw [$ffd0]
    adi a, $06
    staw [$ffd4]
    ldax [hl]
    staw [$ffd1]
    adi a, $05
    staw [$ffd3]
    call try497f
    call call5b3b
.jr564b:
    inrw [$ffdc]
    eqiw [$ffdc], $13
    jre .jr562c
.jr5652:
    calt ASTRO9
    inr a
    mov [$c6cb], a
    eqi a, $05
    jre .jr55fc
    mov a, [var_bomber_x]
    adi a, $06
    mov b, a
    adi a, $05
    mov d, a
    mov a, [var_bomber_y]
    mov c, a
    adi a, $02
    mov e, a
    call call5f0b
    call call4857
    calt GET_BOMBER_X
    adi a, $04
    staw [$ffd0]
    adi a, $06
    staw [$ffd4]
    calt GET_BOMBER_Y
    staw [$ffd1]
    adi a, $02
    staw [$ffd3]
    mvi a, $05
    staw [$ffdc]
.jr5688:
    ldaw [$ffdc]
    calt ASTRO4
    ldax [hl+]
    oni a, $80
    jr .jr56a7
    ldax [hl+]
    eqi a, $07
    jr .jr56a7
    ldax [hl+]
    staw [$ffd6]
    adi a, $06
    staw [$ffda]
    ldax [hl]
    staw [$ffd7]
    adi a, $05
    staw [$ffd9]
    call try495b
    call call484a
.jr56a7:
    inrw [$ffdc]
    eqiw [$ffdc], $13
    jre .jr5688
    call call4a3e
    neiw [var_mode], MODE_PLAYER
    jr .jr56c6
    gtiw [TIME.SEC], $14
    jre .jr56e3
    mvi a, $01
    staw [$fff0]
    gtiw [TIME.SEC], $1e
    jr .jr56c6
    mvi a, $03
    staw [$fff1]
.jr56c6:
    gtiw [TIME.SEC], $3c
    jr .jr56e3
    oriw [$fff0], $01
    mov a, [$c6d1]
    eqi a, $02
    jr .jr56dc
    gtiw [TIME.SEC], $50
    jr .jr56e3
    oriw [$fff1], $01
    jr .jr56e3
.jr56dc:
    gtiw [TIME.SEC], $46
    jr .jr56e3
    oriw [$fff1], $01
.jr56e3:
    call call4fbc
    ret
.jr56e7:
    mov a, [$c5ed]
    nei a, $1e
    jr .jr56f4
    inr a
    mov [$c5ed], a
    jr .jr5702
.jr56f4:
    mvi a, $00
    dcrw [var_lives]
    neiw [var_lives], $00
    mvi a, $02
    staw [$fff0]
    oriw [$fff1], $01
.jr5702:
    ret

init_boss:
    calt ACCCLR
    staw [$fff0]
    staw [$fff1]
    staw [TIME.SEC]
    mov [$c6eb], a
    mov [$c6ed], a
    mov [$c6e5], a
    mov [$c6ec], a
    mov [$c6e8], a
    lxi hl, $c5b4
    mvi a, $88
    stax [hl+]
    mvi a, $11
    stax [hl+]
    mvi a, $40
    stax [hl+]
    mvi a, $12
    stax [hl]
    mov a, [$c6e7]
    nei a, $00
    mov [$c6f0], a
    lxi hl, $c3c0
    calt ACCCLR
    mvi b, $ef
    calt MEMSET
    lxi hl, $c70f
    mvi b, $08
    calt MEMSET
    ldaw [$fff5]
    clc
    rar
    nei a, $00
    jr .jr5754
    nei a, $01
    jr .jr5752
    mvi a, $12
.jr5752:
    mvi a, $24
.jr5754:
    mvi a, $32
    mov [$c6d7], a
    mov a, [$c6e7]
    nei a, $00
    jr .jr5771
    mov b, [$c698]
    mvi a, $3c
    sub a, b
    staw [TIME.SEC]
    adi a, $02
    mov [$c6a8], a
.jr5771:
    mvi a, $01
    mov [$c6e7], a
    ret

call5778:
    call call489b
    call call5e50
    mov a, [$c6d2]
    eqi a, $00
    dcr a
    mov [$c6d2], a
    ret

call578a:
    call call489b
    calt ASTRO6
    oni a, $80
    jmp .jr5a0a
    neiw [$fff0], $01
    jr .jr57a6
    calt ASTRO2
    ani a, $61
    eqi a, $61
    jr .jr57a6
    mov a, [$c6d2]
    nei a, $00
    call call5b63
.jr57a6:
    call call5c8c
    call call5c8c
    call call5c8c
    call call5ba1
    call call5f71
    call call5d22
    call call4754
    calt GET_BOMBER_Y
    eqi a, $3a
    jr .jr57ca
    mvi b, $00
    call call4857
    mvi a, $37
    mov [$c5ef], a
.jr57ca:
    lxi hl, $c5a7
    ldax [hl]
    gti a, $38
    jr .jr57d8
    mvi a, $38
    stax [hl-]
    dcx hl
    mvi a, $22
    stax [hl]
.jr57d8:
    call call489b
    mvi a, $01
    mov [$c6cb], a
.jr57e1:
    mvi a, $07
    staw [$ffdc]
    calt ASTRO9
    calt ASTRO4
    ldax [hl+]
    oni a, $80
    jre .jr5893
    inx hl
    ldax [hl+]
    dcr a
    staw [$ffd0]
    adi a, $03
    staw [$ffd4]
    ldax [hl-]
    staw [$ffd1]
    staw [$ffd3]
    dcx hl
    ldax [hl]
    eqi a, $05
    jr .jr5805
    ldaw [$ffd3]
    adi a, $02
    staw [$ffd3]
.jr5805:
    ldaw [$ffdc]
    calt ASTRO4
    ldax [hl+]
    oni a, $80
    jre .jr588c
    ldax [hl+]
    nei a, $07
    jr .jr5819
    nei a, $10
    jr .jr581d
    nei a, $1f
    jr .jr5821
    jre .jr588c
.jr5819:
    lxi de, $0605
    jr .jr5826
.jr581d:
    lxi de, $0502
    jr .jr5828
.jr5821:
    lxi de, $0e02
    mvi a, $00
.jr5826:
    mvi a, $19
.jr5828:
    mvi a, $80
    mov [$c6f9], a
    ldax [hl+]
    staw [$ffd6]
    add a, d
    staw [$ffda]
    ldax [hl]
    staw [$ffd7]
    add a, e
    staw [$ffd9]
    call try495b
    jr .jr5842
    jre .jr588c
.jr5842:
    ldaw [$ffdc]
    calt ASTRO4
    inx hl
    ldax [hl]
    eqi a, $1f
    jr .jr585e
    calt ASTRO9
    calt ASTRO4
    inx hl
    mvi a, $22
    stax [hl+]
    mvi a, $12
    staw [$ffdc]
    inx hl
    mvi a, $2d
    stax [hl]
    lxi hl, music_explode
    calt MUSPLAY
    jre .jr588c
.jr585e:
    mvi a, $20
    stax [hl]
    calt ASTRO9
    calt ASTRO4
    calt ACCCLR
    stax [hl]
    mov a, [$c6f9]
    call call4a59
    mov a, [$c6f9]
    eqi a, $19
    jr .jr5882
    ldaw [var_energy]
    adi a, $03
    lti a, $1f
    mvi a, $1e
    staw [var_energy]
    lxi hl, music_explode
    calt MUSPLAY
    jr .jr588c
.jr5882:
    mvi a, $20
    stax [hl]
    ldaw [$ffdc]
    sui a, $07
    call call5d5d
.jr588c:
    inrw [$ffdc]
    eqiw [$ffdc], $13
    jre .jr5805
.jr5893:
    lxi hl, $c6cb
    ldax [hl]
    inr a
    stax [hl]
    eqi a, $05
    jre .jr57e1
    mov a, [$c5b6]
    staw [$ffd0]
    adi a, $08
    staw [$ffd4]
    mov a, [$c5b7]
    staw [$ffd1]
    adi a, $0e
    staw [$ffd3]
    mvi a, $02
    mov [$c6cb], a
.jr58b7:
    calt ASTRO9
    calt ASTRO4
    ldax [hl+]
    oni a, $80
    jr .jr58cb
    ldax [hl+]
    eqi a, $06
    jr .jr58cb
    ldax [hl+]
    mov d, a
    ldax [hl]
    mov e, a
    call try497f
    call call5d9c
.jr58cb:
    lxi hl, $c6cb
    ldax [hl]
    inr a
    stax [hl]
    eqi a, $05
    jr .jr58b7
    calt GET_BOMBER_X
    adi a, $05
    staw [$ffd0]
    adi a, $05
    staw [$ffd4]
    calt GET_BOMBER_Y
    staw [$ffd1]
    adi a, $02
    staw [$ffd3]
    mvi a, $07
    staw [$ffdc]
.jr58e8:
    ldaw [$ffdc]
    calt ASTRO4
    ldax [hl+]
    oni a, $80
    jre .jr591b
    ldax [hl+]
    nei a, $10
    jr .jr58fc
    nei a, $07
    jr .jr5900
    nei a, $1f
    jr .jr5904
    jre .jr591b
.jr58fc:
    lxi de, $0502
    jr .jr5907
.jr5900:
    lxi de, $0605
    jr .jr5907
.jr5904:
    lxi de, $0e02
.jr5907:
    ldax [hl+]
    staw [$ffd6]
    add a, d
    staw [$ffda]
    ldax [hl]
    staw [$ffd7]
    add a, e
    staw [$ffd9]
    call try495b
    call call484a
.jr591b:
    inrw [$ffdc]
    eqiw [$ffdc], $13
    jre .jr58e8
    call call5e5a
    call call4857
    call call4a3e
    ldaw [TIME.SEC]
    mov b, a
    mvi a, $3c
    sub a, b
    offi a, $80
    calt ACCCLR
    mov [$c698], a
    neiw [var_mode], MODE_PLAYER
    jr .jr5952
    gtiw [TIME.SEC], $14
    jre .jr5962
    oriw [$fff0], $01
    gtiw [TIME.SEC], $1e
    jr .jr5962
    calt ACCCLR
    mov [$c6ec], a
    mvi a, $03
    staw [$fff1]
.jr5952:
    gtiw [TIME.SEC], $3c
    jr .jr595f
    oriw [$fff0], $01
    gtiw [TIME.SEC], $44
    jr .jr595f
    jre .jr5997
.jr595f:
    call call4fbc
.jr5962:
    mov a, [$c6f0]
    eqi a, $05
    jre .jr5a30
    calt ASTRO6
    offi a, $80
    jr .jr5981
    lxi hl, $c5a0
    lxi de, $c5ec
    calt ACCCLR
    stax [de+]
    inx de
    mvi a, $80
    stax [hl+]
    mvi a, $01
    stax [hl+]
    ldax [de+]
    stax [hl+]
    ldax [de]
    stax [hl]
.jr5981:
    calt ACCCLR
    lxi hl, $c5a4
    mvi b, $0f
    calt MEMSET
    lxi hl, $c5bc
    mvi b, $2f
    calt MEMSET
    mvi a, $01
    mov [$c6e8], a
    call call5dc9
.jr5997:
    mvi a, $01
    staw [$fff1]
    staw [$fff0]
    staw [var_mode]
    calt ACCCLR
    mov [$c6ec], a
    oriw [var_mode], MODE_ATTRACT
    lxi hl, music_fanfare
    calt MUSPLAY
.jr59ab:
    offiw [$ff80], $07
    jr .jr59ab
    aniw [TIME.SEC], $00
    lxi hl, $c5a4
    calt ACCCLR
    mvi b, $4b
    calt MEMSET
    mvi a, $90
    mov [$c5a0], a
    calt SCR1CLR
    lxi hl, .str_bonus
    calt DRAWTEXT
    db $05, $1b, TEXT.SCR1 | TEXT.SPC1 | .str_bonus.len
    lxi hl, $c6fb
    calt DRAWHEX
    db $2d, $1b, TEXT.SCR1 | TEXT.SPC1 | 2
    lxi hl, .str_zero
    calt DRAWTEXT
    db $3f, $1b, TEXT.SCR1 | TEXT.SPC1 | .str_zero.len
    call update_screen
.jr59d8:
    eqiw [TIME.SEC], $03
    jr .jr59d8
    mov a, [$c698]
.jr59e0:
    nei a, $00
    jr .jr59f1
    dcr a
    push va
    lxi hl, $0100
    calt ARITHMTC
    db ARITH.BCD | ARITH.HL3 | ARITH.HLW | ARITH.DE2 | ARITH.DEW
    call call4fbc
    pop va
    jr .jr59e0
.jr59f1:
    calt SCR1CLR
    mvi a, $80
    mov [$c5a0], a
    calt ACCCLR
    mov [$c6ec], a
    staw [var_mode]
    mov [$c6e8], a
    ret

.str_bonus:
    #d largetext("BONUS")
..len = $ - .str_bonus

.str_zero:
    #d largetext("0")
..len = $ - .str_zero

.jr5a0a:
    mov a, [$c5ed]
    nei a, $1e
    jr .jr5a17
    inr a
    mov [$c5ed], a
    jr .jr5a30
.jr5a17:
    calt ACCCLR
    dcrw [var_lives]
    neiw [var_lives], $00
    mvi a, $02
    staw [$fff0]
    oriw [$fff1], $01
    calt ACCCLR
    neiw [$fff0], $02
    mov [$c6e7], a
    mov [$c6ec], a
.jr5a30:
    call call5e91
    ret

call5a34:
    mov a, [$c69e]
    clc
    ral
    mov b, a
    calt ACCCLR
    sub a, b
    mov [$c6a0], a
    mvi a, $0b
    mov [$c6a1], a
.jr5a4a:
    mvi a, $07
    mov [$c6a2], a
    mov b, [$c6a1]
    mvi a, $0b
    sub a, b
    lxi hl, $c4b0
    calt ADD_HL_A
    ldax [hl]
    staw [$ffdc]
    nei a, $00
    jre .jr5a92
.jr5a63:
    ldaw [$ffdc]
    rar
    staw [$ffdc]
    sknc
    call call5a9e
    mov a, [$c6a2]
    dcr a
    mov [$c6a2], a
    eqi a, $00
    jr .jr5a63
    mov a, [$c6a0]
    adi a, $08
    mov [$c6a0], a
    mov a, [$c6a1]
    dcr a
    mov [$c6a1], a
    eqi a, $00
    jre .jr5a4a
    ret
.jr5a92:
    lxi hl, $c20d
    mvi b, $4a
.jr5a97:
    ldax [hl]
    ori a, $f0
    stax [hl+]
    dcr b
    jr .jr5a97
    ret

call5a9e:
    mov b, [$c6a2]
    mvi a, $08
    sub a, b
    clc
    ral
    clc
    ral
    clc
    ral
    staw [$ffd3]
    mov a, [$c6a0]
    staw [$ffd2]
    mvi a, $24
    staw [$ffd1]
    jmp call4424

call5ac1:
    calt ASTRO2
    oni a, $80
    jr .jr5ad4
    mov a, [$c4b9]
    offi a, $02
    ret
    oni a, $04
    ret
    mvi a, $12
    push va
    jr .jr5ae2
.jr5ad4:
    mov a, [$c4b9]
    offi a, $20
    ret
    oni a, $40
    ret
    mvi a, $32
    push va
.jr5ae2:
    mvi a, $01
    call call49cf
    mov a, h
    nei a, $00
    jr .jr5af8
    mvi a, $80
    stax [hl+]
    mvi a, $07
    stax [hl+]
    mvi a, $4a
    stax [hl+]
    pop va
    stax [hl]
    ret
.jr5af8:
    pop va
    ret

call5afb:
    push de
    calt ASTRO9
    eqi a, $01
    jr .jr5b07
    pop de
    mov a, e
    adi a, $02
    jr .jr5b11
.jr5b07:
    mov a, d
    sui a, $03
    mov d, a
    call call5ed2
    jr .jr5b16
    pop de
.jr5b11:
    call call5ed2
    jr .jr5b18
    rets
.jr5b16:
    pop de
.jr5b18:
    ret

call5b19:
    mvi a, $05
    staw [$ffdc]
.jr5b1d:
    ldaw [$ffdc]
    calt ASTRO4
    ldax [hl+]
    oni a, $80
    jr .jr5b34
    ldax [hl]
    nei a, $07
    jr .jr5b2e
    inx hl
    ldax [hl]
    sui a, $02
    stax [hl]
    jr .jr5b34
.jr5b2e:
    inx hl
    ldax [hl]
    sui a, $02
    stax [hl-]
    jr .jr5b34
.jr5b34:
    inrw [$ffdc]
    eqiw [$ffdc], $13
    jr .jr5b1d
    ret

call5b3b:
    ldaw [$ffdc]
    calt ASTRO4
    mvi a, $20
    inx hl
    stax [hl]
    calt ASTRO9
    calt ASTRO4
    calt ACCCLR
    stax [hl]
    mvi a, $19
    call call4a59
    ldaw [var_energy]
    adi a, $03
    lti a, $1e
    mvi a, $1e
    staw [var_energy]
    lxi hl, music_explode
    calt MUSPLAY
    ret

call5b5a:
    calt ASTRO9
    calt ASTRO4
    calt ACCCLR
    stax [hl]
    pop de
    jmp call55cf.jr564b

call5b63:
    calt ASTRO2
    gti a, $40
    ret
    mvi a, $03
    call call49cf
    mov a, h
    nei a, $00
    ret
    mvi a, $80
    stax [hl]
    push hl
    mvi a, $03
    call call49cf
    pop de
    calt ACCCLR
    stax [de]
    mov a, h
    nei a, $00
    ret
    mvi a, $80
    stax [hl+]
    mvi a, $07
    stax [hl+]
    mvi a, $4a
    stax [hl+]
    mvi a, $36
    stax [hl]
    mvi a, $80
    stax [de+]
    mvi a, $1f
    stax [de+]
    mvi a, $47
    stax [de+]
    mvi a, $31
    stax [de]
    mvi a, $04
    mov [$c6d2], a
    ret

call5ba1:
    mov a, [$c6eb]
    eqi a, $00
    jre .jr5c0d
    ltiw [TIME.SEC], $3c
    jre .jr5c78
    calt ASTRO2
    gti a, $e0
    jre .jr5c0d
    mov a, [$c6ec]
    nei a, $03
    jre .jr5c0d
    inr a
    mov [$c6ec], a
    lxi hl, $c70f
    mvi b, $00
.jr5bc5:
    ldax [hl+]
    inx hl
    inr b
    eqi a, $00
    jr .jr5bc5
    dcx hl
    dcx hl
    mov [$c6eb], b
    mvi a, $01
    stax [hl+]
    calt ACCCLR
    stax [hl]
    mov a, [$c6d7]
    clc
    rar
    rar
    mov [$c6e5], a
    mov c, a
    ldaw [$fff5]
    mov b, a
    mvi a, $07
    sub a, b
    clc
    ral
    add a, c
    mov [$c6ed], a
    mov a, [$c6eb]
    adi a, $06
    calt ASTRO4
    mvi a, $88
    stax [hl+]
    mvi a, $10
    stax [hl+]
    mvi a, $3d
    stax [hl+]
    mov a, [$c5b7]
    adi a, $06
    stax [hl]
.jr5c0d:
    mov a, [$c6e5]
    eqi a, $00
    dcr a
    mov [$c6e5], a
    mov a, [$c6ed]
    eqi a, $00
    dcr a
    mov [$c6ed], a
    eqi a, $00
    jr .jr5c2d
    calt ACCCLR
    mov [$c6eb], a
    mvi a, $11
.jr5c2d:
    mvi a, $12
    mov [$c5b5], a
    mov a, [$c6e5]
    eqi a, $00
    jre .jr5c66
    lxi hl, $c5b4
    ldax [hl+]
    oni a, $08
    jr .jr5c50
    inx hl
    inx hl
    ldax [hl]
    dcr a
    stax [hl-]
    dcx hl
    dcx hl
    lti a, $0a
    jr .jr5c5e
    mvi a, $80
    stax [hl]
    jr .jr5c66
.jr5c50:
    inx hl
    inx hl
    ldax [hl]
    inr a
    stax [hl-]
    dcx hl
    dcx hl
    gti a, $20
    jr .jr5c5e
    mvi a, $88
    stax [hl]
    jr .jr5c66
.jr5c5e:
    calt ASTRO2
    gti a, $e0
    jr .jr5c66
    ldax [hl]
    xri a, $08
    stax [hl]
.jr5c66:
    mov a, [$c6f0]
    gti a, $02
    ret
    mov a, [$c5b4]
    xri a, $10
    mov [$c5b4], a
    ret
.jr5c78:
    lxi hl, $c5b4
    mov a, [$c6f0]
    gti a, $02
    jr .jr5c86
    ldax [hl]
    xri a, $10
    stax [hl]
.jr5c86:
    inx hl
    inx hl
    ldax [hl]
    inr a
    stax [hl]
    ret

call5c8c:
    calt ACCCLR
    staw [$ffdc]
.jr5c8f:
    ldaw [$ffdc]
    clc
    ral
    lxi hl, $c70f
    calt ADD_HL_A
    ldax [hl+]
    nei a, $00
    jre .jr5d1a
    push hl
    pop bc
    ldaw [$ffdc]
    adi a, $07
    calt ASTRO4
    inx hl
    ldax [hl+]
    eqi a, $10
    jre .jr5d1a
    ldax [hl+]
    adi a, $05
    mov d, a
    ldax [hl]
    adi a, $01
    mov e, a
    ldaw [$ffdc]
    push bc
    push de
    mvi e, $50
    calt MULTIPLY
    mov a, l
    lxi hl, $c3c0
    calt ADD_HL_A
    pop de
    pop bc
    ldax [bc]
    calt ADD_HL_A
    mov a, d
    stax [hl+]
    mov a, e
    stax [hl]
    ldax [bc]
    adi a, $02
    mov d, [$c6d7]
    nea a, d
    calt ACCCLR
    stax [bc]
    ldaw [$ffdc]
    adi a, $07
    calt ASTRO4
    ldax [hl+]
    inx hl
    oni a, $08
    jr .jr5cf3
    ldax [hl]
    sui a, $01
    stax [hl+]
    ldax [hl]
    sui a, $01
    stax [hl-]
    dcx hl
    dcx hl
    lti a, $0a
    jr .jr5d04
    mvi a, $80
    stax [hl]
    jr .jr5d0c
.jr5cf3:
    ldax [hl]
    sui a, $01
    stax [hl+]
    ldax [hl]
    adi a, $01
    stax [hl-]
    dcx hl
    dcx hl
    gti a, $20
    jr .jr5d04
    mvi a, $88
    stax [hl]
    jr .jr5d0c
.jr5d04:
    calt ASTRO2
    gti a, $e0
    jr .jr5d0c
    ldax [hl]
    xri a, $08
    stax [hl]
.jr5d0c:
    inx hl
    inx hl
    ldax [hl-]
    eqi a, $d6
    jr .jr5d1a
    dcx hl
    calt ACCCLR
    stax [hl]
    ldaw [$ffdc]
    call call5d5d
.jr5d1a:
    inrw [$ffdc]
    eqiw [$ffdc], $03
    jre .jr5c8f
    ret

call5d22:
    mvi a, $0a
    staw [$ffdc]
.jr5d26:
    ldaw [$ffdc]
    calt ASTRO4
    ldax [hl+]
    oni a, $80
    jre .jr5d55
    ldax [hl]
    eqi a, $07
    jr .jr5d38
    inx hl
    ldax [hl]
    sui a, $02
    stax [hl]
    jr .jr5d55
.jr5d38:
    eqi a, $1f
    jr .jr5d41
    inx hl
    ldax [hl]
    sui a, $02
    stax [hl]
    jr .jr5d55
.jr5d41:
    nei a, $10
    jr .jr5d55
    nei a, $11
    jr .jr5d55
    nei a, $12
    jr .jr5d55
    nei a, $13
    jr .jr5d55
    nei a, $14
    jr .jr5d55
    inx hl
    ldax [hl]
    sui a, $02
    stax [hl]
.jr5d55:
    inrw [$ffdc]
    eqiw [$ffdc], $13
    jre .jr5d26
    ret

call5d5d:
    push va
    clc
    ral
    lxi hl, $c70f
    calt ADD_HL_A
    calt ACCCLR
    stax [hl+]
    stax [hl]
    pop va
    push va
    mvi e, $50
    calt MULTIPLY
    mov a, l
    lxi hl, $c3c0
    calt ADD_HL_A
    mvi b, $4f
    calt ACCCLR
    calt MEMSET
    mov a, [$c6ec]
    dcr a
    mov [$c6ec], a
    pop va
    inr a
    mov b, a
    mov a, [$c6eb]
    eqa a, b
    ret
    calt ACCCLR
    mov [$c6eb], a
    mov [$c6ed], a
    mov [$c6e5], a
    ret

call5d9c:
    mov a, [$c5b5]
    eqi a, $12
    jre .jr5dc4
    mov a, [$c5b7]
    adi a, $04
    mov b, a
    calt ASTRO9
    calt ASTRO4
    inx hl
    inx hl
    inx hl
    ldax [hl]
    subnb a, b
    jr .jr5dc4
    lti a, $06
    jr .jr5dc4
    mov a, [$c6f0]
    inr a
    mov [$c6f0], a
    lxi hl, music_bosshit
    calt MUSPLAY
.jr5dc4:
    calt ASTRO9
    calt ASTRO4
    calt ACCCLR
    stax [hl]
    ret

call5dc9:
    lxi hl, $c5b4
    lxi de, $c5b8
    mvi a, $80
    stax [hl+]
    stax [de+]
    mvi a, $13
    stax [hl+]
    mvi a, $14
    stax [de+]
    ldax [hl+]
    stax [de+]
    ldax [hl-]
    adi a, $08
    stax [de]
    push hl
    mvi a, $03
    call call49cf
    shld [$c6d8]
    mvi a, $80
    stax [hl+]
    mvi a, $15
    stax [hl+]
    pop de
    ldax [de+]
    stax [hl+]
    ldax [de]
    adi a, $04
    stax [hl]
    mvi a, $02
    staw [$ffdc]
    lxi hl, music_crash
    calt MUSPLAY
.jr5e00:
    offiw [$ff80], $07
    jr .jr5e08
    lxi hl, music_explode
    calt MUSPLAY
.jr5e08:
    lxi hl, $c5b4
    ldax [hl+]
    oni a, $80
    jr .jr5e15
    inx hl
    inx hl
    ldax [hl]
    sui a, $03
    stax [hl]
.jr5e15:
    lxi hl, $c5b8
    ldax [hl+]
    oni a, $80
    jr .jr5e22
    inx hl
    inx hl
    ldax [hl]
    adi a, $03
    stax [hl]
.jr5e22:
    lhld [$c6d8]
    ldax [hl+]
    oni a, $80
    jr .jr5e3b
    ldax [hl]
    inr a
    stax [hl]
    eqi a, $1f
    jr .jr5e3b
    mvi a, $15
    stax [hl-]
    dcrw [$ffdc]
    ldaw [$ffdc]
    eqi a, $00
    jr .jr5e3b
    stax [hl]
.jr5e3b:
    call call5e50
    call update_screen
    mvi a, $f5
.jr5e43:
    mvi b, $a0
.jr5e45:
    inr b
    jr .jr5e45
    inr a
    jr .jr5e43
    ldaw [$ffdc]
    eqi a, $00
    jre .jr5e00
    ret

call5e50:
    calt SCR1CLR
    mvi a, $f0
    mvi b, $4a
    lxi hl, $c20d
    calt MEMSET
    ret

call5e5a:
    calt ACCCLR
    staw [$ffdc]
    calt GET_BOMBER_X
    adi a, $04
    staw [$ffd0]
    adi a, $06
    staw [$ffd4]
    calt GET_BOMBER_Y
    staw [$ffd1]
    adi a, $02
    staw [$ffd3]
    mvi b, $77
    lxi hl, $c3c0
.jr5e72:
    ldax [hl+]
    mov d, a
    ldax [hl+]
    mov e, a
    nei a, $00
    jr .jr5e8a
    push hl
    push bc
    call try497f
    jr .jr5e82
    jr .jr5e86
.jr5e82:
    mvi a, $01
    staw [$ffdc]
.jr5e86:
    pop bc
    pop hl
.jr5e8a:
    dcr b
    jr .jr5e72
    eqiw [$ffdc], $00
    ret
    rets

call5e91:
    lxi hl, $c3c0
    mvi b, $77
.jr5e96:
    ldax [hl+]
    eqi a, $00
    jr .jr5e9c
    inx hl
    jr .jr5eae
.jr5e9c:
    mov d, a
    ldax [hl+]
    mov e, a
    push bc
    push hl
    push de
    pop hl
    call call5eb1
    pop hl
    pop bc
.jr5eae:
    dcr b
    jr .jr5e96
    ret
call5eb1:
    mov a, l
    ani a, $07
    push va
    call call46ca
    pop va
    mov b, a
    mov a, h
    nei a, $00
    ret
    call call5ec7
    orax [hl]
    stax [hl]
    ret

call5ec7:
    calt ACCCLR
    stc
    jr .jr5ecd
.jr5ecb:
    clc
.jr5ecd:
    ral
    dcr b
    jr .jr5ecb
    ret

call5ed2:
    mov a, [$c69e]
    add a, d
    clc
    rar
    clc
    rar
    clc
    rar
    mov d, a
    mov a, e
    sui a, $08
    clc
    rar
    clc
    rar
    clc
    rar
    mov e, a
    mov a, d
    lxi hl, $c4b0
    calt ADD_HL_A
    ldax [hl]
    push va
    mov a, e
    mov b, a
    call call5ec7
    mov b, a
    pop va
    ana a, b
    eqi a, $00
    ret
    rets

call5f0b:
    lxi hl, $c6a0
    mov a, b
    stax [hl+]
    mov a, c
    stax [hl+]
    mov a, b
    stax [hl+]
    mov a, e
    stax [hl+]
    mov a, d
    stax [hl+]
    mov a, c
    stax [hl+]
    mov a, d
    stax [hl+]
    mov a, e
    stax [hl]
    lxi hl, $c6a0
    mvi b, $03
.jr5f23:
    ldax [hl+]
    mov d, a
    ldax [hl+]
    mov e, a
    push hl
    push bc
    call call5ed2
    jr .jr5f36
    pop bc
    pop hl
    dcr b
    jr .jr5f23
    jr .jr5f3d
.jr5f36:
    pop hl
    pop hl
    mvi b, $00
    ret
.jr5f3d:
    mvi b, $00
    rets

astro4:
    clc
    ral
    ral
    lxi hl, $c5a0
    calt ADD_HL_A
    ret

call5f4b:
    mov a, [$c698]
    lxi hl, $0000
.jr5f52:
    gti a, $09
    jr .jr5f5f
    sui a, $0a
    push va
    mov a, h
    inr a
    mov h, a
    pop va
    jr .jr5f52
.jr5f5f:
    mov b, a
    nei a, $00
    jr .jr5f69
    dcr b
.jr5f64:
    mvi a, $10
    calt ADD_HL_A
    dcr b
    jr .jr5f64
.jr5f69:
    lxi de, $c6fb
    mov a, h
    stax [de+]
    mov a, l
    stax [de]
    ret

call5f71:
    mvi a, $01
    staw [$ffdc]
.jr5f75:
    ldaw [$ffdc]
    calt ASTRO4
    ldax [hl+]
    oni a, $80
    jr .jr5f90
    ldax [hl]
    nei a, $04
    jr .jr5f98
    nei a, $05
    jr .jr5f98
    nei a, $06
    jr .jr5fa4
    gti a, $1f
    jr .jr5f90
    inr a
    stax [hl-]
    eqi a, $24
    jr .jr5f90
    calt ACCCLR
    stax [hl]
.jr5f90:
    inrw [$ffdc]
    eqiw [$ffdc], $13
    jre .jr5f75
    ret
.jr5f98:
    mvi a, $05
    stax [hl+]
    ldax [hl]
    adi a, $01
    stax [hl+]
    ldax [hl]
    adi a, $03
    stax [hl]
    jr .jr5f90
.jr5fa4:
    inx hl
    ldax [hl]
    adi a, $05
    stax [hl]
    jr .jr5f90

data5faa:
    #d $40484a4a7a43
    #d $40585e40405052525e4040407740405c
    #d $4545744446525240404076747441415d
    #d $714040405f404050507e404040686262
    #d $7644445d5d40407040405e5050737140
    #d $406849495d7040465f4040
