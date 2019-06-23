`timescale 1ns/1ps
`include "params.vh"
// Приёмник для собственной проверки отправленых слов.
module RX_LVDS(
    input clk,
    output wire [`CH_NUM*`BUFF_SIZE-1:0] data_out,
    output wire rx_ena,
    input wire rx);

    reg [4:0] bit_cnt = 4'h0; // Объявляем счётчик
    reg [`CH_NUM*`BUFF_SIZE-1:0] sft = 4'h00;    // Обявляем регистр, который будем использовать для сдвига.
    reg rx_ena_i = 1'b0;
    reg [`CH_NUM*`BUFF_SIZE-1:0] data_out_i = 0;

//Объявляем и кодируем автомат состояний
    parameter st_start = 2'b00, st_rx = 2'b01, st_stop = 2'b10;
// Начальное состояние
    reg [1:0] st = st_start;

    assign data_out = data_out_i;
    assign rx_ena = rx_ena_i;


    always @(posedge clk)
        begin
            case (st)
                // Ловим старт бит = 0
                st_start:
                    begin
                        rx_ena_i <= 0;
                        data_out_i <= 8'h00;
                        if (rx == 0)
                            st <= st_rx;
                    end
                // Принмаем слово 8 бит по одному биту
                st_rx:
                    if (bit_cnt == `CH_NUM*8)   // Если счётчик бит достчитал до 8 то:
                        begin
                            bit_cnt <= 4'h0;
                            st <= st_stop;
                        end
                    else
                        begin
                            sft[`CH_NUM*`BUFF_SIZE-1] <= rx; sft[`CH_NUM*`BUFF_SIZE-2:0] <= sft[`CH_NUM*`BUFF_SIZE-1:1]; // Сдвигаем байт данных в сторону младших разрядов на выходной порт
                            bit_cnt <= bit_cnt+1'b1;
                        end
                //Ловим стоп бит = 1
                st_stop, 2'b11:
                    if (rx == 1)
                        begin
                            st <= st_start;
                            rx_ena_i <= 1;
                            data_out_i <= sft;
                        end
                    else
                        rx_ena_i <= 0;
            endcase
        end
endmodule
