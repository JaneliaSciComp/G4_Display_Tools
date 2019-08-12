function exp_folder = create_exp_dir_G4(exp_name)

base_folder = 'C:\matlabroot\G4\Experiments\';

%create experiment folders
exp_folder = [base_folder exp_name];

if exist(exp_folder,'dir')
    overwrite = input('Experiment folder already exists. Do you want to overwrite it? (Y or N): ','s');
    if lower(overwrite)=='y'
        rmdir(exp_folder,'s');
    else
        error('script aborted by user request')
    end
end

mkdir(base_folder, exp_name);
mkdir(exp_folder,'Patterns');    
mkdir(exp_folder,'Functions');   
mkdir(exp_folder,'Analog Output Functions');

end