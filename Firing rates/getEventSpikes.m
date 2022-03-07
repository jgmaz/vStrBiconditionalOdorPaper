function Q_task = getEventSpikes(cfg_in,Q)
% Organizes task data
cfg_def = [];

cfg = ProcessConfig(cfg_def,cfg_in);

for iC = 1:size(Q.S.data,1)
    
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
    
    trial_idx = find(Q.odorAll.data(C1,firstSpk:lastSpk) == 1); % all trials, not just correct
    trial_idx = cat(2,trial_idx,find(Q.odorAll.data(C2,firstSpk:lastSpk) == 1));
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
    
    Q.trgtErr_trl = Q.trgtErr;
    Q.trgtErr_trl.tvec = Q.trgtErr_trl.tvec(:,Q_keep);
    Q.trgtErr_trl.data = Q.trgtErr_trl.data(:,Q_keep);
    
    %% ctx
    Ctx = [C1 C2];
    
    for iCtx = 1:2
        
        idx = find(Q.odor_trl.data(Ctx(iCtx),:) == 1);
        
        Q_task{iC}.ctx{iCtx} = tsd;
        Q_task{iC}.ctx{iCtx}.tvec = 0:cfg.dt:cfg.trlLen-cfg.dt;
        Q_task{iC}.ctx{iCtx}.label = Q.odor.label{iCtx};
        
        Q_task{iC}.ctxPre{iCtx} = tsd;
        Q_task{iC}.ctxPre{iCtx}.tvec = 0:cfg.dt:cfg.trlLen-cfg.dt;
        
        Q_task{iC}.delay{iCtx} = tsd;
        Q_task{iC}.delay{iCtx}.tvec = 0:cfg.dt:cfg.trlLen-cfg.dt;
        
        for iT = 1:length(idx)
            
            t_start = idx(iT); t_stop = idx(iT) + cfg.trlLen/cfg.dt - 1;
            Q_task{iC}.ctx{iCtx}.data(iT,:) = Q.S_trl.data(iC,t_start:t_stop);
            
            t_start = idx(iT) - cfg.trlLen/cfg.dt; t_stop = idx(iT) - 1;
            Q_task{iC}.ctxPre{iCtx}.data(iT,:) = Q.S_trl.data(iC,t_start:t_stop);
            
            t_start = idx(iT) + cfg.delayT/cfg.dt; t_stop = idx(iT) + cfg.delayT/cfg.dt + cfg.trlLen/cfg.dt - 1;
            Q_task{iC}.delay{iCtx}.data(iT,:) = Q.S_trl.data(iC,t_start:t_stop);
            
        end
        
        Q_task{iC}.ctx{iCtx}.FR = sum(Q_task{iC}.ctx{iCtx}.data,2) / cfg.trlLen;
        Q_task{iC}.ctxPre{iCtx}.FR = sum(Q_task{iC}.ctxPre{iCtx}.data,2) / cfg.trlLen;
        Q_task{iC}.delay{iCtx}.FR = sum(Q_task{iC}.delay{iCtx}.data,2) / cfg.trlLen;
        
    end
    
    %% trgt
    C1xT1 = find(strcmp(Q.trgt.label,'Trgt 1 - Ctx 1'));
    C1xT2 = find(strcmp(Q.trgt.label,'Trgt 2 - Ctx 1'));
    C2xT1 = find(strcmp(Q.trgt.label,'Trgt 1 - Ctx 2'));
    C2xT2 = find(strcmp(Q.trgt.label,'Trgt 2 - Ctx 2'));
    
    CxT = [C1xT1 C1xT2 C2xT1 C2xT2];
    
    for iType = 1:length(CxT)
        
        idx = find(Q.trgt_trl.data(CxT(iType),:) == 1);
        
        Q_task{iC}.trgt{iType} = tsd;
        Q_task{iC}.trgt{iType}.tvec = 0:cfg.dt:cfg.trlLen-cfg.dt;
        Q_task{iC}.trgt{iType}.label = Q.trgt.label{iType};
        
        Q_task{iC}.trgtPre{iType} = tsd;
        Q_task{iC}.trgtPre{iType}.tvec = 0:cfg.dt:cfg.trlLen-cfg.dt;
        
        for iT = 1:length(idx)
            
            t_start = idx(iT); t_stop = idx(iT) + cfg.trlLen/cfg.dt - 1;
            Q_task{iC}.trgt{iType}.data(iT,:) = Q.S_trl.data(iC,t_start:t_stop);
            
            t_start = idx(iT) - cfg.trlLen/cfg.dt; t_stop = idx(iT) - 1;
            Q_task{iC}.trgtPre{iType}.data(iT,:) = Q.S_trl.data(iC,t_start:t_stop);
            
        end
        
        Q_task{iC}.trgt{iType}.FR = sum(Q_task{iC}.trgt{iType}.data,2) / cfg.trlLen;
        Q_task{iC}.trgtPre{iType}.FR = sum(Q_task{iC}.trgtPre{iType}.data,2) / cfg.trlLen;
        
    end
    %% trgt Err
    
    for iType = 1:length(CxT)
        
        idx = find(Q.trgtErr_trl.data(CxT(iType),:) == 1);
        
        Q_task{iC}.trgtErr{iType} = tsd;
        Q_task{iC}.trgtErr{iType}.tvec = 0:cfg.dt:cfg.trlLen-cfg.dt;
        Q_task{iC}.trgtErr{iType}.label = Q.trgt.label{iType};
        
        Q_task{iC}.trgtErrPre{iType} = tsd;
        Q_task{iC}.trgtErrPre{iType}.tvec = 0:cfg.dt:cfg.trlLen-cfg.dt;
        
        for iT = 1:length(idx)
            
            t_start = idx(iT); t_stop = idx(iT) + cfg.trlLen/cfg.dt - 1;
            Q_task{iC}.trgtErr{iType}.data(iT,:) = Q.S_trl.data(iC,t_start:t_stop);
            
            t_start = idx(iT) - cfg.trlLen/cfg.dt; t_stop = idx(iT) - 1;
            Q_task{iC}.trgtErrPre{iType}.data(iT,:) = Q.S_trl.data(iC,t_start:t_stop);
            
        end
        
        Q_task{iC}.trgtErr{iType}.FR = sum(Q_task{iC}.trgtErr{iType}.data,2) / cfg.trlLen;
        Q_task{iC}.trgtErrPre{iType}.FR = sum(Q_task{iC}.trgtErrPre{iType}.data,2) / cfg.trlLen;
        
    end
    
    %% trgt window
    winInt = cfg.trlInt(1):cfg.trlLen:cfg.trlInt(2)-cfg.trlLen;
    winInt = winInt - 3; %change to trgt cue timebase
    
    for iType = 1:length(CxT)
        
        idx = find(Q.trgt_trl.data(CxT(iType),:) == 1);
        
        for iWin = 1:length(winInt)
            
            Q_task{iC}.trgtWin{iWin}{iType} = tsd;
            Q_task{iC}.trgtWin{iWin}{iType}.tvec = 0:cfg.dt:cfg.trlLen-cfg.dt;
            
            for iT = 1:length(idx)
                
                t_start = idx(iT) + winInt(iWin)/cfg.dt; t_stop = idx(iT) + winInt(iWin)/cfg.dt + cfg.trlLen/cfg.dt - 1;
                if t_start == 0
                    t_start = 1;
                    t_stop = t_stop + 1;
                end
                
                if t_stop > length(Q.S_trl.data(iC,:))
                    diff = t_stop -  length(Q.S_trl.data(iC,:));
                    t_stop = length(Q.S_trl.data(iC,:));
                    t_start = t_start - diff;
                end
                Q_task{iC}.trgtWin{iWin}{iType}.data(iT,:) = Q.S_trl.data(iC,t_start:t_stop);
                
            end
            
            Q_task{iC}.trgtWin{iWin}{iType}.FR = sum(Q_task{iC}.trgtWin{iWin}{iType}.data,2) / cfg.trlLen;
            
        end
        
    end
    
    %%    trgt Err window
    
    for iType = 1:length(CxT)
        
        idx = find(Q.trgtErr_trl.data(CxT(iType),:) == 1);
        
        for iWin = 1:length(winInt)
            
            Q_task{iC}.trgtErrWin{iWin}{iType} = tsd;
            Q_task{iC}.trgtErrWin{iWin}{iType}.tvec = 0:cfg.dt:cfg.trlLen-cfg.dt;
            
            for iT = 1:length(idx)
                
                t_start = idx(iT) + winInt(iWin)/cfg.dt; t_stop = idx(iT) + winInt(iWin)/cfg.dt + cfg.trlLen/cfg.dt - 1;
                if t_start == 0
                    t_start = 1;
                    t_stop = t_stop + 1;
                end
                
                if t_stop > length(Q.S_trl.data(iC,:))
                    t_stop = length(Q.S_trl.data(iC,:));
                end
                Q_task{iC}.trgtErrWin{iWin}{iType}.data(iT,:) = Q.S_trl.data(iC,t_start:t_stop);
                
            end
            
            Q_task{iC}.trgtErrWin{iWin}{iType}.FR = sum(Q_task{iC}.trgtErrWin{iWin}{iType}.data,2) / cfg.trlLen;
            
        end
        
    end
    
end

end