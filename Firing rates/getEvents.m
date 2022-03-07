function task = getEvents(cfg_in,evt)
% Organizes task data
cfg_def = [];
cfg_def.behResp = [];

cfg = ProcessConfig(cfg_def,cfg_in);

%% initialize task data
task.odorEvt = ts;

for iO = 1:length(evt.cfg.ExpKeys.odors)
    
    idx = find(strcmp(evt.label,['odor ' num2str(iO)]) == 1);
    task.odorEvt.t{iO} = evt.t{idx};
    task.odorEvt.label{iO} = evt.cfg.ExpKeys.odorLabels{iO};
    
end

C1 = find(strcmp(task.odorEvt.label,'Context 1'));
C2 = find(strcmp(task.odorEvt.label,'Context 2'));
T1 = find(strcmp(task.odorEvt.label,'Target 1'));
T2 = find(strcmp(task.odorEvt.label,'Target 2'));

%% clean up duplicates after reward
TrgtCue = [T1 T2];

for iTrgt = 1:2
    
    for iT = length(task.odorEvt.t{TrgtCue(iTrgt)}):-1:2
        
        idx = find(task.odorEvt.t{C1} < task.odorEvt.t{TrgtCue(iTrgt)}(iT),1,'last');
        
        if ~isempty(idx)
            
            ts_diff(1) = task.odorEvt.t{TrgtCue(iTrgt)}(iT) - task.odorEvt.t{C1}(idx);
            
        else
            
            ts_diff(1) = NaN;
            
        end
        
        idx = find(task.odorEvt.t{C2} < task.odorEvt.t{TrgtCue(iTrgt)}(iT),1,'last');
        
        if ~isempty(idx)
            
            ts_diff(2) = task.odorEvt.t{TrgtCue(iTrgt)}(iT) - task.odorEvt.t{C2}(idx);
            
        else
            
            ts_diff(2) = NaN;
            
        end
        
        idx = find(task.odorEvt.t{TrgtCue(iTrgt)} < task.odorEvt.t{TrgtCue(iTrgt)}(iT),1,'last');
        
        if ~isempty(idx)
            
            ts_diff(3) = task.odorEvt.t{TrgtCue(iTrgt)}(iT) - task.odorEvt.t{TrgtCue(iTrgt)}(idx);
            
        else
            
            ts_diff(3) = NaN;
            
        end
        
        [~,min_idx] = min(ts_diff);
        
        if min_idx == 3
            
            task.odorEvt.t{TrgtCue(iTrgt)}(iT) = [];
            
        end
        
        ts_diff = [];
        
    end
    
end

%% separate trial types (context)
CtxCue = {'Context 1' 'Context 2'};

for iCue = 1:2
    
    Ctx = find(strcmp(task.odorEvt.label,CtxCue{iCue}));
    
    for iT = 1:length(task.odorEvt.t{Ctx})
        
        idx = find(task.odorEvt.t{T1} > task.odorEvt.t{Ctx}(iT),1,'first');
        ts_diff_T1 = task.odorEvt.t{T1}(idx) - task.odorEvt.t{Ctx}(iT);
        
        idx = find(task.odorEvt.t{T2} > task.odorEvt.t{Ctx}(iT),1,'first');
        ts_diff_T2 = task.odorEvt.t{T2}(idx) - task.odorEvt.t{Ctx}(iT);
        
        if isempty(ts_diff_T1)
            
            Trial.CtxCue{iCue}(iT) = 1;
            
        elseif isempty(ts_diff_T2)
            
            Trial.CtxCue{iCue}(iT) = -1;
            
        else
            
            Trial.CtxCue{iCue}(iT) = ts_diff_T1 - ts_diff_T2;
            
        end
        
    end
    
    Trial.CtxCue{iCue}(Trial.CtxCue{iCue} > 0) = 1;
    Trial.CtxCue{iCue}(Trial.CtxCue{iCue} < 0) = 0;
    Trial.Type{iCue,1} =  task.odorEvt.t{Ctx}(~logical(Trial.CtxCue{iCue}));
    Trial.Type{iCue,2} =  task.odorEvt.t{Ctx}(logical(Trial.CtxCue{iCue}));
    Trial.Type_Label{1,1} = 'Ctx 1 - Trgt 1';
    Trial.Type_Label{1,2} = 'Ctx 1 - Trgt 2';
    Trial.Type_Label{2,1} = 'Ctx 2 - Trgt 1';
    Trial.Type_Label{2,2} = 'Ctx 2 - Trgt 2';
    
end

%% separate trial types (target)
TrgtCue = {'Target 1', 'Target 2'};

