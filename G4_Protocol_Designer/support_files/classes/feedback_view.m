classdef feedback_view < handle
    
    
    properties
        
        panel
        wbf_alarm
        min_wbf
        position_center
        openLoop_axis
        closeLoop_axis
        wbf_axis
        avg_wbf
        badTrials
        badConds
        badReps
        trial_label
        cond_label
        rep_label
        runcon
        current_trial
        
        
        
        
        
    end
    
    methods
        
        function self = feedback_view(con, placement)
            
            fig = con.view.fig();
            fig_size = con.view.fig_size();
            self.runcon = con;
            self.min_wbf = con.fb_model.get_wbf_lim();
            self.current_trial = 1;
            
           
            self.panel = uipanel(fig, 'Title', 'Data Monitoring', 'Fontsize', 11, ...
                'units', 'pixels', 'Position', [placement fig_size(3)*.37, fig_size(4)-15]);
            
            wbf_label = uicontrol(self.panel, 'Style', 'text', 'String', 'Last trial avg WBF:', ...
                'FontSize', 9, 'HorizontalAlignment', 'center', 'units', ...
                'normalized', 'Position', [.02, .9, .2, .05]);
            self.avg_wbf = uicontrol(self.panel, 'Style','text','String', string(con.fb_model.avg_wbf), ...
                'FontSize', 11, 'HorizontalAlignment', 'center', 'units', ...
                'normalized', 'Position', [.25, .9, .1, .05]);
            bad_trials_label = uicontrol(self.panel, 'Style', 'text', 'String', ...
                'Bad Trials/Conditions:', 'FontSize', 9, 'HorizontalAlignment', ...
                'center', 'units', 'normalized', 'Position', [.4,.9,.23,.05]);
            self.trial_label = uicontrol(self.panel, 'Style', 'text', 'String', 'Trial', ...
                'HorizontalAlignment', 'center', 'units', 'normalized', 'Position', [.65, .93, .06, .05]);
            self.cond_label = uicontrol(self.panel, 'Style', 'text', 'String', 'Condition', ...
                'HorizontalAlignment', 'center', 'units', 'normalized', 'Position', [.72, .93, .12, .05]);
            self.rep_label = uicontrol(self.panel, 'Style', 'text', 'String', 'Repetition', ...
                'HorizontalAlignment', 'center', 'units', 'normalized', 'Position', [.85, .93, .14, .05]);
            
            self.badTrials{1} = uicontrol(self.panel, 'Style', 'text', 'String', '', ...
                'HorizontalAlignment', 'center', 'units', 'normalized', 'Position', ...
                [self.trial_label.Position(1), self.trial_label.Position(2) - .05, .03, .04]);
            
            self.badConds{1} = uicontrol(self.panel, 'Style', 'text', 'String', '', ...
                'HorizontalAlignment', 'center', 'units', 'normalized', 'Position', ...
                [self.cond_label.Position(1), self.cond_label.Position(2) - .05, .03, .04]);
            
            self.badReps{1} = uicontrol(self.panel, 'Style', 'text', 'String', '', ...
                'HorizontalAlignment', 'center', 'units', 'normalized', 'Position', ...
                [self.rep_label.Position(1), self.rep_label.Position(2) - .05, .03, .04]);
            
            
            self.openLoop_axis = axes(self.panel, 'units','normalized', 'Position', [.1, .67, .5 ,.2]);
            self.closeLoop_axis = axes(self.panel, 'units', 'normalized', 'Position', [.1, .37, .5, .2]);
            self.wbf_axis = axes(self.panel, 'units', 'normalized', 'Position', [.1, .07, .8, .2]);
            
            self.wbf_axis.YAxis.Limits = [0 3];

%             self.openLoop_axis.YTickLabel = [];
%             self.openLoop_axis.YTick = [];
%            self.openLoop_axis.XAxis.Limits = [-180 180];
%            xline(self.openLoop_axis, 0);
%            hold on;
            

        end
        
          function clear_view(self, model)
        
            set(self.avg_wbf, 'String',string(round(model.avg_wbf,4)));
            
            
            for label = 1:length(self.badTrials)
                self.badTrials{label}.String = '';
                self.badConds{label}.String = '';
                self.badReps{label}.String = '';
            end
                       
            self.badTrials = {};
            self.badConds = {};
            self.badReps = {};
            self.current_trial = 1;
            
            self.badTrials{1} = uicontrol(self.panel, 'Style', 'text', 'String', '', ...
                'HorizontalAlignment', 'center', 'units', 'normalized', 'Position', ...
                [self.trial_label.Position(1), self.trial_label.Position(2) - .07, .03, .06]);
            
            self.badConds{1} = uicontrol(self.panel, 'Style', 'text', 'String', '', ...
                'HorizontalAlignment', 'center', 'units', 'normalized', 'Position', ...
                [self.cond_label.Position(1), self.cond_label.Position(2) - .07, .03, .06]);
            
            self.badReps{1} = uicontrol(self.panel, 'Style', 'text', 'String', '', ...
                'HorizontalAlignment', 'center', 'units', 'normalized', 'Position', ...
                [self.rep_label.Position(1), self.rep_label.Position(2) - .07, .03, .06]);
            
            
            cla(self.openLoop_axis);
            cla(self.closeLoop_axis);
            cla(self.wbf_axis);
