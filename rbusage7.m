% Based on the output of rbusage6, the usage with updated TAs, and the
% output of rbusage3, the occupancy marked with RNTIs, produce RB usage
% marked by TA to observe if TA affects RB assignment

% clc;clear;

if exist(fullfile(cd, 'TAoccuData.mat'), 'file')
    load('TAoccuData.mat');
else
    TADataDir = 'ucimanmatdata1';
    name_postfix = {'21', '22', '23', '24'};
    occuDataDir = ['zip' name_postfix 'matdata'];
    tafiles = dir2(['./' TADataDir]);
    tadata = [];
    taoccudata = [];
    occuTimes = cell(1,4);
    for i = 1:4
        occuDir = ['zip' name_postfix{i} 'matdata'];
        occufiles = dir2(['./' occuDir]);
        nof_occufile = numel(occufiles);
        onedaytimes = zeros(nof_occufile,7);
        [~,idx] = sort([occufiles.datenum]);
        for j = 1:nof_occufile
            occuname = occufiles(idx(j)).name;
            onedaytimes(j,:) = sscanf(occuname, 'rbu_%d-%d-%d_%d.%d.%d.%d.mat')';
        end
        occuTimes{i} = onedaytimes;
    end

    nof_tafiles = numel(tafiles);

    [~,idx] = sort([tafiles.datenum]);
    for i = 429:nof_tafiles
        i
        % load ta data
        load(['./' TADataDir '/' tafiles(idx(i)).name]);
        tafilename = tafiles(idx(i)).name;
        daytime = sscanf(tafilename, 'the_%d-%d-%d_%d.%d.%d.%d.mat')';
        % load corresponding occu data file
        loadfilename = findFiles(daytime,occuTimes);
        usage = [];
        for j = 1:numel(loadfilename)        
            load(['zip' num2str(daytime(3),'%02d') 'matdata/' loadfilename{j}]);
            usage = [usage;ten_sec_usage];
        end
        usage(:,52:end) = [];
        % go over c_file_data keep [tti, rnti, current TA]
        nof_line = size(c_file_data,1);
    %    tadataOneFile = [];
        for j = 1:nof_line
            records = c_file_data{j,3};
            nof_records = size(records,1);
            for k = 1:nof_records
                if records(k,6)>0
                    tadataOneFile = [tadataOneFile; c_file_data{j,1} records(k,1) records(k,6)];
                end
            end
        end
        % find occupancy at right tti
        if ~isempty(tadataOneFile)
            taoccudataOnefile = findTAOccuTTI(tadataOneFile, usage);
            taoccudata = [taoccudata; taoccudataOnefile];
        end
    end

    % save the results of RB occupancy marked by TAs
    save('TAoccuData.mat', 'taoccudata', 'i');
end

% plot
nof_records = size(taoccudata,1);
chosen = randperm(nof_records,2000)';
chosen_taoccudate = taoccudata(chosen,:);

% Fig #1, TA vs RB
figure('rend','painters','pos',[100 100 600 300]);
c = get(gca,'colororder');
c = c(1,:);
set(0,'defaultAxesFontName', 'Arial');
subplot(2,2,1);
hold on; grid on;
oneRB = 20;
histData = chosen_taoccudate(:,oneRB);
histData(histData==0) = [];
h = histogram(histData);
h.FaceColor = c;
h.EdgeColor = c;
set(gca,'YScale','log');
xticks(0:100:200);
% title('RB 1 TA');
xlabel('TA');
ylabel('RB20');

subplot(2,2,2);
hold on; grid on;
oneRB = 30;
histData = chosen_taoccudate(:,oneRB);
histData(histData==0) = [];
h = histogram(histData);
h.FaceColor = c;
h.EdgeColor = c;
set(gca,'YScale','log');
xticks(0:100:200);
% title('RB 25 TA');
xlabel('TA');
ylabel('RB30');

subplot(2,2,3);
hold on; grid on;
oneRB = 40;
histData = chosen_taoccudate(:,oneRB);
histData(histData==0) = [];
h = histogram(histData);
h.FaceColor = c;
h.EdgeColor = c;
set(gca,'YScale','log');
xticks(0:100:200);
% title('RB 40 TA');
xlabel('TA');
ylabel('RB40');

