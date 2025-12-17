module dbscan_fsm #(
    parameter N = 16,
    parameter EPS2 = 300,
    parameter MINPTS = 2,
    parameter ITER = 6
)(
    input clk,
    input rst,

    input [17:0] dist2,
    input [3:0] li,
    input core_i,
    input core_j,

    output reg [3:0] i,
    output reg [3:0] j,

    output reg we_label,
    output reg we_core,
    output reg [3:0] waddr,
    output reg [3:0] wlabel,
    output reg       wcore,

    output reg done
);

    reg [7:0] iter;
    reg [3:0] current_label;
    reg [3:0] neighbor_count;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            i <= 0; j <= 0;
            iter <= 0;
            current_label <= 1;
            neighbor_count <= 0;
            done <= 0;
            we_label <= 0;
            we_core <= 0;
        end else if (!done) begin
            we_label <= 0;
            we_core  <= 0;

            // număr vecini
            if (dist2 < EPS2 && i != j)
                neighbor_count <= neighbor_count + 1;

            // final scanare vecini
            if (j == N-1) begin
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
                neighbor_count <= 0;
                j <= 0;
                i <= i + 1;
            end else begin
                j <= j + 1;
            end

            // expansiune cluster
            if (core_i && dist2 < EPS2 && li != 0) begin
                we_label <= 1;
                waddr <= j;
                wlabel <= li;
            end

            if (i == N-1) begin
                i <= 0;
                iter <= iter + 1;
            end

            if (iter >= ITER)
                done <= 1;
        end
    end
endmodule
