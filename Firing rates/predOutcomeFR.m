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

if ~isfield(FR,'poiss')
    
    FR.poiss = [];
    FR.poiss_z = [];
    
end

order{1} = [1 3]; order{2} = [2 4];
nWins = length(cfg.trlInt(1):cfg.trlLen:cfg.trlInt(2)-cfg.trlLen);

for iC = 1:length(Q_task)
    
    mean_win = NaN(nWins,1);
    z_win = NaN(nWins,1);
    
    for iWin = 1:nWins
        
        pred_all = [];
        predShuf_all = [];
        
        for iTrl = 1:2
            
            temp = [];
            temp.pre = cat(1,Q_task{iC}.trgtWin{iWin}{order{iTrl}(1)}.FR,Q_task{iC}.trgtWin{iWin}{order{iTrl}(2)}.FR);
            temp.out = cat(1,Q_task{iC}.trgt{order{iTrl}(1)}.FR,Q_task{iC}.trgt{order{iTrl}(2)}.FR);
            
            pred_all{iTrl} = zeros(length(temp.pre),1);
            
            if length(temp.pre) > 3
                
                C = cvpartition(length(temp.pre), 'leaveout');
                
                for iFold = 1:C.NumTestSets
                    
                    % get idxs for training and testing set
                    tr_idx = C.training(iFold); te_idx = C.test(iFold);
                    
                    % train initial model
                    mdl = fitglm(temp.pre(tr_idx),temp.out(tr_idx),'Distribution','poisson');
                    %                             warning('off','last'); % rank deficiency
                    
                    % test it and add resulting predor to running total
                    pred = mdl.predict(temp.pre(te_idx));
                    pred = (pred - temp.out(te_idx)).^2;
                    
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
                        
                        % train initial model
                        mdl = fitglm(shuf.pre(tr_idx),shuf.out(tr_idx),'Distribution','poisson');
                        %                             warning('off','last'); % rank deficiency
                        
                        % test it and add resulting predShufor to running total
                        predShuf = mdl.predict(shuf.pre(te_idx));
                        predShuf = (predShuf - shuf.out(te_idx)).^2;
                        
                        predShuf_all{iS}{iTrl}(te_idx) = predShuf_all{iS}{iTrl}(te_idx) + predShuf;
                        
                    end
                    
                else
                    predShuf_all{iS}{iTrl} = NaN(length(shuf.pre),1);
                end
                
            end
            
        end % over folds
        
        %%
        temp.all = cat(1,pred_all{1},pred_all{2});
        mean_win(iWin,1) = nanmean(temp.all);
        
        
        for iS = 1:cfg.nShuf
            
            shuf_all = cat(1,predShuf_all{iS}{1},predShuf_all{iS}{2});
            shuf_data(iS) = nanmean(shuf_all);
            
        end
        
        shuf_mean = mean(shuf_data); shuf_std = std(shuf_data);
        z_win(iWin,1) = (mean_win(iWin,1) - shuf_mean) / shuf_std;       
        
    end
    
    FR.poiss = [FR.poiss mean_win];
    FR.poiss_z = [FR.poiss_z z_win];
    
end

end