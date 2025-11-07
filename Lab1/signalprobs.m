%%%
%%%
%%% τρέχετε το πρόγραμμα ως:
%%% signalprobs(input1sp,input2sp)
%%%
%%% Παραδείγματα:
%%% >> signalprobs(0.5,0.5)
%%% AND Gate for input probabilities (0.500000 0.500000):
%%% ans =  0.25000
%%% OR Gate for input probabilities (0.500000 0.500000):
%%% ans =  0.75000
%%% XOR Gate for input probabilities (0.500000 0.500000):
%%% NAND Gate for input probabilities (0.500000 0.500000):
%%% NOR Gate for input probabilities (0.500000 0.500000):
%%%
%%%
%%% >> signalprobs(0,0)
%%% AND Gate for input probabilities (0.00000 0.00000):
%%% ans =  0
%%% OR Gate for input probabilities (0.00000 0.00000):
%%% ans =  0
%%% XOR Gate for input probabilities (0.00000 0.00000):
%%% NAND Gate for input probabilities (0.00000 0.00000):
%%% NOR Gate for input probabilities (0.00000 0.00000):
%%%
%%% >> signalprobs(1,1)
%%% AND Gate for input probabilities (1.00000 1.00000):
%%% ans =  1
%%% OR Gate for input probabilities (1.00000 1.00000):
%%% ans =  1
%%% XOR Gate for input probabilities (1.00000 1.00000):
%%% NAND Gate for input probabilities (1.00000 1.00000):
%%% NOR Gate for input probabilities (1.00000 1.00000):
%%%
%%%
%%%
%%% Οι συναρτήσεις που υπολογίζουν τα signal probabilities
%%% AND και OR πυλών δύο εισόδων έχουν ήδη υλοποιηθεί παρακάτω.
%%% Οι συναρτήσεις που υπολογίζουν τα signal probabilities
%%% XOR, NAND και NOR πυλών δύο εισόδων είναι ημιτελής.
%%% (α) Σας ζητείτε να συμπληρώσετε τις υπόλοιπες ημιτελής συναρτήσεις για τον υπολογισμό
%%% των signal probabilities XOR,NAND και NOR 2 εισόδων πυλών.
%%% (β) γράψτε συναρτήσεις για τον υπολογισμό των signal probabilities
%%% AND, OR, XOR, NAND, NOR πυλών 3 εισόδων
%%% (γ) γράψτε συναρτήσεις για τον υπολογισμό των signal probabilities
%%% AND, OR, XOR, NAND, NOR πυλών Ν εισόδων


