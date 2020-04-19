
CROSS=riscv32-unknown-elf-
CFLAGS=

PICORV32_DIR=../picorv32
PICOSOC_DIR=$(PICORV32_DIR)

# ---- Lattice iCE40 Ultra Plus Breakout Board ----

lice40upsim: lice40up_tb.vvp lice40up_fw.hex
	vvp -N $< +firmware=lice40up_fw.hex

lice40upsynsim: lice40up_syn_tb.vvp lice40up_fw.hex
	vvp -N $< +firmware=lice40up_fw.hex

lice40up.json: lice40up.v ice40up5k_spram.v spimemio.v simpleuart.v picosoc.v $(PICORV32_DIR)/picorv32.v
	yosys -ql lice40up.log -p 'synth_ice40 -top lice40up -json lice40up.json' $^

lice40up_tb.vvp: lice40up_tb.v lice40up.v ice40up5k_spram.v spimemio.v simpleuart.v picosoc.v $(PICORV32_DIR)/picorv32.v spiflash.v
	iverilog -s testbench -o $@ $^ `yosys-config --datdir/ice40/cells_sim.v`

lice40up_syn_tb.vvp: lice40up_tb.v lice40up_syn.v spiflash.v
	iverilog -s testbench -o $@ $^ `yosys-config --datdir/ice40/cells_sim.v`

lice40up_syn.v: lice40up.json
	yosys -p 'read_json lice40up.json; write_verilog lice40up_syn.v'

lice40up.asc: lice40up.pcf lice40up.json
	nextpnr-ice40 --freq 13 --up5k --asc lice40up.asc --pcf lice40up.pcf --json lice40up.json

lice40up.bin: lice40up.asc
	icetime -d up5k -c 12 -mtr lice40up.rpt lice40up.asc
	icepack lice40up.asc lice40up.bin

lice40upprog: lice40up.bin lice40up_fw.bin
	iceprog lice40up.bin
	iceprog -o 1M lice40up_fw.bin

lice40upprog_fw: lice40up_fw.bin
	iceprog -o 1M lice40up_fw.bin

lice40up_sections.lds: sections.lds
	$(CROSS)cpp -P -DLICE40UP -o $@ $^

lice40up_fw.elf: lice40up_sections.lds start.s firmware_lice40up.c
	$(CROSS)gcc $(CFLAGS) -DLICE40UP -march=rv32ic -Wl,-Bstatic,-T,lice40up_sections.lds,--strip-debug -ffreestanding -nostdlib -o lice40up_fw.elf start.s firmware_lice40up.c

lice40up_fw.hex: lice40up_fw.elf
	$(CROSS)objcopy -O verilog lice40up_fw.elf lice40up_fw.hex

lice40up_fw.bin: lice40up_fw.elf
	$(CROSS)objcopy -O binary lice40up_fw.elf lice40up_fw.bin

# ---- Testbench for SPI Flash Model ----

spiflash_tb: spiflash_tb.vvp firmware.hex
	vvp -N $<

spiflash_tb.vvp: spiflash.v spiflash_tb.v
	iverilog -s testbench -o $@ $^

# ---- ASIC Synthesis Tests ----

cmos.log: spimemio.v simpleuart.v picosoc.v $(PICORV32_DIR)/picorv32.v
	yosys -l cmos.log -p 'synth -top picosoc; abc -g cmos2; opt -fast; stat' $^

# ---- Clean ----

clean:
	rm -f testbench.vvp testbench.vcd spiflash_tb.vvp spiflash_tb.vcd
	rm -f lice40up_fw.elf lice40up_fw.hex lice40up_fw.bin
	rm -f lice40up.json lice40up.log lice40up.asc lice40up.rpt lice40up.bin
	rm -f lice40up_syn.v lice40up_syn_tb.vvp lice40up_tb.vvp

.PHONY: spiflash_tb clean
.PHONY: lice40upprog lice40upprog_fw lice40upsim lice40upsynsim