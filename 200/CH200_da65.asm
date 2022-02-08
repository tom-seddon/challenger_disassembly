; Input file: CH200.rom
; Page:       1


        .setcpu "6502"

; ----------------------------------------------------------------------------
L00A8           := $00A8
L00AA           := $00AA
L00AE           := $00AE
L00C0           := $00C0
current_drive   := $00CF
L0100           := $0100
fscv            := $021E
L0406           := $0406
L0810           := $0810
L0D00           := $0D00
L0D11           := $0D11
L0D2C           := $0D2C
nmi_opt9_value  := $0D2D
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
; Commentary by Greg Cook, 7 February 2022
; Taken from http://regregex.bbcmicro.net/chal200.asm.txt
        brk                                     ; Language entry
        brk
        brk
        jmp     svc                             ; Service entry

; ----------------------------------------------------------------------------
        .byte   $82,$1A,$20                     ; rom type: service only
; ----------------------------------------------------------------------------
        .byte   "Challenger 3"                  ; title

        .byte   $00                             ; terminator byte
        .byte   "2.00"                          ; version string
        .byte   $00                             ; terminator byte
        .byte   "(C)1987 Slogger"               ; copyright string validated by MOS

        .byte   $00                             ; terminator byte
; ----------------------------------------------------------------------------
; Issue Filing System Call
L802B:  jmp     (fscv)

; ----------------------------------------------------------------------------
; unreachable code
        rts

; ----------------------------------------------------------------------------
; ROM service
svc:    cmp     #$01
        bne     L8087                           ; Service call &01 = reserve absolute workspace
svc_handle_absolute_workspace_claim:
        jsr     push_registers_and_tuck_restoration_thunk; save AXY
        jsr     probe_challenger_ram_size       ; probe Challenger unit RAM size
        tax
        beq     L8086                           ; if Challenger unit absent then return
        jsr     select_ram_page_001             ; else page in main workspace
        lda     $FD00                           ; validate first workspace sentinel
        and     #$7F                            ; mask off b7=Challenger is current FS
        cmp     #$65                            ; compare remainder with valid value &65/E5
        beq     L8053                           ; if equal then validate second sentinel
        lda     #$65                            ; else initialise sentinel=&65, b7=0 no FS
        sta     $FD00
        jsr     reset_current_drive_mappings    ; initialise current FS's drive mapping
        jsr     do_177x_force_interrupt
L8053:  lda     #$E5                            ; validate second workspace sentinel
        cmp     $FDFD
        beq     L806D                           ; if not equal to valid value &E5
        sta     $FDFD                           ; then initialise second sentinel
        lda     #$04                            ; set current drive = 4
        sta     current_drive
        ldx     #$02                            ; x=2 select drive 4 volume size = &3F5
        jsr     LAFF8                           ; initialise RAM disc catalogue
        inc     current_drive                   ; current drive = 5
        ldx     #$03                            ; x=3 select drive 5 volume size = &3FF
        jsr     LAFF8                           ; initialise RAM disc catalogue
L806D:  lda     #$FD                            ; OSBYTE &FD = read/write type of last reset
        jsr     osbyte_x00_yff                  ; call OSBYTE with X=0, Y=&FF
        txa                                     ; test type of last reset
        beq     L8078                           ; if A=0 then soft break so skip
        jsr     L82A4                           ; else initialise workspace
L8078:  jsr     L82C8
        bit     $FDF4                           ; test b7=*ENABLE CAT
        bpl     L8086                           ; if enabled
        tsx                                     ; then return Y=&17 nine pages of workspace
        lda     #$17
        sta     $0103,x
L8086:  rts

; ----------------------------------------------------------------------------
L8087:  cmp     #$02
        bne     L8096                           ; Service call &02 = reserve private workspace
svc_handle_private_workspace_claim:
        jsr     select_ram_page_001             ; page in main workspace
        bit     $FDF4                           ; test b7=*ENABLE CAT
        bpl     L8095                           ; if enabled
        iny                                     ; then reserve two pages of private workspace
        iny
L8095:  rts

; ----------------------------------------------------------------------------
L8096:  cmp     #$03
        bne     L80B6                           ; Service call &03 = boot
svc_handle_auto_boot:
        jsr     select_ram_page_001             ; page in main workspace
        sty     $B3                             ; save boot flag in scratch space
        jsr     push_registers_and_tuck_restoration_thunk; save AXY
        lda     #$7A                            ; call OSBYTE &7A = scan keyboard from &10+
        jsr     osbyte
        txa                                     ; test returned key code
        bmi     L80B3                           ; if N=1 no key is pressed, so init and boot
        cmp     #$52                            ; else if key pressed is not C
        bne     L80F3                           ; then exit
        lda     #$78                            ; else register keypress for two-key rollover
        jsr     osbyte
L80B3:  jmp     L81EE                           ; initialise Chall. and boot default volume

; ----------------------------------------------------------------------------
L80B6:  cmp     #$04
        bne     L80DA                           ; Service call &04 = unrecognised OSCLI
svc_handle_star:
        jsr     select_ram_page_001             ; page in main workspace
        jsr     push_registers_and_tuck_restoration_thunk; save AXY
        tsx
        stx     $B8                             ; save stack pointer to restore on abort
        tya                                     ; a=offset of *command from GSINIT pointer
        ldx     #$48                            ; point XY to utility command table at &9148
        ldy     #$91
        jsr     L91A8                           ; search for command in table
        bcs     L80F3                           ; if not found then exit
        lda     $FD00                           ; else test b7=Challenger is current FS
        bmi     L80D7                           ; if b7=1 then execute *command
        jsr     L00AA                           ; else get syntax byte from command table
        bmi     L80F3                           ; if b7=1 restricted command then return
L80D7:  jmp     (L00A8)                         ; else execute *command, Y=cmd line tail ptr

; ----------------------------------------------------------------------------
L80DA:  cmp     #$09
        bne     L8113                           ; Service call &09 = *HELP
svc_handle_help:
        jsr     select_ram_page_001             ; page in main workspace
        jsr     push_registers_and_tuck_restoration_thunk; save AXY
        lda     ($F2),y                         ; test character at start of *HELP string
        cmp     #$0D                            ; if not CR then *HELP called with keyword
        bne     L80F4                           ; so scan keyword
        ldx     #$90                            ; else point XY to *HELP keyword table at &9190
        ldy     #$91
        lda     #$03                            ; 3 entries to print
        jsr     LA534                           ; print *HELP keywords and pass on the call.
L80F3:  rts

; ----------------------------------------------------------------------------
; Scan *HELP keyword
L80F4:  jsr     gsinit_with_carry_clear         ; call GSINIT with C=0
        bne     L80FC                           ; if keyword present then search in table
        jmp     L8469                           ; else print newline

; ----------------------------------------------------------------------------
; Search for *HELP keyword
L80FC:  tya                                     ; a=offset of keyword from GSINIT pointer
        pha                                     ; also save on stack
        ldx     #$90                            ; point XY to *HELP keyword table at &9190
        ldy     #$91
        jsr     L91A8                           ; search for keyword in table
        bcs     L810A                           ; if keyword found
        jsr     L80D7                           ; then call its action address; print help
L810A:  pla                                     ; restore string offset
        tay
L810C:  jsr     gsread                          ; call GSREAD
        bcc     L810C                           ; until end of argument (discarding it)
        bcs     L80F4                           ; then scan next *HELP keyword
L8113:  cmp     #$12
        bne     L8124
svc_handle_init_fs:
        cpy     #$04                            ; Service call &12 = initialise FS
        bne     L80F3                           ; if number of FS to initialise = 4
        jsr     select_ram_page_001             ; then page in main workspace
        jsr     push_registers_and_tuck_restoration_thunk; save AXY
        jmp     disc_command                    ; and initialise Challenger FS

; ----------------------------------------------------------------------------
L8124:  cmp     #$08
        bne     L80F3                           ; Service call &08 = unrecognised OSWORD
svc_handle_unknown_osword:
        jsr     select_ram_page_001             ; page in main workspace
        jsr     LA875                           ; save XY (X will be clobbered on return)
        ldy     $F0                             ; set &B0..1 = pointer to OSWORD control block
        sty     $B0
        ldy     $F1
        sty     $B1
        ldy     #$00
        sty     $B9                             ; =0 disc operation is uninterruptible
        ldy     $EF                             ; set Y = OSWORD call number (in A on entry)
        cpy     #$7F
        bne     L81B8
        jsr     claim_nmi_area                  ; OSWORD A = &7F
        ldy     #$01                            ; claim NMI
        lda     ($B0),y                         ; offset 1 = address LSB
        sta     $A6                             ; copy to &A6
        iny
        lda     ($B0),y                         ; offset 2 = address 3MSB
        sta     $A7                             ; copy to &A7
        ldy     #$00
        lda     ($B0),y                         ; offset 0 = drive number
        bmi     L8165                           ; if b7=1 then use previous drive
        pha                                     ; else save requested drive
        rol     a                               ; shift bit 3 = force double density
        rol     a                               ; to bit 6
        rol     a
        and     #$40                            ; mask bit 6 = hardware double density flag
        ora     $FDED                           ; or with *DENSITY detected/forced DD flag
        sta     $FDED                           ; update *DENSITY flag
        pla                                     ; restore requested drive
        and     #$07                            ; extract drive number 0..7
        sta     current_drive                   ; set as current drive
L8165:  iny                                     ; offset 1 = address
        ldx     #$02
        jsr     L89C2                           ; copy address to &BE,F,&106F,70
        lda     ($B0),y                         ; y = 5 on exit; offset 5 = no. parameters
        pha                                     ; save number of parameters
        iny                                     ; increment offset
        lda     ($B0),y                         ; offset 6 = command
        and     #$3F
        sta     $B2
        jsr     lsr_x4                          ; shift A right 4 places, extract bit 4:
        and     #$01                            ; a=0 if writing to disc, A=1 if reading
        jsr     L96AE                           ; open Tube data transfer channel
        ldy     #$07
        lda     ($B0),y                         ; offset 7 = first parameter (usu. track)
        iny                                     ; offset 8, Y points to second parameter
        sta     $BA
        ldx     #$FD                            ; x = &FD to start at offset 0:
L8186:  inx                                     ; add 3 to X
        inx
        inx
        lda     LB8AD,x                         ; get command byte from table
        beq     L81AE                           ; if the terminator byte then exit
        cmp     $B2                             ; else compare with OSWORD &7F command
        bne     L8186                           ; if not the same try next entry
        php                                     ; else save interrupt state
        cli                                     ; enable interrupts
        lda     #$81                            ; push return address &81A3 on stack
        pha
        lda     #$A2
        pha
        lda     LB8AE+1,x                       ; fetch action address high byte
        pha                                     ; push on stack
        lda     LB8AE,x                         ; fetch action address low byte
        pha                                     ; push on stack
        rts                                     ; jump to action address.

; ----------------------------------------------------------------------------
; Finish OSWORD &7F
        tax                                     ; hold result in X
        plp                                     ; restore interrupt state
        pla                                     ; restore number of parameters
        clc                                     ; add 7; drive, address, no.parms, command
        adc     #$07                            ; =offset of result in O7F control block
        tay                                     ; transfer to Y for use as offset
        txa
        sta     ($B0),y                         ; store result in user's OSWORD &7F block
        pha                                     ; push dummy byte on stack:
L81AE:  pla                                     ; discard byte from stack
        jsr     release_nmi_area                ; release NMI
        jsr     L96E6                           ; release Tube
        lda     #$00                            ; exit A=0 to claim service call
        rts

; ----------------------------------------------------------------------------
; OSWORD A <> &7F
L81B8:  cpy     #$7D                            ; if A < &7D
        bcc     L81ED                           ; then exit
        jsr     LAA1E                           ; set current vol/dir = default, set up drive
        jsr     L962F                           ; load volume catalogue L4
        cpy     #$7E
        beq     L81D2                           ; OSWORD A = &7D (and &80..&DF)
        jsr     select_ram_page_003             ; page in catalogue sector 1
        ldy     #$00
        lda     $FD04                           ; get catalogue cycle number
        sta     ($B0),y                         ; store in OSWORD control block offset 0
        tya                                     ; return A = 0, claiming service call.
        rts

; ----------------------------------------------------------------------------
; OSWORD A = &7E get size of volume in bytes
L81D2:  jsr     select_ram_page_003             ; page in catalogue sector 1
        lda     #$00
        tay
        sta     ($B0),y                         ; store 0 at offset 0: multiple of 256 bytes
        iny                                     ; offset 1
        lda     $FD07                           ; get LSB volume size from catalogue
        sta     ($B0),y                         ; save as 3MSB volume size
        iny                                     ; offset 2
        lda     $FD06                           ; get boot option/top bits volume size
        and     #$03                            ; extract MSB volume size
        sta     ($B0),y                         ; save as 2MSB volume size
        iny                                     ; offset 3
        lda     #$00                            ; store 0: volume size less than 16 MiB
        sta     ($B0),y
L81ED:  rts

; ----------------------------------------------------------------------------
; Initialise Chall. and boot default volume
L81EE:  lda     $B3                             ; get back boot flag (Y on entry to call &3)
        pha                                     ; save on stack
        sec
        jsr     print_CHALLENGER                ; print Challenger banner
        jsr     L8469                           ; print newline
        jsr     get_rom_status_byte             ; get Challenger unit type
        and     #$03                            ; extract b1,b0 of A
        beq     L8217                           ; if Challenger not installed then exit
        jsr     L82C8                           ; else initialise workspace part 2
        jsr     L8258                           ; initialise Challenger FS
        pla                                     ; if boot flag was >0
        bne     L820B                           ; then return A=0 to claim call
        jmp     L82F7                           ; else examine and boot default volume

; ----------------------------------------------------------------------------
; Return A=0
L820B:  lda     #$00
        rts

; ----------------------------------------------------------------------------
; *DISC / *DISK
disc_command:
        pha
        jsr     check_challenger_presence       ; probe JIM page &0001 for RAM
        bne     L8217                           ; if RAM found then Challenger unit installed
        jsr     L8258                           ; so initialise Challenger FS
L8217:  pla
        rts

; ----------------------------------------------------------------------------
; Get Challenger unit type
get_rom_status_byte:
        ldx     $F4                             ; get our ROM slot number
        lda     $0DF0,x                         ; get type from private page pointer
        rts

; ----------------------------------------------------------------------------
; also CHADFS request $02
; ChADFS ROM call 2
; Probe Challenger unit RAM size
probe_challenger_ram_size:
        ldx     #$00                            ; set X=0, no RAM found
        jsr     check_challenger_presence
        bne     L822F                           ; if RAM absent return 0
        inx                                     ; else X=1, 256 KiB unit
        lda     #$04                            ; probe JIM page &0401 for RAM
        jsr     L8238                           ; will hit empty sockets, not alias to bank 0
        bne     L822F                           ; if RAM absent return 1
        inx                                     ; else X=2, 512 KiB unit
L822F:  txa
        ldx     $F4                             ; get our ROM slot number
        sta     $0DF0,x                         ; store Challenger unit type in private pg ptr
        rts

; ----------------------------------------------------------------------------
check_challenger_presence:
        lda     #$00                            ; Probe JIM page &0001 for RAM
L8238:  sta     ram_paging_msb                  ; store MSB JIM paging register
        lda     #$01                            ; page &0001 (main workspace) or &0401
        sta     ram_paging_lsb                  ; store LSB JIM paging register
        lda     $FD00                           ; read offset 0 of JIM page
        eor     #$FF                            ; invert it
        sta     $FD00                           ; write it back
        ldy     #$05                            ; wait 13 microseconds
L824A:  dey                                     ; allow 1 MHz data bus to discharge
        bne     L824A
        cmp     $FD00                           ; read offset 0, compare with value written
        php                                     ; save result
        eor     #$FF                            ; restore original value
        sta     $FD00                           ; write back in case RAM is there
        plp                                     ; return Z=1 if location 0 acts like RAM
        rts

; ----------------------------------------------------------------------------
; Initialise Challenger FS
L8258:  lda     #$00
        tsx
        sta     $0108,x                         ; have A=0 returned on exit
        lda     #$06                            ; FSC &06 = new FS about to change vectors
        jsr     L802B                           ; issue Filing System Call
        ldx     #$00                            ; x = 0 offset in MOS vector table
L8265:  lda     LADF9,x                         ; copy addresses of extended vector handlers
        sta     $0212,x                         ; to FILEV,ARGSV,BGETV,BPUTV,GBPBV,FINDV,FSCV
        inx                                     ; loop until 7 vectors transferred
        cpx     #$0E
        bne     L8265
        jsr     osbyte_get_rom_pointer_table_address; call OSBYTE &A8 = get ext. vector table addr
        sty     $B1                             ; set up pointer to vector table
        stx     $B0
        ldx     #$00                            ; x = 0 offset in Challenger vector table
        ldy     #$1B                            ; y = &1B offset of FILEV in extended vec tbl
L827B:  lda     LADF9+14,x                      ; get LSB action address from table
        sta     ($B0),y                         ; store in extended vector table
        inx
        iny
        lda     LADF9+14,x                      ; get MSB action address from table
        sta     ($B0),y                         ; store in extended vector table
        inx
        iny
        lda     $F4                             ; get our ROM slot number
        sta     ($B0),y                         ; store in extended vector table
        iny
        cpx     #$0E                            ; loop until 7 vectors transferred
        bne     L827B
        lda     $FD00                           ; get first workspace sentinel
        ora     #$80                            ; set b7=1 Challenger is current FS
        sta     $FD00                           ; update first sentinel
        lda     #$00
        sta     $FDFF                           ; b6=0 Challenger is current FS
        ldx     #$0F                            ; service call &0F = vectors claimed
        jmp     osbyte_rom_service_request      ; call OSBYTE &8F = issue service call

; ----------------------------------------------------------------------------
; Initialise workspace part 1
L82A4:  jsr     select_ram_page_001             ; page in main workspace
        lda     #$80                            ; a=&80
        sta     $FDED                           ; *OPT 6,0 automatic density
        sta     $FDEA                           ; *OPT 8,255 automatic stepping
        lda     #$0E                            ; a=&0E
        sta     $FDEE                           ; *OPT 9,14 page in ROM slot 14 during disc ops
        lda     #$00
        sta     $FDC7                           ; set default volume = "0A"
        sta     $FDC9                           ; set library volume = "0A"
        sta     $FDF4
        lda     #$24
        sta     $FDC6                           ; set default directory = "$"
        sta     $FDC8                           ; set library directory = "$"
        rts

; ----------------------------------------------------------------------------
; Initialise workspace part 2
L82C8:  jsr     select_ram_page_001             ; page in main workspace
        jsr     osbyte_read_tube_presence       ; call OSBYTE &EA = read Tube presence flag
        txa
        eor     #$FF                            ; invert; 0=tube present &FF=Tube absent
        sta     $FDCD                           ; save Tube presence flag
        ldy     #$00                            ; y=&00
        sty     $FDCE                           ; no files are open
        sty     $FDDE
        sty     $FDDD                           ; NMI resource is not ours
        sty     $FDCC                           ; no Tube data transfer in progress
        sty     $FDFF                           ; b6=0 Challenger is current FS
        dey                                     ; y=&FF
        sty     $FDDF                           ; *commands are not *ENABLEd
        sty     $FDD9                           ; *OPT 1,0 quiet operation
        sty     $FDDC                           ; no catalogue in JIM pages 2..3
        jsr     osbyte_aff_x00_yff              ; call OSBYTE &FF = read/write startup options
        stx     $B4                             ; save them in zero page
        jmp     LB8F7                           ; set track stepping rate from startup options

; ----------------------------------------------------------------------------
L82F7:  jsr     LAA1E                           ; set current volume and directory = default
        jsr     L9632                           ; load volume catalogue
        ldy     #$00
        ldx     #$00
        jsr     select_ram_page_003             ; page in catalogue sector 1
        lda     $FD06                           ; get boot option/top bits volume size
        jsr     lsr_x4                          ; shift A right 4 places
        beq     L8331                           ; if boot option = 0 then exit
        pha
        ldx     #$55                            ; point XY to filename "!BOOT"
        ldy     #$83
        jsr     set_f2_y                        ; set GSINIT pointer to XY, set Y=0
        jsr     L89DC                           ; set current file from file spec
        jsr     L8C2E                           ; search for file in catalogue
        pla                                     ; restore boot option
        bcs     do_boot                         ; if !BOOT found then boot from it
        jsr     print_string_nterm              ; else print "File not found" and return
        .byte   "File not found"

        .byte   $0D,$0D
; ----------------------------------------------------------------------------
        nop
L8331:  rts

; ----------------------------------------------------------------------------
do_boot:cmp     #$02
        bcc     do_load_boot                    ; if boot option = 1 then load !BOOT
        beq     do_run_boot                     ; if boot option = 2 then run !BOOT
do_exec_boot:
        ldx     #$53                            ; else boot option = 3 (or b7 or b6 set)
        ldy     #$83                            ; point XY to "E.!BOOT"
        bne     L8348                           ; call OSCLI
do_run_boot:
        ldx     #$55                            ; point XY to "!BOOT"
        ldy     #$83
        bne     L8348                           ; call OSCLI
do_load_boot:
        ldx     #$4B                            ; point XY to "L.!BOOT"
        ldy     #$83
L8348:  jmp     oscli                           ; call OSCLI

; ----------------------------------------------------------------------------
        .byte   "L.!BOOT"
        .byte   $0D
        .byte   "E.!BOOT"
        .byte   $0D
; ----------------------------------------------------------------------------
; *TYPE
type_command:
        jsr     LA821                           ; claim service call and set up argument ptr
        lda     #$00                            ; a = &00 CR does not trigger line no.
        beq     L8367
; *LIST
list_command:
        jsr     LA821                           ; claim service call and set up argument ptr
        lda     #$FF                            ; a = &FF CR triggers line number
L8367:  sta     $AB                             ; store CR mask
        lda     #$40                            ; OSFIND &40 = open a file for reading
        jsr     osfind                          ; call OSFIND
        tay                                     ; test returned file handle
        beq     L83A1                           ; if file not found then raise error
        lda     #$0D                            ; preload CR so *LIST prints line no. 1
        bne     L8390                           ; branch to CR test (always)
L8375:  jsr     osbget                          ; call OSBGET
        bcs     L8398                           ; if EOF then finish
        cmp     #$0A                            ; else if character is LF
        beq     L8375                           ; ignore it and get next one
        plp                                     ; else restore result of (A & mask) - CR
        bne     L8389                           ; if no match just print the character
        pha                                     ; else save first character of line
        jsr     LA7DA                           ; increment and print BCD word
        jsr     print_space_without_spool       ; print a space
        pla                                     ; restore first character
L8389:  jsr     osasci                          ; call OSASCI
        bit     $FF                             ; if ESCAPE pressed
        bmi     L8399                           ; then finish
L8390:  and     $AB                             ; else apply mask to character just prt'd
        cmp     #$0D                            ; compare masked character with CR
        php                                     ; save result
        jmp     L8375                           ; and loop to read next character

; ----------------------------------------------------------------------------
L8398:  plp                                     ; discard result of (A & mask) - CR
L8399:  jsr     L8469                           ; print newline
L839C:  lda     #$00                            ; OSFIND &00 = close file
        jmp     osfind                          ; call OSFIND and exit

; ----------------------------------------------------------------------------
L83A1:  jmp     L8B46                           ; raise "File not found" error

; ----------------------------------------------------------------------------
; *DUMP
dump_command:
        jsr     LA821                           ; claim service call and set up argument ptr
        lda     #$40                            ; OSFIND &40 = open a file for reading
        jsr     osfind                          ; call OSFIND
        tay                                     ; transfer file handle to Y
        beq     L83A1                           ; if file not found raise error
L83AF:  bit     $FF                             ; if ESCAPE pressed
        bmi     L839C                           ; then close file and exit
        lda     $A9                             ; else get high byte of file offset
        jsr     print_hex_byte                  ; print hex byte
        lda     L00A8                           ; get low byte of file offset
        jsr     print_hex_byte                  ; print hex byte
        jsr     print_space_without_spool       ; print a space
        tsx
        stx     $AD                             ; save stack pointer
        ldx     #$08                            ; offset = 8 for indexed indirect load
L83C5:  jsr     osbget                          ; call OSBGET
        bcs     L83D4                           ; if EOF then finish
        pha                                     ; else save byte read for ASCII column
        jsr     print_hex_byte                  ; print hex byte
        jsr     print_space_without_spool       ; print a space
        dex                                     ; decrement counter
        bne     L83C5                           ; loop until line complete
L83D4:  dex                                     ; test counter
        bmi     L83E4                           ; if EOF on incomplete line
        php                                     ; then save status (N=0, C=1)
        jsr     print_string_nterm              ; pad hex column with "** "
        .byte   "** "
; ----------------------------------------------------------------------------
        lda     #$00
        plp                                     ; restore status
        pha                                     ; push NUL to pad ASCII column
        bpl     L83D4                           ; loop until line complete (always)
; print ASCII column
L83E4:  php                                     ; save C=EOF
        tsx                                     ; transfer stack pointer to X
        lda     #$07
        sta     $AC                             ; set counter to 7:
L83EA:  lda     $0109,x                         ; get byte 9..2 down = byte 1..8 of column
        cmp     #$7F                            ; if DEL or higher
        bcs     L83F5                           ; then print a dot
        cmp     #$20                            ; else if a printable character
        bcs     L83F7                           ; then print it
L83F5:  lda     #$2E                            ; else print a dot:
L83F7:  jsr     osasci                          ; call OSASCI
        dex                                     ; decrement pointer, work toward top of stack
        dec     $AC                             ; decrement counter
        bpl     L83EA                           ; loop until line complete
        jsr     L8469                           ; print newline
        lda     #$08                            ; add 8 to file offset
        clc
        adc     L00A8
        sta     L00A8
        bcc     L840D                           ; carry out to high byte
        inc     $A9
L840D:  plp                                     ; restore carry flag from OSBGET
        ldx     $AD                             ; restore stack pointer to discard column
        txs
        bcc     L83AF                           ; if not at end of file then print next row
        bcs     L839C                           ; else close file and exit
; *BUILD
build_command:
        jsr     LA821                           ; claim service call and set up argument ptr
        lda     #$80                            ; OSFIND &80 = open a file for writing
        jsr     osfind                          ; call OSFIND
        sta     $AB                             ; save file handle
        jsr     LA838                           ; set line number = 0 (OSFIND clobbers)
L8422:  jsr     LA7DA                           ; increment and print BCD word
        jsr     print_space_without_spool       ; print a space
        lda     #$FD                            ; y = &FD point to JIM page for OSWORD
        sta     $AD
        ldx     #$AC                            ; x = &AC low address for OSWORD
        ldy     #$FF                            ; y = &FF
        sty     L00AE                           ; maximum line length = 255
        sty     $B0                             ; maximum ASCII value = 255
        iny
        sty     $AC                             ; clear low byte of pointer
        sty     $AF                             ; minimum ASCII value = 0
        jsr     select_ram_page_009             ; page in line buffer
        tya                                     ; OSWORD &00 = read line of input
        jsr     osword                          ; call OSWORD
        php                                     ; save returned flags
        sty     L00AA                           ; save length of line
        ldy     $AB                             ; y = file handle for OSBPUT
        ldx     #$00                            ; offset = 0 for indexed indirect load
L8447:  txa
        cmp     L00AA                           ; compare offset with line length
        beq     L8458                           ; if end of line reached then terminate line
        jsr     select_ram_page_009             ; else page in line buffer
        lda     $FD00,x                         ; get character of line
        jsr     osbput                          ; call OSBPUT
        inx                                     ; increment offset
        bne     L8447                           ; and loop to write rest of line (always)
; terminate line
L8458:  plp                                     ; restore flags from OSWORD
        bcs     L8463                           ; if user escaped from input then finish
        lda     #$0D                            ; else A = carriage return
        jsr     osbput                          ; write to file
        jmp     L8422                           ; and loop to build next line

; ----------------------------------------------------------------------------
L8463:  jsr     acknowledge_escape              ; acknowledge ESCAPE condition
        jsr     L839C                           ; close file:
; Print newline
L8469:  pha
        lda     #$0D
        jsr     print_char_without_spool        ; print character in A (OSASCI)
        pla
        rts

; ----------------------------------------------------------------------------
; Select source volume
L8471:  jsr     push_registers_and_tuck_restoration_thunk; save AXY
        jsr     select_ram_page_001             ; page in main workspace
        ldx     $FDCA                           ; set X = source volume
        lda     #$00                            ; a=&00 = we want source disc
        beq     L8489                           ; branch (always)
; Select destination volume
L847E:  jsr     push_registers_and_tuck_restoration_thunk; save AXY
        jsr     select_ram_page_001             ; page in main workspace
        ldx     $FDCB                           ; set X = destination volume
        lda     #$80                            ; a=&80 = we want destination disc
L8489:  pha                                     ; save A
        stx     current_drive                   ; set wanted volume as current volume
        pla                                     ; restore A
        bit     $A9                             ; if disc swapping required
        bmi     L8492                           ; then branch to prompt
L8491:  rts                                     ; else exit

; ----------------------------------------------------------------------------
L8492:  cmp     L00AA                           ; compare wanted disc with disc in drive
        beq     L8491                           ; if the same then do not prompt
        sta     L00AA                           ; else wanted disc is going into drive
        jsr     print_string_nterm              ; print "Insert "
        .byte   "Insert "
; ----------------------------------------------------------------------------
        nop
        bit     L00AA                           ; if b7=1
        bmi     L84B2                           ; then print "destination"
        jsr     print_string_nterm              ; else print "source"
        .byte   "source"
; ----------------------------------------------------------------------------
        bcc     L84C1                           ; and branch (always)
L84B2:  jsr     print_string_nterm              ; print " destination"
        .byte   "destination"

; ----------------------------------------------------------------------------
        nop
L84C1:  jsr     print_string_nterm              ; print " disk and hit a key"
        .byte   " disk and hit a key"


; ----------------------------------------------------------------------------
        nop
        jsr     L84EF                           ; poll for ESCAPE (OSRDCH)
        jmp     L8469                           ; print newline and exit

; ----------------------------------------------------------------------------
; Ask user yes or no
L84DE:  jsr     L84EF                           ; wait for keypress
        and     #$5F                            ; convert to uppercase
        cmp     #$59                            ; is it "Y"?
        php                                     ; save the answer
        beq     L84EA                           ; if so then print "Y"
        lda     #$4E                            ; else print "N"
L84EA:  jsr     print_char_without_spool        ; print character in A (OSASCI)
        plp                                     ; return Z=1 if "Y" or "y" pressed
        rts

; ----------------------------------------------------------------------------
; Poll for ESCAPE (OSRDCH)
L84EF:  jsr     LADC2                           ; call *FX 15,1 = clear input buffer
        jsr     osrdch                          ; call OSRDCH, wait for input character
        bcc     L84FA                           ; if ESCAPE was pressed
        ldx     $B8                             ; then abort our routine
        txs                                     ; clear our stacked items, return to caller
L84FA:  rts

; ----------------------------------------------------------------------------
; Restore parameters of source drive
L84FB:  ldy     #$00                            ; offset = 0
        beq     L8501                           ; branch (always)
; Restore parameters of destination drive
L84FF:  ldy     #$02                            ; offset = 2:
; Restore parameters of source/dest drive
L8501:  jsr     select_ram_page_001             ; page in main workspace
        lda     $FDFA,y                         ; get first track of selected volume
        sta     $FDEC                           ; set as first track of current volume
        lda     $FDF9,y                         ; get packed drive parameters:
; Restore packed drive parameters
L850D:  pha                                     ; save packed drive parameters
        and     #$C0                            ; mask b7,b6
        sta     $FDED                           ; store *OPT 6 density setting
        pla                                     ; restore packed drive parameters
        lsr     a                               ; shift b1,b0 of A to b7,b6
        ror     a
        ror     a
        pha                                     ; save other bits
        and     #$C0                            ; mask b7,b6
        sta     $FDEA                           ; store *OPT 8 tracks setting
        pla                                     ; restore b1,b0 = original b4,b3
        and     #$03                            ; mask b1,b0
        jmp     L854C                           ; unpack and store sectors per track

; ----------------------------------------------------------------------------
; Save parameters of source drive
L8523:  jsr     push_registers_and_tuck_restoration_thunk; save AXY
        ldy     #$00
        beq     L852F
; Save parameters of destination drive
L852A:  jsr     push_registers_and_tuck_restoration_thunk; save AXY
        ldy     #$02
; Save parameters of source/dest drive
L852F:  jsr     select_ram_page_001             ; page in main workspace
        lda     $FDEC                           ; get first track of current volume
        sta     $FDFA,y                         ; set as first track of selected volume
        jsr     L853F                           ; pack drive parameters
        sta     $FDF9,y
        rts

; ----------------------------------------------------------------------------
; Pack drive parameters
L853F:  jsr     L855C                           ; pack number of sectors per track
        ora     $FDEA                           ; apply *OPT 8 tracks setting in b7,b6
        asl     a                               ; shift spt to b4,b3, *OPT 8 to b1,b0
        rol     a
        rol     a
        ora     $FDED                           ; apply *OPT 6 density setting in b7,b6
        rts                                     ; return packed drive parameters

; ----------------------------------------------------------------------------
; Unpack and store sectors per track
L854C:  cmp     #$00                            ; if A=0 on entry then RAM disc
        beq     L8558                           ; so store 0=sectors per track undefined
        cmp     #$02                            ; else if A=1
        lda     #$0A                            ; then store 10 sectors per track
        bcc     L8558
        lda     #$12                            ; else A>1, store 18 sectors per track
L8558:  sta     $FDEB                           ; store number of sectors per track
        rts

; ----------------------------------------------------------------------------
; Pack number of sectors per track
L855C:  lda     $FDEB                           ; get current setting
        beq     L8568                           ; if A=0 then RAM disc, return 0
        cmp     #$12                            ; else if less than 18 i.e. 10, single dens.
        lda     #$01                            ; then return 1
        bcc     L8568
        asl     a                               ; if 18 or more i.e. double density return 2.
L8568:  rts

; ----------------------------------------------------------------------------
; *BACKUP
backup_command:
        jsr     LA75F                           ; ensure *ENABLE active
        jsr     LA78A                           ; parse and print source and dest. volumes
        lda     #$00
        sta     L00A8                           ; no catalogue entry waiting to be created
        sta     $C8                             ; set source volume LBA = 0
        sta     $C9
        sta     $CA                             ; set destination volume LBA = 0
        sta     $CB
        jsr     L865F                           ; load source volume catalogue
        lda     #$00
        sta     $FDEC                           ; data area starts on track 0
        jsr     L8523                           ; save parameters of source drive
        jsr     L863A                           ; return volume size in XY/boot option in A
        sta     LFDE0                           ; save source volume boot option
        stx     $C6
        sty     $C7
        jsr     L8659                           ; load destination volume catalogue
        lda     #$00
        sta     $FDEC                           ; data area starts on track 0
        jsr     L852A                           ; save parameters of destination drive
        lda     $FDF9                           ; get density of source drive
        eor     $FDFB                           ; xor with density flag of destination drive
        and     #$40                            ; extract bit 6 density flag, ignore auto b7
        beq     L85CA                           ; if the same density then skip
        jsr     print_string_2_nterm            ; else raise density mismatch error.
        .byte   $D5
        .byte   "Both disks MUST be same density"



        .byte   $0D
; ----------------------------------------------------------------------------
        brk
L85CA:  jsr     L863A                           ; return volume size in XY/boot option in A
        txa                                     ; save destination volume size on stack
        pha
        tya
        pha
        cmp     $C7                             ; compare MSBs dest volume size - source
        bcc     L85DC                           ; if dest < source then raise error
        bne     L8600                           ; if dest > source then proceed
        txa                                     ; else compare LSBs dest - source
        cmp     $C6
        bcs     L8600                           ; if dest >= source then proceed
L85DC:  lda     #$D5                            ; else error number = &D5
        jsr     LA938                           ; begin error message, number in A
        lda     $FDCA                           ; get source drive
        jsr     L8EAD                           ; print " Drive " plus volume spec in A
        jsr     print_string_nterm              ; print " larger than "
        .byte   " larger than "

; ----------------------------------------------------------------------------
        lda     $FDCB                           ; get destination drive
        jsr     L8EAD                           ; print " Drive " plus volume spec in A
        jmp     LA8F8                           ; terminate error message, raise error

; ----------------------------------------------------------------------------
L8600:  jsr     L8948                           ; copy source drive/file to destination
        jsr     L88CA                           ; store empty BASIC program at OSHWM (NEW)
        jsr     is_current_drive_ram_disk       ; set Z=1 iff current drive is a RAM disc
        bne     L860E                           ; if so
        pla                                     ; then discard destination volume size
        pla
        rts                                     ; and exit

; ----------------------------------------------------------------------------
L860E:  bit     $FDED                           ; else test density flag
        bvs     L8629                           ; if double density then update disc catalogue
        jsr     L9632                           ; else load volume catalogue L4
        pla                                     ; pop MSB destination volume size
        and     #$0F                            ; mask bits 0..3
        ora     LFDE0                           ; apply source boot option in bits 4..5
        jsr     select_ram_page_003             ; page in catalogue sector 1
        sta     $FD06                           ; store in catalogue
        pla                                     ; pop LSB destination volume size
        sta     $FD07                           ; store in catalogue
        jmp     L960B                           ; write volume catalogue L4

; ----------------------------------------------------------------------------
; Update disc catalogue
L8629:  jsr     LACBA                           ; load disc catalogue L3
        jsr     select_ram_page_002             ; page in catalogue sector 0
        pla                                     ; pop MSB disc size
        sta     $FD01                           ; store in disc catalogue
        pla                                     ; pop LSB disc size
        sta     $FD02                           ; store in disc catalogue
        jmp     LACBD                           ; write disc catalogue L3

; ----------------------------------------------------------------------------
; Return volume size in XY/boot option in A
L863A:  jsr     select_ram_page_003             ; page in catalogue sector 1
        ldx     $FD07                           ; get LSB volume size from catalogue
        lda     $FD06                           ; get boot option/top bits volume size
        pha
        and     #$03                            ; extract MSB volume size
        tay                                     ; put volume size in XY
        jsr     select_ram_page_001             ; page in main workspace
        bit     $FDED                           ; test density flag
        bvc     L8655                           ; if double density
        ldx     $FDF6                           ; then load disc size from workspace instead
        ldy     $FDF5
L8655:  pla                                     ; return disc size in XY
        and     #$F0                            ; return boot option in A bits 5 and 4
        rts

; ----------------------------------------------------------------------------
; Load destination volume catalogue
L8659:  jsr     L847E                           ; select destination volume
        jmp     L9632                           ; load volume catalogue L4

; ----------------------------------------------------------------------------
; Load source volume catalogue
L865F:  jsr     L8471                           ; select source volume
        jmp     L9632                           ; load volume catalogue L4

; ----------------------------------------------------------------------------
; *COPY
copy_command:
        jsr     L8B2E                           ; allow wildcard characters in filename
        jsr     LA78A                           ; parse and print source and dest. volumes
        jsr     LA565                           ; call GSINIT with C=0 and reject empty arg
        jsr     L89DC                           ; set current file from file spec
        jsr     L8471                           ; select source volume
        jsr     L8B41                           ; ensure matching file in catalogue
        jsr     L8523                           ; save parameters of source drive
        lda     $FDD5                           ; get start of user memory
        sta     $BD                             ; save in zero page
        lda     #$00
        sta     $FDF7                           ; point to start of copy buffer file table
        sta     L00A8
        lda     #$01
        sta     L00A8                           ; one entry in copy buffer file table:
; Copy file
L868A:  tya                                     ; save catalogue offset of found file
        pha
        ldx     #$00
L868E:  lda     $C7,x                           ; save file spec on stack
        pha
        inx
        cpx     #$08
        bne     L868E
        jsr     print_string_nterm              ; print "Reading "
        .byte   "Reading "
; ----------------------------------------------------------------------------
        nop
        jsr     L8AA3                           ; print filename from catalogue
        jsr     L8469                           ; print newline
        ldx     $FDF7                           ; get pointer to free end of buffer table
        lda     #$08                            ; 8 bytes to copy
        sta     $B0                             ; set counter:
L86AF:  jsr     select_ram_page_003             ; page in catalogue sector 1
        lda     $FD08,y                         ; get matching file's catalogue information
        jsr     select_ram_page_000             ; page in auxiliary workspace
        sta     $FD11,x                         ; store information in copy buffer table
        inx                                     ; &FD11..18,X
        iny
        dec     $B0                             ; loop until 8 bytes copied
        bne     L86AF
        lda     #$08                            ; 8 characters to copy
        sta     $B0                             ; set counter:
L86C5:  jsr     select_ram_page_002             ; page in catalogue sector 0
        lda     $FD00,y                         ; get matching file's name and directory
        jsr     select_ram_page_000             ; page in auxiliary workspace
        sta     $FD12,x                         ; store filename in copy buffer table
        inx                                     ; &FD1A..21,X
        iny
        dec     $B0                             ; loop until 8 characters copied
        bne     L86C5
        lda     #$00
        sta     $FD09,x                         ; clear &FD19,X flag byte
        lda     $FD05,x                         ; get LSB length
        cmp     #$01                            ; set C=1 iff file includes partial sector
        lda     $FD06,x                         ; get 2MSB length
        adc     #$00                            ; round up to get LSB length in sectors
        sta     $FD12,x                         ; store LSB length in sectors in table
        php                                     ; save carry flag
        lda     $FD07,x                         ; get top bits exec/length/load/start sector
        jsr     extract_00xx0000                ; extract b5,b4 of A
        plp                                     ; restore carry flag
        adc     #$00                            ; carry out to get MSB length in sectors
        sta     $FD13,x                         ; save length in sectors at &FD22..23,X
        lda     $FD08,x                         ; get LSB start LBA
        sta     $FD14,x                         ; copy to &FD24,X
        lda     $FD07,x                         ; get top bits exec/length/load/start sector
        and     #$03                            ; extract MSB start sector
        sta     $FD15,x                         ; store MSB start LBA at &FD25,X:
; Read segment of file
L8704:  jsr     select_ram_page_001             ; page in main workspace
        sec                                     ; subtract HIMEM - OSHWM
        lda     $FDD6
        sbc     $BD
        sta     $C3                             ; = number of pages of user memory
        ldy     $FDF7                           ; get pointer to latest buffer table entry
        jsr     select_ram_page_000             ; page in auxiliary workspace
        lda     $FD22,y                         ; copy LSB length in sectors
        sta     $C6                             ; to zero page
        lda     $FD23,y                         ; MSB length in sectors
        sta     $C7
        lda     $FD24,y                         ; LSB start LBA
        sta     $C8
        lda     $FD25,y                         ; MSB start LBA
        sta     $C9
        jsr     L8989                           ; set start and size of next transfer
        lda     $BD                             ; set MSB load address = start of user memory
        sta     $BF
        lda     #$00
        sta     $BE                             ; set LSB load address = 0
        sta     $C2                             ; set LSB transfer size = 0
        lda     $C3                             ; get size of transfer
        jsr     select_ram_page_000             ; page in auxiliary workspace
        sta     $FD18,y                         ; overwrite LSB start LBA at &FD18,Y
        jsr     L959C                           ; set high word of OSFILE load address = &FFFF
        jsr     L970D                           ; read ordinary file L5
        jsr     L899E                           ; adjust addresses by amount transferred
        clc
        lda     $BD                             ; get start of free copy buffer
        adc     $C3                             ; add size of transfer
        sta     $BD                             ; update start of free copy buffer
        ldy     $FDF7                           ; get pointer to latest buffer table entry
        jsr     select_ram_page_000             ; page in auxiliary workspace
        lda     $C6                             ; return LSB length in sectors
        sta     $FD22,y                         ; to copy buffer table
        lda     $C7                             ; MSB length in sectors
        sta     $FD23,y
        lda     $C8                             ; LSB start LBA
        sta     $FD24,y
        lda     $C9                             ; MSB start LBA
        sta     $FD25,y
        lda     $C6                             ; test number of sectors to transfer
        ora     $C7
        beq     L8779                           ; if no more then read next file/write buffer
        jsr     select_ram_page_000             ; else page in auxiliary workspace
        lda     $FD19,y                         ; get buffer table entry's flag byte
        ora     #$80                            ; b7=1 file incomplete in buffer
        sta     $FD19,y                         ; update flag byte:
; Continue filling copy buffer until full, or write it out
L8779:  jsr     select_ram_page_001             ; page in main workspace
        lda     $BD                             ; has copy buffer been filled up to HIMEM?
        cmp     $FDD6
        beq     L87BA                           ; if so then write it out
        bit     L00A8                           ; else if b7=1 all files read
        bmi     L87BA                           ; then write out copy buffer
        lda     L00A8                           ; else if copy buffer table is full
        and     #$7F
        cmp     #$08
        beq     L87BA                           ; then write it out
        clc
        lda     $FDF7                           ; else point copy buffer table pointer
        adc     #$17                            ; to next entry:
        sta     $FDF7
; Copy next matching file
L8798:  ldx     #$07                            ; 8 bytes to restore:
L879A:  pla                                     ; restore file spec from stack
        sta     $C7,x
        dex                                     ; loop until 8 bytes restored
        bpl     L879A
        pla                                     ; restore catalogue offset of found file
        sta     $FDC2
        jsr     L8C35                           ; find next matching file
        bcc     L87AE                           ; if no more files match then finish
        inc     L00A8                           ; else increment no. of files in buffer
        jmp     L868A                           ; and copy next file.

; ----------------------------------------------------------------------------
; Flush copy buffer
L87AE:  ldy     $FDF7                           ; more than one table entry in use?
        bne     L87B4                           ; if so then write out copy buffer
        rts                                     ; else exit

; ----------------------------------------------------------------------------
L87B4:  lda     L00A8                           ; set b7=1 all files read
        ora     #$80
        sta     L00A8
L87BA:  jsr     select_ram_page_001             ; page in main workspace
        jsr     L847E                           ; select destination volume
        lda     $FDD5
        sta     $BD                             ; set start of copy buffer to OSHWM
        lda     L00A8                           ; get no. entries in copy buffer
        and     #$7F                            ; extract actual number of entries
        tax
        ldy     #$E9                            ; y=&E9 going to &00:
; Write file from copy buffer
L87CC:  txa
        pha                                     ; save number of buffer table entries
        clc
        tya
        adc     #$17                            ; point to next buffer table entry
        sta     $FDF8                           ; set pointer to last entry of buffer table
        pha                                     ; and save it
        tay
        jsr     select_ram_page_000             ; page in auxiliary workspace
        lda     $FD19,y                         ; if b6=1 destination file partly copied
        and     #$40                            ; then skip catalogue entry creation:
        bne     L8838                           ; write out rest of file
        lda     $FD19,y                         ; else b6=1 don't create entry twice
        ora     #$40
        sta     $FD19,y
        ldx     #$00
L87EB:  lda     $FD11,y                         ; read from buffer table entry &FD11..21,Y
        sta     $BE,x                           ; restore file catalogue info &BE..&C5
        iny                                     ; and filename and directory &C7..&CE
        inx
        cpx     #$11
        bne     L87EB
        jsr     L9753                           ; forget catalogue in JIM pages 2..3
        jsr     L8C2E                           ; search for file in catalogue
        bcc     L8801                           ; if file found
        jsr     L8C78                           ; then delete catalogue entry
L8801:  jsr     L852A                           ; save parameters of destination drive
        jsr     L958D                           ; expand 18-bit load address to 32-bit
        jsr     L95AC                           ; expand 18-bit exec address to 32-bit
        lda     $C4                             ; get top bits exec/length/load/start sector
        jsr     extract_00xx0000                ; extract b5,b4 of A
        sta     $C6                             ; store MSB length of file
        jsr     L940B                           ; create catalogue entry
        jsr     print_string_nterm              ; print "Writing "
        .byte   "Writing "
; ----------------------------------------------------------------------------
        nop
        jsr     L8AA3                           ; print filename from catalogue
        jsr     L8469                           ; print newline
        ldy     $FDF8                           ; point to last entry of buffer table
        jsr     select_ram_page_000             ; page in auxiliary workspace
        lda     $C4                             ; get top bits exec/length/load/start sector
        and     #$03                            ; extract b1,b0 of A
        sta     $FD26,y                         ; store MSB destination LBA
        lda     $C5                             ; copy LSB destination LBA
        sta     $FD27,y
; Write segment of file
L8838:  lda     $FD18,y                         ; get no. pages of data in buffer
        sta     $C3                             ; set size of transfer
        clc
        lda     $FD27,y                         ; copy LSB destination LBA
        sta     $C5
        adc     $C3                             ; add transfer size
        sta     $FD27,y                         ; update LSB destination LBA of next write
        lda     $FD26,y                         ; copy MSB destination LBA
        sta     $C4
        adc     #$00                            ; carry out transfer size
        sta     $FD26,y                         ; update MSB destination LBA of next write
        lda     $BD                             ; get start of filled copy buffer
        sta     $BF                             ; set MSB of source address
        lda     #$00
        sta     $BE                             ; clear LSB source address
        sta     $C2                             ; clear LSB transfer size
        jsr     L84FF                           ; restore parameters of destination drive
        jsr     L959C                           ; set high word of OSFILE load address = &FFFF
        jsr     L9713                           ; write extended file L5
        clc
        lda     $BD                             ; get start of filled copy buffer
        adc     $C3                             ; add size of transfer
        sta     $BD                             ; update start of filled copy buffer
        pla                                     ; restore pointer to last table entry
        tay
        pla                                     ; restore no. entries in buffer table
        tax
        dex                                     ; remove one
        beq     L8876                           ; if last entry then check for multi-pass copy
        jmp     L87CC                           ; else write next file in copy buffer

; ----------------------------------------------------------------------------
; Wrote last entry of copy buffer.  Copy rest of file or refill buffer
L8876:  jsr     L84FB                           ; restore parameters of source drive
        ldy     $FDF8                           ; point to last entry of buffer table
        jsr     select_ram_page_000             ; page in auxiliary workspace
        lda     $FD19,y                         ; test flag byte
        and     #$80                            ; if b7=0 file(s) in buffer are complete
        beq     L88B0                           ; then start refilling copy buffer
        ldx     #$00                            ; else start at offset = 0:
; The last entry in the copy buffer table needs another pass
; to fulfil.  Move it to the first table slot.
L8888:  lda     $FD11,y                         ; copy last entry to first position
        sta     $FD11,x
        iny                                     ; increment offsets
        inx
        cpx     #$17                            ; loop until all 23 bytes copied
        bne     L8888
        lda     #$40                            ; b6=1 destination file partly copied
        sta     $FD19                           ; set buffer table entry's flag byte
        jsr     L8471                           ; select source volume
        jsr     L9632                           ; load volume catalogue L4
        lda     $FDD5
        sta     $BD                             ; set start of copy buffer to OSHWM
        lda     #$00
        sta     $FDF7                           ; one buffer table entry in use
        sta     L00A8
        inc     L00A8                           ; one entry in copy buffer table
        jmp     L8704                           ; read in the rest of this file.

; ----------------------------------------------------------------------------
; Exit if no more files to read; else empty copy buffer and refill it
L88B0:  bit     L00A8                           ; if b7=1 all files read
        bmi     L88C9                           ; then exit
        jsr     L8471                           ; else select source volume
        jsr     L9632                           ; load volume catalogue L4
        lda     $FDD5
        sta     $BD                             ; set start of copy buffer to OSHWM
        lda     #$00
        sta     $FDF7                           ; no buffer table entries in use
        sta     L00A8                           ; no entries in copy buffer table
        jmp     L8798                           ; copy next matching file.

; ----------------------------------------------------------------------------
L88C9:  rts

; ----------------------------------------------------------------------------
; Store empty BASIC program at OSHWM (NEW)
L88CA:  lda     $FDD5                           ; get start of user memory
        sta     $BF                             ; store as high byte of pointer
        lda     #$00                            ; clear low byte
        sta     $BE                             ; PAGE is always on a page boundary
        lda     #$0D
        sta     ($BE),y                         ; &0D = first byte of end-of-program marker
        iny                                     ; store at start of user memory
        lda     #$FF                            ; &FF = second byte of end-of-program marker
        sta     ($BE),y                         ; store in user memory
        rts

; ----------------------------------------------------------------------------
; unreachable code
        jsr     L8471
        jsr     L9632
        jsr     L8523
        jsr     select_ram_page_003             ; page in catalogue sector 1
        lda     $FD07
        sta     $C6
        lda     $FD06
        and     #$03
        sta     $C7
        lda     $FD06
        and     #$F0
        jsr     select_ram_page_001             ; page in main workspace
        sta     LFDE0
        jsr     L847E
        jsr     L9632
        jmp     L852A

; ----------------------------------------------------------------------------
; unreachable code
        jsr     select_ram_page_003             ; page in catalogue sector 1
        lda     $FD06
        and     #$03
        cmp     $C7
        bcc     L891C
        bne     L891C
        lda     $FD07
        cmp     $C6
L891C:  rts

; ----------------------------------------------------------------------------
; Shift data
L891D:  jsr     push_registers_and_tuck_restoration_thunk; save AXY
        lda     #$02
        sta     $FDD7                           ; 2 pages of user memory = catalogue sectors
        lda     #$00
        sta     $BF                             ; MSB of load address in JIM space = &00
L8929:  jsr     L8984                           ; set start and size of first transfer
        lda     #$02
        sta     $BE                             ; LSB of load address in JIM space = &02
        jsr     L9724                           ; read ordinary file to JIM L5
        lda     $CA                             ; set LBA = destination volume LBA
        sta     $C5                             ; NB always works downwards and shifts upwards
        lda     $CB                             ; sector reads and writes will not overlap
        sta     $C4
        lda     #$02
        sta     $BE                             ; LSB of load address in JIM space = &02
        jsr     L9721                           ; write ordinary file from JIM L5
        jsr     L899E                           ; adjust addresses by amount transferred
        bne     L8929                           ; loop until no more sectors to transfer
        rts

; ----------------------------------------------------------------------------
; Copy source drive/file to destination
L8948:  jsr     select_ram_page_001             ; page in main workspace
        lda     #$00
        sta     $BE                             ; clear LSB load address
        sta     $C2                             ; clear LSB transfer size in bytes
L8951:  jsr     L8984
        lda     $FDD5                           ; set MSB load address = start of user memory
        sta     $BF
        jsr     L84FB                           ; restore parameters of source drive
        jsr     L8471                           ; select source volume
        jsr     L959C                           ; set high word of OSFILE load address = &FFFF
        jsr     L970D                           ; read extended file L5
        lda     $CA                             ; set LBA = destination volume LBA
        sta     $C5
        lda     $CB
        sta     $C4
        lda     $FDD5                           ; set MSB save address = start of user memory
        sta     $BF
        jsr     L84FF                           ; restore parameters of destination drive
        jsr     L847E                           ; select destination volume
        jsr     L959C                           ; set high word of OSFILE load address = &FFFF
        jsr     L9713                           ; write extended file L5
        jsr     L899E                           ; adjust addresses by amount transferred
        bne     L8951                           ; loop until no more sectors to transfer
        rts

; ----------------------------------------------------------------------------
; Set start and size of first transfer
L8984:  lda     $FDD7                           ; get number of pages of user memory
        sta     $C3                             ; set number of sectors to transfer:
; Set start and size of next transfer
L8989:  ldx     $C6                             ; compare remaining file size
        cpx     $C3                             ; - available memory
        lda     $C7
        sbc     #$00
        bcs     L8995                           ; if remainder doesn't fit then fill memory
        stx     $C3                             ; else transfer size=file size in pages
L8995:  lda     $C8                             ; set LBA = source volume LBA
        sta     $C5
        lda     $C9
        sta     $C4
        rts

; ----------------------------------------------------------------------------
; Adjust addresses by amount transferred
L899E:  lda     $CA                             ; get LSB destination LBA
        clc
        adc     $C3                             ; add number of sectors transferred
        sta     $CA                             ; store LSB destination LBA
        bcc     L89A9                           ; carry out to MSB
        inc     $CB
L89A9:  lda     $C3                             ; get number of sectors transferred
        clc
        adc     $C8                             ; add LSB source LBA
        sta     $C8                             ; store LSB source LBA
        bcc     L89B4                           ; carry out to MSB:
        inc     $C9
; Subtract transfer size from remainder
L89B4:  sec
        lda     $C6                             ; get LSB number of sectors in volume
        sbc     $C3                             ; subtract amount transferred
        sta     $C6                             ; store LSB number of sectors remaining
        bcs     L89BF                           ; borrow from MSB
        dec     $C7
L89BF:  ora     $C7                             ; return Z=no more sectors to transfer
        rts

; ----------------------------------------------------------------------------
; Copy doubleword into OSFILE field
L89C2:  jsr     L89D2                           ; copy low word into OSFILE field
        dex                                     ; restore offset in X = 4 * field no.
        dex
        jsr     L89CA                           ; copy 3MSB of dword to workspace:
; Copy high byte into OSFILE field
L89CA:  lda     ($B0),y                         ; fetch byte from zero page workspace
        sta     $FDB3,x                         ; store in OSFILE high words table
        inx                                     ; increment offsets
        iny
        rts

; ----------------------------------------------------------------------------
; Copy low word into OSFILE field
L89D2:  jsr     L89D5                           ; copy LSB of word into workspace:
; Copy low byte into OSFILE field
L89D5:  lda     ($B0),y                         ; fetch byte from zero page workspace
        sta     $BC,x                           ; store in OSFILE low words table
        inx                                     ; increment offsets
        iny
        rts

; ----------------------------------------------------------------------------
L89DC:  jsr     LAA1E                           ; set current volume and dir = default
        jmp     L89F2

; ----------------------------------------------------------------------------
; Set current file from argument pointer
L89E2:  jsr     LAA1E                           ; set current volume and dir = default:
; Parse file spec from argument pointer
L89E5:  lda     $BC                             ; copy argument pointer to GSINIT pointer
        sta     $F2
        lda     $BD
        sta     $F3
        ldy     #$00                            ; set Y = 0 offset for GSINIT
        jsr     gsinit_with_carry_clear         ; call GSINIT with C=0:
; Parse file spec
L89F2:  jsr     L8A5D                           ; set current filename to all spaces
        jsr     gsread                          ; call GSREAD
        bcs     L8A4D                           ; if argument empty then "Bad filename"
        cmp     #$3A                            ; else is first character ":"?
        bne     L8A20                           ; if not then skip to dir/filename
        jsr     gsread                          ; else a drive is specified, call GSREAD
        bcs     L8A5A                           ; if no drive number then "Bad drive"
        jsr     LA9F6                           ; else set current drive from ASCII digit
        jsr     gsread                          ; call GSREAD
        bcs     L8A4D                           ; if only drive specified then "Bad filename"
        cmp     #$2E                            ; else if next character is "."
        beq     L8A1B                           ; then get first character of filename
        jsr     LA9FC                           ; else set volume from ASCII letter
        jsr     gsread                          ; call GSREAD
        bcs     L8A4D                           ; if only volume spec'd then "Bad filename"
        cmp     #$2E                            ; if separator character "." missing
        bne     L8A4D                           ; then raise "Bad filename" error
L8A1B:  jsr     gsread                          ; call GSREAD, get first character of filename
        bcs     L8A4D                           ; if filename is empty then "Bad filename"
L8A20:  sta     $C7                             ; else save first character of filename
        ldx     #$00                            ; set filename offset = 0
        jsr     gsread                          ; call GSREAD, get second filename character
        bcs     L8A6D                           ; if absent then process one-character name
        inx                                     ; else offset = 1
        cmp     #$2E                            ; is the second character "."?
        bne     L8A39                           ; if not then read in rest of leaf name
        lda     $C7                             ; else first character was a directory spec
        jsr     LAAB0                           ; set directory from ASCII character
        jsr     gsread                          ; call GSREAD, get first character of leaf name
        bcs     L8A4D                           ; if leaf name is empty then "Bad filename"
        dex                                     ; else offset = 0, read in leaf name:
L8A39:  cmp     #$2A                            ; is filename character "*"?
        beq     L8A73                           ; if so then process "*" in filename
        cmp     #$21                            ; else is it a control character or space?
        bcc     L8A4D                           ; if so then raise "Bad filename" error
        sta     $C7,x                           ; else store character of filename
        inx                                     ; point X to next character of current filename
        jsr     gsread                          ; call GSREAD, get next character of leaf name
        bcs     L8A6C                           ; if no more then filename complete, return
        cpx     #$07                            ; else have seven characters been read already?
        bne     L8A39                           ; if not then loop, else:
; Raise "Bad filename" error.
L8A4D:  jsr     dobrk_with_Bad_prefix
        .byte   $CC
        .byte   "filename"
; ----------------------------------------------------------------------------
        brk
L8A5A:  jmp     LAA34                           ; raise "Bad drive" error

; ----------------------------------------------------------------------------
; Set current filename to all spaces
L8A5D:  ldx     #$00
        lda     #$20
        bne     L8A65                           ; branch (always)
; Pad current filename with "#"s
L8A63:  lda     #$23                            ; x=offset of end of filename
L8A65:  sta     $C7,x
        inx
        cpx     #$07
        bne     L8A65
L8A6C:  rts

; ----------------------------------------------------------------------------
; Process one-character filename
L8A6D:  lda     $C7                             ; if filename is "*", then:
        cmp     #$2A
        bne     L8A6C
; Process "*" in filename
L8A73:  jsr     gsread                          ; call GSREAD
        bcs     L8A63                           ; if end of argument pad filename with "#"s
        cmp     #$20                            ; else if next character is space
        beq     L8A63                           ; then pad filename with "#"s
        bne     L8A4D                           ; else raise "Bad filename" error.
; Ensure disc not changed
L8A7E:  jsr     push_registers_and_tuck_restoration_thunk; save AXY
        jsr     select_ram_page_003             ; page in catalogue sector 1
        lda     $FD04                           ; get cycle number of last catalogue read
        jsr     L962F                           ; load volume catalogue L4
        jsr     select_ram_page_003             ; page in catalogue sector 1
        cmp     $FD04                           ; compare with freshly loaded cycle number
        beq     L8A6C                           ; return if equal, else:
L8A92:  jsr     print_string_2_nterm            ; Raise "Disk changed" error.
        .byte   $C8
        .byte   "Disk changed"

; ----------------------------------------------------------------------------
        brk
; Print filename from catalogue
L8AA3:  jsr     push_registers_and_tuck_restoration_thunk; save AXY
        jsr     select_ram_page_002             ; page in catalogue sector 0
        lda     $FD0F,y                         ; get directory character
        php                                     ; save N = lock attribute
        and     #$7F                            ; extract ASCII character
        bne     L8AB6                           ; if NUL then file is in CSD
        jsr     print_2_spaces_without_spool    ; so print two spaces
        beq     L8ABC                           ; branch (always)
L8AB6:  jsr     print_char_without_spool        ; else print directory character
        jsr     print_dot_without_spool         ; print a dot
L8ABC:  ldx     #$06                            ; repeat 7 times:
L8ABE:  lda     $FD08,y                         ; get character of leaf name
        and     #$7F                            ; mask bit 7
        jsr     print_char_without_spool        ; print character
        iny
        dex
        bpl     L8ABE                           ; and loop
        jsr     select_ram_page_001             ; page in main workspace
        jsr     print_2_spaces_without_spool    ; print two spaces
        lda     #$20                            ; a = space
        plp                                     ; restore lock attribute in N
        bpl     L8AD7                           ; if lock bit set
        lda     #$4C                            ; then A = capital L
L8AD7:  jsr     print_char_without_spool        ; print attribute character
        jmp     print_space_without_spool       ; print a space and exit

; ----------------------------------------------------------------------------
; Y = number of spaces to print
; Print number of spaces in Y
print_N_spaces_without_spool:
        jsr     print_space_without_spool       ; print a space
        dey                                     ; loop until Y = 0
        bne     print_N_spaces_without_spool
        rts

; ----------------------------------------------------------------------------
; Prepare extended file transfer
L8AE4:  lda     #$00                            ; set MSB length = 0; transfer less than 64 KiB
        sta     $A5
        ldx     $C4                             ; x = LSB of relative LBA
        jmp     L8AF9

; ----------------------------------------------------------------------------
; Prepare ordinary file transfer
L8AED:  lda     $C4                             ; get top bits exec/length/load/start sector
        jsr     extract_00xx0000                ; extract b5,b4 of A
        sta     $A5                             ; ?&A5 = b17..16 (MSB) of length
        lda     $C4                             ; x = b9..8 (MSB) of relative LBA
        and     #$03
        tax
L8AF9:  lda     $BE                             ; copy user data address to NMI area
        sta     $A6
        lda     $BF
        sta     $A7
        lda     $C3                             ; copy 2MSB length
        sta     $A4
        lda     $C2                             ; copy LSB length
        sta     $A3
        stx     $BA                             ; store LSB/MSB of LBA (clobbered if LSB)
        lda     $C5                             ; copy MSB/LSB of LBA
        sta     $BB
        lda     $FDEB                           ; get number of sectors per track
        beq     L8B2D                           ; if not defined then just use the LBA
        lda     $FDEC                           ; else get first track of current volume
        sta     $BA                             ; set track number for transfer
        dec     $BA                             ; decrement, to increment at start of loop
        lda     $C5                             ; get LSB of relative LBA:
L8B1D:  sec                                     ; set C=1 to subtract without borrow:
L8B1E:  inc     $BA                             ; increment track number
        sbc     $FDEB                           ; subtract sectors-per-track from LBA
        bcs     L8B1E                           ; loop until LSB borrows in
        dex                                     ; then decrement MSB of relative LBA
        bpl     L8B1D                           ; loop until MSB borrows in/underflows
        adc     $FDEB                           ; add sectors per track to negative remainder
        sta     $BB                             ; set sector number.
L8B2D:  rts

; ----------------------------------------------------------------------------
; Allow wildcard characters in filename
L8B2E:  lda     #$23
        bne     L8B34
L8B32:  lda     #$FF                            ; Disallow wildcard characters in filename
L8B34:  sta     $FDD8
        rts

; ----------------------------------------------------------------------------
; Ensure file matching spec in catalogue
L8B38:  jsr     L89DC                           ; set current file from file spec
        jmp     L8B41                           ; ensure matching file in catalogue

; ----------------------------------------------------------------------------
; Ensure file matching argument in catalogue
L8B3E:  jsr     L89E2                           ; set current file from argument pointer:
; Ensure matching file in catalogue
L8B41:  jsr     L8C2E                           ; search for file in catalogue
        bcs     L8B2D                           ; if found then return
L8B46:  jsr     dobrk_with_File_prefix          ; else raise "File not found" error.
        .byte   $D6
        .byte   "not found"

; ----------------------------------------------------------------------------
        brk
; *MAP
map_command:
        jsr     LAA16                           ; parse volume spec from argument
        jsr     L962F                           ; load volume catalogue L4
        lda     #$00
        sta     $C4                             ; clear MSB start of data area
        sta     $C6                             ; clear total free space
        sta     $C7
        jsr     LA4F8                           ; return no. reserved sectors in data area
        sta     $C5                             ; store LSB start of data area
        lda     $FDEC                           ; if this volume's data area starts >track 0
        beq     L8B88
        jsr     print_string_nterm              ; then print "Track offset = "
        .byte   "  Track offset  = "


; ----------------------------------------------------------------------------
        nop
        jsr     print_hex_byte                  ; print hex byte
        jsr     L8469                           ; print newline
L8B88:  jsr     select_ram_page_003             ; page in catalogue sector 1
        ldy     $FD05                           ; y = offset of last catalogue entry:
L8B8E:  jsr     L9507                           ; calculate slack space after file
        beq     L8BC2                           ; if no slack space then only map the file
        clc
        lda     $B0                             ; else add LSB slack space
        adc     $C6                             ; to LSB total free space
        sta     $C6
        txa                                     ; add MSB slack space
        adc     $C7                             ; and carry out
        sta     $C7                             ; to MSB total free space
        jsr     print_string_nterm              ; print "  Free space "
        .byte   "  Free space "

; ----------------------------------------------------------------------------
        nop
        jsr     L8C01                           ; print number of sectors
        jsr     print_space_without_spool       ; print a space
        txa                                     ; a = MSB slack space
        jsr     print_hex_nybble                ; print hex nibble
        lda     $B0                             ; a = LSB slack space
        jsr     print_hex_byte                  ; print hex byte
        jsr     L8469                           ; print newline
L8BC2:  tya                                     ; if end of catalogue reached
        beq     L8BE0                           ; then print total free space
        jsr     dey_x8                          ; else subtract 8 from Y
        jsr     L8AA3                           ; print filename from catalogue
        jsr     L8CE3                           ; print start sector
        jsr     print_space_without_spool       ; print a space
        jsr     L94EB                           ; calculate number of sectors used by file
        jsr     L8C01                           ; print number of sectors
        jsr     L8469                           ; print newline
        jsr     L94D6                           ; calculate LBA of end of file
        jmp     L8B8E                           ; loop to map next file.

; ----------------------------------------------------------------------------
; Print total free space
L8BE0:  jsr     print_string_nterm              ; print "Free sectors "
        .byte   $0D
        .byte   "Free sectors "

; ----------------------------------------------------------------------------
        lda     $C7                             ; a = MSB total free space
        jsr     print_hex_nybble                ; print hex nibble
        lda     $C6                             ; a = LSB total free space
        jsr     print_hex_byte                  ; print hex byte
        jsr     L8469                           ; print newline
        jmp     select_ram_page_001             ; page in main workspace

; ----------------------------------------------------------------------------
; Print number of sectors
L8C01:  lda     $C4                             ; get MSB size of file or slack space
        jsr     print_hex_nybble                ; print hex nibble
        lda     $C5                             ; get LSB size of file or slack space
        jmp     print_hex_byte                  ; print hex byte

; ----------------------------------------------------------------------------
; OSFSC  9 = *EX
osfsc_ex:
        jsr     set_f2_y                        ; set GSINIT pointer to XY, set Y=0
        jsr     LAA16                           ; parse volume spec from argument
        ldx     #$00                            ; set X = 0, whole current filename to #s
        jsr     L8A63                           ; set current filename = "#######"
        jmp     info_command                    ; jump into *INFO

; ----------------------------------------------------------------------------
; OSFSC 10 = *INFO
osfsc_info:
        jsr     set_f2_y                        ; set GSINIT pointer to XY, set Y=0
info_command:
        jsr     L8B2E                           ; allow wildcard characters in filename
        jsr     LA565                           ; call GSINIT with C=0 and reject empty arg
        jsr     L8B38                           ; ensure file matching spec in catalogue
L8C25:  jsr     L8CA5                           ; print *INFO line
        jsr     L8C35                           ; find next matching file
        bcs     L8C25                           ; loop until no more files match.
        rts

; ----------------------------------------------------------------------------
; Search for file in catalogue
L8C2E:  jsr     L961F                           ; ensure current volume catalogue loaded
        ldy     #$F8                            ; y=&F8, start beyond first catalogue entry
        bne     L8C3B                           ; and jump into search loop (always)
; Find next matching file
L8C35:  jsr     select_ram_page_001             ; page in main workspace
        ldy     $FDC2                           ; set Y = catalogue pointer
L8C3B:  jsr     select_ram_page_003             ; page in catalogue sector 1
        jsr     iny_x8                          ; add 8 to Y
        cpy     $FD05                           ; have we reached the end of the catalogue?
        bcs     L8C99                           ; if so return C=0 file not found
        jsr     iny_x8                          ; else add 8 to Y
        ldx     #$07                            ; x=7 point to directory character:
L8C4B:  jsr     select_ram_page_001             ; page in main workspace
        lda     $C7,x                           ; get character of current filename
        cmp     $FDD8                           ; compare with wildcard mask
        beq     L8C66                           ; if ='#' and wildcards allowed accept char
        jsr     isalpha                         ; else set C=0 iff character in A is a letter
        jsr     select_ram_page_002             ; page in catalogue sector 0
        eor     $FD07,y                         ; compare with character in catalogue
        bcs     L8C62                           ; if character in current filename is letter
        and     #$DF                            ; then ignore case
L8C62:  and     #$7F                            ; ignore bit 7, Z=1 if characters equal
        bne     L8C72                           ; if not equal then test next file
L8C66:  dey                                     ; loop to test next (previous) char of name
        dex
        bpl     L8C4B                           ; if no more chars to test then files match
        jsr     select_ram_page_001             ; page in main workspace
        sty     $FDC2                           ; save cat. offset of found file in workspace
        sec                                     ; return C=1 file found
        rts

; ----------------------------------------------------------------------------
; catalogue entry does not match file spec
L8C72:  dey                                     ; advance catalogue pointer to next file
        dex
        bpl     L8C72
        bmi     L8C3B                           ; loop until file found or not
; Delete catalogue entry
L8C78:  jsr     LA2A8                           ; ensure file not locked or open (mutex)
L8C7B:  jsr     select_ram_page_002             ; page in catalogue sector 0
        lda     $FD10,y                         ; copy next file's entry over previous entry
        sta     $FD08,y                         ; shifting entries up one place
        jsr     select_ram_page_003             ; page in catalogue sector 1
        lda     $FD10,y                         ; (copies title/boot/size if catalogue full)
        sta     $FD08,y
        iny                                     ; loop until current file count reached
        cpy     $FD05                           ; have we reached the end of the catalogue?
        bcc     L8C7B
        tya                                     ; copy Y to A = pointer to last file; C=1
        sbc     #$08                            ; subtract 8, catalogue contains one file less
        sta     $FD05                           ; store new file count
L8C99:  clc
L8C9A:  jmp     select_ram_page_001             ; page in main workspace and exit.

; ----------------------------------------------------------------------------
; Print *INFO line if verbose
L8C9D:  jsr     select_ram_page_001             ; page in main workspace
        bit     $FDD9                           ; test *OPT 1 setting
        bmi     L8C9A                           ; if b7=1 then *OPT 1,0 do not print, else:
; Print *INFO line
L8CA5:  jsr     push_registers_and_tuck_restoration_thunk; save AXY
        jsr     L8AA3                           ; print filename from catalogue
        tya                                     ; save catalogue pointer
        pha
        lda     #$A1                            ; set up pointer to OSFILE block in workspace
        sta     $B0                             ; at &FDA1
        lda     #$FD
        sta     $B1
        jsr     L8CF7                           ; return catalogue information to OSFILE block
        jsr     select_ram_page_001             ; page in main workspace
        ldy     #$02                            ; y = &02 offset of load address in block
        jsr     print_space_without_spool       ; print a space
        jsr     L8CD1                           ; print load address
        jsr     L8CD1                           ; print execution address
        jsr     L8CD1                           ; print file length
        pla                                     ; restore catalogue pointer
        tay
        jsr     L8CE3                           ; print start sector
        jmp     L8469                           ; print newline

; ----------------------------------------------------------------------------
; Print 24-bit field at &FDA1,Y
L8CD1:  ldx     #$03                            ; start at MSB, offset = 3:
L8CD3:  lda     $FDA3,y                         ; get byte at &FDA3,Y
        jsr     print_hex_byte                  ; print hex byte
        dey                                     ; increment offset
        dex                                     ; decrement counter
        bne     L8CD3                           ; loop until 3 bytes printed
        jsr     iny_x7                          ; add 7 to Y to point to MSB of next field
        jmp     print_space_without_spool       ; print a space and exit

; ----------------------------------------------------------------------------
; Print start sector
L8CE3:  jsr     select_ram_page_003             ; page in catalogue sector 1
        lda     $FD0E,y                         ; get top bits exec/length/load/start sector
        and     #$03                            ; extract MSB start sector
        jsr     print_hex_nybble                ; print hex nibble
        lda     $FD0F,y                         ; get LSB start sector
        jsr     print_hex_byte                  ; print hex byte
        jmp     select_ram_page_001             ; page in main workspace

; ----------------------------------------------------------------------------
; Return catalogue information to OSFILE block
L8CF7:  jsr     push_registers_and_tuck_restoration_thunk; save AXY
        tya                                     ; save catalogue pointer on stack
        pha
        tax                                     ; and copy to X
        jsr     select_ram_page_001             ; page in main workspace
        ldy     #$02                            ; clear bytes at offsets 2..17
        lda     #$00
L8D04:  sta     ($B0),y
        iny
        cpy     #$12
        bne     L8D04
        ldy     #$02                            ; offset 2 = LSB load address
L8D0D:  jsr     L8D55                           ; copy two bytes from catalogue to OSFILE block
        iny                                     ; skip high bytes of OSFILE field
        iny
        cpy     #$0E                            ; loop until 3 fields half-filled:
        bne     L8D0D                           ; load address, execution address, file length
        pla                                     ; restore catalogue pointer
        tax
        jsr     select_ram_page_002             ; page in catalogue sector 0
        lda     $FD0F,x                         ; get directory character
        bpl     L8D29                           ; if b7=1 then file is locked
        lda     #$0A                            ; so set attributes to LR/RW (old style)
        ldy     #$0E                            ; no delete, owner read only, public read/write
        jsr     select_ram_page_001             ; page in main workspace
        sta     ($B0),y                         ; store in OSFILE block
L8D29:  jsr     select_ram_page_003             ; page in catalogue sector 1
        lda     $FD0E,x                         ; get top bits exec/length/load/start sector
        jsr     select_ram_page_001             ; page in main workspace
        ldy     #$04                            ; offset 4 = 2MSB load address
        jsr     L8D43                           ; expand bits 3,2 to top 16 bits of field
        ldy     #$0C                            ; offset 12 = 2MSB file length
        lsr     a                               ; PD43 returned A = ..eelldd
        lsr     a                               ; shift A right twice to make A = ....eell
        pha                                     ; save exec address
        and     #$03                            ; extract bits 1,0 for length (don't expand)
        sta     ($B0),y                         ; store in OSFILE block
        pla                                     ; restore exec address in bits 3,2
        ldy     #$08                            ; offset 8 = 2MSB execution address:
L8D43:  lsr     a                               ; shift A right 2 places
        lsr     a
        pha                                     ; save shifted value for return
        and     #$03                            ; extract bits 3,2 of A on entry
        cmp     #$03                            ; if either one is clear
        bne     L8D51                           ; then save both as b1,0 of 2MSB
        lda     #$FF                            ; else set MSB and 2MSB = &FF.
        sta     ($B0),y
        iny
L8D51:  sta     ($B0),y
        pla                                     ; discard byte on stack
        rts

; ----------------------------------------------------------------------------
; Copy two bytes from catalogue to OSFILE block
L8D55:  jsr     L8D58
L8D58:  jsr     select_ram_page_003             ; page in catalogue sector 1
        lda     $FD08,x
        jsr     select_ram_page_001             ; page in main workspace
        sta     ($B0),y
        inx
        iny
        rts

; ----------------------------------------------------------------------------
; *STAT
stat_command:
        jsr     gsinit_with_carry_clear         ; call GSINIT with C=0
        jsr     LAA72                           ; select specified or default volume
        txa                                     ; test bit 0 of X
        and     #$01                            ; if X=3 drive and volume specified
        beq     L8D74
        jmp     L8DB3                           ; then stat specified volume, else:

; ----------------------------------------------------------------------------
; *STAT eight volumes if double density
L8D74:  lda     current_drive                   ; get current volume
        and     #$0F                            ; extract drive number
        sta     current_drive                   ; set current volume letter to A
        lda     #$80                            ; data transfer call &80 = read data to JIM
        sta     $FDE9                           ; set data transfer call number
        jsr     LABB5                           ; detect disc format/set sector address
        bit     $FDED                           ; test density flag
        bvs     L8D8A                           ; if double density then *STAT eight volumes
        jmp     L8DB3                           ; else *STAT the single volume

; ----------------------------------------------------------------------------
; *STAT eight volumes
L8D8A:  jsr     L8F0B                           ; print disc type and volume list
        ldx     #$00                            ; for each volume letter A..H:
L8D8F:  jsr     select_ram_page_000             ; page in auxiliary workspace
        lda     $FDCD,x                         ; test if number of tracks in volume > 0
        beq     L8DA4                           ; if = 0 then no such volume, skip
        txa                                     ; save volume counter
        pha
        jsr     L8469                           ; print newline
        jsr     L961F                           ; ensure current volume catalogue loaded
        jsr     L9033                           ; print volume statistics
        pla                                     ; restore volume counter
        tax
L8DA4:  clc
        lda     current_drive                   ; get current volume
        adc     #$10                            ; increment volume letter
        sta     current_drive                   ; set as current volume
        inx                                     ; increment counter
        cpx     #$08                            ; loop until 8 volumes catalogued
        bne     L8D8F
        jmp     select_ram_page_001

; ----------------------------------------------------------------------------
; *STAT specified volume
L8DB3:  jsr     L961F                           ; ensure current volume catalogue loaded
        jsr     L8F0B                           ; print disc type and volume list
        jmp     L9033                           ; print volume statistics

; ----------------------------------------------------------------------------
; Print "No file"
L8DBC:  jsr     print_string_nterm              ; print string immediate
        .byte   $0D                             ; newline
        .byte   "No file"
        .byte   $0D                             ; newline
; ----------------------------------------------------------------------------
        nop
        rts

; ----------------------------------------------------------------------------
; List files in catalogue
L8DCA:  jsr     select_ram_page_003             ; page in catalogue sector 1
        lda     $FD05                           ; get number of files in catalogue * 8
        beq     L8DBC                           ; if catalogue empty then print "No file"
        sta     $AC                             ; else copy file count to zero page
        ldy     #$FF
        sty     L00A8                           ; print a newline before first entry
        iny
        sty     L00AA                           ; CSD printed first, directory char = NUL
L8DDB:  jsr     select_ram_page_002             ; page in catalogue sector 0
        cpy     $AC                             ; have we reached the end of the catalogue?
        bcs     L8DFF                           ; if so then start sorting entries
        lda     $FD0F,y                         ; else get directory character of cat entry
        jsr     select_ram_page_001             ; page in main workspace
        eor     $FDC6                           ; compare with default (CSD) directory
        jsr     select_ram_page_002             ; page in catalogue sector 0
        and     #$7F                            ; mask off lock bit
        bne     L8DFA                           ; if directories differ skip to next entry
        lda     $FD0F,y                         ; else set directory character to NUL
        and     #$80                            ; and preserve lock bit
        sta     $FD0F,y
L8DFA:  jsr     iny_x8                          ; add 8 to Y
        bcc     L8DDB                           ; and loop (always)
L8DFF:  jsr     select_ram_page_002             ; page in catalogue sector 0
        ldy     #$00                            ; y=&00, start at first file entry
        jsr     L8E9E                           ; find unlisted catalogue entry
        bcc     L8E12                           ; if entry found then list it
        jsr     select_ram_page_001             ; else finish catalogue.
        jsr     L9753                           ; forget catalogue in JIM pages 2..3
        jmp     L8469                           ; print newline and exit

; ----------------------------------------------------------------------------
L8E12:  sty     $AB                             ; save catalogue pointer
        ldx     #$00                            ; set filename offset = 0
L8E16:  jsr     select_ram_page_002
        lda     $FD08,y                         ; copy name and directory of first entry
        and     #$7F                            ; with b7 clear
        jsr     select_ram_page_001
        sta     $FDA1,x                         ; to workspace
        iny                                     ; loop until 8 characters copied
        inx
        cpx     #$08
        bne     L8E16
L8E2A:  jsr     select_ram_page_002
        jsr     L8E9E                           ; find unlisted catalogue entry
        bcs     L8E5D                           ; if none remaining then print lowest entry
        sec                                     ; else set C=1 for subtraction
        ldx     #$06                            ; start at 6th character (LSB) of leaf name:
L8E35:  jsr     select_ram_page_002             ; page in catalogue sector 0
        lda     $FD0E,y                         ; get character of entry
        jsr     select_ram_page_001             ; page in main workspace
        sbc     $FDA1,x                         ; subtract character of workspace
        dey                                     ; loop until 7 characters compared
        dex
        bpl     L8E35
        jsr     iny_x7                          ; add 7 to Y
        jsr     select_ram_page_002             ; page in catalogue sector 0
        lda     $FD0F,y                         ; get directory character (MSB) of entry
        and     #$7F                            ; mask off lock bit
        jsr     select_ram_page_001             ; page in main workspace
        sbc     $FDA8                           ; subtract directory character in workspace
        bcc     L8E12                           ; if entry < wksp then copy entry to wksp
        jsr     iny_x8                          ; else add 8 to Y
        bcs     L8E2A                           ; and loop (always)
L8E5D:  jsr     select_ram_page_002             ; page in catalogue sector 0
        ldy     $AB                             ; get catalogue pointer
        lda     $FD08,y                         ; set b7 in first character of leaf name
        ora     #$80                            ; marking entry as listed
        sta     $FD08,y
        jsr     select_ram_page_001             ; page in main workspace
        lda     $FDA8                           ; get directory character from workspace
        cmp     L00AA                           ; compare with last one printed
        beq     L8E84                           ; if same then add entry to group
        ldx     L00AA                           ; else test previous directory
        sta     L00AA                           ; set previous directory = current directory
        bne     L8E84                           ; if prev=NUL we go from CSD to other dirs
        jsr     L8469                           ; so print double newline:
L8E7D:  jsr     L8469                           ; print newline
        ldy     #$FF                            ; set Y = &FF going to 0, start of line
        bne     L8E8D                           ; branch (always)
L8E84:  ldy     L00A8                           ; have we printed two entries on this line?
        bne     L8E7D                           ; if so then print newline and reset counter
        ldy     #$05                            ; else tab to next field. Y = 5 spaces
        jsr     print_N_spaces_without_spool    ; print number of spaces in Y, set index = 1:
L8E8D:  iny
        sty     L00A8                           ; y = index of next entry on this line
        ldy     $AB                             ; get catalogue pointer
        jsr     print_2_spaces_without_spool    ; print two spaces
        jsr     L8AA3                           ; print filename from catalogue
        jmp     L8DFF                           ; loop until all files listed

; ----------------------------------------------------------------------------
; Find next unlisted catalogue entry
L8E9B:  jsr     iny_x8                          ; add 8 to Y
; Find unlisted catalogue entry
L8E9E:  cpy     $AC                             ; if catalogue pointer beyond last file
        bcs     L8EA7                           ; then return C=1
        lda     $FD08,y                         ; else test first character of leaf name
        bmi     L8E9B                           ; if b7=1 then already listed, skip
L8EA7:  rts                                     ; else return C=0, catalogue pointer in Y

; ----------------------------------------------------------------------------
; Print volume spec in A (assuming DD)
L8EA8:  bit     L8EA7                           ; set V=1
        bvs     L8EBE                           ; always print volume letter B..H after drive
; Print " Drive " plus volume spec in A
L8EAD:  jsr     print_string_nterm
        .byte   " Drive "
; ----------------------------------------------------------------------------
        nop
; Print volume spec in A
L8EB8:  jsr     select_ram_page_001             ; test density flag
        bit     $FDED
L8EBE:  php                                     ; save density flag on stack
        pha                                     ; save volume on stack
        and     #$07                            ; extract bits 2..0, drive 0..7
        jsr     print_hex_nybble                ; print hex nibble
        pla                                     ; restore volume
        plp                                     ; restore density flag
        bvc     L8ECF                           ; if single density then only print drive no.
        lsr     a                               ; else shift volume letter to bits 2..0
        lsr     a
        lsr     a
        lsr     a
        bne     L8ED0                           ; if volume letter is not A then print it
L8ECF:  rts                                     ; else exit

; ----------------------------------------------------------------------------
L8ED0:  dey                                     ; decrement Y (no. spaces to print later)
        clc                                     ; add ASCII value of "A"
        adc     #$41                            ; to produce volume letter B..H
        jmp     print_char_without_spool        ; print character in A (OSASCI) and exit

; ----------------------------------------------------------------------------
; Print volume title
print_disc_title_and_cycle_number:
        ldy     #$0B                            ; set y = &0B print 11 spaces
        jsr     print_N_spaces_without_spool    ; print number of spaces in Y
L8EDC:  jsr     select_ram_page_002             ; page in catalogue sector 0
        lda     $FD00,y                         ; y=0; if Y=0..7 get char from sector 0
        cpy     #$08                            ; if Y=8..11
        bcc     L8EEC
        jsr     select_ram_page_003             ; page in catalogue sector 1
        lda     fdc_status_or_cmd,y             ; then get character of title from sector 1
L8EEC:  jsr     print_char_without_spool        ; print character in A (OSASCI)
        iny                                     ; loop until 12 characters of title printed
        cpy     #$0C
        bne     L8EDC
        jsr     print_string_nterm              ; print " ("
        .byte   $0D
        .byte   " ("
; ----------------------------------------------------------------------------
        nop
        jsr     select_ram_page_003             ; page in catalogue sector 1
        lda     $FD04                           ; get BCD catalogue cycle number
        jsr     print_hex_byte                  ; print hex byte
        jsr     print_string_nterm              ; print ")" +newline
        .byte   ")"
        .byte   $0D
; ----------------------------------------------------------------------------
        nop
        rts

; ----------------------------------------------------------------------------
L8F0B:  jsr     select_ram_page_001             ; page in main workspace
        jsr     is_current_drive_ram_disk       ; set Z=1 iff current drive is a RAM disc
        beq     L8F79                           ; if so then print "RAM Disk"
        bit     $FDED                           ; else test density flag
        bvs     L8F21                           ; if double density print "Double density"
        jsr     print_string_nterm              ; else print "Single density"
        .byte   "Sing"
; ----------------------------------------------------------------------------
        bcc     L8F29
L8F21:  jsr     print_string_nterm
        .byte   "Doub"
; ----------------------------------------------------------------------------
        nop
L8F29:  jsr     print_string_nterm
        .byte   "le density"

; ----------------------------------------------------------------------------
        nop
        ldy     #$0E                            ; set Y = 14 spaces for single density
        bit     $FDED                           ; test density flag
        bvc     L8F62                           ; if single density skip list of volumes
        ldy     #$05                            ; else Y = 5 spaces for double density
        jsr     print_N_spaces_without_spool    ; print number of spaces in Y
        ldx     #$00                            ; set volume index = 0, start at volume A:
L8F45:  clc                                     ; clear carry for add
        jsr     select_ram_page_000             ; page in auxiliary workspace
        lda     $FDCD,x                         ; test if number of tracks in volume > 0
        php                                     ; preserve result
        txa                                     ; copy index to A to make volume letter
        plp                                     ; restore result
        bne     L8F53                           ; if volume present print its letter
        lda     #$ED                            ; else A=&ED + &41 = &2E, ".":
L8F53:  adc     #$41                            ; add ASCII value of "A"
        jsr     print_char_without_spool        ; print character in A (OSASCI)
        inx                                     ; point to next volume
        cpx     #$08                            ; have all 8 volumes been listed?
        bne     L8F45                           ; if not then loop
        jsr     select_ram_page_001             ; page in main workspace
        ldy     #$01                            ; else Y=1 space separating volume list:
L8F62:  bit     $FDEA                           ; test double-stepping flag
        bpl     L8F76                           ; if set manually (*OPT 8,0/1) then end line
        bvc     L8F76                           ; if 1:1 stepping was detected then end line
        jsr     print_N_spaces_without_spool    ; else print 1 or 14 spaces
        jsr     print_string_nterm              ; print "40in80"
        .byte   "40in80"
; ----------------------------------------------------------------------------
        nop
L8F76:  jmp     L8469                           ; print newline

; ----------------------------------------------------------------------------
; Print "RAM Disk"
L8F79:  jsr     print_string_255term            ; print VDU sequence immediate
        .byte   "RAM Disk"
        .byte   $FF
; ----------------------------------------------------------------------------
        jmp     L8469                           ; print newline

; ----------------------------------------------------------------------------
; Print volume spec and boot option
L8F88:  ldy     #$0D                            ; set Y = &0D print 13 spaces
        lda     current_drive                   ; get current volume
        jsr     L8EAD                           ; print " Drive " plus volume spec in A
        jsr     print_N_spaces_without_spool    ; print number of spaces in Y
        jsr     select_ram_page_003             ; page in catalogue sector 1
        jsr     print_string_nterm              ; print "Option "
        .byte   "Option "
; ----------------------------------------------------------------------------
        lda     $FD06                           ; get boot option/top bits volume size
        jsr     lsr_x4                          ; shift A right 4 places
        jsr     print_hex_nybble                ; print hex nibble
        jsr     print_string_nterm              ; print " ("
        .byte   " ("
; ----------------------------------------------------------------------------
        tax                                     ; transfer to X for use as index
        jsr     print_table_string              ; print boot or Challenger config descriptor
        jsr     print_string_nterm              ; print ")"+newline
        .byte   ")"
        .byte   $0D
; ----------------------------------------------------------------------------
        nop
        rts

; ----------------------------------------------------------------------------
; Print CSD and library directories
L8FB8:  jsr     print_string_nterm              ; print " Directory :"
        .byte   " Directory :"

; ----------------------------------------------------------------------------
        ldy     #$06                            ; 6 characters in next field
        jsr     select_ram_page_001             ; page in main workspace
        ldx     #$00                            ; x = 0 point to default (CSD) directory
        jsr     L8FE8                           ; print default or library directory
        jsr     print_N_spaces_without_spool    ; print number of spaces in Y
        jsr     print_string_nterm              ; print "Library :"
        .byte   "Library :"

; ----------------------------------------------------------------------------
        ldx     #$02                            ; x = 2 point to library directory
        jsr     L8FE8                           ; print default or library directory
        jmp     L8469                           ; print newline

; ----------------------------------------------------------------------------
; Print default or library directory
L8FE8:  lda     $FDC7,x                         ; get default or library volume
        jsr     L8EA8                           ; print volume spec in A (assuming DD)
        jsr     print_dot_without_spool         ; print a dot
        lda     $FDC6,x                         ; get default or library directory
        jmp     print_char_without_spool        ; print character in A (OSASCI)

; ----------------------------------------------------------------------------
; 0="off" 1="LOAD" 2="RUN" 3="EXEC" 4="inactive" 5="256K" 6="512K"
; Print boot or Challenger config descriptor
print_table_string:
        lda     strings_offsets_table,x         ; look up offset of message selected by X
        tax                                     ; replace X with offset of message:
L8FFB:  lda     strings_data,x                  ; get character of message
        beq     L9006                           ; if NUL terminator reached then exit
        jsr     print_char_without_spool        ; else print character in A (OSASCI)
        inx                                     ; increment offset
        bpl     L8FFB                           ; and loop (always)
L9006:  rts

; ----------------------------------------------------------------------------
; Table of offsets of boot descriptors 0..3
strings_offsets_table:
        .byte   $00,$04,$09,$0D,$12,$1B,$20
; ----------------------------------------------------------------------------
; Table of boot option descriptors 0..3
strings_data:
        .byte   "off"
        .byte   $00
        .byte   "LOAD"
        .byte   $00
        .byte   "RUN"
        .byte   $00
        .byte   "EXEC"
        .byte   $00
; Table of Challenger configuration descriptors 4..6
        .byte   "inactive"
        .byte   $00
        .byte   "256K"
        .byte   $00
        .byte   "512K"
        .byte   $00
; ----------------------------------------------------------------------------
; Print volume statistics
L9033:  ldy     #$03                            ; y=3 print <drv> 2 spaces/<drv><vol> 1 space
        lda     current_drive                   ; get current volume
        jsr     L8EAD                           ; print " Drive " plus volume spec in A
        jsr     print_N_spaces_without_spool    ; print number of spaces in Y
        jsr     print_string_nterm
        .byte   "Volume size   "

; ----------------------------------------------------------------------------
        nop
        jsr     select_ram_page_003             ; page in catalogue sector 1
        lda     $FD07                           ; copy volume size to sector count
        sta     L00A8                           ; LSB
        lda     $FD06                           ; get boot option/top bits volume size
        and     #$03                            ; mask top bits volume size
        sta     $A9                             ; store MSB
        jsr     LB380                           ; print sector count as kilobytes
        jsr     L8469                           ; print newline
        ldy     #$0B                            ; set Y = &0B print 11 spaces
        jsr     print_N_spaces_without_spool    ; print number of spaces in Y
        jsr     print_string_nterm              ; print "Volume unused"
        .byte   "Volume unused "

; ----------------------------------------------------------------------------
        nop
        jsr     select_ram_page_003             ; calculate used space on volume
        ldy     $FD05                           ; get number of files in catalogue * 8
        lda     #$00
        sta     $CB                             ; clear MSB number of used sectors on volume
        jsr     LA4F8                           ; return no. reserved sectors in data area
        sta     $CA                             ; set LSB number of used sectors on volume
L908A:  jsr     dey_x8                          ; subtract 8 from Y
        cpy     #$F8                            ; if Y=&F8 then was 0, first (last) file done
        beq     L909A                           ; if all files added then continue, else:
        jsr     LA714                           ; calculate number of sectors used by file
        jsr     LA733                           ; add number of sectors to total
        jmp     L908A                           ; loop for next file

; ----------------------------------------------------------------------------
L909A:  jsr     select_ram_page_003             ; page in catalogue sector 1
        sec                                     ; c=1 for subtract
        lda     $FD07                           ; get LSB volume size from catalogue
        sbc     $CA                             ; subtract LSB used space
        sta     L00A8                           ; store LSB result in zero page
        lda     $FD06                           ; get boot option/top bits volume size
        and     #$03                            ; extract MSB volume size
        sbc     $CB                             ; subtract MSB used space, store in zp
        sta     $A9
        jsr     LB380                           ; print sector count as kilobytes
        jmp     L8469                           ; print newline

; ----------------------------------------------------------------------------
; Challenger command table
command_table:
        .byte   "ACCESS"
; ----------------------------------------------------------------------------
        .dbyt   $936E
; ----------------------------------------------------------------------------
        .byte   $32                             ; syntax &2,&3: <afsp> (L)
; ----------------------------------------------------------------------------
        .byte   "BACKUP"
; ----------------------------------------------------------------------------
        .dbyt   $8569
; ----------------------------------------------------------------------------
        .byte   $54                             ; syntax &4,&5: <src drv> <dest drv>
; ----------------------------------------------------------------------------
        .byte   "COMPACT"
; ----------------------------------------------------------------------------
        .dbyt   $A636
; ----------------------------------------------------------------------------
        .byte   $0A                             ; syntax &A: (<drv>)
; ----------------------------------------------------------------------------
        .byte   "CONFIG"
; ----------------------------------------------------------------------------
        .dbyt   $AAF6
; ----------------------------------------------------------------------------
        .byte   $0A                             ; syntax &A: (<drv>)
; ----------------------------------------------------------------------------
        .byte   "COPY"
; ----------------------------------------------------------------------------
        .dbyt   $8665
; ----------------------------------------------------------------------------
        .byte   $64                             ; syntax &4,&6: <src drv> <dest drv> <afsp>
; ----------------------------------------------------------------------------
        .byte   "DELETE"
; ----------------------------------------------------------------------------
        .dbyt   $9274
; ----------------------------------------------------------------------------
        .byte   $01                             ; syntax &1: <fsp>
; ----------------------------------------------------------------------------
        .byte   "DESTROY"
; ----------------------------------------------------------------------------
        .dbyt   $9283
; ----------------------------------------------------------------------------
        .byte   $02                             ; syntax &2: <afsp>
; ----------------------------------------------------------------------------
        .byte   "DIR"
; ----------------------------------------------------------------------------
        .dbyt   $9313
; ----------------------------------------------------------------------------
        .byte   $09                             ; syntax &9: (<dir>)
; ----------------------------------------------------------------------------
        .byte   "DRIVE"
; ----------------------------------------------------------------------------
        .dbyt   $930A
; ----------------------------------------------------------------------------
        .byte   $0A                             ; syntax &A: (<drv>)
; ----------------------------------------------------------------------------
        .byte   "ENABLE"
; ----------------------------------------------------------------------------
        .dbyt   $955C
; ----------------------------------------------------------------------------
        .byte   $00                             ; syntax &0: no arguments
; ----------------------------------------------------------------------------
        .byte   "FDCSTAT"
; ----------------------------------------------------------------------------
        .dbyt   $B766
; ----------------------------------------------------------------------------
        .byte   $80                             ; syntax &0: no arguments        b7=1
; ----------------------------------------------------------------------------
        .byte   "INFO"
; ----------------------------------------------------------------------------
        .dbyt   $8C1C
; ----------------------------------------------------------------------------
        .byte   $02                             ; syntax &2: <afsp>
; ----------------------------------------------------------------------------
        .byte   "LIB"
; ----------------------------------------------------------------------------
        .dbyt   $9316
; ----------------------------------------------------------------------------
        .byte   $09                             ; syntax &9: (<dir>)
; ----------------------------------------------------------------------------
        .byte   "MAP"
; ----------------------------------------------------------------------------
        .dbyt   $8B54
; ----------------------------------------------------------------------------
        .byte   $0A                             ; syntax &A: (<drv>)
; ----------------------------------------------------------------------------
        .byte   "RENAME"
; ----------------------------------------------------------------------------
        .dbyt   $95C6
; ----------------------------------------------------------------------------
        .byte   $78                             ; syntax &8,&7: <old fsp> <new fsp>
; ----------------------------------------------------------------------------
        .byte   "STAT"
; ----------------------------------------------------------------------------
        .dbyt   $8D66
; ----------------------------------------------------------------------------
        .byte   $0A                             ; syntax &A: (<drv>)
; ----------------------------------------------------------------------------
        .byte   "TITLE"
; ----------------------------------------------------------------------------
        .dbyt   $9339
; ----------------------------------------------------------------------------
        .byte   $0B                             ; syntax &B: <title>
; ----------------------------------------------------------------------------
        .byte   "WIPE"
; ----------------------------------------------------------------------------
        .dbyt   $923F
; ----------------------------------------------------------------------------
        .byte   $02                             ; syntax &2: <afsp>
; ----------------------------------------------------------------------------
        .dbyt   $9823                           ; unrecognised command, *RUN it  &9823
; ----------------------------------------------------------------------------
; Utility command table
        .byte   "BUILD"
; ----------------------------------------------------------------------------
        .dbyt   $8415
; ----------------------------------------------------------------------------
        .byte   $01                             ; syntax &1: <fsp>
; ----------------------------------------------------------------------------
        .byte   "DISC"
; ----------------------------------------------------------------------------
        .dbyt   $820E
; ----------------------------------------------------------------------------
        .byte   $00                             ; syntax &0: no arguments
; ----------------------------------------------------------------------------
        .byte   "DUMP"
; ----------------------------------------------------------------------------
        .dbyt   $83A4
; ----------------------------------------------------------------------------
        .byte   $01                             ; syntax &1: <fsp>
; ----------------------------------------------------------------------------
        .byte   "FORMAT"
; ----------------------------------------------------------------------------
        .dbyt   $AE88
; ----------------------------------------------------------------------------
        .byte   $8A                             ; syntax &A: (<drv>)             b7=1
; ----------------------------------------------------------------------------
        .byte   "LIST"
; ----------------------------------------------------------------------------
        .dbyt   $8362
; ----------------------------------------------------------------------------
        .byte   $01                             ; syntax &1: <fsp>
; ----------------------------------------------------------------------------
        .byte   "TYPE"
; ----------------------------------------------------------------------------
        .dbyt   $835B
; ----------------------------------------------------------------------------
        .byte   $01                             ; syntax &1: <fsp>
; ----------------------------------------------------------------------------
        .byte   "VERIFY"
; ----------------------------------------------------------------------------
        .dbyt   $B07E
; ----------------------------------------------------------------------------
        .byte   $8A                             ; syntax &A: (<drv>)             b7=1
; ----------------------------------------------------------------------------
        .byte   "VOLGEN"
; ----------------------------------------------------------------------------
        .dbyt   $B140
; ----------------------------------------------------------------------------
        .byte   $8A                             ; syntax &A: (<drv>)             b7=1
; ----------------------------------------------------------------------------
; entry not printed in *HELP UTILS
        .byte   "DISK"
; ----------------------------------------------------------------------------
        .dbyt   $820E
; ----------------------------------------------------------------------------
        .byte   $00                             ; syntax &0: no arguments
; ----------------------------------------------------------------------------
        .dbyt   $91A7                           ; unrecognised utility, return   &91A7
; ----------------------------------------------------------------------------
; *HELP keyword table
        .byte   "CHAL"
; ----------------------------------------------------------------------------
        .dbyt   $A52E
; ----------------------------------------------------------------------------
        .byte   $00
; ----------------------------------------------------------------------------
        .byte   "DFS"
; ----------------------------------------------------------------------------
        .dbyt   $A52E
; ----------------------------------------------------------------------------
        .byte   $00
; ----------------------------------------------------------------------------
        .byte   "UTILS"
; ----------------------------------------------------------------------------
        .dbyt   $A526
; ----------------------------------------------------------------------------
        .byte   $00
; ----------------------------------------------------------------------------
        .dbyt   $91A7                           ; unrecognised keyword, return   &91A7
; ----------------------------------------------------------------------------
; Return from unrecognised keyword
        rts

; ----------------------------------------------------------------------------
; on entry A=string offset (=Y to GSINIT)
; XY=address of table
; Search for command or keyword in table
L91A8:  jsr     init_lda_abx_thunk              ; set up trampoline to read table at XY
        tay
        jsr     gsinit_with_carry_clear         ; call GSINIT with C=0
        tya                                     ; save offset of start of command line
        pha
        lda     ($F2),y                         ; get first character of command
        and     #$5F                            ; make uppercase
        cmp     #$43                            ; is it C?
        bne     L91C4                           ; if not then search in table
        iny                                     ; else skip to next character
        lda     ($F2),y                         ; fetch it
        cmp     #$20                            ; is it a space?
        bne     L91C4                           ; if not then search in table
        pla                                     ; else discard offset of start of command line
        iny                                     ; skip past the space
        tya                                     ; save new offset of start of command:
        pha                                     ; accept *C <command> as alias of *<command>.
L91C4:  pla                                     ; restore offset of start of command line
        tay
        pha
        ldx     #$00                            ; start at current trampoline address
        jsr     L00AA                           ; fetch first byte
        sec                                     ; if terminator,empty keyword matches anything
        bmi     L920A                           ; so jump to following action address with C=1
        dex                                     ; else decrement X and Y to stay in place:
        dey
L91D1:  inx                                     ; advance command line and table offsets
        iny
        jsr     L00AA                           ; get byte from table
        bmi     L91FA                           ; if terminator, check command also terminates
        eor     ($F2),y                         ; else compare with character of command
        and     #$5F                            ; make comparison case-insensitive
        beq     L91D1                           ; if equal then compare next characters
        lda     ($F2),y                         ; else get mismatching character of command
        cmp     #$2E                            ; is it a dot?
        php                                     ; save the result
L91E3:  inx                                     ; scan keyword in table
        jsr     L00AA
        bpl     L91E3                           ; loop until terminator reached
        inx                                     ; skip action address, 2 bytes
        inx
        plp                                     ; is the command an abbreviation or a mismatch?
        bne     L91F3                           ; if mismatch then skip syntax, scan next kywd
        jsr     L00AA                           ; else test syntax byte
        bpl     L9206                           ; if b7=0 accept cmd, else abbrev. not allowed:
L91F3:  inx                                     ; skip syntax byte
        jsr     L922D                           ; add X to trampoline address
        jmp     L91C4                           ; scan next keyword

; ----------------------------------------------------------------------------
L91FA:  lda     ($F2),y                         ; get character of command
        jsr     isalpha                         ; set C=0 iff character in A is a letter
        bcs     L9209                           ; if C=1 accept command, else longer than kywd
        inx                                     ; so skip action address, 2 bytes
        inx
        jmp     L91F3                           ; skip syntax byte and scan next keyword

; ----------------------------------------------------------------------------
; Accept abbreviated command
L9206:  dex                                     ; backtrack to action address, 2 bytes
        dex
        iny                                     ; advance command line offset past the dot:
; Accept command
L9209:  clc                                     ; set C=0 command valid
L920A:  pla                                     ; discard offset to start of command
        jsr     L00AA                           ; get action address high byte
        sta     $A9                             ; store high byte of vector
        inx                                     ; advance to next byte of table
        jsr     L00AA                           ; get action address low byte
        sta     L00A8                           ; store low byte of vector
        inx                                     ; return X=offset of syntax byte
        rts                                     ; y=offset of command line tail.

; ----------------------------------------------------------------------------
; YX = addr - create little thunk at $AA that does STA addr,X - YX = addr
; unreachable code
init_sta_abx_thunk:
        pha                                     ; set up trampoline to write table at XY
        lda     #$9D
        jmp     L9221

; ----------------------------------------------------------------------------
; YX = addr - create little thunk at $AA that does LDA addr,X
; Set up trampoline to read table at XY
init_lda_abx_thunk:
        pha
        lda     #$BD                            ; &BD = LDA abs,X
L9221:  sta     L00AA                           ; instruction at &00AA = LDA xy,X
        stx     $AB
        sty     $AC
        lda     #$60                            ; instruction at &00AD = RTS
        sta     $AD
        pla                                     ; restore A
        rts

; ----------------------------------------------------------------------------
; Add X to trampoline address
L922D:  clc
        txa
        adc     $AB                             ; add X to low byte of LDA,X address
        sta     $AB
        bcc     L9237                           ; carry out to high byte
        inc     $AC
L9237:  rts

; ----------------------------------------------------------------------------
; ?&F2=X, ?&F3=Y, Y=0
; Set GSINIT pointer to XY, set Y=0
set_f2_y:
        stx     $F2
        sty     $F3
        ldy     #$00
        rts

; ----------------------------------------------------------------------------
; *WIPE
wipe_command:
        jsr     L92DD                           ; ensure file matching wildcard argument
L9242:  jsr     L8AA3                           ; print filename from catalogue
        jsr     print_string_nterm
        .byte   " : "
; ----------------------------------------------------------------------------
        nop
        jsr     select_ram_page_002             ; page in catalogue sector 0
        lda     $FD0F,y                         ; test lock bit
        bpl     L925A                           ; if unlocked then ask to delete
        jsr     print_N_without_spool           ; else deletion not allowed, print letter N
        jmp     L926B                           ; find next matching file

; ----------------------------------------------------------------------------
L925A:  jsr     L84DE                           ; ask user yes or no
        bne     L926B                           ; if user replies no then find next match
        jsr     L8A7E                           ; else ensure disc not changed
        jsr     L8C78                           ; delete catalogue entry
        jsr     L960B                           ; write volume catalogue
        jsr     L9300                           ; shift cat pointer to follow shifted files
L926B:  jsr     L8469                           ; print newline
        jsr     L8C35                           ; find next matching file
        bcs     L9242                           ; if found then wipe the file
        rts                                     ; else exit

; ----------------------------------------------------------------------------
; *DELETE
delete_command:
        jsr     L8B32                           ; disallow wildcard characters in filename
        jsr     L92E0                           ; ensure file matching argument
        jsr     L8C9D                           ; print *INFO line if verbose
        jsr     L8C78                           ; delete catalogue entry
        jmp     L960B                           ; write volume catalogue

; ----------------------------------------------------------------------------
; *DESTROY
destroy_command:
        jsr     LA75F                           ; ensure *ENABLE active
        jsr     L92DD                           ; ensure file matching wildcard argument
L9289:  jsr     L8AA3                           ; print filename from catalogue
        jsr     L8469                           ; print newline
        jsr     L8C35                           ; find next matching file
        bcs     L9289                           ; loop until all matching files listed
        jsr     print_string_nterm
        .byte   $0D
        .byte   "Delete (Y/N) ? "

; ----------------------------------------------------------------------------
        nop
        jsr     L84DE                           ; ask user yes or no
        beq     L92B0                           ; if user replies yes then proceed
        jmp     L8469                           ; else print newline and exit

; ----------------------------------------------------------------------------
L92B0:  jsr     L8A7E                           ; ensure disc not changed
        jsr     L8C2E                           ; search for file in catalogue
L92B6:  jsr     select_ram_page_002             ; page in catalogue sector 0
        lda     $FD0F,y                         ; unlock catalogue entry!
        and     #$7F
        sta     $FD0F,y
        jsr     L8C78                           ; delete catalogue entry
        jsr     L9300                           ; subtract 8 from catalogue pointer
        jsr     L8C35                           ; find next matching file
        bcs     L92B6
        jsr     L960B                           ; write volume catalogue
        jsr     print_string_nterm              ; print "Deleted" and exit
        .byte   $0D
        .byte   "Deleted"
        .byte   $0D
; ----------------------------------------------------------------------------
        nop
        rts

; ----------------------------------------------------------------------------
; Ensure file matching wildcard argument
L92DD:  jsr     L8B2E                           ; allow wildcard characters in filename
; Ensure file matching argument
L92E0:  jsr     LA565                           ; call GSINIT with C=0 and reject empty arg
        jmp     L8B38                           ; ensure file matching spec in catalogue

; ----------------------------------------------------------------------------
; Set current file from argument
L92E6:  jsr     LA565                           ; call GSINIT with C=0 and reject empty arg
        jmp     L89DC                           ; set current file from file spec

; ----------------------------------------------------------------------------
; Pack b17,16 of length into catalogue entry
L92EC:  jsr     asl_x4                          ; shift A left 4 places
        jsr     select_ram_page_003             ; page in catalogue sector 1
        eor     $FD0E,x                         ; replace b5,b4 of top bits with b5,b4 from A
        and     #$30
        eor     $FD0E,x
        sta     $FD0E,x                         ; store top bits back in catalogue
        jmp     select_ram_page_001             ; page in main workspace

; ----------------------------------------------------------------------------
; Subtract 8 from catalogue pointer
L9300:  ldy     $FDC2                           ; get catalogue pointer
        jsr     dey_x8                          ; subtract 8 from Y
        sty     $FDC2                           ; store catalogue pointer
        rts

; ----------------------------------------------------------------------------
; *DRIVE
drive_command:
        jsr     LAA16                           ; parse volume spec from argument
        lda     current_drive                   ; get current volume
        sta     $FDC7                           ; set as default volume
        rts

; ----------------------------------------------------------------------------
; *DIR
dir_command:
        ldx     #$00
        .byte   $AD                             ; *LIB 903A=LDX #&02
lib_command:
        ldx     #$02
        lda     $FDC6,x                         ; get default/library directory
        sta     $CE                             ; set as current directory
        lda     $FDC7,x                         ; get default/library volume
        sta     current_drive                   ; set as current volume
        txa                                     ; save offset
        pha
        jsr     gsinit_with_carry_clear         ; call GSINIT with C=0
        beq     L932C
        jsr     LAA3E                           ; parse directory spec
L932C:  pla                                     ; restore offset
        tax
        lda     $CE                             ; get current directory
        sta     $FDC6,x                         ; set as default/library directory
        lda     current_drive                   ; get current volume
        sta     $FDC7,x                         ; set as default/library volume
        rts

; ----------------------------------------------------------------------------
; *TITLE
title_command:
        jsr     LA565                           ; call GSINIT with C=0 and reject empty arg
        jsr     LAA1E                           ; set current vol/dir = default, set up drive
        jsr     L962F                           ; load volume catalogue L4
        ldx     #$0B                            ; first offset to store = 11
        lda     #$00                            ; set title to 12 NULs:
L9346:  jsr     L935C                           ; store character of title
        dex                                     ; loop until 12 characters stored
        bpl     L9346                           ; finish with X=&FF
L934C:  jsr     gsread                          ; call GSREAD
        bcs     L9359                           ; if end of argument write catalogue
        inx                                     ; else point X to next character
        jsr     L935C                           ; store character of title
        cpx     #$0B                            ; is this the twelfth character written?
        bne     L934C                           ; if not then loop to write more, else:
L9359:  jmp     L960B                           ; write volume catalogue and exit

; ----------------------------------------------------------------------------
; Store character of title
L935C:  cpx     #$08                            ; if offset is 8 or more
        bcc     L9367
        jsr     select_ram_page_003             ; page in catalogue sector 1
        sta     fdc_status_or_cmd,x             ; then store at &0F00..3, X=8..11
        rts

; ----------------------------------------------------------------------------
L9367:  jsr     select_ram_page_002             ; page in catalogue sector 0
        sta     $FD00,x                         ; else store at &0E00..7, X=0..7
        rts

; ----------------------------------------------------------------------------
; *ACCESS
access_command:
        jsr     L8B2E                           ; allow wildcard characters in filename
        jsr     L92E6                           ; set current file from argument
        ldx     #$00                            ; preset X=&00 file unlocked
        jsr     gsinit_with_carry_clear         ; call GSINIT with C=0
        bne     L939C                           ; if argument is empty
L937B:  stx     L00AA                           ; then attribute mask = &00, file unlocked
        jsr     L8B41                           ; ensure matching file in catalogue
L9380:  jsr     LA2AB                           ; ensure file not open (mutex)
        jsr     select_ram_page_002             ; page in catalogue sector 0
        lda     $FD0F,y                         ; get directory character from catalogue
        and     #$7F                            ; mask off old attribute
        ora     L00AA                           ; apply new attribute
        sta     $FD0F,y                         ; put back in catalogue
        jsr     L8C9D                           ; print *INFO line if verbose
        jsr     L8C35                           ; find next matching file
        bcs     L9380                           ; if found then set its attribute
        bcc     L9359                           ; else write volume catalogue and exit
L939A:  ldx     #$80                            ; found L, set bit 7 to indicate file locked:
L939C:  jsr     gsread                          ; call GSREAD, get character of attribute
        bcs     L937B                           ; if end of string then set attribute
        cmp     #$4C                            ; else is character capital L?
        beq     L939A                           ; if so then set bit 7
        jsr     dobrk_with_Bad_prefix           ; else raise "Bad attribute" error.
        .byte   $CF
        .byte   "attribute"

; ----------------------------------------------------------------------------
        brk
; Create file from OSFILE block
L93B3:  jsr     L89E2                           ; set current file from argument pointer
        jsr     L8C2E                           ; search for file in catalogue
        bcc     L93BE                           ; if found
        jsr     L8C78                           ; then delete catalogue entry
L93BE:  lda     $C2                             ; save start address low word
        pha
        lda     $C3
        pha
        sec                                     ; subtract end address - start address
        lda     $C4                             ; (24 bits) yielding file length
        sbc     $C2
        sta     $C2
        lda     $C5
        sbc     $C3
        sta     $C3
        lda     $FDBB
        sbc     $FDB9
        sta     $C6
        jsr     L940B                           ; create catalogue entry
        lda     $FDBA                           ; copy start address high word to data pointer
        sta     $FDB6
        lda     $FDB9
        sta     $FDB5
        pla                                     ; restore low word to data pointer
        sta     $BF
        pla
        sta     $BE
        rts

; ----------------------------------------------------------------------------
; Raise "Disk full" error
L93EF:  jsr     dobrk_with_Disk_prefix
        .byte   $C6                             ; number = &C6, "Disk full", cf. &9EDF
        .byte   "full"
; ----------------------------------------------------------------------------
        brk
; Raise "Catalogue full" error
L93F8:  jsr     print_string_2_nterm
        .byte   $BE
        .byte   "Catalogue full"

; ----------------------------------------------------------------------------
        brk
; Create catalogue entry
L940B:  lda     #$00
        sta     $C4                             ; set MSB of LBA = 0
        jsr     LA4F8                           ; return no. reserved sectors in data area
        sta     $C5                             ; set as LSB of LBA
        jsr     select_ram_page_003             ; page in catalogue sector 1
        ldy     $FD05                           ; get number of files in catalogue * 8
        cpy     #$F8                            ; if there are already 31 files
        bcs     L93F8                           ; then raise "Catalogue full" error
        bcc     L947F                           ; else jump into loop
L9420:  bit     L00A8                           ; if b6=0 will not accept shorter allocation
        bvc     L93EF                           ; then raise "Disk full" error
        lda     #$00
        sta     $C3                             ; else zero LSB size of file to be fitted
        sta     $C6                             ; and MSB
        sta     $C4                             ; set MSB of LBA = 0
        jsr     LA4F8                           ; return no. reserved sectors in data area
        sta     $C5                             ; set as LSB of LBA
        jsr     select_ram_page_003             ; page in catalogue sector 1
        ldy     $FD05                           ; get number of files in catalogue * 8
        jmp     L9443                           ; jump into loop

; ----------------------------------------------------------------------------
L943A:  tya
        beq     L9460                           ; if cat ptr = 0 then test fit
        jsr     dey_x8                          ; else subtract 8 from Y
        jsr     L94D6                           ; calculate LBA of end of file
L9443:  jsr     L9507                           ; calculate slack space after file
        beq     L943A                           ; if no slack space then test prev cat entry
        sec                                     ; else C=1 for subtraction
        jsr     L9521                           ; test if new file will fit after current file
        bcc     L943A                           ; if file won't fit then test prev cat entry
        stx     $C6                             ; else set MSB file size to MSB slack space
        lda     $B0                             ; get LSB slack space
        sta     $C3                             ; set LSB file size
        lda     $C4                             ; this finds the largest slack space on volume
        sta     $B1                             ; save LSB LBA of slack space
        lda     $C5
        sta     $B2                             ; save MSB LBA of slack space
        sty     $C2                             ; save catalogue offset of insertion point
        bcs     L943A                           ; and loop (always)
L9460:  lda     $C3                             ; test slack space found
        ora     $C6                             ; if no slack space available
        beq     L93EF                           ; then raise "Disk full" error
        lda     $B1                             ; else get MSB LBA of slack space
        sta     $C4                             ; set MSB start LBA of file
        lda     $B2                             ; get LSB LBA of slack space
        sta     $C5                             ; set LSB start LBA of file
        ldy     $C2                             ; restore catalogue offset of insertion point
        lda     #$00
        sta     $C2                             ; clear LSB length
        beq     L9489                           ; and branch (always)
L9476:  tya
        beq     L9420                           ; if cat ptr = 0 then test fit
        jsr     dey_x8                          ; else subtract 8 from Y
        jsr     L94D6                           ; calculate LBA of end of file
L947F:  jsr     L9507                           ; calculate slack space after file
        beq     L9476                           ; if no slack space then test prev cat entry
        jsr     L951D                           ; test if new file will fit after current file
        bcc     L9476                           ; if file won't fit then test prev cat entry
L9489:  sty     $B0                             ; else insert new catalogue entry here
        jsr     select_ram_page_003             ; page in catalogue sector 1
        ldy     $FD05                           ; point Y to last valid catalogue entry:
L9491:  cpy     $B0                             ; compare pointer with insertion point
        beq     L94AA                           ; stop copying if insertion point reached
        jsr     select_ram_page_002             ; page in catalogue sector 0
        lda     $FD07,y                         ; else copy current catalogue entry
        sta     $FD0F,y                         ; to next slot
        jsr     select_ram_page_003             ; page in catalogue sector 1
        lda     $FD07,y                         ; leaving one slot open
        sta     $FD0F,y                         ; for new catalogue entry
        dey                                     ; decrease pointer to work back from end
        bcs     L9491                           ; and loop (always)
L94AA:  jsr     select_ram_page_001             ; page in main workspace
        jsr     L953A                           ; compose top bits exec/length/load/start
        jsr     L9529                           ; write filename+dir into catalogue at Y=0..&F0
        jsr     select_ram_page_003             ; page in catalogue sector 1
; Write load/exec/length/start into catalogue
L94B6:  lda     $BD,x                           ; x=8..1 copy from &BE..&C5
        dey                                     ; y=catalogue pointer + 7..0
        sta     $FD08,y                         ; copy to catalogue address fields
        dex                                     ; loop until 8 bytes copied
        bne     L94B6
        jsr     L8C9D                           ; print *INFO line if verbose
        tya                                     ; save catalogue pointer
        pha
        jsr     select_ram_page_003
        ldy     $FD05                           ; get number of files in catalogue * 8
        jsr     iny_x8                          ; add 8 to Y
        sty     $FD05                           ; store new file count
        jsr     L960B                           ; write volume catalogue
        pla                                     ; restore catalogue pointer
        tay
        rts

; ----------------------------------------------------------------------------
; Calculate LBA of end of file
L94D6:  jsr     L94EB                           ; calculate number of sectors used by file
        clc
        lda     $FD0F,y                         ; get LSB start sector
        adc     $C5                             ; add LSB file length in sectors
        sta     $C5                             ; replace with new LSB start sector
        lda     $FD0E,y                         ; get top bits exec/length/load/start sector
        and     #$03                            ; extract MSB start sector
        adc     $C4                             ; add MSB file length in sectors
        sta     $C4                             ; replace with new MSB start sector
        rts

; ----------------------------------------------------------------------------
; Calculate number of sectors used by file
L94EB:  jsr     select_ram_page_003             ; page in catalogue sector 1
        lda     $FD0C,y                         ; get LSB length
        cmp     #$01                            ; c=1 iff LSB >0
        lda     $FD0D,y                         ; add C to 2MSB length, rounding up
        adc     #$00                            ; (Y points to 8 bytes before file entry)
        sta     $C5
        php                                     ; save carry flag from addition
        lda     $FD0E,y                         ; get top bits exec/length/load/start sector
        jsr     extract_00xx0000                ; extract length from b5,4 to b1,0
        plp                                     ; restore carry flag
        adc     #$00                            ; add C to MSB length, rounding up
        sta     $C4                             ; store length in sectors in zero page
        rts

; ----------------------------------------------------------------------------
; Calculate slack space after file
L9507:  jsr     select_ram_page_003             ; page in catalogue sector 1
        sec
        lda     $FD07,y                         ; get LSB LBA of preceding file in catalogue
        sbc     $C5                             ; subtract LSB LBA of end of this file
        sta     $B0                             ; store LSB size of slack space
        lda     $FD06,y                         ; get top bits exec/length/load/start sector
        and     #$03                            ; extract MSB start sector
        sbc     $C4                             ; subtract MSB LBA of end of this file
        tax                                     ; return MSB slack size in X, LSB in &B0
        ora     $B0                             ; test result, Z=1 if file follows without gap
        rts

; ----------------------------------------------------------------------------
; Test if new file will fit after current file
L951D:  lda     #$00                            ; if file includes partial sector
        cmp     $C2                             ; then C=1 include it in the comparison:
; Test if new file will fit after current file
L9521:  lda     $B0                             ; get LSB slack space
        sbc     $C3                             ; subtract LSB file size in sectors
        txa                                     ; a=MSB slack space
        sbc     $C6                             ; subtract MSB file size in sectors
        rts                                     ; return C=1 if file will fit

; ----------------------------------------------------------------------------
; Write filename+dir into catalogue at Y=0..&F0
L9529:  jsr     select_ram_page_002             ; page in catalogue sector 0
        ldx     #$00
L952E:  lda     $C7,x                           ; get character of current filename+dir
        sta     $FD08,y                         ; store in catalogue
        iny                                     ; increment both offsets
        inx
        cpx     #$08                            ; loop until 8 bytes copied.
        bne     L952E
        rts

; ----------------------------------------------------------------------------
; Compose top bits exec/length/load/start
L953A:  lda     $FDB7                           ; get b17,b16 exec address
        and     #$03                            ; place in b1,b0 of A, clear b7..b2
        asl     a                               ; shift A left 2 places
        asl     a                               ; a = ....ee..
        eor     $C6                             ; place b17,b16 of length in b1,b0
        and     #$FC                            ; keep b7..b2 of A
        eor     $C6                             ; a = ....eell
        asl     a                               ; shift A left 2 places
        asl     a                               ; a = ..eell..
        eor     $FDB5                           ; place b17,b16 of load address in b1,b0
        and     #$FC                            ; keep b7..b2 of A
        eor     $FDB5                           ; a = ..eelldd
        asl     a                               ; shift A left 2 places
        asl     a                               ; a = eelldd..
        eor     $C4                             ; place b10,b9 of start LBA in b1,b0
        and     #$FC                            ; keep b7..b2 of A
        eor     $C4                             ; a = eellddss
        sta     $C4                             ; set top bits exec/length/load/start sector
        rts

; ----------------------------------------------------------------------------
; *ENABLE
enable_command:
        jsr     gsinit_with_carry_clear         ; call GSINIT with C=0
        beq     L957D                           ; if no argument then enable *commands
        ldx     #$00                            ; else X=0 offset into "CAT" string:
L9563:  jsr     gsread                          ; call GSREAD
        bcs     L9587                           ; if end of argument then "Bad command"
        cmp     L958A,x                         ; else compare char with char of "CAT"
        bne     L9587                           ; if unequal then "Bad command"
        inx                                     ; else increment offset
        cpx     #$03                            ; loop until whole "CAT" string compared
        bne     L9563
        jsr     gsread                          ; call GSREAD
        bcc     L9587                           ; if argument continues then "Bad command"
        lda     #$80                            ; else *ENABLE CAT
        sta     $FDF4                           ; b7=1 emulate Acorn DFS's main memory use
        rts

; ----------------------------------------------------------------------------
; *ENABLE (no argument)
L957D:  lda     #$80
        sta     $B9                             ; >0 disc operation is interruptible
        lda     #$01                            ; set *ENABLE flag = 1; will be nonnegative
        sta     $FDDF                           ; (after OSFSC 8) for next *command only.
        rts

; ----------------------------------------------------------------------------
L9587:  jmp     L9849                           ; raise "Bad command" error

; ----------------------------------------------------------------------------
L958A:  .byte   "CAT"                           ; CAT keyword for *ENABLE
; ----------------------------------------------------------------------------
; Expand 18-bit load address to 32-bit
L958D:  pha
        lda     #$00                            ; set MSB of address = &00
        pha
        lda     $C4                             ; get top bits exec/length/load/start sector
        jsr     extract_0000xx00                ; extract b3,b2 of A
        cmp     #$03                            ; if either bit clear then a Tube address
        bne     L95A0                           ; so set high word = high word of tube address
        pla                                     ; else discard the high word:
        pla
; Set high word of OSFILE load address = &FFFF
L959C:  pha
        lda     #$FF
        pha
; Set high word of OSFILE load address
L95A0:  jsr     select_ram_page_001             ; page in main workspace
        sta     $FDB5
        pla
        sta     $FDB6
        pla
        rts

; ----------------------------------------------------------------------------
; Expand 18-bit exec address to 32-bit
L95AC:  jsr     select_ram_page_001             ; page in main workspace
        lda     #$00                            ; clear MSB of 32-bit address
        sta     $FDB8
        lda     $C4                             ; get top bits exec/length/load/start sector
        jsr     extract_xx000000                ; extract b7,b6 of A
        cmp     #$03                            ; if b7,b6 both set
        bne     L95C2
        lda     #$FF                            ; then a host address, set high word = &FFFF
        sta     $FDB8
L95C2:  sta     $FDB7                           ; else set 2MSB parasite address &0..2FFFF
        rts

; ----------------------------------------------------------------------------
; *RENAME
rename_command:
        jsr     L8B32                           ; disallow wildcard characters in filename
        jsr     L92E6                           ; set current file from argument
        jsr     get_current_physical_drive      ; map current volume to physical volume
        pha                                     ; save source volume
        tya                                     ; save command line offset
        pha
        jsr     L8B41                           ; ensure matching file in catalogue
        jsr     LA2A8                           ; ensure file not locked or open (mutex)
        sty     $B3                             ; save pointer to file entry
        pla                                     ; restore command line offset
        tay
        jsr     LA565                           ; call GSINIT with C=0 and reject empty arg
        lda     $FDC6                           ; set current directory = default directory
        sta     $CE
        jsr     L89F2                           ; parse file spec
        pla                                     ; restore source volume
        sta     $FDC0                           ; save in workspace
        jsr     get_current_physical_drive      ; map current volume to physical volume
        cmp     $FDC0                           ; compare with source volume
        beq     L95F6                           ; if equal then rename the file
        jmp     L9849                           ; else rename across volumes, "Bad command".

; ----------------------------------------------------------------------------
L95F6:  jsr     L8C2E                           ; search for file in catalogue
        bcc     L9606                           ; if not found then update filename+dir
        jsr     dobrk_with_File_prefix          ; else raise "File exists" error.
        .byte   $C4
        .byte   "exists"
; ----------------------------------------------------------------------------
        brk
; Update filename+dir in catalogue
L9606:  ldy     $B3                             ; get pointer to file entry
        jsr     L9529                           ; write filename+dir into catalogue:
; Write volume catalogue L4
L960B:  jsr     select_ram_page_003             ; page in catalogue sector 1
        clc                                     ; add 1 to BCD catalogue cycle number
        sed
        lda     $FD04
        adc     #$01
        sta     $FD04
        cld
        jsr     L9743                           ; set xfer call no. = write, claim NMI
        jmp     L9635                           ; transfer volume catalogue and exit

; ----------------------------------------------------------------------------
; Ensure current volume catalogue loaded
L961F:  jsr     select_ram_page_001             ; page in main workspace
        jsr     get_current_physical_drive      ; map current volume to physical volume
        cmp     $FDDC                           ; compare with volume of loaded catalogue
        bne     L962F                           ; if unequal then load volume catalogue
        jsr     LBD06                           ; else if motor is on
        beq     copy_enable_cat_data            ; then present cat. and release NMI else:
L962F:  jsr     push_registers_and_tuck_restoration_thunk; save AXY
; Load volume catalogue L4
L9632:  jsr     L973A                           ; set xfer call no. = read, claim NMI:
; Transfer volume catalogue
L9635:  lda     #$00
        sta     $FDCC                           ; transferring to host, not Tube
        lda     #$80
        sta     $B9                             ; >0 disc operation is interruptible
        lda     $FDE9                           ; get data transfer call number
        ora     #$80                            ; b7=1 data address in JIM space
        sta     $FDE9                           ; update data transfer call number
        jsr     LABB5                           ; detect disc format/set sector address
        jsr     get_current_physical_drive      ; map current volume to physical volume
        sta     $FDDC                           ; set drive and volume of loaded catalogue
        jsr     L968B                           ; transfer disc/volume catalogue L3
        beq     copy_enable_cat_data            ; if zero status release NMI and exit
        jmp     LBCAF                           ; else raise "Disk fault" error.

; ----------------------------------------------------------------------------
; Present catalogue and release NMI
copy_enable_cat_data:
        jsr     select_ram_page_001             ; page in main workspace
        bit     $FDF4                           ; test b7=*ENABLE CAT
        bpl     L9679                           ; if enabled
        jsr     select_ram_page_002             ; page in catalogue sector 0
        ldx     #$00                            ; then start at offset 0:
L9664:  lda     $FD00,x                         ; copy catalogue sector 0
        sta     $0E00,x                         ; to main memory page &E, emulating DFS use
        inx                                     ; loop until entire sector copied
        bne     L9664
        jsr     select_ram_page_003             ; page in catalogue sector 1
L9670:  lda     $FD00,x                         ; copy catalogue sector 1
        sta     $0F00,x                         ; to main memory page &F, emulating DFS use
        inx                                     ; loop until entire sector copied
        bne     L9670
L9679:  jsr     select_ram_page_001             ; page in main workspace
        jmp     release_nmi_area                ; release NMI

; ----------------------------------------------------------------------------
; unreachable code
        lda     #$80                            ; data transfer call &80 = read data to JIM
        bne     L9685                           ; branch (always)
; Write disc/volume catalogue L3
L9683:  lda     #$81                            ; data transfer call &81 = write data from JIM
; Transfer disc/volume catalogue L3
L9685:  jsr     select_ram_page_001             ; page in main workspace
        sta     $FDE9                           ; set data transfer call number
; Transfer disc/volume catalogue L3
L968B:  jsr     LA875                           ; save XY
        jsr     L96A5                           ; set data pointer to &0200
        ldx     #$03                            ; set X = &03, three possible attempts:
L9693:  lda     #$00                            ; 512 bytes to transfer
        sta     $A0
        lda     #$02
        sta     $A1
        jsr     LBA18                           ; transfer data L2
        beq     L96A4                           ; if zero status then success, return
        dex                                     ; else decrement attempts counter
        bne     L9693                           ; if not tried 3 times then try again
        dex                                     ; else return Z=0, failed
L96A4:  rts

; ----------------------------------------------------------------------------
; Set data pointer to &0200
L96A5:  lda     #$02                            ; this addresses catalogue sector 0 in JIM
        sta     $A6
        lda     #$00
        sta     $A7
        rts

; ----------------------------------------------------------------------------
; Open Tube data transfer channel
L96AE:  jsr     select_ram_page_001             ; page in main workspace
        pha                                     ; a=Tube service call, save in stack
        lda     $BE                             ; reform address at &FDB3..B6 from &BE,F
        sta     $FDB3
        lda     $BF
        sta     $FDB4
        lda     $FDB5                           ; and high bytes of address
        and     $FDB6                           ; a=&FF if address is in the host
        ora     $FDCD                           ; a=&FF if Tube absent (&10D6=NOT MOS flag!)
        eor     #$FF                            ; invert; A>0 if transferring over Tube
        sta     $FDCC                           ; store Tube flag
        sec
        beq     L96DA                           ; if A=0 then no need for Tube, exit C=1
        jsr     L96DC                           ; else claim Tube
        ldx     #$B3                            ; point XY at address
        ldy     #$FD
        pla                                     ; restore Tube call number
        pha
        jsr     L0406                           ; call Tube service
        clc                                     ; exit C=0 as Tube was called
L96DA:  pla                                     ; preserve Tube call number on exit
        rts

; ----------------------------------------------------------------------------
; Claim Tube
L96DC:  pha
L96DD:  lda     #$C1                            ; tube service call = &C0 + ID for DFS (1)
        jsr     L0406                           ; call Tube service
        bcc     L96DD                           ; loop until C=1, indicating claim granted
        pla
        rts

; ----------------------------------------------------------------------------
; Release Tube
L96E6:  pha
        lda     $FDCC                           ; load Tube flag, A>0 if Tube in use
        beq     L96F1                           ; if not in use then exit, else:
L96EC:  lda     #$81                            ; tube service call = &80 + ID for DFS (1)
        jsr     L0406                           ; call Tube service
L96F1:  pla
        rts

; ----------------------------------------------------------------------------
; Release Tube if present
L96F3:  pha
        lda     #$EA                            ; OSBYTE &EA = read Tube presence flag
        jsr     osbyte_x00_yff                  ; call OSBYTE with X=0, Y=&FF
        txa                                     ; test X, X=&FF if Tube present
        bne     L96EC                           ; if Tube present then release Tube
        pla
        rts

; ----------------------------------------------------------------------------
; Write ordinary file L5
L96FE:  jsr     L973E                           ; prepare to write from user memory
        jmp     L9707                           ; transfer ordinary file L5

; ----------------------------------------------------------------------------
; Read ordinary file L5
L9704:  jsr     L9735                           ; prepare to read to user memory
; Transfer ordinary file L5
L9707:  jsr     L8AED                           ; prepare ordinary file transfer
        jmp     L9719                           ; transfer data and release Tube

; ----------------------------------------------------------------------------
; Read extended file L5
L970D:  jsr     L9735                           ; prepare to read to user memory
        jmp     L9716                           ; transfer extended file L5

; ----------------------------------------------------------------------------
; Write extended file L5
L9713:  jsr     L973E                           ; prepare to write from user memory
; Transfer extended file L5
L9716:  jsr     L8AE4                           ; prepare extended file transfer
L9719:  lda     #$01                            ; a=&01
        jsr     LACE4                           ; transfer data and report errors L4
        jmp     L96E6                           ; release Tube and exit

; ----------------------------------------------------------------------------
; Write ordinary file from JIM L5
L9721:  lda     #$81                            ; data transfer call &81 = write data from JIM
        .byte   $AE                             ; 9724=LDA #&80
; Read ordinary file to JIM L5
L9724:  lda     #$80                            ; data transfer call &80 = read data to JIM
        sta     $FDE9                           ; set data transfer call number
        jsr     claim_nmi_area                  ; claim NMI
        jsr     L8AED                           ; prepare ordinary file transfer
        jsr     LACE4                           ; transfer data and report errors L4
        jmp     L96E6                           ; release Tube

; ----------------------------------------------------------------------------
; Prepare to read to user memory
L9735:  lda     #$01                            ; Tube service 1 = write single bytes to R3
        jsr     L96AE                           ; open Tube data transfer channel
L973A:  lda     #$00                            ; data transfer call &00 = read data
        beq     L974A                           ; branch (always)
; Prepare to write from user memory
L973E:  lda     #$00                            ; Tube service 0 = read single bytes from R3
        jsr     L96AE                           ; open Tube data transfer channel
; Set xfer call no. = write, claim NMI
L9743:  jsr     LADBC                           ; test write protect state of current drive
        bne     L975C                           ; if not then "Disk read only"
        lda     #$01                            ; else data transfer call &01 = write data
L974A:  jsr     select_ram_page_001             ; page in main workspace
        sta     $FDE9                           ; set data transfer call number
        jsr     claim_nmi_area                  ; claim NMI:
; Forget catalogue in JIM pages 2..3
L9753:  jsr     select_ram_page_001             ; page in main workspace
        lda     #$FF
        sta     $FDDC                           ; no catalogue in JIM pages 2..3
        rts

; ----------------------------------------------------------------------------
L975C:  jmp     LA884                           ; raise "Disk read only" error

; ----------------------------------------------------------------------------
; OSFSC
chosfsc:jsr     select_ram_page_001             ; page in main workspace
        cmp     #$0C                            ; if call outside range 0..11
        bcs     L9774                           ; then exit
        stx     $B5                             ; else save X
        tax                                     ; transfer call number to X as index
        lda     osfsc_routines_msbs,x           ; get action address high byte
        pha                                     ; save on stack
        lda     osfsc_routines_lsbs,x           ; get action address low byte
        pha                                     ; save on stack
        txa                                     ; restore call number to A
        ldx     $B5                             ; restore X on entry
L9774:  rts                                     ; jump to action address

; ----------------------------------------------------------------------------
; OSFSC  0 = *OPT
osfsc_opt:
        jsr     push_registers_and_tuck_restoration_thunk; save AXY
        cpx     #$0A                            ; is option outside range 0..9?
        bcs     osfsc_opt_2_or_3_or_5           ; if so then raise "Bad option" error
        txa                                     ; else double option in X for use as offset
        asl     a
        tax
        lda     osfsc_opt_routines+1,x          ; get action address high byte
        pha                                     ; save it on stack
        lda     osfsc_opt_routines,x            ; get action address low byte
        pha                                     ; save it on stack
        rts                                     ; jump to action address

; ----------------------------------------------------------------------------
; Raise "Bad option" error
osfsc_opt_2_or_3_or_5:
        jsr     dobrk_with_Bad_prefix
        .byte   $CB
        .byte   "option"
; ----------------------------------------------------------------------------
        brk
; *OPT 0 = restore default FS options
; *OPT 1 = set reporting level
osfsc_opt_0_or_1:
        ldx     #$FF
        tya                                     ; is verbosity level =0?
        beq     L9799                           ; if so then set flag = &FF
        inx                                     ; else level >0, set flag = 0.
L9799:  stx     $FDD9
        rts

; ----------------------------------------------------------------------------
; *OPT 4 set boot option
osfsc_opt_4:
        tya                                     ; save requested option
        pha
        jsr     LAA1E                           ; set current vol/dir = default, set up drive
        jsr     L9632                           ; load volume catalogue
        pla                                     ; restore option
        jsr     asl_x4                          ; shift A left 4 places
        jsr     select_ram_page_003             ; page in catalogue sector 1
        eor     $FD06                           ; xor new option with old
        and     #$30                            ; clear all but option bits 5,4
        eor     $FD06                           ; b5,4 contain new option, others preserved
        sta     $FD06                           ; store new option in catalogue
        jmp     L960B                           ; write volume catalogue and exit.

; ----------------------------------------------------------------------------
; *OPT 6 = set density
osfsc_opt_6:
        lda     #$40                            ; preset A=&40 force double density
        cpy     #$12                            ; if parameter = 18
        beq     L97CA                           ; then force double density in disc ops
        asl     a                               ; else A=&80 automatic density
        cpy     #$00                            ; if parameter = 0
        beq     L97CA                           ; then detect density during FS operations
        asl     a                               ; else A=&00 force single density
        cpy     #$0A                            ; if parameter <> 10
        bne     osfsc_opt_2_or_3_or_5           ; then raise "Bad option" error, else:
L97CA:  sta     $FDED                           ; store *OPT 6 density setting
        rts

; ----------------------------------------------------------------------------
; *OPT 7 = set stepping rate
osfsc_opt_7:
        cpy     #$04                            ; if parameter outside range 0..3
        bcs     osfsc_opt_2_or_3_or_5           ; then raise "Bad option" error
        tya                                     ; else 0=slow..3=fast; reverse mapping
        eor     #$03                            ; now in internal format 0=fast..3=slow
        sta     $FDF2                           ; store mask to apply to WD 1770 commands
        rts

; ----------------------------------------------------------------------------
; *OPT 8 = set double-stepping
osfsc_opt_8:
        lda     #$40                            ; preset A=&40 force double-stepping
        iny                                     ; map &FF,0,1 to 0..2
        cpy     #$02                            ; if parameter = 1
        beq     L97E8                           ; then force double-stepping
        bcs     osfsc_opt_2_or_3_or_5           ; if not &FF, 0 or 1 then "Bad option"
        asl     a                               ; else A=&80 automatic stepping
        cpy     #$01                            ; if parameter = &FF
        bcc     L97E8                           ; then detect stepping during FS operations
        asl     a                               ; else A=&00 force 1:1 stepping:
L97E8:  sta     $FDEA                           ; store *OPT 8 tracks setting
        rts

; ----------------------------------------------------------------------------
; *OPT 9 = set save ROM slot no.
osfsc_opt_9:
        cpy     #$10                            ; if parameter not in range &0..F
        bcs     osfsc_opt_2_or_3_or_5           ; then raise "Bad option" error
        sty     $FDEE                           ; else store *OPT 9 saverom during disc ops
        rts

; ----------------------------------------------------------------------------
; Table of action addresses for *OPT commands 0..9
osfsc_opt_routines:
        .word   osfsc_opt_0_or_1-1              ; *OPT 0 = restore default FS opts &9793
        .word   osfsc_opt_0_or_1-1              ; *OPT 1 = set reporting level     &9793
        .word   osfsc_opt_2_or_3_or_5-1         ; *OPT 2 = (invalid)               &9788
        .word   osfsc_opt_2_or_3_or_5-1         ; *OPT 3 = (invalid)               &9788
        .word   osfsc_opt_4-1                   ; *OPT 4 = set boot option         &979D
        .word   osfsc_opt_2_or_3_or_5-1         ; *OPT 5 = (invalid)               &9788
        .word   osfsc_opt_6-1                   ; *OPT 6 = set density             &97BA
        .word   osfsc_opt_7-1                   ; *OPT 7 = set stepping rate       &97CE
        .word   osfsc_opt_8-1                   ; *OPT 8 = set double-stepping     &97D9
        .word   osfsc_opt_9-1                   ; *OPT 9 = set save ROM slot no.   &97EC
; ----------------------------------------------------------------------------
; OSFSC  1 = read EOF state
osfsc_eof:
        pha                                     ; save AY
        tya
        pha
        txa                                     ; transfer file handle to Y
        tay
        jsr     L9C9B                           ; ensure file handle valid and open
        tya                                     ; a=y = channel workspace pointer
        jsr     L9E9F                           ; compare PTR - EXT
        bne     L981A                           ; if PTR <> EXT then return 0
        ldx     #$FF                            ; else return &FF, we are at end of file
        bne     L981C
L981A:  ldx     #$00
L981C:  pla                                     ; restore AY and exit
        tay
        pla
        rts

; ----------------------------------------------------------------------------
; does triple duty - *RUN, */ and libfs *RUN
; OSFSC  2/4/11 = */, *RUN, *RUN from library
osfsc_run:
        jsr     set_f2_y                        ; set GSINIT pointer to XY, set Y=0
; OSFSC 3 with *command not in table
        jsr     L988F                           ; copy argument ptr and load to cat address
        sty     $FDE3                           ; store offset of start of command line
        jsr     L89E2                           ; set current file from argument pointer
        sty     $FDE2                           ; store offset of command line tail
        jsr     L8C2E                           ; search for file in catalogue
        bcs     L9855                           ; if found then execute command binary
        ldy     $FDE3
        lda     $FDC8                           ; get library directory
        sta     $CE                             ; set as current directory
        lda     $FDC9                           ; get library drive and volume
        sta     current_drive                   ; select volume in A
        jsr     L89E5                           ; parse file spec from argument pointer
        jsr     L8C2E                           ; search for file in catalogue
        bcs     L9855                           ; if found then execute it
L9849:  jsr     dobrk_with_Bad_prefix           ; else raise "Bad command" error.
        .byte   $FE
        .byte   "command"
; ----------------------------------------------------------------------------
        brk
; Execute command binary
L9855:  jsr     LA1F8                           ; load file into memory
        clc
        lda     $FDE2                           ; get offset of command line tail
        tay                                     ; and pass to command in Y (if on host)
        adc     $F2                             ; add it to GSINIT pointer in &F2,3
        sta     $FDE2                           ; giving command line tail pointer
        lda     $F3                             ; save it in &FDE2,3 for OSARGS 1
        adc     #$00
        sta     $FDE3
        lda     $FDB7                           ; and high bytes of address
        and     $FDB8                           ; a=&FF if address is in the host
        ora     $FDCD                           ; a=&FF if Tube absent (&10D6=NOT MOS flag!)
        cmp     #$FF                            ; if host address or Tube absent
        beq     L988C                           ; then jump indirect
        lda     L00C0                           ; else copy low word of exec address
        sta     $FDB5                           ; over high word of load addr in OSFILE block
        lda     $C1
        sta     $FDB6
        jsr     L96DC                           ; claim Tube
        ldx     #$B5                            ; point XY to 32-bit execution address
        ldy     #$FD
        lda     #$04                            ; tube service call &04 = *Go
        jmp     L0406                           ; jump into Tube service

; ----------------------------------------------------------------------------
; Execute command on host
L988C:  jmp     (L00C0)

; ----------------------------------------------------------------------------
; Copy argument ptr and load to cat address
L988F:  lda     #$FF                            ; lsb exec address in our OSFILE block = &FF:
        sta     L00C0                           ; load executable to load address in catalogue
        lda     $F2                             ; copy GSINIT string pointer to zero page
        sta     $BC                             ; = command line pointer
        lda     $F3
        sta     $BD
        rts

; ----------------------------------------------------------------------------
; OSFSC  3 = unrecognised *command
osfsc_star:
        jsr     set_f2_y                        ; set GSINIT pointer to XY, set Y=0
        ldx     #$B4                            ; point XY to command table at &90B4
        ldy     #$90
        lda     #$00                            ; command starts at XY with zero offset
        jsr     L91A8                           ; search for command or keyword in table
        tsx
        stx     $B8                             ; save stack pointer to restore on abort
        jmp     L80D7                           ; execute command

; ----------------------------------------------------------------------------
; OSFSC  5 = *CAT
osfsc_cat:
        jsr     set_f2_y                        ; set GSINIT pointer to XY, set Y=0
        jsr     gsinit_with_carry_clear         ; call GSINIT with C=0
        jsr     LAA72                           ; select specified or default volume
        txa                                     ; test b7 of detected specification type
        bpl     L98F3                           ; if b7=0 then spec specific, *CAT single vol
        lda     #$80                            ; else data transfer call &80 = read to JIM
        sta     $FDE9
        jsr     LABB5                           ; detect disc format/set sector address
        bit     $FDED                           ; test density flag
        bvc     L98F3                           ; if double density then *CAT eight volumes:
        jsr     L8F0B                           ; print disc type and volume list
        ldx     #$00                            ; for each volume letter A..H:
L98CC:  jsr     select_ram_page_000             ; page in auxiliary workspace
        lda     $FDCD,x                         ; test if number of tracks in volume > 0
        beq     L98E4                           ; if = 0 then no such volume, skip
        txa                                     ; save volume counter
        pha
        jsr     L961F                           ; ensure current volume catalogue loaded
        jsr     print_disc_title_and_cycle_number; print volume title
        jsr     L8F88                           ; print volume spec and boot option
        jsr     L8DCA                           ; list files in catalogue
        pla                                     ; restore volume counter
        tax
L98E4:  clc
        lda     current_drive                   ; get current volume
        adc     #$10                            ; select next volume letter
        sta     current_drive                   ; set as current volume
        inx                                     ; increment counter
        cpx     #$08                            ; have 8 volumes A..H been listed?
        bne     L98CC                           ; if not then loop
        jmp     select_ram_page_001             ; else page in main workspace and exit

; ----------------------------------------------------------------------------
; *CAT single volume
L98F3:  jsr     L961F                           ; ensure current volume catalogue loaded
        jsr     print_disc_title_and_cycle_number; print volume title
        jsr     L8F0B                           ; print disc type and volume list
        jsr     L8F88                           ; print volume spec and boot option
        jsr     L8FB8                           ; print CSD and library directories
        jmp     L8DCA                           ; list files in catalogue

; ----------------------------------------------------------------------------
; OSFSC  6 = new filing system starting up
osfsc_shut_down_fs:
        jsr     L990F                           ; close *SPOOL/*EXEC files
        asl     $FD00                           ; clear b7=0 Challenger not current FS
        lsr     $FD00
        rts

; ----------------------------------------------------------------------------
L990F:  jsr     push_registers_and_tuck_restoration_thunk; save AXY
        lda     #$77                            ; call OSBYTE &77 = close *SPOOL/*EXEC files
        jmp     osbyte

; ----------------------------------------------------------------------------
; OSFSC  7 = range of valid file handles
osfsc_get_handle_range:
        ldx     #$11
        ldy     #$15
        rts

; ----------------------------------------------------------------------------
; OSFSC  8 = *command has been entered
osfsc_oscli:
        bit     $FDDF                           ; if *ENABLEd flag b7=0 (i.e. byte = 0 or 1)
        bmi     L9924
        dec     $FDDF                           ; then enable this command, not the ones after
L9924:  jmp     L9753                           ; forget catalogue in JIM pages 2..3

; ----------------------------------------------------------------------------
; Ensure open file still in drive
L9927:  jsr     LAB9A                           ; set current vol/dir from open filename
; Ensure open file still on current volume
L992A:  jsr     select_ram_page_001
        ldx     #$07                            ; start at seventh character of leaf name:
L992F:  lda     $FCED,y                         ; copy leaf name of file to current leaf name
        sta     $C6,x
        dey                                     ; skip odd bytes containing length and addrs
        dey                                     ; select previous character of leaf name (Y>0)
        dex                                     ; decrement offset in current leaf name
        bne     L992F                           ; loop until 7 characters copied (X=7..1)
        jsr     L8C2E                           ; search for file in catalogue
        bcc     L995E                           ; if file not found then raise "Disk changed"
        sty     $FDD2                           ; else save offset in catalogue
        jsr     select_ram_page_003             ; page in catalogue sector 1
        lda     $FD0E,y                         ; get top bits exec/length/load/start sector
        ldx     $FD0F,y                         ; put LSB start sector in X
        jsr     select_ram_page_001             ; page in main workspace
        ldy     $FDD0                           ; put channel workspace pointer in Y
        eor     $FCEE,y                         ; compare start sector with one in workspace
        and     #$03                            ; mask off other fields
        bne     L995E                           ; if not equal then raise "Disk changed" error
        txa                                     ; else compare low bytes of start sector (LBA)
        cmp     $FCF0,y
        bne     L995E                           ; if not equal then raise "Disk changed" error
        rts                                     ; else exit

; ----------------------------------------------------------------------------
L995E:  jmp     L8A92                           ; raise "Disk changed" error

; ----------------------------------------------------------------------------
; OSFIND
chosfind:
        cmp     #$00
        bne     L99D9                           ; if A>0 then open a file
        jsr     push_registers_and_tuck_restoration_thunk; else close a file/all files. save AXY
L9968:  tya                                     ; if handle = 0
        beq     L9974                           ; then close all files
        pha                                     ; save handle
        jsr     L9CAF                           ; else convert to pointer
        tay
        pla                                     ; restore handle
        jmp     L9988                           ; then close file

; ----------------------------------------------------------------------------
; Close all files
L9974:  jsr     L990F                           ; close *SPOOL/*EXEC files
L9977:  ldy     #$04                            ; 5 file handles to close:
L9979:  tya                                     ; save counter
        pha
        lda     L9C91,y                         ; y=0..4. get workspace pointer from table
        tay
        jsr     L9988                           ; close file L7
        pla                                     ; restore counter
        tay
        dey                                     ; loop until all files closed.
        bpl     L9979
        rts

; ----------------------------------------------------------------------------
; Close file L7
L9988:  jsr     select_ram_page_001             ; page in main workspace
        pha
        jsr     L9C74                           ; validate workspace offset
        bcs     L99D7                           ; if channel invalid or closed then exit
        lda     fdc_control,y                   ; else get bit mask corresponding to channel
        eor     #$FF                            ; invert it, bit corresponding to channel =0
        and     $FDCE                           ; clear bit of channel open flag byte
        sta     $FDCE                           ; update flag byte
        lda     fdc_status_or_cmd,y             ; get channel flags
        and     #$60                            ; if either buffer or EXT changed
        beq     L99D7
        jsr     L9927                           ; then ensure open file still in drive
        lda     fdc_status_or_cmd,y             ; if EXT changed
        and     #$20
        beq     L99D4
        ldx     $FDD2                           ; then set X = catalogue pointer
        lda     $FCF5,y                         ; copy low word of EXT to length in catalogue
        jsr     select_ram_page_003             ; page in catalogue sector 1
        sta     $FD0C,x
        jsr     select_ram_page_001             ; page in main workspace
        lda     $FCF6,y
        jsr     select_ram_page_003             ; page in catalogue sector 1
        sta     $FD0D,x
        jsr     select_ram_page_001             ; page in main workspace
        lda     $FCF7,y                         ; get high byte of EXT
        jsr     L92EC                           ; pack b17,16 of length into catalogue entry
        jsr     L960B                           ; write volume catalogue
        ldy     $FDD0                           ; put channel workspace pointer in Y
L99D4:  jsr     L9D42                           ; ensure buffer up-to-date on disc L6
L99D7:  pla                                     ; restore A on entry
        rts

; ----------------------------------------------------------------------------
; Open a file
L99D9:  jsr     LA875                           ; save XY
        stx     $BC
        sty     $BD
        sta     $B4                             ; store file open mode in temporary var.
        bit     $B4                             ; set N and V from temporary variable
        php
        jsr     L89E2                           ; set current file from argument pointer
        jsr     L9AF7                           ; find unused file handle
        bcc     L9A05                           ; if all file handles in use
        jsr     print_string_2_nterm            ; then raise "Too many files open" error.
        .byte   $C0
        .byte   "Too many files open"


; ----------------------------------------------------------------------------
        brk
L9A05:  ldx     #$C7                            ; point XY+A to current filename
        lda     #$00
        tay
        jsr     L9B10                           ; compare filename at XY+A with open filenames
        bcc     L9A29                           ; if file not open then continue
L9A0F:  jsr     select_ram_page_001             ; page in main workspace
        lda     $FCED,y                         ; else test if the channel is open read-write
        bpl     L9A1B                           ; if so, reopening is a conflict; raise error
        plp                                     ; else if reopening a r-o channel read-only
        php                                     ; (i.e. channel b7=1, OSFIND call no. b7=0)
        bpl     L9A24                           ; then this is also safe; continue
L9A1B:  jsr     dobrk_with_File_prefix          ; else reopening a r-o channel r-w is conflict
        .byte   $C2                             ; raise "File open" error.
        .byte   "open"
; ----------------------------------------------------------------------------
        brk
L9A24:  jsr     L9B2A                           ; find any other channels open on this file
        bcs     L9A0F                           ; if another channel found then loop
L9A29:  jsr     L8B32                           ; disallow wildcard characters in filename
        jsr     L8C2E                           ; search for file in catalogue
        bcs     L9A4E                           ; if not found
        lda     #$00                            ; then preset A=0, no file handle to return
        plp                                     ; if opening for read or update
        bvc     L9A37                           ; (i.e. OSFIND call no. b6=1)
        rts                                     ; then existing file was expected, return A=0

; ----------------------------------------------------------------------------
L9A37:  php
        jsr     select_ram_page_001             ; page in main workspace
        ldx     #$07                            ; else opening new file for output.
L9A3D:  sta     $BE,x                           ; clear load, exec, start and length = 0
        sta     $FDB5,x
        dex
        bpl     L9A3D
        lda     #$40                            ; initial length = &4000 = 16 KiB
        sta     $C5
        sta     L00A8                           ; b6=1 will accept shorter allocation
        jsr     L93B3                           ; create file from OSFILE block
L9A4E:  tya                                     ; transfer catalogue pointer to X
        tax
        plp
        php
        bvs     L9A57                           ; if opening for output (OSFIND b6=0)
        jsr     LA295                           ; then ensure file not locked
L9A57:  jsr     select_ram_page_001             ; page in main workspace
        lda     #$08                            ; set counter = 8
        sta     $FDD3
        ldy     $FDD0                           ; put channel workspace pointer in Y
L9A62:  jsr     select_ram_page_002             ; page in catalogue sector 0
        lda     $FD08,x                         ; copy name and attributes of file
        jsr     select_ram_page_001             ; page in main workspace
        sta     $FCE1,y                         ; to bottom half of channel workspace
        iny
        jsr     select_ram_page_003             ; page in catalogue sector 1
        lda     $FD08,x
        jsr     select_ram_page_001             ; page in main workspace
        sta     $FCE1,y
        iny
        inx
        dec     $FDD3                           ; loop until 8 byte pairs copied
        bne     L9A62
        ldx     #$10
        lda     #$00
L9A86:  sta     $FCE1,y                         ; clear top half of channel workspace
        iny
        dex
        bne     L9A86
        ldy     $FDD0                           ; put channel workspace pointer in Y
        lda     $FDCF                           ; get bit mask corresponding to channel
        sta     fdc_control,y                   ; store in channel workspace
        ora     $FDCE                           ; set that bit in channel open flags byte
        sta     $FDCE                           ; marking this channel open
        lda     $FCEA,y                         ; test LSB of file length
        cmp     #$01                            ; set C=1 iff partial sector
        lda     $FCEC,y                         ; copy 2MSB length to allocation
        adc     #$00                            ; rounding up to whole sector
        sta     fdc_sector,y
        lda     $FCEE,y                         ; get top bits exec/length/load/start sector
        ora     #$0F                            ; mask off load/start sector
        adc     #$00                            ; carry out to length in bits 5 and 4
        jsr     extract_00xx0000                ; extract b5,b4 of A
        sta     fdc_data,y                      ; store MSB allocation
        plp                                     ; restore OSFILE call number to N and V
        bvc     L9AF0                           ; if opening for output then branch
        bmi     L9AC3                           ; if opening for update then branch
        lda     #$80                            ; else opening for input.
        ora     $FCED,y                         ; set b7=1 of seventh char of leaf name
        sta     $FCED,y                         ; marking channel read-only.
L9AC3:  lda     $FCEA,y                         ; input or update; set EXT = length of file
        sta     $FCF5,y
        lda     $FCEC,y
        sta     $FCF6,y
        lda     $FCEE,y
        jsr     extract_00xx0000                ; extract b5,b4 of A
        sta     $FCF7,y
L9AD8:  lda     current_drive                   ; get current volume
        sta     $FD00,y                         ; set as volume of open file
        jsr     L853F                           ; pack drive parameters
        sta     $FCF4,y                         ; store in place of buffer page number
        lda     $FDEC                           ; get first track of current volume
        sta     ram_paging_lsb,y                ; store in spare byte of channel workspace
        tya                                     ; transfer channel workspace pointer to A
        jsr     lsr_x5                          ; shift A right 5 places
        adc     #$10                            ; c=0; add &10 to return file handle &11..15
        rts

; ----------------------------------------------------------------------------
; opening for output
L9AF0:  lda     #$20                            ; set channel flag b5=1, "EXT changed"
        sta     fdc_status_or_cmd,y             ; to truncate file's initial allocation
        bne     L9AD8                           ; branch to return file handle (always)
; Find unused file handle
L9AF7:  lda     $FDCE                           ; get channel open flags
        ldx     #$FB                            ; test up to 5 channel bits:
L9AFC:  asl     a                               ; shift next channel open flag into carry
        bcc     L9B03                           ; if C=0 channel unused, calculate ptr+mask
        inx                                     ; else loop until 5 channels tested
        bmi     L9AFC
        rts                                     ; if C=1 all channels in use, none free

; ----------------------------------------------------------------------------
; Calculate workspace pointer and bit mask
L9B03:  lda     L9B96,x                         ; get workspace pointer from &9C91..5
        sta     $FDD0                           ; return in workspace pointer variable
        lda     L9B9B,x                         ; get channel open bit mask from &9C96..A
        sta     $FDCF                           ; return in bit mask variable.
        rts

; ----------------------------------------------------------------------------
; Compare filename at XY+A with open filenames
L9B10:  stx     $B0                             ; save XY as filename pointer
        sty     $B1
        sta     $B2                             ; save A as offset
        jsr     select_ram_page_001             ; page in main workspace
        lda     $FDCE                           ; get channel open flags
        and     #$F8                            ; extract flags for channels &11..15
        sta     $B5                             ; save as shift register
        ldx     #$20                            ; start at channel workspace offset &20:
L9B22:  stx     $B4
        asl     $B5                             ; shift next channel open flag into carry
        bcs     L9B34                           ; if C=1 channel open then compare names
        beq     L9B32                           ; if no more channels open exit C=0, else:
; no match
L9B2A:  lda     $B4                             ; add &20 to channel workspace pointer
        clc
        adc     #$20
        tax
        bcc     L9B22                           ; and loop to test next channel (always)
L9B32:  clc
        rts

; ----------------------------------------------------------------------------
L9B34:  lda     $FD00,x                         ; get volume of open file
        jsr     get_physical_drive              ; map volume in A to physical volume
        sta     $B3                             ; store in temporary variable
        jsr     get_current_physical_drive      ; map current volume to physical volume
        eor     $B3                             ; compare with volume of open file
        bne     L9B2A                           ; if unequal then no match
        lda     #$08                            ; else set counter = 8
        sta     $B3
        ldy     $B2                             ; put offset in Y:
L9B49:  jsr     select_ram_page_002             ; page in catalogue sector 0
        lda     ($B0),y                         ; get character of filename to compare
        jsr     select_ram_page_001             ; page in main workspace
        eor     $FCE1,x                         ; compare with char of open filename
        and     #$7F                            ; ignore bit 7
        bne     L9B2A                           ; if unequal then no match
        iny                                     ; skip to next character of comparand
        inx                                     ; skip even addresses cont'g file attributes
        inx                                     ; skip to next character of open filename
        dec     $B3                             ; decrement counter
        bne     L9B49                           ; loop until 7 leaf name chars + dir tested
        ldy     $B4                             ; then restore channel workspace offset to Y
        rts                                     ; return C=1 matching filename found.

; ----------------------------------------------------------------------------
; OSARGS
chosargs:
        jsr     select_ram_page_001             ; page in main workspace
        cpy     #$00                            ; file handle in Y; if Y = 0
        beq     L9B7A                           ; then perform Y = 0 functions
        jsr     push_registers_and_tuck_restoration_thunk; else save AXY
        cmp     #$FF                            ; if A=&FF
        beq     L9BAC                           ; then ensure file up-to-date on disc
        cmp     #$03                            ; else if A>=3
        bcs     L9B8B                           ; then return
        lsr     a                               ; else place bit 0 of A in carry flag
        bcc     L9BB8                           ; if A=0 or A=2 then return PTR or EXT
        jmp     L9BD8                           ; else A=1 set PTR

; ----------------------------------------------------------------------------
; OSARGS Y=0
L9B7A:  jsr     LA875                           ; save XY
        tay                                     ; A=call number, transfer to Y
        iny                                     ; convert &FF,0,1 to 0..2
        cpy     #$03                            ; if call number was &02..&FE
        bcs     L9B8B                           ; then return
        lda     osargs_y0_routines_msbs,y       ; else get action address high byte
        pha                                     ; save on stack
        lda     osargs_y0_routines_lsbs,y       ; get action address low byte
        pha                                     ; save on stack
L9B8B:  rts                                     ; jump to action address.

; ----------------------------------------------------------------------------
; OSARGS A=0, Y=0 return filing system number
osargs_get_fs_type:
        lda     #$04                            ; a=4 for Disc Filing System
        rts

; ----------------------------------------------------------------------------
; OSARGS A=1, Y=0 read command line tail
osargs_get_command_line_tail:
        lda     #$FF                            ; command line is always in I/O processor
        sta     $02,x                           ; so return a host address, &FFFFxxxx
        sta     $03,x
        .byte   $AD                             ; copy address of command line arguments
L9B96:  .byte   $E2
        sbc     a:$95,x
        .byte   $AD                             ; to user's OSARGS block
L9B9B:  .byte   $E3
        sbc     $0195,x
        lda     #$00                            ; return A=0
        rts

; ----------------------------------------------------------------------------
; OSARGS A=&FF, Y=0
osargs_update_all_files:
        lda     $FDCE                           ; Ensure all files up-to-date on disc (flush)
        pha                                     ; save channel open flags
        jsr     L9977                           ; close all files (returns N=1)
        jmp     L9BB3                           ; branch (always)

; ----------------------------------------------------------------------------
; OSARGS A=&FF, Y>0 ensure file up-to-date
L9BAC:  lda     $FDCE                           ; Ensure file up-to-date on disc (flush)
        pha                                     ; save channel open flags
        jsr     L9968                           ; close a file/all files
L9BB3:  pla                                     ; restore channel open flags.
        sta     $FDCE
        rts

; ----------------------------------------------------------------------------
; OSARGS A=0/2, Y>0 return PTR/EXT
L9BB8:  jsr     push_registers_and_tuck_restoration_thunk; save AXY
        jsr     L9C9B                           ; ensure file handle valid and open
        asl     a                               ; A=0 or 1, multiply by 4
        asl     a                               ; A=0 offset of PTR, A=4 offset of EXT
        adc     $FDD0                           ; add offset to channel workspace pointer
        tay                                     ; transfer to Y as index
        lda     $FCF1,y                         ; copy PTR or EXT
        sta     $00,x                           ; to 3 LSBs of user's OSARGS block
        lda     $FCF2,y
        sta     $01,x
        lda     $FCF3,y
        sta     $02,x
        lda     #$00                            ; clear MSB of user's OSARGS block
        sta     $03,x                           ; PTR <= EXT < 16 MiB
        rts

; ----------------------------------------------------------------------------
; OSARGS A=1, Y>0 set PTR
L9BD8:  jsr     push_registers_and_tuck_restoration_thunk; save AXY
        jsr     L9C9B                           ; ensure file handle valid and open
        sec
        lda     $FCFD,y                         ; get LSB sector address of buffer
        sbc     $FCF0,y                         ; subtract LSB start sector of file
        sta     $B0                             ; =offset of buffer from start of file
        lda     ram_paging_msb,y                ; get MSB sector address of buffer
        sbc     $FCEE,y                         ; subtract MSB start sector of file
        and     #$03                            ; b7..5 of latter = other top bits, mask off
        cmp     $02,x                           ; compare b1..0 with 2MSB requested PTR
        bne     L9BF9                           ; if equal
        lda     $B0                             ; then compare LSB buffer offset with request
        cmp     $01,x
        beq     L9C04                           ; if requested PTR not within current buffer
L9BF9:  jsr     LAB9A                           ; then set current vol/dir from open filename
        jsr     L9D3F                           ; ensure buffer up-to-date on disc L6
        lda     #$6F                            ; b7=0 PTR not in buffer, b4=0 EOF warning clr
        jsr     L9D37                           ; clear channel flag bits
L9C04:  jsr     L9EB7                           ; compare EXT - requested PTR
        bcs     L9C64                           ; if EXT >= request then just set PTR
        lda     $01,x                           ; else compare 3MSB request - 2MSB EXT
        cmp     $FCF6,y
        bne     L9C17                           ; if unequal then extend file
        lda     $02,x                           ; else compare 2MSB request - MSB EXT
        cmp     $FCF7,y
        beq     L9C48                           ; if equal then within allocation, set PTR,EXT
L9C17:  clc
        lda     $00,x                           ; get LSB requested PTR
        adc     #$FF                            ; c=1 iff LSB >0
        lda     $01,x                           ; add C to 3MSB request, rounding up
        adc     #$00
        sta     $C4                             ; store LSB requested length in sectors
        lda     $02,x                           ; carry out to 2MSB request
        adc     #$00
        sta     $C5                             ; store MSB requested length in sectors
        txa                                     ; save OSARGS pointer
        pha
        jsr     L992A                           ; ensure open file still on current volume
        jsr     L9E6E                           ; calculate maximum available allocation
        sec
        lda     $C4                             ; get LSB requested length in sectors
        sbc     L00C0                           ; subtract LSB maximum available allocation
        sta     $C2                             ; save LSB excess
        lda     $C5                             ; get MSB requested length in sectors
        sbc     $C1                             ; subtract MSB maximum available allocation
        sta     $C3                             ; save MSB excess, C=0 if negative (headroom)
        bcc     L9C46                           ; if allocation > request then set PTR
        ora     $C2                             ; else test excess
        beq     L9C46                           ; if allocation = request then set PTR
        jsr     L9EC7                           ; else move files
L9C46:  pla                                     ; restore OSARGS pointer
        tax
L9C48:  lda     $FCF5,y                         ; set PTR = EXT
        sta     $FCF1,y
        lda     $FCF6,y
        sta     $FCF2,y
        lda     $FCF7,y
        sta     $FCF3,y
L9C5A:  lda     #$00                            ; a = &00 filler byte
        jsr     L9D98                           ; write byte to end of file
        jsr     L9EB7                           ; compare EXT - request
        bcc     L9C5A                           ; loop until last byte is just before new PTR
L9C64:  lda     $00,x                           ; copy requested PTR in user's OSARGS block
        sta     $FCF1,y                         ; to channel pointer
        lda     $01,x
        sta     $FCF2,y
        lda     $02,x
        sta     $FCF3,y
        rts

; ----------------------------------------------------------------------------
; Validate workspace offset
L9C74:  pha                                     ; save A
        tya                                     ; transfer workspace offset to A
        and     #$E0                            ; mask bits 7..5, offset = 0..7 * &20
        sta     $FDD0                           ; save channel workspace pointer
        beq     L9C8E                           ; if offset = 0 (i.e. channel &10) return C=1
        lsr     a                               ; else shift right five times, divide by 32
        lsr     a                               ; to produce an offset 1..7
        lsr     a                               ; corresponding to channels &11..17
        lsr     a
        lsr     a
        tay                                     ; transfer to Y for use as index
        lda     L9C95,y                         ; get channel open bit mask from table
        ldy     $FDD0                           ; put channel workspace pointer in Y
        bit     $FDCE                           ; if channel's open bit in flag byte = 0
        bne     L9C8F
L9C8E:  sec                                     ; then return C=1
L9C8F:  pla                                     ; else return C=0
        rts

; ----------------------------------------------------------------------------
; Table of channel workspace pointers for file handles &11..15
L9C91:  .byte   $20,$40,$60,$80
L9C95:  .byte   $A0
; Table of channel open bit masks for file handles &11..15
L9C96:  .byte   $80,$40
; ----------------------------------------------------------------------------
        jsr     L0810
; Ensure file handle valid and open
L9C9B:  pha                                     ; save A on entry, Y = file handle
        jsr     L9CAF                           ; convert file handle to workspace pointer
        sta     $FDD0                           ; save in temporary location
        lda     L9C96,y                         ; get channel open bit mask from table
        ldy     $FDD0                           ; put channel workspace pointer in Y
        bit     $FDCE                           ; if channel's open bit in flag byte = 0
        beq     L9CBD                           ; then raise "Channel" error
        pla                                     ; else restore A
        rts

; ----------------------------------------------------------------------------
; Convert file handle to workspace pointer
L9CAF:  tya
        cmp     #$16                            ; if file handle is &16 or more
        bcs     L9CBD                           ; then raise "Channel" error
        sbc     #$10                            ; else C=0; if file handle less than &11
        bcc     L9CBD                           ; then raise "Channel" error, else:
        tay
        lda     L9C91,y                         ; y=0..4. get workspace pointer from table
        rts

; ----------------------------------------------------------------------------
; Raise "Channel" error
L9CBD:  jsr     print_string_2_nterm
        .byte   $DE
        .byte   "Channel"
; ----------------------------------------------------------------------------
        brk
; Raise "EOF" error
L9CC9:  jsr     print_string_2_nterm
        .byte   $DF
        .byte   "EOF"
; ----------------------------------------------------------------------------
        brk
; OSBGET
chosbget:
        jsr     select_ram_page_001             ; page in main workspace
        stx     $FDC4
        sty     $FDC5
        jsr     L9C9B                           ; ensure file handle valid and open
        tya
        jsr     L9E9F                           ; compare PTR - EXT
        bne     L9CF4                           ; if at EOF
        lda     fdc_status_or_cmd,y             ; then test EOF warning flag b4
        and     #$10
        bne     L9CC9                           ; if set then raise "EOF" error
        lda     #$10                            ; else set EOF warning flag b4=1
        jsr     L9D30                           ; set channel flag bits (A = OR mask)
        lda     #$FE                            ; return A=&FE, "file end"
        sec                                     ; return C=1 indicating end-of-file
        bcs     L9D0C                           ; restore XY and exit
L9CF4:  lda     fdc_status_or_cmd,y             ; not at EOF. get channel flags
        bmi     L9D03                           ; if PTR not within current buffer
        jsr     LAB9A                           ; then set current vol/dir from open filename
        jsr     L9D42                           ; ensure buffer up-to-date on disc L6
        sec                                     ; c=1 read buffer from disc
        jsr     L9D4A                           ; read/write sector buffer L6 (returns C=0)
L9D03:  jsr     L9E59                           ; increment PTR and page in channel buffer
        lda     $FD00,x                         ; get byte from channel buffer at old PTR
        jsr     select_ram_page_001             ; page in main workspace
L9D0C:  ldx     $FDC4                           ; restore X and Y on entry
        ldy     $FDC5
        pha                                     ; set N and Z according to A
        pla
        rts                                     ; exit

; ----------------------------------------------------------------------------
; Set buffer sector address from PTR
L9D15:  clc
        lda     $FCF0,y                         ; get LSB start sector of open file
        adc     $FCF2,y                         ; add 2MSB of PTR
        sta     $C5                             ; store LSB sector address
        sta     $FCFD,y                         ; store LSB sector address of buffer
        lda     $FCEE,y                         ; get top bits exec/length/load/start sector
        and     #$03                            ; extract MSB start sector
        adc     $FCF3,y                         ; add MSB of PTR
        sta     $C4                             ; store MSB sector address
        sta     ram_paging_msb,y                ; store MSB sector address of buffer
        lda     #$80                            ; b7=1 buffer contains byte at PTR:
; Set channel flag bits (A = OR mask)
L9D30:  ora     fdc_status_or_cmd,y
        bne     L9D3A                           ; store if >0 else fall through harmlessly:
; Clear buffer-contains-PTR channel flag:
L9D35:  lda     #$7F
; Clear channel flag bits (A = AND mask)
L9D37:  and     fdc_status_or_cmd,y
L9D3A:  sta     fdc_status_or_cmd,y
        clc
        rts

; ----------------------------------------------------------------------------
L9D3F:  jsr     push_registers_and_tuck_restoration_thunk; save AXY
; Ensure buffer up-to-date on disc L6
L9D42:  lda     fdc_status_or_cmd,y             ; test b6 of channel flag
        and     #$40
        beq     L9D86                           ; if buffer not changed then return
        clc                                     ; c=0 write buffer to disc:
; Read/write sector buffer L6
L9D4A:  php
        jsr     select_ram_page_001             ; get channel workspace pointer
        ldy     $FDD0                           ; put channel workspace pointer in Y
        tya                                     ; and A
        lsr     a                               ; shift A right 5 places
        lsr     a
        lsr     a
        lsr     a
        lsr     a
        adc     #$03                            ; c=0; A=4..8 for handles &11..15
        sta     $BE                             ; set LSB address of buffer in JIM space
        lda     #$00
        sta     $BF                             ; clear MSB buffer address
        sta     $C2
        lda     #$01                            ; 256 bytes to transfer
        sta     $C3
        plp
        bcs     L9D7D                           ; if C was 0 on entry then read buffer
        lda     $FCFD,y                         ; else copy channel's sector buffer address
        sta     $C5                             ; to &C5,4 (big-endian)
        lda     ram_paging_msb,y
        sta     $C4
        jsr     L9721                           ; write ordinary file from JIM L5
        ldy     $FDD0                           ; put channel workspace pointer in Y
        lda     #$BF                            ; b6=0 buffer not changed
        jmp     L9D37                           ; clear channel flag bits and exit

; ----------------------------------------------------------------------------
; Read channel buffer from disc L6
L9D7D:  jsr     L9D15                           ; set buffer sector address from PTR
        jsr     L9724                           ; read ordinary file to JIM L5
        ldy     $FDD0                           ; put channel workspace pointer in Y
L9D86:  rts

; ----------------------------------------------------------------------------
L9D87:  jmp     LA29D                           ; raise "File locked" error.

; ----------------------------------------------------------------------------
; Raise "File read only" error.
L9D8A:  jsr     dobrk_with_File_prefix
        .byte   $C1
        .byte   "read only"

; ----------------------------------------------------------------------------
        brk
L9D98:  jsr     push_registers_and_tuck_restoration_thunk; save AXY
        jmp     L9DAD

; ----------------------------------------------------------------------------
; OSBPUT
chosbput:
        jsr     select_ram_page_001             ; page in main workspace
        sta     $FDC3                           ; save AXY on entry
        stx     $FDC4
        sty     $FDC5
        jsr     L9C9B                           ; ensure file handle valid and open
L9DAD:  pha                                     ; save byte to write
        lda     $FCED,y                         ; test channel read-only bit
        bmi     L9D8A                           ; if b7=1 then raise "File read only" error
        lda     $FCEF,y                         ; else test file locked bit
        bmi     L9D87                           ; if b7=1 then raise "File locked" error
        jsr     LAB9A                           ; else set current vol/dir from open filename
        tya                                     ; a=y = channel workspace pointer
        clc                                     ; add 4 to point A to allocated length not EXT
        adc     #$04
        jsr     L9E9F                           ; compare PTR - allocated length
        bne     L9E07                           ; if within allocation then write
        jsr     L992A                           ; else ensure open file still on current volume
L9DC7:  jsr     L9E6E                           ; calculate maximum available allocation
        lda     $C1                             ; get MSB maximum available allocation
        cmp     fdc_data,y                      ; compare MSB length of file per workspace
        bne     L9DE5                           ; if not equal then extend file
        lda     L00C0                           ; else restore LSB maximum available allocation
        cmp     fdc_sector,y                    ; compare 2MSB length of file per workspace
        bne     L9DF3                           ; if not equal then extend file
        lda     #$01                            ; else excess = 1 sector
        sta     $C2
        lda     #$00
        sta     $C3
        jsr     L9EC7                           ; move files (to yield one sector)
        bcc     L9DC7                           ; and try again
L9DE5:  clc
        lda     fdc_data,y                      ; increment MSB of file length in workspace
        adc     #$01                            ; strictly increasing length to n*64 KiB
        sta     fdc_data,y
        jsr     L92EC                           ; pack b17,16 of length into catalogue entry
        lda     #$00                            ; set 2MSB file length to 0:
L9DF3:  sta     fdc_sector,y                    ; store 2MSB file length in workspace
        jsr     select_ram_page_003             ; page in catalogue sector 1
        sta     $FD0D,x                         ; store 2MSB file length in catalogue
        lda     #$00
        sta     $FD0C,x                         ; clear LSB file length in catalogue
        jsr     L960B                           ; write volume catalogue
        ldy     $FDD0                           ; put channel workspace pointer in Y
; write byte to file
L9E07:  lda     fdc_status_or_cmd,y             ; test channel flags
        bmi     L9E23                           ; if b7=1 buffer-contains-PTR then write byte
        jsr     L9D42                           ; else ensure buffer up-to-date on disc L6
        lda     $FCF5,y                         ; does EXT equal a whole number of sectors?
        bne     L9E1F                           ; if not then read buffer from disc
        tya                                     ; else a=y = channel workspace pointer
        jsr     L9E9F                           ; compare PTR - EXT
        bne     L9E1F                           ; if not at EOF then read buffer from disc
        jsr     L9D15                           ; else set buffer sector address from PTR
        bne     L9E23                           ; branch (always)
L9E1F:  sec                                     ; c=1 write buffer to disc
        jsr     L9D4A                           ; read/write sector buffer L6
L9E23:  jsr     L9E59                           ; increment PTR and page in channel buffer
        pla                                     ; restore byte to write
        sta     $FD00,x                         ; put byte in channel buffer at old PTR
        jsr     select_ram_page_001             ; page in main workspace
        lda     #$40                            ; b6=1, buffer has changed
        jsr     L9D30                           ; set channel flag bits (A = OR mask)
        tya                                     ; a=y = channel workspace pointer
        jsr     L9E9F                           ; compare PTR - EXT
        bcc     L9E4F                           ; if at EOF (i.e. pointer >= EXT)
        lda     #$20                            ; then b5=1, EXT has changed
        jsr     L9D30                           ; set channel flag bits (A = OR mask)
        lda     $FCF1,y                         ; copy EXT = PTR
        sta     $FCF5,y
        lda     $FCF2,y
        sta     $FCF6,y
        lda     $FCF3,y
        sta     $FCF7,y
L9E4F:  lda     $FDC3                           ; restore AXY on entry
        ldx     $FDC4
        ldy     $FDC5
        rts                                     ; exit

; ----------------------------------------------------------------------------
; Increment PTR and page in channel buffer
L9E59:  lda     $FCF1,y                         ; get current LSB of PTR to return
        pha
        jsr     L9E8D                           ; increment PTR
        tya                                     ; transfer workspace pointer to A
        lsr     a                               ; shift A right 5 places
        lsr     a
        lsr     a
        lsr     a
        lsr     a
        adc     #$03                            ; c=0; A=4..8 for handles &11..15
        jsr     LBE1D                           ; page in JIM page in A
        pla
        tax                                     ; return old LSB of PTR in X as buffer offset
        rts

; ----------------------------------------------------------------------------
; Calculate maximum available allocation
L9E6E:  jsr     select_ram_page_001             ; page in main workspace
        ldx     $FDD2                           ; get offset of file in catalogue
        jsr     select_ram_page_003             ; page in catalogue sector 1
        sec
        lda     $FD07,x                         ; get LSB start LBA of previous file in cat
        sbc     $FD0F,x                         ; subtract LSB start LBA of open file
        sta     L00C0                           ; save LSB maximum available allocation
        lda     $FD06,x                         ; get MSB start LBA of previous file in cat
        sbc     $FD0E,x                         ; subtract MSB start LBA of open file
        and     #$03                            ; extract b1,b0
        sta     $C1                             ; store MSB maximum available allocation
        jmp     select_ram_page_001             ; page in main workspace

; ----------------------------------------------------------------------------
; Increment PTR
L9E8D:  tya                                     ; transfer channel workspace pointer to X
        tax
        inc     $FCF1,x                         ; increment LSB of PTR
        bne     L9EB6                           ; if within same sector then return
        inc     $FCF2,x                         ; else sector boundary crossed.
        bne     L9E9C                           ; carry out to high bytes of PTR
        inc     $FCF3,x
L9E9C:  jmp     L9D35                           ; and clear buffer-contains-PTR channel flag.

; ----------------------------------------------------------------------------
; Compare PTR - EXT (A=Y), - allocation (A=Y+4)
L9E9F:  tax                                     ; return C=1 iff at/past EOF or allocation
        lda     $FCF3,y                         ; return Z=1 iff at EOF or equal to allocation
        cmp     $FCF7,x
        bne     L9EB6
        lda     $FCF2,y
        cmp     $FCF6,x
        bne     L9EB6
        lda     $FCF1,y
        cmp     $FCF5,x
L9EB6:  rts

; ----------------------------------------------------------------------------
; Compare EXT - OSARGS parameter
L9EB7:  lda     $FCF5,y                         ; return C=1 iff EXT >= parameter
        cmp     $00,x
        lda     $FCF6,y
        sbc     $01,x
        lda     $FCF7,y
        sbc     $02,x
        rts

; ----------------------------------------------------------------------------
; Move files
L9EC7:  jsr     push_registers_and_tuck_restoration_thunk; save AXY
        stx     $A9                             ; store catalogue offset of file to extend
        jsr     select_ram_page_003             ; page in catalogue sector 1
        lda     $FD05                           ; get number of files in catalogue * 8
        sta     L00AA                           ; save in zero page
        jsr     LA053                           ; push file map on stack
        tsx                                     ; x = stack pointer
        stx     $B2                             ; save pointer to file map
        jsr     LA0CE                           ; confirm space available
        bcs     L9EE8                           ; if space cannot be made
        jsr     dobrk_with_Disk_prefix          ; then raise "Disk full" error
        .byte   $BF                             ; number = &BF, "Can't extend", cf. &93EF
        .byte   "full"
; ----------------------------------------------------------------------------
        brk
; Move files with space confirmed available
L9EE8:  jsr     LA0C9                           ; confirm space available after file
        bcc     L9F02                           ; if not then shift previous files up
        sec
        lda     $CA                             ; else get LSB LBA of end of slack to use
        sbc     $C8                             ; subtract LSB headroom
        sta     $CA                             ; store LSB LBA of new end of block
        lda     $CB                             ; get MSB LBA of end of slack to use
        sbc     $C9                             ; subtract MSB headroom
        sta     $CB                             ; update MSB LBA of new end of block
        lda     #$00
        sta     $CC                             ; do not move previous files
        sta     $CD
        beq     L9F0F                           ; and branch (always)
; Shifting later files down is insufficient; must shift earlier files up
L9F02:  sec
        lda     #$00
        sbc     $C8                             ; negate LSB negative headroom
        sta     $CC                             ; store LSB excess to move previous files by
        lda     #$00
        sbc     $C9                             ; negate MSB negative headroom
        sta     $CD                             ; store MSB excess
; Shift files after current file down
L9F0F:  lda     $C6                             ; test total slack space after file
        ora     $C7
        beq     L9F45                           ; if none then all space must come from prev
L9F15:  clc
        lda     $0108,y                         ; get LSB length of file in sectors
        sta     $C6                             ; store at C6
        adc     $0106,y                         ; add LSB LBA of file
        sta     $C8                             ; store LSB source LBA
        lda     $0107,y                         ; get MSB length of file in sectors
        sta     $C7                             ; store at C7
        adc     $0105,y                         ; add MSB LBA of file
        sta     $C9                             ; store MSB source LBA
        jsr     L9F9E                           ; move file data
        lda     $FDD0                           ; get channel workspace pointer for open file
        sta     $C3                             ; store at C3
        jsr     L9FF1                           ; update LBAs in channel workspaces
        lda     $CB                             ; get LSB destination LBA after transfer
        sta     $0105,y                         ; replace LSB LBA of file
        lda     $CA                             ; get MSB destination LBA after transfer
        sta     $0106,y                         ; replace MSB LBA of file
        jsr     iny_x4                          ; add 4 to Y
        dex                                     ; loop until all files after current moved
        bne     L9F15
; Shift files before current file up
L9F45:  lda     $CC                             ; get LSB excess to move previous files by
        sta     $C2                             ; replace LSB total excess
        lda     $CD                             ; get MSB excess to move previous files by
        sta     $C3                             ; replace LSB total excess
        ora     $C2                             ; test excess to move previous files by
        beq     L9F93                           ; if none then update catalogue and exit
        jsr     LA0FC                           ; else confirm space available before file
        clc                                     ; (certain to succeed)
        lda     $0106,y                         ; get LSB LBA of previous file
        adc     $0108,y                         ; add LSB length of file in sectors
        sta     $CA                             ; store LSB LBA of end of previous file
        lda     $0105,y                         ; get MSB LBA of previous file
        adc     $0107,y                         ; add MSB length of file in sectors
        sta     $CB                             ; store MSB LBA of end of previous file:
L9F65:  lda     $0104,y                         ; get LSB length of current file in sectors
        sta     $C6                             ; store at C6
        lda     $0103,y                         ; get MSB length of current file in sectors
        sta     $C7                             ; store at C7
        lda     $0102,y                         ; get LSB LBA of current file
        sta     $C8                             ; store at C8
        lda     $0101,y                         ; get MSB LBA of current file
        sta     $C9                             ; store at C9
        lda     $CA                             ; get LSB LBA of end of previous file
        sta     $0102,y                         ; replace LSB LBA of file
        lda     $CB                             ; get MSB LBA of end of previous file
        sta     $0101,y                         ; replace MSB LBA of file
        lda     #$00                            ; set workspace pointer out of range:
        sta     $C3                             ; update LBAs even of file being extended
        jsr     L9FF1                           ; update LBAs in channel workspaces
        jsr     L891D                           ; shift data
        jsr     dey_x4                          ; subtract 4 from Y
        dex                                     ; loop until beginning of catalogue reached
        bne     L9F65
; Update catalogue and exit
L9F93:  jsr     L9632                           ; load volume catalogue L4
        jsr     LA09A                           ; update LBAs in catalogue
        jsr     L960B                           ; write volume catalogue L4
        clc                                     ; return C=0 sufficient space was made
        rts

; ----------------------------------------------------------------------------
; Move file data
L9F9E:  jsr     push_registers_and_tuck_restoration_thunk; save AXY
        lda     #$00
        sta     $BF                             ; clear MSB load address in JIM space
        sta     $C2                             ; clear LSB number of bytes to transfer
L9FA7:  ldy     $C6                             ; compare size of file in sectors - &0002
        cpy     #$02
        lda     $C7
        sbc     #$00
        bcc     L9FB3                           ; if size of file >= 2 sectors
        ldy     #$02                            ; then transfer size = 2:
L9FB3:  sty     $C3                             ; set number of sectors to transfer
        sec
        lda     $C8                             ; get LSB source LBA
        sbc     $C3                             ; subtract transfer size
        sta     $C5                             ; store LSB of transfer LBA
        sta     $C8                             ; update LSB source LBA
        lda     $C9                             ; get MSB source LBA
        sbc     #$00                            ; borrow in from transfer size
        sta     $C4                             ; store MSB transfer LBA
        sta     $C9                             ; update MSB source LBA
        lda     #$02
        sta     $BE                             ; set load address in JIM space = &0002
        jsr     L959C                           ; set high word of OSFILE load address = &FFFF
        jsr     L9724                           ; read ordinary file to JIM L5
        sec
        lda     $CA                             ; get LSB destination LBA
        sbc     $C3                             ; subtract transfer size
        sta     $C5                             ; store LSB of transfer LBA
        sta     $CA                             ; update LSB destination LBA
        lda     $CB                             ; get MSB destination LBA
        sbc     #$00                            ; borrow in from transfer size
        sta     $C4                             ; store MSB transfer LBA
        sta     $CB                             ; update MSB destination LBA
; NB always works upwards and shifts downwards
; sector reads and writes will not overlap
        lda     #$02
        sta     $BE                             ; set load address in JIM space = &0002
        jsr     L959C                           ; set high word of OSFILE load address = &FFFF
        jsr     L9721                           ; write ordinary file from JIM L5
        jsr     L89B4                           ; subtract transfer size from remainder
        bne     L9FA7                           ; loop while sectors remaining to transfer
        rts

; ----------------------------------------------------------------------------
; Update LBAs in channel workspaces
L9FF1:  jsr     push_registers_and_tuck_restoration_thunk; save AXY
        ldx     #$00                            ; start at channel &11
        lda     $FDCE                           ; get channel open flags:
L9FF9:  asl     a                               ; shift next channel open flag into C
        pha                                     ; save other flags
        bcc     LA04C                           ; if C=0 channel closed then skip, else:
        lda     L9C91,x                         ; x=0..4. get workspace pointer from table
        tay
        lda     $FD00,y                         ; get volume of open file
        jsr     get_physical_drive              ; map volume in A to physical volume
        sta     $C2
        jsr     get_current_physical_drive      ; map current volume to physical volume
        cmp     $C2                             ; compare with current volume
        bne     LA04C                           ; if unequal then no match
        lda     $FCEE,y                         ; get top bits exec/length/load/start sector
        and     #$03                            ; extract b1,b0 of A
        cmp     $C9                             ; compare MSB LBA of start of open file
        bne     LA04C                           ; with LBA of current file; skip if unequal
        lda     $FCF0,y                         ; else get LSB start LBA of open file
        cmp     $C8                             ; compare with LSB LBA of current file
        bne     LA04C                           ; if unequal then skip
        cpy     $C3                             ; else compare wksp pointer with current file
        beq     LA04C                           ; skip if equal (don't move it even if empty)
        lda     $CA                             ; else get LSB new starting LBA
        sta     $FCF0,y                         ; update LSB start LBA of open file
        sbc     $C8                             ; subtract LSB old starting LBA
        sta     $C2                             ; store LSB difference
        lda     $CB                             ; get MSB new starting LBA
        sbc     $C9                             ; subtract LSB old starting LBA
        pha                                     ; save MSB difference
        lda     $FCEE,y                         ; get top bits exec/length/load/start sector
        and     #$FC                            ; mask off MSB start LBA in b1,b0
        ora     $CB                             ; apply MSB new starting LBA
        sta     $FCEE,y                         ; update top bits
        clc
        lda     $C2                             ; get LSB difference in LBAs
        adc     $FCFD,y                         ; add LSB LBA of sector in buffer
        sta     $FCFD,y                         ; update LSB LBA of sector in buffer
        pla                                     ; restore MSB difference
        adc     ram_paging_msb,y                ; add MSB LBA of sector in buffer
        sta     ram_paging_msb,y                ; update LSB LBA of sector in buffer
LA04C:  pla                                     ; restore channel open flags
        inx                                     ; select next channel
        cpx     #$05                            ; loop until channels &11..15 updated
        bne     L9FF9
        rts

; ----------------------------------------------------------------------------
; Push file map on stack
LA053:  pla                                     ; pop caller's address into pointer
        sta     L00AE
        pla
        sta     $AF
        jsr     select_ram_page_003             ; page in catalogue sector 1
        ldy     $FD05                           ; point Y to last catalogue entry
        lda     #$00
        pha                                     ; push word &0000
        pha
        jsr     LA4F8                           ; return no. reserved sectors in data area
        pha                                     ; push as big-endian word
        lda     #$00
        pha
        jsr     select_ram_page_003             ; page in catalogue sector 1
LA06D:  lda     $FD04,y                         ; get LSB file length
        cmp     #$01                            ; c=1 iff LSB >0
        lda     $FD05,y                         ; add C to 2MSB file length, rounding up
        adc     #$00
        pha                                     ; push LSB length in sectors
        php                                     ; save carry flag
        lda     $FD06,y                         ; get top bits exec/length/load/start sector
        jsr     extract_00xx0000                ; extract b5,b4 of A
        plp                                     ; restore carry flag
        adc     #$00                            ; carry out to MSB file length
        pha                                     ; push MSB length in sectors
        lda     $FD07,y                         ; get LSB start sector
        pha                                     ; push LSB start sector
        lda     $FD06,y                         ; get top bits exec/length/load/start sector
        and     #$03                            ; extract b1,b0 of A
        pha                                     ; push MSB start sector
        jsr     dey_x8                          ; subtract 8 from Y
        cpy     #$F8                            ; loop until all entries +volume size pushed
        bne     LA06D
        jsr     select_ram_page_001             ; page in main workspace
        jmp     LA932                           ; return to caller

; ----------------------------------------------------------------------------
; Update LBAs in catalogue
LA09A:  pla                                     ; pop caller's address into pointer
        sta     L00AE
        pla
        sta     $AF
        jsr     select_ram_page_003             ; page in catalogue sector 1
        ldy     #$F8                            ; y = catalogue offset &F8 going to &00:
LA0A5:  jsr     iny_x8                          ; add 8 to Y
        pla                                     ; pop MSB LBA end of volume/start of file
        eor     $FD06,y                         ; XOR top bits exec/length/load/start sector
        and     #$03                            ; mask b1,b0 old XOR new
        eor     $FD06,y                         ; preserve b7..b2, replace b1,b0
        sta     $FD06,y                         ; update top bits exec/length/load/start
        pla                                     ; pop LSB LBA end of volume/start of file
        sta     $FD07,y                         ; store LSB LBA end of volume/start of file
        pla                                     ; discard undefined/file length
        pla
        cpy     $FD05                           ; have all files in catalogue been updated?
        bne     LA0A5                           ; loop until true
        pla                                     ; discard LBA of start of data area
        pla
        pla                                     ; discard file map terminator
        pla
        jsr     select_ram_page_001             ; page in main workspace
        jmp     LA932                           ; return to caller

; ----------------------------------------------------------------------------
; Confirm space available after file
LA0C9:  lda     $A9                             ; get catalogue offset of file to extend
        jmp     LA0D0                           ; jump into routine

; ----------------------------------------------------------------------------
; Confirm space available
LA0CE:  lda     L00AA                           ; get number of files in catalogue * 8
LA0D0:  lsr     a                               ; divide by two, =no. four-byte records
        pha                                     ; save on stack
        clc
        adc     $B2                             ; add to file map pointer
        tay                                     ; terminator located at &0105..08,Y
        pla                                     ; restore A
        lsr     a                               ; divide by four, = no. files
        lsr     a
        sta     $B0                             ; store file count
        inc     $B0                             ; increment it to include end of volume
        ldx     #$00
        stx     $C6                             ; clear total slack space
        stx     $C7
        beq     LA0E9                           ; jump into loop (always)
LA0E5:  inx
        jsr     dey_x4                          ; subtract 4 from Y (toward higher LBAs)
LA0E9:  jsr     LA12C                           ; calculate LBA of end of previous file
        jsr     LA13E                           ; calculate slack space before current file
        jsr     LA152                           ; add slack space to total
        jsr     LA160                           ; subtract total slack space - excess
        bcs     LA0FB                           ; if slack will absorb excess then return C=1
        dec     $B0                             ; else loop
        bne     LA0E5                           ; until all files in map tested
LA0FB:  rts                                     ; return C=0 cannot absorb excess

; ----------------------------------------------------------------------------
; Confirm space available before file
LA0FC:  lda     $A9                             ; get catalogue offset of file to extend
        lsr     a                               ; divide by two, =no. four-byte records
        clc
        adc     $B2                             ; add to file map pointer
        tay                                     ; file's entry located at &0105..08,Y
        sec
        lda     L00AA                           ; get number of files in catalogue * 8
        sbc     $A9                             ; subtract offset of file to extend
        lsr     a                               ; divide by 8
        lsr     a
        lsr     a
        sta     $B0                             ; =count of files after file to extend, >=0
        inc     $B0                             ; increment it to include file itself
        ldx     #$00
        stx     $C6                             ; clear total slack space
        stx     $C7
LA115:  jsr     iny_x4                          ; add 4 to Y (toward lower LBAs)
        inx
        jsr     LA12C                           ; calculate LBA of end of previous file
        jsr     LA13E                           ; calculate slack space before current file
        jsr     LA152                           ; add slack space to total
        jsr     LA160                           ; subtract total slack space - excess
        bcs     LA12B                           ; if slack will absorb excess then return C=1
        dec     $B0                             ; else loop
        bne     LA115                           ; until all files before subject tested
LA12B:  rts                                     ; return C=0 cannot absorb excess

; ----------------------------------------------------------------------------
; Calculate LBA of end of previous file
LA12C:  clc
        lda     $0106,y                         ; get LSB LBA of previous file
        adc     $0108,y                         ; add LSB length of file in sectors
        sta     $C4                             ; store at C4
        lda     $0105,y                         ; get MSB LBA of previous file
        adc     $0107,y                         ; add MSB length of file in sectors
        sta     $C5                             ; store at C5
        rts

; ----------------------------------------------------------------------------
; Calculate slack space before current file
LA13E:  sec
        lda     $0102,y                         ; get LSB LBA of current file
        sta     $CA                             ; store at CA
        sbc     $C4                             ; subtract LSB LBA of end of previous file
        sta     $C4                             ; store LSB slack space
        lda     $0101,y                         ; get MSB LBA of current file
        sta     $CB                             ; store at CB
        sbc     $C5                             ; subtract MSB LBA of end of previous file
        sta     $C5                             ; store MSB slack space
        rts

; ----------------------------------------------------------------------------
; Add slack space to total
LA152:  clc
        lda     $C6                             ; get LSB total slack space
        adc     $C4                             ; add LSB slack space before current file
        sta     $C6                             ; update LSB total slack space
        lda     $C7                             ; get MSB total slack space
        adc     $C5                             ; add MSB slack space before current file
        sta     $C7                             ; update MSB total slack space
        rts

; ----------------------------------------------------------------------------
; Subtract total slack space - excess
LA160:  sec
        lda     $C6                             ; get LSB total slack space
        sbc     $C2                             ; subtract LSB excess (i.e. space to be made)
        sta     $C8                             ; store LSB headroom
        lda     $C7                             ; get MSB total slack space
        sbc     $C3                             ; subtract MSB excess
        sta     $C9                             ; store MSB headroom
        rts                                     ; c=1 if slack space will absorb excess

; ----------------------------------------------------------------------------
; OSFILE
chosfile:
        jsr     LA875                           ; save XY
        jsr     select_ram_page_001             ; page in main workspace
        pha                                     ; push A
        jsr     L8B32                           ; disallow wildcard characters in filename
        stx     $B0                             ; set up pointer from XY
        stx     $FDE4
        sty     $B1
        sty     $FDE5
        ldx     #$00
        ldy     #$00
        jsr     L89D2                           ; copy word at pointer to &BC,D
LA189:  jsr     L89C2                           ; copy next four dwords to &BE..C5 (low words)
        cpy     #$12                            ; &106F..76 (high words)
        bne     LA189
        pla                                     ; transfer call number to X
        tax
        inx                                     ; increment for use as index
        cpx     #$08                            ; was call number &FF or 0..6?
        bcs     LA19F                           ; if not then exit
        lda     osfile_routines_msbs,x          ; else get action address high byte
        pha                                     ; save on stack
        lda     osfile_routines_lsbs,x          ; get action address low byte
        pha                                     ; save on stack
LA19F:  rts                                     ; jump to action address

; ----------------------------------------------------------------------------
; OSFILE   0 = save file
osfile_write_metadata:
        lda     #$00
        sta     L00A8                           ; b6=0 will not accept shorter allocation
        jsr     L93B3                           ; create file from OSFILE block
        jsr     LA2D1                           ; set up pointer to user's OSFILE block
        jsr     L8CF7                           ; return catalogue information to OSFILE block
        jmp     L96FE                           ; write ordinary file L5

; ----------------------------------------------------------------------------
; OSFILE   1 = write catalogue information
osfile_write_load:
        jsr     LA290                           ; ensure unlocked file exists
        jsr     LA22D                           ; set load address from OSFILE block
        jsr     LA24C                           ; set exec address from OSFILE block
        bvc     LA1D1                           ; branch to set attributes and write (always)
; OSFILE   2 = write load address
osfile_write_exec:
        jsr     LA290                           ; ensure unlocked file exists
        jsr     LA22D                           ; set load address from OSFILE block
        bvc     LA1D4                           ; branch to write catalogue (always)
; OSFILE   3 = write execution address
osfile_write_attr:
        jsr     LA290                           ; ensure unlocked file exists
        jsr     LA24C                           ; set exec address from OSFILE block
        bvc     LA1D4                           ; branch to write catalogue (always)
; OSFILE   4 = write file attributes
osfile_read_metadata:
        jsr     LA2BD                           ; ensure file exists
        jsr     LA2AB                           ; ensure file not open (mutex)
LA1D1:  jsr     LA274                           ; set file attributes from OSFILE block
LA1D4:  jsr     L9359                           ; write volume catalogue
        lda     #$01                            ; return A=1, file found
        rts

; ----------------------------------------------------------------------------
; OSFILE   5 = read catalogue information
osfile_delete:
        jsr     LA2BD                           ; ensure file exists
        jsr     L8CF7                           ; return catalogue information to OSFILE block
        lda     #$01                            ; return A=1, file found
        rts

; ----------------------------------------------------------------------------
; OSFILE   6 = delete file
osfile_create:
        jsr     LA290                           ; ensure unlocked file exists
        jsr     L8CF7                           ; return catalogue information to OSFILE block
        jsr     L8C78                           ; delete catalogue entry
        jmp     LA1D4                           ; write volume catalogue, return A=1

; ----------------------------------------------------------------------------
; OSFILE &FF = load file
osfile_save:
        jsr     L8B3E                           ; ensure file matching argument in catalogue
        jsr     LA2D1                           ; set up pointer to user's OSFILE block
        jsr     L8CF7                           ; return catalogue information to OSFILE block
; Load file into memory
LA1F8:  sty     $BC
        ldx     #$00
        lda     L00C0                           ; test offset 6, LSB exec from OSFILE block
        bne     LA206                           ; if non-zero, use load address in catalogue
        iny                                     ; else skip first two bytes of catalogue entry
        iny
        ldx     #$02                            ; skip over user-supplied load address in zp
        bne     LA214                           ; branch (always)
LA206:  jsr     select_ram_page_003             ; page in catalogue sector 1
        lda     $FD0E,y                         ; get top bits exec/length/load/start sector
        sta     $C4
        jsr     select_ram_page_001             ; page in main workspace
        jsr     L958D                           ; expand 18-bit load address to 32-bit
LA214:  jsr     select_ram_page_003             ; page in catalogue sector 1
LA217:  lda     $FD08,y                         ; copy load/exec/length/start from catalogue
        sta     $BE,x                           ; into low words of OSFILE block
        iny                                     ; (our copy, gave user theirs at &A1F5)
        inx
        cpx     #$08                            ; loop until 8 or 6 bytes copied, 0..7/2..7
        bne     LA217
        jsr     L95AC                           ; expand 18-bit exec address to 32-bit
        ldy     $BC
        jsr     L8C9D                           ; print *INFO line if verbose
        jmp     L9704                           ; read ordinary file L5 and exit

; ----------------------------------------------------------------------------
; Set load address from OSFILE block
LA22D:  jsr     push_registers_and_tuck_restoration_thunk; save AXY
        ldy     #$02                            ; set offset = 2
        lda     ($B0),y                         ; get LSB load address from OSFILE block
        jsr     select_ram_page_003
        sta     $FD08,x                         ; store in catalogue entry
        iny                                     ; increment offset; Y=3
        lda     ($B0),y                         ; get 3MSB load address
        sta     $FD09,x                         ; store in catalogue entry
        iny                                     ; increment offset; Y=4
        lda     ($B0),y                         ; get 2MSB load address
        asl     a                               ; extract b17,b16, place in b3,b2
        asl     a
        eor     $FD0E,x                         ; XOR with existing top bits
        and     #$0C                            ; mask b3,b2; A=....XX..
        bpl     LA26A                           ; branch to update top bits (always)
; Set exec address from OSFILE block
LA24C:  jsr     push_registers_and_tuck_restoration_thunk; save AXY
        ldy     #$06                            ; set offset = 6
        lda     ($B0),y                         ; get LSB exec address from OSFILE block
        jsr     select_ram_page_003             ; page in catalogue sector 1
        sta     $FD0A,x                         ; store in catalogue entry
        iny                                     ; increment offset; Y=7
        lda     ($B0),y                         ; get 3MSB exec address
        sta     $FD0B,x                         ; store in catalogue entry
        iny                                     ; increment offset; Y=8
        lda     ($B0),y                         ; get 2MSB load address
        ror     a                               ; extract b17,b16, place in b7,b6
        ror     a
        ror     a
        eor     $FD0E,x                         ; XOR with existing top bits
        and     #$C0                            ; mask b7,b6; A=XX......
LA26A:  eor     $FD0E,x                         ; XOR old top bits with A; 6 bits old, 2 new
        sta     $FD0E,x                         ; set top bits exec/length/load/start sector
        clv                                     ; return V=0
        jmp     select_ram_page_001             ; page in main workspace

; ----------------------------------------------------------------------------
; Set file attributes from OSFILE block
LA274:  jsr     push_registers_and_tuck_restoration_thunk; save AXY
        ldy     #$0E                            ; set Y=14, offset of file attributes
        lda     ($B0),y                         ; get LSB of file attributes
        and     #$0A                            ; test b3=file locked, b1=writing denied
        beq     LA281                           ; if either is set
        lda     #$80                            ; then b7=1 file locked
LA281:  jsr     select_ram_page_002             ; page in catalogue sector 0
        eor     $FD0F,x                         ; else b7=0 file unlocked. get directory char
        and     #$80                            ; from catalogue entry
        eor     $FD0F,x                         ; preserve b6..0, replace b7 from A
        sta     $FD0F,x                         ; save directory char with new lock attribute
        rts

; ----------------------------------------------------------------------------
; Ensure unlocked file exists
LA290:  jsr     LA2C7                           ; test if file exists
        bcc     LA2C2                           ; if not then return A=0 from caller, else:
; Ensure file not locked
LA295:  jsr     select_ram_page_002             ; page in catalogue sector 0
        lda     $FD0F,y                         ; if directory character b7=1
        bpl     LA2C6
LA29D:  jsr     dobrk_with_File_prefix          ; then raise "File locked" error.
        .byte   $C3
        .byte   "locked"
; ----------------------------------------------------------------------------
        brk
; Ensure file not locked or open (mutex)
LA2A8:  jsr     LA295                           ; ensure file not locked
; Ensure file not open (mutex)
LA2AB:  jsr     push_registers_and_tuck_restoration_thunk; save AXY
        tya                                     ; save catalogue pointer
        pha
        ldx     #$08                            ; point XY to filename in catalogue, &FD08
        ldy     #$FD
        pla
        jsr     L9B10                           ; compare filename at XY+A with open filenames
        bcc     LA2C6                           ; if unequal then return
        jmp     L9A1B                           ; else raise "File open" error.

; ----------------------------------------------------------------------------
; Ensure file exists
LA2BD:  jsr     LA2C7                           ; test if file exists
        bcs     LA2C6                           ; if present then return, else:
; Return A=0 from caller
LA2C2:  pla                                     ; discard return address on stack
        pla
        lda     #$00                            ; return A=0 as if from caller.
LA2C6:  rts

; ----------------------------------------------------------------------------
; Test if file exists
LA2C7:  jsr     L89E2                           ; set current file from argument pointer
        jsr     L8C2E                           ; search for file in catalogue
        bcc     LA2DB                           ; if file not found then exit C=0
        tya                                     ; else transfer catalogue pointer to X:
        tax
; Set up pointer to user's OSFILE block
LA2D1:  lda     $FDE4
        sta     $B0
        lda     $FDE5
        sta     $B1
LA2DB:  rts

; ----------------------------------------------------------------------------
; OSGBPB
chosgbpb:
        cmp     #$09
        bcs     LA2DB                           ; if call number >=9 then return
        jsr     push_registers_and_tuck_restoration_thunk; else save AXY
        jsr     select_ram_page_001             ; page in main workspace
        jsr     LA83F                           ; have A=0 returned on exit
        stx     $FDBE                           ; save OSGBPB block pointer in workspace
        sty     $FDBF
        tay                                     ; transfer call number to Y for use as index
        jsr     LA2F9                           ; execute OSGBPB call
        php
        jsr     L96F3                           ; release Tube if present
        plp
        rts

; ----------------------------------------------------------------------------
LA2F9:  lda     osgbpb_routines_lsbs,y          ; get low byte of action address from table
        sta     LFDE0
        lda     osgbpb_routines_msbs,y          ; get high byte of action address from table
        sta     $FDE1
        lda     osgbpb_routines_flags,y         ; get microcode byte from table
        lsr     a                               ; push bit 0 as C
        php
        lsr     a                               ; push bit 1 as C
        php
        sta     $FDDA                           ; store Tube service call number as bits 0..5
        jsr     LA4D5                           ; set up pointer to user's OSGBPB block
        ldy     #$0C                            ; 13 bytes to copy, &0C..&00:
LA314:  lda     ($B4),y                         ; copy user's OSGBPB block
        sta     $FDA1,y                         ; to workspace
        dey                                     ; loop until 13 bytes copied
        bpl     LA314
        lda     $FDA4                           ; and high bytes of address
        and     $FDA5                           ; a=&FF if address is in the host
        ora     $FDCD                           ; a=&FF if Tube absent (&FDCD=NOT MOS flag!)
        clc
        adc     #$01                            ; set A=0, C=1 if transferring to/from host
        beq     LA330                           ; if A>0
        jsr     L96DC                           ; then claim Tube
        clc
        lda     #$FF                            ; and set A=&FF, C=0, transferring to/from Tube
LA330:  sta     $FDDB                           ; set Tube transfer flag
        lda     $FDDA                           ; set A=0 if writing user mem, A=1 if reading
        bcs     LA33F                           ; if transferring to/from Tube
        ldx     #$A2                            ; then point XY to OSGBPB data address
        ldy     #$FD
        jsr     L0406                           ; call Tube service to open Tube data channel
LA33F:  plp                                     ; set C=microcode b1
        bcs     LA346                           ; if reading/writing data then transfer it
        plp                                     ; else C=microcode b0 (=0), pop off stack
LA343:  jmp     (LFDE0)                         ; and jump to action address.

; ----------------------------------------------------------------------------
LA346:  ldx     #$03                            ; 4 bytes to copy, 3..0:
LA348:  lda     $FDAA,x                         ; copy OSGBPB pointer field
        sta     $B6,x                           ; to zero page
        dex
        bpl     LA348
        ldx     #$B6                            ; point X to pointer in zero page
        ldy     $FDA1                           ; set Y=channel number
        lda     #$00                            ; set A=0, read PTR not EXT
        plp                                     ; set C=microcode b0
        bcs     LA35D                           ; if C=0
        jsr     L9BD8                           ; then call OSARGS 1,Y set PTR.
LA35D:  jsr     L9BB8                           ; call OSARGS 0,Y return PTR
        ldx     #$03                            ; 4 bytes to copy, 3..0:
LA362:  lda     $B6,x                           ; copy pointer in zero page
        sta     $FDAA,x                         ; to OSGBPB pointer field
        dex
        bpl     LA362
LA36A:  jsr     LA4C7                           ; invert OSGBPB length field
        bmi     LA37C                           ; and branch into loop (always)
LA36F:  ldy     $FDA1                           ; set Y = channel number
        jsr     LA343                           ; transfer byte / element
        bcs     LA384                           ; if attempted read past EOF then finish
        ldx     #$09                            ; else set X = &09, point to OSGBPB pointer
        jsr     LA4BB                           ; increment pointer
LA37C:  ldx     #$05                            ; set X = &05, point to OSGBPB length field
        jsr     LA4BB                           ; increment OSGBPB length field (inverted)
        bne     LA36F                           ; if not overflowed to zero then loop
        clc                                     ; else set C = 0, no read past EOF:
LA384:  php
        jsr     LA4C7                           ; invert OSGBPB length field
        ldx     #$05                            ; add one to get two's complement (0 -> 0)
        jsr     LA4BB                           ; thus, number of elements not transferred
        ldy     #$0C                            ; 13 bytes to copy, offsets 0..&C:
        jsr     LA4D5                           ; set up pointer to user's OSGBPB block
LA392:  lda     $FDA1,y                         ; copy OSGBPB block back to user memory
        sta     ($B4),y
        dey
        bpl     LA392
        plp
osgbpb_done:
        rts

; ----------------------------------------------------------------------------
; OSGBPB 1 = set pointer and write data
; OSGBPB 2 = write data
osgbpb_pb:
        jsr     LA46D                           ; get byte from user memory
        jsr     chosbput                        ; call OSBPUT; write byte to file
        clc                                     ; return C=0 no end-of-file condition
        rts

; ----------------------------------------------------------------------------
; OSGBPB 3 = set pointer and read data
; OSGBPB 4 = read data
osgbpb_gb:
        jsr     chosbget                        ; call OSBGET; read byte from file
        bcs     osgbpb_done                     ; if end-of-file reached return C=1
        jmp     LA4A4                           ; else write data byte to user memory

; ----------------------------------------------------------------------------
; OSGBPB 5 = read title, boot option and drive
osgbpb_get_media_metadata:
        jsr     LAA1E                           ; set current vol/dir = default, set up drive
        jsr     L961F                           ; ensure current volume catalogue loaded
        lda     #$0C                            ; write 12 to user memory
        jsr     LA4A4                           ; = length of title
        ldy     #$00                            ; set offset to 0
LA3B9:  jsr     select_ram_page_002             ; page in catalogue sector 0
        lda     $FD00,y                         ; get first eight characters of title
        jsr     LA4A4                           ; write to user memory
        iny
        cpy     #$08                            ; loop until 8 characters written
        bne     LA3B9
LA3C7:  jsr     select_ram_page_003             ; page in catalogue sector 1
        lda     fdc_status_or_cmd,y             ; get last four characters from &FD00..3
        jsr     LA4A4                           ; write to user memory (Y = 8..11)
        iny
        cpy     #$0C                            ; loop until 4 more characters written
        bne     LA3C7
        jsr     select_ram_page_003
        lda     $FD06                           ; get boot option/top bits volume size
        jsr     lsr_x4                          ; shift A right 4 places
        jmp     LA4A4                           ; write boot option to user memory and exit

; ----------------------------------------------------------------------------
; OSGBPB 6 = read default (CSD) drive and dir
osgbpb_read_cur_dir:
        lda     $FDC7                           ; get default volume
        jsr     LA480                           ; write length+drive identifier to user memory
        jsr     LA4A2                           ; write binary 1 to user memory
        lda     $FDC6                           ; get default directory character
        jmp     LA4A4                           ; write it to user memory and exit

; ----------------------------------------------------------------------------
; OSGBPB 7 = read library drive and directory
osgbpb_read_lib_dir:
        lda     $FDC9                           ; get library volume
        jsr     LA480                           ; write length+drive identifier to user memory
        jsr     LA4A2                           ; write binary 1 to user memory
        lda     $FDC8                           ; get library directory character
        jmp     LA4A4                           ; write it to user memory and exit

; ----------------------------------------------------------------------------
; OSGBPB 8 = read filenames in default dir
osgbpb_read_names:
        jsr     LAA1E                           ; set current vol/dir = default, set up drive
        jsr     L961F                           ; ensure current volume catalogue loaded
        lda     #$12                            ; replace action address with &A412
        sta     LFDE0                           ; = return one filename
        lda     #$A4
        sta     $FDE1
        jmp     LA36A                           ; and return requested number of filenames.

; ----------------------------------------------------------------------------
; Return one filename (called during OSGBPB 8)
        jsr     select_ram_page_001             ; page in main workspace
        ldy     $FDAA                           ; set Y = catalogue pointer (0 on first call)
LA418:  jsr     select_ram_page_003             ; page in catalogue sector 1
        cpy     $FD05                           ; compare with no. files in catalogue
        bcs     LA44E                           ; if out of files return C=1, read past EOF
        jsr     select_ram_page_002             ; else page in catalogue sector 0
        lda     $FD0F,y                         ; get directory character of cat entry
        jsr     isalpha                         ; set C=0 iff character in A is a letter
        eor     $CE                             ; compare with current directory character
        bcs     LA42F                           ; if directory character is a letter
        and     #$DF                            ; then ignore case.
LA42F:  and     #$7F                            ; mask off attribute bit b7
        beq     LA438                           ; if catalogue entry not in current directory
        jsr     iny_x8                          ; then add 8 to Y
        bne     LA418                           ; and loop (always)
LA438:  lda     #$07                            ; else write 7 to user memory
        jsr     LA4A4                           ; = length of filename
        sta     $B0                             ; set counter to 7
LA43F:  jsr     select_ram_page_002             ; page in catalogue sector 0
        lda     $FD08,y                         ; get character of leaf name
        jsr     LA4A4                           ; write byte to user memory
        iny                                     ; increment catalogue pointer
        dec     $B0                             ; loop until 7 characters transferred
        bne     LA43F                           ; (Y is 7 up, inc at &A379 puts pointer 8 up)
        clc                                     ; c=0, did not run out of filenames:
LA44E:  jsr     select_ram_page_003             ; page in catalogue sector 1
        lda     $FD04                           ; get catalogue cycle number
        jsr     select_ram_page_001             ; page in main workspace
        sty     $FDAA                           ; put updated cat ptr in OSGBPB pointer field
        sta     $FDA1                           ; return catalogue cycle no. in channel field
        rts

; ----------------------------------------------------------------------------
; Set up pointer to user I/O memory
LA45E:  pha
        lda     $FDA2
        sta     $B8
        lda     $FDA3
        sta     $B9
        ldx     #$00                            ; offset = 0 for indexed indirect load/store
        pla
        rts

; ----------------------------------------------------------------------------
; Read data byte from user memory
LA46D:  bit     $FDDB                           ; test Tube transfer flag
        bpl     LA478                           ; if b7=0 then read from I/O memory
        lda     $FEE5                           ; else read from R3DATA
        jmp     LA4B6                           ; increment OSGBPB address field

; ----------------------------------------------------------------------------
LA478:  jsr     LA45E                           ; set up pointer to user I/O memory
        lda     ($B8,x)                         ; read byte from user I/O memory
        jmp     LA4B6                           ; increment OSGBPB address field

; ----------------------------------------------------------------------------
; Write length+drive identifier to user memory
LA480:  pha
        ldy     #$01                            ; return Y=1
        and     #$F0                            ; unless volume letter is B..H
        beq     LA488
        iny                                     ; in which case return Y=2
LA488:  tya
        jsr     LA4A4                           ; write length of drive ID to user memory
        pla
        pha
        and     #$0F                            ; extract drive number
        clc
        adc     #$30                            ; convert to ASCII digit
        jsr     LA4A4                           ; write data byte to user memory
        pla
        jsr     lsr_x4                          ; shift A right 4 places
        beq     LA4DF                           ; if volume letter is A then exit
        clc
        adc     #$41                            ; else convert binary to letter B..H
        jmp     LA4A4                           ; write it to user memory and exit

; ----------------------------------------------------------------------------
; Write binary 1 to user memory
LA4A2:  lda     #$01
; Write data byte to user memory
LA4A4:  jsr     select_ram_page_001             ; page in main workspace
        bit     $FDDB                           ; test Tube flag
        bpl     LA4B1                           ; if Tube not in use then write to I/O memory
        sta     $FEE5                           ; else put byte in R3DATA
        bmi     LA4B6                           ; and increment OSGBPB address field (always)
LA4B1:  jsr     LA45E                           ; set up pointer to user I/O memory
        sta     ($B8,x)                         ; store byte at pointer:
; Increment OSGBPB address field
LA4B6:  jsr     push_registers_and_tuck_restoration_thunk; save AXY
        ldx     #$01                            ; set X = &01, point to OSGBPB data address:
; Increment OSGBPB field
LA4BB:  ldy     #$04
LA4BD:  inc     $FDA1,x
        bne     LA4C6
        inx
        dey
        bne     LA4BD
LA4C6:  rts                                     ; return Z=1 iff field overflows

; ----------------------------------------------------------------------------
; Invert OSGBPB length field
LA4C7:  ldx     #$03
LA4C9:  lda     #$FF
        eor     $FDA6,x
        sta     $FDA6,x
        dex
        bpl     LA4C9
        rts

; ----------------------------------------------------------------------------
; Set up pointer to user's OSGBPB block
LA4D5:  lda     $FDBE
        sta     $B4
        lda     $FDBF
        sta     $B5
LA4DF:  rts

; ----------------------------------------------------------------------------
; Put data byte in user memory
LA4E0:  bit     $FDCC                           ; test Tube data transfer flag
        bmi     LA4E8                           ; if transferring to host
        sta     ($A6),y                         ; then write to address in I/O memory
        rts

; ----------------------------------------------------------------------------
LA4E8:  sta     $FEE5                           ; else write to R3DATA.
        rts

; ----------------------------------------------------------------------------
; Get data byte from user memory
LA4EC:  bit     $FDCC                           ; test Tube data transfer flag
        bmi     LA4F4                           ; if transferring from host
        lda     ($A6),y                         ; then read address in I/O memory
        rts

; ----------------------------------------------------------------------------
LA4F4:  lda     $FEE5                           ; else read from R3DATA.
        rts

; ----------------------------------------------------------------------------
; Return no. reserved sectors in data area
LA4F8:  jsr     select_ram_page_001             ; page in main workspace
        jsr     is_current_drive_ram_disk       ; is the physical drive a RAM disc?
        beq     LA507                           ; if so then return A=2
        lda     #$00                            ; else A=0
        bit     $FDED                           ; test density flag
        bvs     LA509                           ; if single density
LA507:  lda     #$02                            ; then return A=2
LA509:  rts                                     ; else return A=0

; ----------------------------------------------------------------------------
; Get start and size of user memory
LA50A:  jsr     select_ram_page_001             ; page in main workspace
        lda     #$83                            ; call OSBYTE &83 = read OSHWM
        jsr     osbyte
        sty     $FDD5                           ; save MSB
        lda     #$84                            ; call OSBYTE &84 = read HIMEM
        jsr     osbyte
        tya
        sta     $FDD6                           ; save MSB
        sec
        sbc     $FDD5                           ; subtract MSB of OSHWM
        sta     $FDD7                           ; save result = no. pages of user memory.
        rts

; ----------------------------------------------------------------------------
; *HELP UTILS
utils_help:
        ldx     #$48                            ; Print utility command table at &9148
        ldy     #$91
        lda     #$08                            ; 8 entries to print (not *DISK)
        bne     LA534
; *HELP CHAL / *HELP DFS
chal_help:
        ldx     #$B4                            ; Print Challenger command table at &90B4
        ldy     #$90
        lda     #$12                            ; 18 entries to print
LA534:  jsr     init_lda_abx_thunk              ; set up trampoline to read table at XY
        sta     $B8                             ; store number of printable entries in counter
        jsr     L8469                           ; print newline
        clc                                     ; c=0 print version number in banner
        jsr     print_CHALLENGER                ; print Challenger banner
        jsr     print_string_nterm              ; print copyright message
        .byte   "(C) SLOGGER 1987"

        .byte   $0D
; ----------------------------------------------------------------------------
        nop
        ldx     #$00                            ; set offset in command table = 0
LA557:  jsr     print_2_spaces_without_spool    ; print two spaces
        jsr     LA57E                           ; print command name and syntax
        jsr     L8469                           ; print newline
        dec     $B8                             ; decrement count of entries
        bne     LA557                           ; loop until none remain
        rts

; ----------------------------------------------------------------------------
; Call GSINIT with C=0 and reject empty arg
LA565:  jsr     gsinit_with_carry_clear         ; call GSINIT with C=0
        beq     LA56B                           ; if string empty (and unquoted), syntax error
        rts

; ----------------------------------------------------------------------------
; Raise "Syntax: " error
LA56B:  jsr     print_string_2_nterm
        .byte   $DC
        .byte   "Syntax: "
; ----------------------------------------------------------------------------
        nop
        jsr     LA57E                           ; print command name and syntax
        jmp     LA8F8                           ; terminate error message, raise error

; ----------------------------------------------------------------------------
; Print command name and syntax
LA57E:  jsr     push_registers_and_tuck_restoration_thunk; save AXY
        ldx     #$00                            ; set offset in command table = 0
        ldy     #$09                            ; 9 characters in command name column
LA585:  jsr     L00AA                           ; get byte of command name
        bmi     LA592                           ; if terminator reached then print syntax
        jsr     print_char_without_spool        ; else print character in A (OSASCI)
        inx                                     ; increment offset
        dey                                     ; decrement number of spaces remaining
        jmp     LA585                           ; and loop

; ----------------------------------------------------------------------------
; Print syntax
LA592:  dey                                     ; if Y in range 1..128
        bmi     LA599                           ; then command not reached edge of column
        iny                                     ; so
        jsr     print_N_spaces_without_spool    ; print number of spaces in Y
LA599:  inx                                     ; skip action address
        inx
        jsr     L00AA                           ; get syntax byte
        pha                                     ; save it
        inx                                     ; skip over it
        jsr     L922D                           ; add X to trampoline address
        pla
        jsr     LA5AC                           ; print syntax element
        jsr     lsr_x4                          ; shift A right 4 places
        and     #$07                            ; mask b2..0 ignore restricted cmd bit:
; Print syntax element
LA5AC:  jsr     push_registers_and_tuck_restoration_thunk; save AXY
        and     #$0F                            ; mask b3..0 current syntax element
        beq     LA5D0                           ; if null element then return
        tay                                     ; else transfer to Y for use as counter
        lda     #$20                            ; print a space
        jsr     print_char_without_spool        ; print character in A (OSASCI)
        ldx     #$FF                            ; set offset=&FF going to 0:
LA5BB:  inx                                     ; increment offset
        lda     LA5D1,x                         ; get character of syntax element table
        bne     LA5BB                           ; loop until NUL reached
        dey                                     ; decrement number of NULs to skip
        bne     LA5BB                           ; when Y=0 we've reached correct element:
LA5C4:  inx                                     ; increment offset
        lda     LA5D1,x                         ; get character of syntax element table
        beq     LA5D0                           ; if NUL reached then return
        jsr     print_char_without_spool        ; else print character in A (OSASCI)
        jmp     LA5C4                           ; and loop until element printed.

; ----------------------------------------------------------------------------
LA5D0:  rts

; ----------------------------------------------------------------------------
; Table of syntax elements
LA5D1:  .byte   $00                             ; element &0, ""
        .byte   "<fsp>"                         ; element &1, <fsp>
        .byte   $00
        .byte   "<afsp>"                        ; element &2, <afsp>
        .byte   $00
        .byte   "(L)"                           ; element &3, (L)
        .byte   $00
        .byte   "<src drv>"                     ; element &4, <src drv>

        .byte   $00
        .byte   "<dest drv>"                    ; element &5, <dest drv>

        .byte   $00
        .byte   "<dest drv> <afsp>"             ; element &6, <dest drv> <afsp>


        .byte   $00
        .byte   "<new fsp>"                     ; element &7, <new fsp>

        .byte   $00
        .byte   "<old fsp>"                     ; element &8, <old fsp>

        .byte   $00
        .byte   "(<dir>)"                       ; element &9, (<dir>)
        .byte   $00
        .byte   "(<drv>)"                       ; element &A, (<drv>)
        .byte   $00
        .byte   "<title>"                       ; element &B, <title>
        .byte   $00                             ; terminator byte
; ----------------------------------------------------------------------------
; *COMPACT
compact_command:
        jsr     LAA16                           ; parse volume spec from argument
        sta     $FDCA                           ; set as source drive
        sta     $FDCB                           ; set as destination drive
        jsr     print_string_nterm
        .byte   "Compacting"

; ----------------------------------------------------------------------------
        nop
        jsr     L8EAD                           ; print " Drive " plus volume spec in A
        jsr     L8469                           ; print newline
        jsr     L9974                           ; close all files
        jsr     LA50A                           ; get start and size of user memory
        jsr     L962F                           ; load volume catalogue L4
        jsr     L8523                           ; save parameters of source drive
        jsr     L852A                           ; save parameters of destination drive
        jsr     select_ram_page_003             ; page in catalogue sector 1
        ldy     $FD05                           ; get number of files in catalogue
        sty     $CC                             ; set as catalogue pointer
        lda     #$00                            ; initialise LBA to start of data area
        sta     $CB
        jsr     LA4F8
        sta     $CA
LA673:  ldy     $CC                             ; set Y to catalogue pointer
        jsr     dey_x8                          ; subtract 8 from Y
        cpy     #$F8                            ; if we've reached end of catalogue
        beq     LA6D6                           ; then finish
        sty     $CC                             ; else set new catalogue pointer
        jsr     L8C9D                           ; print *INFO line if verbose
        ldy     $CC
        jsr     LA703                           ; test length of file
        beq     LA6CE                           ; if empty then only print *INFO line
        lda     #$00
        sta     $BE                             ; else set LSB load address = 0
        sta     $C2                             ; set LSB transfer size = 0
        jsr     LA714                           ; calculate number of sectors used by file
        jsr     select_ram_page_003             ; page in catalogue sector 1
        lda     $FD0F,y                         ; get LSB start sector
        sta     $C8                             ; set LSB source LBA
        lda     $FD0E,y                         ; get top bits exec/length/load/start sector
        and     #$03                            ; extract b1,b0 of A
        sta     $C9                             ; set MSB source LBA
        cmp     $CB                             ; compare with destination LBA
        bne     LA6B0                           ; if unequal then compact file
        lda     $C8                             ; else compare LSBs source - destination LBA
        cmp     $CA
        bne     LA6B0                           ; if unequal then compact file
        jsr     LA733                           ; else add number of sectors to total
        jmp     LA6CE                           ; print *INFO line and loop for next file

; ----------------------------------------------------------------------------
; Compact file
LA6B0:  jsr     select_ram_page_003             ; page in catalogue sector 1
        lda     $CA                             ; set LSB start sector = destination LBA
        sta     $FD0F,y
        lda     $FD0E,y                         ; get top bits exec/length/load/start sector
        and     #$FC                            ; clear b1,b0 MSB start sector
        ora     $CB                             ; replace with MSB destination LBA
        sta     $FD0E,y                         ; set top bits exec/length/load/start sector
        lda     #$00
        sta     L00A8                           ; no catalogue entry waiting to be created
        sta     $A9                             ; &00 = source and dest. are different drives
        jsr     L8948                           ; copy source drive/file to destination
        jsr     L960B                           ; write volume catalogue L4
LA6CE:  ldy     $CC
        jsr     L8CA5                           ; print *INFO line
        jmp     LA673                           ; loop for next file

; ----------------------------------------------------------------------------
LA6D6:  jsr     print_string_nterm              ; print "Disk compacted "
        .byte   "Disk compacted "

; ----------------------------------------------------------------------------
        nop
        sec
        jsr     select_ram_page_003             ; page in catalogue sector 1
        lda     $FD07                           ; get LSB volume size
        sbc     $CA                             ; subtract LSB sectors used on volume
        sta     $C6                             ; =LSB sectors free. save on stack
        lda     $FD06                           ; get boot option/top bits volume size
        and     #$03                            ; extract volume size in b1,b0
        sbc     $CB                             ; subtract MSB sectors used on volume
        sta     $C7
        jsr     L8BE0                           ; print number of free sectors
        jmp     L88CA                           ; store empty BASIC program at OSHWM (NEW)

; ----------------------------------------------------------------------------
; Test length of file
LA703:  jsr     select_ram_page_003             ; page in catalogue sector 1
        lda     $FD0E,y                         ; get top bits exec/length/load/start sector
        and     #$30                            ; extract length in b5,b4
        ora     $FD0D,y                         ; OR with 2MSB, LSB of length
        ora     $FD0C,y                         ; return Z=1 if length=0, empty file.
        jmp     select_ram_page_001             ; page in main workspace

; ----------------------------------------------------------------------------
; Calculate number of sectors used by file
LA714:  jsr     select_ram_page_003             ; page in catalogue sector 1
        clc
        lda     $FD0C,y                         ; get LSB length
        adc     #$FF                            ; c=1 iff LSB >0
        lda     $FD0D,y                         ; add C to 2MSB length, rounding up
        adc     #$00                            ; (Y points to 8 bytes before file entry)
        sta     $C6
        lda     $FD0E,y                         ; get top bits exec/length/load/start sector
        php                                     ; save carry flag from addition
        jsr     extract_00xx0000                ; extract length from b5,4 to b1,0
        plp                                     ; restore carry flag
        adc     #$00                            ; add C to MSB length, rounding up
        sta     $C7                             ; store length in sectors in zero page
        jmp     select_ram_page_001             ; page in main workspace

; ----------------------------------------------------------------------------
; Add number of sectors to total
LA733:  clc                                     ; add LSB
        lda     $CA
        adc     $C6
        sta     $CA
        lda     $CB                             ; add MSB
        adc     $C7
        sta     $CB
        rts

; ----------------------------------------------------------------------------
; Set swapping and current disc flags
LA741:  lda     $FDCB                           ; get destination drive
        jsr     get_physical_drive              ; map volume in A to physical volume
        sta     $A9                             ; store in temporary variable
        lda     $FDCA                           ; get source drive
        jsr     get_physical_drive              ; map volume in A to physical volume
        cmp     $A9                             ; compare with destination drive
        bne     LA75A                           ; if equal
        lda     #$FF                            ; then A=&FF
        sta     $A9                             ; b7=1 source & dest. share drive (swapping)
        sta     L00AA                           ; b7=1 dest. disc in drive (ask for source)
        rts

; ----------------------------------------------------------------------------
LA75A:  lda     #$00                            ; &00 = source and dest. are different drives
        sta     $A9
        rts

; ----------------------------------------------------------------------------
; Ensure *ENABLE active
LA75F:  jsr     push_registers_and_tuck_restoration_thunk; save AXY
        bit     $FDDF                           ; test *ENABLE flag
        bpl     LA787                           ; if b7=0 then current command is enabled
        jsr     print_string_nterm              ; else print "Are you sure ? Y/N "
        .byte   $0D
        .byte   "Are you sure ? Y/N "


; ----------------------------------------------------------------------------
        nop
        jsr     L84DE                           ; ask user yes or no
        beq     LA787                           ; if user typed Y then return
        ldx     $B8                             ; else reset to stack pointer set at &80C0
        txs                                     ; and exit from *command.
LA787:  jmp     L8469                           ; print newline

; ----------------------------------------------------------------------------
; Parse and print source and dest. volumes
LA78A:  jsr     LA565                           ; call GSINIT with C=0 and reject empty arg
        jsr     LAA7F                           ; parse volume spec
        sta     $FDCA                           ; store source volume
        jsr     LA565                           ; call GSINIT with C=0 and reject empty arg
        jsr     LAA7F                           ; parse volume spec
        sta     $FDCB                           ; store destination volume
        tya                                     ; save GSINIT offset in Y
        pha
        jsr     LA741                           ; set swapping and current disc flags
        jsr     LA50A                           ; get start and size of user memory
        jsr     print_string_nterm              ; print "Copying from drive "
        .byte   "Copying from drive "


; ----------------------------------------------------------------------------
        lda     $FDCA                           ; get source volume
        jsr     L8EB8                           ; print volume spec in A
        jsr     print_string_nterm              ; print " to drive "
        .byte   " to drive "

; ----------------------------------------------------------------------------
        lda     $FDCB                           ; get destination volume
        jsr     L8EB8                           ; print volume spec in A
        jsr     L8469                           ; print newline
        pla                                     ; restore GSINIT offset to Y
        tay
        clc
        rts

; ----------------------------------------------------------------------------
; Increment and print BCD word
LA7DA:  sed                                     ; set decimal mode
        clc                                     ; increment low byte
        lda     L00A8
        adc     #$01                            ; only ADC and SBC have decimal mode
        sta     L00A8                           ; carry out in C, the only valid flag
        lda     $A9                             ; carry out to high byte
        adc     #$00
        sta     $A9
        cld                                     ; clear decimal mode
; Print space-padded hex word
LA7E9:  clc                                     ; set C=1, pad numeric field with spaces
        lda     $A9                             ; get high byte of word
        jsr     LA800                           ; print hex byte, C=0 if space-padded
        bcs     LA7F2                           ; c=digit printed; preserve over entry point
; Print space-padded hex byte
LA7F1:  clc
; Print hex byte, C=0 if space-padded
LA7F2:  lda     L00A8                           ; get low byte of word
        bne     LA800                           ; if non-zero then print it
        bcs     LA800                           ; else if not space-padded then print zeroes
        jsr     print_space_without_spool       ; else print a space
        lda     #$00
        jmp     print_hex_nybble                ; and print hex nibble (0).

; ----------------------------------------------------------------------------
; Print hex byte, C=0 if space-padded
LA800:  pha
        php                                     ; save space padding flag in C
        jsr     lsr_x4                          ; shift A right 4 places
        plp                                     ; restore C
        jsr     LA80A                           ; print top nibble of byte
        pla                                     ; restore bottom nibble:
; Print space-padded hex nibble
LA80A:  pha                                     ; test accumulator, Z=1 if zero
        pla
        bcs     LA810                           ; if digit has been printed print another
        beq     print_space_without_spool       ; else if nibble is zero print a space
LA810:  jsr     print_hex_nybble                ; else print hex nibble
        sec                                     ; set C=1 to suppress space padding
        rts                                     ; and exit

; ----------------------------------------------------------------------------
; Print two spaces
print_2_spaces_without_spool:
        jsr     print_space_without_spool
; Print a space
print_space_without_spool:
        pha                                     ; preserve A
        lda     #$20
        jsr     print_char_without_spool        ; print character in A (OSASCI)
        pla
        clc                                     ; return C=0
        rts

; ----------------------------------------------------------------------------
; Claim service call and set up argument ptr
LA821:  tsx
        lda     #$00                            ; have A=0 returned on exit
        sta     $0107,x
        tya                                     ; save string offset
        pha
        jsr     LA565                           ; call GSINIT with C=0 and reject empty arg
        pla                                     ; restore string offset
        tay
        tya                                     ; set XY to GSINIT pointer + Y
        clc                                     ; add Y to LSB of GSINIT pointer
        adc     $F2
        tax                                     ; hold in X
        lda     $F3                             ; carry out to high byte of GSINIT pointer
        adc     #$00
        tay                                     ; hold in Y
; Clear private pointer
LA838:  lda     #$00
        sta     L00A8
        sta     $A9
        rts

; ----------------------------------------------------------------------------
; Have A=0 returned on exit
LA83F:  pha                                     ; caller called Save AXY, A was at &0105,S
        txa                                     ; save caller's AX
        pha                                     ; these two bytes plus return address make 4
        tsx                                     ; superroutine's A is thus 5+4 = 9 bytes down
        lda     #$00
        sta     $0109,x
        pla                                     ; restore caller's AX
        tax
        pla
        rts

; ----------------------------------------------------------------------------
; Save AXY
push_registers_and_tuck_restoration_thunk:
        pha                                     ; stack = &6E,&A8,y,x,a,cl,ch,sl,sh
        txa                                     ; cl,ch=caller return address
        pha                                     ; sl,sh=superroutine return address
        tya
        pha
        lda     #$A8
        pha
        lda     #$6E
        pha
LA857:  ldy     #$05                            ; duplicate y,x,a,cl,ch
LA859:  tsx
        lda     $0107,x
        pha
        dey
        bne     LA859
        ldy     #$0A                            ; copy top 10 bytes down 2 places:
LA863:  lda     $0109,x                         ; overwrite bottom copy of cl,ch
        sta     $010B,x
        dex
        dey                                     ; stack now contains:
        bne     LA863                           ; y,x,y,x,a,cl,ch,&6E,&A8,y,x,a,sl,sh
        pla                                     ; discard y,x:
        pla
; Restore AXY and return
LA86F:  pla
        tay
        pla
        tax
        pla
        rts

; ----------------------------------------------------------------------------
; Save XY
LA875:  pha                                     ; push y,x,a
        txa
        pha
        tya
        pha
        jsr     LA857                           ; restack then "call" rest of caller's routine!
        tsx                                     ; get stack pointer
        sta     $0103,x                         ; store A on exit from caller in stack:
        jmp     LA86F                           ; restore y,x on entry, a on exit.

; ----------------------------------------------------------------------------
; Raise "Disk read only" error
LA884:  jsr     dobrk_with_Disk_prefix
        .byte   $C9
        .byte   "read only"

; ----------------------------------------------------------------------------
        brk
; Raise "Disk " error
dobrk_with_Disk_prefix:
        jsr     LA8D0
        .byte   "Disk "
; ----------------------------------------------------------------------------
        bcc     print_string_2_nterm
; Raise "Bad " error
dobrk_with_Bad_prefix:
        jsr     LA8D0
        .byte   "Bad "
; ----------------------------------------------------------------------------
        bcc     print_string_2_nterm
; Raise "File " error
dobrk_with_File_prefix:
        jsr     LA8D0
        .byte   "File "
; ----------------------------------------------------------------------------
; Append error message immediate
print_string_2_nterm:
        sta     $B3                             ; save A on entry
        pla                                     ; pop caller's address into pointer
        sta     L00AE
        pla
        sta     $AF
        lda     $B3                             ; restore A on entry and save on stack
        pha
        tya                                     ; save Y
        pha
        ldy     #$00                            ; set Y=0 for indirect indexed load
        jsr     inc_AEw                         ; increment &AE,F
        lda     (L00AE),y                       ; get error number from byte after JSR
        sta     $0101                           ; store at bottom of stack
        jsr     set_rom_status_byte_msb         ; if error message already being built
        bmi     LA8E2                           ; then complete it
        lda     #$02                            ; else A = &02
        sta     L0100                           ; error message being built from offset 2
        bne     LA8E2                           ; build error message (always)
; Prefix error message immediate
LA8D0:  jsr     LA93B                           ; begin error message
; Print string immediate
print_string_nterm:
        sta     $B3                             ; save A on entry
        pla                                     ; pop caller's address into pointer
        sta     L00AE
        pla
        sta     $AF
        lda     $B3                             ; restore A on entry and save on stack
        pha
        tya                                     ; save Y
        pha
        ldy     #$00                            ; set Y=0 for indirect indexed load:
LA8E2:  jsr     inc_AEw                         ; increment &AE,F
        lda     (L00AE),y                       ; get character from after JSR
        bmi     LA8F1                           ; if b7=1 then opcode terminator, execute it
        beq     LA8F8                           ; else if NUL then raise error
        jsr     print_char_without_spool        ; else print the character
        jmp     LA8E2                           ; and loop

; ----------------------------------------------------------------------------
LA8F1:  pla                                     ; restore AY
        tay
        pla
        clc
        jmp     (L00AE)                         ; jump to address of end of string

; ----------------------------------------------------------------------------
; Terminate error message, raise error
LA8F8:  lda     #$00
        ldx     L0100                           ; get offset of end of error message
        sta     L0100,x                         ; set NUL error message terminator
        sta     L0100                           ; instruction at &0100 = BRK
        jsr     get_rom_status_byte             ; get Challenger unit type
        and     #$7F                            ; b7=0
        sta     $0DF0,x                         ; no error message being built print to screen
        jsr     L9753                           ; forget catalogue in JIM pages 2..3
        jsr     L96F3                           ; release Tube if present
        jsr     release_nmi_area                ; release NMI
        jmp     L0100                           ; jump to BRK to raise error

; ----------------------------------------------------------------------------
; Print VDU sequence immediate
print_string_255term:
        pla                                     ; pop caller's address into pointer
        sta     L00AE
        pla
        sta     $AF
        tya                                     ; save Y
        pha
        ldy     #$00                            ; offset = 0 for indirect indexed load
LA921:  jsr     inc_AEw                         ; increment &AE,F
        lda     (L00AE),y                       ; get character from after JSR
        cmp     #$FF                            ; if &FF terminator byte
        beq     LA930                           ; then skip it and return to code after it
        jsr     oswrch                          ; else call OSWRCH
        jmp     LA921                           ; and loop

; ----------------------------------------------------------------------------
LA930:  pla                                     ; restore Y
        tay
LA932:  jsr     inc_AEw                         ; increment &AE,F
        jmp     (L00AE)                         ; jump to address at end of string

; ----------------------------------------------------------------------------
; Begin error message, number in A
LA938:  sta     $0101                           ; set first byte after BRK to error number
; Begin error message
LA93B:  lda     #$02
        sta     L0100                           ; error message being built from offset 2
set_rom_status_byte_msb:
        jsr     get_rom_status_byte             ; get Challenger unit type
        php
        ora     #$80                            ; b7=1
        sta     $0DF0,x                         ; error message being built, &0100 = offset
        plp
        rts

; ----------------------------------------------------------------------------
; Print letter N
print_N_without_spool:
        lda     #$4E
        bne     print_char_without_spool        ; branch (always)
; Print a dot
print_dot_without_spool:
        lda     #$2E
; prints char, disabling *SPOOL first
; Print character in A (OSASCI)
print_char_without_spool:
        jsr     push_registers_and_tuck_restoration_thunk; save AXY
        pha                                     ; save character
        jsr     get_rom_status_byte             ; get Chal. unit type. if error being built
        bmi     LA96D                           ; then append character to error message else:
        jsr     osbyte_read_character_destination; call OSBYTE &EC = read/write char dest status
        txa                                     ; save current output stream setting
        pha
        ora     #$10                            ; b4=1 disable *SPOOL output
        jsr     osbyte_select_output_stream_a   ; call OSBYTE &03 = specify output stream in A
        pla                                     ; restore previous output stream setting
        tax
        pla                                     ; restore character
        jsr     osasci                          ; call OSASCI
        jmp     osbyte_select_output_stream     ; call OSBYTE &03 = specify output stream

; ----------------------------------------------------------------------------
; Append character to error message
LA96D:  pla                                     ; restore character
        ldx     L0100                           ; get pointer to end of error message
        sta     L0100,x                         ; store character there
        inc     L0100                           ; and increment pointer
        rts

; ----------------------------------------------------------------------------
; Print hex byte
print_hex_byte:
        pha                                     ; save A
        jsr     lsr_x4                          ; shift A right 4 places
        jsr     print_hex_nybble                ; print top nibble of byte
        pla                                     ; restore bottom nibble:
; Print hex nibble
print_hex_nybble:
        pha                                     ; save A
        and     #$0F                            ; extract b3..0
        sed                                     ; set decimal mode for 6502 deep magic
        clc
        adc     #$90                            ; a=&90..99, C=0 or A=&00..05, C=1
        adc     #$40                            ; a=&30..39      or A=&41..46
        cld                                     ; clear decimal mode
        jsr     print_char_without_spool        ; print character in A (OSASCI)
        pla                                     ; restore A
        rts

; ----------------------------------------------------------------------------
; Acknowledge ESCAPE condition
acknowledge_escape:
        lda     #$7E                            ; OSBYTE &7E = acknowledge ESCAPE condition
        jmp     osbyte                          ; call OSBYTE and exit

; ----------------------------------------------------------------------------
; Extract b7,b6 of A
extract_xx000000:
        lsr     a
        lsr     a
; Extract b5,b4 of A
extract_00xx0000:
        lsr     a
        lsr     a
; Extract b3,b2 of A
extract_0000xx00:
        lsr     a
        lsr     a
        and     #$03
        rts

; ----------------------------------------------------------------------------
; Shift A right 5 places
lsr_x5: lsr     a
; Shift A right 4 places
lsr_x4: lsr     a
        lsr     a
        lsr     a
        lsr     a
        rts

; ----------------------------------------------------------------------------
; unreachable code
        asl     a
; Shift A left 4 places
asl_x4: asl     a
        asl     a
        asl     a
        asl     a
        rts

; ----------------------------------------------------------------------------
; Add 8 to Y
iny_x8: iny
; Add 7 to Y
iny_x7: iny
        iny
        iny
; Add 4 to Y
iny_x4: iny
        iny
        iny
        iny
        rts

; ----------------------------------------------------------------------------
; Subtract 8 from Y
dey_x8: dey
        dey
        dey
        dey
; Subtract 4 from Y
dey_x4: dey
        dey
        dey
        dey
        rts

; ----------------------------------------------------------------------------
; Uppercase and validate letter in A
toupper:cmp     #$41                            ; is character less than capital A?
        bcc     toupper_was_nonalpha            ; if so then return C=1
        cmp     #$5B                            ; else is it more than capital Z?
        bcc     toupper_was_alpha               ; if not then uppercase and return C=0
        cmp     #$61                            ; else is it less than lowercase a?
        bcc     toupper_was_nonalpha            ; if so then return C=1
        cmp     #$7B                            ; else is it more than lowercase z?
        bcc     toupper_was_alpha               ; if not then uppercase and return C=0
toupper_was_nonalpha:
        sec                                     ; else return C=1
        rts

; ----------------------------------------------------------------------------
toupper_was_alpha:
        and     #$DF                            ; mask bit 5, convert letter to uppercase
        clc
        rts

; ----------------------------------------------------------------------------
; Set C=0 iff character in A is a letter
isalpha:pha
        jsr     toupper                         ; uppercase and validate letter in A
        pla
        rts

; ----------------------------------------------------------------------------
; unreachable code
        jsr     xtoi
        bcc     do_sec
        cmp     #$10
        rts

; ----------------------------------------------------------------------------
; unreachable code
do_sec: sec
        rts

; ----------------------------------------------------------------------------
; Convert ASCII hex digit to binary
xtoi:   cmp     #$41                            ; if digit is less than A
        bcc     LA9E7                           ; then convert 0..9 to binary
        sbc     #$07                            ; else convert A..F to binary
LA9E7:  sec
        sbc     #$30
        rts

; ----------------------------------------------------------------------------
; Increment &AE,F
inc_AEw:inc     L00AE
        bne     LA9F1
        inc     $AF
LA9F1:  rts

; ----------------------------------------------------------------------------
; Call GSINIT with C=0
gsinit_with_carry_clear:
        clc                                     ; c=0 space or CR terminates unquoted strings
        jmp     gsinit                          ; jump to GSINIT

; ----------------------------------------------------------------------------
; Set current drive from ASCII digit
LA9F6:  jsr     LAABA                           ; convert and validate ASCII drive digit
        sta     current_drive                   ; set as current drive
        rts

; ----------------------------------------------------------------------------
; Set volume from ASCII letter
LA9FC:  jsr     toupper                         ; uppercase and validate letter in A
        sec                                     ; subtract ASCII value of A
        sbc     #$41                            ; obtain ordinal 0..25
        bcc     LAA34                           ; if ordinal negative then "Bad drive"
        cmp     #$08                            ; else is ordinal 8 or more?
        bcs     LAA34                           ; if so then raise "Bad drive" error
        jsr     asl_x4                          ; else shift A left 4 places
        ora     current_drive                   ; combine volume letter with current drive
        sta     current_drive                   ; set as current volume, return C=0
        rts

; ----------------------------------------------------------------------------
; unreachable code
; Call GSINIT and parse mandatory vol spec
        jsr     LA565                           ; call GSINIT with C=0 and reject empty arg
        jmp     LAA7F                           ; parse volume spec

; ----------------------------------------------------------------------------
; Parse volume spec from argument
LAA16:  jsr     gsinit_with_carry_clear         ; call GSINIT with C=0
        beq     LAA26                           ; if no argument then current vol = default
        jmp     LAA7F                           ; else parse volume spec

; ----------------------------------------------------------------------------
; Set current volume and directory = default
LAA1E:  jsr     select_ram_page_001             ; page in main workspace
        lda     $FDC6                           ; get default directory
        sta     $CE                             ; set as current directory:
; Set current volume = default volume
LAA26:  lda     $FDC7                           ; get default volume
        sta     current_drive                   ; set as current volume
LAA2B:  rts

; ----------------------------------------------------------------------------
; unreachable code
        jsr     LAA16
        jsr     gsinit_with_carry_clear
        beq     LAA2B
; Raise "Bad drive" error
LAA34:  jsr     dobrk_with_Bad_prefix
        .byte   $CD
        .byte   "drive"
; ----------------------------------------------------------------------------
        brk
; Parse directory spec
LAA3E:  jsr     gsread                          ; call GSREAD
        bcs     LAA71                           ; if end of argument then exit C=1
        cmp     #$3A                            ; else is character a colon?
        bne     LAA69                           ; if not then accept directory character
        jsr     gsread                          ; else call GSREAD
        bcs     LAA34                           ; if ":" by itself then "Bad drive" error
        jsr     LA9F6                           ; else set current drive from ASCII digit
        jsr     gsread                          ; call GSREAD
        bcs     LAA71                           ; if ":<drv>" keep current volume and dir
        cmp     #$2E                            ; else is character a full stop?
        beq     LAA64                           ; if so then expect a directory character
        jsr     LA9FC                           ; else set volume from ASCII letter
        jsr     gsread                          ; call GSREAD
        bcs     LAA71                           ; if ":<drv><vol>" keep current directory
        cmp     #$2E                            ; else ".<dir>" must follow
        bne     LAA34                           ; if next char not full stop "Bad drive"
LAA64:  jsr     gsread                          ; else call GSREAD
        bcs     LAA34                           ; directory char expected else "Bad drive"
LAA69:  jsr     LAAB0                           ; set directory from ASCII character
        jsr     gsread                          ; if not at end of argument
        bcc     LAA34                           ; then raise "Bad drive" error.
LAA71:  rts

; ----------------------------------------------------------------------------
; Select specified or default volume
LAA72:  jsr     LAA26                           ; set current volume = default volume
        ldx     #$00                            ; x=0, nothing specified
        jsr     gsread                          ; call GSREAD
        bcs     LAA71                           ; if end of argument then exit C=1
        sec                                     ; else C=1, ambiguous vol spec allowed
        bcs     LAA86                           ; jump into parse volume spec
; Parse volume spec
LAA7F:  ldx     #$00                            ; x=0, nothing specified
        jsr     gsread                          ; call GSREAD
        bcs     LAA71                           ; if end of argument then exit C=1
LAA86:  php                                     ; else save ambiguity flag in C
        cmp     #$3A                            ; is character a colon?
        bne     LAA90                           ; if not then set drive from digit
        jsr     gsread                          ; else call GSREAD
        bcs     LAA34                           ; if ":" by itself then "Bad drive" error
LAA90:  jsr     LA9F6                           ; set current drive from ASCII digit
        ldx     #$02                            ; x=2, only drive specified
        jsr     gsread                          ; call GSREAD
        bcs     LAAA9                           ; if no more chars return drive, volume=A
        plp                                     ; else restore ambig. flag, if not allowed
        bcc     LAAA4                           ; then set volume and return current volume
        cmp     #$2A                            ; else is character an asterisk? if not
        bne     LAAA4                           ; then set volume and return current volume
        ldx     #$83                            ; else X=&83, drive and ambiguous volume spec
        rts

; ----------------------------------------------------------------------------
LAAA4:  jsr     LA9FC                           ; set volume letter from ASCII letter
        inx                                     ; x=3, drive and volume specified
        php                                     ; push dummy flag
LAAA9:  plp                                     ; discard ambiguity flag
        lda     current_drive                   ; get current volume and exit
        rts

; ----------------------------------------------------------------------------
; unreachable code
        jsr     gsread
; Set directory from ASCII character
LAAB0:  cmp     #$2A                            ; make * an alias of #
        bne     LAAB6
        lda     #$23
LAAB6:  sta     $CE                             ; set as current directory
        clc
        rts

; ----------------------------------------------------------------------------
; Convert and validate ASCII drive digit
LAABA:  sec                                     ; convert to binary drive no. 0..3
        sbc     #$30
        bcc     LAAD6                           ; if invalid then raise "Bad drive" error
        pha                                     ; else save result
        cmp     #$08                            ; is it more than 8?
        bcs     LAAD6                           ; then invalid as a logical drive, "Bad drive"
        jsr     get_physical_drive              ; else map volume in A to physical volume
        cmp     #$05                            ; if not physical drive 5, the second RAM disc
        bne     LAAD4                           ; then accept digit
        jsr     get_rom_status_byte             ; else get Challenger unit type
        and     #$03                            ; mask bits 1,0
        cmp     #$02                            ; is a 512 KiB unit attached?
        bne     LAAD6                           ; if not then phys. drive 5 is a "Bad drive"
LAAD4:  pla                                     ; else return logical drive number, N=0
        rts

; ----------------------------------------------------------------------------
LAAD6:  jmp     LAA34                           ; raise "Bad drive" error

; ----------------------------------------------------------------------------
; Map current volume to physical volume
get_current_physical_drive:
        lda     current_drive                   ; get current volume:
; Map volume in A to physical volume
get_physical_drive:
        jsr     LA875                           ; save XY
        tax                                     ; hold volume in X
        and     #$F0                            ; mask volume letter in bits 6..4
        pha                                     ; save volume letter
        txa                                     ; transfer complete volume to A
        and     #$07                            ; mask logical drive number in bits 2..0
        tax                                     ; transfer to X for use as index
        jsr     select_ram_page_000             ; page in auxiliary workspace
        lda     $FD00,x                         ; look up physical drive for logical drive
        tsx                                     ; transfer stack pointer to X
        ora     $0101,x                         ; apply volume letter saved on top of stack
        tax                                     ; hold result = volume on physical drive
        pla                                     ; discard masked volume letter
        txa                                     ; return physical volume in A
        jmp     select_ram_page_001             ; page in main workspace and exit

; ----------------------------------------------------------------------------
; ChADFS ROM call 0
; *CONFIG
config_command:
        jsr     gsinit_with_carry_clear         ; call GSINIT with C=0
        bne     LAB31                           ; if argument present then parse it
        jsr     print_string_nterm              ; else list mapping. Print "L drv:"
        .byte   "L drv:"
; ----------------------------------------------------------------------------
        ldx     #$00                            ; start at logical drive 0:
print_logical_drive_list_loop:
        txa                                     ; perform identity mapping to print log.drive
        jsr     LAB90                           ; print digit and compare X=8
        bne     print_logical_drive_list_loop   ; loop until logical drives 0..7 listed
        jsr     print_string_nterm              ; print newline + "P drv:"
        .byte   $0D
        .byte   "P drv:"
; ----------------------------------------------------------------------------
        ldx     #$00                            ; start at logical drive 0:
LAB18:  bit     $FDFF                           ; test b6=ChADFS is current FS
        jsr     select_ram_page_000             ; page in auxiliary workspace
        lda     $FD00,x                         ; preload Challenger physical drive mapping
        bvc     LAB26                           ; if ChADFS is current FS
        lda     $FD08,x                         ; then replace with ChADFS physical drive
LAB26:  jsr     select_ram_page_001             ; page in main workspace
        jsr     LAB90                           ; print digit and compare X=8
        bne     LAB18                           ; loop until logical drives 0..7 listed
        jmp     L8469                           ; print newline and exit

; ----------------------------------------------------------------------------
; Parse *CONFIG argument
LAB31:  cmp     #$52                            ; if first character of argument is capital R
        beq     reset_current_drive_mappings    ; then reset drive mappings
LAB35:  jsr     gsread                          ; else call GSREAD
        jsr     LAABA                           ; convert and validate ASCII drive digit
        bit     $FDFF                           ; test b6=ChADFS is current FS
        bvc     LAB43                           ; if ChADFS is current FS
        clc                                     ; then add 8 to A making offset to ChADFS map:
        adc     #$08
LAB43:  sta     $B0                             ; save offset into drive mapping table
        jsr     gsread                          ; call GSREAD
        bcs     LAB67                           ; if only log. drive given then "Syntax" error
        cmp     #$3D                            ; else is next character "="?
        bne     LAB67                           ; if not then "Syntax" error
        jsr     gsread                          ; else "<drv>="; call GSREAD
        bcs     LAB67                           ; if no phys. drive given then "Syntax" error
        jsr     LAABA                           ; else convert and validate ASCII drive digit
        jsr     select_ram_page_000             ; page in auxiliary workspace
        ldx     $B0                             ; restore offset into drive mapping table
        sta     $FD00,x                         ; save physical drive mapping in table
        jsr     select_ram_page_001             ; page in main workspace
        jsr     gsinit_with_carry_clear         ; call GSINIT with C=0
        bne     LAB35                           ; if argument present then parse it
        rts                                     ; else exit

; ----------------------------------------------------------------------------
LAB67:  jmp     LA56B                           ; raise "Syntax: " error

; ----------------------------------------------------------------------------
; *CONFIG R
reset_current_drive_mappings:
        bit     $FDFF                           ; if b6=1 ChADFS is current FS
        bvs     reset_adfs_drive_mappings       ; then only reset ChADFS mapping, else:
; Reset *CONFIG mapping
reset_dfs_drive_mappings:
        jsr     select_ram_page_000             ; page in auxiliary workspace
        ldx     #$07                            ; loop for X = 7..0:
LAB74:  txa
        sta     $FD00,x                         ; configure logical drive X = physical drive X
        dex
        bpl     LAB74                           ; loop until all 8 drive mappings reset
        jmp     select_ram_page_001             ; page in main workspace and exit

; ----------------------------------------------------------------------------
; ChADFS ROM call 3
reset_all_drive_mappings:
        jsr     reset_dfs_drive_mappings        ; reset *CONFIG mapping
reset_adfs_drive_mappings:
        jsr     select_ram_page_000             ; page in auxiliary workspace
        ldx     #$07                            ; loop for X = 7..0:
LAB86:  txa                                     ; configure ChADFS mapping drive X = drive X
        sta     $FD08,x
        dex
        bpl     LAB86                           ; loop until all 8 drive mappings reset
        jmp     select_ram_page_001             ; page in main workspace and exit

; ----------------------------------------------------------------------------
LAB90:  jsr     print_space_without_spool       ; print a space
        jsr     print_hex_nybble                ; print hex nibble
        inx                                     ; increment counter
        cpx     #$08                            ; return Z=1 iff counter has reached 8
        rts

; ----------------------------------------------------------------------------
; Set current vol/dir from open filename
LAB9A:  jsr     select_ram_page_001
        lda     $FCEF,y                         ; get directory character of open file
        and     #$7F                            ; mask off b7 =channel file locked bit
        sta     $CE                             ; set as current directory
        lda     $FD00,y                         ; get volume containing open file
        sta     current_drive                   ; set as current volume
        lda     ram_paging_lsb,y                ; get first track of volume of open file
        sta     $FDEC                           ; set as first track of current volume
        lda     $FCF4,y                         ; get packed drive parameters of open file
        jmp     L850D                           ; restore packed drive parameters and exit

; ----------------------------------------------------------------------------
; Detect disc format/set sector address
LABB5:  jsr     select_ram_page_001             ; page in main workspace
        jsr     claim_nmi_area                  ; claim NMI
        lda     #$00
        sta     $BA                             ; set track number = 0
        sta     $BB                             ; set sector number = 0
        jsr     is_current_drive_ram_disk       ; set Z=1 iff current drive is a RAM disc
        beq     LAC23                           ; if not
        jsr     LB916                           ; then seek logical track
        lda     $FDE9                           ; if data transfer call is not 0 = read data
        and     #$7F
        bne     LAC37                           ; then set sector number = 2 * volume letter
        lda     #$00                            ; else data area starts on track 0
        sta     $FDEC
        jsr     LAC46                           ; set number of sectors per track
        bit     $FDED                           ; test density flag
        bvs     LABE0                           ; if disc is single density
        jsr     LAC1A                           ; then ensure volume letter is A
LABE0:  bit     $FDEA                           ; if double-stepping is automatic
        bpl     LABE8
        jsr     LAC5D                           ; then detect track stepping
LABE8:  bit     $FDED                           ; if disc is single density
        bvc     LAC37                           ; then set sector number = 0
        jsr     LB52E                           ; else copy volume allocations to wksp
        jsr     select_ram_page_002             ; page in catalogue sector 0
        lda     $FD00                           ; test configuration/version number
        cmp     #$E5                            ; of disc catalogue
        bne     LABFD                           ; if byte is &E5 formatting fill byte
        jmp     LAC9F                           ; then "Disk not configured by VOLGEN"

; ----------------------------------------------------------------------------
LABFD:  jsr     LAC3C                           ; set sector number = 2 * volume letter
        tay                                     ; = offset into the track allocation table
        lda     $FD08,y                         ; get first track of volume from disc cat.
        ldy     $FD01                           ; get MSB number of sectors on surface
        ldx     $FD02                           ; get LSB number of sectors on surface
        jsr     select_ram_page_001             ; page in main workspace
        stx     $FDF6                           ; save in workspace
        sty     $FDF5
        sta     $FDEC                           ; set as first track of current volume
        tax
        beq     LAC84                           ; if =0 raise "Volume . n/a" error
LAC19:  rts

; ----------------------------------------------------------------------------
; Ensure volume letter is A
LAC1A:  lda     current_drive                   ; get current volume
        and     #$F0                            ; extract volume letter
        beq     LAC19                           ; if volume letter is not A
        jmp     LAA34                           ; then raise "Bad drive" error

; ----------------------------------------------------------------------------
; Set up for RAM disc
LAC23:  jsr     LAC1A                           ; ensure volume letter is A
        lda     $FDED                           ; set density flag to single density
        and     #$80                            ; preserving automatic density setting
        sta     $FDED
        lda     #$00
        sta     $FDEB                           ; number of sectors per track is undefined
        sta     $FDEC                           ; data area starts on track 0
        rts

; ----------------------------------------------------------------------------
; Set sector number = 2 * volume letter
LAC37:  lda     $FDED                           ; test density flag
        beq     LAC43                           ; if single (and manual!) then start sector =0
LAC3C:  lda     current_drive                   ; else get current volume
        and     #$F0                            ; extract volume letter
        lsr     a                               ; shift right three places
        lsr     a                               ; to get sector offset of volume catalogue
        lsr     a
LAC43:  sta     $BB                             ; set as sector number
        rts

; ----------------------------------------------------------------------------
; Set number of sectors per track
LAC46:  bit     $FDED                           ; if density setting is automatic
        bmi     LAC55                           ; then ensure disc is formatted
        lda     #$0A                            ; else set 10 sectors per track
        bvc     LAC51                           ; unless disc is double density
        lda     #$12                            ; in which case set 18 sectors per track
LAC51:  sta     $FDEB
LAC54:  rts

; ----------------------------------------------------------------------------
; Ensure disc is formatted
LAC55:  jsr     LB95F                           ; read ID and detect density
        beq     LAC54                           ; if record found then exit
        jmp     LBCE3                           ; else raise "Disk not formatted" error.

; ----------------------------------------------------------------------------
; Detect track stepping
LAC5D:  lda     #$00                            ; b7=0 manual, b6=0 1:1 stepping
        sta     $FDEA                           ; set stepping flag
        lda     #$02                            ; track number = 2
        sta     $BA
        jsr     LB9B2                           ; execute Read Address command
        ldx     $0D0C                           ; get C cylinder number
        lda     #$C0
        dex                                     ; is it 1?
        beq     LAC7C                           ; then disc is 40 track, set double stepping
        asl     a
        dex                                     ; else is it 2?
        beq     LAC7C                           ; then 1:1 stepping is correct
        dex                                     ; else the format is wrong, raise an error
        dex                                     ; is the head over logical track 4?
        beq     LACAD                           ; if so then raise "80 in 40" error
        jmp     LBCAF                           ; else raise "Disk fault" error.

; ----------------------------------------------------------------------------
LAC7C:  sta     $FDEA                           ; set stepping flag
        lda     #$00                            ; track number = 0
        sta     $BA
        rts

; ----------------------------------------------------------------------------
; Raise "Volume . n/a" error
LAC84:  jsr     print_string_2_nterm            ; begin error message "Volume "
        .byte   $CD
        .byte   "Volume "
; ----------------------------------------------------------------------------
        lda     $BB                             ; transfer sector offset to A
        lsr     a                               ; divide by 2; A=0..7, C=0
        adc     #$41                            ; convert to ASCII character "A".."H"
        jsr     print_char_without_spool        ; print character in A (to error message)
        jsr     print_string_nterm              ; print " n/a" and raise error
        .byte   " n/a"                          ; short for "not allocated"
        .byte   $00
; ----------------------------------------------------------------------------
LAC9F:  jsr     print_string_2_nterm
        .byte   $CD
        .byte   "No config"

; ----------------------------------------------------------------------------
        brk
LACAD:  jsr     print_string_2_nterm
        .byte   $CD
        .byte   "80 in 40"
; ----------------------------------------------------------------------------
        brk
; Load disc catalogue L3
LACBA:  lda     #$80                            ; data transfer call &80 = read data to JIM
        .byte   $AE                             ; ACBD=LDA #&81
; Write disc catalogue L3
LACBD:  lda     #$81                            ; data transfer call &81 = write data from JIM
        jsr     select_ram_page_001             ; page in main workspace
        sta     $FDE9                           ; set data transfer call number
        ldx     #$03                            ; x = 3 number of attempts allowed:
LACC7:  jsr     L96A5                           ; set data pointer to &0200
        lda     #$10                            ; set sector number = 16
        sta     $BB
        lda     #$00                            ; set track number = 0
        sta     $BA
        sta     $A0                             ; &0100 = 256 bytes to transfer
        lda     #$01
        sta     $A1
        jsr     LBA18                           ; transfer data to disc L2
        beq     LACE3                           ; if command succeeded then exit
        dex                                     ; else decrement attempts remaining
        bne     LACC7                           ; if not run out then try again
        jmp     LBCAF                           ; else raise "Disk fault" error

; ----------------------------------------------------------------------------
LACE3:  rts

; ----------------------------------------------------------------------------
; Transfer data and report errors L4
LACE4:  jsr     LACF0                           ; transfer data L3
        sta     $FDF3                           ; store result of transfer
        bne     LACED                           ; if result >0 then "Disk fault" else exit
        rts

; ----------------------------------------------------------------------------
LACED:  jmp     LBCAF                           ; raise "Disk fault" error

; ----------------------------------------------------------------------------
; Transfer data L3
LACF0:  jsr     LA875                           ; save XY
        lda     #$80
        sta     $B9                             ; >0 disc operation is interruptible
        ldy     #$03                            ; set attempt counter to 3
LACF9:  lda     $FDEB                           ; get number of sectors per track
        php                                     ; save Z flag
        ldx     $A3                             ; set X=LSB byte count
        lda     $A4                             ; set A=2MSB byte count
        plp                                     ; restore Z flag
        beq     LAD1C                           ; if 0 sectors per track then RAM disc, branch
        sec                                     ; else subtract
        lda     $FDEB                           ; number of sectors per track
        sbc     $BB                             ; - starting sector
        sta     $A0                             ; = sectors until end, store temp
        lda     $A5                             ; test MSB byte count
        bne     LAD18                           ; if >=64 KiB then transfer rest of track
        ldx     $A3                             ; else X=LSB byte count
        lda     $A4                             ; set A=2MSB byte count
        cmp     $A0                             ; if transfer ends before end of track
        bcc     LAD1C                           ; then only transfer byte count, else:
; transfer rest of track
LAD18:  ldx     #$00                            ; X=0 byte count is a multiple of 256
        lda     $A0                             ; A=number of sectors (not bytes) to transfer:
LAD1C:  stx     $A0                             ; store LSB byte count
        sta     $A1                             ; store MSB byte count
        ora     $A0                             ; test if byte count > 0
        beq     LAD6B                           ; if no data to transfer then finish
        lda     $FDEB                           ; else test number of sectors per track
        beq     LAD35                           ; if 0 sectors per track then RAM disc, branch
        sec                                     ; else subtract
        lda     $BA                             ; track number
        sbc     #$50                            ; - 80
        bcc     LAD35                           ; if track number in range 0..79 then proceed
        sta     $BA                             ; else set new track number 80 less
        jsr     LAD9B                           ; select side 2 of current drive.
LAD35:  jsr     LBA18                           ; transfer data L2
        bne     LAD6C                           ; if non-zero status then try again
        inc     $BA                             ; else increment track
        sta     $BB                             ; next transfer starts at sector 0
        ldx     $A1                             ; x = ?&A1 = MSB number of bytes transferred
        lda     $A0                             ; a = ?&A0 = LSB number of bytes transferred
        bit     $FDE9                           ; test data transfer call number
        bpl     LAD4A                           ; if b7=1, transferring to JIM
        txa                                     ; then a = ?&A1 = number of pages
        ldx     #$00                            ; x = 0, less than 64 KiB transferred
LAD4A:  clc                                     ; add expected transfer size to xfer. address
        adc     $A6                             ; (byte address in CPU space,
        sta     $A6                             ; page address in JIM space)
        txa
        adc     $A7
        sta     $A7
        sec                                     ; subtract expected transfer size
        lda     $A3                             ; from 24-bit byte count
        sbc     $A0
        sta     $A3
        lda     $A4
        sbc     $A1
        sta     $A4
        bcs     LAD65
        dec     $A5
LAD65:  ora     $A3                             ; test remaining no. bytes to transfer
        ora     $A5                             ; if no more data to transfer then finish
        bne     LACF9                           ; else loop to transfer rest of file.
LAD6B:  rts

; ----------------------------------------------------------------------------
LAD6C:  dey                                     ; decrement attempt counter
        bne     LACF9                           ; if not tried 3 times then try again
        tay                                     ; else Y=A=status>0, return Z=0
        rts

; ----------------------------------------------------------------------------
; Release NMI
release_nmi_area:
        lda     $FDDD                           ; if NMI is not already ours
        bpl     nmi_area_released               ; then exit
        cmp     #$FF                            ; if Y=&FF no previous owner
        beq     nmi_area_released               ; then skip release call
        and     #$7F                            ; else Y = ID of previous NMI owner
        tay
        ldx     #$0B                            ; service call &0B = NMI release
        jsr     osbyte_rom_service_request      ; call OSBYTE &8F = issue service call
nmi_area_released:
        lda     #$00
        sta     $FDDD                           ; &00 = NMI not ours, no previous owner
        rts

; ----------------------------------------------------------------------------
; Claim NMI
claim_nmi_area:
        bit     $FDDD                           ; if NMI is already ours
        bmi     nmi_area_claimed                ; then exit
        lda     #$8F                            ; else OSBYTE &8F = issue service call
        ldx     #$0C                            ; service call &0C = claim NMI
        jsr     osbyte_yff                      ; call OSBYTE with Y=&FF
        tya                                     ; save ID of previous NMI owner
        ora     #$80                            ; set b7=1 to show we own the NMI
        sta     $FDDD                           ; set NMI ownership flag/previous owner
nmi_area_claimed:
        rts

; ----------------------------------------------------------------------------
; Select side 2 of current drive
LAD9B:  jsr     get_current_physical_drive      ; map current drive to physical drive
        tax                                     ; transfer to X for use as index
        jsr     select_ram_page_000             ; page in auxiliary workspace
        lda     LADB7,x                         ; look up side 2 of physical drive
        ldx     #$07                            ; loop for logical drives 7..0:
LADA7:  cmp     $FD00,x                         ; does this drive map to the drive we want?
        beq     LADB2                           ; if so then set current logical drive
        dex                                     ; else try next logical drive
        bpl     LADA7                           ; loop until all 8 logical drives tested
        jmp     LAA34                           ; if physical drive not mapped "Bad drive"

; ----------------------------------------------------------------------------
LADB2:  stx     current_drive                   ; else set current drive = logical drive
        jmp     select_ram_page_001             ; page in main workspace and exit

; ----------------------------------------------------------------------------
; Side 2 of physical drives 0..4
LADB7:  .byte   $02,$03,$FF,$FF,$05
; ----------------------------------------------------------------------------
; next three bytes more than 7, invalid physical drives
; Test write protect state of current drive
LADBC:  jsr     get_current_physical_drive      ; map current drive to physical drive
        jmp     LB905                           ; test write protect state of current drive

; ----------------------------------------------------------------------------
; Flush input buffer
LADC2:  jsr     push_registers_and_tuck_restoration_thunk; save AXY
        lda     #$0F                            ; OSBYTE &0F = flush selected buffer class
        ldx     #$01                            ; x = &01 flush input buffer only
        bne     osbyte_y00                      ; call OSBYTE with Y=&00
; unreachable code
        lda     #$81                            ; OSBYTE &81 = read key within time limit
        bne     osbyte_x00_y00
; unreachable code
        lda     #$C7                            ; OSBYTE &C7 = read/write *SPOOL handle
osbyte_x00_y00:
        ldx     #$00
; Call OSBYTE with Y=&00
osbyte_y00:
        ldy     #$00
        beq     call_osbyte
osbyte_select_output_stream_a:
        tax                                     ; Call OSBYTE &03 = specify output stream in A
osbyte_select_output_stream:
        lda     #$03                            ; Call OSBYTE &03 = specify output stream
        bne     call_osbyte
; Call OSBYTE &EC = read/write char dest status
osbyte_read_character_destination:
        lda     #$EC
        bne     osbyte_x00_yff
; unreachable code
        lda     #$C7                            ; OSBYTE &C7 = read/write *SPOOL handle
        bne     osbyte_x00_yff
; Call OSBYTE &EA = read Tube presence flag
osbyte_read_tube_presence:
        lda     #$EA
        bne     osbyte_x00_yff
; Call OSBYTE &A8 = get ext. vector table addr
osbyte_get_rom_pointer_table_address:
        lda     #$A8
        bne     osbyte_x00_yff
; Call OSBYTE &8F = issue service call
osbyte_rom_service_request:
        lda     #$8F
        bne     call_osbyte
; Call OSBYTE &FF = read/write startup options
osbyte_aff_x00_yff:
        lda     #$FF
; Call OSBYTE with X=&00, Y=&FF
osbyte_x00_yff:
        ldx     #$00
; Call OSBYTE with Y=&FF
osbyte_yff:
        ldy     #$FF
; Call OSBYTE
call_osbyte:
        jmp     osbyte

; ----------------------------------------------------------------------------
; Table of addresses of extended vector handlers
LADF9:  .addr   LFF1B                           ; FILEV,         &0212 =         &FF1B
        .addr   LFF1E                           ; ARGSV,         &0214 =         &FF1E
        .addr   LFF21                           ; BGETV,         &0216 =         &FF21
        .addr   LFF24                           ; BPUTV,         &0218 =         &FF24
        .addr   LFF27                           ; GBPBV,         &021A =         &FF27
        .addr   LFF2A                           ; FINDV,         &021C =         &FF2A
        .addr   LFF2D                           ; FSCV,          &021E =         &FF2D
; Table of action addresses for extended vector table
        .addr   chosfile                        ; E FILEV,       evt + &1B =     &A16E
        .addr   chosargs                        ; E ARGSV,       evt + &1E =     &9B62
        .addr   chosbget                        ; E BGETV,       evt + &21 =     &9CD1
        .addr   chosbput                        ; E BPUTV,       evt + &24 =     &9D9E
        .addr   chosgbpb                        ; E GBPBV,       evt + &27 =     &A2DC
        .addr   chosfind                        ; E FINDV,       evt + &2A =     &9961
        .addr   chosfsc                         ; E FSCV,        evt + &2D =     &975F
; ----------------------------------------------------------------------------
; Table of action addresses for OSFSC calls 0..11, low bytes
osfsc_routines_lsbs:
        .byte   $74,$07,$1F,$9B,$1F,$AD,$04,$16
        .byte   $1B,$0A,$18,$1F
; Table of action addresses for OSFSC calls 0..11, high bytes
osfsc_routines_msbs:
        .byte   $97,$98,$98,$98,$98,$98,$99,$99
        .byte   $99,$8C,$8C,$98
; Table of action addresses for OSARGS calls A=&FF,0,1, Y=0, low bytes
osargs_y0_routines_lsbs:
        .byte   $A1,$8B,$8E
; Table of action addresses for OSARGS calls A=&FF,0,1, Y=0, high bytes
osargs_y0_routines_msbs:
        .byte   $9B,$9B,$9B
; Table of action addresses for OSFILE calls &FF,0..6, low bytes
osfile_routines_lsbs:
        .byte   $EE,$9F,$AF,$BA,$C2,$CA,$D9,$E2
; Table of action addresses for OSFILE calls &FF,0..6, high bytes
osfile_routines_msbs:
        .byte   $A1,$A1,$A1,$A1,$A1,$A1,$A1,$A1
; Table of action addresses for OSGBPB calls 0..8, low bytes
osgbpb_routines_lsbs:
        .byte   $9B,$9C,$9C,$A4,$A4,$AC,$E1,$F0
        .byte   $FF
; Table of action addresses for OSGBPB calls 0..8, high bytes
osgbpb_routines_msbs:
        .byte   $A3,$A3,$A3,$A3,$A3,$A3,$A3,$A3
        .byte   $A3
; Table of microcode bytes for OSGBPB calls 0..8
osgbpb_routines_flags:
        .byte   $04,$02,$03,$06,$07,$04,$04,$04
        .byte   $04
; ----------------------------------------------------------------------------
; if C clear on entry, also print version number
; Print Challenger banner
print_CHALLENGER:
        php                                     ; save C on entry
        jsr     print_string_nterm              ; print "CHALLENGER "
        .byte   "CHALLENGER "

; ----------------------------------------------------------------------------
        nop
        plp                                     ; restore C
        bcs     LAE7A                           ; if C=0 on entry
        jsr     print_string_nterm              ; then print version number "2.00 "
        .byte   "2.00 "
; ----------------------------------------------------------------------------
        nop
LAE7A:  jsr     get_rom_status_byte             ; get Challenger unit type
        and     #$03                            ; extract bits 1,0
        ora     #$04                            ; add 4 to make 4..7
        tax                                     ; transfer to X to select message
        jsr     print_table_string              ; print boot or Challenger config descriptor
        jmp     L8469                           ; print newline and exit

; ----------------------------------------------------------------------------
; *FORMAT
format_command:
        jsr     gsinit_with_carry_clear         ; call GSINIT with C=0
        beq     LAEA4                           ; if no argument then skip
LAE8D:  jsr     gsread                          ; else call GSREAD
        bcc     LAE96                           ; type character of argument if present
        lda     #$0D                            ; else end of argument, type RETURN
        ldy     #$00                            ; offset = 0, indicate end of argument
LAE96:  sty     $B7                             ; save command line offset
        tay                                     ; transfer character of argument to Y
        ldx     #$00                            ; x=&00 insert into keyboard buffer
        lda     #$99                            ; OSBYTE &99 = insert char into buffer ck/ESC
        jsr     osbyte                          ; call OSBYTE
        ldy     $B7                             ; restore command line offset
        bne     LAE8D                           ; loop until argument inserted in buffer
LAEA4:  jsr     LA83F                           ; have A=0 returned on exit
        tsx
        stx     $B7                             ; set stack pointer to restore on restart
        stx     $B8                             ; set stack pointer to restore on exit
        jsr     L959C                           ; set high word of buffer address = &FFFF
; command restart point set at &AEE5
        jsr     LB01D                           ; set command restart to exit command
        jsr     LB2B2                           ; print "FORMAT" heading
LAEB5:  jsr     LB2DE                           ; clear row 23
LAEB8:  jsr     print_string_255term            ; print VDU sequence immediate
        .byte   $1F,$00,$13                     ; move cursor to (0,19)
        .byte   "Drive number (0-7) "


        .byte   $FF
; ----------------------------------------------------------------------------
        jsr     LB5CB                           ; get printable input character
        sec                                     ; convert to binary drive no. 0..7
        sbc     #$30                            ; is it less than ASCII "0"?
        bcc     LAEB8                           ; if so then input new drive number
        cmp     #$08                            ; is drive number in range?
        bcc     LAEE3                           ; if so then proceed
        jsr     LB73C                           ; else make a short beep
        bne     LAEB5                           ; and input new drive number
LAEE3:  sta     current_drive                   ; set as current volume
LAEE5:  ldx     #$AF                            ; point XY at *FORMAT entry point, &AEAF
        ldy     #$AE
        jsr     LB021                           ; set command restart action address
        jsr     print_string_255term            ; print VDU sequence immediate
        .byte   $1F,$00,$14                     ; move cursor to (0,20)
        .byte   "0=40, 1=80 tracks :  "


        .byte   $7F,$7F,$FF
; ----------------------------------------------------------------------------
        jsr     is_current_drive_ram_disk       ; set Z=1 iff current drive is a RAM disc
        bne     LAF12                           ; if so
        jmp     LAFB7                           ; then format RAM disc

; ----------------------------------------------------------------------------
LAF12:  jsr     LB5CB                           ; else get printable input character
        ldx     #$28                            ; set X = 40 tracks
        cmp     #$30                            ; if user typed 0
        beq     LAF21                           ; then proceed with 40 track format
        ldx     #$50                            ; else set X = 80 tracks
        cmp     #$31                            ; if user typed 1 then format 80 tracks
        bne     LAEE5                           ; else invalid character, prompt again
LAF21:  stx     L00C0                           ; set number of tracks to format
        ldx     #$50                            ; 80 tracks maximum can be formatted
        lda     $FDEA                           ; test double-stepping flag
        bpl     LAF2F                           ; if double-stepping is automatic
        and     #$80                            ; then discard last detected setting
        sta     $FDEA                           ; and force 1:1 stepping
LAF2F:  bit     $FDEA                           ; (else) test double-stepping flag
        bvc     LAF36                           ; if *OPT 8,1, forced double-stepping
        ldx     #$28                            ; then maximum format is 40 tracks.
LAF36:  cpx     L00C0                           ; compare max - chosen number of tracks
        bcs     LAF3F                           ; if max >= number chosen then proceed
        jsr     LB73C                           ; else make a short beep
        bne     LAEE5                           ; and input new format size
LAF3F:  jsr     LB2DE                           ; clear row 23
LAF42:  jsr     print_string_255term            ; print VDU sequence immediate
        .byte   $1F,$00,$15                     ; move cursor to (0,21)
        .byte   "Density (S/D) "

        .byte   $FF
; ----------------------------------------------------------------------------
        jsr     LB5CB                           ; get printable input character
        cmp     #$53                            ; is it capital S?
        beq     LAF96                           ; if so then format single density
        cmp     #$44                            ; else is it capital D?
        beq     LAF68                           ; if so then format double density
        jsr     LB73C                           ; else make a short beep
        jmp     LAF42                           ; and re-input

; ----------------------------------------------------------------------------
; Format double density
LAF68:  lda     $FDED                           ; set double density
        ora     #$40                            ; preserve automatic setting bit 7
        sta     $FDED                           ; set double density bit 6
        lda     #$12                            ; set 18 sectors per track
        sta     $FDEB
        jsr     LB65C                           ; prompt user and start format
        bcs     LAF8E                           ; if failed then prompt to repeat
        ldx     L00C0                           ; else get number of tracks on disc
        dex                                     ; all but one track available for volumes
        stx     $B0                             ; set multiplicand
        jsr     LB552                           ; multiply by no. sectors per track
        jsr     LB412                           ; set default volume sizes
        jsr     LB45E                           ; write volume catalogues
        jsr     LB477                           ; generate disc catalogue
        jsr     LACBD                           ; write disc catalogue L3
LAF8E:  jsr     LB035                           ; prompt to repeat
        beq     LAF68                           ; if user chooses repeat then format another
        jmp     LB028                           ; else exit command

; ----------------------------------------------------------------------------
; Format single density
LAF96:  lda     $FDED                           ; set single density
        and     #$80                            ; preserve automatic setting bit 7
        sta     $FDED                           ; clear double density bit 6
        lda     #$0A                            ; set 10 sectors per track
        sta     $FDEB
        jsr     LB65C                           ; prompt user and start format
        bcs     LAFAF                           ; if failed then prompt to repeat
        ldx     L00C0                           ; else get number of tracks on disc
        stx     $B0                             ; set multiplicand
        jsr     LB05B                           ; initialise volume catalogue by no. tracks
LAFAF:  jsr     LB035                           ; prompt to repeat
        beq     LAF96                           ; if user chooses repeat then format another
        jmp     LB028                           ; else exit command

; ----------------------------------------------------------------------------
; format RAM disc
LAFB7:  jsr     print_string_255term            ; print VDU sequence immediate
        .byte   $7F,$7F                         ; delete " :"
        .byte   ", 2=Max RAM disk "


        .byte   $FF
; ----------------------------------------------------------------------------
        jsr     LB5CB                           ; get printable input character
        sec                                     ; convert to binary option 0..2
        sbc     #$30
        bcc     LAFF2                           ; if invalid character then prompt again
        cmp     #$03                            ; else is option in range?
        bcs     LAFF2                           ; if not 0..2 then prompt again
        pha                                     ; else save option
        jsr     LB61B                           ; prompt to start format
        pla                                     ; restore option
        tax
        cpx     #$02                            ; if 40 or 80 track format selected
        bne     LAFEC                           ; then format to that size
        jsr     get_current_physical_drive      ; else map current volume to physical volume
        cmp     #$05                            ; if formatting drive 4
        bne     LAFEC                           ; then use option 2, size = &3F5 sectors
        inx                                     ; else use option 3, size = &3FF sectors
LAFEC:  jsr     LAFF8                           ; initialise RAM disc catalogue
        jmp     LB028                           ; exit command

; ----------------------------------------------------------------------------
LAFF2:  jsr     LB73C                           ; make a short beep
        jmp     LAEE5                           ; and input new volume size option

; ----------------------------------------------------------------------------
; Initialise RAM disc catalogue
LAFF8:  lda     LB015,x                         ; look up LSB of selected volume size
        sta     $C4
        lda     LB019,x                         ; and MSB
        sta     $C5
        jsr     claim_nmi_area                  ; claim NMI
        lda     #$00
        sta     $FDFE                           ; b6=0 RAM disc is single density
        sta     $FDED                           ; *OPT 6,10 single density
        ldy     #$00                            ; write catalogue to sector 0
        jsr     LB062                           ; initialise volume catalogue
        jmp     release_nmi_area                ; release NMI

; ----------------------------------------------------------------------------
; Table of single density volume sizes, X=0..3, low bytes
LB015:  .byte   $90,$20,$F5,$FF
; Table of single density volume sizes, X=0..3, high bytes
LB019:  .byte   $01,$03,$03,$03
; ----------------------------------------------------------------------------
; Set command restart to exit command
LB01D:  ldx     #$28                            ; point XY at command exit routine, &B028
        ldy     #$B0
; Set command restart action address
LB021:  stx     LFDE6
        sty     $FDE7
        rts

; ----------------------------------------------------------------------------
; Exit command
LB028:  ldx     $B8                             ; restore stack pointer from workspace
        txs
        jsr     LB650                           ; clear rows 20..22
        ldx     #$00                            ; set XY to screen coordinates (0,24)
        ldy     #$18
        jmp     LB2D1                           ; move cursor to (X,Y)

; ----------------------------------------------------------------------------
; Prompt to repeat
LB035:  jsr     print_string_255term            ; print VDU sequence immediate
        .byte   $1F,$08,$10                     ; move cursor to (8,16)
        .byte   "Format complete"

        .byte   $0D,$0A
        .byte   "Repeat? "
        .byte   $FF
; ----------------------------------------------------------------------------
        jsr     LB5EE                           ; get input character and acknowledge ESCAPE
        cmp     #$59                            ; return Z=1 iff user typed capital Y
        rts

; ----------------------------------------------------------------------------
; Initialise volume catalogue by no. tracks
LB05B:  jsr     LB552                           ; multiply by no. sectors per track
        ldy     #$00                            ; sector number = 0
        sty     $BA                             ; set track number = 0
; Initialise volume catalogue
LB062:  jsr     push_registers_and_tuck_restoration_thunk; save AXY
        sty     $BB                             ; set LSB absolute LBA = 2 * volume letter
        lda     #$00
        sta     $BA                             ; set MSB of absolute LBA = 0
        jsr     LB3EA                           ; clear catalogue sectors
        jsr     select_ram_page_003             ; page in catalogue sector 1
        lda     $C5                             ; set MSB volume size, boot option OFF
        sta     $FD06
        lda     $C4                             ; set LSB volume size
        sta     $FD07
        jmp     L9683                           ; write disc/volume catalogue L3

; ----------------------------------------------------------------------------
; *VERIFY
verify_command:
        jsr     LB741                           ; parse floppy volume spec from argument
        tsx
        stx     $B8                             ; set stack pointer to restore on exit
        stx     $B7                             ; set stack pointer to restore on restart
        jsr     LA83F                           ; have A=0 returned on exit
        jsr     L959C                           ; set high word of OSFILE load address = &FFFF
; command restart point set at &B0B6
        jsr     LB01D                           ; set command restart to exit command
        jsr     LB758                           ; set display MODE 7 and place heading
        jsr     print_string_255term            ; print VDU sequence immediate
        .byte   "V E R I F Y"

        .byte   $FF
; ----------------------------------------------------------------------------
        jsr     print_string_255term            ; print VDU sequence immediate
        .byte   $1F,$00,$10                     ; move cursor to (0,10)
        .byte   "Insert disk"

        .byte   $FF
; ----------------------------------------------------------------------------
        jsr     LB706                           ; prompt for keypress
        ldx     #$8C                            ; point XY at *VERIFY entry point, &B08C
        ldy     #$B0
        jsr     LB021                           ; set command restart action address
        lda     #$00
        sta     $FDE9                           ; data transfer call &00 = read data
        lda     #$80
        sta     $B9                             ; >0 disc operation is interruptible
        jsr     LABB5                           ; detect disc format/set sector address
        bit     $FDED                           ; test density flag
        bvs     LB0F4                           ; if double density then examine disc catalog
        jsr     L9632                           ; else load volume catalogue
        jsr     select_ram_page_003             ; page in catalogue sector 1
        lda     $FD06                           ; get boot option/top bits volume size
        and     #$03                            ; extract top bits volume size
        sta     $B1                             ; store MSB of dividend
        lda     $FD07                           ; get LSB volume size
        sta     $B0                             ; store LSB of dividend
        jsr     select_ram_page_001             ; page in main workspace
        lda     #$00
        sta     $B3                             ; clear MSB of divisor
        lda     $FDEB                           ; get number of sectors per track (= 10)
        sta     $B2                             ; store LSB of divisor
        jsr     LB35F                           ; divide word by word
        stx     L00C0                           ; store quotient as number of tracks
        jmp     LB0FF                           ; verify disc

; ----------------------------------------------------------------------------
LB0F4:  jsr     LACBA                           ; load disc catalogue L3
        jsr     select_ram_page_002             ; page in catalogue sector 0
        lda     $FD04                           ; get number of tracks on disc
        sta     L00C0                           ; store number of tracks to verify
; Verify disc
LB0FF:  jsr     select_ram_page_001             ; page in main workspace
        lda     #$00
        sta     $BA                             ; set starting track = 0
        clc                                     ; set C=0, no error
LB107:  php
        jsr     LB6B3                           ; print track number in table
        jsr     LB121                           ; verify track with display
        beq     LB113                           ; if hard error occurred
        plp                                     ; then set C=1, verify failed
        sec
        php
LB113:  inc     $BA                             ; increment track number
        lda     $BA                             ; compare track number - number of tracks
        cmp     L00C0
        bcc     LB107                           ; if less then verify next track
        plp                                     ; else test return code
        bcs     LB13A                           ; if error occurred print "ERROR"
        jmp     LB028                           ; else exit command.

; ----------------------------------------------------------------------------
; Verify track with display
LB121:  ldx     #$03                            ; make 3 attempts
        ldy     #$03                            ; erase next 3 characters
        jsr     LB72C                           ; erase Y characters ahead of cursor
LB128:  jsr     LB2EA                           ; poll for ESCAPE
        jsr     LBA05                           ; verify track
        beq     LB139                           ; if verify succeeded then exit
        lda     #$2E                            ; else print a dot
        jsr     oswrch                          ; call OSWRCH
        dex                                     ; decrement attempt counter
        bne     LB128                           ; if attempts remaining then try again
        dex                                     ; else X=&FF, Z=0 to indicate failure
LB139:  rts

; ----------------------------------------------------------------------------
LB13A:  jsr     LB60B                           ; print "ERROR"
        jmp     LB028                           ; and exit command.

; ----------------------------------------------------------------------------
; *VOLGEN
volgen_command:
        jsr     LB741                           ; parse floppy volume spec from argument
        jsr     LA83F                           ; have A=0 returned on exit
        tsx
        stx     $B8                             ; set stack pointer to restore on exit
        jsr     LA75F                           ; ensure *ENABLE active
        jsr     L959C                           ; set high word of OSFILE load address = &FFFF
        lda     #$80
        sta     $B9                             ; >0 disc operation is interruptible
        lda     #$00
        sta     $FDEC                           ; data area starts on track 0
        sta     $BA                             ; set track number = 0
        jsr     LB916                           ; seek logical track
        jsr     LB279                           ; ensure disc is double density
        lda     current_drive                   ; get current volume
        and     #$0F                            ; extract physical drive number, clear b7..4
        sta     current_drive                   ; set current volume letter to A
        jsr     LB758                           ; set display MODE 7 and place heading
        jsr     print_string_255term            ; print VDU sequence immediate
        .byte   "V O L G E N"

        .byte   $FF
; ----------------------------------------------------------------------------
        jsr     print_string_255term            ; print VDU sequence immediate
        .byte   $1F,$00,$04,$0D                 ; move cursor to (0,4)
        .byte   "Vol  Size   (K) "

        .byte   $FF
; ----------------------------------------------------------------------------
        lda     current_drive                   ; get current volume
        jsr     L8EAD                           ; print " Drive " plus volume spec in A
        jsr     print_string_255term            ; print VDU sequence immediate
        .byte   $1F,$00,$0F                     ; move cursor to (0,15)
        .byte   "Free"
        .byte   $FF
; ----------------------------------------------------------------------------
        jsr     LB4D2                           ; read volume sizes and allocations
        lda     #$07                            ; 8 volumes to list
        sta     $C1                             ; set as counter
LB1A7:  jsr     LB3BC                           ; print tabulated volume size
        dec     $C1                             ; loop until 8 volumes listed
        bpl     LB1A7
; command restart point set at &B255
LB1AE:  jsr     LB01D                           ; set command restart to exit command
LB1B1:  jsr     LB56D                           ; sum volume sizes
        ldx     #$05                            ; move cursor to (5,15)
        ldy     #$0F
        jsr     LB2D1
        jsr     LB380                           ; print sector count as kilobytes
        jmp     LB1C4

; ----------------------------------------------------------------------------
LB1C1:  jsr     LB73C                           ; make a short beep
LB1C4:  jsr     print_string_255term            ; print VDU sequence immediate
        .byte   $1F,$00,$17                     ; move cursor to (0,23)
        .byte   "VOLUME :      (W to configure)"



        .byte   $1F,$08,$17,$FF                 ; move cursor to (8,23)
; ----------------------------------------------------------------------------
        jsr     LB5EE                           ; get input character and acknowledge ESCAPE
        cmp     #$57                            ; if user typed capital W
        bne     LB1F6
        jmp     LB255                           ; then generate volumes and exit

; ----------------------------------------------------------------------------
LB1F6:  sec                                     ; else convert letter A..H to volume index 0..7
        sbc     #$41
        bcc     LB1C1                           ; if out of range then display error
        cmp     #$08
        bcs     LB1C1
        sta     $C1                             ; else set volume index
        adc     #$41                            ; convert back to letter A..H, print it
        jsr     oswrch                          ; call OSWRCH
        lda     #$20                            ; print a space
        jsr     oswrch                          ; call OSWRCH
        jsr     LB305                           ; input number up to 3 digits
        bcs     LB1C4                           ; if invalid input then prompt again
        lda     L00AA                           ; else test entered volume size
        ora     $AB
        bne     LB223                           ; if >0 then set volume size
        lda     $C1                             ; else RETURN pressed, delete volume
        beq     LB1C1                           ; volume A can't be deleted, prompt again
        jsr     LB2A2                           ; else clear volume size
        jsr     LB3BC                           ; print tabulated volume size
        jmp     LB1B1                           ; update free space and take next command.

; ----------------------------------------------------------------------------
; Fit volume request
LB223:  lda     $AB                             ; test MSB of entered number
        cmp     #$04                            ; if <256 KiB requested then continue
        bcs     LB1C1                           ; else display error and prompt again
        jsr     LB2A2                           ; clear volume size
        jsr     LB56D                           ; sum volume sizes
        lda     L00A8                           ; compare free space - request
        cmp     L00AA
        lda     $A9
        sbc     $AB
        bcs     LB241                           ; if request fits then assign request
        lda     L00A8                           ; else set request = free space on disc
        sta     L00AA
        lda     $A9
        sta     $AB
LB241:  lda     $C1                             ; get volume index
        asl     a                               ; double it
        tay                                     ; transfer to Y as index
        lda     $AB                             ; set assigned volume size
        sta     $FDD5,y                         ; = min(request, free_space)
        lda     L00AA
        sta     $FDD6,y
        jsr     LB3BC                           ; print tabulated volume size
        jmp     LB1B1                           ; update free space display and take input.

; ----------------------------------------------------------------------------
; Generate volumes
LB255:  ldx     #$AE                            ; point XY at *VOLGEN entry point, &B1AE
        ldy     #$B1
        jsr     LB021                           ; set command restart action address
        jsr     LB706                           ; prompt for keypress
        jsr     LB279                           ; ensure disc is double density
        jsr     LB6D3                           ; ensure disc is write enabled
        beq     LB26A                           ; if write enabled then proceed
        jmp     LB1AE                           ; if write protected then try again

; ----------------------------------------------------------------------------
LB26A:  jsr     LB3EA                           ; clear catalogue sectors
        jsr     LB45E                           ; write volume catalogues
        jsr     LB477                           ; generate disc catalogue
        jsr     LACBD                           ; write disc catalogue L3
        jmp     LB028                           ; exit command

; ----------------------------------------------------------------------------
LB279:  jsr     LAC55                           ; ensure disc is formatted
        bit     $FDED                           ; test density flag
        bvs     LB2A1                           ; if single density
        jsr     print_string_2_nterm            ; then raise "must be double density" error.
        .byte   $C9
        .byte   "Disk must be double density"



; ----------------------------------------------------------------------------
        brk
LB2A1:  rts

; ----------------------------------------------------------------------------
; Clear volume size
LB2A2:  lda     $C1                             ; get volume index
        asl     a                               ; double to get offset
        tay
        jsr     select_ram_page_000             ; page in auxiliary workspace
        lda     #$00
        sta     $FDD5,y                         ; set size of selected volume = 0
        sta     $FDD6,y
        rts

; ----------------------------------------------------------------------------
; Print "FORMAT" heading
LB2B2:  jsr     LB758                           ; set display MODE 7 and place heading
        jsr     print_string_255term            ; print VDU sequence immediate
        .byte   "F O R M A T"

        .byte   $FF
; ----------------------------------------------------------------------------
LB2C4:  rts

; ----------------------------------------------------------------------------
; Set display MODE 7
LB2C5:  lda     #$07
        pha
        lda     #$16
        jsr     oswrch
        pla
        jmp     oswrch

; ----------------------------------------------------------------------------
; Move cursor to (X,Y)
LB2D1:  lda     #$1F                            ; issue VDU 31 = PRINT TAB(X,Y)
        jsr     oswrch
        txa                                     ; send X coordinate to OSWRCH, 0=leftmost col
        jsr     oswrch
        tya                                     ; send Y coordinate to OSWRCH, 0=top row
        jmp     oswrch

; ----------------------------------------------------------------------------
; Clear row 23
LB2DE:  ldx     #$00                            ; move cursor to (0,23)
        ldy     #$17
        jsr     LB2D1                           ; move cursor to (X,Y)
        ldy     #$28                            ; set Y = 40, width of one MODE 7 row:
        jmp     print_N_spaces_without_spool    ; print number of spaces in Y

; ----------------------------------------------------------------------------
; Poll for ESCAPE
LB2EA:  bit     $FF                             ; if ESCAPE was pressed
        bpl     LB2C4
        jsr     acknowledge_escape              ; then acknowledge ESCAPE condition
        jsr     release_nmi_area                ; release NMI
        ldx     $B7                             ; restore stack pointer from &B7
        txs
        jmp     (LFDE6)                         ; and restart command

; ----------------------------------------------------------------------------
; Move cursor to table row in &C1
LB2FA:  ldx     #$01                            ; (1,6+?&C1)
        clc
        lda     $C1
        adc     #$06
        tay
        jmp     LB2D1

; ----------------------------------------------------------------------------
; Input hex number up to 3 digits
LB305:  ldy     #$00                            ; start with no characters in line buffer
        sty     L00AA                           ; clear accumulator
        sty     $AB
LB30B:  jsr     LB5EE                           ; get input character and acknowledge ESCAPE
        cmp     #$0D                            ; if user pressed RETURN
        bne     LB314
        clc                                     ; then return C=0
        rts

; ----------------------------------------------------------------------------
LB314:  cmp     #$7F                            ; else if user pressed DELETE
        bne     LB32D
        tya                                     ; then test number of characters entered
        bne     LB31D                           ; if no characters on line
        sec                                     ; then return C=1
        rts

; ----------------------------------------------------------------------------
LB31D:  jsr     LB348                           ; else backspace and erase last character
        dey                                     ; decrement number of characters entered
        ldx     #$04                            ; else 4 places to shift by:
LB323:  lsr     $AB                             ; shift MSB of accumulator right
        ror     L00AA                           ; shift old b0 into LSB of accumulator
        dex                                     ; loop until 4 bits shifted
        bne     LB323                           ; removing last digit entered
        jmp     LB30B                           ; and loop

; ----------------------------------------------------------------------------
LB32D:  cpy     #$03                            ; if 3 characters already entered
        beq     LB30B                           ; then ignore latest, loop to read DEL/CR
        jsr     xtoi                            ; else convert ASCII hex digit to binary
        jsr     print_hex_nybble                ; print hex nibble
        ldx     #$04                            ; 4 places to shift by:
LB339:  asl     L00AA                           ; shift LSB of accumulator left
        rol     $AB                             ; shift old b7 into MSB of accumulator
        dex                                     ; loop until 4 bits shifted
        bne     LB339                           ; now b3..0 of &AA = &0
        ora     L00AA                           ; apply LSB to nibble typed by user
        sta     L00AA                           ; update LSB of accumulator
        iny                                     ; increment number of digits typed
        jmp     LB30B                           ; loop to input more digits

; ----------------------------------------------------------------------------
; Backspace and erase characters
LB348:  jsr     LB350                           ; print DEL
        lda     #$20                            ; print space:
        jsr     oswrch
; Print DEL
LB350:  lda     #$7F                            ; set A = ASCII value of DEL character
        jmp     oswrch                          ; call OSWRCH to print it and exit.

; ----------------------------------------------------------------------------
; unreachable code
        sec                                     ; Convert ASCII digit to binary and validate
        sbc     #$30                            ; C=1 iff invalid
        bcc     LB35D
        cmp     #$0A
        rts

; ----------------------------------------------------------------------------
; unreachable code
LB35D:  sec
        rts

; ----------------------------------------------------------------------------
; Divide word by word
LB35F:  ldx     #$00                            ; initialise quotient = 0:
LB361:  lda     $B1                             ; Compare dividend - divisor
        cmp     $B3
        bcc     LB37F
        bne     LB36F
        lda     $B0
        cmp     $B2
        bcc     LB37F                           ; if dividend >= divisor
LB36F:  lda     $B0                             ; then subtract dividend - divisor
        sbc     $B2
        sta     $B0                             ; ultimately leaving remainder
        lda     $B1
        sbc     $B3
        sta     $B1
        inx                                     ; increment quotient in X
        jmp     LB361                           ; and loop as remainder >= 0

; ----------------------------------------------------------------------------
LB37F:  rts

; ----------------------------------------------------------------------------
; Print sector count as kilobytes
LB380:  jsr     LA7E9                           ; print sector count
        ldy     #$02                            ; print 2 spaces
        jsr     print_N_spaces_without_spool
        lsr     $A9                             ; divide sector count by 4 to get kilobytes
        ror     L00A8
        lsr     $A9
        ror     L00A8
        lda     L00A8
        jsr     LB39D                           ; convert byte to three decimal digits
        jsr     LA7E9                           ; print space-padded hex word
        lda     #$4B                            ; print "K"
        jmp     oswrch

; ----------------------------------------------------------------------------
; Convert byte to three decimal digits
LB39D:  sec
        ldx     #$FF
        stx     $A9
LB3A2:  inc     $A9
        sbc     #$64
        bcs     LB3A2
        adc     #$64
LB3AA:  inx
        sbc     #$0A
        bcs     LB3AA
        adc     #$0A
        sta     L00A8
        txa
        jsr     asl_x4
        ora     L00A8
        sta     L00A8
        rts

; ----------------------------------------------------------------------------
; Print tabulated volume size
LB3BC:  jsr     LB2FA                           ; move cursor to table row in &C1
        clc
        lda     $C1                             ; get volume letter
        adc     #$41                            ; convert to ASCII letter A..H
        jsr     oswrch                          ; call OSWRCH
        ldy     #$0D                            ; erase next 13 characters
        jsr     LB72C                           ; erase Y characters ahead of cursor
        lda     $C1                             ; get volume index
        asl     a                               ; double it
        tay                                     ; transfer to Y as index
        jsr     select_ram_page_000             ; page in auxiliary workspace
        lda     $FDD5,y                         ; get MSB volume size
        sta     $A9                             ; store it in zero page
        lda     $FDD6,y                         ; get LSB volume size
        sta     L00A8                           ; store it in zero page
        ora     $A9                             ; test volume size
        beq     LB3E7                           ; if =0 then leave row blank
        jsr     print_2_spaces_without_spool    ; else print two spaces
        jsr     LB380                           ; print sector count as kilobytes
LB3E7:  jmp     select_ram_page_001             ; page in main workspace

; ----------------------------------------------------------------------------
; Clear catalogue sectors
LB3EA:  lda     #$00
        tay
        jsr     select_ram_page_002             ; page in catalogue sector 0
LB3F0:  sta     $FD00,y
        iny
        bne     LB3F0
        jsr     select_ram_page_003             ; page in catalogue sector 1
LB3F9:  sta     $FD00,y
        iny
        bne     LB3F9
        jmp     select_ram_page_001             ; page in main workspace

; ----------------------------------------------------------------------------
; Clear volume sizes
LB402:  jsr     select_ram_page_000             ; page in auxiliary workspace
        lda     #$00
        ldy     #$0F                            ; 8 words to clear for volumes A..H
LB409:  sta     $FDD5,y                         ; set assigned size of volume to &0000
        dey
        bpl     LB409                           ; loop until all words cleared
        jmp     select_ram_page_001             ; page in main workspace

; ----------------------------------------------------------------------------
; Set default volume sizes
LB412:  jsr     select_ram_page_001             ; page in main workspace
        lda     $C4                             ; set free space = sectors avail. for volumes
        sta     $B2
        lda     $C5
        sta     $B3
        lda     $FDEB                           ; get number of sectors per track
        sta     $B0
        lda     #$00                            ; clear MSB of word
        ldx     #$04                            ; 4 places to shift, multiply by 16:
LB426:  asl     $B0                             ; shift word one place left
        rol     a
        dex                                     ; repeat 4 times
        bne     LB426                           ; max. 16 tracks = 72 KiB per volume
        sta     $B1
        jsr     select_ram_page_000             ; page in auxiliary workspace
        ldy     #$00
LB433:  jsr     LB547                           ; compare requested allocation with free space
        bcc     LB440                           ; if it fits then set allocation = request
        lda     $B3                             ; else set request = free space
        sta     $B1
        lda     $B2
        sta     $B0
LB440:  lda     $B1                             ; set allocation = request
        sta     $FDD5,y
        lda     $B0
        sta     $FDD6,y
        sec                                     ; subtract LSB request from free space
        lda     $B2
        sbc     $B0
        sta     $B2
        lda     $B3                             ; subtract MSB request from free space
        sbc     $B1
        sta     $B3
        iny                                     ; add 2 to offset, point to next volume
        iny
        cpy     #$10                            ; loop until volumes A..H set.
        bne     LB433
        rts

; ----------------------------------------------------------------------------
; Write volume catalogues
LB45E:  ldy     #$00                            ; start at volume A
LB460:  jsr     select_ram_page_000             ; page in auxiliary workspace
        lda     $FDD5,y                         ; copy MSB sector count
        sta     $C5                             ; to size of volume to be created
        lda     $FDD6,y                         ; and copy LSB
        sta     $C4
        jsr     LB062                           ; initialise volume catalogue
        iny                                     ; advance volume letter by 1/sector by 2
        iny
        cpy     #$10                            ; have we initialised 8 volumes/16 sectors?
        bne     LB460                           ; if not then loop to init all volumes
        rts

; ----------------------------------------------------------------------------
; Generate disc catalogue
LB477:  jsr     select_ram_page_002             ; page in catalogue sector 0
        lda     #$20                            ; set version/configuration number = &20
        sta     $FD00                           ; indicating that sector count is big-endian
        lda     #$12                            ; 18 sectors per track
        sta     $FD03
        ldy     L00C0                           ; set number of tracks on disc
        sty     $FD04
        lda     #$00                            ; mystery field (MSB no. tracks?), always 0
        sta     $FD05
        jsr     LB5AE
        lda     L00A8
        sta     $FD02                           ; store LSB number of sectors on disc
        lda     $A9
        sta     $FD01                           ; store MSB
        ldy     #$01
        sty     $BB                             ; data area starts on track 1
        dey
LB4A0:  jsr     select_ram_page_000             ; page in auxiliary workspace
        tya                                     ; save 2 * volume letter
        pha
        lda     $FDD5,y                         ; get MSB no. sectors in volume's data area
        sta     $B1                             ; store MSB dividend
        lda     $FDD6,y                         ; get LSB no. sectors in volume's data area
        sta     $B0                             ; store LSB dividend
        ora     $B1                             ; test number of requested sectors
        beq     LB4C9                           ; if zero then volume absent, assign no tracks
        jsr     select_ram_page_002
        lda     $BB                             ; else set starting track of volume data area
        sta     $FD08,y
        lda     #$00                            ; clear next byte (MSB track number?)
        sta     $FD09,y
        jsr     LB597                           ; generate track multiple of at least req.
        clc
        tya
        adc     $BB                             ; add number of tracks in Y to starting track
        sta     $BB
LB4C9:  pla                                     ; skip to next volume entry
        tay
        iny
        iny
        cpy     #$10                            ; loop until tracks assigned to 8 volumes
        bne     LB4A0
        rts

; ----------------------------------------------------------------------------
; Read volume sizes and allocations
LB4D2:  jsr     LB52E                           ; copy volume allocations to workspace
        jsr     select_ram_page_002             ; page in catalogue sector 0
        sec
        lda     $FD02                           ; get LSB number of sectors on disc
        sbc     #$12                            ; subtract 18 sectors of catalogue track
        sta     $C4                             ; set LSB total sectors allocated to volumes
        lda     $FD01                           ; borrow from MSB
        sbc     #$00
        sta     $C5
        lda     $FD04                           ; get number of tracks on disc
        sta     L00C0
        jsr     LB402                           ; clear volume sizes
        ldy     #$0E                            ; start at volume H, cat. sector 14:
; Read volume sizes from the catalogue of each volume.
LB4F1:  jsr     select_ram_page_000             ; page in auxiliary workspace
        tya                                     ; y=2*volume
        lsr     a                               ; A=volume
        tax                                     ; transfer to X for use as index
        lda     $FDCD,x                         ; look up number of tracks in volume
        beq     LB529                           ; if volume absent then skip
        sty     $BB                             ; else set sector number = 2*volume
        inc     $BB                             ; add 1, point to 2nd sector of cat.
        jsr     L96A5                           ; set data pointer to &0200
        lda     #$01                            ; 256 bytes to transfer
        sta     $A1
        lda     #$00
        sta     $A0
        lda     #$80                            ; data transfer call &80 = read data to JIM
        sta     $FDE9                           ; set data transfer call number
        jsr     LBA18                           ; transfer data L2
        jsr     select_ram_page_002             ; page in catalogue sector 0
        lda     $FD06                           ; get boot option/top bits volume size
        and     #$03                            ; extract MSB volume size
        pha
        lda     $FD07                           ; get LSB volume size from catalogue
        jsr     select_ram_page_000             ; page in auxiliary workspace
        sta     $FDD6,y                         ; set as LSB size of this volume
        pla
        sta     $FDD5,y                         ; set as MSB size of this volume
LB529:  dey                                     ; proceed to previous volume
        dey                                     ; whose catalogue sector no. is two less
        bpl     LB4F1                           ; loop until all eight volumes read
        rts

; ----------------------------------------------------------------------------
; Copy volume allocations to workspace
LB52E:  jsr     LACBA                           ; load disc catalogue L3
        ldy     #$0E                            ; start at sector offset 14, volume H
        ldx     #$07                            ; start at workspace offset 7, volume H
LB535:  jsr     select_ram_page_002             ; page in catalogue sector 0
        lda     $FD08,y                         ; get first track of data area of volume
        jsr     select_ram_page_000             ; page in auxiliary workspace
        sta     $FDCD,x                         ; store in workspace
        dey                                     ; skip mystery field in sector
        dey                                     ; decrement offset, work back from H to A
        dex                                     ; decrement workspace offset
        bpl     LB535                           ; loop until 8 track numbers copied
        rts

; ----------------------------------------------------------------------------
; Compare requested allocation with limit
LB547:  lda     $B1
        cmp     $B3
        bne     LB551
        lda     $B0
        cmp     $B2
LB551:  rts

; ----------------------------------------------------------------------------
; Multiply by no. sectors per track
LB552:  jsr     select_ram_page_001             ; page in main workspace
        ldy     $FDEB                           ; get number of sectors per track
        lda     #$00                            ; clear product
        sta     $C4
        sta     $C5
LB55E:  clc                                     ; add number of tracks to product
        lda     $B0
        adc     $C4
        sta     $C4
        bcc     LB569                           ; carry out to high byte
        inc     $C5
LB569:  dey                                     ; loop until all sectors per track added
        bne     LB55E
        rts

; ----------------------------------------------------------------------------
; Sum volume sizes
LB56D:  ldx     #$00                            ; clear offset = 0, point to volume A
        stx     $B2                             ; clear total
LB571:  jsr     select_ram_page_000             ; page in auxiliary workspace
        lda     $FDD6,x                         ; get LSB requested size of volume at X
        sta     $B0                             ; set LSB current request
        lda     $FDD5,x                         ; get MSB requested size of volume at X
        sta     $B1                             ; get MSB current request
        jsr     LB597                           ; generate track multiple of at least req.
        clc
        tya                                     ; a = track count for this volume
        adc     $B2                             ; add to total allocations
        sta     $B2
        inx                                     ; add 2 to offset
        inx
        cpx     #$10                            ; loop until 8 allocations added
        bne     LB571
        sec                                     ; subtract disc size - total allocations
        lda     L00C0
        sbc     $B2
        tay                                     ; =disc space free
        dey                                     ; subtract 1 for catalogue track
        jmp     LB5AE                           ; multiply track count by 18

; ----------------------------------------------------------------------------
; Generate track multiple of at least req.
LB597:  ldy     #$00
        sty     L00A8                           ; clear LSB sector count
        sty     $A9                             ; clear MSB sector count
LB59D:  lda     L00A8                           ; compare sector count - request
        cmp     $B0
        lda     $A9
        sbc     $B1
        bcs     LB5AD                           ; if sector count >= request then return it
        iny                                     ; else add one track to track count
        jsr     LB5BE                           ; add 18 sectors to sector count
        bcc     LB59D                           ; and loop (always)
LB5AD:  rts

; ----------------------------------------------------------------------------
; Multiply track count by 18
LB5AE:  lda     #$00
        sta     L00A8                           ; clear LSB sector count
        sta     $A9                             ; clear MSB sector count
        iny                                     ; pre-increment track count to exit on 0:
LB5B5:  dey                                     ; have we added all tracks?
        beq     LB5BD                           ; if so then return sector count
        jsr     LB5BE                           ; else add 18 sectors to sector count
        bcc     LB5B5                           ; and loop (always)
LB5BD:  rts

; ----------------------------------------------------------------------------
; Add 18 sectors to sector count
LB5BE:  clc
        lda     L00A8
        adc     #$12
        sta     L00A8
        bcc     LB5C9                           ; carry out to MSB
        inc     $A9
LB5C9:  clc
        rts

; ----------------------------------------------------------------------------
; Get printable input character
LB5CB:  jsr     LB5EE                           ; get input character and acknowledge ESCAPE
        cmp     #$30                            ; is ASCII value less than that of "0"?
        bcc     LB5CB                           ; if so then discard, get another character
        cmp     #$5B                            ; else is ASCII value higher than "Z"?
        bcs     LB5CB                           ; if so then discard, get another character
        pha                                     ; else save input character
        jsr     oswrch                          ; call OSWRCH to print it:
LB5DA:  jsr     LB5EE                           ; get input character and acknowledge ESCAPE
        cmp     #$0D                            ; is it CR?
        bne     LB5E3                           ; if not then test for DEL
        pla                                     ; else restore first character and exit
        rts

; ----------------------------------------------------------------------------
LB5E3:  cmp     #$7F                            ; was DELETE key pressed?
        bne     LB5DA                           ; if neither CR or DEL then get another
        pla                                     ; else discard first character
        jsr     LB348                           ; backspace and erase characters
        jmp     LB5CB                           ; and loop to get another character.

; ----------------------------------------------------------------------------
; Get input character and acknowledge ESCAPE
LB5EE:  jsr     osrdch                          ; call OSRDCH
        bcs     LB5F4                           ; if C=1 then error occurred, test err. code
        rts                                     ; else return character in A

; ----------------------------------------------------------------------------
LB5F4:  cmp     #$1B                            ; test if error code from OSRDCH is &1B
        beq     LB5F9                           ; if so then ESCAPE was pressed
        rts                                     ; else return

; ----------------------------------------------------------------------------
LB5F9:  jsr     select_ram_page_001             ; page in main workspace
        jsr     acknowledge_escape              ; acknowledge ESCAPE condition
        jsr     release_nmi_area                ; release NMI
        jsr     LB650                           ; clear rows 20..22
        ldx     $B7                             ; restore stack pointer from &B7
        txs
        jmp     (LFDE6)                         ; jump to action address

; ----------------------------------------------------------------------------
; Print "ERROR"
LB60B:  jsr     LB650                           ; clear rows 20..22
        jsr     print_string_255term            ; print VDU sequence immediate
        .byte   $1F,$15,$17                     ; move cursor to (21,23)
        .byte   "ERROR"
        .byte   $FF
; ----------------------------------------------------------------------------
        rts

; ----------------------------------------------------------------------------
; Prompt to start format
LB61B:  jsr     print_string_255term            ; print VDU sequence immediate
        .byte   $1C,$00,$0D                     ; define text window (0,13)..(39,4)
        .byte   "'"
        .byte   $04,$0C,$1A,$FF
; ----------------------------------------------------------------------------
        jsr     LB650                           ; clear rows 20..22
        jsr     print_string_255term            ; print VDU sequence immediate
        .byte   $1F,$00,$10                     ; move cursor to (0,16)
        .byte   "Press F(ret) to start  "


        .byte   $7F,$FF                         ; backspace and erase character
; ----------------------------------------------------------------------------
        jsr     LB5CB                           ; get printable input character
        cmp     #$46                            ; is it capital F?
        bne     LB61B                           ; if not then reprint heading and try again
        rts

; ----------------------------------------------------------------------------
; Clear rows 20..22
LB650:  ldx     #$00                            ; move cursor to (0,20)
        ldy     #$10
        jsr     LB2D1                           ; move cursor to (X,Y)
        ldy     #$78                            ; print 120 spaces and exit
        jmp     print_N_spaces_without_spool    ; print X spaces

; ----------------------------------------------------------------------------
; Prompt user and start format
LB65C:  jsr     LB61B                           ; prompt to start format
        jsr     LB6D3                           ; ensure disc is write enabled
        bne     LB65C                           ; if write protected then try again
        jsr     LB650                           ; else clear rows 20..22
        lda     #$80
        sta     $B9                             ; >0 disc operation is interruptible
        lda     #$00
        sta     $BA                             ; set track number = 0
        sta     $BB                             ; set running track skew counter = 0
        jsr     LBB18                           ; create ID table and format track
LB674:  lda     #$03                            ; make three attempts (outer)
        sta     $BF                             ; set attempt counter
LB678:  jsr     LB2EA                           ; poll for ESCAPE
        jsr     LB6B3                           ; print track number in table
        ldy     #$03                            ; erase next 3 characters
        jsr     LB72C                           ; erase Y characters ahead of cursor
        jsr     LBB18                           ; create ID table and format track
        jsr     LB121                           ; verify track with display
        beq     LB694                           ; if succeeded then format next track
        dec     $BF                             ; else decrement attempt counter
        bne     LB678                           ; if attempts remaining then try again
        jsr     LB60B                           ; else print "ERROR"
        sec                                     ; set C=1, format failed
        rts

; ----------------------------------------------------------------------------
LB694:  lda     #$FE                            ; implement track skew
        bit     $FDED                           ; a=-2 (in two's complement)
        bvc     LB69C                           ; if double density
        asl     a                               ; then A=-4:
LB69C:  clc                                     ; subtract 2 or 4 from first R of track
        adc     $BB
        bcs     LB6A4                           ; if it underflows
        adc     $FDEB                           ; then add number of sectors per track
LB6A4:  sta     $BB                             ; set first sector number of track
        inc     $BA                             ; increment track number
        lda     $BA
        cmp     L00C0                           ; compare with total tracks
        bcs     LB6B1                           ; if >= total tracks then format complete
        jmp     LB674                           ; else loop to format next track

; ----------------------------------------------------------------------------
LB6B1:  clc                                     ; set C=0, format succeeded.
        rts

; ----------------------------------------------------------------------------
; Print track number in table
LB6B3:  ldx     #$00                            ; set column to 0
        ldy     $BA                             ; copy track number as row number
LB6B7:  sec
        tya
        sbc     #$0A                            ; subtract 10 from row number
        bcc     LB6C5                           ; if underflow then keep current row
        tay                                     ; else set as new row number
        clc                                     ; add 10 to column
        txa
        adc     #$05
        tax
        bcc     LB6B7                           ; and loop until row < 0
LB6C5:  adc     #$0E                            ; c=0, add 14 to negative remainder
        tay                                     ; set Y = row 4..13
        jsr     LB2D1                           ; move cursor to (X,Y)
        lda     $BA                             ; get track number
        jsr     LB39D                           ; convert byte to three decimal digits
        jmp     LA7F1                           ; print space-padded hex byte

; ----------------------------------------------------------------------------
; Ensure disc is write enabled
LB6D3:  jsr     LADBC                           ; test write protect state of current drive
        beq     LB705                           ; if write enabled then return
        jsr     print_string_255term            ; else print VDU sequence immediate
        .byte   $1F,$00,$10                     ; move cursor to (0,16)
        .byte   "Disk R/O...remove write protect"



        .byte   $0D,$0A,$FF
; ----------------------------------------------------------------------------
        jsr     LB706                           ; prompt for keypress
        lda     #$FF                            ; return Z=0
LB705:  rts

; ----------------------------------------------------------------------------
; Prompt for keypress
LB706:  jsr     print_string_255term            ; print VDU sequence immediate
        .byte   $1F,$04,$11                     ; move cursor to (4,17)
        .byte   "Press any key to continue"



        .byte   $FF
; ----------------------------------------------------------------------------
        jsr     LB5EE                           ; get input character and acknowledge ESCAPE
        jmp     LB650                           ; clear rows 20..22 and exit

; ----------------------------------------------------------------------------
; Erase Y characters ahead of cursor
LB72C:  tya
        pha
        jsr     print_N_spaces_without_spool    ; print number of spaces in Y
        pla
        tay
LB733:  lda     #$7F                            ; print number of DELs in Y
        jsr     oswrch
        dey
        bne     LB733
        rts

; ----------------------------------------------------------------------------
; Make a short beep
LB73C:  lda     #$07                            ; BEL = make a short beep
        jmp     oswrch                          ; call OSWRCH

; ----------------------------------------------------------------------------
; Parse floppy volume spec from argument
LB741:  jsr     LAA16                           ; parse volume spec from argument
        jsr     is_current_drive_ram_disk       ; set Z=1 iff current drive is a RAM disc
        bne     LB757                           ; if so
        jmp     LAAD6                           ; then raise "Bad drive" error.

; ----------------------------------------------------------------------------
; Z set if RAM disk
; Set Z=1 iff current drive is a RAM disc
is_current_drive_ram_disk:
        jsr     get_current_physical_drive      ; map current volume to physical volume
        and     #$07                            ; mask drive no in b2..0 mask off volume letter
        cmp     #$04                            ; if physical drive = 4
        beq     LB757                           ; then return Z=1
        cmp     #$05                            ; else return Z=1 if physical drive = 5.
LB757:  rts

; ----------------------------------------------------------------------------
; set display MODE 7 and place heading
LB758:  jsr     LB2C5                           ; set display MODE 7
        ldy     #$00
        iny
        ldx     #$0D                            ; set X=13, Y=1
        jsr     LB2D1                           ; move cursor to (X,Y)
        cpy     #$03
        rts

; ----------------------------------------------------------------------------
; *FDCSTAT
fdcstat_command:
        tsx                                     ; have A=0 returned on exit
        lda     #$00
        sta     $0105,x
        jsr     print_string_255term            ; print VDU sequence immediate
        .byte   $0D,$0A
        .byte   "WD 1770 status : "


        .byte   $FF
; ----------------------------------------------------------------------------
        lda     $FDF3                           ; get status of last command
        jsr     print_hex_byte                  ; print hex byte
        jmp     L8469                           ; print newline

; ----------------------------------------------------------------------------
osword_7f_read_data_or_deleted_data:
        ldx     #$00                            ; &13 Read data / &17 Read data & deleted data
        .byte   $AD                             ; &0B Write data                 B78F=LDX #&01
osword_7f_write_data:
        ldx     #$01
        lda     $02A2                           ; B792=LDX #&02
        .byte   $AD                             ; &0F Write deleted data         B795=LDX #&03
osword_7f_write_deleted_data:
        ldx     #$03
        .byte   $AD                             ; &1F Verify data                B798=LDX #&04
osword_7f_verify_data:
        ldx     #$04
        stx     $FDE9                           ; set data transfer call number
        lda     ($B0),y                         ; get 2nd parameter = starting sector number
        sta     $BB                             ; set starting sector
        jsr     is_current_drive_ram_disk       ; set Z=1 iff current drive is a RAM disc
        bne     LB7B9                           ; if so
        ldx     #$0A                            ; then convert CS address per Acorn DFS to LBA
        ldy     #$00                            ; x = 10 sectors per track, Y = 0 MSB of LBA
        lda     $BB                             ; begin with LSB of LBA = starting sector:
LB7AC:  clc                                     ; add one sector for each track skipped
        adc     $BA
        bcc     LB7B2                           ; carry out to MSB
        iny
LB7B2:  dex                                     ; loop until 10 sectors per track added
        bne     LB7AC                           ; thereby adding product = no. sectors skipped
        sta     $BB                             ; store LSB of LBA
        sty     $BA                             ; store MSB of LBA (big-endian)
LB7B9:  ldy     #$09
        lda     ($B0),y                         ; get number of sectors + size code
        jsr     lsr_x5                          ; shift A right 5 places
        tax                                     ; save size code in X
        lda     #$00                            ; set LSB of byte count = 0
        sta     $A0
        lda     ($B0),y                         ; get number of sectors + size code
        iny                                     ; increment offset; Y = 10, points to status
        and     #$1F                            ; extract number of sectors
        lsr     a                               ; A,&A0 = 256 x sector count; divide by two
        ror     $A0                             ; = byte count if X=0, 128-byte sectors
        bcc     LB7D2                           ; jump into doubling loop (always)
LB7CF:  asl     $A0                             ; multiply byte count by two
        rol     a
LB7D2:  dex                                     ; subtract 1 from X
        bpl     LB7CF                           ; if X was >0 then double byte count
        sta     $A1                             ; else store high byte of byte count
        jmp     LBA18                           ; transfer data L2 and exit

; ----------------------------------------------------------------------------
; &29 Seek
osword_7f_seek:
        jsr     LB7E3                           ; set A=0, C=1 if RAM else A=physical drive
        bcs     LB7E2                           ; if a RAM disc then nothing to do, exit
        jsr     LB916                           ; else seek logical track
LB7E2:  rts

; ----------------------------------------------------------------------------
; Set A=0, C=1 if RAM else A=physical drive
LB7E3:  jsr     is_current_drive_ram_disk       ; set Z=1 iff current drive is a RAM disc
        clc                                     ; if a floppy drive
        bne     LB7EC                           ; then return C=0, A=physical drive, Z=0
        lda     #$00
        sec                                     ; else return C=1, A=0, Z=1
LB7EC:  rts

; ----------------------------------------------------------------------------
; &1B Read ID
osword_7f_command_1b:
        ldy     #$09                            ; offset 9 = third parameter
        lda     ($B0),y                         ; get number of IDs to return
        bne     LB7F5                           ; zero is reserved for internal use
        lda     #$01                            ; in which case return one ID
LB7F5:  sta     $BB                             ; set number of IDs to return
        jsr     is_current_drive_ram_disk       ; set Z=1 iff current drive is a RAM disc
        beq     LB818                           ; if so then emulate IDs
        jsr     LB916                           ; seek logical track
        jsr     LB95F                           ; read ID and detect density
        bne     LB817                           ; if command failed then exit
        pha                                     ; else save command result = 0
        lda     $BB                             ; get number of IDs to return
        asl     a                               ; multiply by 4 = number of ID bytes
        asl     a
        tax                                     ; transfer to X to use as counter
        ldy     #$00                            ; start at offset 0:
LB80C:  lda     $0D0C,y                         ; get byte of ID read from workspace
        jsr     LA4E0                           ; put data byte in user memory
        iny                                     ; increment offset
        dex                                     ; loop until X bytes returned to user
        bne     LB80C
        pla                                     ; restore command result
LB817:  rts

; ----------------------------------------------------------------------------
; emulate RAM disc sector IDs
LB818:  pla
        ldy     #$00                            ; start at beginning of user memory
        ldx     #$00                            ; first sector number = 0
; Create ID table
LB81D:  lda     $BA                             ; get track number       C
        jsr     LA4E0                           ; put data byte in user memory
        iny
        lda     #$00                            ; head number = 0        H
        jsr     LA4E0                           ; put data byte in user memory
        iny
        txa                                     ; transfer sector number R
        jsr     LA4E0                           ; put data byte in user memory
        iny
        lda     #$01                            ; size code = 1, 256 b   N
        jsr     LA4E0                           ; put data byte in user memory
        inx                                     ; increment sector number
        dec     $BB                             ; loop until required no. sector IDs created
        bne     LB81D
        jsr     LB996                           ; set up drive for single density
        lda     #$00                            ; fake WD1770 status = 0, succeeded.
        rts

; ----------------------------------------------------------------------------
; &23 Format track
osword_7f_command_23:
        jsr     LB7E3                           ; Set A=0, C=1 if RAM else A=physical drive
        bcs     LB84E                           ; if RAM then set density of RAM disc
        iny                                     ; else offset 9 = no. sectors + size code
        lda     ($B0),y
        and     #$1F                            ; extract number of sectors
        sta     $FDEB                           ; store number of sectors per track
        jmp     LBB58                           ; format track

; ----------------------------------------------------------------------------
LB84E:  lda     $FDED                           ; get density flag
        and     #$40                            ; mask bit 6 = double density
        sta     $FDFE                           ; store RAM disc density flag
        lda     #$00                            ; fake WD1770 status = 0, succeeded.
        rts

; ----------------------------------------------------------------------------
; &2C Read drive status
osword_7f_read_drive_status:
        dey                                     ; y = 8 going to 7, offset of result
        jsr     LB905                           ; test write protect state
        lsr     a                               ; returned in bit 6
        lsr     a                               ; move to bit 3 = WR PROT
        lsr     a
        ora     #$44                            ; set b6 = RDY 1, b2 = RDY 0
LB862:  rts                                     ; return result to user's OSWORD &7F block

; ----------------------------------------------------------------------------
; &35 Specify
osword_7f_initialise:
        lda     $BA                             ; get first parameter
        cmp     #$0D                            ; is it &0D = Specify Initialization?
        bne     LB862                           ; if not then exit
        lda     ($B0),y                         ; else get second parameter = step rate
        tax                                     ; (WD1770 format; 0=fast..3=slow; b7..2=0)
        jmp     LB901                           ; save as track stepping rate

; ----------------------------------------------------------------------------
; &3A Write special registers
osword_7f_write_special_registers:
        lda     ($B0),y                         ; get second parameter = value to write
        ldx     $BA                             ; get first parameter = register address
        cpx     #$05                            ; if address in range 0..4
        bcs     LB87B
        sta     $FDEA,x                         ; then set parameter of current drive
        rts

; ----------------------------------------------------------------------------
LB87B:  ldy     #$00                            ; else point to unit 0 track position
        cpx     #$12                            ; if address = 18
        beq     LB886                           ; then set unit 0 position
        iny                                     ; else point to unit 1 track position
        cpx     #$1A                            ; if address <> 26
        bne     LB8AA                           ; then exit with result = 0
LB886:  sta     $FDEF,y                         ; else store physical position of head
        lda     #$00                            ; return result = 0, succeeded.
        rts

; ----------------------------------------------------------------------------
; &3D Read special registers
osword_7f_read_special_registers:
        ldx     $BA                             ; get first parameter = register address
        cpx     #$05                            ; if address in range 0..3
        bcs     LB898
        lda     $FDEA,x                         ; then return parameter of current drive
        sta     ($B0),y                         ; return to offset 8 of OSWORD control block
        rts

; ----------------------------------------------------------------------------
LB898:  lda     #$00                            ; else point to unit 0 track position
        cpx     #$12                            ; if address = 18
        beq     LB8A4                           ; then return unit 0 position
        lda     #$01                            ; else point to unit 1 track position
        cpx     #$1A                            ; if address <> 26
        bne     LB8AA                           ; then exit with result = 0
LB8A4:  tax                                     ; else transfer offset to X
        lda     $FDEF,x                         ; get physical track number for drive
        sta     ($B0),y                         ; store result byte
LB8AA:  lda     #$00                            ; returns 0
        rts

; ----------------------------------------------------------------------------
; Table of 8271 floppy drive controller commands with action addresses
LB8AD:  .byte   $13                             ; &13 Read data
; ----------------------------------------------------------------------------
LB8AE:  .word   osword_7f_read_data_or_deleted_data-1
; ----------------------------------------------------------------------------
        .byte   $0B                             ; &0B Write data
; ----------------------------------------------------------------------------
        .word   osword_7f_write_data-1
; ----------------------------------------------------------------------------
        .byte   $29                             ; &29 Seek
; ----------------------------------------------------------------------------
        .word   osword_7f_seek-1
; ----------------------------------------------------------------------------
        .byte   $1F                             ; &1F Verify data
; ----------------------------------------------------------------------------
        .word   osword_7f_verify_data-1
; ----------------------------------------------------------------------------
        .byte   $17                             ; &17 Read data & deleted data
; ----------------------------------------------------------------------------
        .word   osword_7f_read_data_or_deleted_data-1
; ----------------------------------------------------------------------------
        .byte   $0F                             ; &0F Write deleted data
; ----------------------------------------------------------------------------
        .word   osword_7f_write_deleted_data-1
; ----------------------------------------------------------------------------
        .byte   $1B                             ; &1B Read ID
; ----------------------------------------------------------------------------
        .word   osword_7f_command_1b-1
; ----------------------------------------------------------------------------
        .byte   $23                             ; &23 Format track
; ----------------------------------------------------------------------------
        .word   osword_7f_command_23-1
; ----------------------------------------------------------------------------
        .byte   $2C                             ; &2C Read drive status
; ----------------------------------------------------------------------------
        .word   osword_7f_read_drive_status-1
; ----------------------------------------------------------------------------
        .byte   $35                             ; &35 Specify
; ----------------------------------------------------------------------------
        .word   osword_7f_initialise-1
; ----------------------------------------------------------------------------
        .byte   $3A                             ; &3A Write special registers
; ----------------------------------------------------------------------------
        .word   osword_7f_write_special_registers-1
; ----------------------------------------------------------------------------
        .byte   $3D                             ; &3D Read special registers
; ----------------------------------------------------------------------------
        .word   osword_7f_read_special_registers-1
; ----------------------------------------------------------------------------
        .byte   $00                             ; terminator byte
; ----------------------------------------------------------------------------
; Set control latch for drive
fdc_select_current_drive:
        jsr     push_registers_and_tuck_restoration_thunk; save AXY
        jsr     is_current_drive_ram_disk       ; set Z=1 iff current drive is a RAM disc
        beq     LB8EE                           ; if so then nothing to do, return
        jsr     get_current_physical_drive      ; else map current volume to physical volume
        and     #$07                            ; extract physical drive number, clear b7..3
        tax                                     ; put drive number in X
        lda     $FDED                           ; get density flag
        and     #$7F                            ; mask off b7=automatic density
        eor     #$40                            ; invert b6, now 0=double density 1=single
        lsr     a                               ; move to bit 5
        ora     fdc_control_table,x             ; apply flags for drive 0..7 in X
        sta     fdc_control                     ; store in control latch
LB8EE:  rts

; ----------------------------------------------------------------------------
; +0 = $12 = drive 0 side 0 = *DRIVE 0; +1 = $14 = drive 1 side 0 = *DRIVE 1; +2 = $13 = drive 0 side 1 = *DRIVE 2; +3 = $15 = drive 1 side 1 = *DRIVE 3; +4 = $ff = invalid??; +5 = $ff = invalid??; +6 = $18 = ??; +7 = $19 = ??
; Table of drive control latch values for drives 0..7
fdc_control_table:
        .byte   $12,$14,$13,$15,$FF,$FF,$18,$19
; ----------------------------------------------------------------------------
; Set track stepping rate from startup options
LB8F7:  jsr     push_registers_and_tuck_restoration_thunk; save AXY
        jsr     osbyte_aff_x00_yff              ; call OSBYTE &FF = read/write startup options
        txa                                     ; transfer keyboard links to A
        jsr     extract_00xx0000                ; extract b5,b4 of A
LB901:  sta     $FDF2                           ; save as track stepping rate
        rts

; ----------------------------------------------------------------------------
; Test write protect state of current drive
LB905:  jsr     is_current_drive_ram_disk       ; set Z=1 iff current drive is a RAM disc
        beq     LB913                           ; if so then return A=&00, Z=1 write enabled
        jsr     do_177x_seek                    ; else issue Seek and Force Interrupt
        jsr     LBD16                           ; wait for command completion
        and     #$40                            ; z=0 if WD1770 S6 = write protect.
        rts

; ----------------------------------------------------------------------------
LB913:  lda     #$00
        rts

; ----------------------------------------------------------------------------
; Seek logical track
LB916:  jsr     select_ram_page_001             ; page in main workspace
        lda     $BA                             ; get logical track number
        bit     $FDEA                           ; test double-stepping flag
        bvc     LB921                           ; if b6=1 then double stepping is enabled
        asl     a                               ; so double track number:
; Seek physical track
LB921:  jsr     fdc_select_current_drive        ; set control latch for drive
        jsr     LA875                           ; save XY
        pha                                     ; save target physical track
        jsr     LBCA0                           ; set X=physical floppy unit for current drive
        lda     $FDEF,x                         ; get physical track number for drive
        jsr     LBC9C                           ; write to FDC track register
        pla                                     ; get back A
        sta     $FDEF,x                         ; store physical track number for drive
        jsr     write_data                      ; write to FDC data register
        cmp     #$00                            ; if track number = 0
        beq     LB93E                           ; then issue WD1770 FDC command &00 = Restore
        lda     #$10                            ; else issue WD1770 FDC command &10 = Seek:
; Execute Restore/Seek command
LB93E:  bit     fdc_status_or_cmd               ; test FDC status register
        php                                     ; save WD1770 S7 = motor on in N
        ora     $FDF2                           ; apply track stepping rate
        jsr     write_command                   ; write to FDC command register
        jsr     LBD16                           ; wait for command completion
        plp                                     ; restore previous status
        bmi     LB95E                           ; if motor was on then exit
        lda     $FDE9                           ; else get data transfer call number
        lsr     a                               ; test bit 0
        bcc     LB95E                           ; if reading or verifying data then exit
        ldy     #$00                            ; else wait 295 milliseconds then exit:
LB956:  nop                                     ; allow extra head settling time
        nop                                     ; before writing
        dex
        bne     LB956
        dey                                     ; this point reached every 1.1 milliseconds
        bne     LB956
LB95E:  rts

; ----------------------------------------------------------------------------
; Read ID and detect density
LB95F:  jsr     LA875                           ; save XY
        jsr     select_ram_page_001             ; page in main workspace
        jsr     do_177x_seek                    ; issue Seek and Force Interrupt
        ldx     #$05                            ; 5 attempts to make, 3 in SD + 2 in DD
        bit     $FDED                           ; if current density is single
        bvc     LB982                           ; then attempt in single density first
        dex                                     ; else only 2 attempts in DD + 2 in SD:
LB970:  lda     $FDED                           ; get density flag
        ora     #$40                            ; set b6=1, double density
        ldy     #$12                            ; 18 sectors per track
        jsr     LB9AC                           ; execute Read Address at specified density
        beq     LB9A9                           ; if record found then return success
        bit     $FDED                           ; else test density flag
        bpl     LB996                           ; if b7=0 manual density then return failure
        dex                                     ; else decrement number of attempts remaining
LB982:  lda     $FDED                           ; get density flag
        and     #$BF                            ; set b6=0, single density
        ldy     #$0A                            ; 10 sectors per track
        jsr     LB9AC                           ; execute Read Address at specified density
        beq     LB9A9                           ; if record found then return success
        bit     $FDED                           ; else test density flag
        bpl     LB996                           ; if b7=0 manual density then return failure
        dex                                     ; else decrement number of attempts remaining
        bne     LB970                           ; if attempts remaining try double density
LB996:  lda     $FDED                           ; else set b6=0, single density
        and     #$BF
        sta     $FDED
        jsr     fdc_select_current_drive        ; set control latch for drive
        lda     #$0A                            ; set 10 sectors per track
        sta     $FDEB
        lda     #$18                            ; fake WD1770 S4 = record not found
        rts                                     ; fake WD1770 S3 = CRC error.

; ----------------------------------------------------------------------------
LB9A9:  lda     #$00                            ; fake WD1770 status = 0, succeeded.
        rts

; ----------------------------------------------------------------------------
; Execute Read Address at specified density
LB9AC:  sta     $FDED                           ; store density flag
        sty     $FDEB                           ; store number of sectors per track:
; Execute Read Address command
LB9B2:  jsr     LA875                           ; save XY
        jsr     LB916                           ; seek logical track
        ldy     #$0B                            ; 12 bytes to copy, &0D00..0B:
LB9BA:  lda     nmi_write_routine_same_page,y   ; get byte of NMI read ID
        sta     L0D00,y                         ; store in NMI area
        dey                                     ; loop until all bytes copied
        bpl     LB9BA
        php                                     ; save interrupt state
        ldx     $BB                             ; test no. IDs to read
        beq     LB9D0                           ; 0 = internal use, skip wait for index
        sei                                     ; else disable interrupts
LB9C9:  lda     fdc_status_or_cmd               ; load FDC status register
        and     #$02                            ; test WD1770 S1 = index
        beq     LB9C9                           ; loop until index pulse from drive
LB9D0:  ldy     #$00                            ; then wait 640.5 microseconds
LB9D2:  dey
        bne     LB9D2
        lda     #$C0                            ; WD1770 command &C0 = Read address
        sta     fdc_status_or_cmd               ; write to FDC command register
        jsr     LBD16                           ; wait for command completion
        bne     LB9EA                           ; if command succeeded
        dec     $0D05                           ; then backspace over CRC bytes
        dec     $0D05
        dex                                     ; decrement number of IDs to read
        bmi     LB9EA                           ; if an internal call then finish
        bne     LB9D0                           ; else loop until all IDs read, then:
LB9EA:  plp                                     ; restore interrupt state
        lda     fdc_status_or_cmd               ; WD1770 S4 = record not found
        and     #$18                            ; WD1770 S3 = CRC error
        jmp     select_ram_page_001             ; mask off other bits, page in main workspace.

; ----------------------------------------------------------------------------
; Issue Seek and Force Interrupt
do_177x_seek:
        jsr     fdc_select_current_drive        ; set control latch for drive
        lda     #$18                            ; WD1770 command &18 = Seek w/spin up
        jsr     write_command                   ; write to FDC command register
        ldx     #$0F                            ; wait 38 microseconds
LB9FD:  dex
        bne     LB9FD
do_177x_force_interrupt:
        lda     #$D0                            ; WD1770 command &D0 = Force interrupt
        jmp     write_command                   ; write to FDC command register and exit

; ----------------------------------------------------------------------------
; Verify track
LBA05:  jsr     LA875                           ; save XY
        lda     #$00
        sta     $BB                             ; sector number = 0
        sta     $A0                             ; whole number of sectors to transfer
        lda     $FDEB                           ; get number of sectors per track
        sta     $A1                             ; set number of sectors to transfer
        lda     #$04                            ; set call number to &04, verify data
        sta     $FDE9                           ; set data transfer call number
; Transfer data L2
LBA18:  jsr     LA875                           ; save XY (inner)
        jsr     is_current_drive_ram_disk       ; set Z=1 iff current drive is a RAM disc
        bne     LBA23                           ; if floppy then transfer data to disc L2
        jmp     LBE67                           ; else transfer data to paged RAM

; ----------------------------------------------------------------------------
; Transfer data to disc L2
LBA23:  lda     $A0                             ; save ?&A0, ?&A1 on stack
        pha
        lda     $A1
        pha
        jsr     fdc_select_current_drive        ; set control latch for drive
        jsr     LB916                           ; seek logical track
        lda     $BA                             ; get logical track number
        jsr     LBC94                           ; store physical position of head
        jsr     copy_nmi_read_routine           ; copy NMI read from disc/polling loop to NMI
        lda     $FDEE                           ; get *OPT 9 saverom slot number
        sta     nmi_opt9_value                  ; store in polling loop to page in on entry
        lda     $FDE9                           ; get data transfer call number
        pha                                     ; save on stack
        and     #$05                            ; if call=0 or 2, read (deleted) data
        beq     LBA4E                           ; then branch
        ror     a                               ; else if b2..0 = 1x0, A=&04 verify data
        bcs     LBA58
        jsr     LBAEF                           ; then instruction at &0D06 = JMP &0D11
        jmp     LBA6A                           ; discard byte from FDC data register

; ----------------------------------------------------------------------------
LBA4E:  lda     $A0                             ; increment MSB byte count if LSB >0
        beq     LBA54                           ; not rounding up, converting number format
        inc     $A1                             ; Z=1 from both DECs means zero reached
LBA54:  ldy     #$07                            ; if call=0 or 2, read (deleted) data
        bne     LBA67                           ; then data address is located at &0D07.
LBA58:  lda     $A0                             ; increment MSB byte count if LSB >0
        beq     LBA5E                           ; not rounding up, converting number format
        inc     $A1                             ; Z=1 from both DECs means zero reached
LBA5E:  lda     #$00                            ; if b0=1, A=1 or 3 write (deleted) data
        sta     $A0                             ; then clear ?&A0, write whole sectors
        jsr     copy_nmi_write_routine          ; copy NMI write to disc to NMI area
        ldy     #$04                            ; data address is located at &0D04
LBA67:  jsr     LBAA0                           ; set data address in NMI ISR
LBA6A:  lda     $F4                             ; get Challenger ROM slot number
        sta     $0D38                           ; save in NMI area
        lda     $BB                             ; get start sector number
        jsr     write_sector                    ; write to FDC sector register
        pla                                     ; restore data transfer call number
        and     #$07                            ; mask bits 2..0
        pha                                     ; save it again
        tay                                     ; transfer to Y
        lda     fdc_commands,y                  ; get FDC command for call
        jsr     write_command                   ; write to FDC command register
        ldx     #$1E                            ; wait 76 microseconds
LBA81:  dex
        bne     LBA81
        jsr     L0D2C                           ; page SROM in and wait until finished L0
        jsr     select_ram_page_001             ; page in main workspace
        pla
        tay
        jsr     LBD27                           ; load FDC status register and store b6..0
        and     LBD57,y                         ; apply status mask from table to set Z
        tay                                     ; present FDC status register in A
        jsr     LBC8C                           ; store head position for this drive
LBA96:  pla                                     ; restore ?&A0, ?&A1 from stack
        sta     $A1
        pla
        sta     $A0
        tya
        jmp     select_ram_page_001             ; page in main workspace

; ----------------------------------------------------------------------------
; Set data address in NMI ISR
LBAA0:  lda     $FDE9                           ; test data transfer call number
        bmi     LBACF                           ; if b7=1 then transferring to JIM, branch
        lda     $FDCC                           ; else test Tube data transfer flag
        beq     LBAC4                           ; if transferring data to Tube
        lda     #$E5                            ; then paste address of R3DATA at &0D00+Y
        sta     L0D00,y
        lda     #$FE
        sta     $0D01,y
        lda     #$4C                            ; instruction at &0D09 = JMP &0D11
        sta     $0D09                           ; do not increment R3DATA address
        lda     #$11
        sta     $0D0A
        lda     #$0D
        sta     $0D0B
        rts

; ----------------------------------------------------------------------------
LBAC4:  lda     $A6                             ; else copy data pointer to NMI ISR at &0D00+Y
        sta     L0D00,y
        lda     $A7
        sta     $0D01,y
        rts

; ----------------------------------------------------------------------------
; Enable JIM select in NMI read from disc
LBACF:  lda     #$20                            ; &0D0E = JSR &0D3D
        sta     $0D0E
        lda     #$3D
        sta     $0D0F
        lda     #$0D
        sta     $0D10
        lda     $A6                             ; insert 2MSB of JIM address = LSB page no.
        sta     $0D41
        sta     ram_paging_lsb                  ; and page it in
        lda     $A7                             ; insert MSB of JIM address = MSB page no.
        sta     $0D4B
        sta     ram_paging_msb                  ; and page it in
        rts

; ----------------------------------------------------------------------------
; Copy NMI verify to NMI area
LBAEF:  ldy     #$02                            ; 3 bytes to copy, &0D06..8:
LBAF1:  lda     LBDC6,y                         ; get byte of NMI verify
        sta     $0D06,y                         ; store in NMI area
        dey                                     ; loop until all bytes copied
        bpl     LBAF1
        rts

; ----------------------------------------------------------------------------
; Copy NMI read from disc/polling loop to NMI
copy_nmi_read_routine:
        ldy     #$4F                            ; 80 bytes to copy, &0D00..4F:
LBAFD:  lda     nmi_read_routine,y              ; get byte of NMI read from disc/polling loop
        sta     L0D00,y                         ; store in NMI area
        dey                                     ; loop until all bytes copied
        bpl     LBAFD
        rts

; ----------------------------------------------------------------------------
; Copy NMI write to disc to NMI area
copy_nmi_write_routine:
        ldy     #$0D                            ; 14 bytes to copy, &0D03..10:
LBB09:  lda     nmi_write_routine,y             ; get byte of NMI write to disc
        sta     $0D03,y                         ; patch NMI read to disc routine with it
        dey                                     ; loop until all bytes copied
        bpl     LBB09
        lda     #$FC                            ; enable 123 microsecond delay
        sta     $0D23                           ; before interrupting write operation
        rts                                     ; so that FDC will write CRC of sector

; ----------------------------------------------------------------------------
; Create ID table and format track
LBB18:  lda     #$0A                            ; set A = 10 sectors per track
        bit     $FDED                           ; if double density format
        bvc     LBB21
        lda     #$12                            ; then set A = 18 sectors per track
LBB21:  sta     $A6                             ; store as limit to sector count
        sta     $FDEB                           ; store as no. sectors per track of disc
        asl     a                               ; multiply by 4
        asl     a
        sta     $A7                             ; store as size of CHRN table
        ldx     $BB                             ; set X = number of first sector
        ldy     #$00                            ; (inverse track skew) Y=0 CHRN tbl index
LBB2E:  lda     $BA                             ; Get logical track number
        sta     $FD61,y                         ; store cylinder number  C
        iny
        lda     #$00                            ; head number = 0
        sta     $FD61,y                         ; store head humber      H
        iny
        txa                                     ; transfer sector number to A
        sta     $FD61,y                         ; store record number    R
        iny
        lda     #$01                            ; size code = 1, 256-byte sector
        sta     $FD61,y                         ; store size code        N
        iny
        inx                                     ; increment sector number
        cpx     $A6                             ; has it reached no. sectors per track?
        bcc     LBB4C
        ldx     #$00                            ; if so then wrap around to 0
LBB4C:  cpy     $A7                             ; has table offset reached 4x s.p.t?
        bcc     LBB2E                           ; if not then loop
        lda     #$61                            ; else set pointer to start of CHRN table:
        sta     $A6
        lda     #$FD
        sta     $A7
; Format track
LBB58:  lda     #$12                            ; set run table pointer to &000612 in JIM
        sta     $A4                             ; (page breaks occur 5/8 through fifth,
        lda     #$06                            ; 1/8 through eleventh and in gap2 of
        pha                                     ; seventeenth sector of track.)
        sta     $A5
        ldx     #$00                            ; point to single density table, X = &00
        bit     $FDED                           ; if double density format
        bvc     LBB6A
        ldx     #$23                            ; then point to double density table, X = &23
LBB6A:  lda     $FDEB                           ; get number of sectors per track
        sta     $A2                             ; set as counter
        jsr     LBC3A                           ; page in JIM page 6..9
        ldy     #$05                            ; set Y = 5 as counter:
LBB74:  jsr     LBBBB                           ; add entry to track format RLE table
        dey                                     ; loop until 5 entries added
        bne     LBB74                           ; this copies gap 5, IDAM and start of gap 1
        stx     $A3                             ; X points to repeating sector block
LBB7C:  ldx     $A3                             ; reset X to start of sector block
LBB7E:  jsr     LBBBB                           ; add entry to track format RLE table
        bcc     LBB7E                           ; loop until terminator byte reached
        dec     $A2                             ; decrement number of sectors remaining
        bne     LBB7C                           ; loop until all sectors added to track
        lda     #$00                            ; data byte = &00 (run length = &10 or &16)
        jsr     LBC14                           ; add gap 4 to table
        jsr     select_ram_page_001             ; page in main workspace
        jsr     LB916                           ; seek logical track
        ldx     #$FF
        ldy     #$10                            ; A = &10
        bit     $FDED                           ; if double density format
        bvc     LBB9F
        ldy     #$28                            ; then A = &28
        ldx     #$4E
LBB9F:  sty     $A0                             ; set number of filler bytes in gap 5
        pla
        jsr     LBE1D                           ; page in JIM page in A
        stx     $FD92                           ; set filler byte in gap 5
        ldy     #$3C                            ; 61 bytes to copy, &0D00..3D:
LBBAA:  lda     LBDC9,y                         ; get byte of NMI format code
        sta     L0D00,y                         ; store in NMI handler area
        dey                                     ; loop until all bytes transferred
        bpl     LBBAA
        lda     #$F4                            ; &F4=Write track, settling delay
        jsr     write_command                   ; write to FDC command register
        jmp     LBD16                           ; wait for command completion and exit.

; ----------------------------------------------------------------------------
; Add entry to track format RLE table
LBBBB:  txa                                     ; save ROM table offset
        pha
        tya                                     ; save number of sectors remaining
        pha
        ldy     #$00                            ; y=&00
        sec
        lda     LBC42,x                         ; get run length from ROM table
        bmi     LBBD9                           ; if b7=1 then process special entry
        beq     LBBD2                           ; if the terminator byte then finish C=1
        sta     $A0                             ; else store run length in zero page
        lda     LBC43,x                         ; get data byte from ROM table
        jsr     LBC14                           ; store run in table
LBBD1:  clc                                     ; c=0, sector not completed
LBBD2:  pla                                     ; restore number of sectors remaining
        tay
        pla                                     ; restore ROM table offset
        tax
        inx                                     ; add 2 to ROM table offset
        inx
        rts

; ----------------------------------------------------------------------------
; Process special table entry (length=&FF)
LBBD9:  lda     LBC43,x                         ; get data byte from ROM format table
        bne     LBC00                           ; if non-zero then add sector data area
        lda     #$01                            ; else add ID bytes. run length of bytes = 1
        sta     $A0                             ; store run length in zero page
        ldx     #$04                            ; 4 bytes in sector ID:
LBBE4:  jsr     select_ram_page_001
        ldy     #$00                            ; y=0 for user memory load
        jsr     LA4EC                           ; get data byte from user memory
        jsr     LBC3A                           ; page in JIM page 6..9
        jsr     LBC14                           ; store run in table
        inc     $A6                             ; increment CHRN table pointer
        bne     LBBF8                           ; carry out to high byte
        inc     $A7
LBBF8:  dex                                     ; loop until 4 ID bytes stored
        bne     LBBE4
        sta     $A1                             ; store last byte read = N = size code
        jmp     LBBD1                           ; restore XY and return

; ----------------------------------------------------------------------------
; Add sector data area
LBC00:  ldx     $A1                             ; load sector size code
        lda     LBC88,x                         ; get run length from table
        sta     $A0                             ; store in zero page
        ldx     #$08                            ; repeat prescribed run 8 times:
        lda     #$E5                            ; A=&E5 = sector filler byte
LBC0B:  jsr     LBC14                           ; store run in table
        dex                                     ; loop until 8 copies of run stored
        bne     LBC0B
        jmp     LBBD1                           ; restore XY and return

; ----------------------------------------------------------------------------
; Store run in table
LBC14:  pha                                     ; save data byte
        ldy     $A4                             ; get offset into data/run tables
        sta     $FD80,y                         ; store data byte in data table
        lda     $A0                             ; get run length
        sta     $FD00,y                         ; store run length in run table
        lda     $A4
        bne     LBC2B                           ; if pointers are on a page boundary
        lda     $FD00                           ; then set b7=1 of run length
        ora     #$80
        sta     $FD00
LBC2B:  inc     $A4                             ; increment data table pointer
        bpl     LBC38                           ; if LSB of pointer reaches &80
        lda     #$00                            ; then the tables fill each half page
        sta     $A4                             ; so reset LSB of pointer = &00
        inc     $A5                             ; and carry out to high byte
        jsr     LBC3A
LBC38:  pla                                     ; restore data byte and return
        rts

; ----------------------------------------------------------------------------
; page in JIM page 6..9
LBC3A:  pha                                     ; save A
        lda     $A5                             ; get MSB of data table pointer
        jsr     LBE1D                           ; page in JIM page in A
        pla
        rts

; ----------------------------------------------------------------------------
; RLE tables of formatting bytes
LBC42:  .byte   $10
LBC43:  .byte   $FF,$03,$00,$03,$00,$01,$FC,$0B
        .byte   $FF,$03,$00,$03,$00,$01,$FE,$FF
        .byte   $00,$01,$F7,$0B,$FF,$03,$00,$03
        .byte   $00,$01,$FB,$FF,$01,$01,$F7,$10
        .byte   $FF,$00,$28,$4E,$0C,$00,$03,$F6
        .byte   $01,$FC,$19,$4E,$0C,$00,$03,$F5
        .byte   $01,$FE,$FF,$00,$01,$F7,$16,$4E
        .byte   $0C,$00,$03,$F5,$01,$FB,$FF,$01
        .byte   $01,$F7,$16,$4E,$00
LBC88:  .byte   $10,$20,$40,$80
; ----------------------------------------------------------------------------
; Store per-drive head position
LBC8C:  lda     $BA                             ; get logical track number of disc operation
        bit     $FDEA                           ; test double-stepping flag
        bvc     LBC94                           ; if b6=1 then double stepping is enabled
        asl     a                               ; so double track number:
; Store physical position of head
LBC94:  pha                                     ; save physical track
        jsr     LBCA0                           ; set X=physical floppy unit for current drive
        pla                                     ; restore physical track
        sta     $FDEF,x                         ; store physical track number for drive:
; Write to FDC track register
LBC9C:  sta     fdc_track
        rts

; ----------------------------------------------------------------------------
; Set X=physical floppy unit for current drive
LBCA0:  jsr     get_current_physical_drive      ; map current volume to physical volume
        and     #$07                            ; mask drive no in b2..0 mask off volume letter
        ldx     #$02                            ; preset X=2 to select third floppy drive
        cmp     #$06                            ; if physical drive number = 6 or 7
        bcs     LBCAE                           ; then return X=2
        and     #$01                            ; else return X=0 drv 0 or 2, X=1 drv 1 or 3
        tax
LBCAE:  rts

; ----------------------------------------------------------------------------
; Raise "Disk fault" error
LBCAF:  jsr     dobrk_with_Disk_prefix          ; begin error message with "Disk fault "
        .byte   $C5
        .byte   "fault "
; ----------------------------------------------------------------------------
        nop
        lda     $FDF3
        jsr     print_hex_byte                  ; print hex byte
        jsr     print_string_nterm              ; print " at Trk "
        .byte   " at Trk "
; ----------------------------------------------------------------------------
        nop
        lda     $BA                             ; get track number
        jsr     print_hex_byte                  ; print hex byte
        jsr     print_string_nterm              ; print ", Sct "
        .byte   ", Sct "
; ----------------------------------------------------------------------------
        nop
        lda     $BB                             ; get sector number
        jsr     print_hex_byte                  ; print hex byte
        jmp     LA8F8                           ; terminate error message, raise error

; ----------------------------------------------------------------------------
; Raise "Disk not formatted" error
LBCE3:  jsr     print_string_2_nterm
        .byte   $C5
        .byte   "Disk not formatted"


; ----------------------------------------------------------------------------
        brk
; Write to FDC command register
write_command:
        sta     fdc_status_or_cmd
        rts

; ----------------------------------------------------------------------------
; Write to FDC sector register
write_sector:
        sta     fdc_sector
        rts

; ----------------------------------------------------------------------------
; Write to FDC data register
write_data:
        sta     fdc_data
        rts

; ----------------------------------------------------------------------------
; Set Z=1 iff drive motor is on
LBD06:  jsr     is_current_drive_ram_disk       ; set Z=1 iff current drive is a RAM disc
        beq     LBD13                           ; if RAM disc then treat as motor on
        lda     fdc_status_or_cmd               ; else load FDC status register
        eor     #$80                            ; return A=0, Z=1 iff motor is on
        and     #$80                            ; mask b7 extract WD1770 S7 = motor on
        rts

; ----------------------------------------------------------------------------
LBD13:  lda     #$00                            ; return A=0, Z=1 indicating motor on.
        rts

; ----------------------------------------------------------------------------
; Wait for command completion
LBD16:  jsr     LA875                           ; save XY
        ldx     #$FF                            ; wait 638 microseconds
LBD1B:  dex
        bne     LBD1B
LBD1E:  jsr     LBD33                           ; poll for ESCAPE
        lda     fdc_status_or_cmd               ; load FDC status register
        ror     a                               ; place bit 0 in carry flag
        bcs     LBD1E                           ; loop until b0=0 WD1770 S0 = busy
LBD27:  lda     fdc_status_or_cmd               ; load FDC status register
        and     #$7F                            ; mask bits 6..0 ignore WD1770 S7 = motor on
        jsr     select_ram_page_001
        sta     $FDF3                           ; save final status
        rts

; ----------------------------------------------------------------------------
; Poll for ESCAPE
LBD33:  lda     $B9                             ; if >0 disc operation is uninterruptible
        beq     LBD51                           ; then return
        bit     $FF                             ; else if ESCAPE pressed
        bpl     LBD51
        jsr     do_177x_force_interrupt         ; then send Force Interrupt
        lda     #$00                            ; RES b4=0, reset WD 1770 floppy controller
        sta     fdc_control                     ; store in control latch
        jsr     acknowledge_escape              ; acknowledge ESCAPE condition
        jsr     print_string_2_nterm            ; raise "Escape" error.
        .byte   $11
        .byte   "Escape"
; ----------------------------------------------------------------------------
        brk
LBD51:  rts

; ----------------------------------------------------------------------------
; +0 = $90 = read multiple sectors; +1 = $b4 = write multiple sectors with 30ms delay; +2 = $90 = read multiple sectors; +3 = $b5 = write multiple sectors, deleted data, with 30ms delay; +4 = $90 = read multiple sectors
; Table of WD1770 FDC commands for data transfer call numbers 0..4
fdc_commands:
        .byte   $90,$B4,$90,$B5,$90
; Table of status mask bytes for data transfer call numbers 0..4
LBD57:  .byte   $3C,$7C,$1C,$5C,$3C
; ----------------------------------------------------------------------------
; NMI read from disc, &0D00..2B
; opcode read 4+e..8 microseconds after NMI
; (up to 13.5 us if code running in 1 MHz mem)
nmi_read_routine:
        sta     $0D2A                           ; save accumulator to restore on exit
        lda     fdc_data                        ; read FDC data register
        sta     $FD00                           ; store in user memory or R3DATA
        inc     $0D07                           ; increment user memory address
        bne     LBD6D                           ; carry out to high byte
        inc     $0D08
LBD6D:  dec     $A0                             ; decrement count of bytes to transfer
        bne     LBD85                           ; (&0101 = 1; &0000 = 0)
        dec     $A1                             ; if count has not reached zero
        bne     LBD85                           ; then restore A and return from interrupt
        lda     #$40                            ; else set 0D00=RTI; ignore further NMIs
        sta     L0D00                           ; ISR safe by 23+e..30.5 us after NMI
        lda     #$CE                            ; write complete by 25.5+e..33 us
        adc     #$01                            ; wait 123 microseconds (if loop enabled)
        bcc     LBD80                           ; 0D23=&FC loops back to &0D20
LBD80:  lda     #$D0                            ; FDC command &D0 = Force Interrupt
        sta     fdc_status_or_cmd               ; write to FDC command register
LBD85:  lda     #$00                            ; restore value of A on entry
        rti                                     ; return from interrupt

; ----------------------------------------------------------------------------
; NMI polling loop, &0D2C..3C
        lda     #$0E                            ; page *OPT 9 saverom slot in
        sta     $FE30
LBD8D:  lda     fdc_status_or_cmd               ; load FDC status register
        ror     a                               ; place bit 0 in carry flag
        bcs     LBD8D                           ; loop until b0=0 WD1770 S0 = busy
        lda     #$00                            ; page Challenger ROM back in
        sta     $FE30
        rts                                     ; return

; ----------------------------------------------------------------------------
; JIM page select routine, &0D3D..4F
; made reachable by JSR installed at &BACF
        inc     $0D41                           ; increment LSB of JIM page address
        lda     #$00                            ; set LSB of JIM page address
        sta     ram_paging_lsb
        bne     LBDAB                           ; if carry out
        inc     $0D4B                           ; then increment MSB of JIM page address
        lda     #$00                            ; set MSB of JIM page address
        sta     ram_paging_msb
LBDAB:  rts

; ----------------------------------------------------------------------------
; NMI write to disc, &0D03..10
nmi_write_routine:
        lda     $FD00
        sta     fdc_data
        inc     $0D04
        bne     nmi_write_routine_same_page
        inc     $0D05
nmi_write_routine_same_page:
        pha
        lda     fdc_data                        ; load FDC data register
        sta     $0D0C                           ; store ID byte in buffer
        inc     $0D05                           ; increment offset
        pla
        rti

; ----------------------------------------------------------------------------
; NMI verify, &0D06..08
LBDC6:  jmp     L0D11                           ; discard byte from FDC data register

; ----------------------------------------------------------------------------
; NMI format, &0D00..3C
LBDC9:  pha                                     ; save A on entry
        lda     $FD92                           ; fetch current data byte
        sta     fdc_data                        ; write to FDC data register
        dec     $A0                             ; decrement run counter
        bne     LBDEA                           ; if all bytes in run written
        inc     $0D02                           ; then increment data byte address low
        bne     LBDFC                           ; if no carry then fetch next run length
        lda     #$80                            ; else reset data address low = &80
        sta     $0D02
        lda     #$07                            ; page in next JIM page
        sta     ram_paging_lsb
        lda     $FD00                           ; fetch next run length marked b7=1
        sta     $A0                             ; set run counter
LBDE8:  pla                                     ; restore A on entry
        rti                                     ; exit

; ----------------------------------------------------------------------------
LBDEA:  bpl     LBDE8                           ; if run still in progress then exit
        lda     $A0                             ; else page was crossed last time:
        and     #$7F                            ; mask off page marker in b7
        sta     $A0                             ; update run counter
        lda     #$00                            ; reset run length address low = &00
        sta     $0D37
        inc     $0D16                           ; increment data byte address high
        pla                                     ; restore A on entry
        rti                                     ; exit

; ----------------------------------------------------------------------------
LBDFC:  inc     $0D37                           ; increment run length address
        lda     $FD12                           ; fetch next run length
        sta     $A0                             ; set run counter
        pla                                     ; restore A on entry
        rti                                     ; exit

; ----------------------------------------------------------------------------
; unreachable code
        nop
; Page in auxiliary workspace
select_ram_page_000:
        pha
        lda     #$00
        beq     select_ram_page_by_lsb
; Page in main workspace
select_ram_page_001:
        pha
        lda     #$01
        bne     select_ram_page_by_lsb
; Page in catalogue sector 0
select_ram_page_002:
        pha
        lda     #$02
        bne     select_ram_page_by_lsb
; Page in catalogue sector 1
select_ram_page_003:
        pha
        lda     #$03
        bne     select_ram_page_by_lsb
; Page in line buffer
select_ram_page_009:
        lda     #$09
; Page in JIM page in A
LBE1D:  pha
select_ram_page_by_lsb:
        sta     ram_paging_lsb                  ; store LSB JIM paging register
        lda     #$00
        sta     ram_paging_msb                  ; set MSB JIM paging register = &00
        pla                                     ; restore A on entry
        rts

; ----------------------------------------------------------------------------
; ChADFS ROM call 4
chadfs_request_04:
        jsr     claim_nmi_area                  ; claim NMI
        jsr     select_ram_page_001             ; page in main workspace
        lda     #$01                            ; data transfer call &01 = write data
        sta     $FDE9
        lda     #$00                            ; transfer size = 512 bytes
        sta     $A0
        lda     #$02
        sta     $A1
        lda     #$00                            ; source address = HAZEL, &C000
        sta     $A6
        lda     #$C0
        sta     $A7
        lda     #$00                            ; b7=0 transfer from host
        sta     $FDCC
        lda     #$00                            ; starting sector/LBA = &0000
        sta     $BA
        sta     $BB
        lda     #$04                            ; destination physical drive = 4
        jsr     LBE7C                           ; transfer data to paged RAM
        lda     #$C9                            ; source address = HAZEL, &C900
        sta     $A7
        lda     #$02                            ; starting sector/LBA = &0002
        sta     $BB
        lda     #$05                            ; transfer size = 1280 bytes
        sta     $A1
        lda     #$04                            ; destination physical drive = 4
        jsr     LBE7C                           ; transfer data to paged RAM
        lda     #$00                            ; fake WD1770 status = 0, succeeded.
        rts

; ----------------------------------------------------------------------------
; Transfer data to paged RAM
LBE67:  jsr     select_ram_page_001             ; page in main workspace
        ldy     #$10
        lda     $FDED                           ; get density flag
        eor     $FDFE                           ; compare with RAM disc density flag
        and     #$40                            ; mask bit 6 = double density
        beq     LBE79                           ; if not matched
        lda     #$10                            ; WD1770 S4 = record not found
        rts

; ----------------------------------------------------------------------------
LBE79:  jsr     get_current_physical_drive      ; map current volume to physical volume
LBE7C:  ldy     #$0A                            ; volume 4 starts at JIM address &000A00
        ldx     #$00
        cmp     #$04                            ; if physical drive is not 4
        beq     LBE88
        ldy     #$00                            ; then volume starts at JIM address &040000
        ldx     #$04
LBE88:  lda     $A0                             ; save ?&A0, ?&A1 on stack
        pha
        lda     $A1
        pha
        txa                                     ; save volume start address in YX on stack
        pha                                     ; MSB first
        tya
        pha
        lda     $A0                             ; increment MSB byte count if LSB >0
        beq     LBE98                           ; not rounding up, converting number format
        inc     $A1                             ; Z=1 from both DECs means zero reached
LBE98:  ldy     #$46                            ; 71 bytes to copy, &0D00..46:
LBE9A:  lda     LBF2F,y                         ; get byte of RAM disc transfer code
        sta     L0D00,y                         ; store in NMI handler area
        dey                                     ; loop until all bytes transferred
        bpl     LBE9A
        lda     $FDE9                           ; get data transfer call number
        bmi     LBEF6                           ; if data address in JIM space then branch
        bne     LBEC0                           ; else if =0 read data
        lda     $A6                             ; then paste user memory address at &0D22,3
        sta     $0D22
        lda     $A7
        sta     $0D23
        lda     $FDCC                           ; test Tube transfer flag
        beq     LBF16                           ; if b7=0 then an I/O transfer, branch
        lda     #$8D                            ; else instruction at &0D21 = STA &FEE5
        ldy     #$03
        jmp     LBED8                           ; modify RAM transfer code for Tube.

; ----------------------------------------------------------------------------
; Modify RAM transfer code for write
LBEC0:  lda     $A6                             ; paste user memory address at &0D1F,20
        sta     $0D1F
        lda     $A7
        sta     $0D20
        lda     #$20                            ; 0D27=INC &0D20
        sta     $0D28                           ; increment user memory address
        lda     $FDCC                           ; test Tube transfer flag
        beq     LBF16                           ; if b7=0 then an I/O transfer, branch
        lda     #$AD                            ; else instruction at &0D1E = LDA &FEE5
        ldy     #$00
; Modify RAM transfer code for Tube
LBED8:  sta     $0D1E,y                         ; store opcode LDA abs at &D1E/STA abs at &D21
        lda     #$E5                            ; store address of R3DATA, &FEE5
        sta     $0D1F,y                         ; at &0D1F,20 or &0D22,3
        lda     #$FE
        sta     $0D20,y
        lda     #$F4                            ; 0D25=BNE &0D1B
        sta     $0D26                           ; enable 25 microsecond interval per byte
        lda     #$E1                            ; 0D38=BNE &0D1B
        sta     $0D39                           ; enable 38.5 microsecond delay to next page
        lda     #$AD                            ; 0D27=LDA &0D23
        sta     $0D27                           ; do not increment R3DATA address
        bne     LBF16                           ; branch (always)
; Copy data between JIM pages
LBEF6:  ldy     #$31                            ; 50 bytes to copy, &0D00..31:
LBEF8:  lda     LBF76,y                         ; get byte of RAM disc copy code
        sta     L0D00,y                         ; store in NMI handler area
        dey                                     ; loop until all bytes transferred
        bpl     LBEF8
        ldy     #$00                            ; LBA goes to &0D06,01
        ldx     #$12                            ; JIM page number goes to &0D13
        lda     $FDE9                           ; get data transfer call number
        and     #$7F                            ; mask bits 0..6
        beq     LBF10                           ; if not =0, read data
        ldy     #$0D                            ; then LBA goes to &0D13,0E
        ldx     #$05                            ; JIM page number goes to &0D06
LBF10:  lda     $A6
        sta     $0D01,x                         ; paste JIM page number at &0D06/13
        .byte   $AD                             ; BF16=LDY #&11
LBF16:  ldy     #$11                            ; LBA goes to &0D17,12
        clc
        pla                                     ; restore LSB volume start address
        adc     $BB                             ; add LSB relative LBA
        sta     $0D06,y                         ; paste LSB absolute LBA at &0D06/13/17
        pla                                     ; restore MSB volume start address
        adc     $BA                             ; add MSB relative LBA
        sta     $0D01,y                         ; paste MSB absolute LBA at &0D01/0E/12
        ldy     #$00                            ; starting offset = &00
        jsr     L0D00                           ; do transfer to/from paged RAM
        ldy     #$00                            ; fake WD1770 status = 0, succeeded
        jmp     LBA96                           ; restore &A0,1 and page in main workspace.

; ----------------------------------------------------------------------------
; Transfer code copied to &0D00..46
LBF2F:  lda     $FDEE                           ; get *OPT 9 saverom setting
        sta     $FE30                           ; set ROM bank to *OPT 9 saverom
LBF35:  lda     $A1                             ; if 256 bytes or less remaining
        cmp     #$01
        bne     LBF40
        lda     #$0F                            ; then 0D25=BNE &0D36
        sta     $0D26                           ; transfer bytes of last page
LBF40:  ldx     #$00                            ; 0D11
        stx     ram_paging_msb                  ; set MSB of JIM page number
        ldx     #$00                            ; 0D16
        stx     ram_paging_lsb                  ; set LSB of JIM page number
        jsr     L0D40                           ; wait 18 microseconds (only needed for Tube)
LBF4D:  lda     $FD00,y                         ; 0D1E read byte from JIM page
        sta     $FD00,y                         ; 0D21 write byte to JIM page
        iny                                     ; increment offset
        bne     LBF4D                           ; 0D25 loop until page boundary reached
        inc     $0D23                           ; 0D27 increment MSB write address
        inc     $0D17                           ; increment LSB of JIM page number
        bne     LBF61                           ; carry out to MSB of JIM page number
        inc     $0D12
LBF61:  dec     $A1                             ; decrement MSB transfer byte count
        bne     LBF35                           ; loop to transfer next page (always)
        dec     $A0                             ; 0D36 decrement LSB transfer byte count
        bne     LBF4D                           ; loop until last bytes transferred
        lda     $F4                             ; page Challenger ROM back in
        sta     $FE30
        rts                                     ; return

; ----------------------------------------------------------------------------
        jsr     L0D46                           ; 0D40 wait 18 microseconds
        jsr     L0D46
        rts

; ----------------------------------------------------------------------------
; RAM disc copy code copied to &0D00..31
LBF76:  ldx     #$00
        stx     ram_paging_msb                  ; set MSB JIM paging register to source
        ldx     #$00
        stx     ram_paging_lsb                  ; set LSB JIM paging register to source
        lda     $FD00,y                         ; get byte from source page
        ldx     #$00                            ; 0D0D
        stx     ram_paging_msb                  ; set MSB JIM paging register to destination
        ldx     #$00                            ; 0D12
        stx     ram_paging_lsb                  ; set MSB JIM paging register to destination
        sta     $FD00,y                         ; store byte in destination page
        iny                                     ; loop to copy whole page
        bne     LBF76
        inc     $0D06                           ; increment LSB source page
        bne     LBF9B                           ; carry out to MSB source page
        inc     $0D01
LBF9B:  inc     $0D13                           ; increment LSB destination page
        bne     LBFA3                           ; carry out to MSB destination page
        inc     $0D0E
LBFA3:  dec     $A1                             ; loop until required number of pages copied
        bne     LBF76
        rts

; ----------------------------------------------------------------------------
; ChADFS ROM call 1
chadfs_request_01:
        lda     #$00
        sta     $FDEC                           ; first track of volume = 0, no track offset
        lda     $FDED                           ; get *OPT 6 density setting
        ora     #$40                            ; set b6=1, double density
        sta     $FDED                           ; update *OPT 6 density setting (preserve auto)
        jsr     L8AE4                           ; prepare extended file transfer
        jmp     LACF0                           ; transfer data L3 and exit

; ----------------------------------------------------------------------------
; Table of action addresses for ChADFS ROM calls 0..4, low bytes
LBFBB:  .byte   $F5,$A7,$1E,$7D,$27
; Table of action addresses for ChADFS ROM calls 0..4, high bytes
LBFC0:  .byte   $AA,$BF,$82,$AB,$BE
; ----------------------------------------------------------------------------
; ChADFS ROM call dispatcher
LBFC5:  tax                                     ; transfer call number to X as index
        jsr     select_ram_page_001             ; page in main workspace
        lda     #$FF
        sta     $FDFF                           ; b6=1 ChADFS is current FS
        lda     #$BF                            ; push address of ChADFS return, &BFF4
        pha                                     ; high byte
        lda     #$F3                            ; low byte
        pha
        lda     LBFC0,x                         ; get action address high byte
        pha                                     ; save on stack
        lda     LBFBB,x                         ; get action address low byte
        pha                                     ; save on stack
        rts                                     ; jump to action address

; ----------------------------------------------------------------------------
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
; Return to ChADFS ROM
        ldx     $F4                             ; get our ROM slot number
        inx                                     ; ChADFS is in the slot above
        stx     $F4                             ; set MOS copy of ROMSEL to new slot number
        stx     $FE30                           ; switch to ChADFS ROM and continue there
; entry point from ChADFS ROM
        nop                                     ; allow address bus to stabilise
        jmp     LBFC5                           ; jump to dispatcher

; ----------------------------------------------------------------------------
