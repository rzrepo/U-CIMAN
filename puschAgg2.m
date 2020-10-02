% analyze pusch cell staticstics
clc;clear;

if exist(fullfile(cd, 'ulrbcellprocessed.mat'), 'file')
    load('ulrbcellprocessed.mat');
else
    dataDir = 'oneDaymatdata';
    files = dir2(['./' dataDir]);
    [~,idx] = sort([files.datenum]);
    nof_files = numel(files);

    nrb = 50;

    hour_rb_pos_count = zeros(24, nrb); % count the number of each rb index

    mean_rb_per_tti_per_hour = zeros(24, 1); % average number of rb per tti
    pctileLow_rb_per_tti_per_hour = zeros(24, 1); % 15 percentile of rb per tti
    pctileHigh_rb_per_tti_per_hour = zeros(24, 1); % 85 percentile of rb per tti
    min_rb_per_tti_per_hour = zeros(24, 1); % min rb per tti
    max_rb_per_tti_per_hour = zeros(24, 1); % max rb per tti
    per_tti_nrb_record = zeros(24, 1 + nrb); % distribution of number of rb per tti
    nof_TTI = zeros(24, 1);

    hour_cell = cell(24,2);

    for i = 1:24
        hour_cell{i,1} = 0;
        hour_cell{i,2} = zeros(1, 3600*1000*50);
    end

    for i = 1:nof_files
        shour = extractBetween(files(idx(i)).name,16,17);
        dhour = str2double(shour);
        if dhour>23 || dhour<0
            disp('Wrong hour!! Something wrong happened!!');
            return;        
        end
        load(['./' dataDir '/' files(idx(i)).name]);
        ulrb = ten_sec_usage(:,(nrb+2):(end-1));
        if max(max(ulrb))>65535 || min(min(ulrb))<0
            disp(['Wrong rnti value at ' files(idx(i)).name]);
            return;
        end
        ulrb = ulrb';
        ulrb = reshape(ulrb, 1, numel(ulrb));
        start_idx = hour_cell{dhour+1, 1} + 1;
        end_idx = hour_cell{dhour+1, 1} + length(ulrb);
        if end_idx>3600*1000*50
            continue;
        else
            hour_cell{dhour+1, 2}(start_idx:end_idx) = ulrb;
            hour_cell{dhour+1, 1} = hour_cell{dhour+1, 1} + length(ulrb);
        end
    end
    
    for i = 1:24
        currentH_count = hour_cell{i,1};
        currentH = hour_cell{i,2};
        currentH = currentH(1:currentH_count);
        for j = 1:nrb
            hour_rb_pos_count(i,j) = sum(currentH(j:50:end)>0);
        end
        currentH = reshape(currentH, 50, numel(currentH)/50);
        for j = 0:nrb
            per_tti_nrb_record(i,j+1) = sum(sum(currentH>0)==j);
        end
        current_rb_per_tti = sum(currentH>0);
        mean_rb_per_tti_per_hour(i) = mean(current_rb_per_tti); % average number of rb per tti
        pctileLow_rb_per_tti_per_hour(i) = prctile(current_rb_per_tti, 15); % 15 percentile of rb per tti
        pctileHigh_rb_per_tti_per_hour(i) = prctile(current_rb_per_tti, 85); % 85 percentile of rb per tti
        min_rb_per_tti_per_hour(i) = min(current_rb_per_tti); % min rb per tti
        max_rb_per_tti_per_hour(i) = max(current_rb_per_tti); % max rb per tti
    end
    save('ulrbcellprocessed.mat', '-v7.3');
end

figure('rend','painters','pos',[100 100 600 300]);
set(0,'defaultAxesFontName', 'Arial');
hold on; grid on;
bar(0:2, per_tti_nrb_record([3 9 15],:), 'EdgeColor','white', 'LineWidth',0.1);
colorbar;
set(gca, 'YScale', 'log');
xlabel('Hour of the day');
ylabel('Occurance of RB sizes');
xticks(0:2);
xticklabels({'3','9','15'});
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
print(fig,'UL_RB_size_dist','-dpdf');
savefig('UL_RB_size_dist');

figure('rend','painters','pos',[100 100 600 300]);
set(0,'defaultAxesFontName', 'Arial');
hold on; grid on;
errorbar(0:23, mean_rb_per_tti_per_hour, min_rb_per_tti_per_hour-mean_rb_per_tti_per_hour,...
    max_rb_per_tti_per_hour-mean_rb_per_tti_per_hour, 'o');
errorbar(0:23, mean_rb_per_tti_per_hour, pctileLow_rb_per_tti_per_hour-mean_rb_per_tti_per_hour,...
    pctileHigh_rb_per_tti_per_hour-mean_rb_per_tti_per_hour, 'o');
xlabel('Hour of the day');
ylabel('Number of UL data RBs');
xlim([-1 24]);
xticks(0:2:23);
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
print(fig,'ultotalrbdis','-dpdf');
savefig('ultotalrbdis');

figure('rend','painters','pos',[100 100 600 300]);
set(0,'defaultAxesFontName', 'Arial');
hold on; grid on;
bar(0:2, hour_rb_pos_count([3 9 15],:), 'EdgeColor','white', 'LineWidth',0.1);
colorbar;
xlabel('Hour of the day');
ylabel('UL data RB usage count');
xticks(0:2);
xticklabels({'3','9','15'});
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
print(fig,'ultotalrbusage','-dpdf');
savefig('ultotalrbusage');