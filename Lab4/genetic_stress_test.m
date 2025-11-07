#4.2

function genetic_stress_test()

    P = 30;          % 30 individuals ανά γενιά
    Gmax = 50;       % αριθμός γενεών
    mutation_rate = 0.01;

    input_names = {"i1","i2","i3","i4","i5","i6","i7","i8","i9","i10", ...
                   "i11","i12","i13","i14","i15","i16","i17","i18","i19","i20"};

    gates = load_circuit_from_text();
    topo  = topo_sort(gates, input_names);

    % Αρχικοποίηση πληθυσμού
    population = cell(1,P);
    for p = 1:P
        population{p} = randi([0 1], 2, length(input_names));
    endfor

    scoreG = zeros(1,Gmax);          % μέγιστο scoreI ανά γενιά
    best_global_score = -Inf;
    best_global_individual = [];

    for g = 1:Gmax
        scores_this_gen = zeros(1,P);

        % αξιολόγηση πληθυσμού
        for p = 1:P
            W = population{p};  % 2x20

            vecA = W(1,:);
            vecB = W(2,:);

            SignalsBefore = evaluate_circuit(topo, gates, input_names, vecA);
            SignalsAfter  = evaluate_circuit(topo, gates, input_names, vecB);

            this_score = count_toggle(SignalsBefore, SignalsAfter, input_names);
            scores_this_gen(p) = this_score;
        endfor

        % κρατάμε τον καλύτερο αυτής της γενιάς
        [best_score_gen, best_idx_gen] = max(scores_this_gen);
        scoreG(g) = best_score_gen;

        % ενημερώνουμε global best
        if best_score_gen > best_global_score
            best_global_score = best_score_gen;
            best_global_individual = population{best_idx_gen}; % 2x20
        endif

        %ΕΠΙΛΟΓΗ + Crossover + Mutation για την επόμενη γενιά

        new_population = cell(1,P);

        % Elitism: κράτα τον καλύτερο της γενιάς οπως ειναι
        new_population{1} = population{best_idx_gen};

        for np = 2:2:P  % φτιάξε ζευγάρια παιδιών
            % διάλεξε δύο γονείς με tournament selection
            parentA = tournament_select(population, scores_this_gen);
            parentB = tournament_select(population, scores_this_gen);

            % crossover -> δύο παιδιά
            [child1, child2] = crossover(parentA, parentB);

            % mutation
            child1 = mutate(child1, mutation_rate);
            child2 = mutate(child2, mutation_rate);

            new_population{np}   = child1;
            if np+1 <= P
                new_population{np+1} = child2;
            endif
        endfor

        population = new_population;
    endfor

    % ===== ΤΕΛΟΣ GA =====
    % scoreG έχει το max score ανά γενιά
    % best_global_individual είναι ο φόρτος εργασίας (2x20 bits)
    % με το μεγαλύτερο score συνολικά

    figure;
    plot(1:Gmax, scoreG, 'o-');
    xlabel('generation g');
    ylabel('scoreG(g) = best toggles in gen');
    title('Genetic Algorithm stress score per generation');
    print('-dpng', 'ga_scoreG_per_generation.png');

    save_best_workload(best_global_individual, best_global_score, 'best_workload.txt');
endfunction


function parent = tournament_select(population, scores)
    % Tournament 2-way: πάρε 2 random individuals και κράτα τον καλύτερο
    P = length(population);
    a = randi(P);
    b = randi(P);
    if scores(a) >= scores(b)
        parent = population{a};
    else
        parent = population{b};
    endif
endfunction


function [c1, c2] = crossover(p1, p2)

    genome1 = [p1(1,:), p1(2,:)];
    genome2 = [p2(1,:), p2(2,:)];

    L = length(genome1);
    cp = randi([1, L-1]);

    child_genome1 = [genome1(1:cp), genome2(cp+1:end)];
    child_genome2 = [genome2(1:cp), genome1(cp+1:end)];

    c1 = [child_genome1(1:20); child_genome1(21:40)];
    c2 = [child_genome2(1:20); child_genome2(21:40)];
endfunction


function mutant = mutate(individual, mutation_rate)
    % individual: 2x20
    mutant = individual;
    for r = 1:2
        for c = 1:20
            if rand() < mutation_rate
                mutant(r,c) = 1 - mutant(r,c); % flip bit
            endif
        endfor
    endfor
endfunction


function save_best_workload(best_individual, best_score, filename)
    % best_individual: 2x20 bits (γραμμή 1 = πρώτο διάνυσμα, γραμμή 2 = δεύτερο)
    fid = fopen(filename, 'w');
    if fid == -1
        error("Could not open file to save best workload");
    endif

    fprintf(fid, "# Best workload found by GA\n");
    fprintf(fid, "# Best score: %d\n", best_score);
    fprintf(fid, "# Format: each line is i1..i20 for one vector\n");

    vecA = best_individual(1,:);
    vecB = best_individual(2,:);

    fprintf(fid, "vector1: ");
    for k=1:length(vecA)
        fprintf(fid, "%d", vecA(k));
        if k < length(vecA), fprintf(fid, " "); endif
    endfor
    fprintf(fid, "\n");

    fprintf(fid, "vector2: ");
    for k=1:length(vecB)
        fprintf(fid, "%d", vecB(k));
        if k < length(vecB), fprintf(fid, " "); endif
    endfor
    fprintf(fid, "\n");

    fclose(fid);
