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
    
    FR = getFR(cfg,sessions);
    
    %% run dPCA
    cfg = [];
    cfg.time = PCA.cfg.time;
    cfg.ifSimultaneousRecording = PCA.cfg.ifSimultaneousRecording;
    cfg.plot = 1;
    cfg.dPCAwhich = PCA.cfg.dPCAwhich;
    
    [W{iM-2}, V, PCids{iM-2}] = rundPCA(cfg,FR);
    
    %% project data onto dPCs
    cfg = [];
    cfg.all = 1;
    cfg.remProp = PCA.cfg.remProp;
    
    Proj{iM-2} = projData(cfg,FR,W{iM-2},PCids{iM-2});
    
    %% pred behavior
    cfg = [];
    cfg.dt = PCA.cfg.dt;
    cfg.nBins  = PCA.cfg.nBins;
    cfg.nShuf = PCA.cfg.nShuf;
    cfg.nTrl = PCA.cfg.nTrl;
    cfg.nErrTrl = PCA.cfg.nErrTrl;
    cfg.ctxNum = PCA.cfg.ctxNum;
    
    pred = [PCids{iM-2}.gen(1:3) PCids{iM-2}.ctx(1:2) PCids{iM-2}.trgt(1) PCids{iM-2}.out(1)];
    
    for iPred = 1:length(pred)
        
        cfg.xPred = pred(iPred);
        reg{iM-2}{iPred} = predOutcome_dPCA(cfg,FR,W{iM-2},PCids{iM-2});
        
    end
    
    %% decoder
    cfg = [];
    cfg.time = PCA.cfg.time;
    cfg.nBins  = PCA.cfg.nBins;
    cfg.dt = PCA.cfg.dt;
    cfg.twin = PCA.cfg.twin;
    cfg.remProp = PCA.cfg.remProp;
    cfg.nShuf = PCA.cfg.nShuf;
    cfg.nTrl = PCA.cfg.nTrl;
    cfg.nErrTrl = PCA.cfg.nErrTrl;
    cfg.ctxNum = PCA.cfg.ctxNum;
    
    R2{iM-2} = runDecoder(cfg,FR,W{iM-2},PCids{iM-2});
    R2{iM-2} = runDecoderRemove(cfg,FR,W{iM-2},PCids{iM-2},R2{iM-2});
    
end

%% plot top ctx, value, trgt components and decoder output
cfg = [];
cfg.time = PCA.cfg.time;
cfg.dt = PCA.cfg.dt;
cfg.twin = PCA.cfg.twin;
cfg.zscore = PCA.cfg.zscore;
cfg.save = 'off';

plotdPCA(cfg,Proj,reg,R2,PCids);
