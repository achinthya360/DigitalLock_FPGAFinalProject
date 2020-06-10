// Code your design here
// Created by fizzim.pl version 5.20 on 2020:06:09 at 16:19:54 (www.fizzim.com)

// Warning T20: 9 bits specified as type "reg".  Type "reg" means they will be included in the state encoding.  With so many bits, this might take a very long time and/or consume large amounts of memory.  Consider converting some of them to type "regdp" or type "flag".  To suppress this message in the future, use "-nowarn T20" 

//`timescale 1ns / 1ps

module controller (
  output wire blinkType,
  output wire check1,
  output wire check2,
  output wire led1,
  output wire led2,
  output wire led3,
  output wire read_input,
  output wire start_blinking,
  output wire store,
  output wire [1:0] compareType,
  input wire [3:0] button,
  input wire hwclk,
  input wire bstate,
  input wire correct_input,
  input wire data_ready,
  input wire done_blinking,
  input wire ledblink,
  input wire validLength,
  input wire validLengthPC,
  
  output wire testLED,
  output wire testLED2,
);

  //initial blinkType = 0;		//update with this variable at every blinking state
  //reg check1;
  //reg check2;
  //reg led1;
  //reg led2;
  //reg led3;
  //reg read_input;
  //reg start_blinking;
  initial led1 = 0;
  initial store = 0;
  initial read_input = 1;
  initial testLED = 0;
  initial testLED2 = 0;
  
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
  initial state = IDLE;
  reg [10:0] nextstate;

  // comb always block
  always @(*) begin
    
    nextstate = state; // default to hold value because implied_loopback is set
    case (state)
      IDLE            : begin
        testLED = 1;
        testled2 = 0;
        led1 = led1;
        led2 = 0;
        led3 = 0;
        read_input = 1;							//is this correct?
        if (button[3:0]==9) begin
          testLED=0;
          testLED2=1;
          nextstate = locktoggleCE;
        end
        else if (button[3:0]==8) begin
          testLED =0;
          testLED2=1;
          nextstate = readPC;
        end
        else begin
          nextstate = IDLE;
        end
      end
      LED3longblink   : begin
        //led1 = led1;
        led2 = 0;
        led3 = ledblink;
        read_input = 0;
        start_blinking = 1;
        if (done_blinking) begin
          nextstate = IDLE;
          start_blinking = 0;
        end
        else if (!done_blinking) begin
          nextstate = LED3longblink;
          start_blinking = 1;
        end
      end
      checkPC         : begin
        led1 = led1;
        led2 = 0;
        led3 = 1;
        read_input = 0;
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
        //led1 = led1;
        led2 = 1;
        led3 = 0;
        read_input = 0;
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
        //led1 = led1;
        led2 = 1;
        led3 = 0;
        read_input = 1;
        testLED2 = 1;
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
        led1 = led1;
        led2 = 0;
        led3 = 1;
        read_input = 0;
        compareType = 2'b10;
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
        //led1 = led1;
        led2 = 0;
        led3 = 1;
        read_input = 1;
        compareType = 2'b00;
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
        led1 = led1;
        led2 = 0;
        led3 = 1;
        read_input = 1;
        compareType = 2'b11;
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
        led1 = led1;
        led2 = 0;
        led3 = 1;
        read_input = 1;
        compareType = 2'b10;
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
        led1 = led1;
        led2 = 0;
        led3 = ledblink;
        read_input = 0;
        start_blinking = 1;
        blinkType = 1;
        store = 1;
        if (done_blinking) begin
          store = 0;
          blinkType = 0;
          start_blinking = 0;
          nextstate = IDLE;
        end
        else if (!done_blinking) begin
          store = 1;
          blinkType = 1;
          start_blinking = 1;
          nextstate = reprogramSuccess;
        end
      end
      toggle_lock     : begin
        led1 = !led1;
        led2 = 0;
        led3 = 0;
        read_input = 0;
        if (button[3:0]==7) begin
          nextstate = LED3longblink;
        end
        else begin
          nextstate = IDLE;
        end
      end
      wrongUCblink    : begin
        //led1 = led1;
        led2 = ledblink;
        led3 = 0;
        read_input = 0;
        start_blinking = 1;
        if (done_blinking) begin
          nextstate = IDLE;
          start_blinking = 0;
        end
        else if (!done_blinking) begin
          nextstate = wrongUCblink;
          start_blinking = 1;
        end
      end
    endcase
  end

  // Assign reg'd outputs to state bits
  //assign blinkType = state[0];
  assign check1 = state[1];
  assign check2 = state[2];
  //assign led1 = state[3];
  //assign led2 = state[4];
  //assign led3 = state[5];
  //assign read_input = state[6];
  //assign start_blinking = state[7];
  //assign store = state[8];

  // sequential always block
  always @(negedge bstate) begin
      state <= nextstate;
  end

/*
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
  `endif */

endmodule
