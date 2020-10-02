% run dlInterRbTime1 and pdschAgg3, to compare overall rb usage and inter
% rb time, which shows counter intuitive results

pdschAgg2;

dlInterRbTime0;

clc;clear;

name_postfix = {'21', '22', '23'};

for i = 1:numel(name_postfix)
    dlInterRbTime1(name_postfix{i});
    pdschAgg3(name_postfix{i});
end