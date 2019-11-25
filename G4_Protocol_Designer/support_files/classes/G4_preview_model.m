classdef G4_preview_model < handle
    
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
        ao_data_
        fr_increment_
        ao_increment_
        
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
        ao_data
        fr_increment
        ao_increment
        
    end
    
    methods
%CONSTRUCTOR
        
        function self = G4_preview_model(doc)
            
            self.doc = doc;
            self.data = {};
            self.dummy_data = [];
            self.preview_index = 1;
            self.is_paused = false;
            self.is_realtime = false;
            self.slow_frRate = 30;
            self.mode = [];
            self.fr_increment = 1;
            self.ao_increment = 1;

        end
        
        function update_trial_data(self, data)
            
            self.data = data;
            self.mode = data{1};
            pat = data{2};
            patfield = self.doc.get_pattern_field_name(pat);
            self.pattern_data = self.normalize_matrix();
            
            if self.mode == 2
                self.rt_frRate = self.data{9};
            else
                if self.doc.Patterns.(patfield).pattern.gs_val == 1
                    self.rt_frRate = 1000;
                elseif self.doc.Patterns.(patfield).pattern.gs_val == 4
                    self.rt_frRate = 500;
                else
                    waitfor(errordlg("Please make sure your pattern has a valid gs_val"));
                end
            end
            
            if ~strcmp(self.data{3},'') && ~self.doc.check_if_cell_disabled(self.data{3})
                pos = self.data{3};
                posfield = self.doc.get_posfunc_field_name(pos);
                self.pos_data = self.doc.Pos_funcs.(posfield).pfnparam.func;
            end
            
            for i = 4:7
                
                if ~isempty(self.data{i})
                    ao = self.data{i};
                    aofield = self.doc.get_aofunc_field_name(ao);
                    self.ao_data{i-3} = self.doc.Ao_funcs.(aofield).afnparam.func;
                end
            end
           
            self.dur = self.data{12};
            
        end
        
        function set_slow_frRate(self, new_value)
            self.slow_frRate = new_value;
        end
        
        function [adjusted_data] = normalize_matrix(self)
            
            pat = self.data{2};
            patfield = self.doc.get_pattern_field_name(pat);
            original_data = self.doc.Patterns.(patfield).pattern.Pats;
            grayscale_val = self.doc.Patterns.(patfield).pattern.gs_val;
            
            x = [0 length(original_data(1,:,1))];
            y = [0 length(original_data(:,1,1))];
            adjusted_data = zeros(y(2),x(2),length(original_data(1,1,:)));
            max_num = (2^grayscale_val) - 1;
            
%             x = length(original_data(1,:,1));
%             y = length(original_data(:,1,1));
%             z = length(original_data(1,1,:));
%             
%             adjusted_file = zeros(y(2),x(2),length(self.model.current_preview_file(1,1,:)));
%             adjusted_data = zeros(y,x,z);

            for i = 1:length(original_data(1,1,:))

                adjusted_matrix = original_data(:,:,i) ./ max_num;
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
        function value = get.ao_data(self)
            value = self.ao_data_;
        end
       
        function value = get.doc(self)
            value = self.doc_;
        end
        function value = get.data(self)
            value = self.data_;
        end
        function value = get.fr_increment(self)
            value = self.fr_increment_;
        end
        function value = get.ao_increment(self)
            value = self.ao_increment_;
        end

        
        
        
%SETTERS        
        function set.data(self, value)
            self.data_ = value;
        end
        
        function set.dummy_data(self, value)
            self.dummy_data_ = value;
        end
        function set.preview_index(self, value)
            self.preview_index_ = value;
        end
        function set.is_paused(self, value)
            self.is_paused_ = value;
        end
        function set.is_realtime(self, value)
            self.is_realtime_ = value;
        end
        function set.slow_frRate(self, value)
            self.slow_frRate_ = value;
        end
        function set.rt_frRate(self, value)
            self.rt_frRate_ = value;
        end
        function set.pattern_data(self, value)
            self.pattern_data_ = value;
        end
        function set.mode(self, value)
            self.mode_ = value;
        end
        function set.dur(self, value)
            self.dur_ = value;
        end
        function set.pos_data(self, value)
            self.pos_data_ = value;
        end
        function set.ao_data(self, value)
            self.ao_data_ = value;
        end
        
        function set.doc(self, value)
            self.doc_ = value;
        end
        function set.fr_increment(self, value)
            self.fr_increment_ = value;
        end
        function set.ao_increment(self, value)
            self.ao_increment_ = value;
        end
        
    end
    
end