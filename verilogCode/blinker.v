// Blink an LED provided blink durations and quantity of blinks
/* module */
module blinker (
    hwclk,
    led, // must be specified by controller

    testled, // just for debugging

    blinkType,

    start_blinking,
    done_blinking,
    );

    /* I/O */
    input hwclk;
    output led;

    output testled;
    
    input blinkType;

    input start_blinking;
    output done_blinking;

    wire start_blinkinglocal;

    /* register counts the number of led toggles (half blinks) that have occurred*/
    reg [3:0] numBlinks = 32'b0;
    reg [31:0] blink_timer = 32'b0;
    reg [4:0] blink_counter = 5'b0;
    
    reg clk_led = 0;

    // actual led number must be specified by controller
    assign led = clk_led;

    // error blink
    parameter PERIODON1 = 32'd60000000;   //0.5 SECONDS
    parameter PERIODOFF1 = 32'd120000000; // 1 SECOND
    parameter BLINKCOUNT1 = 4'd6;   // 3 BLINKS

    // successful programming blink
    parameter PERIODON2 = 32'd2400000;   // 0.2 SECONDS
    parameter PERIODOFF2 = 32'd2400000;  //0.2 SECONDS
    parameter BLINKCOUNT2 = 4'd10;  // 5 BLINKS
    
    /* specify blinkLengths in units: tenths of seconds */
    wire BLINK_PERIODON = PERIODON1;
    wire BLINK_PERIODOFF = PERIODOFF1;
    wire [3:0] timesToBlink = 20;

    always @(posedge start_blinking) begin
    start_blinkinglocal = 1;
    numBlinks = 0;
    case (blinkType)
        1'b0 : begin
            BLINK_PERIODON = PERIODON1;
            BLINK_PERIODOFF = PERIODOFF1;
            timesToBlink = BLINKCOUNT1;
        end
        1'b1 : begin
            BLINK_PERIODON = PERIODON2;
            BLINK_PERIODOFF = PERIODOFF2;
            timesToBlink = BLINKCOUNT2;
        end
    endcase
    end

    always @ (posedge hwclk) begin
        /*if(start_blinkinglocal == 1) begin  // controller tells module to start blinking
            numBlinks <= 0;
            start_blinkinglocal <= 0;
            done_blinking <= 0;
        end*/
        if(numBlinks < timesToBlink) begin
            if(clk_led) begin  // led ON   // TODO: CHANGE 1 TO clk_led
                if (blink_timer < BLINK_PERIODON) begin
                    blink_timer <= blink_timer + 1; 
                end 
                else begin
                    blink_timer = 32'b0;
                    numBlinks <= numBlinks + 1;
                    clk_led <= ~clk_led;
                    testled <= 1;
                end
            end 
            else begin  // led OFF
                if (blink_timer < BLINK_PERIODOFF) begin
                    blink_timer <= blink_timer + 1;
                end 
                else begin
                    blink_timer = 32'b0;
                    numBlinks <= numBlinks + 1;
                    clk_led <= ~clk_led;
                end
            end
        end 
        /*else begin    // module is done blinking
            clk_led <= 0; // change back to 0
            done_blinking <= 1;
        end*/
    end

endmodule
