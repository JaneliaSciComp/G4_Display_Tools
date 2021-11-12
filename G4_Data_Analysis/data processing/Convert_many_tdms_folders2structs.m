function Convert_many_tdms_folders2structs(fly_path)

    % Take in the path to the folder, find all sub folders with tdms files
    % in them, and then run G4_TDMS_folder2struct on each, resulting in the
    % same number of Log .mat files. 
    if strcmpi(fly_path(end),'\')==1
        fly_path = fly_path(1:end-1);
    end
    files = dir(fly_path);
    files = files(~ismember({files.name},{'.','..'}));
    subdir_idx = [files.isdir]; %look for subfolders
    subfolders = files(subdir_idx);

    
    for fold = length(subfolders):-1:1
        subfiles = dir(fullfile(fly_path, subfolders(fold).name));
        subfiles = subfiles(~ismember({subfiles.name},{'.','..'}));
        if ~contains([subfiles.name], '.tdms')
            subfolders(fold) = [];
        end
    end
    
    for folder = 1:length(subfolders)
        G4_TDMS_folder2struct(fullfile(fly_path, subfolders(folder).name));
    
    end
    
    % Now the folder has a Log file for each condition. Load all Log files
    % and combine them into one Log file 
    
    newfiles = dir(fly_path);
    newfiles = newfiles(~ismember({newfiles.name},{'.', '..'}));
    for file = length(newfiles):-1:1
        if ~contains(newfiles(file).name, 'G4_TDMS_Logs_')
            newfiles(file) = [];
        end
    end
    
    % Create main Log struct to hold all data
    
    Log = struct;
    LogInd = load(fullfile(fly_path, newfiles(1).name));
    
    Log = LogInd.Log; % Adds all correct struct fields and data for the first trial
    
    for l = 2:length(newfiles)
        LogInd =  load(fullfile(fly_path, newfiles(l).name));
        % Go through each field/value in the Log struct and combine with
        % the existing
        
        Log.ADC.Time = [Log.ADC.Time LogInd.Log.ADC.Time];
        Log.ADC.Volts = [Log.ADC.Volts LogInd.Log.ADC.Volts];
        Log.AO.Time = [Log.AO.Time LogInd.Log.AO.Time];
        Log.AO.Volts = [Log.AO.Volts LogInd.Log.AO.Volts];
        Log.Frames.Time = [Log.Frames.Time LogInd.Log.Frames.Time];
        Log.Frames.Position = [Log.Frames.Position LogInd.Log.Frames.Position];
        Log.Commands.Time = [Log.Commands.Time LogInd.Log.Commands.Time];
        Log.Commands.Name = [Log.Commands.Name LogInd.Log.Commands.Name];
        Log.Commands.Data = [Log.Commands.Data LogInd.Log.Commands.Data];
        
    end
    
    save(fullfile(fly_path, 'G4_TDMS_Logs_final.mat'), 'Log');
    
    
end