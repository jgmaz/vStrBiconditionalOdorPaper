function PlotFR(cfg_in,FR)
% Organizes task data
cfg_def = [];

cfg = ProcessConfig(cfg_def,cfg_in);

%%
colors{1} = [136/255 86/255 167/255];
colors{2} = [253/255 141/255 60/255];
colors{3} = [116/255 196/255 118/255];
colors{4} = [231/255 41/255 138/255];

%% plot CTX
figure('units','normalized','outerposition',[0 0 1 1])

% all
subplot(2,3,1)
imagesc(FR.cfg.trlInt(1):FR.cfg.dt:FR.cfg.trlInt(2),1:size(FR.sort.ctxPre,2),FR.PETH.ctxAllNorm(FR.sort.ctxPre,:)); colorbar; %caxis([0 40])
hold on
line([0 0],[1 size(FR.sort.ctxPre,2)],'color','r')
line([1 1],[1 size(FR.sort.ctxPre,2)],'color','r')
line([3 3],[1 size(FR.sort.ctxPre,2)],'color','k')
line([4 4],[1 size(FR.sort.ctxPre,2)],'color','k')
set(gca,'FontSize',18)
xlabel('Time from context cue onset (s)');
ylabel('Unit id');
title('Max normalized mean FR (sorted to context cue)')

subplot(2,3,4)
temp = FR.diff.z.ctxPre(FR.sort.ctxPre);
temp(temp> 20) = 20;
temp(temp< -20) = -20;
tempMinus = temp(temp < -cfg.zscore); % tempMinus = temp(temp < round(-cfg.zscore));
tempPlus = temp(temp > cfg.zscore); % tempPlus = temp(temp > round(cfg.zscore));
h1 = histogram(temp,80,'BinLimits',[-20,20]);%,-10:.1:10)
hold on
histogram(tempMinus,80,'BinLimits',[-20,20],'FaceColor',colors{2})
histogram(tempPlus,80,'BinLimits',[-20,20],'FaceColor',colors{1})
set(gca,'FontSize',18)
xlabel('Z-scored pre v post \Delta');
ylabel('Number of units');
title('Pre- vs. post-ctx preference')
line([cfg.zscore cfg.zscore],[0 max(h1.Values)*1.2],'color','r','LineStyle','--')
line([-cfg.zscore -cfg.zscore],[0 max(h1.Values)*1.2],'color','r','LineStyle','--')
ylim([0 max(h1.Values)*1.2])

% CS+ vs CS-
subplot(2,3,2)
imagesc(FR.cfg.trlInt(1):FR.cfg.dt:FR.cfg.trlInt(2),1:size(FR.sort.ctx,2),FR.PETH.ctxDiff(FR.sortABS.ctx,:)); colorbar; caxis([-5 5])
hold on
line([0 0],[1 size(FR.sort.ctxPre,2)],'color','r')
line([1 1],[1 size(FR.sort.ctxPre,2)],'color','r')
line([3 3],[1 size(FR.sort.ctxPre,2)],'color','k')
line([4 4],[1 size(FR.sort.ctxPre,2)],'color','k')
set(gca,'FontSize',18)
xlabel('Time from context cue onset (s)');
% ylabel('Unit id');
title('FR diff to context cues')

subplot(2,3,5)
temp = FR.diff.z.ctx(FR.sort.ctx);
temp(temp> 10) = 10;
temp(temp< -10) = -10;
tempMinus = temp(temp < -cfg.zscore); % tempMinus = temp(temp < round(-cfg.zscore));
tempPlus = temp(temp > cfg.zscore); % tempPlus = temp(temp > round(cfg.zscore));
h1 = histogram(temp,40,'BinLimits',[-10,10]);%,-10:.1:10)
hold on
histogram(tempMinus,40,'BinLimits',[-10,10],'FaceColor',colors{2})
histogram(tempPlus,40,'BinLimits',[-10,10],'FaceColor',colors{1})
set(gca,'FontSize',18)
xlabel('Z-scored context cue \Delta');
% ylabel('Number of units');
title('Context cue preference')
line([cfg.zscore cfg.zscore],[0 max(h1.Values)*1.2],'color','r','LineStyle','--')
line([-cfg.zscore -cfg.zscore],[0 max(h1.Values)*1.2],'color','r','LineStyle','--')
ylim([0 max(h1.Values)*1.2])

