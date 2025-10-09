;"Pokekon" BIOS disassembly & comments by Chris Covell

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
RESET:  0000:   00                          NOP
        0001:   48 24                       DI
        0003:   CF                          JR      0013
;------------------------------------------------------------
INT0:   0004:   54 0C 40                    JMP     400C
	0007:   00                          NOP
;------------------------------------------------------------
INTT:   0008:   4E E6                       JRE     00F0
;------------------------------------------------------------
;((HL-) ==> (DE-))xB
; Copies the data pointed to by HL "(HL)" to (DE).
; B holds a single byte for the copy loop count.
CALT 96 000A:   2F                          LDAX    H-
        000B:   3E                          STAX    D-
        000C:   52                          DCR     B
        000D:   FC                          JR      000A
        000E:   08                          RET
        000F:   00                          NOP
;------------------------------------------------------------
INT1:   0010:   54 0F 40                    JMP     400F
;------------------------------------------------------------
cont    0013:   04 00 00                    LXI     SP,0000
        0016:   48 3C                       PER			;Set Port E to AB mode
        0018:   69 C1                       MVI     A,C1
        001A:   4D C0                       MOV     PA,A
        001C:   64 88 FE                    ANI     PA,FE
        001F:   64 98 01                    ORI     PA,01
        0022:   85                          CALT    008A	; "Clear A"
        0023:   4D C4                       MOV     MB,A	;Mode B = All outputs
        0025:   64 98 38                    ORI     PA,38

        0028:   69 39                       MVI     A,39
        002A:   4D C1                       MOV     PB,A
        002C:   64 98 02                    ORI     PA,02
        002F:   64 88 FD                    ANI     PA,FD
        0032:   69 3E                       MVI     A,3E
        0034:   4D C1                       MOV     PB,A
        0036:   64 98 02                    ORI     PA,02
        0039:   64 88 FD                    ANI     PA,FD
        003C:   64 88 C7                    ANI     PA,C7
        003F:   64 98 04                    ORI     PA,04
        0042:   69 07                       MVI     A,07
        0044:   4D C9                       MOV     TMM,A	;Timer register = #$7
        0046:   69 74                       MVI     A,74
        0048:   4D C6                       MOV     T0,A        ;Timer option reg = #$74
        004A:   87                          CALT    008E	; "Clear Screen RAM"
        004B:   88                          CALT    0090	; "Clear C4B0~C593"
        004C:   89                          CALT    0092	; "Clear C594~C86F?"
        004D:   34 80 FF                    LXI     H,FF80
        0050:   6A 49                       MVI     B,49
        0052:   8A                          CALT    0094	; "Clear RAM (HL+)xB"
        0053:   81                          CALT    0082	; Copy Screen RAM to LCD Driver
        0054:   69 05                       MVI     A,05
        0056:   4D C3                       MOV     MK,A        ;Mask = IntT,1 ON
        0058:   48 20                       EI
        005A:   80                          CALT    0080	; [PC+1] Check Cartridge
        005B:   C0                          .DB $C0 		;Jump to ($4001) in cartridge
        005C:   54 7F 05                    JMP     057F        ;Flow continues if no cartridge is present.
;------------------------------------------------------------
;(DE+)-(HL+) ==> A
; Loads A with (DE), increments DE, then subtracts (HL) from A and increments HL.
CALT A1 005F:   2C                          LDAX    D+
        0060:   70 E5                       SUBX    H+
        0062:   08                          RET
;------------------------------------------------------------
;?? (Find 1st diff. byte in (HL),(DE)xB)  (Matching byte perhaps?)
; I don't know how useful this is, but I guess it's for advancing pointers to
; the first difference between 2 buffers, etc.
CALT A2 0063:   A1                          CALT    00C2	; "(DE+)-(HL+) ==> A"
        0064:   48 1C                       SKN     Z
        0066:   C1                          JR      0068
        0067:   08                          RET

        0068:   52                          DCR     B
        0069:   F9                          JR      0063
        006A:   60 91                       XRA     A,A
        006C:   08                          RET
;------------------------------------------------------------
;?? (Find diff. & Copy bytes)
; I have no idea what purpose this serves...
CALT A3 006D:   48 3E                       PUSH    H
        006F:   48 2E                       PUSH    D
        0071:   48 1E                       PUSH    B
        0073:   A2                          CALT    00C4	; "?? (Find 1st diff. byte in (HL),(DE)xB)"
        0074:   48 1F                       POP     B
        0076:   48 2F                       POP     D
        0078:   48 3F                       POP     H
        007A:   48 1A                       SKN     CY
        007C:   C1                          JR      007E
        007D:   08                          RET

        007E:   95                          CALT    00AA	; "((HL+) ==> (DE+))xB"
        007F:   08                          RET
;------------------------------------------------------------
;This is the call table provided by the CALT instruction in the uPD78xx CPU.
;It provides a way for programs to call commonly-used routines using a single-byte opcode.
;The numbers in the parentheses refer to the opcode for each entry in the table.
;Each table entry contains an address to jump to.  (Quite simple.)

;Opcodes $80-$AD point to routines hard-coded in the uPD78c06 CPU ROM.
;Opcodes $AE-$B7 point to cartridge ROM routines (whose jump tables are at $4012-$402F.)

; "[PC+X]" means the subroutine uses the bytes after its call as parameters.
; the subroutine then usually advances the return address by X bytes before returning.

(CALT 80) 0080:   A6 01                       01A6	;[PC+1] Check Cartridge
(CALT 81) 0082:   CF 01                       01CF	;Copy Screen RAM to LCD Driver
(CALT 82) 0084:   8E 01                       018E	;[PC+2] Setup/Play Sound
(CALT 83) 0086:   9C 01                       019C	;Setup/Play Music
(CALT 84) 0088:   1F 09                       091F	;Read Controller FF90-FF95
(CALT 85) 008A:   9D 08                       089D	;Clear A
(CALT 86) 008C:   FF 08                       08FF	;Clear Screen 2 RAM
(CALT 87) 008E:   02 09                       0902	;Clear Screen RAM
(CALT 88) 0090:   15 09                       0915	;Clear C4B0~C593
(CALT 89) 0092:   0D 09                       090D	;Clear C594~C7FF
(CALT 8A) 0094:   1A 09                       091A	;Clear RAM (HL+)xB
(CALT 8B) 0096:   1B 0C                       0C1B	;HL <== HL+DE
(CALT 8C) 0098:   0E 0C                       0C0E	;[PC+1] HL +- byte
(CALT 8D) 009A:   18 0C                       0C18	;HL <== HL+E
(CALT 8E) 009C:   8C 09                       098C	;Swap C258+ <==> C000+
(CALT 8F) 009E:   81 09                       0981	;C000+ ==> C258+
(CALT 90) 00A0:   7E 09                       097E	;C258+ ==> C000+
(CALT 91) 00A2:   CD 01                       01CD	;CALT 00A0, CALT 00A4
(CALT 92) 00A4:   37 0B                       0B37	;?? (Move some RAM around...)
(CALT 93) 00A6:   D7 08                       08D7	;HL <== AxE
(CALT 94) 00A8:   A0 08                       08A0	;XCHG HL,DE
(CALT 95) 00AA:   11 0D                       0D11	;((HL+) ==> (DE+))xB
(CALT 96) 00AC:   0A 00                       000A	;((HL-) ==> (DE-))xB
(CALT 97) 00AE:   F3 08                       08F3	;((HL+) <==> (DE+))xB
(CALT 98) 00B0:   99 09                       0999	;Set Dot; B,C = X-,Y-position
(CALT 99) 00B2:   C7 09                       09C7	;[PC+2] Draw Horizontal Line
(CALT 9A) 00B4:   E4 09                       09E4	;[PC+3] Print Bytes on-Screen
(CALT 9B) 00B6:   29 0A                       0A29	;[PC+3] Print Text on-Screen
(CALT 9C) 00B8:   0E 0B                       0B0E	;Byte -> Point to Font Graphic
(CALT 9D) 00BA:   F1 0B                       0BF1	;Set HL to screen (B,C)
(CALT 9E) 00BC:   24 0C                       0C24	;HL=C4B0+(A*$10)
(CALT 9F) 00BE:   1B 09                       091B	;A ==> (HL+)xB
(CALT A0) 00C0:   6E 0C                       0C6E	;(RLR A)x4
(CALT A1) 00C2:   5F 00                       005F	;(DE+)-(HL+) ==> A
(CALT A2) 00C4:   63 00                       0063	;?? (Find 1st diff. byte in (HL),(DE)xB)
(CALT A3) 00C6:   6D 00                       006D	;?? (Find diff. & Copy bytes)
(CALT A4) 00C8:   5D 0F                       0F5D	;[PC+1] 8~32-bit Add/Subtract (dec/hex)
(CALT A5) 00CA:   42 0F                       0F42	;[PC+1] Invert 8 bytes at (C4B8+A*$10)
(CALT A6) 00CC:   2C 0F                       0F2C	;Invert Screen RAM (C000~)
(CALT A7) 00CE:   2F 0F                       0F2F	;Invert Screen 2 RAM (C258~)
(CALT A8) 00D0:   6E 0E                       0E6E	;[PC+1] ?? (Unpack 8 bytes -> 64 bytes (Twice!))
(CALT A9) 00D2:   98 0E                       0E98	;[PC+1] ?? (Unpack & Roll 8 bits)
(CALT AA) 00D4:   A4 0E                       0EA4	;[PC+1] ?? (Roll 8 bits -> Byte?)
(CALT AB) 00D6:   D2 0E                       0ED2	;[PC+x] ?? (Add/Sub multiple bytes)
(CALT AC) 00D8:   D9 0F                       0FD9	;[PC+1] INC/DEC Range of bytes from (HL)
(CALT AD) 00DA:   B1 09                       09B1	;Clear Dot; B,C = X-,Y-position

(CALT AE) 00DC:   12 40                       4012      ;Jump table for cartridge routines
(CALT AF) 00DE:   15 40                       4015
(CALT B0) 00E0:   18 40                       4018
(CALT B1) 00E2:   1B 40                       401B
(CALT B2) 00E4:   1E 40                       401E
(CALT B3) 00E6:   21 40                       4021
(CALT B4) 00E8:   24 40                       4024
(CALT B5) 00EA:   27 40                       4027
(CALT B6) 00EC:   2A 40                       402A
(CALT B7) 00EE:   2D 40                       402D
;-----------------------------------------------------------
;                        Timer Interrupt
INTT:   00F0:   45 80 01                    ONIW    80,01	;If 1, don't jump to cart.
        00F3:   4E 66                       JRE     015B

        00F5:   30 9A                       DCRW    9A
        00F7:   4E 5F                       JRE     0158

        00F9:   48 0E                       PUSH    V
        00FB:   28 8F                       LDAW    8F
        00FD:   38 9A                       STAW    9A
        00FF:   30 99                       DCRW    99
        0101:   4E 2B                       JRE     012E

        0103:   48 1E                       PUSH    B
        0105:   48 2E                       PUSH    D
        0107:   48 3E                       PUSH    H
        0109:   69 03                       MVI     A,03
        010B:   4D C9                       MOV     TMM,A	;Adjust timer
        010D:   69 53                       MVI     A,53
        010F:   51                          DCR     A
        0110:   FE                          JR      010F
        0111:   45 80 02                    ONIW    80,02
        0114:   C7                          JR      011C

        0115:   70 3F 84 FF                 LHLD    FF84
        0119:   78 A9                       CALF    08A9	;Music-playing code...
        011B:   CC                          JR      0128

        011C:   05 80 FC                    ANIW    80,FC
        011F:   69 07                       MVI     A,07
        0121:   4D C9                       MOV     TMM,A
        0123:   69 74                       MVI     A,74
        0125:   4D C6                       MOV     T0,A
        0127:   19                          STM
        0128:   48 3F                       POP     H
        012A:   48 2F                       POP     D
        012C:   48 1F                       POP     B
        012E:   28 88                       LDAW    88
        0130:   46 01                       ADI     A,01
        0132:   61                          DAA
        0133:   38 88                       STAW    88
        0135:   48 1A                       SKN     CY
        0137:   C1                          JR      0139
        0138:   D5                          JR      014E

        0139:   20 89                       INRW    89
        013B:   00                          NOP
        013C:   28 87                       LDAW    87
        013E:   46 01                       ADI     A,01
        0140:   61                          DAA
        0141:   38 87                       STAW    87
        0143:   48 1A                       SKN     CY
        0145:   C1                          JR      0147
        0146:   C7                          JR      014E

        0147:   28 86                       LDAW    86
        0149:   46 01                       ADI     A,01
        014B:   61                          DAA
        014C:   38 86                       STAW    86
        014E:   45 8A 80                    ONIW    8A,80
        0151:   20 8A                       INRW    8A
        0153:   20 8B                       INRW    8B
        0155:   00                          NOP
        0156:   48 0F                       POP     V
;--------
        0158:   48 20                       EI
        015A:   62                          RETI
;------------------------------------------------------------
        015B:   48 0E                       PUSH    V
        015D:   48 1E                       PUSH    B
        015F:   48 2E                       PUSH    D
        0161:   48 3E                       PUSH    H
        0163:   55 80 80                    OFFIW   80,80	;If 0, don't go to cart's INT routine
        0166:   54 09 40                    JMP     4009
;---------------------------------------
        0169:   60 D2                       ADC     A,B         ;Probably a simple random-number generator.
        016B:   60 D3                       ADC     A,C
        016D:   60 D4                       ADC     A,D
        016F:   60 D5                       ADC     A,E
        0171:   60 D6                       ADC     A,H
        0173:   60 D7                       ADC     A,L
        0175:   38 8C                       STAW    8C
        0177:   48 30                       RAL
        0179:   48 30                       RAL
        017B:   1A                          MOV     B,A
        017C:   48 2F                       POP     D
        017E:   48 2E                       PUSH    D
        0180:   60 D5                       ADC     A,E
        0182:   38 8D                       STAW    8D
        0184:   48 31                       RLR
        0186:   48 31                       RLR
        0188:   60 D2                       ADC     A,B
        018A:   38 8E                       STAW    8E
        018C:   4F 9A                       JRE     0128
;------------------------------------------------------------
;[PC+2] Setup/Play Sound
; 1st byte is sound pitch (00[silence] to $25); 2nd byte is length.
; Any pitch out of range could overrun the timers & sap the CPU.
CALT 82 018E:   48 24                       DI
        0190:   48 3F                       POP     H
        0192:   2D                          LDAX    H+		;(PC+1)
        0193:   1A                          MOV     B,A
        0194:   2D                          LDAX    H+          ;(PC+1)
        0195:   48 3E                       PUSH    H
        0197:   38 99                       STAW    99
        0199:   78 B6                       CALF    08B6        ;Set note timers
        019B:   C7                          JR      01A3
