% examine why high usage, on/off time they other way
clear;clc;

if exist(fullfile(cd, 'contra.mat'), 'file')
    load('contra.mat');
else
    cmp_idx = [2,15];
    tts_inh = zeros(1,numel(cmp_idx));
    records = cell(1,numel(cmp_idx));

    is_same = zeros(numel(cmp_idx),2);

    nrb = 50;

    hour_rb_pos_count = zeros(2, nrb); % count the number of each rb index
    mean_rb_per_tti_per_hour = zeros(2, 1); % average number of rb per tti
    pctileLow_rb_per_tti_per_hour = zeros(2, 1); % 15 percentile of rb per tti
    pctileHigh_rb_per_tti_per_hour = zeros(2, 1); % 85 percentile of rb per tti
    min_rb_per_tti_per_hour = zeros(2, 1); % min rb per tti
    max_rb_per_tti_per_hour = zeros(2, 1); % max rb per tti
    per_tti_nrb_record = zeros(2, 1 + nrb); % distribution of number of rb per tti

    mean_dl_interRb_interval = zeros(2, nrb); % average number of rb per tti
    pctileLow_dl_interRb_interval = zeros(2, nrb); % 15 percentile of rb per tti
    pctileHigh_dl_interRb_interval = zeros(2, nrb); % 85 percentile of rb per tti
    min_dl_interRb_interval = zeros(2, nrb); % min rb per tti
    max_dl_interRb_interval = zeros(2, nrb); % max rb per tti

    mean_dl_interRb_onTime = zeros(2, nrb); % average number of rb per tti
    pctileLow_dl_interRb_onTime = zeros(2, nrb); % 15 percentile of rb per tti
    pctileHigh_dl_interRb_onTime = zeros(2, nrb); % 85 percentile of rb per tti
    min_dl_interRb_onTime = zeros(2, nrb); % min rb per tti
    max_dl_interRb_onTime = zeros(2, nrb); % max rb per tti

    mean_dl_interRb_offTime = zeros(2, nrb); % average number of rb per tti
    pctileLow_dl_interRb_offTime = zeros(2, nrb); % 15 percentile of rb per tti
    pctileHigh_dl_interRb_offTime = zeros(2, nrb); % 85 percentile of rb per tti
    min_dl_interRb_offTime = zeros(2, nrb); % min rb per tti
    max_dl_interRb_offTime = zeros(2, nrb); % max rb per tti

    mean_dl_interRb_DR = zeros(2, nrb); % average number of rb per tti
    pctileLow_dl_interRb_DR = zeros(2, nrb); % 15 percentile of rb per tti
    pctileHigh_dl_interRb_DR = zeros(2, nrb); % 85 percentile of rb per tti
    min_dl_interRb_DR = zeros(2, nrb); % min rb per tti
    max_dl_interRb_DR = zeros(2, nrb); % max rb per tti

    for i = 1:numel(cmp_idx)

        load('dlInterRb.mat','hour_cell');
        nof_tts_a = hour_cell{cmp_idx(i),1};
        tts_a = hour_cell{cmp_idx(i),2}(:,1:nof_tts_a);
        clear hour_cell;
        load('dlrbcellprocessed.mat','hour_cell');
        nof_tts_i = hour_cell{cmp_idx(i),1};
        tts_i = hour_cell{cmp_idx(i),2}(1:nof_tts_i);
        clear hour_cell;
        same1 = nof_tts_a*50==nof_tts_i;

        if same1 == 1        
            tts_i_p = reshape(tts_i, 50, []);
            same2 = sum(sum(tts_i_p==tts_a))==nof_tts_i;
            is_same(i,1) = same1;
            is_same(i,2) = same2;
            tts_inh(i) = nof_tts_i;
            records{i} = tts_i;
        else
            continue;
        end
    end
    save('contra.mat', '-v7.3');
end
    
for i = 1:numel(cmp_idx)
    nof_tts_i = tts_inh(i);
    tts_i = records{i};
    currentH = tts_i(1:nof_tts_i);
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
    
    for j = 1:nrb
        tts_i_p = reshape(tts_i,50,[]);
        rb_usage = tts_i_p(j,1:tts_inh(i)/50);

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
        end
    end
