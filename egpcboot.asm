;"Pokekon" BIOS disassembly & comments by Chris Covell

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

; This is a disassembly of the Epoch Game Pocket Computer's BIOS ROM.
; The BIOS is internal to the uPD78c06 CPU, but is completely accessible to
; all game ROMs, and provides vital support functions for games (reading
; the joypad, updating the LCD, offering music-playing routines...)
;
; Not all of the functions of the BIOS are understood, but a good many
; of them have been documented.  Much of the ROM space is taken up by
; the internal demonstration, puzzle, and "paint" programs of the Pokekon
; so it is not relevant to game programmers, necessarily.
;
; I can't guarantee that this disassembly is completely error-free, so
; bear with me.  Many thanks to Judge, the Guru, and John Dyer for their help!

;General BIOS breakdown:
;0000 - 007F:	Startup Routine
;0080 - 00EF:	CPU CALT Table
;00F0 - 018D:	INTT (timer) Routine
;018E - 0277:	Support Routines
;0278 - 057E:	Data (music/font/text)
;057F - 05D0:	Main (Demo) Loop
;05D1 - 06EB:	Paint Program
;06EC - 089C:	Puzzle Program
;089D - 0FFB:	Support Routines & Subroutines
;------------------------------------------------------------
;                  EPOCH GAME MASK ROM
;------------------------------------------------------------
RESET___0000:   nop
________0001:   di
________0003:   jr cont____0013
;------------------------------------------------------------
INT0____0004:   jmp $400C
________0007:   nop
;------------------------------------------------------------
INTT____0008:   jre INTT____00F0
;------------------------------------------------------------
;((HL-) ==> (DE-))xB
; Copies the data pointed to by HL "(HL)" to (DE).
; B holds a single byte for the copy loop count.
CALT_96_000A:   ldax [hl-]
________000B:   stax [de-]
________000C:   dcr b
________000D:   jr CALT_96_000A
________000E:   ret
________000F:   nop
;------------------------------------------------------------
INT1____0010:   jmp $400F
;------------------------------------------------------------
cont____0013:   lxi sp, $0000
________0016:   per                                             ;Set Port E to AB mode
________0018:   mvi a, $C1
________001A:   mov pa, a
________001C:   ani pa, $FE
________001F:   ori pa, $01
________0022:   calt $008A                                      ; "Clear A"
________0023:   mov mb, a                                       ;Mode B = All outputs
________0025:   ori pa, $38

________0028:   mvi a, $39
________002A:   mov pb, a
________002C:   ori pa, $02
________002F:   ani pa, $FD
________0032:   mvi a, $3E
________0034:   mov pb, a
________0036:   ori pa, $02
________0039:   ani pa, $FD
________003C:   ani pa, $C7
________003F:   ori pa, $04
________0042:   mvi a, $07
________0044:   mov tmm, a                                      ;Timer register = #$7
________0046:   mvi a, $74
________0048:   mov tm0, a                                      ;Timer option reg = #$74
________004A:   calt $008E                                      ; "Clear Screen RAM"
________004B:   calt $0090                                      ; "Clear C4B0~C593"
________004C:   calt $0092                                      ; "Clear C594~C86F?"
________004D:   lxi hl, $FF80
________0050:   mvi b, $49
________0052:   calt $0094                                      ; "Clear RAM (HL+)xB"
________0053:   calt $0082                                      ; Copy Screen RAM to LCD Driver
________0054:   mvi a, $05
________0056:   mov mk, a                                       ;Mask = IntT,1 ON
________0058:   ei
________005A:   calt $0080                                      ; [PC+1] Check Cartridge
________005B:   db $C0                                          ;Jump to ($4001) in cartridge
________005C:   jmp ________057F                                ;Flow continues if no cartridge is present.
;------------------------------------------------------------
;(DE+)-(HL+) ==> A
; Loads A with (DE), increments DE, then subtracts (HL) from A and increments HL.
CALT_A1_005F:   ldax [de+]
________0060:   subx [hl+]
________0062:   ret
;------------------------------------------------------------
;?? (Find 1st diff. byte in (HL),(DE)xB)  (Matching byte perhaps?)
; I don't know how useful this is, but I guess it's for advancing pointers to
; the first difference between 2 buffers, etc.
CALT_A2_0063:   calt $00C2                                      ; "(DE+)-(HL+) ==> A"
________0064:   skn z
________0066:   jr ________0068
________0067:   ret

________0068:   dcr b
________0069:   jr CALT_A2_0063
________006A:   xra a, a
________006C:   ret
;------------------------------------------------------------
;?? (Find diff. & Copy bytes)
; I have no idea what purpose this serves...
CALT_A3_006D:   push hl
________006F:   push de
________0071:   push bc
________0073:   calt $00C4                                      ; "?? (Find 1st diff. byte in (HL),(DE)xB)"
________0074:   pop bc
________0076:   pop de
________0078:   pop hl
________007A:   skn cy
________007C:   jr ________007E
________007D:   ret

________007E:   calt $00AA                                      ; "((HL+) ==> (DE+))xB"
________007F:   ret
;------------------------------------------------------------
;This is the call table provided by the CALT instruction in the uPD78xx CPU.
;It provides a way for programs to call commonly-used routines using a single-byte opcode.
;The numbers in the parentheses refer to the opcode for each entry in the table.
;Each table entry contains an address to jump to.  (Quite simple.)

;Opcodes $80-$AD point to routines hard-coded in the uPD78c06 CPU ROM.
;Opcodes $AE-$B7 point to cartridge ROM routines (whose jump tables are at $4012-$402F.)

; "[PC+X]" means the subroutine uses the bytes after its call as parameters.
; the subroutine then usually advances the return address by X bytes before returning.

_CALT_80__0080:   dw CALT_80_01A6	;[PC+1] Check Cartridge
_CALT_81__0082:   dw CALT_81_01CF	;Copy Screen RAM to LCD Driver
_CALT_82__0084:   dw CALT_82_018E	;[PC+2] Setup/Play Sound
_CALT_83__0086:   dw CALT_83_019C	;Setup/Play Music
_CALT_84__0088:   dw CALT_84_091F	;Read Controller FF90-FF95
_CALT_85__008A:   dw CALT_85_089D	;Clear A
_CALT_86__008C:   dw CALT_86_08FF	;Clear Screen 2 RAM
_CALT_87__008E:   dw CALT_87_0902	;Clear Screen RAM
_CALT_88__0090:   dw CALT_88_0915	;Clear C4B0~C593
_CALT_89__0092:   dw CALT_89_090D	;Clear C594~C7FF
_CALT_8A__0094:   dw CALT_8A_091A	;Clear RAM (HL+)xB
_CALT_8B__0096:   dw CALT_8B_0C1B	;HL <== HL+DE
_CALT_8C__0098:   dw CALT_8C_0C0E	;[PC+1] HL +- byte
_CALT_8D__009A:   dw CALT_8D_0C18	;HL <== HL+E
_CALT_8E__009C:   dw CALT_8E_098C	;Swap C258+ <==> C000+
_CALT_8F__009E:   dw CALT_8F_0981	;C000+ ==> C258+
_CALT_90__00A0:   dw CALT_90_097E	;C258+ ==> C000+
_CALT_91__00A2:   dw CALT_91_01CD	;CALT 00A0, CALT 00A4
_CALT_92__00A4:   dw CALT_92_0B37	;?? (Move some RAM around...)
_CALT_93__00A6:   dw CALT_93_08D7	;HL <== AxE
_CALT_94__00A8:   dw CALT_94_08A0	;XCHG HL,DE
_CALT_95__00AA:   dw CALT_95_0D11	;((HL+) ==> (DE+))xB
_CALT_96__00AC:   dw CALT_96_000A	;((HL-) ==> (DE-))xB
_CALT_97__00AE:   dw CALT_97_08F3	;((HL+) <==> (DE+))xB
_CALT_98__00B0:   dw CALT_98_0999	;Set Dot; B,C = X-,Y-position
_CALT_99__00B2:   dw CALT_99_09C7	;[PC+2] Draw Horizontal Line
_CALT_9A__00B4:   dw CALT_9A_09E4	;[PC+3] Print Bytes on-Screen
_CALT_9B__00B6:   dw CALT_9B_0A29	;[PC+3] Print Text on-Screen
_CALT_9C__00B8:   dw CALT_9C_0B0E	;Byte -> Point to Font Graphic
_CALT_9D__00BA:   dw CALT_9D_0BF1	;Set HL to screen (B,C)
_CALT_9E__00BC:   dw CALT_9E_0C24	;HL=C4B0+(A*$10)
_CALT_9F__00BE:   dw CALT_9F_091B	;A ==> (HL+)xB
_CALT_A0__00C0:   dw CALT_A0_0C6E	;(RLR A)x4
_CALT_A1__00C2:   dw CALT_A1_005F	;(DE+)-(HL+) ==> A
_CALT_A2__00C4:   dw CALT_A2_0063	;?? (Find 1st diff. byte in (HL),(DE)xB)
_CALT_A3__00C6:   dw CALT_A3_006D	;?? (Find diff. & Copy bytes)
_CALT_A4__00C8:   dw CALT_A4_0F5D	;[PC+1] 8~32-bit Add/Subtract (dec/hex)
_CALT_A5__00CA:   dw CALT_A5_0F42	;[PC+1] Invert 8 bytes at (C4B8+A*$10)
_CALT_A6__00CC:   dw CALT_A6_0F2C	;Invert Screen RAM (C000~)
_CALT_A7__00CE:   dw CALT_A7_0F2F	;Invert Screen 2 RAM (C258~)
_CALT_A8__00D0:   dw CALT_A8_0E6E	;[PC+1] ?? (Unpack 8 bytes -> 64 bytes (Twice!))
_CALT_A9__00D2:   dw CALT_A9_0E98	;[PC+1] ?? (Unpack & Roll 8 bits)
_CALT_AA__00D4:   dw CALT_AA_0EA4	;[PC+1] ?? (Roll 8 bits -> Byte?)
_CALT_AB__00D6:   dw CALT_AB_0ED2	;[PC+x] ?? (Add/Sub multiple bytes)
_CALT_AC__00D8:   dw CALT_AC_0FD9	;[PC+1] INC/DEC Range of bytes from (HL)
_CALT_AD__00DA:   dw CALT_AD_09B1	;Clear Dot; B,C = X-,Y-position

_CALT_AE__00DC:   dw $4012      ;Jump table for cartridge routines
_CALT_AF__00DE:   dw $4015
_CALT_B0__00E0:   dw $4018
_CALT_B1__00E2:   dw $401B
_CALT_B2__00E4:   dw $401E
_CALT_B3__00E6:   dw $4021
_CALT_B4__00E8:   dw $4024
_CALT_B5__00EA:   dw $4027
_CALT_B6__00EC:   dw $402A
_CALT_B7__00EE:   dw $402D
;-----------------------------------------------------------
;                        Timer Interrupt
INTT____00F0:   oniw [$FF80], $01                               ;If 1, don't jump to cart.
________00F3:   jre ________015B

________00F5:   dcrw [$FF9A]
________00F7:   jre ________0158

________00F9:   push va
________00FB:   ldaw [$FF8F]
________00FD:   staw [$FF9A]
________00FF:   dcrw [$FF99]
________0101:   jre ________012E

________0103:   push bc
________0105:   push de
________0107:   push hl
________0109:   mvi a, $03
________010B:   mov tmm, a                                      ;Adjust timer
________010D:   mvi a, $53
________010F:   dcr a
________0110:   jr ________010F
________0111:   oniw [$FF80], $02
________0114:   jr ________011C

________0115:   lhld [$FF84]
________0119:   calf CALF____08A9                               ;Music-playing code...
________011B:   jr ________0128

________011C:   aniw [$ff80], $fc
________011F:   mvi a, $07
________0121:   mov tmm, a
________0123:   mvi a, $74
________0125:   mov tm0, a
________0127:   stm
________0128:   pop hl
________012A:   pop de
________012C:   pop bc
________012E:   ldaw [$FF88]
________0130:   adi a, $01
________0132:   daa
________0133:   staw [$FF88]
________0135:   skn cy
________0137:   jr ________0139
________0138:   jr ________014E

________0139:   inrw [$FF89]
________013B:   nop
________013C:   ldaw [$FF87]
________013E:   adi a, $01
________0140:   daa
________0141:   staw [$FF87]
________0143:   skn cy
________0145:   jr ________0147
________0146:   jr ________014E

