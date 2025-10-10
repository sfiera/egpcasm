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
    bc  => 0x9
    de  => 0xA
    hl  => 0xB
    de+ => 0xC
    hl+ => 0xD
    de- => 0xE
    hl- => 0xF
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

#subruledef reg_vbcdehl {
    v => 0b000
    {r: reg_bcdehl} => r
}

#subruledef reg_vabcdehl {
    a => 0b001
    {r: reg_vbcdehl} => r
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

#ruledef {
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

    inx {reg: inx_reg} => reg @ $2
    dcx {reg: inx_reg} => reg @ $3
    ldax [{reg: ldax_reg}] => $2 @ reg
    stax [{reg: ldax_reg}] => $3 @ reg

    inr {reg: reg_inr} => $4 @ reg
    dcr {reg: reg_inr} => $5 @ reg

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

    push {reg: push_reg} => $48 @ reg @ $e
    pop {reg: push_reg} => $48 @ reg @ $f

    jmp {addr: u16} => $54 @ le(addr)

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
________0003:   jr $0013
;------------------------------------------------------------
INT0____0004:   jmp $400C
________0007:   nop
;------------------------------------------------------------
INTT____0008:   jre $00F0
;------------------------------------------------------------
;((HL-) ==> (DE-))xB
; Copies the data pointed to by HL "(HL)" to (DE).
; B holds a single byte for the copy loop count.
CALT_96_000A:   ldax [hl-]
________000B:   stax [de-]
________000C:   dcr b
________000D:   jr $000a
________000E:   ret
________000F:   nop
;------------------------------------------------------------
INT1____0010:   jmp $400F
;------------------------------------------------------------
cont____0013:   #d8 $04, $00, $00                               ; LXI     SP,0000
________0016:   per                                             ;Set Port E to AB mode
________0018:   #d8 $69, $C1                                    ; MVI     A,C1
________001A:   mov pa, a
________001C:   #d8 $64, $88, $FE                               ; ANI     PA,FE
________001F:   #d8 $64, $98, $01                               ; ORI     PA,01
________0022:   calt $008A                                      ; "Clear A"
________0023:   mov mb, a                                       ;Mode B = All outputs
________0025:   #d8 $64, $98, $38                               ; ORI     PA,38

________0028:   #d8 $69, $39                                    ; MVI     A,39
________002A:   mov pb, a
________002C:   #d8 $64, $98, $02                               ; ORI     PA,02
________002F:   #d8 $64, $88, $FD                               ; ANI     PA,FD
________0032:   #d8 $69, $3E                                    ; MVI     A,3E
________0034:   mov pb, a
________0036:   #d8 $64, $98, $02                               ; ORI     PA,02
________0039:   #d8 $64, $88, $FD                               ; ANI     PA,FD
________003C:   #d8 $64, $88, $C7                               ; ANI     PA,C7
________003F:   #d8 $64, $98, $04                               ; ORI     PA,04
________0042:   #d8 $69, $07                                    ; MVI     A,07
________0044:   mov tmm, a                                      ;Timer register = #$7
________0046:   #d8 $69, $74                                    ; MVI     A,74
________0048:   mov tm0, a                                      ;Timer option reg = #$74
________004A:   calt $008E                                      ; "Clear Screen RAM"
________004B:   calt $0090                                      ; "Clear C4B0~C593"
________004C:   calt $0092                                      ; "Clear C594~C86F?"
________004D:   #d8 $34, $80, $FF                               ; LXI     H,FF80
________0050:   #d8 $6A, $49                                    ; MVI     B,49
________0052:   calt $0094                                      ; "Clear RAM (HL+)xB"
________0053:   calt $0082                                      ; Copy Screen RAM to LCD Driver
________0054:   #d8 $69, $05                                    ; MVI     A,05
________0056:   mov mk, a                                       ;Mask = IntT,1 ON
________0058:   ei
________005A:   calt $0080                                      ; [PC+1] Check Cartridge
________005B:   #d8 $C0                                         ; DB $C0 		;Jump to ($4001) in cartridge
________005C:   jmp $057F                                       ;Flow continues if no cartridge is present.
;------------------------------------------------------------
;(DE+)-(HL+) ==> A
; Loads A with (DE), increments DE, then subtracts (HL) from A and increments HL.
CALT_A1_005F:   ldax [de+]
________0060:   #d8 $70, $E5                                    ; SUBX    H+
________0062:   ret
;------------------------------------------------------------
;?? (Find 1st diff. byte in (HL),(DE)xB)  (Matching byte perhaps?)
; I don't know how useful this is, but I guess it's for advancing pointers to
; the first difference between 2 buffers, etc.
CALT_A2_0063:   calt $00C2                                      ; "(DE+)-(HL+) ==> A"
________0064:   #d8 $48, $1C                                    ; SKN     Z
________0066:   jr $0068
________0067:   ret

________0068:   dcr b
________0069:   jr $0063
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
________007A:   #d8 $48, $1A                                    ; SKN     CY
________007C:   jr $007E
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

_CALT_80__0080:   #d8 $A6, $01                     ; DW 01A6	;[PC+1] Check Cartridge
_CALT_81__0082:   #d8 $CF, $01                     ; DW 01CF	;Copy Screen RAM to LCD Driver
_CALT_82__0084:   #d8 $8E, $01                     ; DW 018E	;[PC+2] Setup/Play Sound
_CALT_83__0086:   #d8 $9C, $01                     ; DW 019C	;Setup/Play Music
_CALT_84__0088:   #d8 $1F, $09                     ; DW 091F	;Read Controller FF90-FF95
_CALT_85__008A:   #d8 $9D, $08                     ; DW 089D	;Clear A
_CALT_86__008C:   #d8 $FF, $08                     ; DW 08FF	;Clear Screen 2 RAM
_CALT_87__008E:   #d8 $02, $09                     ; DW 0902	;Clear Screen RAM
_CALT_88__0090:   #d8 $15, $09                     ; DW 0915	;Clear C4B0~C593
_CALT_89__0092:   #d8 $0D, $09                     ; DW 090D	;Clear C594~C7FF
_CALT_8A__0094:   #d8 $1A, $09                     ; DW 091A	;Clear RAM (HL+)xB
_CALT_8B__0096:   #d8 $1B, $0C                     ; DW 0C1B	;HL <== HL+DE
_CALT_8C__0098:   #d8 $0E, $0C                     ; DW 0C0E	;[PC+1] HL +- byte
_CALT_8D__009A:   #d8 $18, $0C                     ; DW 0C18	;HL <== HL+E
_CALT_8E__009C:   #d8 $8C, $09                     ; DW 098C	;Swap C258+ <==> C000+
_CALT_8F__009E:   #d8 $81, $09                     ; DW 0981	;C000+ ==> C258+
_CALT_90__00A0:   #d8 $7E, $09                     ; DW 097E	;C258+ ==> C000+
_CALT_91__00A2:   #d8 $CD, $01                     ; DW 01CD	;CALT 00A0, CALT 00A4
_CALT_92__00A4:   #d8 $37, $0B                     ; DW 0B37	;?? (Move some RAM around...)
_CALT_93__00A6:   #d8 $D7, $08                     ; DW 08D7	;HL <== AxE
_CALT_94__00A8:   #d8 $A0, $08                     ; DW 08A0	;XCHG HL,DE
_CALT_95__00AA:   #d8 $11, $0D                     ; DW 0D11	;((HL+) ==> (DE+))xB
_CALT_96__00AC:   #d8 $0A, $00                     ; DW 000A	;((HL-) ==> (DE-))xB
_CALT_97__00AE:   #d8 $F3, $08                     ; DW 08F3	;((HL+) <==> (DE+))xB
_CALT_98__00B0:   #d8 $99, $09                     ; DW 0999	;Set Dot; B,C = X-,Y-position
_CALT_99__00B2:   #d8 $C7, $09                     ; DW 09C7	;[PC+2] Draw Horizontal Line
_CALT_9A__00B4:   #d8 $E4, $09                     ; DW 09E4	;[PC+3] Print Bytes on-Screen
_CALT_9B__00B6:   #d8 $29, $0A                     ; DW 0A29	;[PC+3] Print Text on-Screen
_CALT_9C__00B8:   #d8 $0E, $0B                     ; DW 0B0E	;Byte -> Point to Font Graphic
_CALT_9D__00BA:   #d8 $F1, $0B                     ; DW 0BF1	;Set HL to screen (B,C)
_CALT_9E__00BC:   #d8 $24, $0C                     ; DW 0C24	;HL=C4B0+(A*$10)
_CALT_9F__00BE:   #d8 $1B, $09                     ; DW 091B	;A ==> (HL+)xB
_CALT_A0__00C0:   #d8 $6E, $0C                     ; DW 0C6E	;(RLR A)x4
_CALT_A1__00C2:   #d8 $5F, $00                     ; DW 005F	;(DE+)-(HL+) ==> A
_CALT_A2__00C4:   #d8 $63, $00                     ; DW 0063	;?? (Find 1st diff. byte in (HL),(DE)xB)
_CALT_A3__00C6:   #d8 $6D, $00                     ; DW 006D	;?? (Find diff. & Copy bytes)
_CALT_A4__00C8:   #d8 $5D, $0F                     ; DW 0F5D	;[PC+1] 8~32-bit Add/Subtract (dec/hex)
_CALT_A5__00CA:   #d8 $42, $0F                     ; DW 0F42	;[PC+1] Invert 8 bytes at (C4B8+A*$10)
_CALT_A6__00CC:   #d8 $2C, $0F                     ; DW 0F2C	;Invert Screen RAM (C000~)
_CALT_A7__00CE:   #d8 $2F, $0F                     ; DW 0F2F	;Invert Screen 2 RAM (C258~)
_CALT_A8__00D0:   #d8 $6E, $0E                     ; DW 0E6E	;[PC+1] ?? (Unpack 8 bytes -> 64 bytes (Twice!))
_CALT_A9__00D2:   #d8 $98, $0E                     ; DW 0E98	;[PC+1] ?? (Unpack & Roll 8 bits)
_CALT_AA__00D4:   #d8 $A4, $0E                     ; DW 0EA4	;[PC+1] ?? (Roll 8 bits -> Byte?)
_CALT_AB__00D6:   #d8 $D2, $0E                     ; DW 0ED2	;[PC+x] ?? (Add/Sub multiple bytes)
_CALT_AC__00D8:   #d8 $D9, $0F                     ; DW 0FD9	;[PC+1] INC/DEC Range of bytes from (HL)
_CALT_AD__00DA:   #d8 $B1, $09                     ; DW 09B1	;Clear Dot; B,C = X-,Y-position

_CALT_AE__00DC:   #d8 $12, $40                     ; DW 4012      ;Jump table for cartridge routines
_CALT_AF__00DE:   #d8 $15, $40                     ; DW 4015
_CALT_B0__00E0:   #d8 $18, $40                     ; DW 4018
_CALT_B1__00E2:   #d8 $1B, $40                     ; DW 401B
_CALT_B2__00E4:   #d8 $1E, $40                     ; DW 401E
_CALT_B3__00E6:   #d8 $21, $40                     ; DW 4021
_CALT_B4__00E8:   #d8 $24, $40                     ; DW 4024
_CALT_B5__00EA:   #d8 $27, $40                     ; DW 4027
_CALT_B6__00EC:   #d8 $2A, $40                     ; DW 402A
_CALT_B7__00EE:   #d8 $2D, $40                     ; DW 402D
;-----------------------------------------------------------
;                        Timer Interrupt
INTT____00F0:   #d8 $45, $80, $01                               ; ONIW    80,01	;If 1, don't jump to cart.
________00F3:   jre $015B

________00F5:   #d8 $30, $9A                                    ; DCRW    9A
________00F7:   jre $0158

________00F9:   push va
________00FB:   #d8 $28, $8F                                    ; LDAW    8F
________00FD:   #d8 $38, $9A                                    ; STAW    9A
________00FF:   #d8 $30, $99                                    ; DCRW    99
________0101:   jre $012E

________0103:   push bc
________0105:   push de
________0107:   push hl
________0109:   #d8 $69, $03                                    ; MVI     A,03
________010B:   mov tmm, a                                      ;Adjust timer
________010D:   #d8 $69, $53                                    ; MVI     A,53
________010F:   dcr a
________0110:   jr $010F
________0111:   #d8 $45, $80, $02                               ; ONIW    80,02
________0114:   jr $011C

________0115:   #d8 $70, $3F, $84, $FF                          ; LHLD    FF84
________0119:   calf $08A9                                      ;Music-playing code...
________011B:   jr $0128

________011C:   #d8 $05, $80, $FC                               ; ANIW    80,FC
________011F:   #d8 $69, $07                                    ; MVI     A,07
________0121:   mov tmm, a
________0123:   #d8 $69, $74                                    ; MVI     A,74
________0125:   mov tm0, a
________0127:   stm
________0128:   pop hl
________012A:   pop de
________012C:   pop bc
________012E:   #d8 $28, $88                                    ; LDAW    88
________0130:   #d8 $46, $01                                    ; ADI     A,01
________0132:   daa
________0133:   #d8 $38, $88                                    ; STAW    88
________0135:   #d8 $48, $1A                                    ; SKN     CY
________0137:   jr $0139
________0138:   jr $014E

________0139:   #d8 $20, $89                                    ; INRW    89
________013B:   nop
________013C:   #d8 $28, $87                                    ; LDAW    87
________013E:   #d8 $46, $01                                    ; ADI     A,01
________0140:   daa
________0141:   #d8 $38, $87                                    ; STAW    87
________0143:   #d8 $48, $1A                                    ; SKN     CY
________0145:   jr $0147
________0146:   jr $014E

________0147:   #d8 $28, $86                                    ; LDAW    86
________0149:   #d8 $46, $01                                    ; ADI     A,01
________014B:   daa
________014C:   #d8 $38, $86                                    ; STAW    86
________014E:   #d8 $45, $8A, $80                               ; ONIW    8A,80
________0151:   #d8 $20, $8A                                    ; INRW    8A
________0153:   #d8 $20, $8B                                    ; INRW    8B
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
________0163:   #d8 $55, $80, $80                               ; OFFIW   80,80	;If 0, don't go to cart's INT routine
________0166:   jmp $4009
;---------------------------------------
________0169:   adc a, b                                        ;Probably a simple random-number generator.
________016B:   adc a, c
________016D:   adc a, d
________016F:   adc a, e
________0171:   adc a, h
________0173:   adc a, l
________0175:   #d8 $38, $8C                                    ; STAW    8C
________0177:   ral
________0179:   ral
________017B:   mov b, a
________017C:   pop de
________017E:   push de
________0180:   adc a, e
________0182:   #d8 $38, $8D                                    ; STAW    8D
________0184:   #d8 $48, $31                                    ; RLR
________0186:   #d8 $48, $31                                    ; RLR
________0188:   adc a, b
________018A:   #d8 $38, $8E                                    ; STAW    8E
________018C:   jre $0128
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
________0197:   #d8 $38, $99                                    ; STAW    99
________0199:   calf $08B6                                      ;Set note timers
________019B:   jr $01A3
;------------------------------------------------------------
;Setup/Play Music
;HL should already contain the address of the music data.
;Format of the data string is the same as "Play Sound", with $FF terminating the song.
CALT_83_019C:   di
________019E:   #d8 $15, $80, $02                               ; ORIW    80,02
________01A1:   calf $08A9                                      ;Read notes & set timers
________01A3:   ei                                              ;(sometimes skipped)
________01A5:   ret
;------------------------------------------------------------
;[PC+1] Check Cartridge
; Checks if the cart is present, and possibly jumps to ($4001) or ($4003)
; The parameter $C0 sends it to $4001, $C1 to $4003, etc...
CALT_80_01A6:   #d8 $34, $00, $40                               ; LXI     H,4000
________01A9:   ldax [hl]
________01AA:   #d8 $77, $55                                    ; EQI     A,55
________01AC:   rets

