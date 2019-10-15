%% User-defined experiment conditions
experiment_name = 'test'; %name of experiment folder
num_reps = 3; %number of repetitions for each trial
randomize = 1; %randomize each block of trials (1=yes, 0=no)
exp_mode = 1; %control mode during trials: 1=position function, 2=constant rate, 3=position change, 4=CL, 5=CL+bias, 6=CL+OL
inter_type = 3; %type of intertrial: 0=no intertrial, 1=static 1st frame of current pattern, 2=inter-trial closed loop with pattern 1, 3=pitching arena
log_TDMS = 1; %1=log, 0=don't log
AOchannel = 1; %set active AO channels: 0=ADC2, 1=ADC3, 2=ADC4, 3=ADC5
fly_name = 'test'; %name of experiment results folder
trial_duration = 6; %duration of trial in seconds
inter_trial_duration = 2; %duration of intertrial in seconds (e.g. to allow time for arena pitching)
CL_gain = 10; %gain for intertrial closed-loop
CL_offset = 0; %ofset for intertrial closed-loop


%% Load configuration
userSettings;
experiment_folder = ['C:\matlabroot\G4\Experiments\' experiment_name];
load([experiment_folder '\currentExp.mat']);
% trial_duration = currentExp.trialDuration-1; %seconds (ignore last second of position/AO functions)
num_conditions = currentExp.pattern.num_patterns;
if ~exist(fullfile(experiment_folder,'Log Files'),'dir')
    mkdir(experiment_folder,'Log Files');
end
connectHost;
Panel_com('change_root_directory', experiment_folder);


%% check if log files already present
if exist([experiment_folder '\Log Files\*'],'file')
    fprintf('unsorted log files present in save folder, remove before restarting experiment\n');
    return
end
if exist([experiment_folder '\Results\' fly_name],'dir')
    fprintf('Results folder already exists with that fly name\n');
    return
end
    

%% initialize zaber stage for ASCII protocol
Z_port = serial('COM6');
set(Z_port, ...
    'BaudRate', 115200, ...
    'DataBits', 8, ...
    'FlowControl', 'none', ...
    'Parity', 'none', ...
    'StopBits', 1, ...
    'Terminator','CR/LF');
set(Z_port, 'Timeout', 0.5)
warning off MATLAB:serial:fgetl:unsuccessfulRead
fopen(Z_port); %open the port
protocol = Zaber.AsciiProtocol(Z_port);
Zaber_device = Zaber.AsciiDevice.initialize(protocol, 1);
Zaber_device.set('maxspeed',4*92160);
position = Zaber_device.getposition();
Zaber_device.set('pos',position);
range = Zaber_device.getrange();
deg_unit = .00000427*(range(2)-range(1));        
                

%% create .mat file of experiment order
if randomize == 1
    exp_order = NaN(num_reps,num_conditions);
    for rep_ind = 1:num_reps
        exp_order(rep_ind,:) = randperm(num_conditions);
    end
else
    disp('order of conditions are not randomized');
    exp_order = repmat(1:num_conditions,num_reps,1);
end

exp_seconds = num_reps*num_conditions*(trial_duration+inter_trial_duration);
save([experiment_folder '\Log Files\exp_order.mat'],'exp_order')


%% start experiment
Panel_com('set_control_mode', exp_mode);
Panel_com('set_active_ao_channels', dec2bin(bitset(0,AOchannel+1,1),4));
fprintf(['Estimated experiment duration: ' num2str(exp_seconds/60) ' minutes\n']);
start = input('press enter to start experiment');

if log_TDMS==1
    Panel_com('start_log');
end

current_pitch = 0;
pause(0.5);

for r = 1:num_reps
    for c = 1:num_conditions
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
        elseif inter_type == 3
            next_pitch = currentExp.pattern.arena_pitch(exp_order(r,c));
            Zaber_device.moverelative(-(current_pitch-next_pitch)*deg_unit);
            pause(inter_trial_duration);
            Zaber_device.waitforidle();
            current_pitch = next_pitch;
        end
        
        
        %trial portion
        Panel_com('set_control_mode', exp_mode);
        Panel_com('set_pattern_id', exp_order(r,c));
        %Panel_com('set_gain_bias', [CL_gain CL_offset]);
        Panel_com('set_pattern_func_id', exp_order(r,c));
        Panel_com('set_ao_function_id',[AOchannel, exp_order(r,c)]);
        %Panel_com('set_ao',[1, conditionV]);
        fprintf(['Rep ' num2str(r) ' of ' num2str(num_reps) ', cond ' num2str(c) ' of ' num2str(num_conditions) ': ' ...
            strjoin(currentExp.pattern.pattNames(exp_order(r,(c)))) ', arena pitch ' num2str(current_pitch) '\n']);
        Panel_com('start_display', trial_duration*10); %duration expected in 100ms units
        pause(trial_duration)
        Panel_com('stop_display');
    end
end

%reset arena to equator
next_pitch = 0;
Zaber_device.moverelative(-(current_pitch-next_pitch)*deg_unit);
Zaber_device.waitforidle();
current_pitch = next_pitch;
fclose(Z_port);
delete(Z_port);

%rename/move results folder
if log_TDMS==1
    pause(0.5);
    Panel_com('stop_log');
    pause(1);
end
movefile([experiment_folder '\Log Files\*'],fullfile(experiment_folder,'Results',fly_name));

disp('finished');

%disconnectHost;