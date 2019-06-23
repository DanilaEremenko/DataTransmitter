module syn_block(
	input wire clk, syn_clk,
	input wire [3:0] data_in,
	output reg wrreq,
	output reg [3:0] data_out
	);
	
reg lock=1'b0;
 
always @(posedge syn_clk) 
begin 
	if (clk==1'b1&&lock==1'b0) begin
		wrreq<=1'b1;
		data_out<=data_in;
		lock<=1'b1;
	end
	else wrreq<=1'b0;
	
	if (clk == 1'b0)
			lock<=1'b0;
end 
endmodule
