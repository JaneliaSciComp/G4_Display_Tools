function [start_idx, stop_idx, start_times, stop_times] = get_start_stop_times(Log, command_string, manual_first_start)
    
    start_idx = strcmpi(Log.Commands.Name,command_string);
    start_times = Log.Commands.Time(start_idx);
    stop_idx = strcmpi(Log.Commands.Name,'Stop Log');
    stop_times = Log.Commands.Time(stop_idx);
    if manual_first_start==1
        start_times = [min(Log.ADC.Time(:,1)) start_times];
    end

%     timestamps = Log.ADC.Time(1,:);
%     for time = 1:length(timestamps)-1
%         diff(time) = timestamps(time + 1) - timestamps(time);
%     end
%     stop_idx = find(diff~=1000);
%     start_idx = stop_idx + ones(1, length(stop_idx));
%     start_idx = [1 start_idx];
%     stop_idx = [stop_idx length(timestamps)];
%     stop_times = timestamps(stop_idx);
%     start_times = timestamps(start_idx);
%     if manual_first_start==1
%         start_times = [min(Log.ADC.Time(:,1)) start_times];
%     end

end