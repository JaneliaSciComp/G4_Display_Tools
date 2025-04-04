function processed_file_name = G4_Process_Data_flyingdetector(exp_folder, trial_options, manual_first_start)
%FUNCTION G4_Process_Data_flyingdetector(exp_folder, trial_options, manual_first_start)
% 
% Inputs:
% exp_folder: path containing G4_TDMS_Logs file
% trial_options: 1x3 logical array [pre-trial, intertrial, post-trial]
% manual_first_start: (optional) %sets first trial start time to beginning of data log (used if first start_display command is unlogged)



%% user-defined parameters
%specify timeseries data channels
channel_order = {'LmR_chan', 'L_chan', 'R_chan', 'F_chan', 'Frame Position', 'LmR', 'LpR'}; %add faLmR below if desired (line 214)

%specify time ranges for parsing and data analysis
data_rate = 1000; % rate (in Hz) which all data will be aligned to
pre_dur = 1; %seconds before start of trial to include
post_dur = 1; %seconds after end of trial to include
da_start = 0.05; %seconds after start of trial to start data analysis
da_stop = 0.15; %seconds before end of trial to end data analysis
time_conv = 1000000; %converts seconds to microseconds (TDMS timestamps are in micros)
common_cond_dur = 0; %sets whether all condition durations are the same (1) or not (0), for error-checking
processed_file_name = 'G4_Processed_Data.mat';


