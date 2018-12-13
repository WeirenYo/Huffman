module huffman(clk, reset, gray_valid, gray_data , CNT_valid, CNT1, CNT2, CNT3, CNT4, CNT5, CNT6, code_valid, HC1, HC2, HC3, HC4, HC5, HC6 , M1, M2, M3, M4, M5, M6);

input clk;
input reset;
input gray_valid;
input [7:0] gray_data;
output CNT_valid;
output reg [7:0] CNT1, CNT2, CNT3, CNT4, CNT5, CNT6;
output reg code_valid;
output reg [7:0] HC1, HC2, HC3, HC4, HC5, HC6; 	// display A1~A6 huffman code
output reg [7:0] M1, M2, M3, M4, M5, M6; 		// only present how many valid bit for A1~A6

reg gray_valid_1T, gray_valid_2T;
reg [7:0] gray_data_1T;
reg [13:0] CNT1_temp, CNT2_temp, CNT3_temp, CNT4_temp, CNT5_temp, CNT6_temp;
reg [2:0] sort_con;

assign CNT_valid = ~gray_valid_1T & gray_valid_2T;

reg [2:0] comb_con;
reg first_sort;
reg hf_add_0_valid;
reg hf_add_1_valid;
reg [6:1] hf_add_0_data;
reg [6:1] hf_add_1_data;

reg [7:0] M1_sel;
reg [7:0] M2_sel;
reg [7:0] M3_sel;
reg [7:0] M4_sel;
reg [7:0] M5_sel;
reg [7:0] M6_sel;

reg [1:0] huffman_state;

always@(posedge clk, posedge reset)begin
	if(reset)begin
		gray_valid_1T <= 0;
		gray_valid_2T <= 0;
		gray_data_1T  <= 0;
	end else begin
		gray_valid_1T <= gray_valid;
		gray_valid_2T <= gray_valid_1T;
		gray_data_1T  <= gray_data;
	end
end

always@(posedge clk, posedge reset)begin
	if(reset)begin
		CNT1 <= 0;
		CNT2 <= 0;
		CNT3 <= 0;
		CNT4 <= 0;
		CNT5 <= 0;
		CNT6 <= 0;
	end else begin
		if(gray_valid_1T)begin
			case(gray_data_1T[2:0])
				3'd1: CNT1 <= CNT1 + 1;
				3'd2: CNT2 <= CNT2 + 1;
				3'd3: CNT3 <= CNT3 + 1;
				3'd4: CNT4 <= CNT4 + 1;
				3'd5: CNT5 <= CNT5 + 1;
				3'd6: CNT6 <= CNT6 + 1;
			endcase
		end
	end
end


