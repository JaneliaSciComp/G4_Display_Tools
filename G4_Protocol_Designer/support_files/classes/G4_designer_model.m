classdef G4_designer_model
    %MAIN MODEL with trial data (in the form of cell arrays) and other
    %parameters for submitting a run. 

    properties

%tracking which cell in each table is currently selected
        pre_selected_index_
        inter_selected_index_
        post_selected_index_
        block_selected_index_
        
%tracking which file is in the current preview window
        current_preview_file_
        current_selected_cell_
        
%Tracking position in in-window preview
        auto_preview_index_
        is_paused_
        
%Other values to keep track of

        isSelect_all_
        
    end
    
    properties (Dependent)
        
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
       
    end
    
    methods
%CONSTRUCTOR (Set defaults here except trial defaults - set those in model_trial)
        function self = G4_designer_model()
            
            self.isSelect_all = false;
            self.is_paused = false;
            self.current_selected_cell = struct('table', "", 'index', [0,0]);
            self.auto_preview_index = 1;
            self.current_preview_file = '';
 
     
        end
        

        

%SETTERS
        
        
        function self = set.pre_selected_index(self, value)
            self.pre_selected_index_ = value;
        end
        
        function self = set.inter_selected_index(self, value)
            self.inter_selected_index_ = value;
        end
        
        function self = set.post_selected_index(self, value)
            self.post_selected_index_ = value;
        end
        
        function self = set.block_selected_index(self, value)
            self.block_selected_index_ = value;
        end
        
        function self = set.current_preview_file(self, value)
            self.current_preview_file_ = value;
        end
        
        function self = set.current_selected_cell(self, value)
            self.current_selected_cell_ = value;
        end
        
        function self = set.auto_preview_index(self, value)
            self.auto_preview_index_ = value;
        end
        
        function self = set.is_paused(self, value)
            self.is_paused_ = value;
        end
        
        function self = set.isSelect_all(self, value)
            self.isSelect_all_ = value;
        end
        

        
%GETTERS        

        function value = get.pre_selected_index(self)
            value = self.pre_selected_index_;
        end
        
        function value = get.inter_selected_index(self)
            value = self.inter_selected_index_;
        end
        
        function value = get.post_selected_index(self)
            value = self.post_selected_index_;
        end
        
        function value = get.block_selected_index(self)
            value = self.block_selected_index_;
        end
        
        function value = get.current_preview_file(self)
            value = self.current_preview_file_;
        end
        
        function value = get.current_selected_cell(self)
            value = self.current_selected_cell_;
        end
        
        function value = get.auto_preview_index(self)
            value = self.auto_preview_index_;
        end
        
        function value = get.is_paused(self)
            value = self.is_paused_;
        end
        
        function value = get.isSelect_all(self)
            value = self.isSelect_all_;
        end
        
        

    end
end