;------------------------------------------------------------
;Setup/Play Music
;HL should already contain the address of the music data.
;Format of the data string is the same as "Play Sound", with $FF terminating the song.
CALT 83 019C:   48 24                       DI
        019E:   15 80 02                    ORIW    80,02
        01A1:   78 A9                       CALF    08A9	;Read notes & set timers
        01A3:   48 20                       EI			;(sometimes skipped)
        01A5:   08                          RET
;------------------------------------------------------------
;[PC+1] Check Cartridge
; Checks if the cart is present, and possibly jumps to ($4001) or ($4003)
; The parameter $C0 sends it to $4001, $C1 to $4003, etc...
CALT 80 01A6:   34 00 40                    LXI     H,4000
        01A9:   2B                          LDAX    H
        01AA:   77 55                       EQI     A,55
        01AC:   18                          RETS

        01AD:   85                          CALT    008A	; "Clear A"
        01AE:   38 89                       STAW    89
        01B0:   2B                          LDAX    H
        01B1:   77 55                       EQI     A,55
        01B3:   18                          RETS
;----------------------------------
        01B4:   75 89 03                    EQIW    89,03
        01B7:   F8                          JR      01B0

        01B8:   7E 4D                       CALF    0E4D	;Sets a timer
        01BA:   15 80 80                    ORIW    80,80
        01BD:   32                          INX     H           ;->$4001
        01BE:   48 1F                       POP     B
        01C0:   29                          LDAX    B
        01C1:   67 C0                       NEI     A,C0        ;To cart if it's $C0
        01C3:   C4                          JR      01C8

        01C4:   32                          INX     H           ;->$4003
        01C5:   32                          INX     H
        01C6:   51                          DCR     A
        01C7:   F9                          JR      01C1

        01C8:   2D                          LDAX    H+
        01C9:   1B                          MOV     C,A
        01CA:   2B                          LDAX    H
        01CB:   1A                          MOV     B,A
        01CC:   73                          JB                  ;Jump to cartridge!
;-----------------------------------------------------------
;CALT 00A0, CALT 00A4
; Copies the 2nd screen to the screen buffer & moves some text around
; And updates the LCD...
CALT 91 01CD:   90                          CALT    00A0	; "C258+ ==> C000+"
        01CE:   92                          CALT    00A4	; "?? (Move some RAM around...)"
;-----------------------------------------------------------
;Copy Screen RAM to LCD Driver
; A very important and often-used function.  The LCD won't show anything without it...
								;Set up writing for LCD controller #1
CALT 81 01CF:   64 98 08                    ORI     PA,08       ;(Port A, bit 3 on)
        01D2:   34 31 C0                    LXI     H,C031
        01D5:   24 7D 00                    LXI     D,007D
        01D8:   6A 00                       MVI     B,00
        01DA:   64 88 FB                    ANI     PA,FB       ;bit 2 off
        01DD:   0A                          MOV     A,B
        01DE:   4D C1                       MOV     PB,A        ;Port B = (A)
        01E0:   64 98 02                    ORI     PA,02       ;bit 1 on
        01E3:   64 88 FD                    ANI     PA,FD       ;bit 1 off
        01E6:   6B 31                       MVI     C,31
        01E8:   64 98 04                    ORI     PA,04       ;bit 2 on
        01EB:   2F                          LDAX    H-          ;Screen data...
        01EC:   4D C1                       MOV     PB,A	;...to Port B
        01EE:   64 98 02                    ORI     PA,02       ;bit 1 on
        01F1:   64 88 FD                    ANI     PA,FD       ;bit 1 off
        01F4:   53                          DCR     C
        01F5:   F5                          JR      01EB
        01F6:   8B                          CALT    0096	; "HL <== HL+DE"
        01F7:   0A                          MOV     A,B
        01F8:   26 40                       ADINC   A,40
        01FA:   C3                          JR      01FE
        01FB:   1A                          MOV     B,A
        01FC:   4F DC                       JRE     01DA
								;Set up writing for LCD controller #2
        01FE:   64 88 F7                    ANI     PA,F7       ;bit 3 off
        0201:   64 98 10                    ORI     PA,10       ;bit 4 on
        0204:   34 2C C1                    LXI     H,C12C
        0207:   24 19 00                    LXI     D,0019
        020A:   6A 00                       MVI     B,00
        020C:   64 88 FB                    ANI     PA,FB       ;Same as in 1st loop
        020F:   0A                          MOV     A,B
        0210:   4D C1                       MOV     PB,A
        0212:   64 98 02                    ORI     PA,02
        0215:   64 88 FD                    ANI     PA,FD
        0218:   6B 31                       MVI     C,31
        021A:   64 98 04                    ORI     PA,04
        021D:   2D                          LDAX    H+
        021E:   4D C1                       MOV     PB,A
        0220:   64 98 02                    ORI     PA,02
        0223:   64 88 FD                    ANI     PA,FD
        0226:   53                          DCR     C
        0227:   F5                          JR      021D
        0228:   8B                          CALT    0096	; "HL <== HL+DE"
        0229:   0A                          MOV     A,B
        022A:   26 40                       ADINC   A,40
        022C:   C3                          JR      0230
        022D:   1A                          MOV     B,A
        022E:   4F DC                       JRE     020C

        0230:   85                          CALT    008A	; "Clear A"
        0231:   38 96                       STAW    96
        						;Set up writing for LCD controller #3
        0233:   64 88 EF                    ANI     PA,EF	;bit 4 off
        0236:   64 98 20                    ORI     PA,20       ;bit 5 on
        0239:   34 32 C0                    LXI     H,C032
        023C:   24 5E C1                    LXI     D,C15E
        023F:   6A 00                       MVI     B,00
        0241:   64 88 FB                    ANI     PA,FB
        0244:   0A                          MOV     A,B
        0245:   4D C1                       MOV     PB,A
        0247:   64 98 02                    ORI     PA,02
        024A:   64 88 FD                    ANI     PA,FD
        024D:   00                          NOP
        024E:   64 98 04                    ORI     PA,04

        0251:   6B 18                       MVI     C,18

        0253:   2D                          LDAX    H+
        0254:   4D C1                       MOV     PB,A
        0256:   64 98 02                    ORI     PA,02
        0259:   64 88 FD                    ANI     PA,FD
        025C:   53                          DCR     C
        025D:   F5                          JR      0253

        025E:   48 2E                       PUSH    D
        0260:   24 32 00                    LXI     D,0032
        0263:   8B                          CALT    0096	; "HL <== HL+DE"
        0264:   48 2F                       POP     D
        0266:   94                          CALT    00A8	; "XCHG HL,DE"
        0267:   20 96                       INRW    96          ;Skip if a carry...
        0269:   55 96 01                    OFFIW   96,01       ;Do alternating lines
        026C:   E4                          JR      0251

        026D:   0A                          MOV     A,B
        026E:   26 40                       ADINC   A,40
        0270:   C3                          JR      0274
        0271:   1A                          MOV     B,A
        0272:   4F CD                       JRE     0241

        0274:   64 88 DF                    ANI     PA,DF       ;bit 5 off
        0277:   08                          RET
;-----------------------------------------------------------
	;Sound note and timer data...
        0278:   B2 0A EE 07 E1 08 D4 09 C8 09 BD 0A B2 0A A8 0B
        0288:   9E 0C 96 0C 8D 0D 85 0E 7E 0F 77 10 70 11 6A 12
        0298:   64 13 5E 14 59 15 54 16 4F 17 4A 19 46 1A 42 1C
        02A8:   3E 1E 3B 1F 37 22 34 23 31 26 2E 28 2C 2A 29 2D
        02B8:   27 2F 25 31 23 34 21 37 1F 3B 1D 3F
;-----------------------------------------------------------
	;Graphic Font Data
        02C4:   00 00 00 00 00 00 00 4F 00 00 00 07 00 07 00 14
        02E4:   7F 14 7F 14 24 2A 7F 2A 12 23 13 08 64 62 36 49
        02F4:   55 22 50 00 05 03 00 00 00 1C 22 41 00 00 41 22
        02F4:   1C 00 14 08 3E 08 14 08 08 3E 08 08 00 50 30 00
        0304:   00 08 08 08 08 08 00 60 60 00 00 20 10 08 04 02
        0314:   3E 51 49 45 3E 00 42 7F 40 00 42 61 51 49 46 21
        0324:   41 45 4B 31 18 14 12 7F 10 27 45 45 45 39 3C 4A
        0334:   49 49 30 01 71 09 05 03 36 49 49 49 36 06 49 49
        0344:   29 1E 00 36 36 00 00 00 56 36 00 00 08 14 22 41
        0354:   00 14 14 14 14 14 00 41 22 14 08 02 01 51 09 06
        0364:   32 49 79 41 3E 7E 11 11 11 7E 7F 49 49 49 36 3E
        0374:   41 41 41 22 7F 41 41 22 1C 7F 49 49 49 49 7F 09
        0384:   09 09 01 3E 41 49 49 7A 7F 08 08 08 7F 00 41 7F
        0394:   41 00 20 40 41 3F 01 7F 08 14 22 41 7F 40 40 40
        03A4:   40 7F 02 0C 02 7F 7F 04 08 10 7F 3E 41 41 41 3E
        03B4:   7F 09 09 09 06 3E 41 51 21 5E 7F 09 19 29 46 46
        03C4:   49 49 49 31 01 01 7F 01 01 3F 40 40 40 3F 1F 20
        03D4:   40 20 1F 3F 40 38 40 3F 63 14 08 14 63 07 08 70
        03E4:   08 07 61 51 49 45 43 00 7F 41 41 00 15 16 7C 16
        03F4:   15 00 41 41 7F 00 04 02 01 02 04 40 40 40 40 40
        0404:   00 1F 11 11 1F 00 00 11 1F 10 00 1D 15 15 17 00
        0414:   11 15 15 1F 00 0F 08 1F 08 00 17 15 15 1D 00 1F
        0424:   15 15 1D 00 03 01 01 1F 00 1F 15 15 1F 00 17 15
        0434:   15 1F 1E 09 09 09 1E 1F 15 15 15 0A 0E 11 11 11
        0444:   11 1F 11 11 11 0E 1F 15 15 15 11 1F 05 05 05 01
        0454:   0E 11 11 15 1D 1F 04 04 04 1F 00 11 1F 11 00 08
        0464:   10 11 0F 01 1F 08 04 0A 11 1F 10 10 10 10 1F 02
        0474:   04 02 1F 1F 02 04 08 1F 0E 11 11 11 0E 1F 05 05
        0484:   05 02 0E 11 15 09 16 1F 05 05 0D 12 12 15 15 15
        0494:   09 01 01 1F 01 01 0F 10 10 10 0F 07 08 10 08 07
        04A4:   0F 10 0C 10 0F 1B 0A 04 0A 1B 03 04 18 04 03 11
        04B4:   19 15 13 11
;-----------------------------------------------------------
	;Text data
        04B8:   2C 23 24 00 24 2F 34 00 2D 21 34 32 29 38 00 33	;LCD DOT MATRIX SYSTEM
        04C8:   39 33 34 25 2D 00 26 35 2C 2C 00 27 32 21 30 28 ;FULL GRAPHIC
        04D8:   29 23 00 08 17 15 0A 16 14 00 24 2F 34 33 09 00 ;(75*64 DOTS)
        04E8:   00 00 00 FF
	;Music notation data
        04EC:   00 0A 06 0A 0B 0A 0F 0A 12 14 12 14
        04F8:   12 14 12 14 0A 14 0A 14 0B 14 0B 07 0D 07 0B 07
        0508:   10 14 10 14 0F 14 0F 14 0D 28 00 0A 06 0A 0B 0A
        0518:   0F 0A 12 14 12 14 12 14 12 14 0A 14 0A 07 0B 07
        0528:   0A 07 0B 14 0B 07 0D 07 0B 07 0D 14 0D 14 06 14
        0538:   08 0A 0A 0A 0B 3C 00 50 FF
	;Text data
        0541:   27 32 21 0E 00 38 10 10 0C 39 10 10 		;GRA. X00,Y00

        054D:   30 35 3A 3A 2C 25                               ;PUZZLE

        0553:   34 29 2D 25 1B 10 10 10 0E 10			;TIME:000.0
	;Grid data, probably
        055D:   04 04 08 01 01 08 04 04 08 01 01 02 04 04 02 01
        056D:   01 02

        056F:   08 04 02 04 08 08 08 01 02 01 08 04 02 02 04 02
;-----------------------------------------------------------
;from 005C -

        057F:   86                          CALT    008C	;Clear Screen 2 RAM
        0580:   38 D8                       STAW    D8          ;Set mem locations to 0
        0582:   38 82                       STAW    82
        0584:   38 A5                       STAW    A5
        0586:   34 B8 04                    LXI     H,04B8	;Start of scrolltext
        0589:   70 3E D6 FF                 SHLD    FFD6	;Save pointer
        058D:   7D 68                       CALF    0D68        ;Setup RAM vars
        058F:   90                          CALT    00A0	; "C258+ ==> C000+"
        0590:   81                          CALT    0082	;Copy Screen RAM to LCD Driver
        0591:   85                          CALT    008A	; "Clear A"
        0592:   38 DA                       STAW    DA
        0594:   38 D1                       STAW    D1
        0596:   38 D2                       STAW    D2
        0598:   38 D5                       STAW    D5
        059A:   69 FF                       MVI     A,FF
        059C:   38 D0                       STAW    D0
        059E:   34 D8 FF                    LXI     H,FFD8
        05A1:   70 93                       XRAX    H		;A=$FF XOR ($FFD8)
        05A3:   38 D8                       STAW    D8
        05A5:   69 60                       MVI     A,60        ;A delay value for the scrolltext
        05A7:   38 8A                       STAW    8A

