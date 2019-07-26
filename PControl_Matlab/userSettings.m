mfile_path = mfilename('fullpath');
[root_path, ~, ~] = fileparts(mfile_path);


controller_path = fullfile(root_path, 'controller' );
function_path = fullfile(root_path, 'functions','MyFunctions'); 
aofunction_path = fullfile(root_path, 'ao_functions\','MyAO');
pattern_path =  fullfile(root_path, 'Patterns');   
default_exp_path = fullfile(root_path, 'Experiment');
exp_path = default_exp_path;
%pattern_path =  fullfile(root_path, 'temp'); 

%Arena Config
NumofColumns = 12;
NumofRows = 4;

%GUI pattern display setting flipUpDown and flipLeftRight
%1 means pattern display flip accordingly in the GUI and 0 means no flip
flipUpDown = 1;
flipLeftRight = 1;