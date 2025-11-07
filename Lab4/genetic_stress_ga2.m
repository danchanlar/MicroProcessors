#4.3

function genetic_stress_ga2(filename)

    N = 30;             % μέγεθος πληθυσμού
    Gmax = 100;         % αριθμός γενεών
    mutation_rate = 0.05; % 5%
    L = 2;              % μήκος φόρτου εργασίας

    try, pkg load statistics; catch, end

    % 1) Φόρτωση κυκλώματος και προετοιμασία
    circuit0 = buildCircuitFromFile(filename);
    inputsNumber = numel(circuit0.TlpInputs);

    % 2) Αρχικοποίηση πληθυσμού
    population = gaInitPopulation(N, inputsNumber, L);

    % 3) Βρόχος εξέλιξης ΓΑ
    scoreG = zeros(1, Gmax);
    best_global_score = -Inf;
    best_global_workload = [];

    for g = 1:Gmax
        % Αξιολόγηση πληθυσμού
        scores = zeros(1, N);
        for p = 1:N
            W = population{p};                  % 2 x inputsNumber
            scores(p) = evaluateWorkload(circuit0, W); % scoreI(i)
        end

        %Max στη γενιά, scoreG(g)
        [best_gen_score, best_idx] = max(scores);
        scoreG(g) = best_gen_score;

        % Global best ενημέρωση
        if best_gen_score > best_global_score
            best_global_score    = best_gen_score;
            best_global_workload = population{best_idx};
        end

        % Επιλογή δύο γονέων (top-2)
        [parent1, parent2] = gaSelectParents(scores, population);
        if isequal(parent1, parent2)
            [~, ord] = sort(scores, 'descend');
            parent2 = population{ord(2)};
            if isequal(parent1, parent2) && N >= 3
                parent2 = population{ord(3)};
            end
        end

        % Δημιουργία νέου πληθυσμού
        new_population = cell(1, N);
        new_population{1} = population{best_idx};

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

    figure;
    plot(1:Gmax, scoreG, '-o');
    xlabel('generation g');
    ylabel('scoreG(g) = #switches (max per gen)');
    title(sprintf('GA Evolution (L=2, N=%d, m=%.2f, G=%d)', N, mutation_rate, Gmax));
    grid on;
    print('-dpng', 'ga_evolution_scoreG.png');

    % 5) Αποθήκευση καλύτερου workload
    gaSaveBestWorkload(best_global_workload, best_global_score, 'ga_best_workload.txt');
    fprintf('Καλύτερο score (switches): %d\n', best_global_score);
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

    % scoreI: πλήθος εναλλαγών (αγνοούμε TLPINPUTS)
    sc = countSwitches(c);
end

function pop = gaInitPopulation(N, inputsNumber, L)
    pop = cell(1, N);
    for i = 1:N
        pop{i} = randi([0 1], L, inputsNumber);   % 2 x inputsNumber
    end
end

function [parent1, parent2] = gaSelectParents(scores, population)
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

    % Ασφάλεια: αν για κάποιο λόγο ταυτίστηκαν
    if sbesti == -1 || sbesti == besti
        [~, order] = sort(scores, 'descend');
        for k = 1:numel(order)
            if order(k) ~= besti
                sbesti = order(k);
                break;
            end
        end
    end

    parent1 = population{besti};
    parent2 = population{sbesti};
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
    fprintf(fid, "# Best score (switches): %d\n", best_score);
    fprintf(fid, "vector1:"); fprintf(fid, " %d", W(1,:)); fprintf(fid, "\n");
    fprintf(fid, "vector2:"); fprintf(fid, " %d", W(2,:)); fprintf(fid, "\n");
    fclose(fid);
end

function circuit = buildCircuitFromFile(fname)
    fid = fopen(fname, 'r');
    if fid == -1, error("Δεν βρέθηκε το αρχείο κυκλώματος: %s", fname); end

    lines = {};
    while ~feof(fid)
        ln = strtrim(fgetl(fid));
        if ischar(ln) && ~isempty(ln), lines{end+1} = ln; end %#ok<AGROW>
    end
    fclose(fid);

    % Διάβασε TLPINPUTS και τις πύλες
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

    % Συγκέντρωση όλων των σημάτων (unique, stable)
    allNames = tlpNames;
    for k = 1:numel(rawGates)
        allNames = [allNames, rawGates{k}.outName, rawGates{k}.inNames]; %#ok<AGROW>
    end
    [~, ia] = unique(allNames, 'stable');
    signalNames = allNames(sort(ia));

    % Map name->index
    name2idx = containers.Map(signalNames, num2cell(1:numel(signalNames)));

    % TLP indices
    tlpIdx = cellfun(@(s) name2idx(s), tlpNames);

    % Χτίσιμο Elements με αριθμητικούς δείκτες
    Elements = cell(1, numel(rawGates));
    for k = 1:numel(rawGates)
        g = struct();
        g.type   = rawGates{k}.type;
        g.output = name2idx(rawGates{k}.outName);
        inIdx    = zeros(1, numel(rawGates{k}.inNames));
        for j = 1:numel(rawGates{k}.inNames)
            inIdx(j) = name2idx(rawGates{k}.inNames{j});
        end
        g.inputs = num2cell(inIdx(:));   % column cell -> συμβατό με process()
        Elements{k} = g;
    end

    % Αρχικοποίηση circuit struct
    circuit.SignalNames    = signalNames;
    circuit.TlpInputs      = tlpIdx;
    circuit.Elements       = Elements;
    circuit.ElementsSorted = [];
    circuit.Signals        = zeros(1, numel(signalNames));
    circuit.SignalsBefore  = zeros(1, numel(signalNames));
    circuit.delays         = zeros(1, numel(signalNames));

    % Προϋπολογισμός σειράς εκτέλεσης
    circuit = findProcessOrder(circuit);
end

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

function updated = applyTLPInputs(obj, vec)
    if numel(vec) ~= numel(obj.TlpInputs)
        error('applyTLPInputs: wrong vector length (got %d, expected %d).', ...
              numel(vec), numel(obj.TlpInputs));
    end
    obj.Signals(obj.TlpInputs) = vec;
    updated = obj;
end

function updated = process(obj)
    obj.delays(:) = 0;
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

function switchesnumber = countSwitches(obj)
    switchesnumber = 0;
    total = numel(obj.Signals);
    mask = true(1,total);
    mask(obj.TlpInputs) = false;  % αγνόησε TLPINPUTS
    for j = 1:total
        if ~mask(j), continue; end
        if obj.SignalsBefore(j) ~= obj.Signals(j)
            switchesnumber = switchesnumber + 1;
        end
    end
end

