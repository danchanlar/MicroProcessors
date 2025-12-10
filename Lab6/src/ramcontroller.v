module MCPU_RAMController(we, datawr, re, addr, datard, instraddr, instrrd);
parameter WORD_SIZE=43;
parameter ADDR_WIDTH=8;
parameter RAM_SIZE=1<<ADDR_WIDTH; //this is the size of seats 2^8=256

input we, re; //this are signals for (write enable) (read enable)

input [WORD_SIZE-1:0] datawr; //this is data which are gonna be stored to memory

input [ADDR_WIDTH-1:0] addr;  //the address for reading or writing 
input [ADDR_WIDTH-1:0] instraddr; // instruction address this is the address of instructions

output [WORD_SIZE-1:0] datard;  //data which we are reading from memory (FOR DATA)
output [WORD_SIZE-1:0] instrrd;  // data which we are reading from memory (FOR INSTRUCTIONS)

reg [WORD_SIZE-1:0] mem[RAM_SIZE-1:0]; //this is register which holds the values 


reg [WORD_SIZE-1:0] datard; 
reg [WORD_SIZE-1:0] instrrd;

always @ (addr or we or re or datawr)
begin
  if(we)begin
    mem[addr]=datawr;
  end
  if(re) begin
    datard=mem[addr];
  end
end

//this is for reading instructions
always @ (instraddr)
begin
    instrrd=mem[instraddr];
end


endmodule

