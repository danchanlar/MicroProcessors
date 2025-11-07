#Run Experiments
N_values = [10, 100, 5281, 5386];

printf("\n--- Monte Carlo Switching Activity Results ---\n");
printf("%10s | %10s %10s %10s | %10s %10s %10s\n", ...
       "N", "Sw_d", "Sw_e", "Sw_f", "Act_d", "Act_e", "Act_f");
printf("%s\n", repmat("-",1,90));

for i = 1:length(N_values)
    N = N_values(i);
    [Switches, Activity] = MCSCHEMATIC1(N);

    printf("%10d | %10d %10d %10d | %10.4f %10.4f %10.4f\n", ...
        N, ...
        Switches.d, Switches.e, Switches.f, ...
        Activity.d, Activity.e, Activity.f);
endfor
