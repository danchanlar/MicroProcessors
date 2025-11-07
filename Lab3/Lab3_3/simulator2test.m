function simulator2test
  % Κεντρική ρουτίνα
  warning('off','all');

  % Truth tables για τα 2 format
  circuit_tb('input_file_format_1.txt');
  circuit_tb('input_file_format_2.txt');

  % ESW υπολογισμοί
  calculate_esw();
  calculate_esw_5281();
  calculate_esw_5386();
end

% ------------------------- ΚΥΡΙΟΣ ΠΡΟΣΟΜΟΙΩΤΗΣ -------------------------
% Χρήση: [outputs, labels] = circuit(in1, in2, ..., 'file_path.txt')
function [ResultOutputs, ResultDescribeOutputsTable] = circuit(varargin)
  elements   = [];     % πίνακας δομών για τις πύλες
  top_inputs = [];     % λίστα συμβολικών πρωτευόντων εισόδων

  % ¶νοιγμα αρχείου περιγραφής
  fid = fopen(varargin{end}, 'r');
  if fid == -1
    error('Something went wrong opening file!');
  end

  % Ανάγνωση γραμμών
  while ~feof(fid)
    line   = fgetl(fid);
    tokens = strsplit(line, ' ');

    % top_inputs a b c ...
    if strcmp(tokens{1,1}, 'top_inputs')
      top_inputs = tokens(1,2:end);
      continue;
    end

    % Δομή στοιχείου (πύλης)
    tempE.type         = tokens{1,1};
    tempE.outputChar   = tokens(1,2);
    tempE.output       = 0;
    tempE.markedOutput = 0;

    n = numel(tokens);
    inputs = [];
    for i = 3:n
      inputs = [inputs tokens(1,i)];
    end
    tempE.inputsChar   = inputs;
    tempE.inputs       = zeros(1, numel(inputs));
    tempE.markedInputs = zeros(1, numel(inputs));
    elements = [elements, tempE];
  end
  fclose(fid);

  % Αν δεν δόθηκαν top_inputs μέσα στο αρχείο, υπολόγισέ τα
  nTopInputs = numel(top_inputs);
  if nTopInputs == 0
    [nTopInputs, top_inputs_str] = countTopInputs(elements);
    tokens = strsplit(top_inputs_str, ' ');
    top_inputs = tokens(1,2:end); % αγνόησε το αρχικό κενό
  end

  % Topological sort: αρχικά στοιχεία + όλα τα υπόλοιπα
  [sortedElements, elements] = getInitialMarkedInputs(elements, top_inputs);
  sortedElements = [sortedElements, sortElements(elements)];

  % Map συμβολικών σημάτων σε indices
  [sortedElements, describeTable, nSignalsTable] = linkElements(sortedElements);

  % Πίνακας τιμών σημάτων
  signalsTable = zeros(1, nSignalsTable);

  % Αρχικοποίηση πρωτευόντων εισόδων με τα varargin
  for i = 1:nTopInputs
    signalsTable(i) = varargin{i};
  end

  % Διερεύνηση (run) κυκλώματος
  for el = sortedElements
    signalsTable = process(el, signalsTable);
  end

  % Συγκρότηση εξόδων (με σειρά στοιχείων)
  describeOutputsTable = [];
  outputs = [];
  for el = sortedElements
    describeOutputsTable = [describeOutputsTable el.outputChar];
    outputs = [outputs signalsTable(el.output)];
  end

  % Επιστροφή
  ResultOutputs = outputs;
  ResultDescribeOutputsTable = describeOutputsTable;
end

