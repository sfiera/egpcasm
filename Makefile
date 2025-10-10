ASM ?= customasm
ASM_FLAGS ?= --color=off --format=binary

.PHONY: compare
compare: egpcboot.bin
	shasum -c roms.sha1

egpcboot.bin: egpcboot.asm gamepock.asm 7806.asm font.1bpp
	$(ASM) $(ASM_FLAGS) $< -o $@

font.1bpp: font.png
	rgbgfx -d1 -o $@ $<
