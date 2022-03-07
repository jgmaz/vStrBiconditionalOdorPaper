function plotdPCAshuff(cfg_in,Proj,reg,R2,PCids)
% get FR data into format for Kobak's dPCA function
cfg_def = [];

cfg = ProcessConfig(cfg_def,cfg_in);

%% consolidate shuffles

use.gen = {[1 3],[1 3],[1 3],[1 2]};
use.ctx = {[1 2],[1 2],[2 1],[1 2]};

for iM = 1:size(ProjShuf,1) % rename shuffle e.g. Proj to ProjShuf
    
    ProjShufAll{iM} = [];
    
    for iS = 1:size(ProjShuf,2)
        
        idxPC(1) = PCidsShuf{iM,iS}.gen(use.gen{iM}(1));
        idxPC(2) = PCidsShuf{iM,iS}.gen(use.gen{iM}(2));
        
        if length(PCidsShuf{iM,iS}.ctx) > 1
            
            idxPC(3) = PCidsShuf{iM,iS}.ctx(use.ctx{iM}(1));
            idxPC(4) = PCidsShuf{iM,iS}.ctx(use.ctx{iM}(2));
            
        else
            
            idxPC(3) = PCidsShuf{iM,iS}.ctx(1);
            idxPC(4) = PCidsShuf{iM,iS}.ctx(1);
            
        end
        
        idxPC(5) = PCidsShuf{iM,iS}.trgt(1);
        idxPC(6) = PCidsShuf{iM,iS}.out(1);
        
        for iPC = 1:length(idxPC)
            
            VarShuf{iM}.all(iPC,iS) = PCidsShuf{iM,iS}.explVar.componentVar(idxPC(iPC));
            
            for iT = 1:4
                
                ProjShufAll{iM}.all{iPC,iT}(:,iS) = ProjShuf{iM,iS}.trial{iT}(:,idxPC(iPC));
                
            end
            
        end
        
    end
    
    VarShuf{iM}.mean = mean(VarShuf{iM}.all,2);
    VarShuf{iM}.std = std(VarShuf{iM}.all,[],2);
    
    for iPC = 1:length(idxPC)
        
        for iT = 1:4
            
            ProjShufAll{iM}.mean{iPC,iT} = mean(ProjShufAll{iM}.all{iPC,iT},2);
            ProjShufAll{iM}.std{iPC,iT} = std(ProjShufAll{iM}.all{iPC,iT},[],2);
            
        end
        
    end
    
end


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
ids{2} = [5 4 3 2];
ids{3} = [3 10 10 7];
ids{4} = [9 12 9 16];
ids{5} = [7 8 5 5];
ids{6} = [4 2 11 4];

ids_labels = {'General','State value','Delay','Context','Target','Outcome'};
mice = {'M040','M111','M142','M146'};

fig1 = figure('units','normalized','outerposition',[0 0 1 1]);  set(gcf,'renderer','Painters')
fig2 = figure('units','normalized','outerposition',[0 0 1 1]);  set(gcf,'renderer','Painters')
fig3 = figure('units','normalized','outerposition',[0 0 1 1]);  set(gcf,'renderer','Painters')
fig4 = figure('units','normalized','outerposition',[0 0 1 1]);  set(gcf,'renderer','Painters')

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
        
        shadedErrorBar(cfg.twin(1):cfg.dt:cfg.twin(2),ProjShufAll{iM}.mean{iPC,1},ProjShufAll{iM}.std{iPC,1}*1.96,{'color',colors{1}},1)
        shadedErrorBar(cfg.twin(1):cfg.dt:cfg.twin(2),ProjShufAll{iM}.mean{iPC,2},ProjShufAll{iM}.std{iPC,2}*1.96,{'color',colors{2}},1)
        shadedErrorBar(cfg.twin(1):cfg.dt:cfg.twin(2),ProjShufAll{iM}.mean{iPC,3},ProjShufAll{iM}.std{iPC,3}*1.96,{'color',colors{3}},1)
        shadedErrorBar(cfg.twin(1):cfg.dt:cfg.twin(2),ProjShufAll{iM}.mean{iPC,4},ProjShufAll{iM}.std{iPC,4}*1.96,{'color',colors{4}},1)
        
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% descending order shuffle
ProjShufAll = [];
VarShuf = [];

