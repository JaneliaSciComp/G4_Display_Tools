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
        OL_custom_function
        CL_custom_function
        
        bad_trials
        bad_trials_before_reruns
        full_streamed_intertrials
        full_streamed_conditions
        
        full_inter_left
        full_inter_right
        full_inter_lmr
        
        full_conds_left
        full_conds_right       
        full_conds_lmr
        
        full_inter_left_count
        full_inter_right_count
        full_inter_lmr_count
        
        full_conds_left_count
        full_conds_right_count
        full_conds_lmr_count
        
        
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
            self.full_inter_left = [];
            self.full_inter_right = [];
           
            self.full_inter_lmr = [];       
            self.full_conds_left = [];
            self.full_conds_right = [];           
            self.full_conds_lmr = [];
            
            self.inter_hist_axis = 0:.1:10;
            self.inter_lmr_axis = 0:.1:10;
            self.cond_hist_axis = 0:.1:10;
            
            self.full_conds_lmr_count = zeros(1,length(self.cond_hist_axis)-1);
            self.full_conds_left_count = zeros(1,length(self.cond_hist_axis)-1);
            self.full_conds_right_count = zeros(1,length(self.cond_hist_axis)-1);
            
            self.full_inter_left_count = zeros(1, length(self.inter_hist_axis)-1);
            self.full_inter_right_count = zeros(1, length(self.inter_hist_axis)-1);
            self.full_inter_lmr_count = zeros(1, length(self.inter_hist_axis)-1);

            self.CL_custom_function = '';
            self.OL_custom_function = '';
            
            self.bad_trials = {};
            self.bad_trials_before_reruns = {};
            self.lmr_data = [];
            self.l_data = [];
            self.r_data = [];
            self.wbf_data = [];
            self.avg_wbf = 0;
            self.update_model_channels(doc);  
            
            self.cond_hist_left = zeros(1,length(self.cond_hist_axis)-1);
            self.cond_hist_right = zeros(1,length(self.cond_hist_axis)-1);
            self.cond_hist_lmr = zeros(1, length(self.cond_hist_axis)-1);
            self.inter_hist_left = zeros(1, length(self.inter_hist_axis)-1);
            self.inter_hist_right = zeros(1, length(self.inter_hist_axis)-1);
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
            
            %Save the raw data in case you want it later
            self.set_raw_data(tcp_read_data);
            
            %translate the data from binary and save it
            
            self.set_translated_data(self.translate_data());
            
            %save full translated, divided up data
            self.add_full_data(trialType);
            
            %save each stream to its own variable
            self.set_lmr_data(self.translated_data{1});
            self.set_l_data(self.translated_data{2});
            self.set_r_data(self.translated_data{3});
            self.set_wbf_data(self.translated_data{4});
            
            %get and save the average wbf for this dataset
            self.set_avg_wbf(mean(self.wbf_data));

            % If they have their own custom functions to determine the data
            % for the OL and CL axes, we should run it here INTEAD Of
            % get_histogram_count and get_histograms, which together
            % create the data to be plotted by default. 

            if isempty(self.CL_custom_function) && isempty(self.OL_custom_function)
            
                %Get the counts of each voltage reading for histogram for this
                %trial, and add it to the previous totals
                self.get_histogram_count(trialType);
                
                %Divide the total counts for each voltage reading by number of
                %readings to get probability of each. This is the histogram
                %data to be plotted
                self.get_histograms(trialType);
            elseif ~isempty(self.CL_custom_function) && ~isempty(self.OL_custom_function)

                % run custom functions. Custom functions must take in one 
                % variable, the translated data that was collected from a
                % single condition. It is laid out like so: 

                % data{1} = channel 1 data (LmR)
                % data{2} = channel 2 data (Left wing)
                % data{3} = channel 3 data (right wing)
                % data{4} = channel 4 data (wbf)

                % Each cell element is an array of numbers, size 1 x number of datapoints
                % streamed for that condition

                % The function must return two 1 x some number arrays. The
                % first should be the plot's ydata for the left wing, and
                % the second should be the plot's ydata for the right wing.
                % To save time, the axis and lines are created at the
                % beginning, and only the Ydata of the lines are updated
                % after each condition.

                self.run_custom_function(1,1);

            elseif isempty(self.CL_custom_function) && ~isempty(self.OL_custom_function)

                % Run default histogram stuff to get CL axis data, then run
                % custom OL function and replace the OL axis data with
                % its output

                self.get_histogram_count(trialType);
                self.get_histograms(trialType);

                % run custom OL function
                self.run_custom_function(1, 0)

            else

                % Run default histogram stuff to get OL axis data, then run
                % custom CL function and replace the CL axis data with
                % its output

                self.get_histogram_count(trialType);
                self.get_histograms(trialType);

                % run custom CL function
                self.run_custom_function(0,1);

            end
            
            
        
        end

        function run_custom_function(self, ol, cl)
            
            if ol
                data = self.translated_data;
                [~, OLfuncName] = fileparts(self.OL_custom_function);
                [ol_leftWing, ol_rightWing] = feval(OLfuncName, data);
                self.set_inter_left(ol_leftWing);
                self.set_inter_right(ol_rightWing);
            end
            if cl
                 data = self.translated_data;
                 [~, CLfuncName] = fileparts(self.CL_custom_function);
                [cl_leftWing, cl_rightWing] = feval(CLfuncName, data);
                self.set_cond_hist_left(cl_leftWing);
                self.set_cond_hist_right(cl_rightWing);
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

                if ~strcmp(trialType, 'rescheduled')
                    if cond_flat == 1 || bad_flier == 1
                        self.add_bad_condition(cond, rep);
                    end
                end
                
            end
            
        end
        

        
        function get_histogram_count(self, trialType)
            
            new_data = self.translated_data; 
            
            new_data_lmr = new_data{1};
            new_data_left = new_data{2};
            new_data_right = new_data{3};          

            count_left = [];
            count_right = [];
            count_lmr = [];
            
            if ~strcmp(trialType, 'inter')
                for i = 1:length(self.cond_hist_axis)-1
                    count_left(i) = sum(new_data_left()>=self.cond_hist_axis(i) & new_data_left<self.cond_hist_axis(i+1));
                    count_right(i) = sum(new_data_right()>=self.cond_hist_axis(i) & new_data_right<self.cond_hist_axis(i+1));
                    count_lmr(i) = sum(new_data_lmr()>=self.cond_hist_axis(i) & new_data_lmr<self.cond_hist_axis(i+1));
    %                 probs_left(i) = count_left(i)/lendataleft;
    %                 probs_right(i) = count_right(i)/lendataright;
    %                 probs_lmr(i) = count_lmr(i)/lendatalmr;
                end

                self.full_conds_left_count = self.full_conds_left_count + count_left;
                self.full_conds_right_count = self.full_conds_right_count + count_right;
                self.full_conds_lmr_count = self.full_conds_lmr_count + count_lmr;
                
            else
                for i = 1:length(self.inter_hist_axis)-1
                    count_left(i) = sum(new_data_left()>=self.inter_hist_axis(i) & new_data_left<self.inter_hist_axis(i+1));
                    count_right(i) = sum(new_data_right()>=self.inter_hist_axis(i) & new_data_right<self.inter_hist_axis(i+1));
                    count_lmr(i) = sum(new_data_lmr()>=self.inter_hist_axis(i) & new_data_lmr<self.inter_hist_axis(i+1));
    %                 probs_left(i) = count_left(i)/lendataleft;
    %                 probs_right(i) = count_right(i)/lendataright;
    %                 probs_lmr(i) = count_lmr(i)/lendatalmr;
                end

                self.full_inter_left_count = self.full_inter_left_count + count_left;
                self.full_inter_right_count = self.full_inter_right_count + count_right;
                self.full_inter_lmr_count = self.full_inter_lmr_count + count_lmr;
                
            end    
            
        end
        
        function get_histograms(self, trialType)
           
            if ~strcmp(trialType, 'inter')
               probs_left = self.full_conds_left_count/length(self.full_conds_left);
               probs_right = self.full_conds_right_count/length(self.full_conds_right);
               probs_lmr = self.full_conds_lmr_count/length(self.full_conds_lmr);

                %% Set histogram data

                self.set_cond_hist_left(probs_left);
                self.set_cond_hist_right(probs_right);
                self.set_cond_hist_lmr(probs_lmr);
                
            else
                
                probs_left = self.full_inter_left_count/length(self.full_inter_left);
                probs_right = self.full_inter_right_count/length(self.full_inter_right);
                probs_lmr = self.full_inter_lmr_count/length(self.full_inter_lmr);
                
                self.set_inter_left(probs_left);
                self.set_inter_right(probs_right);
                self.set_inter_lmr(probs_lmr);
                
            end
            
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
        
        function remove_bad_condition(self, rep, cond)
            element = 0;
            for bad = 1:numel(self.bad_trials)
                if self.bad_trials{bad} == [cond, rep]
                    element = bad;
                end
            end
            
            if element ~= 0
                self.bad_trials(element) = [];
            end
        end
        
        function add_full_data(self, trialType)
            
             %channel 1 = LmR
                %channel 2 = Left wing
                %channel 3 = Right wing
                %channel 4 = WBF
                
            new_data = self.translated_data;
            
            if strcmp(trialType, 'inter')
                fullData = self.full_streamed_intertrials;
                fullData{end+1} = new_data;
                self.set_full_intertrials(fullData);
                
                self.full_inter_left = [self.full_inter_left new_data{2}];
                self.full_inter_right = [self.full_inter_right new_data{3}];              
                self.full_inter_lmr = [self.full_inter_lmr new_data{1}];
            else
                fullData = self.full_streamed_conditions;
                fullData{end+1} = new_data;
                self.set_full_conditions(fullData);
                
                self.full_conds_left = [self.full_conds_left new_data{2}];
                self.full_conds_right = [self.full_conds_right new_data{3}];
                self.full_conds_lmr = [self.full_conds_lmr new_data{1}];
                
                
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
%                label_idx2 = strfind(raw,'!S');
 
