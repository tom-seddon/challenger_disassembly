svc=$802f
print_string_2_nterm=$a8ad ; can't figure out what this bit is...
fdc_status_or_cmd=$fcf8
fdc_track=$fcf9
fdc_sector=$fcfa
fdc_data=$fcfb
fdc_control=$fcfc
ram_paging_msb=$fcfe
ram_paging_lsb=$fcff
osfile=$ffdd
osargs=$ffda
osbget=$ffd7
osbput=$ffd4
osgbpb=$ffd1
osfind=$ffce
fscv=$21e
osrdch=$ffe0
osasci=$ffe3
oswrch=$ffee
osword=$fff1
osbyte=$fff4
oscli=$fff7
gsinit=$ffc2
gsread=$ffc5
extract_xx000000=$a994
extract_00xx0000=$a996
extract_0000xx00=$a998
lsr_x5=$a99d
lsr_x4=$a99e
asl_x4=$a9a4
iny_x8=$a9a9
iny_x7=$a9aa
iny_x4=$a9ad
dey_x8=$a9b2
dey_x4=$a9b6
toupper=$a9bb
toupper_was_nonalpha=$a9cb
toupper_was_alpha=$a9cd
isalpha=$a9d1
print_hex_byte=$a978
print_hex_nybble=$a980
acknowledge_escape=$a98f
get_rom_status_byte=$8219
call_osbyte=$adf6
osbyte_yff=$adf4
osbyte_x00_yff=$adf2
osbyte_aff_x00_yff=$adf0
osbyte_get_rom_pointer_table_address=$ade8
osbyte_rom_service_request=$adec
osbyte_read_tube_presence=$ade4
osbyte_x00_y00=$add1
osbyte_y00=$add3
osbyte_select_output_stream_a=$add7
osbyte_select_output_stream=$add8
osbyte_read_character_destination=$addc
check_challenger_presence=$8236
probe_challenger_ram_size=$821f	;also CHADFS request $02
push_registers_and_tuck_restoration_thunk=$a84c
svc_handle_absolute_workspace_claim=$8033
svc_handle_private_workspace_claim=$808b
svc_handle_auto_boot=$809a
svc_handle_star=$80ba
svc_handle_help=$80de
svc_handle_init_fs=$8117
svc_handle_unknown_osword=$8128
select_ram_page_000=$be07
select_ram_page_001=$be0c
select_ram_page_002=$be11
select_ram_page_003=$be16
select_ram_page_009=$be1b
select_ram_page_by_lsb=$be1e
print_string_nterm=$a8d3
print_string_255term=$a917
print_CHALLENGER=$ae5e ; if C clear on entry, also print version number
strings_offsets_table=$9007
strings_data=$900e
print_table_string=$8ff7 ; 0="off" 1="LOAD" 2="RUN" 3="EXEC" 4="inactive" 5="256K" 6="512K"
dobrk_with_Disk_prefix=$a892
dobrk_with_Bad_prefix=$a89c
dobrk_with_File_prefix=$a8a5
do_load_boot=$8344
do_run_boot=$833e
do_exec_boot=$8338
do_boot=$8332
set_f2_y=$9238 ; ?&F2=X, ?&F3=Y, Y=0
print_char_without_spool=$a951 ; prints char, disabling *SPOOL first
print_N_without_spool=$a94b
print_dot_without_spool=$a94f
print_space_without_spool=$a818
print_2_spaces_without_spool=$a815
print_N_spaces_without_spool=$8add ; Y = number of spaces to print
print_disc_title=$8ed7
write_command=$bcfa
write_sector=$bcfe
write_data=$bd02
command_table=$90b4
init_sta_abx_thunk=$9218 ; YX = addr - create little thunk at $AA that does STA addr,X - YX = addr
init_lda_abx_thunk=$921e ; YX = addr - create little thunk at $AA that does LDA addr,X
print_logical_drive_list_loop=$ab06
gsinit_with_carry_clear=$a9f2
chosfile=$a16e
chosargs=$9b62
chosbget=$9cd1
chosbput=$9d9e
chosgbpb=$a2dc
chosfind=$9961
chosfsc=$975f
osfsc_routines_lsbs=$ae15
osfsc_routines_msbs=$ae21
osargs_y0_routines_lsbs=$ae2d
osargs_y0_routines_msbs=$ae30
osfile_routines_lsbs=$ae33
osfile_routines_msbs=$ae3b
osgbpb_routines_lsbs=$ae43
osgbpb_routines_msbs=$ae4c
osgbpb_routines_flags=$ae55
osfsc_opt=$9775
osfsc_eof=$9808
osfsc_run=$9820 ; does triple duty - *RUN, */ and libfs *RUN
osfsc_star=$989c
osfsc_cat=$98ae
osfsc_shut_down_fs=$8905
osfsc_get_handle_range=$9917
osfsc_oscli=$991c
osfsc_ex=$8c0b
osfsc_info=$8c19
osargs_update_all_files=$9ba2
osargs_get_fs_type=$9b8c
osargs_get_command_line_tail=$9b8f
osfile_save=$a1ef
osfile_write_metadata=$a1a0
osfile_write_load=$a1b0
osfile_write_exec=$a1bb
osfile_write_attr=$a1c3
osfile_read_metadata=$a1cb
osfile_delete=$a1da
osfile_create=$a1e3
osgbpb_done=$a39b
osgbpb_pb=$a39c
osgbpb_gb=$a3a4
osgbpb_get_media_metadata=$a3ac
osgbpb_read_cur_dir=$a3e1
osgbpb_read_lib_dir=$a3f0
osgbpb_read_names=$a3ff
osfsc_opt_routines=$97f4
osfsc_opt_0_or_1=$9793
osfsc_opt_2_or_3_or_5=$9788
osfsc_opt_4=$979d
osfsc_opt_6=$97ba
osfsc_opt_7=$97ce
osfsc_opt_8=$97d9
osfsc_opt_9=$97ec
inc_AEw=$a9eb
do_sec=$a9df
xtoi=$a9e1
set_rom_status_byte_msb=$a940
osword_7f_read_data_or_deleted_data=$b78c
osword_7f_write_data=$b78f
osword_7f_verify_data=$b798
osword_7f_write_deleted_data=$b795
osword_7f_read_special_registers=$b88c
osword_7f_write_special_registers=$b86f
osword_7f_initialise=$b863
osword_7f_seek=$b7da
osword_7f_read_drive_status=$b859
osword_7f_command_1b=$b7ed
osword_7f_command_23=$b83e
fdc_control_table=$b8ef
chadfs_request_01=$bfa8
chadfs_request_03=$ab7e
chadfs_request_04=$be28