endfunction


% Load circuit from text (Format-2). If no filename is given, uses 'circuit.txt'.
function gates = load_circuit_from_text(varargin)
    if nargin >= 1
        fname = varargin{1};
    else
        fname = 'circuit.txt';
    end
    fid = fopen(fname, 'r');
    if fid == -1
        error("load_circuit_from_text: could not open %s", fname);
    end

    lines = {};
    while ~feof(fid)
        ln = fgetl(fid);
        if ischar(ln)
            ln = strtrim(ln);
            if ~isempty(ln) && ln(1) ~= '#'
                lines{end+1} = ln; %#ok<AGROW>
            end
        end
    end
    fclose(fid);

    gates = struct('type', {}, 'out', {}, 'ins', {});
    for k = 1:numel(lines)
        toks = strsplit(lines{k}, ' ');
        if strcmpi(toks{1}, 'TLPINPUTS')
            % ignore here; you pass input_names separately into genetic_stress_test
            continue;
        end
        gt.type = upper(toks{1});
        gt.out  = toks{2};
        gt.ins  = toks(3:end);
        gates(end+1) = gt; %#ok<AGROW>
    end
endfunction

% Topological sort of gates given known primary input names.
% Returns 'topo': indices into 'gates' in a valid evaluation order.
function topo = topo_sort(gates, input_names)
    known = containers.Map(input_names, num2cell(true(1,numel(input_names))));
    n = numel(gates);
    used = false(1, n);
    topo = [];

    progressed = true;
    while numel(topo) < n && progressed
        progressed = false;
        for i = 1:n
            if used(i), continue; end
            ins = gates(i).ins;
            ok = true;
            for j = 1:numel(ins)
                if ~isKey(known, ins{j})
                    ok = false; break;
                end
            end
            if ok
                topo(end+1) = i; %#ok<AGROW>
                used(i) = true;
                known(gates(i).out) = true;   % its output becomes known
                progressed = true;
            end
        end
    end

    if numel(topo) < n
        error('topo_sort: cannot resolve order (cycle or missing driver).');
    end
endfunction

% Evaluate circuit once for a given input vector (0/1 for each input_names).
% Returns a containers.Map of signal->value (includes inputs, internals, outputs).
function sigmap = evaluate_circuit(topo, gates, input_names, vec)
    if numel(vec) ~= numel(input_names)
        error('evaluate_circuit: input vector length mismatch.');
    end
    % initialize signals with inputs
    sigmap = containers.Map();
    for i = 1:numel(input_names)
        sigmap(input_names{i}) = double(vec(i) ~= 0);
    end

    % evaluate in topo order
    for t = topo
        ins = gates(t).ins;
        vin = zeros(1, numel(ins));
        for j = 1:numel(ins)
            if ~isKey(sigmap, ins{j})
                error('evaluate_circuit: missing driver for %s', ins{j});
            end
            vin(j) = sigmap(ins{j});
        end
        y = eval_gate(gates(t).type, vin);
        sigmap(gates(t).out) = y;
    end
endfunction

% Count toggles between two signal maps, excluding primary inputs.
function toggles = count_toggle(sigBefore, sigAfter, input_names)
    % Build set of all names
    allNames = keys(sigBefore);
    namesB = keys(sigAfter);
    % unify
    set = containers.Map();
    for i = 1:numel(allNames), set(allNames{i}) = true; end
    for i = 1:numel(namesB),   set(namesB{i})   = true; end
    unames = keys(set);

    % mark inputs
    isInput = containers.Map(input_names, num2cell(true(1,numel(input_names))));

    toggles = 0;
    for i = 1:numel(unames)
        name = unames{i};
        if isKey(isInput, name), continue; end
        vb = 0; if isKey(sigBefore, name), vb = sigBefore(name); end
        va = 0; if isKey(sigAfter,  name), va = sigAfter(name);  end
        if vb ~= va
            toggles = toggles + 1;
        end
    end
endfunction

% ---------------------- gate evaluator (boolean) ------------------------
function y = eval_gate(type, vin)
    switch upper(type)
        case 'AND',   y = double(all(vin == 1));
        case 'OR',    y = double(any(vin == 1));
        case 'NAND',  y = double(~all(vin == 1));
        case 'NOR',   y = double(~any(vin == 1));
        case 'XOR',   y = double(mod(sum(vin), 2));
        case 'XNOR',  y = double(~mod(sum(vin), 2));
        case 'NOT'
            if numel(vin) ~= 1, error('NOT expects 1 input'); end
            y = double(~vin(1));
        case 'BUF'
            if numel(vin) ~= 1, error('BUF expects 1 input'); end
            y = double(vin(1));
        otherwise
            error('Unknown gate type: %s', type);
    end
endfunction

