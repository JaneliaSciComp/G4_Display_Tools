function exp_folder = create_exp_dir_G4(exp_name, exp_path)

%create experiment folders
exp_folder = fullfile(exp_path, exp_name);

if exist(exp_folder,'dir')
    overwrite = input('Experiment folder already exists. Do you want to overwrite it? (Y or N): ','s');
    if lower(overwrite)=='y'
        rmdir(exp_folder,'s');
    else
        error('script aborted by user request')
    end
end

mkdir(exp_path, exp_name);
mkdir(exp_folder,'Patterns');    
mkdir(exp_folder,'Functions');   
mkdir(exp_folder,'Analog Output Functions');

end