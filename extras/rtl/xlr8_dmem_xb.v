///////////////////////////////////////////////////////////////////
//=================================================================
//  Copyright (c) Alorium Technology 2017
//  ALL RIGHTS RESERVED
//  $Id:  $
//=================================================================
//
// File name:  : xlr8_dmem_xb.v
// Author      : Steve Phillips
// Description : Extended Data Memory XB
//
// This XB adds additional data memory to the XLR8. When adding this
// XB is can be configured for any size between 1KB and 64KB, in 1KB
// increments. 
//
// The address for the memory access is set by writing to the
// ADRREG. Each write will load 8 bits into the lower byte of the 16
// bit ADRREG, shifting the previous lower byte to the upper byte. So,
// to load a new address, one should perform two writes to the ADRREG,
// first the upper byte, then the lower.
//
// The each time the memory is accessed, the ADRREG is incremented by
// the value of the STRIDE reg, which defaults to a one. So, to
// read/write a block of memory, one mearly writes the starting
// address to the ADRREG and then performs a series of read/writes,
// where the address will be auto incremented after each access.
//
//=================================================================
///////////////////////////////////////////////////////////////////

module xlr8_dmem_xb 
  #(
    parameter XLR8DMEM_CTRL_ADDR = 0,
    parameter XLR8DMEM_ADRREG_ADDR = 0,
    parameter XLR8DMEM_STRIDE_ADDR = 0,
    parameter XLR8DMEM_DATA_ADDR = 0,
    parameter XLR8DMEM_WIDTH = 8,
    parameter XLR8DMEM_SIZE = 1024  // Size of dmem
    )
   (
    // Clock and Reset
    input              clk, // Clock
    input              rstn, // Reset
    input              clken, // Clock Enable
    // I/O 
    input [255:0]      gprf, // Direct RO access to Reg File
    input [5:0]        adr, // Reg Address
    input [7:0]        dbus_in, // Data Bus Input
    output logic [7:0] dbus_out, // Data Bus Output
    output logic       io_out_en, // IO Output Enable
    input              iore, // IO Reade Enable
    input              iowe, // IO Write Enable
    // DM
    input [7:0]        ramadr, // RAM Address
    input              ramre, // RAM Read Enable
    input              ramwe, // RAM Write Enable
    input              dm_sel          // DM Select
    );
   
   //======================================================================
   // Reg interfaces

   logic [XLR8DMEM_WIDTH-1:0] ctrl_reg;
   logic                      ctrl_sel;
   logic                      ctrl_we;
   logic                      ctrl_re;
   
   logic [15:0]               addr_reg; // hardcoded to be 16 bits
   logic                      addr_sel;
   logic                      addr_we;
   logic                      addr_re;

   logic [XLR8DMEM_WIDTH-1:0] stride_reg;
   logic                      stride_sel;
   logic                      stride_we;
   logic                      stride_re;
   
   logic                      data_sel;
   logic                      data_we;
   logic                      data_re;
   
   logic [15:0]               dmem_addr;
   logic [XLR8DMEM_WIDTH-1:0] dmem_din;
   logic [XLR8DMEM_WIDTH-1:0] dmem_dout;
   logic                      dmem_we;
   logic                      data_tc;
   
   //----------------------------------------------------------------------

   
   //======================================================================
   //  Control select
   //
   // For each register interface, do control select based on address

   assign ctrl_sel = (dm_sel && ramadr == XLR8DMEM_CTRL_ADDR);
   assign ctrl_we  = ctrl_sel && (ramwe);
   assign ctrl_re  = ctrl_sel && (ramre);
   
   assign addr_sel = (dm_sel && ramadr == XLR8DMEM_ADRREG_ADDR);
   assign addr_we  = addr_sel && (ramwe);
   assign addr_re  = addr_sel && (ramre);

   assign stride_sel = (dm_sel && ramadr == XLR8DMEM_STRIDE_ADDR);
   assign stride_we  = stride_sel && (ramwe);
   assign stride_re  = stride_sel && (ramre);

   assign data_sel = (dm_sel && ramadr == XLR8DMEM_DATA_ADDR);
   assign data_we  = data_sel && (ramwe);
   assign data_re  = data_sel && (ramre);


   // Mux the data and enable outputs
   assign dbus_out =  ({8{ctrl_sel}} & ctrl_reg)    |
                      ({8{data_sel}} & dmem_dout);

   assign io_out_en = ctrl_re ||
                      data_re;

   // End, Control Select
   //----------------------------------------------------------------------
   

   //======================================================================
   // Load write data from AVR core into registers
   //
   // For data written from the AVR core to the user module, you may
   // want to register the value here so that it is held for reference
   // until the net update in value

   // Load control register. NOT USED AT THE MOMENT
   always @(posedge clk or negedge rstn) begin
      if (!rstn)  begin
         ctrl_reg <= {8'h0};
      end else if (ctrl_we) begin
         ctrl_reg <= dbus_in[XLR8DMEM_WIDTH-1:0];
      end
   end // always @ (posedge clk or negedge rstn)

   // Load stride register
   always @(posedge clk or negedge rstn) begin
      if (!rstn)  begin
         stride_reg <= {8'h1};
      end else if (stride_we) begin
         stride_reg <= dbus_in[XLR8DMEM_WIDTH-1:0];
      end
   end // always @ (posedge clk or negedge rstn)

   // Load address register
   always @(posedge clk or negedge rstn) begin
      if (!rstn)  begin
         addr_reg <= {16'h0};
      end else if (addr_we) begin
         // Shift in the DBUS value to the lower byte of addr reg. Two 
         // of these address writes will be required to get a complete 
         // 16 address loaded.
         addr_reg <= {addr_reg[7:0], dbus_in[XLR8DMEM_WIDTH-1:0]};
      end 
      else if (data_we || data_re) begin
         addr_reg <= addr_reg + stride_reg; // FIXME: no overflow protection?
      end
   end // always @ (posedge clk or negedge rstn)
   
   // read data timing chain
   always @(posedge clk or negedge rstn) begin
      if (!rstn)  begin
         data_tc <= 1'b0;
      end else begin
         data_tc <= data_re;
      end
   end // always @ (posedge clk or negedge rstn)


   // End, Load write data
   //----------------------------------------------------------------------
   
   // Logic for dmem I/O
   //   When addr changing, get a jump start on new address
   always_comb dmem_addr = addr_reg;
   // FIXME: This may be needed if we have to revert to a memory with a latched output
   //   always_comb dmem_addr = addr_we ? {addr_reg[7:0], dbus_in[XLR8DMEM_WIDTH-1:0]} :
   //                                     data_re ? addr_reg + 1 :
   //                                               addr_reg;
   always_comb dmem_din     = dbus_in[XLR8DMEM_WIDTH-1:0];
   always_comb dmem_we      = data_we;
   
   
   //======================================================================
   // Instantiate d_mem module
   //

`ifdef D_MEM_SIM_MODEL
   
   // just model the ram so we don't have to worry about technology specific models
   reg [15:0]  addr_tmp_d;
   reg [7:0]   mem_data [XLR8DMEM_SIZE-1:0];
   always @(posedge clk) begin
      addr_tmp_d <= addr_reg;
      if (dmem_we) mem_data[addr_reg] <= dmem_din;
   end
   assign dmem_dout = mem_data[addr_tmp_d];

`else
   
   xlr8_ram_1p   // module type
     #(
       .XLR8DMEM_SIZE(XLR8DMEM_SIZE)
       )
   d_mem_inst    // instance name
     (
      .clock   (clk),        
      .address (dmem_addr),
      .data    (dmem_din),
      .q       (dmem_dout),
      .wren    (dmem_we)
      );

`endif
   
   //----------------------------------------------------------------------
   
endmodule // xlr8_dmem_xb

