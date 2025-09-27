`define TB

module cvm(
	input clk, rst_, n, d, q,
	output reg del, rn, rd
);
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
		end
		else begin
			cst <= nst;
		end
	end

	always @ (n or d or q) begin
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

`ifdef TB
module tb();
	reg clk, rst_, n, d, q;
	wire del, rn, rd;
	
	cvm UUT (.clk(clk), .rst_(rst_), .n(n), .d(d), .q(q), .del(del), .rn(rn), .rd(rd));

	task reset;
		begin
			clk = 1'b1;
			rst_ = 1'b1;
			n = 1'b0;
			d = 1'b0;
			q = 1'b0;
			@(posedge clk) rst_ <= 1'b0;
			@(posedge clk) rst_ <= 1'b1;
		end
	endtask

	task insert_nickle;
		begin
			@(posedge clk) n <= 1'b1;
			@(posedge clk) n <= 1'b0;
		end
	endtask
	
	task insert_dime;
		begin
			@(posedge clk) d <= 1'b1;
			@(posedge clk) d <= 1'b0;
		end
	endtask
	
	task insert_quater;
		begin
			@(posedge clk) q <= 1'b1;
			@(posedge clk) q <= 1'b0;
		end
	endtask

	initial begin
		reset;
		
		repeat(5) @(posedge clk) insert_nickle;

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
