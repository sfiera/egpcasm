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

WRAMC594 = OBJ.END
WRAMC63E = WRAMC594 + 170
WRAMC6E8 = WRAMC63E + 170
WRAMC6F2 = WRAMC6E8 + 10
WRAMC788 = WRAMC6F2 + 150

header:
    db CART.MAGIC
    dw start
    dw start
    dw font
    dw 0

    jre jr4030

#addr $4030
jr4030:
    oniw [$ffd0], $80
.jr4033:
    jmp $0128
    calt JOYREAD
    neiw [$ff93], $09
    jr .jr4047
    neiw [$ff93], $08
    jr .jr4047
    eqiw [$ff93], $01
    jr .jr4033
    lxi hl, music4faa
    calt MUSPLAY
.jr4047:
    oniw [$ffd1], $80
    jr .jr4050
    offiw [$ff80], $03
    calf $0e4d
.jr4050:
    lxi sp, $c800
    jr start.jr405d

start:
    di
    calt WRAMCLR
    lxi sp, $c800
    call call409e
.jr405d:
    call call40e3
    ei
.jr4062:
    call call40f0
.jr4065:
    call call491c
    call call4928
.jr406b:
    call call4924
    call call4158
.jr4071:
    calt JOYREAD
    eqiw [$ff93], $01
    jr .jr407e
    oniw [$ff95], $01
    jr .jr4094
    call call4175
    jr .jr4065
.jr407e:
    eqiw [$ff93], $08
    jr .jr408b
    oniw [$ff95], $08
    jr .jr4094
    call call4184
    jre .jr4062
.jr408b:
    eqiw [$ff89], $0a
    jr .jr4097
    call call4197
    jre .jr4062
.jr4094:
    call call4928
.jr4097:
    ltiw [$ff8b], $1e
    jre .jr406b
    jre .jr4071

call409e:
    calt OBJCLR
    staw [$ffd2]
    lxi hl, data4efc
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
    call call4ba2
    call call40b9
    ret

call40b9:
    lxi hl, WRAMC6E8
    mvi b, $a9
    calt MEMCLR
    mvi c, $01
.jr40c1:
    mov a, c
    eqi a, $01
    lxi hl, WRAMC788
    lxi hl, WRAMC6E8
    mvi a, $11
    mvi b, $09
    calt MEMSET
    dcr c
    jr .jr40c1
    lxi hl, WRAMC6F2
    lxi de, $0009
    mvi b, $0e
.jr40d9:
    mvi a, $01
    stax [hl]
    calt ADDRHLDE
    mvi a, $01
    stax [hl+]
    dcr b
    jr .jr40d9
    ret

call40e3:
    ldaw [$ffd2]
    mov c, a
    lxi hl, $ffd0
    mvi b, $2f
    calt MEMCLR
    mov a, c
    staw [$ffd2]
    ret

call40f0:
    calt SCR2CLR

    lxi hl, text4e82
    calt DRAWTEXT
    db $0c, $01, $0a

    lxi hl, text4e8c
    calt DRAWTEXT
    db $0c, $09, $0a

    lxi hl, text4e96
    calt DRAWTEXT
    db $17, $12, $15

    lxi hl, text4e9b
    calt DRAWTEXT
    db $11, $19, $17

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

    lxi hl, text4ea2
    calt DRAWTEXT
    db $11, $22, $15

    lxi hl, text4ea7
    calt DRAWTEXT
    db $11, $2c, $13

    lxi hl, text4eaa
    calt DRAWTEXT
    db $22, $2c, $01

    lxi hl, text4eab
    calt DRAWTEXT
    db $27, $2c, $13

    lxi hl, text4eae
    calt DRAWTEXT
    db $11, $36, $13

    lxi hl, text4eb1
    calt DRAWTEXT
    db $22, $36, $14

    ret

call4158:
    calt SCR2COPY
    oniw [$ffd0], $04
    jr .jr4170
    ldaw [$ffd2]
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

call4175:
    lxi hl, music4faa
    calt MUSPLAY
    ldaw [$ffd2]
    inr a
    nop
    gti a, $02
    jr .jr4181
    calt ACCCLR
.jr4181:
    staw [$ffd2]
    ret

call4184:
    eqiw [$ffd2], $00
    jr .jr418c
    call call4236
    jr .jr4196
.jr418c:
    eqiw [$ffd2], $01
    jr .jr4193
    call call4539
.jr4193:
    call call452c
.jr4196:
    ret

call4197:
    ldaw [$ffd3]
    push va
    calt ACCCLR
    staw [$ffd3]
    call call493d
    call call491c
    call call4920
    oriw [$ffd0], $80
    lxi hl, data4fb8
    ldax [hl+]
    staw [$ffea]
    shld [$ffe7]
    mvi a, $03
    staw [$ffe9]
    call call46b7
    call call4a2d
    lxi hl, text4ee9
    calt DRAWTEXT
    db $12, $04, $03
    lxi hl, text4ee4
    calt DRAWTEXT
    db $22, $04, $14
    call call4902
    mvi b, $05
    call call4967
    call call4924
.jr41d7:
    gtiw [$ffea], $00
    jre .jr4229
    gtiw [$ffe3], $00
    jre .jr4229
    gtiw [$ffe4], $00
    jre .jr4229
    mvi a, $00
    staw [$ffeb]
.jr41ea:
    gtiw [$ffeb], $00
    jr .jr41f9
.jr41ee:
    gtiw [$ff8b], $1d
    jr .jr41ee
    call call48fc
    dcrw [$ffeb]
    nop
    jr .jr41ea
.jr41f9:
    lhld [$ffe7]
    ldaw [$ffe9]
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
    ani a, $03
    mov b, a
    ldaw [$ffd0]
    ani a, $fc
    ora a, b
    staw [$ffd0]
    dcrw [$ffe9]
    jr .jr4220
    mvi a, $03
    staw [$ffe9]
    inx hl
    shld [$ffe7]
.jr4220:
    dcrw [$ffea]
    nop
    call call43f5
    nop
    jre .jr41d7
.jr4229:
    call call4892
    mvi b, $03
    call call4967
    pop va
    staw [$ffd3]
    ret