;Main Loop starts here!
        05A9:   80                          CALT    0080	;[PC+1] Check Cartridge
        05AA:   C1                          .DB $C1 		;Jump to ($4003) in cartridge

        05AB:   55 80 02                    OFFIW   80,02       ;If bit 1 is on, no music
        05AE:   C3                          JR      05B2
        05AF:   7E 64                       CALF    0E64	;Point HL to the music data
        05B1:   83                          CALT    0086	;Setup/Play Music
        05B2:   84                          CALT    0088	;Read Controller FF90-FF95
        05B3:   65 93 01                    NEIW    93,01       ;If Select is pressed...
        05B6:   54 EC 06                    JMP     06EC        ;Setup puzzle
        05B9:   65 D2 0F                    NEIW    D2,0F
        05BC:   4F D3                       JRE     0591        ;(go to main loop setup)
        05BE:   7D 1F                       CALF    0D1F        ;Draw spiral dot-by-dot
        05C0:   7D 1F                       CALF    0D1F	;Draw spiral dot-by-dot
        05C2:   90                          CALT    00A0	; "C258+ ==> C000+"
        05C3:   81                          CALT    0082	;Copy Screen RAM to LCD Driver
        05C4:   65 93 08                    NEIW    93,08       ;If Start is pressed...
        05C7:   C9                          JR      05D1        ;Jump to graphic program

        05C8:   75 8A 80                    EQIW    8A,80       ;Delay for the scrolltext
        05CB:   4F DC                       JRE     05A9        ;JRE Main Loop
        05CD:   7C E2                       CALF    0CE2        ;Scroll Text routine
        05CF:   4F D4                       JRE     05A5        ;Reset scrolltext delay...
;-----------------------------------------------------------
;"Paint" program setup routines
        05D1:   7E 4D                       CALF    0E4D        ;Turn timer on
        05D3:   86                          CALT    008C	; "Clear Screen 2 RAM"
        05D4:   88                          CALT    0090	; "Clear C4B0~C593"
        05D5:   34 41 05                    LXI     H,0541      ;"GRA"
        05D8:   9B                          CALT    00B6	; "[PC+3] Print Text on-Screen"
        05D9:   02 00 1C                    .DB $02,$00,$1C     ;Parameters for the text routine
        05DC:   69 05                       MVI     A,05
        05DE:   34 B8 C4                    LXI     H,C4B8
        05E1:   3D                          STAX    H+
        05E2:   32                          INX     H
        05E3:   3B                          STAX    H
        05E4:   41                          INR     A
        05E5:   34 70 C5                    LXI     H,C570
        05E8:   3D                          STAX    H+
        05E9:   41                          INR     A
        05EA:   38 A6                       STAW    A6
        05EC:   69 39                       MVI     A,39
        05EE:   3D                          STAX    H+
        05EF:   41                          INR     A
        05F0:   38 A7                       STAW    A7
        05F2:   85                          CALT    008A	; "Clear A"
        05F3:   3D                          STAX    H+
        05F4:   38 A0                       STAW    A0          ;X,Y position for cursor
        05F6:   38 A1                       STAW    A1
        05F8:   69 99                       MVI     A,99        ;What does this do?
        05FA:   6A 0A                       MVI     B,0A
        05FC:   32                          INX     H
        05FD:   32                          INX     H
        05FE:   3D                          STAX    H+		;Just writes "99s" 3 bytes apart
        05FF:   32                          INX     H
        0600:   32                          INX     H
        0601:   52                          DCR     B
        0602:   FB                          JR      05FE
        0603:   7D 68                       CALF    0D68        ;Draw Border

        0605:   69 70                       MVI     A,70
        0607:   38 8A                       STAW    8A
        0609:   34 A0 FF                    LXI     H,FFA0      ;Print the X-, Y- position
        060C:   9A                          CALT    00B4	; "[PC+3] Print Bytes on-Screen"
        060D:   26 00 19                    .DB $26,$00,$19     ;Parameters for the print routine
        0610:   34 A1 FF                    LXI     H,FFA1
        0613:   9A                          CALT    00B4	; "[PC+3] Print Bytes on-Screen"
        0614:   3E 00 19                    .DB $3E,$00,$19     ;Parameters for the print routine
        0617:   91                          CALT    00A2	; "CALT A0, CALT A4"
        0618:   80                          CALT    0080	;[PC+1] Check Cartridge
        0619:   C1                          .DB	$C1		;Jump to ($4003) in cartridge

        061A:   45 8A 80                    ONIW    8A,80
        061D:   FA                          JR      0618
        061E:   34 72 C5                    LXI     H,C572
        0621:   2B                          LDAX    H
        0622:   16 FF                       XRI     A,FF
        0624:   3B                          STAX    H
        0625:   84                          CALT    0088	;Read Controller FF90-FF95
        0626:   28 93                       LDAW    93
        0628:   57 3F                       OFFI    A,3F        ;Test Buttons 1,2,3,4
        062A:   C8                          JR      0633
        062B:   28 92                       LDAW    92
        062D:   57 0F                       OFFI    A,0F	;Test U,D,L,R
        062F:   4E 42                       JRE     0673
        0631:   4F D2                       JRE     0605
;------------------------------------------------------------
        0633:   45 95 09                    ONIW    95,09
        0636:   D0                          JR      0647
        0637:   77 08                       EQI     A,08        ;Start clears the screen
        0639:   C5                          JR      063F

        063A:   82                          CALT    0084	;[PC+2] Setup/Play Sound
        063B:   22 03                       .DB	$22,$03
        063D:   4F 9D                       JRE     05DC        ;Clear screen

        063F:   77 01                       EQI     A,01        ;Select goes to the Puzzle
        0641:   C5                          JR      0647

        0642:   82                          CALT    0084	;[PC+2] Setup/Play Sound
        0643:   23 03                       .DB	$23,$03
        0645:   4E A7                       JRE     06EE        ;To Puzzle Setup

        0647:   77 02                       EQI     A,02        ;Button 1
        0649:   C4                          JR      064E
        064A:   82                          CALT    0084	;[PC+2] Setup/Play Sound
        064B:   19 03                       .DB	$19,$03
        064D:   D6                          JR      0664        ;Clear a dot

        064E:   77 10                       EQI     A,10        ;Button 2
        0650:   C4                          JR      0655
        0651:   82                          CALT    0084	;[PC+2] Setup/Play Sound
        0652:   1B 03                       .DB	$1B,$03
        0654:   CF                          JR      0664        ;Clear a dot

        0655:   77 04                       EQI     A,04        ;Button 3
        0657:   C4                          JR      065C
        0658:   82                          CALT    0084	;[PC+2] Setup/Play Sound
        0659:   1D 03                       .DB	$1D,$03
        065B:   D0                          JR      066C        ;Set a dot

        065C:   77 20                       EQI     A,20        ;Button 4
        065E:   4E 20                       JRE     0680
        0660:   82                          CALT    0084	;[PC+2] Setup/Play Sound
        0661:   1E 03                       .DB	$1E,$03
        0663:   C8                          JR      066C        ;Set a dot

        0664:   28 A6                       LDAW    A6
        0666:   1A                          MOV     B,A
        0667:   28 A7                       LDAW    A7
        0669:   1B                          MOV     C,A
        066A:   AD                          CALT    00DA	; "Clear Dot; B,C = X-,Y-position"
        066B:   C7                          JR      0673

        066C:   28 A6                       LDAW    A6
        066E:   1A                          MOV     B,A
        066F:   28 A7                       LDAW    A7
        0671:   1B                          MOV     C,A
        0672:   98                          CALT    00B0	; "Set Dot; B,C = X-,Y-position"

        0673:   28 92                       LDAW    92
        0675:   67 0F                       NEI     A,0F        ;Check if U,D,L,R pressed at once??
        0677:   4F 8C                       JRE     0605
        0679:   47 01                       ONI     A,01        ;Up
        067B:   D8                          JR      0694

        067C:   28 A7                       LDAW    A7
        067E:   67 0E                       NEI     A,0E        ;Check lower limits of X-pos
        0680:   DA                          JR      069B

        0681:   51                          DCR     A
        0682:   38 A7                       STAW    A7
        0684:   51                          DCR     A
        0685:   70 79 71 C5                 MOV     C571,A
        0689:   28 A1                       LDAW    A1
        068B:   46 01                       ADI     A,01
        068D:   61                          DAA
        068E:   38 A1                       STAW    A1
        0690:   82                          CALT    0084	;[PC+2] Setup/Play Sound
        0691:   12 03                       .DB	$12,$03
        0693:   DA                          JR      06AE

        0694:   47 04                       ONI     A,04        ;Down
        0696:   D7                          JR      06AE

        0697:   28 A7                       LDAW    A7
        0699:   67 3A                       NEI     A,3A        ;Check lower cursor limit
        069B:   DB                          JR      06B7

        069C:   41                          INR     A
        069D:   38 A7                       STAW    A7
        069F:   51                          DCR     A
        06A0:   70 79 71 C5                 MOV     C571,A
        06A4:   28 A1                       LDAW    A1
        06A6:   46 99                       ADI     A,99
        06A8:   61                          DAA     
        06A9:   38 A1                       STAW    A1
        06AB:   82                          CALT    0084	;[PC+2] Setup/Play Sound
        06AC:   14 03                       .DB	$14,$03

        06AE:   28 92                       LDAW    92
        06B0:   47 08                       ONI     A,08        ;Right
        06B2:   D9                          JR      06CC

        06B3:   28 A6                       LDAW    A6
        06B5:   67 43                       NEI     A,43
        06B7:   DC                          JR      06D4

        06B8:   41                          INR     A
        06B9:   38 A6                       STAW    A6
        06BB:   51                          DCR     A
        06BC:   70 79 70 C5                 MOV     C570,A
        06C0:   28 A0                       LDAW    A0
        06C2:   46 01                       ADI     A,01
        06C4:   61                          DAA
        06C5:   38 A0                       STAW    A0
        06C7:   82                          CALT    0084	;[PC+2] Setup/Play Sound
        06C8:   17 03                       .DB	$17,$03
        06CA:   4F 39                       JRE     0605

        06CC:   47 02                       ONI     A,02        ;Left
        06CE:   4F 35                       JRE     0605
        06D0:   28 A6                       LDAW    A6
        06D2:   67 07                       NEI     A,07
        06D4:   D3                          JR      06E8

        06D5:   51                          DCR     A
        06D6:   38 A6                       STAW    A6
        06D8:   51                          DCR     A
        06D9:   70 79 70 C5                 MOV     C570,A
        06DD:   28 A0                       LDAW    A0
        06DF:   46 99                       ADI     A,99
        06E1:   61                          DAA     
        06E2:   38 A0                       STAW    A0
        06E4:   82                          CALT    0084	;[PC+2] Setup/Play Sound
        06E5:   16 03                       .DB	$16,$03
        06E7:   E2                          JR      06CA
;------------------------------------------------------------
        06E8:   82                          CALT    0084	;[PC+2] Setup/Play Sound
        06E9:   01 03                       .DB	$01,$03
        06EB:   FB                          JR      06E7
;------------------------------------------------------------
;Puzzle Setup Routines...
        06EC:   7E 4D                       CALF    0E4D	;Reset the timer?
        06EE:   69 21                       MVI     A,21
        06F0:   6A 0A                       MVI     B,0A
        06F2:   7E 67                       CALF    0E67	;LXI H,$C7F2
        06F4:   3D                          STAX    H+
        06F5:   41                          INR     A           ;Set up the puzzle tiles in RAM
        06F6:   52                          DCR     B
        06F7:   FC                          JR      06F4
        06F8:   0A                          MOV     A,B         ;$FF
        06F9:   3D                          STAX    H+
        06FA:   7E 67                       CALF    0E67
        06FC:   6A 0B                       MVI     B,0B
        06FE:   24 5E C7                    LXI     D,C75E
        0701:   95                          CALT    00AA	; "((HL+) ==> (DE+))xB"
        0702:   6A 0B                       MVI     B,0B
        0704:   34 5E C7                    LXI     H,C75E
        0707:   24 52 C7                    LXI     D,C752
        070A:   95                          CALT    00AA	; "((HL+) ==> (DE+))xB"
        070B:   86                          CALT    008C	; "Clear Screen 2 RAM"
        070C:   7D 68                       CALF    0D68        ;Draw Border
        070E:   7D 92                       CALF    0D92	;Draw the grid
        0710:   7C 7B                       CALF    0C7B	;Write "PUZZLE"
        0712:   05 89 00                    ANIW    89,00
        0715:   69 60                       MVI     A,60
        0717:   38 8A                       STAW    8A
        0719:   80                          CALT    0080	;[PC+1] Check Cartridge
        071A:   C1                          .DB	$C1		;Jump to ($4003) in cartridge
;------------------------------------------------------------
        071B:   6A 0B                       MVI     B,0B
        071D:   34 52 C7                    LXI     H,C752
        0720:   24 F2 C7                    LXI     D,C7F2
        0723:   95                          CALT    00AA	; "((HL+) ==> (DE+))xB"
        0724:   6A 11                       MVI     B,11
        0726:   34 5D 05                    LXI     H,055D      ;Point to "grid" data
        0729:   2D                          LDAX    H+
        072A:   48 1E                       PUSH    B
        072C:   48 3E                       PUSH    H
        072E:   7D D3                       CALF    0DD3        ;This probably draws the tiles
        0730:   00                          NOP                 ;Or randomizes them??
        0731:   48 3F                       POP     H
        0733:   48 1F                       POP     B
        0735:   52                          DCR     B
        0736:   F2                          JR      0729
        0737:   6A 0B                       MVI     B,0B        
        0739:   7E 67                       CALF    0E67        ;LXI H,$C7F2
        073B:   24 52 C7                    LXI     D,C752
        073E:   95                          CALT    00AA	; "((HL+) ==> (DE+))xB"
        073F:   84                          CALT    0088	;Read Controller FF90-FF95
        0740:   65 93 01                    NEIW    93,01       ;Select
        0743:   45 95 01                    ONIW    95,01	;Select trigger
        0746:   C6                          JR      074D
        0747:   82                          CALT    0084	;[PC+2] Setup/Play Sound
        0748:   14 03                       .DB $14,$03
	074A:	54 D1 05                    JMP     05D1	;Go to Paint Program
        074D:   65 93 08                    NEIW    93,08	;Start
        0750:   45 95 08                    ONIW    95,08
        0753:   C4                          JR      0758
        0754:   82                          CALT    0084	;[PC+2] Setup/Play Sound
        0755:   16 03                       .DB $16,$03
        0757:   CD                          JR      0765
;------------------------------------------------------------
        0758:   75 8A 80                    EQIW    8A,80
        075B:   4F BC                       JRE     0719        ;Draw Tiles
        075D:   75 89 3C                    EQIW    89,3C
        0760:   4F B3                       JRE     0715	;Reset timer?
        0762:   54 7F 05                    JMP     057F        ;Go back to startup screen(?)
