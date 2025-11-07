#4.1

function run_random_stress(filename, NUM_INDIVIDUALS)
    if nargin < 1
        error("Δώσε path αρχείου κυκλώματος μορφής 2 (π.χ. 'circuit.txt').");
    end
    if nargin < 2
        NUM_INDIVIDUALS = 2000;
    end

    try
        pkg load statistics;
    catch
        % ok if not available on MATLAB
    end

    %Load circuit
    circuit = buildCircuitFromFile(filename);
    inputsNumber = numel(circuit.TlpInputs);

    switchesTable = [];

    %Monte Carlo loop
    for it = 1:NUM_INDIVIDUALS
        W = gaGenerateRandomWorkload(inputsNumber, 2);

        % Apply first vector
        circuit = applyTLPInputs(circuit, W(1,:));
        circuit = process(circuit);
        circuit.SignalsBefore = circuit.Signals;

        % Apply second vector
        circuit = applyTLPInputs(circuit, W(2,:));
        circuit = process(circuit);

        % count toggles (excluding TLP inputs)
        sw = countSwitches(circuit);
        switchesTable(end+1,1) = sw; %#ok<AGROW>
    end

    %Stats & plot
    avgSwitches = mean(switchesTable);
    varSwitches = var(switchesTable);

    fprintf("Average switches: %.4f\n", avgSwitches);
    fprintf("Variance switches: %.4f\n", varSwitches);

    figure;
    plot(1:NUM_INDIVIDUALS, switchesTable, '.-');
    xlabel('individual #');
    ylabel('score (toggles in internal+output nets)');
    title(sprintf('Random stress test (L=2) - N=%d, mean=%.2f, var=%.2f', ...
                  NUM_INDIVIDUALS, avgSwitches, varSwitches));
    grid on;
    print('-dpng', 'stress_random_scores.png');
end


% for our help: random workload 2xN
function W = gaGenerateRandomWorkload(inputsNumber, L)
    W = randi([0 1], L, inputsNumber);
end

%loader: parse format-2 and convert names->indices
function circuit = buildCircuitFromFile(fname)
    fid = fopen(fname, 'r');
    if fid == -1
        error("Δεν βρέθηκε το αρχείο κυκλώματος: %s", fname);
    end

    lines = {};
    while ~feof(fid)
        ln = strtrim(fgetl(fid));
        if ischar(ln) && ~isempty(ln)
            lines{end+1} = ln; %#ok<AGROW>
        end
    end
    fclose(fid);

    % First pass: read TLPINPUTS and collect all names
    tlpNames = {};
    rawGates = {};
    for k = 1:numel(lines)
        toks = strsplit(lines{k}, ' ');
        if strcmpi(toks{1}, 'TLPINPUTS')
            tlpNames = toks(2:end);
        else
            gt.type    = upper(toks{1});
            gt.outName = toks{2};
            gt.inNames = toks(3:end);
            rawGates{end+1} = gt; %#ok<AGROW>
        end
    end

    % Collect all signal names (outputs + inputs)
    allNames = tlpNames;
    for k = 1:numel(rawGates)
        allNames = [allNames, rawGates{k}.outName, rawGates{k}.inNames]; %#ok<AGROW>
    end
    % unique, preserve order
    [~, ia] = unique(allNames, 'stable');
    signalNames = allNames(sort(ia));

    % Make name->index map
    name2idx = containers.Map(signalNames, num2cell(1:numel(signalNames)));

    % TLP indices
    tlpIdx = cellfun(@(s) name2idx(s), tlpNames);

    % Build Elements with numeric indices
    Elements = cell(1, numel(rawGates));
    for k = 1:numel(rawGates)
        g = struct();
        g.type   = rawGates{k}.type;
        g.output = name2idx(rawGates{k}.outName);
        inIdx    = zeros(1, numel(rawGates{k}.inNames));
        for j = 1:numel(rawGates{k}.inNames)
            inIdx(j) = name2idx(rawGates{k}.inNames{j});
        end
        % store as cell column to match your indexing style [ele.inputs{:,1}]
        g.inputs = num2cell(inIdx(:));
        Elements{k} = g;
    end

    % Init circuit struct
    circuit.SignalNames   = signalNames;
    circuit.TlpInputs     = tlpIdx;
    circuit.Elements      = Elements;
    circuit.ElementsSorted = [];         % filled by findProcessOrder
    circuit.Signals       = zeros(1, numel(signalNames));
    circuit.SignalsBefore = zeros(1, numel(signalNames));
    circuit.delays        = zeros(1, numel(signalNames));

    % Precompute order
    circuit = findProcessOrder(circuit);
