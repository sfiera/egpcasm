#include "gamepock.asm"

#bankdef rom
{
    addr = CART.HEADER
    size = $2000
    fill = true
    outp = 0
}

header:
    db CART.MAGIC
    dw main
    dw main
    dw 0
    dw 0
    jmp interrupt

#addr CART.USER0
    jmp call469b
    jmp call46a3
    jmp call4997
    jmp call5192
    jmp call5f40
    jmp call46b2
    jmp call46b6
    jmp call46ba
    jmp call46c0
    jmp call46c5

#addr CART.BEGIN
main:
    lxi sp, $c7ff
    call call42dc

start:
    lxi sp, $c7ff
    calt ACCCLR
    staw [$fff1]
    staw [$fff0]
    mvi a, $01
    staw [$fff6]
    call call40fd
    mvi a, $01
    staw [$fff6]
.jr4049:
    call call427b
.jr404c:
    neiw [$fff6], $01
    call call40aa
    neiw [$fff6], $02
    call call40aa
    neiw [$fff6], $03
    call call40aa
    neiw [$fff6], $04
    call call40bb
    neiw [$fff6], $05
    call call40cc
    eqiw [$fff0], $00
    jr .jr4076
    call call42ed
    call call4303
    jre .jr404c
.jr4076:
    eqiw [$fff0], $01
    jr .jr407f
    call call40dd
    jre .jr404c
.jr407f:
    lxi hl, $ffa0
    lxi de, $ffa3
    mvi b, $03
    calt MEMCCPY
    lxi de, $ffa3
    neiw [$fff4], $01
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
    jre .jr4049
    jre start

call40aa:
    call call4b92
.jr40ad:
    call call4bde
    call call4d75
    call call43c4
    neiw [$fff1], $00
    jr .jr40ad
    ret

call40bb:
    call call5521
.jr40be:
    call call5552
    call call55cf
    call call43c4
    neiw [$fff1], $00
    jr .jr40be
    ret

call40cc:
    call call5703
.jr40cf:
    call call5778
    call call578a
    call call43c4
    neiw [$fff1], $00
    jr .jr40cf
    ret

call40dd:
    mvi a, $01
    inrw [$fff6]
    ltiw [$fff6], $06
    staw [$fff6]
    call call4307
    eqiw [$fff6], $01
    ret
    eqiw [$fff4], $01
    jr .jr40f7
    gtiw [$fff5], $02
    inrw [$fff5]
    ret
.jr40f7:
    gtiw [$fff5], $04
    inrw [$fff5]
    ret

call40fd:
    calt SCR1CLR
    aniw [$ff89], $00
    call call4194
    call call41b9
    lxi de, $c061
    lxi hl, gfx_astro
    mvi b, $1e
    calt MEMCOPY
    lxi de, $c0a9
    lxi hl, gfx_bomber
    mvi b, $24
    calt MEMCOPY
    lxi hl, str4249
    calt DRAWTEXT
    db $10, $1d, TEXT.SCR1 | TEXT.SPC1 | str4249.len
    lxi hl, $fff4
    calt DRAWHEX
    db $35, $1d, $c0
    lxi hl, $fffd
    calt DRAWHEX
    db $2c, $24, $c0
    aniw [$ffde], $00
    oriw [$ffdf], $01
    call call43c4
.jr4137:
    calt JOYREAD
    offiw [$ff95], $08
    ret
    call try42cd
    jre call40fd
    gtiw [$ff89], $0f
    jr .jr4137
    mvi a, $01
    staw [$ffe7]
.jr4149:
    calt ACCCLR
    staw [$fff1]
    calt USER5
    mvi a, $80
    stax [hl+]
    mvi a, $01
    stax [hl+]
    calt ACCCLR
    stax [hl+]
    stax [hl]
    call call4303
    neiw [$fff6], $01
    call call40aa
    neiw [$fff6], $02
    call call40aa
    neiw [$fff6], $03
    call call40aa
    neiw [$fff6], $04
    call call40bb
    neiw [$fff6], $05
    call call40cc
    eqiw [$fff1], $03
    jr .jr4185
    inrw [$fff6]
    gtiw [$fff6], $05
    jre .jr4149
    jmp start
.jr4185:
    eqiw [$fff1], $01
    jre call40fd
    ldaw [$fff4]
    xri a, $03
    staw [$fff4]
    call call42d5
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

str4249:
    #d smalltext("LEVEL"), largetext("-")
.len = $ - str4249

str424f:
    #d largetext("HIGH SCORE")
.len = $ - str424f
str4259:
    #d largetext("GAME OVER")
.len = $ - str4259
str4262:
    #d largetext("[PERFECT]")
.len = $ - str4262
str426b:
    #d largetext("VERY GOOD!")
.len = $ - str426b
str4275:
    #d largetext("=4800=")
