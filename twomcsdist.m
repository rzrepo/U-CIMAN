% Total MCS distribution versus last occu MCS distribution

last_occu_mcs = zeros(24,32);
before_last_occu_mcs = zeros(24,32);
total_mcs = zeros(24,32);

if exist(fullfile(cd, 'twomcsdist.mat'), 'file')
    load('twomcsdist.mat');
else
    dataDir = 'oneDaymatdataV2';
    files = dir2(['./' dataDir]);
    [~,idx] = sort([files.datenum]);
    nof_files = numel(files);

    nrb = 50;

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
            disp(['Wrong MCS value at ' files(idx(i)).name]);
            return;
        end
        dlrb = dlrb';
        zero_pos = dlrb==0;
        zero_pos(:,1) = [];
        zero_pos(:,end+1) = 0;
        before_zero_mcs = dlrb(zero_pos);
        non_zero_pos = dlrb~=0;
        non_zero_pos(:,1) = [];
        non_zero_pos(:,end+1) = 0;
        before_last_one_pos = dlrb(non_zero_pos);
        for j = 1:32            
            last_occu_mcs(dhour+1,j) = last_occu_mcs(dhour+1,j) + sum(before_zero_mcs==j-1);
            before_last_occu_mcs(dhour+1,j) = before_last_occu_mcs(dhour+1,j) + sum(before_last_one_pos==j-1);
            total_mcs(dhour+1,j) = total_mcs(dhour+1,j) + sum(sum(dlrb==j-1));
        end
    end
    save('twomcsdist.mat');
end

last_occu_total = sum(sum(last_occu_mcs));
before_last_occu_total = sum(sum(before_last_occu_mcs));
tt = sum(sum(total_mcs));

figure('rend','painters','pos',[100 100 600 300]);
set(0,'defaultAxesFontName', 'Arial');
hold on; grid on;
bar(0:31,[100*sum(last_occu_mcs)/last_occu_total;100*sum(before_last_occu_mcs)/before_last_occu_total;100*sum(total_mcs)/tt]',...
    'EdgeColor','white', 'LineWidth',0.1);
xlabel('MCS');
ylabel('Percentage');
% xticks(0:2);
% xticklabels({'3','9','15'});
xlim([-1 32]);
legend('MCS before idle', 'MCS before occu.', 'All MCS', 'Location', 'Best');
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset;
ti = ti * 2.45;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
set(findall(gcf,'-property','FontSize'),'FontSize',28);
print(fig,'twomcsdist','-dpdf');
savefig('twomcsdist');