end

%Apply inputs (set the TLP input indices)
function updated = applyTLPInputs(obj, vec)
    if numel(vec) ~= numel(obj.TlpInputs)
        error('applyTLPInputs: wrong vector length (got %d, expected %d).', ...
              numel(vec), numel(obj.TlpInputs));
    end
    obj.Signals(obj.TlpInputs) = vec;
    updated = obj;
end

%Evaluate the circuit in ElementsSorted order
function updated = process(obj)
    obj.delays(:) = 0;
    obj.SignalsBefore = obj.Signals;

    if isempty(obj.ElementsSorted)
        obj = findProcessOrder(obj);
    end

    for j = 1:numel(obj.ElementsSorted)
        ele = obj.Elements{obj.ElementsSorted(j)};
        inIdx = [ele.inputs{:,1}];
        inputValues = obj.Signals(inIdx);
        inputDelays = obj.delays(inIdx);

        obj.delays(ele.output)  = max(inputDelays) + 1.0;
        obj.Signals(ele.output) = spByType(ele.type, num2cell(inputValues){:});
    end
    updated = obj;
end

%Topological ordering
function updated = findProcessOrder(obj)
    nEls = numel(obj.Elements);
    nSigs = numel(obj.Signals);

    signalsUpdated  = false(1, nSigs);
    elementsUpdated = false(1, nEls);
    obj.ElementsSorted = [];

    signalsUpdated(obj.TlpInputs) = true;

    updatedNumberofElements = 0;
    guard = 0;
    while updatedNumberofElements ~= nEls
        progressed = false;

        for j = 1:nEls
            if elementsUpdated(j), continue; end
            ele = obj.Elements{j};
            inIdx = [ele.inputs{:,1}];
            if all(signalsUpdated(inIdx))
                elementsUpdated(j) = true;
                obj.ElementsSorted(end+1) = j; %#ok<AGROW>
                signalsUpdated(ele.output) = true;
                updatedNumberofElements = updatedNumberofElements + 1;
                progressed = true;
            end
        end

        if ~progressed
            error('findProcessOrder: cannot resolve order (cycle or missing driver).');
        end

        guard = guard + 1;
        if guard > nEls + 1000
            error('findProcessOrder: exceeded max iterations.');
        end
    end
    updated = obj;
end

%Boolean gate evaluation by type
function y = spByType(type, varargin)
    v = cell2mat(varargin);
    switch upper(type)
        case 'AND',  y = double(all(v == 1));
        case 'OR',   y = double(any(v == 1));
        case 'NAND', y = double(~all(v == 1));
        case 'NOR',  y = double(~any(v == 1));
        case 'XOR',  y = double(mod(sum(v),2));
        case 'XNOR', y = double(~mod(sum(v),2));
        otherwise, error('Unknown gate type: %s', type);
    end
end

%Count toggles excluding TLP inputs
function switchesnumber = countSwitches(obj)
    switchesnumber = 0;
    total = numel(obj.Signals);
    mask = true(1,total);
    mask(obj.TlpInputs) = false;  % do not count input nets
    for j = 1:total
        if ~mask(j), continue; end
        if obj.SignalsBefore(j) ~= obj.Signals(j)
            switchesnumber = switchesnumber + 1;
        end
    end
end

