fly_results_folder = '\\dm11.hhmi.org\reiserlab\Jinyong\LPT protocol\LPTephys_protocol02_05-24-23_14-29-19\05_26_2023\no_fly-15_19_13';
settings_file = '\\dm11.hhmi.org\reiserlab\Jinyong\LPT protocol\LPTephys_protocol02_05-24-23_14-29-19\processeing_settings.mat';
% num_conds = 60;
% num_reps = 4;

% load(fullfile(fly_results_folder, 'exp_order.mat'));
% for rep = 1:num_reps
%     exp_order(rep,:) = 1:num_conds;
% end
% save(fullfile(fly_results_folder, 'exp_order.mat'), 'exp_order');
run_con = G4_conductor_controller();
%run_con.layout();

run_con.convert_multiple_logs(fly_results_folder);
Log = run_con.consolidate_log_structs(fly_results_folder);
LogFinalName = 'G4_TDMS_Logs_Final.mat';
save(fullfile(fly_results_folder, LogFinalName),'Log');
process_data(fly_results_folder, settings_file);
