% further process ucimanmatdata to update position and corresponding RB
% usage
%
% original input
% TTI #_of_records [RNTI LCID length initial_TA update_TA current_TA 
%                   RNTI LCID length initial_TA update_TA current_TA
%                                .     .      .
%                                .     .      .
%                   RNTI LCID length initial_TA update_TA current_TA]
%
% ucimanmatdata1
% TTI #_of_records [RNTI LCID length initial_TA update_TA current_TA 
%                   RNTI LCID length initial_TA update_TA current_TA
%                                .     .      .
%                                .     .      .
%                   RNTI LCID length initial_TA update_TA current_TA]
%
% ucimanmatdata2
% TTI #_of_records [RNTI LCID length initial_TA update_TA current_TA 
%                   RNTI LCID length initial_TA update_TA current_TA
%                                .     .      .
%                                .     .      .
%                   RNTI LCID length initial_TA update_TA current_TA]

clc;clear;

name_postfix = '24';
rawDataDir1 = 'ucimanmatdata';
rawDataDir2 = ['zip' name_postfix 'matdata'];
saveDataDir = 'ucimanmatdata1';
files = dir2(['./' rawDataDir1]);
done_files = dir2(['./' saveDataDir]);
nof_done = numel(done_files)-1;
files(1:nof_done) = [];
[~,idx] = sort([files.datenum]);

nof_files1 = numel(files);
previous_tti = -1;

for i = 1:nof_files1
    % process data in one file, if data in the next file are continuous
    % save as one piece of data using file name of the first file
    % otherwise, save separately
    load(['./' rawDataDir1 '/' files(idx(i)).name]);
    c_file_data = file_data;
    nof_row = size(c_file_data,1);
    TA_update_list = []; % [rnti, inital_TA, current_TA]
    for j = 1:nof_row
        i
        j
        unit = c_file_data{j,3};
        nrntis = size(unit,1);
        for k = 1:nrntis
% http://lteforgeeks.blogspot.com/2015/07/timing-advance-for-lte-a.html
% TA update
            if ~isempty(TA_update_list) && ismember(unit(k,1), TA_update_list(:,1))
                TA_update_list_position = find(TA_update_list(:,1)==unit(k,1),1);
                if unit(k,5)>0
                    TA_update_list(TA_update_list_position,3) = TA_update_list(TA_update_list_position,3)+unit(k,5)-31;
                end
                c_file_data{j,3}(k,4) = TA_update_list(TA_update_list_position,2);
                c_file_data{j,3}(k,6) = TA_update_list(TA_update_list_position,3);
            end
            if unit(k,4) > 0
                c_file_data{j,3}(k,6) = c_file_data{j,3}(k,4);
                TA_update_list = [TA_update_list; unit(k,1) unit(k,4) unit(k,4)];                
            end
        end
    end
    Folder = cd;
    Folder = fullfile(Folder, ['/' saveDataDir]);
    name = files(idx(i)).name;
    save(fullfile(Folder, [name '.mat']), 'c_file_data', 'TA_update_list');
end
