function simulator_load()

#simulator_load calls circuit_tb twice (for input_file_2.txt and input_file.txt).
#We have two truth-table
  warning('off', 'all');
  #Format A
  circuit_tb('input_file_2.txt');
  #Format B
  circuit_tb('input_file.txt');

  calculate_esw();
  calculate_esw_5281();
  calculate_esw_5386();

endfunction
#Model format circuit(input1,input2,...,file_path);
function [ResultOutputs, ResultDescribeOutputsTable] = circuit(varargin)

    #--------------------------- this is code for organize our circuit ---------------------------
    elements = [];
    top_inputs = [];

    fid = fopen(varargin{end}, "r");

    if fid == -1
      error("Something went wrong opening file!");
    endif

    while ~feof(fid)
      line = fgetl(fid);
      tokens = strsplit(line," ");

      #get top inputs here
      if (strcmp(tokens{1,1},'top_inputs'))
        top_inputs = tokens(1,2:end);
        continue;
      endif

      tempE.type = tokens{1,1};
      tempE.outputChar = tokens(1,2);
      tempE.output = 0;
      n = size(tokens, 2);

      inputs = [];
      for i=3:n
        inputs = [inputs tokens(1,i)];
      endfor
      tempE.inputsChar = inputs;
      tempE.inputs = zeros(1,length(inputs));
      elements = [elements, tempE];

    endwhile

    fclose(fid);

    nTopInputs = length(top_inputs);
    if(nTopInputs==0)
      nTopInputs = countTopInputs(elements);
    endif

    [elements,describeTable,nSignalsTable] = linkElements(elements);

    signalsTable = zeros(1,nSignalsTable);

    for i=1:nTopInputs
      #varargin{i};
      signalsTable(i) = varargin{i};
    endfor

    for el=elements
      signalsTable = process(el,signalsTable);
    endfor

    #initialize the top inputs
    for i=1:nTopInputs
      signalsTable(i) = varargin{i};
    endfor

    #run for every element
    for el=elements
      signalsTable = process(el,signalsTable);
    endfor

    #organize output
    describeOutputsTable=[];
    outputs=[];
    for el=elements
      describeOutputsTable= [describeOutputsTable el.outputChar];
      outputs=[outputs signalsTable(el.output)];
    endfor

    ResultOutputs = outputs;
    ResultDescribeOutputsTable = describeOutputsTable;

endfunction

#link elements here
function [resultELements,resultDescribeTable,nSignalsTable] = linkElements(elements)
  elementsN = size(elements,2);

  describeTable = [''];

  #put inputs to describeTable
  for i=1:elementsN
    #for every input
    for j=1:size(elements(i).inputsChar,2)
      #in case if same input
      foundSame=0;
      for token=strsplit(describeTable," ")
        if strcmp(token,elements(i).inputsChar{1,j})
          foundSame=1;
          break;
        endif
      endfor
      if(foundSame==0)
        describeTable = [describeTable ' ' elements(i).inputsChar{1,j}];
      endif
    endfor
  endfor

  describeTable = describeTable(2:end);
  #put outputs
  for i=1:elementsN

    foundSame=0;
    for token=strsplit(describeTable," ")
       if strcmp(token,elements(i).outputChar{1,1})
         foundSame=1;
         break;
       endif
    endfor

    if(foundSame==0)
        describeTable = [describeTable ' ' elements(i).outputChar{1,1}];
    endif
  endfor

  #time for indexing
  for i=1:elementsN

    #map inputs first
    for j=1:size(elements(i).inputsChar,2)
      index = 1;
      for token=strsplit(describeTable," ")
        if strcmp(token,elements(i).inputsChar{1,j})
          elements(i).inputs(j) = index;
          break;
        endif
        index++;
      endfor
    endfor

    #map output
    index=1;
    for token=strsplit(describeTable," ")
        if strcmp(token,elements(i).outputChar{1,1})
          elements(i).output=index;
          break;
        endif
        index++;
    endfor

   endfor

  #give the return values
  nSignalsTable=length(strsplit(describeTable," "));
  resultELements = elements;
  resultDescribeTable = describeTable;
