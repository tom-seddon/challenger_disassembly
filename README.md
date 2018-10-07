# Challenger ROM disassembly

The Opus Challenger 3-in-1 was a combined disc interface, disc drive
and RAM disc for the BBC Micro.

This repo exists to provide a disassembly of the Challenger 2.00 ROM,
the last ROM made for it, and to provide a patched version suitable
for use with a BBC B (since as supplied it effectively only works on
the BBC Master).

The current disassembly is the raw output from
[da65](https://cc65.github.io/doc/da65.html), with meaningful labels
and (hopefully) most of the code and data separated out. In the long,
I intend to start working on it by and, making it
[64tass](http://tass64.sourceforge.net/)-friendly, adding comments,
adding appropriate org directives for the NMI routines, turning
absolute addresses into label-relative offsets when necessary, adding
`<` and `>` operators where appropriate, ond so on...

# Challenger info

Pics and stuff: http://chrisacorns.computinghistory.org.uk/8bit_Upgrades/Opus_Challenger3.html, http://www.beebmaster.co.uk/8bit/Challenger.html

Some tech info: http://modelb.bbcmicro.com/tech-challenger.html

Stardot thread about Challenger 2.00, with Master 128-only ADFS
support:
https://stardot.org.uk/forums/viewtopic.php?f=32&t=11795&hilit=challenger+adfs&start=30

# Patched 2.00 ROM

The Challenger 2.00 DFS ROM sort-of works on its own in a BBC B, but
doesn't initialise properly without the ADFS ROM, effectively making
it Master-only (and going by the code I actually suspect it wouldn't
work on its own even then). The patched version fixes this. Full list
of changes:

* initialise DFS properly on reset
* tidy up wonky `*CAT` output
* advertises itself as version `200A`

The patched ROM image is in the repo as `beeb/chaldis/1/R.PCH200`.

**Use at your own risk**! - I do use this patched ROM in my BBC B
myself, and no problems noted so far, but I don't store anything
important on discs...

The patched ROM should work on the Master, with or without the ADFS
part, but I haven't tested this.

# Repo layout

## `200`

Disassembly of Challenger 2.00 ROM. The ROM is 32K, so it's in two
parts - see `CH200_da65.asm` and `CHADFS_da65.asm`

## `101`

Quick disassembly of the Challenger 1.01 ROM - see `CH101_da65.asm`.

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

# Building

The build outputs are in the repo already, so you only need to do this
if you're going to modify something...

Prerequisites:

* [da65](https://cc65.github.io/doc/da65.html)
* Python 2.x on PATH
* Some kind of Unix with all the usual Unix stuff (I use Mac OS X)

The build process does the following:

* run da65 to generate initial Challenger 1.01 disassembly (outputs
  `./101/CH101_da65.asm`)
* run da65 to generate initial Challenger 2.00 disassembly (outputs
  `./200/CH200_da65.asm` and `./200/CHADFS_da65.asm`)
* run `./tools/patch_ch200.py` to generate patched Challenger 2.00 ROM
  for use on BBC B (outputs `./beeb/chaldis/1/R.CH200P`)

Type `make` to run it.

(So far, I've been working entirely with the output from da65. Once
I'm happy I've got all (or nearly all...) the labels and code/data
sorted out, I'll be taking a copy of the initial disassembly, making
it -friendly, and hand-editing
it to add comments, appropriate org directives for the NMI routines,
`<` and `>` operators for the jump tables, and so on.
