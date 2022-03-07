function plotdPCA(cfg_in,Proj,reg,R2,PCids)
% get FR data into format for Kobak's dPCA function
cfg_def = [];

cfg = ProcessConfig(cfg_def,cfg_in);

%% set params
colors = {[136/255 86/255 167/255],[253/255 141/255 60/255],[212/255 185/255 218/255],[253/255 208/255 162/255]}; % originally had these flipped?
%note order of colors diff here
pre_trial = 1;
ctx_start = find(cfg.time == 0);
ctx_stop = find(cfg.time == 1);
delay = find(cfg.time == 2);
delay_m(1:4) = find(cfg.time == 1.5);
delay_m(4) = find(cfg.time == 2.25);
trgt_start = find(cfg.time == 3);
trgt_stop = find(cfg.time == 4);
bins = -.25:.25:4.75;

%% summary figure
ids{1} = [1 1 1 1];
ids{2} = [5 4 3 3];
ids{3} = [9 12 9 6];
ids{4} = [3 10 10 2];
ids{5} = [7 8 5 7];
ids{6} = [4 2 11 5];
ids_labels = {'General','State value','Context','Delay','Target','Outcome'};
mice = {'M040','M111','M142','M146'};

fig1 = figure('units','normalized','outerposition',[0 0 1 1]);
fig2 = figure('units','normalized','outerposition',[0 0 1 1]);
fig3 = figure('units','normalized','outerposition',[0 0 1 1]);
fig4 = figure('units','normalized','outerposition',[0 0 1 1]);

for iM = 1:4
    iPlot = 0;
    switch iM
        case {1,2}
            figure(fig1)
            offset = 0;
        case {3,4}
            figure(fig3)
            offset = 2;
    end
    for iPC = 1:length(ids)
        PC_max = max(max([Proj{iM}.trial{1}(:, ids{iPC}(iM)) Proj{iM}.trial{2}(:, ids{iPC}(iM)) Proj{iM}.trial{3}(:, ids{iPC}(iM)) Proj{iM}.trial{4}(:, ids{iPC}(iM))]));
        PC_min = min(min([Proj{iM}.trial{1}(:, ids{iPC}(iM)) Proj{iM}.trial{2}(:, ids{iPC}(iM)) Proj{iM}.trial{3}(:, ids{iPC}(iM)) Proj{iM}.trial{4}(:, ids{iPC}(iM))]));
        
        subplot(3,2,iPlot + iM - offset)
        hold on
        plot(cfg.twin(1):cfg.dt:cfg.twin(2),Proj{iM}.trial{1}(:, ids{iPC}(iM)),'color',colors{1})
        plot(cfg.twin(1):cfg.dt:cfg.twin(2),Proj{iM}.trial{2}(:, ids{iPC}(iM)),'color',colors{2})
        plot(cfg.twin(1):cfg.dt:cfg.twin(2),Proj{iM}.trial{3}(:, ids{iPC}(iM)),'color',colors{3})
        plot(cfg.twin(1):cfg.dt:cfg.twin(2),Proj{iM}.trial{4}(:, ids{iPC}(iM)),'color',colors{4})
        plot([0 0],[PC_max*1.2 PC_min*1.2],'--r')
        plot([1 1],[PC_max*1.2 PC_min*1.2],'--r')
        plot([3 3],[PC_max*1.2 PC_min*1.2],'--k')
        plot([4 4],[PC_max*1.2 PC_min*1.2],'--k')
        ylim([PC_min*1.2 PC_max*1.2])
        set(gca,'FontSize',16)
        title(['Component #' num2str(ids{iPC}(iM)) ' (' num2str(PCids{iM}.explVar.componentVar(ids{iPC}(iM))) '%)'])
        iPlot = iPlot + 2;
        
        if iM == 1
            ylabel(ids_labels{iPC});
        end
        if iPC == length(ids)
            xlabel('Time from context cue onset (s)')
        elseif iPC == 3
            iPlot = 0;
            switch iM
                case {1,2}
                    figure(fig2)
                case {3,4}
                    figure(fig4)
            end
        end
        
    end
end

