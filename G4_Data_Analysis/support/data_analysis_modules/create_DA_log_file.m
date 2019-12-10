function create_DA_log_file(DA_obj)
    
    %% TO HAVE A SINGLE LOG FILE LOG ALL ANALYSIS
    
    
    
    %% TO HAVE A WEEKLY LOG FILE
    
    

    %% TO HAVE A LOG FILE BY EXPERIMENTAL PROTOCOL
    
    
    %% TO HAVE A LOG FILE FOR EACH DATA ANALYSIS RUN?
    exp_folder = DA_obj.exp_folder;
    date = datestr(now, 'mm-dd-yyyy HH:MM:SS');
    analyses_performed = DA_obj.flags;
    results_path = DA_obj.save_settings.save_path;
    
    
    

end