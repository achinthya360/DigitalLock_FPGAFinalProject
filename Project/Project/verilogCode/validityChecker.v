
module validChecker (
  input hwclk,
  input wire bstate,
  input wire [3:0]button,
  input wire inputWrong,
  input wire readInput,
  input wire [1:0]compareType,
  //input wire [23:0]correctUC,
  //input wire [23:0]correctPC,
  input wire store,
  output reg correct,
  output wire [23:0]newUC,
  output wire dataready,

  output led1, output led2,output led3, output led4,
);

	wire [3:0] prev1, prev2, prev3, prev4, prev5, prev6, prevNum;
	reg [3:0] prevUC1, prevUC2, prevUC3, prevUC4, prevUC5, prevUC6;
	
	/* just testing purposes */
	assign led1 = prev6[0];
	assign led2 = prev6[1];
	assign led3 = prev6[2];
	assign led4 = prev6[3];

	reg [23:0] correctUC;
    initial correctUC = (correctUC1 << 20) + (correctUC2 << 16) + (correctUC3 << 12)
    + (correctUC4 << 8) + (correctUC5 << 4) + (correctUC6);
    parameter [3:0]correctUC1 = 1;
    parameter [3:0]correctUC2 = 2;
    parameter [3:0]correctUC3 = 3;
    parameter [3:0]correctUC4 = 4;
    parameter [3:0]correctUC5 = 5;
    parameter [3:0]correctUC6 = 6;


    parameter [23:0] correctPC = (correctPC1 << 20) + (correctPC2 << 16) + (correctPC3 << 12)
    + (correctPC4 << 8) + (correctPC5 << 4) + (correctPC6);
    parameter [3:0]correctPC1 = 6;
    parameter [3:0]correctPC2 = 6;
    parameter [3:0]correctPC3 = 6;
    parameter [3:0]correctPC4 = 6;
    parameter [3:0]correctPC5 = 6;
    parameter [3:0]correctPC6= 6;

	parameter COMPAREPC = 2'b00;
	parameter COMPAREUC = 2'b01;
	parameter MATCHUC = 2'b10;
	parameter STOREUC = 2'b11;

	always @(negedge bstate) begin
		if(readInput) begin // only update registers when inputs should be read
			if((prevNum==8||prevNum==9)||(button[3:0]==7)) begin
				prev1 = 0;
				prev2 = 0;
				prev3 = 0;
				prev4 = 0;
				prev5 = 0;
				prev6 = button;
				prevNum = 0;
				correct <= 0;
				dataready <= 0;
			end 
			else if(((button[3:0]==8)||(button[3:0]==9)) && correct == 1) begin // ignore 8 or 9
				prevNum = button;
				dataready <= 1;
			end
			else begin
				prev1 = prev2;
				prev2 = prev3;
				prev3 = prev4;
				prev4 = prev5;
				prev5 = prev6;
				prev6 = button;
				correct <= 0;
				dataready <= 0;
			end 
		end

		if(compareType==COMPAREPC) begin // compare PCs
			if(prev1[3:0]==correctPC[23:20]
				&& prev2[3:0]==correctPC[19:16]
				&& prev3[3:0]==correctPC[15:12]
				&& prev4[3:0]==correctPC[11:8]
				&& prev5[3:0]==correctPC[7:4]
				&& prev6[3:0]==correctPC[3:0]) begin
				dataready <= 1;
				correct <= 1;
			end
		end
		else if(compareType==COMPAREUC) begin // compare UC to correct UC
			if((prev1[3:0]==correctUC[23:20] /*| correctUC[23:20]==0*/)
				&& (prev2[3:0]==correctUC[19:16] /*| correctUC[19:16]==0*/)
				&& prev3[3:0]==correctUC[15:12]
				&& prev4[3:0]==correctUC[11:8]
				&& prev5[3:0]==correctUC[7:4]
				&& prev6[3:0]==correctUC[3:0]) begin
				dataready <= 1;
				correct <= 1;
			end
		end
		else if(compareType==MATCHUC) begin// compare UC to previously entered input UC
			if((prev1[3:0]==prevUC1[3:0] /*| prevUC1[23:20]==0*/)
				&& (prev2[3:0]==prevUC2[3:0] /*| prevUC1[19:16]==0*/)
				&& prev3[3:0]==prevUC3[3:0]
				&& prev4[3:0]==prevUC4[3:0]
				&& prev5[3:0]==prevUC5[3:0]
				&& prev6[3:0]==prevUC6[3:0]) begin
				dataready <= 1;
				correct <= 1;
			end
		end
		else begin // store a UC for future comparison
			prevUC1 = prev1;
			prevUC2 = prev2;
			prevUC3 = prev3;
			prevUC4 = prev4;
			prevUC5 = prev5;
			prevUC6 = prev6;
			dataready <= 0;
			correct <= 1;
		end
	end

	always @(negedge store) begin
		// newUC[23:20] = prev1;
		// newUC[19:16] = prev2;
		// newUC[15:12] = prev3;
		// newUC[11:8] = prev4;
		// newUC[7:4] = prev5;
		// newUC[3:0] = prev6;

		correctUC[23:20] = prevUC1;
		correctUC[19:16] = prevUC2;
		correctUC[15:12] = prevUC3;
		correctUC[11:8] = prevUC4;
		correctUC[7:4] = prevUC5;
		correctUC[3:0] = prevUC6;
	end


endmodule