________01AD:   calt $008A                                      ; "Clear A"
________01AE:   #d8 $38, $89                                    ; STAW    89
________01B0:   ldax [hl]
________01B1:   #d8 $77, $55                                    ; EQI     A,55
________01B3:   rets
;----------------------------------
________01B4:   #d8 $75, $89, $03                               ; EQIW    89,03
________01B7:   jr $01B0

________01B8:   calf $0E4D                                      ;Sets a timer
________01BA:   #d8 $15, $80, $80                               ; ORIW    80,80
________01BD:   inx hl                                          ;->$4001
________01BE:   pop bc
________01C0:   ldax [bc]
________01C1:   #d8 $67, $C0                                    ; NEI     A,C0        ;To cart if it's $C0
________01C3:   jr $01C8

________01C4:   inx hl                                          ;->$4003
________01C5:   inx hl
________01C6:   dcr a
________01C7:   jr $01C1

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
CALT_81_01CF:   #d8 $64, $98, $08                               ; ORI     PA,08       ;(Port A, bit 3 on)
________01D2:   #d8 $34, $31, $C0                               ; LXI     H,C031
________01D5:   #d8 $24, $7D, $00                               ; LXI     D,007D
________01D8:   #d8 $6A, $00                                    ; MVI     B,00
________01DA:   #d8 $64, $88, $FB                               ; ANI     PA,FB       ;bit 2 off
________01DD:   mov a, b
________01DE:   mov pb, a                                       ;Port B = (A)
________01E0:   #d8 $64, $98, $02                               ; ORI     PA,02       ;bit 1 on
________01E3:   #d8 $64, $88, $FD                               ; ANI     PA,FD       ;bit 1 off
________01E6:   #d8 $6B, $31                                    ; MVI     C,31
________01E8:   #d8 $64, $98, $04                               ; ORI     PA,04       ;bit 2 on
________01EB:   ldax [hl-]                                      ;Screen data...
________01EC:   mov pb, a                                       ;...to Port B
________01EE:   #d8 $64, $98, $02                               ; ORI     PA,02       ;bit 1 on
________01F1:   #d8 $64, $88, $FD                               ; ANI     PA,FD       ;bit 1 off
________01F4:   dcr c
________01F5:   jr $01EB
________01F6:   calt $0096                                      ; "HL <== HL+DE"
________01F7:   mov a, b
________01F8:   #d8 $26, $40                                    ; ADINC   A,40
________01FA:   jr $01FE
________01FB:   mov b, a
________01FC:   jre $01DA
								;Set up writing for LCD controller #2
________01FE:   #d8 $64, $88, $F7                               ; ANI     PA,F7       ;bit 3 off
________0201:   #d8 $64, $98, $10                               ; ORI     PA,10       ;bit 4 on
________0204:   #d8 $34, $2C, $C1                               ; LXI     H,C12C
________0207:   #d8 $24, $19, $00                               ; LXI     D,0019
________020A:   #d8 $6A, $00                                    ; MVI     B,00
________020C:   #d8 $64, $88, $FB                               ; ANI     PA,FB       ;Same as in 1st loop
________020F:   mov a, b
________0210:   mov pb, a
________0212:   #d8 $64, $98, $02                               ; ORI     PA,02
________0215:   #d8 $64, $88, $FD                               ; ANI     PA,FD
________0218:   #d8 $6B, $31                                    ; MVI     C,31
________021A:   #d8 $64, $98, $04                               ; ORI     PA,04
________021D:   ldax [hl+]
________021E:   mov pb, a
________0220:   #d8 $64, $98, $02                               ; ORI     PA,02
________0223:   #d8 $64, $88, $FD                               ; ANI     PA,FD
________0226:   dcr c
________0227:   jr $021D
________0228:   calt $0096                                      ; "HL <== HL+DE"
________0229:   mov a, b
________022A:   #d8 $26, $40                                    ; ADINC   A,40
________022C:   jr $0230
________022D:   mov b, a
________022E:   jre $020C

________0230:   calt $008A                                      ; "Clear A"
________0231:   #d8 $38, $96                                    ; STAW    96
        						;Set up writing for LCD controller #3
________0233:   #d8 $64, $88, $EF                               ; ANI     PA,EF	;bit 4 off
________0236:   #d8 $64, $98, $20                               ; ORI     PA,20       ;bit 5 on
________0239:   #d8 $34, $32, $C0                               ; LXI     H,C032
________023C:   #d8 $24, $5E, $C1                               ; LXI     D,C15E
________023F:   #d8 $6A, $00                                    ; MVI     B,00
________0241:   #d8 $64, $88, $FB                               ; ANI     PA,FB
________0244:   mov a, b
________0245:   mov pb, a
________0247:   #d8 $64, $98, $02                               ; ORI     PA,02
________024A:   #d8 $64, $88, $FD                               ; ANI     PA,FD
________024D:   nop
________024E:   #d8 $64, $98, $04                               ; ORI     PA,04

________0251:   #d8 $6B, $18                                    ; MVI     C,18

________0253:   ldax [hl+]
________0254:   mov pb, a
________0256:   #d8 $64, $98, $02                               ; ORI     PA,02
________0259:   #d8 $64, $88, $FD                               ; ANI     PA,FD
________025C:   dcr c
________025D:   jr $0253

________025E:   push de
________0260:   #d8 $24, $32, $00                               ; LXI     D,0032
________0263:   calt $0096                                      ; "HL <== HL+DE"
________0264:   pop de
________0266:   calt $00A8                                      ; "XCHG HL,DE"
________0267:   #d8 $20, $96                                    ; INRW    96          ;Skip if a carry...
________0269:   #d8 $55, $96, $01                               ; OFFIW   96,01       ;Do alternating lines
________026C:   jr $0251

________026D:   mov a, b
________026E:   #d8 $26, $40                                    ; ADINC   A,40
________0270:   jr $0274
________0271:   mov b, a
________0272:   jre $0241

________0274:   #d8 $64, $88, $DF                               ; ANI     PA,DF       ;bit 5 off
________0277:   ret
;-----------------------------------------------------------
	;Sound note and timer data...
________0278:   #d8 $B2, $0A, $EE, $07, $E1, $08, $D4, $09, $C8,$09, $BD, $0A, $B2, $0A, $A8, $0B
________0288:   #d8 $9E, $0C, $96, $0C, $8D, $0D, $85, $0E, $7E,$0F, $77, $10, $70, $11, $6A, $12
________0298:   #d8 $64, $13, $5E, $14, $59, $15, $54, $16, $4F,$17, $4A, $19, $46, $1A, $42, $1C
________02A8:   #d8 $3E, $1E, $3B, $1F, $37, $22, $34, $23, $31,$26, $2E, $28, $2C, $2A, $29, $2D
________02B8:   #d8 $27, $2F, $25, $31, $23, $34, $21, $37, $1F,$3B, $1D, $3F
;-----------------------------------------------------------
	;Graphic Font Data
________02C4:   #d8 $00, $00, $00, $00, $00, $00, $00, $4F, $00,$00, $00, $07, $00, $07, $00, $14
________02D4:   #d8 $7F, $14, $7F, $14, $24, $2A, $7F, $2A, $12,$23, $13, $08, $64, $62, $36, $49
________02E4:   #d8 $55, $22, $50, $00, $05, $03, $00, $00, $00,$1C, $22, $41, $00, $00, $41, $22
________02F4:   #d8 $1C, $00, $14, $08, $3E, $08, $14, $08, $08,$3E, $08, $08, $00, $50, $30, $00
________0304:   #d8 $00, $08, $08, $08, $08, $08, $00, $60, $60,$00, $00, $20, $10, $08, $04, $02
________0314:   #d8 $3E, $51, $49, $45, $3E, $00, $42, $7F, $40,$00, $42, $61, $51, $49, $46, $21
________0324:   #d8 $41, $45, $4B, $31, $18, $14, $12, $7F, $10,$27, $45, $45, $45, $39, $3C, $4A
________0334:   #d8 $49, $49, $30, $01, $71, $09, $05, $03, $36,$49, $49, $49, $36, $06, $49, $49
________0344:   #d8 $29, $1E, $00, $36, $36, $00, $00, $00, $56,$36, $00, $00, $08, $14, $22, $41
________0354:   #d8 $00, $14, $14, $14, $14, $14, $00, $41, $22,$14, $08, $02, $01, $51, $09, $06
________0364:   #d8 $32, $49, $79, $41, $3E, $7E, $11, $11, $11,$7E, $7F, $49, $49, $49, $36, $3E
________0374:   #d8 $41, $41, $41, $22, $7F, $41, $41, $22, $1C,$7F, $49, $49, $49, $49, $7F, $09
________0384:   #d8 $09, $09, $01, $3E, $41, $49, $49, $7A, $7F,$08, $08, $08, $7F, $00, $41, $7F
________0394:   #d8 $41, $00, $20, $40, $41, $3F, $01, $7F, $08,$14, $22, $41, $7F, $40, $40, $40
________03A4:   #d8 $40, $7F, $02, $0C, $02, $7F, $7F, $04, $08,$10, $7F, $3E, $41, $41, $41, $3E
________03B4:   #d8 $7F, $09, $09, $09, $06, $3E, $41, $51, $21,$5E, $7F, $09, $19, $29, $46, $46
________03C4:   #d8 $49, $49, $49, $31, $01, $01, $7F, $01, $01,$3F, $40, $40, $40, $3F, $1F, $20
________03D4:   #d8 $40, $20, $1F, $3F, $40, $38, $40, $3F, $63,$14, $08, $14, $63, $07, $08, $70
________03E4:   #d8 $08, $07, $61, $51, $49, $45, $43, $00, $7F,$41, $41, $00, $15, $16, $7C, $16
________03F4:   #d8 $15, $00, $41, $41, $7F, $00, $04, $02, $01,$02, $04, $40, $40, $40, $40, $40
________0404:   #d8 $00, $1F, $11, $11, $1F, $00, $00, $11, $1F,$10, $00, $1D, $15, $15, $17, $00
________0414:   #d8 $11, $15, $15, $1F, $00, $0F, $08, $1F, $08,$00, $17, $15, $15, $1D, $00, $1F
________0424:   #d8 $15, $15, $1D, $00, $03, $01, $01, $1F, $00,$1F, $15, $15, $1F, $00, $17, $15
________0434:   #d8 $15, $1F, $1E, $09, $09, $09, $1E, $1F, $15,$15, $15, $0A, $0E, $11, $11, $11
________0444:   #d8 $11, $1F, $11, $11, $11, $0E, $1F, $15, $15,$15, $11, $1F, $05, $05, $05, $01
________0454:   #d8 $0E, $11, $11, $15, $1D, $1F, $04, $04, $04,$1F, $00, $11, $1F, $11, $00, $08
________0464:   #d8 $10, $11, $0F, $01, $1F, $08, $04, $0A, $11,$1F, $10, $10, $10, $10, $1F, $02
________0474:   #d8 $04, $02, $1F, $1F, $02, $04, $08, $1F, $0E,$11, $11, $11, $0E, $1F, $05, $05
________0484:   #d8 $05, $02, $0E, $11, $15, $09, $16, $1F, $05,$05, $0D, $12, $12, $15, $15, $15
________0494:   #d8 $09, $01, $01, $1F, $01, $01, $0F, $10, $10,$10, $0F, $07, $08, $10, $08, $07
________04A4:   #d8 $0F, $10, $0C, $10, $0F, $1B, $0A, $04, $0A,$1B, $03, $04, $18, $04, $03, $11
________04B4:   #d8 $19, $15, $13, $11            
;-----------------------------------------------------------
	;Text data
________04B8:   #d8 $2C, $23, $24, $00, $24, $2F, $34, $00, $2D,$21, $34, $32, $29, $38, $00, $33	;LCD DOT MATRIX SYSTEM
________04C8:   #d8 $39, $33, $34, $25, $2D, $00, $26, $35, $2C,$2C, $00, $27, $32, $21, $30, $28 ;FULL GRAPHIC
________04D8:   #d8 $29, $23, $00, $08, $17, $15, $0A, $16, $14,$00, $24, $2F, $34, $33, $09, $00 ;(75*64 DOTS)
________04E8:   #d8 $00, $00, $00, $FF            
	;Music notation data
________04EC:   #d8 $00, $0A, $06, $0A, $0B, $0A, $0F, $0A, $12,$14, $12, $14    
________04F8:   #d8 $12, $14, $12, $14, $0A, $14, $0A, $14, $0B,$14, $0B, $07, $0D, $07, $0B, $07
________0508:   #d8 $10, $14, $10, $14, $0F, $14, $0F, $14, $0D,$28, $00, $0A, $06, $0A, $0B, $0A
________0518:   #d8 $0F, $0A, $12, $14, $12, $14, $12, $14, $12,$14, $0A, $14, $0A, $07, $0B, $07
________0528:   #d8 $0A, $07, $0B, $14, $0B, $07, $0D, $07, $0B,$07, $0D, $14, $0D, $14, $06, $14
________0538:   #d8 $08, $0A, $0A, $0A, $0B, $3C, $00, $50, $FF 
	;Text data
________0541:   #d8 $27, $32, $21, $0E, $00, $38, $10, $10, $0C,$39, $10, $10     		;GRA. X00,Y00

________054D:   #d8 $30, $35, $3A, $3A, $2C, $25                ;PUZZLE

________0553:   #d8 $34, $29, $2D, $25, $1B, $10, $10, $10, $0E,$10      			;TIME:000.0
	;Grid data, probably
________055D:   #d8 $04, $04, $08, $01, $01, $08, $04, $04, $08,$01, $01, $02, $04, $04, $02, $01
________056D:   #d8 $01, $02              

________056F:   #d8 $08, $04, $02, $04, $08, $08, $08, $01, $02,$01, $08, $04, $02, $02, $04, $02
;-----------------------------------------------------------
;from 005C -

