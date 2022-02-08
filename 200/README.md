# Notes

## CHADFS->CH200 request reasons

CHADFS makes these requests by calling $bff2 with the reason code in
A.

0 = handle `*CONFIG*`
1 = transfer data
2 = test Challenger presence and RAM size. Set ROM status byte at $0DFx to 0 (no Challenger), 1 (256K) or 2 (512K)
3 = reset drive mappings for both ADFS and DFS
4 = format the RAM disc as an ADFS volume

## Challenger RAM layout

Addresses are of the form R$PPPOO where PPP is the page number
(000-3ff for 256K, 000-7ff for 512K) and OO the offset in the page.
The R distinguishes this from BBC RAM.

* R$00000-R$00007 - DFS drive mappings. Bottom 4 bits of each byte are
  mapping for drive 0-7 respectively

* R$00008-R$0000F - ADFS drive mappings, ditto

* R$00100 - bottom 7 bits are $65 if Challenger RAM initialised. Top
  bit is 1 if Challenger FS is active
  
* R$001FD - equals $e5 if the RAM discs have been formatted

* R$001DD - if not $ff, bit 7 set if NMI area claimed. Low nybble
  is slot of previous owner?

* R$001ED - density flag - bit 6 = double

* R$001EE - ROM to select when loading or saving, as set by *OPT9

* R$001F4 - *ENABLE CAT if bit 7 set