% ------------------------- ΒΟΗΘΗΤΙΚΑ ΓΙΑ SORT --------------------------
function [resultSortedElements, ResultElements] = getInitialMarkedInputs(elements, top_inputs)
  sortedElements = [];
  elementsN = numel(elements);

  % Μαρκάρισμα inputs που είναι top_inputs
  for i = 1:elementsN
    for j = 1:numel(elements(i).inputsChar)
      for input = top_inputs
        if strcmp(input{1,1}, elements(i).inputsChar{1,j})
          elements(i).markedInputs(j) = 1;
        end
      end
    end
  end

  % Όσες πύλες έχουν όλα τα inputs μαρκαρισμένα, μπαίνουν πρώτες
  for i = 1:elementsN
    if all(elements(i).markedInputs == 1)
      elements(i).markedOutput = 1;
      sortedElements = [sortedElements elements(i)];
    end
  end

  % Μαρκάρισμα inputs που τροφοδοτούνται από τα outputs των ήδη επιλεγμένων
  for i = 1:numel(sortedElements)
    for k = 1:elementsN
      for in = 1:numel(elements(k).inputsChar)
        if strcmp(sortedElements(i).outputChar{1,1}, elements(k).inputsChar{1,in})
          elements(k).markedInputs(in) = 1;
        end
      end
    end
  end

  % Αφαίρεση των ήδη ταξινομημένων από το υπόλοιπο σύνολο
  finalElements = [];
  for i = 1:elementsN
    foundSame = 0;
    for j = 1:numel(sortedElements)
      if strcmp(sortedElements(j).type, elements(i).type) && ...
         strcmp(sortedElements(j).inputsChar{1,1}, elements(i).inputsChar{1,1})
        foundSame = 1; break;
      end
    end
    if ~foundSame
      finalElements = [finalElements, elements(i)];
    end
  end

  resultSortedElements = sortedElements;
  ResultElements = finalElements;
end

function ResultSortedElements = sortElements(elements)
  sortedElements = [];

  while ~isempty(elements)
    % Βρες όσες έχουν όλα τα inputs μαρκαρισμένα
    for i = 1:numel(elements)
      if all(elements(i).markedInputs == 1)
        elements(i).markedOutput = 1;
        sortedElements = [sortedElements elements(i)];
      end
    end

    % Μαρκάρισε τα outputs τους στα υπόλοιπα
    for i = 1:numel(sortedElements)
      for k = 1:numel(elements)
        for in = 1:numel(elements(k).inputsChar)
          if strcmp(sortedElements(i).outputChar{1,1}, elements(k).inputsChar{1,in})
            elements(k).markedInputs(in) = 1;
          end
        end
      end
    end

    % Βγάλε τις ήδη ταξινομημένες
    tempElements = [];
    for i = 1:numel(elements)
      foundSame = 0;
      for j = 1:numel(sortedElements)
        if strcmp(sortedElements(j).type, elements(i).type) && ...
           strcmp(sortedElements(j).inputsChar{1,1}, elements(i).inputsChar{1,1})
          foundSame = 1; break;
        end
      end
      if ~foundSame
        tempElements = [tempElements, elements(i)];
      end
    end
    elements = tempElements;
  end

  ResultSortedElements = sortedElements;
end

function [resultElements, resultDescribeTable, nSignalsTable] = linkElements(elements)
  elementsN = numel(elements);
  describeTable = [''];

  % Συγκρότηση λεξιλογίου εισόδων
  for i = 1:elementsN
    for j = 1:numel(elements(i).inputsChar)
      foundSame = 0;
      for token = strsplit(describeTable, ' ')
        if strcmp(token, elements(i).inputsChar{1,j})
          foundSame = 1; break;
        end
      end
      if ~foundSame
        describeTable = [describeTable ' ' elements(i).inputsChar{1,j}];
      end
    end
  end
  describeTable = describeTable(2:end);

  % Προσθήκη outputs
  for i = 1:elementsN
    foundSame = 0;
    for token = strsplit(describeTable, ' ')
      if strcmp(token, elements(i).outputChar{1,1})
        foundSame = 1; break;
      end
    end
    if ~foundSame
      describeTable = [describeTable ' ' elements(i).outputChar{1,1}];
    end
  end

  % Mapping inputs σε indices
  for i = 1:elementsN
    % inputs
    for j = 1:numel(elements(i).inputsChar)
      index = 1;
      for token = strsplit(describeTable, ' ')
        if strcmp(token, elements(i).inputsChar{1,j})
          elements(i).inputs(j) = index; break;
        end
        index = index + 1;
      end
    end
    % output
    index = 1;
    for token = strsplit(describeTable, ' ')
      if strcmp(token, elements(i).outputChar{1,1})
        elements(i).output = index; break;
      end
      index = index + 1;
    end
  end

  nSignalsTable = numel(strsplit(describeTable, ' '));
  resultElements = elements;
  resultDescribeTable = describeTable;
