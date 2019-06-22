`timescale 1ns/1ps

// Передатчик. Передаёт байт по одному биту. Старт бит - 0, Стоп бит 1. 
module TX_LVDS(
    input clk,

    input wire [23:0] data_in,  //входные данные
    input wire tx_ena,             // готовность входных данных

    output wire tx,                 // выходной порт( выплёвывает по одному биту)

    output wire tx_busy             // Передатчик Занят
);

    reg [4:0] bit_cnt = 4'h0; // Объявляем счётчик
    reg [23:0] sft = 24'h0;    // Обявляем регистр, который будем использовать для сдвига.
    reg tx_out = 1'b1;          // Дополнительный флаг

//Объявляем и кодируем автомат состояний
    parameter st_tx_ena = 1'b0, st_busy = 1'b1;
// Начальное состояние
    reg st = st_tx_ena;

    assign tx_busy = (tx_ena == 1 || st == st_busy) ? 1'b1:1'b0;
    assign tx = tx_out;

    always @(posedge clk)
        begin
            case (st)
                st_busy:
                    if (bit_cnt == 24)   // Если счётчик бит достчитал до 8 то:
                        begin
                            tx_out <= 1;     // вешаем на канале пеередачи единицу( он же является стоп битом)
                            bit_cnt <= 4'h0; // Обнуляем счётчик
                            st <= st_tx_ena;
                        end
                    else  // Иначе
                        begin
                            bit_cnt <= bit_cnt+1'b1; // Нарашиваем счётчик
                            tx_out <= sft[1'b0]; sft <= {1'b0, sft[23:1]}; // Сдвигаем байт данных в сторону младших разрядов на выходной порт
                        end
                st_tx_ena:
                    if (tx_ena)   // Если получили сигнал готовности входных данных то :
                        begin
                            sft <= data_in; // переписываем данный в регистр
                            st <= st_busy;
                            tx_out <= 0;     // Выдаём старт бит = 0
                        end
            endcase
        end
endmodule
