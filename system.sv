`include "config.h"
import typepkg::*;

module system (
	// Clock and reset
	input logic clk, n_reset_in,
	output logic n_reset, dbg,
	// GPIO
	inout wire [`DATA_N - 1:0] io[2],
	output dataLogic iodir[2],
	// SPI
	input logic cs, miso,
	output logic mosi, sck
);

// Reset signal reformation
always_ff @(posedge clk, negedge n_reset_in)
	if (~n_reset_in)
		n_reset <= 1'b0;
	else
		n_reset <= 1'b1;
sys_if sys (.*);

// Interconnections and buses
wire rdy;
logic we;
wire [`ADDR_N - 1 : 0] addr;
wire [`DATA_N - 1 : 0] data;
sysbus_if sysbus (.*);

cpu cpu0 (.*);

peripherals periph0 (.*);

logic rom0sel;
assign rom0sel = sysbus.addr >= `BOOTROM_BASE;
dataLogic rom0q;
assign sysbus.rdy = rom0sel ? 1'b1 : 1'bz;
assign sysbus.data = (~sysbus.we & rom0sel) ? rom0q : {`DATA_N{1'bz}};
rom rom0 (
	.clock(~sys.clk), .aclr(~sys.n_reset),
	.address(sysbus.addr[7:0]), .q(rom0q));

logic ram0sel;
assign ram0sel = sysbus.addr < `RAM0_TOP;
dataLogic ram0q;
assign sysbus.rdy = ram0sel ? 1'b1 : 1'bz;
assign sysbus.data = (~sysbus.we & ram0sel) ? ram0q : {`DATA_N{1'bz}};
ram2k ram0 (
	.clock(~sys.clk), .aclr(~sys.n_reset),
	.address(sysbus.addr[10:0]), .data(sysbus.data),
	.wren(sysbus.we & ram0sel), .q(ram0q));

endmodule