module kmeans_top_tb;

    reg clk = 0;
    reg rst = 1;
    wire done;
    integer f;
    integer i;

    kmeans_top DUT (
        .clk(clk),
        .rst(rst),
        .done(done)
    );

    always #5 clk = ~clk;

    initial begin
        // puncte test (11)
        DUT.PM.x_mem[0]  = 10; DUT.PM.y_mem[0]  = 10; DUT.PM.z_mem[0]  = 10;
        DUT.PM.x_mem[1]  = 12; DUT.PM.y_mem[1]  = 9;  DUT.PM.z_mem[1]  = 11;
        DUT.PM.x_mem[2]  = 9;  DUT.PM.y_mem[2]  = 12; DUT.PM.z_mem[2]  = 10;
        DUT.PM.x_mem[3]  = 11; DUT.PM.y_mem[3]  = 8;  DUT.PM.z_mem[3]  = 9;

        DUT.PM.x_mem[4]  = 50; DUT.PM.y_mem[4]  = 50; DUT.PM.z_mem[4]  = 50;
        DUT.PM.x_mem[5]  = 52; DUT.PM.y_mem[5]  = 48; DUT.PM.z_mem[5]  = 51;
        DUT.PM.x_mem[6]  = 49; DUT.PM.y_mem[6]  = 53; DUT.PM.z_mem[6]  = 50;
        DUT.PM.x_mem[7]  = 51; DUT.PM.y_mem[7]  = 49; DUT.PM.z_mem[7]  = 52;

        DUT.PM.x_mem[8]  = 90; DUT.PM.y_mem[8]  = 20; DUT.PM.z_mem[8]  = 70;
        DUT.PM.x_mem[9]  = 92; DUT.PM.y_mem[9]  = 22; DUT.PM.z_mem[9]  = 71;
        DUT.PM.x_mem[10] = 88; DUT.PM.y_mem[10] = 18; DUT.PM.z_mem[10] = 69;
        DUT.PM.x_mem[11] = 91; DUT.PM.y_mem[11] = 21; DUT.PM.z_mem[11] = 72;



        #20 rst = 0;
        wait(done);

        f = $fopen("clusters_out.txt", "w");
        $fwrite(f, "x y z label\n");
        for (i = 0; i < 12; i = i + 1) begin
            $fwrite(f, "%0d %0d %0d %0d\n",
                DUT.PM.x_mem[i],
                DUT.PM.y_mem[i],
                DUT.PM.z_mem[i],
                DUT.PM.label_mem[i]);
        end
        $fclose(f);

        $display("K-means done – clusters_out.txt generated");
        #20 $finish;
    end
endmodule
