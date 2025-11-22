`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4    //FIFO_DEPTH = 2^ADDR_WIDTH
)(
    input w_clk,
    input r_clk,
    input w_rst_n,
    input r_rst_n,
    input w_en,
    input r_en,
    input [DATA_WIDTH-1:0]data_in,
    output reg [DATA_WIDTH-1:0]data_out,
    output full,
    output empty
    );
    
    //FIFO_MEMORY
    localparam DEPTH = 1 << ADDR_WIDTH; //LEFT SHIFT BY 4 PLACE = 16
    reg [DATA_WIDTH-1:0] RAM [0:DEPTH-1];
    
    //Binary and gray write pointer 
    reg [ADDR_WIDTH:0] w_ptr_bin;
    reg [ADDR_WIDTH:0] w_ptr_gray;
    
    //Binary and gray read pointer
    reg [ADDR_WIDTH:0] r_ptr_bin;
    reg [ADDR_WIDTH:0] r_ptr_gray;
    
    //Synchronizer Registers
    reg [ADDR_WIDTH:0] w_ptr_gray_sync1, w_ptr_gray_sync2;  // into r_clk domain
    reg [ADDR_WIDTH:0] r_ptr_gray_sync1, r_ptr_gray_sync2;  // into w_clk domain
    
    //WRITE POINTER UPDATE AND MEMORY WRITE
    
    always @(posedge w_clk or negedge w_rst_n)begin
        if(!w_rst_n)begin
            w_ptr_bin <= 0;
            w_ptr_gray <= 0;
        end
        else if(w_en && !full) begin
            RAM[w_ptr_bin[ADDR_WIDTH-1:0]] <= data_in;
            w_ptr_bin <= w_ptr_bin + 1;
            w_ptr_gray <= (w_ptr_bin + 1) ^ ((w_ptr_bin + 1) >> 1);  // binary → gray
        end
    end
    
    //READ POINTER UPDATE AND MEMORY READ
    
    always @(posedge r_clk or negedge r_rst_n) begin
            if (!r_rst_n) begin
                r_ptr_bin  <= 0;
                r_ptr_gray <= 0;
                data_out   <= 0;
            end
            else if (r_en && !empty) begin
                data_out   <= RAM[r_ptr_bin[ADDR_WIDTH-1:0]];
                r_ptr_bin  <= r_ptr_bin + 1;
                r_ptr_gray <= (r_ptr_bin + 1) ^ ((r_ptr_bin + 1) >> 1);  // binary → gray
            end
        end
    
    //SYNCHRONIZE WRITE POINTER INTO READ CLOCK DOMAIN
    
    always @(posedge r_clk or negedge r_rst_n) begin
            if (!r_rst_n) begin
                w_ptr_gray_sync1 <= 0;
                w_ptr_gray_sync2 <= 0;
            end
            else begin
                w_ptr_gray_sync1 <= w_ptr_gray;
                w_ptr_gray_sync2 <= w_ptr_gray_sync1;
            end
        end
    
    //SYNCHRONIZE READ POINTER INTO WRITE CLOCK DOMAIN
    
     always @(posedge w_clk or negedge w_rst_n) begin
           if (!w_rst_n) begin
               r_ptr_gray_sync1 <= 0;
               r_ptr_gray_sync2 <= 0;
           end
           else begin
               r_ptr_gray_sync1 <= r_ptr_gray;
               r_ptr_gray_sync2 <= r_ptr_gray_sync1;
           end
       end
    
    //EMPTY AND FULL LOGIC
    
    assign empty = (r_ptr_gray == w_ptr_gray_sync2);
    
   /* wire [ADDR_WIDTH:0] w_ptr_bin_next = w_ptr_bin + 1;
    wire [ADDR_WIDTH:0] w_ptr_gray_next = w_ptr_bin_next ^ (w_ptr_bin_next >> 1);

    assign full = (w_ptr_gray_next ==
                  {~r_ptr_gray_sync2[ADDR_WIDTH:ADDR_WIDTH-1],
                    r_ptr_gray_sync2[ADDR_WIDTH-2:0]});*/

    assign full =
            (w_ptr_gray[ADDR_WIDTH]     != r_ptr_gray_sync2[ADDR_WIDTH])   &&
            (w_ptr_gray[ADDR_WIDTH-1]   != r_ptr_gray_sync2[ADDR_WIDTH-1]) &&
            (w_ptr_gray[ADDR_WIDTH-2:0] == r_ptr_gray_sync2[ADDR_WIDTH-2:0]);

    
endmodule