for iCue = 1:2
    
    Trgt = find(strcmp(task.odorEvt.label,TrgtCue{iCue}));
    
    for iT = 1:length(task.odorEvt.t{Trgt})
        
        idx = find(task.odorEvt.t{Trgt}(iT) > task.odorEvt.t{C1},1,'last');
        ts_diff_C1 = task.odorEvt.t{Trgt}(iT) - task.odorEvt.t{C1}(idx);
        
        idx = find(task.odorEvt.t{Trgt}(iT) > task.odorEvt.t{C2},1,'last');
        ts_diff_C2 = task.odorEvt.t{Trgt}(iT) - task.odorEvt.t{C2}(idx);
        
        if isempty(ts_diff_C1)
            
            Trial.TrgtCue{iCue}(iT) = 1;
            
        elseif isempty(ts_diff_C2)
            
            Trial.TrgtCue{iCue}(iT) = -1;
            
        else
            
            Trial.TrgtCue{iCue}(iT) = ts_diff_C1 - ts_diff_C2;
            
        end
        
    end
    
    Trial.TrgtCue{iCue}(Trial.TrgtCue{iCue} > 0) = 1;
    Trial.TrgtCue{iCue}(Trial.TrgtCue{iCue} < 0) = 0;
    Trial.Trgt{iCue,1} =  task.odorEvt.t{Trgt}(~logical(Trial.TrgtCue{iCue}));
    Trial.Trgt{iCue,2} =  task.odorEvt.t{Trgt}(logical(Trial.TrgtCue{iCue}));
    Trial.Trgt_Label{1,1} = 'Trgt 1 - Ctx 1';
    Trial.Trgt_Label{1,2} = 'Trgt 1 - Ctx 2';
    Trial.Trgt_Label{2,1} = 'Trgt 2 - Ctx 1';
    Trial.Trgt_Label{2,2} = 'Trgt 2 - Ctx 2';
    
end

task.Trial_info = Trial;

%% pool reward events
task.rewDel = ts;
task.rewDel.t{1} = [];
task.rewDel.label{1} = 'reward delivery';

for iE = 1:length(evt.label)
    
    idx = strfind(evt.label{iE},'rew');
    
    if idx
        
        task.rewDel.t{1} = cat(1,task.rewDel.t{1}, evt.t{iE});
        
    end
end

task.rewDel.t{1} = sort(task.rewDel.t{1});

%% lick events
task.behEvt = ts;

for iE = 1:length(evt.label)
    
    idx = strfind(evt.label{iE},'lick');
    
    if idx
        
        task.behEvt.t{1} = evt.t{iE};
        task.behEvt.label{1} = evt.label{iE};
        
    end
end

%% rew receipt (first lick)
task.rewEvt = ts;
task.rewEvt.t{1} = [];
task.rewEvt.label{1} = 'reward';

for iT = 1:length(task.rewDel.t{1})
    
    idx = find(task.behEvt.t{1} > task.rewDel.t{1}(iT) & task.behEvt.t{1} < task.rewDel.t{1}(iT) + 1, 1, 'first');
    
    if ~isempty(idx)
        
        task.rewEvt.t{1} = cat(1,task.rewEvt.t{1}, task.behEvt.t{1}(idx));
        
    end
end

%% lick events after cue (first)
odorLick = [];
task.behCueEvt = ts;

for iO = 1:length(task.odorEvt.t)
    
    odorLick{iO} = zeros(1,length(task.odorEvt.t{iO}));
    task.behCueEvt.t{iO} = [];
    task.behCueEvt.label{iO} = task.odorEvt.label{iO};
    
    for iT = 1:length(task.odorEvt.t{iO})
        
        idx = find(task.behEvt.t{1} > task.odorEvt.t{iO}(iT) & task.behEvt.t{1} < task.odorEvt.t{iO}(iT) + 1, 1, 'first');
        
        if ~isempty(idx)
            
            task.behCueEvt.t{iO} = cat(1,task.behCueEvt.t{iO}, task.behEvt.t{1}(idx));
            odorLick{iO}(iT) = 1;
            
        end
    end
end

%% trial performance (find correct trials)
trialLick = [];
trialLick.correct = [];
trialLick.allTrgt = [];
trialLick.allCtx = [];

