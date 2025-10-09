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
RESET___0000:   00                          ; NOP
________0001:   48 24                       ; DI
________0003:   CF                          ; JR      0013
;------------------------------------------------------------
INT0____0004:   54 0C 40                    ; JMP     400C
________0007:   00                          ; NOP
;------------------------------------------------------------
INTT____0008:   4E E6                       ; JRE     00F0
;------------------------------------------------------------
;((HL-) ==> (DE-))xB
; Copies the data pointed to by HL "(HL)" to (DE).
; B holds a single byte for the copy loop count.
CALT_96_000A:   2F                          ; LDAX    H-
________000B:   3E                          ; STAX    D-
________000C:   52                          ; DCR     B
________000D:   FC                          ; JR      000A
________000E:   08                          ; RET
________000F:   00                          ; NOP
;------------------------------------------------------------
INT1____0010:   54 0F 40                    ; JMP     400F
;------------------------------------------------------------
cont    0013:   04 00 00                    ; LXI     SP,0000
________0016:   48 3C                       ; PER			;Set Port E to AB mode
________0018:   69 C1                       ; MVI     A,C1
________001A:   4D C0                       ; MOV     PA,A
________001C:   64 88 FE                    ; ANI     PA,FE
________001F:   64 98 01                    ; ORI     PA,01
________0022:   85                          ; CALT    008A	; "Clear A"
________0023:   4D C4                       ; MOV     MB,A	;Mode B = All outputs
________0025:   64 98 38                    ; ORI     PA,38

________0028:   69 39                       ; MVI     A,39
________002A:   4D C1                       ; MOV     PB,A
________002C:   64 98 02                    ; ORI     PA,02
________002F:   64 88 FD                    ; ANI     PA,FD
________0032:   69 3E                       ; MVI     A,3E
________0034:   4D C1                       ; MOV     PB,A
________0036:   64 98 02                    ; ORI     PA,02
________0039:   64 88 FD                    ; ANI     PA,FD
________003C:   64 88 C7                    ; ANI     PA,C7
________003F:   64 98 04                    ; ORI     PA,04
________0042:   69 07                       ; MVI     A,07
________0044:   4D C9                       ; MOV     TMM,A	;Timer register = #$7
________0046:   69 74                       ; MVI     A,74
________0048:   4D C6                       ; MOV     T0,A        ;Timer option reg = #$74
________004A:   87                          ; CALT    008E	; "Clear Screen RAM"
________004B:   88                          ; CALT    0090	; "Clear C4B0~C593"
________004C:   89                          ; CALT    0092	; "Clear C594~C86F?"
________004D:   34 80 FF                    ; LXI     H,FF80
________0050:   6A 49                       ; MVI     B,49
________0052:   8A                          ; CALT    0094	; "Clear RAM (HL+)xB"
________0053:   81                          ; CALT    0082	; Copy Screen RAM to LCD Driver
________0054:   69 05                       ; MVI     A,05
________0056:   4D C3                       ; MOV     MK,A        ;Mask = IntT,1 ON
________0058:   48 20                       ; EI
________005A:   80                          ; CALT    0080	; [PC+1] Check Cartridge
________005B:   C0                          ; DB $C0 		;Jump to ($4001) in cartridge
________005C:   54 7F 05                    ; JMP     057F        ;Flow continues if no cartridge is present.
;------------------------------------------------------------
;(DE+)-(HL+) ==> A
; Loads A with (DE), increments DE, then subtracts (HL) from A and increments HL.
CALT_A1_005F:   2C                          ; LDAX    D+
________0060:   70 E5                       ; SUBX    H+
________0062:   08                          ; RET
;------------------------------------------------------------
;?? (Find 1st diff. byte in (HL),(DE)xB)  (Matching byte perhaps?)
; I don't know how useful this is, but I guess it's for advancing pointers to
; the first difference between 2 buffers, etc.
CALT_A2_0063:   A1                          ; CALT    00C2	; "(DE+)-(HL+) ==> A"
________0064:   48 1C                       ; SKN     Z
________0066:   C1                          ; JR      0068
________0067:   08                          ; RET

________0068:   52                          ; DCR     B
________0069:   F9                          ; JR      0063
________006A:   60 91                       ; XRA     A,A
________006C:   08                          ; RET
;------------------------------------------------------------
;?? (Find diff. & Copy bytes)
; I have no idea what purpose this serves...
CALT_A3_006D:   48 3E                       ; PUSH    H
________006F:   48 2E                       ; PUSH    D
________0071:   48 1E                       ; PUSH    B
________0073:   A2                          ; CALT    00C4	; "?? (Find 1st diff. byte in (HL),(DE)xB)"
________0074:   48 1F                       ; POP     B
________0076:   48 2F                       ; POP     D
________0078:   48 3F                       ; POP     H
________007A:   48 1A                       ; SKN     CY
________007C:   C1                          ; JR      007E
________007D:   08                          ; RET

________007E:   95                          ; CALT    00AA	; "((HL+) ==> (DE+))xB"
________007F:   08                          ; RET
;------------------------------------------------------------
;This is the call table provided by the CALT instruction in the uPD78xx CPU.
;It provides a way for programs to call commonly-used routines using a single-byte opcode.
;The numbers in the parentheses refer to the opcode for each entry in the table.
;Each table entry contains an address to jump to.  (Quite simple.)

;Opcodes $80-$AD point to routines hard-coded in the uPD78c06 CPU ROM.
;Opcodes $AE-$B7 point to cartridge ROM routines (whose jump tables are at $4012-$402F.)

; "[PC+X]" means the subroutine uses the bytes after its call as parameters.
; the subroutine then usually advances the return address by X bytes before returning.

(CALT 80) 0080:   A6 01                     ; DW 01A6	;[PC+1] Check Cartridge
(CALT 81) 0082:   CF 01                     ; DW 01CF	;Copy Screen RAM to LCD Driver
(CALT 82) 0084:   8E 01                     ; DW 018E	;[PC+2] Setup/Play Sound
(CALT 83) 0086:   9C 01                     ; DW 019C	;Setup/Play Music
(CALT 84) 0088:   1F 09                     ; DW 091F	;Read Controller FF90-FF95
(CALT 85) 008A:   9D 08                     ; DW 089D	;Clear A
(CALT 86) 008C:   FF 08                     ; DW 08FF	;Clear Screen 2 RAM
(CALT 87) 008E:   02 09                     ; DW 0902	;Clear Screen RAM
(CALT 88) 0090:   15 09                     ; DW 0915	;Clear C4B0~C593
(CALT 89) 0092:   0D 09                     ; DW 090D	;Clear C594~C7FF
(CALT 8A) 0094:   1A 09                     ; DW 091A	;Clear RAM (HL+)xB
(CALT 8B) 0096:   1B 0C                     ; DW 0C1B	;HL <== HL+DE
(CALT 8C) 0098:   0E 0C                     ; DW 0C0E	;[PC+1] HL +- byte
(CALT 8D) 009A:   18 0C                     ; DW 0C18	;HL <== HL+E
(CALT 8E) 009C:   8C 09                     ; DW 098C	;Swap C258+ <==> C000+
(CALT 8F) 009E:   81 09                     ; DW 0981	;C000+ ==> C258+
(CALT 90) 00A0:   7E 09                     ; DW 097E	;C258+ ==> C000+
(CALT 91) 00A2:   CD 01                     ; DW 01CD	;CALT 00A0, CALT 00A4
(CALT 92) 00A4:   37 0B                     ; DW 0B37	;?? (Move some RAM around...)
(CALT 93) 00A6:   D7 08                     ; DW 08D7	;HL <== AxE
(CALT 94) 00A8:   A0 08                     ; DW 08A0	;XCHG HL,DE
(CALT 95) 00AA:   11 0D                     ; DW 0D11	;((HL+) ==> (DE+))xB
(CALT 96) 00AC:   0A 00                     ; DW 000A	;((HL-) ==> (DE-))xB
(CALT 97) 00AE:   F3 08                     ; DW 08F3	;((HL+) <==> (DE+))xB
(CALT 98) 00B0:   99 09                     ; DW 0999	;Set Dot; B,C = X-,Y-position
(CALT 99) 00B2:   C7 09                     ; DW 09C7	;[PC+2] Draw Horizontal Line
(CALT 9A) 00B4:   E4 09                     ; DW 09E4	;[PC+3] Print Bytes on-Screen
(CALT 9B) 00B6:   29 0A                     ; DW 0A29	;[PC+3] Print Text on-Screen
(CALT 9C) 00B8:   0E 0B                     ; DW 0B0E	;Byte -> Point to Font Graphic
(CALT 9D) 00BA:   F1 0B                     ; DW 0BF1	;Set HL to screen (B,C)
(CALT 9E) 00BC:   24 0C                     ; DW 0C24	;HL=C4B0+(A*$10)
(CALT 9F) 00BE:   1B 09                     ; DW 091B	;A ==> (HL+)xB
(CALT A0) 00C0:   6E 0C                     ; DW 0C6E	;(RLR A)x4
(CALT A1) 00C2:   5F 00                     ; DW 005F	;(DE+)-(HL+) ==> A
(CALT A2) 00C4:   63 00                     ; DW 0063	;?? (Find 1st diff. byte in (HL),(DE)xB)
(CALT A3) 00C6:   6D 00                     ; DW 006D	;?? (Find diff. & Copy bytes)
(CALT A4) 00C8:   5D 0F                     ; DW 0F5D	;[PC+1] 8~32-bit Add/Subtract (dec/hex)
(CALT A5) 00CA:   42 0F                     ; DW 0F42	;[PC+1] Invert 8 bytes at (C4B8+A*$10)
(CALT A6) 00CC:   2C 0F                     ; DW 0F2C	;Invert Screen RAM (C000~)
(CALT A7) 00CE:   2F 0F                     ; DW 0F2F	;Invert Screen 2 RAM (C258~)
(CALT A8) 00D0:   6E 0E                     ; DW 0E6E	;[PC+1] ?? (Unpack 8 bytes -> 64 bytes (Twice!))
(CALT A9) 00D2:   98 0E                     ; DW 0E98	;[PC+1] ?? (Unpack & Roll 8 bits)
(CALT AA) 00D4:   A4 0E                     ; DW 0EA4	;[PC+1] ?? (Roll 8 bits -> Byte?)
(CALT AB) 00D6:   D2 0E                     ; DW 0ED2	;[PC+x] ?? (Add/Sub multiple bytes)
(CALT AC) 00D8:   D9 0F                     ; DW 0FD9	;[PC+1] INC/DEC Range of bytes from (HL)
(CALT AD) 00DA:   B1 09                     ; DW 09B1	;Clear Dot; B,C = X-,Y-position

(CALT AE) 00DC:   12 40                     ; DW 4012      ;Jump table for cartridge routines
(CALT AF) 00DE:   15 40                     ; DW 4015
(CALT B0) 00E0:   18 40                     ; DW 4018
(CALT B1) 00E2:   1B 40                     ; DW 401B
(CALT B2) 00E4:   1E 40                     ; DW 401E
(CALT B3) 00E6:   21 40                     ; DW 4021
(CALT B4) 00E8:   24 40                     ; DW 4024
(CALT B5) 00EA:   27 40                     ; DW 4027
(CALT B6) 00EC:   2A 40                     ; DW 402A
(CALT B7) 00EE:   2D 40                     ; DW 402D
;-----------------------------------------------------------
;                        Timer Interrupt
INTT____00F0:   45 80 01                    ; ONIW    80,01	;If 1, don't jump to cart.
________00F3:   4E 66                       ; JRE     015B

________00F5:   30 9A                       ; DCRW    9A
________00F7:   4E 5F                       ; JRE     0158

________00F9:   48 0E                       ; PUSH    V
________00FB:   28 8F                       ; LDAW    8F
________00FD:   38 9A                       ; STAW    9A
________00FF:   30 99                       ; DCRW    99
________0101:   4E 2B                       ; JRE     012E

________0103:   48 1E                       ; PUSH    B
________0105:   48 2E                       ; PUSH    D
________0107:   48 3E                       ; PUSH    H
________0109:   69 03                       ; MVI     A,03
________010B:   4D C9                       ; MOV     TMM,A	;Adjust timer
________010D:   69 53                       ; MVI     A,53
________010F:   51                          ; DCR     A
________0110:   FE                          ; JR      010F
________0111:   45 80 02                    ; ONIW    80,02
________0114:   C7                          ; JR      011C

________0115:   70 3F 84 FF                 ; LHLD    FF84
________0119:   78 A9                       ; CALF    08A9	;Music-playing code...
________011B:   CC                          ; JR      0128

________011C:   05 80 FC                    ; ANIW    80,FC
________011F:   69 07                       ; MVI     A,07
________0121:   4D C9                       ; MOV     TMM,A
________0123:   69 74                       ; MVI     A,74
________0125:   4D C6                       ; MOV     T0,A
________0127:   19                          ; STM
________0128:   48 3F                       ; POP     H
________012A:   48 2F                       ; POP     D
________012C:   48 1F                       ; POP     B
________012E:   28 88                       ; LDAW    88
________0130:   46 01                       ; ADI     A,01
________0132:   61                          ; DAA
________0133:   38 88                       ; STAW    88
________0135:   48 1A                       ; SKN     CY
________0137:   C1                          ; JR      0139
________0138:   D5                          ; JR      014E

________0139:   20 89                       ; INRW    89
________013B:   00                          ; NOP
________013C:   28 87                       ; LDAW    87
________013E:   46 01                       ; ADI     A,01
________0140:   61                          ; DAA
________0141:   38 87                       ; STAW    87
________0143:   48 1A                       ; SKN     CY
________0145:   C1                          ; JR      0147
________0146:   C7                          ; JR      014E

________0147:   28 86                       ; LDAW    86
________0149:   46 01                       ; ADI     A,01
________014B:   61                          ; DAA
________014C:   38 86                       ; STAW    86
________014E:   45 8A 80                    ; ONIW    8A,80
________0151:   20 8A                       ; INRW    8A
________0153:   20 8B                       ; INRW    8B
________0155:   00                          ; NOP
________0156:   48 0F                       ; POP     V
;--------
________0158:   48 20                       ; EI
________015A:   62                          ; RETI
;------------------------------------------------------------
________015B:   48 0E                       ; PUSH    V
________015D:   48 1E                       ; PUSH    B
________015F:   48 2E                       ; PUSH    D
________0161:   48 3E                       ; PUSH    H
________0163:   55 80 80                    ; OFFIW   80,80	;If 0, don't go to cart's INT routine
________0166:   54 09 40                    ; JMP     4009
;---------------------------------------
________0169:   60 D2                       ; ADC     A,B         ;Probably a simple random-number generator.
________016B:   60 D3                       ; ADC     A,C
________016D:   60 D4                       ; ADC     A,D
________016F:   60 D5                       ; ADC     A,E
________0171:   60 D6                       ; ADC     A,H
________0173:   60 D7                       ; ADC     A,L
________0175:   38 8C                       ; STAW    8C
________0177:   48 30                       ; RAL
________0179:   48 30                       ; RAL
________017B:   1A                          ; MOV     B,A
________017C:   48 2F                       ; POP     D
________017E:   48 2E                       ; PUSH    D
________0180:   60 D5                       ; ADC     A,E
________0182:   38 8D                       ; STAW    8D
________0184:   48 31                       ; RLR
________0186:   48 31                       ; RLR
________0188:   60 D2                       ; ADC     A,B
________018A:   38 8E                       ; STAW    8E
________018C:   4F 9A                       ; JRE     0128
;------------------------------------------------------------
;[PC+2] Setup/Play Sound
; 1st byte is sound pitch (00[silence] to $25); 2nd byte is length.
; Any pitch out of range could overrun the timers & sap the CPU.
CALT_82_018E:   48 24                       ; DI
________0190:   48 3F                       ; POP     H
________0192:   2D                          ; LDAX    H+		;(PC+1)
________0193:   1A                          ; MOV     B,A
________0194:   2D                          ; LDAX    H+          ;(PC+1)
________0195:   48 3E                       ; PUSH    H
________0197:   38 99                       ; STAW    99
________0199:   78 B6                       ; CALF    08B6        ;Set note timers
________019B:   C7                          ; JR      01A3
;------------------------------------------------------------
;Setup/Play Music
;HL should already contain the address of the music data.
;Format of the data string is the same as "Play Sound", with $FF terminating the song.
CALT_83_019C:   48 24                       ; DI
________019E:   15 80 02                    ; ORIW    80,02
________01A1:   78 A9                       ; CALF    08A9	;Read notes & set timers
________01A3:   48 20                       ; EI			;(sometimes skipped)
________01A5:   08                          ; RET
;------------------------------------------------------------
;[PC+1] Check Cartridge
; Checks if the cart is present, and possibly jumps to ($4001) or ($4003)
; The parameter $C0 sends it to $4001, $C1 to $4003, etc...
CALT_80_01A6:   34 00 40                    ; LXI     H,4000
________01A9:   2B                          ; LDAX    H
________01AA:   77 55                       ; EQI     A,55
________01AC:   18                          ; RETS

