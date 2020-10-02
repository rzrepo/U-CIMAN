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
    load(['dlTimeSA' num2str(i,'%d')], 'AIC', 'cmpOffD', 'cmpOnD', ...
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
ti = ti*1.8;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];
% axes('position', [0.7 0.35 0.08 0.3]);
% box on;
% plot(0:23, arCmp);
% xlim([14.999 15.001]);
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
set(findall(gcf,'-property','FontSize'),'FontSize',18);
print(fig,'ARcmpDL','-dpdf');
savefig('ARcmpDL');

% Fig #2, the s/m channel off fitting comparison
figure('rend','painters','pos',[100 100 600 300]);
set(0,'defaultAxesFontName', 'Arial');
hold on; grid on;
stem((0:23)-0.11, plotOffCmp(:,1));
stem((0:23)+0.11, plotOffCmp(:,2),':diamond');
% plot(0:23, plotOffCmp(:,1), 'or', 0:23, plotOffCmp(:,2), 'sb');
% plotOffCmp_YY = spline(0:23, plotOffCmp', 0:0.1:23);
% plot(0:0.1:23, plotOffCmp_YY(1,:), '--r', 0:0.1:23, plotOffCmp_YY(2,:), '-.b');
xlabel('Hour of the day');
ylabel('Off time D value');
% xlim([0 23.2]);
legend('On/off','VAR', 'Location', 'Best');
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset;
ti = ti * 2.45;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
set(findall(gcf,'-property','FontSize'),'FontSize', 28);
print(fig,'smOffCmpDL','-dpdf');
savefig('smOffCmpDL');

% Fig #3, the s/m channel on fitting comparison
figure('rend','painters','pos',[100 100 600 300]);
set(0,'defaultAxesFontName', 'Arial');
hold on; grid on;
% bar(plotOnCmp);
% plot(0:23, plotOnCmp(:,1), '--o', 0:23, plotOnCmp(:,2), '-*');
% plot(0:23, plotOnCmp(:,1), 'or', 0:23, plotOnCmp(:,2), 'sb');
% plotOnCmp_YY = spline(0:23, plotOnCmp', 0:0.1:23);
% plot(0:0.1:23, plotOnCmp_YY(1,:), '--r', 0:0.1:23, plotOnCmp_YY(2,:), '-.b');
stem((0:23)-0.11, plotOnCmp(:,1));
stem((0:23)+0.11, plotOnCmp(:,2),':diamond');
xlabel('Hour of the day');
ylabel('On time D value');
% xlim([0 23.2]);
legend('On/off','VAR', 'Location', 'Best');
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset;
ti = ti * 2.45;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
set(findall(gcf,'-property','FontSize'),'FontSize', 28);
print(fig,'smOnCmpDL','-dpdf');
savefig('smOnCmpDL');

% Fig #4, compare off/on correlation
figure('rend','painters','pos',[100 100 600 300]);
set(0,'defaultAxesFontName', 'Arial');
hold on; grid on;
% oriOffOncorr10Chan_YY = spline(0:23, oriOffOncorr10Chan(1:10:231), 0:0.1:23);
% synDOffOncorr10Chan_YY = spline(0:23, synDOffOncorr10Chan(1:10:231), 0:0.1:23);
% synAROffOncorr10Chan = spline(0:23, synAROffOncorr10Chan(1:10:231), 0:0.1:23);
% plot(0:23, oriOffOncorr10Chan(1:10:231), 'dk',...
%      0:23, synDOffOncorr10Chan(1:10:231), 'or', 0:23, synAROffOncorr10Chan(1:10:231), 'sb');
% plot(0:0.1:23, oriOffOncorr10Chan_YY, ':k',...
%     0:0.1:23, synDOffOncorr10Chan_YY, '--r', 0:0.1:23, synAROffOncorr10Chan, '-.b');
stem((0:23)-0.16, oriOffOncorr10Chan(1:10:231));
stem((0:23), synDOffOncorr10Chan(1:10:231),':diamond');
stem((0:23)+0.16, synAROffOncorr10Chan(1:10:231),'--square');
xlabel('Hour of the day');
ylabel('Correlation');
ylim([-0.2 0.2]);
% xlim([0 23.2]);
l = legend({'Meas','On/0ff','VAR'}, 'Location', 'Best');
l.NumColumns = 3;
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset;
ti = ti * 2.45;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
set(findall(gcf,'-property','FontSize'),'FontSize', 28);
print(fig,'onOffCorrDL','-dpdf');
savefig('onOffCorrDL');

% Fig #5, compare adjacent channel correlation
figure('rend','painters','pos',[100 100 600 300]);
set(0,'defaultAxesFontName', 'Arial');
hold on; grid on;
oriChannCorr10Chan_YY = spline(1:10, oriChannCorr10Chan{15}(1,:), 1:0.1:10);
synDChannCorr10Chan_YY = spline(1:10, synDChannCorr10Chan{15}(1,:), 1:0.1:10);
synARChannCorr10Chan_YY = spline(1:10, synARChannCorr10Chan{15}(1,:), 1:0.1:10);
plot(1:10, oriChannCorr10Chan{15}(1,:), 'dk', ...
    1:10, synDChannCorr10Chan{15}(1,:), 'or', 1:10, synARChannCorr10Chan{15}(1,:), 'sb');
plot(1:0.1:10, oriChannCorr10Chan_YY, ':k', ...
    1:0.1:10, synDChannCorr10Chan_YY, '--r', 1:0.1:10, synARChannCorr10Chan_YY, '-.b');
xlabel('Channel');
ylabel('Correlation');
xlim([1 10.3]);
ylim([-0.1 1]);
legend('Meas','On/off','VAR', 'Location', 'Best');
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset;
ti = ti * 2.45;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2)*1.15 - ti(4);
ax.Position = [left bottom ax_width ax_height];
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
set(findall(gcf,'-property','FontSize'),'FontSize', 28);
print(fig,'chanCorrDL','-dpdf');
savefig('chanCorrDL');


% Fig #6, the s/m interval fitting comparison
figure('rend','painters','pos',[100 100 600 300]);
set(0,'defaultAxesFontName', 'Arial');
hold on; grid on;
% bar(plotIntCmp);
% plot(0:23, plotIntCmp(:,1), '--o', 0:23, plotIntCmp(:,2), '-*');
% plot(0:23, plotIntCmp(:,1), 'or', 0:23, plotIntCmp(:,2), 'sb');
% plotIntCmp_YY = spline(0:23, plotIntCmp', 0:0.1:23);
% plot(0:0.1:23, plotIntCmp_YY(1,:), '--r', 0:0.1:23, plotIntCmp_YY(2,:), '-.b');
stem((0:23)-0.11, plotIntCmp(:,1));
stem((0:23)+0.11, plotIntCmp(:,2),':diamond');
xlabel('Hour of the day');
ylabel('D value');
% xlim([0 23.2]);
legend('On/off','VAR', 'Location', 'Best');
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset;
ti = ti * 2.45;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
set(findall(gcf,'-property','FontSize'),'FontSize', 28);
print(fig,'smIntCmpDL','-dpdf');
savefig('smIntCmpDL');