.len = $ - str4275

call427b:
    lxi hl, music4a85
    calt MUSPLAY
    calt ACCCLR
    staw [$ffe7]
    mov [$c6ec], a
    staw [$ff89]
    call call4300
    calt SCR1CLR
    call call4194
    call call41ce
    oriw [$ffdf], $01
    call call43c4
    lxi hl, str424f
    calt DRAWTEXT
    db $08, $14, TEXT.SCR1 | TEXT.SPC1 | str424f.len
    call call431a
    neiw [$fff4], $01
    lxi hl, $c692
    lxi hl, $c695
    lxi de, $ffa3
    mvi b, $02
    calt MEMCOPY
    lxi hl, $ffa3
    calt DRAWHEX
    db $17, $1e, $94
    calt SCRN2LCD
.jr42b9:
    eqiw [$ff89], $04
    jr .jr42b9
    aniw [$fff1], $00
    aniw [$fff0], $00
    aniw [$ff89], $00
    call call41c6
    call call42ed
    ret

try42cd:
    oniw [$ff95], $01
    rets
    oniw [$ff93], $01
    rets

call42d5:
    lxi hl, music4b8d
    calt MUSPLAY
    eqiw [$fff4], $01
    ; fall through

call42dc:
    mvi a, $01
    mvi a, $02
    staw [$fff4]
    call call4a6b
    ; fall through

call42e5:
    lxi hl, $ffa0
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
    call call42e5

call4303:
    mvi a, $1e
    staw [$fffc]

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
    lxi hl, str4249
    calt DRAWTEXT
    db $05, $00, TEXT.SCR1 | TEXT.SPC1 | str4249.len
    lxi hl, $fff4
    calt DRAWHEX
    db $28, $00, $c0
    ret

call4329:
    oriw [$ffe7], $01
    lxi hl, music4af8
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
    lxi hl, str4262
    calt DRAWTEXT
    db $0b, $1c, TEXT.SCR1 | TEXT.SPC1 | str4262.len
    lxi hl, str426b
    calt DRAWTEXT
    db $0b, $29, TEXT.SCR1 | TEXT.SPC1 | str426b.len
    eqiw [$fff4], $02
    jr .jr4367
    gtiw [$ff88], $40
    jr .jr4367
    lxi hl, str4275
    calt DRAWTEXT
    db $14, $36, TEXT.SCR1 | TEXT.SPC1 | str4275.len
.jr4367:
    calt SCRN2LCD
    calt JOYREAD
    oniw [$ff95], $09
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
    gtiw [$ff89], $05
    jr .jr4372
    eqiw [$ffe4], $01
    calt SCR1INV
    oriw [$ffe7], $01
    lxi hl, music4ad3
    calt MUSPLAY
.jr4397:
    oriw [$ffde], $01
    call call43c4
    lxi hl, $c0ea
    calt ACCCLR
    mvi b, $37
    calt MEMSET
    gtiw [$ff88], $40
    jr .jr43af
    lxi hl, str4259
    calt DRAWTEXT
    db $0a, $18, TEXT.SCR1 | TEXT.SPC1 | str4259.len
.jr43af:
    calt SCRN2LCD
    calt JOYREAD
    oniw [$ff95], $08
    jr .jr43ba
    gtiw [$ff89], $0a
    ret
    rets
.jr43ba:
    offiw [$ff93], $01
    rets
    gtiw [$ff89], $14
    jre .jr4397
    rets

call43c4:
    calt USER5
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
    call call44d1
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
    calt USER0
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
    lxi de, data4540
    calt USER1
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
    lxi de, data4564
    calt USER1
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
    calt USER0
    shld [$c68e]
    ldaw [$ffd5]
    sui a, $08
    staw [$ffd5]
    call call470a
.jr44d0:
    ret

call44d1:
    lxi hl, $c000
    mvi b, $4a
    calt ACCCLR
    calt MEMSET
    neiw [$ffe7], $00
    jr .jr44e1
    call call431a
    jre .jr451c
.jr44e1:
    lxi hl, $fffd
    calt DRAWHEX
    db $00, $00, $c0
    lxi hl, str453d
    calt DRAWTEXT
    db $0d, $00, $c1
    lxi de, $c6a8
    ldax [de]
    mov b, [$ff89]
    lta a, b
    jr .jr4506
    inr a
    inr a
    stax [de]
    ltiw [$ff89], $3c
    jr .jr4506
    eqiw [$fffc], $00
    dcrw [$fffc]
.jr4506:
    ltiw [$fffc], $06
    jr .jr450e
    gtiw [$ff88], $50
    jr .jr4518
.jr450e:
    ldaw [$fffc]
    mov b, a
    lxi hl, $c013
    mvi a, $1f
    dcr b
    calt MEMSET