call4236:
    offiw [$ffd1], $40
    jr .jr423e
    mvi a, $01
    staw [$ffd3]
.jr423e:
    call call491c
    call call493d
    calt SNDPLAY
    db $0f, $06
.jr4247:
    call call46b7
    call call4a2d
    call call4a9a
    mvi b, $04
    mvi c, $00
    mvi a, $43
    call call4c36
    mvi c, $01
    call call4c36
    lxi hl, text4eb5
    calt DRAWTEXT
    db $06, $01, $95
    lxi hl, text4eba
    calt DRAWTEXT
    db $28, $01, $93
    lxi hl, $ffd3
    calt DRAWHEX
    db $3a, $01, $99
    calt SCRN2LCD
.jr4274:
    calt JOYREAD
    neiw [$ff93], $09
    jmp jr4030.jr4047
    eqiw [$ff93], $08
    jr .jr4288
    oniw [$ff95], $08
    jr .jr4274
    call call42f6
    jre .jr42a7
.jr4288:
    eqiw [$ff93], $02
    jr .jr4294
    oniw [$ff95], $02
    jr .jr4274
    call call42c6
    jr .jr42a1
.jr4294:
    eqiw [$ff93], $10
    jre .jr4274
    oniw [$ff95], $10
    jre .jr4274
    call call42a8
.jr42a1:
    lxi hl, music4faa
    calt MUSPLAY
    jre .jr4247
.jr42a7:
    ret

call42a8:
    call call42e4
    inr b
    nop
    gti a, $05
    jr .jr42b7
    mov a, b
    gti a, $05
    jr .jr42c2
    mvi b, $00
    jr .jr42c2
.jr42b7:
    mov a, b
    gti a, $09
    jr .jr42c2
    mvi b, $00
    mov a, c
    dcr a
    jr .jr42c2
    inr b
    nop
.jr42c2:
    call call42ef
    ret

call42c6:
    call call42e4
    inr c
    nop
    mov a, c
    gti a, $06
    jr .jr42d7
    mvi c, $00
    mov a, b
    nei a, $00
    mvi b, $01
    jr .jr42e0
.jr42d7:
    eqi a, $06
    jr .jr42e0
    mov a, b
    gti a, $05
    jr .jr42e0
    mvi c, $00
.jr42e0:
    call call42ef
    ret

call42e4:
    lxi hl, $ffd3
    calt ACCCLR
    rrd
    mov b, a
    rrd
    mov c, a
    ret

call42ef:
    mov a, b
    rrd
    mov a, c
    rrd
    ret

call42f6:
    mvi a, $01
    staw [$ffd4]
.jr42fa:
    call call436a
    call call491c
    call call4920
.jr4303:
    neiw [$ffdc], $00
    jr .jr4311
    gtiw [$ffe3], $00
    jre .jr4363
    gtiw [$ffe4], $00
    jre .jr4363
.jr4311:
    calt JOYREAD
    neiw [$ff93], $09
    jmp jr4030.jr4047
    eqiw [$ff93], $04
    jr .jr432c
    offiw [$ff95], $04
    jr .jr4325
    oniw [$ffd1], $80
    jre .jr4359
.jr4325:
    call call44bf
    jre .jr4359
    jre .jr434d
.jr432c:
    eqiw [$ff93], $08
    jr .jr433b
    oniw [$ff95], $08
    jr .jr434d
    call call44e4
    jre .jr4369
    jre .jr42fa
.jr433b:
    offiw [$ff93], $3f
    jr .jr4354
    oniw [$ff92], $0f
    jr .jr434d
    call call4a0d
    jr .jr434d
    call call43f5
    jr .jr4359
    jre .jr4303
.jr434d:
    oniw [$ffd1], $80
    jr .jr4359
    aniw [$ffd1], $7f
.jr4354:
    offiw [$ff80], $03
    calf $0e4d
.jr4359:
    gtiw [$ff8b], $1d
    jre .jr4311
    call call48fc
    jre .jr4311
.jr4363:
    call call44fc
    jr .jr4369
    jre .jr42fa
.jr4369:
    ret

call436a:
    call call491c
    neiw [$ffd2], $00
    jr .jr437e
    lxi hl, WRAMC6E8
    lxi de, WRAMC594
    mvi b, $a9
    calt MEMCOPY
    call call4bd3
    jr .jr4381
.jr437e:
    call call46b7
.jr4381:
    call call4a2d
    call call4a9a
    neiw [$ffd2], $00
    jr .jr43a8
    mvi b, $0f
    mvi c, $08
    mvi a, $2e
    call call4c36
    mvi c, $0a
    call call4c36

    lxi hl, text4ee1
    calt DRAWTEXT
    db $0f, $0a, $93

    lxi hl, text4ee4
    calt DRAWTEXT
    db $20, $0a, $95

    jr .jr43c4
.jr43a8:
    mvi b, $11
    mvi c, $08
    mvi a, $29
    call call4c36
    mvi c, $0a
    call call4c36
    lxi hl, text4ebd
    calt DRAWTEXT
    db $11, $0a, $97
    lxi hl, $ffd3
    calt DRAWHEX
    db $29, $0a, $99
.jr43c4:
    mvi b, $04
    mvi c, $18
    mvi a, $43
    call call4c36
    mvi c, $1a
    call call4c36
    lxi hl, text4ec4
    calt DRAWTEXT
    db $06, $1a, $99
    lxi hl, $ffd4
    calt DRAWHEX
    db $40, $1a, $80
    calt SCRN2LCD
    lxi hl, music4f3c
    calt MUSPLAY
    db $44, $86, $49
    oriw [$ffd0], $40
    call call4a2d
    call call48ff
    calt SNDPLAY
    db $0f, $06
    ret

call43f5:
    call call448d
    jre .jr4488
    aniw [$ffd0], $fb
    oriw [$ffd0], $08
    neiw [$ffde], $00
    jr .jr4413
    call call49a4
    call call484e
    oni a, $02
    mvi a, $04
    mvi a, $02
    call call4b18
.jr4413:
    offiw [$ffd0], $80
    jr .jr441f
    oniw [$ff94], $0f
    jr .jr441f
    offiw [$ffd0], $08
    jr .jr442c
