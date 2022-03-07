function [evt, S] = LoadSession(cfg_in)
% Pulls out session data to be analyzed

cfg_def.uint = '64';
cfg_def.load_questionable_cells = 0;

cfg = ProcessConfig(cfg_def,cfg_in);

%% Load events
LoadExpKeys

cfg_evt = [];
cfg_evt.eventList = ExpKeys.eventList;
cfg_evt.eventLabel = ExpKeys.eventLabel;

evt = LoadEvents(cfg_evt);

cfg_spike = [];
cfg_spike.uint = cfg.uint;
cfg_spike.load_questionable_cells = cfg.load_questionable_cells;

S = LoadSpikes(cfg_spike);

end