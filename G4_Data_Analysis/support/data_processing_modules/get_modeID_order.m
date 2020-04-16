function [modeID_order] = get_modeID_order(combined_data)
    for i = 1:length(combined_data)
        patterndata_order{i} = combined_data{i}(3);
        modedata_order{i} = combined_data{i}(1);
    end

    patternID_order = cell2mat(cellfun(@PD_fun, patterndata_order,'UniformOutput',false));
    %error-checking to add: check that patternID orders match condition orders
    
    %get order of control modes

    modeID_order = cell2mat(cellfun(@str2double, modedata_order,'UniformOutput',false));
    %error-checking to add: check that control mode matches conditions to plot

end