% CS+ vs CS- delay period
subplot(2,3,3)
imagesc(FR.cfg.trlInt(1):FR.cfg.dt:FR.cfg.trlInt(2),1:size(FR.sort.delay,2),FR.PETH.delayDiff(FR.sortABS.delay,:)); colorbar; caxis([-5 5])
hold on
line([0 0],[1 size(FR.sort.ctxPre,2)],'color','r')
line([1 1],[1 size(FR.sort.ctxPre,2)],'color','r')
line([3 3],[1 size(FR.sort.ctxPre,2)],'color','k')
line([4 4],[1 size(FR.sort.ctxPre,2)],'color','k')
set(gca,'FontSize',18)
xlabel('Time from context cue onset (s)');
% ylabel('Unit id');
title('FR diff during delay')

subplot(2,3,6)
temp = FR.diff.z.delay(FR.sort.delay);
temp(temp> 10) = 10;
temp(temp< -10) = -10;
tempMinus = temp(temp < -cfg.zscore); % tempMinus = temp(temp < round(-cfg.zscore));
tempPlus = temp(temp > cfg.zscore); % tempPlus = temp(temp > round(cfg.zscore));
h1 = histogram(temp,40,'BinLimits',[-10,10]);%,-10:.1:10)
hold on
histogram(tempMinus,40,'BinLimits',[-10,10],'FaceColor',colors{2})
histogram(tempPlus,40,'BinLimits',[-10,10],'FaceColor',colors{1})
set(gca,'FontSize',18)
xlabel('Z-scored context cue \Delta');
% ylabel('Number of units');
title('Context cue preference at delay')
line([cfg.zscore cfg.zscore],[0 max(h1.Values)*1.2],'color','r','LineStyle','--')
line([-cfg.zscore -cfg.zscore],[0 max(h1.Values)*1.2],'color','r','LineStyle','--')
ylim([0 max(h1.Values)*1.2])

if strcmp(cfg.save,'on')
    
    saveas(gcf,['E:\vStr-phaselock\temp\figurePlots\FRevents_ctx.png'])
    close
    
end

%% plot TRGT
figure('units','normalized','outerposition',[0 0 1 1])

% all
subplot(2,3,1)
imagesc(FR.cfg.trlInt(1):FR.cfg.dt:FR.cfg.trlInt(2),1:size(FR.sort.trgtPre,2),FR.PETH.ctxAllNorm(FR.sort.trgtPre,:)); colorbar; %caxis([0 40])
hold on
line([0 0],[1 size(FR.sort.trgtPre,2)],'color','r')
line([1 1],[1 size(FR.sort.trgtPre,2)],'color','r')
line([3 3],[1 size(FR.sort.trgtPre,2)],'color','k')
line([4 4],[1 size(FR.sort.trgtPre,2)],'color','k')
set(gca,'FontSize',18)
xlabel('Time from context cue onset (s)');
ylabel('Unit id');
title('Max normalized mean FR (target cue sorted)')

subplot(2,3,4)
temp = FR.diff.z.trgtPre(FR.sort.trgtPre);
temp(temp> 20) = 20;
temp(temp< -20) = -20;
tempMinus = temp(temp < -cfg.zscore); % tempMinus = temp(temp < round(-cfg.zscore));
tempPlus = temp(temp > cfg.zscore); % tempPlus = temp(temp > round(cfg.zscore));
h1 = histogram(temp,80,'BinLimits',[-20,20]);%,-10:.1:10)
hold on
histogram(tempMinus,80,'BinLimits',[-20,20],'FaceColor',colors{2})
histogram(tempPlus,80,'BinLimits',[-20,20],'FaceColor',colors{1})
set(gca,'FontSize',18)
xlabel('Z-scored pre v post \Delta');
ylabel('Number of units');
title('Pre- vs. post-trgt preference')
line([cfg.zscore cfg.zscore],[0 max(h1.Values)*1.2],'color','r','LineStyle','--')
line([-cfg.zscore -cfg.zscore],[0 max(h1.Values)*1.2],'color','r','LineStyle','--')
ylim([0 max(h1.Values)*1.2])

