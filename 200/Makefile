TMP:=.tmp
INF:=$(TMP)/CH200.inf

.PHONY:all
all:
	mkdir -p $(TMP)
	echo > $(INF)
	python strings.py >> $(INF)
	echo "ASMINC {file \"CH200.inc\";};" >> $(INF)
	cat ./CH200.inf >> $(INF)
	da65 -o CH200.asm -S 0x8000 -i $(INF) --comments 4 --text-column 65 CH200.rom

