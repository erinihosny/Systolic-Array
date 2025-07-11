module PE #(
	parameter data_width = 1
) (
	input logic clk,
	input logic reset,
	input logic [data_width-1:0] a,
	input logic [data_width-1:0] b,
	output logic [2*data_width:0] p
);
	
	always_ff @(posedge clk or posedge reset) begin
		if (reset) p <= 0;
        else p <= p + (a * b);
    end
	 
endmodule
