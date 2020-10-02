% analyze pdsch cell staticstics
clc;clear;

dataDir = 'oneDaymatdata';
files = dir2(['./' dataDir]);
[~,idx] = sort([files.datenum]);
nof_files = numel(files);

nrb = 50;

hour_rb_pos_count = zeros(24, nrb); % count the number of each rb index

mean_rb_per_tti_per_hour = zeros(24, 1); % average number of rb per tti
std_rb_per_tti_per_hour = zeros(24, 1); % std deviation rb per tti
per_tti_nrb_record = zeros(24, 1 + nrb); % distribution of number of rb per tti
nof_TTI = zeros(24, 1);


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
        disp(['Wrong cfi value at ' files(idx(i)).name]);
        return;
    end

    hour_rb_pos_count(dhour, :) = hour_rb_pos_count(dhour, :) + sum(dlrb>0);
 
    dlrb_size = numel(dlrb);
    nTTI = dlrb_size/nrb;
    dlrb = dlrb';
    local_per_tti_nrb = sum(dlrb>0);
    local_mean = mean(local_per_tti_nrb);
    mean_rb_per_tti_per_hour(dhour) = (local_mean*nTTI + mean_rb_per_tti_per_hour(dhour)*nof_TTI(dhour))/(nTTI+nof_TTI(dhour));
    nof_TTI(dhour)= nof_TTI(dhour) + nTTI;
    [count,ind] = hist(local_per_tti_nrb, unique(local_per_tti_nrb));
    per_tti_nrb_record(dhour, ind+1) = per_tti_nrb_record(dhour, ind+1) + count;
end

nof_TTI = zeros(24, 1);
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
    
    avg = mean_rb_per_tti_per_hour(dhour);
 
    dlrb_size = numel(dlrb);
    nTTI = dlrb_size/nrb;
    dlrb = dlrb';
    local_per_tti_nrb = sum(dlrb>0);
    local_std = sum((local_per_tti_nrb-avg).^2);
    std_rb_per_tti_per_hour(dhour) = local_std + std_rb_per_tti_per_hour(dhour);
    nof_TTI(dhour) = nof_TTI(dhour) + nTTI;
end
std_rb_per_tti_per_hour = std_rb_per_tti_per_hour./nof_TTI;
std_rb_per_tti_per_hour = sqrt(std_rb_per_tti_per_hour);

save('dlrbcellprocessed.mat');

figure; hold on; grid on;
bar(0:23, hour_rb_pos_count);
xlabel('Hour of the day');
ylabel('The number of used RBs in an hour');
xlim([-1 24]);

figure; hold on; grid on;
ax1 = subplot(2,1,1);
bar(ax1, 0:23, per_tti_nrb_record);
xlabel('Hour of the day');
ylabel('Distribution of the number of RBs in the downlink per TTI');
xlim([-1 24]);
subplot(2,1,2);
errorbar(mean_rb_per_tti_per_hour, std_rb_per_tti_per_hour, 'x');
xlabel('Hour of the day');
ylabel('Average number of donwlink RBs used per TTI in an hour');
xlim([-1 24]);