subplot(2,2,4);
hold on; grid on;
allHistData = chosen_taoccudate(:,2:51);
allHistData = reshape(allHistData,[],1);
allHistData(allHistData==0) = [];
h = histogram(allHistData);
h.FaceColor = c;
h.EdgeColor = c;
set(gca,'YScale','log');
xticks(0:100:200);
% title('TA of all RBs');
xlabel('TA');
ylabel('All RB');

set(findall(gcf,'-property','FontSize'),'FontSize', 26);
savefig('TAvsrb');

% 'rbu_%f-%f-%f_%f_%f.%f.mat'
function loadfilename = findFiles(daytime,occuTimes)
    day = daytime(3);
    h = daytime(4);
    m = daytime(5);
    s = daytime(6)+daytime(7)/1000;
    filetime = h*3600 + m*60 + s;
    alltimes = occuTimes{day-20};
    abstime = alltimes(:,4)*3600 + alltimes(:,5)*60 + alltimes(:,6) + ...
        alltimes(:,7)/1000;
    diff = abstime - filetime;
    idx = find(diff>0, 1);
    % idx only
    loadfilename{1} = sprintf('rbu_%4d-%02d-%02d_%02d.%02d.%02d.%03d.mat', ...
        alltimes(idx,:));
    if diff(idx) < 10 && idx~=numel(alltimes)
        % idx and the one after
        extra = sprintf('rbu_%4d-%02d-%02d_%02d.%02d.%02d.%03d.mat', ...
            alltimes(idx+1,:));
        loadfilename{2} = extra;
    end
    if diff(idx) > 110 && idx~=-3
        % idx and the one before
        extra = sprintf('rbu_%4d-%02d-%02d_%02d.%02d.%02d.%03d.mat', ...
            alltimes(idx-1,:));
        loadfilename{2} = loadfilename{1};
        loadfilename{1} = extra;
    end
end

function taoccudataOnefile = findTAOccuTTI(tadataOneFile, usage)
    % tadataOneFile [tti, rnti, current TA]
    % usage [tti, rnti...rnti]
    % taoccudataOnefile [tti, ta...ta]
    % find the starting point, and then count nof_match if start from here
    % loop all possible start points and choose the most one
    startingtti = tadataOneFile(1);
    nof_line_tadataOneFile = size(tadataOneFile,1);
    nof_line_usage = 1:size(usage,1);
    usageidx = nof_line_usage(usage(:,1)==startingtti);
    matchCount = zeros(1,numel(usageidx));
    nof_matchCount = numel(matchCount);
    diff = mod(tadataOneFile(:,1) - startingtti + 10240, 10240);
    thelineidx = usageidx + diff;
    for i = 1:nof_matchCount
        for j =1:nof_line_tadataOneFile
            start_tti = thelineidx(j,i);
            end_tti = min(start_tti+19999, size(usage,1));
            nof_match = sum(sum(usage(start_tti:end_tti, 2:51)==tadataOneFile(j,2)));
            matchCount(i) = matchCount(i) + nof_match;
        end
    end
    if max(matchCount)>0        
        [~,maxidx] = max(matchCount);
        thegroupofttiidx = thelineidx(:,maxidx);
        start_idx = thegroupofttiidx(1);
        end_idx = thegroupofttiidx(end);
        total_length = min(mod(end_idx+10240-start_idx,10240)+1+19999,size(usage,1)-start_idx);
        tmplt = usage(start_idx:(start_idx+total_length)-1,:);
        taoccudataOnefile = zeros(total_length, 51);
        for i = 1:nof_line_tadataOneFile            
            theLine = mod(thegroupofttiidx(i)+10240-start_idx,10240)+1;
            endLine = min(theLine + 19999, total_length);
            taoccudataOnefile(theLine:endLine,2:51)=taoccudataOnefile(theLine:endLine,2:51)+...
                tadataOneFile(i,3).*(tmplt(theLine:endLine,2:51)==tadataOneFile(i,2))...
                .*(taoccudataOnefile(theLine:endLine,2:51)<=0);
            taoccudataOnefile(theLine:endLine,1) = tmplt(theLine:endLine,1);
        end
        line_sum = sum(taoccudataOnefile(:,2:51),2);
        taoccudataOnefile(line_sum<=0,:) = [];
    else
        taoccudataOnefile = [];
    end
end