________057F:   calt $008C                                      ;Clear Screen 2 RAM
________0580:   #d8 $38, $D8                                    ; STAW    D8          ;Set mem locations to 0
________0582:   #d8 $38, $82                                    ; STAW    82
________0584:   #d8 $38, $A5                                    ; STAW    A5
________0586:   #d8 $34, $B8, $04                               ; LXI     H,04B8	;Start of scrolltext
________0589:   #d8 $70, $3E, $D6, $FF                          ; SHLD    FFD6	;Save pointer
________058D:   calf $0D68                                      ;Setup RAM vars
________058F:   calt $00A0                                      ; "C258+ ==> C000+"
________0590:   calt $0082                                      ;Copy Screen RAM to LCD Driver
________0591:   calt $008A                                      ; "Clear A"
________0592:   #d8 $38, $DA                                    ; STAW    DA
________0594:   #d8 $38, $D1                                    ; STAW    D1
________0596:   #d8 $38, $D2                                    ; STAW    D2
________0598:   #d8 $38, $D5                                    ; STAW    D5
________059A:   #d8 $69, $FF                                    ; MVI     A,FF
________059C:   #d8 $38, $D0                                    ; STAW    D0
________059E:   #d8 $34, $D8, $FF                               ; LXI     H,FFD8
________05A1:   #d8 $70, $93                                    ; XRAX    H		;A=$FF XOR ($FFD8)
________05A3:   #d8 $38, $D8                                    ; STAW    D8
________05A5:   #d8 $69, $60                                    ; MVI     A,60        ;A delay value for the scrolltext
________05A7:   #d8 $38, $8A                                    ; STAW    8A

;Main Loop starts here!
________05A9:   calt $0080                                      ;[PC+1] Check Cartridge
________05AA:   #d8 $C1                                         ; DB $C1 		;Jump to ($4003) in cartridge

________05AB:   #d8 $55, $80, $02                               ; OFFIW   80,02       ;If bit 1 is on, no music
________05AE:   jr $05B2
________05AF:   calf $0E64                                      ;Point HL to the music data
________05B1:   calt $0086                                      ;Setup/Play Music
________05B2:   calt $0088                                      ;Read Controller FF90-FF95
________05B3:   #d8 $65, $93, $01                               ; NEIW    93,01       ;If Select is pressed...
________05B6:   jmp $06EC                                       ;Setup puzzle
________05B9:   #d8 $65, $D2, $0F                               ; NEIW    D2,0F
________05BC:   jre $0591                                       ;(go to main loop setup)
________05BE:   calf $0D1F                                      ;Draw spiral dot-by-dot
________05C0:   calf $0D1F                                      ;Draw spiral dot-by-dot
________05C2:   calt $00A0                                      ; "C258+ ==> C000+"
________05C3:   calt $0082                                      ;Copy Screen RAM to LCD Driver
________05C4:   #d8 $65, $93, $08                               ; NEIW    93,08       ;If Start is pressed...
________05C7:   jr $05D1                                        ;Jump to graphic program

________05C8:   #d8 $75, $8A, $80                               ; EQIW    8A,80       ;Delay for the scrolltext
________05CB:   jre $05A9                                       ;JRE Main Loop
________05CD:   calf $0CE2                                      ;Scroll Text routine
________05CF:   jre $05A5                                       ;Reset scrolltext delay...
;-----------------------------------------------------------
;"Paint" program setup routines
________05D1:   calf $0E4D                                      ;Turn timer on
________05D3:   calt $008C                                      ; "Clear Screen 2 RAM"
________05D4:   calt $0090                                      ; "Clear C4B0~C593"
________05D5:   #d8 $34, $41, $05                               ; LXI     H,0541      ;"GRA"
________05D8:   calt $00B6                                      ; "[PC+3] Print Text on-Screen"
________05D9:   #d8 $02, $00, $1C                               ; DB $02,$00,$1C     ;Parameters for the text routine
________05DC:   #d8 $69, $05                                    ; MVI     A,05
________05DE:   #d8 $34, $B8, $C4                               ; LXI     H,C4B8
________05E1:   stax [hl+]
________05E2:   inx hl
________05E3:   stax [hl]
________05E4:   inr a
________05E5:   #d8 $34, $70, $C5                               ; LXI     H,C570
________05E8:   stax [hl+]
________05E9:   inr a
________05EA:   #d8 $38, $A6                                    ; STAW    A6
________05EC:   #d8 $69, $39                                    ; MVI     A,39
________05EE:   stax [hl+]
________05EF:   inr a
________05F0:   #d8 $38, $A7                                    ; STAW    A7
________05F2:   calt $008A                                      ; "Clear A"
________05F3:   stax [hl+]
________05F4:   #d8 $38, $A0                                    ; STAW    A0          ;X,Y position for cursor
________05F6:   #d8 $38, $A1                                    ; STAW    A1
________05F8:   #d8 $69, $99                                    ; MVI     A,99        ;What does this do?
________05FA:   #d8 $6A, $0A                                    ; MVI     B,0A
________05FC:   inx hl
________05FD:   inx hl
________05FE:   stax [hl+]		                                ;Just writes "99s" 3 bytes apart
________05FF:   inx hl
________0600:   inx hl
________0601:   dcr b
________0602:   jr $05FE
________0603:   calf $0D68                                      ;Draw Border

________0605:   #d8 $69, $70                                    ; MVI     A,70
________0607:   #d8 $38, $8A                                    ; STAW    8A
________0609:   #d8 $34, $A0, $FF                               ; LXI     H,FFA0      ;Print the X-, Y- position
________060C:   calt $00B4                                      ; "[PC+3] Print Bytes on-Screen"
________060D:   #d8 $26, $00, $19                               ; DB $26,$00,$19     ;Parameters for the print routine
________0610:   #d8 $34, $A1, $FF                               ; LXI     H,FFA1
________0613:   calt $00B4                                      ; "[PC+3] Print Bytes on-Screen"
________0614:   #d8 $3E, $00, $19                               ; DB $3E,$00,$19     ;Parameters for the print routine
________0617:   calt $00A2                                      ; "CALT A0, CALT A4"
________0618:   calt $0080                                      ;[PC+1] Check Cartridge
________0619:   #d8 $C1                                         ; DB $C1		;Jump to ($4003) in cartridge

________061A:   #d8 $45, $8A, $80                               ; ONIW    8A,80
________061D:   jr $0618
________061E:   #d8 $34, $72, $C5                               ; LXI     H,C572
________0621:   ldax [hl]
________0622:   #d8 $16, $FF                                    ; XRI     A,FF
________0624:   stax [hl]
________0625:   calt $0088                                      ;Read Controller FF90-FF95
________0626:   #d8 $28, $93                                    ; LDAW    93
________0628:   #d8 $57, $3F                                    ; OFFI    A,3F        ;Test Buttons 1,2,3,4
________062A:   jr $0633
________062B:   #d8 $28, $92                                    ; LDAW    92
________062D:   #d8 $57, $0F                                    ; OFFI    A,0F	;Test U,D,L,R
________062F:   jre $0673
________0631:   jre $0605
;------------------------------------------------------------
________0633:   #d8 $45, $95, $09                               ; ONIW    95,09
________0636:   jr $0647
________0637:   #d8 $77, $08                                    ; EQI     A,08        ;Start clears the screen
________0639:   jr $063F

________063A:   calt $0084                                      ;[PC+2] Setup/Play Sound
________063B:   #d8 $22, $03                                    ; DB $22,$03
________063D:   jre $05DC                                       ;Clear screen

________063F:   #d8 $77, $01                                    ; EQI     A,01        ;Select goes to the Puzzle
________0641:   jr $0647

________0642:   calt $0084                                      ;[PC+2] Setup/Play Sound
________0643:   #d8 $23, $03                                    ; DB $23,$03
________0645:   jre $06EE                                       ;To Puzzle Setup

________0647:   #d8 $77, $02                                    ; EQI     A,02        ;Button 1
________0649:   jr $064E
________064A:   calt $0084                                      ;[PC+2] Setup/Play Sound
________064B:   #d8 $19, $03                                    ; DB $19,$03
________064D:   jr $0664                                        ;Clear a dot

________064E:   #d8 $77, $10                                    ; EQI     A,10        ;Button 2
________0650:   jr $0655
________0651:   calt $0084                                      ;[PC+2] Setup/Play Sound
________0652:   #d8 $1B, $03                                    ; DB $1B,$03
________0654:   jr $0664                                        ;Clear a dot

________0655:   #d8 $77, $04                                    ; EQI     A,04        ;Button 3
________0657:   jr $065C
________0658:   calt $0084                                      ;[PC+2] Setup/Play Sound
________0659:   #d8 $1D, $03                                    ; DB $1D,$03
________065B:   jr $066C                                        ;Set a dot

________065C:   #d8 $77, $20                                    ; EQI     A,20        ;Button 4
________065E:   jre $0680
________0660:   calt $0084                                      ;[PC+2] Setup/Play Sound
________0661:   #d8 $1E, $03                                    ; DB $1E,$03
________0663:   jr $066C                                        ;Set a dot

________0664:   #d8 $28, $A6                                    ; LDAW    A6
________0666:   mov b, a
________0667:   #d8 $28, $A7                                    ; LDAW    A7
________0669:   mov c, a
________066A:   calt $00DA                                      ; "Clear Dot; B,C = X-,Y-position"
________066B:   jr $0673

________066C:   #d8 $28, $A6                                    ; LDAW    A6
________066E:   mov b, a
________066F:   #d8 $28, $A7                                    ; LDAW    A7
________0671:   mov c, a
________0672:   calt $00B0                                      ; "Set Dot; B,C = X-,Y-position"

________0673:   #d8 $28, $92                                    ; LDAW    92
________0675:   #d8 $67, $0F                                    ; NEI     A,0F        ;Check if U,D,L,R pressed at once??
________0677:   jre $0605
________0679:   #d8 $47, $01                                    ; ONI     A,01        ;Up
________067B:   jr $0694

________067C:   #d8 $28, $A7                                    ; LDAW    A7
________067E:   #d8 $67, $0E                                    ; NEI     A,0E        ;Check lower limits of X-pos
________0680:   jr $069B

________0681:   dcr a
________0682:   #d8 $38, $A7                                    ; STAW    A7
________0684:   dcr a
________0685:   mov [$C571], a
________0689:   #d8 $28, $A1                                    ; LDAW    A1
________068B:   #d8 $46, $01                                    ; ADI     A,01
________068D:   daa
________068E:   #d8 $38, $A1                                    ; STAW    A1
________0690:   calt $0084                                      ;[PC+2] Setup/Play Sound
________0691:   #d8 $12, $03                                    ; DB $12,$03
________0693:   jr $06AE

________0694:   #d8 $47, $04                                    ; ONI     A,04        ;Down
________0696:   jr $06AE

________0697:   #d8 $28, $A7                                    ; LDAW    A7
________0699:   #d8 $67, $3A                                    ; NEI     A,3A        ;Check lower cursor limit
________069B:   jr $06B7

________069C:   inr a
________069D:   #d8 $38, $A7                                    ; STAW    A7
________069F:   dcr a
________06A0:   mov [$C571], a
________06A4:   #d8 $28, $A1                                    ; LDAW    A1
________06A6:   #d8 $46, $99                                    ; ADI     A,99
________06A8:   daa
________06A9:   #d8 $38, $A1                                    ; STAW    A1
________06AB:   calt $0084                                      ;[PC+2] Setup/Play Sound
________06AC:   #d8 $14, $03                                    ; DB $14,$03

________06AE:   #d8 $28, $92                                    ; LDAW    92
________06B0:   #d8 $47, $08                                    ; ONI     A,08        ;Right
________06B2:   jr $06CC

________06B3:   #d8 $28, $A6                                    ; LDAW    A6
________06B5:   #d8 $67, $43                                    ; NEI     A,43
________06B7:   jr $06D4

________06B8:   inr a
________06B9:   #d8 $38, $A6                                    ; STAW    A6
________06BB:   dcr a
________06BC:   mov [$C570], a
________06C0:   #d8 $28, $A0                                    ; LDAW    A0
________06C2:   #d8 $46, $01                                    ; ADI     A,01
________06C4:   daa
________06C5:   #d8 $38, $A0                                    ; STAW    A0
________06C7:   calt $0084                                      ;[PC+2] Setup/Play Sound
________06C8:   #d8 $17, $03                                    ; DB $17,$03
________06CA:   jre $0605

________06CC:   #d8 $47, $02                                    ; ONI     A,02        ;Left
________06CE:   jre $0605
________06D0:   #d8 $28, $A6                                    ; LDAW    A6
________06D2:   #d8 $67, $07                                    ; NEI     A,07
________06D4:   jr $06E8