.jr4518:
    neiw [$fff6], $05
    jr .jr4524
.jr451c:
    lxi hl, $ffa0
    calt DRAWHEX
    db $32, $00, $c5
    jr .jr453c
.jr4524:
    lxi hl, str453e
    calt DRAWTEXT
    db $33, $00, $c2
    call call5f4b
    lxi hl, $c6fb
    calt DRAWHEX
    db $3c, $00, $c2
    lxi hl, $c039
    mvi a, $04
    stax [hl+]
    stax [hl]
.jr453c:
    ret

str453d:
    #d smalltext("E")

str453e:
    #d smalltext("T"), largetext(".")

data4540:
    #d $b3b3b33333217658d7b7a69577593563
    #d $9f8f878755667755667755667777e355
    #d $66556688

data4564:
    dw data45ac
    dw data45b7
    dw data45c2
    dw data45cd
    dw data45d0
    dw data45d3
    dw data45d5
    dw data45dc
    dw data45e1
    dw data45ee
    dw data45f9
    dw data4603
    dw data460c
    dw data4613
    dw data461d
    dw data4620
    dw data4626
    dw data4638
    dw data4648
    dw data4640
    dw data4650
    dw data4655
    dw data465b
    dw data4650
    dw data4655
    dw data465b
    dw data4650
    dw data4655
    dw data465b
    dw data4662
    dw data4669
    dw data4650
    dw data4655
    dw data4650
    dw data4655
    dw data4677

data45ac:
    #d $0500050205070606060604

data45b7:
    #d $0200020507070606060604

data45c2:
    #d $0000000005070606060604

data45cd:
    #d $050202

data45d0:
    #d $010601

data45d3:
    #d $0101

data45d5:
    #d $22170d350d1722

data45dc:
    #d $e0344b34e0

data45e1:
    #d $14085522082255220822550814

data45ee:
    #d $000008142a1441142a1408

data45f9:
    #d $00000008142a142a1408

data4603:
    #d $000000000814081408

data460c:
    #d $085c2a3f2a5c08

data4613:
    #d $54aa45aa540000010000

data461d:
    #d $0a150a

data4620:
    #d $050205050202

data4626:
    #d $8040709bbf537eb0400001076c7e653f0601

data4638:
    #d $a0b09bbf537eb040

data4640:
    #d $02066c7e653f0601

data4648:
    #d $20301b3f537e3040

data4650:
    #d $0000081408

data4655:
    #d $002214001422

data465b:
    #d $08220855082208

data4662:
    #d $492a006b002a49

data4669:
    #d $0606070707070707070707070606

data4677:
    #d $ffffffffffffffff

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

call469b:
    add a, l
    mov l, a
    mov a, h
    aci a, $00
    mov h, a
    ret

call46a3:
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

call46b2:
    lxi hl, $c5a0
    ret

call46b6:
    mov a, [$c5a0]
    ret

call46ba:
    mov a, [$c5a2]
    ret

call46c0:
    mov a, [$c5a3]
    ret

call46c5:
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
    calt USER0
    ret
.jr46e2:
    mvi a, $4b
    calt USER0
    jr .jr46dd
.jr46e6:
    lxi hl, $0000
    ret
.jr46ea:
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
    calt USER2
    eqiw [$ffe7], $00
    ret
    eqiw [$fffc], $00
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
    calt USER8
    inr a
    mov [$c5a3], a
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
    calt USER0
    lxi de, $c5a2
    ldax [hl+]
    addx [de]
    stax [de+]
    ldax [hl]
    addx [de]
    stax [de]
.jr47c1:
    calt USER7
    oni a, $80
    jr .jr47c7
    calt ACCCLR
    jr .jr47cc
.jr47c7:
    gti a, $28
    jr .jr47d0
    mvi a, $29
.jr47cc:
    mov [$c5a2], a
.jr47d0:
    calt USER8
    lti a, $08
    jr .jr47da
    mvi a, $08
    mov [$c5a3], a
.jr47da:
    calt USER8
    lti a, $3c
    mvi a, $3c
    mov [$c5a3], a
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
    calt USER6
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
    calt USER7
    adi a, $0c
    stax [hl+]
    calt USER8
    adi a, $02
    stax [hl]
    jr .jr482c
.jr4826:
    mvi a, $04
    calt USER0
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
    lxi hl, music4b31
    calt MUSPLAY
    calt USER2
    ret
    calt USER5
    ldaw [$ffdc]
    calt USER4
    inx hl
    ldax [hl-]
    nei a, $1f
    jr .jr4856
    calt ACCCLR
    stax [hl+]
    ldax [hl]
.jr4856:
    mov b, a
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
    lxi hl, music4b0f
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
    eqiw [$ffe7], $00
    jre .jr48ef
    calt USER6
    oni a, $80
    jre .jr48e6
    lhld [$ff92]
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
    ldaw [$ff93]
    ani a, $09
    eqi a, $09
    jr .jr48e6
    jre .jr4908