________01AD:   85                          ; CALT    008A	; "Clear A"
________01AE:   38 89                       ; STAW    89
________01B0:   2B                          ; LDAX    H
________01B1:   77 55                       ; EQI     A,55
________01B3:   18                          ; RETS
;----------------------------------
________01B4:   75 89 03                    ; EQIW    89,03
________01B7:   F8                          ; JR      01B0

________01B8:   7E 4D                       ; CALF    0E4D	;Sets a timer
________01BA:   15 80 80                    ; ORIW    80,80
________01BD:   32                          ; INX     H           ;->$4001
________01BE:   48 1F                       ; POP     B
________01C0:   29                          ; LDAX    B
________01C1:   67 C0                       ; NEI     A,C0        ;To cart if it's $C0
________01C3:   C4                          ; JR      01C8

________01C4:   32                          ; INX     H           ;->$4003
________01C5:   32                          ; INX     H
________01C6:   51                          ; DCR     A
________01C7:   F9                          ; JR      01C1

________01C8:   2D                          ; LDAX    H+
________01C9:   1B                          ; MOV     C,A
________01CA:   2B                          ; LDAX    H
________01CB:   1A                          ; MOV     B,A
________01CC:   73                          ; JB                  ;Jump to cartridge!
;-----------------------------------------------------------
;CALT 00A0, CALT 00A4
; Copies the 2nd screen to the screen buffer & moves some text around
; And updates the LCD...
CALT_91_01CD:   90                          ; CALT    00A0	; "C258+ ==> C000+"
________01CE:   92                          ; CALT    00A4	; "?? (Move some RAM around...)"
;-----------------------------------------------------------
;Copy Screen RAM to LCD Driver
; A very important and often-used function.  The LCD won't show anything without it...
								;Set up writing for LCD controller #1
CALT_81_01CF:   64 98 08                    ; ORI     PA,08       ;(Port A, bit 3 on)
________01D2:   34 31 C0                    ; LXI     H,C031
________01D5:   24 7D 00                    ; LXI     D,007D
________01D8:   6A 00                       ; MVI     B,00
________01DA:   64 88 FB                    ; ANI     PA,FB       ;bit 2 off
________01DD:   0A                          ; MOV     A,B
________01DE:   4D C1                       ; MOV     PB,A        ;Port B = (A)
________01E0:   64 98 02                    ; ORI     PA,02       ;bit 1 on
________01E3:   64 88 FD                    ; ANI     PA,FD       ;bit 1 off
________01E6:   6B 31                       ; MVI     C,31
________01E8:   64 98 04                    ; ORI     PA,04       ;bit 2 on
________01EB:   2F                          ; LDAX    H-          ;Screen data...
________01EC:   4D C1                       ; MOV     PB,A	;...to Port B
________01EE:   64 98 02                    ; ORI     PA,02       ;bit 1 on
________01F1:   64 88 FD                    ; ANI     PA,FD       ;bit 1 off
________01F4:   53                          ; DCR     C
________01F5:   F5                          ; JR      01EB
________01F6:   8B                          ; CALT    0096	; "HL <== HL+DE"
________01F7:   0A                          ; MOV     A,B
________01F8:   26 40                       ; ADINC   A,40
________01FA:   C3                          ; JR      01FE
________01FB:   1A                          ; MOV     B,A
________01FC:   4F DC                       ; JRE     01DA
								;Set up writing for LCD controller #2
________01FE:   64 88 F7                    ; ANI     PA,F7       ;bit 3 off
________0201:   64 98 10                    ; ORI     PA,10       ;bit 4 on
________0204:   34 2C C1                    ; LXI     H,C12C
________0207:   24 19 00                    ; LXI     D,0019
________020A:   6A 00                       ; MVI     B,00
________020C:   64 88 FB                    ; ANI     PA,FB       ;Same as in 1st loop
________020F:   0A                          ; MOV     A,B
________0210:   4D C1                       ; MOV     PB,A
________0212:   64 98 02                    ; ORI     PA,02
________0215:   64 88 FD                    ; ANI     PA,FD
________0218:   6B 31                       ; MVI     C,31
________021A:   64 98 04                    ; ORI     PA,04
________021D:   2D                          ; LDAX    H+
________021E:   4D C1                       ; MOV     PB,A
________0220:   64 98 02                    ; ORI     PA,02
________0223:   64 88 FD                    ; ANI     PA,FD
________0226:   53                          ; DCR     C
________0227:   F5                          ; JR      021D
________0228:   8B                          ; CALT    0096	; "HL <== HL+DE"
________0229:   0A                          ; MOV     A,B
________022A:   26 40                       ; ADINC   A,40
________022C:   C3                          ; JR      0230
________022D:   1A                          ; MOV     B,A
________022E:   4F DC                       ; JRE     020C

________0230:   85                          ; CALT    008A	; "Clear A"
________0231:   38 96                       ; STAW    96
        						;Set up writing for LCD controller #3
________0233:   64 88 EF                    ; ANI     PA,EF	;bit 4 off
________0236:   64 98 20                    ; ORI     PA,20       ;bit 5 on
________0239:   34 32 C0                    ; LXI     H,C032
________023C:   24 5E C1                    ; LXI     D,C15E
________023F:   6A 00                       ; MVI     B,00
________0241:   64 88 FB                    ; ANI     PA,FB
________0244:   0A                          ; MOV     A,B
________0245:   4D C1                       ; MOV     PB,A
________0247:   64 98 02                    ; ORI     PA,02
________024A:   64 88 FD                    ; ANI     PA,FD
________024D:   00                          ; NOP
________024E:   64 98 04                    ; ORI     PA,04

________0251:   6B 18                       ; MVI     C,18

________0253:   2D                          ; LDAX    H+
________0254:   4D C1                       ; MOV     PB,A
________0256:   64 98 02                    ; ORI     PA,02
________0259:   64 88 FD                    ; ANI     PA,FD
________025C:   53                          ; DCR     C
________025D:   F5                          ; JR      0253

________025E:   48 2E                       ; PUSH    D
________0260:   24 32 00                    ; LXI     D,0032
________0263:   8B                          ; CALT    0096	; "HL <== HL+DE"
________0264:   48 2F                       ; POP     D
________0266:   94                          ; CALT    00A8	; "XCHG HL,DE"
________0267:   20 96                       ; INRW    96          ;Skip if a carry...
________0269:   55 96 01                    ; OFFIW   96,01       ;Do alternating lines
________026C:   E4                          ; JR      0251

________026D:   0A                          ; MOV     A,B
________026E:   26 40                       ; ADINC   A,40
________0270:   C3                          ; JR      0274
________0271:   1A                          ; MOV     B,A
________0272:   4F CD                       ; JRE     0241

________0274:   64 88 DF                    ; ANI     PA,DF       ;bit 5 off
________0277:   08                          ; RET
;-----------------------------------------------------------
	;Sound note and timer data...
________0278:   B2 0A EE 07 E1 08 D4 09 C8 09 BD 0A B2 0A A8 0B
________0288:   9E 0C 96 0C 8D 0D 85 0E 7E 0F 77 10 70 11 6A 12
________0298:   64 13 5E 14 59 15 54 16 4F 17 4A 19 46 1A 42 1C
________02A8:   3E 1E 3B 1F 37 22 34 23 31 26 2E 28 2C 2A 29 2D
________02B8:   27 2F 25 31 23 34 21 37 1F 3B 1D 3F
;-----------------------------------------------------------
	;Graphic Font Data
________02C4:   00 00 00 00 00 00 00 4F 00 00 00 07 00 07 00 14
________02D4:   7F 14 7F 14 24 2A 7F 2A 12 23 13 08 64 62 36 49
________02E4:   55 22 50 00 05 03 00 00 00 1C 22 41 00 00 41 22
________02F4:   1C 00 14 08 3E 08 14 08 08 3E 08 08 00 50 30 00
________0304:   00 08 08 08 08 08 00 60 60 00 00 20 10 08 04 02
________0314:   3E 51 49 45 3E 00 42 7F 40 00 42 61 51 49 46 21
________0324:   41 45 4B 31 18 14 12 7F 10 27 45 45 45 39 3C 4A
________0334:   49 49 30 01 71 09 05 03 36 49 49 49 36 06 49 49
________0344:   29 1E 00 36 36 00 00 00 56 36 00 00 08 14 22 41
________0354:   00 14 14 14 14 14 00 41 22 14 08 02 01 51 09 06
________0364:   32 49 79 41 3E 7E 11 11 11 7E 7F 49 49 49 36 3E
________0374:   41 41 41 22 7F 41 41 22 1C 7F 49 49 49 49 7F 09
________0384:   09 09 01 3E 41 49 49 7A 7F 08 08 08 7F 00 41 7F
________0394:   41 00 20 40 41 3F 01 7F 08 14 22 41 7F 40 40 40
________03A4:   40 7F 02 0C 02 7F 7F 04 08 10 7F 3E 41 41 41 3E
________03B4:   7F 09 09 09 06 3E 41 51 21 5E 7F 09 19 29 46 46
________03C4:   49 49 49 31 01 01 7F 01 01 3F 40 40 40 3F 1F 20
________03D4:   40 20 1F 3F 40 38 40 3F 63 14 08 14 63 07 08 70
________03E4:   08 07 61 51 49 45 43 00 7F 41 41 00 15 16 7C 16
________03F4:   15 00 41 41 7F 00 04 02 01 02 04 40 40 40 40 40
________0404:   00 1F 11 11 1F 00 00 11 1F 10 00 1D 15 15 17 00
________0414:   11 15 15 1F 00 0F 08 1F 08 00 17 15 15 1D 00 1F
________0424:   15 15 1D 00 03 01 01 1F 00 1F 15 15 1F 00 17 15
________0434:   15 1F 1E 09 09 09 1E 1F 15 15 15 0A 0E 11 11 11
________0444:   11 1F 11 11 11 0E 1F 15 15 15 11 1F 05 05 05 01
________0454:   0E 11 11 15 1D 1F 04 04 04 1F 00 11 1F 11 00 08
________0464:   10 11 0F 01 1F 08 04 0A 11 1F 10 10 10 10 1F 02
________0474:   04 02 1F 1F 02 04 08 1F 0E 11 11 11 0E 1F 05 05
________0484:   05 02 0E 11 15 09 16 1F 05 05 0D 12 12 15 15 15
________0494:   09 01 01 1F 01 01 0F 10 10 10 0F 07 08 10 08 07
________04A4:   0F 10 0C 10 0F 1B 0A 04 0A 1B 03 04 18 04 03 11
________04B4:   19 15 13 11
;-----------------------------------------------------------
	;Text data
________04B8:   2C 23 24 00 24 2F 34 00 2D 21 34 32 29 38 00 33	;LCD DOT MATRIX SYSTEM
________04C8:   39 33 34 25 2D 00 26 35 2C 2C 00 27 32 21 30 28 ;FULL GRAPHIC
________04D8:   29 23 00 08 17 15 0A 16 14 00 24 2F 34 33 09 00 ;(75*64 DOTS)
________04E8:   00 00 00 FF
	;Music notation data
________04EC:   00 0A 06 0A 0B 0A 0F 0A 12 14 12 14
________04F8:   12 14 12 14 0A 14 0A 14 0B 14 0B 07 0D 07 0B 07
________0508:   10 14 10 14 0F 14 0F 14 0D 28 00 0A 06 0A 0B 0A
________0518:   0F 0A 12 14 12 14 12 14 12 14 0A 14 0A 07 0B 07
________0528:   0A 07 0B 14 0B 07 0D 07 0B 07 0D 14 0D 14 06 14
________0538:   08 0A 0A 0A 0B 3C 00 50 FF
	;Text data
________0541:   27 32 21 0E 00 38 10 10 0C 39 10 10 		;GRA. X00,Y00

________054D:   30 35 3A 3A 2C 25                               ;PUZZLE

________0553:   34 29 2D 25 1B 10 10 10 0E 10			;TIME:000.0
	;Grid data, probably
________055D:   04 04 08 01 01 08 04 04 08 01 01 02 04 04 02 01
________056D:   01 02

________056F:   08 04 02 04 08 08 08 01 02 01 08 04 02 02 04 02
;-----------------------------------------------------------
;from 005C -

________057F:   86                          ; CALT    008C	;Clear Screen 2 RAM
________0580:   38 D8                       ; STAW    D8          ;Set mem locations to 0
________0582:   38 82                       ; STAW    82
________0584:   38 A5                       ; STAW    A5
________0586:   34 B8 04                    ; LXI     H,04B8	;Start of scrolltext
________0589:   70 3E D6 FF                 ; SHLD    FFD6	;Save pointer
________058D:   7D 68                       ; CALF    0D68        ;Setup RAM vars
________058F:   90                          ; CALT    00A0	; "C258+ ==> C000+"
________0590:   81                          ; CALT    0082	;Copy Screen RAM to LCD Driver
________0591:   85                          ; CALT    008A	; "Clear A"
________0592:   38 DA                       ; STAW    DA
________0594:   38 D1                       ; STAW    D1
________0596:   38 D2                       ; STAW    D2
________0598:   38 D5                       ; STAW    D5
________059A:   69 FF                       ; MVI     A,FF
________059C:   38 D0                       ; STAW    D0
________059E:   34 D8 FF                    ; LXI     H,FFD8
________05A1:   70 93                       ; XRAX    H		;A=$FF XOR ($FFD8)
________05A3:   38 D8                       ; STAW    D8
________05A5:   69 60                       ; MVI     A,60        ;A delay value for the scrolltext
________05A7:   38 8A                       ; STAW    8A

;Main Loop starts here!
________05A9:   80                          ; CALT    0080	;[PC+1] Check Cartridge
________05AA:   C1                          ; DB $C1 		;Jump to ($4003) in cartridge

________05AB:   55 80 02                    ; OFFIW   80,02       ;If bit 1 is on, no music
________05AE:   C3                          ; JR      05B2
________05AF:   7E 64                       ; CALF    0E64	;Point HL to the music data
________05B1:   83                          ; CALT    0086	;Setup/Play Music
________05B2:   84                          ; CALT    0088	;Read Controller FF90-FF95
________05B3:   65 93 01                    ; NEIW    93,01       ;If Select is pressed...
________05B6:   54 EC 06                    ; JMP     06EC        ;Setup puzzle
________05B9:   65 D2 0F                    ; NEIW    D2,0F
________05BC:   4F D3                       ; JRE     0591        ;(go to main loop setup)
________05BE:   7D 1F                       ; CALF    0D1F        ;Draw spiral dot-by-dot
________05C0:   7D 1F                       ; CALF    0D1F	;Draw spiral dot-by-dot
________05C2:   90                          ; CALT    00A0	; "C258+ ==> C000+"
________05C3:   81                          ; CALT    0082	;Copy Screen RAM to LCD Driver
________05C4:   65 93 08                    ; NEIW    93,08       ;If Start is pressed...
________05C7:   C9                          ; JR      05D1        ;Jump to graphic program

