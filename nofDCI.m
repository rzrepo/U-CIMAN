% analyze per TTI # of scheduling or DCIs

clc;clear;

if exist(fullfile(cd, 'nofDCI.mat'), 'file')
    load('nofDCI.mat');
else
    dataDir = 'oneDaymatdata';
    files = dir2(['./' dataDir]);
    [~,idx] = sort([files.datenum]);
    nof_files = numel(files);

    nrb = 50;

    mean_dci_per_tti_per_hour = zeros(24, 1); % average number of rb per tti
    pctileLow_dci_per_tti_per_hour = zeros(24, 1); % 15 percentile of rb per tti
    pctileHigh_dci_per_tti_per_hour = zeros(24, 1); % 85 percentile of rb per tti
    min_dci_per_tti_per_hour = zeros(24, 1); % min rb per tti
    max_dci_per_tti_per_hour = zeros(24, 1); % max rb per tti

    hour_dci = cell(24,2);

    for i = 1:24
        hour_dci{i,1} = 0;
        hour_dci{i,2} = zeros(1, 3600*1000);
    end

    for i = 1:nof_files
        shour = extractBetween(files(idx(i)).name,16,17);
        dhour = str2double(shour);
        if dhour>23 || dhour<0
            disp('Wrong hour!! Something wrong happened!!');
            return;        
        end
        load(['./' dataDir '/' files(idx(i)).name]);
        rb = ten_sec_usage(:,2:(end-1));
        if max(max(rb))>65535 || min(min(rb))<0
            disp(['Wrong rnti value at ' files(idx(i)).name]);
            return;
        end
        rb = rb';
        nof_c = size(rb, 2);
        start_idx = hour_dci{dhour+1, 1} + 1;
        end_idx = hour_dci{dhour+1, 1} + nof_c;
        if end_idx>3600*1000
            continue;
        else
            for j = 1:nof_c
                current_c = rb(:,j);
                current_c(current_c==0) = [];
                hour_dci{dhour+1, 2}(start_idx + j -1) = length(unique(current_c));
            end            
            hour_dci{dhour+1, 1} = hour_dci{dhour+1, 1} + nof_c;
        end
    end
    
    for i = 1:24
        currentH_count = hour_dci{i,1};
        currentH = hour_dci{i,2};
        currentH = currentH(1:currentH_count);

        mean_dci_per_tti_per_hour(i) = mean(currentH);
        pctileLow_dci_per_tti_per_hour(i) = prctile(currentH, 20);
        pctileHigh_dci_per_tti_per_hour(i) = prctile(currentH, 80);
        min_dci_per_tti_per_hour(i) = prctile(currentH, 1);
        max_dci_per_tti_per_hour(i) = prctile(currentH, 99);
    end
    save('nofDCI.mat', '-v7.3');
end

for i = 1:24
    currentH_count = hour_dci{i,1};
    currentH = hour_dci{i,2};
    currentH = currentH(1:currentH_count);

    mean_dci_per_tti_per_hour(i) = mean(currentH);
    pctileLow_dci_per_tti_per_hour(i) = prctile(currentH, 20);
    pctileHigh_dci_per_tti_per_hour(i) = prctile(currentH, 80);
    min_dci_per_tti_per_hour(i) = prctile(currentH, 1);
    max_dci_per_tti_per_hour(i) = prctile(currentH, 99);
end

figure('rend','painters','pos',[100 100 600 300]);
set(0,'defaultAxesFontName', 'Arial');
grid on; hold on;
errorbar(0:23, mean_dci_per_tti_per_hour, min_dci_per_tti_per_hour-mean_dci_per_tti_per_hour,...
    max_dci_per_tti_per_hour-mean_dci_per_tti_per_hour, 'o');
errorbar(0:23, mean_dci_per_tti_per_hour, pctileLow_dci_per_tti_per_hour-mean_dci_per_tti_per_hour,...
    pctileHigh_dci_per_tti_per_hour-mean_dci_per_tti_per_hour, 'o');
xlabel('Hour of the day');
ylabel('Number of DCIs');
xlim([-1 24]);
ylim([0 15]);
% xticks(0:2:23);
legend('  1 to 99 pct.', '20 to 80 pct.', 'Location', 'Best');
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
set(findall(gcf,'-property','FontSize'),'FontSize',28);
print(fig,'nofDCI','-dpdf');
savefig('nofDCI');