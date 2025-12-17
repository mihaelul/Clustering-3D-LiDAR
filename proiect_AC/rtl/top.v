module top (
    input clk,
    input rst,

    input  [7:0] x,
    input  [7:0] y,
    input  [7:0] z,
    input        valid,
    input        last,

    output [3:0] label,
    output       out_valid,
    output       done
);

    octree_stream OCT (
        .clk(clk),
        .rst(rst),
        .x(x),
        .y(y),
        .z(z),
        .valid(valid),
        .last(last),
        .label(label),
        .out_valid(out_valid),
        .done(done)
    );
endmodule