.jr441f:
    neiw [$ffde], $00
    mvi a, $0c
    mvi a, $10
    mov b, a
.jr4427:
    ldaw [$ff8b]
    gta a, b
    jr .jr4427
.jr442c:
    oniw [$ffd0], $08
    jr .jr4434
    lxi hl, music4fb1
    calt MUSPLAY
.jr4434:
    call call48ff
    oniw [$ffd0], $08
    jre .jr448c
    lxi hl, WRAMC594
    lxi de, WRAMC63E
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
    inrw [$ffe3]
    nop
    inrw [$ffe4]
    nop
.jr4465:
    mvi a, $87
    call call4878
    call call49f2
    mvi a, $08
    call call4878
    oni a, $02
    jr .jr447b
    dcrw [$ffe3]
    nop
    dcrw [$ffe4]
    nop
.jr447b:
    mvi a, $08
    call call4b18
.jr4480:
    oriw [$ffd0], $10
    aniw [$ffd0], $f7
    jre .jr4413
.jr4488:
    call call4907
    ret
.jr448c:
    rets

call448d:
    call call4992
    call call49c8
    jre .jr44be
    call call49f2
    call call49c8
    jre .jr44be
    call call484e
    offi a, $01
    jr .jr44be
    oni a, $08
    jr .jr44ba
    call call49ad
    call call49f2
    call call49c8
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

call44bf:
    oniw [$ffd0], $10
    jr .jr44e0
    lxi hl, music4f9d
    calt MUSPLAY
    call call4986
    call call491c
    lxi hl, WRAMC63E
    lxi de, WRAMC594
    mvi b, $a9
    calt MEMCOPY
    call call4bd3
    call call4a2d
    call call48ff
    rets
.jr44e0:
    call call4907
    ret

call44e4:
    inrw [$ffd4]
    nop
call44e7:
    gtiw [$ffd4], $05
    jr .jr44f8
    neiw [$ffd2], $00
    oriw [$ffd1], $40
    call call48b0
    call call4970
    ret
.jr44f8:
    calt SNDPLAY
    db $0d, $14
    rets

call44fc:
    eqiw [$ffd2], $00
    jr .jr4518
    call call42e4
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
    call call42ef
    mov a, c
    gti a, $05
    jr .jr451f
    mov a, b
    gti a, $05
    jr .jr451f
.jr4518:
    call call4892
    call call4970
    ret
.jr451f:
    call call4892
    mvi b, $03
    call call4967
    mvi a, $01
    staw [$ffd4]
    rets

call452c:
    calt SNDPLAY
    db $0f, $06
    call call492e
    call call493d
    call call42f6
    ret

call4539:
    calt SNDPLAY
    db $0f, $06
    call call492e
.jr453f:
    mvi a, $02
    staw [$ffe0]
    mvi a, $10
    staw [$ffe1]
    lxi hl, WRAMC6E8
    lxi de, WRAMC594
    mvi b, $a9
    calt MEMCOPY
    call call4bd3
    neiw [$ffdc], $00
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
    aniw [$ffd0], $cf
    calt JOYREAD
    eqiw [$ff93], $09
    jr .jr4582
    lxi hl, WRAMC594
    lxi de, WRAMC6E8
    mvi b, $a9
    calt MEMCOPY
    jmp jr4030.jr4047
.jr4582:
    eqiw [$ff93], $08
    jr .jr4592
    offiw [$ff95], $08
    jre .jr45cd
    offiw [$ffd1], $80
    jre .jr45cd
    jre .jr45c3
.jr4592:
    eqiw [$ff93], $18
    jr .jr459f
    oniw [$ff95], $18
    jr .jr45b7
    call call4694
    jre .jr453f
.jr459f:
    offiw [$ff93], $09
    jr .jr45be
    oniw [$ff93], $36
    jr .jr45ab
    call call45d2
    jr .jr45be
.jr45ab:
    oniw [$ff92], $0f
    jr .jr45b7
    call call4a0d
    jr .jr45be
    call call4664
    jr .jr45c3
.jr45b7:
    oniw [$ffd1], $80
    jr .jr45c3
    aniw [$ffd1], $7f
.jr45be:
    offiw [$ff80], $03
    calf $0e4d
.jr45c3:
    gtiw [$ff8b], $1d
    jre .jr456e
    call call48fc
    jre .jr456e
.jr45cd:
    call call469b
    jr .jr45c3
    ret

call45d2:
    neiw [$ff93], $02
    jr .jr45e2
    neiw [$ff93], $04
    jr .jr45e2
    neiw [$ff93], $20
    jr .jr45e2
    eqiw [$ff93], $10
    ret
.jr45e2:
    offiw [$ffd1], $80
    jre .jr4631
    call call49b6
    call call484e
    eqiw [$ff93], $02
    jr .jr45f7
    call call4632
    jre .jr462e
    jr .jr460f
.jr45f7:
    eqiw [$ff93], $04
    jr .jr4601
    call call463e
    jre .jr462e
    jr .jr460f
.jr4601:
    eqiw [$ff93], $20
    jr .jr460b
    call call464a
    jre .jr462e
    jr .jr460f
.jr460b:
    call call4659
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
    lxi hl, music4faa
    calt MUSPLAY
    aniw [$ffd0], $fb
    call call48ff
    oriw [$ffd0], $20
.jr462e:
    oriw [$ffd0], $10
.jr4631:
    rets

call4632:
    offi a, $01
    ret
    oni a, $08
    jr .jr463b
    dcrw [$ffe2]
    nop
.jr463b:
    mvi a, $01
    rets

call463e:
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

call464a:
    offi a, $08
    ret
    oni a, $02
    jr .jr4653
    ori a, $08
    jr .jr4655
.jr4653:
    mvi a, $08
.jr4655:
    inrw [$ffe2]
    nop
    rets

call4659:
    oni a, $0f
    ret
    oni a, $08
    jr .jr4662
    dcrw [$ffe2]
    nop
.jr4662:
    calt ACCCLR
    rets

call4664:
    call call49b6
    call call49f2
    call call49c8
    jre .jr4690
    aniw [$ffd1], $7f
    offiw [$ffd0], $20
    jr .jr4679
    calt SNDPLAY
    db $0a, $06
