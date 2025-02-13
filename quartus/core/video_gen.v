module video_gen(
    input wire clk,
    input wire reset,
    input wire cen,
    
    output wire [9:0] video_pos_x,
    output wire [8:0] video_pos_y,
    output wire hsync,
    output wire vsync,
    output wire hblank,
    output wire vblank,
    output wire enable
);

    // Horizontal regions
    localparam H_FRONT_PORCH = 40;
    localparam H_RETRACE     = 32;
    localparam H_BACK_PORCH  = 56;
    localparam H_DISPLAY     = 256;
    localparam H_SCAN        = H_FRONT_PORCH + H_RETRACE + H_BACK_PORCH + H_DISPLAY; // 384

    // Vertical regions
    localparam V_FRONT_PORCH = 16;
    localparam V_RETRACE     = 8;
    localparam V_BACK_PORCH  = 16;
    localparam V_DISPLAY     = 224;
    localparam V_SCAN        = V_FRONT_PORCH + V_RETRACE + V_BACK_PORCH + V_DISPLAY; // 264

    // Initial counter values
    localparam H_START = 128;
    localparam V_START = 248;

    // Position counters
    reg [9:0] x = H_START;
    reg [8:0] y = V_START;

    // Sync signals
    reg hsync_reg, vsync_reg;
    // Blank signals
    reg hblank_reg, vblank_reg;

    // Generate horizontal timing signals
    always @(posedge clk) begin
        if (cen) begin
            if (reset) begin
                x <= H_START;
            end else if (x == 511) begin
                x <= H_START;
            end else begin
                x <= x + 1;
            end

            // Assert the HSYNC signal after the front porch region. Deassert it after the horizontal retrace.
            if (x == H_START + H_FRONT_PORCH + H_RETRACE - 1) begin
                hsync_reg <= 1'b0;
            end else if (x == H_START + H_FRONT_PORCH - 1) begin
                hsync_reg <= 1'b1;
            end

            // Assert the HBLANK signal at the end of the scan line. Deassert it after the back porch region.
            if (x == H_START + H_FRONT_PORCH + H_RETRACE + H_BACK_PORCH - 1) begin
                hblank_reg <= 1'b0;
            end else if (x == H_START + H_SCAN - 1) begin
                hblank_reg <= 1'b1;
            end
        end
    end

    // Generate vertical timing signals
    always @(posedge clk) begin
        if (cen) begin
            if (reset) begin
                y <= V_START;
            end else if (x == H_START + H_FRONT_PORCH - 1) begin
                if (y == 511) begin
                    y <= V_START;
                end else begin
                    y <= y + 1;
                end

                if (y == V_START + V_RETRACE - 1) begin
                    vsync_reg <= 1'b0;
                end else if (y == V_START + V_SCAN - 1) begin
                    vsync_reg <= 1'b1;
                end

                if (y == V_START + V_RETRACE + V_BACK_PORCH - 1) begin
                    vblank_reg <= 1'b0;
                end else if (y == V_START + V_RETRACE + V_BACK_PORCH + V_DISPLAY - 1) begin
                    vblank_reg <= 1'b1;
                end
            end
        end
    end

    // Set video position
    assign video_pos_x = x;
    assign video_pos_y = y;

    // Set sync signals
    assign hsync = hsync_reg;
    assign vsync = vsync_reg;

    // Set blank signals
    assign hblank = hblank_reg;
    assign vblank = vblank_reg;

    // Set output enable
    assign enable = ~(hblank | vblank);

endmodule