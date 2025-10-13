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
    {addr: u16} => {
        assert(addr >= 0xFF00)
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
    {addr: u16} => {
        reladdr = addr - $ - 1
        assert(reladdr <= 0x3f)
        assert(reladdr >= -0x3f)
        reladdr`6
    }
}

#subruledef pd7806_jre_reladdr {
    {addr: u16} => {
        reladdr = addr - $ - 2
        assert(reladdr <= 0xff)
        assert(reladdr >= -0xff)
        (reladdr >= 0 ? %0 : %1) @ reladdr`8
    }
}

#subruledef pd7806_calf_addr {
    {addr: u16} => {
        assert(addr >= 0x0800)
        assert(addr <= 0x0FFF)
        addr`12
    }
}

#subruledef pd7806_calt_addr {
    {addr: u16} => {
        assert(addr[0:0] == 0)
        assert(addr >= 0x0080)
        assert(addr <= 0x00FE)
        (addr - 0x0080)[6:1]
    }
}

#subruledef bytes {
    {b1: u8} => b1
    {b1: u8}, {bn: bytes} => b1 @ bn
}

#subruledef words {
    {w1: u16} => le(w1)
    {w1: u16}, {wn: words} => le(w1) @ words
}

#ruledef {
    ; 8-Bit Data Transfer
    mov {reg: pd7806_r1}, a => 0x1 @ 0b1 @ reg
    mov a, {reg: pd7806_r1} => 0x0 @ 0b1 @ reg
    mov {port: pd7806_sr}, a => 0x4dc @ port
    mov a, {port: pd7806_sr} => 0x4cc @ port
    mov {reg: pd7806_r}, [{addr: u16}] => $706 @ 0b1 @ reg @ le(addr)
    mov [{addr: u16}], {reg: pd7806_r} => $707 @ 0b1 @ reg @ le(addr)
    mvi {reg: pd7806_r}, {value: u8} => $6 @ 0b1 @ reg @ value
    staw [{addr: pd7806_wa}] => $38 @ addr
    ldaw [{addr: pd7806_wa}] => $28 @ addr
    stax [{reg: pd7806_rpa}] => $3 @ 0b1 @ reg
    ldax [{reg: pd7806_rpa}] => $2 @ 0b1 @ reg

    ; 16-Bit Data Transfer
    sbcd [{addr: u16}] => $701E @ le(addr)
    sded [{addr: u16}] => $702E @ le(addr)
    shld [{addr: u16}] => $703E @ le(addr)
    sspd [{addr: u16}] => $700E @ le(addr)
    lbcd [{addr: u16}] => $701F @ le(addr)
    lded [{addr: u16}] => $702F @ le(addr)
    lhld [{addr: u16}] => $703F @ le(addr)
    lspd [{addr: u16}] => $700F @ le(addr)
    push {reg: pd7806_rp1} => $48 @ reg @ $e
    pop {reg: pd7806_rp1} => $48 @ reg @ $f
    lxi {reg: pd7806_rp}, {value: u16} => reg @ $4 @ le(value)

    ; Arithmetic
    add     a, {reg: pd7806_r}   => $60C @ 0b0 @ reg
    addx    [{reg: pd7806_rpa}]  => $70C @ 0b0 @ reg
    adc     a, {reg: pd7806_r}   => $60D @ 0b0 @ reg
    adcx    [{reg: pd7806_rpa}]  => $70D @ 0b0 @ reg
    sub     a, {reg: pd7806_r}   => $60E @ 0b0 @ reg
    subx    [{reg: pd7806_rpa}]  => $70E @ 0b0 @ reg
    sbb     a, {reg: pd7806_r}   => $60F @ 0b0 @ reg
    sbbx    [{reg: pd7806_rpa}]  => $70F @ 0b0 @ reg
    addnc   a, {reg: pd7806_r}   => $60A @ 0b0 @ reg
    addncx  [{reg: pd7806_rpa}]  => $70A @ 0b0 @ reg
    subnb   a, {reg: pd7806_r}   => $60B @ 0b0 @ reg
    subnbx  [{reg: pd7806_rpa}]  => $70B @ 0b0 @ reg
    ana     a, {reg: pd7806_r}   => $608 @ 0b1 @ reg
    anax    [{reg: pd7806_rpa}]  => $708 @ 0b1 @ reg
    ora     a, {reg: pd7806_r}   => $609 @ 0b1 @ reg
    orax    [{reg: pd7806_rpa}]  => $709 @ 0b1 @ reg
    xra     a, {reg: pd7806_r}   => $609 @ 0b0 @ reg
    xrax    [{reg: pd7806_rpa}]  => $709 @ 0b0 @ reg
    gta     a, {reg: pd7806_r}   => $60A @ 0b1 @ reg
    gtax    [{reg: pd7806_rpa}]  => $70A @ 0b1 @ reg
    lta     a, {reg: pd7806_r}   => $60B @ 0b1 @ reg
    ltax    [{reg: pd7806_rpa}]  => $70B @ 0b1 @ reg
    nea     a, {reg: pd7806_r}   => $60E @ 0b1 @ reg
    neax    [{reg: pd7806_rpa}]  => $70E @ 0b1 @ reg
    eqa     a, {reg: pd7806_r}   => $60F @ 0b1 @ reg
    eqax    [{reg: pd7806_rpa}]  => $70F @ 0b1 @ reg

    ; Immediate Data Transfer (Accumulator)
    xri    a, {value: u8}  => $16 @ value
    adinc  a, {value: u8}  => $26 @ value
    suinb  a, {value: u8}  => $36 @ value
    adi    a, {value: u8}  => $46 @ value
    aci    a, {value: u8}  => $56 @ value
    sui    a, {value: u8}  => $66 @ value
    sbi    a, {value: u8}  => $76 @ value
    ani    a, {value: u8}  => $07 @ value
    ori    a, {value: u8}  => $17 @ value
    gti    a, {value: u8}  => $27 @ value
    lti    a, {value: u8}  => $37 @ value
    oni    a, {value: u8}  => $47 @ value
    offi   a, {value: u8}  => $57 @ value
    nei    a, {value: u8}  => $67 @ value
    eqi    a, {value: u8}  => $77 @ value

    ; Immediate Data Transfer (Special Register)
    ani  {port: pd7806_rp2}, {value: u8} => $648 @ 0b10 @ port @ value
    ori  {port: pd7806_rp2}, {value: u8} => $649 @ 0b10 @ port @ value
    offi {port: pd7806_rp2}, {value: u8} => $64d @ 0b10 @ port @ value
    oni  {port: pd7806_rp2}, {value: u8} => $64c @ 0b10 @ port @ value

    ; Working Register
    aniw    [{addr: pd7806_wa}], {value: u8} => $05 @ addr @ value
    oriw    [{addr: pd7806_wa}], {value: u8} => $15 @ addr @ value
    gtiw    [{addr: pd7806_wa}], {value: u8} => $25 @ addr @ value
    ltiw    [{addr: pd7806_wa}], {value: u8} => $35 @ addr @ value
    oniw    [{addr: pd7806_wa}], {value: u8} => $45 @ addr @ value
    offiw   [{addr: pd7806_wa}], {value: u8} => $55 @ addr @ value
    neiw    [{addr: pd7806_wa}], {value: u8} => $65 @ addr @ value
    eqiw    [{addr: pd7806_wa}], {value: u8} => $75 @ addr @ value

    ; Increment/Decrement
    inr {reg: pd7802_r2} => $4 @ %0 @ reg
    inrw [{addr: pd7806_wa}] => $20 @ addr
    dcr {reg: pd7802_r2} => $5 @ %0 @ reg
    dcrw [{addr: pd7806_wa}] => $30 @ addr
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
    jmp {addr: u16} => $54 @ le(addr)
    jb => $73
    jr {reladdr: pd7806_jr_reladdr} => 0b11 @ reladdr
    jre {reladdr: pd7806_jre_reladdr} => $4E[7:1] @ reladdr

    ; Call
    call {addr: u16} => $44 @ le(addr)
    calf {addr: pd7806_calf_addr} => 0b0111 @ addr
    calt {addr: pd7806_calt_addr} => 0b10 @ addr

    ; Return
    ret => $08
    rets => $18
    reti => $62

    ; Skip
    sknc                    => $481A
    sknz                    => $481C
    sknit {flag: pd7806_f}  => $481 @ flag

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
    db {b: bytes} => b
    dw {w: words} => w
}