%% consolidate shuffles
cmp_order{1} = {'gen','gen','ctx','out','gen','gen','trgt','gen','ctx','gen','out','gen'};
cmp_order{2} = {'gen','out','gen','gen','gen','out','gen','trgt','gen','ctx','out','ctx'};
cmp_order{3} = {'gen','gen','gen','gen','trgt','gen','gen','gen','ctx','ctx','out','gen'};
cmp_order{4} = {'gen','gen','gen','out','trgt','gen','ctx','out','gen','trgt','ctx','out'};

chgDirect = [6 7 12 6]; %dPCA sometimes switches direction of signal, make consistent in summary plots
chgWhich = [1 1 0 0];
direct_shift = 0;

for iM = 1:size(ProjShuf,1) % rename shuffle e.g. Proj to ProjShuf
    
    ProjShufAll{iM} = [];
    
    for iS = 1:size(ProjShuf,2)
        
        idxs.gen = 1; idxs.out = 1; idxs.trgt = 1; idxs.ctx = 1;
        
        for iPC = 1:length(cmp_order{iM})
            
            if length(PCidsShuf{iM,iS}.(cmp_order{iM}{iPC})) < idxs.(cmp_order{iM}{iPC})
                idxs.(cmp_order{iM}{iPC}) = length(PCidsShuf{iM,iS}.(cmp_order{iM}{iPC}));
            end
            
            idxPC(iPC) = PCidsShuf{iM,iS}.(cmp_order{iM}{iPC})(idxs.(cmp_order{iM}{iPC}));
            
            idxs.(cmp_order{iM}{iPC}) = idxs.(cmp_order{iM}{iPC}) + 1;
            
            VarShuf{iM}.all(iPC,iS) = PCidsShuf{iM,iS}.explVar.componentVar(idxPC(iPC));
            
            if iPC == chgDirect(iM)
                
                test_dir = mean(ProjShuf{iM,iS}.trial{1}(1:100,idxPC(iPC)));
                
                switch chgWhich(iM)
                    
                    case 1
                        if test_dir > 0
                            direct_shift = 1;
                        end
                    case 0
                        if test_dir < 0
                            direct_shift = 1;
                        end
                        
                end
                
            end
            
            for iT = 1:4
                
                if direct_shift
                    
                    ProjShufAll{iM}.all{iPC,iT}(:,iS) = -ProjShuf{iM,iS}.trial{iT}(:,idxPC(iPC));
                    
                else
                    
                    ProjShufAll{iM}.all{iPC,iT}(:,iS) = ProjShuf{iM,iS}.trial{iT}(:,idxPC(iPC));
                    
                end
                
            end
            
            direct_shift = 0;
            
        end
        
    end
    
    VarShuf{iM}.mean = mean(VarShuf{iM}.all,2);
    VarShuf{iM}.std = std(VarShuf{iM}.all,[],2);
    
    for iPC = 1:length(idxPC)
        
        for iT = 1:4
            
            ProjShufAll{iM}.mean{iPC,iT} = mean(ProjShufAll{iM}.all{iPC,iT},2);
            ProjShufAll{iM}.std{iPC,iT} = std(ProjShufAll{iM}.all{iPC,iT},[],2);
            
        end
        
    end
    
end

%% summary figure
idsLbl{1} = [1 5 3 9 7 4];
idsLbl{2} = [1 4 10 12 8 2];
idsLbl{3} = [1 3 10 9 5 11];
idsLbl{4} = [1 2 7 11 5 4];

ids_labels = {'General','State value','Delay','Context','Target','Outcome'};
mice = {'M040','M111','M142','M146'};

fig1 = figure('units','normalized','outerposition',[0 0 1 1]);  set(gcf,'renderer','Painters')
fig2 = figure('units','normalized','outerposition',[0 0 1 1]);  set(gcf,'renderer','Painters')
fig3 = figure('units','normalized','outerposition',[0 0 1 1]);  set(gcf,'renderer','Painters')
fig4 = figure('units','normalized','outerposition',[0 0 1 1]);  set(gcf,'renderer','Painters')
fig5 = figure('units','normalized','outerposition',[0 0 1 1]);  set(gcf,'renderer','Painters')
fig6 = figure('units','normalized','outerposition',[0 0 1 1]);  set(gcf,'renderer','Painters')
fig7 = figure('units','normalized','outerposition',[0 0 1 1]);  set(gcf,'renderer','Painters')
fig8 = figure('units','normalized','outerposition',[0 0 1 1]);  set(gcf,'renderer','Painters')

