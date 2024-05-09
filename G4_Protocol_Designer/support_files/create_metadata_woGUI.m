%% This function is a quick way to generate the metadata struct that needs
% to be passed into the 'run_experiment_woGUI.m' file. If you are running
% an experiment from command line without the GUI, you can use this to
% generate your metadata.

%% From run_experiment_woGUI.m
%   - metadata would be a struct with all the correct metadata values in
%   it. These can be strings, which can be passed into get_metadata_index
%   to get the index value later, but they must match a string in the
%   googlesheet. They can also be the index of the value in the googlesheet.
%       Fields of metadata:
%           experiment_type - must be 1 (flight), 2 (cam), or 3 (chip)
%           do_processing - 1 or 0
%           do_plotting - 1 or 0
%           plotting_file_path - char. Can be left out if default
%           processing_file_path - char. Can be left out if default
%           run_protocol_index - should be a number 1-8 corresponding to
%                   the drop down list of run protocols in the Conductor.
%                   Will default to 1.
%           experimenter - char OR index 
%           genotype - char OR index
%           fly_age - char OR index
%           fly_sex - char OR index
%           experiment_temp - char OR index
%           rearing_protocol - char OR index
%           light_cycle - char OR index
%           comment_text - char. Can be empty or left out

% Possible run protocol indices are: 
% 1 - Simple run protocol
% 2 - Combined Command
% 3 - Streaming
% 4 - Log Reps Separately
% 5 - CC + Streaming
% 6 - CC + Log Reps
% 7 - Streaming + Log Reps
% 8 - CC + Streaming + Log Reps

function [filepath, md, run_test] = create_metadata_woGUI()

    filepath = 'G4_Display_Tools/G4_Protocol_Designer/test_protocols/test_protocol_4Rows/test_protocol_4Rows.g4p';
    run_test = 0;

    md.experiment_type = 1;
    md.do_processing = 0;
    md.do_plotting = 0;  
    md.processing_file_path = '';
    md.plotting_file_path = '';
    md.run_protocol_index = 1; % 1-8
    md.experimenter = 1;
    md.genotype = 1;
    md.fly_age = 1;
    md.fly_sex = 1;
    md.experiment_temp = 1;
    md.rearing_protocol = 1;
    md.light_cycle = 1;
    md.comment_text = '';


end