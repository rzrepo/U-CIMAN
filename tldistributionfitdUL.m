% analyze on, off, and interval length distributions for an RB, or channel
% the discrete version
clc;
clearvars -except hour_rb_inter_usage;
if 1 ~= exist('hour_rb_inter_usage', 'var')
    clc;clear;
    load ulInterRb.mat;
end

distributions = ["Exponential"  "Weibull"  "Lognormal" "GeneralizedPareto" "Gamma"];
% 
nof_dist = numel(distributions);

hour = 1:24;
rb_idx = 40;

% ulOn = zeros(24*nof_dist, 6); % 3 for kstest, 3 for fitting parameters
% ulOff = zeros(24*nof_dist, 6); % 3 for kstest, 3 for fitting parameters
% ulInter = zeros(24*nof_dist, 6); % 3 for kstest, 3 for fitting parameters
dlOn = -ones(24*nof_dist, 8)*NaN; % 3 for kstest, 3 for fitting parameters
dlOff = -ones(24*nof_dist, 8)*NaN; % 3 for kstest, 3 for fitting parameters
dlInter = -ones(24*nof_dist, 8)*NaN; % 3 for kstest, 3 for fitting parameters

fitSize = [10 30 50 100 200 500 1000 2000];
nof_fitSize = numel(fitSize);

% this loop evaluates the fit size for the RB at each hour
totalFit = zeros(24, nof_fitSize); % the rate of fit for different sizes
for i = 1:24
    nof_record = hour_rb_inter_usage{hour(i),1}(rb_idx);
    nof_record = nof_record/2;
    offTime = hour_rb_inter_usage{hour(i),2}(rb_idx, 1:nof_record);
    interval = hour_rb_inter_usage{hour(i),2}(rb_idx,(nof_record+1):2*nof_record);
    onTime = interval - offTime;
    % par
    parfor j = 1:nof_fitSize
        nof_fitL = zeros(1, 3);
        dlOnL = -ones(nof_dist, 1)*NaN; % 3 for kstest, 3 for fitting parameters
        dlOffL = -ones(nof_dist, 1)*NaN; % 3 for kstest, 3 for fitting parameters
        dlInterL = -ones(nof_dist, 1)*NaN; % 3 for kstest, 3 for fitting parameters
        currentSize = fitSize(j);
        loopCount = floor(nof_record / currentSize);
        % loopCount = 2;
        if loopCount < 1
            totalFit(i,j) = 0;
        else            
            for k = 1:loopCount
                i
                j
                k
                loopCount
                
                offTimeK = offTime((1:fitSize(j))*k)';
                intervalK = interval((1:fitSize(j))*k)';
                onTimeK = onTime((1:fitSize(j))*k)';
                
                for l = 1:nof_dist                    
                    try
                        pd = fitdist(offTimeK, char(distributions(l)));
                        g = pd.random(1, numel(offTimeK));
                        g = ceil(g);
                        dlOffL(l) = kstest2(offTimeK, g);
                    catch
                        dlOffL(l) = 1;
                    end

                    try
                        pd = fitdist(intervalK, char(distributions(l)));
                        g = pd.random(1, numel(intervalK));
                        g = ceil(g);
                        dlInterL(l) = kstest2(intervalK, g);
                    catch
                        dlInterL(l) = 1;
                    end

                    try
                        pd = fitdist(onTimeK, char(distributions(l)));
                        g = pd.random(1, numel(onTimeK));
                        g = ceil(g);
                        dlOnL(l) = kstest2(onTimeK, g);
                    catch
                        dlOnL(l) = 1;
                    end
                end
                nof_fitL(1) = nof_dist - sum(dlOffL);
                nof_fitL(2) = nof_dist - sum(dlInterL);
                nof_fitL(3) = nof_dist - sum(dlOnL);
                
                totalFit(i,j) = totalFit(i,j) + sum(sum(nof_fitL))/nof_dist/3;
            end
            totalFit(i,j) = totalFit(i,j)/loopCount;
        end
    end
end
save('uldistD', 'totalFit');