________05C8:   75 8A 80                    ; EQIW    8A,80       ;Delay for the scrolltext
________05CB:   4F DC                       ; JRE     05A9        ;JRE Main Loop
________05CD:   7C E2                       ; CALF    0CE2        ;Scroll Text routine
________05CF:   4F D4                       ; JRE     05A5        ;Reset scrolltext delay...
;-----------------------------------------------------------
;"Paint" program setup routines
________05D1:   7E 4D                       ; CALF    0E4D        ;Turn timer on
________05D3:   86                          ; CALT    008C	; "Clear Screen 2 RAM"
________05D4:   88                          ; CALT    0090	; "Clear C4B0~C593"
________05D5:   34 41 05                    ; LXI     H,0541      ;"GRA"
________05D8:   9B                          ; CALT    00B6	; "[PC+3] Print Text on-Screen"
________05D9:   02 00 1C                    ; DB $02,$00,$1C     ;Parameters for the text routine
________05DC:   69 05                       ; MVI     A,05
________05DE:   34 B8 C4                    ; LXI     H,C4B8
________05E1:   3D                          ; STAX    H+
________05E2:   32                          ; INX     H
________05E3:   3B                          ; STAX    H
________05E4:   41                          ; INR     A
________05E5:   34 70 C5                    ; LXI     H,C570
________05E8:   3D                          ; STAX    H+
________05E9:   41                          ; INR     A
________05EA:   38 A6                       ; STAW    A6
________05EC:   69 39                       ; MVI     A,39
________05EE:   3D                          ; STAX    H+
________05EF:   41                          ; INR     A
________05F0:   38 A7                       ; STAW    A7
________05F2:   85                          ; CALT    008A	; "Clear A"
________05F3:   3D                          ; STAX    H+
________05F4:   38 A0                       ; STAW    A0          ;X,Y position for cursor
________05F6:   38 A1                       ; STAW    A1
________05F8:   69 99                       ; MVI     A,99        ;What does this do?
________05FA:   6A 0A                       ; MVI     B,0A
________05FC:   32                          ; INX     H
________05FD:   32                          ; INX     H
________05FE:   3D                          ; STAX    H+		;Just writes "99s" 3 bytes apart
________05FF:   32                          ; INX     H
________0600:   32                          ; INX     H
________0601:   52                          ; DCR     B
________0602:   FB                          ; JR      05FE
________0603:   7D 68                       ; CALF    0D68        ;Draw Border

________0605:   69 70                       ; MVI     A,70
________0607:   38 8A                       ; STAW    8A
________0609:   34 A0 FF                    ; LXI     H,FFA0      ;Print the X-, Y- position
________060C:   9A                          ; CALT    00B4	; "[PC+3] Print Bytes on-Screen"
________060D:   26 00 19                    ; DB $26,$00,$19     ;Parameters for the print routine
________0610:   34 A1 FF                    ; LXI     H,FFA1
________0613:   9A                          ; CALT    00B4	; "[PC+3] Print Bytes on-Screen"
________0614:   3E 00 19                    ; DB $3E,$00,$19     ;Parameters for the print routine
________0617:   91                          ; CALT    00A2	; "CALT A0, CALT A4"
________0618:   80                          ; CALT    0080	;[PC+1] Check Cartridge
________0619:   C1                          ; DB $C1		;Jump to ($4003) in cartridge

________061A:   45 8A 80                    ; ONIW    8A,80
________061D:   FA                          ; JR      0618
________061E:   34 72 C5                    ; LXI     H,C572
________0621:   2B                          ; LDAX    H
________0622:   16 FF                       ; XRI     A,FF
________0624:   3B                          ; STAX    H
________0625:   84                          ; CALT    0088	;Read Controller FF90-FF95
________0626:   28 93                       ; LDAW    93
________0628:   57 3F                       ; OFFI    A,3F        ;Test Buttons 1,2,3,4
________062A:   C8                          ; JR      0633
________062B:   28 92                       ; LDAW    92
________062D:   57 0F                       ; OFFI    A,0F	;Test U,D,L,R
________062F:   4E 42                       ; JRE     0673
________0631:   4F D2                       ; JRE     0605
;------------------------------------------------------------
________0633:   45 95 09                    ; ONIW    95,09
________0636:   D0                          ; JR      0647
________0637:   77 08                       ; EQI     A,08        ;Start clears the screen
________0639:   C5                          ; JR      063F

________063A:   82                          ; CALT    0084	;[PC+2] Setup/Play Sound
________063B:   22 03                       ; DB $22,$03
________063D:   4F 9D                       ; JRE     05DC        ;Clear screen

________063F:   77 01                       ; EQI     A,01        ;Select goes to the Puzzle
________0641:   C5                          ; JR      0647

________0642:   82                          ; CALT    0084	;[PC+2] Setup/Play Sound
________0643:   23 03                       ; DB $23,$03
________0645:   4E A7                       ; JRE     06EE        ;To Puzzle Setup

________0647:   77 02                       ; EQI     A,02        ;Button 1
________0649:   C4                          ; JR      064E
________064A:   82                          ; CALT    0084	;[PC+2] Setup/Play Sound
________064B:   19 03                       ; DB $19,$03
________064D:   D6                          ; JR      0664        ;Clear a dot

________064E:   77 10                       ; EQI     A,10        ;Button 2
________0650:   C4                          ; JR      0655
________0651:   82                          ; CALT    0084	;[PC+2] Setup/Play Sound
________0652:   1B 03                       ; DB $1B,$03
________0654:   CF                          ; JR      0664        ;Clear a dot

________0655:   77 04                       ; EQI     A,04        ;Button 3
________0657:   C4                          ; JR      065C
________0658:   82                          ; CALT    0084	;[PC+2] Setup/Play Sound
________0659:   1D 03                       ; DB $1D,$03
________065B:   D0                          ; JR      066C        ;Set a dot

________065C:   77 20                       ; EQI     A,20        ;Button 4
________065E:   4E 20                       ; JRE     0680
________0660:   82                          ; CALT    0084	;[PC+2] Setup/Play Sound
________0661:   1E 03                       ; DB $1E,$03
________0663:   C8                          ; JR      066C        ;Set a dot

________0664:   28 A6                       ; LDAW    A6
________0666:   1A                          ; MOV     B,A
________0667:   28 A7                       ; LDAW    A7
________0669:   1B                          ; MOV     C,A
________066A:   AD                          ; CALT    00DA	; "Clear Dot; B,C = X-,Y-position"
________066B:   C7                          ; JR      0673

________066C:   28 A6                       ; LDAW    A6
________066E:   1A                          ; MOV     B,A
________066F:   28 A7                       ; LDAW    A7
________0671:   1B                          ; MOV     C,A
________0672:   98                          ; CALT    00B0	; "Set Dot; B,C = X-,Y-position"

________0673:   28 92                       ; LDAW    92
________0675:   67 0F                       ; NEI     A,0F        ;Check if U,D,L,R pressed at once??
________0677:   4F 8C                       ; JRE     0605
________0679:   47 01                       ; ONI     A,01        ;Up
________067B:   D8                          ; JR      0694

________067C:   28 A7                       ; LDAW    A7
________067E:   67 0E                       ; NEI     A,0E        ;Check lower limits of X-pos
________0680:   DA                          ; JR      069B

________0681:   51                          ; DCR     A
________0682:   38 A7                       ; STAW    A7
________0684:   51                          ; DCR     A
________0685:   70 79 71 C5                 ; MOV     C571,A
________0689:   28 A1                       ; LDAW    A1
________068B:   46 01                       ; ADI     A,01
________068D:   61                          ; DAA
________068E:   38 A1                       ; STAW    A1
________0690:   82                          ; CALT    0084	;[PC+2] Setup/Play Sound
________0691:   12 03                       ; DB $12,$03
________0693:   DA                          ; JR      06AE

________0694:   47 04                       ; ONI     A,04        ;Down
________0696:   D7                          ; JR      06AE

________0697:   28 A7                       ; LDAW    A7
________0699:   67 3A                       ; NEI     A,3A        ;Check lower cursor limit
________069B:   DB                          ; JR      06B7

________069C:   41                          ; INR     A
________069D:   38 A7                       ; STAW    A7
________069F:   51                          ; DCR     A
________06A0:   70 79 71 C5                 ; MOV     C571,A
________06A4:   28 A1                       ; LDAW    A1
________06A6:   46 99                       ; ADI     A,99
________06A8:   61                          ; DAA     
________06A9:   38 A1                       ; STAW    A1
________06AB:   82                          ; CALT    0084	;[PC+2] Setup/Play Sound
________06AC:   14 03                       ; DB $14,$03

________06AE:   28 92                       ; LDAW    92
________06B0:   47 08                       ; ONI     A,08        ;Right
________06B2:   D9                          ; JR      06CC

________06B3:   28 A6                       ; LDAW    A6
________06B5:   67 43                       ; NEI     A,43
________06B7:   DC                          ; JR      06D4

________06B8:   41                          ; INR     A
________06B9:   38 A6                       ; STAW    A6
________06BB:   51                          ; DCR     A
________06BC:   70 79 70 C5                 ; MOV     C570,A
________06C0:   28 A0                       ; LDAW    A0
________06C2:   46 01                       ; ADI     A,01
________06C4:   61                          ; DAA
________06C5:   38 A0                       ; STAW    A0
________06C7:   82                          ; CALT    0084	;[PC+2] Setup/Play Sound
________06C8:   17 03                       ; DB $17,$03
________06CA:   4F 39                       ; JRE     0605

________06CC:   47 02                       ; ONI     A,02        ;Left
________06CE:   4F 35                       ; JRE     0605
________06D0:   28 A6                       ; LDAW    A6
________06D2:   67 07                       ; NEI     A,07
________06D4:   D3                          ; JR      06E8