________0147:   ldaw [$FF86]
________0149:   adi a, $01
________014B:   daa
________014C:   staw [$FF86]
________014E:   oniw [$FF8A], $80
________0151:   inrw [$FF8A]
________0153:   inrw [$FF8B]
________0155:   nop
________0156:   pop va
;--------
________0158:   ei
________015A:   reti
;------------------------------------------------------------
________015B:   push va
________015D:   push bc
________015F:   push de
________0161:   push hl
________0163:   offiw [$FF80], $80                              ;If 0, don't go to cart's INT routine
________0166:   jmp $4009
;---------------------------------------
________0169:   adc a, b                                        ;Probably a simple random-number generator.
________016B:   adc a, c
________016D:   adc a, d
________016F:   adc a, e
________0171:   adc a, h
________0173:   adc a, l
________0175:   staw [$FF8C]
________0177:   ral
________0179:   ral
________017B:   mov b, a
________017C:   pop de
________017E:   push de
________0180:   adc a, e
________0182:   staw [$FF8D]
________0184:   rar
________0186:   rar
________0188:   adc a, b
________018A:   staw [$FF8E]
________018C:   jre ________0128
;------------------------------------------------------------
;[PC+2] Setup/Play Sound
; 1st byte is sound pitch (00[silence] to $25); 2nd byte is length.
; Any pitch out of range could overrun the timers & sap the CPU.
CALT_82_018E:   di
________0190:   pop hl
________0192:   ldax [hl+]                                      ;(PC+1)
________0193:   mov b, a
________0194:   ldax [hl+]                                      ;(PC+1)
________0195:   push hl
________0197:   staw [$FF99]
________0199:   calf CALF____08B6                               ;Set note timers
________019B:   jr ________01A3
;------------------------------------------------------------
;Setup/Play Music
;HL should already contain the address of the music data.
;Format of the data string is the same as "Play Sound", with $FF terminating the song.
CALT_83_019C:   di
________019E:   oriw [$FF80], $02
________01A1:   calf CALF____08A9                               ;Read notes & set timers
________01A3:   ei                                              ;(sometimes skipped)
________01A5:   ret
;------------------------------------------------------------
;[PC+1] Check Cartridge
; Checks if the cart is present, and possibly jumps to ($4001) or ($4003)
; The parameter $C0 sends it to $4001, $C1 to $4003, etc...
CALT_80_01A6:   lxi hl, $4000
________01A9:   ldax [hl]
________01AA:   eqi a, $55
________01AC:   rets

________01AD:   calt $008A                                      ; "Clear A"
________01AE:   staw [$FF89]
________01B0:   ldax [hl]
________01B1:   eqi a, $55
________01B3:   rets
;----------------------------------
________01B4:   eqiw [$FF89], $03
________01B7:   jr ________01B0

________01B8:   calf CALF____0E4D                               ;Sets a timer
________01BA:   oriw [$FF80], $80
________01BD:   inx hl                                          ;->$4001
________01BE:   pop bc
________01C0:   ldax [bc]
________01C1:   nei a, $C0                                      ;To cart if it's $C0
________01C3:   jr ________01C8

________01C4:   inx hl                                          ;->$4003
________01C5:   inx hl
________01C6:   dcr a
________01C7:   jr ________01C1

________01C8:   ldax [hl+]
________01C9:   mov c, a
________01CA:   ldax [hl]
________01CB:   mov b, a
________01CC:   jb
;-----------------------------------------------------------
;CALT 00A0, CALT 00A4
; Copies the 2nd screen to the screen buffer & moves some text around
; And updates the LCD...
CALT_91_01CD:   calt $00A0                                      ; "C258+ ==> C000+"
________01CE:   calt $00A4                                      ; "?? (Move some RAM around...)"
;-----------------------------------------------------------
;Copy Screen RAM to LCD Driver
; A very important and often-used function.  The LCD won't show anything without it...
								;Set up writing for LCD controller #1
CALT_81_01CF:   ori pa, $08                                     ;(Port A, bit 3 on)
________01D2:   lxi hl, $C031
________01D5:   lxi de, $007D
________01D8:   mvi b, $00
________01DA:   ani pa, $FB                                     ;bit 2 off
________01DD:   mov a, b
________01DE:   mov pb, a                                       ;Port B = (A)
________01E0:   ori pa, $02                                     ;bit 1 on
________01E3:   ani pa, $FD                                     ;bit 1 off
________01E6:   mvi c, $31
________01E8:   ori pa, $04                                     ;bit 2 on
________01EB:   ldax [hl-]                                      ;Screen data...
________01EC:   mov pb, a                                       ;...to Port B
________01EE:   ori pa, $02                                     ;bit 1 on
________01F1:   ani pa, $FD                                     ;bit 1 off
________01F4:   dcr c
________01F5:   jr ________01EB
________01F6:   calt $0096                                      ; "HL <== HL+DE"
________01F7:   mov a, b
________01F8:   adinc a, $40
________01FA:   jr ________01FE
________01FB:   mov b, a
________01FC:   jre ________01DA
								;Set up writing for LCD controller #2
________01FE:   ani pa, $F7                                     ;bit 3 off
________0201:   ori pa, $10                                     ;bit 4 on
________0204:   lxi hl, $C12C
________0207:   lxi de, $0019
________020A:   mvi b, $00
________020C:   ani pa, $FB                                     ;Same as in 1st loop
________020F:   mov a, b
________0210:   mov pb, a
________0212:   ori pa, $02
________0215:   ani pa, $FD
________0218:   mvi c, $31
________021A:   ori pa, $04
________021D:   ldax [hl+]
________021E:   mov pb, a
________0220:   ori pa, $02
________0223:   ani pa, $FD
________0226:   dcr c
________0227:   jr ________021D
________0228:   calt $0096                                      ; "HL <== HL+DE"
________0229:   mov a, b
________022A:   adinc a, $40
________022C:   jr ________0230
________022D:   mov b, a
________022E:   jre ________020C

________0230:   calt $008A                                      ; "Clear A"
________0231:   staw [$FF96]
        						;Set up writing for LCD controller #3
________0233:   ani pa, $EF                                     ;bit 4 off
________0236:   ori pa, $20                                     ;bit 5 on
________0239:   lxi hl, $C032
________023C:   lxi de, $C15E
________023F:   mvi b, $00
________0241:   ani pa, $FB
________0244:   mov a, b
________0245:   mov pb, a
________0247:   ori pa, $02
________024A:   ani pa, $FD
________024D:   nop
________024E:   ori pa, $04

________0251:   mvi c, $18

________0253:   ldax [hl+]
________0254:   mov pb, a
________0256:   ori pa, $02
________0259:   ani pa, $FD
________025C:   dcr c
________025D:   jr ________0253

________025E:   push de
________0260:   lxi de, $0032
________0263:   calt $0096                                      ; "HL <== HL+DE"
________0264:   pop de
________0266:   calt $00A8                                      ; "XCHG HL,DE"
________0267:   inrw [$FF96]                                    ;Skip if a carry...
________0269:   offiw [$FF96], $01                              ;Do alternating lines
________026C:   jr ________0251

________026D:   mov a, b
________026E:   adinc a, $40
________0270:   jr ________0274
________0271:   mov b, a
________0272:   jre ________0241

________0274:   ani pa, $DF                                     ;bit 5 off
________0277:   ret
;-----------------------------------------------------------
	;Sound note and timer data...
________0278:   #d8 $B2, $0A, $EE, $07, $E1, $08, $D4, $09, $C8, $09, $BD, $0A, $B2, $0A, $A8, $0B
________0288:   #d8 $9E, $0C, $96, $0C, $8D, $0D, $85, $0E, $7E, $0F, $77, $10, $70, $11, $6A, $12
________0298:   #d8 $64, $13, $5E, $14, $59, $15, $54, $16, $4F, $17, $4A, $19, $46, $1A, $42, $1C
________02A8:   #d8 $3E, $1E, $3B, $1F, $37, $22, $34, $23, $31, $26, $2E, $28, $2C, $2A, $29, $2D
________02B8:   #d8 $27, $2F, $25, $31, $23, $34, $21, $37, $1F, $3B, $1D, $3F
;-----------------------------------------------------------
	;Graphic Font Data
________02C4:   #d8 $00, $00, $00, $00, $00, $00, $00, $4F, $00, $00, $00, $07, $00, $07, $00, $14
________02D4:   #d8 $7F, $14, $7F, $14, $24, $2A, $7F, $2A, $12, $23, $13, $08, $64, $62, $36, $49
________02E4:   #d8 $55, $22, $50, $00, $05, $03, $00, $00, $00, $1C, $22, $41, $00, $00, $41, $22
________02F4:   #d8 $1C, $00, $14, $08, $3E, $08, $14, $08, $08, $3E, $08, $08, $00, $50, $30, $00
________0304:   #d8 $00, $08, $08, $08, $08, $08, $00, $60, $60, $00, $00, $20, $10, $08, $04, $02
________0314:   #d8 $3E, $51, $49, $45, $3E, $00, $42, $7F, $40, $00, $42, $61, $51, $49, $46, $21
________0324:   #d8 $41, $45, $4B, $31, $18, $14, $12, $7F, $10, $27, $45, $45, $45, $39, $3C, $4A
________0334:   #d8 $49, $49, $30, $01, $71, $09, $05, $03, $36, $49, $49, $49, $36, $06, $49, $49
________0344:   #d8 $29, $1E, $00, $36, $36, $00, $00, $00, $56, $36, $00, $00, $08, $14, $22, $41
________0354:   #d8 $00, $14, $14, $14, $14, $14, $00, $41, $22, $14, $08, $02, $01, $51, $09, $06
________0364:   #d8 $32, $49, $79, $41, $3E, $7E, $11, $11, $11, $7E, $7F, $49, $49, $49, $36, $3E
________0374:   #d8 $41, $41, $41, $22, $7F, $41, $41, $22, $1C, $7F, $49, $49, $49, $49, $7F, $09
________0384:   #d8 $09, $09, $01, $3E, $41, $49, $49, $7A, $7F, $08, $08, $08, $7F, $00, $41, $7F
________0394:   #d8 $41, $00, $20, $40, $41, $3F, $01, $7F, $08, $14, $22, $41, $7F, $40, $40, $40
________03A4:   #d8 $40, $7F, $02, $0C, $02, $7F, $7F, $04, $08, $10, $7F, $3E, $41, $41, $41, $3E
________03B4:   #d8 $7F, $09, $09, $09, $06, $3E, $41, $51, $21, $5E, $7F, $09, $19, $29, $46, $46
________03C4:   #d8 $49, $49, $49, $31, $01, $01, $7F, $01, $01, $3F, $40, $40, $40, $3F, $1F, $20
________03D4:   #d8 $40, $20, $1F, $3F, $40, $38, $40, $3F, $63, $14, $08, $14, $63, $07, $08, $70
________03E4:   #d8 $08, $07, $61, $51, $49, $45, $43, $00, $7F, $41, $41, $00, $15, $16, $7C, $16
________03F4:   #d8 $15, $00, $41, $41, $7F, $00, $04, $02, $01, $02, $04, $40, $40, $40, $40, $40
________0404:   #d8 $00, $1F, $11, $11, $1F, $00, $00, $11, $1F, $10, $00, $1D, $15, $15, $17, $00
________0414:   #d8 $11, $15, $15, $1F, $00, $0F, $08, $1F, $08, $00, $17, $15, $15, $1D, $00, $1F
________0424:   #d8 $15, $15, $1D, $00, $03, $01, $01, $1F, $00, $1F, $15, $15, $1F, $00, $17, $15
________0434:   #d8 $15, $1F, $1E, $09, $09, $09, $1E, $1F, $15, $15, $15, $0A, $0E, $11, $11, $11
________0444:   #d8 $11, $1F, $11, $11, $11, $0E, $1F, $15, $15, $15, $11, $1F, $05, $05, $05, $01
________0454:   #d8 $0E, $11, $11, $15, $1D, $1F, $04, $04, $04, $1F, $00, $11, $1F, $11, $00, $08
________0464:   #d8 $10, $11, $0F, $01, $1F, $08, $04, $0A, $11, $1F, $10, $10, $10, $10, $1F, $02
________0474:   #d8 $04, $02, $1F, $1F, $02, $04, $08, $1F, $0E, $11, $11, $11, $0E, $1F, $05, $05
________0484:   #d8 $05, $02, $0E, $11, $15, $09, $16, $1F, $05, $05, $0D, $12, $12, $15, $15, $15
________0494:   #d8 $09, $01, $01, $1F, $01, $01, $0F, $10, $10, $10, $0F, $07, $08, $10, $08, $07
________04A4:   #d8 $0F, $10, $0C, $10, $0F, $1B, $0A, $04, $0A, $1B, $03, $04, $18, $04, $03, $11
________04B4:   #d8 $19, $15, $13, $11
;-----------------------------------------------------------
	;Text data
