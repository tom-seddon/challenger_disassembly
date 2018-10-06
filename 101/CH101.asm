; da65 V2.17 - Git df3c43be
; Created:    2018-10-06 16:36:48
; Input file: CH101
; Page:       1


        .setcpu "6502"

; ----------------------------------------------------------------------------
L0029           := $0029
L00A8           := $00A8
L00AA           := $00AA
L00AE           := $00AE
L00C0           := $00C0
L0100           := $0100
fscv            := $021E
L0406           := $0406
L0810           := $0810
L0D00           := $0D00
L0D11           := $0D11
L0D2C           := $0D2C
L0D40           := $0D40
L0D46           := $0D46
L2020           := $2020
L203A           := $203A
L2045           := $2045
L2049           := $2049
L204C           := $204C
L2052           := $2052
L2064           := $2064
L20FF           := $20FF
L2820           := $2820
L2846           := $2846
L2F52           := $2F52
L3028           := $3028
L3731           := $3731
L3D31           := $3D31
L3E65           := $3E65
L414F           := $414F
L4152           := $4152
L4D55           := $4D55
L6040           := $6040
L613C           := $613C
L6944           := $6944
L6964           := $6964
L6E61           := $6E61
L6E65           := $6E65
L6F63           := $6F63
L6F74           := $6F74
L7264           := $7264
L7277           := $7277
L7366           := $7366
L7473           := $7473
L7F20           := $7F20
L7F7F           := $7F7F
fdc_status_or_cmd:= $FCF8
fdc_track       := $FCF9
fdc_sector      := $FCFA
fdc_data        := $FCFB
fdc_control     := $FCFC
ram_paging_msb  := $FCFE
ram_paging_lsb  := $FCFF
LFDE0           := $FDE0
LFDE6           := $FDE6
LFF54           := $FF54
gsinit          := $FFC2
gsread          := $FFC5
osfind          := $FFCE
osgbpb          := $FFD1
osbput          := $FFD4
osbget          := $FFD7
osargs          := $FFDA
osfile          := $FFDD
osrdch          := $FFE0
osasci          := $FFE3
oswrch          := $FFEE
osword          := $FFF1
osbyte          := $FFF4
oscli           := $FFF7
; ----------------------------------------------------------------------------
        brk                                     ; 8000 00       .
        brk                                     ; 8001 00       .
        brk                                     ; 8002 00       .
        jmp     L801F                           ; 8003 4C 1F 80 L..

; ----------------------------------------------------------------------------
        .byte   $82,$15,$35                     ; 8006 82 15 35 ..5
; ----------------------------------------------------------------------------
        .byte   "SLOGGER"                       ; 8009 53 4C 4F 47 47 45 52SLOGGER
        .byte   $00                             ; 8010 00       .
        .byte   "1.01"                          ; 8011 31 2E 30 311.01
        .byte   $00                             ; 8015 00       .
        .byte   "(C)S"                          ; 8016 28 43 29 53(C)S
        .byte   $00                             ; 801A 00       .
; ----------------------------------------------------------------------------
L801B:  jmp     (fscv)                          ; 801B 6C 1E 02 l..

; ----------------------------------------------------------------------------
        rts                                     ; 801E 60       `

; ----------------------------------------------------------------------------
L801F:  cmp     #$01                            ; 801F C9 01    ..
        bne     L807D                           ; 8021 D0 5A    .Z
        jsr     push_registers_and_tuck_restoration_thunk; 8023 20 AB A8 ..
        ldx     $F4                             ; 8026 A6 F4    ..
        lda     #$00                            ; 8028 A9 00    ..
        sta     $0DF0,x                         ; 802A 9D F0 0D ...
        jsr     check_challenger_presence       ; 802D 20 EF 81  ..
        bne     L807C                           ; 8030 D0 4A    .J
        ldx     #$01                            ; 8032 A2 01    ..
        lda     #$04                            ; 8034 A9 04    ..
        jsr     L81F1                           ; 8036 20 F1 81  ..
        bne     L803C                           ; 8039 D0 01    ..
        inx                                     ; 803B E8       .
L803C:  txa                                     ; 803C 8A       .
        ldx     $F4                             ; 803D A6 F4    ..
        sta     $0DF0,x                         ; 803F 9D F0 0D ...
        jsr     select_ram_page_001             ; 8042 20 28 BE  (.
        lda     $FD00                           ; 8045 AD 00 FD ...
        and     #$7F                            ; 8048 29 7F    ).
        cmp     #$65                            ; 804A C9 65    .e
        beq     L8066                           ; 804C F0 18    ..
        lda     #$65                            ; 804E A9 65    .e
        sta     $FD00                           ; 8050 8D 00 FD ...
        jsr     reset_drive_mappings            ; 8053 20 BA AB  ..
        lda     #$04                            ; 8056 A9 04    ..
        sta     $CF                             ; 8058 85 CF    ..
        ldx     #$02                            ; 805A A2 02    ..
        jsr     LB040                           ; 805C 20 40 B0  @.
        inc     $CF                             ; 805F E6 CF    ..
        ldx     #$03                            ; 8061 A2 03    ..
        jsr     LB040                           ; 8063 20 40 B0  @.
L8066:  lda     #$FD                            ; 8066 A9 FD    ..
        jsr     LAE3D                           ; 8068 20 3D AE  =.
        txa                                     ; 806B 8A       .
        beq     L8071                           ; 806C F0 03    ..
        jsr     L8258                           ; 806E 20 58 82  X.
L8071:  bit     $FDF4                           ; 8071 2C F4 FD ,..
        bpl     L807C                           ; 8074 10 06    ..
        tsx                                     ; 8076 BA       .
        lda     #$17                            ; 8077 A9 17    ..
        sta     $0103,x                         ; 8079 9D 03 01 ...
L807C:  rts                                     ; 807C 60       `

; ----------------------------------------------------------------------------
L807D:  cmp     #$02                            ; 807D C9 02    ..
        bne     L808C                           ; 807F D0 0B    ..
        jsr     select_ram_page_001             ; 8081 20 28 BE  (.
        bit     $FDF4                           ; 8084 2C F4 FD ,..
        bpl     L808B                           ; 8087 10 02    ..
        iny                                     ; 8089 C8       .
        iny                                     ; 808A C8       .
L808B:  rts                                     ; 808B 60       `

; ----------------------------------------------------------------------------
L808C:  cmp     #$03                            ; 808C C9 03    ..
        bne     L80AC                           ; 808E D0 1C    ..
        jsr     select_ram_page_001             ; 8090 20 28 BE  (.
        sty     $B3                             ; 8093 84 B3    ..
        jsr     push_registers_and_tuck_restoration_thunk; 8095 20 AB A8 ..
        lda     #$7A                            ; 8098 A9 7A    .z
        jsr     osbyte                          ; 809A 20 F4 FF  ..
        txa                                     ; 809D 8A       .
        bmi     L80A9                           ; 809E 30 09    0.
        cmp     #$52                            ; 80A0 C9 52    .R
        bne     L80E9                           ; 80A2 D0 45    .E
        lda     #$78                            ; 80A4 A9 78    .x
        jsr     osbyte                          ; 80A6 20 F4 FF  ..
L80A9:  jmp     L81C2                           ; 80A9 4C C2 81 L..

; ----------------------------------------------------------------------------
L80AC:  cmp     #$04                            ; 80AC C9 04    ..
        bne     L80D0                           ; 80AE D0 20    . 
        jsr     select_ram_page_001             ; 80B0 20 28 BE  (.
        jsr     push_registers_and_tuck_restoration_thunk; 80B3 20 AB A8 ..
        tsx                                     ; 80B6 BA       .
        stx     $B8                             ; 80B7 86 B8    ..
        tya                                     ; 80B9 98       .
        ldx     #$FD                            ; 80BA A2 FD    ..
        ldy     #$90                            ; 80BC A0 90    ..
        jsr     L915D                           ; 80BE 20 5D 91  ].
        bcs     L80E9                           ; 80C1 B0 26    .&
        lda     $FD00                           ; 80C3 AD 00 FD ...
        bmi     L80CD                           ; 80C6 30 05    0.
        jsr     L00AA                           ; 80C8 20 AA 00  ..
        bmi     L80E9                           ; 80CB 30 1C    0.
L80CD:  jmp     (L00A8)                         ; 80CD 6C A8 00 l..

; ----------------------------------------------------------------------------
L80D0:  cmp     #$09                            ; 80D0 C9 09    ..
        bne     L8106                           ; 80D2 D0 32    .2
        jsr     select_ram_page_001             ; 80D4 20 28 BE  (.
        jsr     push_registers_and_tuck_restoration_thunk; 80D7 20 AB A8 ..
        lda     ($F2),y                         ; 80DA B1 F2    ..
        cmp     #$0D                            ; 80DC C9 0D    ..
        bne     L80EA                           ; 80DE D0 0A    ..
        ldx     #$45                            ; 80E0 A2 45    .E
        ldy     #$91                            ; 80E2 A0 91    ..
        lda     #$03                            ; 80E4 A9 03    ..
        jsr     LA596                           ; 80E6 20 96 A5  ..
L80E9:  rts                                     ; 80E9 60       `

; ----------------------------------------------------------------------------
L80EA:  jsr     LAA52                           ; 80EA 20 52 AA  R.
        beq     L80E9                           ; 80ED F0 FA    ..
        tya                                     ; 80EF 98       .
        pha                                     ; 80F0 48       H
        ldx     #$45                            ; 80F1 A2 45    .E
        ldy     #$91                            ; 80F3 A0 91    ..
        jsr     L915D                           ; 80F5 20 5D 91  ].
        bcs     L80FD                           ; 80F8 B0 03    ..
        jsr     L80CD                           ; 80FA 20 CD 80  ..
L80FD:  pla                                     ; 80FD 68       h
        tay                                     ; 80FE A8       .
L80FF:  jsr     gsread                          ; 80FF 20 C5 FF  ..
        bcc     L80FF                           ; 8102 90 FB    ..
        bcs     L80EA                           ; 8104 B0 E4    ..
L8106:  cmp     #$12                            ; 8106 C9 12    ..
        bne     L8117                           ; 8108 D0 0D    ..
        cpy     #$04                            ; 810A C0 04    ..
        bne     L80E9                           ; 810C D0 DB    ..
        jsr     select_ram_page_001             ; 810E 20 28 BE  (.
        jsr     push_registers_and_tuck_restoration_thunk; 8111 20 AB A8 ..
        jmp     disc_command                    ; 8114 4C DE 81 L..

; ----------------------------------------------------------------------------
L8117:  cmp     #$08                            ; 8117 C9 08    ..
        bne     L80E9                           ; 8119 D0 CE    ..
        jsr     select_ram_page_001             ; 811B 20 28 BE  (.
        jsr     LA8D4                           ; 811E 20 D4 A8  ..
        ldy     $F0                             ; 8121 A4 F0    ..
        sty     $B0                             ; 8123 84 B0    ..
        ldy     $F1                             ; 8125 A4 F1    ..
        sty     $B1                             ; 8127 84 B1    ..
        ldy     $EF                             ; 8129 A4 EF    ..
        cpy     #$7F                            ; 812B C0 7F    ..
        bne     L818C                           ; 812D D0 5D    .]
        jsr     LADF4                           ; 812F 20 F4 AD  ..
        ldy     #$01                            ; 8132 A0 01    ..
        lda     ($B0),y                         ; 8134 B1 B0    ..
        sta     $A6                             ; 8136 85 A6    ..
        iny                                     ; 8138 C8       .
        lda     ($B0),y                         ; 8139 B1 B0    ..
        sta     $A7                             ; 813B 85 A7    ..
        ldy     #$00                            ; 813D A0 00    ..
        lda     ($B0),y                         ; 813F B1 B0    ..
        bmi     L8147                           ; 8141 30 04    0.
        and     #$07                            ; 8143 29 07    ).
        sta     $CF                             ; 8145 85 CF    ..
L8147:  iny                                     ; 8147 C8       .
        ldx     #$02                            ; 8148 A2 02    ..
        jsr     L8973                           ; 814A 20 73 89  s.
        iny                                     ; 814D C8       .
        lda     ($B0),y                         ; 814E B1 B0    ..
        and     #$3F                            ; 8150 29 3F    )?
        sta     $B2                             ; 8152 85 B2    ..
        jsr     LA9FE                           ; 8154 20 FE A9  ..
        and     #$01                            ; 8157 29 01    ).
        jsr     L9716                           ; 8159 20 16 97  ..
        ldy     #$07                            ; 815C A0 07    ..
        lda     ($B0),y                         ; 815E B1 B0    ..
        iny                                     ; 8160 C8       .
        sta     $BA                             ; 8161 85 BA    ..
        ldx     #$FD                            ; 8163 A2 FD    ..
L8165:  inx                                     ; 8165 E8       .
        inx                                     ; 8166 E8       .
        inx                                     ; 8167 E8       .
        lda     LB8DC,x                         ; 8168 BD DC B8 ...
        beq     L8183                           ; 816B F0 16    ..
        cmp     $B2                             ; 816D C5 B2    ..
        bne     L8165                           ; 816F D0 F4    ..
        php                                     ; 8171 08       .
        cli                                     ; 8172 58       X
        lda     #$81                            ; 8173 A9 81    ..
        pha                                     ; 8175 48       H
        lda     #$81                            ; 8176 A9 81    ..
        pha                                     ; 8178 48       H
        lda     LB8DE,x                         ; 8179 BD DE B8 ...
        pha                                     ; 817C 48       H
        lda     LB8DD,x                         ; 817D BD DD B8 ...
        pha                                     ; 8180 48       H
        rts                                     ; 8181 60       `

; ----------------------------------------------------------------------------
        plp                                     ; 8182 28       (
L8183:  jsr     LADDD                           ; 8183 20 DD AD  ..
        jsr     L974E                           ; 8186 20 4E 97  N.
        lda     #$00                            ; 8189 A9 00    ..
        rts                                     ; 818B 60       `

; ----------------------------------------------------------------------------
L818C:  cpy     #$7D                            ; 818C C0 7D    .}
        bcc     L81C1                           ; 818E 90 31    .1
        jsr     LAA7E                           ; 8190 20 7E AA  ~.
        jsr     L969B                           ; 8193 20 9B 96  ..
        cpy     #$7E                            ; 8196 C0 7E    .~
        beq     L81A6                           ; 8198 F0 0C    ..
        jsr     select_ram_page_003             ; 819A 20 32 BE  2.
        ldy     #$00                            ; 819D A0 00    ..
        lda     $FD04                           ; 819F AD 04 FD ...
        sta     ($B0),y                         ; 81A2 91 B0    ..
        tya                                     ; 81A4 98       .
        rts                                     ; 81A5 60       `

; ----------------------------------------------------------------------------
L81A6:  jsr     select_ram_page_003             ; 81A6 20 32 BE  2.
        lda     #$00                            ; 81A9 A9 00    ..
        tay                                     ; 81AB A8       .
        sta     ($B0),y                         ; 81AC 91 B0    ..
        iny                                     ; 81AE C8       .
        lda     $FD07                           ; 81AF AD 07 FD ...
        sta     ($B0),y                         ; 81B2 91 B0    ..
        iny                                     ; 81B4 C8       .
        lda     $FD06                           ; 81B5 AD 06 FD ...
        and     #$03                            ; 81B8 29 03    ).
        sta     ($B0),y                         ; 81BA 91 B0    ..
        iny                                     ; 81BC C8       .
        lda     #$00                            ; 81BD A9 00    ..
        sta     ($B0),y                         ; 81BF 91 B0    ..
L81C1:  rts                                     ; 81C1 60       `

; ----------------------------------------------------------------------------
L81C2:  lda     $B3                             ; 81C2 A5 B3    ..
        pha                                     ; 81C4 48       H
        jsr     LAEA3                           ; 81C5 20 A3 AE  ..
        jsr     L81E9                           ; 81C8 20 E9 81  ..
        and     #$03                            ; 81CB 29 03    ).
        beq     L81E7                           ; 81CD F0 18    ..
        jsr     L827C                           ; 81CF 20 7C 82  |.
        jsr     L8211                           ; 81D2 20 11 82  ..
        pla                                     ; 81D5 68       h
        bne     L81DB                           ; 81D6 D0 03    ..
        jmp     L82A8                           ; 81D8 4C A8 82 L..

; ----------------------------------------------------------------------------
L81DB:  lda     #$00                            ; 81DB A9 00    ..
        rts                                     ; 81DD 60       `

; ----------------------------------------------------------------------------
disc_command:
        pha                                     ; 81DE 48       H
        jsr     check_challenger_presence       ; 81DF 20 EF 81  ..
        bne     L81E7                           ; 81E2 D0 03    ..
        jsr     L8211                           ; 81E4 20 11 82  ..
L81E7:  pla                                     ; 81E7 68       h
        rts                                     ; 81E8 60       `

; ----------------------------------------------------------------------------
L81E9:  ldx     $F4                             ; 81E9 A6 F4    ..
        lda     $0DF0,x                         ; 81EB BD F0 0D ...
        rts                                     ; 81EE 60       `

; ----------------------------------------------------------------------------
check_challenger_presence:
        lda     #$00                            ; 81EF A9 00    ..
L81F1:  sta     ram_paging_msb                  ; 81F1 8D FE FC ...
        lda     #$01                            ; 81F4 A9 01    ..
        sta     ram_paging_lsb                  ; 81F6 8D FF FC ...
        lda     $FD00                           ; 81F9 AD 00 FD ...
        eor     #$FF                            ; 81FC 49 FF    I.
        sta     $FD00                           ; 81FE 8D 00 FD ...
        ldy     #$05                            ; 8201 A0 05    ..
L8203:  dey                                     ; 8203 88       .
        bne     L8203                           ; 8204 D0 FD    ..
        cmp     $FD00                           ; 8206 CD 00 FD ...
        php                                     ; 8209 08       .
        eor     #$FF                            ; 820A 49 FF    I.
        sta     $FD00                           ; 820C 8D 00 FD ...
        plp                                     ; 820F 28       (
        rts                                     ; 8210 60       `

; ----------------------------------------------------------------------------
L8211:  lda     #$00                            ; 8211 A9 00    ..
        tsx                                     ; 8213 BA       .
        sta     $0108,x                         ; 8214 9D 08 01 ...
        lda     #$06                            ; 8217 A9 06    ..
        jsr     L801B                           ; 8219 20 1B 80  ..
        ldx     #$00                            ; 821C A2 00    ..
L821E:  lda     LAE44,x                         ; 821E BD 44 AE .D.
        sta     $0212,x                         ; 8221 9D 12 02 ...
        inx                                     ; 8224 E8       .
        cpx     #$0E                            ; 8225 E0 0E    ..
        bne     L821E                           ; 8227 D0 F5    ..
        jsr     LAE33                           ; 8229 20 33 AE  3.
        sty     $B1                             ; 822C 84 B1    ..
        stx     $B0                             ; 822E 86 B0    ..
        ldx     #$00                            ; 8230 A2 00    ..
        ldy     #$1B                            ; 8232 A0 1B    ..
L8234:  lda     LAE52,x                         ; 8234 BD 52 AE .R.
        sta     ($B0),y                         ; 8237 91 B0    ..
        inx                                     ; 8239 E8       .
        iny                                     ; 823A C8       .
        lda     LAE52,x                         ; 823B BD 52 AE .R.
        sta     ($B0),y                         ; 823E 91 B0    ..
        inx                                     ; 8240 E8       .
        iny                                     ; 8241 C8       .
        lda     $F4                             ; 8242 A5 F4    ..
        sta     ($B0),y                         ; 8244 91 B0    ..
        iny                                     ; 8246 C8       .
        cpx     #$0E                            ; 8247 E0 0E    ..
        bne     L8234                           ; 8249 D0 E9    ..
        lda     $FD00                           ; 824B AD 00 FD ...
        ora     #$80                            ; 824E 09 80    ..
        sta     $FD00                           ; 8250 8D 00 FD ...
        ldx     #$0F                            ; 8253 A2 0F    ..
        jmp     LAE37                           ; 8255 4C 37 AE L7.

; ----------------------------------------------------------------------------
L8258:  jsr     select_ram_page_001             ; 8258 20 28 BE  (.
        lda     #$80                            ; 825B A9 80    ..
        sta     $FDED                           ; 825D 8D ED FD ...
        sta     $FDEA                           ; 8260 8D EA FD ...
        lda     #$0E                            ; 8263 A9 0E    ..
        sta     $FDEE                           ; 8265 8D EE FD ...
        lda     #$00                            ; 8268 A9 00    ..
        sta     $FDC7                           ; 826A 8D C7 FD ...
        sta     $FDC9                           ; 826D 8D C9 FD ...
        sta     $FDF4                           ; 8270 8D F4 FD ...
        lda     #$24                            ; 8273 A9 24    .$
        sta     $FDC6                           ; 8275 8D C6 FD ...
        sta     $FDC8                           ; 8278 8D C8 FD ...
        rts                                     ; 827B 60       `

; ----------------------------------------------------------------------------
L827C:  jsr     select_ram_page_001             ; 827C 20 28 BE  (.
        jsr     LAE2F                           ; 827F 20 2F AE  /.
        txa                                     ; 8282 8A       .
        eor     #$FF                            ; 8283 49 FF    I.
        sta     $FDCD                           ; 8285 8D CD FD ...
        ldy     #$00                            ; 8288 A0 00    ..
        sty     $FDCE                           ; 828A 8C CE FD ...
        sty     $FDDE                           ; 828D 8C DE FD ...
        sty     $FDDD                           ; 8290 8C DD FD ...
        sty     $FDCC                           ; 8293 8C CC FD ...
        dey                                     ; 8296 88       .
        sty     $FDDF                           ; 8297 8C DF FD ...
        sty     $FDD9                           ; 829A 8C D9 FD ...
        sty     $FDDC                           ; 829D 8C DC FD ...
        jsr     LAE3B                           ; 82A0 20 3B AE  ;.
        stx     $B4                             ; 82A3 86 B4    ..
        jmp     LB929                           ; 82A5 4C 29 B9 L).

; ----------------------------------------------------------------------------
L82A8:  jsr     LAA7E                           ; 82A8 20 7E AA  ~.
        jsr     L969E                           ; 82AB 20 9E 96  ..
        ldy     #$00                            ; 82AE A0 00    ..
        ldx     #$00                            ; 82B0 A2 00    ..
        jsr     select_ram_page_003             ; 82B2 20 32 BE  2.
        lda     $FD06                           ; 82B5 AD 06 FD ...
        jsr     LA9FE                           ; 82B8 20 FE A9  ..
        beq     L82E2                           ; 82BB F0 25    .%
        pha                                     ; 82BD 48       H
        ldx     #$06                            ; 82BE A2 06    ..
        ldy     #$83                            ; 82C0 A0 83    ..
        jsr     L91ED                           ; 82C2 20 ED 91  ..
        jsr     L898D                           ; 82C5 20 8D 89  ..
        jsr     L8BCE                           ; 82C8 20 CE 8B  ..
        pla                                     ; 82CB 68       h
        bcs     L82E3                           ; 82CC B0 15    ..
        jsr     LA933                           ; 82CE 20 33 A9  3.
        .byte   "File not found"                ; 82D1 46 69 6C 65 20 6E 6F 74File not
                                                ; 82D9 20 66 6F 75 6E 64 found
        .byte   $0D,$0D                         ; 82DF 0D 0D    ..
; ----------------------------------------------------------------------------
        nop                                     ; 82E1 EA       .
L82E2:  rts                                     ; 82E2 60       `

; ----------------------------------------------------------------------------
L82E3:  cmp     #$02                            ; 82E3 C9 02    ..
        bcc     L82F5                           ; 82E5 90 0E    ..
        beq     L82EF                           ; 82E7 F0 06    ..
        ldx     #$04                            ; 82E9 A2 04    ..
        ldy     #$83                            ; 82EB A0 83    ..
        bne     L82F9                           ; 82ED D0 0A    ..
L82EF:  ldx     #$06                            ; 82EF A2 06    ..
        ldy     #$83                            ; 82F1 A0 83    ..
        bne     L82F9                           ; 82F3 D0 04    ..
L82F5:  ldx     #$FC                            ; 82F5 A2 FC    ..
        ldy     #$82                            ; 82F7 A0 82    ..
L82F9:  jmp     oscli                           ; 82F9 4C F7 FF L..

; ----------------------------------------------------------------------------
        .byte   "L.!BOOT"                       ; 82FC 4C 2E 21 42 4F 4F 54L.!BOOT
        .byte   $0D                             ; 8303 0D       .
        .byte   "E.!BOOT"                       ; 8304 45 2E 21 42 4F 4F 54E.!BOOT
        .byte   $0D                             ; 830B 0D       .
; ----------------------------------------------------------------------------
type_command:
        jsr     LA880                           ; 830C 20 80 A8  ..
        lda     #$00                            ; 830F A9 00    ..
        beq     L8318                           ; 8311 F0 05    ..
list_command:
        jsr     LA880                           ; 8313 20 80 A8  ..
        lda     #$FF                            ; 8316 A9 FF    ..
L8318:  sta     $AB                             ; 8318 85 AB    ..
        lda     #$40                            ; 831A A9 40    .@
        jsr     osfind                          ; 831C 20 CE FF  ..
        tay                                     ; 831F A8       .
        beq     L8352                           ; 8320 F0 30    .0
        lda     #$0D                            ; 8322 A9 0D    ..
        bne     L8341                           ; 8324 D0 1B    ..
L8326:  jsr     osbget                          ; 8326 20 D7 FF  ..
        bcs     L8349                           ; 8329 B0 1E    ..
        cmp     #$0A                            ; 832B C9 0A    ..
        beq     L8326                           ; 832D F0 F7    ..
        plp                                     ; 832F 28       (
        bne     L833A                           ; 8330 D0 08    ..
        pha                                     ; 8332 48       H
        jsr     LA839                           ; 8333 20 39 A8  9.
        jsr     LA877                           ; 8336 20 77 A8  w.
        pla                                     ; 8339 68       h
L833A:  jsr     osasci                          ; 833A 20 E3 FF  ..
        bit     $FF                             ; 833D 24 FF    $.
        bmi     L834A                           ; 833F 30 09    0.
L8341:  and     $AB                             ; 8341 25 AB    %.
        cmp     #$0D                            ; 8343 C9 0D    ..
        php                                     ; 8345 08       .
        jmp     L8326                           ; 8346 4C 26 83 L&.

; ----------------------------------------------------------------------------
L8349:  plp                                     ; 8349 28       (
L834A:  jsr     L841A                           ; 834A 20 1A 84  ..
L834D:  lda     #$00                            ; 834D A9 00    ..
        jmp     osfind                          ; 834F 4C CE FF L..

; ----------------------------------------------------------------------------
L8352:  jmp     L8AF7                           ; 8352 4C F7 8A L..

; ----------------------------------------------------------------------------
dump_command:
        jsr     LA880                           ; 8355 20 80 A8  ..
        lda     #$40                            ; 8358 A9 40    .@
        jsr     osfind                          ; 835A 20 CE FF  ..
        tay                                     ; 835D A8       .
        beq     L8352                           ; 835E F0 F2    ..
L8360:  bit     $FF                             ; 8360 24 FF    $.
        bmi     L834D                           ; 8362 30 E9    0.
        lda     $A9                             ; 8364 A5 A9    ..
        jsr     LA9D8                           ; 8366 20 D8 A9  ..
        lda     L00A8                           ; 8369 A5 A8    ..
        jsr     LA9D8                           ; 836B 20 D8 A9  ..
        jsr     LA877                           ; 836E 20 77 A8  w.
        tsx                                     ; 8371 BA       .
        stx     $AD                             ; 8372 86 AD    ..
        ldx     #$08                            ; 8374 A2 08    ..
L8376:  jsr     osbget                          ; 8376 20 D7 FF  ..
        bcs     L8385                           ; 8379 B0 0A    ..
        pha                                     ; 837B 48       H
        jsr     LA9D8                           ; 837C 20 D8 A9  ..
        jsr     LA877                           ; 837F 20 77 A8  w.
        dex                                     ; 8382 CA       .
        bne     L8376                           ; 8383 D0 F1    ..
L8385:  dex                                     ; 8385 CA       .
        bmi     L8395                           ; 8386 30 0D    0.
        php                                     ; 8388 08       .
        jsr     LA933                           ; 8389 20 33 A9  3.
        .byte   "** "                           ; 838C 2A 2A 20 ** 
; ----------------------------------------------------------------------------
        lda     #$00                            ; 838F A9 00    ..
        plp                                     ; 8391 28       (
        pha                                     ; 8392 48       H
        bpl     L8385                           ; 8393 10 F0    ..
L8395:  php                                     ; 8395 08       .
        tsx                                     ; 8396 BA       .
        lda     #$07                            ; 8397 A9 07    ..
        sta     $AC                             ; 8399 85 AC    ..
L839B:  lda     $0109,x                         ; 839B BD 09 01 ...
        cmp     #$7F                            ; 839E C9 7F    ..
        bcs     L83A6                           ; 83A0 B0 04    ..
        cmp     #$20                            ; 83A2 C9 20    . 
        bcs     L83A8                           ; 83A4 B0 02    ..
L83A6:  lda     #$2E                            ; 83A6 A9 2E    ..
L83A8:  jsr     osasci                          ; 83A8 20 E3 FF  ..
        dex                                     ; 83AB CA       .
        dec     $AC                             ; 83AC C6 AC    ..
        bpl     L839B                           ; 83AE 10 EB    ..
        jsr     L841A                           ; 83B0 20 1A 84  ..
        lda     #$08                            ; 83B3 A9 08    ..
        clc                                     ; 83B5 18       .
        adc     L00A8                           ; 83B6 65 A8    e.
        sta     L00A8                           ; 83B8 85 A8    ..
        bcc     L83BE                           ; 83BA 90 02    ..
        inc     $A9                             ; 83BC E6 A9    ..
L83BE:  plp                                     ; 83BE 28       (
        ldx     $AD                             ; 83BF A6 AD    ..
        txs                                     ; 83C1 9A       .
        bcc     L8360                           ; 83C2 90 9C    ..
        bcs     L834D                           ; 83C4 B0 87    ..
build_command:
        jsr     LA880                           ; 83C6 20 80 A8  ..
        lda     #$80                            ; 83C9 A9 80    ..
        jsr     osfind                          ; 83CB 20 CE FF  ..
        sta     $AB                             ; 83CE 85 AB    ..
        jsr     LA897                           ; 83D0 20 97 A8  ..
L83D3:  jsr     LA839                           ; 83D3 20 39 A8  9.
        jsr     LA877                           ; 83D6 20 77 A8  w.
        lda     #$FD                            ; 83D9 A9 FD    ..
        sta     $AD                             ; 83DB 85 AD    ..
        ldx     #$AC                            ; 83DD A2 AC    ..
        ldy     #$FF                            ; 83DF A0 FF    ..
        sty     L00AE                           ; 83E1 84 AE    ..
        sty     $B0                             ; 83E3 84 B0    ..
        iny                                     ; 83E5 C8       .
        sty     $AC                             ; 83E6 84 AC    ..
        sty     $AF                             ; 83E8 84 AF    ..
        jsr     select_ram_page_009             ; 83EA 20 37 BE  7.
        tya                                     ; 83ED 98       .
        jsr     osword                          ; 83EE 20 F1 FF  ..
        php                                     ; 83F1 08       .
        sty     L00AA                           ; 83F2 84 AA    ..
        ldy     $AB                             ; 83F4 A4 AB    ..
        ldx     #$00                            ; 83F6 A2 00    ..
L83F8:  txa                                     ; 83F8 8A       .
        cmp     L00AA                           ; 83F9 C5 AA    ..
        beq     L8409                           ; 83FB F0 0C    ..
        jsr     select_ram_page_009             ; 83FD 20 37 BE  7.
        lda     $FD00,x                         ; 8400 BD 00 FD ...
        jsr     osbput                          ; 8403 20 D4 FF  ..
        inx                                     ; 8406 E8       .
        bne     L83F8                           ; 8407 D0 EF    ..
L8409:  plp                                     ; 8409 28       (
        bcs     L8414                           ; 840A B0 08    ..
        lda     #$0D                            ; 840C A9 0D    ..
        jsr     osbput                          ; 840E 20 D4 FF  ..
        jmp     L83D3                           ; 8411 4C D3 83 L..

; ----------------------------------------------------------------------------
L8414:  jsr     LA9EF                           ; 8414 20 EF A9  ..
        jsr     L834D                           ; 8417 20 4D 83  M.
L841A:  pha                                     ; 841A 48       H
        lda     #$0D                            ; 841B A9 0D    ..
        jsr     LA9B1                           ; 841D 20 B1 A9  ..
        pla                                     ; 8420 68       h
        rts                                     ; 8421 60       `

; ----------------------------------------------------------------------------
L8422:  jsr     push_registers_and_tuck_restoration_thunk; 8422 20 AB A8 ..
        jsr     select_ram_page_001             ; 8425 20 28 BE  (.
        ldx     $FDCA                           ; 8428 AE CA FD ...
        lda     #$00                            ; 842B A9 00    ..
        beq     L843A                           ; 842D F0 0B    ..
L842F:  jsr     push_registers_and_tuck_restoration_thunk; 842F 20 AB A8 ..
        jsr     select_ram_page_001             ; 8432 20 28 BE  (.
        ldx     $FDCB                           ; 8435 AE CB FD ...
        lda     #$80                            ; 8438 A9 80    ..
L843A:  pha                                     ; 843A 48       H
        stx     $CF                             ; 843B 86 CF    ..
        pla                                     ; 843D 68       h
        bit     $A9                             ; 843E 24 A9    $.
        bmi     L8443                           ; 8440 30 01    0.
L8442:  rts                                     ; 8442 60       `

; ----------------------------------------------------------------------------
L8443:  cmp     L00AA                           ; 8443 C5 AA    ..
        beq     L8442                           ; 8445 F0 FB    ..
        sta     L00AA                           ; 8447 85 AA    ..
        jsr     LA933                           ; 8449 20 33 A9  3.
        .byte   "Insert "                       ; 844C 49 6E 73 65 72 74 20Insert 
; ----------------------------------------------------------------------------
        nop                                     ; 8453 EA       .
        bit     L00AA                           ; 8454 24 AA    $.
        bmi     L8463                           ; 8456 30 0B    0.
        jsr     LA933                           ; 8458 20 33 A9  3.
        .byte   "source"                        ; 845B 73 6F 75 72 63 65source
; ----------------------------------------------------------------------------
        bcc     L8472                           ; 8461 90 0F    ..
L8463:  jsr     LA933                           ; 8463 20 33 A9  3.
        .byte   "destination"                   ; 8466 64 65 73 74 69 6E 61 74destinat
                                                ; 846E 69 6F 6E ion
; ----------------------------------------------------------------------------
        nop                                     ; 8471 EA       .
L8472:  jsr     LA933                           ; 8472 20 33 A9  3.
        .byte   " disk and hit a key"           ; 8475 20 64 69 73 6B 20 61 6E disk an
                                                ; 847D 64 20 68 69 74 20 61 20d hit a 
                                                ; 8485 6B 65 79 key
; ----------------------------------------------------------------------------
        nop                                     ; 8488 EA       .
        jsr     L84A0                           ; 8489 20 A0 84  ..
        jmp     L841A                           ; 848C 4C 1A 84 L..

; ----------------------------------------------------------------------------
L848F:  jsr     L84A0                           ; 848F 20 A0 84  ..
        and     #$5F                            ; 8492 29 5F    )_
        cmp     #$59                            ; 8494 C9 59    .Y
        php                                     ; 8496 08       .
        beq     L849B                           ; 8497 F0 02    ..
        lda     #$4E                            ; 8499 A9 4E    .N
L849B:  jsr     LA9B1                           ; 849B 20 B1 A9  ..
        plp                                     ; 849E 28       (
        rts                                     ; 849F 60       `

; ----------------------------------------------------------------------------
L84A0:  jsr     LAE0D                           ; 84A0 20 0D AE  ..
        jsr     osrdch                          ; 84A3 20 E0 FF  ..
        bcc     L84AB                           ; 84A6 90 03    ..
        ldx     $B8                             ; 84A8 A6 B8    ..
        txs                                     ; 84AA 9A       .
L84AB:  rts                                     ; 84AB 60       `

; ----------------------------------------------------------------------------
L84AC:  ldy     #$00                            ; 84AC A0 00    ..
        beq     L84B2                           ; 84AE F0 02    ..
L84B0:  ldy     #$02                            ; 84B0 A0 02    ..
L84B2:  jsr     select_ram_page_001             ; 84B2 20 28 BE  (.
        lda     $FDFA,y                         ; 84B5 B9 FA FD ...
        sta     $FDEC                           ; 84B8 8D EC FD ...
        lda     $FDF9,y                         ; 84BB B9 F9 FD ...
L84BE:  pha                                     ; 84BE 48       H
        and     #$C0                            ; 84BF 29 C0    ).
        sta     $FDED                           ; 84C1 8D ED FD ...
        pla                                     ; 84C4 68       h
        lsr     a                               ; 84C5 4A       J
        ror     a                               ; 84C6 6A       j
        ror     a                               ; 84C7 6A       j
        pha                                     ; 84C8 48       H
        and     #$C0                            ; 84C9 29 C0    ).
        sta     $FDEA                           ; 84CB 8D EA FD ...
        pla                                     ; 84CE 68       h
        and     #$03                            ; 84CF 29 03    ).
        jmp     L84FD                           ; 84D1 4C FD 84 L..

; ----------------------------------------------------------------------------
L84D4:  jsr     push_registers_and_tuck_restoration_thunk; 84D4 20 AB A8 ..
        ldy     #$00                            ; 84D7 A0 00    ..
        beq     L84E0                           ; 84D9 F0 05    ..
L84DB:  jsr     push_registers_and_tuck_restoration_thunk; 84DB 20 AB A8 ..
        ldy     #$02                            ; 84DE A0 02    ..
L84E0:  jsr     select_ram_page_001             ; 84E0 20 28 BE  (.
        lda     $FDEC                           ; 84E3 AD EC FD ...
        sta     $FDFA,y                         ; 84E6 99 FA FD ...
        jsr     L84F0                           ; 84E9 20 F0 84  ..
        sta     $FDF9,y                         ; 84EC 99 F9 FD ...
        rts                                     ; 84EF 60       `

; ----------------------------------------------------------------------------
L84F0:  jsr     L850D                           ; 84F0 20 0D 85  ..
        ora     $FDEA                           ; 84F3 0D EA FD ...
        asl     a                               ; 84F6 0A       .
        rol     a                               ; 84F7 2A       *
        rol     a                               ; 84F8 2A       *
        ora     $FDED                           ; 84F9 0D ED FD ...
        rts                                     ; 84FC 60       `

; ----------------------------------------------------------------------------
L84FD:  cmp     #$00                            ; 84FD C9 00    ..
        beq     L8509                           ; 84FF F0 08    ..
        cmp     #$02                            ; 8501 C9 02    ..
        lda     #$0A                            ; 8503 A9 0A    ..
        bcc     L8509                           ; 8505 90 02    ..
        lda     #$12                            ; 8507 A9 12    ..
L8509:  sta     $FDEB                           ; 8509 8D EB FD ...
        rts                                     ; 850C 60       `

; ----------------------------------------------------------------------------
L850D:  lda     $FDEB                           ; 850D AD EB FD ...
        beq     L8519                           ; 8510 F0 07    ..
        cmp     #$12                            ; 8512 C9 12    ..
        lda     #$01                            ; 8514 A9 01    ..
        bcc     L8519                           ; 8516 90 01    ..
        asl     a                               ; 8518 0A       .
L8519:  rts                                     ; 8519 60       `

; ----------------------------------------------------------------------------
backup_command:
        jsr     LA7BE                           ; 851A 20 BE A7  ..
        jsr     LA7E9                           ; 851D 20 E9 A7  ..
        lda     #$00                            ; 8520 A9 00    ..
        sta     L00A8                           ; 8522 85 A8    ..
        sta     $C8                             ; 8524 85 C8    ..
        sta     $C9                             ; 8526 85 C9    ..
        sta     $CA                             ; 8528 85 CA    ..
        sta     $CB                             ; 852A 85 CB    ..
        jsr     L8610                           ; 852C 20 10 86  ..
        lda     #$00                            ; 852F A9 00    ..
        sta     $FDEC                           ; 8531 8D EC FD ...
        jsr     L84D4                           ; 8534 20 D4 84  ..
        jsr     L85EB                           ; 8537 20 EB 85  ..
        sta     LFDE0                           ; 853A 8D E0 FD ...
        stx     $C6                             ; 853D 86 C6    ..
        sty     $C7                             ; 853F 84 C7    ..
        jsr     L860A                           ; 8541 20 0A 86  ..
        lda     #$00                            ; 8544 A9 00    ..
        sta     $FDEC                           ; 8546 8D EC FD ...
        jsr     L84DB                           ; 8549 20 DB 84  ..
        lda     $FDF9                           ; 854C AD F9 FD ...
        eor     $FDFB                           ; 854F 4D FB FD M..
        and     #$40                            ; 8552 29 40    )@
        beq     L857B                           ; 8554 F0 25    .%
        jsr     LA90D                           ; 8556 20 0D A9  ..
        .byte   $D5                             ; 8559 D5       .
        .byte   "Both disks MUST be same density"; 855A 42 6F 74 68 20 64 69 73Both dis
                                                ; 8562 6B 73 20 4D 55 53 54 20ks MUST 
                                                ; 856A 62 65 20 73 61 6D 65 20be same 
                                                ; 8572 64 65 6E 73 69 74 79density
        .byte   $0D,$00                         ; 8579 0D 00    ..
; ----------------------------------------------------------------------------
L857B:  jsr     L85EB                           ; 857B 20 EB 85  ..
        txa                                     ; 857E 8A       .
        pha                                     ; 857F 48       H
        tya                                     ; 8580 98       .
        pha                                     ; 8581 48       H
        cmp     $C7                             ; 8582 C5 C7    ..
        bcc     L858D                           ; 8584 90 07    ..
        bne     L85B1                           ; 8586 D0 29    .)
        txa                                     ; 8588 8A       .
        cmp     $C6                             ; 8589 C5 C6    ..
        bcs     L85B1                           ; 858B B0 24    .$
L858D:  lda     #$D5                            ; 858D A9 D5    ..
        jsr     LA998                           ; 858F 20 98 A9  ..
        lda     $FDCA                           ; 8592 AD CA FD ...
        jsr     L8E4D                           ; 8595 20 4D 8E  M.
        jsr     LA933                           ; 8598 20 33 A9  3.
        .byte   " larger than "                 ; 859B 20 6C 61 72 67 65 72 20 larger 
                                                ; 85A3 74 68 61 6E 20than 
; ----------------------------------------------------------------------------
        lda     $FDCB                           ; 85A8 AD CB FD ...
        jsr     L8E4D                           ; 85AB 20 4D 8E  M.
        jmp     LA958                           ; 85AE 4C 58 A9 LX.

; ----------------------------------------------------------------------------
L85B1:  jsr     L88F9                           ; 85B1 20 F9 88  ..
        jsr     L887B                           ; 85B4 20 7B 88  {.
        jsr     LB7B2                           ; 85B7 20 B2 B7  ..
        bne     L85BF                           ; 85BA D0 03    ..
        pla                                     ; 85BC 68       h
        pla                                     ; 85BD 68       h
        rts                                     ; 85BE 60       `

; ----------------------------------------------------------------------------
L85BF:  bit     $FDED                           ; 85BF 2C ED FD ,..
        bvs     L85DA                           ; 85C2 70 16    p.
        jsr     L969E                           ; 85C4 20 9E 96  ..
        pla                                     ; 85C7 68       h
        and     #$0F                            ; 85C8 29 0F    ).
        ora     LFDE0                           ; 85CA 0D E0 FD ...
        jsr     select_ram_page_003             ; 85CD 20 32 BE  2.
        sta     $FD06                           ; 85D0 8D 06 FD ...
        pla                                     ; 85D3 68       h
        sta     $FD07                           ; 85D4 8D 07 FD ...
        jmp     L9677                           ; 85D7 4C 77 96 Lw.

; ----------------------------------------------------------------------------
L85DA:  jsr     LAD37                           ; 85DA 20 37 AD  7.
        jsr     select_ram_page_002             ; 85DD 20 2D BE  -.
        pla                                     ; 85E0 68       h
        sta     $FD01                           ; 85E1 8D 01 FD ...
        pla                                     ; 85E4 68       h
        sta     $FD02                           ; 85E5 8D 02 FD ...
        jmp     LAD3A                           ; 85E8 4C 3A AD L:.

; ----------------------------------------------------------------------------
L85EB:  jsr     select_ram_page_003             ; 85EB 20 32 BE  2.
        ldx     $FD07                           ; 85EE AE 07 FD ...
        lda     $FD06                           ; 85F1 AD 06 FD ...
        pha                                     ; 85F4 48       H
        and     #$03                            ; 85F5 29 03    ).
        tay                                     ; 85F7 A8       .
        jsr     select_ram_page_001             ; 85F8 20 28 BE  (.
        bit     $FDED                           ; 85FB 2C ED FD ,..
        bvc     L8606                           ; 85FE 50 06    P.
        ldx     $FDF6                           ; 8600 AE F6 FD ...
        ldy     $FDF5                           ; 8603 AC F5 FD ...
L8606:  pla                                     ; 8606 68       h
        and     #$F0                            ; 8607 29 F0    ).
        rts                                     ; 8609 60       `

; ----------------------------------------------------------------------------
L860A:  jsr     L842F                           ; 860A 20 2F 84  /.
        jmp     L969E                           ; 860D 4C 9E 96 L..

; ----------------------------------------------------------------------------
L8610:  jsr     L8422                           ; 8610 20 22 84  ".
        jmp     L969E                           ; 8613 4C 9E 96 L..

; ----------------------------------------------------------------------------
copy_command:
        jsr     L8ADF                           ; 8616 20 DF 8A  ..
        jsr     LA7E9                           ; 8619 20 E9 A7  ..
        jsr     LA5C4                           ; 861C 20 C4 A5  ..
        jsr     L898D                           ; 861F 20 8D 89  ..
        jsr     L8422                           ; 8622 20 22 84  ".
        jsr     L8AF2                           ; 8625 20 F2 8A  ..
        jsr     L84D4                           ; 8628 20 D4 84  ..
        lda     $FDD5                           ; 862B AD D5 FD ...
        sta     $BD                             ; 862E 85 BD    ..
        lda     #$00                            ; 8630 A9 00    ..
        sta     $FDF7                           ; 8632 8D F7 FD ...
        sta     L00A8                           ; 8635 85 A8    ..
        lda     #$01                            ; 8637 A9 01    ..
        sta     L00A8                           ; 8639 85 A8    ..
L863B:  tya                                     ; 863B 98       .
        pha                                     ; 863C 48       H
        ldx     #$00                            ; 863D A2 00    ..
L863F:  lda     $C7,x                           ; 863F B5 C7    ..
        pha                                     ; 8641 48       H
        inx                                     ; 8642 E8       .
        cpx     #$08                            ; 8643 E0 08    ..
        bne     L863F                           ; 8645 D0 F8    ..
        jsr     LA933                           ; 8647 20 33 A9  3.
        .byte   "Reading "                      ; 864A 52 65 61 64 69 6E 67 20Reading 
; ----------------------------------------------------------------------------
        nop                                     ; 8652 EA       .
        jsr     L8A54                           ; 8653 20 54 8A  T.
        jsr     L841A                           ; 8656 20 1A 84  ..
        ldx     $FDF7                           ; 8659 AE F7 FD ...
        lda     #$08                            ; 865C A9 08    ..
        sta     $B0                             ; 865E 85 B0    ..
L8660:  jsr     select_ram_page_003             ; 8660 20 32 BE  2.
        lda     $FD08,y                         ; 8663 B9 08 FD ...
        jsr     select_ram_page_000             ; 8666 20 23 BE  #.
        sta     $FD00,x                         ; 8669 9D 00 FD ...
        inx                                     ; 866C E8       .
        iny                                     ; 866D C8       .
        dec     $B0                             ; 866E C6 B0    ..
        bne     L8660                           ; 8670 D0 EE    ..
        lda     #$08                            ; 8672 A9 08    ..
        sta     $B0                             ; 8674 85 B0    ..
L8676:  jsr     select_ram_page_002             ; 8676 20 2D BE  -.
        lda     $FD00,y                         ; 8679 B9 00 FD ...
        jsr     select_ram_page_000             ; 867C 20 23 BE  #.
        sta     $FD01,x                         ; 867F 9D 01 FD ...
        inx                                     ; 8682 E8       .
        iny                                     ; 8683 C8       .
        dec     $B0                             ; 8684 C6 B0    ..
        bne     L8676                           ; 8686 D0 EE    ..
        lda     #$00                            ; 8688 A9 00    ..
        sta     fdc_status_or_cmd,x             ; 868A 9D F8 FC ...
        lda     $FCF4,x                         ; 868D BD F4 FC ...
        cmp     #$01                            ; 8690 C9 01    ..
        lda     $FCF5,x                         ; 8692 BD F5 FC ...
        adc     #$00                            ; 8695 69 00    i.
        sta     $FD01,x                         ; 8697 9D 01 FD ...
        php                                     ; 869A 08       .
        lda     $FCF6,x                         ; 869B BD F6 FC ...
        jsr     LA9F6                           ; 869E 20 F6 A9  ..
        plp                                     ; 86A1 28       (
        adc     #$00                            ; 86A2 69 00    i.
        sta     $FD02,x                         ; 86A4 9D 02 FD ...
        lda     $FCF7,x                         ; 86A7 BD F7 FC ...
        sta     $FD03,x                         ; 86AA 9D 03 FD ...
        lda     $FCF6,x                         ; 86AD BD F6 FC ...
        and     #$03                            ; 86B0 29 03    ).
        sta     $FD04,x                         ; 86B2 9D 04 FD ...
L86B5:  jsr     select_ram_page_001             ; 86B5 20 28 BE  (.
        sec                                     ; 86B8 38       8
        lda     $FDD6                           ; 86B9 AD D6 FD ...
        sbc     $BD                             ; 86BC E5 BD    ..
        sta     $C3                             ; 86BE 85 C3    ..
        ldy     $FDF7                           ; 86C0 AC F7 FD ...
        jsr     select_ram_page_000             ; 86C3 20 23 BE  #.
        lda     $FD11,y                         ; 86C6 B9 11 FD ...
        sta     $C6                             ; 86C9 85 C6    ..
        lda     $FD12,y                         ; 86CB B9 12 FD ...
        sta     $C7                             ; 86CE 85 C7    ..
        lda     $FD13,y                         ; 86D0 B9 13 FD ...
        sta     $C8                             ; 86D3 85 C8    ..
        lda     $FD14,y                         ; 86D5 B9 14 FD ...
        sta     $C9                             ; 86D8 85 C9    ..
        jsr     L893A                           ; 86DA 20 3A 89  :.
        lda     $BD                             ; 86DD A5 BD    ..
        sta     $BF                             ; 86DF 85 BF    ..
        lda     #$00                            ; 86E1 A9 00    ..
        sta     $BE                             ; 86E3 85 BE    ..
        sta     $C2                             ; 86E5 85 C2    ..
        lda     $C3                             ; 86E7 A5 C3    ..
        jsr     select_ram_page_000             ; 86E9 20 23 BE  #.
        sta     $FD07,y                         ; 86EC 99 07 FD ...
        jsr     L960B                           ; 86EF 20 0B 96  ..
        jsr     L9775                           ; 86F2 20 75 97  u.
        jsr     L894F                           ; 86F5 20 4F 89  O.
        clc                                     ; 86F8 18       .
        lda     $BD                             ; 86F9 A5 BD    ..
        adc     $C3                             ; 86FB 65 C3    e.
        sta     $BD                             ; 86FD 85 BD    ..
        ldy     $FDF7                           ; 86FF AC F7 FD ...
        jsr     select_ram_page_000             ; 8702 20 23 BE  #.
        lda     $C6                             ; 8705 A5 C6    ..
        sta     $FD11,y                         ; 8707 99 11 FD ...
        lda     $C7                             ; 870A A5 C7    ..
        sta     $FD12,y                         ; 870C 99 12 FD ...
        lda     $C8                             ; 870F A5 C8    ..
        sta     $FD13,y                         ; 8711 99 13 FD ...
        lda     $C9                             ; 8714 A5 C9    ..
        sta     $FD14,y                         ; 8716 99 14 FD ...
        lda     $C6                             ; 8719 A5 C6    ..
        ora     $C7                             ; 871B 05 C7    ..
        beq     L872A                           ; 871D F0 0B    ..
        jsr     select_ram_page_000             ; 871F 20 23 BE  #.
        lda     $FD08,y                         ; 8722 B9 08 FD ...
        ora     #$80                            ; 8725 09 80    ..
        sta     $FD08,y                         ; 8727 99 08 FD ...
L872A:  jsr     select_ram_page_001             ; 872A 20 28 BE  (.
        lda     $BD                             ; 872D A5 BD    ..
        cmp     $FDD6                           ; 872F CD D6 FD ...
        beq     L876B                           ; 8732 F0 37    .7
        bit     L00A8                           ; 8734 24 A8    $.
        bmi     L876B                           ; 8736 30 33    03
        lda     L00A8                           ; 8738 A5 A8    ..
        and     #$7F                            ; 873A 29 7F    ).
        cmp     #$08                            ; 873C C9 08    ..
        beq     L876B                           ; 873E F0 2B    .+
        clc                                     ; 8740 18       .
        lda     $FDF7                           ; 8741 AD F7 FD ...
        adc     #$17                            ; 8744 69 17    i.
        sta     $FDF7                           ; 8746 8D F7 FD ...
L8749:  ldx     #$07                            ; 8749 A2 07    ..
L874B:  pla                                     ; 874B 68       h
        sta     $C7,x                           ; 874C 95 C7    ..
        dex                                     ; 874E CA       .
        bpl     L874B                           ; 874F 10 FA    ..
        pla                                     ; 8751 68       h
        sta     $FDC2                           ; 8752 8D C2 FD ...
        jsr     L8BD5                           ; 8755 20 D5 8B  ..
        bcc     L875F                           ; 8758 90 05    ..
        inc     L00A8                           ; 875A E6 A8    ..
        jmp     L863B                           ; 875C 4C 3B 86 L;.

; ----------------------------------------------------------------------------
L875F:  ldy     $FDF7                           ; 875F AC F7 FD ...
        bne     L8765                           ; 8762 D0 01    ..
        rts                                     ; 8764 60       `

; ----------------------------------------------------------------------------
L8765:  lda     L00A8                           ; 8765 A5 A8    ..
        ora     #$80                            ; 8767 09 80    ..
        sta     L00A8                           ; 8769 85 A8    ..
L876B:  jsr     select_ram_page_001             ; 876B 20 28 BE  (.
        jsr     L842F                           ; 876E 20 2F 84  /.
        lda     $FDD5                           ; 8771 AD D5 FD ...
        sta     $BD                             ; 8774 85 BD    ..
        lda     L00A8                           ; 8776 A5 A8    ..
        and     #$7F                            ; 8778 29 7F    ).
        tax                                     ; 877A AA       .
        ldy     #$E9                            ; 877B A0 E9    ..
L877D:  txa                                     ; 877D 8A       .
        pha                                     ; 877E 48       H
        clc                                     ; 877F 18       .
        tya                                     ; 8780 98       .
        adc     #$17                            ; 8781 69 17    i.
        sta     $FDF8                           ; 8783 8D F8 FD ...
        pha                                     ; 8786 48       H
        tay                                     ; 8787 A8       .
        jsr     select_ram_page_000             ; 8788 20 23 BE  #.
        lda     $FD08,y                         ; 878B B9 08 FD ...
        and     #$40                            ; 878E 29 40    )@
        bne     L87E9                           ; 8790 D0 57    .W
        lda     $FD08,y                         ; 8792 B9 08 FD ...
        ora     #$40                            ; 8795 09 40    .@
        sta     $FD08,y                         ; 8797 99 08 FD ...
        ldx     #$00                            ; 879A A2 00    ..
L879C:  lda     $FD00,y                         ; 879C B9 00 FD ...
        sta     $BE,x                           ; 879F 95 BE    ..
        iny                                     ; 87A1 C8       .
        inx                                     ; 87A2 E8       .
        cpx     #$11                            ; 87A3 E0 11    ..
        bne     L879C                           ; 87A5 D0 F5    ..
        jsr     L97BB                           ; 87A7 20 BB 97  ..
        jsr     L8BCE                           ; 87AA 20 CE 8B  ..
        bcc     L87B2                           ; 87AD 90 03    ..
        jsr     L8C18                           ; 87AF 20 18 8C  ..
L87B2:  jsr     L84DB                           ; 87B2 20 DB 84  ..
        jsr     L95FC                           ; 87B5 20 FC 95  ..
        jsr     L961B                           ; 87B8 20 1B 96  ..
        lda     $C4                             ; 87BB A5 C4    ..
        jsr     LA9F6                           ; 87BD 20 F6 A9  ..
        sta     $C6                             ; 87C0 85 C6    ..
        jsr     L947E                           ; 87C2 20 7E 94  ~.
        jsr     LA933                           ; 87C5 20 33 A9  3.
        .byte   "Writing "                      ; 87C8 57 72 69 74 69 6E 67 20Writing 
; ----------------------------------------------------------------------------
        nop                                     ; 87D0 EA       .
        jsr     L8A54                           ; 87D1 20 54 8A  T.
        jsr     L841A                           ; 87D4 20 1A 84  ..
        ldy     $FDF8                           ; 87D7 AC F8 FD ...
        jsr     select_ram_page_000             ; 87DA 20 23 BE  #.
        lda     $C4                             ; 87DD A5 C4    ..
        and     #$03                            ; 87DF 29 03    ).
        sta     $FD15,y                         ; 87E1 99 15 FD ...
        lda     $C5                             ; 87E4 A5 C5    ..
        sta     $FD16,y                         ; 87E6 99 16 FD ...
L87E9:  lda     $FD07,y                         ; 87E9 B9 07 FD ...
        sta     $C3                             ; 87EC 85 C3    ..
        clc                                     ; 87EE 18       .
        lda     $FD16,y                         ; 87EF B9 16 FD ...
        sta     $C5                             ; 87F2 85 C5    ..
        adc     $C3                             ; 87F4 65 C3    e.
        sta     $FD16,y                         ; 87F6 99 16 FD ...
        lda     $FD15,y                         ; 87F9 B9 15 FD ...
        sta     $C4                             ; 87FC 85 C4    ..
        adc     #$00                            ; 87FE 69 00    i.
        sta     $FD15,y                         ; 8800 99 15 FD ...
        lda     $BD                             ; 8803 A5 BD    ..
        sta     $BF                             ; 8805 85 BF    ..
        lda     #$00                            ; 8807 A9 00    ..
        sta     $BE                             ; 8809 85 BE    ..
        sta     $C2                             ; 880B 85 C2    ..
        jsr     L84B0                           ; 880D 20 B0 84  ..
        jsr     L960B                           ; 8810 20 0B 96  ..
        jsr     L977B                           ; 8813 20 7B 97  {.
        clc                                     ; 8816 18       .
        lda     $BD                             ; 8817 A5 BD    ..
        adc     $C3                             ; 8819 65 C3    e.
        sta     $BD                             ; 881B 85 BD    ..
        pla                                     ; 881D 68       h
        tay                                     ; 881E A8       .
        pla                                     ; 881F 68       h
        tax                                     ; 8820 AA       .
        dex                                     ; 8821 CA       .
        beq     L8827                           ; 8822 F0 03    ..
        jmp     L877D                           ; 8824 4C 7D 87 L}.

; ----------------------------------------------------------------------------
L8827:  jsr     L84AC                           ; 8827 20 AC 84  ..
        ldy     $FDF8                           ; 882A AC F8 FD ...
        jsr     select_ram_page_000             ; 882D 20 23 BE  #.
        lda     $FD08,y                         ; 8830 B9 08 FD ...
        and     #$80                            ; 8833 29 80    ).
        beq     L8861                           ; 8835 F0 2A    .*
        ldx     #$00                            ; 8837 A2 00    ..
L8839:  lda     $FD00,y                         ; 8839 B9 00 FD ...
        sta     $FD00,x                         ; 883C 9D 00 FD ...
        iny                                     ; 883F C8       .
        inx                                     ; 8840 E8       .
        cpx     #$17                            ; 8841 E0 17    ..
        bne     L8839                           ; 8843 D0 F4    ..
        lda     #$40                            ; 8845 A9 40    .@
        sta     $FD08                           ; 8847 8D 08 FD ...
        jsr     L8422                           ; 884A 20 22 84  ".
        jsr     L969E                           ; 884D 20 9E 96  ..
        lda     $FDD5                           ; 8850 AD D5 FD ...
        sta     $BD                             ; 8853 85 BD    ..
        lda     #$00                            ; 8855 A9 00    ..
        sta     $FDF7                           ; 8857 8D F7 FD ...
        sta     L00A8                           ; 885A 85 A8    ..
        inc     L00A8                           ; 885C E6 A8    ..
        jmp     L86B5                           ; 885E 4C B5 86 L..

; ----------------------------------------------------------------------------
L8861:  bit     L00A8                           ; 8861 24 A8    $.
        bmi     L887A                           ; 8863 30 15    0.
        jsr     L8422                           ; 8865 20 22 84  ".
        jsr     L969E                           ; 8868 20 9E 96  ..
        lda     $FDD5                           ; 886B AD D5 FD ...
        sta     $BD                             ; 886E 85 BD    ..
        lda     #$00                            ; 8870 A9 00    ..
        sta     $FDF7                           ; 8872 8D F7 FD ...
        sta     L00A8                           ; 8875 85 A8    ..
        jmp     L8749                           ; 8877 4C 49 87 LI.

; ----------------------------------------------------------------------------
L887A:  rts                                     ; 887A 60       `

; ----------------------------------------------------------------------------
L887B:  lda     $FDD5                           ; 887B AD D5 FD ...
        sta     $BF                             ; 887E 85 BF    ..
        lda     #$00                            ; 8880 A9 00    ..
        sta     $BE                             ; 8882 85 BE    ..
        lda     #$0D                            ; 8884 A9 0D    ..
        sta     ($BE),y                         ; 8886 91 BE    ..
        iny                                     ; 8888 C8       .
        lda     #$FF                            ; 8889 A9 FF    ..
        sta     ($BE),y                         ; 888B 91 BE    ..
        rts                                     ; 888D 60       `

; ----------------------------------------------------------------------------
        jsr     L8422                           ; 888E 20 22 84  ".
        jsr     L969E                           ; 8891 20 9E 96  ..
        jsr     L84D4                           ; 8894 20 D4 84  ..
        jsr     select_ram_page_003             ; 8897 20 32 BE  2.
        lda     $FD07                           ; 889A AD 07 FD ...
        sta     $C6                             ; 889D 85 C6    ..
        lda     $FD06                           ; 889F AD 06 FD ...
        and     #$03                            ; 88A2 29 03    ).
        sta     $C7                             ; 88A4 85 C7    ..
        lda     $FD06                           ; 88A6 AD 06 FD ...
        and     #$F0                            ; 88A9 29 F0    ).
        jsr     select_ram_page_001             ; 88AB 20 28 BE  (.
        sta     LFDE0                           ; 88AE 8D E0 FD ...
        jsr     L842F                           ; 88B1 20 2F 84  /.
        jsr     L969E                           ; 88B4 20 9E 96  ..
        jmp     L84DB                           ; 88B7 4C DB 84 L..

; ----------------------------------------------------------------------------
        jsr     select_ram_page_003             ; 88BA 20 32 BE  2.
        lda     $FD06                           ; 88BD AD 06 FD ...
        and     #$03                            ; 88C0 29 03    ).
        cmp     $C7                             ; 88C2 C5 C7    ..
        bcc     L88CD                           ; 88C4 90 07    ..
        bne     L88CD                           ; 88C6 D0 05    ..
        lda     $FD07                           ; 88C8 AD 07 FD ...
        cmp     $C6                             ; 88CB C5 C6    ..
L88CD:  rts                                     ; 88CD 60       `

; ----------------------------------------------------------------------------
L88CE:  jsr     push_registers_and_tuck_restoration_thunk; 88CE 20 AB A8 ..
        lda     #$02                            ; 88D1 A9 02    ..
        sta     $FDD7                           ; 88D3 8D D7 FD ...
        lda     #$00                            ; 88D6 A9 00    ..
        sta     $BF                             ; 88D8 85 BF    ..
L88DA:  jsr     L8935                           ; 88DA 20 35 89  5.
        lda     #$02                            ; 88DD A9 02    ..
        sta     $BE                             ; 88DF 85 BE    ..
        jsr     L978C                           ; 88E1 20 8C 97  ..
        lda     $CA                             ; 88E4 A5 CA    ..
        sta     $C5                             ; 88E6 85 C5    ..
        lda     $CB                             ; 88E8 A5 CB    ..
        sta     $C4                             ; 88EA 85 C4    ..
        lda     #$02                            ; 88EC A9 02    ..
        sta     $BE                             ; 88EE 85 BE    ..
        jsr     L9789                           ; 88F0 20 89 97  ..
        jsr     L894F                           ; 88F3 20 4F 89  O.
        bne     L88DA                           ; 88F6 D0 E2    ..
        rts                                     ; 88F8 60       `

; ----------------------------------------------------------------------------
L88F9:  jsr     select_ram_page_001             ; 88F9 20 28 BE  (.
        lda     #$00                            ; 88FC A9 00    ..
        sta     $BE                             ; 88FE 85 BE    ..
        sta     $C2                             ; 8900 85 C2    ..
L8902:  jsr     L8935                           ; 8902 20 35 89  5.
        lda     $FDD5                           ; 8905 AD D5 FD ...
        sta     $BF                             ; 8908 85 BF    ..
        jsr     L84AC                           ; 890A 20 AC 84  ..
        jsr     L8422                           ; 890D 20 22 84  ".
        jsr     L960B                           ; 8910 20 0B 96  ..
        jsr     L9775                           ; 8913 20 75 97  u.
        lda     $CA                             ; 8916 A5 CA    ..
        sta     $C5                             ; 8918 85 C5    ..
        lda     $CB                             ; 891A A5 CB    ..
        sta     $C4                             ; 891C 85 C4    ..
        lda     $FDD5                           ; 891E AD D5 FD ...
        sta     $BF                             ; 8921 85 BF    ..
        jsr     L84B0                           ; 8923 20 B0 84  ..
        jsr     L842F                           ; 8926 20 2F 84  /.
        jsr     L960B                           ; 8929 20 0B 96  ..
        jsr     L977B                           ; 892C 20 7B 97  {.
        jsr     L894F                           ; 892F 20 4F 89  O.
        bne     L8902                           ; 8932 D0 CE    ..
        rts                                     ; 8934 60       `

; ----------------------------------------------------------------------------
L8935:  lda     $FDD7                           ; 8935 AD D7 FD ...
        sta     $C3                             ; 8938 85 C3    ..
L893A:  ldx     $C6                             ; 893A A6 C6    ..
        cpx     $C3                             ; 893C E4 C3    ..
        lda     $C7                             ; 893E A5 C7    ..
        sbc     #$00                            ; 8940 E9 00    ..
        bcs     L8946                           ; 8942 B0 02    ..
        stx     $C3                             ; 8944 86 C3    ..
L8946:  lda     $C8                             ; 8946 A5 C8    ..
        sta     $C5                             ; 8948 85 C5    ..
        lda     $C9                             ; 894A A5 C9    ..
        sta     $C4                             ; 894C 85 C4    ..
        rts                                     ; 894E 60       `

; ----------------------------------------------------------------------------
L894F:  lda     $CA                             ; 894F A5 CA    ..
        clc                                     ; 8951 18       .
        adc     $C3                             ; 8952 65 C3    e.
        sta     $CA                             ; 8954 85 CA    ..
        bcc     L895A                           ; 8956 90 02    ..
        inc     $CB                             ; 8958 E6 CB    ..
L895A:  lda     $C3                             ; 895A A5 C3    ..
        clc                                     ; 895C 18       .
        adc     $C8                             ; 895D 65 C8    e.
        sta     $C8                             ; 895F 85 C8    ..
        bcc     L8965                           ; 8961 90 02    ..
        inc     $C9                             ; 8963 E6 C9    ..
L8965:  sec                                     ; 8965 38       8
        lda     $C6                             ; 8966 A5 C6    ..
        sbc     $C3                             ; 8968 E5 C3    ..
        sta     $C6                             ; 896A 85 C6    ..
        bcs     L8970                           ; 896C B0 02    ..
        dec     $C7                             ; 896E C6 C7    ..
L8970:  ora     $C7                             ; 8970 05 C7    ..
        rts                                     ; 8972 60       `

; ----------------------------------------------------------------------------
L8973:  jsr     L8983                           ; 8973 20 83 89  ..
        dex                                     ; 8976 CA       .
        dex                                     ; 8977 CA       .
        jsr     L897B                           ; 8978 20 7B 89  {.
L897B:  lda     ($B0),y                         ; 897B B1 B0    ..
        sta     $FDB3,x                         ; 897D 9D B3 FD ...
        inx                                     ; 8980 E8       .
        iny                                     ; 8981 C8       .
        rts                                     ; 8982 60       `

; ----------------------------------------------------------------------------
L8983:  jsr     L8986                           ; 8983 20 86 89  ..
L8986:  lda     ($B0),y                         ; 8986 B1 B0    ..
        sta     $BC,x                           ; 8988 95 BC    ..
        inx                                     ; 898A E8       .
        iny                                     ; 898B C8       .
        rts                                     ; 898C 60       `

; ----------------------------------------------------------------------------
L898D:  jsr     LAA7E                           ; 898D 20 7E AA  ~.
        jmp     L89A3                           ; 8990 4C A3 89 L..

; ----------------------------------------------------------------------------
L8993:  jsr     LAA7E                           ; 8993 20 7E AA  ~.
L8996:  lda     $BC                             ; 8996 A5 BC    ..
        sta     $F2                             ; 8998 85 F2    ..
        lda     $BD                             ; 899A A5 BD    ..
        sta     $F3                             ; 899C 85 F3    ..
        ldy     #$00                            ; 899E A0 00    ..
        jsr     LAA52                           ; 89A0 20 52 AA  R.
L89A3:  jsr     L8A0E                           ; 89A3 20 0E 8A  ..
        jsr     gsread                          ; 89A6 20 C5 FF  ..
        bcs     L89FE                           ; 89A9 B0 53    .S
        cmp     #$3A                            ; 89AB C9 3A    .:
        bne     L89D1                           ; 89AD D0 22    ."
        jsr     gsread                          ; 89AF 20 C5 FF  ..
        bcs     L8A0B                           ; 89B2 B0 57    .W
        jsr     LAA56                           ; 89B4 20 56 AA  V.
        jsr     gsread                          ; 89B7 20 C5 FF  ..
        bcs     L89FE                           ; 89BA B0 42    .B
        cmp     #$2E                            ; 89BC C9 2E    ..
        beq     L89CC                           ; 89BE F0 0C    ..
        jsr     LAA5C                           ; 89C0 20 5C AA  \.
        jsr     gsread                          ; 89C3 20 C5 FF  ..
        bcs     L89FE                           ; 89C6 B0 36    .6
        cmp     #$2E                            ; 89C8 C9 2E    ..
        bne     L89FE                           ; 89CA D0 32    .2
L89CC:  jsr     gsread                          ; 89CC 20 C5 FF  ..
        bcs     L89FE                           ; 89CF B0 2D    .-
L89D1:  sta     $C7                             ; 89D1 85 C7    ..
        ldx     #$00                            ; 89D3 A2 00    ..
        jsr     gsread                          ; 89D5 20 C5 FF  ..
        bcs     L8A1E                           ; 89D8 B0 44    .D
        inx                                     ; 89DA E8       .
        cmp     #$2E                            ; 89DB C9 2E    ..
        bne     L89EA                           ; 89DD D0 0B    ..
        lda     $C7                             ; 89DF A5 C7    ..
        jsr     LAB10                           ; 89E1 20 10 AB  ..
        jsr     gsread                          ; 89E4 20 C5 FF  ..
        bcs     L89FE                           ; 89E7 B0 15    ..
        dex                                     ; 89E9 CA       .
L89EA:  cmp     #$2A                            ; 89EA C9 2A    .*
        beq     L8A24                           ; 89EC F0 36    .6
        cmp     #$21                            ; 89EE C9 21    .!
        bcc     L89FE                           ; 89F0 90 0C    ..
        sta     $C7,x                           ; 89F2 95 C7    ..
        inx                                     ; 89F4 E8       .
        jsr     gsread                          ; 89F5 20 C5 FF  ..
        bcs     L8A1D                           ; 89F8 B0 23    .#
        cpx     #$07                            ; 89FA E0 07    ..
        bne     L89EA                           ; 89FC D0 EC    ..
L89FE:  jsr     LA8FC                           ; 89FE 20 FC A8  ..
        cpy     $6966                           ; 8A01 CC 66 69 .fi
        jmp     (L6E65)                         ; 8A04 6C 65 6E len

; ----------------------------------------------------------------------------
        adc     ($6D,x)                         ; 8A07 61 6D    am
        adc     $00                             ; 8A09 65 00    e.
L8A0B:  jmp     LAA94                           ; 8A0B 4C 94 AA L..

; ----------------------------------------------------------------------------
L8A0E:  ldx     #$00                            ; 8A0E A2 00    ..
        lda     #$20                            ; 8A10 A9 20    . 
        bne     L8A16                           ; 8A12 D0 02    ..
L8A14:  lda     #$23                            ; 8A14 A9 23    .#
L8A16:  sta     $C7,x                           ; 8A16 95 C7    ..
        inx                                     ; 8A18 E8       .
        cpx     #$07                            ; 8A19 E0 07    ..
        bne     L8A16                           ; 8A1B D0 F9    ..
L8A1D:  rts                                     ; 8A1D 60       `

; ----------------------------------------------------------------------------
L8A1E:  lda     $C7                             ; 8A1E A5 C7    ..
        cmp     #$2A                            ; 8A20 C9 2A    .*
        bne     L8A1D                           ; 8A22 D0 F9    ..
L8A24:  jsr     gsread                          ; 8A24 20 C5 FF  ..
        bcs     L8A14                           ; 8A27 B0 EB    ..
        cmp     #$20                            ; 8A29 C9 20    . 
        beq     L8A14                           ; 8A2B F0 E7    ..
        bne     L89FE                           ; 8A2D D0 CF    ..
L8A2F:  jsr     push_registers_and_tuck_restoration_thunk; 8A2F 20 AB A8 ..
        jsr     select_ram_page_003             ; 8A32 20 32 BE  2.
        lda     $FD04                           ; 8A35 AD 04 FD ...
        jsr     L969B                           ; 8A38 20 9B 96  ..
        jsr     select_ram_page_003             ; 8A3B 20 32 BE  2.
        cmp     $FD04                           ; 8A3E CD 04 FD ...
        beq     L8A1D                           ; 8A41 F0 DA    ..
L8A43:  jsr     LA90D                           ; 8A43 20 0D A9  ..
        .byte   $C8                             ; 8A46 C8       .
        .byte   "Disk changed"                  ; 8A47 44 69 73 6B 20 63 68 61Disk cha
                                                ; 8A4F 6E 67 65 64nged
        .byte   $00                             ; 8A53 00       .
; ----------------------------------------------------------------------------
L8A54:  jsr     push_registers_and_tuck_restoration_thunk; 8A54 20 AB A8 ..
        jsr     select_ram_page_002             ; 8A57 20 2D BE  -.
        lda     $FD0F,y                         ; 8A5A B9 0F FD ...
        php                                     ; 8A5D 08       .
        and     #$7F                            ; 8A5E 29 7F    ).
        bne     L8A67                           ; 8A60 D0 05    ..
        jsr     LA874                           ; 8A62 20 74 A8  t.
        beq     L8A6D                           ; 8A65 F0 06    ..
L8A67:  jsr     LA9B1                           ; 8A67 20 B1 A9  ..
        jsr     LA9AF                           ; 8A6A 20 AF A9  ..
L8A6D:  ldx     #$06                            ; 8A6D A2 06    ..
L8A6F:  lda     $FD08,y                         ; 8A6F B9 08 FD ...
        and     #$7F                            ; 8A72 29 7F    ).
        jsr     LA9B1                           ; 8A74 20 B1 A9  ..
        iny                                     ; 8A77 C8       .
        dex                                     ; 8A78 CA       .
        bpl     L8A6F                           ; 8A79 10 F4    ..
        jsr     select_ram_page_001             ; 8A7B 20 28 BE  (.
        jsr     LA874                           ; 8A7E 20 74 A8  t.
        lda     #$20                            ; 8A81 A9 20    . 
        plp                                     ; 8A83 28       (
        bpl     L8A88                           ; 8A84 10 02    ..
        lda     #$4C                            ; 8A86 A9 4C    .L
L8A88:  jsr     LA9B1                           ; 8A88 20 B1 A9  ..
        jmp     LA877                           ; 8A8B 4C 77 A8 Lw.

; ----------------------------------------------------------------------------
L8A8E:  jsr     LA877                           ; 8A8E 20 77 A8  w.
        dey                                     ; 8A91 88       .
        bne     L8A8E                           ; 8A92 D0 FA    ..
        rts                                     ; 8A94 60       `

; ----------------------------------------------------------------------------
L8A95:  lda     #$00                            ; 8A95 A9 00    ..
        sta     $A5                             ; 8A97 85 A5    ..
        ldx     $C4                             ; 8A99 A6 C4    ..
        jmp     L8AAA                           ; 8A9B 4C AA 8A L..

; ----------------------------------------------------------------------------
L8A9E:  lda     $C4                             ; 8A9E A5 C4    ..
        jsr     LA9F6                           ; 8AA0 20 F6 A9  ..
        sta     $A5                             ; 8AA3 85 A5    ..
        lda     $C4                             ; 8AA5 A5 C4    ..
        and     #$03                            ; 8AA7 29 03    ).
        tax                                     ; 8AA9 AA       .
L8AAA:  lda     $BE                             ; 8AAA A5 BE    ..
        sta     $A6                             ; 8AAC 85 A6    ..
        lda     $BF                             ; 8AAE A5 BF    ..
        sta     $A7                             ; 8AB0 85 A7    ..
        lda     $C3                             ; 8AB2 A5 C3    ..
        sta     $A4                             ; 8AB4 85 A4    ..
        lda     $C2                             ; 8AB6 A5 C2    ..
        sta     $A3                             ; 8AB8 85 A3    ..
        stx     $BA                             ; 8ABA 86 BA    ..
        lda     $C5                             ; 8ABC A5 C5    ..
        sta     $BB                             ; 8ABE 85 BB    ..
        lda     $FDEB                           ; 8AC0 AD EB FD ...
        beq     L8ADE                           ; 8AC3 F0 19    ..
        lda     $FDEC                           ; 8AC5 AD EC FD ...
        sta     $BA                             ; 8AC8 85 BA    ..
        dec     $BA                             ; 8ACA C6 BA    ..
        lda     $C5                             ; 8ACC A5 C5    ..
L8ACE:  sec                                     ; 8ACE 38       8
L8ACF:  inc     $BA                             ; 8ACF E6 BA    ..
        sbc     $FDEB                           ; 8AD1 ED EB FD ...
        bcs     L8ACF                           ; 8AD4 B0 F9    ..
        dex                                     ; 8AD6 CA       .
        bpl     L8ACE                           ; 8AD7 10 F5    ..
        adc     $FDEB                           ; 8AD9 6D EB FD m..
        sta     $BB                             ; 8ADC 85 BB    ..
L8ADE:  rts                                     ; 8ADE 60       `

; ----------------------------------------------------------------------------
L8ADF:  lda     #$23                            ; 8ADF A9 23    .#
        bne     L8AE5                           ; 8AE1 D0 02    ..
L8AE3:  lda     #$FF                            ; 8AE3 A9 FF    ..
L8AE5:  sta     $FDD8                           ; 8AE5 8D D8 FD ...
        rts                                     ; 8AE8 60       `

; ----------------------------------------------------------------------------
L8AE9:  jsr     L898D                           ; 8AE9 20 8D 89  ..
        jmp     L8AF2                           ; 8AEC 4C F2 8A L..

; ----------------------------------------------------------------------------
L8AEF:  jsr     L8993                           ; 8AEF 20 93 89  ..
L8AF2:  jsr     L8BCE                           ; 8AF2 20 CE 8B  ..
        bcs     L8ADE                           ; 8AF5 B0 E7    ..
L8AF7:  jsr     LA905                           ; 8AF7 20 05 A9  ..
        .byte   $D6                             ; 8AFA D6       .
        .byte   "not found"                     ; 8AFB 6E 6F 74 20 66 6F 75 6Enot foun
                                                ; 8B03 64       d
        .byte   $00                             ; 8B04 00       .
; ----------------------------------------------------------------------------
map_command:
        jsr     LAA76                           ; 8B05 20 76 AA  v.
        jsr     L969B                           ; 8B08 20 9B 96  ..
        lda     #$00                            ; 8B0B A9 00    ..
        sta     $C4                             ; 8B0D 85 C4    ..
        sta     $C6                             ; 8B0F 85 C6    ..
        sta     $C7                             ; 8B11 85 C7    ..
        jsr     LA55A                           ; 8B13 20 5A A5  Z.
        sta     $C5                             ; 8B16 85 C5    ..
        lda     $FDEC                           ; 8B18 AD EC FD ...
        beq     L8B39                           ; 8B1B F0 1C    ..
        jsr     LA933                           ; 8B1D 20 33 A9  3.
        .byte   "  Track offset  = "            ; 8B20 20 20 54 72 61 63 6B 20  Track 
                                                ; 8B28 6F 66 66 73 65 74 20 20offset  
                                                ; 8B30 3D 20    = 
; ----------------------------------------------------------------------------
        nop                                     ; 8B32 EA       .
        jsr     LA9D8                           ; 8B33 20 D8 A9  ..
        jsr     L841A                           ; 8B36 20 1A 84  ..
L8B39:  jsr     select_ram_page_003             ; 8B39 20 32 BE  2.
        ldy     $FD05                           ; 8B3C AC 05 FD ...
L8B3F:  jsr     L957A                           ; 8B3F 20 7A 95  z.
        beq     L8B73                           ; 8B42 F0 2F    ./
        clc                                     ; 8B44 18       .
        lda     $B0                             ; 8B45 A5 B0    ..
        adc     $C6                             ; 8B47 65 C6    e.
        sta     $C6                             ; 8B49 85 C6    ..
        txa                                     ; 8B4B 8A       .
        adc     $C7                             ; 8B4C 65 C7    e.
        sta     $C7                             ; 8B4E 85 C7    ..
        jsr     LA933                           ; 8B50 20 33 A9  3.
        .byte   "  Free space "                 ; 8B53 20 20 46 72 65 65 20 73  Free s
                                                ; 8B5B 70 61 63 65 20pace 
; ----------------------------------------------------------------------------
        nop                                     ; 8B60 EA       .
        jsr     L8BB2                           ; 8B61 20 B2 8B  ..
        jsr     LA877                           ; 8B64 20 77 A8  w.
        txa                                     ; 8B67 8A       .
        jsr     LA9E0                           ; 8B68 20 E0 A9  ..
        lda     $B0                             ; 8B6B A5 B0    ..
        jsr     LA9D8                           ; 8B6D 20 D8 A9  ..
        jsr     L841A                           ; 8B70 20 1A 84  ..
L8B73:  tya                                     ; 8B73 98       .
        beq     L8B91                           ; 8B74 F0 1B    ..
        jsr     LAA12                           ; 8B76 20 12 AA  ..
        jsr     L8A54                           ; 8B79 20 54 8A  T.
        jsr     L8C83                           ; 8B7C 20 83 8C  ..
        jsr     LA877                           ; 8B7F 20 77 A8  w.
        jsr     L955E                           ; 8B82 20 5E 95  ^.
        jsr     L8BB2                           ; 8B85 20 B2 8B  ..
        jsr     L841A                           ; 8B88 20 1A 84  ..
        jsr     L9549                           ; 8B8B 20 49 95  I.
        jmp     L8B3F                           ; 8B8E 4C 3F 8B L?.

; ----------------------------------------------------------------------------
L8B91:  jsr     LA933                           ; 8B91 20 33 A9  3.
        .byte   $0D                             ; 8B94 0D       .
        .byte   "Free sectors "                 ; 8B95 46 72 65 65 20 73 65 63Free sec
                                                ; 8B9D 74 6F 72 73 20tors 
; ----------------------------------------------------------------------------
        lda     $C7                             ; 8BA2 A5 C7    ..
        jsr     LA9E0                           ; 8BA4 20 E0 A9  ..
        lda     $C6                             ; 8BA7 A5 C6    ..
        jsr     LA9D8                           ; 8BA9 20 D8 A9  ..
        jsr     L841A                           ; 8BAC 20 1A 84  ..
        jmp     select_ram_page_001             ; 8BAF 4C 28 BE L(.

; ----------------------------------------------------------------------------
L8BB2:  lda     $C4                             ; 8BB2 A5 C4    ..
        jsr     LA9E0                           ; 8BB4 20 E0 A9  ..
        lda     $C5                             ; 8BB7 A5 C5    ..
        jmp     LA9D8                           ; 8BB9 4C D8 A9 L..

; ----------------------------------------------------------------------------
info_command:
        jsr     L8ADF                           ; 8BBC 20 DF 8A  ..
        jsr     LA5C4                           ; 8BBF 20 C4 A5  ..
        jsr     L8AE9                           ; 8BC2 20 E9 8A  ..
L8BC5:  jsr     L8C45                           ; 8BC5 20 45 8C  E.
        jsr     L8BD5                           ; 8BC8 20 D5 8B  ..
        bcs     L8BC5                           ; 8BCB B0 F8    ..
        rts                                     ; 8BCD 60       `

; ----------------------------------------------------------------------------
L8BCE:  jsr     L968B                           ; 8BCE 20 8B 96  ..
        ldy     #$F8                            ; 8BD1 A0 F8    ..
        bne     L8BDB                           ; 8BD3 D0 06    ..
L8BD5:  jsr     select_ram_page_001             ; 8BD5 20 28 BE  (.
        ldy     $FDC2                           ; 8BD8 AC C2 FD ...
L8BDB:  jsr     select_ram_page_003             ; 8BDB 20 32 BE  2.
        jsr     LAA09                           ; 8BDE 20 09 AA  ..
        cpy     $FD05                           ; 8BE1 CC 05 FD ...
        bcs     L8C39                           ; 8BE4 B0 53    .S
        jsr     LAA09                           ; 8BE6 20 09 AA  ..
        ldx     #$07                            ; 8BE9 A2 07    ..
L8BEB:  jsr     select_ram_page_001             ; 8BEB 20 28 BE  (.
        lda     $C7,x                           ; 8BEE B5 C7    ..
        cmp     $FDD8                           ; 8BF0 CD D8 FD ...
        beq     L8C06                           ; 8BF3 F0 11    ..
        jsr     LAA31                           ; 8BF5 20 31 AA  1.
        jsr     select_ram_page_002             ; 8BF8 20 2D BE  -.
        eor     $FD07,y                         ; 8BFB 59 07 FD Y..
        bcs     L8C02                           ; 8BFE B0 02    ..
        and     #$DF                            ; 8C00 29 DF    ).
L8C02:  and     #$7F                            ; 8C02 29 7F    ).
        bne     L8C12                           ; 8C04 D0 0C    ..
L8C06:  dey                                     ; 8C06 88       .
        dex                                     ; 8C07 CA       .
        bpl     L8BEB                           ; 8C08 10 E1    ..
        jsr     select_ram_page_001             ; 8C0A 20 28 BE  (.
        sty     $FDC2                           ; 8C0D 8C C2 FD ...
        sec                                     ; 8C10 38       8
        rts                                     ; 8C11 60       `

; ----------------------------------------------------------------------------
L8C12:  dey                                     ; 8C12 88       .
        dex                                     ; 8C13 CA       .
        bpl     L8C12                           ; 8C14 10 FC    ..
        bmi     L8BDB                           ; 8C16 30 C3    0.
L8C18:  jsr     LA30A                           ; 8C18 20 0A A3  ..
L8C1B:  jsr     select_ram_page_002             ; 8C1B 20 2D BE  -.
        lda     $FD10,y                         ; 8C1E B9 10 FD ...
        sta     $FD08,y                         ; 8C21 99 08 FD ...
        jsr     select_ram_page_003             ; 8C24 20 32 BE  2.
        lda     $FD10,y                         ; 8C27 B9 10 FD ...
        sta     $FD08,y                         ; 8C2A 99 08 FD ...
        iny                                     ; 8C2D C8       .
        cpy     $FD05                           ; 8C2E CC 05 FD ...
        bcc     L8C1B                           ; 8C31 90 E8    ..
        tya                                     ; 8C33 98       .
        sbc     #$08                            ; 8C34 E9 08    ..
        sta     $FD05                           ; 8C36 8D 05 FD ...
L8C39:  clc                                     ; 8C39 18       .
L8C3A:  jmp     select_ram_page_001             ; 8C3A 4C 28 BE L(.

; ----------------------------------------------------------------------------
L8C3D:  jsr     select_ram_page_001             ; 8C3D 20 28 BE  (.
        bit     $FDD9                           ; 8C40 2C D9 FD ,..
        bmi     L8C3A                           ; 8C43 30 F5    0.
L8C45:  jsr     push_registers_and_tuck_restoration_thunk; 8C45 20 AB A8 ..
        jsr     L8A54                           ; 8C48 20 54 8A  T.
        tya                                     ; 8C4B 98       .
        pha                                     ; 8C4C 48       H
        lda     #$A1                            ; 8C4D A9 A1    ..
        sta     $B0                             ; 8C4F 85 B0    ..
        lda     #$FD                            ; 8C51 A9 FD    ..
        sta     $B1                             ; 8C53 85 B1    ..
        jsr     L8C97                           ; 8C55 20 97 8C  ..
        jsr     select_ram_page_001             ; 8C58 20 28 BE  (.
        ldy     #$02                            ; 8C5B A0 02    ..
        jsr     LA877                           ; 8C5D 20 77 A8  w.
        jsr     L8C71                           ; 8C60 20 71 8C  q.
        jsr     L8C71                           ; 8C63 20 71 8C  q.
        jsr     L8C71                           ; 8C66 20 71 8C  q.
        pla                                     ; 8C69 68       h
        tay                                     ; 8C6A A8       .
        jsr     L8C83                           ; 8C6B 20 83 8C  ..
        jmp     L841A                           ; 8C6E 4C 1A 84 L..

; ----------------------------------------------------------------------------
L8C71:  ldx     #$03                            ; 8C71 A2 03    ..
L8C73:  lda     $FDA3,y                         ; 8C73 B9 A3 FD ...
        jsr     LA9D8                           ; 8C76 20 D8 A9  ..
        dey                                     ; 8C79 88       .
        dex                                     ; 8C7A CA       .
        bne     L8C73                           ; 8C7B D0 F6    ..
        jsr     LAA0A                           ; 8C7D 20 0A AA  ..
        jmp     LA877                           ; 8C80 4C 77 A8 Lw.

; ----------------------------------------------------------------------------
L8C83:  jsr     select_ram_page_003             ; 8C83 20 32 BE  2.
        lda     $FD0E,y                         ; 8C86 B9 0E FD ...
        and     #$03                            ; 8C89 29 03    ).
        jsr     LA9E0                           ; 8C8B 20 E0 A9  ..
        lda     $FD0F,y                         ; 8C8E B9 0F FD ...
        jsr     LA9D8                           ; 8C91 20 D8 A9  ..
        jmp     select_ram_page_001             ; 8C94 4C 28 BE L(.

; ----------------------------------------------------------------------------
L8C97:  jsr     push_registers_and_tuck_restoration_thunk; 8C97 20 AB A8 ..
        tya                                     ; 8C9A 98       .
        pha                                     ; 8C9B 48       H
        tax                                     ; 8C9C AA       .
        jsr     select_ram_page_001             ; 8C9D 20 28 BE  (.
        ldy     #$02                            ; 8CA0 A0 02    ..
        lda     #$00                            ; 8CA2 A9 00    ..
L8CA4:  sta     ($B0),y                         ; 8CA4 91 B0    ..
        iny                                     ; 8CA6 C8       .
        cpy     #$12                            ; 8CA7 C0 12    ..
        bne     L8CA4                           ; 8CA9 D0 F9    ..
        ldy     #$02                            ; 8CAB A0 02    ..
L8CAD:  jsr     L8CF5                           ; 8CAD 20 F5 8C  ..
        iny                                     ; 8CB0 C8       .
        iny                                     ; 8CB1 C8       .
        cpy     #$0E                            ; 8CB2 C0 0E    ..
        bne     L8CAD                           ; 8CB4 D0 F7    ..
        pla                                     ; 8CB6 68       h
        tax                                     ; 8CB7 AA       .
        jsr     select_ram_page_002             ; 8CB8 20 2D BE  -.
        lda     $FD0F,x                         ; 8CBB BD 0F FD ...
        bpl     L8CC9                           ; 8CBE 10 09    ..
        lda     #$0A                            ; 8CC0 A9 0A    ..
        ldy     #$0E                            ; 8CC2 A0 0E    ..
        jsr     select_ram_page_001             ; 8CC4 20 28 BE  (.
        sta     ($B0),y                         ; 8CC7 91 B0    ..
L8CC9:  jsr     select_ram_page_003             ; 8CC9 20 32 BE  2.
        lda     $FD0E,x                         ; 8CCC BD 0E FD ...
        jsr     select_ram_page_001             ; 8CCF 20 28 BE  (.
        ldy     #$04                            ; 8CD2 A0 04    ..
        jsr     L8CE3                           ; 8CD4 20 E3 8C  ..
        ldy     #$0C                            ; 8CD7 A0 0C    ..
        lsr     a                               ; 8CD9 4A       J
        lsr     a                               ; 8CDA 4A       J
        pha                                     ; 8CDB 48       H
        and     #$03                            ; 8CDC 29 03    ).
        sta     ($B0),y                         ; 8CDE 91 B0    ..
        pla                                     ; 8CE0 68       h
        ldy     #$08                            ; 8CE1 A0 08    ..
L8CE3:  lsr     a                               ; 8CE3 4A       J
        lsr     a                               ; 8CE4 4A       J
        pha                                     ; 8CE5 48       H
        and     #$03                            ; 8CE6 29 03    ).
        cmp     #$03                            ; 8CE8 C9 03    ..
        bne     L8CF1                           ; 8CEA D0 05    ..
        lda     #$FF                            ; 8CEC A9 FF    ..
        sta     ($B0),y                         ; 8CEE 91 B0    ..
        iny                                     ; 8CF0 C8       .
L8CF1:  sta     ($B0),y                         ; 8CF1 91 B0    ..
        pla                                     ; 8CF3 68       h
        rts                                     ; 8CF4 60       `

; ----------------------------------------------------------------------------
L8CF5:  jsr     L8CF8                           ; 8CF5 20 F8 8C  ..
L8CF8:  jsr     select_ram_page_003             ; 8CF8 20 32 BE  2.
        lda     $FD08,x                         ; 8CFB BD 08 FD ...
        jsr     select_ram_page_001             ; 8CFE 20 28 BE  (.
        sta     ($B0),y                         ; 8D01 91 B0    ..
        inx                                     ; 8D03 E8       .
        iny                                     ; 8D04 C8       .
        rts                                     ; 8D05 60       `

; ----------------------------------------------------------------------------
stat_command:
        jsr     LAA52                           ; 8D06 20 52 AA  R.
        jsr     LAAD2                           ; 8D09 20 D2 AA  ..
        txa                                     ; 8D0C 8A       .
        and     #$01                            ; 8D0D 29 01    ).
        beq     L8D14                           ; 8D0F F0 03    ..
        jmp     L8D53                           ; 8D11 4C 53 8D LS.

; ----------------------------------------------------------------------------
L8D14:  lda     $CF                             ; 8D14 A5 CF    ..
        and     #$0F                            ; 8D16 29 0F    ).
        sta     $CF                             ; 8D18 85 CF    ..
        lda     #$80                            ; 8D1A A9 80    ..
        sta     $FDE9                           ; 8D1C 8D E9 FD ...
        jsr     LABEE                           ; 8D1F 20 EE AB  ..
        bit     $FDED                           ; 8D22 2C ED FD ,..
        bvs     L8D2A                           ; 8D25 70 03    p.
        jmp     L8D53                           ; 8D27 4C 53 8D LS.

; ----------------------------------------------------------------------------
L8D2A:  jsr     L8EAB                           ; 8D2A 20 AB 8E  ..
        ldx     #$00                            ; 8D2D A2 00    ..
L8D2F:  jsr     select_ram_page_000             ; 8D2F 20 23 BE  #.
        lda     $FDBC,x                         ; 8D32 BD BC FD ...
        beq     L8D44                           ; 8D35 F0 0D    ..
        txa                                     ; 8D37 8A       .
        pha                                     ; 8D38 48       H
        jsr     L841A                           ; 8D39 20 1A 84  ..
        jsr     L968B                           ; 8D3C 20 8B 96  ..
        jsr     L8FDD                           ; 8D3F 20 DD 8F  ..
        pla                                     ; 8D42 68       h
        tax                                     ; 8D43 AA       .
L8D44:  clc                                     ; 8D44 18       .
        lda     $CF                             ; 8D45 A5 CF    ..
        adc     #$10                            ; 8D47 69 10    i.
        sta     $CF                             ; 8D49 85 CF    ..
        inx                                     ; 8D4B E8       .
        cpx     #$08                            ; 8D4C E0 08    ..
        bne     L8D2F                           ; 8D4E D0 DF    ..
        jmp     select_ram_page_001             ; 8D50 4C 28 BE L(.

; ----------------------------------------------------------------------------
L8D53:  jsr     L968B                           ; 8D53 20 8B 96  ..
        jsr     L8EAB                           ; 8D56 20 AB 8E  ..
        jmp     L8FDD                           ; 8D59 4C DD 8F L..

; ----------------------------------------------------------------------------
L8D5C:  jsr     LA933                           ; 8D5C 20 33 A9  3.
        .byte   $0D                             ; 8D5F 0D       .
        .byte   "No file"                       ; 8D60 4E 6F 20 66 69 6C 65No file
        .byte   $0D                             ; 8D67 0D       .
; ----------------------------------------------------------------------------
        nop                                     ; 8D68 EA       .
        rts                                     ; 8D69 60       `

; ----------------------------------------------------------------------------
L8D6A:  jsr     select_ram_page_003             ; 8D6A 20 32 BE  2.
        lda     $FD05                           ; 8D6D AD 05 FD ...
        beq     L8D5C                           ; 8D70 F0 EA    ..
        sta     $AC                             ; 8D72 85 AC    ..
        ldy     #$FF                            ; 8D74 A0 FF    ..
        sty     L00A8                           ; 8D76 84 A8    ..
        iny                                     ; 8D78 C8       .
        sty     L00AA                           ; 8D79 84 AA    ..
L8D7B:  jsr     select_ram_page_002             ; 8D7B 20 2D BE  -.
        cpy     $AC                             ; 8D7E C4 AC    ..
        bcs     L8D9F                           ; 8D80 B0 1D    ..
        lda     $FD0F,y                         ; 8D82 B9 0F FD ...
        jsr     select_ram_page_001             ; 8D85 20 28 BE  (.
        eor     $FDC6                           ; 8D88 4D C6 FD M..
        jsr     select_ram_page_002             ; 8D8B 20 2D BE  -.
        and     #$7F                            ; 8D8E 29 7F    ).
        bne     L8D9A                           ; 8D90 D0 08    ..
        lda     $FD0F,y                         ; 8D92 B9 0F FD ...
        and     #$80                            ; 8D95 29 80    ).
        sta     $FD0F,y                         ; 8D97 99 0F FD ...
L8D9A:  jsr     LAA09                           ; 8D9A 20 09 AA  ..
        bcc     L8D7B                           ; 8D9D 90 DC    ..
L8D9F:  jsr     select_ram_page_002             ; 8D9F 20 2D BE  -.
        ldy     #$00                            ; 8DA2 A0 00    ..
        jsr     L8E3E                           ; 8DA4 20 3E 8E  >.
        bcc     L8DB2                           ; 8DA7 90 09    ..
        jsr     select_ram_page_001             ; 8DA9 20 28 BE  (.
        jsr     L97BB                           ; 8DAC 20 BB 97  ..
        jmp     L841A                           ; 8DAF 4C 1A 84 L..

; ----------------------------------------------------------------------------
L8DB2:  sty     $AB                             ; 8DB2 84 AB    ..
        ldx     #$00                            ; 8DB4 A2 00    ..
L8DB6:  jsr     select_ram_page_002             ; 8DB6 20 2D BE  -.
        lda     $FD08,y                         ; 8DB9 B9 08 FD ...
        and     #$7F                            ; 8DBC 29 7F    ).
        jsr     select_ram_page_001             ; 8DBE 20 28 BE  (.
        sta     $FDA1,x                         ; 8DC1 9D A1 FD ...
        iny                                     ; 8DC4 C8       .
        inx                                     ; 8DC5 E8       .
        cpx     #$08                            ; 8DC6 E0 08    ..
        bne     L8DB6                           ; 8DC8 D0 EC    ..
L8DCA:  jsr     select_ram_page_002             ; 8DCA 20 2D BE  -.
        jsr     L8E3E                           ; 8DCD 20 3E 8E  >.
        bcs     L8DFD                           ; 8DD0 B0 2B    .+
        sec                                     ; 8DD2 38       8
        ldx     #$06                            ; 8DD3 A2 06    ..
L8DD5:  jsr     select_ram_page_002             ; 8DD5 20 2D BE  -.
        lda     $FD0E,y                         ; 8DD8 B9 0E FD ...
        jsr     select_ram_page_001             ; 8DDB 20 28 BE  (.
        sbc     $FDA1,x                         ; 8DDE FD A1 FD ...
        dey                                     ; 8DE1 88       .
        dex                                     ; 8DE2 CA       .
        bpl     L8DD5                           ; 8DE3 10 F0    ..
        jsr     LAA0A                           ; 8DE5 20 0A AA  ..
        jsr     select_ram_page_002             ; 8DE8 20 2D BE  -.
        lda     $FD0F,y                         ; 8DEB B9 0F FD ...
        and     #$7F                            ; 8DEE 29 7F    ).
        jsr     select_ram_page_001             ; 8DF0 20 28 BE  (.
        sbc     $FDA8                           ; 8DF3 ED A8 FD ...
        bcc     L8DB2                           ; 8DF6 90 BA    ..
        jsr     LAA09                           ; 8DF8 20 09 AA  ..
        bcs     L8DCA                           ; 8DFB B0 CD    ..
L8DFD:  jsr     select_ram_page_002             ; 8DFD 20 2D BE  -.
        ldy     $AB                             ; 8E00 A4 AB    ..
        lda     $FD08,y                         ; 8E02 B9 08 FD ...
        ora     #$80                            ; 8E05 09 80    ..
        sta     $FD08,y                         ; 8E07 99 08 FD ...
        jsr     select_ram_page_001             ; 8E0A 20 28 BE  (.
        lda     $FDA8                           ; 8E0D AD A8 FD ...
        cmp     L00AA                           ; 8E10 C5 AA    ..
        beq     L8E24                           ; 8E12 F0 10    ..
        ldx     L00AA                           ; 8E14 A6 AA    ..
        sta     L00AA                           ; 8E16 85 AA    ..
        bne     L8E24                           ; 8E18 D0 0A    ..
        jsr     L841A                           ; 8E1A 20 1A 84  ..
L8E1D:  jsr     L841A                           ; 8E1D 20 1A 84  ..
        ldy     #$FF                            ; 8E20 A0 FF    ..
        bne     L8E2D                           ; 8E22 D0 09    ..
L8E24:  ldy     L00A8                           ; 8E24 A4 A8    ..
        bne     L8E1D                           ; 8E26 D0 F5    ..
        ldy     #$05                            ; 8E28 A0 05    ..
        jsr     L8A8E                           ; 8E2A 20 8E 8A  ..
L8E2D:  iny                                     ; 8E2D C8       .
        sty     L00A8                           ; 8E2E 84 A8    ..
        ldy     $AB                             ; 8E30 A4 AB    ..
        jsr     LA874                           ; 8E32 20 74 A8  t.
        jsr     L8A54                           ; 8E35 20 54 8A  T.
        jmp     L8D9F                           ; 8E38 4C 9F 8D L..

; ----------------------------------------------------------------------------
L8E3B:  jsr     LAA09                           ; 8E3B 20 09 AA  ..
L8E3E:  cpy     $AC                             ; 8E3E C4 AC    ..
        bcs     L8E47                           ; 8E40 B0 05    ..
        lda     $FD08,y                         ; 8E42 B9 08 FD ...
        bmi     L8E3B                           ; 8E45 30 F4    0.
L8E47:  rts                                     ; 8E47 60       `

; ----------------------------------------------------------------------------
L8E48:  bit     L8E47                           ; 8E48 2C 47 8E ,G.
        bvs     L8E5E                           ; 8E4B 70 11    p.
L8E4D:  jsr     LA933                           ; 8E4D 20 33 A9  3.
        .byte   " Drive "                       ; 8E50 20 44 72 69 76 65 20 Drive 
; ----------------------------------------------------------------------------
        nop                                     ; 8E57 EA       .
L8E58:  jsr     select_ram_page_001             ; 8E58 20 28 BE  (.
        bit     $FDED                           ; 8E5B 2C ED FD ,..
L8E5E:  php                                     ; 8E5E 08       .
        pha                                     ; 8E5F 48       H
        and     #$07                            ; 8E60 29 07    ).
        jsr     LA9E0                           ; 8E62 20 E0 A9  ..
        pla                                     ; 8E65 68       h
        plp                                     ; 8E66 28       (
        bvc     L8E6F                           ; 8E67 50 06    P.
        lsr     a                               ; 8E69 4A       J
        lsr     a                               ; 8E6A 4A       J
        lsr     a                               ; 8E6B 4A       J
        lsr     a                               ; 8E6C 4A       J
        bne     L8E70                           ; 8E6D D0 01    ..
L8E6F:  rts                                     ; 8E6F 60       `

; ----------------------------------------------------------------------------
L8E70:  dey                                     ; 8E70 88       .
        clc                                     ; 8E71 18       .
        adc     #$41                            ; 8E72 69 41    iA
        jmp     LA9B1                           ; 8E74 4C B1 A9 L..

; ----------------------------------------------------------------------------
L8E77:  ldy     #$0B                            ; 8E77 A0 0B    ..
        jsr     L8A8E                           ; 8E79 20 8E 8A  ..
L8E7C:  jsr     select_ram_page_002             ; 8E7C 20 2D BE  -.
        lda     $FD00,y                         ; 8E7F B9 00 FD ...
        cpy     #$08                            ; 8E82 C0 08    ..
        bcc     L8E8C                           ; 8E84 90 06    ..
        jsr     select_ram_page_003             ; 8E86 20 32 BE  2.
        lda     fdc_status_or_cmd,y             ; 8E89 B9 F8 FC ...
L8E8C:  jsr     LA9B1                           ; 8E8C 20 B1 A9  ..
        iny                                     ; 8E8F C8       .
        cpy     #$0C                            ; 8E90 C0 0C    ..
        bne     L8E7C                           ; 8E92 D0 E8    ..
        jsr     LA933                           ; 8E94 20 33 A9  3.
        .byte   $0D                             ; 8E97 0D       .
        .byte   " ("                            ; 8E98 20 28     (
; ----------------------------------------------------------------------------
        nop                                     ; 8E9A EA       .
        jsr     select_ram_page_003             ; 8E9B 20 32 BE  2.
        lda     $FD04                           ; 8E9E AD 04 FD ...
        jsr     LA9D8                           ; 8EA1 20 D8 A9  ..
        jsr     LA933                           ; 8EA4 20 33 A9  3.
        .byte   ")"                             ; 8EA7 29       )
        .byte   $0D                             ; 8EA8 0D       .
; ----------------------------------------------------------------------------
        nop                                     ; 8EA9 EA       .
        rts                                     ; 8EAA 60       `

; ----------------------------------------------------------------------------
L8EAB:  jsr     select_ram_page_001             ; 8EAB 20 28 BE  (.
        lda     #$83                            ; 8EAE A9 83    ..
        jsr     LA9B1                           ; 8EB0 20 B1 A9  ..
        jsr     LB7B2                           ; 8EB3 20 B2 B7  ..
        beq     L8F23                           ; 8EB6 F0 6B    .k
        bit     $FDED                           ; 8EB8 2C ED FD ,..
        bvs     L8EC6                           ; 8EBB 70 09    p.
        jsr     LA933                           ; 8EBD 20 33 A9  3.
        .byte   "Sing"                          ; 8EC0 53 69 6E 67Sing
; ----------------------------------------------------------------------------
        bcc     L8ECE                           ; 8EC4 90 08    ..
L8EC6:  jsr     LA933                           ; 8EC6 20 33 A9  3.
        .byte   "Doub"                          ; 8EC9 44 6F 75 62Doub
; ----------------------------------------------------------------------------
        nop                                     ; 8ECD EA       .
L8ECE:  jsr     LA933                           ; 8ECE 20 33 A9  3.
        .byte   "le density"                    ; 8ED1 6C 65 20 64 65 6E 73 69le densi
                                                ; 8ED9 74 79    ty
; ----------------------------------------------------------------------------
        nop                                     ; 8EDB EA       .
        lda     #$87                            ; 8EDC A9 87    ..
        jsr     LA9B1                           ; 8EDE 20 B1 A9  ..
        ldy     #$0E                            ; 8EE1 A0 0E    ..
        bit     $FDED                           ; 8EE3 2C ED FD ,..
        bvc     L8F0C                           ; 8EE6 50 24    P$
        ldy     #$05                            ; 8EE8 A0 05    ..
        jsr     L8A8E                           ; 8EEA 20 8E 8A  ..
        ldx     #$00                            ; 8EED A2 00    ..
L8EEF:  clc                                     ; 8EEF 18       .
        jsr     select_ram_page_000             ; 8EF0 20 23 BE  #.
        lda     $FDBC,x                         ; 8EF3 BD BC FD ...
        php                                     ; 8EF6 08       .
        txa                                     ; 8EF7 8A       .
        plp                                     ; 8EF8 28       (
        bne     L8EFD                           ; 8EF9 D0 02    ..
        lda     #$ED                            ; 8EFB A9 ED    ..
L8EFD:  adc     #$41                            ; 8EFD 69 41    iA
        jsr     LA9B1                           ; 8EFF 20 B1 A9  ..
        inx                                     ; 8F02 E8       .
        cpx     #$08                            ; 8F03 E0 08    ..
        bne     L8EEF                           ; 8F05 D0 E8    ..
        jsr     select_ram_page_001             ; 8F07 20 28 BE  (.
        ldy     #$01                            ; 8F0A A0 01    ..
L8F0C:  bit     $FDEA                           ; 8F0C 2C EA FD ,..
        bpl     L8F20                           ; 8F0F 10 0F    ..
        bvc     L8F20                           ; 8F11 50 0D    P.
        jsr     L8A8E                           ; 8F13 20 8E 8A  ..
        jsr     LA933                           ; 8F16 20 33 A9  3.
        .byte   "40in80"                        ; 8F19 34 30 69 6E 38 3040in80
; ----------------------------------------------------------------------------
        nop                                     ; 8F1F EA       .
L8F20:  jmp     L841A                           ; 8F20 4C 1A 84 L..

; ----------------------------------------------------------------------------
L8F23:  jsr     LA977                           ; 8F23 20 77 A9  w.
        .byte   $52                             ; 8F26 52       R
        eor     ($4D,x)                         ; 8F27 41 4D    AM
        jsr     L6944                           ; 8F29 20 44 69  Di
        .byte   $73                             ; 8F2C 73       s
        .byte   $6B                             ; 8F2D 6B       k
        .byte   $FF                             ; 8F2E FF       .
        jmp     L841A                           ; 8F2F 4C 1A 84 L..

; ----------------------------------------------------------------------------
L8F32:  ldy     #$0D                            ; 8F32 A0 0D    ..
        lda     $CF                             ; 8F34 A5 CF    ..
        jsr     L8E4D                           ; 8F36 20 4D 8E  M.
        jsr     L8A8E                           ; 8F39 20 8E 8A  ..
        jsr     select_ram_page_003             ; 8F3C 20 32 BE  2.
        jsr     LA933                           ; 8F3F 20 33 A9  3.
        .byte   "Option "                       ; 8F42 4F 70 74 69 6F 6E 20Option 
; ----------------------------------------------------------------------------
        lda     $FD06                           ; 8F49 AD 06 FD ...
        jsr     LA9FE                           ; 8F4C 20 FE A9  ..
        jsr     LA9E0                           ; 8F4F 20 E0 A9  ..
        jsr     LA933                           ; 8F52 20 33 A9  3.
        .byte   " ("                            ; 8F55 20 28     (
; ----------------------------------------------------------------------------
        tax                                     ; 8F57 AA       .
        jsr     L8FA1                           ; 8F58 20 A1 8F  ..
        jsr     LA933                           ; 8F5B 20 33 A9  3.
        .byte   ")"                             ; 8F5E 29       )
        .byte   $0D                             ; 8F5F 0D       .
; ----------------------------------------------------------------------------
        nop                                     ; 8F60 EA       .
        rts                                     ; 8F61 60       `

; ----------------------------------------------------------------------------
L8F62:  jsr     LA933                           ; 8F62 20 33 A9  3.
        .byte   " Directory :"                  ; 8F65 20 44 69 72 65 63 74 6F Directo
                                                ; 8F6D 72 79 20 3Ary :
; ----------------------------------------------------------------------------
        ldy     #$06                            ; 8F71 A0 06    ..
        jsr     select_ram_page_001             ; 8F73 20 28 BE  (.
        ldx     #$00                            ; 8F76 A2 00    ..
        jsr     L8F92                           ; 8F78 20 92 8F  ..
        jsr     L8A8E                           ; 8F7B 20 8E 8A  ..
        jsr     LA933                           ; 8F7E 20 33 A9  3.
        .byte   "Library :"                     ; 8F81 4C 69 62 72 61 72 79 20Library 
                                                ; 8F89 3A       :
; ----------------------------------------------------------------------------
        ldx     #$02                            ; 8F8A A2 02    ..
        jsr     L8F92                           ; 8F8C 20 92 8F  ..
        jmp     L841A                           ; 8F8F 4C 1A 84 L..

; ----------------------------------------------------------------------------
L8F92:  lda     $FDC7,x                         ; 8F92 BD C7 FD ...
        jsr     L8E48                           ; 8F95 20 48 8E  H.
        jsr     LA9AF                           ; 8F98 20 AF A9  ..
        lda     $FDC6,x                         ; 8F9B BD C6 FD ...
        jmp     LA9B1                           ; 8F9E 4C B1 A9 L..

; ----------------------------------------------------------------------------
L8FA1:  lda     L8FB1,x                         ; 8FA1 BD B1 8F ...
        tax                                     ; 8FA4 AA       .
L8FA5:  lda     L8FB8,x                         ; 8FA5 BD B8 8F ...
        beq     L8FB0                           ; 8FA8 F0 06    ..
        jsr     LA9B1                           ; 8FAA 20 B1 A9  ..
        inx                                     ; 8FAD E8       .
        bpl     L8FA5                           ; 8FAE 10 F5    ..
L8FB0:  rts                                     ; 8FB0 60       `

; ----------------------------------------------------------------------------
L8FB1:  brk                                     ; 8FB1 00       .
        .byte   $04                             ; 8FB2 04       .
        ora     #$0D                            ; 8FB3 09 0D    ..
        .byte   $12                             ; 8FB5 12       .
        .byte   $1B                             ; 8FB6 1B       .
        .byte   $20                             ; 8FB7 20        
L8FB8:  .byte   $6F                             ; 8FB8 6F       o
        ror     $66                             ; 8FB9 66 66    ff
        brk                                     ; 8FBB 00       .
        jmp     L414F                           ; 8FBC 4C 4F 41 LOA

; ----------------------------------------------------------------------------
        .byte   $44                             ; 8FBF 44       D
        brk                                     ; 8FC0 00       .
        .byte   $52                             ; 8FC1 52       R
        eor     $4E,x                           ; 8FC2 55 4E    UN
        brk                                     ; 8FC4 00       .
        eor     $58                             ; 8FC5 45 58    EX
        eor     $43                             ; 8FC7 45 43    EC
        brk                                     ; 8FC9 00       .
        adc     #$6E                            ; 8FCA 69 6E    in
        adc     ($63,x)                         ; 8FCC 61 63    ac
        .byte   $74                             ; 8FCE 74       t
        adc     #$76                            ; 8FCF 69 76    iv
        adc     $00                             ; 8FD1 65 00    e.
        .byte   $32                             ; 8FD3 32       2
        and     $36,x                           ; 8FD4 35 36    56
        .byte   $4B                             ; 8FD6 4B       K
        brk                                     ; 8FD7 00       .
        and     $31,x                           ; 8FD8 35 31    51
        .byte   $32                             ; 8FDA 32       2
        .byte   $4B                             ; 8FDB 4B       K
        brk                                     ; 8FDC 00       .
L8FDD:  ldy     #$03                            ; 8FDD A0 03    ..
        lda     $CF                             ; 8FDF A5 CF    ..
        jsr     L8E4D                           ; 8FE1 20 4D 8E  M.
        jsr     L8A8E                           ; 8FE4 20 8E 8A  ..
        jsr     LA933                           ; 8FE7 20 33 A9  3.
        .byte   "Volume size   "                ; 8FEA 56 6F 6C 75 6D 65 20 73Volume s
                                                ; 8FF2 69 7A 65 20 20 20ize   
; ----------------------------------------------------------------------------
        nop                                     ; 8FF8 EA       .
        jsr     select_ram_page_003             ; 8FF9 20 32 BE  2.
        lda     $FD07                           ; 8FFC AD 07 FD ...
        sta     L00A8                           ; 8FFF 85 A8    ..
        lda     $FD06                           ; 9001 AD 06 FD ...
        and     #$03                            ; 9004 29 03    ).
        sta     $A9                             ; 9006 85 A9    ..
        jsr     LB3D2                           ; 9008 20 D2 B3  ..
        jsr     L841A                           ; 900B 20 1A 84  ..
        ldy     #$0B                            ; 900E A0 0B    ..
        jsr     L8A8E                           ; 9010 20 8E 8A  ..
        jsr     LA933                           ; 9013 20 33 A9  3.
        .byte   "Volume unused "                ; 9016 56 6F 6C 75 6D 65 20 75Volume u
                                                ; 901E 6E 75 73 65 64 20nused 
; ----------------------------------------------------------------------------
        nop                                     ; 9024 EA       .
        jsr     select_ram_page_003             ; 9025 20 32 BE  2.
        ldy     $FD05                           ; 9028 AC 05 FD ...
        lda     #$00                            ; 902B A9 00    ..
        sta     $CB                             ; 902D 85 CB    ..
        jsr     LA55A                           ; 902F 20 5A A5  Z.
        sta     $CA                             ; 9032 85 CA    ..
L9034:  jsr     LAA12                           ; 9034 20 12 AA  ..
        cpy     #$F8                            ; 9037 C0 F8    ..
        beq     L9044                           ; 9039 F0 09    ..
        jsr     LA773                           ; 903B 20 73 A7  s.
        jsr     LA792                           ; 903E 20 92 A7  ..
        jmp     L9034                           ; 9041 4C 34 90 L4.

; ----------------------------------------------------------------------------
L9044:  jsr     select_ram_page_003             ; 9044 20 32 BE  2.
        sec                                     ; 9047 38       8
        lda     $FD07                           ; 9048 AD 07 FD ...
        sbc     $CA                             ; 904B E5 CA    ..
        sta     L00A8                           ; 904D 85 A8    ..
        lda     $FD06                           ; 904F AD 06 FD ...
        and     #$03                            ; 9052 29 03    ).
        sbc     $CB                             ; 9054 E5 CB    ..
        sta     $A9                             ; 9056 85 A9    ..
        jsr     LB3D2                           ; 9058 20 D2 B3  ..
        jmp     L841A                           ; 905B 4C 1A 84 L..

; ----------------------------------------------------------------------------
        .byte   "ACCESS"                        ; 905E 41 43 43 45 53 53ACCESS
; ----------------------------------------------------------------------------
        .dbyt   $93E1                           ; 9064 93 E1    ..
; ----------------------------------------------------------------------------
        .byte   $32                             ; 9066 32       2
; ----------------------------------------------------------------------------
        .byte   "BACKUP"                        ; 9067 42 41 43 4B 55 50BACKUP
; ----------------------------------------------------------------------------
        .dbyt   $851A                           ; 906D 85 1A    ..
; ----------------------------------------------------------------------------
        .byte   $54                             ; 906F 54       T
; ----------------------------------------------------------------------------
        .byte   "COMPACT"                       ; 9070 43 4F 4D 50 41 43 54COMPACT
; ----------------------------------------------------------------------------
        .dbyt   $A695                           ; 9077 A6 95    ..
; ----------------------------------------------------------------------------
        .byte   $0A                             ; 9079 0A       .
; ----------------------------------------------------------------------------
        .byte   "CONFIG"                        ; 907A 43 4F 4E 46 49 47CONFIG
; ----------------------------------------------------------------------------
        .dbyt   $AB56                           ; 9080 AB 56    .V
; ----------------------------------------------------------------------------
        .byte   $0A                             ; 9082 0A       .
; ----------------------------------------------------------------------------
        .byte   "COPY"                          ; 9083 43 4F 50 59COPY
; ----------------------------------------------------------------------------
        .dbyt   $8616                           ; 9087 86 16    ..
; ----------------------------------------------------------------------------
        .byte   $64                             ; 9089 64       d
; ----------------------------------------------------------------------------
        .byte   "DELETE"                        ; 908A 44 45 4C 45 54 45DELETE
; ----------------------------------------------------------------------------
        .dbyt   $9229                           ; 9090 92 29    .)
; ----------------------------------------------------------------------------
        .byte   $01                             ; 9092 01       .
; ----------------------------------------------------------------------------
        .byte   "DESTROY"                       ; 9093 44 45 53 54 52 4F 59DESTROY
; ----------------------------------------------------------------------------
        .dbyt   $9238                           ; 909A 92 38    .8
; ----------------------------------------------------------------------------
        .byte   $02                             ; 909C 02       .
; ----------------------------------------------------------------------------
        .byte   "DIR"                           ; 909D 44 49 52 DIR
; ----------------------------------------------------------------------------
        .dbyt   $92C8                           ; 90A0 92 C8    ..
; ----------------------------------------------------------------------------
        .byte   $09                             ; 90A2 09       .
; ----------------------------------------------------------------------------
        .byte   "DRIVE"                         ; 90A3 44 52 49 56 45DRIVE
; ----------------------------------------------------------------------------
        .dbyt   $92BF                           ; 90A8 92 BF    ..
; ----------------------------------------------------------------------------
        .byte   $0A                             ; 90AA 0A       .
; ----------------------------------------------------------------------------
        .byte   "ENABLE"                        ; 90AB 45 4E 41 42 4C 45ENABLE
; ----------------------------------------------------------------------------
        .dbyt   $95CF                           ; 90B1 95 CF    ..
; ----------------------------------------------------------------------------
        .byte   $00                             ; 90B3 00       .
; ----------------------------------------------------------------------------
        .byte   "FDCSTAT"                       ; 90B4 46 44 43 53 54 41 54FDCSTAT
; ----------------------------------------------------------------------------
        .dbyt   $B7CC                           ; 90BB B7 CC    ..
; ----------------------------------------------------------------------------
        .byte   $80                             ; 90BD 80       .
; ----------------------------------------------------------------------------
        .byte   "INFO"                          ; 90BE 49 4E 46 4FINFO
; ----------------------------------------------------------------------------
        .dbyt   $8BBC                           ; 90C2 8B BC    ..
; ----------------------------------------------------------------------------
        .byte   $02                             ; 90C4 02       .
; ----------------------------------------------------------------------------
        .byte   "LIB"                           ; 90C5 4C 49 42 LIB
; ----------------------------------------------------------------------------
        .dbyt   $92CB                           ; 90C8 92 CB    ..
; ----------------------------------------------------------------------------
        .byte   $09                             ; 90CA 09       .
; ----------------------------------------------------------------------------
        .byte   "MAP"                           ; 90CB 4D 41 50 MAP
; ----------------------------------------------------------------------------
        .dbyt   $8B05                           ; 90CE 8B 05    ..
; ----------------------------------------------------------------------------
        .byte   $0A                             ; 90D0 0A       .
; ----------------------------------------------------------------------------
        .byte   "RENAME"                        ; 90D1 52 45 4E 41 4D 45RENAME
; ----------------------------------------------------------------------------
        .dbyt   $9632                           ; 90D7 96 32    .2
; ----------------------------------------------------------------------------
        .byte   $78                             ; 90D9 78       x
; ----------------------------------------------------------------------------
        .byte   "STAT"                          ; 90DA 53 54 41 54STAT
; ----------------------------------------------------------------------------
        .dbyt   $8D06                           ; 90DE 8D 06    ..
; ----------------------------------------------------------------------------
        .byte   $0A                             ; 90E0 0A       .
; ----------------------------------------------------------------------------
        .byte   "TAPEDISK"                      ; 90E1 54 41 50 45 44 49 53 4BTAPEDISK
; ----------------------------------------------------------------------------
        .dbyt   $92EE                           ; 90E9 92 EE    ..
; ----------------------------------------------------------------------------
        .byte   $81                             ; 90EB 81       .
; ----------------------------------------------------------------------------
        .byte   "TITLE"                         ; 90EC 54 49 54 4C 45TITLE
; ----------------------------------------------------------------------------
        .dbyt   $93AC                           ; 90F1 93 AC    ..
; ----------------------------------------------------------------------------
        .byte   $0B                             ; 90F3 0B       .
; ----------------------------------------------------------------------------
        .byte   "WIPE"                          ; 90F4 57 49 50 45WIPE
; ----------------------------------------------------------------------------
        .dbyt   $91F4                           ; 90F8 91 F4    ..
; ----------------------------------------------------------------------------
        .byte   $02                             ; 90FA 02       .
; ----------------------------------------------------------------------------
        .dbyt   $988B                           ; 90FB 98 8B    ..
; ----------------------------------------------------------------------------
        .byte   "BUILD"                         ; 90FD 42 55 49 4C 44BUILD
; ----------------------------------------------------------------------------
        .dbyt   $83C6                           ; 9102 83 C6    ..
; ----------------------------------------------------------------------------
        .byte   $01                             ; 9104 01       .
; ----------------------------------------------------------------------------
        .byte   "DISC"                          ; 9105 44 49 53 43DISC
; ----------------------------------------------------------------------------
        .dbyt   $81DE                           ; 9109 81 DE    ..
; ----------------------------------------------------------------------------
        .byte   $00                             ; 910B 00       .
; ----------------------------------------------------------------------------
        .byte   "DUMP"                          ; 910C 44 55 4D 50DUMP
; ----------------------------------------------------------------------------
        .dbyt   $8355                           ; 9110 83 55    .U
; ----------------------------------------------------------------------------
        .byte   $01                             ; 9112 01       .
; ----------------------------------------------------------------------------
        .byte   "FORMAT"                        ; 9113 46 4F 52 4D 41 54FORMAT
; ----------------------------------------------------------------------------
        .dbyt   $AECD                           ; 9119 AE CD    ..
; ----------------------------------------------------------------------------
        .byte   $8A                             ; 911B 8A       .
; ----------------------------------------------------------------------------
        .byte   "LIST"                          ; 911C 4C 49 53 54LIST
; ----------------------------------------------------------------------------
        .dbyt   $8313                           ; 9120 83 13    ..
; ----------------------------------------------------------------------------
        .byte   $01                             ; 9122 01       .
; ----------------------------------------------------------------------------
        .byte   "TYPE"                          ; 9123 54 59 50 45TYPE
; ----------------------------------------------------------------------------
        .dbyt   $830C                           ; 9127 83 0C    ..
; ----------------------------------------------------------------------------
        .byte   $01                             ; 9129 01       .
; ----------------------------------------------------------------------------
        .byte   "VERIFY"                        ; 912A 56 45 52 49 46 59VERIFY
; ----------------------------------------------------------------------------
        .dbyt   $B0C0                           ; 9130 B0 C0    ..
; ----------------------------------------------------------------------------
        .byte   $8A                             ; 9132 8A       .
; ----------------------------------------------------------------------------
        .byte   "VOLGEN"                        ; 9133 56 4F 4C 47 45 4EVOLGEN
; ----------------------------------------------------------------------------
        .dbyt   $B188                           ; 9139 B1 88    ..
; ----------------------------------------------------------------------------
        .byte   $8A                             ; 913B 8A       .
; ----------------------------------------------------------------------------
        .byte   "DISK"                          ; 913C 44 49 53 4BDISK
; ----------------------------------------------------------------------------
        .dbyt   $81DE                           ; 9140 81 DE    ..
; ----------------------------------------------------------------------------
        .byte   $00                             ; 9142 00       .
; ----------------------------------------------------------------------------
        .dbyt   $915C                           ; 9143 91 5C    .\
; ----------------------------------------------------------------------------
        .byte   "CHAL"                          ; 9145 43 48 41 4CCHAL
; ----------------------------------------------------------------------------
        .dbyt   $A590                           ; 9149 A5 90    ..
; ----------------------------------------------------------------------------
        .byte   $00                             ; 914B 00       .
; ----------------------------------------------------------------------------
        .byte   "DFS"                           ; 914C 44 46 53 DFS
; ----------------------------------------------------------------------------
        .dbyt   $A590                           ; 914F A5 90    ..
; ----------------------------------------------------------------------------
        .byte   $00                             ; 9151 00       .
; ----------------------------------------------------------------------------
        .byte   "UTILS"                         ; 9152 55 54 49 4C 53UTILS
; ----------------------------------------------------------------------------
        .dbyt   $A588                           ; 9157 A5 88    ..
; ----------------------------------------------------------------------------
        .byte   $00                             ; 9159 00       .
; ----------------------------------------------------------------------------
        .dbyt   $915C                           ; 915A 91 5C    .\
; ----------------------------------------------------------------------------
        rts                                     ; 915C 60       `

; ----------------------------------------------------------------------------
L915D:  jsr     L91D3                           ; 915D 20 D3 91  ..
        tay                                     ; 9160 A8       .
        jsr     LAA52                           ; 9161 20 52 AA  R.
        tya                                     ; 9164 98       .
        pha                                     ; 9165 48       H
        lda     ($F2),y                         ; 9166 B1 F2    ..
        and     #$5F                            ; 9168 29 5F    )_
        cmp     #$43                            ; 916A C9 43    .C
        bne     L9179                           ; 916C D0 0B    ..
        iny                                     ; 916E C8       .
        lda     ($F2),y                         ; 916F B1 F2    ..
        cmp     #$20                            ; 9171 C9 20    . 
        bne     L9179                           ; 9173 D0 04    ..
        pla                                     ; 9175 68       h
        iny                                     ; 9176 C8       .
        tya                                     ; 9177 98       .
        pha                                     ; 9178 48       H
L9179:  pla                                     ; 9179 68       h
        tay                                     ; 917A A8       .
        pha                                     ; 917B 48       H
        ldx     #$00                            ; 917C A2 00    ..
        jsr     L00AA                           ; 917E 20 AA 00  ..
        sec                                     ; 9181 38       8
        bmi     L91BF                           ; 9182 30 3B    0;
        dex                                     ; 9184 CA       .
        dey                                     ; 9185 88       .
L9186:  inx                                     ; 9186 E8       .
        iny                                     ; 9187 C8       .
        jsr     L00AA                           ; 9188 20 AA 00  ..
        bmi     L91AF                           ; 918B 30 22    0"
        eor     ($F2),y                         ; 918D 51 F2    Q.
        and     #$5F                            ; 918F 29 5F    )_
        beq     L9186                           ; 9191 F0 F3    ..
        lda     ($F2),y                         ; 9193 B1 F2    ..
        cmp     #$2E                            ; 9195 C9 2E    ..
        php                                     ; 9197 08       .
L9198:  inx                                     ; 9198 E8       .
        jsr     L00AA                           ; 9199 20 AA 00  ..
        bpl     L9198                           ; 919C 10 FA    ..
        inx                                     ; 919E E8       .
        inx                                     ; 919F E8       .
        plp                                     ; 91A0 28       (
        bne     L91A8                           ; 91A1 D0 05    ..
        jsr     L00AA                           ; 91A3 20 AA 00  ..
        bpl     L91BB                           ; 91A6 10 13    ..
L91A8:  inx                                     ; 91A8 E8       .
        jsr     L91E2                           ; 91A9 20 E2 91  ..
        jmp     L9179                           ; 91AC 4C 79 91 Ly.

; ----------------------------------------------------------------------------
L91AF:  lda     ($F2),y                         ; 91AF B1 F2    ..
        jsr     LAA31                           ; 91B1 20 31 AA  1.
        bcs     L91BE                           ; 91B4 B0 08    ..
        inx                                     ; 91B6 E8       .
        inx                                     ; 91B7 E8       .
        jmp     L91A8                           ; 91B8 4C A8 91 L..

; ----------------------------------------------------------------------------
L91BB:  dex                                     ; 91BB CA       .
        dex                                     ; 91BC CA       .
        iny                                     ; 91BD C8       .
L91BE:  clc                                     ; 91BE 18       .
L91BF:  pla                                     ; 91BF 68       h
        jsr     L00AA                           ; 91C0 20 AA 00  ..
        sta     $A9                             ; 91C3 85 A9    ..
        inx                                     ; 91C5 E8       .
        jsr     L00AA                           ; 91C6 20 AA 00  ..
        sta     L00A8                           ; 91C9 85 A8    ..
        inx                                     ; 91CB E8       .
        rts                                     ; 91CC 60       `

; ----------------------------------------------------------------------------
        pha                                     ; 91CD 48       H
        lda     #$9D                            ; 91CE A9 9D    ..
        jmp     L91D6                           ; 91D0 4C D6 91 L..

; ----------------------------------------------------------------------------
L91D3:  pha                                     ; 91D3 48       H
        lda     #$BD                            ; 91D4 A9 BD    ..
L91D6:  sta     L00AA                           ; 91D6 85 AA    ..
        stx     $AB                             ; 91D8 86 AB    ..
        sty     $AC                             ; 91DA 84 AC    ..
        lda     #$60                            ; 91DC A9 60    .`
        sta     $AD                             ; 91DE 85 AD    ..
        pla                                     ; 91E0 68       h
        rts                                     ; 91E1 60       `

; ----------------------------------------------------------------------------
L91E2:  clc                                     ; 91E2 18       .
        txa                                     ; 91E3 8A       .
        adc     $AB                             ; 91E4 65 AB    e.
        sta     $AB                             ; 91E6 85 AB    ..
        bcc     L91EC                           ; 91E8 90 02    ..
        inc     $AC                             ; 91EA E6 AC    ..
L91EC:  rts                                     ; 91EC 60       `

; ----------------------------------------------------------------------------
L91ED:  stx     $F2                             ; 91ED 86 F2    ..
        sty     $F3                             ; 91EF 84 F3    ..
        ldy     #$00                            ; 91F1 A0 00    ..
        rts                                     ; 91F3 60       `

; ----------------------------------------------------------------------------
wipe_command:
        jsr     L9292                           ; 91F4 20 92 92  ..
L91F7:  jsr     L8A54                           ; 91F7 20 54 8A  T.
        jsr     LA933                           ; 91FA 20 33 A9  3.
        .byte   " : "                           ; 91FD 20 3A 20  : 
; ----------------------------------------------------------------------------
        nop                                     ; 9200 EA       .
        jsr     select_ram_page_002             ; 9201 20 2D BE  -.
        lda     $FD0F,y                         ; 9204 B9 0F FD ...
        bpl     L920F                           ; 9207 10 06    ..
        jsr     LA9AB                           ; 9209 20 AB A9  ..
        jmp     L9220                           ; 920C 4C 20 92 L .

; ----------------------------------------------------------------------------
L920F:  jsr     L848F                           ; 920F 20 8F 84  ..
        bne     L9220                           ; 9212 D0 0C    ..
        jsr     L8A2F                           ; 9214 20 2F 8A  /.
        jsr     L8C18                           ; 9217 20 18 8C  ..
        jsr     L9677                           ; 921A 20 77 96  w.
        jsr     L92B5                           ; 921D 20 B5 92  ..
L9220:  jsr     L841A                           ; 9220 20 1A 84  ..
        jsr     L8BD5                           ; 9223 20 D5 8B  ..
        bcs     L91F7                           ; 9226 B0 CF    ..
        rts                                     ; 9228 60       `

; ----------------------------------------------------------------------------
delete_command:
        jsr     L8AE3                           ; 9229 20 E3 8A  ..
        jsr     L9295                           ; 922C 20 95 92  ..
        jsr     L8C3D                           ; 922F 20 3D 8C  =.
        jsr     L8C18                           ; 9232 20 18 8C  ..
        jmp     L9677                           ; 9235 4C 77 96 Lw.

; ----------------------------------------------------------------------------
destroy_command:
        jsr     LA7BE                           ; 9238 20 BE A7  ..
        jsr     L9292                           ; 923B 20 92 92  ..
L923E:  jsr     L8A54                           ; 923E 20 54 8A  T.
        jsr     L841A                           ; 9241 20 1A 84  ..
        jsr     L8BD5                           ; 9244 20 D5 8B  ..
        bcs     L923E                           ; 9247 B0 F5    ..
        jsr     LA933                           ; 9249 20 33 A9  3.
        .byte   $0D                             ; 924C 0D       .
        .byte   "Delete (Y/N) ? "               ; 924D 44 65 6C 65 74 65 20 28Delete (
                                                ; 9255 59 2F 4E 29 20 3F 20Y/N) ? 
; ----------------------------------------------------------------------------
        nop                                     ; 925C EA       .
        jsr     L848F                           ; 925D 20 8F 84  ..
        beq     L9265                           ; 9260 F0 03    ..
        jmp     L841A                           ; 9262 4C 1A 84 L..

; ----------------------------------------------------------------------------
L9265:  jsr     L8A2F                           ; 9265 20 2F 8A  /.
        jsr     L8BCE                           ; 9268 20 CE 8B  ..
L926B:  jsr     select_ram_page_002             ; 926B 20 2D BE  -.
        lda     $FD0F,y                         ; 926E B9 0F FD ...
        and     #$7F                            ; 9271 29 7F    ).
        sta     $FD0F,y                         ; 9273 99 0F FD ...
        jsr     L8C18                           ; 9276 20 18 8C  ..
        jsr     L92B5                           ; 9279 20 B5 92  ..
        jsr     L8BD5                           ; 927C 20 D5 8B  ..
        bcs     L926B                           ; 927F B0 EA    ..
        jsr     L9677                           ; 9281 20 77 96  w.
        jsr     LA933                           ; 9284 20 33 A9  3.
        .byte   $0D                             ; 9287 0D       .
        .byte   "Deleted"                       ; 9288 44 65 6C 65 74 65 64Deleted
        .byte   $0D                             ; 928F 0D       .
; ----------------------------------------------------------------------------
        nop                                     ; 9290 EA       .
        rts                                     ; 9291 60       `

; ----------------------------------------------------------------------------
L9292:  jsr     L8ADF                           ; 9292 20 DF 8A  ..
L9295:  jsr     LA5C4                           ; 9295 20 C4 A5  ..
        jmp     L8AE9                           ; 9298 4C E9 8A L..

; ----------------------------------------------------------------------------
L929B:  jsr     LA5C4                           ; 929B 20 C4 A5  ..
        jmp     L898D                           ; 929E 4C 8D 89 L..

; ----------------------------------------------------------------------------
L92A1:  jsr     LAA04                           ; 92A1 20 04 AA  ..
        jsr     select_ram_page_003             ; 92A4 20 32 BE  2.
        eor     $FD0E,x                         ; 92A7 5D 0E FD ]..
        and     #$30                            ; 92AA 29 30    )0
        eor     $FD0E,x                         ; 92AC 5D 0E FD ]..
        sta     $FD0E,x                         ; 92AF 9D 0E FD ...
        jmp     select_ram_page_001             ; 92B2 4C 28 BE L(.

; ----------------------------------------------------------------------------
L92B5:  ldy     $FDC2                           ; 92B5 AC C2 FD ...
        jsr     LAA12                           ; 92B8 20 12 AA  ..
        sty     $FDC2                           ; 92BB 8C C2 FD ...
        rts                                     ; 92BE 60       `

; ----------------------------------------------------------------------------
drive_command:
        jsr     LAA76                           ; 92BF 20 76 AA  v.
        lda     $CF                             ; 92C2 A5 CF    ..
        sta     $FDC7                           ; 92C4 8D C7 FD ...
        rts                                     ; 92C7 60       `

; ----------------------------------------------------------------------------
dir_command:
        ldx     #$00                            ; 92C8 A2 00    ..
        .byte   $AD                             ; 92CA AD       .
lib_command:
        ldx     #$02                            ; 92CB A2 02    ..
        lda     $FDC6,x                         ; 92CD BD C6 FD ...
        sta     $CE                             ; 92D0 85 CE    ..
        lda     $FDC7,x                         ; 92D2 BD C7 FD ...
        sta     $CF                             ; 92D5 85 CF    ..
        txa                                     ; 92D7 8A       .
        pha                                     ; 92D8 48       H
        jsr     LAA52                           ; 92D9 20 52 AA  R.
        beq     L92E1                           ; 92DC F0 03    ..
        jsr     LAA9E                           ; 92DE 20 9E AA  ..
L92E1:  pla                                     ; 92E1 68       h
        tax                                     ; 92E2 AA       .
        lda     $CE                             ; 92E3 A5 CE    ..
        sta     $FDC6,x                         ; 92E5 9D C6 FD ...
        lda     $CF                             ; 92E8 A5 CF    ..
        sta     $FDC7,x                         ; 92EA 9D C7 FD ...
        rts                                     ; 92ED 60       `

; ----------------------------------------------------------------------------
tapedisk_command:
        jsr     LA88D                           ; 92EE 20 8D A8  ..
        stx     $02EE                           ; 92F1 8E EE 02 ...
        sty     $02EF                           ; 92F4 8C EF 02 ...
        jsr     LA56C                           ; 92F7 20 6C A5  l.
        lda     $FDD5                           ; 92FA AD D5 FD ...
        sta     $02F1                           ; 92FD 8D F1 02 ...
        lda     #$00                            ; 9300 A9 00    ..
        sta     $02F0                           ; 9302 8D F0 02 ...
        jsr     L938B                           ; 9305 20 8B 93  ..
        ldx     #$0C                            ; 9308 A2 0C    ..
        lda     #$8C                            ; 930A A9 8C    ..
        jsr     osbyte                          ; 930C 20 F4 FF  ..
        lda     #$FF                            ; 930F A9 FF    ..
        jsr     L9384                           ; 9311 20 84 93  ..
        ldx     #$98                            ; 9314 A2 98    ..
        ldy     #$93                            ; 9316 A0 93    ..
        jsr     oscli                           ; 9318 20 F7 FF  ..
        lda     #$B2                            ; 931B A9 B2    ..
        sta     $02EE                           ; 931D 8D EE 02 ...
        lda     #$03                            ; 9320 A9 03    ..
        sta     $02EF                           ; 9322 8D EF 02 ...
        ldx     #$00                            ; 9325 A2 00    ..
L9327:  lda     $03B2,x                         ; 9327 BD B2 03 ...
        beq     L9331                           ; 932A F0 05    ..
        inx                                     ; 932C E8       .
        cpx     #$07                            ; 932D E0 07    ..
        bne     L9327                           ; 932F D0 F6    ..
L9331:  lda     #$0D                            ; 9331 A9 0D    ..
        sta     $03B2,x                         ; 9333 9D B2 03 ...
        jsr     L939D                           ; 9336 20 9D 93  ..
        lda     $B0                             ; 9339 A5 B0    ..
        beq     L933F                           ; 933B F0 02    ..
        inc     $B1                             ; 933D E6 B1    ..
L933F:  lda     $FDD7                           ; 933F AD D7 FD ...
        cmp     $B1                             ; 9342 C5 B1    ..
        bcs     L9359                           ; 9344 B0 13    ..
        jsr     LA905                           ; 9346 20 05 A9  ..
        .byte   $D4                             ; 9349 D4       .
        .byte   "size too large"                ; 934A 73 69 7A 65 20 74 6F 6Fsize too
                                                ; 9352 20 6C 61 72 67 65 large
        .byte   $00                             ; 9358 00       .
; ----------------------------------------------------------------------------
L9359:  jsr     L939D                           ; 9359 20 9D 93  ..
        lda     #$00                            ; 935C A9 00    ..
        sta     $02F8                           ; 935E 8D F8 02 ...
        lda     $FDD5                           ; 9361 AD D5 FD ...
        sta     $02F9                           ; 9364 8D F9 02 ...
        clc                                     ; 9367 18       .
        adc     $B1                             ; 9368 65 B1    e.
        sta     $02FD                           ; 936A 8D FD 02 ...
        lda     $B0                             ; 936D A5 B0    ..
        sta     $02FC                           ; 936F 8D FC 02 ...
        lda     #$00                            ; 9372 A9 00    ..
        jsr     L9384                           ; 9374 20 84 93  ..
        ldx     #$07                            ; 9377 A2 07    ..
L9379:  lda     $03BE,x                         ; 9379 BD BE 03 ...
        sta     $02F0,x                         ; 937C 9D F0 02 ...
        dex                                     ; 937F CA       .
        bpl     L9379                           ; 9380 10 F7    ..
        lda     #$01                            ; 9382 A9 01    ..
L9384:  ldx     #$EE                            ; 9384 A2 EE    ..
        ldy     #$02                            ; 9386 A0 02    ..
        jmp     osfile                          ; 9388 4C DD FF L..

; ----------------------------------------------------------------------------
L938B:  ldx     #$04                            ; 938B A2 04    ..
        lda     #$00                            ; 938D A9 00    ..
L938F:  sta     $02EE,x                         ; 938F 9D EE 02 ...
        inx                                     ; 9392 E8       .
        cpx     #$11                            ; 9393 E0 11    ..
        bcc     L938F                           ; 9395 90 F8    ..
        rts                                     ; 9397 60       `

; ----------------------------------------------------------------------------
        .byte   $44                             ; 9398 44       D
        eor     #$53                            ; 9399 49 53    IS
        .byte   $43                             ; 939B 43       C
        .byte   $0D                             ; 939C 0D       .
L939D:  lda     $03C8                           ; 939D AD C8 03 ...
        sta     $B0                             ; 93A0 85 B0    ..
        clc                                     ; 93A2 18       .
        lda     $03C6                           ; 93A3 AD C6 03 ...
        adc     $03C9                           ; 93A6 6D C9 03 m..
        sta     $B1                             ; 93A9 85 B1    ..
        rts                                     ; 93AB 60       `

; ----------------------------------------------------------------------------
title_command:
        jsr     LA5C4                           ; 93AC 20 C4 A5  ..
        jsr     LAA7E                           ; 93AF 20 7E AA  ~.
        jsr     L969B                           ; 93B2 20 9B 96  ..
        ldx     #$0C                            ; 93B5 A2 0C    ..
        lda     #$00                            ; 93B7 A9 00    ..
L93B9:  jsr     L93CF                           ; 93B9 20 CF 93  ..
        dex                                     ; 93BC CA       .
        bne     L93B9                           ; 93BD D0 FA    ..
L93BF:  jsr     gsread                          ; 93BF 20 C5 FF  ..
        bcs     L93CC                           ; 93C2 B0 08    ..
        jsr     L93CF                           ; 93C4 20 CF 93  ..
        inx                                     ; 93C7 E8       .
        cpx     #$0C                            ; 93C8 E0 0C    ..
        bne     L93BF                           ; 93CA D0 F3    ..
L93CC:  jmp     L9677                           ; 93CC 4C 77 96 Lw.

; ----------------------------------------------------------------------------
L93CF:  cpx     #$08                            ; 93CF E0 08    ..
        bcc     L93DA                           ; 93D1 90 07    ..
        jsr     select_ram_page_003             ; 93D3 20 32 BE  2.
        sta     fdc_status_or_cmd,x             ; 93D6 9D F8 FC ...
        rts                                     ; 93D9 60       `

; ----------------------------------------------------------------------------
L93DA:  jsr     select_ram_page_002             ; 93DA 20 2D BE  -.
        sta     $FD00,x                         ; 93DD 9D 00 FD ...
        rts                                     ; 93E0 60       `

; ----------------------------------------------------------------------------
access_command:
        jsr     L8ADF                           ; 93E1 20 DF 8A  ..
        jsr     L929B                           ; 93E4 20 9B 92  ..
        ldx     #$00                            ; 93E7 A2 00    ..
        jsr     LAA52                           ; 93E9 20 52 AA  R.
        bne     L940F                           ; 93EC D0 21    .!
L93EE:  stx     L00AA                           ; 93EE 86 AA    ..
        jsr     L8AF2                           ; 93F0 20 F2 8A  ..
L93F3:  jsr     LA30D                           ; 93F3 20 0D A3  ..
        jsr     select_ram_page_002             ; 93F6 20 2D BE  -.
        lda     $FD0F,y                         ; 93F9 B9 0F FD ...
        and     #$7F                            ; 93FC 29 7F    ).
        ora     L00AA                           ; 93FE 05 AA    ..
        sta     $FD0F,y                         ; 9400 99 0F FD ...
        jsr     L8C3D                           ; 9403 20 3D 8C  =.
        jsr     L8BD5                           ; 9406 20 D5 8B  ..
        bcs     L93F3                           ; 9409 B0 E8    ..
        bcc     L93CC                           ; 940B 90 BF    ..
L940D:  ldx     #$80                            ; 940D A2 80    ..
L940F:  jsr     gsread                          ; 940F 20 C5 FF  ..
        bcs     L93EE                           ; 9412 B0 DA    ..
        cmp     #$4C                            ; 9414 C9 4C    .L
        beq     L940D                           ; 9416 F0 F5    ..
        jsr     LA8FC                           ; 9418 20 FC A8  ..
        .byte   $CF                             ; 941B CF       .
        adc     ($74,x)                         ; 941C 61 74    at
        .byte   $74                             ; 941E 74       t
        .byte   $72                             ; 941F 72       r
        adc     #$62                            ; 9420 69 62    ib
        adc     $74,x                           ; 9422 75 74    ut
        adc     $00                             ; 9424 65 00    e.
L9426:  jsr     L8993                           ; 9426 20 93 89  ..
        jsr     L8BCE                           ; 9429 20 CE 8B  ..
        bcc     L9431                           ; 942C 90 03    ..
        jsr     L8C18                           ; 942E 20 18 8C  ..
L9431:  lda     $C2                             ; 9431 A5 C2    ..
        pha                                     ; 9433 48       H
        lda     $C3                             ; 9434 A5 C3    ..
        pha                                     ; 9436 48       H
        sec                                     ; 9437 38       8
        lda     $C4                             ; 9438 A5 C4    ..
        sbc     $C2                             ; 943A E5 C2    ..
        sta     $C2                             ; 943C 85 C2    ..
        lda     $C5                             ; 943E A5 C5    ..
        sbc     $C3                             ; 9440 E5 C3    ..
        sta     $C3                             ; 9442 85 C3    ..
        lda     $FDBB                           ; 9444 AD BB FD ...
        sbc     $FDB9                           ; 9447 ED B9 FD ...
        sta     $C6                             ; 944A 85 C6    ..
        jsr     L947E                           ; 944C 20 7E 94  ~.
        lda     $FDBA                           ; 944F AD BA FD ...
        sta     $FDB6                           ; 9452 8D B6 FD ...
        lda     $FDB9                           ; 9455 AD B9 FD ...
        sta     $FDB5                           ; 9458 8D B5 FD ...
        pla                                     ; 945B 68       h
        sta     $BF                             ; 945C 85 BF    ..
        pla                                     ; 945E 68       h
        sta     $BE                             ; 945F 85 BE    ..
        rts                                     ; 9461 60       `

; ----------------------------------------------------------------------------
L9462:  jsr     LA8F2                           ; 9462 20 F2 A8  ..
        .byte   $C6                             ; 9465 C6       .
        .byte   "full"                          ; 9466 66 75 6C 6Cfull
        .byte   $00                             ; 946A 00       .
; ----------------------------------------------------------------------------
L946B:  jsr     LA90D                           ; 946B 20 0D A9  ..
        .byte   $BE                             ; 946E BE       .
        .byte   "Catalogue full"                ; 946F 43 61 74 61 6C 6F 67 75Catalogu
                                                ; 9477 65 20 66 75 6C 6Ce full
        .byte   $00                             ; 947D 00       .
; ----------------------------------------------------------------------------
L947E:  lda     #$00                            ; 947E A9 00    ..
        sta     $C4                             ; 9480 85 C4    ..
        jsr     LA55A                           ; 9482 20 5A A5  Z.
        sta     $C5                             ; 9485 85 C5    ..
        jsr     select_ram_page_003             ; 9487 20 32 BE  2.
        ldy     $FD05                           ; 948A AC 05 FD ...
        cpy     #$F8                            ; 948D C0 F8    ..
        bcs     L946B                           ; 948F B0 DA    ..
        bcc     L94F2                           ; 9491 90 5F    ._
L9493:  bit     L00A8                           ; 9493 24 A8    $.
        bvc     L9462                           ; 9495 50 CB    P.
        lda     #$00                            ; 9497 A9 00    ..
        sta     $C3                             ; 9499 85 C3    ..
        sta     $C6                             ; 949B 85 C6    ..
        sta     $C4                             ; 949D 85 C4    ..
        jsr     LA55A                           ; 949F 20 5A A5  Z.
        sta     $C5                             ; 94A2 85 C5    ..
        jsr     select_ram_page_003             ; 94A4 20 32 BE  2.
        ldy     $FD05                           ; 94A7 AC 05 FD ...
        jmp     L94B6                           ; 94AA 4C B6 94 L..

; ----------------------------------------------------------------------------
L94AD:  tya                                     ; 94AD 98       .
        beq     L94D3                           ; 94AE F0 23    .#
        jsr     LAA12                           ; 94B0 20 12 AA  ..
        jsr     L9549                           ; 94B3 20 49 95  I.
L94B6:  jsr     L957A                           ; 94B6 20 7A 95  z.
        beq     L94AD                           ; 94B9 F0 F2    ..
        sec                                     ; 94BB 38       8
        jsr     L9594                           ; 94BC 20 94 95  ..
        bcc     L94AD                           ; 94BF 90 EC    ..
        stx     $C6                             ; 94C1 86 C6    ..
        lda     $B0                             ; 94C3 A5 B0    ..
        sta     $C3                             ; 94C5 85 C3    ..
        lda     $C4                             ; 94C7 A5 C4    ..
        sta     $B1                             ; 94C9 85 B1    ..
        lda     $C5                             ; 94CB A5 C5    ..
        sta     $B2                             ; 94CD 85 B2    ..
        sty     $C2                             ; 94CF 84 C2    ..
        bcs     L94AD                           ; 94D1 B0 DA    ..
L94D3:  lda     $C3                             ; 94D3 A5 C3    ..
        ora     $C6                             ; 94D5 05 C6    ..
        beq     L9462                           ; 94D7 F0 89    ..
        lda     $B1                             ; 94D9 A5 B1    ..
        sta     $C4                             ; 94DB 85 C4    ..
        lda     $B2                             ; 94DD A5 B2    ..
        sta     $C5                             ; 94DF 85 C5    ..
        ldy     $C2                             ; 94E1 A4 C2    ..
        lda     #$00                            ; 94E3 A9 00    ..
        sta     $C2                             ; 94E5 85 C2    ..
        beq     L94FC                           ; 94E7 F0 13    ..
L94E9:  tya                                     ; 94E9 98       .
        beq     L9493                           ; 94EA F0 A7    ..
        jsr     LAA12                           ; 94EC 20 12 AA  ..
        jsr     L9549                           ; 94EF 20 49 95  I.
L94F2:  jsr     L957A                           ; 94F2 20 7A 95  z.
        beq     L94E9                           ; 94F5 F0 F2    ..
        jsr     L9590                           ; 94F7 20 90 95  ..
        bcc     L94E9                           ; 94FA 90 ED    ..
L94FC:  sty     $B0                             ; 94FC 84 B0    ..
        jsr     select_ram_page_003             ; 94FE 20 32 BE  2.
        ldy     $FD05                           ; 9501 AC 05 FD ...
L9504:  cpy     $B0                             ; 9504 C4 B0    ..
        beq     L951D                           ; 9506 F0 15    ..
        jsr     select_ram_page_002             ; 9508 20 2D BE  -.
        lda     $FD07,y                         ; 950B B9 07 FD ...
        sta     $FD0F,y                         ; 950E 99 0F FD ...
        jsr     select_ram_page_003             ; 9511 20 32 BE  2.
        lda     $FD07,y                         ; 9514 B9 07 FD ...
        sta     $FD0F,y                         ; 9517 99 0F FD ...
        dey                                     ; 951A 88       .
        bcs     L9504                           ; 951B B0 E7    ..
L951D:  jsr     select_ram_page_001             ; 951D 20 28 BE  (.
        jsr     L95AD                           ; 9520 20 AD 95  ..
        jsr     L959C                           ; 9523 20 9C 95  ..
        jsr     select_ram_page_003             ; 9526 20 32 BE  2.
L9529:  lda     $BD,x                           ; 9529 B5 BD    ..
        dey                                     ; 952B 88       .
        sta     $FD08,y                         ; 952C 99 08 FD ...
        dex                                     ; 952F CA       .
        bne     L9529                           ; 9530 D0 F7    ..
        jsr     L8C3D                           ; 9532 20 3D 8C  =.
        tya                                     ; 9535 98       .
        pha                                     ; 9536 48       H
        jsr     select_ram_page_003             ; 9537 20 32 BE  2.
        ldy     $FD05                           ; 953A AC 05 FD ...
        jsr     LAA09                           ; 953D 20 09 AA  ..
        sty     $FD05                           ; 9540 8C 05 FD ...
        jsr     L9677                           ; 9543 20 77 96  w.
        pla                                     ; 9546 68       h
        tay                                     ; 9547 A8       .
        rts                                     ; 9548 60       `

; ----------------------------------------------------------------------------
L9549:  jsr     L955E                           ; 9549 20 5E 95  ^.
        clc                                     ; 954C 18       .
        lda     $FD0F,y                         ; 954D B9 0F FD ...
        adc     $C5                             ; 9550 65 C5    e.
        sta     $C5                             ; 9552 85 C5    ..
        lda     $FD0E,y                         ; 9554 B9 0E FD ...
        and     #$03                            ; 9557 29 03    ).
        adc     $C4                             ; 9559 65 C4    e.
        sta     $C4                             ; 955B 85 C4    ..
        rts                                     ; 955D 60       `

; ----------------------------------------------------------------------------
L955E:  jsr     select_ram_page_003             ; 955E 20 32 BE  2.
        lda     $FD0C,y                         ; 9561 B9 0C FD ...
        cmp     #$01                            ; 9564 C9 01    ..
        lda     $FD0D,y                         ; 9566 B9 0D FD ...
        adc     #$00                            ; 9569 69 00    i.
        sta     $C5                             ; 956B 85 C5    ..
        php                                     ; 956D 08       .
        lda     $FD0E,y                         ; 956E B9 0E FD ...
        jsr     LA9F6                           ; 9571 20 F6 A9  ..
        plp                                     ; 9574 28       (
        adc     #$00                            ; 9575 69 00    i.
        sta     $C4                             ; 9577 85 C4    ..
        rts                                     ; 9579 60       `

; ----------------------------------------------------------------------------
L957A:  jsr     select_ram_page_003             ; 957A 20 32 BE  2.
        sec                                     ; 957D 38       8
        lda     $FD07,y                         ; 957E B9 07 FD ...
        sbc     $C5                             ; 9581 E5 C5    ..
        sta     $B0                             ; 9583 85 B0    ..
        lda     $FD06,y                         ; 9585 B9 06 FD ...
        and     #$03                            ; 9588 29 03    ).
        sbc     $C4                             ; 958A E5 C4    ..
        tax                                     ; 958C AA       .
        ora     $B0                             ; 958D 05 B0    ..
        rts                                     ; 958F 60       `

; ----------------------------------------------------------------------------
L9590:  lda     #$00                            ; 9590 A9 00    ..
        cmp     $C2                             ; 9592 C5 C2    ..
L9594:  lda     $B0                             ; 9594 A5 B0    ..
        sbc     $C3                             ; 9596 E5 C3    ..
        txa                                     ; 9598 8A       .
        sbc     $C6                             ; 9599 E5 C6    ..
        rts                                     ; 959B 60       `

; ----------------------------------------------------------------------------
L959C:  jsr     select_ram_page_002             ; 959C 20 2D BE  -.
        ldx     #$00                            ; 959F A2 00    ..
L95A1:  lda     $C7,x                           ; 95A1 B5 C7    ..
        sta     $FD08,y                         ; 95A3 99 08 FD ...
        iny                                     ; 95A6 C8       .
        inx                                     ; 95A7 E8       .
        cpx     #$08                            ; 95A8 E0 08    ..
        bne     L95A1                           ; 95AA D0 F5    ..
        rts                                     ; 95AC 60       `

; ----------------------------------------------------------------------------
L95AD:  lda     $FDB7                           ; 95AD AD B7 FD ...
        and     #$03                            ; 95B0 29 03    ).
        asl     a                               ; 95B2 0A       .
        asl     a                               ; 95B3 0A       .
        eor     $C6                             ; 95B4 45 C6    E.
        and     #$FC                            ; 95B6 29 FC    ).
        eor     $C6                             ; 95B8 45 C6    E.
        asl     a                               ; 95BA 0A       .
        asl     a                               ; 95BB 0A       .
        eor     $FDB5                           ; 95BC 4D B5 FD M..
        and     #$FC                            ; 95BF 29 FC    ).
        eor     $FDB5                           ; 95C1 4D B5 FD M..
        asl     a                               ; 95C4 0A       .
        asl     a                               ; 95C5 0A       .
        eor     $C4                             ; 95C6 45 C4    E.
        and     #$FC                            ; 95C8 29 FC    ).
        eor     $C4                             ; 95CA 45 C4    E.
        sta     $C4                             ; 95CC 85 C4    ..
        rts                                     ; 95CE 60       `

; ----------------------------------------------------------------------------
enable_command:
        jsr     LAA52                           ; 95CF 20 52 AA  R.
        beq     L95F0                           ; 95D2 F0 1C    ..
        ldx     #$00                            ; 95D4 A2 00    ..
L95D6:  jsr     gsread                          ; 95D6 20 C5 FF  ..
        bcs     L95F6                           ; 95D9 B0 1B    ..
        cmp     L95F9,x                         ; 95DB DD F9 95 ...
        bne     L95F6                           ; 95DE D0 16    ..
        inx                                     ; 95E0 E8       .
        cpx     #$03                            ; 95E1 E0 03    ..
        bne     L95D6                           ; 95E3 D0 F1    ..
        jsr     gsread                          ; 95E5 20 C5 FF  ..
        bcc     L95F6                           ; 95E8 90 0C    ..
        lda     #$80                            ; 95EA A9 80    ..
        sta     $FDF4                           ; 95EC 8D F4 FD ...
        rts                                     ; 95EF 60       `

; ----------------------------------------------------------------------------
L95F0:  lda     #$01                            ; 95F0 A9 01    ..
        sta     $FDDF                           ; 95F2 8D DF FD ...
        rts                                     ; 95F5 60       `

; ----------------------------------------------------------------------------
L95F6:  jmp     L98B1                           ; 95F6 4C B1 98 L..

; ----------------------------------------------------------------------------
L95F9:  .byte   $43                             ; 95F9 43       C
        eor     ($54,x)                         ; 95FA 41 54    AT
L95FC:  pha                                     ; 95FC 48       H
        lda     #$00                            ; 95FD A9 00    ..
        pha                                     ; 95FF 48       H
        lda     $C4                             ; 9600 A5 C4    ..
        jsr     LA9F8                           ; 9602 20 F8 A9  ..
        cmp     #$03                            ; 9605 C9 03    ..
        bne     L960F                           ; 9607 D0 06    ..
        pla                                     ; 9609 68       h
        pla                                     ; 960A 68       h
L960B:  pha                                     ; 960B 48       H
        lda     #$FF                            ; 960C A9 FF    ..
        pha                                     ; 960E 48       H
L960F:  jsr     select_ram_page_001             ; 960F 20 28 BE  (.
        sta     $FDB5                           ; 9612 8D B5 FD ...
        pla                                     ; 9615 68       h
        sta     $FDB6                           ; 9616 8D B6 FD ...
        pla                                     ; 9619 68       h
        rts                                     ; 961A 60       `

; ----------------------------------------------------------------------------
L961B:  lda     #$00                            ; 961B A9 00    ..
        sta     $FDB8                           ; 961D 8D B8 FD ...
        lda     $C4                             ; 9620 A5 C4    ..
        jsr     LA9F4                           ; 9622 20 F4 A9  ..
        cmp     #$03                            ; 9625 C9 03    ..
        bne     L962E                           ; 9627 D0 05    ..
        lda     #$FF                            ; 9629 A9 FF    ..
        sta     $FDB8                           ; 962B 8D B8 FD ...
L962E:  sta     $FDB7                           ; 962E 8D B7 FD ...
        rts                                     ; 9631 60       `

; ----------------------------------------------------------------------------
rename_command:
        jsr     L8AE3                           ; 9632 20 E3 8A  ..
        jsr     L929B                           ; 9635 20 9B 92  ..
        jsr     LAB39                           ; 9638 20 39 AB  9.
        pha                                     ; 963B 48       H
        tya                                     ; 963C 98       .
        pha                                     ; 963D 48       H
        jsr     L8AF2                           ; 963E 20 F2 8A  ..
        jsr     LA30A                           ; 9641 20 0A A3  ..
        sty     $B3                             ; 9644 84 B3    ..
        pla                                     ; 9646 68       h
        tay                                     ; 9647 A8       .
        jsr     LA5C4                           ; 9648 20 C4 A5  ..
        lda     $FDC6                           ; 964B AD C6 FD ...
        sta     $CE                             ; 964E 85 CE    ..
        jsr     L89A3                           ; 9650 20 A3 89  ..
        pla                                     ; 9653 68       h
        sta     $FDC0                           ; 9654 8D C0 FD ...
        jsr     LAB39                           ; 9657 20 39 AB  9.
        cmp     $FDC0                           ; 965A CD C0 FD ...
        beq     L9662                           ; 965D F0 03    ..
        jmp     L98B1                           ; 965F 4C B1 98 L..

; ----------------------------------------------------------------------------
L9662:  jsr     L8BCE                           ; 9662 20 CE 8B  ..
        bcc     L9672                           ; 9665 90 0B    ..
        jsr     LA905                           ; 9667 20 05 A9  ..
        .byte   $C4                             ; 966A C4       .
        .byte   "exists"                        ; 966B 65 78 69 73 74 73exists
        .byte   $00                             ; 9671 00       .
; ----------------------------------------------------------------------------
L9672:  ldy     $B3                             ; 9672 A4 B3    ..
        jsr     L959C                           ; 9674 20 9C 95  ..
L9677:  jsr     select_ram_page_003             ; 9677 20 32 BE  2.
        clc                                     ; 967A 18       .
        sed                                     ; 967B F8       .
        lda     $FD04                           ; 967C AD 04 FD ...
        adc     #$01                            ; 967F 69 01    i.
        sta     $FD04                           ; 9681 8D 04 FD ...
        cld                                     ; 9684 D8       .
        jsr     L97AB                           ; 9685 20 AB 97  ..
        jmp     L96A1                           ; 9688 4C A1 96 L..

; ----------------------------------------------------------------------------
L968B:  jsr     select_ram_page_001             ; 968B 20 28 BE  (.
        jsr     LAB39                           ; 968E 20 39 AB  9.
        cmp     $FDDC                           ; 9691 CD DC FD ...
        bne     L969B                           ; 9694 D0 05    ..
        jsr     LBD1C                           ; 9696 20 1C BD  ..
        beq     L96BF                           ; 9699 F0 24    .$
L969B:  jsr     push_registers_and_tuck_restoration_thunk; 969B 20 AB A8 ..
L969E:  jsr     L97A2                           ; 969E 20 A2 97  ..
L96A1:  lda     #$00                            ; 96A1 A9 00    ..
        sta     $FDCC                           ; 96A3 8D CC FD ...
        lda     $FDE9                           ; 96A6 AD E9 FD ...
        ora     #$80                            ; 96A9 09 80    ..
        sta     $FDE9                           ; 96AB 8D E9 FD ...
        jsr     LABEE                           ; 96AE 20 EE AB  ..
        jsr     LAB39                           ; 96B1 20 39 AB  9.
        sta     $FDDC                           ; 96B4 8D DC FD ...
        jsr     L96F3                           ; 96B7 20 F3 96  ..
        beq     L96BF                           ; 96BA F0 03    ..
        jmp     LBCEE                           ; 96BC 4C EE BC L..

; ----------------------------------------------------------------------------
L96BF:  jsr     select_ram_page_001             ; 96BF 20 28 BE  (.
        bit     $FDF4                           ; 96C2 2C F4 FD ,..
        bpl     L96E1                           ; 96C5 10 1A    ..
        jsr     select_ram_page_002             ; 96C7 20 2D BE  -.
        ldx     #$00                            ; 96CA A2 00    ..
L96CC:  lda     $FD00,x                         ; 96CC BD 00 FD ...
        sta     $0E00,x                         ; 96CF 9D 00 0E ...
        inx                                     ; 96D2 E8       .
        bne     L96CC                           ; 96D3 D0 F7    ..
        jsr     select_ram_page_003             ; 96D5 20 32 BE  2.
L96D8:  lda     $FD00,x                         ; 96D8 BD 00 FD ...
        sta     $0F00,x                         ; 96DB 9D 00 0F ...
        inx                                     ; 96DE E8       .
        bne     L96D8                           ; 96DF D0 F7    ..
L96E1:  jsr     select_ram_page_001             ; 96E1 20 28 BE  (.
        jmp     LADDD                           ; 96E4 4C DD AD L..

; ----------------------------------------------------------------------------
        lda     #$80                            ; 96E7 A9 80    ..
        bne     L96ED                           ; 96E9 D0 02    ..
L96EB:  lda     #$81                            ; 96EB A9 81    ..
L96ED:  jsr     select_ram_page_001             ; 96ED 20 28 BE  (.
        sta     $FDE9                           ; 96F0 8D E9 FD ...
L96F3:  jsr     LA8D4                           ; 96F3 20 D4 A8  ..
        jsr     L970D                           ; 96F6 20 0D 97  ..
        ldx     #$03                            ; 96F9 A2 03    ..
L96FB:  lda     #$00                            ; 96FB A9 00    ..
        sta     $A0                             ; 96FD 85 A0    ..
        lda     #$02                            ; 96FF A9 02    ..
        sta     $A1                             ; 9701 85 A1    ..
        jsr     LBA59                           ; 9703 20 59 BA  Y.
        beq     L970C                           ; 9706 F0 04    ..
        dex                                     ; 9708 CA       .
        bne     L96FB                           ; 9709 D0 F0    ..
        dex                                     ; 970B CA       .
L970C:  rts                                     ; 970C 60       `

; ----------------------------------------------------------------------------
L970D:  lda     #$02                            ; 970D A9 02    ..
        sta     $A6                             ; 970F 85 A6    ..
        lda     #$00                            ; 9711 A9 00    ..
        sta     $A7                             ; 9713 85 A7    ..
        rts                                     ; 9715 60       `

; ----------------------------------------------------------------------------
L9716:  jsr     select_ram_page_001             ; 9716 20 28 BE  (.
        pha                                     ; 9719 48       H
        lda     $BE                             ; 971A A5 BE    ..
        sta     $FDB3                           ; 971C 8D B3 FD ...
        lda     $BF                             ; 971F A5 BF    ..
        sta     $FDB4                           ; 9721 8D B4 FD ...
        lda     $FDB5                           ; 9724 AD B5 FD ...
        and     $FDB6                           ; 9727 2D B6 FD -..
        ora     $FDCD                           ; 972A 0D CD FD ...
        eor     #$FF                            ; 972D 49 FF    I.
        sta     $FDCC                           ; 972F 8D CC FD ...
        sec                                     ; 9732 38       8
        beq     L9742                           ; 9733 F0 0D    ..
        jsr     L9744                           ; 9735 20 44 97  D.
        ldx     #$B3                            ; 9738 A2 B3    ..
        ldy     #$FD                            ; 973A A0 FD    ..
        pla                                     ; 973C 68       h
        pha                                     ; 973D 48       H
        jsr     L0406                           ; 973E 20 06 04  ..
        clc                                     ; 9741 18       .
L9742:  pla                                     ; 9742 68       h
        rts                                     ; 9743 60       `

; ----------------------------------------------------------------------------
L9744:  pha                                     ; 9744 48       H
L9745:  lda     #$C1                            ; 9745 A9 C1    ..
        jsr     L0406                           ; 9747 20 06 04  ..
        bcc     L9745                           ; 974A 90 F9    ..
        pla                                     ; 974C 68       h
        rts                                     ; 974D 60       `

; ----------------------------------------------------------------------------
L974E:  pha                                     ; 974E 48       H
        lda     $FDCC                           ; 974F AD CC FD ...
        beq     L9759                           ; 9752 F0 05    ..
L9754:  lda     #$81                            ; 9754 A9 81    ..
        jsr     L0406                           ; 9756 20 06 04  ..
L9759:  pla                                     ; 9759 68       h
        rts                                     ; 975A 60       `

; ----------------------------------------------------------------------------
L975B:  pha                                     ; 975B 48       H
        lda     #$EA                            ; 975C A9 EA    ..
        jsr     LAE3D                           ; 975E 20 3D AE  =.
        txa                                     ; 9761 8A       .
        bne     L9754                           ; 9762 D0 F0    ..
        pla                                     ; 9764 68       h
        rts                                     ; 9765 60       `

; ----------------------------------------------------------------------------
L9766:  jsr     L97A6                           ; 9766 20 A6 97  ..
        jmp     L976F                           ; 9769 4C 6F 97 Lo.

; ----------------------------------------------------------------------------
L976C:  jsr     L979D                           ; 976C 20 9D 97  ..
L976F:  jsr     L8A9E                           ; 976F 20 9E 8A  ..
        jmp     L9781                           ; 9772 4C 81 97 L..

; ----------------------------------------------------------------------------
L9775:  jsr     L979D                           ; 9775 20 9D 97  ..
        jmp     L977E                           ; 9778 4C 7E 97 L~.

; ----------------------------------------------------------------------------
L977B:  jsr     L97A6                           ; 977B 20 A6 97  ..
L977E:  jsr     L8A95                           ; 977E 20 95 8A  ..
L9781:  lda     #$01                            ; 9781 A9 01    ..
        jsr     LAD61                           ; 9783 20 61 AD  a.
        jmp     L974E                           ; 9786 4C 4E 97 LN.

; ----------------------------------------------------------------------------
L9789:  lda     #$81                            ; 9789 A9 81    ..
        .byte   $AE                             ; 978B AE       .
L978C:  lda     #$80                            ; 978C A9 80    ..
        sta     $FDE9                           ; 978E 8D E9 FD ...
        jsr     LADF4                           ; 9791 20 F4 AD  ..
        jsr     L8A9E                           ; 9794 20 9E 8A  ..
        jsr     LAD61                           ; 9797 20 61 AD  a.
        jmp     L974E                           ; 979A 4C 4E 97 LN.

; ----------------------------------------------------------------------------
L979D:  lda     #$01                            ; 979D A9 01    ..
        jsr     L9716                           ; 979F 20 16 97  ..
L97A2:  lda     #$00                            ; 97A2 A9 00    ..
        beq     L97B2                           ; 97A4 F0 0C    ..
L97A6:  lda     #$00                            ; 97A6 A9 00    ..
        jsr     L9716                           ; 97A8 20 16 97  ..
L97AB:  jsr     LAE07                           ; 97AB 20 07 AE  ..
        bne     L97C4                           ; 97AE D0 14    ..
        lda     #$01                            ; 97B0 A9 01    ..
L97B2:  jsr     select_ram_page_001             ; 97B2 20 28 BE  (.
        sta     $FDE9                           ; 97B5 8D E9 FD ...
        jsr     LADF4                           ; 97B8 20 F4 AD  ..
L97BB:  jsr     select_ram_page_001             ; 97BB 20 28 BE  (.
        lda     #$FF                            ; 97BE A9 FF    ..
        sta     $FDDC                           ; 97C0 8D DC FD ...
        rts                                     ; 97C3 60       `

; ----------------------------------------------------------------------------
L97C4:  jmp     LA8E3                           ; 97C4 4C E3 A8 L..

; ----------------------------------------------------------------------------
L97C7:  jsr     select_ram_page_001             ; 97C7 20 28 BE  (.
        cmp     #$09                            ; 97CA C9 09    ..
        bcs     L97DC                           ; 97CC B0 0E    ..
        stx     $B5                             ; 97CE 86 B5    ..
        tax                                     ; 97D0 AA       .
        lda     LAE69,x                         ; 97D1 BD 69 AE .i.
        pha                                     ; 97D4 48       H
        lda     LAE60,x                         ; 97D5 BD 60 AE .`.
        pha                                     ; 97D8 48       H
        txa                                     ; 97D9 8A       .
        ldx     $B5                             ; 97DA A6 B5    ..
L97DC:  rts                                     ; 97DC 60       `

; ----------------------------------------------------------------------------
        jsr     push_registers_and_tuck_restoration_thunk; 97DD 20 AB A8 ..
        cpx     #$0A                            ; 97E0 E0 0A    ..
        bcs     L97F0                           ; 97E2 B0 0C    ..
        txa                                     ; 97E4 8A       .
        asl     a                               ; 97E5 0A       .
        tax                                     ; 97E6 AA       .
        lda     L985D,x                         ; 97E7 BD 5D 98 .].
        pha                                     ; 97EA 48       H
        lda     L985C,x                         ; 97EB BD 5C 98 .\.
        pha                                     ; 97EE 48       H
        rts                                     ; 97EF 60       `

; ----------------------------------------------------------------------------
L97F0:  jsr     LA8FC                           ; 97F0 20 FC A8  ..
        .byte   $CB                             ; 97F3 CB       .
        .byte   $6F                             ; 97F4 6F       o
        bvs     L986B                           ; 97F5 70 74    pt
        adc     #$6F                            ; 97F7 69 6F    io
        ror     LA200                           ; 97F9 6E 00 A2 n..
        .byte   $FF                             ; 97FC FF       .
        tya                                     ; 97FD 98       .
        beq     L9801                           ; 97FE F0 01    ..
        inx                                     ; 9800 E8       .
L9801:  stx     $FDD9                           ; 9801 8E D9 FD ...
        rts                                     ; 9804 60       `

; ----------------------------------------------------------------------------
        tya                                     ; 9805 98       .
        pha                                     ; 9806 48       H
        jsr     LAA7E                           ; 9807 20 7E AA  ~.
        jsr     L969E                           ; 980A 20 9E 96  ..
        pla                                     ; 980D 68       h
        jsr     LAA04                           ; 980E 20 04 AA  ..
        jsr     select_ram_page_003             ; 9811 20 32 BE  2.
        eor     $FD06                           ; 9814 4D 06 FD M..
        and     #$30                            ; 9817 29 30    )0
        eor     $FD06                           ; 9819 4D 06 FD M..
        sta     $FD06                           ; 981C 8D 06 FD ...
        jmp     L9677                           ; 981F 4C 77 96 Lw.

; ----------------------------------------------------------------------------
        lda     #$40                            ; 9822 A9 40    .@
        cpy     #$12                            ; 9824 C0 12    ..
        beq     L9832                           ; 9826 F0 0A    ..
        asl     a                               ; 9828 0A       .
        cpy     #$00                            ; 9829 C0 00    ..
        beq     L9832                           ; 982B F0 05    ..
        asl     a                               ; 982D 0A       .
        cpy     #$0A                            ; 982E C0 0A    ..
        bne     L97F0                           ; 9830 D0 BE    ..
L9832:  sta     $FDED                           ; 9832 8D ED FD ...
        rts                                     ; 9835 60       `

; ----------------------------------------------------------------------------
        cpy     #$04                            ; 9836 C0 04    ..
        bcs     L97F0                           ; 9838 B0 B6    ..
        tya                                     ; 983A 98       .
        eor     #$03                            ; 983B 49 03    I.
        sta     $FDF2                           ; 983D 8D F2 FD ...
        rts                                     ; 9840 60       `

; ----------------------------------------------------------------------------
        lda     #$40                            ; 9841 A9 40    .@
        iny                                     ; 9843 C8       .
        cpy     #$02                            ; 9844 C0 02    ..
        beq     L9850                           ; 9846 F0 08    ..
        bcs     L97F0                           ; 9848 B0 A6    ..
        asl     a                               ; 984A 0A       .
        cpy     #$01                            ; 984B C0 01    ..
        bcc     L9850                           ; 984D 90 01    ..
        asl     a                               ; 984F 0A       .
L9850:  sta     $FDEA                           ; 9850 8D EA FD ...
        rts                                     ; 9853 60       `

; ----------------------------------------------------------------------------
        cpy     #$10                            ; 9854 C0 10    ..
        bcs     L97F0                           ; 9856 B0 98    ..
        sty     $FDEE                           ; 9858 8C EE FD ...
        rts                                     ; 985B 60       `

; ----------------------------------------------------------------------------
L985C:  .byte   $EF                             ; 985C EF       .
L985D:  .byte   $97                             ; 985D 97       .
        .byte   $FA                             ; 985E FA       .
        .byte   $97                             ; 985F 97       .
        .byte   $EF                             ; 9860 EF       .
        .byte   $97                             ; 9861 97       .
        .byte   $EF                             ; 9862 EF       .
        .byte   $97                             ; 9863 97       .
        .byte   $04                             ; 9864 04       .
        tya                                     ; 9865 98       .
        .byte   $EF                             ; 9866 EF       .
        .byte   $97                             ; 9867 97       .
        and     ($98,x)                         ; 9868 21 98    !.
        .byte   $35                             ; 986A 35       5
L986B:  tya                                     ; 986B 98       .
        rti                                     ; 986C 40       @

; ----------------------------------------------------------------------------
        tya                                     ; 986D 98       .
        .byte   $53                             ; 986E 53       S
        tya                                     ; 986F 98       .
        pha                                     ; 9870 48       H
        tya                                     ; 9871 98       .
        pha                                     ; 9872 48       H
        txa                                     ; 9873 8A       .
        tay                                     ; 9874 A8       .
        jsr     L9D03                           ; 9875 20 03 9D  ..
        tya                                     ; 9878 98       .
        jsr     L9F07                           ; 9879 20 07 9F  ..
        bne     L9882                           ; 987C D0 04    ..
        ldx     #$FF                            ; 987E A2 FF    ..
        bne     L9884                           ; 9880 D0 02    ..
L9882:  ldx     #$00                            ; 9882 A2 00    ..
L9884:  pla                                     ; 9884 68       h
        tay                                     ; 9885 A8       .
        pla                                     ; 9886 68       h
        rts                                     ; 9887 60       `

; ----------------------------------------------------------------------------
        jsr     L91ED                           ; 9888 20 ED 91  ..
        jsr     L98F7                           ; 988B 20 F7 98  ..
        sty     $FDE3                           ; 988E 8C E3 FD ...
        jsr     L8993                           ; 9891 20 93 89  ..
        sty     $FDE2                           ; 9894 8C E2 FD ...
        jsr     L8BCE                           ; 9897 20 CE 8B  ..
        bcs     L98BD                           ; 989A B0 21    .!
        ldy     $FDE3                           ; 989C AC E3 FD ...
        lda     $FDC8                           ; 989F AD C8 FD ...
        sta     $CE                             ; 98A2 85 CE    ..
        lda     $FDC9                           ; 98A4 AD C9 FD ...
        sta     $CF                             ; 98A7 85 CF    ..
        jsr     L8996                           ; 98A9 20 96 89  ..
        jsr     L8BCE                           ; 98AC 20 CE 8B  ..
        bcs     L98BD                           ; 98AF B0 0C    ..
L98B1:  jsr     LA8FC                           ; 98B1 20 FC A8  ..
        inc     L6F63,x                         ; 98B4 FE 63 6F .co
        adc     $616D                           ; 98B7 6D 6D 61 mma
        ror     a:$64                           ; 98BA 6E 64 00 nd.
L98BD:  jsr     LA25A                           ; 98BD 20 5A A2  Z.
        clc                                     ; 98C0 18       .
        lda     $FDE2                           ; 98C1 AD E2 FD ...
        tay                                     ; 98C4 A8       .
        adc     $F2                             ; 98C5 65 F2    e.
        sta     $FDE2                           ; 98C7 8D E2 FD ...
        lda     $F3                             ; 98CA A5 F3    ..
        adc     #$00                            ; 98CC 69 00    i.
        sta     $FDE3                           ; 98CE 8D E3 FD ...
        lda     $FDB7                           ; 98D1 AD B7 FD ...
        and     $FDB8                           ; 98D4 2D B8 FD -..
        ora     $FDCD                           ; 98D7 0D CD FD ...
        cmp     #$FF                            ; 98DA C9 FF    ..
        beq     L98F4                           ; 98DC F0 16    ..
        lda     L00C0                           ; 98DE A5 C0    ..
        sta     $FDB5                           ; 98E0 8D B5 FD ...
        lda     $C1                             ; 98E3 A5 C1    ..
        sta     $FDB6                           ; 98E5 8D B6 FD ...
        jsr     L9744                           ; 98E8 20 44 97  D.
        ldx     #$B5                            ; 98EB A2 B5    ..
        ldy     #$FD                            ; 98ED A0 FD    ..
        lda     #$04                            ; 98EF A9 04    ..
        jmp     L0406                           ; 98F1 4C 06 04 L..

; ----------------------------------------------------------------------------
L98F4:  jmp     (L00C0)                         ; 98F4 6C C0 00 l..

; ----------------------------------------------------------------------------
L98F7:  lda     #$FF                            ; 98F7 A9 FF    ..
        sta     L00C0                           ; 98F9 85 C0    ..
        lda     $F2                             ; 98FB A5 F2    ..
        sta     $BC                             ; 98FD 85 BC    ..
        lda     $F3                             ; 98FF A5 F3    ..
        sta     $BD                             ; 9901 85 BD    ..
        rts                                     ; 9903 60       `

; ----------------------------------------------------------------------------
        jsr     L91ED                           ; 9904 20 ED 91  ..
        ldx     #$5E                            ; 9907 A2 5E    .^
        ldy     #$90                            ; 9909 A0 90    ..
        lda     #$00                            ; 990B A9 00    ..
        jsr     L915D                           ; 990D 20 5D 91  ].
        tsx                                     ; 9910 BA       .
        stx     $B8                             ; 9911 86 B8    ..
        jmp     L80CD                           ; 9913 4C CD 80 L..

; ----------------------------------------------------------------------------
        jsr     L91ED                           ; 9916 20 ED 91  ..
        jsr     LAA52                           ; 9919 20 52 AA  R.
        jsr     LAAD2                           ; 991C 20 D2 AA  ..
        txa                                     ; 991F 8A       .
        bpl     L995B                           ; 9920 10 39    .9
        lda     #$80                            ; 9922 A9 80    ..
        sta     $FDE9                           ; 9924 8D E9 FD ...
        jsr     LABEE                           ; 9927 20 EE AB  ..
        bit     $FDED                           ; 992A 2C ED FD ,..
        bvc     L995B                           ; 992D 50 2C    P,
        jsr     L8EAB                           ; 992F 20 AB 8E  ..
        ldx     #$00                            ; 9932 A2 00    ..
L9934:  jsr     select_ram_page_000             ; 9934 20 23 BE  #.
        lda     $FDBC,x                         ; 9937 BD BC FD ...
        beq     L994C                           ; 993A F0 10    ..
        txa                                     ; 993C 8A       .
        pha                                     ; 993D 48       H
        jsr     L968B                           ; 993E 20 8B 96  ..
        jsr     L8E77                           ; 9941 20 77 8E  w.
        jsr     L8F32                           ; 9944 20 32 8F  2.
        jsr     L8D6A                           ; 9947 20 6A 8D  j.
        pla                                     ; 994A 68       h
        tax                                     ; 994B AA       .
L994C:  clc                                     ; 994C 18       .
        lda     $CF                             ; 994D A5 CF    ..
        adc     #$10                            ; 994F 69 10    i.
        sta     $CF                             ; 9951 85 CF    ..
        inx                                     ; 9953 E8       .
        cpx     #$08                            ; 9954 E0 08    ..
        bne     L9934                           ; 9956 D0 DC    ..
        jmp     select_ram_page_001             ; 9958 4C 28 BE L(.

; ----------------------------------------------------------------------------
L995B:  jsr     L968B                           ; 995B 20 8B 96  ..
        jsr     L8E77                           ; 995E 20 77 8E  w.
        jsr     L8EAB                           ; 9961 20 AB 8E  ..
        jsr     L8F32                           ; 9964 20 32 8F  2.
        jsr     L8F62                           ; 9967 20 62 8F  b.
        jmp     L8D6A                           ; 996A 4C 6A 8D Lj.

; ----------------------------------------------------------------------------
        jsr     L9977                           ; 996D 20 77 99  w.
        asl     $FD00                           ; 9970 0E 00 FD ...
        lsr     $FD00                           ; 9973 4E 00 FD N..
        rts                                     ; 9976 60       `

; ----------------------------------------------------------------------------
L9977:  jsr     push_registers_and_tuck_restoration_thunk; 9977 20 AB A8 ..
        lda     #$77                            ; 997A A9 77    .w
        jmp     osbyte                          ; 997C 4C F4 FF L..

; ----------------------------------------------------------------------------
        ldx     #$11                            ; 997F A2 11    ..
        ldy     #$15                            ; 9981 A0 15    ..
        rts                                     ; 9983 60       `

; ----------------------------------------------------------------------------
        bit     $FDDF                           ; 9984 2C DF FD ,..
        bmi     L998C                           ; 9987 30 03    0.
        dec     $FDDF                           ; 9989 CE DF FD ...
L998C:  jmp     L97BB                           ; 998C 4C BB 97 L..

; ----------------------------------------------------------------------------
L998F:  jsr     LABD3                           ; 998F 20 D3 AB  ..
L9992:  jsr     select_ram_page_001             ; 9992 20 28 BE  (.
        ldx     #$07                            ; 9995 A2 07    ..
L9997:  .byte   $B9                             ; 9997 B9       .
L9998:  .byte   $ED                             ; 9998 ED       .
L9999:  .byte   $FC                             ; 9999 FC       .
        sta     $C6,x                           ; 999A 95 C6    ..
        dey                                     ; 999C 88       .
        dey                                     ; 999D 88       .
        dex                                     ; 999E CA       .
        bne     L9997                           ; 999F D0 F6    ..
        jsr     L8BCE                           ; 99A1 20 CE 8B  ..
        bcc     L99C6                           ; 99A4 90 20    . 
        sty     $FDD2                           ; 99A6 8C D2 FD ...
        jsr     select_ram_page_003             ; 99A9 20 32 BE  2.
        lda     $FD0E,y                         ; 99AC B9 0E FD ...
        ldx     $FD0F,y                         ; 99AF BE 0F FD ...
        jsr     select_ram_page_001             ; 99B2 20 28 BE  (.
        ldy     $FDD0                           ; 99B5 AC D0 FD ...
        eor     $FCEE,y                         ; 99B8 59 EE FC Y..
        and     #$03                            ; 99BB 29 03    ).
        bne     L99C6                           ; 99BD D0 07    ..
        txa                                     ; 99BF 8A       .
        cmp     $FCF0,y                         ; 99C0 D9 F0 FC ...
        bne     L99C6                           ; 99C3 D0 01    ..
        rts                                     ; 99C5 60       `

; ----------------------------------------------------------------------------
L99C6:  jmp     L8A43                           ; 99C6 4C 43 8A LC.

; ----------------------------------------------------------------------------
        cmp     #$00                            ; 99C9 C9 00    ..
        bne     L9A41                           ; 99CB D0 74    .t
        jsr     push_registers_and_tuck_restoration_thunk; 99CD 20 AB A8 ..
L99D0:  tya                                     ; 99D0 98       .
        beq     L99DC                           ; 99D1 F0 09    ..
        pha                                     ; 99D3 48       H
        jsr     L9D17                           ; 99D4 20 17 9D  ..
        tay                                     ; 99D7 A8       .
        pla                                     ; 99D8 68       h
        jmp     L99F0                           ; 99D9 4C F0 99 L..

; ----------------------------------------------------------------------------
L99DC:  jsr     L9977                           ; 99DC 20 77 99  w.
L99DF:  ldy     #$04                            ; 99DF A0 04    ..
L99E1:  tya                                     ; 99E1 98       .
        pha                                     ; 99E2 48       H
        lda     L9CF9,y                         ; 99E3 B9 F9 9C ...
        tay                                     ; 99E6 A8       .
        jsr     L99F0                           ; 99E7 20 F0 99  ..
        pla                                     ; 99EA 68       h
        tay                                     ; 99EB A8       .
        dey                                     ; 99EC 88       .
        bpl     L99E1                           ; 99ED 10 F2    ..
        rts                                     ; 99EF 60       `

; ----------------------------------------------------------------------------
L99F0:  jsr     select_ram_page_001             ; 99F0 20 28 BE  (.
        pha                                     ; 99F3 48       H
        jsr     L9CDC                           ; 99F4 20 DC 9C  ..
        bcs     L9A3F                           ; 99F7 B0 46    .F
        lda     fdc_control,y                   ; 99F9 B9 FC FC ...
        eor     #$FF                            ; 99FC 49 FF    I.
        and     $FDCE                           ; 99FE 2D CE FD -..
        sta     $FDCE                           ; 9A01 8D CE FD ...
        lda     fdc_status_or_cmd,y             ; 9A04 B9 F8 FC ...
        and     #$60                            ; 9A07 29 60    )`
        beq     L9A3F                           ; 9A09 F0 34    .4
        jsr     L998F                           ; 9A0B 20 8F 99  ..
        lda     fdc_status_or_cmd,y             ; 9A0E B9 F8 FC ...
        and     #$20                            ; 9A11 29 20    ) 
        beq     L9A3C                           ; 9A13 F0 27    .'
        ldx     $FDD2                           ; 9A15 AE D2 FD ...
        lda     $FCF5,y                         ; 9A18 B9 F5 FC ...
        jsr     select_ram_page_003             ; 9A1B 20 32 BE  2.
        sta     $FD0C,x                         ; 9A1E 9D 0C FD ...
        jsr     select_ram_page_001             ; 9A21 20 28 BE  (.
        lda     $FCF6,y                         ; 9A24 B9 F6 FC ...
        jsr     select_ram_page_003             ; 9A27 20 32 BE  2.
        sta     $FD0D,x                         ; 9A2A 9D 0D FD ...
        jsr     select_ram_page_001             ; 9A2D 20 28 BE  (.
        lda     $FCF7,y                         ; 9A30 B9 F7 FC ...
        jsr     L92A1                           ; 9A33 20 A1 92  ..
        jsr     L9677                           ; 9A36 20 77 96  w.
        ldy     $FDD0                           ; 9A39 AC D0 FD ...
L9A3C:  jsr     L9DAA                           ; 9A3C 20 AA 9D  ..
L9A3F:  pla                                     ; 9A3F 68       h
        rts                                     ; 9A40 60       `

; ----------------------------------------------------------------------------
L9A41:  jsr     LA8D4                           ; 9A41 20 D4 A8  ..
        stx     $BC                             ; 9A44 86 BC    ..
        sty     $BD                             ; 9A46 84 BD    ..
        sta     $B4                             ; 9A48 85 B4    ..
        bit     $B4                             ; 9A4A 24 B4    $.
        php                                     ; 9A4C 08       .
        jsr     L8993                           ; 9A4D 20 93 89  ..
        jsr     L9B5F                           ; 9A50 20 5F 9B  _.
        bcc     L9A6D                           ; 9A53 90 18    ..
        jsr     LA90D                           ; 9A55 20 0D A9  ..
        .byte   $C0                             ; 9A58 C0       .
        .byte   "Too many files open"           ; 9A59 54 6F 6F 20 6D 61 6E 79Too many
                                                ; 9A61 20 66 69 6C 65 73 20 6F files o
                                                ; 9A69 70 65 6E pen
        .byte   $00                             ; 9A6C 00       .
; ----------------------------------------------------------------------------
L9A6D:  ldx     #$C7                            ; 9A6D A2 C7    ..
        lda     #$00                            ; 9A6F A9 00    ..
        tay                                     ; 9A71 A8       .
        jsr     L9B78                           ; 9A72 20 78 9B  x.
        bcc     L9A91                           ; 9A75 90 1A    ..
L9A77:  jsr     select_ram_page_001             ; 9A77 20 28 BE  (.
        lda     $FCED,y                         ; 9A7A B9 ED FC ...
        bpl     L9A83                           ; 9A7D 10 04    ..
        plp                                     ; 9A7F 28       (
        php                                     ; 9A80 08       .
        bpl     L9A8C                           ; 9A81 10 09    ..
L9A83:  jsr     LA905                           ; 9A83 20 05 A9  ..
        .byte   $C2                             ; 9A86 C2       .
        .byte   "open"                          ; 9A87 6F 70 65 6Eopen
        .byte   $00                             ; 9A8B 00       .
; ----------------------------------------------------------------------------
L9A8C:  jsr     L9B92                           ; 9A8C 20 92 9B  ..
        bcs     L9A77                           ; 9A8F B0 E6    ..
L9A91:  jsr     L8AE3                           ; 9A91 20 E3 8A  ..
        jsr     L8BCE                           ; 9A94 20 CE 8B  ..
        bcs     L9AB6                           ; 9A97 B0 1D    ..
        lda     #$00                            ; 9A99 A9 00    ..
        plp                                     ; 9A9B 28       (
        bvc     L9A9F                           ; 9A9C 50 01    P.
        rts                                     ; 9A9E 60       `

; ----------------------------------------------------------------------------
L9A9F:  php                                     ; 9A9F 08       .
        jsr     select_ram_page_001             ; 9AA0 20 28 BE  (.
        ldx     #$07                            ; 9AA3 A2 07    ..
L9AA5:  sta     $BE,x                           ; 9AA5 95 BE    ..
        sta     $FDB5,x                         ; 9AA7 9D B5 FD ...
        dex                                     ; 9AAA CA       .
        bpl     L9AA5                           ; 9AAB 10 F8    ..
        lda     #$40                            ; 9AAD A9 40    .@
        sta     $C5                             ; 9AAF 85 C5    ..
        sta     L00A8                           ; 9AB1 85 A8    ..
        jsr     L9426                           ; 9AB3 20 26 94  &.
L9AB6:  tya                                     ; 9AB6 98       .
        tax                                     ; 9AB7 AA       .
        plp                                     ; 9AB8 28       (
        php                                     ; 9AB9 08       .
        bvs     L9ABF                           ; 9ABA 70 03    p.
        jsr     LA2F7                           ; 9ABC 20 F7 A2  ..
L9ABF:  jsr     select_ram_page_001             ; 9ABF 20 28 BE  (.
        lda     #$08                            ; 9AC2 A9 08    ..
        sta     $FDD3                           ; 9AC4 8D D3 FD ...
        ldy     $FDD0                           ; 9AC7 AC D0 FD ...
L9ACA:  jsr     select_ram_page_002             ; 9ACA 20 2D BE  -.
        lda     $FD08,x                         ; 9ACD BD 08 FD ...
        jsr     select_ram_page_001             ; 9AD0 20 28 BE  (.
        sta     $FCE1,y                         ; 9AD3 99 E1 FC ...
        iny                                     ; 9AD6 C8       .
        jsr     select_ram_page_003             ; 9AD7 20 32 BE  2.
        lda     $FD08,x                         ; 9ADA BD 08 FD ...
        jsr     select_ram_page_001             ; 9ADD 20 28 BE  (.
        sta     $FCE1,y                         ; 9AE0 99 E1 FC ...
        iny                                     ; 9AE3 C8       .
        inx                                     ; 9AE4 E8       .
        dec     $FDD3                           ; 9AE5 CE D3 FD ...
        bne     L9ACA                           ; 9AE8 D0 E0    ..
        ldx     #$10                            ; 9AEA A2 10    ..
        lda     #$00                            ; 9AEC A9 00    ..
L9AEE:  sta     $FCE1,y                         ; 9AEE 99 E1 FC ...
        iny                                     ; 9AF1 C8       .
        dex                                     ; 9AF2 CA       .
        bne     L9AEE                           ; 9AF3 D0 F9    ..
        ldy     $FDD0                           ; 9AF5 AC D0 FD ...
        lda     $FDCF                           ; 9AF8 AD CF FD ...
        sta     fdc_control,y                   ; 9AFB 99 FC FC ...
        ora     $FDCE                           ; 9AFE 0D CE FD ...
        sta     $FDCE                           ; 9B01 8D CE FD ...
        lda     $FCEA,y                         ; 9B04 B9 EA FC ...
        cmp     #$01                            ; 9B07 C9 01    ..
        lda     $FCEC,y                         ; 9B09 B9 EC FC ...
        adc     #$00                            ; 9B0C 69 00    i.
        sta     fdc_sector,y                    ; 9B0E 99 FA FC ...
        lda     $FCEE,y                         ; 9B11 B9 EE FC ...
        ora     #$0F                            ; 9B14 09 0F    ..
        adc     #$00                            ; 9B16 69 00    i.
        jsr     LA9F6                           ; 9B18 20 F6 A9  ..
        sta     fdc_data,y                      ; 9B1B 99 FB FC ...
        plp                                     ; 9B1E 28       (
        bvc     L9B58                           ; 9B1F 50 37    P7
        bmi     L9B2B                           ; 9B21 30 08    0.
        lda     #$80                            ; 9B23 A9 80    ..
        ora     $FCED,y                         ; 9B25 19 ED FC ...
        sta     $FCED,y                         ; 9B28 99 ED FC ...
L9B2B:  lda     $FCEA,y                         ; 9B2B B9 EA FC ...
        sta     $FCF5,y                         ; 9B2E 99 F5 FC ...
        lda     $FCEC,y                         ; 9B31 B9 EC FC ...
        sta     $FCF6,y                         ; 9B34 99 F6 FC ...
        lda     $FCEE,y                         ; 9B37 B9 EE FC ...
        jsr     LA9F6                           ; 9B3A 20 F6 A9  ..
        sta     $FCF7,y                         ; 9B3D 99 F7 FC ...
L9B40:  lda     $CF                             ; 9B40 A5 CF    ..
        sta     $FD00,y                         ; 9B42 99 00 FD ...
        jsr     L84F0                           ; 9B45 20 F0 84  ..
        sta     $FCF4,y                         ; 9B48 99 F4 FC ...
        lda     $FDEC                           ; 9B4B AD EC FD ...
        sta     ram_paging_lsb,y                ; 9B4E 99 FF FC ...
        tya                                     ; 9B51 98       .
        jsr     LA9FD                           ; 9B52 20 FD A9  ..
        adc     #$10                            ; 9B55 69 10    i.
        rts                                     ; 9B57 60       `

; ----------------------------------------------------------------------------
L9B58:  lda     #$20                            ; 9B58 A9 20    . 
        sta     fdc_status_or_cmd,y             ; 9B5A 99 F8 FC ...
        bne     L9B40                           ; 9B5D D0 E1    ..
L9B5F:  lda     $FDCE                           ; 9B5F AD CE FD ...
        ldx     #$FB                            ; 9B62 A2 FB    ..
L9B64:  asl     a                               ; 9B64 0A       .
        bcc     L9B6B                           ; 9B65 90 04    ..
        inx                                     ; 9B67 E8       .
        bmi     L9B64                           ; 9B68 30 FA    0.
        rts                                     ; 9B6A 60       `

; ----------------------------------------------------------------------------
L9B6B:  lda     L9BFE,x                         ; 9B6B BD FE 9B ...
        sta     $FDD0                           ; 9B6E 8D D0 FD ...
        lda     L9C03,x                         ; 9B71 BD 03 9C ...
        sta     $FDCF                           ; 9B74 8D CF FD ...
        rts                                     ; 9B77 60       `

; ----------------------------------------------------------------------------
L9B78:  stx     $B0                             ; 9B78 86 B0    ..
        sty     $B1                             ; 9B7A 84 B1    ..
        sta     $B2                             ; 9B7C 85 B2    ..
        jsr     select_ram_page_001             ; 9B7E 20 28 BE  (.
        lda     $FDCE                           ; 9B81 AD CE FD ...
        and     #$F8                            ; 9B84 29 F8    ).
        sta     $B5                             ; 9B86 85 B5    ..
        ldx     #$20                            ; 9B88 A2 20    . 
L9B8A:  stx     $B4                             ; 9B8A 86 B4    ..
        asl     $B5                             ; 9B8C 06 B5    ..
        bcs     L9B9C                           ; 9B8E B0 0C    ..
        beq     L9B9A                           ; 9B90 F0 08    ..
L9B92:  lda     $B4                             ; 9B92 A5 B4    ..
        clc                                     ; 9B94 18       .
        adc     #$20                            ; 9B95 69 20    i 
        tax                                     ; 9B97 AA       .
        bcc     L9B8A                           ; 9B98 90 F0    ..
L9B9A:  clc                                     ; 9B9A 18       .
        rts                                     ; 9B9B 60       `

; ----------------------------------------------------------------------------
L9B9C:  lda     $FD00,x                         ; 9B9C BD 00 FD ...
        jsr     LAB3B                           ; 9B9F 20 3B AB  ;.
        sta     $B3                             ; 9BA2 85 B3    ..
        jsr     LAB39                           ; 9BA4 20 39 AB  9.
        eor     $B3                             ; 9BA7 45 B3    E.
        bne     L9B92                           ; 9BA9 D0 E7    ..
        lda     #$08                            ; 9BAB A9 08    ..
        sta     $B3                             ; 9BAD 85 B3    ..
        ldy     $B2                             ; 9BAF A4 B2    ..
L9BB1:  jsr     select_ram_page_002             ; 9BB1 20 2D BE  -.
        lda     ($B0),y                         ; 9BB4 B1 B0    ..
        jsr     select_ram_page_001             ; 9BB6 20 28 BE  (.
        eor     $FCE1,x                         ; 9BB9 5D E1 FC ]..
        and     #$7F                            ; 9BBC 29 7F    ).
        bne     L9B92                           ; 9BBE D0 D2    ..
        iny                                     ; 9BC0 C8       .
        inx                                     ; 9BC1 E8       .
        inx                                     ; 9BC2 E8       .
        dec     $B3                             ; 9BC3 C6 B3    ..
        bne     L9BB1                           ; 9BC5 D0 EA    ..
        ldy     $B4                             ; 9BC7 A4 B4    ..
        rts                                     ; 9BC9 60       `

; ----------------------------------------------------------------------------
        jsr     select_ram_page_001             ; 9BCA 20 28 BE  (.
        cpy     #$00                            ; 9BCD C0 00    ..
        beq     L9BE2                           ; 9BCF F0 11    ..
        jsr     push_registers_and_tuck_restoration_thunk; 9BD1 20 AB A8 ..
        cmp     #$FF                            ; 9BD4 C9 FF    ..
        beq     L9C14                           ; 9BD6 F0 3C    .<
        cmp     #$03                            ; 9BD8 C9 03    ..
        bcs     L9BF3                           ; 9BDA B0 17    ..
        lsr     a                               ; 9BDC 4A       J
        bcc     L9C20                           ; 9BDD 90 41    .A
        jmp     L9C40                           ; 9BDF 4C 40 9C L@.

; ----------------------------------------------------------------------------
L9BE2:  jsr     LA8D4                           ; 9BE2 20 D4 A8  ..
        tay                                     ; 9BE5 A8       .
        iny                                     ; 9BE6 C8       .
        cpy     #$03                            ; 9BE7 C0 03    ..
        bcs     L9BF3                           ; 9BE9 B0 08    ..
        lda     LAE75,y                         ; 9BEB B9 75 AE .u.
        pha                                     ; 9BEE 48       H
        lda     LAE72,y                         ; 9BEF B9 72 AE .r.
        pha                                     ; 9BF2 48       H
L9BF3:  rts                                     ; 9BF3 60       `

; ----------------------------------------------------------------------------
        lda     #$04                            ; 9BF4 A9 04    ..
        rts                                     ; 9BF6 60       `

; ----------------------------------------------------------------------------
        lda     #$FF                            ; 9BF7 A9 FF    ..
        sta     $02,x                           ; 9BF9 95 02    ..
        sta     $03,x                           ; 9BFB 95 03    ..
        .byte   $AD                             ; 9BFD AD       .
L9BFE:  .byte   $E2                             ; 9BFE E2       .
        sbc     a:$95,x                         ; 9BFF FD 95 00 ...
        .byte   $AD                             ; 9C02 AD       .
L9C03:  .byte   $E3                             ; 9C03 E3       .
        sbc     $0195,x                         ; 9C04 FD 95 01 ...
        lda     #$00                            ; 9C07 A9 00    ..
        rts                                     ; 9C09 60       `

; ----------------------------------------------------------------------------
        lda     $FDCE                           ; 9C0A AD CE FD ...
        pha                                     ; 9C0D 48       H
        jsr     L99DF                           ; 9C0E 20 DF 99  ..
        jmp     L9C1B                           ; 9C11 4C 1B 9C L..

; ----------------------------------------------------------------------------
L9C14:  lda     $FDCE                           ; 9C14 AD CE FD ...
        pha                                     ; 9C17 48       H
        jsr     L99D0                           ; 9C18 20 D0 99  ..
L9C1B:  pla                                     ; 9C1B 68       h
        sta     $FDCE                           ; 9C1C 8D CE FD ...
        rts                                     ; 9C1F 60       `

; ----------------------------------------------------------------------------
L9C20:  jsr     push_registers_and_tuck_restoration_thunk; 9C20 20 AB A8 ..
        jsr     L9D03                           ; 9C23 20 03 9D  ..
        asl     a                               ; 9C26 0A       .
        asl     a                               ; 9C27 0A       .
        adc     $FDD0                           ; 9C28 6D D0 FD m..
        tay                                     ; 9C2B A8       .
        lda     $FCF1,y                         ; 9C2C B9 F1 FC ...
        sta     $00,x                           ; 9C2F 95 00    ..
        lda     $FCF2,y                         ; 9C31 B9 F2 FC ...
        sta     $01,x                           ; 9C34 95 01    ..
        lda     $FCF3,y                         ; 9C36 B9 F3 FC ...
        sta     $02,x                           ; 9C39 95 02    ..
        lda     #$00                            ; 9C3B A9 00    ..
        sta     $03,x                           ; 9C3D 95 03    ..
        rts                                     ; 9C3F 60       `

; ----------------------------------------------------------------------------
L9C40:  jsr     push_registers_and_tuck_restoration_thunk; 9C40 20 AB A8 ..
        jsr     L9D03                           ; 9C43 20 03 9D  ..
        sec                                     ; 9C46 38       8
        lda     $FCFD,y                         ; 9C47 B9 FD FC ...
        sbc     $FCF0,y                         ; 9C4A F9 F0 FC ...
        sta     $B0                             ; 9C4D 85 B0    ..
        lda     ram_paging_msb,y                ; 9C4F B9 FE FC ...
        sbc     $FCEE,y                         ; 9C52 F9 EE FC ...
        and     #$03                            ; 9C55 29 03    ).
        cmp     $02,x                           ; 9C57 D5 02    ..
        bne     L9C61                           ; 9C59 D0 06    ..
        lda     $B0                             ; 9C5B A5 B0    ..
        cmp     $01,x                           ; 9C5D D5 01    ..
        beq     L9C6C                           ; 9C5F F0 0B    ..
L9C61:  jsr     LABD3                           ; 9C61 20 D3 AB  ..
        jsr     L9DA7                           ; 9C64 20 A7 9D  ..
        lda     #$6F                            ; 9C67 A9 6F    .o
        jsr     L9D9F                           ; 9C69 20 9F 9D  ..
L9C6C:  jsr     L9F1F                           ; 9C6C 20 1F 9F  ..
        bcs     L9CCC                           ; 9C6F B0 5B    .[
        lda     $01,x                           ; 9C71 B5 01    ..
        cmp     $FCF6,y                         ; 9C73 D9 F6 FC ...
        bne     L9C7F                           ; 9C76 D0 07    ..
        lda     $02,x                           ; 9C78 B5 02    ..
        cmp     $FCF7,y                         ; 9C7A D9 F7 FC ...
        beq     L9CB0                           ; 9C7D F0 31    .1
L9C7F:  clc                                     ; 9C7F 18       .
        lda     $00,x                           ; 9C80 B5 00    ..
        adc     #$FF                            ; 9C82 69 FF    i.
        lda     $01,x                           ; 9C84 B5 01    ..
        adc     #$00                            ; 9C86 69 00    i.
        sta     $C4                             ; 9C88 85 C4    ..
        lda     $02,x                           ; 9C8A B5 02    ..
        adc     #$00                            ; 9C8C 69 00    i.
        sta     $C5                             ; 9C8E 85 C5    ..
        txa                                     ; 9C90 8A       .
        pha                                     ; 9C91 48       H
        jsr     L9992                           ; 9C92 20 92 99  ..
        jsr     L9ED6                           ; 9C95 20 D6 9E  ..
        sec                                     ; 9C98 38       8
        lda     $C4                             ; 9C99 A5 C4    ..
        sbc     L00C0                           ; 9C9B E5 C0    ..
        sta     $C2                             ; 9C9D 85 C2    ..
        lda     $C5                             ; 9C9F A5 C5    ..
        sbc     $C1                             ; 9CA1 E5 C1    ..
        sta     $C3                             ; 9CA3 85 C3    ..
        bcc     L9CAE                           ; 9CA5 90 07    ..
        ora     $C2                             ; 9CA7 05 C2    ..
        beq     L9CAE                           ; 9CA9 F0 03    ..
        jsr     L9F2F                           ; 9CAB 20 2F 9F  /.
L9CAE:  pla                                     ; 9CAE 68       h
        tax                                     ; 9CAF AA       .
L9CB0:  lda     $FCF5,y                         ; 9CB0 B9 F5 FC ...
        sta     $FCF1,y                         ; 9CB3 99 F1 FC ...
        lda     $FCF6,y                         ; 9CB6 B9 F6 FC ...
        sta     $FCF2,y                         ; 9CB9 99 F2 FC ...
        lda     $FCF7,y                         ; 9CBC B9 F7 FC ...
        sta     $FCF3,y                         ; 9CBF 99 F3 FC ...
L9CC2:  lda     #$00                            ; 9CC2 A9 00    ..
        jsr     L9E00                           ; 9CC4 20 00 9E  ..
        jsr     L9F1F                           ; 9CC7 20 1F 9F  ..
        bcc     L9CC2                           ; 9CCA 90 F6    ..
L9CCC:  lda     $00,x                           ; 9CCC B5 00    ..
        sta     $FCF1,y                         ; 9CCE 99 F1 FC ...
        lda     $01,x                           ; 9CD1 B5 01    ..
        sta     $FCF2,y                         ; 9CD3 99 F2 FC ...
        lda     $02,x                           ; 9CD6 B5 02    ..
        sta     $FCF3,y                         ; 9CD8 99 F3 FC ...
        rts                                     ; 9CDB 60       `

; ----------------------------------------------------------------------------
L9CDC:  pha                                     ; 9CDC 48       H
        tya                                     ; 9CDD 98       .
        and     #$E0                            ; 9CDE 29 E0    ).
        sta     $FDD0                           ; 9CE0 8D D0 FD ...
        beq     L9CF6                           ; 9CE3 F0 11    ..
        lsr     a                               ; 9CE5 4A       J
        lsr     a                               ; 9CE6 4A       J
        lsr     a                               ; 9CE7 4A       J
        lsr     a                               ; 9CE8 4A       J
        lsr     a                               ; 9CE9 4A       J
        tay                                     ; 9CEA A8       .
        lda     L9CFD,y                         ; 9CEB B9 FD 9C ...
        ldy     $FDD0                           ; 9CEE AC D0 FD ...
        bit     $FDCE                           ; 9CF1 2C CE FD ,..
        bne     L9CF7                           ; 9CF4 D0 01    ..
L9CF6:  sec                                     ; 9CF6 38       8
L9CF7:  pla                                     ; 9CF7 68       h
        rts                                     ; 9CF8 60       `

; ----------------------------------------------------------------------------
L9CF9:  jsr     L6040                           ; 9CF9 20 40 60  @`
        .byte   $80                             ; 9CFC 80       .
L9CFD:  .byte   $A0                             ; 9CFD A0       .
L9CFE:  .byte   $80                             ; 9CFE 80       .
        rti                                     ; 9CFF 40       @

; ----------------------------------------------------------------------------
        jsr     L0810                           ; 9D00 20 10 08  ..
L9D03:  pha                                     ; 9D03 48       H
        jsr     L9D17                           ; 9D04 20 17 9D  ..
        sta     $FDD0                           ; 9D07 8D D0 FD ...
        lda     L9CFE,y                         ; 9D0A B9 FE 9C ...
        ldy     $FDD0                           ; 9D0D AC D0 FD ...
        bit     $FDCE                           ; 9D10 2C CE FD ,..
        beq     L9D25                           ; 9D13 F0 10    ..
        pla                                     ; 9D15 68       h
        rts                                     ; 9D16 60       `

; ----------------------------------------------------------------------------
L9D17:  tya                                     ; 9D17 98       .
        cmp     #$16                            ; 9D18 C9 16    ..
        bcs     L9D25                           ; 9D1A B0 09    ..
        sbc     #$10                            ; 9D1C E9 10    ..
        bcc     L9D25                           ; 9D1E 90 05    ..
        tay                                     ; 9D20 A8       .
        lda     L9CF9,y                         ; 9D21 B9 F9 9C ...
        rts                                     ; 9D24 60       `

; ----------------------------------------------------------------------------
L9D25:  jsr     LA90D                           ; 9D25 20 0D A9  ..
        .byte   $DE                             ; 9D28 DE       .
        .byte   "Channel"                       ; 9D29 43 68 61 6E 6E 65 6CChannel
        .byte   $00                             ; 9D30 00       .
; ----------------------------------------------------------------------------
L9D31:  jsr     LA90D                           ; 9D31 20 0D A9  ..
        .byte   $DF                             ; 9D34 DF       .
        .byte   "EOF"                           ; 9D35 45 4F 46 EOF
        .byte   $00                             ; 9D38 00       .
; ----------------------------------------------------------------------------
L9D39:  jsr     select_ram_page_001             ; 9D39 20 28 BE  (.
        stx     $FDC4                           ; 9D3C 8E C4 FD ...
        sty     $FDC5                           ; 9D3F 8C C5 FD ...
        jsr     L9D03                           ; 9D42 20 03 9D  ..
        tya                                     ; 9D45 98       .
        jsr     L9F07                           ; 9D46 20 07 9F  ..
        bne     L9D5C                           ; 9D49 D0 11    ..
        lda     fdc_status_or_cmd,y             ; 9D4B B9 F8 FC ...
        and     #$10                            ; 9D4E 29 10    ).
        bne     L9D31                           ; 9D50 D0 DF    ..
        lda     #$10                            ; 9D52 A9 10    ..
        jsr     L9D98                           ; 9D54 20 98 9D  ..
        lda     #$FE                            ; 9D57 A9 FE    ..
        sec                                     ; 9D59 38       8
        bcs     L9D74                           ; 9D5A B0 18    ..
L9D5C:  lda     fdc_status_or_cmd,y             ; 9D5C B9 F8 FC ...
        bmi     L9D6B                           ; 9D5F 30 0A    0.
        jsr     LABD3                           ; 9D61 20 D3 AB  ..
        jsr     L9DAA                           ; 9D64 20 AA 9D  ..
        sec                                     ; 9D67 38       8
        jsr     L9DB2                           ; 9D68 20 B2 9D  ..
L9D6B:  jsr     L9EC1                           ; 9D6B 20 C1 9E  ..
        lda     $FD00,x                         ; 9D6E BD 00 FD ...
        jsr     select_ram_page_001             ; 9D71 20 28 BE  (.
L9D74:  ldx     $FDC4                           ; 9D74 AE C4 FD ...
        ldy     $FDC5                           ; 9D77 AC C5 FD ...
        pha                                     ; 9D7A 48       H
        pla                                     ; 9D7B 68       h
        rts                                     ; 9D7C 60       `

; ----------------------------------------------------------------------------
L9D7D:  clc                                     ; 9D7D 18       .
        lda     $FCF0,y                         ; 9D7E B9 F0 FC ...
        adc     $FCF2,y                         ; 9D81 79 F2 FC y..
        sta     $C5                             ; 9D84 85 C5    ..
        sta     $FCFD,y                         ; 9D86 99 FD FC ...
        lda     $FCEE,y                         ; 9D89 B9 EE FC ...
        and     #$03                            ; 9D8C 29 03    ).
        adc     $FCF3,y                         ; 9D8E 79 F3 FC y..
        sta     $C4                             ; 9D91 85 C4    ..
        sta     ram_paging_msb,y                ; 9D93 99 FE FC ...
        lda     #$80                            ; 9D96 A9 80    ..
L9D98:  ora     fdc_status_or_cmd,y             ; 9D98 19 F8 FC ...
        bne     L9DA2                           ; 9D9B D0 05    ..
L9D9D:  lda     #$7F                            ; 9D9D A9 7F    ..
L9D9F:  and     fdc_status_or_cmd,y             ; 9D9F 39 F8 FC 9..
L9DA2:  sta     fdc_status_or_cmd,y             ; 9DA2 99 F8 FC ...
        clc                                     ; 9DA5 18       .
        rts                                     ; 9DA6 60       `

; ----------------------------------------------------------------------------
L9DA7:  jsr     push_registers_and_tuck_restoration_thunk; 9DA7 20 AB A8 ..
L9DAA:  lda     fdc_status_or_cmd,y             ; 9DAA B9 F8 FC ...
        and     #$40                            ; 9DAD 29 40    )@
        beq     L9DEE                           ; 9DAF F0 3D    .=
        clc                                     ; 9DB1 18       .
L9DB2:  php                                     ; 9DB2 08       .
        jsr     select_ram_page_001             ; 9DB3 20 28 BE  (.
        ldy     $FDD0                           ; 9DB6 AC D0 FD ...
        tya                                     ; 9DB9 98       .
        lsr     a                               ; 9DBA 4A       J
        lsr     a                               ; 9DBB 4A       J
        lsr     a                               ; 9DBC 4A       J
        lsr     a                               ; 9DBD 4A       J
        lsr     a                               ; 9DBE 4A       J
        adc     #$03                            ; 9DBF 69 03    i.
        sta     $BE                             ; 9DC1 85 BE    ..
        lda     #$00                            ; 9DC3 A9 00    ..
        sta     $BF                             ; 9DC5 85 BF    ..
        sta     $C2                             ; 9DC7 85 C2    ..
        lda     #$01                            ; 9DC9 A9 01    ..
        sta     $C3                             ; 9DCB 85 C3    ..
        plp                                     ; 9DCD 28       (
        bcs     L9DE5                           ; 9DCE B0 15    ..
        lda     $FCFD,y                         ; 9DD0 B9 FD FC ...
        sta     $C5                             ; 9DD3 85 C5    ..
        lda     ram_paging_msb,y                ; 9DD5 B9 FE FC ...
        sta     $C4                             ; 9DD8 85 C4    ..
        jsr     L9789                           ; 9DDA 20 89 97  ..
        ldy     $FDD0                           ; 9DDD AC D0 FD ...
        lda     #$BF                            ; 9DE0 A9 BF    ..
        jmp     L9D9F                           ; 9DE2 4C 9F 9D L..

; ----------------------------------------------------------------------------
L9DE5:  jsr     L9D7D                           ; 9DE5 20 7D 9D  }.
        jsr     L978C                           ; 9DE8 20 8C 97  ..
        ldy     $FDD0                           ; 9DEB AC D0 FD ...
L9DEE:  rts                                     ; 9DEE 60       `

; ----------------------------------------------------------------------------
L9DEF:  jmp     LA2FF                           ; 9DEF 4C FF A2 L..

; ----------------------------------------------------------------------------
L9DF2:  jsr     LA905                           ; 9DF2 20 05 A9  ..
        .byte   $C1                             ; 9DF5 C1       .
        .byte   "read only"                     ; 9DF6 72 65 61 64 20 6F 6E 6Cread onl
                                                ; 9DFE 79       y
        .byte   $00                             ; 9DFF 00       .
; ----------------------------------------------------------------------------
L9E00:  jsr     push_registers_and_tuck_restoration_thunk; 9E00 20 AB A8 ..
        jmp     L9E15                           ; 9E03 4C 15 9E L..

; ----------------------------------------------------------------------------
L9E06:  jsr     select_ram_page_001             ; 9E06 20 28 BE  (.
        sta     $FDC3                           ; 9E09 8D C3 FD ...
        stx     $FDC4                           ; 9E0C 8E C4 FD ...
        sty     $FDC5                           ; 9E0F 8C C5 FD ...
        jsr     L9D03                           ; 9E12 20 03 9D  ..
L9E15:  pha                                     ; 9E15 48       H
        lda     $FCED,y                         ; 9E16 B9 ED FC ...
        bmi     L9DF2                           ; 9E19 30 D7    0.
        lda     $FCEF,y                         ; 9E1B B9 EF FC ...
        bmi     L9DEF                           ; 9E1E 30 CF    0.
        jsr     LABD3                           ; 9E20 20 D3 AB  ..
        tya                                     ; 9E23 98       .
        clc                                     ; 9E24 18       .
        adc     #$04                            ; 9E25 69 04    i.
        jsr     L9F07                           ; 9E27 20 07 9F  ..
        bne     L9E6F                           ; 9E2A D0 43    .C
        jsr     L9992                           ; 9E2C 20 92 99  ..
L9E2F:  jsr     L9ED6                           ; 9E2F 20 D6 9E  ..
        lda     $C1                             ; 9E32 A5 C1    ..
        cmp     fdc_data,y                      ; 9E34 D9 FB FC ...
        bne     L9E4D                           ; 9E37 D0 14    ..
        lda     L00C0                           ; 9E39 A5 C0    ..
        cmp     fdc_sector,y                    ; 9E3B D9 FA FC ...
        bne     L9E5B                           ; 9E3E D0 1B    ..
        lda     #$01                            ; 9E40 A9 01    ..
        sta     $C2                             ; 9E42 85 C2    ..
        lda     #$00                            ; 9E44 A9 00    ..
        sta     $C3                             ; 9E46 85 C3    ..
        jsr     L9F2F                           ; 9E48 20 2F 9F  /.
        bcc     L9E2F                           ; 9E4B 90 E2    ..
L9E4D:  clc                                     ; 9E4D 18       .
        lda     fdc_data,y                      ; 9E4E B9 FB FC ...
        adc     #$01                            ; 9E51 69 01    i.
        sta     fdc_data,y                      ; 9E53 99 FB FC ...
        jsr     L92A1                           ; 9E56 20 A1 92  ..
        lda     #$00                            ; 9E59 A9 00    ..
L9E5B:  sta     fdc_sector,y                    ; 9E5B 99 FA FC ...
        jsr     select_ram_page_003             ; 9E5E 20 32 BE  2.
        sta     $FD0D,x                         ; 9E61 9D 0D FD ...
        lda     #$00                            ; 9E64 A9 00    ..
        sta     $FD0C,x                         ; 9E66 9D 0C FD ...
        jsr     L9677                           ; 9E69 20 77 96  w.
        ldy     $FDD0                           ; 9E6C AC D0 FD ...
L9E6F:  lda     fdc_status_or_cmd,y             ; 9E6F B9 F8 FC ...
        bmi     L9E8B                           ; 9E72 30 17    0.
        jsr     L9DAA                           ; 9E74 20 AA 9D  ..
        lda     $FCF5,y                         ; 9E77 B9 F5 FC ...
        bne     L9E87                           ; 9E7A D0 0B    ..
        tya                                     ; 9E7C 98       .
        jsr     L9F07                           ; 9E7D 20 07 9F  ..
        bne     L9E87                           ; 9E80 D0 05    ..
        jsr     L9D7D                           ; 9E82 20 7D 9D  }.
        bne     L9E8B                           ; 9E85 D0 04    ..
L9E87:  sec                                     ; 9E87 38       8
        jsr     L9DB2                           ; 9E88 20 B2 9D  ..
L9E8B:  jsr     L9EC1                           ; 9E8B 20 C1 9E  ..
        pla                                     ; 9E8E 68       h
        sta     $FD00,x                         ; 9E8F 9D 00 FD ...
        jsr     select_ram_page_001             ; 9E92 20 28 BE  (.
        lda     #$40                            ; 9E95 A9 40    .@
        jsr     L9D98                           ; 9E97 20 98 9D  ..
        tya                                     ; 9E9A 98       .
        jsr     L9F07                           ; 9E9B 20 07 9F  ..
        bcc     L9EB7                           ; 9E9E 90 17    ..
        lda     #$20                            ; 9EA0 A9 20    . 
        jsr     L9D98                           ; 9EA2 20 98 9D  ..
        lda     $FCF1,y                         ; 9EA5 B9 F1 FC ...
        sta     $FCF5,y                         ; 9EA8 99 F5 FC ...
        lda     $FCF2,y                         ; 9EAB B9 F2 FC ...
        sta     $FCF6,y                         ; 9EAE 99 F6 FC ...
        lda     $FCF3,y                         ; 9EB1 B9 F3 FC ...
        sta     $FCF7,y                         ; 9EB4 99 F7 FC ...
L9EB7:  lda     $FDC3                           ; 9EB7 AD C3 FD ...
        ldx     $FDC4                           ; 9EBA AE C4 FD ...
        ldy     $FDC5                           ; 9EBD AC C5 FD ...
        rts                                     ; 9EC0 60       `

; ----------------------------------------------------------------------------
L9EC1:  lda     $FCF1,y                         ; 9EC1 B9 F1 FC ...
        pha                                     ; 9EC4 48       H
        jsr     L9EF5                           ; 9EC5 20 F5 9E  ..
        tya                                     ; 9EC8 98       .
        lsr     a                               ; 9EC9 4A       J
        lsr     a                               ; 9ECA 4A       J
        lsr     a                               ; 9ECB 4A       J
        lsr     a                               ; 9ECC 4A       J
        lsr     a                               ; 9ECD 4A       J
        adc     #$03                            ; 9ECE 69 03    i.
        jsr     LBE39                           ; 9ED0 20 39 BE  9.
        pla                                     ; 9ED3 68       h
        tax                                     ; 9ED4 AA       .
        rts                                     ; 9ED5 60       `

; ----------------------------------------------------------------------------
L9ED6:  jsr     select_ram_page_001             ; 9ED6 20 28 BE  (.
        ldx     $FDD2                           ; 9ED9 AE D2 FD ...
        jsr     select_ram_page_003             ; 9EDC 20 32 BE  2.
        sec                                     ; 9EDF 38       8
        lda     $FD07,x                         ; 9EE0 BD 07 FD ...
        sbc     $FD0F,x                         ; 9EE3 FD 0F FD ...
        sta     L00C0                           ; 9EE6 85 C0    ..
        lda     $FD06,x                         ; 9EE8 BD 06 FD ...
        sbc     $FD0E,x                         ; 9EEB FD 0E FD ...
        and     #$03                            ; 9EEE 29 03    ).
        sta     $C1                             ; 9EF0 85 C1    ..
        jmp     select_ram_page_001             ; 9EF2 4C 28 BE L(.

; ----------------------------------------------------------------------------
L9EF5:  tya                                     ; 9EF5 98       .
        tax                                     ; 9EF6 AA       .
        inc     $FCF1,x                         ; 9EF7 FE F1 FC ...
        bne     L9F1E                           ; 9EFA D0 22    ."
        inc     $FCF2,x                         ; 9EFC FE F2 FC ...
        bne     L9F04                           ; 9EFF D0 03    ..
        inc     $FCF3,x                         ; 9F01 FE F3 FC ...
L9F04:  jmp     L9D9D                           ; 9F04 4C 9D 9D L..

; ----------------------------------------------------------------------------
L9F07:  tax                                     ; 9F07 AA       .
        lda     $FCF3,y                         ; 9F08 B9 F3 FC ...
        cmp     $FCF7,x                         ; 9F0B DD F7 FC ...
        bne     L9F1E                           ; 9F0E D0 0E    ..
        lda     $FCF2,y                         ; 9F10 B9 F2 FC ...
        cmp     $FCF6,x                         ; 9F13 DD F6 FC ...
        bne     L9F1E                           ; 9F16 D0 06    ..
        lda     $FCF1,y                         ; 9F18 B9 F1 FC ...
        cmp     $FCF5,x                         ; 9F1B DD F5 FC ...
L9F1E:  rts                                     ; 9F1E 60       `

; ----------------------------------------------------------------------------
L9F1F:  lda     $FCF5,y                         ; 9F1F B9 F5 FC ...
        cmp     $00,x                           ; 9F22 D5 00    ..
        lda     $FCF6,y                         ; 9F24 B9 F6 FC ...
        sbc     $01,x                           ; 9F27 F5 01    ..
        lda     $FCF7,y                         ; 9F29 B9 F7 FC ...
        sbc     $02,x                           ; 9F2C F5 02    ..
        rts                                     ; 9F2E 60       `

; ----------------------------------------------------------------------------
L9F2F:  jsr     push_registers_and_tuck_restoration_thunk; 9F2F 20 AB A8 ..
        stx     $A9                             ; 9F32 86 A9    ..
        jsr     select_ram_page_003             ; 9F34 20 32 BE  2.
        lda     $FD05                           ; 9F37 AD 05 FD ...
        sta     L00AA                           ; 9F3A 85 AA    ..
        jsr     LA0B5                           ; 9F3C 20 B5 A0  ..
        tsx                                     ; 9F3F BA       .
        stx     $B2                             ; 9F40 86 B2    ..
        jsr     LA130                           ; 9F42 20 30 A1  0.
        bcs     L9F4A                           ; 9F45 B0 03    ..
        jmp     L9462                           ; 9F47 4C 62 94 Lb.

; ----------------------------------------------------------------------------
L9F4A:  jsr     LA12B                           ; 9F4A 20 2B A1  +.
        bcc     L9F64                           ; 9F4D 90 15    ..
        sec                                     ; 9F4F 38       8
        lda     $CA                             ; 9F50 A5 CA    ..
        sbc     $C8                             ; 9F52 E5 C8    ..
        sta     $CA                             ; 9F54 85 CA    ..
        lda     $CB                             ; 9F56 A5 CB    ..
        sbc     $C9                             ; 9F58 E5 C9    ..
        sta     $CB                             ; 9F5A 85 CB    ..
        lda     #$00                            ; 9F5C A9 00    ..
        sta     $CC                             ; 9F5E 85 CC    ..
        sta     $CD                             ; 9F60 85 CD    ..
        beq     L9F71                           ; 9F62 F0 0D    ..
L9F64:  sec                                     ; 9F64 38       8
        lda     #$00                            ; 9F65 A9 00    ..
        sbc     $C8                             ; 9F67 E5 C8    ..
        sta     $CC                             ; 9F69 85 CC    ..
        lda     #$00                            ; 9F6B A9 00    ..
        sbc     $C9                             ; 9F6D E5 C9    ..
        sta     $CD                             ; 9F6F 85 CD    ..
L9F71:  lda     $C6                             ; 9F71 A5 C6    ..
        ora     $C7                             ; 9F73 05 C7    ..
        beq     L9FA7                           ; 9F75 F0 30    .0
L9F77:  clc                                     ; 9F77 18       .
        lda     $0108,y                         ; 9F78 B9 08 01 ...
        sta     $C6                             ; 9F7B 85 C6    ..
        adc     $0106,y                         ; 9F7D 79 06 01 y..
        sta     $C8                             ; 9F80 85 C8    ..
        lda     $0107,y                         ; 9F82 B9 07 01 ...
        sta     $C7                             ; 9F85 85 C7    ..
        adc     $0105,y                         ; 9F87 79 05 01 y..
        sta     $C9                             ; 9F8A 85 C9    ..
        jsr     LA000                           ; 9F8C 20 00 A0  ..
        lda     $FDD0                           ; 9F8F AD D0 FD ...
        sta     $C3                             ; 9F92 85 C3    ..
        jsr     LA053                           ; 9F94 20 53 A0  S.
        lda     $CB                             ; 9F97 A5 CB    ..
        sta     $0105,y                         ; 9F99 99 05 01 ...
        lda     $CA                             ; 9F9C A5 CA    ..
        sta     $0106,y                         ; 9F9E 99 06 01 ...
        jsr     LAA0D                           ; 9FA1 20 0D AA  ..
        dex                                     ; 9FA4 CA       .
        bne     L9F77                           ; 9FA5 D0 D0    ..
L9FA7:  lda     $CC                             ; 9FA7 A5 CC    ..
        sta     $C2                             ; 9FA9 85 C2    ..
        lda     $CD                             ; 9FAB A5 CD    ..
        sta     $C3                             ; 9FAD 85 C3    ..
        ora     $C2                             ; 9FAF 05 C2    ..
        beq     L9FF5                           ; 9FB1 F0 42    .B
        jsr     LA15E                           ; 9FB3 20 5E A1  ^.
        clc                                     ; 9FB6 18       .
        lda     $0106,y                         ; 9FB7 B9 06 01 ...
        adc     $0108,y                         ; 9FBA 79 08 01 y..
        sta     $CA                             ; 9FBD 85 CA    ..
        lda     $0105,y                         ; 9FBF B9 05 01 ...
        adc     $0107,y                         ; 9FC2 79 07 01 y..
        sta     $CB                             ; 9FC5 85 CB    ..
L9FC7:  lda     $0104,y                         ; 9FC7 B9 04 01 ...
        sta     $C6                             ; 9FCA 85 C6    ..
        lda     $0103,y                         ; 9FCC B9 03 01 ...
        sta     $C7                             ; 9FCF 85 C7    ..
        lda     $0102,y                         ; 9FD1 B9 02 01 ...
        sta     $C8                             ; 9FD4 85 C8    ..
        lda     $0101,y                         ; 9FD6 B9 01 01 ...
        sta     $C9                             ; 9FD9 85 C9    ..
        lda     $CA                             ; 9FDB A5 CA    ..
        sta     $0102,y                         ; 9FDD 99 02 01 ...
        lda     $CB                             ; 9FE0 A5 CB    ..
        sta     $0101,y                         ; 9FE2 99 01 01 ...
        lda     #$00                            ; 9FE5 A9 00    ..
        sta     $C3                             ; 9FE7 85 C3    ..
        jsr     LA053                           ; 9FE9 20 53 A0  S.
        jsr     L88CE                           ; 9FEC 20 CE 88  ..
        jsr     LAA16                           ; 9FEF 20 16 AA  ..
        dex                                     ; 9FF2 CA       .
        bne     L9FC7                           ; 9FF3 D0 D2    ..
L9FF5:  jsr     L969E                           ; 9FF5 20 9E 96  ..
        jsr     LA0FC                           ; 9FF8 20 FC A0  ..
        jsr     L9677                           ; 9FFB 20 77 96  w.
        clc                                     ; 9FFE 18       .
        rts                                     ; 9FFF 60       `

; ----------------------------------------------------------------------------
LA000:  jsr     push_registers_and_tuck_restoration_thunk; A000 20 AB A8 ..
        lda     #$00                            ; A003 A9 00    ..
        sta     $BF                             ; A005 85 BF    ..
        sta     $C2                             ; A007 85 C2    ..
LA009:  ldy     $C6                             ; A009 A4 C6    ..
        cpy     #$02                            ; A00B C0 02    ..
        lda     $C7                             ; A00D A5 C7    ..
        sbc     #$00                            ; A00F E9 00    ..
        bcc     LA015                           ; A011 90 02    ..
        ldy     #$02                            ; A013 A0 02    ..
LA015:  sty     $C3                             ; A015 84 C3    ..
        sec                                     ; A017 38       8
        lda     $C8                             ; A018 A5 C8    ..
        sbc     $C3                             ; A01A E5 C3    ..
        sta     $C5                             ; A01C 85 C5    ..
        sta     $C8                             ; A01E 85 C8    ..
        lda     $C9                             ; A020 A5 C9    ..
        sbc     #$00                            ; A022 E9 00    ..
        sta     $C4                             ; A024 85 C4    ..
        sta     $C9                             ; A026 85 C9    ..
        lda     #$02                            ; A028 A9 02    ..
        sta     $BE                             ; A02A 85 BE    ..
        jsr     L960B                           ; A02C 20 0B 96  ..
        jsr     L978C                           ; A02F 20 8C 97  ..
        sec                                     ; A032 38       8
        lda     $CA                             ; A033 A5 CA    ..
        sbc     $C3                             ; A035 E5 C3    ..
        sta     $C5                             ; A037 85 C5    ..
        sta     $CA                             ; A039 85 CA    ..
        lda     $CB                             ; A03B A5 CB    ..
        sbc     #$00                            ; A03D E9 00    ..
        sta     $C4                             ; A03F 85 C4    ..
        sta     $CB                             ; A041 85 CB    ..
        lda     #$02                            ; A043 A9 02    ..
        sta     $BE                             ; A045 85 BE    ..
        jsr     L960B                           ; A047 20 0B 96  ..
        jsr     L9789                           ; A04A 20 89 97  ..
        jsr     L8965                           ; A04D 20 65 89  e.
        bne     LA009                           ; A050 D0 B7    ..
        rts                                     ; A052 60       `

; ----------------------------------------------------------------------------
LA053:  jsr     push_registers_and_tuck_restoration_thunk; A053 20 AB A8 ..
        ldx     #$00                            ; A056 A2 00    ..
        lda     $FDCE                           ; A058 AD CE FD ...
LA05B:  asl     a                               ; A05B 0A       .
        pha                                     ; A05C 48       H
        bcc     LA0AE                           ; A05D 90 4F    .O
        lda     L9CF9,x                         ; A05F BD F9 9C ...
        tay                                     ; A062 A8       .
        lda     $FD00,y                         ; A063 B9 00 FD ...
        jsr     LAB3B                           ; A066 20 3B AB  ;.
        sta     $C2                             ; A069 85 C2    ..
        jsr     LAB39                           ; A06B 20 39 AB  9.
        cmp     $C2                             ; A06E C5 C2    ..
        bne     LA0AE                           ; A070 D0 3C    .<
        lda     $FCEE,y                         ; A072 B9 EE FC ...
        and     #$03                            ; A075 29 03    ).
        cmp     $C9                             ; A077 C5 C9    ..
        bne     LA0AE                           ; A079 D0 33    .3
        lda     $FCF0,y                         ; A07B B9 F0 FC ...
        cmp     $C8                             ; A07E C5 C8    ..
        bne     LA0AE                           ; A080 D0 2C    .,
        cpy     $C3                             ; A082 C4 C3    ..
        beq     LA0AE                           ; A084 F0 28    .(
        lda     $CA                             ; A086 A5 CA    ..
        sta     $FCF0,y                         ; A088 99 F0 FC ...
        sbc     $C8                             ; A08B E5 C8    ..
        sta     $C2                             ; A08D 85 C2    ..
        lda     $CB                             ; A08F A5 CB    ..
        sbc     $C9                             ; A091 E5 C9    ..
        pha                                     ; A093 48       H
        lda     $FCEE,y                         ; A094 B9 EE FC ...
        and     #$FC                            ; A097 29 FC    ).
        ora     $CB                             ; A099 05 CB    ..
        sta     $FCEE,y                         ; A09B 99 EE FC ...
        clc                                     ; A09E 18       .
        lda     $C2                             ; A09F A5 C2    ..
        adc     $FCFD,y                         ; A0A1 79 FD FC y..
        sta     $FCFD,y                         ; A0A4 99 FD FC ...
        pla                                     ; A0A7 68       h
        adc     ram_paging_msb,y                ; A0A8 79 FE FC y..
        sta     ram_paging_msb,y                ; A0AB 99 FE FC ...
LA0AE:  pla                                     ; A0AE 68       h
        inx                                     ; A0AF E8       .
        cpx     #$05                            ; A0B0 E0 05    ..
        bne     LA05B                           ; A0B2 D0 A7    ..
        rts                                     ; A0B4 60       `

; ----------------------------------------------------------------------------
LA0B5:  pla                                     ; A0B5 68       h
        sta     L00AE                           ; A0B6 85 AE    ..
        pla                                     ; A0B8 68       h
        sta     $AF                             ; A0B9 85 AF    ..
        jsr     select_ram_page_003             ; A0BB 20 32 BE  2.
        ldy     $FD05                           ; A0BE AC 05 FD ...
        lda     #$00                            ; A0C1 A9 00    ..
        pha                                     ; A0C3 48       H
        pha                                     ; A0C4 48       H
        jsr     LA55A                           ; A0C5 20 5A A5  Z.
        pha                                     ; A0C8 48       H
        lda     #$00                            ; A0C9 A9 00    ..
        pha                                     ; A0CB 48       H
        jsr     select_ram_page_003             ; A0CC 20 32 BE  2.
LA0CF:  lda     $FD04,y                         ; A0CF B9 04 FD ...
        cmp     #$01                            ; A0D2 C9 01    ..
        lda     $FD05,y                         ; A0D4 B9 05 FD ...
        adc     #$00                            ; A0D7 69 00    i.
        pha                                     ; A0D9 48       H
        php                                     ; A0DA 08       .
        lda     $FD06,y                         ; A0DB B9 06 FD ...
        jsr     LA9F6                           ; A0DE 20 F6 A9  ..
        plp                                     ; A0E1 28       (
        adc     #$00                            ; A0E2 69 00    i.
        pha                                     ; A0E4 48       H
        lda     $FD07,y                         ; A0E5 B9 07 FD ...
        pha                                     ; A0E8 48       H
        lda     $FD06,y                         ; A0E9 B9 06 FD ...
        and     #$03                            ; A0EC 29 03    ).
        pha                                     ; A0EE 48       H
        jsr     LAA12                           ; A0EF 20 12 AA  ..
        cpy     #$F8                            ; A0F2 C0 F8    ..
        bne     LA0CF                           ; A0F4 D0 D9    ..
        jsr     select_ram_page_001             ; A0F6 20 28 BE  (.
        jmp     LA992                           ; A0F9 4C 92 A9 L..

; ----------------------------------------------------------------------------
LA0FC:  pla                                     ; A0FC 68       h
        sta     L00AE                           ; A0FD 85 AE    ..
        pla                                     ; A0FF 68       h
        sta     $AF                             ; A100 85 AF    ..
        jsr     select_ram_page_003             ; A102 20 32 BE  2.
        ldy     #$F8                            ; A105 A0 F8    ..
LA107:  jsr     LAA09                           ; A107 20 09 AA  ..
        pla                                     ; A10A 68       h
        eor     $FD06,y                         ; A10B 59 06 FD Y..
        and     #$03                            ; A10E 29 03    ).
        eor     $FD06,y                         ; A110 59 06 FD Y..
        sta     $FD06,y                         ; A113 99 06 FD ...
        pla                                     ; A116 68       h
        sta     $FD07,y                         ; A117 99 07 FD ...
        pla                                     ; A11A 68       h
        pla                                     ; A11B 68       h
        cpy     $FD05                           ; A11C CC 05 FD ...
        bne     LA107                           ; A11F D0 E6    ..
        pla                                     ; A121 68       h
        pla                                     ; A122 68       h
        pla                                     ; A123 68       h
        pla                                     ; A124 68       h
        jsr     select_ram_page_001             ; A125 20 28 BE  (.
        jmp     LA992                           ; A128 4C 92 A9 L..

; ----------------------------------------------------------------------------
LA12B:  lda     $A9                             ; A12B A5 A9    ..
        jmp     LA132                           ; A12D 4C 32 A1 L2.

; ----------------------------------------------------------------------------
LA130:  lda     L00AA                           ; A130 A5 AA    ..
LA132:  lsr     a                               ; A132 4A       J
        pha                                     ; A133 48       H
        clc                                     ; A134 18       .
        adc     $B2                             ; A135 65 B2    e.
        tay                                     ; A137 A8       .
        pla                                     ; A138 68       h
        lsr     a                               ; A139 4A       J
        lsr     a                               ; A13A 4A       J
        sta     $B0                             ; A13B 85 B0    ..
        inc     $B0                             ; A13D E6 B0    ..
        ldx     #$00                            ; A13F A2 00    ..
        stx     $C6                             ; A141 86 C6    ..
        stx     $C7                             ; A143 86 C7    ..
        beq     LA14B                           ; A145 F0 04    ..
LA147:  inx                                     ; A147 E8       .
        jsr     LAA16                           ; A148 20 16 AA  ..
LA14B:  jsr     LA18E                           ; A14B 20 8E A1  ..
        jsr     LA1A0                           ; A14E 20 A0 A1  ..
        jsr     LA1B4                           ; A151 20 B4 A1  ..
        jsr     LA1C2                           ; A154 20 C2 A1  ..
        bcs     LA15D                           ; A157 B0 04    ..
        dec     $B0                             ; A159 C6 B0    ..
        bne     LA147                           ; A15B D0 EA    ..
LA15D:  rts                                     ; A15D 60       `

; ----------------------------------------------------------------------------
LA15E:  lda     $A9                             ; A15E A5 A9    ..
        lsr     a                               ; A160 4A       J
        clc                                     ; A161 18       .
        adc     $B2                             ; A162 65 B2    e.
        tay                                     ; A164 A8       .
        sec                                     ; A165 38       8
        lda     L00AA                           ; A166 A5 AA    ..
        sbc     $A9                             ; A168 E5 A9    ..
        lsr     a                               ; A16A 4A       J
        lsr     a                               ; A16B 4A       J
        lsr     a                               ; A16C 4A       J
        sta     $B0                             ; A16D 85 B0    ..
        inc     $B0                             ; A16F E6 B0    ..
        ldx     #$00                            ; A171 A2 00    ..
        stx     $C6                             ; A173 86 C6    ..
        stx     $C7                             ; A175 86 C7    ..
LA177:  jsr     LAA0D                           ; A177 20 0D AA  ..
        inx                                     ; A17A E8       .
        jsr     LA18E                           ; A17B 20 8E A1  ..
        jsr     LA1A0                           ; A17E 20 A0 A1  ..
        jsr     LA1B4                           ; A181 20 B4 A1  ..
        jsr     LA1C2                           ; A184 20 C2 A1  ..
        bcs     LA18D                           ; A187 B0 04    ..
        dec     $B0                             ; A189 C6 B0    ..
        bne     LA177                           ; A18B D0 EA    ..
LA18D:  rts                                     ; A18D 60       `

; ----------------------------------------------------------------------------
LA18E:  clc                                     ; A18E 18       .
        lda     $0106,y                         ; A18F B9 06 01 ...
        adc     $0108,y                         ; A192 79 08 01 y..
        sta     $C4                             ; A195 85 C4    ..
        lda     $0105,y                         ; A197 B9 05 01 ...
        adc     $0107,y                         ; A19A 79 07 01 y..
        sta     $C5                             ; A19D 85 C5    ..
        rts                                     ; A19F 60       `

; ----------------------------------------------------------------------------
LA1A0:  sec                                     ; A1A0 38       8
        lda     $0102,y                         ; A1A1 B9 02 01 ...
        sta     $CA                             ; A1A4 85 CA    ..
        sbc     $C4                             ; A1A6 E5 C4    ..
        sta     $C4                             ; A1A8 85 C4    ..
        lda     $0101,y                         ; A1AA B9 01 01 ...
        sta     $CB                             ; A1AD 85 CB    ..
        sbc     $C5                             ; A1AF E5 C5    ..
        sta     $C5                             ; A1B1 85 C5    ..
        rts                                     ; A1B3 60       `

; ----------------------------------------------------------------------------
LA1B4:  clc                                     ; A1B4 18       .
        lda     $C6                             ; A1B5 A5 C6    ..
        adc     $C4                             ; A1B7 65 C4    e.
        sta     $C6                             ; A1B9 85 C6    ..
        lda     $C7                             ; A1BB A5 C7    ..
        adc     $C5                             ; A1BD 65 C5    e.
        sta     $C7                             ; A1BF 85 C7    ..
        rts                                     ; A1C1 60       `

; ----------------------------------------------------------------------------
LA1C2:  sec                                     ; A1C2 38       8
        lda     $C6                             ; A1C3 A5 C6    ..
        sbc     $C2                             ; A1C5 E5 C2    ..
        sta     $C8                             ; A1C7 85 C8    ..
        lda     $C7                             ; A1C9 A5 C7    ..
        sbc     $C3                             ; A1CB E5 C3    ..
        sta     $C9                             ; A1CD 85 C9    ..
        rts                                     ; A1CF 60       `

; ----------------------------------------------------------------------------
        jsr     LA8D4                           ; A1D0 20 D4 A8  ..
        jsr     select_ram_page_001             ; A1D3 20 28 BE  (.
        pha                                     ; A1D6 48       H
        jsr     L8AE3                           ; A1D7 20 E3 8A  ..
        stx     $B0                             ; A1DA 86 B0    ..
        stx     $FDE4                           ; A1DC 8E E4 FD ...
        sty     $B1                             ; A1DF 84 B1    ..
        sty     $FDE5                           ; A1E1 8C E5 FD ...
        ldx     #$00                            ; A1E4 A2 00    ..
        ldy     #$00                            ; A1E6 A0 00    ..
        jsr     L8983                           ; A1E8 20 83 89  ..
LA1EB:  jsr     L8973                           ; A1EB 20 73 89  s.
        cpy     #$12                            ; A1EE C0 12    ..
        bne     LA1EB                           ; A1F0 D0 F9    ..
        pla                                     ; A1F2 68       h
        tax                                     ; A1F3 AA       .
        inx                                     ; A1F4 E8       .
        cpx     #$08                            ; A1F5 E0 08    ..
        bcs     LA201                           ; A1F7 B0 08    ..
        lda     LAE80,x                         ; A1F9 BD 80 AE ...
        pha                                     ; A1FC 48       H
        lda     LAE78,x                         ; A1FD BD 78 AE .x.
LA200:  pha                                     ; A200 48       H
LA201:  rts                                     ; A201 60       `

; ----------------------------------------------------------------------------
        lda     #$00                            ; A202 A9 00    ..
        sta     L00A8                           ; A204 85 A8    ..
        jsr     L9426                           ; A206 20 26 94  &.
        jsr     LA333                           ; A209 20 33 A3  3.
        jsr     L8C97                           ; A20C 20 97 8C  ..
        jmp     L9766                           ; A20F 4C 66 97 Lf.

; ----------------------------------------------------------------------------
        jsr     LA2F2                           ; A212 20 F2 A2  ..
        jsr     LA28F                           ; A215 20 8F A2  ..
        jsr     LA2AE                           ; A218 20 AE A2  ..
        bvc     LA233                           ; A21B 50 16    P.
        jsr     LA2F2                           ; A21D 20 F2 A2  ..
        jsr     LA28F                           ; A220 20 8F A2  ..
        bvc     LA236                           ; A223 50 11    P.
        jsr     LA2F2                           ; A225 20 F2 A2  ..
        jsr     LA2AE                           ; A228 20 AE A2  ..
        bvc     LA236                           ; A22B 50 09    P.
        jsr     LA31F                           ; A22D 20 1F A3  ..
        jsr     LA30D                           ; A230 20 0D A3  ..
LA233:  jsr     LA2D6                           ; A233 20 D6 A2  ..
LA236:  jsr     L93CC                           ; A236 20 CC 93  ..
        lda     #$01                            ; A239 A9 01    ..
        rts                                     ; A23B 60       `

; ----------------------------------------------------------------------------
        jsr     LA31F                           ; A23C 20 1F A3  ..
        jsr     L8C97                           ; A23F 20 97 8C  ..
        lda     #$01                            ; A242 A9 01    ..
        rts                                     ; A244 60       `

; ----------------------------------------------------------------------------
        jsr     LA2F2                           ; A245 20 F2 A2  ..
        jsr     L8C97                           ; A248 20 97 8C  ..
        jsr     L8C18                           ; A24B 20 18 8C  ..
        jmp     LA236                           ; A24E 4C 36 A2 L6.

; ----------------------------------------------------------------------------
        jsr     L8AEF                           ; A251 20 EF 8A  ..
        jsr     LA333                           ; A254 20 33 A3  3.
        jsr     L8C97                           ; A257 20 97 8C  ..
LA25A:  sty     $BC                             ; A25A 84 BC    ..
        ldx     #$00                            ; A25C A2 00    ..
        lda     L00C0                           ; A25E A5 C0    ..
        bne     LA268                           ; A260 D0 06    ..
        iny                                     ; A262 C8       .
        iny                                     ; A263 C8       .
        ldx     #$02                            ; A264 A2 02    ..
        bne     LA276                           ; A266 D0 0E    ..
LA268:  jsr     select_ram_page_003             ; A268 20 32 BE  2.
        lda     $FD0E,y                         ; A26B B9 0E FD ...
        sta     $C4                             ; A26E 85 C4    ..
        jsr     select_ram_page_001             ; A270 20 28 BE  (.
        jsr     L95FC                           ; A273 20 FC 95  ..
LA276:  jsr     select_ram_page_003             ; A276 20 32 BE  2.
LA279:  lda     $FD08,y                         ; A279 B9 08 FD ...
        sta     $BE,x                           ; A27C 95 BE    ..
        iny                                     ; A27E C8       .
        inx                                     ; A27F E8       .
        cpx     #$08                            ; A280 E0 08    ..
        bne     LA279                           ; A282 D0 F5    ..
        jsr     L961B                           ; A284 20 1B 96  ..
        ldy     $BC                             ; A287 A4 BC    ..
        jsr     L8C3D                           ; A289 20 3D 8C  =.
        jmp     L976C                           ; A28C 4C 6C 97 Ll.

; ----------------------------------------------------------------------------
LA28F:  jsr     push_registers_and_tuck_restoration_thunk; A28F 20 AB A8 ..
        ldy     #$02                            ; A292 A0 02    ..
        lda     ($B0),y                         ; A294 B1 B0    ..
        jsr     select_ram_page_003             ; A296 20 32 BE  2.
        sta     $FD08,x                         ; A299 9D 08 FD ...
        iny                                     ; A29C C8       .
        lda     ($B0),y                         ; A29D B1 B0    ..
        sta     $FD09,x                         ; A29F 9D 09 FD ...
        iny                                     ; A2A2 C8       .
        lda     ($B0),y                         ; A2A3 B1 B0    ..
        asl     a                               ; A2A5 0A       .
        asl     a                               ; A2A6 0A       .
        eor     $FD0E,x                         ; A2A7 5D 0E FD ]..
        and     #$0C                            ; A2AA 29 0C    ).
        bpl     LA2CC                           ; A2AC 10 1E    ..
LA2AE:  jsr     push_registers_and_tuck_restoration_thunk; A2AE 20 AB A8 ..
        ldy     #$06                            ; A2B1 A0 06    ..
        lda     ($B0),y                         ; A2B3 B1 B0    ..
        jsr     select_ram_page_003             ; A2B5 20 32 BE  2.
        sta     $FD0A,x                         ; A2B8 9D 0A FD ...
        iny                                     ; A2BB C8       .
        lda     ($B0),y                         ; A2BC B1 B0    ..
        sta     $FD0B,x                         ; A2BE 9D 0B FD ...
        iny                                     ; A2C1 C8       .
        lda     ($B0),y                         ; A2C2 B1 B0    ..
        ror     a                               ; A2C4 6A       j
        ror     a                               ; A2C5 6A       j
        ror     a                               ; A2C6 6A       j
        eor     $FD0E,x                         ; A2C7 5D 0E FD ]..
        and     #$C0                            ; A2CA 29 C0    ).
LA2CC:  eor     $FD0E,x                         ; A2CC 5D 0E FD ]..
        sta     $FD0E,x                         ; A2CF 9D 0E FD ...
        clv                                     ; A2D2 B8       .
        jmp     select_ram_page_001             ; A2D3 4C 28 BE L(.

; ----------------------------------------------------------------------------
LA2D6:  jsr     push_registers_and_tuck_restoration_thunk; A2D6 20 AB A8 ..
        ldy     #$0E                            ; A2D9 A0 0E    ..
        lda     ($B0),y                         ; A2DB B1 B0    ..
        and     #$0A                            ; A2DD 29 0A    ).
        beq     LA2E3                           ; A2DF F0 02    ..
        lda     #$80                            ; A2E1 A9 80    ..
LA2E3:  jsr     select_ram_page_002             ; A2E3 20 2D BE  -.
        eor     $FD0F,x                         ; A2E6 5D 0F FD ]..
        and     #$80                            ; A2E9 29 80    ).
        eor     $FD0F,x                         ; A2EB 5D 0F FD ]..
        sta     $FD0F,x                         ; A2EE 9D 0F FD ...
        rts                                     ; A2F1 60       `

; ----------------------------------------------------------------------------
LA2F2:  jsr     LA329                           ; A2F2 20 29 A3  ).
        bcc     LA324                           ; A2F5 90 2D    .-
LA2F7:  jsr     select_ram_page_002             ; A2F7 20 2D BE  -.
        lda     $FD0F,y                         ; A2FA B9 0F FD ...
        bpl     LA328                           ; A2FD 10 29    .)
LA2FF:  jsr     LA905                           ; A2FF 20 05 A9  ..
        .byte   $C3                             ; A302 C3       .
        .byte   "locked"                        ; A303 6C 6F 63 6B 65 64locked
        .byte   $00                             ; A309 00       .
; ----------------------------------------------------------------------------
LA30A:  jsr     LA2F7                           ; A30A 20 F7 A2  ..
LA30D:  jsr     push_registers_and_tuck_restoration_thunk; A30D 20 AB A8 ..
        tya                                     ; A310 98       .
        pha                                     ; A311 48       H
        ldx     #$08                            ; A312 A2 08    ..
        ldy     #$FD                            ; A314 A0 FD    ..
        pla                                     ; A316 68       h
        jsr     L9B78                           ; A317 20 78 9B  x.
        bcc     LA328                           ; A31A 90 0C    ..
        jmp     L9A83                           ; A31C 4C 83 9A L..

; ----------------------------------------------------------------------------
LA31F:  jsr     LA329                           ; A31F 20 29 A3  ).
        bcs     LA328                           ; A322 B0 04    ..
LA324:  pla                                     ; A324 68       h
        pla                                     ; A325 68       h
        lda     #$00                            ; A326 A9 00    ..
LA328:  rts                                     ; A328 60       `

; ----------------------------------------------------------------------------
LA329:  jsr     L8993                           ; A329 20 93 89  ..
        jsr     L8BCE                           ; A32C 20 CE 8B  ..
        bcc     LA33D                           ; A32F 90 0C    ..
        tya                                     ; A331 98       .
        tax                                     ; A332 AA       .
LA333:  lda     $FDE4                           ; A333 AD E4 FD ...
        sta     $B0                             ; A336 85 B0    ..
        lda     $FDE5                           ; A338 AD E5 FD ...
        sta     $B1                             ; A33B 85 B1    ..
LA33D:  rts                                     ; A33D 60       `

; ----------------------------------------------------------------------------
        cmp     #$09                            ; A33E C9 09    ..
        bcs     LA33D                           ; A340 B0 FB    ..
        jsr     push_registers_and_tuck_restoration_thunk; A342 20 AB A8 ..
        jsr     select_ram_page_001             ; A345 20 28 BE  (.
        jsr     LA89E                           ; A348 20 9E A8  ..
        stx     $FDBE                           ; A34B 8E BE FD ...
        sty     $FDBF                           ; A34E 8C BF FD ...
        tay                                     ; A351 A8       .
        jsr     LA35B                           ; A352 20 5B A3  [.
        php                                     ; A355 08       .
        jsr     L975B                           ; A356 20 5B 97  [.
        plp                                     ; A359 28       (
        rts                                     ; A35A 60       `

; ----------------------------------------------------------------------------
LA35B:  lda     LAE88,y                         ; A35B B9 88 AE ...
        sta     LFDE0                           ; A35E 8D E0 FD ...
        lda     LAE91,y                         ; A361 B9 91 AE ...
        sta     $FDE1                           ; A364 8D E1 FD ...
        lda     LAE9A,y                         ; A367 B9 9A AE ...
        lsr     a                               ; A36A 4A       J
        php                                     ; A36B 08       .
        lsr     a                               ; A36C 4A       J
        php                                     ; A36D 08       .
        sta     $FDDA                           ; A36E 8D DA FD ...
        jsr     LA537                           ; A371 20 37 A5  7.
        ldy     #$0C                            ; A374 A0 0C    ..
LA376:  lda     ($B4),y                         ; A376 B1 B4    ..
        sta     $FDA1,y                         ; A378 99 A1 FD ...
        dey                                     ; A37B 88       .
        bpl     LA376                           ; A37C 10 F8    ..
        lda     $FDA4                           ; A37E AD A4 FD ...
        and     $FDA5                           ; A381 2D A5 FD -..
        ora     $FDCD                           ; A384 0D CD FD ...
        clc                                     ; A387 18       .
        adc     #$01                            ; A388 69 01    i.
        beq     LA392                           ; A38A F0 06    ..
        jsr     L9744                           ; A38C 20 44 97  D.
        clc                                     ; A38F 18       .
        lda     #$FF                            ; A390 A9 FF    ..
LA392:  sta     $FDDB                           ; A392 8D DB FD ...
        lda     $FDDA                           ; A395 AD DA FD ...
        bcs     LA3A1                           ; A398 B0 07    ..
        ldx     #$A2                            ; A39A A2 A2    ..
        ldy     #$FD                            ; A39C A0 FD    ..
        jsr     L0406                           ; A39E 20 06 04  ..
LA3A1:  plp                                     ; A3A1 28       (
        bcs     LA3A8                           ; A3A2 B0 04    ..
        plp                                     ; A3A4 28       (
LA3A5:  jmp     (LFDE0)                         ; A3A5 6C E0 FD l..

; ----------------------------------------------------------------------------
LA3A8:  ldx     #$03                            ; A3A8 A2 03    ..
LA3AA:  lda     $FDAA,x                         ; A3AA BD AA FD ...
        sta     $B6,x                           ; A3AD 95 B6    ..
        dex                                     ; A3AF CA       .
        bpl     LA3AA                           ; A3B0 10 F8    ..
        ldx     #$B6                            ; A3B2 A2 B6    ..
        ldy     $FDA1                           ; A3B4 AC A1 FD ...
        lda     #$00                            ; A3B7 A9 00    ..
        plp                                     ; A3B9 28       (
        bcs     LA3BF                           ; A3BA B0 03    ..
        jsr     L9C40                           ; A3BC 20 40 9C  @.
LA3BF:  jsr     L9C20                           ; A3BF 20 20 9C   .
        ldx     #$03                            ; A3C2 A2 03    ..
LA3C4:  lda     $B6,x                           ; A3C4 B5 B6    ..
        sta     $FDAA,x                         ; A3C6 9D AA FD ...
        dex                                     ; A3C9 CA       .
        bpl     LA3C4                           ; A3CA 10 F8    ..
LA3CC:  jsr     LA529                           ; A3CC 20 29 A5  ).
        bmi     LA3DE                           ; A3CF 30 0D    0.
LA3D1:  ldy     $FDA1                           ; A3D1 AC A1 FD ...
        jsr     LA3A5                           ; A3D4 20 A5 A3  ..
        bcs     LA3E6                           ; A3D7 B0 0D    ..
        ldx     #$09                            ; A3D9 A2 09    ..
        jsr     LA51D                           ; A3DB 20 1D A5  ..
LA3DE:  ldx     #$05                            ; A3DE A2 05    ..
        jsr     LA51D                           ; A3E0 20 1D A5  ..
        bne     LA3D1                           ; A3E3 D0 EC    ..
        clc                                     ; A3E5 18       .
LA3E6:  php                                     ; A3E6 08       .
        jsr     LA529                           ; A3E7 20 29 A5  ).
        ldx     #$05                            ; A3EA A2 05    ..
        jsr     LA51D                           ; A3EC 20 1D A5  ..
        ldy     #$0C                            ; A3EF A0 0C    ..
        jsr     LA537                           ; A3F1 20 37 A5  7.
LA3F4:  lda     $FDA1,y                         ; A3F4 B9 A1 FD ...
        sta     ($B4),y                         ; A3F7 91 B4    ..
        dey                                     ; A3F9 88       .
        bpl     LA3F4                           ; A3FA 10 F8    ..
        plp                                     ; A3FC 28       (
LA3FD:  rts                                     ; A3FD 60       `

; ----------------------------------------------------------------------------
        jsr     LA4CF                           ; A3FE 20 CF A4  ..
        jsr     L9E06                           ; A401 20 06 9E  ..
        clc                                     ; A404 18       .
        rts                                     ; A405 60       `

; ----------------------------------------------------------------------------
        jsr     L9D39                           ; A406 20 39 9D  9.
        bcs     LA3FD                           ; A409 B0 F2    ..
        jmp     LA506                           ; A40B 4C 06 A5 L..

; ----------------------------------------------------------------------------
        jsr     LAA7E                           ; A40E 20 7E AA  ~.
        jsr     L968B                           ; A411 20 8B 96  ..
        lda     #$0C                            ; A414 A9 0C    ..
        jsr     LA506                           ; A416 20 06 A5  ..
        ldy     #$00                            ; A419 A0 00    ..
LA41B:  jsr     select_ram_page_002             ; A41B 20 2D BE  -.
        lda     $FD00,y                         ; A41E B9 00 FD ...
        jsr     LA506                           ; A421 20 06 A5  ..
        iny                                     ; A424 C8       .
        cpy     #$08                            ; A425 C0 08    ..
        bne     LA41B                           ; A427 D0 F2    ..
LA429:  jsr     select_ram_page_003             ; A429 20 32 BE  2.
        lda     fdc_status_or_cmd,y             ; A42C B9 F8 FC ...
        jsr     LA506                           ; A42F 20 06 A5  ..
        iny                                     ; A432 C8       .
        cpy     #$0C                            ; A433 C0 0C    ..
        bne     LA429                           ; A435 D0 F2    ..
        jsr     select_ram_page_003             ; A437 20 32 BE  2.
        lda     $FD06                           ; A43A AD 06 FD ...
        jsr     LA9FE                           ; A43D 20 FE A9  ..
        jmp     LA506                           ; A440 4C 06 A5 L..

; ----------------------------------------------------------------------------
        lda     $FDC7                           ; A443 AD C7 FD ...
        jsr     LA4E2                           ; A446 20 E2 A4  ..
        jsr     LA504                           ; A449 20 04 A5  ..
        lda     $FDC6                           ; A44C AD C6 FD ...
        jmp     LA506                           ; A44F 4C 06 A5 L..

; ----------------------------------------------------------------------------
        lda     $FDC9                           ; A452 AD C9 FD ...
        jsr     LA4E2                           ; A455 20 E2 A4  ..
        jsr     LA504                           ; A458 20 04 A5  ..
        lda     $FDC8                           ; A45B AD C8 FD ...
        jmp     LA506                           ; A45E 4C 06 A5 L..

; ----------------------------------------------------------------------------
        jsr     LAA7E                           ; A461 20 7E AA  ~.
        jsr     L968B                           ; A464 20 8B 96  ..
        lda     #$74                            ; A467 A9 74    .t
        sta     LFDE0                           ; A469 8D E0 FD ...
        lda     #$A4                            ; A46C A9 A4    ..
        sta     $FDE1                           ; A46E 8D E1 FD ...
        jmp     LA3CC                           ; A471 4C CC A3 L..

; ----------------------------------------------------------------------------
        jsr     select_ram_page_001             ; A474 20 28 BE  (.
        ldy     $FDAA                           ; A477 AC AA FD ...
LA47A:  jsr     select_ram_page_003             ; A47A 20 32 BE  2.
        cpy     $FD05                           ; A47D CC 05 FD ...
        bcs     LA4B0                           ; A480 B0 2E    ..
        jsr     select_ram_page_002             ; A482 20 2D BE  -.
        lda     $FD0F,y                         ; A485 B9 0F FD ...
        jsr     LAA31                           ; A488 20 31 AA  1.
        eor     $CE                             ; A48B 45 CE    E.
        bcs     LA491                           ; A48D B0 02    ..
        and     #$DF                            ; A48F 29 DF    ).
LA491:  and     #$7F                            ; A491 29 7F    ).
        beq     LA49A                           ; A493 F0 05    ..
        jsr     LAA09                           ; A495 20 09 AA  ..
        bne     LA47A                           ; A498 D0 E0    ..
LA49A:  lda     #$07                            ; A49A A9 07    ..
        jsr     LA506                           ; A49C 20 06 A5  ..
        sta     $B0                             ; A49F 85 B0    ..
LA4A1:  jsr     select_ram_page_002             ; A4A1 20 2D BE  -.
        lda     $FD08,y                         ; A4A4 B9 08 FD ...
        jsr     LA506                           ; A4A7 20 06 A5  ..
        iny                                     ; A4AA C8       .
        dec     $B0                             ; A4AB C6 B0    ..
        bne     LA4A1                           ; A4AD D0 F2    ..
        clc                                     ; A4AF 18       .
LA4B0:  jsr     select_ram_page_003             ; A4B0 20 32 BE  2.
        lda     $FD04                           ; A4B3 AD 04 FD ...
        jsr     select_ram_page_001             ; A4B6 20 28 BE  (.
        sty     $FDAA                           ; A4B9 8C AA FD ...
        sta     $FDA1                           ; A4BC 8D A1 FD ...
        rts                                     ; A4BF 60       `

; ----------------------------------------------------------------------------
LA4C0:  pha                                     ; A4C0 48       H
        lda     $FDA2                           ; A4C1 AD A2 FD ...
        sta     $B8                             ; A4C4 85 B8    ..
        lda     $FDA3                           ; A4C6 AD A3 FD ...
        sta     $B9                             ; A4C9 85 B9    ..
        ldx     #$00                            ; A4CB A2 00    ..
        pla                                     ; A4CD 68       h
        rts                                     ; A4CE 60       `

; ----------------------------------------------------------------------------
LA4CF:  bit     $FDDB                           ; A4CF 2C DB FD ,..
        bpl     LA4DA                           ; A4D2 10 06    ..
        lda     $FEE5                           ; A4D4 AD E5 FE ...
        jmp     LA518                           ; A4D7 4C 18 A5 L..

; ----------------------------------------------------------------------------
LA4DA:  jsr     LA4C0                           ; A4DA 20 C0 A4  ..
        lda     ($B8,x)                         ; A4DD A1 B8    ..
        jmp     LA518                           ; A4DF 4C 18 A5 L..

; ----------------------------------------------------------------------------
LA4E2:  pha                                     ; A4E2 48       H
        ldy     #$01                            ; A4E3 A0 01    ..
        and     #$F0                            ; A4E5 29 F0    ).
        beq     LA4EA                           ; A4E7 F0 01    ..
        iny                                     ; A4E9 C8       .
LA4EA:  tya                                     ; A4EA 98       .
        jsr     LA506                           ; A4EB 20 06 A5  ..
        pla                                     ; A4EE 68       h
        pha                                     ; A4EF 48       H
        and     #$0F                            ; A4F0 29 0F    ).
        clc                                     ; A4F2 18       .
        adc     #$30                            ; A4F3 69 30    i0
        jsr     LA506                           ; A4F5 20 06 A5  ..
        pla                                     ; A4F8 68       h
        jsr     LA9FE                           ; A4F9 20 FE A9  ..
        beq     LA541                           ; A4FC F0 43    .C
        clc                                     ; A4FE 18       .
        adc     #$41                            ; A4FF 69 41    iA
        jmp     LA506                           ; A501 4C 06 A5 L..

; ----------------------------------------------------------------------------
LA504:  lda     #$01                            ; A504 A9 01    ..
LA506:  jsr     select_ram_page_001             ; A506 20 28 BE  (.
        bit     $FDDB                           ; A509 2C DB FD ,..
        bpl     LA513                           ; A50C 10 05    ..
        sta     $FEE5                           ; A50E 8D E5 FE ...
        bmi     LA518                           ; A511 30 05    0.
LA513:  jsr     LA4C0                           ; A513 20 C0 A4  ..
        sta     ($B8,x)                         ; A516 81 B8    ..
LA518:  jsr     push_registers_and_tuck_restoration_thunk; A518 20 AB A8 ..
        ldx     #$01                            ; A51B A2 01    ..
LA51D:  ldy     #$04                            ; A51D A0 04    ..
LA51F:  inc     $FDA1,x                         ; A51F FE A1 FD ...
        bne     LA528                           ; A522 D0 04    ..
        inx                                     ; A524 E8       .
        dey                                     ; A525 88       .
        bne     LA51F                           ; A526 D0 F7    ..
LA528:  rts                                     ; A528 60       `

; ----------------------------------------------------------------------------
LA529:  ldx     #$03                            ; A529 A2 03    ..
LA52B:  lda     #$FF                            ; A52B A9 FF    ..
        eor     $FDA6,x                         ; A52D 5D A6 FD ]..
        sta     $FDA6,x                         ; A530 9D A6 FD ...
        dex                                     ; A533 CA       .
        bpl     LA52B                           ; A534 10 F5    ..
        rts                                     ; A536 60       `

; ----------------------------------------------------------------------------
LA537:  lda     $FDBE                           ; A537 AD BE FD ...
        sta     $B4                             ; A53A 85 B4    ..
        lda     $FDBF                           ; A53C AD BF FD ...
        sta     $B5                             ; A53F 85 B5    ..
LA541:  rts                                     ; A541 60       `

; ----------------------------------------------------------------------------
LA542:  bit     $FDCC                           ; A542 2C CC FD ,..
        bmi     LA54A                           ; A545 30 03    0.
        sta     ($A6),y                         ; A547 91 A6    ..
        rts                                     ; A549 60       `

; ----------------------------------------------------------------------------
LA54A:  sta     $FEE5                           ; A54A 8D E5 FE ...
        rts                                     ; A54D 60       `

; ----------------------------------------------------------------------------
LA54E:  bit     $FDCC                           ; A54E 2C CC FD ,..
        bmi     LA556                           ; A551 30 03    0.
        lda     ($A6),y                         ; A553 B1 A6    ..
        rts                                     ; A555 60       `

; ----------------------------------------------------------------------------
LA556:  lda     $FEE5                           ; A556 AD E5 FE ...
        rts                                     ; A559 60       `

; ----------------------------------------------------------------------------
LA55A:  jsr     select_ram_page_001             ; A55A 20 28 BE  (.
        jsr     LB7B2                           ; A55D 20 B2 B7  ..
        beq     LA569                           ; A560 F0 07    ..
        lda     #$00                            ; A562 A9 00    ..
        bit     $FDED                           ; A564 2C ED FD ,..
        bvs     LA56B                           ; A567 70 02    p.
LA569:  lda     #$02                            ; A569 A9 02    ..
LA56B:  rts                                     ; A56B 60       `

; ----------------------------------------------------------------------------
LA56C:  jsr     select_ram_page_001             ; A56C 20 28 BE  (.
        lda     #$83                            ; A56F A9 83    ..
        jsr     osbyte                          ; A571 20 F4 FF  ..
        sty     $FDD5                           ; A574 8C D5 FD ...
        lda     #$84                            ; A577 A9 84    ..
        jsr     osbyte                          ; A579 20 F4 FF  ..
        tya                                     ; A57C 98       .
        sta     $FDD6                           ; A57D 8D D6 FD ...
        sec                                     ; A580 38       8
        sbc     $FDD5                           ; A581 ED D5 FD ...
        sta     $FDD7                           ; A584 8D D7 FD ...
        rts                                     ; A587 60       `

; ----------------------------------------------------------------------------
utils_help:
        ldx     #$FD                            ; A588 A2 FD    ..
        ldy     #$90                            ; A58A A0 90    ..
        lda     #$08                            ; A58C A9 08    ..
        bne     LA596                           ; A58E D0 06    ..
chal_help:
        ldx     #$5E                            ; A590 A2 5E    .^
        ldy     #$90                            ; A592 A0 90    ..
        lda     #$13                            ; A594 A9 13    ..
LA596:  jsr     L91D3                           ; A596 20 D3 91  ..
        sta     $B8                             ; A599 85 B8    ..
        jsr     LAEA3                           ; A59B 20 A3 AE  ..
        jsr     LA933                           ; A59E 20 33 A9  3.
        .byte   "(C) SLOGGER 1985"              ; A5A1 28 43 29 20 53 4C 4F 47(C) SLOG
                                                ; A5A9 47 45 52 20 31 39 38 35GER 1985
        .byte   $0D,$0D                         ; A5B1 0D 0D    ..
; ----------------------------------------------------------------------------
        nop                                     ; A5B3 EA       .
        ldx     #$00                            ; A5B4 A2 00    ..
LA5B6:  jsr     LA874                           ; A5B6 20 74 A8  t.
        jsr     LA5DD                           ; A5B9 20 DD A5  ..
        jsr     L841A                           ; A5BC 20 1A 84  ..
        dec     $B8                             ; A5BF C6 B8    ..
        bne     LA5B6                           ; A5C1 D0 F3    ..
        rts                                     ; A5C3 60       `

; ----------------------------------------------------------------------------
LA5C4:  jsr     LAA52                           ; A5C4 20 52 AA  R.
        beq     LA5CA                           ; A5C7 F0 01    ..
        rts                                     ; A5C9 60       `

; ----------------------------------------------------------------------------
LA5CA:  jsr     LA90D                           ; A5CA 20 0D A9  ..
        .byte   $DC                             ; A5CD DC       .
        .byte   "Syntax: "                      ; A5CE 53 79 6E 74 61 78 3A 20Syntax: 
; ----------------------------------------------------------------------------
        nop                                     ; A5D6 EA       .
        jsr     LA5DD                           ; A5D7 20 DD A5  ..
        jmp     LA958                           ; A5DA 4C 58 A9 LX.

; ----------------------------------------------------------------------------
LA5DD:  jsr     push_registers_and_tuck_restoration_thunk; A5DD 20 AB A8 ..
        ldx     #$00                            ; A5E0 A2 00    ..
        ldy     #$09                            ; A5E2 A0 09    ..
LA5E4:  jsr     L00AA                           ; A5E4 20 AA 00  ..
        bmi     LA5F1                           ; A5E7 30 08    0.
        jsr     LA9B1                           ; A5E9 20 B1 A9  ..
        inx                                     ; A5EC E8       .
        dey                                     ; A5ED 88       .
        jmp     LA5E4                           ; A5EE 4C E4 A5 L..

; ----------------------------------------------------------------------------
LA5F1:  dey                                     ; A5F1 88       .
        bmi     LA5F8                           ; A5F2 30 04    0.
        iny                                     ; A5F4 C8       .
        jsr     L8A8E                           ; A5F5 20 8E 8A  ..
LA5F8:  inx                                     ; A5F8 E8       .
        inx                                     ; A5F9 E8       .
        jsr     L00AA                           ; A5FA 20 AA 00  ..
        pha                                     ; A5FD 48       H
        inx                                     ; A5FE E8       .
        jsr     L91E2                           ; A5FF 20 E2 91  ..
        pla                                     ; A602 68       h
        jsr     LA60B                           ; A603 20 0B A6  ..
        jsr     LA9FE                           ; A606 20 FE A9  ..
        and     #$07                            ; A609 29 07    ).
LA60B:  jsr     push_registers_and_tuck_restoration_thunk; A60B 20 AB A8 ..
        and     #$0F                            ; A60E 29 0F    ).
        beq     LA62F                           ; A610 F0 1D    ..
        tay                                     ; A612 A8       .
        lda     #$20                            ; A613 A9 20    . 
        jsr     LA9B1                           ; A615 20 B1 A9  ..
        ldx     #$FF                            ; A618 A2 FF    ..
LA61A:  inx                                     ; A61A E8       .
        lda     LA630,x                         ; A61B BD 30 A6 .0.
        bne     LA61A                           ; A61E D0 FA    ..
        dey                                     ; A620 88       .
        bne     LA61A                           ; A621 D0 F7    ..
LA623:  inx                                     ; A623 E8       .
        lda     LA630,x                         ; A624 BD 30 A6 .0.
        beq     LA62F                           ; A627 F0 06    ..
        jsr     LA9B1                           ; A629 20 B1 A9  ..
        jmp     LA623                           ; A62C 4C 23 A6 L#.

; ----------------------------------------------------------------------------
LA62F:  rts                                     ; A62F 60       `

; ----------------------------------------------------------------------------
LA630:  brk                                     ; A630 00       .
        .byte   $3C                             ; A631 3C       <
        ror     $73                             ; A632 66 73    fs
        bvs     LA674                           ; A634 70 3E    p>
        brk                                     ; A636 00       .
        .byte   $3C                             ; A637 3C       <
        adc     ($66,x)                         ; A638 61 66    af
        .byte   $73                             ; A63A 73       s
        bvs     LA67B                           ; A63B 70 3E    p>
        brk                                     ; A63D 00       .
        plp                                     ; A63E 28       (
        jmp     L0029                           ; A63F 4C 29 00 L).

; ----------------------------------------------------------------------------
        .byte   $3C                             ; A642 3C       <
        .byte   $73                             ; A643 73       s
        .byte   $72                             ; A644 72       r
        .byte   $63                             ; A645 63       c
        jsr     L7264                           ; A646 20 64 72  dr
        ror     $3E,x                           ; A649 76 3E    v>
        brk                                     ; A64B 00       .
        .byte   $3C                             ; A64C 3C       <
        .byte   $64                             ; A64D 64       d
        adc     $73                             ; A64E 65 73    es
        .byte   $74                             ; A650 74       t
        jsr     L7264                           ; A651 20 64 72  dr
        ror     $3E,x                           ; A654 76 3E    v>
        brk                                     ; A656 00       .
        .byte   $3C                             ; A657 3C       <
        .byte   $64                             ; A658 64       d
        adc     $73                             ; A659 65 73    es
        .byte   $74                             ; A65B 74       t
        jsr     L7264                           ; A65C 20 64 72  dr
        ror     $3E,x                           ; A65F 76 3E    v>
        jsr     L613C                           ; A661 20 3C 61  <a
        ror     $73                             ; A664 66 73    fs
        bvs     LA6A6                           ; A666 70 3E    p>
        brk                                     ; A668 00       .
        .byte   $3C                             ; A669 3C       <
        ror     $7765                           ; A66A 6E 65 77 new
        jsr     L7366                           ; A66D 20 66 73  fs
        bvs     LA6B0                           ; A670 70 3E    p>
        brk                                     ; A672 00       .
        .byte   $3C                             ; A673 3C       <
LA674:  .byte   $6F                             ; A674 6F       o
        jmp     (L2064)                         ; A675 6C 64 20 ld 

; ----------------------------------------------------------------------------
        ror     $73                             ; A678 66 73    fs
        .byte   $70                             ; A67A 70       p
LA67B:  rol     $2800,x                         ; A67B 3E 00 28 >.(
        .byte   $3C                             ; A67E 3C       <
        .byte   $64                             ; A67F 64       d
        adc     #$72                            ; A680 69 72    ir
        rol     a:L0029,x                       ; A682 3E 29 00 >).
        plp                                     ; A685 28       (
        .byte   $3C                             ; A686 3C       <
        .byte   $64                             ; A687 64       d
        .byte   $72                             ; A688 72       r
        ror     $3E,x                           ; A689 76 3E    v>
        and     #$00                            ; A68B 29 00    ).
        .byte   $3C                             ; A68D 3C       <
        .byte   $74                             ; A68E 74       t
        adc     #$74                            ; A68F 69 74    it
        jmp     (L3E65)                         ; A691 6C 65 3E le>

; ----------------------------------------------------------------------------
        brk                                     ; A694 00       .
compact_command:
        jsr     LAA76                           ; A695 20 76 AA  v.
        sta     $FDCA                           ; A698 8D CA FD ...
        sta     $FDCB                           ; A69B 8D CB FD ...
        jsr     LA933                           ; A69E 20 33 A9  3.
        .byte   "Compa"                         ; A6A1 43 6F 6D 70 61Compa
LA6A6:  .byte   "cting"                         ; A6A6 63 74 69 6E 67cting
; ----------------------------------------------------------------------------
        nop                                     ; A6AB EA       .
        jsr     L8E4D                           ; A6AC 20 4D 8E  M.
        .byte   $20                             ; A6AF 20        
LA6B0:  .byte   $1A                             ; A6B0 1A       .
        sty     $20                             ; A6B1 84 20    . 
        .byte   $DC                             ; A6B3 DC       .
        sta     $6C20,y                         ; A6B4 99 20 6C . l
        lda     $20                             ; A6B7 A5 20    . 
        .byte   $9B                             ; A6B9 9B       .
        stx     $20,y                           ; A6BA 96 20    . 
        .byte   $D4                             ; A6BC D4       .
        sty     $20                             ; A6BD 84 20    . 
        .byte   $DB                             ; A6BF DB       .
        sty     $20                             ; A6C0 84 20    . 
        .byte   $32                             ; A6C2 32       2
        ldx     $05AC,y                         ; A6C3 BE AC 05 ...
        sbc     $CC84,x                         ; A6C6 FD 84 CC ...
        lda     #$00                            ; A6C9 A9 00    ..
        sta     $CB                             ; A6CB 85 CB    ..
        jsr     LA55A                           ; A6CD 20 5A A5  Z.
        sta     $CA                             ; A6D0 85 CA    ..
LA6D2:  ldy     $CC                             ; A6D2 A4 CC    ..
        jsr     LAA12                           ; A6D4 20 12 AA  ..
        cpy     #$F8                            ; A6D7 C0 F8    ..
        beq     LA735                           ; A6D9 F0 5A    .Z
        sty     $CC                             ; A6DB 84 CC    ..
        jsr     L8C3D                           ; A6DD 20 3D 8C  =.
        ldy     $CC                             ; A6E0 A4 CC    ..
        jsr     LA762                           ; A6E2 20 62 A7  b.
        beq     LA72D                           ; A6E5 F0 46    .F
        lda     #$00                            ; A6E7 A9 00    ..
        sta     $BE                             ; A6E9 85 BE    ..
        sta     $C2                             ; A6EB 85 C2    ..
        jsr     LA773                           ; A6ED 20 73 A7  s.
        jsr     select_ram_page_003             ; A6F0 20 32 BE  2.
        lda     $FD0F,y                         ; A6F3 B9 0F FD ...
        sta     $C8                             ; A6F6 85 C8    ..
        lda     $FD0E,y                         ; A6F8 B9 0E FD ...
        and     #$03                            ; A6FB 29 03    ).
        sta     $C9                             ; A6FD 85 C9    ..
        cmp     $CB                             ; A6FF C5 CB    ..
        bne     LA70F                           ; A701 D0 0C    ..
        lda     $C8                             ; A703 A5 C8    ..
        cmp     $CA                             ; A705 C5 CA    ..
        bne     LA70F                           ; A707 D0 06    ..
        jsr     LA792                           ; A709 20 92 A7  ..
        jmp     LA72D                           ; A70C 4C 2D A7 L-.

; ----------------------------------------------------------------------------
LA70F:  jsr     select_ram_page_003             ; A70F 20 32 BE  2.
        lda     $CA                             ; A712 A5 CA    ..
        sta     $FD0F,y                         ; A714 99 0F FD ...
        lda     $FD0E,y                         ; A717 B9 0E FD ...
        and     #$FC                            ; A71A 29 FC    ).
        ora     $CB                             ; A71C 05 CB    ..
        sta     $FD0E,y                         ; A71E 99 0E FD ...
        lda     #$00                            ; A721 A9 00    ..
        sta     L00A8                           ; A723 85 A8    ..
        sta     $A9                             ; A725 85 A9    ..
        jsr     L88F9                           ; A727 20 F9 88  ..
        jsr     L9677                           ; A72A 20 77 96  w.
LA72D:  ldy     $CC                             ; A72D A4 CC    ..
        jsr     L8C45                           ; A72F 20 45 8C  E.
        jmp     LA6D2                           ; A732 4C D2 A6 L..

; ----------------------------------------------------------------------------
LA735:  jsr     LA933                           ; A735 20 33 A9  3.
        .byte   "Disk compacted "               ; A738 44 69 73 6B 20 63 6F 6DDisk com
                                                ; A740 70 61 63 74 65 64 20pacted 
; ----------------------------------------------------------------------------
        nop                                     ; A747 EA       .
        sec                                     ; A748 38       8
        jsr     select_ram_page_003             ; A749 20 32 BE  2.
        lda     $FD07                           ; A74C AD 07 FD ...
        sbc     $CA                             ; A74F E5 CA    ..
        sta     $C6                             ; A751 85 C6    ..
        lda     $FD06                           ; A753 AD 06 FD ...
        and     #$03                            ; A756 29 03    ).
        sbc     $CB                             ; A758 E5 CB    ..
        sta     $C7                             ; A75A 85 C7    ..
        jsr     L8B91                           ; A75C 20 91 8B  ..
        jmp     L887B                           ; A75F 4C 7B 88 L{.

; ----------------------------------------------------------------------------
LA762:  jsr     select_ram_page_003             ; A762 20 32 BE  2.
        lda     $FD0E,y                         ; A765 B9 0E FD ...
        and     #$30                            ; A768 29 30    )0
        ora     $FD0D,y                         ; A76A 19 0D FD ...
        ora     $FD0C,y                         ; A76D 19 0C FD ...
        jmp     select_ram_page_001             ; A770 4C 28 BE L(.

; ----------------------------------------------------------------------------
LA773:  jsr     select_ram_page_003             ; A773 20 32 BE  2.
        clc                                     ; A776 18       .
        lda     $FD0C,y                         ; A777 B9 0C FD ...
        adc     #$FF                            ; A77A 69 FF    i.
        lda     $FD0D,y                         ; A77C B9 0D FD ...
        adc     #$00                            ; A77F 69 00    i.
        sta     $C6                             ; A781 85 C6    ..
        lda     $FD0E,y                         ; A783 B9 0E FD ...
        php                                     ; A786 08       .
        jsr     LA9F6                           ; A787 20 F6 A9  ..
        plp                                     ; A78A 28       (
        adc     #$00                            ; A78B 69 00    i.
        sta     $C7                             ; A78D 85 C7    ..
        jmp     select_ram_page_001             ; A78F 4C 28 BE L(.

; ----------------------------------------------------------------------------
LA792:  clc                                     ; A792 18       .
        lda     $CA                             ; A793 A5 CA    ..
        adc     $C6                             ; A795 65 C6    e.
        sta     $CA                             ; A797 85 CA    ..
        lda     $CB                             ; A799 A5 CB    ..
        adc     $C7                             ; A79B 65 C7    e.
        sta     $CB                             ; A79D 85 CB    ..
        rts                                     ; A79F 60       `

; ----------------------------------------------------------------------------
LA7A0:  lda     $FDCB                           ; A7A0 AD CB FD ...
        jsr     LAB3B                           ; A7A3 20 3B AB  ;.
        sta     $A9                             ; A7A6 85 A9    ..
        lda     $FDCA                           ; A7A8 AD CA FD ...
        jsr     LAB3B                           ; A7AB 20 3B AB  ;.
        cmp     $A9                             ; A7AE C5 A9    ..
        bne     LA7B9                           ; A7B0 D0 07    ..
        lda     #$FF                            ; A7B2 A9 FF    ..
        sta     $A9                             ; A7B4 85 A9    ..
        sta     L00AA                           ; A7B6 85 AA    ..
        rts                                     ; A7B8 60       `

; ----------------------------------------------------------------------------
LA7B9:  lda     #$00                            ; A7B9 A9 00    ..
        sta     $A9                             ; A7BB 85 A9    ..
        rts                                     ; A7BD 60       `

; ----------------------------------------------------------------------------
LA7BE:  jsr     push_registers_and_tuck_restoration_thunk; A7BE 20 AB A8 ..
        bit     $FDDF                           ; A7C1 2C DF FD ,..
        bpl     LA7E6                           ; A7C4 10 20    . 
        jsr     LA933                           ; A7C6 20 33 A9  3.
        .byte   $0D                             ; A7C9 0D       .
        .byte   "Are you sure ? Y/N "           ; A7CA 41 72 65 20 79 6F 75 20Are you 
                                                ; A7D2 73 75 72 65 20 3F 20 59sure ? Y
                                                ; A7DA 2F 4E 20 /N 
; ----------------------------------------------------------------------------
        nop                                     ; A7DD EA       .
        jsr     L848F                           ; A7DE 20 8F 84  ..
        beq     LA7E6                           ; A7E1 F0 03    ..
        ldx     $B8                             ; A7E3 A6 B8    ..
        txs                                     ; A7E5 9A       .
LA7E6:  jmp     L841A                           ; A7E6 4C 1A 84 L..

; ----------------------------------------------------------------------------
LA7E9:  jsr     LA5C4                           ; A7E9 20 C4 A5  ..
        jsr     LAADF                           ; A7EC 20 DF AA  ..
        sta     $FDCA                           ; A7EF 8D CA FD ...
        jsr     LA5C4                           ; A7F2 20 C4 A5  ..
        jsr     LAADF                           ; A7F5 20 DF AA  ..
        sta     $FDCB                           ; A7F8 8D CB FD ...
        tya                                     ; A7FB 98       .
        pha                                     ; A7FC 48       H
        jsr     LA7A0                           ; A7FD 20 A0 A7  ..
        jsr     LA56C                           ; A800 20 6C A5  l.
        jsr     LA933                           ; A803 20 33 A9  3.
        .byte   "Copying from drive "           ; A806 43 6F 70 79 69 6E 67 20Copying 
                                                ; A80E 66 72 6F 6D 20 64 72 69from dri
                                                ; A816 76 65 20 ve 
; ----------------------------------------------------------------------------
        lda     $FDCA                           ; A819 AD CA FD ...
        jsr     L8E58                           ; A81C 20 58 8E  X.
        jsr     LA933                           ; A81F 20 33 A9  3.
        .byte   " to drive "                    ; A822 20 74 6F 20 64 72 69 76 to driv
                                                ; A82A 65 20    e 
; ----------------------------------------------------------------------------
        lda     $FDCB                           ; A82C AD CB FD ...
        jsr     L8E58                           ; A82F 20 58 8E  X.
        jsr     L841A                           ; A832 20 1A 84  ..
        pla                                     ; A835 68       h
        tay                                     ; A836 A8       .
        clc                                     ; A837 18       .
        rts                                     ; A838 60       `

; ----------------------------------------------------------------------------
LA839:  sed                                     ; A839 F8       .
        clc                                     ; A83A 18       .
        lda     L00A8                           ; A83B A5 A8    ..
        adc     #$01                            ; A83D 69 01    i.
        sta     L00A8                           ; A83F 85 A8    ..
        lda     $A9                             ; A841 A5 A9    ..
        adc     #$00                            ; A843 69 00    i.
        sta     $A9                             ; A845 85 A9    ..
        cld                                     ; A847 D8       .
LA848:  clc                                     ; A848 18       .
        lda     $A9                             ; A849 A5 A9    ..
        jsr     LA85F                           ; A84B 20 5F A8  _.
        bcs     LA851                           ; A84E B0 01    ..
LA850:  clc                                     ; A850 18       .
LA851:  lda     L00A8                           ; A851 A5 A8    ..
        bne     LA85F                           ; A853 D0 0A    ..
        bcs     LA85F                           ; A855 B0 08    ..
        jsr     LA877                           ; A857 20 77 A8  w.
        lda     #$00                            ; A85A A9 00    ..
        jmp     LA9E0                           ; A85C 4C E0 A9 L..

; ----------------------------------------------------------------------------
LA85F:  pha                                     ; A85F 48       H
        php                                     ; A860 08       .
        jsr     LA9FE                           ; A861 20 FE A9  ..
        plp                                     ; A864 28       (
        jsr     LA869                           ; A865 20 69 A8  i.
        pla                                     ; A868 68       h
LA869:  pha                                     ; A869 48       H
        pla                                     ; A86A 68       h
        bcs     LA86F                           ; A86B B0 02    ..
        beq     LA877                           ; A86D F0 08    ..
LA86F:  jsr     LA9E0                           ; A86F 20 E0 A9  ..
        sec                                     ; A872 38       8
        rts                                     ; A873 60       `

; ----------------------------------------------------------------------------
LA874:  jsr     LA877                           ; A874 20 77 A8  w.
LA877:  pha                                     ; A877 48       H
        lda     #$20                            ; A878 A9 20    . 
        jsr     LA9B1                           ; A87A 20 B1 A9  ..
        pla                                     ; A87D 68       h
        clc                                     ; A87E 18       .
        rts                                     ; A87F 60       `

; ----------------------------------------------------------------------------
LA880:  tsx                                     ; A880 BA       .
        lda     #$00                            ; A881 A9 00    ..
        sta     $0107,x                         ; A883 9D 07 01 ...
        tya                                     ; A886 98       .
        pha                                     ; A887 48       H
        jsr     LA5C4                           ; A888 20 C4 A5  ..
        pla                                     ; A88B 68       h
        tay                                     ; A88C A8       .
LA88D:  tya                                     ; A88D 98       .
        clc                                     ; A88E 18       .
        adc     $F2                             ; A88F 65 F2    e.
        tax                                     ; A891 AA       .
        lda     $F3                             ; A892 A5 F3    ..
        adc     #$00                            ; A894 69 00    i.
        tay                                     ; A896 A8       .
LA897:  lda     #$00                            ; A897 A9 00    ..
        sta     L00A8                           ; A899 85 A8    ..
        sta     $A9                             ; A89B 85 A9    ..
        rts                                     ; A89D 60       `

; ----------------------------------------------------------------------------
LA89E:  pha                                     ; A89E 48       H
        txa                                     ; A89F 8A       .
        pha                                     ; A8A0 48       H
        tsx                                     ; A8A1 BA       .
        lda     #$00                            ; A8A2 A9 00    ..
        sta     $0109,x                         ; A8A4 9D 09 01 ...
        pla                                     ; A8A7 68       h
        tax                                     ; A8A8 AA       .
        pla                                     ; A8A9 68       h
        rts                                     ; A8AA 60       `

; ----------------------------------------------------------------------------
push_registers_and_tuck_restoration_thunk:
        pha                                     ; A8AB 48       H
        txa                                     ; A8AC 8A       .
        pha                                     ; A8AD 48       H
        tya                                     ; A8AE 98       .
        pha                                     ; A8AF 48       H
        lda     #$A8                            ; A8B0 A9 A8    ..
        pha                                     ; A8B2 48       H
        lda     #$CD                            ; A8B3 A9 CD    ..
        pha                                     ; A8B5 48       H
LA8B6:  ldy     #$05                            ; A8B6 A0 05    ..
LA8B8:  tsx                                     ; A8B8 BA       .
        lda     $0107,x                         ; A8B9 BD 07 01 ...
        pha                                     ; A8BC 48       H
        dey                                     ; A8BD 88       .
        bne     LA8B8                           ; A8BE D0 F8    ..
        ldy     #$0A                            ; A8C0 A0 0A    ..
LA8C2:  lda     $0109,x                         ; A8C2 BD 09 01 ...
        sta     $010B,x                         ; A8C5 9D 0B 01 ...
        dex                                     ; A8C8 CA       .
        dey                                     ; A8C9 88       .
        bne     LA8C2                           ; A8CA D0 F6    ..
        pla                                     ; A8CC 68       h
        pla                                     ; A8CD 68       h
LA8CE:  pla                                     ; A8CE 68       h
        tay                                     ; A8CF A8       .
        pla                                     ; A8D0 68       h
        tax                                     ; A8D1 AA       .
        pla                                     ; A8D2 68       h
        rts                                     ; A8D3 60       `

; ----------------------------------------------------------------------------
LA8D4:  pha                                     ; A8D4 48       H
        txa                                     ; A8D5 8A       .
        pha                                     ; A8D6 48       H
        tya                                     ; A8D7 98       .
        pha                                     ; A8D8 48       H
        jsr     LA8B6                           ; A8D9 20 B6 A8  ..
        tsx                                     ; A8DC BA       .
        sta     $0103,x                         ; A8DD 9D 03 01 ...
        jmp     LA8CE                           ; A8E0 4C CE A8 L..

; ----------------------------------------------------------------------------
LA8E3:  jsr     LA8F2                           ; A8E3 20 F2 A8  ..
        .byte   $C9                             ; A8E6 C9       .
        .byte   " read only"                    ; A8E7 20 72 65 61 64 20 6F 6E read on
                                                ; A8EF 6C 79    ly
        .byte   $00                             ; A8F1 00       .
; ----------------------------------------------------------------------------
LA8F2:  jsr     LA930                           ; A8F2 20 30 A9  0.
        .byte   "Disk "                         ; A8F5 44 69 73 6B 20Disk 
; ----------------------------------------------------------------------------
        bcc     LA90D                           ; A8FA 90 11    ..
LA8FC:  jsr     LA930                           ; A8FC 20 30 A9  0.
        .byte   "Bad "                          ; A8FF 42 61 64 20Bad 
; ----------------------------------------------------------------------------
        bcc     LA90D                           ; A903 90 08    ..
LA905:  jsr     LA930                           ; A905 20 30 A9  0.
        .byte   "File "                         ; A908 46 69 6C 65 20File 
; ----------------------------------------------------------------------------
LA90D:  sta     $B3                             ; A90D 85 B3    ..
        pla                                     ; A90F 68       h
        sta     L00AE                           ; A910 85 AE    ..
        pla                                     ; A912 68       h
        sta     $AF                             ; A913 85 AF    ..
        lda     $B3                             ; A915 A5 B3    ..
        pha                                     ; A917 48       H
        tya                                     ; A918 98       .
        pha                                     ; A919 48       H
        ldy     #$00                            ; A91A A0 00    ..
        jsr     LAA4B                           ; A91C 20 4B AA  K.
        lda     (L00AE),y                       ; A91F B1 AE    ..
        sta     $0101                           ; A921 8D 01 01 ...
        jsr     LA9A0                           ; A924 20 A0 A9  ..
        bmi     LA942                           ; A927 30 19    0.
        lda     #$02                            ; A929 A9 02    ..
        sta     L0100                           ; A92B 8D 00 01 ...
        bne     LA942                           ; A92E D0 12    ..
LA930:  jsr     LA99B                           ; A930 20 9B A9  ..
LA933:  sta     $B3                             ; A933 85 B3    ..
        pla                                     ; A935 68       h
        sta     L00AE                           ; A936 85 AE    ..
        pla                                     ; A938 68       h
        sta     $AF                             ; A939 85 AF    ..
        lda     $B3                             ; A93B A5 B3    ..
        pha                                     ; A93D 48       H
        tya                                     ; A93E 98       .
        pha                                     ; A93F 48       H
        ldy     #$00                            ; A940 A0 00    ..
LA942:  jsr     LAA4B                           ; A942 20 4B AA  K.
        lda     (L00AE),y                       ; A945 B1 AE    ..
        bmi     LA951                           ; A947 30 08    0.
        beq     LA958                           ; A949 F0 0D    ..
        jsr     LA9B1                           ; A94B 20 B1 A9  ..
        jmp     LA942                           ; A94E 4C 42 A9 LB.

; ----------------------------------------------------------------------------
LA951:  pla                                     ; A951 68       h
        tay                                     ; A952 A8       .
        pla                                     ; A953 68       h
        clc                                     ; A954 18       .
        jmp     (L00AE)                         ; A955 6C AE 00 l..

; ----------------------------------------------------------------------------
LA958:  lda     #$00                            ; A958 A9 00    ..
        ldx     L0100                           ; A95A AE 00 01 ...
        sta     L0100,x                         ; A95D 9D 00 01 ...
        sta     L0100                           ; A960 8D 00 01 ...
        jsr     L81E9                           ; A963 20 E9 81  ..
        and     #$7F                            ; A966 29 7F    ).
        sta     $0DF0,x                         ; A968 9D F0 0D ...
        jsr     L97BB                           ; A96B 20 BB 97  ..
        jsr     L975B                           ; A96E 20 5B 97  [.
        jsr     LADDD                           ; A971 20 DD AD  ..
        jmp     L0100                           ; A974 4C 00 01 L..

; ----------------------------------------------------------------------------
LA977:  pla                                     ; A977 68       h
        sta     L00AE                           ; A978 85 AE    ..
        pla                                     ; A97A 68       h
        sta     $AF                             ; A97B 85 AF    ..
        tya                                     ; A97D 98       .
        pha                                     ; A97E 48       H
        ldy     #$00                            ; A97F A0 00    ..
LA981:  jsr     LAA4B                           ; A981 20 4B AA  K.
        lda     (L00AE),y                       ; A984 B1 AE    ..
        cmp     #$FF                            ; A986 C9 FF    ..
        beq     LA990                           ; A988 F0 06    ..
        jsr     oswrch                          ; A98A 20 EE FF  ..
        jmp     LA981                           ; A98D 4C 81 A9 L..

; ----------------------------------------------------------------------------
LA990:  pla                                     ; A990 68       h
        tay                                     ; A991 A8       .
LA992:  jsr     LAA4B                           ; A992 20 4B AA  K.
        jmp     (L00AE)                         ; A995 6C AE 00 l..

; ----------------------------------------------------------------------------
LA998:  sta     $0101                           ; A998 8D 01 01 ...
LA99B:  lda     #$02                            ; A99B A9 02    ..
        sta     L0100                           ; A99D 8D 00 01 ...
LA9A0:  jsr     L81E9                           ; A9A0 20 E9 81  ..
        php                                     ; A9A3 08       .
        ora     #$80                            ; A9A4 09 80    ..
        sta     $0DF0,x                         ; A9A6 9D F0 0D ...
        plp                                     ; A9A9 28       (
        rts                                     ; A9AA 60       `

; ----------------------------------------------------------------------------
LA9AB:  lda     #$4E                            ; A9AB A9 4E    .N
        bne     LA9B1                           ; A9AD D0 02    ..
LA9AF:  lda     #$2E                            ; A9AF A9 2E    ..
LA9B1:  jsr     push_registers_and_tuck_restoration_thunk; A9B1 20 AB A8 ..
        pha                                     ; A9B4 48       H
        jsr     L81E9                           ; A9B5 20 E9 81  ..
        bmi     LA9CD                           ; A9B8 30 13    0.
        jsr     LAE27                           ; A9BA 20 27 AE  '.
        txa                                     ; A9BD 8A       .
        pha                                     ; A9BE 48       H
        ora     #$10                            ; A9BF 09 10    ..
        jsr     LAE22                           ; A9C1 20 22 AE  ".
        pla                                     ; A9C4 68       h
        tax                                     ; A9C5 AA       .
        pla                                     ; A9C6 68       h
        jsr     osasci                          ; A9C7 20 E3 FF  ..
        jmp     LAE23                           ; A9CA 4C 23 AE L#.

; ----------------------------------------------------------------------------
LA9CD:  pla                                     ; A9CD 68       h
        ldx     L0100                           ; A9CE AE 00 01 ...
        sta     L0100,x                         ; A9D1 9D 00 01 ...
        inc     L0100                           ; A9D4 EE 00 01 ...
        rts                                     ; A9D7 60       `

; ----------------------------------------------------------------------------
LA9D8:  pha                                     ; A9D8 48       H
        jsr     LA9FE                           ; A9D9 20 FE A9  ..
        jsr     LA9E0                           ; A9DC 20 E0 A9  ..
        pla                                     ; A9DF 68       h
LA9E0:  pha                                     ; A9E0 48       H
        and     #$0F                            ; A9E1 29 0F    ).
        sed                                     ; A9E3 F8       .
        clc                                     ; A9E4 18       .
        adc     #$90                            ; A9E5 69 90    i.
        adc     #$40                            ; A9E7 69 40    i@
        cld                                     ; A9E9 D8       .
        jsr     LA9B1                           ; A9EA 20 B1 A9  ..
        pla                                     ; A9ED 68       h
        rts                                     ; A9EE 60       `

; ----------------------------------------------------------------------------
LA9EF:  lda     #$7E                            ; A9EF A9 7E    .~
        jmp     osbyte                          ; A9F1 4C F4 FF L..

; ----------------------------------------------------------------------------
LA9F4:  lsr     a                               ; A9F4 4A       J
        lsr     a                               ; A9F5 4A       J
LA9F6:  lsr     a                               ; A9F6 4A       J
        lsr     a                               ; A9F7 4A       J
LA9F8:  lsr     a                               ; A9F8 4A       J
        lsr     a                               ; A9F9 4A       J
        and     #$03                            ; A9FA 29 03    ).
        rts                                     ; A9FC 60       `

; ----------------------------------------------------------------------------
LA9FD:  lsr     a                               ; A9FD 4A       J
LA9FE:  lsr     a                               ; A9FE 4A       J
        lsr     a                               ; A9FF 4A       J
        lsr     a                               ; AA00 4A       J
        lsr     a                               ; AA01 4A       J
        rts                                     ; AA02 60       `

; ----------------------------------------------------------------------------
        asl     a                               ; AA03 0A       .
LAA04:  asl     a                               ; AA04 0A       .
        asl     a                               ; AA05 0A       .
        asl     a                               ; AA06 0A       .
        asl     a                               ; AA07 0A       .
        rts                                     ; AA08 60       `

; ----------------------------------------------------------------------------
LAA09:  iny                                     ; AA09 C8       .
LAA0A:  iny                                     ; AA0A C8       .
        iny                                     ; AA0B C8       .
        iny                                     ; AA0C C8       .
LAA0D:  iny                                     ; AA0D C8       .
        iny                                     ; AA0E C8       .
        iny                                     ; AA0F C8       .
        iny                                     ; AA10 C8       .
        rts                                     ; AA11 60       `

; ----------------------------------------------------------------------------
LAA12:  dey                                     ; AA12 88       .
        dey                                     ; AA13 88       .
        dey                                     ; AA14 88       .
        dey                                     ; AA15 88       .
LAA16:  dey                                     ; AA16 88       .
        dey                                     ; AA17 88       .
        dey                                     ; AA18 88       .
        dey                                     ; AA19 88       .
        rts                                     ; AA1A 60       `

; ----------------------------------------------------------------------------
LAA1B:  cmp     #$41                            ; AA1B C9 41    .A
        bcc     LAA2B                           ; AA1D 90 0C    ..
        cmp     #$5B                            ; AA1F C9 5B    .[
        bcc     LAA2D                           ; AA21 90 0A    ..
        cmp     #$61                            ; AA23 C9 61    .a
        bcc     LAA2B                           ; AA25 90 04    ..
        cmp     #$7B                            ; AA27 C9 7B    .{
        bcc     LAA2D                           ; AA29 90 02    ..
LAA2B:  sec                                     ; AA2B 38       8
        rts                                     ; AA2C 60       `

; ----------------------------------------------------------------------------
LAA2D:  and     #$DF                            ; AA2D 29 DF    ).
        clc                                     ; AA2F 18       .
        rts                                     ; AA30 60       `

; ----------------------------------------------------------------------------
LAA31:  pha                                     ; AA31 48       H
        jsr     LAA1B                           ; AA32 20 1B AA  ..
        pla                                     ; AA35 68       h
        rts                                     ; AA36 60       `

; ----------------------------------------------------------------------------
        jsr     LAA41                           ; AA37 20 41 AA  A.
        bcc     LAA3F                           ; AA3A 90 03    ..
        cmp     #$10                            ; AA3C C9 10    ..
        rts                                     ; AA3E 60       `

; ----------------------------------------------------------------------------
LAA3F:  sec                                     ; AA3F 38       8
        rts                                     ; AA40 60       `

; ----------------------------------------------------------------------------
LAA41:  cmp     #$41                            ; AA41 C9 41    .A
        bcc     LAA47                           ; AA43 90 02    ..
        sbc     #$07                            ; AA45 E9 07    ..
LAA47:  sec                                     ; AA47 38       8
        sbc     #$30                            ; AA48 E9 30    .0
        rts                                     ; AA4A 60       `

; ----------------------------------------------------------------------------
LAA4B:  inc     L00AE                           ; AA4B E6 AE    ..
        bne     LAA51                           ; AA4D D0 02    ..
        inc     $AF                             ; AA4F E6 AF    ..
LAA51:  rts                                     ; AA51 60       `

; ----------------------------------------------------------------------------
LAA52:  clc                                     ; AA52 18       .
        jmp     gsinit                          ; AA53 4C C2 FF L..

; ----------------------------------------------------------------------------
LAA56:  jsr     LAB1A                           ; AA56 20 1A AB  ..
        sta     $CF                             ; AA59 85 CF    ..
        rts                                     ; AA5B 60       `

; ----------------------------------------------------------------------------
LAA5C:  jsr     LAA1B                           ; AA5C 20 1B AA  ..
        sec                                     ; AA5F 38       8
        sbc     #$41                            ; AA60 E9 41    .A
        bcc     LAA94                           ; AA62 90 30    .0
        cmp     #$08                            ; AA64 C9 08    ..
        bcs     LAA94                           ; AA66 B0 2C    .,
        jsr     LAA04                           ; AA68 20 04 AA  ..
        ora     $CF                             ; AA6B 05 CF    ..
        sta     $CF                             ; AA6D 85 CF    ..
        rts                                     ; AA6F 60       `

; ----------------------------------------------------------------------------
        jsr     LA5C4                           ; AA70 20 C4 A5  ..
        jmp     LAADF                           ; AA73 4C DF AA L..

; ----------------------------------------------------------------------------
LAA76:  jsr     LAA52                           ; AA76 20 52 AA  R.
        beq     LAA86                           ; AA79 F0 0B    ..
        jmp     LAADF                           ; AA7B 4C DF AA L..

; ----------------------------------------------------------------------------
LAA7E:  jsr     select_ram_page_001             ; AA7E 20 28 BE  (.
        lda     $FDC6                           ; AA81 AD C6 FD ...
        sta     $CE                             ; AA84 85 CE    ..
LAA86:  lda     $FDC7                           ; AA86 AD C7 FD ...
        sta     $CF                             ; AA89 85 CF    ..
LAA8B:  rts                                     ; AA8B 60       `

; ----------------------------------------------------------------------------
        jsr     LAA76                           ; AA8C 20 76 AA  v.
        jsr     LAA52                           ; AA8F 20 52 AA  R.
        beq     LAA8B                           ; AA92 F0 F7    ..
LAA94:  jsr     LA8FC                           ; AA94 20 FC A8  ..
        cmp     L7264                           ; AA97 CD 64 72 .dr
        adc     #$76                            ; AA9A 69 76    iv
        adc     $00                             ; AA9C 65 00    e.
LAA9E:  jsr     gsread                          ; AA9E 20 C5 FF  ..
        bcs     LAAD1                           ; AAA1 B0 2E    ..
        cmp     #$3A                            ; AAA3 C9 3A    .:
        bne     LAAC9                           ; AAA5 D0 22    ."
        jsr     gsread                          ; AAA7 20 C5 FF  ..
        bcs     LAA94                           ; AAAA B0 E8    ..
        jsr     LAA56                           ; AAAC 20 56 AA  V.
        jsr     gsread                          ; AAAF 20 C5 FF  ..
        bcs     LAAD1                           ; AAB2 B0 1D    ..
        cmp     #$2E                            ; AAB4 C9 2E    ..
        beq     LAAC4                           ; AAB6 F0 0C    ..
        jsr     LAA5C                           ; AAB8 20 5C AA  \.
        jsr     gsread                          ; AABB 20 C5 FF  ..
        bcs     LAAD1                           ; AABE B0 11    ..
        cmp     #$2E                            ; AAC0 C9 2E    ..
        bne     LAA94                           ; AAC2 D0 D0    ..
LAAC4:  jsr     gsread                          ; AAC4 20 C5 FF  ..
        bcs     LAA94                           ; AAC7 B0 CB    ..
LAAC9:  jsr     LAB10                           ; AAC9 20 10 AB  ..
        jsr     gsread                          ; AACC 20 C5 FF  ..
        bcc     LAA94                           ; AACF 90 C3    ..
LAAD1:  rts                                     ; AAD1 60       `

; ----------------------------------------------------------------------------
LAAD2:  jsr     LAA86                           ; AAD2 20 86 AA  ..
        ldx     #$00                            ; AAD5 A2 00    ..
        jsr     gsread                          ; AAD7 20 C5 FF  ..
        bcs     LAAD1                           ; AADA B0 F5    ..
        sec                                     ; AADC 38       8
        bcs     LAAE6                           ; AADD B0 07    ..
LAADF:  ldx     #$00                            ; AADF A2 00    ..
        jsr     gsread                          ; AAE1 20 C5 FF  ..
        bcs     LAAD1                           ; AAE4 B0 EB    ..
LAAE6:  php                                     ; AAE6 08       .
        cmp     #$3A                            ; AAE7 C9 3A    .:
        bne     LAAF0                           ; AAE9 D0 05    ..
        jsr     gsread                          ; AAEB 20 C5 FF  ..
        bcs     LAA94                           ; AAEE B0 A4    ..
LAAF0:  jsr     LAA56                           ; AAF0 20 56 AA  V.
        ldx     #$02                            ; AAF3 A2 02    ..
        jsr     gsread                          ; AAF5 20 C5 FF  ..
        bcs     LAB09                           ; AAF8 B0 0F    ..
        plp                                     ; AAFA 28       (
        bcc     LAB04                           ; AAFB 90 07    ..
        cmp     #$2A                            ; AAFD C9 2A    .*
        bne     LAB04                           ; AAFF D0 03    ..
        ldx     #$83                            ; AB01 A2 83    ..
        rts                                     ; AB03 60       `

; ----------------------------------------------------------------------------
LAB04:  jsr     LAA5C                           ; AB04 20 5C AA  \.
        inx                                     ; AB07 E8       .
        php                                     ; AB08 08       .
LAB09:  plp                                     ; AB09 28       (
        lda     $CF                             ; AB0A A5 CF    ..
        rts                                     ; AB0C 60       `

; ----------------------------------------------------------------------------
        jsr     gsread                          ; AB0D 20 C5 FF  ..
LAB10:  cmp     #$2A                            ; AB10 C9 2A    .*
        bne     LAB16                           ; AB12 D0 02    ..
        lda     #$23                            ; AB14 A9 23    .#
LAB16:  sta     $CE                             ; AB16 85 CE    ..
        clc                                     ; AB18 18       .
        rts                                     ; AB19 60       `

; ----------------------------------------------------------------------------
LAB1A:  sec                                     ; AB1A 38       8
        sbc     #$30                            ; AB1B E9 30    .0
        bcc     LAB36                           ; AB1D 90 17    ..
        pha                                     ; AB1F 48       H
        cmp     #$08                            ; AB20 C9 08    ..
        bcs     LAB36                           ; AB22 B0 12    ..
        jsr     LAB3B                           ; AB24 20 3B AB  ;.
        cmp     #$05                            ; AB27 C9 05    ..
        bne     LAB34                           ; AB29 D0 09    ..
        jsr     L81E9                           ; AB2B 20 E9 81  ..
        and     #$03                            ; AB2E 29 03    ).
        cmp     #$02                            ; AB30 C9 02    ..
        bne     LAB36                           ; AB32 D0 02    ..
LAB34:  pla                                     ; AB34 68       h
        rts                                     ; AB35 60       `

; ----------------------------------------------------------------------------
LAB36:  jmp     LAA94                           ; AB36 4C 94 AA L..

; ----------------------------------------------------------------------------
LAB39:  lda     $CF                             ; AB39 A5 CF    ..
LAB3B:  jsr     LA8D4                           ; AB3B 20 D4 A8  ..
        tax                                     ; AB3E AA       .
        and     #$F0                            ; AB3F 29 F0    ).
        pha                                     ; AB41 48       H
        txa                                     ; AB42 8A       .
        and     #$07                            ; AB43 29 07    ).
        tax                                     ; AB45 AA       .
        jsr     select_ram_page_000             ; AB46 20 23 BE  #.
        lda     $FDD4,x                         ; AB49 BD D4 FD ...
        tsx                                     ; AB4C BA       .
        ora     $0101,x                         ; AB4D 1D 01 01 ...
        tax                                     ; AB50 AA       .
        pla                                     ; AB51 68       h
        txa                                     ; AB52 8A       .
        jmp     select_ram_page_001             ; AB53 4C 28 BE L(.

; ----------------------------------------------------------------------------
config_command:
        jsr     LAA52                           ; AB56 20 52 AA  R.
        bne     LAB89                           ; AB59 D0 2E    ..
        jsr     LA933                           ; AB5B 20 33 A9  3.
        .byte   "L drv:"                        ; AB5E 4C 20 64 72 76 3AL drv:
; ----------------------------------------------------------------------------
        ldx     #$00                            ; AB64 A2 00    ..
LAB66:  txa                                     ; AB66 8A       .
        jsr     LABC9                           ; AB67 20 C9 AB  ..
        bne     LAB66                           ; AB6A D0 FA    ..
        jsr     LA933                           ; AB6C 20 33 A9  3.
        .byte   $0D                             ; AB6F 0D       .
        .byte   "P drv:"                        ; AB70 50 20 64 72 76 3AP drv:
; ----------------------------------------------------------------------------
        ldx     #$00                            ; AB76 A2 00    ..
LAB78:  jsr     select_ram_page_000             ; AB78 20 23 BE  #.
        lda     $FDD4,x                         ; AB7B BD D4 FD ...
        jsr     select_ram_page_001             ; AB7E 20 28 BE  (.
        jsr     LABC9                           ; AB81 20 C9 AB  ..
        bne     LAB78                           ; AB84 D0 F2    ..
        jmp     L841A                           ; AB86 4C 1A 84 L..

; ----------------------------------------------------------------------------
LAB89:  cmp     #$52                            ; AB89 C9 52    .R
        beq     reset_drive_mappings            ; AB8B F0 2D    .-
LAB8D:  jsr     gsread                          ; AB8D 20 C5 FF  ..
        jsr     LAB1A                           ; AB90 20 1A AB  ..
        sta     $B0                             ; AB93 85 B0    ..
        jsr     gsread                          ; AB95 20 C5 FF  ..
        bcs     LABB7                           ; AB98 B0 1D    ..
        cmp     #$3D                            ; AB9A C9 3D    .=
        bne     LABB7                           ; AB9C D0 19    ..
        jsr     gsread                          ; AB9E 20 C5 FF  ..
        bcs     LABB7                           ; ABA1 B0 14    ..
        jsr     LAB1A                           ; ABA3 20 1A AB  ..
        jsr     select_ram_page_000             ; ABA6 20 23 BE  #.
        ldx     $B0                             ; ABA9 A6 B0    ..
        sta     $FDD4,x                         ; ABAB 9D D4 FD ...
        jsr     select_ram_page_001             ; ABAE 20 28 BE  (.
        jsr     LAA52                           ; ABB1 20 52 AA  R.
        bne     LAB8D                           ; ABB4 D0 D7    ..
        rts                                     ; ABB6 60       `

; ----------------------------------------------------------------------------
LABB7:  jmp     LA5CA                           ; ABB7 4C CA A5 L..

; ----------------------------------------------------------------------------
reset_drive_mappings:
        jsr     select_ram_page_000             ; ABBA 20 23 BE  #.
        ldx     #$07                            ; ABBD A2 07    ..
LABBF:  txa                                     ; ABBF 8A       .
        sta     $FDD4,x                         ; ABC0 9D D4 FD ...
        dex                                     ; ABC3 CA       .
        bpl     LABBF                           ; ABC4 10 F9    ..
        jmp     select_ram_page_001             ; ABC6 4C 28 BE L(.

; ----------------------------------------------------------------------------
LABC9:  jsr     LA877                           ; ABC9 20 77 A8  w.
        jsr     LA9E0                           ; ABCC 20 E0 A9  ..
        inx                                     ; ABCF E8       .
        cpx     #$08                            ; ABD0 E0 08    ..
        rts                                     ; ABD2 60       `

; ----------------------------------------------------------------------------
LABD3:  jsr     select_ram_page_001             ; ABD3 20 28 BE  (.
        lda     $FCEF,y                         ; ABD6 B9 EF FC ...
        and     #$7F                            ; ABD9 29 7F    ).
        sta     $CE                             ; ABDB 85 CE    ..
        lda     $FD00,y                         ; ABDD B9 00 FD ...
        sta     $CF                             ; ABE0 85 CF    ..
        lda     ram_paging_lsb,y                ; ABE2 B9 FF FC ...
        sta     $FDEC                           ; ABE5 8D EC FD ...
        lda     $FCF4,y                         ; ABE8 B9 F4 FC ...
        jmp     L84BE                           ; ABEB 4C BE 84 L..

; ----------------------------------------------------------------------------
LABEE:  jsr     select_ram_page_001             ; ABEE 20 28 BE  (.
        jsr     LADF4                           ; ABF1 20 F4 AD  ..
        lda     #$00                            ; ABF4 A9 00    ..
        sta     $BA                             ; ABF6 85 BA    ..
        jsr     LB7B2                           ; ABF8 20 B2 B7  ..
        beq     LAC5F                           ; ABFB F0 62    .b
        jsr     LB948                           ; ABFD 20 48 B9  H.
        lda     $FDE9                           ; AC00 AD E9 FD ...
        and     #$7F                            ; AC03 29 7F    ).
        bne     LAC75                           ; AC05 D0 6E    .n
        lda     #$00                            ; AC07 A9 00    ..
        sta     $FDEC                           ; AC09 8D EC FD ...
        jsr     LAC84                           ; AC0C 20 84 AC  ..
        bit     $FDED                           ; AC0F 2C ED FD ,..
        bvs     LAC17                           ; AC12 70 03    p.
        jsr     LAC56                           ; AC14 20 56 AC  V.
LAC17:  bit     $FDEA                           ; AC17 2C EA FD ,..
        bpl     LAC1F                           ; AC1A 10 03    ..
        jsr     LAC96                           ; AC1C 20 96 AC  ..
LAC1F:  bit     $FDED                           ; AC1F 2C ED FD ,..
        bvc     LAC75                           ; AC22 50 51    PQ
        jsr     LB585                           ; AC24 20 85 B5  ..
        jsr     select_ram_page_002             ; AC27 20 2D BE  -.
        lda     $FD00                           ; AC2A AD 00 FD ...
        cmp     #$E5                            ; AC2D C9 E5    ..
        bne     LAC34                           ; AC2F D0 03    ..
        jmp     LACE9                           ; AC31 4C E9 AC L..

; ----------------------------------------------------------------------------
LAC34:  jsr     LAC7A                           ; AC34 20 7A AC  z.
        tay                                     ; AC37 A8       .
        lda     $FD08,y                         ; AC38 B9 08 FD ...
        pha                                     ; AC3B 48       H
        lda     $FD01                           ; AC3C AD 01 FD ...
        pha                                     ; AC3F 48       H
        lda     $FD02                           ; AC40 AD 02 FD ...
        pha                                     ; AC43 48       H
        jsr     select_ram_page_001             ; AC44 20 28 BE  (.
        pla                                     ; AC47 68       h
        sta     $FDF6                           ; AC48 8D F6 FD ...
        pla                                     ; AC4B 68       h
        sta     $FDF5                           ; AC4C 8D F5 FD ...
        pla                                     ; AC4F 68       h
        sta     $FDEC                           ; AC50 8D EC FD ...
        beq     LACC3                           ; AC53 F0 6E    .n
LAC55:  rts                                     ; AC55 60       `

; ----------------------------------------------------------------------------
LAC56:  lda     $CF                             ; AC56 A5 CF    ..
        and     #$F0                            ; AC58 29 F0    ).
        beq     LAC55                           ; AC5A F0 F9    ..
        jmp     LAA94                           ; AC5C 4C 94 AA L..

; ----------------------------------------------------------------------------
LAC5F:  jsr     LAC56                           ; AC5F 20 56 AC  V.
        lda     $FDED                           ; AC62 AD ED FD ...
        and     #$80                            ; AC65 29 80    ).
        sta     $FDED                           ; AC67 8D ED FD ...
        lda     #$00                            ; AC6A A9 00    ..
        sta     $FDEB                           ; AC6C 8D EB FD ...
        sta     $FDEC                           ; AC6F 8D EC FD ...
        sta     $BB                             ; AC72 85 BB    ..
        rts                                     ; AC74 60       `

; ----------------------------------------------------------------------------
LAC75:  lda     $FDED                           ; AC75 AD ED FD ...
        beq     LAC81                           ; AC78 F0 07    ..
LAC7A:  lda     $CF                             ; AC7A A5 CF    ..
        and     #$F0                            ; AC7C 29 F0    ).
        lsr     a                               ; AC7E 4A       J
        lsr     a                               ; AC7F 4A       J
        lsr     a                               ; AC80 4A       J
LAC81:  sta     $BB                             ; AC81 85 BB    ..
        rts                                     ; AC83 60       `

; ----------------------------------------------------------------------------
LAC84:  bit     $FDED                           ; AC84 2C ED FD ,..
        bpl     LAC8C                           ; AC87 10 03    ..
        jmp     LB9AB                           ; AC89 4C AB B9 L..

; ----------------------------------------------------------------------------
LAC8C:  lda     #$0A                            ; AC8C A9 0A    ..
        bvc     LAC92                           ; AC8E 50 02    P.
        lda     #$12                            ; AC90 A9 12    ..
LAC92:  sta     $FDEB                           ; AC92 8D EB FD ...
        rts                                     ; AC95 60       `

; ----------------------------------------------------------------------------
LAC96:  lda     #$80                            ; AC96 A9 80    ..
        sta     $FDEA                           ; AC98 8D EA FD ...
        lda     #$02                            ; AC9B A9 02    ..
        jsr     LB967                           ; AC9D 20 67 B9  g.
        jsr     LBA01                           ; ACA0 20 01 BA  ..
        jsr     select_ram_page_000             ; ACA3 20 23 BE  #.
        ldx     $FDB8                           ; ACA6 AE B8 FD ...
        jsr     select_ram_page_001             ; ACA9 20 28 BE  (.
        dex                                     ; ACAC CA       .
        beq     LACB9                           ; ACAD F0 0A    ..
        dex                                     ; ACAF CA       .
        beq     LACBE                           ; ACB0 F0 0C    ..
        dex                                     ; ACB2 CA       .
        dex                                     ; ACB3 CA       .
        bne     LACFE                           ; ACB4 D0 48    .H
        jmp     LAD13                           ; ACB6 4C 13 AD L..

; ----------------------------------------------------------------------------
LACB9:  lda     #$C0                            ; ACB9 A9 C0    ..
        sta     $FDEA                           ; ACBB 8D EA FD ...
LACBE:  lda     #$00                            ; ACBE A9 00    ..
        jmp     LB967                           ; ACC0 4C 67 B9 Lg.

; ----------------------------------------------------------------------------
LACC3:  jsr     LA90D                           ; ACC3 20 0D A9  ..
        .byte   $CD                             ; ACC6 CD       .
        .byte   "Volume "                       ; ACC7 56 6F 6C 75 6D 65 20Volume 
; ----------------------------------------------------------------------------
        nop                                     ; ACCE EA       .
        clc                                     ; ACCF 18       .
        tya                                     ; ACD0 98       .
        lsr     a                               ; ACD1 4A       J
        adc     #$41                            ; ACD2 69 41    iA
        jsr     LA9B1                           ; ACD4 20 B1 A9  ..
        jsr     LA933                           ; ACD7 20 33 A9  3.
        .byte   " not allocated"                ; ACDA 20 6E 6F 74 20 61 6C 6C not all
                                                ; ACE2 6F 63 61 74 65 64ocated
        .byte   $00                             ; ACE8 00       .
; ----------------------------------------------------------------------------
LACE9:  jsr     LA90D                           ; ACE9 20 0D A9  ..
        .byte   $CD                             ; ACEC CD       .
        .byte   "No config sector"              ; ACED 4E 6F 20 63 6F 6E 66 69No confi
                                                ; ACF5 67 20 73 65 63 74 6F 72g sector
        .byte   $00                             ; ACFD 00       .
; ----------------------------------------------------------------------------
LACFE:  jsr     LA90D                           ; ACFE 20 0D A9  ..
        .byte   $CD                             ; AD01 CD       .
        .byte   "Bad track format"              ; AD02 42 61 64 20 74 72 61 63Bad trac
                                                ; AD0A 6B 20 66 6F 72 6D 61 74k format
        .byte   $00                             ; AD12 00       .
; ----------------------------------------------------------------------------
LAD13:  jsr     LA90D                           ; AD13 20 0D A9  ..
        .byte   $CD                             ; AD16 CD       .
        .byte   "80 track disk in 40 track drive"; AD17 38 30 20 74 72 61 63 6B80 track
                                                ; AD1F 20 64 69 73 6B 20 69 6E disk in
                                                ; AD27 20 34 30 20 74 72 61 63 40 trac
                                                ; AD2F 6B 20 64 72 69 76 65k drive
        .byte   $00                             ; AD36 00       .
; ----------------------------------------------------------------------------
LAD37:  lda     #$80                            ; AD37 A9 80    ..
        .byte   $AE                             ; AD39 AE       .
LAD3A:  lda     #$81                            ; AD3A A9 81    ..
        jsr     select_ram_page_001             ; AD3C 20 28 BE  (.
        sta     $FDE9                           ; AD3F 8D E9 FD ...
        ldx     #$03                            ; AD42 A2 03    ..
LAD44:  jsr     L970D                           ; AD44 20 0D 97  ..
        lda     #$10                            ; AD47 A9 10    ..
        sta     $BB                             ; AD49 85 BB    ..
        lda     #$00                            ; AD4B A9 00    ..
        sta     $BA                             ; AD4D 85 BA    ..
        sta     $A0                             ; AD4F 85 A0    ..
        lda     #$01                            ; AD51 A9 01    ..
        sta     $A1                             ; AD53 85 A1    ..
        jsr     LBA59                           ; AD55 20 59 BA  Y.
        beq     LAD60                           ; AD58 F0 06    ..
        dex                                     ; AD5A CA       .
        bne     LAD44                           ; AD5B D0 E7    ..
        jmp     LBCEE                           ; AD5D 4C EE BC L..

; ----------------------------------------------------------------------------
LAD60:  rts                                     ; AD60 60       `

; ----------------------------------------------------------------------------
LAD61:  jsr     push_registers_and_tuck_restoration_thunk; AD61 20 AB A8 ..
        ldy     #$03                            ; AD64 A0 03    ..
LAD66:  lda     $FDEB                           ; AD66 AD EB FD ...
        php                                     ; AD69 08       .
        ldx     $A3                             ; AD6A A6 A3    ..
        lda     $A4                             ; AD6C A5 A4    ..
        plp                                     ; AD6E 28       (
        beq     LAD89                           ; AD6F F0 18    ..
        sec                                     ; AD71 38       8
        lda     $FDEB                           ; AD72 AD EB FD ...
        sbc     $BB                             ; AD75 E5 BB    ..
        sta     $A0                             ; AD77 85 A0    ..
        lda     $A5                             ; AD79 A5 A5    ..
        bne     LAD85                           ; AD7B D0 08    ..
        ldx     $A3                             ; AD7D A6 A3    ..
        lda     $A4                             ; AD7F A5 A4    ..
        cmp     $A0                             ; AD81 C5 A0    ..
        bcc     LAD89                           ; AD83 90 04    ..
LAD85:  ldx     #$00                            ; AD85 A2 00    ..
        lda     $A0                             ; AD87 A5 A0    ..
LAD89:  stx     $A0                             ; AD89 86 A0    ..
        sta     $A1                             ; AD8B 85 A1    ..
        ora     $A0                             ; AD8D 05 A0    ..
        beq     LADDD                           ; AD8F F0 4C    .L
        jsr     LBA59                           ; AD91 20 59 BA  Y.
        beq     LAD9C                           ; AD94 F0 06    ..
        dey                                     ; AD96 88       .
        bne     LAD66                           ; AD97 D0 CD    ..
        jmp     LBCEE                           ; AD99 4C EE BC L..

; ----------------------------------------------------------------------------
LAD9C:  inc     $BA                             ; AD9C E6 BA    ..
        sta     $BB                             ; AD9E 85 BB    ..
        ldx     $A1                             ; ADA0 A6 A1    ..
        lda     $A0                             ; ADA2 A5 A0    ..
        bit     $FDE9                           ; ADA4 2C E9 FD ,..
        bpl     LADAC                           ; ADA7 10 03    ..
        txa                                     ; ADA9 8A       .
        ldx     #$00                            ; ADAA A2 00    ..
LADAC:  clc                                     ; ADAC 18       .
        adc     $A6                             ; ADAD 65 A6    e.
        sta     $A6                             ; ADAF 85 A6    ..
        txa                                     ; ADB1 8A       .
        adc     $A7                             ; ADB2 65 A7    e.
        sta     $A7                             ; ADB4 85 A7    ..
        clc                                     ; ADB6 18       .
        lda     $A1                             ; ADB7 A5 A1    ..
        adc     $FDB4                           ; ADB9 6D B4 FD m..
        bcc     LADC6                           ; ADBC 90 08    ..
        inc     $FDB5                           ; ADBE EE B5 FD ...
        bne     LADC6                           ; ADC1 D0 03    ..
        inc     $FDB6                           ; ADC3 EE B6 FD ...
LADC6:  sec                                     ; ADC6 38       8
        lda     $A3                             ; ADC7 A5 A3    ..
        sbc     $A0                             ; ADC9 E5 A0    ..
        sta     $A3                             ; ADCB 85 A3    ..
        lda     $A4                             ; ADCD A5 A4    ..
        sbc     $A1                             ; ADCF E5 A1    ..
        sta     $A4                             ; ADD1 85 A4    ..
        bcs     LADD7                           ; ADD3 B0 02    ..
        dec     $A5                             ; ADD5 C6 A5    ..
LADD7:  ora     $A3                             ; ADD7 05 A3    ..
        ora     $A5                             ; ADD9 05 A5    ..
        bne     LAD66                           ; ADDB D0 89    ..
LADDD:  lda     $FDDD                           ; ADDD AD DD FD ...
        bpl     LADEE                           ; ADE0 10 0C    ..
        cmp     #$FF                            ; ADE2 C9 FF    ..
        beq     LADEE                           ; ADE4 F0 08    ..
        and     #$7F                            ; ADE6 29 7F    ).
        tay                                     ; ADE8 A8       .
        ldx     #$0B                            ; ADE9 A2 0B    ..
        jsr     LAE37                           ; ADEB 20 37 AE  7.
LADEE:  lda     #$00                            ; ADEE A9 00    ..
        sta     $FDDD                           ; ADF0 8D DD FD ...
        rts                                     ; ADF3 60       `

; ----------------------------------------------------------------------------
LADF4:  .byte   $2C                             ; ADF4 2C       ,
LADF5:  cmp     $30FD,x                         ; ADF5 DD FD 30 ..0
        ora     $8FA9                           ; ADF8 0D A9 8F ...
        ldx     #$0C                            ; ADFB A2 0C    ..
        jsr     LAE3F                           ; ADFD 20 3F AE  ?.
        tya                                     ; AE00 98       .
        ora     #$80                            ; AE01 09 80    ..
        sta     $FDDD                           ; AE03 8D DD FD ...
LAE06:  rts                                     ; AE06 60       `

; ----------------------------------------------------------------------------
LAE07:  jsr     LAB39                           ; AE07 20 39 AB  9.
        jmp     LB937                           ; AE0A 4C 37 B9 L7.

; ----------------------------------------------------------------------------
LAE0D:  jsr     push_registers_and_tuck_restoration_thunk; AE0D 20 AB A8 ..
        lda     #$0F                            ; AE10 A9 0F    ..
        ldx     #$01                            ; AE12 A2 01    ..
        bne     LAE1E                           ; AE14 D0 08    ..
        lda     #$81                            ; AE16 A9 81    ..
        bne     LAE1C                           ; AE18 D0 02    ..
        lda     #$C7                            ; AE1A A9 C7    ..
LAE1C:  ldx     #$00                            ; AE1C A2 00    ..
LAE1E:  ldy     #$00                            ; AE1E A0 00    ..
        beq     LAE41                           ; AE20 F0 1F    ..
LAE22:  tax                                     ; AE22 AA       .
LAE23:  lda     #$03                            ; AE23 A9 03    ..
        bne     LAE41                           ; AE25 D0 1A    ..
LAE27:  lda     #$EC                            ; AE27 A9 EC    ..
        bne     LAE3D                           ; AE29 D0 12    ..
        lda     #$C7                            ; AE2B A9 C7    ..
        bne     LAE3D                           ; AE2D D0 0E    ..
LAE2F:  lda     #$EA                            ; AE2F A9 EA    ..
        bne     LAE3D                           ; AE31 D0 0A    ..
LAE33:  lda     #$A8                            ; AE33 A9 A8    ..
        bne     LAE3D                           ; AE35 D0 06    ..
LAE37:  lda     #$8F                            ; AE37 A9 8F    ..
        bne     LAE41                           ; AE39 D0 06    ..
LAE3B:  lda     #$FF                            ; AE3B A9 FF    ..
LAE3D:  ldx     #$00                            ; AE3D A2 00    ..
LAE3F:  ldy     #$FF                            ; AE3F A0 FF    ..
LAE41:  jmp     osbyte                          ; AE41 4C F4 FF L..

; ----------------------------------------------------------------------------
LAE44:  .byte   $1B                             ; AE44 1B       .
        .byte   $FF                             ; AE45 FF       .
        asl     $21FF,x                         ; AE46 1E FF 21 ..!
        .byte   $FF                             ; AE49 FF       .
        bit     $FF                             ; AE4A 24 FF    $.
        .byte   $27                             ; AE4C 27       '
        .byte   $FF                             ; AE4D FF       .
        rol     a                               ; AE4E 2A       *
        .byte   $FF                             ; AE4F FF       .
        .byte   $2D                             ; AE50 2D       -
        .byte   $FF                             ; AE51 FF       .
LAE52:  bne     LADF5                           ; AE52 D0 A1    ..
        dex                                     ; AE54 CA       .
        .byte   $9B                             ; AE55 9B       .
        and     $069D,y                         ; AE56 39 9D 06 9..
        .byte   $9E                             ; AE59 9E       .
        rol     $C9A3,x                         ; AE5A 3E A3 C9 >..
        sta     L97C7,y                         ; AE5D 99 C7 97 ...
LAE60:  .byte   $DC                             ; AE60 DC       .
        .byte   $6F                             ; AE61 6F       o
        .byte   $87                             ; AE62 87       .
        .byte   $03                             ; AE63 03       .
        .byte   $87                             ; AE64 87       .
        ora     $6C,x                           ; AE65 15 6C    .l
        .byte   $7E                             ; AE67 7E       ~
        .byte   $83                             ; AE68 83       .
LAE69:  .byte   $97                             ; AE69 97       .
        tya                                     ; AE6A 98       .
        tya                                     ; AE6B 98       .
        sta     L9998,y                         ; AE6C 99 98 99 ...
        sta     L9999,y                         ; AE6F 99 99 99 ...
LAE72:  ora     #$F3                            ; AE72 09 F3    ..
        .byte   $F6                             ; AE74 F6       .
LAE75:  .byte   $9C                             ; AE75 9C       .
        .byte   $9B                             ; AE76 9B       .
        .byte   $9B                             ; AE77 9B       .
LAE78:  bvc     LAE7B                           ; AE78 50 01    P.
        .byte   $11                             ; AE7A 11       .
LAE7B:  .byte   $1C                             ; AE7B 1C       .
        bit     $2C                             ; AE7C 24 2C    $,
        .byte   $3B                             ; AE7E 3B       ;
        .byte   $44                             ; AE7F 44       D
LAE80:  ldx     #$A2                            ; AE80 A2 A2    ..
        ldx     #$A2                            ; AE82 A2 A2    ..
        ldx     #$A2                            ; AE84 A2 A2    ..
        ldx     #$A2                            ; AE86 A2 A2    ..
LAE88:  sbc     $FEFE,x                         ; AE88 FD FE FE ...
        asl     $06                             ; AE8B 06 06    ..
        asl     $5243                           ; AE8D 0E 43 52 .CR
        .byte   $61                             ; AE90 61       a
LAE91:  .byte   $A3                             ; AE91 A3       .
        .byte   $A3                             ; AE92 A3       .
        .byte   $A3                             ; AE93 A3       .
        ldy     $A4                             ; AE94 A4 A4    ..
        ldy     $A4                             ; AE96 A4 A4    ..
        ldy     $A4                             ; AE98 A4 A4    ..
LAE9A:  .byte   $04                             ; AE9A 04       .
        .byte   $02                             ; AE9B 02       .
        .byte   $03                             ; AE9C 03       .
        asl     $07                             ; AE9D 06 07    ..
        .byte   $04                             ; AE9F 04       .
        .byte   $04                             ; AEA0 04       .
        .byte   $04                             ; AEA1 04       .
        .byte   $04                             ; AEA2 04       .
LAEA3:  jsr     LA933                           ; AEA3 20 33 A9  3.
        .byte   "OPUS CHALLENGER 1.01 "         ; AEA6 4F 50 55 53 20 43 48 41OPUS CHA
                                                ; AEAE 4C 4C 45 4E 47 45 52 20LLENGER 
                                                ; AEB6 31 2E 30 31 201.01 
; ----------------------------------------------------------------------------
        nop                                     ; AEBB EA       .
        jsr     L81E9                           ; AEBC 20 E9 81  ..
        and     #$03                            ; AEBF 29 03    ).
        ora     #$04                            ; AEC1 09 04    ..
        tax                                     ; AEC3 AA       .
        jsr     L8FA1                           ; AEC4 20 A1 8F  ..
        jsr     L841A                           ; AEC7 20 1A 84  ..
        jmp     L841A                           ; AECA 4C 1A 84 L..

; ----------------------------------------------------------------------------
format_command:
        jsr     LAA52                           ; AECD 20 52 AA  R.
        beq     LAEE9                           ; AED0 F0 17    ..
LAED2:  jsr     gsread                          ; AED2 20 C5 FF  ..
        bcc     LAEDB                           ; AED5 90 04    ..
        lda     #$0D                            ; AED7 A9 0D    ..
        ldy     #$00                            ; AED9 A0 00    ..
LAEDB:  sty     $B7                             ; AEDB 84 B7    ..
        tay                                     ; AEDD A8       .
        ldx     #$00                            ; AEDE A2 00    ..
        lda     #$99                            ; AEE0 A9 99    ..
        jsr     osbyte                          ; AEE2 20 F4 FF  ..
        ldy     $B7                             ; AEE5 A4 B7    ..
        bne     LAED2                           ; AEE7 D0 E9    ..
LAEE9:  jsr     LA89E                           ; AEE9 20 9E A8  ..
        tsx                                     ; AEEC BA       .
        stx     $B7                             ; AEED 86 B7    ..
        stx     $B8                             ; AEEF 86 B8    ..
        jsr     L960B                           ; AEF1 20 0B 96  ..
        jsr     LB05D                           ; AEF4 20 5D B0  ].
        jsr     LB2FD                           ; AEF7 20 FD B2  ..
LAEFA:  jsr     LB330                           ; AEFA 20 30 B3  0.
LAEFD:  jsr     LA977                           ; AEFD 20 77 A9  w.
        .byte   $1F                             ; AF00 1F       .
        brk                                     ; AF01 00       .
        .byte   $13                             ; AF02 13       .
        .byte   $83                             ; AF03 83       .
        .byte   $44                             ; AF04 44       D
        .byte   $72                             ; AF05 72       r
        adc     #$76                            ; AF06 69 76    iv
        adc     $20                             ; AF08 65 20    e 
        ror     $6D75                           ; AF0A 6E 75 6D num
        .byte   $62                             ; AF0D 62       b
        adc     $72                             ; AF0E 65 72    er
        jsr     L3028                           ; AF10 20 28 30  (0
        and     $2937                           ; AF13 2D 37 29 -7)
        jsr     L20FF                           ; AF16 20 FF 20  . 
        .byte   $22                             ; AF19 22       "
        ldx     $38,y                           ; AF1A B6 38    .8
        sbc     #$30                            ; AF1C E9 30    .0
        bcc     LAEFD                           ; AF1E 90 DD    ..
        cmp     #$08                            ; AF20 C9 08    ..
        bcc     LAF29                           ; AF22 90 05    ..
        jsr     LB7A2                           ; AF24 20 A2 B7  ..
        bne     LAEFA                           ; AF27 D0 D1    ..
LAF29:  sta     $CF                             ; AF29 85 CF    ..
LAF2B:  ldx     #$F4                            ; AF2B A2 F4    ..
        ldy     #$AE                            ; AF2D A0 AE    ..
        jsr     LB061                           ; AF2F 20 61 B0  a.
        jsr     LA977                           ; AF32 20 77 A9  w.
        .byte   $1F                             ; AF35 1F       .
        brk                                     ; AF36 00       .
        .byte   $14                             ; AF37 14       .
        .byte   $83                             ; AF38 83       .
        bmi     LAF78                           ; AF39 30 3D    0=
        .byte   $34                             ; AF3B 34       4
        bmi     LAF6A                           ; AF3C 30 2C    0,
        jsr     L3D31                           ; AF3E 20 31 3D  1=
        sec                                     ; AF41 38       8
        bmi     LAF64                           ; AF42 30 20    0 
        .byte   $74                             ; AF44 74       t
        .byte   $72                             ; AF45 72       r
        adc     ($63,x)                         ; AF46 61 63    ac
        .byte   $6B                             ; AF48 6B       k
        .byte   $73                             ; AF49 73       s
        jsr     L203A                           ; AF4A 20 3A 20  : 
        jsr     L7F7F                           ; AF4D 20 7F 7F  ..
        .byte   $FF                             ; AF50 FF       .
        jsr     LB7B2                           ; AF51 20 B2 B7  ..
        bne     LAF59                           ; AF54 D0 03    ..
        jmp     LAFFF                           ; AF56 4C FF AF L..

; ----------------------------------------------------------------------------
LAF59:  jsr     LB622                           ; AF59 20 22 B6  ".
        ldx     #$28                            ; AF5C A2 28    .(
        cmp     #$30                            ; AF5E C9 30    .0
        beq     LAF68                           ; AF60 F0 06    ..
        ldx     #$50                            ; AF62 A2 50    .P
LAF64:  cmp     #$31                            ; AF64 C9 31    .1
        bne     LAF2B                           ; AF66 D0 C3    ..
LAF68:  stx     L00C0                           ; AF68 86 C0    ..
LAF6A:  ldx     #$50                            ; AF6A A2 50    .P
        lda     $FDEA                           ; AF6C AD EA FD ...
        bpl     LAF76                           ; AF6F 10 05    ..
        and     #$80                            ; AF71 29 80    ).
        sta     $FDEA                           ; AF73 8D EA FD ...
LAF76:  .byte   $2C                             ; AF76 2C       ,
        nop                                     ; AF77 EA       .
LAF78:  sbc     $0250,x                         ; AF78 FD 50 02 .P.
        ldx     #$28                            ; AF7B A2 28    .(
        cpx     L00C0                           ; AF7D E4 C0    ..
        bcs     LAF86                           ; AF7F B0 05    ..
        jsr     LB7A2                           ; AF81 20 A2 B7  ..
        bne     LAF2B                           ; AF84 D0 A5    ..
LAF86:  jsr     LB330                           ; AF86 20 30 B3  0.
LAF89:  jsr     LA977                           ; AF89 20 77 A9  w.
        .byte   $1F                             ; AF8C 1F       .
        brk                                     ; AF8D 00       .
        ora     $83,x                           ; AF8E 15 83    ..
        .byte   $44                             ; AF90 44       D
        adc     $6E                             ; AF91 65 6E    en
        .byte   $73                             ; AF93 73       s
        adc     #$74                            ; AF94 69 74    it
        adc     L2820,y                         ; AF96 79 20 28 y (
        .byte   $53                             ; AF99 53       S
        .byte   $2F                             ; AF9A 2F       /
        .byte   $44                             ; AF9B 44       D
        and     #$20                            ; AF9C 29 20    ) 
        .byte   $FF                             ; AF9E FF       .
        jsr     LB622                           ; AF9F 20 22 B6  ".
        cmp     #$53                            ; AFA2 C9 53    .S
        beq     LAFDE                           ; AFA4 F0 38    .8
        cmp     #$44                            ; AFA6 C9 44    .D
        beq     LAFB0                           ; AFA8 F0 06    ..
        jsr     LB7A2                           ; AFAA 20 A2 B7  ..
        jmp     LAF89                           ; AFAD 4C 89 AF L..

; ----------------------------------------------------------------------------
LAFB0:  lda     $FDED                           ; AFB0 AD ED FD ...
        ora     #$40                            ; AFB3 09 40    .@
        sta     $FDED                           ; AFB5 8D ED FD ...
        lda     #$12                            ; AFB8 A9 12    ..
        sta     $FDEB                           ; AFBA 8D EB FD ...
        jsr     LB6B9                           ; AFBD 20 B9 B6  ..
        bcs     LAFD6                           ; AFC0 B0 14    ..
        ldx     L00C0                           ; AFC2 A6 C0    ..
        dex                                     ; AFC4 CA       .
        stx     $B0                             ; AFC5 86 B0    ..
        jsr     LB5A9                           ; AFC7 20 A9 B5  ..
        jsr     LB469                           ; AFCA 20 69 B4  i.
        jsr     LB4B5                           ; AFCD 20 B5 B4  ..
        jsr     LB4CE                           ; AFD0 20 CE B4  ..
        jsr     LAD3A                           ; AFD3 20 3A AD  :.
LAFD6:  jsr     LB075                           ; AFD6 20 75 B0  u.
        beq     LAFB0                           ; AFD9 F0 D5    ..
        jmp     LB068                           ; AFDB 4C 68 B0 Lh.

; ----------------------------------------------------------------------------
LAFDE:  lda     $FDED                           ; AFDE AD ED FD ...
        and     #$80                            ; AFE1 29 80    ).
        sta     $FDED                           ; AFE3 8D ED FD ...
        lda     #$0A                            ; AFE6 A9 0A    ..
        sta     $FDEB                           ; AFE8 8D EB FD ...
        jsr     LB6B9                           ; AFEB 20 B9 B6  ..
        bcs     LAFF7                           ; AFEE B0 07    ..
        ldx     L00C0                           ; AFF0 A6 C0    ..
        stx     $B0                             ; AFF2 86 B0    ..
        jsr     LB09D                           ; AFF4 20 9D B0  ..
LAFF7:  jsr     LB075                           ; AFF7 20 75 B0  u.
        beq     LAFDE                           ; AFFA F0 E2    ..
        jmp     LB068                           ; AFFC 4C 68 B0 Lh.

; ----------------------------------------------------------------------------
LAFFF:  jsr     LA977                           ; AFFF 20 77 A9  w.
        .byte   $7F                             ; B002 7F       .
        .byte   $7F                             ; B003 7F       .
        bit     $3220                           ; B004 2C 20 32 , 2
        and     $614D,x                         ; B007 3D 4D 61 =Ma
        sei                                     ; B00A 78       x
        jsr     L4152                           ; B00B 20 52 41  RA
        eor     $6420                           ; B00E 4D 20 64 M d
        adc     #$73                            ; B011 69 73    is
        .byte   $6B                             ; B013 6B       k
        jsr     L20FF                           ; B014 20 FF 20  . 
        .byte   $22                             ; B017 22       "
        ldx     $38,y                           ; B018 B6 38    .8
        sbc     #$30                            ; B01A E9 30    .0
        bcc     LB03A                           ; B01C 90 1C    ..
        cmp     #$03                            ; B01E C9 03    ..
        bcs     LB03A                           ; B020 B0 18    ..
        pha                                     ; B022 48       H
        jsr     LB674                           ; B023 20 74 B6  t.
        pla                                     ; B026 68       h
        tax                                     ; B027 AA       .
        cpx     #$02                            ; B028 E0 02    ..
        bne     LB034                           ; B02A D0 08    ..
        jsr     LAB39                           ; B02C 20 39 AB  9.
        cmp     #$05                            ; B02F C9 05    ..
        bne     LB034                           ; B031 D0 01    ..
        inx                                     ; B033 E8       .
LB034:  jsr     LB040                           ; B034 20 40 B0  @.
        jmp     LB068                           ; B037 4C 68 B0 Lh.

; ----------------------------------------------------------------------------
LB03A:  jsr     LB7A2                           ; B03A 20 A2 B7  ..
        jmp     LAF2B                           ; B03D 4C 2B AF L+.

; ----------------------------------------------------------------------------
LB040:  lda     LB055,x                         ; B040 BD 55 B0 .U.
        sta     $C4                             ; B043 85 C4    ..
        lda     LB059,x                         ; B045 BD 59 B0 .Y.
        sta     $C5                             ; B048 85 C5    ..
        jsr     LADF4                           ; B04A 20 F4 AD  ..
        ldy     #$00                            ; B04D A0 00    ..
        jsr     LB0A4                           ; B04F 20 A4 B0  ..
        jmp     LADDD                           ; B052 4C DD AD L..

; ----------------------------------------------------------------------------
LB055:  bcc     LB077                           ; B055 90 20    . 
        sbc     $FF,x                           ; B057 F5 FF    ..
LB059:  ora     ($03,x)                         ; B059 01 03    ..
        .byte   $03                             ; B05B 03       .
        .byte   $03                             ; B05C 03       .
LB05D:  ldx     #$68                            ; B05D A2 68    .h
        ldy     #$B0                            ; B05F A0 B0    ..
LB061:  stx     LFDE6                           ; B061 8E E6 FD ...
        sty     $FDE7                           ; B064 8C E7 FD ...
        rts                                     ; B067 60       `

; ----------------------------------------------------------------------------
LB068:  ldx     $B8                             ; B068 A6 B8    ..
        txs                                     ; B06A 9A       .
        jsr     LB6AD                           ; B06B 20 AD B6  ..
        ldx     #$00                            ; B06E A2 00    ..
        ldy     #$18                            ; B070 A0 18    ..
        jmp     LB323                           ; B072 4C 23 B3 L#.

; ----------------------------------------------------------------------------
LB075:  .byte   $20                             ; B075 20        
        .byte   $77                             ; B076 77       w
LB077:  lda     #$1F                            ; B077 A9 1F    ..
        php                                     ; B079 08       .
        bpl     LAFFF                           ; B07A 10 83    ..
        lsr     $6F                             ; B07C 46 6F    Fo
        .byte   $72                             ; B07E 72       r
        adc     $7461                           ; B07F 6D 61 74 mat
        jsr     L6F63                           ; B082 20 63 6F  co
        adc     $6C70                           ; B085 6D 70 6C mpl
        adc     $74                             ; B088 65 74    et
        adc     $0D                             ; B08A 65 0D    e.
        asl     a                               ; B08C 0A       .
        .byte   $83                             ; B08D 83       .
        .byte   $52                             ; B08E 52       R
        adc     $70                             ; B08F 65 70    ep
        adc     $61                             ; B091 65 61    ea
        .byte   $74                             ; B093 74       t
        .byte   $3F                             ; B094 3F       ?
        jsr     L20FF                           ; B095 20 FF 20  . 
        eor     $B6                             ; B098 45 B6    E.
        cmp     #$59                            ; B09A C9 59    .Y
        rts                                     ; B09C 60       `

; ----------------------------------------------------------------------------
LB09D:  jsr     LB5A9                           ; B09D 20 A9 B5  ..
        ldy     #$00                            ; B0A0 A0 00    ..
        sty     $BA                             ; B0A2 84 BA    ..
LB0A4:  jsr     push_registers_and_tuck_restoration_thunk; B0A4 20 AB A8 ..
        sty     $BB                             ; B0A7 84 BB    ..
        lda     #$00                            ; B0A9 A9 00    ..
        sta     $BA                             ; B0AB 85 BA    ..
        jsr     LB441                           ; B0AD 20 41 B4  A.
        jsr     select_ram_page_003             ; B0B0 20 32 BE  2.
        lda     $C5                             ; B0B3 A5 C5    ..
        sta     $FD06                           ; B0B5 8D 06 FD ...
        lda     $C4                             ; B0B8 A5 C4    ..
        sta     $FD07                           ; B0BA 8D 07 FD ...
        jmp     L96EB                           ; B0BD 4C EB 96 L..

; ----------------------------------------------------------------------------
verify_command:
        jsr     LB7A7                           ; B0C0 20 A7 B7  ..
        tsx                                     ; B0C3 BA       .
        stx     $B8                             ; B0C4 86 B8    ..
        stx     $B7                             ; B0C6 86 B7    ..
        jsr     LA89E                           ; B0C8 20 9E A8  ..
        jsr     L960B                           ; B0CB 20 0B 96  ..
        jsr     LB05D                           ; B0CE 20 5D B0  ].
        jsr     LB7BE                           ; B0D1 20 BE B7  ..
LB0D4:  jsr     LA977                           ; B0D4 20 77 A9  w.
        .byte   $83                             ; B0D7 83       .
        sta     $2056                           ; B0D8 8D 56 20 .V 
        eor     $20                             ; B0DB 45 20    E 
        .byte   $52                             ; B0DD 52       R
        jsr     L2049                           ; B0DE 20 49 20  I 
        lsr     $20                             ; B0E1 46 20    F 
        eor     L20FF,y                         ; B0E3 59 FF 20 Y. 
        .byte   $C3                             ; B0E6 C3       .
        .byte   $B7                             ; B0E7 B7       .
        bne     LB0D4                           ; B0E8 D0 EA    ..
        jsr     LA977                           ; B0EA 20 77 A9  w.
        .byte   $1F                             ; B0ED 1F       .
        brk                                     ; B0EE 00       .
        bpl     LB13A                           ; B0EF 10 49    .I
        ror     $6573                           ; B0F1 6E 73 65 nse
        .byte   $72                             ; B0F4 72       r
        .byte   $74                             ; B0F5 74       t
        jsr     L6964                           ; B0F6 20 64 69  di
        .byte   $73                             ; B0F9 73       s
        .byte   $6B                             ; B0FA 6B       k
        .byte   $FF                             ; B0FB FF       .
        jsr     LB76C                           ; B0FC 20 6C B7  l.
        ldx     #$CE                            ; B0FF A2 CE    ..
        ldy     #$B0                            ; B101 A0 B0    ..
        jsr     LB061                           ; B103 20 61 B0  a.
        lda     #$00                            ; B106 A9 00    ..
        sta     $FDE9                           ; B108 8D E9 FD ...
        jsr     LABEE                           ; B10B 20 EE AB  ..
        bit     $FDED                           ; B10E 2C ED FD ,..
        bvs     LB139                           ; B111 70 26    p&
        jsr     L969E                           ; B113 20 9E 96  ..
        jsr     select_ram_page_003             ; B116 20 32 BE  2.
        lda     $FD06                           ; B119 AD 06 FD ...
        and     #$03                            ; B11C 29 03    ).
        sta     $B1                             ; B11E 85 B1    ..
        lda     $FD07                           ; B120 AD 07 FD ...
        sta     $B0                             ; B123 85 B0    ..
        jsr     select_ram_page_001             ; B125 20 28 BE  (.
        lda     #$00                            ; B128 A9 00    ..
        sta     $B3                             ; B12A 85 B3    ..
        lda     $FDEB                           ; B12C AD EB FD ...
        sta     $B2                             ; B12F 85 B2    ..
        jsr     LB3B1                           ; B131 20 B1 B3  ..
        stx     L00C0                           ; B134 86 C0    ..
        jmp     LB144                           ; B136 4C 44 B1 LD.

; ----------------------------------------------------------------------------
LB139:  .byte   $20                             ; B139 20        
LB13A:  .byte   $37                             ; B13A 37       7
        lda     $2D20                           ; B13B AD 20 2D . -
        ldx     $04AD,y                         ; B13E BE AD 04 ...
        sbc     $C085,x                         ; B141 FD 85 C0 ...
LB144:  jsr     select_ram_page_001             ; B144 20 28 BE  (.
        lda     #$00                            ; B147 A9 00    ..
        sta     $BA                             ; B149 85 BA    ..
        clc                                     ; B14B 18       .
LB14C:  php                                     ; B14C 08       .
        jsr     LB717                           ; B14D 20 17 B7  ..
        jsr     LB169                           ; B150 20 69 B1  i.
        beq     LB158                           ; B153 F0 03    ..
        plp                                     ; B155 28       (
        sec                                     ; B156 38       8
        php                                     ; B157 08       .
LB158:  inc     $BA                             ; B158 E6 BA    ..
        lda     $BA                             ; B15A A5 BA    ..
        cmp     L00C0                           ; B15C C5 C0    ..
        bcc     LB14C                           ; B15E 90 EC    ..
        plp                                     ; B160 28       (
        bcs     LB182                           ; B161 B0 1F    ..
        jsr     LB948                           ; B163 20 48 B9  H.
        jmp     LB068                           ; B166 4C 68 B0 Lh.

; ----------------------------------------------------------------------------
LB169:  ldx     #$03                            ; B169 A2 03    ..
        ldy     #$03                            ; B16B A0 03    ..
        jsr     LB792                           ; B16D 20 92 B7  ..
LB170:  jsr     LB33C                           ; B170 20 3C B3  <.
        jsr     LBA46                           ; B173 20 46 BA  F.
        beq     LB181                           ; B176 F0 09    ..
        lda     #$2E                            ; B178 A9 2E    ..
        jsr     oswrch                          ; B17A 20 EE FF  ..
        dex                                     ; B17D CA       .
        bne     LB170                           ; B17E D0 F0    ..
        dex                                     ; B180 CA       .
LB181:  rts                                     ; B181 60       `

; ----------------------------------------------------------------------------
LB182:  jsr     LB662                           ; B182 20 62 B6  b.
        jmp     LB068                           ; B185 4C 68 B0 Lh.

; ----------------------------------------------------------------------------
volgen_command:
        jsr     LB7A7                           ; B188 20 A7 B7  ..
        jsr     LA89E                           ; B18B 20 9E A8  ..
        tsx                                     ; B18E BA       .
        stx     $B8                             ; B18F 86 B8    ..
        jsr     LA7BE                           ; B191 20 BE A7  ..
        jsr     L960B                           ; B194 20 0B 96  ..
        jsr     LB948                           ; B197 20 48 B9  H.
        lda     #$00                            ; B19A A9 00    ..
        sta     $FDEC                           ; B19C 8D EC FD ...
        jsr     LB2C4                           ; B19F 20 C4 B2  ..
        lda     $CF                             ; B1A2 A5 CF    ..
        and     #$0F                            ; B1A4 29 0F    ).
        sta     $CF                             ; B1A6 85 CF    ..
        jsr     LB7BE                           ; B1A8 20 BE B7  ..
LB1AB:  jsr     LA977                           ; B1AB 20 77 A9  w.
        .byte   $83                             ; B1AE 83       .
        sta     $2056                           ; B1AF 8D 56 20 .V 
        .byte   $4F                             ; B1B2 4F       O
        jsr     L204C                           ; B1B3 20 4C 20  L 
        .byte   $47                             ; B1B6 47       G
        jsr     L2045                           ; B1B7 20 45 20  E 
        lsr     L20FF                           ; B1BA 4E FF 20 N. 
        .byte   $C3                             ; B1BD C3       .
        .byte   $B7                             ; B1BE B7       .
        bne     LB1AB                           ; B1BF D0 EA    ..
        jsr     LA977                           ; B1C1 20 77 A9  w.
        .byte   $1F                             ; B1C4 1F       .
        brk                                     ; B1C5 00       .
        .byte   $04                             ; B1C6 04       .
        ora     $5683                           ; B1C7 0D 83 56 ..V
        .byte   $6F                             ; B1CA 6F       o
        jmp     (L2020)                         ; B1CB 6C 20 20 l  

; ----------------------------------------------------------------------------
        .byte   $53                             ; B1CE 53       S
        adc     #$7A                            ; B1CF 69 7A    iz
        adc     $20                             ; B1D1 65 20    e 
        jsr     L2820                           ; B1D3 20 20 28   (
        .byte   $4B                             ; B1D6 4B       K
        and     #$20                            ; B1D7 29 20    ) 
        .byte   $FF                             ; B1D9 FF       .
        lda     $CF                             ; B1DA A5 CF    ..
        jsr     L8E4D                           ; B1DC 20 4D 8E  M.
        jsr     LA977                           ; B1DF 20 77 A9  w.
        .byte   $1F                             ; B1E2 1F       .
        brk                                     ; B1E3 00       .
        .byte   $0F                             ; B1E4 0F       .
        .byte   $83                             ; B1E5 83       .
        lsr     $72                             ; B1E6 46 72    Fr
        adc     $65                             ; B1E8 65 65    ee
        .byte   $FF                             ; B1EA FF       .
        jsr     LB529                           ; B1EB 20 29 B5  ).
        lda     #$07                            ; B1EE A9 07    ..
        sta     $C1                             ; B1F0 85 C1    ..
LB1F2:  jsr     LB40E                           ; B1F2 20 0E B4  ..
        dec     $C1                             ; B1F5 C6 C1    ..
        bpl     LB1F2                           ; B1F7 10 F9    ..
LB1F9:  jsr     LB05D                           ; B1F9 20 5D B0  ].
LB1FC:  jsr     LB5C4                           ; B1FC 20 C4 B5  ..
        ldx     #$05                            ; B1FF A2 05    ..
        ldy     #$0F                            ; B201 A0 0F    ..
        jsr     LB323                           ; B203 20 23 B3  #.
        jsr     LB3D2                           ; B206 20 D2 B3  ..
        jmp     LB20F                           ; B209 4C 0F B2 L..

; ----------------------------------------------------------------------------
LB20C:  jsr     LB7A2                           ; B20C 20 A2 B7  ..
LB20F:  jsr     LA977                           ; B20F 20 77 A9  w.
        .byte   $1F                             ; B212 1F       .
        brk                                     ; B213 00       .
        .byte   $17                             ; B214 17       .
        lsr     $4F,x                           ; B215 56 4F    VO
        jmp     L4D55                           ; B217 4C 55 4D LUM

; ----------------------------------------------------------------------------
        eor     $20                             ; B21A 45 20    E 
        .byte   $3A                             ; B21C 3A       :
        jsr     L2020                           ; B21D 20 20 20    
        jsr     L2020                           ; B220 20 20 20    
        plp                                     ; B223 28       (
        .byte   $57                             ; B224 57       W
        jsr     L6F74                           ; B225 20 74 6F  to
        jsr     L6F63                           ; B228 20 63 6F  co
        ror     $6966                           ; B22B 6E 66 69 nfi
        .byte   $67                             ; B22E 67       g
        adc     $72,x                           ; B22F 75 72    ur
        adc     L0029                           ; B231 65 29    e)
        .byte   $1F                             ; B233 1F       .
        php                                     ; B234 08       .
        .byte   $17                             ; B235 17       .
        .byte   $FF                             ; B236 FF       .
        jsr     LB645                           ; B237 20 45 B6  E.
        cmp     #$57                            ; B23A C9 57    .W
        bne     LB241                           ; B23C D0 03    ..
        jmp     LB2A0                           ; B23E 4C A0 B2 L..

; ----------------------------------------------------------------------------
LB241:  sec                                     ; B241 38       8
        sbc     #$41                            ; B242 E9 41    .A
        bcc     LB20C                           ; B244 90 C6    ..
        cmp     #$08                            ; B246 C9 08    ..
        bcs     LB20C                           ; B248 B0 C2    ..
        sta     $C1                             ; B24A 85 C1    ..
        adc     #$41                            ; B24C 69 41    iA
        jsr     oswrch                          ; B24E 20 EE FF  ..
        lda     #$20                            ; B251 A9 20    . 
        jsr     oswrch                          ; B253 20 EE FF  ..
        jsr     LB357                           ; B256 20 57 B3  W.
        bcs     LB20F                           ; B259 B0 B4    ..
        lda     L00AA                           ; B25B A5 AA    ..
        ora     $AB                             ; B25D 05 AB    ..
        bne     LB26E                           ; B25F D0 0D    ..
        lda     $C1                             ; B261 A5 C1    ..
        beq     LB20C                           ; B263 F0 A7    ..
        jsr     LB2ED                           ; B265 20 ED B2  ..
        jsr     LB40E                           ; B268 20 0E B4  ..
        jmp     LB1FC                           ; B26B 4C FC B1 L..

; ----------------------------------------------------------------------------
LB26E:  lda     $AB                             ; B26E A5 AB    ..
        cmp     #$04                            ; B270 C9 04    ..
        bcs     LB20C                           ; B272 B0 98    ..
        jsr     LB2ED                           ; B274 20 ED B2  ..
        jsr     LB5C4                           ; B277 20 C4 B5  ..
        lda     L00A8                           ; B27A A5 A8    ..
        cmp     L00AA                           ; B27C C5 AA    ..
        lda     $A9                             ; B27E A5 A9    ..
        sbc     $AB                             ; B280 E5 AB    ..
        bcs     LB28C                           ; B282 B0 08    ..
        lda     L00A8                           ; B284 A5 A8    ..
        sta     L00AA                           ; B286 85 AA    ..
        lda     $A9                             ; B288 A5 A9    ..
        sta     $AB                             ; B28A 85 AB    ..
LB28C:  lda     $C1                             ; B28C A5 C1    ..
        asl     a                               ; B28E 0A       .
        tay                                     ; B28F A8       .
        lda     $AB                             ; B290 A5 AB    ..
        sta     $FDC4,y                         ; B292 99 C4 FD ...
        lda     L00AA                           ; B295 A5 AA    ..
        sta     $FDC5,y                         ; B297 99 C5 FD ...
        jsr     LB40E                           ; B29A 20 0E B4  ..
        jmp     LB1FC                           ; B29D 4C FC B1 L..

; ----------------------------------------------------------------------------
LB2A0:  ldx     #$F9                            ; B2A0 A2 F9    ..
        ldy     #$B1                            ; B2A2 A0 B1    ..
        jsr     LB061                           ; B2A4 20 61 B0  a.
        jsr     LB76C                           ; B2A7 20 6C B7  l.
        jsr     LB2C4                           ; B2AA 20 C4 B2  ..
        jsr     LB737                           ; B2AD 20 37 B7  7.
        beq     LB2B5                           ; B2B0 F0 03    ..
        jmp     LB1F9                           ; B2B2 4C F9 B1 L..

; ----------------------------------------------------------------------------
LB2B5:  jsr     LB441                           ; B2B5 20 41 B4  A.
        jsr     LB4B5                           ; B2B8 20 B5 B4  ..
        jsr     LB4CE                           ; B2BB 20 CE B4  ..
        jsr     LAD3A                           ; B2BE 20 3A AD  :.
        jmp     LB068                           ; B2C1 4C 68 B0 Lh.

; ----------------------------------------------------------------------------
LB2C4:  jsr     LB9AB                           ; B2C4 20 AB B9  ..
        bit     $FDED                           ; B2C7 2C ED FD ,..
        bvs     LB2EC                           ; B2CA 70 20    p 
        jsr     LA90D                           ; B2CC 20 0D A9  ..
        .byte   $C9                             ; B2CF C9       .
        .byte   "Disk must be double density"   ; B2D0 44 69 73 6B 20 6D 75 73Disk mus
                                                ; B2D8 74 20 62 65 20 64 6F 75t be dou
                                                ; B2E0 62 6C 65 20 64 65 6E 73ble dens
                                                ; B2E8 69 74 79 ity
        .byte   $00                             ; B2EB 00       .
; ----------------------------------------------------------------------------
LB2EC:  rts                                     ; B2EC 60       `

; ----------------------------------------------------------------------------
LB2ED:  lda     $C1                             ; B2ED A5 C1    ..
        asl     a                               ; B2EF 0A       .
        tay                                     ; B2F0 A8       .
        jsr     select_ram_page_000             ; B2F1 20 23 BE  #.
        lda     #$00                            ; B2F4 A9 00    ..
        sta     $FDC4,y                         ; B2F6 99 C4 FD ...
        sta     $FDC5,y                         ; B2F9 99 C5 FD ...
        rts                                     ; B2FC 60       `

; ----------------------------------------------------------------------------
LB2FD:  jsr     LB7BE                           ; B2FD 20 BE B7  ..
LB300:  jsr     LA977                           ; B300 20 77 A9  w.
        .byte   $83                             ; B303 83       .
        sta     $2046                           ; B304 8D 46 20 .F 
        .byte   $4F                             ; B307 4F       O
        jsr     L2052                           ; B308 20 52 20  R 
        eor     $4120                           ; B30B 4D 20 41 M A
        jsr     LFF54                           ; B30E 20 54 FF  T.
        jsr     LB7C3                           ; B311 20 C3 B7  ..
        bne     LB300                           ; B314 D0 EA    ..
LB316:  rts                                     ; B316 60       `

; ----------------------------------------------------------------------------
LB317:  lda     #$07                            ; B317 A9 07    ..
        pha                                     ; B319 48       H
        lda     #$16                            ; B31A A9 16    ..
        jsr     oswrch                          ; B31C 20 EE FF  ..
        pla                                     ; B31F 68       h
        jmp     oswrch                          ; B320 4C EE FF L..

; ----------------------------------------------------------------------------
LB323:  lda     #$1F                            ; B323 A9 1F    ..
        jsr     oswrch                          ; B325 20 EE FF  ..
        txa                                     ; B328 8A       .
        jsr     oswrch                          ; B329 20 EE FF  ..
        tya                                     ; B32C 98       .
        jmp     oswrch                          ; B32D 4C EE FF L..

; ----------------------------------------------------------------------------
LB330:  ldx     #$00                            ; B330 A2 00    ..
        ldy     #$17                            ; B332 A0 17    ..
        jsr     LB323                           ; B334 20 23 B3  #.
        ldy     #$28                            ; B337 A0 28    .(
        jmp     L8A8E                           ; B339 4C 8E 8A L..

; ----------------------------------------------------------------------------
LB33C:  bit     $FF                             ; B33C 24 FF    $.
        bpl     LB316                           ; B33E 10 D6    ..
        jsr     LA9EF                           ; B340 20 EF A9  ..
        jsr     LADDD                           ; B343 20 DD AD  ..
        ldx     $B7                             ; B346 A6 B7    ..
        txs                                     ; B348 9A       .
        jmp     (LFDE6)                         ; B349 6C E6 FD l..

; ----------------------------------------------------------------------------
LB34C:  ldx     #$01                            ; B34C A2 01    ..
        clc                                     ; B34E 18       .
        lda     $C1                             ; B34F A5 C1    ..
        adc     #$06                            ; B351 69 06    i.
        tay                                     ; B353 A8       .
        jmp     LB323                           ; B354 4C 23 B3 L#.

; ----------------------------------------------------------------------------
LB357:  ldy     #$00                            ; B357 A0 00    ..
        sty     L00AA                           ; B359 84 AA    ..
        sty     $AB                             ; B35B 84 AB    ..
LB35D:  jsr     LB645                           ; B35D 20 45 B6  E.
        cmp     #$0D                            ; B360 C9 0D    ..
        bne     LB366                           ; B362 D0 02    ..
        clc                                     ; B364 18       .
        rts                                     ; B365 60       `

; ----------------------------------------------------------------------------
LB366:  cmp     #$7F                            ; B366 C9 7F    ..
        bne     LB37F                           ; B368 D0 15    ..
        tya                                     ; B36A 98       .
        bne     LB36F                           ; B36B D0 02    ..
        sec                                     ; B36D 38       8
        rts                                     ; B36E 60       `

; ----------------------------------------------------------------------------
LB36F:  jsr     LB39A                           ; B36F 20 9A B3  ..
        dey                                     ; B372 88       .
        ldx     #$04                            ; B373 A2 04    ..
LB375:  lsr     $AB                             ; B375 46 AB    F.
        ror     L00AA                           ; B377 66 AA    f.
        dex                                     ; B379 CA       .
        bne     LB375                           ; B37A D0 F9    ..
        jmp     LB35D                           ; B37C 4C 5D B3 L].

; ----------------------------------------------------------------------------
LB37F:  cpy     #$03                            ; B37F C0 03    ..
        beq     LB35D                           ; B381 F0 DA    ..
        jsr     LAA41                           ; B383 20 41 AA  A.
        jsr     LA9E0                           ; B386 20 E0 A9  ..
        ldx     #$04                            ; B389 A2 04    ..
LB38B:  asl     L00AA                           ; B38B 06 AA    ..
        rol     $AB                             ; B38D 26 AB    &.
        dex                                     ; B38F CA       .
        bne     LB38B                           ; B390 D0 F9    ..
        ora     L00AA                           ; B392 05 AA    ..
        sta     L00AA                           ; B394 85 AA    ..
        iny                                     ; B396 C8       .
        jmp     LB35D                           ; B397 4C 5D B3 L].

; ----------------------------------------------------------------------------
LB39A:  jsr     LB3A2                           ; B39A 20 A2 B3  ..
        lda     #$20                            ; B39D A9 20    . 
        jsr     oswrch                          ; B39F 20 EE FF  ..
LB3A2:  lda     #$7F                            ; B3A2 A9 7F    ..
        jmp     oswrch                          ; B3A4 4C EE FF L..

; ----------------------------------------------------------------------------
        sec                                     ; B3A7 38       8
        sbc     #$30                            ; B3A8 E9 30    .0
        bcc     LB3AF                           ; B3AA 90 03    ..
        cmp     #$0A                            ; B3AC C9 0A    ..
        rts                                     ; B3AE 60       `

; ----------------------------------------------------------------------------
LB3AF:  sec                                     ; B3AF 38       8
        rts                                     ; B3B0 60       `

; ----------------------------------------------------------------------------
LB3B1:  ldx     #$00                            ; B3B1 A2 00    ..
LB3B3:  lda     $B1                             ; B3B3 A5 B1    ..
        cmp     $B3                             ; B3B5 C5 B3    ..
        bcc     LB3D1                           ; B3B7 90 18    ..
        bne     LB3C1                           ; B3B9 D0 06    ..
        lda     $B0                             ; B3BB A5 B0    ..
        cmp     $B2                             ; B3BD C5 B2    ..
        bcc     LB3D1                           ; B3BF 90 10    ..
LB3C1:  lda     $B0                             ; B3C1 A5 B0    ..
        sbc     $B2                             ; B3C3 E5 B2    ..
        sta     $B0                             ; B3C5 85 B0    ..
        lda     $B1                             ; B3C7 A5 B1    ..
        sbc     $B3                             ; B3C9 E5 B3    ..
        sta     $B1                             ; B3CB 85 B1    ..
        inx                                     ; B3CD E8       .
        jmp     LB3B3                           ; B3CE 4C B3 B3 L..

; ----------------------------------------------------------------------------
LB3D1:  rts                                     ; B3D1 60       `

; ----------------------------------------------------------------------------
LB3D2:  jsr     LA848                           ; B3D2 20 48 A8  H.
        ldy     #$02                            ; B3D5 A0 02    ..
        jsr     L8A8E                           ; B3D7 20 8E 8A  ..
        lsr     $A9                             ; B3DA 46 A9    F.
        ror     L00A8                           ; B3DC 66 A8    f.
        lsr     $A9                             ; B3DE 46 A9    F.
        ror     L00A8                           ; B3E0 66 A8    f.
        lda     L00A8                           ; B3E2 A5 A8    ..
        jsr     LB3EF                           ; B3E4 20 EF B3  ..
        jsr     LA848                           ; B3E7 20 48 A8  H.
        lda     #$4B                            ; B3EA A9 4B    .K
        jmp     oswrch                          ; B3EC 4C EE FF L..

; ----------------------------------------------------------------------------
LB3EF:  sec                                     ; B3EF 38       8
        ldx     #$FF                            ; B3F0 A2 FF    ..
        stx     $A9                             ; B3F2 86 A9    ..
LB3F4:  inc     $A9                             ; B3F4 E6 A9    ..
        sbc     #$64                            ; B3F6 E9 64    .d
        bcs     LB3F4                           ; B3F8 B0 FA    ..
        adc     #$64                            ; B3FA 69 64    id
LB3FC:  inx                                     ; B3FC E8       .
        sbc     #$0A                            ; B3FD E9 0A    ..
        bcs     LB3FC                           ; B3FF B0 FB    ..
        adc     #$0A                            ; B401 69 0A    i.
        sta     L00A8                           ; B403 85 A8    ..
        txa                                     ; B405 8A       .
        jsr     LAA04                           ; B406 20 04 AA  ..
        ora     L00A8                           ; B409 05 A8    ..
        sta     L00A8                           ; B40B 85 A8    ..
        rts                                     ; B40D 60       `

; ----------------------------------------------------------------------------
LB40E:  jsr     LB34C                           ; B40E 20 4C B3  L.
        lda     #$83                            ; B411 A9 83    ..
        jsr     oswrch                          ; B413 20 EE FF  ..
        clc                                     ; B416 18       .
        lda     $C1                             ; B417 A5 C1    ..
        adc     #$41                            ; B419 69 41    iA
        jsr     oswrch                          ; B41B 20 EE FF  ..
        ldy     #$0D                            ; B41E A0 0D    ..
        jsr     LB792                           ; B420 20 92 B7  ..
        lda     $C1                             ; B423 A5 C1    ..
        asl     a                               ; B425 0A       .
        tay                                     ; B426 A8       .
        jsr     select_ram_page_000             ; B427 20 23 BE  #.
        lda     $FDC4,y                         ; B42A B9 C4 FD ...
        sta     $A9                             ; B42D 85 A9    ..
        lda     $FDC5,y                         ; B42F B9 C5 FD ...
        sta     L00A8                           ; B432 85 A8    ..
        ora     $A9                             ; B434 05 A9    ..
        beq     LB43E                           ; B436 F0 06    ..
        jsr     LA874                           ; B438 20 74 A8  t.
        jsr     LB3D2                           ; B43B 20 D2 B3  ..
LB43E:  jmp     select_ram_page_001             ; B43E 4C 28 BE L(.

; ----------------------------------------------------------------------------
LB441:  lda     #$00                            ; B441 A9 00    ..
        tay                                     ; B443 A8       .
        jsr     select_ram_page_002             ; B444 20 2D BE  -.
LB447:  sta     $FD00,y                         ; B447 99 00 FD ...
        iny                                     ; B44A C8       .
        bne     LB447                           ; B44B D0 FA    ..
        jsr     select_ram_page_003             ; B44D 20 32 BE  2.
LB450:  sta     $FD00,y                         ; B450 99 00 FD ...
        iny                                     ; B453 C8       .
        bne     LB450                           ; B454 D0 FA    ..
        jmp     select_ram_page_001             ; B456 4C 28 BE L(.

; ----------------------------------------------------------------------------
LB459:  jsr     select_ram_page_000             ; B459 20 23 BE  #.
        lda     #$00                            ; B45C A9 00    ..
        ldy     #$0F                            ; B45E A0 0F    ..
LB460:  sta     $FDC4,y                         ; B460 99 C4 FD ...
        dey                                     ; B463 88       .
        bpl     LB460                           ; B464 10 FA    ..
        jmp     select_ram_page_001             ; B466 4C 28 BE L(.

; ----------------------------------------------------------------------------
LB469:  jsr     select_ram_page_001             ; B469 20 28 BE  (.
        lda     $C4                             ; B46C A5 C4    ..
        sta     $B2                             ; B46E 85 B2    ..
        lda     $C5                             ; B470 A5 C5    ..
        sta     $B3                             ; B472 85 B3    ..
        lda     $FDEB                           ; B474 AD EB FD ...
        sta     $B0                             ; B477 85 B0    ..
        lda     #$00                            ; B479 A9 00    ..
        ldx     #$04                            ; B47B A2 04    ..
LB47D:  asl     $B0                             ; B47D 06 B0    ..
        rol     a                               ; B47F 2A       *
        dex                                     ; B480 CA       .
        bne     LB47D                           ; B481 D0 FA    ..
        sta     $B1                             ; B483 85 B1    ..
        jsr     select_ram_page_000             ; B485 20 23 BE  #.
        ldy     #$00                            ; B488 A0 00    ..
LB48A:  jsr     LB59E                           ; B48A 20 9E B5  ..
        bcc     LB497                           ; B48D 90 08    ..
        lda     $B3                             ; B48F A5 B3    ..
        sta     $B1                             ; B491 85 B1    ..
        lda     $B2                             ; B493 A5 B2    ..
        sta     $B0                             ; B495 85 B0    ..
LB497:  lda     $B1                             ; B497 A5 B1    ..
        sta     $FDC4,y                         ; B499 99 C4 FD ...
        lda     $B0                             ; B49C A5 B0    ..
        sta     $FDC5,y                         ; B49E 99 C5 FD ...
        sec                                     ; B4A1 38       8
        lda     $B2                             ; B4A2 A5 B2    ..
        sbc     $B0                             ; B4A4 E5 B0    ..
        sta     $B2                             ; B4A6 85 B2    ..
        lda     $B3                             ; B4A8 A5 B3    ..
        sbc     $B1                             ; B4AA E5 B1    ..
        sta     $B3                             ; B4AC 85 B3    ..
        iny                                     ; B4AE C8       .
        iny                                     ; B4AF C8       .
        cpy     #$10                            ; B4B0 C0 10    ..
        bne     LB48A                           ; B4B2 D0 D6    ..
        rts                                     ; B4B4 60       `

; ----------------------------------------------------------------------------
LB4B5:  ldy     #$00                            ; B4B5 A0 00    ..
LB4B7:  jsr     select_ram_page_000             ; B4B7 20 23 BE  #.
        lda     $FDC4,y                         ; B4BA B9 C4 FD ...
        sta     $C5                             ; B4BD 85 C5    ..
        lda     $FDC5,y                         ; B4BF B9 C5 FD ...
        sta     $C4                             ; B4C2 85 C4    ..
        jsr     LB0A4                           ; B4C4 20 A4 B0  ..
        iny                                     ; B4C7 C8       .
        iny                                     ; B4C8 C8       .
        cpy     #$10                            ; B4C9 C0 10    ..
        bne     LB4B7                           ; B4CB D0 EA    ..
        rts                                     ; B4CD 60       `

; ----------------------------------------------------------------------------
LB4CE:  jsr     select_ram_page_002             ; B4CE 20 2D BE  -.
        lda     #$20                            ; B4D1 A9 20    . 
        sta     $FD00                           ; B4D3 8D 00 FD ...
        lda     #$12                            ; B4D6 A9 12    ..
        sta     $FD03                           ; B4D8 8D 03 FD ...
        ldy     L00C0                           ; B4DB A4 C0    ..
        sty     $FD04                           ; B4DD 8C 04 FD ...
        lda     #$00                            ; B4E0 A9 00    ..
        sta     $FD05                           ; B4E2 8D 05 FD ...
        jsr     LB605                           ; B4E5 20 05 B6  ..
        lda     L00A8                           ; B4E8 A5 A8    ..
        sta     $FD02                           ; B4EA 8D 02 FD ...
        lda     $A9                             ; B4ED A5 A9    ..
        sta     $FD01                           ; B4EF 8D 01 FD ...
        ldy     #$01                            ; B4F2 A0 01    ..
        sty     $BB                             ; B4F4 84 BB    ..
        dey                                     ; B4F6 88       .
LB4F7:  jsr     select_ram_page_000             ; B4F7 20 23 BE  #.
        tya                                     ; B4FA 98       .
        pha                                     ; B4FB 48       H
        lda     $FDC4,y                         ; B4FC B9 C4 FD ...
        sta     $B1                             ; B4FF 85 B1    ..
        lda     $FDC5,y                         ; B501 B9 C5 FD ...
        sta     $B0                             ; B504 85 B0    ..
        ora     $B1                             ; B506 05 B1    ..
        beq     LB520                           ; B508 F0 16    ..
        jsr     select_ram_page_002             ; B50A 20 2D BE  -.
        lda     $BB                             ; B50D A5 BB    ..
        sta     $FD08,y                         ; B50F 99 08 FD ...
        lda     #$00                            ; B512 A9 00    ..
        sta     $FD09,y                         ; B514 99 09 FD ...
        jsr     LB5EE                           ; B517 20 EE B5  ..
        clc                                     ; B51A 18       .
        tya                                     ; B51B 98       .
        adc     $BB                             ; B51C 65 BB    e.
        sta     $BB                             ; B51E 85 BB    ..
LB520:  pla                                     ; B520 68       h
        tay                                     ; B521 A8       .
        iny                                     ; B522 C8       .
        iny                                     ; B523 C8       .
        cpy     #$10                            ; B524 C0 10    ..
        bne     LB4F7                           ; B526 D0 CF    ..
        rts                                     ; B528 60       `

; ----------------------------------------------------------------------------
LB529:  jsr     LB585                           ; B529 20 85 B5  ..
        jsr     select_ram_page_002             ; B52C 20 2D BE  -.
        sec                                     ; B52F 38       8
        lda     $FD02                           ; B530 AD 02 FD ...
        sbc     #$12                            ; B533 E9 12    ..
        sta     $C4                             ; B535 85 C4    ..
        lda     $FD01                           ; B537 AD 01 FD ...
        sbc     #$00                            ; B53A E9 00    ..
        sta     $C5                             ; B53C 85 C5    ..
        lda     $FD04                           ; B53E AD 04 FD ...
        sta     L00C0                           ; B541 85 C0    ..
        jsr     LB459                           ; B543 20 59 B4  Y.
        ldy     #$0E                            ; B546 A0 0E    ..
LB548:  jsr     select_ram_page_000             ; B548 20 23 BE  #.
        tya                                     ; B54B 98       .
        lsr     a                               ; B54C 4A       J
        tax                                     ; B54D AA       .
        lda     $FDBC,x                         ; B54E BD BC FD ...
        beq     LB580                           ; B551 F0 2D    .-
        sty     $BB                             ; B553 84 BB    ..
        inc     $BB                             ; B555 E6 BB    ..
        jsr     L970D                           ; B557 20 0D 97  ..
        lda     #$01                            ; B55A A9 01    ..
        sta     $A1                             ; B55C 85 A1    ..
        lda     #$00                            ; B55E A9 00    ..
        sta     $A0                             ; B560 85 A0    ..
        lda     #$80                            ; B562 A9 80    ..
        sta     $FDE9                           ; B564 8D E9 FD ...
        jsr     LBA59                           ; B567 20 59 BA  Y.
        jsr     select_ram_page_002             ; B56A 20 2D BE  -.
        lda     $FD06                           ; B56D AD 06 FD ...
        and     #$03                            ; B570 29 03    ).
        pha                                     ; B572 48       H
        lda     $FD07                           ; B573 AD 07 FD ...
        jsr     select_ram_page_000             ; B576 20 23 BE  #.
        sta     $FDC5,y                         ; B579 99 C5 FD ...
        pla                                     ; B57C 68       h
        sta     $FDC4,y                         ; B57D 99 C4 FD ...
LB580:  dey                                     ; B580 88       .
        dey                                     ; B581 88       .
        bpl     LB548                           ; B582 10 C4    ..
        rts                                     ; B584 60       `

; ----------------------------------------------------------------------------
LB585:  jsr     LAD37                           ; B585 20 37 AD  7.
        ldy     #$0E                            ; B588 A0 0E    ..
        ldx     #$07                            ; B58A A2 07    ..
LB58C:  jsr     select_ram_page_002             ; B58C 20 2D BE  -.
        lda     $FD08,y                         ; B58F B9 08 FD ...
        jsr     select_ram_page_000             ; B592 20 23 BE  #.
        sta     $FDBC,x                         ; B595 9D BC FD ...
        dey                                     ; B598 88       .
        dey                                     ; B599 88       .
        dex                                     ; B59A CA       .
        bpl     LB58C                           ; B59B 10 EF    ..
        rts                                     ; B59D 60       `

; ----------------------------------------------------------------------------
LB59E:  lda     $B1                             ; B59E A5 B1    ..
        cmp     $B3                             ; B5A0 C5 B3    ..
        bne     LB5A8                           ; B5A2 D0 04    ..
        lda     $B0                             ; B5A4 A5 B0    ..
        cmp     $B2                             ; B5A6 C5 B2    ..
LB5A8:  rts                                     ; B5A8 60       `

; ----------------------------------------------------------------------------
LB5A9:  jsr     select_ram_page_001             ; B5A9 20 28 BE  (.
        ldy     $FDEB                           ; B5AC AC EB FD ...
        lda     #$00                            ; B5AF A9 00    ..
        sta     $C4                             ; B5B1 85 C4    ..
        sta     $C5                             ; B5B3 85 C5    ..
LB5B5:  clc                                     ; B5B5 18       .
        lda     $B0                             ; B5B6 A5 B0    ..
        adc     $C4                             ; B5B8 65 C4    e.
        sta     $C4                             ; B5BA 85 C4    ..
        bcc     LB5C0                           ; B5BC 90 02    ..
        inc     $C5                             ; B5BE E6 C5    ..
LB5C0:  dey                                     ; B5C0 88       .
        bne     LB5B5                           ; B5C1 D0 F2    ..
        rts                                     ; B5C3 60       `

; ----------------------------------------------------------------------------
LB5C4:  ldx     #$00                            ; B5C4 A2 00    ..
        stx     $B2                             ; B5C6 86 B2    ..
LB5C8:  jsr     select_ram_page_000             ; B5C8 20 23 BE  #.
        lda     $FDC5,x                         ; B5CB BD C5 FD ...
        sta     $B0                             ; B5CE 85 B0    ..
        lda     $FDC4,x                         ; B5D0 BD C4 FD ...
        sta     $B1                             ; B5D3 85 B1    ..
        jsr     LB5EE                           ; B5D5 20 EE B5  ..
        clc                                     ; B5D8 18       .
        tya                                     ; B5D9 98       .
        adc     $B2                             ; B5DA 65 B2    e.
        sta     $B2                             ; B5DC 85 B2    ..
        inx                                     ; B5DE E8       .
        inx                                     ; B5DF E8       .
        cpx     #$10                            ; B5E0 E0 10    ..
        bne     LB5C8                           ; B5E2 D0 E4    ..
        sec                                     ; B5E4 38       8
        lda     L00C0                           ; B5E5 A5 C0    ..
        sbc     $B2                             ; B5E7 E5 B2    ..
        tay                                     ; B5E9 A8       .
        dey                                     ; B5EA 88       .
        jmp     LB605                           ; B5EB 4C 05 B6 L..

; ----------------------------------------------------------------------------
LB5EE:  ldy     #$00                            ; B5EE A0 00    ..
        sty     L00A8                           ; B5F0 84 A8    ..
        sty     $A9                             ; B5F2 84 A9    ..
LB5F4:  lda     L00A8                           ; B5F4 A5 A8    ..
        cmp     $B0                             ; B5F6 C5 B0    ..
        lda     $A9                             ; B5F8 A5 A9    ..
        sbc     $B1                             ; B5FA E5 B1    ..
        bcs     LB604                           ; B5FC B0 06    ..
        iny                                     ; B5FE C8       .
        jsr     LB615                           ; B5FF 20 15 B6  ..
        bcc     LB5F4                           ; B602 90 F0    ..
LB604:  rts                                     ; B604 60       `

; ----------------------------------------------------------------------------
LB605:  lda     #$00                            ; B605 A9 00    ..
        sta     L00A8                           ; B607 85 A8    ..
        sta     $A9                             ; B609 85 A9    ..
        iny                                     ; B60B C8       .
LB60C:  dey                                     ; B60C 88       .
        beq     LB614                           ; B60D F0 05    ..
        jsr     LB615                           ; B60F 20 15 B6  ..
        bcc     LB60C                           ; B612 90 F8    ..
LB614:  rts                                     ; B614 60       `

; ----------------------------------------------------------------------------
LB615:  clc                                     ; B615 18       .
        lda     L00A8                           ; B616 A5 A8    ..
        adc     #$12                            ; B618 69 12    i.
        sta     L00A8                           ; B61A 85 A8    ..
        bcc     LB620                           ; B61C 90 02    ..
        inc     $A9                             ; B61E E6 A9    ..
LB620:  clc                                     ; B620 18       .
        rts                                     ; B621 60       `

; ----------------------------------------------------------------------------
LB622:  jsr     LB645                           ; B622 20 45 B6  E.
        cmp     #$30                            ; B625 C9 30    .0
        bcc     LB622                           ; B627 90 F9    ..
        cmp     #$5B                            ; B629 C9 5B    .[
        bcs     LB622                           ; B62B B0 F5    ..
        pha                                     ; B62D 48       H
        jsr     oswrch                          ; B62E 20 EE FF  ..
LB631:  jsr     LB645                           ; B631 20 45 B6  E.
        cmp     #$0D                            ; B634 C9 0D    ..
        bne     LB63A                           ; B636 D0 02    ..
        pla                                     ; B638 68       h
        rts                                     ; B639 60       `

; ----------------------------------------------------------------------------
LB63A:  cmp     #$7F                            ; B63A C9 7F    ..
        bne     LB631                           ; B63C D0 F3    ..
        pla                                     ; B63E 68       h
        jsr     LB39A                           ; B63F 20 9A B3  ..
        jmp     LB622                           ; B642 4C 22 B6 L".

; ----------------------------------------------------------------------------
LB645:  jsr     osrdch                          ; B645 20 E0 FF  ..
        bcs     LB64B                           ; B648 B0 01    ..
        rts                                     ; B64A 60       `

; ----------------------------------------------------------------------------
LB64B:  cmp     #$1B                            ; B64B C9 1B    ..
        beq     LB650                           ; B64D F0 01    ..
        rts                                     ; B64F 60       `

; ----------------------------------------------------------------------------
LB650:  jsr     select_ram_page_001             ; B650 20 28 BE  (.
        jsr     LA9EF                           ; B653 20 EF A9  ..
        jsr     LADDD                           ; B656 20 DD AD  ..
        jsr     LB6AD                           ; B659 20 AD B6  ..
        ldx     $B7                             ; B65C A6 B7    ..
        txs                                     ; B65E 9A       .
        jmp     (LFDE6)                         ; B65F 6C E6 FD l..

; ----------------------------------------------------------------------------
LB662:  jsr     LB6AD                           ; B662 20 AD B6  ..
        jsr     LA977                           ; B665 20 77 A9  w.
        .byte   $1F                             ; B668 1F       .
        ora     $17,x                           ; B669 15 17    ..
        dey                                     ; B66B 88       .
        .byte   $83                             ; B66C 83       .
        eor     $52                             ; B66D 45 52    ER
        .byte   $52                             ; B66F 52       R
        .byte   $4F                             ; B670 4F       O
        .byte   $52                             ; B671 52       R
        .byte   $FF                             ; B672 FF       .
        rts                                     ; B673 60       `

; ----------------------------------------------------------------------------
LB674:  jsr     LA977                           ; B674 20 77 A9  w.
        .byte   $1C                             ; B677 1C       .
        brk                                     ; B678 00       .
        ora     $0427                           ; B679 0D 27 04 .'.
        .byte   $0C                             ; B67C 0C       .
        .byte   $1C                             ; B67D 1C       .
        brk                                     ; B67E 00       .
        clc                                     ; B67F 18       .
        .byte   $27                             ; B680 27       '
        brk                                     ; B681 00       .
        .byte   $FF                             ; B682 FF       .
        jsr     LB6AD                           ; B683 20 AD B6  ..
        jsr     LA977                           ; B686 20 77 A9  w.
        .byte   $1F                             ; B689 1F       .
        brk                                     ; B68A 00       .
        bpl     LB6DD                           ; B68B 10 50    .P
        .byte   $72                             ; B68D 72       r
        adc     $73                             ; B68E 65 73    es
        .byte   $73                             ; B690 73       s
        jsr     L2846                           ; B691 20 46 28  F(
        .byte   $72                             ; B694 72       r
        adc     $74                             ; B695 65 74    et
        and     #$20                            ; B697 29 20    ) 
        .byte   $74                             ; B699 74       t
        .byte   $6F                             ; B69A 6F       o
        jsr     L7473                           ; B69B 20 73 74  st
        adc     ($72,x)                         ; B69E 61 72    ar
        .byte   $74                             ; B6A0 74       t
        jsr     L7F20                           ; B6A1 20 20 7F   .
        .byte   $FF                             ; B6A4 FF       .
        jsr     LB622                           ; B6A5 20 22 B6  ".
        cmp     #$46                            ; B6A8 C9 46    .F
        bne     LB674                           ; B6AA D0 C8    ..
        rts                                     ; B6AC 60       `

; ----------------------------------------------------------------------------
LB6AD:  ldx     #$00                            ; B6AD A2 00    ..
        ldy     #$10                            ; B6AF A0 10    ..
        jsr     LB323                           ; B6B1 20 23 B3  #.
        ldy     #$78                            ; B6B4 A0 78    .x
        jmp     L8A8E                           ; B6B6 4C 8E 8A L..

; ----------------------------------------------------------------------------
LB6B9:  jsr     LB674                           ; B6B9 20 74 B6  t.
        jsr     LB737                           ; B6BC 20 37 B7  7.
        bne     LB6B9                           ; B6BF D0 F8    ..
        jsr     LB6AD                           ; B6C1 20 AD B6  ..
        jsr     LB948                           ; B6C4 20 48 B9  H.
        lda     #$00                            ; B6C7 A9 00    ..
        sta     $BA                             ; B6C9 85 BA    ..
LB6CB:  lda     #$00                            ; B6CB A9 00    ..
        sta     $B9                             ; B6CD 85 B9    ..
        sta     $BB                             ; B6CF 85 BB    ..
        jsr     LBB59                           ; B6D1 20 59 BB  Y.
LB6D4:  lda     #$03                            ; B6D4 A9 03    ..
        sta     $BF                             ; B6D6 85 BF    ..
LB6D8:  jsr     LB33C                           ; B6D8 20 3C B3  <.
        .byte   $20                             ; B6DB 20        
        .byte   $17                             ; B6DC 17       .
LB6DD:  .byte   $B7                             ; B6DD B7       .
        ldy     #$03                            ; B6DE A0 03    ..
        jsr     LB792                           ; B6E0 20 92 B7  ..
        lda     $B9                             ; B6E3 A5 B9    ..
        sta     $BB                             ; B6E5 85 BB    ..
        jsr     LBB59                           ; B6E7 20 59 BB  Y.
        jsr     LB169                           ; B6EA 20 69 B1  i.
        beq     LB6F8                           ; B6ED F0 09    ..
        dec     $BF                             ; B6EF C6 BF    ..
        bne     LB6D8                           ; B6F1 D0 E5    ..
        jsr     LB662                           ; B6F3 20 62 B6  b.
        sec                                     ; B6F6 38       8
        rts                                     ; B6F7 60       `

; ----------------------------------------------------------------------------
LB6F8:  lda     #$FE                            ; B6F8 A9 FE    ..
        bit     $FDED                           ; B6FA 2C ED FD ,..
        bvc     LB700                           ; B6FD 50 01    P.
        asl     a                               ; B6FF 0A       .
LB700:  clc                                     ; B700 18       .
        adc     $B9                             ; B701 65 B9    e.
        bcs     LB708                           ; B703 B0 03    ..
        adc     $FDEB                           ; B705 6D EB FD m..
LB708:  sta     $B9                             ; B708 85 B9    ..
        inc     $BA                             ; B70A E6 BA    ..
        lda     $BA                             ; B70C A5 BA    ..
        cmp     L00C0                           ; B70E C5 C0    ..
        bcs     LB715                           ; B710 B0 03    ..
        jmp     LB6D4                           ; B712 4C D4 B6 L..

; ----------------------------------------------------------------------------
LB715:  clc                                     ; B715 18       .
        rts                                     ; B716 60       `

; ----------------------------------------------------------------------------
LB717:  ldx     #$00                            ; B717 A2 00    ..
        ldy     $BA                             ; B719 A4 BA    ..
LB71B:  sec                                     ; B71B 38       8
        tya                                     ; B71C 98       .
        sbc     #$0A                            ; B71D E9 0A    ..
        bcc     LB729                           ; B71F 90 08    ..
        tay                                     ; B721 A8       .
        clc                                     ; B722 18       .
        txa                                     ; B723 8A       .
        adc     #$05                            ; B724 69 05    i.
        tax                                     ; B726 AA       .
        bcc     LB71B                           ; B727 90 F2    ..
LB729:  adc     #$0E                            ; B729 69 0E    i.
        tay                                     ; B72B A8       .
        jsr     LB323                           ; B72C 20 23 B3  #.
        lda     $BA                             ; B72F A5 BA    ..
        jsr     LB3EF                           ; B731 20 EF B3  ..
        jmp     LA850                           ; B734 4C 50 A8 LP.

; ----------------------------------------------------------------------------
LB737:  jsr     LAE07                           ; B737 20 07 AE  ..
        beq     LB76B                           ; B73A F0 2F    ./
        jsr     LA977                           ; B73C 20 77 A9  w.
        .byte   $1F                             ; B73F 1F       .
        brk                                     ; B740 00       .
        bpl     LB6CB                           ; B741 10 88    ..
        .byte   $83                             ; B743 83       .
        .byte   $44                             ; B744 44       D
        adc     #$73                            ; B745 69 73    is
        .byte   $6B                             ; B747 6B       k
        jsr     L2F52                           ; B748 20 52 2F  R/
        .byte   $4F                             ; B74B 4F       O
        rol     $2E2E                           ; B74C 2E 2E 2E ...
        .byte   $72                             ; B74F 72       r
        adc     $6D                             ; B750 65 6D    em
        .byte   $6F                             ; B752 6F       o
        ror     $65,x                           ; B753 76 65    ve
        jsr     L7277                           ; B755 20 77 72  wr
        adc     #$74                            ; B758 69 74    it
        adc     $20                             ; B75A 65 20    e 
        bvs     LB7D0                           ; B75C 70 72    pr
        .byte   $6F                             ; B75E 6F       o
        .byte   $74                             ; B75F 74       t
        adc     $63                             ; B760 65 63    ec
        .byte   $74                             ; B762 74       t
        ora     $FF0A                           ; B763 0D 0A FF ...
        jsr     LB76C                           ; B766 20 6C B7  l.
        lda     #$FF                            ; B769 A9 FF    ..
LB76B:  rts                                     ; B76B 60       `

; ----------------------------------------------------------------------------
LB76C:  jsr     LA977                           ; B76C 20 77 A9  w.
        .byte   $1F                             ; B76F 1F       .
        .byte   $04                             ; B770 04       .
        ora     ($50),y                         ; B771 11 50    .P
        .byte   $72                             ; B773 72       r
        adc     $73                             ; B774 65 73    es
        .byte   $73                             ; B776 73       s
        jsr     L6E61                           ; B777 20 61 6E  an
        adc     $6B20,y                         ; B77A 79 20 6B y k
        adc     $79                             ; B77D 65 79    ey
        jsr     L6F74                           ; B77F 20 74 6F  to
        jsr     L6F63                           ; B782 20 63 6F  co
        ror     $6974                           ; B785 6E 74 69 nti
        ror     $6575                           ; B788 6E 75 65 nue
        .byte   $FF                             ; B78B FF       .
        jsr     LB645                           ; B78C 20 45 B6  E.
        jmp     LB6AD                           ; B78F 4C AD B6 L..

; ----------------------------------------------------------------------------
LB792:  tya                                     ; B792 98       .
        pha                                     ; B793 48       H
        jsr     L8A8E                           ; B794 20 8E 8A  ..
        pla                                     ; B797 68       h
        tay                                     ; B798 A8       .
LB799:  lda     #$7F                            ; B799 A9 7F    ..
        jsr     oswrch                          ; B79B 20 EE FF  ..
        dey                                     ; B79E 88       .
        bne     LB799                           ; B79F D0 F8    ..
        rts                                     ; B7A1 60       `

; ----------------------------------------------------------------------------
LB7A2:  lda     #$07                            ; B7A2 A9 07    ..
        jmp     oswrch                          ; B7A4 4C EE FF L..

; ----------------------------------------------------------------------------
LB7A7:  jsr     LAA76                           ; B7A7 20 76 AA  v.
        jsr     LB7B2                           ; B7AA 20 B2 B7  ..
        bne     LB7BD                           ; B7AD D0 0E    ..
        jmp     LAB36                           ; B7AF 4C 36 AB L6.

; ----------------------------------------------------------------------------
LB7B2:  jsr     LAB39                           ; B7B2 20 39 AB  9.
        and     #$07                            ; B7B5 29 07    ).
        cmp     #$04                            ; B7B7 C9 04    ..
        beq     LB7BD                           ; B7B9 F0 02    ..
        cmp     #$05                            ; B7BB C9 05    ..
LB7BD:  rts                                     ; B7BD 60       `

; ----------------------------------------------------------------------------
LB7BE:  jsr     LB317                           ; B7BE 20 17 B3  ..
        ldy     #$00                            ; B7C1 A0 00    ..
LB7C3:  iny                                     ; B7C3 C8       .
        ldx     #$0D                            ; B7C4 A2 0D    ..
        jsr     LB323                           ; B7C6 20 23 B3  #.
        cpy     #$03                            ; B7C9 C0 03    ..
        rts                                     ; B7CB 60       `

; ----------------------------------------------------------------------------
fdcstat_command:
        tsx                                     ; B7CC BA       .
        lda     #$00                            ; B7CD A9 00    ..
        .byte   $9D                             ; B7CF 9D       .
LB7D0:  ora     $01                             ; B7D0 05 01    ..
        jsr     LA977                           ; B7D2 20 77 A9  w.
        ora     $570A                           ; B7D5 0D 0A 57 ..W
        .byte   $44                             ; B7D8 44       D
        jsr     L3731                           ; B7D9 20 31 37  17
        .byte   $37                             ; B7DC 37       7
        bmi     LB7FF                           ; B7DD 30 20    0 
        .byte   $73                             ; B7DF 73       s
        .byte   $74                             ; B7E0 74       t
        adc     ($74,x)                         ; B7E1 61 74    at
        adc     $73,x                           ; B7E3 75 73    us
        jsr     L203A                           ; B7E5 20 3A 20  : 
        .byte   $FF                             ; B7E8 FF       .
        lda     $FDF3                           ; B7E9 AD F3 FD ...
        jsr     LA9D8                           ; B7EC 20 D8 A9  ..
        jmp     L841A                           ; B7EF 4C 1A 84 L..

; ----------------------------------------------------------------------------
        ldx     #$00                            ; B7F2 A2 00    ..
        lda     $01A2                           ; B7F4 AD A2 01 ...
        lda     $02A2                           ; B7F7 AD A2 02 ...
        lda     $03A2                           ; B7FA AD A2 03 ...
        .byte   $AD                             ; B7FD AD       .
        .byte   $A2                             ; B7FE A2       .
LB7FF:  .byte   $04                             ; B7FF 04       .
        stx     $FDE9                           ; B800 8E E9 FD ...
        lda     ($B0),y                         ; B803 B1 B0    ..
        sta     $BB                             ; B805 85 BB    ..
        jsr     LB7B2                           ; B807 20 B2 B7  ..
        bne     LB81F                           ; B80A D0 13    ..
        ldx     #$0A                            ; B80C A2 0A    ..
        ldy     #$00                            ; B80E A0 00    ..
        lda     $BB                             ; B810 A5 BB    ..
LB812:  clc                                     ; B812 18       .
        adc     $BA                             ; B813 65 BA    e.
        bcc     LB818                           ; B815 90 01    ..
        iny                                     ; B817 C8       .
LB818:  dex                                     ; B818 CA       .
        bne     LB812                           ; B819 D0 F7    ..
        sta     $BB                             ; B81B 85 BB    ..
        sty     $BA                             ; B81D 84 BA    ..
LB81F:  ldy     #$09                            ; B81F A0 09    ..
        lda     ($B0),y                         ; B821 B1 B0    ..
        jsr     LA9FD                           ; B823 20 FD A9  ..
        tax                                     ; B826 AA       .
        lda     #$00                            ; B827 A9 00    ..
        sta     $A0                             ; B829 85 A0    ..
        lda     ($B0),y                         ; B82B B1 B0    ..
        iny                                     ; B82D C8       .
        and     #$1F                            ; B82E 29 1F    ).
        lsr     a                               ; B830 4A       J
        ror     $A0                             ; B831 66 A0    f.
        bcc     LB838                           ; B833 90 03    ..
LB835:  asl     $A0                             ; B835 06 A0    ..
        rol     a                               ; B837 2A       *
LB838:  dex                                     ; B838 CA       .
        bpl     LB835                           ; B839 10 FA    ..
        sta     $A1                             ; B83B 85 A1    ..
        jsr     LBA59                           ; B83D 20 59 BA  Y.
LB840:  ldy     #$0A                            ; B840 A0 0A    ..
        sta     ($B0),y                         ; B842 91 B0    ..
        rts                                     ; B844 60       `

; ----------------------------------------------------------------------------
        jsr     LB850                           ; B845 20 50 B8  P.
        jsr     LB95C                           ; B848 20 5C B9  \.
        ldy     #$08                            ; B84B A0 08    ..
        sta     ($B0),y                         ; B84D 91 B0    ..
        rts                                     ; B84F 60       `

; ----------------------------------------------------------------------------
LB850:  jsr     LB7B2                           ; B850 20 B2 B7  ..
        bne     LB857                           ; B853 D0 02    ..
        pla                                     ; B855 68       h
        pla                                     ; B856 68       h
LB857:  rts                                     ; B857 60       `

; ----------------------------------------------------------------------------
        jsr     LB7B2                           ; B858 20 B2 B7  ..
        beq     LB876                           ; B85B F0 19    ..
        jsr     LB9B7                           ; B85D 20 B7 B9  ..
        jsr     LB9B7                           ; B860 20 B7 B9  ..
        ldy     #$0A                            ; B863 A0 0A    ..
        sta     ($B0),y                         ; B865 91 B0    ..
        tay                                     ; B867 A8       .
        bne     LB875                           ; B868 D0 0B    ..
LB86A:  lda     $0D15,y                         ; B86A B9 15 0D ...
        jsr     LA542                           ; B86D 20 42 A5  B.
        iny                                     ; B870 C8       .
        cpy     #$04                            ; B871 C0 04    ..
        bne     LB86A                           ; B873 D0 F5    ..
LB875:  rts                                     ; B875 60       `

; ----------------------------------------------------------------------------
LB876:  ldy     #$00                            ; B876 A0 00    ..
        lda     $BA                             ; B878 A5 BA    ..
LB87A:  jsr     LA542                           ; B87A 20 42 A5  B.
        lda     LB88C,y                         ; B87D B9 8C B8 ...
        iny                                     ; B880 C8       .
        cpy     #$04                            ; B881 C0 04    ..
        bne     LB87A                           ; B883 D0 F5    ..
        jsr     LB9E5                           ; B885 20 E5 B9  ..
        lda     #$00                            ; B888 A9 00    ..
        beq     LB840                           ; B88A F0 B4    ..
LB88C:  brk                                     ; B88C 00       .
        brk                                     ; B88D 00       .
        ora     ($20,x)                         ; B88E 01 20    . 
        stx     $BB,y                           ; B890 96 BB    ..
        ldy     #$0C                            ; B892 A0 0C    ..
        sta     ($B0),y                         ; B894 91 B0    ..
        rts                                     ; B896 60       `

; ----------------------------------------------------------------------------
        dey                                     ; B897 88       .
        jsr     LB937                           ; B898 20 37 B9  7.
        lsr     a                               ; B89B 4A       J
        lsr     a                               ; B89C 4A       J
        lsr     a                               ; B89D 4A       J
        ora     #$44                            ; B89E 09 44    .D
        sta     ($B0),y                         ; B8A0 91 B0    ..
LB8A2:  rts                                     ; B8A2 60       `

; ----------------------------------------------------------------------------
        lda     $BA                             ; B8A3 A5 BA    ..
        cmp     #$0D                            ; B8A5 C9 0D    ..
        bne     LB8A2                           ; B8A7 D0 F9    ..
        lda     ($B0),y                         ; B8A9 B1 B0    ..
        tax                                     ; B8AB AA       .
        jmp     LB933                           ; B8AC 4C 33 B9 L3.

; ----------------------------------------------------------------------------
        lda     ($B0),y                         ; B8AF B1 B0    ..
        ldx     $BA                             ; B8B1 A6 BA    ..
        cpx     #$04                            ; B8B3 E0 04    ..
        bcs     LB8BB                           ; B8B5 B0 04    ..
        sta     $FDEA,x                         ; B8B7 9D EA FD ...
        rts                                     ; B8BA 60       `

; ----------------------------------------------------------------------------
LB8BB:  bne     LB8C1                           ; B8BB D0 04    ..
        sta     $FDEE                           ; B8BD 8D EE FD ...
        rts                                     ; B8C0 60       `

; ----------------------------------------------------------------------------
LB8C1:  cpx     #$12                            ; B8C1 E0 12    ..
        bne     LB8DB                           ; B8C3 D0 16    ..
        jmp     LBCD3                           ; B8C5 4C D3 BC L..

; ----------------------------------------------------------------------------
        ldx     $BA                             ; B8C8 A6 BA    ..
        cpx     #$04                            ; B8CA E0 04    ..
        bcs     LB8D4                           ; B8CC B0 06    ..
        lda     $FDEA,x                         ; B8CE BD EA FD ...
        sta     ($B0),y                         ; B8D1 91 B0    ..
        rts                                     ; B8D3 60       `

; ----------------------------------------------------------------------------
LB8D4:  bne     LB8DB                           ; B8D4 D0 05    ..
        lda     $FDEE                           ; B8D6 AD EE FD ...
        sta     ($B0),y                         ; B8D9 91 B0    ..
LB8DB:  rts                                     ; B8DB 60       `

; ----------------------------------------------------------------------------
LB8DC:  .byte   $13                             ; B8DC 13       .
LB8DD:  .byte   $F1                             ; B8DD F1       .
LB8DE:  .byte   $B7                             ; B8DE B7       .
        .byte   $0B                             ; B8DF 0B       .
        .byte   $F4                             ; B8E0 F4       .
        .byte   $B7                             ; B8E1 B7       .
        and     #$44                            ; B8E2 29 44    )D
        clv                                     ; B8E4 B8       .
        .byte   $1F                             ; B8E5 1F       .
        sbc     $17B7,x                         ; B8E6 FD B7 17 ...
        sbc     ($B7),y                         ; B8E9 F1 B7    ..
        .byte   $0F                             ; B8EB 0F       .
        .byte   $FA                             ; B8EC FA       .
        .byte   $B7                             ; B8ED B7       .
        .byte   $1B                             ; B8EE 1B       .
        .byte   $57                             ; B8EF 57       W
        clv                                     ; B8F0 B8       .
        .byte   $23                             ; B8F1 23       #
        stx     $2CB8                           ; B8F2 8E B8 2C ..,
        stx     $B8,y                           ; B8F5 96 B8    ..
        and     $A2,x                           ; B8F7 35 A2    5.
        clv                                     ; B8F9 B8       .
        .byte   $3A                             ; B8FA 3A       :
        ldx     $3DB8                           ; B8FB AE B8 3D ..=
        .byte   $C7                             ; B8FE C7       .
        clv                                     ; B8FF B8       .
        brk                                     ; B900 00       .
LB901:  jsr     LB7B2                           ; B901 20 B2 B7  ..
        beq     LB91E                           ; B904 F0 18    ..
        txa                                     ; B906 8A       .
        pha                                     ; B907 48       H
        jsr     LAB39                           ; B908 20 39 AB  9.
        and     #$07                            ; B90B 29 07    ).
        tax                                     ; B90D AA       .
        lda     $FDED                           ; B90E AD ED FD ...
        and     #$7F                            ; B911 29 7F    ).
        eor     #$40                            ; B913 49 40    I@
        lsr     a                               ; B915 4A       J
        ora     LB921,x                         ; B916 1D 21 B9 .!.
        sta     fdc_control                     ; B919 8D FC FC ...
        pla                                     ; B91C 68       h
        tax                                     ; B91D AA       .
LB91E:  lda     $CF                             ; B91E A5 CF    ..
        rts                                     ; B920 60       `

; ----------------------------------------------------------------------------
LB921:  .byte   $12                             ; B921 12       .
        .byte   $14                             ; B922 14       .
        .byte   $13                             ; B923 13       .
        ora     $FF,x                           ; B924 15 FF    ..
        .byte   $FF                             ; B926 FF       .
        clc                                     ; B927 18       .
        .byte   $19                             ; B928 19       .
LB929:  jsr     push_registers_and_tuck_restoration_thunk; B929 20 AB A8 ..
        jsr     LAE3B                           ; B92C 20 3B AE  ;.
        txa                                     ; B92F 8A       .
        jsr     LA9F6                           ; B930 20 F6 A9  ..
LB933:  sta     $FDF2                           ; B933 8D F2 FD ...
        rts                                     ; B936 60       `

; ----------------------------------------------------------------------------
LB937:  jsr     LB7B2                           ; B937 20 B2 B7  ..
        beq     LB945                           ; B93A F0 09    ..
        jsr     LBA34                           ; B93C 20 34 BA  4.
        jsr     LBD4A                           ; B93F 20 4A BD  J.
        and     #$40                            ; B942 29 40    )@
        rts                                     ; B944 60       `

; ----------------------------------------------------------------------------
LB945:  lda     #$00                            ; B945 A9 00    ..
        rts                                     ; B947 60       `

; ----------------------------------------------------------------------------
LB948:  jsr     LA8D4                           ; B948 20 D4 A8  ..
        jsr     LB901                           ; B94B 20 01 B9  ..
        lda     #$00                            ; B94E A9 00    ..
        jsr     LB987                           ; B950 20 87 B9  ..
        jsr     LBCDF                           ; B953 20 DF BC  ..
        lda     #$00                            ; B956 A9 00    ..
        sta     $FDEF,x                         ; B958 9D EF FD ...
        rts                                     ; B95B 60       `

; ----------------------------------------------------------------------------
LB95C:  jsr     select_ram_page_001             ; B95C 20 28 BE  (.
        lda     $BA                             ; B95F A5 BA    ..
        bit     $FDEA                           ; B961 2C EA FD ,..
        bvc     LB967                           ; B964 50 01    P.
        asl     a                               ; B966 0A       .
LB967:  cmp     #$00                            ; B967 C9 00    ..
        beq     LB948                           ; B969 F0 DD    ..
        jsr     LA8D4                           ; B96B 20 D4 A8  ..
        pha                                     ; B96E 48       H
        jsr     LBCDF                           ; B96F 20 DF BC  ..
        lda     $FDEF,x                         ; B972 BD EF FD ...
        jsr     LBCDB                           ; B975 20 DB BC  ..
        pla                                     ; B978 68       h
        sta     $FDEF,x                         ; B979 9D EF FD ...
        jsr     LBD18                           ; B97C 20 18 BD  ..
        lda     #$10                            ; B97F A9 10    ..
        jsr     LB987                           ; B981 20 87 B9  ..
        and     #$10                            ; B984 29 10    ).
        rts                                     ; B986 60       `

; ----------------------------------------------------------------------------
LB987:  bit     fdc_status_or_cmd               ; B987 2C F8 FC ,..
        php                                     ; B98A 08       .
        ora     $FDF2                           ; B98B 0D F2 FD ...
        jsr     LBD10                           ; B98E 20 10 BD  ..
        jsr     LBD4A                           ; B991 20 4A BD  J.
        plp                                     ; B994 28       (
        bmi     LB9AA                           ; B995 30 13    0.
        jsr     push_registers_and_tuck_restoration_thunk; B997 20 AB A8 ..
        lda     $FDE9                           ; B99A AD E9 FD ...
        lsr     a                               ; B99D 4A       J
        bcc     LB9AA                           ; B99E 90 0A    ..
        ldy     #$00                            ; B9A0 A0 00    ..
LB9A2:  nop                                     ; B9A2 EA       .
        nop                                     ; B9A3 EA       .
        dex                                     ; B9A4 CA       .
        bne     LB9A2                           ; B9A5 D0 FB    ..
        dey                                     ; B9A7 88       .
        bne     LB9A2                           ; B9A8 D0 F8    ..
LB9AA:  rts                                     ; B9AA 60       `

; ----------------------------------------------------------------------------
LB9AB:  jsr     LB901                           ; B9AB 20 01 B9  ..
        jsr     LB9B7                           ; B9AE 20 B7 B9  ..
        beq     LB9B6                           ; B9B1 F0 03    ..
        jmp     LBCF9                           ; B9B3 4C F9 BC L..

; ----------------------------------------------------------------------------
LB9B6:  rts                                     ; B9B6 60       `

; ----------------------------------------------------------------------------
LB9B7:  jsr     LA8D4                           ; B9B7 20 D4 A8  ..
        jsr     select_ram_page_001             ; B9BA 20 28 BE  (.
        jsr     LBA34                           ; B9BD 20 34 BA  4.
        ldx     #$04                            ; B9C0 A2 04    ..
        bit     $FDED                           ; B9C2 2C ED FD ,..
        bvc     LB9D6                           ; B9C5 50 0F    P.
LB9C7:  lda     $FDED                           ; B9C7 AD ED FD ...
        ora     #$40                            ; B9CA 09 40    .@
        ldy     #$12                            ; B9CC A0 12    ..
        jsr     LB9FB                           ; B9CE 20 FB B9  ..
        beq     LB9F8                           ; B9D1 F0 25    .%
        dex                                     ; B9D3 CA       .
        beq     LB9E5                           ; B9D4 F0 0F    ..
LB9D6:  lda     $FDED                           ; B9D6 AD ED FD ...
        and     #$BF                            ; B9D9 29 BF    ).
        ldy     #$0A                            ; B9DB A0 0A    ..
        jsr     LB9FB                           ; B9DD 20 FB B9  ..
        beq     LB9F8                           ; B9E0 F0 16    ..
        dex                                     ; B9E2 CA       .
        bne     LB9C7                           ; B9E3 D0 E2    ..
LB9E5:  lda     $FDED                           ; B9E5 AD ED FD ...
        and     #$BF                            ; B9E8 29 BF    ).
        sta     $FDED                           ; B9EA 8D ED FD ...
        jsr     LB901                           ; B9ED 20 01 B9  ..
        lda     #$0A                            ; B9F0 A9 0A    ..
        sta     $FDEB                           ; B9F2 8D EB FD ...
        lda     #$18                            ; B9F5 A9 18    ..
        rts                                     ; B9F7 60       `

; ----------------------------------------------------------------------------
LB9F8:  lda     #$00                            ; B9F8 A9 00    ..
        rts                                     ; B9FA 60       `

; ----------------------------------------------------------------------------
LB9FB:  sta     $FDED                           ; B9FB 8D ED FD ...
        sty     $FDEB                           ; B9FE 8C EB FD ...
LBA01:  ldy     #$14                            ; BA01 A0 14    ..
LBA03:  lda     LBDCD,y                         ; BA03 B9 CD BD ...
        sta     L0D00,y                         ; BA06 99 00 0D ...
        dey                                     ; BA09 88       .
        bpl     LBA03                           ; BA0A 10 F7    ..
        lda     #$00                            ; BA0C A9 00    ..
        sta     $A0                             ; BA0E 85 A0    ..
        jsr     LB901                           ; BA10 20 01 B9  ..
        lda     #$C0                            ; BA13 A9 C0    ..
        jsr     LBD10                           ; BA15 20 10 BD  ..
        jsr     LBD4A                           ; BA18 20 4A BD  J.
        pha                                     ; BA1B 48       H
        jsr     select_ram_page_000             ; BA1C 20 23 BE  #.
        ldy     #$03                            ; BA1F A0 03    ..
LBA21:  lda     $0D15,y                         ; BA21 B9 15 0D ...
        sta     $FDB8,y                         ; BA24 99 B8 FD ...
        dey                                     ; BA27 88       .
        bne     LBA21                           ; BA28 D0 F7    ..
        lda     fdc_sector                      ; BA2A AD FA FC ...
        sta     $FDB8                           ; BA2D 8D B8 FD ...
        pla                                     ; BA30 68       h
        jmp     select_ram_page_001             ; BA31 4C 28 BE L(.

; ----------------------------------------------------------------------------
LBA34:  jsr     LB901                           ; BA34 20 01 B9  ..
        lda     #$18                            ; BA37 A9 18    ..
        jsr     LBD10                           ; BA39 20 10 BD  ..
        ldx     #$0F                            ; BA3C A2 0F    ..
LBA3E:  dex                                     ; BA3E CA       .
        bne     LBA3E                           ; BA3F D0 FD    ..
        lda     #$D0                            ; BA41 A9 D0    ..
        jmp     LBD10                           ; BA43 4C 10 BD L..

; ----------------------------------------------------------------------------
LBA46:  jsr     LA8D4                           ; BA46 20 D4 A8  ..
        lda     #$00                            ; BA49 A9 00    ..
        sta     $BB                             ; BA4B 85 BB    ..
        sta     $A0                             ; BA4D 85 A0    ..
        lda     $FDEB                           ; BA4F AD EB FD ...
        sta     $A1                             ; BA52 85 A1    ..
        lda     #$04                            ; BA54 A9 04    ..
        sta     $FDE9                           ; BA56 8D E9 FD ...
LBA59:  jsr     LA8D4                           ; BA59 20 D4 A8  ..
        lda     $A0                             ; BA5C A5 A0    ..
        pha                                     ; BA5E 48       H
        lda     $A1                             ; BA5F A5 A1    ..
        pha                                     ; BA61 48       H
        jsr     LB7B2                           ; BA62 20 B2 B7  ..
        bne     LBA6A                           ; BA65 D0 03    ..
        jmp     LBE44                           ; BA67 4C 44 BE LD.

; ----------------------------------------------------------------------------
LBA6A:  jsr     LB901                           ; BA6A 20 01 B9  ..
        jsr     LB95C                           ; BA6D 20 5C B9  \.
        lda     $BA                             ; BA70 A5 BA    ..
        jsr     LBCD3                           ; BA72 20 D3 BC  ..
        jsr     LBB3C                           ; BA75 20 3C BB  <.
        lda     $FDEE                           ; BA78 AD EE FD ...
        sta     $0D2D                           ; BA7B 8D 2D 0D .-.
        lda     $FDE9                           ; BA7E AD E9 FD ...
        pha                                     ; BA81 48       H
        and     #$05                            ; BA82 29 05    ).
        beq     LBA8F                           ; BA84 F0 09    ..
        ror     a                               ; BA86 6A       j
        bcs     LBA99                           ; BA87 B0 10    ..
        jsr     LBB30                           ; BA89 20 30 BB  0.
        jmp     LBAAB                           ; BA8C 4C AB BA L..

; ----------------------------------------------------------------------------
LBA8F:  lda     $A0                             ; BA8F A5 A0    ..
        beq     LBA95                           ; BA91 F0 02    ..
        inc     $A1                             ; BA93 E6 A1    ..
LBA95:  ldy     #$07                            ; BA95 A0 07    ..
        bne     LBAA8                           ; BA97 D0 0F    ..
LBA99:  lda     $A0                             ; BA99 A5 A0    ..
        beq     LBA9F                           ; BA9B F0 02    ..
        inc     $A1                             ; BA9D E6 A1    ..
LBA9F:  lda     #$00                            ; BA9F A9 00    ..
        sta     $A0                             ; BAA1 85 A0    ..
        jsr     LBB48                           ; BAA3 20 48 BB  H.
        ldy     #$04                            ; BAA6 A0 04    ..
LBAA8:  jsr     LBAE1                           ; BAA8 20 E1 BA  ..
LBAAB:  lda     $F4                             ; BAAB A5 F4    ..
        sta     $0D38                           ; BAAD 8D 38 0D .8.
        lda     $BB                             ; BAB0 A5 BB    ..
        jsr     LBD14                           ; BAB2 20 14 BD  ..
        pla                                     ; BAB5 68       h
        and     #$07                            ; BAB6 29 07    ).
        pha                                     ; BAB8 48       H
        tay                                     ; BAB9 A8       .
        lda     LBD65,y                         ; BABA B9 65 BD .e.
        jsr     LBD10                           ; BABD 20 10 BD  ..
        ldx     #$1E                            ; BAC0 A2 1E    ..
LBAC2:  dex                                     ; BAC2 CA       .
        bne     LBAC2                           ; BAC3 D0 FD    ..
        jsr     L0D2C                           ; BAC5 20 2C 0D  ,.
        jsr     select_ram_page_001             ; BAC8 20 28 BE  (.
        pla                                     ; BACB 68       h
        tay                                     ; BACC A8       .
        jsr     LBD59                           ; BACD 20 59 BD  Y.
        and     LBD6A,y                         ; BAD0 39 6A BD 9j.
        tay                                     ; BAD3 A8       .
        jsr     LBCCB                           ; BAD4 20 CB BC  ..
LBAD7:  pla                                     ; BAD7 68       h
        sta     $A1                             ; BAD8 85 A1    ..
        pla                                     ; BADA 68       h
        sta     $A0                             ; BADB 85 A0    ..
        tya                                     ; BADD 98       .
        jmp     select_ram_page_001             ; BADE 4C 28 BE L(.

; ----------------------------------------------------------------------------
LBAE1:  lda     $FDE9                           ; BAE1 AD E9 FD ...
        bmi     LBB10                           ; BAE4 30 2A    0*
        lda     $FDCC                           ; BAE6 AD CC FD ...
        beq     LBB05                           ; BAE9 F0 1A    ..
        lda     #$E5                            ; BAEB A9 E5    ..
        sta     L0D00,y                         ; BAED 99 00 0D ...
        lda     #$FE                            ; BAF0 A9 FE    ..
        sta     $0D01,y                         ; BAF2 99 01 0D ...
        lda     #$4C                            ; BAF5 A9 4C    .L
        sta     $0D09                           ; BAF7 8D 09 0D ...
        lda     #$11                            ; BAFA A9 11    ..
        sta     $0D0A                           ; BAFC 8D 0A 0D ...
        lda     #$0D                            ; BAFF A9 0D    ..
        sta     $0D0B                           ; BB01 8D 0B 0D ...
        rts                                     ; BB04 60       `

; ----------------------------------------------------------------------------
LBB05:  lda     $A6                             ; BB05 A5 A6    ..
        sta     L0D00,y                         ; BB07 99 00 0D ...
        lda     $A7                             ; BB0A A5 A7    ..
        sta     $0D01,y                         ; BB0C 99 01 0D ...
        rts                                     ; BB0F 60       `

; ----------------------------------------------------------------------------
LBB10:  lda     #$20                            ; BB10 A9 20    . 
        sta     $0D0E                           ; BB12 8D 0E 0D ...
        lda     #$3D                            ; BB15 A9 3D    .=
        sta     $0D0F                           ; BB17 8D 0F 0D ...
        lda     #$0D                            ; BB1A A9 0D    ..
        sta     $0D10                           ; BB1C 8D 10 0D ...
        lda     $A6                             ; BB1F A5 A6    ..
        sta     $0D41                           ; BB21 8D 41 0D .A.
        sta     ram_paging_lsb                  ; BB24 8D FF FC ...
        lda     $A7                             ; BB27 A5 A7    ..
        sta     $0D4B                           ; BB29 8D 4B 0D .K.
        sta     ram_paging_msb                  ; BB2C 8D FE FC ...
        rts                                     ; BB2F 60       `

; ----------------------------------------------------------------------------
LBB30:  ldy     #$02                            ; BB30 A0 02    ..
LBB32:  lda     LBDE2,y                         ; BB32 B9 E2 BD ...
        sta     $0D06,y                         ; BB35 99 06 0D ...
        dey                                     ; BB38 88       .
        bpl     LBB32                           ; BB39 10 F7    ..
        rts                                     ; BB3B 60       `

; ----------------------------------------------------------------------------
LBB3C:  ldy     #$4F                            ; BB3C A0 4F    .O
LBB3E:  lda     LBD6F,y                         ; BB3E B9 6F BD .o.
        sta     L0D00,y                         ; BB41 99 00 0D ...
        dey                                     ; BB44 88       .
        bpl     LBB3E                           ; BB45 10 F7    ..
        rts                                     ; BB47 60       `

; ----------------------------------------------------------------------------
LBB48:  ldy     #$0D                            ; BB48 A0 0D    ..
LBB4A:  lda     LBDBF,y                         ; BB4A B9 BF BD ...
        sta     $0D03,y                         ; BB4D 99 03 0D ...
        dey                                     ; BB50 88       .
        bpl     LBB4A                           ; BB51 10 F7    ..
        lda     #$FC                            ; BB53 A9 FC    ..
        sta     $0D23                           ; BB55 8D 23 0D .#.
        rts                                     ; BB58 60       `

; ----------------------------------------------------------------------------
LBB59:  lda     #$0A                            ; BB59 A9 0A    ..
        bit     $FDED                           ; BB5B 2C ED FD ,..
        bvc     LBB62                           ; BB5E 50 02    P.
        lda     #$12                            ; BB60 A9 12    ..
LBB62:  sta     $A6                             ; BB62 85 A6    ..
        asl     a                               ; BB64 0A       .
        asl     a                               ; BB65 0A       .
        sta     $A7                             ; BB66 85 A7    ..
        ldx     $BB                             ; BB68 A6 BB    ..
        ldy     #$00                            ; BB6A A0 00    ..
LBB6C:  lda     $BA                             ; BB6C A5 BA    ..
        sta     $FD61,y                         ; BB6E 99 61 FD .a.
        iny                                     ; BB71 C8       .
        lda     #$00                            ; BB72 A9 00    ..
        sta     $FD61,y                         ; BB74 99 61 FD .a.
        iny                                     ; BB77 C8       .
        txa                                     ; BB78 8A       .
        sta     $FD61,y                         ; BB79 99 61 FD .a.
        iny                                     ; BB7C C8       .
        lda     #$01                            ; BB7D A9 01    ..
        sta     $FD61,y                         ; BB7F 99 61 FD .a.
        iny                                     ; BB82 C8       .
        inx                                     ; BB83 E8       .
        cpx     $A6                             ; BB84 E4 A6    ..
        bcc     LBB8A                           ; BB86 90 02    ..
        ldx     #$00                            ; BB88 A2 00    ..
LBB8A:  cpy     $A7                             ; BB8A C4 A7    ..
        bcc     LBB6C                           ; BB8C 90 DE    ..
        lda     #$61                            ; BB8E A9 61    .a
        sta     $A6                             ; BB90 85 A6    ..
        lda     #$FD                            ; BB92 A9 FD    ..
        sta     $A7                             ; BB94 85 A7    ..
        lda     #$12                            ; BB96 A9 12    ..
        sta     $A4                             ; BB98 85 A4    ..
        lda     #$06                            ; BB9A A9 06    ..
        pha                                     ; BB9C 48       H
        sta     $A5                             ; BB9D 85 A5    ..
        ldx     #$00                            ; BB9F A2 00    ..
        lda     #$0A                            ; BBA1 A9 0A    ..
        bit     $FDED                           ; BBA3 2C ED FD ,..
        bvc     LBBAC                           ; BBA6 50 04    P.
        ldx     #$23                            ; BBA8 A2 23    .#
        lda     #$12                            ; BBAA A9 12    ..
LBBAC:  sta     $A2                             ; BBAC 85 A2    ..
        jsr     LBC79                           ; BBAE 20 79 BC  y.
        ldy     #$05                            ; BBB1 A0 05    ..
LBBB3:  jsr     LBBFA                           ; BBB3 20 FA BB  ..
        dey                                     ; BBB6 88       .
        bne     LBBB3                           ; BBB7 D0 FA    ..
        stx     $A3                             ; BBB9 86 A3    ..
LBBBB:  ldx     $A3                             ; BBBB A6 A3    ..
LBBBD:  jsr     LBBFA                           ; BBBD 20 FA BB  ..
        bcc     LBBBD                           ; BBC0 90 FB    ..
        dec     $A2                             ; BBC2 C6 A2    ..
        bne     LBBBB                           ; BBC4 D0 F5    ..
        lda     #$00                            ; BBC6 A9 00    ..
        jsr     LBC53                           ; BBC8 20 53 BC  S.
        jsr     select_ram_page_001             ; BBCB 20 28 BE  (.
        jsr     LB95C                           ; BBCE 20 5C B9  \.
        ldx     #$FF                            ; BBD1 A2 FF    ..
        ldy     #$10                            ; BBD3 A0 10    ..
        bit     $FDED                           ; BBD5 2C ED FD ,..
        bvc     LBBDE                           ; BBD8 50 04    P.
        ldy     #$28                            ; BBDA A0 28    .(
        ldx     #$4E                            ; BBDC A2 4E    .N
LBBDE:  sty     $A0                             ; BBDE 84 A0    ..
        pla                                     ; BBE0 68       h
        jsr     LBE39                           ; BBE1 20 39 BE  9.
        stx     $FD92                           ; BBE4 8E 92 FD ...
        ldy     #$3C                            ; BBE7 A0 3C    .<
LBBE9:  lda     LBDE5,y                         ; BBE9 B9 E5 BD ...
        sta     L0D00,y                         ; BBEC 99 00 0D ...
        dey                                     ; BBEF 88       .
        bpl     LBBE9                           ; BBF0 10 F7    ..
        lda     #$F4                            ; BBF2 A9 F4    ..
        jsr     LBD10                           ; BBF4 20 10 BD  ..
        jmp     LBD4A                           ; BBF7 4C 4A BD LJ.

; ----------------------------------------------------------------------------
LBBFA:  txa                                     ; BBFA 8A       .
        pha                                     ; BBFB 48       H
        tya                                     ; BBFC 98       .
        pha                                     ; BBFD 48       H
        ldy     #$00                            ; BBFE A0 00    ..
        sec                                     ; BC00 38       8
        lda     LBC81,x                         ; BC01 BD 81 BC ...
        bmi     LBC18                           ; BC04 30 12    0.
        beq     LBC11                           ; BC06 F0 09    ..
        sta     $A0                             ; BC08 85 A0    ..
        lda     LBC82,x                         ; BC0A BD 82 BC ...
        jsr     LBC53                           ; BC0D 20 53 BC  S.
LBC10:  clc                                     ; BC10 18       .
LBC11:  pla                                     ; BC11 68       h
        tay                                     ; BC12 A8       .
        pla                                     ; BC13 68       h
        tax                                     ; BC14 AA       .
        inx                                     ; BC15 E8       .
        inx                                     ; BC16 E8       .
        rts                                     ; BC17 60       `

; ----------------------------------------------------------------------------
LBC18:  lda     LBC82,x                         ; BC18 BD 82 BC ...
        bne     LBC3F                           ; BC1B D0 22    ."
        lda     #$01                            ; BC1D A9 01    ..
        sta     $A0                             ; BC1F 85 A0    ..
        ldx     #$04                            ; BC21 A2 04    ..
LBC23:  jsr     select_ram_page_001             ; BC23 20 28 BE  (.
        ldy     #$00                            ; BC26 A0 00    ..
        jsr     LA54E                           ; BC28 20 4E A5  N.
        jsr     LBC79                           ; BC2B 20 79 BC  y.
        jsr     LBC53                           ; BC2E 20 53 BC  S.
        inc     $A6                             ; BC31 E6 A6    ..
        bne     LBC37                           ; BC33 D0 02    ..
        inc     $A7                             ; BC35 E6 A7    ..
LBC37:  dex                                     ; BC37 CA       .
        bne     LBC23                           ; BC38 D0 E9    ..
        sta     $A1                             ; BC3A 85 A1    ..
        jmp     LBC10                           ; BC3C 4C 10 BC L..

; ----------------------------------------------------------------------------
LBC3F:  ldx     $A1                             ; BC3F A6 A1    ..
        lda     LBCC7,x                         ; BC41 BD C7 BC ...
        sta     $A0                             ; BC44 85 A0    ..
        ldx     #$08                            ; BC46 A2 08    ..
        lda     #$E5                            ; BC48 A9 E5    ..
LBC4A:  jsr     LBC53                           ; BC4A 20 53 BC  S.
        dex                                     ; BC4D CA       .
        bne     LBC4A                           ; BC4E D0 FA    ..
        jmp     LBC10                           ; BC50 4C 10 BC L..

; ----------------------------------------------------------------------------
LBC53:  pha                                     ; BC53 48       H
        ldy     $A4                             ; BC54 A4 A4    ..
        sta     $FD80,y                         ; BC56 99 80 FD ...
        lda     $A0                             ; BC59 A5 A0    ..
        sta     $FD00,y                         ; BC5B 99 00 FD ...
        lda     $A4                             ; BC5E A5 A4    ..
        bne     LBC6A                           ; BC60 D0 08    ..
        lda     $FD00                           ; BC62 AD 00 FD ...
        ora     #$80                            ; BC65 09 80    ..
        sta     $FD00                           ; BC67 8D 00 FD ...
LBC6A:  inc     $A4                             ; BC6A E6 A4    ..
        bpl     LBC77                           ; BC6C 10 09    ..
        lda     #$00                            ; BC6E A9 00    ..
        sta     $A4                             ; BC70 85 A4    ..
        inc     $A5                             ; BC72 E6 A5    ..
        jsr     LBC79                           ; BC74 20 79 BC  y.
LBC77:  pla                                     ; BC77 68       h
        rts                                     ; BC78 60       `

; ----------------------------------------------------------------------------
LBC79:  pha                                     ; BC79 48       H
        lda     $A5                             ; BC7A A5 A5    ..
        jsr     LBE39                           ; BC7C 20 39 BE  9.
        pla                                     ; BC7F 68       h
        rts                                     ; BC80 60       `

; ----------------------------------------------------------------------------
LBC81:  .byte   $10                             ; BC81 10       .
LBC82:  .byte   $FF                             ; BC82 FF       .
        .byte   $03                             ; BC83 03       .
        brk                                     ; BC84 00       .
        .byte   $03                             ; BC85 03       .
        brk                                     ; BC86 00       .
        ora     ($FC,x)                         ; BC87 01 FC    ..
        .byte   $0B                             ; BC89 0B       .
        .byte   $FF                             ; BC8A FF       .
        .byte   $03                             ; BC8B 03       .
        brk                                     ; BC8C 00       .
        .byte   $03                             ; BC8D 03       .
        brk                                     ; BC8E 00       .
        ora     ($FE,x)                         ; BC8F 01 FE    ..
        .byte   $FF                             ; BC91 FF       .
        brk                                     ; BC92 00       .
        ora     ($F7,x)                         ; BC93 01 F7    ..
        .byte   $0B                             ; BC95 0B       .
        .byte   $FF                             ; BC96 FF       .
        .byte   $03                             ; BC97 03       .
        brk                                     ; BC98 00       .
        .byte   $03                             ; BC99 03       .
        brk                                     ; BC9A 00       .
        ora     ($FB,x)                         ; BC9B 01 FB    ..
        .byte   $FF                             ; BC9D FF       .
        ora     ($01,x)                         ; BC9E 01 01    ..
        .byte   $F7                             ; BCA0 F7       .
        .byte   $10                             ; BCA1 10       .
LBCA2:  .byte   $FF                             ; BCA2 FF       .
        brk                                     ; BCA3 00       .
        plp                                     ; BCA4 28       (
        lsr     a:$0C                           ; BCA5 4E 0C 00 N..
        .byte   $03                             ; BCA8 03       .
        inc     $01,x                           ; BCA9 F6 01    ..
        .byte   $FC                             ; BCAB FC       .
        ora     $0C4E,y                         ; BCAC 19 4E 0C .N.
        brk                                     ; BCAF 00       .
        .byte   $03                             ; BCB0 03       .
        sbc     $01,x                           ; BCB1 F5 01    ..
        inc     a:$FF,x                         ; BCB3 FE FF 00 ...
        ora     ($F7,x)                         ; BCB6 01 F7    ..
        asl     $4E,x                           ; BCB8 16 4E    .N
        .byte   $0C                             ; BCBA 0C       .
        brk                                     ; BCBB 00       .
        .byte   $03                             ; BCBC 03       .
        sbc     $01,x                           ; BCBD F5 01    ..
        .byte   $FB                             ; BCBF FB       .
        .byte   $FF                             ; BCC0 FF       .
        ora     ($01,x)                         ; BCC1 01 01    ..
        .byte   $F7                             ; BCC3 F7       .
        asl     $4E,x                           ; BCC4 16 4E    .N
        brk                                     ; BCC6 00       .
LBCC7:  bpl     LBCE9                           ; BCC7 10 20    . 
        rti                                     ; BCC9 40       @

; ----------------------------------------------------------------------------
        .byte   $80                             ; BCCA 80       .
LBCCB:  lda     $BA                             ; BCCB A5 BA    ..
        bit     $FDEA                           ; BCCD 2C EA FD ,..
        bvc     LBCD3                           ; BCD0 50 01    P.
        asl     a                               ; BCD2 0A       .
LBCD3:  pha                                     ; BCD3 48       H
        jsr     LBCDF                           ; BCD4 20 DF BC  ..
        pla                                     ; BCD7 68       h
        sta     $FDEF,x                         ; BCD8 9D EF FD ...
LBCDB:  sta     fdc_track                       ; BCDB 8D F9 FC ...
        rts                                     ; BCDE 60       `

; ----------------------------------------------------------------------------
LBCDF:  jsr     LAB39                           ; BCDF 20 39 AB  9.
        and     #$07                            ; BCE2 29 07    ).
        ldx     #$02                            ; BCE4 A2 02    ..
        cmp     #$06                            ; BCE6 C9 06    ..
        .byte   $B0                             ; BCE8 B0       .
LBCE9:  .byte   $03                             ; BCE9 03       .
        and     #$01                            ; BCEA 29 01    ).
        tax                                     ; BCEC AA       .
        rts                                     ; BCED 60       `

; ----------------------------------------------------------------------------
LBCEE:  jsr     LA8F2                           ; BCEE 20 F2 A8  ..
        .byte   $C5                             ; BCF1 C5       .
        .byte   " fault"                        ; BCF2 20 66 61 75 6C 74 fault
        .byte   $00                             ; BCF8 00       .
; ----------------------------------------------------------------------------
LBCF9:  jsr     LA90D                           ; BCF9 20 0D A9  ..
        .byte   $C5                             ; BCFC C5       .
        .byte   "Disk not formatted"            ; BCFD 44 69 73 6B 20 6E 6F 74Disk not
                                                ; BD05 20 66 6F 72 6D 61 74 74 formatt
                                                ; BD0D 65 64    ed
        .byte   $00                             ; BD0F 00       .
; ----------------------------------------------------------------------------
LBD10:  sta     fdc_status_or_cmd               ; BD10 8D F8 FC ...
        rts                                     ; BD13 60       `

; ----------------------------------------------------------------------------
LBD14:  sta     fdc_sector                      ; BD14 8D FA FC ...
        rts                                     ; BD17 60       `

; ----------------------------------------------------------------------------
LBD18:  sta     fdc_data                        ; BD18 8D FB FC ...
LBD1B:  rts                                     ; BD1B 60       `

; ----------------------------------------------------------------------------
LBD1C:  .byte   $20                             ; BD1C 20        
        .byte   $B2                             ; BD1D B2       .
LBD1E:  .byte   $B7                             ; BD1E B7       .
        beq     LBD29                           ; BD1F F0 08    ..
        lda     fdc_status_or_cmd               ; BD21 AD F8 FC ...
        eor     #$80                            ; BD24 49 80    I.
        and     #$80                            ; BD26 29 80    ).
        rts                                     ; BD28 60       `

; ----------------------------------------------------------------------------
LBD29:  lda     #$00                            ; BD29 A9 00    ..
        rts                                     ; BD2B 60       `

; ----------------------------------------------------------------------------
        brk                                     ; BD2C 00       .
        brk                                     ; BD2D 00       .
        brk                                     ; BD2E 00       .
        brk                                     ; BD2F 00       .
        brk                                     ; BD30 00       .
        brk                                     ; BD31 00       .
        brk                                     ; BD32 00       .
        brk                                     ; BD33 00       .
        brk                                     ; BD34 00       .
        brk                                     ; BD35 00       .
        brk                                     ; BD36 00       .
        brk                                     ; BD37 00       .
        brk                                     ; BD38 00       .
        brk                                     ; BD39 00       .
        brk                                     ; BD3A 00       .
        brk                                     ; BD3B 00       .
        brk                                     ; BD3C 00       .
        brk                                     ; BD3D 00       .
        brk                                     ; BD3E 00       .
        brk                                     ; BD3F 00       .
        brk                                     ; BD40 00       .
        brk                                     ; BD41 00       .
        brk                                     ; BD42 00       .
        brk                                     ; BD43 00       .
        brk                                     ; BD44 00       .
        brk                                     ; BD45 00       .
        brk                                     ; BD46 00       .
        brk                                     ; BD47 00       .
        brk                                     ; BD48 00       .
        brk                                     ; BD49 00       .
LBD4A:  jsr     LA8D4                           ; BD4A 20 D4 A8  ..
        ldx     #$FF                            ; BD4D A2 FF    ..
LBD4F:  dex                                     ; BD4F CA       .
        bne     LBD4F                           ; BD50 D0 FD    ..
LBD52:  lda     fdc_status_or_cmd               ; BD52 AD F8 FC ...
        ror     a                               ; BD55 6A       j
        bcs     LBD52                           ; BD56 B0 FA    ..
        nop                                     ; BD58 EA       .
LBD59:  lda     fdc_status_or_cmd               ; BD59 AD F8 FC ...
        and     #$7F                            ; BD5C 29 7F    ).
        jsr     select_ram_page_001             ; BD5E 20 28 BE  (.
        sta     $FDF3                           ; BD61 8D F3 FD ...
        rts                                     ; BD64 60       `

; ----------------------------------------------------------------------------
LBD65:  bcc     LBD1B                           ; BD65 90 B4    ..
        bcc     LBD1E                           ; BD67 90 B5    ..
        .byte   $90                             ; BD69 90       .
LBD6A:  .byte   $3C                             ; BD6A 3C       <
        .byte   $7C                             ; BD6B 7C       |
        .byte   $1C                             ; BD6C 1C       .
        .byte   $5C                             ; BD6D 5C       \
        .byte   $3C                             ; BD6E 3C       <
LBD6F:  sta     $0D2A                           ; BD6F 8D 2A 0D .*.
        lda     fdc_data                        ; BD72 AD FB FC ...
        sta     $FD00                           ; BD75 8D 00 FD ...
        inc     $0D07                           ; BD78 EE 07 0D ...
        bne     LBD80                           ; BD7B D0 03    ..
        inc     $0D08                           ; BD7D EE 08 0D ...
LBD80:  dec     $A0                             ; BD80 C6 A0    ..
        bne     LBD98                           ; BD82 D0 14    ..
        dec     $A1                             ; BD84 C6 A1    ..
        bne     LBD98                           ; BD86 D0 10    ..
        lda     #$40                            ; BD88 A9 40    .@
        sta     L0D00                           ; BD8A 8D 00 0D ...
        lda     #$CE                            ; BD8D A9 CE    ..
        adc     #$01                            ; BD8F 69 01    i.
        bcc     LBD93                           ; BD91 90 00    ..
LBD93:  lda     #$D0                            ; BD93 A9 D0    ..
        sta     fdc_status_or_cmd               ; BD95 8D F8 FC ...
LBD98:  lda     #$00                            ; BD98 A9 00    ..
        rti                                     ; BD9A 40       @

; ----------------------------------------------------------------------------
        lda     #$0E                            ; BD9B A9 0E    ..
        sta     $FE30                           ; BD9D 8D 30 FE .0.
LBDA0:  lda     fdc_status_or_cmd               ; BDA0 AD F8 FC ...
        ror     a                               ; BDA3 6A       j
        bcs     LBDA0                           ; BDA4 B0 FA    ..
        lda     #$00                            ; BDA6 A9 00    ..
        sta     $FE30                           ; BDA8 8D 30 FE .0.
        rts                                     ; BDAB 60       `

; ----------------------------------------------------------------------------
        inc     $0D41                           ; BDAC EE 41 0D .A.
        lda     #$00                            ; BDAF A9 00    ..
        sta     ram_paging_lsb                  ; BDB1 8D FF FC ...
        bne     LBDBE                           ; BDB4 D0 08    ..
        inc     $0D4B                           ; BDB6 EE 4B 0D .K.
        lda     #$00                            ; BDB9 A9 00    ..
        sta     ram_paging_msb                  ; BDBB 8D FE FC ...
LBDBE:  rts                                     ; BDBE 60       `

; ----------------------------------------------------------------------------
LBDBF:  lda     $FD00                           ; BDBF AD 00 FD ...
        sta     fdc_data                        ; BDC2 8D FB FC ...
        inc     $0D04                           ; BDC5 EE 04 0D ...
        bne     LBDCD                           ; BDC8 D0 03    ..
        inc     $0D05                           ; BDCA EE 05 0D ...
LBDCD:  sta     $0D13                           ; BDCD 8D 13 0D ...
        sty     L0D11                           ; BDD0 8C 11 0D ...
        ldy     $A0                             ; BDD3 A4 A0    ..
        lda     fdc_data                        ; BDD5 AD FB FC ...
        sta     $0D15,y                         ; BDD8 99 15 0D ...
        inc     $A0                             ; BDDB E6 A0    ..
        ldy     #$00                            ; BDDD A0 00    ..
        lda     #$00                            ; BDDF A9 00    ..
        rti                                     ; BDE1 40       @

; ----------------------------------------------------------------------------
LBDE2:  jmp     L0D11                           ; BDE2 4C 11 0D L..

; ----------------------------------------------------------------------------
LBDE5:  pha                                     ; BDE5 48       H
        lda     $FD92                           ; BDE6 AD 92 FD ...
        sta     fdc_data                        ; BDE9 8D FB FC ...
        dec     $A0                             ; BDEC C6 A0    ..
        bne     LBE06                           ; BDEE D0 16    ..
        inc     $0D02                           ; BDF0 EE 02 0D ...
        bne     LBE18                           ; BDF3 D0 23    .#
        lda     #$80                            ; BDF5 A9 80    ..
        sta     $0D02                           ; BDF7 8D 02 0D ...
        lda     #$07                            ; BDFA A9 07    ..
        sta     ram_paging_lsb                  ; BDFC 8D FF FC ...
        lda     $FD00                           ; BDFF AD 00 FD ...
        sta     $A0                             ; BE02 85 A0    ..
LBE04:  pla                                     ; BE04 68       h
        rti                                     ; BE05 40       @

; ----------------------------------------------------------------------------
LBE06:  bpl     LBE04                           ; BE06 10 FC    ..
        lda     $A0                             ; BE08 A5 A0    ..
        and     #$7F                            ; BE0A 29 7F    ).
        sta     $A0                             ; BE0C 85 A0    ..
        lda     #$00                            ; BE0E A9 00    ..
        sta     $0D37                           ; BE10 8D 37 0D .7.
        inc     $0D16                           ; BE13 EE 16 0D ...
        pla                                     ; BE16 68       h
        rti                                     ; BE17 40       @

; ----------------------------------------------------------------------------
LBE18:  inc     $0D37                           ; BE18 EE 37 0D .7.
        lda     $FD12                           ; BE1B AD 12 FD ...
        sta     $A0                             ; BE1E 85 A0    ..
        pla                                     ; BE20 68       h
        rti                                     ; BE21 40       @

; ----------------------------------------------------------------------------
        nop                                     ; BE22 EA       .
select_ram_page_000:
        pha                                     ; BE23 48       H
        lda     #$00                            ; BE24 A9 00    ..
        beq     LBE3A                           ; BE26 F0 12    ..
select_ram_page_001:
        pha                                     ; BE28 48       H
        lda     #$01                            ; BE29 A9 01    ..
        bne     LBE3A                           ; BE2B D0 0D    ..
select_ram_page_002:
        pha                                     ; BE2D 48       H
        lda     #$02                            ; BE2E A9 02    ..
        bne     LBE3A                           ; BE30 D0 08    ..
select_ram_page_003:
        pha                                     ; BE32 48       H
        lda     #$03                            ; BE33 A9 03    ..
        bne     LBE3A                           ; BE35 D0 03    ..
select_ram_page_009:
        lda     #$09                            ; BE37 A9 09    ..
LBE39:  pha                                     ; BE39 48       H
LBE3A:  sta     ram_paging_lsb                  ; BE3A 8D FF FC ...
        lda     #$00                            ; BE3D A9 00    ..
        sta     ram_paging_msb                  ; BE3F 8D FE FC ...
        pla                                     ; BE42 68       h
        rts                                     ; BE43 60       `

; ----------------------------------------------------------------------------
LBE44:  jsr     LAB39                           ; BE44 20 39 AB  9.
        ldy     #$0A                            ; BE47 A0 0A    ..
        ldx     #$00                            ; BE49 A2 00    ..
        cmp     #$04                            ; BE4B C9 04    ..
        beq     LBE53                           ; BE4D F0 04    ..
        ldy     #$00                            ; BE4F A0 00    ..
        ldx     #$04                            ; BE51 A2 04    ..
LBE53:  txa                                     ; BE53 8A       .
        pha                                     ; BE54 48       H
        tya                                     ; BE55 98       .
        pha                                     ; BE56 48       H
        lda     $A0                             ; BE57 A5 A0    ..
        beq     LBE5D                           ; BE59 F0 02    ..
        inc     $A1                             ; BE5B E6 A1    ..
LBE5D:  ldy     #$46                            ; BE5D A0 46    .F
LBE5F:  lda     LBEF4,y                         ; BE5F B9 F4 BE ...
        sta     L0D00,y                         ; BE62 99 00 0D ...
        dey                                     ; BE65 88       .
        bpl     LBE5F                           ; BE66 10 F7    ..
        lda     $FDE9                           ; BE68 AD E9 FD ...
        bmi     LBEBB                           ; BE6B 30 4E    0N
        bne     LBE85                           ; BE6D D0 16    ..
        lda     $A6                             ; BE6F A5 A6    ..
        sta     $0D22                           ; BE71 8D 22 0D .".
        lda     $A7                             ; BE74 A5 A7    ..
        sta     $0D23                           ; BE76 8D 23 0D .#.
        lda     $FDCC                           ; BE79 AD CC FD ...
        beq     LBEDB                           ; BE7C F0 5D    .]
        lda     #$8D                            ; BE7E A9 8D    ..
        ldy     #$03                            ; BE80 A0 03    ..
        jmp     LBE9D                           ; BE82 4C 9D BE L..

; ----------------------------------------------------------------------------
LBE85:  lda     $A6                             ; BE85 A5 A6    ..
        sta     $0D1F                           ; BE87 8D 1F 0D ...
        lda     $A7                             ; BE8A A5 A7    ..
        sta     $0D20                           ; BE8C 8D 20 0D . .
        lda     #$20                            ; BE8F A9 20    . 
        sta     $0D28                           ; BE91 8D 28 0D .(.
        lda     $FDCC                           ; BE94 AD CC FD ...
        beq     LBEDB                           ; BE97 F0 42    .B
        lda     #$AD                            ; BE99 A9 AD    ..
        ldy     #$00                            ; BE9B A0 00    ..
LBE9D:  sta     $0D1E,y                         ; BE9D 99 1E 0D ...
        lda     #$E5                            ; BEA0 A9 E5    ..
        sta     $0D1F,y                         ; BEA2 99 1F 0D ...
        lda     #$FE                            ; BEA5 A9 FE    ..
        sta     $0D20,y                         ; BEA7 99 20 0D . .
        lda     #$F4                            ; BEAA A9 F4    ..
        sta     $0D26                           ; BEAC 8D 26 0D .&.
        lda     #$E1                            ; BEAF A9 E1    ..
        sta     $0D39                           ; BEB1 8D 39 0D .9.
        lda     #$AD                            ; BEB4 A9 AD    ..
        sta     $0D27                           ; BEB6 8D 27 0D .'.
        bne     LBEDB                           ; BEB9 D0 20    . 
LBEBB:  ldy     #$31                            ; BEBB A0 31    .1
LBEBD:  lda     LBF3B,y                         ; BEBD B9 3B BF .;.
        sta     L0D00,y                         ; BEC0 99 00 0D ...
        dey                                     ; BEC3 88       .
        bpl     LBEBD                           ; BEC4 10 F7    ..
        ldy     #$00                            ; BEC6 A0 00    ..
        ldx     #$12                            ; BEC8 A2 12    ..
        lda     $FDE9                           ; BECA AD E9 FD ...
        and     #$7F                            ; BECD 29 7F    ).
        beq     LBED5                           ; BECF F0 04    ..
        ldy     #$0D                            ; BED1 A0 0D    ..
        ldx     #$05                            ; BED3 A2 05    ..
LBED5:  lda     $A6                             ; BED5 A5 A6    ..
        sta     $0D01,x                         ; BED7 9D 01 0D ...
        .byte   $AD                             ; BEDA AD       .
LBEDB:  ldy     #$11                            ; BEDB A0 11    ..
        clc                                     ; BEDD 18       .
        pla                                     ; BEDE 68       h
        adc     $BB                             ; BEDF 65 BB    e.
        sta     $0D06,y                         ; BEE1 99 06 0D ...
        pla                                     ; BEE4 68       h
        adc     $BA                             ; BEE5 65 BA    e.
        sta     $0D01,y                         ; BEE7 99 01 0D ...
        ldy     #$00                            ; BEEA A0 00    ..
        jsr     L0D00                           ; BEEC 20 00 0D  ..
        ldy     #$00                            ; BEEF A0 00    ..
        jmp     LBAD7                           ; BEF1 4C D7 BA L..

; ----------------------------------------------------------------------------
LBEF4:  lda     $FDEE                           ; BEF4 AD EE FD ...
        sta     $FE30                           ; BEF7 8D 30 FE .0.
LBEFA:  lda     $A1                             ; BEFA A5 A1    ..
        cmp     #$01                            ; BEFC C9 01    ..
        bne     LBF05                           ; BEFE D0 05    ..
        lda     #$0F                            ; BF00 A9 0F    ..
        sta     $0D26                           ; BF02 8D 26 0D .&.
LBF05:  ldx     #$00                            ; BF05 A2 00    ..
        stx     ram_paging_msb                  ; BF07 8E FE FC ...
        ldx     #$00                            ; BF0A A2 00    ..
        stx     ram_paging_lsb                  ; BF0C 8E FF FC ...
        jsr     L0D40                           ; BF0F 20 40 0D  @.
LBF12:  lda     $FD00,y                         ; BF12 B9 00 FD ...
        sta     $FD00,y                         ; BF15 99 00 FD ...
        iny                                     ; BF18 C8       .
        bne     LBF12                           ; BF19 D0 F7    ..
        inc     $0D23                           ; BF1B EE 23 0D .#.
        inc     $0D17                           ; BF1E EE 17 0D ...
        bne     LBF26                           ; BF21 D0 03    ..
        inc     $0D12                           ; BF23 EE 12 0D ...
LBF26:  dec     $A1                             ; BF26 C6 A1    ..
        bne     LBEFA                           ; BF28 D0 D0    ..
        dec     $A0                             ; BF2A C6 A0    ..
        bne     LBF12                           ; BF2C D0 E4    ..
        lda     $F4                             ; BF2E A5 F4    ..
        sta     $FE30                           ; BF30 8D 30 FE .0.
        rts                                     ; BF33 60       `

; ----------------------------------------------------------------------------
        jsr     L0D46                           ; BF34 20 46 0D  F.
        jsr     L0D46                           ; BF37 20 46 0D  F.
        rts                                     ; BF3A 60       `

; ----------------------------------------------------------------------------
LBF3B:  ldx     #$00                            ; BF3B A2 00    ..
        stx     ram_paging_msb                  ; BF3D 8E FE FC ...
        ldx     #$00                            ; BF40 A2 00    ..
        stx     ram_paging_lsb                  ; BF42 8E FF FC ...
        lda     $FD00,y                         ; BF45 B9 00 FD ...
        ldx     #$00                            ; BF48 A2 00    ..
        stx     ram_paging_msb                  ; BF4A 8E FE FC ...
        ldx     #$00                            ; BF4D A2 00    ..
        stx     ram_paging_lsb                  ; BF4F 8E FF FC ...
        sta     $FD00,y                         ; BF52 99 00 FD ...
        iny                                     ; BF55 C8       .
        bne     LBF3B                           ; BF56 D0 E3    ..
        inc     $0D06                           ; BF58 EE 06 0D ...
        bne     LBF60                           ; BF5B D0 03    ..
        inc     $0D01                           ; BF5D EE 01 0D ...
LBF60:  inc     $0D13                           ; BF60 EE 13 0D ...
        bne     LBF68                           ; BF63 D0 03    ..
        inc     $0D0E                           ; BF65 EE 0E 0D ...
LBF68:  dec     $A1                             ; BF68 C6 A1    ..
        bne     LBF3B                           ; BF6A D0 CF    ..
        rts                                     ; BF6C 60       `

; ----------------------------------------------------------------------------
        brk                                     ; BF6D 00       .
        brk                                     ; BF6E 00       .
        brk                                     ; BF6F 00       .
        brk                                     ; BF70 00       .
        brk                                     ; BF71 00       .
        brk                                     ; BF72 00       .
        brk                                     ; BF73 00       .
        brk                                     ; BF74 00       .
        brk                                     ; BF75 00       .
        brk                                     ; BF76 00       .
        brk                                     ; BF77 00       .
        brk                                     ; BF78 00       .
        brk                                     ; BF79 00       .
        brk                                     ; BF7A 00       .
        brk                                     ; BF7B 00       .
        brk                                     ; BF7C 00       .
        brk                                     ; BF7D 00       .
        brk                                     ; BF7E 00       .
        brk                                     ; BF7F 00       .
        sbc     $E5                             ; BF80 E5 E5    ..
        sbc     $E5                             ; BF82 E5 E5    ..
        sbc     $E5                             ; BF84 E5 E5    ..
        sbc     $E5                             ; BF86 E5 E5    ..
        sbc     $E5                             ; BF88 E5 E5    ..
        sbc     $E5                             ; BF8A E5 E5    ..
        sbc     $E5                             ; BF8C E5 E5    ..
        sbc     $E5                             ; BF8E E5 E5    ..
        sbc     $E5                             ; BF90 E5 E5    ..
        sbc     $E5                             ; BF92 E5 E5    ..
        sbc     $E5                             ; BF94 E5 E5    ..
        sbc     $E5                             ; BF96 E5 E5    ..
        sbc     $E5                             ; BF98 E5 E5    ..
        sbc     $E5                             ; BF9A E5 E5    ..
        sbc     $E5                             ; BF9C E5 E5    ..
        sbc     $E5                             ; BF9E E5 E5    ..
        sbc     $E5                             ; BFA0 E5 E5    ..
        sbc     $E5                             ; BFA2 E5 E5    ..
        sbc     $E5                             ; BFA4 E5 E5    ..
        sbc     $E5                             ; BFA6 E5 E5    ..
        sbc     $E5                             ; BFA8 E5 E5    ..
        sbc     $E5                             ; BFAA E5 E5    ..
        sbc     $E5                             ; BFAC E5 E5    ..
        sbc     $E5                             ; BFAE E5 E5    ..
        sbc     $E5                             ; BFB0 E5 E5    ..
        sbc     $E5                             ; BFB2 E5 E5    ..
        sbc     $E5                             ; BFB4 E5 E5    ..
        sbc     $E5                             ; BFB6 E5 E5    ..
        sbc     $E5                             ; BFB8 E5 E5    ..
        sbc     $E5                             ; BFBA E5 E5    ..
        sbc     $E5                             ; BFBC E5 E5    ..
        sbc     $E5                             ; BFBE E5 E5    ..
        sbc     $E5                             ; BFC0 E5 E5    ..
        sbc     $E5                             ; BFC2 E5 E5    ..
        sbc     $E5                             ; BFC4 E5 E5    ..
        sbc     $E5                             ; BFC6 E5 E5    ..
        sbc     $E5                             ; BFC8 E5 E5    ..
        sbc     $E5                             ; BFCA E5 E5    ..
        sbc     $E5                             ; BFCC E5 E5    ..
        sbc     $E5                             ; BFCE E5 E5    ..
        sbc     $E5                             ; BFD0 E5 E5    ..
        sbc     $E5                             ; BFD2 E5 E5    ..
        sbc     $E5                             ; BFD4 E5 E5    ..
        sbc     $E5                             ; BFD6 E5 E5    ..
        sbc     $E5                             ; BFD8 E5 E5    ..
        sbc     $E5                             ; BFDA E5 E5    ..
        sbc     $E5                             ; BFDC E5 E5    ..
        sbc     $E5                             ; BFDE E5 E5    ..
        sbc     $E5                             ; BFE0 E5 E5    ..
        sbc     $E5                             ; BFE2 E5 E5    ..
        sbc     $E5                             ; BFE4 E5 E5    ..
        sbc     $E5                             ; BFE6 E5 E5    ..
        sbc     $E5                             ; BFE8 E5 E5    ..
        sbc     $E5                             ; BFEA E5 E5    ..
        sbc     $E5                             ; BFEC E5 E5    ..
        sbc     $E5                             ; BFEE E5 E5    ..
        sbc     $E5                             ; BFF0 E5 E5    ..
        sbc     $E5                             ; BFF2 E5 E5    ..
        sbc     $E5                             ; BFF4 E5 E5    ..
        sbc     $E5                             ; BFF6 E5 E5    ..
        sbc     $E5                             ; BFF8 E5 E5    ..
        sbc     $E5                             ; BFFA E5 E5    ..
        sbc     $E5                             ; BFFC E5 E5    ..
        sbc     $E5                             ; BFFE E5 E5    ..