% fig #1 fitting rate versus fitting size n

figure('rend','painters','pos',[100 100 600 300]);
set(0,'defaultAxesFontName', 'Arial');
hold on; grid on;
% bar(totalFit, 'EdgeColor',[1 1 1], 'LineWidth', 0.2);
plot(0:23, totalFit(:,1), 'o', 0:23, totalFit(:,2), '+', 0:23, totalFit(:,3), '*',...
    0:23, totalFit(:,4), 'x', 0:23, totalFit(:,5), 's', 0:23, totalFit(:,6),'d',...
    0:23, totalFit(:,7), 'p', 0:23, totalFit(:,8), 'h');
totalFit_YY = spline(0:23, totalFit', 0:0.1:23);
ax = gca;
ax.ColorOrderIndex = 1;
plot(0:0.1:23, totalFit_YY(1,:), '-', 0:0.1:23, totalFit_YY(2,:), '--', 0:0.1:23, totalFit_YY(3,:), ':',...
    0:0.1:23, totalFit_YY(4,:), '-.', 0:0.1:23, totalFit_YY(5,:), '-', 0:0.1:23, totalFit_YY(6,:),'--',...
    0:0.1:23, totalFit_YY(7,:), ':', 0:0.1:23, totalFit_YY(8,:), '-.');
xlabel('Hour of the day');
ylabel('Fitting rate');
xlim([0 32]);
ylim([-0.05 1]);
xticks(0:5:25);
legend('n=10','n=30','n=50','n=100','n=200','n=500','n=1000','n=2000', 'Location', 'Best');
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset;
ti = ti*1.5;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
set(findall(gcf,'-property','FontSize'),'FontSize',14);
print(fig,'sizevsfitrateUl','-dpdf');
savefig('sizevsfitrateUl');



goodSize = zeros(24,1);
for i = 1:24    
    [~, goodSizeIdx] = max(totalFit(i,:));
    goodSize(i) = fitSize(goodSizeIdx);
end

goodSize = 100*ones(24,1);

% This loop finds the fit counts of the 5 distributions for each hour when
% sample size is the good size.
cmpFitDistOff = zeros(24, nof_dist);
cmpFitDistOn = zeros(24, nof_dist);
cmpFitDistInt = zeros(24, nof_dist);
%
for i = 1:24
    nof_record = hour_rb_inter_usage{hour(i),1}(rb_idx);
    nof_record = nof_record/2;
    offTime = hour_rb_inter_usage{hour(i),2}(rb_idx, 1:nof_record);
    interval = hour_rb_inter_usage{hour(i),2}(rb_idx,(nof_record+1):2*nof_record);
    onTime = interval - offTime;
    
    nof_fitL = zeros(1, 3);
    dlOnL = -ones(nof_dist, 1)*NaN; % 3 for kstest, 3 for fitting parameters
    dlOffL = -ones(nof_dist, 1)*NaN; % 3 for kstest, 3 for fitting parameters
    dlInterL = -ones(nof_dist, 1)*NaN; % 3 for kstest, 3 for fitting parameters
    currentSize = goodSize(i);
    loopCount = floor(nof_record / currentSize);
    % loopCount = 10;
           
    for k = 1:loopCount
        offTimeK = offTime((1:currentSize)*k)';
        intervalK = interval((1:currentSize)*k)';
        onTimeK = onTime((1:currentSize)*k)';
        for l = 1:nof_dist                    
            try
                pd = fitdist(offTimeK, char(distributions(l)));
                g = pd.random(1, numel(offTimeK));
                g = ceil(g);
                dlOffL(l) = kstest2(offTimeK, g);
            catch
                dlOffL(l) = 1;
            end

            try
                pd = fitdist(intervalK, char(distributions(l)));
                g = pd.random(1, numel(intervalK));
                g = ceil(g);
                dlInterL(l) = kstest2(intervalK, g);
            catch
                dlInterL(l) = 1;
            end

            try
                pd = fitdist(onTimeK, char(distributions(l)));
                g = pd.random(1, numel(onTimeK));
                g = ceil(g);
                dlOnL(l) = kstest2(onTimeK, g);
            catch
                dlOnL(l) = 1;
            end
            cmpFitDistOff(i,l) = cmpFitDistOff(i,l) + dlOffL(l);
            cmpFitDistOn(i,l) = cmpFitDistOn(i,l) + dlInterL(l);
            cmpFitDistInt(i,l) = cmpFitDistInt(i,l) + dlOnL(l);
        end
    end
    cmpFitDistOff(i,:) = 1 - cmpFitDistOff(i,:)/loopCount;
    cmpFitDistOn(i,:) = 1 - cmpFitDistOn(i,:)/loopCount;
    cmpFitDistInt(i,:) = 1 - cmpFitDistInt(i,:)/loopCount;
end

save('uldistD', 'cmpFitDistOff', 'cmpFitDistOn', 'cmpFitDistInt', '-append');


% fig #2, when size is fixed as 100, off time fitting rate

figure('rend','painters','pos',[100 100 600 300]);
set(0,'defaultAxesFontName', 'Arial');
hold on; grid on;
% bar(cmpFitDistOff, 'EdgeColor',[1 1 1], 'LineWidth', 0.2);
plot(0:23, cmpFitDistOff(:,1), 'o', 0:23, cmpFitDistOff(:,2), '+',...
    0:23, cmpFitDistOff(:,3), '*', 0:23, cmpFitDistOff(:,4), 'x',...
    0:23, cmpFitDistOff(:,5), 's');
cmpFitDistOff_YY = spline(0:23, cmpFitDistOff', 0:0.1:23);
ax = gca;
ax.ColorOrderIndex = 1;
plot(0:0.1:23, cmpFitDistOff_YY(1,:), '-', 0:0.1:23, cmpFitDistOff_YY(2,:), '--', 0:0.1:23, cmpFitDistOff_YY(3,:), ':',...
    0:0.1:23, cmpFitDistOff_YY(4,:), '-.', 0:0.1:23, cmpFitDistOff_YY(5,:), '-');
xlabel('Hour of the day');
ylabel('Fitting rate');
xlim([0 30]);ylim([-0.05 1]);
xticks(0:5:25);
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset;
ti = ti*1.5;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
legend('Exp','Wei','Lgn','GeP','Gam', 'Location', 'Best');
set(findall(gcf,'-property','FontSize'),'FontSize',14);
print(fig,'off1005discmpUl','-dpdf');
savefig('off1005discmpUl');

% fig #3, when size is fixed as 100, on time fitting rate

figure('rend','painters','pos',[100 100 600 300]);
set(0,'defaultAxesFontName', 'Arial');
hold on; grid on;
% bar(cmpFitDistOn, 'EdgeColor',[1 1 1], 'LineWidth', 0.2);
plot(0:23, cmpFitDistOn(:,1), 'o', 0:23, cmpFitDistOn(:,2), '+',...
    0:23, cmpFitDistOn(:,3), '*', 0:23, cmpFitDistOn(:,4), 'x',...
    0:23, cmpFitDistOn(:,5), 's');
cmpFitDistOn_YY = spline(0:23, cmpFitDistOn', 0:0.1:23);
ax = gca;
ax.ColorOrderIndex = 1;
plot(0:0.1:23, cmpFitDistOn_YY(1,:), '-', 0:0.1:23, cmpFitDistOn_YY(2,:), '--', 0:0.1:23, cmpFitDistOn_YY(3,:), ':',...
    0:0.1:23, cmpFitDistOn_YY(4,:), '-.', 0:0.1:23, cmpFitDistOn_YY(5,:), '-');
xlabel('Hour of the day');
ylabel('Fitting rate');
xlim([0 23.2]);ylim([-0.05 1]);
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset;
ti = ti*1.5;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
legend('Exp','Wei','Lgn','GeP','Gam', 'Location', 'Best');
set(findall(gcf,'-property','FontSize'),'FontSize',14);
print(fig,'on1005discmpUl','-dpdf');
savefig('on1005discmpUl');

% fig #4, when size is fixed as 100, interval fitting rate

figure('rend','painters','pos',[100 100 600 300]);
set(0,'defaultAxesFontName', 'Arial');
hold on; grid on;
% bar(cmpFitDistInt, 'EdgeColor',[1 1 1], 'LineWidth', 0.2);
plot(0:23, cmpFitDistInt(:,1), 'o', 0:23, cmpFitDistInt(:,2), '+',...
    0:23, cmpFitDistInt(:,3), '*', 0:23, cmpFitDistInt(:,4), 'x',...
    0:23, cmpFitDistInt(:,5), 's');
cmpFitDistInt_YY = spline(0:23, cmpFitDistInt', 0:0.1:23);
ax = gca;
ax.ColorOrderIndex = 1;
plot(0:0.1:23, cmpFitDistInt_YY(1,:), '-', 0:0.1:23, cmpFitDistInt_YY(2,:), '--', 0:0.1:23, cmpFitDistInt_YY(3,:), ':',...
    0:0.1:23, cmpFitDistInt_YY(4,:), '-.', 0:0.1:23, cmpFitDistInt_YY(5,:), '-');
xlabel('Hour of the day');
ylabel('Fitting rate');
xlim([0 23.2]);ylim([-0.05 0.5]);
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset;
ti = ti*1.5;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
legend('Exp','Wei','Lgn','GeP','Gam', 'Location', 'Best');
set(findall(gcf,'-property','FontSize'),'FontSize',14);
print(fig,'int1005discmpUl','-dpdf');
savefig('int1005discmpUl');




for i = 1:24
    nof_record = hour_rb_inter_usage{hour(i),1}(rb_idx);
    nof_record = nof_record/2;
    offTime = hour_rb_inter_usage{hour(i),2}(rb_idx, 1:nof_record);
    interval = hour_rb_inter_usage{hour(i),2}( rb_idx,(nof_record+1):2*nof_record);
    onTime = interval - offTime;
    offTime = offTime(1:goodSize(i))';
    interval = interval(1:goodSize(i))';
    onTime = onTime(1:goodSize(i))';
    for j = 1:nof_dist
        i
        j
        try
            pd = fitdist(offTime, char(distributions(j)));
            g = pd.random(1, numel(offTime));
            g = ceil(g);
            [dlOff((i-1)*nof_dist+j,1), dlOff((i-1)*nof_dist+j,2), dlOff((i-1)*nof_dist+j,3)] = kstest2(offTime, g);
            for k = 1:pd.NumParameters
                dlOff((i-1)*nof_dist+j, 3+k) = pd.(pd.ParameterNames{k});
            end
        catch
            dlOff((i-1)*nof_dist+j,1) = 1;
        end
        
        try
            pd = fitdist(interval, char(distributions(j)));
            g = pd.random(1, numel(interval));
            g = ceil(g);
            [dlInter((i-1)*nof_dist+j,1), dlInter((i-1)*nof_dist+j,2), dlInter((i-1)*nof_dist+j,3)] = kstest2(interval, g);
            for k = 1:pd.NumParameters
                dlInter((i-1)*nof_dist+j, 3+k) = pd.(pd.ParameterNames{k});
            end
        catch
            dlInter((i-1)*nof_dist+j,1) = 1;
        end
           
        try
            pd = fitdist(onTime, char(distributions(j)));
            g = pd.random(1, numel(onTime));
            g = ceil(g);
            [dlOn((i-1)*nof_dist+j,1), dlOn((i-1)*nof_dist+j,2), dlOn((i-1)*nof_dist+j,3)] = kstest2(onTime, g);
            for k = 1:pd.NumParameters
                dlOn((i-1)*nof_dist+j, 3+k) = pd.(pd.ParameterNames{k});
            end
        catch
            dlOn((i-1)*nof_dist+j,1) = 1;
        end
    end
end

save('uldistD', 'distributions', 'dlOff', 'dlInter', 'dlOn', '-append');