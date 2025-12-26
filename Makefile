ASM ?= customasm
ASM_FLAGS ?= --color=off
MAME ?= mame
MAMEDEBUG ?= -debug
MAMEFLAGS ?= -window -resolution 375x320 -nofilter $(MAMEDEBUG)

OUT = gamepock/egpcboot.bin \
	  gamepock/hellowd.bin \
	  gamepock/boing.bin \
	  gamepock/pokedemo.bin

.PHONY: compare
compare: $(OUT)
	shasum -c roms.sha1

.PHONY: run
run: gamepock/egpcboot.bin
	$(MAME) gamepock -rompath . $(MAMEFLAGS)

run-%: gamepock/%.bin gamepock/egpcboot.bin
	$(MAME) gamepock -rompath . $(MAMEFLAGS) -cart $<

$(OUT): gamepock/%.bin: %.asm gamepock.asm pd7806.asm
	@ mkdir -p gamepock
	$(ASM) $(ASM_FLAGS) $< \
	    -f binary -o $@ -- \
	    -f symbols -o gamepock/$*.sym

%.1bpp: %.png
	rgbgfx -Zd1 -o $@ $<

%.2bpp: %.png
	rgbgfx -Zd2 -o $@ $<

gamepock/egpcboot.bin: font.1bpp
gamepock/boing.bin: ball.2bpp
gamepock/pokedemo.bin: pokedemo/font.1bpp
gamepock/pokedemo.bin: pokedemo/marspr.1bpp
gamepock/pokedemo.bin: $(wildcard pokedemo/*.bin)
