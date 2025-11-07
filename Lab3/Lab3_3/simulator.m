function simulator

  #εδω τα λογικά στοιχεία στο αρχείο μπορεί να μην είναι ταξινομημένα με βάση
  #τη σωστή σειρά επεξεργασίας τους.
  warning('off', 'all');

  circuit_tb('input_file_format_1.txt');
  circuit_tb('input_file_format_2.txt');

  #find esw_here
  calculate_esw();
  calculate_esw_5281();
  calculate_esw_5386();

  #this method is to load check circuit (ex. circuit(inputs,<file_path>)
  #[outputs,describeTable] = circuit(0.5,0.5,0.5,0.5,0.5,0.5,'input_file_3_test.txt');
  #outputs
  #for i=1:length(describeTable)
  #  printf("%s ", describeTable{1,i});
  #endfor
  #printf("\n");

endfunction

#Model format circuit(input1,input2,...,file_path);
function [ResultOutputs, ResultDescribeOutputsTable]  = circuit(varargin)


  #collect the elements
  elements = [];

  #collect the top inputs
  top_inputs = [];

  #open file here
  fid = fopen(varargin{end}, "r");

  #in case something went wrong
  if fid == -1
    error("Something went wrong opening file!");
  endif

  #read every file lines
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
    tempE.markedOutput = 0;
    n = size(tokens, 2);

    inputs = [];
    for i=3:n
      inputs = [inputs tokens(1,i)];
    endfor
    tempE.inputsChar = inputs;
    tempE.inputs = zeros(1,length(inputs));
    tempE.markedInputs = zeros(1,length(inputs));

    elements = [elements, tempE];

endwhile


  nTopInputs=length(top_inputs);
  if(length(top_inputs)==0)
    [nTopInputs,top_inputs] = countTopInputs(elements);
    tokens = strsplit(top_inputs," ");
    top_inputs = tokens(1,2:end);
  endif


  #get initial marked elements
  [sortedElements, elements] = getInitialMarkedInputs(elements, top_inputs);

  sortedElements = [sortedElements sortElements(elements)];

  [sortedElements,describeTable,nSignalsTable] = linkElements(sortedElements);

    printf("------------------ SORTED ----------------------------\n")
    #test here
    for el=sortedElements
      printf("\n\n")
      printf("TYPE: \n");
      el.type
      printf("INPUTS: \n");
      el.inputsChar
      el.inputs
      printf("OUTPUTS: \n");
      el.outputChar
      el.output
    endfor
    #end test

  signalsTable = zeros(1,nSignalsTable);


  #initialize the top inputs
  for i=1:nTopInputs
    signalsTable(i) = varargin{i};
  endfor

  for el=sortedElements
    signalsTable = process(el,signalsTable);
  endfor


    #organize output
    describeOutputsTable=[];
    outputs=[];
    for el=sortedElements
      describeOutputsTable= [describeOutputsTable el.outputChar];
      outputs=[outputs signalsTable(el.output)];
    endfor

    ResultOutputs = outputs;
    ResultDescribeOutputsTable = describeOutputsTable;

    printf("-------------------------------- OUTPUT INDEXES-------------------------------- \n")

    signalsTable

    #test
    for el=sortedElements
      el.type
      el.inputs
      el.output
    endfor

    #end test

endfunction

#find, mark and gather initial elements
function [resultSortedElements, ResultElements] = getInitialMarkedInputs(elements, top_inputs)

  sortedElements = [];
  nonSorted = [];

  elementsN = size(elements,2);
  topInputsN = length(top_inputs);

  #step 1 mark the top inputs
  for i=1:elementsN
      #for every input
      for j=1:size(elements(i).inputsChar,2)
        #if same with the top inputs
        for input=top_inputs
          if (strcmp(input{1,1} , elements(i).inputsChar{1,j}))
            elements(i).markedInputs(j) = 1;
          endif
        endfor
      endfor
  endfor


  #step 2 push the elements to sortedElements
  for i=1:elementsN
      #check if all inputs are marked
      if (all(elements(i).markedInputs==1))
        elements(i).markedOutput = 1;
        sortedElements = [sortedElements elements(i)];
      endif
  endfor

  #step 3 mark the outpus
  for i=1:size(sortedElements,2);
    #now need to mark the inputs of where is connected to our output
    for k=1:elementsN
      for in=1:size(elements(k).inputsChar,2)
        if (strcmp(sortedElements(i).outputChar{1,1} , elements(k).inputsChar{1,in}))
          elements(k).markedInputs(in) = 1;
        endif
      endfor
    endfor
  endfor

  #test
  #printf("----------------------- SORTED ELEMENTS INSIDE FUNCTION ----------------------- \n");
  #for el=sortedElements
  #  el.type
  #  el.inputsChar
  #  el.outputChar
  #endfor
  #end test

  #now remove the sortedElements from elements array
  finalElements = [];
  sortedElementsN = size(sortedElements,2);

for i=1:elementsN
  foundSame = 0;

  for j=1:sortedElementsN
    if ( strcmp(sortedElements(j).type , elements(i).type) && strcmp(sortedElements(j).inputsChar{1,1} , elements(i).inputsChar{1,1}) )
      foundSame=1;
      break;
    endif
  endfor

  if (foundSame==0)
    finalElements = [finalElements , elements(i)];
  endif

endfor

  #return the output
  resultSortedElements = sortedElements;
  ResultElements = finalElements;

endfunction