.jr48e6:
    pop va
    pop de
    pop bc
    pop hl
    ret
.jr48ef:
    ldaw [$ff93]
    mov b, a
    ldaw [$ff95]
    ana a, b
    oni a, $08
    jr .jr48fe
    mvi a, $01
.jr48fb:
    staw [$fff1]
    jr .jr48e6
.jr48fe:
    oni a, $01
    jr .jr48e6
    lxi hl, music4b8d
    calt MUSPLAY
    mvi a, $02
    jr .jr48fb
.jr4908:
    oriw [$ffe7], $01
    calf $0e4d
    calt ACCCLR
    mov [$c6ec], a
    mov [$c6e7], a
.jr4916:
    calt JOYREAD
    ldaw [$ff93]
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
    calt USER6
    oni a, $80
    jr .jr4950
    mov a, [$c6ec]
    nei a, $00
    jr .jr493f
    lxi hl, music4b65
    calt MUSPLAY
    jr .jr4950
.jr493f:
    eqiw [$ffe7], $00
    jr .jr4950
    calt USER5
    ldax [hl+]
    oni a, $80
    jr .jr4950
    ldax [hl]
    nei a, $03
    jr .jr4950
    lxi hl, music4b7a
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

call4997:
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
    calt USER0
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
    calt USER0
    dcrw [$ffe0]
    jr .jr4a00
    mvi h, $00
    ret
.jr4a0e:
    mvi a, $04
    calt USER0
    dcrw [$ffe0]
    jr .jr4a17
    mvi h, $00
    ret
.jr4a17:
    mvi a, $80
    onax [hl]
    jr .jr4a26
    mvi a, $04
    calt USER0
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
    ldaw [$ffa0]
    gti a, $09
    ret
    mvi a, $01
    staw [$fff1]
    mvi a, $09
    staw [$fff0]
    staw [$ffa0]
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
    gti a, $48
    stax [hl-]
    pop de
    pop bc
    ret

call4a6b:
    eqiw [$fff4], $02
    mvi a, $06
    mvi a, $04
    staw [$fffd]
    aniw [$ff89], $00
    mvi a, $01
    staw [$ffe4]
    eqiw [$fff4], $02
    mvi a, $00
    mvi a, $02
    staw [$fff5]
    ret

music4a85:
    #d $061206090b360f090d090b
    #d $090d1b0f091236120914090f09121b10
    #d $1b0f1b0f090b090f090d36ff

music4aac:
    #d $06120609
    #d $0b2d0b090d240e0910090e36061b0612
    #d $06090b2d0d090e120b090e090b091209
    #d $1036ff

music4ad3:
    #d $0b0906090b090f240b120f090b
    #d $090f0912240f1212090f09120916240a
    #d $120a120a090f36ff

music4af8:
    #d $061206090b2d0b09
    #d $0f1b0f090d090b090d1212091236ff

music4b0f:
    #d $03
    #d $01020100010301020100050a04000304
    #d $030003020300020105ff

music4b2a:
    #d $040103010101ff

music4b31:
    #d $1402000114030001ff

music4b3a:
    #d $010500030305
    #d $0003050500030606000308070003ff

music4b4f:
    #d $1205130414031502130411051006ff

music4b5e:
    #d $12000f001600ff

music4b65:
    #d $0604050306040703080409
    #d $030804070306040503ff

music4b7a:
    #d $020101010001ff

data4b81:
    #d $120216010001120216010001

music4b8d:
    #d $12021601ff

call4b92:
    neiw [$fff6], $01
    jr .jr4b9d
    eqiw [$fff0], $00
    jr .jr4ba0
    neiw [$ffe7], $00
.jr4b9d:
    call call4875
.jr4ba0:
    calt ACCCLR
    staw [$fff0]
    staw [$fff1]
    staw [$ff89]
    ldaw [$fff6]
    mov b, a
    clc
    ral
    ral
    add a, b
    lxi hl, data4bcf - 5
    calt USER0
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
    neiw [$fff4], $02
    jr .jr4bcd
    eqiw [$fff6], $02
    mvi a, $03
    mvi a, $04
.jr4bcd:
    stax [de]
    ret

data4bcf:
    #d $280a0409042800020d052314030e04

call4bde:
    call call489b
    calt USER6
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
    eqiw [$fff6], $03
    jr .jr4c1e
    eqiw [$fffa], $00
    jr .jr4c09
    call call4d27
    jr .jr4c0b
.jr4c09:
    dcrw [$fffa]
.jr4c0b:
    ltiw [$ff89], $37
    jr .jr4c17
    neiw [$ffe7], $00
    jr .jr4c1e
    gtiw [$ff89], $15
    jr .jr4c1e
