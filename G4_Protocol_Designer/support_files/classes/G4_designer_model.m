classdef G4_designer_model < handle
    %MAIN MODEL with trial data (in the form of cell arrays) and other
    %parameters for submitting a run. 
    
    properties
        
%tracking which cell in each table is currently selected
        pre_selected_index
        inter_selected_index
        post_selected_index
        block_selected_index
        
%tracking which file is in the current preview window
        current_preview_file
        current_selected_cell
        
%Tracking position in in-window preview
        auto_preview_index
        is_paused
        
%Other values to keep track of

        isSelect_all
        host_connected
        screen_on
       
    end
    
    methods
%CONSTRUCTOR (Set defaults here except trial defaults - set those in model_trial)
        function self = G4_designer_model()
            
            self.set_isSelect_all(false);
            self.set_is_paused(false);
            self.set_current_selected_cell(struct('table', "", 'index', [0,0]));
            self.set_auto_preview_index(1);
            self.set_current_preview_file('');
            self.set_host_connected(0);
            self.set_screen_on(0);
     
        end

%SETTERS
        function set_pre_selected_index(self, input)
            self.pre_selected_index = input;
        end

        function set_inter_selected_index(self, input)
            self.inter_selected_index = input;
        end

        function set_post_selected_index(self, input)
            self.post_selected_index = input;
        end

        function set_block_selected_index(self, input)
            self.block_selected_index = input;
        end

        function set_current_preview_file(self, input)
            self.current_preview_file = input;
        end

        function set_current_selected_cell(self, input)
            self.current_selected_cell = input;
        end

        function set_auto_preview_index(self, input)
            self.auto_preview_index = input;
        end

        function set_is_paused(self, input)
            if input == 0 || input == 1
                self.is_paused = input;
            else
                disp("Error with the pause function");
            end
        end

        function set_isSelect_all(self, input)
            if input == 0 || input == 1
                self.isSelect_all = input;
            else
                disp("Error with the select all function");
            end
        end

        function set_host_connected(self, input)
            self.host_connected = input;
        end

        function set_screen_on(self, input)
            if input == 1 || input == 0
                self.screen_on = input;
            else
                disp("Error with the Screen On/Off function");
            end
        end

%GETTERS

        function output = get_pre_selected_index(self)
            output = self.pre_selected_index;
        end

        function output = get_inter_selected_index(self)
            output = self.inter_selected_index;
        end

        function output = get_post_selected_index(self)
            output = self.post_selected_index;
        end

        function output = get_block_selected_index(self)
            output = self.block_selected_index;
        end

        function output = get_current_preview_file(self)
            output = self.current_preview_file;
        end

        function output = get_current_selected_cell(self)
            output = self.current_selected_cell;
        end

        function output = get_auto_preview_index(self)
            output = self.auto_preview_index;
        end

        function output = get_is_paused(self)
            output = self.is_paused;
        end

        function output = get_isSelect_all(self)
            output = self.isSelect_all;
        end

        function output = get_host_connected(self)
            output = self.host_connected;
        end
           

        function output = get_screen_on(self)
            output = self.screen_on;
        end


    end
end

