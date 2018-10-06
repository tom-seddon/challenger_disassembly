# -*- mode:makefile-gmake; -*-
##########################################################################
##########################################################################

TMP:=.tmp
INF200:=$(TMP)/CH200.inf
INFADFS:=$(TMP)/CHADFS.inf
DAOPTS:=--comments 4 --text-column 65

##########################################################################
##########################################################################

.PHONY:all
all:
	mkdir -p $(TMP)

	echo > $(INF200)
	python CH200.py >> $(INF200)
	echo "ASMINC {file \"CH200.inc\";};" >> $(INF200)
	cat ./CH200.inf >> $(INF200)
	da65 -o $(TMP)/CH200.asm -S 0x8000 -i $(INF200) $(DAOPTS) CH200.rom
	cat $(TMP)/CH200.asm | tail -n +3 > ./CH200_da65.asm

	echo > $(INFADFS)
	python CHADFS.py >> $(INFADFS)
	echo "ASMINC {file \"CHADFS.inc\";};" >> $(INFADFS)
	cat ./CHADFS.inf >> $(INFADFS)
	da65 -o $(TMP)/CHADFS.asm -S 0x8000 --cpu 65c02 -i $(INFADFS) $(DAOPTS) CHADFS.rom
	cat $(TMP)/CHADFS.asm | tail -n +3 > ./CHADFS_da65.asm
