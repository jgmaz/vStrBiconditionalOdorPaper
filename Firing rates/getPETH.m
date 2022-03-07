function FR = getPETH(cfg_in,FR,Q)
% Organizes task data
cfg_def = [];

cfg = ProcessConfig(cfg_def,cfg_in);

for iC = 1:size(Q.S.data,1)
    
    temp = [];
    
    if ~isfield(FR,'PETH')
        
        FR.PETH.ctxDiff = [];
        FR.PETH.delayDiff = [];
        FR.PETH.trgtDiff = [];
        FR.PETH.rewDiff = [];
        FR.PETH.ctxAll = [];
        FR.PETH.ctxAllNorm = [];
        FR.nSpk.ctx = [];
        FR.PETH.npDiff = [];
        FR.PETH.npAll = [];
        FR.PETH.npAllNorm = [];
        FR.nSpk.np = [];
        
    end
    
    %find stable times
    cell_id = strcmp(Q.S.label{iC},cfg.ExpKeys.cellID);
    
    cellStart = cfg.ExpKeys.cellStart(cell_id)/10000;
    cellEnd = cfg.ExpKeys.cellEnd(cell_id)/10000;
    
    firstSpk = find(Q.S.tvec > cellStart, 1, 'first');
    lastSpk = find(Q.S.tvec < cellEnd, 1, 'last');
    
    buffer = cfg.trlInt(2)/cfg.dt;
    
    firstSpk = firstSpk - buffer;
    
    if firstSpk < 1
        
        firstSpk = 1;
        
    end
    
    lastSpk = lastSpk + buffer;
    
    if lastSpk > length(Q.S.tvec)
        
        lastSpk = length(Q.S.tvec);
        
    end
    
    C1 = find(strcmp(Q.odor.label,'Context 1'));
    C2 = find(strcmp(Q.odor.label,'Context 2'));
    T1 = find(strcmp(Q.odor.label,'Target 1'));
    T2 = find(strcmp(Q.odor.label,'Target 2'));
    
    trial_idx = find(Q.odor.data(C1,firstSpk:lastSpk) == 1);
    trial_idx = cat(2,trial_idx,find(Q.odor.data(C2,firstSpk:lastSpk) == 1));
    trial_idx = sort(trial_idx);
    trial_idx = trial_idx + (firstSpk - 1); % adjust for when firstSpk > 1
    t_start = Q.odor.tvec(trial_idx) + cfg.trlInt(1);
    t_end = Q.odor.tvec(trial_idx) + cfg.trlInt(2);
    
    Q.odor_trl = restrict(Q.odor,t_start,t_end);
    Q_keep = ismember(Q.odor.tvec,Q.odor_trl.tvec);
    
    Q.trgt_trl = Q.trgt;
    Q.trgt_trl.tvec = Q.trgt_trl.tvec(:,Q_keep);
    Q.trgt_trl.data = Q.trgt_trl.data(:,Q_keep);
    
    Q.S_trl = Q.S;
    Q.S_trl.tvec = Q.S_trl.tvec(:,Q_keep);
    Q.S_trl.data = Q.S_trl.data(:,Q_keep);
    quiet_idx = find(sum(Q.S_trl.data,2) == 0)';
    
    Q.rew_trl = Q.rew;
    Q.rew_trl.tvec = Q.rew_trl.tvec(:,Q_keep);
    Q.rew_trl.data = Q.rew_trl.data(:,Q_keep);
    
    Q.beh_trl = Q.beh;
    Q.beh_trl.tvec = Q.beh_trl.tvec(:,Q_keep);
    Q.beh_trl.data = Q.beh_trl.data(:,Q_keep);
    
    %% ctx
    C1xT1 = find(strcmp(Q.trgt.label,'Trgt 1 - Ctx 1'));
    C1xT2 = find(strcmp(Q.trgt.label,'Trgt 2 - Ctx 1'));
    C2xT1 = find(strcmp(Q.trgt.label,'Trgt 1 - Ctx 2'));
    C2xT2 = find(strcmp(Q.trgt.label,'Trgt 2 - Ctx 2'));
    
    CxT = [C1xT1 C1xT2 C2xT1 C2xT2];
    
    for iType = 1:length(CxT)
        
%         idx = find(Q.odor_trl.data(CxT(iType),:) == 1);
        idx = find(Q.trgt_trl.data(CxT(iType),:) == 1);
        
        if ~isempty(idx)
            
            for iT = 1:length(idx)
                