________06D5:   51                          ; DCR     A
________06D6:   38 A6                       ; STAW    A6
________06D8:   51                          ; DCR     A
________06D9:   70 79 70 C5                 ; MOV     C570,A
________06DD:   28 A0                       ; LDAW    A0
________06DF:   46 99                       ; ADI     A,99
________06E1:   61                          ; DAA     
________06E2:   38 A0                       ; STAW    A0
________06E4:   82                          ; CALT    0084	;[PC+2] Setup/Play Sound
________06E5:   16 03                       ; DB $16,$03
________06E7:   E2                          ; JR      06CA
;------------------------------------------------------------
________06E8:   82                          ; CALT    0084	;[PC+2] Setup/Play Sound
________06E9:   01 03                       ; DB $01,$03
________06EB:   FB                          ; JR      06E7
;------------------------------------------------------------
;Puzzle Setup Routines...
________06EC:   7E 4D                       ; CALF    0E4D	;Reset the timer?
________06EE:   69 21                       ; MVI     A,21
________06F0:   6A 0A                       ; MVI     B,0A
________06F2:   7E 67                       ; CALF    0E67	;LXI H,$C7F2
________06F4:   3D                          ; STAX    H+
________06F5:   41                          ; INR     A           ;Set up the puzzle tiles in RAM
________06F6:   52                          ; DCR     B
________06F7:   FC                          ; JR      06F4
________06F8:   0A                          ; MOV     A,B         ;$FF
________06F9:   3D                          ; STAX    H+
________06FA:   7E 67                       ; CALF    0E67
________06FC:   6A 0B                       ; MVI     B,0B
________06FE:   24 5E C7                    ; LXI     D,C75E
________0701:   95                          ; CALT    00AA	; "((HL+) ==> (DE+))xB"
________0702:   6A 0B                       ; MVI     B,0B
________0704:   34 5E C7                    ; LXI     H,C75E
________0707:   24 52 C7                    ; LXI     D,C752
________070A:   95                          ; CALT    00AA	; "((HL+) ==> (DE+))xB"
________070B:   86                          ; CALT    008C	; "Clear Screen 2 RAM"
________070C:   7D 68                       ; CALF    0D68        ;Draw Border
________070E:   7D 92                       ; CALF    0D92	;Draw the grid
________0710:   7C 7B                       ; CALF    0C7B	;Write "PUZZLE"
________0712:   05 89 00                    ; ANIW    89,00
________0715:   69 60                       ; MVI     A,60
________0717:   38 8A                       ; STAW    8A
________0719:   80                          ; CALT    0080	;[PC+1] Check Cartridge
________071A:   C1                          ; DB $C1		;Jump to ($4003) in cartridge
;------------------------------------------------------------
________071B:   6A 0B                       ; MVI     B,0B
________071D:   34 52 C7                    ; LXI     H,C752
________0720:   24 F2 C7                    ; LXI     D,C7F2
________0723:   95                          ; CALT    00AA	; "((HL+) ==> (DE+))xB"
________0724:   6A 11                       ; MVI     B,11
________0726:   34 5D 05                    ; LXI     H,055D      ;Point to "grid" data
________0729:   2D                          ; LDAX    H+
________072A:   48 1E                       ; PUSH    B
________072C:   48 3E                       ; PUSH    H
________072E:   7D D3                       ; CALF    0DD3        ;This probably draws the tiles
________0730:   00                          ; NOP                 ;Or randomizes them??
________0731:   48 3F                       ; POP     H
________0733:   48 1F                       ; POP     B
________0735:   52                          ; DCR     B
________0736:   F2                          ; JR      0729
________0737:   6A 0B                       ; MVI     B,0B        
________0739:   7E 67                       ; CALF    0E67        ;LXI H,$C7F2
________073B:   24 52 C7                    ; LXI     D,C752
________073E:   95                          ; CALT    00AA	; "((HL+) ==> (DE+))xB"
________073F:   84                          ; CALT    0088	;Read Controller FF90-FF95
________0740:   65 93 01                    ; NEIW    93,01       ;Select
________0743:   45 95 01                    ; ONIW    95,01	;Select trigger
________0746:   C6                          ; JR      074D
________0747:   82                          ; CALT    0084	;[PC+2] Setup/Play Sound
________0748:   14 03                       ; DB $14,$03
________074A:   54 D1 05                    ; JMP     05D1	;Go to Paint Program
________074D:   65 93 08                    ; NEIW    93,08	;Start
________0750:   45 95 08                    ; ONIW    95,08
________0753:   C4                          ; JR      0758
________0754:   82                          ; CALT    0084	;[PC+2] Setup/Play Sound
________0755:   16 03                       ; DB $16,$03
________0757:   CD                          ; JR      0765
;------------------------------------------------------------
________0758:   75 8A 80                    ; EQIW    8A,80
________075B:   4F BC                       ; JRE     0719        ;Draw Tiles
________075D:   75 89 3C                    ; EQIW    89,3C
________0760:   4F B3                       ; JRE     0715	;Reset timer?
________0762:   54 7F 05                    ; JMP     057F        ;Go back to startup screen(?)
;------------------------------------------------------------
________0765:   86                          ; CALT    008C	; "Clear Screen 2 RAM"
________0766:   34 53 05                    ; LXI     H,0553      ;"TIME"
________0769:   9B                          ; CALT    00B6	; "[PC+3] Print Text on-Screen"
________076A:   0E 00 1A                    ; DB $0E,$00,$1A
________076D:   34 86 FF                    ; LXI     H,FF86
________0770:   6A 02                       ; MVI     B,02
________0772:   8A                          ; CALT    0094	; "Clear RAM (HL+)xB"
________0773:   28 8C                       ; LDAW    8C
________0775:   07 0F                       ; ANI     A,0F
________0777:   1A                          ; MOV     B,A
________0778:   34 6F 05                    ; LXI     H,056F
________077B:   2D                          ; LDAX    H+
________077C:   48 1E                       ; PUSH    B
________077E:   48 3E                       ; PUSH    H
________0780:   7D D3                       ; CALF    0DD3	;Draw Tiles
________0782:   00                          ; NOP
________0783:   48 3F                       ; POP     H
________0785:   48 1F                       ; POP     B
________0787:   52                          ; DCR     B
________0788:   F2                          ; JR      077B
________0789:   7D 68                       ; CALF    0D68        ;Draw Border (again)
________078B:   7D 92                       ; CALF    0D92        ;Draw the grid (again)
________078D:   7C 82                       ; CALF    0C82	;Scroll text? Write time in decimal?
________078F:   69 60                       ; MVI     A,60
________0791:   38 8A                       ; STAW    8A
________0793:   80                          ; CALT    0080	;[PC+1] Check Cartridge
________0794:   C1                          ; DB $C1		;Jump to ($4003) in cartridge
;------------------------------------------------------------
________0795:   34 86 FF                    ; LXI     H,FF86
________0798:   9A                          ; CALT    00B4	; "[PC+3] Print Bytes on-Screen"
________0799:   2C 00 12                    ; DB $2C,$00,$12
________079C:   34 88 FF                    ; LXI     H,FF88
________079F:   9A                          ; CALT    00B4	; "[PC+3] Print Bytes on-Screen"
________07A0:   44 00 08                    ; DB $44,$00,$08
________07A3:   90                          ; CALT    00A0	; "C258+ ==> C000+"
________07A4:   81                          ; CALT    0082	;Copy Screen RAM to LCD Driver
________07A5:   84                          ; CALT    0088	;Read Controller FF90-FF95
________07A6:   65 93 01                    ; NEIW    93,01       ;Select
________07A9:   4F 9C                       ; JRE     0747	;To Paint Program
________07AB:   65 93 08                    ; NEIW    93,08	;Start
________07AE:   45 95 08                    ; ONIW    95,08	;Start trigger
________07B1:   C2                          ; JR      07B4
________07B2:   4F A0                       ; JRE     0754        ;Restart puzzle
;------------------------------------------------------------
________07B4:   75 8A 80                    ; EQIW    8A,80
________07B7:   4F DA                       ; JRE     0793
________07B9:   28 92                       ; LDAW    92          ;Joypad
________07BB:   47 0F                       ; ONI     A,0F
________07BD:   4F D0                       ; JRE     078F        ;Keep looping
________07BF:   7D D3                       ; CALF    0DD3        ;Draw Tiles
________07C1:   C4                          ; JR      07C6
;------------------------------------------------------------
________07C2:   82                          ; CALT    0084	;[PC+2] Setup/Play Sound
________07C3:   01 03                       ; DB $01,$03
________07C5:   F7                          ; JR      07BD
;------------------------------------------------------------
________07C6:   48 0E                       ; PUSH    V
________07C8:   69 03                       ; MVI     A,03
________07CA:   38 99                       ; STAW    99
________07CC:   48 24                       ; DI  
________07CE:   78 B6                       ; CALF    08B6        ;Play Music (Snd)
________07D0:   48 20                       ; EI
________07D2:   34 FE C7                    ; LXI     H,C7FE
________07D5:   2D                          ; LDAX    H+
________07D6:   1A                          ; MOV     B,A
________07D7:   2F                          ; LDAX    H-
________07D8:   60 BA                       ; LTA     A,B
________07DA:   C2                          ; JR      07DD
________07DB:   1A                          ; MOV     B,A
________07DC:   2B                          ; LDAX    H
________07DD:   48 1E                       ; PUSH    B
________07DF:   75 A2 00                    ; EQIW    A2,00
________07E2:   4E 3F                       ; JRE     0823
________07E4:   7C BF                       ; CALF    0CBF        ;Write Text(?)
________07E6:   32                          ; INX     H
________07E7:   99                          ; CALT    00B2	; "[PC+2] Draw Horizontal Line"
________07E8:   00 8E                       ; DB $00,$8E
________07EA:   7C 77                       ; CALF    0C77        ;HL + $3C
________07EC:   48 3E                       ; PUSH    H
________07EE:   99                          ; CALT    00B2	; "[PC+2] Draw Horizontal Line"
________07EF:   F0 0E                       ; DB $F0,$0E
________07F1:   48 3F                       ; POP     H
________07F3:   99                          ; CALT    00B2	; "[PC+2] Draw Horizontal Line"
________07F4:   F0 8E                       ; DB $F0,$8E
________07F6:   7C 77                       ; CALF    0C77        ;HL + $3C
________07F8:   99                          ; CALT    00B2	; "[PC+2] Draw Horizontal Line"
________07F9:   1F 0F                       ; DB $1F,$0F
________07FB:   48 1F                       ; POP     B
________07FD:   0A                          ; MOV     A,B
________07FE:   7C BF                       ; CALF    0CBF        ;Write Text(?)
________0800:   99                          ; CALT    00B2	; "[PC+2] Draw Horizontal Line"
________0801:   F0 0F                       ; DB $F0,$0F
________0803:   7C 77                       ; CALF    0C77        ;HL + $3C
________0805:   48 3E                       ; PUSH    H
________0807:   99                          ; CALT    00B2	; "[PC+2] Draw Horizontal Line"
________0808:   0F 0E                       ; DB $0F,$0E
________080A:   48 3F                       ; POP     H
________080C:   99                          ; CALT    00B2	; "[PC+2] Draw Horizontal Line"
________080D:   0F 8E                       ; DB $0F,$0E
________080F:   6D 41                       ; MVI     E,41
________0811:   8D                          ; CALT    009A	; "HL <== HL+E"
________0812:   48 0F                       ; POP     V
________0814:   48 3E                       ; PUSH    H
________0816:   9C                          ; CALT    00B8	;Byte -> Point to Font Graphic
________0817:   48 2F                       ; POP     D
________0819:   6A 04                       ; MVI     B,04
________081B:   2D                          ; LDAX    H+
________081C:   48 30                       ; RAL
________081E:   3C                          ; STAX    D+
________081F:   52                          ; DCR     B
________0820:   FA                          ; JR      081B
________0821:   4E 52                       ; JRE     0875
;------------------------------------------------------------
________0823:   7C BF                       ; CALF    0CBF        ;Write Text(?)
________0825:   6A 07                       ; MVI     B,07
________0827:   32                          ; INX     H
________0828:   52                          ; DCR     B
________0829:   FD                          ; JR      0827
________082A:   69 01                       ; MVI     A,01
________082C:   38 A5                       ; STAW    A5
________082E:   99                          ; CALT    00B2	; "[PC+2] Draw Horizontal Line"
________082F:   E0 08                       ; DB $E0,$08
________0831:   6D 42                       ; MVI     E,42
________0833:   8D                          ; CALT    009A	; "HL <== HL+E"
________0834:   99                          ; CALT    00B2	; "[PC+2] Draw Horizontal Line"
________0835:   FF 08                       ; DB $FF,$08
________0837:   6D 42                       ; MVI     E,42
________0839:   8D                          ; CALT    009A	; "HL <== HL+E"
________083A:   99                          ; CALT    00B2	; "[PC+2] Draw Horizontal Line"
________083B:   1F 08                       ; DB $1F,$08
________083D:   28 A5                       ; LDAW    A5
________083F:   51                          ; DCR     A
________0840:   C1                          ; JR      0842
________0841:   CA                          ; JR      084C

________0842:   38 A5                       ; STAW    A5
________0844:   48 1F                       ; POP     B
________0846:   0A                          ; MOV     A,B
________0847:   38 A2                       ; STAW    A2
________0849:   7C BF                       ; CALF    0CBF        ;Write Text(?)
________084B:   E2                          ; JR      082E

________084C:   28 A2                       ; LDAW    A2
________084E:   7C BF                       ; CALF    0CBF        ;Write Text(?)
________0850:   6D 09                       ; MVI     E,09
________0852:   8D                          ; CALT    009A	; "HL <== HL+E"
________0853:   99                          ; CALT    00B2	; "[PC+2] Draw Horizontal Line"
________0854:   1F 8E                       ; DB $1F,$8E
________0856:   7C 77                       ; CALF    0C77        ;HL + $3C
________0858:   99                          ; CALT    00B2	; "[PC+2] Draw Horizontal Line"
________0859:   00 8E                       ; DB $00,$8E
________085B:   7C 77                       ; CALF    0C77        ;HL + $3C
________085D:   99                          ; CALT    00B2	; "[PC+2] Draw Horizontal Line"
________085E:   F0 8E                       ; DB $F0,$8E
________0860:   6A 54                       ; MVI     B,54        ;Decrement HL 55 times!
________0862:   33                          ; DCX     H		;Is this a delay or something?
________0863:   52                          ; DCR     B		;There's already a CALT that subs HL...
________0864:   FD                          ; JR      0862
________0865:   94                          ; CALT    00A8	; "XCHG HL,DE"
________0866:   48 0F                       ; POP     V
________0868:   48 2E                       ; PUSH    D
________086A:   9C                          ; CALT    00B8	;Byte -> Point to Font Graphic
________086B:   48 2F                       ; POP     D
________086D:   6A 04                       ; MVI     B,04
________086F:   2D                          ; LDAX    H+
________0870:   48 30                       ; RAL 
________0872:   3C                          ; STAX    D+
________0873:   52                          ; DCR     B
________0874:   FA                          ; JR      086F
________0875:   34 88 FF                    ; LXI     H,FF88
________0878:   9A                          ; CALT    00B4	; "[PC+3] Print Bytes on-Screen"
________0879:   44 00 08                    ; DB $44,$00,$08
________087C:   90                          ; CALT    00A0	; "C258+ ==> C000+"
________087D:   81                          ; CALT    0082	;Copy Screen RAM to LCD Driver
________087E:   7D 68                       ; CALF    0D68        ;Draw Border
________0880:   7D 92                       ; CALF    0D92	;Draw Puzzle Grid
________0882:   7C 82                       ; CALF    0C82        ;Scroll text? Write time in decimal?
________0884:   6A 0B                       ; MVI     B,0B
________0886:   34 5E C7                    ; LXI     H,C75E
________0889:   24 F2 C7                    ; LXI     D,C7F2
________088C:   2D                          ; LDAX    H+
________088D:   70 FC                       ; EQAX    D+
________088F:   4F 34                       ; JRE     07C5
________0891:   52                          ; DCR     B
________0892:   F9                          ; JR      088C
________0893:   7E 64                       ; CALF    0E64	;Point HL to music data
________0895:   83                          ; CALT    0086	;Setup/Play Music
________0896:   45 80 03                    ; ONIW    80,03
________0899:   54 12 07                    ; JMP     0712        ;Continue puzzle
________089C:   F9                          ; JR      0896
;End of Puzzle Code
;------------------------------------------------------------
;Clear A
CALT_85_089D:   69 00                       ; MVI     A,00
________089F:   08                          ; RET
;------------------------------------------------------------
;XCHG HL,DE
CALT_94_08A0:   48 3E                       ; PUSH    H
________08A2:   48 2E                       ; PUSH    D
________08A4:   48 3F                       ; POP     H
________08A6:   48 2F                       ; POP     D
________08A8:   08                          ; RET
;------------------------------------------------------------
;Music-playing code...
CALF____08A9:   2D                          ; LDAX    H+
________08AA:   1A                          ; MOV     B,A
________08AB:   2D                          ; LDAX    H+
________08AC:   38 99                       ; STAW    99
________08AE:   70 3E 84 FF                 ; SHLD    FF84
________08B2:   0A                          ; MOV     A,B
________08B3:   41                          ; INR     A
________08B4:   C1                          ; JR      08B6
________08B5:   18                          ; RETS                ;Return & Skip if read "$FF"

;Move "note" into TM0
CALF____08B6:   34 78 02                    ; LXI     H,0278           ;Table Start
________08B9:   0A                          ; MOV     A,B
________08BA:   36 01                       ; SUINB   A,01
________08BC:   C3                          ; JR      08C0
________08BD:   32                          ; INX     H          ;Add A*2 to HL (wastefully)
________08BE:   32                          ; INX     H
________08BF:   FA                          ; JR      08BA

________08C0:   2D                          ; LDAX    H+
________08C1:   4D C6                       ; MOV     T0,A
________08C3:   2B                          ; LDAX    H
________08C4:   38 9A                       ; STAW    9A
________08C6:   38 8F                       ; STAW    8F
________08C8:   52                          ; DCR     B
________08C9:   69 00                       ; MVI     A,00       ;Sound?
________08CB:   69 03                       ; MVI     A,03       ;Silent
________08CD:   4D C9                       ; MOV     TMM,A
________08CF:   15 80 01                    ; ORIW    80,01
________08D2:   19                          ; STM
________08D3:   08                          ; RET
;------------------------------------------------------------
;Load a "multiplication table" for A,E from (HL) and do AxE
;Is this ever used?
________08D4:   2D                          ; LDAX    H+
________08D5:   1D                          ; MOV     E,A
________08D6:   2B                          ; LDAX    H
;HL <== AxE
CALT_93_08D7:   34 00 00                    ; LXI     H,0000
________08DA:   6C 00                       ; MVI     D,00
________08DC:   27 00                       ; GTI     A,00
________08DE:   08                          ; RET
________08DF:   48 2A                       ; CLC
________08E1:   48 31                       ; RLR
________08E3:   48 0E                       ; PUSH    V
________08E5:   48 1A                       ; SKN     CY
________08E7:   8B                          ; CALT    0096	; "HL <== HL+DE"
________08E8:   0D                          ; MOV     A,E
________08E9:   60 C1                       ; ADD     A,A
________08EB:   1D                          ; MOV     E,A
________08EC:   0C                          ; MOV     A,D
________08ED:   48 30                       ; RAL
________08EF:   1C                          ; MOV     D,A
________08F0:   48 0F                       ; POP     V
________08F2:   E9                          ; JR      08DC
;-----------------------------
;((HL+) <==> (DE+))xB
;This function swaps the contents of (HL)<->(DE) B times
CALT_97_08F3:   78 F8                       ; CALF    08F8	;Swap (HL+)<->(DE+)
________08F5:   52                          ; DCR     B
________08F6:   FC                          ; JR      08F3
________08F7:   08                          ; RET
;------------------------------------------------------------
;Swap (HL+)<->(DE+)
CALF____08F8:   2B                          ; LDAX    H
________08F9:   1B                          ; MOV     C,A
________08FA:   2A                          ; LDAX    D
________08FB:   3D                          ; STAX    H+
________08FC:   0B                          ; MOV     A,C
________08FD:   3C                          ; STAX    D+
________08FE:   08                          ; RET
;------------------------------------------------------------
;Clear Screen 2 RAM
CALT_86_08FF:   34 58 C2                    ; LXI     H,C258	;RAM for screen 2
;Clear Screen RAM
CALT_87_0902:   34 00 C0                    ; LXI     H,C000	;RAM for screen 1
________0905:   6B 02                       ; MVI     C,02
________0907:   6A C7                       ; MVI     B,C7        ;$C8 bytes * 3 loops
________0909:   8A                          ; CALT    0094	; "Clear RAM (HL+)xB"
________090A:   53                          ; DCR     C
________090B:   FB                          ; JR      0907
________090C:   08                          ; RET
;------------------------------------------------------------
;Clear C594~C7FF
CALT_89_090D:   34 94 C5                    ; LXI     H,C594	;Set HL
________0910:   79 05                       ; CALF    0905	;And jump to above routine
________0912:   6A 13                       ; MVI     B,13        ;Then clear $14 more bytes
________0914:   C5                          ; JR      091A	;Clear RAM (HL+)xB

;Clear C4B0~C593
CALT_88_0915:   34 B0 C4                    ; LXI     H,C4B0      ;Set RAM pointer
________0918:   6A E3                       ; MVI     B,E3	;and just drop into the func.