;------------------------------------------------------------
        0765:   86                          CALT    008C	; "Clear Screen 2 RAM"
        0766:   34 53 05                    LXI     H,0553      ;"TIME"
        0769:   9B                          CALT    00B6	; "[PC+3] Print Text on-Screen"
        076A:   0E 00 1A                    .DB $0E,$00,$1A
        076D:   34 86 FF                    LXI     H,FF86
        0770:   6A 02                       MVI     B,02
        0772:   8A                          CALT    0094	; "Clear RAM (HL+)xB"
        0773:   28 8C                       LDAW    8C
        0775:   07 0F                       ANI     A,0F
        0777:   1A                          MOV     B,A
        0778:   34 6F 05                    LXI     H,056F
        077B:   2D                          LDAX    H+
        077C:   48 1E                       PUSH    B
        077E:   48 3E                       PUSH    H
        0780:   7D D3                       CALF    0DD3	;Draw Tiles
        0782:   00                          NOP
        0783:   48 3F                       POP     H
        0785:   48 1F                       POP     B
        0787:   52                          DCR     B
        0788:   F2                          JR      077B
        0789:   7D 68                       CALF    0D68        ;Draw Border (again)
        078B:   7D 92                       CALF    0D92        ;Draw the grid (again)
        078D:   7C 82                       CALF    0C82	;Scroll text? Write time in decimal?
        078F:   69 60                       MVI     A,60
        0791:   38 8A                       STAW    8A
        0793:   80                          CALT    0080	;[PC+1] Check Cartridge
        0794:   C1                          .DB	$C1		;Jump to ($4003) in cartridge
;------------------------------------------------------------
        0795:   34 86 FF                    LXI     H,FF86
        0798:   9A                          CALT    00B4	; "[PC+3] Print Bytes on-Screen"
        0799:   2C 00 12                    .DB	$2C,$00,$12
        079C:   34 88 FF                    LXI     H,FF88
        079F:   9A                          CALT    00B4	; "[PC+3] Print Bytes on-Screen"
        07A0:   44 00 08                    .DB	$44,$00,$08
        07A3:   90                          CALT    00A0	; "C258+ ==> C000+"
        07A4:   81                          CALT    0082	;Copy Screen RAM to LCD Driver
        07A5:   84                          CALT    0088	;Read Controller FF90-FF95
        07A6:   65 93 01                    NEIW    93,01       ;Select
        07A9:   4F 9C                       JRE     0747	;To Paint Program
        07AB:   65 93 08                    NEIW    93,08	;Start
        07AE:   45 95 08                    ONIW    95,08	;Start trigger
        07B1:   C2                          JR      07B4
        07B2:   4F A0                       JRE     0754        ;Restart puzzle
;------------------------------------------------------------
        07B4:   75 8A 80                    EQIW    8A,80
        07B7:   4F DA                       JRE     0793
        07B9:   28 92                       LDAW    92          ;Joypad
        07BB:   47 0F                       ONI     A,0F
        07BD:   4F D0                       JRE     078F        ;Keep looping
        07BF:   7D D3                       CALF    0DD3        ;Draw Tiles
        07C1:   C4                          JR      07C6
;------------------------------------------------------------
        07C2:   82                          CALT    0084	;[PC+2] Setup/Play Sound
        07C3:   01 03                       .DB	$01,$03
        07C5:   F7                          JR      07BD
;------------------------------------------------------------
        07C6:   48 0E                       PUSH    V
        07C8:   69 03                       MVI     A,03
        07CA:   38 99                       STAW    99
        07CC:   48 24                       DI  
        07CE:   78 B6                       CALF    08B6        ;Play Music (Snd)
        07D0:   48 20                       EI
        07D2:   34 FE C7                    LXI     H,C7FE
        07D5:   2D                          LDAX    H+
        07D6:   1A                          MOV     B,A
        07D7:   2F                          LDAX    H-
        07D8:   60 BA                       LTA     A,B
        07DA:   C2                          JR      07DD
        07DB:   1A                          MOV     B,A
        07DC:   2B                          LDAX    H
        07DD:   48 1E                       PUSH    B
        07DF:   75 A2 00                    EQIW    A2,00
        07E2:   4E 3F                       JRE     0823
        07E4:   7C BF                       CALF    0CBF        ;Write Text(?)
        07E6:   32                          INX     H
        07E7:   99                          CALT    00B2	; "[PC+2] Draw Horizontal Line"
        07E8:   00 8E                       .DB	$00,$8E
        07EA:   7C 77                       CALF    0C77        ;HL + $3C
        07EC:   48 3E                       PUSH    H
        07EE:   99                          CALT    00B2	; "[PC+2] Draw Horizontal Line"
        07EF:   F0 0E                       .DB	$F0,$0E
        07F1:   48 3F                       POP     H
        07F3:   99                          CALT    00B2	; "[PC+2] Draw Horizontal Line"
        07F4:   F0 8E                       .DB	$F0,$8E
        07F6:   7C 77                       CALF    0C77        ;HL + $3C
        07F8:   99                          CALT    00B2	; "[PC+2] Draw Horizontal Line"
        07F9:   1F 0F                       .DB	$1F,$0F
        07FB:   48 1F                       POP     B
        07FD:   0A                          MOV     A,B
        07FE:   7C BF                       CALF    0CBF        ;Write Text(?)
        0800:   99                          CALT    00B2	; "[PC+2] Draw Horizontal Line"
        0801:   F0 0F                       .DB	$F0,$0F
        0803:   7C 77                       CALF    0C77        ;HL + $3C
        0805:   48 3E                       PUSH    H
        0807:   99                          CALT    00B2	; "[PC+2] Draw Horizontal Line"
        0808:   0F 0E                       .DB	$0F,$0E
        080A:   48 3F                       POP     H
        080C:   99                          CALT    00B2	; "[PC+2] Draw Horizontal Line"
        080D:   0F 8E                       .DB	$0F,$0E
        080F:   6D 41                       MVI     E,41
        0811:   8D                          CALT    009A	; "HL <== HL+E"
        0812:   48 0F                       POP     V
        0814:   48 3E                       PUSH    H
        0816:   9C                          CALT    00B8	;Byte -> Point to Font Graphic
        0817:   48 2F                       POP     D
        0819:   6A 04                       MVI     B,04
        081B:   2D                          LDAX    H+
        081C:   48 30                       RAL
        081E:   3C                          STAX    D+
        081F:   52                          DCR     B
        0820:   FA                          JR      081B
        0821:   4E 52                       JRE     0875
;------------------------------------------------------------
        0823:   7C BF                       CALF    0CBF        ;Write Text(?)
        0825:   6A 07                       MVI     B,07
        0827:   32                          INX     H
        0828:   52                          DCR     B
        0829:   FD                          JR      0827
        082A:   69 01                       MVI     A,01
        082C:   38 A5                       STAW    A5
        082E:   99                          CALT    00B2	; "[PC+2] Draw Horizontal Line"
        082F:   E0 08                       .DB $E0,$08
        0831:   6D 42                       MVI     E,42
        0833:   8D                          CALT    009A	; "HL <== HL+E"
        0834:   99                          CALT    00B2	; "[PC+2] Draw Horizontal Line"
        0835:   FF 08                       .DB $FF,$08
        0837:   6D 42                       MVI     E,42
        0839:   8D                          CALT    009A	; "HL <== HL+E"
        083A:   99                          CALT    00B2	; "[PC+2] Draw Horizontal Line"
        083B:   1F 08                       .DB $1F,$08
        083D:   28 A5                       LDAW    A5
        083F:   51                          DCR     A
        0840:   C1                          JR      0842
        0841:   CA                          JR      084C

        0842:   38 A5                       STAW    A5
        0844:   48 1F                       POP     B
        0846:   0A                          MOV     A,B
        0847:   38 A2                       STAW    A2
        0849:   7C BF                       CALF    0CBF        ;Write Text(?)
        084B:   E2                          JR      082E

        084C:   28 A2                       LDAW    A2
        084E:   7C BF                       CALF    0CBF        ;Write Text(?)
        0850:   6D 09                       MVI     E,09
        0852:   8D                          CALT    009A	; "HL <== HL+E"
        0853:   99                          CALT    00B2	; "[PC+2] Draw Horizontal Line"
        0854:   1F 8E                       .DB $1F,$8E
        0856:   7C 77                       CALF    0C77        ;HL + $3C
        0858:   99                          CALT    00B2	; "[PC+2] Draw Horizontal Line"
        0859:   00 8E                       .DB $00,$8E
        085B:   7C 77                       CALF    0C77        ;HL + $3C
        085D:   99                          CALT    00B2	; "[PC+2] Draw Horizontal Line"
        085E:   F0 8E                       .DB $F0,$8E
        0860:   6A 54                       MVI     B,54        ;Decrement HL 55 times!
        0862:   33                          DCX     H		;Is this a delay or something?
        0863:   52                          DCR     B		;There's already a CALT that subs HL...
        0864:   FD                          JR      0862
        0865:   94                          CALT    00A8	; "XCHG HL,DE"
        0866:   48 0F                       POP     V
        0868:   48 2E                       PUSH    D
        086A:   9C                          CALT    00B8	;Byte -> Point to Font Graphic
        086B:   48 2F                       POP     D
        086D:   6A 04                       MVI     B,04
        086F:   2D                          LDAX    H+
        0870:   48 30                       RAL 
        0872:   3C                          STAX    D+
        0873:   52                          DCR     B
        0874:   FA                          JR      086F
        0875:   34 88 FF                    LXI     H,FF88
        0878:   9A                          CALT    00B4	; "[PC+3] Print Bytes on-Screen"
        0879:   44 00 08                    .DB $44,$00,$08
        087C:   90                          CALT    00A0	; "C258+ ==> C000+"
        087D:   81                          CALT    0082	;Copy Screen RAM to LCD Driver
        087E:   7D 68                       CALF    0D68        ;Draw Border
        0880:   7D 92                       CALF    0D92	;Draw Puzzle Grid
        0882:   7C 82                       CALF    0C82        ;Scroll text? Write time in decimal?
        0884:   6A 0B                       MVI     B,0B
        0886:   34 5E C7                    LXI     H,C75E
        0889:   24 F2 C7                    LXI     D,C7F2
        088C:   2D                          LDAX    H+
        088D:   70 FC                       EQAX    D+
        088F:   4F 34                       JRE     07C5
        0891:   52                          DCR     B
        0892:   F9                          JR      088C
        0893:   7E 64                       CALF    0E64	;Point HL to music data
        0895:   83                          CALT    0086	;Setup/Play Music
        0896:   45 80 03                    ONIW    80,03
        0899:   54 12 07                    JMP     0712        ;Continue puzzle
        089C:   F9                          JR      0896
;End of Puzzle Code
;------------------------------------------------------------
;Clear A
CALT 85 089D:   69 00                       MVI     A,00
        089F:   08                          RET
;------------------------------------------------------------
;XCHG HL,DE
CALT 94 08A0:   48 3E                       PUSH    H
        08A2:   48 2E                       PUSH    D
        08A4:   48 3F                       POP     H
        08A6:   48 2F                       POP     D
        08A8:   08                          RET
;------------------------------------------------------------
;Music-playing code...
CALF    08A9:   2D                          LDAX    H+
        08AA:   1A                          MOV     B,A
        08AB:   2D                          LDAX    H+
        08AC:   38 99                       STAW    99
        08AE:   70 3E 84 FF                 SHLD    FF84
        08B2:   0A                          MOV     A,B
        08B3:   41                          INR     A
        08B4:   C1                          JR      08B6
        08B5:   18                          RETS                ;Return & Skip if read "$FF"

;Move "note" into TM0
CALF    08B6:   34 78 02                    LXI     H,0278           ;Table Start
        08B9:   0A                          MOV     A,B
        08BA:   36 01                       SUINB   A,01
        08BC:   C3                          JR      08C0
        08BD:   32                          INX     H          ;Add A*2 to HL (wastefully)
        08BE:   32                          INX     H
        08BF:   FA                          JR      08BA

        08C0:   2D                          LDAX    H+
        08C1:   4D C6                       MOV     T0,A
        08C3:   2B                          LDAX    H
        08C4:   38 9A                       STAW    9A
        08C6:   38 8F                       STAW    8F
        08C8:   52                          DCR     B
        08C9:   69 00                       MVI     A,00       ;Sound?
        08CB:   69 03                       MVI     A,03       ;Silent
        08CD:   4D C9                       MOV     TMM,A
        08CF:   15 80 01                    ORIW    80,01
        08D2:   19                          STM
        08D3:   08                          RET
;------------------------------------------------------------
;Load a "multiplication table" for A,E from (HL) and do AxE
;Is this ever used?
        08D4:   2D                          LDAX    H+
        08D5:   1D                          MOV     E,A
        08D6:   2B                          LDAX    H
;HL <== AxE
CALT 93 08D7:   34 00 00                    LXI     H,0000
        08DA:   6C 00                       MVI     D,00
        08DC:   27 00                       GTI     A,00
        08DE:   08                          RET
        08DF:   48 2A                       CLC
        08E1:   48 31                       RLR
        08E3:   48 0E                       PUSH    V
        08E5:   48 1A                       SKN     CY
        08E7:   8B                          CALT    0096	; "HL <== HL+DE"
        08E8:   0D                          MOV     A,E
        08E9:   60 C1                       ADD     A,A
        08EB:   1D                          MOV     E,A
        08EC:   0C                          MOV     A,D
        08ED:   48 30                       RAL
        08EF:   1C                          MOV     D,A
        08F0:   48 0F                       POP     V
        08F2:   E9                          JR      08DC
;-----------------------------
;((HL+) <==> (DE+))xB
;This function swaps the contents of (HL)<->(DE) B times
CALT 97 08F3:   78 F8                       CALF    08F8	;Swap (HL+)<->(DE+)
        08F5:   52                          DCR     B
        08F6:   FC                          JR      08F3
        08F7:   08                          RET
;------------------------------------------------------------
;Swap (HL+)<->(DE+)
CALF    08F8:   2B                          LDAX    H
        08F9:   1B                          MOV     C,A
        08FA:   2A                          LDAX    D
        08FB:   3D                          STAX    H+
        08FC:   0B                          MOV     A,C
        08FD:   3C                          STAX    D+
        08FE:   08                          RET
;------------------------------------------------------------
;Clear Screen 2 RAM
CALT 86 08FF:   34 58 C2                    LXI     H,C258	;RAM for screen 2
;Clear Screen RAM
CALT 87 0902:   34 00 C0                    LXI     H,C000	;RAM for screen 1
        0905:   6B 02                       MVI     C,02
        0907:   6A C7                       MVI     B,C7        ;$C8 bytes * 3 loops
        0909:   8A                          CALT    0094	; "Clear RAM (HL+)xB"
        090A:   53                          DCR     C
        090B:   FB                          JR      0907
        090C:   08                          RET
;------------------------------------------------------------
;Clear C594~C7FF
CALT 89 090D:   34 94 C5                    LXI     H,C594	;Set HL
        0910:   79 05                       CALF    0905	;And jump to above routine
        0912:   6A 13                       MVI     B,13        ;Then clear $14 more bytes
        0914:   C5                          JR      091A	;Clear RAM (HL+)xB

