% get the rb usage from mowl output
clc;clear;

rawDataDir = '0314.739mhz.data';
saveDataDir = '0314.739mhzmatdata';

files = dir2(['./' rawDataDir]);

[~,idx] = sort([files.datenum]);

nof_files = numel(files);

current = 0;
is_first = true;

nrb = 50;
nof_TTI = 120*1000;

ten_sec_usage = zeros(nof_TTI, 2+2*nrb);
tti_count = 1;
name = files(idx(1)).name;
temp_usage = zeros(1, 2+2*nrb);

for i = 1:nof_files
    fid=fopen(['./' rawDataDir '/' files(idx(i)).name]);
    while ~feof(fid)
        tline = fgetl(fid);
        line = sscanf(tline, '%f %f %f %f %f %f %f %f %f %f %f %f')';
        tti = line(1)*10+line(2);
        if is_first
            is_first = false;
            current = tti;
        else
            if current ~= tti
                ten_sec_usage(tti_count,:) = temp_usage;
                diff = round(mod(tti-current,10240));
                if diff>1
                    zero_jump_end = min(tti_count+diff-1, nof_TTI);
                    nof_zero_lines = zero_jump_end - tti_count;
                    ten_sec_usage((tti_count+1):zero_jump_end,:) = zeros(nof_zero_lines, 2+2*nrb);
                    ten_sec_usage((tti_count+1):zero_jump_end,1) = mod(((current+1):(current + nof_zero_lines))', 10240);
                end
                tti_count = tti_count+diff;
                current = tti;
                temp_usage = zeros(1, 2+2*nrb);
                if tti_count >= nof_TTI+1
                    % save ten_sec_usage as the name
                    tti_count = 1;
                    Folder = cd;
                    Folder = fullfile(Folder, ['/' saveDataDir]);
                    save(fullfile(Folder, [name '.mat']), 'ten_sec_usage');
                    % save([name '.mat'],'ten_sec_usage');
                    name = files(idx(i)).name;
                    ten_sec_usage = zeros(nof_TTI, 2+2*nrb);
                end
            end
        end
        temp_usage = get_usage2(line(7:10), line(3), line(4), temp_usage);
        temp_usage(end) = line(11);
        temp_usage(1) = mod(tti,10240);
    end
    fclose(fid);
end