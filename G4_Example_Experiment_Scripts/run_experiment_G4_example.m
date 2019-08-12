%% User-defined experiment conditions
experiment_name = 'Motion1'; %name of experiment folder (expected to be located in 'C:\matlabroot\G4\Experiments\')
num_reps = 3; %number of repetitions for each stimuli
randomize = 1; %randomize order of stimuli (1=yes, 0=no)
exp_mode = 1; %0=streaming, 1=position function, 2=constant rate, 3=position change, 4=Closed-loop (CL), 5=CL+bias, 6=CL+OL
inter_type = 1; %0=no intertrial, 1=static 1st frame of current pattern, 2=inter-trial closed loop with pattern 1
fly_name = 'testfly1';
trial_duration = 4; %duration (in seconds) of each trial
inter_trial_duration = 2; %duration (in seconds) of period in between trials
AOchannel = 1; %AO channel for analog output function (e.g. to trigger camera start with 5V pulse)


%% set up for experiment
%Load configuration and start G4 Host
userSettings;
experiment_folder = ['C:\matlabroot\G4\Experiments\' experiment_name];
load([experiment_folder '\currentExp.mat']);
num_conditions = currentExp.pattern.num_patterns;
if ~exist(fullfile(experiment_folder,'Log Files'),'dir')
    mkdir(experiment_folder,'Log Files');
end
connectHost;
Panel_com('change_root_directory', experiment_folder);

%check if log files already present for this experiment
assert(~exist([experiment_folder '\Log Files\*'],'file'),'unsorted log files present in save folder, remove before restarting experiment\n');
assert(~exist([experiment_folder '\Results\' fly_name],'dir'),'Results folder already exists with that fly name\n');

%create .mat file of experiment order
if randomize == 1;
    exp_order = NaN(num_reps,num_conditions);
    for rep_ind = 1:num_reps
        exp_order(rep_ind,:) = randperm(num_conditions);
    end
else
    exp_order = repmat(1:num_conditions,num_reps,1);
end

%finish setting up for experiment
exp_seconds = num_reps*num_conditions*(trial_duration+inter_trial_duration*(ceil(inter_type/10)));
fprintf(['Estimated experiment duration: ' num2str(exp_seconds/60) ' minutes\n']);
save([experiment_folder '\Log Files\exp_order.mat'],'exp_order')
Panel_com('set_active_ao_channels', dec2bin(bitset(0,AOchannel+1,1),4));


%% start experiment
Panel_com('start_log'); %starts logging data in .tdms files
pause(0.5);

%block trial structure
for r = 1:num_reps
    for c = 1:num_conditions
        %trial portion
        Panel_com('set_control_mode', exp_mode);
        Panel_com('set_pattern_id', exp_order(r,c));
        Panel_com('set_pattern_func_id', exp_order(r,c));
        Panel_com('set_ao_function_id',[AOchannel, exp_order(r,c)]);
        fprintf(['Rep ' num2str(r) ' of ' num2str(num_reps) ', cond ' num2str(c) ' of ' num2str(num_conditions) ': ' strjoin(currentExp.pattern.pattNames(exp_order(r,c))) '\n']);
        Panel_com('start_display', (trial_duration*10)-1); %duration expected in 100ms units
        pause(trial_duration)
        
        %intertrial portion
        if inter_type == 1
            Panel_com('set_control_mode', 3);
            Panel_com('set_pattern_id', exp_order(r,c));
            Panel_com('set_position_x', 1);
            Panel_com('start_display', (inter_trial_duration*10)-1);
            pause(inter_trial_duration);
        elseif inter_type == 2
            Panel_com('set_control_mode', 4);
            Panel_com('set_gain_bias', [CL_gain CL_offset]);
            Panel_com('set_pattern_id', 1);
            Panel_com('start_display', (inter_trial_duration*10));
            pause(inter_trial_duration);
        end
    end
end

%rename/move results folder
pause(0.5);
Panel_com('stop_log');
pause(1);
movefile([experiment_folder '\Log Files\*'],fullfile(experiment_folder,'Results',fly_name));

disp('finished');