for iTrgt = 1:2
    
    for iCtx = 1:2
        
        trialLick.all{iTrgt,iCtx} = zeros(length(Trial.Trgt{iTrgt,iCtx}),1);
        
        for iT = 1:length(Trial.Trgt{iTrgt,iCtx})
            
            if cfg.behResp == 1
                
                idx = find(task.behEvt.t{1} > Trial.Trgt{iTrgt,iCtx}(iT) & task.behEvt.t{1} < Trial.Trgt{iTrgt,iCtx}(iT) + 2, 1, 'first');
                
            else
                
                idx = find(task.behEvt.t{1} > Trial.Trgt{iTrgt,iCtx}(iT) & task.behEvt.t{1} < Trial.Trgt{iTrgt,iCtx}(iT) + 1, 1, 'first');
                
            end
            
            if ~isempty(idx)
                
                trialLick.all{iTrgt,iCtx}(iT) = 1;
                
            end
        end
        
        trialLick.sum{iTrgt,iCtx} = sum(trialLick.all{iTrgt,iCtx});
        trialLick.prop{iTrgt,iCtx} = trialLick.sum{iTrgt,iCtx} / length(trialLick.all{iTrgt,iCtx});
        
        switch Trial.Trgt_Label{iTrgt,iCtx}
            
            case {'Trgt 1 - Ctx 1', 'Trgt 2 - Ctx 2'}
                
                corr_idx = logical(trialLick.all{iTrgt,iCtx});
                
            case {'Trgt 1 - Ctx 2', 'Trgt 2 - Ctx 1'}
                
                corr_idx = ~logical(trialLick.all{iTrgt,iCtx});
                
        end
        
        trialLick.allTrgt = cat(1,trialLick.allTrgt,Trial.Trgt{iTrgt,iCtx});
        trialLick.allCtx = cat(1,trialLick.allCtx,Trial.Type{iCtx,iTrgt});
        trialLick.correct = cat(1,trialLick.correct,corr_idx);
        
    end
    
end

%% trial performance (find good blocks)
[sort_Trgt, idx_Trgt] = sort(trialLick.allTrgt);
[sort_Ctx, idx_Ctx] = sort(trialLick.allCtx); %note idx_Trgt ~= idx_Ctx because of layout of Trial.Trgt_Label and Trial.Type_Label

sort_correct = trialLick.correct(idx_Trgt);

use_blocks = zeros(1,length(sort_correct));

num_blocks = floor(length(sort_correct) / 4);

idx_good = 0;

for iBlock = 1:4:num_blocks*4
    
    if idx_good > 1 %2 blocks in a row
        
        use_blocks(iBlock-8:iBlock-1) = 1;
        
    end
    
    if sum(sort_correct(iBlock:iBlock+3)) > 2
        
        idx_good = idx_good + 1;
        
    else
        
        idx_good = 0;
        
    end
end

if idx_good > 1
    
    use_blocks(iBlock:iBlock+3) = 1;
    
end

use_correct = sort_correct(logical(use_blocks));
use_Trgt = sort_Trgt(logical(use_blocks));
use_Ctx = sort_Ctx(logical(use_blocks));

% use_correct = sort_correct;
% use_Trgt = sort_Trgt;
% use_Ctx = sort_Ctx;


% correct trials within good blocks
corr_Trgt = use_Trgt(logical(use_correct));
corr_Ctx = use_Ctx(logical(use_correct));

task.goodEvt = task.odorEvt;

C1_keep = ismember(task.goodEvt.t{C1},corr_Ctx);
task.goodEvt.t{C1} = task.goodEvt.t{C1}(C1_keep);

C2_keep = ismember(task.goodEvt.t{C2},corr_Ctx);
task.goodEvt.t{C2} = task.goodEvt.t{C2}(C2_keep);

T1_keep = ismember(task.goodEvt.t{T1},corr_Trgt);
task.goodEvt.t{T1} = task.goodEvt.t{T1}(T1_keep);

T2_keep = ismember(task.goodEvt.t{T2},corr_Trgt);
task.goodEvt.t{T2} = task.goodEvt.t{T2}(T2_keep);

% error trials within good blocks
err_Trgt = use_Trgt(~logical(use_correct));
err_Ctx = use_Ctx(~logical(use_correct));

task.errEvt = task.odorEvt;

C1_keep = ismember(task.errEvt.t{C1},err_Ctx);
task.errEvt.t{C1} = task.errEvt.t{C1}(C1_keep);

C2_keep = ismember(task.errEvt.t{C2},err_Ctx);
task.errEvt.t{C2} = task.errEvt.t{C2}(C2_keep);

T1_keep = ismember(task.errEvt.t{T1},err_Trgt);
task.errEvt.t{T1} = task.errEvt.t{T1}(T1_keep);

T2_keep = ismember(task.errEvt.t{T2},err_Trgt);
task.errEvt.t{T2} = task.errEvt.t{T2}(T2_keep);

% all trials within good blocks
all_Trgt = use_Trgt;
all_Ctx = use_Ctx;

task.allEvt = task.odorEvt;

