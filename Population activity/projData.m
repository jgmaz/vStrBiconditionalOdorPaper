function proj = projData(cfg_in,FR,W,PCids)
% proj FRs onto dPCs
cfg_def = [];

cfg = ProcessConfig(cfg_def,cfg_in);

%%

% project data
Xfull = FR.firingRatesAverage;
X = Xfull(:,:)';
Xcen = bsxfun(@minus, X, mean(X));
proj.all = Xcen * W;
proj.trial{1} = Xcen(1:4:end,:) * W;
proj.trial{2} = Xcen(2:4:end,:) * W;
proj.trial{3} = Xcen(3:4:end,:) * W;
proj.trial{4} = Xcen(4:4:end,:) * W;

if cfg.all
    
    [W_sort, W_idx] = sort(abs(W),1,'descend');
    nCells = size(W,1);
    nRem = floor(nCells*cfg.remProp);
    count_rem = 1;
    x_pred = PCids.ctx(1);
    
    %remove top contributors
    for iR = 0:nRem:nCells-nRem
        if count_rem < 7
            W_sub = W;
            if iR > 0
                W_sub(W_idx(1:iR,x_pred),:) = [];
            end
            
            Xfull = FR.firingRatesAverage;
            X = Xfull(:,:)';
            Xcen = bsxfun(@minus, X, mean(X));
            Xcen(:,W_idx(1:iR,x_pred)) = [];
            proj.red{count_rem}.all = Xcen * W_sub;
            proj.red{count_rem}.trial{1} = Xcen(1:4:end,:) * W_sub;
            proj.red{count_rem}.trial{2} = Xcen(2:4:end,:) * W_sub;
            proj.red{count_rem}.trial{3} = Xcen(3:4:end,:) * W_sub;
            proj.red{count_rem}.trial{4} = Xcen(4:4:end,:) * W_sub;
            
            count_rem = count_rem + 1;
            
        end
    end
    
    %proj error trials
    Xfull = FR.firingRatesAverageErr;
    X = Xfull(:,:)';
    Xcen = bsxfun(@minus, X, mean(X));
    proj.all = Xcen * W;
    proj.err{1} = Xcen(1:4:end,:) * W;
    proj.err{2} = Xcen(2:4:end,:) * W;
    proj.err{3} = Xcen(3:4:end,:) * W;
    proj.err{4} = Xcen(4:4:end,:) * W;
    
    % project data BAD blocks
    Xfull = FR.firingRatesAverageBad;
    X = Xfull(:,:)';
    Xcen = bsxfun(@minus, X, mean(X));
    proj.all = Xcen * W;
    proj.trialBad{1} = Xcen(1:4:end,:) * W;
    proj.trialBad{2} = Xcen(2:4:end,:) * W;
    proj.trialBad{3} = Xcen(3:4:end,:) * W;
    proj.trialBad{4} = Xcen(4:4:end,:) * W;
    
    %proj error trials BAD blocks
    Xfull = FR.firingRatesAverageErrBad;
    X = Xfull(:,:)';
    Xcen = bsxfun(@minus, X, mean(X));
    proj.all = Xcen * W;
    proj.errBad{1} = Xcen(1:4:end,:) * W;
    proj.errBad{2} = Xcen(2:4:end,:) * W;
    proj.errBad{3} = Xcen(3:4:end,:) * W;
    proj.errBad{4} = Xcen(4:4:end,:) * W;
    
end

end