________06D5:   dcr a
________06D6:   #d8 $38, $A6                                    ; STAW    A6
________06D8:   dcr a
________06D9:   mov [$C570], a
________06DD:   #d8 $28, $A0                                    ; LDAW    A0
________06DF:   #d8 $46, $99                                    ; ADI     A,99
________06E1:   daa
________06E2:   #d8 $38, $A0                                    ; STAW    A0
________06E4:   calt $0084                                      ;[PC+2] Setup/Play Sound
________06E5:   #d8 $16, $03                                    ; DB $16,$03
________06E7:   jr $06CA
;------------------------------------------------------------
________06E8:   calt $0084                                      ;[PC+2] Setup/Play Sound
________06E9:   #d8 $01, $03                                    ; DB $01,$03
________06EB:   jr $06E7
;------------------------------------------------------------
;Puzzle Setup Routines...
________06EC:   calf $0E4D                                      ;Reset the timer?
________06EE:   #d8 $69, $21                                    ; MVI     A,21
________06F0:   #d8 $6A, $0A                                    ; MVI     B,0A
________06F2:   calf $0E67                                      ;LXI H,$C7F2
________06F4:   stax [hl+]
________06F5:   inr a                                           ;Set up the puzzle tiles in RAM
________06F6:   dcr b
________06F7:   jr $06F4
________06F8:   mov a, b                                        ;$FF
________06F9:   stax [hl+]
________06FA:   calf $0E67
________06FC:   #d8 $6A, $0B                                    ; MVI     B,0B
________06FE:   #d8 $24, $5E, $C7                               ; LXI     D,C75E
________0701:   calt $00AA                                      ; "((HL+) ==> (DE+))xB"
________0702:   #d8 $6A, $0B                                    ; MVI     B,0B
________0704:   #d8 $34, $5E, $C7                               ; LXI     H,C75E
________0707:   #d8 $24, $52, $C7                               ; LXI     D,C752
________070A:   calt $00AA                                      ; "((HL+) ==> (DE+))xB"
________070B:   calt $008C                                      ; "Clear Screen 2 RAM"
________070C:   calf $0D68                                      ;Draw Border
________070E:   calf $0D92                                      ;Draw the grid
________0710:   calf $0C7B                                      ;Write "PUZZLE"
________0712:   #d8 $05, $89, $00                               ; ANIW    89,00
________0715:   #d8 $69, $60                                    ; MVI     A,60
________0717:   #d8 $38, $8A                                    ; STAW    8A
________0719:   calt $0080                                      ;[PC+1] Check Cartridge
________071A:   #d8 $C1                                         ; DB $C1		;Jump to ($4003) in cartridge
;------------------------------------------------------------
________071B:   #d8 $6A, $0B                                    ; MVI     B,0B
________071D:   #d8 $34, $52, $C7                               ; LXI     H,C752
________0720:   #d8 $24, $F2, $C7                               ; LXI     D,C7F2
________0723:   calt $00AA                                      ; "((HL+) ==> (DE+))xB"
________0724:   #d8 $6A, $11                                    ; MVI     B,11
________0726:   #d8 $34, $5D, $05                               ; LXI     H,055D      ;Point to "grid" data
________0729:   ldax [hl+]
________072A:   push bc
________072C:   push hl
________072E:   calf $0DD3                                      ;This probably draws the tiles
________0730:   nop                                             ;Or randomizes them??
________0731:   pop hl
________0733:   pop bc
________0735:   dcr b
________0736:   jr $0729
________0737:   #d8 $6A, $0B                                    ; MVI     B,0B        
________0739:   calf $0E67                                      ;LXI H,$C7F2
________073B:   #d8 $24, $52, $C7                               ; LXI     D,C752
________073E:   calt $00AA                                      ; "((HL+) ==> (DE+))xB"
________073F:   calt $0088                                      ;Read Controller FF90-FF95
________0740:   #d8 $65, $93, $01                               ; NEIW    93,01       ;Select
________0743:   #d8 $45, $95, $01                               ; ONIW    95,01	;Select trigger
________0746:   jr $074D
________0747:   calt $0084                                      ;[PC+2] Setup/Play Sound
________0748:   #d8 $14, $03                                    ; DB $14,$03
________074A:   jmp $05D1                                       ;Go to Paint Program
________074D:   #d8 $65, $93, $08                               ; NEIW    93,08	;Start
________0750:   #d8 $45, $95, $08                               ; ONIW    95,08
________0753:   jr $0758
________0754:   calt $0084                                      ;[PC+2] Setup/Play Sound
________0755:   #d8 $16, $03                                    ; DB $16,$03
________0757:   jr $0765
;------------------------------------------------------------
________0758:   #d8 $75, $8A, $80                               ; EQIW    8A,80
________075B:   jre $0719                                       ;Draw Tiles
________075D:   #d8 $75, $89, $3C                               ; EQIW    89,3C
________0760:   jre $0715                                       ;Reset timer?
________0762:   jmp $057F                                       ;Go back to startup screen(?)
;------------------------------------------------------------
________0765:   calt $008C                                      ; "Clear Screen 2 RAM"
________0766:   #d8 $34, $53, $05                               ; LXI     H,0553      ;"TIME"
________0769:   calt $00B6                                      ; "[PC+3] Print Text on-Screen"
________076A:   #d8 $0E, $00, $1A                               ; DB $0E,$00,$1A
________076D:   #d8 $34, $86, $FF                               ; LXI     H,FF86
________0770:   #d8 $6A, $02                                    ; MVI     B,02
________0772:   calt $0094                                      ; "Clear RAM (HL+)xB"
________0773:   #d8 $28, $8C                                    ; LDAW    8C
________0775:   #d8 $07, $0F                                    ; ANI     A,0F
________0777:   mov b, a
________0778:   #d8 $34, $6F, $05                               ; LXI     H,056F
________077B:   ldax [hl+]
________077C:   push bc
________077E:   push hl
________0780:   calf $0DD3                                      ;Draw Tiles
________0782:   nop
________0783:   pop hl
________0785:   pop bc
________0787:   dcr b
________0788:   jr $077B
________0789:   calf $0D68                                      ;Draw Border (again)
________078B:   calf $0D92                                      ;Draw the grid (again)
________078D:   calf $0C82                                      ;Scroll text? Write time in decimal?
________078F:   #d8 $69, $60                                    ; MVI     A,60
________0791:   #d8 $38, $8A                                    ; STAW    8A
________0793:   calt $0080                                      ;[PC+1] Check Cartridge
________0794:   #d8 $C1                                         ; DB $C1		;Jump to ($4003) in cartridge
;------------------------------------------------------------
________0795:   #d8 $34, $86, $FF                               ; LXI     H,FF86
________0798:   calt $00B4                                      ; "[PC+3] Print Bytes on-Screen"
________0799:   #d8 $2C, $00, $12                               ; DB $2C,$00,$12
________079C:   #d8 $34, $88, $FF                               ; LXI     H,FF88
________079F:   calt $00B4                                      ; "[PC+3] Print Bytes on-Screen"
________07A0:   #d8 $44, $00, $08                               ; DB $44,$00,$08
________07A3:   calt $00A0                                      ; "C258+ ==> C000+"
________07A4:   calt $0082                                      ;Copy Screen RAM to LCD Driver
________07A5:   calt $0088                                      ;Read Controller FF90-FF95
________07A6:   #d8 $65, $93, $01                               ; NEIW    93,01       ;Select
________07A9:   jre $0747                                       ;To Paint Program
________07AB:   #d8 $65, $93, $08                               ; NEIW    93,08	;Start
________07AE:   #d8 $45, $95, $08                               ; ONIW    95,08	;Start trigger
________07B1:   jr $07B4
________07B2:   jre $0754                                       ;Restart puzzle
;------------------------------------------------------------
________07B4:   #d8 $75, $8A, $80                               ; EQIW    8A,80
________07B7:   jre $0793
________07B9:   #d8 $28, $92                                    ; LDAW    92          ;Joypad
________07BB:   #d8 $47, $0F                                    ; ONI     A,0F
________07BD:   jre $078F                                       ;Keep looping
________07BF:   calf $0DD3                                      ;Draw Tiles
________07C1:   jr $07C6
;------------------------------------------------------------
________07C2:   calt $0084                                      ;[PC+2] Setup/Play Sound
________07C3:   #d8 $01, $03                                    ; DB $01,$03
________07C5:   jr $07BD
;------------------------------------------------------------
________07C6:   push va
________07C8:   #d8 $69, $03                                    ; MVI     A,03
________07CA:   #d8 $38, $99                                    ; STAW    99
________07CC:   di  
________07CE:   calf $08B6                                      ;Play Music (Snd)
________07D0:   ei
________07D2:   #d8 $34, $FE, $C7                               ; LXI     H,C7FE
________07D5:   ldax [hl+]
________07D6:   mov b, a
________07D7:   ldax [hl-]
________07D8:   lta a, b
________07DA:   jr $07DD
________07DB:   mov b, a
________07DC:   ldax [hl]
________07DD:   push bc
________07DF:   #d8 $75, $A2, $00                               ; EQIW    A2,00
________07E2:   jre $0823
________07E4:   calf $0CBF                                      ;Write Text(?)
________07E6:   inx hl
________07E7:   calt $00B2                                      ; "[PC+2] Draw Horizontal Line"
________07E8:   #d8 $00, $8E                                    ; DB $00,$8E
________07EA:   calf $0C77                                      ;HL + $3C
________07EC:   push hl
________07EE:   calt $00B2                                      ; "[PC+2] Draw Horizontal Line"
________07EF:   #d8 $F0, $0E                                    ; DB $F0,$0E
________07F1:   pop hl
________07F3:   calt $00B2                                      ; "[PC+2] Draw Horizontal Line"
________07F4:   #d8 $F0, $8E                                    ; DB $F0,$8E
________07F6:   calf $0C77                                      ;HL + $3C
________07F8:   calt $00B2                                      ; "[PC+2] Draw Horizontal Line"
________07F9:   #d8 $1F, $0F                                    ; DB $1F,$0F
________07FB:   pop bc
________07FD:   mov a, b
________07FE:   calf $0CBF                                      ;Write Text(?)
________0800:   calt $00B2                                      ; "[PC+2] Draw Horizontal Line"
________0801:   #d8 $F0, $0F                                    ; DB $F0,$0F
________0803:   calf $0C77                                      ;HL + $3C
________0805:   push hl
________0807:   calt $00B2                                      ; "[PC+2] Draw Horizontal Line"
________0808:   #d8 $0F, $0E                                    ; DB $0F,$0E
________080A:   pop hl
________080C:   calt $00B2                                      ; "[PC+2] Draw Horizontal Line"
________080D:   #d8 $0F, $8E                                    ; DB $0F,$0E
________080F:   #d8 $6D, $41                                    ; MVI     E,41
________0811:   calt $009A                                      ; "HL <== HL+E"
________0812:   pop va
________0814:   push hl
________0816:   calt $00B8                                      ;Byte -> Point to Font Graphic
________0817:   pop de
________0819:   #d8 $6A, $04                                    ; MVI     B,04
________081B:   ldax [hl+]
________081C:   ral
________081E:   stax [de+]
________081F:   dcr b
________0820:   jr $081B
________0821:   jre $0875
;------------------------------------------------------------
________0823:   calf $0CBF                                      ;Write Text(?)
________0825:   #d8 $6A, $07                                    ; MVI     B,07
________0827:   inx hl
________0828:   dcr b
________0829:   jr $0827
________082A:   #d8 $69, $01                                    ; MVI     A,01
________082C:   #d8 $38, $A5                                    ; STAW    A5
________082E:   calt $00B2                                      ; "[PC+2] Draw Horizontal Line"
________082F:   #d8 $E0, $08                                    ; DB $E0,$08
________0831:   #d8 $6D, $42                                    ; MVI     E,42
________0833:   calt $009A                                      ; "HL <== HL+E"
________0834:   calt $00B2                                      ; "[PC+2] Draw Horizontal Line"
________0835:   #d8 $FF, $08                                    ; DB $FF,$08
________0837:   #d8 $6D, $42                                    ; MVI     E,42
________0839:   calt $009A                                      ; "HL <== HL+E"
________083A:   calt $00B2                                      ; "[PC+2] Draw Horizontal Line"
________083B:   #d8 $1F, $08                                    ; DB $1F,$08
________083D:   #d8 $28, $A5                                    ; LDAW    A5
________083F:   dcr a
________0840:   jr $0842
________0841:   jr $084C

________0842:   #d8 $38, $A5                                    ; STAW    A5
________0844:   pop bc
________0846:   mov a, b
________0847:   #d8 $38, $A2                                    ; STAW    A2
________0849:   calf $0CBF                                      ;Write Text(?)
________084B:   jr $082E

________084C:   #d8 $28, $A2                                    ; LDAW    A2
________084E:   calf $0CBF                                      ;Write Text(?)
________0850:   #d8 $6D, $09                                    ; MVI     E,09
________0852:   calt $009A                                      ; "HL <== HL+E"
________0853:   calt $00B2                                      ; "[PC+2] Draw Horizontal Line"
________0854:   #d8 $1F, $8E                                    ; DB $1F,$8E
________0856:   calf $0C77                                      ;HL + $3C
________0858:   calt $00B2                                      ; "[PC+2] Draw Horizontal Line"
________0859:   #d8 $00, $8E                                    ; DB $00,$8E
________085B:   calf $0C77                                      ;HL + $3C
________085D:   calt $00B2                                      ; "[PC+2] Draw Horizontal Line"
________085E:   #d8 $F0, $8E                                    ; DB $F0,$8E
________0860:   #d8 $6A, $54                                    ; MVI     B,54        ;Decrement HL 55 times!
________0862:   dcx hl                                          ;Is this a delay or something?
________0863:   dcr b                                           ;There's already a CALT that subs HL...
________0864:   jr $0862
________0865:   calt $00A8                                      ; "XCHG HL,DE"
________0866:   pop va
________0868:   push de
________086A:   calt $00B8                                      ;Byte -> Point to Font Graphic
________086B:   pop de
________086D:   #d8 $6A, $04                                    ; MVI     B,04
________086F:   ldax [hl+]
________0870:   ral 
________0872:   stax [de+]
________0873:   dcr b
________0874:   jr $086F
________0875:   #d8 $34, $88, $FF                               ; LXI     H,FF88
________0878:   calt $00B4                                      ; "[PC+3] Print Bytes on-Screen"
________0879:   #d8 $44, $00, $08                               ; DB $44,$00,$08
________087C:   calt $00A0                                      ; "C258+ ==> C000+"
________087D:   calt $0082                                      ;Copy Screen RAM to LCD Driver
________087E:   calf $0D68                                      ;Draw Border
________0880:   calf $0D92                                      ;Draw Puzzle Grid
________0882:   calf $0C82                                      ;Scroll text? Write time in decimal?
________0884:   #d8 $6A, $0B                                    ; MVI     B,0B
________0886:   #d8 $34, $5E, $C7                               ; LXI     H,C75E
________0889:   #d8 $24, $F2, $C7                               ; LXI     D,C7F2
________088C:   ldax [hl+]
________088D:   #d8 $70, $FC                                    ; EQAX    D+
________088F:   jre $07C5
________0891:   dcr b
________0892:   jr $088C
________0893:   calf $0E64                                      ;Point HL to music data
________0895:   calt $0086                                      ;Setup/Play Music
________0896:   #d8 $45, $80, $03                               ; ONIW    80,03
________0899:   jmp $0712                                       ;Continue puzzle
________089C:   jr $0896
;End of Puzzle Code
;------------------------------------------------------------
;Clear A
CALT_85_089D:   #d8 $69, $00                                    ; MVI     A,00
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
________08AC:   #d8 $38, $99                                    ; STAW    99
________08AE:   #d8 $70, $3E, $84, $FF                          ; SHLD    FF84
________08B2:   mov a, b
________08B3:   inr a
________08B4:   jr $08B6
________08B5:   rets                                            ;Return & Skip if read "$FF"

;Move "note" into TM0
CALF____08B6:   #d8 $34, $78, $02                               ; LXI     H,0278           ;Table Start
________08B9:   mov a, b
________08BA:   #d8 $36, $01                                    ; SUINB   A,01
________08BC:   jr $08C0
________08BD:   inx hl                                          ;Add A*2 to HL (wastefully)
________08BE:   inx hl
________08BF:   jr $08BA

