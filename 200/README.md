# Challenger ADFS

The elusive Challenger ADFS!

https://stardot.org.uk/forums/viewtopic.php?f=32&t=11795&hilit=challenger+adfs&start=30

See `CH200.asm` and `CHADFS.asm`.

# Notes

## CHADFS->CH200 request reasons

CHADFS makes these requests by calling $bff2 with the reason code in
A.

0 = handle `*CONFIG*`
1 = ?
2 = test Challenger presence and RAM size. Set ROM status byte at $0DFx to 0 (no Challenger), 1 (256K) or 2 (512K)
3 = reset drive mappings for both ADFS and DFS
4 = ?

## Challenger RAM layout

Addresses are of the form R$PPPOO where PPP is the page number
(000-3ff for 256K, 000-7ff for 512K) and OO the offset in the page.
The R distinguishes this from BBC RAM.

