module dbscan_top_tb;
    reg clk = 0;
    reg rst = 1;
    wire done;
    integer f;

    dbscan_top DUT (clk, rst, done);

    always #5 clk = ~clk;

    initial begin
        // === CLUSTER 1 ===
        DUT.PM.x_mem[0]=10; DUT.PM.y_mem[0]=10; DUT.PM.z_mem[0]=10;
        DUT.PM.x_mem[1]=13; DUT.PM.y_mem[1]=12; DUT.PM.z_mem[1]=9;
        DUT.PM.x_mem[2]=8;  DUT.PM.y_mem[2]=15; DUT.PM.z_mem[2]=11;

        // === CLUSTER 2 ===
        DUT.PM.x_mem[3]=50; DUT.PM.y_mem[3]=50; DUT.PM.z_mem[3]=50;
        DUT.PM.x_mem[4]=52; DUT.PM.y_mem[4]=48; DUT.PM.z_mem[4]=53;
        DUT.PM.x_mem[5]=48; DUT.PM.y_mem[5]=55; DUT.PM.z_mem[5]=49;

        // === CLUSTER 3 ===
        DUT.PM.x_mem[6]=90; DUT.PM.y_mem[6]=20; DUT.PM.z_mem[6]=70;
        DUT.PM.x_mem[7]=88; DUT.PM.y_mem[7]=23; DUT.PM.z_mem[7]=72;
        DUT.PM.x_mem[8]=93; DUT.PM.y_mem[8]=18; DUT.PM.z_mem[8]=68;

        #10 rst = 0;
        wait(done);

        // =============================
        // EXPORT ÎN FIȘIER
        // =============================
        f = $fopen("clusters_out.txt", "w");
        $fwrite(f, "x y z label\n");

        for (integer i = 0; i < 9; i = i + 1)
            $fwrite(f, "%0d %0d %0d %0d\n",
                DUT.PM.x_mem[i],
                DUT.PM.y_mem[i],
                DUT.PM.z_mem[i],
                DUT.PM.label_mem[i]);

        $fclose(f);

        $display("DBSCAN done, clusters_out.txt generated");
        #20 $finish;
    end
endmodule
