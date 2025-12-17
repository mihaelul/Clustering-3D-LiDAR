module clustering_fsm #(
    parameter N = 16
)(
    input clk,
    input rst,
    input is_neighbor,

    input [3:0] li,
    input [3:0] lj,

    output reg [3:0] i,
    output reg [3:0] j,

    output reg we,
    output reg [3:0] waddr,
    output reg [3:0] wlabel,

    output reg done
);

    reg [3:0] current_cluster;
    reg [3:0] li_reg;   // label stabil pentru i

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            i <= 0;
            j <= 1;
            current_cluster <= 0;
            li_reg <= 0;
            we <= 0;
            done <= 0;
        end else begin
            we <= 0;

            // === la începutul fiecărui i, memorăm label-ul ===
            if (j == i + 1)
                li_reg <= li;

            // === dacă i NU are label → cluster nou ===
            if (j == i + 1 && li == 0) begin
                current_cluster <= current_cluster + 1;
                li_reg <= current_cluster + 1;
                we <= 1;
                waddr <= i;
                wlabel <= current_cluster + 1;
            end

            // === propagare către j (folosind li_reg!) ===
            if (is_neighbor && li_reg != 0 && lj == 0) begin
                we <= 1;
                waddr <= j;
                wlabel <= li_reg;
            end

            // === avansare indici ===
            if (j < N-1) begin
                j <= j + 1;
            end else begin
                i <= i + 1;
                j <= i + 2;
            end

            if (i >= N-1)
                done <= 1;
        end
    end
endmodule
