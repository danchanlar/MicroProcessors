function lab_2_1

  combinations = dec2bin(0:(2^3)-1) - '0'

    #default all ok
    s = 1;

    for i=1:8
      outputGate = circuit( combinations(i,1) , combinations(i,2) , combinations(i,3))
      if (!(checkIfCorrect( combinations(i,1) , combinations(i,2) , combinations(i,3), outputGate)))
        #not fit then wrong
        printf("NOT FOUND!\n")
        s = 0;
        break;
      endif
    endfor

    #print if all ok
    printf("CHECK MODEL IF CORRECT: %i\n",s);


endfunction

#our model
function [d,e,f] = circuit(a,b,c)

  e = sp2AND(a,b);
  f = spNOT(c);
  d = sp2AND(e,f);


endfunction

#to validate our model

function stat = checkIfCorrect(a,b,c,d)

  %%  A  B  C | D
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

#SignalProbabilities functions


function s=sp2AND(input1sp, input2sp)
  %printf("AND Gate for input probabilities (%f %f):\n",input1sp,input2sp);
  s = input1sp*input2sp;
endfunction

function s=spNOT(input1sp)
  %printf("AND Gate for input probabilities (%f):\n",input1sp);
  s = (1-input1sp);
endfunction
