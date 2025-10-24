#subruledef pd7806_r {
    a => 1`3
    b => 2`3
    c => 3`3
    d => 4`3
    e => 5`3
    h => 6`3
    l => 7`3
}

#subruledef pd7806_r1 {
    b => 2`3
    c => 3`3
    d => 4`3
    e => 5`3
    h => 6`3
    l => 7`3
}

#subruledef pd7802_r2 {
    a => 1`3
    b => 2`3
    c => 3`3
}

#subruledef pd7806_sr {
    pa  => 0`4
    pb  => 1`4
    pc  => 2`4
    mk  => 3`4
    mb  => 4`4
    mc  => 5`4
    tm0 => 6`4
    tm1 => 7`4
    s   => 8`4
    tmm => 9`4
}

#subruledef pd7806_rp {
    sp => 0`4
    bc => 1`4
    de => 2`4
    hl => 3`4
}

#subruledef pd7806_rp1 {
    va => 0`4
    bc => 1`4
    de => 2`4
    hl => 3`4
}

#subruledef pd7806_rp2 {
    pa  => 0`2
    pb  => 1`2
    pc  => 2`2
    mk  => 3`2
}

#subruledef pd7806_rpa {
    bc  => 1`3
    de  => 2`3
    hl  => 3`3
    de+ => 4`3
    hl+ => 5`3
    de- => 6`3
    hl- => 7`3
}

#subruledef pd7806_wa {
    {addr: i16} => {
        assert(addr >= $FF00)
        addr[7:0]
    }
}

#subruledef pd7806_f {
    f0 => 0`4
    ft => 1`4
    f1 => 2`4
    f2 => 3`4
    fs => 4`4
}

#subruledef pd7806_jr_reladdr {
    {addr: i16} => {
        reladdr = addr - $ - 1
        assert(reladdr <= $3f)
        assert(reladdr >= -$3f)
        reladdr`6
    }
}

#subruledef pd7806_jre_reladdr {
    {addr: i16} => {
        reladdr = addr - $ - 2
        assert(reladdr <= $ff)
        assert(reladdr >= -$ff)
        (reladdr >= 0 ? %0 : %1) @ reladdr`8
    }
}

