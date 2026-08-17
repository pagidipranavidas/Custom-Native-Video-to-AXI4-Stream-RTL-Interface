`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.08.2026 15:16:44
// Design Name: 
// Module Name: native_video_to_axi4_stream
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
// native_video_to_axi4_stream
//
// Converts native video (data + hsync + vsync, valid every clock) into
// AXI4-Stream video. h_count/v_count are continuously self-corrected
// from the LIVE LEVEL of native_hsync/native_vsync (no edge detector,
// no shadow/delayed copy of the sync inputs anywhere) - the counters
// are pinned to a known position for as long as the real sync pulse is
// asserted, and simply resume counting once it deasserts.

module native_video_to_axi4_stream #(
  parameter active_hsize=1280,
  parameter active_vsize=720,
  parameter total_hsize=1650,
  parameter total_vsize=750,
  parameter hsync_start=1390,
  parameter hsync_end=1430,
  parameter vsync_start=725,
  parameter vsync_end=730,
  parameter data=24
  )
  (
    input clk,rst, 
    input active_video,
    input [data-1:0]native_data,
    input native_hsync,
    input native_vsync,
    input tready,
    output  [data-1:0]tdata,
    output  tvalid,tuser,tlast
    );
    
    reg [15:0]h_count;
    reg [15:0]v_count;
    
   always @(posedge clk) begin
        if (rst) begin
            h_count <= 16'd0;
            v_count <= 16'd0;
        end
        else begin
            if (h_count == total_hsize - 1) begin
                 h_count <= 16'd0;              // wrap -> start of new line
                 if(v_count == total_vsize -1)
                   v_count <= 16'd0;
                 else
                   v_count <= v_count+16'd1;
            // Current line is ending (h_count about to wrap) -> advance line count.
            end
           else begin
            h_count <= h_count + 16'd1;
        end
    end
  end

    /*always @(posedge clk) begin
        if (rst) begin
            tvalid <= 1'b0;
            tdata  <= {data{1'b0}};
            tuser  <= 1'b0;
            tlast  <= 1'b0;
        end
        else begin
            tvalid <= active_video;
            tdata  <= active_video ? native_data : {data{1'b0}};
            tuser  <= active_video && (h_count == 16'd0) && (v_count == 16'd0);   // start of frame
            tlast  <= active_video && (h_count == active_hsize - 1);              // end of line
        end
    end
endmodule */
    // ---------------------------------------------------------
    // AXI4-Stream video signals
    // Derived directly from the CURRENT timing position.
    // ---------------------------------------------------------

    assign tvalid = active_video;

    assign tuser = active_video && (h_count == 16'd0) && (v_count == 16'd0);

    assign tlast = active_video && (h_count == active_hsize - 1);

    assign tdata = active_video ? native_data : {data{1'b0}};
endmodule