;Clear RAM (HL+)xB
CALT_8A_091A:   85                          ; CALT    008A	; "Clear A"
;A ==> (HL+)xB
CALT_9F_091B:   3D                          ; STAX    H+
________091C:   52                          ; DCR     B
________091D:   FD                          ; JR      091B
________091E:   08                          ; RET
;------------------------------------------------------------
;Read Controller FF90-FF95
CALT_84_091F:   34 92 FF                    ; LXI     H,FF92      ;Current joy storage
________0922:   24 90 FF                    ; LXI     D,FF90      ;Old joy storage
________0925:   6A 01                       ; MVI     B,01        ;Copy 2 bytes from curr->old
________0927:   95                          ; CALT    00AA	; "((HL+) ==> (DE+))xB"
________0928:   64 88 BF                    ; ANI     PA,BF       ;PA Bit 6 off
________092B:   4C C2                       ; MOV     A,PC	;Get port C
________092D:   16 FF                       ; XRI     A,FF
________092F:   1B                          ; MOV     C,A
________0930:   6A 40                       ; MVI     B,40	;Debouncing delay
________0932:   52                          ; DCR     B
________0933:   FE                          ; JR      0932
________0934:   4C C2                       ; MOV     A,PC	;Get port C a 2nd time
________0936:   16 FF                       ; XRI     A,FF
________0938:   60 FB                       ; EQA     A,C		;Check if both reads are equal
________093A:   F4                          ; JR      092F
________093B:   64 98 40                    ; ORI     PA,40	;PA Bit 6 on
________093E:   07 03                       ; ANI     A,03
________0940:   3C                          ; STAX    D+		;Save controller read in 92
________0941:   0B                          ; MOV     A,C
________0942:   7C 72                       ; CALF    0C72	;RLR A x2
________0944:   07 07                       ; ANI     A,07
________0946:   3E                          ; STAX    D-		;Save cont in 93
________0947:   64 88 7F                    ; ANI     PA,7F	;PA bit 7 off
________094A:   4C C2                       ; MOV     A,PC	;Get other controller bits
________094C:   16 FF                       ; XRI     A,FF
________094E:   1B                          ; MOV     C,A
________094F:   6A 40                       ; MVI     B,40	;...and debounce
________0951:   52                          ; DCR     B
________0952:   FE                          ; JR      0951
________0953:   4C C2                       ; MOV     A,PC
________0955:   16 FF                       ; XRI     A,FF
________0957:   60 FB                       ; EQA     A,C		;...check again
________0959:   F4                          ; JR      094E
________095A:   64 98 80                    ; ORI     PA,80       ;PA bit 7 on
________095D:   48 30                       ; RAL
________095F:   48 30                       ; RAL
________0961:   07 0C                       ; ANI     A,0C
________0963:   70 9A                       ; ORAX    D		;Or with FF92
________0965:   3C                          ; STAX    D+          ;...and save
________0966:   0B                          ; MOV     A,C
________0967:   48 30                       ; RAL 
________0969:   07 38                       ; ANI     A,38
________096B:   70 9A                       ; ORAX    D           ;Or with FF93
________096D:   3E                          ; STAX    D-		;...and save
________096E:   34 90 FF                    ; LXI     H,FF90      ;Get our new,old
________0971:   14 94 FF                    ; LXI     B,FF94
________0974:   2D                          ; LDAX    H+          ;And XOR to get controller strobe
________0975:   70 94                       ; XRAX    D+		;But this strobe function is stupid:
________0977:   39                          ; STAX    B           ;Bits go to 1 whenever the button is
________0978:   12                          ; INX     B		;initially pressed AND released...
________0979:   2B                          ; LDAX    H
________097A:   70 92                       ; XRAX    D
________097C:   39                          ; STAX    B
________097D:   08                          ; RET
;------------------------------------------------------------
;C258+ ==> C000+
CALT_90_097E:   7E 5E                       ; CALF    0E5E
________0980:   C3                          ; JR      0984
;C000+ ==> C258+
CALT_8F_0981:   7E 5E                       ; CALF    0E5E
________0983:   94                          ; CALT    00A8	; "XCHG HL,DE"
________0984:   6B 02                       ; MVI     C,02
________0986:   6A C7                       ; MVI     B,C7
________0988:   95                          ; CALT    00AA	; "((HL+) ==> (DE+))xB"
________0989:   53                          ; DCR     C
________098A:   FB                          ; JR      0986
________098B:   08                          ; RET     
;------------------------------------------------------------
;Swap C258+ <==> C000+
CALT_8E_098C:   7E 5E                       ; CALF    0E5E
________098E:   14 02 C7                    ; LXI     B,C702
________0991:   48 1E                       ; PUSH    B
________0993:   97                          ; CALT    00AE	; "((HL+) <==> (DE+))xB"
________0994:   48 1F                       ; POP     B
________0996:   53                          ; DCR     C
________0997:   F9                          ; JR      0991
________0998:   08                          ; RET
;------------------------------------------------------------
;Set Dot; B,C = X-,Y-position
;(Oddly enough, this writes dots to the 2nd screen RAM area!)
CALT_98_0999:   48 1E                       ; PUSH    B
________099B:   7B F4                       ; CALF    0BF4       ;Point to 2nd screen
________099D:   48 1F                       ; POP     B
________099F:   0B                          ; MOV     A,C
________09A0:   07 07                       ; ANI     A,07
________09A2:   1B                          ; MOV     C,A
________09A3:   85                          ; CALT    008A	; "Clear A"
________09A4:   48 2B                       ; STC
________09A6:   48 30                       ; RAL
________09A8:   53                          ; DCR     C
________09A9:   FC                          ; JR      09A6
________09AA:   70 9B                       ; ORAX    H
________09AC:   D8                          ; JR      09C5
;------------------------------------------------------------
CALF____09AD:   75 D8 00                    ; EQIW    D8,00       ;"Invert Dot", then...
________09B0:   E8                          ; JR      0999

;Clear Dot; B,C = X-,Y-position
CALT_AD_09B1:   48 1E                       ; PUSH    B
________09B3:   7B F4                       ; CALF    0BF4        ;Point to 2nd screen
________09B5:   48 1F                       ; POP     B
________09B7:   0B                          ; MOV     A,C
________09B8:   07 07                       ; ANI     A,07
________09BA:   1B                          ; MOV     C,A
________09BB:   69 FF                       ; MVI     A,FF
________09BD:   48 2A                       ; CLC
________09BF:   48 30                       ; RAL
________09C1:   53                          ; DCR     C
________09C2:   FC                          ; JR      09BF
________09C3:   70 8B                       ; ANAX    H
________09C5:   3B                          ; STAX    H
________09C6:   08                          ; RET
;------------------------------------------------------------
;[PC+2] Draw Horizontal Line
; 1st byte is the bit-pattern (of the 8-dot vertical "char" of the LCD)
; 2nd byte is the length: 00-7F draws black lines; 80-FF draws white lines
CALT_99_09C7:   48 2F                       ; POP     D
________09C9:   2C                          ; LDAX    D+  	;SP+1
________09CA:   1B                          ; MOV     C,A
________09CB:   2C                          ; LDAX    D+		;SP+2
________09CC:   48 2E                       ; PUSH    D
________09CE:   1C                          ; MOV     D,A
________09CF:   07 7F                       ; ANI     A,7F
________09D1:   1A                          ; MOV     B,A
________09D2:   0C                          ; MOV     A,D
________09D3:   47 80                       ; ONI     A,80
________09D5:   C7                          ; JR      09DD

________09D6:   2B                          ; LDAX    H
________09D7:   60 8B                       ; ANA     A,C
________09D9:   3D                          ; STAX    H+
________09DA:   52                          ; DCR     B
________09DB:   FA                          ; JR      09D6
________09DC:   08                          ; RET

________09DD:   2B                          ; LDAX    H
________09DE:   60 9B                       ; ORA     A,C
________09E0:   3D                          ; STAX    H+
________09E1:   52                          ; DCR     B
________09E2:   FA                          ; JR      09DD
________09E3:   08                          ; RET
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
CALT_9A_09E4:   48 2F                       ; POP     D
________09E6:   2C                          ; LDAX    D+
________09E7:   1A                          ; MOV     B,A
________09E8:   38 9B                       ; STAW    9B
________09EA:   2C                          ; LDAX    D+
________09EB:   1B                          ; MOV     C,A
________09EC:   07 07                       ; ANI     A,07
________09EE:   38 9C                       ; STAW    9C
________09F0:   2C                          ; LDAX    D+
________09F1:   48 2E                       ; PUSH    D
________09F3:   38 9D                       ; STAW    9D
________09F5:   07 07                       ; ANI     A,07
________09F7:   41                          ; INR     A
________09F8:   48 1E                       ; PUSH    B
________09FA:   38 98                       ; STAW    98
________09FC:   24 A8 FF                    ; LXI     D,FFA8
________09FF:   70 2E C0 FF                 ; SDED    FFC0
________0A03:   1A                          ; MOV     B,A
________0A04:   6B 40                       ; MVI     C,40
________0A06:   45 9D 40                    ; ONIW    9D,40
________0A09:   6B 10                       ; MVI     C,10
________0A0B:   45 9D 08                    ; ONIW    9D,08
________0A0E:   CA                          ; JR      0A19
________0A0F:   52                          ; DCR     B
________0A10:   C1                          ; JR      0A12
________0A11:   D1                          ; JR      0A23

________0A12:   2B                          ; LDAX    H
________0A13:   A0                          ; CALT    00C0	; "(RLR A)x4"
________0A14:   07 0F                       ; ANI     A,0F
________0A16:   60 9B                       ; ORA     A,C
________0A18:   3C                          ; STAX    D+
________0A19:   52                          ; DCR     B
________0A1A:   C1                          ; JR      0A1C
________0A1B:   C7                          ; JR      0A23

________0A1C:   2D                          ; LDAX    H+
________0A1D:   07 0F                       ; ANI     A,0F
________0A1F:   60 9B                       ; ORA     A,C
________0A21:   3C                          ; STAX    D+
________0A22:   EC                          ; JR      0A0F

________0A23:   48 1F                       ; POP     B
________0A25:   05 9D BF                    ; ANIW    9D,BF
________0A28:   D9                          ; JR      0A42
;-----------------------------------------------------------
;[PC+3] Print Text on-Screen
;This prints a text string (pointed to by HL) anywhere on-screen.
;1st byte (after the call) is X-position, 2nd byte is Y-position.
;3rd byte sets a few options:
; bit: 76543210			S = write to screen 1/0
;      Sbbb####		      bbb = blank space between digits (0..7)
;			     #### = 1..F nybbles to write
;
CALT_9B_0A29:   48 2F                       ; POP     D
________0A2B:   2C                          ; LDAX    D+
________0A2C:   1A                          ; MOV     B,A
________0A2D:   38 9B                       ; STAW    9B
________0A2F:   2C                          ; LDAX    D+
________0A30:   1B                          ; MOV     C,A         ;Save X,Y position in BC
________0A31:   07 07                       ; ANI     A,07
________0A33:   38 9C                       ; STAW    9C
________0A35:   2C                          ; LDAX    D+
________0A36:   48 2E                       ; PUSH    D
________0A38:   38 9D                       ; STAW    9D
________0A3A:   07 0F                       ; ANI     A,0F        ;Get # of characters to write
________0A3C:   70 3E C0 FF                 ; SHLD    FFC0
________0A40:   38 98                       ; STAW    98  	;# saved in 98
________0A42:   28 9D                       ; LDAW    9D
________0A44:   47 80                       ; ONI     A,80	;Check if 0 (2nd screen) or 1 (1st screen)
________0A46:   C2                          ; JR      0A49
________0A47:   9D                          ; CALT    00BA	; "Set HL to screen (B,C)"
________0A48:   C2                          ; JR      0A4B

________0A49:   7B F4                       ; CALF    0BF4        ;This points to Sc 1
________0A4B:   70 7B C6 FF                 ; MOV     FFC6,C
________0A4F:   70 3E C2 FF                 ; SHLD    FFC2
________0A53:   24 4B 00                    ; LXI     D,004B
________0A56:   8B                          ; CALT    0096	; "HL <== HL+DE"
________0A57:   70 3E C4 FF                 ; SHLD    FFC4
________0A5B:   28 9D                       ; LDAW    9D
________0A5D:   A0                          ; CALT    00C0	; "(RLR A)x4"
________0A5E:   07 07                       ; ANI     A,07	;Get text spacing (0-7)
________0A60:   38 9D                       ; STAW    9D		;Save in 9D
;--
________0A62:   30 98                       ; DCRW    98		;The loop starts here
________0A64:   C1                          ; JR      0A66
________0A65:   08                          ; RET

________0A66:   45 C6 FF                    ; ONIW    C6,FF
________0A69:   DB                          ; JR      0A85
________0A6A:   70 3F C2 FF                 ; LHLD    FFC2
________0A6E:   70 3E C7 FF                 ; SHLD    FFC7
________0A72:   24 B0 FF                    ; LXI     D,FFB0
________0A75:   6A 04                       ; MVI     B,04
________0A77:   7B D3                       ; CALF    0BD3
________0A79:   57 80                       ; OFFI    A,80
________0A7B:   C9                          ; JR      0A85
________0A7C:   70 2F 9D FF                 ; LDED    FF9D
________0A80:   8D                          ; CALT    009A	; "HL <== HL+E"
________0A81:   70 3E C2 FF                 ; SHLD    FFC2
________0A85:   70 3F C4 FF                 ; LHLD    FFC4
________0A89:   70 3E C9 FF                 ; SHLD    FFC9
________0A8D:   24 B5 FF                    ; LXI     D,FFB5
________0A90:   6A 04                       ; MVI     B,04
________0A92:   7B D3                       ; CALF    0BD3	;Copy B*A bytes?
________0A94:   57 80                       ; OFFI    A,80
________0A96:   C9                          ; JR      0AA0
________0A97:   70 2F 9D FF                 ; LDED    FF9D
________0A9B:   8D                          ; CALT    009A	; "HL <== HL+E"
________0A9C:   70 3E C4 FF                 ; SHLD    FFC4
________0AA0:   70 6A 9C FF                 ; MOV     B,FF9C
________0AA4:   85                          ; CALT    008A	; "Clear A"
________0AA5:   52                          ; DCR     B
________0AA6:   C1                          ; JR      0AA8
________0AA7:   C5                          ; JR      0AAD

________0AA8:   48 2B                       ; STC
________0AAA:   48 30                       ; RAL
________0AAC:   F8                          ; JR      0AA5

