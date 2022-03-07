function Q = binEvents(cfg_in,S,task)
% bins spikes and events into format for GLM
cfg_def.dt = 0.05;
cfg_def.goodTrials = 1;
cfg_def.smooth = 'none'; % gauss or none
cfg_def.gausswin_size = .1; % in seconds
cfg_def.gausswin_sd = 0.02; % in seconds

cfg = ProcessConfig(cfg_def,cfg_in);

%%
cfg_Q = [];
cfg_Q.dt = cfg.dt;
cfg_Q.smooth = cfg.smooth;
cfg_Q.gausswin_size = cfg.gausswin_size;
cfg_Q.gausswin_sd = cfg.gausswin_sd;

Q.S = MakeQfromS(cfg_Q,S);
Q.S.label = S.label;

cfg_Q = [];
cfg_Q.dt = cfg.dt;
cfg_Q.tvec_edges = Q.S.tvec(1:end) - cfg_Q.dt/2;
cfg_Q.tvec_edges(end+1) = cfg_Q.tvec_edges(end) + cfg_Q.dt;

if cfg.goodTrials
    
    Q.odor = MakeQfromS(cfg_Q,task.goodEvt);
    Q.odor.label = task.goodEvt.label;
    Q.odorErr = MakeQfromS(cfg_Q,task.errEvt);
    Q.odorErr.label = task.errEvt.label;
    Q.odorAll = MakeQfromS(cfg_Q,task.allEvt);
    Q.odorAll.label = task.allEvt.label;
    
    Q.trgt = MakeQfromS(cfg_Q,task.goodTrgt);
    Q.trgt.label = task.goodTrgt.label;
    Q.trgtErr = MakeQfromS(cfg_Q,task.errTrgt);
    Q.trgtErr.label = task.errTrgt.label;
    Q.trgtAll = MakeQfromS(cfg_Q,task.allTrgt);
    Q.trgtAll.label = task.allTrgt.label;
    disp('using good trials')
    
    Q.odorBad = MakeQfromS(cfg_Q,task.badEvt);
    Q.odorBad.label = task.badEvt.label;
    Q.odorErrBad = MakeQfromS(cfg_Q,task.errBadEvt);
    Q.odorErrBad.label = task.errBadEvt.label;
    Q.odorAllBad = MakeQfromS(cfg_Q,task.allBadEvt);
    Q.odorAllBad.label = task.allBadEvt.label;
    
else
    
    Q.odor = MakeQfromS(cfg_Q,task.odorEvt);
    Q.odor.label = task.odorEvt.label;
    Q.trgt = MakeQfromS(cfg_Q,task.trgtEvt);
    Q.trgt.label = task.trgtEvt.label;
    disp('using all trials')
    
end

Q.rew = MakeQfromS(cfg_Q,task.rewEvt);
Q.rew.label = task.rewEvt.label;

Q.beh = MakeQfromS(cfg_Q,task.behEvt);
Q.beh.label = task.behEvt.label;

Q.behCue = MakeQfromS(cfg_Q,task.behCueEvt);
Q.behCue.label = task.behCueEvt.label;

Q.correct = task.correct;

end