endfunction
#find top inputs here
function nTopInputs = countTopInputs(elements)

  elementsN = size(elements,2);
  countTopInputs = 0;

  for i=1:elementsN

    #for every input
    for j=1:size(elements(i).inputsChar,2)

      foundSame=0;

      #for previous elements
      for k=1:i
        if(strcmp(elements(k).outputChar{1,1},   elements(i).inputsChar{1,j}))
          foundSame=1;
          break;
        endif
      endfor

      if (foundSame==0)
        countTopInputs++;
      endif

    endfor

  endfor

  nTopInputs=countTopInputs;

endfunction
function signalTable = process(element,SignalsTable)

  temp_inputs = [];
  for in=element.inputs
    temp_inputs = [temp_inputs SignalsTable(in)];
  endfor
  temp_inputs = num2cell(temp_inputs);


  if (strcmp(element.type,'AND'))
    SignalsTable(element.output) = spAND(temp_inputs{:});
  elseif(strcmp(element.type,'NOT'))
    SignalsTable(element.output) = spNOT(SignalsTable(element.inputs(1)));
  elseif (strcmp(element.type,'OR'))
    SignalsTable(element.output) = spOR(temp_inputs{:});
  elseif (strcmp(element.type,'XOR'))
    SignalsTable(element.output) = spXOR(temp_inputs{:});
  elseif (strcmp(element.type,'NAND'))
    SignalsTable(element.output) = spNAND(temp_inputs{:});
  elseif (strcmp(element.type,'NOR'))
    SignalsTable(element.output) = spNOR(temp_inputs{:});
  endif


  signalTable = SignalsTable;

endfunction
#this is testbench
function circuit_tb(strPath)

  combinations = dec2bin(0:(2^3)-1) - '0';

  for i=1:8

    a = combinations(i,1);
    b = combinations(i,2);
    c = combinations(i,3);

    outputs = circuit(a,b,c,strPath);
    d = outputs(end);
    printf("\n")
    printf("A B C D\n");
    printf("%f %f %f %f \n",a,b,c,d)

  endfor

  printf("EVERYTHING WORKS PERFECT!\n");

endfunction
#to validate our system
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

  #for type-A file
  printf("----------------------- input_file.txt -----------------------\n");
  [outputs,describeTable] = circuit(0.5,0.5,0.5,'input_file.txt');
  for i=1:length(outputs)
    temp_esw = (2*outputs(i))*(1-outputs(i));
    printf("ESW_%s: %f\n",describeTable{1,i},temp_esw);
  endfor

  #for type-B file
  printf("----------------------- input_file_2.txt -----------------------\n");
  [outputs,describeTable] = circuit(0.5,0.5,0.5,'input_file_2.txt');
  for i=1:length(outputs)
    temp_esw = (2*outputs(i))*(1-outputs(i));
    printf("ESW_%s: %f\n",describeTable{1,i},temp_esw);
  endfor

endfunction

function calculate_esw_5281()

  #for type-A file
  printf("----------------------- input_file.txt [5281]---------------------\n");
  [outputs,describeTable] = circuit(0.5281,0.5281,0.5281,'input_file.txt');
  for i=1:length(outputs)
    temp_esw = (2*outputs(i))*(1-outputs(i));
    printf("ESW_%s: %f\n",describeTable{1,i},temp_esw);
  endfor

  #for type-B file
  printf("----------------------- input_file_2.txt [5281]-------------------\n");
  [outputs,describeTable] = circuit(0.5281,0.5281,0.5281,'input_file_2.txt');
  for i=1:length(outputs)
    temp_esw = (2*outputs(i))*(1-outputs(i));
    printf("ESW_%s: %f\n",describeTable{1,i},temp_esw);
  endfor