always@(posedge clk, posedge reset)begin
	if(reset)begin
		CNT1_temp <= 0;
		CNT2_temp <= 0;
		CNT3_temp <= 0;
		CNT4_temp <= 0;
		CNT5_temp <= 0;
		CNT6_temp <= 0;
		sort_con  <= 0;
		comb_con  <= 0;
		code_valid <= 0;
		first_sort <= 0;
		huffman_state  <= 0;
		hf_add_0_valid <= 0;
		hf_add_1_valid <= 0;
		hf_add_0_data  <= 0;
		hf_add_1_data  <= 0;
	end else begin
		case(huffman_state)
			2'd0: begin
				if(CNT_valid)begin
					CNT1_temp  <= {6'b000001, CNT1};
					CNT2_temp  <= {6'b000010, CNT2};
					CNT3_temp  <= {6'b000100, CNT3};
					CNT4_temp  <= {6'b001000, CNT4};
					CNT5_temp  <= {6'b010000, CNT5};
					CNT6_temp  <= {6'b100000, CNT6};
					first_sort <= 1;
					huffman_state <= 2'd1;
				end
				code_valid <= 0;
			end
			2'd1: begin
				if(~sort_con[0])begin
					if( (CNT1_temp[7:0]>CNT2_temp[7:0]) | (CNT1_temp[7:0]==CNT2_temp[7:0] && CNT1_temp[13:8]<CNT2_temp[13:8] && first_sort) )begin
						CNT1_temp <= CNT2_temp;
						CNT2_temp <= CNT1_temp;
					end
					if( (CNT3_temp[7:0]>CNT4_temp[7:0]) | (CNT3_temp[7:0]==CNT4_temp[7:0] && CNT3_temp[13:8]<CNT4_temp[13:8] && first_sort) )begin
						CNT3_temp <= CNT4_temp;
						CNT4_temp <= CNT3_temp;
					end
					if( (CNT5_temp[7:0]>CNT6_temp[7:0]) | (CNT5_temp[7:0]==CNT6_temp[7:0] && CNT5_temp[13:8]<CNT6_temp[13:8] && first_sort) )begin
						CNT5_temp <= CNT6_temp;
						CNT6_temp <= CNT5_temp;
					end	
				end else begin
					if( (CNT2_temp[7:0]>CNT3_temp[7:0]) | (CNT2_temp[7:0]==CNT3_temp[7:0] && CNT2_temp[13:8]<CNT3_temp[13:8] && first_sort) )begin
						CNT2_temp <= CNT3_temp;
						CNT3_temp <= CNT2_temp;
					end
					if( (CNT4_temp[7:0]>CNT5_temp[7:0]) | (CNT4_temp[7:0]==CNT5_temp[7:0] && CNT4_temp[13:8]<CNT5_temp[13:8] && first_sort) )begin
						CNT4_temp <= CNT5_temp;
						CNT5_temp <= CNT4_temp;
					end
				end
				
				if(sort_con==5)begin
					sort_con <= 0;
					huffman_state <= 2'd2;
				end else begin
					sort_con <= sort_con + 1;
					huffman_state <= 2'd1;
				end
				
				hf_add_0_valid <= 0;
				hf_add_1_valid <= 0;
			end
			2'd2: begin
				first_sort <= 0;

				hf_add_0_valid <= 1;
				hf_add_1_valid <= 1;
				hf_add_0_data <= CNT2_temp[13:8];
				hf_add_1_data <= CNT1_temp[13:8];
				
				// update content
				CNT1_temp <= CNT2_temp + CNT1_temp;
				CNT2_temp <= CNT3_temp;
				CNT3_temp <= CNT4_temp;
				CNT4_temp <= CNT5_temp;
				CNT5_temp <= CNT6_temp;
				CNT6_temp <= 14'h3fff;
				
				if(comb_con == 4)begin
					comb_con <= 0;
					huffman_state <= 2'd3;
				end else begin
					comb_con <= comb_con + 1;
					huffman_state <= 2'd1;
				end
			end
			2'd3: begin
				code_valid     <= 1;
				hf_add_0_valid <= 0;
				hf_add_1_valid <= 0;
				huffman_state  <= 2'd0;
			end
		endcase
	end
end

// 
always@(posedge clk, posedge reset)begin
	if(reset)begin
		M1 <= 0; M2 <= 0; M3 <= 0; M4 <= 0; M5 <= 0; M6 <= 0;
		M1_sel <= 0; M2_sel <= 0; M3_sel <= 0; M4_sel<= 0; M5_sel <= 0; M6_sel <= 0;	
	end else begin
		if( (hf_add_0_valid & hf_add_0_data[1]) | (hf_add_1_valid & hf_add_1_data[1]) ) begin M1 <= (M1<<1) + 1; M1_sel <= M1_sel + 1; end
		if( (hf_add_0_valid & hf_add_0_data[2]) | (hf_add_1_valid & hf_add_1_data[2]) ) begin M2 <= (M2<<1) + 1; M2_sel <= M2_sel + 1; end
		if( (hf_add_0_valid & hf_add_0_data[3]) | (hf_add_1_valid & hf_add_1_data[3]) ) begin M3 <= (M3<<1) + 1; M3_sel <= M3_sel + 1; end
		if( (hf_add_0_valid & hf_add_0_data[4]) | (hf_add_1_valid & hf_add_1_data[4]) ) begin M4 <= (M4<<1) + 1; M4_sel <= M4_sel + 1; end
		if( (hf_add_0_valid & hf_add_0_data[5]) | (hf_add_1_valid & hf_add_1_data[5]) ) begin M5 <= (M5<<1) + 1; M5_sel <= M5_sel + 1; end
		if( (hf_add_0_valid & hf_add_0_data[6]) | (hf_add_1_valid & hf_add_1_data[6]) ) begin M6 <= (M6<<1) + 1; M6_sel <= M6_sel + 1; end
	end
end

//
always@(posedge clk, posedge reset)begin
	if(reset)begin
		HC1 <= 0; HC2 <= 0; HC3 <= 0; HC4 <= 0; HC5 <= 0; HC6 <= 0;
	end else begin
		if(hf_add_1_valid & hf_add_1_data[1]) HC1[M1_sel] <= 1;
		if(hf_add_1_valid & hf_add_1_data[2]) HC2[M2_sel] <= 1;
		if(hf_add_1_valid & hf_add_1_data[3]) HC3[M3_sel] <= 1;
		if(hf_add_1_valid & hf_add_1_data[4]) HC4[M4_sel] <= 1;
		if(hf_add_1_valid & hf_add_1_data[5]) HC5[M5_sel] <= 1;
		if(hf_add_1_valid & hf_add_1_data[6]) HC6[M6_sel] <= 1;
	end
end

endmodule

