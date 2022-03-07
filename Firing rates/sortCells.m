function FR = sortCells(cfg_in,FR)
% Organizes task data
cfg_def = [];

cfg = ProcessConfig(cfg_def,cfg_in);

%% sufficient spikes
FR.suffSpk = FR.nSpk;

FR.suffSpk.ctx(FR.suffSpk.ctx < cfg.minSpk) = 0;
FR.suffSpk.ctx(FR.suffSpk.ctx >= cfg.minSpk) = 1;
FR.suffSpk.ctx(isnan(FR.suffSpk.ctx)) = 0;
FR.suffSpk.ctx = logical(FR.suffSpk.ctx);

%% sort by zscore
fields = fieldnames(FR.diff.z);
FR.fields = fields;

for iF = 1:length(fields)
    
    use_cells = FR.suffSpk.ctx;
    
    temp_sort = FR.diff.z.(fields{iF}); temp_sort(~use_cells) = NaN;
    [~, idx] = sort(temp_sort,'descend','MissingPlacement','last');
    nan_idx = find(isnan(temp_sort),1,'first');
    
    if ~isempty(nan_idx)
        
        end_idx = find(idx == nan_idx);
        FR.sort.(fields{iF}) = idx(1:end_idx-1);
        
    else
        
        FR.sort.(fields{iF}) = idx;
        
    end
    
    [~, idx] = sort(abs(temp_sort),'descend','MissingPlacement','last');
    nan_idx = find(isnan(temp_sort),1,'first');
    
    if ~isempty(nan_idx)
        
        end_idx = find(idx == nan_idx);
        FR.sortABS.(fields{iF}) = idx(1:end_idx-1);
        
    else
        
        FR.sortABS.(fields{iF}) = idx;
        
    end
    
    for iM = 3:length(cfg.Mice)
        m_idx = contains(FR.label,cfg.Mice(iM).name);
        
        use_cells = FR.suffSpk.ctx(m_idx);
        
        FR.mice.(cfg.Mice(iM).name).diffZ.(fields{iF}) = FR.diff.z.(fields{iF})(m_idx);
        FR.mice.(cfg.Mice(iM).name).diffZ.(fields{iF})(~use_cells) = [];
        temp_sort = FR.diff.z.(fields{iF})(m_idx); temp_sort(~use_cells) = NaN;
        [~, idx] = sort(temp_sort,'descend','MissingPlacement','last');
        nan_idx = find(isnan(temp_sort),1,'first');
        
        if ~isempty(nan_idx)
            
            end_idx = find(idx == nan_idx);
            FR.mice.(cfg.Mice(iM).name).sort.(fields{iF}) = idx(1:end_idx-1);
            
        else
            
            FR.mice.(cfg.Mice(iM).name).sort.(fields{iF}) = idx;
            
        end
        
        [~, idx] = sort(abs(temp_sort),'descend','MissingPlacement','last');
        nan_idx = find(isnan(temp_sort),1,'first');
        
        if ~isempty(nan_idx)
            
            end_idx = find(idx == nan_idx);
            FR.mice.(cfg.Mice(iM).name).sortABS.(fields{iF}) = idx(1:end_idx-1);
            
        else
            
            FR.mice.(cfg.Mice(iM).name).sortABS.(fields{iF}) = idx;
            
        end
        
    end
end

%% correlate across events

for iF = 1:length(fields)
    
    FR.corr.label{iF} = fields{iF};
    
    for iF2 = 1:length(fields)
        
        idx = intersect(FR.sort.(fields{iF}),FR.sort.(fields{iF2}));
        temp = corrcoef(FR.diff.mean.(fields{iF}),FR.diff.mean.(fields{iF2}),'rows','complete');
        FR.corr.r(iF,iF2) = temp(2);
        
        for iS = 1:size(FR.diff.shuff.(fields{iF}),2)
            
            temp = corrcoef(FR.diff.shuff.(fields{iF})(:,iS),FR.diff.shuff.(fields{iF2})(:,iS),'rows','complete');
            FR.corr.shuff(iF,iF2,iS) = temp(2);
            
        end
        
        FR.corr.z(iF,iF2) = (FR.corr.r(iF,iF2) - nanmean(FR.corr.shuff(iF,iF2,:))) / nanstd(FR.corr.shuff(iF,iF2,:));
        
    end
    
end

FR.corr.r(eye(length(fields)) == 1) = NaN;
FR.corr.z(eye(length(fields)) == 1) = NaN;

%% get proportions

FR.prop_label = FR.corr.label;

