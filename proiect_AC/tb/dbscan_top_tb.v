module dbscan_top_tb;
    reg clk = 0;
    reg rst = 1;
    reg [7:0] x, y, z;
    reg valid, last;
    wire done;

    integer f;

    dbscan_top DUT (clk, rst, x, y, z, valid, last, done);

    always #5 clk = ~clk;

    task send_point(input [7:0] xi, yi, zi, input is_last);
        begin
            @(posedge clk);
            x <= xi; y <= yi; z <= zi;
            valid <= 1; last <= is_last;
            @(posedge clk);
            valid <= 0; last <= 0;
        end
    endtask

    initial begin
        valid = 0; last = 0;
        #10 rst = 0;

        	send_point(10,10,10,0);
        send_point(13,12,9,0);
        send_point(8,15,11,0);
        send_point(12,11,13,0);
        send_point(9,14,8,0);

        // ===== CLUSTER 2 (50,50,50)
        send_point(50,50,50,0);
        send_point(52,48,53,0);
        send_point(48,55,49,0);
        send_point(51,53,52,0);
        send_point(49,47,48,0);

        // ===== CLUSTER 3 (90,20,70)
        send_point(90,20,70,0);
        send_point(88,23,72,0);
        send_point(93,18,68,0);
        send_point(91,21,74,0);
        send_point(87,19,69,0);

        // ===== CLUSTER 4 (20,80,30)
        send_point(20,80,30,0);
        send_point(22,78,33,0);
        send_point(18,83,28,0);
        send_point(21,81,31,0);
        send_point(19,79,29,0);

        // ===== CLUSTER 5 (70,70,20)
        send_point(70,70,20,0);
        send_point(72,68,25,0);
        send_point(68,75,18,0);
        send_point(71,69,22,0);
        send_point(69,73,21,0);

        // ===== CLUSTER 6 (40,10,90)
        send_point(40,10,90,0);
        send_point(42,12,88,0);
        send_point(38,9,93,0);
        send_point(41,11,91,0);
        send_point(39,8,89,0);

        // ===== CLUSTER 7 (100,100,100)
        send_point(100,100,100,0);
        send_point(102,98,99,0);
        send_point(98,101,103,0);
        send_point(101,99,97,0);
        send_point(99,102,101,0);

        // ===== NOISE (împrăștiat)
        send_point(120,5,90,0);
        send_point(30,80,10,0);
        send_point(5,100,40,0);
        send_point(115,60,20,0);
        send_point(60,5,120,0);
        send_point(80,110,10,0);
        send_point(15,45,100,0);
        send_point(90,90,10,0);
        send_point(10,120,60,0);

        // ===== ULTIMUL PUNCT
        send_point(55,20,115,1);

        wait(done);

        f = $fopen("clusters_out.txt", "w");
        $fwrite(f, "x y z label\n");

        for (integer i = 0; i < DUT.num_points; i = i + 1)
            $fwrite(f, "%0d %0d %0d %0d\n",
                DUT.PM.x_mem[i],
                DUT.PM.y_mem[i],
                DUT.PM.z_mem[i],
                DUT.PM.label_mem[i]);

        $fclose(f);
        $display("DONE – DBSCAN STREAMING");
        #20 $finish;
    end
endmodule
