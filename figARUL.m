% Draw the figures for AR model and the comparisons

theChan = 1;
arCmp = zeros(24, 6);
plotOffCmp = zeros(24, 2);
plotOnCmp = zeros(24, 2);
plotIntCmp = zeros(24, 2);
singleCOffDisCmp = cell(24,1);
singleCOnDisCmp = cell(24,1);
multiCOffDisCmp = cell(24,1);
multiCOnDisCmp = cell(24,1);
oriOffOncorr10Chan = zeros(240,1);
synDOffOncorr10Chan = zeros(240,1);
synAROffOncorr10Chan = zeros(240,1);
oriChannCorr10Chan = cell(24,1);
synARChannCorr10Chan = cell(24,1);
synDChannCorr10Chan = cell(24,1);

for i = 1:24
    load(['ulTimeSA' num2str(i,'%d')], 'AIC', 'cmpOffD', 'cmpOnD', ...
        'cmpOffAR', 'cmpOnAR', 'oriOffOnCorr', 'synAROffOnCorr', ...
        'synDOffOnCorr', 'oriChannCorr', 'synARChannCorr',...
        'synDChannCorr', 'cmpIntD', 'cmpIntAR');
    arCmp(i,:) = AIC;
    plotOffCmp(i,1) = cmpOffD(theChan, 3);
    plotOffCmp(i,2) = cmpOffAR(theChan, 3);
    plotOnCmp(i,1) = cmpOnD(theChan, 3);
    plotOnCmp(i,2) = cmpOnAR(theChan, 3);
    plotIntCmp(i,1) = cmpIntD(theChan, 3);
    plotIntCmp(i,2) = cmpIntAR(theChan, 3);
    singleCOffDisCmp{i} = cmpOffD;
    singleCOnDisCmp{i} = cmpOnD;
    multiCOffDisCmp{i} = cmpOffAR;
    multiCOnDisCmp{i} = cmpOnAR;
    oriOffOncorr10Chan((i*10-9):(i*10)) = oriOffOnCorr;
    synDOffOncorr10Chan((i*10-9):(i*10)) = synAROffOnCorr;
    synAROffOncorr10Chan((i*10-9):(i*10)) = synDOffOnCorr;
    oriChannCorr10Chan{i} = oriChannCorr;
    synARChannCorr10Chan{i} = synARChannCorr;
    synDChannCorr10Chan{i} = synDChannCorr;
end

% Fig #1, the AR lag comparison
figure('rend','painters','pos',[100 100 600 300]);
set(0,'defaultAxesFontName', 'Arial');
hold on; grid on;
bar(arCmp, 'EdgeColor',[1 1 1], 'LineWidth', 0.2);
% plot(0:23, arCmp);
xlabel('Hour of the day');
ylabel('AIC');
xlim([0 25]);
legend('lag=1','lag=2','lag=3','lag=4','lag=8','lag=12', 'Location', 'Best');
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset;
ti = ti*1.5;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];

% axes('position', [0.25 0.45 0.03 0.3]);
% box on;
% plot(0:23, arCmp);
% xlim([3.999 4.001]);
% axes('position', [0.5 0.35 0.03 0.3]);
% box on;
% plot(0:23, arCmp);
% xlim([10.999 11.001]);
% axes('position', [0.7 0.35 0.03 0.3]);
% box on;
% plot(0:23, arCmp);
% xlim([18.999 19.001]);

fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
set(findall(gcf,'-property','FontSize'),'FontSize',14);
print(fig,'ARcmpUL','-dpdf');
savefig('ARcmpUL');