for iF = 1:length(fields)
    
    suffSpk = FR.suffSpk.ctx;
    
    exc_idx = ~suffSpk + isnan(FR.diff.z.(fields{iF}))';
    exc_idx(exc_idx > 0) = 1; exc_idx = logical(exc_idx);
    usable_cells = FR.diff.z.(fields{iF})(~exc_idx);
    nCells = length(usable_cells);
    nSig = length(find(abs(usable_cells) > cfg.zscore));
    FR.prop(iF) = nSig / nCells;
    FR.num.allSig(iF) = nSig;
    FR.num.totalCells(iF) = nCells;
    
    nSig = length(find(usable_cells < -cfg.zscore));
    FR.dec(iF) = nSig / nCells;
    FR.num.dec(iF) = nSig;
    nSig = length(find(usable_cells > cfg.zscore));
    FR.inc(iF) = nSig / nCells;
    FR.num.inc(iF) = nSig;
    
    for iM = 3:length(cfg.Mice)
        m_idx = contains(FR.label,cfg.Mice(iM).name);
        
        suffSpk = FR.suffSpk.ctx(m_idx);
        
        exc_idx = ~suffSpk + isnan(FR.diff.z.(fields{iF})(m_idx))';
        exc_idx(exc_idx > 0) = 1; exc_idx = logical(exc_idx);
        temp_cells =  FR.diff.z.(fields{iF})(m_idx);
        usable_cells = temp_cells(~exc_idx);
        nCells = length(usable_cells);
        nSig = length(find(abs(usable_cells) > cfg.zscore));
        FR.mice.(cfg.Mice(iM).name).prop(iF) = nSig / nCells;
        FR.mice.(cfg.Mice(iM).name).num.allSig(iF) = nSig;
        FR.mice.(cfg.Mice(iM).name).num.totalCells(iF) = nCells;
        
        nSig = length(find(usable_cells < -cfg.zscore));
        FR.mice.(cfg.Mice(iM).name).dec(iF) = nSig / nCells;
        FR.mice.(cfg.Mice(iM).name).num.dec(iF) = nSig;
        nSig = length(find(usable_cells > cfg.zscore));
        FR.mice.(cfg.Mice(iM).name).inc(iF) = nSig / nCells;
        FR.mice.(cfg.Mice(iM).name).num.inc(iF) = nSig;
        
    end
    
end

%% proportions for WIN
if strcmp(cfg.win,'on')
    
    suffSpk = repmat(FR.suffSpk.ctx',cfg.nWins,1);
    
    exc_idx = ~suffSpk + isnan(FR.diffWin.z.ctxWin);
    exc_idx(exc_idx > 0) = 1; exc_idx = logical(exc_idx);
    
    excReg_idx = ~suffSpk + isnan(FR.reg_z);
    excReg_idx(excReg_idx > 0) = 1; excReg_idx = logical(excReg_idx);
    
    excPoiss_idx = ~suffSpk + isnan(FR.poiss_z);
    excPoiss_idx(excPoiss_idx > 0) = 1; excPoiss_idx = logical(excPoiss_idx);
    
    for iWin = 1:cfg.nWins
        
        usable_cells = FR.diffWin.z.ctxWin(iWin,~exc_idx(iWin,:));
        nCells = length(usable_cells);
        nSig = length(find(abs(usable_cells) > cfg.zscore));
        FR.win.diff.prop(iWin) = nSig / nCells;
        FR.win.diff.allSig(iWin) = nSig;
        FR.win.diff.totalCells(iWin) = nCells;
        
        usable_cells = FR.reg_z(iWin,~excReg_idx(iWin,:));
        nCells = length(usable_cells);
        reg_sig = find(usable_cells > cfg.zscore);
        nSig = length(reg_sig);
        FR.win.reg.prop(iWin) = nSig / nCells;
        FR.win.reg.allSig(iWin) = nSig;
        FR.win.reg.totalCells(iWin) = nCells;
        
        usable_cells = FR.poiss_z(iWin,~excPoiss_idx(iWin,:));
        nCells = length(usable_cells);
        poiss_sig = find(usable_cells > cfg.zscore);
        nSig = length(poiss_sig);
        FR.win.poiss.prop(iWin) = nSig / nCells;
        FR.win.poiss.allSig(iWin) = nSig;
        FR.win.poiss.totalCells(iWin) = nCells;
        
        usable_cells = FR.regErr_z(iWin,~excReg_idx(iWin,:));
        nCells = length(usable_cells);
        usable_cells = usable_cells(reg_sig);
        
        temp = find(usable_cells > cfg.zscore);
        if sum(temp) == 0
            nSig = 0;
        else
            nSig = length(temp);
        end
        FR.win.reg.propErrBeh(iWin) = nSig / nCells;
        temp = find(usable_cells < -cfg.zscore);
        if sum(temp) == 0
            nSig2 = 0;
        else
            nSig2 = length(temp);
        end
        FR.win.reg.propErrNeural(iWin) = nSig2 / nCells;
        nSig3 = length(reg_sig) - nSig - nSig2;
        FR.win.reg.propErrNone(iWin) = nSig3 / nCells;
        
        usable_cells = FR.poissErr_z(iWin,~excPoiss_idx(iWin,:));
        nCells = length(usable_cells);
        usable_cells = usable_cells(poiss_sig);
        
        temp = find(usable_cells > cfg.zscore);
        if sum(temp) == 0
            nSig = 0;
        else
            nSig = length(temp);
        end
        FR.win.poiss.propErrBeh(iWin) = nSig / nCells;
        temp = find(usable_cells < -cfg.zscore);
        if sum(temp) == 0
            nSig2 = 0;
        else
            nSig2 = length(temp);
        end
        FR.win.poiss.propErrNeural(iWin) = nSig2 / nCells;
        nSig3 = length(poiss_sig) - nSig - nSig2;
        FR.win.poiss.propErrNone(iWin) = nSig3 / nCells;
        
        temp = corrcoef(FR.diffWin.z.ctxWin(iWin,~exc_idx(iWin,:)),FR.reg_z(iWin,~exc_idx(iWin,:)),'rows','complete');
        FR.win.corrDiffxReg(iWin) = temp(2);
        
        temp = corrcoef(FR.diffWin.z.ctxWin(iWin,~exc_idx(iWin,:)),FR.poiss_z(iWin,~exc_idx(iWin,:)),'rows','complete');
        FR.win.corrDiffxPoiss(iWin) = temp(2);
        
        temp = corrcoef(FR.reg_z(iWin,~exc_idx(iWin,:)),FR.poiss_z(iWin,~exc_idx(iWin,:)),'rows','complete');
        FR.win.corrRegxPoiss(iWin) = temp(2);
        
    end
    
end
end