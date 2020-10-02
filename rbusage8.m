% Based on the output of rbusage6, the usage with packet size, and the
% output of rbusage3, the occupancy marked with RNTIs, produce RB usage
% marked by packet size to observe its impact on RB usage

clc;clear;


if exist(fullfile(cd, 'sizeoccuData.mat'), 'file')
    load('sizeoccuData.mat');
else
    sizeDataDir = 'ucimanmatdata1';
    name_postfix = {'21', '22', '23', '24'};
    occuDataDir = ['zip' name_postfix 'matdata'];
    sizefiles = dir2(['./' sizeDataDir]);
    sizedata = [];
    sizeccudata = [];
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

    nof_sizefiles = numel(sizefiles);

    [~,idx] = sort([sizefiles.datenum]);
    for i = 740:nof_sizefiles
        i
        % load ta data
        load(['./' sizeDataDir '/' sizefiles(idx(i)).name]);
        sizefilename = sizefiles(idx(i)).name;
        daytime = sscanf(sizefilename, 'the_%d-%d-%d_%d.%d.%d.%d.mat')';
        % load corresponding occu data file
        loadfilename = findFiles(daytime,occuTimes);
        usage = [];
        for j = 1:numel(loadfilename)        
            load(['zip' num2str(daytime(3),'%02d') 'matdata/' loadfilename{j}]);
            usage = [usage;ten_sec_usage];
        end
        usage(:,52:end) = [];
        % go over c_file_data keep [tti, rnti, size]
        nof_line = size(c_file_data,1);
        sizedataOneFile = [];
        for j = 1:nof_line
            records = c_file_data{j,3};
            nof_records = size(records,1);
            for k = 1:nof_records
                if numel(records(k,:))==6 && records(k,6)>0
                    sizedataOneFile = [sizedataOneFile; c_file_data{j,1} records(k,1) records(k,3)];
                end
            end
        end
        % find occupancy at right tti
        if ~isempty(sizedataOneFile)
            taoccudataOnefile = findTAOccuTTI(sizedataOneFile, usage);
            sizeccudata = [sizeccudata; taoccudataOnefile];
        end
    end

    % save the results of RB occupancy marked by TAs
    save('sizeoccuData.mat', 'sizeccudata');
end

% plot
% Fig #1, packet size vs RB, packet size cannot indicate anything about
% which RB is used, observed in this way, so not very interesting
% conclusion....
figure('rend','painters','pos',[100 100 600 300]);
c = get(gca,'colororder');
c = c(1,:);
set(0,'defaultAxesFontName', 'Arial');
subplot(2,2,1);
hold on; grid on;
oneRB = 20;
histData = sizeccudata(:,oneRB);
histData(histData==0) = [];
h = histogram(histData);
h.FaceColor = c;
h.EdgeColor = c;
set(gca,'YScale','log');
% title('RB 1 packet size');
xlabel('Size (bytes)');
ylabel('RB20');

subplot(2,2,2);
hold on; grid on;
oneRB = 25;
histData = sizeccudata(:,oneRB+1);
histData(histData==0) = [];
h = histogram(histData);
h.FaceColor = c;
h.EdgeColor = c;
set(gca,'YScale','log');
% title('RB 25 packet size');
xlabel('Size (bytes)');
ylabel('RB30');

subplot(2,2,3);
hold on; grid on;
oneRB = 40;
histData = sizeccudata(:,oneRB+1);
histData(histData==0) = [];
h = histogram(histData);
h.FaceColor = c;
h.EdgeColor = c;
set(gca,'YScale','log');
% title('RB 40 packet size');
xlabel('Size (bytes)');
ylabel('RB40');

subplot(2,2,4);
hold on; grid on;
allHistData = sizeccudata(:,2:51);
allHistData = reshape(allHistData,[],1);
allHistData(allHistData==0) = [];
h = histogram(allHistData);
h.FaceColor = c;
h.EdgeColor = c;
set(gca,'YScale','log');
% title('Packet size of all RBs');
xlabel('Size (bytes)');
ylabel('All RB');

set(findall(gcf,'-property','FontSize'),'FontSize', 26);
savefig('sizevsrb');


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

function sizeoccudataOnefile = findTAOccuTTI(sizedataOneFile, usage)
    % tadataOneFile [tti, rnti, current size]
    % usage [tti, rnti...rnti]
    % taoccudataOnefile [tti, size...size]
    % find the starting point, and then count nof_match if start from here
    % loop all possible start points and choose the most one
    startingtti = sizedataOneFile(1);
    nof_line_tadataOneFile = size(sizedataOneFile,1);
    nof_line_usage = 1:size(usage,1);
    usageidx = nof_line_usage(usage(:,1)==startingtti);
    matchCount = zeros(1,numel(usageidx));
  %  nof_matchCount = numel(matchCount);
    diff = mod(sizedataOneFile(:,1) - startingtti + 10240, 10240);
    diffcheck = [0;diff(2:end)-diff(1:end-1)];
    cut_point = find(diffcheck<0,1);
    diff(cut_point:end) = [];
    thelineidx = usageidx + diff;
    [nof_r,nof_c] = size(thelineidx);
    for i = 1:nof_c
        for j =1:nof_r
            if thelineidx(j,i) > size(usage,1)
                break;
            end
            nof_match = sum(usage(thelineidx(j,i), 2:51)==sizedataOneFile(j,2));
            matchCount(i) = matchCount(i) + nof_match;
        end
    end
    if max(matchCount)>0
        [~,maxidx] = max(matchCount);
        thegroupofttiidx = thelineidx(:,maxidx);
        thegroupofttiidx(thegroupofttiidx>size(usage,1)) = [];
        start_idx = thegroupofttiidx(1);
        end_idx = thegroupofttiidx(end);
        total_length = min(mod(end_idx+10240-start_idx,10240)+1,size(usage,1)-start_idx);
        tmplt = usage(start_idx:(start_idx+total_length)-1,:);
        sizeoccudataOnefile = zeros(total_length, 51);
        for i = 1:size(thegroupofttiidx,1) 
            try
            theLine = mod(thegroupofttiidx(i)+10240-start_idx,10240)+1;
            catch
            theLine    
            end
             try
            sizeoccudataOnefile(theLine,2:51)=sizeoccudataOnefile(theLine,2:51)...
                +sizedataOneFile(i,3).*(tmplt(theLine,2:51)==sizedataOneFile(i,2))...
                .*(sizeoccudataOnefile(theLine,2:51)<=0);
            catch
                disp(theLine);
            end
            sizeoccudataOnefile(theLine,1) = tmplt(theLine,1);
        end
        line_sum = sum(sizeoccudataOnefile(:,2:51),2);
        sizeoccudataOnefile(line_sum<=0,:) = [];
    else
        sizeoccudataOnefile = [];
    end
end