%                 t_start = idx(iT) + cfg.trlInt(1)/cfg.dt; t_stop = idx(iT) + cfg.trlInt(2)/cfg.dt - 1;
t_start = idx(iT) - 3/cfg.dt + cfg.trlInt(1)/cfg.dt; t_stop = idx(iT) - 3/cfg.dt + cfg.trlInt(2)/cfg.dt - 1;
                if t_stop <= length(Q.S_trl.data(iC,:)) & t_start > 0
                    temp.ctx{iType}(iT,:) = Q.S_trl.data(iC,t_start:t_stop);
                else
                    disp(['cell ' num2str(iC) ' - ' num2str(iType) ' - trial ' num2str(iT) ' skipped'])
                end
                
            end
            
            temp.meanCtx(iType,:) = mean(temp.ctx{iType},1) / cfg.dt;
            
        else
            temp.ctx{iType}(1,:) = NaN(length(cfg.trlInt(1)/cfg.dt:(cfg.trlInt(2)/cfg.dt - 1)),1);
            temp.meanCtx(iType,:) = NaN(length(cfg.trlInt(1)/cfg.dt:(cfg.trlInt(2)/cfg.dt - 1)),1);
        end
    end
    
    bins = cfg.trlInt(1):cfg.dt:cfg.trlInt(2);
    ctx_times(1) = find(bins > 0,1,'first');    ctx_times(2) = find(bins >= 0 + cfg.trlLen,1,'first');
    delay_times(1) = find(bins > 0 + cfg.delayT,1,'first');    delay_times(2) = find(bins >= 0 + cfg.delayT + cfg.trlLen,1,'first');
    trgt_times(1) = find(bins > 3,1,'first');   trgt_times(2) = find(bins >= 3 + cfg.trlLen,1,'first');
    
    %ctx
    temp1 = cat(1,temp.ctx{1},temp.ctx{2}); ctx1 = mean(nanmean(temp1(:,ctx_times(1):ctx_times(2)),1));
    temp2 = cat(1,temp.ctx{3},temp.ctx{4}); ctx2 = mean(nanmean(temp2(:,ctx_times(1):ctx_times(2)),1));
    if ctx1 > ctx2
        temp.diffCtx = (nanmean(temp1,1) - nanmean(temp2,1)) / cfg.dt;
    else
        temp.diffCtx = (nanmean(temp2,1) - nanmean(temp1,1)) / cfg.dt;
    end
    
        %delay
    temp1 = cat(1,temp.ctx{1},temp.ctx{2}); delay1 = mean(nanmean(temp1(:,delay_times(1):delay_times(2)),1));
    temp2 = cat(1,temp.ctx{3},temp.ctx{4}); delay2 = mean(nanmean(temp2(:,delay_times(1):delay_times(2)),1));
    
    if delay1 > delay2
        temp.diffDelay = (nanmean(temp1,1) - nanmean(temp2,1)) / cfg.dt;
    else
        temp.diffDelay = (nanmean(temp2,1) - nanmean(temp1,1)) / cfg.dt;
    end
    
    %trgt
    temp1 = cat(1,temp.ctx{1},temp.ctx{3}); trgt1 = mean(nanmean(temp1(:,trgt_times(1):trgt_times(2)),1));
    temp2 = cat(1,temp.ctx{2},temp.ctx{4}); trgt2 = mean(nanmean(temp2(:,trgt_times(1):trgt_times(2)),1));
    
       if trgt1 > trgt2
        temp.diffTrgt = (nanmean(temp1,1) - nanmean(temp2,1)) / cfg.dt;
    else
        temp.diffTrgt = (nanmean(temp2,1) - nanmean(temp1,1)) / cfg.dt;
       end
     
    %rew
    temp1 = cat(1,temp.ctx{1},temp.ctx{4}); rew1 = mean(nanmean(temp1(:,trgt_times(1):trgt_times(2)),1));
    temp2 = cat(1,temp.ctx{2},temp.ctx{3}); rew2 = mean(nanmean(temp2(:,trgt_times(1):trgt_times(2)),1));
    
       if rew1 > rew2
        temp.diffRew = (nanmean(temp1,1) - nanmean(temp2,1)) / cfg.dt;
    else
        temp.diffRew = (nanmean(temp2,1) - nanmean(temp1,1)) / cfg.dt;
       end
    
    temp.Ctx = cat(1,temp.ctx{1},temp.ctx{2},temp.ctx{1},temp.ctx{2});
    temp.allCtx = nanmean(temp.Ctx,1) / cfg.dt;
    temp.CtxnSpk = sum(nansum(temp.Ctx));
    temp.allCtxNorm = temp.allCtx ./ max(temp.allCtx,[],2);
    
    FR.PETH.ctxDiff = cat(1,FR.PETH.ctxDiff,temp.diffCtx);
     FR.PETH.delayDiff = cat(1,FR.PETH.delayDiff,temp.diffDelay);
    FR.PETH.trgtDiff = cat(1,FR.PETH.trgtDiff,temp.diffTrgt);
    FR.PETH.rewDiff = cat(1,FR.PETH.rewDiff,temp.diffRew);
    FR.PETH.ctxAll = cat(1,FR.PETH.ctxAll,temp.allCtx);
    FR.PETH.ctxAllNorm = cat(1,FR.PETH.ctxAllNorm,temp.allCtxNorm);
    FR.nSpk.ctx = cat(1,FR.nSpk.ctx,temp.CtxnSpk);    
    
end

end