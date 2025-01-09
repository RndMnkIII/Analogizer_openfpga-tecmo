//
// User core top-level
//
// Instantiated by the real top-level: apf_top
//

`default_nettype none

module core_top (

//
// physical connections
//

///////////////////////////////////////////////////
// clock inputs 74.25mhz. not phase aligned, so treat these domains as asynchronous

input   wire            clk_74a, // mainclk1
input   wire            clk_74b, // mainclk1

///////////////////////////////////////////////////
// cartridge interface
// switches between 3.3v and 5v mechanically
// output enable for multibit translators controlled by pic32

// GBA AD[15:8]
inout   wire    [7:0]   cart_tran_bank2,
output  wire            cart_tran_bank2_dir,

// GBA AD[7:0]
inout   wire    [7:0]   cart_tran_bank3,
output  wire            cart_tran_bank3_dir,

// GBA A[23:16]
inout   wire    [7:0]   cart_tran_bank1,
output  wire            cart_tran_bank1_dir,

// GBA [7] PHI#
// GBA [6] WR#
// GBA [5] RD#
// GBA [4] CS1#/CS#
//     [3:0] unwired
inout   wire    [7:4]   cart_tran_bank0,
output  wire            cart_tran_bank0_dir,

// GBA CS2#/RES#
inout   wire            cart_tran_pin30,
output  wire            cart_tran_pin30_dir,
// when GBC cart is inserted, this signal when low or weak will pull GBC /RES low with a special circuit
// the goal is that when unconfigured, the FPGA weak pullups won't interfere.
// thus, if GBC cart is inserted, FPGA must drive this high in order to let the level translators
// and general IO drive this pin.
output  wire            cart_pin30_pwroff_reset,

// GBA IRQ/DRQ
inout   wire            cart_tran_pin31,
output  wire            cart_tran_pin31_dir,

// infrared
input   wire            port_ir_rx,
output  wire            port_ir_tx,
output  wire            port_ir_rx_disable,

// GBA link port
inout   wire            port_tran_si,
output  wire            port_tran_si_dir,
inout   wire            port_tran_so,
output  wire            port_tran_so_dir,
inout   wire            port_tran_sck,
output  wire            port_tran_sck_dir,
inout   wire            port_tran_sd,
output  wire            port_tran_sd_dir,

///////////////////////////////////////////////////
// cellular psram 0 and 1, two chips (64mbit x2 dual die per chip)

output  wire    [21:16] cram0_a,
inout   wire    [15:0]  cram0_dq,
input   wire            cram0_wait,
output  wire            cram0_clk,
output  wire            cram0_adv_n,
output  wire            cram0_cre,
output  wire            cram0_ce0_n,
output  wire            cram0_ce1_n,
output  wire            cram0_oe_n,
output  wire            cram0_we_n,
output  wire            cram0_ub_n,
output  wire            cram0_lb_n,

output  wire    [21:16] cram1_a,
inout   wire    [15:0]  cram1_dq,
input   wire            cram1_wait,
output  wire            cram1_clk,
output  wire            cram1_adv_n,
output  wire            cram1_cre,
output  wire            cram1_ce0_n,
output  wire            cram1_ce1_n,
output  wire            cram1_oe_n,
output  wire            cram1_we_n,
output  wire            cram1_ub_n,
output  wire            cram1_lb_n,

///////////////////////////////////////////////////
// sdram, 512mbit 16bit

output  wire    [12:0]  dram_a,
output  wire    [1:0]   dram_ba,
inout   wire    [15:0]  dram_dq,
output  wire    [1:0]   dram_dqm,
output  wire            dram_clk,
output  wire            dram_cke,
output  wire            dram_ras_n,
output  wire            dram_cas_n,
output  wire            dram_we_n,

///////////////////////////////////////////////////
// sram, 1mbit 16bit

output  wire    [16:0]  sram_a,
inout   wire    [15:0]  sram_dq,
output  wire            sram_oe_n,
output  wire            sram_we_n,
output  wire            sram_ub_n,
output  wire            sram_lb_n,

///////////////////////////////////////////////////
// vblank driven by dock for sync in a certain mode

input   wire            vblank,

///////////////////////////////////////////////////
// i/o to 6515D breakout usb uart

output  wire            dbg_tx,
input   wire            dbg_rx,

///////////////////////////////////////////////////
// i/o pads near jtag connector user can solder to

output  wire            user1,
input   wire            user2,

///////////////////////////////////////////////////
// RFU internal i2c bus

inout   wire            aux_sda,
output  wire            aux_scl,

///////////////////////////////////////////////////
// RFU, do not use
output  wire            vpll_feed,


//
// logical connections
//

///////////////////////////////////////////////////
// video, audio output to scaler
output  wire    [23:0]  video_rgb,
output  wire            video_rgb_clock,
output  wire            video_rgb_clock_90,
output  wire            video_de,
output  wire            video_skip,
output  wire            video_vs,
output  wire            video_hs,

output  wire            audio_mclk,
input   wire            audio_adc,
output  wire            audio_dac,
output  wire            audio_lrck,

///////////////////////////////////////////////////
// bridge bus connection
// synchronous to clk_74a
output  wire            bridge_endian_little,
input   wire    [31:0]  bridge_addr,
input   wire            bridge_rd,
output  reg     [31:0]  bridge_rd_data,
input   wire            bridge_wr,
input   wire    [31:0]  bridge_wr_data,

///////////////////////////////////////////////////
// controller data
//
// key bitmap:
//   [0]    dpad_up
//   [1]    dpad_down
//   [2]    dpad_left
//   [3]    dpad_right
//   [4]    face_a
//   [5]    face_b
//   [6]    face_x
//   [7]    face_y
//   [8]    trig_l1
//   [9]    trig_r1
//   [10]   trig_l2
//   [11]   trig_r2
//   [12]   trig_l3
//   [13]   trig_r3
//   [14]   face_select
//   [15]   face_start
// joy values - unsigned
//   [ 7: 0] lstick_x
//   [15: 8] lstick_y
//   [23:16] rstick_x
//   [31:24] rstick_y
// trigger values - unsigned
//   [ 7: 0] ltrig
//   [15: 8] rtrig
//
input   wire    [15:0]  cont1_key,
input   wire    [15:0]  cont2_key,
input   wire    [15:0]  cont3_key,
input   wire    [15:0]  cont4_key,
input   wire    [31:0]  cont1_joy,
input   wire    [31:0]  cont2_joy,
input   wire    [31:0]  cont3_joy,
input   wire    [31:0]  cont4_joy,
input   wire    [15:0]  cont1_trig,
input   wire    [15:0]  cont2_trig,
input   wire    [15:0]  cont3_trig,
input   wire    [15:0]  cont4_trig

);

// not using the IR port, so turn off both the LED, and
// disable the receive circuit to save power
assign port_ir_tx = 0;
assign port_ir_rx_disable = 1;

// bridge endianness
assign bridge_endian_little = 1;

// cart is unused, so set all level translators accordingly
// directions are 0:IN, 1:OUT
// assign cart_tran_bank3 = 8'hzz;
// assign cart_tran_bank3_dir = 1'b0;
// assign cart_tran_bank2 = 8'hzz;
// assign cart_tran_bank2_dir = 1'b0;
// assign cart_tran_bank1 = 8'hzz;
// assign cart_tran_bank1_dir = 1'b0;
// assign cart_tran_bank0 = 4'hf;
// assign cart_tran_bank0_dir = 1'b1;
// assign cart_tran_pin30 = 1'b0;      // reset or cs2, we let the hw control it by itself
// assign cart_tran_pin30_dir = 1'bz;
// assign cart_pin30_pwroff_reset = 1'b0;  // hardware can control this
// assign cart_tran_pin31 = 1'bz;      // input
// assign cart_tran_pin31_dir = 1'b0;  // input

// link port is input only
assign port_tran_so = 1'bz;
assign port_tran_so_dir = 1'b0;     // SO is output only
assign port_tran_si = 1'bz;
assign port_tran_si_dir = 1'b0;     // SI is input only
assign port_tran_sck = 1'bz;
assign port_tran_sck_dir = 1'b0;    // clock direction can change
assign port_tran_sd = 1'bz;
assign port_tran_sd_dir = 1'b0;     // SD is input and not used

// tie off the rest of the pins we are not using
assign cram0_a = 'h0;
assign cram0_dq = {16{1'bZ}};
assign cram0_clk = 0;
assign cram0_adv_n = 1;
assign cram0_cre = 0;
assign cram0_ce0_n = 1;
assign cram0_ce1_n = 1;
assign cram0_oe_n = 1;
assign cram0_we_n = 1;
assign cram0_ub_n = 1;
assign cram0_lb_n = 1;

assign cram1_a = 'h0;
assign cram1_dq = {16{1'bZ}};
assign cram1_clk = 0;
assign cram1_adv_n = 1;
assign cram1_cre = 0;
assign cram1_ce0_n = 1;
assign cram1_ce1_n = 1;
assign cram1_oe_n = 1;
assign cram1_we_n = 1;
assign cram1_ub_n = 1;
assign cram1_lb_n = 1;

assign sram_a = 'h0;
assign sram_dq = {16{1'bZ}};
assign sram_oe_n  = 1;
assign sram_we_n  = 1;
assign sram_ub_n  = 1;
assign sram_lb_n  = 1;

assign dbg_tx = 1'bZ;
assign user1 = 1'bZ;
assign aux_scl = 1'bZ;
assign vpll_feed = 1'bZ;

// for bridge write data, we just broadcast it to all bus devices
// for bridge read data, we have to mux it
// add your own devices here
always @(*) begin
    casex(bridge_addr)
    default: begin
        bridge_rd_data <= 0;
    end
    32'h10xxxxxx: begin
        // example
        // bridge_rd_data <= example_device_data;
        bridge_rd_data <= 0;
    end
    32'hF7000000: begin 
        bridge_rd_data <= {18'h0,analogizer_settings};
      end
    32'hF8xxxxxx: begin
        bridge_rd_data <= cmd_bridge_rd_data;
    end
    endcase
end


//
// host/target command handler
//
    wire            reset_n;                // driven by host commands, can be used as core-wide reset
    wire    [31:0]  cmd_bridge_rd_data;

// bridge host commands
// synchronous to clk_74a
    wire            status_boot_done = pll_core_locked;
    wire            status_setup_done = pll_core_locked; // rising edge triggers a target command
    wire            status_running = reset_n; // we are running as soon as reset_n goes high

    wire            dataslot_requestread;
    wire    [15:0]  dataslot_requestread_id;
    wire            dataslot_requestread_ack = 1;
    wire            dataslot_requestread_ok = 1;

    wire            dataslot_requestwrite;
    wire    [15:0]  dataslot_requestwrite_id;
    wire            dataslot_requestwrite_ack = 1;
    wire            dataslot_requestwrite_ok = 1;

    wire            dataslot_allcomplete;

    wire            savestate_supported;
    wire    [31:0]  savestate_addr;
    wire    [31:0]  savestate_size;
    wire    [31:0]  savestate_maxloadsize;

    wire            savestate_start;
    wire            savestate_start_ack;
    wire            savestate_start_busy;
    wire            savestate_start_ok;
    wire            savestate_start_err;

    wire            savestate_load;
    wire            savestate_load_ack;
    wire            savestate_load_busy;
    wire            savestate_load_ok;
    wire            savestate_load_err;

    wire            osnotify_inmenu;

// bridge target commands
// synchronous to clk_74a


// bridge data slot access

    wire    [9:0]   datatable_addr;
    wire            datatable_wren;
    wire    [31:0]  datatable_data;
    wire    [31:0]  datatable_q;

core_bridge_cmd icb (

    .clk                ( clk_74a ),
    .reset_n            ( reset_n ),

    .bridge_endian_little   ( bridge_endian_little ),
    .bridge_addr            ( bridge_addr ),
    .bridge_rd              ( bridge_rd ),
    .bridge_rd_data         ( cmd_bridge_rd_data ),
    .bridge_wr              ( bridge_wr ),
    .bridge_wr_data         ( bridge_wr_data ),

    .status_boot_done       ( status_boot_done ),
    .status_setup_done      ( status_setup_done ),
    .status_running         ( status_running ),

    .dataslot_requestread       ( dataslot_requestread ),
    .dataslot_requestread_id    ( dataslot_requestread_id ),
    .dataslot_requestread_ack   ( dataslot_requestread_ack ),
    .dataslot_requestread_ok    ( dataslot_requestread_ok ),

    .dataslot_requestwrite      ( dataslot_requestwrite ),
    .dataslot_requestwrite_id   ( dataslot_requestwrite_id ),
    .dataslot_requestwrite_ack  ( dataslot_requestwrite_ack ),
    .dataslot_requestwrite_ok   ( dataslot_requestwrite_ok ),

    .dataslot_allcomplete   ( dataslot_allcomplete ),

    .savestate_supported    ( savestate_supported ),
    .savestate_addr         ( savestate_addr ),
    .savestate_size         ( savestate_size ),
    .savestate_maxloadsize  ( savestate_maxloadsize ),

    .savestate_start        ( savestate_start ),
    .savestate_start_ack    ( savestate_start_ack ),
    .savestate_start_busy   ( savestate_start_busy ),
    .savestate_start_ok     ( savestate_start_ok ),
    .savestate_start_err    ( savestate_start_err ),

    .savestate_load         ( savestate_load ),
    .savestate_load_ack     ( savestate_load_ack ),
    .savestate_load_busy    ( savestate_load_busy ),
    .savestate_load_ok      ( savestate_load_ok ),
    .savestate_load_err     ( savestate_load_err ),

    .osnotify_inmenu        ( osnotify_inmenu ),

    .datatable_addr         ( datatable_addr ),
    .datatable_wren         ( datatable_wren ),
    .datatable_data         ( datatable_data ),
    .datatable_q            ( datatable_q )

);

wire sys_clock, cpu_clock;
wire cpu_reset;
wire pll_core_locked;

  /*[ANALOGIZER_HOOK_BEGIN]*/
  //Pocket Menu settings
  // reg [31:0] analogizer_settings = 0;
  // wire [31:0] analogizer_settings_s;
  //reg [13:0] analogizer_settings = 0;
  wire [13:0] analogizer_settings;
  wire [13:0] analogizer_settings_s;


  wire [15:0] cont1_key_s;
  wire [15:0] cont2_key_s;

  synch_3 #(
      .WIDTH(16)
  ) cont1_s (
      cont1_key,
      cont1_key_s,
      sys_clock
  );

  synch_3 #(
      .WIDTH(16)
  ) cont2_s (
      cont2_key,
      cont2_key_s,
      sys_clock
  );
  synch_3 #(.WIDTH(14)) sync_analogizer(analogizer_settings, analogizer_settings_s, sys_clock);

  always @(*) begin
    snac_game_cont_type   = analogizer_settings_s[4:0];
    snac_cont_assignment  = analogizer_settings_s[9:6];
    analogizer_video_type = analogizer_settings_s[13:10];
  end
//*** Analogizer Interface V1.1 ***
reg analogizer_ena;
reg [3:0] analogizer_video_type;
reg [4:0] snac_game_cont_type /* synthesis keep */;
reg [3:0] snac_cont_assignment /* synthesis keep */;
  
wire [31:0] p1_joy, p2_joy; //analog sticks data, from Analogizer adapter module
//use PSX Dual Shock style left analog stick as directional pad
wire is_analog_input = (snac_game_cont_type == 5'h13);

//! Player 1 ---------------------------------------------------------------------------
reg p1_up, p1_down, p1_left, p1_right;
wire p1_up_analog, p1_down_analog, p1_left_analog, p1_right_analog;
//using left analog joypad
assign p1_up_analog    = (p1_joy[15:8] < 8'h40) ? 1'b1 : 1'b0; //analog range UP 0x00 Idle 0x7F DOWN 0xFF, DEADZONE +- 0x15
assign p1_down_analog  = (p1_joy[15:8] > 8'hC0) ? 1'b1 : 1'b0; 
assign p1_left_analog  = (p1_joy[7:0]  < 8'h40) ? 1'b1 : 1'b0; //analog range LEFT 0x00 Idle 0x7F RIGHT 0xFF, DEADZONE +- 0x15
assign p1_right_analog = (p1_joy[7:0]  > 8'hC0) ? 1'b1 : 1'b0;

always @(posedge sys_clock) begin
    p1_up    <= (is_analog_input) ? p1_up_analog    : p1_btn[0];
    p1_down  <= (is_analog_input) ? p1_down_analog  : p1_btn[1];
    p1_left  <= (is_analog_input) ? p1_left_analog  : p1_btn[2];
    p1_right <= (is_analog_input) ? p1_right_analog : p1_btn[3];
end
//! Player 2 ---------------------------------------------------------------------------
reg p2_up, p2_down, p2_left, p2_right;
wire p2_up_analog, p2_down_analog, p2_left_analog, p2_right_analog;
//using left analog joypad
assign p2_up_analog    = (p2_joy[15:8] < 8'h40) ? 1'b1 : 1'b0; //analog range UP 0x00 Idle 0x7F DOWN 0xFF, DEADZONE +- 0x15
assign p2_down_analog  = (p2_joy[15:8] > 8'hC0) ? 1'b1 : 1'b0; 
assign p2_left_analog  = (p2_joy[7:0]  < 8'h40) ? 1'b1 : 1'b0; //analog range LEFT 0x00 Idle 0x7F RIGHT 0xFF, DEADZONE +- 0x15
assign p2_right_analog = (p2_joy[7:0]  > 8'hC0) ? 1'b1 : 1'b0;

always @(posedge sys_clock) begin
    p2_up    <= (is_analog_input) ? p2_up_analog    : p2_btn[0];
    p2_down  <= (is_analog_input) ? p2_down_analog  : p2_btn[1];
    p2_left  <= (is_analog_input) ? p2_left_analog  : p2_btn[2];
    p2_right <= (is_analog_input) ? p2_right_analog : p2_btn[3];
end

  //switch between Analogizer SNAC and Pocket Controls for P1-P4 (P3,P4 when uses PCEngine Multitap)
  wire [15:0] p1_btn, p2_btn;
  reg [15:0] p1_controls, p2_controls;

  always @(posedge sys_clock) begin
    if(snac_game_cont_type == 5'h0) begin //SNAC is disabled
                  p1_controls <= cont1_key_s;
                  p2_controls <= cont2_key_s;
    end
    else begin
      case(snac_cont_assignment)
      4'h0:    begin 
                  p1_controls <= {p1_btn[15:4],p1_right,p1_left,p1_down,p1_up};
                  p2_controls <= cont2_key_s;
                end
      4'h1:    begin 
                  p1_controls <= cont1_key_s;
                  p2_controls <= {p1_btn[15:4],p1_right,p1_left,p1_down,p1_up};
                end
      4'h2:    begin
                  p1_controls <= {p1_btn[15:4],p1_right,p1_left,p1_down,p1_up};
                  p2_controls <= {p2_btn[15:4],p2_right,p2_left,p2_down,p2_up};
                end
      4'h3:    begin
                  p1_controls <= {p2_btn[15:4],p2_right,p2_left,p2_down,p2_up};
                  p2_controls <= {p1_btn[15:4],p1_right,p1_left,p1_down,p1_up};
                end
      default: begin
                  p1_controls <= cont1_key_s;
                  p2_controls <= cont2_key_s;
                end
      endcase
    end
  end

// SET PAL and NTSC TIMING and pass through status bits. ** YC must be enabled in the qsf file **
wire [39:0] CHROMA_PHASE_INC;
wire PALFLAG;

// adjusted for 96MHz video clock
localparam [39:0] NTSC_PHASE_INC = 40'd40997409892; // ((NTSC_REF * 2^40) / CLK_VIDEO_NTSC)
localparam [39:0] PAL_PHASE_INC  = 40'd50779326758;  // ((PAL_REF * 2^40) / CLK_VIDEO_PAL)

// Send Parameters to Y/C Module
assign CHROMA_PHASE_INC = (analogizer_video_type == 4'h4) || (analogizer_video_type == 4'hC) ? PAL_PHASE_INC : NTSC_PHASE_INC; 
assign PALFLAG = (analogizer_video_type == 4'h4) || (analogizer_video_type == 4'hC); 

reg [2:0] fx /* synthesis preserve */;
always @(posedge sys_clock) begin
    case (analogizer_video_type)
        4'd5, 4'd13:    fx <= 3'd0; //SC  0%
        4'd6, 4'd14:    fx <= 3'd2; //SC  50%
        4'd7, 4'd15:    fx <= 3'd4; //hq2x
        default:        fx <= 3'd0;
    endcase
end

wire ANALOGIZER_CSYNC = ~^{HS, VS};
wire ANALOGIZER_DE = ~(HBL || VBL);

//video fix
wire hs_fix,vs_fix;
sync_fix sync_v(sys_clock, video_hs_core2, hs_fix);
sync_fix sync_h(sys_clock, video_vs_core2, vs_fix);

reg [23:0] RGB_fix;
reg CE,HS,VS,HBL,VBL;
always @(posedge sys_clock) begin
	reg old_ce;
	old_ce <= video_ce_core2;
	CE <= 0;
	if(~old_ce & video_ce_core2) begin
		CE <= 1;
		HS <= hs_fix;
		if(~HS & hs_fix) VS <= vs_fix;

		RGB_fix <= video_rgb_core2;
		HBL <= video_hb_core2;
		if(HBL & ~video_hb_core2) VBL <= video_vb_core2;
	end
end

assign video_rgb = (analogizer_video_type[3]) ? 24'h000000: video_rgb_core;

//96_000_000
openFPGA_Pocket_Analogizer #(.MASTER_CLK_FREQ(96_000_000), .LINE_LENGTH(256)) analogizer (
	.i_clk(sys_clock),
	.i_rst(~pll_core_locked), //i_rst is active high
	.i_ena(1'b1),
	//Video interface
   .video_clk(sys_clock),
	.analog_video_type(analogizer_video_type),
   .R(RGB_fix[23:16]),
	.G(RGB_fix[15:8] ),
	.B(RGB_fix[7:0]  ),
   .Hblank(HBL),
   .Vblank(VBL),
   .BLANKn(ANALOGIZER_DE),
   .Hsync(HS),
	.Vsync(VS),
   .Csync(ANALOGIZER_CSYNC), //composite SYNC on HSync.
   //Video Y/C Encoder interface
   .CHROMA_PHASE_INC(CHROMA_PHASE_INC),
   .PALFLAG(PALFLAG),
   //Video SVGA Scandoubler interface
   .ce_pix(video_ce_core2),
   .scandoubler(1'b1), //logic for disable/enable the scandoubler
	.fx(fx), //0 disable, 1 scanlines 25%, 2 scanlines 50%, 3 scanlines 75%, 4 hq2x
	//SNAC interface
	.conf_AB((snac_game_cont_type >= 5'd16)),              //0 conf. A(default), 1 conf. B (see graph above)
	.game_cont_type(snac_game_cont_type), //0-15 Conf. A, 16-31 Conf. B
	.p1_btn_state(p1_btn),
   .p1_joy_state(p1_joy),
	.p2_btn_state(p2_btn),  
   .p2_joy_state(p2_joy),
   .p3_btn_state(),
	.p4_btn_state(),  
   //  .i_VIB_SW1(p1_btn[5:4]), .i_VIB_DAT1(8'hb0), .i_VIB_SW2(p2_btn[5:4]), .i_VIB_DAT2(8'hb0),

	//Pocket Analogizer IO interface to the Pocket cartridge port
	.cart_tran_bank2(cart_tran_bank2),
	.cart_tran_bank2_dir(cart_tran_bank2_dir),
	.cart_tran_bank3(cart_tran_bank3),
	.cart_tran_bank3_dir(cart_tran_bank3_dir),
	.cart_tran_bank1(cart_tran_bank1),
	.cart_tran_bank1_dir(cart_tran_bank1_dir),
	.cart_tran_bank0(cart_tran_bank0),
	.cart_tran_bank0_dir(cart_tran_bank0_dir),
	.cart_tran_pin30(cart_tran_pin30),
	.cart_tran_pin30_dir(cart_tran_pin30_dir),
	.cart_pin30_pwroff_reset(cart_pin30_pwroff_reset),
	.cart_tran_pin31(cart_tran_pin31),
	.cart_tran_pin31_dir(cart_tran_pin31_dir),
	//debug {PSX_ATT1,PSX_CLK,PSX_CMD,PSX_DAT}
   //.DBG_TX(),
	.o_stb()
);
/*[ANALOGIZER_HOOK_END]*/




mf_pllbase mp1 (
    .refclk         ( clk_74a ),
    .rst            ( 0 ),

    .outclk_0       ( sys_clock ), //96
    .outclk_1       ( cpu_clock ), //12
    .outclk_2       ( video_rgb_clock ), //6
    .outclk_3       ( video_rgb_clock_90 ), //6 90 degree phase shift

    .locked         ( pll_core_locked )
);

reset_ctrl cpu_reset_ctrl (
  .clk(cpu_clock),
  .rst_i(~reset_n),
  .rst_o(cpu_reset)
);

wire        dram_oe_n;
wire [15:0] dram_din;
assign dram_clk = sys_clock;
assign dram_dq = dram_oe_n ? dram_din : 16'bZ;

wire [15:0] audio;

wire [23:0] video_rgb_core;
wire video_de_core;
wire video_hs_core, video_vs_core;
wire video_hb_core, video_vb_core;

Tecmo tecmo (
  .reset(~pll_core_locked),
  .cpuReset(cpu_reset),

  .clock(sys_clock),
  .bridgeClock(clk_74a),
  .cpuClock(cpu_clock),
  .videoClock(video_rgb_clock),

  .bridge_wr(bridge_wr),
  .bridge_addr(bridge_addr),
  .bridge_dout(bridge_wr_data),
  .bridge_pause(osnotify_inmenu),
  .bridge_done(dataslot_allcomplete),
  //[Analogizer Hook]
  .bridge_1_io_options_Analogizer(analogizer_settings),

  .player_0_up(p1_controls[0]),
  .player_0_down(p1_controls[1]),
  .player_0_left(p1_controls[2]),
  .player_0_right(p1_controls[3]),
  .player_0_buttons(p1_controls[7:4]),
  .player_0_start(p1_controls[15]),
  .player_0_coin(p1_controls[14]),

  .player_1_up(p2_controls[0]),
  .player_1_down(p2_controls[1]),
  .player_1_left(p2_controls[2]),
  .player_1_right(p2_controls[3]),
  .player_1_buttons(p2_controls[7:4]),
  .player_1_start(p2_controls[15]),
  .player_1_coin(p2_controls[14]),

  .sdram_cke(dram_cke),
  .sdram_ras_n(dram_ras_n),
  .sdram_cas_n(dram_cas_n),
  .sdram_we_n(dram_we_n),
  .sdram_oe_n(dram_oe_n),
  .sdram_bank(dram_ba),
  .sdram_addr(dram_a),
  .sdram_din(dram_din),
  .sdram_dout(dram_dq),

  //.video_clockEnable(video_ce),
  .video_hSync(video_hs),
  .video_vSync(video_vs),
  .video_hBlank(video_hb_core),
  .video_vBlank(video_vb_core),
  .video_displayEnable(video_de),

  .audio(audio),

  .rgb(video_rgb_core), //24bits
);

//calculate video_ce_core
reg [23:0] video_rgb_core2;
reg video_de_core2;
reg video_hs_core2, video_vs_core2;
reg video_hb_core2, video_vb_core2, video_ce_core2; //needed by Analogizer
always @(posedge sys_clock) begin
    reg vid_clk_r;
    vid_clk_r <= video_rgb_clock;
    video_rgb_core2 <= video_rgb_core;
    video_de_core2 <= video_de;
    video_hs_core2 <= video_hs;
    video_vs_core2 <= video_vs;
    video_hb_core2 <= video_hb_core;
    video_vb_core2 <= video_vb_core;
    video_ce_core2 <= 1'b0;

    if(!video_rgb_clock && vid_clk_r) begin
        video_ce_core2 <= 1'b1;
    end
end

i2s i2s (
  .clk_74a(clk_74a),
  .left_audio(audio),
  .right_audio(audio),
  .audio_mclk(audio_mclk),
  .audio_dac(audio_dac),
  .audio_lrck(audio_lrck)
);

endmodule

module sync_fix
(
	input clk,
	
	input sync_in,
	output sync_out
);

assign sync_out = sync_in ^ pol;

reg pol;
always @(posedge clk) begin
	reg [31:0] cnt;
	reg s1,s2;

	s1 <= sync_in;
	s2 <= s1;
	cnt <= s2 ? (cnt - 1) : (cnt + 1);

	if(~s2 & s1) begin
		cnt <= 0;
		pol <= cnt[31];
	end
end
endmodule