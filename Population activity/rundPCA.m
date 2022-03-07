function [W, V, PCids] = rundPCA(cfg_in,FR)
% function from Kobak et al. (2016)
% exact replica of their function.

cfg_def = [];
cfg_def.combinedParams = {{1, [1 3]}, {2, [2 3]}, {3}, {[1 2], [1 2 3]}};
cfg_def.margNames = {'Stimulus', 'Decision', 'Condition-independent', 'S/D Interaction'};
cfg_def.margColours = [23 100 171; 187 20 25; 150 150 150; 114 97 171]/256;
cfg_def.timeEvents = [0 3];
cfg_def.plot = 1;
cfg_def.dPCAwhich = 'correct';

cfg = ProcessConfig(cfg_def,cfg_in);

%% Step 4: dPCA with regularization

% This function takes some minutes to run. It will save the computations
% in a .mat file with a given name. Once computed, you can simply load
% lambdas out of this file:
%   load('tmp_optimalLambdas.mat', 'optimalLambda')

% Please note that this now includes noise covariance matrix Cnoise which
% tends to provide substantial regularization by itself (even with lambda set
% to zero).

switch cfg.dPCAwhich
    case {'correct'}
        firingRates = FR.firingRates;
        firingRatesAverage = FR.firingRatesAverage;
        trialNum = FR.trialNum;
    case {'all'}
        firingRates = FR.firingRatesAll;
        firingRatesAverage = FR.firingRatesAverageAll;
        trialNum = FR.trialNumAll;
end

optimalLambda = dpca_optimizeLambda(firingRatesAverage, firingRates, trialNum, ...
    'combinedParams', cfg.combinedParams, ...
    'simultaneous', cfg.ifSimultaneousRecording, ...
    'numRep', 2, ...  % increase this number to ~10 for better accuracy
    'filename', 'tmp_optimalLambdas.mat');

Cnoise = dpca_getNoiseCovariance(firingRatesAverage, ...
    firingRates, trialNum, 'simultaneous', cfg.ifSimultaneousRecording);

[W,V,whichMarg] = dpca(firingRatesAverage, 20, ...
    'combinedParams', cfg.combinedParams, ...
    'lambda', optimalLambda, ...
    'Cnoise', Cnoise);

explVar = dpca_explainedVariance(firingRatesAverage, W, V, ...
    'combinedParams', cfg.combinedParams);

close

if cfg.plot
    
   PCids.orthoPC = dpca_plot(FR.firingRatesAverage, W, V, @dpca_plot_default, ...
        'explainedVar', explVar, ...
        'marginalizationNames', cfg.margNames, ...
        'marginalizationColours', cfg.margColours, ...
        'whichMarg', whichMarg,                 ...
        'time', cfg.time,                        ...
        'timeEvents', cfg.timeEvents,               ...
        'timeMarginalization', 3,           ...
        'legendSubplot', 16);
    
end

PCids.explVar = explVar;
PCids.whichMarg = whichMarg;
idx = find(strcmp(cfg.margNames,'Stimulus'));
PCids.ctx = find(whichMarg == idx);
idx = find(strcmp(cfg.margNames,'Decision'));
PCids.out = find(whichMarg == idx);
idx = find(strcmp(cfg.margNames,'S/D Interaction'));
PCids.trgt = find(whichMarg == idx);
idx = find(strcmp(cfg.margNames,'Condition-independent'));
PCids.gen = find(whichMarg == idx);

end