________04B8:   #d8 $2C, $23, $24, $00, $24, $2F, $34, $00, $2D, $21, $34, $32, $29, $38, $00, $33	;LCD DOT MATRIX SYSTEM
________04C8:   #d8 $39, $33, $34, $25, $2D, $00, $26, $35, $2C, $2C, $00, $27, $32, $21, $30, $28 ;FULL GRAPHIC
________04D8:   #d8 $29, $23, $00, $08, $17, $15, $0A, $16, $14, $00, $24, $2F, $34, $33, $09, $00 ;(75*64 DOTS)
________04E8:   #d8 $00, $00, $00, $FF
	;Music notation data
________04EC:   #d8 $00, $0A, $06, $0A, $0B, $0A, $0F, $0A, $12, $14, $12, $14
________04F8:   #d8 $12, $14, $12, $14, $0A, $14, $0A, $14, $0B, $14, $0B, $07, $0D, $07, $0B, $07
________0508:   #d8 $10, $14, $10, $14, $0F, $14, $0F, $14, $0D, $28, $00, $0A, $06, $0A, $0B, $0A
________0518:   #d8 $0F, $0A, $12, $14, $12, $14, $12, $14, $12, $14, $0A, $14, $0A, $07, $0B, $07
________0528:   #d8 $0A, $07, $0B, $14, $0B, $07, $0D, $07, $0B, $07, $0D, $14, $0D, $14, $06, $14
________0538:   #d8 $08, $0A, $0A, $0A, $0B, $3C, $00, $50, $FF
	;Text data
________0541:   #d8 $27, $32, $21, $0E, $00, $38, $10, $10, $0C, $39, $10, $10     		;GRA. X00,Y00

________054D:   #d8 $30, $35, $3A, $3A, $2C, $25                ;PUZZLE

________0553:   #d8 $34, $29, $2D, $25, $1B, $10, $10, $10, $0E, $10      			;TIME:000.0
	;Grid data, probably
________055D:   #d8 $04, $04, $08, $01, $01, $08, $04, $04, $08, $01, $01, $02, $04, $04, $02, $01
________056D:   #d8 $01, $02

________056F:   #d8 $08, $04, $02, $04, $08, $08, $08, $01, $02, $01, $08, $04, $02, $02, $04, $02
;-----------------------------------------------------------
;from 005C -

________057F:   calt $008C                                      ;Clear Screen 2 RAM
________0580:   staw [$FFD8]                                    ;Set mem locations to 0
________0582:   staw [$FF82]
________0584:   staw [$FFA5]
________0586:   lxi hl, ________04B8                            ;Start of scrolltext
________0589:   shld [$FFD6]                                    ;Save pointer
________058D:   calf CALF____0D68                               ;Setup RAM vars
________058F:   calt $00A0                                      ; "C258+ ==> C000+"
________0590:   calt $0082                                      ;Copy Screen RAM to LCD Driver
________0591:   calt $008A                                      ; "Clear A"
________0592:   staw [$FFDA]
________0594:   staw [$FFD1]
________0596:   staw [$FFD2]
________0598:   staw [$FFD5]
________059A:   mvi a, $FF
________059C:   staw [$FFD0]
________059E:   lxi hl, $FFD8
________05A1:   xrax [hl]                                       ;A=$FF XOR ($FFD8)
________05A3:   staw [$FFD8]
________05A5:   mvi a, $60                                      ;A delay value for the scrolltext
________05A7:   staw [$FF8A]

;Main Loop starts here!
________05A9:   calt $0080                                      ;[PC+1] Check Cartridge
________05AA:   db $C1                                          ;Jump to ($4003) in cartridge

________05AB:   offiw [$FF80], $02                              ;If bit 1 is on, no music
________05AE:   jr ________05B2
________05AF:   calf CALF____0E64                               ;Point HL to the music data
________05B1:   calt $0086                                      ;Setup/Play Music
________05B2:   calt $0088                                      ;Read Controller FF90-FF95
________05B3:   neiw [$FF93], $01                               ;If Select is pressed...
________05B6:   jmp ________06EC                                ;Setup puzzle
________05B9:   neiw [$FFD2], $0F
________05BC:   jre ________0591                                ;(go to main loop setup)
________05BE:   calf CALF____0D1F                               ;Draw spiral dot-by-dot
________05C0:   calf CALF____0D1F                               ;Draw spiral dot-by-dot
________05C2:   calt $00A0                                      ; "C258+ ==> C000+"
________05C3:   calt $0082                                      ;Copy Screen RAM to LCD Driver
________05C4:   neiw [$FF93], $08                               ;If Start is pressed...
________05C7:   jr ________05D1                                 ;Jump to graphic program

________05C8:   eqiw [$FF8A], $80                               ;Delay for the scrolltext
________05CB:   jre ________05A9                                ;JRE Main Loop
________05CD:   calf CALF____0CE2                               ;Scroll Text routine
________05CF:   jre ________05A5                                ;Reset scrolltext delay...
;-----------------------------------------------------------
;"Paint" program setup routines
________05D1:   calf CALF____0E4D                               ;Turn timer on
________05D3:   calt $008C                                      ; "Clear Screen 2 RAM"
________05D4:   calt $0090                                      ; "Clear C4B0~C593"
________05D5:   lxi hl, ________0541                            ;"GRA"
________05D8:   calt $00B6                                      ; "[PC+3] Print Text on-Screen"
________05D9:   db $02, $00, $1C                                ;Parameters for the text routine
________05DC:   mvi a, $05
________05DE:   lxi hl, $C4B8
________05E1:   stax [hl+]
________05E2:   inx hl
________05E3:   stax [hl]
________05E4:   inr a
________05E5:   lxi hl, $C570
________05E8:   stax [hl+]
________05E9:   inr a
________05EA:   staw [$FFA6]
________05EC:   mvi a, $39
________05EE:   stax [hl+]
________05EF:   inr a
________05F0:   staw [$FFA7]
________05F2:   calt $008A                                      ; "Clear A"
________05F3:   stax [hl+]
________05F4:   staw [$FFA0]                                    ;X,Y position for cursor
________05F6:   staw [$FFA1]
________05F8:   mvi a, $99                                      ;What does this do?
________05FA:   mvi b, $0A
________05FC:   inx hl
________05FD:   inx hl
________05FE:   stax [hl+]		                                ;Just writes "99s" 3 bytes apart
________05FF:   inx hl
________0600:   inx hl
________0601:   dcr b
________0602:   jr ________05FE
________0603:   calf CALF____0D68                               ;Draw Border

________0605:   mvi a, $70
________0607:   staw [$FF8A]
________0609:   lxi hl, $FFA0                                   ;Print the X-, Y- position
________060C:   calt $00B4                                      ; "[PC+3] Print Bytes on-Screen"
________060D:   db $26, $00, $19                                ;Parameters for the print routine
________0610:   lxi hl, $FFA1
________0613:   calt $00B4                                      ; "[PC+3] Print Bytes on-Screen"
________0614:   db $3E, $00, $19                                ;Parameters for the print routine
________0617:   calt $00A2                                      ; "CALT A0, CALT A4"
________0618:   calt $0080                                      ;[PC+1] Check Cartridge
________0619:   db $C1                                          ;Jump to ($4003) in cartridge

________061A:   oniw [$FF8A], $80
________061D:   jr ________0618
________061E:   lxi hl, $C572
________0621:   ldax [hl]
________0622:   xri a, $FF
________0624:   stax [hl]
________0625:   calt $0088                                      ;Read Controller FF90-FF95
________0626:   ldaw [$FF93]
________0628:   offi a, $3F                                     ;Test Buttons 1,2,3,4
________062A:   jr ________0633
________062B:   ldaw [$FF92]
________062D:   offi a, $0F                                     ;Test U,D,L,R
________062F:   jre ________0673
________0631:   jre ________0605
;------------------------------------------------------------
________0633:   oniw [$FF95], $09
________0636:   jr ________0647
________0637:   eqi a, $08                                      ;Start clears the screen
________0639:   jr ________063F

________063A:   calt $0084                                      ;[PC+2] Setup/Play Sound
________063B:   db $22, $03
________063D:   jre ________05DC                                ;Clear screen

________063F:   eqi a, $01                                      ;Select goes to the Puzzle
________0641:   jr ________0647

________0642:   calt $0084                                      ;[PC+2] Setup/Play Sound
________0643:   db $23, $03
________0645:   jre ________06EE                                ;To Puzzle Setup

________0647:   eqi a, $02                                      ;Button 1
________0649:   jr ________064E
________064A:   calt $0084                                      ;[PC+2] Setup/Play Sound
________064B:   db $19, $03
________064D:   jr ________0664                                 ;Clear a dot

________064E:   eqi a, $10                                      ;Button 2
________0650:   jr ________0655
________0651:   calt $0084                                      ;[PC+2] Setup/Play Sound
________0652:   db $1B, $03
________0654:   jr ________0664                                 ;Clear a dot

________0655:   eqi a, $04                                      ;Button 3
________0657:   jr ________065C
________0658:   calt $0084                                      ;[PC+2] Setup/Play Sound
________0659:   db $1D, $03
________065B:   jr ________066C                                 ;Set a dot

________065C:   eqi a, $20                                      ;Button 4
________065E:   jre ________0680
________0660:   calt $0084                                      ;[PC+2] Setup/Play Sound
________0661:   db $1E, $03
________0663:   jr ________066C                                 ;Set a dot

________0664:   ldaw [$FFA6]
________0666:   mov b, a
________0667:   ldaw [$FFA7]
________0669:   mov c, a
________066A:   calt $00DA                                      ; "Clear Dot; B,C = X-,Y-position"
________066B:   jr ________0673

________066C:   ldaw [$FFA6]
________066E:   mov b, a
________066F:   ldaw [$FFA7]
________0671:   mov c, a
________0672:   calt $00B0                                      ; "Set Dot; B,C = X-,Y-position"

________0673:   ldaw [$FF92]
________0675:   nei a, $0F                                      ;Check if U,D,L,R pressed at once??
________0677:   jre ________0605
________0679:   oni a, $01                                      ;Up
________067B:   jr ________0694

________067C:   ldaw [$FFA7]
________067E:   nei a, $0E                                      ;Check lower limits of X-pos
________0680:   jr ________069B

________0681:   dcr a
________0682:   staw [$FFA7]
________0684:   dcr a
________0685:   mov [$C571], a
________0689:   ldaw [$FFA1]
________068B:   adi a, $01
________068D:   daa
________068E:   staw [$FFA1]
________0690:   calt $0084                                      ;[PC+2] Setup/Play Sound
________0691:   db $12, $03
________0693:   jr ________06AE

________0694:   oni a, $04                                      ;Down
________0696:   jr ________06AE

________0697:   ldaw [$FFA7]
________0699:   nei a, $3A                                      ;Check lower cursor limit
________069B:   jr ________06B7

________069C:   inr a
________069D:   staw [$FFA7]
________069F:   dcr a
________06A0:   mov [$C571], a
________06A4:   ldaw [$FFA1]
________06A6:   adi a, $99
________06A8:   daa
________06A9:   staw [$FFA1]
________06AB:   calt $0084                                      ;[PC+2] Setup/Play Sound
________06AC:   db $14, $03

________06AE:   ldaw [$FF92]
________06B0:   oni a, $08                                      ;Right
________06B2:   jr ________06CC

________06B3:   ldaw [$FFA6]
________06B5:   nei a, $43
________06B7:   jr ________06D4

________06B8:   inr a
________06B9:   staw [$FFA6]
________06BB:   dcr a
________06BC:   mov [$C570], a
________06C0:   ldaw [$FFA0]
________06C2:   adi a, $01
________06C4:   daa
________06C5:   staw [$FFA0]
________06C7:   calt $0084                                      ;[PC+2] Setup/Play Sound
________06C8:   db $17, $03
________06CA:   jre ________0605

________06CC:   oni a, $02                                      ;Left
________06CE:   jre ________0605
________06D0:   ldaw [$FFA6]
________06D2:   nei a, $07
________06D4:   jr ________06E8

