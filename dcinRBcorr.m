% show correlations between 2 groups

clc;clear;

if exist(fullfile(cd, 'dcinRBcorr.mat'), 'file')
    load('dcinRBcorr.mat');
else
    load('dlrbcellprocessed.mat');
    clearvars -except hour_cell;
    load('nofDCI.mat');
    clearvars -except hour_cell hour_dci;
    load('dciProcessed.mat');
    clearvars -except hour_cell hour_dci hour_seq;
    pdcchsizeCnRB = zeros(24,1);
    nDCICnRB = zeros(24,1);

    for i = 1:24    
        currentH_nRB = hour_cell{i,1};
        currentnRB = hour_cell{i,2};
        currentnRB = currentnRB(1:currentH_nRB);
        currentnRB = reshape(currentnRB,50,[]);
        currentnRB = sum(currentnRB>0);

        currentH_nDCI = hour_dci{i,1};
        currentHnDCI = hour_dci{i,2};
        currentHnDCI = currentHnDCI(1:currentH_nDCI);    

        nof_pdcchsize = hour_seq(i,1);
        hour_cfi = hour_seq(i,2:(1+nof_pdcchsize));
        hour_cfi(hour_cfi==0) = 1;

        minsize = min([numel(currentnRB), numel(currentHnDCI), numel(hour_cfi)]);
        nDCICnRB(i) = mean((currentnRB-mean(currentnRB)).*(currentHnDCI-mean(currentHnDCI)))/std(currentnRB)/std(currentHnDCI);
        pdcchsizeCnRB(i) = mean((currentnRB-mean(currentnRB)).*(hour_cfi-mean(hour_cfi)))/std(currentnRB)/std(hour_cfi);
    end
    clearvars -except pdcchsizeCnRB nDCICnRB;
    save('dcinRBcorr', '-v7.3');
end


figure('rend','painters','pos',[100 100 600 300]);
set(0,'defaultAxesFontName', 'Arial');
hold on; grid on;
bar(0:23, [pdcchsizeCnRB nDCICnRB], 'EdgeColor','white', 'LineWidth',0.1);
xlabel('Hour of the day');
ylabel('\rho_{X^{nRB},X^{DCI}}');
% xticks(0:2);
% xticklabels({'3','9','15'});
xlim([-1 24]);
legend('pdcchsize-nRB', 'nDCI-nRB', 'Location', 'Best');
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
set(findall(gcf,'-property','FontSize'),'FontSize', 28);
print(fig,'dcinRBcorr','-dpdf');
savefig('dcinRBcorr');