%% configure data processing
%specify exp folder to analyse and plot
if nargin==0
    exp_folder = fullfile("C:\");
    new_dir = uigetdir('C:/','Select a folder containing a G4_TDMS_Logs file');
    if new_dir ~= 0
        exp_folder = new_dir;
    end
    trial_options = [1 1 1]; %[pre-trial, inter-trial, post-trial]
end

%load TDMS_logs
files = dir(exp_folder);
try
    TDMS_logs_name = files(contains({files.name},{'G4_TDMS_Logs'})).name;
catch
    error('cannot find G4_TDMS_Logs file in specified folder')
end
load(fullfile(exp_folder,TDMS_logs_name),'Log');

%get start times of all trials (including pre/inter/post-trials)
start_idx = strcmpi(Log.Commands.Name,'Start-Display');
start_times = Log.Commands.Time(start_idx);
stop_idx = strcmpi(Log.Commands.Name,'Stop-Display');
stop_times = Log.Commands.Time(stop_idx);
if exist('manual_first_start','var') && manual_first_start==1
    start_times = [min(Log.ADC.Time(:,1)) start_times];
end

%get order of pattern IDs (maybe use for error-checking?)
set_pattern_idx = strcmpi(Log.Commands.Name,'Set Pattern ID');
patterndata_order = Log.Commands.Data(set_pattern_idx);
patternID_order = cell2mat(cellfun(@PD_fun, patterndata_order,'UniformOutput',false));
%error-checking to add: check that patternID orders match condition orders

%get order of control modes
set_mode_idx = strcmpi(Log.Commands.Name,'Set Control Mode');
modedata_order = Log.Commands.Data(set_mode_idx);
modeID_order = cell2mat(cellfun(@str2double, modedata_order,'UniformOutput',false));
%error-checking to add: check that control mode matches conditions to plot

%load exp_order
load(fullfile(exp_folder,'exp_order.mat'),'exp_order');
exp_order = exp_order'; %change to [condition, repetition]
[num_conds, num_reps] = size(exp_order);

%get trial start and stop times based on input trial options
num_trials = numel(exp_order);
assert(length(start_times)==num_trials + trial_options(1) + trial_options(3) + ((num_trials-1)*trial_options(2)),...
    'unexpected number of trials detected - check that pre-trial, post-trial, and intertrial options are correct')
if trial_options(1) %if pre-trial was run
    trial_start_ind = 2; %exclude pre-trial
else
    trial_start_ind = 1;
end
if trial_options(3) %if post-trial was run
    trial_end_ind = length(start_times)-1; %exclude post-trial
else
    trial_end_ind = length(start_times);
    start_times = [start_times stop_times(end)]; %if no post-trial, add last 'stop-display' to mark end of last trial
end
if trial_options(2) %if intertrials were run
    %get start times/modes of trials
    trial_start_times = start_times(trial_start_ind:2:trial_end_ind);
    trial_stop_times = start_times(trial_start_ind+1:2:trial_end_ind+1);
    trial_modes = modeID_order(trial_start_ind:2:trial_end_ind);
    
    %get start times/modes of intertrials
    intertrial_start_times = trial_stop_times(1:end-1);
    intertrial_stop_times = trial_start_times(2:end);
    intertrial_modes = modeID_order(trial_start_ind+1:2:trial_end_ind-1);
    intertrial_durs = double(intertrial_stop_times - intertrial_start_times)/time_conv;
    assert(all(intertrial_modes-intertrial_modes(1)==0),...
        'unexpected order of trials and intertrials - check that pre-trial, post-trial, and intertrial options are correct')
else
    %get start times/modes of trials
    trial_start_times = start_times(trial_start_ind:trial_end_ind);
    trial_stop_times = start_times(trial_start_ind+1:trial_end_ind+1);
    trial_modes = modeID_order(trial_start_ind:trial_end_ind);
end

%organize trial duration and control mode by condition/repetition
cond_dur = nan(num_conds, num_reps);
cond_modes = nan(num_conds, num_reps);
for trial=1:num_trials
    cond = exp_order(trial);
    rep = floor((trial-1)/num_conds)+1;
    cond_dur(cond,rep) = double(trial_stop_times(trial) - trial_start_times(trial))/time_conv;
    cond_modes(cond,rep) = trial_modes(trial);
end

%check condition durations and control modes for experiment errors
assert(all(all((cond_modes-repmat(cond_modes(:,1),[1 num_reps]))==0)),...
    'unexpected order of trial modes - check that pre-trial, post-trial, and intertrial options are correct')
if common_cond_dur == 1
    median_dur = repmat(median(cond_dur,2),[1 num_reps]); %find median duration for each condition
    dur_error = abs(cond_dur-median_dur)./median_dur; %find condition duration error away from median
    [bad_conds, bad_reps] = find(dur_error>0.01); %find bad trials (any trial where duration is off by >1%)
    if ~isempty(bad_conds) %display bad trials
        out = regexp(exp_folder,filesep,'start');
        exp_name = exp_folder(out(end)+1:end);
        fprintf([exp_name ' excluded trials' ])
        fprintf(' - cond %d, rep %d',[bad_conds bad_reps]')
        fprintf('\n')
    end
else
    bad_conds = [];
    bad_reps = [];
end

%check intertrial durations for experiment errors
if trial_options(2)
    median_dur = median(intertrial_durs,2); %find median duration for each intertrial
    dur_error = abs(intertrial_durs-median_dur)./median_dur; %find intertrial duration error away from median
    bad_intertrials = find(dur_error>0.01); %find bad intertrials (any trial where duration is off by >1%)
    if ~isempty(bad_intertrials) %display bad intertrials
        out = regexp(exp_folder,filesep,'start');
        exp_name = exp_folder(out(end)+1:end);
        fprintf([exp_name ' excluded intertrials' ])
        fprintf(' - trial %d',[bad_intertrials]')
        fprintf('\n')
    end
end
    
%get indices for all datatypes
Frame_ind = strcmpi(channel_order,'Frame Position');
LmR_ind = find(strcmpi(channel_order,'LmR'));
% faLmR_ind = find(strcmpi(channel_order,'faLmR'));
LpR_ind = find(strcmpi(channel_order,'LpR'));
% LmR_chan_idx = strcmpi(channel_order,'LmR_chan');
L_chan_idx = strcmpi(channel_order,'L_chan');
R_chan_idx = strcmpi(channel_order,'R_chan');
% F_chan_idx = strcmpi(channel_order,'F_chan');
num_ts_datatypes = length(channel_order);
num_ADC_chans = length(Log.ADC.Channels);


%% organize TDMS data by datatype/condition/repetition and align timeseries together
%pre-allocate space
longest_dur = max(max(cond_dur));
data_period = 1/data_rate;
ts_time = -pre_dur-data_period:data_period:longest_dur+post_dur+data_period; 
ts_data = nan([num_ts_datatypes num_conds num_reps length(ts_time)]);
if trial_options(2) %if intertrials were run
    inter_ts_time = 0:1/data_rate:max(intertrial_durs)+0.01; 
    inter_ts_data = nan([num_trials-1 length(inter_ts_time)]);
end 

%loop for every trial
for trial=1:num_trials
    cond = exp_order(trial);
    rep = floor((trial-1)/num_conds)+1;
    
    %only process data for good trials
    if ~(any(cond==bad_conds) && any(rep==bad_reps(bad_conds==cond)))
        %get analog input data for this trial, aligned to data rate
        for chan = 1:num_ADC_chans
            start_ind = find(Log.ADC.Time(chan,:)>=(trial_start_times(trial)-pre_dur*time_conv),1);
            stop_ind = find(Log.ADC.Time(chan,:)<=(trial_stop_times(trial)+post_dur*time_conv),1,'last');
            if isempty(stop_ind)
                stop_ind = length(Log.ADC.Time(chan,:));
            end
            unaligned_time = double(Log.ADC.Time(chan,start_ind:stop_ind) - trial_start_times(trial))/time_conv;
            ts_data(chan,cond,rep,:) = align_timeseries(ts_time, unaligned_time, Log.ADC.Volts(chan,start_ind:stop_ind), 'leave nan', 'mean');
        end

        %get frame position data for this trial, aligned to data rate
        start_ind = find(Log.Frames.Time(1,:)>=(trial_start_times(trial)-pre_dur*time_conv),1);
        stop_ind = find(Log.Frames.Time(1,:)<=(trial_stop_times(trial)+post_dur*time_conv),1,'last');
        if isempty(stop_ind)
            stop_ind = length(Log.Frames.Time(1,:));
        end
        unaligned_time = double(Log.Frames.Time(1,start_ind:stop_ind)-trial_start_times(trial))/time_conv;
        ts_data(Frame_ind,cond,rep,:) = align_timeseries(ts_time, unaligned_time, Log.Frames.Position(1,start_ind:stop_ind)+1, 'propagate', 'median');

        %create dataset for intertrial histogram (if applicable)
        if trial_options(2)==1 && trial<num_trials && ~(any(trial==bad_intertrials))
            %get frame position data, upsampled to match ADC timestamps
            start_ind = find(Log.Frames.Time(1,:)>=intertrial_start_times(trial),1);
            stop_ind = find(Log.Frames.Time(1,:)<=intertrial_stop_times(trial),1,'last');
            unaligned_time = double(Log.Frames.Time(1,start_ind:stop_ind)-intertrial_start_times(trial))/time_conv;
            inter_ts_data(trial,:) = align_timeseries(inter_ts_time, unaligned_time, Log.Frames.Position(1,start_ind:stop_ind)+1, 'propagate', 'median');
        end
    end
end


%% process data into meaningful datasets
%calculate LmR (Left - Right) and LpR (Left + Right)
ts_data(LmR_ind,:,:,:) = ts_data(L_chan_idx,:,:,:) - ts_data(R_chan_idx,:,:,:); % + = right turns, - = left turns
ts_data(LpR_ind,:,:,:) = ts_data(L_chan_idx,:,:,:) + ts_data(R_chan_idx,:,:,:); % + = increased amplitude, - = decreased

%small field Experiment0002 - RK %sweeps and looms
%%flip data for all conditions starting on the right side 
% ts_data(:,:,:,:,2) = nan; %duplicate ts_data along new dimension
% ts_data(faLmR_ind,:,:,:,:,1) = ts_data(LmR_ind,:,:,:,:,1); %1st set of values = LmR
% ts_data(faLmR_ind,1:2:end,:,:,2) = -ts_data(faLmR_ind,2:2:end,:,:,1); % left side of panel
% ts_data(faLmR_ind,2:2:end,:,:,2) = -ts_data(faLmR_ind,1:2:end,:,:,1);% from right side of panel
% ts_data = nanmean(ts_data,5); %average together the 2 sets of values (only for faLmR, everything else stays the same)

%average ts_data over number of reps
timeseries_avg_over_reps = squeeze(nanmean(ts_data, 3));

%average LmR data over number of reps
LmR_avg_over_reps = squeeze(nanmean(ts_data(LmR_ind,:,:,:),3));

%average LpR data over number of reps
LpR_avg_over_reps = squeeze(nanmean(ts_data(LpR_ind,:,:,:),3));

%average ts_data over all trials
timeseries_avg_all_trials = squeeze(nanmean(timeseries_avg_over_reps,2));

%average LmR data over all trials
LmR_avg_all_trials = squeeze(nanmean(LmR_avg_over_reps,1));

%average LpR data over all trials
LpR_avg_all_trials = squeeze(nanmean(LpR_avg_over_reps,1));

%duplicate ts_data and exclude all datapoints outside data analysis window (da_start:da_stop)
da_data = ts_data;
da_start_ind = find(ts_time>=da_start,1);
da_data(:,:,:,1:da_start_ind) = nan; %omit data before trial start
for cond = 1:num_conds
    da_stop_ind = find(ts_time<=(cond_dur(cond,1)-da_stop),1,'last');
    assert(~isempty(da_stop_ind),'data analysis window extends past trial end')
    da_data(:,cond,:,da_stop_ind:end) = nan; %omit data after trial end
end

%calculate values for tuning curves
tc_data = nanmean(da_data,4);

%calculate histograms of/by pattern position
hist_datatypes = {'Frame Position', 'LmR', 'LpR'};
num_hist_datatypes = length(hist_datatypes); 
max_pos = max(max(max(da_data(Frame_ind,:,:,:),[],4),[],3),[],2);
hist_data = nan([num_hist_datatypes num_conds num_reps max_pos]);
p = permute(1:max_pos,[1 3 4 2]); %create array of all possible pattern position values along 4th dimension
        
%get histogram of pattern position
tmpdata = permute(da_data(Frame_ind,:,:,:),[2 3 4 1]);
p_idx = tmpdata==p;
hist_data(1,:,:,:) = nansum(p_idx,3); 

%get mean turning, forward, and sideslip for each pattern position
tmpdata = repmat(da_data([LmR_ind, LpR_ind],:,:,:),[1 1 1 1 max_pos]);
p_idx = repmat(permute(p_idx,[5 1 2 3 4]),[2 1 1 1 1]);
tmpdata(~p_idx) = nan;
hist_data(2:3,:,:,:) = nanmean(tmpdata,4); %LmR and LpR by pattern position

%get histogram of intertrial pattern position
if trial_options(2) %if intertrials were run
    max_pos = max(max(inter_ts_data,[],2));
    p = permute(1:max_pos,[3 1 2]);
    p_idx = inter_ts_data==p;
    inter_hist_data = permute(nansum(p_idx,2),[1 3 2]); 
else
    inter_hist_data = [];
end


%% save data
channelNames.timeseries = channel_order; %cell array of channel names for timeseries data
channelNames.histograms = hist_datatypes; %cell array of channel names for histograms
histograms_CL = hist_data; %[datatype, condition, repetition, pattern-position]
interhistogram = inter_hist_data; %[repetition, pattern-position]
timestamps = ts_time; %[1 timestamp]
timeseries = ts_data; %[datatype, condition, repition, datapoint]
summaries = tc_data; %[datatype, condition, repition]
conditionModes = cond_modes(:,1); %[condition]

save(fullfile(exp_folder,processed_file_name),'channelNames', 'histograms_CL', ...
    'interhistogram', 'timestamps', 'timeseries', 'summaries', 'conditionModes', ...
    'timeseries_avg_over_reps', 'LmR_avg_over_reps', 'LpR_avg_over_reps', ...
    'timeseries_avg_all_trials', 'LmR_avg_all_trials', 'LpR_avg_all_trials');