.jr4c17:
    mvi a, $04
    staw [$fff9]
    calt ACCCLR
    staw [$fffb]
.jr4c1e:
    lxi hl, $c666
    ldaw [$fff2]
    calt USER0
    ldaw [$fff9]
    stax [hl]
    lxi hl, $c640
    ldaw [$fff2]
    calt USER0
    ldaw [$fffb]
    stax [hl]
    call $5518

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
    calt USER1
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
    call $5518
    jre .jr4c4b
.jr4c95:
    call $5518
    eqiw [$fff6], $03
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
    calt USER1
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
    calt USER0
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
    call $5518
    jre .jr4ca8
.jr4cf0:
    call $5518
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
    calt USER0
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
    calt USER2
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
    calt USER0
    ldax [hl]
    staw [$fffb]
    lxi hl, $c69d
    ldax [hl]
    inr a
    ani a, $03
    stax [hl]
    gti a, $02
    jr .jr4d49
    calt USER2
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
    calt USER6
    oni a, $80
    jr .jr4d8c
    call call4fe0
    calt USER6
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
    call $52e1
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
    call $5300
    jre .jr4e15
.jr4deb:
    gti a, $08
    jr .jr4df6
    lti a, $0d
    jr .jr4df6
    call $534a
    jre .jr4e15
.jr4df6:
    eqi a, $0d
    jr .jr4dfd
    call $539f
    jr .jr4e15
.jr4dfd:
    eqi a, $0e
    jr .jr4e04
    call $5435
    jr .jr4e15
.jr4e04:
    eqi a, $0f
    jr .jr4e0b
    call $54cb
    jr .jr4e15
.jr4e0b:
    gti a, $1f
    jr .jr4e15
    lti a, $24
    jr .jr4e15
    call $533b
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
    call $516d
    call $50a9
    jr .jr4e31
    calt ACCCLR
    stax [de]
    jr .jr4e3f
.jr4e31:
    call $523d
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
    call $517f
    call $50a9
    jr .jr4e59
    calt ACCCLR
    stax [de]
    jr .jr4e72
.jr4e59:
    call $526b
    call try495b
    jr .jr4e6c
    eqiw [$fff6], $03
    jr .jr4e72
    call $529a
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
    calt USER6
    oni a, $80
    ret
    neiw [$ffe7], $00
    jr .jr4e87
    ltiw [$ff89], $13
    ret
.jr4e87:
    ltiw [$ff89], $35
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
    calt USER2
    ani a, $7f
    eqiw [$ffe7], $00
    ani a, $3f
    mov d, a
    lxi hl, $c6ac
    ltax [hl+]
    jre .jr4f1c
    gtax [hl]
    jre .jr4f1c
    calt ACCCLR
    stax [bc]
    eqiw [$fff6], $03
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
    calt USER1
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
    calt USER2
    lti a, $64
    mvi a, $07
    mvi a, $08
    gtiw [$fff6], $02
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
    neiw [$ffe7], $00
    jr .jr4f87
    gtiw [$ff89], $22
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
    calt USER6
    oni a, $80
    jr .jr4f9d
    gtiw [$ff89], $45
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
    ldaw [$fffd]
    dcr a
    jr .jr4fb1
    mvi a, $00
.jr4fb1:
    staw [$fffd]
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
    ldaw [$fff4]
    eqi a, $01
    mvi a, $04
    mvi a, $06
    mov b, a
    ldaw [$fffd]
    inr a
    lta a, b
    mov a, b
    staw [$fffd]
    jmp call489b

call4fe0:
    #d $75e70008690d38e034a2c52d460438d6
    #d $460638da2b38d7460238d934b4c52d47
    #d $804e7957104e752b7707cbb1445b49c2
    #d $4e6a69194e6e7708d1b1445b49c24e5c
    #d $332d4708693069604e5a27084e29370d
    #d $4e25332d57404e442bb1445b49c24e3c
    #d $28fc660a57808538fc483e34874b8348
    #d $3f3369c03d4e25770dcab1445b49c1dc
    #d $69404e20770ec9b1445b49c1cf6980d4
    #d $770fc9b1445b49c1c36940c832323230
    #d $e04f7bce44594a33853b44c652340f4b
    #d $8308690144e551445b49ef75f6030869
    #d $0244e551445b49e208690d38e034b4c5
    #d $2d47804e9d57104e992b7707d5b1445b
    #d $49c24e8e28fc4603371e691e38fc6919
    #d $4e887708d1b1445b49c24e76332d4708
    #d $693069604e74770dceb1445b49c24e62
    #d $30fe0069404e63770e4e4bb1445b49c2
    #d $4e50330f66b4482a4831482a48311401
    #d $c744ab4685396903123969a53d690f3d
    #d $2d1a2b1b66013d69ad3d690f3d0a3d0b
    #d $460a3f483e345e4b83483f698044594a
    #d $853a30fe0018770fc9b1445b49c1c369
    #d $40c832323230e04f570844594a483e34
    #d $2a4b83483f3369c03d69203b1834a6c5
    #d $2d38d6460238da2b38d7460238d90822
    #d $222c660238d6460438da2e38d738d923
    #d $23
    ret

