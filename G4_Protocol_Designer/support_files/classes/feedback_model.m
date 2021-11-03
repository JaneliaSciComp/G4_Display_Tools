classdef feedback_model < handle
   
    properties
       
        raw_data
        translated_data
        wbf_data
        lmr_data
        l_data
        r_data
        avg_wbf
        wbf_limits
        
        bad_trials
        full_streamed_intertrials
        full_streamed_conditions
        inter_hist_left
        inter_hist_right
        inter_hist_lmr
        cond_hist_left
        cond_hist_right
        cond_hist_lmr
        inter_hist_axis
        cond_hist_axis
        inter_lmr_axis
        num_chans
        ischan1
        ischan2
        ischan3
        ischan4
        
        
        
    end
    
    methods
        
        function self = feedback_model(doc)
            
            self.raw_data = []; 
            self.translated_data = {};
            self.full_streamed_intertrials = {};
            self.full_streamed_conditions = {};
            self.bad_trials = {};
            self.lmr_data = [];
            self.l_data = [];
            self.r_data = [];
            self.wbf_data = [];
            self.avg_wbf = 0;
            self.update_model_channels(doc);  
            self.inter_hist_axis = 0:.1:10;
            self.inter_lmr_axis = 0:.1:10;
            self.cond_hist_axis = 0:.1:10;
            self.wbf_limits{1} = [150 260];
            self.wbf_limits{2} = .25;
            self.wbf_limits{3} = 1; 
            
           
            
        end
        
        function clear_model(self)
            
        end
        
        function update_model_channels(self, doc)
            
            if doc.chan1_rate ~= 0
                self.ischan1 = 1;
            else
                self.ischan1 = 0;
            end
            if doc.chan2_rate ~= 0
                self.ischan2 = 1;
            else
                self.ischan2 = 0;
            end
            if doc.chan3_rate ~= 0
                self.ischan3 = 1;
            else
                self.ischan3 = 0;
            end
            if doc.chan4_rate ~= 0
                self.ischan4 = 1;
            else
                self.ischan4 = 0;
            end
            self.num_chans = self.calc_num_chans();
            
        end
        
        function read_tcp_data(self, tcp_read_data, trialType)
            
            self.set_raw_data(tcp_read_data);
            self.set_translated_data(self.translate_data());
            self.add_full_data(self.translated_data, trialType);
            self.set_lmr_data(self.translated_data{1});
            self.set_l_data(self.translated_data{2});
            self.set_r_data(self.translated_data{3});
            self.set_wbf_data(self.translated_data{4});
            self.set_avg_wbf(mean(self.wbf_data));
            
            if strcmp(trialType, 'inter')
                self.get_inter_histograms();
            else
                self.get_cond_histograms();
            end
                
            
        
        end
        
        function get_wbf_limits(self, processing_path)
           
            S = load(processing_path);
            if isfield(S, settings)
                wbf_lim{1} = S.settings.wbf_range;
                wbf_lim{2} = S.settings.wbf_cutoff;
                wbf_lim{3} = S.settings.wbf_end_percent;
                self.set_wbf_limits(wbf_lim);
                
            end
            
        end
        
        function [cond_flat, bad_flier] = check_if_bad(self, cond, rep, trialType)
           
              % Check if condition is flat
            
            bad_flier = 0;
            cond_flat = 0;
            
            if ~strcmp(trialType, 'inter')
                diff = [];
                for ind = 1:length(self.lmr_data)-1
                    diff(ind) = self.lmr_data(ind + 1) - self.lmr_data(ind);
                end
                if diff == 0
                    cond_flat = 1;
                end

                if self.avg_wbf < self.wbf_limits{1}(1)/100
                    bad_flier = 1;
                end
                
                count_low_wbf = sum(self.wbf_data()<self.wbf_limits{1}(1)/100);
                if (count_low_wbf/length(self.wbf_data)) > self.wbf_limits{2}
                    bad_flier = 1;
                end


                if cond_flat == 1 || bad_flier == 1
                    self.add_bad_condition(cond, rep);
                end
                
            end
            
            
            
            
        end
        
        function get_cond_histograms(self)
           
            %% Combine all conditions collected so far into one array for each wing
            
            condition_data_left = [];
            condition_data_right = [];
            condition_data_lmr = [];
            
            for trial = 1:length(self.full_streamed_conditions)
                
                condition_data_left = [condition_data_left self.full_streamed_conditions{trial}{2}];
                condition_data_right = [condition_data_right self.full_streamed_conditions{trial}{3}];
                condition_data_lmr = [condition_data_lmr self.full_streamed_conditions{trial}{1}];
            end
            
            %% Create histogram datasets for left, right, and lmr
            
            lendataleft = length(condition_data_left);
            lendataright = length(condition_data_right);
            lendatalmr = length(condition_data_lmr);
            count_left = [];
            probs_left = [];
            count_right = [];
            probs_right = [];
            count_lmr = [];
            probs_lmr = [];
            
            for i = 1:length(self.cond_hist_axis)-1
                count_left(i) = sum(condition_data_left()>=self.cond_hist_axis(i) & condition_data_left<=self.cond_hist_axis(i+1));
                count_right(i) = sum(condition_data_right()>=self.cond_hist_axis(i) & condition_data_right<=self.cond_hist_axis(i+1));
                count_lmr(i) = sum(condition_data_lmr()>=self.cond_hist_axis(i) & condition_data_lmr<=self.cond_hist_axis(i+1));
                probs_left(i) = count_left(i)/lendataleft;
                probs_right(i) = count_right(i)/lendataright;
                probs_lmr(i) = count_lmr(i)/lendatalmr;
            end
            
            %% Set histogram data
            
            self.set_cond_hist_left(probs_left);
            self.set_cond_hist_right(probs_right);
            self.set_cond_hist_lmr(probs_lmr);
            
        end
        
        function  get_inter_histograms(self)
