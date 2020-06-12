// Code your design here
// Created by fizzim.pl version 5.20 on 2020:06:09 at 16:19:54 (www.fizzim.com)

// Warning T20: 9 bits specified as type "reg".  Type "reg" means they will be included in the state encoding.  With so many bits, this might take a very long time and/or consume large amounts of memory.  Consider converting some of them to type "regdp" or type "flag".  To suppress this message in the future, use "-nowarn T20" 

//`timescale 1ns / 1ps

module controller (
  output wire blinkType,
  //output wire check1,
  //output wire check2,
  output led1,
  output wire led2,
  output wire led3,
  output wire read_input,
  output wire start_blinking,
  output wire store,
  output wire [1:0] compareType,
  input wire [3:0]button,
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
  output wire testLED3,
  output wire testLED4,
);

  wire led1;
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
/*
  initial testLED = 0;
  initial testLED2 = 0;
  initial testLED3 = 0;
  initial testLED4 = 0;
*/
  
  reg prevbstate;
  reg bstatechange;
  initial bstatechange = 0;
  
  parameter COMPAREPC = 2'b00;
  parameter COMPAREUC = 2'b01;
  parameter MATCHUC = 2'b10;
  parameter STOREUC = 2'b11;

  // state bits
  parameter 
  IDLE             = 4'b0000, // extra=00 store=0 start_blinking=0 read_input=0 led3=0 led2=0 led1=0 check2=0 check1=0 blinkType=0 
  LED3LONGBLINK    = 4'b0001, // extra=00 store=0 start_blinking=1 read_input=0 led3=0 led2=0 led1=0 check2=0 check1=0 blinkType=0 
  CHECKPC          = 4'b0010, // extra=00 store=0 start_blinking=0 read_input=0 led3=1 led2=0 led1=0 check2=0 check1=0 blinkType=0 
  INPUT_CHECK      = 4'b0011, // extra=00 store=0 start_blinking=0 read_input=0 led3=0 led2=1 led1=0 check2=0 check1=0 blinkType=0 
  LOCKTOGGLECE     = 4'b0100, // extra=00 store=0 start_blinking=0 read_input=1 led3=0 led2=1 led1=0 check2=0 check1=0 blinkType=0 
  MATCHUCS         = 4'b0101, // extra=01 store=0 start_blinking=0 read_input=0 led3=1 led2=0 led1=0 check2=0 check1=0 blinkType=0 
  READPC           = 4'b0110, // extra=00 store=0 start_blinking=0 read_input=1 led3=1 led2=0 led1=0 check2=0 check1=0 blinkType=0 
  READUC           = 4'b0111, // extra=01 store=0 start_blinking=0 read_input=1 led3=1 led2=0 led1=0 check2=0 check1=0 blinkType=0 
  READUC2          = 4'b1000, // extra=10 store=0 start_blinking=0 read_input=1 led3=1 led2=0 led1=0 check2=0 check1=0 blinkType=0 
  REPROGRAMSUCCESS = 4'b1001, // extra=00 store=1 start_blinking=1 read_input=0 led3=0 led2=0 led1=0 check2=0 check1=0 blinkType=1 
  TOGGLE_LOCK      = 4'b1010, // extra=01 store=0 start_blinking=0 read_input=0 led3=0 led2=0 led1=0 check2=0 check1=0 blinkType=0 
  WRONGUCBLINK     = 4'b1011; // extra=01 store=0 start_blinking=1 read_input=0 led3=0 led2=0 led1=0 check2=0 check1=0 blinkType=0 

  reg [3:0] state;
  initial state = IDLE;
  reg [3:0] nextstate;

  // comb always block
  always @(*) begin
    
    nextstate = state; // default to hold value because implied_loopback is set
    
    /* 1. use blake's makeshift bstate posedge for state transitions
       2. fix blinking timing 
    */
    if(prevbstate&(!bstate)) begin
      bstatechange = 1;
    end
    else begin
      bstatechange = 0;
    end  
    
    start_blinking <= 0;
    blinkType <= 0;

    case (state)
      IDLE            : begin
        //testLED = 1;
        //testLED2 = 0;
        //led1 <= 0;              //change later
        led2 <= 0;
        led3 <= 0;
        read_input <= 1;
        compareType <= 0;
        start_blinking <= 0;
        store = 0;					
        if (bstatechange & button[3:0]==4'd9) begin
          //testLED=0;
          //testLED2=1;
          nextstate = LOCKTOGGLECE;
        end
        else if (bstatechange & button[3:0]==4'd8) begin
          //testLED =0;
          //testLED2=1;

          nextstate = READPC;
        end
        else begin
          nextstate = IDLE;
        end
      end
      LED3LONGBLINK   : begin
        //led1 = 1;                                   //comment this out later
        led2 <= 0;
        led3 <= ledblink;
        read_input = 0;
        start_blinking = 1;
        compareType <= 0;
        if (done_blinking) begin
          nextstate = IDLE;
          start_blinking = 0;
        end
        else if (!done_blinking) begin
          nextstate = LED3LONGBLINK;
          start_blinking = 1;
        end
      end
      CHECKPC         : begin
        //led1 = led1;
        led2 <= 0;
        led3 <= 1;
        read_input = 0;
        compareType <= COMPAREPC;
        if (/*data_ready&*/correct_input) begin
          nextstate = READUC;
        end
        else if (/*data_ready&*/!correct_input|((button[3:0]==7)&bstatechange)) begin
          nextstate = LED3LONGBLINK;
        end
        /*
        else if (!data_ready) begin
          nextstate = CHECKPC;
        end */
      end
      INPUT_CHECK     : begin
        //led1 = led1;
        led2 <= 1;
        led3 <= 0;
        read_input = 0;
        compareType = COMPAREUC;
        if (button[3:0]==7) begin
          nextstate = LED3LONGBLINK;
        end
        else if (/*data_ready&*/correct_input) begin
          nextstate = TOGGLE_LOCK;
        end
        /*
        else if (!data_ready) begin
          nextstate = INPUT_CHECK;
        end */
        else if (/*data_ready&*/!correct_input) begin
          nextstate = WRONGUCBLINK;
        end
      end
      LOCKTOGGLECE    : begin
        //led1 = led1;
        led2 <= 1;
        led3 <= 0;
        read_input = 1;
        compareType <= COMPAREUC;
        //testLED2 = 1;
        if (bstatechange&(button[3:0]==9)&(validLength)) begin
          nextstate = INPUT_CHECK;
        end
        else if(bstatechange&(button[3:0]==9)&!validLength) begin
          nextstate = WRONGUCBLINK;
        end
        else if (bstatechange&button[3:0]==7) begin
          nextstate = LED3LONGBLINK;
        end
        else begin
          nextstate = LOCKTOGGLECE;
        end
      end
      MATCHUCS        : begin
        //led1 = led1;
        led2 <= 0;
        led3 <= 1;
        read_input = 0;
        compareType = MATCHUC;
        start_blinking = 0;
        if (/*data_ready&*/correct_input) begin
          blinkType = 1;
          nextstate = REPROGRAMSUCCESS;
        end
        else if (/*data_ready&*/!correct_input|((button[3:0]==7)&bstatechange)) begin
          blinkType = 0;
          nextstate = LED3LONGBLINK;
        end
        /*
        else if (!data_ready) begin
          nextstate = MATCHUCS;
        end */
      end
      READPC          : begin
        //led1 = led1;
        led2 <= 0;
        led3 <= 1;
        read_input = 1;
        compareType = COMPAREPC;
        start_blinking = 0;
        if (bstatechange&(button[3:0]==8)/*&validLengthPC*/) begin
          nextstate = CHECKPC;
        end
        else if (bstatechange&(button[3:0]==8)&!validLengthPC|((button[3:0]==7)&bstatechange)) begin
          nextstate = LED3LONGBLINK;
        end
        else begin
          nextstate = READPC;
        end
      end
      READUC          : begin
        //led1 = led1;
        led2 <= 0;
        led3 <= 1;
        read_input = 1;
        compareType = STOREUC;
        start_blinking = 0;
        if (bstatechange&(button[3:0]==8)/*&validLength*/) begin
          nextstate = READUC2;
        end
        else if (bstatechange&(button[3:0]==8)&!validLength|((button[3:0]==7)&bstatechange)) begin
          nextstate = LED3LONGBLINK;
        end
        else begin
          nextstate = READUC;
        end
      end
      READUC2         : begin
        //led1 = led1;
        led2 <= 0;
        led3 <= 1;
        read_input = 1;
        compareType = MATCHUC;
        if (bstatechange&(button[3:0]==8)&validLength) begin
          nextstate = MATCHUCS;
        end
        else if (bstatechange&(button[3:0]==8)&!validLength|((button[3:0]==7)&bstatechange)) begin
          nextstate = LED3LONGBLINK;
        end
        else begin
          nextstate = READUC2;
        end
      end
      REPROGRAMSUCCESS: begin
        //led1 = led1;
        led2 <= 0;
        led3 <= ledblink;
        read_input = 0;
        start_blinking = 1;
        blinkType = 1;
        store = 1;
        compareType <= 0;
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
          nextstate = REPROGRAMSUCCESS;
        end
      end
      TOGGLE_LOCK     : begin
        led1 <= ~led1;
        led2 <= 0;
        led3 <= 0;
        read_input = 0;
        compareType <= 0;
        if (bstatechange&button[3:0]==7) begin
          nextstate = LED3LONGBLINK;
        end
        else begin
          nextstate = IDLE;
        end
      end
      WRONGUCBLINK    : begin
        //led1 = led1;
        led2 <= ledblink;
        led3 <= 0;
        read_input = 0;
        start_blinking = 1;
        blinkType <= 0;
        compareType <= 0;
        if (done_blinking) begin
          nextstate = IDLE;
          start_blinking = 0;
        end
        else if (!done_blinking) begin
          nextstate = WRONGUCBLINK;
          start_blinking = 1;
        end
      end
    endcase
  end

  // Assign reg'd outputs to state bits
  //assign blinkType = state[0];
  //assign check1 = state[1];
  //assign check2 = state[2];
  //assign led1 = state[3];
  //assign led2 = state[4];
  //assign led3 = state[5];
  //assign read_input = state[6];
  //assign start_blinking = state[7];
  //assign store = state[8];

  // sequential always block
  always @(posedge hwclk) begin
      state <= nextstate;
    testLED <= state[0];
    testLED2 <= state[1];
    testLED3 <= state[2];
    testLED4 <= state[3]; 

    prevbstate <= bstate;
  end

/*
  // This code allows you to see state names in simulation
  `ifndef SYNTHESIS
  reg [127:0] statename;
  always @* begin
    case (state)
      IDLE            :
        statename = "IDLE";
      LED3LONGBLINK   :
        statename = "LED3LONGBLINK";
      CHECKPC         :
        statename = "CHECKPC";
      INPUT_CHECK     :
        statename = "INPUT_CHECK";
      LOCKTOGGLECE    :
        statename = "LOCKTOGGLECE";
      MATCHUCS        :
        statename = "MATCHUCS";
      READPC          :
        statename = "READPC";
      READUC          :
        statename = "READUC";
      READUC2         :
        statename = "READUC2";
      REPROGRAMSUCCESS:
        statename = "REPROGRAMSUCCESS";
      TOGGLE_LOCK     :
        statename = "TOGGLE_LOCK";
      WRONGUCBLINK    :
        statename = "WRONGUCBLINK";
      default         :
        statename = "XXXXXXXXXXXXXXXX";
    endcase
  end
  `endif */

endmodule
