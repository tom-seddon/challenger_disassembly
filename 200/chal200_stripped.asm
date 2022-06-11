;Commentary by Greg Cook, 26 March 2022
;Taken from http://regregex.bbcmicro.net/chal200.asm.txt
8000 EQUB &00                   ;Language entry
8001 EQUB &00
8002 EQUB &00
8003 4C 2F 80  JMP P02F         ;Service entry
8006 EQUB &82                   ;rom type: service only
8007 EQUB &1A                   ;Copyright offset pointer
8008 EQUB &20                   ;Version No.
8009 EQUS "Challenger 3"        ;title
8015 EQUB &00                   ;terminator byte
8016 EQUS "2.00"                ;version string
801A EQUB &00                   ;terminator byte
801B EQUS "(C)1987 Slogger"     ;copyright string validated by MOS
802A EQUB &00                   ;terminator byte
.P02B                           ;Issue Filing System Call
802B 6C 1E 02  JMP (&021E)
                                ;unreachable code
802E 60        RTS
.P02F                           ;ROM service
802F C9 01     CMP #&01
8031 D0 54     BNE P087         ;Service call &01 = reserve absolute workspace
8033 20 4C A8  JSR R84C         ;save AXY
8036 20 1F 82  JSR P21F         ;probe Challenger unit RAM size
8039 AA        TAX
803A F0 4A     BEQ P086         ;if Challenger unit absent then return
803C 20 0C BE  JSR SE0C         ;else page in main workspace
803F AD 00 FD  LDA &FD00        ;validate first workspace sentinel
8042 29 7F     AND #&7F         ;mask off b7=Challenger is current FS
8044 C9 65     CMP #&65         ;compare remainder with valid value &65/E5
8046 F0 0B     BEQ P053         ;if equal then validate second sentinel
8048 A9 65     LDA #&65         ;else initialise sentinel=&65, b7=0 no FS
804A 8D 00 FD  STA &FD00
804D 20 6A AB  JSR RB6A         ;initialise current FS's drive mapping
8050 20 00 BA  JSR SA00
.P053
8053 A9 E5     LDA #&E5         ;validate second workspace sentinel
8055 CD FD FD  CMP &FDFD
8058 F0 13     BEQ P06D         ;if not equal to valid value &E5
805A 8D FD FD  STA &FDFD        ;then initialise second sentinel
805D A9 04     LDA #&04         ;set current drive = 4
805F 85 CF     STA &CF
8061 A2 02     LDX #&02         ;x=2 select drive 4 volume size = &3F5
8063 20 F8 AF  JSR RFF8         ;initialise RAM disc catalogue
8066 E6 CF     INC &CF          ;current drive = 5
8068 A2 03     LDX #&03         ;x=3 select drive 5 volume size = &3FF
806A 20 F8 AF  JSR RFF8         ;initialise RAM disc catalogue
.P06D
806D A9 FD     LDA #&FD         ;OSBYTE &FD = read/write type of last reset
806F 20 F2 AD  JSR RDF2         ;call OSBYTE with X=0, Y=&FF
8072 8A        TXA              ;test type of last reset
8073 F0 03     BEQ P078         ;if A=0 then soft break so skip
8075 20 A4 82  JSR P2A4         ;else initialise workspace
.P078
8078 20 C8 82  JSR P2C8
807B 2C F4 FD  BIT &FDF4        ;test b7=*ENABLE CAT
807E 10 06     BPL P086         ;if enabled
8080 BA        TSX              ;then return Y=&17 nine pages of workspace
8081 A9 17     LDA #&17
8083 9D 03 01  STA &0103,X
.P086
8086 60        RTS
.P087
8087 C9 02     CMP #&02
8089 D0 0B     BNE P096         ;Service call &02 = reserve private workspace
808B 20 0C BE  JSR SE0C         ;page in main workspace
808E 2C F4 FD  BIT &FDF4        ;test b7=*ENABLE CAT
8091 10 02     BPL P095         ;if enabled
8093 C8        INY              ;then reserve two pages of private workspace
8094 C8        INY
.P095
8095 60        RTS
.P096
8096 C9 03     CMP #&03
8098 D0 1C     BNE P0B6         ;Service call &03 = boot
809A 20 0C BE  JSR SE0C         ;page in main workspace
809D 84 B3     STY &B3          ;save boot flag in scratch space
809F 20 4C A8  JSR R84C         ;save AXY
80A2 A9 7A     LDA #&7A         ;call OSBYTE &7A = scan keyboard from &10+
80A4 20 F4 FF  JSR &FFF4
80A7 8A        TXA              ;test returned key code
80A8 30 09     BMI P0B3         ;if N=1 no key is pressed, so init and boot
80AA C9 52     CMP #&52         ;else if key pressed is not C
80AC D0 45     BNE P0F3         ;then exit
80AE A9 78     LDA #&78         ;else register keypress for two-key rollover
80B0 20 F4 FF  JSR &FFF4
.P0B3
80B3 4C EE 81  JMP P1EE         ;initialise Chall. and boot default volume
.P0B6
80B6 C9 04     CMP #&04
80B8 D0 20     BNE P0DA         ;Service call &04 = unrecognised OSCLI
80BA 20 0C BE  JSR SE0C         ;page in main workspace
80BD 20 4C A8  JSR R84C         ;save AXY
80C0 BA        TSX
80C1 86 B8     STX &B8          ;save stack pointer to restore on abort
80C3 98        TYA              ;a=offset of *command from GSINIT pointer
80C4 A2 48     LDX #&48         ;point XY to utility command table at &9148
80C6 A0 91     LDY #&91
80C8 20 A8 91  JSR Q1A8         ;search for command in table
80CB B0 26     BCS P0F3         ;if not found then exit
80CD AD 00 FD  LDA &FD00        ;else test b7=Challenger is current FS
80D0 30 05     BMI P0D7         ;if b7=1 then execute *command
80D2 20 AA 00  JSR &00AA        ;else get syntax byte from command table
80D5 30 1C     BMI P0F3         ;if b7=1 restricted command then return
.P0D7
80D7 6C A8 00  JMP (&00A8)      ;else execute *command, Y=cmd line tail ptr
.P0DA
80DA C9 09     CMP #&09
80DC D0 35     BNE P113         ;Service call &09 = *HELP
80DE 20 0C BE  JSR SE0C         ;page in main workspace
80E1 20 4C A8  JSR R84C         ;save AXY
80E4 B1 F2     LDA (&F2),Y      ;test character at start of *HELP string
80E6 C9 0D     CMP #&0D         ;if not CR then *HELP called with keyword
80E8 D0 0A     BNE P0F4         ;so scan keyword
80EA A2 90     LDX #&90         ;else point XY to *HELP keyword table at &9190
80EC A0 91     LDY #&91
80EE A9 03     LDA #&03         ;3 entries to print
80F0 20 34 A5  JSR R534         ;print *HELP keywords and pass on the call.
.P0F3
80F3 60        RTS
.P0F4                           ;Scan *HELP keyword
80F4 20 F2 A9  JSR R9F2         ;call GSINIT with C=0
80F7 D0 03     BNE P0FC         ;if keyword present then search in table
80F9 4C 69 84  JMP P469         ;else print newline
.P0FC                           ;Search for *HELP keyword
80FC 98        TYA              ;a=offset of keyword from GSINIT pointer
80FD 48        PHA              ;also save on stack
80FE A2 90     LDX #&90         ;point XY to *HELP keyword table at &9190
8100 A0 91     LDY #&91
8102 20 A8 91  JSR Q1A8         ;search for keyword in table
8105 B0 03     BCS P10A         ;if keyword found
8107 20 D7 80  JSR P0D7         ;then call its action address; print help
.P10A
810A 68        PLA              ;restore string offset
810B A8        TAY
.P10C
810C 20 C5 FF  JSR &FFC5        ;call GSREAD
810F 90 FB     BCC P10C         ;until end of argument (discarding it)
8111 B0 E1     BCS P0F4         ;then scan next *HELP keyword
.P113
8113 C9 12     CMP #&12
8115 D0 0D     BNE P124
8117 C0 04     CPY #&04         ;Service call &12 = initialise FS
8119 D0 D8     BNE P0F3         ;if number of FS to initialise = 4
811B 20 0C BE  JSR SE0C         ;then page in main workspace
811E 20 4C A8  JSR R84C         ;save AXY
8121 4C 0E 82  JMP P20E         ;and initialise Challenger FS
.P124
8124 C9 08     CMP #&08
8126 D0 CB     BNE P0F3         ;Service call &08 = unrecognised OSWORD
8128 20 0C BE  JSR SE0C         ;page in main workspace
812B 20 75 A8  JSR R875         ;save XY (X will be clobbered on return)
812E A4 F0     LDY &F0          ;set &B0..1 = pointer to OSWORD control block
8130 84 B0     STY &B0
8132 A4 F1     LDY &F1
8134 84 B1     STY &B1
8136 A0 00     LDY #&00
8138 84 B9     STY &B9          ;=0 disc operation is uninterruptible
813A A4 EF     LDY &EF          ;set Y = OSWORD call number (in A on entry)
813C C0 7F     CPY #&7F
813E D0 78     BNE P1B8
8140 20 88 AD  JSR RD88         ;OSWORD A = &7F
8143 A0 01     LDY #&01         ;claim NMI
8145 B1 B0     LDA (&B0),Y      ;offset 1 = address LSB
8147 85 A6     STA &A6          ;copy to &A6
8149 C8        INY
814A B1 B0     LDA (&B0),Y      ;offset 2 = address 3MSB
814C 85 A7     STA &A7          ;copy to &A7
814E A0 00     LDY #&00
8150 B1 B0     LDA (&B0),Y      ;offset 0 = drive number
8152 30 11     BMI P165         ;if b7=1 then use previous drive
8154 48        PHA              ;else save requested drive
8155 2A        ROL A            ;shift bit 3 = force double density
8156 2A        ROL A            ;to bit 6
8157 2A        ROL A
8158 29 40     AND #&40         ;mask bit 6 = hardware double density flag
815A 0D ED FD  ORA &FDED        ;or with *DENSITY detected/forced DD flag
815D 8D ED FD  STA &FDED        ;update *DENSITY flag
8160 68        PLA              ;restore requested drive
8161 29 07     AND #&07         ;extract drive number 0..7
8163 85 CF     STA &CF          ;set as current drive
.P165
8165 C8        INY              ;offset 1 = address
8166 A2 02     LDX #&02
8168 20 C2 89  JSR P9C2         ;copy address to &BE,F,&FDB5,6
816B B1 B0     LDA (&B0),Y      ;y = 5 on exit; offset 5 = no. parameters
816D 48        PHA              ;save number of parameters
816E C8        INY              ;increment offset
816F B1 B0     LDA (&B0),Y      ;offset 6 = command
8171 29 3F     AND #&3F
8173 85 B2     STA &B2
8175 20 9E A9  JSR R99E         ;shift A right 4 places, extract bit 4:
8178 29 01     AND #&01         ;a=0 if writing to disc, A=1 if reading
817A 20 AE 96  JSR Q6AE         ;open Tube data transfer channel
817D A0 07     LDY #&07
817F B1 B0     LDA (&B0),Y      ;offset 7 = first parameter (usu. track)
8181 C8        INY              ;offset 8, Y points to second parameter
8182 85 BA     STA &BA
8184 A2 FD     LDX #&FD         ;x = &FD to start at offset 0:
.P186
8186 E8        INX              ;add 3 to X
8187 E8        INX
8188 E8        INX
8189 BD AD B8  LDA &B8AD,X      ;get command byte from table
818C F0 20     BEQ P1AE         ;if the terminator byte then exit
818E C5 B2     CMP &B2          ;else compare with OSWORD &7F command
8190 D0 F4     BNE P186         ;if not the same try next entry
8192 08        PHP              ;else save interrupt state
8193 58        CLI              ;enable interrupts
8194 A9 81     LDA #&81         ;push return address &81A3 on stack
8196 48        PHA
8197 A9 A2     LDA #&A2
8199 48        PHA
819A BD AF B8  LDA &B8AF,X      ;fetch action address high byte
819D 48        PHA              ;push on stack
819E BD AE B8  LDA &B8AE,X      ;fetch action address low byte
81A1 48        PHA              ;push on stack
81A2 60        RTS              ;jump to action address.
                                ;Finish OSWORD &7F
81A3 AA        TAX              ;hold result in X
81A4 28        PLP              ;restore interrupt state
81A5 68        PLA              ;restore number of parameters
81A6 18        CLC              ;add 7; drive, address, no.parms, command
81A7 69 07     ADC #&07         ;=offset of result in O7F control block
81A9 A8        TAY              ;transfer to Y for use as offset
81AA 8A        TXA
81AB 91 B0     STA (&B0),Y      ;store result in user's OSWORD &7F block
81AD 48        PHA              ;push dummy byte on stack:
.P1AE
81AE 68        PLA              ;discard byte from stack
81AF 20 71 AD  JSR RD71         ;release NMI
81B2 20 E6 96  JSR Q6E6         ;release Tube
81B5 A9 00     LDA #&00         ;exit A=0 to claim service call
81B7 60        RTS
.P1B8                           ;OSWORD A <> &7F
81B8 C0 7D     CPY #&7D         ;if A < &7D
81BA 90 31     BCC P1ED         ;then exit
81BC 20 1E AA  JSR RA1E         ;set current vol/dir = default, set up drive
81BF 20 2F 96  JSR Q62F         ;load volume catalogue L4
81C2 C0 7E     CPY #&7E
81C4 F0 0C     BEQ P1D2         ;OSWORD A = &7D (and &80..&DF)
81C6 20 16 BE  JSR SE16         ;page in catalogue sector 1
81C9 A0 00     LDY #&00
81CB AD 04 FD  LDA &FD04        ;get catalogue cycle number
81CE 91 B0     STA (&B0),Y      ;store in OSWORD control block offset 0
81D0 98        TYA              ;return A = 0, claiming service call.
81D1 60        RTS
.P1D2                           ;OSWORD A = &7E get size of volume in bytes
81D2 20 16 BE  JSR SE16         ;page in catalogue sector 1
81D5 A9 00     LDA #&00
81D7 A8        TAY
81D8 91 B0     STA (&B0),Y      ;store 0 at offset 0: multiple of 256 bytes
81DA C8        INY              ;offset 1
81DB AD 07 FD  LDA &FD07        ;get LSB volume size from catalogue
81DE 91 B0     STA (&B0),Y      ;save as 3MSB volume size
81E0 C8        INY              ;offset 2
81E1 AD 06 FD  LDA &FD06        ;get boot option/top bits volume size
81E4 29 03     AND #&03         ;extract MSB volume size
81E6 91 B0     STA (&B0),Y      ;save as 2MSB volume size
81E8 C8        INY              ;offset 3
81E9 A9 00     LDA #&00         ;store 0: volume size less than 16 MiB
81EB 91 B0     STA (&B0),Y
.P1ED
81ED 60        RTS
.P1EE                           ;Initialise Chall. and boot default volume
81EE A5 B3     LDA &B3          ;get back boot flag (Y on entry to call &3)
81F0 48        PHA              ;save on stack
81F1 38        SEC
81F2 20 5E AE  JSR RE5E         ;print Challenger banner
81F5 20 69 84  JSR P469         ;print newline
81F8 20 19 82  JSR P219         ;get Challenger unit type
81FB 29 03     AND #&03         ;extract b1,b0 of A
81FD F0 18     BEQ P217         ;if Challenger not installed then exit
81FF 20 C8 82  JSR P2C8         ;else initialise workspace part 2
8202 20 58 82  JSR P258         ;initialise Challenger FS
8205 68        PLA              ;if boot flag was >0
8206 D0 03     BNE P20B         ;then return A=0 to claim call
8208 4C F7 82  JMP P2F7         ;else examine and boot default volume
.P20B                           ;Return A=0
820B A9 00     LDA #&00
820D 60        RTS
.P20E                           ;*DISC / *DISK
820E 48        PHA
820F 20 36 82  JSR P236         ;probe JIM page &0001 for RAM
8212 D0 03     BNE P217         ;if RAM found then Challenger unit installed
8214 20 58 82  JSR P258         ;so initialise Challenger FS
.P217
8217 68        PLA
8218 60        RTS
.P219                           ;Get Challenger unit type
8219 A6 F4     LDX &F4          ;get our ROM slot number
821B BD F0 0D  LDA &0DF0,X      ;get type from private page pointer
821E 60        RTS
                                ;ChADFS ROM call 2
.P21F                           ;Probe Challenger unit RAM size
821F A2 00     LDX #&00         ;set X=0, no RAM found
8221 20 36 82  JSR P236
8224 D0 09     BNE P22F         ;if RAM absent return 0
8226 E8        INX              ;else X=1, 256 KiB unit
8227 A9 04     LDA #&04         ;probe JIM page &0401 for RAM
8229 20 38 82  JSR P238         ;will hit empty sockets, not alias to bank 0
822C D0 01     BNE P22F         ;if RAM absent return 1
822E E8        INX              ;else X=2, 512 KiB unit
.P22F
822F 8A        TXA
8230 A6 F4     LDX &F4          ;get our ROM slot number
8232 9D F0 0D  STA &0DF0,X      ;store Challenger unit type in private pg ptr
8235 60        RTS
.P236
8236 A9 00     LDA #&00         ;Probe JIM page &0001 for RAM
.P238
8238 8D FE FC  STA &FCFE        ;store MSB JIM paging register
823B A9 01     LDA #&01         ;page &0001 (main workspace) or &0401
823D 8D FF FC  STA &FCFF        ;store LSB JIM paging register
8240 AD 00 FD  LDA &FD00        ;read offset 0 of JIM page
8243 49 FF     EOR #&FF         ;invert it
8245 8D 00 FD  STA &FD00        ;write it back
8248 A0 05     LDY #&05         ;wait 13 microseconds
.P24A
824A 88        DEY              ;allow 1 MHz data bus to discharge
824B D0 FD     BNE P24A
824D CD 00 FD  CMP &FD00        ;read offset 0, compare with value written
8250 08        PHP              ;save result
8251 49 FF     EOR #&FF         ;restore original value
8253 8D 00 FD  STA &FD00        ;write back in case RAM is there
8256 28        PLP              ;return Z=1 if location 0 acts like RAM
8257 60        RTS
.P258                           ;Initialise Challenger FS
8258 A9 00     LDA #&00
825A BA        TSX
825B 9D 08 01  STA &0108,X      ;have A=0 returned on exit
825E A9 06     LDA #&06         ;FSC &06 = new FS about to change vectors
8260 20 2B 80  JSR P02B         ;issue Filing System Call
8263 A2 00     LDX #&00         ;x = 0 offset in MOS vector table
.P265
8265 BD F9 AD  LDA &ADF9,X      ;copy addresses of extended vector handlers
8268 9D 12 02  STA &0212,X      ;to FILEV,ARGSV,BGETV,BPUTV,GBPBV,FINDV,FSCV
826B E8        INX              ;loop until 7 vectors transferred
826C E0 0E     CPX #&0E
826E D0 F5     BNE P265
8270 20 E8 AD  JSR RDE8         ;call OSBYTE &A8 = get ext. vector table addr
8273 84 B1     STY &B1          ;set up pointer to vector table
8275 86 B0     STX &B0
8277 A2 00     LDX #&00         ;x = 0 offset in Challenger vector table
8279 A0 1B     LDY #&1B         ;y = &1B offset of FILEV in extended vec tbl
.P27B
827B BD 07 AE  LDA &AE07,X      ;get LSB action address from table
827E 91 B0     STA (&B0),Y      ;store in extended vector table
8280 E8        INX
8281 C8        INY
8282 BD 07 AE  LDA &AE07,X      ;get MSB action address from table
8285 91 B0     STA (&B0),Y      ;store in extended vector table
8287 E8        INX
8288 C8        INY
8289 A5 F4     LDA &F4          ;get our ROM slot number
828B 91 B0     STA (&B0),Y      ;store in extended vector table
828D C8        INY
828E E0 0E     CPX #&0E         ;loop until 7 vectors transferred
8290 D0 E9     BNE P27B
8292 AD 00 FD  LDA &FD00        ;get first workspace sentinel
8295 09 80     ORA #&80         ;set b7=1 Challenger is current FS
8297 8D 00 FD  STA &FD00        ;update first sentinel
829A A9 00     LDA #&00
829C 8D FF FD  STA &FDFF        ;b6=0 Challenger is current FS
829F A2 0F     LDX #&0F         ;service call &0F = vectors claimed
82A1 4C EC AD  JMP RDEC         ;call OSBYTE &8F = issue service call
.P2A4                           ;Initialise workspace part 1
82A4 20 0C BE  JSR SE0C         ;page in main workspace
82A7 A9 80     LDA #&80         ;a=&80
82A9 8D ED FD  STA &FDED        ;*OPT 6,0 automatic density
82AC 8D EA FD  STA &FDEA        ;*OPT 8,255 automatic stepping
82AF A9 0E     LDA #&0E         ;a=&0E
82B1 8D EE FD  STA &FDEE        ;*OPT 9,14 page in ROM slot 14 during disc ops
82B4 A9 00     LDA #&00
82B6 8D C7 FD  STA &FDC7        ;set default volume = "0A"
82B9 8D C9 FD  STA &FDC9        ;set library volume = "0A"
82BC 8D F4 FD  STA &FDF4
82BF A9 24     LDA #&24
82C1 8D C6 FD  STA &FDC6        ;set default directory = "$"
82C4 8D C8 FD  STA &FDC8        ;set library directory = "$"
82C7 60        RTS
.P2C8                           ;Initialise workspace part 2
82C8 20 0C BE  JSR SE0C         ;page in main workspace
82CB 20 E4 AD  JSR RDE4         ;call OSBYTE &EA = read Tube presence flag
82CE 8A        TXA
82CF 49 FF     EOR #&FF         ;invert; 0=tube present &FF=Tube absent
82D1 8D CD FD  STA &FDCD        ;save Tube presence flag
82D4 A0 00     LDY #&00         ;y=&00
82D6 8C CE FD  STY &FDCE        ;no files are open
82D9 8C DE FD  STY &FDDE
82DC 8C DD FD  STY &FDDD        ;NMI resource is not ours
82DF 8C CC FD  STY &FDCC        ;no Tube data transfer in progress
82E2 8C FF FD  STY &FDFF        ;b6=0 Challenger is current FS
82E5 88        DEY              ;y=&FF
82E6 8C DF FD  STY &FDDF        ;*commands are not *ENABLEd
82E9 8C D9 FD  STY &FDD9        ;*OPT 1,0 quiet operation
82EC 8C DC FD  STY &FDDC        ;no catalogue in JIM pages 2..3
82EF 20 F0 AD  JSR RDF0         ;call OSBYTE &FF = read/write startup options
82F2 86 B4     STX &B4          ;save them in zero page
82F4 4C F7 B8  JMP S8F7         ;set track stepping rate from startup options
.P2F7
82F7 20 1E AA  JSR RA1E         ;set current volume and directory = default
82FA 20 32 96  JSR Q632         ;load volume catalogue
82FD A0 00     LDY #&00
82FF A2 00     LDX #&00
8301 20 16 BE  JSR SE16         ;page in catalogue sector 1
8304 AD 06 FD  LDA &FD06        ;get boot option/top bits volume size
8307 20 9E A9  JSR R99E         ;shift A right 4 places
830A F0 25     BEQ P331         ;if boot option = 0 then exit
830C 48        PHA
830D A2 55     LDX #&55         ;point XY to filename "!BOOT"
830F A0 83     LDY #&83
8311 20 38 92  JSR Q238         ;set GSINIT pointer to XY, set Y=0
8314 20 DC 89  JSR P9DC         ;set current file from file spec
8317 20 2E 8C  JSR PC2E         ;search for file in catalogue
831A 68        PLA              ;restore boot option
831B B0 15     BCS P332         ;if !BOOT found then boot from it
831D 20 D3 A8  JSR R8D3         ;else print "File not found" and return
8320 EQUS "File not found"
832E EQUB &0D
832F EQUB &0D
8330 EA        NOP
.P331
8331 60        RTS
.P332
8332 C9 02     CMP #&02
8334 90 0E     BCC P344         ;if boot option = 1 then load !BOOT
8336 F0 06     BEQ P33E         ;if boot option = 2 then run !BOOT
8338 A2 53     LDX #&53         ;else boot option = 3 (or b7 or b6 set)
833A A0 83     LDY #&83         ;point XY to "E.!BOOT"
833C D0 0A     BNE P348         ;call OSCLI
.P33E
833E A2 55     LDX #&55         ;point XY to "!BOOT"
8340 A0 83     LDY #&83
8342 D0 04     BNE P348         ;call OSCLI
.P344
8344 A2 4B     LDX #&4B         ;point XY to "L.!BOOT"
8346 A0 83     LDY #&83
.P348
8348 4C F7 FF  JMP &FFF7        ;call OSCLI
834B EQUS "L.!BOOT"
8352 EQUB &0D
8353 EQUS "E.!BOOT"
835A EQUB &0D
                                ;*TYPE
835B 20 21 A8  JSR R821         ;claim service call and set up argument ptr
835E A9 00     LDA #&00         ;a = &00 CR does not trigger line no.
8360 F0 05     BEQ P367
                                ;*LIST
8362 20 21 A8  JSR R821         ;claim service call and set up argument ptr
8365 A9 FF     LDA #&FF         ;a = &FF CR triggers line number
.P367
8367 85 AB     STA &AB          ;store CR mask
8369 A9 40     LDA #&40         ;OSFIND &40 = open a file for reading
836B 20 CE FF  JSR &FFCE        ;call OSFIND
836E A8        TAY              ;test returned file handle
836F F0 30     BEQ P3A1         ;if file not found then raise error
8371 A9 0D     LDA #&0D         ;preload CR so *LIST prints line no. 1
8373 D0 1B     BNE P390         ;branch to CR test (always)
.P375
8375 20 D7 FF  JSR &FFD7        ;call OSBGET
8378 B0 1E     BCS P398         ;if EOF then finish
837A C9 0A     CMP #&0A         ;else if character is LF
837C F0 F7     BEQ P375         ;ignore it and get next one
837E 28        PLP              ;else restore result of (A & mask) - CR
837F D0 08     BNE P389         ;if no match just print the character
8381 48        PHA              ;else save first character of line
8382 20 DA A7  JSR R7DA         ;increment and print BCD word
8385 20 18 A8  JSR R818         ;print a space
8388 68        PLA              ;restore first character
.P389
8389 20 E3 FF  JSR &FFE3        ;call OSASCI
838C 24 FF     BIT &FF          ;if ESCAPE pressed
838E 30 09     BMI P399         ;then finish
.P390
8390 25 AB     AND &AB          ;else apply mask to character just prt'd
8392 C9 0D     CMP #&0D         ;compare masked character with CR
8394 08        PHP              ;save result
8395 4C 75 83  JMP P375         ;and loop to read next character
.P398
8398 28        PLP              ;discard result of (A & mask) - CR
.P399
8399 20 69 84  JSR P469         ;print newline
.P39C
839C A9 00     LDA #&00         ;OSFIND &00 = close file
839E 4C CE FF  JMP &FFCE        ;call OSFIND and exit
.P3A1
83A1 4C 46 8B  JMP PB46         ;raise "File not found" error
                                ;*DUMP
83A4 20 21 A8  JSR R821         ;claim service call and set up argument ptr
83A7 A9 40     LDA #&40         ;OSFIND &40 = open a file for reading
83A9 20 CE FF  JSR &FFCE        ;call OSFIND
83AC A8        TAY              ;transfer file handle to Y
83AD F0 F2     BEQ P3A1         ;if file not found raise error
.P3AF
83AF 24 FF     BIT &FF          ;if ESCAPE pressed
83B1 30 E9     BMI P39C         ;then close file and exit
83B3 A5 A9     LDA &A9          ;else get high byte of file offset
83B5 20 78 A9  JSR R978         ;print hex byte
83B8 A5 A8     LDA &A8          ;get low byte of file offset
83BA 20 78 A9  JSR R978         ;print hex byte
83BD 20 18 A8  JSR R818         ;print a space
83C0 BA        TSX
83C1 86 AD     STX &AD          ;save stack pointer
83C3 A2 08     LDX #&08         ;offset = 8 for indexed indirect load
.P3C5
83C5 20 D7 FF  JSR &FFD7        ;call OSBGET
83C8 B0 0A     BCS P3D4         ;if EOF then finish
83CA 48        PHA              ;else save byte read for ASCII column
83CB 20 78 A9  JSR R978         ;print hex byte
83CE 20 18 A8  JSR R818         ;print a space
83D1 CA        DEX              ;decrement counter
83D2 D0 F1     BNE P3C5         ;loop until line complete
.P3D4
83D4 CA        DEX              ;test counter
83D5 30 0D     BMI P3E4         ;if EOF on incomplete line
83D7 08        PHP              ;then save status (N=0, C=1)
83D8 20 D3 A8  JSR R8D3         ;pad hex column with "** "
83DB EQUS "** "
83DE A9 00     LDA #&00
83E0 28        PLP              ;restore status
83E1 48        PHA              ;push NUL to pad ASCII column
83E2 10 F0     BPL P3D4         ;loop until line complete (always)
.P3E4                           ;print ASCII column
83E4 08        PHP              ;save C=EOF
83E5 BA        TSX              ;transfer stack pointer to X
83E6 A9 07     LDA #&07
83E8 85 AC     STA &AC          ;set counter to 7:
.P3EA
83EA BD 09 01  LDA &0109,X      ;get byte 9..2 down = byte 1..8 of column
83ED C9 7F     CMP #&7F         ;if DEL or higher
83EF B0 04     BCS P3F5         ;then print a dot
83F1 C9 20     CMP #&20         ;else if a printable character
83F3 B0 02     BCS P3F7         ;then print it
.P3F5
83F5 A9 2E     LDA #&2E         ;else print a dot:
.P3F7
83F7 20 E3 FF  JSR &FFE3        ;call OSASCI
83FA CA        DEX              ;decrement pointer, work toward top of stack
83FB C6 AC     DEC &AC          ;decrement counter
83FD 10 EB     BPL P3EA         ;loop until line complete
83FF 20 69 84  JSR P469         ;print newline
8402 A9 08     LDA #&08         ;add 8 to file offset
8404 18        CLC
8405 65 A8     ADC &A8
8407 85 A8     STA &A8
8409 90 02     BCC P40D         ;carry out to high byte
840B E6 A9     INC &A9
.P40D
840D 28        PLP              ;restore carry flag from OSBGET
840E A6 AD     LDX &AD          ;restore stack pointer to discard column
8410 9A        TXS
8411 90 9C     BCC P3AF         ;if not at end of file then print next row
8413 B0 87     BCS P39C         ;else close file and exit
                                ;*BUILD
8415 20 21 A8  JSR R821         ;claim service call and set up argument ptr
8418 A9 80     LDA #&80         ;OSFIND &80 = open a file for writing
841A 20 CE FF  JSR &FFCE        ;call OSFIND
841D 85 AB     STA &AB          ;save file handle
841F 20 38 A8  JSR R838         ;set line number = 0 (OSFIND clobbers)
.P422
8422 20 DA A7  JSR R7DA         ;increment and print BCD word
8425 20 18 A8  JSR R818         ;print a space
8428 A9 FD     LDA #&FD         ;y = &FD point to JIM page for OSWORD
842A 85 AD     STA &AD
842C A2 AC     LDX #&AC         ;x = &AC low address for OSWORD
842E A0 FF     LDY #&FF         ;y = &FF
8430 84 AE     STY &AE          ;maximum line length = 255
8432 84 B0     STY &B0          ;maximum ASCII value = 255
8434 C8        INY
8435 84 AC     STY &AC          ;clear low byte of pointer
8437 84 AF     STY &AF          ;minimum ASCII value = 0
8439 20 1B BE  JSR SE1B         ;page in line buffer
843C 98        TYA              ;OSWORD &00 = read line of input
843D 20 F1 FF  JSR &FFF1        ;call OSWORD
8440 08        PHP              ;save returned flags
8441 84 AA     STY &AA          ;save length of line
8443 A4 AB     LDY &AB          ;y = file handle for OSBPUT
8445 A2 00     LDX #&00         ;offset = 0 for indexed indirect load
.P447
8447 8A        TXA
8448 C5 AA     CMP &AA          ;compare offset with line length
844A F0 0C     BEQ P458         ;if end of line reached then terminate line
844C 20 1B BE  JSR SE1B         ;else page in line buffer
844F BD 00 FD  LDA &FD00,X      ;get character of line
8452 20 D4 FF  JSR &FFD4        ;call OSBPUT
8455 E8        INX              ;increment offset
8456 D0 EF     BNE P447         ;and loop to write rest of line (always)
.P458                           ;terminate line
8458 28        PLP              ;restore flags from OSWORD
8459 B0 08     BCS P463         ;if user escaped from input then finish
845B A9 0D     LDA #&0D         ;else A = carriage return
845D 20 D4 FF  JSR &FFD4        ;write to file
8460 4C 22 84  JMP P422         ;and loop to build next line
.P463
8463 20 8F A9  JSR R98F         ;acknowledge ESCAPE condition
8466 20 9C 83  JSR P39C         ;close file:
.P469                           ;Print newline
8469 48        PHA
846A A9 0D     LDA #&0D
846C 20 51 A9  JSR R951         ;print character in A (OSASCI)
846F 68        PLA
8470 60        RTS
.P471                           ;Select source volume
8471 20 4C A8  JSR R84C         ;save AXY
8474 20 0C BE  JSR SE0C         ;page in main workspace
8477 AE CA FD  LDX &FDCA        ;set X = source volume
847A A9 00     LDA #&00         ;a=&00 = we want source disc
847C F0 0B     BEQ P489         ;branch (always)
.P47E                           ;Select destination volume
847E 20 4C A8  JSR R84C         ;save AXY
8481 20 0C BE  JSR SE0C         ;page in main workspace
8484 AE CB FD  LDX &FDCB        ;set X = destination volume
8487 A9 80     LDA #&80         ;a=&80 = we want destination disc
.P489
8489 48        PHA              ;save A
848A 86 CF     STX &CF          ;set wanted volume as current volume
848C 68        PLA              ;restore A
848D 24 A9     BIT &A9          ;if disc swapping required
848F 30 01     BMI P492         ;then branch to prompt
.P491
8491 60        RTS              ;else exit
.P492
8492 C5 AA     CMP &AA          ;compare wanted disc with disc in drive
8494 F0 FB     BEQ P491         ;if the same then do not prompt
8496 85 AA     STA &AA          ;else wanted disc is going into drive
8498 20 D3 A8  JSR R8D3         ;print "Insert "
849B EQUS "Insert "
84A2 EA        NOP
84A3 24 AA     BIT &AA          ;if b7=1
84A5 30 0B     BMI P4B2         ;then print "destination"
84A7 20 D3 A8  JSR R8D3         ;else print "source"
84AA EQUS "source"
84B0 90 0F     BCC P4C1         ;and branch (always)
.P4B2
84B2 20 D3 A8  JSR R8D3         ;print " destination"
84B5 EQUS "destination"
84C0 EA        NOP
.P4C1
84C1 20 D3 A8  JSR R8D3         ;print " disk and hit a key"
84C4 EQUS " disk and hit a key"
84D7 EA        NOP
84D8 20 EF 84  JSR P4EF         ;poll for ESCAPE (OSRDCH)
84DB 4C 69 84  JMP P469         ;print newline and exit
.P4DE                           ;Ask user yes or no
84DE 20 EF 84  JSR P4EF         ;wait for keypress
84E1 29 5F     AND #&5F         ;convert to uppercase
84E3 C9 59     CMP #&59         ;is it "Y"?
84E5 08        PHP              ;save the answer
84E6 F0 02     BEQ P4EA         ;if so then print "Y"
84E8 A9 4E     LDA #&4E         ;else print "N"
.P4EA
84EA 20 51 A9  JSR R951         ;print character in A (OSASCI)
84ED 28        PLP              ;return Z=1 if "Y" or "y" pressed
84EE 60        RTS
.P4EF                           ;Poll for ESCAPE (OSRDCH)
84EF 20 C2 AD  JSR RDC2         ;call *FX 15,1 = clear input buffer
84F2 20 E0 FF  JSR &FFE0        ;call OSRDCH, wait for input character
84F5 90 03     BCC P4FA         ;if ESCAPE was pressed
84F7 A6 B8     LDX &B8          ;then abort our routine
84F9 9A        TXS              ;clear our stacked items, return to caller
.P4FA
84FA 60        RTS
.P4FB                           ;Restore parameters of source drive
84FB A0 00     LDY #&00         ;offset = 0
84FD F0 02     BEQ P501         ;branch (always)
.P4FF                           ;Restore parameters of destination drive
84FF A0 02     LDY #&02         ;offset = 2:
.P501                           ;Restore parameters of source/dest drive
8501 20 0C BE  JSR SE0C         ;page in main workspace
8504 B9 FA FD  LDA &FDFA,Y      ;get first track of selected volume
8507 8D EC FD  STA &FDEC        ;set as first track of current volume
850A B9 F9 FD  LDA &FDF9,Y      ;get packed drive parameters:
.P50D                           ;Restore packed drive parameters
850D 48        PHA              ;save packed drive parameters
850E 29 C0     AND #&C0         ;mask b7,b6
8510 8D ED FD  STA &FDED        ;store *OPT 6 density setting
8513 68        PLA              ;restore packed drive parameters
8514 4A        LSR A            ;shift b1,b0 of A to b7,b6
8515 6A        ROR A
8516 6A        ROR A
8517 48        PHA              ;save other bits
8518 29 C0     AND #&C0         ;mask b7,b6
851A 8D EA FD  STA &FDEA        ;store *OPT 8 tracks setting
851D 68        PLA              ;restore b1,b0 = original b4,b3
851E 29 03     AND #&03         ;mask b1,b0
8520 4C 4C 85  JMP P54C         ;unpack and store sectors per track
.P523                           ;Save parameters of source drive
8523 20 4C A8  JSR R84C         ;save AXY
8526 A0 00     LDY #&00
8528 F0 05     BEQ P52F
.P52A                           ;Save parameters of destination drive
852A 20 4C A8  JSR R84C         ;save AXY
852D A0 02     LDY #&02
.P52F                           ;Save parameters of source/dest drive
852F 20 0C BE  JSR SE0C         ;page in main workspace
8532 AD EC FD  LDA &FDEC        ;get first track of current volume
8535 99 FA FD  STA &FDFA,Y      ;set as first track of selected volume
8538 20 3F 85  JSR P53F         ;pack drive parameters
853B 99 F9 FD  STA &FDF9,Y
853E 60        RTS
.P53F                           ;Pack drive parameters
853F 20 5C 85  JSR P55C         ;pack number of sectors per track
8542 0D EA FD  ORA &FDEA        ;apply *OPT 8 tracks setting in b7,b6
8545 0A        ASL A            ;shift spt to b4,b3, *OPT 8 to b1,b0
8546 2A        ROL A
8547 2A        ROL A
8548 0D ED FD  ORA &FDED        ;apply *OPT 6 density setting in b7,b6
854B 60        RTS              ;return packed drive parameters
.P54C                           ;Unpack and store sectors per track
854C C9 00     CMP #&00         ;if A=0 on entry then RAM disc
854E F0 08     BEQ P558         ;so store 0=sectors per track undefined
8550 C9 02     CMP #&02         ;else if A=1
8552 A9 0A     LDA #&0A         ;then store 10 sectors per track
8554 90 02     BCC P558
8556 A9 12     LDA #&12         ;else A>1, store 18 sectors per track
.P558
8558 8D EB FD  STA &FDEB        ;store number of sectors per track
855B 60        RTS
.P55C                           ;Pack number of sectors per track
855C AD EB FD  LDA &FDEB        ;get current setting
855F F0 07     BEQ P568         ;if A=0 then RAM disc, return 0
8561 C9 12     CMP #&12         ;else if less than 18 i.e. 10, single dens.
8563 A9 01     LDA #&01         ;then return 1
8565 90 01     BCC P568
8567 0A        ASL A            ;if 18 or more i.e. double density return 2.
.P568
8568 60        RTS
                                ;*BACKUP
8569 20 5F A7  JSR R75F         ;ensure *ENABLE active
856C 20 8A A7  JSR R78A         ;parse and print source and dest. volumes
856F A9 00     LDA #&00
8571 85 A8     STA &A8          ;no catalogue entry waiting to be created
8573 85 C8     STA &C8          ;set source volume LBA = 0
8575 85 C9     STA &C9
8577 85 CA     STA &CA          ;set destination volume LBA = 0
8579 85 CB     STA &CB
857B 20 5F 86  JSR P65F         ;load source volume catalogue
857E A9 00     LDA #&00
8580 8D EC FD  STA &FDEC        ;data area starts on track 0
8583 20 23 85  JSR P523         ;save parameters of source drive
8586 20 3A 86  JSR P63A         ;return volume size in XY/boot option in A
8589 8D E0 FD  STA &FDE0        ;save source volume boot option
858C 86 C6     STX &C6
858E 84 C7     STY &C7
8590 20 59 86  JSR P659         ;load destination volume catalogue
8593 A9 00     LDA #&00
8595 8D EC FD  STA &FDEC        ;data area starts on track 0
8598 20 2A 85  JSR P52A         ;save parameters of destination drive
859B AD F9 FD  LDA &FDF9        ;get density of source drive
859E 4D FB FD  EOR &FDFB        ;xor with density flag of destination drive
85A1 29 40     AND #&40         ;extract bit 6 density flag, ignore auto b7
85A3 F0 25     BEQ P5CA         ;if the same density then skip
85A5 20 AD A8  JSR R8AD         ;else raise density mismatch error.
85A8 EQUB &D5
85A9 EQUS "Both disks MUST be same density"
85C8 EQUB &0D
85C9 EQUB &00
.P5CA
85CA 20 3A 86  JSR P63A         ;return volume size in XY/boot option in A
85CD 8A        TXA              ;save destination volume size on stack
85CE 48        PHA
85CF 98        TYA
85D0 48        PHA
85D1 C5 C7     CMP &C7          ;compare MSBs dest volume size - source
85D3 90 07     BCC P5DC         ;if dest < source then raise error
85D5 D0 29     BNE P600         ;if dest > source then proceed
85D7 8A        TXA              ;else compare LSBs dest - source
85D8 C5 C6     CMP &C6
85DA B0 24     BCS P600         ;if dest >= source then proceed
.P5DC
85DC A9 D5     LDA #&D5         ;else error number = &D5
85DE 20 38 A9  JSR R938         ;begin error message, number in A
85E1 AD CA FD  LDA &FDCA        ;get source drive
85E4 20 AD 8E  JSR PEAD         ;print " Drive " plus volume spec in A
85E7 20 D3 A8  JSR R8D3         ;print " larger than "
85EA EQUS " larger than "
85F7 AD CB FD  LDA &FDCB        ;get destination drive
85FA 20 AD 8E  JSR PEAD         ;print " Drive " plus volume spec in A
85FD 4C F8 A8  JMP R8F8         ;terminate error message, raise error
.P600
8600 20 48 89  JSR P948         ;copy source drive/file to destination
8603 20 CA 88  JSR P8CA         ;store empty BASIC program at OSHWM (NEW)
8606 20 4C B7  JSR S74C         ;set Z=1 iff current drive is a RAM disc
8609 D0 03     BNE P60E         ;if so
860B 68        PLA              ;then discard destination volume size
860C 68        PLA
860D 60        RTS              ;and exit
.P60E
860E 2C ED FD  BIT &FDED        ;else test density flag
8611 70 16     BVS P629         ;if double density then update disc catalogue
8613 20 32 96  JSR Q632         ;else load volume catalogue L4
8616 68        PLA              ;pop MSB destination volume size
8617 29 0F     AND #&0F         ;mask bits 0..3
8619 0D E0 FD  ORA &FDE0        ;apply source boot option in bits 4..5
861C 20 16 BE  JSR SE16         ;page in catalogue sector 1
861F 8D 06 FD  STA &FD06        ;store in catalogue
8622 68        PLA              ;pop LSB destination volume size
8623 8D 07 FD  STA &FD07        ;store in catalogue
8626 4C 0B 96  JMP Q60B         ;write volume catalogue L4
.P629                           ;Update disc catalogue
8629 20 BA AC  JSR RCBA         ;load disc catalogue L3
862C 20 11 BE  JSR SE11         ;page in catalogue sector 0
862F 68        PLA              ;pop MSB disc size
8630 8D 01 FD  STA &FD01        ;store in disc catalogue
8633 68        PLA              ;pop LSB disc size
8634 8D 02 FD  STA &FD02        ;store in disc catalogue
8637 4C BD AC  JMP RCBD         ;write disc catalogue L3
.P63A                           ;Return volume size in XY/boot option in A
863A 20 16 BE  JSR SE16         ;page in catalogue sector 1
863D AE 07 FD  LDX &FD07        ;get LSB volume size from catalogue
8640 AD 06 FD  LDA &FD06        ;get boot option/top bits volume size
8643 48        PHA
8644 29 03     AND #&03         ;extract MSB volume size
8646 A8        TAY              ;put volume size in XY
8647 20 0C BE  JSR SE0C         ;page in main workspace
864A 2C ED FD  BIT &FDED        ;test density flag
864D 50 06     BVC P655         ;if double density
864F AE F6 FD  LDX &FDF6        ;then load disc size from workspace instead
8652 AC F5 FD  LDY &FDF5
.P655
8655 68        PLA              ;return disc size in XY
8656 29 F0     AND #&F0         ;return boot option in A bits 5 and 4
8658 60        RTS
.P659                           ;Load destination volume catalogue
8659 20 7E 84  JSR P47E         ;select destination volume
865C 4C 32 96  JMP Q632         ;load volume catalogue L4
.P65F                           ;Load source volume catalogue
865F 20 71 84  JSR P471         ;select source volume
8662 4C 32 96  JMP Q632         ;load volume catalogue L4
                                ;*COPY
8665 20 2E 8B  JSR PB2E         ;allow wildcard characters in filename
8668 20 8A A7  JSR R78A         ;parse and print source and dest. volumes
866B 20 65 A5  JSR R565         ;call GSINIT with C=0 and reject empty arg
866E 20 DC 89  JSR P9DC         ;set current file from file spec
8671 20 71 84  JSR P471         ;select source volume
8674 20 41 8B  JSR PB41         ;ensure matching file in catalogue
8677 20 23 85  JSR P523         ;save parameters of source drive
867A AD D5 FD  LDA &FDD5        ;get start of user memory
867D 85 BD     STA &BD          ;save in zero page
867F A9 00     LDA #&00
8681 8D F7 FD  STA &FDF7        ;point to start of copy buffer file table
8684 85 A8     STA &A8
8686 A9 01     LDA #&01
8688 85 A8     STA &A8          ;one entry in copy buffer file table:
;Copy file
.P68A
868A 98        TYA              ;save catalogue offset of found file
868B 48        PHA
868C A2 00     LDX #&00
.P68E
868E B5 C7     LDA &C7,X        ;save file spec on stack
8690 48        PHA
8691 E8        INX
8692 E0 08     CPX #&08
8694 D0 F8     BNE P68E
8696 20 D3 A8  JSR R8D3         ;print "Reading "
8699 EQUS "Reading "
86A1 EA        NOP
86A2 20 A3 8A  JSR PAA3         ;print filename from catalogue
86A5 20 69 84  JSR P469         ;print newline
86A8 AE F7 FD  LDX &FDF7        ;get pointer to free end of buffer table
86AB A9 08     LDA #&08         ;8 bytes to copy
86AD 85 B0     STA &B0          ;set counter:
.P6AF
86AF 20 16 BE  JSR SE16         ;page in catalogue sector 1
86B2 B9 08 FD  LDA &FD08,Y      ;get matching file's catalogue information
86B5 20 07 BE  JSR SE07         ;page in auxiliary workspace
86B8 9D 11 FD  STA &FD11,X      ;store information in copy buffer table
86BB E8        INX              ;&FD11..18,X
86BC C8        INY
86BD C6 B0     DEC &B0          ;loop until 8 bytes copied
86BF D0 EE     BNE P6AF
86C1 A9 08     LDA #&08         ;8 characters to copy
86C3 85 B0     STA &B0          ;set counter:
.P6C5
86C5 20 11 BE  JSR SE11         ;page in catalogue sector 0
86C8 B9 00 FD  LDA &FD00,Y      ;get matching file's name and directory
86CB 20 07 BE  JSR SE07         ;page in auxiliary workspace
86CE 9D 12 FD  STA &FD12,X      ;store filename in copy buffer table
86D1 E8        INX              ;&FD1A..21,X
86D2 C8        INY
86D3 C6 B0     DEC &B0          ;loop until 8 characters copied
86D5 D0 EE     BNE P6C5
86D7 A9 00     LDA #&00
86D9 9D 09 FD  STA &FD09,X      ;clear &FD19,X flag byte
86DC BD 05 FD  LDA &FD05,X      ;get LSB length
86DF C9 01     CMP #&01         ;set C=1 iff file includes partial sector
86E1 BD 06 FD  LDA &FD06,X      ;get 2MSB length
86E4 69 00     ADC #&00         ;round up to get LSB length in sectors
86E6 9D 12 FD  STA &FD12,X      ;store LSB length in sectors in table
86E9 08        PHP              ;save carry flag
86EA BD 07 FD  LDA &FD07,X      ;get top bits exec/length/load/start sector
86ED 20 96 A9  JSR R996         ;extract b5,b4 of A
86F0 28        PLP              ;restore carry flag
86F1 69 00     ADC #&00         ;carry out to get MSB length in sectors
86F3 9D 13 FD  STA &FD13,X      ;save length in sectors at &FD22..23,X
86F6 BD 08 FD  LDA &FD08,X      ;get LSB start LBA
86F9 9D 14 FD  STA &FD14,X      ;copy to &FD24,X
86FC BD 07 FD  LDA &FD07,X      ;get top bits exec/length/load/start sector
86FF 29 03     AND #&03         ;extract MSB start sector
8701 9D 15 FD  STA &FD15,X      ;store MSB start LBA at &FD25,X:
;Read segment of file
.P704
8704 20 0C BE  JSR SE0C         ;page in main workspace
8707 38        SEC              ;subtract HIMEM - OSHWM
8708 AD D6 FD  LDA &FDD6
870B E5 BD     SBC &BD
870D 85 C3     STA &C3          ;= number of pages of user memory
870F AC F7 FD  LDY &FDF7        ;get pointer to latest buffer table entry
8712 20 07 BE  JSR SE07         ;page in auxiliary workspace
8715 B9 22 FD  LDA &FD22,Y      ;copy LSB length in sectors
8718 85 C6     STA &C6          ;to zero page
871A B9 23 FD  LDA &FD23,Y      ;MSB length in sectors
871D 85 C7     STA &C7
871F B9 24 FD  LDA &FD24,Y      ;LSB start LBA
8722 85 C8     STA &C8
8724 B9 25 FD  LDA &FD25,Y      ;MSB start LBA
8727 85 C9     STA &C9
8729 20 89 89  JSR P989         ;set start and size of next transfer
872C A5 BD     LDA &BD          ;set MSB load address = start of user memory
872E 85 BF     STA &BF
8730 A9 00     LDA #&00
8732 85 BE     STA &BE          ;set LSB load address = 0
8734 85 C2     STA &C2          ;set LSB transfer size = 0
8736 A5 C3     LDA &C3          ;get size of transfer
8738 20 07 BE  JSR SE07         ;page in auxiliary workspace
873B 99 18 FD  STA &FD18,Y      ;overwrite LSB start LBA at &FD18,Y
873E 20 9C 95  JSR Q59C         ;set high word of OSFILE load address = &FFFF
8741 20 0D 97  JSR Q70D         ;read ordinary file L5
8744 20 9E 89  JSR P99E         ;adjust addresses by amount transferred
8747 18        CLC
8748 A5 BD     LDA &BD          ;get start of free copy buffer
874A 65 C3     ADC &C3          ;add size of transfer
874C 85 BD     STA &BD          ;update start of free copy buffer
874E AC F7 FD  LDY &FDF7        ;get pointer to latest buffer table entry
8751 20 07 BE  JSR SE07         ;page in auxiliary workspace
8754 A5 C6     LDA &C6          ;return LSB length in sectors
8756 99 22 FD  STA &FD22,Y      ;to copy buffer table
8759 A5 C7     LDA &C7          ;MSB length in sectors
875B 99 23 FD  STA &FD23,Y
875E A5 C8     LDA &C8          ;LSB start LBA
8760 99 24 FD  STA &FD24,Y
8763 A5 C9     LDA &C9          ;MSB start LBA
8765 99 25 FD  STA &FD25,Y
8768 A5 C6     LDA &C6          ;test number of sectors to transfer
876A 05 C7     ORA &C7
876C F0 0B     BEQ P779         ;if no more then read next file/write buffer
876E 20 07 BE  JSR SE07         ;else page in auxiliary workspace
8771 B9 19 FD  LDA &FD19,Y      ;get buffer table entry's flag byte
8774 09 80     ORA #&80         ;b7=1 file incomplete in buffer
8776 99 19 FD  STA &FD19,Y      ;update flag byte:
;Continue filling copy buffer until full, or write it out
.P779
8779 20 0C BE  JSR SE0C         ;page in main workspace
877C A5 BD     LDA &BD          ;has copy buffer been filled up to HIMEM?
877E CD D6 FD  CMP &FDD6
8781 F0 37     BEQ P7BA         ;if so then write it out
8783 24 A8     BIT &A8          ;else if b7=1 all files read
8785 30 33     BMI P7BA         ;then write out copy buffer
8787 A5 A8     LDA &A8          ;else if copy buffer table is full
8789 29 7F     AND #&7F
878B C9 08     CMP #&08
878D F0 2B     BEQ P7BA         ;then write it out
878F 18        CLC
8790 AD F7 FD  LDA &FDF7        ;else point copy buffer table pointer
8793 69 17     ADC #&17         ;to next entry:
8795 8D F7 FD  STA &FDF7
;Copy next matching file
.P798
8798 A2 07     LDX #&07         ;8 bytes to restore:
.P79A
879A 68        PLA              ;restore file spec from stack
879B 95 C7     STA &C7,X
879D CA        DEX              ;loop until 8 bytes restored
879E 10 FA     BPL P79A
87A0 68        PLA              ;restore catalogue offset of found file
87A1 8D C2 FD  STA &FDC2
87A4 20 35 8C  JSR PC35         ;find next matching file
87A7 90 05     BCC P7AE         ;if no more files match then finish
87A9 E6 A8     INC &A8          ;else increment no. of files in buffer
87AB 4C 8A 86  JMP P68A         ;and copy next file.
;Flush copy buffer
.P7AE
87AE AC F7 FD  LDY &FDF7        ;more than one table entry in use?
87B1 D0 01     BNE P7B4         ;if so then write out copy buffer
87B3 60        RTS              ;else exit
.P7B4
87B4 A5 A8     LDA &A8          ;set b7=1 all files read
87B6 09 80     ORA #&80
87B8 85 A8     STA &A8
.P7BA
87BA 20 0C BE  JSR SE0C         ;page in main workspace
87BD 20 7E 84  JSR P47E         ;select destination volume
87C0 AD D5 FD  LDA &FDD5
87C3 85 BD     STA &BD          ;set start of copy buffer to OSHWM
87C5 A5 A8     LDA &A8          ;get no. entries in copy buffer
87C7 29 7F     AND #&7F         ;extract actual number of entries
87C9 AA        TAX
87CA A0 E9     LDY #&E9         ;y=&E9 going to &00:
;Write file from copy buffer
.P7CC
87CC 8A        TXA
87CD 48        PHA              ;save number of buffer table entries
87CE 18        CLC
87CF 98        TYA
87D0 69 17     ADC #&17         ;point to next buffer table entry
87D2 8D F8 FD  STA &FDF8        ;set pointer to last entry of buffer table
87D5 48        PHA              ;and save it
87D6 A8        TAY
87D7 20 07 BE  JSR SE07         ;page in auxiliary workspace
87DA B9 19 FD  LDA &FD19,Y      ;if b6=1 destination file partly copied
87DD 29 40     AND #&40         ;then skip catalogue entry creation:
87DF D0 57     BNE P838         ;write out rest of file
87E1 B9 19 FD  LDA &FD19,Y      ;else b6=1 don't create entry twice
87E4 09 40     ORA #&40
87E6 99 19 FD  STA &FD19,Y
87E9 A2 00     LDX #&00
.P7EB
87EB B9 11 FD  LDA &FD11,Y      ;read from buffer table entry &FD11..21,Y
87EE 95 BE     STA &BE,X        ;restore file catalogue info &BE..&C5
87F0 C8        INY              ;and filename and directory &C7..&CE
87F1 E8        INX
87F2 E0 11     CPX #&11
87F4 D0 F5     BNE P7EB
87F6 20 53 97  JSR Q753         ;forget catalogue in JIM pages 2..3
87F9 20 2E 8C  JSR PC2E         ;search for file in catalogue
87FC 90 03     BCC P801         ;if file found
87FE 20 78 8C  JSR PC78         ;then delete catalogue entry
.P801
8801 20 2A 85  JSR P52A         ;save parameters of destination drive
8804 20 8D 95  JSR Q58D         ;expand 18-bit load address to 32-bit
8807 20 AC 95  JSR Q5AC         ;expand 18-bit exec address to 32-bit
880A A5 C4     LDA &C4          ;get top bits exec/length/load/start sector
880C 20 96 A9  JSR R996         ;extract b5,b4 of A
880F 85 C6     STA &C6          ;store MSB length of file
8811 20 0B 94  JSR Q40B         ;create catalogue entry
8814 20 D3 A8  JSR R8D3         ;print "Writing "
8817 EQUS "Writing "
881F EA        NOP
8820 20 A3 8A  JSR PAA3         ;print filename from catalogue
8823 20 69 84  JSR P469         ;print newline
8826 AC F8 FD  LDY &FDF8        ;point to last entry of buffer table
8829 20 07 BE  JSR SE07         ;page in auxiliary workspace
882C A5 C4     LDA &C4          ;get top bits exec/length/load/start sector
882E 29 03     AND #&03         ;extract b1,b0 of A
8830 99 26 FD  STA &FD26,Y      ;store MSB destination LBA
8833 A5 C5     LDA &C5          ;copy LSB destination LBA
8835 99 27 FD  STA &FD27,Y
;Write segment of file
.P838
8838 B9 18 FD  LDA &FD18,Y      ;get no. pages of data in buffer
883B 85 C3     STA &C3          ;set size of transfer
883D 18        CLC
883E B9 27 FD  LDA &FD27,Y      ;copy LSB destination LBA
8841 85 C5     STA &C5
8843 65 C3     ADC &C3          ;add transfer size
8845 99 27 FD  STA &FD27,Y      ;update LSB destination LBA of next write
8848 B9 26 FD  LDA &FD26,Y      ;copy MSB destination LBA
884B 85 C4     STA &C4
884D 69 00     ADC #&00         ;carry out transfer size
884F 99 26 FD  STA &FD26,Y      ;update MSB destination LBA of next write
8852 A5 BD     LDA &BD          ;get start of filled copy buffer
8854 85 BF     STA &BF          ;set MSB of source address
8856 A9 00     LDA #&00
8858 85 BE     STA &BE          ;clear LSB source address
885A 85 C2     STA &C2          ;clear LSB transfer size
885C 20 FF 84  JSR P4FF         ;restore parameters of destination drive
885F 20 9C 95  JSR Q59C         ;set high word of OSFILE load address = &FFFF
8862 20 13 97  JSR Q713         ;write extended file L5
8865 18        CLC
8866 A5 BD     LDA &BD          ;get start of filled copy buffer
8868 65 C3     ADC &C3          ;add size of transfer
886A 85 BD     STA &BD          ;update start of filled copy buffer
886C 68        PLA              ;restore pointer to last table entry
886D A8        TAY
886E 68        PLA              ;restore no. entries in buffer table
886F AA        TAX
8870 CA        DEX              ;remove one
8871 F0 03     BEQ P876         ;if last entry then check for multi-pass copy
8873 4C CC 87  JMP P7CC         ;else write next file in copy buffer
;Wrote last entry of copy buffer.  Copy rest of file or refill buffer
.P876
8876 20 FB 84  JSR P4FB         ;restore parameters of source drive
8879 AC F8 FD  LDY &FDF8        ;point to last entry of buffer table
887C 20 07 BE  JSR SE07         ;page in auxiliary workspace
887F B9 19 FD  LDA &FD19,Y      ;test flag byte
8882 29 80     AND #&80         ;if b7=0 file(s) in buffer are complete
8884 F0 2A     BEQ P8B0         ;then start refilling copy buffer
8886 A2 00     LDX #&00         ;else start at offset = 0:
;The last entry in the copy buffer table needs another pass
;to fulfil.  Move it to the first table slot.
.P888
8888 B9 11 FD  LDA &FD11,Y      ;copy last entry to first position
888B 9D 11 FD  STA &FD11,X
888E C8        INY              ;increment offsets
888F E8        INX
8890 E0 17     CPX #&17         ;loop until all 23 bytes copied
8892 D0 F4     BNE P888
8894 A9 40     LDA #&40         ;b6=1 destination file partly copied
8896 8D 19 FD  STA &FD19        ;set buffer table entry's flag byte
8899 20 71 84  JSR P471         ;select source volume
889C 20 32 96  JSR Q632         ;load volume catalogue L4
889F AD D5 FD  LDA &FDD5
88A2 85 BD     STA &BD          ;set start of copy buffer to OSHWM
88A4 A9 00     LDA #&00
88A6 8D F7 FD  STA &FDF7        ;one buffer table entry in use
88A9 85 A8     STA &A8
88AB E6 A8     INC &A8          ;one entry in copy buffer table
88AD 4C 04 87  JMP P704         ;read in the rest of this file.
;Exit if no more files to read; else empty copy buffer and refill it
.P8B0
88B0 24 A8     BIT &A8          ;if b7=1 all files read
88B2 30 15     BMI P8C9         ;then exit
88B4 20 71 84  JSR P471         ;else select source volume
88B7 20 32 96  JSR Q632         ;load volume catalogue L4
88BA AD D5 FD  LDA &FDD5
88BD 85 BD     STA &BD          ;set start of copy buffer to OSHWM
88BF A9 00     LDA #&00
88C1 8D F7 FD  STA &FDF7        ;no buffer table entries in use
88C4 85 A8     STA &A8          ;no entries in copy buffer table
88C6 4C 98 87  JMP P798         ;copy next matching file.
.P8C9
88C9 60        RTS
.P8CA                           ;Store empty BASIC program at OSHWM (NEW)
88CA AD D5 FD  LDA &FDD5        ;get start of user memory
88CD 85 BF     STA &BF          ;store as high byte of pointer
88CF A9 00     LDA #&00         ;clear low byte
88D1 85 BE     STA &BE          ;PAGE is always on a page boundary
88D3 A9 0D     LDA #&0D
88D5 91 BE     STA (&BE),Y      ;&0D = first byte of end-of-program marker
88D7 C8        INY              ;store at start of user memory
88D8 A9 FF     LDA #&FF         ;&FF = second byte of end-of-program marker
88DA 91 BE     STA (&BE),Y      ;store in user memory
88DC 60        RTS
                                ;unreachable code
88DD 20 71 84  JSR P471
88E0 20 32 96  JSR Q632
88E3 20 23 85  JSR P523
88E6 20 16 BE  JSR SE16         ;page in catalogue sector 1
88E9 AD 07 FD  LDA &FD07
88EC 85 C6     STA &C6
88EE AD 06 FD  LDA &FD06
88F1 29 03     AND #&03
88F3 85 C7     STA &C7
88F5 AD 06 FD  LDA &FD06
88F8 29 F0     AND #&F0
88FA 20 0C BE  JSR SE0C         ;page in main workspace
88FD 8D E0 FD  STA &FDE0
8900 20 7E 84  JSR P47E
8903 20 32 96  JSR Q632
8906 4C 2A 85  JMP P52A
                                ;unreachable code
8909 20 16 BE  JSR SE16         ;page in catalogue sector 1
890C AD 06 FD  LDA &FD06
890F 29 03     AND #&03
8911 C5 C7     CMP &C7
8913 90 07     BCC P91C
8915 D0 05     BNE P91C
8917 AD 07 FD  LDA &FD07
891A C5 C6     CMP &C6
.P91C
891C 60        RTS
.P91D                           ;Shift data
891D 20 4C A8  JSR R84C         ;save AXY
8920 A9 02     LDA #&02
8922 8D D7 FD  STA &FDD7        ;2 pages of user memory = catalogue sectors
8925 A9 00     LDA #&00
8927 85 BF     STA &BF          ;MSB of load address in JIM space = &00
.P929
8929 20 84 89  JSR P984         ;set start and size of first transfer
892C A9 02     LDA #&02
892E 85 BE     STA &BE          ;LSB of load address in JIM space = &02
8930 20 24 97  JSR Q724         ;read ordinary file to JIM L5
8933 A5 CA     LDA &CA          ;set LBA = destination volume LBA
8935 85 C5     STA &C5          ;NB always works downwards and shifts upwards
8937 A5 CB     LDA &CB          ;sector reads and writes will not overlap
8939 85 C4     STA &C4
893B A9 02     LDA #&02
893D 85 BE     STA &BE          ;LSB of load address in JIM space = &02
893F 20 21 97  JSR Q721         ;write ordinary file from JIM L5
8942 20 9E 89  JSR P99E         ;adjust addresses by amount transferred
8945 D0 E2     BNE P929         ;loop until no more sectors to transfer
8947 60        RTS
.P948                           ;Copy source drive/file to destination
8948 20 0C BE  JSR SE0C         ;page in main workspace
894B A9 00     LDA #&00
894D 85 BE     STA &BE          ;clear LSB load address
894F 85 C2     STA &C2          ;clear LSB transfer size in bytes
.P951
8951 20 84 89  JSR P984
8954 AD D5 FD  LDA &FDD5        ;set MSB load address = start of user memory
8957 85 BF     STA &BF
8959 20 FB 84  JSR P4FB         ;restore parameters of source drive
895C 20 71 84  JSR P471         ;select source volume
895F 20 9C 95  JSR Q59C         ;set high word of OSFILE load address = &FFFF
8962 20 0D 97  JSR Q70D         ;read extended file L5
8965 A5 CA     LDA &CA          ;set LBA = destination volume LBA
8967 85 C5     STA &C5
8969 A5 CB     LDA &CB
896B 85 C4     STA &C4
896D AD D5 FD  LDA &FDD5        ;set MSB save address = start of user memory
8970 85 BF     STA &BF
8972 20 FF 84  JSR P4FF         ;restore parameters of destination drive
8975 20 7E 84  JSR P47E         ;select destination volume
8978 20 9C 95  JSR Q59C         ;set high word of OSFILE load address = &FFFF
897B 20 13 97  JSR Q713         ;write extended file L5
897E 20 9E 89  JSR P99E         ;adjust addresses by amount transferred
8981 D0 CE     BNE P951         ;loop until no more sectors to transfer
8983 60        RTS
.P984                           ;Set start and size of first transfer
8984 AD D7 FD  LDA &FDD7        ;get number of pages of user memory
8987 85 C3     STA &C3          ;set number of sectors to transfer:
.P989                           ;Set start and size of next transfer
                                ;?&C3 contains no. pages free in user memory
8989 A6 C6     LDX &C6          ;compare remaining file size
898B E4 C3     CPX &C3          ;- available memory
898D A5 C7     LDA &C7
898F E9 00     SBC #&00
8991 B0 02     BCS P995         ;if remainder doesn't fit then fill memory
8993 86 C3     STX &C3          ;else transfer size=file size in pages
.P995
8995 A5 C8     LDA &C8          ;set LBA = source volume LBA
8997 85 C5     STA &C5
8999 A5 C9     LDA &C9
899B 85 C4     STA &C4
899D 60        RTS
.P99E                           ;Adjust addresses by amount transferred
899E A5 CA     LDA &CA          ;get LSB destination LBA
89A0 18        CLC
89A1 65 C3     ADC &C3          ;add number of sectors transferred
89A3 85 CA     STA &CA          ;store LSB destination LBA
89A5 90 02     BCC P9A9         ;carry out to MSB
89A7 E6 CB     INC &CB
.P9A9
89A9 A5 C3     LDA &C3          ;get number of sectors transferred
89AB 18        CLC
89AC 65 C8     ADC &C8          ;add LSB source LBA
89AE 85 C8     STA &C8          ;store LSB source LBA
89B0 90 02     BCC P9B4         ;carry out to MSB:
89B2 E6 C9     INC &C9
.P9B4                           ;Subtract transfer size from remainder
89B4 38        SEC
89B5 A5 C6     LDA &C6          ;get LSB number of sectors in volume
89B7 E5 C3     SBC &C3          ;subtract amount transferred
89B9 85 C6     STA &C6          ;store LSB number of sectors remaining
89BB B0 02     BCS P9BF         ;borrow from MSB
89BD C6 C7     DEC &C7
.P9BF
89BF 05 C7     ORA &C7          ;return Z=no more sectors to transfer
89C1 60        RTS
.P9C2                           ;Copy doubleword into OSFILE field
89C2 20 D2 89  JSR P9D2         ;copy low word into OSFILE field
89C5 CA        DEX              ;restore offset in X = 4 * field no.
89C6 CA        DEX
89C7 20 CA 89  JSR P9CA         ;copy 3MSB of dword to workspace:
.P9CA                           ;Copy high byte into OSFILE field
89CA B1 B0     LDA (&B0),Y      ;fetch byte from zero page workspace
89CC 9D B3 FD  STA &FDB3,X      ;store in OSFILE high words table
89CF E8        INX              ;increment offsets
89D0 C8        INY
89D1 60        RTS
.P9D2                           ;Copy low word into OSFILE field
89D2 20 D5 89  JSR P9D5         ;copy LSB of word into workspace:
.P9D5                           ;Copy low byte into OSFILE field
89D5 B1 B0     LDA (&B0),Y      ;fetch byte from zero page workspace
89D7 95 BC     STA &BC,X        ;store in OSFILE low words table
89D9 E8        INX              ;increment offsets
89DA C8        INY
89DB 60        RTS
.P9DC
89DC 20 1E AA  JSR RA1E         ;set current volume and dir = default
89DF 4C F2 89  JMP P9F2
.P9E2                           ;Set current file from argument pointer
89E2 20 1E AA  JSR RA1E         ;set current volume and dir = default:
.P9E5                           ;Parse file spec from argument pointer
89E5 A5 BC     LDA &BC          ;copy argument pointer to GSINIT pointer
89E7 85 F2     STA &F2
89E9 A5 BD     LDA &BD
89EB 85 F3     STA &F3
89ED A0 00     LDY #&00         ;set Y = 0 offset for GSINIT
89EF 20 F2 A9  JSR R9F2         ;call GSINIT with C=0:
.P9F2                           ;Parse file spec
89F2 20 5D 8A  JSR PA5D         ;set current filename to all spaces
89F5 20 C5 FF  JSR &FFC5        ;call GSREAD
89F8 B0 53     BCS PA4D         ;if argument empty then "Bad filename"
89FA C9 3A     CMP #&3A         ;else is first character ":"?
89FC D0 22     BNE PA20         ;if not then skip to dir/filename
89FE 20 C5 FF  JSR &FFC5        ;else a drive is specified, call GSREAD
8A01 B0 57     BCS PA5A         ;if no drive number then "Bad drive"
8A03 20 F6 A9  JSR R9F6         ;else set current drive from ASCII digit
8A06 20 C5 FF  JSR &FFC5        ;call GSREAD
8A09 B0 42     BCS PA4D         ;if only drive specified then "Bad filename"
8A0B C9 2E     CMP #&2E         ;else if next character is "."
8A0D F0 0C     BEQ PA1B         ;then get first character of filename
8A0F 20 FC A9  JSR R9FC         ;else set volume from ASCII letter
8A12 20 C5 FF  JSR &FFC5        ;call GSREAD
8A15 B0 36     BCS PA4D         ;if only volume spec'd then "Bad filename"
8A17 C9 2E     CMP #&2E         ;if separator character "." missing
8A19 D0 32     BNE PA4D         ;then raise "Bad filename" error
.PA1B
8A1B 20 C5 FF  JSR &FFC5        ;call GSREAD, get first character of filename
8A1E B0 2D     BCS PA4D         ;if filename is empty then "Bad filename"
.PA20
8A20 85 C7     STA &C7          ;else save first character of filename
8A22 A2 00     LDX #&00         ;set filename offset = 0
8A24 20 C5 FF  JSR &FFC5        ;call GSREAD, get second filename character
8A27 B0 44     BCS PA6D         ;if absent then process one-character name
8A29 E8        INX              ;else offset = 1
8A2A C9 2E     CMP #&2E         ;is the second character "."?
8A2C D0 0B     BNE PA39         ;if not then read in rest of leaf name
8A2E A5 C7     LDA &C7          ;else first character was a directory spec
8A30 20 B0 AA  JSR RAB0         ;set directory from ASCII character
8A33 20 C5 FF  JSR &FFC5        ;call GSREAD, get first character of leaf name
8A36 B0 15     BCS PA4D         ;if leaf name is empty then "Bad filename"
8A38 CA        DEX              ;else offset = 0, read in leaf name:
.PA39
8A39 C9 2A     CMP #&2A         ;is filename character "*"?
8A3B F0 36     BEQ PA73         ;if so then process "*" in filename
8A3D C9 21     CMP #&21         ;else is it a control character or space?
8A3F 90 0C     BCC PA4D         ;if so then raise "Bad filename" error
8A41 95 C7     STA &C7,X        ;else store character of filename
8A43 E8        INX              ;point X to next character of current filename
8A44 20 C5 FF  JSR &FFC5        ;call GSREAD, get next character of leaf name
8A47 B0 23     BCS PA6C         ;if no more then filename complete, return
8A49 E0 07     CPX #&07         ;else have seven characters been read already?
8A4B D0 EC     BNE PA39         ;if not then loop, else:
.PA4D                           ;Raise "Bad filename" error.
8A4D 20 9C A8  JSR R89C
8A50 EQUB &CC
8A51 EQUS "filename"
8A59 EQUB &00
.PA5A
8A5A 4C 34 AA  JMP RA34         ;raise "Bad drive" error
.PA5D                           ;Set current filename to all spaces
8A5D A2 00     LDX #&00
8A5F A9 20     LDA #&20
8A61 D0 02     BNE PA65         ;branch (always)
.PA63                           ;Pad current filename with "#"s
8A63 A9 23     LDA #&23         ;x=offset of end of filename
.PA65
8A65 95 C7     STA &C7,X
8A67 E8        INX
8A68 E0 07     CPX #&07
8A6A D0 F9     BNE PA65
.PA6C
8A6C 60        RTS
.PA6D                           ;Process one-character filename
8A6D A5 C7     LDA &C7          ;if filename is "*", then:
8A6F C9 2A     CMP #&2A
8A71 D0 F9     BNE PA6C
.PA73                           ;Process "*" in filename
8A73 20 C5 FF  JSR &FFC5        ;call GSREAD
8A76 B0 EB     BCS PA63         ;if end of argument pad filename with "#"s
8A78 C9 20     CMP #&20         ;else if next character is space
8A7A F0 E7     BEQ PA63         ;then pad filename with "#"s
8A7C D0 CF     BNE PA4D         ;else raise "Bad filename" error.
.PA7E                           ;Ensure disc not changed
8A7E 20 4C A8  JSR R84C         ;save AXY
8A81 20 16 BE  JSR SE16         ;page in catalogue sector 1
8A84 AD 04 FD  LDA &FD04        ;get cycle number of last catalogue read
8A87 20 2F 96  JSR Q62F         ;load volume catalogue L4
8A8A 20 16 BE  JSR SE16         ;page in catalogue sector 1
8A8D CD 04 FD  CMP &FD04        ;compare with freshly loaded cycle number
8A90 F0 DA     BEQ PA6C         ;return if equal, else:
.PA92
8A92 20 AD A8  JSR R8AD         ;Raise "Disk changed" error.
8A95 EQUB &C8
8A96 EQUS "Disk changed"
8AA2 EQUB &00
.PAA3                           ;Print filename from catalogue
8AA3 20 4C A8  JSR R84C         ;save AXY
8AA6 20 11 BE  JSR SE11         ;page in catalogue sector 0
8AA9 B9 0F FD  LDA &FD0F,Y      ;get directory character
8AAC 08        PHP              ;save N = lock attribute
8AAD 29 7F     AND #&7F         ;extract ASCII character
8AAF D0 05     BNE PAB6         ;if NUL then file is in CSD
8AB1 20 15 A8  JSR R815         ;so print two spaces
8AB4 F0 06     BEQ PABC         ;branch (always)
.PAB6
8AB6 20 51 A9  JSR R951         ;else print directory character
8AB9 20 4F A9  JSR R94F         ;print a dot
.PABC
8ABC A2 06     LDX #&06         ;repeat 7 times:
.PABE
8ABE B9 08 FD  LDA &FD08,Y      ;get character of leaf name
8AC1 29 7F     AND #&7F         ;mask bit 7
8AC3 20 51 A9  JSR R951         ;print character
8AC6 C8        INY
8AC7 CA        DEX
8AC8 10 F4     BPL PABE         ;and loop
8ACA 20 0C BE  JSR SE0C         ;page in main workspace
8ACD 20 15 A8  JSR R815         ;print two spaces
8AD0 A9 20     LDA #&20         ;a = space
8AD2 28        PLP              ;restore lock attribute in N
8AD3 10 02     BPL PAD7         ;if lock bit set
8AD5 A9 4C     LDA #&4C         ;then A = capital L
.PAD7
8AD7 20 51 A9  JSR R951         ;print attribute character
8ADA 4C 18 A8  JMP R818         ;print a space and exit
.PADD                           ;Print number of spaces in Y
8ADD 20 18 A8  JSR R818         ;print a space
8AE0 88        DEY              ;loop until Y = 0
8AE1 D0 FA     BNE PADD
8AE3 60        RTS
.PAE4                           ;Prepare extended file transfer
8AE4 A9 00     LDA #&00         ;set MSB length = 0; transfer less than 64 KiB
8AE6 85 A5     STA &A5
8AE8 A6 C4     LDX &C4          ;x = LSB of relative LBA
8AEA 4C F9 8A  JMP PAF9
.PAED                           ;Prepare ordinary file transfer
8AED A5 C4     LDA &C4          ;get top bits exec/length/load/start sector
8AEF 20 96 A9  JSR R996         ;extract b5,b4 of A
8AF2 85 A5     STA &A5          ;?&A5 = b17..16 (MSB) of length
8AF4 A5 C4     LDA &C4          ;x = b9..8 (MSB) of relative LBA
8AF6 29 03     AND #&03
8AF8 AA        TAX
.PAF9
8AF9 A5 BE     LDA &BE          ;copy user data address to NMI area
8AFB 85 A6     STA &A6
8AFD A5 BF     LDA &BF
8AFF 85 A7     STA &A7
8B01 A5 C3     LDA &C3          ;copy 2MSB length
8B03 85 A4     STA &A4
8B05 A5 C2     LDA &C2          ;copy LSB length
8B07 85 A3     STA &A3
8B09 86 BA     STX &BA          ;store LSB/MSB of LBA (clobbered if LSB)
8B0B A5 C5     LDA &C5          ;copy MSB/LSB of LBA
8B0D 85 BB     STA &BB
8B0F AD EB FD  LDA &FDEB        ;get number of sectors per track
8B12 F0 19     BEQ PB2D         ;if not defined then just use the LBA
8B14 AD EC FD  LDA &FDEC        ;else get first track of current volume
8B17 85 BA     STA &BA          ;set track number for transfer
8B19 C6 BA     DEC &BA          ;decrement, to increment at start of loop
8B1B A5 C5     LDA &C5          ;get LSB of relative LBA:
.PB1D
8B1D 38        SEC              ;set C=1 to subtract without borrow:
.PB1E
8B1E E6 BA     INC &BA          ;increment track number
8B20 ED EB FD  SBC &FDEB        ;subtract sectors-per-track from LBA
8B23 B0 F9     BCS PB1E         ;loop until LSB borrows in
8B25 CA        DEX              ;then decrement MSB of relative LBA
8B26 10 F5     BPL PB1D         ;loop until MSB borrows in/underflows
8B28 6D EB FD  ADC &FDEB        ;add sectors per track to negative remainder
8B2B 85 BB     STA &BB          ;set sector number.
.PB2D
8B2D 60        RTS
.PB2E                           ;Allow wildcard characters in filename
8B2E A9 23     LDA #&23
8B30 D0 02     BNE PB34
.PB32                           ;Disallow wildcard characters in filename
8B32 A9 FF     LDA #&FF
.PB34
8B34 8D D8 FD  STA &FDD8
8B37 60        RTS
.PB38                           ;Ensure file matching spec in catalogue
8B38 20 DC 89  JSR P9DC         ;set current file from file spec
8B3B 4C 41 8B  JMP PB41         ;ensure matching file in catalogue
.PB3E                           ;Ensure file matching argument in catalogue
8B3E 20 E2 89  JSR P9E2         ;set current file from argument pointer:
.PB41                           ;Ensure matching file in catalogue
8B41 20 2E 8C  JSR PC2E         ;search for file in catalogue
8B44 B0 E7     BCS PB2D         ;if found then return
.PB46
8B46 20 A5 A8  JSR R8A5         ;else raise "File not found" error.
8B49 EQUB &D6
8B4A EQUS "not found"
8B53 EQUB &00
                                ;*MAP
8B54 20 16 AA  JSR RA16         ;parse volume spec from argument
8B57 20 2F 96  JSR Q62F         ;load volume catalogue L4
8B5A A9 00     LDA #&00
8B5C 85 C4     STA &C4          ;clear MSB start of data area
8B5E 85 C6     STA &C6          ;clear total free space
8B60 85 C7     STA &C7
8B62 20 F8 A4  JSR R4F8         ;return no. reserved sectors in data area
8B65 85 C5     STA &C5          ;store LSB start of data area
8B67 AD EC FD  LDA &FDEC        ;if this volume's data area starts >track 0
8B6A F0 1C     BEQ PB88
8B6C 20 D3 A8  JSR R8D3         ;then print "Track offset = "
8B6F EQUS "  Track offset  = "
8B81 EA        NOP
8B82 20 78 A9  JSR R978         ;print hex byte
8B85 20 69 84  JSR P469         ;print newline
.PB88
8B88 20 16 BE  JSR SE16         ;page in catalogue sector 1
8B8B AC 05 FD  LDY &FD05        ;y = offset of last catalogue entry:
.PB8E
8B8E 20 07 95  JSR Q507         ;calculate slack space after file
8B91 F0 2F     BEQ PBC2         ;if no slack space then only map the file
8B93 18        CLC
8B94 A5 B0     LDA &B0          ;else add LSB slack space
8B96 65 C6     ADC &C6          ;to LSB total free space
8B98 85 C6     STA &C6
8B9A 8A        TXA              ;add MSB slack space
8B9B 65 C7     ADC &C7          ;and carry out
8B9D 85 C7     STA &C7          ;to MSB total free space
8B9F 20 D3 A8  JSR R8D3         ;print "  Free space "
8BA2 EQUS "  Free space "
8BAF EA        NOP
8BB0 20 01 8C  JSR PC01         ;print number of sectors
8BB3 20 18 A8  JSR R818         ;print a space
8BB6 8A        TXA              ;a = MSB slack space
8BB7 20 80 A9  JSR R980         ;print hex nibble
8BBA A5 B0     LDA &B0          ;a = LSB slack space
8BBC 20 78 A9  JSR R978         ;print hex byte
8BBF 20 69 84  JSR P469         ;print newline
.PBC2
8BC2 98        TYA              ;if end of catalogue reached
8BC3 F0 1B     BEQ PBE0         ;then print total free space
8BC5 20 B2 A9  JSR R9B2         ;else subtract 8 from Y
8BC8 20 A3 8A  JSR PAA3         ;print filename from catalogue
8BCB 20 E3 8C  JSR PCE3         ;print start sector
8BCE 20 18 A8  JSR R818         ;print a space
8BD1 20 EB 94  JSR Q4EB         ;calculate number of sectors used by file
8BD4 20 01 8C  JSR PC01         ;print number of sectors
8BD7 20 69 84  JSR P469         ;print newline
8BDA 20 D6 94  JSR Q4D6         ;calculate LBA of end of file
8BDD 4C 8E 8B  JMP PB8E         ;loop to map next file.
.PBE0                           ;Print total free space
8BE0 20 D3 A8  JSR R8D3         ;print "Free sectors "
8BE3 EQUB &0D
8BE4 EQUS "Free sectors "
8BF1 A5 C7     LDA &C7          ;a = MSB total free space
8BF3 20 80 A9  JSR R980         ;print hex nibble
8BF6 A5 C6     LDA &C6          ;a = LSB total free space
8BF8 20 78 A9  JSR R978         ;print hex byte
8BFB 20 69 84  JSR P469         ;print newline
8BFE 4C 0C BE  JMP SE0C         ;page in main workspace
.PC01                           ;Print number of sectors
8C01 A5 C4     LDA &C4          ;get MSB size of file or slack space
8C03 20 80 A9  JSR R980         ;print hex nibble
8C06 A5 C5     LDA &C5          ;get LSB size of file or slack space
8C08 4C 78 A9  JMP R978         ;print hex byte
                                ;OSFSC  9 = *EX
8C0B 20 38 92  JSR Q238         ;set GSINIT pointer to XY, set Y=0
8C0E 20 16 AA  JSR RA16         ;parse volume spec from argument
8C11 A2 00     LDX #&00         ;set X = 0, whole current filename to #s
8C13 20 63 8A  JSR PA63         ;set current filename = "#######"
8C16 4C 1C 8C  JMP PC1C         ;jump into *INFO
                                ;OSFSC 10 = *INFO
8C19 20 38 92  JSR Q238         ;set GSINIT pointer to XY, set Y=0
.PC1C
                                ;*INFO
8C1C 20 2E 8B  JSR PB2E         ;allow wildcard characters in filename
8C1F 20 65 A5  JSR R565         ;call GSINIT with C=0 and reject empty arg
8C22 20 38 8B  JSR PB38         ;ensure file matching spec in catalogue
.PC25
8C25 20 A5 8C  JSR PCA5         ;print *INFO line
8C28 20 35 8C  JSR PC35         ;find next matching file
8C2B B0 F8     BCS PC25         ;loop until no more files match.
8C2D 60        RTS
.PC2E                           ;Search for file in catalogue
8C2E 20 1F 96  JSR Q61F         ;ensure current volume catalogue loaded
8C31 A0 F8     LDY #&F8         ;y=&F8, start beyond first catalogue entry
8C33 D0 06     BNE PC3B         ;and jump into search loop (always)
.PC35                           ;Find next matching file
8C35 20 0C BE  JSR SE0C         ;page in main workspace
8C38 AC C2 FD  LDY &FDC2        ;set Y = catalogue pointer
.PC3B
8C3B 20 16 BE  JSR SE16         ;page in catalogue sector 1
8C3E 20 A9 A9  JSR R9A9         ;add 8 to Y
8C41 CC 05 FD  CPY &FD05        ;have we reached the end of the catalogue?
8C44 B0 53     BCS PC99         ;if so return C=0 file not found
8C46 20 A9 A9  JSR R9A9         ;else add 8 to Y
8C49 A2 07     LDX #&07         ;x=7 point to directory character:
.PC4B
8C4B 20 0C BE  JSR SE0C         ;page in main workspace
8C4E B5 C7     LDA &C7,X        ;get character of current filename
8C50 CD D8 FD  CMP &FDD8        ;compare with wildcard mask
8C53 F0 11     BEQ PC66         ;if ='#' and wildcards allowed accept char
8C55 20 D1 A9  JSR R9D1         ;else set C=0 iff character in A is a letter
8C58 20 11 BE  JSR SE11         ;page in catalogue sector 0
8C5B 59 07 FD  EOR &FD07,Y      ;compare with character in catalogue
8C5E B0 02     BCS PC62         ;if character in current filename is letter
8C60 29 DF     AND #&DF         ;then ignore case
.PC62
8C62 29 7F     AND #&7F         ;ignore bit 7, Z=1 if characters equal
8C64 D0 0C     BNE PC72         ;if not equal then test next file
.PC66
8C66 88        DEY              ;loop to test next (previous) char of name
8C67 CA        DEX
8C68 10 E1     BPL PC4B         ;if no more chars to test then files match
8C6A 20 0C BE  JSR SE0C         ;page in main workspace
8C6D 8C C2 FD  STY &FDC2        ;save cat. offset of found file in workspace
8C70 38        SEC              ;return C=1 file found
8C71 60        RTS
.PC72                           ;catalogue entry does not match file spec
8C72 88        DEY              ;advance catalogue pointer to next file
8C73 CA        DEX
8C74 10 FC     BPL PC72
8C76 30 C3     BMI PC3B         ;loop until file found or not
.PC78                           ;Delete catalogue entry
8C78 20 A8 A2  JSR R2A8         ;ensure file not locked or open (mutex)
.PC7B
8C7B 20 11 BE  JSR SE11         ;page in catalogue sector 0
8C7E B9 10 FD  LDA &FD10,Y      ;copy next file's entry over previous entry
8C81 99 08 FD  STA &FD08,Y      ;shifting entries up one place
8C84 20 16 BE  JSR SE16         ;page in catalogue sector 1
8C87 B9 10 FD  LDA &FD10,Y      ;(copies title/boot/size if catalogue full)
8C8A 99 08 FD  STA &FD08,Y
8C8D C8        INY              ;loop until current file count reached
8C8E CC 05 FD  CPY &FD05        ;have we reached the end of the catalogue?
8C91 90 E8     BCC PC7B
8C93 98        TYA              ;copy Y to A = pointer to last file; C=1
8C94 E9 08     SBC #&08         ;subtract 8, catalogue contains one file less
8C96 8D 05 FD  STA &FD05        ;store new file count
.PC99
8C99 18        CLC
.PC9A
8C9A 4C 0C BE  JMP SE0C         ;page in main workspace and exit.
.PC9D                           ;Print *INFO line if verbose
8C9D 20 0C BE  JSR SE0C         ;page in main workspace
8CA0 2C D9 FD  BIT &FDD9        ;test *OPT 1 setting
8CA3 30 F5     BMI PC9A         ;if b7=1 then *OPT 1,0 do not print, else:
.PCA5                           ;Print *INFO line
8CA5 20 4C A8  JSR R84C         ;save AXY
8CA8 20 A3 8A  JSR PAA3         ;print filename from catalogue
8CAB 98        TYA              ;save catalogue pointer
8CAC 48        PHA
8CAD A9 A1     LDA #&A1         ;set up pointer to OSFILE block in workspace
8CAF 85 B0     STA &B0          ;at &FDA1
8CB1 A9 FD     LDA #&FD
8CB3 85 B1     STA &B1
8CB5 20 F7 8C  JSR PCF7         ;return catalogue information to OSFILE block
8CB8 20 0C BE  JSR SE0C         ;page in main workspace
8CBB A0 02     LDY #&02         ;y = &02 offset of load address in block
8CBD 20 18 A8  JSR R818         ;print a space
8CC0 20 D1 8C  JSR PCD1         ;print load address
8CC3 20 D1 8C  JSR PCD1         ;print execution address
8CC6 20 D1 8C  JSR PCD1         ;print file length
8CC9 68        PLA              ;restore catalogue pointer
8CCA A8        TAY
8CCB 20 E3 8C  JSR PCE3         ;print start sector
8CCE 4C 69 84  JMP P469         ;print newline
.PCD1                           ;Print 24-bit field at &FDA1,Y
8CD1 A2 03     LDX #&03         ;start at MSB, offset = 3:
.PCD3
8CD3 B9 A3 FD  LDA &FDA3,Y      ;get byte at &FDA3,Y
8CD6 20 78 A9  JSR R978         ;print hex byte
8CD9 88        DEY              ;increment offset
8CDA CA        DEX              ;decrement counter
8CDB D0 F6     BNE PCD3         ;loop until 3 bytes printed
8CDD 20 AA A9  JSR R9AA         ;add 7 to Y to point to MSB of next field
8CE0 4C 18 A8  JMP R818         ;print a space and exit
.PCE3                           ;Print start sector
8CE3 20 16 BE  JSR SE16         ;page in catalogue sector 1
8CE6 B9 0E FD  LDA &FD0E,Y      ;get top bits exec/length/load/start sector
8CE9 29 03     AND #&03         ;extract MSB start sector
8CEB 20 80 A9  JSR R980         ;print hex nibble
8CEE B9 0F FD  LDA &FD0F,Y      ;get LSB start sector
8CF1 20 78 A9  JSR R978         ;print hex byte
8CF4 4C 0C BE  JMP SE0C         ;page in main workspace
.PCF7                           ;Return catalogue information to OSFILE block
8CF7 20 4C A8  JSR R84C         ;save AXY
8CFA 98        TYA              ;save catalogue pointer on stack
8CFB 48        PHA
8CFC AA        TAX              ;and copy to X
8CFD 20 0C BE  JSR SE0C         ;page in main workspace
8D00 A0 02     LDY #&02         ;clear bytes at offsets 2..17
8D02 A9 00     LDA #&00
.PD04
8D04 91 B0     STA (&B0),Y
8D06 C8        INY
8D07 C0 12     CPY #&12
8D09 D0 F9     BNE PD04
8D0B A0 02     LDY #&02         ;offset 2 = LSB load address
.PD0D
8D0D 20 55 8D  JSR PD55         ;copy two bytes from catalogue to OSFILE block
8D10 C8        INY              ;skip high bytes of OSFILE field
8D11 C8        INY
8D12 C0 0E     CPY #&0E         ;loop until 3 fields half-filled:
8D14 D0 F7     BNE PD0D         ;load address, execution address, file length
8D16 68        PLA              ;restore catalogue pointer
8D17 AA        TAX
8D18 20 11 BE  JSR SE11         ;page in catalogue sector 0
8D1B BD 0F FD  LDA &FD0F,X      ;get directory character
8D1E 10 09     BPL PD29         ;if b7=1 then file is locked
8D20 A9 0A     LDA #&0A         ;so set attributes to LR/RW (old style)
8D22 A0 0E     LDY #&0E         ;no delete, owner read only, public read/write
8D24 20 0C BE  JSR SE0C         ;page in main workspace
8D27 91 B0     STA (&B0),Y      ;store in OSFILE block
.PD29
8D29 20 16 BE  JSR SE16         ;page in catalogue sector 1
8D2C BD 0E FD  LDA &FD0E,X      ;get top bits exec/length/load/start sector
8D2F 20 0C BE  JSR SE0C         ;page in main workspace
8D32 A0 04     LDY #&04         ;offset 4 = 2MSB load address
8D34 20 43 8D  JSR PD43         ;expand bits 3,2 to top 16 bits of field
8D37 A0 0C     LDY #&0C         ;offset 12 = 2MSB file length
8D39 4A        LSR A            ;PD43 returned A = ..eelldd
8D3A 4A        LSR A            ;shift A right twice to make A = ....eell
8D3B 48        PHA              ;save exec address
8D3C 29 03     AND #&03         ;extract bits 1,0 for length (don't expand)
8D3E 91 B0     STA (&B0),Y      ;store in OSFILE block
8D40 68        PLA              ;restore exec address in bits 3,2
8D41 A0 08     LDY #&08         ;offset 8 = 2MSB execution address:
.PD43
8D43 4A        LSR A            ;shift A right 2 places
8D44 4A        LSR A
8D45 48        PHA              ;save shifted value for return
8D46 29 03     AND #&03         ;extract bits 3,2 of A on entry
8D48 C9 03     CMP #&03         ;if either one is clear
8D4A D0 05     BNE PD51         ;then save both as b1,0 of 2MSB
8D4C A9 FF     LDA #&FF         ;else set MSB and 2MSB = &FF.
8D4E 91 B0     STA (&B0),Y
8D50 C8        INY
.PD51
8D51 91 B0     STA (&B0),Y
8D53 68        PLA              ;discard byte on stack
8D54 60        RTS
.PD55                           ;Copy two bytes from catalogue to OSFILE block
8D55 20 58 8D  JSR PD58
.PD58
8D58 20 16 BE  JSR SE16         ;page in catalogue sector 1
8D5B BD 08 FD  LDA &FD08,X
8D5E 20 0C BE  JSR SE0C         ;page in main workspace
8D61 91 B0     STA (&B0),Y
8D63 E8        INX
8D64 C8        INY
8D65 60        RTS
                                ;*STAT
8D66 20 F2 A9  JSR R9F2         ;call GSINIT with C=0
8D69 20 72 AA  JSR RA72         ;select specified or default volume
8D6C 8A        TXA              ;test bit 0 of X
8D6D 29 01     AND #&01         ;if X=3 drive and volume specified
8D6F F0 03     BEQ PD74
8D71 4C B3 8D  JMP PDB3         ;then stat specified volume, else:
.PD74                           ;*STAT eight volumes if double density
8D74 A5 CF     LDA &CF          ;get current volume
8D76 29 0F     AND #&0F         ;extract drive number
8D78 85 CF     STA &CF          ;set current volume letter to A
8D7A A9 80     LDA #&80         ;data transfer call &80 = read data to JIM
8D7C 8D E9 FD  STA &FDE9        ;set data transfer call number
8D7F 20 B5 AB  JSR RBB5         ;detect disc format/set sector address
8D82 2C ED FD  BIT &FDED        ;test density flag
8D85 70 03     BVS PD8A         ;if double density then *STAT eight volumes
8D87 4C B3 8D  JMP PDB3         ;else *STAT the single volume
.PD8A                           ;*STAT eight volumes
8D8A 20 0B 8F  JSR PF0B         ;print disc type and volume list
8D8D A2 00     LDX #&00         ;for each volume letter A..H:
.PD8F
8D8F 20 07 BE  JSR SE07         ;page in auxiliary workspace
8D92 BD CD FD  LDA &FDCD,X      ;test if number of tracks in volume > 0
8D95 F0 0D     BEQ PDA4         ;if = 0 then no such volume, skip
8D97 8A        TXA              ;save volume counter
8D98 48        PHA
8D99 20 69 84  JSR P469         ;print newline
8D9C 20 1F 96  JSR Q61F         ;ensure current volume catalogue loaded
8D9F 20 33 90  JSR Q033         ;print volume statistics
8DA2 68        PLA              ;restore volume counter
8DA3 AA        TAX
.PDA4
8DA4 18        CLC
8DA5 A5 CF     LDA &CF          ;get current volume
8DA7 69 10     ADC #&10         ;increment volume letter
8DA9 85 CF     STA &CF          ;set as current volume
8DAB E8        INX              ;increment counter
8DAC E0 08     CPX #&08         ;loop until 8 volumes catalogued
8DAE D0 DF     BNE PD8F
8DB0 4C 0C BE  JMP SE0C
.PDB3                           ;*STAT specified volume
8DB3 20 1F 96  JSR Q61F         ;ensure current volume catalogue loaded
8DB6 20 0B 8F  JSR PF0B         ;print disc type and volume list
8DB9 4C 33 90  JMP Q033         ;print volume statistics
.PDBC                           ;Print "No file"
8DBC 20 D3 A8  JSR R8D3         ;print string immediate
8DBF EQUB &0D                   ;newline
8DC0 EQUS "No file"
8DC7 EQUB &0D                   ;newline
8DC8 EA        NOP
8DC9 60        RTS
.PDCA                           ;List files in catalogue
8DCA 20 16 BE  JSR SE16         ;page in catalogue sector 1
8DCD AD 05 FD  LDA &FD05        ;get number of files in catalogue * 8
8DD0 F0 EA     BEQ PDBC         ;if catalogue empty then print "No file"
8DD2 85 AC     STA &AC          ;else copy file count to zero page
8DD4 A0 FF     LDY #&FF
8DD6 84 A8     STY &A8          ;print a newline before first entry
8DD8 C8        INY
8DD9 84 AA     STY &AA          ;CSD printed first, directory char = NUL
.PDDB
8DDB 20 11 BE  JSR SE11         ;page in catalogue sector 0
8DDE C4 AC     CPY &AC          ;have we reached the end of the catalogue?
8DE0 B0 1D     BCS PDFF         ;if so then start sorting entries
8DE2 B9 0F FD  LDA &FD0F,Y      ;else get directory character of cat entry
8DE5 20 0C BE  JSR SE0C         ;page in main workspace
8DE8 4D C6 FD  EOR &FDC6        ;compare with default (CSD) directory
8DEB 20 11 BE  JSR SE11         ;page in catalogue sector 0
8DEE 29 7F     AND #&7F         ;mask off lock bit
8DF0 D0 08     BNE PDFA         ;if directories differ skip to next entry
8DF2 B9 0F FD  LDA &FD0F,Y      ;else set directory character to NUL
8DF5 29 80     AND #&80         ;and preserve lock bit
8DF7 99 0F FD  STA &FD0F,Y
.PDFA
8DFA 20 A9 A9  JSR R9A9         ;add 8 to Y
8DFD 90 DC     BCC PDDB         ;and loop (always)
.PDFF
8DFF 20 11 BE  JSR SE11         ;page in catalogue sector 0
8E02 A0 00     LDY #&00         ;y=&00, start at first file entry
8E04 20 9E 8E  JSR PE9E         ;find unlisted catalogue entry
8E07 90 09     BCC PE12         ;if entry found then list it
8E09 20 0C BE  JSR SE0C         ;else finish catalogue.
8E0C 20 53 97  JSR Q753         ;forget catalogue in JIM pages 2..3
8E0F 4C 69 84  JMP P469         ;print newline and exit
.PE12
8E12 84 AB     STY &AB          ;save catalogue pointer
8E14 A2 00     LDX #&00         ;set filename offset = 0
.PE16
8E16 20 11 BE  JSR SE11
8E19 B9 08 FD  LDA &FD08,Y      ;copy name and directory of first entry
8E1C 29 7F     AND #&7F         ;with b7 clear
8E1E 20 0C BE  JSR SE0C
8E21 9D A1 FD  STA &FDA1,X      ;to workspace
8E24 C8        INY              ;loop until 8 characters copied
8E25 E8        INX
8E26 E0 08     CPX #&08
8E28 D0 EC     BNE PE16
.PE2A
8E2A 20 11 BE  JSR SE11
8E2D 20 9E 8E  JSR PE9E         ;find unlisted catalogue entry
8E30 B0 2B     BCS PE5D         ;if none remaining then print lowest entry
8E32 38        SEC              ;else set C=1 for subtraction
8E33 A2 06     LDX #&06         ;start at 6th character (LSB) of leaf name:
.PE35
8E35 20 11 BE  JSR SE11         ;page in catalogue sector 0
8E38 B9 0E FD  LDA &FD0E,Y      ;get character of entry
8E3B 20 0C BE  JSR SE0C         ;page in main workspace
8E3E FD A1 FD  SBC &FDA1,X      ;subtract character of workspace
8E41 88        DEY              ;loop until 7 characters compared
8E42 CA        DEX
8E43 10 F0     BPL PE35
8E45 20 AA A9  JSR R9AA         ;add 7 to Y
8E48 20 11 BE  JSR SE11         ;page in catalogue sector 0
8E4B B9 0F FD  LDA &FD0F,Y      ;get directory character (MSB) of entry
8E4E 29 7F     AND #&7F         ;mask off lock bit
8E50 20 0C BE  JSR SE0C         ;page in main workspace
8E53 ED A8 FD  SBC &FDA8        ;subtract directory character in workspace
8E56 90 BA     BCC PE12         ;if entry < wksp then copy entry to wksp
8E58 20 A9 A9  JSR R9A9         ;else add 8 to Y
8E5B B0 CD     BCS PE2A         ;and loop (always)
.PE5D
8E5D 20 11 BE  JSR SE11         ;page in catalogue sector 0
8E60 A4 AB     LDY &AB          ;get catalogue pointer
8E62 B9 08 FD  LDA &FD08,Y      ;set b7 in first character of leaf name
8E65 09 80     ORA #&80         ;marking entry as listed
8E67 99 08 FD  STA &FD08,Y
8E6A 20 0C BE  JSR SE0C         ;page in main workspace
8E6D AD A8 FD  LDA &FDA8        ;get directory character from workspace
8E70 C5 AA     CMP &AA          ;compare with last one printed
8E72 F0 10     BEQ PE84         ;if same then add entry to group
8E74 A6 AA     LDX &AA          ;else test previous directory
8E76 85 AA     STA &AA          ;set previous directory = current directory
8E78 D0 0A     BNE PE84         ;if prev=NUL we go from CSD to other dirs
8E7A 20 69 84  JSR P469         ;so print double newline:
.PE7D
8E7D 20 69 84  JSR P469         ;print newline
8E80 A0 FF     LDY #&FF         ;set Y = &FF going to 0, start of line
8E82 D0 09     BNE PE8D         ;branch (always)
.PE84
8E84 A4 A8     LDY &A8          ;have we printed two entries on this line?
8E86 D0 F5     BNE PE7D         ;if so then print newline and reset counter
8E88 A0 05     LDY #&05         ;else tab to next field. Y = 5 spaces
8E8A 20 DD 8A  JSR PADD         ;print number of spaces in Y, set index = 1:
.PE8D
8E8D C8        INY
8E8E 84 A8     STY &A8          ;y = index of next entry on this line
8E90 A4 AB     LDY &AB          ;get catalogue pointer
8E92 20 15 A8  JSR R815         ;print two spaces
8E95 20 A3 8A  JSR PAA3         ;print filename from catalogue
8E98 4C FF 8D  JMP PDFF         ;loop until all files listed
.PE9B                           ;Find next unlisted catalogue entry
8E9B 20 A9 A9  JSR R9A9         ;add 8 to Y
.PE9E                           ;Find unlisted catalogue entry
8E9E C4 AC     CPY &AC          ;if catalogue pointer beyond last file
8EA0 B0 05     BCS PEA7         ;then return C=1
8EA2 B9 08 FD  LDA &FD08,Y      ;else test first character of leaf name
8EA5 30 F4     BMI PE9B         ;if b7=1 then already listed, skip
.PEA7
8EA7 60        RTS              ;else return C=0, catalogue pointer in Y
.PEA8                           ;Print volume spec in A (assuming DD)
8EA8 2C A7 8E  BIT &8EA7        ;set V=1
8EAB 70 11     BVS PEBE         ;always print volume letter B..H after drive
.PEAD                           ;Print " Drive " plus volume spec in A
8EAD 20 D3 A8  JSR R8D3
8EB0 EQUS " Drive "
8EB7 EA        NOP
.PEB8                           ;Print volume spec in A
8EB8 20 0C BE  JSR SE0C         ;test density flag
8EBB 2C ED FD  BIT &FDED
.PEBE
8EBE 08        PHP              ;save density flag on stack
8EBF 48        PHA              ;save volume on stack
8EC0 29 07     AND #&07         ;extract bits 2..0, drive 0..7
8EC2 20 80 A9  JSR R980         ;print hex nibble
8EC5 68        PLA              ;restore volume
8EC6 28        PLP              ;restore density flag
8EC7 50 06     BVC PECF         ;if single density then only print drive no.
8EC9 4A        LSR A            ;else shift volume letter to bits 2..0
8ECA 4A        LSR A
8ECB 4A        LSR A
8ECC 4A        LSR A
8ECD D0 01     BNE PED0         ;if volume letter is not A then print it
.PECF
8ECF 60        RTS              ;else exit
.PED0
8ED0 88        DEY              ;decrement Y (no. spaces to print later)
8ED1 18        CLC              ;add ASCII value of "A"
8ED2 69 41     ADC #&41         ;to produce volume letter B..H
8ED4 4C 51 A9  JMP R951         ;print character in A (OSASCI) and exit
.PED7                           ;Print volume title
8ED7 A0 0B     LDY #&0B         ;set y = &0B print 11 spaces
8ED9 20 DD 8A  JSR PADD         ;print number of spaces in Y
.PEDC
8EDC 20 11 BE  JSR SE11         ;page in catalogue sector 0
8EDF B9 00 FD  LDA &FD00,Y      ;y=0; if Y=0..7 get char from sector 0
8EE2 C0 08     CPY #&08         ;if Y=8..11
8EE4 90 06     BCC PEEC
8EE6 20 16 BE  JSR SE16         ;page in catalogue sector 1
8EE9 B9 F8 FC  LDA &FCF8,Y      ;then get character of title from sector 1
.PEEC
8EEC 20 51 A9  JSR R951         ;print character in A (OSASCI)
8EEF C8        INY              ;loop until 12 characters of title printed
8EF0 C0 0C     CPY #&0C
8EF2 D0 E8     BNE PEDC
8EF4 20 D3 A8  JSR R8D3         ;print " ("
8EF7 EQUB &0D
8EF8 EQUS " ("
8EFA EA        NOP
8EFB 20 16 BE  JSR SE16         ;page in catalogue sector 1
8EFE AD 04 FD  LDA &FD04        ;get BCD catalogue cycle number
8F01 20 78 A9  JSR R978         ;print hex byte
8F04 20 D3 A8  JSR R8D3         ;print ")" +newline
8F07 EQUS ")"
8F08 EQUB &0D
8F09 EA        NOP
8F0A 60        RTS
.PF0B
8F0B 20 0C BE  JSR SE0C         ;page in main workspace
8F0E 20 4C B7  JSR S74C         ;set Z=1 iff current drive is a RAM disc
8F11 F0 66     BEQ PF79         ;if so then print "RAM Disk"
8F13 2C ED FD  BIT &FDED        ;else test density flag
8F16 70 09     BVS PF21         ;if double density print "Double density"
8F18 20 D3 A8  JSR R8D3         ;else print "Single density"
8F1B EQUS "Sing"
8F1F 90 08     BCC PF29
.PF21
8F21 20 D3 A8  JSR R8D3
8F24 EQUS "Doub"
8F28 EA        NOP
.PF29
8F29 20 D3 A8  JSR R8D3
8F2C EQUS "le density"
8F36 EA        NOP
8F37 A0 0E     LDY #&0E         ;set Y = 14 spaces for single density
8F39 2C ED FD  BIT &FDED        ;test density flag
8F3C 50 24     BVC PF62         ;if single density skip list of volumes
8F3E A0 05     LDY #&05         ;else Y = 5 spaces for double density
8F40 20 DD 8A  JSR PADD         ;print number of spaces in Y
8F43 A2 00     LDX #&00         ;set volume index = 0, start at volume A:
.PF45
8F45 18        CLC              ;clear carry for add
8F46 20 07 BE  JSR SE07         ;page in auxiliary workspace
8F49 BD CD FD  LDA &FDCD,X      ;test if number of tracks in volume > 0
8F4C 08        PHP              ;preserve result
8F4D 8A        TXA              ;copy index to A to make volume letter
8F4E 28        PLP              ;restore result
8F4F D0 02     BNE PF53         ;if volume present print its letter
8F51 A9 ED     LDA #&ED         ;else A=&ED + &41 = &2E, ".":
.PF53
8F53 69 41     ADC #&41         ;add ASCII value of "A"
8F55 20 51 A9  JSR R951         ;print character in A (OSASCI)
8F58 E8        INX              ;point to next volume
8F59 E0 08     CPX #&08         ;have all 8 volumes been listed?
8F5B D0 E8     BNE PF45         ;if not then loop
8F5D 20 0C BE  JSR SE0C         ;page in main workspace
8F60 A0 01     LDY #&01         ;else Y=1 space separating volume list:
.PF62
8F62 2C EA FD  BIT &FDEA        ;test double-stepping flag
8F65 10 0F     BPL PF76         ;if set manually (*OPT 8,0/1) then end line
8F67 50 0D     BVC PF76         ;if 1:1 stepping was detected then end line
8F69 20 DD 8A  JSR PADD         ;else print 1 or 14 spaces
8F6C 20 D3 A8  JSR R8D3         ;print "40in80"
8F6F EQUS "40in80"
8F75 EA        NOP
.PF76
8F76 4C 69 84  JMP P469         ;print newline
.PF79                           ;Print "RAM Disk"
8F79 20 17 A9  JSR R917         ;print VDU sequence immediate
8F7C EQUS "RAM Disk"
8F84 EQUB &FF
8F85 4C 69 84  JMP P469         ;print newline
.PF88                           ;Print volume spec and boot option
8F88 A0 0D     LDY #&0D         ;set Y = &0D print 13 spaces
8F8A A5 CF     LDA &CF          ;get current volume
8F8C 20 AD 8E  JSR PEAD         ;print " Drive " plus volume spec in A
8F8F 20 DD 8A  JSR PADD         ;print number of spaces in Y
8F92 20 16 BE  JSR SE16         ;page in catalogue sector 1
8F95 20 D3 A8  JSR R8D3         ;print "Option "
8F98 EQUS "Option "
8F9F AD 06 FD  LDA &FD06        ;get boot option/top bits volume size
8FA2 20 9E A9  JSR R99E         ;shift A right 4 places
8FA5 20 80 A9  JSR R980         ;print hex nibble
8FA8 20 D3 A8  JSR R8D3         ;print " ("
8FAB EQUS " ("
8FAD AA        TAX              ;transfer to X for use as index
8FAE 20 F7 8F  JSR PFF7         ;print boot or Challenger config descriptor
8FB1 20 D3 A8  JSR R8D3         ;print ")"+newline
8FB4 EQUS ")"
8FB5 EQUB &0D
8FB6 EA        NOP
8FB7 60        RTS
.PFB8                           ;Print CSD and library directories
8FB8 20 D3 A8  JSR R8D3         ;print " Directory :"
8FBB EQUS " Directory :"
8FC7 A0 06     LDY #&06         ;6 characters in next field
8FC9 20 0C BE  JSR SE0C         ;page in main workspace
8FCC A2 00     LDX #&00         ;x = 0 point to default (CSD) directory
8FCE 20 E8 8F  JSR PFE8         ;print default or library directory
8FD1 20 DD 8A  JSR PADD         ;print number of spaces in Y
8FD4 20 D3 A8  JSR R8D3         ;print "Library :"
8FD7 EQUS "Library :"
8FE0 A2 02     LDX #&02         ;x = 2 point to library directory
8FE2 20 E8 8F  JSR PFE8         ;print default or library directory
8FE5 4C 69 84  JMP P469         ;print newline
.PFE8                           ;Print default or library directory
8FE8 BD C7 FD  LDA &FDC7,X      ;get default or library volume
8FEB 20 A8 8E  JSR PEA8         ;print volume spec in A (assuming DD)
8FEE 20 4F A9  JSR R94F         ;print a dot
8FF1 BD C6 FD  LDA &FDC6,X      ;get default or library directory
8FF4 4C 51 A9  JMP R951         ;print character in A (OSASCI)
.PFF7                           ;Print boot or Challenger config descriptor
8FF7 BD 07 90  LDA &9007,X      ;look up offset of message selected by X
8FFA AA        TAX              ;replace X with offset of message:
.PFFB
8FFB BD 0E 90  LDA &900E,X      ;get character of message
8FFE F0 06     BEQ Q006         ;if NUL terminator reached then exit
9000 20 51 A9  JSR R951         ;else print character in A (OSASCI)
9003 E8        INX              ;increment offset
9004 10 F5     BPL PFFB         ;and loop (always)
.Q006
9006 60        RTS
;Table of offsets of boot descriptors 0..3
9007 EQUB &00,&04,&09,&0D
;Table of offsets of Challenger configuration descriptors 4..6
900B EQUB &12,&1B,&20
;Table of boot option descriptors 0..3
900E EQUS "off"
9011 EQUB &00
9012 EQUS "LOAD"
9016 EQUB &00
9017 EQUS "RUN"
901A EQUB &00
901B EQUS "EXEC"
901F EQUB &00
;Table of Challenger configuration descriptors 4..6
9020 EQUS "inactive"
9028 EQUB &00
9029 EQUS "256K"
902D EQUB &00
902E EQUS "512K"
9032 EQUB &00
.Q033                           ;Print volume statistics
9033 A0 03     LDY #&03         ;y=3 print <drv> 2 spaces/<drv><vol> 1 space
9035 A5 CF     LDA &CF          ;get current volume
9037 20 AD 8E  JSR PEAD         ;print " Drive " plus volume spec in A
903A 20 DD 8A  JSR PADD         ;print number of spaces in Y
903D 20 D3 A8  JSR R8D3
9040 EQUS "Volume size   "
904E EA        NOP
904F 20 16 BE  JSR SE16         ;page in catalogue sector 1
9052 AD 07 FD  LDA &FD07        ;copy volume size to sector count
9055 85 A8     STA &A8          ;LSB
9057 AD 06 FD  LDA &FD06        ;get boot option/top bits volume size
905A 29 03     AND #&03         ;mask top bits volume size
905C 85 A9     STA &A9          ;store MSB
905E 20 80 B3  JSR S380         ;print sector count as kilobytes
9061 20 69 84  JSR P469         ;print newline
9064 A0 0B     LDY #&0B         ;set Y = &0B print 11 spaces
9066 20 DD 8A  JSR PADD         ;print number of spaces in Y
9069 20 D3 A8  JSR R8D3         ;print "Volume unused"
906C EQUS "Volume unused "
907A EA        NOP
907B 20 16 BE  JSR SE16         ;calculate used space on volume
907E AC 05 FD  LDY &FD05        ;get number of files in catalogue * 8
9081 A9 00     LDA #&00
9083 85 CB     STA &CB          ;clear MSB number of used sectors on volume
9085 20 F8 A4  JSR R4F8         ;return no. reserved sectors in data area
9088 85 CA     STA &CA          ;set LSB number of used sectors on volume
.Q08A
908A 20 B2 A9  JSR R9B2         ;subtract 8 from Y
908D C0 F8     CPY #&F8         ;if Y=&F8 then was 0, first (last) file done
908F F0 09     BEQ Q09A         ;if all files added then continue, else:
9091 20 14 A7  JSR R714         ;calculate number of sectors used by file
9094 20 33 A7  JSR R733         ;add number of sectors to total
9097 4C 8A 90  JMP Q08A         ;loop for next file
.Q09A
909A 20 16 BE  JSR SE16         ;page in catalogue sector 1
909D 38        SEC              ;c=1 for subtract
909E AD 07 FD  LDA &FD07        ;get LSB volume size from catalogue
90A1 E5 CA     SBC &CA          ;subtract LSB used space
90A3 85 A8     STA &A8          ;store LSB result in zero page
90A5 AD 06 FD  LDA &FD06        ;get boot option/top bits volume size
90A8 29 03     AND #&03         ;extract MSB volume size
90AA E5 CB     SBC &CB          ;subtract MSB used space, store in zp
90AC 85 A9     STA &A9
90AE 20 80 B3  JSR S380         ;print sector count as kilobytes
90B1 4C 69 84  JMP P469         ;print newline
;Challenger command table
90B4 EQUS "ACCESS"
90BA EQUW &93,&6E
90BC EQUB &32                   ;syntax &2,&3: <afsp> (L)
90BD EQUS "BACKUP"
90C3 EQUW &85,&69
90C5 EQUB &54                   ;syntax &4,&5: <src drv> <dest drv>
90C6 EQUS "COMPACT"
90CD EQUW &A6,&36
90CF EQUB &0A                   ;syntax &A: (<drv>)
90D0 EQUS "CONFIG"
90D6 EQUW &AA,&F6
90D8 EQUB &0A                   ;syntax &A: (<drv>)
90D9 EQUS "COPY"
90DD EQUW &86,&65
90DF EQUB &64                   ;syntax &4,&6: <src drv> <dest drv> <afsp>
90E0 EQUS "DELETE"
90E6 EQUW &92,&74
90E8 EQUB &01                   ;syntax &1: <fsp>
90E9 EQUS "DESTROY"
90F0 EQUW &92,&83
90F2 EQUB &02                   ;syntax &2: <afsp>
90F3 EQUS "DIR"
90F6 EQUW &93,&13
90F8 EQUB &09                   ;syntax &9: (<dir>)
90F9 EQUS "DRIVE"
90FE EQUW &93,&0A
9100 EQUB &0A                   ;syntax &A: (<drv>)
9101 EQUS "ENABLE"
9107 EQUW &95,&5C
9109 EQUB &00                   ;syntax &0: no arguments
910A EQUS "FDCSTAT"
9111 EQUW &B7,&66
9113 EQUB &80                   ;syntax &0: no arguments        b7=1
9114 EQUS "INFO"
9118 EQUW &8C,&1C
911A EQUB &02                   ;syntax &2: <afsp>
911B EQUS "LIB"
911E EQUW &93,&16
9120 EQUB &09                   ;syntax &9: (<dir>)
9121 EQUS "MAP"
9124 EQUW &8B,&54
9126 EQUB &0A                   ;syntax &A: (<drv>)
9127 EQUS "RENAME"
912D EQUW &95,&C6
912F EQUB &78                   ;syntax &8,&7: <old fsp> <new fsp>
9130 EQUS "STAT"
9134 EQUW &8D,&66
9136 EQUB &0A                   ;syntax &A: (<drv>)
9137 EQUS "TITLE"
913C EQUW &93,&39
913E EQUB &0B                   ;syntax &B: <title>
913F EQUS "WIPE"
9143 EQUW &92,&3F
9145 EQUB &02                   ;syntax &2: <afsp>
9146 EQUW &98,&23               ;unrecognised command, *RUN it  &9823
;Utility command table
9148 EQUS "BUILD"
914D EQUW &84,&15
914F EQUB &01                   ;syntax &1: <fsp>
9150 EQUS "DISC"
9154 EQUW &82,&0E
9156 EQUB &00                   ;syntax &0: no arguments
9157 EQUS "DUMP"
915B EQUW &83,&A4
915D EQUB &01                   ;syntax &1: <fsp>
915E EQUS "FORMAT"
9164 EQUW &AE,&88
9166 EQUB &8A                   ;syntax &A: (<drv>)             b7=1
9167 EQUS "LIST"
916B EQUW &83,&62
916D EQUB &01                   ;syntax &1: <fsp>
916E EQUS "TYPE"
9172 EQUW &83,&5B
9174 EQUB &01                   ;syntax &1: <fsp>
9175 EQUS "VERIFY"
917B EQUW &B0,&7E
917D EQUB &8A                   ;syntax &A: (<drv>)             b7=1
917E EQUS "VOLGEN"
9184 EQUW &B1,&40
9186 EQUB &8A                   ;syntax &A: (<drv>)             b7=1
;entry not printed in *HELP UTILS
9187 EQUS "DISK"
918B EQUW &82,&0E
918D EQUB &00                   ;syntax &0: no arguments
918E EQUW &91,&A7               ;unrecognised utility, return   &91A7
;*HELP keyword table
9190 EQUS "CHAL"
9194 EQUW &A5,&2E
9196 EQUB &00
9197 EQUS "DFS"
919A EQUW &A5,&2E
919C EQUB &00
919D EQUS "UTILS"
91A2 EQUW &A5,&26
91A4 EQUB &00
91A5 EQUW &91,&A7               ;unrecognised keyword, return   &91A7
                                ;Return from unrecognised keyword
91A7 60        RTS
                                ;on entry A=string offset (=Y to GSINIT)
                                ;XY=address of table
.Q1A8                           ;Search for command or keyword in table
91A8 20 1E 92  JSR Q21E         ;set up trampoline to read table at XY
91AB A8        TAY
91AC 20 F2 A9  JSR R9F2         ;call GSINIT with C=0
91AF 98        TYA              ;save offset of start of command line
91B0 48        PHA
91B1 B1 F2     LDA (&F2),Y      ;get first character of command
91B3 29 5F     AND #&5F         ;make uppercase
91B5 C9 43     CMP #&43         ;is it C?
91B7 D0 0B     BNE Q1C4         ;if not then search in table
91B9 C8        INY              ;else skip to next character
91BA B1 F2     LDA (&F2),Y      ;fetch it
91BC C9 20     CMP #&20         ;is it a space?
91BE D0 04     BNE Q1C4         ;if not then search in table
91C0 68        PLA              ;else discard offset of start of command line
91C1 C8        INY              ;skip past the space
91C2 98        TYA              ;save new offset of start of command:
91C3 48        PHA              ;accept *C <command> as alias of *<command>.
.Q1C4
91C4 68        PLA              ;restore offset of start of command line
91C5 A8        TAY
91C6 48        PHA
91C7 A2 00     LDX #&00         ;start at current trampoline address
91C9 20 AA 00  JSR &00AA        ;fetch first byte
91CC 38        SEC              ;if terminator,empty keyword matches anything
91CD 30 3B     BMI Q20A         ;so jump to following action address with C=1
91CF CA        DEX              ;else decrement X and Y to stay in place:
91D0 88        DEY
.Q1D1
91D1 E8        INX              ;advance command line and table offsets
91D2 C8        INY
91D3 20 AA 00  JSR &00AA        ;get byte from table
91D6 30 22     BMI Q1FA         ;if terminator, check command also terminates
91D8 51 F2     EOR (&F2),Y      ;else compare with character of command
91DA 29 5F     AND #&5F         ;make comparison case-insensitive
91DC F0 F3     BEQ Q1D1         ;if equal then compare next characters
91DE B1 F2     LDA (&F2),Y      ;else get mismatching character of command
91E0 C9 2E     CMP #&2E         ;is it a dot?
91E2 08        PHP              ;save the result
.Q1E3
91E3 E8        INX              ;scan keyword in table
91E4 20 AA 00  JSR &00AA
91E7 10 FA     BPL Q1E3         ;loop until terminator reached
91E9 E8        INX              ;skip action address, 2 bytes
91EA E8        INX
91EB 28        PLP              ;is the command an abbreviation or a mismatch?
91EC D0 05     BNE Q1F3         ;if mismatch then skip syntax, scan next kywd
91EE 20 AA 00  JSR &00AA        ;else test syntax byte
91F1 10 13     BPL Q206         ;if b7=0 accept cmd, else abbrev. not allowed:
.Q1F3
91F3 E8        INX              ;skip syntax byte
91F4 20 2D 92  JSR Q22D         ;add X to trampoline address
91F7 4C C4 91  JMP Q1C4         ;scan next keyword
.Q1FA
91FA B1 F2     LDA (&F2),Y      ;get character of command
91FC 20 D1 A9  JSR R9D1         ;set C=0 iff character in A is a letter
91FF B0 08     BCS Q209         ;if C=1 accept command, else longer than kywd
9201 E8        INX              ;so skip action address, 2 bytes
9202 E8        INX
9203 4C F3 91  JMP Q1F3         ;skip syntax byte and scan next keyword
.Q206                           ;Accept abbreviated command
9206 CA        DEX              ;backtrack to action address, 2 bytes
9207 CA        DEX
9208 C8        INY              ;advance command line offset past the dot:
.Q209                           ;Accept command
9209 18        CLC              ;set C=0 command valid
.Q20A
920A 68        PLA              ;discard offset to start of command
920B 20 AA 00  JSR &00AA        ;get action address high byte
920E 85 A9     STA &A9          ;store high byte of vector
9210 E8        INX              ;advance to next byte of table
9211 20 AA 00  JSR &00AA        ;get action address low byte
9214 85 A8     STA &A8          ;store low byte of vector
9216 E8        INX              ;return X=offset of syntax byte
9217 60        RTS              ;y=offset of command line tail.
                                ;unreachable code
9218 48        PHA              ;set up trampoline to write table at XY
9219 A9 9D     LDA #&9D
921B 4C 21 92  JMP Q221
.Q21E                           ;Set up trampoline to read table at XY
921E 48        PHA
921F A9 BD     LDA #&BD         ;&BD = LDA abs,X
.Q221
9221 85 AA     STA &AA          ;instruction at &00AA = LDA xy,X
9223 86 AB     STX &AB
9225 84 AC     STY &AC
9227 A9 60     LDA #&60         ;instruction at &00AD = RTS
9229 85 AD     STA &AD
922B 68        PLA              ;restore A
922C 60        RTS
.Q22D                           ;Add X to trampoline address
922D 18        CLC
922E 8A        TXA
922F 65 AB     ADC &AB          ;add X to low byte of LDA,X address
9231 85 AB     STA &AB
9233 90 02     BCC Q237         ;carry out to high byte
9235 E6 AC     INC &AC
.Q237
9237 60        RTS
.Q238                           ;Set GSINIT pointer to XY, set Y=0
9238 86 F2     STX &F2
923A 84 F3     STY &F3
923C A0 00     LDY #&00
923E 60        RTS
                                ;*WIPE
923F 20 DD 92  JSR Q2DD         ;ensure file matching wildcard argument
.Q242
9242 20 A3 8A  JSR PAA3         ;print filename from catalogue
9245 20 D3 A8  JSR R8D3
9248 EQUS " : "
924B EA        NOP
924C 20 11 BE  JSR SE11         ;page in catalogue sector 0
924F B9 0F FD  LDA &FD0F,Y      ;test lock bit
9252 10 06     BPL Q25A         ;if unlocked then ask to delete
9254 20 4B A9  JSR R94B         ;else deletion not allowed, print letter N
9257 4C 6B 92  JMP Q26B         ;find next matching file
.Q25A
925A 20 DE 84  JSR P4DE         ;ask user yes or no
925D D0 0C     BNE Q26B         ;if user replies no then find next match
925F 20 7E 8A  JSR PA7E         ;else ensure disc not changed
9262 20 78 8C  JSR PC78         ;delete catalogue entry
9265 20 0B 96  JSR Q60B         ;write volume catalogue
9268 20 00 93  JSR Q300         ;shift cat pointer to follow shifted files
.Q26B
926B 20 69 84  JSR P469         ;print newline
926E 20 35 8C  JSR PC35         ;find next matching file
9271 B0 CF     BCS Q242         ;if found then wipe the file
9273 60        RTS              ;else exit
                                ;*DELETE
9274 20 32 8B  JSR PB32         ;disallow wildcard characters in filename
9277 20 E0 92  JSR Q2E0         ;ensure file matching argument
927A 20 9D 8C  JSR PC9D         ;print *INFO line if verbose
927D 20 78 8C  JSR PC78         ;delete catalogue entry
9280 4C 0B 96  JMP Q60B         ;write volume catalogue
                                ;*DESTROY
9283 20 5F A7  JSR R75F         ;ensure *ENABLE active
9286 20 DD 92  JSR Q2DD         ;ensure file matching wildcard argument
.Q289
9289 20 A3 8A  JSR PAA3         ;print filename from catalogue
928C 20 69 84  JSR P469         ;print newline
928F 20 35 8C  JSR PC35         ;find next matching file
9292 B0 F5     BCS Q289         ;loop until all matching files listed
9294 20 D3 A8  JSR R8D3
9297 EQUB &0D
9298 EQUS "Delete (Y/N) ? "
92A7 EA        NOP
92A8 20 DE 84  JSR P4DE         ;ask user yes or no
92AB F0 03     BEQ Q2B0         ;if user replies yes then proceed
92AD 4C 69 84  JMP P469         ;else print newline and exit
.Q2B0
92B0 20 7E 8A  JSR PA7E         ;ensure disc not changed
92B3 20 2E 8C  JSR PC2E         ;search for file in catalogue
.Q2B6
92B6 20 11 BE  JSR SE11         ;page in catalogue sector 0
92B9 B9 0F FD  LDA &FD0F,Y      ;unlock catalogue entry!
92BC 29 7F     AND #&7F
92BE 99 0F FD  STA &FD0F,Y
92C1 20 78 8C  JSR PC78         ;delete catalogue entry
92C4 20 00 93  JSR Q300         ;subtract 8 from catalogue pointer
92C7 20 35 8C  JSR PC35         ;find next matching file
92CA B0 EA     BCS Q2B6
92CC 20 0B 96  JSR Q60B         ;write volume catalogue
92CF 20 D3 A8  JSR R8D3         ;print "Deleted" and exit
92D2 EQUB &0D
92D3 EQUS "Deleted"
92DA EQUB &0D
92DB EA        NOP
92DC 60        RTS
.Q2DD                           ;Ensure file matching wildcard argument
92DD 20 2E 8B  JSR PB2E         ;allow wildcard characters in filename
.Q2E0                           ;Ensure file matching argument
92E0 20 65 A5  JSR R565         ;call GSINIT with C=0 and reject empty arg
92E3 4C 38 8B  JMP PB38         ;ensure file matching spec in catalogue
.Q2E6                           ;Set current file from argument
92E6 20 65 A5  JSR R565         ;call GSINIT with C=0 and reject empty arg
92E9 4C DC 89  JMP P9DC         ;set current file from file spec
.Q2EC                           ;Pack b17,16 of length into catalogue entry
92EC 20 A4 A9  JSR R9A4         ;shift A left 4 places
92EF 20 16 BE  JSR SE16         ;page in catalogue sector 1
92F2 5D 0E FD  EOR &FD0E,X      ;replace b5,b4 of top bits with b5,b4 from A
92F5 29 30     AND #&30
92F7 5D 0E FD  EOR &FD0E,X
92FA 9D 0E FD  STA &FD0E,X      ;store top bits back in catalogue
92FD 4C 0C BE  JMP SE0C         ;page in main workspace
.Q300                           ;Subtract 8 from catalogue pointer
9300 AC C2 FD  LDY &FDC2        ;get catalogue pointer
9303 20 B2 A9  JSR R9B2         ;subtract 8 from Y
9306 8C C2 FD  STY &FDC2        ;store catalogue pointer
9309 60        RTS
                                ;*DRIVE
930A 20 16 AA  JSR RA16         ;parse volume spec from argument
930D A5 CF     LDA &CF          ;get current volume
930F 8D C7 FD  STA &FDC7        ;set as default volume
9312 60        RTS
                                ;*DIR
9313 A2 00     LDX #&00
9315 AD A2 02  LDA &02A2        ;*LIB 903A=LDX #&02
9318 BD C6 FD  LDA &FDC6,X      ;get default/library directory
931B 85 CE     STA &CE          ;set as current directory
931D BD C7 FD  LDA &FDC7,X      ;get default/library volume
9320 85 CF     STA &CF          ;set as current volume
9322 8A        TXA              ;save offset
9323 48        PHA
9324 20 F2 A9  JSR R9F2         ;call GSINIT with C=0
9327 F0 03     BEQ Q32C
9329 20 3E AA  JSR RA3E         ;parse directory spec
.Q32C
932C 68        PLA              ;restore offset
932D AA        TAX
932E A5 CE     LDA &CE          ;get current directory
9330 9D C6 FD  STA &FDC6,X      ;set as default/library directory
9333 A5 CF     LDA &CF          ;get current volume
9335 9D C7 FD  STA &FDC7,X      ;set as default/library volume
9338 60        RTS
                                ;*TITLE
9339 20 65 A5  JSR R565         ;call GSINIT with C=0 and reject empty arg
933C 20 1E AA  JSR RA1E         ;set current vol/dir = default, set up drive
933F 20 2F 96  JSR Q62F         ;load volume catalogue L4
9342 A2 0B     LDX #&0B         ;first offset to store = 11
9344 A9 00     LDA #&00         ;set title to 12 NULs:
.Q346
9346 20 5C 93  JSR Q35C         ;store character of title
9349 CA        DEX              ;loop until 12 characters stored
934A 10 FA     BPL Q346         ;finish with X=&FF
.Q34C
934C 20 C5 FF  JSR &FFC5        ;call GSREAD
934F B0 08     BCS Q359         ;if end of argument write catalogue
9351 E8        INX              ;else point X to next character
9352 20 5C 93  JSR Q35C         ;store character of title
9355 E0 0B     CPX #&0B         ;is this the twelfth character written?
9357 D0 F3     BNE Q34C         ;if not then loop to write more, else:
.Q359
9359 4C 0B 96  JMP Q60B         ;write volume catalogue and exit
.Q35C                           ;Store character of title
935C E0 08     CPX #&08         ;if offset is 8 or more
935E 90 07     BCC Q367
9360 20 16 BE  JSR SE16         ;page in catalogue sector 1
9363 9D F8 FC  STA &FCF8,X      ;then store at &0F00..3, X=8..11
9366 60        RTS
.Q367
9367 20 11 BE  JSR SE11         ;page in catalogue sector 0
936A 9D 00 FD  STA &FD00,X      ;else store at &0E00..7, X=0..7
936D 60        RTS
                                ;*ACCESS
936E 20 2E 8B  JSR PB2E         ;allow wildcard characters in filename
9371 20 E6 92  JSR Q2E6         ;set current file from argument
9374 A2 00     LDX #&00         ;preset X=&00 file unlocked
9376 20 F2 A9  JSR R9F2         ;call GSINIT with C=0
9379 D0 21     BNE Q39C         ;if argument is empty
.Q37B
937B 86 AA     STX &AA          ;then attribute mask = &00, file unlocked
937D 20 41 8B  JSR PB41         ;ensure matching file in catalogue
.Q380
9380 20 AB A2  JSR R2AB         ;ensure file not open (mutex)
9383 20 11 BE  JSR SE11         ;page in catalogue sector 0
9386 B9 0F FD  LDA &FD0F,Y      ;get directory character from catalogue
9389 29 7F     AND #&7F         ;mask off old attribute
938B 05 AA     ORA &AA          ;apply new attribute
938D 99 0F FD  STA &FD0F,Y      ;put back in catalogue
9390 20 9D 8C  JSR PC9D         ;print *INFO line if verbose
9393 20 35 8C  JSR PC35         ;find next matching file
9396 B0 E8     BCS Q380         ;if found then set its attribute
9398 90 BF     BCC Q359         ;else write volume catalogue and exit
.Q39A
939A A2 80     LDX #&80         ;found L, set bit 7 to indicate file locked:
.Q39C
939C 20 C5 FF  JSR &FFC5        ;call GSREAD, get character of attribute
939F B0 DA     BCS Q37B         ;if end of string then set attribute
93A1 C9 4C     CMP #&4C         ;else is character capital L?
93A3 F0 F5     BEQ Q39A         ;if so then set bit 7
93A5 20 9C A8  JSR R89C         ;else raise "Bad attribute" error.
93A8 EQUB &CF
93A9 EQUS "attribute"
93B2 EQUB &00
.Q3B3                           ;Create file from OSFILE block
93B3 20 E2 89  JSR P9E2         ;set current file from argument pointer
93B6 20 2E 8C  JSR PC2E         ;search for file in catalogue
93B9 90 03     BCC Q3BE         ;if found
93BB 20 78 8C  JSR PC78         ;then delete catalogue entry
.Q3BE
93BE A5 C2     LDA &C2          ;save start address low word
93C0 48        PHA
93C1 A5 C3     LDA &C3
93C3 48        PHA
93C4 38        SEC              ;subtract end address - start address
93C5 A5 C4     LDA &C4          ;(24 bits) yielding file length
93C7 E5 C2     SBC &C2
93C9 85 C2     STA &C2
93CB A5 C5     LDA &C5
93CD E5 C3     SBC &C3
93CF 85 C3     STA &C3
93D1 AD BB FD  LDA &FDBB
93D4 ED B9 FD  SBC &FDB9
93D7 85 C6     STA &C6
93D9 20 0B 94  JSR Q40B         ;create catalogue entry
93DC AD BA FD  LDA &FDBA        ;copy start address high word to data pointer
93DF 8D B6 FD  STA &FDB6
93E2 AD B9 FD  LDA &FDB9
93E5 8D B5 FD  STA &FDB5
93E8 68        PLA              ;restore low word to data pointer
93E9 85 BF     STA &BF
93EB 68        PLA
93EC 85 BE     STA &BE
93EE 60        RTS
.Q3EF                           ;Raise "Disk full" error
93EF 20 92 A8  JSR R892
93F2 EQUB &C6                   ;number = &C6, "Disk full", cf. &9EDF
93F3 EQUS "full"
93F7 EQUB &00
.Q3F8                           ;Raise "Catalogue full" error
93F8 20 AD A8  JSR R8AD
93FB EQUB &BE
93FC EQUS "Catalogue full"
940A EQUB &00
.Q40B                           ;Create catalogue entry
940B A9 00     LDA #&00
940D 85 C4     STA &C4          ;set MSB of LBA = 0
940F 20 F8 A4  JSR R4F8         ;return no. reserved sectors in data area
9412 85 C5     STA &C5          ;set as LSB of LBA
9414 20 16 BE  JSR SE16         ;page in catalogue sector 1
9417 AC 05 FD  LDY &FD05        ;get number of files in catalogue * 8
941A C0 F8     CPY #&F8         ;if there are already 31 files
941C B0 DA     BCS Q3F8         ;then raise "Catalogue full" error
941E 90 5F     BCC Q47F         ;else jump into loop
.Q420
9420 24 A8     BIT &A8          ;if b6=0 will not accept shorter allocation
9422 50 CB     BVC Q3EF         ;then raise "Disk full" error
9424 A9 00     LDA #&00
9426 85 C3     STA &C3          ;else zero LSB size of file to be fitted
9428 85 C6     STA &C6          ;and MSB
942A 85 C4     STA &C4          ;set MSB of LBA = 0
942C 20 F8 A4  JSR R4F8         ;return no. reserved sectors in data area
942F 85 C5     STA &C5          ;set as LSB of LBA
9431 20 16 BE  JSR SE16         ;page in catalogue sector 1
9434 AC 05 FD  LDY &FD05        ;get number of files in catalogue * 8
9437 4C 43 94  JMP Q443         ;jump into loop
.Q43A
943A 98        TYA
943B F0 23     BEQ Q460         ;if cat ptr = 0 then test fit
943D 20 B2 A9  JSR R9B2         ;else subtract 8 from Y
9440 20 D6 94  JSR Q4D6         ;calculate LBA of end of file
.Q443
9443 20 07 95  JSR Q507         ;calculate slack space after file
9446 F0 F2     BEQ Q43A         ;if no slack space then test prev cat entry
9448 38        SEC              ;else C=1 for subtraction
9449 20 21 95  JSR Q521         ;test if new file will fit after current file
944C 90 EC     BCC Q43A         ;if file won't fit then test prev cat entry
944E 86 C6     STX &C6          ;else set MSB file size to MSB slack space
9450 A5 B0     LDA &B0          ;get LSB slack space
9452 85 C3     STA &C3          ;set LSB file size
9454 A5 C4     LDA &C4          ;this finds the largest slack space on volume
9456 85 B1     STA &B1          ;save LSB LBA of slack space
9458 A5 C5     LDA &C5
945A 85 B2     STA &B2          ;save MSB LBA of slack space
945C 84 C2     STY &C2          ;save catalogue offset of insertion point
945E B0 DA     BCS Q43A         ;and loop (always)
.Q460
9460 A5 C3     LDA &C3          ;test slack space found
9462 05 C6     ORA &C6          ;if no slack space available
9464 F0 89     BEQ Q3EF         ;then raise "Disk full" error
9466 A5 B1     LDA &B1          ;else get MSB LBA of slack space
9468 85 C4     STA &C4          ;set MSB start LBA of file
946A A5 B2     LDA &B2          ;get LSB LBA of slack space
946C 85 C5     STA &C5          ;set LSB start LBA of file
946E A4 C2     LDY &C2          ;restore catalogue offset of insertion point
9470 A9 00     LDA #&00
9472 85 C2     STA &C2          ;clear LSB length
9474 F0 13     BEQ Q489         ;and branch (always)
.Q476
9476 98        TYA
9477 F0 A7     BEQ Q420         ;if cat ptr = 0 then test fit
9479 20 B2 A9  JSR R9B2         ;else subtract 8 from Y
947C 20 D6 94  JSR Q4D6         ;calculate LBA of end of file
.Q47F
947F 20 07 95  JSR Q507         ;calculate slack space after file
9482 F0 F2     BEQ Q476         ;if no slack space then test prev cat entry
9484 20 1D 95  JSR Q51D         ;test if new file will fit after current file
9487 90 ED     BCC Q476         ;if file won't fit then test prev cat entry
.Q489
9489 84 B0     STY &B0          ;else insert new catalogue entry here
948B 20 16 BE  JSR SE16         ;page in catalogue sector 1
948E AC 05 FD  LDY &FD05        ;point Y to last valid catalogue entry:
.Q491
9491 C4 B0     CPY &B0          ;compare pointer with insertion point
9493 F0 15     BEQ Q4AA         ;stop copying if insertion point reached
9495 20 11 BE  JSR SE11         ;page in catalogue sector 0
9498 B9 07 FD  LDA &FD07,Y      ;else copy current catalogue entry
949B 99 0F FD  STA &FD0F,Y      ;to next slot
949E 20 16 BE  JSR SE16         ;page in catalogue sector 1
94A1 B9 07 FD  LDA &FD07,Y      ;leaving one slot open
94A4 99 0F FD  STA &FD0F,Y      ;for new catalogue entry
94A7 88        DEY              ;decrease pointer to work back from end
94A8 B0 E7     BCS Q491         ;and loop (always)
.Q4AA
94AA 20 0C BE  JSR SE0C         ;page in main workspace
94AD 20 3A 95  JSR Q53A         ;compose top bits exec/length/load/start
94B0 20 29 95  JSR Q529         ;write filename+dir into catalogue at Y=0..&F0
94B3 20 16 BE  JSR SE16         ;page in catalogue sector 1
.Q4B6                           ;Write load/exec/length/start into catalogue
94B6 B5 BD     LDA &BD,X        ;x=8..1 copy from &BE..&C5
94B8 88        DEY              ;y=catalogue pointer + 7..0
94B9 99 08 FD  STA &FD08,Y      ;copy to catalogue address fields
94BC CA        DEX              ;loop until 8 bytes copied
94BD D0 F7     BNE Q4B6
94BF 20 9D 8C  JSR PC9D         ;print *INFO line if verbose
94C2 98        TYA              ;save catalogue pointer
94C3 48        PHA
94C4 20 16 BE  JSR SE16
94C7 AC 05 FD  LDY &FD05        ;get number of files in catalogue * 8
94CA 20 A9 A9  JSR R9A9         ;add 8 to Y
94CD 8C 05 FD  STY &FD05        ;store new file count
94D0 20 0B 96  JSR Q60B         ;write volume catalogue
94D3 68        PLA              ;restore catalogue pointer
94D4 A8        TAY
94D5 60        RTS
.Q4D6                           ;Calculate LBA of end of file
94D6 20 EB 94  JSR Q4EB         ;calculate number of sectors used by file
94D9 18        CLC
94DA B9 0F FD  LDA &FD0F,Y      ;get LSB start sector
94DD 65 C5     ADC &C5          ;add LSB file length in sectors
94DF 85 C5     STA &C5          ;replace with new LSB start sector
94E1 B9 0E FD  LDA &FD0E,Y      ;get top bits exec/length/load/start sector
94E4 29 03     AND #&03         ;extract MSB start sector
94E6 65 C4     ADC &C4          ;add MSB file length in sectors
94E8 85 C4     STA &C4          ;replace with new MSB start sector
94EA 60        RTS
.Q4EB                           ;Calculate number of sectors used by file
94EB 20 16 BE  JSR SE16         ;page in catalogue sector 1
94EE B9 0C FD  LDA &FD0C,Y      ;get LSB length
94F1 C9 01     CMP #&01         ;c=1 iff LSB >0
94F3 B9 0D FD  LDA &FD0D,Y      ;add C to 2MSB length, rounding up
94F6 69 00     ADC #&00         ;(Y points to 8 bytes before file entry)
94F8 85 C5     STA &C5
94FA 08        PHP              ;save carry flag from addition
94FB B9 0E FD  LDA &FD0E,Y      ;get top bits exec/length/load/start sector
94FE 20 96 A9  JSR R996         ;extract length from b5,4 to b1,0
9501 28        PLP              ;restore carry flag
9502 69 00     ADC #&00         ;add C to MSB length, rounding up
9504 85 C4     STA &C4          ;store length in sectors in zero page
9506 60        RTS
.Q507                           ;Calculate slack space after file
9507 20 16 BE  JSR SE16         ;page in catalogue sector 1
950A 38        SEC
950B B9 07 FD  LDA &FD07,Y      ;get LSB LBA of preceding file in catalogue
950E E5 C5     SBC &C5          ;subtract LSB LBA of end of this file
9510 85 B0     STA &B0          ;store LSB size of slack space
9512 B9 06 FD  LDA &FD06,Y      ;get top bits exec/length/load/start sector
9515 29 03     AND #&03         ;extract MSB start sector
9517 E5 C4     SBC &C4          ;subtract MSB LBA of end of this file
9519 AA        TAX              ;return MSB slack size in X, LSB in &B0
951A 05 B0     ORA &B0          ;test result, Z=1 if file follows without gap
951C 60        RTS
.Q51D                           ;Test if new file will fit after current file
951D A9 00     LDA #&00         ;if file includes partial sector
951F C5 C2     CMP &C2          ;then C=1 include it in the comparison:
.Q521                           ;Test if new file will fit after current file
9521 A5 B0     LDA &B0          ;get LSB slack space
9523 E5 C3     SBC &C3          ;subtract LSB file size in sectors
9525 8A        TXA              ;a=MSB slack space
9526 E5 C6     SBC &C6          ;subtract MSB file size in sectors
9528 60        RTS              ;return C=1 if file will fit
.Q529                           ;Write filename+dir into catalogue at Y=0..&F0
9529 20 11 BE  JSR SE11         ;page in catalogue sector 0
952C A2 00     LDX #&00
.Q52E
952E B5 C7     LDA &C7,X        ;get character of current filename+dir
9530 99 08 FD  STA &FD08,Y      ;store in catalogue
9533 C8        INY              ;increment both offsets
9534 E8        INX
9535 E0 08     CPX #&08         ;loop until 8 bytes copied.
9537 D0 F5     BNE Q52E
9539 60        RTS
.Q53A                           ;Compose top bits exec/length/load/start
953A AD B7 FD  LDA &FDB7        ;get b17,b16 exec address
953D 29 03     AND #&03         ;place in b1,b0 of A, clear b7..b2
953F 0A        ASL A            ;shift A left 2 places
9540 0A        ASL A            ;a = ....ee..
9541 45 C6     EOR &C6          ;place b17,b16 of length in b1,b0
9543 29 FC     AND #&FC         ;keep b7..b2 of A
9545 45 C6     EOR &C6          ;a = ....eell
9547 0A        ASL A            ;shift A left 2 places
9548 0A        ASL A            ;a = ..eell..
9549 4D B5 FD  EOR &FDB5        ;place b17,b16 of load address in b1,b0
954C 29 FC     AND #&FC         ;keep b7..b2 of A
954E 4D B5 FD  EOR &FDB5        ;a = ..eelldd
9551 0A        ASL A            ;shift A left 2 places
9552 0A        ASL A            ;a = eelldd..
9553 45 C4     EOR &C4          ;place b10,b9 of start LBA in b1,b0
9555 29 FC     AND #&FC         ;keep b7..b2 of A
9557 45 C4     EOR &C4          ;a = eellddss
9559 85 C4     STA &C4          ;set top bits exec/length/load/start sector
955B 60        RTS
                                ;*ENABLE
955C 20 F2 A9  JSR R9F2         ;call GSINIT with C=0
955F F0 1C     BEQ Q57D         ;if no argument then enable *commands
9561 A2 00     LDX #&00         ;else X=0 offset into "CAT" string:
.Q563
9563 20 C5 FF  JSR &FFC5        ;call GSREAD
9566 B0 1F     BCS Q587         ;if end of argument then "Bad command"
9568 DD 8A 95  CMP &958A,X      ;else compare char with char of "CAT"
956B D0 1A     BNE Q587         ;if unequal then "Bad command"
956D E8        INX              ;else increment offset
956E E0 03     CPX #&03         ;loop until whole "CAT" string compared
9570 D0 F1     BNE Q563
9572 20 C5 FF  JSR &FFC5        ;call GSREAD
9575 90 10     BCC Q587         ;if argument continues then "Bad command"
9577 A9 80     LDA #&80         ;else *ENABLE CAT
9579 8D F4 FD  STA &FDF4        ;b7=1 emulate Acorn DFS's main memory use
957C 60        RTS
.Q57D                           ;*ENABLE (no argument)
957D A9 80     LDA #&80
957F 85 B9     STA &B9          ;>0 disc operation is interruptible
9581 A9 01     LDA #&01         ;set *ENABLE flag = 1; will be nonnegative
9583 8D DF FD  STA &FDDF        ;(after OSFSC 8) for next *command only.
9586 60        RTS
.Q587
9587 4C 49 98  JMP Q849         ;raise "Bad command" error
958A EQUS "CAT"                 ;CAT keyword for *ENABLE
.Q58D                           ;Expand 18-bit load address to 32-bit
958D 48        PHA
958E A9 00     LDA #&00         ;set MSB of address = &00
9590 48        PHA
9591 A5 C4     LDA &C4          ;get top bits exec/length/load/start sector
9593 20 98 A9  JSR R998         ;extract b3,b2 of A
9596 C9 03     CMP #&03         ;if either bit clear then a Tube address
9598 D0 06     BNE Q5A0         ;so set high word = high word of tube address
959A 68        PLA              ;else discard the high word:
959B 68        PLA
.Q59C                           ;Set high word of OSFILE load address = &FFFF
959C 48        PHA
959D A9 FF     LDA #&FF
959F 48        PHA
.Q5A0                           ;Set high word of OSFILE load address
95A0 20 0C BE  JSR SE0C         ;page in main workspace
95A3 8D B5 FD  STA &FDB5
95A6 68        PLA
95A7 8D B6 FD  STA &FDB6
95AA 68        PLA
95AB 60        RTS
.Q5AC                           ;Expand 18-bit exec address to 32-bit
95AC 20 0C BE  JSR SE0C         ;page in main workspace
95AF A9 00     LDA #&00         ;clear MSB of 32-bit address
95B1 8D B8 FD  STA &FDB8
95B4 A5 C4     LDA &C4          ;get top bits exec/length/load/start sector
95B6 20 94 A9  JSR R994         ;extract b7,b6 of A
95B9 C9 03     CMP #&03         ;if b7,b6 both set
95BB D0 05     BNE Q5C2
95BD A9 FF     LDA #&FF         ;then a host address, set high word = &FFFF
95BF 8D B8 FD  STA &FDB8
.Q5C2
95C2 8D B7 FD  STA &FDB7        ;else set 2MSB parasite address &0..2FFFF
95C5 60        RTS
                                ;*RENAME
95C6 20 32 8B  JSR PB32         ;disallow wildcard characters in filename
95C9 20 E6 92  JSR Q2E6         ;set current file from argument
95CC 20 D9 AA  JSR RAD9         ;map current volume to physical volume
95CF 48        PHA              ;save source volume
95D0 98        TYA              ;save command line offset
95D1 48        PHA
95D2 20 41 8B  JSR PB41         ;ensure matching file in catalogue
95D5 20 A8 A2  JSR R2A8         ;ensure file not locked or open (mutex)
95D8 84 B3     STY &B3          ;save pointer to file entry
95DA 68        PLA              ;restore command line offset
95DB A8        TAY
95DC 20 65 A5  JSR R565         ;call GSINIT with C=0 and reject empty arg
95DF AD C6 FD  LDA &FDC6        ;set current directory = default directory
95E2 85 CE     STA &CE
95E4 20 F2 89  JSR P9F2         ;parse file spec
95E7 68        PLA              ;restore source volume
95E8 8D C0 FD  STA &FDC0        ;save in workspace
95EB 20 D9 AA  JSR RAD9         ;map current volume to physical volume
95EE CD C0 FD  CMP &FDC0        ;compare with source volume
95F1 F0 03     BEQ Q5F6         ;if equal then rename the file
95F3 4C 49 98  JMP Q849         ;else rename across volumes, "Bad command".
.Q5F6
95F6 20 2E 8C  JSR PC2E         ;search for file in catalogue
95F9 90 0B     BCC Q606         ;if not found then update filename+dir
95FB 20 A5 A8  JSR R8A5         ;else raise "File exists" error.
95FE EQUB &C4
95FF EQUS "exists"
9605 EQUB &00
.Q606                           ;Update filename+dir in catalogue
9606 A4 B3     LDY &B3          ;get pointer to file entry
9608 20 29 95  JSR Q529         ;write filename+dir into catalogue:
.Q60B                           ;Write volume catalogue L4
960B 20 16 BE  JSR SE16         ;page in catalogue sector 1
960E 18        CLC              ;add 1 to BCD catalogue cycle number
960F F8        SED
9610 AD 04 FD  LDA &FD04
9613 69 01     ADC #&01
9615 8D 04 FD  STA &FD04
9618 D8        CLD
9619 20 43 97  JSR Q743         ;set xfer call no. = write, claim NMI
961C 4C 35 96  JMP Q635         ;transfer volume catalogue and exit
.Q61F                           ;Ensure current volume catalogue loaded
961F 20 0C BE  JSR SE0C         ;page in main workspace
9622 20 D9 AA  JSR RAD9         ;map current volume to physical volume
9625 CD DC FD  CMP &FDDC        ;compare with volume of loaded catalogue
9628 D0 05     BNE Q62F         ;if unequal then load volume catalogue
962A 20 06 BD  JSR SD06         ;else if motor is on
962D F0 28     BEQ Q657         ;then present cat. and release NMI else:
.Q62F
962F 20 4C A8  JSR R84C         ;save AXY
.Q632                           ;Load volume catalogue L4
9632 20 3A 97  JSR Q73A         ;set xfer call no. = read, claim NMI:
.Q635                           ;Transfer volume catalogue
9635 A9 00     LDA #&00
9637 8D CC FD  STA &FDCC        ;transferring to host, not Tube
963A A9 80     LDA #&80
963C 85 B9     STA &B9          ;>0 disc operation is interruptible
963E AD E9 FD  LDA &FDE9        ;get data transfer call number
9641 09 80     ORA #&80         ;b7=1 data address in JIM space
9643 8D E9 FD  STA &FDE9        ;update data transfer call number
9646 20 B5 AB  JSR RBB5         ;detect disc format/set sector address
9649 20 D9 AA  JSR RAD9         ;map current volume to physical volume
964C 8D DC FD  STA &FDDC        ;set drive and volume of loaded catalogue
964F 20 8B 96  JSR Q68B         ;transfer disc/volume catalogue L3
9652 F0 03     BEQ Q657         ;if zero status release NMI and exit
9654 4C AF BC  JMP SCAF         ;else raise "Disk fault" error.
.Q657                           ;Present catalogue and release NMI
9657 20 0C BE  JSR SE0C         ;page in main workspace
965A 2C F4 FD  BIT &FDF4        ;test b7=*ENABLE CAT
965D 10 1A     BPL Q679         ;if enabled
965F 20 11 BE  JSR SE11         ;page in catalogue sector 0
9662 A2 00     LDX #&00         ;then start at offset 0:
.Q664
9664 BD 00 FD  LDA &FD00,X      ;copy catalogue sector 0
9667 9D 00 0E  STA &0E00,X      ;to main memory page &E, emulating DFS use
966A E8        INX              ;loop until entire sector copied
966B D0 F7     BNE Q664
966D 20 16 BE  JSR SE16         ;page in catalogue sector 1
.Q670
9670 BD 00 FD  LDA &FD00,X      ;copy catalogue sector 1
9673 9D 00 0F  STA &0F00,X      ;to main memory page &F, emulating DFS use
9676 E8        INX              ;loop until entire sector copied
9677 D0 F7     BNE Q670
.Q679
9679 20 0C BE  JSR SE0C         ;page in main workspace
967C 4C 71 AD  JMP RD71         ;release NMI
                                ;unreachable code
967F A9 80     LDA #&80         ;data transfer call &80 = read data to JIM
9681 D0 02     BNE Q685         ;branch (always)
.Q683                           ;Write disc/volume catalogue L3
9683 A9 81     LDA #&81         ;data transfer call &81 = write data from JIM
.Q685                           ;Transfer disc/volume catalogue L3
9685 20 0C BE  JSR SE0C         ;page in main workspace
9688 8D E9 FD  STA &FDE9        ;set data transfer call number
.Q68B                           ;Transfer disc/volume catalogue L3
968B 20 75 A8  JSR R875         ;save XY
968E 20 A5 96  JSR Q6A5         ;set data pointer to &0200
9691 A2 03     LDX #&03         ;set X = &03, three possible attempts:
.Q693
9693 A9 00     LDA #&00         ;512 bytes to transfer
9695 85 A0     STA &A0
9697 A9 02     LDA #&02
9699 85 A1     STA &A1
969B 20 18 BA  JSR SA18         ;transfer data L2
969E F0 04     BEQ Q6A4         ;if zero status then success, return
96A0 CA        DEX              ;else decrement attempts counter
96A1 D0 F0     BNE Q693         ;if not tried 3 times then try again
96A3 CA        DEX              ;else return Z=0, failed
.Q6A4
96A4 60        RTS
.Q6A5                           ;Set data pointer to &0200
96A5 A9 02     LDA #&02         ;this addresses catalogue sector 0 in JIM
96A7 85 A6     STA &A6
96A9 A9 00     LDA #&00
96AB 85 A7     STA &A7
96AD 60        RTS
.Q6AE                           ;Open Tube data transfer channel
96AE 20 0C BE  JSR SE0C         ;page in main workspace
96B1 48        PHA              ;a=Tube service call, save in stack
96B2 A5 BE     LDA &BE          ;reform address at &FDB3..B6 from &BE,F
96B4 8D B3 FD  STA &FDB3
96B7 A5 BF     LDA &BF
96B9 8D B4 FD  STA &FDB4
96BC AD B5 FD  LDA &FDB5        ;and high bytes of address
96BF 2D B6 FD  AND &FDB6        ;a=&FF if address is in the host
96C2 0D CD FD  ORA &FDCD        ;a=&FF if Tube absent (&FDCD=NOT MOS flag!)
96C5 49 FF     EOR #&FF         ;invert; A>0 if transferring over Tube
96C7 8D CC FD  STA &FDCC        ;store Tube flag
96CA 38        SEC
96CB F0 0D     BEQ Q6DA         ;if A=0 then no need for Tube, exit C=1
96CD 20 DC 96  JSR Q6DC         ;else claim Tube
96D0 A2 B3     LDX #&B3         ;point XY at address
96D2 A0 FD     LDY #&FD
96D4 68        PLA              ;restore Tube call number
96D5 48        PHA
96D6 20 06 04  JSR &0406        ;call Tube service
96D9 18        CLC              ;exit C=0 as Tube was called
.Q6DA
96DA 68        PLA              ;preserve Tube call number on exit
96DB 60        RTS
.Q6DC                           ;Claim Tube
96DC 48        PHA
.Q6DD
96DD A9 C1     LDA #&C1         ;tube service call = &C0 + ID for DFS (1)
96DF 20 06 04  JSR &0406        ;call Tube service
96E2 90 F9     BCC Q6DD         ;loop until C=1, indicating claim granted
96E4 68        PLA
96E5 60        RTS
.Q6E6                           ;Release Tube
96E6 48        PHA
96E7 AD CC FD  LDA &FDCC        ;load Tube flag, A>0 if Tube in use
96EA F0 05     BEQ Q6F1         ;if not in use then exit, else:
.Q6EC
96EC A9 81     LDA #&81         ;tube service call = &80 + ID for DFS (1)
96EE 20 06 04  JSR &0406        ;call Tube service
.Q6F1
96F1 68        PLA
96F2 60        RTS
.Q6F3                           ;Release Tube if present
96F3 48        PHA
96F4 A9 EA     LDA #&EA         ;OSBYTE &EA = read Tube presence flag
96F6 20 F2 AD  JSR RDF2         ;call OSBYTE with X=0, Y=&FF
96F9 8A        TXA              ;test X, X=&FF if Tube present
96FA D0 F0     BNE Q6EC         ;if Tube present then release Tube
96FC 68        PLA
96FD 60        RTS
.Q6FE                           ;Write ordinary file L5
96FE 20 3E 97  JSR Q73E         ;prepare to write from user memory
9701 4C 07 97  JMP Q707         ;transfer ordinary file L5
.Q704                           ;Read ordinary file L5
9704 20 35 97  JSR Q735         ;prepare to read to user memory
.Q707                           ;Transfer ordinary file L5
9707 20 ED 8A  JSR PAED         ;prepare ordinary file transfer
970A 4C 19 97  JMP Q719         ;transfer data and release Tube
.Q70D                           ;Read extended file L5
970D 20 35 97  JSR Q735         ;prepare to read to user memory
9710 4C 16 97  JMP Q716         ;transfer extended file L5
.Q713                           ;Write extended file L5
9713 20 3E 97  JSR Q73E         ;prepare to write from user memory
.Q716                           ;Transfer extended file L5
9716 20 E4 8A  JSR PAE4         ;prepare extended file transfer
.Q719
9719 A9 01     LDA #&01         ;a=&01
971B 20 E4 AC  JSR RCE4         ;transfer data and report errors L4
971E 4C E6 96  JMP Q6E6         ;release Tube and exit
.Q721                           ;Write ordinary file from JIM L5
9721 A9 81     LDA #&81         ;data transfer call &81 = write data from JIM
9723 AE A9 80  LDX &80A9        ;9724=LDA #&80
.Q724                           ;Read ordinary file to JIM L5
9724 A9 80     LDX #&80         ;data transfer call &80 = read data to JIM
9726 8D E9 FD  STA &FDE9        ;set data transfer call number
9729 20 88 AD  JSR RD88         ;claim NMI
972C 20 ED 8A  JSR PAED         ;prepare ordinary file transfer
972F 20 E4 AC  JSR RCE4         ;transfer data and report errors L4
9732 4C E6 96  JMP Q6E6         ;release Tube
.Q735                           ;Prepare to read to user memory
9735 A9 01     LDA #&01         ;Tube service 1 = write single bytes to R3
9737 20 AE 96  JSR Q6AE         ;open Tube data transfer channel
.Q73A
973A A9 00     LDA #&00         ;data transfer call &00 = read data
973C F0 0C     BEQ Q74A         ;branch (always)
.Q73E                           ;Prepare to write from user memory
973E A9 00     LDA #&00         ;Tube service 0 = read single bytes from R3
9740 20 AE 96  JSR Q6AE         ;open Tube data transfer channel
.Q743                           ;Set xfer call no. = write, claim NMI
9743 20 BC AD  JSR RDBC         ;test write protect state of current drive
9746 D0 14     BNE Q75C         ;if not then "Disk read only"
9748 A9 01     LDA #&01         ;else data transfer call &01 = write data
.Q74A
974A 20 0C BE  JSR SE0C         ;page in main workspace
974D 8D E9 FD  STA &FDE9        ;set data transfer call number
9750 20 88 AD  JSR RD88         ;claim NMI:
.Q753                           ;Forget catalogue in JIM pages 2..3
9753 20 0C BE  JSR SE0C         ;page in main workspace
9756 A9 FF     LDA #&FF
9758 8D DC FD  STA &FDDC        ;no catalogue in JIM pages 2..3
975B 60        RTS
.Q75C
975C 4C 84 A8  JMP R884         ;raise "Disk read only" error
                                ;OSFSC
975F 20 0C BE  JSR SE0C         ;page in main workspace
9762 C9 0C     CMP #&0C         ;if call outside range 0..11
9764 B0 0E     BCS Q774         ;then exit
9766 86 B5     STX &B5          ;else save X
9768 AA        TAX              ;transfer call number to X as index
9769 BD 21 AE  LDA &AE21,X      ;get action address high byte
976C 48        PHA              ;save on stack
976D BD 15 AE  LDA &AE15,X      ;get action address low byte
9770 48        PHA              ;save on stack
9771 8A        TXA              ;restore call number to A
9772 A6 B5     LDX &B5          ;restore X on entry
.Q774
9774 60        RTS              ;jump to action address
                                ;OSFSC  0 = *OPT
9775 20 4C A8  JSR R84C         ;save AXY
9778 E0 0A     CPX #&0A         ;is option outside range 0..9?
977A B0 0C     BCS Q788         ;if so then raise "Bad option" error
977C 8A        TXA              ;else double option in X for use as offset
977D 0A        ASL A
977E AA        TAX
977F BD F5 97  LDA &97F5,X      ;get action address high byte
9782 48        PHA              ;save it on stack
9783 BD F4 97  LDA &97F4,X      ;get action address low byte
9786 48        PHA              ;save it on stack
9787 60        RTS              ;jump to action address
.Q788                           ;Raise "Bad option" error
9788 20 9C A8  JSR R89C
978B EQUB &CB
978C EQUS "option"
9792 EQUB &00
                                ;*OPT 0 = restore default FS options
                                ;*OPT 1 = set reporting level
9793 A2 FF     LDX #&FF
9795 98        TYA              ;is verbosity level =0?
9796 F0 01     BEQ Q799         ;if so then set flag = &FF
9798 E8        INX              ;else level >0, set flag = 0.
.Q799
9799 8E D9 FD  STX &FDD9
979C 60        RTS
                                ;*OPT 4 set boot option
979D 98        TYA              ;save requested option
979E 48        PHA
979F 20 1E AA  JSR RA1E         ;set current vol/dir = default, set up drive
97A2 20 32 96  JSR Q632         ;load volume catalogue
97A5 68        PLA              ;restore option
97A6 20 A4 A9  JSR R9A4         ;shift A left 4 places
97A9 20 16 BE  JSR SE16         ;page in catalogue sector 1
97AC 4D 06 FD  EOR &FD06        ;xor new option with old
97AF 29 30     AND #&30         ;clear all but option bits 5,4
97B1 4D 06 FD  EOR &FD06        ;b5,4 contain new option, others preserved
97B4 8D 06 FD  STA &FD06        ;store new option in catalogue
97B7 4C 0B 96  JMP Q60B         ;write volume catalogue and exit.
                                ;*OPT 6 = set density
97BA A9 40     LDA #&40         ;preset A=&40 force double density
97BC C0 12     CPY #&12         ;if parameter = 18
97BE F0 0A     BEQ Q7CA         ;then force double density in disc ops
97C0 0A        ASL A            ;else A=&80 automatic density
97C1 C0 00     CPY #&00         ;if parameter = 0
97C3 F0 05     BEQ Q7CA         ;then detect density during FS operations
97C5 0A        ASL A            ;else A=&00 force single density
97C6 C0 0A     CPY #&0A         ;if parameter <> 10
97C8 D0 BE     BNE Q788         ;then raise "Bad option" error, else:
.Q7CA
97CA 8D ED FD  STA &FDED        ;store *OPT 6 density setting
97CD 60        RTS
                                ;*OPT 7 = set stepping rate
97CE C0 04     CPY #&04         ;if parameter outside range 0..3
97D0 B0 B6     BCS Q788         ;then raise "Bad option" error
97D2 98        TYA              ;else 0=slow..3=fast; reverse mapping
97D3 49 03     EOR #&03         ;now in internal format 0=fast..3=slow
97D5 8D F2 FD  STA &FDF2        ;store mask to apply to WD 1770 commands
97D8 60        RTS
                                ;*OPT 8 = set double-stepping
97D9 A9 40     LDA #&40         ;preset A=&40 force double-stepping
97DB C8        INY              ;map &FF,0,1 to 0..2
97DC C0 02     CPY #&02         ;if parameter = 1
97DE F0 08     BEQ Q7E8         ;then force double-stepping
97E0 B0 A6     BCS Q788         ;if not &FF, 0 or 1 then "Bad option"
97E2 0A        ASL A            ;else A=&80 automatic stepping
97E3 C0 01     CPY #&01         ;if parameter = &FF
97E5 90 01     BCC Q7E8         ;then detect stepping during FS operations
97E7 0A        ASL A            ;else A=&00 force 1:1 stepping:
.Q7E8
97E8 8D EA FD  STA &FDEA        ;store *OPT 8 tracks setting
97EB 60        RTS
                                ;*OPT 9 = set save ROM slot no.
97EC C0 10     CPY #&10         ;if parameter not in range &0..F
97EE B0 98     BCS Q788         ;then raise "Bad option" error
97F0 8C EE FD  STY &FDEE        ;else store *OPT 9 saverom during disc ops
97F3 60        RTS
;Table of action addresses for *OPT commands 0..9
97F4 EQUW &92,&97               ;*OPT 0 = restore default FS opts &9793
97F6 EQUW &92,&97               ;*OPT 1 = set reporting level     &9793
97F8 EQUW &87,&97               ;*OPT 2 = (invalid)               &9788
97FA EQUW &87,&97               ;*OPT 3 = (invalid)               &9788
97FC EQUW &9C,&97               ;*OPT 4 = set boot option         &979D
97FE EQUW &87,&97               ;*OPT 5 = (invalid)               &9788
9800 EQUW &B9,&97               ;*OPT 6 = set density             &97BA
9802 EQUW &CD,&97               ;*OPT 7 = set stepping rate       &97CE
9804 EQUW &D8,&97               ;*OPT 8 = set double-stepping     &97D9
9806 EQUW &EB,&97               ;*OPT 9 = set save ROM slot no.   &97EC
                                ;OSFSC  1 = read EOF state
9808 48        PHA              ;save AY
9809 98        TYA
980A 48        PHA
980B 8A        TXA              ;transfer file handle to Y
980C A8        TAY
980D 20 9B 9C  JSR QC9B         ;ensure file handle valid and open
9810 98        TYA              ;a=y = channel workspace pointer
9811 20 9F 9E  JSR QE9F         ;compare PTR - EXT
9814 D0 04     BNE Q81A         ;if PTR <> EXT then return 0
9816 A2 FF     LDX #&FF         ;else return &FF, we are at end of file
9818 D0 02     BNE Q81C
.Q81A
981A A2 00     LDX #&00
.Q81C
981C 68        PLA              ;restore AY and exit
981D A8        TAY
981E 68        PLA
981F 60        RTS
                                ;OSFSC  2/4/11 = */, *RUN, *RUN from library
9820 20 38 92  JSR Q238         ;set GSINIT pointer to XY, set Y=0
                                ;OSFSC 3 with *command not in table
9823 20 8F 98  JSR Q88F         ;copy argument ptr and load to cat address
9826 8C E3 FD  STY &FDE3        ;store offset of start of command line
9829 20 E2 89  JSR P9E2         ;set current file from argument pointer
982C 8C E2 FD  STY &FDE2        ;store offset of command line tail
982F 20 2E 8C  JSR PC2E         ;search for file in catalogue
9832 B0 21     BCS Q855         ;if found then execute command binary
9834 AC E3 FD  LDY &FDE3
9837 AD C8 FD  LDA &FDC8        ;get library directory
983A 85 CE     STA &CE          ;set as current directory
983C AD C9 FD  LDA &FDC9        ;get library drive and volume
983F 85 CF     STA &CF          ;select volume in A
9841 20 E5 89  JSR P9E5         ;parse file spec from argument pointer
9844 20 2E 8C  JSR PC2E         ;search for file in catalogue
9847 B0 0C     BCS Q855         ;if found then execute it
.Q849
9849 20 9C A8  JSR R89C         ;else raise "Bad command" error.
984C EQUB &FE
984D EQUS "command"
9854 EQUB &00
.Q855                           ;Execute command binary
9855 20 F8 A1  JSR R1F8         ;load file into memory
9858 18        CLC
9859 AD E2 FD  LDA &FDE2        ;get offset of command line tail
985C A8        TAY              ;and pass to command in Y (if on host)
985D 65 F2     ADC &F2          ;add it to GSINIT pointer in &F2,3
985F 8D E2 FD  STA &FDE2        ;giving command line tail pointer
9862 A5 F3     LDA &F3          ;save it in &FDE2,3 for OSARGS 1
9864 69 00     ADC #&00
9866 8D E3 FD  STA &FDE3
9869 AD B7 FD  LDA &FDB7        ;and high bytes of address
986C 2D B8 FD  AND &FDB8        ;a=&FF if address is in the host
986F 0D CD FD  ORA &FDCD        ;a=&FF if Tube absent (&FDCD=NOT MOS flag!)
9872 C9 FF     CMP #&FF         ;if host address or Tube absent
9874 F0 16     BEQ Q88C         ;then jump indirect
9876 A5 C0     LDA &C0          ;else copy low word of exec address
9878 8D B5 FD  STA &FDB5        ;over high word of load addr in OSFILE block
987B A5 C1     LDA &C1
987D 8D B6 FD  STA &FDB6
9880 20 DC 96  JSR Q6DC         ;claim Tube
9883 A2 B5     LDX #&B5         ;point XY to 32-bit execution address
9885 A0 FD     LDY #&FD
9887 A9 04     LDA #&04         ;tube service call &04 = *Go
9889 4C 06 04  JMP &0406        ;jump into Tube service
.Q88C                           ;Execute command on host
988C 6C C0 00  JMP (&00C0)
.Q88F                           ;Copy argument ptr and load to cat address
988F A9 FF     LDA #&FF         ;lsb exec address in our OSFILE block = &FF:
9891 85 C0     STA &C0          ;load executable to load address in catalogue
9893 A5 F2     LDA &F2          ;copy GSINIT string pointer to zero page
9895 85 BC     STA &BC          ;= command line pointer
9897 A5 F3     LDA &F3
9899 85 BD     STA &BD
989B 60        RTS
                                ;OSFSC  3 = unrecognised *command
989C 20 38 92  JSR Q238         ;set GSINIT pointer to XY, set Y=0
989F A2 B4     LDX #&B4         ;point XY to command table at &90B4
98A1 A0 90     LDY #&90
98A3 A9 00     LDA #&00         ;command starts at XY with zero offset
98A5 20 A8 91  JSR Q1A8         ;search for command or keyword in table
98A8 BA        TSX
98A9 86 B8     STX &B8          ;save stack pointer to restore on abort
98AB 4C D7 80  JMP P0D7         ;execute command
                                ;OSFSC  5 = *CAT
98AE 20 38 92  JSR Q238         ;set GSINIT pointer to XY, set Y=0
98B1 20 F2 A9  JSR R9F2         ;call GSINIT with C=0
98B4 20 72 AA  JSR RA72         ;select specified or default volume
98B7 8A        TXA              ;test b7 of detected specification type
98B8 10 39     BPL Q8F3         ;if b7=0 then spec specific, *CAT single vol
98BA A9 80     LDA #&80         ;else data transfer call &80 = read to JIM
98BC 8D E9 FD  STA &FDE9
98BF 20 B5 AB  JSR RBB5         ;detect disc format/set sector address
98C2 2C ED FD  BIT &FDED        ;test density flag
98C5 50 2C     BVC Q8F3         ;if double density then *CAT eight volumes:
98C7 20 0B 8F  JSR PF0B         ;print disc type and volume list
98CA A2 00     LDX #&00         ;for each volume letter A..H:
.Q8CC
98CC 20 07 BE  JSR SE07         ;page in auxiliary workspace
98CF BD CD FD  LDA &FDCD,X      ;test if number of tracks in volume > 0
98D2 F0 10     BEQ Q8E4         ;if = 0 then no such volume, skip
98D4 8A        TXA              ;save volume counter
98D5 48        PHA
98D6 20 1F 96  JSR Q61F         ;ensure current volume catalogue loaded
98D9 20 D7 8E  JSR PED7         ;print volume title
98DC 20 88 8F  JSR PF88         ;print volume spec and boot option
98DF 20 CA 8D  JSR PDCA         ;list files in catalogue
98E2 68        PLA              ;restore volume counter
98E3 AA        TAX
.Q8E4
98E4 18        CLC
98E5 A5 CF     LDA &CF          ;get current volume
98E7 69 10     ADC #&10         ;select next volume letter
98E9 85 CF     STA &CF          ;set as current volume
98EB E8        INX              ;increment counter
98EC E0 08     CPX #&08         ;have 8 volumes A..H been listed?
98EE D0 DC     BNE Q8CC         ;if not then loop
98F0 4C 0C BE  JMP SE0C         ;else page in main workspace and exit
.Q8F3                           ;*CAT single volume
98F3 20 1F 96  JSR Q61F         ;ensure current volume catalogue loaded
98F6 20 D7 8E  JSR PED7         ;print volume title
98F9 20 0B 8F  JSR PF0B         ;print disc type and volume list
98FC 20 88 8F  JSR PF88         ;print volume spec and boot option
98FF 20 B8 8F  JSR PFB8         ;print CSD and library directories
9902 4C CA 8D  JMP PDCA         ;list files in catalogue
                                ;OSFSC  6 = new filing system starting up
9905 20 0F 99  JSR Q90F         ;close *SPOOL/*EXEC files
9908 0E 00 FD  ASL &FD00        ;clear b7=0 Challenger not current FS
990B 4E 00 FD  LSR &FD00
990E 60        RTS
.Q90F
990F 20 4C A8  JSR R84C         ;save AXY
9912 A9 77     LDA #&77         ;call OSBYTE &77 = close *SPOOL/*EXEC files
9914 4C F4 FF  JMP &FFF4
                                ;OSFSC  7 = range of valid file handles
9917 A2 11     LDX #&11
9919 A0 15     LDY #&15
991B 60        RTS
                                ;OSFSC  8 = *command has been entered
991C 2C DF FD  BIT &FDDF        ;if *ENABLEd flag b7=0 (i.e. byte = 0 or 1)
991F 30 03     BMI Q924
9921 CE DF FD  DEC &FDDF        ;then enable this command, not the ones after
.Q924
9924 4C 53 97  JMP Q753         ;forget catalogue in JIM pages 2..3
.Q927                           ;Ensure open file still in drive
9927 20 9A AB  JSR RB9A         ;set current vol/dir from open filename
.Q92A                           ;Ensure open file still on current volume
992A 20 0C BE  JSR SE0C
992D A2 07     LDX #&07         ;start at seventh character of leaf name:
.Q92F
992F B9 ED FC  LDA &FCED,Y      ;copy leaf name of file to current leaf name
9932 95 C6     STA &C6,X
9934 88        DEY              ;skip odd bytes containing length and addrs
9935 88        DEY              ;select previous character of leaf name (Y>0)
9936 CA        DEX              ;decrement offset in current leaf name
9937 D0 F6     BNE Q92F         ;loop until 7 characters copied (X=7..1)
9939 20 2E 8C  JSR PC2E         ;search for file in catalogue
993C 90 20     BCC Q95E         ;if file not found then raise "Disk changed"
993E 8C D2 FD  STY &FDD2        ;else save offset in catalogue
9941 20 16 BE  JSR SE16         ;page in catalogue sector 1
9944 B9 0E FD  LDA &FD0E,Y      ;get top bits exec/length/load/start sector
9947 BE 0F FD  LDX &FD0F,Y      ;put LSB start sector in X
994A 20 0C BE  JSR SE0C         ;page in main workspace
994D AC D0 FD  LDY &FDD0        ;put channel workspace pointer in Y
9950 59 EE FC  EOR &FCEE,Y      ;compare start sector with one in workspace
9953 29 03     AND #&03         ;mask off other fields
9955 D0 07     BNE Q95E         ;if not equal then raise "Disk changed" error
9957 8A        TXA              ;else compare low bytes of start sector (LBA)
9958 D9 F0 FC  CMP &FCF0,Y
995B D0 01     BNE Q95E         ;if not equal then raise "Disk changed" error
995D 60        RTS              ;else exit
.Q95E
995E 4C 92 8A  JMP PA92         ;raise "Disk changed" error
                                ;OSFIND
9961 C9 00     CMP #&00
9963 D0 74     BNE Q9D9         ;if A>0 then open a file
9965 20 4C A8  JSR R84C         ;else close a file/all files. save AXY
.Q968
9968 98        TYA              ;if handle = 0
9969 F0 09     BEQ Q974         ;then close all files
996B 48        PHA              ;save handle
996C 20 AF 9C  JSR QCAF         ;else convert to pointer
996F A8        TAY
9970 68        PLA              ;restore handle
9971 4C 88 99  JMP Q988         ;then close file
.Q974                           ;Close all files
9974 20 0F 99  JSR Q90F         ;close *SPOOL/*EXEC files
.Q977
9977 A0 04     LDY #&04         ;5 file handles to close:
.Q979
9979 98        TYA              ;save counter
997A 48        PHA
997B B9 91 9C  LDA &9C91,Y      ;y=0..4. get workspace pointer from table
997E A8        TAY
997F 20 88 99  JSR Q988         ;close file L7
9982 68        PLA              ;restore counter
9983 A8        TAY
9984 88        DEY              ;loop until all files closed.
9985 10 F2     BPL Q979
9987 60        RTS
.Q988                           ;Close file L7
9988 20 0C BE  JSR SE0C         ;page in main workspace
998B 48        PHA
998C 20 74 9C  JSR QC74         ;validate workspace offset
998F B0 46     BCS Q9D7         ;if channel invalid or closed then exit
9991 B9 FC FC  LDA &FCFC,Y      ;else get bit mask corresponding to channel
9994 49 FF     EOR #&FF         ;invert it, bit corresponding to channel =0
9996 2D CE FD  AND &FDCE        ;clear bit of channel open flag byte
9999 8D CE FD  STA &FDCE        ;update flag byte
999C B9 F8 FC  LDA &FCF8,Y      ;get channel flags
999F 29 60     AND #&60         ;if either buffer or EXT changed
99A1 F0 34     BEQ Q9D7
99A3 20 27 99  JSR Q927         ;then ensure open file still in drive
99A6 B9 F8 FC  LDA &FCF8,Y      ;if EXT changed
99A9 29 20     AND #&20
99AB F0 27     BEQ Q9D4
99AD AE D2 FD  LDX &FDD2        ;then set X = catalogue pointer
99B0 B9 F5 FC  LDA &FCF5,Y      ;copy low word of EXT to length in catalogue
99B3 20 16 BE  JSR SE16         ;page in catalogue sector 1
99B6 9D 0C FD  STA &FD0C,X
99B9 20 0C BE  JSR SE0C         ;page in main workspace
99BC B9 F6 FC  LDA &FCF6,Y
99BF 20 16 BE  JSR SE16         ;page in catalogue sector 1
99C2 9D 0D FD  STA &FD0D,X
99C5 20 0C BE  JSR SE0C         ;page in main workspace
99C8 B9 F7 FC  LDA &FCF7,Y      ;get high byte of EXT
99CB 20 EC 92  JSR Q2EC         ;pack b17,16 of length into catalogue entry
99CE 20 0B 96  JSR Q60B         ;write volume catalogue
99D1 AC D0 FD  LDY &FDD0        ;put channel workspace pointer in Y
.Q9D4
99D4 20 42 9D  JSR QD42         ;ensure buffer up-to-date on disc L6
.Q9D7
99D7 68        PLA              ;restore A on entry
99D8 60        RTS
.Q9D9                           ;Open a file
99D9 20 75 A8  JSR R875         ;save XY
99DC 86 BC     STX &BC
99DE 84 BD     STY &BD
99E0 85 B4     STA &B4          ;store file open mode in temporary var.
99E2 24 B4     BIT &B4          ;set N and V from temporary variable
99E4 08        PHP
99E5 20 E2 89  JSR P9E2         ;set current file from argument pointer
99E8 20 F7 9A  JSR QAF7         ;find unused file handle
99EB 90 18     BCC QA05         ;if all file handles in use
99ED 20 AD A8  JSR R8AD         ;then raise "Too many files open" error.
99F0 EQUB &C0
99F1 EQUS "Too many files open"
9A04 EQUB &00
.QA05
9A05 A2 C7     LDX #&C7         ;point XY+A to current filename
9A07 A9 00     LDA #&00
9A09 A8        TAY
9A0A 20 10 9B  JSR QB10         ;compare filename at XY+A with open filenames
9A0D 90 1A     BCC QA29         ;if file not open then continue
.QA0F
9A0F 20 0C BE  JSR SE0C         ;page in main workspace
9A12 B9 ED FC  LDA &FCED,Y      ;else test if the channel is open read-write
9A15 10 04     BPL QA1B         ;if so, reopening is a conflict; raise error
9A17 28        PLP              ;else if reopening a r-o channel read-only
9A18 08        PHP              ;(i.e. channel b7=1, OSFIND call no. b7=0)
9A19 10 09     BPL QA24         ;then this is also safe; continue
.QA1B
9A1B 20 A5 A8  JSR R8A5         ;else reopening a r-o channel r-w is conflict
9A1E EQUB &C2                   ;raise "File open" error.
9A1F EQUS "open"
9A23 EQUB &00
.QA24
9A24 20 2A 9B  JSR QB2A         ;find any other channels open on this file
9A27 B0 E6     BCS QA0F         ;if another channel found then loop
.QA29
9A29 20 32 8B  JSR PB32         ;disallow wildcard characters in filename
9A2C 20 2E 8C  JSR PC2E         ;search for file in catalogue
9A2F B0 1D     BCS QA4E         ;if not found
9A31 A9 00     LDA #&00         ;then preset A=0, no file handle to return
9A33 28        PLP              ;if opening for read or update
9A34 50 01     BVC QA37         ;(i.e. OSFIND call no. b6=1)
9A36 60        RTS              ;then existing file was expected, return A=0
.QA37
9A37 08        PHP
9A38 20 0C BE  JSR SE0C         ;page in main workspace
9A3B A2 07     LDX #&07         ;else opening new file for output.
.QA3D
9A3D 95 BE     STA &BE,X        ;clear load, exec, start and length = 0
9A3F 9D B5 FD  STA &FDB5,X
9A42 CA        DEX
9A43 10 F8     BPL QA3D
9A45 A9 40     LDA #&40         ;initial length = &4000 = 16 KiB
9A47 85 C5     STA &C5
9A49 85 A8     STA &A8          ;b6=1 will accept shorter allocation
9A4B 20 B3 93  JSR Q3B3         ;create file from OSFILE block
.QA4E
9A4E 98        TYA              ;transfer catalogue pointer to X
9A4F AA        TAX
9A50 28        PLP
9A51 08        PHP
9A52 70 03     BVS QA57         ;if opening for output (OSFIND b6=0)
9A54 20 95 A2  JSR R295         ;then ensure file not locked
.QA57
9A57 20 0C BE  JSR SE0C         ;page in main workspace
9A5A A9 08     LDA #&08         ;set counter = 8
9A5C 8D D3 FD  STA &FDD3
9A5F AC D0 FD  LDY &FDD0        ;put channel workspace pointer in Y
.QA62
9A62 20 11 BE  JSR SE11         ;page in catalogue sector 0
9A65 BD 08 FD  LDA &FD08,X      ;copy name and attributes of file
9A68 20 0C BE  JSR SE0C         ;page in main workspace
9A6B 99 E1 FC  STA &FCE1,Y      ;to bottom half of channel workspace
9A6E C8        INY
9A6F 20 16 BE  JSR SE16         ;page in catalogue sector 1
9A72 BD 08 FD  LDA &FD08,X
9A75 20 0C BE  JSR SE0C         ;page in main workspace
9A78 99 E1 FC  STA &FCE1,Y
9A7B C8        INY
9A7C E8        INX
9A7D CE D3 FD  DEC &FDD3        ;loop until 8 byte pairs copied
9A80 D0 E0     BNE QA62
9A82 A2 10     LDX #&10
9A84 A9 00     LDA #&00
.QA86
9A86 99 E1 FC  STA &FCE1,Y      ;clear top half of channel workspace
9A89 C8        INY
9A8A CA        DEX
9A8B D0 F9     BNE QA86
9A8D AC D0 FD  LDY &FDD0        ;put channel workspace pointer in Y
9A90 AD CF FD  LDA &FDCF        ;get bit mask corresponding to channel
9A93 99 FC FC  STA &FCFC,Y      ;store in channel workspace
9A96 0D CE FD  ORA &FDCE        ;set that bit in channel open flags byte
9A99 8D CE FD  STA &FDCE        ;marking this channel open
9A9C B9 EA FC  LDA &FCEA,Y      ;test LSB of file length
9A9F C9 01     CMP #&01         ;set C=1 iff partial sector
9AA1 B9 EC FC  LDA &FCEC,Y      ;copy 2MSB length to allocation
9AA4 69 00     ADC #&00         ;rounding up to whole sector
9AA6 99 FA FC  STA &FCFA,Y
9AA9 B9 EE FC  LDA &FCEE,Y      ;get top bits exec/length/load/start sector
9AAC 09 0F     ORA #&0F         ;mask off load/start sector
9AAE 69 00     ADC #&00         ;carry out to length in bits 5 and 4
9AB0 20 96 A9  JSR R996         ;extract b5,b4 of A
9AB3 99 FB FC  STA &FCFB,Y      ;store MSB allocation
9AB6 28        PLP              ;restore OSFILE call number to N and V
9AB7 50 37     BVC QAF0         ;if opening for output then branch
9AB9 30 08     BMI QAC3         ;if opening for update then branch
9ABB A9 80     LDA #&80         ;else opening for input.
9ABD 19 ED FC  ORA &FCED,Y      ;set b7=1 of seventh char of leaf name
9AC0 99 ED FC  STA &FCED,Y      ;marking channel read-only.
.QAC3
9AC3 B9 EA FC  LDA &FCEA,Y      ;input or update; set EXT = length of file
9AC6 99 F5 FC  STA &FCF5,Y
9AC9 B9 EC FC  LDA &FCEC,Y
9ACC 99 F6 FC  STA &FCF6,Y
9ACF B9 EE FC  LDA &FCEE,Y
9AD2 20 96 A9  JSR R996         ;extract b5,b4 of A
9AD5 99 F7 FC  STA &FCF7,Y
.QAD8
9AD8 A5 CF     LDA &CF          ;get current volume
9ADA 99 00 FD  STA &FD00,Y      ;set as volume of open file
9ADD 20 3F 85  JSR P53F         ;pack drive parameters
9AE0 99 F4 FC  STA &FCF4,Y      ;store in place of buffer page number
9AE3 AD EC FD  LDA &FDEC        ;get first track of current volume
9AE6 99 FF FC  STA &FCFF,Y      ;store in spare byte of channel workspace
9AE9 98        TYA              ;transfer channel workspace pointer to A
9AEA 20 9D A9  JSR R99D         ;shift A right 5 places
9AED 69 10     ADC #&10         ;c=0; add &10 to return file handle &11..15
9AEF 60        RTS
.QAF0                           ;opening for output
9AF0 A9 20     LDA #&20         ;set channel flag b5=1, "EXT changed"
9AF2 99 F8 FC  STA &FCF8,Y      ;to truncate file's initial allocation
9AF5 D0 E1     BNE QAD8         ;branch to return file handle (always)
.QAF7                           ;Find unused file handle
9AF7 AD CE FD  LDA &FDCE        ;get channel open flags
9AFA A2 FB     LDX #&FB         ;test up to 5 channel bits:
.QAFC
9AFC 0A        ASL A            ;shift next channel open flag into carry
9AFD 90 04     BCC QB03         ;if C=0 channel unused, calculate ptr+mask
9AFF E8        INX              ;else loop until 5 channels tested
9B00 30 FA     BMI QAFC
9B02 60        RTS              ;if C=1 all channels in use, none free
.QB03                           ;Calculate workspace pointer and bit mask
9B03 BD 96 9B  LDA &9B96,X      ;get workspace pointer from &9C91..5
9B06 8D D0 FD  STA &FDD0        ;return in workspace pointer variable
9B09 BD 9B 9B  LDA &9B9B,X      ;get channel open bit mask from &9C96..A
9B0C 8D CF FD  STA &FDCF        ;return in bit mask variable.
9B0F 60        RTS
.QB10                           ;Compare filename at XY+A with open filenames
9B10 86 B0     STX &B0          ;save XY as filename pointer
9B12 84 B1     STY &B1
9B14 85 B2     STA &B2          ;save A as offset
9B16 20 0C BE  JSR SE0C         ;page in main workspace
9B19 AD CE FD  LDA &FDCE        ;get channel open flags
9B1C 29 F8     AND #&F8         ;extract flags for channels &11..15
9B1E 85 B5     STA &B5          ;save as shift register
9B20 A2 20     LDX #&20         ;start at channel workspace offset &20:
.QB22
9B22 86 B4     STX &B4
9B24 06 B5     ASL &B5          ;shift next channel open flag into carry
9B26 B0 0C     BCS QB34         ;if C=1 channel open then compare names
9B28 F0 08     BEQ QB32         ;if no more channels open exit C=0, else:
.QB2A                           ;no match
9B2A A5 B4     LDA &B4          ;add &20 to channel workspace pointer
9B2C 18        CLC
9B2D 69 20     ADC #&20
9B2F AA        TAX
9B30 90 F0     BCC QB22         ;and loop to test next channel (always)
.QB32
9B32 18        CLC
9B33 60        RTS
.QB34
9B34 BD 00 FD  LDA &FD00,X      ;get volume of open file
9B37 20 DB AA  JSR RADB         ;map volume in A to physical volume
9B3A 85 B3     STA &B3          ;store in temporary variable
9B3C 20 D9 AA  JSR RAD9         ;map current volume to physical volume
9B3F 45 B3     EOR &B3          ;compare with volume of open file
9B41 D0 E7     BNE QB2A         ;if unequal then no match
9B43 A9 08     LDA #&08         ;else set counter = 8
9B45 85 B3     STA &B3
9B47 A4 B2     LDY &B2          ;put offset in Y:
.QB49
9B49 20 11 BE  JSR SE11         ;page in catalogue sector 0
9B4C B1 B0     LDA (&B0),Y      ;get character of filename to compare
9B4E 20 0C BE  JSR SE0C         ;page in main workspace
9B51 5D E1 FC  EOR &FCE1,X      ;compare with char of open filename
9B54 29 7F     AND #&7F         ;ignore bit 7
9B56 D0 D2     BNE QB2A         ;if unequal then no match
9B58 C8        INY              ;skip to next character of comparand
9B59 E8        INX              ;skip even addresses cont'g file attributes
9B5A E8        INX              ;skip to next character of open filename
9B5B C6 B3     DEC &B3          ;decrement counter
9B5D D0 EA     BNE QB49         ;loop until 7 leaf name chars + dir tested
9B5F A4 B4     LDY &B4          ;then restore channel workspace offset to Y
9B61 60        RTS              ;return C=1 matching filename found.
                                ;OSARGS
9B62 20 0C BE  JSR SE0C         ;page in main workspace
9B65 C0 00     CPY #&00         ;file handle in Y; if Y = 0
9B67 F0 11     BEQ QB7A         ;then perform Y = 0 functions
9B69 20 4C A8  JSR R84C         ;else save AXY
9B6C C9 FF     CMP #&FF         ;if A=&FF
9B6E F0 3C     BEQ QBAC         ;then ensure file up-to-date on disc
9B70 C9 03     CMP #&03         ;else if A>=3
9B72 B0 17     BCS QB8B         ;then return
9B74 4A        LSR A            ;else place bit 0 of A in carry flag
9B75 90 41     BCC QBB8         ;if A=0 or A=2 then return PTR or EXT
9B77 4C D8 9B  JMP QBD8         ;else A=1 set PTR
.QB7A                           ;OSARGS Y=0
9B7A 20 75 A8  JSR R875         ;save XY
9B7D A8        TAY              ;A=call number, transfer to Y
9B7E C8        INY              ;convert &FF,0,1 to 0..2
9B7F C0 03     CPY #&03         ;if call number was &02..&FE
9B81 B0 08     BCS QB8B         ;then return
9B83 B9 30 AE  LDA &AE30,Y      ;else get action address high byte
9B86 48        PHA              ;save on stack
9B87 B9 2D AE  LDA &AE2D,Y      ;get action address low byte
9B8A 48        PHA              ;save on stack
.QB8B
9B8B 60        RTS              ;jump to action address.
                                ;OSARGS A=0, Y=0 return filing system number
9B8C A9 04     LDA #&04         ;a=4 for Disc Filing System
9B8E 60        RTS
                                ;OSARGS A=1, Y=0 read command line tail
9B8F A9 FF     LDA #&FF         ;command line is always in I/O processor
9B91 95 02     STA &02,X        ;so return a host address, &FFFFxxxx
9B93 95 03     STA &03,X
9B95 AD E2 FD  LDA &FDE2        ;copy address of command line arguments
9B98 95 00     STA &00,X        ;from workspace where stored by OSFSC 2..4
9B9A AD E3 FD  LDA &FDE3        ;to user's OSARGS block
9B9D 95 01     STA &01,X
9B9F A9 00     LDA #&00         ;return A=0
9BA1 60        RTS
                                ;OSARGS A=&FF, Y=0
9BA2 AD CE FD  LDA &FDCE        ;Ensure all files up-to-date on disc (flush)
9BA5 48        PHA              ;save channel open flags
9BA6 20 77 99  JSR Q977         ;close all files (returns N=1)
9BA9 4C B3 9B  JMP QBB3         ;branch (always)
.QBAC                           ;OSARGS A=&FF, Y>0 ensure file up-to-date
9BAC AD CE FD  LDA &FDCE        ;Ensure file up-to-date on disc (flush)
9BAF 48        PHA              ;save channel open flags
9BB0 20 68 99  JSR Q968         ;close a file/all files
.QBB3
9BB3 68        PLA              ;restore channel open flags.
9BB4 8D CE FD  STA &FDCE
9BB7 60        RTS
.QBB8                           ;OSARGS A=0/2, Y>0 return PTR/EXT
9BB8 20 4C A8  JSR R84C         ;save AXY
9BBB 20 9B 9C  JSR QC9B         ;ensure file handle valid and open
9BBE 0A        ASL A            ;A=0 or 1, multiply by 4
9BBF 0A        ASL A            ;A=0 offset of PTR, A=4 offset of EXT
9BC0 6D D0 FD  ADC &FDD0        ;add offset to channel workspace pointer
9BC3 A8        TAY              ;transfer to Y as index
9BC4 B9 F1 FC  LDA &FCF1,Y      ;copy PTR or EXT
9BC7 95 00     STA &00,X        ;to 3 LSBs of user's OSARGS block
9BC9 B9 F2 FC  LDA &FCF2,Y
9BCC 95 01     STA &01,X
9BCE B9 F3 FC  LDA &FCF3,Y
9BD1 95 02     STA &02,X
9BD3 A9 00     LDA #&00         ;clear MSB of user's OSARGS block
9BD5 95 03     STA &03,X        ;PTR <= EXT < 16 MiB
9BD7 60        RTS
.QBD8                           ;OSARGS A=1, Y>0 set PTR
9BD8 20 4C A8  JSR R84C         ;save AXY
9BDB 20 9B 9C  JSR QC9B         ;ensure file handle valid and open
9BDE 38        SEC
9BDF B9 FD FC  LDA &FCFD,Y      ;get LSB sector address of buffer
9BE2 F9 F0 FC  SBC &FCF0,Y      ;subtract LSB start sector of file
9BE5 85 B0     STA &B0          ;=offset of buffer from start of file
9BE7 B9 FE FC  LDA &FCFE,Y      ;get MSB sector address of buffer
9BEA F9 EE FC  SBC &FCEE,Y      ;subtract MSB start sector of file
9BED 29 03     AND #&03         ;b7..5 of latter = other top bits, mask off
9BEF D5 02     CMP &02,X        ;compare b1..0 with 2MSB requested PTR
9BF1 D0 06     BNE QBF9         ;if equal
9BF3 A5 B0     LDA &B0          ;then compare LSB buffer offset with request
9BF5 D5 01     CMP &01,X
9BF7 F0 0B     BEQ QC04         ;if requested PTR not within current buffer
.QBF9
9BF9 20 9A AB  JSR RB9A         ;then set current vol/dir from open filename
9BFC 20 3F 9D  JSR QD3F         ;ensure buffer up-to-date on disc L6
9BFF A9 6F     LDA #&6F         ;b7=0 PTR not in buffer, b4=0 EOF warning clr
9C01 20 37 9D  JSR QD37         ;clear channel flag bits
.QC04
9C04 20 B7 9E  JSR QEB7         ;compare EXT - requested PTR
9C07 B0 5B     BCS QC64         ;if EXT >= request then just set PTR
9C09 B5 01     LDA &01,X        ;else compare 3MSB request - 2MSB EXT
9C0B D9 F6 FC  CMP &FCF6,Y
9C0E D0 07     BNE QC17         ;if unequal then extend file
9C10 B5 02     LDA &02,X        ;else compare 2MSB request - MSB EXT
9C12 D9 F7 FC  CMP &FCF7,Y
9C15 F0 31     BEQ QC48         ;if equal then within allocation, set PTR,EXT
.QC17
9C17 18        CLC
9C18 B5 00     LDA &00,X        ;get LSB requested PTR
9C1A 69 FF     ADC #&FF         ;c=1 iff LSB >0
9C1C B5 01     LDA &01,X        ;add C to 3MSB request, rounding up
9C1E 69 00     ADC #&00
9C20 85 C4     STA &C4          ;store LSB requested length in sectors
9C22 B5 02     LDA &02,X        ;carry out to 2MSB request
9C24 69 00     ADC #&00
9C26 85 C5     STA &C5          ;store MSB requested length in sectors
9C28 8A        TXA              ;save OSARGS pointer
9C29 48        PHA
9C2A 20 2A 99  JSR Q92A         ;ensure open file still on current volume
9C2D 20 6E 9E  JSR QE6E         ;calculate maximum available allocation
9C30 38        SEC
9C31 A5 C4     LDA &C4          ;get LSB requested length in sectors
9C33 E5 C0     SBC &C0          ;subtract LSB maximum available allocation
9C35 85 C2     STA &C2          ;save LSB excess
9C37 A5 C5     LDA &C5          ;get MSB requested length in sectors
9C39 E5 C1     SBC &C1          ;subtract MSB maximum available allocation
9C3B 85 C3     STA &C3          ;save MSB excess, C=0 if negative (headroom)
9C3D 90 07     BCC QC46         ;if allocation > request then set PTR
9C3F 05 C2     ORA &C2          ;else test excess
9C41 F0 03     BEQ QC46         ;if allocation = request then set PTR
9C43 20 C7 9E  JSR QEC7         ;else move files
.QC46
9C46 68        PLA              ;restore OSARGS pointer
9C47 AA        TAX
.QC48
9C48 B9 F5 FC  LDA &FCF5,Y      ;set PTR = EXT
9C4B 99 F1 FC  STA &FCF1,Y
9C4E B9 F6 FC  LDA &FCF6,Y
9C51 99 F2 FC  STA &FCF2,Y
9C54 B9 F7 FC  LDA &FCF7,Y
9C57 99 F3 FC  STA &FCF3,Y
.QC5A
9C5A A9 00     LDA #&00         ;a = &00 filler byte
9C5C 20 98 9D  JSR QD98         ;write byte to end of file
9C5F 20 B7 9E  JSR QEB7         ;compare EXT - request
9C62 90 F6     BCC QC5A         ;loop until last byte is just before new PTR
.QC64
9C64 B5 00     LDA &00,X        ;copy requested PTR in user's OSARGS block
9C66 99 F1 FC  STA &FCF1,Y      ;to channel pointer
9C69 B5 01     LDA &01,X
9C6B 99 F2 FC  STA &FCF2,Y
9C6E B5 02     LDA &02,X
9C70 99 F3 FC  STA &FCF3,Y
9C73 60        RTS
.QC74                           ;Validate workspace offset
9C74 48        PHA              ;save A
9C75 98        TYA              ;transfer workspace offset to A
9C76 29 E0     AND #&E0         ;mask bits 7..5, offset = 0..7 * &20
9C78 8D D0 FD  STA &FDD0        ;save channel workspace pointer
9C7B F0 11     BEQ QC8E         ;if offset = 0 (i.e. channel &10) return C=1
9C7D 4A        LSR A            ;else shift right five times, divide by 32
9C7E 4A        LSR A            ;to produce an offset 1..7
9C7F 4A        LSR A            ;corresponding to channels &11..17
9C80 4A        LSR A
9C81 4A        LSR A
9C82 A8        TAY              ;transfer to Y for use as index
9C83 B9 95 9C  LDA &9C95,Y      ;get channel open bit mask from table
9C86 AC D0 FD  LDY &FDD0        ;put channel workspace pointer in Y
9C89 2C CE FD  BIT &FDCE        ;if channel's open bit in flag byte = 0
9C8C D0 01     BNE QC8F
.QC8E
9C8E 38        SEC              ;then return C=1
.QC8F
9C8F 68        PLA              ;else return C=0
9C90 60        RTS
;Table of channel workspace pointers for file handles &11..15
9C91 EQUB &20
9C92 EQUB &40
9C93 EQUB &60
9C94 EQUB &80
9C95 EQUB &A0
;Table of channel open bit masks for file handles &11..15
9C96 EQUB &80
9C97 EQUB &40
9C98 EQUB &20
9C99 EQUB &10
9C9A EQUB &08
.QC9B                           ;Ensure file handle valid and open
9C9B 48        PHA              ;save A on entry, Y = file handle
9C9C 20 AF 9C  JSR QCAF         ;convert file handle to workspace pointer
9C9F 8D D0 FD  STA &FDD0        ;save in temporary location
9CA2 B9 96 9C  LDA &9C96,Y      ;get channel open bit mask from table
9CA5 AC D0 FD  LDY &FDD0        ;put channel workspace pointer in Y
9CA8 2C CE FD  BIT &FDCE        ;if channel's open bit in flag byte = 0
9CAB F0 10     BEQ QCBD         ;then raise "Channel" error
9CAD 68        PLA              ;else restore A
9CAE 60        RTS
.QCAF                           ;Convert file handle to workspace pointer
9CAF 98        TYA
9CB0 C9 16     CMP #&16         ;if file handle is &16 or more
9CB2 B0 09     BCS QCBD         ;then raise "Channel" error
9CB4 E9 10     SBC #&10         ;else C=0; if file handle less than &11
9CB6 90 05     BCC QCBD         ;then raise "Channel" error, else:
9CB8 A8        TAY
9CB9 B9 91 9C  LDA &9C91,Y      ;y=0..4. get workspace pointer from table
9CBC 60        RTS
.QCBD                           ;Raise "Channel" error
9CBD 20 AD A8  JSR R8AD
9CC0 EQUB &DE
9CC1 EQUS "Channel"
9CC8 EQUB &00
.QCC9                           ;Raise "EOF" error
9CC9 20 AD A8  JSR R8AD
9CCC EQUB &DF
9CCD EQUS "EOF"
9CD0 EQUB &00
.QCD1                           ;OSBGET
9CD1 20 0C BE  JSR SE0C         ;page in main workspace
9CD4 8E C4 FD  STX &FDC4
9CD7 8C C5 FD  STY &FDC5
9CDA 20 9B 9C  JSR QC9B         ;ensure file handle valid and open
9CDD 98        TYA
9CDE 20 9F 9E  JSR QE9F         ;compare PTR - EXT
9CE1 D0 11     BNE QCF4         ;if at EOF
9CE3 B9 F8 FC  LDA &FCF8,Y      ;then test EOF warning flag b4
9CE6 29 10     AND #&10
9CE8 D0 DF     BNE QCC9         ;if set then raise "EOF" error
9CEA A9 10     LDA #&10         ;else set EOF warning flag b4=1
9CEC 20 30 9D  JSR QD30         ;set channel flag bits (A = OR mask)
9CEF A9 FE     LDA #&FE         ;return A=&FE, "file end"
9CF1 38        SEC              ;return C=1 indicating end-of-file
9CF2 B0 18     BCS QD0C         ;restore XY and exit
.QCF4
9CF4 B9 F8 FC  LDA &FCF8,Y      ;not at EOF. get channel flags
9CF7 30 0A     BMI QD03         ;if PTR not within current buffer
9CF9 20 9A AB  JSR RB9A         ;then set current vol/dir from open filename
9CFC 20 42 9D  JSR QD42         ;ensure buffer up-to-date on disc L6
9CFF 38        SEC              ;c=1 read buffer from disc
9D00 20 4A 9D  JSR QD4A         ;read/write sector buffer L6 (returns C=0)
.QD03
9D03 20 59 9E  JSR QE59         ;increment PTR and page in channel buffer
9D06 BD 00 FD  LDA &FD00,X      ;get byte from channel buffer at old PTR
9D09 20 0C BE  JSR SE0C         ;page in main workspace
.QD0C
9D0C AE C4 FD  LDX &FDC4        ;restore X and Y on entry
9D0F AC C5 FD  LDY &FDC5
9D12 48        PHA              ;set N and Z according to A
9D13 68        PLA
9D14 60        RTS              ;exit
.QD15                           ;Set buffer sector address from PTR
9D15 18        CLC
9D16 B9 F0 FC  LDA &FCF0,Y      ;get LSB start sector of open file
9D19 79 F2 FC  ADC &FCF2,Y      ;add 2MSB of PTR
9D1C 85 C5     STA &C5          ;store LSB sector address
9D1E 99 FD FC  STA &FCFD,Y      ;store LSB sector address of buffer
9D21 B9 EE FC  LDA &FCEE,Y      ;get top bits exec/length/load/start sector
9D24 29 03     AND #&03         ;extract MSB start sector
9D26 79 F3 FC  ADC &FCF3,Y      ;add MSB of PTR
9D29 85 C4     STA &C4          ;store MSB sector address
9D2B 99 FE FC  STA &FCFE,Y      ;store MSB sector address of buffer
9D2E A9 80     LDA #&80         ;b7=1 buffer contains byte at PTR:
.QD30                           ;Set channel flag bits (A = OR mask)
9D30 19 F8 FC  ORA &FCF8,Y
9D33 D0 05     BNE QD3A         ;store if >0 else fall through harmlessly:
.QD35                           ;Clear buffer-contains-PTR channel flag:
9D35 A9 7F     LDA #&7F
.QD37                           ;Clear channel flag bits (A = AND mask)
9D37 39 F8 FC  AND &FCF8,Y
.QD3A
9D3A 99 F8 FC  STA &FCF8,Y
9D3D 18        CLC
9D3E 60        RTS
.QD3F
9D3F 20 4C A8  JSR R84C         ;save AXY
.QD42                           ;Ensure buffer up-to-date on disc L6
9D42 B9 F8 FC  LDA &FCF8,Y      ;test b6 of channel flag
9D45 29 40     AND #&40
9D47 F0 3D     BEQ QD86         ;if buffer not changed then return
9D49 18        CLC              ;c=0 write buffer to disc:
.QD4A                           ;Read/write sector buffer L6
9D4A 08        PHP
9D4B 20 0C BE  JSR SE0C         ;get channel workspace pointer
9D4E AC D0 FD  LDY &FDD0        ;put channel workspace pointer in Y
9D51 98        TYA              ;and A
9D52 4A        LSR A            ;shift A right 5 places
9D53 4A        LSR A
9D54 4A        LSR A
9D55 4A        LSR A
9D56 4A        LSR A
9D57 69 03     ADC #&03         ;c=0; A=4..8 for handles &11..15
9D59 85 BE     STA &BE          ;set LSB address of buffer in JIM space
9D5B A9 00     LDA #&00
9D5D 85 BF     STA &BF          ;clear MSB buffer address
9D5F 85 C2     STA &C2
9D61 A9 01     LDA #&01         ;256 bytes to transfer
9D63 85 C3     STA &C3
9D65 28        PLP
9D66 B0 15     BCS QD7D         ;if C was 0 on entry then read buffer
9D68 B9 FD FC  LDA &FCFD,Y      ;else copy channel's sector buffer address
9D6B 85 C5     STA &C5          ;to &C5,4 (big-endian)
9D6D B9 FE FC  LDA &FCFE,Y
9D70 85 C4     STA &C4
9D72 20 21 97  JSR Q721         ;write ordinary file from JIM L5
9D75 AC D0 FD  LDY &FDD0        ;put channel workspace pointer in Y
9D78 A9 BF     LDA #&BF         ;b6=0 buffer not changed
9D7A 4C 37 9D  JMP QD37         ;clear channel flag bits and exit
.QD7D                           ;Read channel buffer from disc L6
9D7D 20 15 9D  JSR QD15         ;set buffer sector address from PTR
9D80 20 24 97  JSR Q724         ;read ordinary file to JIM L5
9D83 AC D0 FD  LDY &FDD0        ;put channel workspace pointer in Y
.QD86
9D86 60        RTS
.QD87
9D87 4C 9D A2  JMP R29D         ;raise "File locked" error.
.QD8A                           ;Raise "File read only" error.
9D8A 20 A5 A8  JSR R8A5
9D8D EQUB &C1
9D8E EQUS "read only"
9D97 EQUB &00
.QD98
9D98 20 4C A8  JSR R84C         ;save AXY
9D9B 4C AD 9D  JMP QDAD
.QD9E                           ;OSBPUT
9D9E 20 0C BE  JSR SE0C         ;page in main workspace
9DA1 8D C3 FD  STA &FDC3        ;save AXY on entry
9DA4 8E C4 FD  STX &FDC4
9DA7 8C C5 FD  STY &FDC5
9DAA 20 9B 9C  JSR QC9B         ;ensure file handle valid and open
.QDAD
9DAD 48        PHA              ;save byte to write
9DAE B9 ED FC  LDA &FCED,Y      ;test channel read-only bit
9DB1 30 D7     BMI QD8A         ;if b7=1 then raise "File read only" error
9DB3 B9 EF FC  LDA &FCEF,Y      ;else test file locked bit
9DB6 30 CF     BMI QD87         ;if b7=1 then raise "File locked" error
9DB8 20 9A AB  JSR RB9A         ;else set current vol/dir from open filename
9DBB 98        TYA              ;a=y = channel workspace pointer
9DBC 18        CLC              ;add 4 to point A to allocated length not EXT
9DBD 69 04     ADC #&04
9DBF 20 9F 9E  JSR QE9F         ;compare PTR - allocated length
9DC2 D0 43     BNE QE07         ;if within allocation then write
9DC4 20 2A 99  JSR Q92A         ;else ensure open file still on current volume
.QDC7
9DC7 20 6E 9E  JSR QE6E         ;calculate maximum available allocation
9DCA A5 C1     LDA &C1          ;get MSB maximum available allocation
9DCC D9 FB FC  CMP &FCFB,Y      ;compare MSB length of file per workspace
9DCF D0 14     BNE QDE5         ;if not equal then extend file
9DD1 A5 C0     LDA &C0          ;else restore LSB maximum available allocation
9DD3 D9 FA FC  CMP &FCFA,Y      ;compare 2MSB length of file per workspace
9DD6 D0 1B     BNE QDF3         ;if not equal then extend file
9DD8 A9 01     LDA #&01         ;else excess = 1 sector
9DDA 85 C2     STA &C2
9DDC A9 00     LDA #&00
9DDE 85 C3     STA &C3
9DE0 20 C7 9E  JSR QEC7         ;move files (to yield one sector)
9DE3 90 E2     BCC QDC7         ;and try again
.QDE5
9DE5 18        CLC
9DE6 B9 FB FC  LDA &FCFB,Y      ;increment MSB of file length in workspace
9DE9 69 01     ADC #&01         ;strictly increasing length to n*64 KiB
9DEB 99 FB FC  STA &FCFB,Y
9DEE 20 EC 92  JSR Q2EC         ;pack b17,16 of length into catalogue entry
9DF1 A9 00     LDA #&00         ;set 2MSB file length to 0:
.QDF3
9DF3 99 FA FC  STA &FCFA,Y      ;store 2MSB file length in workspace
9DF6 20 16 BE  JSR SE16         ;page in catalogue sector 1
9DF9 9D 0D FD  STA &FD0D,X      ;store 2MSB file length in catalogue
9DFC A9 00     LDA #&00
9DFE 9D 0C FD  STA &FD0C,X      ;clear LSB file length in catalogue
9E01 20 0B 96  JSR Q60B         ;write volume catalogue
9E04 AC D0 FD  LDY &FDD0        ;put channel workspace pointer in Y
.QE07                           ;write byte to file
9E07 B9 F8 FC  LDA &FCF8,Y      ;test channel flags
9E0A 30 17     BMI QE23         ;if b7=1 buffer-contains-PTR then write byte
9E0C 20 42 9D  JSR QD42         ;else ensure buffer up-to-date on disc L6
9E0F B9 F5 FC  LDA &FCF5,Y      ;does EXT equal a whole number of sectors?
9E12 D0 0B     BNE QE1F         ;if not then read buffer from disc
9E14 98        TYA              ;else a=y = channel workspace pointer
9E15 20 9F 9E  JSR QE9F         ;compare PTR - EXT
9E18 D0 05     BNE QE1F         ;if not at EOF then read buffer from disc
9E1A 20 15 9D  JSR QD15         ;else set buffer sector address from PTR
9E1D D0 04     BNE QE23         ;branch (always)
.QE1F
9E1F 38        SEC              ;c=1 write buffer to disc
9E20 20 4A 9D  JSR QD4A         ;read/write sector buffer L6
.QE23
9E23 20 59 9E  JSR QE59         ;increment PTR and page in channel buffer
9E26 68        PLA              ;restore byte to write
9E27 9D 00 FD  STA &FD00,X      ;put byte in channel buffer at old PTR
9E2A 20 0C BE  JSR SE0C         ;page in main workspace
9E2D A9 40     LDA #&40         ;b6=1, buffer has changed
9E2F 20 30 9D  JSR QD30         ;set channel flag bits (A = OR mask)
9E32 98        TYA              ;a=y = channel workspace pointer
9E33 20 9F 9E  JSR QE9F         ;compare PTR - EXT
9E36 90 17     BCC QE4F         ;if at EOF (i.e. pointer >= EXT)
9E38 A9 20     LDA #&20         ;then b5=1, EXT has changed
9E3A 20 30 9D  JSR QD30         ;set channel flag bits (A = OR mask)
9E3D B9 F1 FC  LDA &FCF1,Y      ;copy EXT = PTR
9E40 99 F5 FC  STA &FCF5,Y
9E43 B9 F2 FC  LDA &FCF2,Y
9E46 99 F6 FC  STA &FCF6,Y
9E49 B9 F3 FC  LDA &FCF3,Y
9E4C 99 F7 FC  STA &FCF7,Y
.QE4F
9E4F AD C3 FD  LDA &FDC3        ;restore AXY on entry
9E52 AE C4 FD  LDX &FDC4
9E55 AC C5 FD  LDY &FDC5
9E58 60        RTS              ;exit
.QE59                           ;Increment PTR and page in channel buffer
9E59 B9 F1 FC  LDA &FCF1,Y      ;get current LSB of PTR to return
9E5C 48        PHA
9E5D 20 8D 9E  JSR QE8D         ;increment PTR
9E60 98        TYA              ;transfer workspace pointer to A
9E61 4A        LSR A            ;shift A right 5 places
9E62 4A        LSR A
9E63 4A        LSR A
9E64 4A        LSR A
9E65 4A        LSR A
9E66 69 03     ADC #&03         ;c=0; A=4..8 for handles &11..15
9E68 20 1D BE  JSR SE1D         ;page in JIM page in A
9E6B 68        PLA
9E6C AA        TAX              ;return old LSB of PTR in X as buffer offset
9E6D 60        RTS
.QE6E                           ;Calculate maximum available allocation
9E6E 20 0C BE  JSR SE0C         ;page in main workspace
9E71 AE D2 FD  LDX &FDD2        ;get offset of file in catalogue
9E74 20 16 BE  JSR SE16         ;page in catalogue sector 1
9E77 38        SEC
9E78 BD 07 FD  LDA &FD07,X      ;get LSB start LBA of previous file in cat
9E7B FD 0F FD  SBC &FD0F,X      ;subtract LSB start LBA of open file
9E7E 85 C0     STA &C0          ;save LSB maximum available allocation
9E80 BD 06 FD  LDA &FD06,X      ;get MSB start LBA of previous file in cat
9E83 FD 0E FD  SBC &FD0E,X      ;subtract MSB start LBA of open file
9E86 29 03     AND #&03         ;extract b1,b0
9E88 85 C1     STA &C1          ;store MSB maximum available allocation
9E8A 4C 0C BE  JMP SE0C         ;page in main workspace
.QE8D                           ;Increment PTR
9E8D 98        TYA              ;transfer channel workspace pointer to X
9E8E AA        TAX
9E8F FE F1 FC  INC &FCF1,X      ;increment LSB of PTR
9E92 D0 22     BNE QEB6         ;if within same sector then return
9E94 FE F2 FC  INC &FCF2,X      ;else sector boundary crossed.
9E97 D0 03     BNE QE9C         ;carry out to high bytes of PTR
9E99 FE F3 FC  INC &FCF3,X
.QE9C
9E9C 4C 35 9D  JMP QD35         ;and clear buffer-contains-PTR channel flag.
.QE9F                           ;Compare PTR - EXT (A=Y), - allocation (A=Y+4)
9E9F AA        TAX              ;return C=1 iff at/past EOF or allocation
9EA0 B9 F3 FC  LDA &FCF3,Y      ;return Z=1 iff at EOF or equal to allocation
9EA3 DD F7 FC  CMP &FCF7,X
9EA6 D0 0E     BNE QEB6
9EA8 B9 F2 FC  LDA &FCF2,Y
9EAB DD F6 FC  CMP &FCF6,X
9EAE D0 06     BNE QEB6
9EB0 B9 F1 FC  LDA &FCF1,Y
9EB3 DD F5 FC  CMP &FCF5,X
.QEB6
9EB6 60        RTS
.QEB7                           ;Compare EXT - OSARGS parameter
9EB7 B9 F5 FC  LDA &FCF5,Y      ;return C=1 iff EXT >= parameter
9EBA D5 00     CMP &00,X
9EBC B9 F6 FC  LDA &FCF6,Y
9EBF F5 01     SBC &01,X
9EC1 B9 F7 FC  LDA &FCF7,Y
9EC4 F5 02     SBC &02,X
9EC6 60        RTS
.QEC7                           ;Move files
9EC7 20 4C A8  JSR R84C         ;save AXY
9ECA 86 A9     STX &A9          ;store catalogue offset of file to extend
9ECC 20 16 BE  JSR SE16         ;page in catalogue sector 1
9ECF AD 05 FD  LDA &FD05        ;get number of files in catalogue * 8
9ED2 85 AA     STA &AA          ;save in zero page
9ED4 20 53 A0  JSR R053         ;push file map on stack
9ED7 BA        TSX              ;x = stack pointer
9ED8 86 B2     STX &B2          ;save pointer to file map
9EDA 20 CE A0  JSR R0CE         ;confirm space available
9EDD B0 09     BCS QEE8         ;if space cannot be made
9EDF 20 92 A8  JSR R892         ;then raise "Disk full" error
9EE2 EQUB &BF                   ;number = &BF, "Can't extend", cf. &93EF
9EE3 EQUS "full"
9EE7 EQUB &00
;Move files with space confirmed available
.QEE8
9EE8 20 C9 A0  JSR R0C9         ;confirm space available after file
9EEB 90 15     BCC QF02         ;if not then shift previous files up
9EED 38        SEC
9EEE A5 CA     LDA &CA          ;else get LSB LBA of end of slack to use
9EF0 E5 C8     SBC &C8          ;subtract LSB headroom
9EF2 85 CA     STA &CA          ;store LSB LBA of new end of block
9EF4 A5 CB     LDA &CB          ;get MSB LBA of end of slack to use
9EF6 E5 C9     SBC &C9          ;subtract MSB headroom
9EF8 85 CB     STA &CB          ;update MSB LBA of new end of block
9EFA A9 00     LDA #&00
9EFC 85 CC     STA &CC          ;do not move previous files
9EFE 85 CD     STA &CD
9F00 F0 0D     BEQ QF0F         ;and branch (always)
;Shifting later files down is insufficient; must shift earlier files up
.QF02
9F02 38        SEC
9F03 A9 00     LDA #&00
9F05 E5 C8     SBC &C8          ;negate LSB negative headroom
9F07 85 CC     STA &CC          ;store LSB excess to move previous files by
9F09 A9 00     LDA #&00
9F0B E5 C9     SBC &C9          ;negate MSB negative headroom
9F0D 85 CD     STA &CD          ;store MSB excess
;Shift files after current file down
.QF0F
9F0F A5 C6     LDA &C6          ;test total slack space after file
9F11 05 C7     ORA &C7
9F13 F0 30     BEQ QF45         ;if none then all space must come from prev
.QF15
9F15 18        CLC
9F16 B9 08 01  LDA &0108,Y      ;get LSB length of file in sectors
9F19 85 C6     STA &C6          ;store at C6
9F1B 79 06 01  ADC &0106,Y      ;add LSB LBA of file
9F1E 85 C8     STA &C8          ;store LSB source LBA
9F20 B9 07 01  LDA &0107,Y      ;get MSB length of file in sectors
9F23 85 C7     STA &C7          ;store at C7
9F25 79 05 01  ADC &0105,Y      ;add MSB LBA of file
9F28 85 C9     STA &C9          ;store MSB source LBA
9F2A 20 9E 9F  JSR QF9E         ;move file data
9F2D AD D0 FD  LDA &FDD0        ;get channel workspace pointer for open file
9F30 85 C3     STA &C3          ;store at C3
9F32 20 F1 9F  JSR QFF1         ;update LBAs in channel workspaces
9F35 A5 CB     LDA &CB          ;get LSB destination LBA after transfer
9F37 99 05 01  STA &0105,Y      ;replace LSB LBA of file
9F3A A5 CA     LDA &CA          ;get MSB destination LBA after transfer
9F3C 99 06 01  STA &0106,Y      ;replace MSB LBA of file
9F3F 20 AD A9  JSR R9AD         ;add 4 to Y
9F42 CA        DEX              ;loop until all files after current moved
9F43 D0 D0     BNE QF15
;Shift files before current file up
.QF45
9F45 A5 CC     LDA &CC          ;get LSB excess to move previous files by
9F47 85 C2     STA &C2          ;replace LSB total excess
9F49 A5 CD     LDA &CD          ;get MSB excess to move previous files by
9F4B 85 C3     STA &C3          ;replace LSB total excess
9F4D 05 C2     ORA &C2          ;test excess to move previous files by
9F4F F0 42     BEQ QF93         ;if none then update catalogue and exit
9F51 20 FC A0  JSR R0FC         ;else confirm space available before file
9F54 18        CLC              ;(certain to succeed)
9F55 B9 06 01  LDA &0106,Y      ;get LSB LBA of previous file
9F58 79 08 01  ADC &0108,Y      ;add LSB length of file in sectors
9F5B 85 CA     STA &CA          ;store LSB LBA of end of previous file
9F5D B9 05 01  LDA &0105,Y      ;get MSB LBA of previous file
9F60 79 07 01  ADC &0107,Y      ;add MSB length of file in sectors
9F63 85 CB     STA &CB          ;store MSB LBA of end of previous file:
.QF65
9F65 B9 04 01  LDA &0104,Y      ;get LSB length of current file in sectors
9F68 85 C6     STA &C6          ;store at C6
9F6A B9 03 01  LDA &0103,Y      ;get MSB length of current file in sectors
9F6D 85 C7     STA &C7          ;store at C7
9F6F B9 02 01  LDA &0102,Y      ;get LSB LBA of current file
9F72 85 C8     STA &C8          ;store at C8
9F74 B9 01 01  LDA &0101,Y      ;get MSB LBA of current file
9F77 85 C9     STA &C9          ;store at C9
9F79 A5 CA     LDA &CA          ;get LSB LBA of end of previous file
9F7B 99 02 01  STA &0102,Y      ;replace LSB LBA of file
9F7E A5 CB     LDA &CB          ;get MSB LBA of end of previous file
9F80 99 01 01  STA &0101,Y      ;replace MSB LBA of file
9F83 A9 00     LDA #&00         ;set workspace pointer out of range:
9F85 85 C3     STA &C3          ;update LBAs even of file being extended
9F87 20 F1 9F  JSR QFF1         ;update LBAs in channel workspaces
9F8A 20 1D 89  JSR P91D         ;shift data
9F8D 20 B6 A9  JSR R9B6         ;subtract 4 from Y
9F90 CA        DEX              ;loop until beginning of catalogue reached
9F91 D0 D2     BNE QF65
;Update catalogue and exit
.QF93
9F93 20 32 96  JSR Q632         ;load volume catalogue L4
9F96 20 9A A0  JSR R09A         ;update LBAs in catalogue
9F99 20 0B 96  JSR Q60B         ;write volume catalogue L4
9F9C 18        CLC              ;return C=0 sufficient space was made
9F9D 60        RTS
.QF9E                           ;Move file data
9F9E 20 4C A8  JSR R84C         ;save AXY
9FA1 A9 00     LDA #&00
9FA3 85 BF     STA &BF          ;clear MSB load address in JIM space
9FA5 85 C2     STA &C2          ;clear LSB number of bytes to transfer
.QFA7
9FA7 A4 C6     LDY &C6          ;compare size of file in sectors - &0002
9FA9 C0 02     CPY #&02
9FAB A5 C7     LDA &C7
9FAD E9 00     SBC #&00
9FAF 90 02     BCC QFB3         ;if size of file >= 2 sectors
9FB1 A0 02     LDY #&02         ;then transfer size = 2:
.QFB3
9FB3 84 C3     STY &C3          ;set number of sectors to transfer
9FB5 38        SEC
9FB6 A5 C8     LDA &C8          ;get LSB source LBA
9FB8 E5 C3     SBC &C3          ;subtract transfer size
9FBA 85 C5     STA &C5          ;store LSB of transfer LBA
9FBC 85 C8     STA &C8          ;update LSB source LBA
9FBE A5 C9     LDA &C9          ;get MSB source LBA
9FC0 E9 00     SBC #&00         ;borrow in from transfer size
9FC2 85 C4     STA &C4          ;store MSB transfer LBA
9FC4 85 C9     STA &C9          ;update MSB source LBA
9FC6 A9 02     LDA #&02
9FC8 85 BE     STA &BE          ;set load address in JIM space = &0002
9FCA 20 9C 95  JSR Q59C         ;set high word of OSFILE load address = &FFFF
9FCD 20 24 97  JSR Q724         ;read ordinary file to JIM L5
9FD0 38        SEC
9FD1 A5 CA     LDA &CA          ;get LSB destination LBA
9FD3 E5 C3     SBC &C3          ;subtract transfer size
9FD5 85 C5     STA &C5          ;store LSB of transfer LBA
9FD7 85 CA     STA &CA          ;update LSB destination LBA
9FD9 A5 CB     LDA &CB          ;get MSB destination LBA
9FDB E9 00     SBC #&00         ;borrow in from transfer size
9FDD 85 C4     STA &C4          ;store MSB transfer LBA
9FDF 85 CB     STA &CB          ;update MSB destination LBA
                                ;NB always works upwards and shifts downwards
                                ;sector reads and writes will not overlap
9FE1 A9 02     LDA #&02
9FE3 85 BE     STA &BE          ;set load address in JIM space = &0002
9FE5 20 9C 95  JSR Q59C         ;set high word of OSFILE load address = &FFFF
9FE8 20 21 97  JSR Q721         ;write ordinary file from JIM L5
9FEB 20 B4 89  JSR P9B4         ;subtract transfer size from remainder
9FEE D0 B7     BNE QFA7         ;loop while sectors remaining to transfer
9FF0 60        RTS
.QFF1                           ;Update LBAs in channel workspaces
9FF1 20 4C A8  JSR R84C         ;save AXY
9FF4 A2 00     LDX #&00         ;start at channel &11
9FF6 AD CE FD  LDA &FDCE        ;get channel open flags:
.QFF9
9FF9 0A        ASL A            ;shift next channel open flag into C
9FFA 48        PHA              ;save other flags
9FFB 90 4F     BCC R04C         ;if C=0 channel closed then skip, else:
9FFD BD 91 9C  LDA &9C91,X      ;x=0..4. get workspace pointer from table
A000 A8        TAY
A001 B9 00 FD  LDA &FD00,Y      ;get volume of open file
A004 20 DB AA  JSR RADB         ;map volume in A to physical volume
A007 85 C2     STA &C2
A009 20 D9 AA  JSR RAD9         ;map current volume to physical volume
A00C C5 C2     CMP &C2          ;compare with current volume
A00E D0 3C     BNE R04C         ;if unequal then no match
A010 B9 EE FC  LDA &FCEE,Y      ;get top bits exec/length/load/start sector
A013 29 03     AND #&03         ;extract b1,b0 of A
A015 C5 C9     CMP &C9          ;compare MSB LBA of start of open file
A017 D0 33     BNE R04C         ;with LBA of current file; skip if unequal
A019 B9 F0 FC  LDA &FCF0,Y      ;else get LSB start LBA of open file
A01C C5 C8     CMP &C8          ;compare with LSB LBA of current file
A01E D0 2C     BNE R04C         ;if unequal then skip
A020 C4 C3     CPY &C3          ;else compare wksp pointer with current file
A022 F0 28     BEQ R04C         ;skip if equal (don't move it even if empty)
A024 A5 CA     LDA &CA          ;else get LSB new starting LBA
A026 99 F0 FC  STA &FCF0,Y      ;update LSB start LBA of open file
A029 E5 C8     SBC &C8          ;subtract LSB old starting LBA
A02B 85 C2     STA &C2          ;store LSB difference
A02D A5 CB     LDA &CB          ;get MSB new starting LBA
A02F E5 C9     SBC &C9          ;subtract LSB old starting LBA
A031 48        PHA              ;save MSB difference
A032 B9 EE FC  LDA &FCEE,Y      ;get top bits exec/length/load/start sector
A035 29 FC     AND #&FC         ;mask off MSB start LBA in b1,b0
A037 05 CB     ORA &CB          ;apply MSB new starting LBA
A039 99 EE FC  STA &FCEE,Y      ;update top bits
A03C 18        CLC
A03D A5 C2     LDA &C2          ;get LSB difference in LBAs
A03F 79 FD FC  ADC &FCFD,Y      ;add LSB LBA of sector in buffer
A042 99 FD FC  STA &FCFD,Y      ;update LSB LBA of sector in buffer
A045 68        PLA              ;restore MSB difference
A046 79 FE FC  ADC &FCFE,Y      ;add MSB LBA of sector in buffer
A049 99 FE FC  STA &FCFE,Y      ;update LSB LBA of sector in buffer
.R04C
A04C 68        PLA              ;restore channel open flags
A04D E8        INX              ;select next channel
A04E E0 05     CPX #&05         ;loop until channels &11..15 updated
A050 D0 A7     BNE QFF9
A052 60        RTS
.R053                           ;Push file map on stack
A053 68        PLA              ;pop caller's address into pointer
A054 85 AE     STA &AE
A056 68        PLA
A057 85 AF     STA &AF
A059 20 16 BE  JSR SE16         ;page in catalogue sector 1
A05C AC 05 FD  LDY &FD05        ;point Y to last catalogue entry
A05F A9 00     LDA #&00
A061 48        PHA              ;push word &0000
A062 48        PHA
A063 20 F8 A4  JSR R4F8         ;return no. reserved sectors in data area
A066 48        PHA              ;push as big-endian word
A067 A9 00     LDA #&00
A069 48        PHA
A06A 20 16 BE  JSR SE16         ;page in catalogue sector 1
.R06D
A06D B9 04 FD  LDA &FD04,Y      ;get LSB file length
A070 C9 01     CMP #&01         ;c=1 iff LSB >0
A072 B9 05 FD  LDA &FD05,Y      ;add C to 2MSB file length, rounding up
A075 69 00     ADC #&00
A077 48        PHA              ;push LSB length in sectors
A078 08        PHP              ;save carry flag
A079 B9 06 FD  LDA &FD06,Y      ;get top bits exec/length/load/start sector
A07C 20 96 A9  JSR R996         ;extract b5,b4 of A
A07F 28        PLP              ;restore carry flag
A080 69 00     ADC #&00         ;carry out to MSB file length
A082 48        PHA              ;push MSB length in sectors
A083 B9 07 FD  LDA &FD07,Y      ;get LSB start sector
A086 48        PHA              ;push LSB start sector
A087 B9 06 FD  LDA &FD06,Y      ;get top bits exec/length/load/start sector
A08A 29 03     AND #&03         ;extract b1,b0 of A
A08C 48        PHA              ;push MSB start sector
A08D 20 B2 A9  JSR R9B2         ;subtract 8 from Y
A090 C0 F8     CPY #&F8         ;loop until all entries +volume size pushed
A092 D0 D9     BNE R06D
A094 20 0C BE  JSR SE0C         ;page in main workspace
A097 4C 32 A9  JMP R932         ;return to caller
.R09A                           ;Update LBAs in catalogue
A09A 68        PLA              ;pop caller's address into pointer
A09B 85 AE     STA &AE
A09D 68        PLA
A09E 85 AF     STA &AF
A0A0 20 16 BE  JSR SE16         ;page in catalogue sector 1
A0A3 A0 F8     LDY #&F8         ;y = catalogue offset &F8 going to &00:
.R0A5
A0A5 20 A9 A9  JSR R9A9         ;add 8 to Y
A0A8 68        PLA              ;pop MSB LBA end of volume/start of file
A0A9 59 06 FD  EOR &FD06,Y      ;XOR top bits exec/length/load/start sector
A0AC 29 03     AND #&03         ;mask b1,b0 old XOR new
A0AE 59 06 FD  EOR &FD06,Y      ;preserve b7..b2, replace b1,b0
A0B1 99 06 FD  STA &FD06,Y      ;update top bits exec/length/load/start
A0B4 68        PLA              ;pop LSB LBA end of volume/start of file
A0B5 99 07 FD  STA &FD07,Y      ;store LSB LBA end of volume/start of file
A0B8 68        PLA              ;discard undefined/file length
A0B9 68        PLA
A0BA CC 05 FD  CPY &FD05        ;have all files in catalogue been updated?
A0BD D0 E6     BNE R0A5         ;loop until true
A0BF 68        PLA              ;discard LBA of start of data area
A0C0 68        PLA
A0C1 68        PLA              ;discard file map terminator
A0C2 68        PLA
A0C3 20 0C BE  JSR SE0C         ;page in main workspace
A0C6 4C 32 A9  JMP R932         ;return to caller
.R0C9                           ;Confirm space available after file
A0C9 A5 A9     LDA &A9          ;get catalogue offset of file to extend
A0CB 4C D0 A0  JMP R0D0         ;jump into routine
.R0CE                           ;Confirm space available
A0CE A5 AA     LDA &AA          ;get number of files in catalogue * 8
.R0D0
A0D0 4A        LSR A            ;divide by two, =no. four-byte records
A0D1 48        PHA              ;save on stack
A0D2 18        CLC
A0D3 65 B2     ADC &B2          ;add to file map pointer
A0D5 A8        TAY              ;terminator located at &0105..08,Y
A0D6 68        PLA              ;restore A
A0D7 4A        LSR A            ;divide by four, = no. files
A0D8 4A        LSR A
A0D9 85 B0     STA &B0          ;store file count
A0DB E6 B0     INC &B0          ;increment it to include end of volume
A0DD A2 00     LDX #&00
A0DF 86 C6     STX &C6          ;clear total slack space
A0E1 86 C7     STX &C7
A0E3 F0 04     BEQ R0E9         ;jump into loop (always)
.R0E5
A0E5 E8        INX
A0E6 20 B6 A9  JSR R9B6         ;subtract 4 from Y (toward higher LBAs)
.R0E9
A0E9 20 2C A1  JSR R12C         ;calculate LBA of end of previous file
A0EC 20 3E A1  JSR R13E         ;calculate slack space before current file
A0EF 20 52 A1  JSR R152         ;add slack space to total
A0F2 20 60 A1  JSR R160         ;subtract total slack space - excess
A0F5 B0 04     BCS R0FB         ;if slack will absorb excess then return C=1
A0F7 C6 B0     DEC &B0          ;else loop
A0F9 D0 EA     BNE R0E5         ;until all files in map tested
.R0FB
A0FB 60        RTS              ;return C=0 cannot absorb excess
.R0FC                           ;Confirm space available before file
A0FC A5 A9     LDA &A9          ;get catalogue offset of file to extend
A0FE 4A        LSR A            ;divide by two, =no. four-byte records
A0FF 18        CLC
A100 65 B2     ADC &B2          ;add to file map pointer
A102 A8        TAY              ;file's entry located at &0105..08,Y
A103 38        SEC
A104 A5 AA     LDA &AA          ;get number of files in catalogue * 8
A106 E5 A9     SBC &A9          ;subtract offset of file to extend
A108 4A        LSR A            ;divide by 8
A109 4A        LSR A
A10A 4A        LSR A
A10B 85 B0     STA &B0          ;=count of files after file to extend, >=0
A10D E6 B0     INC &B0          ;increment it to include file itself
A10F A2 00     LDX #&00
A111 86 C6     STX &C6          ;clear total slack space
A113 86 C7     STX &C7
.R115
A115 20 AD A9  JSR R9AD         ;add 4 to Y (toward lower LBAs)
A118 E8        INX
A119 20 2C A1  JSR R12C         ;calculate LBA of end of previous file
A11C 20 3E A1  JSR R13E         ;calculate slack space before current file
A11F 20 52 A1  JSR R152         ;add slack space to total
A122 20 60 A1  JSR R160         ;subtract total slack space - excess
A125 B0 04     BCS R12B         ;if slack will absorb excess then return C=1
A127 C6 B0     DEC &B0          ;else loop
A129 D0 EA     BNE R115         ;until all files before subject tested
.R12B
A12B 60        RTS              ;return C=0 cannot absorb excess
.R12C                           ;Calculate LBA of end of previous file
A12C 18        CLC
A12D B9 06 01  LDA &0106,Y      ;get LSB LBA of previous file
A130 79 08 01  ADC &0108,Y      ;add LSB length of file in sectors
A133 85 C4     STA &C4          ;store at C4
A135 B9 05 01  LDA &0105,Y      ;get MSB LBA of previous file
A138 79 07 01  ADC &0107,Y      ;add MSB length of file in sectors
A13B 85 C5     STA &C5          ;store at C5
A13D 60        RTS
.R13E                           ;Calculate slack space before current file
A13E 38        SEC
A13F B9 02 01  LDA &0102,Y      ;get LSB LBA of current file
A142 85 CA     STA &CA          ;store at CA
A144 E5 C4     SBC &C4          ;subtract LSB LBA of end of previous file
A146 85 C4     STA &C4          ;store LSB slack space
A148 B9 01 01  LDA &0101,Y      ;get MSB LBA of current file
A14B 85 CB     STA &CB          ;store at CB
A14D E5 C5     SBC &C5          ;subtract MSB LBA of end of previous file
A14F 85 C5     STA &C5          ;store MSB slack space
A151 60        RTS
.R152                           ;Add slack space to total
A152 18        CLC
A153 A5 C6     LDA &C6          ;get LSB total slack space
A155 65 C4     ADC &C4          ;add LSB slack space before current file
A157 85 C6     STA &C6          ;update LSB total slack space
A159 A5 C7     LDA &C7          ;get MSB total slack space
A15B 65 C5     ADC &C5          ;add MSB slack space before current file
A15D 85 C7     STA &C7          ;update MSB total slack space
A15F 60        RTS
.R160                           ;Subtract total slack space - excess
A160 38        SEC
A161 A5 C6     LDA &C6          ;get LSB total slack space
A163 E5 C2     SBC &C2          ;subtract LSB excess (i.e. space to be made)
A165 85 C8     STA &C8          ;store LSB headroom
A167 A5 C7     LDA &C7          ;get MSB total slack space
A169 E5 C3     SBC &C3          ;subtract MSB excess
A16B 85 C9     STA &C9          ;store MSB headroom
A16D 60        RTS              ;c=1 if slack space will absorb excess
                                ;OSFILE
A16E 20 75 A8  JSR R875         ;save XY
A171 20 0C BE  JSR SE0C         ;page in main workspace
A174 48        PHA              ;push A
A175 20 32 8B  JSR PB32         ;disallow wildcard characters in filename
A178 86 B0     STX &B0          ;set up pointer from XY
A17A 8E E4 FD  STX &FDE4
A17D 84 B1     STY &B1
A17F 8C E5 FD  STY &FDE5
A182 A2 00     LDX #&00
A184 A0 00     LDY #&00
A186 20 D2 89  JSR P9D2         ;copy word at pointer to &BC,D
.R189
A189 20 C2 89  JSR P9C2         ;copy next four dwords to &BE..C5 (low words)
A18C C0 12     CPY #&12         ;&FDB5..C (high words)
A18E D0 F9     BNE R189
A190 68        PLA              ;transfer call number to X
A191 AA        TAX
A192 E8        INX              ;increment for use as index
A193 E0 08     CPX #&08         ;was call number &FF or 0..6?
A195 B0 08     BCS R19F         ;if not then exit
A197 BD 3B AE  LDA &AE3B,X      ;else get action address high byte
A19A 48        PHA              ;save on stack
A19B BD 33 AE  LDA &AE33,X      ;get action address low byte
A19E 48        PHA              ;save on stack
.R19F
A19F 60        RTS              ;jump to action address
                                ;OSFILE   0 = save file
A1A0 A9 00     LDA #&00
A1A2 85 A8     STA &A8          ;b6=0 will not accept shorter allocation
A1A4 20 B3 93  JSR Q3B3         ;create file from OSFILE block
A1A7 20 D1 A2  JSR R2D1         ;set up pointer to user's OSFILE block
A1AA 20 F7 8C  JSR PCF7         ;return catalogue information to OSFILE block
A1AD 4C FE 96  JMP Q6FE         ;write ordinary file L5
                                ;OSFILE   1 = write catalogue information
A1B0 20 90 A2  JSR R290         ;ensure unlocked file exists
A1B3 20 2D A2  JSR R22D         ;set load address from OSFILE block
A1B6 20 4C A2  JSR R24C         ;set exec address from OSFILE block
A1B9 50 16     BVC R1D1         ;branch to set attributes and write (always)
                                ;OSFILE   2 = write load address
A1BB 20 90 A2  JSR R290         ;ensure unlocked file exists
A1BE 20 2D A2  JSR R22D         ;set load address from OSFILE block
A1C1 50 11     BVC R1D4         ;branch to write catalogue (always)
                                ;OSFILE   3 = write execution address
A1C3 20 90 A2  JSR R290         ;ensure unlocked file exists
A1C6 20 4C A2  JSR R24C         ;set exec address from OSFILE block
A1C9 50 09     BVC R1D4         ;branch to write catalogue (always)
                                ;OSFILE   4 = write file attributes
A1CB 20 BD A2  JSR R2BD         ;ensure file exists
A1CE 20 AB A2  JSR R2AB         ;ensure file not open (mutex)
.R1D1
A1D1 20 74 A2  JSR R274         ;set file attributes from OSFILE block
.R1D4
A1D4 20 59 93  JSR Q359         ;write volume catalogue
A1D7 A9 01     LDA #&01         ;return A=1, file found
A1D9 60        RTS
                                ;OSFILE   5 = read catalogue information
A1DA 20 BD A2  JSR R2BD         ;ensure file exists
A1DD 20 F7 8C  JSR PCF7         ;return catalogue information to OSFILE block
A1E0 A9 01     LDA #&01         ;return A=1, file found
A1E2 60        RTS
                                ;OSFILE   6 = delete file
A1E3 20 90 A2  JSR R290         ;ensure unlocked file exists
A1E6 20 F7 8C  JSR PCF7         ;return catalogue information to OSFILE block
A1E9 20 78 8C  JSR PC78         ;delete catalogue entry
A1EC 4C D4 A1  JMP R1D4         ;write volume catalogue, return A=1
                                ;OSFILE &FF = load file
A1EF 20 3E 8B  JSR PB3E         ;ensure file matching argument in catalogue
A1F2 20 D1 A2  JSR R2D1         ;set up pointer to user's OSFILE block
A1F5 20 F7 8C  JSR PCF7         ;return catalogue information to OSFILE block
.R1F8                           ;Load file into memory
A1F8 84 BC     STY &BC
A1FA A2 00     LDX #&00
A1FC A5 C0     LDA &C0          ;test offset 6, LSB exec from OSFILE block
A1FE D0 06     BNE R206         ;if non-zero, use load address in catalogue
A200 C8        INY              ;else skip first two bytes of catalogue entry
A201 C8        INY
A202 A2 02     LDX #&02         ;skip over user-supplied load address in zp
A204 D0 0E     BNE R214         ;branch (always)
.R206
A206 20 16 BE  JSR SE16         ;page in catalogue sector 1
A209 B9 0E FD  LDA &FD0E,Y      ;get top bits exec/length/load/start sector
A20C 85 C4     STA &C4
A20E 20 0C BE  JSR SE0C         ;page in main workspace
A211 20 8D 95  JSR Q58D         ;expand 18-bit load address to 32-bit
.R214
A214 20 16 BE  JSR SE16         ;page in catalogue sector 1
.R217
A217 B9 08 FD  LDA &FD08,Y      ;copy load/exec/length/start from catalogue
A21A 95 BE     STA &BE,X        ;into low words of OSFILE block
A21C C8        INY              ;(our copy, gave user theirs at &A1F5)
A21D E8        INX
A21E E0 08     CPX #&08         ;loop until 8 or 6 bytes copied, 0..7/2..7
A220 D0 F5     BNE R217
A222 20 AC 95  JSR Q5AC         ;expand 18-bit exec address to 32-bit
A225 A4 BC     LDY &BC
A227 20 9D 8C  JSR PC9D         ;print *INFO line if verbose
A22A 4C 04 97  JMP Q704         ;read ordinary file L5 and exit
.R22D                           ;Set load address from OSFILE block
A22D 20 4C A8  JSR R84C         ;save AXY
A230 A0 02     LDY #&02         ;set offset = 2
A232 B1 B0     LDA (&B0),Y      ;get LSB load address from OSFILE block
A234 20 16 BE  JSR SE16
A237 9D 08 FD  STA &FD08,X      ;store in catalogue entry
A23A C8        INY              ;increment offset; Y=3
A23B B1 B0     LDA (&B0),Y      ;get 3MSB load address
A23D 9D 09 FD  STA &FD09,X      ;store in catalogue entry
A240 C8        INY              ;increment offset; Y=4
A241 B1 B0     LDA (&B0),Y      ;get 2MSB load address
A243 0A        ASL A            ;extract b17,b16, place in b3,b2
A244 0A        ASL A
A245 5D 0E FD  EOR &FD0E,X      ;XOR with existing top bits
A248 29 0C     AND #&0C         ;mask b3,b2; A=....XX..
A24A 10 1E     BPL R26A         ;branch to update top bits (always)
.R24C                           ;Set exec address from OSFILE block
A24C 20 4C A8  JSR R84C         ;save AXY
A24F A0 06     LDY #&06         ;set offset = 6
A251 B1 B0     LDA (&B0),Y      ;get LSB exec address from OSFILE block
A253 20 16 BE  JSR SE16         ;page in catalogue sector 1
A256 9D 0A FD  STA &FD0A,X      ;store in catalogue entry
A259 C8        INY              ;increment offset; Y=7
A25A B1 B0     LDA (&B0),Y      ;get 3MSB exec address
A25C 9D 0B FD  STA &FD0B,X      ;store in catalogue entry
A25F C8        INY              ;increment offset; Y=8
A260 B1 B0     LDA (&B0),Y      ;get 2MSB load address
A262 6A        ROR A            ;extract b17,b16, place in b7,b6
A263 6A        ROR A
A264 6A        ROR A
A265 5D 0E FD  EOR &FD0E,X      ;XOR with existing top bits
A268 29 C0     AND #&C0         ;mask b7,b6; A=XX......
.R26A
A26A 5D 0E FD  EOR &FD0E,X      ;XOR old top bits with A; 6 bits old, 2 new
A26D 9D 0E FD  STA &FD0E,X      ;set top bits exec/length/load/start sector
A270 B8        CLV              ;return V=0
A271 4C 0C BE  JMP SE0C         ;page in main workspace
.R274                           ;Set file attributes from OSFILE block
A274 20 4C A8  JSR R84C         ;save AXY
A277 A0 0E     LDY #&0E         ;set Y=14, offset of file attributes
A279 B1 B0     LDA (&B0),Y      ;get LSB of file attributes
A27B 29 0A     AND #&0A         ;test b3=file locked, b1=writing denied
A27D F0 02     BEQ R281         ;if either is set
A27F A9 80     LDA #&80         ;then b7=1 file locked
.R281
A281 20 11 BE  JSR SE11         ;page in catalogue sector 0
A284 5D 0F FD  EOR &FD0F,X      ;else b7=0 file unlocked. get directory char
A287 29 80     AND #&80         ;from catalogue entry
A289 5D 0F FD  EOR &FD0F,X      ;preserve b6..0, replace b7 from A
A28C 9D 0F FD  STA &FD0F,X      ;save directory char with new lock attribute
A28F 60        RTS
.R290                           ;Ensure unlocked file exists
A290 20 C7 A2  JSR R2C7         ;test if file exists
A293 90 2D     BCC R2C2         ;if not then return A=0 from caller, else:
.R295                           ;Ensure file not locked
A295 20 11 BE  JSR SE11         ;page in catalogue sector 0
A298 B9 0F FD  LDA &FD0F,Y      ;if directory character b7=1
A29B 10 29     BPL R2C6
.R29D
A29D 20 A5 A8  JSR R8A5         ;then raise "File locked" error.
A2A0 EQUB &C3
A2A1 EQUS "locked"
A2A7 EQUB &00
.R2A8                           ;Ensure file not locked or open (mutex)
A2A8 20 95 A2  JSR R295         ;ensure file not locked
.R2AB                           ;Ensure file not open (mutex)
A2AB 20 4C A8  JSR R84C         ;save AXY
A2AE 98        TYA              ;save catalogue pointer
A2AF 48        PHA
A2B0 A2 08     LDX #&08         ;point XY to filename in catalogue, &FD08
A2B2 A0 FD     LDY #&FD
A2B4 68        PLA
A2B5 20 10 9B  JSR QB10         ;compare filename at XY+A with open filenames
A2B8 90 0C     BCC R2C6         ;if unequal then return
A2BA 4C 1B 9A  JMP QA1B         ;else raise "File open" error.
.R2BD                           ;Ensure file exists
A2BD 20 C7 A2  JSR R2C7         ;test if file exists
A2C0 B0 04     BCS R2C6         ;if present then return, else:
.R2C2                           ;Return A=0 from caller
A2C2 68        PLA              ;discard return address on stack
A2C3 68        PLA
A2C4 A9 00     LDA #&00         ;return A=0 as if from caller.
.R2C6
A2C6 60        RTS
.R2C7                           ;Test if file exists
A2C7 20 E2 89  JSR P9E2         ;set current file from argument pointer
A2CA 20 2E 8C  JSR PC2E         ;search for file in catalogue
A2CD 90 0C     BCC R2DB         ;if file not found then exit C=0
A2CF 98        TYA              ;else transfer catalogue pointer to X:
A2D0 AA        TAX
.R2D1                           ;Set up pointer to user's OSFILE block
A2D1 AD E4 FD  LDA &FDE4
A2D4 85 B0     STA &B0
A2D6 AD E5 FD  LDA &FDE5
A2D9 85 B1     STA &B1
.R2DB
A2DB 60        RTS
                                ;OSGBPB
A2DC C9 09     CMP #&09
A2DE B0 FB     BCS R2DB         ;if call number >=9 then return
A2E0 20 4C A8  JSR R84C         ;else save AXY
A2E3 20 0C BE  JSR SE0C         ;page in main workspace
A2E6 20 3F A8  JSR R83F         ;have A=0 returned on exit
A2E9 8E BE FD  STX &FDBE        ;save OSGBPB block pointer in workspace
A2EC 8C BF FD  STY &FDBF
A2EF A8        TAY              ;transfer call number to Y for use as index
A2F0 20 F9 A2  JSR R2F9         ;execute OSGBPB call
A2F3 08        PHP
A2F4 20 F3 96  JSR Q6F3         ;release Tube if present
A2F7 28        PLP
A2F8 60        RTS
.R2F9
A2F9 B9 43 AE  LDA &AE43,Y      ;get low byte of action address from table
A2FC 8D E0 FD  STA &FDE0
A2FF B9 4C AE  LDA &AE4C,Y      ;get high byte of action address from table
A302 8D E1 FD  STA &FDE1
A305 B9 55 AE  LDA &AE55,Y      ;get microcode byte from table
A308 4A        LSR A            ;push bit 0 as C
A309 08        PHP
A30A 4A        LSR A            ;push bit 1 as C
A30B 08        PHP
A30C 8D DA FD  STA &FDDA        ;store Tube service call number as bits 0..5
A30F 20 D5 A4  JSR R4D5         ;set up pointer to user's OSGBPB block
A312 A0 0C     LDY #&0C         ;13 bytes to copy, &0C..&00:
.R314
A314 B1 B4     LDA (&B4),Y      ;copy user's OSGBPB block
A316 99 A1 FD  STA &FDA1,Y      ;to workspace
A319 88        DEY              ;loop until 13 bytes copied
A31A 10 F8     BPL R314
A31C AD A4 FD  LDA &FDA4        ;and high bytes of address
A31F 2D A5 FD  AND &FDA5        ;a=&FF if address is in the host
A322 0D CD FD  ORA &FDCD        ;a=&FF if Tube absent (&FDCD=NOT MOS flag!)
A325 18        CLC
A326 69 01     ADC #&01         ;set A=0, C=1 if transferring to/from host
A328 F0 06     BEQ R330         ;if A>0
A32A 20 DC 96  JSR Q6DC         ;then claim Tube
A32D 18        CLC
A32E A9 FF     LDA #&FF         ;and set A=&FF, C=0, transferring to/from Tube
.R330
A330 8D DB FD  STA &FDDB        ;set Tube transfer flag
A333 AD DA FD  LDA &FDDA        ;set A=0 if writing user mem, A=1 if reading
A336 B0 07     BCS R33F         ;if transferring to/from Tube
A338 A2 A2     LDX #&A2         ;then point XY to OSGBPB data address
A33A A0 FD     LDY #&FD
A33C 20 06 04  JSR &0406        ;call Tube service to open Tube data channel
.R33F
A33F 28        PLP              ;set C=microcode b1
A340 B0 04     BCS R346         ;if reading/writing data then transfer it
A342 28        PLP              ;else C=microcode b0 (=0), pop off stack
.R343
A343 6C E0 FD  JMP (&FDE0)      ;and jump to action address.
.R346
A346 A2 03     LDX #&03         ;4 bytes to copy, 3..0:
.R348
A348 BD AA FD  LDA &FDAA,X      ;copy OSGBPB pointer field
A34B 95 B6     STA &B6,X        ;to zero page
A34D CA        DEX
A34E 10 F8     BPL R348
A350 A2 B6     LDX #&B6         ;point X to pointer in zero page
A352 AC A1 FD  LDY &FDA1        ;set Y=channel number
A355 A9 00     LDA #&00         ;set A=0, read PTR not EXT
A357 28        PLP              ;set C=microcode b0
A358 B0 03     BCS R35D         ;if C=0
A35A 20 D8 9B  JSR QBD8         ;then call OSARGS 1,Y set PTR.
.R35D
A35D 20 B8 9B  JSR QBB8         ;call OSARGS 0,Y return PTR
A360 A2 03     LDX #&03         ;4 bytes to copy, 3..0:
.R362
A362 B5 B6     LDA &B6,X        ;copy pointer in zero page
A364 9D AA FD  STA &FDAA,X      ;to OSGBPB pointer field
A367 CA        DEX
A368 10 F8     BPL R362
.R36A
A36A 20 C7 A4  JSR R4C7         ;invert OSGBPB length field
A36D 30 0D     BMI R37C         ;and branch into loop (always)
.R36F
A36F AC A1 FD  LDY &FDA1        ;set Y = channel number
A372 20 43 A3  JSR R343         ;transfer byte / element
A375 B0 0D     BCS R384         ;if attempted read past EOF then finish
A377 A2 09     LDX #&09         ;else set X = &09, point to OSGBPB pointer
A379 20 BB A4  JSR R4BB         ;increment pointer
.R37C
A37C A2 05     LDX #&05         ;set X = &05, point to OSGBPB length field
A37E 20 BB A4  JSR R4BB         ;increment OSGBPB length field (inverted)
A381 D0 EC     BNE R36F         ;if not overflowed to zero then loop
A383 18        CLC              ;else set C = 0, no read past EOF:
.R384
A384 08        PHP
A385 20 C7 A4  JSR R4C7         ;invert OSGBPB length field
A388 A2 05     LDX #&05         ;add one to get two's complement (0 -> 0)
A38A 20 BB A4  JSR R4BB         ;thus, number of elements not transferred
A38D A0 0C     LDY #&0C         ;13 bytes to copy, offsets 0..&C:
A38F 20 D5 A4  JSR R4D5         ;set up pointer to user's OSGBPB block
.R392
A392 B9 A1 FD  LDA &FDA1,Y      ;copy OSGBPB block back to user memory
A395 91 B4     STA (&B4),Y
A397 88        DEY
A398 10 F8     BPL R392
A39A 28        PLP
.R39B
A39B 60        RTS
                                ;OSGBPB 1 = set pointer and write data
                                ;OSGBPB 2 = write data
A39C 20 6D A4  JSR R46D         ;get byte from user memory
A39F 20 9E 9D  JSR QD9E         ;call OSBPUT; write byte to file
A3A2 18        CLC              ;return C=0 no end-of-file condition
A3A3 60        RTS
                                ;OSGBPB 3 = set pointer and read data
                                ;OSGBPB 4 = read data
A3A4 20 D1 9C  JSR QCD1         ;call OSBGET; read byte from file
A3A7 B0 F2     BCS R39B         ;if end-of-file reached return C=1
A3A9 4C A4 A4  JMP R4A4         ;else write data byte to user memory
                                ;OSGBPB 5 = read title, boot option and drive
A3AC 20 1E AA  JSR RA1E         ;set current vol/dir = default, set up drive
A3AF 20 1F 96  JSR Q61F         ;ensure current volume catalogue loaded
A3B2 A9 0C     LDA #&0C         ;write 12 to user memory
A3B4 20 A4 A4  JSR R4A4         ;= length of title
A3B7 A0 00     LDY #&00         ;set offset to 0
.R3B9
A3B9 20 11 BE  JSR SE11         ;page in catalogue sector 0
A3BC B9 00 FD  LDA &FD00,Y      ;get first eight characters of title
A3BF 20 A4 A4  JSR R4A4         ;write to user memory
A3C2 C8        INY
A3C3 C0 08     CPY #&08         ;loop until 8 characters written
A3C5 D0 F2     BNE R3B9
.R3C7
A3C7 20 16 BE  JSR SE16         ;page in catalogue sector 1
A3CA B9 F8 FC  LDA &FCF8,Y      ;get last four characters from &FD00..3
A3CD 20 A4 A4  JSR R4A4         ;write to user memory (Y = 8..11)
A3D0 C8        INY
A3D1 C0 0C     CPY #&0C         ;loop until 4 more characters written
A3D3 D0 F2     BNE R3C7
A3D5 20 16 BE  JSR SE16
A3D8 AD 06 FD  LDA &FD06        ;get boot option/top bits volume size
A3DB 20 9E A9  JSR R99E         ;shift A right 4 places
A3DE 4C A4 A4  JMP R4A4         ;write boot option to user memory and exit
                                ;OSGBPB 6 = read default (CSD) drive and dir
A3E1 AD C7 FD  LDA &FDC7        ;get default volume
A3E4 20 80 A4  JSR R480         ;write length+drive identifier to user memory
A3E7 20 A2 A4  JSR R4A2         ;write binary 1 to user memory
A3EA AD C6 FD  LDA &FDC6        ;get default directory character
A3ED 4C A4 A4  JMP R4A4         ;write it to user memory and exit
                                ;OSGBPB 7 = read library drive and directory
A3F0 AD C9 FD  LDA &FDC9        ;get library volume
A3F3 20 80 A4  JSR R480         ;write length+drive identifier to user memory
A3F6 20 A2 A4  JSR R4A2         ;write binary 1 to user memory
A3F9 AD C8 FD  LDA &FDC8        ;get library directory character
A3FC 4C A4 A4  JMP R4A4         ;write it to user memory and exit
                                ;OSGBPB 8 = read filenames in default dir
A3FF 20 1E AA  JSR RA1E         ;set current vol/dir = default, set up drive
A402 20 1F 96  JSR Q61F         ;ensure current volume catalogue loaded
A405 A9 12     LDA #&12         ;replace action address with &A412
A407 8D E0 FD  STA &FDE0        ;= return one filename
A40A A9 A4     LDA #&A4
A40C 8D E1 FD  STA &FDE1
A40F 4C 6A A3  JMP R36A         ;and return requested number of filenames.
                                ;Return one filename (called during OSGBPB 8)
A412 20 0C BE  JSR SE0C         ;page in main workspace
A415 AC AA FD  LDY &FDAA        ;set Y = catalogue pointer (0 on first call)
.R418
A418 20 16 BE  JSR SE16         ;page in catalogue sector 1
A41B CC 05 FD  CPY &FD05        ;compare with no. files in catalogue
A41E B0 2E     BCS R44E         ;if out of files return C=1, read past EOF
A420 20 11 BE  JSR SE11         ;else page in catalogue sector 0
A423 B9 0F FD  LDA &FD0F,Y      ;get directory character of cat entry
A426 20 D1 A9  JSR R9D1         ;set C=0 iff character in A is a letter
A429 45 CE     EOR &CE          ;compare with current directory character
A42B B0 02     BCS R42F         ;if directory character is a letter
A42D 29 DF     AND #&DF         ;then ignore case.
.R42F
A42F 29 7F     AND #&7F         ;mask off attribute bit b7
A431 F0 05     BEQ R438         ;if catalogue entry not in current directory
A433 20 A9 A9  JSR R9A9         ;then add 8 to Y
A436 D0 E0     BNE R418         ;and loop (always)
.R438
A438 A9 07     LDA #&07         ;else write 7 to user memory
A43A 20 A4 A4  JSR R4A4         ;= length of filename
A43D 85 B0     STA &B0          ;set counter to 7
.R43F
A43F 20 11 BE  JSR SE11         ;page in catalogue sector 0
A442 B9 08 FD  LDA &FD08,Y      ;get character of leaf name
A445 20 A4 A4  JSR R4A4         ;write byte to user memory
A448 C8        INY              ;increment catalogue pointer
A449 C6 B0     DEC &B0          ;loop until 7 characters transferred
A44B D0 F2     BNE R43F         ;(Y is 7 up, inc at &A379 puts pointer 8 up)
A44D 18        CLC              ;c=0, did not run out of filenames:
.R44E
A44E 20 16 BE  JSR SE16         ;page in catalogue sector 1
A451 AD 04 FD  LDA &FD04        ;get catalogue cycle number
A454 20 0C BE  JSR SE0C         ;page in main workspace
A457 8C AA FD  STY &FDAA        ;put updated cat ptr in OSGBPB pointer field
A45A 8D A1 FD  STA &FDA1        ;return catalogue cycle no. in channel field
A45D 60        RTS
.R45E                           ;Set up pointer to user I/O memory
A45E 48        PHA
A45F AD A2 FD  LDA &FDA2
A462 85 B8     STA &B8
A464 AD A3 FD  LDA &FDA3
A467 85 B9     STA &B9
A469 A2 00     LDX #&00         ;offset = 0 for indexed indirect load/store
A46B 68        PLA
A46C 60        RTS
.R46D                           ;Read data byte from user memory
A46D 2C DB FD  BIT &FDDB        ;test Tube transfer flag
A470 10 06     BPL R478         ;if b7=0 then read from I/O memory
A472 AD E5 FE  LDA &FEE5        ;else read from R3DATA
A475 4C B6 A4  JMP R4B6         ;increment OSGBPB address field
.R478
A478 20 5E A4  JSR R45E         ;set up pointer to user I/O memory
A47B A1 B8     LDA (&B8,X)      ;read byte from user I/O memory
A47D 4C B6 A4  JMP R4B6         ;increment OSGBPB address field
.R480                           ;Write length+drive identifier to user memory
A480 48        PHA
A481 A0 01     LDY #&01         ;return Y=1
A483 29 F0     AND #&F0         ;unless volume letter is B..H
A485 F0 01     BEQ R488
A487 C8        INY              ;in which case return Y=2
.R488
A488 98        TYA
A489 20 A4 A4  JSR R4A4         ;write length of drive ID to user memory
A48C 68        PLA
A48D 48        PHA
A48E 29 0F     AND #&0F         ;extract drive number
A490 18        CLC
A491 69 30     ADC #&30         ;convert to ASCII digit
A493 20 A4 A4  JSR R4A4         ;write data byte to user memory
A496 68        PLA
A497 20 9E A9  JSR R99E         ;shift A right 4 places
A49A F0 43     BEQ R4DF         ;if volume letter is A then exit
A49C 18        CLC
A49D 69 41     ADC #&41         ;else convert binary to letter B..H
A49F 4C A4 A4  JMP R4A4         ;write it to user memory and exit
.R4A2                           ;Write binary 1 to user memory
A4A2 A9 01     LDA #&01
.R4A4                           ;Write data byte to user memory
A4A4 20 0C BE  JSR SE0C         ;page in main workspace
A4A7 2C DB FD  BIT &FDDB        ;test Tube flag
A4AA 10 05     BPL R4B1         ;if Tube not in use then write to I/O memory
A4AC 8D E5 FE  STA &FEE5        ;else put byte in R3DATA
A4AF 30 05     BMI R4B6         ;and increment OSGBPB address field (always)
.R4B1
A4B1 20 5E A4  JSR R45E         ;set up pointer to user I/O memory
A4B4 81 B8     STA (&B8,X)      ;store byte at pointer:
.R4B6                           ;Increment OSGBPB address field
A4B6 20 4C A8  JSR R84C         ;save AXY
A4B9 A2 01     LDX #&01         ;set X = &01, point to OSGBPB data address:
.R4BB                           ;Increment OSGBPB field
A4BB A0 04     LDY #&04
.R4BD
A4BD FE A1 FD  INC &FDA1,X
A4C0 D0 04     BNE R4C6
A4C2 E8        INX
A4C3 88        DEY
A4C4 D0 F7     BNE R4BD
.R4C6
A4C6 60        RTS              ;return Z=1 iff field overflows
.R4C7                           ;Invert OSGBPB length field
A4C7 A2 03     LDX #&03
.R4C9
A4C9 A9 FF     LDA #&FF
A4CB 5D A6 FD  EOR &FDA6,X
A4CE 9D A6 FD  STA &FDA6,X
A4D1 CA        DEX
A4D2 10 F5     BPL R4C9
A4D4 60        RTS
.R4D5                           ;Set up pointer to user's OSGBPB block
A4D5 AD BE FD  LDA &FDBE
A4D8 85 B4     STA &B4
A4DA AD BF FD  LDA &FDBF
A4DD 85 B5     STA &B5
.R4DF
A4DF 60        RTS
.R4E0                           ;Put data byte in user memory
A4E0 2C CC FD  BIT &FDCC        ;test Tube data transfer flag
A4E3 30 03     BMI R4E8         ;if transferring to host
A4E5 91 A6     STA (&A6),Y      ;then write to address in I/O memory
A4E7 60        RTS
.R4E8
A4E8 8D E5 FE  STA &FEE5        ;else write to R3DATA.
A4EB 60        RTS
.R4EC                           ;Get data byte from user memory
A4EC 2C CC FD  BIT &FDCC        ;test Tube data transfer flag
A4EF 30 03     BMI R4F4         ;if transferring from host
A4F1 B1 A6     LDA (&A6),Y      ;then read address in I/O memory
A4F3 60        RTS
.R4F4
A4F4 AD E5 FE  LDA &FEE5        ;else read from R3DATA.
A4F7 60        RTS
.R4F8                           ;Return no. reserved sectors in data area
A4F8 20 0C BE  JSR SE0C         ;page in main workspace
A4FB 20 4C B7  JSR S74C         ;is the physical drive a RAM disc?
A4FE F0 07     BEQ R507         ;if so then return A=2
A500 A9 00     LDA #&00         ;else A=0
A502 2C ED FD  BIT &FDED        ;test density flag
A505 70 02     BVS R509         ;if single density
.R507
A507 A9 02     LDA #&02         ;then return A=2
.R509
A509 60        RTS              ;else return A=0
.R50A                           ;Get start and size of user memory
A50A 20 0C BE  JSR SE0C         ;page in main workspace
A50D A9 83     LDA #&83         ;call OSBYTE &83 = read OSHWM
A50F 20 F4 FF  JSR &FFF4
A512 8C D5 FD  STY &FDD5        ;save MSB
A515 A9 84     LDA #&84         ;call OSBYTE &84 = read HIMEM
A517 20 F4 FF  JSR &FFF4
A51A 98        TYA
A51B 8D D6 FD  STA &FDD6        ;save MSB
A51E 38        SEC
A51F ED D5 FD  SBC &FDD5        ;subtract MSB of OSHWM
A522 8D D7 FD  STA &FDD7        ;save result = no. pages of user memory.
A525 60        RTS
                                ;*HELP UTILS
A526 A2 48     LDX #&48         ;Print utility command table at &9148
A528 A0 91     LDY #&91
A52A A9 08     LDA #&08         ;8 entries to print (not *DISK)
A52C D0 06     BNE R534
                                ;*HELP CHAL / *HELP DFS
A52E A2 B4     LDX #&B4         ;Print Challenger command table at &90B4
A530 A0 90     LDY #&90
A532 A9 12     LDA #&12         ;18 entries to print
.R534
A534 20 1E 92  JSR Q21E         ;set up trampoline to read table at XY
A537 85 B8     STA &B8          ;store number of printable entries in counter
A539 20 69 84  JSR P469         ;print newline
A53C 18        CLC              ;c=0 print version number in banner
A53D 20 5E AE  JSR RE5E         ;print Challenger banner
A540 20 D3 A8  JSR R8D3         ;print copyright message
A543 EQUS "(C) SLOGGER 1987"
A553 EQUB &0D
A554 EA        NOP
A555 A2 00     LDX #&00         ;set offset in command table = 0
.R557
A557 20 15 A8  JSR R815         ;print two spaces
A55A 20 7E A5  JSR R57E         ;print command name and syntax
A55D 20 69 84  JSR P469         ;print newline
A560 C6 B8     DEC &B8          ;decrement count of entries
A562 D0 F3     BNE R557         ;loop until none remain
A564 60        RTS
.R565                           ;Call GSINIT with C=0 and reject empty arg
A565 20 F2 A9  JSR R9F2         ;call GSINIT with C=0
A568 F0 01     BEQ R56B         ;if string empty (and unquoted), syntax error
A56A 60        RTS
.R56B                           ;Raise "Syntax: " error
A56B 20 AD A8  JSR R8AD
A56E EQUB &DC
A56F EQUS "Syntax: "
A577 EA        NOP
A578 20 7E A5  JSR R57E         ;print command name and syntax
A57B 4C F8 A8  JMP R8F8         ;terminate error message, raise error
.R57E                           ;Print command name and syntax
A57E 20 4C A8  JSR R84C         ;save AXY
A581 A2 00     LDX #&00         ;set offset in command table = 0
A583 A0 09     LDY #&09         ;9 characters in command name column
.R585
A585 20 AA 00  JSR &00AA        ;get byte of command name
A588 30 08     BMI R592         ;if terminator reached then print syntax
A58A 20 51 A9  JSR R951         ;else print character in A (OSASCI)
A58D E8        INX              ;increment offset
A58E 88        DEY              ;decrement number of spaces remaining
A58F 4C 85 A5  JMP R585         ;and loop
.R592                           ;Print syntax
A592 88        DEY              ;if Y in range 1..128
A593 30 04     BMI R599         ;then command not reached edge of column
A595 C8        INY              ;so
A596 20 DD 8A  JSR PADD         ;print number of spaces in Y
.R599
A599 E8        INX              ;skip action address
A59A E8        INX
A59B 20 AA 00  JSR &00AA        ;get syntax byte
A59E 48        PHA              ;save it
A59F E8        INX              ;skip over it
A5A0 20 2D 92  JSR Q22D         ;add X to trampoline address
A5A3 68        PLA
A5A4 20 AC A5  JSR R5AC         ;print syntax element
A5A7 20 9E A9  JSR R99E         ;shift A right 4 places
A5AA 29 07     AND #&07         ;mask b2..0 ignore restricted cmd bit:
.R5AC                           ;Print syntax element
A5AC 20 4C A8  JSR R84C         ;save AXY
A5AF 29 0F     AND #&0F         ;mask b3..0 current syntax element
A5B1 F0 1D     BEQ R5D0         ;if null element then return
A5B3 A8        TAY              ;else transfer to Y for use as counter
A5B4 A9 20     LDA #&20         ;print a space
A5B6 20 51 A9  JSR R951         ;print character in A (OSASCI)
A5B9 A2 FF     LDX #&FF         ;set offset=&FF going to 0:
.R5BB
A5BB E8        INX              ;increment offset
A5BC BD D1 A5  LDA &A5D1,X      ;get character of syntax element table
A5BF D0 FA     BNE R5BB         ;loop until NUL reached
A5C1 88        DEY              ;decrement number of NULs to skip
A5C2 D0 F7     BNE R5BB         ;when Y=0 we've reached correct element:
.R5C4
A5C4 E8        INX              ;increment offset
A5C5 BD D1 A5  LDA &A5D1,X      ;get character of syntax element table
A5C8 F0 06     BEQ R5D0         ;if NUL reached then return
A5CA 20 51 A9  JSR R951         ;else print character in A (OSASCI)
A5CD 4C C4 A5  JMP R5C4         ;and loop until element printed.
.R5D0
A5D0 60        RTS
;Table of syntax elements
A5D1 EQUB &00                   ;element &0, ""
A5D2 EQUS "<fsp>"               ;element &1, <fsp>
A5D7 EQUB &00
A5D8 EQUS "<afsp>"              ;element &2, <afsp>
A5DE EQUB &00
A5DF EQUS "(L)"                 ;element &3, (L)
A5E2 EQUB &00
A5E3 EQUS "<src drv>"           ;element &4, <src drv>
A5EC EQUB &00
A5ED EQUS "<dest drv>"          ;element &5, <dest drv>
A5F7 EQUB &00
A5F8 EQUS "<dest drv> <afsp>"   ;element &6, <dest drv> <afsp>
A609 EQUB &00
A60A EQUS "<new fsp>"           ;element &7, <new fsp>
A613 EQUB &00
A614 EQUS "<old fsp>"           ;element &8, <old fsp>
A61D EQUB &00
A61E EQUS "(<dir>)"             ;element &9, (<dir>)
A625 EQUB &00
A626 EQUS "(<drv>)"             ;element &A, (<drv>)
A62D EQUB &00
A62E EQUS "<title>"             ;element &B, <title>
A635 EQUB &00                   ;terminator byte
                                ;*COMPACT
A636 20 16 AA  JSR RA16         ;parse volume spec from argument
A639 8D CA FD  STA &FDCA        ;set as source drive
A63C 8D CB FD  STA &FDCB        ;set as destination drive
A63F 20 D3 A8  JSR R8D3
A642 EQUS "Compacting"
A64C EA        NOP
A64D 20 AD 8E  JSR PEAD         ;print " Drive " plus volume spec in A
A650 20 69 84  JSR P469         ;print newline
A653 20 74 99  JSR Q974         ;close all files
A656 20 0A A5  JSR R50A         ;get start and size of user memory
A659 20 2F 96  JSR Q62F         ;load volume catalogue L4
A65C 20 23 85  JSR P523         ;save parameters of source drive
A65F 20 2A 85  JSR P52A         ;save parameters of destination drive
A662 20 16 BE  JSR SE16         ;page in catalogue sector 1
A665 AC 05 FD  LDY &FD05        ;get number of files in catalogue
A668 84 CC     STY &CC          ;set as catalogue pointer
A66A A9 00     LDA #&00         ;initialise LBA to start of data area
A66C 85 CB     STA &CB
A66E 20 F8 A4  JSR R4F8
A671 85 CA     STA &CA
.R673
A673 A4 CC     LDY &CC          ;set Y to catalogue pointer
A675 20 B2 A9  JSR R9B2         ;subtract 8 from Y
A678 C0 F8     CPY #&F8         ;if we've reached end of catalogue
A67A F0 5A     BEQ R6D6         ;then finish
A67C 84 CC     STY &CC          ;else set new catalogue pointer
A67E 20 9D 8C  JSR PC9D         ;print *INFO line if verbose
A681 A4 CC     LDY &CC
A683 20 03 A7  JSR R703         ;test length of file
A686 F0 46     BEQ R6CE         ;if empty then only print *INFO line
A688 A9 00     LDA #&00
A68A 85 BE     STA &BE          ;else set LSB load address = 0
A68C 85 C2     STA &C2          ;set LSB transfer size = 0
A68E 20 14 A7  JSR R714         ;calculate number of sectors used by file
A691 20 16 BE  JSR SE16         ;page in catalogue sector 1
A694 B9 0F FD  LDA &FD0F,Y      ;get LSB start sector
A697 85 C8     STA &C8          ;set LSB source LBA
A699 B9 0E FD  LDA &FD0E,Y      ;get top bits exec/length/load/start sector
A69C 29 03     AND #&03         ;extract b1,b0 of A
A69E 85 C9     STA &C9          ;set MSB source LBA
A6A0 C5 CB     CMP &CB          ;compare with destination LBA
A6A2 D0 0C     BNE R6B0         ;if unequal then compact file
A6A4 A5 C8     LDA &C8          ;else compare LSBs source - destination LBA
A6A6 C5 CA     CMP &CA
A6A8 D0 06     BNE R6B0         ;if unequal then compact file
A6AA 20 33 A7  JSR R733         ;else add number of sectors to total
A6AD 4C CE A6  JMP R6CE         ;print *INFO line and loop for next file
.R6B0                           ;Compact file
A6B0 20 16 BE  JSR SE16         ;page in catalogue sector 1
A6B3 A5 CA     LDA &CA          ;set LSB start sector = destination LBA
A6B5 99 0F FD  STA &FD0F,Y
A6B8 B9 0E FD  LDA &FD0E,Y      ;get top bits exec/length/load/start sector
A6BB 29 FC     AND #&FC         ;clear b1,b0 MSB start sector
A6BD 05 CB     ORA &CB          ;replace with MSB destination LBA
A6BF 99 0E FD  STA &FD0E,Y      ;set top bits exec/length/load/start sector
A6C2 A9 00     LDA #&00
A6C4 85 A8     STA &A8          ;no catalogue entry waiting to be created
A6C6 85 A9     STA &A9          ;&00 = source and dest. are different drives
A6C8 20 48 89  JSR P948         ;copy source drive/file to destination
A6CB 20 0B 96  JSR Q60B         ;write volume catalogue L4
.R6CE
A6CE A4 CC     LDY &CC
A6D0 20 A5 8C  JSR PCA5         ;print *INFO line
A6D3 4C 73 A6  JMP R673         ;loop for next file
.R6D6
A6D6 20 D3 A8  JSR R8D3         ;print "Disk compacted "
A6D9 EQUS "Disk compacted "
A6E8 EA        NOP
A6E9 38        SEC
A6EA 20 16 BE  JSR SE16         ;page in catalogue sector 1
A6ED AD 07 FD  LDA &FD07        ;get LSB volume size
A6F0 E5 CA     SBC &CA          ;subtract LSB sectors used on volume
A6F2 85 C6     STA &C6          ;=LSB sectors free. save on stack
A6F4 AD 06 FD  LDA &FD06        ;get boot option/top bits volume size
A6F7 29 03     AND #&03         ;extract volume size in b1,b0
A6F9 E5 CB     SBC &CB          ;subtract MSB sectors used on volume
A6FB 85 C7     STA &C7
A6FD 20 E0 8B  JSR PBE0         ;print number of free sectors
A700 4C CA 88  JMP P8CA         ;store empty BASIC program at OSHWM (NEW)
.R703                           ;Test length of file
A703 20 16 BE  JSR SE16         ;page in catalogue sector 1
A706 B9 0E FD  LDA &FD0E,Y      ;get top bits exec/length/load/start sector
A709 29 30     AND #&30         ;extract length in b5,b4
A70B 19 0D FD  ORA &FD0D,Y      ;OR with 2MSB, LSB of length
A70E 19 0C FD  ORA &FD0C,Y      ;return Z=1 if length=0, empty file.
A711 4C 0C BE  JMP SE0C         ;page in main workspace
.R714                           ;Calculate number of sectors used by file
A714 20 16 BE  JSR SE16         ;page in catalogue sector 1
A717 18        CLC
A718 B9 0C FD  LDA &FD0C,Y      ;get LSB length
A71B 69 FF     ADC #&FF         ;c=1 iff LSB >0
A71D B9 0D FD  LDA &FD0D,Y      ;add C to 2MSB length, rounding up
A720 69 00     ADC #&00         ;(Y points to 8 bytes before file entry)
A722 85 C6     STA &C6
A724 B9 0E FD  LDA &FD0E,Y      ;get top bits exec/length/load/start sector
A727 08        PHP              ;save carry flag from addition
A728 20 96 A9  JSR R996         ;extract length from b5,4 to b1,0
A72B 28        PLP              ;restore carry flag
A72C 69 00     ADC #&00         ;add C to MSB length, rounding up
A72E 85 C7     STA &C7          ;store length in sectors in zero page
A730 4C 0C BE  JMP SE0C         ;page in main workspace
.R733                           ;Add number of sectors to total
A733 18        CLC              ;add LSB
A734 A5 CA     LDA &CA
A736 65 C6     ADC &C6
A738 85 CA     STA &CA
A73A A5 CB     LDA &CB          ;add MSB
A73C 65 C7     ADC &C7
A73E 85 CB     STA &CB
A740 60        RTS
.R741                           ;Set swapping and current disc flags
A741 AD CB FD  LDA &FDCB        ;get destination drive
A744 20 DB AA  JSR RADB         ;map volume in A to physical volume
A747 85 A9     STA &A9          ;store in temporary variable
A749 AD CA FD  LDA &FDCA        ;get source drive
A74C 20 DB AA  JSR RADB         ;map volume in A to physical volume
A74F C5 A9     CMP &A9          ;compare with destination drive
A751 D0 07     BNE R75A         ;if equal
A753 A9 FF     LDA #&FF         ;then A=&FF
A755 85 A9     STA &A9          ;b7=1 source & dest. share drive (swapping)
A757 85 AA     STA &AA          ;b7=1 dest. disc in drive (ask for source)
A759 60        RTS
.R75A
A75A A9 00     LDA #&00         ;&00 = source and dest. are different drives
A75C 85 A9     STA &A9
A75E 60        RTS
.R75F                           ;Ensure *ENABLE active
A75F 20 4C A8  JSR R84C         ;save AXY
A762 2C DF FD  BIT &FDDF        ;test *ENABLE flag
A765 10 20     BPL R787         ;if b7=0 then current command is enabled
A767 20 D3 A8  JSR R8D3         ;else print "Are you sure ? Y/N "
A76A EQUB &0D
A76B EQUS "Are you sure ? Y/N "
A77E EA        NOP
A77F 20 DE 84  JSR P4DE         ;ask user yes or no
A782 F0 03     BEQ R787         ;if user typed Y then return
A784 A6 B8     LDX &B8          ;else reset to stack pointer set at &80C0
A786 9A        TXS              ;and exit from *command.
.R787
A787 4C 69 84  JMP P469         ;print newline
.R78A                           ;Parse and print source and dest. volumes
A78A 20 65 A5  JSR R565         ;call GSINIT with C=0 and reject empty arg
A78D 20 7F AA  JSR RA7F         ;parse volume spec
A790 8D CA FD  STA &FDCA        ;store source volume
A793 20 65 A5  JSR R565         ;call GSINIT with C=0 and reject empty arg
A796 20 7F AA  JSR RA7F         ;parse volume spec
A799 8D CB FD  STA &FDCB        ;store destination volume
A79C 98        TYA              ;save GSINIT offset in Y
A79D 48        PHA
A79E 20 41 A7  JSR R741         ;set swapping and current disc flags
A7A1 20 0A A5  JSR R50A         ;get start and size of user memory
A7A4 20 D3 A8  JSR R8D3         ;print "Copying from drive "
A7A7 EQUS "Copying from drive "
A7BA AD CA FD  LDA &FDCA        ;get source volume
A7BD 20 B8 8E  JSR PEB8         ;print volume spec in A
A7C0 20 D3 A8  JSR R8D3         ;print " to drive "
A7C3 EQUS " to drive "
A7CD AD CB FD  LDA &FDCB        ;get destination volume
A7D0 20 B8 8E  JSR PEB8         ;print volume spec in A
A7D3 20 69 84  JSR P469         ;print newline
A7D6 68        PLA              ;restore GSINIT offset to Y
A7D7 A8        TAY
A7D8 18        CLC
A7D9 60        RTS
.R7DA                           ;Increment and print BCD word
A7DA F8        SED              ;set decimal mode
A7DB 18        CLC              ;increment low byte
A7DC A5 A8     LDA &A8
A7DE 69 01     ADC #&01         ;only ADC and SBC have decimal mode
A7E0 85 A8     STA &A8          ;carry out in C, the only valid flag
A7E2 A5 A9     LDA &A9          ;carry out to high byte
A7E4 69 00     ADC #&00
A7E6 85 A9     STA &A9
A7E8 D8        CLD              ;clear decimal mode
.R7E9                           ;Print space-padded hex word
A7E9 18        CLC              ;set C=1, pad numeric field with spaces
A7EA A5 A9     LDA &A9          ;get high byte of word
A7EC 20 00 A8  JSR R800         ;print hex byte, C=0 if space-padded
A7EF B0 01     BCS R7F2         ;c=digit printed; preserve over entry point
.R7F1                           ;Print space-padded hex byte
A7F1 18        CLC
.R7F2                           ;Print hex byte, C=0 if space-padded
A7F2 A5 A8     LDA &A8          ;get low byte of word
A7F4 D0 0A     BNE R800         ;if non-zero then print it
A7F6 B0 08     BCS R800         ;else if not space-padded then print zeroes
A7F8 20 18 A8  JSR R818         ;else print a space
A7FB A9 00     LDA #&00
A7FD 4C 80 A9  JMP R980         ;and print hex nibble (0).
.R800                           ;Print hex byte, C=0 if space-padded
A800 48        PHA
A801 08        PHP              ;save space padding flag in C
A802 20 9E A9  JSR R99E         ;shift A right 4 places
A805 28        PLP              ;restore C
A806 20 0A A8  JSR R80A         ;print top nibble of byte
A809 68        PLA              ;restore bottom nibble:
.R80A                           ;Print space-padded hex nibble
A80A 48        PHA              ;test accumulator, Z=1 if zero
A80B 68        PLA
A80C B0 02     BCS R810         ;if digit has been printed print another
A80E F0 08     BEQ R818         ;else if nibble is zero print a space
.R810
A810 20 80 A9  JSR R980         ;else print hex nibble
A813 38        SEC              ;set C=1 to suppress space padding
A814 60        RTS              ;and exit
.R815                           ;Print two spaces
A815 20 18 A8  JSR R818
.R818                           ;Print a space
A818 48        PHA              ;preserve A
A819 A9 20     LDA #&20
A81B 20 51 A9  JSR R951         ;print character in A (OSASCI)
A81E 68        PLA
A81F 18        CLC              ;return C=0
A820 60        RTS
.R821                           ;Claim service call and set up argument ptr
A821 BA        TSX
A822 A9 00     LDA #&00         ;have A=0 returned on exit
A824 9D 07 01  STA &0107,X
A827 98        TYA              ;save string offset
A828 48        PHA
A829 20 65 A5  JSR R565         ;call GSINIT with C=0 and reject empty arg
A82C 68        PLA              ;restore string offset
A82D A8        TAY
A82E 98        TYA              ;set XY to GSINIT pointer + Y
A82F 18        CLC              ;add Y to LSB of GSINIT pointer
A830 65 F2     ADC &F2
A832 AA        TAX              ;hold in X
A833 A5 F3     LDA &F3          ;carry out to high byte of GSINIT pointer
A835 69 00     ADC #&00
A837 A8        TAY              ;hold in Y
.R838                           ;Clear private pointer
A838 A9 00     LDA #&00
A83A 85 A8     STA &A8
A83C 85 A9     STA &A9
A83E 60        RTS
.R83F                           ;Have A=0 returned on exit
A83F 48        PHA              ;caller called Save AXY, A was at &0105,S
A840 8A        TXA              ;save caller's AX
A841 48        PHA              ;these two bytes plus return address make 4
A842 BA        TSX              ;superroutine's A is thus 5+4 = 9 bytes down
A843 A9 00     LDA #&00
A845 9D 09 01  STA &0109,X
A848 68        PLA              ;restore caller's AX
A849 AA        TAX
A84A 68        PLA
A84B 60        RTS
.R84C                           ;Save AXY
A84C 48        PHA              ;stack = &6E,&A8,y,x,a,cl,ch,sl,sh
A84D 8A        TXA              ;cl,ch=caller return address
A84E 48        PHA              ;sl,sh=superroutine return address
A84F 98        TYA
A850 48        PHA
A851 A9 A8     LDA #&A8
A853 48        PHA
A854 A9 6E     LDA #&6E
A856 48        PHA
.R857
A857 A0 05     LDY #&05         ;duplicate y,x,a,cl,ch
.R859
A859 BA        TSX
A85A BD 07 01  LDA &0107,X
A85D 48        PHA
A85E 88        DEY
A85F D0 F8     BNE R859
A861 A0 0A     LDY #&0A         ;copy top 10 bytes down 2 places:
.R863
A863 BD 09 01  LDA &0109,X      ;overwrite bottom copy of cl,ch
A866 9D 0B 01  STA &010B,X
A869 CA        DEX
A86A 88        DEY              ;stack now contains:
A86B D0 F6     BNE R863         ;y,x,y,x,a,cl,ch,&6E,&A8,y,x,a,sl,sh
A86D 68        PLA              ;discard y,x:
A86E 68        PLA
.R86F                           ;Restore AXY and return
A86F 68        PLA
A870 A8        TAY
A871 68        PLA
A872 AA        TAX
A873 68        PLA
A874 60        RTS
.R875                           ;Save XY
A875 48        PHA              ;push y,x,a
A876 8A        TXA
A877 48        PHA
A878 98        TYA
A879 48        PHA
A87A 20 57 A8  JSR R857         ;restack then "call" rest of caller's routine!
A87D BA        TSX              ;get stack pointer
A87E 9D 03 01  STA &0103,X      ;store A on exit from caller in stack:
A881 4C 6F A8  JMP R86F         ;restore y,x on entry, a on exit.
.R884                           ;Raise "Disk read only" error
A884 20 92 A8  JSR R892
A887 EQUB &C9
A888 EQUS "read only"
A891 EQUB &00
.R892                           ;Raise "Disk " error
A892 20 D0 A8  JSR R8D0
A895 EQUS "Disk "
A89A 90 11     BCC R8AD
.R89C                           ;Raise "Bad " error
A89C 20 D0 A8  JSR R8D0
A89F EQUS "Bad "
A8A3 90 08     BCC R8AD
.R8A5                           ;Raise "File " error
A8A5 20 D0 A8  JSR R8D0
A8A8 EQUS "File "
.R8AD                           ;Append error message immediate
A8AD 85 B3     STA &B3          ;save A on entry
A8AF 68        PLA              ;pop caller's address into pointer
A8B0 85 AE     STA &AE
A8B2 68        PLA
A8B3 85 AF     STA &AF
A8B5 A5 B3     LDA &B3          ;restore A on entry and save on stack
A8B7 48        PHA
A8B8 98        TYA              ;save Y
A8B9 48        PHA
A8BA A0 00     LDY #&00         ;set Y=0 for indirect indexed load
A8BC 20 EB A9  JSR R9EB         ;increment &AE,F
A8BF B1 AE     LDA (&AE),Y      ;get error number from byte after JSR
A8C1 8D 01 01  STA &0101        ;store at bottom of stack
A8C4 20 40 A9  JSR R940         ;if error message already being built
A8C7 30 19     BMI R8E2         ;then complete it
A8C9 A9 02     LDA #&02         ;else A = &02
A8CB 8D 00 01  STA &0100        ;error message being built from offset 2
A8CE D0 12     BNE R8E2         ;build error message (always)
.R8D0                           ;Prefix error message immediate
A8D0 20 3B A9  JSR R93B         ;begin error message
.R8D3                           ;Print string immediate
A8D3 85 B3     STA &B3          ;save A on entry
A8D5 68        PLA              ;pop caller's address into pointer
A8D6 85 AE     STA &AE
A8D8 68        PLA
A8D9 85 AF     STA &AF
A8DB A5 B3     LDA &B3          ;restore A on entry and save on stack
A8DD 48        PHA
A8DE 98        TYA              ;save Y
A8DF 48        PHA
A8E0 A0 00     LDY #&00         ;set Y=0 for indirect indexed load:
.R8E2
A8E2 20 EB A9  JSR R9EB         ;increment &AE,F
A8E5 B1 AE     LDA (&AE),Y      ;get character from after JSR
A8E7 30 08     BMI R8F1         ;if b7=1 then opcode terminator, execute it
A8E9 F0 0D     BEQ R8F8         ;else if NUL then raise error
A8EB 20 51 A9  JSR R951         ;else print the character
A8EE 4C E2 A8  JMP R8E2         ;and loop
.R8F1
A8F1 68        PLA              ;restore AY
A8F2 A8        TAY
A8F3 68        PLA
A8F4 18        CLC
A8F5 6C AE 00  JMP (&00AE)      ;jump to address of end of string
.R8F8                           ;Terminate error message, raise error
A8F8 A9 00     LDA #&00
A8FA AE 00 01  LDX &0100        ;get offset of end of error message
A8FD 9D 00 01  STA &0100,X      ;set NUL error message terminator
A900 8D 00 01  STA &0100        ;instruction at &0100 = BRK
A903 20 19 82  JSR P219         ;get Challenger unit type
A906 29 7F     AND #&7F         ;b7=0
A908 9D F0 0D  STA &0DF0,X      ;no error message being built print to screen
A90B 20 53 97  JSR Q753         ;forget catalogue in JIM pages 2..3
A90E 20 F3 96  JSR Q6F3         ;release Tube if present
A911 20 71 AD  JSR RD71         ;release NMI
A914 4C 00 01  JMP &0100        ;jump to BRK to raise error
.R917                           ;Print VDU sequence immediate
A917 68        PLA              ;pop caller's address into pointer
A918 85 AE     STA &AE
A91A 68        PLA
A91B 85 AF     STA &AF
A91D 98        TYA              ;save Y
A91E 48        PHA
A91F A0 00     LDY #&00         ;offset = 0 for indirect indexed load
.R921
A921 20 EB A9  JSR R9EB         ;increment &AE,F
A924 B1 AE     LDA (&AE),Y      ;get character from after JSR
A926 C9 FF     CMP #&FF         ;if &FF terminator byte
A928 F0 06     BEQ R930         ;then skip it and return to code after it
A92A 20 EE FF  JSR &FFEE        ;else call OSWRCH
A92D 4C 21 A9  JMP R921         ;and loop
.R930
A930 68        PLA              ;restore Y
A931 A8        TAY
.R932
A932 20 EB A9  JSR R9EB         ;increment &AE,F
A935 6C AE 00  JMP (&00AE)      ;jump to address at end of string
.R938                           ;Begin error message, number in A
A938 8D 01 01  STA &0101        ;set first byte after BRK to error number
.R93B                           ;Begin error message
A93B A9 02     LDA #&02
A93D 8D 00 01  STA &0100        ;error message being built from offset 2
.R940
A940 20 19 82  JSR P219         ;get Challenger unit type
A943 08        PHP
A944 09 80     ORA #&80         ;b7=1
A946 9D F0 0D  STA &0DF0,X      ;error message being built, &0100 = offset
A949 28        PLP
A94A 60        RTS
.R94B                           ;Print letter N
A94B A9 4E     LDA #&4E
A94D D0 02     BNE R951         ;branch (always)
.R94F                           ;Print a dot
A94F A9 2E     LDA #&2E
.R951                           ;Print character in A (OSASCI)
A951 20 4C A8  JSR R84C         ;save AXY
A954 48        PHA              ;save character
A955 20 19 82  JSR P219         ;get Chal. unit type. if error being built
A958 30 13     BMI R96D         ;then append character to error message else:
A95A 20 DC AD  JSR RDDC         ;call OSBYTE &EC = read/write char dest status
A95D 8A        TXA              ;save current output stream setting
A95E 48        PHA
A95F 09 10     ORA #&10         ;b4=1 disable *SPOOL output
A961 20 D7 AD  JSR RDD7         ;call OSBYTE &03 = specify output stream in A
A964 68        PLA              ;restore previous output stream setting
A965 AA        TAX
A966 68        PLA              ;restore character
A967 20 E3 FF  JSR &FFE3        ;call OSASCI
A96A 4C D8 AD  JMP RDD8         ;call OSBYTE &03 = specify output stream
.R96D                           ;Append character to error message
A96D 68        PLA              ;restore character
A96E AE 00 01  LDX &0100        ;get pointer to end of error message
A971 9D 00 01  STA &0100,X      ;store character there
A974 EE 00 01  INC &0100        ;and increment pointer
A977 60        RTS
.R978                           ;Print hex byte
A978 48        PHA              ;save A
A979 20 9E A9  JSR R99E         ;shift A right 4 places
A97C 20 80 A9  JSR R980         ;print top nibble of byte
A97F 68        PLA              ;restore bottom nibble:
.R980                           ;Print hex nibble
A980 48        PHA              ;save A
A981 29 0F     AND #&0F         ;extract b3..0
A983 F8        SED              ;set decimal mode for 6502 deep magic
A984 18        CLC
A985 69 90     ADC #&90         ;a=&90..99, C=0 or A=&00..05, C=1
A987 69 40     ADC #&40         ;a=&30..39      or A=&41..46
A989 D8        CLD              ;clear decimal mode
A98A 20 51 A9  JSR R951         ;print character in A (OSASCI)
A98D 68        PLA              ;restore A
A98E 60        RTS
.R98F                           ;Acknowledge ESCAPE condition
A98F A9 7E     LDA #&7E         ;OSBYTE &7E = acknowledge ESCAPE condition
A991 4C F4 FF  JMP &FFF4        ;call OSBYTE and exit
.R994                           ;Extract b7,b6 of A
A994 4A        LSR A
A995 4A        LSR A
.R996                           ;Extract b5,b4 of A
A996 4A        LSR A
A997 4A        LSR A
.R998                           ;Extract b3,b2 of A
A998 4A        LSR A
A999 4A        LSR A
A99A 29 03     AND #&03
A99C 60        RTS
.R99D                           ;Shift A right 5 places
A99D 4A        LSR A
.R99E                           ;Shift A right 4 places
A99E 4A        LSR A
A99F 4A        LSR A
A9A0 4A        LSR A
A9A1 4A        LSR A
A9A2 60        RTS
                                ;unreachable code
A9A3 0A        ASL A
.R9A4                           ;Shift A left 4 places
A9A4 0A        ASL A
A9A5 0A        ASL A
A9A6 0A        ASL A
A9A7 0A        ASL A
A9A8 60        RTS
.R9A9                           ;Add 8 to Y
A9A9 C8        INY
.R9AA                           ;Add 7 to Y
A9AA C8        INY
A9AB C8        INY
A9AC C8        INY
.R9AD                           ;Add 4 to Y
A9AD C8        INY
A9AE C8        INY
A9AF C8        INY
A9B0 C8        INY
A9B1 60        RTS
.R9B2                           ;Subtract 8 from Y
A9B2 88        DEY
A9B3 88        DEY
A9B4 88        DEY
A9B5 88        DEY
.R9B6                           ;Subtract 4 from Y
A9B6 88        DEY
A9B7 88        DEY
A9B8 88        DEY
A9B9 88        DEY
A9BA 60        RTS
.R9BB                           ;Uppercase and validate letter in A
A9BB C9 41     CMP #&41         ;is character less than capital A?
A9BD 90 0C     BCC R9CB         ;if so then return C=1
A9BF C9 5B     CMP #&5B         ;else is it more than capital Z?
A9C1 90 0A     BCC R9CD         ;if not then uppercase and return C=0
A9C3 C9 61     CMP #&61         ;else is it less than lowercase a?
A9C5 90 04     BCC R9CB         ;if so then return C=1
A9C7 C9 7B     CMP #&7B         ;else is it more than lowercase z?
A9C9 90 02     BCC R9CD         ;if not then uppercase and return C=0
.R9CB
A9CB 38        SEC              ;else return C=1
A9CC 60        RTS
.R9CD
A9CD 29 DF     AND #&DF         ;mask bit 5, convert letter to uppercase
A9CF 18        CLC
A9D0 60        RTS
.R9D1                           ;Set C=0 iff character in A is a letter
A9D1 48        PHA
A9D2 20 BB A9  JSR R9BB         ;uppercase and validate letter in A
A9D5 68        PLA
A9D6 60        RTS
                                ;unreachable code
A9D7 20 E1 A9  JSR R9E1
A9DA 90 03     BCC R9DF
A9DC C9 10     CMP #&10
A9DE 60        RTS
.R9DF                           ;unreachable code
A9DF 38        SEC
A9E0 60        RTS
.R9E1                           ;Convert ASCII hex digit to binary
A9E1 C9 41     CMP #&41         ;if digit is less than A
A9E3 90 02     BCC R9E7         ;then convert 0..9 to binary
A9E5 E9 07     SBC #&07         ;else convert A..F to binary
.R9E7
A9E7 38        SEC
A9E8 E9 30     SBC #&30
A9EA 60        RTS
.R9EB                           ;Increment &AE,F
A9EB E6 AE     INC &AE
A9ED D0 02     BNE R9F1
A9EF E6 AF     INC &AF
.R9F1
A9F1 60        RTS
.R9F2                           ;Call GSINIT with C=0
A9F2 18        CLC              ;c=0 space or CR terminates unquoted strings
A9F3 4C C2 FF  JMP &FFC2        ;jump to GSINIT
.R9F6                           ;Set current drive from ASCII digit
A9F6 20 BA AA  JSR RABA         ;convert and validate ASCII drive digit
A9F9 85 CF     STA &CF          ;set as current drive
A9FB 60        RTS
.R9FC                           ;Set volume from ASCII letter
A9FC 20 BB A9  JSR R9BB         ;uppercase and validate letter in A
A9FF 38        SEC              ;subtract ASCII value of A
AA00 E9 41     SBC #&41         ;obtain ordinal 0..25
AA02 90 30     BCC RA34         ;if ordinal negative then "Bad drive"
AA04 C9 08     CMP #&08         ;else is ordinal 8 or more?
AA06 B0 2C     BCS RA34         ;if so then raise "Bad drive" error
AA08 20 A4 A9  JSR R9A4         ;else shift A left 4 places
AA0B 05 CF     ORA &CF          ;combine volume letter with current drive
AA0D 85 CF     STA &CF          ;set as current volume, return C=0
AA0F 60        RTS
                                ;unreachable code
                                ;Call GSINIT and parse mandatory vol spec
AA10 20 65 A5  JSR R565         ;call GSINIT with C=0 and reject empty arg
AA13 4C 7F AA  JMP RA7F         ;parse volume spec
.RA16                           ;Parse volume spec from argument
AA16 20 F2 A9  JSR R9F2         ;call GSINIT with C=0
AA19 F0 0B     BEQ RA26         ;if no argument then current vol = default
AA1B 4C 7F AA  JMP RA7F         ;else parse volume spec
.RA1E                           ;Set current volume and directory = default
AA1E 20 0C BE  JSR SE0C         ;page in main workspace
AA21 AD C6 FD  LDA &FDC6        ;get default directory
AA24 85 CE     STA &CE          ;set as current directory:
.RA26                           ;Set current volume = default volume
AA26 AD C7 FD  LDA &FDC7        ;get default volume
AA29 85 CF     STA &CF          ;set as current volume
.RA2B
AA2B 60        RTS
                                ;unreachable code
AA2C 20 16 AA  JSR RA16
AA2F 20 F2 A9  JSR R9F2
AA32 F0 F7     BEQ RA2B
.RA34                           ;Raise "Bad drive" error
AA34 20 9C A8  JSR R89C
AA37 EQUB &CD
AA38 EQUS "drive"
AA3D EQUB &00
.RA3E                           ;Parse directory spec
AA3E 20 C5 FF  JSR &FFC5        ;call GSREAD
AA41 B0 2E     BCS RA71         ;if end of argument then exit C=1
AA43 C9 3A     CMP #&3A         ;else is character a colon?
AA45 D0 22     BNE RA69         ;if not then accept directory character
AA47 20 C5 FF  JSR &FFC5        ;else call GSREAD
AA4A B0 E8     BCS RA34         ;if ":" by itself then "Bad drive" error
AA4C 20 F6 A9  JSR R9F6         ;else set current drive from ASCII digit
AA4F 20 C5 FF  JSR &FFC5        ;call GSREAD
AA52 B0 1D     BCS RA71         ;if ":<drv>" keep current volume and dir
AA54 C9 2E     CMP #&2E         ;else is character a full stop?
AA56 F0 0C     BEQ RA64         ;if so then expect a directory character
AA58 20 FC A9  JSR R9FC         ;else set volume from ASCII letter
AA5B 20 C5 FF  JSR &FFC5        ;call GSREAD
AA5E B0 11     BCS RA71         ;if ":<drv><vol>" keep current directory
AA60 C9 2E     CMP #&2E         ;else ".<dir>" must follow
AA62 D0 D0     BNE RA34         ;if next char not full stop "Bad drive"
.RA64
AA64 20 C5 FF  JSR &FFC5        ;else call GSREAD
AA67 B0 CB     BCS RA34         ;directory char expected else "Bad drive"
.RA69
AA69 20 B0 AA  JSR RAB0         ;set directory from ASCII character
AA6C 20 C5 FF  JSR &FFC5        ;if not at end of argument
AA6F 90 C3     BCC RA34         ;then raise "Bad drive" error.
.RA71
AA71 60        RTS
.RA72                           ;Select specified or default volume
AA72 20 26 AA  JSR RA26         ;set current volume = default volume
AA75 A2 00     LDX #&00         ;x=0, nothing specified
AA77 20 C5 FF  JSR &FFC5        ;call GSREAD
AA7A B0 F5     BCS RA71         ;if end of argument then exit C=1
AA7C 38        SEC              ;else C=1, ambiguous vol spec allowed
AA7D B0 07     BCS RA86         ;jump into parse volume spec
.RA7F                           ;Parse volume spec
AA7F A2 00     LDX #&00         ;x=0, nothing specified
AA81 20 C5 FF  JSR &FFC5        ;call GSREAD
AA84 B0 EB     BCS RA71         ;if end of argument then exit C=1
.RA86
AA86 08        PHP              ;else save ambiguity flag in C
AA87 C9 3A     CMP #&3A         ;is character a colon?
AA89 D0 05     BNE RA90         ;if not then set drive from digit
AA8B 20 C5 FF  JSR &FFC5        ;else call GSREAD
AA8E B0 A4     BCS RA34         ;if ":" by itself then "Bad drive" error
.RA90
AA90 20 F6 A9  JSR R9F6         ;set current drive from ASCII digit
AA93 A2 02     LDX #&02         ;x=2, only drive specified
AA95 20 C5 FF  JSR &FFC5        ;call GSREAD
AA98 B0 0F     BCS RAA9         ;if no more chars return drive, volume=A
AA9A 28        PLP              ;else restore ambig. flag, if not allowed
AA9B 90 07     BCC RAA4         ;then set volume and return current volume
AA9D C9 2A     CMP #&2A         ;else is character an asterisk? if not
AA9F D0 03     BNE RAA4         ;then set volume and return current volume
AAA1 A2 83     LDX #&83         ;else X=&83, drive and ambiguous volume spec
AAA3 60        RTS
.RAA4
AAA4 20 FC A9  JSR R9FC         ;set volume letter from ASCII letter
AAA7 E8        INX              ;x=3, drive and volume specified
AAA8 08        PHP              ;push dummy flag
.RAA9
AAA9 28        PLP              ;discard ambiguity flag
AAAA A5 CF     LDA &CF          ;get current volume and exit
AAAC 60        RTS
                                ;unreachable code
AAAD 20 C5 FF  JSR &FFC5
.RAB0                           ;Set directory from ASCII character
AAB0 C9 2A     CMP #&2A         ;make * an alias of #
AAB2 D0 02     BNE RAB6
AAB4 A9 23     LDA #&23
.RAB6
AAB6 85 CE     STA &CE          ;set as current directory
AAB8 18        CLC
AAB9 60        RTS
.RABA                           ;Convert and validate ASCII drive digit
AABA 38        SEC              ;convert to binary drive no. 0..3
AABB E9 30     SBC #&30
AABD 90 17     BCC RAD6         ;if invalid then raise "Bad drive" error
AABF 48        PHA              ;else save result
AAC0 C9 08     CMP #&08         ;is it more than 8?
AAC2 B0 12     BCS RAD6         ;then invalid as a logical drive, "Bad drive"
AAC4 20 DB AA  JSR RADB         ;else map volume in A to physical volume
AAC7 C9 05     CMP #&05         ;if not physical drive 5, the second RAM disc
AAC9 D0 09     BNE RAD4         ;then accept digit
AACB 20 19 82  JSR P219         ;else get Challenger unit type
AACE 29 03     AND #&03         ;mask bits 1,0
AAD0 C9 02     CMP #&02         ;is a 512 KiB unit attached?
AAD2 D0 02     BNE RAD6         ;if not then phys. drive 5 is a "Bad drive"
.RAD4
AAD4 68        PLA              ;else return logical drive number, N=0
AAD5 60        RTS
.RAD6
AAD6 4C 34 AA  JMP RA34         ;raise "Bad drive" error
.RAD9                           ;Map current volume to physical volume
AAD9 A5 CF     LDA &CF          ;get current volume:
.RADB                           ;Map volume in A to physical volume
AADB 20 75 A8  JSR R875         ;save XY
AADE AA        TAX              ;hold volume in X
AADF 29 F0     AND #&F0         ;mask volume letter in bits 6..4
AAE1 48        PHA              ;save volume letter
AAE2 8A        TXA              ;transfer complete volume to A
AAE3 29 07     AND #&07         ;mask logical drive number in bits 2..0
AAE5 AA        TAX              ;transfer to X for use as index
AAE6 20 07 BE  JSR SE07         ;page in auxiliary workspace
AAE9 BD 00 FD  LDA &FD00,X      ;look up physical drive for logical drive
AAEC BA        TSX              ;transfer stack pointer to X
AAED 1D 01 01  ORA &0101,X      ;apply volume letter saved on top of stack
AAF0 AA        TAX              ;hold result = volume on physical drive
AAF1 68        PLA              ;discard masked volume letter
AAF2 8A        TXA              ;return physical volume in A
AAF3 4C 0C BE  JMP SE0C         ;page in main workspace and exit
                                ;ChADFS ROM call 0
                                ;*CONFIG
AAF6 20 F2 A9  JSR R9F2         ;call GSINIT with C=0
AAF9 D0 36     BNE RB31         ;if argument present then parse it
AAFB 20 D3 A8  JSR R8D3         ;else list mapping. Print "L drv:"
AAFE EQUS "L drv:"
AB04 A2 00     LDX #&00         ;start at logical drive 0:
.RB06
AB06 8A        TXA              ;perform identity mapping to print log.drive
AB07 20 90 AB  JSR RB90         ;print digit and compare X=8
AB0A D0 FA     BNE RB06         ;loop until logical drives 0..7 listed
AB0C 20 D3 A8  JSR R8D3         ;print newline + "P drv:"
AB0F EQUB &0D
AB10 EQUS "P drv:"
AB16 A2 00     LDX #&00         ;start at logical drive 0:
.RB18
AB18 2C FF FD  BIT &FDFF        ;test b6=ChADFS is current FS
AB1B 20 07 BE  JSR SE07         ;page in auxiliary workspace
AB1E BD 00 FD  LDA &FD00,X      ;preload Challenger physical drive mapping
AB21 50 03     BVC RB26         ;if ChADFS is current FS
AB23 BD 08 FD  LDA &FD08,X      ;then replace with ChADFS physical drive
.RB26
AB26 20 0C BE  JSR SE0C         ;page in main workspace
AB29 20 90 AB  JSR RB90         ;print digit and compare X=8
AB2C D0 EA     BNE RB18         ;loop until logical drives 0..7 listed
AB2E 4C 69 84  JMP P469         ;print newline and exit
.RB31                           ;Parse *CONFIG argument
AB31 C9 52     CMP #&52         ;if first character of argument is capital R
AB33 F0 35     BEQ RB6A         ;then reset drive mappings
.RB35
AB35 20 C5 FF  JSR &FFC5        ;else call GSREAD
AB38 20 BA AA  JSR RABA         ;convert and validate ASCII drive digit
AB3B 2C FF FD  BIT &FDFF        ;test b6=ChADFS is current FS
AB3E 50 03     BVC RB43         ;if ChADFS is current FS
AB40 18        CLC              ;then add 8 to A making offset to ChADFS map:
AB41 69 08     ADC #&08
.RB43
AB43 85 B0     STA &B0          ;save offset into drive mapping table
AB45 20 C5 FF  JSR &FFC5        ;call GSREAD
AB48 B0 1D     BCS RB67         ;if only log. drive given then "Syntax" error
AB4A C9 3D     CMP #&3D         ;else is next character "="?
AB4C D0 19     BNE RB67         ;if not then "Syntax" error
AB4E 20 C5 FF  JSR &FFC5        ;else "<drv>="; call GSREAD
AB51 B0 14     BCS RB67         ;if no phys. drive given then "Syntax" error
AB53 20 BA AA  JSR RABA         ;else convert and validate ASCII drive digit
AB56 20 07 BE  JSR SE07         ;page in auxiliary workspace
AB59 A6 B0     LDX &B0          ;restore offset into drive mapping table
AB5B 9D 00 FD  STA &FD00,X      ;save physical drive mapping in table
AB5E 20 0C BE  JSR SE0C         ;page in main workspace
AB61 20 F2 A9  JSR R9F2         ;call GSINIT with C=0
AB64 D0 CF     BNE RB35         ;if argument present then parse it
AB66 60        RTS              ;else exit
.RB67
AB67 4C 6B A5  JMP R56B         ;raise "Syntax: " error
.RB6A                           ;*CONFIG R
AB6A 2C FF FD  BIT &FDFF        ;if b6=1 ChADFS is current FS
AB6D 70 12     BVS RB81         ;then only reset ChADFS mapping, else:
.RB6F                           ;Reset *CONFIG mapping
AB6F 20 07 BE  JSR SE07         ;page in auxiliary workspace
AB72 A2 07     LDX #&07         ;loop for X = 7..0:
.RB74
AB74 8A        TXA
AB75 9D 00 FD  STA &FD00,X      ;configure logical drive X = physical drive X
AB78 CA        DEX
AB79 10 F9     BPL RB74         ;loop until all 8 drive mappings reset
AB7B 4C 0C BE  JMP SE0C         ;page in main workspace and exit
                                ;ChADFS ROM call 3
AB7E 20 6F AB  JSR RB6F         ;reset *CONFIG mapping
.RB81
AB81 20 07 BE  JSR SE07         ;page in auxiliary workspace
AB84 A2 07     LDX #&07         ;loop for X = 7..0:
.RB86
AB86 8A        TXA              ;configure ChADFS mapping drive X = drive X
AB87 9D 08 FD  STA &FD08,X
AB8A CA        DEX
AB8B 10 F9     BPL RB86         ;loop until all 8 drive mappings reset
AB8D 4C 0C BE  JMP SE0C         ;page in main workspace and exit
.RB90
AB90 20 18 A8  JSR R818         ;print a space
AB93 20 80 A9  JSR R980         ;print hex nibble
AB96 E8        INX              ;increment counter
AB97 E0 08     CPX #&08         ;return Z=1 iff counter has reached 8
AB99 60        RTS
.RB9A                           ;Set current vol/dir from open filename
AB9A 20 0C BE  JSR SE0C
AB9D B9 EF FC  LDA &FCEF,Y      ;get directory character of open file
ABA0 29 7F     AND #&7F         ;mask off b7 =channel file locked bit
ABA2 85 CE     STA &CE          ;set as current directory
ABA4 B9 00 FD  LDA &FD00,Y      ;get volume containing open file
ABA7 85 CF     STA &CF          ;set as current volume
ABA9 B9 FF FC  LDA &FCFF,Y      ;get first track of volume of open file
ABAC 8D EC FD  STA &FDEC        ;set as first track of current volume
ABAF B9 F4 FC  LDA &FCF4,Y      ;get packed drive parameters of open file
ABB2 4C 0D 85  JMP P50D         ;restore packed drive parameters and exit
.RBB5                           ;Detect disc format/set sector address
ABB5 20 0C BE  JSR SE0C         ;page in main workspace
ABB8 20 88 AD  JSR RD88         ;claim NMI
ABBB A9 00     LDA #&00
ABBD 85 BA     STA &BA          ;set track number = 0
ABBF 85 BB     STA &BB          ;set sector number = 0
ABC1 20 4C B7  JSR S74C         ;set Z=1 iff current drive is a RAM disc
ABC4 F0 5D     BEQ RC23         ;if not
ABC6 20 16 B9  JSR S916         ;then seek logical track
ABC9 AD E9 FD  LDA &FDE9        ;if data transfer call is not 0 = read data
ABCC 29 7F     AND #&7F
ABCE D0 67     BNE RC37         ;then set sector number = 2 * volume letter
ABD0 A9 00     LDA #&00         ;else data area starts on track 0
ABD2 8D EC FD  STA &FDEC
ABD5 20 46 AC  JSR RC46         ;set number of sectors per track
ABD8 2C ED FD  BIT &FDED        ;test density flag
ABDB 70 03     BVS RBE0         ;if disc is single density
ABDD 20 1A AC  JSR RC1A         ;then ensure volume letter is A
.RBE0
ABE0 2C EA FD  BIT &FDEA        ;if double-stepping is automatic
ABE3 10 03     BPL RBE8
ABE5 20 5D AC  JSR RC5D         ;then detect track stepping
.RBE8
ABE8 2C ED FD  BIT &FDED        ;if disc is single density
ABEB 50 4A     BVC RC37         ;then set sector number = 0
ABED 20 2E B5  JSR S52E         ;else copy volume allocations to wksp
ABF0 20 11 BE  JSR SE11         ;page in catalogue sector 0
ABF3 AD 00 FD  LDA &FD00        ;test configuration/version number
ABF6 C9 E5     CMP #&E5         ;of disc catalogue
ABF8 D0 03     BNE RBFD         ;if byte is &E5 formatting fill byte
ABFA 4C 9F AC  JMP RC9F         ;then "Disk not configured by VOLGEN"
.RBFD
ABFD 20 3C AC  JSR RC3C         ;set sector number = 2 * volume letter
AC00 A8        TAY              ;= offset into the track allocation table
AC01 B9 08 FD  LDA &FD08,Y      ;get first track of volume from disc cat.
AC04 AC 01 FD  LDY &FD01        ;get MSB number of sectors on surface
AC07 AE 02 FD  LDX &FD02        ;get LSB number of sectors on surface
AC0A 20 0C BE  JSR SE0C         ;page in main workspace
AC0D 8E F6 FD  STX &FDF6        ;save in workspace
AC10 8C F5 FD  STY &FDF5
AC13 8D EC FD  STA &FDEC        ;set as first track of current volume
AC16 AA        TAX
AC17 F0 6B     BEQ RC84         ;if =0 raise "Volume . n/a" error
.RC19
AC19 60        RTS
.RC1A                           ;Ensure volume letter is A
AC1A A5 CF     LDA &CF          ;get current volume
AC1C 29 F0     AND #&F0         ;extract volume letter
AC1E F0 F9     BEQ RC19         ;if volume letter is not A
AC20 4C 34 AA  JMP RA34         ;then raise "Bad drive" error
.RC23                           ;Set up for RAM disc
AC23 20 1A AC  JSR RC1A         ;ensure volume letter is A
AC26 AD ED FD  LDA &FDED        ;set density flag to single density
AC29 29 80     AND #&80         ;preserving automatic density setting
AC2B 8D ED FD  STA &FDED
AC2E A9 00     LDA #&00
AC30 8D EB FD  STA &FDEB        ;number of sectors per track is undefined
AC33 8D EC FD  STA &FDEC        ;data area starts on track 0
AC36 60        RTS
.RC37                           ;Set sector number = 2 * volume letter
AC37 AD ED FD  LDA &FDED        ;test density flag
AC3A F0 07     BEQ RC43         ;if single (and manual!) then start sector =0
.RC3C
AC3C A5 CF     LDA &CF          ;else get current volume
AC3E 29 F0     AND #&F0         ;extract volume letter
AC40 4A        LSR A            ;shift right three places
AC41 4A        LSR A            ;to get sector offset of volume catalogue
AC42 4A        LSR A
.RC43
AC43 85 BB     STA &BB          ;set as sector number
AC45 60        RTS
.RC46                           ;Set number of sectors per track
AC46 2C ED FD  BIT &FDED        ;if density setting is automatic
AC49 30 0A     BMI RC55         ;then ensure disc is formatted
AC4B A9 0A     LDA #&0A         ;else set 10 sectors per track
AC4D 50 02     BVC RC51         ;unless disc is double density
AC4F A9 12     LDA #&12         ;in which case set 18 sectors per track
.RC51
AC51 8D EB FD  STA &FDEB
.RC54
AC54 60        RTS
.RC55                           ;Ensure disc is formatted
AC55 20 5F B9  JSR S95F         ;read ID and detect density
AC58 F0 FA     BEQ RC54         ;if record found then exit
AC5A 4C E3 BC  JMP SCE3         ;else raise "Disk not formatted" error.
.RC5D                           ;Detect track stepping
AC5D A9 00     LDA #&00         ;b7=0 manual, b6=0 1:1 stepping
AC5F 8D EA FD  STA &FDEA        ;set stepping flag
AC62 A9 02     LDA #&02         ;track number = 2
AC64 85 BA     STA &BA
AC66 20 B2 B9  JSR S9B2         ;execute Read Address command
AC69 AE 0C 0D  LDX &0D0C        ;get C cylinder number
AC6C A9 C0     LDA #&C0
AC6E CA        DEX              ;is it 1?
AC6F F0 0B     BEQ RC7C         ;then disc is 40 track, set double stepping
AC71 0A        ASL A
AC72 CA        DEX              ;else is it 2?
AC73 F0 07     BEQ RC7C         ;then 1:1 stepping is correct
AC75 CA        DEX              ;else the format is wrong, raise an error
AC76 CA        DEX              ;is the head over logical track 4?
AC77 F0 34     BEQ RCAD         ;if so then raise "80 in 40" error
AC79 4C AF BC  JMP SCAF         ;else raise "Disk fault" error.
.RC7C
AC7C 8D EA FD  STA &FDEA        ;set stepping flag
AC7F A9 00     LDA #&00         ;track number = 0
AC81 85 BA     STA &BA
AC83 60        RTS
.RC84                           ;Raise "Volume . n/a" error
AC84 20 AD A8  JSR R8AD         ;begin error message "Volume "
AC87 EQUB &CD
AC88 EQUS "Volume "
AC8F A5 BB     LDA &BB          ;transfer sector offset to A
AC91 4A        LSR A            ;divide by 2; A=0..7, C=0
AC92 69 41     ADC #&41         ;convert to ASCII character "A".."H"
AC94 20 51 A9  JSR R951         ;print character in A (to error message)
AC97 20 D3 A8  JSR R8D3         ;print " n/a" and raise error
AC9A EQUS " n/a"                ;short for "not allocated"
AC9E EQUB &00
.RC9F
AC9F 20 AD A8  JSR R8AD
ACA2 EQUB &CD
ACA3 EQUS "No config"
ACAC EQUB &00
.RCAD
ACAD 20 AD A8  JSR R8AD
ACB0 EQUB &CD
ACB1 EQUS "80 in 40"
ACB9 EQUB &00
.RCBA                           ;Load disc catalogue L3
ACBA A9 80     LDA #&80         ;data transfer call &80 = read data to JIM
ACBC AE A9 81  LDX &81A9        ;ACBD=LDA #&81
.RCBD                           ;Write disc catalogue L3
ACBD A9 81     LDA #&81         ;data transfer call &81 = write data from JIM
ACBF 20 0C BE  JSR SE0C         ;page in main workspace
ACC2 8D E9 FD  STA &FDE9        ;set data transfer call number
ACC5 A2 03     LDX #&03         ;x = 3 number of attempts allowed:
.RCC7
ACC7 20 A5 96  JSR Q6A5         ;set data pointer to &0200
ACCA A9 10     LDA #&10         ;set sector number = 16
ACCC 85 BB     STA &BB
ACCE A9 00     LDA #&00         ;set track number = 0
ACD0 85 BA     STA &BA
ACD2 85 A0     STA &A0          ;&0100 = 256 bytes to transfer
ACD4 A9 01     LDA #&01
ACD6 85 A1     STA &A1
ACD8 20 18 BA  JSR SA18         ;transfer data to disc L2
ACDB F0 06     BEQ RCE3         ;if command succeeded then exit
ACDD CA        DEX              ;else decrement attempts remaining
ACDE D0 E7     BNE RCC7         ;if not run out then try again
ACE0 4C AF BC  JMP SCAF         ;else raise "Disk fault" error
.RCE3
ACE3 60        RTS
.RCE4                           ;Transfer data and report errors L4
ACE4 20 F0 AC  JSR RCF0         ;transfer data L3
ACE7 8D F3 FD  STA &FDF3        ;store result of transfer
ACEA D0 01     BNE RCED         ;if result >0 then "Disk fault" else exit
ACEC 60        RTS
.RCED
ACED 4C AF BC  JMP SCAF         ;raise "Disk fault" error
.RCF0                           ;Transfer data L3
ACF0 20 75 A8  JSR R875         ;save XY
ACF3 A9 80     LDA #&80
ACF5 85 B9     STA &B9          ;>0 disc operation is interruptible
ACF7 A0 03     LDY #&03         ;set attempt counter to 3
.RCF9
ACF9 AD EB FD  LDA &FDEB        ;get number of sectors per track
ACFC 08        PHP              ;save Z flag
ACFD A6 A3     LDX &A3          ;set X=LSB byte count
ACFF A5 A4     LDA &A4          ;set A=2MSB byte count
AD01 28        PLP              ;restore Z flag
AD02 F0 18     BEQ RD1C         ;if 0 sectors per track then RAM disc, branch
AD04 38        SEC              ;else subtract
AD05 AD EB FD  LDA &FDEB        ;number of sectors per track
AD08 E5 BB     SBC &BB          ;- starting sector
AD0A 85 A0     STA &A0          ;= sectors until end, store temp
AD0C A5 A5     LDA &A5          ;test MSB byte count
AD0E D0 08     BNE RD18         ;if >=64 KiB then transfer rest of track
AD10 A6 A3     LDX &A3          ;else X=LSB byte count
AD12 A5 A4     LDA &A4          ;set A=2MSB byte count
AD14 C5 A0     CMP &A0          ;if transfer ends before end of track
AD16 90 04     BCC RD1C         ;then only transfer byte count, else:
.RD18                           ;transfer rest of track
AD18 A2 00     LDX #&00         ;X=0 byte count is a multiple of 256
AD1A A5 A0     LDA &A0          ;A=number of sectors (not bytes) to transfer:
.RD1C
AD1C 86 A0     STX &A0          ;store LSB byte count
AD1E 85 A1     STA &A1          ;store MSB byte count
AD20 05 A0     ORA &A0          ;test if byte count > 0
AD22 F0 47     BEQ RD6B         ;if no data to transfer then finish
AD24 AD EB FD  LDA &FDEB        ;else test number of sectors per track
AD27 F0 0C     BEQ RD35         ;if 0 sectors per track then RAM disc, branch
AD29 38        SEC              ;else subtract
AD2A A5 BA     LDA &BA          ;track number
AD2C E9 50     SBC #&50         ;- 80
AD2E 90 05     BCC RD35         ;if track number in range 0..79 then proceed
AD30 85 BA     STA &BA          ;else set new track number 80 less
AD32 20 9B AD  JSR RD9B         ;select side 2 of current drive.
.RD35
AD35 20 18 BA  JSR SA18         ;transfer data L2
AD38 D0 32     BNE RD6C         ;if non-zero status then try again
AD3A E6 BA     INC &BA          ;else increment track
AD3C 85 BB     STA &BB          ;next transfer starts at sector 0
AD3E A6 A1     LDX &A1          ;x = ?&A1 = MSB number of bytes transferred
AD40 A5 A0     LDA &A0          ;a = ?&A0 = LSB number of bytes transferred
AD42 2C E9 FD  BIT &FDE9        ;test data transfer call number
AD45 10 03     BPL RD4A         ;if b7=1, transferring to JIM
AD47 8A        TXA              ;then a = ?&A1 = number of pages
AD48 A2 00     LDX #&00         ;x = 0, less than 64 KiB transferred
.RD4A
AD4A 18        CLC              ;add expected transfer size to xfer. address
AD4B 65 A6     ADC &A6          ;(byte address in CPU space,
AD4D 85 A6     STA &A6          ;page address in JIM space)
AD4F 8A        TXA
AD50 65 A7     ADC &A7
AD52 85 A7     STA &A7
AD54 38        SEC              ;subtract expected transfer size
AD55 A5 A3     LDA &A3          ;from 24-bit byte count
AD57 E5 A0     SBC &A0
AD59 85 A3     STA &A3
AD5B A5 A4     LDA &A4
AD5D E5 A1     SBC &A1
AD5F 85 A4     STA &A4
AD61 B0 02     BCS RD65
AD63 C6 A5     DEC &A5
.RD65
AD65 05 A3     ORA &A3          ;test remaining no. bytes to transfer
AD67 05 A5     ORA &A5          ;if no more data to transfer then finish
AD69 D0 8E     BNE RCF9         ;else loop to transfer rest of file.
.RD6B
AD6B 60        RTS
.RD6C
AD6C 88        DEY              ;decrement attempt counter
AD6D D0 8A     BNE RCF9         ;if not tried 3 times then try again
AD6F A8        TAY              ;else Y=A=status>0, return Z=0
AD70 60        RTS
.RD71                           ;Release NMI
AD71 AD DD FD  LDA &FDDD        ;if NMI is not already ours
AD74 10 0C     BPL RD82         ;then exit
AD76 C9 FF     CMP #&FF         ;if Y=&FF no previous owner
AD78 F0 08     BEQ RD82         ;then skip release call
AD7A 29 7F     AND #&7F         ;else Y = ID of previous NMI owner
AD7C A8        TAY
AD7D A2 0B     LDX #&0B         ;service call &0B = NMI release
AD7F 20 EC AD  JSR RDEC         ;call OSBYTE &8F = issue service call
.RD82
AD82 A9 00     LDA #&00
AD84 8D DD FD  STA &FDDD        ;&00 = NMI not ours, no previous owner
AD87 60        RTS
.RD88                           ;Claim NMI
AD88 2C DD FD  BIT &FDDD        ;if NMI is already ours
AD8B 30 0D     BMI RD9A         ;then exit
AD8D A9 8F     LDA #&8F         ;else OSBYTE &8F = issue service call
AD8F A2 0C     LDX #&0C         ;service call &0C = claim NMI
AD91 20 F4 AD  JSR RDF4         ;call OSBYTE with Y=&FF
AD94 98        TYA              ;save ID of previous NMI owner
AD95 09 80     ORA #&80         ;set b7=1 to show we own the NMI
AD97 8D DD FD  STA &FDDD        ;set NMI ownership flag/previous owner
.RD9A
AD9A 60        RTS
.RD9B                           ;Select side 2 of current drive
AD9B 20 D9 AA  JSR RAD9         ;map current drive to physical drive
AD9E AA        TAX              ;transfer to X for use as index
AD9F 20 07 BE  JSR SE07         ;page in auxiliary workspace
ADA2 BD B7 AD  LDA &ADB7,X      ;look up side 2 of physical drive
ADA5 A2 07     LDX #&07         ;loop for logical drives 7..0:
.RDA7
ADA7 DD 00 FD  CMP &FD00,X      ;does this drive map to the drive we want?
ADAA F0 06     BEQ RDB2         ;if so then set current logical drive
ADAC CA        DEX              ;else try next logical drive
ADAD 10 F8     BPL RDA7         ;loop until all 8 logical drives tested
ADAF 4C 34 AA  JMP RA34         ;if physical drive not mapped "Bad drive"
.RDB2
ADB2 86 CF     STX &CF          ;else set current drive = logical drive
ADB4 4C 0C BE  JMP SE0C         ;page in main workspace and exit
;Side 2 of physical drives 0..4
ADB7 EQUB &02
ADB8 EQUB &03
ADB9 EQUB &FF                   ;invalid, raise "Bad drive" error
ADBA EQUB &FF                   ;invalid, raise "Bad drive" error
ADBB EQUB &05
;next three bytes more than 7, invalid physical drives
.RDBC                           ;Test write protect state of current drive
ADBC 20 D9 AA  JSR RAD9         ;map current drive to physical drive
ADBF 4C 05 B9  JMP S905         ;test write protect state of current drive
.RDC2                           ;Flush input buffer
ADC2 20 4C A8  JSR R84C         ;save AXY
ADC5 A9 0F     LDA #&0F         ;OSBYTE &0F = flush selected buffer class
ADC7 A2 01     LDX #&01         ;x = &01 flush input buffer only
ADC9 D0 08     BNE RDD3         ;call OSBYTE with Y=&00
                                ;unreachable code
ADCB A9 81     LDA #&81         ;OSBYTE &81 = read key within time limit
ADCD D0 02     BNE RDD1
                                ;unreachable code
ADCF A9 C7     LDA #&C7         ;OSBYTE &C7 = read/write *SPOOL handle
.RDD1
                                ;Call OSBYTE with X=&00, Y=&00
ADD1 A2 00     LDX #&00
.RDD3                           ;Call OSBYTE with Y=&00
ADD3 A0 00     LDY #&00
ADD5 F0 1F     BEQ RDF6
.RDD7
ADD7 AA        TAX              ;Call OSBYTE &03 = specify output stream in A
.RDD8
ADD8 A9 03     LDA #&03         ;Call OSBYTE &03 = specify output stream
ADDA D0 1A     BNE RDF6
.RDDC                           ;Call OSBYTE &EC = read/write char dest status
ADDC A9 EC     LDA #&EC
ADDE D0 12     BNE RDF2
                                ;unreachable code
ADE0 A9 C7     LDA #&C7         ;OSBYTE &C7 = read/write *SPOOL handle
ADE2 D0 0E     BNE RDF2
.RDE4                           ;Call OSBYTE &EA = read Tube presence flag
ADE4 A9 EA     LDA #&EA
ADE6 D0 0A     BNE RDF2
.RDE8                           ;Call OSBYTE &A8 = get ext. vector table addr
ADE8 A9 A8     LDA #&A8
ADEA D0 06     BNE RDF2
.RDEC                           ;Call OSBYTE &8F = issue service call
ADEC A9 8F     LDA #&8F
ADEE D0 06     BNE RDF6
.RDF0                           ;Call OSBYTE &FF = read/write startup options
ADF0 A9 FF     LDA #&FF
.RDF2                           ;Call OSBYTE with X=&00, Y=&FF
ADF2 A2 00     LDX #&00
.RDF4                           ;Call OSBYTE with Y=&FF
ADF4 A0 FF     LDY #&FF
.RDF6                           ;Call OSBYTE
ADF6 4C F4 FF  JMP &FFF4
;Table of addresses of extended vector handlers
ADF9 EQUW &1B,&FF               ;FILEV,         &0212 =         &FF1B
ADFB EQUW &1E,&FF               ;ARGSV,         &0214 =         &FF1E
ADFD EQUW &21,&FF               ;BGETV,         &0216 =         &FF21
ADFF EQUW &24,&FF               ;BPUTV,         &0218 =         &FF24
AE01 EQUW &27,&FF               ;GBPBV,         &021A =         &FF27
AE03 EQUW &2A,&FF               ;FINDV,         &021C =         &FF2A
AE05 EQUW &2D,&FF               ;FSCV,          &021E =         &FF2D
;Table of action addresses for extended vector table
AE07 EQUW &6E,&A1               ;E FILEV,       evt + &1B =     &A16E
AE09 EQUW &62,&9B               ;E ARGSV,       evt + &1E =     &9B62
AE0B EQUW &D1,&9C               ;E BGETV,       evt + &21 =     &9CD1
AE0D EQUW &9E,&9D               ;E BPUTV,       evt + &24 =     &9D9E
AE0F EQUW &DC,&A2               ;E GBPBV,       evt + &27 =     &A2DC
AE11 EQUW &61,&99               ;E FINDV,       evt + &2A =     &9961
AE13 EQUW &5F,&97               ;E FSCV,        evt + &2D =     &975F
;Table of action addresses for OSFSC calls 0..11, low bytes
AE15 EQUB &74
AE16 EQUB &07                   ;OSFSC  1 = read EOF state      &9808
AE17 EQUB &1F                   ;OSFSC  2 = */                  &9820
AE18 EQUB &9B                   ;OSFSC  3 = unrecognised *cmd   &989C
AE19 EQUB &1F                   ;OSFSC  4 = *RUN                &9820
AE1A EQUB &AD                   ;OSFSC  5 = *CAT                &98AE
AE1B EQUB &04                   ;OSFSC  6 = new FS starting up  &9905
AE1C EQUB &16                   ;OSFSC  7 = valid file handles  &9917
AE1D EQUB &1B
AE1E EQUB &0A                   ;OSFSC  9 = *EX                 &8C0B
AE1F EQUB &18                   ;OSFSC 10 = *INFO               &8C19
AE20 EQUB &1F                   ;OSFSC 11 = *RUN from library   &9820
;Table of action addresses for OSFSC calls 0..11, high bytes
AE21 EQUB &97
AE22 EQUB &98
AE23 EQUB &98
AE24 EQUB &98
AE25 EQUB &98
AE26 EQUB &98
AE27 EQUB &99
AE28 EQUB &99
AE29 EQUB &99
AE2A EQUB &8C
AE2B EQUB &8C
AE2C EQUB &98
;Table of action addresses for OSARGS calls A=&FF,0,1, Y=0, low bytes
AE2D EQUB &A1
AE2E EQUB &8B                   ;OSARGS   0 = return FS number  &9B8C
AE2F EQUB &8E                   ;OSARGS   1 = command line tail &9B8F
;Table of action addresses for OSARGS calls A=&FF,0,1, Y=0, high bytes
AE30 EQUB &9B
AE31 EQUB &9B
AE32 EQUB &9B
;Table of action addresses for OSFILE calls &FF,0..6, low bytes
AE33 EQUB &EE
AE34 EQUB &9F                   ;OSFILE   0 = save file         &A1A0
AE35 EQUB &AF                   ;OSFILE   1 = wr. catalog info  &A1B0
AE36 EQUB &BA                   ;OSFILE   2 = wr. load address  &A1BB
AE37 EQUB &C2                   ;OSFILE   3 = wr. exec address  &A1C3
AE38 EQUB &CA                   ;OSFILE   4 = wr. attributes    &A1CB
AE39 EQUB &D9                   ;OSFILE   5 = read catalog info &A1DA
AE3A EQUB &E2                   ;OSFILE   6 = delete file       &A1E3
;Table of action addresses for OSFILE calls &FF,0..6, high bytes
AE3B EQUB &A1
AE3C EQUB &A1
AE3D EQUB &A1
AE3E EQUB &A1
AE3F EQUB &A1
AE40 EQUB &A1
AE41 EQUB &A1
AE42 EQUB &A1
;Table of action addresses for OSGBPB calls 0..8, low bytes
AE43 EQUB &9B
AE44 EQUB &9C                   ;OSGBPB 1 = set PTR and write   &A39C
AE45 EQUB &9C                   ;OSGBPB 2 = write data          &A39C
AE46 EQUB &A4                   ;OSGBPB 3 = set PTR and read    &A3A4
AE47 EQUB &A4                   ;OSGBPB 4 = read data           &A3A4
AE48 EQUB &AC                   ;OSGBPB 5 = read title/opt/drv  &A3AC
AE49 EQUB &E1                   ;OSGBPB 6 = read CSD drv/dir    &A3E1
AE4A EQUB &F0                   ;OSGBPB 7 = read lib'y drv/dir  &A3F0
AE4B EQUB &FF
;Table of action addresses for OSGBPB calls 0..8, high bytes
AE4C EQUB &A3
AE4D EQUB &A3
AE4E EQUB &A3
AE4F EQUB &A3
AE50 EQUB &A3
AE51 EQUB &A3
AE52 EQUB &A3
AE53 EQUB &A3
AE54 EQUB &A3
;Table of microcode bytes for OSGBPB calls 0..8
AE55 EQUB &04
AE56 EQUB &02                   ;%000000 1 0 from memory, xfer data, set PTR
AE57 EQUB &03                   ;%000000 1 1 from memory, xfer data, leave PTR
AE58 EQUB &06                   ;%000001 1 0 to memory,   xfer data, set PTR
AE59 EQUB &07                   ;%000001 1 1 to memory,   xfer data, leave PTR
AE5A EQUB &04                   ;%000001 0 . to memory,   special handler
AE5B EQUB &04                   ;%000001 0 . to memory,   special handler
AE5C EQUB &04                   ;%000001 0 . to memory,   special handler
AE5D EQUB &04
.RE5E                           ;Print Challenger banner
AE5E 08        PHP              ;save C on entry
AE5F 20 D3 A8  JSR R8D3         ;print "CHALLENGER "
AE62 EQUS "CHALLENGER "
AE6D EA        NOP
AE6E 28        PLP              ;restore C
AE6F B0 09     BCS RE7A         ;if C=0 on entry
AE71 20 D3 A8  JSR R8D3         ;then print version number "2.00 "
AE74 EQUS "2.00 "
AE79 EA        NOP
.RE7A
AE7A 20 19 82  JSR P219         ;get Challenger unit type
AE7D 29 03     AND #&03         ;extract bits 1,0
AE7F 09 04     ORA #&04         ;add 4 to make 4..7
AE81 AA        TAX              ;transfer to X to select message
AE82 20 F7 8F  JSR PFF7         ;print boot or Challenger config descriptor
AE85 4C 69 84  JMP P469         ;print newline and exit
                                ;*FORMAT
AE88 20 F2 A9  JSR R9F2         ;call GSINIT with C=0
AE8B F0 17     BEQ REA4         ;if no argument then skip
.RE8D
AE8D 20 C5 FF  JSR &FFC5        ;else call GSREAD
AE90 90 04     BCC RE96         ;type character of argument if present
AE92 A9 0D     LDA #&0D         ;else end of argument, type RETURN
AE94 A0 00     LDY #&00         ;offset = 0, indicate end of argument
.RE96
AE96 84 B7     STY &B7          ;save command line offset
AE98 A8        TAY              ;transfer character of argument to Y
AE99 A2 00     LDX #&00         ;x=&00 insert into keyboard buffer
AE9B A9 99     LDA #&99         ;OSBYTE &99 = insert char into buffer ck/ESC
AE9D 20 F4 FF  JSR &FFF4        ;call OSBYTE
AEA0 A4 B7     LDY &B7          ;restore command line offset
AEA2 D0 E9     BNE RE8D         ;loop until argument inserted in buffer
.REA4
AEA4 20 3F A8  JSR R83F         ;have A=0 returned on exit
AEA7 BA        TSX
AEA8 86 B7     STX &B7          ;set stack pointer to restore on restart
AEAA 86 B8     STX &B8          ;set stack pointer to restore on exit
AEAC 20 9C 95  JSR Q59C         ;set high word of buffer address = &FFFF
                                ;command restart point set at &AEE5
AEAF 20 1D B0  JSR S01D         ;set command restart to exit command
AEB2 20 B2 B2  JSR S2B2         ;print "FORMAT" heading
.REB5
AEB5 20 DE B2  JSR S2DE         ;clear row 23
.REB8
AEB8 20 17 A9  JSR R917         ;print VDU sequence immediate
AEBB EQUB &1F                   ;move cursor to (0,19)
AEBC EQUB &00
AEBD EQUB &13
AEBE EQUS "Drive number (0-7) "
AED1 EQUB &FF
AED2 20 CB B5  JSR S5CB         ;get printable input character
AED5 38        SEC              ;convert to binary drive no. 0..7
AED6 E9 30     SBC #&30         ;is it less than ASCII "0"?
AED8 90 DE     BCC REB8         ;if so then input new drive number
AEDA C9 08     CMP #&08         ;is drive number in range?
AEDC 90 05     BCC REE3         ;if so then proceed
AEDE 20 3C B7  JSR S73C         ;else make a short beep
AEE1 D0 D2     BNE REB5         ;and input new drive number
.REE3
AEE3 85 CF     STA &CF          ;set as current volume
.REE5
AEE5 A2 AF     LDX #&AF         ;point XY at *FORMAT entry point, &AEAF
AEE7 A0 AE     LDY #&AE
AEE9 20 21 B0  JSR S021         ;set command restart action address
AEEC 20 17 A9  JSR R917         ;print VDU sequence immediate
AEEF EQUB &1F                   ;move cursor to (0,20)
AEF0 EQUB &00
AEF1 EQUB &14
AEF2 EQUS "0=40, 1=80 tracks :  "
AF07 EQUB &7F
AF08 EQUB &7F
AF09 EQUB &FF
AF0A 20 4C B7  JSR S74C         ;set Z=1 iff current drive is a RAM disc
AF0D D0 03     BNE RF12         ;if so
AF0F 4C B7 AF  JMP RFB7         ;then format RAM disc
.RF12
AF12 20 CB B5  JSR S5CB         ;else get printable input character
AF15 A2 28     LDX #&28         ;set X = 40 tracks
AF17 C9 30     CMP #&30         ;if user typed 0
AF19 F0 06     BEQ RF21         ;then proceed with 40 track format
AF1B A2 50     LDX #&50         ;else set X = 80 tracks
AF1D C9 31     CMP #&31         ;if user typed 1 then format 80 tracks
AF1F D0 C4     BNE REE5         ;else invalid character, prompt again
.RF21
AF21 86 C0     STX &C0          ;set number of tracks to format
AF23 A2 50     LDX #&50         ;80 tracks maximum can be formatted
AF25 AD EA FD  LDA &FDEA        ;test double-stepping flag
AF28 10 05     BPL RF2F         ;if double-stepping is automatic
AF2A 29 80     AND #&80         ;then discard last detected setting
AF2C 8D EA FD  STA &FDEA        ;and force 1:1 stepping
.RF2F
AF2F 2C EA FD  BIT &FDEA        ;(else) test double-stepping flag
AF32 50 02     BVC RF36         ;if *OPT 8,1, forced double-stepping
AF34 A2 28     LDX #&28         ;then maximum format is 40 tracks.
.RF36
AF36 E4 C0     CPX &C0          ;compare max - chosen number of tracks
AF38 B0 05     BCS RF3F         ;if max >= number chosen then proceed
AF3A 20 3C B7  JSR S73C         ;else make a short beep
AF3D D0 A6     BNE REE5         ;and input new format size
.RF3F
AF3F 20 DE B2  JSR S2DE         ;clear row 23
.RF42
AF42 20 17 A9  JSR R917         ;print VDU sequence immediate
AF45 EQUB &1F                   ;move cursor to (0,21)
AF46 EQUB &00
AF47 EQUB &15
AF48 EQUS "Density (S/D) "
AF56 EQUB &FF
AF57 20 CB B5  JSR S5CB         ;get printable input character
AF5A C9 53     CMP #&53         ;is it capital S?
AF5C F0 38     BEQ RF96         ;if so then format single density
AF5E C9 44     CMP #&44         ;else is it capital D?
AF60 F0 06     BEQ RF68         ;if so then format double density
AF62 20 3C B7  JSR S73C         ;else make a short beep
AF65 4C 42 AF  JMP RF42         ;and re-input
.RF68                           ;Format double density
AF68 AD ED FD  LDA &FDED        ;set double density
AF6B 09 40     ORA #&40         ;preserve automatic setting bit 7
AF6D 8D ED FD  STA &FDED        ;set double density bit 6
AF70 A9 12     LDA #&12         ;set 18 sectors per track
AF72 8D EB FD  STA &FDEB
AF75 20 5C B6  JSR S65C         ;prompt user and start format
AF78 B0 14     BCS RF8E         ;if failed then prompt to repeat
AF7A A6 C0     LDX &C0          ;else get number of tracks on disc
AF7C CA        DEX              ;all but one track available for volumes
AF7D 86 B0     STX &B0          ;set multiplicand
AF7F 20 52 B5  JSR S552         ;multiply by no. sectors per track
AF82 20 12 B4  JSR S412         ;set default volume sizes
AF85 20 5E B4  JSR S45E         ;write volume catalogues
AF88 20 77 B4  JSR S477         ;generate disc catalogue
AF8B 20 BD AC  JSR RCBD         ;write disc catalogue L3
.RF8E
AF8E 20 35 B0  JSR S035         ;prompt to repeat
AF91 F0 D5     BEQ RF68         ;if user chooses repeat then format another
AF93 4C 28 B0  JMP S028         ;else exit command
.RF96                           ;Format single density
AF96 AD ED FD  LDA &FDED        ;set single density
AF99 29 80     AND #&80         ;preserve automatic setting bit 7
AF9B 8D ED FD  STA &FDED        ;clear double density bit 6
AF9E A9 0A     LDA #&0A         ;set 10 sectors per track
AFA0 8D EB FD  STA &FDEB
AFA3 20 5C B6  JSR S65C         ;prompt user and start format
AFA6 B0 07     BCS RFAF         ;if failed then prompt to repeat
AFA8 A6 C0     LDX &C0          ;else get number of tracks on disc
AFAA 86 B0     STX &B0          ;set multiplicand
AFAC 20 5B B0  JSR S05B         ;initialise volume catalogue by no. tracks
.RFAF
AFAF 20 35 B0  JSR S035         ;prompt to repeat
AFB2 F0 E2     BEQ RF96         ;if user chooses repeat then format another
AFB4 4C 28 B0  JMP S028         ;else exit command
.RFB7                           ;format RAM disc
AFB7 20 17 A9  JSR R917         ;print VDU sequence immediate
AFBA EQUB &7F                   ;delete " :"
AFBB EQUB &7F
AFBC EQUS ", 2=Max RAM disk "
AFCD EQUB &FF
AFCE 20 CB B5  JSR S5CB         ;get printable input character
AFD1 38        SEC              ;convert to binary option 0..2
AFD2 E9 30     SBC #&30
AFD4 90 1C     BCC RFF2         ;if invalid character then prompt again
AFD6 C9 03     CMP #&03         ;else is option in range?
AFD8 B0 18     BCS RFF2         ;if not 0..2 then prompt again
AFDA 48        PHA              ;else save option
AFDB 20 1B B6  JSR S61B         ;prompt to start format
AFDE 68        PLA              ;restore option
AFDF AA        TAX
AFE0 E0 02     CPX #&02         ;if 40 or 80 track format selected
AFE2 D0 08     BNE RFEC         ;then format to that size
AFE4 20 D9 AA  JSR RAD9         ;else map current volume to physical volume
AFE7 C9 05     CMP #&05         ;if formatting drive 4
AFE9 D0 01     BNE RFEC         ;then use option 2, size = &3F5 sectors
AFEB E8        INX              ;else use option 3, size = &3FF sectors
.RFEC
AFEC 20 F8 AF  JSR RFF8         ;initialise RAM disc catalogue
AFEF 4C 28 B0  JMP S028         ;exit command
.RFF2
AFF2 20 3C B7  JSR S73C         ;make a short beep
AFF5 4C E5 AE  JMP REE5         ;and input new volume size option
.RFF8                           ;Initialise RAM disc catalogue
AFF8 BD 15 B0  LDA &B015,X      ;look up LSB of selected volume size
AFFB 85 C4     STA &C4
AFFD BD 19 B0  LDA &B019,X      ;and MSB
B000 85 C5     STA &C5
B002 20 88 AD  JSR RD88         ;claim NMI
B005 A9 00     LDA #&00
B007 8D FE FD  STA &FDFE        ;b6=0 RAM disc is single density
B00A 8D ED FD  STA &FDED        ;*OPT 6,10 single density
B00D A0 00     LDY #&00         ;write catalogue to sector 0
B00F 20 62 B0  JSR S062         ;initialise volume catalogue
B012 4C 71 AD  JMP RD71         ;release NMI
;Table of single density volume sizes, X=0..3, low bytes
B015 EQUB &90
B016 EQUB &20                   ;x=1, 80 track disc, &0320 sectors, 200 KiB
B017 EQUB &F5                   ;x=2, RAM disc 4,    &03F5 sectors, 253 KiB
B018 EQUB &FF                   ;x=3, RAM disc 5,    &03FF sectors, 255 KiB
;Table of single density volume sizes, X=0..3, high bytes
B019 EQUB &01
B01A EQUB &03
B01B EQUB &03
B01C EQUB &03
.S01D                           ;Set command restart to exit command
B01D A2 28     LDX #&28         ;point XY at command exit routine, &B028
B01F A0 B0     LDY #&B0
.S021                           ;Set command restart action address
B021 8E E6 FD  STX &FDE6
B024 8C E7 FD  STY &FDE7
B027 60        RTS
.S028                           ;Exit command
B028 A6 B8     LDX &B8          ;restore stack pointer from workspace
B02A 9A        TXS
B02B 20 50 B6  JSR S650         ;clear rows 20..22
B02E A2 00     LDX #&00         ;set XY to screen coordinates (0,24)
B030 A0 18     LDY #&18
B032 4C D1 B2  JMP S2D1         ;move cursor to (X,Y)
.S035                           ;Prompt to repeat
B035 20 17 A9  JSR R917         ;print VDU sequence immediate
B038 EQUB &1F                   ;move cursor to (8,16)
B039 EQUB &08
B03A EQUB &10
B03B EQUS "Format complete"
B04A EQUB &0D
B04B EQUB &0A
B04C EQUS "Repeat? "
B054 EQUB &FF
B055 20 EE B5  JSR S5EE         ;get input character and acknowledge ESCAPE
B058 C9 59     CMP #&59         ;return Z=1 iff user typed capital Y
B05A 60        RTS
.S05B                           ;Initialise volume catalogue by no. tracks
B05B 20 52 B5  JSR S552         ;multiply by no. sectors per track
B05E A0 00     LDY #&00         ;sector number = 0
B060 84 BA     STY &BA          ;set track number = 0
.S062                           ;Initialise volume catalogue
B062 20 4C A8  JSR R84C         ;save AXY
B065 84 BB     STY &BB          ;set LSB absolute LBA = 2 * volume letter
B067 A9 00     LDA #&00
B069 85 BA     STA &BA          ;set MSB of absolute LBA = 0
B06B 20 EA B3  JSR S3EA         ;clear catalogue sectors
B06E 20 16 BE  JSR SE16         ;page in catalogue sector 1
B071 A5 C5     LDA &C5          ;set MSB volume size, boot option OFF
B073 8D 06 FD  STA &FD06
B076 A5 C4     LDA &C4          ;set LSB volume size
B078 8D 07 FD  STA &FD07
B07B 4C 83 96  JMP Q683         ;write disc/volume catalogue L3
                                ;*VERIFY
B07E 20 41 B7  JSR S741         ;parse floppy volume spec from argument
B081 BA        TSX
B082 86 B8     STX &B8          ;set stack pointer to restore on exit
B084 86 B7     STX &B7          ;set stack pointer to restore on restart
B086 20 3F A8  JSR R83F         ;have A=0 returned on exit
B089 20 9C 95  JSR Q59C         ;set high word of OSFILE load address = &FFFF
                                ;command restart point set at &B0B6
B08C 20 1D B0  JSR S01D         ;set command restart to exit command
B08F 20 58 B7  JSR S758         ;set display MODE 7 and place heading
B092 20 17 A9  JSR R917         ;print VDU sequence immediate
B095 EQUS "V E R I F Y"
B0A0 EQUB &FF
B0A1 20 17 A9  JSR R917         ;print VDU sequence immediate
B0A4 EQUB &1F                   ;move cursor to (0,10)
B0A5 EQUB &00
B0A6 EQUB &10
B0A7 EQUS "Insert disk"
B0B2 EQUB &FF
B0B3 20 06 B7  JSR S706         ;prompt for keypress
B0B6 A2 8C     LDX #&8C         ;point XY at *VERIFY entry point, &B08C
B0B8 A0 B0     LDY #&B0
B0BA 20 21 B0  JSR S021         ;set command restart action address
B0BD A9 00     LDA #&00
B0BF 8D E9 FD  STA &FDE9        ;data transfer call &00 = read data
B0C2 A9 80     LDA #&80
B0C4 85 B9     STA &B9          ;>0 disc operation is interruptible
B0C6 20 B5 AB  JSR RBB5         ;detect disc format/set sector address
B0C9 2C ED FD  BIT &FDED        ;test density flag
B0CC 70 26     BVS S0F4         ;if double density then examine disc catalog
B0CE 20 32 96  JSR Q632         ;else load volume catalogue
B0D1 20 16 BE  JSR SE16         ;page in catalogue sector 1
B0D4 AD 06 FD  LDA &FD06        ;get boot option/top bits volume size
B0D7 29 03     AND #&03         ;extract top bits volume size
B0D9 85 B1     STA &B1          ;store MSB of dividend
B0DB AD 07 FD  LDA &FD07        ;get LSB volume size
B0DE 85 B0     STA &B0          ;store LSB of dividend
B0E0 20 0C BE  JSR SE0C         ;page in main workspace
B0E3 A9 00     LDA #&00
B0E5 85 B3     STA &B3          ;clear MSB of divisor
B0E7 AD EB FD  LDA &FDEB        ;get number of sectors per track (= 10)
B0EA 85 B2     STA &B2          ;store LSB of divisor
B0EC 20 5F B3  JSR S35F         ;divide word by word
B0EF 86 C0     STX &C0          ;store quotient as number of tracks
B0F1 4C FF B0  JMP S0FF         ;verify disc
.S0F4
B0F4 20 BA AC  JSR RCBA         ;load disc catalogue L3
B0F7 20 11 BE  JSR SE11         ;page in catalogue sector 0
B0FA AD 04 FD  LDA &FD04        ;get number of tracks on disc
B0FD 85 C0     STA &C0          ;store number of tracks to verify
.S0FF                           ;Verify disc
B0FF 20 0C BE  JSR SE0C         ;page in main workspace
B102 A9 00     LDA #&00
B104 85 BA     STA &BA          ;set starting track = 0
B106 18        CLC              ;set C=0, no error
.S107
B107 08        PHP
B108 20 B3 B6  JSR S6B3         ;print track number in table
B10B 20 21 B1  JSR S121         ;verify track with display
B10E F0 03     BEQ S113         ;if hard error occurred
B110 28        PLP              ;then set C=1, verify failed
B111 38        SEC
B112 08        PHP
.S113
B113 E6 BA     INC &BA          ;increment track number
B115 A5 BA     LDA &BA          ;compare track number - number of tracks
B117 C5 C0     CMP &C0
B119 90 EC     BCC S107         ;if less then verify next track
B11B 28        PLP              ;else test return code
B11C B0 1C     BCS S13A         ;if error occurred print "ERROR"
B11E 4C 28 B0  JMP S028         ;else exit command.
.S121                           ;Verify track with display
B121 A2 03     LDX #&03         ;make 3 attempts
B123 A0 03     LDY #&03         ;erase next 3 characters
B125 20 2C B7  JSR S72C         ;erase Y characters ahead of cursor
.S128
B128 20 EA B2  JSR S2EA         ;poll for ESCAPE
B12B 20 05 BA  JSR SA05         ;verify track
B12E F0 09     BEQ S139         ;if verify succeeded then exit
B130 A9 2E     LDA #&2E         ;else print a dot
B132 20 EE FF  JSR &FFEE        ;call OSWRCH
B135 CA        DEX              ;decrement attempt counter
B136 D0 F0     BNE S128         ;if attempts remaining then try again
B138 CA        DEX              ;else X=&FF, Z=0 to indicate failure
.S139
B139 60        RTS
.S13A
B13A 20 0B B6  JSR S60B         ;print "ERROR"
B13D 4C 28 B0  JMP S028         ;and exit command.
                                ;*VOLGEN
B140 20 41 B7  JSR S741         ;parse floppy volume spec from argument
B143 20 3F A8  JSR R83F         ;have A=0 returned on exit
B146 BA        TSX
B147 86 B8     STX &B8          ;set stack pointer to restore on exit
B149 20 5F A7  JSR R75F         ;ensure *ENABLE active
B14C 20 9C 95  JSR Q59C         ;set high word of OSFILE load address = &FFFF
B14F A9 80     LDA #&80
B151 85 B9     STA &B9          ;>0 disc operation is interruptible
B153 A9 00     LDA #&00
B155 8D EC FD  STA &FDEC        ;data area starts on track 0
B158 85 BA     STA &BA          ;set track number = 0
B15A 20 16 B9  JSR S916         ;seek logical track
B15D 20 79 B2  JSR S279         ;ensure disc is double density
B160 A5 CF     LDA &CF          ;get current volume
B162 29 0F     AND #&0F         ;extract physical drive number, clear b7..4
B164 85 CF     STA &CF          ;set current volume letter to A
B166 20 58 B7  JSR S758         ;set display MODE 7 and place heading
B169 20 17 A9  JSR R917         ;print VDU sequence immediate
B16C EQUS "V O L G E N"
B177 EQUB &FF
B178 20 17 A9  JSR R917         ;print VDU sequence immediate
B17B EQUB &1F                   ;move cursor to (0,4)
B17C EQUB &00
B17D EQUB &04
B17E EQUB &0D
B17F EQUS "Vol  Size   (K) "
B18F EQUB &FF
B190 A5 CF     LDA &CF          ;get current volume
B192 20 AD 8E  JSR PEAD         ;print " Drive " plus volume spec in A
B195 20 17 A9  JSR R917         ;print VDU sequence immediate
B198 EQUB &1F                   ;move cursor to (0,15)
B199 EQUB &00
B19A EQUB &0F
B19B EQUS "Free"
B19F EQUB &FF
B1A0 20 D2 B4  JSR S4D2         ;read volume sizes and allocations
B1A3 A9 07     LDA #&07         ;8 volumes to list
B1A5 85 C1     STA &C1          ;set as counter
.S1A7
B1A7 20 BC B3  JSR S3BC         ;print tabulated volume size
B1AA C6 C1     DEC &C1          ;loop until 8 volumes listed
B1AC 10 F9     BPL S1A7
.S1AE                           ;command restart point set at &B255
B1AE 20 1D B0  JSR S01D         ;set command restart to exit command
.S1B1
B1B1 20 6D B5  JSR S56D         ;sum volume sizes
B1B4 A2 05     LDX #&05         ;move cursor to (5,15)
B1B6 A0 0F     LDY #&0F
B1B8 20 D1 B2  JSR S2D1
B1BB 20 80 B3  JSR S380         ;print sector count as kilobytes
B1BE 4C C4 B1  JMP S1C4
.S1C1
B1C1 20 3C B7  JSR S73C         ;make a short beep
.S1C4
B1C4 20 17 A9  JSR R917         ;print VDU sequence immediate
B1C7 EQUB &1F                   ;move cursor to (0,23)
B1C8 EQUB &00
B1C9 EQUB &17
B1CA EQUS "VOLUME :      (W to configure)"
B1E8 EQUB &1F                   ;move cursor to (8,23)
B1E9 EQUB &08
B1EA EQUB &17
B1EB EQUB &FF
B1EC 20 EE B5  JSR S5EE         ;get input character and acknowledge ESCAPE
B1EF C9 57     CMP #&57         ;if user typed capital W
B1F1 D0 03     BNE S1F6
B1F3 4C 55 B2  JMP S255         ;then generate volumes and exit
.S1F6
B1F6 38        SEC              ;else convert letter A..H to volume index 0..7
B1F7 E9 41     SBC #&41
B1F9 90 C6     BCC S1C1         ;if out of range then display error
B1FB C9 08     CMP #&08
B1FD B0 C2     BCS S1C1
B1FF 85 C1     STA &C1          ;else set volume index
B201 69 41     ADC #&41         ;convert back to letter A..H, print it
B203 20 EE FF  JSR &FFEE        ;call OSWRCH
B206 A9 20     LDA #&20         ;print a space
B208 20 EE FF  JSR &FFEE        ;call OSWRCH
B20B 20 05 B3  JSR S305         ;input number up to 3 digits
B20E B0 B4     BCS S1C4         ;if invalid input then prompt again
B210 A5 AA     LDA &AA          ;else test entered volume size
B212 05 AB     ORA &AB
B214 D0 0D     BNE S223         ;if >0 then set volume size
B216 A5 C1     LDA &C1          ;else RETURN pressed, delete volume
B218 F0 A7     BEQ S1C1         ;volume A can't be deleted, prompt again
B21A 20 A2 B2  JSR S2A2         ;else clear volume size
B21D 20 BC B3  JSR S3BC         ;print tabulated volume size
B220 4C B1 B1  JMP S1B1         ;update free space and take next command.
.S223                           ;Fit volume request
B223 A5 AB     LDA &AB          ;test MSB of entered number
B225 C9 04     CMP #&04         ;if <256 KiB requested then continue
B227 B0 98     BCS S1C1         ;else display error and prompt again
B229 20 A2 B2  JSR S2A2         ;clear volume size
B22C 20 6D B5  JSR S56D         ;sum volume sizes
B22F A5 A8     LDA &A8          ;compare free space - request
B231 C5 AA     CMP &AA
B233 A5 A9     LDA &A9
B235 E5 AB     SBC &AB
B237 B0 08     BCS S241         ;if request fits then assign request
B239 A5 A8     LDA &A8          ;else set request = free space on disc
B23B 85 AA     STA &AA
B23D A5 A9     LDA &A9
B23F 85 AB     STA &AB
.S241
B241 A5 C1     LDA &C1          ;get volume index
B243 0A        ASL A            ;double it
B244 A8        TAY              ;transfer to Y as index
B245 A5 AB     LDA &AB          ;set assigned volume size
B247 99 D5 FD  STA &FDD5,Y      ;= min(request, free_space)
B24A A5 AA     LDA &AA
B24C 99 D6 FD  STA &FDD6,Y
B24F 20 BC B3  JSR S3BC         ;print tabulated volume size
B252 4C B1 B1  JMP S1B1         ;update free space display and take input.
.S255                           ;Generate volumes
B255 A2 AE     LDX #&AE         ;point XY at *VOLGEN entry point, &B1AE
B257 A0 B1     LDY #&B1
B259 20 21 B0  JSR S021         ;set command restart action address
B25C 20 06 B7  JSR S706         ;prompt for keypress
B25F 20 79 B2  JSR S279         ;ensure disc is double density
B262 20 D3 B6  JSR S6D3         ;ensure disc is write enabled
B265 F0 03     BEQ S26A         ;if write enabled then proceed
B267 4C AE B1  JMP S1AE         ;if write protected then try again
.S26A
B26A 20 EA B3  JSR S3EA         ;clear catalogue sectors
B26D 20 5E B4  JSR S45E         ;write volume catalogues
B270 20 77 B4  JSR S477         ;generate disc catalogue
B273 20 BD AC  JSR RCBD         ;write disc catalogue L3
B276 4C 28 B0  JMP S028         ;exit command
.S279
B279 20 55 AC  JSR RC55         ;ensure disc is formatted
B27C 2C ED FD  BIT &FDED        ;test density flag
B27F 70 20     BVS S2A1         ;if single density
B281 20 AD A8  JSR R8AD         ;then raise "must be double density" error.
B284 EQUB &C9
B285 EQUS "Disk must be double density"
B2A0 EQUB &00
.S2A1
B2A1 60        RTS
.S2A2                           ;Clear volume size
B2A2 A5 C1     LDA &C1          ;get volume index
B2A4 0A        ASL A            ;double to get offset
B2A5 A8        TAY
B2A6 20 07 BE  JSR SE07         ;page in auxiliary workspace
B2A9 A9 00     LDA #&00
B2AB 99 D5 FD  STA &FDD5,Y      ;set size of selected volume = 0
B2AE 99 D6 FD  STA &FDD6,Y
B2B1 60        RTS
.S2B2                           ;Print "FORMAT" heading
B2B2 20 58 B7  JSR S758         ;set display MODE 7 and place heading
B2B5 20 17 A9  JSR R917         ;print VDU sequence immediate
B2B8 EQUS "F O R M A T"
B2C3 EQUB &FF
.S2C4
B2C4 60        RTS
.S2C5                           ;Set display MODE 7
B2C5 A9 07     LDA #&07
B2C7 48        PHA
B2C8 A9 16     LDA #&16
B2CA 20 EE FF  JSR &FFEE
B2CD 68        PLA
B2CE 4C EE FF  JMP &FFEE
.S2D1                           ;Move cursor to (X,Y)
B2D1 A9 1F     LDA #&1F         ;issue VDU 31 = PRINT TAB(X,Y)
B2D3 20 EE FF  JSR &FFEE
B2D6 8A        TXA              ;send X coordinate to OSWRCH, 0=leftmost col
B2D7 20 EE FF  JSR &FFEE
B2DA 98        TYA              ;send Y coordinate to OSWRCH, 0=top row
B2DB 4C EE FF  JMP &FFEE
.S2DE                           ;Clear row 23
B2DE A2 00     LDX #&00         ;move cursor to (0,23)
B2E0 A0 17     LDY #&17
B2E2 20 D1 B2  JSR S2D1         ;move cursor to (X,Y)
B2E5 A0 28     LDY #&28         ;set Y = 40, width of one MODE 7 row:
B2E7 4C DD 8A  JMP PADD         ;print number of spaces in Y
.S2EA                           ;Poll for ESCAPE
B2EA 24 FF     BIT &FF          ;if ESCAPE was pressed
B2EC 10 D6     BPL S2C4
B2EE 20 8F A9  JSR R98F         ;then acknowledge ESCAPE condition
B2F1 20 71 AD  JSR RD71         ;release NMI
B2F4 A6 B7     LDX &B7          ;restore stack pointer from &B7
B2F6 9A        TXS
B2F7 6C E6 FD  JMP (&FDE6)      ;and restart command
.S2FA                           ;Move cursor to table row in &C1
B2FA A2 01     LDX #&01         ;(1,6+?&C1)
B2FC 18        CLC
B2FD A5 C1     LDA &C1
B2FF 69 06     ADC #&06
B301 A8        TAY
B302 4C D1 B2  JMP S2D1
.S305                           ;Input hex number up to 3 digits
B305 A0 00     LDY #&00         ;start with no characters in line buffer
B307 84 AA     STY &AA          ;clear accumulator
B309 84 AB     STY &AB
.S30B
B30B 20 EE B5  JSR S5EE         ;get input character and acknowledge ESCAPE
B30E C9 0D     CMP #&0D         ;if user pressed RETURN
B310 D0 02     BNE S314
B312 18        CLC              ;then return C=0
B313 60        RTS
.S314
B314 C9 7F     CMP #&7F         ;else if user pressed DELETE
B316 D0 15     BNE S32D
B318 98        TYA              ;then test number of characters entered
B319 D0 02     BNE S31D         ;if no characters on line
B31B 38        SEC              ;then return C=1
B31C 60        RTS
.S31D
B31D 20 48 B3  JSR S348         ;else backspace and erase last character
B320 88        DEY              ;decrement number of characters entered
B321 A2 04     LDX #&04         ;else 4 places to shift by:
.S323
B323 46 AB     LSR &AB          ;shift MSB of accumulator right
B325 66 AA     ROR &AA          ;shift old b0 into LSB of accumulator
B327 CA        DEX              ;loop until 4 bits shifted
B328 D0 F9     BNE S323         ;removing last digit entered
B32A 4C 0B B3  JMP S30B         ;and loop
.S32D
B32D C0 03     CPY #&03         ;if 3 characters already entered
B32F F0 DA     BEQ S30B         ;then ignore latest, loop to read DEL/CR
B331 20 E1 A9  JSR R9E1         ;else convert ASCII hex digit to binary
B334 20 80 A9  JSR R980         ;print hex nibble
B337 A2 04     LDX #&04         ;4 places to shift by:
.S339
B339 06 AA     ASL &AA          ;shift LSB of accumulator left
B33B 26 AB     ROL &AB          ;shift old b7 into MSB of accumulator
B33D CA        DEX              ;loop until 4 bits shifted
B33E D0 F9     BNE S339         ;now b3..0 of &AA = &0
B340 05 AA     ORA &AA          ;apply LSB to nibble typed by user
B342 85 AA     STA &AA          ;update LSB of accumulator
B344 C8        INY              ;increment number of digits typed
B345 4C 0B B3  JMP S30B         ;loop to input more digits
.S348                           ;Backspace and erase characters
B348 20 50 B3  JSR S350         ;print DEL
B34B A9 20     LDA #&20         ;print space:
B34D 20 EE FF  JSR &FFEE
.S350                           ;Print DEL
B350 A9 7F     LDA #&7F         ;set A = ASCII value of DEL character
B352 4C EE FF  JMP &FFEE        ;call OSWRCH to print it and exit.
                                ;unreachable code
B355 38        SEC              ;Convert ASCII digit to binary and validate
B356 E9 30     SBC #&30         ;C=1 iff invalid
B358 90 03     BCC S35D
B35A C9 0A     CMP #&0A
B35C 60        RTS
.S35D                           ;unreachable code
B35D 38        SEC
B35E 60        RTS
.S35F                           ;Divide word by word
B35F A2 00     LDX #&00         ;initialise quotient = 0:
.S361
B361 A5 B1     LDA &B1          ;Compare dividend - divisor
B363 C5 B3     CMP &B3
B365 90 18     BCC S37F
B367 D0 06     BNE S36F
B369 A5 B0     LDA &B0
B36B C5 B2     CMP &B2
B36D 90 10     BCC S37F         ;if dividend >= divisor
.S36F
B36F A5 B0     LDA &B0          ;then subtract dividend - divisor
B371 E5 B2     SBC &B2
B373 85 B0     STA &B0          ;ultimately leaving remainder
B375 A5 B1     LDA &B1
B377 E5 B3     SBC &B3
B379 85 B1     STA &B1
B37B E8        INX              ;increment quotient in X
B37C 4C 61 B3  JMP S361         ;and loop as remainder >= 0
.S37F
B37F 60        RTS
.S380                           ;Print sector count as kilobytes
B380 20 E9 A7  JSR R7E9         ;print sector count
B383 A0 02     LDY #&02         ;print 2 spaces
B385 20 DD 8A  JSR PADD
B388 46 A9     LSR &A9          ;divide sector count by 4 to get kilobytes
B38A 66 A8     ROR &A8
B38C 46 A9     LSR &A9
B38E 66 A8     ROR &A8
B390 A5 A8     LDA &A8
B392 20 9D B3  JSR S39D         ;convert byte to three decimal digits
B395 20 E9 A7  JSR R7E9         ;print space-padded hex word
B398 A9 4B     LDA #&4B         ;print "K"
B39A 4C EE FF  JMP &FFEE
.S39D                           ;Convert byte to three decimal digits
B39D 38        SEC
B39E A2 FF     LDX #&FF
B3A0 86 A9     STX &A9
.S3A2
B3A2 E6 A9     INC &A9
B3A4 E9 64     SBC #&64
B3A6 B0 FA     BCS S3A2
B3A8 69 64     ADC #&64
.S3AA
B3AA E8        INX
B3AB E9 0A     SBC #&0A
B3AD B0 FB     BCS S3AA
B3AF 69 0A     ADC #&0A
B3B1 85 A8     STA &A8
B3B3 8A        TXA
B3B4 20 A4 A9  JSR R9A4
B3B7 05 A8     ORA &A8
B3B9 85 A8     STA &A8
B3BB 60        RTS
.S3BC                           ;Print tabulated volume size
B3BC 20 FA B2  JSR S2FA         ;move cursor to table row in &C1
B3BF 18        CLC
B3C0 A5 C1     LDA &C1          ;get volume letter
B3C2 69 41     ADC #&41         ;convert to ASCII letter A..H
B3C4 20 EE FF  JSR &FFEE        ;call OSWRCH
B3C7 A0 0D     LDY #&0D         ;erase next 13 characters
B3C9 20 2C B7  JSR S72C         ;erase Y characters ahead of cursor
B3CC A5 C1     LDA &C1          ;get volume index
B3CE 0A        ASL A            ;double it
B3CF A8        TAY              ;transfer to Y as index
B3D0 20 07 BE  JSR SE07         ;page in auxiliary workspace
B3D3 B9 D5 FD  LDA &FDD5,Y      ;get MSB volume size
B3D6 85 A9     STA &A9          ;store it in zero page
B3D8 B9 D6 FD  LDA &FDD6,Y      ;get LSB volume size
B3DB 85 A8     STA &A8          ;store it in zero page
B3DD 05 A9     ORA &A9          ;test volume size
B3DF F0 06     BEQ S3E7         ;if =0 then leave row blank
B3E1 20 15 A8  JSR R815         ;else print two spaces
B3E4 20 80 B3  JSR S380         ;print sector count as kilobytes
.S3E7
B3E7 4C 0C BE  JMP SE0C         ;page in main workspace
.S3EA                           ;Clear catalogue sectors
B3EA A9 00     LDA #&00
B3EC A8        TAY
B3ED 20 11 BE  JSR SE11         ;page in catalogue sector 0
.S3F0
B3F0 99 00 FD  STA &FD00,Y
B3F3 C8        INY
B3F4 D0 FA     BNE S3F0
B3F6 20 16 BE  JSR SE16         ;page in catalogue sector 1
.S3F9
B3F9 99 00 FD  STA &FD00,Y
B3FC C8        INY
B3FD D0 FA     BNE S3F9
B3FF 4C 0C BE  JMP SE0C         ;page in main workspace
.S402                           ;Clear volume sizes
B402 20 07 BE  JSR SE07         ;page in auxiliary workspace
B405 A9 00     LDA #&00
B407 A0 0F     LDY #&0F         ;8 words to clear for volumes A..H
.S409
B409 99 D5 FD  STA &FDD5,Y      ;set assigned size of volume to &0000
B40C 88        DEY
B40D 10 FA     BPL S409         ;loop until all words cleared
B40F 4C 0C BE  JMP SE0C         ;page in main workspace
.S412                           ;Set default volume sizes
B412 20 0C BE  JSR SE0C         ;page in main workspace
B415 A5 C4     LDA &C4          ;set free space = sectors avail. for volumes
B417 85 B2     STA &B2
B419 A5 C5     LDA &C5
B41B 85 B3     STA &B3
B41D AD EB FD  LDA &FDEB        ;get number of sectors per track
B420 85 B0     STA &B0
B422 A9 00     LDA #&00         ;clear MSB of word
B424 A2 04     LDX #&04         ;4 places to shift, multiply by 16:
.S426
B426 06 B0     ASL &B0          ;shift word one place left
B428 2A        ROL A
B429 CA        DEX              ;repeat 4 times
B42A D0 FA     BNE S426         ;max. 16 tracks = 72 KiB per volume
B42C 85 B1     STA &B1
B42E 20 07 BE  JSR SE07         ;page in auxiliary workspace
B431 A0 00     LDY #&00
.S433
B433 20 47 B5  JSR S547         ;compare requested allocation with free space
B436 90 08     BCC S440         ;if it fits then set allocation = request
B438 A5 B3     LDA &B3          ;else set request = free space
B43A 85 B1     STA &B1
B43C A5 B2     LDA &B2
B43E 85 B0     STA &B0
.S440
B440 A5 B1     LDA &B1          ;set allocation = request
B442 99 D5 FD  STA &FDD5,Y
B445 A5 B0     LDA &B0
B447 99 D6 FD  STA &FDD6,Y
B44A 38        SEC              ;subtract LSB request from free space
B44B A5 B2     LDA &B2
B44D E5 B0     SBC &B0
B44F 85 B2     STA &B2
B451 A5 B3     LDA &B3          ;subtract MSB request from free space
B453 E5 B1     SBC &B1
B455 85 B3     STA &B3
B457 C8        INY              ;add 2 to offset, point to next volume
B458 C8        INY
B459 C0 10     CPY #&10         ;loop until volumes A..H set.
B45B D0 D6     BNE S433
B45D 60        RTS
.S45E                           ;Write volume catalogues
B45E A0 00     LDY #&00         ;start at volume A
.S460
B460 20 07 BE  JSR SE07         ;page in auxiliary workspace
B463 B9 D5 FD  LDA &FDD5,Y      ;copy MSB sector count
B466 85 C5     STA &C5          ;to size of volume to be created
B468 B9 D6 FD  LDA &FDD6,Y      ;and copy LSB
B46B 85 C4     STA &C4
B46D 20 62 B0  JSR S062         ;initialise volume catalogue
B470 C8        INY              ;advance volume letter by 1/sector by 2
B471 C8        INY
B472 C0 10     CPY #&10         ;have we initialised 8 volumes/16 sectors?
B474 D0 EA     BNE S460         ;if not then loop to init all volumes
B476 60        RTS
.S477                           ;Generate disc catalogue
B477 20 11 BE  JSR SE11         ;page in catalogue sector 0
B47A A9 20     LDA #&20         ;set version/configuration number = &20
B47C 8D 00 FD  STA &FD00        ;indicating that sector count is big-endian
B47F A9 12     LDA #&12         ;18 sectors per track
B481 8D 03 FD  STA &FD03
B484 A4 C0     LDY &C0          ;set number of tracks on disc
B486 8C 04 FD  STY &FD04
B489 A9 00     LDA #&00         ;mystery field (MSB no. tracks?), always 0
B48B 8D 05 FD  STA &FD05
B48E 20 AE B5  JSR S5AE
B491 A5 A8     LDA &A8
B493 8D 02 FD  STA &FD02        ;store LSB number of sectors on disc
B496 A5 A9     LDA &A9
B498 8D 01 FD  STA &FD01        ;store MSB
B49B A0 01     LDY #&01
B49D 84 BB     STY &BB          ;data area starts on track 1
B49F 88        DEY
.S4A0
B4A0 20 07 BE  JSR SE07         ;page in auxiliary workspace
B4A3 98        TYA              ;save 2 * volume letter
B4A4 48        PHA
B4A5 B9 D5 FD  LDA &FDD5,Y      ;get MSB no. sectors in volume's data area
B4A8 85 B1     STA &B1          ;store MSB dividend
B4AA B9 D6 FD  LDA &FDD6,Y      ;get LSB no. sectors in volume's data area
B4AD 85 B0     STA &B0          ;store LSB dividend
B4AF 05 B1     ORA &B1          ;test number of requested sectors
B4B1 F0 16     BEQ S4C9         ;if zero then volume absent, assign no tracks
B4B3 20 11 BE  JSR SE11
B4B6 A5 BB     LDA &BB          ;else set starting track of volume data area
B4B8 99 08 FD  STA &FD08,Y
B4BB A9 00     LDA #&00         ;clear next byte (MSB track number?)
B4BD 99 09 FD  STA &FD09,Y
B4C0 20 97 B5  JSR S597         ;generate track multiple of at least req.
B4C3 18        CLC
B4C4 98        TYA
B4C5 65 BB     ADC &BB          ;add number of tracks in Y to starting track
B4C7 85 BB     STA &BB
.S4C9
B4C9 68        PLA              ;skip to next volume entry
B4CA A8        TAY
B4CB C8        INY
B4CC C8        INY
B4CD C0 10     CPY #&10         ;loop until tracks assigned to 8 volumes
B4CF D0 CF     BNE S4A0
B4D1 60        RTS
.S4D2                           ;Read volume sizes and allocations
B4D2 20 2E B5  JSR S52E         ;copy volume allocations to workspace
B4D5 20 11 BE  JSR SE11         ;page in catalogue sector 0
B4D8 38        SEC
B4D9 AD 02 FD  LDA &FD02        ;get LSB number of sectors on disc
B4DC E9 12     SBC #&12         ;subtract 18 sectors of catalogue track
B4DE 85 C4     STA &C4          ;set LSB total sectors allocated to volumes
B4E0 AD 01 FD  LDA &FD01        ;borrow from MSB
B4E3 E9 00     SBC #&00
B4E5 85 C5     STA &C5
B4E7 AD 04 FD  LDA &FD04        ;get number of tracks on disc
B4EA 85 C0     STA &C0
B4EC 20 02 B4  JSR S402         ;clear volume sizes
B4EF A0 0E     LDY #&0E         ;start at volume H, cat. sector 14:
;Read volume sizes from the catalogue of each volume.
.S4F1
B4F1 20 07 BE  JSR SE07         ;page in auxiliary workspace
B4F4 98        TYA              ;y=2*volume
B4F5 4A        LSR A            ;A=volume
B4F6 AA        TAX              ;transfer to X for use as index
B4F7 BD CD FD  LDA &FDCD,X      ;look up number of tracks in volume
B4FA F0 2D     BEQ S529         ;if volume absent then skip
B4FC 84 BB     STY &BB          ;else set sector number = 2*volume
B4FE E6 BB     INC &BB          ;add 1, point to 2nd sector of cat.
B500 20 A5 96  JSR Q6A5         ;set data pointer to &0200
B503 A9 01     LDA #&01         ;256 bytes to transfer
B505 85 A1     STA &A1
B507 A9 00     LDA #&00
B509 85 A0     STA &A0
B50B A9 80     LDA #&80         ;data transfer call &80 = read data to JIM
B50D 8D E9 FD  STA &FDE9        ;set data transfer call number
B510 20 18 BA  JSR SA18         ;transfer data L2
B513 20 11 BE  JSR SE11         ;page in catalogue sector 0
B516 AD 06 FD  LDA &FD06        ;get boot option/top bits volume size
B519 29 03     AND #&03         ;extract MSB volume size
B51B 48        PHA
B51C AD 07 FD  LDA &FD07        ;get LSB volume size from catalogue
B51F 20 07 BE  JSR SE07         ;page in auxiliary workspace
B522 99 D6 FD  STA &FDD6,Y      ;set as LSB size of this volume
B525 68        PLA
B526 99 D5 FD  STA &FDD5,Y      ;set as MSB size of this volume
.S529
B529 88        DEY              ;proceed to previous volume
B52A 88        DEY              ;whose catalogue sector no. is two less
B52B 10 C4     BPL S4F1         ;loop until all eight volumes read
B52D 60        RTS
.S52E                           ;Copy volume allocations to workspace
B52E 20 BA AC  JSR RCBA         ;load disc catalogue L3
B531 A0 0E     LDY #&0E         ;start at sector offset 14, volume H
B533 A2 07     LDX #&07         ;start at workspace offset 7, volume H
.S535
B535 20 11 BE  JSR SE11         ;page in catalogue sector 0
B538 B9 08 FD  LDA &FD08,Y      ;get first track of data area of volume
B53B 20 07 BE  JSR SE07         ;page in auxiliary workspace
B53E 9D CD FD  STA &FDCD,X      ;store in workspace
B541 88        DEY              ;skip mystery field in sector
B542 88        DEY              ;decrement offset, work back from H to A
B543 CA        DEX              ;decrement workspace offset
B544 10 EF     BPL S535         ;loop until 8 track numbers copied
B546 60        RTS
.S547                           ;Compare requested allocation with limit
B547 A5 B1     LDA &B1
B549 C5 B3     CMP &B3
B54B D0 04     BNE S551
B54D A5 B0     LDA &B0
B54F C5 B2     CMP &B2
.S551
B551 60        RTS
.S552                           ;Multiply by no. sectors per track
B552 20 0C BE  JSR SE0C         ;page in main workspace
B555 AC EB FD  LDY &FDEB        ;get number of sectors per track
B558 A9 00     LDA #&00         ;clear product
B55A 85 C4     STA &C4
B55C 85 C5     STA &C5
.S55E
B55E 18        CLC              ;add number of tracks to product
B55F A5 B0     LDA &B0
B561 65 C4     ADC &C4
B563 85 C4     STA &C4
B565 90 02     BCC S569         ;carry out to high byte
B567 E6 C5     INC &C5
.S569
B569 88        DEY              ;loop until all sectors per track added
B56A D0 F2     BNE S55E
B56C 60        RTS
.S56D                           ;Sum volume sizes
B56D A2 00     LDX #&00         ;clear offset = 0, point to volume A
B56F 86 B2     STX &B2          ;clear total
.S571
B571 20 07 BE  JSR SE07         ;page in auxiliary workspace
B574 BD D6 FD  LDA &FDD6,X      ;get LSB requested size of volume at X
B577 85 B0     STA &B0          ;set LSB current request
B579 BD D5 FD  LDA &FDD5,X      ;get MSB requested size of volume at X
B57C 85 B1     STA &B1          ;get MSB current request
B57E 20 97 B5  JSR S597         ;generate track multiple of at least req.
B581 18        CLC
B582 98        TYA              ;a = track count for this volume
B583 65 B2     ADC &B2          ;add to total allocations
B585 85 B2     STA &B2
B587 E8        INX              ;add 2 to offset
B588 E8        INX
B589 E0 10     CPX #&10         ;loop until 8 allocations added
B58B D0 E4     BNE S571
B58D 38        SEC              ;subtract disc size - total allocations
B58E A5 C0     LDA &C0
B590 E5 B2     SBC &B2
B592 A8        TAY              ;=disc space free
B593 88        DEY              ;subtract 1 for catalogue track
B594 4C AE B5  JMP S5AE         ;multiply track count by 18
.S597                           ;Generate track multiple of at least req.
B597 A0 00     LDY #&00
B599 84 A8     STY &A8          ;clear LSB sector count
B59B 84 A9     STY &A9          ;clear MSB sector count
.S59D
B59D A5 A8     LDA &A8          ;compare sector count - request
B59F C5 B0     CMP &B0
B5A1 A5 A9     LDA &A9
B5A3 E5 B1     SBC &B1
B5A5 B0 06     BCS S5AD         ;if sector count >= request then return it
B5A7 C8        INY              ;else add one track to track count
B5A8 20 BE B5  JSR S5BE         ;add 18 sectors to sector count
B5AB 90 F0     BCC S59D         ;and loop (always)
.S5AD
B5AD 60        RTS
.S5AE                           ;Multiply track count by 18
B5AE A9 00     LDA #&00
B5B0 85 A8     STA &A8          ;clear LSB sector count
B5B2 85 A9     STA &A9          ;clear MSB sector count
B5B4 C8        INY              ;pre-increment track count to exit on 0:
.S5B5
B5B5 88        DEY              ;have we added all tracks?
B5B6 F0 05     BEQ S5BD         ;if so then return sector count
B5B8 20 BE B5  JSR S5BE         ;else add 18 sectors to sector count
B5BB 90 F8     BCC S5B5         ;and loop (always)
.S5BD
B5BD 60        RTS
.S5BE                           ;Add 18 sectors to sector count
B5BE 18        CLC
B5BF A5 A8     LDA &A8
B5C1 69 12     ADC #&12
B5C3 85 A8     STA &A8
B5C5 90 02     BCC S5C9         ;carry out to MSB
B5C7 E6 A9     INC &A9
.S5C9
B5C9 18        CLC
B5CA 60        RTS
.S5CB                           ;Get printable input character
B5CB 20 EE B5  JSR S5EE         ;get input character and acknowledge ESCAPE
B5CE C9 30     CMP #&30         ;is ASCII value less than that of "0"?
B5D0 90 F9     BCC S5CB         ;if so then discard, get another character
B5D2 C9 5B     CMP #&5B         ;else is ASCII value higher than "Z"?
B5D4 B0 F5     BCS S5CB         ;if so then discard, get another character
B5D6 48        PHA              ;else save input character
B5D7 20 EE FF  JSR &FFEE        ;call OSWRCH to print it:
.S5DA
B5DA 20 EE B5  JSR S5EE         ;get input character and acknowledge ESCAPE
B5DD C9 0D     CMP #&0D         ;is it CR?
B5DF D0 02     BNE S5E3         ;if not then test for DEL
B5E1 68        PLA              ;else restore first character and exit
B5E2 60        RTS
.S5E3
B5E3 C9 7F     CMP #&7F         ;was DELETE key pressed?
B5E5 D0 F3     BNE S5DA         ;if neither CR or DEL then get another
B5E7 68        PLA              ;else discard first character
B5E8 20 48 B3  JSR S348         ;backspace and erase characters
B5EB 4C CB B5  JMP S5CB         ;and loop to get another character.
.S5EE                           ;Get input character and acknowledge ESCAPE
B5EE 20 E0 FF  JSR &FFE0        ;call OSRDCH
B5F1 B0 01     BCS S5F4         ;if C=1 then error occurred, test err. code
B5F3 60        RTS              ;else return character in A
.S5F4
B5F4 C9 1B     CMP #&1B         ;test if error code from OSRDCH is &1B
B5F6 F0 01     BEQ S5F9         ;if so then ESCAPE was pressed
B5F8 60        RTS              ;else return
.S5F9
B5F9 20 0C BE  JSR SE0C         ;page in main workspace
B5FC 20 8F A9  JSR R98F         ;acknowledge ESCAPE condition
B5FF 20 71 AD  JSR RD71         ;release NMI
B602 20 50 B6  JSR S650         ;clear rows 20..22
B605 A6 B7     LDX &B7          ;restore stack pointer from &B7
B607 9A        TXS
B608 6C E6 FD  JMP (&FDE6)      ;jump to action address
.S60B                           ;Print "ERROR"
B60B 20 50 B6  JSR S650         ;clear rows 20..22
B60E 20 17 A9  JSR R917         ;print VDU sequence immediate
B611 EQUB &1F                   ;move cursor to (21,23)
B612 EQUB &15
B613 EQUB &17
B614 EQUS "ERROR"
B619 EQUB &FF
B61A 60        RTS
.S61B                           ;Prompt to start format
B61B 20 17 A9  JSR R917         ;print VDU sequence immediate
B61E EQUB &1C                   ;define text window (0,13)..(39,4)
B61F EQUB &00
B620 EQUB &0D
B621 EQUB &27
B622 EQUB &04
B623 EQUB &0C                   ;clear text window
B624 EQUB &1A                   ;restore default windows
B625 EQUB &FF
B626 20 50 B6  JSR S650         ;clear rows 20..22
B629 20 17 A9  JSR R917         ;print VDU sequence immediate
B62C EQUB &1F                   ;move cursor to (0,16)
B62D EQUB &00
B62E EQUB &10
B62F EQUS "Press F(ret) to start  "
B646 EQUB &7F                   ;backspace and erase character
B647 EQUB &FF
B648 20 CB B5  JSR S5CB         ;get printable input character
B64B C9 46     CMP #&46         ;is it capital F?
B64D D0 CC     BNE S61B         ;if not then reprint heading and try again
B64F 60        RTS
.S650                           ;Clear rows 20..22
B650 A2 00     LDX #&00         ;move cursor to (0,20)
B652 A0 10     LDY #&10
B654 20 D1 B2  JSR S2D1         ;move cursor to (X,Y)
B657 A0 78     LDY #&78         ;print 120 spaces and exit
B659 4C DD 8A  JMP PADD         ;print X spaces
.S65C                           ;Prompt user and start format
B65C 20 1B B6  JSR S61B         ;prompt to start format
B65F 20 D3 B6  JSR S6D3         ;ensure disc is write enabled
B662 D0 F8     BNE S65C         ;if write protected then try again
B664 20 50 B6  JSR S650         ;else clear rows 20..22
B667 A9 80     LDA #&80
B669 85 B9     STA &B9          ;>0 disc operation is interruptible
B66B A9 00     LDA #&00
B66D 85 BA     STA &BA          ;set track number = 0
B66F 85 BB     STA &BB          ;set running track skew counter = 0
B671 20 18 BB  JSR SB18         ;create ID table and format track
.S674
B674 A9 03     LDA #&03         ;make three attempts (outer)
B676 85 BF     STA &BF          ;set attempt counter
.S678
B678 20 EA B2  JSR S2EA         ;poll for ESCAPE
B67B 20 B3 B6  JSR S6B3         ;print track number in table
B67E A0 03     LDY #&03         ;erase next 3 characters
B680 20 2C B7  JSR S72C         ;erase Y characters ahead of cursor
B683 20 18 BB  JSR SB18         ;create ID table and format track
B686 20 21 B1  JSR S121         ;verify track with display
B689 F0 09     BEQ S694         ;if succeeded then format next track
B68B C6 BF     DEC &BF          ;else decrement attempt counter
B68D D0 E9     BNE S678         ;if attempts remaining then try again
B68F 20 0B B6  JSR S60B         ;else print "ERROR"
B692 38        SEC              ;set C=1, format failed
B693 60        RTS
.S694
B694 A9 FE     LDA #&FE         ;implement track skew
B696 2C ED FD  BIT &FDED        ;a=-2 (in two's complement)
B699 50 01     BVC S69C         ;if double density
B69B 0A        ASL A            ;then A=-4:
.S69C
B69C 18        CLC              ;subtract 2 or 4 from first R of track
B69D 65 BB     ADC &BB
B69F B0 03     BCS S6A4         ;if it underflows
B6A1 6D EB FD  ADC &FDEB        ;then add number of sectors per track
.S6A4
B6A4 85 BB     STA &BB          ;set first sector number of track
B6A6 E6 BA     INC &BA          ;increment track number
B6A8 A5 BA     LDA &BA
B6AA C5 C0     CMP &C0          ;compare with total tracks
B6AC B0 03     BCS S6B1         ;if >= total tracks then format complete
B6AE 4C 74 B6  JMP S674         ;else loop to format next track
.S6B1
B6B1 18        CLC              ;set C=0, format succeeded.
B6B2 60        RTS
.S6B3                           ;Print track number in table
B6B3 A2 00     LDX #&00         ;set column to 0
B6B5 A4 BA     LDY &BA          ;copy track number as row number
.S6B7
B6B7 38        SEC
B6B8 98        TYA
B6B9 E9 0A     SBC #&0A         ;subtract 10 from row number
B6BB 90 08     BCC S6C5         ;if underflow then keep current row
B6BD A8        TAY              ;else set as new row number
B6BE 18        CLC              ;add 10 to column
B6BF 8A        TXA
B6C0 69 05     ADC #&05
B6C2 AA        TAX
B6C3 90 F2     BCC S6B7         ;and loop until row < 0
.S6C5
B6C5 69 0E     ADC #&0E         ;c=0, add 14 to negative remainder
B6C7 A8        TAY              ;set Y = row 4..13
B6C8 20 D1 B2  JSR S2D1         ;move cursor to (X,Y)
B6CB A5 BA     LDA &BA          ;get track number
B6CD 20 9D B3  JSR S39D         ;convert byte to three decimal digits
B6D0 4C F1 A7  JMP R7F1         ;print space-padded hex byte
.S6D3                           ;Ensure disc is write enabled
B6D3 20 BC AD  JSR RDBC         ;test write protect state of current drive
B6D6 F0 2D     BEQ S705         ;if write enabled then return
B6D8 20 17 A9  JSR R917         ;else print VDU sequence immediate
B6DB EQUB &1F                   ;move cursor to (0,16)
B6DC EQUB &00
B6DD EQUB &10
B6DE EQUS "Disk R/O...remove write protect"
B6FD EQUB &0D
B6FE EQUB &0A
B6FF EQUB &FF
B700 20 06 B7  JSR S706         ;prompt for keypress
B703 A9 FF     LDA #&FF         ;return Z=0
.S705
B705 60        RTS
.S706                           ;Prompt for keypress
B706 20 17 A9  JSR R917         ;print VDU sequence immediate
B709 EQUB &1F                   ;move cursor to (4,17)
B70A EQUB &04
B70B EQUB &11
B70C EQUS "Press any key to continue"
B725 EQUB &FF
B726 20 EE B5  JSR S5EE         ;get input character and acknowledge ESCAPE
B729 4C 50 B6  JMP S650         ;clear rows 20..22 and exit
.S72C                           ;Erase Y characters ahead of cursor
B72C 98        TYA
B72D 48        PHA
B72E 20 DD 8A  JSR PADD         ;print number of spaces in Y
B731 68        PLA
B732 A8        TAY
.S733
B733 A9 7F     LDA #&7F         ;print number of DELs in Y
B735 20 EE FF  JSR &FFEE
B738 88        DEY
B739 D0 F8     BNE S733
B73B 60        RTS
.S73C                           ;Make a short beep
B73C A9 07     LDA #&07         ;BEL = make a short beep
B73E 4C EE FF  JMP &FFEE        ;call OSWRCH
.S741                           ;Parse floppy volume spec from argument
B741 20 16 AA  JSR RA16         ;parse volume spec from argument
B744 20 4C B7  JSR S74C         ;set Z=1 iff current drive is a RAM disc
B747 D0 0E     BNE S757         ;if so
B749 4C D6 AA  JMP RAD6         ;then raise "Bad drive" error.
.S74C                           ;Set Z=1 iff current drive is a RAM disc
B74C 20 D9 AA  JSR RAD9         ;map current volume to physical volume
B74F 29 07     AND #&07         ;mask drive no in b2..0 mask off volume letter
B751 C9 04     CMP #&04         ;if physical drive = 4
B753 F0 02     BEQ S757         ;then return Z=1
B755 C9 05     CMP #&05         ;else return Z=1 if physical drive = 5.
.S757
B757 60        RTS
.S758                           ;set display MODE 7 and place heading
B758 20 C5 B2  JSR S2C5         ;set display MODE 7
B75B A0 00     LDY #&00
B75D C8        INY
B75E A2 0D     LDX #&0D         ;set X=13, Y=1
B760 20 D1 B2  JSR S2D1         ;move cursor to (X,Y)
B763 C0 03     CPY #&03
B765 60        RTS
                                ;*FDCSTAT
B766 BA        TSX              ;have A=0 returned on exit
B767 A9 00     LDA #&00
B769 9D 05 01  STA &0105,X
B76C 20 17 A9  JSR R917         ;print VDU sequence immediate
B76F EQUB &0D
B770 EQUB &0A
B771 EQUS "WD 1770 status : "
B782 EQUB &FF
B783 AD F3 FD  LDA &FDF3        ;get status of last command
B786 20 78 A9  JSR R978         ;print hex byte
B789 4C 69 84  JMP P469         ;print newline
B78C A2 00     LDX #&00         ;&13 Read data / &17 Read data & deleted data
B78E AD A2 01  LDA &01A2        ;&0B Write data                 B78F=LDX #&01
B791 AD A2 02  LDA &02A2        ;                               B792=LDX #&02
B794 AD A2 03  LDA &03A2        ;&0F Write deleted data         B795=LDX #&03
B797 AD A2 04  LDA &04A2        ;&1F Verify data                B798=LDX #&04
B79A 8E E9 FD  STX &FDE9        ;set data transfer call number
B79D B1 B0     LDA (&B0),Y      ;get 2nd parameter = starting sector number
B79F 85 BB     STA &BB          ;set starting sector
B7A1 20 4C B7  JSR S74C         ;set Z=1 iff current drive is a RAM disc
B7A4 D0 13     BNE S7B9         ;if so
B7A6 A2 0A     LDX #&0A         ;then convert CS address per Acorn DFS to LBA
B7A8 A0 00     LDY #&00         ;x = 10 sectors per track, Y = 0 MSB of LBA
B7AA A5 BB     LDA &BB          ;begin with LSB of LBA = starting sector:
.S7AC
B7AC 18        CLC              ;add one sector for each track skipped
B7AD 65 BA     ADC &BA
B7AF 90 01     BCC S7B2         ;carry out to MSB
B7B1 C8        INY
.S7B2
B7B2 CA        DEX              ;loop until 10 sectors per track added
B7B3 D0 F7     BNE S7AC         ;thereby adding product = no. sectors skipped
B7B5 85 BB     STA &BB          ;store LSB of LBA
B7B7 84 BA     STY &BA          ;store MSB of LBA (big-endian)
.S7B9
B7B9 A0 09     LDY #&09
B7BB B1 B0     LDA (&B0),Y      ;get number of sectors + size code
B7BD 20 9D A9  JSR R99D         ;shift A right 5 places
B7C0 AA        TAX              ;save size code in X
B7C1 A9 00     LDA #&00         ;set LSB of byte count = 0
B7C3 85 A0     STA &A0
B7C5 B1 B0     LDA (&B0),Y      ;get number of sectors + size code
B7C7 C8        INY              ;increment offset; Y = 10, points to status
B7C8 29 1F     AND #&1F         ;extract number of sectors
B7CA 4A        LSR A            ;A,&A0 = 256 x sector count; divide by two
B7CB 66 A0     ROR &A0          ;= byte count if X=0, 128-byte sectors
B7CD 90 03     BCC S7D2         ;jump into doubling loop (always)
.S7CF
B7CF 06 A0     ASL &A0          ;multiply byte count by two
B7D1 2A        ROL A
.S7D2
B7D2 CA        DEX              ;subtract 1 from X
B7D3 10 FA     BPL S7CF         ;if X was >0 then double byte count
B7D5 85 A1     STA &A1          ;else store high byte of byte count
B7D7 4C 18 BA  JMP SA18         ;transfer data L2 and exit
                                ;&29 Seek
B7DA 20 E3 B7  JSR S7E3         ;set A=0, C=1 if RAM else A=physical drive
B7DD B0 03     BCS S7E2         ;if a RAM disc then nothing to do, exit
B7DF 20 16 B9  JSR S916         ;else seek logical track
.S7E2
B7E2 60        RTS
.S7E3                           ;Set A=0, C=1 if RAM else A=physical drive
B7E3 20 4C B7  JSR S74C         ;set Z=1 iff current drive is a RAM disc
B7E6 18        CLC              ;if a floppy drive
B7E7 D0 03     BNE S7EC         ;then return C=0, A=physical drive, Z=0
B7E9 A9 00     LDA #&00
B7EB 38        SEC              ;else return C=1, A=0, Z=1
.S7EC
B7EC 60        RTS
                                ;&1B Read ID
B7ED A0 09     LDY #&09         ;offset 9 = third parameter
B7EF B1 B0     LDA (&B0),Y      ;get number of IDs to return
B7F1 D0 02     BNE S7F5         ;zero is reserved for internal use
B7F3 A9 01     LDA #&01         ;in which case return one ID
.S7F5
B7F5 85 BB     STA &BB          ;set number of IDs to return
B7F7 20 4C B7  JSR S74C         ;set Z=1 iff current drive is a RAM disc
B7FA F0 1C     BEQ S818         ;if so then emulate IDs
B7FC 20 16 B9  JSR S916         ;seek logical track
B7FF 20 5F B9  JSR S95F         ;read ID and detect density
B802 D0 13     BNE S817         ;if command failed then exit
B804 48        PHA              ;else save command result = 0
B805 A5 BB     LDA &BB          ;get number of IDs to return
B807 0A        ASL A            ;multiply by 4 = number of ID bytes
B808 0A        ASL A
B809 AA        TAX              ;transfer to X to use as counter
B80A A0 00     LDY #&00         ;start at offset 0:
.S80C
B80C B9 0C 0D  LDA &0D0C,Y      ;get byte of ID read from workspace
B80F 20 E0 A4  JSR R4E0         ;put data byte in user memory
B812 C8        INY              ;increment offset
B813 CA        DEX              ;loop until X bytes returned to user
B814 D0 F6     BNE S80C
B816 68        PLA              ;restore command result
.S817
B817 60        RTS
.S818                           ;emulate RAM disc sector IDs
B818 68        PLA
B819 A0 00     LDY #&00         ;start at beginning of user memory
B81B A2 00     LDX #&00         ;first sector number = 0
.S81D                           ;Create ID table
B81D A5 BA     LDA &BA          ;get track number       C
B81F 20 E0 A4  JSR R4E0         ;put data byte in user memory
B822 C8        INY
B823 A9 00     LDA #&00         ;head number = 0        H
B825 20 E0 A4  JSR R4E0         ;put data byte in user memory
B828 C8        INY
B829 8A        TXA              ;transfer sector number R
B82A 20 E0 A4  JSR R4E0         ;put data byte in user memory
B82D C8        INY
B82E A9 01     LDA #&01         ;size code = 1, 256 b   N
B830 20 E0 A4  JSR R4E0         ;put data byte in user memory
B833 E8        INX              ;increment sector number
B834 C6 BB     DEC &BB          ;loop until required no. sector IDs created
B836 D0 E5     BNE S81D
B838 20 96 B9  JSR S996         ;set up drive for single density
B83B A9 00     LDA #&00         ;fake WD1770 status = 0, succeeded.
B83D 60        RTS
                                ;&23 Format track
B83E 20 E3 B7  JSR S7E3         ;Set A=0, C=1 if RAM else A=physical drive
B841 B0 0B     BCS S84E         ;if RAM then set density of RAM disc
B843 C8        INY              ;else offset 9 = no. sectors + size code
B844 B1 B0     LDA (&B0),Y
B846 29 1F     AND #&1F         ;extract number of sectors
B848 8D EB FD  STA &FDEB        ;store number of sectors per track
B84B 4C 58 BB  JMP SB58         ;format track
.S84E
B84E AD ED FD  LDA &FDED        ;get density flag
B851 29 40     AND #&40         ;mask bit 6 = double density
B853 8D FE FD  STA &FDFE        ;store RAM disc density flag
B856 A9 00     LDA #&00         ;fake WD1770 status = 0, succeeded.
B858 60        RTS
                                ;&2C Read drive status
B859 88        DEY              ;y = 8 going to 7, offset of result
B85A 20 05 B9  JSR S905         ;test write protect state
B85D 4A        LSR A            ;returned in bit 6
B85E 4A        LSR A            ;move to bit 3 = WR PROT
B85F 4A        LSR A
B860 09 44     ORA #&44         ;set b6 = RDY 1, b2 = RDY 0
.S862
B862 60        RTS              ;return result to user's OSWORD &7F block
                                ;&35 Specify
B863 A5 BA     LDA &BA          ;get first parameter
B865 C9 0D     CMP #&0D         ;is it &0D = Specify Initialization?
B867 D0 F9     BNE S862         ;if not then exit
B869 B1 B0     LDA (&B0),Y      ;else get second parameter = step rate
B86B AA        TAX              ;(WD1770 format; 0=fast..3=slow; b7..2=0)
B86C 4C 01 B9  JMP S901         ;save as track stepping rate
                                ;&3A Write special registers
B86F B1 B0     LDA (&B0),Y      ;get second parameter = value to write
B871 A6 BA     LDX &BA          ;get first parameter = register address
B873 E0 05     CPX #&05         ;if address in range 0..4
B875 B0 04     BCS S87B
B877 9D EA FD  STA &FDEA,X      ;then set parameter of current drive
B87A 60        RTS
.S87B
B87B A0 00     LDY #&00         ;else point to unit 0 track position
B87D E0 12     CPX #&12         ;if address = 18
B87F F0 05     BEQ S886         ;then set unit 0 position
B881 C8        INY              ;else point to unit 1 track position
B882 E0 1A     CPX #&1A         ;if address <> 26
B884 D0 24     BNE S8AA         ;then exit with result = 0
.S886
B886 99 EF FD  STA &FDEF,Y      ;else store physical position of head
B889 A9 00     LDA #&00         ;return result = 0, succeeded.
B88B 60        RTS
                                ;&3D Read special registers
B88C A6 BA     LDX &BA          ;get first parameter = register address
B88E E0 05     CPX #&05         ;if address in range 0..3
B890 B0 06     BCS S898
B892 BD EA FD  LDA &FDEA,X      ;then return parameter of current drive
B895 91 B0     STA (&B0),Y      ;return to offset 8 of OSWORD control block
B897 60        RTS
.S898
B898 A9 00     LDA #&00         ;else point to unit 0 track position
B89A E0 12     CPX #&12         ;if address = 18
B89C F0 06     BEQ S8A4         ;then return unit 0 position
B89E A9 01     LDA #&01         ;else point to unit 1 track position
B8A0 E0 1A     CPX #&1A         ;if address <> 26
B8A2 D0 06     BNE S8AA         ;then exit with result = 0
.S8A4
B8A4 AA        TAX              ;else transfer offset to X
B8A5 BD EF FD  LDA &FDEF,X      ;get physical track number for drive
B8A8 91 B0     STA (&B0),Y      ;store result byte
.S8AA
B8AA A9 00     LDA #&00         ;returns 0
B8AC 60        RTS
;Table of 8271 floppy drive controller commands with action addresses
B8AD EQUB &13                   ;&13 Read data
B8AE EQUW &8B,&B7
B8B0 EQUB &0B                   ;&0B Write data
B8B1 EQUW &8E,&B7
B8B3 EQUB &29                   ;&29 Seek
B8B4 EQUW &D9,&B7
B8B6 EQUB &1F                   ;&1F Verify data
B8B7 EQUW &97,&B7
B8B9 EQUB &17                   ;&17 Read data & deleted data
B8BA EQUW &8B,&B7
B8BC EQUB &0F                   ;&0F Write deleted data
B8BD EQUW &94,&B7
B8BF EQUB &1B                   ;&1B Read ID
B8C0 EQUW &EC,&B7
B8C2 EQUB &23                   ;&23 Format track
B8C3 EQUW &3D,&B8
B8C5 EQUB &2C                   ;&2C Read drive status
B8C6 EQUW &58,&B8
B8C8 EQUB &35                   ;&35 Specify
B8C9 EQUW &62,&B8
B8CB EQUB &3A                   ;&3A Write special registers
B8CC EQUW &6E,&B8
B8CE EQUB &3D                   ;&3D Read special registers
B8CF EQUW &8B,&B8
B8D1 EQUB &00                   ;terminator byte
.S8D2                           ;Set control latch for drive
B8D2 20 4C A8  JSR R84C         ;save AXY
B8D5 20 4C B7  JSR S74C         ;set Z=1 iff current drive is a RAM disc
B8D8 F0 14     BEQ S8EE         ;if so then nothing to do, return
B8DA 20 D9 AA  JSR RAD9         ;else map current volume to physical volume
B8DD 29 07     AND #&07         ;extract physical drive number, clear b7..3
B8DF AA        TAX              ;put drive number in X
B8E0 AD ED FD  LDA &FDED        ;get density flag
B8E3 29 7F     AND #&7F         ;mask off b7=automatic density
B8E5 49 40     EOR #&40         ;invert b6, now 0=double density 1=single
B8E7 4A        LSR A            ;move to bit 5
B8E8 1D EF B8  ORA &B8EF,X      ;apply flags for drive 0..7 in X
B8EB 8D FC FC  STA &FCFC        ;store in control latch
.S8EE
B8EE 60        RTS
;Table of drive control latch values for drives 0..7
B8EF EQUB &12,&14,&13,&15
B8F3 EQUB &FF,&FF,&18,&19       ;drives 4 and 5 are RAM discs
.S8F7                           ;Set track stepping rate from startup options
B8F7 20 4C A8  JSR R84C         ;save AXY
B8FA 20 F0 AD  JSR RDF0         ;call OSBYTE &FF = read/write startup options
B8FD 8A        TXA              ;transfer keyboard links to A
B8FE 20 96 A9  JSR R996         ;extract b5,b4 of A
.S901
B901 8D F2 FD  STA &FDF2        ;save as track stepping rate
B904 60        RTS
.S905                           ;Test write protect state of current drive
B905 20 4C B7  JSR S74C         ;set Z=1 iff current drive is a RAM disc
B908 F0 09     BEQ S913         ;if so then return A=&00, Z=1 write enabled
B90A 20 F3 B9  JSR S9F3         ;else issue Seek and Force Interrupt
B90D 20 16 BD  JSR SD16         ;wait for command completion
B910 29 40     AND #&40         ;z=0 if WD1770 S6 = write protect.
B912 60        RTS
.S913
B913 A9 00     LDA #&00
B915 60        RTS
.S916                           ;Seek logical track
B916 20 0C BE  JSR SE0C         ;page in main workspace
B919 A5 BA     LDA &BA          ;get logical track number
B91B 2C EA FD  BIT &FDEA        ;test double-stepping flag
B91E 50 01     BVC S921         ;if b6=1 then double stepping is enabled
B920 0A        ASL A            ;so double track number:
.S921                           ;Seek physical track
B921 20 D2 B8  JSR S8D2         ;set control latch for drive
B924 20 75 A8  JSR R875         ;save XY
B927 48        PHA              ;save target physical track
B928 20 A0 BC  JSR SCA0         ;set X=physical floppy unit for current drive
B92B BD EF FD  LDA &FDEF,X      ;get physical track number for drive
B92E 20 9C BC  JSR SC9C         ;write to FDC track register
B931 68        PLA              ;get back A
B932 9D EF FD  STA &FDEF,X      ;store physical track number for drive
B935 20 02 BD  JSR SD02         ;write to FDC data register
B938 C9 00     CMP #&00         ;if track number = 0
B93A F0 02     BEQ S93E         ;then issue WD1770 FDC command &00 = Restore
B93C A9 10     LDA #&10         ;else issue WD1770 FDC command &10 = Seek:
.S93E                           ;Execute Restore/Seek command
B93E 2C F8 FC  BIT &FCF8        ;test FDC status register
B941 08        PHP              ;save WD1770 S7 = motor on in N
B942 0D F2 FD  ORA &FDF2        ;apply track stepping rate
B945 20 FA BC  JSR SCFA         ;write to FDC command register
B948 20 16 BD  JSR SD16         ;wait for command completion
B94B 28        PLP              ;restore previous status
B94C 30 10     BMI S95E         ;if motor was on then exit
B94E AD E9 FD  LDA &FDE9        ;else get data transfer call number
B951 4A        LSR A            ;test bit 0
B952 90 0A     BCC S95E         ;if reading or verifying data then exit
B954 A0 00     LDY #&00         ;else wait 295 milliseconds then exit:
.S956
B956 EA        NOP              ;allow extra head settling time
B957 EA        NOP              ;before writing
B958 CA        DEX
B959 D0 FB     BNE S956
B95B 88        DEY              ;this point reached every 1.1 milliseconds
B95C D0 F8     BNE S956
.S95E
B95E 60        RTS
.S95F                           ;Read ID and detect density
B95F 20 75 A8  JSR R875         ;save XY
B962 20 0C BE  JSR SE0C         ;page in main workspace
B965 20 F3 B9  JSR S9F3         ;issue Seek and Force Interrupt
B968 A2 05     LDX #&05         ;5 attempts to make, 3 in SD + 2 in DD
B96A 2C ED FD  BIT &FDED        ;if current density is single
B96D 50 13     BVC S982         ;then attempt in single density first
B96F CA        DEX              ;else only 2 attempts in DD + 2 in SD:
.S970
B970 AD ED FD  LDA &FDED        ;get density flag
B973 09 40     ORA #&40         ;set b6=1, double density
B975 A0 12     LDY #&12         ;18 sectors per track
B977 20 AC B9  JSR S9AC         ;execute Read Address at specified density
B97A F0 2D     BEQ S9A9         ;if record found then return success
B97C 2C ED FD  BIT &FDED        ;else test density flag
B97F 10 15     BPL S996         ;if b7=0 manual density then return failure
B981 CA        DEX              ;else decrement number of attempts remaining
.S982
B982 AD ED FD  LDA &FDED        ;get density flag
B985 29 BF     AND #&BF         ;set b6=0, single density
B987 A0 0A     LDY #&0A         ;10 sectors per track
B989 20 AC B9  JSR S9AC         ;execute Read Address at specified density
B98C F0 1B     BEQ S9A9         ;if record found then return success
B98E 2C ED FD  BIT &FDED        ;else test density flag
B991 10 03     BPL S996         ;if b7=0 manual density then return failure
B993 CA        DEX              ;else decrement number of attempts remaining
B994 D0 DA     BNE S970         ;if attempts remaining try double density
.S996
B996 AD ED FD  LDA &FDED        ;else set b6=0, single density
B999 29 BF     AND #&BF
B99B 8D ED FD  STA &FDED
B99E 20 D2 B8  JSR S8D2         ;set control latch for drive
B9A1 A9 0A     LDA #&0A         ;set 10 sectors per track
B9A3 8D EB FD  STA &FDEB
B9A6 A9 18     LDA #&18         ;fake WD1770 S4 = record not found
B9A8 60        RTS              ;fake WD1770 S3 = CRC error.
.S9A9
B9A9 A9 00     LDA #&00         ;fake WD1770 status = 0, succeeded.
B9AB 60        RTS
.S9AC                           ;Execute Read Address at specified density
B9AC 8D ED FD  STA &FDED        ;store density flag
B9AF 8C EB FD  STY &FDEB        ;store number of sectors per track:
.S9B2                           ;Execute Read Address command
B9B2 20 75 A8  JSR R875         ;save XY
B9B5 20 16 B9  JSR S916         ;seek logical track
B9B8 A0 0B     LDY #&0B         ;12 bytes to copy, &0D00..0B:
.S9BA
B9BA B9 BA BD  LDA &BDBA,Y      ;get byte of NMI read ID
B9BD 99 00 0D  STA &0D00,Y      ;store in NMI area
B9C0 88        DEY              ;loop until all bytes copied
B9C1 10 F7     BPL S9BA
B9C3 08        PHP              ;save interrupt state
B9C4 A6 BB     LDX &BB          ;test no. IDs to read
B9C6 F0 08     BEQ S9D0         ;0 = internal use, skip wait for index
B9C8 78        SEI              ;else disable interrupts
.S9C9
B9C9 AD F8 FC  LDA &FCF8        ;load FDC status register
B9CC 29 02     AND #&02         ;test WD1770 S1 = index
B9CE F0 F9     BEQ S9C9         ;loop until index pulse from drive
.S9D0
B9D0 A0 00     LDY #&00         ;then wait 640.5 microseconds
.S9D2
B9D2 88        DEY
B9D3 D0 FD     BNE S9D2
B9D5 A9 C0     LDA #&C0         ;WD1770 command &C0 = Read address
B9D7 8D F8 FC  STA &FCF8        ;write to FDC command register
B9DA 20 16 BD  JSR SD16         ;wait for command completion
B9DD D0 0B     BNE S9EA         ;if command succeeded
B9DF CE 05 0D  DEC &0D05        ;then backspace over CRC bytes
B9E2 CE 05 0D  DEC &0D05
B9E5 CA        DEX              ;decrement number of IDs to read
B9E6 30 02     BMI S9EA         ;if an internal call then finish
B9E8 D0 E6     BNE S9D0         ;else loop until all IDs read, then:
.S9EA
B9EA 28        PLP              ;restore interrupt state
B9EB AD F8 FC  LDA &FCF8        ;WD1770 S4 = record not found
B9EE 29 18     AND #&18         ;WD1770 S3 = CRC error
B9F0 4C 0C BE  JMP SE0C         ;mask off other bits, page in main workspace.
.S9F3                           ;Issue Seek and Force Interrupt
B9F3 20 D2 B8  JSR S8D2         ;set control latch for drive
B9F6 A9 18     LDA #&18         ;WD1770 command &18 = Seek w/spin up
B9F8 20 FA BC  JSR SCFA         ;write to FDC command register
B9FB A2 0F     LDX #&0F         ;wait 38 microseconds
.S9FD
B9FD CA        DEX
B9FE D0 FD     BNE S9FD
.SA00
BA00 A9 D0     LDA #&D0         ;WD1770 command &D0 = Force interrupt
BA02 4C FA BC  JMP SCFA         ;write to FDC command register and exit
.SA05                           ;Verify track
BA05 20 75 A8  JSR R875         ;save XY
BA08 A9 00     LDA #&00
BA0A 85 BB     STA &BB          ;sector number = 0
BA0C 85 A0     STA &A0          ;whole number of sectors to transfer
BA0E AD EB FD  LDA &FDEB        ;get number of sectors per track
BA11 85 A1     STA &A1          ;set number of sectors to transfer
BA13 A9 04     LDA #&04         ;set call number to &04, verify data
BA15 8D E9 FD  STA &FDE9        ;set data transfer call number
.SA18                           ;Transfer data L2
BA18 20 75 A8  JSR R875         ;save XY (inner)
BA1B 20 4C B7  JSR S74C         ;set Z=1 iff current drive is a RAM disc
BA1E D0 03     BNE SA23         ;if floppy then transfer data to disc L2
BA20 4C 67 BE  JMP SE67         ;else transfer data to paged RAM
.SA23                           ;Transfer data to disc L2
BA23 A5 A0     LDA &A0          ;save ?&A0, ?&A1 on stack
BA25 48        PHA
BA26 A5 A1     LDA &A1
BA28 48        PHA
BA29 20 D2 B8  JSR S8D2         ;set control latch for drive
BA2C 20 16 B9  JSR S916         ;seek logical track
BA2F A5 BA     LDA &BA          ;get logical track number
BA31 20 94 BC  JSR SC94         ;store physical position of head
BA34 20 FB BA  JSR SAFB         ;copy NMI read from disc/polling loop to NMI
BA37 AD EE FD  LDA &FDEE        ;get *OPT 9 saverom slot number
BA3A 8D 2D 0D  STA &0D2D        ;store in polling loop to page in on entry
BA3D AD E9 FD  LDA &FDE9        ;get data transfer call number
BA40 48        PHA              ;save on stack
BA41 29 05     AND #&05         ;if call=0 or 2, read (deleted) data
BA43 F0 09     BEQ SA4E         ;then branch
BA45 6A        ROR A            ;else if b2..0 = 1x0, A=&04 verify data
BA46 B0 10     BCS SA58
BA48 20 EF BA  JSR SAEF         ;then instruction at &0D06 = JMP &0D11
BA4B 4C 6A BA  JMP SA6A         ;discard byte from FDC data register
.SA4E
BA4E A5 A0     LDA &A0          ;increment MSB byte count if LSB >0
BA50 F0 02     BEQ SA54         ;not rounding up, converting number format;
BA52 E6 A1     INC &A1          ;Z=1 from both DECs means zero reached
.SA54
BA54 A0 07     LDY #&07         ;if call=0 or 2, read (deleted) data
BA56 D0 0F     BNE SA67         ;then data address is located at &0D07.
.SA58
BA58 A5 A0     LDA &A0          ;increment MSB byte count if LSB >0
BA5A F0 02     BEQ SA5E         ;not rounding up, converting number format;
BA5C E6 A1     INC &A1          ;Z=1 from both DECs means zero reached
.SA5E
BA5E A9 00     LDA #&00         ;if b0=1, A=1 or 3 write (deleted) data
BA60 85 A0     STA &A0          ;then clear ?&A0, write whole sectors
BA62 20 07 BB  JSR SB07         ;copy NMI write to disc to NMI area
BA65 A0 04     LDY #&04         ;data address is located at &0D04
.SA67
BA67 20 A0 BA  JSR SAA0         ;set data address in NMI ISR
.SA6A
BA6A A5 F4     LDA &F4          ;get Challenger ROM slot number
BA6C 8D 38 0D  STA &0D38        ;save in NMI area
BA6F A5 BB     LDA &BB          ;get start sector number
BA71 20 FE BC  JSR SCFE         ;write to FDC sector register
BA74 68        PLA              ;restore data transfer call number
BA75 29 07     AND #&07         ;mask bits 2..0
BA77 48        PHA              ;save it again
BA78 A8        TAY              ;transfer to Y
BA79 B9 52 BD  LDA &BD52,Y      ;get FDC command for call
BA7C 20 FA BC  JSR SCFA         ;write to FDC command register
BA7F A2 1E     LDX #&1E         ;wait 76 microseconds
.SA81
BA81 CA        DEX
BA82 D0 FD     BNE SA81
BA84 20 2C 0D  JSR &0D2C        ;page SROM in and wait until finished L0
BA87 20 0C BE  JSR SE0C         ;page in main workspace
BA8A 68        PLA
BA8B A8        TAY
BA8C 20 27 BD  JSR SD27         ;load FDC status register and store b6..0
BA8F 39 57 BD  AND &BD57,Y      ;apply status mask from table to set Z
BA92 A8        TAY              ;present FDC status register in A
BA93 20 8C BC  JSR SC8C         ;store head position for this drive
.SA96
BA96 68        PLA              ;restore ?&A0, ?&A1 from stack
BA97 85 A1     STA &A1
BA99 68        PLA
BA9A 85 A0     STA &A0
BA9C 98        TYA
BA9D 4C 0C BE  JMP SE0C         ;page in main workspace
.SAA0                           ;Set data address in NMI ISR
BAA0 AD E9 FD  LDA &FDE9        ;test data transfer call number
BAA3 30 2A     BMI SACF         ;if b7=1 then transferring to JIM, branch
BAA5 AD CC FD  LDA &FDCC        ;else test Tube data transfer flag
BAA8 F0 1A     BEQ SAC4         ;if transferring data to Tube
BAAA A9 E5     LDA #&E5         ;then paste address of R3DATA at &0D00+Y
BAAC 99 00 0D  STA &0D00,Y
BAAF A9 FE     LDA #&FE
BAB1 99 01 0D  STA &0D01,Y
BAB4 A9 4C     LDA #&4C         ;instruction at &0D09 = JMP &0D11
BAB6 8D 09 0D  STA &0D09        ;do not increment R3DATA address
BAB9 A9 11     LDA #&11
BABB 8D 0A 0D  STA &0D0A
BABE A9 0D     LDA #&0D
BAC0 8D 0B 0D  STA &0D0B
BAC3 60        RTS
.SAC4
BAC4 A5 A6     LDA &A6          ;else copy data pointer to NMI ISR at &0D00+Y
BAC6 99 00 0D  STA &0D00,Y
BAC9 A5 A7     LDA &A7
BACB 99 01 0D  STA &0D01,Y
BACE 60        RTS
.SACF                           ;Enable JIM select in NMI read from disc
BACF A9 20     LDA #&20         ;&0D0E = JSR &0D3D
BAD1 8D 0E 0D  STA &0D0E
BAD4 A9 3D     LDA #&3D
BAD6 8D 0F 0D  STA &0D0F
BAD9 A9 0D     LDA #&0D
BADB 8D 10 0D  STA &0D10
BADE A5 A6     LDA &A6          ;insert 2MSB of JIM address = LSB page no.
BAE0 8D 41 0D  STA &0D41
BAE3 8D FF FC  STA &FCFF        ;and page it in
BAE6 A5 A7     LDA &A7          ;insert MSB of JIM address = MSB page no.
BAE8 8D 4B 0D  STA &0D4B
BAEB 8D FE FC  STA &FCFE        ;and page it in
BAEE 60        RTS
.SAEF                           ;Copy NMI verify to NMI area
BAEF A0 02     LDY #&02         ;3 bytes to copy, &0D06..8:
.SAF1
BAF1 B9 C6 BD  LDA &BDC6,Y      ;get byte of NMI verify
BAF4 99 06 0D  STA &0D06,Y      ;store in NMI area
BAF7 88        DEY              ;loop until all bytes copied
BAF8 10 F7     BPL SAF1
BAFA 60        RTS
.SAFB                           ;Copy NMI read from disc/polling loop to NMI
BAFB A0 4F     LDY #&4F         ;80 bytes to copy, &0D00..4F:
.SAFD
BAFD B9 5C BD  LDA &BD5C,Y      ;get byte of NMI read from disc/polling loop
BB00 99 00 0D  STA &0D00,Y      ;store in NMI area
BB03 88        DEY              ;loop until all bytes copied
BB04 10 F7     BPL SAFD
BB06 60        RTS
.SB07                           ;Copy NMI write to disc to NMI area
BB07 A0 0D     LDY #&0D         ;14 bytes to copy, &0D03..10:
.SB09
BB09 B9 AC BD  LDA &BDAC,Y      ;get byte of NMI write to disc
BB0C 99 03 0D  STA &0D03,Y      ;patch NMI read to disc routine with it
BB0F 88        DEY              ;loop until all bytes copied
BB10 10 F7     BPL SB09
BB12 A9 FC     LDA #&FC         ;enable 123 microsecond delay
BB14 8D 23 0D  STA &0D23        ;before interrupting write operation
BB17 60        RTS              ;so that FDC will write CRC of sector
.SB18                           ;Create ID table and format track
BB18 A9 0A     LDA #&0A         ;set A = 10 sectors per track
BB1A 2C ED FD  BIT &FDED        ;if double density format
BB1D 50 02     BVC SB21
BB1F A9 12     LDA #&12         ;then set A = 18 sectors per track
.SB21
BB21 85 A6     STA &A6          ;store as limit to sector count
BB23 8D EB FD  STA &FDEB        ;store as no. sectors per track of disc
BB26 0A        ASL A            ;multiply by 4
BB27 0A        ASL A
BB28 85 A7     STA &A7          ;store as size of CHRN table
BB2A A6 BB     LDX &BB          ;set X = number of first sector
BB2C A0 00     LDY #&00         ;(inverse track skew) Y=0 CHRN tbl index
.SB2E
BB2E A5 BA     LDA &BA          ;Get logical track number
BB30 99 61 FD  STA &FD61,Y      ;store cylinder number  C
BB33 C8        INY
BB34 A9 00     LDA #&00         ;head number = 0
BB36 99 61 FD  STA &FD61,Y      ;store head humber      H
BB39 C8        INY
BB3A 8A        TXA              ;transfer sector number to A
BB3B 99 61 FD  STA &FD61,Y      ;store record number    R
BB3E C8        INY
BB3F A9 01     LDA #&01         ;size code = 1, 256-byte sector
BB41 99 61 FD  STA &FD61,Y      ;store size code        N
BB44 C8        INY
BB45 E8        INX              ;increment sector number
BB46 E4 A6     CPX &A6          ;has it reached no. sectors per track?
BB48 90 02     BCC SB4C
BB4A A2 00     LDX #&00         ;if so then wrap around to 0
.SB4C
BB4C C4 A7     CPY &A7          ;has table offset reached 4x s.p.t?
BB4E 90 DE     BCC SB2E         ;if not then loop
BB50 A9 61     LDA #&61         ;else set pointer to start of CHRN table:
BB52 85 A6     STA &A6
BB54 A9 FD     LDA #&FD
BB56 85 A7     STA &A7
.SB58                           ;Format track
BB58 A9 12     LDA #&12         ;set run table pointer to &000612 in JIM
BB5A 85 A4     STA &A4          ;(page breaks occur 5/8 through fifth,
BB5C A9 06     LDA #&06         ;1/8 through eleventh and in gap2 of
BB5E 48        PHA              ;seventeenth sector of track.)
BB5F 85 A5     STA &A5
BB61 A2 00     LDX #&00         ;point to single density table, X = &00
BB63 2C ED FD  BIT &FDED        ;if double density format
BB66 50 02     BVC SB6A
BB68 A2 23     LDX #&23         ;then point to double density table, X = &23
.SB6A
BB6A AD EB FD  LDA &FDEB        ;get number of sectors per track
BB6D 85 A2     STA &A2          ;set as counter
BB6F 20 3A BC  JSR SC3A         ;page in JIM page 6..9
BB72 A0 05     LDY #&05         ;set Y = 5 as counter:
.SB74
BB74 20 BB BB  JSR SBBB         ;add entry to track format RLE table
BB77 88        DEY              ;loop until 5 entries added
BB78 D0 FA     BNE SB74         ;this copies gap 5, IDAM and start of gap 1
BB7A 86 A3     STX &A3          ;X points to repeating sector block
.SB7C
BB7C A6 A3     LDX &A3          ;reset X to start of sector block
.SB7E
BB7E 20 BB BB  JSR SBBB         ;add entry to track format RLE table
BB81 90 FB     BCC SB7E         ;loop until terminator byte reached
BB83 C6 A2     DEC &A2          ;decrement number of sectors remaining
BB85 D0 F5     BNE SB7C         ;loop until all sectors added to track
BB87 A9 00     LDA #&00         ;data byte = &00 (run length = &10 or &16)
BB89 20 14 BC  JSR SC14         ;add gap 4 to table
BB8C 20 0C BE  JSR SE0C         ;page in main workspace
BB8F 20 16 B9  JSR S916         ;seek logical track
BB92 A2 FF     LDX #&FF
BB94 A0 10     LDY #&10         ;A = &10
BB96 2C ED FD  BIT &FDED        ;if double density format
BB99 50 04     BVC SB9F
BB9B A0 28     LDY #&28         ;then A = &28
BB9D A2 4E     LDX #&4E
.SB9F
BB9F 84 A0     STY &A0          ;set number of filler bytes in gap 5
BBA1 68        PLA
BBA2 20 1D BE  JSR SE1D         ;page in JIM page in A
BBA5 8E 92 FD  STX &FD92        ;set filler byte in gap 5
BBA8 A0 3C     LDY #&3C         ;61 bytes to copy, &0D00..3D:
.SBAA
BBAA B9 C9 BD  LDA &BDC9,Y      ;get byte of NMI format code
BBAD 99 00 0D  STA &0D00,Y      ;store in NMI handler area
BBB0 88        DEY              ;loop until all bytes transferred
BBB1 10 F7     BPL SBAA
BBB3 A9 F4     LDA #&F4         ;&F4=Write track, settling delay
BBB5 20 FA BC  JSR SCFA         ;write to FDC command register
BBB8 4C 16 BD  JMP SD16         ;wait for command completion and exit.
.SBBB                           ;Add entry to track format RLE table
BBBB 8A        TXA              ;save ROM table offset
BBBC 48        PHA
BBBD 98        TYA              ;save number of sectors remaining
BBBE 48        PHA
BBBF A0 00     LDY #&00         ;y=&00
BBC1 38        SEC
BBC2 BD 42 BC  LDA &BC42,X      ;get run length from ROM table
BBC5 30 12     BMI SBD9         ;if b7=1 then process special entry
BBC7 F0 09     BEQ SBD2         ;if the terminator byte then finish C=1
BBC9 85 A0     STA &A0          ;else store run length in zero page
BBCB BD 43 BC  LDA &BC43,X      ;get data byte from ROM table
BBCE 20 14 BC  JSR SC14         ;store run in table
.SBD1
BBD1 18        CLC              ;c=0, sector not completed
.SBD2
BBD2 68        PLA              ;restore number of sectors remaining
BBD3 A8        TAY
BBD4 68        PLA              ;restore ROM table offset
BBD5 AA        TAX
BBD6 E8        INX              ;add 2 to ROM table offset
BBD7 E8        INX
BBD8 60        RTS
.SBD9                           ;Process special table entry (length=&FF)
BBD9 BD 43 BC  LDA &BC43,X      ;get data byte from ROM format table
BBDC D0 22     BNE SC00         ;if non-zero then add sector data area
BBDE A9 01     LDA #&01         ;else add ID bytes. run length of bytes = 1
BBE0 85 A0     STA &A0          ;store run length in zero page
BBE2 A2 04     LDX #&04         ;4 bytes in sector ID:
.SBE4
BBE4 20 0C BE  JSR SE0C
BBE7 A0 00     LDY #&00         ;y=0 for user memory load
BBE9 20 EC A4  JSR R4EC         ;get data byte from user memory
BBEC 20 3A BC  JSR SC3A         ;page in JIM page 6..9
BBEF 20 14 BC  JSR SC14         ;store run in table
BBF2 E6 A6     INC &A6          ;increment CHRN table pointer
BBF4 D0 02     BNE SBF8         ;carry out to high byte
BBF6 E6 A7     INC &A7
.SBF8
BBF8 CA        DEX              ;loop until 4 ID bytes stored
BBF9 D0 E9     BNE SBE4
BBFB 85 A1     STA &A1          ;store last byte read = N = size code
BBFD 4C D1 BB  JMP SBD1         ;restore XY and return
.SC00                           ;Add sector data area
BC00 A6 A1     LDX &A1          ;load sector size code
BC02 BD 88 BC  LDA &BC88,X      ;get run length from table
BC05 85 A0     STA &A0          ;store in zero page
BC07 A2 08     LDX #&08         ;repeat prescribed run 8 times:
BC09 A9 E5     LDA #&E5         ;A=&E5 = sector filler byte
.SC0B
BC0B 20 14 BC  JSR SC14         ;store run in table
BC0E CA        DEX              ;loop until 8 copies of run stored
BC0F D0 FA     BNE SC0B
BC11 4C D1 BB  JMP SBD1         ;restore XY and return
.SC14                           ;Store run in table
BC14 48        PHA              ;save data byte
BC15 A4 A4     LDY &A4          ;get offset into data/run tables
BC17 99 80 FD  STA &FD80,Y      ;store data byte in data table
BC1A A5 A0     LDA &A0          ;get run length
BC1C 99 00 FD  STA &FD00,Y      ;store run length in run table
BC1F A5 A4     LDA &A4
BC21 D0 08     BNE SC2B         ;if pointers are on a page boundary
BC23 AD 00 FD  LDA &FD00        ;then set b7=1 of run length
BC26 09 80     ORA #&80
BC28 8D 00 FD  STA &FD00
.SC2B
BC2B E6 A4     INC &A4          ;increment data table pointer
BC2D 10 09     BPL SC38         ;if LSB of pointer reaches &80
BC2F A9 00     LDA #&00         ;then the tables fill each half page
BC31 85 A4     STA &A4          ;so reset LSB of pointer = &00
BC33 E6 A5     INC &A5          ;and carry out to high byte
BC35 20 3A BC  JSR SC3A
.SC38
BC38 68        PLA              ;restore data byte and return
BC39 60        RTS
.SC3A                           ;page in JIM page 6..9
BC3A 48        PHA              ;save A
BC3B A5 A5     LDA &A5          ;get MSB of data table pointer
BC3D 20 1D BE  JSR SE1D         ;page in JIM page in A
BC40 68        PLA
BC41 60        RTS
;RLE tables of formatting bytes
BC42 EQUB &10,&FF
BC44 EQUB &03,&00               ;  6x &00 synchronization bytes }
BC46 EQUB &03,&00
BC48 EQUB &01,&FC               ;  1x &FC index address mark (clock &D7)
BC4A EQUB &0B,&FF               ; 11x &FF filler bytes          } Gap 1
;block repeated for each sector
BC4C EQUB &03,&00               ;  6x &00 synchronization bytes }
BC4E EQUB &03,&00
BC50 EQUB &01,&FE               ;  1x &FE ID address mark (clock &C7)
BC52 EQUB &FF,&00               ;id bytes are inserted here
BC54 EQUB &01,&F7               ;  1x &F7 CRC character insert (2 bytes)
BC56 EQUB &0B,&FF               ; 11x &FF filler bytes          } Gap 2
BC58 EQUB &03,&00               ;  6x &00 synchronization bytes }
BC5A EQUB &03,&00
BC5C EQUB &01,&FB               ;  1x &FB data address mark (clock &C7)
BC5E EQUB &FF,&01               ;data bytes are inserted here
BC60 EQUB &01,&F7               ;  1x &F7 CRC character insert (2 bytes)
BC62 EQUB &10,&FF               ; 16x &FF filler bytes          } Gap 3...
;end of repeated block
BC64 EQUB &00                   ;terminator byte (not part of format)
;Double density
BC65 EQUB &28,&4E               ; 40x &4E filler bytes          }
BC67 EQUB &0C,&00               ; 12x &00 preamble bytes        } Gap 5
BC69 EQUB &03,&F6               ;  3x &F6 synchronization bytes }
BC6B EQUB &01,&FC
BC6D EQUB &19,&4E               ; 25x &4E filler bytes          } Gap 1
;block repeated for each sector
BC6F EQUB &0C,&00               ; 12x &00 preamble bytes        }
BC71 EQUB &03,&F5               ;  3x &F5 synchronization bytes }
BC73 EQUB &01,&FE
BC75 EQUB &FF,&00               ;id bytes are inserted here
BC77 EQUB &01,&F7               ;  1x &F7 CRC character insert (2 bytes)
BC79 EQUB &16,&4E               ; 22x &4E filler bytes          }
BC7B EQUB &0C,&00
BC7D EQUB &03,&F5               ;  3x &F5 synchronization bytes }
BC7F EQUB &01,&FB               ;  1x &FB data address mark
BC81 EQUB &FF,&01               ;data bytes are inserted here
BC83 EQUB &01,&F7
BC85 EQUB &16,&4E               ; 22x &4E filler bytes          } Gap 3...
;end of repeated block
BC87 EQUB &00                   ;terminator byte (not part of format)
BC88 EQUB &10
BC89 EQUB &20                   ;8x runs of  32 bytes for  256-byte sectors
BC8A EQUB &40                   ;8x runs of  64 bytes for  512-byte sectors
BC8B EQUB &80                   ;8x runs of 128 bytes for 1024-byte sectors
.SC8C                           ;Store per-drive head position
BC8C A5 BA     LDA &BA          ;get logical track number of disc operation
BC8E 2C EA FD  BIT &FDEA        ;test double-stepping flag
BC91 50 01     BVC SC94         ;if b6=1 then double stepping is enabled
BC93 0A        ASL A            ;so double track number:
.SC94                           ;Store physical position of head
BC94 48        PHA              ;save physical track
BC95 20 A0 BC  JSR SCA0         ;set X=physical floppy unit for current drive
BC98 68        PLA              ;restore physical track
BC99 9D EF FD  STA &FDEF,X      ;store physical track number for drive:
.SC9C                           ;Write to FDC track register
BC9C 8D F9 FC  STA &FCF9
BC9F 60        RTS
.SCA0                           ;Set X=physical floppy unit for current drive
BCA0 20 D9 AA  JSR RAD9         ;map current volume to physical volume
BCA3 29 07     AND #&07         ;mask drive no in b2..0 mask off volume letter
BCA5 A2 02     LDX #&02         ;preset X=2 to select third floppy drive
BCA7 C9 06     CMP #&06         ;if physical drive number = 6 or 7
BCA9 B0 03     BCS SCAE         ;then return X=2
BCAB 29 01     AND #&01         ;else return X=0 drv 0 or 2, X=1 drv 1 or 3
BCAD AA        TAX
.SCAE
BCAE 60        RTS
.SCAF                           ;Raise "Disk fault" error
BCAF 20 92 A8  JSR R892         ;begin error message with "Disk fault "
BCB2 EQUB &C5
BCB3 EQUS "fault "
BCB9 EQUB &EA
BCBA AD F3 FD  LDA &FDF3
BCBD 20 78 A9  JSR R978         ;print hex byte
BCC0 20 D3 A8  JSR R8D3         ;print " at Trk "
BCC3 EQUS " at Trk "
BCCB EA        NOP
BCCC A5 BA     LDA &BA          ;get track number
BCCE 20 78 A9  JSR R978         ;print hex byte
BCD1 20 D3 A8  JSR R8D3         ;print ", Sct "
BCD4 EQUS ", Sct "
BCDA EA        NOP
BCDB A5 BB     LDA &BB          ;get sector number
BCDD 20 78 A9  JSR R978         ;print hex byte
BCE0 4C F8 A8  JMP R8F8         ;terminate error message, raise error
.SCE3                           ;Raise "Disk not formatted" error
BCE3 20 AD A8  JSR R8AD
BCE6 EQUB &C5
BCE7 EQUS "Disk not formatted"
BCF9 EQUB &00
.SCFA                           ;Write to FDC command register
BCFA 8D F8 FC  STA &FCF8
BCFD 60        RTS
.SCFE                           ;Write to FDC sector register
BCFE 8D FA FC  STA &FCFA
BD01 60        RTS
.SD02                           ;Write to FDC data register
BD02 8D FB FC  STA &FCFB
BD05 60        RTS
.SD06                           ;Set Z=1 iff drive motor is on
BD06 20 4C B7  JSR S74C         ;set Z=1 iff current drive is a RAM disc
BD09 F0 08     BEQ SD13         ;if RAM disc then treat as motor on
BD0B AD F8 FC  LDA &FCF8        ;else load FDC status register
BD0E 49 80     EOR #&80         ;return A=0, Z=1 iff motor is on
BD10 29 80     AND #&80         ;mask b7 extract WD1770 S7 = motor on
BD12 60        RTS
.SD13
BD13 A9 00     LDA #&00         ;return A=0, Z=1 indicating motor on.
BD15 60        RTS
.SD16                           ;Wait for command completion
BD16 20 75 A8  JSR R875         ;save XY
BD19 A2 FF     LDX #&FF         ;wait 638 microseconds
.SD1B
BD1B CA        DEX
BD1C D0 FD     BNE SD1B
.SD1E
BD1E 20 33 BD  JSR SD33         ;poll for ESCAPE
BD21 AD F8 FC  LDA &FCF8        ;load FDC status register
BD24 6A        ROR A            ;place bit 0 in carry flag
BD25 B0 F7     BCS SD1E         ;loop until b0=0 WD1770 S0 = busy
.SD27
BD27 AD F8 FC  LDA &FCF8        ;load FDC status register
BD2A 29 7F     AND #&7F         ;mask bits 6..0 ignore WD1770 S7 = motor on
BD2C 20 0C BE  JSR SE0C
BD2F 8D F3 FD  STA &FDF3        ;save final status
BD32 60        RTS
.SD33                           ;Poll for ESCAPE
BD33 A5 B9     LDA &B9          ;if >0 disc operation is uninterruptible
BD35 F0 1A     BEQ SD51         ;then return
BD37 24 FF     BIT &FF          ;else if ESCAPE pressed
BD39 10 16     BPL SD51
BD3B 20 00 BA  JSR SA00         ;then send Force Interrupt
BD3E A9 00     LDA #&00         ;RES b4=0, reset WD 1770 floppy controller
BD40 8D FC FC  STA &FCFC        ;store in control latch
BD43 20 8F A9  JSR R98F         ;acknowledge ESCAPE condition
BD46 20 AD A8  JSR R8AD         ;raise "Escape" error.
BD49 EQUB &11
BD4A EQUS "Escape"
BD50 EQUB &00
.SD51
BD51 60        RTS
;Table of WD1770 FDC commands for data transfer call numbers 0..4
BD52 EQUB &90
BD53 EQUB &B4                   ;&01 = Write data
BD54 EQUB &90
BD55 EQUB &B5                   ;&03 = Write deleted data
BD56 EQUB &90                   ;&04 = Verify data
;Table of status mask bytes for data transfer call numbers 0..4
BD57 EQUB &3C
BD58 EQUB &7C                   ;&01 = Write data: {WriteProtect RecordType}
BD59 EQUB &1C                   ;{}
BD5A EQUB &5C                   ;&03 = Write deleted data: {WriteProtect}
BD5B EQUB &3C                   ;&04 = Verify data: {RecordType}
                                ;NMI read from disc, &0D00..2B
                                ;opcode read 4+e..8 microseconds after NMI
                                ;(up to 13.5 us if code running in 1 MHz mem)
BD5C 8D 2A 0D  STA &0D2A        ;save accumulator to restore on exit
BD5F AD FB FC  LDA &FCFB        ;read FDC data register
BD62 8D 00 FD  STA &FD00        ;store in user memory or R3DATA
BD65 EE 07 0D  INC &0D07        ;increment user memory address
BD68 D0 03     BNE SD6D         ;carry out to high byte
BD6A EE 08 0D  INC &0D08
.SD6D
BD6D C6 A0     DEC &A0          ;decrement count of bytes to transfer
BD6F D0 14     BNE SD85         ;(&0101 = 1; &0000 = 0)
BD71 C6 A1     DEC &A1          ;if count has not reached zero
BD73 D0 10     BNE SD85         ;then restore A and return from interrupt
BD75 A9 40     LDA #&40         ;else set 0D00=RTI; ignore further NMIs
BD77 8D 00 0D  STA &0D00        ;ISR safe by 23+e..30.5 us after NMI
BD7A A9 CE     LDA #&CE         ;write complete by 25.5+e..33 us
BD7C 69 01     ADC #&01         ;wait 123 microseconds (if loop enabled)
BD7E 90 00     BCC SD80         ;0D23=&FC loops back to &0D20
.SD80
BD80 A9 D0     LDA #&D0         ;FDC command &D0 = Force Interrupt
BD82 8D F8 FC  STA &FCF8        ;write to FDC command register
.SD85
BD85 A9 00     LDA #&00         ;restore value of A on entry
BD87 40        RTI              ;return from interrupt
                                ;NMI polling loop, &0D2C..3C
BD88 A9 0E     LDA #&0E         ;page *OPT 9 saverom slot in
BD8A 8D 30 FE  STA &FE30
.SD8D
BD8D AD F8 FC  LDA &FCF8        ;load FDC status register
BD90 6A        ROR A            ;place bit 0 in carry flag
BD91 B0 FA     BCS SD8D         ;loop until b0=0 WD1770 S0 = busy
BD93 A9 00     LDA #&00         ;page Challenger ROM back in
BD95 8D 30 FE  STA &FE30
BD98 60        RTS              ;return
                                ;JIM page select routine, &0D3D..4F
                                ;made reachable by JSR installed at &BACF
BD99 EE 41 0D  INC &0D41        ;increment LSB of JIM page address
BD9C A9 00     LDA #&00         ;set LSB of JIM page address
BD9E 8D FF FC  STA &FCFF
BDA1 D0 08     BNE SDAB         ;if carry out
BDA3 EE 4B 0D  INC &0D4B        ;then increment MSB of JIM page address
BDA6 A9 00     LDA #&00         ;set MSB of JIM page address
BDA8 8D FE FC  STA &FCFE
.SDAB
BDAB 60        RTS
                                ;NMI write to disc, &0D03..10
BDAC AD 00 FD  LDA &FD00
BDAF 8D FB FC  STA &FCFB
BDB2 EE 04 0D  INC &0D04
BDB5 D0 03     BNE SDBA
BDB7 EE 05 0D  INC &0D05
.SDBA
                                ;NMI read ID, &0D00..0B
BDBA 48        PHA
BDBB AD FB FC  LDA &FCFB        ;load FDC data register
BDBE 8D 0C 0D  STA &0D0C        ;store ID byte in buffer
BDC1 EE 05 0D  INC &0D05        ;increment offset
BDC4 68        PLA
BDC5 40        RTI
                                ;NMI verify, &0D06..08
BDC6 4C 11 0D  JMP &0D11        ;discard byte from FDC data register
                                ;NMI format, &0D00..3C
BDC9 48        PHA              ;save A on entry
BDCA AD 92 FD  LDA &FD92        ;fetch current data byte
BDCD 8D FB FC  STA &FCFB        ;write to FDC data register
BDD0 C6 A0     DEC &A0          ;decrement run counter
BDD2 D0 16     BNE SDEA         ;if all bytes in run written
BDD4 EE 02 0D  INC &0D02        ;then increment data byte address low
BDD7 D0 23     BNE SDFC         ;if no carry then fetch next run length
BDD9 A9 80     LDA #&80         ;else reset data address low = &80
BDDB 8D 02 0D  STA &0D02
BDDE A9 07     LDA #&07         ;page in next JIM page
BDE0 8D FF FC  STA &FCFF
BDE3 AD 00 FD  LDA &FD00        ;fetch next run length marked b7=1
BDE6 85 A0     STA &A0          ;set run counter
.SDE8
BDE8 68        PLA              ;restore A on entry
BDE9 40        RTI              ;exit
.SDEA
BDEA 10 FC     BPL SDE8         ;if run still in progress then exit
BDEC A5 A0     LDA &A0          ;else page was crossed last time:
BDEE 29 7F     AND #&7F         ;mask off page marker in b7
BDF0 85 A0     STA &A0          ;update run counter
BDF2 A9 00     LDA #&00         ;reset run length address low = &00
BDF4 8D 37 0D  STA &0D37
BDF7 EE 16 0D  INC &0D16        ;increment data byte address high
BDFA 68        PLA              ;restore A on entry
BDFB 40        RTI              ;exit
.SDFC
BDFC EE 37 0D  INC &0D37        ;increment run length address
BDFF AD 12 FD  LDA &FD12        ;fetch next run length
BE02 85 A0     STA &A0          ;set run counter
BE04 68        PLA              ;restore A on entry
BE05 40        RTI              ;exit
                                ;unreachable code
BE06 EA        NOP
.SE07                           ;Page in auxiliary workspace
BE07 48        PHA
BE08 A9 00     LDA #&00
BE0A F0 12     BEQ SE1E
.SE0C                           ;Page in main workspace
BE0C 48        PHA
BE0D A9 01     LDA #&01
BE0F D0 0D     BNE SE1E
.SE11                           ;Page in catalogue sector 0
BE11 48        PHA
BE12 A9 02     LDA #&02
BE14 D0 08     BNE SE1E
.SE16                           ;Page in catalogue sector 1
BE16 48        PHA
BE17 A9 03     LDA #&03
BE19 D0 03     BNE SE1E
.SE1B                           ;Page in line buffer
BE1B A9 09     LDA #&09
.SE1D                           ;Page in JIM page in A
BE1D 48        PHA
.SE1E
BE1E 8D FF FC  STA &FCFF        ;store LSB JIM paging register
BE21 A9 00     LDA #&00
BE23 8D FE FC  STA &FCFE        ;set MSB JIM paging register = &00
BE26 68        PLA              ;restore A on entry
BE27 60        RTS
                                ;ChADFS ROM call 4
BE28 20 88 AD  JSR RD88         ;claim NMI
BE2B 20 0C BE  JSR SE0C         ;page in main workspace
BE2E A9 01     LDA #&01         ;data transfer call &01 = write data
BE30 8D E9 FD  STA &FDE9
BE33 A9 00     LDA #&00         ;transfer size = 512 bytes
BE35 85 A0     STA &A0
BE37 A9 02     LDA #&02
BE39 85 A1     STA &A1
BE3B A9 00     LDA #&00         ;source address = HAZEL, &C000
BE3D 85 A6     STA &A6
BE3F A9 C0     LDA #&C0
BE41 85 A7     STA &A7
BE43 A9 00     LDA #&00         ;b7=0 transfer from host
BE45 8D CC FD  STA &FDCC
BE48 A9 00     LDA #&00         ;starting sector/LBA = &0000
BE4A 85 BA     STA &BA
BE4C 85 BB     STA &BB
BE4E A9 04     LDA #&04         ;destination physical drive = 4
BE50 20 7C BE  JSR SE7C         ;transfer data to paged RAM
BE53 A9 C9     LDA #&C9         ;source address = HAZEL, &C900
BE55 85 A7     STA &A7
BE57 A9 02     LDA #&02         ;starting sector/LBA = &0002
BE59 85 BB     STA &BB
BE5B A9 05     LDA #&05         ;transfer size = 1280 bytes
BE5D 85 A1     STA &A1
BE5F A9 04     LDA #&04         ;destination physical drive = 4
BE61 20 7C BE  JSR SE7C         ;transfer data to paged RAM
BE64 A9 00     LDA #&00         ;fake WD1770 status = 0, succeeded.
BE66 60        RTS
.SE67                           ;Transfer data to paged RAM
BE67 20 0C BE  JSR SE0C         ;page in main workspace
BE6A A0 10     LDY #&10
BE6C AD ED FD  LDA &FDED        ;get density flag
BE6F 4D FE FD  EOR &FDFE        ;compare with RAM disc density flag
BE72 29 40     AND #&40         ;mask bit 6 = double density
BE74 F0 03     BEQ SE79         ;if not matched
BE76 A9 10     LDA #&10         ;WD1770 S4 = record not found
BE78 60        RTS
.SE79
BE79 20 D9 AA  JSR RAD9         ;map current volume to physical volume
.SE7C
BE7C A0 0A     LDY #&0A         ;volume 4 starts at JIM address &000A00
BE7E A2 00     LDX #&00
BE80 C9 04     CMP #&04         ;if physical drive is not 4
BE82 F0 04     BEQ SE88
BE84 A0 00     LDY #&00         ;then volume starts at JIM address &040000
BE86 A2 04     LDX #&04
.SE88
BE88 A5 A0     LDA &A0          ;save ?&A0, ?&A1 on stack
BE8A 48        PHA
BE8B A5 A1     LDA &A1
BE8D 48        PHA
BE8E 8A        TXA              ;save volume start address in YX on stack
BE8F 48        PHA              ;MSB first
BE90 98        TYA
BE91 48        PHA
BE92 A5 A0     LDA &A0          ;increment MSB byte count if LSB >0
BE94 F0 02     BEQ SE98         ;not rounding up, converting number format;
BE96 E6 A1     INC &A1          ;Z=1 from both DECs means zero reached
.SE98
BE98 A0 46     LDY #&46         ;71 bytes to copy, &0D00..46:
.SE9A
BE9A B9 2F BF  LDA &BF2F,Y      ;get byte of RAM disc transfer code
BE9D 99 00 0D  STA &0D00,Y      ;store in NMI handler area
BEA0 88        DEY              ;loop until all bytes transferred
BEA1 10 F7     BPL SE9A
BEA3 AD E9 FD  LDA &FDE9        ;get data transfer call number
BEA6 30 4E     BMI SEF6         ;if data address in JIM space then branch
BEA8 D0 16     BNE SEC0         ;else if =0 read data
BEAA A5 A6     LDA &A6          ;then paste user memory address at &0D22,3
BEAC 8D 22 0D  STA &0D22
BEAF A5 A7     LDA &A7
BEB1 8D 23 0D  STA &0D23
BEB4 AD CC FD  LDA &FDCC        ;test Tube transfer flag
BEB7 F0 5D     BEQ SF16         ;if b7=0 then an I/O transfer, branch
BEB9 A9 8D     LDA #&8D         ;else instruction at &0D21 = STA &FEE5
BEBB A0 03     LDY #&03
BEBD 4C D8 BE  JMP SED8         ;modify RAM transfer code for Tube.
.SEC0                           ;Modify RAM transfer code for write
BEC0 A5 A6     LDA &A6          ;paste user memory address at &0D1F,20
BEC2 8D 1F 0D  STA &0D1F
BEC5 A5 A7     LDA &A7
BEC7 8D 20 0D  STA &0D20
BECA A9 20     LDA #&20         ;0D27=INC &0D20
BECC 8D 28 0D  STA &0D28        ;increment user memory address
BECF AD CC FD  LDA &FDCC        ;test Tube transfer flag
BED2 F0 42     BEQ SF16         ;if b7=0 then an I/O transfer, branch
BED4 A9 AD     LDA #&AD         ;else instruction at &0D1E = LDA &FEE5
BED6 A0 00     LDY #&00
.SED8                           ;Modify RAM transfer code for Tube
BED8 99 1E 0D  STA &0D1E,Y      ;store opcode LDA abs at &D1E/STA abs at &D21
BEDB A9 E5     LDA #&E5         ;store address of R3DATA, &FEE5
BEDD 99 1F 0D  STA &0D1F,Y      ;at &0D1F,20 or &0D22,3
BEE0 A9 FE     LDA #&FE
BEE2 99 20 0D  STA &0D20,Y
BEE5 A9 F4     LDA #&F4         ;0D25=BNE &0D1B
BEE7 8D 26 0D  STA &0D26        ;enable 25 microsecond interval per byte
BEEA A9 E1     LDA #&E1         ;0D38=BNE &0D1B
BEEC 8D 39 0D  STA &0D39        ;enable 38.5 microsecond delay to next page
BEEF A9 AD     LDA #&AD         ;0D27=LDA &0D23
BEF1 8D 27 0D  STA &0D27        ;do not increment R3DATA address
BEF4 D0 20     BNE SF16         ;branch (always)
.SEF6                           ;Copy data between JIM pages
BEF6 A0 31     LDY #&31         ;50 bytes to copy, &0D00..31:
.SEF8
BEF8 B9 76 BF  LDA &BF76,Y      ;get byte of RAM disc copy code
BEFB 99 00 0D  STA &0D00,Y      ;store in NMI handler area
BEFE 88        DEY              ;loop until all bytes transferred
BEFF 10 F7     BPL SEF8
BF01 A0 00     LDY #&00         ;LBA goes to &0D06,01
BF03 A2 12     LDX #&12         ;JIM page number goes to &0D13
BF05 AD E9 FD  LDA &FDE9        ;get data transfer call number
BF08 29 7F     AND #&7F         ;mask bits 0..6
BF0A F0 04     BEQ SF10         ;if not =0, read data
BF0C A0 0D     LDY #&0D         ;then LBA goes to &0D13,0E
BF0E A2 05     LDX #&05         ;JIM page number goes to &0D06
.SF10
BF10 A5 A6     LDA &A6
BF12 9D 01 0D  STA &0D01,X      ;paste JIM page number at &0D06/13
BF15 AD A0 11  LDA &11A0        ;BF16=LDY #&11
.SF16
BF16 A0 11     LDY #&11         ;LBA goes to &0D17,12
BF18 18        CLC
BF19 68        PLA              ;restore LSB volume start address
BF1A 65 BB     ADC &BB          ;add LSB relative LBA
BF1C 99 06 0D  STA &0D06,Y      ;paste LSB absolute LBA at &0D06/13/17
BF1F 68        PLA              ;restore MSB volume start address
BF20 65 BA     ADC &BA          ;add MSB relative LBA
BF22 99 01 0D  STA &0D01,Y      ;paste MSB absolute LBA at &0D01/0E/12
BF25 A0 00     LDY #&00         ;starting offset = &00
BF27 20 00 0D  JSR &0D00        ;do transfer to/from paged RAM
BF2A A0 00     LDY #&00         ;fake WD1770 status = 0, succeeded
BF2C 4C 96 BA  JMP SA96         ;restore &A0,1 and page in main workspace.
;Transfer code copied to &0D00..46
BF2F AD EE FD  LDA &FDEE        ;get *OPT 9 saverom setting
BF32 8D 30 FE  STA &FE30        ;set ROM bank to *OPT 9 saverom
.SF35
BF35 A5 A1     LDA &A1          ;if 256 bytes or less remaining
BF37 C9 01     CMP #&01
BF39 D0 05     BNE SF40
BF3B A9 0F     LDA #&0F         ;then 0D25=BNE &0D36
BF3D 8D 26 0D  STA &0D26        ;transfer bytes of last page
.SF40
BF40 A2 00     LDX #&00         ;0D11
BF42 8E FE FC  STX &FCFE        ;set MSB of JIM page number
BF45 A2 00     LDX #&00         ;0D16
BF47 8E FF FC  STX &FCFF        ;set LSB of JIM page number
BF4A 20 40 0D  JSR &0D40        ;wait 18 microseconds (only needed for Tube)
.SF4D
BF4D B9 00 FD  LDA &FD00,Y      ;0D1E read byte from JIM page
BF50 99 00 FD  STA &FD00,Y      ;0D21 write byte to JIM page
BF53 C8        INY              ;increment offset
BF54 D0 F7     BNE SF4D         ;0D25 loop until page boundary reached
BF56 EE 23 0D  INC &0D23        ;0D27 increment MSB write address
BF59 EE 17 0D  INC &0D17        ;increment LSB of JIM page number
BF5C D0 03     BNE SF61         ;carry out to MSB of JIM page number
BF5E EE 12 0D  INC &0D12
.SF61
BF61 C6 A1     DEC &A1          ;decrement MSB transfer byte count
BF63 D0 D0     BNE SF35         ;loop to transfer next page (always)
BF65 C6 A0     DEC &A0          ;0D36 decrement LSB transfer byte count
BF67 D0 E4     BNE SF4D         ;loop until last bytes transferred
BF69 A5 F4     LDA &F4          ;page Challenger ROM back in
BF6B 8D 30 FE  STA &FE30
BF6E 60        RTS              ;return
BF6F 20 46 0D  JSR &0D46        ;0D40 wait 18 microseconds
BF72 20 46 0D  JSR &0D46
BF75 60        RTS
.SF76                           ;RAM disc copy code copied to &0D00..31
BF76 A2 00     LDX #&00
BF78 8E FE FC  STX &FCFE        ;set MSB JIM paging register to source
BF7B A2 00     LDX #&00
BF7D 8E FF FC  STX &FCFF        ;set LSB JIM paging register to source
BF80 B9 00 FD  LDA &FD00,Y      ;get byte from source page
BF83 A2 00     LDX #&00         ;0D0D
BF85 8E FE FC  STX &FCFE        ;set MSB JIM paging register to destination
BF88 A2 00     LDX #&00         ;0D12
BF8A 8E FF FC  STX &FCFF        ;set MSB JIM paging register to destination
BF8D 99 00 FD  STA &FD00,Y      ;store byte in destination page
BF90 C8        INY              ;loop to copy whole page
BF91 D0 E3     BNE SF76
BF93 EE 06 0D  INC &0D06        ;increment LSB source page
BF96 D0 03     BNE SF9B         ;carry out to MSB source page
BF98 EE 01 0D  INC &0D01
.SF9B
BF9B EE 13 0D  INC &0D13        ;increment LSB destination page
BF9E D0 03     BNE SFA3         ;carry out to MSB destination page
BFA0 EE 0E 0D  INC &0D0E
.SFA3
BFA3 C6 A1     DEC &A1          ;loop until required number of pages copied
BFA5 D0 CF     BNE SF76
BFA7 60        RTS
                                ;ChADFS ROM call 1
BFA8 A9 00     LDA #&00
BFAA 8D EC FD  STA &FDEC        ;first track of volume = 0, no track offset
BFAD AD ED FD  LDA &FDED        ;get *OPT 6 density setting
BFB0 09 40     ORA #&40         ;set b6=1, double density
BFB2 8D ED FD  STA &FDED        ;update *OPT 6 density setting (preserve auto)
BFB5 20 E4 8A  JSR PAE4         ;prepare extended file transfer
BFB8 4C F0 AC  JMP RCF0         ;transfer data L3 and exit
;Table of action addresses for ChADFS ROM calls 0..4, low bytes
BFBB EQUB &F5
BFBC EQUB &A7                   ;ChADFS 1 = transfer data       &BFA8
BFBD EQUB &1E                   ;ChADFS 2 = probe unit RAM size &821F
BFBE EQUB &7D                   ;ChADFS 3 = reset drv mappings  &AB7E
BFBF EQUB &27                   ;ChADFS 4 = format RAM disc     &BE28
;Table of action addresses for ChADFS ROM calls 0..4, high bytes
BFC0 EQUB &AA
BFC1 EQUB &BF
BFC2 EQUB &82
BFC3 EQUB &AB
BFC4 EQUB &BE
.SFC5                           ;ChADFS ROM call dispatcher
BFC5 AA        TAX              ;transfer call number to X as index
BFC6 20 0C BE  JSR SE0C         ;page in main workspace
BFC9 A9 FF     LDA #&FF
BFCB 8D FF FD  STA &FDFF        ;b6=1 ChADFS is current FS
BFCE A9 BF     LDA #&BF         ;push address of ChADFS return, &BFF4
BFD0 48        PHA              ;high byte
BFD1 A9 F3     LDA #&F3         ;low byte
BFD3 48        PHA
BFD4 BD C0 BF  LDA &BFC0,X      ;get action address high byte
BFD7 48        PHA              ;save on stack
BFD8 BD BB BF  LDA &BFBB,X      ;get action address low byte
BFDB 48        PHA              ;save on stack
BFDC 60        RTS              ;jump to action address
                                ;Return to ChADFS ROM
BFF4 A6 F4     LDX &F4          ;get our ROM slot number
BFF6 E8        INX              ;ChADFS is in the slot above
BFF7 86 F4     STX &F4          ;set MOS copy of ROMSEL to new slot number
BFF9 8E 30 FE  STX &FE30        ;switch to ChADFS ROM and continue there
                                ;entry point from ChADFS ROM
BFFC EA        NOP              ;allow address bus to stabilise
BFFD 4C C5 BF  JMP SFC5         ;jump to dispatcher
