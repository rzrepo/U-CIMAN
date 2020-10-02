% analyze dl rb inter usage time

clc;clear;

if exist(fullfile(cd, 'dlInterRb.mat'), 'file')
    load('dlInterRb.mat');
else
    dataDir = 'oneDaymatdata';
    files = dir2(['./' dataDir]);
    [~,idx] = sort([files.datenum]);
    nof_files = numel(files);

    nrb = 50;

    mean_dl_interRb_interval = zeros(24, nrb); % average number of rb per tti
    pctileLow_dl_interRb_interval = zeros(24, nrb); % 15 percentile of rb per tti
    pctileHigh_dl_interRb_interval = zeros(24, nrb); % 85 percentile of rb per tti
    min_dl_interRb_interval = zeros(24, nrb); % min rb per tti
    max_dl_interRb_interval = zeros(24, nrb); % max rb per tti

    mean_dl_interRb_onTime = zeros(24, nrb); % average number of rb per tti
    pctileLow_dl_interRb_onTime = zeros(24, nrb); % 15 percentile of rb per tti
    pctileHigh_dl_interRb_onTime = zeros(24, nrb); % 85 percentile of rb per tti
    min_dl_interRb_onTime = zeros(24, nrb); % min rb per tti
    max_dl_interRb_onTime = zeros(24, nrb); % max rb per tti

    mean_dl_interRb_offTime = zeros(24, nrb); % average number of rb per tti
    pctileLow_dl_interRb_offTime = zeros(24, nrb); % 15 percentile of rb per tti
    pctileHigh_dl_interRb_offTime = zeros(24, nrb); % 85 percentile of rb per tti
    min_dl_interRb_offTime = zeros(24, nrb); % min rb per tti
    max_dl_interRb_offTime = zeros(24, nrb); % max rb per tti

    mean_dl_interRb_DR = zeros(24, nrb); % average number of rb per tti
    pctileLow_dl_interRb_DR = zeros(24, nrb); % 15 percentile of rb per tti
    pctileHigh_dl_interRb_DR = zeros(24, nrb); % 85 percentile of rb per tti
    min_dl_interRb_DR = zeros(24, nrb); % min rb per tti
    max_dl_interRb_DR = zeros(24, nrb); % max rb per tti

    hour_rb_inter_usage = cell(24,2);
    hour_cell = cell(24,2);

    for i = 1:24
        hour_cell{i,1} = 0;
        hour_cell{i,2} = zeros(50, 3600*1000);
        hour_rb_inter_usage{i,1} = zeros(50, 1); % number of intervals for one RB
        hour_rb_inter_usage{i,2} = zeros(50, 3600*1000/2); % statistics for each interval
    end

    for i = 1:nof_files
        shour = extractBetween(files(idx(i)).name,16,17);
        dhour = str2double(shour);
        if dhour>23 || dhour<0
            disp('Wrong hour!! Something wrong happened!!');
            return;        
        end
        load(['./' dataDir '/' files(idx(i)).name]);
        dlrb = ten_sec_usage(:,2:(nrb+1));
        if max(max(dlrb))>65535 || min(min(dlrb))<0
            disp(['Wrong rnti value at ' files(idx(i)).name]);
            return;
        end
        dlrb = dlrb';
        start_idx = hour_cell{dhour+1, 1} + 1;
        end_idx = hour_cell{dhour+1, 1} + size(dlrb, 2);
        if end_idx>3600*1000
            continue;
        else
            hour_cell{dhour+1, 2}(:, start_idx:end_idx) = dlrb;
            hour_cell{dhour+1, 1} = hour_cell{dhour+1, 1} + size(dlrb, 2);
        end
    end
    
    for i = 1:24
        for j = 1:nrb
            rb_usage = hour_cell{i,2}(j,:);
            rb_usage = rb_usage(1:hour_cell{i,1});
            
            rb_usage_p1 = rb_usage>0;
            rb_usage_p2 = zeros(size(rb_usage_p1));
            rb_usage_p2(2:end) = rb_usage_p1(2:end) - rb_usage_p1(1:(end-1));
       
            nof_intervals = sum(rb_usage_p2==-1)-1;
            hour_rb_inter_usage{i,1}(j) = nof_intervals*2; % number of intervals for one RB
            
            if nof_intervals>0            
                firstm1_idx = find(rb_usage_p2==-1,1,'first');
                lastm1_idx = find(rb_usage_p2==-1,1,'last');
                rb_usage_p2(lastm1_idx:end) = [];
                rb_usage_p2(1:(firstm1_idx-1)) = [];
                m1positions = find(rb_usage_p2==-1);
                interval_lengths = [m1positions(2:end)-m1positions(1:(end-1)) length(rb_usage_p2)-m1positions(end)+1];
                p1positions = find(rb_usage_p2==1);
                off_time = p1positions - m1positions;
            
                hour_rb_inter_usage{i,2}(j,1:nof_intervals*2) = [off_time interval_lengths]; % statistics for each interval
                on_time = interval_lengths - off_time;
                duty_ratio = on_time./interval_lengths;

                mean_dl_interRb_interval(i, j) = mean(interval_lengths);
                pctileLow_dl_interRb_interval(i, j) = prctile(interval_lengths, 15); % 15 percentile of rb per tti
                pctileHigh_dl_interRb_interval(i, j) = prctile(interval_lengths, 85); % 85 percentile of rb per tti
                min_dl_interRb_interval(i, j) = min(interval_lengths); % min rb per tti
                max_dl_interRb_interval(i, j) = max(interval_lengths); % max rb per tti

                mean_dl_interRb_onTime(i, j) = mean(on_time); % average number of rb per tti
                pctileLow_dl_interRb_onTime(i, j) = prctile(on_time, 15); % 15 percentile of rb per tti
                pctileHigh_dl_interRb_onTime(i, j) = prctile(on_time, 85); % 85 percentile of rb per tti
                min_dl_interRb_onTime(i, j) = min(on_time); % min rb per tti
                max_dl_interRb_onTime(i, j) = max(on_time); % max rb per tti    
                
                mean_dl_interRb_offTime(i, j) = mean(off_time); % average number of rb per tti
                pctileLow_dl_interRb_offTime(i, j) = prctile(off_time, 15); % 15 percentile of rb per tti
                pctileHigh_dl_interRb_offTime(i, j) = prctile(off_time, 85); % 85 percentile of rb per tti
                min_dl_interRb_offTime(i, j) = min(off_time); % min rb per tti
                max_dl_interRb_offTime(i, j) = max(off_time); % max rb per tti

                mean_dl_interRb_DR(i, j) = mean(duty_ratio); % average number of rb per tti
                pctileLow_dl_interRb_DR(i, j) = prctile(duty_ratio, 15); % 15 percentile of rb per tti
                pctileHigh_dl_interRb_DR(i, j) = prctile(duty_ratio, 85); % 85 percentile of rb per tti
                min_dl_interRb_DR(i, j) = min(duty_ratio); % min rb per tti
                max_dl_interRb_DR(i, j) = max(duty_ratio); % max rb per tti
            else
            end
        end
    end
    save('dlInterRb.mat', '-v7.3');
