ASM ?= customasm
ASM_FLAGS ?= --color=off --format=binary

.PHONY: compare
compare: egpcboot.bin
	shasum -c roms.sha1

egpcboot.bin: egpcboot.asm gamepock.asm 7806.asm
	$(ASM) $(ASM_FLAGS) $< -o $@
