% time series analysis for on/off dl
for h = 7:7
    
clc;
clearvars -except hour_cell h;


if 1 ~= exist('hour_cell', 'var')
    load('dlInterRb.mat', 'hour_cell');
end

rng('default');
rng(1);

nof_rb = hour_cell{h,1};
usageData = hour_cell{h,2}(:, 1:nof_rb);
usageData = double(usageData>0)';
fitChannel = 10;
lag = [1 2 3 4 8 12];
fitLength = 10000;
lc = numel(lag); % number of lags to try
logL = zeros(1, lc);
np = zeros(1, lc);
VAR = cell(1,lc);
EstMdl = cell(1,lc);
EstParamCov = cell(1,lc);
info = cell(1,lc);
results = cell(1,lc);
% fitData = usageData(1:fitLength, 1:fitChannel);
fitData = usageData((1:fitLength)+50000, 1:fitChannel);
% fitData = usageData((1:fitLength), 1:fitChannel);
for i = 1:lc
    VAR{i} = varm(fitChannel, lag(i));
    try
        [EstMdl{i}, EstParamCov{i}, logL(i), info{i}] = estimate(VAR{i}, fitData);
        results{i} = summarize(EstMdl{i});
        np(i) = results{i}.NumEstimatedParameters;
    catch
        np(i) = 999999999;
    end
end
AIC = aicbic(logL, np);
[~, bestFitIdx] = min(AIC);
    
syntheticAR = simulate(EstMdl{bestFitIdx}, fitLength);
% syntheticAR = simulate(EstMdl{4}, fitLength);
onePercent = sum(sum(fitData))/numel(fitData);
Y = prctile(syntheticAR(:), (1-onePercent)*100);
syntheticAR = syntheticAR > Y;
onePercentF = sum(sum(syntheticAR))/numel(syntheticAR);
syntheticOffOnAR = getOffOn(syntheticAR);

fitDataOffOn = getOffOn(fitData); % get the off on interval from 0 1
offOnModel = getOnOffDist(fitDataOffOn); % get the best off on model
% get the synthetic data
% this may not be of the same  size of original data, needs to be trimmed
syntheticOffOnD = synth(offOnModel, fitLength, fitChannel);

% off/on interval length same distribution?
cmpOffD = zeros(fitChannel, 3);
cmpOnD = zeros(fitChannel, 3);
cmpIntD = zeros(fitChannel, 3);
cmpOffAR = zeros(fitChannel, 3);
cmpOnAR = zeros(fitChannel, 3);
cmpIntAR = zeros(fitChannel, 3);
for i = 1:fitChannel
    [cmpOffD(i,1), cmpOffD(i,2), cmpOffD(i,3)] = kstest2(fitDataOffOn{2*i-1}, syntheticOffOnD{2*i-1});
    [cmpOnD(i,1), cmpOnD(i,2), cmpOnD(i,3)] = kstest2(fitDataOffOn{2*i}, syntheticOffOnD{2*i});
    [cmpIntD(i,1), cmpIntD(i,2), cmpIntD(i,3)] = kstest2(fitDataOffOn{2*i} + fitDataOffOn{2*i-1}, syntheticOffOnD{2*i} + syntheticOffOnD{2*i-1});
    [cmpOffAR(i,1), cmpOffAR(i,2), cmpOffAR(i,3)] = kstest2(fitDataOffOn{2*i-1}, syntheticOffOnAR{2*i-1});
    [cmpOnAR(i,1), cmpOnAR(i,2), cmpOnAR(i,3)] = kstest2(fitDataOffOn{2*i}, syntheticOffOnAR{2*i});
    [cmpIntAR(i,1), cmpIntAR(i,2), cmpIntAR(i,3)] = kstest2(fitDataOffOn{2*i} + fitDataOffOn{2*i-1}, syntheticOffOnAR{2*i} + syntheticOffOnAR{2*i-1});
end

% correlation of off/on interval length similar?
oriOffOnCorr = zeros(1,10);
synAROffOnCorr = zeros(1,10);
synDOffOnCorr = zeros(1,10);
for i = 1:fitChannel
    tmp = corrcoef(fitDataOffOn{2*i-1}, fitDataOffOn{2*i});
    oriOffOnCorr(i) = tmp(1,2);
    tmp = corrcoef(syntheticOffOnD{2*i-1}, syntheticOffOnD{2*i});
    synDOffOnCorr(i) = tmp(1,2);
    tmp = corrcoef(syntheticOffOnAR{2*i-1}, syntheticOffOnAR{2*i});
    synAROffOnCorr(i) = tmp(1,2);
end

% correlation of adjacent channels similar?
oriChannCorr = corrcoef(fitData);
synARChannCorr = corrcoef(syntheticAR);
synDChannCorr = corrcoef(get01(syntheticOffOnD, fitLength));

fileName = ['dlTimeSA' num2str(h,'%d')];
save(fileName);
end