module distance_unit (
    input  [7:0] x1, y1, z1,
    input  [7:0] x2, y2, z2,
    input  [15:0] r2,
    output reg is_neighbor
);

    reg [8:0] dx, dy, dz;
    reg [17:0] dist2;

    always @(*) begin
        dx = (x1 > x2) ? (x1 - x2) : (x2 - x1);
        dy = (y1 > y2) ? (y1 - y2) : (y2 - y1);
        dz = (z1 > z2) ? (z1 - z2) : (z2 - z1);

        dist2 = dx*dx + dy*dy + dz*dz;
        is_neighbor = (dist2 < r2);
    end
endmodule
