% resource block compare
% compare the LTE resource block usage between
% the measured result obtained by DCI decoding
% and the actual RB usage according to Amarisoft eNB log
clc; clear;

nrb = 25;

% load('rbu_2018-03-08_22.06.00.048.mat');
load('rbu_2018-03-08_22.06.05.843.mat');
mrb = ten_sec_usage;
asul = dlmread('607asul.txt');
asdl = dlmread('607asdl.txt');

measUl = mrb(:, (nrb+2) : (2*nrb+1));
measDl = mrb(:, 2 : (nrb+1));
meastti = mrb(:,1);

asUltti = asul(:,2);
asDltti = asdl(:,2);

asul(:, [1 2]) = [];
asdl(:, [1 2]) = [];

[measUlrate, sizeUl] = get_rate(meastti, asUltti, measUl, asul);

[measDlrate, sizeDl] = get_rate(meastti, asDltti, measDl, asdl);

dlUsage = sum(sum(asdl))/numel(asdl);
ulUsage = sum(sum(asul))/numel(asul);