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

push_registers_and_tuck_restoration_thunk=$a8ab
check_challenger_presence=$81ef
reset_drive_mappings=$abba
select_ram_page_000=$be23
select_ram_page_001=$be28
select_ram_page_002=$be2d
select_ram_page_003=$be32
select_ram_page_009=$be37

inc_AEw=$aa4b
get_rom_status_byte=$81e9

osbyte_read_character_destination=$ae27
osbyte_read_tube_presence=$ae2f
osbyte_get_rom_pointer_table_address=$ae33
osbyte_rom_service_request=$ae37
osbyte_aff_x00_yff=$ae3b
osbyte_x00_yff=$ae3d
osbyte_yff=$ae3f
osbyte_x00_y00=$ae1c
osbyte_y00=$ae1e
call_osbyte=$ae41
osbyte_select_output_stream_a=$ae22
osbyte_select_output_stream=$ae23
