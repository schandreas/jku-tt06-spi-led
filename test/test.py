# Copyright 2023 Andreas Scharnreitner
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles
from cocotb.utils import get_sim_time


@cocotb.test()
async def test_spi(dut):
    dut._log.info("Start SPI test")
    clock = Clock(dut.tbspi.sclk, 10, units="us")
    cocotb.start_soon(clock.start())

    #setup
    dut.tbspi.nsel.value = 1
    dut.tbspi.mosi.value = 0

    # reset
    dut._log.info("Reset SPI")
    dut.tbspi.nreset.value = 0
    await ClockCycles(dut.tbspi.sclk, 5)
    dut.tbspi.nreset.value = 1
    await ClockCycles(dut.tbspi.sclk, 5)

    #after reset the data should be 0
    assert dut.tbspi.data.value == 0
    #without nsel the data_rdy should be 1 (ready)
    assert dut.tbspi.data_rdy.value == 1

    await ClockCycles(dut.tbspi.sclk, 10)
    
    await FallingEdge(dut.tbspi.sclk)
    dut.tbspi.nsel.value = 0
    await FallingEdge(dut.tbspi.data_rdy)
    dut._log.info("SPI: Writing 0xAA")
    for i in range(8):
        dut.tbspi.mosi.value = i%2
        await ClockCycles(dut.tbspi.sclk, 1)

    dut.tbspi.nsel.value = 1
    await RisingEdge(dut.tbspi.data_rdy)
    
    assert dut.tbspi.data.value == 0xAA

    await ClockCycles(dut.tbspi.sclk, 10)
    
    await FallingEdge(dut.tbspi.sclk)
    dut.tbspi.nsel.value = 0
    await FallingEdge(dut.tbspi.data_rdy)
    dut._log.info("SPI: Writing 0xB3")
    for i in range(8):
        dut.tbspi.mosi.value = (0xB3 >> i)&1
        await ClockCycles(dut.tbspi.sclk, 1)

    dut.tbspi.nsel.value = 1
    await RisingEdge(dut.tbspi.data_rdy)
    
    assert dut.tbspi.data.value == 0xB3

    await ClockCycles(dut.tbspi.sclk, 10)

@cocotb.test()
async def test_rgbled(dut):
    dut._log.info("Start RGBLED test")
    clock = Clock(dut.tbrgbled.clk, 40, units="ns")
    cocotb.start_soon(clock.start())
    
    #setup
    dut.tbrgbled.data_rdy.value = 0

    dut._log.info("Reset RGBLED")
    dut.tbrgbled.nreset.value = 0
    await ClockCycles(dut.tbrgbled.clk, 5)
    dut.tbrgbled.nreset.value = 1
    await ClockCycles(dut.tbrgbled.clk, 5)

    dut._log.info("RGBLED Output Test")
    dut.tbrgbled.data.value = 0x112233445566AA00FF
    dut.tbrgbled.data_rdy.value = 1

    await RisingEdge(dut.tbrgbled.data_rdy)

    tim_start = get_sim_time('us')

    await RisingEdge(dut.tbrgbled.led)
    
    assert (get_sim_time('us') - tim_start) > 50
    tim_start = get_sim_time('ns')

    await FallingEdge(dut.tbrgbled.led)

    tim_mid = get_sim_time('ns')
    assert (tim_mid - tim_start) > 650
    assert (tim_mid - tim_start) < 950

    await RisingEdge(dut.tbrgbled.led)
    
    assert (get_sim_time('ns') - tim_mid) > 300
    assert (get_sim_time('ns') - tim_mid) < 600
    
    assert (get_sim_time('ns') - tim_start) > 650
    assert (get_sim_time('ns') - tim_start) < 1850

    for i in range(8):
        await RisingEdge(dut.tbrgbled.led)
    
    tim_start = get_sim_time('ns')

    await FallingEdge(dut.tbrgbled.led)

    tim_mid = get_sim_time('ns')
    assert (tim_mid - tim_start) > 250
    assert (tim_mid - tim_start) < 550

    await RisingEdge(dut.tbrgbled.led)
    
    assert (get_sim_time('ns') - tim_mid) > 700
    assert (get_sim_time('ns') - tim_mid) < 1000
    
    assert (get_sim_time('ns') - tim_start) > 650
    assert (get_sim_time('ns') - tim_start) < 1850
    
    await RisingEdge(dut.tbrgbled.rgbled_dut.do_res)
    
    tim_start = get_sim_time('us')
    
    await ClockCycles(dut.tbrgbled.clk, 10)
    await RisingEdge(dut.tbrgbled.led)

    assert (get_sim_time('us') - tim_start) > 50
    
    await ClockCycles(dut.tbrgbled.clk, 10)

# @cocotb.test()
# async def test_comp(dut):
#     dut._log.info("Combined Test")
#     clock = Clock(dut.dec.clk, 40, units="ns")
#     cocotb.start_soon(clock.start())
#     sclock = Clock(dut.dec.ui_in[1], 100, units="us")
#     cocotb.start_soon(sclock.start())

#     dut._log.info("Reset")
#     dut.dec.ena.value = 1
#     dut.dec.rst_n.value = 0
#     dut.dec.ui_in[2].value = 1
#     dut.dec.ui_in[0].value = 0    

#     await ClockCycles(dut.dec.clk, 10)
#     dut.dec.rst_n.value = 1

#     await FallingEdge(dut.dec.spi.sclk)

#     dut._log.info("Put in Data")
#     dut.dec.ui_in[2].value = 0
#     for i in range(72):
#         dut.dec.ui_in[0].value = i%2
#         await FallingEdge(dut.dec.spi.sclk)

#     dut.dec.ui_in[2].value = 1

#     dut._log.info("Await Output")
#     for i in range(72):
#         await RisingEdge(dut.dec.rgbled.led)

#     await ClockCycles(dut.dec.spi.sclk, 10)