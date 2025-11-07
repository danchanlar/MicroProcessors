function MCpi()

    r = 1;  % circle radius
    a = 2 * r;  % square side
    Nsets = {[10,100,1000,5386,10000], [10,100,1000,5281,10000]};   % 2 sets Í
    for s = 1:length(Nsets)
        Nvalues = Nsets{s};
        fprintf('\n=== Execution %d ===\n', s);
        results = zeros(size(Nvalues));

        for i = 1:length(Nvalues)
            N = Nvalues(i);

            % create random points in the square [-r, r] x [-r, r]
            x = (rand(1, N) * 2 * r) - r;
            y = (rand(1, N) * 2 * r) - r;

            % calculate the points inside the circle
            inside = (x.^2 + y.^2) <= r^2;
            count_inside = sum(inside);

            % estimate pi
            pi_est = 4 * (count_inside / N);
            results(i) = pi_est;

            fprintf('N = %5d  -->  Calculated pi = %.6f\n', N, pi_est);
        end

        figure(s);
        plot(Nvalues, results, '-o', 'LineWidth', 1.5);
        title(sprintf('Approximation of pi with Monte Carlo (Set %d)', s));
        xlabel('Number of points N');
        ylabel('Approached pi');
        grid on;
        ylim([2.5 3.8]);

        hold on;
        plot(xlim, [pi pi], '--r');
        text(max(xlim)*0.9, pi + 0.02, 'pi = 3.1416', 'Color', 'r');
        hold off;
    end
end