% Fig #2, the s/m channel off fitting comparison
figure('rend','painters','pos',[100 100 600 300]);
set(0,'defaultAxesFontName', 'Arial');
hold on; grid on;
% bar(plotOffCmp);
plot(1+(0:23), plotOffCmp(:,1), 'or', 1+(0:23), plotOffCmp(:,2), 'sb');
plotOffCmp_YY = spline(0:23, plotOffCmp', 0:0.1:23);
plot(1+(0:0.1:23), plotOffCmp_YY(1,:), '--r', 1+(0:0.1:23), plotOffCmp_YY(2,:), '-.b');
xlabel('Hour of the day');
ylabel('Off time D value');
xlim([0 25]);
legend('Single-Channel fitting','Multi-Channel fitting', 'Location', 'Best');
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
print(fig,'smOffCmpUL','-dpdf');
savefig('smOffCmpUL');

% Fig #3, the s/m channel on fitting comparison
figure('rend','painters','pos',[100 100 600 300]);
set(0,'defaultAxesFontName', 'Arial');
hold on; grid on;
% bar(plotOnCmp);
plot(1+(0:23), plotOnCmp(:,1), 'or', 1+(0:23), plotOnCmp(:,2), 'sb');
plotOnCmp_YY = spline(0:23, plotOnCmp', 0:0.1:23);
plot(1+(0:0.1:23), plotOnCmp_YY(1,:), '--r', 1+(0:0.1:23), plotOnCmp_YY(2,:), '-.b');
xlabel('Hour of the day');
ylabel('On time D value');
xlim([0 25]);
legend('Single-Channel fitting','Multi-Channel fitting', 'Location', 'Best');
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
print(fig,'smOnCmpUL','-dpdf');
savefig('smOnCmpUL');

% Fig #4, compare off/on correlation
figure('rend','painters','pos',[100 100 600 300]);
set(0,'defaultAxesFontName', 'Arial');
hold on; grid on;
% bar([oriOffOncorr10Chan(1:10:231) synDOffOncorr10Chan(1:10:231) synAROffOncorr10Chan(1:10:231)]);
oriOffOncorr10Chan_YY = spline(0:23, oriOffOncorr10Chan(1:10:231), 0:0.1:23);
synDOffOncorr10Chan_YY = spline(0:23, synDOffOncorr10Chan(1:10:231), 0:0.1:23);
synAROffOncorr10Chan = spline(0:23, synAROffOncorr10Chan(1:10:231), 0:0.1:23);
plot(1+(0:23), oriOffOncorr10Chan(1:10:231), 'or', 1+(0:23), synDOffOncorr10Chan(1:10:231), 'sb',...
     1+(0:23), synAROffOncorr10Chan(1:10:231), 'dk');
plot(1+(0:0.1:23), oriOffOncorr10Chan_YY, '--r', 1+(0:0.1:23), synDOffOncorr10Chan_YY, '-.b',...
    1+(0:0.1:23), synAROffOncorr10Chan, ':k');
% plot(1:240, oriOffOncorr10Chan, '--o', 1:240, synDOffOncorr10Chan, '-*', ...
%     1:240, synAROffOncorr10Chan, ':d');
xlabel('Hour of the day');
ylabel('Correlation coefficient');
% xlim([0.5 240.5]);
% xticks(24.5:40:224.5);
% xticklabels({'2', '6', '10' '14', '18', '22'});
legend('Measurement','Single-Channel fitting','Multi-Channel fitting', 'Location', 'Best');
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
print(fig,'onOffCorrUL','-dpdf');
savefig('onOffCorrUL');

% Fig #5, compare adjacent channel correlation
figure('rend','painters','pos',[100 100 600 300]);
set(0,'defaultAxesFontName', 'Arial');
hold on; grid on;
% bar([oriChannCorr10Chan{15}(1,:)' synDChannCorr10Chan{15}(1,:)' synARChannCorr10Chan{15}(1,:)']);
oriChannCorr10Chan_YY = spline(1:10, oriChannCorr10Chan{15}(1,:), 1:0.1:10);
synDChannCorr10Chan_YY = spline(1:10, synDChannCorr10Chan{15}(1,:), 1:0.1:10);
synARChannCorr10Chan_YY = spline(1:10, synARChannCorr10Chan{15}(1,:), 1:0.1:10);
plot(1:10, oriChannCorr10Chan{15}(1,:), 'or', 1:10, synDChannCorr10Chan{15}(1,:), 'sb', ...
    1:10, synARChannCorr10Chan{15}(1,:), 'dk');
plot(1:0.1:10, oriChannCorr10Chan_YY, '--r', 1:0.1:10, synDChannCorr10Chan_YY, '-.b', ...
    1:0.1:10, synARChannCorr10Chan_YY, ':k');
xlabel('Channel');
ylabel('Correlation coefficient');
xlim([0.5 10.5]); ylim([-0.1 1]);
legend('Measurement','Single-Channel fitting','Multi-Channel fitting', 'Location', 'Best');
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
print(fig,'chanCorrUL','-dpdf');
savefig('chanCorrUL');


% Fig #6, the s/m interval fitting comparison
figure('rend','painters','pos',[100 100 600 300]);
set(0,'defaultAxesFontName', 'Arial');
hold on; grid on;
% bar(plotIntCmp);
% plot(0:23, plotIntCmp(:,1), '--o', 0:23, plotIntCmp(:,2), '-*');
plotIntCmp_YY = spline(0:23, plotIntCmp', 0:0.1:23);
plot(1+(0:23), plotIntCmp(:,1), 'ob', 1+(0:23), plotIntCmp(:,2), 'sr');
plot(1+(0:0.1:23), plotIntCmp_YY(1,:), '--b', 1+(0:0.1:23), plotIntCmp_YY(2,:), '-.r');
xlabel('Hour of the day');
ylabel('Interval length D value');
xlim([0 25]);
legend('Single-Channel fitting','Multi-Channel fitting', 'Location', 'Best');
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
print(fig,'smIntCmpUL','-dpdf');
savefig('smIntCmpUL');