________06D5:   dcr a
________06D6:   staw [$FFA6]
________06D8:   dcr a
________06D9:   mov [$C570], a
________06DD:   ldaw [$FFA0]
________06DF:   adi a, $99
________06E1:   daa
________06E2:   staw [$FFA0]
________06E4:   calt $0084                                      ;[PC+2] Setup/Play Sound
________06E5:   db $16, $03
________06E7:   jr ________06CA
;------------------------------------------------------------
________06E8:   calt $0084                                      ;[PC+2] Setup/Play Sound
________06E9:   db $01, $03
________06EB:   jr ________06E7
;------------------------------------------------------------
;Puzzle Setup Routines...
________06EC:   calf CALF____0E4D                               ;Reset the timer?
________06EE:   mvi a, $21
________06F0:   mvi b, $0A
________06F2:   calf CALF____0E67                               ;LXI H,$C7F2
________06F4:   stax [hl+]
________06F5:   inr a                                           ;Set up the puzzle tiles in RAM
________06F6:   dcr b
________06F7:   jr ________06F4
________06F8:   mov a, b                                        ;$FF
________06F9:   stax [hl+]
________06FA:   calf CALF____0E67
________06FC:   mvi b, $0B
________06FE:   lxi de, $C75E
________0701:   calt $00AA                                      ; "((HL+) ==> (DE+))xB"
________0702:   mvi b, $0B
________0704:   lxi hl, $C75E
________0707:   lxi de, $C752
________070A:   calt $00AA                                      ; "((HL+) ==> (DE+))xB"
________070B:   calt $008C                                      ; "Clear Screen 2 RAM"
________070C:   calf CALF____0D68                               ;Draw Border
________070E:   calf CALF____0D92                               ;Draw the grid
________0710:   calf CALF____0C7B                               ;Write "PUZZLE"
________0712:   aniw [$FF89], $00
________0715:   mvi a, $60
________0717:   staw [$FF8A]
________0719:   calt $0080                                      ;[PC+1] Check Cartridge
________071A:   db $C1                                          ;Jump to ($4003) in cartridge
;------------------------------------------------------------
________071B:   mvi b, $0B
________071D:   lxi hl, $C752
________0720:   lxi de, $C7F2
________0723:   calt $00AA                                      ; "((HL+) ==> (DE+))xB"
________0724:   mvi b, $11
________0726:   lxi hl, ________055D                            ;Point to "grid" data
________0729:   ldax [hl+]
________072A:   push bc
________072C:   push hl
________072E:   calf CALF____0DD3                               ;This probably draws the tiles
________0730:   nop                                             ;Or randomizes them??
________0731:   pop hl
________0733:   pop bc
________0735:   dcr b
________0736:   jr ________0729
________0737:   mvi b, $0B        
________0739:   calf CALF____0E67                               ;LXI H,$C7F2
________073B:   lxi de, $C752
________073E:   calt $00AA                                      ; "((HL+) ==> (DE+))xB"
________073F:   calt $0088                                      ;Read Controller FF90-FF95
________0740:   neiw [$FF93], $01                               ;Select
________0743:   oniw [$FF95], $01                               ;Select trigger
________0746:   jr ________074D
________0747:   calt $0084                                      ;[PC+2] Setup/Play Sound
________0748:   db $14, $03
________074A:   jmp ________05D1                                ;Go to Paint Program
________074D:   neiw [$FF93], $08                               ;Start
________0750:   oniw [$FF95], $08
________0753:   jr ________0758
________0754:   calt $0084                                      ;[PC+2] Setup/Play Sound
________0755:   db $16, $03
________0757:   jr ________0765
;------------------------------------------------------------
________0758:   eqiw [$FF8A], $80
________075B:   jre ________0719                                ;Draw Tiles
________075D:   eqiw [$FF89], $3C
________0760:   jre ________0715                                ;Reset timer?
________0762:   jmp ________057F                                ;Go back to startup screen(?)
;------------------------------------------------------------
________0765:   calt $008C                                      ; "Clear Screen 2 RAM"
________0766:   lxi hl, ________0553                            ;"TIME"
________0769:   calt $00B6                                      ; "[PC+3] Print Text on-Screen"
________076A:   db $0E, $00, $1A
________076D:   lxi hl, $FF86
________0770:   mvi b, $02
________0772:   calt $0094                                      ; "Clear RAM (HL+)xB"
________0773:   ldaw [$FF8C]
________0775:   ani a, $0F
________0777:   mov b, a
________0778:   lxi hl, ________056F
________077B:   ldax [hl+]
________077C:   push bc
________077E:   push hl
________0780:   calf CALF____0DD3                               ;Draw Tiles
________0782:   nop
________0783:   pop hl
________0785:   pop bc
________0787:   dcr b
________0788:   jr ________077B
________0789:   calf CALF____0D68                               ;Draw Border (again)
________078B:   calf CALF____0D92                               ;Draw the grid (again)
________078D:   calf CALF____0C82                               ;Scroll text? Write time in decimal?
________078F:   mvi a, $60
________0791:   staw [$FF8A]
________0793:   calt $0080                                      ;[PC+1] Check Cartridge
________0794:   db $C1                                          ;Jump to ($4003) in cartridge
;------------------------------------------------------------
________0795:   lxi hl, $FF86
________0798:   calt $00B4                                      ; "[PC+3] Print Bytes on-Screen"
________0799:   db $2C, $00, $12
________079C:   lxi hl, $FF88
________079F:   calt $00B4                                      ; "[PC+3] Print Bytes on-Screen"
________07A0:   db $44, $00, $08
________07A3:   calt $00A0                                      ; "C258+ ==> C000+"
________07A4:   calt $0082                                      ;Copy Screen RAM to LCD Driver
________07A5:   calt $0088                                      ;Read Controller FF90-FF95
________07A6:   neiw [$FF93], $01                               ;Select
________07A9:   jre ________0747                                ;To Paint Program
________07AB:   neiw [$FF93], $08                               ;Start
________07AE:   oniw [$FF95], $08                               ;Start trigger
________07B1:   jr ________07B4
________07B2:   jre ________0754                                ;Restart puzzle
;------------------------------------------------------------
________07B4:   eqiw [$FF8A], $80
________07B7:   jre ________0793
________07B9:   ldaw [$FF92]                                    ;Joypad
________07BB:   oni a, $0F
________07BD:   jre ________078F                                ;Keep looping
________07BF:   calf CALF____0DD3                               ;Draw Tiles
________07C1:   jr ________07C6
;------------------------------------------------------------
________07C2:   calt $0084                                      ;[PC+2] Setup/Play Sound
________07C3:   db $01, $03
________07C5:   jr ________07BD
;------------------------------------------------------------
________07C6:   push va
________07C8:   mvi a, $03
________07CA:   staw [$FF99]
________07CC:   di  
________07CE:   calf CALF____08B6                               ;Play Music (Snd)
________07D0:   ei
________07D2:   lxi hl, $C7FE
________07D5:   ldax [hl+]
________07D6:   mov b, a
________07D7:   ldax [hl-]
________07D8:   lta a, b
________07DA:   jr ________07DD
________07DB:   mov b, a
________07DC:   ldax [hl]
________07DD:   push bc
________07DF:   eqiw [$FFA2], $00
________07E2:   jre ________0823
________07E4:   calf CALF____0CBF                               ;Write Text(?)
________07E6:   inx hl
________07E7:   calt $00B2                                      ; "[PC+2] Draw Horizontal Line"
________07E8:   db $00, $8E
________07EA:   calf CALF____0C77                               ;HL + $3C
________07EC:   push hl
________07EE:   calt $00B2                                      ; "[PC+2] Draw Horizontal Line"
________07EF:   db $F0, $0E
________07F1:   pop hl
________07F3:   calt $00B2                                      ; "[PC+2] Draw Horizontal Line"
________07F4:   db $F0, $8E
________07F6:   calf CALF____0C77                               ;HL + $3C
________07F8:   calt $00B2                                      ; "[PC+2] Draw Horizontal Line"
________07F9:   db $1F, $0F
________07FB:   pop bc
________07FD:   mov a, b
________07FE:   calf CALF____0CBF                               ;Write Text(?)
________0800:   calt $00B2                                      ; "[PC+2] Draw Horizontal Line"
________0801:   db $F0, $0F
________0803:   calf CALF____0C77                               ;HL + $3C
________0805:   push hl
________0807:   calt $00B2                                      ; "[PC+2] Draw Horizontal Line"
________0808:   db $0F, $0E
________080A:   pop hl
________080C:   calt $00B2                                      ; "[PC+2] Draw Horizontal Line"
________080D:   db $0F, $8E
________080F:   mvi e, $41
________0811:   calt $009A                                      ; "HL <== HL+E"
________0812:   pop va
________0814:   push hl
________0816:   calt $00B8                                      ;Byte -> Point to Font Graphic
________0817:   pop de
________0819:   mvi b, $04
________081B:   ldax [hl+]
________081C:   ral
________081E:   stax [de+]
________081F:   dcr b
________0820:   jr ________081B
________0821:   jre ________0875
;------------------------------------------------------------
________0823:   calf CALF____0CBF                               ;Write Text(?)
________0825:   mvi b, $07
________0827:   inx hl
________0828:   dcr b
________0829:   jr ________0827
________082A:   mvi a, $01
________082C:   staw [$FFA5]
________082E:   calt $00B2                                      ; "[PC+2] Draw Horizontal Line"
________082F:   db $E0, $08
________0831:   mvi e, $42
________0833:   calt $009A                                      ; "HL <== HL+E"
________0834:   calt $00B2                                      ; "[PC+2] Draw Horizontal Line"
________0835:   db $FF, $08
________0837:   mvi e, $42
________0839:   calt $009A                                      ; "HL <== HL+E"
________083A:   calt $00B2                                      ; "[PC+2] Draw Horizontal Line"
________083B:   db $1F, $08
________083D:   ldaw [$FFA5]
________083F:   dcr a
________0840:   jr ________0842
________0841:   jr ________084C

________0842:   staw [$FFA5]
________0844:   pop bc
________0846:   mov a, b
________0847:   staw [$FFA2]
________0849:   calf CALF____0CBF                               ;Write Text(?)
________084B:   jr ________082E

________084C:   ldaw [$FFA2]
________084E:   calf CALF____0CBF                               ;Write Text(?)
________0850:   mvi e, $09
________0852:   calt $009A                                      ; "HL <== HL+E"
________0853:   calt $00B2                                      ; "[PC+2] Draw Horizontal Line"
________0854:   db $1F, $8E
________0856:   calf CALF____0C77                               ;HL + $3C
________0858:   calt $00B2                                      ; "[PC+2] Draw Horizontal Line"
________0859:   db $00, $8E
________085B:   calf CALF____0C77                               ;HL + $3C
________085D:   calt $00B2                                      ; "[PC+2] Draw Horizontal Line"
________085E:   db $F0, $8E
________0860:   mvi b, $54                                      ;Decrement HL 55 times!
________0862:   dcx hl                                          ;Is this a delay or something?
________0863:   dcr b                                           ;There's already a CALT that subs HL...
________0864:   jr ________0862
________0865:   calt $00A8                                      ; "XCHG HL,DE"
________0866:   pop va
________0868:   push de
________086A:   calt $00B8                                      ;Byte -> Point to Font Graphic
________086B:   pop de
________086D:   mvi b, $04
________086F:   ldax [hl+]
________0870:   ral 
________0872:   stax [de+]
________0873:   dcr b
________0874:   jr ________086F
________0875:   lxi hl, $FF88
________0878:   calt $00B4                                      ; "[PC+3] Print Bytes on-Screen"
________0879:   db $44, $00, $08
________087C:   calt $00A0                                      ; "C258+ ==> C000+"
________087D:   calt $0082                                      ;Copy Screen RAM to LCD Driver
________087E:   calf CALF____0D68                               ;Draw Border
________0880:   calf CALF____0D92                               ;Draw Puzzle Grid
________0882:   calf CALF____0C82                               ;Scroll text? Write time in decimal?
________0884:   mvi b, $0B
________0886:   lxi hl, $C75E
________0889:   lxi de, $C7F2
________088C:   ldax [hl+]
________088D:   eqax [de+]
________088F:   jre ________07C5
________0891:   dcr b
________0892:   jr ________088C
________0893:   calf CALF____0E64                               ;Point HL to music data
________0895:   calt $0086                                      ;Setup/Play Music
________0896:   oniw [$FF80], $03
________0899:   jmp ________0712                                ;Continue puzzle
________089C:   jr ________0896
;End of Puzzle Code
;------------------------------------------------------------
;Clear A
CALT_85_089D:   mvi a, $00
________089F:   ret
;------------------------------------------------------------
;XCHG HL,DE
CALT_94_08A0:   push hl
________08A2:   push de
________08A4:   pop hl
________08A6:   pop de
________08A8:   ret
;------------------------------------------------------------
;Music-playing code...
CALF____08A9:   ldax [hl+]
________08AA:   mov b, a
________08AB:   ldax [hl+]
________08AC:   staw [$FF99]
________08AE:   shld [$FF84]
________08B2:   mov a, b
________08B3:   inr a
________08B4:   jr CALF____08B6
________08B5:   rets                                            ;Return & Skip if read "$FF"

