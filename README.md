# Challenger ROM disassembly

The Opus Challenger 3-in-1 was a combined disc interface, disc drive
and RAM disc for the BBC Micro.

Pics and stuff: http://chrisacorns.computinghistory.org.uk/8bit_Upgrades/Opus_Challenger3.html, http://www.beebmaster.co.uk/8bit/Challenger.html

Some tech info: http://modelb.bbcmicro.com/tech-challenger.html

Stardot thread about the much rarer Challenger 2.00, with Master
128-only ADFS support:
https://stardot.org.uk/forums/viewtopic.php?f=32&t=11795&hilit=challenger+adfs&start=30

# Repo

## `200`

Disassembly of Challenger 2.00 ROM. The ROM is 32K, so it's in two
parts - see `CH200.asm` and `CHADFS.asm`

## `101`

Quick disassembly of the Challenger 1.01 ROM - see `CH101.asm`.

Not sure how far I'm going to go with this. For now it's for
comparison to the 2.00 ROM only.

## `originals`

Original ROMs, random Slogger advert pic, and anything else I find.

## `tools`

Tools for use on PC. So far, just the ROM patcher that makes the BBC B
version of Challenger 2.00.

## `beeb`

[BeebLink](https://github.com/tom-seddon/beeblink) volume holding some
test programs and the patched 2.00 ROM for use with BBC B.

# Patched 2.00 ROM info

The original Challenger 2.00 ROM sort-of works on its own in a BBC B,
but doesn't initialise properly without the ADFS ROM, effectively
making it Master-only. The patched version fixes this. Full list of
changes:

* initialise DFS properly on reset
* tidy up wonky `*CAT` output
* advertises itself as version `200A`

See `beeb/chaldis/1/R.PCH200`.

**Use at your own risk**!

# Building

The build outputs are in the repo already, so you only need to do this
if you're going to modify something...

Prerequisites:

* [da65](https://cc65.github.io/doc/da65.html)
* Python 2.x on PATH
* Some kind of Unix with all the usual Unix stuff

The build process does the following:

* run da65 to generate initial Challenger 1.01 disassembly (outputs `./101/CH101.asm`)
* run da65 to generate initial Challenger 2.00 disassembly (outputs `./200/CH200.asm` and `./200/CHADFS.asm`)
* run `./tools/patch_ch200.py` to generate patched Challenger 2.00 ROM for use on BBC B (outputs `./beeb/chaldis/1/R.CH200P`)

Type `make` to run it.

