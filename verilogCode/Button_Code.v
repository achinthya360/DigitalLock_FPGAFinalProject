//Use negedge of bstate to detect button releases in your main code.
module enterDigit(
    // input hardware clock (12 MHz)
    hwclk, 
    // Keypad lines
    keypad_r1,
    keypad_r2,
    keypad_r3,
    keypad_c1,
    keypad_c2,
    keypad_c3,
    button,
    bstate
    );

    input hwclk;

    output keypad_r1;
    output keypad_r2;
    output keypad_r3;
    input keypad_c1;
    input keypad_c2;
    input keypad_c3;

    output [3:0] button;
    reg [3:0] buttonReg;
    assign button = buttonReg;

    output bstate;
    reg bstateReg;
    assign bstate = bstateReg;


    wire keypad_c1_din;
    SB_IO #(
        .PIN_TYPE(6'b0000_01),
        .PULLUP(1'b1)
    ) keypad_c1_config (
        .PACKAGE_PIN(keypad_c1),
        .D_IN_0(keypad_c1_din)
    );

    wire keypad_c2_din;
    SB_IO #(
        .PIN_TYPE(6'b0000_01),
        .PULLUP(1'b1)
    ) keypad_c2_config (
        .PACKAGE_PIN(keypad_c2),
        .D_IN_0(keypad_c2_din)
    );

    wire keypad_c3_din;
    SB_IO #(
        .PIN_TYPE(6'b0000_01),
        .PULLUP(1'b1)
    ) keypad_c3_config (
        .PACKAGE_PIN(keypad_c3),
        .D_IN_0(keypad_c3_din)
    );


    /* Debouncing timer and period = 10 ms */
    reg [31:0] debounce_timer = 32'b0;
    parameter DEBOUNCE_PERIOD = 32'd120000;
    reg debouncing = 1'b0;

    reg [2:0] rowval = 3'b011;
    assign keypad_r1=rowval[0];
    assign keypad_r2=rowval[1];
    assign keypad_r3=rowval[2];

    wire dinNOR = (~keypad_c1_din | ~keypad_c2_din | ~keypad_c3_din);


    reg [1:0] counter = 2;

    always @ (negedge hwclk) begin
        //counter <= 2;
    
        counter <= (counter == 2) ? 0 : counter + 1;
        case (counter)
            2: rowval <= 3'b110; 
            0: rowval <= 3'b101;
            1: rowval <= 3'b011;
       endcase
       
    end

    always @ (posedge hwclk) begin
        
        // check for button presses
        if (~debouncing && ~keypad_c1_din) begin
            bstateReg <= 1;
            case (counter)
                0: buttonReg <= 4'd1; //1
                1: buttonReg <= 4'd4; //4
                2: buttonReg <= 4'd7; //7
            endcase
            debouncing <= 1;
        end else if (~debouncing && ~keypad_c2_din) begin
            bstateReg <= 1;
            case (counter)
                0: buttonReg <= 4'd2; //2
                1: buttonReg <= 4'd5; //5
                2: buttonReg <= 4'd8; //8
            endcase
            debouncing <= 1;
        end else if (~debouncing && ~keypad_c3_din) begin
            bstateReg <= 1;
            case (counter)
                0: buttonReg <= 4'd3; //3
                1: buttonReg <= 4'd6; //6
                2: buttonReg <= 4'd9; //9
            endcase
            debouncing <= 1;
        // reset debouncing if button is held low
        end else if (debouncing && dinNOR) begin
            debounce_timer <= 32'b0;
            bstateReg <= 0;
        // or if it's high, increment debounce timer
        end else if (debouncing && debounce_timer < DEBOUNCE_PERIOD) begin
            debounce_timer <= debounce_timer + 1;
        // finally, if it's high and timer expired, debouncing done!
        end else if (debouncing) begin
            debounce_timer <= 32'b0;
            debouncing <= 1'b0;
        end
    end

endmodule