#subruledef pd7806_calf_addr {
    {addr: i16} => {
        assert(addr >= $0800)
        assert(addr <= $0FFF)
        addr`12
    }
}

#subruledef pd7806_calt_addr {
    {addr: i16} => {
        assert(addr[0:0] == 0)
        assert(addr >= $0080)
        assert(addr <= $00FE)
        (addr - $0080)[6:1]
    }
}

#subruledef pd7806_db {
    {b1: i8} => b1
    {b1: i8}, {bn: pd7806_db} => b1 @ bn
}

#subruledef pd7806_dw {
    {w1: i16} => le(w1)
    {w1: i16}, {wn: pd7806_dw} => le(w1) @ pd7806_dw
}

#ruledef pd7806 {
    ; 8-Bit Data Transfer
    mov {reg: pd7806_r1}, a => $1 @ %1 @ reg
    mov a, {reg: pd7806_r1} => $0 @ %1 @ reg
    mov {port: pd7806_sr}, a => $4dc @ port
    mov a, {port: pd7806_sr} => $4cc @ port
    mov {reg: pd7806_r}, [{addr: i16}] => $706 @ %1 @ reg @ le(addr)
    mov [{addr: i16}], {reg: pd7806_r} => $707 @ %1 @ reg @ le(addr)
    mvi {reg: pd7806_r}, {value: i8} => $6 @ %1 @ reg @ value
    staw [{addr: pd7806_wa}] => $38 @ addr
    ldaw [{addr: pd7806_wa}] => $28 @ addr
    stax [{reg: pd7806_rpa}] => $3 @ %1 @ reg
    ldax [{reg: pd7806_rpa}] => $2 @ %1 @ reg

    ; 16-Bit Data Transfer
    sbcd [{addr: i16}] => $701E @ le(addr)
    sded [{addr: i16}] => $702E @ le(addr)
    shld [{addr: i16}] => $703E @ le(addr)
    sspd [{addr: i16}] => $700E @ le(addr)
    lbcd [{addr: i16}] => $701F @ le(addr)
    lded [{addr: i16}] => $702F @ le(addr)
    lhld [{addr: i16}] => $703F @ le(addr)
    lspd [{addr: i16}] => $700F @ le(addr)
    push {reg: pd7806_rp1} => $48 @ reg @ $e
    pop {reg: pd7806_rp1} => $48 @ reg @ $f
    lxi {reg: pd7806_rp}, {value: i16} => reg @ $4 @ le(value)

    ; Arithmetic
    add     a, {reg: pd7806_r}   => $60C @ %0 @ reg
    addx    [{reg: pd7806_rpa}]  => $70C @ %0 @ reg
    adc     a, {reg: pd7806_r}   => $60D @ %0 @ reg
    adcx    [{reg: pd7806_rpa}]  => $70D @ %0 @ reg
    sub     a, {reg: pd7806_r}   => $60E @ %0 @ reg
    subx    [{reg: pd7806_rpa}]  => $70E @ %0 @ reg
    sbb     a, {reg: pd7806_r}   => $60F @ %0 @ reg
    sbbx    [{reg: pd7806_rpa}]  => $70F @ %0 @ reg
    addnc   a, {reg: pd7806_r}   => $60A @ %0 @ reg  ; skip: no carry
    addncx  [{reg: pd7806_rpa}]  => $70A @ %0 @ reg  ; skip: no carry
    subnb   a, {reg: pd7806_r}   => $60B @ %0 @ reg  ; skip: no borrow
    subnbx  [{reg: pd7806_rpa}]  => $70B @ %0 @ reg  ; skip: no borrow
    ana     a, {reg: pd7806_r}   => $608 @ %1 @ reg
    anax    [{reg: pd7806_rpa}]  => $708 @ %1 @ reg
    ora     a, {reg: pd7806_r}   => $609 @ %1 @ reg
    orax    [{reg: pd7806_rpa}]  => $709 @ %1 @ reg
    xra     a, {reg: pd7806_r}   => $609 @ %0 @ reg
    xrax    [{reg: pd7806_rpa}]  => $709 @ %0 @ reg
    gta     a, {reg: pd7806_r}   => $60A @ %1 @ reg  ; skip: no borrow
    gtax    [{reg: pd7806_rpa}]  => $70A @ %1 @ reg  ; skip: no borrow
    lta     a, {reg: pd7806_r}   => $60B @ %1 @ reg  ; skip: borrow
    ltax    [{reg: pd7806_rpa}]  => $70B @ %1 @ reg  ; skip: borrow
    onax    [{reg: pd7806_rpa}]  => $70C @ %1 @ reg  ; skip: no zero
    offax   [{reg: pd7806_rpa}]  => $70D @ %1 @ reg  ; skip: zero
    nea     a, {reg: pd7806_r}   => $60E @ %1 @ reg  ; skip: no zero
    neax    [{reg: pd7806_rpa}]  => $70E @ %1 @ reg  ; skip: no zero
    eqa     a, {reg: pd7806_r}   => $60F @ %1 @ reg  ; skip: zero
    eqax    [{reg: pd7806_rpa}]  => $70F @ %1 @ reg  ; skip: zero

    ; Immediate Data Transfer (Accumulator)
    xri    a, {value: i8}  => $16 @ value
    adinc  a, {value: i8}  => $26 @ value  ; skip: no carry
    suinb  a, {value: i8}  => $36 @ value  ; skip: no borrow
    adi    a, {value: i8}  => $46 @ value
    aci    a, {value: i8}  => $56 @ value
    sui    a, {value: i8}  => $66 @ value
    sbi    a, {value: i8}  => $76 @ value
    ani    a, {value: i8}  => $07 @ value
    ori    a, {value: i8}  => $17 @ value
    gti    a, {value: i8}  => $27 @ value  ; skip: no borrow
    lti    a, {value: i8}  => $37 @ value  ; skip: borrow
    oni    a, {value: i8}  => $47 @ value  ; skip: no zero
    offi   a, {value: i8}  => $57 @ value  ; skip: zero
    nei    a, {value: i8}  => $67 @ value  ; skip: no zero
    eqi    a, {value: i8}  => $77 @ value  ; skip: zero

    ; Immediate Data Transfer (Special Register)
    ani  {port: pd7806_rp2}, {value: i8} => $648 @ %10 @ port @ value
    ori  {port: pd7806_rp2}, {value: i8} => $649 @ %10 @ port @ value
    offi {port: pd7806_rp2}, {value: i8} => $64d @ %10 @ port @ value  ; skip: no zero
    oni  {port: pd7806_rp2}, {value: i8} => $64c @ %10 @ port @ value  ; skip: zero

    ; Working Register
    aniw    [{addr: pd7806_wa}], {value: i8} => $05 @ addr @ value
    oriw    [{addr: pd7806_wa}], {value: i8} => $15 @ addr @ value
    gtiw    [{addr: pd7806_wa}], {value: i8} => $25 @ addr @ value  ; skip: no borrow
    ltiw    [{addr: pd7806_wa}], {value: i8} => $35 @ addr @ value  ; skip: borrow
    oniw    [{addr: pd7806_wa}], {value: i8} => $45 @ addr @ value  ; skip: no zero
    offiw   [{addr: pd7806_wa}], {value: i8} => $55 @ addr @ value  ; skip: zero
    neiw    [{addr: pd7806_wa}], {value: i8} => $65 @ addr @ value  ; skip: no zero
    eqiw    [{addr: pd7806_wa}], {value: i8} => $75 @ addr @ value  ; skip: zero

    ; Increment/Decrement
    inr {reg: pd7802_r2} => $4 @ %0 @ reg   ; skip: carry
    inrw [{addr: pd7806_wa}] => $20 @ addr  ; skip: carry
    dcr {reg: pd7802_r2} => $5 @ %0 @ reg   ; skip: borrow
    dcrw [{addr: pd7806_wa}] => $30 @ addr  ; skip: borrow
    inx {reg: pd7806_rp} => reg @ $2
    dcx {reg: pd7806_rp} => reg @ $3

    ; Miscellaneous
    daa => $61
    stc => $482B
    clc => $482A

    ; Rotate and Shift
    rld => $4838
    rrd => $4839
    ral => $4830
    rar => $4831

    ; Jump
    jmp {addr: i16} => $54 @ le(addr)
    jb => $73
    jr {reladdr: pd7806_jr_reladdr} => %11 @ reladdr
    jre {reladdr: pd7806_jre_reladdr} => $4E[7:1] @ reladdr

    ; Call
    call {addr: i16} => $44 @ le(addr)
    calf {addr: pd7806_calf_addr} => %0111 @ addr
    calt {addr: pd7806_calt_addr} => %10 @ addr

    ; Return
    ret => $08
    rets => $18
    reti => $62

    ; Skip
    sknc                    => $481A        ; skip: cy == 0
    sknz                    => $481C        ; skip: z == 0
    sknit {flag: pd7806_f}  => $481 @ flag  ; skip: f == 0

    ; CPU Control
    nop => $00
    ei  => $4820
    di  => $4824

    ; Serial Port Control
    sio => $09
    stm => $19

    ; Port E Control
    pex => $482D
    per => $483C

    ; Data Directives
    db {b: pd7806_db} => b
    dw {w: pd7806_dw} => w
}

#const TMM_EXT    = %00000000  ; Output timer to TO pin
#const TMM_NOEXT  = %00000011  ; Don't output timer to TO pin
#const TMM_FAST   = %00000000  ; Decrement tm0 with 82us clock
#const TMM_SLOW   = %00000100  ; Decrement tm0 with 5us clock
