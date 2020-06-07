// Blink an LED provided blink durations and quantity of blinks
/* module */
module blinker (
    hwclk,
    led,

    blinkCount,
    blinkLengthOn,
    blinkLengthOff,

    start_blinking,
    done_blinking,
    );

    /* I/O */
    input hwclk;
    output led;

    input [3:0] blinkCount;
    input [4:0] blinkLengthOn;
    input [4:0] blinkLengthOff;

    input start_blinking;
    output done_blinking;

    /* register counts the number of led toggles (half blinks) that have occurred*/
    reg [4:0] numBlinks = 32'b0;

    reg [31:0] row_timer = 32'b0;
    reg [31:0] blink_timer = 32'b0;
    reg [4:0] blink_counter = 5'b0;
    
    reg clk_led = 0;

    assign led = clk_led;
    
    /* specify blinkLengths in units: tenths of seconds */
    wire BLINK_PERIODON = 32'd1200000 /** 2*/ * blinkLengthOn;
    wire BLINK_PERIODOFF = 32'd1200000 /** 8*/ * blinkLengthOff;
    
    wire [4:0] timesToBlink = /* 32'd10 */ blinkCount * 2;

    always @ (posedge hwclk) begin
        if(start_blinking == 1) begin  // controller tells module to start blinking
            numBlinks <= 0;
            start_blinking <= 0;
            done_blinking <= 0;
        end
        else if(numBlinks < timesToBlink) begin
            if(clk_led) begin  // led ON
                if (blink_timer < BLINK_PERIODON) begin
                blink_timer <= blink_timer + 1; 
            end else begin
                blink_timer = 32'b0;
                numBlinks <= numBlinks + 1;
                clk_led <= ~clk_led;
            end
        end else begin  // led OFF
            if (blink_timer < BLINK_PERIODOFF) begin
                blink_timer <= blink_timer + 1;
            end else begin
                blink_timer = 32'b0;
                numBlinks <= numBlinks + 1;
                clk_led <= ~clk_led;
            end
        end
        end else begin    // module is done blinking
            clk_led <= 0;
            done_blinking <= 1;
        end
    end

endmodule
