#4.3

function genetic_stress_ga(filename, N, Gmax, mutation_rate)
    % Παράμετροι με default αν δεν δοθούν
    if nargin < 1, error("Δώσε path αρχείου κυκλώματος (μορφή 2)."); end
    if nargin < 2, N = 30;        end      % μέγεθος πληθυσμού
    if nargin < 3, Gmax = 100;    end      % γενιές
    if nargin < 4, mutation_rate = 0.05; end  % 5%

    try, pkg load statistics; catch, end

    % Φόρτωση κυκλώματος & προετοιμασία
    circuit0 = buildCircuitFromFile(filename);
    inputsNumber = numel(circuit0.TlpInputs);
    L = 2;

    % Αρχικοποίηση πληθυσμού: cell array, κάθε cell = 2xinputsNumber (0/1)
    population = gaInitPopulation(N, inputsNumber, L);

    scoreG = zeros(1, Gmax);
    best_global_score = -Inf;
    best_global_workload = [];

    %ΚΥΚΛΟΣ ΕΞΕΛΙΞΗΣ
    for g = 1:Gmax
        %Αξιολόγηση πληθυσμού
        scores = zeros(1, N);
        for p = 1:N
            W = population{p};
            scores(p) = evaluateWorkload(circuit0, W);
        end

        % Max στη γενιά -> scoreG(g)
        [best_gen_score, best_idx] = max(scores);
        scoreG(g) = best_gen_score;

        % Global best ενημέρωση
        if best_gen_score > best_global_score
            best_global_score    = best_gen_score;
            best_global_workload = population{best_idx};
        end

        %Επιλογή Γονέων (top-2)
        [parent1, parent2, ~, ~] = gaSelectParents(scores, population, N, L);
        % Ασφαλιστική δικλείδα: αν για κάποιο λόγο είναι ίδιοι, πάρε τον επόμενο καλύτερο
        if isequal(parent1, parent2)
            [~, order] = sort(scores, 'descend');
            parent2 = population{order(2)};
            if isequal(parent1, parent2) && N >= 3
                parent2 = population{order(3)};
            end
        end

        %Δημιουργία νέου πληθυσμού
        new_population = cell(1, N);
        % Elitism: κράτα τον καλύτερο της γενιάς
        new_population{1} = population{best_idx};

        % Γέμισε τα υπόλοιπα με παιδιά από parent1/parent2
        for idx = 2:2:N
            [c1, c2] = gaCrossover(parent1, parent2);
            c1 = gaMutate(c1, mutation_rate);
            c2 = gaMutate(c2, mutation_rate);

            new_population{idx} = c1;
            if idx+1 <= N
                new_population{idx+1} = c2;
            end
        end

        population = new_population;
    end

    %ΤΕΛΟΣ GA

    % Plot: x = generation, y = number of switches (max per generation)
    figure;
    plot(1:Gmax, scoreG, '-o');
    xlabel('Generation');
    ylabel('Number of switches (max per generation)');
    title(sprintf('GA Evolution (N=%d, m=%.2f, L=2)', N, mutation_rate));
    grid on;
    print('-dpng', 'ga_evolution_switches.png');

    % Save best workload
    gaSaveBestWorkload(best_global_workload, best_global_score, 'ga_best_workload.txt');
    fprintf('Best switches: %d\n', best_global_score);
end

function sc = evaluateWorkload(circuit0, W)
    % W: 2 x inputsNumber (0/1)
    c = circuit0;

    % Πρώτο διάνυσμα
    c = applyTLPInputs(c, W(1,:));
    c = process(c);
    c.SignalsBefore = c.Signals;

    % Δεύτερο διάνυσμα
    c = applyTLPInputs(c, W(2,:));
    c = process(c);

    % scoreI: πλήθος εναλλαγών (αγνοώντας TLPINPUTS)
    sc = countSwitches(c);
end

function pop = gaInitPopulation(N, inputsNumber, L)
    pop = cell(1, N);
    for i = 1:N
        pop{i} = randi([0 1], L, inputsNumber);
    end
end

function [parent1, parent2, score1, score2] = gaSelectParents(scores, population, N, L)
    best  = -Inf;  sbest  = -Inf;
    besti = -1;    sbesti = -1;

    for i = 1:numel(scores)
        if scores(i) > best
            sbest  = best;    sbesti = besti;
            best   = scores(i); besti  = i;
        elseif scores(i) >= sbest && i ~= besti
            sbest  = scores(i); sbesti = i;
        end
    end

    % Αν για κάποιο λόγο βγήκαν ίδιοι δείκτες (παρά φύση), διόρθωσέ το
    if sbesti == -1 || sbesti == besti
        % βρες τον επόμενο καλύτερο διαφορετικό
        [~, order] = sort(scores, 'descend');
        for k = 1:numel(order)
            if order(k) ~= besti
                sbesti = order(k);
                break;
            end
        end
    end

    parent1 = gaGetWorkloadFromPopulation(N, L, population, besti);
    parent2 = gaGetWorkloadFromPopulation(N, L, population, sbesti);
    score1  = best;
    score2  = sbest;
end

function W = gaGetWorkloadFromPopulation(~, ~, population, idx)
    % Ο πληθυσμός είναι cell array, κάθε κελί = 2xinputsNumber
    W = population{idx};
end

function [c1, c2] = gaCrossover(p1, p2)
    % One-point crossover πάνω στο ενωμένο genome 1x(2*inputsNumber)
    g1 = [p1(1,:), p1(2,:)];
    g2 = [p2(1,:), p2(2,:)];
    Ltot = numel(g1);
    cp = randi([1, Ltot-1]);

    gc1 = [g1(1:cp), g2(cp+1:end)];
    gc2 = [g2(1:cp), g1(cp+1:end)];

    half = Ltot/2;
    c1 = [gc1(1:half); gc1(half+1:end)];
    c2 = [gc2(1:half); gc2(half+1:end)];
end

function out = gaMutate(indiv, mutation_rate)
    out = indiv;
    for r = 1:size(out,1)
        for c = 1:size(out,2)
            if rand() < mutation_rate
                out(r,c) = 1 - out(r,c);
            end
        end
    end
end

function gaSaveBestWorkload(W, best_score, fname)
    fid = fopen(fname, 'w');
    if fid == -1
        warning('Δεν μπόρεσα να ανοίξω αρχείο για αποθήκευση: %s', fname);
        return;
    end
    fprintf(fid, "# Best workload found by GA\n");
    fprintf(fid, "# Best score: %d\n", best_score);
    fprintf(fid, "vector1:");
    fprintf(fid, " %d", W(1,:));
    fprintf(fid, "\n");
    fprintf(fid, "vector2:");
    fprintf(fid, " %d", W(2,:));
    fprintf(fid, "\n");
    fclose(fid);
end

%Loader: parse format-2 and convert names->indices
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
    rawGates = {}; % each = struct('type',..,'outName',..,'inNames',{...})
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
    circuit.ElementsSorted = [];         % to be filled by findProcessOrder
    circuit.Signals       = zeros(1, numel(signalNames));
    circuit.SignalsBefore = zeros(1, numel(signalNames));
    circuit.delays        = zeros(1, numel(signalNames));

    % Precompute order
    circuit = findProcessOrder(circuit);
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