%% beh reg
for iM = 1:4
    
    figure('units','normalized','outerposition',[0 0 1 1]);
    
    c1 = ids{4}(iM);
    c2 = ids{6}(iM);
    
    subplot(3,2,[1 3])
    plot(Proj{iM}.trial{1}(:, c1),Proj{iM}.trial{1}(:, c2),'color',colors{1})
    hold on
    plot(Proj{iM}.trial{2}(:, c1),Proj{iM}.trial{2}(:, c2),'color',colors{2})
    plot(Proj{iM}.trial{3}(:, c1),Proj{iM}.trial{3}(:, c2),'color',colors{3})
    plot(Proj{iM}.trial{4}(:, c1),Proj{iM}.trial{4}(:, c2),'color',colors{4})
    
    t_start{1} = [Proj{iM}.trial{1}(pre_trial, c1) Proj{iM}.trial{2}(pre_trial, c1) Proj{iM}.trial{3}(pre_trial, c1) Proj{iM}.trial{4}(pre_trial, c1)];
    t_start{2} = [Proj{iM}.trial{1}(pre_trial, c2) Proj{iM}.trial{2}(pre_trial, c2) Proj{iM}.trial{3}(pre_trial, c2) Proj{iM}.trial{4}(pre_trial, c2)];
    plot(t_start{:}, 'ro', 'MarkerSize', 10);
    
    t_end4{1} = [Proj{iM}.trial{1}(delay_m(iM), c1) Proj{iM}.trial{2}(delay_m(iM), c1) Proj{iM}.trial{3}(delay_m(iM), c1) Proj{iM}.trial{4}(delay_m(iM), c1)];
    t_end4{2} = [Proj{iM}.trial{1}(delay_m(iM), c2) Proj{iM}.trial{2}(delay_m(iM), c2) Proj{iM}.trial{3}(delay_m(iM), c2) Proj{iM}.trial{4}(delay_m(iM), c2)];
    plot(t_end4{:}, 'co', 'MarkerSize', 10);
    
    t_end5{1} = [Proj{iM}.trial{1}(trgt_stop, c1) Proj{iM}.trial{2}(trgt_stop, c1) Proj{iM}.trial{3}(trgt_stop, c1) Proj{iM}.trial{4}(trgt_stop, c1)];
    t_end5{2} = [Proj{iM}.trial{1}(trgt_stop, c2) Proj{iM}.trial{2}(trgt_stop, c2) Proj{iM}.trial{3}(trgt_stop, c2) Proj{iM}.trial{4}(trgt_stop, c2)];
    plot(t_end5{:}, 'ko', 'MarkerSize', 10);
    
    set(gca,'FontSize',16)
    title([mice{iM} ' progression through a trial'])
    xlabel('Context-related delay component')
    ylabel('Value component')
    box off
    
    subplot(3,2,5)
    plot(bins,reg{iM}.prop(1:end-1))
    hold on
    ylim([0 1])
    plot([0 0],[0 1],'--r'); plot([3 3],[0 1],'--k');
    plot([1 1],[0 1],'--r'); plot([4 4],[0 1],'--k');
    title('Predicting trial response from context'); set(gca,'FontSize',16)
    ylabel('Prop. correct')
    box off
    
    subplot(3,2,2)
    plot(bins,R2{iM}.data.all{1})
    hold on
    shadedErrorBar(bins,R2{iM}.shuff.all.mean{1}(1,:),R2{iM}.shuff.all.std{1}(1,:)*1.96,'r',1)
    ylim([0 .6])
    plot([0 0],[0 1],'--r'); plot([3 3],[0 1],'--k');
    plot([1 1],[0 1],'--r'); plot([4 4],[0 1],'--k');
    title('Predicting value from context (target trials)'); set(gca,'FontSize',16)
    xlabel('Time from context cue onset (s)')
    ylabel('R2')
    box off
    
    subplot(3,2,6)
    hold on
    for iRem = 1:length(R2{iM}.remove.data.all{1})-1
        plot(bins,R2{iM}.remove.data.all{1}{iRem})
    end
    ylim([0 .6])
    plot([0 0],[0 1],'--r'); plot([3 3],[0 1],'--k');
    plot([1 1],[0 1],'--r'); plot([4 4],[0 1],'--k');
    title('Removing units from context component'); set(gca,'FontSize',16)
    xlabel('Time from context cue onset (s)')
    ylabel('R2')
    box off
    
    subplot(3,2,4)
    plot(bins,R2{iM}.data.all{2})
    hold on
    shadedErrorBar(bins,R2{iM}.shuff.all.mean{2}(1,:),R2{iM}.shuff.all.std{2}(1,:)*1.96,'r',1)
    ylim([0 .6])
    plot([0 0],[0 1],'--r'); plot([3 3],[0 1],'--k');
    plot([1 1],[0 1],'--r'); plot([4 4],[0 1],'--k');
    title('Predicting value from context (context trials)'); set(gca,'FontSize',16)
    box off
    
    ylabel('R2')
    
end

end