.jr4679:
    call call49bf
    aniw [$ffd0], $fb
    call call48ff
    offiw [$ff94], $0f
    mvi a, $13
    mvi a, $09
    mov b, a
.jr468a:
    ldaw [$ff8b]
    gta a, b
    jr .jr468a
    jr .jr4693
.jr4690:
    call call4907
.jr4693:
    ret

call4694:
    calt SNDPLAY
    db $12, $14
    call call40b9
    ret

call469b:
    call call49b6
    call call484e
    offi a, $09
    jr .jr46b3
    mvi a, $04
    call call4878
    lxi hl, WRAMC594
    lxi de, WRAMC6E8
    mvi b, $a9
    calt MEMCOPY
    rets
.jr46b3:
    call call4907
    ret

call46b7:
    call call4c1c
    ldaw [$ffd3]
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
    lti a, $42
    jre .jr473f
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
    jre .jr473f
    lti a, $12
    jre .jr473f
    staw [$ffd9]
    ldax [de+]
    gti a, $00
    jre .jr473f
    lti a, $10
    jre .jr473f
    staw [$ffda]
    ldax [de+]
    gti a, $02
    jre .jr473f
    lti a, $14
    jre .jr473f
    staw [$ffdb]
    call call49e5
    oriw [$ffd1], $01
.jr4706:
    ldax [de]
    oniw [$ffd1], $01
    jr .jr470c
    calt ACC4RAR
.jr470c:
    ani a, $0f
    nei a, $0f
    jre .jr4738
    push de
    mov b, a
    calf $0c72
    ani a, $03
    staw [$ffee]
    mov a, b
    ani a, $03
    inr a
    nop
    staw [$ffef]
    call call4740
    jr .jr473d
    call call4760
    jr .jr473d
    ldaw [$ffd1]
    xri a, $01
    staw [$ffd1]
    pop de
    oni a, $01
    jr .jr4736
    inx de
.jr4736:
    jre .jr4706
.jr4738:
    inx de
    call call47db
    jr .jr473f

.jr473d:
    pop de
.jr473f:
    ret

call4740:
    eqiw [$ffee], $03
    jr .jr475f
    eqiw [$fff0], $00
    jr .jr4750
    call call49d9
    gtiw [$ffe6], $11
    jr .jr4750
    ret
.jr4750:
    call call499b
    eqiw [$ffef], $02
    jr .jr475b
    mvi a, $04
    staw [$ffee]
.jr475b:
    mvi a, $01
    staw [$ffef]
.jr475f:
    rets

call4760:
    ldaw [$ffef]
    mov b, a
    ldaw [$fff0]
    mov c, a
    subnb a, b
    jr .jr4779
    staw [$fff0]
    call call479a
    oni a, $02
    jr .jr4777
    ldaw [$ffe4]
    add a, b
    staw [$ffe4]
.jr4777:
    jre .jr4799
.jr4779:
    xri a, $ff
    inr a
    nop
    staw [$ffef]
    mov a, c
    gti a, $00
    jr .jr4790
    mov b, a
    call call479a
    oni a, $02
    jr .jr4790
    ldaw [$ffe4]
    add a, b
    staw [$ffe4]
.jr4790:
    call call49d9
    gtiw [$ffe6], $11
    jre call4760
    ret
.jr4799:
    rets

call479a:
    ldaw [$ffee]
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
    ldaw [$ffd1]
    xri a, $02
    staw [$ffd1]
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
    ldaw [$ffe5]
    add a, b
    staw [$ffe5]
    pop va
    ret

call47db:
    call call49e5
.jr47de:
    ldax [de+]
    nei a, $00
    jre .jr4829
    staw [$ffef]
    push de
.jr47e7:
    ldaw [$ffef]
    mov b, a
    ldaw [$fff0]
    mov c, a
    subnb a, b
    jre .jr4819
    nei a, $00
    jre .jr4819
    staw [$fff0]
    ldaw [$ffe5]
    add a, b
    staw [$ffe5]
    call call484e
    offi a, $05
    jr .jr4815
    oni a, $02
    jr .jr480a
    dcrw [$ffe4]
    nop
    jr .jr480d
.jr480a:
    inrw [$ffe3]
    nop
.jr480d:
    inrw [$ffe2]
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
    staw [$ffef]
    call call49d9
    gtiw [$ffe6], $11
    jre .jr47e7
    pop de
.jr4829:
    ret

call482a:
    ldaw [$ffe5]
    dcr a
    nop
    clc
    rar
    aniw [$ffd1], $fd
    sknc
    oriw [$ffd1], $02
    mvi d, $00
    mov e, a
    push de
    ldaw [$ffe6]
    dcr a
    nop
    mvi e, $0a
    calt MULTIPLY
    pop de
    calt ADDRHLDE
    lxi de, WRAMC594
    calt ADDRHLDE
    ret

call484e:
    call call482a
    ldax [hl]
    offiw [$ffd1], $02
    calt ACC4RAR
    ani a, $0f
    ret

call4859:
    oniw [$ffd1], $02
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

call4892:
    lxi hl, music4f5d
    calt MUSPLAY
    call call4986
    mvi b, $16
    mvi c, $1a
    mvi a, $21
    call call4c36
    mvi c, $1c
    call call4c36
    lxi hl, text4ecd
    calt DRAWTEXT
    db $18, $1c, $95
    calt SCRN2LCD
    ret

call48b0:
    lxi hl, music4f7c
    calt MUSPLAY
    call call4986
    call call48df
    mvi b, $0f
    mvi c, $22
    mvi a, $2f
    call call4c36
    mvi c, $24
    call call4c36
    lxi hl, text4eda
    calt DRAWTEXT
    db $11, $24, $82
    lxi hl, text4edc
    calt DRAWTEXT
    db $1b, $24, $92
    lxi hl, text4ede
    calt DRAWTEXT
    db $2b, $24, $93
    calt SCRN2LCD
    ret

call48df:
    mvi b, $0a
    mvi c, $08
    mvi a, $37
    call call4c36
    mvi c, $0a
    call call4c36
    lxi hl, text4ed2
    calt DRAWTEXT
    db $0c, $0a, $94
    lxi hl, text4ed6
    calt DRAWTEXT
    db $28, $0a, $94
    ret

