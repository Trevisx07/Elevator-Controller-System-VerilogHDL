module ele(
    input clk,
    input [3:0] floor,
    input emergency_stop, // Emergency stop button input
    output reg [6:0] seg,
    output reg [6:0] seg2,

    output reg [3:0] leds,
    output reg up_led,
    output reg down_led
);

reg [3:0] cf = 4'b0001;
reg [3:0] last_floor_pressed = 4'b0001; // Track the last floor pressed

reg [31:0] clkdiv = 32'd0;
reg up_dir = 1'b0; // Initialize up direction to 0 (not moving)

// Priority Encoder for floor requests
wire [3:0] priority_floor = (floor != 4'b0000) ? floor : last_floor_pressed;

// Divide clock by 16 million
always @(posedge clk) begin
    clkdiv <= clkdiv + 1;
end

// Update current floor every 16 ms
always @(posedge clkdiv[25]) begin
    // Check if emergency stop is pressed, halt all movement if true
    if (emergency_stop) begin
        cf <= cf; // Hold current floor
    end
    else begin
        if (priority_floor < cf) begin
            if (cf == 4'b0001)
                cf <= 4'b0001;
            else
                cf <= cf >> 1;
        end
        else if (priority_floor > cf)
            cf <= cf << 1;
        // Store the last floor pressed
        if (floor != 4'b0000)
            last_floor_pressed <= floor;
    end
end

// Check if lift is moving up or down
always @(posedge clkdiv[25]) begin
    if (priority_floor != cf && !emergency_stop) begin
        if (priority_floor > cf)
            up_dir <= 1'b1; // Going up
        else
            up_dir <= 1'b0; // Going down
    end
end

// Display current floor and LEDs
always @(posedge clkdiv) begin
    case(cf)
        4'b0001: begin
            seg <= 7'b1111001; // Display 1
seg2 <= 7'b0001110;
            leds <= 4'b0001; // LED corresponding to floor 1 is on
            up_led <= up_dir; // Up LED is on if moving up
            down_led <= ~up_dir; // Down LED is on if moving down
        end
        4'b0010: begin
            seg <= 7'b0100100;
seg2 <= 7'b0001110; // Display 2
            leds <= 4'b0010; // LED corresponding to floor 2 is on
            up_led <= up_dir; // Up LED is on if moving up
            down_led <= ~up_dir; // Down LED is on if moving down
        end
        4'b0100: begin
            seg <= 7'b0110000; // Display 3
seg2 <= 7'b0001110;
            leds <= 4'b0100; // LED corresponding to floor 3 is on
            up_led <= up_dir; // Up LED is on if moving up
            down_led <= ~up_dir; // Down LED is on if moving down
        end
        4'b1000: begin
            seg <= 7'b0011001; // Display 4
seg2 <= 7'b0001110;
            leds <= 4'b1000; // LED corresponding to floor 4 is on
            up_led <= up_dir; // Up LED is on if moving up
            down_led <= ~up_dir; // Down LED is on if moving down
        end
       
    endcase
end                

endmodule