;Move "note" into TM0
CALF____08B6:   lxi hl, ________0278                            ;Table Start
________08B9:   mov a, b
________08BA:   suinb a, $01
________08BC:   jr ________08C0
________08BD:   inx hl                                          ;Add A*2 to HL (wastefully)
________08BE:   inx hl
________08BF:   jr ________08BA

________08C0:   ldax [hl+]
________08C1:   mov tm0, a
________08C3:   ldax [hl]
________08C4:   staw [$FF9A]
________08C6:   staw [$FF8F]
________08C8:   dcr b
________08C9:   mvi a, $00                                      ;Sound?
________08CB:   mvi a, $03                                      ;Silent
________08CD:   mov tmm, a
________08CF:   oriw [$FF80], $01
________08D2:   stm
________08D3:   ret
;------------------------------------------------------------
;Load a "multiplication table" for A,E from (HL) and do AxE
;Is this ever used?
________08D4:   ldax [hl+]
________08D5:   mov e, a
________08D6:   ldax [hl]
;HL <== AxE
CALT_93_08D7:   lxi hl, $0000
________08DA:   mvi d, $00
________08DC:   gti a, $00
________08DE:   ret
________08DF:   clc
________08E1:   rar
________08E3:   push va
________08E5:   skn cy
________08E7:   calt $0096                                      ; "HL <== HL+DE"
________08E8:   mov a, e
________08E9:   add a, a
________08EB:   mov e, a
________08EC:   mov a, d
________08ED:   ral
________08EF:   mov d, a
________08F0:   pop va
________08F2:   jr ________08DC
;-----------------------------
;((HL+) <==> (DE+))xB
;This function swaps the contents of (HL)<->(DE) B times
CALT_97_08F3:   calf CALF____08F8                               ;Swap (HL+)<->(DE+)
________08F5:   dcr b
________08F6:   jr CALT_97_08F3
________08F7:   ret
;------------------------------------------------------------
;Swap (HL+)<->(DE+)
CALF____08F8:   ldax [hl]
________08F9:   mov c, a
________08FA:   ldax [de]
________08FB:   stax [hl+]
________08FC:   mov a, c
________08FD:   stax [de+]
________08FE:   ret
;------------------------------------------------------------
;Clear Screen 2 RAM
CALT_86_08FF:   lxi hl, $C258                                   ;RAM for screen 2
;Clear Screen RAM
CALT_87_0902:   lxi hl, $C000                                   ;RAM for screen 1
CALF____0905:   mvi c, $02
________0907:   mvi b, $C7                                      ;$C8 bytes * 3 loops
________0909:   calt $0094                                      ; "Clear RAM (HL+)xB"
________090A:   dcr c
________090B:   jr ________0907
________090C:   ret
;------------------------------------------------------------
;Clear C594~C7FF
CALT_89_090D:   lxi hl, $C594                                   ;Set HL
________0910:   calf CALF____0905                               ;And jump to above routine
________0912:   mvi b, $13                                      ;Then clear $14 more bytes
________0914:   jr CALT_8A_091A                                 ;Clear RAM (HL+)xB

;Clear C4B0~C593
CALT_88_0915:   lxi hl, $C4B0                                   ;Set RAM pointer
________0918:   mvi b, $E3                                      ;and just drop into the func.

;Clear RAM (HL+)xB
CALT_8A_091A:   calt $008A                                      ; "Clear A"
;A ==> (HL+)xB
CALT_9F_091B:   stax [hl+]
________091C:   dcr b
________091D:   jr CALT_9F_091B
________091E:   ret
;------------------------------------------------------------
;Read Controller FF90-FF95
CALT_84_091F:   lxi hl, $FF92                                   ;Current joy storage
________0922:   lxi de, $FF90                                   ;Old joy storage
________0925:   mvi b, $01                                      ;Copy 2 bytes from curr->old
________0927:   calt $00AA                                      ; "((HL+) ==> (DE+))xB"
________0928:   ani pa, $BF                                     ;PA Bit 6 off
________092B:   mov a, pc                                       ;Get port C
________092D:   xri a, $FF
________092F:   mov c, a
________0930:   mvi b, $40                                      ;Debouncing delay
________0932:   dcr b
________0933:   jr ________0932
________0934:   mov a, pc                                       ;Get port C a 2nd time
________0936:   xri a, $FF
________0938:   eqa a, c                                        ;Check if both reads are equal
________093A:   jr ________092F
________093B:   ori pa, $40                                     ;PA Bit 6 on
________093E:   ani a, $03
________0940:   stax [de+]                                      ;Save controller read in 92
________0941:   mov a, c
________0942:   calf CALF____0C72                               ;RLR A x2
________0944:   ani a, $07
________0946:   stax [de-]                                      ;Save cont in 93
________0947:   ani pa, $7F                                     ;PA bit 7 off
________094A:   mov a, pc                                       ;Get other controller bits
________094C:   xri a, $FF
________094E:   mov c, a
________094F:   mvi b, $40                                      ;...and debounce
________0951:   dcr b
________0952:   jr ________0951
________0953:   mov a, pc
________0955:   xri a, $FF
________0957:   eqa a, c                                        ;...check again
________0959:   jr ________094E
________095A:   ori pa, $80                                     ;PA bit 7 on
________095D:   ral
________095F:   ral
________0961:   ani a, $0C
________0963:   orax [de]                                       ;Or with FF92
________0965:   stax [de+]                                      ;...and save
________0966:   mov a, c
________0967:   ral 
________0969:   ani a, $38
________096B:   orax [de]                                       ;Or with FF93
________096D:   stax [de-]                                      ;...and save
________096E:   lxi hl, $FF90                                   ;Get our new,old
________0971:   lxi bc, $FF94
________0974:   ldax [hl+]                                      ;And XOR to get controller strobe
________0975:   xrax [de+]                                      ;But this strobe function is stupid:
________0977:   stax [bc]                                       ;Bits go to 1 whenever the button is
________0978:   inx bc                                          ;initially pressed AND released...
________0979:   ldax [hl]
________097A:   xrax [de]
________097C:   stax [bc]
________097D:   ret
;------------------------------------------------------------
;C258+ ==> C000+
CALT_90_097E:   calf CALF____0E5E
________0980:   jr ________0984
;C000+ ==> C258+
CALT_8F_0981:   calf CALF____0E5E
________0983:   calt $00A8                                      ; "XCHG HL,DE"
________0984:   mvi c, $02
________0986:   mvi b, $C7
________0988:   calt $00AA                                      ; "((HL+) ==> (DE+))xB"
________0989:   dcr c
________098A:   jr ________0986
________098B:   ret
;------------------------------------------------------------
;Swap C258+ <==> C000+
CALT_8E_098C:   calf CALF____0E5E
________098E:   lxi bc, $C702
________0991:   push bc
________0993:   calt $00AE                                      ; "((HL+) <==> (DE+))xB"
________0994:   pop bc
________0996:   dcr c
________0997:   jr ________0991
________0998:   ret
;------------------------------------------------------------
;Set Dot; B,C = X-,Y-position
;(Oddly enough, this writes dots to the 2nd screen RAM area!)
CALT_98_0999:   push bc
________099B:   calf CALF____0BF4                               ;Point to 2nd screen
________099D:   pop bc
________099F:   mov a, c
________09A0:   ani a, $07
________09A2:   mov c, a
________09A3:   calt $008A                                      ; "Clear A"
________09A4:   stc
________09A6:   ral
________09A8:   dcr c
________09A9:   jr ________09A6
________09AA:   orax [hl]
________09AC:   jr ________09C5
;------------------------------------------------------------
CALF____09AD:   eqiw [$FFD8], $00                               ;"Invert Dot", then...
________09B0:   jr CALT_98_0999

;Clear Dot; B,C = X-,Y-position
CALT_AD_09B1:   push bc
________09B3:   calf CALF____0BF4                               ;Point to 2nd screen
________09B5:   pop bc
________09B7:   mov a, c
________09B8:   ani a, $07
________09BA:   mov c, a
________09BB:   mvi a, $FF
________09BD:   clc
________09BF:   ral
________09C1:   dcr c
________09C2:   jr ________09BF
________09C3:   anax [hl]
________09C5:   stax [hl]
________09C6:   ret
;------------------------------------------------------------
;[PC+2] Draw Horizontal Line
; 1st byte is the bit-pattern (of the 8-dot vertical "char" of the LCD)
; 2nd byte is the length: 00-7F draws black lines; 80-FF draws white lines
CALT_99_09C7:   pop de
________09C9:   ldax [de+]                                      ;SP+1
________09CA:   mov c, a
________09CB:   ldax [de+]                                      ;SP+2
________09CC:   push de
________09CE:   mov d, a
________09CF:   ani a, $7F
________09D1:   mov b, a
________09D2:   mov a, d
________09D3:   oni a, $80
________09D5:   jr ________09DD

________09D6:   ldax [hl]
________09D7:   ana a, c
________09D9:   stax [hl+]
________09DA:   dcr b
________09DB:   jr ________09D6
________09DC:   ret

________09DD:   ldax [hl]
________09DE:   ora a, c
________09E0:   stax [hl+]
________09E1:   dcr b
________09E2:   jr ________09DD
________09E3:   ret
;------------------------------------------------------------
;[PC+3] Print Bytes on-Screen
;This prints bytes (pointed to by HL) as HEX anywhere on-screen.
;1st byte (after the call) is X-position, 2nd byte is Y-position.
;3rd byte sets a few options:
; bit: 76543210			S = write to screen 1/0
;      SFbbN###			F = Use 5x8 / 5x5 font
;			       bb = blank space between digits (0..3)
;				N = start at right nybble (LSB) /
;				    start at left nybble (MSB) (more desirable)
;			      ### = 1..8 nybbles to write
;
CALT_9A_09E4:   pop de
________09E6:   ldax [de+]
________09E7:   mov b, a
________09E8:   staw [$FF9B]
________09EA:   ldax [de+]
________09EB:   mov c, a
________09EC:   ani a, $07
________09EE:   staw [$FF9C]
________09F0:   ldax [de+]
________09F1:   push de
________09F3:   staw [$FF9D]
________09F5:   ani a, $07
________09F7:   inr a
________09F8:   push bc
________09FA:   staw [$FF98]
________09FC:   lxi de, $FFA8
________09FF:   sded [$FFC0]
________0A03:   mov b, a
________0A04:   mvi c, $40
________0A06:   oniw [$FF9D], $40
________0A09:   mvi c, $10
________0A0B:   oniw [$FF9D], $08
________0A0E:   jr ________0A19
________0A0F:   dcr b
________0A10:   jr ________0A12
________0A11:   jr ________0A23

________0A12:   ldax [hl]
________0A13:   calt $00C0                                      ; "(RLR A)x4"
________0A14:   ani a, $0F
________0A16:   ora a, c
________0A18:   stax [de+]
________0A19:   dcr b
________0A1A:   jr ________0A1C
________0A1B:   jr ________0A23

________0A1C:   ldax [hl+]
________0A1D:   ani a, $0F
________0A1F:   ora a, c
________0A21:   stax [de+]
________0A22:   jr ________0A0F

________0A23:   pop bc
________0A25:   aniw [$FF9D], $BF
________0A28:   jr ________0A42
;-----------------------------------------------------------
;[PC+3] Print Text on-Screen
;This prints a text string (pointed to by HL) anywhere on-screen.
;1st byte (after the call) is X-position, 2nd byte is Y-position.
;3rd byte sets a few options:
; bit: 76543210			S = write to screen 1/0
;      Sbbb####		      bbb = blank space between digits (0..7)
;			     #### = 1..F nybbles to write
;
CALT_9B_0A29:   pop de
________0A2B:   ldax [de+]
________0A2C:   mov b, a
________0A2D:   staw [$FF9B]
________0A2F:   ldax [de+]
________0A30:   mov c, a                                        ;Save X,Y position in BC
________0A31:   ani a, $07
________0A33:   staw [$FF9C]
________0A35:   ldax [de+]
________0A36:   push de
________0A38:   staw [$FF9D]
________0A3A:   ani a, $0F                                      ;Get # of characters to write
________0A3C:   shld [$FFC0]
________0A40:   staw [$FF98]                                    ;# saved in 98
________0A42:   ldaw [$FF9D]
________0A44:   oni a, $80                                      ;Check if 0 (2nd screen) or 1 (1st screen)
________0A46:   jr ________0A49
________0A47:   calt $00BA                                      ; "Set HL to screen (B,C)"
________0A48:   jr ________0A4B

