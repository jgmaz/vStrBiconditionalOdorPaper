function plotGLM(cfg_in,GLM)
% plots GLM
cfg_def = [];
cfg_def.smooth = 'none'; % gauss or none
cfg_def.gausswin_size = 1; % in seconds
cfg_def.gausswin_sd = 0.05; % in seconds
cfg_def.dt = 0.05;
cfg_def.trlInt = [-2 6];

cfg = ProcessConfig(cfg_def,cfg_in);

%% plot fingerprints for each exmaple
colors{1} = {[136/255 86/255 167/255],[212/255 185/255 218/255]}; % originally had these flipped?
colors{2} = {[253/255 208/255 162/255],[253/255 141/255 60/255]}; % as in rewarded and unrewarded flipped, probably related old way of trialifying data


for iC = 1:length(cfg.examples)
    cd(['E:\vStr-eyeblink\Output\GLM\Spring2021\' cfg.examples{iC}(1:4)])
    load(['GLM-' cfg.examples{iC}(1:15) '.mat']);
    disp(['Plotting cell ' num2str(iC) ' - ' cfg.examples{iC}])
    
    c_idx = find(strcmp(GLM.label,cfg.examples{iC}));
    
    figure('units','normalized','outerposition',[0 0 1 1]);
    
    line_h = 1;
    
    subtightplot(3,2,1) % raster
    box off
    set(gca,'FontSize',18,'YTick',[],'XTick',[])
    ylabel('Trial number')
%     title(['Firing rate for each trial type for ' GLM.label{c_idx}(1:end-2)])
title(GLM.label{c_idx}(1:end-2))
    hold on
    
    for iCtx = 1:2
        
        for iTrgt = 1:2
            
            for iT = 1:GLM.plot.Trgt_count{c_idx}(iCtx,iTrgt)
                
                if ~isempty(GLM.plot.Spk_ts{c_idx}{iCtx}{iTrgt}{iT})
                    
                    if length(GLM.plot.Spk_ts{c_idx}{iCtx}{iTrgt}{iT}) == 2
                        
                        plot([GLM.plot.Spk_ts{c_idx}{iCtx}{iTrgt}{iT}(1) GLM.plot.Spk_ts{c_idx}{iCtx}{iTrgt}{iT}(1)],[line_h line_h+.8],'color',colors{iCtx}{iTrgt})
                        plot([GLM.plot.Spk_ts{c_idx}{iCtx}{iTrgt}{iT}(2) GLM.plot.Spk_ts{c_idx}{iCtx}{iTrgt}{iT}(2)],[line_h line_h+.8],'color',colors{iCtx}{iTrgt})
                        
                    else
                        
                        plot([GLM.plot.Spk_ts{c_idx}{iCtx}{iTrgt}{iT} GLM.plot.Spk_ts{c_idx}{iCtx}{iTrgt}{iT}],[line_h line_h+.8],'color',colors{iCtx}{iTrgt})
                        
                    end
                end
                
                line_h = line_h + 1;
                
            end
            
            line_h = line_h + 4;
            
        end
        
    end
    
    xlim([0 cfg.trlInt(2)-cfg.trlInt(1)]); ylim([0 line_h-3]);
    plot([abs(cfg.trlInt(1)) abs(cfg.trlInt(1))],[0 line_h-3],'--r')
    plot([abs(cfg.trlInt(1))+1 abs(cfg.trlInt(1))+1],[0 line_h-3],'--r')
    plot([abs(cfg.trlInt(1))+3 abs(cfg.trlInt(1))+3],[0 line_h-3],'--k')
    plot([abs(cfg.trlInt(1))+4 abs(cfg.trlInt(1))+4],[0 line_h-3],'--k')
    
    subtightplot(3,2,3) % PSTHs
    box off
    hold on
    
    for iCtx = 1:2
        
        for iTrgt = 1:2
            
            if GLM.plot.Trgt_count{c_idx}(iCtx,iTrgt) > 0
                
                if strcmp(cfg.smooth,'gauss')
                    
                    gauss_window = cfg.gausswin_size./cfg.dt; % 1 second window
                    gauss_SD = cfg.gausswin_sd./cfg.dt; % 0.02 seconds (20ms) SD
                    gk = gausskernel(gauss_window,gauss_SD)'; %gk = gk./cfg.dt; % normalize by binsize
                    gauss_conv = conv2(GLM.plot.Spk_mean{c_idx}{iCtx}{iTrgt},gk,'same');
                    plot([cfg.trlInt(1):cfg.dt:cfg.trlInt(2)],gauss_conv,'color',colors{iCtx}{iTrgt})
                    
                else
                    
                    plot([cfg.trlInt(1):cfg.dt:cfg.trlInt(2)],GLM.plot.Spk_mean{c_idx}{iCtx}{iTrgt},'color',colors{iCtx}{iTrgt})
                    
                end
                
                plot([0 0],[0 max(GLM.plot.Spk_mean{c_idx}{iCtx}{iTrgt})*1.2],'--r')
                plot([1 1],[0 max(GLM.plot.Spk_mean{c_idx}{iCtx}{iTrgt})*1.2],'--r')
                plot([3 3],[0 max(GLM.plot.Spk_mean{c_idx}{iCtx}{iTrgt})*1.2],'--k')
                plot([4 4],[0 max(GLM.plot.Spk_mean{c_idx}{iCtx}{iTrgt})*1.2],'--k')
                set(gca,'FontSize',16)
                ylabel('Firing rate (Hz)')
                xlabel('Time from context odor onset')
                xlim([cfg.trlInt(1) cfg.trlInt(2)])
%                 title('Data PSTH')
                
            end
            
        end
        
    end
    
    set(gcf,'renderer','Painters')
    
    if strcmp(cfg.save,'on')
        saveas(gcf,['C:\Users\mvdmlab\Google Drive\Professional\Project materials\BCD\Figures\results packet\Examples\' GLM.label{c_idx}(1:end-2) '.eps'])
        close
    end
    
end

end