end

function [nTopInputs, ResultTopInputs] = countTopInputs(elements)
  elementsN = numel(elements);
  top_inputs = [];
  countTopInputs = 0;

  for i = 1:elementsN
    for j = 1:numel(elements(i).inputsChar)
      foundSame = 0;
      for k = 1:elementsN
        if strcmp(elements(k).outputChar{1,1}, elements(i).inputsChar{1,j})
          foundSame = 1; break;
        end
      end
      if ~foundSame
        top_inputs = [top_inputs ' ' elements(i).inputsChar{1,j}];
        countTopInputs = countTopInputs + 1;
      end
    end
  end

  nTopInputs = countTopInputs;
  ResultTopInputs = top_inputs;
end

% --------------------------- TESTBENCH / OUTPUT --------------------------
function circuit_tb(strPath)
  combinations = dec2bin(0:(2^3)-1) - '0'; % 3 εισόδους (A,B,C) για demo

  printf('\n=== %s ===\n', strPath);
  printf('A B C | D\n');
  printf('-------------\n');
  for i = 1:8
    a = combinations(i,1); b = combinations(i,2); c = combinations(i,3);
    [outputs, ~] = circuit(a,b,c,strPath);
    d = outputs(end);                  % τελευταία έξοδος
    printf('%d %d %d | %.4f\n', a, b, c, d); % εκτύπωση πιθανότητας
  end
  printf("OK!\n");
end

% Προαιρετικός έλεγχος συγκεκριμένης λογικής (δεν χρησιμοποιείται στον κορμό)
function stat = checkIfCorrect(a,b,c,d)
  if (  ((a==0)&&(b==0)&&(c==0)&&(d==0)) || ...
        ((a==0)&&(b==0)&&(c==1)&&(d==0)) || ...
        ((a==0)&&(b==1)&&(c==0)&&(d==0)) || ...
        ((a==0)&&(b==1)&&(c==1)&&(d==0)) || ...
        ((a==1)&&(b==0)&&(c==0)&&(d==0)) || ...
        ((a==1)&&(b==0)&&(c==1)&&(d==0)) || ...
        ((a==1)&&(b==1)&&(c==0)&&(d==1)) || ...
        ((a==1)&&(b==1)&&(c==1)&&(d==0)) )
    stat = 1;
  else
    stat = 0;
  end
end

% ----------------------------- ΠΥΛΕΣ / LOGIC -----------------------------
function signalTable = process(element, SignalsTable)
  % Συλλογή τιμών εισόδων
  temp_inputs = [];
  for in = element.inputs
    temp_inputs = [temp_inputs SignalsTable(in)];
  end
  temp_inputs = num2cell(temp_inputs);

  % Επιλογή τύπου πύλης (ΣΩΣΤΗ σύγκριση strings)
  if     strcmp(element.type,'AND')
    SignalsTable(element.output) = spAND(temp_inputs{:});
  elseif strcmp(element.type,'NOT')
    SignalsTable(element.output) = spNOT(SignalsTable(element.inputs(1)));
  elseif strcmp(element.type,'OR')
    SignalsTable(element.output) = spOR(temp_inputs{:});
  elseif strcmp(element.type,'XOR')
    SignalsTable(element.output) = spXOR(temp_inputs{:});
  elseif strcmp(element.type,'NAND')
    SignalsTable(element.output) = spNAND(temp_inputs{:});
  elseif strcmp(element.type,'NOR')
    SignalsTable(element.output) = spNOR(temp_inputs{:});
  else
    error('Unknown gate type: %s', element.type);
  end

  signalTable = SignalsTable;
end

% --------------------------- ESW ΥΠΟΛΟΓΙΣΜΟΙ ----------------------------
function print_esw_block(p, path)
  [outputs, labels] = circuit(p,p,p, path);
  printf('p=%.4f | %s\n', p, path);
  for i = 1:numel(outputs)
    esw = 2*outputs(i)*(1 - outputs(i));
    printf('  ESW_%s: %.6f\n', labels{1,i}, esw);
  end