%             


        %% Combine intertrial with the intertrials before it
            
            intertrial_data_left = [];
            intertrial_data_right = [];
            intertrial_data_lmr = [];
            
            for trial = 1:length(self.full_streamed_intertrials)
                
                intertrial_data_left = [intertrial_data_left self.full_streamed_intertrials{trial}{2}];
                intertrial_data_right = [intertrial_data_right self.full_streamed_intertrials{trial}{3}];
                intertrial_data_lmr = [intertrial_data_lmr self.full_streamed_intertrials{trial}{1}];
                
            end

%% Create histogram datasets for left wing, right wing, and lmr data. 
            lendataleft = length(intertrial_data_left); 
            lendataright = length(intertrial_data_right);
            lendatalmr = length(intertrial_data_lmr);
            count_left = [];
            probs_left = [];
            count_right = [];
            probs_right = [];
            count_lmr = [];
            probs_lmr = [];

            for i = 1:length(self.inter_hist_axis)-1
                count_left(i) = sum(intertrial_data_left()>=self.inter_hist_axis(i) & intertrial_data_left<=self.inter_hist_axis(i+1));
                count_right(i) = sum(intertrial_data_right()>=self.inter_hist_axis(i) & intertrial_data_right<=self.inter_hist_axis(i+1));
                count_lmr(i) = sum(intertrial_data_lmr()>=self.inter_lmr_axis(i) & intertrial_data_lmr<=self.inter_lmr_axis(i+1));
                probs_left(i) = count_left(i)/lendataleft;
                probs_right(i) = count_right(i)/lendataright;
                probs_lmr(i) = count_lmr(i)/lendatalmr;
            end
  
%% Set histogram data
            self.set_inter_left(probs_left);
            self.set_inter_right(probs_right);
            self.set_inter_lmr(probs_lmr);