;Clear C4B0~C593
CALT 88 0915:   34 B0 C4                    LXI     H,C4B0      ;Set RAM pointer
        0918:   6A E3                       MVI     B,E3	;and just drop into the func.

;Clear RAM (HL+)xB
CALT 8A 091A:   85                          CALT    008A	; "Clear A"
;A ==> (HL+)xB
CALT 9F 091B:   3D                          STAX    H+
        091C:   52                          DCR     B
        091D:   FD                          JR      091B
        091E:   08                          RET
;------------------------------------------------------------
;Read Controller FF90-FF95
CALT 84 091F:   34 92 FF                    LXI     H,FF92      ;Current joy storage
        0922:   24 90 FF                    LXI     D,FF90      ;Old joy storage
        0925:   6A 01                       MVI     B,01        ;Copy 2 bytes from curr->old
        0927:   95                          CALT    00AA	; "((HL+) ==> (DE+))xB"
        0928:   64 88 BF                    ANI     PA,BF       ;PA Bit 6 off
        092B:   4C C2                       MOV     A,PC	;Get port C
        092D:   16 FF                       XRI     A,FF
        092F:   1B                          MOV     C,A
        0930:   6A 40                       MVI     B,40	;Debouncing delay
        0932:   52                          DCR     B
        0933:   FE                          JR      0932
        0934:   4C C2                       MOV     A,PC	;Get port C a 2nd time
        0936:   16 FF                       XRI     A,FF
        0938:   60 FB                       EQA     A,C		;Check if both reads are equal
        093A:   F4                          JR      092F
        093B:   64 98 40                    ORI     PA,40	;PA Bit 6 on
        093E:   07 03                       ANI     A,03
        0940:   3C                          STAX    D+		;Save controller read in 92
        0941:   0B                          MOV     A,C
        0942:   7C 72                       CALF    0C72	;RLR A x2
        0944:   07 07                       ANI     A,07
        0946:   3E                          STAX    D-		;Save cont in 93
        0947:   64 88 7F                    ANI     PA,7F	;PA bit 7 off
        094A:   4C C2                       MOV     A,PC	;Get other controller bits
        094C:   16 FF                       XRI     A,FF
        094E:   1B                          MOV     C,A
        094F:   6A 40                       MVI     B,40	;...and debounce
        0951:   52                          DCR     B
        0952:   FE                          JR      0951
        0953:   4C C2                       MOV     A,PC
        0955:   16 FF                       XRI     A,FF
        0957:   60 FB                       EQA     A,C		;...check again
        0959:   F4                          JR      094E
        095A:   64 98 80                    ORI     PA,80       ;PA bit 7 on
        095D:   48 30                       RAL
        095F:   48 30                       RAL
        0961:   07 0C                       ANI     A,0C
        0963:   70 9A                       ORAX    D		;Or with FF92
        0965:   3C                          STAX    D+          ;...and save
        0966:   0B                          MOV     A,C
        0967:   48 30                       RAL 
        0969:   07 38                       ANI     A,38
        096B:   70 9A                       ORAX    D           ;Or with FF93
        096D:   3E                          STAX    D-		;...and save
        096E:   34 90 FF                    LXI     H,FF90      ;Get our new,old
        0971:   14 94 FF                    LXI     B,FF94
        0974:   2D                          LDAX    H+          ;And XOR to get controller strobe
        0975:   70 94                       XRAX    D+		;But this strobe function is stupid:
        0977:   39                          STAX    B           ;Bits go to 1 whenever the button is
        0978:   12                          INX     B		;initially pressed AND released...
        0979:   2B                          LDAX    H
        097A:   70 92                       XRAX    D
        097C:   39                          STAX    B
        097D:   08                          RET
;------------------------------------------------------------
;C258+ ==> C000+
CALT 90 097E:   7E 5E                       CALF    0E5E
        0980:   C3                          JR      0984
;C000+ ==> C258+
CALT 8F 0981:   7E 5E                       CALF    0E5E
        0983:   94                          CALT    00A8	; "XCHG HL,DE"
        0984:   6B 02                       MVI     C,02
        0986:   6A C7                       MVI     B,C7
        0988:   95                          CALT    00AA	; "((HL+) ==> (DE+))xB"
        0989:   53                          DCR     C
        098A:   FB                          JR      0986
        098B:   08                          RET     
;------------------------------------------------------------
;Swap C258+ <==> C000+
CALT 8E 098C:   7E 5E                       CALF    0E5E
        098E:   14 02 C7                    LXI     B,C702
        0991:   48 1E                       PUSH    B
        0993:   97                          CALT    00AE	; "((HL+) <==> (DE+))xB"
        0994:   48 1F                       POP     B
        0996:   53                          DCR     C
        0997:   F9                          JR      0991
        0998:   08                          RET
;------------------------------------------------------------
;Set Dot; B,C = X-,Y-position
;(Oddly enough, this writes dots to the 2nd screen RAM area!)
CALT 98 0999:   48 1E                       PUSH    B
        099B:   7B F4                       CALF    0BF4       ;Point to 2nd screen
        099D:   48 1F                       POP     B
        099F:   0B                          MOV     A,C
        09A0:   07 07                       ANI     A,07
        09A2:   1B                          MOV     C,A
        09A3:   85                          CALT    008A	; "Clear A"
        09A4:   48 2B                       STC
        09A6:   48 30                       RAL
        09A8:   53                          DCR     C
        09A9:   FC                          JR      09A6
        09AA:   70 9B                       ORAX    H
        09AC:   D8                          JR      09C5
;------------------------------------------------------------
CALF    09AD:   75 D8 00                    EQIW    D8,00       ;"Invert Dot", then...
        09B0:   E8                          JR      0999

;Clear Dot; B,C = X-,Y-position
CALT AD 09B1:   48 1E                       PUSH    B
        09B3:   7B F4                       CALF    0BF4        ;Point to 2nd screen
        09B5:   48 1F                       POP     B
        09B7:   0B                          MOV     A,C
        09B8:   07 07                       ANI     A,07
        09BA:   1B                          MOV     C,A
        09BB:   69 FF                       MVI     A,FF
        09BD:   48 2A                       CLC
        09BF:   48 30                       RAL
        09C1:   53                          DCR     C
        09C2:   FC                          JR      09BF
        09C3:   70 8B                       ANAX    H
        09C5:   3B                          STAX    H
        09C6:   08                          RET
;------------------------------------------------------------
;[PC+2] Draw Horizontal Line
; 1st byte is the bit-pattern (of the 8-dot vertical "char" of the LCD)
; 2nd byte is the length: 00-7F draws black lines; 80-FF draws white lines
CALT 99 09C7:   48 2F                       POP     D
        09C9:   2C                          LDAX    D+  	;SP+1
        09CA:   1B                          MOV     C,A
        09CB:   2C                          LDAX    D+		;SP+2
        09CC:   48 2E                       PUSH    D
        09CE:   1C                          MOV     D,A
        09CF:   07 7F                       ANI     A,7F
        09D1:   1A                          MOV     B,A
        09D2:   0C                          MOV     A,D
        09D3:   47 80                       ONI     A,80
        09D5:   C7                          JR      09DD

        09D6:   2B                          LDAX    H
        09D7:   60 8B                       ANA     A,C
        09D9:   3D                          STAX    H+
        09DA:   52                          DCR     B
        09DB:   FA                          JR      09D6
        09DC:   08                          RET

        09DD:   2B                          LDAX    H
        09DE:   60 9B                       ORA     A,C
        09E0:   3D                          STAX    H+
        09E1:   52                          DCR     B
        09E2:   FA                          JR      09DD
        09E3:   08                          RET
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
CALT 9A 09E4:   48 2F                       POP     D
        09E6:   2C                          LDAX    D+
        09E7:   1A                          MOV     B,A
        09E8:   38 9B                       STAW    9B
        09EA:   2C                          LDAX    D+
        09EB:   1B                          MOV     C,A
        09EC:   07 07                       ANI     A,07
        09EE:   38 9C                       STAW    9C
        09F0:   2C                          LDAX    D+
        09F1:   48 2E                       PUSH    D
        09F3:   38 9D                       STAW    9D
        09F5:   07 07                       ANI     A,07
        09F7:   41                          INR     A
        09F8:   48 1E                       PUSH    B
        09FA:   38 98                       STAW    98
        09FC:   24 A8 FF                    LXI     D,FFA8
        09FF:   70 2E C0 FF                 SDED    FFC0
        0A03:   1A                          MOV     B,A
        0A04:   6B 40                       MVI     C,40
        0A06:   45 9D 40                    ONIW    9D,40
        0A09:   6B 10                       MVI     C,10
        0A0B:   45 9D 08                    ONIW    9D,08
        0A0E:   CA                          JR      0A19
        0A0F:   52                          DCR     B
        0A10:   C1                          JR      0A12
        0A11:   D1                          JR      0A23

        0A12:   2B                          LDAX    H
        0A13:   A0                          CALT    00C0	; "(RLR A)x4"
        0A14:   07 0F                       ANI     A,0F
        0A16:   60 9B                       ORA     A,C
        0A18:   3C                          STAX    D+
        0A19:   52                          DCR     B
        0A1A:   C1                          JR      0A1C
        0A1B:   C7                          JR      0A23

        0A1C:   2D                          LDAX    H+
        0A1D:   07 0F                       ANI     A,0F
        0A1F:   60 9B                       ORA     A,C
        0A21:   3C                          STAX    D+
        0A22:   EC                          JR      0A0F

        0A23:   48 1F                       POP     B
        0A25:   05 9D BF                    ANIW    9D,BF
        0A28:   D9                          JR      0A42
;-----------------------------------------------------------
;[PC+3] Print Text on-Screen
;This prints a text string (pointed to by HL) anywhere on-screen.
;1st byte (after the call) is X-position, 2nd byte is Y-position.
;3rd byte sets a few options:
; bit: 76543210			S = write to screen 1/0
;      Sbbb####		      bbb = blank space between digits (0..7)
;			     #### = 1..F nybbles to write
;
CALT 9B 0A29:   48 2F                       POP     D
        0A2B:   2C                          LDAX    D+
        0A2C:   1A                          MOV     B,A
        0A2D:   38 9B                       STAW    9B
        0A2F:   2C                          LDAX    D+
        0A30:   1B                          MOV     C,A         ;Save X,Y position in BC
        0A31:   07 07                       ANI     A,07
        0A33:   38 9C                       STAW    9C
        0A35:   2C                          LDAX    D+
        0A36:   48 2E                       PUSH    D
        0A38:   38 9D                       STAW    9D
        0A3A:   07 0F                       ANI     A,0F        ;Get # of characters to write
        0A3C:   70 3E C0 FF                 SHLD    FFC0
        0A40:   38 98                       STAW    98  	;# saved in 98
        0A42:   28 9D                       LDAW    9D
        0A44:   47 80                       ONI     A,80	;Check if 0 (2nd screen) or 1 (1st screen)
        0A46:   C2                          JR      0A49
        0A47:   9D                          CALT    00BA	; "Set HL to screen (B,C)"
        0A48:   C2                          JR      0A4B

        0A49:   7B F4                       CALF    0BF4        ;This points to Sc 1
        0A4B:   70 7B C6 FF                 MOV     FFC6,C
        0A4F:   70 3E C2 FF                 SHLD    FFC2
        0A53:   24 4B 00                    LXI     D,004B
        0A56:   8B                          CALT    0096	; "HL <== HL+DE"
        0A57:   70 3E C4 FF                 SHLD    FFC4
        0A5B:   28 9D                       LDAW    9D
        0A5D:   A0                          CALT    00C0	; "(RLR A)x4"
        0A5E:   07 07                       ANI     A,07	;Get text spacing (0-7)
        0A60:   38 9D                       STAW    9D		;Save in 9D
;--
        0A62:   30 98                       DCRW    98		;The loop starts here
        0A64:   C1                          JR      0A66
        0A65:   08                          RET

        0A66:   45 C6 FF                    ONIW    C6,FF
        0A69:   DB                          JR      0A85
        0A6A:   70 3F C2 FF                 LHLD    FFC2
        0A6E:   70 3E C7 FF                 SHLD    FFC7
        0A72:   24 B0 FF                    LXI     D,FFB0
        0A75:   6A 04                       MVI     B,04
        0A77:   7B D3                       CALF    0BD3
        0A79:   57 80                       OFFI    A,80
        0A7B:   C9                          JR      0A85
        0A7C:   70 2F 9D FF                 LDED    FF9D
        0A80:   8D                          CALT    009A	; "HL <== HL+E"
        0A81:   70 3E C2 FF                 SHLD    FFC2
        0A85:   70 3F C4 FF                 LHLD    FFC4
        0A89:   70 3E C9 FF                 SHLD    FFC9
        0A8D:   24 B5 FF                    LXI     D,FFB5
        0A90:   6A 04                       MVI     B,04
        0A92:   7B D3                       CALF    0BD3	;Copy B*A bytes?
        0A94:   57 80                       OFFI    A,80
        0A96:   C9                          JR      0AA0
        0A97:   70 2F 9D FF                 LDED    FF9D
        0A9B:   8D                          CALT    009A	; "HL <== HL+E"
        0A9C:   70 3E C4 FF                 SHLD    FFC4
        0AA0:   70 6A 9C FF                 MOV     B,FF9C
        0AA4:   85                          CALT    008A	; "Clear A"
        0AA5:   52                          DCR     B
        0AA6:   C1                          JR      0AA8
        0AA7:   C5                          JR      0AAD

        0AA8:   48 2B                       STC
        0AAA:   48 30                       RAL
        0AAC:   F8                          JR      0AA5

        0AAD:   48 0E                       PUSH    V
        0AAF:   1B                          MOV     C,A
        0AB0:   7E 6A                       CALF    0E6A	;(FFB0 -> HL)
        0AB2:   6A 04                       MVI     B,04
        0AB4:   2B                          LDAX    H
        0AB5:   60 8B                       ANA     A,C
        0AB7:   3D                          STAX    H+
        0AB8:   52                          DCR     B
        0AB9:   FA                          JR      0AB4
        0ABA:   48 0F                       POP     V
        0ABC:   16 FF                       XRI     A,FF
        0ABE:   1B                          MOV     C,A
        0ABF:   6A 04                       MVI     B,04
        0AC1:   2B                          LDAX    H
        0AC2:   60 8B                       ANA     A,C
        0AC4:   3D                          STAX    H+
        0AC5:   52                          DCR     B
        0AC6:   FA                          JR      0AC1
        0AC7:   70 3F C0 FF                 LHLD    FFC0
        0ACB:   2D                          LDAX    H+
        0ACC:   70 3E C0 FF                 SHLD    FFC0
        0AD0:   9C                          CALT    00B8	;Byte -> Point to Font Graphic
        0AD1:   24 B0 FF                    LXI     D,FFB0
        0AD4:   14 B5 FF                    LXI     B,FFB5
        0AD7:   69 04                       MVI     A,04
        0AD9:   15 80 08                    ORIW    80,08
        0ADC:   7C 31                       CALF    0C31	;Roll graphics a bit (shift up/dn)
        0ADE:   45 C6 FF                    ONIW    C6,FF
        0AE1:   CD                          JR      0AEF
        0AE2:   70 2F C7 FF                 LDED    FFC7
        0AE6:   7E 6A                       CALF    0E6A	;(FFB0 -> HL)
        0AE8:   6A 04                       MVI     B,04
        0AEA:   15 80 10                    ORIW    80,10
        0AED:   7B D3                       CALF    0BD3	;Copy B*A bytes?
        0AEF:   55 C6 08                    OFFIW   C6,08
        0AF2:   CE                          JR      0B01
        0AF3:   70 2F C9 FF                 LDED    FFC9
        0AF7:   34 B5 FF                    LXI     H,FFB5
        0AFA:   6A 04                       MVI     B,04
        0AFC:   15 80 10                    ORIW    80,10
        0AFF:   7B D3                       CALF    0BD3	;Copy B*A bytes?
        0B01:   28 9B                       LDAW    9B
        0B03:   46 05                       ADI     A,05
        0B05:   1A                          MOV     B,A
        0B06:   28 9D                       LDAW    9D
        0B08:   60 C2                       ADD     A,B
        0B0A:   38 9B                       STAW    9B
        0B0C:   4F 54                       JRE     0A62