end



for i = 1:24
    for j = 1:nrb
        rb_usage = hour_cell{i,2}(j,:);
        rb_usage = rb_usage(1:hour_cell{i,1});

        rb_usage_p1 = rb_usage>0;
        rb_usage_p2 = zeros(size(rb_usage_p1));
        rb_usage_p2(2:end) = rb_usage_p1(2:end) - rb_usage_p1(1:(end-1));

        nof_intervals = sum(rb_usage_p2==-1)-1;
        hour_rb_inter_usage{i,1}(j) = nof_intervals*2; % number of intervals for one RB

        if nof_intervals>0            
            firstm1_idx = find(rb_usage_p2==-1,1,'first');
            lastm1_idx = find(rb_usage_p2==-1,1,'last');
            rb_usage_p2(lastm1_idx:end) = [];
            rb_usage_p2(1:(firstm1_idx-1)) = [];
            m1positions = find(rb_usage_p2==-1);
            interval_lengths = [m1positions(2:end)-m1positions(1:(end-1)) length(rb_usage_p2)-m1positions(end)+1];
            p1positions = find(rb_usage_p2==1);
            off_time = p1positions - m1positions;

            hour_rb_inter_usage{i,2}(j,1:nof_intervals*2) = [off_time interval_lengths]; % statistics for each interval
            on_time = interval_lengths - off_time;
            duty_ratio = on_time./interval_lengths;

            mean_dl_interRb_offTime(i, j) = mean(off_time); % average number of rb per tti
            pctileLow_dl_interRb_offTime(i, j) = prctile(off_time, 20); % 15 percentile of rb per tti
            pctileHigh_dl_interRb_offTime(i, j) = prctile(off_time, 80); % 85 percentile of rb per tti
            min_dl_interRb_offTime(i, j) = min(off_time); % min rb per tti
            max_dl_interRb_offTime(i, j) = max(off_time); % max rb per tti
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Fig #1, interval length 2 hours, 3 and 13, all RBs
figure('rend','painters','pos',[100 100 600 300]);
set(0,'defaultAxesFontName', 'Arial');
hold on; grid on;
errorbar([1:50 56:105], [mean_dl_interRb_interval(4,:) mean_dl_interRb_interval(14,:)],...
    [min_dl_interRb_interval(4,:) min_dl_interRb_interval(14,:)] - [mean_dl_interRb_interval(4,:) mean_dl_interRb_interval(14,:)],...
    [max_dl_interRb_interval(4,:) max_dl_interRb_interval(14,:)] - [mean_dl_interRb_interval(4,:) mean_dl_interRb_interval(14,:)],...
    'o','MarkerSize', 2,'CapSize',2);
