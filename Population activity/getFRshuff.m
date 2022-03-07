function FR = getFR(cfg_in,sessions)
% get FR data into format for Kobak's dPCA function
cfg_def = [];

cfg = ProcessConfig(cfg_def,cfg_in);

%%
FR = [];

for iS = 3:length(sessions)
    if strcmp(sessions(iS).name(1:3),'Trl')
        load(sessions(iS).name)
        disp(['loading ' sessions(iS).name])
        
        if isempty(FR)
            
            % get params in common var
            FR.label = [];
            FR.trialNum = [];
            FR.firingRates = [];
            FR.firingRatesAverage = [];
            cellNum = 1;
            
        end
        %%
        for iC = 1:length(Trl.odor.label)
            
            if ~isempty(Trl.odor.Spk_mean{iC})
                trialNum = cumsum([size(Trl.odor.Spk{iC}{1}{1},1) size(Trl.odor.Spk{iC}{1}{2},1) size(Trl.odor.Spk{iC}{2}{2},1) size(Trl.odor.Spk{iC}{2}{1},1)]);
                if size(Trl.odor.Spk{iC}{1}{1},1) > 1 & size(Trl.odor.Spk{iC}{1}{2},1) > 1 & size(Trl.odor.Spk{iC}{2}{2},1) > 1 & size(Trl.odor.Spk{iC}{2}{1},1) > 1
                    
                    FR.label{end+1} = Trl.odor.label{iC};
                    
                    all_trials = cat(1,Trl.odor.Spk{iC}{1}{1},Trl.odor.Spk{iC}{1}{2},Trl.odor.Spk{iC}{2}{2},Trl.odor.Spk{iC}{2}{1});
                    s_idx = randperm(size(all_trials,1));
                    shuf_trials{1} = all_trials(s_idx(1:trialNum(1)),:);
                    shuf_trials{2} = all_trials(s_idx(trialNum(1)+1:trialNum(2)),:);
                    shuf_trials{3} = all_trials(s_idx(trialNum(2)+1:trialNum(3)),:);
                    shuf_trials{4} = all_trials(s_idx(trialNum(3)+1:end),:);
                    
                    % correct
                    FR.trialNum(cellNum,1,1) = size(Trl.odor.Spk{iC}{1}{1},1);
                    FR.trialNum(cellNum,1,2) = size(Trl.odor.Spk{iC}{1}{2},1);
                    FR.trialNum(cellNum,2,1) = size(Trl.odor.Spk{iC}{2}{2},1);
                    FR.trialNum(cellNum,2,2) = size(Trl.odor.Spk{iC}{2}{1},1);
                    
                    FR.firingRates(cellNum,1,1,:,1:FR.trialNum(cellNum,1,1)) = shuf_trials{1}';
                    FR.firingRates(cellNum,1,2,:,1:FR.trialNum(cellNum,1,2)) = shuf_trials{2}';
                    FR.firingRates(cellNum,2,1,:,1:FR.trialNum(cellNum,2,1)) = shuf_trials{3}';
                    FR.firingRates(cellNum,2,2,:,1:FR.trialNum(cellNum,2,2)) = shuf_trials{4}';
                    
                    if ~isempty(nanmean(shuf_trials{1},1))
                        FR.firingRatesAverage(cellNum,1,1,:) = nanmean(shuf_trials{1},1);
                    end
                    if ~isempty(nanmean(shuf_trials{2},1))
                        FR.firingRatesAverage(cellNum,1,2,:) = nanmean(shuf_trials{2},1);
                    end
                    if ~isempty(nanmean(shuf_trials{3},1))
                        FR.firingRatesAverage(cellNum,2,1,:) = nanmean(shuf_trials{3},1);
                    end
                    if ~isempty(nanmean(shuf_trials{4},1))
                        FR.firingRatesAverage(cellNum,2,2,:) = nanmean(shuf_trials{4},1);
                    end
                    
                    cellNum = cellNum + 1;
                end
            end
        end
        
    end
    
end

end