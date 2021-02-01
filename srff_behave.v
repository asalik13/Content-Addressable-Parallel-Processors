module srff_behave(q, s,r,clk);

input s,r,clk;
output reg q;

always@(posedge clk)
begin

if(s == 1)
begin
q = 1;
end
else if(r == 1)
begin
q = 0;
end
else if(s == 0 & r == 0) 
begin 
q <= q;
end
end
endmodule
