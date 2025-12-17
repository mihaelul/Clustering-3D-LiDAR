module dbscan_top #(
    parameter N = 16
)(
    input clk,
    input rst,
    output done
);

    wire [3:0] i, j;
    wire [7:0] xi, yi, zi, xj, yj, zj;
    wire [3:0] li;
    wire core_i, core_j;
    wire [17:0] dist2;

    wire we_label, we_core;
    wire [3:0] waddr, wlabel;
    wire wcore;

    dbscan_point_memory #(N) PM (
        clk,
        i, j,
        xi, yi, zi,
        xj, yj, zj,
        li,
        core_i,
        core_j,
        we_label,
        we_core,
        waddr,
        wlabel,
        wcore
    );

    dbscan_distance_unit DU (
        xi, yi, zi,
        xj, yj, zj,
        dist2
    );

    dbscan_fsm #(N) FSM (
        clk, rst,
        dist2,
        li,
        core_i,
        core_j,
        i, j,
        we_label,
        we_core,
        waddr,
        wlabel,
        wcore,
        done
    );
endmodule
