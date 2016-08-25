`include "config.h"
import typepkg::*;

module alu (
	input wire [`DATA_N - 1:0] alu_in_a, alu_in_b,
	output dataLogic alu_out,
	input logic alu_cin, alu_cinclr,
	output logic alu_cout, alu_zero, alu_sign, alu_ovf,
	input ALUFunc alu_func
);

dataLogic a, b, out;
logic cin, cout;

assign alu_zero = out == 'h0;
assign alu_sign = alu_func == ALUBIT ? b[7] : out[`DATA_N - 1];

logic as, bs, rs;
assign as = a[`DATA_N - 1];
assign bs = b[`DATA_N - 1];
assign rs = out[`DATA_N - 1];
assign alu_ovf = alu_func == ALUBIT ? b[6] : ~(as ^ bs) && (as ^ rs);

always_comb
begin
	a = alu_in_a;
	b = alu_in_b;
	cin = ~alu_cinclr & alu_cin;
	out = 'h0;
	cout = cin;
	case (alu_func)
	ALUTXA:	out = a;
	ALUTXB:	out = b;
	ALUADD:	{cout, out} = a + b + {{`DATA_N - 1{1'b0}}, cin};
	ALUSUB:	begin
		b = ~b;
		{cout, out} = a + b + {{`DATA_N - 1{1'b0}}, ~cin};
		cout = ~cout;
	end
	ALUAND:	out = a & b;
	ALUORA:	out = a | b;
	ALUEOR:	out = a ^ b;
	ALUROL:	{cout, out} = {a, cout};
	ALUROR:	{out, cout} = {cout, a};
	ALUBIT:	out = a & b;
	endcase
	alu_out = out;
	alu_cout = cout;
end

endmodule