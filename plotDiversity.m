% video auto
% a=[153545 122401 122402 102353 103473 16370 18503 1956 24549 87775]
% b=[8403.42237411 7512.77402449 6763.1369703 6263.07891049 633.229392256 1183.48753409 2.04818434577 956.040826487 2798.91833302 9970.05389425]
% c=[6830.55686483 8683.96586794 5120.19859757 2976.71562799 1482.61500296 1.93544493491 4.32454798875 1896.00927117 5133.14143278 9894.8914098]
% 
% video 64qam
% a=[313656 269923 85009 100253 84716 87741 1938 170568 83753 85237];
% b=[9709.93819745 10474.0816041 3242.09097221 3488.16499622 3524.74846181 1481.33625466 8128.93994681 2047.82846154 3679.09791311 2662.31864645];
% c=[12722.6771863 15133.5356118 14380.3591282 1580.93751256 5499.79129153 1904.02629719 4874.75257858 498.714365525 3421.78650461 6359.7549627];
% 
% video qpsk
% a=[3212 445325 422081 435995 482673 436079 488823 320103 454456 474928];
% b=[1985.43567168 2394.12386586 2468.9022619 2804.32649064 2657.9466653 2564.09113085 1814.44950011 2652.82755533 2642.33565116 2734.74612848];
% c=[2237.389543 2396.67578028 2476.12192522 2774.27163496 2504.50679943 2748.54250448 1823.28012598 2612.79211373 2684.55315086 2742.03864228];
% 
% voip-5meter
% 
% a=[8974 11516 9090 8234 10253 8542 7634 10626 8032 8906]
% b=[17.1302414235 23.4316519541 11.9929081881 14.6932734763 20.0393090915 12.8303138364 11.8756610671 19.796905714 13.0321415672 14.3853074002];
% c=[24.6393832697 18.9617891039 27.0362908665 16.5582722757 14.7095562389 22.6571774207 15.3802133048 14.0621100974 22.7947174236 15.1925973193];
% 
% voip-noise
% 
% a=[10056 13250 15334 9316 11047 9876 10771 11227 10733 11064];
% b=[16.9931881164 28.8536424374 25.2190433747 18.3101591808 23.2609837741 14.1972085115 17.333824748 22.7922645049 16.3015228913 19.2719849205];
% c=[20.9114692734 21.1608323444 38.8974880441 23.929544176 18.0204673046 24.6085461901 20.7416816299 17.7306949761 26.3523860014 22.327332082];

clear;clc;

% fig 1, video auto
figure('rend','painters','pos',[100 100 600 300]);
set(0,'defaultAxesFontName', 'Arial');
hold on; grid on;
x=[10 20 30 40 50 60 70 80 90 100];
a=[153545 122401 122402 102353 103473 16370 18503 1956 24549 87775];
b=[8403.42237411 7512.77402449 6763.1369703 6263.07891049 633.229392256 1183.48753409 2.04818434577 956.040826487 2798.91833302 9970.05389425];
c=[6830.55686483 8683.96586794 5120.19859757 2976.71562799 1482.61500296 1.93544493491 4.32454798875 1896.00927117 5133.14143278 9894.8914098];
xx=10:.25:100;
aa=spline(x,a,xx);
yyaxis left;
h1 = plot(x,a,'o');
yyaxis right;
h2 = plot(x,b,'s');
h3 = plot(x,c,'d');
yyaxis left;
plot(xx,aa,'--');
xlabel('Time/s');
ylabel('Number of used RBs');
title('Video-auto');
hold on;
bb=spline(x,b,xx);
yyaxis right;
plot(xx,bb,':');
ylabel('DataRate/ kb/s');
hold on;
cc=spline(x,c,xx);
plot(xx,cc,'-.');
xticks(10:10:100);
xlim([8,102]);
legend([h1 h2 h3],{'RB','eNB','UE'}, 'Location', 'Best');

ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset;
ti = ti*1.5;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
set(findall(gcf,'-property','FontSize'),'FontSize',14);
print(fig,'videoAuto','-dpdf');
savefig('videoAuto');

% fig 2, video qpsk
figure('rend','painters','pos',[100 100 600 300]);
set(0,'defaultAxesFontName', 'Arial');
hold on; grid on;
x=[10 20 30 40 50 60 70 80 90 100];
a=[3212 445325 422081 435995 482673 436079 488823 320103 454456 474928];
b=[1985.43567168 2394.12386586 2468.9022619 2804.32649064 2657.9466653 2564.09113085 1814.44950011 2652.82755533 2642.33565116 2734.74612848];
c=[2237.389543 2396.67578028 2476.12192522 2774.27163496 2504.50679943 2748.54250448 1823.28012598 2612.79211373 2684.55315086 2742.03864228];
xx=10:.25:100;
aa=spline(x,a,xx);
yyaxis left;
h1 = plot(x,a,'o');
yyaxis right;
h2 = plot(x,b,'s');
h3 = plot(x,c,'d');
yyaxis left;
plot(xx,aa,'--');
xlabel('Time/s');
ylabel('Number of used RBs');
title('Video-QPSK');
hold on;
bb=spline(x,b,xx);
yyaxis right;
plot(xx,bb,':');
ylabel('DataRate/ kb/s');
hold on;
cc=spline(x,c,xx);
plot(xx,cc,'-.');
xticks(10:10:100);
xlim([8,102]);
legend([h1 h2 h3],{'RB','eNB','UE'}, 'Location', 'Best');

ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset;
ti = ti*1.5;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
set(findall(gcf,'-property','FontSize'),'FontSize',14);
print(fig,'videoQPSK','-dpdf');
savefig('videoQPSK');

