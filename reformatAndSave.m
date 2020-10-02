% reformat hour_cell into 24 files each storing channel occupancy of a
% single hour

% DL user ID occupancy file dlrbcellprocessed.mat, var name: hour_cell
% DL MCS occupancy file v2hourcell.mat, var name: hour_cell

fileName = 'v2hourcell.mat';
varName = 'hour_cell';

if ~exist(varName, 'var')
    clearvars('-except', 'fileName', 'varName');
    clc;
    load(fileName, varName);
else
    clearvars('-except', varName);
    clc;
end

namePrefix = 'dlOcHV2';

for i = 1:24
    fileName = sprintf('%s_%02d.mat', namePrefix, i);
    occupancy = hour_cell{i,2};
    save(char(fileName), 'occupancy');
end