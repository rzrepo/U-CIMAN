% fit models to segments
clc;
clearvars -except hour_cell hour_rb_inter_usage segments;
if 1 ~= exist('segments', 'var')
    clc;clear;
    load('segmentsch25.mat', 'hour_cell', 'hour_rb_inter_usage', 'segments');
end

rng(3);

seginterval = cell(1,24);
segintmean = -ones(1,24);

for h = 1:24
    segtmp1 = segments{h};
    segtmp2 = [0 segtmp1(1:(end-1))];
    segtmp3 = segtmp1 - segtmp2;
    seginterval{h} = segtmp3;
    segintmean(h) = mean(segtmp3);
end

tt_int = 100;
totalvarcd = -ones(24,100); % change detection
totalonoffcd = -ones(24,100);
totalvarcst = -ones(24,100); % constant
totalonoffcst = -ones(24,100);

cmpOffDcd = -ones(24, tt_int, 3);
cmpOnDcd = -ones(24, tt_int, 3);
cmpIntDcd = -ones(24, tt_int, 3);
cmpOffARcd = -ones(24, tt_int, 3);
cmpOnARcd = -ones(24, tt_int, 3);
cmpIntARcd = -ones(24, tt_int, 3);

offDcdDe = -ones(1, 24);
offARcdDe = -ones(1, 24);

cmpOffDcst = -ones(24, tt_int, 3);
cmpOnDcst = -ones(24, tt_int, 3);
cmpIntDcst = -ones(24, tt_int, 3);
cmpOffARcst = -ones(24, tt_int, 3);
cmpOnARcst = -ones(24, tt_int, 3);
cmpIntARcst = -ones(24, tt_int, 3);

offDcdCon = -ones(1, 24);
offARcdCon = -ones(1, 24);

