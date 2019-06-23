`timescale 1ns/1ps
`include "params.vh"
// Блок контроля. Арбитрирует входные каналы на передачу по принципу поочередной передаче  в случае присутсвия данных, в протвином случае отправка пустого пакета.
module block_control(
    input wire clk,

    input wire next,

    input wire [`BUFF_SIZE-1:0] f1_bf_cnt,
    input wire [`BUFF_SIZE-1:0] f2_bf_cnt,
  
    output wire [1:0] rdy_cnl
);

//Объявляем и кодируем автомат состояний
    parameter st_arb = 1'b0, st_wt = 1'b1;
// Начальное состояние
    reg st = st_arb;

    reg [1:0] arb = 2'b01;
    reg [1:0] rdy_cnl_i = 2'b00;
    wire rdy_fifo_1;
    wire rdy_fifo_2;
    
    assign rdy_cnl = rdy_cnl_i;

// Флаги готовности буферов если в них набралось нужное колличеество байт
    assign rdy_fifo_1 = (f1_bf_cnt >= (`BUFF_SIZE*4-1)) ? 1'b1:1'b0;
    assign rdy_fifo_2 = (f2_bf_cnt >= (`BUFF_SIZE*4-1)) ? 1'b1:1'b0;
  
    always @(posedge clk)
        begin
            case (st)
                st_arb: // Начальное состояние. Выбираем входной канал
                    // Если арбитр выбрал первый канал и на нём есть готовые данные
                    if (arb == 2'b01 && rdy_fifo_1 == 1'b1)
                        begin
                            rdy_cnl_i <= 2'b01; // Передаём код 1
                            st <= st_wt;
                        end
                        //Если арбитр выбрал второй канал и на нём есть готовые данные
                    else if (arb == 2'b10 && rdy_fifo_2 == 1'b1)
                        begin
                            rdy_cnl_i <= 2'b10; // Передаём код 2
                            st <= st_wt;
                        end
                    else
                        begin
                            rdy_cnl_i <= 2'b00; // Передаём код 0
                            st <= st_wt;
                        end

                st_wt: // Состояние ожидания. Ждём прихода флага следующего пакета
                    if (next) begin
                        arb = arb+1'b1; // инвертируем арбитр
                        if (arb == 2'b00) arb = 2'b01;
                        st <= st_arb;
                    end
            endcase
        end

endmodule	
	