`timescale 1ns/1ps

module fcc_top #(
    parameter W = 16,
    parameter LABEL_W = 16,
    parameter COLS = 30,
    parameter COL_W = 5,
    parameter UF_MAX_LABELS = 4096,
    parameter EPS_H2 = 40'd400,
    parameter EPS_V2 = 40'd400
)(
    input  wire clk,
    input  wire rst,

    input  wire in_valid,
    output wire in_ready,
    input  wire [7:0] in_row,
    input  wire [COL_W-1:0] in_col,
    input  wire signed [W-1:0] in_x,
    input  wire signed [W-1:0] in_y,
    input  wire signed [W-1:0] in_z,
    input  wire in_is_ground,

    output reg  out_valid,
    output reg  [7:0] out_row,
    output reg  [COL_W-1:0] out_col,
    output reg  [LABEL_W-1:0] out_label_root,
    output wire out_ready
);

    // Control FSM
    reg done;
    assign in_ready = !done;
    assign out_ready = 1'b1;

    // -----------------------------
    //      POINT MEMORY
    // -----------------------------
    wire [LABEL_W-1:0] dump_label;
    wire dump_is_ground;

    reg dumping;
    reg [7:0] dump_row;
    reg [COL_W-1:0] dump_col;
    wire [LABEL_W-1:0] dump_root;

    fcc_point_memory #(
        .ROWS(30),
        .COLS(COLS),
        .COL_W(COL_W),
        .LABEL_W(LABEL_W)
    ) mem (
        .clk(clk),
        .we(in_valid && !in_is_ground),
        .wr_row(in_row),
        .wr_col(in_col),
        .wr_label({8'd0, in_row}),  // etichetă provizorie simplă
        .wr_is_ground(in_is_ground),

        .rd_row(dump_row),
        .rd_col(dump_col),
        .rd_label(dump_label),
        .rd_is_ground(dump_is_ground)
    );

    // -----------------------------
    //      UNION FIND (mock)
    // -----------------------------
    // aici poți conecta union_find-ul tău real
    assign dump_root = dump_label; // pentru test, root = label

    // -----------------------------
    //      SIMULARE FSM DUMP
    // -----------------------------
    always @(posedge clk) begin
        if (rst) begin
            done <= 0;
            dumping <= 0;
            dump_row <= 0;
            dump_col <= 0;
        end else begin
            if (in_row == 29 && in_col == 29 && in_valid)
                done <= 1;

            if (done && !dumping) begin
                dumping <= 1;
                dump_row <= 0;
                dump_col <= 0;
            end else if (dumping) begin
                if (dump_col == COLS-1) begin
                    dump_col <= 0;
                    dump_row <= dump_row + 1;
                end else begin
                    dump_col <= dump_col + 1;
                end

                if (dump_row == 29 && dump_col == COLS-1)
                    dumping <= 0;
            end
        end
    end

    // -----------------------------
    //      OUTPUT GENERATOR
    // -----------------------------
    always @(posedge clk) begin
        if (rst) begin
            out_valid <= 0;
            out_row <= 0;
            out_col <= 0;
            out_label_root <= 0;
        end else if (dumping) begin
            if (!dump_is_ground) begin
                out_valid <= 1;
                out_row <= dump_row;
                out_col <= dump_col;
                out_label_root <= dump_root;
            end else begin
                out_valid <= 0;
            end
        end else begin
            out_valid <= 0;
        end
    end

endmodule