;------------------------------------------------------------
;Byte -> Point to Font Graphic
CALT 9C 0B0E:   37 64                       LTI     A,64	;If it's greater than 64, use cart font
        0B10:   C4                          JR      0B15        ;or...
        0B11:   24 C4 02                    LXI     D,02C4      ;Point to built-in font
        0B14:   C6                          JR      0B1B

        0B15:   70 2F 05 40                 LDED    4005       ;4005-6 on cart is the font pointer
        0B19:   66 64                       SUI     A,64
        0B1B:   70 2E 96 FF                 SDED    FF96
        0B1F:   1B                          MOV     C,A
        0B20:   07 0F                       ANI     A,0F
        0B22:   6D 05                       MVI     E,05
        0B24:   93                          CALT    00A6	; "Add A to "Pointer""
        0B25:   48 3E                       PUSH    H
        0B27:   0B                          MOV     A,C
        0B28:   A0                          CALT    00C0	; "(RLR A)x4"
        0B29:   07 0F                       ANI     A,0F
        0B2B:   6D 50                       MVI     E,50
        0B2D:   93                          CALT    00A6	; "Add A to "Pointer""
        0B2E:   48 2F                       POP     D
        0B30:   8B                          CALT    0096	; "HL <== HL+DE"
        0B31:   70 2F 96 FF                 LDED    FF96
        0B35:   8B                          CALT    0096	; "HL <== HL+DE"
        0B36:   08                          RET
;------------------------------------------------------------
;?? (Move some RAM around...)
CALT 92 0B37:   34 91 C5                    LXI     H,C591
        0B3A:   6A 0B                       MVI     B,0B

        0B3C:   48 3E                       PUSH    H
        0B3E:   48 1E                       PUSH    B
        0B40:   7B 4C                       CALF    0B4C
        0B42:   48 1F                       POP     B
        0B44:   48 3F                       POP     H
        0B46:   33                          DCX     H
        0B47:   33                          DCX     H
        0B48:   33                          DCX     H
        0B49:   52                          DCR     B
        0B4A:   F1                          JR      0B3C
        0B4B:   08                          RET
;------------------------------------------------------------
CALF    0B4C:   2D                          LDAX    H+
        0B4D:   38 9B                       STAW    9B
        0B4F:   1A                          MOV     B,A
        0B50:   46 07                       ADI     A,07
        0B52:   37 53                       LTI     A,53
        0B54:   08                          RET
        0B55:   2D                          LDAX    H+
        0B56:   1B                          MOV     C,A
        0B57:   07 07                       ANI     A,07
        0B59:   38 9C                       STAW    9C
        0B5B:   0B                          MOV     A,C
        0B5C:   46 07                       ADI     A,07
        0B5E:   37 47                       LTI     A,47
        0B60:   08                          RET
        0B61:   2B                          LDAX    H
        0B62:   38 9D                       STAW    9D
        0B64:   37 0C                       LTI     A,0C
        0B66:   08                          RET
        0B67:   9D                          CALT    00BA	; "Set HL to screen (B,C)"
        0B68:   70 3E 9E FF                 SHLD    FF9E
        0B6C:   0E                          MOV     A,H
        0B6D:   47 40                       ONI     A,40
        0B6F:   C5                          JR      0B75
        0B70:   24 B0 FF                    LXI     D,FFB0
        0B73:   7B D1                       CALF    0BD1
        0B75:   70 3F 9E FF                 LHLD    FF9E
        0B79:   24 4B 00                    LXI     D,004B
        0B7C:   8B                          CALT    0096	; "HL <== HL+DE"
        0B7D:   48 3E                       PUSH    H
        0B7F:   24 B8 FF                    LXI     D,FFB8
        0B82:   7B D1                       CALF    0BD1
        0B84:   7E 6A                       CALF    0E6A
        0B86:   24 C0 FF                    LXI     D,FFC0
        0B89:   6A 0F                       MVI     B,0F
        0B8B:   95                          CALT    00AA	; "((HL+) ==> (DE+))xB"
        0B8C:   28 9D                       LDAW    9D
        0B8E:   9E                          CALT    00BC	; "HL=C4B0+(A*$10)"
        0B8F:   24 B0 FF                    LXI     D,FFB0
        0B92:   14 B8 FF                    LXI     B,FFB8
        0B95:   7C 2F                       CALF    0C2F
        0B97:   48 3E                       PUSH    H
        0B99:   7E 6A                       CALF    0E6A
        0B9B:   24 C0 FF                    LXI     D,FFC0
        0B9E:   6A 0F                       MVI     B,0F
        0BA0:   2B                          LDAX    H
        0BA1:   70 94                       XRAX    D+
        0BA3:   3D                          STAX    H+
        0BA4:   52                          DCR     B
        0BA5:   FA                          JR      0BA0
        0BA6:   48 3F                       POP     H
        0BA8:   15 80 08                    ORIW    80,08
        0BAB:   24 B0 FF                    LXI     D,FFB0
        0BAE:   14 B8 FF                    LXI     B,FFB8
        0BB1:   7C 2F                       CALF    0C2F
        0BB3:   70 2F 9E FF                 LDED    FF9E
        0BB7:   0C                          MOV     A,D
        0BB8:   47 40                       ONI     A,40
        0BBA:   C7                          JR      0BC2
        0BBB:   7E 6A                       CALF    0E6A
        0BBD:   15 80 10                    ORIW    80,10
        0BC0:   7B D1                       CALF    0BD1
        0BC2:   48 2F                       POP     D
        0BC4:   34 A8 3D                    LXI     H,3DA8
        0BC7:   8B                          CALT    0096	; "HL <== HL+DE"
        0BC8:   48 1A                       SKN     CY
        0BCA:   08                          RET
        0BCB:   34 B8 FF                    LXI     H,FFB8
        0BCE:   15 80 10                    ORIW    80,10
;--
        0BD1:   6A 07                       MVI     B,07
        0BD3:   28 9B                       LDAW    9B
        0BD5:   57 80                       OFFI    A,80
        0BD7:   CA                          JR      0BE2
        0BD8:   37 4B                       LTI     A,4B
        0BDA:   D2                          JR      0BED
        0BDB:   48 0E                       PUSH    V
        0BDD:   2D                          LDAX    H+
        0BDE:   3C                          STAX    D+
        0BDF:   48 0F                       POP     V
        0BE1:   C7                          JR      0BE9
        0BE2:   45 80 10                    ONIW    80,10
        0BE5:   C2                          JR      0BE8
        0BE6:   32                          INX     H
        0BE7:   C1                          JR      0BE9

        0BE8:   22                          INX     D
        0BE9:   41                          INR     A
        0BEA:   00                          NOP
        0BEB:   52                          DCR     B
        0BEC:   E8                          JR      0BD5
        0BED:   05 80 EF                    ANIW    80,EF
        0BF0:   08                          RET
;------------------------------------------------------------
;Set HL to screen (B,C)
CALT 9D 0BF1:   34 B5 BF                    LXI     H,BFB5	;Point before Sc. RAM
        0BF4:   34 0D C2                    LXI     H,C20D	;Point before Sc.2 RAM
        0BF7:   6D 4B                       MVI     E,4B
        0BF9:   0B                          MOV     A,C
        0BFA:   6B 00                       MVI     C,00
        0BFC:   46 08                       ADI     A,08
        0BFE:   36 08                       SUINB   A,08
        0C00:   C7                          JR      0C08
        0C01:   48 0E                       PUSH    V
        0C03:   8D                          CALT    009A	; "HL <== HL+E"
        0C04:   48 0F                       POP     V
        0C06:   43                          INR     C
        0C07:   F6                          JR      0BFE
        0C08:   0A                          MOV     A,B
        0C09:   57 80                       OFFI    A,80
        0C0B:   08                          RET     
        0C0C:   1D                          MOV     E,A
        0C0D:   CA                          JR      0C18
;------------------------------------------------------------
;[PC+1] HL +- byte
CALT 8C 0C0E:   48 2F                       POP     D
        0C10:   2C                          LDAX    D+          ;Get byte after PC
        0C11:   48 2E                       PUSH    D
        0C13:   1D                          MOV     E,A
        0C14:   37 80                       LTI     A,80	;Add or subtract that byte
        0C16:   69 FF                       MVI     A,FF
;HL <== HL+E
CALT 8D 0C18:   69 00                       MVI     A,00
        0C1A:   1C                          MOV     D,A
;HL <== HL+DE
CALT 8B 0C1B:   0D                          MOV     A,E
        0C1C:   60 C7                       ADD     A,L
        0C1E:   1F                          MOV     L,A
        0C1F:   0C                          MOV     A,D
        0C20:   60 D6                       ADC     A,H
        0C22:   1E                          MOV     H,A
        0C23:   08                          RET
;------------------------------------------------------------
;HL=C4B0+(A*$10)
CALT 9E 0C24:   34 B0 C4                    LXI     H,C4B0
        0C27:   6D 10                       MVI     E,10
        0C29:   1A                          MOV     B,A
        0C2A:   52                          DCR     B
        0C2B:   C1                          JR      0C2D
        0C2C:   08                          RET

        0C2D:   8D                          CALT    009A	; "HL <== HL+E"
        0C2E:   FB                          JR      0C2A
;------------------------------------------------------------
CALF    0C2F:   69 07                       MVI     A,07
        0C31:   38 96                       STAW    96

        0C33:   28 9C                       LDAW    9C
        0C35:   38 97                       STAW    97
        0C37:   48 1E                       PUSH    B
        0C39:   6B 00                       MVI     C,00
        0C3B:   2D                          LDAX    H+
        0C3C:   30 97                       DCRW    97
        0C3E:   C1                          JR      0C40
        0C3F:   CD                          JR      0C4D

        0C40:   48 2A                       CLC
        0C42:   48 30                       RAL
        0C44:   48 0E                       PUSH    V
        0C46:   0B                          MOV     A,C
        0C47:   48 30                       RAL
        0C49:   1B                          MOV     C,A
        0C4A:   48 0F                       POP     V
        0C4C:   EF                          JR      0C3C

        0C4D:   45 80 08                    ONIW    80,08
        0C50:   C3                          JR      0C54
        0C51:   70 9A                       ORAX    D
        0C53:   C2                          JR      0C56

        0C54:   70 8A                       ANAX    D
        0C56:   3A                          STAX    D
        0C57:   0B                          MOV     A,C
        0C58:   48 1F                       POP     B
        0C5A:   45 80 08                    ONIW    80,08
        0C5D:   C3                          JR      0C61
        0C5E:   70 99                       ORAX    B
        0C60:   C2                          JR      0C63

        0C61:   70 89                       ANAX    B
        0C63:   39                          STAX    B
        0C64:   12                          INX     B
        0C65:   22                          INX     D
        0C66:   30 96                       DCRW    96
        0C68:   4F C9                       JRE     0C33
        0C6A:   05 80 F7                    ANIW    80,F7
        0C6D:   08                          RET
;------------------------------------------------------------
;(RLR A)x4	(Divides A by 16)
CALT A0 0C6E:   48 31                       RLR
        0C70:   48 31                       RLR
CALF    0C72:   48 31                       RLR
        0C74:   48 31                       RLR
        0C76:   08                          RET
;------------------------------------------------------------
CALF    0C77:   6D 3C                       MVI     E,3C	; 60 decimal...
        0C79:   8D                          CALT    009A	; "HL <== HL+E"
        0C7A:   08                          RET
;------------------------------------------------------------
CALF    0C7B:   34 4D 05                    LXI     H,054D      ;"PUZZLE"
        0C7E:   9B                          CALT    00B6	; "[PC+3] Print Text on-Screen"
        0C7F:   03 00 16		    .DB $03,$00,$16
        0C82:   7E 67                       CALF    0E67	;(C7F2 -> HL)
        0C84:   69 01                       MVI     A,01
        0C86:   38 83                       STAW    83
        0C88:   2D                          LDAX    H+
        0C89:   48 3E                       PUSH    H
        0C8B:   67 FF                       NEI     A,FF	;If it's a terminator, loop
        0C8D:   4E 27                       JRE     0CB6
        0C8F:   9C                          CALT    00B8	;Byte -> Point to Font Graphic
        0C90:   94                          CALT    00A8	; "XCHG HL,DE"
        0C91:   28 83                       LDAW    83
        0C93:   7C BF                       CALF    0CBF        ;(Scroll text)
        0C95:   48 2E                       PUSH    D
        0C97:   6D 51                       MVI     E,51
        0C99:   8D                          CALT    009A	; "HL <== HL+E"
        0C9A:   48 2F                       POP     D
        0C9C:   6A 04                       MVI     B,04
        0C9E:   2C                          LDAX    D+
        0C9F:   48 30                       RAL
        0CA1:   3D                          STAX    H+
        0CA2:   52                          DCR     B
        0CA3:   FA                          JR      0C9E
        0CA4:   20 83                       INRW    83
        0CA6:   48 3F                       POP     H
        0CA8:   75 83 0D                    EQIW    83,0D
        0CAB:   4F DB                       JRE     0C88
        0CAD:   34 FF C7                    LXI     H,C7FF
        0CB0:   2B                          LDAX    H
        0CB1:   7E 3B                       CALF    0E3B	;Scroll text; XOR RAM
        0CB3:   90                          CALT    00A0	; "C258+ ==> C000+"
        0CB4:   81                          CALT    0082	;Copy Screen RAM to LCD Driver
        0CB5:   08                          RET
