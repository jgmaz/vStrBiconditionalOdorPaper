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
                if size(Trl.odor.Spk{iC}{1}{1},1) > 1 & size(Trl.odor.Spk{iC}{1}{2},1) > 1 & size(Trl.odor.Spk{iC}{2}{2},1) > 1 & size(Trl.odor.Spk{iC}{2}{1},1) > 1
                    
                    FR.label{end+1} = Trl.odor.label{iC};
                    
                    % correct
                    FR.trialNum(cellNum,1,1) = size(Trl.odor.Spk{iC}{1}{1},1);
                    FR.trialNum(cellNum,1,2) = size(Trl.odor.Spk{iC}{1}{2},1);
                    FR.trialNum(cellNum,2,1) = size(Trl.odor.Spk{iC}{2}{2},1);
                    FR.trialNum(cellNum,2,2) = size(Trl.odor.Spk{iC}{2}{1},1);
                    
                    FR.firingRates(cellNum,1,1,:,1:FR.trialNum(cellNum,1,1)) = Trl.odor.Spk{iC}{1}{1}';
                    FR.firingRates(cellNum,1,2,:,1:FR.trialNum(cellNum,1,2)) = Trl.odor.Spk{iC}{1}{2}';
                    FR.firingRates(cellNum,2,1,:,1:FR.trialNum(cellNum,2,1)) = Trl.odor.Spk{iC}{2}{2}';
                    FR.firingRates(cellNum,2,2,:,1:FR.trialNum(cellNum,2,2)) = Trl.odor.Spk{iC}{2}{1}';
                    
                    if ~isempty(Trl.odor.Spk_mean{iC}{1}{2})
                        FR.firingRatesAverage(cellNum,1,1,:) = Trl.odor.Spk_mean{iC}{1}{1};
                    end
                    if ~isempty(Trl.odor.Spk_mean{iC}{1}{2})
                        FR.firingRatesAverage(cellNum,1,2,:) = Trl.odor.Spk_mean{iC}{1}{2};
                    end
                    if ~isempty(Trl.odor.Spk_mean{iC}{1}{2})
                        FR.firingRatesAverage(cellNum,2,1,:) = Trl.odor.Spk_mean{iC}{2}{2};
                    end
                    if ~isempty(Trl.odor.Spk_mean{iC}{1}{2})
                        FR.firingRatesAverage(cellNum,2,2,:) = Trl.odor.Spk_mean{iC}{2}{1};
                    end
                    
                    % error
                    FR.trialNumErr(cellNum,1,1) = size(Trl.odorErr.Spk{iC}{1}{1},1);
                    FR.trialNumErr(cellNum,1,2) = size(Trl.odorErr.Spk{iC}{1}{2},1);
                    FR.trialNumErr(cellNum,2,1) = size(Trl.odorErr.Spk{iC}{2}{2},1);
                    FR.trialNumErr(cellNum,2,2) = size(Trl.odorErr.Spk{iC}{2}{1},1);
                    
                    if ~isempty(Trl.odorErr.Spk{iC}{1}{1})
                        FR.firingRatesErr(cellNum,1,1,:,1:FR.trialNumErr(cellNum,1,1)) = Trl.odorErr.Spk{iC}{1}{1}';
                    end
                    if ~isempty(Trl.odorErr.Spk{iC}{1}{2})
                        FR.firingRatesErr(cellNum,1,2,:,1:FR.trialNumErr(cellNum,1,2)) = Trl.odorErr.Spk{iC}{1}{2}';
                    end
                    if ~isempty(Trl.odorErr.Spk{iC}{2}{2})
                        FR.firingRatesErr(cellNum,2,1,:,1:FR.trialNumErr(cellNum,2,1)) = Trl.odorErr.Spk{iC}{2}{2}';
                    end
                    if ~isempty(Trl.odorErr.Spk{iC}{2}{1})
                        FR.firingRatesErr(cellNum,2,2,:,1:FR.trialNumErr(cellNum,2,2)) = Trl.odorErr.Spk{iC}{2}{1}';
                    end
                    
                    if ~isempty(Trl.odorErr.Spk{iC}{1}{1})
                        FR.firingRatesAverageErr(cellNum,1,1,:) = Trl.odorErr.Spk_mean{iC}{1}{1};
                    end
                    
                    if ~isempty(Trl.odorErr.Spk{iC}{1}{2})
                        FR.firingRatesAverageErr(cellNum,1,2,:) = Trl.odorErr.Spk_mean{iC}{1}{2};
                    end
                    
                    if ~isempty(Trl.odorErr.Spk{iC}{2}{2})
                        FR.firingRatesAverageErr(cellNum,2,1,:) = Trl.odorErr.Spk_mean{iC}{2}{2};
                    end
                    
                    if ~isempty(Trl.odorErr.Spk{iC}{2}{1})
                        FR.firingRatesAverageErr(cellNum,2,2,:) = Trl.odorErr.Spk_mean{iC}{2}{1};
                    end
                    
                    if ~isempty(Trl.odorAll.Spk_mean{iC}{1}{1})
                        FR.firingRatesAverageAll(cellNum,1,1,:) = Trl.odorAll.Spk_mean{iC}{1}{1};
                    end
                    if ~isempty(Trl.odorAll.Spk_mean{iC}{1}{2})
                        FR.firingRatesAverageAll(cellNum,1,2,:) = Trl.odorAll.Spk_mean{iC}{1}{2};
                    end
                    if ~isempty(Trl.odorAll.Spk_mean{iC}{1}{2})
                        FR.firingRatesAverageAll(cellNum,2,1,:) = Trl.odorAll.Spk_mean{iC}{2}{2};
                    end
                    if ~isempty(Trl.odorAll.Spk_mean{iC}{2}{1})
                        FR.firingRatesAverageAll(cellNum,2,2,:) = Trl.odorAll.Spk_mean{iC}{2}{1};
                    end
                    
                    if ~isempty(Trl.odorBad.Spk{iC}{1}{1})
                        FR.firingRatesAverageBad(cellNum,1,1,:) = Trl.odorBad.Spk_mean{iC}{1}{1};
                    end
                    if ~isempty(Trl.odorBad.Spk{iC}{1}{2})
                        FR.firingRatesAverageBad(cellNum,1,2,:) = Trl.odorBad.Spk_mean{iC}{1}{2};
                    end
                    if ~isempty(Trl.odorBad.Spk{iC}{2}{2})
                        FR.firingRatesAverageBad(cellNum,2,1,:) = Trl.odorBad.Spk_mean{iC}{2}{2};
                    end
                    if ~isempty(Trl.odorBad.Spk{iC}{2}{1})
                        FR.firingRatesAverageBad(cellNum,2,2,:) = Trl.odorBad.Spk_mean{iC}{2}{1};
                    end
                    
                    if ~isempty(Trl.odorErrBad.Spk{iC}{1}{1})
                        FR.firingRatesAverageErrBad(cellNum,1,1,:) = Trl.odorErrBad.Spk_mean{iC}{1}{1};
                    end
                    
                    if ~isempty(Trl.odorErrBad.Spk{iC}{1}{2})
                        FR.firingRatesAverageErrBad(cellNum,1,2,:) = Trl.odorErrBad.Spk_mean{iC}{1}{2};
                    end
                    
                    if ~isempty(Trl.odorErrBad.Spk{iC}{2}{2})
                        FR.firingRatesAverageErrBad(cellNum,2,1,:) = Trl.odorErrBad.Spk_mean{iC}{2}{2};
                    end
                    
                    if ~isempty(Trl.odorErrBad.Spk{iC}{2}{1})
                        FR.firingRatesAverageErrBad(cellNum,2,2,:) = Trl.odorErrBad.Spk_mean{iC}{2}{1};
                    end
                    
                    cellNum = cellNum + 1;
                end
            end
        end
        
    end
    
end

end