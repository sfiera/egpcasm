ASM ?= customasm
ASM_FLAGS ?= --color=off --format=binary

OUT = gamepock/egpcboot.bin

.PHONY: compare
compare: $(OUT)
	shasum -c roms.sha1

.PHONY: run
run: $(OUT)
	mame gamepock -window -rompath . -resolution 375x320 -nofilter

$(OUT): egpcboot.asm gamepock.asm 7806.asm font.1bpp
	@ mkdir -p gamepock
	$(ASM) $(ASM_FLAGS) $< -o $@

font.1bpp: font.png
	rgbgfx -d1 -o $@ $<
