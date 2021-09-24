function find_flies(settings_file)

%% This function will take the settings file you created previously, load it, use
% its settings to find all flies that should be run in the analysis, save
% the variable exp_settings.exp_folder, which contains path to every fly in
% the analysis, and then updates the settings file with the flies. If you
% have previously created a settings file, but new flies have been added
% since creating it, you should run this function to update it before
% running an analysis to be sure all flies are included.

    load(settings_file); %exp_settings must be a variable saved in the settings file

     %% This will generate your exp_folder, do not edit. 
    
   exp_settings.exp_folder = get_exp_folder(exp_settings.field_to_sort_by, exp_settings.field_values, exp_settings.single_group, ...
        exp_settings.single_fly, exp_settings.fly_path, proc_settings.protocol_folder, exp_settings.control_genotype);

    save(settings_file, 'exp_settings', 'histogram_plot_settings', ...
        'histogram_annotation_settings','CL_hist_plot_settings', 'proc_settings',...
        'timeseries_plot_settings', 'TC_plot_settings', 'MP_plot_settings', ...
        'pos_plot_settings', 'save_settings','comp_settings', 'gen_settings');
end