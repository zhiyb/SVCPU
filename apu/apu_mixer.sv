module apu_mixer (
	sys_if sys,
	input logic [3:0] pulse[2], triangle, noise,
	input logic [6:0] dmc,
	output logic [7:0] out
);

logic [6:0] pulse_out;

apu_rom_pulse romp (.aclr(~sys.n_reset), .clock(~sys.clk),
	.address(pulse[0] + pulse[1]), .q(pulse_out));

logic [7:0] tnd_out;

apu_rom_tnd romt (.aclr(~sys.n_reset), .clock(~sys.clk),
	.address(3 * triangle + 2 * noise + dmc), .q(tnd_out));

assign out = pulse_out + tnd_out;

endmodule