call48fc:
    call call498b

call48ff:
    call call4924

call4902:
    call call4a9a
    calt SCRN2LCD
    ret

call4907:
    offiw [$ffd1], $80
    jr .jr4914
    oriw [$ffd1], $80
    offiw [$ff80], $03
    calf $0e4d
    jr .jr4918
.jr4914:
    offiw [$ff80], $03
    jr .jr491b
.jr4918:
    calt SNDPLAY
    db $01, $ff
.jr491b:
    ret

call491c:
    calt ACCCLR
    staw [$ffd0]
    ret

call4920:
    calt ACCCLR
    staw [$ffd1]
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
    staw [$ffd9]
    staw [$ffda]
    mvi a, $13
    staw [$ffdb]
    ret

call4939:
    calt ACCCLR
    staw [$ffdc]
    ret

call493d:
    calt ACCCLR
    staw [$ffe0]
    ret

call4941:
    calt ACCCLR
    staw [$ffde]
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
    neiw [$ff93], $08
    jr .jr4985
    eqiw [$ff93], $01
    jr .jr4981
    lxi hl, music4faa
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
    ldaw [$ffd0]
    xri a, $04
    staw [$ffd0]
    ret

call4992:
    ldaw [$ffdc]
    staw [$ffe5]
    ldaw [$ffdd]
    staw [$ffe6]
    ret

call499b:
    ldaw [$ffe5]
    staw [$ffdc]
    ldaw [$ffe6]
    staw [$ffdd]
    ret

call49a4:
    ldaw [$ffde]
    staw [$ffe5]
    ldaw [$ffdf]
    staw [$ffe6]
    ret

call49ad:
    ldaw [$ffe5]
    staw [$ffde]
    ldaw [$ffe6]
    staw [$ffdf]
    ret

call49b6:
    ldaw [$ffe0]
    staw [$ffe5]
    ldaw [$ffe1]
    staw [$ffe6]
    ret

call49bf:
    ldaw [$ffe5]
    staw [$ffe0]
    ldaw [$ffe6]
    staw [$ffe1]
    ret

call49c8:
    gtiw [$ffe5], $01
    jr .jr49d7
    ltiw [$ffe5], $13
    jr .jr49d7
    gtiw [$ffe6], $01
    jr .jr49d7
    ltiw [$ffe6], $11
.jr49d7:
    ret
    rets

call49d9:
    ldaw [$ffdb]
    staw [$fff0]
    ldaw [$ffd9]
    staw [$ffe5]
    inrw [$ffe6]
    nop
    ret

call49e5:
    ldaw [$ffdb]
    staw [$fff0]
    ldaw [$ffd9]
    staw [$ffe5]
    ldaw [$ffda]
    staw [$ffe6]
    ret

call49f2:
    ldaw [$ffd0]
    oni a, $02
    jr .jr4a02
    oni a, $01
    jr .jr49fe
    dcrw [$ffe6]
    nop
    jr .jr4a0c
.jr49fe:
    inrw [$ffe6]
    nop
    jr .jr4a0c
.jr4a02:
    oni a, $01
    jr .jr4a09
    dcrw [$ffe5]
    nop
    jr .jr4a0c
.jr4a09:
    inrw [$ffe5]
    nop
.jr4a0c:
    ret

call4a0d:
    ldaw [$ffd0]
    ani a, $fc
    eqiw [$ff92], $01
    jr .jr4a18
    ori a, $03
    jr .jr4a2a
.jr4a18:
    eqiw [$ff92], $02
    jr .jr4a1f
    ori a, $01
    jr .jr4a2a
.jr4a1f:
    eqiw [$ff92], $04
    jr .jr4a26
    ori a, $02
    jr .jr4a2a
.jr4a26:
    eqiw [$ff92], $08
    ret
.jr4a2a:
    staw [$ffd0]
    rets

call4a2d:
    calt SCR2CLR
    oniw [$ffd0], $40
    mvi a, $0b
    mvi a, $01
    staw [$ffee]
.jr4a37:
    ldaw [$ffd9]
    staw [$ffe5]
.jr4a3b:
    ldaw [$ffe5]
    mov c, a
    ldaw [$ffd9]
    mov b, a
    ldaw [$ffdb]
    add a, b
    gta a, c
    jre .jr4a8c
    ldaw [$ffda]
    staw [$ffe6]
    call call482a
.jr4a50:
    gtiw [$ffe6], $11
    jr .jr4a6a
    oniw [$ffd0], $40
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
    inrw [$ffe5]
    nop
    jre .jr4a3b
.jr4a6a:
    ldax [hl]
    offiw [$ffd1], $02
    calt ACC4RAR
    ani a, $0f
    mov b, a
    ldaw [$ffee]
    ana a, b
    oni a, $0b
    jr .jr4a84
    offi a, $08
    mvi a, $08
    push hl
    call call4b18
    pop hl
.jr4a84:
    inrw [$ffe6]
    nop
    mvi e, $0a
    calt ADDRHLE
    jre .jr4a50
.jr4a8c:
    oniw [$ffd0], $40
    jr .jr4a99
    mvi a, $0a
    staw [$ffee]
    aniw [$ffd0], $bf
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
    oniw [$ffd0], $08
    jr .jr4abb
    neiw [$ffde], $00
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
    neiw [$ffdc], $00
    jr .jr4adc
    call call4992
    offiw [$ffd0], $04
    jr .jr4adc
    call call4bab
    calt ACCCLR
    stax [hl]
    ldaw [$ffd0]
    oni a, $08
    jr .jr4adb
    ani a, $03
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
    neiw [$ffe0], $00
    jre .jr4b17
    call call49b6
    call call4bab
    push hl
    call call484e
    pop hl
    nei a, $00
    jr .jr4b0f
    oniw [$ffd0], $04
    jr .jr4afa
    mvi a, $07
    stax [hl]
    jr .jr4b16
.jr4afa:
    oniw [$ff92], $0f
    jr .jr4b17
    call call4a0d
    jr .jr4b17
    offiw [$ffd1], $80
    jr .jr4b17
    oniw [$ff93], $3f
    jr .jr4b13
    offiw [$ffd0], $10
    jr .jr4b13
    jr .jr4b17
