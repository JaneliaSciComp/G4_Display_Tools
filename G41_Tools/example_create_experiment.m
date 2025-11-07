%% Example to  create an experiment

% First, you must create a .yaml file. Use the experimentTemplate.yaml
% file, update the paths in it to direct to patterns saved locally on your
% computer and adjust any other parameters. Then save it as a new .yaml
% file elsewhere. 

% Once your .yaml file is created and saved, update the paths below then
% run this script.

yaml_path = '';
experiment_path = ''; % Path to the experiment directory.  It does not have to exist yet. 

G41_Tools.create_experiment_folder_g41(yaml_path, experiment_path);