function R2 = runDecoder(cfg_in,FR,W,PCids)
% proj FRs onto dPCs
cfg_def = [];

cfg = ProcessConfig(cfg_def,cfg_in);

%% trial-by-trial loop

out_idx(1) = find(cfg.time == 3.5);
out_idx(2) = find(cfg.time < 4,1,'last');

x_pred = PCids.ctx(cfg.ctxNum);
x_resp = PCids.out(1);
resp_range = out_idx(1):out_idx(2);
nPreds = length(x_pred);
resp_idx = nPreds + 1;

wLen = .5 / cfg.dt;
wSlide = wLen / 2;

for iD = 1:2
    count = 1;
    
    for iW = 1:wSlide:cfg.nBins-wLen
        disp(iW)
        
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
            
            switch iD
                case 1
                    
                    TrlMtrxTrgt1(end+1,1:nPreds) = mean(Z1(iW:iW+wLen-1,x_pred));
                    TrlMtrxTrgt1(end,resp_idx) = mean(Z1(resp_range,x_resp));
                    TrlMtrxTrgt1(end+1,1:nPreds) = mean(Z4(iW:iW+wLen-1,x_pred));
                    TrlMtrxTrgt1(end,resp_idx) = mean(Z4(resp_range,x_resp));
                    
                    TrlMtrxTrgt2(end+1,1:nPreds) = mean(Z2(iW:iW+wLen-1,x_pred));
                    TrlMtrxTrgt2(end,resp_idx) = mean(Z2(resp_range,x_resp));
                    TrlMtrxTrgt2(end+1,1:nPreds) = mean(Z3(iW:iW+wLen-1,x_pred));
                    TrlMtrxTrgt2(end,resp_idx) = mean(Z3(resp_range,x_resp));
                    
                case 2
                    TrlMtrxTrgt1(end+1,1:nPreds) = mean(Z1(iW:iW+wLen-1,x_pred));
                    TrlMtrxTrgt1(end,resp_idx) = mean(Z1(resp_range,x_resp));
                    TrlMtrxTrgt1(end+1,1:nPreds) = mean(Z3(iW:iW+wLen-1,x_pred));
                    TrlMtrxTrgt1(end,resp_idx) = mean(Z3(resp_range,x_resp));
                    
                    TrlMtrxTrgt2(end+1,1:nPreds) = mean(Z2(iW:iW+wLen-1,x_pred));
                    TrlMtrxTrgt2(end,resp_idx) = mean(Z2(resp_range,x_resp));
                    TrlMtrxTrgt2(end+1,1:nPreds) = mean(Z4(iW:iW+wLen-1,x_pred));
                    TrlMtrxTrgt2(end,resp_idx) = mean(Z4(resp_range,x_resp));
            end
            
        end
        
        %% decoder
        method = 'LSE'; %Moore is other option, however Moore is wrong
        
        y_pred = NaN(1,iT);
        y_diff = NaN(1,iT);
        C = cvpartition(iT,'LeaveOut');
        for iC = 1:iT
            train_set = TrlMtrxTrgt1(C.training(iC),:);
            test_set = TrlMtrxTrgt1(C.test(iC),:);
            switch method
                case {'Moore'}
                    x_inv = pinv(train_set(:,1:nPreds));
                    Wts = x_inv * (train_set(:,resp_idx));
                case{'LSE'}
                    Wts = (train_set(:,1:nPreds)'*train_set(:,resp_idx))/(train_set(:,1:nPreds)'*train_set(:,1:nPreds));
            end
            y_pred(C.test(iC)) = sum(Wts' .* (test_set(:,1:nPreds)));
            y_diff(C.test(iC)) = test_set(:,resp_idx) - y_pred(C.test(iC));
        end
        num = norm(y_diff,'fro');
        denom = norm(TrlMtrxTrgt1(:,resp_idx),'fro');
        R2_temp(1) = 1 - (num/denom);
        temp_diff = y_diff;
        
        %%
        y_pred = NaN(1,iT);
        y_diff = NaN(1,iT);
        C = cvpartition(iT,'LeaveOut');
        for iC = 1:iT
            train_set = TrlMtrxTrgt2(C.training(iC),:);
            test_set = TrlMtrxTrgt2(C.test(iC),:);
            
            switch method
                case {'Moore'}
                    x_inv = pinv(train_set(:,1:nPreds));
                    Wts = x_inv * (train_set(:,resp_idx));
                case{'LSE'}
                    Wts = (train_set(:,1:nPreds)'*train_set(:,resp_idx))/(train_set(:,1:nPreds)'*train_set(:,1:nPreds));
            end
            y_pred(C.test(iC)) = sum(Wts' .* (test_set(:,1:nPreds)));
            y_diff(C.test(iC)) = test_set(:,resp_idx) - y_pred(C.test(iC));
        end
        
        num = norm(y_diff,'fro');
        denom = norm(TrlMtrxTrgt2(:,resp_idx),'fro');
        R2_temp(2) = 1 - (num/denom);
        
        %combine together
        y_diff = [temp_diff y_diff];
        y_obs = cat(1,TrlMtrxTrgt1(:,resp_idx),TrlMtrxTrgt2(:,resp_idx));
        num = norm(y_diff,'fro');
        denom = norm(y_obs,'fro');
        R2_comb = 1 - (num/denom);
        
        %%
        for iS = 1:cfg.nShuf
            s_idx = randperm(length(TrlMtrxTrgt1));
            shuff_data = TrlMtrxTrgt1;
            shuff_data(:,1:nPreds) = TrlMtrxTrgt1(s_idx,1:nPreds);
            y_pred = NaN(1,iT);
            y_diff = NaN(1,iT);
            C = cvpartition(iT,'LeaveOut');
            for iC = 1:iT
                train_set = shuff_data(C.training(iC),:);
                test_set = shuff_data(C.test(iC),:);
                
                switch method
                    case {'Moore'}
                        x_inv = pinv(train_set(:,1:nPreds));
                        Wts = x_inv * (train_set(:,resp_idx));
                    case{'LSE'}
                        Wts = (train_set(:,1:nPreds)'*train_set(:,resp_idx))/(train_set(:,1:nPreds)'*train_set(:,1:nPreds));
                end
                y_pred(C.test(iC)) = sum(Wts' .* (test_set(:,1:nPreds)));
                y_diff(C.test(iC)) = test_set(:,resp_idx) - y_pred(C.test(iC));
            end
            num = norm(y_diff,'fro');
            denom = norm(shuff_data(:,resp_idx),'fro');
            R2_shuff(iS,1) = 1 - (num/denom);
            
            temp_diff(iS,:) = y_diff;
            shuff_data1(:,iS) = shuff_data(:,resp_idx);
        end
        
        %%
        for iS = 1:cfg.nShuf
            s_idx = randperm(length(TrlMtrxTrgt2));
            shuff_data = TrlMtrxTrgt2;
            shuff_data(:,1:nPreds) = TrlMtrxTrgt2(s_idx,1:nPreds);
            y_pred = NaN(1,iT);
            y_diff = NaN(1,iT);
            C = cvpartition(iT,'LeaveOut');
            for iC = 1:iT
                train_set = shuff_data(C.training(iC),:);
                test_set = shuff_data(C.test(iC),:);
                
                switch method
                    case {'Moore'}
                        x_inv = pinv(train_set(:,1:nPreds));
                        Wts = x_inv * (train_set(:,resp_idx));
                    case{'LSE'}
                        Wts = (train_set(:,1:nPreds)'*train_set(:,resp_idx))/(train_set(:,1:nPreds)'*train_set(:,1:nPreds));
                end
                y_pred(C.test(iC)) = sum(Wts' .* (test_set(:,1:nPreds)));
                y_diff(C.test(iC)) = test_set(:,resp_idx) - y_pred(C.test(iC));
            end
            num = norm(y_diff,'fro');
            denom = norm(shuff_data(:,resp_idx),'fro');
            R2_shuff(iS,2) = 1 - (num/denom);
            
            %combine together
            y_diff = [temp_diff(iS,:) y_diff];
            y_obs = cat(1,shuff_data1(:,iS),shuff_data(:,resp_idx));
            num = norm(y_diff,'fro');
            denom = norm(y_obs,'fro');
            R2_shuff_comb(iS) = 1 - (num/denom);
        end
        
        R2_shuff_mean{iD}(:,count) = mean(R2_shuff);
        R2_shuff_std{iD}(:,count) = std(R2_shuff);
        
        R2_shuff_comb_mean{iD}(:,count) = mean(R2_shuff_comb);
        R2_shuff_comb_std{iD}(:,count) = std(R2_shuff_comb);
        
        R2_all{iD}(:,count) = R2_temp;
        R2_all_comb{iD}(:,count) = R2_comb;
        
        count = count + 1;
        R2_temp = [];
        R2_shuff = [];
        
    end
end

R2.data.trial = R2_all;
R2.data.all = R2_all_comb;
R2.shuff.trial.mean = R2_shuff_mean;
R2.shuff.trial.std = R2_shuff_std;
R2.shuff.all.mean = R2_shuff_comb_mean;
R2.shuff.all.std = R2_shuff_comb_std;

end