TMP:=.tmp
INF:=$(TMP)/CH101_tmp.inf

.PHONY:all
all:
	mkdir -p $(TMP)
	echo > $(INF)
	python ch101.py >> $(INF)
	echo "ASMINC {file \"CH101.inc\";};" >> $(INF)
	cat ./CH101.inf >> $(INF)
	da65 -o $(TMP)/CH101.asm -S 0x8000 -i $(INF) --comments 4 --text-column 65 CH101
	cat $(TMP)/CH101.asm | tail -n +3 > ./CH101_da65.asm
