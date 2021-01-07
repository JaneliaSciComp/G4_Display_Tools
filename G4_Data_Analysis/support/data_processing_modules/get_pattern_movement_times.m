%This function determines at what time point of each trial the pattern
%actually started moving by detecting the first change in frame position
%after the onset of the trial.

function [frame_movement_start_times] = get_pattern_movement_times(start_times, Log)
 
    
    init_fidx = 1;
    frame_movement_start_times = NaN(length(start_times));

    while Log.Frames.Position(init_fidx + 1) - Log.Frames.Position(init_fidx) == 0
        init_fidx = init_fidx + 1;
    end

    frame_movement_start_times(1) = Log.Frames.Time(init_fidx);

    for idx = 2:length(start_times)
        start_time = start_times(idx);

        ftime = 1;
        
        while Log.Frames.Time(ftime) < start_time
            ftime = ftime + 1;
        end
        
        movetime = ftime;
            
        while Log.Frames.Position(movetime + 1) - Log.Frames.Position(movetime) == 0
            movetime = movetime + 1; 
        end
        
        frame_movement_start_times(idx) = Log.Frames.Time(movetime);

    end
        
end