;------------------------------------------------------------
        0CB6:   70 69 83 FF                 MOV     A,FF83	;A "LDAW 83" would've been faster here...
        0CBA:   70 79 FF C7                 MOV     C7FF,A
        0CBE:   E5                          JR      0CA4
;------------------------------------------------------------
CALF    0CBF:   37 09                       LTI     A,09
        0CC1:   D0                          JR      0CD2
        0CC2:   37 05                       LTI     A,05
        0CC4:   D3                          JR      0CD8
        0CC5:   34 D8 C2                    LXI     H,C2D8
        0CC8:   67 04                       NEI     A,04
        0CCA:   08                          RET
        0CCB:   6A 0F                       MVI     B,0F
        0CCD:   33                          DCX     H
        0CCE:   52                          DCR     B
        0CCF:   FD                          JR      0CCD
        0CD0:   41                          INR     A
        0CD1:   F6                          JR      0CC8
        0CD2:   34 04 C4                    LXI     H,C404
        0CD5:   66 08                       SUI     A,08
        0CD7:   F0                          JR      0CC8
;------------------------------------------------------------
        0CD8:   34 6E C3                    LXI     H,C36E
        0CDB:   66 04                       SUI     A,04
        0CDD:   EA                          JR      0CC8
;------------------------------------------------------------
        0CDE:   34 B8 04                    LXI     H,04B8	;Point to scroll text
        0CE1:   D8                          JR      0CFA
;------------------------------------------------------------
CALF	;Slide the top line for the scroller.
        0CE2:   20 82                       INRW    82
        0CE4:   00                          NOP
        0CE5:   34 5B C2                    LXI     H,C25B
        0CE8:   24 58 C2                    LXI     D,C258
        0CEB:   6A 47                       MVI     B,47
        0CED:   95                          CALT    00AA	; "((HL+) ==> (DE+))xB"
        0CEE:   55 82 01                    OFFIW   82,01
        0CF1:   C4                          JR      0CF6
        0CF2:   34 A3 FF                    LXI     H,FFA3
        0CF5:   D6                          JR      0D0C

        0CF6:   70 3F D6 FF                 LHLD    FFD6
        0CFA:   2D                          LDAX    H+
        0CFB:   67 FF                       NEI     A,FF	;If terminator...
        0CFD:   E0                          JR      0CDE	;...reset scroll
        0CFE:   70 3E D6 FF                 SHLD    FFD6
        0D02:   9C                          CALT    00B8	;Byte -> Point to Font Graphic
        0D03:   6A 04                       MVI     B,04	;(5 pixels wide)
        0D05:   24 A0 FF                    LXI     D,FFA0
        0D08:   95                          CALT    00AA	; "((HL+) ==> (DE+))xB"
        0D09:   34 A0 FF                    LXI     H,FFA0      ;First copy it to RAM...

        0D0C:   24 A0 C2                    LXI     D,C2A0	;Then put it on screen, 3 pixels at a time.
        0D0F:   6A 02                       MVI     B,02

;((HL+) ==> (DE+))xB
CALT 95 0D11:   2D                          LDAX    H+
        0D12:   3C                          STAX    D+
        0D13:   52                          DCR     B
        0D14:   FC                          JR      0D11
        0D15:   08                          RET
;------------------------------------------------------------
        0D16:   20 DA                       INRW    DA
        0D18:   34 DA FF                    LXI     H,FFDA
        0D1B:   2B                          LDAX    H
        0D1C:   38 D0                       STAW    D0
        0D1E:   C4                          JR      0D23

;Draw a spiral dot-by-dot
CALF    0D1F:   65 D0 FF                    NEIW    D0,FF
        0D22:   F3                          JR      0D16
        0D23:   28 D1                       LDAW    D1		;This stores the direction
        0D25:   67 00                       NEI     A,00	;that the spiral draws in...
        0D27:   DE                          JR      0D46
        0D28:   70 1F D2 FF                 LBCD    FFD2
        0D2C:   67 01                       NEI     A,01
        0D2E:   4E 22                       JRE     0D52
        0D30:   67 02                       NEI     A,02
        0D32:   4E 23                       JRE     0D57
        0D34:   67 03                       NEI     A,03
        0D36:   4E 24                       JRE     0D5C

        0D38:   52                          DCR     B
        0D39:   0A                          MOV     A,B
        0D3A:   38 D3                       STAW    D3
        0D3C:   79 AD                       CALF    09AD	;Draw a dot on-screen
        0D3E:   30 D0                       DCRW    D0		;Decrement length counter...
        0D40:   08                          RET
        0D41:   69 01                       MVI     A,01	;If zero, turn corners
        0D43:   38 D1                       STAW    D1
        0D45:   08                          RET
;------------------------------------------------------------
        0D46:   14 24 25                    LXI     B,2524
        0D49:   70 1E D2 FF                 SBCD    FFD2
        0D4D:   79 AD                       CALF    09AD
        0D4F:   20 D1                       INRW    D1
        0D51:   08                          RET
        0D52:   53                          DCR     C
        0D53:   0B                          MOV     A,C
        0D54:   38 D2                       STAW    D2
        0D56:   C9                          JR      0D60
;------------------------------------------------------------
        0D57:   42                          INR     B
        0D58:   0A                          MOV     A,B
        0D59:   38 D3                       STAW    D3
        0D5B:   C4                          JR      0D60
;------------------------------------------------------------
        0D5C:   43                          INR     C
        0D5D:   0B                          MOV     A,C
        0D5E:   38 D2                       STAW    D2
        0D60:   79 AD                       CALF    09AD
        0D62:   30 D0                       DCRW    D0
        0D64:   08                          RET
        0D65:   20 D1                       INRW    D1
        0D67:   08                          RET

;------------------------------------------------------------
;Draw a thick black frame around the screen
CALF    0D68:   34 A3 C2                    LXI     H,C2A3      ;Point to 2nd screen
        0D6B:   69 FF                       MVI     A,FF	;Black character
        0D6D:   6A 05                       MVI     B,05	;Write 6 characters
        0D6F:   9F                          CALT    00BE	; "A ==> (HL+)xB"
        0D70:   69 1F                       MVI     A,1F	;Then a char with 5 upper dots filled
        0D72:   6A 3E                       MVI     B,3E	;Times 63
        0D74:   9F                          CALT    00BE	; "A ==> (HL+)xB"
        0D75:   6B 04                       MVI     C,04
        0D77:   6A 0B                       MVI     B,0B
        0D79:   69 FF                       MVI     A,FF
        0D7B:   9F                          CALT    00BE	; "A ==> (HL+)xB"
        0D7C:   85                          CALT    008A	; "Clear A"
        0D7D:   6A 3E                       MVI     B,3E
        0D7F:   9F                          CALT    00BE	; "A ==> (HL+)xB"
        0D80:   53                          DCR     C
        0D81:   F5                          JR      0D77
        0D82:   69 FF                       MVI     A,FF
        0D84:   6A 0B                       MVI     B,0B
        0D86:   9F                          CALT    00BE	; "A ==> (HL+)xB"
        0D87:   69 F0                       MVI     A,F0
        0D89:   6A 3E                       MVI     B,3E
        0D8B:   9F                          CALT    00BE	; "A ==> (HL+)xB"
        0D8C:   69 FF                       MVI     A,FF
        0D8E:   6A 05                       MVI     B,05
        0D90:   9F                          CALT    00BE	; "A ==> (HL+)xB"
        0D91:   08                          RET
;------------------------------------------------------------
;This draws the puzzle grid, I think...
CALF    0D92:   65 D5 00                    NEIW    D5,00
        0D95:   CC                          JR      0DA2
        0D96:   65 D5 01                    NEIW    D5,01
        0D99:   CB                          JR      0DA5
        0D9A:   75 D5 02                    EQIW    D5,02
        0D9D:   4E 24                       JRE     0DC3
        0D9F:   34 D8 C2                    LXI     H,C2D8
        0DA2:   34 B8 C2                    LXI     H,C2B8
        0DA5:   34 C8 C2                    LXI     H,C2C8
        0DA8:   99                          CALT    00B2	; "[PC+2] Draw Horizontal Line"
        0DA9:   F0 00                       DB $F0,$00
        0DAB:   6A 04                       MVI     B,04
        0DAD:   48 1E                       PUSH    B
        0DAF:   6D 4A                       MVI     E,4A
        0DB1:   8D                          CALT    009A	; "HL <== HL+E"
        0DB2:   99                          CALT    00B2	; "[PC+2] Draw Horizontal Line"
        0DB3:   FF 00                       DB $FF,$00
        0DB5:   48 1F			    POP	    B
	0DB7:	52			    DCR	    B
	0DB8:   F4			    JR	    0DAD
	0DB9:	6D 4A			    MVI	    E,4A
	0DBB:	8D			    CALT    009A	; "HL <== HL+E"
	0DBC:   99			    CALT    00B2	; "[PC+2] Draw Horizontal Line"
	0DBD:   1F 00			    DB $1F,00
	0DBF:	20 D5			    INRW    D5
	0DC1:   4F CF			    JRE	    0D92
	0DC3:   34 3E C3		    LXI	    H,C33E
	0DC6:   99                          CALT    00B2	; "[PC+2] Draw Horizontal Line"
	0DC7:   10 40			    DB $10,$40
	0DC9:   34 D4 C3		    LXI     H,C3D4
	0DCC:   99                          CALT    00B2	; "[PC+2] Draw Horizontal Line"
	0DCD:   10 40                       DB $10,$40
	0DCF:   85                          CALT    008A	; "Clear A"
	0DD0:   38 D5                       STAW    D5
	0DD2:   08			    RET
;------------------------------------------------------------
        0DD3:   67 01                       NEI     A,01
        0DD5:   D8                          JR      0DEE
        0DD6:   67 04                       NEI     A,04
        0DD8:   4E 22                       JRE     0DFC
        0DDA:   67 02                       NEI     A,02
        0DDC:   4E 2C                       JRE     0E0A

        0DDE:   70 69 FF C7                 MOV     A,C7FF   	;More puzzle grid drawing, probably...
        0DE2:   07 03                       ANI     A,03
        0DE4:   67 01                       NEI     A,01
        0DE6:   18                          RETS

        0DE7:   14 FF 12                    LXI     B,12FF
        0DEA:   15 A2 FF                    ORIW    A2,FF
        0DED:   CD                          JR      0DFB
;------------------------------------------------------------
        0DEE:   70 69 FF C7                 MOV     A,C7FF
        0DF2:   37 09                       LTI     A,09
        0DF4:   18                          RETS

        0DF5:   14 04 0D                    LXI     B,0D04
        0DF8:   05 A2 00                    ANIW    A2,00
        0DFB:   DB                          JR      0E17
;------------------------------------------------------------
        0DFC:   70 69 FF C7                 MOV     A,C7FF
        0E00:   27 04                       GTI     A,04
        0E02:   18                          RETS
        0E03:   14 FC 0F                    LXI     B,0FFC
        0E06:   05 A2 00                    ANIW    A2,00
        0E09:   CD                          JR      0E17
;------------------------------------------------------------
        0E0A:   70 69 FF C7                 MOV     A,C7FF
        0E0E:   47 03                       ONI     A,03
        0E10:   18                          RETS

        0E11:   14 01 11                    LXI     B,1101
        0E14:   15 A2 FF                    ORIW    A2,FF
        0E17:   70 69 FF C7                 MOV     A,C7FF
        0E1B:   1D                          MOV     E,A
        0E1C:   70 79 FE C7                 MOV     C7FE,A
        0E20:   60 C3                       ADD     A,C
        0E22:   1C                          MOV     D,A
        0E23:   70 79 FF C7                 MOV     C7FF,A
        0E27:   34 F1 C7                    LXI     H,C7F1
        0E2A:   0C                          MOV     A,D
        0E2B:   51                          DCR     A
        0E2C:   C1                          JR      0E2E
        0E2D:   C2                          JR      0E30

        0E2E:   32                          INX     H
        0E2F:   FB                          JR      0E2B

        0E30:   0D                          MOV     A,E
        0E31:   24 F1 C7                    LXI     D,C7F1
        0E34:   51                          DCR     A
        0E35:   C3                          JR      0E39
        0E36:   54 F8 08                    JMP     08F8

        0E39:   22                          INX     D
        0E3A:   F9                          JR      0E34
;------------------------------------------------------------
CALF    0E3B:   7C BF                       CALF    0CBF
        0E3D:   99                          CALT    00B2	; "[PC+2] Draw Horizontal Line"
        0E3E:   F0 10			    DB $F0,$10
        0E40:   6D 3A                       MVI     E,3A
        0E42:   8D                          CALT    009A	; "HL <== HL+E"
        0E43:   99                          CALT    00B2	; "[PC+2] Draw Horizontal Line"
        0E44:   FF 10			    DB $FF,$10
        0E46:   6D 3A                       MVI     E,3A
        0E48:   8D                          CALT    009A	; "HL <== HL+E"
        0E49:   99                          CALT    00B2	; "[PC+2] Draw Horizontal Line"
        0E4A:   1F 10			    DB $1F,$10
        0E4C:   08                          RET
;------------------------------------------------------------
; Turns on a hardware timer
CALF    0E4D:   48 24                       DI
        0E4F:   69 07                       MVI     A,07
        0E51:   4D C9                       MOV     TMM,A
        0E53:   69 74                       MVI     A,74
        0E55:   4D C6                       MOV     T0,A
        0E57:   05 80 FC                    ANIW    80,FC
        0E5A:   19                          STM
        0E5B:   48 20                       EI
        0E5D:   08                          RET
;------------------------------------------------------------
; Loads (DE/)HL with various common addresses
CALF    0E5E:   24 00 C0                    LXI     D,C000
        0E61:   34 58 C2                    LXI     H,C258
CALF    0E64:   34 EC 04                    LXI     H,04EC
CALF    0E67:   34 F2 C7                    LXI     H,C7F2
CALF    0E6A:   34 B0 FF                    LXI     H,FFB0
        0E6D:   08                          RET
;------------------------------------------------------------

