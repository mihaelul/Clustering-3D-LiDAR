module octree_stream #(
    parameter CX = 32,
    parameter CY = 32,
    parameter CZ = 32
)(
    input clk,
    input rst,

    input  [7:0] x,
    input  [7:0] y,
    input  [7:0] z,
    input        valid,
    input        last,

    output reg [3:0] label,
    output reg       out_valid,
    output reg       done
);

    wire bx = (x >= CX);
    wire by = (y >= CY);
    wire bz = (z >= CZ);

    wire [2:0] octant = {bx, by, bz};

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            label     <= 0;
            out_valid <= 0;
            done      <= 0;
        end else begin
            out_valid <= 0;

            if (valid) begin
                label     <= octant + 1;
                out_valid <= 1;

                if (last)
                    done <= 1;
            end
        end
    end
endmodule
