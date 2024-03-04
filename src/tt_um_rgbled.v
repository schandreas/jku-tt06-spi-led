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

module tt_um_rgbled #(parameter LEDS = 4, parameter BITS_PER_LED = 24)(
    output wire                             led,
    input wire [(LEDS*BITS_PER_LED)-1 : 0]  data,
    input wire                              clk,
    input wire                              data_rdy,
    input wire                              nreset
);

    reg [$clog2(LEDS*BITS_PER_LED) - 1 : 0] bit_cnt;
    reg [4 : 0] timer_cnt;
    reg do_res;
    wire [4 : 0] cmp;

    always @(posedge clk) begin
        if (nreset & data_rdy) begin
            timer_cnt <= timer_cnt + 1'b1;
            if (timer_cnt == 31) begin
                bit_cnt <= bit_cnt + 1'b1;
                if (do_res) begin
                    if(bit_cnt == 41) begin
                        bit_cnt <= {$clog2(LEDS*BITS_PER_LED){1'b0}};
                        do_res <= 1'b0;
                    end
                end
                else begin
                    if(bit_cnt == (LEDS*BITS_PER_LED)-1) begin
                        bit_cnt <= {$clog2(LEDS*BITS_PER_LED){1'b0}};
                        do_res <= 1'b1;
                    end
                end
            end
        end
        else begin
            bit_cnt <= {$clog2(LEDS*BITS_PER_LED){1'b0}};
            do_res <= 1'b1;
            timer_cnt <= 5'b0;
        end
    end

    assign cmp = data[bit_cnt] ? 20 : 10;

    assign led = (!do_res) & (data_rdy) & (timer_cnt <= cmp);

endmodule

