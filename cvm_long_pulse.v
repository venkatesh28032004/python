`define TB
module cvm_long_pulse(
	input clk, rst_, n_raw, d_raw, q_raw,
	output reg del, rn, rd
);

	nickle_coin U1 (.clk(clk), .rst_(rst_), .n_raw(n_raw), .n(n));
	dime_coin U2 (.clk(clk), .rst_(rst_), .d_raw(d_raw), .d(d));
	quater_coin U3 (.clk(clk), .rst_(rst_), .q_raw(q_raw), .q(q));

	reg [3:0] cst, nst;
	localparam	SRST = 1,
				S5 = 2,
				S10 = 3,
				S15 = 4,
				S20 = 5,
				S25 = 6,
				S30 = 7,
				S35 = 8,
				S40 = 9,
				S45 = 10,
				SDUM1 = 11,
				SDUM2 = 12;

	always @ (posedge clk) begin
		if (!rst_) begin
			cst <= SRST;
			del <= 1'b0;
			rn <= 1'b0;
			rd <= 1'b0;
		end
		else begin
			cst <= nst;
		end
	end

	always @ (cst or n or d or q) begin
		case (cst)
			SRST : begin
				if (n) begin
					nst = S5;
				end
				else if (d) begin
					nst = S10;
				end
				else if (q) begin
					nst = S25;
				end
				else begin
					nst = cst;
				end
			end

			S5 : begin
				if (n) begin
					nst = S10;
				end
				else if (d) begin
					nst = S15;
				end
				else if (q) begin
					nst = S30;
				end
				else begin
					nst = cst;
				end
			end

			S10 : begin
				if (n) begin
					nst = S15;
				end
				else if (d) begin
					nst = S20;
				end
				else if (q) begin
					nst = S35;
				end
				else begin
					nst = cst;
				end
			end
			
			S15 : begin
				if (n) begin
					nst = S20;
				end
				else if (d) begin
					nst = S25;
				end
				else if (q) begin
					nst = S40;
				end
				else begin
					nst = cst;
				end
			end

			S20 : begin
				if (n) begin
					nst = S25;
				end
				else if (d) begin
					nst = S30;
				end
				else if (q) begin
					nst = S45;
				end
				else begin
					nst = cst;
				end
			end

			S25, S30, S35, S40, SDUM2 : begin
				nst = SRST;
			end

			S45 : begin
				nst = SDUM1;
			end

			SDUM1 : begin
				nst = SDUM2;
			end
			default : begin
				nst = SRST;
			end
		endcase
	end

	always @ (cst) begin
		del = ((cst==S25) || (cst==S30) || (cst==S35) || (cst==S40) || (cst==S45));
		rn = ((cst==S30) || (cst==S40));
		rd = ((cst==S35) || (cst==S40) || (cst==S45) || (cst==SDUM2));
	end
endmodule

module nickle_coin(
	input clk, rst_, n_raw,
	output reg n
);
	reg [1:0] cst, nst;
	localparam	S0 = 0,
				S01 = 1,
				S010 = 2;
	
	always @ (posedge clk) begin
		if (!rst_) begin
			cst <= S0;
		end
		else begin
			cst <= nst;
		end
	end

	always @ (cst or n_raw) begin
		case (cst)
			S0 : begin
				if (!n_raw) begin
					nst = S0;
				end
				else begin
					nst = S01;
				end
			end

			S01 : begin
				if (n_raw) begin
					nst = S01;
				end
				else begin
					nst = S010;
				end
			end
			S010 : begin
				if (!n_raw) begin
					nst = S0;
				end
				else begin
					nst = S01;
				end
			end
		endcase
	end

	always @ (cst) begin
		n = (cst==S010);
	end
endmodule
module dime_coin(
	input clk, rst_, d_raw,
	output reg d
);
	reg [1:0] cst, nst;
	localparam	S0 = 0,
				S01 = 1,
				S010 = 2;
	
	always @ (posedge clk) begin
		if (!rst_) begin
			cst <= S0;
		end
		else begin
			cst <= nst;
		end
	end

	always @ (cst or d_raw) begin
		case (cst)
			S0 : begin
				if (!d_raw) begin
					nst = S0;
				end
				else begin
					nst = S01;
				end
			end

			S01 : begin
				if (d_raw) begin
					nst = S01;
				end
				else begin
					nst = S010;
				end
			end
			S010 : begin
				if (!d_raw) begin
					nst = S0;
				end
				else begin
					nst = S01;
				end
			end
		endcase
	end

	always @ (cst) begin
		d = (cst==S010);
	end
endmodule
module quater_coin(
	input clk, rst_, q_raw,
	output reg q
);
	reg [1:0] cst, nst;
	localparam	S0 = 0,
				S01 = 1,
				S010 = 2;
	
	always @ (posedge clk) begin
		if (!rst_) begin
			cst <= S0;
		end
		else begin
			cst <= nst;
		end
	end

	always @ (cst or q_raw) begin
		case (cst)
			S0 : begin
				if (!q_raw) begin
					nst = S0;
				end
				else begin
					nst = S01;
				end
			end

			S01 : begin
				if (q_raw) begin
					nst = S01;
				end
				else begin
					nst = S010;
				end
			end
			S010 : begin
				if (!q_raw) begin
					nst = S0;
				end
				else begin
					nst = S01;
				end
			end
		endcase
	end

	always @ (cst) begin
		q = (cst==S010);
	end
endmodule

`ifdef TB
module tb();
	reg clk, rst_, n_raw, d_raw, q_raw;
	wire del, rn, rd;
	
	cvm_long_pulse UUT (.clk(clk), .rst_(rst_), .n_raw(n_raw), .d_raw(d_raw), .q_raw(q_raw), .del(del), .rn(rn), .rd(rd));

	task reset;
		begin
			clk = 1'b1;
			rst_ = 1'b1;
			n_raw = 1'b0;
			d_raw = 1'b0;
			q_raw = 1'b0;
			@(posedge clk) rst_ <= 1'b0;
			@(posedge clk) rst_ <= 1'b1;
		end
	endtask

	task insert_nickle;
		begin
			@(posedge clk) n_raw <= 1'b1;
			repeat(6) @(posedge clk);
			@(posedge clk) n_raw <= 1'b0;
		end
	endtask
	
	task insert_dime;
		begin
			@(posedge clk) d_raw <= 1'b1;
			repeat(3) @(posedge clk);
			@(posedge clk) d_raw <= 1'b0;
		end
	endtask
	
	task insert_quater;
		begin
			@(posedge clk) q_raw <= 1'b1;
			repeat(4) @(posedge clk);
			@(posedge clk) q_raw <= 1'b0;
		end
	endtask

	initial begin
		reset;
		
		repeat(4) insert_nickle; // n, n, n, n
		@(posedge clk);
		#1 n_raw = 1'b1;// inserting on the negedge of clk;
		#2 n_raw = 1'b0;

		//@(posedge clk);	// coin pulse should atleast 1 time period wide.
		//#1 n_raw = 1'b1;
		//#1 n_raw = 1'b0;
		
		repeat(5) @(posedge clk); // delay

		repeat(2) insert_dime;	// d, d
		@(posedge clk);
		#1 d_raw = 1'b1;	// inserting on the negedge of clk
		#2 d_raw = 1'b0;

		repeat(5) @(posedge clk); // delay
		repeat(2) insert_nickle;
		insert_dime;
		insert_quater;


		#20 $finish;
	end

	initial begin
		forever #1 clk = ~clk;
	end

	initial begin
		$recordfile("database.trn");
		$recordvars();
	end
endmodule
`endif
