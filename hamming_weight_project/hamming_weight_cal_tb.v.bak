module hamming_weight_cal_tb();
reg [7:0] bit_string; // declare reg for module inputs
wire [3:0] hamming_weight; // declare wire for module outputs
 hamming_weight_cal dut(.bit_string(bit_string), .hamming_weight(hamming_weight));

// supply values to the bit_string with delays in between
initial 
begin 
	bit_string = 8'h00;  #5;
 	bit_string = 8'hF1;  #5;
	bit_string = 8'hC2;  #5;
	bit_string = 8'hE3;  #5;
	bit_string = 8'hA4;  #5;
	bit_string = 8'h15;  #5;
	bit_string = 8'h76;  #5;
	bit_string = 8'hB7;  #5;
	bit_string = 8'h35;  #5;
	bit_string = 8'h19;  #5;
	bit_string = 8'h68;  #5;
	bit_string = 8'h28;  #5;
	bit_string = 8'h52;  #5;
	bit_string = 8'hff;  #5;
	bit_string = 8'hdf;  #5;
	bit_string = 8'h7f;  #5;
end

initial
begin
	$monitor("The Hamming Weight of %b is %h \n",bit_string, hamming_weight);
end

initial
begin
#200
$finish();
end
endmodule
