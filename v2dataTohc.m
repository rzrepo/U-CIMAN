% convert v2 data, the MCS occupancy into hour_cell format
clc;clear;

if exist(fullfile(cd, 'v2hourcell.mat'), 'file')
    load('v2hourcell.mat');
else
    dataDir = 'oneDaymatdataV2';
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
        i
        shour = extractBetween(files(idx(i)).name,16,17);
        dhour = str2double(shour);
        if dhour>23 || dhour<0
            disp('Wrong hour!! Something wrong happened!!');
            return;        
        end
        load(['./' dataDir '/' files(idx(i)).name]);
        dlrb = ten_sec_usage(:,2:(nrb+1));
        if max(max(dlrb))>31 || min(min(dlrb))<-1
            disp(['Wrong rnti value at ' files(idx(i)).name]);
            return;
        end
        dlrb = dlrb';
        dlrb = reshape(dlrb, 1, numel(dlrb));
        start_idx = hour_cell{dhour+1, 1} + 1;
        end_idx = hour_cell{dhour+1, 1} + length(dlrb);
        if end_idx>3600*1000*50
            continue;
        else
            hour_cell{dhour+1, 2}(start_idx:end_idx) = dlrb;
            hour_cell{dhour+1, 1} = hour_cell{dhour+1, 1} + length(dlrb);
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
    save('v2hourcell.mat', '-v7.3');
end
