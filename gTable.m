% generate table
% generate the table of input and output for machine learning

clear;clc;
rb = 25; % the rb to predict
history = 10; % TTIs to consider
radius = 0; % how many adjacent RBs to consider
shift = 15000; % where does the data start from
N = 10000; % total size of data, including training and validation
hour = 9;
f_prefix = 'dlOcH_';

load(sprintf('%s%02d.mat', f_prefix, hour));
load('dciProcessed.mat', 'hour_seq');
load('nofDCI.mat', 'hour_dci');

theTable = -ones(N, (radius*2+1)*history+3);
occu = reshape(occupancy, 50, numel(occupancy)/50);
occu = occu';
for i = 1:history
    occup = occu((1:N)+shift-(i-1), :);
    occup = occup(:, (rb-radius):(rb+radius));
    e_idx = (radius*2+1)*history-(i-1)*(radius*2+1);
    s_idx = e_idx - (radius*2+1-1);
    theTable(:, s_idx:e_idx) = occup;
end

theTable(:, end) = double(occu((1:N)+1+shift, rb)>0);
% theTable = double(theTable>0);
% [trainedClassifier, validationAccuracy] = trainClassifier(theTable);
% classificationLearner;