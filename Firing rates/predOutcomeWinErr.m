function FR = predOutcomeErr(cfg_in,FR,Q_task)
% Organizes task data
cfg_def = [];

cfg = ProcessConfig(cfg_def,cfg_in);

%%
%checks

if ~strcmp(Q_task{1}.trgt{1}.label,'Trgt 1 - Ctx 1')
    predor('Odor pairings off')
    
elseif ~strcmp(Q_task{1}.trgt{2}.label,'Trgt 2 - Ctx 1')
    predor('Odor pairings off')
    
elseif ~strcmp(Q_task{1}.trgt{3}.label,'Trgt 1 - Ctx 2')
    predor('Odor pairings off')
    
elseif ~strcmp(Q_task{1}.trgt{4}.label,'Trgt 2 - Ctx 2')
    predor('Odor pairings off')
    
end

if ~isfield(FR,'regErr')
    
    FR.regErr = [];
    FR.regErr_z = [];
    
end

order{1} = [1 3]; order{2} = [4 2];
nWins = length(cfg.trlInt(1):cfg.trlLen:cfg.trlInt(2)-cfg.trlLen);

for iC = 1:length(Q_task)
    
    prop_win = NaN(nWins,1);
    z_win = NaN(nWins,1);
    
    for iWin = 1:nWins
        
        pred_all = [];
        predShuf_all = [];
        
        for iTrl = 1:2
            
            temp = [];
            temp.pre = cat(1,Q_task{iC}.trgtWin{iWin}{order{iTrl}(1)}.FR,Q_task{iC}.trgtWin{iWin}{order{iTrl}(2)}.FR);
            temp.out = zeros(length(temp.pre),1); temp.out(1:length(Q_task{iC}.trgtWin{iWin}{order{iTrl}(1)}.FR)) = 1;
            
            temp.preErr = []; temp.outErr = [];
            
            % error trials, so outcome is reversed (e.g. would expect 1 for
            % unrewarded trial
            if ~isempty(Q_task{iC}.trgtErrWin{iWin}{order{iTrl}(1)}.FR)
                
                temp.preErr = cat(1,temp.preErr,Q_task{iC}.trgtErrWin{iWin}{order{iTrl}(1)}.FR);
                temp.outErr = cat(1,temp.outErr,zeros(length(Q_task{iC}.trgtErrWin{iWin}{order{iTrl}(1)}.FR),1));
                
            end
            
            if ~isempty(Q_task{iC}.trgtErrWin{iWin}{order{iTrl}(2)}.FR)
                
                temp.preErr = cat(1,temp.preErr,Q_task{iC}.trgtErrWin{iWin}{order{iTrl}(2)}.FR);
                temp.outErr = cat(1,temp.outErr,ones(length(Q_task{iC}.trgtErrWin{iWin}{order{iTrl}(2)}.FR),1));
                
            end
            
            pred_all{iTrl} = zeros(length(temp.pre),1);
            
            if length(temp.pre) > 3
                if ~isempty(temp.preErr)
                    % train initial model
                    mdl = fitglm(temp.pre,temp.out,'Distribution','binomial');
                    
                    % test it and add resulting predor to running total
                    for iErr = 1:length(temp.preErr)
                        pred = mdl.predict(temp.preErr(iErr));
                        pred = round(pred);
                        if pred == temp.outErr(iErr)
                            pred = 1;
                        else
                            pred = 0;
                        end
                        
                        pred_all{iTrl}(iErr) = pred_all{iTrl}(iErr) + pred;
                        
                    end
                else
                    pred_all{iTrl} = NaN;
                end
                
            else
                pred_all{iTrl} = NaN;
            end
            
            %%
            
            for iS = 1:cfg.nShuf
                
                shuf = [];
                shuf.pre = temp.pre;
                s_idx = randperm(length(temp.out));
                shuf.out = temp.out(s_idx);
                
                predShuf_all{iS}{iTrl} = zeros(length(shuf.pre),1);
                
                if length(shuf.pre) > 3
                    if ~isempty(temp.preErr)
                        s2_idx = randperm(length(temp.outErr));
                        shuf.preErr = temp.preErr;
                        shuf.outErr = temp.outErr(s2_idx);
                        % train initial model
                        mdl = fitglm(shuf.pre,shuf.out,'Distribution','binomial');
                        
                        % test it and add resulting predShufor to running total
                        for iErr = 1:length(temp.preErr)
                            predShuf = mdl.predict(shuf.preErr(iErr));
                            predShuf = round(predShuf);
                            
                            if predShuf == shuf.outErr(iErr)
                                predShuf = 1;
                            else
                                predShuf = 0;
                            end
                            
                            predShuf_all{iS}{iTrl}(iErr) = predShuf_all{iS}{iTrl}(iErr) + predShuf;
                            
                        end
                        
                    else
                        predShuf_all{iS}{iTrl} = NaN;
                        
                    end
                    
                else
                    predShuf_all{iS}{iTrl} = NaN;
                end
                
            end
            
        end % over folds
        
        %%
        temp.all = cat(1,pred_all{1},pred_all{2});
        prop_win(iWin,1) = sum(temp.all) / length(temp.all);
        
        for iS = 1:cfg.nShuf
            
            shuf_all = cat(1,predShuf_all{iS}{1},predShuf_all{iS}{2});
            shuf_prop(iS) = sum(shuf_all) / length(shuf_all);
            
        end
        
        shuf_mean = mean(shuf_prop); shuf_std = std(shuf_prop);
        z_win(iWin,1) = (prop_win(iWin,1) - shuf_mean) / shuf_std;
        
    end
    
    FR.regErr = [FR.regErr prop_win];
    FR.regErr_z = [FR.regErr_z z_win];
    
end

end