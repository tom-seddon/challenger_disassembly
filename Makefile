# -*- mode:makefile-gmake; -*-
##########################################################################
##########################################################################

.PHONY:all
all:
	$(MAKE) ch200_bbc_b
	$(MAKE) -C 101
	$(MAKE) -C 200

##########################################################################
##########################################################################

.PHONY:ch200_bbc_b
ch200_bbc_b: OUT:=./beeb/chaldis/1
ch200_bbc_b:
	mkdir -p $(OUT)
	python ./tools/patch_ch200.py -o '$(OUT)/R.PCH200' --inf ./200/CH200.rom
