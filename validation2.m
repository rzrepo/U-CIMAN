% plot accuracy validation for three application types

clc;clear;
accuracy1 = [0.988, 0.991, 0.98];
yneg1 = [0.019 0.04 0.03];
ypos1 = [0.004 0.002 0.006];
accuracy2 = [0.953, 0.93, 0.929];
yneg2 = [0.023 0.09 0.06];
ypos2 = [0.006 0.022 0.017];
% x = categorical({'0.0033', '0.091', '0.13', '0.1491'});

figure('rend','painters','pos',[100 100 600 300]);
colormap copper;
cmap = colormap;
c1 = cmap(4,:);
c2 = cmap(50,:);
set(0,'defaultAxesFontName', 'Arial');
% bar((1:3)-0.35, accuracy1, 0.3,'FaceColor',[0.8 0.8 0],'EdgeColor',[0.8 0.8 0]);
% b1 = bar((1:3)-0.35, accuracy1, 0.3,'FaceColor','flat');
% b1(1).CData = 1;
stem((1:3)-0.35, accuracy1, ':','Color',c1, 'LineWidth',4);
hold on;
e = errorbar((1:3)-0.35, accuracy1, yneg1, ypos1, '.', 'CapSize', 14, 'LineWidth',4);
e.Color = c1;
grid on;
axis([0.2 3.8 0.5 1]);
% bar((1:3), accuracy2, 0.3,'FaceColor',[0.6 0.6 1],'EdgeColor',[0.6 0.6 1]);
% b2 = bar((1:3), accuracy2, 0.3,'FaceColor','flat');
% b2(1).CData = 2;
stem((1:3), accuracy2, '-.','Color',c2, 'LineWidth',4);
hold on;
e = errorbar((1:3), accuracy2, yneg2, ypos2, '.', 'CapSize', 14, 'LineWidth',4);
e.Color = c2;
xticks([1 2 3]-0.35/2);
xticklabels({'VoIP','HTTP','video'});
grid on;
axis([0.2 3.5 0.7 1]);
legend('Control mean', 'Control extremes', 'User data mean', 'User data extremes');
ylabel('Accuracy');
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset;
ti = ti*2.0;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
set(findall(gcf,'-property','FontSize'),'FontSize', 26);

savefig('validation2');