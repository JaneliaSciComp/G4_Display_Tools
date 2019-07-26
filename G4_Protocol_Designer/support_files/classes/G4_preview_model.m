classdef G4_preview_model
    
    properties
        doc_
        data_
        dummy_data_
        preview_index_
        is_paused_
        is_realtime_
        slow_frRate_
        rt_frRate_
        pattern_data_
        mode_
        dur_
        pos_data_
        ao1_data_
        ao2_data_
        ao3_data_
        ao4_data_
        
    end
    
    
    properties (Dependent)
        
        doc
        data
        dummy_data
        preview_index
        is_paused
        is_realtime
        slow_frRate
        rt_frRate
        pattern_data
        mode
        dur
        pos_data
        ao1_data
        ao2_data
        ao3_data
        ao4_data
        
    end
    
    methods
%CONSTRUCTOR
        
        function self = G4_preview_model(data, doc)
            
            self.doc = doc;
            self.data = data;
            self.dummy_data = [];
            self.preview_index = 1;
            self.is_paused = false;
            self.is_realtime = false;
            self.slow_frRate = 20;
            self.rt_frRate = [];
            self.mode = data{1};
            self.pattern_data = self.normalize_matrix();
            pat = self.data{2};
            
            if self.mode == 2
                self.rt_frRate = self.data{9};
            else
                if self.doc.Patterns_.(pat).pattern.gs_val == 1
                    self.rt_frRate = 1000;
                elseif self.doc.Patterns_.(pat).pattern.gs_val == 4
                    self.rt_frRate = 500;
                else
                    waitfor(errordlg("Please make sure your pattern has a valid gs_val"));
                end
            end
            
            if strcmp(self.data{3},'') == 0
                pos = self.data{3};
                self.pos_data = self.doc.Pos_funcs_.(pos).pfnparam.func;
            end
            
            if strcmp(self.data{4},'') == 0
                ao1 = self.data{4};
                self.ao1_data = self.doc.Ao_funcs_.(ao1).afnparam.func;
            end
            
            if strcmp(self.data{5},'') == 0
                ao2 = self.data{5};
                self.ao2_data = self.doc.Ao_funcs_.(ao2).afnparam.func;
            end
            
            if strcmp(self.data{6},'') == 0
                ao3 = self.data{6};
                self.ao3_data = self.doc.Ao_funcs_.(ao3).afnparam.func;
            end
            
            if strcmp(self.data{7},'') == 0
                ao4 = self.data{7};
                self.ao4_data = self.doc.Ao_funcs_.(ao4).afnparam.func;
            end
            
            self.dur = self.data{12};
            
        end
        
        function [adjusted_data] = normalize_matrix(self)
            
            pat = self.data{2};
            original_data = self.doc.Patterns_.(pat).pattern.Pats;
            x = length(original_data(1,:,1));
            y = length(original_data(:,1,1));
            z = length(original_data(1,1,:));
            adjusted_data = zeros(y,x,z);
            max_num = max(max(original_data,[],2));
            for i = 1:z
                
                adjusted_matrix(:,:,1) = original_data(:,:,i) ./ max_num(i);
                adjusted_data(:,:,i) = adjusted_matrix(:,:,1);
            
            end
        
        end
        
%GETTERS

        function value = get.dummy_data(self)
            value = self.dummy_data_;
        end
        function value = get.preview_index(self)
            value = self.preview_index_;
        end
        function value = get.is_paused(self)
            value = self.is_paused_;
        end
        function value = get.is_realtime(self)
            value = self.is_realtime_;
        end
        function value = get.slow_frRate(self)
            value = self.slow_frRate_;
        end
        function value = get.rt_frRate(self)
            value = self.rt_frRate_;
        end
        function value = get.pattern_data(self)
            value = self.pattern_data_;
        end
        function value = get.mode(self)
            value = self.mode_;
        end
        function value = get.dur(self)
            value = self.dur_;
        end
        function value = get.pos_data(self)
            value = self.pos_data_;
        end
        function value = get.ao1_data(self)
            value = self.ao1_data_;
        end
        function value = get.ao2_data(self)
            value = self.ao2_data_;
        end
        function value = get.ao3_data(self)
            value = self.ao3_data_;
        end
        function value = get.ao4_data(self)
            value = self.ao4_data_;
        end
        function value = get.doc(self)
            value = self.doc_;
        end
        function value = get.data(self)
            value = self.data_;
        end

        
        
        
%SETTERS        
        function self = set.data(self, value)
            self.data_ = value;
        end
        
        function self = set.dummy_data(self, value)
            self.dummy_data_ = value;
        end
        function self = set.preview_index(self, value)
            self.preview_index_ = value;
        end
        function self = set.is_paused(self, value)
            self.is_paused_ = value;
        end
        function self = set.is_realtime(self, value)
            self.is_realtime_ = value;
        end
        function self = set.slow_frRate(self, value)
            self.slow_frRate_ = value;
        end
        function self = set.rt_frRate(self, value)
            self.rt_frRate_ = value;
        end
        function self = set.pattern_data(self, value)
            self.pattern_data_ = value;
        end
        function self = set.mode(self, value)
            self.mode_ = value;
        end
        function self = set.dur(self, value)
            self.dur_ = value;
        end
        function self = set.pos_data(self, value)
            self.pos_data_ = value;
        end
        function self = set.ao1_data(self, value)
            self.ao1_data_ = value;
        end
        function self = set.ao2_data(self, value)
            self.ao2_data_ = value;
        end
        function self = set.ao3_data(self, value)
            self.ao3_data_ = value;
        end
        function self = set.ao4_data(self, value)
            self.ao4_data_ = value;
        end
        function self = set.doc(self, value)
            self.doc_ = value;
        end
        
    end
    
end