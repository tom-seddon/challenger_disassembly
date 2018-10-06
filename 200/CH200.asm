; da65 V2.17 - Git df3c43be
; Created:    2018-10-06 18:02:21
; Input file: CH200.rom
; Page:       1


        .setcpu "6502"

; ----------------------------------------------------------------------------
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
fdc_status_or_cmd:= $FCF8
fdc_track       := $FCF9
fdc_sector      := $FCFA
fdc_data        := $FCFB
fdc_control     := $FCFC
ram_paging_msb  := $FCFE
ram_paging_lsb  := $FCFF
LFDE0           := $FDE0
LFDE6           := $FDE6
LFF1B           := $FF1B
LFF1E           := $FF1E
LFF21           := $FF21
LFF24           := $FF24
LFF27           := $FF27
LFF2A           := $FF2A
LFF2D           := $FF2D
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
        jmp     svc                             ; 8003 4C 2F 80 L/.

; ----------------------------------------------------------------------------
        .byte   $82,$1A,$20                     ; 8006 82 1A 20 .. 
; ----------------------------------------------------------------------------
        .byte   "Challenger 3"                  ; 8009 43 68 61 6C 6C 65 6E 67Challeng
                                                ; 8011 65 72 20 33er 3
        .byte   $00                             ; 8015 00       .
        .byte   "2.00"                          ; 8016 32 2E 30 302.00
        .byte   $00                             ; 801A 00       .
        .byte   "(C)1987 Slogger"               ; 801B 28 43 29 31 39 38 37 20(C)1987 
                                                ; 8023 53 6C 6F 67 67 65 72Slogger
        .byte   $00                             ; 802A 00       .
; ----------------------------------------------------------------------------
L802B:  jmp     (fscv)                          ; 802B 6C 1E 02 l..

; ----------------------------------------------------------------------------
        rts                                     ; 802E 60       `

; ----------------------------------------------------------------------------
svc:    cmp     #$01                            ; 802F C9 01    ..
        bne     L8087                           ; 8031 D0 54    .T
svc_handle_absolute_workspace_claim:
        jsr     push_registers_and_tuck_restoration_thunk; 8033 20 4C A8 L.
        jsr     probe_challenger_ram_size       ; 8036 20 1F 82  ..
        tax                                     ; 8039 AA       .
        beq     L8086                           ; 803A F0 4A    .J
        jsr     select_ram_page_001             ; 803C 20 0C BE  ..
        lda     $FD00                           ; 803F AD 00 FD ...
        and     #$7F                            ; 8042 29 7F    ).
        cmp     #$65                            ; 8044 C9 65    .e
        beq     L8053                           ; 8046 F0 0B    ..
        lda     #$65                            ; 8048 A9 65    .e
        sta     $FD00                           ; 804A 8D 00 FD ...
        jsr     reset_current_drive_mappings    ; 804D 20 6A AB  j.
        jsr     LBA00                           ; 8050 20 00 BA  ..
L8053:  lda     #$E5                            ; 8053 A9 E5    ..
        cmp     $FDFD                           ; 8055 CD FD FD ...
        beq     L806D                           ; 8058 F0 13    ..
        sta     $FDFD                           ; 805A 8D FD FD ...
        lda     #$04                            ; 805D A9 04    ..
        sta     $CF                             ; 805F 85 CF    ..
        ldx     #$02                            ; 8061 A2 02    ..
        jsr     LAFF8                           ; 8063 20 F8 AF  ..
        inc     $CF                             ; 8066 E6 CF    ..
        ldx     #$03                            ; 8068 A2 03    ..
        jsr     LAFF8                           ; 806A 20 F8 AF  ..
L806D:  lda     #$FD                            ; 806D A9 FD    ..
        jsr     osbyte_x00_yff                  ; 806F 20 F2 AD  ..
        txa                                     ; 8072 8A       .
        beq     L8078                           ; 8073 F0 03    ..
        jsr     L82A4                           ; 8075 20 A4 82  ..
L8078:  jsr     L82C8                           ; 8078 20 C8 82  ..
        bit     $FDF4                           ; 807B 2C F4 FD ,..
        bpl     L8086                           ; 807E 10 06    ..
        tsx                                     ; 8080 BA       .
        lda     #$17                            ; 8081 A9 17    ..
        sta     $0103,x                         ; 8083 9D 03 01 ...
L8086:  rts                                     ; 8086 60       `

; ----------------------------------------------------------------------------
L8087:  cmp     #$02                            ; 8087 C9 02    ..
        bne     L8096                           ; 8089 D0 0B    ..
svc_handle_private_workspace_claim:
        jsr     select_ram_page_001             ; 808B 20 0C BE  ..
        bit     $FDF4                           ; 808E 2C F4 FD ,..
        bpl     L8095                           ; 8091 10 02    ..
        iny                                     ; 8093 C8       .
        iny                                     ; 8094 C8       .
L8095:  rts                                     ; 8095 60       `

; ----------------------------------------------------------------------------
L8096:  cmp     #$03                            ; 8096 C9 03    ..
        bne     L80B6                           ; 8098 D0 1C    ..
svc_handle_auto_boot:
        jsr     select_ram_page_001             ; 809A 20 0C BE  ..
        sty     $B3                             ; 809D 84 B3    ..
        jsr     push_registers_and_tuck_restoration_thunk; 809F 20 4C A8 L.
        lda     #$7A                            ; 80A2 A9 7A    .z
        jsr     osbyte                          ; 80A4 20 F4 FF  ..
        txa                                     ; 80A7 8A       .
        bmi     L80B3                           ; 80A8 30 09    0.
        cmp     #$52                            ; 80AA C9 52    .R
        bne     L80F3                           ; 80AC D0 45    .E
        lda     #$78                            ; 80AE A9 78    .x
        jsr     osbyte                          ; 80B0 20 F4 FF  ..
L80B3:  jmp     L81EE                           ; 80B3 4C EE 81 L..

; ----------------------------------------------------------------------------
L80B6:  cmp     #$04                            ; 80B6 C9 04    ..
        bne     L80DA                           ; 80B8 D0 20    . 
svc_handle_star:
        jsr     select_ram_page_001             ; 80BA 20 0C BE  ..
        jsr     push_registers_and_tuck_restoration_thunk; 80BD 20 4C A8 L.
        tsx                                     ; 80C0 BA       .
        stx     $B8                             ; 80C1 86 B8    ..
        tya                                     ; 80C3 98       .
        ldx     #$48                            ; 80C4 A2 48    .H
        ldy     #$91                            ; 80C6 A0 91    ..
        jsr     L91A8                           ; 80C8 20 A8 91  ..
        bcs     L80F3                           ; 80CB B0 26    .&
        lda     $FD00                           ; 80CD AD 00 FD ...
        bmi     L80D7                           ; 80D0 30 05    0.
        jsr     L00AA                           ; 80D2 20 AA 00  ..
        bmi     L80F3                           ; 80D5 30 1C    0.
L80D7:  jmp     (L00A8)                         ; 80D7 6C A8 00 l..

; ----------------------------------------------------------------------------
L80DA:  cmp     #$09                            ; 80DA C9 09    ..
        bne     L8113                           ; 80DC D0 35    .5
svc_handle_help:
        jsr     select_ram_page_001             ; 80DE 20 0C BE  ..
        jsr     push_registers_and_tuck_restoration_thunk; 80E1 20 4C A8 L.
        lda     ($F2),y                         ; 80E4 B1 F2    ..
        cmp     #$0D                            ; 80E6 C9 0D    ..
        bne     L80F4                           ; 80E8 D0 0A    ..
        ldx     #$90                            ; 80EA A2 90    ..
        ldy     #$91                            ; 80EC A0 91    ..
        lda     #$03                            ; 80EE A9 03    ..
        jsr     LA534                           ; 80F0 20 34 A5  4.
L80F3:  rts                                     ; 80F3 60       `

; ----------------------------------------------------------------------------
L80F4:  jsr     gsinit_with_carry_clear         ; 80F4 20 F2 A9  ..
        bne     L80FC                           ; 80F7 D0 03    ..
        jmp     L8469                           ; 80F9 4C 69 84 Li.

; ----------------------------------------------------------------------------
L80FC:  tya                                     ; 80FC 98       .
        pha                                     ; 80FD 48       H
        ldx     #$90                            ; 80FE A2 90    ..
        ldy     #$91                            ; 8100 A0 91    ..
        jsr     L91A8                           ; 8102 20 A8 91  ..
        bcs     L810A                           ; 8105 B0 03    ..
        jsr     L80D7                           ; 8107 20 D7 80  ..
L810A:  pla                                     ; 810A 68       h
        tay                                     ; 810B A8       .
L810C:  jsr     gsread                          ; 810C 20 C5 FF  ..
        bcc     L810C                           ; 810F 90 FB    ..
        bcs     L80F4                           ; 8111 B0 E1    ..
L8113:  cmp     #$12                            ; 8113 C9 12    ..
        bne     L8124                           ; 8115 D0 0D    ..
svc_handle_init_fs:
        cpy     #$04                            ; 8117 C0 04    ..
        bne     L80F3                           ; 8119 D0 D8    ..
        jsr     select_ram_page_001             ; 811B 20 0C BE  ..
        jsr     push_registers_and_tuck_restoration_thunk; 811E 20 4C A8 L.
        jmp     disc_command                    ; 8121 4C 0E 82 L..

; ----------------------------------------------------------------------------
L8124:  cmp     #$08                            ; 8124 C9 08    ..
        bne     L80F3                           ; 8126 D0 CB    ..
svc_handle_unknown_osword:
        jsr     select_ram_page_001             ; 8128 20 0C BE  ..
        jsr     LA875                           ; 812B 20 75 A8  u.
        ldy     $F0                             ; 812E A4 F0    ..
        sty     $B0                             ; 8130 84 B0    ..
        ldy     $F1                             ; 8132 A4 F1    ..
        sty     $B1                             ; 8134 84 B1    ..
        ldy     #$00                            ; 8136 A0 00    ..
        sty     $B9                             ; 8138 84 B9    ..
        ldy     $EF                             ; 813A A4 EF    ..
        cpy     #$7F                            ; 813C C0 7F    ..
        bne     L81B8                           ; 813E D0 78    .x
        jsr     LAD88                           ; 8140 20 88 AD  ..
        ldy     #$01                            ; 8143 A0 01    ..
        lda     ($B0),y                         ; 8145 B1 B0    ..
        sta     $A6                             ; 8147 85 A6    ..
        iny                                     ; 8149 C8       .
        lda     ($B0),y                         ; 814A B1 B0    ..
        sta     $A7                             ; 814C 85 A7    ..
        ldy     #$00                            ; 814E A0 00    ..
        lda     ($B0),y                         ; 8150 B1 B0    ..
        bmi     L8165                           ; 8152 30 11    0.
        pha                                     ; 8154 48       H
        rol     a                               ; 8155 2A       *
        rol     a                               ; 8156 2A       *
        rol     a                               ; 8157 2A       *
        and     #$40                            ; 8158 29 40    )@
        ora     $FDED                           ; 815A 0D ED FD ...
        sta     $FDED                           ; 815D 8D ED FD ...
        pla                                     ; 8160 68       h
        and     #$07                            ; 8161 29 07    ).
        sta     $CF                             ; 8163 85 CF    ..
L8165:  iny                                     ; 8165 C8       .
        ldx     #$02                            ; 8166 A2 02    ..
        jsr     L89C2                           ; 8168 20 C2 89  ..
        lda     ($B0),y                         ; 816B B1 B0    ..
        pha                                     ; 816D 48       H
        iny                                     ; 816E C8       .
        lda     ($B0),y                         ; 816F B1 B0    ..
        and     #$3F                            ; 8171 29 3F    )?
        sta     $B2                             ; 8173 85 B2    ..
        jsr     lsr_x4                          ; 8175 20 9E A9  ..
        and     #$01                            ; 8178 29 01    ).
        jsr     L96AE                           ; 817A 20 AE 96  ..
        ldy     #$07                            ; 817D A0 07    ..
        lda     ($B0),y                         ; 817F B1 B0    ..
        iny                                     ; 8181 C8       .
        sta     $BA                             ; 8182 85 BA    ..
        ldx     #$FD                            ; 8184 A2 FD    ..
L8186:  inx                                     ; 8186 E8       .
        inx                                     ; 8187 E8       .
        inx                                     ; 8188 E8       .
        lda     LB8AD,x                         ; 8189 BD AD B8 ...
        beq     L81AE                           ; 818C F0 20    . 
        cmp     $B2                             ; 818E C5 B2    ..
        bne     L8186                           ; 8190 D0 F4    ..
        php                                     ; 8192 08       .
        cli                                     ; 8193 58       X
        lda     #$81                            ; 8194 A9 81    ..
        pha                                     ; 8196 48       H
        lda     #$A2                            ; 8197 A9 A2    ..
        pha                                     ; 8199 48       H
        lda     LB8AE+1,x                       ; 819A BD AF B8 ...
        pha                                     ; 819D 48       H
        lda     LB8AE,x                         ; 819E BD AE B8 ...
        pha                                     ; 81A1 48       H
        rts                                     ; 81A2 60       `

; ----------------------------------------------------------------------------
        tax                                     ; 81A3 AA       .
        plp                                     ; 81A4 28       (
        pla                                     ; 81A5 68       h
        clc                                     ; 81A6 18       .
        adc     #$07                            ; 81A7 69 07    i.
        tay                                     ; 81A9 A8       .
        txa                                     ; 81AA 8A       .
        sta     ($B0),y                         ; 81AB 91 B0    ..
        pha                                     ; 81AD 48       H
L81AE:  pla                                     ; 81AE 68       h
        jsr     LAD71                           ; 81AF 20 71 AD  q.
        jsr     L96E6                           ; 81B2 20 E6 96  ..
        lda     #$00                            ; 81B5 A9 00    ..
        rts                                     ; 81B7 60       `

; ----------------------------------------------------------------------------
L81B8:  cpy     #$7D                            ; 81B8 C0 7D    .}
        bcc     L81ED                           ; 81BA 90 31    .1
        jsr     LAA1E                           ; 81BC 20 1E AA  ..
        jsr     L962F                           ; 81BF 20 2F 96  /.
        cpy     #$7E                            ; 81C2 C0 7E    .~
        beq     L81D2                           ; 81C4 F0 0C    ..
        jsr     select_ram_page_003             ; 81C6 20 16 BE  ..
        ldy     #$00                            ; 81C9 A0 00    ..
        lda     $FD04                           ; 81CB AD 04 FD ...
        sta     ($B0),y                         ; 81CE 91 B0    ..
        tya                                     ; 81D0 98       .
        rts                                     ; 81D1 60       `

; ----------------------------------------------------------------------------
L81D2:  jsr     select_ram_page_003             ; 81D2 20 16 BE  ..
        lda     #$00                            ; 81D5 A9 00    ..
        tay                                     ; 81D7 A8       .
        sta     ($B0),y                         ; 81D8 91 B0    ..
        iny                                     ; 81DA C8       .
        lda     $FD07                           ; 81DB AD 07 FD ...
        sta     ($B0),y                         ; 81DE 91 B0    ..
        iny                                     ; 81E0 C8       .
        lda     $FD06                           ; 81E1 AD 06 FD ...
        and     #$03                            ; 81E4 29 03    ).
        sta     ($B0),y                         ; 81E6 91 B0    ..
        iny                                     ; 81E8 C8       .
        lda     #$00                            ; 81E9 A9 00    ..
        sta     ($B0),y                         ; 81EB 91 B0    ..
L81ED:  rts                                     ; 81ED 60       `

; ----------------------------------------------------------------------------
L81EE:  lda     $B3                             ; 81EE A5 B3    ..
        pha                                     ; 81F0 48       H
        sec                                     ; 81F1 38       8
        jsr     print_CHALLENGER                ; 81F2 20 5E AE  ^.
        jsr     L8469                           ; 81F5 20 69 84  i.
        jsr     get_rom_status_byte             ; 81F8 20 19 82  ..
        and     #$03                            ; 81FB 29 03    ).
        beq     L8217                           ; 81FD F0 18    ..
        jsr     L82C8                           ; 81FF 20 C8 82  ..
        jsr     L8258                           ; 8202 20 58 82  X.
        pla                                     ; 8205 68       h
        bne     L820B                           ; 8206 D0 03    ..
        jmp     L82F7                           ; 8208 4C F7 82 L..

; ----------------------------------------------------------------------------
L820B:  lda     #$00                            ; 820B A9 00    ..
        rts                                     ; 820D 60       `

; ----------------------------------------------------------------------------
disc_command:
        pha                                     ; 820E 48       H
        jsr     check_challenger_presence       ; 820F 20 36 82  6.
        bne     L8217                           ; 8212 D0 03    ..
        jsr     L8258                           ; 8214 20 58 82  X.
L8217:  pla                                     ; 8217 68       h
        rts                                     ; 8218 60       `

; ----------------------------------------------------------------------------
get_rom_status_byte:
        ldx     $F4                             ; 8219 A6 F4    ..
        lda     $0DF0,x                         ; 821B BD F0 0D ...
        rts                                     ; 821E 60       `

; ----------------------------------------------------------------------------
; also CHADFS request $02
probe_challenger_ram_size:
        ldx     #$00                            ; 821F A2 00    ..
        jsr     check_challenger_presence       ; 8221 20 36 82  6.
        bne     L822F                           ; 8224 D0 09    ..
        inx                                     ; 8226 E8       .
        lda     #$04                            ; 8227 A9 04    ..
        jsr     L8238                           ; 8229 20 38 82  8.
        bne     L822F                           ; 822C D0 01    ..
        inx                                     ; 822E E8       .
L822F:  txa                                     ; 822F 8A       .
        ldx     $F4                             ; 8230 A6 F4    ..
        sta     $0DF0,x                         ; 8232 9D F0 0D ...
        rts                                     ; 8235 60       `

; ----------------------------------------------------------------------------
check_challenger_presence:
        lda     #$00                            ; 8236 A9 00    ..
L8238:  sta     ram_paging_msb                  ; 8238 8D FE FC ...
        lda     #$01                            ; 823B A9 01    ..
        sta     ram_paging_lsb                  ; 823D 8D FF FC ...
        lda     $FD00                           ; 8240 AD 00 FD ...
        eor     #$FF                            ; 8243 49 FF    I.
        sta     $FD00                           ; 8245 8D 00 FD ...
        ldy     #$05                            ; 8248 A0 05    ..
L824A:  dey                                     ; 824A 88       .
        bne     L824A                           ; 824B D0 FD    ..
        cmp     $FD00                           ; 824D CD 00 FD ...
        php                                     ; 8250 08       .
        eor     #$FF                            ; 8251 49 FF    I.
        sta     $FD00                           ; 8253 8D 00 FD ...
        plp                                     ; 8256 28       (
        rts                                     ; 8257 60       `

; ----------------------------------------------------------------------------
L8258:  lda     #$00                            ; 8258 A9 00    ..
        tsx                                     ; 825A BA       .
        sta     $0108,x                         ; 825B 9D 08 01 ...
        lda     #$06                            ; 825E A9 06    ..
        jsr     L802B                           ; 8260 20 2B 80  +.
        ldx     #$00                            ; 8263 A2 00    ..
L8265:  lda     LADF9,x                         ; 8265 BD F9 AD ...
        sta     $0212,x                         ; 8268 9D 12 02 ...
        inx                                     ; 826B E8       .
        cpx     #$0E                            ; 826C E0 0E    ..
        bne     L8265                           ; 826E D0 F5    ..
        jsr     osbyte_get_rom_pointer_table_address; 8270 20 E8 AD ..
        sty     $B1                             ; 8273 84 B1    ..
        stx     $B0                             ; 8275 86 B0    ..
        ldx     #$00                            ; 8277 A2 00    ..
        ldy     #$1B                            ; 8279 A0 1B    ..
L827B:  lda     LADF9+14,x                      ; 827B BD 07 AE ...
        sta     ($B0),y                         ; 827E 91 B0    ..
        inx                                     ; 8280 E8       .
        iny                                     ; 8281 C8       .
        lda     LADF9+14,x                      ; 8282 BD 07 AE ...
        sta     ($B0),y                         ; 8285 91 B0    ..
        inx                                     ; 8287 E8       .
        iny                                     ; 8288 C8       .
        lda     $F4                             ; 8289 A5 F4    ..
        sta     ($B0),y                         ; 828B 91 B0    ..
        iny                                     ; 828D C8       .
        cpx     #$0E                            ; 828E E0 0E    ..
        bne     L827B                           ; 8290 D0 E9    ..
        lda     $FD00                           ; 8292 AD 00 FD ...
        ora     #$80                            ; 8295 09 80    ..
        sta     $FD00                           ; 8297 8D 00 FD ...
        lda     #$00                            ; 829A A9 00    ..
        sta     $FDFF                           ; 829C 8D FF FD ...
        ldx     #$0F                            ; 829F A2 0F    ..
        jmp     osbyte_rom_service_request      ; 82A1 4C EC AD L..

; ----------------------------------------------------------------------------
L82A4:  jsr     select_ram_page_001             ; 82A4 20 0C BE  ..
        lda     #$80                            ; 82A7 A9 80    ..
        sta     $FDED                           ; 82A9 8D ED FD ...
        sta     $FDEA                           ; 82AC 8D EA FD ...
        lda     #$0E                            ; 82AF A9 0E    ..
        sta     $FDEE                           ; 82B1 8D EE FD ...
        lda     #$00                            ; 82B4 A9 00    ..
        sta     $FDC7                           ; 82B6 8D C7 FD ...
        sta     $FDC9                           ; 82B9 8D C9 FD ...
        sta     $FDF4                           ; 82BC 8D F4 FD ...
        lda     #$24                            ; 82BF A9 24    .$
        sta     $FDC6                           ; 82C1 8D C6 FD ...
        sta     $FDC8                           ; 82C4 8D C8 FD ...
        rts                                     ; 82C7 60       `

; ----------------------------------------------------------------------------
L82C8:  jsr     select_ram_page_001             ; 82C8 20 0C BE  ..
        jsr     osbyte_read_tube_presence       ; 82CB 20 E4 AD  ..
        txa                                     ; 82CE 8A       .
        eor     #$FF                            ; 82CF 49 FF    I.
        sta     $FDCD                           ; 82D1 8D CD FD ...
        ldy     #$00                            ; 82D4 A0 00    ..
        sty     $FDCE                           ; 82D6 8C CE FD ...
        sty     $FDDE                           ; 82D9 8C DE FD ...
        sty     $FDDD                           ; 82DC 8C DD FD ...
        sty     $FDCC                           ; 82DF 8C CC FD ...
        sty     $FDFF                           ; 82E2 8C FF FD ...
        dey                                     ; 82E5 88       .
        sty     $FDDF                           ; 82E6 8C DF FD ...
        sty     $FDD9                           ; 82E9 8C D9 FD ...
        sty     $FDDC                           ; 82EC 8C DC FD ...
        jsr     osbyte_aff_x00_yff              ; 82EF 20 F0 AD  ..
        stx     $B4                             ; 82F2 86 B4    ..
        jmp     LB8F7                           ; 82F4 4C F7 B8 L..

; ----------------------------------------------------------------------------
L82F7:  jsr     LAA1E                           ; 82F7 20 1E AA  ..
        jsr     L9632                           ; 82FA 20 32 96  2.
        ldy     #$00                            ; 82FD A0 00    ..
        ldx     #$00                            ; 82FF A2 00    ..
        jsr     select_ram_page_003             ; 8301 20 16 BE  ..
        lda     $FD06                           ; 8304 AD 06 FD ...
        jsr     lsr_x4                          ; 8307 20 9E A9  ..
        beq     L8331                           ; 830A F0 25    .%
        pha                                     ; 830C 48       H
        ldx     #$55                            ; 830D A2 55    .U
        ldy     #$83                            ; 830F A0 83    ..
        jsr     set_f2_y                        ; 8311 20 38 92  8.
        jsr     L89DC                           ; 8314 20 DC 89  ..
        jsr     L8C2E                           ; 8317 20 2E 8C  ..
        pla                                     ; 831A 68       h
        bcs     do_boot                         ; 831B B0 15    ..
        jsr     print_string_nterm              ; 831D 20 D3 A8  ..
        .byte   "File not found"                ; 8320 46 69 6C 65 20 6E 6F 74File not
                                                ; 8328 20 66 6F 75 6E 64 found
        .byte   $0D,$0D                         ; 832E 0D 0D    ..
; ----------------------------------------------------------------------------
        nop                                     ; 8330 EA       .
L8331:  rts                                     ; 8331 60       `

; ----------------------------------------------------------------------------
do_boot:cmp     #$02                            ; 8332 C9 02    ..
        bcc     do_load_boot                    ; 8334 90 0E    ..
        beq     do_run_boot                     ; 8336 F0 06    ..
do_exec_boot:
        ldx     #$53                            ; 8338 A2 53    .S
        ldy     #$83                            ; 833A A0 83    ..
        bne     L8348                           ; 833C D0 0A    ..
do_run_boot:
        ldx     #$55                            ; 833E A2 55    .U
        ldy     #$83                            ; 8340 A0 83    ..
        bne     L8348                           ; 8342 D0 04    ..
do_load_boot:
        ldx     #$4B                            ; 8344 A2 4B    .K
        ldy     #$83                            ; 8346 A0 83    ..
L8348:  jmp     oscli                           ; 8348 4C F7 FF L..

; ----------------------------------------------------------------------------
        .byte   "L.!BOOT"                       ; 834B 4C 2E 21 42 4F 4F 54L.!BOOT
        .byte   $0D                             ; 8352 0D       .
        .byte   "E.!BOOT"                       ; 8353 45 2E 21 42 4F 4F 54E.!BOOT
        .byte   $0D                             ; 835A 0D       .
; ----------------------------------------------------------------------------
type_command:
        jsr     LA821                           ; 835B 20 21 A8  !.
        lda     #$00                            ; 835E A9 00    ..
        beq     L8367                           ; 8360 F0 05    ..
list_command:
        jsr     LA821                           ; 8362 20 21 A8  !.
        lda     #$FF                            ; 8365 A9 FF    ..
L8367:  sta     $AB                             ; 8367 85 AB    ..
        lda     #$40                            ; 8369 A9 40    .@
        jsr     osfind                          ; 836B 20 CE FF  ..
        tay                                     ; 836E A8       .
        beq     L83A1                           ; 836F F0 30    .0
        lda     #$0D                            ; 8371 A9 0D    ..
        bne     L8390                           ; 8373 D0 1B    ..
L8375:  jsr     osbget                          ; 8375 20 D7 FF  ..
        bcs     L8398                           ; 8378 B0 1E    ..
        cmp     #$0A                            ; 837A C9 0A    ..
        beq     L8375                           ; 837C F0 F7    ..
        plp                                     ; 837E 28       (
        bne     L8389                           ; 837F D0 08    ..
        pha                                     ; 8381 48       H
        jsr     LA7DA                           ; 8382 20 DA A7  ..
        jsr     print_space_without_spool       ; 8385 20 18 A8  ..
        pla                                     ; 8388 68       h
L8389:  jsr     osasci                          ; 8389 20 E3 FF  ..
        bit     $FF                             ; 838C 24 FF    $.
        bmi     L8399                           ; 838E 30 09    0.
L8390:  and     $AB                             ; 8390 25 AB    %.
        cmp     #$0D                            ; 8392 C9 0D    ..
        php                                     ; 8394 08       .
        jmp     L8375                           ; 8395 4C 75 83 Lu.

; ----------------------------------------------------------------------------
L8398:  plp                                     ; 8398 28       (
L8399:  jsr     L8469                           ; 8399 20 69 84  i.
L839C:  lda     #$00                            ; 839C A9 00    ..
        jmp     osfind                          ; 839E 4C CE FF L..

; ----------------------------------------------------------------------------
L83A1:  jmp     L8B46                           ; 83A1 4C 46 8B LF.

; ----------------------------------------------------------------------------
dump_command:
        jsr     LA821                           ; 83A4 20 21 A8  !.
        lda     #$40                            ; 83A7 A9 40    .@
        jsr     osfind                          ; 83A9 20 CE FF  ..
        tay                                     ; 83AC A8       .
        beq     L83A1                           ; 83AD F0 F2    ..
L83AF:  bit     $FF                             ; 83AF 24 FF    $.
        bmi     L839C                           ; 83B1 30 E9    0.
        lda     $A9                             ; 83B3 A5 A9    ..
        jsr     print_hex_byte                  ; 83B5 20 78 A9  x.
        lda     L00A8                           ; 83B8 A5 A8    ..
        jsr     print_hex_byte                  ; 83BA 20 78 A9  x.
        jsr     print_space_without_spool       ; 83BD 20 18 A8  ..
        tsx                                     ; 83C0 BA       .
        stx     $AD                             ; 83C1 86 AD    ..
        ldx     #$08                            ; 83C3 A2 08    ..
L83C5:  jsr     osbget                          ; 83C5 20 D7 FF  ..
        bcs     L83D4                           ; 83C8 B0 0A    ..
        pha                                     ; 83CA 48       H
        jsr     print_hex_byte                  ; 83CB 20 78 A9  x.
        jsr     print_space_without_spool       ; 83CE 20 18 A8  ..
        dex                                     ; 83D1 CA       .
        bne     L83C5                           ; 83D2 D0 F1    ..
L83D4:  dex                                     ; 83D4 CA       .
        bmi     L83E4                           ; 83D5 30 0D    0.
        php                                     ; 83D7 08       .
        jsr     print_string_nterm              ; 83D8 20 D3 A8  ..
        .byte   "** "                           ; 83DB 2A 2A 20 ** 
; ----------------------------------------------------------------------------
        lda     #$00                            ; 83DE A9 00    ..
        plp                                     ; 83E0 28       (
        pha                                     ; 83E1 48       H
        bpl     L83D4                           ; 83E2 10 F0    ..
L83E4:  php                                     ; 83E4 08       .
        tsx                                     ; 83E5 BA       .
        lda     #$07                            ; 83E6 A9 07    ..
        sta     $AC                             ; 83E8 85 AC    ..
L83EA:  lda     $0109,x                         ; 83EA BD 09 01 ...
        cmp     #$7F                            ; 83ED C9 7F    ..
        bcs     L83F5                           ; 83EF B0 04    ..
        cmp     #$20                            ; 83F1 C9 20    . 
        bcs     L83F7                           ; 83F3 B0 02    ..
L83F5:  lda     #$2E                            ; 83F5 A9 2E    ..
L83F7:  jsr     osasci                          ; 83F7 20 E3 FF  ..
        dex                                     ; 83FA CA       .
        dec     $AC                             ; 83FB C6 AC    ..
        bpl     L83EA                           ; 83FD 10 EB    ..
        jsr     L8469                           ; 83FF 20 69 84  i.
        lda     #$08                            ; 8402 A9 08    ..
        clc                                     ; 8404 18       .
        adc     L00A8                           ; 8405 65 A8    e.
        sta     L00A8                           ; 8407 85 A8    ..
        bcc     L840D                           ; 8409 90 02    ..
        inc     $A9                             ; 840B E6 A9    ..
L840D:  plp                                     ; 840D 28       (
        ldx     $AD                             ; 840E A6 AD    ..
        txs                                     ; 8410 9A       .
        bcc     L83AF                           ; 8411 90 9C    ..
        bcs     L839C                           ; 8413 B0 87    ..
build_command:
        jsr     LA821                           ; 8415 20 21 A8  !.
        lda     #$80                            ; 8418 A9 80    ..
        jsr     osfind                          ; 841A 20 CE FF  ..
        sta     $AB                             ; 841D 85 AB    ..
        jsr     LA838                           ; 841F 20 38 A8  8.
L8422:  jsr     LA7DA                           ; 8422 20 DA A7  ..
        jsr     print_space_without_spool       ; 8425 20 18 A8  ..
        lda     #$FD                            ; 8428 A9 FD    ..
        sta     $AD                             ; 842A 85 AD    ..
        ldx     #$AC                            ; 842C A2 AC    ..
        ldy     #$FF                            ; 842E A0 FF    ..
        sty     L00AE                           ; 8430 84 AE    ..
        sty     $B0                             ; 8432 84 B0    ..
        iny                                     ; 8434 C8       .
        sty     $AC                             ; 8435 84 AC    ..
        sty     $AF                             ; 8437 84 AF    ..
        jsr     select_ram_page_009             ; 8439 20 1B BE  ..
        tya                                     ; 843C 98       .
        jsr     osword                          ; 843D 20 F1 FF  ..
        php                                     ; 8440 08       .
        sty     L00AA                           ; 8441 84 AA    ..
        ldy     $AB                             ; 8443 A4 AB    ..
        ldx     #$00                            ; 8445 A2 00    ..
L8447:  txa                                     ; 8447 8A       .
        cmp     L00AA                           ; 8448 C5 AA    ..
        beq     L8458                           ; 844A F0 0C    ..
        jsr     select_ram_page_009             ; 844C 20 1B BE  ..
        lda     $FD00,x                         ; 844F BD 00 FD ...
        jsr     osbput                          ; 8452 20 D4 FF  ..
        inx                                     ; 8455 E8       .
        bne     L8447                           ; 8456 D0 EF    ..
L8458:  plp                                     ; 8458 28       (
        bcs     L8463                           ; 8459 B0 08    ..
        lda     #$0D                            ; 845B A9 0D    ..
        jsr     osbput                          ; 845D 20 D4 FF  ..
        jmp     L8422                           ; 8460 4C 22 84 L".

; ----------------------------------------------------------------------------
L8463:  jsr     acknowledge_escape              ; 8463 20 8F A9  ..
        jsr     L839C                           ; 8466 20 9C 83  ..
L8469:  pha                                     ; 8469 48       H
        lda     #$0D                            ; 846A A9 0D    ..
        jsr     print_char_without_spool        ; 846C 20 51 A9  Q.
        pla                                     ; 846F 68       h
        rts                                     ; 8470 60       `

; ----------------------------------------------------------------------------
L8471:  jsr     push_registers_and_tuck_restoration_thunk; 8471 20 4C A8 L.
        jsr     select_ram_page_001             ; 8474 20 0C BE  ..
        ldx     $FDCA                           ; 8477 AE CA FD ...
        lda     #$00                            ; 847A A9 00    ..
        beq     L8489                           ; 847C F0 0B    ..
L847E:  jsr     push_registers_and_tuck_restoration_thunk; 847E 20 4C A8 L.
        jsr     select_ram_page_001             ; 8481 20 0C BE  ..
        ldx     $FDCB                           ; 8484 AE CB FD ...
        lda     #$80                            ; 8487 A9 80    ..
L8489:  pha                                     ; 8489 48       H
        stx     $CF                             ; 848A 86 CF    ..
        pla                                     ; 848C 68       h
        bit     $A9                             ; 848D 24 A9    $.
        bmi     L8492                           ; 848F 30 01    0.
L8491:  rts                                     ; 8491 60       `

; ----------------------------------------------------------------------------
L8492:  cmp     L00AA                           ; 8492 C5 AA    ..
        beq     L8491                           ; 8494 F0 FB    ..
        sta     L00AA                           ; 8496 85 AA    ..
        jsr     print_string_nterm              ; 8498 20 D3 A8  ..
        .byte   "Insert "                       ; 849B 49 6E 73 65 72 74 20Insert 
; ----------------------------------------------------------------------------
        nop                                     ; 84A2 EA       .
        bit     L00AA                           ; 84A3 24 AA    $.
        bmi     L84B2                           ; 84A5 30 0B    0.
        jsr     print_string_nterm              ; 84A7 20 D3 A8  ..
        .byte   "source"                        ; 84AA 73 6F 75 72 63 65source
; ----------------------------------------------------------------------------
        bcc     L84C1                           ; 84B0 90 0F    ..
L84B2:  jsr     print_string_nterm              ; 84B2 20 D3 A8  ..
        .byte   "destination"                   ; 84B5 64 65 73 74 69 6E 61 74destinat
                                                ; 84BD 69 6F 6E ion
; ----------------------------------------------------------------------------
        nop                                     ; 84C0 EA       .
L84C1:  jsr     print_string_nterm              ; 84C1 20 D3 A8  ..
        .byte   " disk and hit a key"           ; 84C4 20 64 69 73 6B 20 61 6E disk an
                                                ; 84CC 64 20 68 69 74 20 61 20d hit a 
                                                ; 84D4 6B 65 79 key
; ----------------------------------------------------------------------------
        nop                                     ; 84D7 EA       .
        jsr     L84EF                           ; 84D8 20 EF 84  ..
        jmp     L8469                           ; 84DB 4C 69 84 Li.

; ----------------------------------------------------------------------------
L84DE:  jsr     L84EF                           ; 84DE 20 EF 84  ..
        and     #$5F                            ; 84E1 29 5F    )_
        cmp     #$59                            ; 84E3 C9 59    .Y
        php                                     ; 84E5 08       .
        beq     L84EA                           ; 84E6 F0 02    ..
        lda     #$4E                            ; 84E8 A9 4E    .N
L84EA:  jsr     print_char_without_spool        ; 84EA 20 51 A9  Q.
        plp                                     ; 84ED 28       (
        rts                                     ; 84EE 60       `

; ----------------------------------------------------------------------------
L84EF:  jsr     LADC2                           ; 84EF 20 C2 AD  ..
        jsr     osrdch                          ; 84F2 20 E0 FF  ..
        bcc     L84FA                           ; 84F5 90 03    ..
        ldx     $B8                             ; 84F7 A6 B8    ..
        txs                                     ; 84F9 9A       .
L84FA:  rts                                     ; 84FA 60       `

; ----------------------------------------------------------------------------
L84FB:  ldy     #$00                            ; 84FB A0 00    ..
        beq     L8501                           ; 84FD F0 02    ..
L84FF:  ldy     #$02                            ; 84FF A0 02    ..
L8501:  jsr     select_ram_page_001             ; 8501 20 0C BE  ..
        lda     $FDFA,y                         ; 8504 B9 FA FD ...
        sta     $FDEC                           ; 8507 8D EC FD ...
        lda     $FDF9,y                         ; 850A B9 F9 FD ...
L850D:  pha                                     ; 850D 48       H
        and     #$C0                            ; 850E 29 C0    ).
        sta     $FDED                           ; 8510 8D ED FD ...
        pla                                     ; 8513 68       h
        lsr     a                               ; 8514 4A       J
        ror     a                               ; 8515 6A       j
        ror     a                               ; 8516 6A       j
        pha                                     ; 8517 48       H
        and     #$C0                            ; 8518 29 C0    ).
        sta     $FDEA                           ; 851A 8D EA FD ...
        pla                                     ; 851D 68       h
        and     #$03                            ; 851E 29 03    ).
        jmp     L854C                           ; 8520 4C 4C 85 LL.

; ----------------------------------------------------------------------------
L8523:  jsr     push_registers_and_tuck_restoration_thunk; 8523 20 4C A8 L.
        ldy     #$00                            ; 8526 A0 00    ..
        beq     L852F                           ; 8528 F0 05    ..
L852A:  jsr     push_registers_and_tuck_restoration_thunk; 852A 20 4C A8 L.
        ldy     #$02                            ; 852D A0 02    ..
L852F:  jsr     select_ram_page_001             ; 852F 20 0C BE  ..
        lda     $FDEC                           ; 8532 AD EC FD ...
        sta     $FDFA,y                         ; 8535 99 FA FD ...
        jsr     L853F                           ; 8538 20 3F 85  ?.
        sta     $FDF9,y                         ; 853B 99 F9 FD ...
        rts                                     ; 853E 60       `

; ----------------------------------------------------------------------------
L853F:  jsr     L855C                           ; 853F 20 5C 85  \.
        ora     $FDEA                           ; 8542 0D EA FD ...
        asl     a                               ; 8545 0A       .
        rol     a                               ; 8546 2A       *
        rol     a                               ; 8547 2A       *
        ora     $FDED                           ; 8548 0D ED FD ...
        rts                                     ; 854B 60       `

; ----------------------------------------------------------------------------
L854C:  cmp     #$00                            ; 854C C9 00    ..
        beq     L8558                           ; 854E F0 08    ..
        cmp     #$02                            ; 8550 C9 02    ..
        lda     #$0A                            ; 8552 A9 0A    ..
        bcc     L8558                           ; 8554 90 02    ..
        lda     #$12                            ; 8556 A9 12    ..
L8558:  sta     $FDEB                           ; 8558 8D EB FD ...
        rts                                     ; 855B 60       `

; ----------------------------------------------------------------------------
L855C:  lda     $FDEB                           ; 855C AD EB FD ...
        beq     L8568                           ; 855F F0 07    ..
        cmp     #$12                            ; 8561 C9 12    ..
        lda     #$01                            ; 8563 A9 01    ..
        bcc     L8568                           ; 8565 90 01    ..
        asl     a                               ; 8567 0A       .
L8568:  rts                                     ; 8568 60       `

; ----------------------------------------------------------------------------
backup_command:
        jsr     LA75F                           ; 8569 20 5F A7  _.
        jsr     LA78A                           ; 856C 20 8A A7  ..
        lda     #$00                            ; 856F A9 00    ..
        sta     L00A8                           ; 8571 85 A8    ..
        sta     $C8                             ; 8573 85 C8    ..
        sta     $C9                             ; 8575 85 C9    ..
        sta     $CA                             ; 8577 85 CA    ..
        sta     $CB                             ; 8579 85 CB    ..
        jsr     L865F                           ; 857B 20 5F 86  _.
        lda     #$00                            ; 857E A9 00    ..
        sta     $FDEC                           ; 8580 8D EC FD ...
        jsr     L8523                           ; 8583 20 23 85  #.
        jsr     L863A                           ; 8586 20 3A 86  :.
        sta     LFDE0                           ; 8589 8D E0 FD ...
        stx     $C6                             ; 858C 86 C6    ..
        sty     $C7                             ; 858E 84 C7    ..
        jsr     L8659                           ; 8590 20 59 86  Y.
        lda     #$00                            ; 8593 A9 00    ..
        sta     $FDEC                           ; 8595 8D EC FD ...
        jsr     L852A                           ; 8598 20 2A 85  *.
        lda     $FDF9                           ; 859B AD F9 FD ...
        eor     $FDFB                           ; 859E 4D FB FD M..
        and     #$40                            ; 85A1 29 40    )@
        beq     L85CA                           ; 85A3 F0 25    .%
        jsr     print_string_2_nterm            ; 85A5 20 AD A8  ..
        .byte   $D5                             ; 85A8 D5       .
        .byte   "Both disks MUST be same density"; 85A9 42 6F 74 68 20 64 69 73Both dis
                                                ; 85B1 6B 73 20 4D 55 53 54 20ks MUST 
                                                ; 85B9 62 65 20 73 61 6D 65 20be same 
                                                ; 85C1 64 65 6E 73 69 74 79density
        .byte   $0D                             ; 85C8 0D       .
; ----------------------------------------------------------------------------
        brk                                     ; 85C9 00       .
L85CA:  jsr     L863A                           ; 85CA 20 3A 86  :.
        txa                                     ; 85CD 8A       .
        pha                                     ; 85CE 48       H
        tya                                     ; 85CF 98       .
        pha                                     ; 85D0 48       H
        cmp     $C7                             ; 85D1 C5 C7    ..
        bcc     L85DC                           ; 85D3 90 07    ..
        bne     L8600                           ; 85D5 D0 29    .)
        txa                                     ; 85D7 8A       .
        cmp     $C6                             ; 85D8 C5 C6    ..
        bcs     L8600                           ; 85DA B0 24    .$
L85DC:  lda     #$D5                            ; 85DC A9 D5    ..
        jsr     LA938                           ; 85DE 20 38 A9  8.
        lda     $FDCA                           ; 85E1 AD CA FD ...
        jsr     L8EAD                           ; 85E4 20 AD 8E  ..
        jsr     print_string_nterm              ; 85E7 20 D3 A8  ..
        .byte   " larger than "                 ; 85EA 20 6C 61 72 67 65 72 20 larger 
                                                ; 85F2 74 68 61 6E 20than 
; ----------------------------------------------------------------------------
        lda     $FDCB                           ; 85F7 AD CB FD ...
        jsr     L8EAD                           ; 85FA 20 AD 8E  ..
        jmp     LA8F8                           ; 85FD 4C F8 A8 L..

; ----------------------------------------------------------------------------
L8600:  jsr     L8948                           ; 8600 20 48 89  H.
        jsr     L88CA                           ; 8603 20 CA 88  ..
        jsr     LB74C                           ; 8606 20 4C B7  L.
        bne     L860E                           ; 8609 D0 03    ..
        pla                                     ; 860B 68       h
        pla                                     ; 860C 68       h
        rts                                     ; 860D 60       `

; ----------------------------------------------------------------------------
L860E:  bit     $FDED                           ; 860E 2C ED FD ,..
        bvs     L8629                           ; 8611 70 16    p.
        jsr     L9632                           ; 8613 20 32 96  2.
        pla                                     ; 8616 68       h
        and     #$0F                            ; 8617 29 0F    ).
        ora     LFDE0                           ; 8619 0D E0 FD ...
        jsr     select_ram_page_003             ; 861C 20 16 BE  ..
        sta     $FD06                           ; 861F 8D 06 FD ...
        pla                                     ; 8622 68       h
        sta     $FD07                           ; 8623 8D 07 FD ...
        jmp     L960B                           ; 8626 4C 0B 96 L..

; ----------------------------------------------------------------------------
L8629:  jsr     LACBA                           ; 8629 20 BA AC  ..
        jsr     select_ram_page_002             ; 862C 20 11 BE  ..
        pla                                     ; 862F 68       h
        sta     $FD01                           ; 8630 8D 01 FD ...
        pla                                     ; 8633 68       h
        sta     $FD02                           ; 8634 8D 02 FD ...
        jmp     LACBD                           ; 8637 4C BD AC L..

; ----------------------------------------------------------------------------
L863A:  jsr     select_ram_page_003             ; 863A 20 16 BE  ..
        ldx     $FD07                           ; 863D AE 07 FD ...
        lda     $FD06                           ; 8640 AD 06 FD ...
        pha                                     ; 8643 48       H
        and     #$03                            ; 8644 29 03    ).
        tay                                     ; 8646 A8       .
        jsr     select_ram_page_001             ; 8647 20 0C BE  ..
        bit     $FDED                           ; 864A 2C ED FD ,..
        bvc     L8655                           ; 864D 50 06    P.
        ldx     $FDF6                           ; 864F AE F6 FD ...
        ldy     $FDF5                           ; 8652 AC F5 FD ...
L8655:  pla                                     ; 8655 68       h
        and     #$F0                            ; 8656 29 F0    ).
        rts                                     ; 8658 60       `

; ----------------------------------------------------------------------------
L8659:  jsr     L847E                           ; 8659 20 7E 84  ~.
        jmp     L9632                           ; 865C 4C 32 96 L2.

; ----------------------------------------------------------------------------
L865F:  jsr     L8471                           ; 865F 20 71 84  q.
        jmp     L9632                           ; 8662 4C 32 96 L2.

; ----------------------------------------------------------------------------
copy_command:
        jsr     L8B2E                           ; 8665 20 2E 8B  ..
        jsr     LA78A                           ; 8668 20 8A A7  ..
        jsr     LA565                           ; 866B 20 65 A5  e.
        jsr     L89DC                           ; 866E 20 DC 89  ..
        jsr     L8471                           ; 8671 20 71 84  q.
        jsr     L8B41                           ; 8674 20 41 8B  A.
        jsr     L8523                           ; 8677 20 23 85  #.
        lda     $FDD5                           ; 867A AD D5 FD ...
        sta     $BD                             ; 867D 85 BD    ..
        lda     #$00                            ; 867F A9 00    ..
        sta     $FDF7                           ; 8681 8D F7 FD ...
        sta     L00A8                           ; 8684 85 A8    ..
        lda     #$01                            ; 8686 A9 01    ..
        sta     L00A8                           ; 8688 85 A8    ..
L868A:  tya                                     ; 868A 98       .
        pha                                     ; 868B 48       H
        ldx     #$00                            ; 868C A2 00    ..
L868E:  lda     $C7,x                           ; 868E B5 C7    ..
        pha                                     ; 8690 48       H
        inx                                     ; 8691 E8       .
        cpx     #$08                            ; 8692 E0 08    ..
        bne     L868E                           ; 8694 D0 F8    ..
        jsr     print_string_nterm              ; 8696 20 D3 A8  ..
        .byte   "Reading "                      ; 8699 52 65 61 64 69 6E 67 20Reading 
; ----------------------------------------------------------------------------
        nop                                     ; 86A1 EA       .
        jsr     L8AA3                           ; 86A2 20 A3 8A  ..
        jsr     L8469                           ; 86A5 20 69 84  i.
        ldx     $FDF7                           ; 86A8 AE F7 FD ...
        lda     #$08                            ; 86AB A9 08    ..
        sta     $B0                             ; 86AD 85 B0    ..
L86AF:  jsr     select_ram_page_003             ; 86AF 20 16 BE  ..
        lda     $FD08,y                         ; 86B2 B9 08 FD ...
        jsr     select_ram_page_000             ; 86B5 20 07 BE  ..
        sta     $FD11,x                         ; 86B8 9D 11 FD ...
        inx                                     ; 86BB E8       .
        iny                                     ; 86BC C8       .
        dec     $B0                             ; 86BD C6 B0    ..
        bne     L86AF                           ; 86BF D0 EE    ..
        lda     #$08                            ; 86C1 A9 08    ..
        sta     $B0                             ; 86C3 85 B0    ..
L86C5:  jsr     select_ram_page_002             ; 86C5 20 11 BE  ..
        lda     $FD00,y                         ; 86C8 B9 00 FD ...
        jsr     select_ram_page_000             ; 86CB 20 07 BE  ..
        sta     $FD12,x                         ; 86CE 9D 12 FD ...
        inx                                     ; 86D1 E8       .
        iny                                     ; 86D2 C8       .
        dec     $B0                             ; 86D3 C6 B0    ..
        bne     L86C5                           ; 86D5 D0 EE    ..
        lda     #$00                            ; 86D7 A9 00    ..
        sta     $FD09,x                         ; 86D9 9D 09 FD ...
        lda     $FD05,x                         ; 86DC BD 05 FD ...
        cmp     #$01                            ; 86DF C9 01    ..
        lda     $FD06,x                         ; 86E1 BD 06 FD ...
        adc     #$00                            ; 86E4 69 00    i.
        sta     $FD12,x                         ; 86E6 9D 12 FD ...
        php                                     ; 86E9 08       .
        lda     $FD07,x                         ; 86EA BD 07 FD ...
        jsr     extract_00xx0000                ; 86ED 20 96 A9  ..
        plp                                     ; 86F0 28       (
        adc     #$00                            ; 86F1 69 00    i.
        sta     $FD13,x                         ; 86F3 9D 13 FD ...
        lda     $FD08,x                         ; 86F6 BD 08 FD ...
        sta     $FD14,x                         ; 86F9 9D 14 FD ...
        lda     $FD07,x                         ; 86FC BD 07 FD ...
        and     #$03                            ; 86FF 29 03    ).
        sta     $FD15,x                         ; 8701 9D 15 FD ...
L8704:  jsr     select_ram_page_001             ; 8704 20 0C BE  ..
        sec                                     ; 8707 38       8
        lda     $FDD6                           ; 8708 AD D6 FD ...
        sbc     $BD                             ; 870B E5 BD    ..
        sta     $C3                             ; 870D 85 C3    ..
        ldy     $FDF7                           ; 870F AC F7 FD ...
        jsr     select_ram_page_000             ; 8712 20 07 BE  ..
        lda     $FD22,y                         ; 8715 B9 22 FD .".
        sta     $C6                             ; 8718 85 C6    ..
        lda     $FD23,y                         ; 871A B9 23 FD .#.
        sta     $C7                             ; 871D 85 C7    ..
        lda     $FD24,y                         ; 871F B9 24 FD .$.
        sta     $C8                             ; 8722 85 C8    ..
        lda     $FD25,y                         ; 8724 B9 25 FD .%.
        sta     $C9                             ; 8727 85 C9    ..
        jsr     L8989                           ; 8729 20 89 89  ..
        lda     $BD                             ; 872C A5 BD    ..
        sta     $BF                             ; 872E 85 BF    ..
        lda     #$00                            ; 8730 A9 00    ..
        sta     $BE                             ; 8732 85 BE    ..
        sta     $C2                             ; 8734 85 C2    ..
        lda     $C3                             ; 8736 A5 C3    ..
        jsr     select_ram_page_000             ; 8738 20 07 BE  ..
        sta     $FD18,y                         ; 873B 99 18 FD ...
        jsr     L959C                           ; 873E 20 9C 95  ..
        jsr     L970D                           ; 8741 20 0D 97  ..
        jsr     L899E                           ; 8744 20 9E 89  ..
        clc                                     ; 8747 18       .
        lda     $BD                             ; 8748 A5 BD    ..
        adc     $C3                             ; 874A 65 C3    e.
        sta     $BD                             ; 874C 85 BD    ..
        ldy     $FDF7                           ; 874E AC F7 FD ...
        jsr     select_ram_page_000             ; 8751 20 07 BE  ..
        lda     $C6                             ; 8754 A5 C6    ..
        sta     $FD22,y                         ; 8756 99 22 FD .".
        lda     $C7                             ; 8759 A5 C7    ..
        sta     $FD23,y                         ; 875B 99 23 FD .#.
        lda     $C8                             ; 875E A5 C8    ..
        sta     $FD24,y                         ; 8760 99 24 FD .$.
        lda     $C9                             ; 8763 A5 C9    ..
        sta     $FD25,y                         ; 8765 99 25 FD .%.
        lda     $C6                             ; 8768 A5 C6    ..
        ora     $C7                             ; 876A 05 C7    ..
        beq     L8779                           ; 876C F0 0B    ..
        jsr     select_ram_page_000             ; 876E 20 07 BE  ..
        lda     $FD19,y                         ; 8771 B9 19 FD ...
        ora     #$80                            ; 8774 09 80    ..
        sta     $FD19,y                         ; 8776 99 19 FD ...
L8779:  jsr     select_ram_page_001             ; 8779 20 0C BE  ..
        lda     $BD                             ; 877C A5 BD    ..
        cmp     $FDD6                           ; 877E CD D6 FD ...
        beq     L87BA                           ; 8781 F0 37    .7
        bit     L00A8                           ; 8783 24 A8    $.
        bmi     L87BA                           ; 8785 30 33    03
        lda     L00A8                           ; 8787 A5 A8    ..
        and     #$7F                            ; 8789 29 7F    ).
        cmp     #$08                            ; 878B C9 08    ..
        beq     L87BA                           ; 878D F0 2B    .+
        clc                                     ; 878F 18       .
        lda     $FDF7                           ; 8790 AD F7 FD ...
        adc     #$17                            ; 8793 69 17    i.
        sta     $FDF7                           ; 8795 8D F7 FD ...
L8798:  ldx     #$07                            ; 8798 A2 07    ..
L879A:  pla                                     ; 879A 68       h
        sta     $C7,x                           ; 879B 95 C7    ..
        dex                                     ; 879D CA       .
        bpl     L879A                           ; 879E 10 FA    ..
        pla                                     ; 87A0 68       h
        sta     $FDC2                           ; 87A1 8D C2 FD ...
        jsr     L8C35                           ; 87A4 20 35 8C  5.
        bcc     L87AE                           ; 87A7 90 05    ..
        inc     L00A8                           ; 87A9 E6 A8    ..
        jmp     L868A                           ; 87AB 4C 8A 86 L..

; ----------------------------------------------------------------------------
L87AE:  ldy     $FDF7                           ; 87AE AC F7 FD ...
        bne     L87B4                           ; 87B1 D0 01    ..
        rts                                     ; 87B3 60       `

; ----------------------------------------------------------------------------
L87B4:  lda     L00A8                           ; 87B4 A5 A8    ..
        ora     #$80                            ; 87B6 09 80    ..
        sta     L00A8                           ; 87B8 85 A8    ..
L87BA:  jsr     select_ram_page_001             ; 87BA 20 0C BE  ..
        jsr     L847E                           ; 87BD 20 7E 84  ~.
        lda     $FDD5                           ; 87C0 AD D5 FD ...
        sta     $BD                             ; 87C3 85 BD    ..
        lda     L00A8                           ; 87C5 A5 A8    ..
        and     #$7F                            ; 87C7 29 7F    ).
        tax                                     ; 87C9 AA       .
        ldy     #$E9                            ; 87CA A0 E9    ..
L87CC:  txa                                     ; 87CC 8A       .
        pha                                     ; 87CD 48       H
        clc                                     ; 87CE 18       .
        tya                                     ; 87CF 98       .
        adc     #$17                            ; 87D0 69 17    i.
        sta     $FDF8                           ; 87D2 8D F8 FD ...
        pha                                     ; 87D5 48       H
        tay                                     ; 87D6 A8       .
        jsr     select_ram_page_000             ; 87D7 20 07 BE  ..
        lda     $FD19,y                         ; 87DA B9 19 FD ...
        and     #$40                            ; 87DD 29 40    )@
        bne     L8838                           ; 87DF D0 57    .W
        lda     $FD19,y                         ; 87E1 B9 19 FD ...
        ora     #$40                            ; 87E4 09 40    .@
        sta     $FD19,y                         ; 87E6 99 19 FD ...
        ldx     #$00                            ; 87E9 A2 00    ..
L87EB:  lda     $FD11,y                         ; 87EB B9 11 FD ...
        sta     $BE,x                           ; 87EE 95 BE    ..
        iny                                     ; 87F0 C8       .
        inx                                     ; 87F1 E8       .
        cpx     #$11                            ; 87F2 E0 11    ..
        bne     L87EB                           ; 87F4 D0 F5    ..
        jsr     L9753                           ; 87F6 20 53 97  S.
        jsr     L8C2E                           ; 87F9 20 2E 8C  ..
        bcc     L8801                           ; 87FC 90 03    ..
        jsr     L8C78                           ; 87FE 20 78 8C  x.
L8801:  jsr     L852A                           ; 8801 20 2A 85  *.
        jsr     L958D                           ; 8804 20 8D 95  ..
        jsr     L95AC                           ; 8807 20 AC 95  ..
        lda     $C4                             ; 880A A5 C4    ..
        jsr     extract_00xx0000                ; 880C 20 96 A9  ..
        sta     $C6                             ; 880F 85 C6    ..
        jsr     L940B                           ; 8811 20 0B 94  ..
        jsr     print_string_nterm              ; 8814 20 D3 A8  ..
        .byte   "Writing "                      ; 8817 57 72 69 74 69 6E 67 20Writing 
; ----------------------------------------------------------------------------
        nop                                     ; 881F EA       .
        jsr     L8AA3                           ; 8820 20 A3 8A  ..
        jsr     L8469                           ; 8823 20 69 84  i.
        ldy     $FDF8                           ; 8826 AC F8 FD ...
        jsr     select_ram_page_000             ; 8829 20 07 BE  ..
        lda     $C4                             ; 882C A5 C4    ..
        and     #$03                            ; 882E 29 03    ).
        sta     $FD26,y                         ; 8830 99 26 FD .&.
        lda     $C5                             ; 8833 A5 C5    ..
        sta     $FD27,y                         ; 8835 99 27 FD .'.
L8838:  lda     $FD18,y                         ; 8838 B9 18 FD ...
        sta     $C3                             ; 883B 85 C3    ..
        clc                                     ; 883D 18       .
        lda     $FD27,y                         ; 883E B9 27 FD .'.
        sta     $C5                             ; 8841 85 C5    ..
        adc     $C3                             ; 8843 65 C3    e.
        sta     $FD27,y                         ; 8845 99 27 FD .'.
        lda     $FD26,y                         ; 8848 B9 26 FD .&.
        sta     $C4                             ; 884B 85 C4    ..
        adc     #$00                            ; 884D 69 00    i.
        sta     $FD26,y                         ; 884F 99 26 FD .&.
        lda     $BD                             ; 8852 A5 BD    ..
        sta     $BF                             ; 8854 85 BF    ..
        lda     #$00                            ; 8856 A9 00    ..
        sta     $BE                             ; 8858 85 BE    ..
        sta     $C2                             ; 885A 85 C2    ..
        jsr     L84FF                           ; 885C 20 FF 84  ..
        jsr     L959C                           ; 885F 20 9C 95  ..
        jsr     L9713                           ; 8862 20 13 97  ..
        clc                                     ; 8865 18       .
        lda     $BD                             ; 8866 A5 BD    ..
        adc     $C3                             ; 8868 65 C3    e.
        sta     $BD                             ; 886A 85 BD    ..
        pla                                     ; 886C 68       h
        tay                                     ; 886D A8       .
        pla                                     ; 886E 68       h
        tax                                     ; 886F AA       .
        dex                                     ; 8870 CA       .
        beq     L8876                           ; 8871 F0 03    ..
        jmp     L87CC                           ; 8873 4C CC 87 L..

; ----------------------------------------------------------------------------
L8876:  jsr     L84FB                           ; 8876 20 FB 84  ..
        ldy     $FDF8                           ; 8879 AC F8 FD ...
        jsr     select_ram_page_000             ; 887C 20 07 BE  ..
        lda     $FD19,y                         ; 887F B9 19 FD ...
        and     #$80                            ; 8882 29 80    ).
        beq     L88B0                           ; 8884 F0 2A    .*
        ldx     #$00                            ; 8886 A2 00    ..
L8888:  lda     $FD11,y                         ; 8888 B9 11 FD ...
        sta     $FD11,x                         ; 888B 9D 11 FD ...
        iny                                     ; 888E C8       .
        inx                                     ; 888F E8       .
        cpx     #$17                            ; 8890 E0 17    ..
        bne     L8888                           ; 8892 D0 F4    ..
        lda     #$40                            ; 8894 A9 40    .@
        sta     $FD19                           ; 8896 8D 19 FD ...
        jsr     L8471                           ; 8899 20 71 84  q.
        jsr     L9632                           ; 889C 20 32 96  2.
        lda     $FDD5                           ; 889F AD D5 FD ...
        sta     $BD                             ; 88A2 85 BD    ..
        lda     #$00                            ; 88A4 A9 00    ..
        sta     $FDF7                           ; 88A6 8D F7 FD ...
        sta     L00A8                           ; 88A9 85 A8    ..
        inc     L00A8                           ; 88AB E6 A8    ..
        jmp     L8704                           ; 88AD 4C 04 87 L..

; ----------------------------------------------------------------------------
L88B0:  bit     L00A8                           ; 88B0 24 A8    $.
        bmi     L88C9                           ; 88B2 30 15    0.
        jsr     L8471                           ; 88B4 20 71 84  q.
        jsr     L9632                           ; 88B7 20 32 96  2.
        lda     $FDD5                           ; 88BA AD D5 FD ...
        sta     $BD                             ; 88BD 85 BD    ..
        lda     #$00                            ; 88BF A9 00    ..
        sta     $FDF7                           ; 88C1 8D F7 FD ...
        sta     L00A8                           ; 88C4 85 A8    ..
        jmp     L8798                           ; 88C6 4C 98 87 L..

; ----------------------------------------------------------------------------
L88C9:  rts                                     ; 88C9 60       `

; ----------------------------------------------------------------------------
L88CA:  lda     $FDD5                           ; 88CA AD D5 FD ...
        sta     $BF                             ; 88CD 85 BF    ..
        lda     #$00                            ; 88CF A9 00    ..
        sta     $BE                             ; 88D1 85 BE    ..
        lda     #$0D                            ; 88D3 A9 0D    ..
        sta     ($BE),y                         ; 88D5 91 BE    ..
        iny                                     ; 88D7 C8       .
        lda     #$FF                            ; 88D8 A9 FF    ..
        sta     ($BE),y                         ; 88DA 91 BE    ..
        rts                                     ; 88DC 60       `

; ----------------------------------------------------------------------------
        jsr     L8471                           ; 88DD 20 71 84  q.
        jsr     L9632                           ; 88E0 20 32 96  2.
        jsr     L8523                           ; 88E3 20 23 85  #.
        jsr     select_ram_page_003             ; 88E6 20 16 BE  ..
        lda     $FD07                           ; 88E9 AD 07 FD ...
        sta     $C6                             ; 88EC 85 C6    ..
        lda     $FD06                           ; 88EE AD 06 FD ...
        and     #$03                            ; 88F1 29 03    ).
        sta     $C7                             ; 88F3 85 C7    ..
        lda     $FD06                           ; 88F5 AD 06 FD ...
        and     #$F0                            ; 88F8 29 F0    ).
        jsr     select_ram_page_001             ; 88FA 20 0C BE  ..
        sta     LFDE0                           ; 88FD 8D E0 FD ...
        jsr     L847E                           ; 8900 20 7E 84  ~.
        .byte   $20                             ; 8903 20        
        .byte   $32                             ; 8904 32       2
osfsc_shut_down_fs:
        stx     $4C,y                           ; 8905 96 4C    .L
        rol     a                               ; 8907 2A       *
        sta     $20                             ; 8908 85 20    . 
        asl     $BE,x                           ; 890A 16 BE    ..
        lda     $FD06                           ; 890C AD 06 FD ...
        and     #$03                            ; 890F 29 03    ).
        cmp     $C7                             ; 8911 C5 C7    ..
        bcc     L891C                           ; 8913 90 07    ..
        bne     L891C                           ; 8915 D0 05    ..
        lda     $FD07                           ; 8917 AD 07 FD ...
        cmp     $C6                             ; 891A C5 C6    ..
L891C:  rts                                     ; 891C 60       `

; ----------------------------------------------------------------------------
L891D:  jsr     push_registers_and_tuck_restoration_thunk; 891D 20 4C A8 L.
        lda     #$02                            ; 8920 A9 02    ..
        sta     $FDD7                           ; 8922 8D D7 FD ...
        lda     #$00                            ; 8925 A9 00    ..
        sta     $BF                             ; 8927 85 BF    ..
L8929:  jsr     L8984                           ; 8929 20 84 89  ..
        lda     #$02                            ; 892C A9 02    ..
        sta     $BE                             ; 892E 85 BE    ..
        jsr     L9724                           ; 8930 20 24 97  $.
        lda     $CA                             ; 8933 A5 CA    ..
        sta     $C5                             ; 8935 85 C5    ..
        lda     $CB                             ; 8937 A5 CB    ..
        sta     $C4                             ; 8939 85 C4    ..
        lda     #$02                            ; 893B A9 02    ..
        sta     $BE                             ; 893D 85 BE    ..
        jsr     L9721                           ; 893F 20 21 97  !.
        jsr     L899E                           ; 8942 20 9E 89  ..
        bne     L8929                           ; 8945 D0 E2    ..
        rts                                     ; 8947 60       `

; ----------------------------------------------------------------------------
L8948:  jsr     select_ram_page_001             ; 8948 20 0C BE  ..
        lda     #$00                            ; 894B A9 00    ..
        sta     $BE                             ; 894D 85 BE    ..
        sta     $C2                             ; 894F 85 C2    ..
L8951:  jsr     L8984                           ; 8951 20 84 89  ..
        lda     $FDD5                           ; 8954 AD D5 FD ...
        sta     $BF                             ; 8957 85 BF    ..
        jsr     L84FB                           ; 8959 20 FB 84  ..
        jsr     L8471                           ; 895C 20 71 84  q.
        jsr     L959C                           ; 895F 20 9C 95  ..
        jsr     L970D                           ; 8962 20 0D 97  ..
        lda     $CA                             ; 8965 A5 CA    ..
        sta     $C5                             ; 8967 85 C5    ..
        lda     $CB                             ; 8969 A5 CB    ..
        sta     $C4                             ; 896B 85 C4    ..
        lda     $FDD5                           ; 896D AD D5 FD ...
        sta     $BF                             ; 8970 85 BF    ..
        jsr     L84FF                           ; 8972 20 FF 84  ..
        jsr     L847E                           ; 8975 20 7E 84  ~.
        jsr     L959C                           ; 8978 20 9C 95  ..
        jsr     L9713                           ; 897B 20 13 97  ..
        jsr     L899E                           ; 897E 20 9E 89  ..
        bne     L8951                           ; 8981 D0 CE    ..
        rts                                     ; 8983 60       `

; ----------------------------------------------------------------------------
L8984:  lda     $FDD7                           ; 8984 AD D7 FD ...
        sta     $C3                             ; 8987 85 C3    ..
L8989:  ldx     $C6                             ; 8989 A6 C6    ..
        cpx     $C3                             ; 898B E4 C3    ..
        lda     $C7                             ; 898D A5 C7    ..
        sbc     #$00                            ; 898F E9 00    ..
        bcs     L8995                           ; 8991 B0 02    ..
        stx     $C3                             ; 8993 86 C3    ..
L8995:  lda     $C8                             ; 8995 A5 C8    ..
        sta     $C5                             ; 8997 85 C5    ..
        lda     $C9                             ; 8999 A5 C9    ..
        sta     $C4                             ; 899B 85 C4    ..
        rts                                     ; 899D 60       `

; ----------------------------------------------------------------------------
L899E:  lda     $CA                             ; 899E A5 CA    ..
        clc                                     ; 89A0 18       .
        adc     $C3                             ; 89A1 65 C3    e.
        sta     $CA                             ; 89A3 85 CA    ..
        bcc     L89A9                           ; 89A5 90 02    ..
        inc     $CB                             ; 89A7 E6 CB    ..
L89A9:  lda     $C3                             ; 89A9 A5 C3    ..
        clc                                     ; 89AB 18       .
        adc     $C8                             ; 89AC 65 C8    e.
        sta     $C8                             ; 89AE 85 C8    ..
        bcc     L89B4                           ; 89B0 90 02    ..
        inc     $C9                             ; 89B2 E6 C9    ..
L89B4:  sec                                     ; 89B4 38       8
        lda     $C6                             ; 89B5 A5 C6    ..
        sbc     $C3                             ; 89B7 E5 C3    ..
        sta     $C6                             ; 89B9 85 C6    ..
        bcs     L89BF                           ; 89BB B0 02    ..
        dec     $C7                             ; 89BD C6 C7    ..
L89BF:  ora     $C7                             ; 89BF 05 C7    ..
        rts                                     ; 89C1 60       `

; ----------------------------------------------------------------------------
L89C2:  jsr     L89D2                           ; 89C2 20 D2 89  ..
        dex                                     ; 89C5 CA       .
        dex                                     ; 89C6 CA       .
        jsr     L89CA                           ; 89C7 20 CA 89  ..
L89CA:  lda     ($B0),y                         ; 89CA B1 B0    ..
        sta     $FDB3,x                         ; 89CC 9D B3 FD ...
        inx                                     ; 89CF E8       .
        iny                                     ; 89D0 C8       .
        rts                                     ; 89D1 60       `

; ----------------------------------------------------------------------------
L89D2:  jsr     L89D5                           ; 89D2 20 D5 89  ..
L89D5:  lda     ($B0),y                         ; 89D5 B1 B0    ..
        sta     $BC,x                           ; 89D7 95 BC    ..
        inx                                     ; 89D9 E8       .
        iny                                     ; 89DA C8       .
        rts                                     ; 89DB 60       `

; ----------------------------------------------------------------------------
L89DC:  jsr     LAA1E                           ; 89DC 20 1E AA  ..
        jmp     L89F2                           ; 89DF 4C F2 89 L..

; ----------------------------------------------------------------------------
L89E2:  jsr     LAA1E                           ; 89E2 20 1E AA  ..
L89E5:  lda     $BC                             ; 89E5 A5 BC    ..
        sta     $F2                             ; 89E7 85 F2    ..
        lda     $BD                             ; 89E9 A5 BD    ..
        sta     $F3                             ; 89EB 85 F3    ..
        ldy     #$00                            ; 89ED A0 00    ..
        jsr     gsinit_with_carry_clear         ; 89EF 20 F2 A9  ..
L89F2:  jsr     L8A5D                           ; 89F2 20 5D 8A  ].
        jsr     gsread                          ; 89F5 20 C5 FF  ..
        bcs     L8A4D                           ; 89F8 B0 53    .S
        cmp     #$3A                            ; 89FA C9 3A    .:
        bne     L8A20                           ; 89FC D0 22    ."
        jsr     gsread                          ; 89FE 20 C5 FF  ..
        bcs     L8A5A                           ; 8A01 B0 57    .W
        jsr     LA9F6                           ; 8A03 20 F6 A9  ..
        jsr     gsread                          ; 8A06 20 C5 FF  ..
        bcs     L8A4D                           ; 8A09 B0 42    .B
        cmp     #$2E                            ; 8A0B C9 2E    ..
        beq     L8A1B                           ; 8A0D F0 0C    ..
        jsr     LA9FC                           ; 8A0F 20 FC A9  ..
        jsr     gsread                          ; 8A12 20 C5 FF  ..
        bcs     L8A4D                           ; 8A15 B0 36    .6
        cmp     #$2E                            ; 8A17 C9 2E    ..
        bne     L8A4D                           ; 8A19 D0 32    .2
L8A1B:  jsr     gsread                          ; 8A1B 20 C5 FF  ..
        bcs     L8A4D                           ; 8A1E B0 2D    .-
L8A20:  sta     $C7                             ; 8A20 85 C7    ..
        ldx     #$00                            ; 8A22 A2 00    ..
        jsr     gsread                          ; 8A24 20 C5 FF  ..
        bcs     L8A6D                           ; 8A27 B0 44    .D
        inx                                     ; 8A29 E8       .
        cmp     #$2E                            ; 8A2A C9 2E    ..
        bne     L8A39                           ; 8A2C D0 0B    ..
        lda     $C7                             ; 8A2E A5 C7    ..
        jsr     LAAB0                           ; 8A30 20 B0 AA  ..
        jsr     gsread                          ; 8A33 20 C5 FF  ..
        bcs     L8A4D                           ; 8A36 B0 15    ..
        dex                                     ; 8A38 CA       .
L8A39:  cmp     #$2A                            ; 8A39 C9 2A    .*
        beq     L8A73                           ; 8A3B F0 36    .6
        cmp     #$21                            ; 8A3D C9 21    .!
        bcc     L8A4D                           ; 8A3F 90 0C    ..
        sta     $C7,x                           ; 8A41 95 C7    ..
        inx                                     ; 8A43 E8       .
        jsr     gsread                          ; 8A44 20 C5 FF  ..
        bcs     L8A6C                           ; 8A47 B0 23    .#
        cpx     #$07                            ; 8A49 E0 07    ..
        bne     L8A39                           ; 8A4B D0 EC    ..
L8A4D:  jsr     dobrk_with_Bad_prefix           ; 8A4D 20 9C A8  ..
        .byte   $CC                             ; 8A50 CC       .
        .byte   "filename"                      ; 8A51 66 69 6C 65 6E 61 6D 65filename
; ----------------------------------------------------------------------------
        brk                                     ; 8A59 00       .
L8A5A:  jmp     LAA34                           ; 8A5A 4C 34 AA L4.

; ----------------------------------------------------------------------------
L8A5D:  ldx     #$00                            ; 8A5D A2 00    ..
        lda     #$20                            ; 8A5F A9 20    . 
        bne     L8A65                           ; 8A61 D0 02    ..
L8A63:  lda     #$23                            ; 8A63 A9 23    .#
L8A65:  sta     $C7,x                           ; 8A65 95 C7    ..
        inx                                     ; 8A67 E8       .
        cpx     #$07                            ; 8A68 E0 07    ..
        bne     L8A65                           ; 8A6A D0 F9    ..
L8A6C:  rts                                     ; 8A6C 60       `

; ----------------------------------------------------------------------------
L8A6D:  lda     $C7                             ; 8A6D A5 C7    ..
        cmp     #$2A                            ; 8A6F C9 2A    .*
        bne     L8A6C                           ; 8A71 D0 F9    ..
L8A73:  jsr     gsread                          ; 8A73 20 C5 FF  ..
        bcs     L8A63                           ; 8A76 B0 EB    ..
        cmp     #$20                            ; 8A78 C9 20    . 
        beq     L8A63                           ; 8A7A F0 E7    ..
        bne     L8A4D                           ; 8A7C D0 CF    ..
L8A7E:  jsr     push_registers_and_tuck_restoration_thunk; 8A7E 20 4C A8 L.
        jsr     select_ram_page_003             ; 8A81 20 16 BE  ..
        lda     $FD04                           ; 8A84 AD 04 FD ...
        jsr     L962F                           ; 8A87 20 2F 96  /.
        jsr     select_ram_page_003             ; 8A8A 20 16 BE  ..
        cmp     $FD04                           ; 8A8D CD 04 FD ...
        beq     L8A6C                           ; 8A90 F0 DA    ..
L8A92:  jsr     print_string_2_nterm            ; 8A92 20 AD A8  ..
        .byte   $C8                             ; 8A95 C8       .
        .byte   "Disk changed"                  ; 8A96 44 69 73 6B 20 63 68 61Disk cha
                                                ; 8A9E 6E 67 65 64nged
; ----------------------------------------------------------------------------
        brk                                     ; 8AA2 00       .
L8AA3:  jsr     push_registers_and_tuck_restoration_thunk; 8AA3 20 4C A8 L.
        jsr     select_ram_page_002             ; 8AA6 20 11 BE  ..
        lda     $FD0F,y                         ; 8AA9 B9 0F FD ...
        php                                     ; 8AAC 08       .
        and     #$7F                            ; 8AAD 29 7F    ).
        bne     L8AB6                           ; 8AAF D0 05    ..
        jsr     print_2_spaces_without_spool    ; 8AB1 20 15 A8  ..
        beq     L8ABC                           ; 8AB4 F0 06    ..
L8AB6:  jsr     print_char_without_spool        ; 8AB6 20 51 A9  Q.
        jsr     print_dot_without_spool         ; 8AB9 20 4F A9  O.
L8ABC:  ldx     #$06                            ; 8ABC A2 06    ..
L8ABE:  lda     $FD08,y                         ; 8ABE B9 08 FD ...
        and     #$7F                            ; 8AC1 29 7F    ).
        jsr     print_char_without_spool        ; 8AC3 20 51 A9  Q.
        iny                                     ; 8AC6 C8       .
        dex                                     ; 8AC7 CA       .
        bpl     L8ABE                           ; 8AC8 10 F4    ..
        jsr     select_ram_page_001             ; 8ACA 20 0C BE  ..
        jsr     print_2_spaces_without_spool    ; 8ACD 20 15 A8  ..
        lda     #$20                            ; 8AD0 A9 20    . 
        plp                                     ; 8AD2 28       (
        bpl     L8AD7                           ; 8AD3 10 02    ..
        lda     #$4C                            ; 8AD5 A9 4C    .L
L8AD7:  jsr     print_char_without_spool        ; 8AD7 20 51 A9  Q.
        jmp     print_space_without_spool       ; 8ADA 4C 18 A8 L..

; ----------------------------------------------------------------------------
; Y = number of spaces to print
print_N_spaces_without_spool:
        jsr     print_space_without_spool       ; 8ADD 20 18 A8  ..
        dey                                     ; 8AE0 88       .
        bne     print_N_spaces_without_spool    ; 8AE1 D0 FA    ..
        rts                                     ; 8AE3 60       `

; ----------------------------------------------------------------------------
L8AE4:  lda     #$00                            ; 8AE4 A9 00    ..
        sta     $A5                             ; 8AE6 85 A5    ..
        ldx     $C4                             ; 8AE8 A6 C4    ..
        jmp     L8AF9                           ; 8AEA 4C F9 8A L..

; ----------------------------------------------------------------------------
L8AED:  lda     $C4                             ; 8AED A5 C4    ..
        jsr     extract_00xx0000                ; 8AEF 20 96 A9  ..
        sta     $A5                             ; 8AF2 85 A5    ..
        lda     $C4                             ; 8AF4 A5 C4    ..
        and     #$03                            ; 8AF6 29 03    ).
        tax                                     ; 8AF8 AA       .
L8AF9:  lda     $BE                             ; 8AF9 A5 BE    ..
        sta     $A6                             ; 8AFB 85 A6    ..
        lda     $BF                             ; 8AFD A5 BF    ..
        sta     $A7                             ; 8AFF 85 A7    ..
        lda     $C3                             ; 8B01 A5 C3    ..
        sta     $A4                             ; 8B03 85 A4    ..
        lda     $C2                             ; 8B05 A5 C2    ..
        sta     $A3                             ; 8B07 85 A3    ..
        stx     $BA                             ; 8B09 86 BA    ..
        lda     $C5                             ; 8B0B A5 C5    ..
        sta     $BB                             ; 8B0D 85 BB    ..
        lda     $FDEB                           ; 8B0F AD EB FD ...
        beq     L8B2D                           ; 8B12 F0 19    ..
        lda     $FDEC                           ; 8B14 AD EC FD ...
        sta     $BA                             ; 8B17 85 BA    ..
        dec     $BA                             ; 8B19 C6 BA    ..
        lda     $C5                             ; 8B1B A5 C5    ..
L8B1D:  sec                                     ; 8B1D 38       8
L8B1E:  inc     $BA                             ; 8B1E E6 BA    ..
        sbc     $FDEB                           ; 8B20 ED EB FD ...
        bcs     L8B1E                           ; 8B23 B0 F9    ..
        dex                                     ; 8B25 CA       .
        bpl     L8B1D                           ; 8B26 10 F5    ..
        adc     $FDEB                           ; 8B28 6D EB FD m..
        sta     $BB                             ; 8B2B 85 BB    ..
L8B2D:  rts                                     ; 8B2D 60       `

; ----------------------------------------------------------------------------
L8B2E:  lda     #$23                            ; 8B2E A9 23    .#
        bne     L8B34                           ; 8B30 D0 02    ..
L8B32:  lda     #$FF                            ; 8B32 A9 FF    ..
L8B34:  sta     $FDD8                           ; 8B34 8D D8 FD ...
        rts                                     ; 8B37 60       `

; ----------------------------------------------------------------------------
L8B38:  jsr     L89DC                           ; 8B38 20 DC 89  ..
        jmp     L8B41                           ; 8B3B 4C 41 8B LA.

; ----------------------------------------------------------------------------
L8B3E:  jsr     L89E2                           ; 8B3E 20 E2 89  ..
L8B41:  jsr     L8C2E                           ; 8B41 20 2E 8C  ..
        bcs     L8B2D                           ; 8B44 B0 E7    ..
L8B46:  jsr     dobrk_with_File_prefix          ; 8B46 20 A5 A8  ..
        .byte   $D6                             ; 8B49 D6       .
        .byte   "not found"                     ; 8B4A 6E 6F 74 20 66 6F 75 6Enot foun
                                                ; 8B52 64       d
; ----------------------------------------------------------------------------
        brk                                     ; 8B53 00       .
map_command:
        jsr     LAA16                           ; 8B54 20 16 AA  ..
        jsr     L962F                           ; 8B57 20 2F 96  /.
        lda     #$00                            ; 8B5A A9 00    ..
        sta     $C4                             ; 8B5C 85 C4    ..
        sta     $C6                             ; 8B5E 85 C6    ..
        sta     $C7                             ; 8B60 85 C7    ..
        jsr     LA4F8                           ; 8B62 20 F8 A4  ..
        sta     $C5                             ; 8B65 85 C5    ..
        lda     $FDEC                           ; 8B67 AD EC FD ...
        beq     L8B88                           ; 8B6A F0 1C    ..
        jsr     print_string_nterm              ; 8B6C 20 D3 A8  ..
        .byte   "  Track offset  = "            ; 8B6F 20 20 54 72 61 63 6B 20  Track 
                                                ; 8B77 6F 66 66 73 65 74 20 20offset  
                                                ; 8B7F 3D 20    = 
; ----------------------------------------------------------------------------
        nop                                     ; 8B81 EA       .
        jsr     print_hex_byte                  ; 8B82 20 78 A9  x.
        jsr     L8469                           ; 8B85 20 69 84  i.
L8B88:  jsr     select_ram_page_003             ; 8B88 20 16 BE  ..
        ldy     $FD05                           ; 8B8B AC 05 FD ...
L8B8E:  jsr     L9507                           ; 8B8E 20 07 95  ..
        beq     L8BC2                           ; 8B91 F0 2F    ./
        clc                                     ; 8B93 18       .
        lda     $B0                             ; 8B94 A5 B0    ..
        adc     $C6                             ; 8B96 65 C6    e.
        sta     $C6                             ; 8B98 85 C6    ..
        txa                                     ; 8B9A 8A       .
        adc     $C7                             ; 8B9B 65 C7    e.
        sta     $C7                             ; 8B9D 85 C7    ..
        jsr     print_string_nterm              ; 8B9F 20 D3 A8  ..
        .byte   "  Free space "                 ; 8BA2 20 20 46 72 65 65 20 73  Free s
                                                ; 8BAA 70 61 63 65 20pace 
; ----------------------------------------------------------------------------
        nop                                     ; 8BAF EA       .
        jsr     L8C01                           ; 8BB0 20 01 8C  ..
        jsr     print_space_without_spool       ; 8BB3 20 18 A8  ..
        txa                                     ; 8BB6 8A       .
        jsr     print_hex_nybble                ; 8BB7 20 80 A9  ..
        lda     $B0                             ; 8BBA A5 B0    ..
        jsr     print_hex_byte                  ; 8BBC 20 78 A9  x.
        jsr     L8469                           ; 8BBF 20 69 84  i.
L8BC2:  tya                                     ; 8BC2 98       .
        beq     L8BE0                           ; 8BC3 F0 1B    ..
        jsr     dey_x8                          ; 8BC5 20 B2 A9  ..
        jsr     L8AA3                           ; 8BC8 20 A3 8A  ..
        jsr     L8CE3                           ; 8BCB 20 E3 8C  ..
        jsr     print_space_without_spool       ; 8BCE 20 18 A8  ..
        jsr     L94EB                           ; 8BD1 20 EB 94  ..
        jsr     L8C01                           ; 8BD4 20 01 8C  ..
        jsr     L8469                           ; 8BD7 20 69 84  i.
        jsr     L94D6                           ; 8BDA 20 D6 94  ..
        jmp     L8B8E                           ; 8BDD 4C 8E 8B L..

; ----------------------------------------------------------------------------
L8BE0:  jsr     print_string_nterm              ; 8BE0 20 D3 A8  ..
        .byte   $0D                             ; 8BE3 0D       .
        .byte   "Free sectors "                 ; 8BE4 46 72 65 65 20 73 65 63Free sec
                                                ; 8BEC 74 6F 72 73 20tors 
; ----------------------------------------------------------------------------
        lda     $C7                             ; 8BF1 A5 C7    ..
        jsr     print_hex_nybble                ; 8BF3 20 80 A9  ..
        lda     $C6                             ; 8BF6 A5 C6    ..
        jsr     print_hex_byte                  ; 8BF8 20 78 A9  x.
        jsr     L8469                           ; 8BFB 20 69 84  i.
        jmp     select_ram_page_001             ; 8BFE 4C 0C BE L..

; ----------------------------------------------------------------------------
L8C01:  lda     $C4                             ; 8C01 A5 C4    ..
        jsr     print_hex_nybble                ; 8C03 20 80 A9  ..
        lda     $C5                             ; 8C06 A5 C5    ..
        jmp     print_hex_byte                  ; 8C08 4C 78 A9 Lx.

; ----------------------------------------------------------------------------
osfsc_ex:
        jsr     set_f2_y                        ; 8C0B 20 38 92  8.
        jsr     LAA16                           ; 8C0E 20 16 AA  ..
        ldx     #$00                            ; 8C11 A2 00    ..
        jsr     L8A63                           ; 8C13 20 63 8A  c.
        jmp     info_command                    ; 8C16 4C 1C 8C L..

; ----------------------------------------------------------------------------
osfsc_info:
        jsr     set_f2_y                        ; 8C19 20 38 92  8.
info_command:
        jsr     L8B2E                           ; 8C1C 20 2E 8B  ..
        jsr     LA565                           ; 8C1F 20 65 A5  e.
        jsr     L8B38                           ; 8C22 20 38 8B  8.
L8C25:  jsr     L8CA5                           ; 8C25 20 A5 8C  ..
        jsr     L8C35                           ; 8C28 20 35 8C  5.
        bcs     L8C25                           ; 8C2B B0 F8    ..
        rts                                     ; 8C2D 60       `

; ----------------------------------------------------------------------------
L8C2E:  jsr     L961F                           ; 8C2E 20 1F 96  ..
        ldy     #$F8                            ; 8C31 A0 F8    ..
        bne     L8C3B                           ; 8C33 D0 06    ..
L8C35:  jsr     select_ram_page_001             ; 8C35 20 0C BE  ..
        ldy     $FDC2                           ; 8C38 AC C2 FD ...
L8C3B:  jsr     select_ram_page_003             ; 8C3B 20 16 BE  ..
        jsr     iny_x8                          ; 8C3E 20 A9 A9  ..
        cpy     $FD05                           ; 8C41 CC 05 FD ...
        bcs     L8C99                           ; 8C44 B0 53    .S
        jsr     iny_x8                          ; 8C46 20 A9 A9  ..
        ldx     #$07                            ; 8C49 A2 07    ..
L8C4B:  jsr     select_ram_page_001             ; 8C4B 20 0C BE  ..
        lda     $C7,x                           ; 8C4E B5 C7    ..
        cmp     $FDD8                           ; 8C50 CD D8 FD ...
        beq     L8C66                           ; 8C53 F0 11    ..
        jsr     isalpha                         ; 8C55 20 D1 A9  ..
        jsr     select_ram_page_002             ; 8C58 20 11 BE  ..
        eor     $FD07,y                         ; 8C5B 59 07 FD Y..
        bcs     L8C62                           ; 8C5E B0 02    ..
        and     #$DF                            ; 8C60 29 DF    ).
L8C62:  and     #$7F                            ; 8C62 29 7F    ).
        bne     L8C72                           ; 8C64 D0 0C    ..
L8C66:  dey                                     ; 8C66 88       .
        dex                                     ; 8C67 CA       .
        bpl     L8C4B                           ; 8C68 10 E1    ..
        jsr     select_ram_page_001             ; 8C6A 20 0C BE  ..
        sty     $FDC2                           ; 8C6D 8C C2 FD ...
        sec                                     ; 8C70 38       8
        rts                                     ; 8C71 60       `

; ----------------------------------------------------------------------------
L8C72:  dey                                     ; 8C72 88       .
        dex                                     ; 8C73 CA       .
        bpl     L8C72                           ; 8C74 10 FC    ..
        bmi     L8C3B                           ; 8C76 30 C3    0.
L8C78:  jsr     LA2A8                           ; 8C78 20 A8 A2  ..
L8C7B:  jsr     select_ram_page_002             ; 8C7B 20 11 BE  ..
        lda     $FD10,y                         ; 8C7E B9 10 FD ...
        sta     $FD08,y                         ; 8C81 99 08 FD ...
        jsr     select_ram_page_003             ; 8C84 20 16 BE  ..
        lda     $FD10,y                         ; 8C87 B9 10 FD ...
        sta     $FD08,y                         ; 8C8A 99 08 FD ...
        iny                                     ; 8C8D C8       .
        cpy     $FD05                           ; 8C8E CC 05 FD ...
        bcc     L8C7B                           ; 8C91 90 E8    ..
        tya                                     ; 8C93 98       .
        sbc     #$08                            ; 8C94 E9 08    ..
        sta     $FD05                           ; 8C96 8D 05 FD ...
L8C99:  clc                                     ; 8C99 18       .
L8C9A:  jmp     select_ram_page_001             ; 8C9A 4C 0C BE L..

; ----------------------------------------------------------------------------
L8C9D:  jsr     select_ram_page_001             ; 8C9D 20 0C BE  ..
        bit     $FDD9                           ; 8CA0 2C D9 FD ,..
        bmi     L8C9A                           ; 8CA3 30 F5    0.
L8CA5:  jsr     push_registers_and_tuck_restoration_thunk; 8CA5 20 4C A8 L.
        jsr     L8AA3                           ; 8CA8 20 A3 8A  ..
        tya                                     ; 8CAB 98       .
        pha                                     ; 8CAC 48       H
        lda     #$A1                            ; 8CAD A9 A1    ..
        sta     $B0                             ; 8CAF 85 B0    ..
        lda     #$FD                            ; 8CB1 A9 FD    ..
        sta     $B1                             ; 8CB3 85 B1    ..
        jsr     L8CF7                           ; 8CB5 20 F7 8C  ..
        jsr     select_ram_page_001             ; 8CB8 20 0C BE  ..
        ldy     #$02                            ; 8CBB A0 02    ..
        jsr     print_space_without_spool       ; 8CBD 20 18 A8  ..
        jsr     L8CD1                           ; 8CC0 20 D1 8C  ..
        jsr     L8CD1                           ; 8CC3 20 D1 8C  ..
        jsr     L8CD1                           ; 8CC6 20 D1 8C  ..
        pla                                     ; 8CC9 68       h
        tay                                     ; 8CCA A8       .
        jsr     L8CE3                           ; 8CCB 20 E3 8C  ..
        jmp     L8469                           ; 8CCE 4C 69 84 Li.

; ----------------------------------------------------------------------------
L8CD1:  ldx     #$03                            ; 8CD1 A2 03    ..
L8CD3:  lda     $FDA3,y                         ; 8CD3 B9 A3 FD ...
        jsr     print_hex_byte                  ; 8CD6 20 78 A9  x.
        dey                                     ; 8CD9 88       .
        dex                                     ; 8CDA CA       .
        bne     L8CD3                           ; 8CDB D0 F6    ..
        jsr     iny_x7                          ; 8CDD 20 AA A9  ..
        jmp     print_space_without_spool       ; 8CE0 4C 18 A8 L..

; ----------------------------------------------------------------------------
L8CE3:  jsr     select_ram_page_003             ; 8CE3 20 16 BE  ..
        lda     $FD0E,y                         ; 8CE6 B9 0E FD ...
        and     #$03                            ; 8CE9 29 03    ).
        jsr     print_hex_nybble                ; 8CEB 20 80 A9  ..
        lda     $FD0F,y                         ; 8CEE B9 0F FD ...
        jsr     print_hex_byte                  ; 8CF1 20 78 A9  x.
        jmp     select_ram_page_001             ; 8CF4 4C 0C BE L..

; ----------------------------------------------------------------------------
L8CF7:  jsr     push_registers_and_tuck_restoration_thunk; 8CF7 20 4C A8 L.
        tya                                     ; 8CFA 98       .
        pha                                     ; 8CFB 48       H
        tax                                     ; 8CFC AA       .
        jsr     select_ram_page_001             ; 8CFD 20 0C BE  ..
        ldy     #$02                            ; 8D00 A0 02    ..
        lda     #$00                            ; 8D02 A9 00    ..
L8D04:  sta     ($B0),y                         ; 8D04 91 B0    ..
        iny                                     ; 8D06 C8       .
        cpy     #$12                            ; 8D07 C0 12    ..
        bne     L8D04                           ; 8D09 D0 F9    ..
        ldy     #$02                            ; 8D0B A0 02    ..
L8D0D:  jsr     L8D55                           ; 8D0D 20 55 8D  U.
        iny                                     ; 8D10 C8       .
        iny                                     ; 8D11 C8       .
        cpy     #$0E                            ; 8D12 C0 0E    ..
        bne     L8D0D                           ; 8D14 D0 F7    ..
        pla                                     ; 8D16 68       h
        tax                                     ; 8D17 AA       .
        jsr     select_ram_page_002             ; 8D18 20 11 BE  ..
        lda     $FD0F,x                         ; 8D1B BD 0F FD ...
        bpl     L8D29                           ; 8D1E 10 09    ..
        lda     #$0A                            ; 8D20 A9 0A    ..
        ldy     #$0E                            ; 8D22 A0 0E    ..
        jsr     select_ram_page_001             ; 8D24 20 0C BE  ..
        sta     ($B0),y                         ; 8D27 91 B0    ..
L8D29:  jsr     select_ram_page_003             ; 8D29 20 16 BE  ..
        lda     $FD0E,x                         ; 8D2C BD 0E FD ...
        jsr     select_ram_page_001             ; 8D2F 20 0C BE  ..
        ldy     #$04                            ; 8D32 A0 04    ..
        jsr     L8D43                           ; 8D34 20 43 8D  C.
        ldy     #$0C                            ; 8D37 A0 0C    ..
        lsr     a                               ; 8D39 4A       J
        lsr     a                               ; 8D3A 4A       J
        pha                                     ; 8D3B 48       H
        and     #$03                            ; 8D3C 29 03    ).
        sta     ($B0),y                         ; 8D3E 91 B0    ..
        pla                                     ; 8D40 68       h
        ldy     #$08                            ; 8D41 A0 08    ..
L8D43:  lsr     a                               ; 8D43 4A       J
        lsr     a                               ; 8D44 4A       J
        pha                                     ; 8D45 48       H
        and     #$03                            ; 8D46 29 03    ).
        cmp     #$03                            ; 8D48 C9 03    ..
        bne     L8D51                           ; 8D4A D0 05    ..
        lda     #$FF                            ; 8D4C A9 FF    ..
        sta     ($B0),y                         ; 8D4E 91 B0    ..
        iny                                     ; 8D50 C8       .
L8D51:  sta     ($B0),y                         ; 8D51 91 B0    ..
        pla                                     ; 8D53 68       h
        rts                                     ; 8D54 60       `

; ----------------------------------------------------------------------------
L8D55:  jsr     L8D58                           ; 8D55 20 58 8D  X.
L8D58:  jsr     select_ram_page_003             ; 8D58 20 16 BE  ..
        lda     $FD08,x                         ; 8D5B BD 08 FD ...
        jsr     select_ram_page_001             ; 8D5E 20 0C BE  ..
        sta     ($B0),y                         ; 8D61 91 B0    ..
        inx                                     ; 8D63 E8       .
        iny                                     ; 8D64 C8       .
        rts                                     ; 8D65 60       `

; ----------------------------------------------------------------------------
stat_command:
        jsr     gsinit_with_carry_clear         ; 8D66 20 F2 A9  ..
        jsr     LAA72                           ; 8D69 20 72 AA  r.
        txa                                     ; 8D6C 8A       .
        and     #$01                            ; 8D6D 29 01    ).
        beq     L8D74                           ; 8D6F F0 03    ..
        jmp     L8DB3                           ; 8D71 4C B3 8D L..

; ----------------------------------------------------------------------------
L8D74:  lda     $CF                             ; 8D74 A5 CF    ..
        and     #$0F                            ; 8D76 29 0F    ).
        sta     $CF                             ; 8D78 85 CF    ..
        lda     #$80                            ; 8D7A A9 80    ..
        sta     $FDE9                           ; 8D7C 8D E9 FD ...
        jsr     LABB5                           ; 8D7F 20 B5 AB  ..
        bit     $FDED                           ; 8D82 2C ED FD ,..
        bvs     L8D8A                           ; 8D85 70 03    p.
        jmp     L8DB3                           ; 8D87 4C B3 8D L..

; ----------------------------------------------------------------------------
L8D8A:  jsr     L8F0B                           ; 8D8A 20 0B 8F  ..
        ldx     #$00                            ; 8D8D A2 00    ..
L8D8F:  jsr     select_ram_page_000             ; 8D8F 20 07 BE  ..
        lda     $FDCD,x                         ; 8D92 BD CD FD ...
        beq     L8DA4                           ; 8D95 F0 0D    ..
        txa                                     ; 8D97 8A       .
        pha                                     ; 8D98 48       H
        jsr     L8469                           ; 8D99 20 69 84  i.
        jsr     L961F                           ; 8D9C 20 1F 96  ..
        jsr     L9033                           ; 8D9F 20 33 90  3.
        pla                                     ; 8DA2 68       h
        tax                                     ; 8DA3 AA       .
L8DA4:  clc                                     ; 8DA4 18       .
        lda     $CF                             ; 8DA5 A5 CF    ..
        adc     #$10                            ; 8DA7 69 10    i.
        sta     $CF                             ; 8DA9 85 CF    ..
        inx                                     ; 8DAB E8       .
        cpx     #$08                            ; 8DAC E0 08    ..
        bne     L8D8F                           ; 8DAE D0 DF    ..
        jmp     select_ram_page_001             ; 8DB0 4C 0C BE L..

; ----------------------------------------------------------------------------
L8DB3:  jsr     L961F                           ; 8DB3 20 1F 96  ..
        jsr     L8F0B                           ; 8DB6 20 0B 8F  ..
        jmp     L9033                           ; 8DB9 4C 33 90 L3.

; ----------------------------------------------------------------------------
L8DBC:  jsr     print_string_nterm              ; 8DBC 20 D3 A8  ..
        .byte   $0D                             ; 8DBF 0D       .
        .byte   "No file"                       ; 8DC0 4E 6F 20 66 69 6C 65No file
        .byte   $0D                             ; 8DC7 0D       .
; ----------------------------------------------------------------------------
        nop                                     ; 8DC8 EA       .
        rts                                     ; 8DC9 60       `

; ----------------------------------------------------------------------------
L8DCA:  jsr     select_ram_page_003             ; 8DCA 20 16 BE  ..
        lda     $FD05                           ; 8DCD AD 05 FD ...
        beq     L8DBC                           ; 8DD0 F0 EA    ..
        sta     $AC                             ; 8DD2 85 AC    ..
        ldy     #$FF                            ; 8DD4 A0 FF    ..
        sty     L00A8                           ; 8DD6 84 A8    ..
        iny                                     ; 8DD8 C8       .
        sty     L00AA                           ; 8DD9 84 AA    ..
L8DDB:  jsr     select_ram_page_002             ; 8DDB 20 11 BE  ..
        cpy     $AC                             ; 8DDE C4 AC    ..
        bcs     L8DFF                           ; 8DE0 B0 1D    ..
        lda     $FD0F,y                         ; 8DE2 B9 0F FD ...
        jsr     select_ram_page_001             ; 8DE5 20 0C BE  ..
        eor     $FDC6                           ; 8DE8 4D C6 FD M..
        jsr     select_ram_page_002             ; 8DEB 20 11 BE  ..
        and     #$7F                            ; 8DEE 29 7F    ).
        bne     L8DFA                           ; 8DF0 D0 08    ..
        lda     $FD0F,y                         ; 8DF2 B9 0F FD ...
        and     #$80                            ; 8DF5 29 80    ).
        sta     $FD0F,y                         ; 8DF7 99 0F FD ...
L8DFA:  jsr     iny_x8                          ; 8DFA 20 A9 A9  ..
        bcc     L8DDB                           ; 8DFD 90 DC    ..
L8DFF:  jsr     select_ram_page_002             ; 8DFF 20 11 BE  ..
        ldy     #$00                            ; 8E02 A0 00    ..
        jsr     L8E9E                           ; 8E04 20 9E 8E  ..
        bcc     L8E12                           ; 8E07 90 09    ..
        jsr     select_ram_page_001             ; 8E09 20 0C BE  ..
        jsr     L9753                           ; 8E0C 20 53 97  S.
        jmp     L8469                           ; 8E0F 4C 69 84 Li.

; ----------------------------------------------------------------------------
L8E12:  sty     $AB                             ; 8E12 84 AB    ..
        ldx     #$00                            ; 8E14 A2 00    ..
L8E16:  jsr     select_ram_page_002             ; 8E16 20 11 BE  ..
        lda     $FD08,y                         ; 8E19 B9 08 FD ...
        and     #$7F                            ; 8E1C 29 7F    ).
        jsr     select_ram_page_001             ; 8E1E 20 0C BE  ..
        sta     $FDA1,x                         ; 8E21 9D A1 FD ...
        iny                                     ; 8E24 C8       .
        inx                                     ; 8E25 E8       .
        cpx     #$08                            ; 8E26 E0 08    ..
        bne     L8E16                           ; 8E28 D0 EC    ..
L8E2A:  jsr     select_ram_page_002             ; 8E2A 20 11 BE  ..
        jsr     L8E9E                           ; 8E2D 20 9E 8E  ..
        bcs     L8E5D                           ; 8E30 B0 2B    .+
        sec                                     ; 8E32 38       8
        ldx     #$06                            ; 8E33 A2 06    ..
L8E35:  jsr     select_ram_page_002             ; 8E35 20 11 BE  ..
        lda     $FD0E,y                         ; 8E38 B9 0E FD ...
        jsr     select_ram_page_001             ; 8E3B 20 0C BE  ..
        sbc     $FDA1,x                         ; 8E3E FD A1 FD ...
        dey                                     ; 8E41 88       .
        dex                                     ; 8E42 CA       .
        bpl     L8E35                           ; 8E43 10 F0    ..
        jsr     iny_x7                          ; 8E45 20 AA A9  ..
        jsr     select_ram_page_002             ; 8E48 20 11 BE  ..
        lda     $FD0F,y                         ; 8E4B B9 0F FD ...
        and     #$7F                            ; 8E4E 29 7F    ).
        jsr     select_ram_page_001             ; 8E50 20 0C BE  ..
        sbc     $FDA8                           ; 8E53 ED A8 FD ...
        bcc     L8E12                           ; 8E56 90 BA    ..
        jsr     iny_x8                          ; 8E58 20 A9 A9  ..
        bcs     L8E2A                           ; 8E5B B0 CD    ..
L8E5D:  jsr     select_ram_page_002             ; 8E5D 20 11 BE  ..
        ldy     $AB                             ; 8E60 A4 AB    ..
        lda     $FD08,y                         ; 8E62 B9 08 FD ...
        ora     #$80                            ; 8E65 09 80    ..
        sta     $FD08,y                         ; 8E67 99 08 FD ...
        jsr     select_ram_page_001             ; 8E6A 20 0C BE  ..
        lda     $FDA8                           ; 8E6D AD A8 FD ...
        cmp     L00AA                           ; 8E70 C5 AA    ..
        beq     L8E84                           ; 8E72 F0 10    ..
        ldx     L00AA                           ; 8E74 A6 AA    ..
        sta     L00AA                           ; 8E76 85 AA    ..
        bne     L8E84                           ; 8E78 D0 0A    ..
        jsr     L8469                           ; 8E7A 20 69 84  i.
L8E7D:  jsr     L8469                           ; 8E7D 20 69 84  i.
        ldy     #$FF                            ; 8E80 A0 FF    ..
        bne     L8E8D                           ; 8E82 D0 09    ..
L8E84:  ldy     L00A8                           ; 8E84 A4 A8    ..
        bne     L8E7D                           ; 8E86 D0 F5    ..
        ldy     #$05                            ; 8E88 A0 05    ..
        jsr     print_N_spaces_without_spool    ; 8E8A 20 DD 8A  ..
L8E8D:  iny                                     ; 8E8D C8       .
        sty     L00A8                           ; 8E8E 84 A8    ..
        ldy     $AB                             ; 8E90 A4 AB    ..
        jsr     print_2_spaces_without_spool    ; 8E92 20 15 A8  ..
        jsr     L8AA3                           ; 8E95 20 A3 8A  ..
        jmp     L8DFF                           ; 8E98 4C FF 8D L..

; ----------------------------------------------------------------------------
L8E9B:  jsr     iny_x8                          ; 8E9B 20 A9 A9  ..
L8E9E:  cpy     $AC                             ; 8E9E C4 AC    ..
        bcs     L8EA7                           ; 8EA0 B0 05    ..
        lda     $FD08,y                         ; 8EA2 B9 08 FD ...
        bmi     L8E9B                           ; 8EA5 30 F4    0.
L8EA7:  rts                                     ; 8EA7 60       `

; ----------------------------------------------------------------------------
L8EA8:  bit     L8EA7                           ; 8EA8 2C A7 8E ,..
        bvs     L8EBE                           ; 8EAB 70 11    p.
L8EAD:  jsr     print_string_nterm              ; 8EAD 20 D3 A8  ..
        .byte   " Drive "                       ; 8EB0 20 44 72 69 76 65 20 Drive 
; ----------------------------------------------------------------------------
        nop                                     ; 8EB7 EA       .
L8EB8:  jsr     select_ram_page_001             ; 8EB8 20 0C BE  ..
        bit     $FDED                           ; 8EBB 2C ED FD ,..
L8EBE:  php                                     ; 8EBE 08       .
        pha                                     ; 8EBF 48       H
        and     #$07                            ; 8EC0 29 07    ).
        jsr     print_hex_nybble                ; 8EC2 20 80 A9  ..
        pla                                     ; 8EC5 68       h
        plp                                     ; 8EC6 28       (
        bvc     L8ECF                           ; 8EC7 50 06    P.
        lsr     a                               ; 8EC9 4A       J
        lsr     a                               ; 8ECA 4A       J
        lsr     a                               ; 8ECB 4A       J
        lsr     a                               ; 8ECC 4A       J
        bne     L8ED0                           ; 8ECD D0 01    ..
L8ECF:  rts                                     ; 8ECF 60       `

; ----------------------------------------------------------------------------
L8ED0:  dey                                     ; 8ED0 88       .
        clc                                     ; 8ED1 18       .
        adc     #$41                            ; 8ED2 69 41    iA
        jmp     print_char_without_spool        ; 8ED4 4C 51 A9 LQ.

; ----------------------------------------------------------------------------
print_disc_title_and_cycle_number:
        ldy     #$0B                            ; 8ED7 A0 0B    ..
        jsr     print_N_spaces_without_spool    ; 8ED9 20 DD 8A  ..
L8EDC:  jsr     select_ram_page_002             ; 8EDC 20 11 BE  ..
        lda     $FD00,y                         ; 8EDF B9 00 FD ...
        cpy     #$08                            ; 8EE2 C0 08    ..
        bcc     L8EEC                           ; 8EE4 90 06    ..
        jsr     select_ram_page_003             ; 8EE6 20 16 BE  ..
        lda     fdc_status_or_cmd,y             ; 8EE9 B9 F8 FC ...
L8EEC:  jsr     print_char_without_spool        ; 8EEC 20 51 A9  Q.
        iny                                     ; 8EEF C8       .
        cpy     #$0C                            ; 8EF0 C0 0C    ..
        bne     L8EDC                           ; 8EF2 D0 E8    ..
        jsr     print_string_nterm              ; 8EF4 20 D3 A8  ..
        .byte   $0D                             ; 8EF7 0D       .
        .byte   " ("                            ; 8EF8 20 28     (
; ----------------------------------------------------------------------------
        nop                                     ; 8EFA EA       .
        jsr     select_ram_page_003             ; 8EFB 20 16 BE  ..
        lda     $FD04                           ; 8EFE AD 04 FD ...
        jsr     print_hex_byte                  ; 8F01 20 78 A9  x.
        jsr     print_string_nterm              ; 8F04 20 D3 A8  ..
        .byte   ")"                             ; 8F07 29       )
        .byte   $0D                             ; 8F08 0D       .
; ----------------------------------------------------------------------------
        nop                                     ; 8F09 EA       .
        rts                                     ; 8F0A 60       `

; ----------------------------------------------------------------------------
L8F0B:  jsr     select_ram_page_001             ; 8F0B 20 0C BE  ..
        jsr     LB74C                           ; 8F0E 20 4C B7  L.
        beq     L8F79                           ; 8F11 F0 66    .f
        bit     $FDED                           ; 8F13 2C ED FD ,..
        bvs     L8F21                           ; 8F16 70 09    p.
        jsr     print_string_nterm              ; 8F18 20 D3 A8  ..
        .byte   "Sing"                          ; 8F1B 53 69 6E 67Sing
; ----------------------------------------------------------------------------
        bcc     L8F29                           ; 8F1F 90 08    ..
L8F21:  jsr     print_string_nterm              ; 8F21 20 D3 A8  ..
        .byte   "Doub"                          ; 8F24 44 6F 75 62Doub
; ----------------------------------------------------------------------------
        nop                                     ; 8F28 EA       .
L8F29:  jsr     print_string_nterm              ; 8F29 20 D3 A8  ..
        .byte   "le density"                    ; 8F2C 6C 65 20 64 65 6E 73 69le densi
                                                ; 8F34 74 79    ty
; ----------------------------------------------------------------------------
        nop                                     ; 8F36 EA       .
        ldy     #$0E                            ; 8F37 A0 0E    ..
        bit     $FDED                           ; 8F39 2C ED FD ,..
        bvc     L8F62                           ; 8F3C 50 24    P$
        ldy     #$05                            ; 8F3E A0 05    ..
        jsr     print_N_spaces_without_spool    ; 8F40 20 DD 8A  ..
        ldx     #$00                            ; 8F43 A2 00    ..
L8F45:  clc                                     ; 8F45 18       .
        jsr     select_ram_page_000             ; 8F46 20 07 BE  ..
        lda     $FDCD,x                         ; 8F49 BD CD FD ...
        php                                     ; 8F4C 08       .
        txa                                     ; 8F4D 8A       .
        plp                                     ; 8F4E 28       (
        bne     L8F53                           ; 8F4F D0 02    ..
        lda     #$ED                            ; 8F51 A9 ED    ..
L8F53:  adc     #$41                            ; 8F53 69 41    iA
        jsr     print_char_without_spool        ; 8F55 20 51 A9  Q.
        inx                                     ; 8F58 E8       .
        cpx     #$08                            ; 8F59 E0 08    ..
        bne     L8F45                           ; 8F5B D0 E8    ..
        jsr     select_ram_page_001             ; 8F5D 20 0C BE  ..
        ldy     #$01                            ; 8F60 A0 01    ..
L8F62:  bit     $FDEA                           ; 8F62 2C EA FD ,..
        bpl     L8F76                           ; 8F65 10 0F    ..
        bvc     L8F76                           ; 8F67 50 0D    P.
        jsr     print_N_spaces_without_spool    ; 8F69 20 DD 8A  ..
        jsr     print_string_nterm              ; 8F6C 20 D3 A8  ..
        .byte   "40in80"                        ; 8F6F 34 30 69 6E 38 3040in80
; ----------------------------------------------------------------------------
        nop                                     ; 8F75 EA       .
L8F76:  jmp     L8469                           ; 8F76 4C 69 84 Li.

; ----------------------------------------------------------------------------
L8F79:  jsr     print_string_255term            ; 8F79 20 17 A9  ..
        .byte   "RAM Disk"                      ; 8F7C 52 41 4D 20 44 69 73 6BRAM Disk
        .byte   $FF                             ; 8F84 FF       .
; ----------------------------------------------------------------------------
        jmp     L8469                           ; 8F85 4C 69 84 Li.

; ----------------------------------------------------------------------------
L8F88:  ldy     #$0D                            ; 8F88 A0 0D    ..
        lda     $CF                             ; 8F8A A5 CF    ..
        jsr     L8EAD                           ; 8F8C 20 AD 8E  ..
        jsr     print_N_spaces_without_spool    ; 8F8F 20 DD 8A  ..
        jsr     select_ram_page_003             ; 8F92 20 16 BE  ..
        jsr     print_string_nterm              ; 8F95 20 D3 A8  ..
        .byte   "Option "                       ; 8F98 4F 70 74 69 6F 6E 20Option 
; ----------------------------------------------------------------------------
        lda     $FD06                           ; 8F9F AD 06 FD ...
        jsr     lsr_x4                          ; 8FA2 20 9E A9  ..
        jsr     print_hex_nybble                ; 8FA5 20 80 A9  ..
        jsr     print_string_nterm              ; 8FA8 20 D3 A8  ..
        .byte   " ("                            ; 8FAB 20 28     (
; ----------------------------------------------------------------------------
        tax                                     ; 8FAD AA       .
        jsr     print_table_string              ; 8FAE 20 F7 8F  ..
        jsr     print_string_nterm              ; 8FB1 20 D3 A8  ..
        .byte   ")"                             ; 8FB4 29       )
        .byte   $0D                             ; 8FB5 0D       .
; ----------------------------------------------------------------------------
        nop                                     ; 8FB6 EA       .
        rts                                     ; 8FB7 60       `

; ----------------------------------------------------------------------------
L8FB8:  jsr     print_string_nterm              ; 8FB8 20 D3 A8  ..
        .byte   " Directory :"                  ; 8FBB 20 44 69 72 65 63 74 6F Directo
                                                ; 8FC3 72 79 20 3Ary :
; ----------------------------------------------------------------------------
        ldy     #$06                            ; 8FC7 A0 06    ..
        jsr     select_ram_page_001             ; 8FC9 20 0C BE  ..
        ldx     #$00                            ; 8FCC A2 00    ..
        jsr     L8FE8                           ; 8FCE 20 E8 8F  ..
        jsr     print_N_spaces_without_spool    ; 8FD1 20 DD 8A  ..
        jsr     print_string_nterm              ; 8FD4 20 D3 A8  ..
        .byte   "Library :"                     ; 8FD7 4C 69 62 72 61 72 79 20Library 
                                                ; 8FDF 3A       :
; ----------------------------------------------------------------------------
        ldx     #$02                            ; 8FE0 A2 02    ..
        jsr     L8FE8                           ; 8FE2 20 E8 8F  ..
        jmp     L8469                           ; 8FE5 4C 69 84 Li.

; ----------------------------------------------------------------------------
L8FE8:  lda     $FDC7,x                         ; 8FE8 BD C7 FD ...
        jsr     L8EA8                           ; 8FEB 20 A8 8E  ..
        jsr     print_dot_without_spool         ; 8FEE 20 4F A9  O.
        lda     $FDC6,x                         ; 8FF1 BD C6 FD ...
        jmp     print_char_without_spool        ; 8FF4 4C 51 A9 LQ.

; ----------------------------------------------------------------------------
; 0="off" 1="LOAD" 2="RUN" 3="EXEC" 4="inactive" 5="256K" 6="512K"
print_table_string:
        lda     strings_offsets_table,x         ; 8FF7 BD 07 90 ...
        tax                                     ; 8FFA AA       .
L8FFB:  lda     strings_data,x                  ; 8FFB BD 0E 90 ...
        beq     L9006                           ; 8FFE F0 06    ..
        jsr     print_char_without_spool        ; 9000 20 51 A9  Q.
        inx                                     ; 9003 E8       .
        bpl     L8FFB                           ; 9004 10 F5    ..
L9006:  rts                                     ; 9006 60       `

; ----------------------------------------------------------------------------
strings_offsets_table:
        .byte   $00,$04,$09,$0D,$12,$1B,$20     ; 9007 00 04 09 0D 12 1B 20...... 
; ----------------------------------------------------------------------------
strings_data:
        .byte   "off"                           ; 900E 6F 66 66 off
        .byte   $00                             ; 9011 00       .
        .byte   "LOAD"                          ; 9012 4C 4F 41 44LOAD
        .byte   $00                             ; 9016 00       .
        .byte   "RUN"                           ; 9017 52 55 4E RUN
        .byte   $00                             ; 901A 00       .
        .byte   "EXEC"                          ; 901B 45 58 45 43EXEC
        .byte   $00                             ; 901F 00       .
        .byte   "inactive"                      ; 9020 69 6E 61 63 74 69 76 65inactive
        .byte   $00                             ; 9028 00       .
        .byte   "256K"                          ; 9029 32 35 36 4B256K
        .byte   $00                             ; 902D 00       .
        .byte   "512K"                          ; 902E 35 31 32 4B512K
        .byte   $00                             ; 9032 00       .
; ----------------------------------------------------------------------------
L9033:  ldy     #$03                            ; 9033 A0 03    ..
        lda     $CF                             ; 9035 A5 CF    ..
        jsr     L8EAD                           ; 9037 20 AD 8E  ..
        jsr     print_N_spaces_without_spool    ; 903A 20 DD 8A  ..
        jsr     print_string_nterm              ; 903D 20 D3 A8  ..
        .byte   "Volume size   "                ; 9040 56 6F 6C 75 6D 65 20 73Volume s
                                                ; 9048 69 7A 65 20 20 20ize   
; ----------------------------------------------------------------------------
        nop                                     ; 904E EA       .
        jsr     select_ram_page_003             ; 904F 20 16 BE  ..
        lda     $FD07                           ; 9052 AD 07 FD ...
        sta     L00A8                           ; 9055 85 A8    ..
        lda     $FD06                           ; 9057 AD 06 FD ...
        and     #$03                            ; 905A 29 03    ).
        sta     $A9                             ; 905C 85 A9    ..
        jsr     LB380                           ; 905E 20 80 B3  ..
        jsr     L8469                           ; 9061 20 69 84  i.
        ldy     #$0B                            ; 9064 A0 0B    ..
        jsr     print_N_spaces_without_spool    ; 9066 20 DD 8A  ..
        jsr     print_string_nterm              ; 9069 20 D3 A8  ..
        .byte   "Volume unused "                ; 906C 56 6F 6C 75 6D 65 20 75Volume u
                                                ; 9074 6E 75 73 65 64 20nused 
; ----------------------------------------------------------------------------
        nop                                     ; 907A EA       .
        jsr     select_ram_page_003             ; 907B 20 16 BE  ..
        ldy     $FD05                           ; 907E AC 05 FD ...
        lda     #$00                            ; 9081 A9 00    ..
        sta     $CB                             ; 9083 85 CB    ..
        jsr     LA4F8                           ; 9085 20 F8 A4  ..
        sta     $CA                             ; 9088 85 CA    ..
L908A:  jsr     dey_x8                          ; 908A 20 B2 A9  ..
        cpy     #$F8                            ; 908D C0 F8    ..
        beq     L909A                           ; 908F F0 09    ..
        jsr     LA714                           ; 9091 20 14 A7  ..
        jsr     LA733                           ; 9094 20 33 A7  3.
        jmp     L908A                           ; 9097 4C 8A 90 L..

; ----------------------------------------------------------------------------
L909A:  jsr     select_ram_page_003             ; 909A 20 16 BE  ..
        sec                                     ; 909D 38       8
        lda     $FD07                           ; 909E AD 07 FD ...
        sbc     $CA                             ; 90A1 E5 CA    ..
        sta     L00A8                           ; 90A3 85 A8    ..
        lda     $FD06                           ; 90A5 AD 06 FD ...
        and     #$03                            ; 90A8 29 03    ).
        sbc     $CB                             ; 90AA E5 CB    ..
        sta     $A9                             ; 90AC 85 A9    ..
        jsr     LB380                           ; 90AE 20 80 B3  ..
        jmp     L8469                           ; 90B1 4C 69 84 Li.

; ----------------------------------------------------------------------------
command_table:
        .byte   "ACCESS"                        ; 90B4 41 43 43 45 53 53ACCESS
; ----------------------------------------------------------------------------
        .dbyt   $936E                           ; 90BA 93 6E    .n
; ----------------------------------------------------------------------------
        .byte   $32                             ; 90BC 32       2
; ----------------------------------------------------------------------------
        .byte   "BACKUP"                        ; 90BD 42 41 43 4B 55 50BACKUP
; ----------------------------------------------------------------------------
        .dbyt   $8569                           ; 90C3 85 69    .i
; ----------------------------------------------------------------------------
        .byte   $54                             ; 90C5 54       T
; ----------------------------------------------------------------------------
        .byte   "COMPACT"                       ; 90C6 43 4F 4D 50 41 43 54COMPACT
; ----------------------------------------------------------------------------
        .dbyt   $A636                           ; 90CD A6 36    .6
; ----------------------------------------------------------------------------
        .byte   $0A                             ; 90CF 0A       .
; ----------------------------------------------------------------------------
        .byte   "CONFIG"                        ; 90D0 43 4F 4E 46 49 47CONFIG
; ----------------------------------------------------------------------------
        .dbyt   $AAF6                           ; 90D6 AA F6    ..
; ----------------------------------------------------------------------------
        .byte   $0A                             ; 90D8 0A       .
; ----------------------------------------------------------------------------
        .byte   "COPY"                          ; 90D9 43 4F 50 59COPY
; ----------------------------------------------------------------------------
        .dbyt   $8665                           ; 90DD 86 65    .e
; ----------------------------------------------------------------------------
        .byte   $64                             ; 90DF 64       d
; ----------------------------------------------------------------------------
        .byte   "DELETE"                        ; 90E0 44 45 4C 45 54 45DELETE
; ----------------------------------------------------------------------------
        .dbyt   $9274                           ; 90E6 92 74    .t
; ----------------------------------------------------------------------------
        .byte   $01                             ; 90E8 01       .
; ----------------------------------------------------------------------------
        .byte   "DESTROY"                       ; 90E9 44 45 53 54 52 4F 59DESTROY
; ----------------------------------------------------------------------------
        .dbyt   $9283                           ; 90F0 92 83    ..
; ----------------------------------------------------------------------------
        .byte   $02                             ; 90F2 02       .
; ----------------------------------------------------------------------------
        .byte   "DIR"                           ; 90F3 44 49 52 DIR
; ----------------------------------------------------------------------------
        .dbyt   $9313                           ; 90F6 93 13    ..
; ----------------------------------------------------------------------------
        .byte   $09                             ; 90F8 09       .
; ----------------------------------------------------------------------------
        .byte   "DRIVE"                         ; 90F9 44 52 49 56 45DRIVE
; ----------------------------------------------------------------------------
        .dbyt   $930A                           ; 90FE 93 0A    ..
; ----------------------------------------------------------------------------
        .byte   $0A                             ; 9100 0A       .
; ----------------------------------------------------------------------------
        .byte   "ENABLE"                        ; 9101 45 4E 41 42 4C 45ENABLE
; ----------------------------------------------------------------------------
        .dbyt   $955C                           ; 9107 95 5C    .\
; ----------------------------------------------------------------------------
        .byte   $00                             ; 9109 00       .
; ----------------------------------------------------------------------------
        .byte   "FDCSTAT"                       ; 910A 46 44 43 53 54 41 54FDCSTAT
; ----------------------------------------------------------------------------
        .dbyt   $B766                           ; 9111 B7 66    .f
; ----------------------------------------------------------------------------
        .byte   $80                             ; 9113 80       .
; ----------------------------------------------------------------------------
        .byte   "INFO"                          ; 9114 49 4E 46 4FINFO
; ----------------------------------------------------------------------------
        .dbyt   $8C1C                           ; 9118 8C 1C    ..
; ----------------------------------------------------------------------------
        .byte   $02                             ; 911A 02       .
; ----------------------------------------------------------------------------
        .byte   "LIB"                           ; 911B 4C 49 42 LIB
; ----------------------------------------------------------------------------
        .dbyt   $9316                           ; 911E 93 16    ..
; ----------------------------------------------------------------------------
        .byte   $09                             ; 9120 09       .
; ----------------------------------------------------------------------------
        .byte   "MAP"                           ; 9121 4D 41 50 MAP
; ----------------------------------------------------------------------------
        .dbyt   $8B54                           ; 9124 8B 54    .T
; ----------------------------------------------------------------------------
        .byte   $0A                             ; 9126 0A       .
; ----------------------------------------------------------------------------
        .byte   "RENAME"                        ; 9127 52 45 4E 41 4D 45RENAME
; ----------------------------------------------------------------------------
        .dbyt   $95C6                           ; 912D 95 C6    ..
; ----------------------------------------------------------------------------
        .byte   $78                             ; 912F 78       x
; ----------------------------------------------------------------------------
        .byte   "STAT"                          ; 9130 53 54 41 54STAT
; ----------------------------------------------------------------------------
        .dbyt   $8D66                           ; 9134 8D 66    .f
; ----------------------------------------------------------------------------
        .byte   $0A                             ; 9136 0A       .
; ----------------------------------------------------------------------------
        .byte   "TITLE"                         ; 9137 54 49 54 4C 45TITLE
; ----------------------------------------------------------------------------
        .dbyt   $9339                           ; 913C 93 39    .9
; ----------------------------------------------------------------------------
        .byte   $0B                             ; 913E 0B       .
; ----------------------------------------------------------------------------
        .byte   "WIPE"                          ; 913F 57 49 50 45WIPE
; ----------------------------------------------------------------------------
        .dbyt   $923F                           ; 9143 92 3F    .?
; ----------------------------------------------------------------------------
        .byte   $02                             ; 9145 02       .
; ----------------------------------------------------------------------------
        tya                                     ; 9146 98       .
        .byte   $23                             ; 9147 23       #
        .byte   "BUILD"                         ; 9148 42 55 49 4C 44BUILD
; ----------------------------------------------------------------------------
        .dbyt   $8415                           ; 914D 84 15    ..
; ----------------------------------------------------------------------------
        .byte   $01                             ; 914F 01       .
; ----------------------------------------------------------------------------
        .byte   "DISC"                          ; 9150 44 49 53 43DISC
; ----------------------------------------------------------------------------
        .dbyt   $820E                           ; 9154 82 0E    ..
; ----------------------------------------------------------------------------
        .byte   $00                             ; 9156 00       .
; ----------------------------------------------------------------------------
        .byte   "DUMP"                          ; 9157 44 55 4D 50DUMP
; ----------------------------------------------------------------------------
        .dbyt   $83A4                           ; 915B 83 A4    ..
; ----------------------------------------------------------------------------
        .byte   $01                             ; 915D 01       .
; ----------------------------------------------------------------------------
        .byte   "FORMAT"                        ; 915E 46 4F 52 4D 41 54FORMAT
; ----------------------------------------------------------------------------
        .dbyt   $AE88                           ; 9164 AE 88    ..
; ----------------------------------------------------------------------------
        .byte   $8A                             ; 9166 8A       .
; ----------------------------------------------------------------------------
        .byte   "LIST"                          ; 9167 4C 49 53 54LIST
; ----------------------------------------------------------------------------
        .dbyt   $8362                           ; 916B 83 62    .b
; ----------------------------------------------------------------------------
        .byte   $01                             ; 916D 01       .
; ----------------------------------------------------------------------------
        .byte   "TYPE"                          ; 916E 54 59 50 45TYPE
; ----------------------------------------------------------------------------
        .dbyt   $835B                           ; 9172 83 5B    .[
; ----------------------------------------------------------------------------
        .byte   $01                             ; 9174 01       .
; ----------------------------------------------------------------------------
        .byte   "VERIFY"                        ; 9175 56 45 52 49 46 59VERIFY
; ----------------------------------------------------------------------------
        .dbyt   $B07E                           ; 917B B0 7E    .~
; ----------------------------------------------------------------------------
        .byte   $8A                             ; 917D 8A       .
; ----------------------------------------------------------------------------
        .byte   "VOLGEN"                        ; 917E 56 4F 4C 47 45 4EVOLGEN
; ----------------------------------------------------------------------------
        .dbyt   $B140                           ; 9184 B1 40    .@
; ----------------------------------------------------------------------------
        .byte   $8A                             ; 9186 8A       .
; ----------------------------------------------------------------------------
        .byte   "DISK"                          ; 9187 44 49 53 4BDISK
; ----------------------------------------------------------------------------
        .dbyt   $820E                           ; 918B 82 0E    ..
; ----------------------------------------------------------------------------
        .byte   $00                             ; 918D 00       .
; ----------------------------------------------------------------------------
        sta     ($A7),y                         ; 918E 91 A7    ..
        .byte   "CHAL"                          ; 9190 43 48 41 4CCHAL
; ----------------------------------------------------------------------------
        .dbyt   $A52E                           ; 9194 A5 2E    ..
; ----------------------------------------------------------------------------
        .byte   $00                             ; 9196 00       .
; ----------------------------------------------------------------------------
        .byte   "DFS"                           ; 9197 44 46 53 DFS
; ----------------------------------------------------------------------------
        .dbyt   $A52E                           ; 919A A5 2E    ..
; ----------------------------------------------------------------------------
        .byte   $00                             ; 919C 00       .
; ----------------------------------------------------------------------------
        .byte   "UTILS"                         ; 919D 55 54 49 4C 53UTILS
; ----------------------------------------------------------------------------
        .dbyt   $A526                           ; 91A2 A5 26    .&
; ----------------------------------------------------------------------------
        .byte   $00                             ; 91A4 00       .
; ----------------------------------------------------------------------------
        sta     ($A7),y                         ; 91A5 91 A7    ..
        rts                                     ; 91A7 60       `

; ----------------------------------------------------------------------------
L91A8:  jsr     init_lda_abx_thunk              ; 91A8 20 1E 92  ..
        tay                                     ; 91AB A8       .
        jsr     gsinit_with_carry_clear         ; 91AC 20 F2 A9  ..
        tya                                     ; 91AF 98       .
        pha                                     ; 91B0 48       H
        lda     ($F2),y                         ; 91B1 B1 F2    ..
        and     #$5F                            ; 91B3 29 5F    )_
        cmp     #$43                            ; 91B5 C9 43    .C
        bne     L91C4                           ; 91B7 D0 0B    ..
        iny                                     ; 91B9 C8       .
        lda     ($F2),y                         ; 91BA B1 F2    ..
        cmp     #$20                            ; 91BC C9 20    . 
        bne     L91C4                           ; 91BE D0 04    ..
        pla                                     ; 91C0 68       h
        iny                                     ; 91C1 C8       .
        tya                                     ; 91C2 98       .
        pha                                     ; 91C3 48       H
L91C4:  pla                                     ; 91C4 68       h
        tay                                     ; 91C5 A8       .
        pha                                     ; 91C6 48       H
        ldx     #$00                            ; 91C7 A2 00    ..
        jsr     L00AA                           ; 91C9 20 AA 00  ..
        sec                                     ; 91CC 38       8
        bmi     L920A                           ; 91CD 30 3B    0;
        dex                                     ; 91CF CA       .
        dey                                     ; 91D0 88       .
L91D1:  inx                                     ; 91D1 E8       .
        iny                                     ; 91D2 C8       .
        jsr     L00AA                           ; 91D3 20 AA 00  ..
        bmi     L91FA                           ; 91D6 30 22    0"
        eor     ($F2),y                         ; 91D8 51 F2    Q.
        and     #$5F                            ; 91DA 29 5F    )_
        beq     L91D1                           ; 91DC F0 F3    ..
        lda     ($F2),y                         ; 91DE B1 F2    ..
        cmp     #$2E                            ; 91E0 C9 2E    ..
        php                                     ; 91E2 08       .
L91E3:  inx                                     ; 91E3 E8       .
        jsr     L00AA                           ; 91E4 20 AA 00  ..
        bpl     L91E3                           ; 91E7 10 FA    ..
        inx                                     ; 91E9 E8       .
        inx                                     ; 91EA E8       .
        plp                                     ; 91EB 28       (
        bne     L91F3                           ; 91EC D0 05    ..
        jsr     L00AA                           ; 91EE 20 AA 00  ..
        bpl     L9206                           ; 91F1 10 13    ..
L91F3:  inx                                     ; 91F3 E8       .
        jsr     L922D                           ; 91F4 20 2D 92  -.
        jmp     L91C4                           ; 91F7 4C C4 91 L..

; ----------------------------------------------------------------------------
L91FA:  lda     ($F2),y                         ; 91FA B1 F2    ..
        jsr     isalpha                         ; 91FC 20 D1 A9  ..
        bcs     L9209                           ; 91FF B0 08    ..
        inx                                     ; 9201 E8       .
        inx                                     ; 9202 E8       .
        jmp     L91F3                           ; 9203 4C F3 91 L..

; ----------------------------------------------------------------------------
L9206:  dex                                     ; 9206 CA       .
        dex                                     ; 9207 CA       .
        iny                                     ; 9208 C8       .
L9209:  clc                                     ; 9209 18       .
L920A:  pla                                     ; 920A 68       h
        jsr     L00AA                           ; 920B 20 AA 00  ..
        sta     $A9                             ; 920E 85 A9    ..
        inx                                     ; 9210 E8       .
        jsr     L00AA                           ; 9211 20 AA 00  ..
        sta     L00A8                           ; 9214 85 A8    ..
        inx                                     ; 9216 E8       .
        rts                                     ; 9217 60       `

; ----------------------------------------------------------------------------
; YX = addr - create little thunk at $AA that does STA addr,X - YX = addr
init_sta_abx_thunk:
        pha                                     ; 9218 48       H
        lda     #$9D                            ; 9219 A9 9D    ..
        jmp     L9221                           ; 921B 4C 21 92 L!.

; ----------------------------------------------------------------------------
; YX = addr - create little thunk at $AA that does LDA addr,X
init_lda_abx_thunk:
        pha                                     ; 921E 48       H
        lda     #$BD                            ; 921F A9 BD    ..
L9221:  sta     L00AA                           ; 9221 85 AA    ..
        stx     $AB                             ; 9223 86 AB    ..
        sty     $AC                             ; 9225 84 AC    ..
        lda     #$60                            ; 9227 A9 60    .`
        sta     $AD                             ; 9229 85 AD    ..
        pla                                     ; 922B 68       h
        rts                                     ; 922C 60       `

; ----------------------------------------------------------------------------
L922D:  clc                                     ; 922D 18       .
        txa                                     ; 922E 8A       .
        adc     $AB                             ; 922F 65 AB    e.
        sta     $AB                             ; 9231 85 AB    ..
        bcc     L9237                           ; 9233 90 02    ..
        inc     $AC                             ; 9235 E6 AC    ..
L9237:  rts                                     ; 9237 60       `

; ----------------------------------------------------------------------------
; ?&F2=X, ?&F3=Y, Y=0
set_f2_y:
        stx     $F2                             ; 9238 86 F2    ..
        sty     $F3                             ; 923A 84 F3    ..
        ldy     #$00                            ; 923C A0 00    ..
        rts                                     ; 923E 60       `

; ----------------------------------------------------------------------------
wipe_command:
        jsr     L92DD                           ; 923F 20 DD 92  ..
L9242:  jsr     L8AA3                           ; 9242 20 A3 8A  ..
        jsr     print_string_nterm              ; 9245 20 D3 A8  ..
        .byte   " : "                           ; 9248 20 3A 20  : 
; ----------------------------------------------------------------------------
        nop                                     ; 924B EA       .
        jsr     select_ram_page_002             ; 924C 20 11 BE  ..
        lda     $FD0F,y                         ; 924F B9 0F FD ...
        bpl     L925A                           ; 9252 10 06    ..
        jsr     print_N_without_spool           ; 9254 20 4B A9  K.
        jmp     L926B                           ; 9257 4C 6B 92 Lk.

; ----------------------------------------------------------------------------
L925A:  jsr     L84DE                           ; 925A 20 DE 84  ..
        bne     L926B                           ; 925D D0 0C    ..
        jsr     L8A7E                           ; 925F 20 7E 8A  ~.
        jsr     L8C78                           ; 9262 20 78 8C  x.
        jsr     L960B                           ; 9265 20 0B 96  ..
        jsr     L9300                           ; 9268 20 00 93  ..
L926B:  jsr     L8469                           ; 926B 20 69 84  i.
        jsr     L8C35                           ; 926E 20 35 8C  5.
        bcs     L9242                           ; 9271 B0 CF    ..
        rts                                     ; 9273 60       `

; ----------------------------------------------------------------------------
delete_command:
        jsr     L8B32                           ; 9274 20 32 8B  2.
        jsr     L92E0                           ; 9277 20 E0 92  ..
        jsr     L8C9D                           ; 927A 20 9D 8C  ..
        jsr     L8C78                           ; 927D 20 78 8C  x.
        jmp     L960B                           ; 9280 4C 0B 96 L..

; ----------------------------------------------------------------------------
destroy_command:
        jsr     LA75F                           ; 9283 20 5F A7  _.
        jsr     L92DD                           ; 9286 20 DD 92  ..
L9289:  jsr     L8AA3                           ; 9289 20 A3 8A  ..
        jsr     L8469                           ; 928C 20 69 84  i.
        jsr     L8C35                           ; 928F 20 35 8C  5.
        bcs     L9289                           ; 9292 B0 F5    ..
        jsr     print_string_nterm              ; 9294 20 D3 A8  ..
        .byte   $0D                             ; 9297 0D       .
        .byte   "Delete (Y/N) ? "               ; 9298 44 65 6C 65 74 65 20 28Delete (
                                                ; 92A0 59 2F 4E 29 20 3F 20Y/N) ? 
; ----------------------------------------------------------------------------
        nop                                     ; 92A7 EA       .
        jsr     L84DE                           ; 92A8 20 DE 84  ..
        beq     L92B0                           ; 92AB F0 03    ..
        jmp     L8469                           ; 92AD 4C 69 84 Li.

; ----------------------------------------------------------------------------
L92B0:  jsr     L8A7E                           ; 92B0 20 7E 8A  ~.
        jsr     L8C2E                           ; 92B3 20 2E 8C  ..
L92B6:  jsr     select_ram_page_002             ; 92B6 20 11 BE  ..
        lda     $FD0F,y                         ; 92B9 B9 0F FD ...
        and     #$7F                            ; 92BC 29 7F    ).
        sta     $FD0F,y                         ; 92BE 99 0F FD ...
        jsr     L8C78                           ; 92C1 20 78 8C  x.
        jsr     L9300                           ; 92C4 20 00 93  ..
        jsr     L8C35                           ; 92C7 20 35 8C  5.
        bcs     L92B6                           ; 92CA B0 EA    ..
        jsr     L960B                           ; 92CC 20 0B 96  ..
        jsr     print_string_nterm              ; 92CF 20 D3 A8  ..
        .byte   $0D                             ; 92D2 0D       .
        .byte   "Deleted"                       ; 92D3 44 65 6C 65 74 65 64Deleted
        .byte   $0D                             ; 92DA 0D       .
; ----------------------------------------------------------------------------
        nop                                     ; 92DB EA       .
        rts                                     ; 92DC 60       `

; ----------------------------------------------------------------------------
L92DD:  jsr     L8B2E                           ; 92DD 20 2E 8B  ..
L92E0:  jsr     LA565                           ; 92E0 20 65 A5  e.
        jmp     L8B38                           ; 92E3 4C 38 8B L8.

; ----------------------------------------------------------------------------
L92E6:  jsr     LA565                           ; 92E6 20 65 A5  e.
        jmp     L89DC                           ; 92E9 4C DC 89 L..

; ----------------------------------------------------------------------------
L92EC:  jsr     asl_x4                          ; 92EC 20 A4 A9  ..
        jsr     select_ram_page_003             ; 92EF 20 16 BE  ..
        eor     $FD0E,x                         ; 92F2 5D 0E FD ]..
        and     #$30                            ; 92F5 29 30    )0
        eor     $FD0E,x                         ; 92F7 5D 0E FD ]..
        sta     $FD0E,x                         ; 92FA 9D 0E FD ...
        jmp     select_ram_page_001             ; 92FD 4C 0C BE L..

; ----------------------------------------------------------------------------
L9300:  ldy     $FDC2                           ; 9300 AC C2 FD ...
        jsr     dey_x8                          ; 9303 20 B2 A9  ..
        sty     $FDC2                           ; 9306 8C C2 FD ...
        rts                                     ; 9309 60       `

; ----------------------------------------------------------------------------
drive_command:
        jsr     LAA16                           ; 930A 20 16 AA  ..
        lda     $CF                             ; 930D A5 CF    ..
        sta     $FDC7                           ; 930F 8D C7 FD ...
        rts                                     ; 9312 60       `

; ----------------------------------------------------------------------------
dir_command:
        ldx     #$00                            ; 9313 A2 00    ..
        .byte   $AD                             ; 9315 AD       .
lib_command:
        ldx     #$02                            ; 9316 A2 02    ..
        lda     $FDC6,x                         ; 9318 BD C6 FD ...
        sta     $CE                             ; 931B 85 CE    ..
        lda     $FDC7,x                         ; 931D BD C7 FD ...
        sta     $CF                             ; 9320 85 CF    ..
        txa                                     ; 9322 8A       .
        pha                                     ; 9323 48       H
        jsr     gsinit_with_carry_clear         ; 9324 20 F2 A9  ..
        beq     L932C                           ; 9327 F0 03    ..
        jsr     LAA3E                           ; 9329 20 3E AA  >.
L932C:  pla                                     ; 932C 68       h
        tax                                     ; 932D AA       .
        lda     $CE                             ; 932E A5 CE    ..
        sta     $FDC6,x                         ; 9330 9D C6 FD ...
        lda     $CF                             ; 9333 A5 CF    ..
        sta     $FDC7,x                         ; 9335 9D C7 FD ...
        rts                                     ; 9338 60       `

; ----------------------------------------------------------------------------
title_command:
        jsr     LA565                           ; 9339 20 65 A5  e.
        jsr     LAA1E                           ; 933C 20 1E AA  ..
        jsr     L962F                           ; 933F 20 2F 96  /.
        ldx     #$0B                            ; 9342 A2 0B    ..
        lda     #$00                            ; 9344 A9 00    ..
L9346:  jsr     L935C                           ; 9346 20 5C 93  \.
        dex                                     ; 9349 CA       .
        bpl     L9346                           ; 934A 10 FA    ..
L934C:  jsr     gsread                          ; 934C 20 C5 FF  ..
        bcs     L9359                           ; 934F B0 08    ..
        inx                                     ; 9351 E8       .
        jsr     L935C                           ; 9352 20 5C 93  \.
        cpx     #$0B                            ; 9355 E0 0B    ..
        bne     L934C                           ; 9357 D0 F3    ..
L9359:  jmp     L960B                           ; 9359 4C 0B 96 L..

; ----------------------------------------------------------------------------
L935C:  cpx     #$08                            ; 935C E0 08    ..
        bcc     L9367                           ; 935E 90 07    ..
        jsr     select_ram_page_003             ; 9360 20 16 BE  ..
        sta     fdc_status_or_cmd,x             ; 9363 9D F8 FC ...
        rts                                     ; 9366 60       `

; ----------------------------------------------------------------------------
L9367:  jsr     select_ram_page_002             ; 9367 20 11 BE  ..
        sta     $FD00,x                         ; 936A 9D 00 FD ...
        rts                                     ; 936D 60       `

; ----------------------------------------------------------------------------
access_command:
        jsr     L8B2E                           ; 936E 20 2E 8B  ..
        jsr     L92E6                           ; 9371 20 E6 92  ..
        ldx     #$00                            ; 9374 A2 00    ..
        jsr     gsinit_with_carry_clear         ; 9376 20 F2 A9  ..
        bne     L939C                           ; 9379 D0 21    .!
L937B:  stx     L00AA                           ; 937B 86 AA    ..
        jsr     L8B41                           ; 937D 20 41 8B  A.
L9380:  jsr     LA2AB                           ; 9380 20 AB A2  ..
        jsr     select_ram_page_002             ; 9383 20 11 BE  ..
        lda     $FD0F,y                         ; 9386 B9 0F FD ...
        and     #$7F                            ; 9389 29 7F    ).
        ora     L00AA                           ; 938B 05 AA    ..
        sta     $FD0F,y                         ; 938D 99 0F FD ...
        jsr     L8C9D                           ; 9390 20 9D 8C  ..
        jsr     L8C35                           ; 9393 20 35 8C  5.
        bcs     L9380                           ; 9396 B0 E8    ..
        bcc     L9359                           ; 9398 90 BF    ..
L939A:  ldx     #$80                            ; 939A A2 80    ..
L939C:  jsr     gsread                          ; 939C 20 C5 FF  ..
        bcs     L937B                           ; 939F B0 DA    ..
        cmp     #$4C                            ; 93A1 C9 4C    .L
        beq     L939A                           ; 93A3 F0 F5    ..
        jsr     dobrk_with_Bad_prefix           ; 93A5 20 9C A8  ..
        .byte   $CF                             ; 93A8 CF       .
        .byte   "attribute"                     ; 93A9 61 74 74 72 69 62 75 74attribut
                                                ; 93B1 65       e
; ----------------------------------------------------------------------------
        brk                                     ; 93B2 00       .
L93B3:  jsr     L89E2                           ; 93B3 20 E2 89  ..
        jsr     L8C2E                           ; 93B6 20 2E 8C  ..
        bcc     L93BE                           ; 93B9 90 03    ..
        jsr     L8C78                           ; 93BB 20 78 8C  x.
L93BE:  lda     $C2                             ; 93BE A5 C2    ..
        pha                                     ; 93C0 48       H
        lda     $C3                             ; 93C1 A5 C3    ..
        pha                                     ; 93C3 48       H
        sec                                     ; 93C4 38       8
        lda     $C4                             ; 93C5 A5 C4    ..
        sbc     $C2                             ; 93C7 E5 C2    ..
        sta     $C2                             ; 93C9 85 C2    ..
        lda     $C5                             ; 93CB A5 C5    ..
        sbc     $C3                             ; 93CD E5 C3    ..
        sta     $C3                             ; 93CF 85 C3    ..
        lda     $FDBB                           ; 93D1 AD BB FD ...
        sbc     $FDB9                           ; 93D4 ED B9 FD ...
        sta     $C6                             ; 93D7 85 C6    ..
        jsr     L940B                           ; 93D9 20 0B 94  ..
        lda     $FDBA                           ; 93DC AD BA FD ...
        sta     $FDB6                           ; 93DF 8D B6 FD ...
        lda     $FDB9                           ; 93E2 AD B9 FD ...
        sta     $FDB5                           ; 93E5 8D B5 FD ...
        pla                                     ; 93E8 68       h
        sta     $BF                             ; 93E9 85 BF    ..
        pla                                     ; 93EB 68       h
        sta     $BE                             ; 93EC 85 BE    ..
        rts                                     ; 93EE 60       `

; ----------------------------------------------------------------------------
L93EF:  jsr     dobrk_with_Disk_prefix          ; 93EF 20 92 A8  ..
        .byte   $C6                             ; 93F2 C6       .
        .byte   "full"                          ; 93F3 66 75 6C 6Cfull
; ----------------------------------------------------------------------------
        brk                                     ; 93F7 00       .
L93F8:  jsr     print_string_2_nterm            ; 93F8 20 AD A8  ..
        .byte   $BE                             ; 93FB BE       .
        .byte   "Catalogue full"                ; 93FC 43 61 74 61 6C 6F 67 75Catalogu
                                                ; 9404 65 20 66 75 6C 6Ce full
; ----------------------------------------------------------------------------
        brk                                     ; 940A 00       .
L940B:  lda     #$00                            ; 940B A9 00    ..
        sta     $C4                             ; 940D 85 C4    ..
        jsr     LA4F8                           ; 940F 20 F8 A4  ..
        sta     $C5                             ; 9412 85 C5    ..
        jsr     select_ram_page_003             ; 9414 20 16 BE  ..
        ldy     $FD05                           ; 9417 AC 05 FD ...
        cpy     #$F8                            ; 941A C0 F8    ..
        bcs     L93F8                           ; 941C B0 DA    ..
        bcc     L947F                           ; 941E 90 5F    ._
L9420:  bit     L00A8                           ; 9420 24 A8    $.
        bvc     L93EF                           ; 9422 50 CB    P.
        lda     #$00                            ; 9424 A9 00    ..
        sta     $C3                             ; 9426 85 C3    ..
        sta     $C6                             ; 9428 85 C6    ..
        sta     $C4                             ; 942A 85 C4    ..
        jsr     LA4F8                           ; 942C 20 F8 A4  ..
        sta     $C5                             ; 942F 85 C5    ..
        jsr     select_ram_page_003             ; 9431 20 16 BE  ..
        ldy     $FD05                           ; 9434 AC 05 FD ...
        jmp     L9443                           ; 9437 4C 43 94 LC.

; ----------------------------------------------------------------------------
L943A:  tya                                     ; 943A 98       .
        beq     L9460                           ; 943B F0 23    .#
        jsr     dey_x8                          ; 943D 20 B2 A9  ..
        jsr     L94D6                           ; 9440 20 D6 94  ..
L9443:  jsr     L9507                           ; 9443 20 07 95  ..
        beq     L943A                           ; 9446 F0 F2    ..
        sec                                     ; 9448 38       8
        jsr     L9521                           ; 9449 20 21 95  !.
        bcc     L943A                           ; 944C 90 EC    ..
        stx     $C6                             ; 944E 86 C6    ..
        lda     $B0                             ; 9450 A5 B0    ..
        sta     $C3                             ; 9452 85 C3    ..
        lda     $C4                             ; 9454 A5 C4    ..
        sta     $B1                             ; 9456 85 B1    ..
        lda     $C5                             ; 9458 A5 C5    ..
        sta     $B2                             ; 945A 85 B2    ..
        sty     $C2                             ; 945C 84 C2    ..
        bcs     L943A                           ; 945E B0 DA    ..
L9460:  lda     $C3                             ; 9460 A5 C3    ..
        ora     $C6                             ; 9462 05 C6    ..
        beq     L93EF                           ; 9464 F0 89    ..
        lda     $B1                             ; 9466 A5 B1    ..
        sta     $C4                             ; 9468 85 C4    ..
        lda     $B2                             ; 946A A5 B2    ..
        sta     $C5                             ; 946C 85 C5    ..
        ldy     $C2                             ; 946E A4 C2    ..
        lda     #$00                            ; 9470 A9 00    ..
        sta     $C2                             ; 9472 85 C2    ..
        beq     L9489                           ; 9474 F0 13    ..
L9476:  tya                                     ; 9476 98       .
        beq     L9420                           ; 9477 F0 A7    ..
        jsr     dey_x8                          ; 9479 20 B2 A9  ..
        jsr     L94D6                           ; 947C 20 D6 94  ..
L947F:  jsr     L9507                           ; 947F 20 07 95  ..
        beq     L9476                           ; 9482 F0 F2    ..
        jsr     L951D                           ; 9484 20 1D 95  ..
        bcc     L9476                           ; 9487 90 ED    ..
L9489:  sty     $B0                             ; 9489 84 B0    ..
        jsr     select_ram_page_003             ; 948B 20 16 BE  ..
        ldy     $FD05                           ; 948E AC 05 FD ...
L9491:  cpy     $B0                             ; 9491 C4 B0    ..
        beq     L94AA                           ; 9493 F0 15    ..
        jsr     select_ram_page_002             ; 9495 20 11 BE  ..
        lda     $FD07,y                         ; 9498 B9 07 FD ...
        sta     $FD0F,y                         ; 949B 99 0F FD ...
        jsr     select_ram_page_003             ; 949E 20 16 BE  ..
        lda     $FD07,y                         ; 94A1 B9 07 FD ...
        sta     $FD0F,y                         ; 94A4 99 0F FD ...
        dey                                     ; 94A7 88       .
        bcs     L9491                           ; 94A8 B0 E7    ..
L94AA:  jsr     select_ram_page_001             ; 94AA 20 0C BE  ..
        jsr     L953A                           ; 94AD 20 3A 95  :.
        jsr     L9529                           ; 94B0 20 29 95  ).
        jsr     select_ram_page_003             ; 94B3 20 16 BE  ..
L94B6:  lda     $BD,x                           ; 94B6 B5 BD    ..
        dey                                     ; 94B8 88       .
        sta     $FD08,y                         ; 94B9 99 08 FD ...
        dex                                     ; 94BC CA       .
        bne     L94B6                           ; 94BD D0 F7    ..
        jsr     L8C9D                           ; 94BF 20 9D 8C  ..
        tya                                     ; 94C2 98       .
        pha                                     ; 94C3 48       H
        jsr     select_ram_page_003             ; 94C4 20 16 BE  ..
        ldy     $FD05                           ; 94C7 AC 05 FD ...
        jsr     iny_x8                          ; 94CA 20 A9 A9  ..
        sty     $FD05                           ; 94CD 8C 05 FD ...
        jsr     L960B                           ; 94D0 20 0B 96  ..
        pla                                     ; 94D3 68       h
        tay                                     ; 94D4 A8       .
        rts                                     ; 94D5 60       `

; ----------------------------------------------------------------------------
L94D6:  jsr     L94EB                           ; 94D6 20 EB 94  ..
        clc                                     ; 94D9 18       .
        lda     $FD0F,y                         ; 94DA B9 0F FD ...
        adc     $C5                             ; 94DD 65 C5    e.
        sta     $C5                             ; 94DF 85 C5    ..
        lda     $FD0E,y                         ; 94E1 B9 0E FD ...
        and     #$03                            ; 94E4 29 03    ).
        adc     $C4                             ; 94E6 65 C4    e.
        sta     $C4                             ; 94E8 85 C4    ..
        rts                                     ; 94EA 60       `

; ----------------------------------------------------------------------------
L94EB:  jsr     select_ram_page_003             ; 94EB 20 16 BE  ..
        lda     $FD0C,y                         ; 94EE B9 0C FD ...
        cmp     #$01                            ; 94F1 C9 01    ..
        lda     $FD0D,y                         ; 94F3 B9 0D FD ...
        adc     #$00                            ; 94F6 69 00    i.
        sta     $C5                             ; 94F8 85 C5    ..
        php                                     ; 94FA 08       .
        lda     $FD0E,y                         ; 94FB B9 0E FD ...
        jsr     extract_00xx0000                ; 94FE 20 96 A9  ..
        plp                                     ; 9501 28       (
        adc     #$00                            ; 9502 69 00    i.
        sta     $C4                             ; 9504 85 C4    ..
        rts                                     ; 9506 60       `

; ----------------------------------------------------------------------------
L9507:  jsr     select_ram_page_003             ; 9507 20 16 BE  ..
        sec                                     ; 950A 38       8
        lda     $FD07,y                         ; 950B B9 07 FD ...
        sbc     $C5                             ; 950E E5 C5    ..
        sta     $B0                             ; 9510 85 B0    ..
        lda     $FD06,y                         ; 9512 B9 06 FD ...
        and     #$03                            ; 9515 29 03    ).
        sbc     $C4                             ; 9517 E5 C4    ..
        tax                                     ; 9519 AA       .
        ora     $B0                             ; 951A 05 B0    ..
        rts                                     ; 951C 60       `

; ----------------------------------------------------------------------------
L951D:  lda     #$00                            ; 951D A9 00    ..
        cmp     $C2                             ; 951F C5 C2    ..
L9521:  lda     $B0                             ; 9521 A5 B0    ..
        sbc     $C3                             ; 9523 E5 C3    ..
        txa                                     ; 9525 8A       .
        sbc     $C6                             ; 9526 E5 C6    ..
        rts                                     ; 9528 60       `

; ----------------------------------------------------------------------------
L9529:  jsr     select_ram_page_002             ; 9529 20 11 BE  ..
        ldx     #$00                            ; 952C A2 00    ..
L952E:  lda     $C7,x                           ; 952E B5 C7    ..
        sta     $FD08,y                         ; 9530 99 08 FD ...
        iny                                     ; 9533 C8       .
        inx                                     ; 9534 E8       .
        cpx     #$08                            ; 9535 E0 08    ..
        bne     L952E                           ; 9537 D0 F5    ..
        rts                                     ; 9539 60       `

; ----------------------------------------------------------------------------
L953A:  lda     $FDB7                           ; 953A AD B7 FD ...
        and     #$03                            ; 953D 29 03    ).
        asl     a                               ; 953F 0A       .
        asl     a                               ; 9540 0A       .
        eor     $C6                             ; 9541 45 C6    E.
        and     #$FC                            ; 9543 29 FC    ).
        eor     $C6                             ; 9545 45 C6    E.
        asl     a                               ; 9547 0A       .
        asl     a                               ; 9548 0A       .
        eor     $FDB5                           ; 9549 4D B5 FD M..
        and     #$FC                            ; 954C 29 FC    ).
        eor     $FDB5                           ; 954E 4D B5 FD M..
        asl     a                               ; 9551 0A       .
        asl     a                               ; 9552 0A       .
        eor     $C4                             ; 9553 45 C4    E.
        and     #$FC                            ; 9555 29 FC    ).
        eor     $C4                             ; 9557 45 C4    E.
        sta     $C4                             ; 9559 85 C4    ..
        rts                                     ; 955B 60       `

; ----------------------------------------------------------------------------
enable_command:
        jsr     gsinit_with_carry_clear         ; 955C 20 F2 A9  ..
        beq     L957D                           ; 955F F0 1C    ..
        ldx     #$00                            ; 9561 A2 00    ..
L9563:  jsr     gsread                          ; 9563 20 C5 FF  ..
        bcs     L9587                           ; 9566 B0 1F    ..
        cmp     L958A,x                         ; 9568 DD 8A 95 ...
        bne     L9587                           ; 956B D0 1A    ..
        inx                                     ; 956D E8       .
        cpx     #$03                            ; 956E E0 03    ..
        bne     L9563                           ; 9570 D0 F1    ..
        jsr     gsread                          ; 9572 20 C5 FF  ..
        bcc     L9587                           ; 9575 90 10    ..
        lda     #$80                            ; 9577 A9 80    ..
        sta     $FDF4                           ; 9579 8D F4 FD ...
        rts                                     ; 957C 60       `

; ----------------------------------------------------------------------------
L957D:  lda     #$80                            ; 957D A9 80    ..
        sta     $B9                             ; 957F 85 B9    ..
        lda     #$01                            ; 9581 A9 01    ..
        sta     $FDDF                           ; 9583 8D DF FD ...
        rts                                     ; 9586 60       `

; ----------------------------------------------------------------------------
L9587:  jmp     L9849                           ; 9587 4C 49 98 LI.

; ----------------------------------------------------------------------------
L958A:  .byte   $43                             ; 958A 43       C
        eor     ($54,x)                         ; 958B 41 54    AT
L958D:  pha                                     ; 958D 48       H
        lda     #$00                            ; 958E A9 00    ..
        pha                                     ; 9590 48       H
        lda     $C4                             ; 9591 A5 C4    ..
        jsr     extract_0000xx00                ; 9593 20 98 A9  ..
        cmp     #$03                            ; 9596 C9 03    ..
        bne     L95A0                           ; 9598 D0 06    ..
        pla                                     ; 959A 68       h
        pla                                     ; 959B 68       h
L959C:  pha                                     ; 959C 48       H
        lda     #$FF                            ; 959D A9 FF    ..
        pha                                     ; 959F 48       H
L95A0:  jsr     select_ram_page_001             ; 95A0 20 0C BE  ..
        sta     $FDB5                           ; 95A3 8D B5 FD ...
        pla                                     ; 95A6 68       h
        sta     $FDB6                           ; 95A7 8D B6 FD ...
        pla                                     ; 95AA 68       h
        rts                                     ; 95AB 60       `

; ----------------------------------------------------------------------------
L95AC:  jsr     select_ram_page_001             ; 95AC 20 0C BE  ..
        lda     #$00                            ; 95AF A9 00    ..
        sta     $FDB8                           ; 95B1 8D B8 FD ...
        lda     $C4                             ; 95B4 A5 C4    ..
        jsr     extract_xx000000                ; 95B6 20 94 A9  ..
        cmp     #$03                            ; 95B9 C9 03    ..
        bne     L95C2                           ; 95BB D0 05    ..
        lda     #$FF                            ; 95BD A9 FF    ..
        sta     $FDB8                           ; 95BF 8D B8 FD ...
L95C2:  sta     $FDB7                           ; 95C2 8D B7 FD ...
        rts                                     ; 95C5 60       `

; ----------------------------------------------------------------------------
rename_command:
        jsr     L8B32                           ; 95C6 20 32 8B  2.
        jsr     L92E6                           ; 95C9 20 E6 92  ..
        jsr     LAAD9                           ; 95CC 20 D9 AA  ..
        pha                                     ; 95CF 48       H
        tya                                     ; 95D0 98       .
        pha                                     ; 95D1 48       H
        jsr     L8B41                           ; 95D2 20 41 8B  A.
        jsr     LA2A8                           ; 95D5 20 A8 A2  ..
        sty     $B3                             ; 95D8 84 B3    ..
        pla                                     ; 95DA 68       h
        tay                                     ; 95DB A8       .
        jsr     LA565                           ; 95DC 20 65 A5  e.
        lda     $FDC6                           ; 95DF AD C6 FD ...
        sta     $CE                             ; 95E2 85 CE    ..
        jsr     L89F2                           ; 95E4 20 F2 89  ..
        pla                                     ; 95E7 68       h
        sta     $FDC0                           ; 95E8 8D C0 FD ...
        jsr     LAAD9                           ; 95EB 20 D9 AA  ..
        cmp     $FDC0                           ; 95EE CD C0 FD ...
        beq     L95F6                           ; 95F1 F0 03    ..
        jmp     L9849                           ; 95F3 4C 49 98 LI.

; ----------------------------------------------------------------------------
L95F6:  jsr     L8C2E                           ; 95F6 20 2E 8C  ..
        bcc     L9606                           ; 95F9 90 0B    ..
        jsr     dobrk_with_File_prefix          ; 95FB 20 A5 A8  ..
        .byte   $C4                             ; 95FE C4       .
        .byte   "exists"                        ; 95FF 65 78 69 73 74 73exists
; ----------------------------------------------------------------------------
        brk                                     ; 9605 00       .
L9606:  ldy     $B3                             ; 9606 A4 B3    ..
        jsr     L9529                           ; 9608 20 29 95  ).
L960B:  jsr     select_ram_page_003             ; 960B 20 16 BE  ..
        clc                                     ; 960E 18       .
        sed                                     ; 960F F8       .
        lda     $FD04                           ; 9610 AD 04 FD ...
        adc     #$01                            ; 9613 69 01    i.
        sta     $FD04                           ; 9615 8D 04 FD ...
        cld                                     ; 9618 D8       .
        jsr     L9743                           ; 9619 20 43 97  C.
        jmp     L9635                           ; 961C 4C 35 96 L5.

; ----------------------------------------------------------------------------
L961F:  jsr     select_ram_page_001             ; 961F 20 0C BE  ..
        jsr     LAAD9                           ; 9622 20 D9 AA  ..
        cmp     $FDDC                           ; 9625 CD DC FD ...
        bne     L962F                           ; 9628 D0 05    ..
        jsr     LBD06                           ; 962A 20 06 BD  ..
        beq     L9657                           ; 962D F0 28    .(
L962F:  jsr     push_registers_and_tuck_restoration_thunk; 962F 20 4C A8 L.
L9632:  jsr     L973A                           ; 9632 20 3A 97  :.
L9635:  lda     #$00                            ; 9635 A9 00    ..
        sta     $FDCC                           ; 9637 8D CC FD ...
        lda     #$80                            ; 963A A9 80    ..
        sta     $B9                             ; 963C 85 B9    ..
        lda     $FDE9                           ; 963E AD E9 FD ...
        ora     #$80                            ; 9641 09 80    ..
        sta     $FDE9                           ; 9643 8D E9 FD ...
        jsr     LABB5                           ; 9646 20 B5 AB  ..
        jsr     LAAD9                           ; 9649 20 D9 AA  ..
        sta     $FDDC                           ; 964C 8D DC FD ...
        jsr     L968B                           ; 964F 20 8B 96  ..
        beq     L9657                           ; 9652 F0 03    ..
        jmp     LBCAF                           ; 9654 4C AF BC L..

; ----------------------------------------------------------------------------
L9657:  jsr     select_ram_page_001             ; 9657 20 0C BE  ..
        bit     $FDF4                           ; 965A 2C F4 FD ,..
        bpl     L9679                           ; 965D 10 1A    ..
        jsr     select_ram_page_002             ; 965F 20 11 BE  ..
        ldx     #$00                            ; 9662 A2 00    ..
L9664:  lda     $FD00,x                         ; 9664 BD 00 FD ...
        sta     $0E00,x                         ; 9667 9D 00 0E ...
        inx                                     ; 966A E8       .
        bne     L9664                           ; 966B D0 F7    ..
        jsr     select_ram_page_003             ; 966D 20 16 BE  ..
L9670:  lda     $FD00,x                         ; 9670 BD 00 FD ...
        sta     $0F00,x                         ; 9673 9D 00 0F ...
        inx                                     ; 9676 E8       .
        bne     L9670                           ; 9677 D0 F7    ..
L9679:  jsr     select_ram_page_001             ; 9679 20 0C BE  ..
        jmp     LAD71                           ; 967C 4C 71 AD Lq.

; ----------------------------------------------------------------------------
        lda     #$80                            ; 967F A9 80    ..
        bne     L9685                           ; 9681 D0 02    ..
L9683:  lda     #$81                            ; 9683 A9 81    ..
L9685:  jsr     select_ram_page_001             ; 9685 20 0C BE  ..
        sta     $FDE9                           ; 9688 8D E9 FD ...
L968B:  jsr     LA875                           ; 968B 20 75 A8  u.
        jsr     L96A5                           ; 968E 20 A5 96  ..
        ldx     #$03                            ; 9691 A2 03    ..
L9693:  lda     #$00                            ; 9693 A9 00    ..
        sta     $A0                             ; 9695 85 A0    ..
        lda     #$02                            ; 9697 A9 02    ..
        sta     $A1                             ; 9699 85 A1    ..
        jsr     LBA18                           ; 969B 20 18 BA  ..
        beq     L96A4                           ; 969E F0 04    ..
        dex                                     ; 96A0 CA       .
        bne     L9693                           ; 96A1 D0 F0    ..
        dex                                     ; 96A3 CA       .
L96A4:  rts                                     ; 96A4 60       `

; ----------------------------------------------------------------------------
L96A5:  lda     #$02                            ; 96A5 A9 02    ..
        sta     $A6                             ; 96A7 85 A6    ..
        lda     #$00                            ; 96A9 A9 00    ..
        sta     $A7                             ; 96AB 85 A7    ..
        rts                                     ; 96AD 60       `

; ----------------------------------------------------------------------------
L96AE:  jsr     select_ram_page_001             ; 96AE 20 0C BE  ..
        pha                                     ; 96B1 48       H
        lda     $BE                             ; 96B2 A5 BE    ..
        sta     $FDB3                           ; 96B4 8D B3 FD ...
        lda     $BF                             ; 96B7 A5 BF    ..
        sta     $FDB4                           ; 96B9 8D B4 FD ...
        lda     $FDB5                           ; 96BC AD B5 FD ...
        and     $FDB6                           ; 96BF 2D B6 FD -..
        ora     $FDCD                           ; 96C2 0D CD FD ...
        eor     #$FF                            ; 96C5 49 FF    I.
        sta     $FDCC                           ; 96C7 8D CC FD ...
        sec                                     ; 96CA 38       8
        beq     L96DA                           ; 96CB F0 0D    ..
        jsr     L96DC                           ; 96CD 20 DC 96  ..
        ldx     #$B3                            ; 96D0 A2 B3    ..
        ldy     #$FD                            ; 96D2 A0 FD    ..
        pla                                     ; 96D4 68       h
        pha                                     ; 96D5 48       H
        jsr     L0406                           ; 96D6 20 06 04  ..
        clc                                     ; 96D9 18       .
L96DA:  pla                                     ; 96DA 68       h
        rts                                     ; 96DB 60       `

; ----------------------------------------------------------------------------
L96DC:  pha                                     ; 96DC 48       H
L96DD:  lda     #$C1                            ; 96DD A9 C1    ..
        jsr     L0406                           ; 96DF 20 06 04  ..
        bcc     L96DD                           ; 96E2 90 F9    ..
        pla                                     ; 96E4 68       h
        rts                                     ; 96E5 60       `

; ----------------------------------------------------------------------------
L96E6:  pha                                     ; 96E6 48       H
        lda     $FDCC                           ; 96E7 AD CC FD ...
        beq     L96F1                           ; 96EA F0 05    ..
L96EC:  lda     #$81                            ; 96EC A9 81    ..
        jsr     L0406                           ; 96EE 20 06 04  ..
L96F1:  pla                                     ; 96F1 68       h
        rts                                     ; 96F2 60       `

; ----------------------------------------------------------------------------
L96F3:  pha                                     ; 96F3 48       H
        lda     #$EA                            ; 96F4 A9 EA    ..
        jsr     osbyte_x00_yff                  ; 96F6 20 F2 AD  ..
        txa                                     ; 96F9 8A       .
        bne     L96EC                           ; 96FA D0 F0    ..
        pla                                     ; 96FC 68       h
        rts                                     ; 96FD 60       `

; ----------------------------------------------------------------------------
L96FE:  jsr     L973E                           ; 96FE 20 3E 97  >.
        jmp     L9707                           ; 9701 4C 07 97 L..

; ----------------------------------------------------------------------------
L9704:  jsr     L9735                           ; 9704 20 35 97  5.
L9707:  jsr     L8AED                           ; 9707 20 ED 8A  ..
        jmp     L9719                           ; 970A 4C 19 97 L..

; ----------------------------------------------------------------------------
L970D:  jsr     L9735                           ; 970D 20 35 97  5.
        jmp     L9716                           ; 9710 4C 16 97 L..

; ----------------------------------------------------------------------------
L9713:  jsr     L973E                           ; 9713 20 3E 97  >.
L9716:  jsr     L8AE4                           ; 9716 20 E4 8A  ..
L9719:  lda     #$01                            ; 9719 A9 01    ..
        jsr     LACE4                           ; 971B 20 E4 AC  ..
        jmp     L96E6                           ; 971E 4C E6 96 L..

; ----------------------------------------------------------------------------
L9721:  lda     #$81                            ; 9721 A9 81    ..
        .byte   $AE                             ; 9723 AE       .
L9724:  lda     #$80                            ; 9724 A9 80    ..
        sta     $FDE9                           ; 9726 8D E9 FD ...
        jsr     LAD88                           ; 9729 20 88 AD  ..
        jsr     L8AED                           ; 972C 20 ED 8A  ..
        jsr     LACE4                           ; 972F 20 E4 AC  ..
        jmp     L96E6                           ; 9732 4C E6 96 L..

; ----------------------------------------------------------------------------
L9735:  lda     #$01                            ; 9735 A9 01    ..
        jsr     L96AE                           ; 9737 20 AE 96  ..
L973A:  lda     #$00                            ; 973A A9 00    ..
        beq     L974A                           ; 973C F0 0C    ..
L973E:  lda     #$00                            ; 973E A9 00    ..
        jsr     L96AE                           ; 9740 20 AE 96  ..
L9743:  jsr     LADBC                           ; 9743 20 BC AD  ..
        bne     L975C                           ; 9746 D0 14    ..
        lda     #$01                            ; 9748 A9 01    ..
L974A:  jsr     select_ram_page_001             ; 974A 20 0C BE  ..
        sta     $FDE9                           ; 974D 8D E9 FD ...
        jsr     LAD88                           ; 9750 20 88 AD  ..
L9753:  jsr     select_ram_page_001             ; 9753 20 0C BE  ..
        lda     #$FF                            ; 9756 A9 FF    ..
        sta     $FDDC                           ; 9758 8D DC FD ...
        rts                                     ; 975B 60       `

; ----------------------------------------------------------------------------
L975C:  jmp     LA884                           ; 975C 4C 84 A8 L..

; ----------------------------------------------------------------------------
chosfsc:jsr     select_ram_page_001             ; 975F 20 0C BE  ..
        cmp     #$0C                            ; 9762 C9 0C    ..
        bcs     L9774                           ; 9764 B0 0E    ..
        stx     $B5                             ; 9766 86 B5    ..
        tax                                     ; 9768 AA       .
        lda     osfsc_routines_msbs,x           ; 9769 BD 21 AE .!.
        pha                                     ; 976C 48       H
        lda     osfsc_routines_lsbs,x           ; 976D BD 15 AE ...
        pha                                     ; 9770 48       H
        txa                                     ; 9771 8A       .
        ldx     $B5                             ; 9772 A6 B5    ..
L9774:  rts                                     ; 9774 60       `

; ----------------------------------------------------------------------------
osfsc_opt:
        jsr     push_registers_and_tuck_restoration_thunk; 9775 20 4C A8 L.
        cpx     #$0A                            ; 9778 E0 0A    ..
        bcs     osfsc_opt_2_or_3_or_5           ; 977A B0 0C    ..
        txa                                     ; 977C 8A       .
        asl     a                               ; 977D 0A       .
        tax                                     ; 977E AA       .
        lda     osfsc_opt_routines+1,x          ; 977F BD F5 97 ...
        pha                                     ; 9782 48       H
        lda     osfsc_opt_routines,x            ; 9783 BD F4 97 ...
        pha                                     ; 9786 48       H
        rts                                     ; 9787 60       `

; ----------------------------------------------------------------------------
osfsc_opt_2_or_3_or_5:
        jsr     dobrk_with_Bad_prefix           ; 9788 20 9C A8  ..
        .byte   $CB                             ; 978B CB       .
        .byte   "option"                        ; 978C 6F 70 74 69 6F 6Eoption
; ----------------------------------------------------------------------------
        brk                                     ; 9792 00       .
osfsc_opt_0_or_1:
        ldx     #$FF                            ; 9793 A2 FF    ..
        tya                                     ; 9795 98       .
        beq     L9799                           ; 9796 F0 01    ..
        inx                                     ; 9798 E8       .
L9799:  stx     $FDD9                           ; 9799 8E D9 FD ...
        rts                                     ; 979C 60       `

; ----------------------------------------------------------------------------
osfsc_opt_4:
        tya                                     ; 979D 98       .
        pha                                     ; 979E 48       H
        jsr     LAA1E                           ; 979F 20 1E AA  ..
        jsr     L9632                           ; 97A2 20 32 96  2.
        pla                                     ; 97A5 68       h
        jsr     asl_x4                          ; 97A6 20 A4 A9  ..
        jsr     select_ram_page_003             ; 97A9 20 16 BE  ..
        eor     $FD06                           ; 97AC 4D 06 FD M..
        and     #$30                            ; 97AF 29 30    )0
        eor     $FD06                           ; 97B1 4D 06 FD M..
        sta     $FD06                           ; 97B4 8D 06 FD ...
        jmp     L960B                           ; 97B7 4C 0B 96 L..

; ----------------------------------------------------------------------------
osfsc_opt_6:
        lda     #$40                            ; 97BA A9 40    .@
        cpy     #$12                            ; 97BC C0 12    ..
        beq     L97CA                           ; 97BE F0 0A    ..
        asl     a                               ; 97C0 0A       .
        cpy     #$00                            ; 97C1 C0 00    ..
        beq     L97CA                           ; 97C3 F0 05    ..
        asl     a                               ; 97C5 0A       .
        cpy     #$0A                            ; 97C6 C0 0A    ..
        bne     osfsc_opt_2_or_3_or_5           ; 97C8 D0 BE    ..
L97CA:  sta     $FDED                           ; 97CA 8D ED FD ...
        rts                                     ; 97CD 60       `

; ----------------------------------------------------------------------------
osfsc_opt_7:
        cpy     #$04                            ; 97CE C0 04    ..
        bcs     osfsc_opt_2_or_3_or_5           ; 97D0 B0 B6    ..
        tya                                     ; 97D2 98       .
        eor     #$03                            ; 97D3 49 03    I.
        sta     $FDF2                           ; 97D5 8D F2 FD ...
        rts                                     ; 97D8 60       `

; ----------------------------------------------------------------------------
osfsc_opt_8:
        lda     #$40                            ; 97D9 A9 40    .@
        iny                                     ; 97DB C8       .
        cpy     #$02                            ; 97DC C0 02    ..
        beq     L97E8                           ; 97DE F0 08    ..
        bcs     osfsc_opt_2_or_3_or_5           ; 97E0 B0 A6    ..
        asl     a                               ; 97E2 0A       .
        cpy     #$01                            ; 97E3 C0 01    ..
        bcc     L97E8                           ; 97E5 90 01    ..
        asl     a                               ; 97E7 0A       .
L97E8:  sta     $FDEA                           ; 97E8 8D EA FD ...
        rts                                     ; 97EB 60       `

; ----------------------------------------------------------------------------
osfsc_opt_9:
        cpy     #$10                            ; 97EC C0 10    ..
        bcs     osfsc_opt_2_or_3_or_5           ; 97EE B0 98    ..
        sty     $FDEE                           ; 97F0 8C EE FD ...
        rts                                     ; 97F3 60       `

; ----------------------------------------------------------------------------
osfsc_opt_routines:
        .word   osfsc_opt_0_or_1-1              ; 97F4 92 97    ..
        .word   osfsc_opt_0_or_1-1              ; 97F6 92 97    ..
        .word   osfsc_opt_2_or_3_or_5-1         ; 97F8 87 97    ..
        .word   osfsc_opt_2_or_3_or_5-1         ; 97FA 87 97    ..
        .word   osfsc_opt_4-1                   ; 97FC 9C 97    ..
        .word   osfsc_opt_2_or_3_or_5-1         ; 97FE 87 97    ..
        .word   osfsc_opt_6-1                   ; 9800 B9 97    ..
        .word   osfsc_opt_7-1                   ; 9802 CD 97    ..
        .word   osfsc_opt_8-1                   ; 9804 D8 97    ..
        .word   osfsc_opt_9-1                   ; 9806 EB 97    ..
; ----------------------------------------------------------------------------
osfsc_eof:
        pha                                     ; 9808 48       H
        tya                                     ; 9809 98       .
        pha                                     ; 980A 48       H
        txa                                     ; 980B 8A       .
        tay                                     ; 980C A8       .
        jsr     L9C9B                           ; 980D 20 9B 9C  ..
        tya                                     ; 9810 98       .
        jsr     L9E9F                           ; 9811 20 9F 9E  ..
        bne     L981A                           ; 9814 D0 04    ..
        ldx     #$FF                            ; 9816 A2 FF    ..
        bne     L981C                           ; 9818 D0 02    ..
L981A:  ldx     #$00                            ; 981A A2 00    ..
L981C:  pla                                     ; 981C 68       h
        tay                                     ; 981D A8       .
        pla                                     ; 981E 68       h
        rts                                     ; 981F 60       `

; ----------------------------------------------------------------------------
; does triple duty - *RUN, */ and libfs *RUN
osfsc_run:
        jsr     set_f2_y                        ; 9820 20 38 92  8.
        jsr     L988F                           ; 9823 20 8F 98  ..
        sty     $FDE3                           ; 9826 8C E3 FD ...
        jsr     L89E2                           ; 9829 20 E2 89  ..
        sty     $FDE2                           ; 982C 8C E2 FD ...
        jsr     L8C2E                           ; 982F 20 2E 8C  ..
        bcs     L9855                           ; 9832 B0 21    .!
        ldy     $FDE3                           ; 9834 AC E3 FD ...
        lda     $FDC8                           ; 9837 AD C8 FD ...
        sta     $CE                             ; 983A 85 CE    ..
        lda     $FDC9                           ; 983C AD C9 FD ...
        sta     $CF                             ; 983F 85 CF    ..
        jsr     L89E5                           ; 9841 20 E5 89  ..
        jsr     L8C2E                           ; 9844 20 2E 8C  ..
        bcs     L9855                           ; 9847 B0 0C    ..
L9849:  jsr     dobrk_with_Bad_prefix           ; 9849 20 9C A8  ..
        .byte   $FE                             ; 984C FE       .
        .byte   "command"                       ; 984D 63 6F 6D 6D 61 6E 64command
; ----------------------------------------------------------------------------
        brk                                     ; 9854 00       .
L9855:  jsr     LA1F8                           ; 9855 20 F8 A1  ..
        clc                                     ; 9858 18       .
        lda     $FDE2                           ; 9859 AD E2 FD ...
        tay                                     ; 985C A8       .
        adc     $F2                             ; 985D 65 F2    e.
        sta     $FDE2                           ; 985F 8D E2 FD ...
        lda     $F3                             ; 9862 A5 F3    ..
        adc     #$00                            ; 9864 69 00    i.
        sta     $FDE3                           ; 9866 8D E3 FD ...
        lda     $FDB7                           ; 9869 AD B7 FD ...
        and     $FDB8                           ; 986C 2D B8 FD -..
        ora     $FDCD                           ; 986F 0D CD FD ...
        cmp     #$FF                            ; 9872 C9 FF    ..
        beq     L988C                           ; 9874 F0 16    ..
        lda     L00C0                           ; 9876 A5 C0    ..
        sta     $FDB5                           ; 9878 8D B5 FD ...
        lda     $C1                             ; 987B A5 C1    ..
        sta     $FDB6                           ; 987D 8D B6 FD ...
        jsr     L96DC                           ; 9880 20 DC 96  ..
        ldx     #$B5                            ; 9883 A2 B5    ..
        ldy     #$FD                            ; 9885 A0 FD    ..
        lda     #$04                            ; 9887 A9 04    ..
        jmp     L0406                           ; 9889 4C 06 04 L..

; ----------------------------------------------------------------------------
L988C:  jmp     (L00C0)                         ; 988C 6C C0 00 l..

; ----------------------------------------------------------------------------
L988F:  lda     #$FF                            ; 988F A9 FF    ..
        sta     L00C0                           ; 9891 85 C0    ..
        lda     $F2                             ; 9893 A5 F2    ..
        sta     $BC                             ; 9895 85 BC    ..
        lda     $F3                             ; 9897 A5 F3    ..
        sta     $BD                             ; 9899 85 BD    ..
        rts                                     ; 989B 60       `

; ----------------------------------------------------------------------------
osfsc_star:
        jsr     set_f2_y                        ; 989C 20 38 92  8.
        ldx     #$B4                            ; 989F A2 B4    ..
        ldy     #$90                            ; 98A1 A0 90    ..
        lda     #$00                            ; 98A3 A9 00    ..
        jsr     L91A8                           ; 98A5 20 A8 91  ..
        tsx                                     ; 98A8 BA       .
        stx     $B8                             ; 98A9 86 B8    ..
        jmp     L80D7                           ; 98AB 4C D7 80 L..

; ----------------------------------------------------------------------------
osfsc_cat:
        jsr     set_f2_y                        ; 98AE 20 38 92  8.
        jsr     gsinit_with_carry_clear         ; 98B1 20 F2 A9  ..
        jsr     LAA72                           ; 98B4 20 72 AA  r.
        txa                                     ; 98B7 8A       .
        bpl     L98F3                           ; 98B8 10 39    .9
        lda     #$80                            ; 98BA A9 80    ..
        sta     $FDE9                           ; 98BC 8D E9 FD ...
        jsr     LABB5                           ; 98BF 20 B5 AB  ..
        bit     $FDED                           ; 98C2 2C ED FD ,..
        bvc     L98F3                           ; 98C5 50 2C    P,
        jsr     L8F0B                           ; 98C7 20 0B 8F  ..
        ldx     #$00                            ; 98CA A2 00    ..
L98CC:  jsr     select_ram_page_000             ; 98CC 20 07 BE  ..
        lda     $FDCD,x                         ; 98CF BD CD FD ...
        beq     L98E4                           ; 98D2 F0 10    ..
        txa                                     ; 98D4 8A       .
        pha                                     ; 98D5 48       H
        jsr     L961F                           ; 98D6 20 1F 96  ..
        jsr     print_disc_title_and_cycle_number; 98D9 20 D7 8E ..
        jsr     L8F88                           ; 98DC 20 88 8F  ..
        jsr     L8DCA                           ; 98DF 20 CA 8D  ..
        pla                                     ; 98E2 68       h
        tax                                     ; 98E3 AA       .
L98E4:  clc                                     ; 98E4 18       .
        lda     $CF                             ; 98E5 A5 CF    ..
        adc     #$10                            ; 98E7 69 10    i.
        sta     $CF                             ; 98E9 85 CF    ..
        inx                                     ; 98EB E8       .
        cpx     #$08                            ; 98EC E0 08    ..
        bne     L98CC                           ; 98EE D0 DC    ..
        jmp     select_ram_page_001             ; 98F0 4C 0C BE L..

; ----------------------------------------------------------------------------
L98F3:  jsr     L961F                           ; 98F3 20 1F 96  ..
        jsr     print_disc_title_and_cycle_number; 98F6 20 D7 8E ..
        jsr     L8F0B                           ; 98F9 20 0B 8F  ..
        jsr     L8F88                           ; 98FC 20 88 8F  ..
        jsr     L8FB8                           ; 98FF 20 B8 8F  ..
        jmp     L8DCA                           ; 9902 4C CA 8D L..

; ----------------------------------------------------------------------------
        jsr     L990F                           ; 9905 20 0F 99  ..
        asl     $FD00                           ; 9908 0E 00 FD ...
        lsr     $FD00                           ; 990B 4E 00 FD N..
        rts                                     ; 990E 60       `

; ----------------------------------------------------------------------------
L990F:  jsr     push_registers_and_tuck_restoration_thunk; 990F 20 4C A8 L.
        lda     #$77                            ; 9912 A9 77    .w
        jmp     osbyte                          ; 9914 4C F4 FF L..

; ----------------------------------------------------------------------------
osfsc_get_handle_range:
        ldx     #$11                            ; 9917 A2 11    ..
        ldy     #$15                            ; 9919 A0 15    ..
        rts                                     ; 991B 60       `

; ----------------------------------------------------------------------------
osfsc_oscli:
        bit     $FDDF                           ; 991C 2C DF FD ,..
        bmi     L9924                           ; 991F 30 03    0.
        dec     $FDDF                           ; 9921 CE DF FD ...
L9924:  jmp     L9753                           ; 9924 4C 53 97 LS.

; ----------------------------------------------------------------------------
L9927:  jsr     LAB9A                           ; 9927 20 9A AB  ..
L992A:  jsr     select_ram_page_001             ; 992A 20 0C BE  ..
        ldx     #$07                            ; 992D A2 07    ..
L992F:  lda     $FCED,y                         ; 992F B9 ED FC ...
        sta     $C6,x                           ; 9932 95 C6    ..
        dey                                     ; 9934 88       .
        dey                                     ; 9935 88       .
        dex                                     ; 9936 CA       .
        bne     L992F                           ; 9937 D0 F6    ..
        jsr     L8C2E                           ; 9939 20 2E 8C  ..
        bcc     L995E                           ; 993C 90 20    . 
        sty     $FDD2                           ; 993E 8C D2 FD ...
        jsr     select_ram_page_003             ; 9941 20 16 BE  ..
        lda     $FD0E,y                         ; 9944 B9 0E FD ...
        ldx     $FD0F,y                         ; 9947 BE 0F FD ...
        jsr     select_ram_page_001             ; 994A 20 0C BE  ..
        ldy     $FDD0                           ; 994D AC D0 FD ...
        eor     $FCEE,y                         ; 9950 59 EE FC Y..
        and     #$03                            ; 9953 29 03    ).
        bne     L995E                           ; 9955 D0 07    ..
        txa                                     ; 9957 8A       .
        cmp     $FCF0,y                         ; 9958 D9 F0 FC ...
        bne     L995E                           ; 995B D0 01    ..
        rts                                     ; 995D 60       `

; ----------------------------------------------------------------------------
L995E:  jmp     L8A92                           ; 995E 4C 92 8A L..

; ----------------------------------------------------------------------------
chosfind:
        cmp     #$00                            ; 9961 C9 00    ..
        bne     L99D9                           ; 9963 D0 74    .t
        jsr     push_registers_and_tuck_restoration_thunk; 9965 20 4C A8 L.
L9968:  tya                                     ; 9968 98       .
        beq     L9974                           ; 9969 F0 09    ..
        pha                                     ; 996B 48       H
        jsr     L9CAF                           ; 996C 20 AF 9C  ..
        tay                                     ; 996F A8       .
        pla                                     ; 9970 68       h
        jmp     L9988                           ; 9971 4C 88 99 L..

; ----------------------------------------------------------------------------
L9974:  jsr     L990F                           ; 9974 20 0F 99  ..
L9977:  ldy     #$04                            ; 9977 A0 04    ..
L9979:  tya                                     ; 9979 98       .
        pha                                     ; 997A 48       H
        lda     L9C91,y                         ; 997B B9 91 9C ...
        tay                                     ; 997E A8       .
        jsr     L9988                           ; 997F 20 88 99  ..
        pla                                     ; 9982 68       h
        tay                                     ; 9983 A8       .
        dey                                     ; 9984 88       .
        bpl     L9979                           ; 9985 10 F2    ..
        rts                                     ; 9987 60       `

; ----------------------------------------------------------------------------
L9988:  jsr     select_ram_page_001             ; 9988 20 0C BE  ..
        pha                                     ; 998B 48       H
        jsr     L9C74                           ; 998C 20 74 9C  t.
        bcs     L99D7                           ; 998F B0 46    .F
        lda     fdc_control,y                   ; 9991 B9 FC FC ...
        eor     #$FF                            ; 9994 49 FF    I.
        and     $FDCE                           ; 9996 2D CE FD -..
        sta     $FDCE                           ; 9999 8D CE FD ...
        lda     fdc_status_or_cmd,y             ; 999C B9 F8 FC ...
        and     #$60                            ; 999F 29 60    )`
        beq     L99D7                           ; 99A1 F0 34    .4
        jsr     L9927                           ; 99A3 20 27 99  '.
        lda     fdc_status_or_cmd,y             ; 99A6 B9 F8 FC ...
        and     #$20                            ; 99A9 29 20    ) 
        beq     L99D4                           ; 99AB F0 27    .'
        ldx     $FDD2                           ; 99AD AE D2 FD ...
        lda     $FCF5,y                         ; 99B0 B9 F5 FC ...
        jsr     select_ram_page_003             ; 99B3 20 16 BE  ..
        sta     $FD0C,x                         ; 99B6 9D 0C FD ...
        jsr     select_ram_page_001             ; 99B9 20 0C BE  ..
        lda     $FCF6,y                         ; 99BC B9 F6 FC ...
        jsr     select_ram_page_003             ; 99BF 20 16 BE  ..
        sta     $FD0D,x                         ; 99C2 9D 0D FD ...
        jsr     select_ram_page_001             ; 99C5 20 0C BE  ..
        lda     $FCF7,y                         ; 99C8 B9 F7 FC ...
        jsr     L92EC                           ; 99CB 20 EC 92  ..
        jsr     L960B                           ; 99CE 20 0B 96  ..
        ldy     $FDD0                           ; 99D1 AC D0 FD ...
L99D4:  jsr     L9D42                           ; 99D4 20 42 9D  B.
L99D7:  pla                                     ; 99D7 68       h
        rts                                     ; 99D8 60       `

; ----------------------------------------------------------------------------
L99D9:  jsr     LA875                           ; 99D9 20 75 A8  u.
        stx     $BC                             ; 99DC 86 BC    ..
        sty     $BD                             ; 99DE 84 BD    ..
        sta     $B4                             ; 99E0 85 B4    ..
        bit     $B4                             ; 99E2 24 B4    $.
        php                                     ; 99E4 08       .
        jsr     L89E2                           ; 99E5 20 E2 89  ..
        jsr     L9AF7                           ; 99E8 20 F7 9A  ..
        bcc     L9A05                           ; 99EB 90 18    ..
        jsr     print_string_2_nterm            ; 99ED 20 AD A8  ..
        .byte   $C0                             ; 99F0 C0       .
        .byte   "Too many files open"           ; 99F1 54 6F 6F 20 6D 61 6E 79Too many
                                                ; 99F9 20 66 69 6C 65 73 20 6F files o
                                                ; 9A01 70 65 6E pen
; ----------------------------------------------------------------------------
        brk                                     ; 9A04 00       .
L9A05:  ldx     #$C7                            ; 9A05 A2 C7    ..
        lda     #$00                            ; 9A07 A9 00    ..
        tay                                     ; 9A09 A8       .
        jsr     L9B10                           ; 9A0A 20 10 9B  ..
        bcc     L9A29                           ; 9A0D 90 1A    ..
L9A0F:  jsr     select_ram_page_001             ; 9A0F 20 0C BE  ..
        lda     $FCED,y                         ; 9A12 B9 ED FC ...
        bpl     L9A1B                           ; 9A15 10 04    ..
        plp                                     ; 9A17 28       (
        php                                     ; 9A18 08       .
        bpl     L9A24                           ; 9A19 10 09    ..
L9A1B:  jsr     dobrk_with_File_prefix          ; 9A1B 20 A5 A8  ..
        .byte   $C2                             ; 9A1E C2       .
        .byte   "open"                          ; 9A1F 6F 70 65 6Eopen
; ----------------------------------------------------------------------------
        brk                                     ; 9A23 00       .
L9A24:  jsr     L9B2A                           ; 9A24 20 2A 9B  *.
        bcs     L9A0F                           ; 9A27 B0 E6    ..
L9A29:  jsr     L8B32                           ; 9A29 20 32 8B  2.
        jsr     L8C2E                           ; 9A2C 20 2E 8C  ..
        bcs     L9A4E                           ; 9A2F B0 1D    ..
        lda     #$00                            ; 9A31 A9 00    ..
        plp                                     ; 9A33 28       (
        bvc     L9A37                           ; 9A34 50 01    P.
        rts                                     ; 9A36 60       `

; ----------------------------------------------------------------------------
L9A37:  php                                     ; 9A37 08       .
        jsr     select_ram_page_001             ; 9A38 20 0C BE  ..
        ldx     #$07                            ; 9A3B A2 07    ..
L9A3D:  sta     $BE,x                           ; 9A3D 95 BE    ..
        sta     $FDB5,x                         ; 9A3F 9D B5 FD ...
        dex                                     ; 9A42 CA       .
        bpl     L9A3D                           ; 9A43 10 F8    ..
        lda     #$40                            ; 9A45 A9 40    .@
        sta     $C5                             ; 9A47 85 C5    ..
        sta     L00A8                           ; 9A49 85 A8    ..
        jsr     L93B3                           ; 9A4B 20 B3 93  ..
L9A4E:  tya                                     ; 9A4E 98       .
        tax                                     ; 9A4F AA       .
        plp                                     ; 9A50 28       (
        php                                     ; 9A51 08       .
        bvs     L9A57                           ; 9A52 70 03    p.
        jsr     LA295                           ; 9A54 20 95 A2  ..
L9A57:  jsr     select_ram_page_001             ; 9A57 20 0C BE  ..
        lda     #$08                            ; 9A5A A9 08    ..
        sta     $FDD3                           ; 9A5C 8D D3 FD ...
        ldy     $FDD0                           ; 9A5F AC D0 FD ...
L9A62:  jsr     select_ram_page_002             ; 9A62 20 11 BE  ..
        lda     $FD08,x                         ; 9A65 BD 08 FD ...
        jsr     select_ram_page_001             ; 9A68 20 0C BE  ..
        sta     $FCE1,y                         ; 9A6B 99 E1 FC ...
        iny                                     ; 9A6E C8       .
        jsr     select_ram_page_003             ; 9A6F 20 16 BE  ..
        lda     $FD08,x                         ; 9A72 BD 08 FD ...
        jsr     select_ram_page_001             ; 9A75 20 0C BE  ..
        sta     $FCE1,y                         ; 9A78 99 E1 FC ...
        iny                                     ; 9A7B C8       .
        inx                                     ; 9A7C E8       .
        dec     $FDD3                           ; 9A7D CE D3 FD ...
        bne     L9A62                           ; 9A80 D0 E0    ..
        ldx     #$10                            ; 9A82 A2 10    ..
        lda     #$00                            ; 9A84 A9 00    ..
L9A86:  sta     $FCE1,y                         ; 9A86 99 E1 FC ...
        iny                                     ; 9A89 C8       .
        dex                                     ; 9A8A CA       .
        bne     L9A86                           ; 9A8B D0 F9    ..
        ldy     $FDD0                           ; 9A8D AC D0 FD ...
        lda     $FDCF                           ; 9A90 AD CF FD ...
        sta     fdc_control,y                   ; 9A93 99 FC FC ...
        ora     $FDCE                           ; 9A96 0D CE FD ...
        sta     $FDCE                           ; 9A99 8D CE FD ...
        lda     $FCEA,y                         ; 9A9C B9 EA FC ...
        cmp     #$01                            ; 9A9F C9 01    ..
        lda     $FCEC,y                         ; 9AA1 B9 EC FC ...
        adc     #$00                            ; 9AA4 69 00    i.
        sta     fdc_sector,y                    ; 9AA6 99 FA FC ...
        lda     $FCEE,y                         ; 9AA9 B9 EE FC ...
        ora     #$0F                            ; 9AAC 09 0F    ..
        adc     #$00                            ; 9AAE 69 00    i.
        jsr     extract_00xx0000                ; 9AB0 20 96 A9  ..
        sta     fdc_data,y                      ; 9AB3 99 FB FC ...
        plp                                     ; 9AB6 28       (
        bvc     L9AF0                           ; 9AB7 50 37    P7
        bmi     L9AC3                           ; 9AB9 30 08    0.
        lda     #$80                            ; 9ABB A9 80    ..
        ora     $FCED,y                         ; 9ABD 19 ED FC ...
        sta     $FCED,y                         ; 9AC0 99 ED FC ...
L9AC3:  lda     $FCEA,y                         ; 9AC3 B9 EA FC ...
        sta     $FCF5,y                         ; 9AC6 99 F5 FC ...
        lda     $FCEC,y                         ; 9AC9 B9 EC FC ...
        sta     $FCF6,y                         ; 9ACC 99 F6 FC ...
        lda     $FCEE,y                         ; 9ACF B9 EE FC ...
        jsr     extract_00xx0000                ; 9AD2 20 96 A9  ..
        sta     $FCF7,y                         ; 9AD5 99 F7 FC ...
L9AD8:  lda     $CF                             ; 9AD8 A5 CF    ..
        sta     $FD00,y                         ; 9ADA 99 00 FD ...
        jsr     L853F                           ; 9ADD 20 3F 85  ?.
        sta     $FCF4,y                         ; 9AE0 99 F4 FC ...
        lda     $FDEC                           ; 9AE3 AD EC FD ...
        sta     ram_paging_lsb,y                ; 9AE6 99 FF FC ...
        tya                                     ; 9AE9 98       .
        jsr     lsr_x5                          ; 9AEA 20 9D A9  ..
        adc     #$10                            ; 9AED 69 10    i.
        rts                                     ; 9AEF 60       `

; ----------------------------------------------------------------------------
L9AF0:  lda     #$20                            ; 9AF0 A9 20    . 
        sta     fdc_status_or_cmd,y             ; 9AF2 99 F8 FC ...
        bne     L9AD8                           ; 9AF5 D0 E1    ..
L9AF7:  lda     $FDCE                           ; 9AF7 AD CE FD ...
        ldx     #$FB                            ; 9AFA A2 FB    ..
L9AFC:  asl     a                               ; 9AFC 0A       .
        bcc     L9B03                           ; 9AFD 90 04    ..
        inx                                     ; 9AFF E8       .
        bmi     L9AFC                           ; 9B00 30 FA    0.
        rts                                     ; 9B02 60       `

; ----------------------------------------------------------------------------
L9B03:  lda     L9B96,x                         ; 9B03 BD 96 9B ...
        sta     $FDD0                           ; 9B06 8D D0 FD ...
        lda     L9B9B,x                         ; 9B09 BD 9B 9B ...
        sta     $FDCF                           ; 9B0C 8D CF FD ...
        rts                                     ; 9B0F 60       `

; ----------------------------------------------------------------------------
L9B10:  stx     $B0                             ; 9B10 86 B0    ..
        sty     $B1                             ; 9B12 84 B1    ..
        sta     $B2                             ; 9B14 85 B2    ..
        jsr     select_ram_page_001             ; 9B16 20 0C BE  ..
        lda     $FDCE                           ; 9B19 AD CE FD ...
        and     #$F8                            ; 9B1C 29 F8    ).
        sta     $B5                             ; 9B1E 85 B5    ..
        ldx     #$20                            ; 9B20 A2 20    . 
L9B22:  stx     $B4                             ; 9B22 86 B4    ..
        asl     $B5                             ; 9B24 06 B5    ..
        bcs     L9B34                           ; 9B26 B0 0C    ..
        beq     L9B32                           ; 9B28 F0 08    ..
L9B2A:  lda     $B4                             ; 9B2A A5 B4    ..
        clc                                     ; 9B2C 18       .
        adc     #$20                            ; 9B2D 69 20    i 
        tax                                     ; 9B2F AA       .
        bcc     L9B22                           ; 9B30 90 F0    ..
L9B32:  clc                                     ; 9B32 18       .
        rts                                     ; 9B33 60       `

; ----------------------------------------------------------------------------
L9B34:  lda     $FD00,x                         ; 9B34 BD 00 FD ...
        jsr     LAADB                           ; 9B37 20 DB AA  ..
        sta     $B3                             ; 9B3A 85 B3    ..
        jsr     LAAD9                           ; 9B3C 20 D9 AA  ..
        eor     $B3                             ; 9B3F 45 B3    E.
        bne     L9B2A                           ; 9B41 D0 E7    ..
        lda     #$08                            ; 9B43 A9 08    ..
        sta     $B3                             ; 9B45 85 B3    ..
        ldy     $B2                             ; 9B47 A4 B2    ..
L9B49:  jsr     select_ram_page_002             ; 9B49 20 11 BE  ..
        lda     ($B0),y                         ; 9B4C B1 B0    ..
        jsr     select_ram_page_001             ; 9B4E 20 0C BE  ..
        eor     $FCE1,x                         ; 9B51 5D E1 FC ]..
        and     #$7F                            ; 9B54 29 7F    ).
        bne     L9B2A                           ; 9B56 D0 D2    ..
        iny                                     ; 9B58 C8       .
        inx                                     ; 9B59 E8       .
        inx                                     ; 9B5A E8       .
        dec     $B3                             ; 9B5B C6 B3    ..
        bne     L9B49                           ; 9B5D D0 EA    ..
        ldy     $B4                             ; 9B5F A4 B4    ..
        rts                                     ; 9B61 60       `

; ----------------------------------------------------------------------------
chosargs:
        jsr     select_ram_page_001             ; 9B62 20 0C BE  ..
        cpy     #$00                            ; 9B65 C0 00    ..
        beq     L9B7A                           ; 9B67 F0 11    ..
        jsr     push_registers_and_tuck_restoration_thunk; 9B69 20 4C A8 L.
        cmp     #$FF                            ; 9B6C C9 FF    ..
        beq     L9BAC                           ; 9B6E F0 3C    .<
        cmp     #$03                            ; 9B70 C9 03    ..
        bcs     L9B8B                           ; 9B72 B0 17    ..
        lsr     a                               ; 9B74 4A       J
        bcc     L9BB8                           ; 9B75 90 41    .A
        jmp     L9BD8                           ; 9B77 4C D8 9B L..

; ----------------------------------------------------------------------------
L9B7A:  jsr     LA875                           ; 9B7A 20 75 A8  u.
        tay                                     ; 9B7D A8       .
        iny                                     ; 9B7E C8       .
        cpy     #$03                            ; 9B7F C0 03    ..
        bcs     L9B8B                           ; 9B81 B0 08    ..
        lda     osargs_y0_routines_msbs,y       ; 9B83 B9 30 AE .0.
        pha                                     ; 9B86 48       H
        lda     osargs_y0_routines_lsbs,y       ; 9B87 B9 2D AE .-.
        pha                                     ; 9B8A 48       H
L9B8B:  rts                                     ; 9B8B 60       `

; ----------------------------------------------------------------------------
osargs_get_fs_type:
        lda     #$04                            ; 9B8C A9 04    ..
        rts                                     ; 9B8E 60       `

; ----------------------------------------------------------------------------
osargs_get_command_line_tail:
        lda     #$FF                            ; 9B8F A9 FF    ..
        sta     $02,x                           ; 9B91 95 02    ..
        sta     $03,x                           ; 9B93 95 03    ..
        .byte   $AD                             ; 9B95 AD       .
L9B96:  .byte   $E2                             ; 9B96 E2       .
        sbc     a:$95,x                         ; 9B97 FD 95 00 ...
        .byte   $AD                             ; 9B9A AD       .
L9B9B:  .byte   $E3                             ; 9B9B E3       .
        sbc     $0195,x                         ; 9B9C FD 95 01 ...
        lda     #$00                            ; 9B9F A9 00    ..
        rts                                     ; 9BA1 60       `

; ----------------------------------------------------------------------------
osargs_update_all_files:
        lda     $FDCE                           ; 9BA2 AD CE FD ...
        pha                                     ; 9BA5 48       H
        jsr     L9977                           ; 9BA6 20 77 99  w.
        jmp     L9BB3                           ; 9BA9 4C B3 9B L..

; ----------------------------------------------------------------------------
L9BAC:  lda     $FDCE                           ; 9BAC AD CE FD ...
        pha                                     ; 9BAF 48       H
        jsr     L9968                           ; 9BB0 20 68 99  h.
L9BB3:  pla                                     ; 9BB3 68       h
        sta     $FDCE                           ; 9BB4 8D CE FD ...
        rts                                     ; 9BB7 60       `

; ----------------------------------------------------------------------------
L9BB8:  jsr     push_registers_and_tuck_restoration_thunk; 9BB8 20 4C A8 L.
        jsr     L9C9B                           ; 9BBB 20 9B 9C  ..
        asl     a                               ; 9BBE 0A       .
        asl     a                               ; 9BBF 0A       .
        adc     $FDD0                           ; 9BC0 6D D0 FD m..
        tay                                     ; 9BC3 A8       .
        lda     $FCF1,y                         ; 9BC4 B9 F1 FC ...
        sta     $00,x                           ; 9BC7 95 00    ..
        lda     $FCF2,y                         ; 9BC9 B9 F2 FC ...
        sta     $01,x                           ; 9BCC 95 01    ..
        lda     $FCF3,y                         ; 9BCE B9 F3 FC ...
        sta     $02,x                           ; 9BD1 95 02    ..
        lda     #$00                            ; 9BD3 A9 00    ..
        sta     $03,x                           ; 9BD5 95 03    ..
        rts                                     ; 9BD7 60       `

; ----------------------------------------------------------------------------
L9BD8:  jsr     push_registers_and_tuck_restoration_thunk; 9BD8 20 4C A8 L.
        jsr     L9C9B                           ; 9BDB 20 9B 9C  ..
        sec                                     ; 9BDE 38       8
        lda     $FCFD,y                         ; 9BDF B9 FD FC ...
        sbc     $FCF0,y                         ; 9BE2 F9 F0 FC ...
        sta     $B0                             ; 9BE5 85 B0    ..
        lda     ram_paging_msb,y                ; 9BE7 B9 FE FC ...
        sbc     $FCEE,y                         ; 9BEA F9 EE FC ...
        and     #$03                            ; 9BED 29 03    ).
        cmp     $02,x                           ; 9BEF D5 02    ..
        bne     L9BF9                           ; 9BF1 D0 06    ..
        lda     $B0                             ; 9BF3 A5 B0    ..
        cmp     $01,x                           ; 9BF5 D5 01    ..
        beq     L9C04                           ; 9BF7 F0 0B    ..
L9BF9:  jsr     LAB9A                           ; 9BF9 20 9A AB  ..
        jsr     L9D3F                           ; 9BFC 20 3F 9D  ?.
        lda     #$6F                            ; 9BFF A9 6F    .o
        jsr     L9D37                           ; 9C01 20 37 9D  7.
L9C04:  jsr     L9EB7                           ; 9C04 20 B7 9E  ..
        bcs     L9C64                           ; 9C07 B0 5B    .[
        lda     $01,x                           ; 9C09 B5 01    ..
        cmp     $FCF6,y                         ; 9C0B D9 F6 FC ...
        bne     L9C17                           ; 9C0E D0 07    ..
        lda     $02,x                           ; 9C10 B5 02    ..
        cmp     $FCF7,y                         ; 9C12 D9 F7 FC ...
        beq     L9C48                           ; 9C15 F0 31    .1
L9C17:  clc                                     ; 9C17 18       .
        lda     $00,x                           ; 9C18 B5 00    ..
        adc     #$FF                            ; 9C1A 69 FF    i.
        lda     $01,x                           ; 9C1C B5 01    ..
        adc     #$00                            ; 9C1E 69 00    i.
        sta     $C4                             ; 9C20 85 C4    ..
        lda     $02,x                           ; 9C22 B5 02    ..
        adc     #$00                            ; 9C24 69 00    i.
        sta     $C5                             ; 9C26 85 C5    ..
        txa                                     ; 9C28 8A       .
        pha                                     ; 9C29 48       H
        jsr     L992A                           ; 9C2A 20 2A 99  *.
        jsr     L9E6E                           ; 9C2D 20 6E 9E  n.
        sec                                     ; 9C30 38       8
        lda     $C4                             ; 9C31 A5 C4    ..
        sbc     L00C0                           ; 9C33 E5 C0    ..
        sta     $C2                             ; 9C35 85 C2    ..
        lda     $C5                             ; 9C37 A5 C5    ..
        sbc     $C1                             ; 9C39 E5 C1    ..
        sta     $C3                             ; 9C3B 85 C3    ..
        bcc     L9C46                           ; 9C3D 90 07    ..
        ora     $C2                             ; 9C3F 05 C2    ..
        beq     L9C46                           ; 9C41 F0 03    ..
        jsr     L9EC7                           ; 9C43 20 C7 9E  ..
L9C46:  pla                                     ; 9C46 68       h
        tax                                     ; 9C47 AA       .
L9C48:  lda     $FCF5,y                         ; 9C48 B9 F5 FC ...
        sta     $FCF1,y                         ; 9C4B 99 F1 FC ...
        lda     $FCF6,y                         ; 9C4E B9 F6 FC ...
        sta     $FCF2,y                         ; 9C51 99 F2 FC ...
        lda     $FCF7,y                         ; 9C54 B9 F7 FC ...
        sta     $FCF3,y                         ; 9C57 99 F3 FC ...
L9C5A:  lda     #$00                            ; 9C5A A9 00    ..
        jsr     L9D98                           ; 9C5C 20 98 9D  ..
        jsr     L9EB7                           ; 9C5F 20 B7 9E  ..
        bcc     L9C5A                           ; 9C62 90 F6    ..
L9C64:  lda     $00,x                           ; 9C64 B5 00    ..
        sta     $FCF1,y                         ; 9C66 99 F1 FC ...
        lda     $01,x                           ; 9C69 B5 01    ..
        sta     $FCF2,y                         ; 9C6B 99 F2 FC ...
        lda     $02,x                           ; 9C6E B5 02    ..
        sta     $FCF3,y                         ; 9C70 99 F3 FC ...
        rts                                     ; 9C73 60       `

; ----------------------------------------------------------------------------
L9C74:  pha                                     ; 9C74 48       H
        tya                                     ; 9C75 98       .
        and     #$E0                            ; 9C76 29 E0    ).
        sta     $FDD0                           ; 9C78 8D D0 FD ...
        beq     L9C8E                           ; 9C7B F0 11    ..
        lsr     a                               ; 9C7D 4A       J
        lsr     a                               ; 9C7E 4A       J
        lsr     a                               ; 9C7F 4A       J
        lsr     a                               ; 9C80 4A       J
        lsr     a                               ; 9C81 4A       J
        tay                                     ; 9C82 A8       .
        lda     L9C95,y                         ; 9C83 B9 95 9C ...
        ldy     $FDD0                           ; 9C86 AC D0 FD ...
        bit     $FDCE                           ; 9C89 2C CE FD ,..
        bne     L9C8F                           ; 9C8C D0 01    ..
L9C8E:  sec                                     ; 9C8E 38       8
L9C8F:  pla                                     ; 9C8F 68       h
        rts                                     ; 9C90 60       `

; ----------------------------------------------------------------------------
L9C91:  .byte   $20,$40,$60,$80                 ; 9C91 20 40 60 80 @`.
L9C95:  .byte   $A0                             ; 9C95 A0       .
L9C96:  .byte   $80,$40                         ; 9C96 80 40    .@
; ----------------------------------------------------------------------------
        jsr     L0810                           ; 9C98 20 10 08  ..
L9C9B:  pha                                     ; 9C9B 48       H
        jsr     L9CAF                           ; 9C9C 20 AF 9C  ..
        sta     $FDD0                           ; 9C9F 8D D0 FD ...
        lda     L9C96,y                         ; 9CA2 B9 96 9C ...
        ldy     $FDD0                           ; 9CA5 AC D0 FD ...
        bit     $FDCE                           ; 9CA8 2C CE FD ,..
        beq     L9CBD                           ; 9CAB F0 10    ..
        pla                                     ; 9CAD 68       h
        rts                                     ; 9CAE 60       `

; ----------------------------------------------------------------------------
L9CAF:  tya                                     ; 9CAF 98       .
        cmp     #$16                            ; 9CB0 C9 16    ..
        bcs     L9CBD                           ; 9CB2 B0 09    ..
        sbc     #$10                            ; 9CB4 E9 10    ..
        bcc     L9CBD                           ; 9CB6 90 05    ..
        tay                                     ; 9CB8 A8       .
        lda     L9C91,y                         ; 9CB9 B9 91 9C ...
        rts                                     ; 9CBC 60       `

; ----------------------------------------------------------------------------
L9CBD:  jsr     print_string_2_nterm            ; 9CBD 20 AD A8  ..
        .byte   $DE                             ; 9CC0 DE       .
        .byte   "Channel"                       ; 9CC1 43 68 61 6E 6E 65 6CChannel
; ----------------------------------------------------------------------------
        brk                                     ; 9CC8 00       .
L9CC9:  jsr     print_string_2_nterm            ; 9CC9 20 AD A8  ..
        .byte   $DF                             ; 9CCC DF       .
        .byte   "EOF"                           ; 9CCD 45 4F 46 EOF
; ----------------------------------------------------------------------------
        brk                                     ; 9CD0 00       .
chosbget:
        jsr     select_ram_page_001             ; 9CD1 20 0C BE  ..
        stx     $FDC4                           ; 9CD4 8E C4 FD ...
        sty     $FDC5                           ; 9CD7 8C C5 FD ...
        jsr     L9C9B                           ; 9CDA 20 9B 9C  ..
        tya                                     ; 9CDD 98       .
        jsr     L9E9F                           ; 9CDE 20 9F 9E  ..
        bne     L9CF4                           ; 9CE1 D0 11    ..
        lda     fdc_status_or_cmd,y             ; 9CE3 B9 F8 FC ...
        and     #$10                            ; 9CE6 29 10    ).
        bne     L9CC9                           ; 9CE8 D0 DF    ..
        lda     #$10                            ; 9CEA A9 10    ..
        jsr     L9D30                           ; 9CEC 20 30 9D  0.
        lda     #$FE                            ; 9CEF A9 FE    ..
        sec                                     ; 9CF1 38       8
        bcs     L9D0C                           ; 9CF2 B0 18    ..
L9CF4:  lda     fdc_status_or_cmd,y             ; 9CF4 B9 F8 FC ...
        bmi     L9D03                           ; 9CF7 30 0A    0.
        jsr     LAB9A                           ; 9CF9 20 9A AB  ..
        jsr     L9D42                           ; 9CFC 20 42 9D  B.
        sec                                     ; 9CFF 38       8
        jsr     L9D4A                           ; 9D00 20 4A 9D  J.
L9D03:  jsr     L9E59                           ; 9D03 20 59 9E  Y.
        lda     $FD00,x                         ; 9D06 BD 00 FD ...
        jsr     select_ram_page_001             ; 9D09 20 0C BE  ..
L9D0C:  ldx     $FDC4                           ; 9D0C AE C4 FD ...
        ldy     $FDC5                           ; 9D0F AC C5 FD ...
        pha                                     ; 9D12 48       H
        pla                                     ; 9D13 68       h
        rts                                     ; 9D14 60       `

; ----------------------------------------------------------------------------
L9D15:  clc                                     ; 9D15 18       .
        lda     $FCF0,y                         ; 9D16 B9 F0 FC ...
        adc     $FCF2,y                         ; 9D19 79 F2 FC y..
        sta     $C5                             ; 9D1C 85 C5    ..
        sta     $FCFD,y                         ; 9D1E 99 FD FC ...
        lda     $FCEE,y                         ; 9D21 B9 EE FC ...
        and     #$03                            ; 9D24 29 03    ).
        adc     $FCF3,y                         ; 9D26 79 F3 FC y..
        sta     $C4                             ; 9D29 85 C4    ..
        sta     ram_paging_msb,y                ; 9D2B 99 FE FC ...
        lda     #$80                            ; 9D2E A9 80    ..
L9D30:  ora     fdc_status_or_cmd,y             ; 9D30 19 F8 FC ...
        bne     L9D3A                           ; 9D33 D0 05    ..
L9D35:  lda     #$7F                            ; 9D35 A9 7F    ..
L9D37:  and     fdc_status_or_cmd,y             ; 9D37 39 F8 FC 9..
L9D3A:  sta     fdc_status_or_cmd,y             ; 9D3A 99 F8 FC ...
        clc                                     ; 9D3D 18       .
        rts                                     ; 9D3E 60       `

; ----------------------------------------------------------------------------
L9D3F:  jsr     push_registers_and_tuck_restoration_thunk; 9D3F 20 4C A8 L.
L9D42:  lda     fdc_status_or_cmd,y             ; 9D42 B9 F8 FC ...
        and     #$40                            ; 9D45 29 40    )@
        beq     L9D86                           ; 9D47 F0 3D    .=
        clc                                     ; 9D49 18       .
L9D4A:  php                                     ; 9D4A 08       .
        jsr     select_ram_page_001             ; 9D4B 20 0C BE  ..
        ldy     $FDD0                           ; 9D4E AC D0 FD ...
        tya                                     ; 9D51 98       .
        lsr     a                               ; 9D52 4A       J
        lsr     a                               ; 9D53 4A       J
        lsr     a                               ; 9D54 4A       J
        lsr     a                               ; 9D55 4A       J
        lsr     a                               ; 9D56 4A       J
        adc     #$03                            ; 9D57 69 03    i.
        sta     $BE                             ; 9D59 85 BE    ..
        lda     #$00                            ; 9D5B A9 00    ..
        sta     $BF                             ; 9D5D 85 BF    ..
        sta     $C2                             ; 9D5F 85 C2    ..
        lda     #$01                            ; 9D61 A9 01    ..
        sta     $C3                             ; 9D63 85 C3    ..
        plp                                     ; 9D65 28       (
        bcs     L9D7D                           ; 9D66 B0 15    ..
        lda     $FCFD,y                         ; 9D68 B9 FD FC ...
        sta     $C5                             ; 9D6B 85 C5    ..
        lda     ram_paging_msb,y                ; 9D6D B9 FE FC ...
        sta     $C4                             ; 9D70 85 C4    ..
        jsr     L9721                           ; 9D72 20 21 97  !.
        ldy     $FDD0                           ; 9D75 AC D0 FD ...
        lda     #$BF                            ; 9D78 A9 BF    ..
        jmp     L9D37                           ; 9D7A 4C 37 9D L7.

; ----------------------------------------------------------------------------
L9D7D:  jsr     L9D15                           ; 9D7D 20 15 9D  ..
        jsr     L9724                           ; 9D80 20 24 97  $.
        ldy     $FDD0                           ; 9D83 AC D0 FD ...
L9D86:  rts                                     ; 9D86 60       `

; ----------------------------------------------------------------------------
L9D87:  jmp     LA29D                           ; 9D87 4C 9D A2 L..

; ----------------------------------------------------------------------------
L9D8A:  jsr     dobrk_with_File_prefix          ; 9D8A 20 A5 A8  ..
        .byte   $C1                             ; 9D8D C1       .
        .byte   "read only"                     ; 9D8E 72 65 61 64 20 6F 6E 6Cread onl
                                                ; 9D96 79       y
; ----------------------------------------------------------------------------
        brk                                     ; 9D97 00       .
L9D98:  jsr     push_registers_and_tuck_restoration_thunk; 9D98 20 4C A8 L.
        jmp     L9DAD                           ; 9D9B 4C AD 9D L..

; ----------------------------------------------------------------------------
chosbput:
        jsr     select_ram_page_001             ; 9D9E 20 0C BE  ..
        sta     $FDC3                           ; 9DA1 8D C3 FD ...
        stx     $FDC4                           ; 9DA4 8E C4 FD ...
        sty     $FDC5                           ; 9DA7 8C C5 FD ...
        jsr     L9C9B                           ; 9DAA 20 9B 9C  ..
L9DAD:  pha                                     ; 9DAD 48       H
        lda     $FCED,y                         ; 9DAE B9 ED FC ...
        bmi     L9D8A                           ; 9DB1 30 D7    0.
        lda     $FCEF,y                         ; 9DB3 B9 EF FC ...
        bmi     L9D87                           ; 9DB6 30 CF    0.
        jsr     LAB9A                           ; 9DB8 20 9A AB  ..
        tya                                     ; 9DBB 98       .
        clc                                     ; 9DBC 18       .
        adc     #$04                            ; 9DBD 69 04    i.
        jsr     L9E9F                           ; 9DBF 20 9F 9E  ..
        bne     L9E07                           ; 9DC2 D0 43    .C
        jsr     L992A                           ; 9DC4 20 2A 99  *.
L9DC7:  jsr     L9E6E                           ; 9DC7 20 6E 9E  n.
        lda     $C1                             ; 9DCA A5 C1    ..
        cmp     fdc_data,y                      ; 9DCC D9 FB FC ...
        bne     L9DE5                           ; 9DCF D0 14    ..
        lda     L00C0                           ; 9DD1 A5 C0    ..
        cmp     fdc_sector,y                    ; 9DD3 D9 FA FC ...
        bne     L9DF3                           ; 9DD6 D0 1B    ..
        lda     #$01                            ; 9DD8 A9 01    ..
        sta     $C2                             ; 9DDA 85 C2    ..
        lda     #$00                            ; 9DDC A9 00    ..
        sta     $C3                             ; 9DDE 85 C3    ..
        jsr     L9EC7                           ; 9DE0 20 C7 9E  ..
        bcc     L9DC7                           ; 9DE3 90 E2    ..
L9DE5:  clc                                     ; 9DE5 18       .
        lda     fdc_data,y                      ; 9DE6 B9 FB FC ...
        adc     #$01                            ; 9DE9 69 01    i.
        sta     fdc_data,y                      ; 9DEB 99 FB FC ...
        jsr     L92EC                           ; 9DEE 20 EC 92  ..
        lda     #$00                            ; 9DF1 A9 00    ..
L9DF3:  sta     fdc_sector,y                    ; 9DF3 99 FA FC ...
        jsr     select_ram_page_003             ; 9DF6 20 16 BE  ..
        sta     $FD0D,x                         ; 9DF9 9D 0D FD ...
        lda     #$00                            ; 9DFC A9 00    ..
        sta     $FD0C,x                         ; 9DFE 9D 0C FD ...
        jsr     L960B                           ; 9E01 20 0B 96  ..
        ldy     $FDD0                           ; 9E04 AC D0 FD ...
L9E07:  lda     fdc_status_or_cmd,y             ; 9E07 B9 F8 FC ...
        bmi     L9E23                           ; 9E0A 30 17    0.
        jsr     L9D42                           ; 9E0C 20 42 9D  B.
        lda     $FCF5,y                         ; 9E0F B9 F5 FC ...
        bne     L9E1F                           ; 9E12 D0 0B    ..
        tya                                     ; 9E14 98       .
        jsr     L9E9F                           ; 9E15 20 9F 9E  ..
        bne     L9E1F                           ; 9E18 D0 05    ..
        jsr     L9D15                           ; 9E1A 20 15 9D  ..
        bne     L9E23                           ; 9E1D D0 04    ..
L9E1F:  sec                                     ; 9E1F 38       8
        jsr     L9D4A                           ; 9E20 20 4A 9D  J.
L9E23:  jsr     L9E59                           ; 9E23 20 59 9E  Y.
        pla                                     ; 9E26 68       h
        sta     $FD00,x                         ; 9E27 9D 00 FD ...
        jsr     select_ram_page_001             ; 9E2A 20 0C BE  ..
        lda     #$40                            ; 9E2D A9 40    .@
        jsr     L9D30                           ; 9E2F 20 30 9D  0.
        tya                                     ; 9E32 98       .
        jsr     L9E9F                           ; 9E33 20 9F 9E  ..
        bcc     L9E4F                           ; 9E36 90 17    ..
        lda     #$20                            ; 9E38 A9 20    . 
        jsr     L9D30                           ; 9E3A 20 30 9D  0.
        lda     $FCF1,y                         ; 9E3D B9 F1 FC ...
        sta     $FCF5,y                         ; 9E40 99 F5 FC ...
        lda     $FCF2,y                         ; 9E43 B9 F2 FC ...
        sta     $FCF6,y                         ; 9E46 99 F6 FC ...
        lda     $FCF3,y                         ; 9E49 B9 F3 FC ...
        sta     $FCF7,y                         ; 9E4C 99 F7 FC ...
L9E4F:  lda     $FDC3                           ; 9E4F AD C3 FD ...
        ldx     $FDC4                           ; 9E52 AE C4 FD ...
        ldy     $FDC5                           ; 9E55 AC C5 FD ...
        rts                                     ; 9E58 60       `

; ----------------------------------------------------------------------------
L9E59:  lda     $FCF1,y                         ; 9E59 B9 F1 FC ...
        pha                                     ; 9E5C 48       H
        jsr     L9E8D                           ; 9E5D 20 8D 9E  ..
        tya                                     ; 9E60 98       .
        lsr     a                               ; 9E61 4A       J
        lsr     a                               ; 9E62 4A       J
        lsr     a                               ; 9E63 4A       J
        lsr     a                               ; 9E64 4A       J
        lsr     a                               ; 9E65 4A       J
        adc     #$03                            ; 9E66 69 03    i.
        jsr     LBE1D                           ; 9E68 20 1D BE  ..
        pla                                     ; 9E6B 68       h
        tax                                     ; 9E6C AA       .
        rts                                     ; 9E6D 60       `

; ----------------------------------------------------------------------------
L9E6E:  jsr     select_ram_page_001             ; 9E6E 20 0C BE  ..
        ldx     $FDD2                           ; 9E71 AE D2 FD ...
        jsr     select_ram_page_003             ; 9E74 20 16 BE  ..
        sec                                     ; 9E77 38       8
        lda     $FD07,x                         ; 9E78 BD 07 FD ...
        sbc     $FD0F,x                         ; 9E7B FD 0F FD ...
        sta     L00C0                           ; 9E7E 85 C0    ..
        lda     $FD06,x                         ; 9E80 BD 06 FD ...
        sbc     $FD0E,x                         ; 9E83 FD 0E FD ...
        and     #$03                            ; 9E86 29 03    ).
        sta     $C1                             ; 9E88 85 C1    ..
        jmp     select_ram_page_001             ; 9E8A 4C 0C BE L..

; ----------------------------------------------------------------------------
L9E8D:  tya                                     ; 9E8D 98       .
        tax                                     ; 9E8E AA       .
        inc     $FCF1,x                         ; 9E8F FE F1 FC ...
        bne     L9EB6                           ; 9E92 D0 22    ."
        inc     $FCF2,x                         ; 9E94 FE F2 FC ...
        bne     L9E9C                           ; 9E97 D0 03    ..
        inc     $FCF3,x                         ; 9E99 FE F3 FC ...
L9E9C:  jmp     L9D35                           ; 9E9C 4C 35 9D L5.

; ----------------------------------------------------------------------------
L9E9F:  tax                                     ; 9E9F AA       .
        lda     $FCF3,y                         ; 9EA0 B9 F3 FC ...
        cmp     $FCF7,x                         ; 9EA3 DD F7 FC ...
        bne     L9EB6                           ; 9EA6 D0 0E    ..
        lda     $FCF2,y                         ; 9EA8 B9 F2 FC ...
        cmp     $FCF6,x                         ; 9EAB DD F6 FC ...
        bne     L9EB6                           ; 9EAE D0 06    ..
        lda     $FCF1,y                         ; 9EB0 B9 F1 FC ...
        cmp     $FCF5,x                         ; 9EB3 DD F5 FC ...
L9EB6:  rts                                     ; 9EB6 60       `

; ----------------------------------------------------------------------------
L9EB7:  lda     $FCF5,y                         ; 9EB7 B9 F5 FC ...
        cmp     $00,x                           ; 9EBA D5 00    ..
        lda     $FCF6,y                         ; 9EBC B9 F6 FC ...
        sbc     $01,x                           ; 9EBF F5 01    ..
        lda     $FCF7,y                         ; 9EC1 B9 F7 FC ...
        sbc     $02,x                           ; 9EC4 F5 02    ..
        rts                                     ; 9EC6 60       `

; ----------------------------------------------------------------------------
L9EC7:  jsr     push_registers_and_tuck_restoration_thunk; 9EC7 20 4C A8 L.
        stx     $A9                             ; 9ECA 86 A9    ..
        jsr     select_ram_page_003             ; 9ECC 20 16 BE  ..
        lda     $FD05                           ; 9ECF AD 05 FD ...
        sta     L00AA                           ; 9ED2 85 AA    ..
        jsr     LA053                           ; 9ED4 20 53 A0  S.
        tsx                                     ; 9ED7 BA       .
        stx     $B2                             ; 9ED8 86 B2    ..
        jsr     LA0CE                           ; 9EDA 20 CE A0  ..
        bcs     L9EE8                           ; 9EDD B0 09    ..
        jsr     dobrk_with_Disk_prefix          ; 9EDF 20 92 A8  ..
        .byte   $BF                             ; 9EE2 BF       .
        .byte   "full"                          ; 9EE3 66 75 6C 6Cfull
; ----------------------------------------------------------------------------
        brk                                     ; 9EE7 00       .
L9EE8:  jsr     LA0C9                           ; 9EE8 20 C9 A0  ..
        bcc     L9F02                           ; 9EEB 90 15    ..
        sec                                     ; 9EED 38       8
        lda     $CA                             ; 9EEE A5 CA    ..
        sbc     $C8                             ; 9EF0 E5 C8    ..
        sta     $CA                             ; 9EF2 85 CA    ..
        lda     $CB                             ; 9EF4 A5 CB    ..
        sbc     $C9                             ; 9EF6 E5 C9    ..
        sta     $CB                             ; 9EF8 85 CB    ..
        lda     #$00                            ; 9EFA A9 00    ..
        sta     $CC                             ; 9EFC 85 CC    ..
        sta     $CD                             ; 9EFE 85 CD    ..
        beq     L9F0F                           ; 9F00 F0 0D    ..
L9F02:  sec                                     ; 9F02 38       8
        lda     #$00                            ; 9F03 A9 00    ..
        sbc     $C8                             ; 9F05 E5 C8    ..
        sta     $CC                             ; 9F07 85 CC    ..
        lda     #$00                            ; 9F09 A9 00    ..
        sbc     $C9                             ; 9F0B E5 C9    ..
        sta     $CD                             ; 9F0D 85 CD    ..
L9F0F:  lda     $C6                             ; 9F0F A5 C6    ..
        ora     $C7                             ; 9F11 05 C7    ..
        beq     L9F45                           ; 9F13 F0 30    .0
L9F15:  clc                                     ; 9F15 18       .
        lda     $0108,y                         ; 9F16 B9 08 01 ...
        sta     $C6                             ; 9F19 85 C6    ..
        adc     $0106,y                         ; 9F1B 79 06 01 y..
        sta     $C8                             ; 9F1E 85 C8    ..
        lda     $0107,y                         ; 9F20 B9 07 01 ...
        sta     $C7                             ; 9F23 85 C7    ..
        adc     $0105,y                         ; 9F25 79 05 01 y..
        sta     $C9                             ; 9F28 85 C9    ..
        jsr     L9F9E                           ; 9F2A 20 9E 9F  ..
        lda     $FDD0                           ; 9F2D AD D0 FD ...
        sta     $C3                             ; 9F30 85 C3    ..
        jsr     L9FF1                           ; 9F32 20 F1 9F  ..
        lda     $CB                             ; 9F35 A5 CB    ..
        sta     $0105,y                         ; 9F37 99 05 01 ...
        lda     $CA                             ; 9F3A A5 CA    ..
        sta     $0106,y                         ; 9F3C 99 06 01 ...
        jsr     iny_x4                          ; 9F3F 20 AD A9  ..
        dex                                     ; 9F42 CA       .
        bne     L9F15                           ; 9F43 D0 D0    ..
L9F45:  lda     $CC                             ; 9F45 A5 CC    ..
        sta     $C2                             ; 9F47 85 C2    ..
        lda     $CD                             ; 9F49 A5 CD    ..
        sta     $C3                             ; 9F4B 85 C3    ..
        ora     $C2                             ; 9F4D 05 C2    ..
        beq     L9F93                           ; 9F4F F0 42    .B
        jsr     LA0FC                           ; 9F51 20 FC A0  ..
        clc                                     ; 9F54 18       .
        lda     $0106,y                         ; 9F55 B9 06 01 ...
        adc     $0108,y                         ; 9F58 79 08 01 y..
        sta     $CA                             ; 9F5B 85 CA    ..
        lda     $0105,y                         ; 9F5D B9 05 01 ...
        adc     $0107,y                         ; 9F60 79 07 01 y..
        sta     $CB                             ; 9F63 85 CB    ..
L9F65:  lda     $0104,y                         ; 9F65 B9 04 01 ...
        sta     $C6                             ; 9F68 85 C6    ..
        lda     $0103,y                         ; 9F6A B9 03 01 ...
        sta     $C7                             ; 9F6D 85 C7    ..
        lda     $0102,y                         ; 9F6F B9 02 01 ...
        sta     $C8                             ; 9F72 85 C8    ..
        lda     $0101,y                         ; 9F74 B9 01 01 ...
        sta     $C9                             ; 9F77 85 C9    ..
        lda     $CA                             ; 9F79 A5 CA    ..
        sta     $0102,y                         ; 9F7B 99 02 01 ...
        lda     $CB                             ; 9F7E A5 CB    ..
        sta     $0101,y                         ; 9F80 99 01 01 ...
        lda     #$00                            ; 9F83 A9 00    ..
        sta     $C3                             ; 9F85 85 C3    ..
        jsr     L9FF1                           ; 9F87 20 F1 9F  ..
        jsr     L891D                           ; 9F8A 20 1D 89  ..
        jsr     dey_x4                          ; 9F8D 20 B6 A9  ..
        dex                                     ; 9F90 CA       .
        bne     L9F65                           ; 9F91 D0 D2    ..
L9F93:  jsr     L9632                           ; 9F93 20 32 96  2.
        jsr     LA09A                           ; 9F96 20 9A A0  ..
        jsr     L960B                           ; 9F99 20 0B 96  ..
        clc                                     ; 9F9C 18       .
        rts                                     ; 9F9D 60       `

; ----------------------------------------------------------------------------
L9F9E:  jsr     push_registers_and_tuck_restoration_thunk; 9F9E 20 4C A8 L.
        lda     #$00                            ; 9FA1 A9 00    ..
        sta     $BF                             ; 9FA3 85 BF    ..
        sta     $C2                             ; 9FA5 85 C2    ..
L9FA7:  ldy     $C6                             ; 9FA7 A4 C6    ..
        cpy     #$02                            ; 9FA9 C0 02    ..
        lda     $C7                             ; 9FAB A5 C7    ..
        sbc     #$00                            ; 9FAD E9 00    ..
        bcc     L9FB3                           ; 9FAF 90 02    ..
        ldy     #$02                            ; 9FB1 A0 02    ..
L9FB3:  sty     $C3                             ; 9FB3 84 C3    ..
        sec                                     ; 9FB5 38       8
        lda     $C8                             ; 9FB6 A5 C8    ..
        sbc     $C3                             ; 9FB8 E5 C3    ..
        sta     $C5                             ; 9FBA 85 C5    ..
        sta     $C8                             ; 9FBC 85 C8    ..
        lda     $C9                             ; 9FBE A5 C9    ..
        sbc     #$00                            ; 9FC0 E9 00    ..
        sta     $C4                             ; 9FC2 85 C4    ..
        sta     $C9                             ; 9FC4 85 C9    ..
        lda     #$02                            ; 9FC6 A9 02    ..
        sta     $BE                             ; 9FC8 85 BE    ..
        jsr     L959C                           ; 9FCA 20 9C 95  ..
        jsr     L9724                           ; 9FCD 20 24 97  $.
        sec                                     ; 9FD0 38       8
        lda     $CA                             ; 9FD1 A5 CA    ..
        sbc     $C3                             ; 9FD3 E5 C3    ..
        sta     $C5                             ; 9FD5 85 C5    ..
        sta     $CA                             ; 9FD7 85 CA    ..
        lda     $CB                             ; 9FD9 A5 CB    ..
        sbc     #$00                            ; 9FDB E9 00    ..
        sta     $C4                             ; 9FDD 85 C4    ..
        sta     $CB                             ; 9FDF 85 CB    ..
        lda     #$02                            ; 9FE1 A9 02    ..
        sta     $BE                             ; 9FE3 85 BE    ..
        jsr     L959C                           ; 9FE5 20 9C 95  ..
        jsr     L9721                           ; 9FE8 20 21 97  !.
        jsr     L89B4                           ; 9FEB 20 B4 89  ..
        bne     L9FA7                           ; 9FEE D0 B7    ..
        rts                                     ; 9FF0 60       `

; ----------------------------------------------------------------------------
L9FF1:  jsr     push_registers_and_tuck_restoration_thunk; 9FF1 20 4C A8 L.
        ldx     #$00                            ; 9FF4 A2 00    ..
        lda     $FDCE                           ; 9FF6 AD CE FD ...
L9FF9:  asl     a                               ; 9FF9 0A       .
        pha                                     ; 9FFA 48       H
        bcc     LA04C                           ; 9FFB 90 4F    .O
        lda     L9C91,x                         ; 9FFD BD 91 9C ...
        tay                                     ; A000 A8       .
        lda     $FD00,y                         ; A001 B9 00 FD ...
        jsr     LAADB                           ; A004 20 DB AA  ..
        sta     $C2                             ; A007 85 C2    ..
        jsr     LAAD9                           ; A009 20 D9 AA  ..
        cmp     $C2                             ; A00C C5 C2    ..
        bne     LA04C                           ; A00E D0 3C    .<
        lda     $FCEE,y                         ; A010 B9 EE FC ...
        and     #$03                            ; A013 29 03    ).
        cmp     $C9                             ; A015 C5 C9    ..
        bne     LA04C                           ; A017 D0 33    .3
        lda     $FCF0,y                         ; A019 B9 F0 FC ...
        cmp     $C8                             ; A01C C5 C8    ..
        bne     LA04C                           ; A01E D0 2C    .,
        cpy     $C3                             ; A020 C4 C3    ..
        beq     LA04C                           ; A022 F0 28    .(
        lda     $CA                             ; A024 A5 CA    ..
        sta     $FCF0,y                         ; A026 99 F0 FC ...
        sbc     $C8                             ; A029 E5 C8    ..
        sta     $C2                             ; A02B 85 C2    ..
        lda     $CB                             ; A02D A5 CB    ..
        sbc     $C9                             ; A02F E5 C9    ..
        pha                                     ; A031 48       H
        lda     $FCEE,y                         ; A032 B9 EE FC ...
        and     #$FC                            ; A035 29 FC    ).
        ora     $CB                             ; A037 05 CB    ..
        sta     $FCEE,y                         ; A039 99 EE FC ...
        clc                                     ; A03C 18       .
        lda     $C2                             ; A03D A5 C2    ..
        adc     $FCFD,y                         ; A03F 79 FD FC y..
        sta     $FCFD,y                         ; A042 99 FD FC ...
        pla                                     ; A045 68       h
        adc     ram_paging_msb,y                ; A046 79 FE FC y..
        sta     ram_paging_msb,y                ; A049 99 FE FC ...
LA04C:  pla                                     ; A04C 68       h
        inx                                     ; A04D E8       .
        cpx     #$05                            ; A04E E0 05    ..
        bne     L9FF9                           ; A050 D0 A7    ..
        rts                                     ; A052 60       `

; ----------------------------------------------------------------------------
LA053:  pla                                     ; A053 68       h
        sta     L00AE                           ; A054 85 AE    ..
        pla                                     ; A056 68       h
        sta     $AF                             ; A057 85 AF    ..
        jsr     select_ram_page_003             ; A059 20 16 BE  ..
        ldy     $FD05                           ; A05C AC 05 FD ...
        lda     #$00                            ; A05F A9 00    ..
        pha                                     ; A061 48       H
        pha                                     ; A062 48       H
        jsr     LA4F8                           ; A063 20 F8 A4  ..
        pha                                     ; A066 48       H
        lda     #$00                            ; A067 A9 00    ..
        pha                                     ; A069 48       H
        jsr     select_ram_page_003             ; A06A 20 16 BE  ..
LA06D:  lda     $FD04,y                         ; A06D B9 04 FD ...
        cmp     #$01                            ; A070 C9 01    ..
        lda     $FD05,y                         ; A072 B9 05 FD ...
        adc     #$00                            ; A075 69 00    i.
        pha                                     ; A077 48       H
        php                                     ; A078 08       .
        lda     $FD06,y                         ; A079 B9 06 FD ...
        jsr     extract_00xx0000                ; A07C 20 96 A9  ..
        plp                                     ; A07F 28       (
        adc     #$00                            ; A080 69 00    i.
        pha                                     ; A082 48       H
        lda     $FD07,y                         ; A083 B9 07 FD ...
        pha                                     ; A086 48       H
        lda     $FD06,y                         ; A087 B9 06 FD ...
        and     #$03                            ; A08A 29 03    ).
        pha                                     ; A08C 48       H
        jsr     dey_x8                          ; A08D 20 B2 A9  ..
        cpy     #$F8                            ; A090 C0 F8    ..
        bne     LA06D                           ; A092 D0 D9    ..
        jsr     select_ram_page_001             ; A094 20 0C BE  ..
        jmp     LA932                           ; A097 4C 32 A9 L2.

; ----------------------------------------------------------------------------
LA09A:  pla                                     ; A09A 68       h
        sta     L00AE                           ; A09B 85 AE    ..
        pla                                     ; A09D 68       h
        sta     $AF                             ; A09E 85 AF    ..
        jsr     select_ram_page_003             ; A0A0 20 16 BE  ..
        ldy     #$F8                            ; A0A3 A0 F8    ..
LA0A5:  jsr     iny_x8                          ; A0A5 20 A9 A9  ..
        pla                                     ; A0A8 68       h
        eor     $FD06,y                         ; A0A9 59 06 FD Y..
        and     #$03                            ; A0AC 29 03    ).
        eor     $FD06,y                         ; A0AE 59 06 FD Y..
        sta     $FD06,y                         ; A0B1 99 06 FD ...
        pla                                     ; A0B4 68       h
        sta     $FD07,y                         ; A0B5 99 07 FD ...
        pla                                     ; A0B8 68       h
        pla                                     ; A0B9 68       h
        cpy     $FD05                           ; A0BA CC 05 FD ...
        bne     LA0A5                           ; A0BD D0 E6    ..
        pla                                     ; A0BF 68       h
        pla                                     ; A0C0 68       h
        pla                                     ; A0C1 68       h
        pla                                     ; A0C2 68       h
        jsr     select_ram_page_001             ; A0C3 20 0C BE  ..
        jmp     LA932                           ; A0C6 4C 32 A9 L2.

; ----------------------------------------------------------------------------
LA0C9:  lda     $A9                             ; A0C9 A5 A9    ..
        jmp     LA0D0                           ; A0CB 4C D0 A0 L..

; ----------------------------------------------------------------------------
LA0CE:  lda     L00AA                           ; A0CE A5 AA    ..
LA0D0:  lsr     a                               ; A0D0 4A       J
        pha                                     ; A0D1 48       H
        clc                                     ; A0D2 18       .
        adc     $B2                             ; A0D3 65 B2    e.
        tay                                     ; A0D5 A8       .
        pla                                     ; A0D6 68       h
        lsr     a                               ; A0D7 4A       J
        lsr     a                               ; A0D8 4A       J
        sta     $B0                             ; A0D9 85 B0    ..
        inc     $B0                             ; A0DB E6 B0    ..
        ldx     #$00                            ; A0DD A2 00    ..
        stx     $C6                             ; A0DF 86 C6    ..
        stx     $C7                             ; A0E1 86 C7    ..
        beq     LA0E9                           ; A0E3 F0 04    ..
LA0E5:  inx                                     ; A0E5 E8       .
        jsr     dey_x4                          ; A0E6 20 B6 A9  ..
LA0E9:  jsr     LA12C                           ; A0E9 20 2C A1  ,.
        jsr     LA13E                           ; A0EC 20 3E A1  >.
        jsr     LA152                           ; A0EF 20 52 A1  R.
        jsr     LA160                           ; A0F2 20 60 A1  `.
        bcs     LA0FB                           ; A0F5 B0 04    ..
        dec     $B0                             ; A0F7 C6 B0    ..
        bne     LA0E5                           ; A0F9 D0 EA    ..
LA0FB:  rts                                     ; A0FB 60       `

; ----------------------------------------------------------------------------
LA0FC:  lda     $A9                             ; A0FC A5 A9    ..
        lsr     a                               ; A0FE 4A       J
        clc                                     ; A0FF 18       .
        adc     $B2                             ; A100 65 B2    e.
        tay                                     ; A102 A8       .
        sec                                     ; A103 38       8
        lda     L00AA                           ; A104 A5 AA    ..
        sbc     $A9                             ; A106 E5 A9    ..
        lsr     a                               ; A108 4A       J
        lsr     a                               ; A109 4A       J
        lsr     a                               ; A10A 4A       J
        sta     $B0                             ; A10B 85 B0    ..
        inc     $B0                             ; A10D E6 B0    ..
        ldx     #$00                            ; A10F A2 00    ..
        stx     $C6                             ; A111 86 C6    ..
        stx     $C7                             ; A113 86 C7    ..
LA115:  jsr     iny_x4                          ; A115 20 AD A9  ..
        inx                                     ; A118 E8       .
        jsr     LA12C                           ; A119 20 2C A1  ,.
        jsr     LA13E                           ; A11C 20 3E A1  >.
        jsr     LA152                           ; A11F 20 52 A1  R.
        jsr     LA160                           ; A122 20 60 A1  `.
        bcs     LA12B                           ; A125 B0 04    ..
        dec     $B0                             ; A127 C6 B0    ..
        bne     LA115                           ; A129 D0 EA    ..
LA12B:  rts                                     ; A12B 60       `

; ----------------------------------------------------------------------------
LA12C:  clc                                     ; A12C 18       .
        lda     $0106,y                         ; A12D B9 06 01 ...
        adc     $0108,y                         ; A130 79 08 01 y..
        sta     $C4                             ; A133 85 C4    ..
        lda     $0105,y                         ; A135 B9 05 01 ...
        adc     $0107,y                         ; A138 79 07 01 y..
        sta     $C5                             ; A13B 85 C5    ..
        rts                                     ; A13D 60       `

; ----------------------------------------------------------------------------
LA13E:  sec                                     ; A13E 38       8
        lda     $0102,y                         ; A13F B9 02 01 ...
        sta     $CA                             ; A142 85 CA    ..
        sbc     $C4                             ; A144 E5 C4    ..
        sta     $C4                             ; A146 85 C4    ..
        lda     $0101,y                         ; A148 B9 01 01 ...
        sta     $CB                             ; A14B 85 CB    ..
        sbc     $C5                             ; A14D E5 C5    ..
        sta     $C5                             ; A14F 85 C5    ..
        rts                                     ; A151 60       `

; ----------------------------------------------------------------------------
LA152:  clc                                     ; A152 18       .
        lda     $C6                             ; A153 A5 C6    ..
        adc     $C4                             ; A155 65 C4    e.
        sta     $C6                             ; A157 85 C6    ..
        lda     $C7                             ; A159 A5 C7    ..
        adc     $C5                             ; A15B 65 C5    e.
        sta     $C7                             ; A15D 85 C7    ..
        rts                                     ; A15F 60       `

; ----------------------------------------------------------------------------
LA160:  sec                                     ; A160 38       8
        lda     $C6                             ; A161 A5 C6    ..
        sbc     $C2                             ; A163 E5 C2    ..
        sta     $C8                             ; A165 85 C8    ..
        lda     $C7                             ; A167 A5 C7    ..
        sbc     $C3                             ; A169 E5 C3    ..
        sta     $C9                             ; A16B 85 C9    ..
        rts                                     ; A16D 60       `

; ----------------------------------------------------------------------------
chosfile:
        jsr     LA875                           ; A16E 20 75 A8  u.
        jsr     select_ram_page_001             ; A171 20 0C BE  ..
        pha                                     ; A174 48       H
        jsr     L8B32                           ; A175 20 32 8B  2.
        stx     $B0                             ; A178 86 B0    ..
        stx     $FDE4                           ; A17A 8E E4 FD ...
        sty     $B1                             ; A17D 84 B1    ..
        sty     $FDE5                           ; A17F 8C E5 FD ...
        ldx     #$00                            ; A182 A2 00    ..
        ldy     #$00                            ; A184 A0 00    ..
        jsr     L89D2                           ; A186 20 D2 89  ..
LA189:  jsr     L89C2                           ; A189 20 C2 89  ..
        cpy     #$12                            ; A18C C0 12    ..
        bne     LA189                           ; A18E D0 F9    ..
        pla                                     ; A190 68       h
        tax                                     ; A191 AA       .
        inx                                     ; A192 E8       .
        cpx     #$08                            ; A193 E0 08    ..
        bcs     LA19F                           ; A195 B0 08    ..
        lda     osfile_routines_msbs,x          ; A197 BD 3B AE .;.
        pha                                     ; A19A 48       H
        lda     osfile_routines_lsbs,x          ; A19B BD 33 AE .3.
        pha                                     ; A19E 48       H
LA19F:  rts                                     ; A19F 60       `

; ----------------------------------------------------------------------------
osfile_write_metadata:
        lda     #$00                            ; A1A0 A9 00    ..
        sta     L00A8                           ; A1A2 85 A8    ..
        jsr     L93B3                           ; A1A4 20 B3 93  ..
        jsr     LA2D1                           ; A1A7 20 D1 A2  ..
        jsr     L8CF7                           ; A1AA 20 F7 8C  ..
        jmp     L96FE                           ; A1AD 4C FE 96 L..

; ----------------------------------------------------------------------------
osfile_write_load:
        jsr     LA290                           ; A1B0 20 90 A2  ..
        jsr     LA22D                           ; A1B3 20 2D A2  -.
        jsr     LA24C                           ; A1B6 20 4C A2  L.
        bvc     LA1D1                           ; A1B9 50 16    P.
osfile_write_exec:
        jsr     LA290                           ; A1BB 20 90 A2  ..
        jsr     LA22D                           ; A1BE 20 2D A2  -.
        bvc     LA1D4                           ; A1C1 50 11    P.
osfile_write_attr:
        jsr     LA290                           ; A1C3 20 90 A2  ..
        jsr     LA24C                           ; A1C6 20 4C A2  L.
        bvc     LA1D4                           ; A1C9 50 09    P.
osfile_read_metadata:
        jsr     LA2BD                           ; A1CB 20 BD A2  ..
        jsr     LA2AB                           ; A1CE 20 AB A2  ..
LA1D1:  jsr     LA274                           ; A1D1 20 74 A2  t.
LA1D4:  jsr     L9359                           ; A1D4 20 59 93  Y.
        lda     #$01                            ; A1D7 A9 01    ..
        rts                                     ; A1D9 60       `

; ----------------------------------------------------------------------------
osfile_delete:
        jsr     LA2BD                           ; A1DA 20 BD A2  ..
        jsr     L8CF7                           ; A1DD 20 F7 8C  ..
        lda     #$01                            ; A1E0 A9 01    ..
        rts                                     ; A1E2 60       `

; ----------------------------------------------------------------------------
osfile_create:
        jsr     LA290                           ; A1E3 20 90 A2  ..
        jsr     L8CF7                           ; A1E6 20 F7 8C  ..
        jsr     L8C78                           ; A1E9 20 78 8C  x.
        jmp     LA1D4                           ; A1EC 4C D4 A1 L..

; ----------------------------------------------------------------------------
osfile_save:
        jsr     L8B3E                           ; A1EF 20 3E 8B  >.
        jsr     LA2D1                           ; A1F2 20 D1 A2  ..
        jsr     L8CF7                           ; A1F5 20 F7 8C  ..
LA1F8:  sty     $BC                             ; A1F8 84 BC    ..
        ldx     #$00                            ; A1FA A2 00    ..
        lda     L00C0                           ; A1FC A5 C0    ..
        bne     LA206                           ; A1FE D0 06    ..
        iny                                     ; A200 C8       .
        iny                                     ; A201 C8       .
        ldx     #$02                            ; A202 A2 02    ..
        bne     LA214                           ; A204 D0 0E    ..
LA206:  jsr     select_ram_page_003             ; A206 20 16 BE  ..
        lda     $FD0E,y                         ; A209 B9 0E FD ...
        sta     $C4                             ; A20C 85 C4    ..
        jsr     select_ram_page_001             ; A20E 20 0C BE  ..
        jsr     L958D                           ; A211 20 8D 95  ..
LA214:  jsr     select_ram_page_003             ; A214 20 16 BE  ..
LA217:  lda     $FD08,y                         ; A217 B9 08 FD ...
        sta     $BE,x                           ; A21A 95 BE    ..
        iny                                     ; A21C C8       .
        inx                                     ; A21D E8       .
        cpx     #$08                            ; A21E E0 08    ..
        bne     LA217                           ; A220 D0 F5    ..
        jsr     L95AC                           ; A222 20 AC 95  ..
        ldy     $BC                             ; A225 A4 BC    ..
        jsr     L8C9D                           ; A227 20 9D 8C  ..
        jmp     L9704                           ; A22A 4C 04 97 L..

; ----------------------------------------------------------------------------
LA22D:  jsr     push_registers_and_tuck_restoration_thunk; A22D 20 4C A8 L.
        ldy     #$02                            ; A230 A0 02    ..
        lda     ($B0),y                         ; A232 B1 B0    ..
        jsr     select_ram_page_003             ; A234 20 16 BE  ..
        sta     $FD08,x                         ; A237 9D 08 FD ...
        iny                                     ; A23A C8       .
        lda     ($B0),y                         ; A23B B1 B0    ..
        sta     $FD09,x                         ; A23D 9D 09 FD ...
        iny                                     ; A240 C8       .
        lda     ($B0),y                         ; A241 B1 B0    ..
        asl     a                               ; A243 0A       .
        asl     a                               ; A244 0A       .
        eor     $FD0E,x                         ; A245 5D 0E FD ]..
        and     #$0C                            ; A248 29 0C    ).
        bpl     LA26A                           ; A24A 10 1E    ..
LA24C:  jsr     push_registers_and_tuck_restoration_thunk; A24C 20 4C A8 L.
        ldy     #$06                            ; A24F A0 06    ..
        lda     ($B0),y                         ; A251 B1 B0    ..
        jsr     select_ram_page_003             ; A253 20 16 BE  ..
        sta     $FD0A,x                         ; A256 9D 0A FD ...
        iny                                     ; A259 C8       .
        lda     ($B0),y                         ; A25A B1 B0    ..
        sta     $FD0B,x                         ; A25C 9D 0B FD ...
        iny                                     ; A25F C8       .
        lda     ($B0),y                         ; A260 B1 B0    ..
        ror     a                               ; A262 6A       j
        ror     a                               ; A263 6A       j
        ror     a                               ; A264 6A       j
        eor     $FD0E,x                         ; A265 5D 0E FD ]..
        and     #$C0                            ; A268 29 C0    ).
LA26A:  eor     $FD0E,x                         ; A26A 5D 0E FD ]..
        sta     $FD0E,x                         ; A26D 9D 0E FD ...
        clv                                     ; A270 B8       .
        jmp     select_ram_page_001             ; A271 4C 0C BE L..

; ----------------------------------------------------------------------------
LA274:  jsr     push_registers_and_tuck_restoration_thunk; A274 20 4C A8 L.
        ldy     #$0E                            ; A277 A0 0E    ..
        lda     ($B0),y                         ; A279 B1 B0    ..
        and     #$0A                            ; A27B 29 0A    ).
        beq     LA281                           ; A27D F0 02    ..
        lda     #$80                            ; A27F A9 80    ..
LA281:  jsr     select_ram_page_002             ; A281 20 11 BE  ..
        eor     $FD0F,x                         ; A284 5D 0F FD ]..
        and     #$80                            ; A287 29 80    ).
        eor     $FD0F,x                         ; A289 5D 0F FD ]..
        sta     $FD0F,x                         ; A28C 9D 0F FD ...
        rts                                     ; A28F 60       `

; ----------------------------------------------------------------------------
LA290:  jsr     LA2C7                           ; A290 20 C7 A2  ..
        bcc     LA2C2                           ; A293 90 2D    .-
LA295:  jsr     select_ram_page_002             ; A295 20 11 BE  ..
        lda     $FD0F,y                         ; A298 B9 0F FD ...
        bpl     LA2C6                           ; A29B 10 29    .)
LA29D:  jsr     dobrk_with_File_prefix          ; A29D 20 A5 A8  ..
        .byte   $C3                             ; A2A0 C3       .
        .byte   "locked"                        ; A2A1 6C 6F 63 6B 65 64locked
; ----------------------------------------------------------------------------
        brk                                     ; A2A7 00       .
LA2A8:  jsr     LA295                           ; A2A8 20 95 A2  ..
LA2AB:  jsr     push_registers_and_tuck_restoration_thunk; A2AB 20 4C A8 L.
        tya                                     ; A2AE 98       .
        pha                                     ; A2AF 48       H
        ldx     #$08                            ; A2B0 A2 08    ..
        ldy     #$FD                            ; A2B2 A0 FD    ..
        pla                                     ; A2B4 68       h
        jsr     L9B10                           ; A2B5 20 10 9B  ..
        bcc     LA2C6                           ; A2B8 90 0C    ..
        jmp     L9A1B                           ; A2BA 4C 1B 9A L..

; ----------------------------------------------------------------------------
LA2BD:  jsr     LA2C7                           ; A2BD 20 C7 A2  ..
        bcs     LA2C6                           ; A2C0 B0 04    ..
LA2C2:  pla                                     ; A2C2 68       h
        pla                                     ; A2C3 68       h
        lda     #$00                            ; A2C4 A9 00    ..
LA2C6:  rts                                     ; A2C6 60       `

; ----------------------------------------------------------------------------
LA2C7:  jsr     L89E2                           ; A2C7 20 E2 89  ..
        jsr     L8C2E                           ; A2CA 20 2E 8C  ..
        bcc     LA2DB                           ; A2CD 90 0C    ..
        tya                                     ; A2CF 98       .
        tax                                     ; A2D0 AA       .
LA2D1:  lda     $FDE4                           ; A2D1 AD E4 FD ...
        sta     $B0                             ; A2D4 85 B0    ..
        lda     $FDE5                           ; A2D6 AD E5 FD ...
        sta     $B1                             ; A2D9 85 B1    ..
LA2DB:  rts                                     ; A2DB 60       `

; ----------------------------------------------------------------------------
chosgbpb:
        cmp     #$09                            ; A2DC C9 09    ..
        bcs     LA2DB                           ; A2DE B0 FB    ..
        jsr     push_registers_and_tuck_restoration_thunk; A2E0 20 4C A8 L.
        jsr     select_ram_page_001             ; A2E3 20 0C BE  ..
        jsr     LA83F                           ; A2E6 20 3F A8  ?.
        stx     $FDBE                           ; A2E9 8E BE FD ...
        sty     $FDBF                           ; A2EC 8C BF FD ...
        tay                                     ; A2EF A8       .
        jsr     LA2F9                           ; A2F0 20 F9 A2  ..
        php                                     ; A2F3 08       .
        jsr     L96F3                           ; A2F4 20 F3 96  ..
        plp                                     ; A2F7 28       (
        rts                                     ; A2F8 60       `

; ----------------------------------------------------------------------------
LA2F9:  lda     osgbpb_routines_lsbs,y          ; A2F9 B9 43 AE .C.
        sta     LFDE0                           ; A2FC 8D E0 FD ...
        lda     osgbpb_routines_msbs,y          ; A2FF B9 4C AE .L.
        sta     $FDE1                           ; A302 8D E1 FD ...
        lda     osgbpb_routines_flags,y         ; A305 B9 55 AE .U.
        lsr     a                               ; A308 4A       J
        php                                     ; A309 08       .
        lsr     a                               ; A30A 4A       J
        php                                     ; A30B 08       .
        sta     $FDDA                           ; A30C 8D DA FD ...
        jsr     LA4D5                           ; A30F 20 D5 A4  ..
        ldy     #$0C                            ; A312 A0 0C    ..
LA314:  lda     ($B4),y                         ; A314 B1 B4    ..
        sta     $FDA1,y                         ; A316 99 A1 FD ...
        dey                                     ; A319 88       .
        bpl     LA314                           ; A31A 10 F8    ..
        lda     $FDA4                           ; A31C AD A4 FD ...
        and     $FDA5                           ; A31F 2D A5 FD -..
        ora     $FDCD                           ; A322 0D CD FD ...
        clc                                     ; A325 18       .
        adc     #$01                            ; A326 69 01    i.
        beq     LA330                           ; A328 F0 06    ..
        jsr     L96DC                           ; A32A 20 DC 96  ..
        clc                                     ; A32D 18       .
        lda     #$FF                            ; A32E A9 FF    ..
LA330:  sta     $FDDB                           ; A330 8D DB FD ...
        lda     $FDDA                           ; A333 AD DA FD ...
        bcs     LA33F                           ; A336 B0 07    ..
        ldx     #$A2                            ; A338 A2 A2    ..
        ldy     #$FD                            ; A33A A0 FD    ..
        jsr     L0406                           ; A33C 20 06 04  ..
LA33F:  plp                                     ; A33F 28       (
        bcs     LA346                           ; A340 B0 04    ..
        plp                                     ; A342 28       (
LA343:  jmp     (LFDE0)                         ; A343 6C E0 FD l..

; ----------------------------------------------------------------------------
LA346:  ldx     #$03                            ; A346 A2 03    ..
LA348:  lda     $FDAA,x                         ; A348 BD AA FD ...
        sta     $B6,x                           ; A34B 95 B6    ..
        dex                                     ; A34D CA       .
        bpl     LA348                           ; A34E 10 F8    ..
        ldx     #$B6                            ; A350 A2 B6    ..
        ldy     $FDA1                           ; A352 AC A1 FD ...
        lda     #$00                            ; A355 A9 00    ..
        plp                                     ; A357 28       (
        bcs     LA35D                           ; A358 B0 03    ..
        jsr     L9BD8                           ; A35A 20 D8 9B  ..
LA35D:  jsr     L9BB8                           ; A35D 20 B8 9B  ..
        ldx     #$03                            ; A360 A2 03    ..
LA362:  lda     $B6,x                           ; A362 B5 B6    ..
        sta     $FDAA,x                         ; A364 9D AA FD ...
        dex                                     ; A367 CA       .
        bpl     LA362                           ; A368 10 F8    ..
LA36A:  jsr     LA4C7                           ; A36A 20 C7 A4  ..
        bmi     LA37C                           ; A36D 30 0D    0.
LA36F:  ldy     $FDA1                           ; A36F AC A1 FD ...
        jsr     LA343                           ; A372 20 43 A3  C.
        bcs     LA384                           ; A375 B0 0D    ..
        ldx     #$09                            ; A377 A2 09    ..
        jsr     LA4BB                           ; A379 20 BB A4  ..
LA37C:  ldx     #$05                            ; A37C A2 05    ..
        jsr     LA4BB                           ; A37E 20 BB A4  ..
        bne     LA36F                           ; A381 D0 EC    ..
        clc                                     ; A383 18       .
LA384:  php                                     ; A384 08       .
        jsr     LA4C7                           ; A385 20 C7 A4  ..
        ldx     #$05                            ; A388 A2 05    ..
        jsr     LA4BB                           ; A38A 20 BB A4  ..
        ldy     #$0C                            ; A38D A0 0C    ..
        jsr     LA4D5                           ; A38F 20 D5 A4  ..
LA392:  lda     $FDA1,y                         ; A392 B9 A1 FD ...
        sta     ($B4),y                         ; A395 91 B4    ..
        dey                                     ; A397 88       .
        bpl     LA392                           ; A398 10 F8    ..
        plp                                     ; A39A 28       (
osgbpb_done:
        rts                                     ; A39B 60       `

; ----------------------------------------------------------------------------
osgbpb_pb:
        jsr     LA46D                           ; A39C 20 6D A4  m.
        jsr     chosbput                        ; A39F 20 9E 9D  ..
        clc                                     ; A3A2 18       .
        rts                                     ; A3A3 60       `

; ----------------------------------------------------------------------------
osgbpb_gb:
        jsr     chosbget                        ; A3A4 20 D1 9C  ..
        bcs     osgbpb_done                     ; A3A7 B0 F2    ..
        jmp     LA4A4                           ; A3A9 4C A4 A4 L..

; ----------------------------------------------------------------------------
osgbpb_get_media_metadata:
        jsr     LAA1E                           ; A3AC 20 1E AA  ..
        jsr     L961F                           ; A3AF 20 1F 96  ..
        lda     #$0C                            ; A3B2 A9 0C    ..
        jsr     LA4A4                           ; A3B4 20 A4 A4  ..
        ldy     #$00                            ; A3B7 A0 00    ..
LA3B9:  jsr     select_ram_page_002             ; A3B9 20 11 BE  ..
        lda     $FD00,y                         ; A3BC B9 00 FD ...
        jsr     LA4A4                           ; A3BF 20 A4 A4  ..
        iny                                     ; A3C2 C8       .
        cpy     #$08                            ; A3C3 C0 08    ..
        bne     LA3B9                           ; A3C5 D0 F2    ..
LA3C7:  jsr     select_ram_page_003             ; A3C7 20 16 BE  ..
        lda     fdc_status_or_cmd,y             ; A3CA B9 F8 FC ...
        jsr     LA4A4                           ; A3CD 20 A4 A4  ..
        iny                                     ; A3D0 C8       .
        cpy     #$0C                            ; A3D1 C0 0C    ..
        bne     LA3C7                           ; A3D3 D0 F2    ..
        jsr     select_ram_page_003             ; A3D5 20 16 BE  ..
        lda     $FD06                           ; A3D8 AD 06 FD ...
        jsr     lsr_x4                          ; A3DB 20 9E A9  ..
        jmp     LA4A4                           ; A3DE 4C A4 A4 L..

; ----------------------------------------------------------------------------
osgbpb_read_cur_dir:
        lda     $FDC7                           ; A3E1 AD C7 FD ...
        jsr     LA480                           ; A3E4 20 80 A4  ..
        jsr     LA4A2                           ; A3E7 20 A2 A4  ..
        lda     $FDC6                           ; A3EA AD C6 FD ...
        jmp     LA4A4                           ; A3ED 4C A4 A4 L..

; ----------------------------------------------------------------------------
osgbpb_read_lib_dir:
        lda     $FDC9                           ; A3F0 AD C9 FD ...
        jsr     LA480                           ; A3F3 20 80 A4  ..
        jsr     LA4A2                           ; A3F6 20 A2 A4  ..
        lda     $FDC8                           ; A3F9 AD C8 FD ...
        jmp     LA4A4                           ; A3FC 4C A4 A4 L..

; ----------------------------------------------------------------------------
osgbpb_read_names:
        jsr     LAA1E                           ; A3FF 20 1E AA  ..
        jsr     L961F                           ; A402 20 1F 96  ..
        lda     #$12                            ; A405 A9 12    ..
        sta     LFDE0                           ; A407 8D E0 FD ...
        lda     #$A4                            ; A40A A9 A4    ..
        sta     $FDE1                           ; A40C 8D E1 FD ...
        jmp     LA36A                           ; A40F 4C 6A A3 Lj.

; ----------------------------------------------------------------------------
        jsr     select_ram_page_001             ; A412 20 0C BE  ..
        ldy     $FDAA                           ; A415 AC AA FD ...
LA418:  jsr     select_ram_page_003             ; A418 20 16 BE  ..
        cpy     $FD05                           ; A41B CC 05 FD ...
        bcs     LA44E                           ; A41E B0 2E    ..
        jsr     select_ram_page_002             ; A420 20 11 BE  ..
        lda     $FD0F,y                         ; A423 B9 0F FD ...
        jsr     isalpha                         ; A426 20 D1 A9  ..
        eor     $CE                             ; A429 45 CE    E.
        bcs     LA42F                           ; A42B B0 02    ..
        and     #$DF                            ; A42D 29 DF    ).
LA42F:  and     #$7F                            ; A42F 29 7F    ).
        beq     LA438                           ; A431 F0 05    ..
        jsr     iny_x8                          ; A433 20 A9 A9  ..
        bne     LA418                           ; A436 D0 E0    ..
LA438:  lda     #$07                            ; A438 A9 07    ..
        jsr     LA4A4                           ; A43A 20 A4 A4  ..
        sta     $B0                             ; A43D 85 B0    ..
LA43F:  jsr     select_ram_page_002             ; A43F 20 11 BE  ..
        lda     $FD08,y                         ; A442 B9 08 FD ...
        jsr     LA4A4                           ; A445 20 A4 A4  ..
        iny                                     ; A448 C8       .
        dec     $B0                             ; A449 C6 B0    ..
        bne     LA43F                           ; A44B D0 F2    ..
        clc                                     ; A44D 18       .
LA44E:  jsr     select_ram_page_003             ; A44E 20 16 BE  ..
        lda     $FD04                           ; A451 AD 04 FD ...
        jsr     select_ram_page_001             ; A454 20 0C BE  ..
        sty     $FDAA                           ; A457 8C AA FD ...
        sta     $FDA1                           ; A45A 8D A1 FD ...
        rts                                     ; A45D 60       `

; ----------------------------------------------------------------------------
LA45E:  pha                                     ; A45E 48       H
        lda     $FDA2                           ; A45F AD A2 FD ...
        sta     $B8                             ; A462 85 B8    ..
        lda     $FDA3                           ; A464 AD A3 FD ...
        sta     $B9                             ; A467 85 B9    ..
        ldx     #$00                            ; A469 A2 00    ..
        pla                                     ; A46B 68       h
        rts                                     ; A46C 60       `

; ----------------------------------------------------------------------------
LA46D:  bit     $FDDB                           ; A46D 2C DB FD ,..
        bpl     LA478                           ; A470 10 06    ..
        lda     $FEE5                           ; A472 AD E5 FE ...
        jmp     LA4B6                           ; A475 4C B6 A4 L..

; ----------------------------------------------------------------------------
LA478:  jsr     LA45E                           ; A478 20 5E A4  ^.
        lda     ($B8,x)                         ; A47B A1 B8    ..
        jmp     LA4B6                           ; A47D 4C B6 A4 L..

; ----------------------------------------------------------------------------
LA480:  pha                                     ; A480 48       H
        ldy     #$01                            ; A481 A0 01    ..
        and     #$F0                            ; A483 29 F0    ).
        beq     LA488                           ; A485 F0 01    ..
        iny                                     ; A487 C8       .
LA488:  tya                                     ; A488 98       .
        jsr     LA4A4                           ; A489 20 A4 A4  ..
        pla                                     ; A48C 68       h
        pha                                     ; A48D 48       H
        and     #$0F                            ; A48E 29 0F    ).
        clc                                     ; A490 18       .
        adc     #$30                            ; A491 69 30    i0
        jsr     LA4A4                           ; A493 20 A4 A4  ..
        pla                                     ; A496 68       h
        jsr     lsr_x4                          ; A497 20 9E A9  ..
        beq     LA4DF                           ; A49A F0 43    .C
        clc                                     ; A49C 18       .
        adc     #$41                            ; A49D 69 41    iA
        jmp     LA4A4                           ; A49F 4C A4 A4 L..

; ----------------------------------------------------------------------------
LA4A2:  lda     #$01                            ; A4A2 A9 01    ..
LA4A4:  jsr     select_ram_page_001             ; A4A4 20 0C BE  ..
        bit     $FDDB                           ; A4A7 2C DB FD ,..
        bpl     LA4B1                           ; A4AA 10 05    ..
        sta     $FEE5                           ; A4AC 8D E5 FE ...
        bmi     LA4B6                           ; A4AF 30 05    0.
LA4B1:  jsr     LA45E                           ; A4B1 20 5E A4  ^.
        sta     ($B8,x)                         ; A4B4 81 B8    ..
LA4B6:  jsr     push_registers_and_tuck_restoration_thunk; A4B6 20 4C A8 L.
        ldx     #$01                            ; A4B9 A2 01    ..
LA4BB:  ldy     #$04                            ; A4BB A0 04    ..
LA4BD:  inc     $FDA1,x                         ; A4BD FE A1 FD ...
        bne     LA4C6                           ; A4C0 D0 04    ..
        inx                                     ; A4C2 E8       .
        dey                                     ; A4C3 88       .
        bne     LA4BD                           ; A4C4 D0 F7    ..
LA4C6:  rts                                     ; A4C6 60       `

; ----------------------------------------------------------------------------
LA4C7:  ldx     #$03                            ; A4C7 A2 03    ..
LA4C9:  lda     #$FF                            ; A4C9 A9 FF    ..
        eor     $FDA6,x                         ; A4CB 5D A6 FD ]..
        sta     $FDA6,x                         ; A4CE 9D A6 FD ...
        dex                                     ; A4D1 CA       .
        bpl     LA4C9                           ; A4D2 10 F5    ..
        rts                                     ; A4D4 60       `

; ----------------------------------------------------------------------------
LA4D5:  lda     $FDBE                           ; A4D5 AD BE FD ...
        sta     $B4                             ; A4D8 85 B4    ..
        lda     $FDBF                           ; A4DA AD BF FD ...
        sta     $B5                             ; A4DD 85 B5    ..
LA4DF:  rts                                     ; A4DF 60       `

; ----------------------------------------------------------------------------
LA4E0:  bit     $FDCC                           ; A4E0 2C CC FD ,..
        bmi     LA4E8                           ; A4E3 30 03    0.
        sta     ($A6),y                         ; A4E5 91 A6    ..
        rts                                     ; A4E7 60       `

; ----------------------------------------------------------------------------
LA4E8:  sta     $FEE5                           ; A4E8 8D E5 FE ...
        rts                                     ; A4EB 60       `

; ----------------------------------------------------------------------------
LA4EC:  bit     $FDCC                           ; A4EC 2C CC FD ,..
        bmi     LA4F4                           ; A4EF 30 03    0.
        lda     ($A6),y                         ; A4F1 B1 A6    ..
        rts                                     ; A4F3 60       `

; ----------------------------------------------------------------------------
LA4F4:  lda     $FEE5                           ; A4F4 AD E5 FE ...
        rts                                     ; A4F7 60       `

; ----------------------------------------------------------------------------
LA4F8:  jsr     select_ram_page_001             ; A4F8 20 0C BE  ..
        jsr     LB74C                           ; A4FB 20 4C B7  L.
        beq     LA507                           ; A4FE F0 07    ..
        lda     #$00                            ; A500 A9 00    ..
        bit     $FDED                           ; A502 2C ED FD ,..
        bvs     LA509                           ; A505 70 02    p.
LA507:  lda     #$02                            ; A507 A9 02    ..
LA509:  rts                                     ; A509 60       `

; ----------------------------------------------------------------------------
LA50A:  jsr     select_ram_page_001             ; A50A 20 0C BE  ..
        lda     #$83                            ; A50D A9 83    ..
        jsr     osbyte                          ; A50F 20 F4 FF  ..
        sty     $FDD5                           ; A512 8C D5 FD ...
        lda     #$84                            ; A515 A9 84    ..
        jsr     osbyte                          ; A517 20 F4 FF  ..
        tya                                     ; A51A 98       .
        sta     $FDD6                           ; A51B 8D D6 FD ...
        sec                                     ; A51E 38       8
        sbc     $FDD5                           ; A51F ED D5 FD ...
        sta     $FDD7                           ; A522 8D D7 FD ...
        rts                                     ; A525 60       `

; ----------------------------------------------------------------------------
utils_help:
        ldx     #$48                            ; A526 A2 48    .H
        ldy     #$91                            ; A528 A0 91    ..
        lda     #$08                            ; A52A A9 08    ..
        bne     LA534                           ; A52C D0 06    ..
chal_help:
        ldx     #$B4                            ; A52E A2 B4    ..
        ldy     #$90                            ; A530 A0 90    ..
        lda     #$12                            ; A532 A9 12    ..
LA534:  jsr     init_lda_abx_thunk              ; A534 20 1E 92  ..
        sta     $B8                             ; A537 85 B8    ..
        jsr     L8469                           ; A539 20 69 84  i.
        clc                                     ; A53C 18       .
        jsr     print_CHALLENGER                ; A53D 20 5E AE  ^.
        jsr     print_string_nterm              ; A540 20 D3 A8  ..
        .byte   "(C) SLOGGER 1987"              ; A543 28 43 29 20 53 4C 4F 47(C) SLOG
                                                ; A54B 47 45 52 20 31 39 38 37GER 1987
        .byte   $0D                             ; A553 0D       .
; ----------------------------------------------------------------------------
        nop                                     ; A554 EA       .
        ldx     #$00                            ; A555 A2 00    ..
LA557:  jsr     print_2_spaces_without_spool    ; A557 20 15 A8  ..
        jsr     LA57E                           ; A55A 20 7E A5  ~.
        jsr     L8469                           ; A55D 20 69 84  i.
        dec     $B8                             ; A560 C6 B8    ..
        bne     LA557                           ; A562 D0 F3    ..
        rts                                     ; A564 60       `

; ----------------------------------------------------------------------------
LA565:  jsr     gsinit_with_carry_clear         ; A565 20 F2 A9  ..
        beq     LA56B                           ; A568 F0 01    ..
        rts                                     ; A56A 60       `

; ----------------------------------------------------------------------------
LA56B:  jsr     print_string_2_nterm            ; A56B 20 AD A8  ..
        .byte   $DC                             ; A56E DC       .
        .byte   "Syntax: "                      ; A56F 53 79 6E 74 61 78 3A 20Syntax: 
; ----------------------------------------------------------------------------
        nop                                     ; A577 EA       .
        jsr     LA57E                           ; A578 20 7E A5  ~.
        jmp     LA8F8                           ; A57B 4C F8 A8 L..

; ----------------------------------------------------------------------------
LA57E:  jsr     push_registers_and_tuck_restoration_thunk; A57E 20 4C A8 L.
        ldx     #$00                            ; A581 A2 00    ..
        ldy     #$09                            ; A583 A0 09    ..
LA585:  jsr     L00AA                           ; A585 20 AA 00  ..
        bmi     LA592                           ; A588 30 08    0.
        jsr     print_char_without_spool        ; A58A 20 51 A9  Q.
        inx                                     ; A58D E8       .
        dey                                     ; A58E 88       .
        jmp     LA585                           ; A58F 4C 85 A5 L..

; ----------------------------------------------------------------------------
LA592:  dey                                     ; A592 88       .
        bmi     LA599                           ; A593 30 04    0.
        iny                                     ; A595 C8       .
        jsr     print_N_spaces_without_spool    ; A596 20 DD 8A  ..
LA599:  inx                                     ; A599 E8       .
        inx                                     ; A59A E8       .
        jsr     L00AA                           ; A59B 20 AA 00  ..
        pha                                     ; A59E 48       H
        inx                                     ; A59F E8       .
        jsr     L922D                           ; A5A0 20 2D 92  -.
        pla                                     ; A5A3 68       h
        jsr     LA5AC                           ; A5A4 20 AC A5  ..
        jsr     lsr_x4                          ; A5A7 20 9E A9  ..
        and     #$07                            ; A5AA 29 07    ).
LA5AC:  jsr     push_registers_and_tuck_restoration_thunk; A5AC 20 4C A8 L.
        and     #$0F                            ; A5AF 29 0F    ).
        beq     LA5D0                           ; A5B1 F0 1D    ..
        tay                                     ; A5B3 A8       .
        lda     #$20                            ; A5B4 A9 20    . 
        jsr     print_char_without_spool        ; A5B6 20 51 A9  Q.
        ldx     #$FF                            ; A5B9 A2 FF    ..
LA5BB:  inx                                     ; A5BB E8       .
        lda     LA5D1,x                         ; A5BC BD D1 A5 ...
        bne     LA5BB                           ; A5BF D0 FA    ..
        dey                                     ; A5C1 88       .
        bne     LA5BB                           ; A5C2 D0 F7    ..
LA5C4:  inx                                     ; A5C4 E8       .
        lda     LA5D1,x                         ; A5C5 BD D1 A5 ...
        beq     LA5D0                           ; A5C8 F0 06    ..
        jsr     print_char_without_spool        ; A5CA 20 51 A9  Q.
        jmp     LA5C4                           ; A5CD 4C C4 A5 L..

; ----------------------------------------------------------------------------
LA5D0:  rts                                     ; A5D0 60       `

; ----------------------------------------------------------------------------
LA5D1:  .byte   $00                             ; A5D1 00       .
        .byte   "<fsp>"                         ; A5D2 3C 66 73 70 3E<fsp>
        .byte   $00                             ; A5D7 00       .
        .byte   "<afsp>"                        ; A5D8 3C 61 66 73 70 3E<afsp>
        .byte   $00                             ; A5DE 00       .
        .byte   "(L)"                           ; A5DF 28 4C 29 (L)
        .byte   $00                             ; A5E2 00       .
        .byte   "<src drv>"                     ; A5E3 3C 73 72 63 20 64 72 76<src drv
                                                ; A5EB 3E       >
        .byte   $00                             ; A5EC 00       .
        .byte   "<dest drv>"                    ; A5ED 3C 64 65 73 74 20 64 72<dest dr
                                                ; A5F5 76 3E    v>
        .byte   $00                             ; A5F7 00       .
        .byte   "<dest drv> <afsp>"             ; A5F8 3C 64 65 73 74 20 64 72<dest dr
                                                ; A600 76 3E 20 3C 61 66 73 70v> <afsp
                                                ; A608 3E       >
        .byte   $00                             ; A609 00       .
        .byte   "<new fsp>"                     ; A60A 3C 6E 65 77 20 66 73 70<new fsp
                                                ; A612 3E       >
        .byte   $00                             ; A613 00       .
        .byte   "<old fsp>"                     ; A614 3C 6F 6C 64 20 66 73 70<old fsp
                                                ; A61C 3E       >
        .byte   $00                             ; A61D 00       .
        .byte   "(<dir>)"                       ; A61E 28 3C 64 69 72 3E 29(<dir>)
        .byte   $00                             ; A625 00       .
        .byte   "(<drv>)"                       ; A626 28 3C 64 72 76 3E 29(<drv>)
        .byte   $00                             ; A62D 00       .
        .byte   "<title>"                       ; A62E 3C 74 69 74 6C 65 3E<title>
        .byte   $00                             ; A635 00       .
; ----------------------------------------------------------------------------
compact_command:
        jsr     LAA16                           ; A636 20 16 AA  ..
        sta     $FDCA                           ; A639 8D CA FD ...
        sta     $FDCB                           ; A63C 8D CB FD ...
        jsr     print_string_nterm              ; A63F 20 D3 A8  ..
        .byte   "Compacting"                    ; A642 43 6F 6D 70 61 63 74 69Compacti
                                                ; A64A 6E 67    ng
; ----------------------------------------------------------------------------
        nop                                     ; A64C EA       .
        jsr     L8EAD                           ; A64D 20 AD 8E  ..
        jsr     L8469                           ; A650 20 69 84  i.
        jsr     L9974                           ; A653 20 74 99  t.
        jsr     LA50A                           ; A656 20 0A A5  ..
        jsr     L962F                           ; A659 20 2F 96  /.
        jsr     L8523                           ; A65C 20 23 85  #.
        jsr     L852A                           ; A65F 20 2A 85  *.
        jsr     select_ram_page_003             ; A662 20 16 BE  ..
        ldy     $FD05                           ; A665 AC 05 FD ...
        sty     $CC                             ; A668 84 CC    ..
        lda     #$00                            ; A66A A9 00    ..
        sta     $CB                             ; A66C 85 CB    ..
        jsr     LA4F8                           ; A66E 20 F8 A4  ..
        sta     $CA                             ; A671 85 CA    ..
LA673:  ldy     $CC                             ; A673 A4 CC    ..
        jsr     dey_x8                          ; A675 20 B2 A9  ..
        cpy     #$F8                            ; A678 C0 F8    ..
        beq     LA6D6                           ; A67A F0 5A    .Z
        sty     $CC                             ; A67C 84 CC    ..
        jsr     L8C9D                           ; A67E 20 9D 8C  ..
        ldy     $CC                             ; A681 A4 CC    ..
        jsr     LA703                           ; A683 20 03 A7  ..
        beq     LA6CE                           ; A686 F0 46    .F
        lda     #$00                            ; A688 A9 00    ..
        sta     $BE                             ; A68A 85 BE    ..
        sta     $C2                             ; A68C 85 C2    ..
        jsr     LA714                           ; A68E 20 14 A7  ..
        jsr     select_ram_page_003             ; A691 20 16 BE  ..
        lda     $FD0F,y                         ; A694 B9 0F FD ...
        sta     $C8                             ; A697 85 C8    ..
        lda     $FD0E,y                         ; A699 B9 0E FD ...
        and     #$03                            ; A69C 29 03    ).
        sta     $C9                             ; A69E 85 C9    ..
        cmp     $CB                             ; A6A0 C5 CB    ..
        bne     LA6B0                           ; A6A2 D0 0C    ..
        lda     $C8                             ; A6A4 A5 C8    ..
        cmp     $CA                             ; A6A6 C5 CA    ..
        bne     LA6B0                           ; A6A8 D0 06    ..
        jsr     LA733                           ; A6AA 20 33 A7  3.
        jmp     LA6CE                           ; A6AD 4C CE A6 L..

; ----------------------------------------------------------------------------
LA6B0:  jsr     select_ram_page_003             ; A6B0 20 16 BE  ..
        lda     $CA                             ; A6B3 A5 CA    ..
        sta     $FD0F,y                         ; A6B5 99 0F FD ...
        lda     $FD0E,y                         ; A6B8 B9 0E FD ...
        and     #$FC                            ; A6BB 29 FC    ).
        ora     $CB                             ; A6BD 05 CB    ..
        sta     $FD0E,y                         ; A6BF 99 0E FD ...
        lda     #$00                            ; A6C2 A9 00    ..
        sta     L00A8                           ; A6C4 85 A8    ..
        sta     $A9                             ; A6C6 85 A9    ..
        jsr     L8948                           ; A6C8 20 48 89  H.
        jsr     L960B                           ; A6CB 20 0B 96  ..
LA6CE:  ldy     $CC                             ; A6CE A4 CC    ..
        jsr     L8CA5                           ; A6D0 20 A5 8C  ..
        jmp     LA673                           ; A6D3 4C 73 A6 Ls.

; ----------------------------------------------------------------------------
LA6D6:  jsr     print_string_nterm              ; A6D6 20 D3 A8  ..
        .byte   "Disk compacted "               ; A6D9 44 69 73 6B 20 63 6F 6DDisk com
                                                ; A6E1 70 61 63 74 65 64 20pacted 
; ----------------------------------------------------------------------------
        nop                                     ; A6E8 EA       .
        sec                                     ; A6E9 38       8
        jsr     select_ram_page_003             ; A6EA 20 16 BE  ..
        lda     $FD07                           ; A6ED AD 07 FD ...
        sbc     $CA                             ; A6F0 E5 CA    ..
        sta     $C6                             ; A6F2 85 C6    ..
        lda     $FD06                           ; A6F4 AD 06 FD ...
        and     #$03                            ; A6F7 29 03    ).
        sbc     $CB                             ; A6F9 E5 CB    ..
        sta     $C7                             ; A6FB 85 C7    ..
        jsr     L8BE0                           ; A6FD 20 E0 8B  ..
        jmp     L88CA                           ; A700 4C CA 88 L..

; ----------------------------------------------------------------------------
LA703:  jsr     select_ram_page_003             ; A703 20 16 BE  ..
        lda     $FD0E,y                         ; A706 B9 0E FD ...
        and     #$30                            ; A709 29 30    )0
        ora     $FD0D,y                         ; A70B 19 0D FD ...
        ora     $FD0C,y                         ; A70E 19 0C FD ...
        jmp     select_ram_page_001             ; A711 4C 0C BE L..

; ----------------------------------------------------------------------------
LA714:  jsr     select_ram_page_003             ; A714 20 16 BE  ..
        clc                                     ; A717 18       .
        lda     $FD0C,y                         ; A718 B9 0C FD ...
        adc     #$FF                            ; A71B 69 FF    i.
        lda     $FD0D,y                         ; A71D B9 0D FD ...
        adc     #$00                            ; A720 69 00    i.
        sta     $C6                             ; A722 85 C6    ..
        lda     $FD0E,y                         ; A724 B9 0E FD ...
        php                                     ; A727 08       .
        jsr     extract_00xx0000                ; A728 20 96 A9  ..
        plp                                     ; A72B 28       (
        adc     #$00                            ; A72C 69 00    i.
        sta     $C7                             ; A72E 85 C7    ..
        jmp     select_ram_page_001             ; A730 4C 0C BE L..

; ----------------------------------------------------------------------------
LA733:  clc                                     ; A733 18       .
        lda     $CA                             ; A734 A5 CA    ..
        adc     $C6                             ; A736 65 C6    e.
        sta     $CA                             ; A738 85 CA    ..
        lda     $CB                             ; A73A A5 CB    ..
        adc     $C7                             ; A73C 65 C7    e.
        sta     $CB                             ; A73E 85 CB    ..
        rts                                     ; A740 60       `

; ----------------------------------------------------------------------------
LA741:  lda     $FDCB                           ; A741 AD CB FD ...
        jsr     LAADB                           ; A744 20 DB AA  ..
        sta     $A9                             ; A747 85 A9    ..
        lda     $FDCA                           ; A749 AD CA FD ...
        jsr     LAADB                           ; A74C 20 DB AA  ..
        cmp     $A9                             ; A74F C5 A9    ..
        bne     LA75A                           ; A751 D0 07    ..
        lda     #$FF                            ; A753 A9 FF    ..
        sta     $A9                             ; A755 85 A9    ..
        sta     L00AA                           ; A757 85 AA    ..
        rts                                     ; A759 60       `

; ----------------------------------------------------------------------------
LA75A:  lda     #$00                            ; A75A A9 00    ..
        sta     $A9                             ; A75C 85 A9    ..
        rts                                     ; A75E 60       `

; ----------------------------------------------------------------------------
LA75F:  jsr     push_registers_and_tuck_restoration_thunk; A75F 20 4C A8 L.
        bit     $FDDF                           ; A762 2C DF FD ,..
        bpl     LA787                           ; A765 10 20    . 
        jsr     print_string_nterm              ; A767 20 D3 A8  ..
        .byte   $0D                             ; A76A 0D       .
        .byte   "Are you sure ? Y/N "           ; A76B 41 72 65 20 79 6F 75 20Are you 
                                                ; A773 73 75 72 65 20 3F 20 59sure ? Y
                                                ; A77B 2F 4E 20 /N 
; ----------------------------------------------------------------------------
        nop                                     ; A77E EA       .
        jsr     L84DE                           ; A77F 20 DE 84  ..
        beq     LA787                           ; A782 F0 03    ..
        ldx     $B8                             ; A784 A6 B8    ..
        txs                                     ; A786 9A       .
LA787:  jmp     L8469                           ; A787 4C 69 84 Li.

; ----------------------------------------------------------------------------
LA78A:  jsr     LA565                           ; A78A 20 65 A5  e.
        jsr     LAA7F                           ; A78D 20 7F AA  ..
        sta     $FDCA                           ; A790 8D CA FD ...
        jsr     LA565                           ; A793 20 65 A5  e.
        jsr     LAA7F                           ; A796 20 7F AA  ..
        sta     $FDCB                           ; A799 8D CB FD ...
        tya                                     ; A79C 98       .
        pha                                     ; A79D 48       H
        jsr     LA741                           ; A79E 20 41 A7  A.
        jsr     LA50A                           ; A7A1 20 0A A5  ..
        jsr     print_string_nterm              ; A7A4 20 D3 A8  ..
        .byte   "Copying from drive "           ; A7A7 43 6F 70 79 69 6E 67 20Copying 
                                                ; A7AF 66 72 6F 6D 20 64 72 69from dri
                                                ; A7B7 76 65 20 ve 
; ----------------------------------------------------------------------------
        lda     $FDCA                           ; A7BA AD CA FD ...
        jsr     L8EB8                           ; A7BD 20 B8 8E  ..
        jsr     print_string_nterm              ; A7C0 20 D3 A8  ..
        .byte   " to drive "                    ; A7C3 20 74 6F 20 64 72 69 76 to driv
                                                ; A7CB 65 20    e 
; ----------------------------------------------------------------------------
        lda     $FDCB                           ; A7CD AD CB FD ...
        jsr     L8EB8                           ; A7D0 20 B8 8E  ..
        jsr     L8469                           ; A7D3 20 69 84  i.
        pla                                     ; A7D6 68       h
        tay                                     ; A7D7 A8       .
        clc                                     ; A7D8 18       .
        rts                                     ; A7D9 60       `

; ----------------------------------------------------------------------------
LA7DA:  sed                                     ; A7DA F8       .
        clc                                     ; A7DB 18       .
        lda     L00A8                           ; A7DC A5 A8    ..
        adc     #$01                            ; A7DE 69 01    i.
        sta     L00A8                           ; A7E0 85 A8    ..
        lda     $A9                             ; A7E2 A5 A9    ..
        adc     #$00                            ; A7E4 69 00    i.
        sta     $A9                             ; A7E6 85 A9    ..
        cld                                     ; A7E8 D8       .
LA7E9:  clc                                     ; A7E9 18       .
        lda     $A9                             ; A7EA A5 A9    ..
        jsr     LA800                           ; A7EC 20 00 A8  ..
        bcs     LA7F2                           ; A7EF B0 01    ..
LA7F1:  clc                                     ; A7F1 18       .
LA7F2:  lda     L00A8                           ; A7F2 A5 A8    ..
        bne     LA800                           ; A7F4 D0 0A    ..
        bcs     LA800                           ; A7F6 B0 08    ..
        jsr     print_space_without_spool       ; A7F8 20 18 A8  ..
        lda     #$00                            ; A7FB A9 00    ..
        jmp     print_hex_nybble                ; A7FD 4C 80 A9 L..

; ----------------------------------------------------------------------------
LA800:  pha                                     ; A800 48       H
        php                                     ; A801 08       .
        jsr     lsr_x4                          ; A802 20 9E A9  ..
        plp                                     ; A805 28       (
        jsr     LA80A                           ; A806 20 0A A8  ..
        pla                                     ; A809 68       h
LA80A:  pha                                     ; A80A 48       H
        pla                                     ; A80B 68       h
        bcs     LA810                           ; A80C B0 02    ..
        beq     print_space_without_spool       ; A80E F0 08    ..
LA810:  jsr     print_hex_nybble                ; A810 20 80 A9  ..
        sec                                     ; A813 38       8
        rts                                     ; A814 60       `

; ----------------------------------------------------------------------------
print_2_spaces_without_spool:
        jsr     print_space_without_spool       ; A815 20 18 A8  ..
print_space_without_spool:
        pha                                     ; A818 48       H
        lda     #$20                            ; A819 A9 20    . 
        jsr     print_char_without_spool        ; A81B 20 51 A9  Q.
        pla                                     ; A81E 68       h
        clc                                     ; A81F 18       .
        rts                                     ; A820 60       `

; ----------------------------------------------------------------------------
LA821:  tsx                                     ; A821 BA       .
        lda     #$00                            ; A822 A9 00    ..
        sta     $0107,x                         ; A824 9D 07 01 ...
        tya                                     ; A827 98       .
        pha                                     ; A828 48       H
        jsr     LA565                           ; A829 20 65 A5  e.
        pla                                     ; A82C 68       h
        tay                                     ; A82D A8       .
        tya                                     ; A82E 98       .
        clc                                     ; A82F 18       .
        adc     $F2                             ; A830 65 F2    e.
        tax                                     ; A832 AA       .
        lda     $F3                             ; A833 A5 F3    ..
        adc     #$00                            ; A835 69 00    i.
        tay                                     ; A837 A8       .
LA838:  lda     #$00                            ; A838 A9 00    ..
        sta     L00A8                           ; A83A 85 A8    ..
        sta     $A9                             ; A83C 85 A9    ..
        rts                                     ; A83E 60       `

; ----------------------------------------------------------------------------
LA83F:  pha                                     ; A83F 48       H
        txa                                     ; A840 8A       .
        pha                                     ; A841 48       H
        tsx                                     ; A842 BA       .
        lda     #$00                            ; A843 A9 00    ..
        sta     $0109,x                         ; A845 9D 09 01 ...
        pla                                     ; A848 68       h
        tax                                     ; A849 AA       .
        pla                                     ; A84A 68       h
        rts                                     ; A84B 60       `

; ----------------------------------------------------------------------------
push_registers_and_tuck_restoration_thunk:
        pha                                     ; A84C 48       H
        txa                                     ; A84D 8A       .
        pha                                     ; A84E 48       H
        tya                                     ; A84F 98       .
        pha                                     ; A850 48       H
        lda     #$A8                            ; A851 A9 A8    ..
        pha                                     ; A853 48       H
        lda     #$6E                            ; A854 A9 6E    .n
        pha                                     ; A856 48       H
LA857:  ldy     #$05                            ; A857 A0 05    ..
LA859:  tsx                                     ; A859 BA       .
        lda     $0107,x                         ; A85A BD 07 01 ...
        pha                                     ; A85D 48       H
        dey                                     ; A85E 88       .
        bne     LA859                           ; A85F D0 F8    ..
        ldy     #$0A                            ; A861 A0 0A    ..
LA863:  lda     $0109,x                         ; A863 BD 09 01 ...
        sta     $010B,x                         ; A866 9D 0B 01 ...
        dex                                     ; A869 CA       .
        dey                                     ; A86A 88       .
        bne     LA863                           ; A86B D0 F6    ..
        pla                                     ; A86D 68       h
        pla                                     ; A86E 68       h
LA86F:  pla                                     ; A86F 68       h
        tay                                     ; A870 A8       .
        pla                                     ; A871 68       h
        tax                                     ; A872 AA       .
        pla                                     ; A873 68       h
        rts                                     ; A874 60       `

; ----------------------------------------------------------------------------
LA875:  pha                                     ; A875 48       H
        txa                                     ; A876 8A       .
        pha                                     ; A877 48       H
        tya                                     ; A878 98       .
        pha                                     ; A879 48       H
        jsr     LA857                           ; A87A 20 57 A8  W.
        tsx                                     ; A87D BA       .
        sta     $0103,x                         ; A87E 9D 03 01 ...
        jmp     LA86F                           ; A881 4C 6F A8 Lo.

; ----------------------------------------------------------------------------
LA884:  jsr     dobrk_with_Disk_prefix          ; A884 20 92 A8  ..
        .byte   $C9                             ; A887 C9       .
        .byte   "read only"                     ; A888 72 65 61 64 20 6F 6E 6Cread onl
                                                ; A890 79       y
; ----------------------------------------------------------------------------
        brk                                     ; A891 00       .
dobrk_with_Disk_prefix:
        jsr     LA8D0                           ; A892 20 D0 A8  ..
        .byte   "Disk "                         ; A895 44 69 73 6B 20Disk 
; ----------------------------------------------------------------------------
        bcc     print_string_2_nterm            ; A89A 90 11    ..
dobrk_with_Bad_prefix:
        jsr     LA8D0                           ; A89C 20 D0 A8  ..
        .byte   "Bad "                          ; A89F 42 61 64 20Bad 
; ----------------------------------------------------------------------------
        bcc     print_string_2_nterm            ; A8A3 90 08    ..
dobrk_with_File_prefix:
        jsr     LA8D0                           ; A8A5 20 D0 A8  ..
        .byte   "File "                         ; A8A8 46 69 6C 65 20File 
; ----------------------------------------------------------------------------
; can't figure out what this bit is...
print_string_2_nterm:
        sta     $B3                             ; A8AD 85 B3    ..
        pla                                     ; A8AF 68       h
        sta     L00AE                           ; A8B0 85 AE    ..
        pla                                     ; A8B2 68       h
        sta     $AF                             ; A8B3 85 AF    ..
        lda     $B3                             ; A8B5 A5 B3    ..
        pha                                     ; A8B7 48       H
        tya                                     ; A8B8 98       .
        pha                                     ; A8B9 48       H
        ldy     #$00                            ; A8BA A0 00    ..
        jsr     inc_AEw                         ; A8BC 20 EB A9  ..
        lda     (L00AE),y                       ; A8BF B1 AE    ..
        sta     $0101                           ; A8C1 8D 01 01 ...
        jsr     set_rom_status_byte_msb         ; A8C4 20 40 A9  @.
        bmi     LA8E2                           ; A8C7 30 19    0.
        lda     #$02                            ; A8C9 A9 02    ..
        sta     L0100                           ; A8CB 8D 00 01 ...
        bne     LA8E2                           ; A8CE D0 12    ..
LA8D0:  jsr     LA93B                           ; A8D0 20 3B A9  ;.
print_string_nterm:
        sta     $B3                             ; A8D3 85 B3    ..
        pla                                     ; A8D5 68       h
        sta     L00AE                           ; A8D6 85 AE    ..
        pla                                     ; A8D8 68       h
        sta     $AF                             ; A8D9 85 AF    ..
        lda     $B3                             ; A8DB A5 B3    ..
        pha                                     ; A8DD 48       H
        tya                                     ; A8DE 98       .
        pha                                     ; A8DF 48       H
        ldy     #$00                            ; A8E0 A0 00    ..
LA8E2:  jsr     inc_AEw                         ; A8E2 20 EB A9  ..
        lda     (L00AE),y                       ; A8E5 B1 AE    ..
        bmi     LA8F1                           ; A8E7 30 08    0.
        beq     LA8F8                           ; A8E9 F0 0D    ..
        jsr     print_char_without_spool        ; A8EB 20 51 A9  Q.
        jmp     LA8E2                           ; A8EE 4C E2 A8 L..

; ----------------------------------------------------------------------------
LA8F1:  pla                                     ; A8F1 68       h
        tay                                     ; A8F2 A8       .
        pla                                     ; A8F3 68       h
        clc                                     ; A8F4 18       .
        jmp     (L00AE)                         ; A8F5 6C AE 00 l..

; ----------------------------------------------------------------------------
LA8F8:  lda     #$00                            ; A8F8 A9 00    ..
        ldx     L0100                           ; A8FA AE 00 01 ...
        sta     L0100,x                         ; A8FD 9D 00 01 ...
        sta     L0100                           ; A900 8D 00 01 ...
        jsr     get_rom_status_byte             ; A903 20 19 82  ..
        and     #$7F                            ; A906 29 7F    ).
        sta     $0DF0,x                         ; A908 9D F0 0D ...
        jsr     L9753                           ; A90B 20 53 97  S.
        jsr     L96F3                           ; A90E 20 F3 96  ..
        jsr     LAD71                           ; A911 20 71 AD  q.
        jmp     L0100                           ; A914 4C 00 01 L..

; ----------------------------------------------------------------------------
print_string_255term:
        pla                                     ; A917 68       h
        sta     L00AE                           ; A918 85 AE    ..
        pla                                     ; A91A 68       h
        sta     $AF                             ; A91B 85 AF    ..
        tya                                     ; A91D 98       .
        pha                                     ; A91E 48       H
        ldy     #$00                            ; A91F A0 00    ..
LA921:  jsr     inc_AEw                         ; A921 20 EB A9  ..
        lda     (L00AE),y                       ; A924 B1 AE    ..
        cmp     #$FF                            ; A926 C9 FF    ..
        beq     LA930                           ; A928 F0 06    ..
        jsr     oswrch                          ; A92A 20 EE FF  ..
        jmp     LA921                           ; A92D 4C 21 A9 L!.

; ----------------------------------------------------------------------------
LA930:  pla                                     ; A930 68       h
        tay                                     ; A931 A8       .
LA932:  jsr     inc_AEw                         ; A932 20 EB A9  ..
        jmp     (L00AE)                         ; A935 6C AE 00 l..

; ----------------------------------------------------------------------------
LA938:  sta     $0101                           ; A938 8D 01 01 ...
LA93B:  lda     #$02                            ; A93B A9 02    ..
        sta     L0100                           ; A93D 8D 00 01 ...
set_rom_status_byte_msb:
        jsr     get_rom_status_byte             ; A940 20 19 82  ..
        php                                     ; A943 08       .
        ora     #$80                            ; A944 09 80    ..
        sta     $0DF0,x                         ; A946 9D F0 0D ...
        plp                                     ; A949 28       (
        rts                                     ; A94A 60       `

; ----------------------------------------------------------------------------
print_N_without_spool:
        lda     #$4E                            ; A94B A9 4E    .N
        bne     print_char_without_spool        ; A94D D0 02    ..
print_dot_without_spool:
        lda     #$2E                            ; A94F A9 2E    ..
; prints char, disabling *SPOOL first
print_char_without_spool:
        jsr     push_registers_and_tuck_restoration_thunk; A951 20 4C A8 L.
        pha                                     ; A954 48       H
        jsr     get_rom_status_byte             ; A955 20 19 82  ..
        bmi     LA96D                           ; A958 30 13    0.
        jsr     osbyte_read_character_destination; A95A 20 DC AD ..
        txa                                     ; A95D 8A       .
        pha                                     ; A95E 48       H
        ora     #$10                            ; A95F 09 10    ..
        jsr     osbyte_select_output_stream_a   ; A961 20 D7 AD  ..
        pla                                     ; A964 68       h
        tax                                     ; A965 AA       .
        pla                                     ; A966 68       h
        jsr     osasci                          ; A967 20 E3 FF  ..
        jmp     osbyte_select_output_stream     ; A96A 4C D8 AD L..

; ----------------------------------------------------------------------------
LA96D:  pla                                     ; A96D 68       h
        ldx     L0100                           ; A96E AE 00 01 ...
        sta     L0100,x                         ; A971 9D 00 01 ...
        inc     L0100                           ; A974 EE 00 01 ...
        rts                                     ; A977 60       `

; ----------------------------------------------------------------------------
print_hex_byte:
        pha                                     ; A978 48       H
        jsr     lsr_x4                          ; A979 20 9E A9  ..
        jsr     print_hex_nybble                ; A97C 20 80 A9  ..
        pla                                     ; A97F 68       h
print_hex_nybble:
        pha                                     ; A980 48       H
        and     #$0F                            ; A981 29 0F    ).
        sed                                     ; A983 F8       .
        clc                                     ; A984 18       .
        adc     #$90                            ; A985 69 90    i.
        adc     #$40                            ; A987 69 40    i@
        cld                                     ; A989 D8       .
        jsr     print_char_without_spool        ; A98A 20 51 A9  Q.
        pla                                     ; A98D 68       h
        rts                                     ; A98E 60       `

; ----------------------------------------------------------------------------
acknowledge_escape:
        lda     #$7E                            ; A98F A9 7E    .~
        jmp     osbyte                          ; A991 4C F4 FF L..

; ----------------------------------------------------------------------------
extract_xx000000:
        lsr     a                               ; A994 4A       J
        lsr     a                               ; A995 4A       J
extract_00xx0000:
        lsr     a                               ; A996 4A       J
        lsr     a                               ; A997 4A       J
extract_0000xx00:
        lsr     a                               ; A998 4A       J
        lsr     a                               ; A999 4A       J
        and     #$03                            ; A99A 29 03    ).
        rts                                     ; A99C 60       `

; ----------------------------------------------------------------------------
lsr_x5: lsr     a                               ; A99D 4A       J
lsr_x4: lsr     a                               ; A99E 4A       J
        lsr     a                               ; A99F 4A       J
        lsr     a                               ; A9A0 4A       J
        lsr     a                               ; A9A1 4A       J
        rts                                     ; A9A2 60       `

; ----------------------------------------------------------------------------
        asl     a                               ; A9A3 0A       .
asl_x4: asl     a                               ; A9A4 0A       .
        asl     a                               ; A9A5 0A       .
        asl     a                               ; A9A6 0A       .
        asl     a                               ; A9A7 0A       .
        rts                                     ; A9A8 60       `

; ----------------------------------------------------------------------------
iny_x8: iny                                     ; A9A9 C8       .
iny_x7: iny                                     ; A9AA C8       .
        iny                                     ; A9AB C8       .
        iny                                     ; A9AC C8       .
iny_x4: iny                                     ; A9AD C8       .
        iny                                     ; A9AE C8       .
        iny                                     ; A9AF C8       .
        iny                                     ; A9B0 C8       .
        rts                                     ; A9B1 60       `

; ----------------------------------------------------------------------------
dey_x8: dey                                     ; A9B2 88       .
        dey                                     ; A9B3 88       .
        dey                                     ; A9B4 88       .
        dey                                     ; A9B5 88       .
dey_x4: dey                                     ; A9B6 88       .
        dey                                     ; A9B7 88       .
        dey                                     ; A9B8 88       .
        dey                                     ; A9B9 88       .
        rts                                     ; A9BA 60       `

; ----------------------------------------------------------------------------
toupper:cmp     #$41                            ; A9BB C9 41    .A
        bcc     toupper_was_nonalpha            ; A9BD 90 0C    ..
        cmp     #$5B                            ; A9BF C9 5B    .[
        bcc     toupper_was_alpha               ; A9C1 90 0A    ..
        cmp     #$61                            ; A9C3 C9 61    .a
        bcc     toupper_was_nonalpha            ; A9C5 90 04    ..
        cmp     #$7B                            ; A9C7 C9 7B    .{
        bcc     toupper_was_alpha               ; A9C9 90 02    ..
toupper_was_nonalpha:
        sec                                     ; A9CB 38       8
        rts                                     ; A9CC 60       `

; ----------------------------------------------------------------------------
toupper_was_alpha:
        and     #$DF                            ; A9CD 29 DF    ).
        clc                                     ; A9CF 18       .
        rts                                     ; A9D0 60       `

; ----------------------------------------------------------------------------
isalpha:pha                                     ; A9D1 48       H
        jsr     toupper                         ; A9D2 20 BB A9  ..
        pla                                     ; A9D5 68       h
        rts                                     ; A9D6 60       `

; ----------------------------------------------------------------------------
        jsr     xtoi                            ; A9D7 20 E1 A9  ..
        bcc     do_sec                          ; A9DA 90 03    ..
        cmp     #$10                            ; A9DC C9 10    ..
        rts                                     ; A9DE 60       `

; ----------------------------------------------------------------------------
do_sec: sec                                     ; A9DF 38       8
        rts                                     ; A9E0 60       `

; ----------------------------------------------------------------------------
xtoi:   cmp     #$41                            ; A9E1 C9 41    .A
        bcc     LA9E7                           ; A9E3 90 02    ..
        sbc     #$07                            ; A9E5 E9 07    ..
LA9E7:  sec                                     ; A9E7 38       8
        sbc     #$30                            ; A9E8 E9 30    .0
        rts                                     ; A9EA 60       `

; ----------------------------------------------------------------------------
inc_AEw:inc     L00AE                           ; A9EB E6 AE    ..
        bne     LA9F1                           ; A9ED D0 02    ..
        inc     $AF                             ; A9EF E6 AF    ..
LA9F1:  rts                                     ; A9F1 60       `

; ----------------------------------------------------------------------------
gsinit_with_carry_clear:
        clc                                     ; A9F2 18       .
        jmp     gsinit                          ; A9F3 4C C2 FF L..

; ----------------------------------------------------------------------------
LA9F6:  jsr     LAABA                           ; A9F6 20 BA AA  ..
        sta     $CF                             ; A9F9 85 CF    ..
        rts                                     ; A9FB 60       `

; ----------------------------------------------------------------------------
LA9FC:  jsr     toupper                         ; A9FC 20 BB A9  ..
        sec                                     ; A9FF 38       8
        sbc     #$41                            ; AA00 E9 41    .A
        bcc     LAA34                           ; AA02 90 30    .0
        cmp     #$08                            ; AA04 C9 08    ..
        bcs     LAA34                           ; AA06 B0 2C    .,
        jsr     asl_x4                          ; AA08 20 A4 A9  ..
        ora     $CF                             ; AA0B 05 CF    ..
        sta     $CF                             ; AA0D 85 CF    ..
        rts                                     ; AA0F 60       `

; ----------------------------------------------------------------------------
        jsr     LA565                           ; AA10 20 65 A5  e.
        jmp     LAA7F                           ; AA13 4C 7F AA L..

; ----------------------------------------------------------------------------
LAA16:  jsr     gsinit_with_carry_clear         ; AA16 20 F2 A9  ..
        beq     LAA26                           ; AA19 F0 0B    ..
        jmp     LAA7F                           ; AA1B 4C 7F AA L..

; ----------------------------------------------------------------------------
LAA1E:  jsr     select_ram_page_001             ; AA1E 20 0C BE  ..
        lda     $FDC6                           ; AA21 AD C6 FD ...
        sta     $CE                             ; AA24 85 CE    ..
LAA26:  lda     $FDC7                           ; AA26 AD C7 FD ...
        sta     $CF                             ; AA29 85 CF    ..
LAA2B:  rts                                     ; AA2B 60       `

; ----------------------------------------------------------------------------
        jsr     LAA16                           ; AA2C 20 16 AA  ..
        jsr     gsinit_with_carry_clear         ; AA2F 20 F2 A9  ..
        beq     LAA2B                           ; AA32 F0 F7    ..
LAA34:  jsr     dobrk_with_Bad_prefix           ; AA34 20 9C A8  ..
        .byte   $CD                             ; AA37 CD       .
        .byte   "drive"                         ; AA38 64 72 69 76 65drive
; ----------------------------------------------------------------------------
        brk                                     ; AA3D 00       .
LAA3E:  jsr     gsread                          ; AA3E 20 C5 FF  ..
        bcs     LAA71                           ; AA41 B0 2E    ..
        cmp     #$3A                            ; AA43 C9 3A    .:
        bne     LAA69                           ; AA45 D0 22    ."
        jsr     gsread                          ; AA47 20 C5 FF  ..
        bcs     LAA34                           ; AA4A B0 E8    ..
        jsr     LA9F6                           ; AA4C 20 F6 A9  ..
        jsr     gsread                          ; AA4F 20 C5 FF  ..
        bcs     LAA71                           ; AA52 B0 1D    ..
        cmp     #$2E                            ; AA54 C9 2E    ..
        beq     LAA64                           ; AA56 F0 0C    ..
        jsr     LA9FC                           ; AA58 20 FC A9  ..
        jsr     gsread                          ; AA5B 20 C5 FF  ..
        bcs     LAA71                           ; AA5E B0 11    ..
        cmp     #$2E                            ; AA60 C9 2E    ..
        bne     LAA34                           ; AA62 D0 D0    ..
LAA64:  jsr     gsread                          ; AA64 20 C5 FF  ..
        bcs     LAA34                           ; AA67 B0 CB    ..
LAA69:  jsr     LAAB0                           ; AA69 20 B0 AA  ..
        jsr     gsread                          ; AA6C 20 C5 FF  ..
        bcc     LAA34                           ; AA6F 90 C3    ..
LAA71:  rts                                     ; AA71 60       `

; ----------------------------------------------------------------------------
LAA72:  jsr     LAA26                           ; AA72 20 26 AA  &.
        ldx     #$00                            ; AA75 A2 00    ..
        jsr     gsread                          ; AA77 20 C5 FF  ..
        bcs     LAA71                           ; AA7A B0 F5    ..
        sec                                     ; AA7C 38       8
        bcs     LAA86                           ; AA7D B0 07    ..
LAA7F:  ldx     #$00                            ; AA7F A2 00    ..
        jsr     gsread                          ; AA81 20 C5 FF  ..
        bcs     LAA71                           ; AA84 B0 EB    ..
LAA86:  php                                     ; AA86 08       .
        cmp     #$3A                            ; AA87 C9 3A    .:
        bne     LAA90                           ; AA89 D0 05    ..
        jsr     gsread                          ; AA8B 20 C5 FF  ..
        bcs     LAA34                           ; AA8E B0 A4    ..
LAA90:  jsr     LA9F6                           ; AA90 20 F6 A9  ..
        ldx     #$02                            ; AA93 A2 02    ..
        jsr     gsread                          ; AA95 20 C5 FF  ..
        bcs     LAAA9                           ; AA98 B0 0F    ..
        plp                                     ; AA9A 28       (
        bcc     LAAA4                           ; AA9B 90 07    ..
        cmp     #$2A                            ; AA9D C9 2A    .*
        bne     LAAA4                           ; AA9F D0 03    ..
        ldx     #$83                            ; AAA1 A2 83    ..
        rts                                     ; AAA3 60       `

; ----------------------------------------------------------------------------
LAAA4:  jsr     LA9FC                           ; AAA4 20 FC A9  ..
        inx                                     ; AAA7 E8       .
        php                                     ; AAA8 08       .
LAAA9:  plp                                     ; AAA9 28       (
        lda     $CF                             ; AAAA A5 CF    ..
        rts                                     ; AAAC 60       `

; ----------------------------------------------------------------------------
        jsr     gsread                          ; AAAD 20 C5 FF  ..
LAAB0:  cmp     #$2A                            ; AAB0 C9 2A    .*
        bne     LAAB6                           ; AAB2 D0 02    ..
        lda     #$23                            ; AAB4 A9 23    .#
LAAB6:  sta     $CE                             ; AAB6 85 CE    ..
        clc                                     ; AAB8 18       .
        rts                                     ; AAB9 60       `

; ----------------------------------------------------------------------------
LAABA:  sec                                     ; AABA 38       8
        sbc     #$30                            ; AABB E9 30    .0
        bcc     LAAD6                           ; AABD 90 17    ..
        pha                                     ; AABF 48       H
        cmp     #$08                            ; AAC0 C9 08    ..
        bcs     LAAD6                           ; AAC2 B0 12    ..
        jsr     LAADB                           ; AAC4 20 DB AA  ..
        cmp     #$05                            ; AAC7 C9 05    ..
        bne     LAAD4                           ; AAC9 D0 09    ..
        jsr     get_rom_status_byte             ; AACB 20 19 82  ..
        and     #$03                            ; AACE 29 03    ).
        cmp     #$02                            ; AAD0 C9 02    ..
        bne     LAAD6                           ; AAD2 D0 02    ..
LAAD4:  pla                                     ; AAD4 68       h
        rts                                     ; AAD5 60       `

; ----------------------------------------------------------------------------
LAAD6:  jmp     LAA34                           ; AAD6 4C 34 AA L4.

; ----------------------------------------------------------------------------
LAAD9:  lda     $CF                             ; AAD9 A5 CF    ..
LAADB:  jsr     LA875                           ; AADB 20 75 A8  u.
        tax                                     ; AADE AA       .
        and     #$F0                            ; AADF 29 F0    ).
        pha                                     ; AAE1 48       H
        txa                                     ; AAE2 8A       .
        and     #$07                            ; AAE3 29 07    ).
        tax                                     ; AAE5 AA       .
        jsr     select_ram_page_000             ; AAE6 20 07 BE  ..
        lda     $FD00,x                         ; AAE9 BD 00 FD ...
        tsx                                     ; AAEC BA       .
        ora     $0101,x                         ; AAED 1D 01 01 ...
        tax                                     ; AAF0 AA       .
        pla                                     ; AAF1 68       h
        txa                                     ; AAF2 8A       .
        jmp     select_ram_page_001             ; AAF3 4C 0C BE L..

; ----------------------------------------------------------------------------
config_command:
        jsr     gsinit_with_carry_clear         ; AAF6 20 F2 A9  ..
        bne     LAB31                           ; AAF9 D0 36    .6
        jsr     print_string_nterm              ; AAFB 20 D3 A8  ..
        .byte   "L drv:"                        ; AAFE 4C 20 64 72 76 3AL drv:
; ----------------------------------------------------------------------------
        ldx     #$00                            ; AB04 A2 00    ..
print_logical_drive_list_loop:
        txa                                     ; AB06 8A       .
        jsr     LAB90                           ; AB07 20 90 AB  ..
        bne     print_logical_drive_list_loop   ; AB0A D0 FA    ..
        jsr     print_string_nterm              ; AB0C 20 D3 A8  ..
        .byte   $0D                             ; AB0F 0D       .
        .byte   "P drv:"                        ; AB10 50 20 64 72 76 3AP drv:
; ----------------------------------------------------------------------------
        ldx     #$00                            ; AB16 A2 00    ..
LAB18:  bit     $FDFF                           ; AB18 2C FF FD ,..
        jsr     select_ram_page_000             ; AB1B 20 07 BE  ..
        lda     $FD00,x                         ; AB1E BD 00 FD ...
        bvc     LAB26                           ; AB21 50 03    P.
        lda     $FD08,x                         ; AB23 BD 08 FD ...
LAB26:  jsr     select_ram_page_001             ; AB26 20 0C BE  ..
        jsr     LAB90                           ; AB29 20 90 AB  ..
        bne     LAB18                           ; AB2C D0 EA    ..
        jmp     L8469                           ; AB2E 4C 69 84 Li.

; ----------------------------------------------------------------------------
LAB31:  cmp     #$52                            ; AB31 C9 52    .R
        beq     reset_current_drive_mappings    ; AB33 F0 35    .5
LAB35:  jsr     gsread                          ; AB35 20 C5 FF  ..
        jsr     LAABA                           ; AB38 20 BA AA  ..
        bit     $FDFF                           ; AB3B 2C FF FD ,..
        bvc     LAB43                           ; AB3E 50 03    P.
        clc                                     ; AB40 18       .
        adc     #$08                            ; AB41 69 08    i.
LAB43:  sta     $B0                             ; AB43 85 B0    ..
        jsr     gsread                          ; AB45 20 C5 FF  ..
        bcs     LAB67                           ; AB48 B0 1D    ..
        cmp     #$3D                            ; AB4A C9 3D    .=
        bne     LAB67                           ; AB4C D0 19    ..
        jsr     gsread                          ; AB4E 20 C5 FF  ..
        bcs     LAB67                           ; AB51 B0 14    ..
        jsr     LAABA                           ; AB53 20 BA AA  ..
        jsr     select_ram_page_000             ; AB56 20 07 BE  ..
        ldx     $B0                             ; AB59 A6 B0    ..
        sta     $FD00,x                         ; AB5B 9D 00 FD ...
        jsr     select_ram_page_001             ; AB5E 20 0C BE  ..
        jsr     gsinit_with_carry_clear         ; AB61 20 F2 A9  ..
        bne     LAB35                           ; AB64 D0 CF    ..
        rts                                     ; AB66 60       `

; ----------------------------------------------------------------------------
LAB67:  jmp     LA56B                           ; AB67 4C 6B A5 Lk.

; ----------------------------------------------------------------------------
reset_current_drive_mappings:
        bit     $FDFF                           ; AB6A 2C FF FD ,..
        bvs     reset_adfs_drive_mappings       ; AB6D 70 12    p.
reset_dfs_drive_mappings:
        jsr     select_ram_page_000             ; AB6F 20 07 BE  ..
        ldx     #$07                            ; AB72 A2 07    ..
LAB74:  txa                                     ; AB74 8A       .
        sta     $FD00,x                         ; AB75 9D 00 FD ...
        dex                                     ; AB78 CA       .
        bpl     LAB74                           ; AB79 10 F9    ..
        jmp     select_ram_page_001             ; AB7B 4C 0C BE L..

; ----------------------------------------------------------------------------
reset_all_drive_mappings:
        jsr     reset_dfs_drive_mappings        ; AB7E 20 6F AB  o.
reset_adfs_drive_mappings:
        jsr     select_ram_page_000             ; AB81 20 07 BE  ..
        ldx     #$07                            ; AB84 A2 07    ..
LAB86:  txa                                     ; AB86 8A       .
        sta     $FD08,x                         ; AB87 9D 08 FD ...
        dex                                     ; AB8A CA       .
        bpl     LAB86                           ; AB8B 10 F9    ..
        jmp     select_ram_page_001             ; AB8D 4C 0C BE L..

; ----------------------------------------------------------------------------
LAB90:  jsr     print_space_without_spool       ; AB90 20 18 A8  ..
        jsr     print_hex_nybble                ; AB93 20 80 A9  ..
        inx                                     ; AB96 E8       .
        cpx     #$08                            ; AB97 E0 08    ..
        rts                                     ; AB99 60       `

; ----------------------------------------------------------------------------
LAB9A:  jsr     select_ram_page_001             ; AB9A 20 0C BE  ..
        lda     $FCEF,y                         ; AB9D B9 EF FC ...
        and     #$7F                            ; ABA0 29 7F    ).
        sta     $CE                             ; ABA2 85 CE    ..
        lda     $FD00,y                         ; ABA4 B9 00 FD ...
        sta     $CF                             ; ABA7 85 CF    ..
        lda     ram_paging_lsb,y                ; ABA9 B9 FF FC ...
        sta     $FDEC                           ; ABAC 8D EC FD ...
        lda     $FCF4,y                         ; ABAF B9 F4 FC ...
        jmp     L850D                           ; ABB2 4C 0D 85 L..

; ----------------------------------------------------------------------------
LABB5:  jsr     select_ram_page_001             ; ABB5 20 0C BE  ..
        jsr     LAD88                           ; ABB8 20 88 AD  ..
        lda     #$00                            ; ABBB A9 00    ..
        sta     $BA                             ; ABBD 85 BA    ..
        sta     $BB                             ; ABBF 85 BB    ..
        jsr     LB74C                           ; ABC1 20 4C B7  L.
        beq     LAC23                           ; ABC4 F0 5D    .]
        jsr     LB916                           ; ABC6 20 16 B9  ..
        lda     $FDE9                           ; ABC9 AD E9 FD ...
        and     #$7F                            ; ABCC 29 7F    ).
        bne     LAC37                           ; ABCE D0 67    .g
        lda     #$00                            ; ABD0 A9 00    ..
        sta     $FDEC                           ; ABD2 8D EC FD ...
        jsr     LAC46                           ; ABD5 20 46 AC  F.
        bit     $FDED                           ; ABD8 2C ED FD ,..
        bvs     LABE0                           ; ABDB 70 03    p.
        jsr     LAC1A                           ; ABDD 20 1A AC  ..
LABE0:  bit     $FDEA                           ; ABE0 2C EA FD ,..
        bpl     LABE8                           ; ABE3 10 03    ..
        jsr     LAC5D                           ; ABE5 20 5D AC  ].
LABE8:  bit     $FDED                           ; ABE8 2C ED FD ,..
        bvc     LAC37                           ; ABEB 50 4A    PJ
        jsr     LB52E                           ; ABED 20 2E B5  ..
        jsr     select_ram_page_002             ; ABF0 20 11 BE  ..
        lda     $FD00                           ; ABF3 AD 00 FD ...
        cmp     #$E5                            ; ABF6 C9 E5    ..
        bne     LABFD                           ; ABF8 D0 03    ..
        jmp     LAC9F                           ; ABFA 4C 9F AC L..

; ----------------------------------------------------------------------------
LABFD:  jsr     LAC3C                           ; ABFD 20 3C AC  <.
        tay                                     ; AC00 A8       .
        lda     $FD08,y                         ; AC01 B9 08 FD ...
        ldy     $FD01                           ; AC04 AC 01 FD ...
        ldx     $FD02                           ; AC07 AE 02 FD ...
        jsr     select_ram_page_001             ; AC0A 20 0C BE  ..
        stx     $FDF6                           ; AC0D 8E F6 FD ...
        sty     $FDF5                           ; AC10 8C F5 FD ...
        sta     $FDEC                           ; AC13 8D EC FD ...
        tax                                     ; AC16 AA       .
        beq     LAC84                           ; AC17 F0 6B    .k
LAC19:  rts                                     ; AC19 60       `

; ----------------------------------------------------------------------------
LAC1A:  lda     $CF                             ; AC1A A5 CF    ..
        and     #$F0                            ; AC1C 29 F0    ).
        beq     LAC19                           ; AC1E F0 F9    ..
        jmp     LAA34                           ; AC20 4C 34 AA L4.

; ----------------------------------------------------------------------------
LAC23:  jsr     LAC1A                           ; AC23 20 1A AC  ..
        lda     $FDED                           ; AC26 AD ED FD ...
        and     #$80                            ; AC29 29 80    ).
        sta     $FDED                           ; AC2B 8D ED FD ...
        lda     #$00                            ; AC2E A9 00    ..
        sta     $FDEB                           ; AC30 8D EB FD ...
        sta     $FDEC                           ; AC33 8D EC FD ...
        rts                                     ; AC36 60       `

; ----------------------------------------------------------------------------
LAC37:  lda     $FDED                           ; AC37 AD ED FD ...
        beq     LAC43                           ; AC3A F0 07    ..
LAC3C:  lda     $CF                             ; AC3C A5 CF    ..
        and     #$F0                            ; AC3E 29 F0    ).
        lsr     a                               ; AC40 4A       J
        lsr     a                               ; AC41 4A       J
        lsr     a                               ; AC42 4A       J
LAC43:  sta     $BB                             ; AC43 85 BB    ..
        rts                                     ; AC45 60       `

; ----------------------------------------------------------------------------
LAC46:  bit     $FDED                           ; AC46 2C ED FD ,..
        bmi     LAC55                           ; AC49 30 0A    0.
        lda     #$0A                            ; AC4B A9 0A    ..
        bvc     LAC51                           ; AC4D 50 02    P.
        lda     #$12                            ; AC4F A9 12    ..
LAC51:  sta     $FDEB                           ; AC51 8D EB FD ...
LAC54:  rts                                     ; AC54 60       `

; ----------------------------------------------------------------------------
LAC55:  jsr     LB95F                           ; AC55 20 5F B9  _.
        beq     LAC54                           ; AC58 F0 FA    ..
        jmp     LBCE3                           ; AC5A 4C E3 BC L..

; ----------------------------------------------------------------------------
LAC5D:  lda     #$00                            ; AC5D A9 00    ..
        sta     $FDEA                           ; AC5F 8D EA FD ...
        lda     #$02                            ; AC62 A9 02    ..
        sta     $BA                             ; AC64 85 BA    ..
        jsr     LB9B2                           ; AC66 20 B2 B9  ..
        ldx     $0D0C                           ; AC69 AE 0C 0D ...
        lda     #$C0                            ; AC6C A9 C0    ..
        dex                                     ; AC6E CA       .
        beq     LAC7C                           ; AC6F F0 0B    ..
        asl     a                               ; AC71 0A       .
        dex                                     ; AC72 CA       .
        beq     LAC7C                           ; AC73 F0 07    ..
        dex                                     ; AC75 CA       .
        dex                                     ; AC76 CA       .
        beq     LACAD                           ; AC77 F0 34    .4
        jmp     LBCAF                           ; AC79 4C AF BC L..

; ----------------------------------------------------------------------------
LAC7C:  sta     $FDEA                           ; AC7C 8D EA FD ...
        lda     #$00                            ; AC7F A9 00    ..
        sta     $BA                             ; AC81 85 BA    ..
        rts                                     ; AC83 60       `

; ----------------------------------------------------------------------------
LAC84:  jsr     print_string_2_nterm            ; AC84 20 AD A8  ..
        .byte   $CD                             ; AC87 CD       .
        .byte   "Volume "                       ; AC88 56 6F 6C 75 6D 65 20Volume 
; ----------------------------------------------------------------------------
        lda     $BB                             ; AC8F A5 BB    ..
        lsr     a                               ; AC91 4A       J
        adc     #$41                            ; AC92 69 41    iA
        jsr     print_char_without_spool        ; AC94 20 51 A9  Q.
        jsr     print_string_nterm              ; AC97 20 D3 A8  ..
        .byte   " n/a"                          ; AC9A 20 6E 2F 61 n/a
        .byte   $00                             ; AC9E 00       .
; ----------------------------------------------------------------------------
LAC9F:  jsr     print_string_2_nterm            ; AC9F 20 AD A8  ..
        .byte   $CD                             ; ACA2 CD       .
        .byte   "No config"                     ; ACA3 4E 6F 20 63 6F 6E 66 69No confi
                                                ; ACAB 67       g
; ----------------------------------------------------------------------------
        brk                                     ; ACAC 00       .
LACAD:  jsr     print_string_2_nterm            ; ACAD 20 AD A8  ..
        .byte   $CD                             ; ACB0 CD       .
        .byte   "80 in 40"                      ; ACB1 38 30 20 69 6E 20 34 3080 in 40
; ----------------------------------------------------------------------------
        brk                                     ; ACB9 00       .
LACBA:  lda     #$80                            ; ACBA A9 80    ..
        .byte   $AE                             ; ACBC AE       .
LACBD:  lda     #$81                            ; ACBD A9 81    ..
        jsr     select_ram_page_001             ; ACBF 20 0C BE  ..
        sta     $FDE9                           ; ACC2 8D E9 FD ...
        ldx     #$03                            ; ACC5 A2 03    ..
LACC7:  jsr     L96A5                           ; ACC7 20 A5 96  ..
        lda     #$10                            ; ACCA A9 10    ..
        sta     $BB                             ; ACCC 85 BB    ..
        lda     #$00                            ; ACCE A9 00    ..
        sta     $BA                             ; ACD0 85 BA    ..
        sta     $A0                             ; ACD2 85 A0    ..
        lda     #$01                            ; ACD4 A9 01    ..
        sta     $A1                             ; ACD6 85 A1    ..
        jsr     LBA18                           ; ACD8 20 18 BA  ..
        beq     LACE3                           ; ACDB F0 06    ..
        dex                                     ; ACDD CA       .
        bne     LACC7                           ; ACDE D0 E7    ..
        jmp     LBCAF                           ; ACE0 4C AF BC L..

; ----------------------------------------------------------------------------
LACE3:  rts                                     ; ACE3 60       `

; ----------------------------------------------------------------------------
LACE4:  jsr     LACF0                           ; ACE4 20 F0 AC  ..
        sta     $FDF3                           ; ACE7 8D F3 FD ...
        bne     LACED                           ; ACEA D0 01    ..
        rts                                     ; ACEC 60       `

; ----------------------------------------------------------------------------
LACED:  jmp     LBCAF                           ; ACED 4C AF BC L..

; ----------------------------------------------------------------------------
LACF0:  jsr     LA875                           ; ACF0 20 75 A8  u.
        lda     #$80                            ; ACF3 A9 80    ..
        sta     $B9                             ; ACF5 85 B9    ..
        ldy     #$03                            ; ACF7 A0 03    ..
LACF9:  lda     $FDEB                           ; ACF9 AD EB FD ...
        php                                     ; ACFC 08       .
        ldx     $A3                             ; ACFD A6 A3    ..
        lda     $A4                             ; ACFF A5 A4    ..
        plp                                     ; AD01 28       (
        beq     LAD1C                           ; AD02 F0 18    ..
        sec                                     ; AD04 38       8
        lda     $FDEB                           ; AD05 AD EB FD ...
        sbc     $BB                             ; AD08 E5 BB    ..
        sta     $A0                             ; AD0A 85 A0    ..
        lda     $A5                             ; AD0C A5 A5    ..
        bne     LAD18                           ; AD0E D0 08    ..
        ldx     $A3                             ; AD10 A6 A3    ..
        lda     $A4                             ; AD12 A5 A4    ..
        cmp     $A0                             ; AD14 C5 A0    ..
        bcc     LAD1C                           ; AD16 90 04    ..
LAD18:  ldx     #$00                            ; AD18 A2 00    ..
        lda     $A0                             ; AD1A A5 A0    ..
LAD1C:  stx     $A0                             ; AD1C 86 A0    ..
        sta     $A1                             ; AD1E 85 A1    ..
        ora     $A0                             ; AD20 05 A0    ..
        beq     LAD6B                           ; AD22 F0 47    .G
        lda     $FDEB                           ; AD24 AD EB FD ...
        beq     LAD35                           ; AD27 F0 0C    ..
        sec                                     ; AD29 38       8
        lda     $BA                             ; AD2A A5 BA    ..
        sbc     #$50                            ; AD2C E9 50    .P
        bcc     LAD35                           ; AD2E 90 05    ..
        sta     $BA                             ; AD30 85 BA    ..
        jsr     LAD9B                           ; AD32 20 9B AD  ..
LAD35:  jsr     LBA18                           ; AD35 20 18 BA  ..
        bne     LAD6C                           ; AD38 D0 32    .2
        inc     $BA                             ; AD3A E6 BA    ..
        sta     $BB                             ; AD3C 85 BB    ..
        ldx     $A1                             ; AD3E A6 A1    ..
        lda     $A0                             ; AD40 A5 A0    ..
        bit     $FDE9                           ; AD42 2C E9 FD ,..
        bpl     LAD4A                           ; AD45 10 03    ..
        txa                                     ; AD47 8A       .
        ldx     #$00                            ; AD48 A2 00    ..
LAD4A:  clc                                     ; AD4A 18       .
        adc     $A6                             ; AD4B 65 A6    e.
        sta     $A6                             ; AD4D 85 A6    ..
        txa                                     ; AD4F 8A       .
        adc     $A7                             ; AD50 65 A7    e.
        sta     $A7                             ; AD52 85 A7    ..
        sec                                     ; AD54 38       8
        lda     $A3                             ; AD55 A5 A3    ..
        sbc     $A0                             ; AD57 E5 A0    ..
        sta     $A3                             ; AD59 85 A3    ..
        lda     $A4                             ; AD5B A5 A4    ..
        sbc     $A1                             ; AD5D E5 A1    ..
        sta     $A4                             ; AD5F 85 A4    ..
        bcs     LAD65                           ; AD61 B0 02    ..
        dec     $A5                             ; AD63 C6 A5    ..
LAD65:  ora     $A3                             ; AD65 05 A3    ..
        ora     $A5                             ; AD67 05 A5    ..
        bne     LACF9                           ; AD69 D0 8E    ..
LAD6B:  rts                                     ; AD6B 60       `

; ----------------------------------------------------------------------------
LAD6C:  dey                                     ; AD6C 88       .
        bne     LACF9                           ; AD6D D0 8A    ..
        tay                                     ; AD6F A8       .
        rts                                     ; AD70 60       `

; ----------------------------------------------------------------------------
LAD71:  lda     $FDDD                           ; AD71 AD DD FD ...
        bpl     LAD82                           ; AD74 10 0C    ..
        cmp     #$FF                            ; AD76 C9 FF    ..
        beq     LAD82                           ; AD78 F0 08    ..
        and     #$7F                            ; AD7A 29 7F    ).
        tay                                     ; AD7C A8       .
        ldx     #$0B                            ; AD7D A2 0B    ..
        jsr     osbyte_rom_service_request      ; AD7F 20 EC AD  ..
LAD82:  lda     #$00                            ; AD82 A9 00    ..
        sta     $FDDD                           ; AD84 8D DD FD ...
        rts                                     ; AD87 60       `

; ----------------------------------------------------------------------------
LAD88:  bit     $FDDD                           ; AD88 2C DD FD ,..
        bmi     LAD9A                           ; AD8B 30 0D    0.
        lda     #$8F                            ; AD8D A9 8F    ..
        ldx     #$0C                            ; AD8F A2 0C    ..
        jsr     osbyte_yff                      ; AD91 20 F4 AD  ..
        tya                                     ; AD94 98       .
        ora     #$80                            ; AD95 09 80    ..
        sta     $FDDD                           ; AD97 8D DD FD ...
LAD9A:  rts                                     ; AD9A 60       `

; ----------------------------------------------------------------------------
LAD9B:  jsr     LAAD9                           ; AD9B 20 D9 AA  ..
        tax                                     ; AD9E AA       .
        jsr     select_ram_page_000             ; AD9F 20 07 BE  ..
        lda     LADB7,x                         ; ADA2 BD B7 AD ...
        ldx     #$07                            ; ADA5 A2 07    ..
LADA7:  cmp     $FD00,x                         ; ADA7 DD 00 FD ...
        beq     LADB2                           ; ADAA F0 06    ..
        dex                                     ; ADAC CA       .
        bpl     LADA7                           ; ADAD 10 F8    ..
        jmp     LAA34                           ; ADAF 4C 34 AA L4.

; ----------------------------------------------------------------------------
LADB2:  stx     $CF                             ; ADB2 86 CF    ..
        jmp     select_ram_page_001             ; ADB4 4C 0C BE L..

; ----------------------------------------------------------------------------
LADB7:  .byte   $02,$03,$FF,$FF,$05             ; ADB7 02 03 FF FF 05.....
LADBC:  .byte   $20,$D9,$AA                     ; ADBC 20 D9 AA  ..
; ----------------------------------------------------------------------------
        jmp     LB905                           ; ADBF 4C 05 B9 L..

; ----------------------------------------------------------------------------
LADC2:  jsr     push_registers_and_tuck_restoration_thunk; ADC2 20 4C A8 L.
        lda     #$0F                            ; ADC5 A9 0F    ..
        ldx     #$01                            ; ADC7 A2 01    ..
        bne     osbyte_y00                      ; ADC9 D0 08    ..
        lda     #$81                            ; ADCB A9 81    ..
        bne     osbyte_x00_y00                  ; ADCD D0 02    ..
        lda     #$C7                            ; ADCF A9 C7    ..
osbyte_x00_y00:
        ldx     #$00                            ; ADD1 A2 00    ..
osbyte_y00:
        ldy     #$00                            ; ADD3 A0 00    ..
        beq     call_osbyte                     ; ADD5 F0 1F    ..
osbyte_select_output_stream_a:
        tax                                     ; ADD7 AA       .
osbyte_select_output_stream:
        lda     #$03                            ; ADD8 A9 03    ..
        bne     call_osbyte                     ; ADDA D0 1A    ..
osbyte_read_character_destination:
        lda     #$EC                            ; ADDC A9 EC    ..
        bne     osbyte_x00_yff                  ; ADDE D0 12    ..
        lda     #$C7                            ; ADE0 A9 C7    ..
        bne     osbyte_x00_yff                  ; ADE2 D0 0E    ..
osbyte_read_tube_presence:
        lda     #$EA                            ; ADE4 A9 EA    ..
        bne     osbyte_x00_yff                  ; ADE6 D0 0A    ..
osbyte_get_rom_pointer_table_address:
        lda     #$A8                            ; ADE8 A9 A8    ..
        bne     osbyte_x00_yff                  ; ADEA D0 06    ..
osbyte_rom_service_request:
        lda     #$8F                            ; ADEC A9 8F    ..
        bne     call_osbyte                     ; ADEE D0 06    ..
osbyte_aff_x00_yff:
        lda     #$FF                            ; ADF0 A9 FF    ..
osbyte_x00_yff:
        ldx     #$00                            ; ADF2 A2 00    ..
osbyte_yff:
        ldy     #$FF                            ; ADF4 A0 FF    ..
call_osbyte:
        jmp     osbyte                          ; ADF6 4C F4 FF L..

; ----------------------------------------------------------------------------
LADF9:  .addr   LFF1B                           ; ADF9 1B FF    ..
        .addr   LFF1E                           ; ADFB 1E FF    ..
        .addr   LFF21                           ; ADFD 21 FF    !.
        .addr   LFF24                           ; ADFF 24 FF    $.
        .addr   LFF27                           ; AE01 27 FF    '.
        .addr   LFF2A                           ; AE03 2A FF    *.
        .addr   LFF2D                           ; AE05 2D FF    -.
        .addr   chosfile                        ; AE07 6E A1    n.
        .addr   chosargs                        ; AE09 62 9B    b.
        .addr   chosbget                        ; AE0B D1 9C    ..
        .addr   chosbput                        ; AE0D 9E 9D    ..
        .addr   chosgbpb                        ; AE0F DC A2    ..
        .addr   chosfind                        ; AE11 61 99    a.
        .addr   chosfsc                         ; AE13 5F 97    _.
; ----------------------------------------------------------------------------
osfsc_routines_lsbs:
        .byte   $74,$07,$1F,$9B,$1F,$AD,$04,$16 ; AE15 74 07 1F 9B 1F AD 04 16t.......
        .byte   $1B,$0A,$18,$1F                 ; AE1D 1B 0A 18 1F....
osfsc_routines_msbs:
        .byte   $97,$98,$98,$98,$98,$98,$99,$99 ; AE21 97 98 98 98 98 98 99 99........
        .byte   $99,$8C,$8C,$98                 ; AE29 99 8C 8C 98....
osargs_y0_routines_lsbs:
        .byte   $A1,$8B,$8E                     ; AE2D A1 8B 8E ...
osargs_y0_routines_msbs:
        .byte   $9B,$9B,$9B                     ; AE30 9B 9B 9B ...
osfile_routines_lsbs:
        .byte   $EE,$9F,$AF,$BA,$C2,$CA,$D9,$E2 ; AE33 EE 9F AF BA C2 CA D9 E2........
osfile_routines_msbs:
        .byte   $A1,$A1,$A1,$A1,$A1,$A1,$A1,$A1 ; AE3B A1 A1 A1 A1 A1 A1 A1 A1........
osgbpb_routines_lsbs:
        .byte   $9B,$9C,$9C,$A4,$A4,$AC,$E1,$F0 ; AE43 9B 9C 9C A4 A4 AC E1 F0........
        .byte   $FF                             ; AE4B FF       .
osgbpb_routines_msbs:
        .byte   $A3,$A3,$A3,$A3,$A3,$A3,$A3,$A3 ; AE4C A3 A3 A3 A3 A3 A3 A3 A3........
        .byte   $A3                             ; AE54 A3       .
osgbpb_routines_flags:
        .byte   $04,$02,$03,$06,$07,$04,$04,$04 ; AE55 04 02 03 06 07 04 04 04........
        .byte   $04                             ; AE5D 04       .
; ----------------------------------------------------------------------------
; if C clear on entry, also print version number
print_CHALLENGER:
        php                                     ; AE5E 08       .
        jsr     print_string_nterm              ; AE5F 20 D3 A8  ..
        .byte   "CHALLENGER "                   ; AE62 43 48 41 4C 4C 45 4E 47CHALLENG
                                                ; AE6A 45 52 20 ER 
; ----------------------------------------------------------------------------
        nop                                     ; AE6D EA       .
        plp                                     ; AE6E 28       (
        bcs     LAE7A                           ; AE6F B0 09    ..
        jsr     print_string_nterm              ; AE71 20 D3 A8  ..
        .byte   "2.00 "                         ; AE74 32 2E 30 30 202.00 
; ----------------------------------------------------------------------------
        nop                                     ; AE79 EA       .
LAE7A:  jsr     get_rom_status_byte             ; AE7A 20 19 82  ..
        and     #$03                            ; AE7D 29 03    ).
        ora     #$04                            ; AE7F 09 04    ..
        tax                                     ; AE81 AA       .
        jsr     print_table_string              ; AE82 20 F7 8F  ..
        jmp     L8469                           ; AE85 4C 69 84 Li.

; ----------------------------------------------------------------------------
format_command:
        jsr     gsinit_with_carry_clear         ; AE88 20 F2 A9  ..
        beq     LAEA4                           ; AE8B F0 17    ..
LAE8D:  jsr     gsread                          ; AE8D 20 C5 FF  ..
        bcc     LAE96                           ; AE90 90 04    ..
        lda     #$0D                            ; AE92 A9 0D    ..
        ldy     #$00                            ; AE94 A0 00    ..
LAE96:  sty     $B7                             ; AE96 84 B7    ..
        tay                                     ; AE98 A8       .
        ldx     #$00                            ; AE99 A2 00    ..
        lda     #$99                            ; AE9B A9 99    ..
        jsr     osbyte                          ; AE9D 20 F4 FF  ..
        ldy     $B7                             ; AEA0 A4 B7    ..
        bne     LAE8D                           ; AEA2 D0 E9    ..
LAEA4:  jsr     LA83F                           ; AEA4 20 3F A8  ?.
        tsx                                     ; AEA7 BA       .
        stx     $B7                             ; AEA8 86 B7    ..
        stx     $B8                             ; AEAA 86 B8    ..
        jsr     L959C                           ; AEAC 20 9C 95  ..
        jsr     LB01D                           ; AEAF 20 1D B0  ..
        jsr     LB2B2                           ; AEB2 20 B2 B2  ..
LAEB5:  jsr     LB2DE                           ; AEB5 20 DE B2  ..
LAEB8:  jsr     print_string_255term            ; AEB8 20 17 A9  ..
        .byte   $1F,$00,$13                     ; AEBB 1F 00 13 ...
        .byte   "Drive number (0-7) "           ; AEBE 44 72 69 76 65 20 6E 75Drive nu
                                                ; AEC6 6D 62 65 72 20 28 30 2Dmber (0-
                                                ; AECE 37 29 20 7) 
        .byte   $FF                             ; AED1 FF       .
; ----------------------------------------------------------------------------
        jsr     LB5CB                           ; AED2 20 CB B5  ..
        sec                                     ; AED5 38       8
        sbc     #$30                            ; AED6 E9 30    .0
        bcc     LAEB8                           ; AED8 90 DE    ..
        cmp     #$08                            ; AEDA C9 08    ..
        bcc     LAEE3                           ; AEDC 90 05    ..
        jsr     LB73C                           ; AEDE 20 3C B7  <.
        bne     LAEB5                           ; AEE1 D0 D2    ..
LAEE3:  sta     $CF                             ; AEE3 85 CF    ..
LAEE5:  ldx     #$AF                            ; AEE5 A2 AF    ..
        ldy     #$AE                            ; AEE7 A0 AE    ..
        jsr     LB021                           ; AEE9 20 21 B0  !.
        jsr     print_string_255term            ; AEEC 20 17 A9  ..
        .byte   $1F,$00,$14                     ; AEEF 1F 00 14 ...
        .byte   "0=40, 1=80 tracks :  "         ; AEF2 30 3D 34 30 2C 20 31 3D0=40, 1=
                                                ; AEFA 38 30 20 74 72 61 63 6B80 track
                                                ; AF02 73 20 3A 20 20s :  
        .byte   $7F,$7F,$FF                     ; AF07 7F 7F FF ...
; ----------------------------------------------------------------------------
        jsr     LB74C                           ; AF0A 20 4C B7  L.
        bne     LAF12                           ; AF0D D0 03    ..
        jmp     LAFB7                           ; AF0F 4C B7 AF L..

; ----------------------------------------------------------------------------
LAF12:  jsr     LB5CB                           ; AF12 20 CB B5  ..
        ldx     #$28                            ; AF15 A2 28    .(
        cmp     #$30                            ; AF17 C9 30    .0
        beq     LAF21                           ; AF19 F0 06    ..
        ldx     #$50                            ; AF1B A2 50    .P
        cmp     #$31                            ; AF1D C9 31    .1
        bne     LAEE5                           ; AF1F D0 C4    ..
LAF21:  stx     L00C0                           ; AF21 86 C0    ..
        ldx     #$50                            ; AF23 A2 50    .P
        lda     $FDEA                           ; AF25 AD EA FD ...
        bpl     LAF2F                           ; AF28 10 05    ..
        and     #$80                            ; AF2A 29 80    ).
        sta     $FDEA                           ; AF2C 8D EA FD ...
LAF2F:  bit     $FDEA                           ; AF2F 2C EA FD ,..
        bvc     LAF36                           ; AF32 50 02    P.
        ldx     #$28                            ; AF34 A2 28    .(
LAF36:  cpx     L00C0                           ; AF36 E4 C0    ..
        bcs     LAF3F                           ; AF38 B0 05    ..
        jsr     LB73C                           ; AF3A 20 3C B7  <.
        bne     LAEE5                           ; AF3D D0 A6    ..
LAF3F:  jsr     LB2DE                           ; AF3F 20 DE B2  ..
LAF42:  jsr     print_string_255term            ; AF42 20 17 A9  ..
        .byte   $1F,$00,$15                     ; AF45 1F 00 15 ...
        .byte   "Density (S/D) "                ; AF48 44 65 6E 73 69 74 79 20Density 
                                                ; AF50 28 53 2F 44 29 20(S/D) 
        .byte   $FF                             ; AF56 FF       .
; ----------------------------------------------------------------------------
        jsr     LB5CB                           ; AF57 20 CB B5  ..
        cmp     #$53                            ; AF5A C9 53    .S
        beq     LAF96                           ; AF5C F0 38    .8
        cmp     #$44                            ; AF5E C9 44    .D
        beq     LAF68                           ; AF60 F0 06    ..
        jsr     LB73C                           ; AF62 20 3C B7  <.
        jmp     LAF42                           ; AF65 4C 42 AF LB.

; ----------------------------------------------------------------------------
LAF68:  lda     $FDED                           ; AF68 AD ED FD ...
        ora     #$40                            ; AF6B 09 40    .@
        sta     $FDED                           ; AF6D 8D ED FD ...
        lda     #$12                            ; AF70 A9 12    ..
        sta     $FDEB                           ; AF72 8D EB FD ...
        jsr     LB65C                           ; AF75 20 5C B6  \.
        bcs     LAF8E                           ; AF78 B0 14    ..
        ldx     L00C0                           ; AF7A A6 C0    ..
        dex                                     ; AF7C CA       .
        stx     $B0                             ; AF7D 86 B0    ..
        jsr     LB552                           ; AF7F 20 52 B5  R.
        jsr     LB412                           ; AF82 20 12 B4  ..
        jsr     LB45E                           ; AF85 20 5E B4  ^.
        jsr     LB477                           ; AF88 20 77 B4  w.
        jsr     LACBD                           ; AF8B 20 BD AC  ..
LAF8E:  jsr     LB035                           ; AF8E 20 35 B0  5.
        beq     LAF68                           ; AF91 F0 D5    ..
        jmp     LB028                           ; AF93 4C 28 B0 L(.

; ----------------------------------------------------------------------------
LAF96:  lda     $FDED                           ; AF96 AD ED FD ...
        and     #$80                            ; AF99 29 80    ).
        sta     $FDED                           ; AF9B 8D ED FD ...
        lda     #$0A                            ; AF9E A9 0A    ..
        sta     $FDEB                           ; AFA0 8D EB FD ...
        jsr     LB65C                           ; AFA3 20 5C B6  \.
        bcs     LAFAF                           ; AFA6 B0 07    ..
        ldx     L00C0                           ; AFA8 A6 C0    ..
        stx     $B0                             ; AFAA 86 B0    ..
        jsr     LB05B                           ; AFAC 20 5B B0  [.
LAFAF:  jsr     LB035                           ; AFAF 20 35 B0  5.
        beq     LAF96                           ; AFB2 F0 E2    ..
        jmp     LB028                           ; AFB4 4C 28 B0 L(.

; ----------------------------------------------------------------------------
LAFB7:  jsr     print_string_255term            ; AFB7 20 17 A9  ..
        .byte   $7F,$7F                         ; AFBA 7F 7F    ..
        .byte   ", 2=Max RAM disk "             ; AFBC 2C 20 32 3D 4D 61 78 20, 2=Max 
                                                ; AFC4 52 41 4D 20 64 69 73 6BRAM disk
                                                ; AFCC 20        
        .byte   $FF                             ; AFCD FF       .
; ----------------------------------------------------------------------------
        jsr     LB5CB                           ; AFCE 20 CB B5  ..
        sec                                     ; AFD1 38       8
        sbc     #$30                            ; AFD2 E9 30    .0
        bcc     LAFF2                           ; AFD4 90 1C    ..
        cmp     #$03                            ; AFD6 C9 03    ..
        bcs     LAFF2                           ; AFD8 B0 18    ..
        pha                                     ; AFDA 48       H
        jsr     LB61B                           ; AFDB 20 1B B6  ..
        pla                                     ; AFDE 68       h
        tax                                     ; AFDF AA       .
        cpx     #$02                            ; AFE0 E0 02    ..
        bne     LAFEC                           ; AFE2 D0 08    ..
        jsr     LAAD9                           ; AFE4 20 D9 AA  ..
        cmp     #$05                            ; AFE7 C9 05    ..
        bne     LAFEC                           ; AFE9 D0 01    ..
        inx                                     ; AFEB E8       .
LAFEC:  jsr     LAFF8                           ; AFEC 20 F8 AF  ..
        jmp     LB028                           ; AFEF 4C 28 B0 L(.

; ----------------------------------------------------------------------------
LAFF2:  jsr     LB73C                           ; AFF2 20 3C B7  <.
        jmp     LAEE5                           ; AFF5 4C E5 AE L..

; ----------------------------------------------------------------------------
LAFF8:  lda     LB015,x                         ; AFF8 BD 15 B0 ...
        sta     $C4                             ; AFFB 85 C4    ..
        lda     LB019,x                         ; AFFD BD 19 B0 ...
        sta     $C5                             ; B000 85 C5    ..
        jsr     LAD88                           ; B002 20 88 AD  ..
        lda     #$00                            ; B005 A9 00    ..
        sta     $FDFE                           ; B007 8D FE FD ...
        sta     $FDED                           ; B00A 8D ED FD ...
        ldy     #$00                            ; B00D A0 00    ..
        jsr     LB062                           ; B00F 20 62 B0  b.
        jmp     LAD71                           ; B012 4C 71 AD Lq.

; ----------------------------------------------------------------------------
LB015:  bcc     LB037                           ; B015 90 20    . 
        sbc     $FF,x                           ; B017 F5 FF    ..
LB019:  ora     ($03,x)                         ; B019 01 03    ..
        .byte   $03                             ; B01B 03       .
        .byte   $03                             ; B01C 03       .
LB01D:  ldx     #$28                            ; B01D A2 28    .(
        ldy     #$B0                            ; B01F A0 B0    ..
LB021:  stx     LFDE6                           ; B021 8E E6 FD ...
        sty     $FDE7                           ; B024 8C E7 FD ...
        rts                                     ; B027 60       `

; ----------------------------------------------------------------------------
LB028:  ldx     $B8                             ; B028 A6 B8    ..
        txs                                     ; B02A 9A       .
        jsr     LB650                           ; B02B 20 50 B6  P.
        ldx     #$00                            ; B02E A2 00    ..
        ldy     #$18                            ; B030 A0 18    ..
        jmp     LB2D1                           ; B032 4C D1 B2 L..

; ----------------------------------------------------------------------------
LB035:  .byte   $20                             ; B035 20        
        .byte   $17                             ; B036 17       .
LB037:  lda     #$1F                            ; B037 A9 1F    ..
        .byte   $08,$10                         ; B039 08 10    ..
        .byte   "Format complete"               ; B03B 46 6F 72 6D 61 74 20 63Format c
                                                ; B043 6F 6D 70 6C 65 74 65omplete
        .byte   $0D,$0A                         ; B04A 0D 0A    ..
        .byte   "Repeat? "                      ; B04C 52 65 70 65 61 74 3F 20Repeat? 
        .byte   $FF                             ; B054 FF       .
; ----------------------------------------------------------------------------
        jsr     LB5EE                           ; B055 20 EE B5  ..
        cmp     #$59                            ; B058 C9 59    .Y
        rts                                     ; B05A 60       `

; ----------------------------------------------------------------------------
LB05B:  jsr     LB552                           ; B05B 20 52 B5  R.
        ldy     #$00                            ; B05E A0 00    ..
        sty     $BA                             ; B060 84 BA    ..
LB062:  jsr     push_registers_and_tuck_restoration_thunk; B062 20 4C A8 L.
        sty     $BB                             ; B065 84 BB    ..
        lda     #$00                            ; B067 A9 00    ..
        sta     $BA                             ; B069 85 BA    ..
        jsr     LB3EA                           ; B06B 20 EA B3  ..
        jsr     select_ram_page_003             ; B06E 20 16 BE  ..
        lda     $C5                             ; B071 A5 C5    ..
        sta     $FD06                           ; B073 8D 06 FD ...
        lda     $C4                             ; B076 A5 C4    ..
        sta     $FD07                           ; B078 8D 07 FD ...
        jmp     L9683                           ; B07B 4C 83 96 L..

; ----------------------------------------------------------------------------
verify_command:
        jsr     LB741                           ; B07E 20 41 B7  A.
        tsx                                     ; B081 BA       .
        stx     $B8                             ; B082 86 B8    ..
        stx     $B7                             ; B084 86 B7    ..
        jsr     LA83F                           ; B086 20 3F A8  ?.
        jsr     L959C                           ; B089 20 9C 95  ..
        jsr     LB01D                           ; B08C 20 1D B0  ..
        jsr     LB758                           ; B08F 20 58 B7  X.
        jsr     print_string_255term            ; B092 20 17 A9  ..
        .byte   "V E R I F Y"                   ; B095 56 20 45 20 52 20 49 20V E R I 
                                                ; B09D 46 20 59 F Y
        .byte   $FF                             ; B0A0 FF       .
; ----------------------------------------------------------------------------
        jsr     print_string_255term            ; B0A1 20 17 A9  ..
        .byte   $1F,$00,$10                     ; B0A4 1F 00 10 ...
        .byte   "Insert disk"                   ; B0A7 49 6E 73 65 72 74 20 64Insert d
                                                ; B0AF 69 73 6B isk
        .byte   $FF                             ; B0B2 FF       .
; ----------------------------------------------------------------------------
        jsr     LB706                           ; B0B3 20 06 B7  ..
        ldx     #$8C                            ; B0B6 A2 8C    ..
        ldy     #$B0                            ; B0B8 A0 B0    ..
        jsr     LB021                           ; B0BA 20 21 B0  !.
        lda     #$00                            ; B0BD A9 00    ..
        sta     $FDE9                           ; B0BF 8D E9 FD ...
        lda     #$80                            ; B0C2 A9 80    ..
        sta     $B9                             ; B0C4 85 B9    ..
        jsr     LABB5                           ; B0C6 20 B5 AB  ..
        bit     $FDED                           ; B0C9 2C ED FD ,..
        bvs     LB0F4                           ; B0CC 70 26    p&
        jsr     L9632                           ; B0CE 20 32 96  2.
        jsr     select_ram_page_003             ; B0D1 20 16 BE  ..
        lda     $FD06                           ; B0D4 AD 06 FD ...
        and     #$03                            ; B0D7 29 03    ).
        sta     $B1                             ; B0D9 85 B1    ..
        lda     $FD07                           ; B0DB AD 07 FD ...
        sta     $B0                             ; B0DE 85 B0    ..
        jsr     select_ram_page_001             ; B0E0 20 0C BE  ..
        lda     #$00                            ; B0E3 A9 00    ..
        sta     $B3                             ; B0E5 85 B3    ..
        lda     $FDEB                           ; B0E7 AD EB FD ...
        sta     $B2                             ; B0EA 85 B2    ..
        jsr     LB35F                           ; B0EC 20 5F B3  _.
        stx     L00C0                           ; B0EF 86 C0    ..
        jmp     LB0FF                           ; B0F1 4C FF B0 L..

; ----------------------------------------------------------------------------
LB0F4:  jsr     LACBA                           ; B0F4 20 BA AC  ..
        jsr     select_ram_page_002             ; B0F7 20 11 BE  ..
        lda     $FD04                           ; B0FA AD 04 FD ...
        sta     L00C0                           ; B0FD 85 C0    ..
LB0FF:  jsr     select_ram_page_001             ; B0FF 20 0C BE  ..
        lda     #$00                            ; B102 A9 00    ..
        sta     $BA                             ; B104 85 BA    ..
        clc                                     ; B106 18       .
LB107:  php                                     ; B107 08       .
        jsr     LB6B3                           ; B108 20 B3 B6  ..
        jsr     LB121                           ; B10B 20 21 B1  !.
        beq     LB113                           ; B10E F0 03    ..
        plp                                     ; B110 28       (
        sec                                     ; B111 38       8
        php                                     ; B112 08       .
LB113:  inc     $BA                             ; B113 E6 BA    ..
        lda     $BA                             ; B115 A5 BA    ..
        cmp     L00C0                           ; B117 C5 C0    ..
        bcc     LB107                           ; B119 90 EC    ..
        plp                                     ; B11B 28       (
        bcs     LB13A                           ; B11C B0 1C    ..
        jmp     LB028                           ; B11E 4C 28 B0 L(.

; ----------------------------------------------------------------------------
LB121:  ldx     #$03                            ; B121 A2 03    ..
        ldy     #$03                            ; B123 A0 03    ..
        jsr     LB72C                           ; B125 20 2C B7  ,.
LB128:  jsr     LB2EA                           ; B128 20 EA B2  ..
        jsr     LBA05                           ; B12B 20 05 BA  ..
        beq     LB139                           ; B12E F0 09    ..
        lda     #$2E                            ; B130 A9 2E    ..
        jsr     oswrch                          ; B132 20 EE FF  ..
        dex                                     ; B135 CA       .
        bne     LB128                           ; B136 D0 F0    ..
        dex                                     ; B138 CA       .
LB139:  rts                                     ; B139 60       `

; ----------------------------------------------------------------------------
LB13A:  jsr     LB60B                           ; B13A 20 0B B6  ..
        jmp     LB028                           ; B13D 4C 28 B0 L(.

; ----------------------------------------------------------------------------
volgen_command:
        jsr     LB741                           ; B140 20 41 B7  A.
        jsr     LA83F                           ; B143 20 3F A8  ?.
        tsx                                     ; B146 BA       .
        stx     $B8                             ; B147 86 B8    ..
        jsr     LA75F                           ; B149 20 5F A7  _.
        jsr     L959C                           ; B14C 20 9C 95  ..
        lda     #$80                            ; B14F A9 80    ..
        sta     $B9                             ; B151 85 B9    ..
        lda     #$00                            ; B153 A9 00    ..
        sta     $FDEC                           ; B155 8D EC FD ...
        sta     $BA                             ; B158 85 BA    ..
        jsr     LB916                           ; B15A 20 16 B9  ..
        jsr     LB279                           ; B15D 20 79 B2  y.
        lda     $CF                             ; B160 A5 CF    ..
        and     #$0F                            ; B162 29 0F    ).
        sta     $CF                             ; B164 85 CF    ..
        jsr     LB758                           ; B166 20 58 B7  X.
        jsr     print_string_255term            ; B169 20 17 A9  ..
        .byte   "V O L G E N"                   ; B16C 56 20 4F 20 4C 20 47 20V O L G 
                                                ; B174 45 20 4E E N
        .byte   $FF                             ; B177 FF       .
; ----------------------------------------------------------------------------
        jsr     print_string_255term            ; B178 20 17 A9  ..
        .byte   $1F,$00,$04,$0D                 ; B17B 1F 00 04 0D....
        .byte   "Vol  Size   (K) "              ; B17F 56 6F 6C 20 20 53 69 7AVol  Siz
                                                ; B187 65 20 20 20 28 4B 29 20e   (K) 
        .byte   $FF                             ; B18F FF       .
; ----------------------------------------------------------------------------
        lda     $CF                             ; B190 A5 CF    ..
        jsr     L8EAD                           ; B192 20 AD 8E  ..
        jsr     print_string_255term            ; B195 20 17 A9  ..
        .byte   $1F,$00,$0F                     ; B198 1F 00 0F ...
        .byte   "Free"                          ; B19B 46 72 65 65Free
        .byte   $FF                             ; B19F FF       .
; ----------------------------------------------------------------------------
        jsr     LB4D2                           ; B1A0 20 D2 B4  ..
        lda     #$07                            ; B1A3 A9 07    ..
        sta     $C1                             ; B1A5 85 C1    ..
LB1A7:  jsr     LB3BC                           ; B1A7 20 BC B3  ..
        dec     $C1                             ; B1AA C6 C1    ..
        bpl     LB1A7                           ; B1AC 10 F9    ..
LB1AE:  jsr     LB01D                           ; B1AE 20 1D B0  ..
LB1B1:  jsr     LB56D                           ; B1B1 20 6D B5  m.
        ldx     #$05                            ; B1B4 A2 05    ..
        ldy     #$0F                            ; B1B6 A0 0F    ..
        jsr     LB2D1                           ; B1B8 20 D1 B2  ..
        jsr     LB380                           ; B1BB 20 80 B3  ..
        jmp     LB1C4                           ; B1BE 4C C4 B1 L..

; ----------------------------------------------------------------------------
LB1C1:  jsr     LB73C                           ; B1C1 20 3C B7  <.
LB1C4:  jsr     print_string_255term            ; B1C4 20 17 A9  ..
        .byte   $1F,$00,$17                     ; B1C7 1F 00 17 ...
        .byte   "VOLUME :      (W to configure)"; B1CA 56 4F 4C 55 4D 45 20 3AVOLUME :
                                                ; B1D2 20 20 20 20 20 20 28 57      (W
                                                ; B1DA 20 74 6F 20 63 6F 6E 66 to conf
                                                ; B1E2 69 67 75 72 65 29igure)
        .byte   $1F,$08,$17,$FF                 ; B1E8 1F 08 17 FF....
; ----------------------------------------------------------------------------
        jsr     LB5EE                           ; B1EC 20 EE B5  ..
        cmp     #$57                            ; B1EF C9 57    .W
        bne     LB1F6                           ; B1F1 D0 03    ..
        jmp     LB255                           ; B1F3 4C 55 B2 LU.

; ----------------------------------------------------------------------------
LB1F6:  sec                                     ; B1F6 38       8
        sbc     #$41                            ; B1F7 E9 41    .A
        bcc     LB1C1                           ; B1F9 90 C6    ..
        cmp     #$08                            ; B1FB C9 08    ..
        bcs     LB1C1                           ; B1FD B0 C2    ..
        sta     $C1                             ; B1FF 85 C1    ..
        adc     #$41                            ; B201 69 41    iA
        jsr     oswrch                          ; B203 20 EE FF  ..
        lda     #$20                            ; B206 A9 20    . 
        jsr     oswrch                          ; B208 20 EE FF  ..
        jsr     LB305                           ; B20B 20 05 B3  ..
        bcs     LB1C4                           ; B20E B0 B4    ..
        lda     L00AA                           ; B210 A5 AA    ..
        ora     $AB                             ; B212 05 AB    ..
        bne     LB223                           ; B214 D0 0D    ..
        lda     $C1                             ; B216 A5 C1    ..
        beq     LB1C1                           ; B218 F0 A7    ..
        jsr     LB2A2                           ; B21A 20 A2 B2  ..
        jsr     LB3BC                           ; B21D 20 BC B3  ..
        jmp     LB1B1                           ; B220 4C B1 B1 L..

; ----------------------------------------------------------------------------
LB223:  lda     $AB                             ; B223 A5 AB    ..
        cmp     #$04                            ; B225 C9 04    ..
        bcs     LB1C1                           ; B227 B0 98    ..
        jsr     LB2A2                           ; B229 20 A2 B2  ..
        jsr     LB56D                           ; B22C 20 6D B5  m.
        lda     L00A8                           ; B22F A5 A8    ..
        cmp     L00AA                           ; B231 C5 AA    ..
        lda     $A9                             ; B233 A5 A9    ..
        sbc     $AB                             ; B235 E5 AB    ..
        bcs     LB241                           ; B237 B0 08    ..
        lda     L00A8                           ; B239 A5 A8    ..
        sta     L00AA                           ; B23B 85 AA    ..
        lda     $A9                             ; B23D A5 A9    ..
        sta     $AB                             ; B23F 85 AB    ..
LB241:  lda     $C1                             ; B241 A5 C1    ..
        asl     a                               ; B243 0A       .
        tay                                     ; B244 A8       .
        lda     $AB                             ; B245 A5 AB    ..
        sta     $FDD5,y                         ; B247 99 D5 FD ...
        lda     L00AA                           ; B24A A5 AA    ..
        sta     $FDD6,y                         ; B24C 99 D6 FD ...
        jsr     LB3BC                           ; B24F 20 BC B3  ..
        jmp     LB1B1                           ; B252 4C B1 B1 L..

; ----------------------------------------------------------------------------
LB255:  ldx     #$AE                            ; B255 A2 AE    ..
        ldy     #$B1                            ; B257 A0 B1    ..
        jsr     LB021                           ; B259 20 21 B0  !.
        jsr     LB706                           ; B25C 20 06 B7  ..
        jsr     LB279                           ; B25F 20 79 B2  y.
        jsr     LB6D3                           ; B262 20 D3 B6  ..
        beq     LB26A                           ; B265 F0 03    ..
        jmp     LB1AE                           ; B267 4C AE B1 L..

; ----------------------------------------------------------------------------
LB26A:  jsr     LB3EA                           ; B26A 20 EA B3  ..
        jsr     LB45E                           ; B26D 20 5E B4  ^.
        jsr     LB477                           ; B270 20 77 B4  w.
        jsr     LACBD                           ; B273 20 BD AC  ..
        jmp     LB028                           ; B276 4C 28 B0 L(.

; ----------------------------------------------------------------------------
LB279:  jsr     LAC55                           ; B279 20 55 AC  U.
        bit     $FDED                           ; B27C 2C ED FD ,..
        bvs     LB2A1                           ; B27F 70 20    p 
        jsr     print_string_2_nterm            ; B281 20 AD A8  ..
        .byte   $C9                             ; B284 C9       .
        .byte   "Disk must be double density"   ; B285 44 69 73 6B 20 6D 75 73Disk mus
                                                ; B28D 74 20 62 65 20 64 6F 75t be dou
                                                ; B295 62 6C 65 20 64 65 6E 73ble dens
                                                ; B29D 69 74 79 ity
; ----------------------------------------------------------------------------
        brk                                     ; B2A0 00       .
LB2A1:  rts                                     ; B2A1 60       `

; ----------------------------------------------------------------------------
LB2A2:  lda     $C1                             ; B2A2 A5 C1    ..
        asl     a                               ; B2A4 0A       .
        tay                                     ; B2A5 A8       .
        jsr     select_ram_page_000             ; B2A6 20 07 BE  ..
        lda     #$00                            ; B2A9 A9 00    ..
        sta     $FDD5,y                         ; B2AB 99 D5 FD ...
        sta     $FDD6,y                         ; B2AE 99 D6 FD ...
        rts                                     ; B2B1 60       `

; ----------------------------------------------------------------------------
LB2B2:  jsr     LB758                           ; B2B2 20 58 B7  X.
        jsr     print_string_255term            ; B2B5 20 17 A9  ..
        .byte   "F O R M A T"                   ; B2B8 46 20 4F 20 52 20 4D 20F O R M 
                                                ; B2C0 41 20 54 A T
        .byte   $FF                             ; B2C3 FF       .
; ----------------------------------------------------------------------------
LB2C4:  rts                                     ; B2C4 60       `

; ----------------------------------------------------------------------------
LB2C5:  lda     #$07                            ; B2C5 A9 07    ..
        pha                                     ; B2C7 48       H
        lda     #$16                            ; B2C8 A9 16    ..
        jsr     oswrch                          ; B2CA 20 EE FF  ..
        pla                                     ; B2CD 68       h
        jmp     oswrch                          ; B2CE 4C EE FF L..

; ----------------------------------------------------------------------------
LB2D1:  lda     #$1F                            ; B2D1 A9 1F    ..
        jsr     oswrch                          ; B2D3 20 EE FF  ..
        txa                                     ; B2D6 8A       .
        jsr     oswrch                          ; B2D7 20 EE FF  ..
        tya                                     ; B2DA 98       .
        jmp     oswrch                          ; B2DB 4C EE FF L..

; ----------------------------------------------------------------------------
LB2DE:  ldx     #$00                            ; B2DE A2 00    ..
        ldy     #$17                            ; B2E0 A0 17    ..
        jsr     LB2D1                           ; B2E2 20 D1 B2  ..
        ldy     #$28                            ; B2E5 A0 28    .(
        jmp     print_N_spaces_without_spool    ; B2E7 4C DD 8A L..

; ----------------------------------------------------------------------------
LB2EA:  bit     $FF                             ; B2EA 24 FF    $.
        bpl     LB2C4                           ; B2EC 10 D6    ..
        jsr     acknowledge_escape              ; B2EE 20 8F A9  ..
        jsr     LAD71                           ; B2F1 20 71 AD  q.
        ldx     $B7                             ; B2F4 A6 B7    ..
        txs                                     ; B2F6 9A       .
        jmp     (LFDE6)                         ; B2F7 6C E6 FD l..

; ----------------------------------------------------------------------------
LB2FA:  ldx     #$01                            ; B2FA A2 01    ..
        clc                                     ; B2FC 18       .
        lda     $C1                             ; B2FD A5 C1    ..
        adc     #$06                            ; B2FF 69 06    i.
        tay                                     ; B301 A8       .
        jmp     LB2D1                           ; B302 4C D1 B2 L..

; ----------------------------------------------------------------------------
LB305:  ldy     #$00                            ; B305 A0 00    ..
        sty     L00AA                           ; B307 84 AA    ..
        sty     $AB                             ; B309 84 AB    ..
LB30B:  jsr     LB5EE                           ; B30B 20 EE B5  ..
        cmp     #$0D                            ; B30E C9 0D    ..
        bne     LB314                           ; B310 D0 02    ..
        clc                                     ; B312 18       .
        rts                                     ; B313 60       `

; ----------------------------------------------------------------------------
LB314:  cmp     #$7F                            ; B314 C9 7F    ..
        bne     LB32D                           ; B316 D0 15    ..
        tya                                     ; B318 98       .
        bne     LB31D                           ; B319 D0 02    ..
        sec                                     ; B31B 38       8
        rts                                     ; B31C 60       `

; ----------------------------------------------------------------------------
LB31D:  jsr     LB348                           ; B31D 20 48 B3  H.
        dey                                     ; B320 88       .
        ldx     #$04                            ; B321 A2 04    ..
LB323:  lsr     $AB                             ; B323 46 AB    F.
        ror     L00AA                           ; B325 66 AA    f.
        dex                                     ; B327 CA       .
        bne     LB323                           ; B328 D0 F9    ..
        jmp     LB30B                           ; B32A 4C 0B B3 L..

; ----------------------------------------------------------------------------
LB32D:  cpy     #$03                            ; B32D C0 03    ..
        beq     LB30B                           ; B32F F0 DA    ..
        jsr     xtoi                            ; B331 20 E1 A9  ..
        jsr     print_hex_nybble                ; B334 20 80 A9  ..
        ldx     #$04                            ; B337 A2 04    ..
LB339:  asl     L00AA                           ; B339 06 AA    ..
        rol     $AB                             ; B33B 26 AB    &.
        dex                                     ; B33D CA       .
        bne     LB339                           ; B33E D0 F9    ..
        ora     L00AA                           ; B340 05 AA    ..
        sta     L00AA                           ; B342 85 AA    ..
        iny                                     ; B344 C8       .
        jmp     LB30B                           ; B345 4C 0B B3 L..

; ----------------------------------------------------------------------------
LB348:  jsr     LB350                           ; B348 20 50 B3  P.
        lda     #$20                            ; B34B A9 20    . 
        jsr     oswrch                          ; B34D 20 EE FF  ..
LB350:  lda     #$7F                            ; B350 A9 7F    ..
        jmp     oswrch                          ; B352 4C EE FF L..

; ----------------------------------------------------------------------------
        sec                                     ; B355 38       8
        sbc     #$30                            ; B356 E9 30    .0
        bcc     LB35D                           ; B358 90 03    ..
        cmp     #$0A                            ; B35A C9 0A    ..
        rts                                     ; B35C 60       `

; ----------------------------------------------------------------------------
LB35D:  sec                                     ; B35D 38       8
        rts                                     ; B35E 60       `

; ----------------------------------------------------------------------------
LB35F:  ldx     #$00                            ; B35F A2 00    ..
LB361:  lda     $B1                             ; B361 A5 B1    ..
        cmp     $B3                             ; B363 C5 B3    ..
        bcc     LB37F                           ; B365 90 18    ..
        bne     LB36F                           ; B367 D0 06    ..
        lda     $B0                             ; B369 A5 B0    ..
        cmp     $B2                             ; B36B C5 B2    ..
        bcc     LB37F                           ; B36D 90 10    ..
LB36F:  lda     $B0                             ; B36F A5 B0    ..
        sbc     $B2                             ; B371 E5 B2    ..
        sta     $B0                             ; B373 85 B0    ..
        lda     $B1                             ; B375 A5 B1    ..
        sbc     $B3                             ; B377 E5 B3    ..
        sta     $B1                             ; B379 85 B1    ..
        inx                                     ; B37B E8       .
        jmp     LB361                           ; B37C 4C 61 B3 La.

; ----------------------------------------------------------------------------
LB37F:  rts                                     ; B37F 60       `

; ----------------------------------------------------------------------------
LB380:  jsr     LA7E9                           ; B380 20 E9 A7  ..
        ldy     #$02                            ; B383 A0 02    ..
        jsr     print_N_spaces_without_spool    ; B385 20 DD 8A  ..
        lsr     $A9                             ; B388 46 A9    F.
        ror     L00A8                           ; B38A 66 A8    f.
        lsr     $A9                             ; B38C 46 A9    F.
        ror     L00A8                           ; B38E 66 A8    f.
        lda     L00A8                           ; B390 A5 A8    ..
        jsr     LB39D                           ; B392 20 9D B3  ..
        jsr     LA7E9                           ; B395 20 E9 A7  ..
        lda     #$4B                            ; B398 A9 4B    .K
        jmp     oswrch                          ; B39A 4C EE FF L..

; ----------------------------------------------------------------------------
LB39D:  sec                                     ; B39D 38       8
        ldx     #$FF                            ; B39E A2 FF    ..
        stx     $A9                             ; B3A0 86 A9    ..
LB3A2:  inc     $A9                             ; B3A2 E6 A9    ..
        sbc     #$64                            ; B3A4 E9 64    .d
        bcs     LB3A2                           ; B3A6 B0 FA    ..
        adc     #$64                            ; B3A8 69 64    id
LB3AA:  inx                                     ; B3AA E8       .
        sbc     #$0A                            ; B3AB E9 0A    ..
        bcs     LB3AA                           ; B3AD B0 FB    ..
        adc     #$0A                            ; B3AF 69 0A    i.
        sta     L00A8                           ; B3B1 85 A8    ..
        txa                                     ; B3B3 8A       .
        jsr     asl_x4                          ; B3B4 20 A4 A9  ..
        ora     L00A8                           ; B3B7 05 A8    ..
        sta     L00A8                           ; B3B9 85 A8    ..
        rts                                     ; B3BB 60       `

; ----------------------------------------------------------------------------
LB3BC:  jsr     LB2FA                           ; B3BC 20 FA B2  ..
        clc                                     ; B3BF 18       .
        lda     $C1                             ; B3C0 A5 C1    ..
        adc     #$41                            ; B3C2 69 41    iA
        jsr     oswrch                          ; B3C4 20 EE FF  ..
        ldy     #$0D                            ; B3C7 A0 0D    ..
        jsr     LB72C                           ; B3C9 20 2C B7  ,.
        lda     $C1                             ; B3CC A5 C1    ..
        asl     a                               ; B3CE 0A       .
        tay                                     ; B3CF A8       .
        jsr     select_ram_page_000             ; B3D0 20 07 BE  ..
        lda     $FDD5,y                         ; B3D3 B9 D5 FD ...
        sta     $A9                             ; B3D6 85 A9    ..
        lda     $FDD6,y                         ; B3D8 B9 D6 FD ...
        sta     L00A8                           ; B3DB 85 A8    ..
        ora     $A9                             ; B3DD 05 A9    ..
        beq     LB3E7                           ; B3DF F0 06    ..
        jsr     print_2_spaces_without_spool    ; B3E1 20 15 A8  ..
        jsr     LB380                           ; B3E4 20 80 B3  ..
LB3E7:  jmp     select_ram_page_001             ; B3E7 4C 0C BE L..

; ----------------------------------------------------------------------------
LB3EA:  lda     #$00                            ; B3EA A9 00    ..
        tay                                     ; B3EC A8       .
        jsr     select_ram_page_002             ; B3ED 20 11 BE  ..
LB3F0:  sta     $FD00,y                         ; B3F0 99 00 FD ...
        iny                                     ; B3F3 C8       .
        bne     LB3F0                           ; B3F4 D0 FA    ..
        jsr     select_ram_page_003             ; B3F6 20 16 BE  ..
LB3F9:  sta     $FD00,y                         ; B3F9 99 00 FD ...
        iny                                     ; B3FC C8       .
        bne     LB3F9                           ; B3FD D0 FA    ..
        jmp     select_ram_page_001             ; B3FF 4C 0C BE L..

; ----------------------------------------------------------------------------
LB402:  jsr     select_ram_page_000             ; B402 20 07 BE  ..
        lda     #$00                            ; B405 A9 00    ..
        ldy     #$0F                            ; B407 A0 0F    ..
LB409:  sta     $FDD5,y                         ; B409 99 D5 FD ...
        dey                                     ; B40C 88       .
        bpl     LB409                           ; B40D 10 FA    ..
        jmp     select_ram_page_001             ; B40F 4C 0C BE L..

; ----------------------------------------------------------------------------
LB412:  jsr     select_ram_page_001             ; B412 20 0C BE  ..
        lda     $C4                             ; B415 A5 C4    ..
        sta     $B2                             ; B417 85 B2    ..
        lda     $C5                             ; B419 A5 C5    ..
        sta     $B3                             ; B41B 85 B3    ..
        lda     $FDEB                           ; B41D AD EB FD ...
        sta     $B0                             ; B420 85 B0    ..
        lda     #$00                            ; B422 A9 00    ..
        ldx     #$04                            ; B424 A2 04    ..
LB426:  asl     $B0                             ; B426 06 B0    ..
        rol     a                               ; B428 2A       *
        dex                                     ; B429 CA       .
        bne     LB426                           ; B42A D0 FA    ..
        sta     $B1                             ; B42C 85 B1    ..
        jsr     select_ram_page_000             ; B42E 20 07 BE  ..
        ldy     #$00                            ; B431 A0 00    ..
LB433:  jsr     LB547                           ; B433 20 47 B5  G.
        bcc     LB440                           ; B436 90 08    ..
        lda     $B3                             ; B438 A5 B3    ..
        sta     $B1                             ; B43A 85 B1    ..
        lda     $B2                             ; B43C A5 B2    ..
        sta     $B0                             ; B43E 85 B0    ..
LB440:  lda     $B1                             ; B440 A5 B1    ..
        sta     $FDD5,y                         ; B442 99 D5 FD ...
        lda     $B0                             ; B445 A5 B0    ..
        sta     $FDD6,y                         ; B447 99 D6 FD ...
        sec                                     ; B44A 38       8
        lda     $B2                             ; B44B A5 B2    ..
        sbc     $B0                             ; B44D E5 B0    ..
        sta     $B2                             ; B44F 85 B2    ..
        lda     $B3                             ; B451 A5 B3    ..
        sbc     $B1                             ; B453 E5 B1    ..
        sta     $B3                             ; B455 85 B3    ..
        iny                                     ; B457 C8       .
        iny                                     ; B458 C8       .
        cpy     #$10                            ; B459 C0 10    ..
        bne     LB433                           ; B45B D0 D6    ..
        rts                                     ; B45D 60       `

; ----------------------------------------------------------------------------
LB45E:  ldy     #$00                            ; B45E A0 00    ..
LB460:  jsr     select_ram_page_000             ; B460 20 07 BE  ..
        lda     $FDD5,y                         ; B463 B9 D5 FD ...
        sta     $C5                             ; B466 85 C5    ..
        lda     $FDD6,y                         ; B468 B9 D6 FD ...
        sta     $C4                             ; B46B 85 C4    ..
        jsr     LB062                           ; B46D 20 62 B0  b.
        iny                                     ; B470 C8       .
        iny                                     ; B471 C8       .
        cpy     #$10                            ; B472 C0 10    ..
        bne     LB460                           ; B474 D0 EA    ..
        rts                                     ; B476 60       `

; ----------------------------------------------------------------------------
LB477:  jsr     select_ram_page_002             ; B477 20 11 BE  ..
        lda     #$20                            ; B47A A9 20    . 
        sta     $FD00                           ; B47C 8D 00 FD ...
        lda     #$12                            ; B47F A9 12    ..
        sta     $FD03                           ; B481 8D 03 FD ...
        ldy     L00C0                           ; B484 A4 C0    ..
        sty     $FD04                           ; B486 8C 04 FD ...
        lda     #$00                            ; B489 A9 00    ..
        sta     $FD05                           ; B48B 8D 05 FD ...
        jsr     LB5AE                           ; B48E 20 AE B5  ..
        lda     L00A8                           ; B491 A5 A8    ..
        sta     $FD02                           ; B493 8D 02 FD ...
        lda     $A9                             ; B496 A5 A9    ..
        sta     $FD01                           ; B498 8D 01 FD ...
        ldy     #$01                            ; B49B A0 01    ..
        sty     $BB                             ; B49D 84 BB    ..
        dey                                     ; B49F 88       .
LB4A0:  jsr     select_ram_page_000             ; B4A0 20 07 BE  ..
        tya                                     ; B4A3 98       .
        pha                                     ; B4A4 48       H
        lda     $FDD5,y                         ; B4A5 B9 D5 FD ...
        sta     $B1                             ; B4A8 85 B1    ..
        lda     $FDD6,y                         ; B4AA B9 D6 FD ...
        sta     $B0                             ; B4AD 85 B0    ..
        ora     $B1                             ; B4AF 05 B1    ..
        beq     LB4C9                           ; B4B1 F0 16    ..
        jsr     select_ram_page_002             ; B4B3 20 11 BE  ..
        lda     $BB                             ; B4B6 A5 BB    ..
        sta     $FD08,y                         ; B4B8 99 08 FD ...
        lda     #$00                            ; B4BB A9 00    ..
        sta     $FD09,y                         ; B4BD 99 09 FD ...
        jsr     LB597                           ; B4C0 20 97 B5  ..
        clc                                     ; B4C3 18       .
        tya                                     ; B4C4 98       .
        adc     $BB                             ; B4C5 65 BB    e.
        sta     $BB                             ; B4C7 85 BB    ..
LB4C9:  pla                                     ; B4C9 68       h
        tay                                     ; B4CA A8       .
        iny                                     ; B4CB C8       .
        iny                                     ; B4CC C8       .
        cpy     #$10                            ; B4CD C0 10    ..
        bne     LB4A0                           ; B4CF D0 CF    ..
        rts                                     ; B4D1 60       `

; ----------------------------------------------------------------------------
LB4D2:  jsr     LB52E                           ; B4D2 20 2E B5  ..
        jsr     select_ram_page_002             ; B4D5 20 11 BE  ..
        sec                                     ; B4D8 38       8
        lda     $FD02                           ; B4D9 AD 02 FD ...
        sbc     #$12                            ; B4DC E9 12    ..
        sta     $C4                             ; B4DE 85 C4    ..
        lda     $FD01                           ; B4E0 AD 01 FD ...
        sbc     #$00                            ; B4E3 E9 00    ..
        sta     $C5                             ; B4E5 85 C5    ..
        lda     $FD04                           ; B4E7 AD 04 FD ...
        sta     L00C0                           ; B4EA 85 C0    ..
        jsr     LB402                           ; B4EC 20 02 B4  ..
        ldy     #$0E                            ; B4EF A0 0E    ..
LB4F1:  jsr     select_ram_page_000             ; B4F1 20 07 BE  ..
        tya                                     ; B4F4 98       .
        lsr     a                               ; B4F5 4A       J
        tax                                     ; B4F6 AA       .
        lda     $FDCD,x                         ; B4F7 BD CD FD ...
        beq     LB529                           ; B4FA F0 2D    .-
        sty     $BB                             ; B4FC 84 BB    ..
        inc     $BB                             ; B4FE E6 BB    ..
        jsr     L96A5                           ; B500 20 A5 96  ..
        lda     #$01                            ; B503 A9 01    ..
        sta     $A1                             ; B505 85 A1    ..
        lda     #$00                            ; B507 A9 00    ..
        sta     $A0                             ; B509 85 A0    ..
        lda     #$80                            ; B50B A9 80    ..
        sta     $FDE9                           ; B50D 8D E9 FD ...
        jsr     LBA18                           ; B510 20 18 BA  ..
        jsr     select_ram_page_002             ; B513 20 11 BE  ..
        lda     $FD06                           ; B516 AD 06 FD ...
        and     #$03                            ; B519 29 03    ).
        pha                                     ; B51B 48       H
        lda     $FD07                           ; B51C AD 07 FD ...
        jsr     select_ram_page_000             ; B51F 20 07 BE  ..
        sta     $FDD6,y                         ; B522 99 D6 FD ...
        pla                                     ; B525 68       h
        sta     $FDD5,y                         ; B526 99 D5 FD ...
LB529:  dey                                     ; B529 88       .
        dey                                     ; B52A 88       .
        bpl     LB4F1                           ; B52B 10 C4    ..
        rts                                     ; B52D 60       `

; ----------------------------------------------------------------------------
LB52E:  jsr     LACBA                           ; B52E 20 BA AC  ..
        ldy     #$0E                            ; B531 A0 0E    ..
        ldx     #$07                            ; B533 A2 07    ..
LB535:  jsr     select_ram_page_002             ; B535 20 11 BE  ..
        lda     $FD08,y                         ; B538 B9 08 FD ...
        jsr     select_ram_page_000             ; B53B 20 07 BE  ..
        sta     $FDCD,x                         ; B53E 9D CD FD ...
        dey                                     ; B541 88       .
        dey                                     ; B542 88       .
        dex                                     ; B543 CA       .
        bpl     LB535                           ; B544 10 EF    ..
        rts                                     ; B546 60       `

; ----------------------------------------------------------------------------
LB547:  lda     $B1                             ; B547 A5 B1    ..
        cmp     $B3                             ; B549 C5 B3    ..
        bne     LB551                           ; B54B D0 04    ..
        lda     $B0                             ; B54D A5 B0    ..
        cmp     $B2                             ; B54F C5 B2    ..
LB551:  rts                                     ; B551 60       `

; ----------------------------------------------------------------------------
LB552:  jsr     select_ram_page_001             ; B552 20 0C BE  ..
        ldy     $FDEB                           ; B555 AC EB FD ...
        lda     #$00                            ; B558 A9 00    ..
        sta     $C4                             ; B55A 85 C4    ..
        sta     $C5                             ; B55C 85 C5    ..
LB55E:  clc                                     ; B55E 18       .
        lda     $B0                             ; B55F A5 B0    ..
        adc     $C4                             ; B561 65 C4    e.
        sta     $C4                             ; B563 85 C4    ..
        bcc     LB569                           ; B565 90 02    ..
        inc     $C5                             ; B567 E6 C5    ..
LB569:  dey                                     ; B569 88       .
        bne     LB55E                           ; B56A D0 F2    ..
        rts                                     ; B56C 60       `

; ----------------------------------------------------------------------------
LB56D:  ldx     #$00                            ; B56D A2 00    ..
        stx     $B2                             ; B56F 86 B2    ..
LB571:  jsr     select_ram_page_000             ; B571 20 07 BE  ..
        lda     $FDD6,x                         ; B574 BD D6 FD ...
        sta     $B0                             ; B577 85 B0    ..
        lda     $FDD5,x                         ; B579 BD D5 FD ...
        sta     $B1                             ; B57C 85 B1    ..
        jsr     LB597                           ; B57E 20 97 B5  ..
        clc                                     ; B581 18       .
        tya                                     ; B582 98       .
        adc     $B2                             ; B583 65 B2    e.
        sta     $B2                             ; B585 85 B2    ..
        inx                                     ; B587 E8       .
        inx                                     ; B588 E8       .
        cpx     #$10                            ; B589 E0 10    ..
        bne     LB571                           ; B58B D0 E4    ..
        sec                                     ; B58D 38       8
        lda     L00C0                           ; B58E A5 C0    ..
        sbc     $B2                             ; B590 E5 B2    ..
        tay                                     ; B592 A8       .
        dey                                     ; B593 88       .
        jmp     LB5AE                           ; B594 4C AE B5 L..

; ----------------------------------------------------------------------------
LB597:  ldy     #$00                            ; B597 A0 00    ..
        sty     L00A8                           ; B599 84 A8    ..
        sty     $A9                             ; B59B 84 A9    ..
LB59D:  lda     L00A8                           ; B59D A5 A8    ..
        cmp     $B0                             ; B59F C5 B0    ..
        lda     $A9                             ; B5A1 A5 A9    ..
        sbc     $B1                             ; B5A3 E5 B1    ..
        bcs     LB5AD                           ; B5A5 B0 06    ..
        iny                                     ; B5A7 C8       .
        jsr     LB5BE                           ; B5A8 20 BE B5  ..
        bcc     LB59D                           ; B5AB 90 F0    ..
LB5AD:  rts                                     ; B5AD 60       `

; ----------------------------------------------------------------------------
LB5AE:  lda     #$00                            ; B5AE A9 00    ..
        sta     L00A8                           ; B5B0 85 A8    ..
        sta     $A9                             ; B5B2 85 A9    ..
        iny                                     ; B5B4 C8       .
LB5B5:  dey                                     ; B5B5 88       .
        beq     LB5BD                           ; B5B6 F0 05    ..
        jsr     LB5BE                           ; B5B8 20 BE B5  ..
        bcc     LB5B5                           ; B5BB 90 F8    ..
LB5BD:  rts                                     ; B5BD 60       `

; ----------------------------------------------------------------------------
LB5BE:  clc                                     ; B5BE 18       .
        lda     L00A8                           ; B5BF A5 A8    ..
        adc     #$12                            ; B5C1 69 12    i.
        sta     L00A8                           ; B5C3 85 A8    ..
        bcc     LB5C9                           ; B5C5 90 02    ..
        inc     $A9                             ; B5C7 E6 A9    ..
LB5C9:  clc                                     ; B5C9 18       .
        rts                                     ; B5CA 60       `

; ----------------------------------------------------------------------------
LB5CB:  jsr     LB5EE                           ; B5CB 20 EE B5  ..
        cmp     #$30                            ; B5CE C9 30    .0
        bcc     LB5CB                           ; B5D0 90 F9    ..
        cmp     #$5B                            ; B5D2 C9 5B    .[
        bcs     LB5CB                           ; B5D4 B0 F5    ..
        pha                                     ; B5D6 48       H
        jsr     oswrch                          ; B5D7 20 EE FF  ..
LB5DA:  jsr     LB5EE                           ; B5DA 20 EE B5  ..
        cmp     #$0D                            ; B5DD C9 0D    ..
        bne     LB5E3                           ; B5DF D0 02    ..
        pla                                     ; B5E1 68       h
        rts                                     ; B5E2 60       `

; ----------------------------------------------------------------------------
LB5E3:  cmp     #$7F                            ; B5E3 C9 7F    ..
        bne     LB5DA                           ; B5E5 D0 F3    ..
        pla                                     ; B5E7 68       h
        jsr     LB348                           ; B5E8 20 48 B3  H.
        jmp     LB5CB                           ; B5EB 4C CB B5 L..

; ----------------------------------------------------------------------------
LB5EE:  jsr     osrdch                          ; B5EE 20 E0 FF  ..
        bcs     LB5F4                           ; B5F1 B0 01    ..
        rts                                     ; B5F3 60       `

; ----------------------------------------------------------------------------
LB5F4:  cmp     #$1B                            ; B5F4 C9 1B    ..
        beq     LB5F9                           ; B5F6 F0 01    ..
        rts                                     ; B5F8 60       `

; ----------------------------------------------------------------------------
LB5F9:  jsr     select_ram_page_001             ; B5F9 20 0C BE  ..
        jsr     acknowledge_escape              ; B5FC 20 8F A9  ..
        jsr     LAD71                           ; B5FF 20 71 AD  q.
        jsr     LB650                           ; B602 20 50 B6  P.
        ldx     $B7                             ; B605 A6 B7    ..
        txs                                     ; B607 9A       .
        jmp     (LFDE6)                         ; B608 6C E6 FD l..

; ----------------------------------------------------------------------------
LB60B:  jsr     LB650                           ; B60B 20 50 B6  P.
        jsr     print_string_255term            ; B60E 20 17 A9  ..
        .byte   $1F,$15,$17                     ; B611 1F 15 17 ...
        .byte   "ERROR"                         ; B614 45 52 52 4F 52ERROR
        .byte   $FF                             ; B619 FF       .
; ----------------------------------------------------------------------------
        rts                                     ; B61A 60       `

; ----------------------------------------------------------------------------
LB61B:  jsr     print_string_255term            ; B61B 20 17 A9  ..
        .byte   $1C,$00,$0D                     ; B61E 1C 00 0D ...
        .byte   "'"                             ; B621 27       '
        .byte   $04,$0C,$1A,$FF                 ; B622 04 0C 1A FF....
; ----------------------------------------------------------------------------
        jsr     LB650                           ; B626 20 50 B6  P.
        jsr     print_string_255term            ; B629 20 17 A9  ..
        .byte   $1F,$00,$10                     ; B62C 1F 00 10 ...
        .byte   "Press F(ret) to start  "       ; B62F 50 72 65 73 73 20 46 28Press F(
                                                ; B637 72 65 74 29 20 74 6F 20ret) to 
                                                ; B63F 73 74 61 72 74 20 20start  
        .byte   $7F,$FF                         ; B646 7F FF    ..
; ----------------------------------------------------------------------------
        jsr     LB5CB                           ; B648 20 CB B5  ..
        cmp     #$46                            ; B64B C9 46    .F
        bne     LB61B                           ; B64D D0 CC    ..
        rts                                     ; B64F 60       `

; ----------------------------------------------------------------------------
LB650:  ldx     #$00                            ; B650 A2 00    ..
        ldy     #$10                            ; B652 A0 10    ..
        jsr     LB2D1                           ; B654 20 D1 B2  ..
        ldy     #$78                            ; B657 A0 78    .x
        jmp     print_N_spaces_without_spool    ; B659 4C DD 8A L..

; ----------------------------------------------------------------------------
LB65C:  jsr     LB61B                           ; B65C 20 1B B6  ..
        jsr     LB6D3                           ; B65F 20 D3 B6  ..
        bne     LB65C                           ; B662 D0 F8    ..
        jsr     LB650                           ; B664 20 50 B6  P.
        lda     #$80                            ; B667 A9 80    ..
        sta     $B9                             ; B669 85 B9    ..
        lda     #$00                            ; B66B A9 00    ..
        sta     $BA                             ; B66D 85 BA    ..
        sta     $BB                             ; B66F 85 BB    ..
        jsr     LBB18                           ; B671 20 18 BB  ..
LB674:  lda     #$03                            ; B674 A9 03    ..
        sta     $BF                             ; B676 85 BF    ..
LB678:  jsr     LB2EA                           ; B678 20 EA B2  ..
        jsr     LB6B3                           ; B67B 20 B3 B6  ..
        ldy     #$03                            ; B67E A0 03    ..
        jsr     LB72C                           ; B680 20 2C B7  ,.
        jsr     LBB18                           ; B683 20 18 BB  ..
        jsr     LB121                           ; B686 20 21 B1  !.
        beq     LB694                           ; B689 F0 09    ..
        dec     $BF                             ; B68B C6 BF    ..
        bne     LB678                           ; B68D D0 E9    ..
        jsr     LB60B                           ; B68F 20 0B B6  ..
        sec                                     ; B692 38       8
        rts                                     ; B693 60       `

; ----------------------------------------------------------------------------
LB694:  lda     #$FE                            ; B694 A9 FE    ..
        bit     $FDED                           ; B696 2C ED FD ,..
        bvc     LB69C                           ; B699 50 01    P.
        asl     a                               ; B69B 0A       .
LB69C:  clc                                     ; B69C 18       .
        adc     $BB                             ; B69D 65 BB    e.
        bcs     LB6A4                           ; B69F B0 03    ..
        adc     $FDEB                           ; B6A1 6D EB FD m..
LB6A4:  sta     $BB                             ; B6A4 85 BB    ..
        inc     $BA                             ; B6A6 E6 BA    ..
        lda     $BA                             ; B6A8 A5 BA    ..
        cmp     L00C0                           ; B6AA C5 C0    ..
        bcs     LB6B1                           ; B6AC B0 03    ..
        jmp     LB674                           ; B6AE 4C 74 B6 Lt.

; ----------------------------------------------------------------------------
LB6B1:  clc                                     ; B6B1 18       .
        rts                                     ; B6B2 60       `

; ----------------------------------------------------------------------------
LB6B3:  ldx     #$00                            ; B6B3 A2 00    ..
        ldy     $BA                             ; B6B5 A4 BA    ..
LB6B7:  sec                                     ; B6B7 38       8
        tya                                     ; B6B8 98       .
        sbc     #$0A                            ; B6B9 E9 0A    ..
        bcc     LB6C5                           ; B6BB 90 08    ..
        tay                                     ; B6BD A8       .
        clc                                     ; B6BE 18       .
        txa                                     ; B6BF 8A       .
        adc     #$05                            ; B6C0 69 05    i.
        tax                                     ; B6C2 AA       .
        bcc     LB6B7                           ; B6C3 90 F2    ..
LB6C5:  adc     #$0E                            ; B6C5 69 0E    i.
        tay                                     ; B6C7 A8       .
        jsr     LB2D1                           ; B6C8 20 D1 B2  ..
        lda     $BA                             ; B6CB A5 BA    ..
        jsr     LB39D                           ; B6CD 20 9D B3  ..
        jmp     LA7F1                           ; B6D0 4C F1 A7 L..

; ----------------------------------------------------------------------------
LB6D3:  jsr     LADBC                           ; B6D3 20 BC AD  ..
        beq     LB705                           ; B6D6 F0 2D    .-
        jsr     print_string_255term            ; B6D8 20 17 A9  ..
        .byte   $1F,$00,$10                     ; B6DB 1F 00 10 ...
        .byte   "Disk R/O...remove write protect"; B6DE 44 69 73 6B 20 52 2F 4FDisk R/O
                                                ; B6E6 2E 2E 2E 72 65 6D 6F 76...remov
                                                ; B6EE 65 20 77 72 69 74 65 20e write 
                                                ; B6F6 70 72 6F 74 65 63 74protect
        .byte   $0D,$0A,$FF                     ; B6FD 0D 0A FF ...
; ----------------------------------------------------------------------------
        jsr     LB706                           ; B700 20 06 B7  ..
        lda     #$FF                            ; B703 A9 FF    ..
LB705:  rts                                     ; B705 60       `

; ----------------------------------------------------------------------------
LB706:  jsr     print_string_255term            ; B706 20 17 A9  ..
        .byte   $1F,$04,$11                     ; B709 1F 04 11 ...
        .byte   "Press any key to continue"     ; B70C 50 72 65 73 73 20 61 6EPress an
                                                ; B714 79 20 6B 65 79 20 74 6Fy key to
                                                ; B71C 20 63 6F 6E 74 69 6E 75 continu
                                                ; B724 65       e
        .byte   $FF                             ; B725 FF       .
; ----------------------------------------------------------------------------
        jsr     LB5EE                           ; B726 20 EE B5  ..
        jmp     LB650                           ; B729 4C 50 B6 LP.

; ----------------------------------------------------------------------------
LB72C:  tya                                     ; B72C 98       .
        pha                                     ; B72D 48       H
        jsr     print_N_spaces_without_spool    ; B72E 20 DD 8A  ..
        pla                                     ; B731 68       h
        tay                                     ; B732 A8       .
LB733:  lda     #$7F                            ; B733 A9 7F    ..
        jsr     oswrch                          ; B735 20 EE FF  ..
        dey                                     ; B738 88       .
        bne     LB733                           ; B739 D0 F8    ..
        rts                                     ; B73B 60       `

; ----------------------------------------------------------------------------
LB73C:  lda     #$07                            ; B73C A9 07    ..
        jmp     oswrch                          ; B73E 4C EE FF L..

; ----------------------------------------------------------------------------
LB741:  jsr     LAA16                           ; B741 20 16 AA  ..
        jsr     LB74C                           ; B744 20 4C B7  L.
        bne     LB757                           ; B747 D0 0E    ..
        jmp     LAAD6                           ; B749 4C D6 AA L..

; ----------------------------------------------------------------------------
LB74C:  jsr     LAAD9                           ; B74C 20 D9 AA  ..
        and     #$07                            ; B74F 29 07    ).
        cmp     #$04                            ; B751 C9 04    ..
        beq     LB757                           ; B753 F0 02    ..
        cmp     #$05                            ; B755 C9 05    ..
LB757:  rts                                     ; B757 60       `

; ----------------------------------------------------------------------------
LB758:  jsr     LB2C5                           ; B758 20 C5 B2  ..
        ldy     #$00                            ; B75B A0 00    ..
        iny                                     ; B75D C8       .
        ldx     #$0D                            ; B75E A2 0D    ..
        jsr     LB2D1                           ; B760 20 D1 B2  ..
        cpy     #$03                            ; B763 C0 03    ..
        rts                                     ; B765 60       `

; ----------------------------------------------------------------------------
fdcstat_command:
        tsx                                     ; B766 BA       .
        lda     #$00                            ; B767 A9 00    ..
        sta     $0105,x                         ; B769 9D 05 01 ...
        jsr     print_string_255term            ; B76C 20 17 A9  ..
        .byte   $0D,$0A                         ; B76F 0D 0A    ..
        .byte   "WD 1770 status : "             ; B771 57 44 20 31 37 37 30 20WD 1770 
                                                ; B779 73 74 61 74 75 73 20 3Astatus :
                                                ; B781 20        
        .byte   $FF                             ; B782 FF       .
; ----------------------------------------------------------------------------
        lda     $FDF3                           ; B783 AD F3 FD ...
        jsr     print_hex_byte                  ; B786 20 78 A9  x.
        jmp     L8469                           ; B789 4C 69 84 Li.

; ----------------------------------------------------------------------------
osword_7f_read_data_or_deleted_data:
        ldx     #$00                            ; B78C A2 00    ..
        .byte   $AD                             ; B78E AD       .
osword_7f_write_data:
        ldx     #$01                            ; B78F A2 01    ..
        lda     $02A2                           ; B791 AD A2 02 ...
        .byte   $AD                             ; B794 AD       .
osword_7f_write_deleted_data:
        ldx     #$03                            ; B795 A2 03    ..
        .byte   $AD                             ; B797 AD       .
osword_7f_verify_data:
        ldx     #$04                            ; B798 A2 04    ..
        stx     $FDE9                           ; B79A 8E E9 FD ...
        lda     ($B0),y                         ; B79D B1 B0    ..
        sta     $BB                             ; B79F 85 BB    ..
        jsr     LB74C                           ; B7A1 20 4C B7  L.
        bne     LB7B9                           ; B7A4 D0 13    ..
        ldx     #$0A                            ; B7A6 A2 0A    ..
        ldy     #$00                            ; B7A8 A0 00    ..
        lda     $BB                             ; B7AA A5 BB    ..
LB7AC:  clc                                     ; B7AC 18       .
        adc     $BA                             ; B7AD 65 BA    e.
        bcc     LB7B2                           ; B7AF 90 01    ..
        iny                                     ; B7B1 C8       .
LB7B2:  dex                                     ; B7B2 CA       .
        bne     LB7AC                           ; B7B3 D0 F7    ..
        sta     $BB                             ; B7B5 85 BB    ..
        sty     $BA                             ; B7B7 84 BA    ..
LB7B9:  ldy     #$09                            ; B7B9 A0 09    ..
        lda     ($B0),y                         ; B7BB B1 B0    ..
        jsr     lsr_x5                          ; B7BD 20 9D A9  ..
        tax                                     ; B7C0 AA       .
        lda     #$00                            ; B7C1 A9 00    ..
        sta     $A0                             ; B7C3 85 A0    ..
        lda     ($B0),y                         ; B7C5 B1 B0    ..
        iny                                     ; B7C7 C8       .
        and     #$1F                            ; B7C8 29 1F    ).
        lsr     a                               ; B7CA 4A       J
        ror     $A0                             ; B7CB 66 A0    f.
        bcc     LB7D2                           ; B7CD 90 03    ..
LB7CF:  asl     $A0                             ; B7CF 06 A0    ..
        rol     a                               ; B7D1 2A       *
LB7D2:  dex                                     ; B7D2 CA       .
        bpl     LB7CF                           ; B7D3 10 FA    ..
        sta     $A1                             ; B7D5 85 A1    ..
        jmp     LBA18                           ; B7D7 4C 18 BA L..

; ----------------------------------------------------------------------------
osword_7f_seek:
        jsr     LB7E3                           ; B7DA 20 E3 B7  ..
        bcs     LB7E2                           ; B7DD B0 03    ..
        jsr     LB916                           ; B7DF 20 16 B9  ..
LB7E2:  rts                                     ; B7E2 60       `

; ----------------------------------------------------------------------------
LB7E3:  jsr     LB74C                           ; B7E3 20 4C B7  L.
        clc                                     ; B7E6 18       .
        bne     LB7EC                           ; B7E7 D0 03    ..
        lda     #$00                            ; B7E9 A9 00    ..
        sec                                     ; B7EB 38       8
LB7EC:  rts                                     ; B7EC 60       `

; ----------------------------------------------------------------------------
osword_7f_command_1b:
        ldy     #$09                            ; B7ED A0 09    ..
        lda     ($B0),y                         ; B7EF B1 B0    ..
        bne     LB7F5                           ; B7F1 D0 02    ..
        lda     #$01                            ; B7F3 A9 01    ..
LB7F5:  sta     $BB                             ; B7F5 85 BB    ..
        jsr     LB74C                           ; B7F7 20 4C B7  L.
        beq     LB818                           ; B7FA F0 1C    ..
        jsr     LB916                           ; B7FC 20 16 B9  ..
        jsr     LB95F                           ; B7FF 20 5F B9  _.
        bne     LB817                           ; B802 D0 13    ..
        pha                                     ; B804 48       H
        lda     $BB                             ; B805 A5 BB    ..
        asl     a                               ; B807 0A       .
        asl     a                               ; B808 0A       .
        tax                                     ; B809 AA       .
        ldy     #$00                            ; B80A A0 00    ..
LB80C:  lda     $0D0C,y                         ; B80C B9 0C 0D ...
        jsr     LA4E0                           ; B80F 20 E0 A4  ..
        iny                                     ; B812 C8       .
        dex                                     ; B813 CA       .
        bne     LB80C                           ; B814 D0 F6    ..
        pla                                     ; B816 68       h
LB817:  rts                                     ; B817 60       `

; ----------------------------------------------------------------------------
LB818:  pla                                     ; B818 68       h
        ldy     #$00                            ; B819 A0 00    ..
        ldx     #$00                            ; B81B A2 00    ..
LB81D:  lda     $BA                             ; B81D A5 BA    ..
        jsr     LA4E0                           ; B81F 20 E0 A4  ..
        iny                                     ; B822 C8       .
        lda     #$00                            ; B823 A9 00    ..
        jsr     LA4E0                           ; B825 20 E0 A4  ..
        iny                                     ; B828 C8       .
        txa                                     ; B829 8A       .
        jsr     LA4E0                           ; B82A 20 E0 A4  ..
        iny                                     ; B82D C8       .
        lda     #$01                            ; B82E A9 01    ..
        jsr     LA4E0                           ; B830 20 E0 A4  ..
        inx                                     ; B833 E8       .
        dec     $BB                             ; B834 C6 BB    ..
        bne     LB81D                           ; B836 D0 E5    ..
        jsr     LB996                           ; B838 20 96 B9  ..
        lda     #$00                            ; B83B A9 00    ..
        rts                                     ; B83D 60       `

; ----------------------------------------------------------------------------
osword_7f_command_23:
        jsr     LB7E3                           ; B83E 20 E3 B7  ..
        bcs     LB84E                           ; B841 B0 0B    ..
        iny                                     ; B843 C8       .
        lda     ($B0),y                         ; B844 B1 B0    ..
        and     #$1F                            ; B846 29 1F    ).
        sta     $FDEB                           ; B848 8D EB FD ...
        jmp     LBB58                           ; B84B 4C 58 BB LX.

; ----------------------------------------------------------------------------
LB84E:  lda     $FDED                           ; B84E AD ED FD ...
        and     #$40                            ; B851 29 40    )@
        sta     $FDFE                           ; B853 8D FE FD ...
        lda     #$00                            ; B856 A9 00    ..
        rts                                     ; B858 60       `

; ----------------------------------------------------------------------------
osword_7f_read_drive_status:
        dey                                     ; B859 88       .
        jsr     LB905                           ; B85A 20 05 B9  ..
        lsr     a                               ; B85D 4A       J
        lsr     a                               ; B85E 4A       J
        lsr     a                               ; B85F 4A       J
        ora     #$44                            ; B860 09 44    .D
LB862:  rts                                     ; B862 60       `

; ----------------------------------------------------------------------------
osword_7f_initialise:
        lda     $BA                             ; B863 A5 BA    ..
        cmp     #$0D                            ; B865 C9 0D    ..
        bne     LB862                           ; B867 D0 F9    ..
        lda     ($B0),y                         ; B869 B1 B0    ..
        tax                                     ; B86B AA       .
        jmp     LB901                           ; B86C 4C 01 B9 L..

; ----------------------------------------------------------------------------
osword_7f_write_special_registers:
        lda     ($B0),y                         ; B86F B1 B0    ..
        ldx     $BA                             ; B871 A6 BA    ..
        cpx     #$05                            ; B873 E0 05    ..
        bcs     LB87B                           ; B875 B0 04    ..
        sta     $FDEA,x                         ; B877 9D EA FD ...
        rts                                     ; B87A 60       `

; ----------------------------------------------------------------------------
LB87B:  ldy     #$00                            ; B87B A0 00    ..
        cpx     #$12                            ; B87D E0 12    ..
        beq     LB886                           ; B87F F0 05    ..
        iny                                     ; B881 C8       .
        cpx     #$1A                            ; B882 E0 1A    ..
        bne     LB8AA                           ; B884 D0 24    .$
LB886:  sta     $FDEF,y                         ; B886 99 EF FD ...
        lda     #$00                            ; B889 A9 00    ..
        rts                                     ; B88B 60       `

; ----------------------------------------------------------------------------
osword_7f_read_special_registers:
        ldx     $BA                             ; B88C A6 BA    ..
        cpx     #$05                            ; B88E E0 05    ..
        bcs     LB898                           ; B890 B0 06    ..
        lda     $FDEA,x                         ; B892 BD EA FD ...
        sta     ($B0),y                         ; B895 91 B0    ..
        rts                                     ; B897 60       `

; ----------------------------------------------------------------------------
LB898:  lda     #$00                            ; B898 A9 00    ..
        cpx     #$12                            ; B89A E0 12    ..
        beq     LB8A4                           ; B89C F0 06    ..
        lda     #$01                            ; B89E A9 01    ..
        cpx     #$1A                            ; B8A0 E0 1A    ..
        bne     LB8AA                           ; B8A2 D0 06    ..
LB8A4:  tax                                     ; B8A4 AA       .
        lda     $FDEF,x                         ; B8A5 BD EF FD ...
        sta     ($B0),y                         ; B8A8 91 B0    ..
LB8AA:  lda     #$00                            ; B8AA A9 00    ..
        rts                                     ; B8AC 60       `

; ----------------------------------------------------------------------------
LB8AD:  .byte   $13                             ; B8AD 13       .
; ----------------------------------------------------------------------------
LB8AE:  .word   osword_7f_read_data_or_deleted_data-1; B8AE 8B B7..
; ----------------------------------------------------------------------------
        .byte   $0B                             ; B8B0 0B       .
; ----------------------------------------------------------------------------
        .word   osword_7f_write_data-1          ; B8B1 8E B7    ..
; ----------------------------------------------------------------------------
        .byte   $29                             ; B8B3 29       )
; ----------------------------------------------------------------------------
        .word   osword_7f_seek-1                ; B8B4 D9 B7    ..
; ----------------------------------------------------------------------------
        .byte   $1F                             ; B8B6 1F       .
; ----------------------------------------------------------------------------
        .word   osword_7f_verify_data-1         ; B8B7 97 B7    ..
; ----------------------------------------------------------------------------
        .byte   $17                             ; B8B9 17       .
; ----------------------------------------------------------------------------
        .word   osword_7f_read_data_or_deleted_data-1; B8BA 8B B7..
; ----------------------------------------------------------------------------
        .byte   $0F                             ; B8BC 0F       .
; ----------------------------------------------------------------------------
        .word   osword_7f_write_deleted_data-1  ; B8BD 94 B7    ..
; ----------------------------------------------------------------------------
        .byte   $1B                             ; B8BF 1B       .
; ----------------------------------------------------------------------------
        .word   osword_7f_command_1b-1          ; B8C0 EC B7    ..
; ----------------------------------------------------------------------------
        .byte   $23                             ; B8C2 23       #
; ----------------------------------------------------------------------------
        .word   osword_7f_command_23-1          ; B8C3 3D B8    =.
; ----------------------------------------------------------------------------
        .byte   $2C                             ; B8C5 2C       ,
; ----------------------------------------------------------------------------
        .word   osword_7f_read_drive_status-1   ; B8C6 58 B8    X.
; ----------------------------------------------------------------------------
        .byte   $35                             ; B8C8 35       5
; ----------------------------------------------------------------------------
        .word   osword_7f_initialise-1          ; B8C9 62 B8    b.
; ----------------------------------------------------------------------------
        .byte   $3A                             ; B8CB 3A       :
; ----------------------------------------------------------------------------
        .word   osword_7f_write_special_registers-1; B8CC 6E B8 n.
; ----------------------------------------------------------------------------
        .byte   $3D                             ; B8CE 3D       =
; ----------------------------------------------------------------------------
        .word   osword_7f_read_special_registers-1; B8CF 8B B8  ..
; ----------------------------------------------------------------------------
        .byte   $00                             ; B8D1 00       .
; ----------------------------------------------------------------------------
LB8D2:  jsr     push_registers_and_tuck_restoration_thunk; B8D2 20 4C A8 L.
        jsr     LB74C                           ; B8D5 20 4C B7  L.
        beq     LB8EE                           ; B8D8 F0 14    ..
        jsr     LAAD9                           ; B8DA 20 D9 AA  ..
        and     #$07                            ; B8DD 29 07    ).
        tax                                     ; B8DF AA       .
        lda     $FDED                           ; B8E0 AD ED FD ...
        and     #$7F                            ; B8E3 29 7F    ).
        eor     #$40                            ; B8E5 49 40    I@
        lsr     a                               ; B8E7 4A       J
        ora     fdc_control_table,x             ; B8E8 1D EF B8 ...
        sta     fdc_control                     ; B8EB 8D FC FC ...
LB8EE:  rts                                     ; B8EE 60       `

; ----------------------------------------------------------------------------
fdc_control_table:
        .byte   $12,$14,$13,$15,$FF,$FF,$18,$19 ; B8EF 12 14 13 15 FF FF 18 19........
; ----------------------------------------------------------------------------
LB8F7:  jsr     push_registers_and_tuck_restoration_thunk; B8F7 20 4C A8 L.
        jsr     osbyte_aff_x00_yff              ; B8FA 20 F0 AD  ..
        txa                                     ; B8FD 8A       .
        jsr     extract_00xx0000                ; B8FE 20 96 A9  ..
LB901:  sta     $FDF2                           ; B901 8D F2 FD ...
        rts                                     ; B904 60       `

; ----------------------------------------------------------------------------
LB905:  jsr     LB74C                           ; B905 20 4C B7  L.
        beq     LB913                           ; B908 F0 09    ..
        jsr     LB9F3                           ; B90A 20 F3 B9  ..
        jsr     LBD16                           ; B90D 20 16 BD  ..
        and     #$40                            ; B910 29 40    )@
        rts                                     ; B912 60       `

; ----------------------------------------------------------------------------
LB913:  lda     #$00                            ; B913 A9 00    ..
        rts                                     ; B915 60       `

; ----------------------------------------------------------------------------
LB916:  jsr     select_ram_page_001             ; B916 20 0C BE  ..
        lda     $BA                             ; B919 A5 BA    ..
        bit     $FDEA                           ; B91B 2C EA FD ,..
        bvc     LB921                           ; B91E 50 01    P.
        asl     a                               ; B920 0A       .
LB921:  jsr     LB8D2                           ; B921 20 D2 B8  ..
        jsr     LA875                           ; B924 20 75 A8  u.
        pha                                     ; B927 48       H
        jsr     LBCA0                           ; B928 20 A0 BC  ..
        lda     $FDEF,x                         ; B92B BD EF FD ...
        jsr     LBC9C                           ; B92E 20 9C BC  ..
        pla                                     ; B931 68       h
        sta     $FDEF,x                         ; B932 9D EF FD ...
        jsr     write_data                      ; B935 20 02 BD  ..
        cmp     #$00                            ; B938 C9 00    ..
        beq     LB93E                           ; B93A F0 02    ..
        lda     #$10                            ; B93C A9 10    ..
LB93E:  bit     fdc_status_or_cmd               ; B93E 2C F8 FC ,..
        php                                     ; B941 08       .
        ora     $FDF2                           ; B942 0D F2 FD ...
        jsr     write_command                   ; B945 20 FA BC  ..
        jsr     LBD16                           ; B948 20 16 BD  ..
        plp                                     ; B94B 28       (
        bmi     LB95E                           ; B94C 30 10    0.
        lda     $FDE9                           ; B94E AD E9 FD ...
        lsr     a                               ; B951 4A       J
        bcc     LB95E                           ; B952 90 0A    ..
        ldy     #$00                            ; B954 A0 00    ..
LB956:  nop                                     ; B956 EA       .
        nop                                     ; B957 EA       .
        dex                                     ; B958 CA       .
        bne     LB956                           ; B959 D0 FB    ..
        dey                                     ; B95B 88       .
        bne     LB956                           ; B95C D0 F8    ..
LB95E:  rts                                     ; B95E 60       `

; ----------------------------------------------------------------------------
LB95F:  jsr     LA875                           ; B95F 20 75 A8  u.
        jsr     select_ram_page_001             ; B962 20 0C BE  ..
        jsr     LB9F3                           ; B965 20 F3 B9  ..
        ldx     #$05                            ; B968 A2 05    ..
        bit     $FDED                           ; B96A 2C ED FD ,..
        bvc     LB982                           ; B96D 50 13    P.
        dex                                     ; B96F CA       .
LB970:  lda     $FDED                           ; B970 AD ED FD ...
        ora     #$40                            ; B973 09 40    .@
        ldy     #$12                            ; B975 A0 12    ..
        jsr     LB9AC                           ; B977 20 AC B9  ..
        beq     LB9A9                           ; B97A F0 2D    .-
        bit     $FDED                           ; B97C 2C ED FD ,..
        bpl     LB996                           ; B97F 10 15    ..
        dex                                     ; B981 CA       .
LB982:  lda     $FDED                           ; B982 AD ED FD ...
        and     #$BF                            ; B985 29 BF    ).
        ldy     #$0A                            ; B987 A0 0A    ..
        jsr     LB9AC                           ; B989 20 AC B9  ..
        beq     LB9A9                           ; B98C F0 1B    ..
        bit     $FDED                           ; B98E 2C ED FD ,..
        bpl     LB996                           ; B991 10 03    ..
        dex                                     ; B993 CA       .
        bne     LB970                           ; B994 D0 DA    ..
LB996:  lda     $FDED                           ; B996 AD ED FD ...
        and     #$BF                            ; B999 29 BF    ).
        sta     $FDED                           ; B99B 8D ED FD ...
        jsr     LB8D2                           ; B99E 20 D2 B8  ..
        lda     #$0A                            ; B9A1 A9 0A    ..
        sta     $FDEB                           ; B9A3 8D EB FD ...
        lda     #$18                            ; B9A6 A9 18    ..
        rts                                     ; B9A8 60       `

; ----------------------------------------------------------------------------
LB9A9:  lda     #$00                            ; B9A9 A9 00    ..
        rts                                     ; B9AB 60       `

; ----------------------------------------------------------------------------
LB9AC:  sta     $FDED                           ; B9AC 8D ED FD ...
        sty     $FDEB                           ; B9AF 8C EB FD ...
LB9B2:  jsr     LA875                           ; B9B2 20 75 A8  u.
        jsr     LB916                           ; B9B5 20 16 B9  ..
        ldy     #$0B                            ; B9B8 A0 0B    ..
LB9BA:  lda     LBDBA,y                         ; B9BA B9 BA BD ...
        sta     L0D00,y                         ; B9BD 99 00 0D ...
        dey                                     ; B9C0 88       .
        bpl     LB9BA                           ; B9C1 10 F7    ..
        php                                     ; B9C3 08       .
        ldx     $BB                             ; B9C4 A6 BB    ..
        beq     LB9D0                           ; B9C6 F0 08    ..
        sei                                     ; B9C8 78       x
LB9C9:  lda     fdc_status_or_cmd               ; B9C9 AD F8 FC ...
        and     #$02                            ; B9CC 29 02    ).
        beq     LB9C9                           ; B9CE F0 F9    ..
LB9D0:  ldy     #$00                            ; B9D0 A0 00    ..
LB9D2:  dey                                     ; B9D2 88       .
        bne     LB9D2                           ; B9D3 D0 FD    ..
        lda     #$C0                            ; B9D5 A9 C0    ..
        sta     fdc_status_or_cmd               ; B9D7 8D F8 FC ...
        jsr     LBD16                           ; B9DA 20 16 BD  ..
        bne     LB9EA                           ; B9DD D0 0B    ..
        dec     $0D05                           ; B9DF CE 05 0D ...
        dec     $0D05                           ; B9E2 CE 05 0D ...
        dex                                     ; B9E5 CA       .
        bmi     LB9EA                           ; B9E6 30 02    0.
        bne     LB9D0                           ; B9E8 D0 E6    ..
LB9EA:  plp                                     ; B9EA 28       (
        lda     fdc_status_or_cmd               ; B9EB AD F8 FC ...
        and     #$18                            ; B9EE 29 18    ).
        jmp     select_ram_page_001             ; B9F0 4C 0C BE L..

; ----------------------------------------------------------------------------
LB9F3:  jsr     LB8D2                           ; B9F3 20 D2 B8  ..
        lda     #$18                            ; B9F6 A9 18    ..
        jsr     write_command                   ; B9F8 20 FA BC  ..
        ldx     #$0F                            ; B9FB A2 0F    ..
LB9FD:  dex                                     ; B9FD CA       .
        bne     LB9FD                           ; B9FE D0 FD    ..
LBA00:  lda     #$D0                            ; BA00 A9 D0    ..
        jmp     write_command                   ; BA02 4C FA BC L..

; ----------------------------------------------------------------------------
LBA05:  jsr     LA875                           ; BA05 20 75 A8  u.
        lda     #$00                            ; BA08 A9 00    ..
        sta     $BB                             ; BA0A 85 BB    ..
        sta     $A0                             ; BA0C 85 A0    ..
        lda     $FDEB                           ; BA0E AD EB FD ...
        sta     $A1                             ; BA11 85 A1    ..
        lda     #$04                            ; BA13 A9 04    ..
        sta     $FDE9                           ; BA15 8D E9 FD ...
LBA18:  jsr     LA875                           ; BA18 20 75 A8  u.
        jsr     LB74C                           ; BA1B 20 4C B7  L.
        bne     LBA23                           ; BA1E D0 03    ..
        jmp     LBE67                           ; BA20 4C 67 BE Lg.

; ----------------------------------------------------------------------------
LBA23:  lda     $A0                             ; BA23 A5 A0    ..
        pha                                     ; BA25 48       H
        lda     $A1                             ; BA26 A5 A1    ..
        pha                                     ; BA28 48       H
        jsr     LB8D2                           ; BA29 20 D2 B8  ..
        jsr     LB916                           ; BA2C 20 16 B9  ..
        lda     $BA                             ; BA2F A5 BA    ..
        jsr     LBC94                           ; BA31 20 94 BC  ..
        jsr     LBAFB                           ; BA34 20 FB BA  ..
        lda     $FDEE                           ; BA37 AD EE FD ...
        sta     $0D2D                           ; BA3A 8D 2D 0D .-.
        lda     $FDE9                           ; BA3D AD E9 FD ...
        pha                                     ; BA40 48       H
        and     #$05                            ; BA41 29 05    ).
        beq     LBA4E                           ; BA43 F0 09    ..
        ror     a                               ; BA45 6A       j
        bcs     LBA58                           ; BA46 B0 10    ..
        jsr     LBAEF                           ; BA48 20 EF BA  ..
        jmp     LBA6A                           ; BA4B 4C 6A BA Lj.

; ----------------------------------------------------------------------------
LBA4E:  lda     $A0                             ; BA4E A5 A0    ..
        beq     LBA54                           ; BA50 F0 02    ..
        inc     $A1                             ; BA52 E6 A1    ..
LBA54:  ldy     #$07                            ; BA54 A0 07    ..
        bne     LBA67                           ; BA56 D0 0F    ..
LBA58:  lda     $A0                             ; BA58 A5 A0    ..
        beq     LBA5E                           ; BA5A F0 02    ..
        inc     $A1                             ; BA5C E6 A1    ..
LBA5E:  lda     #$00                            ; BA5E A9 00    ..
        sta     $A0                             ; BA60 85 A0    ..
        jsr     LBB07                           ; BA62 20 07 BB  ..
        ldy     #$04                            ; BA65 A0 04    ..
LBA67:  jsr     LBAA0                           ; BA67 20 A0 BA  ..
LBA6A:  lda     $F4                             ; BA6A A5 F4    ..
        sta     $0D38                           ; BA6C 8D 38 0D .8.
        lda     $BB                             ; BA6F A5 BB    ..
        jsr     write_sector                    ; BA71 20 FE BC  ..
        pla                                     ; BA74 68       h
        and     #$07                            ; BA75 29 07    ).
        pha                                     ; BA77 48       H
        tay                                     ; BA78 A8       .
        lda     LBD52,y                         ; BA79 B9 52 BD .R.
        jsr     write_command                   ; BA7C 20 FA BC  ..
        ldx     #$1E                            ; BA7F A2 1E    ..
LBA81:  dex                                     ; BA81 CA       .
        bne     LBA81                           ; BA82 D0 FD    ..
        jsr     L0D2C                           ; BA84 20 2C 0D  ,.
        jsr     select_ram_page_001             ; BA87 20 0C BE  ..
        pla                                     ; BA8A 68       h
        tay                                     ; BA8B A8       .
        jsr     LBD27                           ; BA8C 20 27 BD  '.
        and     LBD57,y                         ; BA8F 39 57 BD 9W.
        tay                                     ; BA92 A8       .
        jsr     LBC8C                           ; BA93 20 8C BC  ..
LBA96:  pla                                     ; BA96 68       h
        sta     $A1                             ; BA97 85 A1    ..
        pla                                     ; BA99 68       h
        sta     $A0                             ; BA9A 85 A0    ..
        tya                                     ; BA9C 98       .
        jmp     select_ram_page_001             ; BA9D 4C 0C BE L..

; ----------------------------------------------------------------------------
LBAA0:  lda     $FDE9                           ; BAA0 AD E9 FD ...
        bmi     LBACF                           ; BAA3 30 2A    0*
        lda     $FDCC                           ; BAA5 AD CC FD ...
        beq     LBAC4                           ; BAA8 F0 1A    ..
        lda     #$E5                            ; BAAA A9 E5    ..
        sta     L0D00,y                         ; BAAC 99 00 0D ...
        lda     #$FE                            ; BAAF A9 FE    ..
        sta     $0D01,y                         ; BAB1 99 01 0D ...
        lda     #$4C                            ; BAB4 A9 4C    .L
        sta     $0D09                           ; BAB6 8D 09 0D ...
        lda     #$11                            ; BAB9 A9 11    ..
        sta     $0D0A                           ; BABB 8D 0A 0D ...
        lda     #$0D                            ; BABE A9 0D    ..
        sta     $0D0B                           ; BAC0 8D 0B 0D ...
        rts                                     ; BAC3 60       `

; ----------------------------------------------------------------------------
LBAC4:  lda     $A6                             ; BAC4 A5 A6    ..
        sta     L0D00,y                         ; BAC6 99 00 0D ...
        lda     $A7                             ; BAC9 A5 A7    ..
        sta     $0D01,y                         ; BACB 99 01 0D ...
        rts                                     ; BACE 60       `

; ----------------------------------------------------------------------------
LBACF:  lda     #$20                            ; BACF A9 20    . 
        sta     $0D0E                           ; BAD1 8D 0E 0D ...
        lda     #$3D                            ; BAD4 A9 3D    .=
        sta     $0D0F                           ; BAD6 8D 0F 0D ...
        lda     #$0D                            ; BAD9 A9 0D    ..
        sta     $0D10                           ; BADB 8D 10 0D ...
        lda     $A6                             ; BADE A5 A6    ..
        sta     $0D41                           ; BAE0 8D 41 0D .A.
        sta     ram_paging_lsb                  ; BAE3 8D FF FC ...
        lda     $A7                             ; BAE6 A5 A7    ..
        sta     $0D4B                           ; BAE8 8D 4B 0D .K.
        sta     ram_paging_msb                  ; BAEB 8D FE FC ...
        rts                                     ; BAEE 60       `

; ----------------------------------------------------------------------------
LBAEF:  ldy     #$02                            ; BAEF A0 02    ..
LBAF1:  lda     LBDC6,y                         ; BAF1 B9 C6 BD ...
        sta     $0D06,y                         ; BAF4 99 06 0D ...
        dey                                     ; BAF7 88       .
        bpl     LBAF1                           ; BAF8 10 F7    ..
        rts                                     ; BAFA 60       `

; ----------------------------------------------------------------------------
LBAFB:  ldy     #$4F                            ; BAFB A0 4F    .O
LBAFD:  lda     LBD5C,y                         ; BAFD B9 5C BD .\.
        sta     L0D00,y                         ; BB00 99 00 0D ...
        dey                                     ; BB03 88       .
        bpl     LBAFD                           ; BB04 10 F7    ..
        rts                                     ; BB06 60       `

; ----------------------------------------------------------------------------
LBB07:  ldy     #$0D                            ; BB07 A0 0D    ..
LBB09:  lda     LBDAC,y                         ; BB09 B9 AC BD ...
        sta     $0D03,y                         ; BB0C 99 03 0D ...
        dey                                     ; BB0F 88       .
        bpl     LBB09                           ; BB10 10 F7    ..
        lda     #$FC                            ; BB12 A9 FC    ..
        sta     $0D23                           ; BB14 8D 23 0D .#.
        rts                                     ; BB17 60       `

; ----------------------------------------------------------------------------
LBB18:  lda     #$0A                            ; BB18 A9 0A    ..
        bit     $FDED                           ; BB1A 2C ED FD ,..
        bvc     LBB21                           ; BB1D 50 02    P.
        lda     #$12                            ; BB1F A9 12    ..
LBB21:  sta     $A6                             ; BB21 85 A6    ..
        sta     $FDEB                           ; BB23 8D EB FD ...
        asl     a                               ; BB26 0A       .
        asl     a                               ; BB27 0A       .
        sta     $A7                             ; BB28 85 A7    ..
        ldx     $BB                             ; BB2A A6 BB    ..
        ldy     #$00                            ; BB2C A0 00    ..
LBB2E:  lda     $BA                             ; BB2E A5 BA    ..
        sta     $FD61,y                         ; BB30 99 61 FD .a.
        iny                                     ; BB33 C8       .
        lda     #$00                            ; BB34 A9 00    ..
        sta     $FD61,y                         ; BB36 99 61 FD .a.
        iny                                     ; BB39 C8       .
        txa                                     ; BB3A 8A       .
        sta     $FD61,y                         ; BB3B 99 61 FD .a.
        iny                                     ; BB3E C8       .
        lda     #$01                            ; BB3F A9 01    ..
        sta     $FD61,y                         ; BB41 99 61 FD .a.
        iny                                     ; BB44 C8       .
        inx                                     ; BB45 E8       .
        cpx     $A6                             ; BB46 E4 A6    ..
        bcc     LBB4C                           ; BB48 90 02    ..
        ldx     #$00                            ; BB4A A2 00    ..
LBB4C:  cpy     $A7                             ; BB4C C4 A7    ..
        bcc     LBB2E                           ; BB4E 90 DE    ..
        lda     #$61                            ; BB50 A9 61    .a
        sta     $A6                             ; BB52 85 A6    ..
        lda     #$FD                            ; BB54 A9 FD    ..
        sta     $A7                             ; BB56 85 A7    ..
LBB58:  lda     #$12                            ; BB58 A9 12    ..
        sta     $A4                             ; BB5A 85 A4    ..
        lda     #$06                            ; BB5C A9 06    ..
        pha                                     ; BB5E 48       H
        sta     $A5                             ; BB5F 85 A5    ..
        ldx     #$00                            ; BB61 A2 00    ..
        bit     $FDED                           ; BB63 2C ED FD ,..
        bvc     LBB6A                           ; BB66 50 02    P.
        ldx     #$23                            ; BB68 A2 23    .#
LBB6A:  lda     $FDEB                           ; BB6A AD EB FD ...
        sta     $A2                             ; BB6D 85 A2    ..
        jsr     LBC3A                           ; BB6F 20 3A BC  :.
        ldy     #$05                            ; BB72 A0 05    ..
LBB74:  jsr     LBBBB                           ; BB74 20 BB BB  ..
        dey                                     ; BB77 88       .
        bne     LBB74                           ; BB78 D0 FA    ..
        stx     $A3                             ; BB7A 86 A3    ..
LBB7C:  ldx     $A3                             ; BB7C A6 A3    ..
LBB7E:  jsr     LBBBB                           ; BB7E 20 BB BB  ..
        bcc     LBB7E                           ; BB81 90 FB    ..
        dec     $A2                             ; BB83 C6 A2    ..
        bne     LBB7C                           ; BB85 D0 F5    ..
        lda     #$00                            ; BB87 A9 00    ..
        jsr     LBC14                           ; BB89 20 14 BC  ..
        jsr     select_ram_page_001             ; BB8C 20 0C BE  ..
        jsr     LB916                           ; BB8F 20 16 B9  ..
        ldx     #$FF                            ; BB92 A2 FF    ..
        ldy     #$10                            ; BB94 A0 10    ..
        bit     $FDED                           ; BB96 2C ED FD ,..
        bvc     LBB9F                           ; BB99 50 04    P.
        ldy     #$28                            ; BB9B A0 28    .(
        ldx     #$4E                            ; BB9D A2 4E    .N
LBB9F:  sty     $A0                             ; BB9F 84 A0    ..
        pla                                     ; BBA1 68       h
        jsr     LBE1D                           ; BBA2 20 1D BE  ..
        stx     $FD92                           ; BBA5 8E 92 FD ...
        ldy     #$3C                            ; BBA8 A0 3C    .<
LBBAA:  lda     LBDC9,y                         ; BBAA B9 C9 BD ...
        sta     L0D00,y                         ; BBAD 99 00 0D ...
        dey                                     ; BBB0 88       .
        bpl     LBBAA                           ; BBB1 10 F7    ..
        lda     #$F4                            ; BBB3 A9 F4    ..
        jsr     write_command                   ; BBB5 20 FA BC  ..
        jmp     LBD16                           ; BBB8 4C 16 BD L..

; ----------------------------------------------------------------------------
LBBBB:  txa                                     ; BBBB 8A       .
        pha                                     ; BBBC 48       H
        tya                                     ; BBBD 98       .
        pha                                     ; BBBE 48       H
        ldy     #$00                            ; BBBF A0 00    ..
        sec                                     ; BBC1 38       8
        lda     LBC42,x                         ; BBC2 BD 42 BC .B.
        bmi     LBBD9                           ; BBC5 30 12    0.
        beq     LBBD2                           ; BBC7 F0 09    ..
        sta     $A0                             ; BBC9 85 A0    ..
        lda     LBC43,x                         ; BBCB BD 43 BC .C.
        jsr     LBC14                           ; BBCE 20 14 BC  ..
LBBD1:  clc                                     ; BBD1 18       .
LBBD2:  pla                                     ; BBD2 68       h
        tay                                     ; BBD3 A8       .
        pla                                     ; BBD4 68       h
        tax                                     ; BBD5 AA       .
        inx                                     ; BBD6 E8       .
        inx                                     ; BBD7 E8       .
        rts                                     ; BBD8 60       `

; ----------------------------------------------------------------------------
LBBD9:  lda     LBC43,x                         ; BBD9 BD 43 BC .C.
        bne     LBC00                           ; BBDC D0 22    ."
        lda     #$01                            ; BBDE A9 01    ..
        sta     $A0                             ; BBE0 85 A0    ..
        ldx     #$04                            ; BBE2 A2 04    ..
LBBE4:  jsr     select_ram_page_001             ; BBE4 20 0C BE  ..
        ldy     #$00                            ; BBE7 A0 00    ..
        jsr     LA4EC                           ; BBE9 20 EC A4  ..
        jsr     LBC3A                           ; BBEC 20 3A BC  :.
        jsr     LBC14                           ; BBEF 20 14 BC  ..
        inc     $A6                             ; BBF2 E6 A6    ..
        bne     LBBF8                           ; BBF4 D0 02    ..
        inc     $A7                             ; BBF6 E6 A7    ..
LBBF8:  dex                                     ; BBF8 CA       .
        bne     LBBE4                           ; BBF9 D0 E9    ..
        sta     $A1                             ; BBFB 85 A1    ..
        jmp     LBBD1                           ; BBFD 4C D1 BB L..

; ----------------------------------------------------------------------------
LBC00:  ldx     $A1                             ; BC00 A6 A1    ..
        lda     LBC88,x                         ; BC02 BD 88 BC ...
        sta     $A0                             ; BC05 85 A0    ..
        ldx     #$08                            ; BC07 A2 08    ..
        lda     #$E5                            ; BC09 A9 E5    ..
LBC0B:  jsr     LBC14                           ; BC0B 20 14 BC  ..
        dex                                     ; BC0E CA       .
        bne     LBC0B                           ; BC0F D0 FA    ..
        jmp     LBBD1                           ; BC11 4C D1 BB L..

; ----------------------------------------------------------------------------
LBC14:  pha                                     ; BC14 48       H
        ldy     $A4                             ; BC15 A4 A4    ..
        sta     $FD80,y                         ; BC17 99 80 FD ...
        lda     $A0                             ; BC1A A5 A0    ..
        sta     $FD00,y                         ; BC1C 99 00 FD ...
        lda     $A4                             ; BC1F A5 A4    ..
        bne     LBC2B                           ; BC21 D0 08    ..
        lda     $FD00                           ; BC23 AD 00 FD ...
        ora     #$80                            ; BC26 09 80    ..
        sta     $FD00                           ; BC28 8D 00 FD ...
LBC2B:  inc     $A4                             ; BC2B E6 A4    ..
        bpl     LBC38                           ; BC2D 10 09    ..
        lda     #$00                            ; BC2F A9 00    ..
        sta     $A4                             ; BC31 85 A4    ..
        inc     $A5                             ; BC33 E6 A5    ..
        jsr     LBC3A                           ; BC35 20 3A BC  :.
LBC38:  pla                                     ; BC38 68       h
        rts                                     ; BC39 60       `

; ----------------------------------------------------------------------------
LBC3A:  pha                                     ; BC3A 48       H
        lda     $A5                             ; BC3B A5 A5    ..
        jsr     LBE1D                           ; BC3D 20 1D BE  ..
        pla                                     ; BC40 68       h
        rts                                     ; BC41 60       `

; ----------------------------------------------------------------------------
LBC42:  .byte   $10                             ; BC42 10       .
LBC43:  .byte   $FF,$03,$00,$03,$00,$01,$FC,$0B ; BC43 FF 03 00 03 00 01 FC 0B........
        .byte   $FF,$03,$00,$03,$00,$01,$FE,$FF ; BC4B FF 03 00 03 00 01 FE FF........
        .byte   $00,$01,$F7,$0B,$FF,$03,$00,$03 ; BC53 00 01 F7 0B FF 03 00 03........
        .byte   $00,$01,$FB,$FF,$01,$01,$F7,$10 ; BC5B 00 01 FB FF 01 01 F7 10........
        .byte   $FF,$00,$28,$4E,$0C,$00,$03,$F6 ; BC63 FF 00 28 4E 0C 00 03 F6..(N....
        .byte   $01,$FC,$19,$4E,$0C,$00,$03,$F5 ; BC6B 01 FC 19 4E 0C 00 03 F5...N....
        .byte   $01,$FE,$FF,$00,$01,$F7,$16,$4E ; BC73 01 FE FF 00 01 F7 16 4E.......N
        .byte   $0C,$00,$03,$F5,$01,$FB,$FF,$01 ; BC7B 0C 00 03 F5 01 FB FF 01........
        .byte   $01,$F7,$16,$4E,$00             ; BC83 01 F7 16 4E 00...N.
LBC88:  .byte   $10,$20,$40,$80                 ; BC88 10 20 40 80. @.
; ----------------------------------------------------------------------------
LBC8C:  lda     $BA                             ; BC8C A5 BA    ..
        bit     $FDEA                           ; BC8E 2C EA FD ,..
        bvc     LBC94                           ; BC91 50 01    P.
        asl     a                               ; BC93 0A       .
LBC94:  pha                                     ; BC94 48       H
        jsr     LBCA0                           ; BC95 20 A0 BC  ..
        pla                                     ; BC98 68       h
        sta     $FDEF,x                         ; BC99 9D EF FD ...
LBC9C:  sta     fdc_track                       ; BC9C 8D F9 FC ...
        rts                                     ; BC9F 60       `

; ----------------------------------------------------------------------------
LBCA0:  jsr     LAAD9                           ; BCA0 20 D9 AA  ..
        and     #$07                            ; BCA3 29 07    ).
        ldx     #$02                            ; BCA5 A2 02    ..
        cmp     #$06                            ; BCA7 C9 06    ..
        bcs     LBCAE                           ; BCA9 B0 03    ..
        and     #$01                            ; BCAB 29 01    ).
        tax                                     ; BCAD AA       .
LBCAE:  rts                                     ; BCAE 60       `

; ----------------------------------------------------------------------------
LBCAF:  jsr     dobrk_with_Disk_prefix          ; BCAF 20 92 A8  ..
        .byte   $C5                             ; BCB2 C5       .
        .byte   "fault "                        ; BCB3 66 61 75 6C 74 20fault 
; ----------------------------------------------------------------------------
        nop                                     ; BCB9 EA       .
        lda     $FDF3                           ; BCBA AD F3 FD ...
        jsr     print_hex_byte                  ; BCBD 20 78 A9  x.
        jsr     print_string_nterm              ; BCC0 20 D3 A8  ..
        .byte   " at Trk "                      ; BCC3 20 61 74 20 54 72 6B 20 at Trk 
; ----------------------------------------------------------------------------
        nop                                     ; BCCB EA       .
        lda     $BA                             ; BCCC A5 BA    ..
        jsr     print_hex_byte                  ; BCCE 20 78 A9  x.
        jsr     print_string_nterm              ; BCD1 20 D3 A8  ..
        .byte   ", Sct "                        ; BCD4 2C 20 53 63 74 20, Sct 
; ----------------------------------------------------------------------------
        nop                                     ; BCDA EA       .
        lda     $BB                             ; BCDB A5 BB    ..
        jsr     print_hex_byte                  ; BCDD 20 78 A9  x.
        jmp     LA8F8                           ; BCE0 4C F8 A8 L..

; ----------------------------------------------------------------------------
LBCE3:  jsr     print_string_2_nterm            ; BCE3 20 AD A8  ..
        .byte   $C5                             ; BCE6 C5       .
        .byte   "Disk not formatted"            ; BCE7 44 69 73 6B 20 6E 6F 74Disk not
                                                ; BCEF 20 66 6F 72 6D 61 74 74 formatt
                                                ; BCF7 65 64    ed
; ----------------------------------------------------------------------------
        brk                                     ; BCF9 00       .
write_command:
        sta     fdc_status_or_cmd               ; BCFA 8D F8 FC ...
        rts                                     ; BCFD 60       `

; ----------------------------------------------------------------------------
write_sector:
        sta     fdc_sector                      ; BCFE 8D FA FC ...
        rts                                     ; BD01 60       `

; ----------------------------------------------------------------------------
write_data:
        sta     fdc_data                        ; BD02 8D FB FC ...
        rts                                     ; BD05 60       `

; ----------------------------------------------------------------------------
LBD06:  jsr     LB74C                           ; BD06 20 4C B7  L.
        beq     LBD13                           ; BD09 F0 08    ..
        lda     fdc_status_or_cmd               ; BD0B AD F8 FC ...
        eor     #$80                            ; BD0E 49 80    I.
        and     #$80                            ; BD10 29 80    ).
        rts                                     ; BD12 60       `

; ----------------------------------------------------------------------------
LBD13:  lda     #$00                            ; BD13 A9 00    ..
        rts                                     ; BD15 60       `

; ----------------------------------------------------------------------------
LBD16:  jsr     LA875                           ; BD16 20 75 A8  u.
        ldx     #$FF                            ; BD19 A2 FF    ..
LBD1B:  dex                                     ; BD1B CA       .
        bne     LBD1B                           ; BD1C D0 FD    ..
LBD1E:  jsr     LBD33                           ; BD1E 20 33 BD  3.
        lda     fdc_status_or_cmd               ; BD21 AD F8 FC ...
        ror     a                               ; BD24 6A       j
        bcs     LBD1E                           ; BD25 B0 F7    ..
LBD27:  lda     fdc_status_or_cmd               ; BD27 AD F8 FC ...
        and     #$7F                            ; BD2A 29 7F    ).
        jsr     select_ram_page_001             ; BD2C 20 0C BE  ..
        sta     $FDF3                           ; BD2F 8D F3 FD ...
        rts                                     ; BD32 60       `

; ----------------------------------------------------------------------------
LBD33:  lda     $B9                             ; BD33 A5 B9    ..
        beq     LBD51                           ; BD35 F0 1A    ..
        bit     $FF                             ; BD37 24 FF    $.
        bpl     LBD51                           ; BD39 10 16    ..
        jsr     LBA00                           ; BD3B 20 00 BA  ..
        lda     #$00                            ; BD3E A9 00    ..
        sta     fdc_control                     ; BD40 8D FC FC ...
        jsr     acknowledge_escape              ; BD43 20 8F A9  ..
        jsr     print_string_2_nterm            ; BD46 20 AD A8  ..
        .byte   $11                             ; BD49 11       .
        .byte   "Escape"                        ; BD4A 45 73 63 61 70 65Escape
; ----------------------------------------------------------------------------
        brk                                     ; BD50 00       .
LBD51:  rts                                     ; BD51 60       `

; ----------------------------------------------------------------------------
LBD52:  .byte   $90,$B4,$90,$B5,$90             ; BD52 90 B4 90 B5 90.....
LBD57:  .byte   $3C,$7C,$1C                     ; BD57 3C 7C 1C <|.
; ----------------------------------------------------------------------------
        .byte   $5C                             ; BD5A 5C       \
        .byte   $3C                             ; BD5B 3C       <
LBD5C:  sta     $0D2A                           ; BD5C 8D 2A 0D .*.
        lda     fdc_data                        ; BD5F AD FB FC ...
        sta     $FD00                           ; BD62 8D 00 FD ...
        inc     $0D07                           ; BD65 EE 07 0D ...
        bne     LBD6D                           ; BD68 D0 03    ..
        inc     $0D08                           ; BD6A EE 08 0D ...
LBD6D:  dec     $A0                             ; BD6D C6 A0    ..
        bne     LBD85                           ; BD6F D0 14    ..
        dec     $A1                             ; BD71 C6 A1    ..
        bne     LBD85                           ; BD73 D0 10    ..
        lda     #$40                            ; BD75 A9 40    .@
        sta     L0D00                           ; BD77 8D 00 0D ...
        lda     #$CE                            ; BD7A A9 CE    ..
        adc     #$01                            ; BD7C 69 01    i.
        bcc     LBD80                           ; BD7E 90 00    ..
LBD80:  lda     #$D0                            ; BD80 A9 D0    ..
        sta     fdc_status_or_cmd               ; BD82 8D F8 FC ...
LBD85:  lda     #$00                            ; BD85 A9 00    ..
        rti                                     ; BD87 40       @

; ----------------------------------------------------------------------------
        lda     #$0E                            ; BD88 A9 0E    ..
        sta     $FE30                           ; BD8A 8D 30 FE .0.
LBD8D:  lda     fdc_status_or_cmd               ; BD8D AD F8 FC ...
        ror     a                               ; BD90 6A       j
        bcs     LBD8D                           ; BD91 B0 FA    ..
        lda     #$00                            ; BD93 A9 00    ..
        sta     $FE30                           ; BD95 8D 30 FE .0.
        rts                                     ; BD98 60       `

; ----------------------------------------------------------------------------
        inc     $0D41                           ; BD99 EE 41 0D .A.
        lda     #$00                            ; BD9C A9 00    ..
        sta     ram_paging_lsb                  ; BD9E 8D FF FC ...
        bne     LBDAB                           ; BDA1 D0 08    ..
        inc     $0D4B                           ; BDA3 EE 4B 0D .K.
        lda     #$00                            ; BDA6 A9 00    ..
        sta     ram_paging_msb                  ; BDA8 8D FE FC ...
LBDAB:  rts                                     ; BDAB 60       `

; ----------------------------------------------------------------------------
LBDAC:  lda     $FD00                           ; BDAC AD 00 FD ...
        sta     fdc_data                        ; BDAF 8D FB FC ...
        inc     $0D04                           ; BDB2 EE 04 0D ...
        bne     LBDBA                           ; BDB5 D0 03    ..
        inc     $0D05                           ; BDB7 EE 05 0D ...
LBDBA:  pha                                     ; BDBA 48       H
        lda     fdc_data                        ; BDBB AD FB FC ...
        sta     $0D0C                           ; BDBE 8D 0C 0D ...
        inc     $0D05                           ; BDC1 EE 05 0D ...
        pla                                     ; BDC4 68       h
        rti                                     ; BDC5 40       @

; ----------------------------------------------------------------------------
LBDC6:  jmp     L0D11                           ; BDC6 4C 11 0D L..

; ----------------------------------------------------------------------------
LBDC9:  pha                                     ; BDC9 48       H
        lda     $FD92                           ; BDCA AD 92 FD ...
        sta     fdc_data                        ; BDCD 8D FB FC ...
        dec     $A0                             ; BDD0 C6 A0    ..
        bne     LBDEA                           ; BDD2 D0 16    ..
        inc     $0D02                           ; BDD4 EE 02 0D ...
        bne     LBDFC                           ; BDD7 D0 23    .#
        lda     #$80                            ; BDD9 A9 80    ..
        sta     $0D02                           ; BDDB 8D 02 0D ...
        lda     #$07                            ; BDDE A9 07    ..
        sta     ram_paging_lsb                  ; BDE0 8D FF FC ...
        lda     $FD00                           ; BDE3 AD 00 FD ...
        sta     $A0                             ; BDE6 85 A0    ..
LBDE8:  pla                                     ; BDE8 68       h
        rti                                     ; BDE9 40       @

; ----------------------------------------------------------------------------
LBDEA:  bpl     LBDE8                           ; BDEA 10 FC    ..
        lda     $A0                             ; BDEC A5 A0    ..
        and     #$7F                            ; BDEE 29 7F    ).
        sta     $A0                             ; BDF0 85 A0    ..
        lda     #$00                            ; BDF2 A9 00    ..
        sta     $0D37                           ; BDF4 8D 37 0D .7.
        inc     $0D16                           ; BDF7 EE 16 0D ...
        pla                                     ; BDFA 68       h
        rti                                     ; BDFB 40       @

; ----------------------------------------------------------------------------
LBDFC:  inc     $0D37                           ; BDFC EE 37 0D .7.
        lda     $FD12                           ; BDFF AD 12 FD ...
        sta     $A0                             ; BE02 85 A0    ..
        pla                                     ; BE04 68       h
        rti                                     ; BE05 40       @

; ----------------------------------------------------------------------------
        nop                                     ; BE06 EA       .
select_ram_page_000:
        pha                                     ; BE07 48       H
        lda     #$00                            ; BE08 A9 00    ..
        beq     select_ram_page_by_lsb          ; BE0A F0 12    ..
select_ram_page_001:
        pha                                     ; BE0C 48       H
        lda     #$01                            ; BE0D A9 01    ..
        bne     select_ram_page_by_lsb          ; BE0F D0 0D    ..
select_ram_page_002:
        pha                                     ; BE11 48       H
        lda     #$02                            ; BE12 A9 02    ..
        bne     select_ram_page_by_lsb          ; BE14 D0 08    ..
select_ram_page_003:
        pha                                     ; BE16 48       H
        lda     #$03                            ; BE17 A9 03    ..
        bne     select_ram_page_by_lsb          ; BE19 D0 03    ..
select_ram_page_009:
        lda     #$09                            ; BE1B A9 09    ..
LBE1D:  pha                                     ; BE1D 48       H
select_ram_page_by_lsb:
        sta     ram_paging_lsb                  ; BE1E 8D FF FC ...
        lda     #$00                            ; BE21 A9 00    ..
        sta     ram_paging_msb                  ; BE23 8D FE FC ...
        pla                                     ; BE26 68       h
        rts                                     ; BE27 60       `

; ----------------------------------------------------------------------------
chadfs_request_04:
        jsr     LAD88                           ; BE28 20 88 AD  ..
        jsr     select_ram_page_001             ; BE2B 20 0C BE  ..
        lda     #$01                            ; BE2E A9 01    ..
        sta     $FDE9                           ; BE30 8D E9 FD ...
        lda     #$00                            ; BE33 A9 00    ..
        sta     $A0                             ; BE35 85 A0    ..
        lda     #$02                            ; BE37 A9 02    ..
        sta     $A1                             ; BE39 85 A1    ..
        lda     #$00                            ; BE3B A9 00    ..
        sta     $A6                             ; BE3D 85 A6    ..
        lda     #$C0                            ; BE3F A9 C0    ..
        sta     $A7                             ; BE41 85 A7    ..
        lda     #$00                            ; BE43 A9 00    ..
        sta     $FDCC                           ; BE45 8D CC FD ...
        lda     #$00                            ; BE48 A9 00    ..
        sta     $BA                             ; BE4A 85 BA    ..
        sta     $BB                             ; BE4C 85 BB    ..
        lda     #$04                            ; BE4E A9 04    ..
        jsr     LBE7C                           ; BE50 20 7C BE  |.
        lda     #$C9                            ; BE53 A9 C9    ..
        sta     $A7                             ; BE55 85 A7    ..
        lda     #$02                            ; BE57 A9 02    ..
        sta     $BB                             ; BE59 85 BB    ..
        lda     #$05                            ; BE5B A9 05    ..
        sta     $A1                             ; BE5D 85 A1    ..
        lda     #$04                            ; BE5F A9 04    ..
        jsr     LBE7C                           ; BE61 20 7C BE  |.
        lda     #$00                            ; BE64 A9 00    ..
        rts                                     ; BE66 60       `

; ----------------------------------------------------------------------------
LBE67:  jsr     select_ram_page_001             ; BE67 20 0C BE  ..
        ldy     #$10                            ; BE6A A0 10    ..
        lda     $FDED                           ; BE6C AD ED FD ...
        eor     $FDFE                           ; BE6F 4D FE FD M..
        and     #$40                            ; BE72 29 40    )@
        beq     LBE79                           ; BE74 F0 03    ..
        lda     #$10                            ; BE76 A9 10    ..
        rts                                     ; BE78 60       `

; ----------------------------------------------------------------------------
LBE79:  jsr     LAAD9                           ; BE79 20 D9 AA  ..
LBE7C:  ldy     #$0A                            ; BE7C A0 0A    ..
        ldx     #$00                            ; BE7E A2 00    ..
        cmp     #$04                            ; BE80 C9 04    ..
        beq     LBE88                           ; BE82 F0 04    ..
        ldy     #$00                            ; BE84 A0 00    ..
        ldx     #$04                            ; BE86 A2 04    ..
LBE88:  lda     $A0                             ; BE88 A5 A0    ..
        pha                                     ; BE8A 48       H
        lda     $A1                             ; BE8B A5 A1    ..
        pha                                     ; BE8D 48       H
        txa                                     ; BE8E 8A       .
        pha                                     ; BE8F 48       H
        tya                                     ; BE90 98       .
        pha                                     ; BE91 48       H
        lda     $A0                             ; BE92 A5 A0    ..
        beq     LBE98                           ; BE94 F0 02    ..
        inc     $A1                             ; BE96 E6 A1    ..
LBE98:  ldy     #$46                            ; BE98 A0 46    .F
LBE9A:  lda     LBF2F,y                         ; BE9A B9 2F BF ./.
        sta     L0D00,y                         ; BE9D 99 00 0D ...
        dey                                     ; BEA0 88       .
        bpl     LBE9A                           ; BEA1 10 F7    ..
        lda     $FDE9                           ; BEA3 AD E9 FD ...
        bmi     LBEF6                           ; BEA6 30 4E    0N
        bne     LBEC0                           ; BEA8 D0 16    ..
        lda     $A6                             ; BEAA A5 A6    ..
        sta     $0D22                           ; BEAC 8D 22 0D .".
        lda     $A7                             ; BEAF A5 A7    ..
        sta     $0D23                           ; BEB1 8D 23 0D .#.
        lda     $FDCC                           ; BEB4 AD CC FD ...
        beq     LBF16                           ; BEB7 F0 5D    .]
        lda     #$8D                            ; BEB9 A9 8D    ..
        ldy     #$03                            ; BEBB A0 03    ..
        jmp     LBED8                           ; BEBD 4C D8 BE L..

; ----------------------------------------------------------------------------
LBEC0:  lda     $A6                             ; BEC0 A5 A6    ..
        sta     $0D1F                           ; BEC2 8D 1F 0D ...
        lda     $A7                             ; BEC5 A5 A7    ..
        sta     $0D20                           ; BEC7 8D 20 0D . .
        lda     #$20                            ; BECA A9 20    . 
        sta     $0D28                           ; BECC 8D 28 0D .(.
        lda     $FDCC                           ; BECF AD CC FD ...
        beq     LBF16                           ; BED2 F0 42    .B
        lda     #$AD                            ; BED4 A9 AD    ..
        ldy     #$00                            ; BED6 A0 00    ..
LBED8:  sta     $0D1E,y                         ; BED8 99 1E 0D ...
        lda     #$E5                            ; BEDB A9 E5    ..
        sta     $0D1F,y                         ; BEDD 99 1F 0D ...
        lda     #$FE                            ; BEE0 A9 FE    ..
        sta     $0D20,y                         ; BEE2 99 20 0D . .
        lda     #$F4                            ; BEE5 A9 F4    ..
        sta     $0D26                           ; BEE7 8D 26 0D .&.
        lda     #$E1                            ; BEEA A9 E1    ..
        sta     $0D39                           ; BEEC 8D 39 0D .9.
        lda     #$AD                            ; BEEF A9 AD    ..
        sta     $0D27                           ; BEF1 8D 27 0D .'.
        bne     LBF16                           ; BEF4 D0 20    . 
LBEF6:  ldy     #$31                            ; BEF6 A0 31    .1
LBEF8:  lda     LBF76,y                         ; BEF8 B9 76 BF .v.
        sta     L0D00,y                         ; BEFB 99 00 0D ...
        dey                                     ; BEFE 88       .
        bpl     LBEF8                           ; BEFF 10 F7    ..
        ldy     #$00                            ; BF01 A0 00    ..
        ldx     #$12                            ; BF03 A2 12    ..
        lda     $FDE9                           ; BF05 AD E9 FD ...
        and     #$7F                            ; BF08 29 7F    ).
        beq     LBF10                           ; BF0A F0 04    ..
        ldy     #$0D                            ; BF0C A0 0D    ..
        ldx     #$05                            ; BF0E A2 05    ..
LBF10:  lda     $A6                             ; BF10 A5 A6    ..
        sta     $0D01,x                         ; BF12 9D 01 0D ...
        .byte   $AD                             ; BF15 AD       .
LBF16:  ldy     #$11                            ; BF16 A0 11    ..
        clc                                     ; BF18 18       .
        pla                                     ; BF19 68       h
        adc     $BB                             ; BF1A 65 BB    e.
        sta     $0D06,y                         ; BF1C 99 06 0D ...
        pla                                     ; BF1F 68       h
        adc     $BA                             ; BF20 65 BA    e.
        sta     $0D01,y                         ; BF22 99 01 0D ...
        ldy     #$00                            ; BF25 A0 00    ..
        jsr     L0D00                           ; BF27 20 00 0D  ..
        ldy     #$00                            ; BF2A A0 00    ..
        jmp     LBA96                           ; BF2C 4C 96 BA L..

; ----------------------------------------------------------------------------
LBF2F:  lda     $FDEE                           ; BF2F AD EE FD ...
        sta     $FE30                           ; BF32 8D 30 FE .0.
LBF35:  lda     $A1                             ; BF35 A5 A1    ..
        cmp     #$01                            ; BF37 C9 01    ..
        bne     LBF40                           ; BF39 D0 05    ..
        lda     #$0F                            ; BF3B A9 0F    ..
        sta     $0D26                           ; BF3D 8D 26 0D .&.
LBF40:  ldx     #$00                            ; BF40 A2 00    ..
        stx     ram_paging_msb                  ; BF42 8E FE FC ...
        ldx     #$00                            ; BF45 A2 00    ..
        stx     ram_paging_lsb                  ; BF47 8E FF FC ...
        jsr     L0D40                           ; BF4A 20 40 0D  @.
LBF4D:  lda     $FD00,y                         ; BF4D B9 00 FD ...
        sta     $FD00,y                         ; BF50 99 00 FD ...
        iny                                     ; BF53 C8       .
        bne     LBF4D                           ; BF54 D0 F7    ..
        inc     $0D23                           ; BF56 EE 23 0D .#.
        inc     $0D17                           ; BF59 EE 17 0D ...
        bne     LBF61                           ; BF5C D0 03    ..
        inc     $0D12                           ; BF5E EE 12 0D ...
LBF61:  dec     $A1                             ; BF61 C6 A1    ..
        bne     LBF35                           ; BF63 D0 D0    ..
        dec     $A0                             ; BF65 C6 A0    ..
        bne     LBF4D                           ; BF67 D0 E4    ..
        lda     $F4                             ; BF69 A5 F4    ..
        sta     $FE30                           ; BF6B 8D 30 FE .0.
        rts                                     ; BF6E 60       `

; ----------------------------------------------------------------------------
        jsr     L0D46                           ; BF6F 20 46 0D  F.
        jsr     L0D46                           ; BF72 20 46 0D  F.
        rts                                     ; BF75 60       `

; ----------------------------------------------------------------------------
LBF76:  ldx     #$00                            ; BF76 A2 00    ..
        stx     ram_paging_msb                  ; BF78 8E FE FC ...
        ldx     #$00                            ; BF7B A2 00    ..
        stx     ram_paging_lsb                  ; BF7D 8E FF FC ...
        lda     $FD00,y                         ; BF80 B9 00 FD ...
        ldx     #$00                            ; BF83 A2 00    ..
        stx     ram_paging_msb                  ; BF85 8E FE FC ...
        ldx     #$00                            ; BF88 A2 00    ..
        stx     ram_paging_lsb                  ; BF8A 8E FF FC ...
        sta     $FD00,y                         ; BF8D 99 00 FD ...
        iny                                     ; BF90 C8       .
        bne     LBF76                           ; BF91 D0 E3    ..
        inc     $0D06                           ; BF93 EE 06 0D ...
        bne     LBF9B                           ; BF96 D0 03    ..
        inc     $0D01                           ; BF98 EE 01 0D ...
LBF9B:  inc     $0D13                           ; BF9B EE 13 0D ...
        bne     LBFA3                           ; BF9E D0 03    ..
        inc     $0D0E                           ; BFA0 EE 0E 0D ...
LBFA3:  dec     $A1                             ; BFA3 C6 A1    ..
        bne     LBF76                           ; BFA5 D0 CF    ..
        rts                                     ; BFA7 60       `

; ----------------------------------------------------------------------------
chadfs_request_01:
        lda     #$00                            ; BFA8 A9 00    ..
        sta     $FDEC                           ; BFAA 8D EC FD ...
        lda     $FDED                           ; BFAD AD ED FD ...
        ora     #$40                            ; BFB0 09 40    .@
        sta     $FDED                           ; BFB2 8D ED FD ...
        jsr     L8AE4                           ; BFB5 20 E4 8A  ..
        jmp     LACF0                           ; BFB8 4C F0 AC L..

; ----------------------------------------------------------------------------
LBFBB:  .byte   $F5,$A7,$1E,$7D,$27             ; BFBB F5 A7 1E 7D 27...}'
LBFC0:  .byte   $AA,$BF,$82,$AB,$BE             ; BFC0 AA BF 82 AB BE.....
; ----------------------------------------------------------------------------
LBFC5:  tax                                     ; BFC5 AA       .
        jsr     select_ram_page_001             ; BFC6 20 0C BE  ..
        lda     #$FF                            ; BFC9 A9 FF    ..
        sta     $FDFF                           ; BFCB 8D FF FD ...
        lda     #$BF                            ; BFCE A9 BF    ..
        pha                                     ; BFD0 48       H
        lda     #$F3                            ; BFD1 A9 F3    ..
        pha                                     ; BFD3 48       H
        lda     LBFC0,x                         ; BFD4 BD C0 BF ...
        pha                                     ; BFD7 48       H
        lda     LBFBB,x                         ; BFD8 BD BB BF ...
        pha                                     ; BFDB 48       H
        rts                                     ; BFDC 60       `

; ----------------------------------------------------------------------------
        brk                                     ; BFDD 00       .
        brk                                     ; BFDE 00       .
        brk                                     ; BFDF 00       .
        brk                                     ; BFE0 00       .
        brk                                     ; BFE1 00       .
        brk                                     ; BFE2 00       .
        brk                                     ; BFE3 00       .
        brk                                     ; BFE4 00       .
        brk                                     ; BFE5 00       .
        brk                                     ; BFE6 00       .
        brk                                     ; BFE7 00       .
        brk                                     ; BFE8 00       .
        brk                                     ; BFE9 00       .
        brk                                     ; BFEA 00       .
        brk                                     ; BFEB 00       .
        brk                                     ; BFEC 00       .
        brk                                     ; BFED 00       .
        brk                                     ; BFEE 00       .
        brk                                     ; BFEF 00       .
        brk                                     ; BFF0 00       .
        brk                                     ; BFF1 00       .
        brk                                     ; BFF2 00       .
        brk                                     ; BFF3 00       .
        ldx     $F4                             ; BFF4 A6 F4    ..
        inx                                     ; BFF6 E8       .
        stx     $F4                             ; BFF7 86 F4    ..
        stx     $FE30                           ; BFF9 8E 30 FE .0.
        nop                                     ; BFFC EA       .
        jmp     LBFC5                           ; BFFD 4C C5 BF L..

; ----------------------------------------------------------------------------