.jr4b0f:
    offiw [$ffd0], $04
    jr .jr4b17
.jr4b13:
    mvi a, $06
    stax [hl]
.jr4b16:
    calt OBJDRAW
.jr4b17:
    ret

call4b18:
    lxi hl, data4eec
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
    ldaw [$ffe6]
    call call4951
    dcr a
    jr .jr4b3a
    lxi hl, $ffb5
    jr .jr4b3d
.jr4b3a:
    mvi e, $4b
    calt $a6
.jr4b3d:
    ldaw [$ffe5]
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
    staw [$ffec]
.jr4b56:
    ldax [hl]
    mov b, a
    ldax [de]
    mov c, a
    ldaw [$ffe6]
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
    ldaw [$ffe6]
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
    dcrw [$ffec]
    jre .jr4b56
.jr4ba1:
    ret

call4ba2:
    lxi hl, OBJ.O0.X
    mvi a, $80
    mvi b, $23
    calt MEMSET
    ret

call4bab:
    lxi hl, OBJ.O0.X
    ldaw [$ffe5]
    dcr a
    nop
    call call495e
    stax [hl+]
    ldaw [$ffe6]
    dcr a
    nop
    call call495e
    sui a, $02
    stax [hl+]
    ret

call4bc1:
    oniw [$ffd0], $02
    jr .jr4bc6
    inx hl
.jr4bc6:
    mvi b, $02
    oniw [$ffd0], $01
    jr .jr4bce
    mvi b, $fe
.jr4bce:
    ldax [hl]
    add a, b
    stax [hl]
    ret

call4bd3:
    call call4c2a
    ldaw [$ffd9]
    staw [$ffe5]
.jr4bda:
    ldaw [$ffe5]
    mov c, a
    ldaw [$ffd9]
    mov b, a
    ldaw [$ffdb]
    add a, b
    gta a, c
    jre .jr4c1b
    ldaw [$ffda]
    staw [$ffe6]
.jr4bec:
    gtiw [$ffe6], $11
    jr .jr4bf4
    inrw [$ffe5]
    nop
    jr .jr4bda
.jr4bf4:
    call call484e
    oni a, $02
    jr .jr4bfd
    inrw [$ffe4]
    nop
.jr4bfd:
    oni a, $08
    jr .jr4c06
    inrw [$ffe3]
    nop
    inrw [$ffe2]
    nop
.jr4c06:
    oni a, $04
    jr .jr4c0d
    call call499b
    jr .jr4c16
.jr4c0d:
    eqi a, $0a
    jr .jr4c16
    dcrw [$ffe4]
    nop
    dcrw [$ffe3]
    nop
.jr4c16:
    inrw [$ffe6]
    nop
    jre .jr4bec
.jr4c1b:
    ret

call4c1c:
    lxi hl, WRAMC594
    mvi b, $a9
    calt MEMCLR
    staw [$ffd1]
    staw [$ffd9]
    staw [$ffda]
    staw [$ffdb]

call4c2a:
    calt ACCCLR
    staw [$ffdc]
    staw [$ffdd]
    staw [$ffe2]
    staw [$ffe3]
    staw [$ffe4]
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

text4e82:
    #d $6a6b6c6d6e6f70717273

text4e8c:
    #d $7475767778797a7b7c7d

text4e96:
    #d smalltext("STORE")

text4e9b:
    #d smalltext("KEEPERS")

text4ea2:
    #d $64, largetext("PLAY")

text4ea7:
    #d $64, largetext("ED")

text4eaa:
    #d largetext("I")

text4eab:
    #d largetext("TOR")

text4eae:
    #d $64, largetext("E"), $65

text4eb1:
    #d largetext("PLAY")

text4eb5:
    #d largetext("START")

text4eba:
    #d largetext("NO"), $66

text4ebd:
    #d $67, largetext("NO")
    #d $68000069

text4ec4:
    #d largetext("CHALLENGE")

text4ecd:
    #d largetext("GOOD!")

text4ed2:
    #d largetext("GAME")
text4ed6:
    #d largetext("OVER")

text4eda:
    #d largetext("G")
text4edb:
    #d largetext("I")
text4edc:
    #d largetext("VE")
text4ede:
    #d largetext("UP?")

text4ee1:
    #d $67, largetext("E"), $65

text4ee4:
    #d largetext("PLAY"), $69

text4ee9:
    #d largetext("DIS")

data4eec:
    #d $0f0f0f0f
    #d $000606000000000006090906

data4efc:
    #d $00000000
    #d $0a07070a00000000020f0f0200000000
    #d $020f0f0200000000020f0f0200000000
    #d $020f0f0200060600060909060f0f0f0f
    #d $090606090f0f0f0f00000000

music4f3c:
    #d $0e080f14
    #d $0e080f1403140d080e140c080e140314
    #d $0a080a140a080c140d140e0aff

music4f5d:
    #d $060a06
    #d $0a0a0a0d1e080a080a0b0a0f1e110a11
    #d $0a110a110a0f0a110a121eff

music4f7c:
    #d $060a080a
    #d $0a0a0b140f0a0b140f0a1214100a0f14
    #d $0d0a0b0a080a060a0a140b28ff

music4f9d:
    #d $0a0a08
    #d $0a060a0a0a080a060aff

music4faa:
    #d $12021600000fff

music4fb1:
    #d $0a080d010001ff

data4fb8:
    #d $7c5fd55a82a89ffd
    #d $7f0aaabff27f02a5daa6327fc276a27f
    #d $c00d957f02895daa

levels:
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
    dw level66

level01:
    #d $05050a77
    #d $143141404050704142532c7270506342
    #d $4304904304a430743f170e06041000

level02:
    #d $02
    #d $0511753324362760434061950436c419
    #d $5333a731619414314041941431407517
    #d $732f27110f0101040d030c020200

level03:
    #d $0203
    #d $10327743243243240404040432430404
    #d $32432432534040634316875076a14304
    #d $25933424a141c62587153161731f3a02
    #d $0f0f020e021c020f00

