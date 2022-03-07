%% dPCA workflow
directory = 'E:\vStr-eyeblink\Output\Trl\Spring2021_allTrl\';
cd(directory)
Mice = dir;

PCA = [];
PCA.cfg.dt = .001;
PCA.cfg.twin = [-.5 5];
PCA.cfg.time = PCA.cfg.twin(1):PCA.cfg.dt:PCA.cfg.twin(2);
PCA.cfg.nBins = length(PCA.cfg.time);
PCA.cfg.ifSimultaneousRecording = false;
PCA.cfg.remProp = .1;
PCA.cfg.zscore = 2.58;
PCA.cfg.nShuf = 2;
PCA.cfg.nTrl = 30;
PCA.cfg.nErrTrl = 5;
PCA.cfg.dPCAwhich = 'correct'; % all or correct
PCA.cfg.ctxNum = 1;

for iM = 3:length(Mice)
    
    cd([directory Mice(iM).name])
    sessions = dir;
    
    %% get summary FR data for dPCA function
    cfg = [];
    
    for iS = 1:100
        
        FRshuff = getFRshuff(cfg,sessions);
        
        %% run dPCA
        cfg = [];
        cfg.time = PCA.cfg.time;
        cfg.ifSimultaneousRecording = PCA.cfg.ifSimultaneousRecording;
        cfg.plot = 0;
        cfg.dPCAwhich = PCA.cfg.dPCAwhich;
        
        [W{iM-2,iS}, V, PCids{iM-2,iS}] = rundPCA(cfg,FRshuff);
        
        %% project data onto dPCs
        cfg = [];
        cfg.all = 0;
        cfg.remProp = PCA.cfg.remProp;
        
        Proj{iM-2,iS} = projData(cfg,FRshuff,W{iM-2,iS},PCids{iM-2,iS});
        
    end
    
end

%% plot top ctx, value, trgt components and decoder output
cfg = [];
cfg.time = PCA.cfg.time;
cfg.dt = PCA.cfg.dt;
cfg.twin = PCA.cfg.twin;
cfg.zscore = PCA.cfg.zscore;
cfg.save = 'off';

plotdPCAshuff(cfg,Proj,reg,R2,PCids);