________0A49:   calf CALF____0BF4                               ;This points to Sc 1
________0A4B:   mov [$FFC6], c
________0A4F:   shld [$FFC2]
________0A53:   lxi de, $004B
________0A56:   calt $0096                                      ; "HL <== HL+DE"
________0A57:   shld [$FFC4]
________0A5B:   ldaw [$FF9D]
________0A5D:   calt $00C0                                      ; "(RLR A)x4"
________0A5E:   ani a, $07                                      ;Get text spacing (0-7)
________0A60:   staw [$FF9D]                                    ;Save in 9D
;--
________0A62:   dcrw [$FF98]                                    ;The loop starts here
________0A64:   jr ________0A66
________0A65:   ret

________0A66:   oniw [$FFC6], $FF
________0A69:   jr ________0A85
________0A6A:   lhld [$FFC2]
________0A6E:   shld [$FFC7]
________0A72:   lxi de, $FFB0
________0A75:   mvi b, $04
________0A77:   calf CALF____0BD3
________0A79:   offi a, $80
________0A7B:   jr ________0A85
________0A7C:   lded [$FF9D]
________0A80:   calt $009A                                      ; "HL <== HL+E"
________0A81:   shld [$FFC2]
________0A85:   lhld [$FFC4]
________0A89:   shld [$FFC9]
________0A8D:   lxi de, $FFB5
________0A90:   mvi b, $04
________0A92:   calf CALF____0BD3                               ;Copy B*A bytes?
________0A94:   offi a, $80
________0A96:   jr ________0AA0
________0A97:   lded [$FF9D]
________0A9B:   calt $009A                                      ; "HL <== HL+E"
________0A9C:   shld [$FFC4]
________0AA0:   mov b, [$FF9C]
________0AA4:   calt $008A                                      ; "Clear A"
________0AA5:   dcr b
________0AA6:   jr ________0AA8
________0AA7:   jr ________0AAD

________0AA8:   stc
________0AAA:   ral
________0AAC:   jr ________0AA5

________0AAD:   push va
________0AAF:   mov c, a
________0AB0:   calf CALF____0E6A                               ;(FFB0 -> HL)
________0AB2:   mvi b, $04
________0AB4:   ldax [hl]
________0AB5:   ana a, c
________0AB7:   stax [hl+]
________0AB8:   dcr b
________0AB9:   jr ________0AB4
________0ABA:   pop va
________0ABC:   xri a, $FF
________0ABE:   mov c, a
________0ABF:   mvi b, $04
________0AC1:   ldax [hl]
________0AC2:   ana a, c
________0AC4:   stax [hl+]
________0AC5:   dcr b
________0AC6:   jr ________0AC1
________0AC7:   lhld [$FFC0]
________0ACB:   ldax [hl+]
________0ACC:   shld [$FFC0]
________0AD0:   calt $00B8                                      ;Byte -> Point to Font Graphic
________0AD1:   lxi de, $FFB0
________0AD4:   lxi bc, $FFB5
________0AD7:   mvi a, $04
________0AD9:   oriw [$FF80], $08
________0ADC:   calf CALF____0C31                               ;Roll graphics a bit (shift up/dn)
________0ADE:   oniw [$FFC6], $FF
________0AE1:   jr ________0AEF
________0AE2:   lded [$FFC7]
________0AE6:   calf CALF____0E6A                               ;(FFB0 -> HL)
________0AE8:   mvi b, $04
________0AEA:   oriw [$FF80], $10
________0AED:   calf CALF____0BD3                               ;Copy B*A bytes?
________0AEF:   offiw [$FFC6], $08
________0AF2:   jr ________0B01
________0AF3:   lded [$FFC9]
________0AF7:   lxi hl, $FFB5
________0AFA:   mvi b, $04
________0AFC:   oriw [$FF80], $10
________0AFF:   calf CALF____0BD3                               ;Copy B*A bytes?
________0B01:   ldaw [$FF9B]
________0B03:   adi a, $05
________0B05:   mov b, a
________0B06:   ldaw [$FF9D]
________0B08:   add a, b
________0B0A:   staw [$FF9B]
________0B0C:   jre ________0A62
;------------------------------------------------------------
;Byte -> Point to Font Graphic
CALT_9C_0B0E:   lti a, $64                                      ;If it's greater than 64, use cart font
________0B10:   jr ________0B15                                 ;or...
________0B11:   lxi de, ________02C4                            ;Point to built-in font
________0B14:   jr ________0B1B

________0B15:   lded [$4005]                                    ;4005-6 on cart is the font pointer
________0B19:   sui a, $64
________0B1B:   sded [$FF96]
________0B1F:   mov c, a
________0B20:   ani a, $0F
________0B22:   mvi e, $05
________0B24:   calt $00A6                                      ; "Add A to "Pointer""
________0B25:   push hl
________0B27:   mov a, c
________0B28:   calt $00C0                                      ; "(RLR A)x4"
________0B29:   ani a, $0F
________0B2B:   mvi e, $50
________0B2D:   calt $00A6                                      ; "Add A to "Pointer""
________0B2E:   pop de
________0B30:   calt $0096                                      ; "HL <== HL+DE"
________0B31:   lded [$FF96]
________0B35:   calt $0096                                      ; "HL <== HL+DE"
________0B36:   ret
;------------------------------------------------------------
;?? (Move some RAM around...)
CALT_92_0B37:   lxi hl, $C591
________0B3A:   mvi b, $0B

________0B3C:   push hl
________0B3E:   push bc
________0B40:   calf CALF____0B4C
________0B42:   pop bc
________0B44:   pop hl
________0B46:   dcx hl
________0B47:   dcx hl
________0B48:   dcx hl
________0B49:   dcr b
________0B4A:   jr ________0B3C
________0B4B:   ret
;------------------------------------------------------------
CALF____0B4C:   ldax [hl+]
________0B4D:   staw [$FF9B]
________0B4F:   mov b, a
________0B50:   adi a, $07
________0B52:   lti a, $53
________0B54:   ret
________0B55:   ldax [hl+]
________0B56:   mov c, a
________0B57:   ani a, $07
________0B59:   staw [$FF9C]
________0B5B:   mov a, c
________0B5C:   adi a, $07
________0B5E:   lti a, $47
________0B60:   ret
________0B61:   ldax [hl]
________0B62:   staw [$FF9D]
________0B64:   lti a, $0C
________0B66:   ret
________0B67:   calt $00BA                                      ; "Set HL to screen (B,C)"
________0B68:   shld [$FF9E]
________0B6C:   mov a, h
________0B6D:   oni a, $40
________0B6F:   jr ________0B75
________0B70:   lxi de, $FFB0
________0B73:   calf CALF____0BD1
________0B75:   lhld [$FF9E]
________0B79:   lxi de, $004B
________0B7C:   calt $0096                                      ; "HL <== HL+DE"
________0B7D:   push hl
________0B7F:   lxi de, $FFB8
________0B82:   calf CALF____0BD1
________0B84:   calf CALF____0E6A
________0B86:   lxi de, $FFC0
________0B89:   mvi b, $0F
________0B8B:   calt $00AA                                      ; "((HL+) ==> (DE+))xB"
________0B8C:   ldaw [$FF9D]
________0B8E:   calt $00BC                                      ; "HL=C4B0+(A*$10)"
________0B8F:   lxi de, $FFB0
________0B92:   lxi bc, $FFB8
________0B95:   calf CALF____0C2F
________0B97:   push hl
________0B99:   calf CALF____0E6A
________0B9B:   lxi de, $FFC0
________0B9E:   mvi b, $0F
________0BA0:   ldax [hl]
________0BA1:   xrax [de+]
________0BA3:   stax [hl+]
________0BA4:   dcr b
________0BA5:   jr ________0BA0
________0BA6:   pop hl
________0BA8:   oriw [$FF80], $08
________0BAB:   lxi de, $FFB0
________0BAE:   lxi bc, $FFB8
________0BB1:   calf CALF____0C2F
________0BB3:   lded [$FF9E]
________0BB7:   mov a, d
________0BB8:   oni a, $40
________0BBA:   jr ________0BC2
________0BBB:   calf CALF____0E6A
________0BBD:   oriw [$FF80], $10
________0BC0:   calf CALF____0BD1
________0BC2:   pop de
________0BC4:   lxi hl, $3DA8
________0BC7:   calt $0096                                      ; "HL <== HL+DE"
________0BC8:   skn cy
________0BCA:   ret
________0BCB:   lxi hl, $FFB8
________0BCE:   oriw [$FF80], $10
;--
CALF____0BD1:   mvi b, $07
CALF____0BD3:   ldaw [$FF9B]
________0BD5:   offi a, $80
________0BD7:   jr ________0BE2
________0BD8:   lti a, $4B
________0BDA:   jr ________0BED
________0BDB:   push va
________0BDD:   ldax [hl+]
________0BDE:   stax [de+]
________0BDF:   pop va
________0BE1:   jr ________0BE9
________0BE2:   oniw [$FF80], $10
________0BE5:   jr ________0BE8
________0BE6:   inx hl
________0BE7:   jr ________0BE9

________0BE8:   inx de
________0BE9:   inr a
________0BEA:   nop
________0BEB:   dcr b
________0BEC:   jr ________0BD5
________0BED:   aniw [$FF80], $EF
________0BF0:   ret
;------------------------------------------------------------
;Set HL to screen (B,C)
CALT_9D_0BF1:   lxi hl, $BFB5                                   ;Point before Sc. RAM
CALF____0BF4:   lxi hl, $C20D                                   ;Point before Sc.2 RAM
________0BF7:   mvi e, $4B
________0BF9:   mov a, c
________0BFA:   mvi c, $00
________0BFC:   adi a, $08
________0BFE:   suinb a, $08
________0C00:   jr ________0C08
________0C01:   push va
________0C03:   calt $009A                                      ; "HL <== HL+E"
________0C04:   pop va
________0C06:   inr c
________0C07:   jr ________0BFE
________0C08:   mov a, b
________0C09:   offi a, $80
________0C0B:   ret
________0C0C:   mov e, a
________0C0D:   jr CALT_8D_0C18
;------------------------------------------------------------
;[PC+1] HL +- byte
CALT_8C_0C0E:   pop de
________0C10:   ldax [de+]                                      ;Get byte after PC
________0C11:   push de
________0C13:   mov e, a
________0C14:   lti a, $80                                      ;Add or subtract that byte
________0C16:   mvi a, $FF
;HL <== HL+E
CALT_8D_0C18:   mvi a, $00
________0C1A:   mov d, a
;HL <== HL+DE
CALT_8B_0C1B:   mov a, e
________0C1C:   add a, l
________0C1E:   mov l, a
________0C1F:   mov a, d
________0C20:   adc a, h
________0C22:   mov h, a
________0C23:   ret
;------------------------------------------------------------
;HL=C4B0+(A*$10)
CALT_9E_0C24:   lxi hl, $C4B0
________0C27:   mvi e, $10
________0C29:   mov b, a
________0C2A:   dcr b
________0C2B:   jr ________0C2D
________0C2C:   ret

________0C2D:   calt $009A                                      ; "HL <== HL+E"
________0C2E:   jr ________0C2A
;------------------------------------------------------------
CALF____0C2F:   mvi a, $07
CALF____0C31:   staw [$FF96]

________0C33:   ldaw [$FF9C]
________0C35:   staw [$FF97]
________0C37:   push bc
________0C39:   mvi c, $00
________0C3B:   ldax [hl+]
________0C3C:   dcrw [$FF97]
________0C3E:   jr ________0C40
________0C3F:   jr ________0C4D

________0C40:   clc
________0C42:   ral
________0C44:   push va
________0C46:   mov a, c
________0C47:   ral
________0C49:   mov c, a
________0C4A:   pop va
________0C4C:   jr ________0C3C

________0C4D:   oniw [$FF80], $08
________0C50:   jr ________0C54
________0C51:   orax [de]
________0C53:   jr ________0C56

________0C54:   anax [de]
________0C56:   stax [de]
________0C57:   mov a, c
________0C58:   pop bc
________0C5A:   oniw [$FF80], $08
________0C5D:   jr ________0C61
________0C5E:   orax [bc]
________0C60:   jr ________0C63

