classdef experiment_system < handle

    properties

        possible_trial_parameters
        default_param_values % Default values for all parameters, whether or not they're used in the system
        num_screen_rows %Potential number of screen rows for this system, not the actual number on the screen you are using.
        run_protocols % This is the list of file names that are allowed to act as run protocol
        run_protocol_names % This is list should be the same length as the run protocols. 
                            % It provides easy to understand strings to make up the run protocol drop down list in the conductor.
        prohibited_modes
        screen_dimensions


    end

    methods

%% CONSTRUCTOR
        function self = experiment_system()
            self.set_possible_parameters({'mode','pattern','posfunc','ao1',...
                'ao2','ao3','ao4','frame_ind','frame_rate','gain','offset','duration'});
            answer = questdlg('Which system are you using?', 'System Version', 'G4', 'G4-1', 'G4');
            switch answer
                
                case 'G4'
                    %for each case provide a list of 0's and 1's that
                    %correspond to the list of possible parameters - 0 if
                    %that parameter is used in this system, 1 if not. 
                    
                    self.set_num_screen_rows(4);
                    %Must include 'G4_default_run_protocol' at a minimum.
                    self.set_run_protocols({'G4_default_run_protocol', ...
                        'G4_default_run_protocol_streaming', ...
                        'G4_run_protocol_blockLogging', ...
                        'G4_run_protocol_streaming_blockLogging'});
                    %Must include 'Simple' at a minimum
                    self.set_run_protocol_names({'Simple', ...
                        'Streaming', ...
                        'Log Reps Separately', ...
                        'Streaming + Log Reps'});
                    self.default_param_values = {1, '', '', '', '', '', '', 1, 60, 1, 0, 5};
                    self.prohibited_modes = [];

                case 'G4-1'
                    
                    self.set_num_screen_rows(2);
                    self.set_run_protocols({'G4_default_run_protocol', ...
                        'G4_run_protocol_blockLogging'});
                    self.set_run_protocol_names({'Simple', ...
                        'Log Reps Separately'});
                    self.default_param_values = {2, '', '', '', '', '', '', 1, 60, 1, 0, 5};
                    self.prohibited_modes = [1, 5];
                    
                    % To add a new system, add additional cases
            end
        end
        % 
        % function inds = get_required_params(self)
        % 
        %     switch self.default_trial_mode
        %         case 1
        %             inds = [1 1 1 0 0 0 0 0 0 0 0 1];
        % 
        %         case 2
        %             inds = [1 1 0 0 0 0 0 0 1 0 0 1];
        %         case 3
        %             inds = [1 1 0 0 0 0 0 1 0 0 0 1];
        %         case 4
        %             inds = [1 1 0 0 0 0 0 0 1 1 1 1];
        %         case 5
        %             inds = [1 1 1 0 0 0 0 0 0 1 1 1];
        %         case 6
        %             inds = []; %This mode is not implemented in display tools
        %         case 7
        %             inds = [1 1 0 0 0 0 0 1 0 1 1 1];
        %     end                  
        % end

        %% Getters
            
        function value = get_possible_parameters(self)
            value = self.possible_trial_parameters;
        end
       
        function value = get_num_screen_rows(self)
            value = self.num_screen_rows;
        end
        function value = get_run_protocols(self)
            value = self.run_protocols;
        end
        
        function value = get_default_param_values(self)
            value = self.default_param_values;
        end
        
        function value = get_run_protocol_names(self)
            value = self.run_protocol_names;
        end


        %% Setters
        function set_possible_parameters(self, new_val)
            self.possible_trial_parameters = new_val;
        end
       
        function set_num_screen_rows(self, new_val)
            self.num_screen_rows = new_val;
        end
        function set_run_protocols(self, new_val)
            self.run_protocols = new_val;
        end

        function set_default_param_values(self, new_val)
            self.default_param_values = new_val;
        end

        function set_run_protocol_names(self, new_val)
            self.run_protocol_names = new_val;
        end



    end
         







end