%                 if isempty(label_idx1) && ~isempty(label_idx2)
%                    
%                      raw = raw(1:label_idx2(end)-1);
%                 elseif ~isempty(label_idx1) && isempty(label_idx2)
%                     raw = raw(label_idx1(1) + 2:end);
%                 elseif ~isempty(label_idx1) && ~isempty(label_idx2)
%                     raw = raw(label_idx1(1) + 2:label_idx2(end)-1);
%                 end
 
                if ~isempty(label_idx1)
                    raw = raw(label_idx1(1) + 2:end);
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
        
        % Do this after the main conditions of the protocol are finished
        % but before any bad trials are re-run. Do it again after each full re-run attempt 
        % so any conditions rescheduled more than once are reflected the correnct number of times.
        % Done in the run protocol
        function set_bad_trials_before_reruns(self)
            self.bad_trials_before_reruns = [self.bad_trials_before_reruns self.bad_trials];
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

        function set_OL_analysis(self, input)
            self.OL_custom_function = input;
        end

        function set_CL_analysis(self, input)
            self.CL_custom_function = input;
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
        function output = get_bad_trials_before_reruns(self)
            output = self.bad_trials_before_reruns;
        end
        function output = get_OL_function(self)
            output = self.OL_custom_function;
        end
        function output = get_CL_function(self)
            output = self.CL_custom_function;
        end

        
    end
    
end