for iM = 1:4
    iPlot = 0;
    switch iM
        case {1,2}
            figure(fig1)
            offset = 0;
        case {3,4}
            figure(fig5)
            offset = 2;
    end
    for iPC = 1:12
        PC_max = max(max([Proj{iM}.trial{1}(:, iPC) Proj{iM}.trial{2}(:, iPC) Proj{iM}.trial{3}(:, iPC) Proj{iM}.trial{4}(:, iPC)]));
        PC_min = min(min([Proj{iM}.trial{1}(:, iPC) Proj{iM}.trial{2}(:, iPC) Proj{iM}.trial{3}(:, iPC) Proj{iM}.trial{4}(:, iPC)]));
        
        subplot(3,2,iPlot + iM - offset)
        hold on
        
        shadedErrorBar(cfg.twin(1):cfg.dt:cfg.twin(2),ProjShufAll{iM}.mean{iPC,1},ProjShufAll{iM}.std{iPC,1}*1.96,{'color',colors{1}},1)
        shadedErrorBar(cfg.twin(1):cfg.dt:cfg.twin(2),ProjShufAll{iM}.mean{iPC,2},ProjShufAll{iM}.std{iPC,2}*1.96,{'color',colors{2}},1)
        shadedErrorBar(cfg.twin(1):cfg.dt:cfg.twin(2),ProjShufAll{iM}.mean{iPC,3},ProjShufAll{iM}.std{iPC,3}*1.96,{'color',colors{3}},1)
        shadedErrorBar(cfg.twin(1):cfg.dt:cfg.twin(2),ProjShufAll{iM}.mean{iPC,4},ProjShufAll{iM}.std{iPC,4}*1.96,{'color',colors{4}},1)
        
        plot(cfg.twin(1):cfg.dt:cfg.twin(2),Proj{iM}.trial{1}(:, iPC),'color',colors{1})
        plot(cfg.twin(1):cfg.dt:cfg.twin(2),Proj{iM}.trial{2}(:, iPC),'color',colors{2})
        plot(cfg.twin(1):cfg.dt:cfg.twin(2),Proj{iM}.trial{3}(:, iPC),'color',colors{3})
        plot(cfg.twin(1):cfg.dt:cfg.twin(2),Proj{iM}.trial{4}(:, iPC),'color',colors{4})
        plot([0 0],[PC_max*1.2 PC_min*1.2],'--r')
        plot([1 1],[PC_max*1.2 PC_min*1.2],'--r')
        plot([3 3],[PC_max*1.2 PC_min*1.2],'--k')
        plot([4 4],[PC_max*1.2 PC_min*1.2],'--k')
        ylim([PC_min*1.2 PC_max*1.2])
        set(gca,'FontSize',16)
        
        lbl_idx = find(idsLbl{iM} == iPC);
        
        if isempty(lbl_idx)
            title(['Component #' num2str(iPC) ' (' num2str(PCids{iM}.explVar.componentVar(iPC)) '%)'])
        else
            title(['Component #' num2str(iPC) ' (' num2str(PCids{iM}.explVar.componentVar(iPC)) '%): "' ids_labels{lbl_idx} '"'])
        end
        iPlot = iPlot + 2;
        
        if iPC == 12
            xlabel('Time from context cue onset (s)')
        elseif iPC == 3
            iPlot = 0;
            switch iM
                case {1,2}
                    figure(fig2)
                case {3,4}
                    figure(fig6)
            end
            
        elseif iPC == 6
            iPlot = 0;
            switch iM
                case {1,2}
                    figure(fig3)
                case {3,4}
                    figure(fig7)
            end
            
        elseif iPC == 9
            iPlot = 0;
            switch iM
                case {1,2}
                    figure(fig4)
                case {3,4}
                    figure(fig8)
            end
        end
        
    end
end

end