call5192:
    #d $6607482a4830482e24c151af2c1a
    #d $322d1b60c238d02a60c338d46911af2c
    #d $1a2b1b60c238d12a60c338d3482f3333
    #d $0801060105020b030a04090508000600
    #d $04000200050007000600050105020400
    #d $060008000477023466c63440c6703ea9
    #d $c6480eb5460438d01a460638d40a482a
    #d $48311a6c0028f260c21a6b0237266626
    #d $703fa9c6ae2b60bc1c420a53ef0c482a
    #d $48301a480f7701cb694060e238d1693f
    #d $38d3080a460738d3690838d1087069a6
    #d $c538d01a460238d40a482a48311a28f2
    #d $60c2372666263466c6ae2b482a48301a
    #d $693f60e238d1693f38d30822222a38d0
    #d $1a460238d40a482a48311a28f260c237
    #d $2666263466c6ae2b482a48301a694060
    #d $e238d1693f38d323230822222a38d01a
    #d $460238d40a482a48311a28f260c23726
    #d $66263440c6ae2b482a4830460738d369
    #d $0838d12323
    ret

call52c6:
    #d $b369003d322d1a2b1b34
    #d $ecc569c13d69153d0a46043d0b66023b
    #d $08332b4720cd16203d322b413d2b4602
    #d $3f33083269053d2b413d2b46033f3308
    #d $7069bec6770008322b66023f1a332d57
    #d $08d90a373708b037c8c40a371908483e
    #d $343a4b83483f3369883d08323275f402
    #d $690469051a2b60e23f33082b413724c6
    #d $3d2b66023f0833853d08332b1a47404e
    #d $3124b5c66b030f70ecc42253fad12e77
    #d $00c53d3a30fe0822513a2b16103bd36b
    #d $0324b5c62a6700c5222253f8c50f3c69
    #d $063a322b44ea463f0a3d7069bdc67700
    #d $083245f501690469051a2b60e23f0870
    #d $69bdc67700083245f501690469051a2b
    #d $60e23f332d323247084e2645f5016906
    #d $69071a2b60e23f370ac6333369803d08
    #d $3719cc44e000376ec6333369803d0833
    #d $082b46053f33690db1322f38d61a4602
    #d $38da0a482a48311a28f260c237266626
    #d $2466c6af2c1a2a60aa0a482a48301a69
    #d $3f60e238dc38d7693f38d9445b49c108
    #d $483e344f4b83483f3369883d323228dc
    #d $66063f33087069bdc677004e7c330f32
    #d $66b4482a4831482a48312401c7af2a1a
    #d $413706853a45f501690269031b322b60
    #d $e33d1b45f5016900690624bf54af0aaf
    #d $2a1a2b60c23f2f37234e3e30fe00330f
    #d $66b4482a4831482a48311401c744ab46
    #d $85391269013969a53d690f3d2d1a2b1b
    #d $66033d69ad3d690f3d0a3d0b460a3f33
    #d $483e345e4b83483f086904ae30e008ff
    #d $ffff010101fefefe0202027069bdc677
    #d $0008330f3266b4482a4831482a483124
    #d $01c7af2a1b413706853a45f501690469
    #d $051a322b60e23d45f50169006906240c
    #d $55af0baf2a1a2b60c23f3308ffffff01
    #d $0101fefefe02020228f24137268538f2
    ret

call5521:
    #d $8538f138f0388970799ec638dd690a
    #d $70799fc634b0c46a0b69409f690235f5
    #d $03690165e70169017079d1c6857079e7
    #d $c6
    ret

call5552:
    #d $449b48b447804e7120dd706ad1c6
    #d $28dd60fa4e6505dd0070699ec677034e
    #d $5470699fc6770accb007077079f3c685
    #d $70799fc670699fc64170799fc6857079
    #d $9ec6690a706df3c69370699fc660c734
    #d $aa5fae483e34b1c424b0c46a0b95483f
    #d $2b75f000857079bbc48570799ec665f0
    #d $0044c15ac6349ec62b413b8754345a

