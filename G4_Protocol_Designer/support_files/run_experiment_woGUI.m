%This function can be called by any program to run an experiment as long as
%the G4 conductor software is on the matlab path.

% A lot of information will need to be passed into the function. All the
% metadata, and the filepath to the experiment.

%INPUTS:
%   - filepath is the filepath to the experiment .g4p file
%   - run_test is a 1 or 0 indicating whether a test experiment should
%   be run. This is optional, will default to 0 (no test).
%   - metadata would be a struct with all the correct metadata values in
%   it. These can be strings, which can be passed into get_metadata_index
%   to get the index value later, but they must match a string in the
%   googlesheet. They can also be the index value.
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

% This method of running an experiment has gotten rid of all the pop-ups
% and user inputs other than one instance - when it asks the user if they
% want to repeat the test protocol. You'll need to replace this with
% whatever function you write for the robot to decide if to repeat or not.

% Note: I named the metadata input "metadataIn" because a "metadata"
% variable with "human readable" values is created when the experiment creates the metadata file, and it
% might replace these metadata values.

function run_experiment_woGUI(filepath, metadataIn, run_test)
    
    %Set default run_test if not passed in
    if ~exist('run_test','var')
        run_test = 0;
    end
    if ~exist('metadataIn','var')
        disp("No metadata was provided for this experiment.");
        metadataIn = [];
    end
    if ~exist('filepath', 'var')
        disp("No experiment filepath was provided so the experiment could not be run.");
        return;
    end
    
    %Open the conductor controller without the gui
    con = G4_conductor_controller();
    
    %Open the experiment path passed in.
    con.open_g4p_file(filepath);

    % Metadata is pulled from the metadata google sheet, so entries should be
    % created for robot experiments. Right now, many of the values passed into the
    %functions which update the metadata are indices - the list from the google
    %sheet is turned into a cell array and the index gets the correct value. 
    
    %Check all metadata values that should be indices. If they are char or
    %string, call get_metadata_index to get the googlesheet index for them
    %and update the metadata struct.
    if ~isempty(metadataIn)
        if ischar(metadataIn.experimenter) || isstring(metadataIn.experimenter)
            metadataIn.experimenter = get_metadata_index(con, 'experimenter',metadataIn.experimenter);
        end
        if ischar(metadataIn.genotype) || isstring(metadataIn.genotype)
            metadataIn.genotype = get_metadata_index(con, 'fly_geno',metadataIn.genotype);
        end
        if ischar(metadataIn.fly_age) || isstring(metadataIn.fly_age)
            metadataIn.fly_age = get_metadata_index(con, 'fly_age',metadataIn.fly_age);
        end
        if ischar(metadataIn.fly_sex) || isstring(metadataIn.fly_sex)
            metadataIn.fly_sex = get_metadata_index(con, 'fly_sex',metadataIn.fly_sex);
        end
        if ischar(metadataIn.experiment_temp) || isstring(metadataIn.experiment_temp)
            metadataIn.experiment_temp = get_metadata_index(con, 'exp_temp',metadataIn.experiment_temp);
        end
        if ischar(metadataIn.rearing_protocol) || isstring(metadataIn.rearing_protocol)
            metadataIn.rearing_protocol = get_metadata_index(con, 'rearing',metadataIn.rearing_protocol);
        end
        if ischar(metadataIn.light_cycle) || isstring(metadataIn.light_cycle)
            metadataIn.light_cycle = get_metadata_index(con, 'light_cycle',metadataIn.light_cycle);
        end
    
        %Update metadata of experiment
        con.update_experiment_type(metadataIn.experiment_type); %1 - flight 2 - Cam walk 3 - Chip walk
        con.update_do_processing(metadataIn.do_processing); % 1 or 0
        con.update_do_plotting(metadataIn.do_plotting); % 1 or 0
        con.update_experimenter(metadataIn.experimenter); % index of googlesheet list
        con.update_genotype(metadataIn.genotype);% index of googlesheet list
        con.update_age(metadataIn.fly_age);% index of googlesheet list
        con.update_sex(metadataIn.fly_sex);% index of googlesheet list
        con.update_temp(metadataIn.experiment_temp);% index of googlesheet list
        con.update_rearing(metadataIn.rearing_protocol);% index of googlesheet list
        con.update_light_cycle(metadataIn.light_cycle);% index of googlesheet list
        con.update_timestamp(); %Get current timestamp
        
        %update any optional metadata
        if isfield(metadataIn, 'comment_text')
            con.update_comments(metadataIn.comment_text);% char/string
        end
        if isfield(metadataIn,'plotting_file_path') && ~isempty(metadataIn.plotting_file_path)
            con.update_plotting_file(metadataIn.plotting_file_path); %Filepath to plotting file
        end
        if isfield(metadataIn, 'processing_file_path') && ~isempty(metadataIn.processing_file_path)
            con.update_processing_file(metadataIn.processing_file_path); %Filepath to processing file
        end
        if isfield(metadataIn, 'run_protocol_index')
            if metadataIn.run_protocol_index > 0 && metadataIn.run_protocol_index < 9
                con.model.set_run_file(metadataIn.run_protocol_index); %Filepath to run protocol
            else
                disp("Run protocol defaulted to 1 because provided number fell outside of the boundaries.");
                con.model.set_run_file(1);
            end
        end
    end

    
    %Run test protocol
    
    if run_test == 1
        con.prepare_test_exp();
        [original_filepath, original_fly_name] = con.run_test();
        
        repeat = con.check_if_repeat();        
        % replace the above function with your own
        %function the robot will use to check if it wants to repeat the
        %test or not. This function asks for input from the user.

        while repeat > 0
            [~, ~] = con.run_test(original_filepath, original_fly_name);
            repeat = con.check_if_repeat(); %again replace this with your own function
        end
        
        con.reopen_original_experiment(original_filepath, original_fly_name);
    end

    con.run();
    
    %Because matlab executes code linearly and not simultaneously, I'm not
    %sure how to have the bot monitor the experiment and call
    %con.abort_experiment() if necessary. Usually, hitting the abort button
    %activates the callback function abort_experiment(). The run function
    %checks after every trial to see if the "is_aborted" variable has
    %changed to 1. So essentially, to do this, the bot will need to be
    %monitoring whatever it needs from the experiment and will need to call
    %con.abort_experiment() if necessary, or simply set con.is_aborted
    %to 1. I'm not sure how it can do that during the run function without
    %the GUI but I'm sure there is a way.

end

function index = get_metadata_index(con, field, value)

    %field options are: experimenter, fly_geno, fly_age, fly_sex,
    %exp_temp, rearing, light_cycle
    
    %value should be a string and must match one of the strings listed in
    %the googlesheet for this field. %This function means if someone
    %rearranges items in the googlesheet list, or inserts a new value in
    %the middle, your metadata won't all be off by one.
    
   index = find(strcmp(con.model.metadata_options.(field)(:),value));
    


end



