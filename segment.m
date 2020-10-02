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

chn = 25;
theCC = 3;
theH = 4;
theK = 4;

segments = cell(1,24);
lambda = 100;
epsilon = 0.9;

for h = 1:24
    channelData = hour_cell{h,2}((chn-(theCC-1)/2):(chn+(theCC-1)/2), :);
    nof_points = hour_cell{h,1}-theH; % can be made smaller here
    T_idx1 = 1;
    T_idx2 = 1;
    while true
        M = 1;
        ss = []; % to store all s in a segment
        while true
            if T_idx2 > nof_points
                break;
            end
            s = strangeness(T_idx1, T_idx2, channelData, theK, theH, theCC);
            ss = [ss s];
            theta = rand(1);
            p = (sum(ss>s) + theta*sum(ss == s))/(T_idx2 - T_idx1 + 1);
            M = M*epsilon*p^(epsilon-1);
            if M > lambda
                segments{h} = [segments{h} T_idx2];
                T_idx2 = T_idx2 + 1;
                T_idx1 = T_idx2;
                break;
            else
                T_idx2
                T_idx2 = T_idx2 + 1;
            end
        end
        if T_idx2 > nof_points
            break;
        end
    end
end


function s = strangeness(T_idx1, T_idx2, channelData, theK, theH, theCC)
    if T_idx2 <= T_idx1 + 2*theK
        s = 0;
    else
        sdata = channelData(:,T_idx1:(T_idx2+theH));
        sdata(sdata>0) = 1;
        ys = sdata((theCC-1)/2, (1+theH):(end-1));
        n0ys = sum(ys==0);
        n1ys = sum(ys==1);
        if n0ys < theH || n1ys < theH
            s = 0;
        else
            y = sdata((theCC-1)/2, end);
            x = sdata(:, (end-theH):(end-1));
            d0s = zeros(1,n0ys);
            d1s = zeros(1,n1ys);
            index0 = 1;
            index1 = 1;
            for i = 1:(T_idx2 - T_idx1 - 1)
                xi = sdata(:, i:(i+theH-1));
                yi = sdata((theCC-1)/2, i+theH);
                distance = sqrt(sum(sum((x-xi).*(x-xi))));
                if yi == 0
                    d0s(index0) = distance;
                    index0 = index0 + 1;
                else
                    d1s(index1) = distance;
                    index1 = index1 + 1;
                end
            end
            Kdis0 = mink(d0s, theK);
            Kdis1 = mink(d1s, theK);
            s = (sum(Kdis1)/sum(Kdis0))^((y-1)*2);
        end
    end
end

function y = mink(A, k)
    A = sort(A);
    y = A(1:k);
end