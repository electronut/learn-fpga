"""

    blinky.py

    Basic blinky example for migen. 

    Tested with Lattice iCE40UP5K Eval Board.
    

    Mahesh Venkitachalam
    electronut.in

"""

from migen.fhdl import *
from migen import *
from migen.build.platforms import ice40_up5k_b_evn as board

class Blinky(Module):
    def __init__(self, led, maxperiod):
        counter = Signal(max=maxperiod+1)
        period = Signal(max=maxperiod+1)
        self.comb += period.eq(maxperiod)
        self.sync += If(counter == 0,
                led.eq(~led),
                counter.eq(period)).Else(
                counter.eq(counter - 1)
                )

# print
led = Signal()
my_Blinky = Blinky(led, 30000000)
print(verilog.convert(my_Blinky, ios={led}))

# set up RGB LED (red channel)
plat = board.Platform()
led = plat.request("rgb_led").r
my_Blinky = Blinky(led, 30000000)

# build
plat.build(my_Blinky)

# flash
prog = board.IceStormProgrammer()
prog.flash(0, "build/top.bin")
