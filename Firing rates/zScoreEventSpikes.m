function FR = zScoreEventSpikes(cfg_in,FR,labels,Q_task,Q_shuff)
% Organizes task data
cfg_def = [];

cfg = ProcessConfig(cfg_def,cfg_in);

%%
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

if ~isfield(FR,'diff')
    
    FR.label = [];
    
    FR.diff.mean.ctx = [];
    FR.diff.shuff.ctx = [];
    FR.diff.z.ctx = [];
    
    FR.diff.mean.ctxPre = [];
    FR.diff.shuff.ctxPre = [];
    FR.diff.z.ctxPre = [];
    
    FR.diff.mean.delay = [];
    FR.diff.shuff.delay = [];
    FR.diff.z.delay = [];
    
    FR.diff.mean.trgt = [];
    FR.diff.shuff.trgt = [];
    FR.diff.z.trgt = [];
    
    FR.diff.mean.trgtPre = [];
    FR.diff.shuff.trgtPre = [];
    FR.diff.z.trgtPre = [];
    
    FR.diff.mean.rew = [];
    FR.diff.shuff.rew = [];
    FR.diff.z.rew = [];
    
    FR.diffWin.mean.ctxWin = [];
    FR.diffWin.shuff.ctxWin = [];
    FR.diffWin.z.ctxWin = [];
    
end

FR.label = [FR.label labels];

temp = [];

for iC = 1:length(Q_task)
    
    temp.mean.ctx(iC) = nanmean(Q_task{iC}.ctx{1}.FR) - nanmean(Q_task{iC}.ctx{2}.FR);
    temp.z.ctx(iC) = (temp.mean.ctx(iC) - nanmean(Q_shuff.ctx(iC,:))) / nanstd(Q_shuff.ctx(iC,:));
    
    temp1 = cat(1,Q_task{iC}.ctx{1}.FR,Q_task{iC}.ctx{2}.FR);
    temp2 = cat(1,Q_task{iC}.ctxPre{1}.FR,Q_task{iC}.ctxPre{2}.FR);
    temp.mean.ctxPre(iC) = nanmean(temp1) - nanmean(temp2);
    temp.z.ctxPre(iC) = (temp.mean.ctxPre(iC) - nanmean(Q_shuff.ctxPre(iC,:))) / nanstd(Q_shuff.ctxPre(iC,:));
    
    temp.mean.delay(iC) = nanmean(Q_task{iC}.delay{1}.FR) - nanmean(Q_task{iC}.delay{2}.FR);
    temp.z.delay(iC) = (temp.mean.delay(iC) - nanmean(Q_shuff.delay(iC,:))) / nanstd(Q_shuff.delay(iC,:));
    
    temp1 = cat(1,Q_task{iC}.trgt{1}.FR,Q_task{iC}.trgt{3}.FR);
    temp2 = cat(1,Q_task{iC}.trgt{2}.FR,Q_task{iC}.trgt{4}.FR);
    temp.mean.trgt(iC)  = nanmean(temp1) - nanmean(temp2);
    temp.z.trgt(iC) = (temp.mean.trgt(iC) - nanmean(Q_shuff.trgt(iC,:))) / nanstd(Q_shuff.trgt(iC,:));
    
    temp1 = cat(1,Q_task{iC}.trgt{1}.FR,Q_task{iC}.trgt{2}.FR,Q_task{iC}.trgt{3}.FR,Q_task{iC}.trgt{4}.FR);
    temp2 = cat(1,Q_task{iC}.trgtPre{1}.FR,Q_task{iC}.trgtPre{2}.FR,Q_task{iC}.trgtPre{3}.FR,Q_task{iC}.trgtPre{4}.FR);
    temp.mean.trgtPre(iC) = nanmean(temp1) - nanmean(temp2);
    temp.z.trgtPre(iC) = (temp.mean.trgtPre(iC) - nanmean(Q_shuff.trgtPre(iC,:))) / nanstd(Q_shuff.trgtPre(iC,:));
    
    temp1 = cat(1,Q_task{iC}.trgt{1}.FR,Q_task{iC}.trgt{4}.FR);
    temp2 = cat(1,Q_task{iC}.trgt{2}.FR,Q_task{iC}.trgt{3}.FR);
    temp.mean.rew(iC)  = nanmean(temp1) - nanmean(temp2);
    temp.z.rew(iC) = (temp.mean.rew(iC) - nanmean(Q_shuff.rew(iC,:))) / nanstd(Q_shuff.rew(iC,:));
    
    for iWin = 1:cfg.nWins
        
        temp1 = cat(1,Q_task{iC}.trgtWin{iWin}{1}.FR,Q_task{iC}.trgtWin{iWin}{2}.FR);
        temp2 = cat(1,Q_task{iC}.trgtWin{iWin}{3}.FR,Q_task{iC}.trgtWin{iWin}{4}.FR);
        temp.mean.ctxWin(iWin,iC)  = nanmean(temp1) - nanmean(temp2);
        temp.z.ctxWin(iWin,iC) = (temp.mean.ctxWin(iWin,iC) - nanmean(Q_shuff.ctxWin{iWin}(iC,:))) / nanstd(Q_shuff.ctxWin{iWin}(iC,:));
        
    end
    
end

FR.diff.mean.ctx = [FR.diff.mean.ctx temp.mean.ctx];
FR.diff.shuff.ctx = cat(1,FR.diff.shuff.ctx,Q_shuff.ctx);
FR.diff.z.ctx = [FR.diff.z.ctx temp.z.ctx];

FR.diff.mean.ctxPre = [FR.diff.mean.ctxPre temp.mean.ctxPre];
FR.diff.shuff.ctxPre = cat(1,FR.diff.shuff.ctxPre,Q_shuff.ctxPre);
FR.diff.z.ctxPre = [FR.diff.z.ctxPre temp.z.ctxPre];

FR.diff.mean.delay = [FR.diff.mean.delay temp.mean.delay];
FR.diff.shuff.delay = cat(1,FR.diff.shuff.delay,Q_shuff.delay);
FR.diff.z.delay = [FR.diff.z.delay temp.z.delay];

FR.diff.mean.trgt = [FR.diff.mean.trgt temp.mean.trgt];
FR.diff.shuff.trgt = cat(1,FR.diff.shuff.trgt,Q_shuff.trgt);
FR.diff.z.trgt = [FR.diff.z.trgt temp.z.trgt];

FR.diff.mean.trgtPre = [FR.diff.mean.trgtPre temp.mean.trgtPre];
FR.diff.shuff.trgtPre = cat(1,FR.diff.shuff.trgtPre,Q_shuff.trgtPre);
FR.diff.z.trgtPre = [FR.diff.z.trgtPre temp.z.trgtPre];

FR.diff.mean.rew = [FR.diff.mean.rew temp.mean.rew];
FR.diff.shuff.rew = cat(1,FR.diff.shuff.rew,Q_shuff.rew);
FR.diff.z.rew = [FR.diff.z.rew temp.z.rew];

FR.diffWin.mean.ctxWin = [FR.diffWin.mean.ctxWin temp.mean.ctxWin];
FR.diffWin.shuff.ctxWin = cat(1,FR.diffWin.shuff.ctxWin,Q_shuff.ctxWin);
FR.diffWin.z.ctxWin = [FR.diffWin.z.ctxWin temp.z.ctxWin];

end