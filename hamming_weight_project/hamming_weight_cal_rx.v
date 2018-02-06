`define START_PACKET 8'b11111111
`define START_RECEIVED 1'b1
`define START_NOTRECEIVED 1'b0
`define TOTAL_STRING_RECEIVED 1'b1
`define TOTAL_STRING_NOTRECEIVED 1'b0

module hamming_weight_cal_rx
			(
				output  reg [10:0] hamming_weight, // 11 bits to output the maximum hamming weight 1024
				input clk,
				input [7:0] bit_string
			);
			
	reg [7:0] clk_count = 8'h00; // internal variable to count the number of clock cycles, initialized to zero
	reg rx_state = `START_NOTRECEIVED; // register to store the rx state
	reg total_string_received = `TOTAL_STRING_NOTRECEIVED ; // register to store if the entire string is received
	wire [3:0] hamming_weight_byte;
	// state machine to look for START_PACKET for every 128 clock cycles
	always@(posedge clk)
	begin
		case(clk_count)
			8'h00: // If clock count is 129 or 0, then we should look for START_packet
				begin
					case(bit_string)
						`START_PACKET:
							begin
								rx_state <= `START_RECEIVED;
								clk_count <= 8'h01;
							end
						default:
							begin
								rx_state <= `START_NOTRECEIVED;
								clk_count <= 8'h00;
							end
					endcase
				end
			8'h81:
				// Case to be executed at the end of each 1024 word
				begin
					rx_state <= `START_NOTRECEIVED; // set the rx_state to be START_NOTRECEIVED
					clk_count <= 8'h00; // reset the clock count
				end
			default: // In all the clk_count cases
				begin
					clk_count <= clk_count+1; // increment the clock count
				end
		endcase
	end
   // instantiate off the hamming weight caluculation module 
   hamming_weight_cal #(.BIT_STRING_LEN(8), .HAMMING_WEIGHT_LEN(4)) 
	hamming_weight_cal_instant(.bit_string(bit_string),.hamming_weight(hamming_weight_byte));

   // Always loop to accumulate the total hamming weight with the hamming weight of each incoming byte
   always@(posedge clk)
   begin
	if(clk_count >= 1)
	begin
		// Accumulate the hamming weight of byte of data in to hamming_weight variable
		hamming_weight <= hamming_weight +{7'b000,hamming_weight_byte};
	end
	
	else
	begin
		// Initialize the value of hamming weight variable
		hamming_weight <= 0; 
	end
   end
 // Logic to generate the positions from the incoming bit streams
genvar i,j;
wire [2:0] bit_position [7:0];
reg [10:0] final_bit_position [7:0];
wire [10:0] bit_position_offset[7:0];
reg  [10:0] bit_position_memory[1023:0];
//reg  [10:0] bit_position_memory_buffer[1023:0];
reg  [1023:0] total_bit_string;
//reg  [1023:0] total_bit_string_of_position_stream;

// store the total_bit_string as per the clk_count
always@(clk_count)
begin
	if(clk_count>1) // if we start receiving the actual bit strem
	begin
		// store off the byte in the specified 8 positions of 1024 byte 
		total_bit_string[8*(clk_count-2)+:8] <= bit_string;
	end
	
	else if (clk_count==0)
	begin
		// fill the total_string with X's
		total_bit_string <= 1024'bX;
	end
end
// generate block to assign the block offsets for each incoming byte
generate 
	for(i=0;i<8;i=i+1)
	begin: bit_position_offset_assign
		assign bit_position_offset[i][10:0] = 8*(clk_count-2);
	end
endgenerate

// generate block to write the combinational logic to encode the incoming byte, bit wise to  find the positions
generate
	for(i=0;i<8;i=i+1)
	begin:encoders
		wire [7:0] decoded_value;
		assign decoded_value = (bit_string & ((8)'(2**i)));
		eight_to_three_encoder encoder_instant(.encoded_value(bit_position[i]), .decoded_value(decoded_value));
	end
endgenerate

always@(clk_count)
begin
	// For every incoming bit, store the true weight in final_bit_position and store off
	// the previous true weights into the bit_position_memory
	if(clk_count > 2)
	begin
		final_bit_position[0][10:0] <= bit_position[0][2:0] + bit_position_offset[0][10:0];
		bit_position_memory[(clk_count-3)*8][10:0] <= final_bit_position[0][10:0]; 
		final_bit_position[1][10:0] <= bit_position[1][2:0] + bit_position_offset[1][10:0];
		bit_position_memory[(clk_count-3)*8+1][10:0] <= final_bit_position[1][10:0]; 
		final_bit_position[2][10:0] <= bit_position[2][2:0] + bit_position_offset[2][10:0];
		bit_position_memory[(clk_count-3)*8+2][10:0] <= final_bit_position[2][10:0]; 
		final_bit_position[3][10:0] <= bit_position[3][2:0] + bit_position_offset[3][10:0];
		bit_position_memory[(clk_count-3)*8+3][10:0] <= final_bit_position[3][10:0]; 
		final_bit_position[4][10:0] <= bit_position[4][2:0] + bit_position_offset[4][10:0];
		bit_position_memory[(clk_count-3)*8+4][10:0] <= final_bit_position[4][10:0]; 
		final_bit_position[5][10:0] <= bit_position[5][2:0] + bit_position_offset[5][10:0];
		bit_position_memory[(clk_count-3)*8+5][10:0] <= final_bit_position[5][10:0]; 
		final_bit_position[6][10:0] <= bit_position[6][2:0] + bit_position_offset[6][10:0];
		bit_position_memory[(clk_count-3)*8+6][10:0] <= final_bit_position[6][10:0]; 
		final_bit_position[7][10:0] <= bit_position[7][2:0] + bit_position_offset[7][10:0];
		bit_position_memory[(clk_count-3)*8+7][10:0] <= final_bit_position[7][10:0]; 
	end
	// For the 1st byte, only final_bit_positions needs to be filled, If the above code is used
	// Garbage will go into the bit_position_memory
	else if(clk_count == 2)
	begin
		final_bit_position[0][10:0] <= bit_position[0][2:0] + bit_position_offset[0][10:0];
		final_bit_position[1][10:0] <= bit_position[1][2:0] + bit_position_offset[1][10:0];
		final_bit_position[2][10:0] <= bit_position[2][2:0] + bit_position_offset[2][10:0];
		final_bit_position[3][10:0] <= bit_position[3][2:0] + bit_position_offset[3][10:0];
		final_bit_position[4][10:0] <= bit_position[4][2:0] + bit_position_offset[4][10:0];
		final_bit_position[5][10:0] <= bit_position[5][2:0] + bit_position_offset[5][10:0];
		final_bit_position[6][10:0] <= bit_position[6][2:0] + bit_position_offset[6][10:0];
		final_bit_position[7][10:0] <= bit_position[7][2:0] + bit_position_offset[7][10:0];
	end
	
	// store off the final byte bit positions in this cycle, because they wont be stored in furthur cycles
	// as they dont get covered by the above conditions
	if(clk_count==129)
	begin
		bit_position_memory[1016][10:0] <= bit_position[0][2:0] + bit_position_offset[0][10:0];
		bit_position_memory[1017][10:0] <= bit_position[1][2:0] + bit_position_offset[1][10:0];
		bit_position_memory[1018][10:0] <= bit_position[2][2:0] + bit_position_offset[2][10:0];
		bit_position_memory[1019][10:0] <= bit_position[3][2:0] + bit_position_offset[3][10:0];
		bit_position_memory[1020][10:0] <= bit_position[4][2:0] + bit_position_offset[4][10:0];
		bit_position_memory[1021][10:0] <= bit_position[5][2:0] + bit_position_offset[5][10:0];
		bit_position_memory[1022][10:0] <= bit_position[6][2:0] + bit_position_offset[6][10:0];
		bit_position_memory[1023][10:0] <= bit_position[7][2:0] + bit_position_offset[7][10:0];
	end

end

// always block to generate total_string_received_signal 
always@(clk_count)
begin
	case(clk_count)
		8'h81: total_string_received <= `TOTAL_STRING_RECEIVED;
		default: total_string_received <= `TOTAL_STRING_NOTRECEIVED;
	endcase
end
endmodule
