function [Switches, SwitchingActivity] = MCSCHEMATIC1(N)
    if nargin < 1
        N = 100;
    end

    Workload = [0 0 0; 1 1 1];

    Workload = [Workload; round(rand(N,3))];

    vectorsNumber = size(Workload,1);

    # Initialize
    prev_d = 0;
    prev_e = 0;
    prev_f = 0;
    switch_d = 0;
    switch_e = 0;
    switch_f = 0;

    # Process all input vectors
    for i = 1:vectorsNumber
        a = Workload(i,1);
        b = Workload(i,2);
        c = Workload(i,3);

        # Circuit definition with internal signals
        e = sp2AND(a, b);
        f = spNOT(c);
        d = sp2AND(e, f);

        # Count switches for each signal
        if i > 1
            if d ~= prev_d
                switch_d = switch_d + 1;
            end
            if e ~= prev_e
                switch_e = switch_e + 1;
            end
            if f ~= prev_f
                switch_f = switch_f + 1;
            end
        end

        # Update previous values
        prev_d = d;
        prev_e = e;
        prev_f = f;
    endfor

    # Compute switching activity for each signal
    act_d = switch_d / vectorsNumber;
    act_e = switch_e / vectorsNumber;
    act_f = switch_f / vectorsNumber;

    # Return structure
    Switches = struct('d', switch_d, 'e', switch_e, 'f', switch_f);
    SwitchingActivity = struct('d', act_d, 'e', act_e, 'f', act_f);
endfunction

#Logic Gate Functions
function s = sp2AND(x,y)
    s = x*y;
endfunction

function s = spNOT(x)
    s = 1 - x;
endfunction
