N_values = [10, 20, 30, 5386];
SwitchingResults = zeros(size(N_values));
exampleTrace = [];

for i = 1:numel(N_values)
    N = N_values(i);
    [result, trace] = MCOR4(N);
    SwitchingResults(i) = result;
    if i == 1, exampleTrace = trace; end

    fprintf('N = %d -> Switching Activity = %.6f\n', N, result);
end

% Plot- Switching activity vs N
figure(1); clf;
plot(N_values, SwitchingResults, '-o', 'LineWidth', 1.5, 'MarkerSize', 6);
title('Switching Activity for a 4-input OR gate');
xlabel('Monte Carlo input vectors (N)');
ylabel('Switching Activity');
grid on;
ylim([0 1]);


