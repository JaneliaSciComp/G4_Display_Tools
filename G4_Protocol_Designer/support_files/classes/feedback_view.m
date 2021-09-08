classdef feedback_view < handle
    
    
    properties
        
        panel
        wbf_alarm
        min_wbf
        position_center
        position_axis
        avg_wbf
        badTrials
        badConds
        badReps
        trial_label
        cond_label
        rep_label
        
        
        
        
        
    end
    
    methods
        
        function self = feedback_view(con, placement)
            
            fig = con.view.fig();
            fig_size = con.view.fig_size();
            
           
            self.panel = uipanel(fig, 'Title', 'Data Monitoring', 'Fontsize', 11, ...
                'units', 'pixels', 'Position', [placement fig_size(3) - 30, fig_size(4) *.3]);
            
            wbf_label = uicontrol(self.panel, 'Style', 'text', 'String', 'Last trial avg WBF:', ...
                'FontSize', 11, 'HorizontalAlignment', 'center', 'units', ...
                'normalized', 'Position', [.02, .85, .2, .1]);
            self.avg_wbf = uicontrol(self.panel, 'Style','text','String', string(con.fb_model.avg_wbf), ...
                'FontSize', 11, 'HorizontalAlignment', 'center', 'units', ...
                'normalized', 'Position', [.25, .85, .1, .1]);
            bad_trials_label = uicontrol(self.panel, 'Style', 'text', 'String', ...
                'Bad Trials/Conditions:', 'FontSize', 11, 'HorizontalAlignment', ...
                'center', 'units', 'normalized', 'Position', [.04,.68,.23,.1]);
            self.trial_label = uicontrol(self.panel, 'Style', 'text', 'String', 'Trial', ...
                'HorizontalAlignment', 'center', 'units', 'normalized', 'Position', [.27, .75, .03, .1]);
            self.cond_label = uicontrol(self.panel, 'Style', 'text', 'String', 'Condition', ...
                'HorizontalAlignment', 'center', 'units', 'normalized', 'Position', [.31, .75, .06, .1]);
            self.rep_label = uicontrol(self.panel, 'Style', 'text', 'String', 'Repetition', ...
                'HorizontalAlignment', 'center', 'units', 'normalized', 'Position', [.38, .75, .07, .1]);
            
            self.badTrials{1} = uicontrol(self.panel, 'Style', 'text', 'String', '', ...
                'HorizontalAlignment', 'center', 'units', 'normalized', 'Position', ...
                [self.trial_label.Position(1), self.trial_label.Position(2) - .07, .03, .06]);
            
            self.badConds{1} = uicontrol(self.panel, 'Style', 'text', 'String', '', ...
                'HorizontalAlignment', 'center', 'units', 'normalized', 'Position', ...
                [self.cond_label.Position(1), self.cond_label.Position(2) - .07, .03, .06]);
            
            self.badReps{1} = uicontrol(self.panel, 'Style', 'text', 'String', '', ...
                'HorizontalAlignment', 'center', 'units', 'normalized', 'Position', ...
                [self.rep_label.Position(1), self.rep_label.Position(2) - .07, .03, .06]);
            
            
            self.position_axis = axes(self.panel, 'units','normalized', 'Position', [.5, .3, .45 ,.4]);
%             self.position_axis.YTickLabel = [];
%             self.position_axis.YTick = [];
%            self.position_axis.XAxis.Limits = [-180 180];
%            xline(self.position_axis, 0);
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
            
            self.badTrials{1} = uicontrol(self.panel, 'Style', 'text', 'String', '', ...
                'HorizontalAlignment', 'center', 'units', 'normalized', 'Position', ...
                [self.trial_label.Position(1), self.trial_label.Position(2) - .07, .03, .06]);
            
            self.badConds{1} = uicontrol(self.panel, 'Style', 'text', 'String', '', ...
                'HorizontalAlignment', 'center', 'units', 'normalized', 'Position', ...
                [self.cond_label.Position(1), self.cond_label.Position(2) - .07, .03, .06]);
            
            self.badReps{1} = uicontrol(self.panel, 'Style', 'text', 'String', '', ...
                'HorizontalAlignment', 'center', 'units', 'normalized', 'Position', ...
                [self.rep_label.Position(1), self.rep_label.Position(2) - .07, .03, .06]);
            
            
            cla(self.position_axis);
%            xline(self.position_axis,0);
 %           hold on;
            drawnow;
            
        end
        
        
        
        function update_feedback_view(self, model, trialType, trialinfo, bad_slope, bad_flier)
            
           set(self.avg_wbf, 'String', string(round(model.avg_wbf,4)));
            
            if ~strcmp(trialType, 'inter')
            
                %trialinfo = [trial number, condition number, rep number]
            
                if bad_slope == 1 || bad_flier == 1
                    self.badTrials{end}.String = string(trialinfo(1));
                    self.badConds{end}.String = string(trialinfo(2));
                    self.badReps{end}.String = string(trialinfo(3));
                    
                    self.badTrials{end+1} = uicontrol(self.panel, 'Style', 'text', 'String', '', ...
                        'HorizontalAlignment', 'center', 'units', 'normalized', 'Position', ...
                        [self.badTrials{end}.Position(1), self.badTrials{end}.Position(2) - .07, .03, .06]);
                    
                    self.badConds{end+1} = uicontrol(self.panel, 'Style', 'text', 'String', '', ...
                        'HorizontalAlignment', 'center', 'units', 'normalized', 'Position', ...
                        [self.badConds{end}.Position(1), self.badConds{end}.Position(2) - .07, .03, .06]);
                    
                    self.badReps{end+1} = uicontrol(self.panel, 'Style', 'text', 'String', '', ...
                        'HorizontalAlignment', 'center', 'units', 'normalized', 'Position', ...
                        [self.badReps{end}.Position(1), self.badReps{end}.Position(2) - .07, .03, .06]);
                end
                
            else
                
                self.position_axis.XAxis.Limits = [model.inter_hist_axis(1), model.inter_hist_axis(end)]; 
%                 peak_left = max(model.inter_hist_left);
%                 idxLeft = find(model.inter_hist_left == max(model.inter_hist_left));
%                 xpoint_left = model.inter_hist_axis(idxLeft);
%                 peak_right = max(model.inter_hist_right);
%                 idxRight = find(model.inter_hist_right == max(model.inter_hist_right));
%                 xpoint_right = model.inter_hist_axis(idxRight);
                xax_plot = model.inter_hist_axis;
                xax_plot(1) = [];
                

                cla(self.position_axis);
                plot(self.position_axis, xax_plot, model.inter_hist_left, 'Color', 'r');
                hold on;
                plot(self.position_axis, xax_plot, model.inter_hist_right, 'Color', 'b');
                %hold on;
                ylabel("Probability");
                xlabel("Volts");
                legend("Left Wing", "Right Wing", 'Location', 'southoutside');
                
      
            end
                
           
            
        end
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
    end
    
    
end