errorbar([1:50 56:105], [mean_dl_interRb_interval(4,:) mean_dl_interRb_interval(14,:)],...
    [pctileLow_dl_interRb_interval(4,:) pctileLow_dl_interRb_interval(14,:)] - [mean_dl_interRb_interval(4,:) mean_dl_interRb_interval(14,:)],...
    [pctileHigh_dl_interRb_interval(4,:) pctileHigh_dl_interRb_interval(14,:)] - [mean_dl_interRb_interval(4,:) mean_dl_interRb_interval(14,:)],...
    'o','MarkerSize', 2,'CapSize',2);
xlabel('Hour of the day');
ylabel('Interval length');
set(gca, 'YScale', 'log');
xlim([0 106]);
xticks([25.5 80.5]);
xticklabels({'3 to 4','13 to 14'});
legend('Min-max range', '15 to 85 percentiles', 'Location', 'Best');
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
print(fig,'dl2h50rbinterval','-dpdf');
savefig('dl2h50rbinterval');


% Fig #2, on time 2 hours, 3 and 13, all RBs
figure('rend','painters','pos',[100 100 600 300]);
set(0,'defaultAxesFontName', 'Arial');
hold on; grid on;
errorbar([1:50 56:105], [mean_dl_interRb_onTime(4,:) mean_dl_interRb_onTime(14,:)],...
    [min_dl_interRb_onTime(4,:) min_dl_interRb_onTime(14,:)] - [mean_dl_interRb_onTime(4,:) mean_dl_interRb_onTime(14,:)],...
    [max_dl_interRb_onTime(4,:) max_dl_interRb_onTime(14,:)] - [mean_dl_interRb_onTime(4,:) mean_dl_interRb_onTime(14,:)],...
    'o','MarkerSize', 2,'CapSize',2);
errorbar([1:50 56:105], [mean_dl_interRb_onTime(4,:) mean_dl_interRb_onTime(14,:)],...
    [pctileLow_dl_interRb_onTime(4,:) pctileLow_dl_interRb_onTime(14,:)] - [mean_dl_interRb_onTime(4,:) mean_dl_interRb_onTime(14,:)],...
    [pctileHigh_dl_interRb_onTime(4,:) pctileHigh_dl_interRb_onTime(14,:)] - [mean_dl_interRb_onTime(4,:) mean_dl_interRb_onTime(14,:)],...
    'o','MarkerSize', 2,'CapSize',2);
xlabel('Hour of the day');
ylabel('On time');
set(gca, 'YScale', 'log');
xlim([0 106]);
xticks([25.5 80.5]);
xticklabels({'3 to 4','13 to 14'});
legend('Min-max range', '15 to 85 percentiles', 'Location', 'Best');
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
print(fig,'dl2h50rbontime','-dpdf');
savefig('dl2h50rbontime');



% Fig #3, off time 2 hours, 3 and 13, all RBs
figure('rend','painters','pos',[100 100 600 300]);
set(0,'defaultAxesFontName', 'Arial');
hold on; grid on;
errorbar([1:50 56:105], [mean_dl_interRb_offTime(4,:) mean_dl_interRb_offTime(14,:)],...
    [min_dl_interRb_offTime(4,:) min_dl_interRb_offTime(14,:)] - [mean_dl_interRb_offTime(4,:) mean_dl_interRb_offTime(14,:)],...
    [max_dl_interRb_offTime(4,:) max_dl_interRb_offTime(14,:)] - [mean_dl_interRb_offTime(4,:) mean_dl_interRb_offTime(14,:)],...
    'o','MarkerSize', 2,'CapSize',2);
