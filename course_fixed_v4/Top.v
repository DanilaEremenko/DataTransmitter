`timescale 1ns/1ps
`include "params.vh"
// Модуль верхнего уровня в состав которого входят все блоки проекта
module Top(
    // 40 Мгц. Период 25ns
    input wire clk,
    // Запуск устройства
    input wire start,
    // Порты записи в FIFO 1
    input wire wr_en_fifo_1,
    input wire [`BUFF_SIZE-1:0] data_in_fifo_1, // входные данные
    // Порты записи в FIFO 2
    input wire wr_en_fifo_2,
    input wire [`BUFF_SIZE-1:0] data_in_fifo_2, // входные данные

    output wire tx                       // выходной порт LVDS( выплёвывает по одному биту)
);
/////////////////////////////////////////////////////////////////
// Сигналы для коммутации
/////////////////////////////////////////////////////////////////
    wire next_i;
    wire tx_ena_i;
    wire tx_busy_i;
    wire rd_en_fifo_1;
    wire rd_en_fifo_2;
    wire [`BUFF_SIZE-1:0] rd_dat_fifo_1;
    wire [`BUFF_SIZE-1:0] rd_dat_fifo_2;
    wire [`BUFF_SIZE-1:0] buf_cnt_fifo_1;
    wire [`BUFF_SIZE-1:0] buf_cnt_fifo_2;
    wire [1:0] rdy_cnl_i;
    wire [`CH_NUM*`BUFF_SIZE-1:0] tx_dat_i;
    wire chk_data_en;
    wire [`CH_NUM*`BUFF_SIZE-1:0] chk_data;
    wire tx_rx;
	
	wire main_clk;
	wire sync_clk;


//////////////////////////////////////////////////////////////////
// Коммутация блоков между собой
//////////////////////////////////////////////////////////////////

    assign tx = tx_rx;



//------------------- GENERATOR -------------------------
pll_800 generator(
				.inclk0 			( clk			),
				.c0				( main_clk	),
				.c1				( sync_clk	)
				);
				
//------------------- SYNC -------------------------				
/*syn_block sync_block_1(
				.clk 				( main_clk					),
				.syn_clk			( sync_clk					),
				.data_in			( data_in_fifo_1			),
				.wrreq			( wr_en_fifo_1				),	
				.data_out		( rd_dat_fifo_1	)
				);
				
syn_block sync_block_2(
				.clk 				( main_clk					),
				.syn_clk			( sync_clk					),
				.data_in			( data_in_fifo_2			),
				.wrreq			( wr_en_fifo_2				),	
				.data_out		( rd_dat_fifo_2	)
				);

syn_block sync_block_3(
				.clk 				( main_clk					),
				.syn_clk			( sync_clk					),
				.data_in			( data_in_fifo_3			),
				.wrreq			( wr_en_fifo_3				),	
				.data_out		( rd_dat_fifo_3	)
				);
*/
	
//------------------- FIFO -------------------------				
// Первый буфер входного потока
    FIFO FIFO_1_inst(
        .clk(clk),
        .wr_en(wr_en_fifo_1),
        .data_in(data_in_fifo_1),
        .rd_en(rd_en_fifo_1),
        .data_out(rd_dat_fifo_1),
        .buf_cnt(buf_cnt_fifo_1)
    );
// Второй буфер входного потока
    FIFO FIFO_2_inst(
        .clk(clk),
        .wr_en(wr_en_fifo_2),
        .data_in(data_in_fifo_2),
        .rd_en(rd_en_fifo_2),
        .data_out(rd_dat_fifo_2),
        .buf_cnt(buf_cnt_fifo_2)
    );



// Блок контроля и арбитрирования
    block_control block_control_inst(
        .clk(clk),
        .next(next_i),
        .f1_bf_cnt(buf_cnt_fifo_1),
        .f2_bf_cnt(buf_cnt_fifo_2),
        .rdy_cnl(rdy_cnl_i)
    );

// Блок формирования пакета и коммутации входных потоков
    pckg_block pckg_block_inst(
        .clk(clk),
        .start(start),
        .rd_en_fifo_1(rd_en_fifo_1),
        .dat_from_fifo_1(rd_dat_fifo_1),
        .rd_en_fifo_2(rd_en_fifo_2),
        .dat_from_fifo_2(rd_dat_fifo_2),
        .next(next_i),
        .rdy_cnl(rdy_cnl_i),
        .tx_busy(tx_busy_i),
        .data_out(tx_dat_i),
        .tx_ena(tx_ena_i)
    );

// Блок передатчик
    TX_LVDS TX_LVDS_inst(
        .clk(clk),
        .data_in(tx_dat_i),
        .tx_ena(tx_ena_i),
        .tx(tx_rx),
        .tx_busy(tx_busy_i)
    );

// Блок приёма для проверки отправляемых данных		
    RX_LVDS RX_LVDS_inst(
        .clk(clk),
        .data_out(chk_data),
        .rx_ena(chk_data_en),
        .rx(tx_rx)
    );

endmodule		