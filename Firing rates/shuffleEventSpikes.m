function Q_shuff = shuffleEventSpikes(cfg_in,Q_task)
% Organizes task data
cfg_def = [];

cfg = ProcessConfig(cfg_def,cfg_in);

%%
Q_shuff = [];

%checks

if ~strcmp(Q_task{1}.trgt{1}.label,'Trgt 1 - Ctx 1')
    error('Odor pairings off')
    
elseif ~strcmp(Q_task{1}.trgt{2}.label,'Trgt 2 - Ctx 1')
    error('Odor pairings off')
    
elseif ~strcmp(Q_task{1}.trgt{3}.label,'Trgt 1 - Ctx 2')
    error('Odor pairings off')
    
elseif ~strcmp(Q_task{1}.trgt{4}.label,'Trgt 2 - Ctx 2')
    error('Odor pairings off')
    
end

for iC = 1:length(Q_task)
    
    ctx_all = cat(1,Q_task{iC}.ctx{1}.FR,Q_task{iC}.ctx{2}.FR);
    ctxPre_all = cat(1,Q_task{iC}.ctxPre{1}.FR,Q_task{iC}.ctxPre{2}.FR);
    delay_all = cat(1,Q_task{iC}.delay{1}.FR,Q_task{iC}.delay{2}.FR);
    sizeCtxAll = length(ctx_all);
    sizeCtx1 = size(Q_task{iC}.ctx{1}.FR,1);
    
    trgt_all = cat(1,Q_task{iC}.trgt{1}.FR,Q_task{iC}.trgt{2}.FR,Q_task{iC}.trgt{3}.FR,Q_task{iC}.trgt{4}.FR);
    trgtPre_all = cat(1,Q_task{iC}.trgtPre{1}.FR,Q_task{iC}.trgtPre{2}.FR,Q_task{iC}.trgtPre{3}.FR,Q_task{iC}.trgtPre{4}.FR);
    sizeTrgtAll = length(trgt_all);
    halfTrgtAll = round(sizeTrgtAll/2);
    sizeTrgt1 = size(Q_task{iC}.trgt{1}.FR,1);
    sizeTrgt2 = size(Q_task{iC}.trgt{2}.FR,1);
    sizeTrgt3 = size(Q_task{iC}.trgt{3}.FR,1);
    
    for iS = 1:cfg.nShuf
        
        permCtx = randperm(sizeCtxAll);
        permTrgt = randperm(sizeTrgtAll);
        
        temp1 = ctx_all(permCtx(1:sizeCtx1));
        temp2 = ctx_all(permCtx(sizeCtx1+1:end));
        Q_shuff.ctx(iC,iS) = nanmean(temp1) - nanmean(temp2);
        
        temp1 = cat(1,ctx_all(permCtx(1:sizeCtx1)),ctxPre_all(permCtx(sizeCtx1+1:end)));
        temp2 = cat(1,ctx_all(permCtx(sizeCtx1+1:end)),ctxPre_all(permCtx(1:sizeCtx1)));
        Q_shuff.ctxPre(iC,iS) = nanmean(temp1) - nanmean(temp2);
        
        temp1 = delay_all(permCtx(1:sizeCtx1));
        temp2 = delay_all(permCtx(sizeCtx1+1:end));
        Q_shuff.delay(iC,iS) = nanmean(temp1) - nanmean(temp2);
        
        temp1 = trgt_all(permTrgt(1:sizeTrgt1));
        temp2 = trgt_all(permTrgt(sizeTrgt1+1:sizeTrgt1+sizeTrgt2));
        temp3 = trgt_all(permTrgt(sizeTrgt1+sizeTrgt2+1:sizeTrgt1+sizeTrgt2+sizeTrgt3));
        temp4 = trgt_all(permTrgt(sizeTrgt1+sizeTrgt2+sizeTrgt3+1:end));
        Q_shuff.trgt(iC,iS) = nanmean([temp1' temp3']) - nanmean([temp2' temp4']);
        Q_shuff.rew(iC,iS) = nanmean([temp1' temp4']) - nanmean([temp2' temp3']);
        
        temp1 = cat(1,trgt_all(permTrgt(1:halfTrgtAll)),trgtPre_all(permTrgt(halfTrgtAll+1:end)));
        temp2 = cat(1,trgt_all(permTrgt(halfTrgtAll+1:end)),trgtPre_all(permTrgt(1:halfTrgtAll)));
        Q_shuff.trgtPre(iC,iS) = nanmean(temp1) - nanmean(temp2);
        
        for iWin = 1:cfg.nWins
            
            trgtWin_all = cat(1,Q_task{iC}.trgtWin{iWin}{1}.FR,Q_task{iC}.trgtWin{iWin}{2}.FR,Q_task{iC}.trgtWin{iWin}{3}.FR,Q_task{iC}.trgtWin{iWin}{4}.FR);
            temp1 = trgtWin_all(permTrgt(1:sizeTrgt1));
            temp2 = trgtWin_all(permTrgt(sizeTrgt1+1:sizeTrgt1+sizeTrgt2));
            temp3 = trgtWin_all(permTrgt(sizeTrgt1+sizeTrgt2+1:sizeTrgt1+sizeTrgt2+sizeTrgt3));
            temp4 = trgtWin_all(permTrgt(sizeTrgt1+sizeTrgt2+sizeTrgt3+1:end));
            Q_shuff.ctxWin{iWin}(iC,iS) = nanmean([temp1' temp2']) - nanmean([temp3' temp4']);
            
        end
        
    end
    
end

end