end

    % Fig #2, on time 2 hours, 3 and 13, all RBs
    figure('rend','painters','pos',[100 100 600 300]);
    set(0,'defaultAxesFontName', 'Arial');
    hold on; grid on;
    errorbar([1:50 56:105], [mean_dl_interRb_onTime(1,:) mean_dl_interRb_onTime(2,:)],...
        [min_dl_interRb_onTime(1,:) min_dl_interRb_onTime(2,:)] - [mean_dl_interRb_onTime(1,:) mean_dl_interRb_onTime(2,:)],...
        [max_dl_interRb_onTime(1,:) max_dl_interRb_onTime(2,:)] - [mean_dl_interRb_onTime(1,:) mean_dl_interRb_onTime(2,:)],...
        'o','MarkerSize', 2,'CapSize',2);
    errorbar([1:50 56:105], [mean_dl_interRb_onTime(1,:) mean_dl_interRb_onTime(2,:)],...
        [pctileLow_dl_interRb_onTime(1,:) pctileLow_dl_interRb_onTime(2,:)] - [mean_dl_interRb_onTime(1,:) mean_dl_interRb_onTime(2,:)],...
        [pctileHigh_dl_interRb_onTime(1,:) pctileHigh_dl_interRb_onTime(2,:)] - [mean_dl_interRb_onTime(1,:) mean_dl_interRb_onTime(2,:)],...
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
%     print(fig,['dl2h50rbontime' name_postfix],'-dpdf');
%     savefig(['dl2h50rbontime' name_postfix]);



    % Fig #3, off time 2 hours, 3 and 13, all RBs
    figure('rend','painters','pos',[100 100 600 300]);
    set(0,'defaultAxesFontName', 'Arial');
    hold on; grid on;
    errorbar([1:50 56:105], [mean_dl_interRb_offTime(1,:) mean_dl_interRb_offTime(2,:)],...
        [min_dl_interRb_offTime(1,:) min_dl_interRb_offTime(2,:)] - [mean_dl_interRb_offTime(1,:) mean_dl_interRb_offTime(2,:)],...
        [max_dl_interRb_offTime(1,:) max_dl_interRb_offTime(2,:)] - [mean_dl_interRb_offTime(1,:) mean_dl_interRb_offTime(2,:)],...
        'o','MarkerSize', 2,'CapSize',2);
    errorbar([1:50 56:105], [mean_dl_interRb_offTime(1,:) mean_dl_interRb_offTime(2,:)],...
        [pctileLow_dl_interRb_offTime(1,:) pctileLow_dl_interRb_offTime(2,:)] - [mean_dl_interRb_offTime(1,:) mean_dl_interRb_offTime(2,:)],...
        [pctileHigh_dl_interRb_offTime(1,:) pctileHigh_dl_interRb_offTime(2,:)] - [mean_dl_interRb_offTime(1,:) mean_dl_interRb_offTime(2,:)],...
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
%     print(fig,['dl2h50rbofftime' name_postfix],'-dpdf');
%     savefig(['dl2h50rbofftime' name_postfix]);


    figure('rend','painters','pos',[100 100 600 300]);
    set(0,'defaultAxesFontName', 'Arial');
    hold on; grid on;
    errorbar(0:1, mean_rb_per_tti_per_hour, min_rb_per_tti_per_hour-mean_rb_per_tti_per_hour,...
        max_rb_per_tti_per_hour-mean_rb_per_tti_per_hour, 'o');
    errorbar(0:1, mean_rb_per_tti_per_hour, pctileLow_rb_per_tti_per_hour-mean_rb_per_tti_per_hour,...
        pctileHigh_rb_per_tti_per_hour-mean_rb_per_tti_per_hour, 'o');
    xlabel('Hour of the day');
    ylabel('Number of DL RBs');
    xlim([-1 24]);
    xticks(0:2:23);
    legend('Min-max', '15 to 85 PCTL', 'Location', 'Best');
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
%     print(fig,['dltotalrbdis' name_postfix],'-dpdf');
%     savefig(['dltotalrbdis' name_postfix]);
