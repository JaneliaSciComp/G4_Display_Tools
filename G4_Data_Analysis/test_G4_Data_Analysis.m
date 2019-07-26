exp_folder = 'C:\matlabroot\G4\Experiments\Experiment1\Results\fly1';
trial_options = [1 1 1]; % [pre-trial, intertrial, post-trial]

%convert .tdms files into .mat struct
G4_TDMS_folder2struct(exp_folder)

%process data
G4_Process_Data_flyingdetector(exp_folder, trial_options)

%plot_data
G4_Plot_Data_flyingdetector(exp_folder, trial_options)

%% for more advanced plotting:
% CL_conds = []; %matrix of closed-loop (CL) conditions to plot as histograms
% OL_conds = [1 2 3 4; 5 6 7 8]; %matrix of open-loop (OL) conditions to plot as timeseries
% TC_conds = [1 2 3 4; 5 6 7 8]; %matrix of open-loop conditions to plot as tuning curves (TC)
% G4_Plot_Data_flyingdetector(exp_folder, trial_options, CL_conds, OL_conds, TC_conds)