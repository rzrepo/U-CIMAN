% process ta, lcid, length
% group consecutive records together
% ta initial value, ta update, lcid and length value of the largest MAC SDU
% Bad structure, do not know how to handle end of file in this way. give
% this version up...
clc;clear;

rawDataDir = 'ucimandata';
saveDataDir = 'ucimanmatdata';

files = dir2(['./' rawDataDir]);

[~,idx] = sort([files.datenum]);

nof_files = numel(files);

current = 0;
is_first = true;

nrb = 50;
nof_TTI = 10240;

file_data = cell(1, 3);
item_index = 0;

tti_count = 1;
name = files(idx(1)).name;

for i = 1:nof_files
    fid=fopen(['./' rawDataDir '/' files(idx(i)).name]);
    while ~feof(fid)
        tline = fgetl(fid);
        line = regexp(tline,'\t','split');
        SFN = str2double(line(1));
        sfi = str2double(line(2));
        if numel(line) == 2 % regard as first line
            nof_rnti = 0;
            details = [];
            while ~feof(fid)
                tline = fgetl(fid);
                line = regexp(tline,'\t','split');
                while numel(line)<2
                    tline = fgetl(fid);
                    line = regexp(tline,'\t','split');
                end
                SFN = str2double(line(1));
                sfi = str2double(line(2));
                if numel(line) == 2
                    % regard as start of next tti
                    % record the previous stuff
                    item_index = item_index + 1;
                    file_data{item_index, 1} = SFN*10 + sfi-1; % assuming consecutive SFN, sfi
                    file_data{item_index, 2} = nof_rnti;
                    if nof_rnti>0
                        file_data{item_index, 3} = details;
                    end
                    % recorded all, so reset now
                    nof_rnti = 0;
                    details = [];
                else % accumulate records
                    total_length = str2double(line(4))/8; % total length in bytes
                    rnti = str2double(line(5));
                    if  rnti < 65524
                        lcid = -1;
                        length = -1;
                        init_TA = -1;
                        update_TA = -1;
                        current_TA = -1;
                        nof_rnti = nof_rnti + 1;
                        tline = fgetl(fid);
                        split_line = regexp(tline,' ','split');
% 'MAC SDU for UL/DL-SCH. Number of Subheaders: 3'
% 'MAC PDU for RAR. Number of Subheaders: 1'
                        pkt_type = split_line{2};
                        nof_sub = extractAfter(tline, 'Number of Subheaders: ');
                        nof_sub = str2double(nof_sub);
                        if nof_sub > 1
                            temp_lcid_length = zeros(nof_sub, 2);
                        end
                        for j = 1:nof_sub
                            tline = fgetl(fid);
                            split_line = regexp(tline,' ','split');
                            if numel(split_line) < 5
% BAD output, stop this loop, retreat the current line
% ' -- Subheader 0:  -- Subheader 1: PADDING'
% ' -- Subheader 1:   12	7	4	   5992	 5467'
                                fseek(fid, -strlength(tline)-1, 'cof');
                                break;
                            end
                            sub_header_type = split_line{5};
                            if strcmp(pkt_type, 'SDU')
    % 'MAC SDU for UL/DL-SCH. Number of Subheaders: 3'
                                if strcmp(sub_header_type, 'SDU')
    % ' -- Subheader 0: SDU LCHID=25, SDU nof_bytes=16170'
                                    lcid = sscanf(split_line{6}, 'LCHID=%f,');
                                    nof_bytes = sscanf(split_line{8}, 'nof_bytes=%f,');
                                    temp_lcid_length(j,1) = lcid;
                                    temp_lcid_length(j,2) = nof_bytes;
                                elseif strcmp(sub_header_type, 'Time')
    % ' -- Subheader 1: Time Advance Command CE: 0'
                                    update_TA = str2double(split_line{end});
                                end
                            elseif strcmp(pkt_type, 'RAR')
    % 'MAC PDU for RAR. Number of Subheaders: 1'
    % ' -- Subheader 0: RAPID: 25, Temp C-RNTI: 6061, TA: 54, UL Grant: [0b e4 c0 ];'
                                rnti = sscanf(split_line{9}, '%f,');
                                init_TA = sscanf(split_line{11}, '%f,');
                            end
                        end
                        if nof_sub > 1
                            delete_row_idx = temp_lcid_length(:,1)>10;
                            temp_lcid_length(delete_row_idx,:) = [];
                            if isempty(temp_lcid_length)
                                lcid = -1;
                            else
                                [~, long_idx] = max(temp_lcid_length(:,2));
                                temp_lcid_length = temp_lcid_length(long_idx,:);
                                lcid = temp_lcid_length(1);
                            end
                        end
                        length = total_length;
                    end
                    details = [details; rnti lcid length init_TA update_TA current_TA];
                end
            end
        else % not first two number line, should skip
            continue;
        end
    end
    Folder = cd;
    Folder = fullfile(Folder, ['/' saveDataDir]);
    save(fullfile(Folder, [name '.mat']), 'ten_sec_usage');
    name = files(idx(i)).name;
    fclose(fid);
end