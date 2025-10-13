#subruledef push_reg {
    va => 0x0
    bc => 0x1
    de => 0x2
    hl => 0x3
}

#subruledef inx_reg {
    sp => 0x0
    bc => 0x1
    de => 0x2
    hl => 0x3
}

#subruledef ldax_reg {
    bc  => 0b001
    de  => 0b010
    hl  => 0b011
    de+ => 0b100
    hl+ => 0b101
    de- => 0b110
    hl- => 0b111
}

#subruledef reg_inr {
    a => $1
    b => $2
    c => $3
}

#subruledef reg_bcdehl {
    b => 0b010
    c => 0b011
    d => 0b100
    e => 0b101
    h => 0b110
    l => 0b111
}

#subruledef reg_abcdehl {
    a => 0b001
    {r: reg_bcdehl} => r
}

#subruledef reg_vabcdehl {
    v => 0b000
    {r: reg_abcdehl} => r
}

#subruledef ani_port {
    pa  => 0b00
    pb  => 0b01
    pc  => 0b10
    mk  => 0b11
}

#subruledef mov_a_port {
    pa  => 0x0
    pb  => 0x1
    pc  => 0x2
    mk  => 0x3
    mb  => 0x4
    mc  => 0x5
    tm0 => 0x6
    tm1 => 0x7
    s   => 0x8
    tmm => 0x9
}

