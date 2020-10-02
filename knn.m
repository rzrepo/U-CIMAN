% knn prediction based segmentation
% prediction accurarcy
% segment lengths distribution
% segment effects on fitting accuracy

clc;
clearvars -except hour_cell hour_rb_inter_usage;
if 1 ~= exist('hour_cell', 'var')
    clc;clear;
    load('dlInterRb.mat', 'hour_cell', 'hour_rb_inter_usage');
end

rng(10);

adjChn = [1 3];
history = [4 8 12 16];
nof_data = 10000;
chn = 25;
acc = zeros(numel(adjChn)*numel(history), 24);

for i = 1:numel(adjChn)
    for j = 1:numel(history)
        for h = 1:24
            [X, Y, tX, tY] = gentable(hour_cell, h, nof_data, adjChn(i), history(j), chn);
            Mdl = fitcknn(X, Y, 'NumNeighbors', 6);
            pdct = predict(Mdl,tX);
            acc((i-1)*numel(history)+j, h) = 1 - sum(abs(pdct-tY))/(nof_data*0.2);
        end        
    end
end

% acc(:,10)'= 0.5040    0.6255    0.5020    0.5910    0.5235    0.6250    0.5130    0.5940 when k=1
% acc(:,10)'= 0.5040    0.6255    0.6045    0.5910    0.5220    0.6350    0.6120    0.5960 when k=2
% acc(:,10)'= 0.5040    0.6255    0.6045    0.5910    0.5220    0.6345    0.6120    0.5990 when k=3
% acc(:,10)'= 0.6495    0.6255    0.6045    0.5910    0.6565    0.6355    0.6120    0.6005 when k=4
% acc(:,10)'= 0.5040    0.6255    0.6045    0.5910    0.5220    0.6345    0.6120    0.5990 when k=5

function [X, Y, tX, tY] = gentable(hour_cell, h, nof_data, i, j, chn)
    data = hour_cell{h,2}((chn-(i-1)/2):(chn+(i-1)/2), 1:(nof_data+j));
    data(data>0) = 1;
    allY = data((i+1)/2, (1+j):end);
    Y = allY(1:nof_data*0.8); Y = Y';
    tY = allY((nof_data*0.8+1):end); tY = tY';
    allX = data(:,1:nof_data);
    X = allX(:,1:nof_data*0.8); X = X';
    tX = allX(:,(nof_data*0.8+1):end); tX = tX';
end