%This function determines at what time point of each trial the pattern
%actually started moving by detecting the first change in frame position
%after the onset of the trial.

function [frame_movement_start_times] = get_pattern_movement_times(start_times, Log)

    init_fidx = 1;
    frame_movement_start_times = NaN(size(start_times));
    while double(Log.Frames.Position(init_fidx + 1)) - double(Log.Frames.Position(init_fidx)) == 0
        init_fidx = init_fidx + 1;
    end
    frame_movement_start_times(1) = Log.Frames.Time(init_fidx);
    for idx = 2:length(start_times)
        start_time = start_times(idx);
        ftime = 1;
        while Log.Frames.Time(ftime) < start_time
            if ftime == length(Log.Frames.Time)
                break;
            else
                ftime = ftime + 1;
            end
        end
        if idx < length(start_times)
            movetime = ftime + 11; % In Log.Frames.Position, the first 9-11 frame numbers after the start time
        end                        % seem random and do not reflect the frame
                                   % actually being displayed - so skip them.
        if movetime < length(Log.Frames.Position)
            while double(Log.Frames.Position(movetime + 1)) - double(Log.Frames.Position(movetime)) == 0
                movetime = movetime + 1;
            end
            frame_movement_start_times(idx) = Log.Frames.Time(movetime);
        else
            disp("Frame movement time could not be detected because it appears to be later than any time recorded in the Position and Time structs (meaning the pattern likely didn't move)");
            frame_movement_start_times(idx) = NaN;
        end
    end
end
