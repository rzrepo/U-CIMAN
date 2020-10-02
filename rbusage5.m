% process ucimandata output
%
% TTI #_of_records [RNTI LCID length initial_TA update_TA current_TA
%                   RNTI LCID length initial_TA update_TA current_TA
%                                .     .      .
%                                .     .      .
%                   RNTI LCID length initial_TA update_TA current_TA]

clc;clear;

rawDataDir = 'ucimandata';
saveDataDir = 'ucimanmatdata';
files = dir2(['./' rawDataDir]);
done_files = dir2(['./' saveDataDir]);
nof_done = numel(done_files)-1;
files(1:nof_done) = [];
[~,idx] = sort([files.datenum]);

nof_files = numel(files);
file_data = cell(1, 3);
previous_tti = -1;

for i = 1:nof_files
    % process data in one file, if data in the next file are continuous
    % save as one piece of data using file name of the first file
    % otherwise, save separately
    fid=fopen(['./' rawDataDir '/' files(idx(i)).name]);
    while true
        i
        size(file_data,1)
        [tti, record, file_end] = read_one_tti(fid);
        if record{2} > 0
            if previous_tti == -1
                file_data = record;
            else
                diff = mod(tti + 10240 - previous_tti,10240);
                file_data(end+diff,:) = record;
                if diff > 1
                    for j = 1:(diff-1)
                        file_data{end-j,1} = mod(abs(tti-j),10240);
                        file_data{end-j,2} = 0;
                    end
                end
            end
            previous_tti = tti;
        end
        if file_end
            fclose(fid);
            Folder = cd;
            Folder = fullfile(Folder, ['/' saveDataDir]);
            name = files(idx(i)).name;
            save(fullfile(Folder, [name '.mat']), 'file_data');
            file_data = cell(1, 3);
            previous_tti = -1;
            disp(name);
            break;
        end
    end
end


function [tti, record, file_end] = read_one_tti(fid)
    nof_rntis = 0;
    tti = -1;
    record = cell(1,3);
    file_end = false;
    tti_end = false;
    started = false;
    details = [];
    if ~feof(fid)
        tline = fgetl(fid);
    else
        file_end = true;
        return;
    end
    line = regexp(tline,'\t','split');
    while true
        if ~started
            if numel(line) == 2
                SFN = str2double(line(1));
                sfi = str2double(line(2));            
                tti = SFN*10 + sfi;
                started = true;
            else
                if ~feof(fid)
                    tline = fgetl(fid);
                else
                    file_end = true;
                    return;
                end
                line = regexp(tline,'\t','split');
            end
        else
            [one_rnti_record, file_end, tti_end] = read_one_rnti(fid, tti);
            if one_rnti_record(1)>0
                nof_rntis = nof_rntis + 1;
                details = [details; one_rnti_record];
            end
            if tti_end
                record{1} = tti;
                record{2} = nof_rntis;
                record{3} = details;
                break;
            end
        end
    end
end


function [one_rnti_record, file_end, tti_end] = read_one_rnti(fid, tti)
    tti_end = false;
    file_end = false;
    started = false;
    rnti = -1;
    lcid = -1;
    length = -1;
    init_TA = -1;
    update_TA = -1;
    current_TA = -1;
    one_rnti_record = [rnti lcid length init_TA update_TA current_TA];
    while ~feof(fid)
        tline = fgetl(fid);
        line = regexp(tline,'\t','split');
        if ~started
            if numel(line) == 5
                tti_this = 10*str2double(line(1)) + str2double(line(2));
                if tti_this == tti
                    started = true;
                    rnti = str2double(line(5));
                    total_length = str2double(line(4))/8; % total length in bytes
                else
                    fseek(fid, -strlength(tline)-8, 'cof');
                    tti_end = true;
                    return;
                end
                break;
            end
        end
    end

    if rnti < 65524
        if ~feof(fid)
            tline = fgetl(fid);
        else
            file_end = true;
            tti_end = true;
            return;
        end
        split_line = regexp(tline,' ','split');
    % 'MAC SDU for UL/DL-SCH. Number of Subheaders: 3'
    % 'MAC PDU for RAR. Number of Subheaders: 1'
        try
            pkt_type = split_line{2};
            nof_sub = extractAfter(tline, 'Number of Subheaders: ');
            nof_sub = str2double(nof_sub);
        catch
            disp(tline);
            pkt_type = 'SDU';
            nof_sub = 1;
        end
        if nof_sub > 1
            temp_lcid_length = zeros(nof_sub, 2);
        end
        for j = 1:nof_sub
            if ~feof(fid)
                tline = fgetl(fid);
            else
                file_end = true;
                tti_end = true;
                break;
            end
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
                    try
                        lcid = sscanf(split_line{6}, 'LCHID=%f,');
                        nof_bytes = sscanf(split_line{8}, 'nof_bytes=%f,');
                    catch
                        disp(tline);
                        disp(split_line);
                        continue;
                    end
                    try
                        temp_lcid_length(j,1) = lcid;
                        temp_lcid_length(j,2) = nof_bytes;
                    catch
                        disp(split_line);
                    end
                elseif strcmp(sub_header_type, 'Time')
    % ' -- Subheader 1: Time Advance Command CE: 0'
                    update_TA = str2double(split_line{end});
                end
            elseif strcmp(pkt_type, 'PDU')
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
    end
    length = total_length;            
    one_rnti_record = [rnti lcid length init_TA update_TA current_TA];
    
    if ~feof(fid)
        tline = fgetl(fid);
        fseek(fid, -strlength(tline)-1, 'cof');
        line = regexp(tline,'\t','split');
        if numel(line)>=5
            SFN_test = str2double(line(1));
            sfi_test = str2double(line(2));            
            tti_test = SFN_test*10 + sfi_test;
            if tti_test == tti_this
                tti_end = false;
            else
                tti_end = true;
            end
        else
            tti_end = true;
        end
    else
        file_end = true;
        tti_end = true;
    end
end