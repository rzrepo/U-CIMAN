% compare the measurement results with another paper
% Exploiting LTE White Space using Dynamic Spectrum Access Algorithms based on Survival Analysis
% Published in ICC 2017
% Assume that the data in Table 1 there refers to uplink RB 5 according to
% descirptions there.
% Interval should be 100 ms
clc;

if exist('hour_rb_inter_usage', 'var')==0
    load('ulInterRb.mat');
    clearvars -except hour_rb_inter_usage;
end

rb_offTime_count = 0;
rb = 5;
for i = 1:24
    rb_offTime_count = rb_offTime_count + hour_rb_inter_usage{i,1}(rb)/2;
end

rb_offTime = zeros(1, rb_offTime_count);
idx = 1;
for i = 1:24
    count = hour_rb_inter_usage{i,1}(rb)/2;
    rb_offTime(idx:(idx+count-1)) = hour_rb_inter_usage{i,2}(rb, 1:count);
    idx = idx + count;
end

rb_offTime_main = rb_offTime(rb_offTime<1000);

tailPercent = 1 - sum(rb_offTime<1000)/rb_offTime_count;

interval_length_other = [ones(1,10), 10*ones(1,4), 450, 4500, 5000, 7871, 114300];
value_other = 100*interval_length_other*triu(ones(numel(interval_length_other)));
value_other_p = [value_other(1:10) (value_other(11:19)+value_other(10:18))/2];
interval_size_other = [10331 8523 2174 957 664 431 308 264 240 152 760 281 165 124 546 64 5 3 4];
value_other_pp = repelem(value_other_p, interval_size_other);
other_count = sum(interval_size_other);
bar_x = interval_length_other*triu(ones(numel(interval_length_other)))-interval_length_other;
bar_y = interval_size_other./interval_length_other;
nof_bars = length(bar_x);
otherTotal = sum(interval_size_other);

tailPercentOther = 1 - sum(interval_size_other(1:8))/otherTotal;

figure('rend','painters','pos',[100 100 600 300]);
c = get(gca,'colororder');
c = c(1,:);
set(0,'defaultAxesFontName', 'Arial');
subplot(1,2,2);
h = histogram(rb_offTime_main);
h.FaceColor = c;
h.EdgeColor = c;
xlim([0 1000]);
xticks(0:500:1000);
set(gca,'YScale','log');
grid on;
title('U-CIMAN');
xlabel('Off time (ms)');
ylabel('Occurrence');
subplot(1,2,1);
bar(100*(bar_x(1:10)+0.5), bar_y(1:10), 1, 'FaceColor', c,'EdgeColor', c);
set(gca,'YScale','log');
title('Other');
grid on;
xlim([0 1000]);
xticks(0:500:1000);
xlabel('Off time (ms)');
ylabel('Occurrence');
% get ylim
% yl=ylim;  
% % get order of magnitude
% e=log10(yl(2));
% e=sign(e)*floor(abs(e))-1;
% % get and rescale yticks
% yt=get(gca,'ytick')/10^e;
% % create tick labels
% ytl=cell(size(yt));
% for j=1:length(yt)
%     % the space after the percent gives the same size to positive and
%     % negative numbers. The number of decimal digits can be changed.
%     ytl{j}=sprintf('% 1.0f',yt(j));
% end
% % set tick labels
% set(gca,'yticklabel',ytl);
% % place order of magnitude
% fs = get(gca,'fontsize');
% set(gca,'units','normalized');
% xl = xlim;
% text(xl(1),yl(2),sprintf('x 10^%d',e),...
%     'fontsize',fs,'VerticalAlignment','bottom');
% ax = gca;
% outerpos = ax.OuterPosition;
% ti = ax.TightInset;
% left = outerpos(1) + ti(1);
% bottom = outerpos(2) + ti(2);
% ax_width = outerpos(3) - ti(1) - ti(3);
% ax_height = outerpos(4) - ti(2) - ti(4);
% % ax.Position = [left bottom ax_width ax_height];
fig = gcf;
% fig.PaperPositionMode = 'auto';
% fig_pos = fig.PaperPosition;
% fig.PaperSize = [fig_pos(3) fig_pos(4)];
 set(findall(gcf,'-property','FontSize'),'FontSize',24);
print(fig,'compare','-dpdf');
savefig('compare');

% figure; hold on; grid on;
% for i = 1:10
%     rectangle('position', [bar_x(i) 0 interval_length_other(i) bar_y(i)]);
% end
% set(gca, 'XScale', 'log');
% set(gca, 'YScale', 'log');

meanOur = mean(rb_offTime);
stdOur = std(rb_offTime);
meanOther = mean(value_other_pp);
stdOther = std(value_other_pp);

meanOurOn = (24*60*60*1000-meanOur*rb_offTime_count)/rb_offTime_count;
meanOtherOn = (24*60*60*1000-meanOur*other_count)/other_count;

save('compareData');