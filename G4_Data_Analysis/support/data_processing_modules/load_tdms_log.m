function [Log] = load_tdms_log(exp_folder)

    %get files in provided directory
    files = dir(exp_folder);
    TDMSfiles = files(contains({files.name},{'G4_TDMS_Logs'}));

    if length(TDMSfiles) > 1
    %Check if there are any files whose name contains 'G4_TDMS_Logs'
        try
            TDMS_logs_name = TDMSfiles(contains({TDMSfiles.name},{'G4_TDMS_Logs_Final'})).name;
        catch
            error('There are multiple TDMS Log files, but no combined final TDMS Log file')
       
        end

    elseif length(TDMSfiles) == 1

        try 
            TDMS_logs_name = TDMSfiles(contains({TDMSfiles.name},{'G4_TDMS_Logs'})).name;
        catch
            error('Cannot find a TDMS Log file in the folder provided')

        end

    else

        disp('Cannot find a TDMS Log file int he folder provided');
        TDMS_logs_name = '';

    end
    
    if ~isempty(TDMS_logs_name)
        load(fullfile(exp_folder,TDMS_logs_name),'Log');
    end

end