________08C0:   ldax [hl+]
________08C1:   mov tm0, a
________08C3:   ldax [hl]
________08C4:   #d8 $38, $9A                                    ; STAW    9A
________08C6:   #d8 $38, $8F                                    ; STAW    8F
________08C8:   dcr b
________08C9:   #d8 $69, $00                                    ; MVI     A,00       ;Sound?
________08CB:   #d8 $69, $03                                    ; MVI     A,03       ;Silent
________08CD:   mov tmm, a
________08CF:   #d8 $15, $80, $01                               ; ORIW    80,01
________08D2:   stm
________08D3:   ret
;------------------------------------------------------------
;Load a "multiplication table" for A,E from (HL) and do AxE
;Is this ever used?
________08D4:   ldax [hl+]
________08D5:   mov e, a
________08D6:   ldax [hl]
;HL <== AxE
CALT_93_08D7:   #d8 $34, $00, $00                               ; LXI     H,0000
________08DA:   #d8 $6C, $00                                    ; MVI     D,00
________08DC:   #d8 $27, $00                                    ; GTI     A,00
________08DE:   ret
________08DF:   clc
________08E1:   #d8 $48, $31                                    ; RLR
________08E3:   push va
________08E5:   #d8 $48, $1A                                    ; SKN     CY
________08E7:   calt $0096                                      ; "HL <== HL+DE"
________08E8:   mov a, e
________08E9:   add a, a
________08EB:   mov e, a
________08EC:   mov a, d
________08ED:   ral
________08EF:   mov d, a
________08F0:   pop va
________08F2:   jr $08DC
;-----------------------------
;((HL+) <==> (DE+))xB
;This function swaps the contents of (HL)<->(DE) B times
CALT_97_08F3:   calf $08F8                                      ;Swap (HL+)<->(DE+)
________08F5:   dcr b
________08F6:   jr $08F3
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
CALT_86_08FF:   #d8 $34, $58, $C2                               ; LXI     H,C258	;RAM for screen 2
;Clear Screen RAM
CALT_87_0902:   #d8 $34, $00, $C0                               ; LXI     H,C000	;RAM for screen 1
________0905:   #d8 $6B, $02                                    ; MVI     C,02
________0907:   #d8 $6A, $C7                                    ; MVI     B,C7        ;$C8 bytes * 3 loops
________0909:   calt $0094                                      ; "Clear RAM (HL+)xB"
________090A:   dcr c
________090B:   jr $0907
________090C:   ret
;------------------------------------------------------------
;Clear C594~C7FF
CALT_89_090D:   #d8 $34, $94, $C5                               ; LXI     H,C594	;Set HL
________0910:   calf $0905                                      ;And jump to above routine
________0912:   #d8 $6A, $13                                    ; MVI     B,13        ;Then clear $14 more bytes
________0914:   jr $091A                                        ;Clear RAM (HL+)xB

;Clear C4B0~C593
CALT_88_0915:   #d8 $34, $B0, $C4                               ; LXI     H,C4B0      ;Set RAM pointer
________0918:   #d8 $6A, $E3                                    ; MVI     B,E3	;and just drop into the func.

;Clear RAM (HL+)xB
CALT_8A_091A:   calt $008A                                      ; "Clear A"
;A ==> (HL+)xB
CALT_9F_091B:   stax [hl+]
________091C:   dcr b
________091D:   jr $091B
________091E:   ret
;------------------------------------------------------------
;Read Controller FF90-FF95
CALT_84_091F:   #d8 $34, $92, $FF                               ; LXI     H,FF92      ;Current joy storage
________0922:   #d8 $24, $90, $FF                               ; LXI     D,FF90      ;Old joy storage
________0925:   #d8 $6A, $01                                    ; MVI     B,01        ;Copy 2 bytes from curr->old
________0927:   calt $00AA                                      ; "((HL+) ==> (DE+))xB"
________0928:   #d8 $64, $88, $BF                               ; ANI     PA,BF       ;PA Bit 6 off
________092B:   mov a, pc                                       ;Get port C
________092D:   #d8 $16, $FF                                    ; XRI     A,FF
________092F:   mov c, a
________0930:   #d8 $6A, $40                                    ; MVI     B,40	;Debouncing delay
________0932:   dcr b
________0933:   jr $0932
________0934:   mov a, pc                                       ;Get port C a 2nd time
________0936:   #d8 $16, $FF                                    ; XRI     A,FF
________0938:   eqa a, c                                        ;Check if both reads are equal
________093A:   jr $092F
________093B:   #d8 $64, $98, $40                               ; ORI     PA,40	;PA Bit 6 on
________093E:   #d8 $07, $03                                    ; ANI     A,03
________0940:   stax [de+]                                      ;Save controller read in 92
________0941:   mov a, c
________0942:   calf $0C72                                      ;RLR A x2
________0944:   #d8 $07, $07                                    ; ANI     A,07
________0946:   stax [de-]                                      ;Save cont in 93
________0947:   #d8 $64, $88, $7F                               ; ANI     PA,7F	;PA bit 7 off
________094A:   mov a, pc                                       ;Get other controller bits
________094C:   #d8 $16, $FF                                    ; XRI     A,FF
________094E:   mov c, a
________094F:   #d8 $6A, $40                                    ; MVI     B,40	;...and debounce
________0951:   dcr b
________0952:   jr $0951
________0953:   mov a, pc
________0955:   #d8 $16, $FF                                    ; XRI     A,FF
________0957:   eqa a, c                                        ;...check again
________0959:   jr $094E
________095A:   #d8 $64, $98, $80                               ; ORI     PA,80       ;PA bit 7 on
________095D:   ral
________095F:   ral
________0961:   #d8 $07, $0C                                    ; ANI     A,0C
________0963:   #d8 $70, $9A                                    ; ORAX    D		;Or with FF92
________0965:   stax [de+]                                      ;...and save
________0966:   mov a, c
________0967:   ral 
________0969:   #d8 $07, $38                                    ; ANI     A,38
________096B:   #d8 $70, $9A                                    ; ORAX    D           ;Or with FF93
________096D:   stax [de-]                                      ;...and save
________096E:   #d8 $34, $90, $FF                               ; LXI     H,FF90      ;Get our new,old
________0971:   #d8 $14, $94, $FF                               ; LXI     B,FF94
________0974:   ldax [hl+]                                      ;And XOR to get controller strobe
________0975:   #d8 $70, $94                                    ; XRAX    D+		;But this strobe function is stupid:
________0977:   stax [bc]                                       ;Bits go to 1 whenever the button is
________0978:   inx bc                                          ;initially pressed AND released...
________0979:   ldax [hl]
________097A:   #d8 $70, $92                                    ; XRAX    D
________097C:   stax [bc]
________097D:   ret
;------------------------------------------------------------
;C258+ ==> C000+
CALT_90_097E:   calf $0E5E
________0980:   jr $0984
;C000+ ==> C258+
CALT_8F_0981:   calf $0E5E
________0983:   calt $00A8                                      ; "XCHG HL,DE"
________0984:   #d8 $6B, $02                                    ; MVI     C,02
________0986:   #d8 $6A, $C7                                    ; MVI     B,C7
________0988:   calt $00AA                                      ; "((HL+) ==> (DE+))xB"
________0989:   dcr c
________098A:   jr $0986
________098B:   ret
;------------------------------------------------------------
;Swap C258+ <==> C000+
CALT_8E_098C:   calf $0E5E
________098E:   #d8 $14, $02, $C7                               ; LXI     B,C702
________0991:   push bc
________0993:   calt $00AE                                      ; "((HL+) <==> (DE+))xB"
________0994:   pop bc
________0996:   dcr c
________0997:   jr $0991
________0998:   ret
;------------------------------------------------------------
;Set Dot; B,C = X-,Y-position
;(Oddly enough, this writes dots to the 2nd screen RAM area!)
CALT_98_0999:   push bc
________099B:   calf $0BF4                                      ;Point to 2nd screen
________099D:   pop bc
________099F:   mov a, c
________09A0:   #d8 $07, $07                                    ; ANI     A,07
________09A2:   mov c, a
________09A3:   calt $008A                                      ; "Clear A"
________09A4:   stc
________09A6:   ral
________09A8:   dcr c
________09A9:   jr $09A6
________09AA:   #d8 $70, $9B                                    ; ORAX    H
________09AC:   jr $09C5
;------------------------------------------------------------
CALF____09AD:   #d8 $75, $D8, $00                               ; EQIW    D8,00       ;"Invert Dot", then...
________09B0:   jr $0999

;Clear Dot; B,C = X-,Y-position
CALT_AD_09B1:   push bc
________09B3:   calf $0BF4                                      ;Point to 2nd screen
________09B5:   pop bc
________09B7:   mov a, c
________09B8:   #d8 $07, $07                                    ; ANI     A,07
________09BA:   mov c, a
________09BB:   #d8 $69, $FF                                    ; MVI     A,FF
________09BD:   clc
________09BF:   ral
________09C1:   dcr c
________09C2:   jr $09BF
________09C3:   #d8 $70, $8B                                    ; ANAX    H
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
________09CF:   #d8 $07, $7F                                    ; ANI     A,7F
________09D1:   mov b, a
________09D2:   mov a, d
________09D3:   #d8 $47, $80                                    ; ONI     A,80
________09D5:   jr $09DD

________09D6:   ldax [hl]
________09D7:   ana a, c
________09D9:   stax [hl+]
________09DA:   dcr b
________09DB:   jr $09D6
________09DC:   ret

________09DD:   ldax [hl]
________09DE:   ora a, c
________09E0:   stax [hl+]
________09E1:   dcr b
________09E2:   jr $09DD
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
________09E8:   #d8 $38, $9B                                    ; STAW    9B
________09EA:   ldax [de+]
________09EB:   mov c, a
________09EC:   #d8 $07, $07                                    ; ANI     A,07
________09EE:   #d8 $38, $9C                                    ; STAW    9C
________09F0:   ldax [de+]
________09F1:   push de
________09F3:   #d8 $38, $9D                                    ; STAW    9D
________09F5:   #d8 $07, $07                                    ; ANI     A,07
________09F7:   inr a
________09F8:   push bc
________09FA:   #d8 $38, $98                                    ; STAW    98
________09FC:   #d8 $24, $A8, $FF                               ; LXI     D,FFA8
________09FF:   #d8 $70, $2E, $C0, $FF                          ; SDED    FFC0
________0A03:   mov b, a
________0A04:   #d8 $6B, $40                                    ; MVI     C,40
________0A06:   #d8 $45, $9D, $40                               ; ONIW    9D,40
________0A09:   #d8 $6B, $10                                    ; MVI     C,10
________0A0B:   #d8 $45, $9D, $08                               ; ONIW    9D,08
________0A0E:   jr $0A19
________0A0F:   dcr b
________0A10:   jr $0A12
________0A11:   jr $0A23

________0A12:   ldax [hl]
________0A13:   calt $00C0                                      ; "(RLR A)x4"
________0A14:   #d8 $07, $0F                                    ; ANI     A,0F
________0A16:   ora a, c
________0A18:   stax [de+]
________0A19:   dcr b
________0A1A:   jr $0A1C
________0A1B:   jr $0A23

________0A1C:   ldax [hl+]
________0A1D:   #d8 $07, $0F                                    ; ANI     A,0F
________0A1F:   ora a, c
________0A21:   stax [de+]
________0A22:   jr $0A0F

________0A23:   pop bc
________0A25:   #d8 $05, $9D, $BF                               ; ANIW    9D,BF
________0A28:   jr $0A42
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
________0A2D:   #d8 $38, $9B                                    ; STAW    9B
________0A2F:   ldax [de+]
________0A30:   mov c, a                                        ;Save X,Y position in BC
________0A31:   #d8 $07, $07                                    ; ANI     A,07
________0A33:   #d8 $38, $9C                                    ; STAW    9C
________0A35:   ldax [de+]
________0A36:   push de
________0A38:   #d8 $38, $9D                                    ; STAW    9D
________0A3A:   #d8 $07, $0F                                    ; ANI     A,0F        ;Get # of characters to write
________0A3C:   #d8 $70, $3E, $C0, $FF                          ; SHLD    FFC0
________0A40:   #d8 $38, $98                                    ; STAW    98  	;# saved in 98
________0A42:   #d8 $28, $9D                                    ; LDAW    9D
________0A44:   #d8 $47, $80                                    ; ONI     A,80	;Check if 0 (2nd screen) or 1 (1st screen)
________0A46:   jr $0A49
________0A47:   calt $00BA                                      ; "Set HL to screen (B,C)"
________0A48:   jr $0A4B

________0A49:   calf $0BF4                                      ;This points to Sc 1
________0A4B:   mov [$FFC6], c
________0A4F:   #d8 $70, $3E, $C2, $FF                          ; SHLD    FFC2
________0A53:   #d8 $24, $4B, $00                               ; LXI     D,004B
________0A56:   calt $0096                                      ; "HL <== HL+DE"
________0A57:   #d8 $70, $3E, $C4, $FF                          ; SHLD    FFC4
________0A5B:   #d8 $28, $9D                                    ; LDAW    9D
________0A5D:   calt $00C0                                      ; "(RLR A)x4"
________0A5E:   #d8 $07, $07                                    ; ANI     A,07	;Get text spacing (0-7)
________0A60:   #d8 $38, $9D                                    ; STAW    9D		;Save in 9D
;--
________0A62:   #d8 $30, $98                                    ; DCRW    98		;The loop starts here
________0A64:   jr $0A66
________0A65:   ret

________0A66:   #d8 $45, $C6, $FF                               ; ONIW    C6,FF
________0A69:   jr $0A85
________0A6A:   #d8 $70, $3F, $C2, $FF                          ; LHLD    FFC2
________0A6E:   #d8 $70, $3E, $C7, $FF                          ; SHLD    FFC7
________0A72:   #d8 $24, $B0, $FF                               ; LXI     D,FFB0
________0A75:   #d8 $6A, $04                                    ; MVI     B,04
________0A77:   calf $0BD3
________0A79:   #d8 $57, $80                                    ; OFFI    A,80
________0A7B:   jr $0A85
________0A7C:   #d8 $70, $2F, $9D, $FF                          ; LDED    FF9D
________0A80:   calt $009A                                      ; "HL <== HL+E"
________0A81:   #d8 $70, $3E, $C2, $FF                          ; SHLD    FFC2
________0A85:   #d8 $70, $3F, $C4, $FF                          ; LHLD    FFC4
________0A89:   #d8 $70, $3E, $C9, $FF                          ; SHLD    FFC9
________0A8D:   #d8 $24, $B5, $FF                               ; LXI     D,FFB5
________0A90:   #d8 $6A, $04                                    ; MVI     B,04
________0A92:   calf $0BD3                                      ;Copy B*A bytes?
________0A94:   #d8 $57, $80                                    ; OFFI    A,80
________0A96:   jr $0AA0
________0A97:   #d8 $70, $2F, $9D, $FF                          ; LDED    FF9D
________0A9B:   calt $009A                                      ; "HL <== HL+E"
________0A9C:   #d8 $70, $3E, $C4, $FF                          ; SHLD    FFC4
________0AA0:   mov b, [$FF9C]
________0AA4:   calt $008A                                      ; "Clear A"
________0AA5:   dcr b
________0AA6:   jr $0AA8
________0AA7:   jr $0AAD

________0AA8:   stc
________0AAA:   ral
________0AAC:   jr $0AA5

