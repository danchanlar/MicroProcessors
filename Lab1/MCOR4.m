function [SwitchingActivity, outputTrace] = MCOR4(N)

    Workload = [0 0 0 0;
                1 1 1 1;
                0 0 0 1;
                1 1 1 1;
                0 1 0 1];

    Workload = [Workload; randi([0 1], N, 4)];
    outputTrace = any(Workload, 2);
    switchesNumber = sum(diff(outputTrace) ~= 0);
    vectorsNumber = size(Workload, 1);
    SwitchingActivity = switchesNumber / max(vectorsNumber - 1, 1);
end

