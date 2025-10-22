ASM ?= customasm
ASM_FLAGS ?= --color=off

OUT = gamepock/egpcboot.bin

.PHONY: compare
compare: $(OUT)
	shasum -c roms.sha1

.PHONY: run
run: $(OUT)
	mame gamepock -window -rompath . -resolution 375x320 -nofilter

.PHONY: debug
debug: $(OUT)
	mame gamepock -window -rompath . -resolution 375x320 -nofilter -debug

$(OUT): gamepock/%.bin: %.asm gamepock.asm pd7806.asm font.1bpp
	@ mkdir -p gamepock
	$(ASM) $(ASM_FLAGS) $< \
	    -f binary -o $@ -- \
	    -f symbols -o gamepock/$*.sym

font.1bpp: font.png
	rgbgfx -Zd1 -o $@ $<
