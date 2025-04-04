exp_folder = fullfile("C:\");
new_dir = uigetdir();
if new_dir ~= 0
    exp_folder = new_dir;
end
settings_filename = 'da_settings';

[protocol_subFiles, protocol_subFolders] = get_files_and_subdirectories(exp_folder);
num_dates = length(protocol_subFolders);

fly_filepaths = {};

for date = 1:num_dates
    folder_path = fullfile(exp_folder, protocol_subFolders{date});
    [fly_files, fly_folders] = get_files_and_subdirectories(folder_path);
    num_flies = length(fly_folders);
    for fly = 1:num_flies
          fly_file = fullfile(folder_path, fly_folders{fly});
          if isfile(fullfile(fly_file, 'metadata.mat'))
              fly_filepaths{end+1} = fly_file;
          end
    end
end

for f = 1:length(fly_filepaths)
    create_settings_file(settings_filename, fly_filepaths{f});
    set_filename = [settings_filename,'.mat'];
    settings_path = fullfile(fly_filepaths{f}, set_filename);
    load(settings_path);
    exp_settings.exp_folder = fly_filepaths{f};
    save_settings.path_to_protocol = fly_filepaths{f};
    save_settings.save_path = fly_filepaths{f};
    save_settings.report_path = fullfile(fly_filepaths{f}, 'da_report.pdf');
    save(fullfile(fly_filepaths{f}, settings_filename), 'exp_settings', 'save_settings', '-append');
    
     da = create_data_analysis_tool(settings_path, '-single', '-tsplot');
     da.run_analysis;
end
    
    
    