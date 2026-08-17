# Custom Native Video to AXI4-Stream RTL Interface

A custom Verilog RTL implementation that converts a **native video interface** into an **AXI4-Stream video interface** for a 1280×720 video timing configuration.

The project was developed to understand the RTL-level implementation of native-video to AXI4-Stream conversion, including pixel tracking, active-video detection, **Start-of-Frame (TUSER)** and **End-of-Line (TLAST)** generation.

---

## Architecture

```text
          Native Video Source
        (Behavioral Testbench)
                 │
                 │
     ┌───────────┼────────────┐
     │           │            │
     ▼           ▼            ▼
active_video  native_data  HSYNC / VSYNC
     │           │            │
     └───────────┼────────────┘
                 ▼
      ┌─────────────────────────┐
      │   Custom Verilog RTL    │
      │                         │
      │ Native Video → AXI4S   │
      │                         │
      │ • Pixel/Line Counters  │
      │ • Active Video          │
      │ • SOF Generation        │
      │ • EOL Generation        │
      │ • Pixel Data Mapping    │
      └────────────┬────────────┘
                   │
                   ▼
            AXI4-Stream Video
                   │
       ┌───────────┼───────────┐
       ▼           ▼           ▼
     TDATA       TUSER       TLAST
                 (SOF)       (EOL)
```
Key Features
Custom Verilog RTL for Native Video → AXI4-Stream conversion
24-bit video pixel data path
1280×720 active video resolution
Parameterized horizontal and vertical timing
Horizontal and vertical pixel-position counters
TVALID generation from active-video status
TUSER generation for Start-of-Frame
TLAST generation for End-of-Line
Behavioral native-video source model in the testbench
RTL simulation and waveform-based verification using Vivado
Video Configuration

Parameter	Value
Active Resolution	1280 × 720
Pixel Width	24 bits
Total Horizontal	1650 pixels
Total Vertical	750 lines
Horizontal Front Porch	110
Horizontal Sync	40
Horizontal Back Porch	220
Vertical Front Porch	5
Vertical Sync	5
Vertical Back Porch	20
Simulation Clock	100 MHz

Timing
 ``` textHorizontal:
1280 Active + 110 FP + 40 Sync + 220 BP = 1650
Vertical:
720 Active + 5 FP + 5 Sync + 20 BP = 750

At 100 MHz, the configured timing corresponds to:

Frame Period ≈ 12.375 ms
Frame Rate   ≈ 80.81 FPS
```
AXI4-Stream Mapping
Native Video	AXI4-Stream
native_data	TDATA
active_video	TVALID
First active pixel of frame	TUSER / SOF
Last active pixel of line	TLAST / EOL

The testbench acts as a behavioral native-video source, generating active_video, pixel data, HSYNC and VSYNC according to the configured 1280×720 timing.

The DUT uses its internal horizontal and vertical counters to generate the corresponding AXI4-Stream control signals.

Verification

The design was verified through RTL simulation in AMD/Xilinx Vivado.

The testbench generates:

100 MHz clock
Reset
Native video timing
24-bit pixel data
Active-video region
HSYNC / VSYNC
AXI4-Stream TREADY

The waveform verifies:

Correct active-video intervals
Pixel-data transfer
TVALID generation
TUSER at frame start
TLAST at the end of each active line
Continuous frame and line progression
Simulation Waveform

Repository Structure
``` text custom-native-video-to-axi4stream/
│
├── rtl/
│   └── native_video_to_axi4_stream.v
│
├── simulation/
│   └── tb_native_video_to_axi4_stream.v
│
├── docs/
│   └── native-video-to-axi4stream-waveform.png
│
└── README.md
```
Tools & Technologies

Verilog HDL · AMD/Xilinx Vivado · AXI4-Stream · RTL Design · RTL Simulation · Video Timing · Waveform Analysis

Learning Outcomes

This project provided practical experience in:
Custom RTL development for FPGA video interfaces
AXI4-Stream video protocol signaling
Native video timing and pixel-position tracking
SOF/EOL generation using TUSER and TLAST
Behavioral video-source modeling
RTL simulation and waveform-based functional verification

## Author
**Pranavi Pagidi**

FPGA Design & Verification Intern
HTIC, IIT Madras Research Park

GitHub: [pagidipranavidas](https://github.com/pagidipranavidas)

LinkedIn: [pagidi pranavi](https://www.linkedin.com/in/pagidi-pranavi-a00b77280)

