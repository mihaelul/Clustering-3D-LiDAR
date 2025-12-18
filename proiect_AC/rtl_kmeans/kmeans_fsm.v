module kmeans_fsm #(
    parameter N = 20,
    parameter ITER = 10
)(
    input clk,
    input rst,

    input [17:0] d0, d1, d2,
    input [7:0]  x, y, z,
    input [1:0]  mem_label,

    output reg [4:0] idx,

    // write label
    output reg        we,
    output reg [4:0]  waddr,
    output reg [1:0]  wlabel,

    // accumulation
    output reg [15:0] sumx0, sumx1, sumx2,
    output reg [15:0] sumy0, sumy1, sumy2,
    output reg [15:0] sumz0, sumz1, sumz2,
    output reg [4:0]  cnt0,  cnt1,  cnt2,

    output reg update_centroids,
    output reg done
);

    localparam ASSIGN = 2'd0,
               ACCUM  = 2'd1,
               UPDATE = 2'd2;

    reg [1:0] phase;
    reg [4:0] i;
    reg [3:0] iter;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            phase <= ASSIGN;
            i <= 0;
            iter <= 0;
            done <= 0;
            we <= 0;
            update_centroids <= 0;

            sumx0 <= 0; sumx1 <= 0; sumx2 <= 0;
            sumy0 <= 0; sumy1 <= 0; sumy2 <= 0;
            sumz0 <= 0; sumz1 <= 0; sumz2 <= 0;
            cnt0  <= 0; cnt1  <= 0; cnt2  <= 0;
        end else if (!done) begin
            we <= 0;
            update_centroids <= 0;

            case (phase)

            // ================= ASSIGN =================
            ASSIGN: begin
                idx   <= i;
                we    <= 1;
                waddr <= i;

                if (d0 <= d1 && d0 <= d2) wlabel <= 2'd0;
                else if (d1 <= d2)        wlabel <= 2'd1;
                else                      wlabel <= 2'd2;

                if (i == N-1) begin
                    i <= 0;
                    phase <= ACCUM;
                end else
                    i <= i + 1;
            end

            // ================= ACCUM =================
            ACCUM: begin
                idx <= i;

                case (mem_label)
                    2'd0: begin
                        sumx0 <= sumx0 + x;
                        sumy0 <= sumy0 + y;
                        sumz0 <= sumz0 + z;
                        cnt0  <= cnt0 + 1;
                    end
                    2'd1: begin
                        sumx1 <= sumx1 + x;
                        sumy1 <= sumy1 + y;
                        sumz1 <= sumz1 + z;
                        cnt1  <= cnt1 + 1;
                    end
                    2'd2: begin
                        sumx2 <= sumx2 + x;
                        sumy2 <= sumy2 + y;
                        sumz2 <= sumz2 + z;
                        cnt2  <= cnt2 + 1;
                    end
                endcase

                if (i == N-1) begin
                    i <= 0;
                    phase <= UPDATE;
                end else
                    i <= i + 1;
            end

            // ================= UPDATE =================
            UPDATE: begin
                update_centroids <= 1;

                sumx0 <= 0; sumx1 <= 0; sumx2 <= 0;
                sumy0 <= 0; sumy1 <= 0; sumy2 <= 0;
                sumz0 <= 0; sumz1 <= 0; sumz2 <= 0;
                cnt0  <= 0; cnt1  <= 0; cnt2  <= 0;

                if (iter == ITER-1) begin
                    done <= 1;
                end else begin
                    iter <= iter + 1;
                    phase <= ASSIGN;
                end
            end

            endcase
        end
    end
endmodule