% trgt
subplot(2,3,2)
imagesc(FR.cfg.trlInt(1):FR.cfg.dt:FR.cfg.trlInt(2),1:size(FR.sort.trgt,2),FR.PETH.trgtDiff(FR.sortABS.trgt,:)); colorbar; caxis([-5 5])
hold on
line([0 0],[1 size(FR.sort.trgtPre,2)],'color','r')
line([1 1],[1 size(FR.sort.trgtPre,2)],'color','r')
line([3 3],[1 size(FR.sort.trgtPre,2)],'color','k')
line([4 4],[1 size(FR.sort.trgtPre,2)],'color','k')
set(gca,'FontSize',18)
xlabel('Time from context cue onset (s)');
% ylabel('Unit id');
title('FR diff to target cues')

subplot(2,3,5)
temp = FR.diff.z.trgt(FR.sort.trgt);
temp(temp> 10) = 10;
temp(temp< -10) = -10;
tempMinus = temp(temp < -cfg.zscore); % tempMinus = temp(temp < round(-cfg.zscore));
tempPlus = temp(temp > cfg.zscore); % tempPlus = temp(temp > round(cfg.zscore));
h1 = histogram(temp,40,'BinLimits',[-10,10]);%,-10:.1:10)
hold on
histogram(tempMinus,40,'BinLimits',[-10,10],'FaceColor',colors{2})
histogram(tempPlus,40,'BinLimits',[-10,10],'FaceColor',colors{1})
set(gca,'FontSize',18)
xlabel('Z-scored target cue \Delta');
% ylabel('Number of units');
title('Target cue preference')
line([cfg.zscore cfg.zscore],[0 max(h1.Values)*1.2],'color','r','LineStyle','--')
line([-cfg.zscore -cfg.zscore],[0 max(h1.Values)*1.2],'color','r','LineStyle','--')
ylim([0 max(h1.Values)*1.2])

% rew
subplot(2,3,3)
imagesc(FR.cfg.trlInt(1):FR.cfg.dt:FR.cfg.trlInt(2),1:size(FR.sort.rew,2),FR.PETH.rewDiff(FR.sortABS.rew,:)); colorbar; caxis([-5 5])
hold on
line([0 0],[1 size(FR.sort.trgtPre,2)],'color','r')
line([1 1],[1 size(FR.sort.trgtPre,2)],'color','r')
line([3 3],[1 size(FR.sort.trgtPre,2)],'color','k')
line([4 4],[1 size(FR.sort.trgtPre,2)],'color','k')
set(gca,'FontSize',18)
xlabel('Time from context cue onset (s)');
% ylabel('Unit id');
title('FR diff to rew vs. unrew trials')

subplot(2,3,6)
temp = FR.diff.z.rew(FR.sort.rew);
temp(temp> 10) = 10;
temp(temp< -10) = -10;
tempMinus = temp(temp < -cfg.zscore); % tempMinus = temp(temp < round(-cfg.zscore));
tempPlus = temp(temp > cfg.zscore); % tempPlus = temp(temp > round(cfg.zscore));
h1 = histogram(temp,40,'BinLimits',[-10,10]);%,-10:.1:10)
hold on
histogram(tempMinus,40,'BinLimits',[-10,10],'FaceColor',colors{2})
histogram(tempPlus,40,'BinLimits',[-10,10],'FaceColor',colors{1})
set(gca,'FontSize',18)
xlabel('Z-scored rew vs. unrew \Delta');
% ylabel('Number of units');
title('Rew vs. unrew trial preference')
line([cfg.zscore cfg.zscore],[0 max(h1.Values)*1.2],'color','r','LineStyle','--')
line([-cfg.zscore -cfg.zscore],[0 max(h1.Values)*1.2],'color','r','LineStyle','--')
ylim([0 max(h1.Values)*1.2])

if strcmp(cfg.save,'on')
    
    saveas(gcf,['E:\vStr-phaselock\temp\figurePlots\FRevents_ctx.png'])
    close
    
end

%% summary
prop = [];
for iM = 3:length(cfg.Mice)
    prop(iM-2,:) = FR.mice.(cfg.Mice(iM).name).prop;
end

label_4_paper = {'Context','Pre-context','Delay','Target','Pre-target','Reward'};

group = [1 2 3 4];
figure('units','normalized','outerposition',[0 0 1 1]);
subplot(2,3,1)
hold on
for iP = 1:length(prop)-3 %no interactions
    gscatter([iP iP iP iP],prop(:,iP),group,'k','xo+*',10)
    plot([iP-.25 iP+.25],[FR.prop(iP) FR.prop(iP)],'r')
