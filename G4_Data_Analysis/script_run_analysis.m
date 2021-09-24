% This is a script to help you run an analysis. You can comment out the
% first line if you have already created your data analysis settings file.
% You must make sure to change the function inputs to fit your needs. Also
% remember to update the single/group flag and the flags indicating what
% kind of plots you want. 

create_settings_file('name of settings file', 'path to settings file');
find_flies('path to settings file');
da = create_data_analysis_tool('path to settings file', '-single', '-hist', '-tsplot');
da.run_analysis;