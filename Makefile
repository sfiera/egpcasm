ASM ?= customasm
ASM_FLAGS ?= --color=off --format=binary

.PHONY: compare
compare: egpcboot.bin
	shasum -c roms.sha1

egpcboot.bin: egpcboot.asm
	$(ASM) $(ASM_FLAGS) $< -o $@