errorbar([1:50 56:105], [mean_dl_interRb_offTime(4,:) mean_dl_interRb_offTime(14,:)],...
    [pctileLow_dl_interRb_offTime(4,:) pctileLow_dl_interRb_offTime(14,:)] - [mean_dl_interRb_offTime(4,:) mean_dl_interRb_offTime(14,:)],...
    [pctileHigh_dl_interRb_offTime(4,:) pctileHigh_dl_interRb_offTime(14,:)] - [mean_dl_interRb_offTime(4,:) mean_dl_interRb_offTime(14,:)],...
    'o','MarkerSize', 2,'CapSize',2);
xlabel('Hour of the day');
ylabel('Off time');
set(gca, 'YScale', 'log');
xlim([0 106]);
xticks([25.5 80.5]);
xticklabels({'3 to 4','13 to 14'});
legend('Min-max range', '15 to 85 percentiles', 'Location', 'Best');
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
print(fig,'dl2h50rbofftime','-dpdf');
savefig('dl2h50rbofftime');


% Fig #4, ratio of on time 2 hours, 3 and 13, all RBs
figure('rend','painters','pos',[100 100 600 300]);
set(0,'defaultAxesFontName', 'Arial');
hold on; grid on;
errorbar([1:50 56:105], [mean_dl_interRb_DR(4,:) mean_dl_interRb_DR(14,:)],...
    [min_dl_interRb_DR(4,:) min_dl_interRb_DR(14,:)] - [mean_dl_interRb_DR(4,:) mean_dl_interRb_DR(14,:)],...
    [max_dl_interRb_DR(4,:) max_dl_interRb_DR(14,:)] - [mean_dl_interRb_DR(4,:) mean_dl_interRb_DR(14,:)],...
    'o','MarkerSize', 2,'CapSize',2);
errorbar([1:50 56:105], [mean_dl_interRb_DR(4,:) mean_dl_interRb_DR(14,:)],...
    [pctileLow_dl_interRb_DR(4,:) pctileLow_dl_interRb_DR(14,:)] - [mean_dl_interRb_DR(4,:) mean_dl_interRb_DR(14,:)],...
    [pctileHigh_dl_interRb_DR(4,:) pctileHigh_dl_interRb_DR(14,:)] - [mean_dl_interRb_DR(4,:) mean_dl_interRb_DR(14,:)],...
    'o','MarkerSize', 2,'CapSize',2);
xlabel('Hour of the day');
ylabel('On time ratio');
set(gca, 'YScale', 'log');
xlim([0 106]);
xticks([25.5 80.5]);
xticklabels({'3 to 4','13 to 14'});
legend('Min-max range', '15 to 85 percentiles', 'Location', 'Best');
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
print(fig,'dl2h50rbdr','-dpdf');
savefig('dl2h50rbdr');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 5 RBs, 1, 13, 25, 37, 50, all hours

plot_RB = [1, 13, 25, 37, 50];
theX = repmat(1:5, 1, 24) + reshape(repmat(0:7:23*7, 5, 1), 1, 120);