________0AAD:   push va
________0AAF:   mov c, a
________0AB0:   calf $0E6A                                      ;(FFB0 -> HL)
________0AB2:   #d8 $6A, $04                                    ; MVI     B,04
________0AB4:   ldax [hl]
________0AB5:   ana a, c
________0AB7:   stax [hl+]
________0AB8:   dcr b
________0AB9:   jr $0AB4
________0ABA:   pop va
________0ABC:   #d8 $16, $FF                                    ; XRI     A,FF
________0ABE:   mov c, a
________0ABF:   #d8 $6A, $04                                    ; MVI     B,04
________0AC1:   ldax [hl]
________0AC2:   ana a, c
________0AC4:   stax [hl+]
________0AC5:   dcr b
________0AC6:   jr $0AC1
________0AC7:   #d8 $70, $3F, $C0, $FF                          ; LHLD    FFC0
________0ACB:   ldax [hl+]
________0ACC:   #d8 $70, $3E, $C0, $FF                          ; SHLD    FFC0
________0AD0:   calt $00B8                                      ;Byte -> Point to Font Graphic
________0AD1:   #d8 $24, $B0, $FF                               ; LXI     D,FFB0
________0AD4:   #d8 $14, $B5, $FF                               ; LXI     B,FFB5
________0AD7:   #d8 $69, $04                                    ; MVI     A,04
________0AD9:   #d8 $15, $80, $08                               ; ORIW    80,08
________0ADC:   calf $0C31                                      ;Roll graphics a bit (shift up/dn)
________0ADE:   #d8 $45, $C6, $FF                               ; ONIW    C6,FF
________0AE1:   jr $0AEF
________0AE2:   #d8 $70, $2F, $C7, $FF                          ; LDED    FFC7
________0AE6:   calf $0E6A                                      ;(FFB0 -> HL)
________0AE8:   #d8 $6A, $04                                    ; MVI     B,04
________0AEA:   #d8 $15, $80, $10                               ; ORIW    80,10
________0AED:   calf $0BD3                                      ;Copy B*A bytes?
________0AEF:   #d8 $55, $C6, $08                               ; OFFIW   C6,08
________0AF2:   jr $0B01
________0AF3:   #d8 $70, $2F, $C9, $FF                          ; LDED    FFC9
________0AF7:   #d8 $34, $B5, $FF                               ; LXI     H,FFB5
________0AFA:   #d8 $6A, $04                                    ; MVI     B,04
________0AFC:   #d8 $15, $80, $10                               ; ORIW    80,10
________0AFF:   calf $0BD3                                      ;Copy B*A bytes?
________0B01:   #d8 $28, $9B                                    ; LDAW    9B
________0B03:   #d8 $46, $05                                    ; ADI     A,05
________0B05:   mov b, a
________0B06:   #d8 $28, $9D                                    ; LDAW    9D
________0B08:   add a, b
________0B0A:   #d8 $38, $9B                                    ; STAW    9B
________0B0C:   jre $0A62
;------------------------------------------------------------
;Byte -> Point to Font Graphic
CALT_9C_0B0E:   #d8 $37, $64                                    ; LTI     A,64	;If it's greater than 64, use cart font
________0B10:   jr $0B15                                        ;or...
________0B11:   #d8 $24, $C4, $02                               ; LXI     D,02C4      ;Point to built-in font
________0B14:   jr $0B1B

________0B15:   #d8 $70, $2F, $05, $40                          ; LDED    4005       ;4005-6 on cart is the font pointer
________0B19:   #d8 $66, $64                                    ; SUI     A,64
________0B1B:   #d8 $70, $2E, $96, $FF                          ; SDED    FF96
________0B1F:   mov c, a
________0B20:   #d8 $07, $0F                                    ; ANI     A,0F
________0B22:   #d8 $6D, $05                                    ; MVI     E,05
________0B24:   calt $00A6                                      ; "Add A to "Pointer""
________0B25:   push hl
________0B27:   mov a, c
________0B28:   calt $00C0                                      ; "(RLR A)x4"
________0B29:   #d8 $07, $0F                                    ; ANI     A,0F
________0B2B:   #d8 $6D, $50                                    ; MVI     E,50
________0B2D:   calt $00A6                                      ; "Add A to "Pointer""
________0B2E:   pop de
________0B30:   calt $0096                                      ; "HL <== HL+DE"
________0B31:   #d8 $70, $2F, $96, $FF                          ; LDED    FF96
________0B35:   calt $0096                                      ; "HL <== HL+DE"
________0B36:   ret
;------------------------------------------------------------
;?? (Move some RAM around...)
CALT_92_0B37:   #d8 $34, $91, $C5                               ; LXI     H,C591
________0B3A:   #d8 $6A, $0B                                    ; MVI     B,0B

________0B3C:   push hl
________0B3E:   push bc
________0B40:   calf $0B4C
________0B42:   pop bc
________0B44:   pop hl
________0B46:   dcx hl
________0B47:   dcx hl
________0B48:   dcx hl
________0B49:   dcr b
________0B4A:   jr $0B3C
________0B4B:   ret
;------------------------------------------------------------
CALF____0B4C:   ldax [hl+]
________0B4D:   #d8 $38, $9B                                    ; STAW    9B
________0B4F:   mov b, a
________0B50:   #d8 $46, $07                                    ; ADI     A,07
________0B52:   #d8 $37, $53                                    ; LTI     A,53
________0B54:   ret
________0B55:   ldax [hl+]
________0B56:   mov c, a
________0B57:   #d8 $07, $07                                    ; ANI     A,07
________0B59:   #d8 $38, $9C                                    ; STAW    9C
________0B5B:   mov a, c
________0B5C:   #d8 $46, $07                                    ; ADI     A,07
________0B5E:   #d8 $37, $47                                    ; LTI     A,47
________0B60:   ret
________0B61:   ldax [hl]
________0B62:   #d8 $38, $9D                                    ; STAW    9D
________0B64:   #d8 $37, $0C                                    ; LTI     A,0C
________0B66:   ret
________0B67:   calt $00BA                                      ; "Set HL to screen (B,C)"
________0B68:   #d8 $70, $3E, $9E, $FF                          ; SHLD    FF9E
________0B6C:   mov a, h
________0B6D:   #d8 $47, $40                                    ; ONI     A,40
________0B6F:   jr $0B75
________0B70:   #d8 $24, $B0, $FF                               ; LXI     D,FFB0
________0B73:   calf $0BD1
________0B75:   #d8 $70, $3F, $9E, $FF                          ; LHLD    FF9E
________0B79:   #d8 $24, $4B, $00                               ; LXI     D,004B
________0B7C:   calt $0096                                      ; "HL <== HL+DE"
________0B7D:   push hl
________0B7F:   #d8 $24, $B8, $FF                               ; LXI     D,FFB8
________0B82:   calf $0BD1
________0B84:   calf $0E6A
________0B86:   #d8 $24, $C0, $FF                               ; LXI     D,FFC0
________0B89:   #d8 $6A, $0F                                    ; MVI     B,0F
________0B8B:   calt $00AA                                      ; "((HL+) ==> (DE+))xB"
________0B8C:   #d8 $28, $9D                                    ; LDAW    9D
________0B8E:   calt $00BC                                      ; "HL=C4B0+(A*$10)"
________0B8F:   #d8 $24, $B0, $FF                               ; LXI     D,FFB0
________0B92:   #d8 $14, $B8, $FF                               ; LXI     B,FFB8
________0B95:   calf $0C2F
________0B97:   push hl
________0B99:   calf $0E6A
________0B9B:   #d8 $24, $C0, $FF                               ; LXI     D,FFC0
________0B9E:   #d8 $6A, $0F                                    ; MVI     B,0F
________0BA0:   ldax [hl]
________0BA1:   #d8 $70, $94                                    ; XRAX    D+
________0BA3:   stax [hl+]
________0BA4:   dcr b
________0BA5:   jr $0BA0
________0BA6:   pop hl
________0BA8:   #d8 $15, $80, $08                               ; ORIW    80,08
________0BAB:   #d8 $24, $B0, $FF                               ; LXI     D,FFB0
________0BAE:   #d8 $14, $B8, $FF                               ; LXI     B,FFB8
________0BB1:   calf $0C2F
________0BB3:   #d8 $70, $2F, $9E, $FF                          ; LDED    FF9E
________0BB7:   mov a, d
________0BB8:   #d8 $47, $40                                    ; ONI     A,40
________0BBA:   jr $0BC2
________0BBB:   calf $0E6A
________0BBD:   #d8 $15, $80, $10                               ; ORIW    80,10
________0BC0:   calf $0BD1
________0BC2:   pop de
________0BC4:   #d8 $34, $A8, $3D                               ; LXI     H,3DA8
________0BC7:   calt $0096                                      ; "HL <== HL+DE"
________0BC8:   #d8 $48, $1A                                    ; SKN     CY
________0BCA:   ret
________0BCB:   #d8 $34, $B8, $FF                               ; LXI     H,FFB8
________0BCE:   #d8 $15, $80, $10                               ; ORIW    80,10
;--
________0BD1:   #d8 $6A, $07                                    ; MVI     B,07
________0BD3:   #d8 $28, $9B                                    ; LDAW    9B
________0BD5:   #d8 $57, $80                                    ; OFFI    A,80
________0BD7:   jr $0BE2
________0BD8:   #d8 $37, $4B                                    ; LTI     A,4B
________0BDA:   jr $0BED
________0BDB:   push va
________0BDD:   ldax [hl+]
________0BDE:   stax [de+]
________0BDF:   pop va
________0BE1:   jr $0BE9
________0BE2:   #d8 $45, $80, $10                               ; ONIW    80,10
________0BE5:   jr $0BE8
________0BE6:   inx hl
________0BE7:   jr $0BE9

________0BE8:   inx de
________0BE9:   inr a
________0BEA:   nop
________0BEB:   dcr b
________0BEC:   jr $0BD5
________0BED:   #d8 $05, $80, $EF                               ; ANIW    80,EF
________0BF0:   ret
;------------------------------------------------------------
;Set HL to screen (B,C)
CALT_9D_0BF1:   #d8 $34, $B5, $BF                               ; LXI     H,BFB5	;Point before Sc. RAM
________0BF4:   #d8 $34, $0D, $C2                               ; LXI     H,C20D	;Point before Sc.2 RAM
________0BF7:   #d8 $6D, $4B                                    ; MVI     E,4B
________0BF9:   mov a, c
________0BFA:   #d8 $6B, $00                                    ; MVI     C,00
________0BFC:   #d8 $46, $08                                    ; ADI     A,08
________0BFE:   #d8 $36, $08                                    ; SUINB   A,08
________0C00:   jr $0C08
________0C01:   push va
________0C03:   calt $009A                                      ; "HL <== HL+E"
________0C04:   pop va
________0C06:   inr c
________0C07:   jr $0BFE
________0C08:   mov a, b
________0C09:   #d8 $57, $80                                    ; OFFI    A,80
________0C0B:   ret
________0C0C:   mov e, a
________0C0D:   jr $0C18
;------------------------------------------------------------
;[PC+1] HL +- byte
CALT_8C_0C0E:   pop de
________0C10:   ldax [de+]                                      ;Get byte after PC
________0C11:   push de
________0C13:   mov e, a
________0C14:   #d8 $37, $80                                    ; LTI     A,80	;Add or subtract that byte
________0C16:   #d8 $69, $FF                                    ; MVI     A,FF
;HL <== HL+E
CALT_8D_0C18:   #d8 $69, $00                                    ; MVI     A,00
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
CALT_9E_0C24:   #d8 $34, $B0, $C4                               ; LXI     H,C4B0
________0C27:   #d8 $6D, $10                                    ; MVI     E,10
________0C29:   mov b, a
________0C2A:   dcr b
________0C2B:   jr $0C2D
________0C2C:   ret

________0C2D:   calt $009A                                      ; "HL <== HL+E"
________0C2E:   jr $0C2A
;------------------------------------------------------------
CALF____0C2F:   #d8 $69, $07                                    ; MVI     A,07
________0C31:   #d8 $38, $96                                    ; STAW    96

________0C33:   #d8 $28, $9C                                    ; LDAW    9C
________0C35:   #d8 $38, $97                                    ; STAW    97
________0C37:   push bc
________0C39:   #d8 $6B, $00                                    ; MVI     C,00
________0C3B:   ldax [hl+]
________0C3C:   #d8 $30, $97                                    ; DCRW    97
________0C3E:   jr $0C40
________0C3F:   jr $0C4D

________0C40:   clc
________0C42:   ral
________0C44:   push va
________0C46:   mov a, c
________0C47:   ral
________0C49:   mov c, a
________0C4A:   pop va
________0C4C:   jr $0C3C

________0C4D:   #d8 $45, $80, $08                               ; ONIW    80,08
________0C50:   jr $0C54
________0C51:   #d8 $70, $9A                                    ; ORAX    D
________0C53:   jr $0C56

________0C54:   #d8 $70, $8A                                    ; ANAX    D
________0C56:   stax [de]
________0C57:   mov a, c
________0C58:   pop bc
________0C5A:   #d8 $45, $80, $08                               ; ONIW    80,08
________0C5D:   jr $0C61
________0C5E:   #d8 $70, $99                                    ; ORAX    B
________0C60:   jr $0C63

