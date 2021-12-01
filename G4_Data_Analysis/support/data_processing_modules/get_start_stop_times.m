function [start_idx, stop_idx, start_times, stop_times] = get_start_stop_times(Log, command_string, manual_first_start)
    
start_idx = strcmpi(Log.Commands.Name,command_string);
start_times = Log.Commands.Time(start_idx);
%stop_idx = strcmpi(Log.Commands.Name,'Stop-Display');
stop_idx = strcmpi(Log.Commands.Name, command_string);
first1idx = find(stop_idx==1);
stop_idx(first1idx(1)) = 0;
stop_times = Log.Commands.Time(stop_idx);
last_stop_idx = strcmpi(Log.Commands.Name, 'Stop-Display');
stop_times(end+1) = Log.Commands.Time(last_stop_idx);
if manual_first_start==1
    start_times = [min(Log.ADC.Time(:,1)) start_times];
end

end