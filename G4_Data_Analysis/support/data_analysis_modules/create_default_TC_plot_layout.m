%If custom plot layouts are not provided, create the default layout with
%this

function [TC_conds] = create_default_TC_plot_layout(conditionModes, TC_condsIn)


    TC_conds = []; %by default, don't plot any tuning curves
    
    
    
    if ~iscell(TC_conds)
        TC_conds = num2cell(TC_conds);
    end
end