% Fig #5, 5 RBs 24 hours interval length
theMean = mean_dl_interRb_interval(:,plot_RB);
theMean = reshape(theMean', [], 1);
theMin = min_dl_interRb_interval(:,plot_RB);
theMin = reshape(theMin', [], 1);
theMax = max_dl_interRb_interval(:,plot_RB);
theMax = reshape(theMax', [], 1);
theH = pctileHigh_dl_interRb_interval(:,plot_RB);
theH = reshape(theH', [], 1);
theL = pctileLow_dl_interRb_interval(:,plot_RB);
theL = reshape(theL', [], 1);

figure('rend','painters','pos',[100 100 600 300]);
set(0,'defaultAxesFontName', 'Arial');
hold on; grid on;
errorbar(theX, theMean, theMin - theMean, ...
    theMax - theMean, 'o','MarkerSize', 2,'CapSize',2);
errorbar(theX, theMean, theL - theMean, ...
    theH - theMean, 'o','MarkerSize', 2,'CapSize',2);
xlabel('Hour of the day');
ylabel('Interval length');
set(gca, 'YScale', 'log');
xlim([0 23*7+5]);
xticks(3:14:23*7+3);
xticklabels({'0','2','4','6','8','10','12','14','16','18','20','22'});
legend('Min-max range', '15 to 85 percentiles', 'Location', 'Best');
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
print(fig,'dl24h5rbinterval','-dpdf');
savefig('dl24h5rbinterval');

% Fig #6, 5 RBs 24 hours on time
theMean = mean_dl_interRb_onTime(:,plot_RB);
theMean = reshape(theMean', [], 1);
theMin = min_dl_interRb_onTime(:,plot_RB);
theMin = reshape(theMin', [], 1);
theMax = max_dl_interRb_onTime(:,plot_RB);
theMax = reshape(theMax', [], 1);
theH = pctileHigh_dl_interRb_onTime(:,plot_RB);
theH = reshape(theH', [], 1);
theL = pctileLow_dl_interRb_onTime(:,plot_RB);
theL = reshape(theL', [], 1);
figure('rend','painters','pos',[100 100 600 300]);
set(0,'defaultAxesFontName', 'Arial');
hold on; grid on;
errorbar(theX, theMean, theMin - theMean, ...
    theMax - theMean, 'o','MarkerSize', 2,'CapSize',2);
errorbar(theX, theMean, theL - theMean, ...
    theH - theMean, 'o','MarkerSize', 2,'CapSize',2);
xlabel('Hour of the day');
ylabel('On time');
set(gca, 'YScale', 'log');
xlim([0 23*7+5]);
ylim([1 10000]);
xticks(3:14:23*7+3);
xticklabels({'0','2','4','6','8','10','12','14','16','18','20','22'});
legend('Min-max range', '15 to 85 percentiles', 'Location', 'Best');
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
print(fig,'dl24h5rbontime','-dpdf');
savefig('dl24h5rbontime');

% Fig #7, 5 RBs 24 hours off time
theMean = mean_dl_interRb_offTime(:,plot_RB);
theMean = reshape(theMean', [], 1);
theMin = min_dl_interRb_offTime(:,plot_RB);
theMin = reshape(theMin', [], 1);
theMax = max_dl_interRb_offTime(:,plot_RB);
theMax = reshape(theMax', [], 1);
theH = pctileHigh_dl_interRb_offTime(:,plot_RB);
theH = reshape(theH', [], 1);
theL = pctileLow_dl_interRb_offTime(:,plot_RB);
theL = reshape(theL', [], 1);
figure('rend','painters','pos',[100 100 600 300]);
set(0,'defaultAxesFontName', 'Arial');
hold on; grid on;
errorbar(theX, theMean, theMin - theMean, ...
    theMax - theMean, 'o','MarkerSize', 2,'CapSize',2);
errorbar(theX, theMean, theL - theMean, ...
    theH - theMean, 'o','MarkerSize', 2,'CapSize',2);
xlabel('Hour of the day');
ylabel('Off time');
set(gca, 'YScale', 'log');
xlim([0 23*7+5]);
ylim([1 100000]);
xticks(3:14:23*7+3);
xticklabels({'0','2','4','6','8','10','12','14','16','18','20','22'});
legend('Min to max', '20 to 80 pct.', 'Location', 'Best');
legend boxoff;
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
print(fig,'dl24h5rbofftime','-dpdf');
savefig('dl24h5rbofftime');

% Fig #8, 5 RBs 24 hours off time
theMean = mean_dl_interRb_DR(:,plot_RB);
theMean = reshape(theMean', [], 1);
theMin = min_dl_interRb_DR(:,plot_RB);
theMin = reshape(theMin', [], 1);
theMax = max_dl_interRb_DR(:,plot_RB);
theMax = reshape(theMax', [], 1);
theH = pctileHigh_dl_interRb_DR(:,plot_RB);
theH = reshape(theH', [], 1);
theL = pctileLow_dl_interRb_DR(:,plot_RB);
theL = reshape(theL', [], 1);
figure('rend','painters','pos',[100 100 600 300]);
set(0,'defaultAxesFontName', 'Arial');
hold on; grid on;
errorbar(theX, theMean, theMin - theMean, ...
    theMax - theMean, 'o','MarkerSize', 2,'CapSize',2);
errorbar(theX, theMean, theL - theMean, ...
    theH - theMean, 'o','MarkerSize', 2,'CapSize',2);
xlabel('Hour of the day');
ylabel('On time ratio');
set(gca, 'YScale', 'log');
xlim([0 23*7+5]);
% ylim([1 10000]);
xticks(3:14:23*7+3);
xticklabels({'0','2','4','6','8','10','12','14','16','18','20','22'});
legend('Min-max range', '15 to 85 percentiles', 'Location', 'Best');
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
print(fig,'dl24h5rbdr','-dpdf');
savefig('dl24h5rbdr');