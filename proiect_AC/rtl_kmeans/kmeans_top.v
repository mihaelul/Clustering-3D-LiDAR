module kmeans_top #(
    parameter N    = 11,
    parameter ITER = 10
)(
    input clk,
    input rst,
    output done
);

    wire [4:0] idx;
    wire [7:0] x, y, z;
    wire [1:0] mem_label;

    wire        we;
    wire [4:0]  waddr;
    wire [1:0]  wlabel;

    reg [7:0] cx0, cy0, cz0;
    reg [7:0] cx1, cy1, cz1;
    reg [7:0] cx2, cy2, cz2;

    wire [17:0] d0, d1, d2;

    wire [15:0] sumx0, sumx1, sumx2;
    wire [15:0] sumy0, sumy1, sumy2;
    wire [15:0] sumz0, sumz1, sumz2;
    wire [4:0]  cnt0,  cnt1,  cnt2;

    wire update_centroids;

    // centroizi inițiali
    initial begin
        cx0 = 12; cy0 = 50; cz0 = 10;
        cx1 = 50; cy1 = 50; cz1 = 51;
        cx2 = 90; cy2 = 21; cz2 = 71;
    end

    // memorie puncte
    kmeans_point_memory #(N) PM (
        .clk(clk),
        .raddr(idx),
        .x(x), .y(y), .z(z),
        .label(mem_label),
        .we(we),
        .waddr(waddr),
        .wlabel(wlabel)
    );

    // distanțe
    kmeans_distance_unit DU0(x,y,z, cx0,cy0,cz0, d0);
    kmeans_distance_unit DU1(x,y,z, cx1,cy1,cz1, d1);
    kmeans_distance_unit DU2(x,y,z, cx2,cy2,cz2, d2);

    // FSM
    kmeans_fsm #(N,ITER) FSM (
        clk, rst,
        d0,d1,d2,
        x,y,z,
        mem_label,
        idx,
        we, waddr, wlabel,
        sumx0,sumx1,sumx2,
        sumy0,sumy1,sumy2,
        sumz0,sumz1,sumz2,
        cnt0,cnt1,cnt2,
        update_centroids,
        done
    );

    // update centroizi (o singură dată / iterație)
    always @(posedge clk) begin
        if (update_centroids) begin
            if (cnt0 != 0) begin
                cx0 <= sumx0 / cnt0;
                cy0 <= sumy0 / cnt0;
                cz0 <= sumz0 / cnt0;
            end
            if (cnt1 != 0) begin
                cx1 <= sumx1 / cnt1;
                cy1 <= sumy1 / cnt1;
                cz1 <= sumz1 / cnt1;
            end
            if (cnt2 != 0) begin
                cx2 <= sumx2 / cnt2;
                cy2 <= sumy2 / cnt2;
                cz2 <= sumz2 / cnt2;
            end
        end
    end

endmodule
