`timescale 1ns/1ps

module async_fifo_tb();

    reg         w_clk, r_clk;
    reg         w_rst_n, r_rst_n;
    reg         w_en, r_en;
    reg  [7:0]  data_in;
    wire [7:0]  data_out;
    wire        full, empty;

    // Instantiate FIFO
    async_fifo DUT (
        .w_clk(w_clk),
        .r_clk(r_clk),
        .w_rst_n(w_rst_n),
        .r_rst_n(r_rst_n),
        .w_en(w_en),
        .r_en(r_en),
        .data_in(data_in),
        .data_out(data_out),
        .full(full),
        .empty(empty)
    );

    // -------------------------
    // Clock generation
    // -------------------------
    initial w_clk = 0;
    always #5 w_clk = ~w_clk;   // 100MHz write clock

    initial r_clk = 0;
    always #7 r_clk = ~r_clk;   // ~71MHz read clock

    // -------------------------
    // Task: Write values
    // -------------------------
    task write_block;
        integer i;
        begin
            w_en = 1;
            for(i = 0; i < 6; i = i + 1) begin
                @(posedge w_clk);
                if(!full)
                    data_in = i[7:0];
                else
                    $display("FIFO FULL, cannot write %0d at time %0t", i, $time);
                    
            end
           @(posedge w_clk); 
           w_en = 0;
        end
    endtask


    // -------------------------
    // Task: Read values
    // -------------------------
    task read_block;
        integer i;
        begin
            r_en = 1;
            for(i = 0; i < 6; i = i + 1) begin
                @(posedge r_clk);
                $display("Read data_out = %0d at time %0t", data_out, $time);
            end
           @(posedge r_clk);
            r_en = 0;  // stop reading
        end
    endtask

    // -------------------------
    // Main process
    // -------------------------
    initial begin
        $dumpfile("fifo.vcd");
        $dumpvars(0, async_fifo_tb);

        // Reset
        w_rst_n = 0; 
        r_rst_n = 0;
        w_en = 0;
        r_en = 0;
        data_in = 0;

        #30;
        w_rst_n = 1;
        r_rst_n = 1;

        // --- WRITE BLOCK ---
        write_block;
        $display("After writing, FIFO FULL = %b at time %0t", full, $time);

        #20; // small wait

        // --- READ BLOCK ---
        read_block;
        $display("After reading, FIFO EMPTY = %b at time %0t", empty, $time);

        #50;
        $finish;
    end

endmodule
