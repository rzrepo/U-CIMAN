% analyze per rnti statistics

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;clear;

if exist(fullfile(cd, 'ulperRnti.mat'), 'file')
    load('ulperRnti.mat');
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

    hour_cell = cell(24,2);
    rnti_hour = cell(24,2);

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
        ulrb = ten_sec_usage(:, (nrb+2):(end-1));
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
        
        listOfrnti = unique(currentH);
        listOfrnti(listOfrnti>65523) = []; % C-RNTI range 0x0001-0xfff3
        listOfrnti(listOfrnti<1) = [];
        nofrnti = length(listOfrnti);
        
        rnti_hour{i,1} = nofrnti; % total number of C-RNTIs per hour
        rnti_hour{i,2} = cell(nofrnti,2); % 
        
        for j = 1:nofrnti            
            i
            j
            nofrnti
            rnti_hour{i,2}{j,1} = listOfrnti(j);
            p_currentH = reshape(currentH, nrb, numel(currentH)/nrb);
            ttiWithRnti = sum(p_currentH == listOfrnti(j));
            p1_ttiWithRnti = ttiWithRnti>0;
            p2_ttiWithRnti = zeros(size(p1_ttiWithRnti));
            p2_ttiWithRnti(2:end) = p1_ttiWithRnti(2:end) - p1_ttiWithRnti(1:(end-1));
            m1_pos = find(p2_ttiWithRnti == -1);
            p1_pos = find(p2_ttiWithRnti == 1);
            if isempty(m1_pos) || isempty(p1_pos)
                continue;
            end
            if m1_pos(1) < p1_pos(1)
                if length(m1_pos) > 2
                    nof_records = length(m1_pos) - 1;
                    rnti_hour{i,2}{j,2} = zeros(nof_records,3);
                    for k = 1:nof_records
                        rnti_hour{i,2}{j,2}(k, 1) = p1_pos(k);
                        rnti_hour{i,2}{j,2}(k, 2) = m1_pos(k+1) - p1_pos(k);
                        rnti_hour{i,2}{j,2}(k, 3) = sum(ttiWithRnti(p1_pos(k):m1_pos(k+1)));
                    end
                else
                    continue;
                end
            else
                if length(m1_pos) + length(p1_pos) > 1
                    nof_records = length(m1_pos);
                    rnti_hour{i,2}{j,2} = zeros(nof_records,3);
                    for k = 1:nof_records
                        rnti_hour{i,2}{j,2}(k, 1) = p1_pos(k);
                        rnti_hour{i,2}{j,2}(k, 2) = m1_pos(k) - p1_pos(k);
                        rnti_hour{i,2}{j,2}(k, 3) = sum(ttiWithRnti(p1_pos(k):m1_pos(k)));
                    end
                else
                    continue;
                end
            end
        end
    end
    save('ulperRnti.mat', '-v7.3');
end





