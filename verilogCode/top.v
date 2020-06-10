// Blink an LED provided an input clock
/* module */
module top (hwclk, led1, led2, led3, led4, led5, led6, led7, led8,
    // Keypad lines
    keypad_r1,
    keypad_r2,
    keypad_r3,
    keypad_c1,
    keypad_c2,
    keypad_c3,
    );

    /* I/O */
    input hwclk;
    output led1;
    output led2;
    output led3;
    output led4;
    output led5;
    output led6;
    output led7;
    output led8;

    output keypad_r1;
    output keypad_r2;
    output keypad_r3;

    input keypad_c1;
    input keypad_c2;
    input keypad_c3;

    wire [3:0] button;
    wire [3:0] button_local;
    wire bstate;

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

    enterDigit button_press(
        .hwclk(hwclk), 
        .keypad_r1(keypad_r1),
        .keypad_r2(keypad_r2),
        .keypad_r3(keypad_r3),
        .keypad_c1(keypad_c1),
        .keypad_c2(keypad_c2),
        .keypad_c3(keypad_c3),
        .button(button),
        .bstate(bstate),
    );

    wire blinkType;
    //initial blinkType = 0;
    wire startblinking;
    wire doneblinking;
    wire ledblink;

    blinker blinks(
        .hwclk(hwclk),
        .led(ledblink),
        .blinkType(blinkType),
        .start_blinking(startblinking),
        .done_blinking(doneblinking),
    );

    wire validUClength;
    wire validPClength;
    wire readInput; // = 1; // change later, assign to actual readInput from controller
    //initial readInput = 1;
    wire inputWrong; // = 0; // change later, assign to correctness checker module
    //initial inputWrong = 0;
    
    lengthChecker lCHECK(
        .hwclk(hwclk),
        .bstate(bstate),
        .button(button),
        .inputWrong(inputWrong),
        .readInput(readInput),
        .validUC(validUClength),
        .validPC(validPClength),
    ); 

    wire store;
    wire [1:0] compareType;
    //initial compareType = 2'b01;
    wire correct;
    wire newUC;
    wire data_ready;

    
    validChecker vCHECK(
        .hwclk(hwclk),
        .bstate(bstate),
        .button(button),
        .inputWrong(inputWrong),
        .readInput(readInput),
        .compareType(compareType),
        .correctUC(correctUC),
        .correctPC(correctPC),
        .store(store),
        .correct(correct),
        .newUC(newUC),
        .dataready(data_ready),
        
        /*
        .led1(led1),
        .led2(led2),
        .led3(led3),
        .led4(led4),   
        */
    ); 

    //wire check1;
    //wire check2;
    //wire blinkTypecontrol;
    //wire led_1;

    
    controller controlFSM(
        .blinkType(blinkType),
        //.check1(check1),        // are these check1 and 2 vestiges of logic before compareType was introduced???
        //.check2(check2),
        .led1(led1),
        .led2(led2),
        .led3(led3),
        .read_input(readInput),
        .start_blinking(startblinking),
        .store(store),
        .compareType(compareType),
        .button(button),
        .hwclk(hwclk),
        .bstate(bstate),
        .correct_input(correct),
        .data_ready(data_ready),
        .done_blinking(doneblinking),
        .ledblink(ledblink),
        .validLength(validUClength),
        .validLengthPC(validPClength),
        .testLED       (led5),
        .testLED2      (led6),
        .testLED3      (led7),
        .testLED4      (led8)
    ); 
    
    
    /*
    assign led8 = readInput;
    assign led7 = correct;
    reg testLED;
    assign led4 = testLED;
    assign led5 = testLED2;

    assign led1 = led_1;

    always @(posedge hwclk) begin
        blinkType <= blinkTypecontrol;
    end */

    
    //wire testLED; 
    //assign testLED = validUClength;
    //wire test2LED;
    //assign test2LED = validPClength;
    /*
    assign led7 = validUClength;
    assign led8 = validPClength;  

    assign led6 = correct;
    */
    //assign led5 = testLED2;
    assign led4 = correct;
    
    /*
    always @ (negedge bstate) begin
        if(readInput) begin
            button_local = button;
        end
    end */

    /*
            if(button_local[3:0] == 8) begin
                if(compareType == 2'b01) begin 
                    compareType <= 2'b11;
                end
                else if(compareType == 2'b11) begin
                    compareType <= 2'b10;
                end
                else if(compareType == 2'b10) begin
                    compareType <= 2'b01;
                end
            end
            else if (button_local[3:0] == 9) begin
                compareType <= 2'b01;
            end

        if(compareType <= 2'b10 && correct) begin
            store = 1;
            correctUC = newUC;
        end
        else begin
            store <= 0;
        end
        end
        
        testLED <= validUClength;
        test2LED <= validPClength;
    end */
    

endmodule
