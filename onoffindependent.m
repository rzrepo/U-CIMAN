% check if on time is independent of the previous off time
if 1 ~= exist('hour_rb_inter_usage', 'var')
    clc;clear;
    load dlInterRb.mat;
end
hour = 11;
rb_idx = 29;
nof_record = hour_rb_inter_usage{hour,1}(rb_idx);
nof_record = nof_record/2;
%nof_record = 338161;
offTime = hour_rb_inter_usage{hour,2}(rb_idx, 1:nof_record);
interval = hour_rb_inter_usage{hour,2}( rb_idx,(nof_record+1):2*nof_record);
onTime = interval - offTime;

nof_onTime_bins = 20;
nof_offTime_bins = 20;

[off_time_counts,off_time_centers] = hist(offTime,nof_offTime_bins);
off_time_p = off_time_counts/nof_record;

[on_time_counts,on_time_centers] = hist(onTime,nof_onTime_bins);
on_time_p = on_time_counts/nof_record;

jointp = zeros(nof_offTime_bins,nof_onTime_bins);
check_same = zeros(nof_offTime_bins,4);

for i = 1:nof_offTime_bins
    if i == 1
        offTime_idx = offTime<mean(off_time_centers([1,2]));
    else
        if i ~= nof_offTime_bins            
            offTime_idx = offTime<mean(off_time_centers([i,i+1])) & offTime>=mean(off_time_centers([i,i-1]));
        else
            offTime_idx = offTime>=mean(off_time_centers([end-1,end]));
        end
    end
    onTime_subset = onTime(offTime_idx);
    size_onTime_subset = sum(onTime_subset>0);
    for j = 1:nof_onTime_bins        
        if j ~= nof_onTime_bins
            onTime_idx = onTime_subset<mean(on_time_centers([j,j+1]));
        else
            onTime_idx = onTime_subset>=mean(on_time_centers([end-1,end]));
        end
        jointp(i,j) = sum(onTime_idx)/size_onTime_subset;
    end
    [check_same(i,1), check_same(i,2), check_same(i,3)]= kstest2(onTime_subset,onTime);
    check_same(i,4) = size_onTime_subset/nof_record;
end
% 
% [f,x] = ecdf(offTime);
% f = 1-f;
% % 
% % figure;
% % hold on; grid on;
% % plot(x,f);
% % legend();
% % 
% % idx = find(f<0.0001, 1, 'first');
% % offTime(offTime>x(idx))=[];
% % 
% % % pd = fitdist(onTime','Exponential');
% % % pd = fitdist(onTime', 'GeneralizedPareto');
% % % pd = fitdist(onTime', 'Weibull');
% % % pd = fitdist(onTime','Gamma');
% % pd = fitdist(offTime', 'GeneralizedPareto'); % for on time idle hours
% % x_icdf = 0:max(offTime);
% % y = 1 - cdf(pd,x_icdf);
% % 
% % plot(x_icdf,y);
% % 
% % pd = fitdist(offTime', 'GeneralizedExtremeValue');
% % x_icdf = 0:max(offTime);
% % y = 1 - cdf(pd,x_icdf);
% % plot(x_icdf,y);
% % 
% % pd = fitdist(offTime', 'Exponential');
% % x_icdf = 0:max(offTime);
% % y = 1 - cdf(pd,x_icdf);
% % plot(x_icdf,y);
% % 
% % 
% % % 'Beta'
% % % 'Binomial'
% % % 'BirnbaumSaunders'
% % % 'Burr'
% % % 'ExtremeValue'
% % % 'GeneralizedExtremeValue'
% % % 'GeneralizedPareto'
% % % 'HalfNormal'
% % % 'InverseGaussian'
% % % 'Kernel'
% % % 'Logistic'
% % % 'Loglogistic'
% % % 'Lognormal'
% % % 'Nakagami'
% % % 'Normal'
% % % 'Poisson'
% % % 'Rayleigh'
% % % 'Rician'
% % % 'Stable'
% % % 'tLocationScale'
% % % 'Weibull'
% % 
% % % set(gca, 'XScale', 'log');
% %  set(gca, 'YScale', 'log');
% % legend;