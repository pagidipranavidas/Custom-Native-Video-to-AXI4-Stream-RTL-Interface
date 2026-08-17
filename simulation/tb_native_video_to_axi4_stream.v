`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.08.2026 11:06:29
// Design Name: 
// Module Name: tb_native_video_to_axi4_stream
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_native_video_to_axi4_stream();
 // ---------------- Parameters ----------
    localparam ACTIVE_HSIZE = 1280;
    localparam TOTAL_HSIZE  = 1650;
    localparam HSYNC_START  = 1390;
    localparam HSYNC_END    = 1430;

    localparam ACTIVE_VSIZE = 720;
    localparam TOTAL_VSIZE  = 750;
    localparam VSYNC_START  = 725;
    localparam VSYNC_END    = 730;

    localparam DATA_WIDTH   = 24;

    // ---------------- DUT signals ---------------------------------------
    reg                     clk;
    reg                     rst;
    reg                     active_video;
    reg  [DATA_WIDTH-1:0]   native_data;
    reg                     native_hsync;
    reg                     native_vsync;
    reg                     tready;

    wire [DATA_WIDTH-1:0]   tdata;
    wire                    tvalid;
    wire                    tuser;
    wire                    tlast;

    // ---------------- DUT instantiation -----------------------------------
    native_video_to_axi4_stream #(
        .active_hsize (ACTIVE_HSIZE),
        .active_vsize (ACTIVE_VSIZE),
        .total_hsize  (TOTAL_HSIZE),
        .total_vsize  (TOTAL_VSIZE),
        .hsync_start  (HSYNC_START),
        .hsync_end    (HSYNC_END),
        .vsync_start  (VSYNC_START),
        .vsync_end    (VSYNC_END),
        .data         (DATA_WIDTH)
    ) uut (
        .clk          (clk),
        .rst          (rst),
        .active_video (active_video),
        .native_data  (native_data),
        .native_hsync (native_hsync),
        .native_vsync (native_vsync),
        .tready       (tready),
        .tdata        (tdata),
        .tvalid       (tvalid),
        .tuser        (tuser),
        .tlast        (tlast)
    );

    // ---------------- Clock generation -------------------------------------
    initial clk = 1'b0;
    always #5 clk = ~clk;   // 100 MHz

    // ---------------- Video source model ------------------------------------
    // Free-running counters that generate native_hsync/native_vsync/native_data
    // matching the same timing parameters as the DUT.
    reg [15:0] src_h;
    reg [15:0] src_v;
    
    reg active_video;
    
    always @(posedge clk) begin
    if (rst) begin
        src_h <= 0;
        src_v <= 0;
    end

    else begin
        if (src_h == TOTAL_HSIZE-1) begin
            src_h <= 0;
            if (src_v == TOTAL_VSIZE-1)
                src_v <= 0;
            else
                src_v <= src_v + 1;
        end
        else begin
            src_h <= src_h + 1;
        end

    end
end

    always @(*) begin
        native_hsync = (src_h >= HSYNC_START) && (src_h < HSYNC_END);
        native_vsync = (src_v >= VSYNC_START) && (src_v < VSYNC_END);
        active_video = !rst && (src_h < ACTIVE_HSIZE) && (src_v < ACTIVE_VSIZE);
        
        if (active_video)
            native_data = {src_v[11:0], src_h[11:0]};   // unique pattern per pixel
        else
            native_data = {DATA_WIDTH{1'b0}};
    end

    // ---------------- Test --------------------------------------------------
   initial begin
    clk = 1'b0;
    rst = 1'b1;
    tready = 1'b1;
    #20;
    rst = 1'b0;

end
    
    initial begin
        $display("Simulation done at time %0t", $time);
        #100_000_000 $finish;
    end
    
endmodule

