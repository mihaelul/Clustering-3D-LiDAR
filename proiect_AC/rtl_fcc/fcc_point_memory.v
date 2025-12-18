`timescale 1ns/1ps

module fcc_point_memory #(
    parameter ROWS = 30,
    parameter COLS = 30,
    parameter COL_W = 5,
    parameter LABEL_W = 16
)(
    input  wire                  clk,
    input  wire                  we,
    input  wire [7:0]            wr_row,
    input  wire [COL_W-1:0]      wr_col,
    input  wire [LABEL_W-1:0]    wr_label,
    input  wire                  wr_is_ground,

    // READ pentru FCC pipeline
    input  wire [7:0]            rd_row,
    input  wire [COL_W-1:0]      rd_col,
    output reg  [LABEL_W-1:0]    rd_label,
    output reg                   rd_is_ground
);

    // memorie simplă bidimensională
    reg [LABEL_W-1:0] label_mem [0:ROWS*COLS-1];
    reg is_ground_mem [0:ROWS*COLS-1];

    function integer idx;
        input [7:0] r;
        input [COL_W-1:0] c;
        begin idx = r * COLS + c; end
    endfunction

    always @(posedge clk) begin
        if (we) begin
            label_mem[idx(wr_row, wr_col)]     <= wr_label;
            is_ground_mem[idx(wr_row, wr_col)] <= wr_is_ground;
        end
        rd_label     <= label_mem[idx(rd_row, rd_col)];
        rd_is_ground <= is_ground_mem[idx(rd_row, rd_col)];

endmodule
