`timescale 100ns/1ns
`include "params.vh"
module test();

    reg clk;
    reg start;
    reg wr_en_fifo_1;
    reg [`BUFF_SIZE-1:0] data_in_fifo_1;
    reg wr_en_fifo_2;
    reg [`BUFF_SIZE-1:0] data_in_fifo_2;
    wire tx;
    integer i;


    Top uut(
        .clk(clk),
        .start(start),
        .wr_en_fifo_1(wr_en_fifo_1),
        .data_in_fifo_1(data_in_fifo_1),
        .wr_en_fifo_2(wr_en_fifo_2),
        .data_in_fifo_2(data_in_fifo_2),
        .tx(tx)
    );
    // Формируем тактовый сигнал
    always
        begin
            clk = 0;
            #1;
            clk = 1;
            #1;
        end

    initial begin
        clk = 0;
        wr_en_fifo_1 <= 0;
        data_in_fifo_1 <= 0;
        wr_en_fifo_2 <= 0;
        data_in_fifo_2 <= 0;
        
        // Запускаем устройство
        #10;
        @(posedge clk);
        start <= 1;

        #10;
        @(posedge clk);

        // Начинаем подавать входные данные на оба канала
        for (i = 0; i < `BUFF_SIZE*4-1;i = i+1)
            begin
                data_in_fifo_1 <= data_in_fifo_1+1;
                data_in_fifo_2 <= data_in_fifo_2+2;
                wr_en_fifo_1 <= 1;
                wr_en_fifo_2 <= 1;
                 @(posedge clk);
            end

        wr_en_fifo_1 <= 0;
        wr_en_fifo_2 <= 0;
    end
endmodule