#subruledef hi_addr {
    {addr: u16} => {
        assert(addr >= 0xFF00)
        (addr & 0xFF)`8
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
    mov {reg: reg_bcdehl}, a => 0x1 @ 0b1 @ reg
    mov a, {reg: reg_bcdehl} => 0x0 @ 0b1 @ reg
    mov {port: mov_a_port}, a => 0x4dc @ port
    mov a, {port: mov_a_port} => 0x4cc @ port
    mov {reg: reg_vabcdehl}, [{addr: u16}] => $706 @ 0b1 @ reg @ le(addr)
    mov [{addr: u16}], {reg: reg_vabcdehl} => $707 @ 0b1 @ reg @ le(addr)
    mvi {reg: reg_abcdehl}, {value: u8} => $6 @ 0b1 @ reg @ value
    staw [{addr: hi_addr}] => $38 @ addr
    ldaw [{addr: hi_addr}] => $28 @ addr
    stax [{reg: ldax_reg}] => $3 @ 0b1 @ reg
    ldax [{reg: ldax_reg}] => $2 @ 0b1 @ reg

    ; 16-Bit Data Transfer
    sbcd [{addr: u16}] => $701E @ le(addr)
    sded [{addr: u16}] => $702E @ le(addr)
    shld [{addr: u16}] => $703E @ le(addr)
    sspd [{addr: u16}] => $700E @ le(addr)
    lbcd [{addr: u16}] => $701F @ le(addr)
    lded [{addr: u16}] => $702F @ le(addr)
    lhld [{addr: u16}] => $703F @ le(addr)
    lspd [{addr: u16}] => $700F @ le(addr)
    push {reg: push_reg} => $48 @ reg @ $e
    pop {reg: push_reg} => $48 @ reg @ $f
    lxi {reg: inx_reg}, {value: u16} => reg @ $4 @ le(value)

    ; Arithmetic
    add     a, {reg: reg_vabcdehl}  => $60C @ 0b0 @ reg
    addx    [{reg: ldax_reg}]       => $70C @ 0b0 @ reg
    adc     a, {reg: reg_vabcdehl}  => $60D @ 0b0 @ reg
    adcx    [{reg: ldax_reg}]       => $70D @ 0b0 @ reg
    sub     a, {reg: reg_vabcdehl}  => $60E @ 0b0 @ reg
    subx    [{reg: ldax_reg}]       => $70E @ 0b0 @ reg
    sbb     a, {reg: reg_vabcdehl}  => $60F @ 0b0 @ reg
    sbbx    [{reg: ldax_reg}]       => $70F @ 0b0 @ reg
    addnc   a, {reg: reg_vabcdehl}  => $60A @ 0b0 @ reg
    addncx  [{reg: ldax_reg}]       => $70A @ 0b0 @ reg
    subnb   a, {reg: reg_vabcdehl}  => $60B @ 0b0 @ reg
    subnbx  [{reg: ldax_reg}]       => $70B @ 0b0 @ reg
    ana     a, {reg: reg_vabcdehl}  => $608 @ 0b1 @ reg
    anax    [{reg: ldax_reg}]       => $708 @ 0b1 @ reg
    ora     a, {reg: reg_vabcdehl}  => $609 @ 0b1 @ reg
    orax    [{reg: ldax_reg}]       => $709 @ 0b1 @ reg
    xra     a, {reg: reg_vabcdehl}  => $609 @ 0b0 @ reg
    xrax    [{reg: ldax_reg}]       => $709 @ 0b0 @ reg
    gta     a, {reg: reg_vabcdehl}  => $60A @ 0b1 @ reg
    gtax    [{reg: ldax_reg}]       => $70A @ 0b1 @ reg
    lta     a, {reg: reg_vabcdehl}  => $60B @ 0b1 @ reg
    ltax    [{reg: ldax_reg}]       => $70B @ 0b1 @ reg
    nea     a, {reg: reg_vabcdehl}  => $60E @ 0b1 @ reg
    neax    [{reg: ldax_reg}]       => $70E @ 0b1 @ reg
    eqa     a, {reg: reg_vabcdehl}  => $60F @ 0b1 @ reg
    eqax    [{reg: ldax_reg}]       => $70F @ 0b1 @ reg

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
    ani  {port: ani_port}, {value: u8} => $648 @ 0b10 @ port @ value
    ori  {port: ani_port}, {value: u8} => $649 @ 0b10 @ port @ value
    offi {port: ani_port}, {value: u8} => $64d @ 0b10 @ port @ value
    oni  {port: ani_port}, {value: u8} => $64c @ 0b10 @ port @ value

    ; Working Register
    aniw    [{addr: hi_addr}], {value: u8} => $05 @ addr @ value
    oriw    [{addr: hi_addr}], {value: u8} => $15 @ addr @ value
    gtiw    [{addr: hi_addr}], {value: u8} => $25 @ addr @ value
    ltiw    [{addr: hi_addr}], {value: u8} => $35 @ addr @ value
    oniw    [{addr: hi_addr}], {value: u8} => $45 @ addr @ value
    offiw   [{addr: hi_addr}], {value: u8} => $55 @ addr @ value
    neiw    [{addr: hi_addr}], {value: u8} => $65 @ addr @ value
    eqiw    [{addr: hi_addr}], {value: u8} => $75 @ addr @ value

    ; Increment/Decrement
    inr {reg: reg_inr} => $4 @ reg
    inrw [{addr: hi_addr}] => $20 @ addr
    dcr {reg: reg_inr} => $5 @ reg
    dcrw [{addr: hi_addr}] => $30 @ addr
    inx {reg: inx_reg} => reg @ $2
    dcx {reg: inx_reg} => reg @ $3

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
    jr {addr: u16} => {
        reladdr = addr - $ - 1
        assert(reladdr <= 0x3f)
        assert(reladdr >= -0x3f)
        0b11 @ reladdr`6
    }
    jre {addr: u16} => {
        reladdr = addr - $ - 2
        assert(reladdr <= 0xff)
        assert(reladdr >= -0xff)
        ( reladdr >= 0
        ? 0x4E @ reladdr`8
        : 0x4F @ reladdr`8
        )
    }

    ; Call
    call {addr: u16} => $44 @ le(addr)
    calf {addr: u16} => {
        assert(addr >= 0x0800)
        assert(addr <= 0x0FFF)
        0b0111 @ addr`12
    }
    calt {addr: u16} => {
        assert(addr & 0x0001 == 0)
        assert(addr >= 0x0080)
        assert(addr <= 0x00FE)
        0b10 @ ((addr - 0x0080) >> 1)`6
    }

    ; Return
    ret => $08
    rets => $18
    reti => $62

    ; Skip
    sknc      => $481A
    sknz      => $481C
    sknit f0  => $4810
    sknit ft  => $4811
    sknit f1  => $4812
    sknit f2  => $4813
    sknit fs  => $4814

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