endfunction

function calculate_esw_5386()

  #for type-A file
  printf("----------------------- input_file.txt [5386] -----------------------\n");
  [outputs,describeTable] = circuit(0.5386,0.5386,0.5386,'input_file.txt');
  for i=1:length(outputs)
    temp_esw = (2*outputs(i))*(1-outputs(i));
    printf("ESW_%s: %f\n",describeTable{1,i},temp_esw);
  endfor

  #for type-B file
  printf("----------------------- input_file_2.txt [5386]--------------------\n");
  [outputs,describeTable] = circuit(0.5386,0.5386,0.5386,'input_file_2.txt');
  for i=1:length(outputs)
    temp_esw = (2*outputs(i))*(1-outputs(i));
    printf("ESW_%s: %f\n",describeTable{1,i},temp_esw);
  endfor
endfunction

#SignalProbabilities functions

function s=spAND(varargin)

  n = nargin;
  probability = 1.0;

  for i=1:n
    probability*=varargin{i};
  endfor

  s = probability;
endfunction

function s=spOR(varargin)

  n = nargin;
  #this is total probability
  totalProbability = 0.0;

  combinations = dec2bin(0:((2^n)-1)) - '0'; #to - '0' to bazoume gia tis sigriseis meta
  nRows = size(combinations,1);

  for i=1:nRows

    outputGate = combinations(i,1);
    currentProb = 1.0;

    if( combinations(i,1) == 0)
      currentProb *= (1-varargin{1});
    else
      currentProb *= (varargin{1});
    endif

    #take the row
    for j=2:n
      outputGate = or(outputGate,combinations(i,j));
      if( combinations(i,j) == 0 )
        currentProb *= (1-varargin{j});
      else
        currentProb *= (varargin{j});
      endif
    endfor

    if (outputGate == 1)
      totalProbability+=currentProb;
    endif

  endfor
  s = totalProbability;

endfunction

function s=spXOR(varargin)

  n = nargin;
  #this is total probability
  totalProbability = 0.0;

  combinations = dec2bin(0:((2^n)-1)) - '0'; #to - '0' to bazoume gia tis sigriseis meta
  nRows = size(combinations,1);

  for i=1:nRows

    outputGate = combinations(i,1);
    currentProb = 1.0;

    if( combinations(i,1) == 0)
      currentProb *= (1-varargin{1});
    else
      currentProb *= (varargin{1});
    endif

    #take the row
    for j=2:n
      outputGate = xor(outputGate,combinations(i,j));
      if( combinations(i,j) == 0 )
      currentProb *= (1-varargin{j});
      else
        currentProb *= (varargin{j});
      endif
    endfor

    if (outputGate == 1)
      totalProbability+=currentProb;
    endif

  endfor

  s = totalProbability;
endfunction

function s=spNAND(varargin)

  n = nargin;
  #this is total probability
  totalProbability = 0.0;

  combinations = dec2bin(0:((2^n)-1)) - '0'; #to - '0' to bazoume gia tis sigriseis meta

  nRows = size(combinations,1);

  for i=1:nRows

    outputGate = combinations(i,1);
    currentProb = 1.0;

    if( combinations(i,1) == 0)
      currentProb *= (1-varargin{1});
    else
      currentProb *= (varargin{1});
    endif

    #take the row
    for j=2:n
      outputGate = !(and(outputGate,combinations(i,j)));
      if( combinations(i,j) == 0 )
      currentProb *= (1-varargin{j});
      else
        currentProb *= (varargin{j});
      endif
    endfor

    if (outputGate == 1)
      totalProbability+=currentProb;
    endif

  endfor

  s = totalProbability;

endfunction

function s=spNOR(varargin)

  n = nargin;
  probability = 1.0;

  for i=1:n
    probability*=(1-varargin{i});
  endfor

  s = probability;
endfunction

function s=spNOT(input1sp)
  s = (1-input1sp);
endfunction