function s=signalprobs(varargin)
  n = length(varargin)

  if n == 2
    s1 = sp2AND(varargin{:})
    s2 = sp2OR(varargin{:})
    s3 = sp2XOR(varargin{:})
    s4 = sp2NAND(varargin{:})
    s5 = sp2NOR(varargin{:})

    switchingActivity(s1, "AND");
    switchingActivity(s2, "OR");
    switchingActivity(s3, "XOR");
    switchingActivity(s4, "NAND");
    switchingActivity(s5, "NOR");

  elseif n == 3
    s1=sp3AND(varargin{:})
    s2=sp3OR(varargin{:})
    s3=sp3XOR(varargin{:})
    s4=sp3NAND(varargin{:})
    s5=sp3NOR(varargin{:})

    switchingActivity(s1, "AND");
    switchingActivity(s2, "OR");
    switchingActivity(s3, "XOR");
    switchingActivity(s4, "NAND");
    switchingActivity(s5, "NOR");
  else
    s1=spnAND(varargin{:})
    s2=spnOR(varargin{:})
    s3=spnXOR(varargin{:})
    s4=spnNAND(varargin{:})
    s5=spnNOR(varargin{:})

    switchingActivity(s1, "AND");
    switchingActivity(s2, "OR");
    switchingActivity(s3, "XOR");
    switchingActivity(s4, "NAND");
    switchingActivity(s5, "NOR");
  endif
  %sp2AND(input1sp, input2sp)
  %sp2OR(input1sp, input2sp)

  % Οι παρακάτω συναρτήσεις πρέπει να ολοκληρωθούν για το (α)
  %sp2XOR(input1sp, input2sp)
  %sp2NAND(input1sp, input2sp)
  %sp2NOR(input1sp, input2sp)

  % Οι παρακάτω συναρτήσεις πρέπει να γραφούν εξ'ολοκλήρου για το (β)
  %sp3AND(input1sp, input2sp, input3sp)
  %sp3OR(input1sp, input2sp, input3sp)
  %sp3XOR(input1sp, input2sp, input3sp);
  %sp3NAND(input1sp, input2sp, input3sp);
  %sp3NOR(input1sp, input2sp, input3sp);

  % Οι παρακάτω συναρτήσεις πρέπει να γραφούν εξ'ολοκλήρου για το (γ)
  %% προσοχή: πρέπει να παίζουν ανεξάρτητα του πόσες εισόδους τους δίνετε
  %spAND(input1sp, input2sp, input3sp, input4sp ...)
  %spOR(input1sp, input2sp, input3sp, input4sp ...)
  %spXOR(input1sp, input2sp, input3sp, input4sp, ...);
  %spNAND(input1sp, input2sp, input3sp, input4sp, ...);
  %spNOR(input1sp, input2sp, input3sp, input4sp, ...);

end
%

% 2-input AND gate truth table
% 0 0:0
% 0 1:0
% 1 0:0
% 1 1:1
%% signal probability calculator for a 2-input AND gate
%% input1sp: signal probability of first input signal
%% input2sp: signal probability of second input signal
%%        s: output signal probability
function s=sp2AND(input1sp, input2sp)
  printf("AND Gate for input probabilities (%f %f):\n",input1sp,input2sp)
  s = input1sp*input2sp;
  endfunction

% 2-input OR gate truth table
% 0 0:0
% 0 1:1
% 1 0:1
% 1 1:1
%% signal probability calculator for a 2-input OR gate
%% input1sp: signal probability of first input signal
%% input2sp: signal probability of second input signal
%%        s: output signal probability
function s=sp2OR(input1sp, input2sp)
  printf("OR Gate for input probabilities (%f %f):\n",input1sp,input2sp)
  s = 1-(1-input1sp)*(1-input2sp);
endfunction


% 2-input XOR gate truth table
% 0 0:0
% 0 1:1
% 1 0:1
% 1 1:0
%% signal probability calculator for a 2-input XOR gate
%% input1sp: signal probability of first input signal
%% input2sp: signal probability of second input signal
%%        s: output signal probability
function s=sp2XOR(input1sp, input2sp)
  printf("XOR Gate for input probabilities (%f %f):\n",input1sp,input2sp)
  s = input1sp*(1 - input2sp) + (1 - input1sp)*input2sp;
endfunction


% 2-input NAND gate truth table
% 0 0:1
% 0 1:1
% 1 0:1
% 1 1:0
%% signal probability calculator for a 2-input XOR gate
%% input1sp: signal probability of first input signal
%% input2sp: signal probability of second input signal
%%        s: output signal probability
function s=sp2NAND(input1sp, input2sp)
  printf("NAND Gate for input probabilities (%f %f):\n",input1sp,input2sp)
  s = 1 - (input1sp * input2sp);
endfunction



% 2-input NOR gate truth table
% 0 0:1
% 0 1:0
% 1 0:0
% 1 1:0
%% signal probability calculator for a 2-input NOR gate
%% input1sp: signal probability of first input signal
%% input2sp: signal probability of second input signal
%%        s: output signal probability
function s=sp2NOR(input1sp, input2sp)
  printf("NOR Gate for input probabilities (%f %f):\n",input1sp,input2sp)
  s = (1-input1sp)*(1-input2sp);
