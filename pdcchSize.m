% analyze pdcch size
clc;clear;

if exist(fullfile(cd, 'dciProcessed.mat'), 'file')
    load('dciProcessed.mat');
else
    dataDir = 'oneDaymatdata';
    files = dir2(['./' dataDir]);
    [~,idx] = sort([files.datenum]);
    nof_files = numel(files);

    hour_count = zeros(24, 4); % count the number of cfi = 0, 1, 2, 3
    hour_seq = zeros(24, 1 + 3600*1000); % the sequence of cfi in an hour
    hour_mean = zeros(24,1); % the mean
    hour_std = zeros(24,1); % the variance

    for i = 1:nof_files
        shour = extractBetween(files(idx(i)).name,16,17);
        dhour = str2double(shour);
        if dhour>23 || dhour<0
            disp('Wrong hour!! Something wrong happened!!');
            return;
        end
        load(['./' dataDir '/' files(idx(i)).name]);
        cfi = ten_sec_usage(:,end);
        if max(cfi)>3 || min(cfi)<0
            disp(['Wrong cfi value at ' files(idx(i)).name]);
            return;
        end
        for j = 1:4
            hour_count(dhour+1, j) = hour_count(dhour+1, j) + sum(cfi==j-1);
        end
        start_idx = hour_seq(dhour+1, 1) + 2;
        end_idx = hour_seq(dhour+1, 1) + length(cfi) + 1;
        hour_seq(dhour+1, start_idx:end_idx) = cfi;
        hour_seq(dhour+1, 1) = hour_seq(dhour+1, 1) + length(cfi);
    end

    for i = 1:24
        nof_elements = hour_seq(i,1);
        if nof_elements == 0
            hour_mean(i) = -100;
            hour_std(i) = -100;
        else
            hour_cfi = hour_seq(i,2:(1+nof_elements));
            %
            hour_cfi(hour_cfi==0) = 1;
            hour_mean(i) = mean(hour_cfi);
            hour_std(i) = std(hour_cfi);
        end
        hour_count(i,:) = hour_count(i,:);
    end
    save('dciProcessed.mat');
end

hour_count_p = zeros(24,3);
hour_count_p(:,[2 3]) = hour_count(:,[3,4]);
hour_count_p(:,1) = hour_count(:,1) + hour_count(:,2);
f = figure('rend','painters','pos',[100 100 600 300]);
% colormap copper;
% cmap = colormap;
% newcolors = cmap([4, 34, 64],:);
% set(f, 'defaultAxesColorOrder', newcolors);
set(0,'defaultAxesFontName', 'Arial');
hold on; grid on;
grid on; hold on;
bar(0:23, hour_count_p, 'stack');
xlabel('Hour of the day');
ylabel('PDCCH sizes');
xlim([-1 24]);
% xticks(0:2:23);
l = legend('Size 1','Size 2','Size 3', 'Location', 'Best');
set(l,'FontSize',24);
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset;
ti = ti*2.45;
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
print(fig,'pdcchsize1','-dpdf');
savefig('pdcchsize1');

figure('rend','painters','pos',[100 100 600 300]);
set(0,'defaultAxesFontName', 'Arial');
grid on; hold on;
errorbar(0:23, hour_mean, hour_std, 'o');
% xlabel({'First line';'Second line'})
xlabel('Hour of the day');
ylabel('Averge size of PDCCH');
xlim([-1 24]);
xticks(0:2:23);
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
print(fig,'pdcchsize2','-dpdf');
savefig('pdcchsize2');