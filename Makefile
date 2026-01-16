YOSYS = yosys
NEXTPNR = nextpnr-himbaechel
GOWIN_PACK = gowin_pack
OPENFPGALOADER = openFPGALoader

FAMILY = GW2A-18
DEVICE = GW2A-LV18PG256C8/I7

TOP = Maze
NAME = blink

CONSTRAINTS = src/constraints.cst

BUILD_DIR = build

all: build

build: $(BUILD_DIR)/$(NAME).fs

upload: $(BUILD_DIR)/$(NAME).fs
	$(OPENFPGALOADER) -b tangprimer20k $<

$(BUILD_DIR)/$(NAME).fs: $(BUILD_DIR)/$(NAME).json
	$(GOWIN_PACK) -d $(DEVICE) -o $@ $<

$(BUILD_DIR)/$(NAME).json: $(BUILD_DIR)/$(NAME)_netlist.json $(CONSTRAINTS)
	$(NEXTPNR) --json $< --write $@ --vopt family=$(FAMILY) --device $(DEVICE) --vopt cst=$(CONSTRAINTS)

$(BUILD_DIR)/$(NAME)_netlist.json: src/* src/layouts/*
	@mkdir -p $(BUILD_DIR)
	$(YOSYS) -p "read_verilog src/*.v src/layouts/*.v; synth_gowin -top $(TOP); write_json $@"

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all build upload clean