________0AAD:   48 0E                       ; PUSH    V
________0AAF:   1B                          ; MOV     C,A
________0AB0:   7E 6A                       ; CALF    0E6A	;(FFB0 -> HL)
________0AB2:   6A 04                       ; MVI     B,04
________0AB4:   2B                          ; LDAX    H
________0AB5:   60 8B                       ; ANA     A,C
________0AB7:   3D                          ; STAX    H+
________0AB8:   52                          ; DCR     B
________0AB9:   FA                          ; JR      0AB4
________0ABA:   48 0F                       ; POP     V
________0ABC:   16 FF                       ; XRI     A,FF
________0ABE:   1B                          ; MOV     C,A
________0ABF:   6A 04                       ; MVI     B,04
________0AC1:   2B                          ; LDAX    H
________0AC2:   60 8B                       ; ANA     A,C
________0AC4:   3D                          ; STAX    H+
________0AC5:   52                          ; DCR     B
________0AC6:   FA                          ; JR      0AC1
________0AC7:   70 3F C0 FF                 ; LHLD    FFC0
________0ACB:   2D                          ; LDAX    H+
________0ACC:   70 3E C0 FF                 ; SHLD    FFC0
________0AD0:   9C                          ; CALT    00B8	;Byte -> Point to Font Graphic
________0AD1:   24 B0 FF                    ; LXI     D,FFB0
________0AD4:   14 B5 FF                    ; LXI     B,FFB5
________0AD7:   69 04                       ; MVI     A,04
________0AD9:   15 80 08                    ; ORIW    80,08
________0ADC:   7C 31                       ; CALF    0C31	;Roll graphics a bit (shift up/dn)
________0ADE:   45 C6 FF                    ; ONIW    C6,FF
________0AE1:   CD                          ; JR      0AEF
________0AE2:   70 2F C7 FF                 ; LDED    FFC7
________0AE6:   7E 6A                       ; CALF    0E6A	;(FFB0 -> HL)
________0AE8:   6A 04                       ; MVI     B,04
________0AEA:   15 80 10                    ; ORIW    80,10
________0AED:   7B D3                       ; CALF    0BD3	;Copy B*A bytes?
________0AEF:   55 C6 08                    ; OFFIW   C6,08
________0AF2:   CE                          ; JR      0B01
________0AF3:   70 2F C9 FF                 ; LDED    FFC9
________0AF7:   34 B5 FF                    ; LXI     H,FFB5
________0AFA:   6A 04                       ; MVI     B,04
________0AFC:   15 80 10                    ; ORIW    80,10
________0AFF:   7B D3                       ; CALF    0BD3	;Copy B*A bytes?
________0B01:   28 9B                       ; LDAW    9B
________0B03:   46 05                       ; ADI     A,05
________0B05:   1A                          ; MOV     B,A
________0B06:   28 9D                       ; LDAW    9D
________0B08:   60 C2                       ; ADD     A,B
________0B0A:   38 9B                       ; STAW    9B
________0B0C:   4F 54                       ; JRE     0A62
;------------------------------------------------------------
;Byte -> Point to Font Graphic
CALT_9C_0B0E:   37 64                       ; LTI     A,64	;If it's greater than 64, use cart font
________0B10:   C4                          ; JR      0B15        ;or...
________0B11:   24 C4 02                    ; LXI     D,02C4      ;Point to built-in font
________0B14:   C6                          ; JR      0B1B

________0B15:   70 2F 05 40                 ; LDED    4005       ;4005-6 on cart is the font pointer
________0B19:   66 64                       ; SUI     A,64
________0B1B:   70 2E 96 FF                 ; SDED    FF96
________0B1F:   1B                          ; MOV     C,A
________0B20:   07 0F                       ; ANI     A,0F
________0B22:   6D 05                       ; MVI     E,05
________0B24:   93                          ; CALT    00A6	; "Add A to "Pointer""
________0B25:   48 3E                       ; PUSH    H
________0B27:   0B                          ; MOV     A,C
________0B28:   A0                          ; CALT    00C0	; "(RLR A)x4"
________0B29:   07 0F                       ; ANI     A,0F
________0B2B:   6D 50                       ; MVI     E,50
________0B2D:   93                          ; CALT    00A6	; "Add A to "Pointer""
________0B2E:   48 2F                       ; POP     D
________0B30:   8B                          ; CALT    0096	; "HL <== HL+DE"
________0B31:   70 2F 96 FF                 ; LDED    FF96
________0B35:   8B                          ; CALT    0096	; "HL <== HL+DE"
________0B36:   08                          ; RET
;------------------------------------------------------------
;?? (Move some RAM around...)
CALT_92_0B37:   34 91 C5                    ; LXI     H,C591
________0B3A:   6A 0B                       ; MVI     B,0B

________0B3C:   48 3E                       ; PUSH    H
________0B3E:   48 1E                       ; PUSH    B
________0B40:   7B 4C                       ; CALF    0B4C
________0B42:   48 1F                       ; POP     B
________0B44:   48 3F                       ; POP     H
________0B46:   33                          ; DCX     H
________0B47:   33                          ; DCX     H
________0B48:   33                          ; DCX     H
________0B49:   52                          ; DCR     B
________0B4A:   F1                          ; JR      0B3C
________0B4B:   08                          ; RET
;------------------------------------------------------------
CALF____0B4C:   2D                          ; LDAX    H+
________0B4D:   38 9B                       ; STAW    9B
________0B4F:   1A                          ; MOV     B,A
________0B50:   46 07                       ; ADI     A,07
________0B52:   37 53                       ; LTI     A,53
________0B54:   08                          ; RET
________0B55:   2D                          ; LDAX    H+
________0B56:   1B                          ; MOV     C,A
________0B57:   07 07                       ; ANI     A,07
________0B59:   38 9C                       ; STAW    9C
________0B5B:   0B                          ; MOV     A,C
________0B5C:   46 07                       ; ADI     A,07
________0B5E:   37 47                       ; LTI     A,47
________0B60:   08                          ; RET
________0B61:   2B                          ; LDAX    H
________0B62:   38 9D                       ; STAW    9D
________0B64:   37 0C                       ; LTI     A,0C
________0B66:   08                          ; RET
________0B67:   9D                          ; CALT    00BA	; "Set HL to screen (B,C)"
________0B68:   70 3E 9E FF                 ; SHLD    FF9E
________0B6C:   0E                          ; MOV     A,H
________0B6D:   47 40                       ; ONI     A,40
________0B6F:   C5                          ; JR      0B75
________0B70:   24 B0 FF                    ; LXI     D,FFB0
________0B73:   7B D1                       ; CALF    0BD1
________0B75:   70 3F 9E FF                 ; LHLD    FF9E
________0B79:   24 4B 00                    ; LXI     D,004B
________0B7C:   8B                          ; CALT    0096	; "HL <== HL+DE"
________0B7D:   48 3E                       ; PUSH    H
________0B7F:   24 B8 FF                    ; LXI     D,FFB8
________0B82:   7B D1                       ; CALF    0BD1
________0B84:   7E 6A                       ; CALF    0E6A
________0B86:   24 C0 FF                    ; LXI     D,FFC0
________0B89:   6A 0F                       ; MVI     B,0F
________0B8B:   95                          ; CALT    00AA	; "((HL+) ==> (DE+))xB"
________0B8C:   28 9D                       ; LDAW    9D
________0B8E:   9E                          ; CALT    00BC	; "HL=C4B0+(A*$10)"
________0B8F:   24 B0 FF                    ; LXI     D,FFB0
________0B92:   14 B8 FF                    ; LXI     B,FFB8
________0B95:   7C 2F                       ; CALF    0C2F
________0B97:   48 3E                       ; PUSH    H
________0B99:   7E 6A                       ; CALF    0E6A
________0B9B:   24 C0 FF                    ; LXI     D,FFC0
________0B9E:   6A 0F                       ; MVI     B,0F
________0BA0:   2B                          ; LDAX    H
________0BA1:   70 94                       ; XRAX    D+
________0BA3:   3D                          ; STAX    H+
________0BA4:   52                          ; DCR     B
________0BA5:   FA                          ; JR      0BA0
________0BA6:   48 3F                       ; POP     H
________0BA8:   15 80 08                    ; ORIW    80,08
________0BAB:   24 B0 FF                    ; LXI     D,FFB0
________0BAE:   14 B8 FF                    ; LXI     B,FFB8
________0BB1:   7C 2F                       ; CALF    0C2F
________0BB3:   70 2F 9E FF                 ; LDED    FF9E
________0BB7:   0C                          ; MOV     A,D
________0BB8:   47 40                       ; ONI     A,40
________0BBA:   C7                          ; JR      0BC2
________0BBB:   7E 6A                       ; CALF    0E6A
________0BBD:   15 80 10                    ; ORIW    80,10
________0BC0:   7B D1                       ; CALF    0BD1
________0BC2:   48 2F                       ; POP     D
________0BC4:   34 A8 3D                    ; LXI     H,3DA8
________0BC7:   8B                          ; CALT    0096	; "HL <== HL+DE"
________0BC8:   48 1A                       ; SKN     CY
________0BCA:   08                          ; RET
________0BCB:   34 B8 FF                    ; LXI     H,FFB8
________0BCE:   15 80 10                    ; ORIW    80,10
;--
________0BD1:   6A 07                       ; MVI     B,07
________0BD3:   28 9B                       ; LDAW    9B
________0BD5:   57 80                       ; OFFI    A,80
________0BD7:   CA                          ; JR      0BE2
________0BD8:   37 4B                       ; LTI     A,4B
________0BDA:   D2                          ; JR      0BED
________0BDB:   48 0E                       ; PUSH    V
________0BDD:   2D                          ; LDAX    H+
________0BDE:   3C                          ; STAX    D+
________0BDF:   48 0F                       ; POP     V
________0BE1:   C7                          ; JR      0BE9
________0BE2:   45 80 10                    ; ONIW    80,10
________0BE5:   C2                          ; JR      0BE8
________0BE6:   32                          ; INX     H
________0BE7:   C1                          ; JR      0BE9

________0BE8:   22                          ; INX     D
________0BE9:   41                          ; INR     A
________0BEA:   00                          ; NOP
________0BEB:   52                          ; DCR     B
________0BEC:   E8                          ; JR      0BD5
________0BED:   05 80 EF                    ; ANIW    80,EF
________0BF0:   08                          ; RET
;------------------------------------------------------------
;Set HL to screen (B,C)
CALT_9D_0BF1:   34 B5 BF                    ; LXI     H,BFB5	;Point before Sc. RAM
________0BF4:   34 0D C2                    ; LXI     H,C20D	;Point before Sc.2 RAM
________0BF7:   6D 4B                       ; MVI     E,4B
________0BF9:   0B                          ; MOV     A,C
________0BFA:   6B 00                       ; MVI     C,00
________0BFC:   46 08                       ; ADI     A,08
________0BFE:   36 08                       ; SUINB   A,08
________0C00:   C7                          ; JR      0C08
________0C01:   48 0E                       ; PUSH    V
________0C03:   8D                          ; CALT    009A	; "HL <== HL+E"
________0C04:   48 0F                       ; POP     V
________0C06:   43                          ; INR     C
________0C07:   F6                          ; JR      0BFE
________0C08:   0A                          ; MOV     A,B
________0C09:   57 80                       ; OFFI    A,80
________0C0B:   08                          ; RET     
________0C0C:   1D                          ; MOV     E,A
________0C0D:   CA                          ; JR      0C18
;------------------------------------------------------------
;[PC+1] HL +- byte
CALT_8C_0C0E:   48 2F                       ; POP     D
________0C10:   2C                          ; LDAX    D+          ;Get byte after PC
________0C11:   48 2E                       ; PUSH    D
________0C13:   1D                          ; MOV     E,A
________0C14:   37 80                       ; LTI     A,80	;Add or subtract that byte
________0C16:   69 FF                       ; MVI     A,FF
;HL <== HL+E
CALT_8D_0C18:   69 00                       ; MVI     A,00
________0C1A:   1C                          ; MOV     D,A
;HL <== HL+DE
CALT_8B_0C1B:   0D                          ; MOV     A,E
________0C1C:   60 C7                       ; ADD     A,L
________0C1E:   1F                          ; MOV     L,A
________0C1F:   0C                          ; MOV     A,D
________0C20:   60 D6                       ; ADC     A,H
________0C22:   1E                          ; MOV     H,A
________0C23:   08                          ; RET
;------------------------------------------------------------
;HL=C4B0+(A*$10)
CALT_9E_0C24:   34 B0 C4                    ; LXI     H,C4B0
________0C27:   6D 10                       ; MVI     E,10
________0C29:   1A                          ; MOV     B,A
________0C2A:   52                          ; DCR     B
________0C2B:   C1                          ; JR      0C2D
________0C2C:   08                          ; RET

________0C2D:   8D                          ; CALT    009A	; "HL <== HL+E"
________0C2E:   FB                          ; JR      0C2A
;------------------------------------------------------------
CALF____0C2F:   69 07                       ; MVI     A,07
________0C31:   38 96                       ; STAW    96

________0C33:   28 9C                       ; LDAW    9C
________0C35:   38 97                       ; STAW    97
________0C37:   48 1E                       ; PUSH    B
________0C39:   6B 00                       ; MVI     C,00
________0C3B:   2D                          ; LDAX    H+
________0C3C:   30 97                       ; DCRW    97
________0C3E:   C1                          ; JR      0C40
________0C3F:   CD                          ; JR      0C4D

________0C40:   48 2A                       ; CLC
________0C42:   48 30                       ; RAL
________0C44:   48 0E                       ; PUSH    V
________0C46:   0B                          ; MOV     A,C
________0C47:   48 30                       ; RAL
________0C49:   1B                          ; MOV     C,A
________0C4A:   48 0F                       ; POP     V
________0C4C:   EF                          ; JR      0C3C

________0C4D:   45 80 08                    ; ONIW    80,08
________0C50:   C3                          ; JR      0C54
________0C51:   70 9A                       ; ORAX    D
________0C53:   C2                          ; JR      0C56

________0C54:   70 8A                       ; ANAX    D
________0C56:   3A                          ; STAX    D
________0C57:   0B                          ; MOV     A,C
________0C58:   48 1F                       ; POP     B
________0C5A:   45 80 08                    ; ONIW    80,08
________0C5D:   C3                          ; JR      0C61
________0C5E:   70 99                       ; ORAX    B
________0C60:   C2                          ; JR      0C63

________0C61:   70 89                       ; ANAX    B
________0C63:   39                          ; STAX    B
________0C64:   12                          ; INX     B
________0C65:   22                          ; INX     D
________0C66:   30 96                       ; DCRW    96
________0C68:   4F C9                       ; JRE     0C33
________0C6A:   05 80 F7                    ; ANIW    80,F7
________0C6D:   08                          ; RET
;------------------------------------------------------------
;(RLR A)x4	(Divides A by 16)
CALT_A0_0C6E:   48 31                       ; RLR
________0C70:   48 31                       ; RLR
CALF____0C72:   48 31                       ; RLR
________0C74:   48 31                       ; RLR
________0C76:   08                          ; RET
;------------------------------------------------------------
CALF____0C77:   6D 3C                       ; MVI     E,3C	; 60 decimal...
________0C79:   8D                          ; CALT    009A	; "HL <== HL+E"
________0C7A:   08                          ; RET
;------------------------------------------------------------
CALF____0C7B:   34 4D 05                    ; LXI     H,054D      ;"PUZZLE"
________0C7E:   9B                          ; CALT    00B6	; "[PC+3] Print Text on-Screen"
________0C7F:   03 00 16                    ; DB $03,$00,$16
________0C82:   7E 67                       ; CALF    0E67	;(C7F2 -> HL)
________0C84:   69 01                       ; MVI     A,01
________0C86:   38 83                       ; STAW    83
________0C88:   2D                          ; LDAX    H+
________0C89:   48 3E                       ; PUSH    H
________0C8B:   67 FF                       ; NEI     A,FF	;If it's a terminator, loop
________0C8D:   4E 27                       ; JRE     0CB6
________0C8F:   9C                          ; CALT    00B8	;Byte -> Point to Font Graphic
________0C90:   94                          ; CALT    00A8	; "XCHG HL,DE"
________0C91:   28 83                       ; LDAW    83
________0C93:   7C BF                       ; CALF    0CBF        ;(Scroll text)
________0C95:   48 2E                       ; PUSH    D
________0C97:   6D 51                       ; MVI     E,51
________0C99:   8D                          ; CALT    009A	; "HL <== HL+E"
________0C9A:   48 2F                       ; POP     D
________0C9C:   6A 04                       ; MVI     B,04
________0C9E:   2C                          ; LDAX    D+
________0C9F:   48 30                       ; RAL
________0CA1:   3D                          ; STAX    H+
________0CA2:   52                          ; DCR     B
________0CA3:   FA                          ; JR      0C9E
________0CA4:   20 83                       ; INRW    83
________0CA6:   48 3F                       ; POP     H
________0CA8:   75 83 0D                    ; EQIW    83,0D
________0CAB:   4F DB                       ; JRE     0C88
________0CAD:   34 FF C7                    ; LXI     H,C7FF
________0CB0:   2B                          ; LDAX    H
________0CB1:   7E 3B                       ; CALF    0E3B	;Scroll text; XOR RAM
________0CB3:   90                          ; CALT    00A0	; "C258+ ==> C000+"
________0CB4:   81                          ; CALT    0082	;Copy Screen RAM to LCD Driver
________0CB5:   08                          ; RET
;------------------------------------------------------------
________0CB6:   70 69 83 FF                 ; MOV     A,FF83	;A "LDAW 83" would've been faster here...
________0CBA:   70 79 FF C7                 ; MOV     C7FF,A
________0CBE:   E5                          ; JR      0CA4
;------------------------------------------------------------
CALF____0CBF:   37 09                       ; LTI     A,09
________0CC1:   D0                          ; JR      0CD2
________0CC2:   37 05                       ; LTI     A,05
________0CC4:   D3                          ; JR      0CD8
________0CC5:   34 D8 C2                    ; LXI     H,C2D8
________0CC8:   67 04                       ; NEI     A,04
________0CCA:   08                          ; RET
________0CCB:   6A 0F                       ; MVI     B,0F
________0CCD:   33                          ; DCX     H
________0CCE:   52                          ; DCR     B
________0CCF:   FD                          ; JR      0CCD
________0CD0:   41                          ; INR     A
________0CD1:   F6                          ; JR      0CC8
________0CD2:   34 04 C4                    ; LXI     H,C404
________0CD5:   66 08                       ; SUI     A,08
________0CD7:   F0                          ; JR      0CC8
;------------------------------------------------------------
________0CD8:   34 6E C3                    ; LXI     H,C36E
________0CDB:   66 04                       ; SUI     A,04
________0CDD:   EA                          ; JR      0CC8
;------------------------------------------------------------
________0CDE:   34 B8 04                    ; LXI     H,04B8	;Point to scroll text
________0CE1:   D8                          ; JR      0CFA
;------------------------------------------------------------
CALF	;Slide the top line for the scroller.
________0CE2:   20 82                       ; INRW    82
________0CE4:   00                          ; NOP
________0CE5:   34 5B C2                    ; LXI     H,C25B
________0CE8:   24 58 C2                    ; LXI     D,C258
________0CEB:   6A 47                       ; MVI     B,47
________0CED:   95                          ; CALT    00AA	; "((HL+) ==> (DE+))xB"
________0CEE:   55 82 01                    ; OFFIW   82,01
________0CF1:   C4                          ; JR      0CF6
________0CF2:   34 A3 FF                    ; LXI     H,FFA3
________0CF5:   D6                          ; JR      0D0C

