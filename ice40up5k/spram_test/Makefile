PROJ = spram_test
PIN_DEF = spram_test.pcf
DEVICE = up5k

ARACHNE = arachne-pnr 
ARACHNE_ARGS = 
ICEPACK = icepack
ICETIME = icetime
ICEPROG = iceprog

all: $(PROJ).bin

%.blif: top.v vga_640x480.v pll.v spram.v spram_io.v
	yosys -p 'synth_ice40 -top top -blif $@' $^

%.asc: $(PIN_DEF) %.blif
	$(ARACHNE) $(ARACHNE_ARGS) -d $(subst up,,$(subst hx,,$(subst lp,,$(DEVICE)))) -o $@ -p $^

%.bin: %.asc
	$(ICEPACK) $< $@

%.rpt: %.asc
	$(ICETIME) -d $(DEVICE) -mtr $@ $<

prog: $(PROJ).bin
	$(ICEPROG) -S $<

sudo-prog: $(PROJ).bin
	@echo 'Executing prog as root!!!'
	sudo $(ICEPROG) $<

sudo-prog-ram: $(PROJ).bin
	@echo 'Executing prog as root!!!'
	sudo $(ICEPROG) -S $<
sim:
	iverilog -o tb.out -s tb testbench.v vga_640x480.v spram_sim.v spram_io.v
	vvp tb.out

sim-show:
	gtkwave testbench.vcd   
	
clean:
	rm -f $(PROJ).blif $(PROJ).asc $(PROJ).rpt $(PROJ).bin log.txt out.txt

.SECONDARY:
.PHONY: all prog clean

# make > out.txt 2>&1   