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
    lxi hl, music
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
    lxi de, $c4b0
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
    lxi hl, $c6e8
    mvi b, $a9
    calt MEMCLR
    mvi c, $01
.jr40c1:
    mov a, c
    eqi a, $01
    lxi hl, $c788
    lxi hl, $c6e8
    mvi a, $11
    mvi b, $09
    calt MEMSET
    dcr c
    jr .jr40c1
    lxi hl, $c6f2
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

    lxi hl, $c2fb
    mvi a, $f8
    stax [hl+]
    mvi a, $04
    stax [hl]
    lxi hl, $c32a
    stax [hl+]
    mvi a, $f8
    stax [hl]
    lxi hl, $c346
    mvi a, $1f
    stax [hl+]
    mvi a, $20
    stax [hl]
    lxi hl, $c375
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
    lxi hl, music
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
    lxi hl, data4ee9
    calt DRAWTEXT
    db $12, $04, $03
    lxi hl, data4ee4
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
    lxi hl, music
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
    lxi hl, $c6e8
    lxi de, $c594
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

    lxi hl, data4ee1
    calt DRAWTEXT
    db $0f, $0a, $93

    lxi hl, data4ee4
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
    lxi hl, data4f3c
    calt $86
    db $44, $86, $49
    oriw [$ffd0], $40
    call call4a2d
    call call48ff
    calt SNDPLAY
    db $0f, $06
    ret

call43f5:
    call call448d
    #d $4e8e05d0fb15d008
    #d $65de00cf
    call call49a4
    call call484e
    #d $470269046902
    call $4b18
    #d $55d080c845940fc455d008cd65
    #d $de00690c69101a288b60aafb45d008c4
    #d $34b14f83
    call call48ff
    #d $45d0084e503494c524
    #d $3ec66aa995
    call call4992
    #d $698b
    call call4878
    call call49f2
    call call499b
    #d $6904
    call call4878
    #d $47084e244702c620
    #d $e30020e4006987
    call call4878
    call call49f2
    #d $690844
    #d $78484702c630e30030e4006908
    call $4b18
    #d $15d01005d0f74f8b
    call call4907
    #d $08
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
    #d $45
    #d $d010dd349d4f83448649441c49343ec6
    #d $2494c56aa99544d34b442d4a44ff4818
    #d $440749
    ret

call44e4:
    #d $20d40025d405cd65d20015d1
    #d $4044b04844704908820d14
    rets

call44fc:
    #d $75d200d8
    #d $44e4420a41002709c38543001a44ef42
    #d $0b2705cb0a2705c74492484470490844
    #d $92486a03446749690138d4
    rets

call452c:
    #d $820f06442e49443d4944f642
    ret

call4539:
    #d $820f06442e4969
    #d $0238e0691038e134e8c62494c56aa995
    #d $44d34b65dc00cb449249698b44784844
    #d $3949441c49442049442d4a44ff4805d0
    #d $cf84759309cc3494c524e8c66aa99554
    #d $4740759308cc5595084e4255d1804e3d
    #d $4e31759318c9459518dd4494464fa055
    #d $9309db459336c444d245d345920fc844
    #d $0d4acb446446cc45d180c805d17f5580
    #d $037e4d258b1d4fa644fc484fa1449b46
    #d $f208659302cc659304c8659320c47593
    #d $100855d1804e4a44b649444e48759302
    #d $c64432464e38d8759304c6443e464e2e
    #d $ce759320c6444a464e24c4445946df48
    #d $0e445948480f470f6904570869084418
    #d $4b34aa4f8305d0fb44ff4815d02015d0
    #d $10185701084708c330e2006901185702
    #d $084708c31702c26902185708084702c3
    #d $1708c2690820e20018470f084708c330
    #d $e200851844b64944f24944c8494e2105
    #d $d17f55d020c3820a0644bf4905d0fb44
    #d $ff4855940f691369091a288b60aafbc3
    #d $4407490882121444b9400844b649444e
    #d $485709cf69044478483494c524e8c66a
    #d $a99518440749
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
    #d $28ef1a28f01b60b2d038f0449a474702
    #d $c628e460c238e44e2016ff410038ef0b
    #d $2700cd1a449a474702c628e460c238e4
    #d $44d94925e6114fc8081828ee6703c577
    #d $04c46906690467004e26480e481e442a
    #d $48481f0a1b480f481e53c1d2480e4459
    #d $4828d1160238d15702c132480feb481f
    #d $480e28e560c238e5480f
    ret

call47db:
    call call49e5
    #d $2c67
    #d $004e4638ef482e28ef1a28f01b60b24e
    #d $2867004e2438f028e560c238e5444e48
    #d $5705d24702c430e400c320e30020e200
    #d $1708445948482f4fc516ff410038ef44
    #d $d94925e6114fc0482f
    ret

call482a:
    #d $28e55100482a
    #d $483105d1fd481a15d1026c001d482e28
    #d $e651006d0a93482f8b2494c58b
    ret

call484e:
    call call482a
    #d $2b55d102a0070f0845d102cd482a48
    #d $304830483048306a0fc26af0480e2b60
    #d $8a1a480f609a3b
    ret

