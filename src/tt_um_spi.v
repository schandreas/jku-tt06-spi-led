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

module tt_um_spi #(parameter DATAWIDTH = 16)(
    output reg [DATAWIDTH-1 : 0]    data,
    output wire                     data_rdy,
    input wire                      nreset,
    input wire                      mosi,
    input wire                      sclk,
    input wire                      nsel
);

    assign data_rdy = nsel;

    always @(posedge sclk) begin
        if (nreset) begin
            if (nsel) begin
            end
            else begin
                data[DATAWIDTH-2:0] <= data[DATAWIDTH-1:1];
                data[DATAWIDTH-1] <= mosi;
            end
        end
        else begin
            data <= {DATAWIDTH{1'b0}};
        end
    end

endmodule

