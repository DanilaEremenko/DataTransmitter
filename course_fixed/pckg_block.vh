`timescale 1ns/1ps
`include "params.vh"
`define send_message(fifo,rd_en) 	\
 /* Если передали все size_data байт*/\
if (cnt_size == size_data)	\
	begin					\
		st <= st_S;			\
		cnt_size <= 4'h0;	\
	end						\
else						\
	/* собираем байт из двух полубайт*/\
	begin					\
		sum = sum ^ fifo;	\
		/* Если прочитали из фифо 3 байта слова*/\
		if (cnt_byte == 4)				\
			begin						\
				/* Если приёмник не занят, отдаём ему байт на отправку и наращиваем счётчик размера слов в пакете*/\
				data_out_i[23:16] <= fifo;				\
				rd_en <= 1'b0;						\
				cnt_size <= cnt_size+1'b1;				\
				if (tx_busy == 1'b0)					\
					begin								\
						tx_ena_i <= 1'b1;				\
						cnt_byte <= 3'b000;				\
					end									\
				else									\
					tx_ena_i <= 0;						\
			end											\
			/* Если прочитали из фифо 2 байта слова*/	\
		else if (cnt_byte == 3)							\
			begin										\
				/*rd_en  <= 1;*/						\
				data_out_i[15:8] <= fifo;				\
				rd_en <= 1'b0;						\
				cnt_byte <= cnt_byte+1'b1;				\
			end											\
			/* Если прочитали из фифо 1 байт слова*/	\
		else if (cnt_byte == 2)							\
			begin										\
				rd_en <= 1'b1;						\
				data_out_i[7:0] <= fifo;				\
				cnt_byte <= cnt_byte+1'b1;				\
			end											\
			/* Выставляем флаг чтения из фифо полубайта*/	\
		else if (tx_busy == 0)							\
			begin										\
				rd_en <= 1;							\
				tx_ena_i <= 1'b0;						\
				cnt_byte <= cnt_byte+1'b1;				\
			end else									\
			begin										\
				tx_ena_i <= 0;							\
				rd_en <= 0;							\
			end											\
	end		
	