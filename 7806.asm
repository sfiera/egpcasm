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

#subruledef reg_vbcdehl {
    v => 0b000
    {r: reg_bcdehl} => r
}

#subruledef reg_vabcdehl {
    a => 0b001
    {r: reg_vbcdehl} => r
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
    db {b: bytes} => b
    dw {w: words} => w

    nop => $00

    ret => $08
    rets => $18
    reti => $62

    jb => $73

    stm => $19
    daa => $61

    ei  => $4820
    di  => $4824
    clc => $482A
    stc => $482B
    pex => $482D
    ral => $4830
    rar => $4831
    rld => $4838
    rrd => $4839
    per => $483C

    mov a, {reg: reg_bcdehl} => 0x0 @ 0b1 @ reg
    mov {reg: reg_bcdehl}, a => 0x1 @ 0b1 @ reg
    mov a, {port: mov_a_port} => 0x4cc @ port
    mov {port: mov_a_port}, a => 0x4dc @ port
    mov {reg: reg_vabcdehl}, [{addr: u16}] => $706 @ 0b1 @ reg @ le(addr)
    mov [{addr: u16}], {reg: reg_vabcdehl} => $707 @ 0b1 @ reg @ le(addr)
    mvi {reg: reg_abcdehl}, {value: u8} => $6 @ 0b1 @ reg @ value

    lxi {reg: inx_reg}, {value: u16} => reg @ $4 @ le(value)
    inx {reg: inx_reg} => reg @ $2
    dcx {reg: inx_reg} => reg @ $3
    ldax [{reg: ldax_reg}] => $2 @ 0b1 @ reg
    stax [{reg: ldax_reg}] => $3 @ 0b1 @ reg

    ldaw [{addr: hi_addr}] => $28 @ addr
    staw [{addr: hi_addr}] => $38 @ addr

    inr {reg: reg_inr} => $4 @ reg
    dcr {reg: reg_inr} => $5 @ reg
    inrw [{addr: hi_addr}] => $20 @ addr
    dcrw [{addr: hi_addr}] => $30 @ addr

    ana     {reg: reg_vbcdehl}, a => $600 @ 0b1 @ reg
    xra     {reg: reg_vbcdehl}, a => $601 @ 0b0 @ reg
    ora     {reg: reg_vbcdehl}, a => $601 @ 0b1 @ reg
    addnc   {reg: reg_vbcdehl}, a => $602 @ 0b0 @ reg
    gta     {reg: reg_vbcdehl}, a => $602 @ 0b1 @ reg
    subnb   {reg: reg_vbcdehl}, a => $603 @ 0b0 @ reg
    lta     {reg: reg_vbcdehl}, a => $603 @ 0b1 @ reg
    add     {reg: reg_vbcdehl}, a => $604 @ 0b0 @ reg
    adc     {reg: reg_vbcdehl}, a => $605 @ 0b0 @ reg
    sub     {reg: reg_vbcdehl}, a => $606 @ 0b0 @ reg
    nea     {reg: reg_vbcdehl}, a => $606 @ 0b1 @ reg
    sbb     {reg: reg_vbcdehl}, a => $607 @ 0b0 @ reg
    eqa     {reg: reg_vbcdehl}, a => $607 @ 0b1 @ reg

    ana     a, {reg: reg_vabcdehl} => $608 @ 0b1 @ reg
    xra     a, {reg: reg_vabcdehl} => $609 @ 0b0 @ reg
    ora     a, {reg: reg_vabcdehl} => $609 @ 0b1 @ reg
    addnc   a, {reg: reg_vabcdehl} => $60A @ 0b0 @ reg
    gta     a, {reg: reg_vabcdehl} => $60A @ 0b1 @ reg
    subnb   a, {reg: reg_vabcdehl} => $60B @ 0b0 @ reg
    lta     a, {reg: reg_vabcdehl} => $60B @ 0b1 @ reg
    add     a, {reg: reg_vabcdehl} => $60C @ 0b0 @ reg
    adc     a, {reg: reg_vabcdehl} => $60D @ 0b0 @ reg
    sub     a, {reg: reg_vabcdehl} => $60E @ 0b0 @ reg
    nea     a, {reg: reg_vabcdehl} => $60E @ 0b1 @ reg
    sbb     a, {reg: reg_vabcdehl} => $60F @ 0b0 @ reg
    eqa     a, {reg: reg_vabcdehl} => $60F @ 0b1 @ reg

    anax    [{reg: ldax_reg}] => $708 @ 0b1 @ reg
    xrax    [{reg: ldax_reg}] => $709 @ 0b0 @ reg
    orax    [{reg: ldax_reg}] => $709 @ 0b1 @ reg
    addncx  [{reg: ldax_reg}] => $70A @ 0b0 @ reg
    gtax    [{reg: ldax_reg}] => $70A @ 0b1 @ reg
    subnbx  [{reg: ldax_reg}] => $70B @ 0b0 @ reg
    ltax    [{reg: ldax_reg}] => $70B @ 0b1 @ reg
    addx    [{reg: ldax_reg}] => $70C @ 0b0 @ reg
    adcx    [{reg: ldax_reg}] => $70D @ 0b0 @ reg
    subx    [{reg: ldax_reg}] => $70E @ 0b0 @ reg
    neax    [{reg: ldax_reg}] => $70E @ 0b1 @ reg
    sbbx    [{reg: ldax_reg}] => $70F @ 0b0 @ reg
    eqax    [{reg: ldax_reg}] => $70F @ 0b1 @ reg

    ani a, {value: u8} => $07 @ value
    xri a, {value: u8} => $16 @ value
    ori a, {value: u8} => $17 @ value
    adinc a, {value: u8} => $26 @ value
    gti a, {value: u8} => $27 @ value
    suinb a, {value: u8} => $36 @ value
    lti a, {value: u8} => $37 @ value
    adi a, {value: u8} => $46 @ value
    oni a, {value: u8} => $47 @ value
    aci a, {value: u8} => $56 @ value
    offi a, {value: u8} => $57 @ value
    sui a, {value: u8} => $66 @ value
    nei a, {value: u8} => $67 @ value
    sbi a, {value: u8} => $76 @ value
    eqi a, {value: u8} => $77 @ value

    ani     {reg: reg_vbcdehl}, {value: u8} => $640 @ 0b1 @ reg @ value
    xri     {reg: reg_vbcdehl}, {value: u8} => $641 @ 0b0 @ reg @ value
    ori     {reg: reg_vbcdehl}, {value: u8} => $641 @ 0b1 @ reg @ value
    adinc   {reg: reg_vbcdehl}, {value: u8} => $642 @ 0b0 @ reg @ value
    gti     {reg: reg_vbcdehl}, {value: u8} => $642 @ 0b1 @ reg @ value
    suinb   {reg: reg_vbcdehl}, {value: u8} => $643 @ 0b0 @ reg @ value
    lti     {reg: reg_vbcdehl}, {value: u8} => $643 @ 0b1 @ reg @ value
    adi     {reg: reg_vbcdehl}, {value: u8} => $644 @ 0b0 @ reg @ value
    oni     {reg: reg_vbcdehl}, {value: u8} => $644 @ 0b1 @ reg @ value
    aci     {reg: reg_vbcdehl}, {value: u8} => $645 @ 0b0 @ reg @ value
    offi    {reg: reg_vbcdehl}, {value: u8} => $645 @ 0b1 @ reg @ value
    sui     {reg: reg_vbcdehl}, {value: u8} => $646 @ 0b0 @ reg @ value
    nei     {reg: reg_vbcdehl}, {value: u8} => $646 @ 0b1 @ reg @ value
    sbi     {reg: reg_vbcdehl}, {value: u8} => $647 @ 0b0 @ reg @ value
    eqi     {reg: reg_vbcdehl}, {value: u8} => $647 @ 0b1 @ reg @ value

    aniw    [{addr: hi_addr}], {value: u8} => $05 @ addr @ value
    oriw    [{addr: hi_addr}], {value: u8} => $15 @ addr @ value
    gtiw    [{addr: hi_addr}], {value: u8} => $25 @ addr @ value
    ltiw    [{addr: hi_addr}], {value: u8} => $35 @ addr @ value
    oniw    [{addr: hi_addr}], {value: u8} => $45 @ addr @ value
    offiw   [{addr: hi_addr}], {value: u8} => $55 @ addr @ value
    neiw    [{addr: hi_addr}], {value: u8} => $65 @ addr @ value
    eqiw    [{addr: hi_addr}], {value: u8} => $75 @ addr @ value

    ani  {port: ani_port}, {value: u8} => $648 @ 0b10 @ port @ value
    ori  {port: ani_port}, {value: u8} => $649 @ 0b10 @ port @ value
    oni  {port: ani_port}, {value: u8} => $64c @ 0b10 @ port @ value
    offi {port: ani_port}, {value: u8} => $64d @ 0b10 @ port @ value

    sspd [{addr: u16}] => $700E @ le(addr)
    lspd [{addr: u16}] => $700F @ le(addr)
    sbcd [{addr: u16}] => $701E @ le(addr)
    lbcd [{addr: u16}] => $701F @ le(addr)
    sded [{addr: u16}] => $702E @ le(addr)
    lded [{addr: u16}] => $702F @ le(addr)
    shld [{addr: u16}] => $703E @ le(addr)
    lhld [{addr: u16}] => $703F @ le(addr)
    push {reg: push_reg} => $48 @ reg @ $e
    pop {reg: push_reg} => $48 @ reg @ $f

    jmp {addr: u16} => $54 @ le(addr)
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

    sknit f0 => $4810
    sknit ft => $4811
    sknit f1 => $4812
    sknit f2 => $4813
    sknit fs => $4814
    skn cy   => $481A
    skn z    => $481C
}
