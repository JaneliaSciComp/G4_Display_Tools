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
        current_uneditable_indices
        
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
            self.set_current_selected_cell("", [1,1]);
            self.set_auto_preview_index(1);
            self.set_current_preview_file('');
            
            uneditable_cells.pre = {};
            uneditable_cells.inter = {};
            uneditable_cells.block = {};
            uneditable_cells.post = {};
            self.set_current_uneditable_indices(uneditable_cells);

            self.set_host_connected(0);
            self.set_screen_on(0);

        end

        function update_uneditable_cell(self, table, index)
            % index should be a cell array with indices of each uneditable
            % cell for that trial. For pre/inter/post, the y value will
            % always be 1, for block it'll be whichever trial is being
            % edited. 
            current_ue_cell = self.get_current_uneditable_indices();
            current_ue_cell.(table){index(2)} = index;

        end
        
%SETTERS
        
        function set_pre_selected_index(self, new_val)
            self.pre_selected_index = new_val;
        end

        function set_inter_selected_index(self, new_val)
            self.inter_selected_index = new_val;
        end

        function set_post_selected_index(self, new_val)
            self.post_selected_index = new_val;
        end

        function set_block_selected_index(self, new_val)
            self.block_selected_index = new_val;
        end

        function set_current_preview_file(self, new_val)
            self.current_preview_file = new_val;
        end
        function set_current_selected_cell(self, table, index)
           
           self.current_selected_cell.table = table;
           self.current_selected_cell.index = index;
        end
        function set_current_uneditable_indices(self, new_val)
            % should be a struct with  4 fields, pre, inter, block, and
            % post. Each field should have a cell array of [x, y] pairs
            % representing the column and row values of each uneditable
            % cell in that table based on the modes. 
            self.current_uneditable_indices = new_val;
        end
        
        function set_auto_preview_index(self, new_val)
            self.auto_preview_index = new_val;
        end
        function set_is_paused(self, new_val)
            self.is_paused = new_val;
        end
        function set_isSelect_all(self, new_val)
            self.isSelect_all = new_val;
        end
        function set_host_connected(self, new_val)
            self.host_connected = new_val;
        end
        function set_screen_on(self, new_val)
            self.screen_on = new_val;
        end
      
        
%GETTERS        

        function value = get_pre_selected_index(self)
            value = self.pre_selected_index;
        end

        function value = get_inter_selected_index(self)
            value = self.inter_selected_index;
        end

        function value = get_post_selected_index(self)
            value = self.post_selected_index;
        end

        function value = get_block_selected_index(self)
            value = self.block_selected_index;
        end

        function value = get_current_preview_file(self)
            value = self.current_preview_file;
        end
        function value = get_current_selected_cell(self)
            value  = self.current_selected_cell;
        end
        function value = get_current_uneditable_indices(self)
            value = self.current_uneditable_indices;
        end
        function value = get_auto_preview_index(self)
            value = self.auto_preview_index;
        end
        function value = get_is_paused(self)
            value = self.is_paused;
        end
        function value = get_isSelect_all(self)
            value = self.isSelect_all;
        end
        function value = get_host_connected(self)
            value = self.host_connected;
        end
        function value = get_screen_on(self)
            value = self.screen_on;
        end
        

    end
end