________0C61:   #d8 $70, $89                                    ; ANAX    B
________0C63:   stax [bc]
________0C64:   inx bc
________0C65:   inx de
________0C66:   #d8 $30, $96                                    ; DCRW    96
________0C68:   jre $0C33
________0C6A:   #d8 $05, $80, $F7                               ; ANIW    80,F7
________0C6D:   ret
;------------------------------------------------------------
;(RLR A)x4	(Divides A by 16)
CALT_A0_0C6E:   #d8 $48, $31                                    ; RLR
________0C70:   #d8 $48, $31                                    ; RLR
CALF____0C72:   #d8 $48, $31                                    ; RLR
________0C74:   #d8 $48, $31                                    ; RLR
________0C76:   ret
;------------------------------------------------------------
CALF____0C77:   #d8 $6D, $3C                                    ; MVI     E,3C	; 60 decimal...
________0C79:   calt $009A                                      ; "HL <== HL+E"
________0C7A:   ret
;------------------------------------------------------------
CALF____0C7B:   #d8 $34, $4D, $05                               ; LXI     H,054D      ;"PUZZLE"
________0C7E:   calt $00B6                                      ; "[PC+3] Print Text on-Screen"
________0C7F:   #d8 $03, $00, $16                               ; DB $03,$00,$16
________0C82:   calf $0E67                                      ;(C7F2 -> HL)
________0C84:   #d8 $69, $01                                    ; MVI     A,01
________0C86:   #d8 $38, $83                                    ; STAW    83
________0C88:   ldax [hl+]
________0C89:   push hl
________0C8B:   #d8 $67, $FF                                    ; NEI     A,FF	;If it's a terminator, loop
________0C8D:   jre $0CB6
________0C8F:   calt $00B8                                      ;Byte -> Point to Font Graphic
________0C90:   calt $00A8                                      ; "XCHG HL,DE"
________0C91:   #d8 $28, $83                                    ; LDAW    83
________0C93:   calf $0CBF                                      ;(Scroll text)
________0C95:   push de
________0C97:   #d8 $6D, $51                                    ; MVI     E,51
________0C99:   calt $009A                                      ; "HL <== HL+E"
________0C9A:   pop de
________0C9C:   #d8 $6A, $04                                    ; MVI     B,04
________0C9E:   ldax [de+]
________0C9F:   ral
________0CA1:   stax [hl+]
________0CA2:   dcr b
________0CA3:   jr $0C9E
________0CA4:   #d8 $20, $83                                    ; INRW    83
________0CA6:   pop hl
________0CA8:   #d8 $75, $83, $0D                               ; EQIW    83,0D
________0CAB:   jre $0C88
________0CAD:   #d8 $34, $FF, $C7                               ; LXI     H,C7FF
________0CB0:   ldax [hl]
________0CB1:   calf $0E3B                                      ;Scroll text; XOR RAM
________0CB3:   calt $00A0                                      ; "C258+ ==> C000+"
________0CB4:   calt $0082                                      ;Copy Screen RAM to LCD Driver
________0CB5:   ret
;------------------------------------------------------------
________0CB6:   mov a, [$FF83]                                  ;A "LDAW 83" would've been faster here...
________0CBA:   mov [$C7FF], a
________0CBE:   jr $0CA4
;------------------------------------------------------------
CALF____0CBF:   #d8 $37, $09                                    ; LTI     A,09
________0CC1:   jr $0CD2
________0CC2:   #d8 $37, $05                                    ; LTI     A,05
________0CC4:   jr $0CD8
________0CC5:   #d8 $34, $D8, $C2                               ; LXI     H,C2D8
________0CC8:   #d8 $67, $04                                    ; NEI     A,04
________0CCA:   ret
________0CCB:   #d8 $6A, $0F                                    ; MVI     B,0F
________0CCD:   dcx hl
________0CCE:   dcr b
________0CCF:   jr $0CCD
________0CD0:   inr a
________0CD1:   jr $0CC8
________0CD2:   #d8 $34, $04, $C4                               ; LXI     H,C404
________0CD5:   #d8 $66, $08                                    ; SUI     A,08
________0CD7:   jr $0CC8
;------------------------------------------------------------
________0CD8:   #d8 $34, $6E, $C3                               ; LXI     H,C36E
________0CDB:   #d8 $66, $04                                    ; SUI     A,04
________0CDD:   jr $0CC8
;------------------------------------------------------------
________0CDE:   #d8 $34, $B8, $04                               ; LXI     H,04B8	;Point to scroll text
________0CE1:   jr $0CFA
;------------------------------------------------------------
    	;Slide the top line for the scroller.
CALF____0CE2:   #d8 $20, $82                                    ; INRW    82
________0CE4:   nop
________0CE5:   #d8 $34, $5B, $C2                               ; LXI     H,C25B
________0CE8:   #d8 $24, $58, $C2                               ; LXI     D,C258
________0CEB:   #d8 $6A, $47                                    ; MVI     B,47
________0CED:   calt $00AA                                      ; "((HL+) ==> (DE+))xB"
________0CEE:   #d8 $55, $82, $01                               ; OFFIW   82,01
________0CF1:   jr $0CF6
________0CF2:   #d8 $34, $A3, $FF                               ; LXI     H,FFA3
________0CF5:   jr $0D0C

________0CF6:   #d8 $70, $3F, $D6, $FF                          ; LHLD    FFD6
________0CFA:   ldax [hl+]
________0CFB:   #d8 $67, $FF                                    ; NEI     A,FF	;If terminator...
________0CFD:   jr $0CDE                                        ;...reset scroll
________0CFE:   #d8 $70, $3E, $D6, $FF                          ; SHLD    FFD6
________0D02:   calt $00B8                                      ;Byte -> Point to Font Graphic
________0D03:   #d8 $6A, $04                                    ; MVI     B,04	;(5 pixels wide)
________0D05:   #d8 $24, $A0, $FF                               ; LXI     D,FFA0
________0D08:   calt $00AA                                      ; "((HL+) ==> (DE+))xB"
________0D09:   #d8 $34, $A0, $FF                               ; LXI     H,FFA0      ;First copy it to RAM...

________0D0C:   #d8 $24, $A0, $C2                               ; LXI     D,C2A0	;Then put it on screen, 3 pixels at a time.
________0D0F:   #d8 $6A, $02                                    ; MVI     B,02

;((HL+) ==> (DE+))xB
CALT_95_0D11:   ldax [hl+]
________0D12:   stax [de+]
________0D13:   dcr b
________0D14:   jr $0D11
________0D15:   ret
;------------------------------------------------------------
________0D16:   #d8 $20, $DA                                    ; INRW    DA
________0D18:   #d8 $34, $DA, $FF                               ; LXI     H,FFDA
________0D1B:   ldax [hl]
________0D1C:   #d8 $38, $D0                                    ; STAW    D0
________0D1E:   jr $0D23

;Draw a spiral dot-by-dot
CALF____0D1F:   #d8 $65, $D0, $FF                               ; NEIW    D0,FF
________0D22:   jr $0D16
________0D23:   #d8 $28, $D1                                    ; LDAW    D1		;This stores the direction
________0D25:   #d8 $67, $00                                    ; NEI     A,00	;that the spiral draws in...
________0D27:   jr $0D46
________0D28:   #d8 $70, $1F, $D2, $FF                          ; LBCD    FFD2
________0D2C:   #d8 $67, $01                                    ; NEI     A,01
________0D2E:   jre $0D52
________0D30:   #d8 $67, $02                                    ; NEI     A,02
________0D32:   jre $0D57
________0D34:   #d8 $67, $03                                    ; NEI     A,03
________0D36:   jre $0D5C

________0D38:   dcr b
________0D39:   mov a, b
________0D3A:   #d8 $38, $D3                                    ; STAW    D3
________0D3C:   calf $09AD                                      ;Draw a dot on-screen
________0D3E:   #d8 $30, $D0                                    ; DCRW    D0		;Decrement length counter...
________0D40:   ret
________0D41:   #d8 $69, $01                                    ; MVI     A,01	;If zero, turn corners
________0D43:   #d8 $38, $D1                                    ; STAW    D1
________0D45:   ret
;------------------------------------------------------------
________0D46:   #d8 $14, $24, $25                               ; LXI     B,2524
________0D49:   #d8 $70, $1E, $D2, $FF                          ; SBCD    FFD2
________0D4D:   calf $09AD
________0D4F:   #d8 $20, $D1                                    ; INRW    D1
________0D51:   ret
________0D52:   dcr c
________0D53:   mov a, c
________0D54:   #d8 $38, $D2                                    ; STAW    D2
________0D56:   jr $0D60
;------------------------------------------------------------
________0D57:   inr b
________0D58:   mov a, b
________0D59:   #d8 $38, $D3                                    ; STAW    D3
________0D5B:   jr $0D60
;------------------------------------------------------------
________0D5C:   inr c
________0D5D:   mov a, c
________0D5E:   #d8 $38, $D2                                    ; STAW    D2
________0D60:   calf $09AD
________0D62:   #d8 $30, $D0                                    ; DCRW    D0
________0D64:   ret
________0D65:   #d8 $20, $D1                                    ; INRW    D1
________0D67:   ret

;------------------------------------------------------------
;Draw a thick black frame around the screen
CALF____0D68:   #d8 $34, $A3, $C2                               ; LXI     H,C2A3      ;Point to 2nd screen
________0D6B:   #d8 $69, $FF                                    ; MVI     A,FF	;Black character
________0D6D:   #d8 $6A, $05                                    ; MVI     B,05	;Write 6 characters
________0D6F:   calt $00BE                                      ; "A ==> (HL+)xB"
________0D70:   #d8 $69, $1F                                    ; MVI     A,1F	;Then a char with 5 upper dots filled
________0D72:   #d8 $6A, $3E                                    ; MVI     B,3E	;Times 63
________0D74:   calt $00BE                                      ; "A ==> (HL+)xB"
________0D75:   #d8 $6B, $04                                    ; MVI     C,04
________0D77:   #d8 $6A, $0B                                    ; MVI     B,0B
________0D79:   #d8 $69, $FF                                    ; MVI     A,FF
________0D7B:   calt $00BE                                      ; "A ==> (HL+)xB"
________0D7C:   calt $008A                                      ; "Clear A"
________0D7D:   #d8 $6A, $3E                                    ; MVI     B,3E
________0D7F:   calt $00BE                                      ; "A ==> (HL+)xB"
________0D80:   dcr c
________0D81:   jr $0D77
________0D82:   #d8 $69, $FF                                    ; MVI     A,FF
________0D84:   #d8 $6A, $0B                                    ; MVI     B,0B
________0D86:   calt $00BE                                      ; "A ==> (HL+)xB"
________0D87:   #d8 $69, $F0                                    ; MVI     A,F0
________0D89:   #d8 $6A, $3E                                    ; MVI     B,3E
________0D8B:   calt $00BE                                      ; "A ==> (HL+)xB"
________0D8C:   #d8 $69, $FF                                    ; MVI     A,FF
________0D8E:   #d8 $6A, $05                                    ; MVI     B,05
________0D90:   calt $00BE                                      ; "A ==> (HL+)xB"
________0D91:   ret
;------------------------------------------------------------
;This draws the puzzle grid, I think...
CALF____0D92:   #d8 $65, $D5, $00                               ; NEIW    D5,00
________0D95:   jr $0DA2
________0D96:   #d8 $65, $D5, $01                               ; NEIW    D5,01
________0D99:   jr $0DA5
________0D9A:   #d8 $75, $D5, $02                               ; EQIW    D5,02
________0D9D:   jre $0DC3
________0D9F:   #d8 $34, $D8, $C2                               ; LXI     H,C2D8
________0DA2:   #d8 $34, $B8, $C2                               ; LXI     H,C2B8
________0DA5:   #d8 $34, $C8, $C2                               ; LXI     H,C2C8
________0DA8:   calt $00B2                                      ; "[PC+2] Draw Horizontal Line"
________0DA9:   #d8 $F0, $00                                    ; DB $F0,$00
________0DAB:   #d8 $6A, $04                                    ; MVI     B,04
________0DAD:   push bc
________0DAF:   #d8 $6D, $4A                                    ; MVI     E,4A
________0DB1:   calt $009A                                      ; "HL <== HL+E"
________0DB2:   calt $00B2                                      ; "[PC+2] Draw Horizontal Line"
________0DB3:   #d8 $FF, $00                                    ; DB $FF,$00
________0DB5:   pop bc
________0DB7:   dcr b
________0DB8:   jr $0DAD
________0DB9:   #d8 $6D, $4A                                    ; MVI     E,4A
________0DBB:   calt $009A                                      ; "HL <== HL+E"
________0DBC:   calt $00B2                                      ; "[PC+2] Draw Horizontal Line"
________0DBD:   #d8 $1F, $00                                    ; DB $1F,00
________0DBF:   #d8 $20, $D5                                    ; INRW    D5
________0DC1:   jre $0D92
________0DC3:   #d8 $34, $3E, $C3                               ; LXI     H,C33E
________0DC6:   calt $00B2                                      ; "[PC+2] Draw Horizontal Line"
________0DC7:   #d8 $10, $40                                    ; DB $10,$40
________0DC9:   #d8 $34, $D4, $C3                               ; LXI     H,C3D4
________0DCC:   calt $00B2                                      ; "[PC+2] Draw Horizontal Line"
________0DCD:   #d8 $10, $40                                    ; DB $10,$40
________0DCF:   calt $008A                                      ; "Clear A"
________0DD0:   #d8 $38, $D5                                    ; STAW    D5
________0DD2:   ret
;------------------------------------------------------------
________0DD3:   #d8 $67, $01                                    ; NEI     A,01
________0DD5:   jr $0DEE
________0DD6:   #d8 $67, $04                                    ; NEI     A,04
________0DD8:   jre $0DFC
________0DDA:   #d8 $67, $02                                    ; NEI     A,02
________0DDC:   jre $0E0A

________0DDE:   mov a, [$C7FF]                                  ;More puzzle grid drawing, probably...
________0DE2:   #d8 $07, $03                                    ; ANI     A,03
________0DE4:   #d8 $67, $01                                    ; NEI     A,01
________0DE6:   rets

________0DE7:   #d8 $14, $FF, $12                               ; LXI     B,12FF
________0DEA:   #d8 $15, $A2, $FF                               ; ORIW    A2,FF
________0DED:   jr $0DFB
;------------------------------------------------------------
________0DEE:   mov a, [$C7FF]
________0DF2:   #d8 $37, $09                                    ; LTI     A,09
________0DF4:   rets

________0DF5:   #d8 $14, $04, $0D                               ; LXI     B,0D04
________0DF8:   #d8 $05, $A2, $00                               ; ANIW    A2,00
________0DFB:   jr $0E17
;------------------------------------------------------------
________0DFC:   mov a, [$C7FF]
________0E00:   #d8 $27, $04                                    ; GTI     A,04
________0E02:   rets
________0E03:   #d8 $14, $FC, $0F                               ; LXI     B,0FFC
________0E06:   #d8 $05, $A2, $00                               ; ANIW    A2,00
________0E09:   jr $0E17
;------------------------------------------------------------
________0E0A:   mov a, [$C7FF]
________0E0E:   #d8 $47, $03                                    ; ONI     A,03
________0E10:   rets

________0E11:   #d8 $14, $01, $11                               ; LXI     B,1101
________0E14:   #d8 $15, $A2, $FF                               ; ORIW    A2,FF
________0E17:   mov a, [$C7FF]
________0E1B:   mov e, a
________0E1C:   mov [$C7FE], a
________0E20:   add a, c
________0E22:   mov d, a
________0E23:   mov [$C7FF], a
________0E27:   #d8 $34, $F1, $C7                               ; LXI     H,C7F1
________0E2A:   mov a, d
________0E2B:   dcr a
________0E2C:   jr $0E2E
________0E2D:   jr $0E30

________0E2E:   inx hl
________0E2F:   jr $0E2B

________0E30:   mov a, e
________0E31:   #d8 $24, $F1, $C7                               ; LXI     D,C7F1
________0E34:   dcr a
________0E35:   jr $0E39
________0E36:   jmp $08F8

