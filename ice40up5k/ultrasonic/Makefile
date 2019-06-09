# Project setup
PROJ      = ultrasonic
BUILD     = ./build
DEVICE    = 1k
FOOTPRINT = vq100

# Files
FILES = top.v seven_seg_cc_4d.v bin_to_bcd.v edge_detect.v

.PHONY: all clean burn

all:
	# if build folder doesn't exist, create it
	mkdir -p $(BUILD)
	# synthesize using Yosys
	yosys -p "synth_ice40 -top top -blif $(BUILD)/$(PROJ).blif" $(FILES)
	# Place and route using arachne
	arachne-pnr -d $(DEVICE) -P $(FOOTPRINT) -o $(BUILD)/$(PROJ).asc -p $(PROJ).pcf $(BUILD)/$(PROJ).blif
	# Convert to bitstream using IcePack
	icepack $(BUILD)/$(PROJ).asc $(BUILD)/$(PROJ).bin

synth:
	# synthesize using Yosys
	yosys -p "synth_ice40 -top top -blif $(BUILD)/$(PROJ).blif" $(FILES)
	
burn:
	iCEburn -ew $(BUILD)/$(PROJ).bin

clean:
	rm build/*