________0C61:   anax [bc]
________0C63:   stax [bc]
________0C64:   inx bc
________0C65:   inx de
________0C66:   dcrw [$FF96]
________0C68:   jre ________0C33
________0C6A:   aniw [$FF80], $F7
________0C6D:   ret
;------------------------------------------------------------
;(RLR A)x4	(Divides A by 16)
CALT_A0_0C6E:   rar
________0C70:   rar
CALF____0C72:   rar
________0C74:   rar
________0C76:   ret
;------------------------------------------------------------
CALF____0C77:   mvi e, $3C                                      ; 60 decimal...
________0C79:   calt $009A                                      ; "HL <== HL+E"
________0C7A:   ret
;------------------------------------------------------------
CALF____0C7B:   lxi hl, ________054D                            ;"PUZZLE"
________0C7E:   calt $00B6                                      ; "[PC+3] Print Text on-Screen"
________0C7F:   db $03, $00, $16
CALF____0C82:   calf CALF____0E67                               ;(C7F2 -> HL)
________0C84:   mvi a, $01
________0C86:   staw [$FF83]
________0C88:   ldax [hl+]
________0C89:   push hl
________0C8B:   nei a, $FF                                      ;If it's a terminator, loop
________0C8D:   jre ________0CB6
________0C8F:   calt $00B8                                      ;Byte -> Point to Font Graphic
________0C90:   calt $00A8                                      ; "XCHG HL,DE"
________0C91:   ldaw [$FF83]
________0C93:   calf CALF____0CBF                               ;(Scroll text)
________0C95:   push de
________0C97:   mvi e, $51
________0C99:   calt $009A                                      ; "HL <== HL+E"
________0C9A:   pop de
________0C9C:   mvi b, $04
________0C9E:   ldax [de+]
________0C9F:   ral
________0CA1:   stax [hl+]
________0CA2:   dcr b
________0CA3:   jr ________0C9E
________0CA4:   inrw [$FF83]
________0CA6:   pop hl
________0CA8:   eqiw [$FF83], $0D
________0CAB:   jre ________0C88
________0CAD:   lxi hl, $C7FF
________0CB0:   ldax [hl]
________0CB1:   calf CALF____0E3B                               ;Scroll text; XOR RAM
________0CB3:   calt $00A0                                      ; "C258+ ==> C000+"
________0CB4:   calt $0082                                      ;Copy Screen RAM to LCD Driver
________0CB5:   ret
;------------------------------------------------------------
________0CB6:   mov a, [$FF83]                                  ;A "LDAW 83" would've been faster here...
________0CBA:   mov [$C7FF], a
________0CBE:   jr ________0CA4
;------------------------------------------------------------
CALF____0CBF:   lti a, $09
________0CC1:   jr ________0CD2
________0CC2:   lti a, $05
________0CC4:   jr ________0CD8
________0CC5:   lxi hl, $C2D8
________0CC8:   nei a, $04
________0CCA:   ret
________0CCB:   mvi b, $0F
________0CCD:   dcx hl
________0CCE:   dcr b
________0CCF:   jr ________0CCD
________0CD0:   inr a
________0CD1:   jr ________0CC8
________0CD2:   lxi hl, $C404
________0CD5:   sui a, $08
________0CD7:   jr ________0CC8
;------------------------------------------------------------
________0CD8:   lxi hl, $C36E
________0CDB:   sui a, $04
________0CDD:   jr ________0CC8
;------------------------------------------------------------
________0CDE:   lxi hl, ________04B8                            ;Point to scroll text
________0CE1:   jr ________0CFA
;------------------------------------------------------------
    	;Slide the top line for the scroller.
CALF____0CE2:   inrw [$FF82]
________0CE4:   nop
________0CE5:   lxi hl, $C25B
________0CE8:   lxi de, $C258
________0CEB:   mvi b, $47
________0CED:   calt $00AA                                      ; "((HL+) ==> (DE+))xB"
________0CEE:   offiw [$FF82], $01
________0CF1:   jr ________0CF6
________0CF2:   lxi hl, $FFA3
________0CF5:   jr ________0D0C

________0CF6:   lhld [$FFD6]
________0CFA:   ldax [hl+]
________0CFB:   nei a, $FF                                      ;If terminator...
________0CFD:   jr ________0CDE                                        ;...reset scroll
________0CFE:   shld [$FFD6]
________0D02:   calt $00B8                                      ;Byte -> Point to Font Graphic
________0D03:   mvi b, $04                                      ;(5 pixels wide)
________0D05:   lxi de, $FFA0
________0D08:   calt $00AA                                      ; "((HL+) ==> (DE+))xB"
________0D09:   lxi hl, $FFA0                                   ;First copy it to RAM...

________0D0C:   lxi de, $C2A0                                   ;Then put it on screen, 3 pixels at a time.
________0D0F:   mvi b, $02

;((HL+) ==> (DE+))xB
CALT_95_0D11:   ldax [hl+]
________0D12:   stax [de+]
________0D13:   dcr b
________0D14:   jr CALT_95_0D11
________0D15:   ret
;------------------------------------------------------------
________0D16:   inrw [$FFDA]
________0D18:   lxi hl, $FFDA
________0D1B:   ldax [hl]
________0D1C:   staw [$FFD0]
________0D1E:   jr ________0D23

;Draw a spiral dot-by-dot
CALF____0D1F:   neiw [$FFD0], $FF
________0D22:   jr ________0D16
________0D23:   ldaw [$FFD1]                                    ;This stores the direction
________0D25:   nei a, $00                                      ;that the spiral draws in...
________0D27:   jr ________0D46
________0D28:   lbcd [$FFD2]
________0D2C:   nei a, $01
________0D2E:   jre ________0D52
________0D30:   nei a, $02
________0D32:   jre ________0D57
________0D34:   nei a, $03
________0D36:   jre ________0D5C

________0D38:   dcr b
________0D39:   mov a, b
________0D3A:   staw [$FFD3]
________0D3C:   calf CALF____09AD                               ;Draw a dot on-screen
________0D3E:   dcrw [$FFD0]                                    ;Decrement length counter...
________0D40:   ret
________0D41:   mvi a, $01                                      ;If zero, turn corners
________0D43:   staw [$FFD1]
________0D45:   ret
;------------------------------------------------------------
________0D46:   lxi bc, $2524
________0D49:   sbcd [$FFD2]
________0D4D:   calf CALF____09AD
________0D4F:   inrw [$FFD1]
________0D51:   ret
________0D52:   dcr c
________0D53:   mov a, c
________0D54:   staw [$FFD2]
________0D56:   jr ________0D60
;------------------------------------------------------------
________0D57:   inr b
________0D58:   mov a, b
________0D59:   staw [$FFD3]
________0D5B:   jr ________0D60
;------------------------------------------------------------
________0D5C:   inr c
________0D5D:   mov a, c
________0D5E:   staw [$FFD2]
________0D60:   calf CALF____09AD
________0D62:   dcrw [$FFD0]
________0D64:   ret
________0D65:   inrw [$FFD1]
________0D67:   ret

;------------------------------------------------------------
;Draw a thick black frame around the screen
CALF____0D68:   lxi hl, $C2A3                                   ;Point to 2nd screen
________0D6B:   mvi a, $FF                                      ;Black character
________0D6D:   mvi b, $05                                      ;Write 6 characters
________0D6F:   calt $00BE                                      ; "A ==> (HL+)xB"
________0D70:   mvi a, $1F                                      ;Then a char with 5 upper dots filled
________0D72:   mvi b, $3E                                      ;Times 63
________0D74:   calt $00BE                                      ; "A ==> (HL+)xB"
________0D75:   mvi c, $04
________0D77:   mvi b, $0B
________0D79:   mvi a, $FF
________0D7B:   calt $00BE                                      ; "A ==> (HL+)xB"
________0D7C:   calt $008A                                      ; "Clear A"
________0D7D:   mvi b, $3E
________0D7F:   calt $00BE                                      ; "A ==> (HL+)xB"
________0D80:   dcr c
________0D81:   jr ________0D77
________0D82:   mvi a, $FF
________0D84:   mvi b, $0B
________0D86:   calt $00BE                                      ; "A ==> (HL+)xB"
________0D87:   mvi a, $F0
________0D89:   mvi b, $3E
________0D8B:   calt $00BE                                      ; "A ==> (HL+)xB"
________0D8C:   mvi a, $FF
________0D8E:   mvi b, $05
________0D90:   calt $00BE                                      ; "A ==> (HL+)xB"
________0D91:   ret
;------------------------------------------------------------
;This draws the puzzle grid, I think...
CALF____0D92:   neiw [$FFD5], $00
________0D95:   jr ________0DA2
________0D96:   neiw [$FFD5], $01
________0D99:   jr ________0DA5
________0D9A:   eqiw [$FFD5], $02
________0D9D:   jre ________0DC3
________0D9F:   lxi hl, $C2D8
________0DA2:   lxi hl, $C2B8
________0DA5:   lxi hl, $C2C8
________0DA8:   calt $00B2                                      ; "[PC+2] Draw Horizontal Line"
________0DA9:   db $F0, $00
________0DAB:   mvi b, $04
________0DAD:   push bc
________0DAF:   mvi e, $4A
________0DB1:   calt $009A                                      ; "HL <== HL+E"
________0DB2:   calt $00B2                                      ; "[PC+2] Draw Horizontal Line"
________0DB3:   db $FF, $00
________0DB5:   pop bc
________0DB7:   dcr b
________0DB8:   jr ________0DAD
________0DB9:   mvi e, $4A
________0DBB:   calt $009A                                      ; "HL <== HL+E"
________0DBC:   calt $00B2                                      ; "[PC+2] Draw Horizontal Line"
________0DBD:   db $1F, $00
________0DBF:   inrw [$FFD5]
________0DC1:   jre CALF____0D92
________0DC3:   lxi hl, $C33E
________0DC6:   calt $00B2                                      ; "[PC+2] Draw Horizontal Line"
________0DC7:   db $10, $40
________0DC9:   lxi hl, $C3D4
________0DCC:   calt $00B2                                      ; "[PC+2] Draw Horizontal Line"
________0DCD:   db $10, $40
________0DCF:   calt $008A                                      ; "Clear A"
________0DD0:   staw [$FFD5]
________0DD2:   ret
;------------------------------------------------------------
CALF____0DD3:   nei a, $01
________0DD5:   jr ________0DEE
________0DD6:   nei a, $04
________0DD8:   jre ________0DFC
________0DDA:   nei a, $02
________0DDC:   jre ________0E0A

________0DDE:   mov a, [$C7FF]                                  ;More puzzle grid drawing, probably...
________0DE2:   ani a, $03
________0DE4:   nei a, $01
________0DE6:   rets

________0DE7:   lxi bc, $12FF
________0DEA:   oriw [$FFA2], $FF
________0DED:   jr ________0DFB
;------------------------------------------------------------
________0DEE:   mov a, [$C7FF]
________0DF2:   lti a, $09
________0DF4:   rets

________0DF5:   lxi bc, $0D04
________0DF8:   aniw [$FFA2], $00
________0DFB:   jr ________0E17
;------------------------------------------------------------
________0DFC:   mov a, [$C7FF]
________0E00:   gti a, $04
________0E02:   rets
________0E03:   lxi bc, $0FFC
________0E06:   aniw [$FFA2], $00
________0E09:   jr ________0E17
;------------------------------------------------------------
________0E0A:   mov a, [$C7FF]
________0E0E:   oni a, $03
________0E10:   rets

________0E11:   lxi bc, $1101
________0E14:   oriw [$FFA2], $FF
________0E17:   mov a, [$C7FF]
________0E1B:   mov e, a
________0E1C:   mov [$C7FE], a
________0E20:   add a, c
________0E22:   mov d, a
________0E23:   mov [$C7FF], a
________0E27:   lxi hl, $C7F1
________0E2A:   mov a, d
________0E2B:   dcr a
________0E2C:   jr ________0E2E
________0E2D:   jr ________0E30

________0E2E:   inx hl
________0E2F:   jr ________0E2B

________0E30:   mov a, e
________0E31:   lxi de, $C7F1
________0E34:   dcr a
________0E35:   jr ________0E39
________0E36:   jmp CALF____08F8

________0E39:   inx de
________0E3A:   jr ________0E34
;------------------------------------------------------------
CALF____0E3B:   calf CALF____0CBF
________0E3D:   calt $00B2                                      ; "[PC+2] Draw Horizontal Line"
________0E3E:   db $F0, $10
________0E40:   mvi e, $3A
________0E42:   calt $009A                                      ; "HL <== HL+E"
________0E43:   calt $00B2                                      ; "[PC+2] Draw Horizontal Line"
________0E44:   db $FF, $10
________0E46:   mvi e, $3A
________0E48:   calt $009A                                      ; "HL <== HL+E"
________0E49:   calt $00B2                                      ; "[PC+2] Draw Horizontal Line"
________0E4A:   db $1F, $10
________0E4C:   ret
;------------------------------------------------------------
; Turns on a hardware timer
CALF____0E4D:   di
________0E4F:   mvi a, $07
________0E51:   mov tmm, a
________0E53:   mvi a, $74
________0E55:   mov tm0, a
________0E57:   aniw [$FF80], $FC
________0E5A:   stm
________0E5B:   ei
________0E5D:   ret
;------------------------------------------------------------
; Loads (DE/)HL with various common addresses
CALF____0E5E:   lxi de, $C000
________0E61:   lxi hl, $C258
CALF____0E64:   lxi hl, ________04EC
CALF____0E67:   lxi hl, $C7F2
CALF____0E6A:   lxi hl, $FFB0
________0E6D:   ret
;------------------------------------------------------------

