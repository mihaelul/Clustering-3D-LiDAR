module top_tb;
    reg clk = 0;
    reg rst = 0;

    reg [7:0] x, y, z;
    reg valid, last;

    wire [3:0] label;
    wire out_valid;
    wire done;

    integer f;
    reg file_open;

    // DUT
    top DUT (
        .clk(clk),
        .rst(rst),
        .x(x),
        .y(y),
        .z(z),
        .valid(valid),
        .last(last),
        .label(label),
        .out_valid(out_valid),
        .done(done)
    );

    // ceas
    always #5 clk = ~clk;

    // ==============================
    // TASK PENTRU STREAM DE PUNCTE
    // ==============================
    task send_point(input [7:0] xi, yi, zi, input is_last);
        begin
            @(posedge clk);
            x     <= xi;
            y     <= yi;
            z     <= zi;
            valid <= 1;
            last  <= is_last;

            @(posedge clk);
            valid <= 0;
            last  <= 0;
        end
    endtask

    // ==============================
    // SCRIERE ÎN FIȘIER (SIGURĂ)
    // ==============================
    always @(posedge clk) begin
        if (out_valid && file_open) begin
            $fwrite(f, "%0d %0d %0d %0d\n", x, y, z, label);
        end
    end

    // ==============================
    // TESTBENCH PRINCIPAL
    // ==============================
    initial begin
        // inițializare
        valid = 0;
        last  = 0;
        file_open = 0;

        rst = 1;
        #10 rst = 0;

        // deschidem fișierul
        f = $fopen("clusters_out.txt", "w");
        file_open = 1;

        // ========= STREAM DE PUNCTE AMESTECATE =========
        send_point(10,10,10,0);
        send_point(45,12,10,0);
        send_point(15,45,12,0);
        send_point(60,60,60,0);
        send_point(18,15,9,0);
        send_point(55,48,14,0);
        send_point(8,50,12,0);
        send_point(42,40,10,0);
        send_point(9,50,0,0);
        send_point(5,2,10,0);
        send_point(62,58,65,1); // LAST

        // așteptăm finalizarea
        wait(done);

        // închidem fișierul
        file_open = 0;
        $fclose(f);

        $display("DONE – clusters_out.txt generated");
        #20 $finish;
    end
endmodule
