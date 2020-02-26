%% BEFORE RUNNING THIS
% - update DA plot settings
% - update the name and path to your settings file below
% - make sure the flags passed to the data analysis tool below are the
% flags you want. 

%Update variables in get_exp_folder.m before running

settings_file_name = 'test_settings';
settings_file_path = '/Users/taylorl/Desktop';

create_settings_file(settings_file_name, settings_file_path);

da = create_data_analysis_tool(exp_folder, trial_options, fullfile(settings_file_path, [settings_file_name '.mat']), '-group', '-normgroup', '-hist','-tsplot','-tcplot');
da.run_analysis();

