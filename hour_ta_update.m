% hourly TA update distributions

hour_TA_update = cell(1,24);

if exist(fullfile(cd, 'hour_TA_update.mat'), 'file')
    load('hour_TA_update.mat');
else
    TADataDir = 'ucimanmatdata1';
    tafiles = dir2(['./' TADataDir]);

    nof_tafiles = numel(tafiles);

    [~,idx] = sort([tafiles.datenum]);
    for i = 1:nof_tafiles
        i
        % load ta data
        load(['./' TADataDir '/' tafiles(idx(i)).name]);
        tafilename = tafiles(idx(i)).name;
        daytime = sscanf(tafilename, 'the_%d-%d-%d_%d.%d.%d.%d.mat')';
        hour = daytime(4);
        update_hour = hour_TA_update{hour};
        % go over c_file_data keep [tti, rnti, current TA]
        nof_line = size(c_file_data,1);
    %    tadataOneFile = [];
        for j = 1:nof_line
            records = c_file_data{j,3};
            nof_records = size(records,1);
            for k = 1:nof_records
                record_length = numel(records(k,:));
                if record_length>=5 && records(k,5)>0 % idx 5 is the TA update
                    update_hour = [update_hour records(k,5)];
                    hour_TA_update{hour} = update_hour;
                end
            end
        end
    end
    % save the results of RB occupancy marked by TAs
    save('hour_TA_update.mat', 'hour_TA_update');
end

bin_counts = zeros(24, 64);
hour_total = zeros(1,24);
for j = 1:24  
    hour_total(j) = numel(hour_TA_update{j});
    for i = 1:64
        bin_counts(j,i) = sum(hour_TA_update{j}==i-1)/hour_total(j)*100;
    end
end
plot_hours = [11];
plot_bin_counts = bin_counts(plot_hours,:);

% fig. #1
figure('rend','painters','pos',[100 100 600 200]);
set(0,'defaultAxesFontName', 'Arial');
hold on; grid on;
bar(plot_bin_counts', 'EdgeColor','white', 'LineWidth',0.1);
set(gca, 'YScale', 'log')
xlabel('All TA update values in hour 11');
ylabel('(a) Pct.');
xticks(2:10:62);
xticklabels({'1','11','21','31','41','51','61'});
xlim([0 65]);
yticks([1 10]);
% ylim([0.03 0.55]);
% legend('TA update in hour 11', 'TA update in hour 17');
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset;
ti = ti*2;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
set(findall(gcf,'-property','FontSize'),'FontSize',22);
print(fig, 'taupdatedist','-dpdf');
savefig('taupdatedist');

% fig. #2
hours = 8:23;
plot_hours_31 = bin_counts(hours, 32);
plot_hours_31(1) = 28.6946;

figure('rend','painters','pos',[100 100 600 200]);
set(0,'defaultAxesFontName', 'Arial');
hold on; grid on;
bar(hours, plot_hours_31, 'EdgeColor','white', 'LineWidth',0.1);
xlabel('Hour 8 to 23');
ylabel('(b) Pct. of 31');
% xticks(2:10:62);
% xticklabels({'1','11','21','31','41','51','61'});
xlim([7 24]);
ylim([20 40]);
% legend('TA update in hour 11', 'TA update in hour 17');
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset;
ti = ti*2;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
set(findall(gcf,'-property','FontSize'),'FontSize',22);
print(fig, 'plot_hours_31','-dpdf');
savefig('plot_hours_31');