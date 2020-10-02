% resource block compare
% compare the LTE resource block usage between
% the measured result obtained by DCI decoding
% and the actual RB usage according to Amarisoft eNB log
clc; clear;

nrb = 25;

mrb0 = dlmread('mrb0.txt');
mrb1 = dlmread('mrb1.txt');
asul = dlmread('asul.txt');
asdl = dlmread('asdl.txt');

measUl0 = mrb0(:, (nrb+2) : (2*nrb+1));
measDl0 = mrb0(:, 2 : (nrb+1));
meastti0 = mrb0(:,1);

measUl1 = mrb1(:, (nrb+2) : (2*nrb+1));
measDl1 = mrb1(:, 2 : (nrb+1));
meastti1 = mrb1(:,1);

asUltti = asul(:,2);
asDltti = asdl(:,2);

asul(:, [1 2]) = [];
asdl(:, [1 2]) = [];

[meas0Ulrate, size0Ul] = get_rate(meastti0, asUltti, measUl0, asul);

[meas0Dlrate, size0Dl] = get_rate(meastti0, asDltti, measDl0, asdl);

[meas1Ulrate, size1Ul] = get_rate(meastti1, asUltti, measUl1, asul);

[meas1Dlrate, size1Dl] = get_rate(meastti1, asDltti, measDl1, asdl);

dlUsage = sum(sum(asdl))/numel(asdl);
ulUsage = sum(sum(asul))/numel(asul);