end

function calculate_esw()
  printf('\n--- ESW (p=0.5000) ---\n');
  print_esw_block(0.5, 'input_file_format_1.txt');
  print_esw_block(0.5, 'input_file_format_2.txt');
end

function calculate_esw_5281()
  printf('\n--- ESW (p=0.5281) ---\n');
  print_esw_block(0.5281, 'input_file_format_1.txt');
  print_esw_block(0.5281, 'input_file_format_2.txt');
end

function calculate_esw_5386()
  printf('\n--- ESW (p=0.5386) ---\n');
  print_esw_block(0.5386, 'input_file_format_1.txt');
  print_esw_block(0.5386, 'input_file_format_2.txt');
end

% ---------------------- ΠΙΘΑΝΟΤΗΤΕΣ ΛΟΓΙΚΩΝ ΠΥΛΩΝ -----------------------
function s = spAND(varargin)
  n = nargin;
  probability = 1.0;
  for i = 1:n
    probability = probability * varargin{i};
  end
  s = probability;
end

function s = spOR(varargin)
  n = nargin;
  totalProbability = 0.0;
  combinations = dec2bin(0:((2^n)-1)) - '0';
  nRows = size(combinations,1);

  for i = 1:nRows
    currentProb = 1.0;
    out = combinations(i,1);
    % prob του πρώτου bit
    if combinations(i,1) == 0, currentProb = currentProb*(1 - varargin{1});
    else,                       currentProb = currentProb*(varargin{1});
    end
    % συσσώρευση OR
    for j = 2:n
      out = or(out, combinations(i,j));
      if combinations(i,j) == 0, currentProb = currentProb*(1 - varargin{j});
      else,                       currentProb = currentProb*(varargin{j});
      end
    end
    if out == 1
      totalProbability = totalProbability + currentProb;
    end
  end
  s = totalProbability;
end

function s = spXOR(varargin)
  n = nargin;
  totalProbability = 0.0;
  combinations = dec2bin(0:((2^n)-1)) - '0';
  nRows = size(combinations,1);

  for i = 1:nRows
    currentProb = 1.0;
    out = combinations(i,1);
    if combinations(i,1) == 0, currentProb = currentProb*(1 - varargin{1});
    else,                       currentProb = currentProb*(varargin{1});
    end
    for j = 2:n
      out = xor(out, combinations(i,j));
      if combinations(i,j) == 0, currentProb = currentProb*(1 - varargin{j});
      else,                       currentProb = currentProb*(varargin{j});
      end
    end
    if out == 1
      totalProbability = totalProbability + currentProb;
    end
  end
  s = totalProbability;
end

function s = spNAND(varargin)
  % ΣΩΣΤΗ υλοποίηση: NAND = NOT(AND όλων)
  n = nargin;
  totalProbability = 0.0;
  combinations = dec2bin(0:((2^n)-1)) - '0';
  nRows = size(combinations,1);

  for i = 1:nRows
    currentProb = 1.0;

    % πιθανότητα γραμμής
    if combinations(i,1) == 0, currentProb = currentProb*(1 - varargin{1});
    else,                       currentProb = currentProb*(varargin{1});
    end
    and_all = combinations(i,1);

    for j = 2:n
      and_all = and(and_all, combinations(i,j)); % συσσώρευση ΚΑΙ
      if combinations(i,j) == 0, currentProb = currentProb*(1 - varargin{j});
      else,                       currentProb = currentProb*(varargin{j});
      end
    end

    out = ~and_all; % NAND
    if out == 1
      totalProbability = totalProbability + currentProb;
    end
  end

  s = totalProbability; % χωρίς άσκοπη εκτύπωση
end

function s = spNOR(varargin)
  n = nargin;
  probability = 1.0;
  for i = 1:n
    probability = probability * (1 - varargin{i});
  end
  s = probability;
end

function s = spNOT(input1sp)
  s = (1 - input1sp);
end

