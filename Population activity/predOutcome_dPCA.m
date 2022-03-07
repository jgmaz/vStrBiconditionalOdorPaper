function reg = predOutcome_dPCA(cfg_in,FR,W,PCids)
% proj FRs onto dPCs
cfg_def = [];

cfg = ProcessConfig(cfg_def,cfg_in);

%% trial-by-trial loop

x_pred = cfg.xPred;
nPreds = length(x_pred);
resp_idx = nPreds + 1;

wLen = .5 / cfg.dt;
wSlide = wLen / 2;

nWins = length(1:wSlide:cfg.nBins-wSlide);

reg.prop = NaN(1,nWins);
reg.z = NaN(1,nWins);

count = 1;

for iW = 1:wSlide:cfg.nBins-wLen
    
    pred_all = [];
    predShuf_all = [];
    
    TrlMtrxTrgt1 = [];
    TrlMtrxTrgt2 = [];
    
    for iT = 1:cfg.nTrl
        Xfull = FR.firingRates(:,:,:,:,iT);
        X = Xfull(:,:)';
        Xcen = bsxfun(@minus, X, nanmean(X));
        XfullCen = bsxfun(@minus, Xfull, mean(X)');
        N = size(X, 1);
        dataDim = size(Xfull);
        nanfind = isnan(Xcen);
        Xcen(nanfind) = 0;
        Z = Xcen * W;
        Z1 = Xcen(1:4:end,:) * W;
        Z2 = Xcen(2:4:end,:) * W;
        Z3 = Xcen(3:4:end,:) * W;
        Z4 = Xcen(4:4:end,:) * W;
        
        % notes Z1 and Z3 are same context
        % Z1 and Z2 are rewarded
        % Z1 and Z4 are same target
        
        TrlMtrxTrgt1(end+1,1:nPreds) = mean(Z1(iW:iW+wLen-1,x_pred));
        TrlMtrxTrgt1(end,resp_idx) = 1;
        TrlMtrxTrgt1(end+1,1:nPreds) = mean(Z4(iW:iW+wLen-1,x_pred));
        TrlMtrxTrgt1(end,resp_idx) = 0;
        
        TrlMtrxTrgt2(end+1,1:nPreds) = mean(Z2(iW:iW+wLen-1,x_pred));
        TrlMtrxTrgt2(end,resp_idx) = 1;
        TrlMtrxTrgt2(end+1,1:nPreds) = mean(Z3(iW:iW+wLen-1,x_pred));
        TrlMtrxTrgt2(end,resp_idx) = 0;
        
    end
    
    %% binomial
    for iTrl = 1:2
        
        pred_all{iTrl} = zeros(size(TrlMtrxTrgt1,1),1);
        C = cvpartition(size(TrlMtrxTrgt1,1),'LeaveOut');
        
        switch iTrl
            case 1
                input_data = TrlMtrxTrgt1;
            case 2
                input_data = TrlMtrxTrgt2;
        end
        for iC = 1:size(TrlMtrxTrgt1,1)
            train_set = input_data(C.training(iC),:);
            test_set = input_data(C.test(iC),:);
            
            % train initial model
            mdl = fitglm(train_set(:,1:nPreds),train_set(:,resp_idx),'Distribution','binomial');
            
            % test it and add resulting predor to running total
            pred = mdl.predict(test_set(:,1:nPreds));
            pred = round(pred);
            if pred == test_set(:,resp_idx)
                pred = 1;
            else
                pred = 0;
            end
            pred_all{iTrl}(C.test(iC)) = pred_all{iTrl}(C.test(iC)) + pred;
            
        end
        
        for iS = 1:cfg.nShuf
            disp(iS)
            s_idx = randperm(size(TrlMtrxTrgt1,1));
            shuf_out = input_data;
            shuf_out(:,resp_idx) = input_data(s_idx,resp_idx);
            
            predShuf_all{iS}{iTrl} = zeros(size(TrlMtrxTrgt1,1),1);
            
            for iC = 1:size(TrlMtrxTrgt1,1)
                
                train_set = shuf_out(C.training(iC),:);
                test_set = shuf_out(C.test(iC),:);
                
                % train initial model
                mdl = fitglm(train_set(:,1:nPreds),train_set(:,resp_idx),'Distribution','binomial');
                
                % test it and add resulting predShufor to running total
                predShuf = mdl.predict(test_set(:,1:nPreds));
                predShuf = round(predShuf);
                
                if predShuf == test_set(:,resp_idx)
                    predShuf = 1;
                else
                    predShuf = 0;
                end
                
                predShuf_all{iS}{iTrl}(C.test(iC)) = predShuf_all{iS}{iTrl}(C.test(iC)) + predShuf;
                
            end
            
        end
        
    end
    
    %%
    temp.all = cat(1,pred_all{1},pred_all{2});
    reg.prop(count) = sum(temp.all) / length(temp.all);
    
    
    for iS = 1:cfg.nShuf
        
        shuf_all = cat(1,predShuf_all{iS}{1},predShuf_all{iS}{2});
        shuf_prop(iS) = sum(shuf_all) / length(shuf_all);
        
    end
    
    shuf_mean = mean(shuf_prop); shuf_std = std(shuf_prop);
    reg.z(count) = (reg.prop(count) - shuf_mean) / shuf_std;
    
    count = count + 1;
    
end

end