%            xline(self.openLoop_axis,0);
 %           hold on;
            drawnow;
            
        end
        
        
        
        function update_feedback_view(self, model, trialType, trialinfo, bad_slope, bad_flier)
            
           set(self.avg_wbf, 'String', string(round(model.avg_wbf,4)));
            
            if ~strcmp(trialType, 'inter')
            
                %trialinfo = [trial number, condition number, rep number]
                
                %Set if it was a bad condition
            
                if bad_slope == 1 || bad_flier == 1
                    self.badTrials{end}.String = string(trialinfo(1));
                    self.badConds{end}.String = string(trialinfo(2));
                    self.badReps{end}.String = string(trialinfo(3));
                    
                    self.badTrials{end+1} = uicontrol(self.panel, 'Style', 'text', 'String', '', ...
                        'HorizontalAlignment', 'center', 'units', 'normalized', 'Position', ...
                        [self.badTrials{end}.Position(1), self.badTrials{end}.Position(2) - .05, .03, .04]);
                    
                    self.badConds{end+1} = uicontrol(self.panel, 'Style', 'text', 'String', '', ...
                        'HorizontalAlignment', 'center', 'units', 'normalized', 'Position', ...
                        [self.badConds{end}.Position(1), self.badConds{end}.Position(2) - .05, .03, .04]);
                    
                    self.badReps{end+1} = uicontrol(self.panel, 'Style', 'text', 'String', '', ...
                        'HorizontalAlignment', 'center', 'units', 'normalized', 'Position', ...
                        [self.badReps{end}.Position(1), self.badReps{end}.Position(2) - .05, .03, .04]);
                    
                    trialNum = length(model.full_streamed_intertrials) + length(model.full_streamed_conditions);
                    self.runcon.add_bad_trial_marker_progress(trialNum);
                    
                end
                
                % Plot the conditions histogram
                
                cla(self.closeLoop_axis);
                
                self.closeLoop_axis.XAxis.Limits = [model.cond_hist_axis(1) model.cond_hist_axis(end)];
                cond_xax = model.cond_hist_axis;
                cond_xax(1) = [];
                
                plot(self.closeLoop_axis, cond_xax, model.cond_hist_left, 'Color', 'r');
                hold(self.closeLoop_axis, 'on');
                plot(self.closeLoop_axis, cond_xax, model.cond_hist_right, 'Color', 'b');
                
                ylabel(self.closeLoop_axis, "Probability");
                xlabel(self.closeLoop_axis, "Volts")
                legend(self.closeLoop_axis, "Left Wing", "Right Wing", 'Location', 'northeast');
                title(self.closeLoop_axis, 'Conditions Histogram');
                hold(self.closeLoop_axis, 'on')
                
                num_trials = self.runcon.get_num_trials();
                self.wbf_axis.XAxis.Limits = [0 num_trials];
                plot(self.wbf_axis, self.current_trial, model.avg_wbf, '.', 'Color', 'k', 'MarkerSize', 12);
                hold(self.wbf_axis, 'on');
                yline(self.wbf_axis, self.min_wbf{1}(1)/100);
                ylabel(self.wbf_axis, "WBF");
                xlabel(self.wbf_axis, "Trial");
                legend(self.wbf_axis, "Conditions", "Minimum", "Intertrials", 'Location', 'south');
                title(self.wbf_axis, 'Wing Beat Frequency per Trial');
                self.current_trial = self.current_trial + 1;
                hold(self.wbf_axis, 'on');
                
            else
                
                cla(self.openLoop_axis);
                
                self.openLoop_axis.XAxis.Limits = [model.inter_hist_axis(1), model.inter_hist_axis(end)];
                
                
%                 peak_left = max(model.inter_hist_left);
%                 idxLeft = find(model.inter_hist_left == max(model.inter_hist_left));
%                 xpoint_left = model.inter_hist_axis(idxLeft);
%                 peak_right = max(model.inter_hist_right);
%                 idxRight = find(model.inter_hist_right == max(model.inter_hist_right));
%                 xpoint_right = model.inter_hist_axis(idxRight);
                inter_xax = model.inter_hist_axis;
                inter_xax(1) = [];
                
                plot(self.openLoop_axis, inter_xax, model.inter_hist_left, 'Color', 'r');
                hold(self.openLoop_axis, 'on');
                plot(self.openLoop_axis, inter_xax, model.inter_hist_right, 'Color', 'b');
                %hold on;
                ylabel(self.openLoop_axis, "Probability");
                xlabel(self.openLoop_axis, "Volts");
                legend(self.openLoop_axis, "Left Wing", "Right Wing", 'Location', 'northeast');
                title(self.openLoop_axis, 'Intertrials Histogram');
                hold(self.openLoop_axis, 'on');
                
                num_trials = self.runcon.get_num_trials();
                self.wbf_axis.XAxis.Limits = [0 num_trials];
                plot(self.wbf_axis, self.current_trial, model.avg_wbf, '.', 'Color', 'r', 'MarkerSize', 12);
                hold(self.wbf_axis, 'on');
                yline(self.wbf_axis, self.min_wbf{1}(1)/100);
                ylabel(self.wbf_axis, "WBF");
                xlabel(self.wbf_axis, "Trial");
                legend(self.wbf_axis, "Conditions", "Minimum", "Intertrials", 'Location', 'south');
                title(self.wbf_axis, 'Wing Beat Frequency per Trial');
                self.current_trial = self.current_trial + 1;
                hold(self.wbf_axis, 'on');
                
            end
                
               
            
            
                
      
            
                
           
            
        end
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
    end
    
    
end
