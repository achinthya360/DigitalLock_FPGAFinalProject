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
    wire bstate;

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

    wire blinkType = 0;
    wire start_blinking = 0;
    wire done_blinking;

    blinker halfBlinks(
        .hwclk(hwclk),
        .led(led1),
        .blinkType(blinkType),
        .start_blinking(start_blinking),
        .done_blinking(done_blinking),
        .testled(testLED),
    );

    /* Counter register */
    reg [31:0] counter = 32'b0;

    /* LED drivers */
    assign led5 = button[0];
    assign led6 = button[1];
    assign led7 = button[2];
    assign led8 = button[3];

    wire testLED; 
    wire test2LED;
    assign led2 = testLED;
    assign led3 = test2LED;    

    /*always @ (negedge bstate) begin
        testLED = ~testLED;
        if(done_blinking == 1) begin
            test2LED = ~test2LED;
            start_blinking <= 1;
        end
    end*/

endmodule
