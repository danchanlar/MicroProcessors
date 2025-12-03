//5_2_B
module MCPU_Alutb2();

parameter CMD_SIZE=2;
parameter WORD_SIZE=8;

reg [CMD_SIZE-1:0] opcode;
reg [WORD_SIZE-1:0] r1;
reg [WORD_SIZE-1:0] r2;
wire [WORD_SIZE-1:0] out;
wire OVERFLOW;

//add register here
reg [WORD_SIZE-1:0] correct;

reg isCorrect;

MCPU_Alu #(.CMD_SIZE(CMD_SIZE), .WORD_SIZE(WORD_SIZE)) aluinst (opcode, r1, r2, out, OVERFLOW);

// Testbench code goes here.
always begin
  //5281
  #4 r1=8'b00000101; //5
  #4 r1=8'b00000010; //2
  #4 r1=8'b00001000; //8
  #4 r1=8'b00000001; //1
end
always begin
  //5386
  #4 r2=8'b00000101; //5
  #4 r2=8'b00000011; //3
  #4 r2=8'b00001000; //8
  #4 r2=8'b00000110; //6

end


always #4 opcode = $random %4;

always @(*)  begin
  #2;
    case(opcode)
      2'b00: correct = r1&r2;
      2'b01: correct = r1|r2;
      2'b10: correct = r1^r2;//xor
      2'b11: correct = r1+r2;//add
    endcase
    
end
always @(out) begin
 if(out == correct)
      isCorrect =1;
    else
      isCorrect=0;
end

initial begin
  $display("@%0dns default is selected, opcode %b",$time,opcode);
end

endmodule