;[PC+1] ?? (Unpack 8 bytes -> 64 bytes (Twice!))
CALT A8 0E6E:   48 3F                       POP     H
        0E70:   2D                          LDAX    H+
        0E71:   48 3E                       PUSH    H
        0E73:   9E                          CALT    00BC	; "HL=C4B0+(A*$10)"
        0E74:   94                          CALT    00A8	; "XCHG HL,DE"
        0E75:   44 78 0E                    CALL    0E78        ;This call means the next code runs twice

        0E78:   6A 07                       MVI     B,7
        0E7A:   6B 07                       MVI     C,7
        0E7C:   7E 6A                       CALF    0E6A	;(FFB0->HL)
        0E7E:   2A                          LDAX    D  		;In this loop, the byte at (FFB0)
        0E7F:   48 30                       RAL			;Has its bits split up into 8 bytes
        0E81:   48 0E                       PUSH    V		;And this loop runs 8 times...
        0E83:   2B                          LDAX    H
        0E84:   48 31                       RLR
        0E86:   3D                          STAX    H+
        0E87:   48 0F                       POP     V
        0E89:   53                          DCR     C
        0E8A:   F4                          JR      0E7F
        0E8B:   22                          INX     D
        0E8C:   52                          DCR     B
        0E8D:   EC                          JR      0E7A

        0E8E:   48 2E                       PUSH    D
        0E90:   33                          DCX     H
        0E91:   23                          DCX     D
        0E92:   6A 07                       MVI     B,7
        0E94:   96                          CALT    00AC	; "((HL-) ==> (DE-))xB"
        0E95:   48 2F                       POP     D
        0E97:   08                          RET
;------------------------------------------------------------
;[PC+1] ?? (Unpack & Roll 8 bits)
CALT A9 0E98:   48 3F                       POP     H
        0E9A:   2D                          LDAX    H+
        0E9B:   48 3E                       PUSH    H
        0E9D:   48 0E                       PUSH    V
        0E9F:   7E 73                       CALF    0E73
        0EA1:   48 0F                       POP     V
        0EA3:   C5                          JR      0EA9
;-----------------------------------------------------------
;[PC+1] ?? (Roll 8 bits -> Byte?)
CALT AA 0EA4:   48 3F                       POP     H
        0EA6:   2D                          LDAX    H+
        0EA7:   48 3E                       PUSH    H
        0EA9:   9E                          CALT    00BC	; "HL=C4B0+(A*$10)"
        0EAA:   24 BF FF                    LXI     D,FFBF
        0EAD:   94                          CALT    00A8	; "XCHG HL,DE"
        0EAE:   48 2E                       PUSH    D
        0EB0:   6B 0F                       MVI     C,0F
        0EB2:   6A 07                       MVI     B,8-1
        0EB4:   2A                          LDAX    D
        0EB5:   48 30                       RAL 
        0EB7:   48 0E                       PUSH    V
        0EB9:   2B                          LDAX    H
        0EBA:   48 31                       RLR
        0EBC:   3B                          STAX    H
        0EBD:   48 0F                       POP     V
        0EBF:   52                          DCR     B
        0EC0:   F4                          JR      0EB5
        0EC1:   33                          DCX     H
        0EC2:   22                          INX     D
        0EC3:   53                          DCR     C
        0EC4:   ED                          JR      0EB2
        0EC5:   48 2F                       POP     D
        0EC7:   34 B8 FF                    LXI     H,FFB8
        0ECA:   7E CE                       CALF    0ECE
        0ECC:   7E 6A                       CALF    0E6A

CALF    0ECE:   6A 07                       MVI     B,8-1
        0ED0:   95                          CALT    00AA	; "((HL+) ==> (DE+))xB"
        0ED1:   08                          RET     
;------------------------------------------------------------
;[PC+x] ?? (Add/Sub multiple bytes)
CALT AB 0ED2:   48 3F                       POP     H
        0ED4:   2D                          LDAX    H+
        0ED5:   48 3E                       PUSH    H
        0ED7:   1A                          MOV     B,A
        0ED8:   07 0F                       ANI     A,0F
        0EDA:   38 96                       STAW    96
        0EDC:   0A                          MOV     A,B
        0EDD:   A0                          CALT    00C0	; "(RLR A)x4"
        0EDE:   07 0F                       ANI     A,0F
        0EE0:   37 0D                       LTI     A,0D
        0EE2:   08                          RET     
        0EE3:   38 97                       STAW    97
        0EE5:   30 97                       DCRW    97
        0EE7:   C8                          JR      0EF0        ;Based on 97, jump to cart (4007)!
        0EE8:   91                          CALT    00A2	; "CALT A0, CALT A4"
        0EE9:   48 1F                       POP     B
        0EEB:   70 1F 07 40                 LBCD    4007        ;Read vector from $4007 on cart, however...
        0EEF:   73                          JB			;...all 5 Pokekon games have "0000" there!
        0EF0:   48 3F                       POP     H
        0EF2:   2D                          LDAX    H+
        0EF3:   48 3E                       PUSH    H
        0EF5:   38 98                       STAW    98
        0EF7:   07 0F                       ANI     A,0F
        0EF9:   37 0C                       LTI     A,0C
        0EFB:   E9                          JR      0EE5
        0EFC:   34 6E C5                    LXI     H,C56E
        0EFF:   32                          INX     H
        0F00:   32                          INX     H
        0F01:   32                          INX     H
        0F02:   51                          DCR     A
        0F03:   FB                          JR      0EFF
        0F04:   24 96 FF                    LXI     D,FF96
        0F07:   45 98 80                    ONIW    98,80
        0F0A:   C5                          JR      0F10
        0F0B:   2B                          LDAX    H
        0F0C:   70 E2                       SUBX    D
        0F0E:   3B                          STAX    H
        0F0F:   C8                          JR      0F18

        0F10:   45 98 40                    ONIW    98,40
        0F13:   C4                          JR      0F18
        0F14:   2B                          LDAX    H
        0F15:   70 C2                       ADDX    D
        0F17:   3B                          STAX    H
        0F18:   33                          DCX     H
        0F19:   45 98 10                    ONIW    98,10
        0F1C:   C6                          JR      0F23

        0F1D:   2B                          LDAX    H
        0F1E:   70 C2                       ADDX    D
        0F20:   3B                          STAX    H
        0F21:   4F C2                       JRE     0EE5

        0F23:   45 98 20                    ONIW    98,20
        0F26:   FA                          JR      0F21
        0F27:   2B                          LDAX    H
        0F28:   70 E2                       SUBX    D
        0F2A:   3B                          STAX    H
        0F2B:   F5                          JR      0F21
;------------------------------------------------------------
;Invert Screen RAM (C000~)
CALT A6 0F2C:   34 00 C0                    LXI     H,C000
;Invert Screen 2 RAM (C258~)
CALT A7 0F2F:   34 58 C2                    LXI     H,C258
        0F32:   6B 02                       MVI     C,02

        0F34:   6A C7                       MVI     B,C7
        0F36:   7F 3B                       CALF    0F3B
        0F38:   53                          DCR     C
        0F39:   FA                          JR      0F34
        0F3A:   08                          RET
;------------------------------------------------------------
;Invert bytes xB
CALF    0F3B:   2B                          LDAX    H
        0F3C:   16 FF                       XRI     A,FF
        0F3E:   3D                          STAX    H+
        0F3F:   52                          DCR     B
        0F40:   FA                          JR      0F3B
        0F41:   08                          RET
;------------------------------------------------------------
;[PC+1] Invert 8 bytes at (C4B8+A*$10)
CALT A5 0F42:   48 3F                       POP     H
        0F44:   2D                          LDAX    H+
        0F45:   48 3E                       PUSH    H
        0F47:   37 0C                       LTI     A,0C
        0F49:   08                          RET

        0F4A:   9E                          CALT    00BC	; "HL=C4B0+(A*$10)"
        0F4B:   6D 08                       MVI     E,08
        0F4D:   8D                          CALT    009A	; "HL <== HL+E"
        0F4E:   6A 07                       MVI     B,07
        0F50:   EA                          JR      0F3B
;------------------------------------------------------------
;for the addition routine below...
        0F51:   0E                          MOV     A,H
        0F52:   38 B0                       STAW    B0
        0F54:   0F                          MOV     A,L
        0F55:   38 B1                       STAW    B1
        0F57:   34 B1 FF                    LXI     H,FFB1
        0F5A:   28 96                       LDAW    96
        0F5C:   D0                          JR      0F6D
;------------------------------------------------------------
;[PC+1] 8~32-bit Add/Subtract (dec/hex)
;Source pointed to by HL & DE.  Extra byte sets a few options:
; bit: 76543210			B = 0/1: Work in decimal (BCD) / regular Hex
;      BA2211HD			A = 0/1: Add / Subtract numbers
;				22 = byte length of (HL)
;				11 = byte length of (DE)
;				H = 1: HL gets bytes from $FFB1
;				D = 1: DE gets bytes from $FFA2
CALT A4 0F5D:   48 1F                       POP     B
        0F5F:   29                          LDAX    B
        0F60:   12                          INX     B
        0F61:   48 1E                       PUSH    B
        0F63:   38 96                       STAW    96		;Get extra byte, keep in 96
        0F65:   57 01                       OFFI    A,01	;If set, load from $FFA2 instead
        0F67:   24 A2 FF                    LXI     D,FFA2
        0F6A:   57 02                       OFFI    A,02	;If set, load from $FFB1
        0F6C:   E4                          JR      0F51

        0F6D:   7C 72                       CALF    0C72	;"RLR A" x2
        0F6F:   1A                          MOV     B,A		;Get our length bits (8-32 bits)
        0F70:   07 03                       ANI     A,03
        0F72:   1B                          MOV     C,A
        0F73:   0A                          MOV     A,B
        0F74:   7C 72                       CALF    0C72        ;"RLR A" x2
        0F76:   07 03                       ANI     A,03
        0F78:   1A                          MOV     B,A
        0F79:   45 96 40                    ONIW    96,40	;Do we subtract instead of add?
        0F7C:   C6                          JR      0F83
        0F7D:   45 96 80                    ONIW    96,80	;Do we work in binary-coded decimal?
        0F80:   D8                          JR      0F99
        0F81:   4E 2D                       JRE     0FB0

        0F83:   45 96 80                    ONIW    96,80
        0F86:   4E 39                       JRE     0FC1

        0F88:   48 2A                       CLC
        0F8A:   2A                          LDAX    D
        0F8B:   70 D3                       ADCX    H   	;Add HL-,DE-
        0F8D:   3A                          STAX    D
        0F8E:   52                          DCR     B
        0F8F:   C1                          JR      0F91
        0F90:   08                          RET

        0F91:   23                          DCX     D
        0F92:   53                          DCR     C
        0F93:   C3                          JR      0F97
        0F94:   7F D3                       CALF    0FD3	;Clear C,HL
        0F96:   F3                          JR      0F8A

        0F97:   33                          DCX     H
        0F98:   F1                          JR      0F8A

        0F99:   48 2B                       STC
        0F9B:   69 99                       MVI     A,99
        0F9D:   56 00                       ACI     A,00
        0F9F:   70 E3                       SUBX    H
        0FA1:   70 C2                       ADDX    D
        0FA3:   61                          DAA
        0FA4:   3A                          STAX    D
        0FA5:   52                          DCR     B
        0FA6:   C1                          JR      0FA8
        0FA7:   08                          RET     

        0FA8:   23                          DCX     D
        0FA9:   53                          DCR     C
        0FAA:   C3                          JR      0FAE
        0FAB:   7F D3                       CALF    0FD3
        0FAD:   ED                          JR      0F9B

        0FAE:   33                          DCX     H
        0FAF:   EB                          JR      0F9B
;-----
        0FB0:   48 2A                       CLC
        0FB2:   2A                          LDAX    D
        0FB3:   70 F3                       SBBX    H
        0FB5:   3A                          STAX    D
        0FB6:   52                          DCR     B
        0FB7:   C1                          JR      0FB9
        0FB8:   08                          RET

        0FB9:   23                          DCX     D
        0FBA:   53                          DCR     C
        0FBB:   C3                          JR      0FBF
        0FBC:   7F D3                       CALF    0FD3
        0FBE:   F3                          JR      0FB2

        0FBF:   33                          DCX     H
        0FC0:   F1                          JR      0FB2
;------
        0FC1:   48 2A                       CLC
        0FC3:   2A                          LDAX    D
        0FC4:   70 D3                       ADCX    H
        0FC6:   61                          DAA
        0FC7:   3A                          STAX    D
        0FC8:   52                          DCR     B
        0FC9:   C1                          JR      0FCB
        0FCA:   08                          RET

        0FCB:   23                          DCX     D
        0FCC:   53                          DCR     C
        0FCD:   C3                          JR      0FD1
        0FCE:   7F D3                       CALF    0FD3
        0FD0:   F2                          JR      0FC3

        0FD1:   33                          DCX     H
        0FD2:   F0                          JR      0FC3
;------------------------------------------------------------
;Clear C,HL (for the add/sub routine above)
CALF    0FD3:   6B 00                       MVI     C,00
        0FD5:   34 00 00                    LXI     H,0000
        0FD8:   08                          RET
;------------------------------------------------------------
;[PC+1] INC/DEC Range of bytes from (HL)
;Extra byte's high bit sets Inc/Dec; rest is the byte counter.
CALT AC 0FD9:   48 1F                       POP     B
        0FDB:   29                          LDAX    B
        0FDC:   12                          INX     B
        0FDD:   48 1E                       PUSH    B
        0FDF:   1A                          MOV     B,A
        0FE0:   47 80                       ONI     A,80	;do we Dec?
        0FE2:   CE                          JR      0FF1

        0FE3:   07 7F                       ANI     A,7F	;Counter can be 00-7F
        0FE5:   1A                          MOV     B,A
        0FE6:   2B                          LDAX    H		;Load a byte
        0FE7:   66 01                       SUI     A,01	;Decrement it
        0FE9:   3F                          STAX    H-
        0FEA:   48 1A                       SKN     CY		;Quit our function if any byte= -1!
        0FEC:   C1                          JR      0FEE
        0FED:   08                          RET

        0FEE:   52                          DCR     B
        0FEF:   F6                          JR      0FE6
        0FF0:   08                          RET

        0FF1:   2B                          LDAX    H		;or Load a byte
        0FF2:   46 01                       ADI     A,01	;Add 1
        0FF4:   3F                          STAX    H-
        0FF5:   48 1A                       SKN     CY		;Quit if any byte overflows!
        0FF7:   C1                          JR      0FF9
        0FF8:   08                          RET

        0FF9:   52                          DCR     B
        0FFA:   F6                          JR      0FF1
        0FFB:   08                          RET			;What a weird way to end a BIOS...
;------------------------------------------------------------
	0FFC:   00 00 00 00		    DB 0,0,0,0		;Unused bytes (and who could blame 'em?)
	
; EOF!
