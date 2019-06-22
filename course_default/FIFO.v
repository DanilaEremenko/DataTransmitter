`timescale 1ns/1ps

// Модуль буфферизации входных данных
module FIFO(
    input wire clk,
    // Порты записи в FIFO
    input wire wr_en,
    input wire [7:0] data_in, // входные данные
    // Порты чтения из FIFO
    input wire rd_en,
    output wire [7:0] data_out, // выходные данные
    // счётчик слов в фифо
    output wire [7:0] buf_cnt
);

// Объявляем память с шириной слова 8 бита и глубиной 256
    reg [7:0] mem [0:255];

    reg [7:0] wr_addr = 8'h0;
    reg [7:0] rd_addr = 8'h0;
    reg [7:0] bf_cnt = 8'h0;
    reg [7:0] data_out_i = 8'h0;

// Внутренние сигналы пустоты и заполения буфера
    wire full;
    wire empty;


    assign full = (bf_cnt == 255) ? 1'b1:1'b0;
    assign empty = (bf_cnt == 0) ? 1'b1:1'b0;

// Выводим сигналы на выходные порты
    assign data_out = data_out_i;
    assign buf_cnt = bf_cnt;

    // Процесс записи в FIFO
    always @(posedge clk)
        begin
            case (1'b1)
                (full == 1'b0 && wr_en && empty == 1'b0 && rd_en && rd_addr != wr_addr): begin
                    mem[wr_addr] <= data_in;
                    data_out_i <= mem[rd_addr];
                    wr_addr <= wr_addr+1'b1;
                    rd_addr <= rd_addr+1'b1;
                end
                (full == 1'b0 && wr_en && empty == 1'b0 && rd_en && rd_addr == wr_addr): begin
                    mem[wr_addr] <= data_in;
                    data_out_i <= data_in;
                    wr_addr <= wr_addr+1'b1;
                    rd_addr <= rd_addr+1'b1;
                end
                (full == 1'b0 && wr_en): begin
                    mem[wr_addr] <= data_in;
                    wr_addr <= wr_addr+1'b1;
                end
                (empty == 1'b0 && rd_en): begin
                    data_out_i <= mem[rd_addr];
                    rd_addr <= rd_addr+1'b1;
                end
            endcase

        end

    // Счётчик слов в фифо
    always @(posedge clk)
        begin
            if (wr_en) begin
                bf_cnt <= bf_cnt+1'b1;
            end
            else if (rd_en) begin
                bf_cnt <= bf_cnt-1'b1;
            end
        end

endmodule