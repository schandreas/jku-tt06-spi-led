// Copyright 2023 Andreas Scharnreitner
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

`default_nettype none
`timescale 1ns/1ps

/*
this testbench just instantiates the module and makes some convenient wires
that can be driven / tested by the cocotb test.py
*/

// testbench is controlled by test.py
module tb_spi ();

    parameter DATAWIDTH = 8;

    // wire up the inputs and outputs
    reg nreset;
    reg mosi;
    reg sclk;
    reg nsel;

    wire [DATAWIDTH-1 : 0]data;
    wire data_rdy;
    

    tt_um_spi #(DATAWIDTH) spi_dut (
        .data(data),
        .data_rdy(data_rdy),
        .nreset(nreset),
        .mosi(mosi),
        .sclk(sclk),
        .nsel(nsel)
        );

endmodule
