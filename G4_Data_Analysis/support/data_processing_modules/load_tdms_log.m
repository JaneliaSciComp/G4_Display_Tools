function [Log] = load_tdms_log(exp_folder)

    %get files in provided directory
    files = dir(exp_folder);
    
    %Check if there are any files whose name contains 'G4_TDMS_Logs'
    try
        TDMS_logs_name = files(contains({files.name},{'G4_TDMS_Logs'})).name;
    catch
        error('cannot find G4_TDMS_Logs file in specified folder')
       
    end
    load(fullfile(exp_folder,TDMS_logs_name),'Log');


end