call55cf:
    #d $44
    #d $9b48b4478054e75644715f65dd004419
    #d $5b445447b6773acb6a00445748693770
    #d $79efc5449b4869017079cbc6b7b22d47
    #d $804e4f2d6704c76705c477064e442d1c
    #d $2b1d482e44fb5a545a5b482f0c38d646
    #d $0238da0d38d738d9690538dc28dcb22d
    #d $4780d82d7707d42d38d0460638d42b38
    #d $d1460538d3447f49443b5b20dc75dc13
    #d $4fdab7417079cbc677054fa07069a2c5
    #d $46061a46051c7069a3c51b46021d440b
    #d $5f445748b5460438d0460638d4b638d1
    #d $460238d3690538dc28dcb22d4780d82d
    #d $7707d42d38d6460638da2b38d7460538
    #d $d9445b49444a4820dc75dc134fda443e
    #d $4a65e700d12589144e29690138f02589
    #d $1ec4690338f125893cd915f0017069d1
    #d $c67702c8258950cb15f101c7258946c3
    #d $15f10144bc4f087069edc5671ec64170
    #d $79edc5ce690030fd65fd00690238f015
    #d $f101
    ret

call5703:
    #d $8538f038f138897079ebc67079
    #d $edc67079e5c67079ecc67079e8c634b4
    #d $c569883d69113d69403d69123b7069e7
    #d $c667007079f0c634c0c3856aef9f340f
    #d $c76a089f28f5482a48316700c76701c2
    #d $6912692469327079d7c67069e7c66700
    #d $d0706a98c6693c60e2388946027079a8
    #d $c669017079e7c6
    ret

call5778:
    #d $449b4844505e7069
    #d $d2c67700517079d2c608

call578a:
    #d $449b48b44780
    #d $540a5a65f001cfb007617761c97069d2
    #d $c6670044635b448c5c448c5c448c5c44
    #d $a15b44715f44225d445447b6773acb6a
    #d $0044574869377079efc534a7c52b2738
    #d $c769383f3369223b449b4869017079cb
    #d $c6690738dcb7b22d47804ea7322d5138
    #d $d0460338d42f38d138d3332b7705c628
    #d $d3460238d328dcb22d47804e7f2d6707
    #d $c86710c9671fca4e73240506c9240205
    #d $c724020e6900691969807079f9c62d38
    #d $d660c438da2b38d760c538d9445b49c2
    #d $4e4a28dcb2322b771fd4b7b23269223d
    #d $691238dc32692d3b342a4b834e2e6920
    #d $3bb7b2853b7069f9c644594a7069f9c6
    #d $7719cf28fc4603371f691e38fc342a4b
    #d $83ca69203b28dc6607445d5d20dc75dc
    #d $134f7234cbc62b413b77054f447069b6
    #d $c538d0460838d47069b7c538d1460e38
    #d $d369027079cbc6b7b22d4780ce2d7706
    #d $ca2d1c2b1d447f49449c5d34cbc62b41
    #d $3b7705e3b5460538d0460538d4b638d1
    #d $460238d3690738dc28dcb22d47804e2b
    #d $2d6710c86707c9671fca4e1f240205c7
    #d $240506c324020e2d38d660c438da2b38
    #d $d760c538d9445b49444a4820dc75dc13
    #d $4fc6445a5e445748443e4a28891a693c
    #d $60e2578085707998c665e700d5258914
    #d $4e2015f00125891ed9857079ecc66903
    #d $38f125893cc915f001258944c24e3844
    #d $bc4f7069f0c677054ec6b45780d334a0
    #d $c524ecc5853c2269803d69013d2c3d2a
    #d $3b8534a4c56a0f9f34bcc56a2f9f6901
    #d $7079e8c644c95d690138f138f038e785
    #d $7079ecc615e70134ac4a83558007fc05
    #d $890034a4c5856a4b9f69907079a0c587
    #d $34045a9b051b9534fbc69a2d1b923409
    #d $5a9b3f1b9144c443758903fc706998c6
    #d $6700ce51480e340001a42744bc4f480f
    #d $ef8769807079a0c5857079ecc638e770
    #d $79e8c608

str5a04:
    #d largetext("BONUS")

