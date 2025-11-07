function simulator()

  circuit_tb();
  calculate_esw();
  calculate_esw_5281();
  calculate_esw_5386();

endfunction

function [d,e,f] = circuit(a,b,c)

  #Where to save the signales
  #SignalsTable=[Input1_E1 , Input2_E1 , Input_E3 , E3_OUTPUT ,  E1_OUTPUT , E2_OUTPUT]
  SignalsTable=[a,b,c,0,0,0];

  #This is AND GATE
  E1.type='AND';
  E1.inputs=[1,2];
  E1.output=5;

  #THIS IS NOT GATE
  E2.type='NOT';
  E2.inputs=[3];
  E2.output=6;

  #THIS IS AND GATE
  E3.type='AND';
  E3.inputs=[5,6];
  E3.output=4;


  #store the elements to table
  ElementsTable=[E1,E2,E3];

  #process of E1
  SignalsTable = process(E1,SignalsTable);

  #process of E2
  SignalsTable = process(E2,SignalsTable);

  #process of E3
  SignalsTable = process(E3,SignalsTable);

  d = SignalsTable(4);
  e = SignalsTable(5);
  f = SignalsTable(6);


endfunction

function signalTable = process(element,SignalsTable)

  if (element.type == 'AND')
    SignalsTable(element.output) = sp2AND(SignalsTable(element.inputs(1)) , SignalsTable(element.inputs(2)));
  elseif(element.type == 'NOT')
    SignalsTable(element.output) = spNOT(SignalsTable(element.inputs(1)));
  endif


  signalTable = SignalsTable;

endfunction


#this if testbench
function circuit_tb()

  combinations = dec2bin(0:(2^3)-1) - '0';
  combinations

  for i=1:8

    a = combinations(i,1);
    b = combinations(i,2);
    c = combinations(i,3);

    d = circuit(a,b,c);
    d

    #test
    #printf("a b c d\n");
    #[a b c d]


    if(!checkIfCorrect(a,b,c,d))
      printf("UNEXPECTED OUTPUT \n");
      break;
    endif

  endfor

  printf("EVERYTHING WORKS PERFECT!\n");

endfunction


function stat = checkIfCorrect(a,b,c,d)

  %%  A  B  C | O
  %%  0  0  0 | 0
  %%  0  0  1 | 0
  %%  0  1  0 | 0
  %%  0  1  1 | 0
  %%  1  0  0 | 0
  %%  1  0  1 | 0
  %%  1  1  0 | 1
  %%  1  1  1 | 0



  if (  ((a==0) && (b==0) && (c==0) && (d==0))
        ||
        ((a==0) && (b==0) && (c==1) && (d==0))
        ||
        ((a==0) && (b==1) && (c==0) && (d==0))
        ||
        ((a==0) && (b==1) && (c==1) && (d==0))
        ||
        ((a==1) && (b==0) && (c==0) && (d==0))
        ||
        ((a==1) && (b==0) && (c==1) && (d==0))
        ||
        ((a==1) && (b==1) && (c==0) && (d==1))
        ||
        ((a==1) && (b==1) && (c==1) && (d==0))
    )
    stat = 1;
   else
    stat = 0;


  endif

endfunction

function calculate_esw()
  printf("---------- a=0.5 , b=0.5, c=0.5 ----------\n");
  [d,e,f] = circuit(0.5,0.5,0.5);

  esw_d = 2*d*(1-d);
  esw_e = 2*e*(1-e);
  esw_f = 2*f*(1-f);

  #print the switching activity
  printf("ESW_D: %f\n", esw_d);
  printf("ESW_E: %f\n", esw_e);
  printf("ESW_F: %f\n", esw_f);
endfunction


function calculate_esw_5281()

  printf("---------- a=0.5281 , b=0.5281, c=0.5281 ----------\n");
  [d,e,f] = circuit(0.5281,0.5281,0.5281);

  esw_d = 2*d*(1-d);
  esw_e = 2*e*(1-e);
  esw_f = 2*f*(1-f);

  #print the switching activity
  printf("ESW_D: %f\n", esw_d);
  printf("ESW_E: %f\n", esw_e);
  printf("ESW_F: %f\n", esw_f);

endfunction


function calculate_esw_5386()
  printf("---------- a=0.5386 , b=0.5386, c=0.5386 ----------\n")
  [d,e,f] = circuit(0.5386,0.5386,0.5386);


  esw_d = 2*d*(1-d);
  esw_e = 2*e*(1-e);
  esw_f = 2*f*(1-f);

  #print the switching activity
  printf("ESW_D: %f\n", esw_d);
  printf("ESW_E: %f\n", esw_e);
  printf("ESW_F: %f\n", esw_f);


endfunction


#SignalProbabilities functions
function s=sp2AND(input1sp, input2sp)
  s = input1sp*input2sp;
endfunction

function s=spNOT(input1sp)
  s = (1-input1sp);
endfunction
