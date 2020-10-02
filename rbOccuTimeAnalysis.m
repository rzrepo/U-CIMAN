% analyze on time and off time length
%function rbOccuTimeAnalysis(hour, rb_idx, hour_rb_inter_usage)
%end
hour = 11;
rb_idx = 29;
nof_record = hour_rb_inter_usage{hour,1}(rb_idx);
nof_record = nof_record/2;
offTime = hour_rb_inter_usage{hour,2}(rb_idx, 1:nof_record);
interval = hour_rb_inter_usage{hour,2}( rb_idx,(nof_record+1):2*nof_record);
onTime = interval - offTime;

[off_time_counts,off_time_centers] = hist(offTime);
off_time_p = off_time_counts/nof_record;


[on_time_counts,on_time_centers] = hist(onTime);

[f,x] = ecdf(offTime);
f = 1-f;
% 
% figure;
% hold on; grid on;
% plot(x,f);
% legend();
% 
% idx = find(f<0.0001, 1, 'first');
% offTime(offTime>x(idx))=[];
% 
% % pd = fitdist(onTime','Exponential');
% % pd = fitdist(onTime', 'GeneralizedPareto');
% % pd = fitdist(onTime', 'Weibull');
% % pd = fitdist(onTime','Gamma');
% pd = fitdist(offTime', 'GeneralizedPareto'); % for on time idle hours
% x_icdf = 0:max(offTime);
% y = 1 - cdf(pd,x_icdf);
% 
% plot(x_icdf,y);
% 
% pd = fitdist(offTime', 'GeneralizedExtremeValue');
% x_icdf = 0:max(offTime);
% y = 1 - cdf(pd,x_icdf);
% plot(x_icdf,y);
% 
% pd = fitdist(offTime', 'Exponential');
% x_icdf = 0:max(offTime);
% y = 1 - cdf(pd,x_icdf);
% plot(x_icdf,y);
% 
% 
% % 'Beta'
% % 'Binomial'
% % 'BirnbaumSaunders'
% % 'Burr'
% % 'ExtremeValue'
% % 'GeneralizedExtremeValue'
% % 'GeneralizedPareto'
% % 'HalfNormal'
% % 'InverseGaussian'
% % 'Kernel'
% % 'Logistic'
% % 'Loglogistic'
% % 'Lognormal'
% % 'Nakagami'
% % 'Normal'
% % 'Poisson'
% % 'Rayleigh'
% % 'Rician'
% % 'Stable'
% % 'tLocationScale'
% % 'Weibull'
% 
% % set(gca, 'XScale', 'log');
%  set(gca, 'YScale', 'log');
% legend;