call4878:
    #d $480e444e481a480f
    #d $4780c3608ac2609a070f480e44594848
    #d $0f
    ret

call4892:
    #d $345d4f834486496a166b1a692144
    #d $364c6b1c44364c34cd4e9b181c958108
    #d $347c4f8344864944df486a0f6b22692f
    #d $44364c6b2444364c34da4e9b11248234
    #d $dc4e9b1b249234de4e9b2b249381086a
    #d $0a6b08693744364c6b0a44364c34d24e
    #d $9b0c0a9434d64e9b280a94
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
    lxi hl, music
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
    #d $25e501cb35e513c7
    #d $25e601c335e6110818

call49d9:
    #d $28db38f028d938e520e600
    ret

call49e5:
    #d $28db38f028d938e528da38
    #d $e608

call49f2:
    #d $28d04702cb4701c430e600ce20e6
    #d $00ca4701c430e500c320e500
    ret

call4a0d:
    #d $28d007
    #d $fc759201c31703d2759202c31701cb75
    #d $9204c31702c47592080838d0
    rets

call4a2d:
    #d $8645d0
    #d $40690b690138ee28d938e528e51b28d9
    #d $1a28db60c260ab4e4328da38e6442a48
    #d $25e611d645d040cd483e442449908148
    #d $3f258b04fc20e5004fd12b55d102a007
    #d $0f1a28ee608a470bcb57086908483e44
    #d $184b483f20e6006d0a8d4fc445d040c9
    #d $690a38ee05d0bf4f9e
    ret

call4a9a:
    #d $9044a54a44bc
    #d $4a44dd4a0845d008d265de00ce44a449
    #d $44ab4b69053f3344c14b920865dc00dc
    #d $44924955d004d544ab4b853b28d04708
    #d $ca070341003b333344c14b920865e000
    #d $4e3544b64944ab4b483e444e48483f67
    #d $00dd45d004c469073bdc45920fd9440d
    #d $4ad555d180d145933fc955d010c5c855
    #d $d004c469063b920834ec4e6d046a0348
    #d $31481ac9480e8d480f52f44e74483e28
    #d $e644514951c434b5ffc36d4b9328e51a
    #d $5100445e491d8d2458c28b482f0a3713
    #d $6902690338ec2b1a2a1b28e647014e2d
    #d $2701ce0b7c7007c01b0a073f609b3b28
    #d $e637114e26483e482e6d4b8d2b07fc1a
    #d $482f2a7c720703609a3b483fce0b4830
    #d $4830073c1b0a07c3609b3b322230ec4f
    #d $b5
    ret

call4ba2:
    #d $3470c569806a239f083470c528e5
    #d $5100445e493d28e65100445e4966023d
    #d $0845d002c1326a0245d001c26afe2b60
    #d $c23b
    ret

call4bd3:
    #d $442a4c28d938e528e51b28d91a
    #d $28db60c260ab4e3328da38e625e611c4
    #d $20e500e6444e484702c320e4004708c6
    #d $20e30020e2004704c4449b49c9770ac6
    #d $30e40030e30020e6004fd1
    ret

call4c1c:
    #d $3494c56a
    #d $a98a38d138d938da38db8538dc38dd38
    #d $e238e338e4
    ret

call4c36:
    #d $480e481e51c24e4c480e
    #d $481e0b
    call call4949
    call call495a
    #d $1a0b60e21a1b43
    #d $008552c1c5482b4830f81c69ff53c1c5
    #d $482a4830f81d481f482e9d482f0c1b48
    #d $0f1a480e483e
    call call4c8f
    #d $483f482e6d4b8d
    #d $482f480f1a0d1b
    call call4c8f
    #d $481f480f08

call4c8f:
    #d $2b608b3d52fa
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
    #d largetext("GOOD!")
    #d largetext("GAMEOVER")
    #d largetext("GIVEUP?")

data4ee1:
    #d $67, largetext("E"), $65

data4ee4:
    #d largetext("PLAY"), $69

data4ee9:
    #d largetext("DIS")

    #d $0f0f0f0f
    #d $000606000000000006090906

data4efc:
    #d $00000000
    #d $0a07070a00000000020f0f0200000000
    #d $020f0f0200000000020f0f0200000000
    #d $020f0f0200060600060909060f0f0f0f
    #d $090606090f0f0f0f00000000

data4f3c:
    #d $0e080f14
    #d $0e080f1403140d080e140c080e140314
    #d $0a080a140a080c140d140e0aff060a06
    #d $0a0a0a0d1e080a080a0b0a0f1e110a11
    #d $0a110a110a0f0a110a121eff060a080a
    #d $0a0a0b140f0a0b140f0a1214100a0f14
    #d $0d0a0b0a080a060a0a140b28ff0a0a08
    #d $0a060a0a0a080a060aff

music:
    #d $12021600000f
    #d $ff0a080d010001ff

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
    #d $0204103277774c
    #d $51953339524140519605379404350417
    #d $04050414315043531431532415143341
    #d $514337733f270b03031b022e1200

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
    #d $020310076075143063
    #d $41415043405043330404304242630758
    #d $631424a5c42524a531424a6141424a40
    #d $414174a404331a407762433274f02a01
    #d $070202020209020f010d11010f120d01
    #d $1400

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
