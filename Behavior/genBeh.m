%% set up sessions to run
directory = 'E:\vStr-eyeblink\Data\inAnalysis\';

cd(directory)
Mice = dir;
lick = [];

%% Main analysis
% find sessions to analyze from each mouse
for iM = 3:length(Mice)
    lick.T{iM-2}{2,2} = [];
    Sessions = [];
    
    cd([directory Mice(iM).name])
    temp_sessions = dir;
    Sessions = cat(1,Sessions,temp_sessions(3:end));
    
    % for each session
    for iS = 1:length(Sessions)
        disp(Sessions(iS).name)
        cd([directory Sessions(iS).name(1:4) '\' Sessions(iS).name])
        
        %% Load session data
        LoadExpKeys
        
        cfg_evt = [];
        cfg_evt.eventList = ExpKeys.eventList;
        cfg_evt.eventLabel = ExpKeys.eventLabel;
        
        evt = LoadEvents(cfg_evt);
        
        %% set up task events
        cfg = [];
        
        task = getEvents(cfg,evt);
        
        %% find time of lick
        
        T1 = find(strcmp(task.behCueEvt.label,'Target 1'));
        T2 = find(strcmp(task.behCueEvt.label,'Target 2'));
        Trgts = [T1 T2];
        
        for iTrgt = 1:2
            for iT = 1:length(task.behCueEvt.t{Trgts(iTrgt)})
                idx1 = find(task.Trial_info.Trgt{iTrgt,1} < task.behCueEvt.t{Trgts(iTrgt)}(iT),1,'last');
                idx1 = task.behCueEvt.t{Trgts(iTrgt)}(iT) - task.Trial_info.Trgt{iTrgt,1}(idx1);
                idx2 = find(task.Trial_info.Trgt{iTrgt,2} < task.behCueEvt.t{Trgts(iTrgt)}(iT),1,'last');
                idx2 = task.behCueEvt.t{Trgts(iTrgt)}(iT) - task.Trial_info.Trgt{iTrgt,2}(idx2);
                if idx1 < idx2
                    lick.T{iM-2}{iTrgt,1}(end+1) = idx1;
                elseif idx2 < idx1
                    lick.T{iM-2}{iTrgt,2}(end+1) = idx2;
                end
            end
        end
        
        temp = [];
        for iCtx = 1:2
            for iTrgt = 1:2
                temp(end+1) =  mean(lick.T{iM-2}{iCtx,iTrgt});
            end
        end
        lick.Mean{iM-2}(iS,:) = temp;
        
        
    end
    lick.MeanAll(iM-2,:) = mean(lick.Mean{iM-2},1);
    
end

%% plot
colors = {[136/255 86/255 167/255],[212/255 185/255 218/255],[253/255 208/255 162/255],[253/255 141/255 60/255]};

group = [1 2 3 4];
figure('units','normalized','outerposition',[0 0 1 1]);
subplot(2,2,1)
gscatter([1 1 1 1],lick.MeanAll(:,1),group,colors{1},'xo+*',15)
hold on;
gscatter([1.5 1.5 1.5 1.5],lick.MeanAll(:,2),group,colors{2},'xo+*',15)
gscatter([2 2 2 2],lick.MeanAll(:,4),group,colors{4},'xo+*',15)
gscatter([2.5 2.5 2.5 2.5],lick.MeanAll(:,3),group,colors{3},'xo+*',15)
ylim([0 1])
xlim([0 3.5])
set(gca,'FontSize',18,'xtick',[],'ytick',[0 1])
xlabel('Trial type')
ylabel('Mean lick latency (s)')
title('Lick latency')
box off

%% n sessions
n_sesh = [28 9 18 7];

group = [1 2 3 4];
figure('units','normalized','outerposition',[0 0 1 1]);
subplot(2,4,1)
gscatter([1 1 1 1],n_sesh,group,'k','xo+*',15)
hold on;
ylim([0 30])
xlim([0.75 1.25])

set(gca,'FontSize',18,'xtick',[],'ytick',[0:10:30])
% xlabel('Trial type')
ylabel('Training sessions')
title('Number of training sessions')
box off

%% Analyses for revision

% find sessions to analyze from each mouse
fig1 = figure('units','normalized','outerposition',[0 0 1 1]);
fig2 = figure('units','normalized','outerposition',[0 0 1 1]);

for iM = 3:length(Mice)
    idxAll = [];
    trlNum(1:4) = 1;
    lickAll = [];
    lickAllPETH{4} = [];
    Sessions = [];
    
    cd([directory Mice(iM).name])
    temp_sessions = dir;
    Sessions = cat(1,Sessions,temp_sessions(3:end));
    
end
% for each session
for iS = 1:length(Sessions)
    disp(Sessions(iS).name)
    cd([directory Sessions(iS).name(1:4) '\' Sessions(iS).name])
    lickPETH = [];
    
    %% Load session data
    LoadExpKeys
    
    cfg_evt = [];
    cfg_evt.eventList = ExpKeys.eventList;
    cfg_evt.eventLabel = ExpKeys.eventLabel;
    
    evt = LoadEvents(cfg_evt);
    
    %% set up task events
    cfg = [];
    cfg.behResp = 1; % uses 2 s instead of 1 s window.
    
    task = getEvents(cfg,evt);
    
    % remove small ITIs
    iti = diff(task.behEvt.t{1});
    remIdx = find(iti < 0.045); remIdx = remIdx + 1;
    task.behEvt.t{1}(remIdx) = [];
    
    %% find time of lick
    colors = {[136/255 86/255 167/255],[212/255 185/255 218/255],[253/255 208/255 162/255],[253/255 141/255 60/255]};
    cfg.trlInt = [-.5 5];
    cfg.dt = .05;
    cfg.save = 'off';
    
    C1T1 = find(strcmp(task.goodTrgt.label,'Trgt 1 - Ctx 1'));
    C1T2 = find(strcmp(task.goodTrgt.label,'Trgt 2 - Ctx 1'));
    C2T1 = find(strcmp(task.goodTrgt.label,'Trgt 1 - Ctx 2'));
    C2T2 = find(strcmp(task.goodTrgt.label,'Trgt 2 - Ctx 2'));
    Trgts = [C1T1 C1T2 C2T1 C2T2];
    
    figure('units','normalized','outerposition',[0 0 1 1]);
    
    line_h = 1;
    
    subtightplot(3,2,1) % raster
    box off
    set(gca,'FontSize',18,'YTick',[],'XTick',[])
    ylabel('Trial number')
    title(Sessions(iS).name)
    hold on
    
    for iTrgt = 1:4
        
        lickPETH{iTrgt} = zeros(length(task.goodTrgt.t{Trgts(iTrgt)}),length(cfg.trlInt(1):cfg.dt:cfg.trlInt(2))-1);
        
        for iT = 1:length(task.goodTrgt.t{Trgts(iTrgt)})
            
            licks = [];
            idx = find(task.behEvt.t{1} > task.goodTrgt.t{Trgts(iTrgt)}(iT) - 3.5 & task.behEvt.t{1} < task.goodTrgt.t{Trgts(iTrgt)}(iT) + 2);
            
            if ~isempty(idx)
                
                licks = task.behEvt.t{1}(idx) - task.goodTrgt.t{Trgts(iTrgt)}(iT) + 3;
                
                count = 1;
                for iBin = cfg.trlInt(1):cfg.dt:cfg.trlInt(2)-cfg.dt
                    
                    idx2 = find(licks > iBin & licks < iBin + cfg.dt);
                    lickPETH{iTrgt}(iT,count) = length(idx2);
                    count = count + 1;
                end
                
                if length(licks) == 2
                    
                    plot([licks(1) licks(1)],[line_h line_h+.8],'color',colors{iTrgt})
                    plot([licks(2) licks(2)],[line_h line_h+.8],'color',colors{iTrgt})
                    
                else
                    
                    plot([licks licks],[line_h line_h+.8],'color',colors{iTrgt})
                    
                end
            end
            
            idxAll{iTrgt}{trlNum(iTrgt)} = idx;
            lickAll{iTrgt}{trlNum(iTrgt)} = licks;
            trlNum(iTrgt) = trlNum(iTrgt) + 1;
            
            line_h = line_h + 1;
            
        end
        
        line_h = line_h + 4;
        
        lickAllPETH{iTrgt} = cat(1,lickAllPETH{iTrgt},lickPETH{iTrgt});
        
    end
    
    xlim([cfg.trlInt(1) cfg.trlInt(2)]); ylim([0 line_h-3]);
    plot([0 0],[0 line_h-3],'--r')
    plot([1 1],[0 line_h-3],'--r')
    plot([3 3],[0 line_h-3],'--k')
    plot([4 4],[0 line_h-3],'--k')
    
    subtightplot(3,2,3) % PSTHs
    box off
    hold on
    
    cfg.smooth = 'gauss'; % gauss or none
    cfg.gausswin_size = .5; % in seconds
    cfg.gausswin_sd = 0.05; % in seconds
    
    for iTrgt = 1:4
        
        lickMean = mean(lickPETH{iTrgt})/cfg.dt;
        
        if strcmp(cfg.smooth,'gauss')
            
            gauss_window = cfg.gausswin_size./cfg.dt; % 1 second window
            gauss_SD = cfg.gausswin_sd./cfg.dt; % 0.02 seconds (20ms) SD
            gk = gausskernel(gauss_window,gauss_SD)'; %gk = gk./cfg.dt; % normalize by binsize
            gauss_conv = conv2(lickMean,gk,'same');
            plot([cfg.trlInt(1)+(cfg.dt/2):cfg.dt:cfg.trlInt(2)-(cfg.dt/2)],gauss_conv,'color',colors{iTrgt})
            
        else
            
            plot([cfg.trlInt(1)+(cfg.dt/2):cfg.dt:cfg.trlInt(2)-(cfg.dt/2)],GLM.plot.Spk_mean{c_idx}{iCtx}{iTrgt},'color',colors{iCtx}{iTrgt})
            
        end
        
        plot([0 0],[0 max(lickMean)*1.2],'--r')
        plot([1 1],[0 max(lickMean)*1.2],'--r')
        plot([3 3],[0 max(lickMean)*1.2],'--k')
        plot([4 4],[0 max(lickMean)*1.2],'--k')
        set(gca,'FontSize',16)
        ylabel('Lick rate (Hz)')
        xlabel('Time from context odor onset')
        xlim([cfg.trlInt(1) cfg.trlInt(2)])
        %                 title('Data PSTH')
        
    end
    
    set(gcf,'renderer','Painters')
    
    if strcmp(cfg.save,'on')
        saveas(gcf,['C:\Users\mvdmlab\Google Drive\Professional\Project materials\BCD\Figures\revision\' Sessions(iS).name '.png'])
        close
    end
    
    close
    
end

%% summary plot for mouse
switch iM
    case {3,4}
        Plot1 = fig1;
        offset = 2;
    case {5,6}
        Plot1 = fig2;
        offset = 4;
end

figure(Plot1)

line_h = 1;

subtightplot(3,2,[(iM - offset) (iM - offset + 2)]) % raster
box off
set(gca,'FontSize',18,'YTick',[],'XTick',[])
if iM == 3 || iM == 5
    ylabel('Trial number')
end
title(Mice(iM).name)
hold on

for iTrgt = 1:4
    
    for iT = 1:length(idxAll{iTrgt})
        
        if ~isempty(idxAll{iTrgt}{iT})
            
            if length(lickAll{iTrgt}{iT}) == 2
                
                plot([lickAll{iTrgt}{iT}(1) lickAll{iTrgt}{iT}(1)],[line_h line_h+.8],'color',colors{iTrgt})
                plot([lickAll{iTrgt}{iT}(2) lickAll{iTrgt}{iT}(2)],[line_h line_h+.8],'color',colors{iTrgt})
                
            else
                
                plot([lickAll{iTrgt}{iT} lickAll{iTrgt}{iT}],[line_h line_h+.8],'color',colors{iTrgt})
                
            end
        end
        
        line_h = line_h + 1;
        
    end
    
    plot([cfg.trlInt(1) cfg.trlInt(2)],[line_h+2 line_h+2],'--','color',[.5 .5 .5])
    
    line_h = line_h + 4;
    
end

xlim([cfg.trlInt(1) cfg.trlInt(2)]); ylim([0 line_h-3]);
plot([0 0],[0 line_h-3],'--r')
plot([1 1],[0 line_h-3],'--r')
plot([3 3],[0 line_h-3],'--k')
plot([4 4],[0 line_h-3],'--k')

subtightplot(3,2,iM - offset + 4) % PSTHs
box off
hold on

cfg.smooth = 'gauss'; % gauss or none
cfg.gausswin_size = .5; % in seconds
cfg.gausswin_sd = 0.05; % in seconds

for iTrgt = 1:4
    
    lickMean = mean(lickAllPETH{iTrgt})/cfg.dt;
    
    if strcmp(cfg.smooth,'gauss')
        
        gauss_window = cfg.gausswin_size./cfg.dt; % 1 second window
        gauss_SD = cfg.gausswin_sd./cfg.dt; % 0.02 seconds (20ms) SD
        gk = gausskernel(gauss_window,gauss_SD)'; %gk = gk./cfg.dt; % normalize by binsize
        gauss_conv = conv2(lickMean,gk,'same');
        plot([cfg.trlInt(1)+(cfg.dt/2):cfg.dt:cfg.trlInt(2)-(cfg.dt/2)],gauss_conv,'color',colors{iTrgt})
        
    else
        
        plot([cfg.trlInt(1)+(cfg.dt/2):cfg.dt:cfg.trlInt(2)-(cfg.dt/2)],lickMean,'color',colors{iTrgt})
        
    end
    
    plot([0 0],[0 max(lickMean)*1.2],'--r')
    plot([1 1],[0 max(lickMean)*1.2],'--r')
    plot([3 3],[0 max(lickMean)*1.2],'--k')
    plot([4 4],[0 max(lickMean)*1.2],'--k')
    set(gca,'FontSize',16)
    if iM == 3 || iM == 5
        ylabel('Lick rate (Hz)')
    end
    xlabel('Time from context odor onset')
    xlim([cfg.trlInt(1) cfg.trlInt(2)])
    
end

end

%% adding ITI, ctx, delay, summary to fig 1 e.

directory = 'E:\vStr-eyeblink\Data\inAnalysis\';

cd(directory)
Mice = dir;
lickAllCount{4} = [];
lickSeshCount{20,4} = [];

for iM = 3:length(Mice)
    
    Sessions = [];
    
    if ~strcmp(Mice(iM).name,'M106')
        cd([directory Mice(iM).name])
        
        temp_sessions = dir;
        Sessions = cat(1,Sessions,temp_sessions(3:end));
    end
    
    % end
    
    % for each session
    for iS = 1:length(Sessions)
        disp(Sessions(iS).name)
        cd([directory Sessions(iS).name(1:4) '\' Sessions(iS).name])
        lickCount = [];
        
        %% Load session data
        LoadExpKeys
        
        cfg_evt = [];
        cfg_evt.eventList = ExpKeys.eventList;
        cfg_evt.eventLabel = ExpKeys.eventLabel;
        
        evt = LoadEvents(cfg_evt);
        
        %% set up task events
        cfg = [];
        cfg.behResp = 1; % uses 2 s instead of 1 s window.
        
        task = getEvents(cfg,evt);
        
        %% find time of lick
        
        C1T1 = find(strcmp(task.goodTrgt.label,'Trgt 1 - Ctx 1'));
        C1T2 = find(strcmp(task.goodTrgt.label,'Trgt 2 - Ctx 1'));
        C2T1 = find(strcmp(task.goodTrgt.label,'Trgt 1 - Ctx 2'));
        C2T2 = find(strcmp(task.goodTrgt.label,'Trgt 2 - Ctx 2'));
        Trgts = [C1T1 C1T2 C2T1 C2T2];
        
        for iTrgt = 1:4
            
            lickCount{iTrgt} = zeros(length(task.goodTrgt.t{Trgts(iTrgt)}),3);
            
            for iT = 1:length(task.goodTrgt.t{Trgts(iTrgt)})
                
                lickCount{iTrgt}(iT,1) = ~isempty(find(task.behEvt.t{1} > task.allTrgt.t{Trgts(iTrgt)}(iT) - 5 & task.behEvt.t{1} < task.allTrgt.t{Trgts(iTrgt)}(iT) - 3));
                lickCount{iTrgt}(iT,2) = ~isempty(find(task.behEvt.t{1} > task.allTrgt.t{Trgts(iTrgt)}(iT) - 3 & task.behEvt.t{1} < task.allTrgt.t{Trgts(iTrgt)}(iT) - 2));
                lickCount{iTrgt}(iT,3) = ~isempty(find(task.behEvt.t{1} > task.allTrgt.t{Trgts(iTrgt)}(iT) - 2 & task.behEvt.t{1} < task.allTrgt.t{Trgts(iTrgt)}(iT)));
                
            end
            
            lickSeshCount{iS,iM-2} = cat(1,lickSeshCount{iS,iM-2},lickCount{iTrgt});
            lickAllCount{iM-2} = cat(1,lickAllCount{iM-2},lickCount{iTrgt});
            
        end
        
        lickSeshMean{iM-2}(iS,:) = mean(lickSeshCount{iS,iM-2},1);
        lickSeshStd{iM-2}(iS,:) = std(lickSeshCount{iS,iM-2},[],1);
        
    end
    
    lickAllMean(iM-2,:) = mean(lickAllCount{iM-2},1);
    lickAllStd(iM-2,:) = std(lickAllCount{iM-2},[],1);
    
    lickSeshMeanOut(iM-2,:) =  mean(lickSeshMean{iM-2},1);
    lickSeshStdOut(iM-2,:) =  std(lickSeshMean{iM-2},1);
    
end

%% training and summary data
mouse = {'M040','M111','M142','M146'};
behav = [];
meanBeh = [];
behavS = [];
meanBehS = [];

for iM = 1:4
    mouse_id = mouse{iM};
    for iType = 1:2
        
        switch iType
            case 1
                cd(['C:\Users\mvdmlab\Google Drive\Professional\Project materials\BCD\Data\' mouse_id '\behavior\training\']);
            case 2
                cd(['C:\Users\mvdmlab\Google Drive\Professional\Project materials\BCD\Data\' mouse_id '\behavior\recording\']);
                
        end
        %% summary of training full task
        sessions = dir;
        s_type = 'full';
        all_bins = [];
        bin_size = 10;
        
        for iS = 1:length(sessions)%[1:11 15:18 20:length(sessions)]
            
            current_session = strfind(sessions(iS).name,s_type);
            
            if ~isempty(current_session)
                
                load(sessions(iS).name)
                
                for iTrial = 1:4
                    
                    t_idx{iTrial} = find(sequence.cue_order(1:sequence.nTrials) == iTrial);
                    t_behav{iTrial} = sequence.behavior(t_idx{iTrial});
                    
                    behav{iM,iType}(iS-2,iTrial) = sum(t_behav{iTrial}) / length(t_behav{iTrial});
                end
                
                t_idx = [];
                t_behav = [];
                
                if iType == 2
                    for iSh = 1:100
                        s_idx = randperm(4);
                        behavS{iM}(iS-2,:,iSh) =  behav{iM,iType}(iS-2,s_idx);
                        
                    end
                    
                end
            end
        end
        
    end
    
    meanBeh(:,iM) = mean(behav{iM,iType},1);
    meanBehS(:,iM,:) = mean(behavS{iM},1);
    
end

% overall rew v unrew
diff_m = mean([(meanBeh(1,:) - meanBeh(2,:)) (meanBeh(4,:) - meanBeh(3,:))]);

for iS = 1:100
    diff_s(iS) = mean([(meanBehS(1,:,iS) - meanBehS(2,:,iS)) (meanBehS(4,:,iS) - meanBehS(3,:,iS))]);
end

diff_z = (diff_m - mean(diff_s)) / std(diff_s);

% ctx 1 v ctx 2 (similar outcome value)
diff_m = mean([(meanBeh(1,:) - meanBeh(4,:)) (meanBeh(2,:) - meanBeh(3,:))]);

for iS = 1:100
    diff_s(iS) = mean([(meanBehS(1,:,iS) - meanBehS(4,:,iS)) (meanBehS(2,:,iS) - meanBehS(3,:,iS))]);
end

diff_ctx_z = (diff_m - mean(diff_s)) / std(diff_s);

%% learning curves
colors = {[136/255 86/255 167/255],[212/255 185/255 218/255],[253/255 208/255 162/255],[253/255 141/255 60/255]};

figure
subplot(2,1,1)
for iTrial = 1:4
    hold on
    plot(bin_size:bin_size:n_bins*bin_size,all_bins(iTrial,:),'color',colors{iTrial})
end

ylabel('Proportion of lick trials'); title(['Context-dependent odor discrimination full task training (' mouse_id ')']);
xlabel('Trial number');
set(gca,'FontSize',18,'ytick',0:.5:1); box off

%% recording summaries
meanBeh = cat(1,meanBeh,lickAllMean');

group = [1 2 3 4];
figure('units','normalized','outerposition',[0 0 1 1]);
subplot(2,3,1:2)
gscatter([2.5 2.5 2.5 2.5],meanBeh(1,:),group,colors{1},'xo+*',15)
hold on;
gscatter([3 3 3 3],meanBeh(2,:),group,colors{2},'xo+*',15)
gscatter([3.5 3.5 3.5 3.5],meanBeh(4,:),group,colors{4},'xo+*',15)
gscatter([4 4 4 4],meanBeh(3,:),group,colors{3},'xo+*',15)
gscatter([1 1 1 1 ],meanBeh(5,:),group,'k','xo+*',15)
gscatter([1.5 1.5 1.5 1.5],meanBeh(6,:),group,'k','xo+*',15)
gscatter([2 2 2 2],meanBeh(7,:),group,'k','xo+*',15)
ylim([0 1])
xlim([0 5])
set(gca,'FontSize',18,'xtick',[],'ytick',[0:.25:1])
xlabel('Trial type')
ylabel('Proportion licked')
title('Behavioral performance')
box off