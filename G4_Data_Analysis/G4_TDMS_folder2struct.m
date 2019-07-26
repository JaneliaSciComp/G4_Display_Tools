function G4_TDMS_folder2struct(exp_folder)
%FUNCTION G4_TDMS_folder2struct(exp_folder)
%
% Imports a folder of G4 TDMS log files into a Matlab struct, focusing on
% ADC data, AO data, Frame position data, and Commands received.
% Recommended to install the parallel computing toolbox to decrease
% processing time.
%
% Inputs:
% exp_folder: folder containing G4 TDMS log files (or containing subfolder
%             of G4 TDMS log files)


%% configure data importing
if nargin==0
    exp_folder = uigetdir('C:/','Select a folder containing .TDMS files');
end

%get/validate directories of exp_folder and TDMS_folder
if strcmpi(exp_folder(end),'\')==1
    exp_folder = exp_folder(1:end-1);
end
files = dir(exp_folder);
files = files(~ismember({files.name},{'.','..'}));
subdir_idx = [files.isdir]; %look for subfolders
if any(subdir_idx) && ~contains([files.name],'.tdms')
    filename = files(subdir_idx); % get subfolder
    filename = filename(1).name;
    TDMS_folder = fullfile(exp_folder,filename);
else
    TDMS_folder = exp_folder;
    out = regexp(TDMS_folder,'\','start');
    exp_folder = TDMS_folder(1:out(end)-1);
    filename = TDMS_folder(out(end)+1:end);
end

%get list of .tdms files
files = dir(TDMS_folder);
files = files(~ismember({files.name},{'.','..'}));
num_TDMSfiles = 0;
for file = 1:length(files)
    if ~contains(files(file).name,'.tdms_index') & contains(files(file).name,'.tdms')
        num_TDMSfiles = num_TDMSfiles+1;
        TDMS_names{num_TDMSfiles} = files(file).name;
    end
end
assert(num_TDMSfiles>0,'cannot find any .tdms files')


%% import TDMS files using sliced variables (in parallel, if possible)

% set filename indices to all zeros for different log file types;
% when each log file type is identified, that filename index will be set to 1
ADCT_inds = zeros(1,num_TDMSfiles);
ADCV_inds = zeros(1,num_TDMSfiles);
AOT_inds = zeros(1,num_TDMSfiles);
AOV_inds = zeros(1,num_TDMSfiles);
FrameT_inds = zeros(1,num_TDMSfiles);
FrameP_inds = zeros(1,num_TDMSfiles);
Command_inds = zeros(1,num_TDMSfiles);

%loop for each TDMS file
parfor i = 1:num_TDMSfiles    
    %for ADC log files, either the logged timeseries of Volts or Timestamps
    if contains(TDMS_names{i},'ADC')
        chan = str2double(TDMS_names{i}(strfind(TDMS_names{i},'ADC')+3));
        group = ['ADC' num2str(chan)];
        [channelData, ~] = TDMS_readChannelOrGroup(fullfile(TDMS_folder,TDMS_names{i}),group);
        if contains(TDMS_names{i},'Time')
            ADCTime(i,:) = squeeze(channelData{1}); %timestamps
            ADCChannels{i} = group;
            ADCT_inds(i) = 1;
        elseif contains(TDMS_names{i},'Volts')
            ADCVolts(i,:) = squeeze(channelData{1}); %timeseries of AO volts
            ADCV_inds(i) = 1;
        else
            error('unexpected TDMS file: neither volts nor time');
        end
        
    %for AO log files
    elseif contains(TDMS_names{i},'AO')
        chan = str2double(TDMS_names{i}(strfind(TDMS_names{i},'AO')+2));
        group = ['AO' num2str(chan-2)];
        [channelData, ~] = TDMS_readChannelOrGroup(fullfile(TDMS_folder,TDMS_names{i}),group);
        if contains(TDMS_names{i},'Time')
            AOTime(i,:) = squeeze(channelData{1}); %timestamps
            AOChannels{i} = group;
            AOT_inds(i) = 1;
        elseif contains(TDMS_names{i},'Volts')
            AOVolts(i,:) = squeeze(channelData{1}); %timeseries of AO volts
            AOV_inds(i) = 1;
        else
            error('unexpected TDMS file: neither volts nor time');
        end
        
    %for Frame Time and Position log files
    elseif contains(TDMS_names{i},'Frame')
        group = 'Pattern Position';
        [channelData, ~] = TDMS_readChannelOrGroup(fullfile(TDMS_folder,TDMS_names{i}),group);
        if contains(TDMS_names{i},'Position')
            FramePosition(i,:) = squeeze(channelData{1}); %timeseries of frame indices
            FrameP_inds(i) = 1;
        elseif contains(TDMS_names{i},'Time')
            FrameTime(i,:) = squeeze(channelData{1}); %timestamps
            FrameT_inds(i) = 1;
        else
            error('unexpected TDMS file: neither pattern position nor time');
        end
       
    %for the unnamed log file containing the list of commands recieved
    else
        group = 'Commands Received';
        try
            [channelData, ~] = TDMS_readChannelOrGroup(fullfile(TDMS_folder,TDMS_names{i}),group);
            CommandTime(i,:) = channelData{1}; %timestampes
            CommandName{i} = channelData{2}; %names of commands
            CommandData{i} = channelData{3}; %data accompanying commands
            Command_inds(i) = 1;
        catch
            error(['Unexpected file in TDMS folder: ' TDMS_names{i} '. Could not find the "Commands Received" group in this file']);
        end
    end
end

%% process imported data
%to accommodate the parfor loop, sliced variables had to be used. The
%following section reoganizes this data into a cleaner structure

%create empty variables for any datatype that was not found/imported
missing_variables = [];
if ~exist('ADCTime','var')
    ADCTime = [];
    missing_variables = [missing_variables ' ADCTime'];
end
if ~exist('ADCVolts','var')
    ADCVolts = [];
    missing_variables = [missing_variables ' ADCVolts'];
end
if ~exist('ADCChannels','var')
    ADCChannels = [];
    missing_variables = [missing_variables ' ADCChannels'];
end
if ~exist('AOTime','var')
    AOTime = [];
    missing_variables = [missing_variables ' AOTime'];
end
if ~exist('AOVolts','var')
    AOVolts = [];
    missing_variables = [missing_variables ' AOVolts'];
end
if ~exist('AOChannels','var')
    AOChannels = [];
    missing_variables = [missing_variables ' AOChannels'];
end
if ~exist('FrameTime','var')
    FrameTime = [];
    missing_variables = [missing_variables ' FrameTime'];
end
if ~exist('FramePosition','var')
    FramePosition = [];
    missing_variables = [missing_variables ' FramePosition'];
end
if ~exist('CommandTime','var')
    CommandTime = [];
    missing_variables = [missing_variables ' CommandTime'];
end
if ~exist('CommandName','var')
    CommandName = [];
    missing_variables = [missing_variables ' CommandName'];
end
if ~exist('CommandData','var')
    CommandData = [];
    missing_variables = [missing_variables ' CommandData'];
end
if ~isempty(missing_variables)
    fprintf(['variables not found/imported: ' missing_variables '\n'])
end

%remove empty fields
ADCTime = ADCTime(logical(ADCT_inds),:);
ADCVolts = ADCVolts(logical(ADCV_inds),:);
ADCChannels = ADCChannels(logical(ADCT_inds));
AOTime = AOTime(logical(AOT_inds),:);
AOVolts = AOVolts(logical(AOV_inds),:);
AOChannels = AOChannels(logical(AOT_inds));
FrameTime = FrameTime(logical(FrameT_inds),:);
FramePosition = FramePosition(logical(FrameP_inds),:);
CommandTime = CommandTime(logical(Command_inds),:);
CommandName = CommandName(logical(Command_inds));
CommandData = CommandData(logical(Command_inds));

%reorganize data into struct
Log.ADC.Time = ADCTime;
Log.ADC.Volts = ADCVolts;
Log.ADC.Channels = ADCChannels;
Log.AO.Time = AOTime;
Log.AO.Volts = AOVolts;
Log.AO.Channels = AOChannels;
Log.Frames.Time = FrameTime;
Log.Frames.Position = FramePosition;
Log.Commands.Time = CommandTime;
Log.Commands.Name = CommandName{1}; %{1} un-nests cell array
Log.Commands.Data = CommandData{1}; %{1} un-nests cell array

%save the new .mat struct in parent folder
save([exp_folder '\G4_TDMS_Logs_' filename '.mat'],'Log');

