function offOnModel = getOnOffDist(fitDataOffOn)
% get the best distributions for off time and on time
    distributions = ["Exponential"  "Weibull"  "Lognormal" "GeneralizedPareto" "Gamma"];
    nof_dist = numel(distributions);
    offOnModel = cell(1,2);
    [~, c] = size(fitDataOffOn);
    onTime = [];
    offTime = [];
    lc = c/2;
    for i = 1:lc
        onTime = [onTime fitDataOffOn{2*i-1}];
        offTime = [offTime fitDataOffOn{2*i}];
    end
    offFitR = zeros(1, nof_dist);
    onFitR = zeros(1, nof_dist);
    offTime = offTime';
    onTime = onTime';
    for i = 1:nof_dist                  
        try
            pd = fitdist(offTime, char(distributions(i)));
            g = pd.random(1, numel(offTime));
            g = ceil(g);
            [~, ~, offFitR(i)] = kstest2(offTime, g);
        catch
            offFitR(i) = 1;
        end
        
        try
            pd = fitdist(onTime, char(distributions(i)));
            g = pd.random(1, numel(onTime));
            g = ceil(g);
            [~, ~, onFitR(i)] = kstest2(onTime, g);
        catch
            onFitR(i) = 1;
        end
    end
    [~, offIdx] = min(offFitR);
    [~, onIdx] = min(onFitR);
    offOnModel{1} = fitdist(offTime, char(distributions(offIdx)));
    offOnModel{2} = fitdist(onTime, char(distributions(onIdx)));
end