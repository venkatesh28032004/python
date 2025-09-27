module railway_crossing(
	input clk, rst_, T1_S1, T1_S3, T2_S1, T2_S3,
	output reg green, red, gate_is_closed, bell
);
	reg [2:0] cst, nst;
	localparam	S_OPEN = 'd0,
				S_CLOSING_1 = 'd1,
				S_CLOSING_2 = 'd2,
				S_OPENING = 'd3,
				S_CLOSED_1 = 'd4,
				S_CLOSED_2 = 'd5;
	reg t_rst_;
	timer U1 (.clk(clk), .rst_(t_rst_), .T(T));

	// sequential logic
	always @ (posedge clk) begin
		if (!rst_) begin
			cst <= S_OPEN;
			t_rst_ <= 1'b1;
		end
		else begin
			cst <= nst;
		end
	end

	// combinational logic
	always @ (cst or T1_S1 or T1_S3 or T2_S1 or T2_S3 or T) begin
		case (cst)
			S_OPEN : begin
				if ((~T1_S1)&(~T2_S1)) begin
					nst = cst;
				end
				else if ((~(T1_S1 & T2_S1))&(T1_S1 | T2_S1)) begin
					nst = S_CLOSING_1;
				end
				else if (T1_S1 & T2_S1) begin
					nst = S_CLOSING_2;
				end
				else begin
					nst = cst;
				end
			end
			S_CLOSING_1 : begin
				if ((~T) & ((~T1_S1)&(~T2_S1))) begin
					nst = cst;
				end
				else if ((~T) & (T1_S1 | T2_S1)) begin
					nst = S_CLOSING_2;
				end
				else if (T) begin
					nst = S_CLOSED_1;
				end
				else begin
					nst = cst;
				end
			end
			S_CLOSING_2 : begin
				if (T) begin
					nst = S_CLOSED_2;
				end
				else if (~T) begin
					nst = cst;
				end
			end
			S_CLOSED_1 : begin
				if (((T1_S3 | T2_S3) & (T1_S1 | T2_S1)) | ((~(T1_S3 | T2_S3)) & (~(T1_S1 | T2_S1)))) begin
					nst = cst;
				end
				else if ((T1_S1 | T2_S1) & (~(T1_S3 + T2_S3))) begin
					nst = S_CLOSED_2;
				end
				else if (((~(T1_S1)) & (~(T2_S1))) & (T1_S3 | T2_S3)) begin
					nst = S_OPENING;
				end
				else begin
					nst = cst;
				end
			end
			S_CLOSED_2 : begin
				if (T1_S3 & T2_S3) begin
					nst = S_OPENING;
				end
				else if ((T1_S3 | T2_S3) & (~(T1_S3 & T2_S3))) begin
					nst = S_CLOSED_1;
				end
				else begin	// write condition if not working
					nst = cst;
				end
			end
			S_OPENING : begin
				if (T) begin
					nst = S_OPEN;
				end
				else if ((~T) & (T1_S1 & T2_S1)) begin
					nst = S_CLOSING_2;
				end
				else if ((~T) & (~(T1_S1 & T2_S1)) & (T1_S1 | T2_S1)) begin
					nst = S_CLOSING_1;
				end
				else begin
					nst = cst;
				end
			end
			default : begin
				nst = cst;
			end
		endcase
	end
	
	// output generation
	always @ (*) begin
	// output green, red, gate_is_closed, bell
		green = (cst==S_CLOSED_1 || cst==S_CLOSED_2);
		red = ~green;
		gate_is_closed = (cst==S_CLOSING_1) || (cst==S_CLOSING_2) || (cst==S_CLOSED_1) || (cst==S_CLOSED_2);
		bell = gate_is_closed;
	end

	always @ (nst) begin
		if (nst==S_CLOSING_1 || nst==S_CLOSING_2 || nst==S_CLOSED_1 || nst==S_CLOSED_2) begin
			t_rst_ <= 1'b0;
		end
		else begin
			t_rst_ <= 1'b1;
		end
	end

endmodule

module timer(
	input clk, rst_,
	output T
);
	reg [3:0] count;

	always @ (posedge clk) begin
		if (!rst_) begin
			count <= 'b0;
		end
		else begin
			count <= count + 1'b1;
		end
	end

	assign T = (count=='b1111);
endmodule

module tb_timer();
	reg clk, rst_;
	wire T;
	railway_crossing rail_UUT ();
	timer TIMER_UUT (.clk(clk), .rst_(rst_), .T(T));

	initial begin
		forever #1 clk = ~clk;
	end

	initial begin
		rst_ = 1'b0;
		#4 rst_ = 1'b1;
		#60 $finish;
	end
endmodule

//module tb();
//	reg clk, rst_, T1_S1, T1_S3, T2_S1, T2_S3;
//	wire green, red, gate_is_closed, bell;
//	
//	railway_crossing UUT (
//		.clk(clk),
//		.rst_(rst_),
//		.T1_S1(T1_S1),
//		.T1_S3(T1_S3),
//		.T2_S1(T2_S1),
//		.T2_S3(T2_S3),
//		.green(green),
//		.red(red),
//		.gate_is_closed(gate_is_closed),
//		.bell(bell)
//	);
//
//	task reset;
//		begin
//			clk = 1'b1;
//			rst_ = 1'b1;
//			T1_S1 = 1'b0;
//			T1_S3 = 1'b0;
//			T2_S1 = 1'b0;
//			T2_S3 = 1'b0;
//			@(posedge clk) rst_ = 1'b0;
//			@(posedge clk) rst_ = 1'b1;
//		end
//	endtask
//
//	task put_T1_S1;
//		begin
//			@(posedge clk) T1_S1 = 1'b1;
//			@(posedge clk) T1_S1 = 1'b0;
//		end
//	endtask
//	
//	task put_T1_S3;
//		begin
//			@(posedge clk) T1_S3 = 1'b1;
//			@(posedge clk) T1_S3 = 1'b0;
//		end
//	endtask
//	
//	task put_T2_S1;
//		begin
//			@(posedge clk) T2_S1 = 1'b1;
//			@(posedge clk) T2_S1 = 1'b0;
//		end
//	endtask
//	
//	task put_T2_S3;
//		begin
//			@(posedge clk) T2_S3 = 1'b1;
//			@(posedge clk) T2_S3 = 1'b0;
//		end
//	endtask
//
//	initial begin
//		reset;
//		put_T1_S1;
//		repeat(20) @(posedge clk);
//		put_T1_S3;
//
//		#20 $finish;
//	end
//
//	initial begin
//		forever #1 clk = ~clk;
//	end
//
//	initial begin
//		$recordfile("database.trn");
//		$recordvars();
//	end
//endmodule
