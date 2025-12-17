module dbscan_fsm #(
    parameter MAX_N = 64,
    parameter EPS2 = 300,
    parameter MINPTS = 2,
    parameter ITER = 6
)(
    input clk,
    input rst,
    input start,
    input [7:0] num_points,

    input [17:0] dist2,
    input [3:0]  li,
    input        core_i,

    output reg [$clog2(MAX_N)-1:0] i,
    output reg [$clog2(MAX_N)-1:0] j,

    output reg we_label,
    output reg we_core,
    output reg [$clog2(MAX_N)-1:0] waddr,
    output reg [3:0] wlabel,
    output reg       wcore,

    output reg done
);

    reg [7:0] iter;
    reg [3:0] neighbor_count;
    reg [3:0] current_label;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            i <= 0; j <= 0;
            iter <= 0;
            neighbor_count <= 0;
            current_label <= 1;
            done <= 0;
            we_label <= 0;
            we_core <= 0;
        end
        else if (start && !done) begin
            we_label <= 0;
            we_core  <= 0;

            // reset neighbor count at new i
            if (j == 0)
                neighbor_count <= 0;

            if (dist2 < EPS2 && i != j)
                neighbor_count <= neighbor_count + 1;

            // end j sweep
            if (j == num_points-1) begin
                if (neighbor_count >= MINPTS) begin
                    we_core <= 1;
                    waddr <= i;
                    wcore <= 1;

                    if (li == 0) begin
                        we_label <= 1;
                        wlabel <= current_label;
                        current_label <= current_label + 1;
                    end
                end
                j <= 0;
                i <= i + 1;
            end else begin
                j <= j + 1;
            end

            // expand cluster
            if (core_i && dist2 < EPS2 && li != 0) begin
                we_label <= 1;
                waddr <= j;
                wlabel <= li;
            end

            // end full sweep
            if (i == num_points-1 && j == num_points-1)
                iter <= iter + 1;

            if (iter >= ITER)
                done <= 1;
        end
    end
endmodule
