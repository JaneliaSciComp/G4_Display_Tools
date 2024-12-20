function [dark_sq_data, light_sq_data, dark_avgReps_data, light_avgReps_data, ...
    dark_sq_neutral, light_sq_neutral, dark_avgReps_neutral, light_avgReps_neutral] = ...
    separate_light_dark(ts_data, neutral_ts_data, num_frames)
    ts_data_avg_reps = squeeze(mean(ts_data,3,'omitnan'));
    neutral_avgReps_data = squeeze(mean(neutral_ts_data,3,'omitnan'));
    for cond = 1:size(ts_data,2)
        
        darklight_cutoff = (num_frames(cond)-1)/2;
        dark_sq_data{cond} = ts_data(:, cond, :, 2:darklight_cutoff+1, :);
        light_sq_data{cond} = ts_data(:, cond, :, darklight_cutoff+2:num_frames(cond), :);
        dark_avgReps_data{cond} = squeeze(ts_data_avg_reps(:, cond, 2:darklight_cutoff+1, :));
        light_avgReps_data{cond} = squeeze(ts_data_avg_reps(:, cond, darklight_cutoff+2:num_frames(cond), :));

        dark_sq_neutral{cond} = neutral_ts_data(:, cond, :, 2:darklight_cutoff+1, :);
        light_sq_neutral{cond} = neutral_ts_data(:, cond, :, darklight_cutoff+2:num_frames(cond), :);
        dark_avgReps_neutral{cond} = squeeze(neutral_avgReps_data(:, cond, 2:darklight_cutoff+1, :));
        light_avgReps_neutral{cond} = squeeze(neutral_avgReps_data(:, cond, darklight_cutoff+2:num_frames(cond), :));


    end

end
