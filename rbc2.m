% resource block compare
% compare the LTE resource block usage between
% the measured result obtained by DCI decoding
% and the actual RB usage according to Amarisoft eNB log

% This version checks if there is time offset in TTI between the two
clc; clear;

nrb = 25;
lineLength = 108;

asul = dlmread('asul.txt');
asdl = dlmread('asdl.txt');
asul(:, [1 2]) = [];
asdl(:, [1 2]) = [];
asUltti = asul(:,2);
asDltti = asdl(:,2);

errorRateUl = ones(2,30);
errorRateDl = ones(2,30);

offsetCount = 0;

fid0 = fopen('mrb0.txt');
formatSpec = '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f';
numLines = ceil(size(asul,1)/2) - 100;
while true
    offsetCount = offsetCount + 1
    C = textscan(fid0,formatSpec, numLines);
    mrb0 = cell2mat(C);
    if size(mrb0, 1) < numLines
        break
    end
    pos = ftell(fid0);
    fseek(fid0, pos-lineLength*(numLines-1),'bof');
    measUl0 = mrb0(:, (nrb+2) : (2*nrb+1));
    measDl0 = mrb0(:, 2 : (nrb+1));
    meastti0 = mrb0(:,1);
    [meas0Ulrate, size0Ul] = get_rate2(meastti0, asUltti, measUl0, asul);
    errorRateUl = processRate(errorRateUl, meas0Ulrate, offsetCount);
    [meas0Dlrate, size0Dl] = get_rate2(meastti0, asDltti, measDl0, asdl);
    errorRateDl = processRate(errorRateDl, meas0Dlrate, offsetCount);
    if meas0Ulrate < 0.05
        meas0Ulrate
        offsetCount
    end
    if meas0Dlrate < 0.05
        meas0Dlrate
        offsetCount
    end    
end
save;