function lab_2_2

  [d,e,f] = circuit(0.5,0.5,0.5);

  esw_e = 2*e*(1-e);
  esw_f = 2*f*(1-f);
  esw_d = 2*d*(1-d);
  printf("ESW_E: %f \n", esw_e);
  printf("ESW_F: %f \n", esw_f);
  printf("ESW_D: %f \n", esw_d);


endfunction



#our model
function [d,e,f] = circuit(a,b,c)

  e = sp2AND(a,b);
  f = spNOT(c);
  d = sp2AND(e,f);

endfunction

#SignalProbabilities functions
function s=sp2AND(input1sp, input2sp)
  #printf("AND Gate for input probabilities (%f %f):\n",input1sp,input2sp);
  s = input1sp*input2sp;
endfunction



function s=spNOT(input1sp)
  #printf("AND Gate for input probabilities (%f):\n",input1sp);
  s = (1-input1sp);
endfunction
