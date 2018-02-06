module eight_to_three_encoder (	output [2:0] encoded_value,
			input [7:0] decoded_value);
always@(decoded_value)
begin
	case(decoded_value)
		8'h01:  encoded_value = 3'b000;
		8'h02:  encoded_value = 3'b001;
		8'h04:  encoded_value = 3'b010;
		8'h08:  encoded_value = 3'b011;
		8'h10:  encoded_value = 3'b100;
		8'h20:  encoded_value = 3'b101;
		8'h40:  encoded_value = 3'b110;
		8'h80:  encoded_value = 3'b111;
	endcase
end

endmodule