C1_keep = ismember(task.allEvt.t{C1},all_Ctx);
task.allEvt.t{C1} = task.allEvt.t{C1}(C1_keep);

C2_keep = ismember(task.allEvt.t{C2},all_Ctx);
task.allEvt.t{C2} = task.allEvt.t{C2}(C2_keep);

T1_keep = ismember(task.allEvt.t{T1},all_Trgt);
task.allEvt.t{T1} = task.allEvt.t{T1}(T1_keep);

T2_keep = ismember(task.allEvt.t{T2},all_Trgt);
task.allEvt.t{T2} = task.allEvt.t{T2}(T2_keep);

task.correct = use_correct;

%% separate all trial types for target cue epoch
task.trgtEvt = ts;
task.trgtEvt.t = reshape(Trial.Trgt,[1 4]);
task.trgtEvt.label = reshape(Trial.Trgt_Label,[1 4]);

% correct trials within good blocks
corr_Trgt = use_Trgt(logical(use_correct));

task.goodTrgt = task.trgtEvt;

for iT = 1:4
    
    T_keep = ismember(task.goodTrgt.t{iT},corr_Trgt);
    task.goodTrgt.t{iT} = task.goodTrgt.t{iT}(T_keep);
    
end

% error trials within good blocks
err_Trgt = use_Trgt(~logical(use_correct));

task.errTrgt = task.trgtEvt;

for iT = 1:4
    
    T_keep = ismember(task.errTrgt.t{iT},err_Trgt);
    task.errTrgt.t{iT} = task.errTrgt.t{iT}(T_keep);
    
end

% all trials within good blocks
all_Trgt = use_Trgt;

task.allTrgt = task.trgtEvt;

for iT = 1:4
    
    T_keep = ismember(task.allTrgt.t{iT},all_Trgt);
    task.allTrgt.t{iT} = task.allTrgt.t{iT}(T_keep);
    
end

%% store trials outside good blocks
use_correct = sort_correct(~logical(use_blocks));
use_Trgt = sort_Trgt(~logical(use_blocks)); % opposite of good
use_Ctx = sort_Ctx(~logical(use_blocks));

% correct trials in bad blocks
corr_Trgt = use_Trgt(logical(use_correct));
corr_Ctx = use_Ctx(logical(use_correct));

task.badEvt = task.odorEvt;

C1_keep = ismember(task.badEvt.t{C1},corr_Ctx);
task.badEvt.t{C1} = task.badEvt.t{C1}(C1_keep);

C2_keep = ismember(task.badEvt.t{C2},corr_Ctx);
task.badEvt.t{C2} = task.badEvt.t{C2}(C2_keep);

T1_keep = ismember(task.badEvt.t{T1},corr_Trgt);
task.badEvt.t{T1} = task.badEvt.t{T1}(T1_keep);

T2_keep = ismember(task.badEvt.t{T2},corr_Trgt);
task.badEvt.t{T2} = task.badEvt.t{T2}(T2_keep);

% error trials in bad blocks
err_Trgt = use_Trgt(~logical(use_correct));
err_Ctx = use_Ctx(~logical(use_correct));

task.errBadEvt = task.odorEvt;

C1_keep = ismember(task.errBadEvt.t{C1},err_Ctx);
task.errBadEvt.t{C1} = task.errBadEvt.t{C1}(C1_keep);

C2_keep = ismember(task.errBadEvt.t{C2},err_Ctx);
task.errBadEvt.t{C2} = task.errBadEvt.t{C2}(C2_keep);

T1_keep = ismember(task.errBadEvt.t{T1},err_Trgt);
task.errBadEvt.t{T1} = task.errBadEvt.t{T1}(T1_keep);

T2_keep = ismember(task.errBadEvt.t{T2},err_Trgt);
task.errBadEvt.t{T2} = task.errBadEvt.t{T2}(T2_keep);

% all trials in bad blocks
all_Trgt = use_Trgt;
all_Ctx = use_Ctx;

task.allBadEvt = task.odorEvt;

C1_keep = ismember(task.allBadEvt.t{C1},all_Ctx);
task.allBadEvt.t{C1} = task.allBadEvt.t{C1}(C1_keep);

C2_keep = ismember(task.allBadEvt.t{C2},all_Ctx);
task.allBadEvt.t{C2} = task.allBadEvt.t{C2}(C2_keep);

T1_keep = ismember(task.allBadEvt.t{T1},all_Trgt);
task.allBadEvt.t{T1} = task.allBadEvt.t{T1}(T1_keep);

T2_keep = ismember(task.allBadEvt.t{T2},all_Trgt);
task.allBadEvt.t{T2} = task.allBadEvt.t{T2}(T2_keep);

end