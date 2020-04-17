function [modeID_order, patternID_order] = get_modeID_order(combined_command, Log, start_idx)

    if combined_command == 1
        
        combined_data = Log.Commands.Data(start_idx);
        for i = 1:length(combined_data)
            patterndata_order{i} = combined_data{i}(3);
            modedata_order{i} = combined_data{i}(1);
        end

        patternID_order = cell2mat(cellfun(@PD_fun, patterndata_order,'UniformOutput',false));
        %error-checking to add: check that patternID orders match condition orders

        %get order of control modes

        modeID_order = cell2mat(cellfun(@str2double, modedata_order,'UniformOutput',false));
        %error-checking to add: check that control mode matches conditions to plot
        
    else
    
        set_pattern_idx = strcmpi(Log.Commands.Name,'Set Pattern ID');
        patterndata_order = Log.Commands.Data(set_pattern_idx);
        patternID_order = cell2mat(cellfun(@PD_fun, patterndata_order,'UniformOutput',false));
        %error-checking to add: check that patternID orders match condition orders

        %get order of control modes
        set_mode_idx = strcmpi(Log.Commands.Name,'Set Control Mode');
        modedata_order = Log.Commands.Data(set_mode_idx);
        modeID_order = cell2mat(cellfun(@str2double, modedata_order,'UniformOutput',false));
    end

end