end
ylim([0 1])
xlim([0 iP+1])
box off
set(gca,'FontSize',18)
title('Number of significant units')
ylabel('Proportion significant')
set(gca,'XTick',1:length(label_4_paper),'XTickLabel',label_4_paper)
xtickangle(45)

subplot(2,3,2)
[corrs, pvals] = corrcoef(FR.PETH.ctxAll,'rows','complete');
imagesc(cfg.trlInt(1):cfg.dt:cfg.trlInt(2),cfg.trlInt(1):cfg.dt:cfg.trlInt(2),corrs)
hold on
set(gca,'FontSize',18)
xlabel('Time from context cue onset (s)')
ylabel('Time from context cue onset (s)')
title('Correlation of firing rates across time');
line([0 0],[-1 5],'color','r','LineWidth',2,'LineStyle','--')
line([1 1],[-1 5],'color','r','LineWidth',2,'LineStyle','--')
line([3 3],[-1 5],'color','k','LineWidth',2,'LineStyle','--')
line([4 4],[-1 5],'color','k','LineWidth',2,'LineStyle','--')
line([-1 5],[0 0],'color','r','LineWidth',2,'LineStyle','--')
line([-1 5],[1 1],'color','r','LineWidth',2,'LineStyle','--')
line([-1 5],[3 3],'color','k','LineWidth',2,'LineStyle','--')
line([-1 5],[4 4],'color','k','LineWidth',2,'LineStyle','--')

if strcmp(cfg.save,'on')
    
    saveas(gcf,['E:\vStr-phaselock\temp\figurePlots\FRevents_summary.png'])
    close
    
end

%% ctx predictions
if strcmp(cfg.win,'on')
    
    figure('units','normalized','outerposition',[0 0 1 1])
    
    x_ticks = FR.cfg.trlInt(1)+FR.cfg.trlLen/2:FR.cfg.trlLen:FR.cfg.trlInt(2)-FR.cfg.trlLen/2;
    
    % diff
    subplot(3,2,1)
    plot(x_ticks,FR.win.diff.prop)
    hold on
    line([0 0],[0 1],'linestyle','--','color','r')
    line([1 1],[0 1],'linestyle','--','color','r')
    line([3 3],[0 1],'linestyle','--','color','k')
    line([4 4],[0 1],'linestyle','--','color','k')
    xlim([-1 5]); ylim([0 .5])
    set(gca,'FontSize',18)
    xlabel('Time from context cue onset (s)');
    ylabel('Prop sig.');
    title('Proportion of units with sig context cue differences')
    box off
    
    % reg
    subplot(3,2,3)
    plot(x_ticks,FR.win.reg.prop)
    hold on
    line([0 0],[0 1],'linestyle','--','color','r')
    line([1 1],[0 1],'linestyle','--','color','r')
    line([3 3],[0 1],'linestyle','--','color','k')
    line([4 4],[0 1],'linestyle','--','color','k')
    xlim([-1 5]); ylim([0 .5])
    set(gca,'FontSize',18)
    xlabel('Time from context cue onset (s)');
    ylabel('Prop sig.');
    title('Proportion of units that predict trgt value')
    box off
    
    % pois
    subplot(3,2,5)
    plot(x_ticks,FR.win.poiss.prop)
    hold on
    line([0 0],[0 1],'linestyle','--','color','r')
    line([1 1],[0 1],'linestyle','--','color','r')
    line([3 3],[0 1],'linestyle','--','color','k')
    line([4 4],[0 1],'linestyle','--','color','k')
    xlim([-1 5]); ylim([0 .5])
    set(gca,'FontSize',18)
    xlabel('Time from context cue onset (s)');
    ylabel('Prop sig.');
    title('Proportion of units that predict trgt activity')
    box off
    
    % corr
    subplot(3,2,2)
    plot(x_ticks,FR.win.corrDiffxReg)
    hold on
    plot(x_ticks,FR.win.corrDiffxPoiss)
    plot(x_ticks,FR.win.corrRegxPoiss)
    line([0 0],[-.5 1],'linestyle','--','color','r')
    line([1 1],[-.5 1],'linestyle','--','color','r')
    line([3 3],[-.5 1],'linestyle','--','color','k')
    line([4 4],[-.5 1],'linestyle','--','color','k')
    xlim([-1 5]); ylim([-.2 .5])
    set(gca,'FontSize',18)
    xlabel('Time from context cue onset (s)');
    ylabel('Corr');
    title('Correlation between metrics')
    box off
    
    % reg err
    subplot(3,2,4)
    plot(x_ticks,FR.win.reg.propErrBeh)
    hold on
    plot(x_ticks,FR.win.reg.propErrNeural)
    plot(x_ticks,FR.win.reg.propErrNone)
    line([0 0],[0 1],'linestyle','--','color','r')
    line([1 1],[0 1],'linestyle','--','color','r')
    line([3 3],[0 1],'linestyle','--','color','k')
    line([4 4],[0 1],'linestyle','--','color','k')
    xlim([-1 5]); ylim([0 .5])
    set(gca,'FontSize',18)
    xlabel('Time from context cue onset (s)');
    ylabel('Prop sig.');
    title('Breakdown of trgt value pred units for err trials')
    box off
    
    % pois err
    subplot(3,2,6)
    plot(x_ticks,FR.win.poiss.propErrBeh)
    hold on
    plot(x_ticks,FR.win.poiss.propErrNeural)
    plot(x_ticks,FR.win.poiss.propErrNone)
    line([0 0],[0 1],'linestyle','--','color','r')
    line([1 1],[0 1],'linestyle','--','color','r')
    line([3 3],[0 1],'linestyle','--','color','k')
    line([4 4],[0 1],'linestyle','--','color','k')
    xlim([-1 5]); ylim([0 .5])
    set(gca,'FontSize',18)
    xlabel('Time from context cue onset (s)');
    ylabel('Prop sig.');
    title('Breakdown of trgt activity pred units for err trials')
    box off
    
    
    if strcmp(cfg.save,'on')
        
        saveas(gcf,['E:\vStr-eyeblink\temp\figurePlots\FRevents_win.png'])
        close
        
    end
    
