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

module tt_um_rgbled_decoder #(parameter LEDS = 8, parameter BITS_PER_LED = 24) (
    input  wire [7:0] ui_in,    // Dedicated inputs - connected to the input switches
    output wire [7:0] uo_out,   // Dedicated outputs - connected to the 7 segment display
    input  wire [7:0] uio_in,   // IOs: Bidirectional Input path
    output wire [7:0] uio_out,  // IOs: Bidirectional Output path
    output wire [7:0] uio_oe,   // IOs: Bidirectional Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    wire nreset;
    wire [(LEDS*BITS_PER_LED)-1 : 0] data;
    wire data_rdy;

    assign nreset = rst_n & ena;

    tt_um_rgbled #(LEDS,BITS_PER_LED) rgbled(
        .clk(clk),
        .data(data),
        .data_rdy(data_rdy),
        .nreset(nreset),
        .led(uo_out[0])
    );

    tt_um_spi #(LEDS*BITS_PER_LED) spi (
        .data(data),
        .data_rdy(data_rdy),
        .nreset(nreset),
        .mosi(ui_in[0]),
        .sclk(ui_in[1]),
        .nsel(ui_in[2])
        );

    assign uo_out[7:1] = 7'b0;
    assign uio_oe = 8'b0;
    assign uio_out = 8'b0;

endmodule
