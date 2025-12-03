//5_3_B
module MCPU_RAMControllertb2();

parameter WORD_SIZE=13;
parameter ADDR_WIDTH=4;
parameter RAM_SIZE=1<<ADDR_WIDTH; //this is the size of seats 2^8=256


//to enable and disable
reg we;
reg re;

//registers to hold values
reg [WORD_SIZE-1:0] datawr;
reg [ADDR_WIDTH-1:0] addr;
reg [WORD_SIZE-1:0] instraddr;

wire [WORD_SIZE-1:0] datard;
wire [WORD_SIZE-1:0] instrrd;

//here we are holding the check values
reg [WORD_SIZE-1:0] check_mem[RAM_SIZE-1:0];


MCPU_RAMController #(.WORD_SIZE(WORD_SIZE), .ADDR_WIDTH(ADDR_WIDTH)) raminst (we,datawr,re,addr,datard,instraddr,instrrd);

//fill the memory with random values
integer i;
reg isCorrect;


initial begin

    //initial signals
    we=0;
    re=0;
    datawr=0;
    addr=0;


    //A erwtima

    //fill values here 5281
    we=1;
    for(i=0;i<RAM_SIZE;i=i+1) begin
        datawr = 5281;
        instraddr=i;
        //keep a copy to array
        check_mem[i] = datawr;
        addr = i;
        #1;
    end
    we=0;
    re=1;
    //check if all correct with read function
    for(i=0;i<RAM_SIZE;i=i+1) begin
        addr = i;
        instraddr=i;
        #1;
        if (datard==check_mem[i] && instrrd==check_mem[i]) isCorrect=1;
        else isCorrect=0;
    end
    re=0;
    isCorrect=0;


    //fill values here 5386
    we=1;
    for(i=0;i<RAM_SIZE;i=i+1) begin
        datawr = 5386;
        instraddr=i;
        //keep a copy to array
        check_mem[i] = datawr;
        addr = i;
        #1;
    end
    we=0;
    re=1;
    //check if all correct with read function
    for(i=0;i<RAM_SIZE;i=i+1) begin
        addr = i;
        instraddr=i;
        #1;
        if (datard==check_mem[i] && instrrd==check_mem[i]) isCorrect=1;
        else isCorrect=0;
    end
    re=0;
end
endmodule