end

%% mouse-by-mouse
if strcmp(cfg.indMice,'on')
    
    fig1 = figure('units','normalized','outerposition',[0 0 1 1]);
    fig2 = figure('units','normalized','outerposition',[0 0 1 1]);
    fig3 = figure('units','normalized','outerposition',[0 0 1 1]);
    fig4 = figure('units','normalized','outerposition',[0 0 1 1]);
    fig5 = figure('units','normalized','outerposition',[0 0 1 1]);
    fig6 = figure('units','normalized','outerposition',[0 0 1 1]);
    
    for iM = 3:length(cfg.Mice)
        
        m_idx = contains(FR.label,cfg.Mice(iM).name);
        
        switch iM
            case {3,4}
                Plot1 = fig1;
                Plot2 = fig2;
                Plot3 = fig3;
                offset = 2;
            case {5,6}
                Plot1 = fig4;
                Plot2 = fig5;
                Plot3 = fig6;
                offset = 4;
        end
        
        
        % all
        plotData = FR.PETH.ctxAllNorm(m_idx,:);
        
        figure(Plot1)
        subplot(2,3,iM - offset)
        imagesc(FR.cfg.trlInt(1):FR.cfg.dt:FR.cfg.trlInt(2),1:size(FR.mice.(cfg.Mice(iM).name).sort.ctxPre,2),plotData(FR.mice.(cfg.Mice(iM).name).sort.ctxPre,:)); colorbar; %caxis([0 40])
        hold on
        line([0 0],[1 size(FR.mice.(cfg.Mice(iM).name).sort.ctxPre,2)],'color','r')
        line([1 1],[1 size(FR.mice.(cfg.Mice(iM).name).sort.ctxPre,2)],'color','r')
        line([3 3],[1 size(FR.mice.(cfg.Mice(iM).name).sort.ctxPre,2)],'color','k')
        line([4 4],[1 size(FR.mice.(cfg.Mice(iM).name).sort.ctxPre,2)],'color','k')
        set(gca,'FontSize',18)
        % xlabel('Time from context cue onset (s)');
        if iM == 3
            ylabel('Unit id');
        end
        title(['Max normalized FR (' cfg.Mice(iM).name ')'])
        
        % CS+ vs CS-
        plotData = FR.PETH.ctxDiff(m_idx,:);
        
        subplot(2,3,3 + iM - offset)
        imagesc(FR.cfg.trlInt(1):FR.cfg.dt:FR.cfg.trlInt(2),1:size(FR.mice.(cfg.Mice(iM).name).sort.ctx,2),plotData(FR.mice.(cfg.Mice(iM).name).sortABS.ctx,:)); colorbar; caxis([-5 5])
        hold on
        line([0 0],[1 size(FR.mice.(cfg.Mice(iM).name).sort.ctxPre,2)],'color','r')
        line([1 1],[1 size(FR.mice.(cfg.Mice(iM).name).sort.ctxPre,2)],'color','r')
        line([3 3],[1 size(FR.mice.(cfg.Mice(iM).name).sort.ctxPre,2)],'color','k')
        line([4 4],[1 size(FR.mice.(cfg.Mice(iM).name).sort.ctxPre,2)],'color','k')
        set(gca,'FontSize',18)
        % xlabel('Time from context cue onset (s)');
        if iM == 3
            ylabel('Unit id');
        end
        title('FR diff to context cues')
        
        % CS+ vs CS- delay period
        plotData = FR.PETH.delayDiff(m_idx,:);
        
        figure(Plot2)
        subplot(2,3,iM - offset)
        imagesc(FR.cfg.trlInt(1):FR.cfg.dt:FR.cfg.trlInt(2),1:size(FR.mice.(cfg.Mice(iM).name).sort.delay,2),plotData(FR.mice.(cfg.Mice(iM).name).sortABS.delay,:)); colorbar; caxis([-5 5])
        hold on
        line([0 0],[1 size(FR.mice.(cfg.Mice(iM).name).sort.ctxPre,2)],'color','r')
        line([1 1],[1 size(FR.mice.(cfg.Mice(iM).name).sort.ctxPre,2)],'color','r')
        line([3 3],[1 size(FR.mice.(cfg.Mice(iM).name).sort.ctxPre,2)],'color','k')
        line([4 4],[1 size(FR.mice.(cfg.Mice(iM).name).sort.ctxPre,2)],'color','k')
        set(gca,'FontSize',18)
        % xlabel('Time from context cue onset (s)');
        if iM == 3
            ylabel('Unit id');
        end
        title('FR diff during delay')
        
        % trgt
        plotData = FR.PETH.trgtDiff(m_idx,:);
        
        subplot(2,3,3+ iM - offset)
        imagesc(FR.cfg.trlInt(1):FR.cfg.dt:FR.cfg.trlInt(2),1:size(FR.mice.(cfg.Mice(iM).name).sort.trgt,2),plotData(FR.mice.(cfg.Mice(iM).name).sortABS.trgt,:)); colorbar; caxis([-5 5])
        hold on
        line([0 0],[1 size(FR.mice.(cfg.Mice(iM).name).sort.trgtPre,2)],'color','r')
        line([1 1],[1 size(FR.mice.(cfg.Mice(iM).name).sort.trgtPre,2)],'color','r')
        line([3 3],[1 size(FR.mice.(cfg.Mice(iM).name).sort.trgtPre,2)],'color','k')
        line([4 4],[1 size(FR.mice.(cfg.Mice(iM).name).sort.trgtPre,2)],'color','k')
        set(gca,'FontSize',18)
        % xlabel('Time from context cue onset (s)');
        if iM == 3
            ylabel('Unit id');
        end
        title('FR diff to target cues')
        
        % rew
        plotData = FR.PETH.rewDiff(m_idx,:);
        
        figure(Plot3)
        subplot(2,3,iM - offset)
        imagesc(FR.cfg.trlInt(1):FR.cfg.dt:FR.cfg.trlInt(2),1:size(FR.mice.(cfg.Mice(iM).name).sort.rew,2),plotData(FR.mice.(cfg.Mice(iM).name).sortABS.rew,:)); colorbar; caxis([-5 5])
        hold on
        line([0 0],[1 size(FR.mice.(cfg.Mice(iM).name).sort.trgtPre,2)],'color','r')
        line([1 1],[1 size(FR.mice.(cfg.Mice(iM).name).sort.trgtPre,2)],'color','r')
        line([3 3],[1 size(FR.mice.(cfg.Mice(iM).name).sort.trgtPre,2)],'color','k')
        line([4 4],[1 size(FR.mice.(cfg.Mice(iM).name).sort.trgtPre,2)],'color','k')
        set(gca,'FontSize',18)
        xlabel('Time from context cue onset (s)');
        if iM == 3
            ylabel('Unit id');
        end
        title('FR diff to rew vs. unrew trials')
        
    end
    
end

end