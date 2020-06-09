// Created by fizzim.pl version 5.20 on 2020:06:08 at 22:48:02 (www.fizzim.com)

module lengthChecker (
  input wire bstate,
  input wire button[3:0],
  input wire inputWrong,
  input wire readInput,
  output reg validUC,
  output reg validPC,
);

  // state bits
  parameter 
  START          = 3'b000, 
  READ_LOCK      = 3'b001, 
  READ_REPROGRAM = 3'b010, 
  REPROGRAM2     = 3'b011, 
  REPROGRAM3     = 3'b100; 

  reg [2:0] state;
  reg [2:0] nextstate;

  reg validUCLength;
  assign validUC = validUCLength;
  reg validPCLength;
  assign validPC = validPCLength;

  wire prevCount[3:0];
  wire count[3:0];

  // comb always block
  always @(button) begin
    nextstate = state; // default to hold value because implied_loopback is set
    case (state)
      START         : begin
        if (readInput&(button[3:0]==8)) begin
          count <= 0;
          nextstate = READ_REPROGRAM;
        end
        else if (readInput&(button[3:0]==9)) begin
          count <= 0;
          nextstate = READ_LOCK;
        end
        else begin
          nextstate = START;
        end
      end
      READ_LOCK     : begin
        if (readInput&(button[3:0]==9)) begin
          nextstate = START;
        end
        else begin
          nextstate = READ_LOCK;
          count <= count + 1;
        end
      end
      READ_REPROGRAM: begin
        if (readInput&(button[3:0]==8)) begin
          count <= 0;
          nextstate = REPROGRAM2;
        end
        else begin
          count <= count + 1;
          nextstate = READ_REPROGRAM;
        end
      end
      REPROGRAM2    : begin
        if (readInput&(button[3:0]==8)) begin
          count <= 0;
          nextstate = REPROGRAM3;
        end
        else begin
          count <= count + 1;
          nextstate = REPROGRAM2;
        end
      end
      REPROGRAM3    : begin
        if (readInput&(button[3:0]==8)) begin
          nextstate = START;
        end
        else begin
          count <= count + 1;
          nextstate = REPROGRAM3;
        end
      end
    endcase
    prevCount <= count;
    validUCLength <= (count > 3) & (count < 7);
    validPCLength <= (count == 6);
  end

  // Assign reg'd outputs to state bits

  // sequential always block
  always @(negedge bstate or negedge inputWrong) begin
    if (!inputWrong | (button[3:0]==7))
      state <= START;
    else
      state <= nextstate;
  end

  // This code allows you to see state names in simulation
  `ifndef SYNTHESIS
  reg [111:0] statename;
  always @* begin
    case (state)
      START         :
        statename = "START";
      READ_LOCK     :
        statename = "READ_LOCK";
      READ_REPROGRAM:
        statename = "READ_REPROGRAM";
      REPROGRAM2    :
        statename = "REPROGRAM2";
      REPROGRAM3    :
        statename = "REPROGRAM3";
      default       :
        statename = "XXXXXXXXXXXXXX";
    endcase
  end
  `endif

endmodule
