// Partly from https://timetoexplore.net/blog/arty-fpga-vga-verilog-01
`include "DataType.sv"

module VgaDisplayAdapter_640_480(
    input wire CLK,             // board clock: 100 MHz on Arty & Basys 3
    input wire RST_BTN,         // reset button
    output VgaSignal_t vga
    );

    wire rst = RST_BTN;  // reset is active low on Arty
    
    parameter ClkFrequency = 100000000; 
    localparam VGA_FREQUENCY = 25000000; // get a 25MHz clock
    localparam CLOCKS_NEEDED = ClkFrequency / VGA_FREQUENCY - 1;

    // generate a 25 MHz pixel strobe
    reg [2:0] cnt = 0;
    reg pix_stb = 0;
    always_ff @(posedge CLK) begin
      if(cnt == CLOCKS_NEEDED) begin
        cnt <= 0;
        pix_stb <= 1;
      end
      else begin
			pix_stb <= 0;
			cnt <= cnt + 1;
		end
    end

    wire [9:0] x;  // current pixel x position: 10-bit value: 0-1023
    wire [8:0] y;  // current pixel y position:  9-bit value: 0-511

    VgaSignalGenerator_640_480 display (
        .i_clk(CLK),
        .i_pix_stb(pix_stb),
        .o_hs(vga.hSync), 
        .o_vs(vga.vSync), 
        .o_x(x), 
        .o_y(y)
    );

    // Demo: Four overlapping squares
    wire sq_a, sq_b, sq_c, sq_d;
    assign sq_a = ((x > 120) & (y >  40) & (x < 280) & (y < 200)) ? 1 : 0;
    assign sq_b = ((x > 200) & (y > 120) & (x < 360) & (y < 280)) ? 1 : 0;
    assign sq_c = ((x > 280) & (y > 200) & (x < 440) & (y < 360)) ? 1 : 0;
    assign sq_d = ((x > 360) & (y > 280) & (x < 520) & (y < 440)) ? 1 : 0;

    assign vga.red[2] = sq_b;         // square b is red
    assign vga.green[2] = sq_a | sq_d;  // squares a and d are green
    assign vga.blue[2] = sq_c;         // square c is blue

    // TODO: read from SRAM in a 25MHz clock
endmodule