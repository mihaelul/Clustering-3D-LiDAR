module kmeans_distance_unit (
    input  [7:0] x1, y1, z1,
    input  [7:0] x2, y2, z2,
    output [17:0] dist2
);
    wire [8:0] dx = (x1 > x2) ? (x1 - x2) : (x2 - x1);
    wire [8:0] dy = (y1 > y2) ? (y1 - y2) : (y2 - y1);
    wire [8:0] dz = (z1 > z2) ? (z1 - z2) : (z2 - z1);

    assign dist2 = dx*dx + dy*dy + dz*dz;
endmodule