% fig 3, video 64qam
figure('rend','painters','pos',[100 100 600 300]);
set(0,'defaultAxesFontName', 'Arial');
hold on; grid on;
x=[10 20 30 40 50 60 70 80 90 100];
a=[313656 269923 85009 100253 84716 87741 1938 170568 83753 85237];
b=[9709.93819745 10474.0816041 3242.09097221 3488.16499622 3524.74846181 1481.33625466 8128.93994681 2047.82846154 3679.09791311 2662.31864645];
c=[12722.6771863 15133.5356118 14380.3591282 1580.93751256 5499.79129153 1904.02629719 4874.75257858 498.714365525 3421.78650461 6359.7549627];
xx=10:.25:100;
aa=spline(x,a,xx);
yyaxis left;
h1 = plot(x,a,'o');
yyaxis right;
h2 = plot(x,b,'s');
h3 = plot(x,c,'d');
yyaxis left;
plot(xx,aa,'--');
xlabel('Time/s');
ylabel('Number of used RBs');
title('Video-64QAM');
hold on;
bb=spline(x,b,xx);
yyaxis right;
plot(xx,bb,':');
ylabel('DataRate/ kb/s');
hold on;
cc=spline(x,c,xx);
plot(xx,cc,'-.');
xticks(10:10:100);
xlim([8,102]);
legend([h1 h2 h3],{'RB','eNB','UE'}, 'Location', 'Best');

ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset;
ti = ti*1.5;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
set(findall(gcf,'-property','FontSize'),'FontSize',14);
print(fig,'video64','-dpdf');
savefig('video64');


% fig 4, voip no noise
figure('rend','painters','pos',[100 100 600 300]);
set(0,'defaultAxesFontName', 'Arial');
hold on; grid on;
x=[10 20 30 40 50 60 70 80 90 100];
a=[8974 11516 9090 8234 10253 8542 7634 10626 8032 8906];
b=[17.1302414235 23.4316519541 11.9929081881 14.6932734763 20.0393090915 12.8303138364 11.8756610671 19.796905714 13.0321415672 14.3853074002];
c=[24.6393832697 18.9617891039 27.0362908665 16.5582722757 14.7095562389 22.6571774207 15.3802133048 14.0621100974 22.7947174236 15.1925973193];
xx=10:.25:100;
aa=spline(x,a,xx);
yyaxis left;
h1 = plot(x,a,'o');
yyaxis right;
h2 = plot(x,b,'s');
h3 = plot(x,c,'d');
yyaxis left;
plot(xx,aa,'--');
xlabel('Time/s');
ylabel('Number of used RBs');
title('VOIP');
hold on;
bb=spline(x,b,xx);
yyaxis right;
plot(xx,bb,':');
ylabel('DataRate/ kb/s');
hold on;
cc=spline(x,c,xx);
plot(xx,cc,'-.');
xticks(10:10:100);
xlim([8,102]);
legend([h1 h2 h3],{'RB','eNB','UE'}, 'Location', 'Best');

ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset;
ti = ti*1.5;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
set(findall(gcf,'-property','FontSize'),'FontSize',14);
print(fig,'voip','-dpdf');
savefig('voip');


% fig 5, voip with noise
figure('rend','painters','pos',[100 100 600 300]);
set(0,'defaultAxesFontName', 'Arial');
hold on; grid on;
x=[10 20 30 40 50 60 70 80 90 100];
a=[10056 13250 15334 9316 11047 9876 10771 11227 10733 11064];
b=[16.9931881164 28.8536424374 25.2190433747 18.3101591808 23.2609837741 14.1972085115 17.333824748 22.7922645049 16.3015228913 19.2719849205];
c=[20.9114692734 21.1608323444 38.8974880441 23.929544176 18.0204673046 24.6085461901 20.7416816299 17.7306949761 26.3523860014 22.327332082];
xx=10:.25:100;
aa=spline(x,a,xx);
yyaxis left;
h1 = plot(x,a,'o');
yyaxis right;
h2 = plot(x,b,'s');
h3 = plot(x,c,'d');
yyaxis left;
plot(xx,aa,'--');
xlabel('Time/s');
ylabel('Number of used RBs');
title('VOIP in noisy environment');
hold on;
bb=spline(x,b,xx);
yyaxis right;
plot(xx,bb,':');
ylabel('DataRate/ kb/s');
hold on;
cc=spline(x,c,xx);
plot(xx,cc,'-.');
xticks(10:10:100);
xlim([8,102]);
legend([h1 h2 h3],{'RB','eNB','UE'}, 'Location', 'Best');

ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset;
ti = ti*1.5;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
set(findall(gcf,'-property','FontSize'),'FontSize',14);
print(fig,'voipnoise','-dpdf');
savefig('voipnoise');