%             
%             xax(1) = [];
%             xax_lmr(1) = [];
%             
%             self.set_inter_axis(xax);
%             self.set_inter_lmr_axis(xax_lmr);

        end
        
        function update_histogram_limits(self, newlimits)
           
            xax = newlimits(1):(newlimits(2)-newlimits(1))/100:newlimits(2);
            self.set_inter_axis(xax);
 
        end
        
        function update_lmr_limits(self, newlimits)
            
            xaxlmr = newlimits(1):(newlimits(2)-newlimits(1))/100:newlimits(2);
            self.set_inter_lmr(xaxlmr);
        end
        
        function add_bad_condition(self, cond, rep)
            
            badTrials = self.bad_trials;
            badTrials{end+1} = [cond, rep];
            self.set_bad_trials(badTrials);
            
            
        end
        
        function add_full_data(self, new_data, trialType)
            
            if strcmp(trialType, 'inter')
                fullData = self.full_streamed_intertrials;
                fullData{end+1} = new_data;
                self.set_full_intertrials(fullData);
            else
                fullData = self.full_streamed_conditions;
                fullData{end+1} = new_data;
                self.set_full_conditions(fullData);
            end

        end
        
        function num = calc_num_chans(self)
            
            num = 0;
            if self.ischan1 == 1
                num = num + 1;
            end
            if self.ischan2 == 1
                num = num + 1;
            end
            if self.ischan3 == 1
                num = num + 1;
            end
            if self.ischan4 == 1
                num = num + 1;
            end
        end
        
            
            
        
        
        function data = translate_data(self)
            
            raw = self.raw_data;
            
            if ~isempty(raw)
                label_idx1 = strfind(raw,'ms');
                label_idx2 = strfind(raw,'!S');

                if isempty(label_idx1) && ~isempty(label_idx2)
                   
                     raw = raw(1:label_idx2(end)-1);
                elseif ~isempty(label_idx1) && isempty(label_idx2)
                    raw = raw(label_idx1(1) + 2:end);
                elseif ~isempty(label_idx1) && ~isempty(label_idx2)
                    raw = raw(label_idx1(1) + 2:label_idx2(end)-1);
                end

                raw = mod(256 + raw, 256); %convert signed bytes to 0-255 char vals
                idx = 3;
                chan1 = [];
                chan2 = [];
                chan3 = [];
                chan4 = [];
                
                %channel 1 = LmR
                %channel 2 = Left wing
                %channel 3 = Right wing
                %channel 4 = WBF
                
                %The string returned with tcpread, after converted to signed bytes, follows
                %the following pattern: [junk junk chan1 chan1 chan2 chan2 chan3 chan3
                %chan4 chan4 junk junk chan1 chan1 etc...]. Any channels not being streamed are
                %just removed from the pattern. The "junk" numbers are always 5 and 20 and
                %I think are some kind of delineator.
                
                while idx < length(raw)
                    
                    if self.ischan1
                    %convert 2 ADC0 bytes into 8-bit voltage double (-10 to +10)
                        chan1(end+1) = double(typecast(uint8(raw(idx:idx+1)),'int16'))/3276.75; 
                        idx = idx + 2;            
                    end

                    if self.ischan2
                        if idx < length(raw)
                            chan2(end+1) = double(typecast(uint8(raw(idx:idx+1)),'int16'))/3276.75;
                            idx = idx + 2;
                        end
                    end



                    if self.ischan3
                        if idx < length(raw)
                            chan3(end+1) = double(typecast(uint8(raw(idx:idx+1)),'int16'))/3276.75;
                            idx = idx + 2;
                        end
                    end


                    if self.ischan4
                        if idx < length(raw)
                            chan4(end+1) = double(typecast(uint8(raw(idx:idx+1)),'int16'))/3276.75;
                            idx = idx + 2;
                        end
                    end
        
                    idx = idx + 2;
                end
                
                data{1} = chan1;
                data{2} = chan2;
                data{3} = chan3;
                data{4} = chan4;
                
            else
                
                data = raw;
            end

            
        end
        
        %% Setters
        
        function set_raw_data(self, input)
            
            self.raw_data = input;
        end
        function set_translated_data(self, input)
            self.translated_data = input; 
        end
        function set_wbf_data(self, input)
            self.wbf_data = input;
        end
        function set_lmr_data(self, input)
            self.lmr_data = input;
        end
        function set_l_data(self, input)
            self.l_data = input;
        end
        function set_r_data(self, input)
            self.r_data = input;
        end
        function set_bad_trials(self, input)
            self.bad_trials = input;
        end
        function set_full_intertrials(self, input)
            self.full_streamed_intertrials = input;
        end
        function set_full_conditions(self, input)
            self.full_streamed_conditions = input;
        end
        function set_avg_wbf(self, input)
            self.avg_wbf = input;
        end
        function set_inter_left(self, input)
            self.inter_hist_left = input;
        end
        function set_inter_right(self, input)
            self.inter_hist_right = input;
        end
        function set_inter_lmr(self, input)
            self.inter_hist_lmr = input;
        end
        function set_inter_axis(self, input)
            self.inter_hist_axis = input;
        end
        function set_inter_lmr_axis(self, input)
            self.inter_lmr_axis = input;
        end
        function set_cond_hist_axis(self, input)
            self.cond_hist_axis = input;
        end
        function set_cond_hist_left(self, input)
            self.cond_hist_left = input;
        end
        function set_cond_hist_right(self, input)
            self.cond_hist_right = input;
        end
        function set_cond_hist_lmr(self, input)
            self.cond_hist_lmr = input;
        end
        function set_wbf_limits(self, input)
            self.wbf_limits = input;
        end
        
        
        function set_num_chans(self, input)
            if input<4
                self.num_chans = input;
            else
                disp("There are only 4 channels but attempted to set feedback_model.num_chans to more than 4. Update to this variable failed.");
            end
        end
        
        function set_chan1(self, input)
            if input==0 || input==1
                self.ischan1 = input;
            else
                disp("feedback_model.ischan1 must equal 0 or 1. Update to this variable failed.");
            end
        end
        
        function set_chan2(self, input)
            
            if input==0 || input==1
                self.ischan2 = input;
            else
                disp("feedback_model.ischan2 must equal 0 or 1. Update to this variable failed.");
            end
        end
        
        function set_chan3(self, input)
            if input==0 || input==1
                self.ischan3 = input;
            else
                disp("feedback_model.ischan3 must equal 0 or 1. Update to this variable failed.");
            end
        end
        
        function set_chan4(self, input)
            if input==0 || input==1
                self.ischan4 = input;
            else
                disp("feedback_model.ischan4 must equal 0 or 1. Update to this variable failed.");
            end
        end
        
        

        
        
        %% Getters
        
        function output = get_raw_data(self)
            output = self.raw_data;
        end
        function output = get_translated_data(self)
            output = self.translated_data;
        end
        function output = get_lmr_data(self)
            output = self.lmr_data;
        end
        function output = get_l_data(self)
            output = self.l_data;
        end
        function output = get_r_data(self)
            output = self.r_data;
        end
        
        function output = get_wbf_data(self)
            output = self.wbf_data;
        end
        function output = get_bad_trials(self)
            output = self.bad_trials;
        end
        function output = get_full_intertrials(self)
            output = self.full_streamed_intertrials;
        end
        function output = get_full_conditions(self)
            output = self.full_streamed_conditions;
        end
        function output = get_num_chans(self)
            output = self.num_chans;
        end
         function output = get_chan1(self)
            output = self.ischan1;
        end
        function output = get_chan2(self)
            output = self.ischan2;
        end
        function output = get_chan3(self)
            output = self.ischan3;
        end
        function output = get_chan4(self)
            output = self.ischan4;
        end
        function output = get_avg_wbf(self)
            output = self.avg_wbf;
        end
        function output = get_inter_left(self)
            output = self.inter_hist_left;
        end
        function output = get_inter_right(self)
            output = self.inter_hist_right;
        end
        function output = get_inter_lmr(self)
            output = self.inter_hist_lmr;
        end
        function output = get_inter_axis(self)
            output = self.inter_hist_axis;
        end
        function output = get_inter_lmr_axis(self)
            output = self.inter_lmr_axis;
        end
        function output = get_cond_hist_axis(self)
            output = self.cond_hist_axis;
        end
        function output = get_cond_hist_left(self)
            output = self.cond_hist_left;
        end
        function output = get_cond_hist_right(self)
            output = self.cond_hist_right;
        end
        function output = get_cond_hist_lmr(self)
            output = self.cond_hist_lmr;
        end
        function output = get_wbf_lim(self)
            output = self.wbf_limits;
        end

        
    end
    
end