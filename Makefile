ASM ?= customasm
ASM_FLAGS ?= --color=off
MAME ?= mame
MAMEDEBUG ?= -debug
MAMEFLAGS ?= -window -resolution 375x320 -nofilter $(MAMEDEBUG)

OUT = gamepock/egpcboot.bin gamepock/hellowd.bin

.PHONY: compare
compare: $(OUT)
	shasum -c roms.sha1

.PHONY: run
run: gamepock/egpcboot.bin
	$(MAME) gamepock -rompath . $(MAMEFLAGS)

.PHONY: run-hellowd
run-hellowd: gamepock/hellowd.bin gamepock/egpcboot.bin
	$(MAME) gamepock -rompath . $(MAMEFLAGS) -cart $<

$(OUT): gamepock/%.bin: %.asm gamepock.asm pd7806.asm
	@ mkdir -p gamepock
	$(ASM) $(ASM_FLAGS) $< \
	    -f binary -o $@ -- \
	    -f symbols -o gamepock/$*.sym

gamepock/egpcboot.bin: font.1bpp

font.1bpp: font.png
	rgbgfx -Zd1 -o $@ $<
