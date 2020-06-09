// Created by fizzim.pl version 5.20 on 2020:06:08 at 22:48:02 (www.fizzim.com)

module lengthChecker (
  input hwclk,
  input wire bstate,
  input wire [3:0]button,
  input wire inputWrong,
  input wire readInput,
  output reg validUC,
  output reg validPC,

  //output led1, output led2,output led3, output led4,
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

  wire validUCLength;
  assign validUC = validUCLength;
  wire validPCLength;
  assign validPC = validPCLength;

  //wire [31:0]prevCount;
  wire [31:0]count;

  //wire testLED;
  /*
  assign led1 = state[0];
  assign led2 = state[1];
  assign led3 = state[2];
  assign led4 = count[3];
  */

  // comb always block
  always @(negedge bstate) begin
    nextstate = state; // default to hold value because implied_loopback is set
    case (state)
      START         : begin
        if (readInput&&(button[3:0]==4'd8)) begin
          count = 0;
          nextstate = READ_REPROGRAM;
        end
        else if (readInput&&(button[3:0]==4'd9)) begin
          count = 0;
          nextstate = READ_LOCK;
        end
        else begin
          nextstate = START;
        end
      end
      READ_LOCK     : begin
        if (readInput&&(button[3:0]==4'd9)) begin
          nextstate = START;
        end
        else begin
          nextstate = READ_LOCK;
          count = count + 1;
        end
      end
      READ_REPROGRAM: begin
        if (readInput&&(button[3:0]==4'd8)) begin
          count = 0;
          nextstate = REPROGRAM2;
        end
        else begin
          count = count + 1;
          nextstate = READ_REPROGRAM;
        end
      end
      REPROGRAM2    : begin
        if (readInput&&(button[3:0]==4'd8)) begin
          count = 0;
          nextstate = REPROGRAM3;
        end
        else begin
          count = count + 1;
          nextstate = REPROGRAM2;
        end
      end
      REPROGRAM3    : begin
        if (readInput&&(button[3:0]==4'd8)) begin
          nextstate = START;
        end
        else begin
          count = count + 1;
          nextstate = REPROGRAM3;
        end
      end
    endcase
    //prevCount <= count;
    validUCLength = (count > 32'd2) && (count < 32'd6);
    validPCLength = (count == 32'd5);
  end

  // Assign reg'd outputs to state bits

  // sequential always block
  always @(posedge hwclk/*negedge bstate or posedge inputWrong*/) begin
    if (inputWrong)
      state <= START;
    else if(button[3:0]==7)
      state <= START;
    else begin
      state <= nextstate;
    end
  end

  // This code allows you to see state names in simulation
  /*`ifndef SYNTHESIS
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
  `endif*/

endmodule