data5a09:
    #d $107069edc5671e
    #d $c6417079edc5d98530fd65fd00690238
    #d $f015f1018565f0027079e7c67079ecc6
    #d $44915e0870699ec6482a48301a8560e2
    #d $7079a0c6690b7079a1c669077079a2c6
    #d $706aa1c6690b60e234b0c4ae2b38dc67
    #d $004e2f28dc483138dc481a449e5a7069
    #d $a2c6517079a2c67700e97069a0c64608
    #d $7079a0c67069a1c6517079a1c677004f
    #d $b908340dc26a4a2b17f03d52fa08706a
    #d $a2c6690860e2482a4830482a4830482a
    #d $483038d37069a0c638d2692438d15424
    #d $44b04780cf7069b9c457020847040869
    #d $12480ece7069b9c45720084740086932
    #d $480e690144cf490e6700cd69803d6907
    #d $3d694a3d480f3b08480f08482eb77701
    #d $c6482f0d4602ca0c66031c44d25ec748
    #d $2f44d25ec318482f08690538dc28dcb2
    #d $2d4780d02b6707c6322b66023bc6322b
    #d $66023fc020dc75dc13e30828dcb26920
    #d $323bb7b2853b691944594a28fc460337
    #d $1e691e38fc342a4b8308b7b2853b482f
    #d $544b56b0274008690344cf490e670008
    #d $69803b483e690344cf49482f853a0e67
    #d $000869803d69073d694a3d69363b6980
    #d $3c691f3c69473c69313a69047079d2c6
    #d $087069ebc677004e6435893c4ecab027
    #d $e04e5a7069ecc667034e52417079ecc6
    #d $340fc76a002d32427700fa3333707aeb
    #d $c669013d853b7069d7c6482a48314831
    #d $7079e5c61b28f51a690760e2482a4830
    #d $60c37079edc67069ebc64606b269883d
    #d $69103d693d3d7069b7c546063b7069e5
    #d $c67700517079e5c67069edc677005170
    #d $79edc67700c7857079ebc66911691270
    #d $79b5c57069e5c677004e2b34b4c52d47
    #d $08ce32322b513f3333370ad269803bd6
    #d $32322b413f33332720c469883bc8b027
    #d $e0c42b16083b7069f0c62702087069b4
    #d $c516107079b4c50834b4c57069f0c627
    #d $02c42b16103b32322b413b088538dc28
    #d $dc482a4830340fc7ae2d67004e7c483e
    #d $481f28dc4607b2322d77104e6d2d4605
    #d $1c2b46011d28dc481e482e6d50930f34
    #d $c0c3ae482f481f29ae0c3d0d3b294602
    #d $706cd7c660ec853928dc4607b22d3247
    #d $08d12b66013d2b66013f3333370ad569
    #d $803bd92b66013d2b46013f33332720c4
    #d $69883bc8b027e0c42b16083b32322f77
    #d $d6c833853b28dc445d5d20dc75dc034f
    #d $6e08690a38dc28dcb22d47804e272b77
    #d $07c6322b66023bdd771fc6322b66023b
    #d $d46710d16711ce6712cb6713c86714c5
    #d $322b66023b20dc75dc134fca08480e48
    #d $2a4830340fc7ae853d3b480f480e6d50
    #d $930f34c0c3ae6a4f859f7069ecc65170
    #d $79ecc6480f411a7069ebc660fa088570
    #d $79ebc67079edc67079e5c6087069b5c5
    #d $77124e207069b7c546041ab7b2323232
    #d $2b60b2d03706cd7069f0c6417079f0c6
    #d $34814b83b7b2853b0834b4c524b8c569
    #d $803d3c69133d69143c2d3c2f46083a48
    #d $3e690344cf49703ed8c669803d69153d
    #d $482f2c3d2a46043b690238dc340f4b83
    #d $558007c4342a4b8334b4c52d4780c632
    #d $322b66033b34b8c52d4780c632322b46
    #d $033b703fd8c62d4780d12b413b771fcb
    #d $69153f30dc28dc7700c13b44505e44c4
    #d $4369f56aa042fe41fa28dc77004fb108
    #d $8769f06a4a340dc29f088538dcb54604
    #d $38d0460638d4b638d1460238d36a7734
    #d $c0c32d1c2d1d6700d1483e481e447f49
    #d $c1c4690138dc481f483f52e675dc0008
    #d $1834c0c36a772d7700c232d21c2d1d48
    #d $1e483e482e483f44b15e483f481f52e6
    #d $080f0707480e44ca46480f1a0e670008
    #d $44c75e709b3b0885482bc2482a483052
    #d $fa0870699ec660c4482a4831482a4831
    #d $482a48311c0d6608482a4831482a4831
    #d $482a48311d0c34b0c4ae2b480e0d1a44
    #d $c75e1a480f608a7700081834a0c60a3d
    #d $0b3d0a3d0d3d0c3d0b3d0c3d0d3b34a0
    #d $c66a032d1c2d1d483e481e44d25ec748
    #d $1f483f52eec7483f483f6a00086a0018

call5f40:
    #d $482a4830483034a0c5ae
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
    calt $dc
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
    ldaw [$ffdc]
    calt $e4
    ldax [hl+]
    oni a, $80
    jr .jr5f90
    ldax [hl]
    nei a, $04
    jr .jr5f98
    nei a, $05
    jr .jr5f98
    nei a, $06
    jr $5fa4
    gti a, $1f
    jr .jr5f90
    inr a
    stax [hl-]
    eqi a, $24
    jr .jr5f90
    calt $8a
    stax [hl]
.jr5f90:
    inrw [$ffdc]
    eqiw [$ffdc], $13
    jre $5f75
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
