function FR = predOutcomeWin(cfg_in,FR,Q_task)
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

if ~isfield(FR,'reg')
    
    FR.reg = [];
    FR.reg_z = [];
    
end

order{1} = [1 3]; order{2} = [2 4];
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
            
            pred_all{iTrl} = zeros(length(temp.pre),1);
            
            if length(temp.pre) > 3
                
                C = cvpartition(length(temp.pre), 'leaveout');
                
                for iFold = 1:C.NumTestSets
                    
                    % get idxs for training and testing set
                    tr_idx = C.training(iFold); te_idx = C.test(iFold);
                    
                    % train initial model
                    mdl = fitglm(temp.pre(tr_idx),temp.out(tr_idx),'Distribution','binomial');
                    %                             warning('off','last'); % rank deficiency
                    
                    % test it and add resulting predor to running total
                    pred = mdl.predict(temp.pre(te_idx));
                    pred = round(pred);
                    
                    if pred == temp.out(te_idx)
                        pred = 1;
                    else
                        pred = 0;
                    end
                    
                    pred_all{iTrl}(te_idx) = pred_all{iTrl}(te_idx) + pred;
                    
                end
                
            else
                pred_all{iTrl} = NaN(length(temp.pre),1);
            end
            
            %%
            
            for iS = 1:cfg.nShuf
                
                shuf = [];
                shuf.pre = temp.pre;
                s_idx = randperm(length(temp.out));
                shuf.out = temp.out(s_idx);
                
                predShuf_all{iS}{iTrl} = zeros(length(shuf.pre),1);
                
                if length(shuf.pre) > 3
                    
                    for iFold = 1:C.NumTestSets
                        
                        % get idxs for training and testing set
                        tr_idx = C.training(iFold); te_idx = C.test(iFold);
                        
                        %                         if z_idx(c_idx,iTrl)
                        
                        %                     disp(['Freq ' num2str(iTrl)])
                        % train initial model
                        mdl = fitglm(shuf.pre(tr_idx),shuf.out(tr_idx),'Distribution','binomial');
                        %                             warning('off','last'); % rank deficiency
                        
                        % test it and add resulting predShufor to running total
                        predShuf = mdl.predict(shuf.pre(te_idx));
                        predShuf = round(predShuf);
                        
                        if predShuf == shuf.out(te_idx)
                            predShuf = 1;
                        else
                            predShuf = 0;
                        end
                        
                        predShuf_all{iS}{iTrl}(te_idx) = predShuf_all{iS}{iTrl}(te_idx) + predShuf;
                        
                    end
                    
                else
                    predShuf_all{iS}{iTrl} = NaN(length(shuf.pre),1);
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
    
    FR.reg = [FR.reg prop_win];
    FR.reg_z = [FR.reg_z z_win];
    
end

end