`timescale 1ns/1ps

module tb_timing;

   reg clock_27           = 1'b0;
   reg btn1_n             = 1'b0; // Active low power up reset
   reg btn2_n             = 1'b0; // Output 6502 trace data on the gpio pins
   reg ps2_clk            = 1'b1;
   reg ps2_data           = 1'b1;

   reg tf_miso            = 1'b1;
   reg uart_rx            = 1'b1;

   wire ps2_mouse_clk;
   wire ps2_mouse_data;

   wire audiol                  ;
   wire audior                  ;
   wire tf_cs                   ;
   wire tf_sclk                 ;
   wire tf_mosi                 ;
   wire uart_tx                 ;
   wire [5:0] led               ;
   wire 	  tmds_clk_p        ;
   wire 	  tmds_clk_n        ;
   wire [2:0] tmds_d_p          ;
   wire [2:0] tmds_d_n          ;
   wire [13:0] gpio             ;
   wire [15:0] trace            ;
   wire 	   phi2             ;
   wire [1:0] O_psram_ck        ;
   wire [1:0] O_psram_ck_n      ;
   wire [1:0] IO_psram_rwds     ;
   wire [15:0] IO_psram_dq      ;
   wire [1:0]  O_psram_reset_n  ;
   wire [1:0]  O_psram_cs_n     ;

   GSR GSR(btn1_n);

   always begin
	  #18.5;
	  clock_27 <= !clock_27;
   end

   initial begin
	  // $sdf_annotate("../../impl/pnr/AtomFpga_TangNano9K.sdf", dut);
	  // $dumpvars;
	  btn1_n <= 1'b0;
	  @(negedge phi2);
	  @(negedge phi2);
	  @(negedge phi2);
	  @(negedge phi2);
	  @(negedge phi2);
	  btn1_n <= 1'b1;
	  #2000000;
	  $finish;
   end


   AtomFpga_TangNano9K dut
	 (
	  .clock_27       (clock_27       ),
      .btn1_n         (btn1_n         ),
      .btn2_n         (btn2_n         ),
      .ps2_clk        (ps2_clk        ),
      .ps2_data       (ps2_data       ),
      .ps2_mouse_clk  (ps2_mouse_clk  ),
      .ps2_mouse_data (ps2_mouse_data ),
      .tf_miso        (tf_miso        ),
      .tf_cs          (tf_cs          ),
      .tf_sclk        (tf_sclk        ),
      .tf_mosi        (tf_mosi        ),
      .uart_rx        (uart_rx        ),
      .uart_tx        (uart_tx        ),
      .led            (led            ),
      .tmds_clk_p     (tmds_clk_p     ),
      .tmds_clk_n     (tmds_clk_n     ),
      .tmds_d_p       (tmds_d_p       ),
      .tmds_d_n       (tmds_d_n       ),
      .gpio           (gpio           ),

      // Flash (not implemented)
      .flash_cs       (               ),
      .flash_ck       (               ),
      .flash_si       (               ),
      .flash_so       (1'b0           ),

      // PSRAM
      .O_psram_ck     (O_psram_ck     ),
      .O_psram_ck_n   (O_psram_ck_n   ),
      .IO_psram_rwds  (IO_psram_rwds  ),
      .IO_psram_dq    (IO_psram_dq    ),
      .O_psram_reset_n(O_psram_reset_n),
      .O_psram_cs_n   (O_psram_cs_n   )
      );

	s27kl0642
	  #(
		// 256KB is plenty (128K ROM + 128K RAM)
        .MemSize  (25'h3FFFF),
		// 64K x 16 bit ROM image in the current directory
        .mem_file_name ("../roms/InternalROM.hex")
        )
      ram
		(
		 .DQ7      (IO_psram_dq[7]),
		 .DQ6      (IO_psram_dq[6]),
		 .DQ5      (IO_psram_dq[5]),
		 .DQ4      (IO_psram_dq[4]),
		 .DQ3      (IO_psram_dq[3]),
		 .DQ2      (IO_psram_dq[2]),
		 .DQ1      (IO_psram_dq[1]),
		 .DQ0      (IO_psram_dq[0]),
         .RWDS     (IO_psram_rwds[0]),

         .CSNeg    (O_psram_cs_n[0]),
         .CK       (O_psram_ck[0]),
         .CKn      (O_psram_ck_n[0]),
         .RESETNeg (O_psram_reset_n[0])
		 );

   // Trace 6502 activity

   assign trace = {1'b1, gpio[11], 4'b1111, gpio[9:0]};
   assign phi2  = gpio[10];

   always @(negedge phi2) begin
      $display("trace: %x", trace);
   end

endmodule // tb_timing
