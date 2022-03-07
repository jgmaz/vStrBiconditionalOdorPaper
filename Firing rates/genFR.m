%% cd to current session
directory = 'E:\vStr-eyeblink\Data\inAnalysis\';
cd(directory)
Mice = dir;
Sessions = [];
FR = [];
FR.cfg.dt = .05;
FR.cfg.trlInt = [-1 5];
FR.cfg.npTrl = [-1 1];
FR.cfg.minSpk = 200;
FR.cfg.nShuf = 20;
FR.cfg.trlLen = 1;
FR.cfg.delayT = 2;
FR.cfg.zscore = 2.58;
FR.cfg.use_cells = 0;
FR.cfg.smooth = 'none';
FR.cfg.nWins = length(FR.cfg.trlInt(1):FR.cfg.trlLen:FR.cfg.trlInt(2)-FR.cfg.trlLen);
FR.cfg.PETHdt = .01;

for iM = 3:length(Mice)
    
    cd([directory Mice(iM).name])
    temp_sessions = dir;
    Sessions = cat(1,Sessions,temp_sessions(3:end));
    
end

for iS = 1:length(Sessions)
    
    cd([directory Sessions(iS).name(1:4) '\' Sessions(iS).name])
    disp(Sessions(iS).name)
    
    %% Load session data
    cfg = [];
    cfg.uint = '64';
    cfg.load_questionable_cells = FR.cfg.use_cells;
    
    [evt, S] = LoadSession(cfg);
    
    %% set up task events
    cfg = [];
    
    task = getEvents(cfg,evt);
    
    %% bin spikes and events
    cfg = [];
    cfg.dt = FR.cfg.dt; %0.05; %.05 for glm, .001 for PCA to get better smoothing
    cfg.goodTrials = 1;
    cfg.smooth = FR.cfg.smooth; % gauss for PCA, none for GLM
    cfg.gausswin_size = .1; % in seconds
    cfg.gausswin_sd = 0.02; % in seconds
    
    Q = binEvents(cfg,S,task);
    
    %% get event-specific spikes
    cfg = [];
    cfg.dt = FR.cfg.dt;
    cfg.trlLen = FR.cfg.trlLen;
    cfg.trlInt = FR.cfg.trlInt;
    cfg.delayT = FR.cfg.delayT;
    cfg.ExpKeys = evt.cfg.ExpKeys;
    
    Q_task = getEventSpikes(cfg,Q);
    
    %% get shuffles
    cfg = [];
    cfg.dt = FR.cfg.dt;
    cfg.nShuf = FR.cfg.nShuf;
    cfg.nWins = FR.cfg.nWins;
    
    Q_shuff = shuffleEventSpikes(cfg,Q_task);
    
    %% get means and zscore
    cfg = [];
    cfg.dt = FR.cfg.dt;
    cfg.nWins = FR.cfg.nWins;
    
    FR = zScoreEventSpikes(cfg,FR,S.label,Q_task,Q_shuff);
    
    %% predict target cue value based on delay activity
    cfg = [];
    cfg.nShuf = FR.cfg.nShuf;
    cfg.trlLen = FR.cfg.trlLen;
    cfg.trlInt = FR.cfg.trlInt;
    
    FR = predOutcomeWin(cfg,FR,Q_task);
    FR = predOutcomeWinErr(cfg,FR,Q_task);
    FR = predOutcomeFR(cfg,FR,Q_task);
    FR = predOutcomeFRErr(cfg,FR,Q_task);
    
    %% get high res convolved data for plotting
    cfg = [];
    cfg.dt = FR.cfg.PETHdt;
    cfg.goodTrials = 1;
    cfg.smooth = 'gauss';
    cfg.gausswin_size = .1; % in seconds
    cfg.gausswin_sd = 0.02; % in seconds
    
    Q_conv = binEvents(cfg,S,task);
    
    %% get PETHs for plotting
    cfg = [];
    cfg.dt = FR.cfg.PETHdt;
    cfg.trlInt = FR.cfg.trlInt;
    cfg.trlLen = FR.cfg.trlLen;
    cfg.delayT = FR.cfg.delayT;
    cfg.ExpKeys = evt.cfg.ExpKeys;
    
    FR = getPETH(cfg,FR,Q_conv);
    
end

clearvars -except FR

%% sort spikes, identify insufficient spikes, correlate across events
cfg = [];
cfg.zscore = FR.cfg.zscore;
cfg.minSpk = FR.cfg.minSpk; % note: nSpk is for all data in lever and np (including pre), but only for PC chambers for pc
cfg.nShuf = FR.cfg.nShuf;
cfg.nWins = FR.cfg.nWins;
cfg.Mice = Mice;
cfg.win = 'on';
cfg.gate = 'off';

FR = sortCells(cfg,FR);

%% plot FR
cfg = [];
cfg.zscore = 2.5;
cfg.save = 'off';
cfg.trlInt = FR.cfg.trlInt;
cfg.trlLen = FR.cfg.trlLen;
cfg.dt = FR.cfg.PETHdt;
cfg.Mice = Mice;
cfg.win = 'on';
cfg.indMice = 'off';

plotFR(cfg,FR);

%% plot example cells
cfg = [];
cfg.save = 'off';
cfg.smooth = 'gauss'; % gauss or none
cfg.gausswin_size = 1; % in seconds
cfg.gausswin_sd = 0.05; % in seconds
cfg.dt = 0.05;
cfg.trlInt = [-.5 5];
cfg.examples = {'M040-2020-04-19-TT07_1.t','M040-2020-04-24-TT08_1.t',...
    'M040-2020-04-28-TT03_1.t','M111-2020-06-26-TT02_1.t',...
    'M142-2020-09-30-TT15_3.t','M142-2020-10-02-TT05_2.t',};

plotExampleCells(cfg);