________0CF6:   70 3F D6 FF                 ; LHLD    FFD6
________0CFA:   2D                          ; LDAX    H+
________0CFB:   67 FF                       ; NEI     A,FF	;If terminator...
________0CFD:   E0                          ; JR      0CDE	;...reset scroll
________0CFE:   70 3E D6 FF                 ; SHLD    FFD6
________0D02:   9C                          ; CALT    00B8	;Byte -> Point to Font Graphic
________0D03:   6A 04                       ; MVI     B,04	;(5 pixels wide)
________0D05:   24 A0 FF                    ; LXI     D,FFA0
________0D08:   95                          ; CALT    00AA	; "((HL+) ==> (DE+))xB"
________0D09:   34 A0 FF                    ; LXI     H,FFA0      ;First copy it to RAM...

________0D0C:   24 A0 C2                    ; LXI     D,C2A0	;Then put it on screen, 3 pixels at a time.
________0D0F:   6A 02                       ; MVI     B,02

;((HL+) ==> (DE+))xB
CALT_95_0D11:   2D                          ; LDAX    H+
________0D12:   3C                          ; STAX    D+
________0D13:   52                          ; DCR     B
________0D14:   FC                          ; JR      0D11
________0D15:   08                          ; RET
;------------------------------------------------------------
________0D16:   20 DA                       ; INRW    DA
________0D18:   34 DA FF                    ; LXI     H,FFDA
________0D1B:   2B                          ; LDAX    H
________0D1C:   38 D0                       ; STAW    D0
________0D1E:   C4                          ; JR      0D23

;Draw a spiral dot-by-dot
CALF____0D1F:   65 D0 FF                    ; NEIW    D0,FF
________0D22:   F3                          ; JR      0D16
________0D23:   28 D1                       ; LDAW    D1		;This stores the direction
________0D25:   67 00                       ; NEI     A,00	;that the spiral draws in...
________0D27:   DE                          ; JR      0D46
________0D28:   70 1F D2 FF                 ; LBCD    FFD2
________0D2C:   67 01                       ; NEI     A,01
________0D2E:   4E 22                       ; JRE     0D52
________0D30:   67 02                       ; NEI     A,02
________0D32:   4E 23                       ; JRE     0D57
________0D34:   67 03                       ; NEI     A,03
________0D36:   4E 24                       ; JRE     0D5C

________0D38:   52                          ; DCR     B
________0D39:   0A                          ; MOV     A,B
________0D3A:   38 D3                       ; STAW    D3
________0D3C:   79 AD                       ; CALF    09AD	;Draw a dot on-screen
________0D3E:   30 D0                       ; DCRW    D0		;Decrement length counter...
________0D40:   08                          ; RET
________0D41:   69 01                       ; MVI     A,01	;If zero, turn corners
________0D43:   38 D1                       ; STAW    D1
________0D45:   08                          ; RET
;------------------------------------------------------------
________0D46:   14 24 25                    ; LXI     B,2524
________0D49:   70 1E D2 FF                 ; SBCD    FFD2
________0D4D:   79 AD                       ; CALF    09AD
________0D4F:   20 D1                       ; INRW    D1
________0D51:   08                          ; RET
________0D52:   53                          ; DCR     C
________0D53:   0B                          ; MOV     A,C
________0D54:   38 D2                       ; STAW    D2
________0D56:   C9                          ; JR      0D60
;------------------------------------------------------------
________0D57:   42                          ; INR     B
________0D58:   0A                          ; MOV     A,B
________0D59:   38 D3                       ; STAW    D3
________0D5B:   C4                          ; JR      0D60
;------------------------------------------------------------
________0D5C:   43                          ; INR     C
________0D5D:   0B                          ; MOV     A,C
________0D5E:   38 D2                       ; STAW    D2
________0D60:   79 AD                       ; CALF    09AD
________0D62:   30 D0                       ; DCRW    D0
________0D64:   08                          ; RET
________0D65:   20 D1                       ; INRW    D1
________0D67:   08                          ; RET

;------------------------------------------------------------
;Draw a thick black frame around the screen
CALF____0D68:   34 A3 C2                    ; LXI     H,C2A3      ;Point to 2nd screen
________0D6B:   69 FF                       ; MVI     A,FF	;Black character
________0D6D:   6A 05                       ; MVI     B,05	;Write 6 characters
________0D6F:   9F                          ; CALT    00BE	; "A ==> (HL+)xB"
________0D70:   69 1F                       ; MVI     A,1F	;Then a char with 5 upper dots filled
________0D72:   6A 3E                       ; MVI     B,3E	;Times 63
________0D74:   9F                          ; CALT    00BE	; "A ==> (HL+)xB"
________0D75:   6B 04                       ; MVI     C,04
________0D77:   6A 0B                       ; MVI     B,0B
________0D79:   69 FF                       ; MVI     A,FF
________0D7B:   9F                          ; CALT    00BE	; "A ==> (HL+)xB"
________0D7C:   85                          ; CALT    008A	; "Clear A"
________0D7D:   6A 3E                       ; MVI     B,3E
________0D7F:   9F                          ; CALT    00BE	; "A ==> (HL+)xB"
________0D80:   53                          ; DCR     C
________0D81:   F5                          ; JR      0D77
________0D82:   69 FF                       ; MVI     A,FF
________0D84:   6A 0B                       ; MVI     B,0B
________0D86:   9F                          ; CALT    00BE	; "A ==> (HL+)xB"
________0D87:   69 F0                       ; MVI     A,F0
________0D89:   6A 3E                       ; MVI     B,3E
________0D8B:   9F                          ; CALT    00BE	; "A ==> (HL+)xB"
________0D8C:   69 FF                       ; MVI     A,FF
________0D8E:   6A 05                       ; MVI     B,05
________0D90:   9F                          ; CALT    00BE	; "A ==> (HL+)xB"
________0D91:   08                          ; RET
;------------------------------------------------------------
;This draws the puzzle grid, I think...
CALF____0D92:   65 D5 00                    ; NEIW    D5,00
________0D95:   CC                          ; JR      0DA2
________0D96:   65 D5 01                    ; NEIW    D5,01
________0D99:   CB                          ; JR      0DA5
________0D9A:   75 D5 02                    ; EQIW    D5,02
________0D9D:   4E 24                       ; JRE     0DC3
________0D9F:   34 D8 C2                    ; LXI     H,C2D8
________0DA2:   34 B8 C2                    ; LXI     H,C2B8
________0DA5:   34 C8 C2                    ; LXI     H,C2C8
________0DA8:   99                          ; CALT    00B2	; "[PC+2] Draw Horizontal Line"
________0DA9:   F0 00                       ; DB $F0,$00
________0DAB:   6A 04                       ; MVI     B,04
________0DAD:   48 1E                       ; PUSH    B
________0DAF:   6D 4A                       ; MVI     E,4A
________0DB1:   8D                          ; CALT    009A	; "HL <== HL+E"
________0DB2:   99                          ; CALT    00B2	; "[PC+2] Draw Horizontal Line"
________0DB3:   FF 00                       ; DB $FF,$00
________0DB5:   48 1F                       ; POP     B
________0DB7:   52                          ; DCR     B
________0DB8:   F4                          ; JR      0DAD
________0DB9:   6D 4A                       ; MVI     E,4A
________0DBB:   8D                          ; CALT    009A	; "HL <== HL+E"
________0DBC:   99                          ; CALT    00B2	; "[PC+2] Draw Horizontal Line"
________0DBD:   1F 00                       ; DB $1F,00
________0DBF:   20 D5                       ; INRW    D5
________0DC1:   4F CF                       ; JRE     0D92
________0DC3:   34 3E C3                    ; LXI     H,C33E
________0DC6:   99                          ; CALT    00B2	; "[PC+2] Draw Horizontal Line"
________0DC7:   10 40                       ; DB $10,$40
________0DC9:   34 D4 C3                    ; LXI     H,C3D4
________0DCC:   99                          ; CALT    00B2	; "[PC+2] Draw Horizontal Line"
________0DCD:   10 40                       ; DB $10,$40
________0DCF:   85                          ; CALT    008A	; "Clear A"
________0DD0:   38 D5                       ; STAW    D5
________0DD2:   08                          ; RET
;------------------------------------------------------------
________0DD3:   67 01                       ; NEI     A,01
________0DD5:   D8                          ; JR      0DEE
________0DD6:   67 04                       ; NEI     A,04
________0DD8:   4E 22                       ; JRE     0DFC
________0DDA:   67 02                       ; NEI     A,02
________0DDC:   4E 2C                       ; JRE     0E0A

________0DDE:   70 69 FF C7                 ; MOV     A,C7FF   	;More puzzle grid drawing, probably...
________0DE2:   07 03                       ; ANI     A,03
________0DE4:   67 01                       ; NEI     A,01
________0DE6:   18                          ; RETS

________0DE7:   14 FF 12                    ; LXI     B,12FF
________0DEA:   15 A2 FF                    ; ORIW    A2,FF
________0DED:   CD                          ; JR      0DFB
;------------------------------------------------------------
________0DEE:   70 69 FF C7                 ; MOV     A,C7FF
________0DF2:   37 09                       ; LTI     A,09
________0DF4:   18                          ; RETS

________0DF5:   14 04 0D                    ; LXI     B,0D04
________0DF8:   05 A2 00                    ; ANIW    A2,00
________0DFB:   DB                          ; JR      0E17
;------------------------------------------------------------
________0DFC:   70 69 FF C7                 ; MOV     A,C7FF
________0E00:   27 04                       ; GTI     A,04
________0E02:   18                          ; RETS
________0E03:   14 FC 0F                    ; LXI     B,0FFC
________0E06:   05 A2 00                    ; ANIW    A2,00
________0E09:   CD                          ; JR      0E17
;------------------------------------------------------------
________0E0A:   70 69 FF C7                 ; MOV     A,C7FF
________0E0E:   47 03                       ; ONI     A,03
________0E10:   18                          ; RETS

________0E11:   14 01 11                    ; LXI     B,1101
________0E14:   15 A2 FF                    ; ORIW    A2,FF
________0E17:   70 69 FF C7                 ; MOV     A,C7FF
________0E1B:   1D                          ; MOV     E,A
________0E1C:   70 79 FE C7                 ; MOV     C7FE,A
________0E20:   60 C3                       ; ADD     A,C
________0E22:   1C                          ; MOV     D,A
________0E23:   70 79 FF C7                 ; MOV     C7FF,A
________0E27:   34 F1 C7                    ; LXI     H,C7F1
________0E2A:   0C                          ; MOV     A,D
________0E2B:   51                          ; DCR     A
________0E2C:   C1                          ; JR      0E2E
________0E2D:   C2                          ; JR      0E30

________0E2E:   32                          ; INX     H
________0E2F:   FB                          ; JR      0E2B

________0E30:   0D                          ; MOV     A,E
________0E31:   24 F1 C7                    ; LXI     D,C7F1
________0E34:   51                          ; DCR     A
________0E35:   C3                          ; JR      0E39
________0E36:   54 F8 08                    ; JMP     08F8

________0E39:   22                          ; INX     D
________0E3A:   F9                          ; JR      0E34
;------------------------------------------------------------
CALF____0E3B:   7C BF                       ; CALF    0CBF
________0E3D:   99                          ; CALT    00B2	; "[PC+2] Draw Horizontal Line"
________0E3E:   F0 10                       ; DB $F0,$10
________0E40:   6D 3A                       ; MVI     E,3A
________0E42:   8D                          ; CALT    009A	; "HL <== HL+E"
________0E43:   99                          ; CALT    00B2	; "[PC+2] Draw Horizontal Line"
________0E44:   FF 10                       ; DB $FF,$10
________0E46:   6D 3A                       ; MVI     E,3A
________0E48:   8D                          ; CALT    009A	; "HL <== HL+E"
________0E49:   99                          ; CALT    00B2	; "[PC+2] Draw Horizontal Line"
________0E4A:   1F 10                       ; DB $1F,$10
________0E4C:   08                          ; RET
;------------------------------------------------------------
; Turns on a hardware timer
CALF____0E4D:   48 24                       ; DI
________0E4F:   69 07                       ; MVI     A,07
________0E51:   4D C9                       ; MOV     TMM,A
________0E53:   69 74                       ; MVI     A,74
________0E55:   4D C6                       ; MOV     T0,A
________0E57:   05 80 FC                    ; ANIW    80,FC
________0E5A:   19                          ; STM
________0E5B:   48 20                       ; EI
________0E5D:   08                          ; RET
;------------------------------------------------------------
; Loads (DE/)HL with various common addresses
CALF____0E5E:   24 00 C0                    ; LXI     D,C000
________0E61:   34 58 C2                    ; LXI     H,C258
CALF____0E64:   34 EC 04                    ; LXI     H,04EC
CALF____0E67:   34 F2 C7                    ; LXI     H,C7F2
CALF____0E6A:   34 B0 FF                    ; LXI     H,FFB0
________0E6D:   08                          ; RET
;------------------------------------------------------------

;[PC+1] ?? (Unpack 8 bytes -> 64 bytes (Twice!))
CALT_A8_0E6E:   48 3F                       ; POP     H
________0E70:   2D                          ; LDAX    H+
________0E71:   48 3E                       ; PUSH    H
________0E73:   9E                          ; CALT    00BC	; "HL=C4B0+(A*$10)"
________0E74:   94                          ; CALT    00A8	; "XCHG HL,DE"
________0E75:   44 78 0E                    ; CALL    0E78        ;This call means the next code runs twice