level04:
#if VERSION == VERSION_PRE0125 {
    #d $0204103277774c
    #d $51953339524140519605379404350417
    #d $04050414315043531431532415143341
    #d $5143377f270b03031b022e1200
} #else {
    #d $0204103277774c
    #d $51953339524140519605379404350417
    #d $04050414315043531431532415143341
    #d $514337733f270b03031b022e1200
}

level05:
    #d $0204
    #d $11374333424333424331626334324316
    #d $0406077240605195332c097507041943
    #d $4317537730f027130f032d0300

level06:
    #d $05040a
    #d $27606306240405148350494071940416
    #d $915248424150404c414314143051761f
    #d $23010107150b110300

level07:
    #d $02031133773304
    #d $314330431417731405a17050404b3250
    #d $405a15250507731c4316070531433432
    #d $4374325243337430f02d020e02310110
    #d $20021000

level08:
    #d $03050e777149143079143259
    #d $14071593c05159140437705341433141
    #d $4343041777f023030a200d0207030202
    #d $00

level09:
    #d $020210173334177614333414142430
    #d $4143243714041705c432525314042406
    #d $3330407077504b14334b14334b14334a
    #d $7334a433274331f02704020703050902
    #d $0d0f02020e030c05020200

level10:
    #d $03030e3272
    #d $7717425b815305a40630604040404343
    #d $40414342404243414043424050714343
    #d $051424315c42432760f02d0f0f0f0f0f
    #d $0f0f00

level11:
    #d $03040e077705c4162632435304
    #d $3170752707507370940433a40437a404
    #d $3405a4041607507331f0210507081b06
    #d $0e0202180100

level12:
    #d $02031133743334274334
    #d $040514334327750625b15307b330504b
    #d $1530c407743053304314330605043324
    #d $34332750f02d141e030d02010e031010
    #d $0200

level13:
    #d $0205113377330430c43304141533
    #d $0430433153417742407b15326a3325b1
    #d $77775330f02c020f030e020f11030d03
    #d $00

level14:
    #d $04040c75160491405c691625933591
    #d $40425960427424242424242432424152
    #d $42774f2c010c0c08030a03080300

level15:
    #d $0305
    #d $0f1743314277414332753435240537a2
    #d $52414a432414a41c41517772f0220210
    #d $03011e09010300

level16:
#if VERSION == VERSION_PRE0125 {
    #d $020310076075143063
    #d $41415043404404333040430424263075
    #d $86
    #d $314104a5c42524a531424a6141424a40
    #d $414174a404331a407762433274f02a01
    #d $070202020209020f010d11010f120d01
    #d $1400
} #else {
    #d $020310076075143063
    #d $41415043405043330404304242630758
    #d $631424a5c42524a531424a6141424a40
    #d $414174a404331a407762433274f02a01
    #d $070202020209020f010d11010f120d01
    #d $1400
}

level17:
    #d $0103123327307751426242517430
    #d $4324c050424251a50424341585040704
    #d $07485041604141485041434041485330
    #d $40414850416050414850731417317530
    #d $77331f30090108120e011e2700

level18:
    #d $03030f
    #d $73324163304363243163043362433142
    #d $431425143530414c0730505040483084
    #d $1406ba5042bb8407bb843776f0200f02
    #d $0d02020b02020b020d0601011b010101
    #d $011901010101010100

level19:
    #d $03050e73174977
    #d $95bbb5333530c31533353335bbb59779
    #d $74317f1d020602050202020202030202
    #d $02020205020202020203020202020205
    #d $02060200

level20:
    #d $03020e0774304b2534848435
    #d $15b4040c5040b4141630415160632404
    #d $33414040431504041615140435050504
    #d $34304163163417431732f02429040b08
    #d $0302020b022605090200

level21:
    #d $020211337743
    #d $163a431431a4314160a430607a430430
    #d $5a407431762431425c33317631743043
    #d $14330706333414333041433304143330
    #d $730f5c010110020d020c0305030a0102
    #d $0e00

level22:
    #d $03030f743174c177163334040404
    #d $17140431705041504304053043040424
    #d $3140404274070742424314a34314b414
    #d $314b7317530f21081708050702070321
    #d $1f00

level23:
    #d $04020c7775305163307405353043
    #d $53040742404261414351414352940779
    #d $24c5b841406b4379537774f01d040b01
    #d $070a0101100d05031a0d0d00

level24:
    #d $04020d31
    #d $73074143531425350604c34340705341
    #d $4b43414b43414b30504a043040753043
    #d $1426314163241433072f22080c02040f
    #d $0a020e0b010c0c021800

level25:
    #d $020411177330
    #d $4314330431743073243041504343043c
    #d $40407405053314042414242627774b43
    #d $324b433275332f27150f031f02020100

level26:
    #d $02031130743334c17637334163324142
    #d $42407414073341433304143060607150
    #d $4b8415314b82532b8777b84331762f2a
    #d $030d0102020d0b07040703030408061b
    #d $020e0400

level27:
    #d $01021217333141774305150c
    #d $42430424327143143417250433514140
    #d $43353315074304041414251616143414
    #d $b30437b97314b73304a53334a4333074
    #d $331f3a03020b0305020a050213010106
    #d $05030a02031700

level28:
    #d $0604090730417141c1
    #d $405150608484150a2508484162405063
    #d $424041424252740f140d050b01011a00

level29:
    #d $03040f07633414174251414a6042414a
    #d $1404242a14042414a084042417753336
    #d $1430424075151c431431531770f0300e
    #d $03010c120b08020a01120100

level30:
    #d $04020d17
    #d $7434a4a434ba434ba434ba434ba43626
    #d $31424375076332533263305043304143
    #d $c34141741417270f1002020208020208
    #d $020202080202080202023a0202020206
    #d $0202020602020202080200

level31:
    #d $0203113774
    #d $33432433430407074143414049415324
    #d $0494334140494150705049505340414a
    #d $2506072533176c425040430772433374
    #d $f0270102011210030a01133400

level32:
    #d $04040d
    #d $777532b532b532b532b532b532b532b5
    #d $32b532b5c31b7775f010020202060202
    #d $02080202020602020208020202060202
    #d $02080202020602020208020202060202
    #d $0200

level33:
    #d $05050b3075074824041495040429
    #d $240414084074050415330504041415c1
    #d $77731f25180705010600