________0E39:   inx de
________0E3A:   jr $0E34
;------------------------------------------------------------
CALF____0E3B:   calf $0CBF
________0E3D:   calt $00B2                                      ; "[PC+2] Draw Horizontal Line"
________0E3E:   #d8 $F0, $10                                    ; DB $F0,$10
________0E40:   #d8 $6D, $3A                                    ; MVI     E,3A
________0E42:   calt $009A                                      ; "HL <== HL+E"
________0E43:   calt $00B2                                      ; "[PC+2] Draw Horizontal Line"
________0E44:   #d8 $FF, $10                                    ; DB $FF,$10
________0E46:   #d8 $6D, $3A                                    ; MVI     E,3A
________0E48:   calt $009A                                      ; "HL <== HL+E"
________0E49:   calt $00B2                                      ; "[PC+2] Draw Horizontal Line"
________0E4A:   #d8 $1F, $10                                    ; DB $1F,$10
________0E4C:   ret
;------------------------------------------------------------
; Turns on a hardware timer
CALF____0E4D:   di
________0E4F:   #d8 $69, $07                                    ; MVI     A,07
________0E51:   mov tmm, a
________0E53:   #d8 $69, $74                                    ; MVI     A,74
________0E55:   mov tm0, a
________0E57:   #d8 $05, $80, $FC                               ; ANIW    80,FC
________0E5A:   stm
________0E5B:   ei
________0E5D:   ret
;------------------------------------------------------------
; Loads (DE/)HL with various common addresses
CALF____0E5E:   #d8 $24, $00, $C0                               ; LXI     D,C000
________0E61:   #d8 $34, $58, $C2                               ; LXI     H,C258
CALF____0E64:   #d8 $34, $EC, $04                               ; LXI     H,04EC
CALF____0E67:   #d8 $34, $F2, $C7                               ; LXI     H,C7F2
CALF____0E6A:   #d8 $34, $B0, $FF                               ; LXI     H,FFB0
________0E6D:   ret
;------------------------------------------------------------

;[PC+1] ?? (Unpack 8 bytes -> 64 bytes (Twice!))
CALT_A8_0E6E:   pop hl
________0E70:   ldax [hl+]
________0E71:   push hl
________0E73:   calt $00BC                                      ; "HL=C4B0+(A*$10)"
________0E74:   calt $00A8                                      ; "XCHG HL,DE"
________0E75:   #d8 $44, $78, $0E                               ; CALL    0E78        ;This call means the next code runs twice

________0E78:   #d8 $6A, $07                                    ; MVI     B,7
________0E7A:   #d8 $6B, $07                                    ; MVI     C,7
________0E7C:   calf $0E6A                                      ;(FFB0->HL)
________0E7E:   ldax [de]                                       ;In this loop, the byte at (FFB0)
________0E7F:   ral                                             ;Has its bits split up into 8 bytes
________0E81:   push va                                         ;And this loop runs 8 times...
________0E83:   ldax [hl]
________0E84:   #d8 $48, $31                                    ; RLR
________0E86:   stax [hl+]
________0E87:   pop va
________0E89:   dcr c
________0E8A:   jr $0E7F
________0E8B:   inx de
________0E8C:   dcr b
________0E8D:   jr $0E7A

________0E8E:   push de
________0E90:   dcx hl
________0E91:   dcx de
________0E92:   #d8 $6A, $07                                    ; MVI     B,7
________0E94:   calt $00AC                                      ; "((HL-) ==> (DE-))xB"
________0E95:   pop de
________0E97:   ret
;------------------------------------------------------------
;[PC+1] ?? (Unpack & Roll 8 bits)
CALT_A9_0E98:   pop hl
________0E9A:   ldax [hl+]
________0E9B:   push hl
________0E9D:   push va
________0E9F:   calf $0E73
________0EA1:   pop va
________0EA3:   jr $0EA9
;-----------------------------------------------------------
;[PC+1] ?? (Roll 8 bits -> Byte?)
CALT_AA_0EA4:   pop hl
________0EA6:   ldax [hl+]
________0EA7:   push hl
________0EA9:   calt $00BC                                      ; "HL=C4B0+(A*$10)"
________0EAA:   #d8 $24, $BF, $FF                               ; LXI     D,FFBF
________0EAD:   calt $00A8                                      ; "XCHG HL,DE"
________0EAE:   push de
________0EB0:   #d8 $6B, $0F                                    ; MVI     C,0F
________0EB2:   #d8 $6A, $07                                    ; MVI     B,8-1
________0EB4:   ldax [de]
________0EB5:   ral 
________0EB7:   push va
________0EB9:   ldax [hl]
________0EBA:   #d8 $48, $31                                    ; RLR
________0EBC:   stax [hl]
________0EBD:   pop va
________0EBF:   dcr b
________0EC0:   jr $0EB5
________0EC1:   dcx hl
________0EC2:   inx de
________0EC3:   dcr c
________0EC4:   jr $0EB2
________0EC5:   pop de
________0EC7:   #d8 $34, $B8, $FF                               ; LXI     H,FFB8
________0ECA:   calf $0ECE
________0ECC:   calf $0E6A

CALF____0ECE:   #d8 $6A, $07                                    ; MVI     B,8-1
________0ED0:   calt $00AA                                      ; "((HL+) ==> (DE+))xB"
________0ED1:   ret
;------------------------------------------------------------
;[PC+x] ?? (Add/Sub multiple bytes)
CALT_AB_0ED2:   pop hl
________0ED4:   ldax [hl+]
________0ED5:   push hl
________0ED7:   mov b, a
________0ED8:   #d8 $07, $0F                                    ; ANI     A,0F
________0EDA:   #d8 $38, $96                                    ; STAW    96
________0EDC:   mov a, b
________0EDD:   calt $00C0                                      ; "(RLR A)x4"
________0EDE:   #d8 $07, $0F                                    ; ANI     A,0F
________0EE0:   #d8 $37, $0D                                    ; LTI     A,0D
________0EE2:   ret
________0EE3:   #d8 $38, $97                                    ; STAW    97
________0EE5:   #d8 $30, $97                                    ; DCRW    97
________0EE7:   jr $0EF0                                        ;Based on 97, jump to cart (4007)!
________0EE8:   calt $00A2                                      ; "CALT A0, CALT A4"
________0EE9:   pop bc
________0EEB:   #d8 $70, $1F, $07, $40                          ; LBCD    4007        ;Read vector from $4007 on cart, however...
________0EEF:   jb                                              ;...all 5 Pokekon games have "0000" there!
________0EF0:   pop hl
________0EF2:   ldax [hl+]
________0EF3:   push hl
________0EF5:   #d8 $38, $98                                    ; STAW    98
________0EF7:   #d8 $07, $0F                                    ; ANI     A,0F
________0EF9:   #d8 $37, $0C                                    ; LTI     A,0C
________0EFB:   jr $0EE5
________0EFC:   #d8 $34, $6E, $C5                               ; LXI     H,C56E
________0EFF:   inx hl
________0F00:   inx hl
________0F01:   inx hl
________0F02:   dcr a
________0F03:   jr $0EFF
________0F04:   #d8 $24, $96, $FF                               ; LXI     D,FF96
________0F07:   #d8 $45, $98, $80                               ; ONIW    98,80
________0F0A:   jr $0F10
________0F0B:   ldax [hl]
________0F0C:   #d8 $70, $E2                                    ; SUBX    D
________0F0E:   stax [hl]
________0F0F:   jr $0F18

________0F10:   #d8 $45, $98, $40                               ; ONIW    98,40
________0F13:   jr $0F18
________0F14:   ldax [hl]
________0F15:   #d8 $70, $C2                                    ; ADDX    D
________0F17:   stax [hl]
________0F18:   dcx hl
________0F19:   #d8 $45, $98, $10                               ; ONIW    98,10
________0F1C:   jr $0F23

________0F1D:   ldax [hl]
________0F1E:   #d8 $70, $C2                                    ; ADDX    D
________0F20:   stax [hl]
________0F21:   jre $0EE5

________0F23:   #d8 $45, $98, $20                               ; ONIW    98,20
________0F26:   jr $0F21
________0F27:   ldax [hl]
________0F28:   #d8 $70, $E2                                    ; SUBX    D
________0F2A:   stax [hl]
________0F2B:   jr $0F21
;------------------------------------------------------------
;Invert Screen RAM (C000~)
CALT_A6_0F2C:   #d8 $34, $00, $C0                               ; LXI     H,C000
;Invert Screen 2 RAM (C258~)
CALT_A7_0F2F:   #d8 $34, $58, $C2                               ; LXI     H,C258
________0F32:   #d8 $6B, $02                                    ; MVI     C,02

________0F34:   #d8 $6A, $C7                                    ; MVI     B,C7
________0F36:   calf $0F3B
________0F38:   dcr c
________0F39:   jr $0F34
________0F3A:   ret
;------------------------------------------------------------
;Invert bytes xB
CALF____0F3B:   ldax [hl]
________0F3C:   #d8 $16, $FF                                    ; XRI     A,FF
________0F3E:   stax [hl+]
________0F3F:   dcr b
________0F40:   jr $0F3B
________0F41:   ret
;------------------------------------------------------------
;[PC+1] Invert 8 bytes at (C4B8+A*$10)
CALT_A5_0F42:   pop hl
________0F44:   ldax [hl+]
________0F45:   push hl
________0F47:   #d8 $37, $0C                                    ; LTI     A,0C
________0F49:   ret

________0F4A:   calt $00BC                                      ; "HL=C4B0+(A*$10)"
________0F4B:   #d8 $6D, $08                                    ; MVI     E,08
________0F4D:   calt $009A                                      ; "HL <== HL+E"
________0F4E:   #d8 $6A, $07                                    ; MVI     B,07
________0F50:   jr $0F3B
;------------------------------------------------------------
;for the addition routine below...
________0F51:   mov a, h
________0F52:   #d8 $38, $B0                                    ; STAW    B0
________0F54:   mov a, l
________0F55:   #d8 $38, $B1                                    ; STAW    B1
________0F57:   #d8 $34, $B1, $FF                               ; LXI     H,FFB1
________0F5A:   #d8 $28, $96                                    ; LDAW    96
________0F5C:   jr $0F6D
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
________0F63:   #d8 $38, $96                                    ; STAW    96		;Get extra byte, keep in 96
________0F65:   #d8 $57, $01                                    ; OFFI    A,01	;If set, load from $FFA2 instead
________0F67:   #d8 $24, $A2, $FF                               ; LXI     D,FFA2
________0F6A:   #d8 $57, $02                                    ; OFFI    A,02	;If set, load from $FFB1
________0F6C:   jr $0F51

________0F6D:   calf $0C72                                      ;"RLR A" x2
________0F6F:   mov b, a                                        ;Get our length bits (8-32 bits)
________0F70:   #d8 $07, $03                                    ; ANI     A,03
________0F72:   mov c, a
________0F73:   mov a, b
________0F74:   calf $0C72                                      ;"RLR A" x2
________0F76:   #d8 $07, $03                                    ; ANI     A,03
________0F78:   mov b, a
________0F79:   #d8 $45, $96, $40                               ; ONIW    96,40	;Do we subtract instead of add?
________0F7C:   jr $0F83
________0F7D:   #d8 $45, $96, $80                               ; ONIW    96,80	;Do we work in binary-coded decimal?
________0F80:   jr $0F99
________0F81:   jre $0FB0

________0F83:   #d8 $45, $96, $80                               ; ONIW    96,80
________0F86:   jre $0FC1

________0F88:   clc
________0F8A:   ldax [de]
________0F8B:   #d8 $70, $D3                                    ; ADCX    H   	;Add HL-,DE-
________0F8D:   stax [de]
________0F8E:   dcr b
________0F8F:   jr $0F91
________0F90:   ret

________0F91:   dcx de
________0F92:   dcr c
________0F93:   jr $0F97
________0F94:   calf $0FD3                                      ;Clear C,HL
________0F96:   jr $0F8A

________0F97:   dcx hl
________0F98:   jr $0F8A

________0F99:   stc
________0F9B:   #d8 $69, $99                                    ; MVI     A,99
________0F9D:   #d8 $56, $00                                    ; ACI     A,00
________0F9F:   #d8 $70, $E3                                    ; SUBX    H
________0FA1:   #d8 $70, $C2                                    ; ADDX    D
________0FA3:   daa
________0FA4:   stax [de]
________0FA5:   dcr b
________0FA6:   jr $0FA8
________0FA7:   ret

________0FA8:   dcx de
________0FA9:   dcr c
________0FAA:   jr $0FAE
________0FAB:   calf $0FD3
________0FAD:   jr $0F9B

________0FAE:   dcx hl
________0FAF:   jr $0F9B
;-----
________0FB0:   clc
________0FB2:   ldax [de]
________0FB3:   #d8 $70, $F3                                    ; SBBX    H
________0FB5:   stax [de]
________0FB6:   dcr b
________0FB7:   jr $0FB9
________0FB8:   ret

________0FB9:   dcx de
________0FBA:   dcr c
________0FBB:   jr $0FBF
________0FBC:   calf $0FD3
________0FBE:   jr $0FB2

________0FBF:   dcx hl
________0FC0:   jr $0FB2
;------
________0FC1:   clc
________0FC3:   ldax [de]
________0FC4:   #d8 $70, $D3                                    ; ADCX    H
________0FC6:   daa
________0FC7:   stax [de]
________0FC8:   dcr b
________0FC9:   jr $0FCB
________0FCA:   ret

________0FCB:   dcx de
________0FCC:   dcr c
________0FCD:   jr $0FD1
________0FCE:   calf $0FD3
________0FD0:   jr $0FC3

________0FD1:   dcx hl
________0FD2:   jr $0FC3
;------------------------------------------------------------
;Clear C,HL (for the add/sub routine above)
CALF____0FD3:   #d8 $6B, $00                                    ; MVI     C,00
________0FD5:   #d8 $34, $00, $00                               ; LXI     H,0000
________0FD8:   ret
;------------------------------------------------------------
;[PC+1] INC/DEC Range of bytes from (HL)
;Extra byte's high bit sets Inc/Dec; rest is the byte counter.
CALT_AC_0FD9:   pop bc
________0FDB:   ldax [bc]
________0FDC:   inx bc
________0FDD:   push bc
________0FDF:   mov b, a
________0FE0:   #d8 $47, $80                                    ; ONI     A,80	;do we Dec?
________0FE2:   jr $0FF1

________0FE3:   #d8 $07, $7F                                    ; ANI     A,7F	;Counter can be 00-7F
________0FE5:   mov b, a
________0FE6:   ldax [hl]                                       ;Load a byte
________0FE7:   #d8 $66, $01                                    ; SUI     A,01	;Decrement it
________0FE9:   stax [hl-]
________0FEA:   #d8 $48, $1A                                    ; SKN     CY		;Quit our function if any byte= -1!
________0FEC:   jr $0FEE
________0FED:   ret

________0FEE:   dcr b
________0FEF:   jr $0FE6
________0FF0:   ret

________0FF1:   ldax [hl]                                       ;or Load a byte
________0FF2:   #d8 $46, $01                                    ; ADI     A,01	;Add 1
________0FF4:   stax [hl-]
________0FF5:   #d8 $48, $1A                                    ; SKN     CY		;Quit if any byte overflows!
________0FF7:   jr $0FF9
________0FF8:   ret

________0FF9:   dcr b
________0FFA:   jr $0FF1
________0FFB:   ret                                             ;What a weird way to end a BIOS...
;------------------------------------------------------------
________0FFC:   #d8 $00, $00, $00, $00                          ; DB 0,0,0,0		;Unused bytes (and who could blame 'em?)
	
; EOF!