;[PC+1] ?? (Unpack 8 bytes -> 64 bytes (Twice!))
CALT_A8_0E6E:   pop hl
________0E70:   ldax [hl+]
________0E71:   push hl
CALF____0E73:   calt $00BC                                      ; "HL=C4B0+(A*$10)"
________0E74:   calt $00A8                                      ; "XCHG HL,DE"
________0E75:   call ________0E78                               ;This call means the next code runs twice

________0E78:   mvi b, $7
________0E7A:   mvi c, $7
________0E7C:   calf CALF____0E6A                               ;(FFB0->HL)
________0E7E:   ldax [de]                                       ;In this loop, the byte at (FFB0)
________0E7F:   ral                                             ;Has its bits split up into 8 bytes
________0E81:   push va                                         ;And this loop runs 8 times...
________0E83:   ldax [hl]
________0E84:   rar
________0E86:   stax [hl+]
________0E87:   pop va
________0E89:   dcr c
________0E8A:   jr ________0E7F
________0E8B:   inx de
________0E8C:   dcr b
________0E8D:   jr ________0E7A

________0E8E:   push de
________0E90:   dcx hl
________0E91:   dcx de
________0E92:   mvi b, $7
________0E94:   calt $00AC                                      ; "((HL-) ==> (DE-))xB"
________0E95:   pop de
________0E97:   ret
;------------------------------------------------------------
;[PC+1] ?? (Unpack & Roll 8 bits)
CALT_A9_0E98:   pop hl
________0E9A:   ldax [hl+]
________0E9B:   push hl
________0E9D:   push va
________0E9F:   calf CALF____0E73
________0EA1:   pop va
________0EA3:   jr ________0EA9
;-----------------------------------------------------------
;[PC+1] ?? (Roll 8 bits -> Byte?)
CALT_AA_0EA4:   pop hl
________0EA6:   ldax [hl+]
________0EA7:   push hl
________0EA9:   calt $00BC                                      ; "HL=C4B0+(A*$10)"
________0EAA:   lxi de, $FFBF
________0EAD:   calt $00A8                                      ; "XCHG HL,DE"
________0EAE:   push de
________0EB0:   mvi c, $0F
________0EB2:   mvi b, $8-1
________0EB4:   ldax [de]
________0EB5:   ral 
________0EB7:   push va
________0EB9:   ldax [hl]
________0EBA:   rar
________0EBC:   stax [hl]
________0EBD:   pop va
________0EBF:   dcr b
________0EC0:   jr ________0EB5
________0EC1:   dcx hl
________0EC2:   inx de
________0EC3:   dcr c
________0EC4:   jr ________0EB2
________0EC5:   pop de
________0EC7:   lxi hl, $FFB8
________0ECA:   calf CALF____0ECE
________0ECC:   calf CALF____0E6A

CALF____0ECE:   mvi b, $8-1
________0ED0:   calt $00AA                                      ; "((HL+) ==> (DE+))xB"
________0ED1:   ret
;------------------------------------------------------------
;[PC+x] ?? (Add/Sub multiple bytes)
CALT_AB_0ED2:   pop hl
________0ED4:   ldax [hl+]
________0ED5:   push hl
________0ED7:   mov b, a
________0ED8:   ani a, $0F
________0EDA:   staw [$FF96]
________0EDC:   mov a, b
________0EDD:   calt $00C0                                      ; "(RLR A)x4"
________0EDE:   ani a, $0F
________0EE0:   lti a, $0D
________0EE2:   ret
________0EE3:   staw [$FF97]
________0EE5:   dcrw [$FF97]
________0EE7:   jr ________0EF0                                 ;Based on 97, jump to cart (4007)!
________0EE8:   calt $00A2                                      ; "CALT A0, CALT A4"
________0EE9:   pop bc
________0EEB:   lbcd [$4007]                                    ;Read vector from $4007 on cart, however...
________0EEF:   jb                                              ;...all 5 Pokekon games have "0000" there!
________0EF0:   pop hl
________0EF2:   ldax [hl+]
________0EF3:   push hl
________0EF5:   staw [$FF98]
________0EF7:   ani a, $0F
________0EF9:   lti a, $0C
________0EFB:   jr ________0EE5
________0EFC:   lxi hl, $C56E
________0EFF:   inx hl
________0F00:   inx hl
________0F01:   inx hl
________0F02:   dcr a
________0F03:   jr ________0EFF
________0F04:   lxi de, $FF96
________0F07:   oniw [$FF98], $80
________0F0A:   jr ________0F10
________0F0B:   ldax [hl]
________0F0C:   subx [de]
________0F0E:   stax [hl]
________0F0F:   jr ________0F18

________0F10:   oniw [$FF98], $40
________0F13:   jr ________0F18
________0F14:   ldax [hl]
________0F15:   addx [de]
________0F17:   stax [hl]
________0F18:   dcx hl
________0F19:   oniw [$FF98], $10
________0F1C:   jr ________0F23

________0F1D:   ldax [hl]
________0F1E:   addx [de]
________0F20:   stax [hl]
________0F21:   jre ________0EE5

________0F23:   oniw [$FF98], $20
________0F26:   jr ________0F21
________0F27:   ldax [hl]
________0F28:   subx [de]
________0F2A:   stax [hl]
________0F2B:   jr ________0F21
;------------------------------------------------------------
;Invert Screen RAM (C000~)
CALT_A6_0F2C:   lxi hl, $C000
;Invert Screen 2 RAM (C258~)
CALT_A7_0F2F:   lxi hl, $C258
________0F32:   mvi c, $02

________0F34:   mvi b, $C7
________0F36:   calf CALF____0F3B
________0F38:   dcr c
________0F39:   jr ________0F34
________0F3A:   ret
;------------------------------------------------------------
;Invert bytes xB
CALF____0F3B:   ldax [hl]
________0F3C:   xri a, $FF
________0F3E:   stax [hl+]
________0F3F:   dcr b
________0F40:   jr CALF____0F3B
________0F41:   ret
;------------------------------------------------------------
;[PC+1] Invert 8 bytes at (C4B8+A*$10)
CALT_A5_0F42:   pop hl
________0F44:   ldax [hl+]
________0F45:   push hl
________0F47:   lti a, $0C
________0F49:   ret

________0F4A:   calt $00BC                                      ; "HL=C4B0+(A*$10)"
________0F4B:   mvi e, $08
________0F4D:   calt $009A                                      ; "HL <== HL+E"
________0F4E:   mvi b, $07
________0F50:   jr CALF____0F3B
;------------------------------------------------------------
;for the addition routine below...
________0F51:   mov a, h
________0F52:   staw [$FFB0]
________0F54:   mov a, l
________0F55:   staw [$FFB1]
________0F57:   lxi hl, $FFB1
________0F5A:   ldaw [$FF96]
________0F5C:   jr ________0F6D
;------------------------------------------------------------
;[PC+1] 8~32-bit Add/Subtract (dec/hex)
;Source pointed to by HL & DE.  Extra byte sets a few options:
; bit: 76543210			B = 0/1: Work in decimal (BCD) / regular Hex
;      BA2211HD			A = 0/1: Add / Subtract numbers
;				22 = byte length of (HL)
;				11 = byte length of (DE)
;				H = 1: HL gets bytes from $FFB1
;				D = 1: DE gets bytes from $FFA2
CALT_A4_0F5D:   pop bc
________0F5F:   ldax [bc]
________0F60:   inx bc
________0F61:   push bc
________0F63:   staw [$FF96]                                    ;Get extra byte, keep in 96
________0F65:   offi a, $01                                     ;If set, load from $FFA2 instead
________0F67:   lxi de, $FFA2
________0F6A:   offi a, $02                                     ;If set, load from $FFB1
________0F6C:   jr ________0F51

________0F6D:   calf CALF____0C72                               ;"RLR A" x2
________0F6F:   mov b, a                                        ;Get our length bits (8-32 bits)
________0F70:   ani a, $03
________0F72:   mov c, a
________0F73:   mov a, b
________0F74:   calf CALF____0C72                               ;"RLR A" x2
________0F76:   ani a, $03
________0F78:   mov b, a
________0F79:   oniw [$FF96], $40                               ;Do we subtract instead of add?
________0F7C:   jr ________0F83
________0F7D:   oniw [$FF96], $80                               ;Do we work in binary-coded decimal?
________0F80:   jr ________0F99
________0F81:   jre ________0FB0

________0F83:   oniw [$FF96], $80
________0F86:   jre ________0FC1

________0F88:   clc
________0F8A:   ldax [de]
________0F8B:   adcx [hl]                                       ;Add HL-,DE-
________0F8D:   stax [de]
________0F8E:   dcr b
________0F8F:   jr ________0F91
________0F90:   ret

________0F91:   dcx de
________0F92:   dcr c
________0F93:   jr ________0F97
________0F94:   calf CALF____0FD3                               ;Clear C,HL
________0F96:   jr ________0F8A

________0F97:   dcx hl
________0F98:   jr ________0F8A

________0F99:   stc
________0F9B:   mvi a, $99
________0F9D:   aci a, $00
________0F9F:   subx [hl]
________0FA1:   addx [de]
________0FA3:   daa
________0FA4:   stax [de]
________0FA5:   dcr b
________0FA6:   jr ________0FA8
________0FA7:   ret

________0FA8:   dcx de
________0FA9:   dcr c
________0FAA:   jr ________0FAE
________0FAB:   calf CALF____0FD3
________0FAD:   jr ________0F9B

________0FAE:   dcx hl
________0FAF:   jr ________0F9B
;-----
________0FB0:   clc
________0FB2:   ldax [de]
________0FB3:   sbbx [hl]
________0FB5:   stax [de]
________0FB6:   dcr b
________0FB7:   jr ________0FB9
________0FB8:   ret

________0FB9:   dcx de
________0FBA:   dcr c
________0FBB:   jr ________0FBF
________0FBC:   calf CALF____0FD3
________0FBE:   jr ________0FB2

________0FBF:   dcx hl
________0FC0:   jr ________0FB2
;------
________0FC1:   clc
________0FC3:   ldax [de]
________0FC4:   adcx [hl]
________0FC6:   daa
________0FC7:   stax [de]
________0FC8:   dcr b
________0FC9:   jr ________0FCB
________0FCA:   ret

________0FCB:   dcx de
________0FCC:   dcr c
________0FCD:   jr ________0FD1
________0FCE:   calf CALF____0FD3
________0FD0:   jr ________0FC3

________0FD1:   dcx hl
________0FD2:   jr ________0FC3
;------------------------------------------------------------
;Clear C,HL (for the add/sub routine above)
CALF____0FD3:   mvi c, $00
________0FD5:   lxi hl, $0000
________0FD8:   ret
;------------------------------------------------------------
;[PC+1] INC/DEC Range of bytes from (HL)
;Extra byte's high bit sets Inc/Dec; rest is the byte counter.
CALT_AC_0FD9:   pop bc
________0FDB:   ldax [bc]
________0FDC:   inx bc
________0FDD:   push bc
________0FDF:   mov b, a
________0FE0:   oni a, $80                                      ;do we Dec?
________0FE2:   jr ________0FF1

________0FE3:   ani a, $7F                                      ;Counter can be 00-7F
________0FE5:   mov b, a
________0FE6:   ldax [hl]                                       ;Load a byte
________0FE7:   sui a, $01                                      ;Decrement it
________0FE9:   stax [hl-]
________0FEA:   skn cy                                          ;Quit our function if any byte= -1!
________0FEC:   jr ________0FEE
________0FED:   ret

________0FEE:   dcr b
________0FEF:   jr ________0FE6
________0FF0:   ret

________0FF1:   ldax [hl]                                       ;or Load a byte
________0FF2:   adi a, $01
________0FF4:   stax [hl-]
________0FF5:   skn cy                                          ;Quit if any byte overflows!
________0FF7:   jr ________0FF9
________0FF8:   ret

________0FF9:   dcr b
________0FFA:   jr ________0FF1
________0FFB:   ret                                             ;What a weird way to end a BIOS...
;------------------------------------------------------------
________0FFC:   db $00, $00, $00, $00                           ;Unused bytes (and who could blame 'em?)
	
; EOF!
