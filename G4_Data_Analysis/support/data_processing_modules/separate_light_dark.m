function [dark_sq_data, light_sq_data, dark_avgReps_data, light_avgReps_data] = ...
    separate_light_dark(ts_data, position_functions)
    ts_data_avg_reps = squeeze(mean(ts_data,3,'omitnan'));
    for cond = 1:size(ts_data,2)
        num_frames = max(position_functions{cond});
        darklight_cutoff = (num_frames-1)/2;
        dark_sq_data{cond} = ts_data(:, cond, :, 2:darklight_cutoff+1, :);
        light_sq_data{cond} = ts_data(:, cond, :, darklight_cutoff+2:num_frames, :);
        dark_avgReps_data{cond} = squeeze(ts_data_avg_reps(:, cond, 2:darklight_cutoff+1, :));
        light_avgReps_data{cond} = squeeze(ts_data_avg_reps(:, cond, darklight_cutoff+2:num_frames, :));

    end

end