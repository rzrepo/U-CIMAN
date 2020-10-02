% plot the time traces of lengths of 3 apps.
% plot the distributions of lengths

set(0,'DefaultFigureColormap',feval('jet'));

clear;clc;

fewUserVoip = importdata('app_len_single_user/voip/voip_time_len.txt');
[t1,d1] = getTime(fewUserVoip);

fewUserHttp = importdata('app_len_single_user/http/http_time_len.txt');
[t2, d2] = getTime(fewUserHttp);

fewUserVideo = importdata('app_len_single_user/video/video_time_len.txt');
[t3, d3] = getTime(fewUserVideo);

manyUserVoip = importdata('app_len_multi_user/voip/time_len.txt');
[t4, d4] = getTime(manyUserVoip);

manyUserHttp = importdata('app_len_multi_user/http/time_len.txt');
[t5, d5] = getTime(manyUserHttp);

manyUserVideo = importdata('app_len_multi_user/video/time_len.txt');
[t6, d6] = getTime(manyUserVideo);

% fig. 1, 3 by 1, time versus length of low traffic scene
figure('rend','painters','pos',[100 100 600 400]);

set(0,'defaultAxesFontName', 'Arial');
subplot(3,1,1);
set(0,'defaultAxesFontName', 'Arial');
stem(t1, fewUserVoip(:,2), 'MarkerSize', 0.1);
ylabel('(a) VoIP');
xlim([0 25]);
% title('(a) Length of VoIP in low traffic');
grid on;

subplot(3,1,2);
set(0,'defaultAxesFontName', 'Arial');
stem(t2, fewUserHttp(:,2), 'MarkerSize', 0.1);
ylabel('(b) HTTP');
xlim([0 25]);
% title('(b) Length of HTTP in low traffic');
grid on;

subplot(3,1,3);
set(0,'defaultAxesFontName', 'Arial');
stem(t3, fewUserVideo(:,2), 'MarkerSize', 0.1);
ylabel('(c) Video');
xlim([0 25]);
% title('(c) Length of video in low traffic');
grid on;
xlabel('Time (s)');

set(findall(gcf,'-property','FontSize'),'FontSize',20);
savefig('fewUserLen');

% fig. 2, 3 by 1, time versus length of high traffic scene
figure('rend','painters','pos',[100 100 600 400]);

set(0,'defaultAxesFontName', 'Arial');
subplot(3,1,1);
set(0,'defaultAxesFontName', 'Arial');
stem(t4-29, manyUserVoip(:,2), 'MarkerSize', 0.1);
ylabel('(a) VoIP');
xlim([0 25]);
% title('(a) Length of VoIP in high traffic');
grid on;

subplot(3,1,2);
set(0,'defaultAxesFontName', 'Arial');
stem(t5, manyUserHttp(:,2), 'MarkerSize', 0.1);
xlim([0 25]);
ylabel('(b) HTTP');
% title('(b) Length of HTTP in high traffic');
grid on;

subplot(3,1,3);
set(0,'defaultAxesFontName', 'Arial');
stem(t6, manyUserVideo(:,2), 'MarkerSize', 0.1);
xlim([0 25]);
ylabel('(c) Video');
% title('(c) Length of video in high traffic');
grid on;
xlabel('Time (s)');

set(findall(gcf,'-property','FontSize'),'FontSize',20);
savefig('manyUserLen');

% fig 3, 1 by 2 plots, 3 lines in each plot, 3 cdfs in low and high traffic
figure('rend','painters','pos',[100 100 600 300]);
set(0,'defaultAxesFontName', 'Arial');
subplot(1,2,1);
cdfplot(d1);
hold on;
cdfplot(d2);
cdfplot(d3);
xlabel('Length (bytes)');
ylabel('CDF');
title('');
legend('VoIP', 'HTTP', 'Video', 'Location', 'northeast');
legend boxoff;

subplot(1,2,2);
cdfplot(d4);
hold on;
cdfplot(d5);
cdfplot(d6);
xlabel('Length (bytes)');
ylabel('CDF');
title('');
legend('VoIP', 'HTTP', 'Video', 'Location', 'northeast');
legend boxoff;

set(findall(gcf,'-property','FontSize'),'FontSize',24);
savefig('mfUserLenDis');


% fig 4, 1 by 2 plots, 3 lines in each plot, 3 pdfs in low and high traffic
n_bins = 20;
[N1,e1] = histcounts(d1, n_bins);
[N2,e2] = histcounts(d2, n_bins);
[N3,e3] = histcounts(d3, n_bins);
[N4,e4] = histcounts(d4, n_bins);
[N5,e5] = histcounts(d5, n_bins);
[N6,e6] = histcounts(d6, n_bins);
m1 = getMid(e1); m2 = getMid(e2); m3 = getMid(e3);
m4 = getMid(e4); m5 = getMid(e5); m6 = getMid(e6);
figure('rend','painters','pos',[100 100 600 300]);
set(0,'defaultAxesFontName', 'Arial');
subplot(1,2,1);
plot(m1, N1/sum(N1), m2, N2/sum(N2), m3, N2/sum(N3));
grid on;
xlabel('Length (bytes)');
ylabel('Empirical PDF');
title('');
legend('VoIP', 'HTTP', 'Video', 'Location', 'northeast');

subplot(1,2,2);
plot(m1, N1/sum(N1), m2, N2/sum(N2), m3, N2/sum(N3));
grid on;
xlabel('Length (bytes)');
ylabel('Empirical PDF');
title('');
legend('VoIP', 'HTTP', 'Video', 'Location', 'northeast');

set(findall(gcf,'-property','FontSize'),'FontSize',20);
savefig('mfUserLenDis');

function m = getMid(e)
    n = numel(e)-1;
    m = e(2:end);
    m = m - e(end)/2/n;
end

function [showTime, data] = getTime(inputtime)
    showTime = inputtime(:,1);
    showTime = showTime - showTime(1);
    showTime = showTime/1000;
    data = inputtime(:,2);
    data(data==0)=[];
end