% analyze on, off, and interval length distributions for an RB, or channel
% the continuous version
clc;
clearvars -except hour_rb_inter_usage;
if 1 ~= exist('hour_rb_inter_usage', 'var')
    clc;clear;
    load dlInterRb.mat;
end

distributions = ["Exponential" "GeneralizedPareto" "Weibull" "Gamma" "Lognormal"];
nof_dist = numel(distributions);

hour = 1:24;
rb_idx = 29;

% ulOn = zeros(24*nof_dist, 6); % 3 for kstest, 3 for fitting parameters
% ulOff = zeros(24*nof_dist, 6); % 3 for kstest, 3 for fitting parameters
% ulInter = zeros(24*nof_dist, 6); % 3 for kstest, 3 for fitting parameters
dlOn = -ones(24*nof_dist, 7)*NaN; % 4 for kstest, 3 for fitting parameters
dlOff = -ones(24*nof_dist, 7)*NaN; % 4 for kstest, 3 for fitting parameters
dlInter = -ones(24*nof_dist, 7)*NaN; % 4 for kstest, 3 for fitting parameters

for i = 1:24
    nof_record = hour_rb_inter_usage{hour(i),1}(rb_idx);
    nof_record = nof_record/2;
    offTime = hour_rb_inter_usage{hour(i),2}(rb_idx, 1:nof_record);
    interval = hour_rb_inter_usage{hour(i),2}( rb_idx,(nof_record+1):2*nof_record);
    onTime = interval - offTime;
    offTime = offTime';
    interval = interval';
    onTime = onTime';
    for j = 1:nof_dist
        i
        j
        pd = fitdist(offTime, char(distributions(j)));
        test_cdf = [offTime, cdf(pd, offTime)];
        [dlOff((i-1)*nof_dist+j,1), dlOff((i-1)*nof_dist+j,2), dlOff((i-1)*nof_dist+j,3), dlOff((i-1)*nof_dist+j,4)] = kstest(offTime, 'CDF', test_cdf);
        for k = 1:pd.NumParameters
            dlOff((i-1)*nof_dist+j, 4+k) = pd.(pd.ParameterNames{k});
        end
        
        pd = fitdist(interval, char(distributions(j)));
        test_cdf = [interval, cdf(pd, interval)];
        [dlInter((i-1)*nof_dist+j,1), dlInter((i-1)*nof_dist+j,2), dlInter((i-1)*nof_dist+j,3), dlInter((i-1)*nof_dist+j,4)] = kstest(interval, 'CDF', test_cdf);
        for k = 1:pd.NumParameters
            dlInter((i-1)*nof_dist+j, 4+k) = pd.(pd.ParameterNames{k});
        end
        
        pd = fitdist(onTime, char(distributions(j)));
        test_cdf = [onTime, cdf(pd, onTime)];
        [dlOn((i-1)*nof_dist+j,1), dlOn((i-1)*nof_dist+j,2), dlOn((i-1)*nof_dist+j,3), dlOn((i-1)*nof_dist+j,4)] = kstest(onTime, 'CDF', test_cdf);
        for k = 1:pd.NumParameters
            dlOn((i-1)*nof_dist+j, 4+k) = pd.(pd.ParameterNames{k});
        end
    end
end

save('dldist', 'distributions', 'dlOff', 'dlInter', 'dlOn');