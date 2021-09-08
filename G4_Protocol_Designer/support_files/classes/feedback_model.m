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
        inter_hist_axis
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
            self.inter_hist_axis = 2.5:.05:7.5;
            self.inter_lmr_axis = 2.5:.05:7.5;
            self.wbf_limits{1} = [150 260];
            self.wbf_limits{2} = .25;
            self.wbf_limits{3} = 1; 
            
            % Load processing settings to get wbf_range?
            
        end
        
        function clear_model(self)
            
        end
        
        function update_model_channels(self, doc)
            
            self.ischan1 = doc.is_chan1;
            self.ischan2 = doc.is_chan2;
            self.ischan3 = doc.is_chan3;
            self.ischan4 = doc.is_chan4;
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
                self.get_wing_histograms();
            end
                
            
        
        end
        
        function get_wbf_limits(self, processing_path)
           
            S = load(processing_path);
            if isfield(S, settings)
                self.wbf_limits{1} = S.settings.wbf_range;
                self.wbf_limits{2} = S.settings.wbf_cutoff;
                self.wbf_limits{3} = S.settings.wbf_end_percent;
                
            end
            
        end
        
        function [cond_flat, bad_flier] = check_if_bad(self, cond, rep, trialType)
           
              % Check if condition is flat
            
            bad_flier = 0;
            cond_flat = 0;
            
            if ~strcmp(trialType, 'inter')
            
                for ind = 1:length(self.lmr_data)-1
                    diff(ind) = self.lmr_data(ind + 1) - self.lmr_data(ind);
                end
                if diff == 0
                    cond_flat = 1;
                end

                if self.avg_wbf < self.wbf_limits{1}(1)/1000
                    bad_flier = 1;
                end
                
                count_low_wbf = sum(self.wbf_data()<self.wbf_limits{1}(1)/1000);
                if (count_low_wbf/length(self.wbf_data)) > self.wbf_limits{2}
                    bad_flier = 1;
                end


                if cond_flat == 1 || bad_flier == 1
                    self.add_bad_condition(cond, rep);
                end
                
            end
            
            
            
            
        end
        
        function  get_wing_histograms(self)
%             
%             minleft = min(self.l_data);
%             maxleft = max(self.l_data);
%             minright = min(self.r_data);
%             maxright = max(self.r_data);
%             minlmr = min(self.lmr_data);
%             maxlmr = max(self.lmr_data);
% 
%             if minleft < minright
%                 mintot = minleft;
%             else
%                mintot = minright; 
%             end
% 
%             if maxleft > maxright
%                 maxtot = maxleft;
%             else
%                 maxtot = maxright;
%             end
% 
%             xax = mintot:(maxtot-mintot)/100:maxtot;
%             xax_lmr = minlmr:(maxlmr-minlmr)/100:maxlmr;

        %% Average the new left and right wing data with the intertrials before it
            
        %get the length of the longest intertrial so far
            longest_int_left = length(self.full_streamed_intertrials{1}{2});
            longest_int_right = length(self.full_streamed_intertrials{1}{3});
            longest_int_lmr = length(self.full_streamed_intertrials{1}{1});
            for int = 1:size(self.full_streamed_intertrials,2)
                templenleft = length(self.full_streamed_intertrials{int}{2});
                templenright = length(self.full_streamed_intertrials{int}{3});
                templenlmr = length(self.full_streamed_intertrials{int}{1});
                if templenleft > longest_int_left
                    longest_int_left = templenleft;
                end
                if templenright > longest_int_right
                    longest_int_right = templenright;
                end
                if templenlmr > longest_int_lmr
                    longest_int_lmr = templenlmr;
                end
            end
        % add Nans to all shorter intertrials so that they are all the same
        % length
            for trial = 1:size(self.full_streamed_intertrials,2)
                if length(self.full_streamed_intertrials{trial}{2}) < longest_int_left
                    self.full_streamed_intertrials{trial}{2}(end+1:longest_int_left) = NaN;
                end
                if length(self.full_streamed_intertrials{trial}{3}) < longest_int_right
                    self.full_streamed_intertrials{trial}{3}(end+1:longest_int_right) = NaN;
                end
                if length(self.full_streamed_intertrials{trial}{1}) < longest_int_lmr
                    self.full_streamed_intertrials{trial}{1}(end+1:longest_int_lmr) = NaN;
                end
            end
        
         % move adjusted intertrials from cell array to regular array
         
            for t = 1:size(self.full_streamed_intertrials,2)
                temp_intertrials_left(t,:) = self.full_streamed_intertrials{t}{2};
                temp_intertrials_right(t,:) = self.full_streamed_intertrials{t}{3};
                temp_intertrials_lmr(t,:) = self.full_streamed_intertrials{t}{1};
            end
            
         % Average all intertrials
         
            intertrial_data_left = nanmean(temp_intertrials_left,1);
            intertrial_data_right = nanmean(temp_intertrials_right,1);
            intertrial_data_lmr = nanmean(temp_intertrials_lmr,1);
         
%             if length(self.l_data) ~= length(self.r_data)
%                 disp('warning: left and right wing data are different lengths. Cannot plot both histograms.');
%                 probs_left = [];
%                 probs_right = [];
%                 probs_lmr = [];
%                 return;
%             end

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
                    raw = raw(1:label_idx2(2)-1);
                elseif ~isempty(label_idx1) && isempty(label_idx2)
                    raw = raw(label_idx1(1) + 2:end);
                elseif ~isempty(label_idx1) && ~isempty(label_idx2)
                    raw = raw(label_idx1(1) + 2:label_idx2(2)-1);
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
                        chan1(end+1) = double(typecast(uint8(raw(idx:idx+1)),'int16'))/6553.5; 
                        idx = idx + 2;            
                    end
        
                    if self.ischan2
                        chan2(end+1) = double(typecast(uint8(raw(idx:idx+1)),'int16'))/6553.5;
                        idx = idx + 2;
                    end
        
                    if self.ischan3
                        chan3(end+1) = double(typecast(uint8(raw(idx:idx+1)),'int16'))/6553.5;
                        idx = idx + 2;
                    end
        
                    if self.ischan4
                        chan4(end+1) = double(typecast(uint8(raw(idx:idx+1)),'int16'))/6553.5;
                        idx = idx + 2;
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
        
        
    end
    
end