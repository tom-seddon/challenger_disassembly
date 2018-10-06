Challenger ROM disassembly
==========================

The Opus Challenger 3-in-1 was a combined disc interface, disc drive
and RAM disc for the BBC Micro.

Pics and stuff: http://chrisacorns.computinghistory.org.uk/8bit_Upgrades/Opus_Challenger3.html, http://www.beebmaster.co.uk/8bit/Challenger.html

Some tech info: http://modelb.bbcmicro.com/tech-challenger.html

Folders
=======

`200` - disassembly of Challenger 2.00 ROM

`101` - quick disassembly of the Challenger 1.01 ROM. Not sure how
far I'm going to go with this. For now it's for comparison to the 2.00
ROM only

`originals` - original ROMs, random Slogger advert

`tools` - tools for use on PC

`beeb` - [BeebLink](https://github.com/tom-seddon/beeblink) volume
holding some test programs

Building
========

The build outputs are in the repo already, so you only need to do this
if you're going to modify something.

Prerequisites:

* [da65](https://cc65.github.io/doc/da65.html)
* Python 2.x on PATH
* Some kind of Unix with all the usual Unix stuff

The build process does the following:

* run da65 to regenerate Challenger 1.01 disassembly (outputs `./101/CH101.asm`)
* run da65 to regenerate Challenger 2.00 disassembly (outputs `./200/CH200.asm` and `./200/CHADFS.asm`)
* run Python tool to generate patched Challenger 2.00 ROM for use on BBC B (outputs `./beeb/chaldis/1/R.CH200P`)

Type `make` to run it.