________0E78:   6A 07                       ; MVI     B,7
________0E7A:   6B 07                       ; MVI     C,7
________0E7C:   7E 6A                       ; CALF    0E6A	;(FFB0->HL)
________0E7E:   2A                          ; LDAX    D  		;In this loop, the byte at (FFB0)
________0E7F:   48 30                       ; RAL			;Has its bits split up into 8 bytes
________0E81:   48 0E                       ; PUSH    V		;And this loop runs 8 times...
________0E83:   2B                          ; LDAX    H
________0E84:   48 31                       ; RLR
________0E86:   3D                          ; STAX    H+
________0E87:   48 0F                       ; POP     V
________0E89:   53                          ; DCR     C
________0E8A:   F4                          ; JR      0E7F
________0E8B:   22                          ; INX     D
________0E8C:   52                          ; DCR     B
________0E8D:   EC                          ; JR      0E7A

________0E8E:   48 2E                       ; PUSH    D
________0E90:   33                          ; DCX     H
________0E91:   23                          ; DCX     D
________0E92:   6A 07                       ; MVI     B,7
________0E94:   96                          ; CALT    00AC	; "((HL-) ==> (DE-))xB"
________0E95:   48 2F                       ; POP     D
________0E97:   08                          ; RET
;------------------------------------------------------------
;[PC+1] ?? (Unpack & Roll 8 bits)
CALT_A9_0E98:   48 3F                       ; POP     H
________0E9A:   2D                          ; LDAX    H+
________0E9B:   48 3E                       ; PUSH    H
________0E9D:   48 0E                       ; PUSH    V
________0E9F:   7E 73                       ; CALF    0E73
________0EA1:   48 0F                       ; POP     V
________0EA3:   C5                          ; JR      0EA9
;-----------------------------------------------------------
;[PC+1] ?? (Roll 8 bits -> Byte?)
CALT_AA_0EA4:   48 3F                       ; POP     H
________0EA6:   2D                          ; LDAX    H+
________0EA7:   48 3E                       ; PUSH    H
________0EA9:   9E                          ; CALT    00BC	; "HL=C4B0+(A*$10)"
________0EAA:   24 BF FF                    ; LXI     D,FFBF
________0EAD:   94                          ; CALT    00A8	; "XCHG HL,DE"
________0EAE:   48 2E                       ; PUSH    D
________0EB0:   6B 0F                       ; MVI     C,0F
________0EB2:   6A 07                       ; MVI     B,8-1
________0EB4:   2A                          ; LDAX    D
________0EB5:   48 30                       ; RAL 
________0EB7:   48 0E                       ; PUSH    V
________0EB9:   2B                          ; LDAX    H
________0EBA:   48 31                       ; RLR
________0EBC:   3B                          ; STAX    H
________0EBD:   48 0F                       ; POP     V
________0EBF:   52                          ; DCR     B
________0EC0:   F4                          ; JR      0EB5
________0EC1:   33                          ; DCX     H
________0EC2:   22                          ; INX     D
________0EC3:   53                          ; DCR     C
________0EC4:   ED                          ; JR      0EB2
________0EC5:   48 2F                       ; POP     D
________0EC7:   34 B8 FF                    ; LXI     H,FFB8
________0ECA:   7E CE                       ; CALF    0ECE
________0ECC:   7E 6A                       ; CALF    0E6A

CALF____0ECE:   6A 07                       ; MVI     B,8-1
________0ED0:   95                          ; CALT    00AA	; "((HL+) ==> (DE+))xB"
________0ED1:   08                          ; RET     
;------------------------------------------------------------
;[PC+x] ?? (Add/Sub multiple bytes)
CALT_AB_0ED2:   48 3F                       ; POP     H
________0ED4:   2D                          ; LDAX    H+
________0ED5:   48 3E                       ; PUSH    H
________0ED7:   1A                          ; MOV     B,A
________0ED8:   07 0F                       ; ANI     A,0F
________0EDA:   38 96                       ; STAW    96
________0EDC:   0A                          ; MOV     A,B
________0EDD:   A0                          ; CALT    00C0	; "(RLR A)x4"
________0EDE:   07 0F                       ; ANI     A,0F
________0EE0:   37 0D                       ; LTI     A,0D
________0EE2:   08                          ; RET     
________0EE3:   38 97                       ; STAW    97
________0EE5:   30 97                       ; DCRW    97
________0EE7:   C8                          ; JR      0EF0        ;Based on 97, jump to cart (4007)!
________0EE8:   91                          ; CALT    00A2	; "CALT A0, CALT A4"
________0EE9:   48 1F                       ; POP     B
________0EEB:   70 1F 07 40                 ; LBCD    4007        ;Read vector from $4007 on cart, however...
________0EEF:   73                          ; JB			;...all 5 Pokekon games have "0000" there!
________0EF0:   48 3F                       ; POP     H
________0EF2:   2D                          ; LDAX    H+
________0EF3:   48 3E                       ; PUSH    H
________0EF5:   38 98                       ; STAW    98
________0EF7:   07 0F                       ; ANI     A,0F
________0EF9:   37 0C                       ; LTI     A,0C
________0EFB:   E9                          ; JR      0EE5
________0EFC:   34 6E C5                    ; LXI     H,C56E
________0EFF:   32                          ; INX     H
________0F00:   32                          ; INX     H
________0F01:   32                          ; INX     H
________0F02:   51                          ; DCR     A
________0F03:   FB                          ; JR      0EFF
________0F04:   24 96 FF                    ; LXI     D,FF96
________0F07:   45 98 80                    ; ONIW    98,80
________0F0A:   C5                          ; JR      0F10
________0F0B:   2B                          ; LDAX    H
________0F0C:   70 E2                       ; SUBX    D
________0F0E:   3B                          ; STAX    H
________0F0F:   C8                          ; JR      0F18

________0F10:   45 98 40                    ; ONIW    98,40
________0F13:   C4                          ; JR      0F18
________0F14:   2B                          ; LDAX    H
________0F15:   70 C2                       ; ADDX    D
________0F17:   3B                          ; STAX    H
________0F18:   33                          ; DCX     H
________0F19:   45 98 10                    ; ONIW    98,10
________0F1C:   C6                          ; JR      0F23

________0F1D:   2B                          ; LDAX    H
________0F1E:   70 C2                       ; ADDX    D
________0F20:   3B                          ; STAX    H
________0F21:   4F C2                       ; JRE     0EE5

________0F23:   45 98 20                    ; ONIW    98,20
________0F26:   FA                          ; JR      0F21
________0F27:   2B                          ; LDAX    H
________0F28:   70 E2                       ; SUBX    D
________0F2A:   3B                          ; STAX    H
________0F2B:   F5                          ; JR      0F21
;------------------------------------------------------------
;Invert Screen RAM (C000~)
CALT_A6_0F2C:   34 00 C0                    ; LXI     H,C000
;Invert Screen 2 RAM (C258~)
CALT_A7_0F2F:   34 58 C2                    ; LXI     H,C258
________0F32:   6B 02                       ; MVI     C,02

________0F34:   6A C7                       ; MVI     B,C7
________0F36:   7F 3B                       ; CALF    0F3B
________0F38:   53                          ; DCR     C
________0F39:   FA                          ; JR      0F34
________0F3A:   08                          ; RET
;------------------------------------------------------------
;Invert bytes xB
CALF____0F3B:   2B                          ; LDAX    H
________0F3C:   16 FF                       ; XRI     A,FF
________0F3E:   3D                          ; STAX    H+
________0F3F:   52                          ; DCR     B
________0F40:   FA                          ; JR      0F3B
________0F41:   08                          ; RET
;------------------------------------------------------------
;[PC+1] Invert 8 bytes at (C4B8+A*$10)
CALT_A5_0F42:   48 3F                       ; POP     H
________0F44:   2D                          ; LDAX    H+
________0F45:   48 3E                       ; PUSH    H
________0F47:   37 0C                       ; LTI     A,0C
________0F49:   08                          ; RET

________0F4A:   9E                          ; CALT    00BC	; "HL=C4B0+(A*$10)"
________0F4B:   6D 08                       ; MVI     E,08
________0F4D:   8D                          ; CALT    009A	; "HL <== HL+E"
________0F4E:   6A 07                       ; MVI     B,07
________0F50:   EA                          ; JR      0F3B
;------------------------------------------------------------
;for the addition routine below...
________0F51:   0E                          ; MOV     A,H
________0F52:   38 B0                       ; STAW    B0
________0F54:   0F                          ; MOV     A,L
________0F55:   38 B1                       ; STAW    B1
________0F57:   34 B1 FF                    ; LXI     H,FFB1
________0F5A:   28 96                       ; LDAW    96
________0F5C:   D0                          ; JR      0F6D
;------------------------------------------------------------
;[PC+1] 8~32-bit Add/Subtract (dec/hex)
;Source pointed to by HL & DE.  Extra byte sets a few options:
; bit: 76543210			B = 0/1: Work in decimal (BCD) / regular Hex
;      BA2211HD			A = 0/1: Add / Subtract numbers
;				22 = byte length of (HL)
;				11 = byte length of (DE)
;				H = 1: HL gets bytes from $FFB1
;				D = 1: DE gets bytes from $FFA2
CALT_A4_0F5D:   48 1F                       ; POP     B
________0F5F:   29                          ; LDAX    B
________0F60:   12                          ; INX     B
________0F61:   48 1E                       ; PUSH    B
________0F63:   38 96                       ; STAW    96		;Get extra byte, keep in 96
________0F65:   57 01                       ; OFFI    A,01	;If set, load from $FFA2 instead
________0F67:   24 A2 FF                    ; LXI     D,FFA2
________0F6A:   57 02                       ; OFFI    A,02	;If set, load from $FFB1
________0F6C:   E4                          ; JR      0F51

________0F6D:   7C 72                       ; CALF    0C72	;"RLR A" x2
________0F6F:   1A                          ; MOV     B,A		;Get our length bits (8-32 bits)
________0F70:   07 03                       ; ANI     A,03
________0F72:   1B                          ; MOV     C,A
________0F73:   0A                          ; MOV     A,B
________0F74:   7C 72                       ; CALF    0C72        ;"RLR A" x2
________0F76:   07 03                       ; ANI     A,03
________0F78:   1A                          ; MOV     B,A
________0F79:   45 96 40                    ; ONIW    96,40	;Do we subtract instead of add?
________0F7C:   C6                          ; JR      0F83
________0F7D:   45 96 80                    ; ONIW    96,80	;Do we work in binary-coded decimal?
________0F80:   D8                          ; JR      0F99
________0F81:   4E 2D                       ; JRE     0FB0

________0F83:   45 96 80                    ; ONIW    96,80
________0F86:   4E 39                       ; JRE     0FC1

________0F88:   48 2A                       ; CLC
________0F8A:   2A                          ; LDAX    D
________0F8B:   70 D3                       ; ADCX    H   	;Add HL-,DE-
________0F8D:   3A                          ; STAX    D
________0F8E:   52                          ; DCR     B
________0F8F:   C1                          ; JR      0F91
________0F90:   08                          ; RET

________0F91:   23                          ; DCX     D
________0F92:   53                          ; DCR     C
________0F93:   C3                          ; JR      0F97
________0F94:   7F D3                       ; CALF    0FD3	;Clear C,HL
________0F96:   F3                          ; JR      0F8A

________0F97:   33                          ; DCX     H
________0F98:   F1                          ; JR      0F8A

________0F99:   48 2B                       ; STC
________0F9B:   69 99                       ; MVI     A,99
________0F9D:   56 00                       ; ACI     A,00
________0F9F:   70 E3                       ; SUBX    H
________0FA1:   70 C2                       ; ADDX    D
________0FA3:   61                          ; DAA
________0FA4:   3A                          ; STAX    D
________0FA5:   52                          ; DCR     B
________0FA6:   C1                          ; JR      0FA8
________0FA7:   08                          ; RET     

________0FA8:   23                          ; DCX     D
________0FA9:   53                          ; DCR     C
________0FAA:   C3                          ; JR      0FAE
________0FAB:   7F D3                       ; CALF    0FD3
________0FAD:   ED                          ; JR      0F9B

________0FAE:   33                          ; DCX     H
________0FAF:   EB                          ; JR      0F9B
;-----
________0FB0:   48 2A                       ; CLC
________0FB2:   2A                          ; LDAX    D
________0FB3:   70 F3                       ; SBBX    H
________0FB5:   3A                          ; STAX    D
________0FB6:   52                          ; DCR     B
________0FB7:   C1                          ; JR      0FB9
________0FB8:   08                          ; RET

________0FB9:   23                          ; DCX     D
________0FBA:   53                          ; DCR     C
________0FBB:   C3                          ; JR      0FBF
________0FBC:   7F D3                       ; CALF    0FD3
________0FBE:   F3                          ; JR      0FB2

________0FBF:   33                          ; DCX     H
________0FC0:   F1                          ; JR      0FB2
;------
________0FC1:   48 2A                       ; CLC
________0FC3:   2A                          ; LDAX    D
________0FC4:   70 D3                       ; ADCX    H
________0FC6:   61                          ; DAA
________0FC7:   3A                          ; STAX    D
________0FC8:   52                          ; DCR     B
________0FC9:   C1                          ; JR      0FCB
________0FCA:   08                          ; RET

________0FCB:   23                          ; DCX     D
________0FCC:   53                          ; DCR     C
________0FCD:   C3                          ; JR      0FD1
________0FCE:   7F D3                       ; CALF    0FD3
________0FD0:   F2                          ; JR      0FC3

________0FD1:   33                          ; DCX     H
________0FD2:   F0                          ; JR      0FC3
;------------------------------------------------------------
;Clear C,HL (for the add/sub routine above)
CALF____0FD3:   6B 00                       ; MVI     C,00
________0FD5:   34 00 00                    ; LXI     H,0000
________0FD8:   08                          ; RET
;------------------------------------------------------------
;[PC+1] INC/DEC Range of bytes from (HL)
;Extra byte's high bit sets Inc/Dec; rest is the byte counter.
CALT_AC_0FD9:   48 1F                       ; POP     B
________0FDB:   29                          ; LDAX    B
________0FDC:   12                          ; INX     B
________0FDD:   48 1E                       ; PUSH    B
________0FDF:   1A                          ; MOV     B,A
________0FE0:   47 80                       ; ONI     A,80	;do we Dec?
________0FE2:   CE                          ; JR      0FF1

________0FE3:   07 7F                       ; ANI     A,7F	;Counter can be 00-7F
________0FE5:   1A                          ; MOV     B,A
________0FE6:   2B                          ; LDAX    H		;Load a byte
________0FE7:   66 01                       ; SUI     A,01	;Decrement it
________0FE9:   3F                          ; STAX    H-
________0FEA:   48 1A                       ; SKN     CY		;Quit our function if any byte= -1!
________0FEC:   C1                          ; JR      0FEE
________0FED:   08                          ; RET

________0FEE:   52                          ; DCR     B
________0FEF:   F6                          ; JR      0FE6
________0FF0:   08                          ; RET

________0FF1:   2B                          ; LDAX    H		;or Load a byte
________0FF2:   46 01                       ; ADI     A,01	;Add 1
________0FF4:   3F                          ; STAX    H-
________0FF5:   48 1A                       ; SKN     CY		;Quit if any byte overflows!
________0FF7:   C1                          ; JR      0FF9
________0FF8:   08                          ; RET

________0FF9:   52                          ; DCR     B
________0FFA:   F6                          ; JR      0FF1
________0FFB:   08                          ; RET			;What a weird way to end a BIOS...
;------------------------------------------------------------
________0FFC:   00 00 00 00                 ; DB 0,0,0,0		;Unused bytes (and who could blame 'em?)
	
; EOF!