endfunction

%β)
%sp3AND εχω 1 μονο οταν και οι τρεις ειναι 1
function s=sp3AND(input1sp, input2sp, input3sp)
  printf("AND Gate for input probabilities (%f %f %f):\n",input1sp,input2sp,input3sp)
  s = input1sp*input2sp * input3sp;
endfunction

%sp3OR εχω 1 οταν εστω η μια απο τις τρεις ειναι 1
function s=sp3OR(input1sp, input2sp, input3sp)
  printf("OR Gate for input probabilities (%f %f %f):\n",input1sp,input2sp, input3sp)
  s = 1 - (1-input1sp)*(1-input2sp)*(1-input3sp);
endfunction

%sp3XOR εχω 1 οταν μονο μια απο τις τρεις ειναι 1 ή οταν ειναι και οι τρεις
function s=sp3XOR(input1sp, input2sp, input3sp)
  printf("XOR Gate for input probabilities (%f %f %f):\n",input1sp,input2sp, input3sp)
  s = input1sp*(1-input2sp)*(1-input3sp) + input2sp*(1-input1sp)*(1-input3sp) + input3sp*(1-input1sp)*(1-input2sp) + input1sp*input2sp*input3sp;
endfunction

%sp3NAND λειτουργεί με τον αντίθετο τρόπο από την sp3AND
function s=sp3NAND(input1sp, input2sp, input3sp)
  printf("NAND Gate for input probabilities (%f %f %f):\n",input1sp,input2sp,input3sp)
  s = 1- (input1sp*input2sp*input3sp);
endfunction

%sp3NOR λειτουργεί με τον αντίθετο τρόπο από την OR
function s=sp3NOR(input1sp, input2sp, input3sp)
  printf("ΝOR Gate for input probabilities (%f %f %f):\n",input1sp,input2sp, input3sp)
  s = (1-input1sp)*(1-input2sp)*(1-input3sp);
endfunction

%γ)
%όλες οι πυλες θα υλοποιηθούν με τον ίδιο τρόπο αλλά με for μέχρι το Ν
%spnAND εχω 1 μονο οταν ολες ειναι 1
function s=spnAND(varargin)
  printf("%d-input AND Gate:\n", length(varargin));
  s = 1;
  for i=1:length(varargin)
    s = s * varargin{i};
  endfor
endfunction

%spnOR εχω 1 οταν εστω η μια ειναι 1
function s=spnOR(varargin)
  printf("%d-input OR Gate:\n", length(varargin));
  s = 1;
  for i=1:length(varargin)
    s = s * (1 - varargin{i});
  endfor
  s = 1 - s;
endfunction

%spnXOR εχω 1 οταν εχω περιττο αριθμο απο 1
function s = spnXOR(varargin)
  printf("%d-input XOR Gate:\n", length(varargin));
  s = 0;
  for i = 1:length(varargin)
    p = varargin{i};
    s = s*(1 - p) + (1 - s)*p;
  endfor
endfunction


%spnNAND λειτουργεί με τον αντίθετο τρόπο από την sp3AND
%μπορουμε απλα να παρουμε το αποτελεσμα της and αντι να κανουμε ξανα μια for loop
function s=spnNAND(varargin)
  printf("%d-input NAND Gate:\n", length(varargin));
  s = 1;
  for i=1:length(varargin)
    s = s * varargin{i};
  endfor
  s = 1 - s;
endfunction

%spnNOR λειτουργεί με τον αντίθετο τρόπο από την OR
function s=spnNOR(varargin)
  printf("%d-input ΝOR Gate:\n", length(varargin));
  s = 1;
  for i=1:length(varargin)
    s = s * (1 - varargin{i});
  endfor
endfunction

%δ)
function switchingActivity(p_out, label)
  alpha = 2 * p_out * (1 - p_out);
  printf("Switching activity for %s gate = %f\n", label, alpha);
endfunction