for h = 1:24
    cstTTsize = segments{h}(tt_int)-1;
    cstInt = ceil(cstTTsize/tt_int);
    usageData = hour_cell{h,2}(:, 1:cstTTsize);
    usageData = double(usageData>0)';
    cd_start = [1 segments{h}(1:(tt_int-1))];
    cd_end = segments{h}(1:(tt_int))-1;
    for i = 1:tt_int
        fitDatacd = usageData(cd_start(i):cd_end(i));
        VAR = varm(1, 1);
        if numel(unique(fitDatacd)) == 1
            continue;
        end
        try            
            [EstMdl, EstParamCov, logL, info] = estimate(VAR, fitDatacd');
        catch
            continue;
        end
        syntheticAR = simulate(EstMdl, cd_end(i)-cd_start(i)+1);
        onePercent = sum(sum(fitDatacd))/numel(fitDatacd);
        Y = prctile(syntheticAR(:), (1-onePercent)*100);
        syntheticAR = syntheticAR > Y;
        if numel(unique(syntheticAR)) == 1
            continue;
        end
        syntheticOffOnAR = getOffOn(syntheticAR);
        if isempty(syntheticOffOnAR{1}) && isempty(syntheticOffOnAR{2})
            continue;
        end
        fitDataOffOn = getOffOn(fitDatacd');
        if isempty(fitDataOffOn{1}) && isempty(fitDataOffOn{2})
            continue;
        end
        offOnModel = getOnOffDist(fitDataOffOn);
        syntheticOffOnD = synth(offOnModel, cd_end(i)-cd_start(i)+1, 1);
        [cmpOffDcd(h, i, 1), cmpOffDcd(h, i, 2), cmpOffDcd(h, i, 3)] = kstest2(fitDataOffOn{1}, syntheticOffOnD{1});
        [cmpOnDcd(h, i, 1), cmpOnDcd(h, i, 2), cmpOnDcd(h, i, 3)] = kstest2(fitDataOffOn{2}, syntheticOffOnD{2});
        [cmpIntDcd(h, i, 1), cmpIntDcd(h, i, 2), cmpIntDcd(h, i, 3)] = kstest2(fitDataOffOn{2} + fitDataOffOn{1}, syntheticOffOnD{2} + syntheticOffOnD{1});
        [cmpOffARcd(h, i, 1), cmpOffARcd(h, i, 2), cmpOffARcd(h, i, 3)] = kstest2(fitDataOffOn{1}, syntheticOffOnAR{1});
        [cmpOnARcd(h, i, 1), cmpOnARcd(h, i, 2), cmpOnARcd(h, i, 3)] = kstest2(fitDataOffOn{2}, syntheticOffOnAR{2});
        [cmpIntARcd(h, i, 1), cmpIntARcd(h, i, 2), cmpIntARcd(h, i, 3)] = kstest2(fitDataOffOn{2} + fitDataOffOn{1}, syntheticOffOnAR{2} + syntheticOffOnAR{1});
    end
    valid_cmpOffDcd = cmpOffDcd(h, :, 3);
    valid_cmpOffDcd = valid_cmpOffDcd(valid_cmpOffDcd>0);
    offDcdDe(h) = mean(valid_cmpOffDcd);
    valid_cmpOffARcd = cmpOffARcd(h, :, 3);
    valid_cmpOffARcd = valid_cmpOffARcd(valid_cmpOffARcd>0);
    offARcdDe(h) = mean(valid_cmpOffARcd);
    
    tt_int_cst = floor(tt_int/30);
    cstIntcst = ceil(cstTTsize/tt_int_cst);
    cst_start = 1 + (0:(tt_int_cst-1))*cstIntcst;
    cst_end = [cstIntcst + cstIntcst*(0:(tt_int_cst-1)), cstTTsize];
    for i = 1:tt_int_cst        
        fitDatacd = usageData(cst_start(i):cst_end(i));
        VAR = varm(1, 1);
        if numel(unique(fitDatacd)) == 1
            continue;
        end
        try            
            [EstMdl, EstParamCov, logL, info] = estimate(VAR, fitDatacd');
        catch
            continue;
        end
        syntheticAR = simulate(EstMdl, cd_end(i)-cd_start(i)+1);
        onePercent = sum(sum(fitDatacd))/numel(fitDatacd);
        Y = prctile(syntheticAR(:), (1-onePercent)*100);
        syntheticAR = syntheticAR > Y;
        if numel(unique(syntheticAR)) == 1
            continue;
        end
        syntheticOffOnAR = getOffOn(syntheticAR);
        if isempty(syntheticOffOnAR{1}) && isempty(syntheticOffOnAR{2})
            continue;
        end
        fitDataOffOn = getOffOn(fitDatacd');
        if isempty(fitDataOffOn{1}) && isempty(fitDataOffOn{2})
            continue;
        end
        offOnModel = getOnOffDist(fitDataOffOn);
        syntheticOffOnD = synth(offOnModel, cd_end(i)-cd_start(i)+1, 1);
        [cmpOffDcst(h, i, 1), cmpOffDcst(h, i, 2), cmpOffDcst(h, i, 3)] = kstest2(fitDataOffOn{1}, syntheticOffOnD{1});
        [cmpOnDcst(h, i, 1), cmpOnDcst(h, i, 2), cmpOnDcst(h, i, 3)] = kstest2(fitDataOffOn{2}, syntheticOffOnD{2});
        [cmpIntDcst(h, i, 1), cmpIntDcst(h, i, 2), cmpIntDcst(h, i, 3)] = kstest2(fitDataOffOn{2} + fitDataOffOn{1}, syntheticOffOnD{2} + syntheticOffOnD{1});
        [cmpOffARcst(h, i, 1), cmpOffARcst(h, i, 2), cmpOffARcst(h, i, 3)] = kstest2(fitDataOffOn{1}, syntheticOffOnAR{1});
        [cmpOnARcst(h, i, 1), cmpOnARcst(h, i, 2), cmpOnARcst(h, i, 3)] = kstest2(fitDataOffOn{2}, syntheticOffOnAR{2});
        [cmpIntARcst(h, i, 1), cmpIntARcst(h, i, 2), cmpIntARcst(h, i, 3)] = kstest2(fitDataOffOn{2} + fitDataOffOn{1}, syntheticOffOnAR{2} + syntheticOffOnAR{1});
    end
    
    valid_cmpOffDcst = cmpOffDcst(h, :, 3);
    valid_cmpOffDcst = valid_cmpOffDcst(valid_cmpOffDcst>0);
    offDcdCon(h) = mean(valid_cmpOffDcst);
    valid_cmpOffARcst = cmpOffARcst(h, :, 3);
    valid_cmpOffARcst = valid_cmpOffARcst(valid_cmpOffARcst>0);
    offARcdCon(h) = mean(valid_cmpOffARcst);
end

save cdonoffar.mat seginterval offDcdCon offDcdDe offARcdCon offARcdDe

% fig 1, plot segment length distribution
allinterval = cell2mat(seginterval);
figure('rend','painters','pos',[100 100 600 300]);
set(0,'defaultAxesFontName', 'Arial');
hold on; grid on;
histogram(allinterval);
set(gca, 'xscale','log');
% plot(0:23, arCmp);
xlabel('Segment length (ms)');
ylabel('Count');
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset;
ti = ti*1.8;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];
% axes('position', [0.7 0.35 0.08 0.3]);
% box on;
% plot(0:23, arCmp);
% xlim([14.999 15.001]);
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
set(findall(gcf,'-property','FontSize'),'FontSize', 18);
print(fig,'segdist','-dpdf');
savefig('segdist');

% fig 2, plot segmentation effect on on/off fitting
figure('rend','painters','pos',[100 100 600 300]);
set(0,'defaultAxesFontName', 'Arial');
hold on; grid on;
plot(0:23, offDcdDe, 'or', 0:23, offDcdCon, 'sb');
offDcdCon_YY = spline(0:23, offDcdCon, 0:0.1:23);
offDcdDe_YY = spline(0:23, offDcdDe, 0:0.1:23);
plot(0:0.1:23, offDcdDe_YY, '--r', 0:0.1:23, offDcdCon_YY, '-.b');
xlabel('Hour of the day');
ylabel('D value of on/off');
xlim([0 23.2]);
legend('Constant', 'Change detection', 'Location', 'Best');
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset;
ti = ti*1.8;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
set(findall(gcf,'-property','FontSize'),'FontSize', 18);
print(fig,'cdvsconoff','-dpdf');
savefig('cdvsconoff');

% fig 3, plot segmentation effect on VAR model fitting
figure('rend','painters','pos',[100 100 600 300]);
set(0,'defaultAxesFontName', 'Arial');
hold on; grid on;
plot(0:23, offARcdDe, 'or', 0:23, offARcdCon, 'sb');
offARcdCon_YY = spline(0:23, offARcdCon, 0:0.1:23);
offARcdDe_YY = spline(0:23, offARcdDe, 0:0.1:23);
plot(0:0.1:23, offARcdDe_YY, '--r', 0:0.1:23, offARcdCon_YY, '-.b');
xlabel('Hour of the day');
ylabel('D value of VAR');
xlim([0 23.2]);
legend('Constant', 'Change detection', 'Location', 'Best');
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset;
ti = ti*1.8;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
set(findall(gcf,'-property','FontSize'),'FontSize', 18);
print(fig,'cdvscar','-dpdf');
savefig('cdvscar');