level34:
    #d $03020f774314
    #d $324314327250704142504c5342433142
    #d $41405342414053773241404252b40404
    #d $2404908404240405a407434a43052743
    #d $1743f04d01010203010d100c01010239
    #d $00

level35:
    #d $010212317763243042531433943143
    #d $04049417761941433394140404150404
    #d $94142430419405042761631434253414
    #d $342531537517433140c4333173331f2c
    #d $172011110e03110a07111100

level36:
    #d $02031133
    #d $7743162424314c33707531586251515b
    #d $a153508514143052430b961517740427
    #d $3304304331430433176330f02a030201
    #d $2209070606050b0d11110200

level37:
    #d $01031277
    #d $3314a27724b330514b85242414b84143
    #d $04176153604336340434343040416051
    #d $407041432424170404152424c3334274
    #d $276327432f2e1103120d06130804061d
    #d $030f0609050400

level38:
    #d $020210375331434336
    #d $050431631773341a50414241a5041431
    #d $a50414241a50414241a504c042770430
    #d $531404304324060632430433076330f0
    #d $35030c020d050e0d1103010e0e020f00

level39:
    #d $02031027753149142431493143149141
    #d $72761415143334141415141740517063
    #d $074041504324350c3242750507634343
    #d $317532f083110305070300

level40:
    #d $0202103273
    #d $33415332425331435326305273340614
    #d $07414043404b14040430b404043404b4
    #d $0406170604270c250530632432415243
    #d $2774f039010e030f220a0d061f050c00

level41:
    #d $01061277776330504a5304314a530405
    #d $24a5242c30a5314171852533a77776f0
    #d $26020106090503010901020f02020217
    #d $00

level42:
    #d $03030e7776250b9516094840514195
    #d $80860414043533040614041615c04043
    #d $41514050404153043172405151743043
    #d $2760f02c110b030b05040a0905040516
    #d $00

level43:
    #d $020311777704333140404075304040
    #d $433041404043c35060404306a504335a
    #d $506315a53040505a752505a437430633
    #d $4304331761f0380202020c020e02020e
    #d $020e01010200

level44:
    #d $01021232763076304304
    #d $3041c143042427740406b9524043b950
    #d $4040406b930627060406143430404043
    #d $30415040432624040743304043060624
    #d $0432430424327714333170f02d020901
    #d $262e07070a020101050a0205011000

level45:
    #d $05
    #d $050b2743626051c34041505061848350
    #d $48484251a1750406342431743f1b0211
    #d $040a080c00

level46:
    #d $05050a0731417405151404
    #d $2c2404251406850604a3405934177f16
    #d $0b020b130200

level47:
    #d $03020e74330425334341
    #d $714371414331416c0430514153150435
    #d $05084041405248406395841434b84143
    #d $4b841417741414331733f02c0f010204
    #d $0a10020710030d10090100

level48:
    #d $0203107407
    #d $314a4041724a630424b530605b531406
    #d $a0530404053430404150406074240433
    #d $53c33052433717516140537363330f29
    #d $0f03100f020f1705030904050a020102
    #d $00

level49:
    #d $010312327073261404143736143433
    #d $34161533414324250414043432414330
    #d $707631c50a40435070a40434b50a4040
    #d $42b794071b41737731f02c0608041203
    #d $030e0b0101010301020b0201120e0110
    #d $1500

level50:
    #d $05050a7740425140404304041941
    #d $405048c850506873352504076243074f
    #d $180207130400

level51:
    #d $05040b3170760c404334
    #d $0435140504a404141a14140480840504
    #d $24041404334041760731f01c0904050c
    #d $1b050300

level52:
    #d $060409707416153251404160
    #d $404061484c051a151484075243404043
    #d $4243740f17130f021c00

level53:
    #d $04040c327417
    #d $527382534084061428416078c1404348
    #d $70405048141430840416314341743730
    #d $f0210504031e042100

level54:
    #d $04050d75175372
    #d $533040614062404360406241a051430a
    #d $5174970c42717330f01c041105010616
    #d $0300

level55:
    #d $04020c763040b43040b43040b430
    #d $50775331524317042414140431414040
    #d $4341404361406143434c4372432741f0
    #d $320c020e01020c09010d010a00

level56:
    #d $060409
    #d $073041430416242c4150480714915294
    #d $06058140436041624143073f141d0205
    #d $011200

level57:
    #d $0103123077433043a43304041a
    #d $433040519437530634a30c5314943177
    #d $4a43335a314040505173241514143317
    #d $415276327431f04f020d02020f02020f
    #d $020f0204020d02020f0400

level58:
    #d $05050b0743
    #d $140c0750404a24040a42605305240753
    #d $2417404043142431741f1c120402080a
    #d $00

level59:
    #d $03030e307531635304251426051404
    #d $153094041424049404142c0494073049
    #d $42634934060580406241614305305317
    #d $62f02e1b02020901050901130900

level60:
    #d $0302
    #d $0e775343370407504160433153243730
    #d $41614150415250430c43431634043143
    #d $4052404251740424330424ba624ba430
    #d $7742f02e0202030c0803011108050b02
    #d $0f00

level61:
    #d $0202113777304331534140431434
    #d $1404150c425050424052430424043424
    #d $30404353250434141534343524040753
    #d $042404b41770484a05334b24334b2433
    #d $77433f2c01020903140d03100e02160f
    #d $010b0100

level62:
    #d $010412330731774153533275
    #d $250525a50432405a5043c142a5240630
    #d $a53315b7337614176337333f28071c01
    #d $020201021c06010a0301030c00

level63:
    #d $04030c
    #d $073341752431c4150585041414080407
    #d $2a426040824060584351584074304141
    #d $414304176143371f1f0d140f0e110102
    #d $00

level64:
    #d $05050b07741424241432405324043c
    #d $2404270614b8061b8040775f19010101
    #d $01070202060b00

level65:
    #d $070506074040c04042
    #d $4042404a6a535351761f0e0101051701
    #d $00

level66:
    #d $03020e3163175c7414bb9405bb96bb
    #d $b5bbb769750433141433141433141433
    #d $141433140533163335304317776f2d01
    #d $01010101010107070702010101022302
    #d $01010102060101050101080101010802
    #d $050208010101080101050101
