// Created by fizzim.pl version 5.20 on 2020:06:10 at 00:21:18 (www.fizzim.com)

// Warning T20: 9 bits specified as type "reg".  Type "reg" means they will be included in the state encoding.  With so many bits, this might take a very long time and/or consume large amounts of memory.  Consider converting some of them to type "regdp" or type "flag".  To suppress this message in the future, use "-nowarn T20" 
module def_name (
  output wire blinkType,
  output wire check1,
  output wire check2,
  output wire led1,
  output wire led2,
  output wire led3,
  output wire read_input,
  output wire start_blinking,
  output wire store,
  input wire [3:0] button,
  input wire clk,
  input wire correct_input,
  input wire data_ready,
  input wire done_blinking,
  input wire led2blink,
  input wire led3blink,
  input wire validLength,
  input wire validLengthPC
);

  // state bits
  parameter 
  IDLE             = 11'b00000000000, // extra=00 store=0 start_blinking=0 read_input=0 led3=0 led2=0 led1=0 check2=0 check1=0 blinkType=0 
  LED3longblink    = 11'b00010000000, // extra=00 store=0 start_blinking=1 read_input=0 led3=0 led2=0 led1=0 check2=0 check1=0 blinkType=0 
  checkPC          = 11'b00000100000, // extra=00 store=0 start_blinking=0 read_input=0 led3=1 led2=0 led1=0 check2=0 check1=0 blinkType=0 
  input_check      = 11'b00000010000, // extra=00 store=0 start_blinking=0 read_input=0 led3=0 led2=1 led1=0 check2=0 check1=0 blinkType=0 
  locktoggleCE     = 11'b00001010000, // extra=00 store=0 start_blinking=0 read_input=1 led3=0 led2=1 led1=0 check2=0 check1=0 blinkType=0 
  matchUCs         = 11'b01000100000, // extra=01 store=0 start_blinking=0 read_input=0 led3=1 led2=0 led1=0 check2=0 check1=0 blinkType=0 
  readPC           = 11'b00001100000, // extra=00 store=0 start_blinking=0 read_input=1 led3=1 led2=0 led1=0 check2=0 check1=0 blinkType=0 
  readUC           = 11'b01001100000, // extra=01 store=0 start_blinking=0 read_input=1 led3=1 led2=0 led1=0 check2=0 check1=0 blinkType=0 
  readUC2          = 11'b10001100000, // extra=10 store=0 start_blinking=0 read_input=1 led3=1 led2=0 led1=0 check2=0 check1=0 blinkType=0 
  reprogramSuccess = 11'b00110000001, // extra=00 store=1 start_blinking=1 read_input=0 led3=0 led2=0 led1=0 check2=0 check1=0 blinkType=1 
  toggle_lock      = 11'b01000000000, // extra=01 store=0 start_blinking=0 read_input=0 led3=0 led2=0 led1=0 check2=0 check1=0 blinkType=0 
  wrongUCblink     = 11'b01010000000; // extra=01 store=0 start_blinking=1 read_input=0 led3=0 led2=0 led1=0 check2=0 check1=0 blinkType=0 

  reg [10:0] state;
  reg [10:0] nextstate;

  // comb always block
  always @* begin
    // Warning I2: Neither implied_loopback nor default_state_is_x attribute is set on state machine - defaulting to implied_loopback to avoid latches being inferred 
    nextstate = state; // default to hold value because implied_loopback is set
    case (state)
      IDLE            : begin
        // Warning P3: State IDLE has multiple exit transitions, and transition trans0 has no defined priority 
        // Warning P3: State IDLE has multiple exit transitions, and transition trans18 has no defined priority 
        if (button[3:0]==9) begin
          nextstate = locktoggleCE;
        end
        else if (button[3:0]==8) begin
          nextstate = readPC;
        end
        else begin
          nextstate = IDLE;
        end
      end
      LED3longblink   : begin
        // Warning P3: State LED3longblink has multiple exit transitions, and transition trans13 has no defined priority 
        // Warning P3: State LED3longblink has multiple exit transitions, and transition trans15 has no defined priority 
        if (done_blinking) begin
          nextstate = IDLE;
        end
        else if (!done_blinking) begin
          nextstate = LED3longblink;
        end
      end
      checkPC         : begin
        // Warning P3: State checkPC has multiple exit transitions, and transition trans21 has no defined priority 
        // Warning P3: State checkPC has multiple exit transitions, and transition trans29 has no defined priority 
        // Warning P3: State checkPC has multiple exit transitions, and transition trans34 has no defined priority 
        if (data_ready&correct_input) begin
          nextstate = readUC;
        end
        else if (data_ready&!correct_input|(button[3:0]==7)) begin
          nextstate = LED3longblink;
        end
        else if (!data_ready) begin
          nextstate = checkPC;
        end
      end
      input_check     : begin
        // Warning P3: State input_check has multiple exit transitions, and transition trans12 has no defined priority 
        // Warning P3: State input_check has multiple exit transitions, and transition trans2 has no defined priority 
        // Warning P3: State input_check has multiple exit transitions, and transition trans4 has no defined priority 
        // Warning P3: State input_check has multiple exit transitions, and transition trans8 has no defined priority 
        if (button[3:0]==7) begin
          nextstate = LED3longblink;
        end
        else if (data_ready&correct_input) begin
          nextstate = toggle_lock;
        end
        else if (!data_ready) begin
          nextstate = input_check;
        end
        else if (data_ready&!correct_input) begin
          nextstate = wrongUCblink;
        end
      end
      locktoggleCE    : begin
        // Warning P3: State locktoggleCE has multiple exit transitions, and transition trans1 has no defined priority 
        // Warning P3: State locktoggleCE has multiple exit transitions, and transition trans17 has no defined priority 
        if ((button[3:0]==9)&(validLength==1)) begin
          nextstate = input_check;
        end
        else if (button[3:0]==7) begin
          nextstate = LED3longblink;
        end
        else begin
          nextstate = locktoggleCE;
        end
      end
      matchUCs        : begin
        // Warning P3: State matchUCs has multiple exit transitions, and transition trans23 has no defined priority 
        // Warning P3: State matchUCs has multiple exit transitions, and transition trans30 has no defined priority 
        // Warning P3: State matchUCs has multiple exit transitions, and transition trans37 has no defined priority 
        if (data_ready&correct_input) begin
          nextstate = reprogramSuccess;
        end
        else if (data_ready&!correct_input|(button[3:0]==7)) begin
          nextstate = LED3longblink;
        end
        else if (!data_ready) begin
          nextstate = matchUCs;
        end
      end
      readPC          : begin
        // Warning P3: State readPC has multiple exit transitions, and transition trans19 has no defined priority 
        // Warning P3: State readPC has multiple exit transitions, and transition trans26 has no defined priority 
        if ((button[3:0]==8)&validLengthPC) begin
          nextstate = checkPC;
        end
        else if ((button[3:0]==8)&!validLengthPC|(button[3:0]==7)) begin
          nextstate = LED3longblink;
        end
        else begin
          nextstate = readPC;
        end
      end
      readUC          : begin
        // Warning P3: State readUC has multiple exit transitions, and transition trans20 has no defined priority 
        // Warning P3: State readUC has multiple exit transitions, and transition trans27 has no defined priority 
        if ((button[3:0]==8)&validLength) begin
          nextstate = readUC2;
        end
        else if ((button[3:0]==8)&!validLength|(button[3:0]==7)) begin
          nextstate = LED3longblink;
        end
        else begin
          nextstate = readUC;
        end
      end
      readUC2         : begin
        // Warning P3: State readUC2 has multiple exit transitions, and transition trans22 has no defined priority 
        // Warning P3: State readUC2 has multiple exit transitions, and transition trans28 has no defined priority 
        if ((button[3:0]==8)&validLength) begin
          nextstate = matchUCs;
        end
        else if ((button[3:0]==8)&!validLength|(button[3:0]==7)) begin
          nextstate = LED3longblink;
        end
        else begin
          nextstate = readUC2;
        end
      end
      reprogramSuccess: begin
        // Warning P3: State reprogramSuccess has multiple exit transitions, and transition trans31 has no defined priority 
        // Warning P3: State reprogramSuccess has multiple exit transitions, and transition trans33 has no defined priority 
        if (done_blinking) begin
          nextstate = IDLE;
        end
        else if (!done_blinking) begin
          nextstate = reprogramSuccess;
        end
      end
      toggle_lock     : begin
        if (button[3:0]==7) begin
          nextstate = LED3longblink;
        end
        else begin
          nextstate = IDLE;
        end
      end
      wrongUCblink    : begin
        // Warning P3: State wrongUCblink has multiple exit transitions, and transition trans7 has no defined priority 
        // Warning P3: State wrongUCblink has multiple exit transitions, and transition trans9 has no defined priority 
        if (done_blinking) begin
          nextstate = IDLE;
        end
        else if (!done_blinking) begin
          nextstate = wrongUCblink;
        end
      end
    endcase
  end

  // Assign reg'd outputs to state bits
  assign blinkType = state[0];
  assign check1 = state[1];
  assign check2 = state[2];
  assign led1 = state[3];
  assign led2 = state[4];
  assign led3 = state[5];
  assign read_input = state[6];
  assign start_blinking = state[7];
  assign store = state[8];

  // sequential always block
  always @(posedge clk or negedge correct_input) begin
    if (!correct_input)
      state <= IDLE;
    else
      state <= nextstate;
  end

  // This code allows you to see state names in simulation
  `ifndef SYNTHESIS
  reg [127:0] statename;
  always @* begin
    case (state)
      IDLE            :
        statename = "IDLE";
      LED3longblink   :
        statename = "LED3longblink";
      checkPC         :
        statename = "checkPC";
      input_check     :
        statename = "input_check";
      locktoggleCE    :
        statename = "locktoggleCE";
      matchUCs        :
        statename = "matchUCs";
      readPC          :
        statename = "readPC";
      readUC          :
        statename = "readUC";
      readUC2         :
        statename = "readUC2";
      reprogramSuccess:
        statename = "reprogramSuccess";
      toggle_lock     :
        statename = "toggle_lock";
      wrongUCblink    :
        statename = "wrongUCblink";
      default         :
        statename = "XXXXXXXXXXXXXXXX";
    endcase
  end
  `endif

endmodule
