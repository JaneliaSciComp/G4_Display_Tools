function [ts_labels, tc_labels, pos_labels, mp_labels] = generate_default_axis_labels(ts_labels,...
    tc_labels, pos_labels, mp_labels, ol_datatypes, tc_datatypes)

     %Generate default timeseries axis labels if not provided
    if isempty(ts_labels)
        for i = 1:length(ol_datatypes)
            ts_labels{i} = ["Time(sec)", string(ol_datatypes{i})];
        end
    end
    
    %Generate default tuning curve axis labels if not provided
    if isempty(tc_labels)
        for i = 1:length(tc_datatypes)
            tc_labels{i} = ["Frequency (Hz)", string(tc_datatypes{i})];
        end
    end
    
    if isempty(pos_labels)
        pos_labels = ["Degrees", "Position"];
    end
    
    if isempty(mp_labels)
        mp_labels = ["Degrees", "Motion-Dependent Response"; "Degrees", "Position-Dependent Response"];
    end


end