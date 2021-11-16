function [start_idx, stop_idx, start_times, stop_times] = get_start_stop_times(Log, command_string, manual_first_start)
    
start_idx = strcmpi(Log.Commands.Name,command_string);
start_times = Log.Commands.Time(start_idx);
stop_idx = strcmpi(Log.Commands.Name,'Stop-Display');
stop_times = Log.Commands.Time(stop_idx);
if manual_first_start==1
    start_times = [min(Log.ADC.Time(:,1)) start_times];
end

end