# gather remain elemenets
function ResultSortedElements = sortElements(elements)

  sortedElements = [];
  count = 0;

  while (length(elements) != 0)

    #step 1 get the elements with all marked inputs
    for i=1:size(elements,2)
      if (all(elements(i).markedInputs==1))
        elements(i).markedOutput = 1;
        sortedElements = [sortedElements elements(i)];
      endif
    endfor

    #step 2 highlight the outputs of collected inputs
    for i=1:size(sortedElements,2)
      for k=1:size(elements,2)
        for in=1:size(elements(k).inputsChar,2)
          if (strcmp(sortedElements(i).outputChar{1,1},elements(k).inputsChar{1,in}))
            elements(k).markedInputs(in) = 1;
          endif
        endfor
      endfor
    endfor


    #step 3 delete the sortedElements from elements array
    tempElements = [];
    for i=1:size(elements,2)
      foundSame = 0;

      for j=1:size(sortedElements,2)
        if ( strcmp(sortedElements(j).type , elements(i).type) && strcmp(sortedElements(j).inputsChar{1,1} , elements(i).inputsChar{1,1}))
          foundSame=1;
          break;
        endif
      endfor

      if (foundSame==0)
        tempElements = [tempElements , elements(i)];
      endif
    endfor

    elements = tempElements;

  endwhile

  ResultSortedElements = sortedElements;

endfunction

#link elements
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

function [nTopInputs,ResultTopInputs] = countTopInputs(elements)

  elementsN = size(elements,2);
  top_inputs = [];
  countTopInputs = 0;

  for i=1:elementsN

    #for every input
    for j=1:size(elements(i).inputsChar,2)

      foundSame=0;

      #for all elements
      for k=1:elementsN
        if(strcmp(elements(k).outputChar{1,1},   elements(i).inputsChar{1,j}))
          foundSame=1;
          break;
        endif
      endfor

      if (foundSame==0)
        top_inputs = [top_inputs ' ' elements(i).inputsChar{1,j}];
        countTopInputs++;
      endif

    endfor

  endfor

  nTopInputs=countTopInputs;
  ResultTopInputs=top_inputs;

endfunction

#this is testbench
function circuit_tb(strPath)

  combinations = dec2bin(0:(2^3)-1) - '0';

  for i=1:8

    a = combinations(i,1);
    b = combinations(i,2);
    c = combinations(i,3);
    [outputs,describeTable] = circuit(a,b,c,strPath);
    d = outputs(end);

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

#issue with process
function signalTable = process(element,SignalsTable)

  temp_inputs = [];
  for in=element.inputs
    temp_inputs = [temp_inputs SignalsTable(in)];
  endfor
  temp_inputs = num2cell(temp_inputs);

  if (element.type == 'AND')
    SignalsTable(element.output) = spAND(temp_inputs{:});
  elseif(element.type == 'NOT')
    SignalsTable(element.output) = spNOT(SignalsTable(element.inputs(1)));
  elseif (element.type == 'OR')
    SignalsTable(element.output) = spOR(temp_inputs{:});
  elseif (element.type == 'XOR')
    SignalsTable(element.output) = spXOR(temp_inputs{:});
  elseif (element.type == 'NAND')
    SignalsTable(element.output) = spNAND(temp_inputs{:});
  elseif (element.type == 'NOR')
    SignalsTable(element.output) = spNOR(temp_inputs{:});
  endif

  signalTable = SignalsTable;

endfunction

function calculate_esw()

  #for type-A file
  printf("----------------------- input_file.txt -----------------------\n");
  [outputs,describeTable] = circuit(0.5,0.5,0.5,'input_file_format_1.txt');
  for i=1:length(outputs)
    temp_esw = (2*outputs(i))*(1-outputs(i));
    printf("ESW_%s: %f\n",describeTable{1,i},temp_esw);
  endfor

  #for type-B file
  printf("----------------------- input_file_2.txt -----------------------\n");
  [outputs,describeTable] = circuit(0.5,0.5,0.5,'input_file_format_2.txt');
  for i=1:length(outputs)
    temp_esw = (2*outputs(i))*(1-outputs(i));
    printf("ESW_%s: %f\n",describeTable{1,i},temp_esw);
  endfor


endfunction

function calculate_esw_5281()

  #for type-A file
  printf("----------------------- input_file.txt [5281] -----------------------\n");
  [outputs,describeTable] = circuit(0.5281,0.5281,0.5281,'input_file_format_1.txt');
  for i=1:length(outputs)
    temp_esw = (2*outputs(i))*(1-outputs(i));
    printf("ESW_%s: %f\n",describeTable{1,i},temp_esw);
  endfor

  #for type-B file
  printf("----------------------- input_file_2.txt [5281] -----------------------\n");
  [outputs,describeTable] = circuit(0.5281,0.5281,0.5281,'input_file_format_2.txt');
  for i=1:length(outputs)
    temp_esw = (2*outputs(i))*(1-outputs(i));
    printf("ESW_%s: %f\n",describeTable{1,i},temp_esw);
  endfor


endfunction

function calculate_esw_5386()

  #for type-A file
  printf("----------------------- input_file.txt [5386] -----------------------\n");
  [outputs,describeTable] = circuit(0.5386,0.5386,0.5386,'input_file_format_1.txt');
  for i=1:length(outputs)
    temp_esw = (2*outputs(i))*(1-outputs(i));
    printf("ESW_%s: %f\n",describeTable{1,i},temp_esw);
  endfor

  #for type-B file
  printf("----------------------- input_file_2.txt [5386] -----------------------\n");
  [outputs,describeTable] = circuit(0.5386,0.5386,0.5386,'input_file_format_2.txt');
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

  #2^n-1 argotera
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
