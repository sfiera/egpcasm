ASM ?= customasm
ASM_FLAGS ?= --color=off
MAME ?= mame
MAMEDEBUG ?= -debug
MAMEFLAGS ?= -window -resolution 375x320 -nofilter $(MAMEDEBUG)

BIN = gamepock/astrobom.bin \
      gamepock/blockmaz.bin \
      gamepock/egpcboot.bin \
	  gamepock/hellowd.bin \
	  gamepock/boing.bin \
	  gamepock/pokedemo.bin \
	  gamepock/pokemahj.bin \
	  gamepock/pokereve.bin \
	  gamepock/sokoban.bin
OUT = $(BIN) \
	  gamepock/sokoban-pre0125.bin

.PHONY: compare
compare: $(OUT)
	shasum -c roms.sha1

.PHONY: run
run: gamepock/egpcboot.bin
	$(MAME) gamepock -rompath . $(MAMEFLAGS)

run-%: gamepock/%.bin gamepock/egpcboot.bin
	$(MAME) gamepock -rompath . $(MAMEFLAGS) -cart $<

$(BIN): gamepock/%.bin: %.asm gamepock.asm pd7806.asm
	@ mkdir -p gamepock
	$(ASM) $(ASM_FLAGS) $< \
	    -f binary -o $@ -- \
	    -f symbols -o gamepock/$*.sym

gamepock/sokoban-pre0125.bin: sokoban.asm gamepock.asm pd7806.asm
	@ mkdir -p gamepock
	$(ASM) $(ASM_FLAGS) $< \
	    -d VERSION=1_25 \
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
gamepock/sokoban.bin: sokoban/font.1bpp
gamepock/sokoban.bin: sokoban/background.1bpp
gamepock/sokoban.bin: sokoban/objects.2bpp
