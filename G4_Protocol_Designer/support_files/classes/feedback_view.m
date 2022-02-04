classdef feedback_view < handle
    
%% NOTE: I Have mixed up open loop and closed loop in my variable names in this code.
% Everything that has to do with the intertrial axis is labeled as "Open
% loop" and everything that has to do with the conditiosn axis is labeled
% "Closed loop" when it should be the opposite! This does not affect what
% data is actually displayed, the correct data is displayed in the correct
% axis. But this may be very confusing to anyone who opens this code and
% tries to update it. TO BE FIXED SOON
    
    properties
        
        panel
        wbf_alarm
        min_wbf
        position_center
        openLoop_axis
        closeLoop_axis
        wbf_axis
        avg_wbf
        trial_label
        cond_label
        rep_label
        runcon
        current_trial
        closeLoop_plot_left
        closeLoop_plot_right
        openLoop_plot_left
        openLoop_plot_right
        OL_function_box
        CL_function_box

        
        
    end
    
    methods
        
        function self = feedback_view(con, placement)
            
            fig = con.view.fig();
            fig_size = con.view.fig_size();
            self.runcon = con;
            model = con.fb_model;
            self.min_wbf = model.get_wbf_lim();
            self.current_trial = 1;
            
            
           
            self.panel = uipanel(fig, 'Title', 'Data Monitoring', 'Fontsize', 11, ...
                'units', 'pixels', 'Position', [placement fig_size(3)*.37, fig_size(4)-15]);
            
            wbf_label = uicontrol(self.panel, 'Style', 'text', 'String', 'Last trial avg WBF:', ...
                'FontSize', 9, 'HorizontalAlignment', 'center', 'units', ...
                'normalized', 'Position', [.02, .9, .2, .05]);
            self.avg_wbf = uicontrol(self.panel, 'Style','text','String', string(con.fb_model.avg_wbf), ...
                'FontSize', 11, 'HorizontalAlignment', 'center', 'units', ...
                'normalized', 'Position', [.25, .9, .1, .05]);

            
% Set up axes for plotting streamed data
            self.openLoop_axis = axes(self.panel, 'units','normalized', 'Position', [.1, .67, .5 ,.2]);
            OL_box_label = uicontrol(self.panel, 'style', 'text', 'String', 'Custom Analysis: ', ...
                'units', 'normalized', 'Position', [.65, .77, .2, .03]);
            self.OL_function_box = uicontrol(self.panel, 'style', 'edit', 'String', ...
                self.runcon.get_custom_OL_function(), 'units', 'normalized', ...
                'Position', [.63, .72, .25, .05], 'Callback', @self.new_OL_function);
            OL_browse_btn = uicontrol(self.panel, 'Style', 'pushbutton', 'String', 'Browse', ...
                'units', 'normalized', 'Position', [.89, .72, .1, .05], 'Callback', @self.OL_browse);
            self.closeLoop_axis = axes(self.panel, 'units', 'normalized', 'Position', [.1, .37, .5, .2]);
            CL_box_label = uicontrol(self.panel, 'style', 'text', 'String', 'Custom Analysis: ', ...
                'units', 'normalized', 'Position', [.65, .47, .2, .03]);
            self.CL_function_box = uicontrol(self.panel, 'style', 'edit', 'String', ...
                self.runcon.get_custom_CL_function(), 'units', 'normalized', ...
                'Position', [.63, .42, .25, .05], 'Callback', @self.new_CL_function);
            CL_browse_btn = uicontrol(self.panel, 'style', 'pushbutton', 'String', 'Browse', ...
                'units', 'normalized', 'Position', [.89, .42, .1, .05], 'Callback', @self.CL_browse);
            self.wbf_axis = axes(self.panel, 'units', 'normalized', 'Position', [.1, .07, .8, .2]);

            %Create initial plots so when it is time to update them, we can
            %just update the xdata of the existing plots, rather than
            %re-plotting
            self.closeLoop_axis.XAxis.Limits = [model.cond_hist_axis(1) model.cond_hist_axis(end)];
            cond_xax = model.cond_hist_axis;
            cond_xax(1) = [];
            self.closeLoop_plot_left = plot(self.closeLoop_axis, cond_xax, model.cond_hist_left, 'Color', 'r');
            hold(self.closeLoop_axis, 'on');
            self.closeLoop_plot_right = plot(self.closeLoop_axis, cond_xax, model.cond_hist_right, 'Color', 'b');
            ylabel(self.closeLoop_axis, "Probability");
            xlabel(self.closeLoop_axis, "Volts")
            legend(self.closeLoop_axis, "Left Wing", "Right Wing", 'Location', 'northeast');
            title(self.closeLoop_axis, 'Conditions Histogram');
            hold(self.closeLoop_axis, 'on')
            
            
            self.openLoop_axis.XAxis.Limits = [model.inter_hist_axis(1), model.inter_hist_axis(end)];
            inter_xax = model.inter_hist_axis;
            inter_xax(1) = [];
            self.openLoop_plot_left = plot(self.openLoop_axis, inter_xax, model.inter_hist_left, 'Color', 'r');
            hold(self.openLoop_axis, 'on');
            self.openLoop_plot_right = plot(self.openLoop_axis, inter_xax, model.inter_hist_right, 'Color', 'b');          
            ylabel(self.openLoop_axis, "Probability");
            xlabel(self.openLoop_axis, "Volts");
            legend(self.openLoop_axis, "Left Wing", "Right Wing", 'Location', 'northeast');
            title(self.openLoop_axis, 'Intertrials Histogram');
            hold(self.openLoop_axis, 'on');

            
            
            self.wbf_axis.YAxis.Limits = [0 3];
            
            
            ylabel(self.wbf_axis, "WBF");
            xlabel(self.wbf_axis, "Trial");
            title(self.wbf_axis, 'Wing Beat Frequency per Trial');
            yline(self.wbf_axis, self.min_wbf{1}(1)/100);
            hold(self.wbf_axis, 'on');

            

        end
        
        function clear_view(self, model)
        
            set(self.avg_wbf, 'String',string(round(model.avg_wbf,4)));
           
            self.current_trial = 1;
            
            if ~isempty(self.OL_function_box.String)
                
                self.new_OL_function(self.OL_function_box, 0);
            end
            if ~isempty(self.CL_function_box.String)
                self.new_CL_function(self.CL_function_box,0);
            end
           
            cond_xax = model.cond_hist_axis;
            cond_xax(1) = [];
            set(self.closeLoop_plot_left, 'XData', cond_xax);
            set(self.closeLoop_plot_right, 'XData', cond_xax);
            set(self.closeLoop_plot_left, 'YData', model.cond_hist_left);
            set(self.closeLoop_plot_right, 'YData', model.cond_hist_right);
            
            inter_xax = model.inter_hist_axis;
            inter_xax(1) = [];
            set(self.openLoop_plot_left, 'XData', inter_xax);
            set(self.openLoop_plot_right, 'XData', inter_xax);
            set(self.openLoop_plot_left, 'YData', model.inter_hist_left);
            set(self.openLoop_plot_right, 'YData', model.inter_hist_right);
            

            cla(self.wbf_axis);
            yline(self.wbf_axis, self.min_wbf{1}(1)/100);
            hold(self.wbf_axis, 'on');

             drawnow;

                
%             
        end
        
        
        
        function update_feedback_view(self, model, trialType, trialinfo, bad_slope, bad_flier)
            
           set(self.avg_wbf, 'String', string(round(model.avg_wbf,4)));
            
            if ~strcmp(trialType, 'inter')

                if bad_slope == 1 || bad_flier == 1
  
                    trialNum = length(model.full_streamed_intertrials) + length(model.full_streamed_conditions);
                    if trialNum <= trialinfo(1)
                        self.runcon.add_bad_trial_marker_progress(trialNum);
                    
                    end
    
                end
                
                % Plot the conditions histogram
                if length(model.cond_hist_left) ~= length(self.closeLoop_plot_left.XData)
                    set(self.closeLoop_plot_left, 'XData', [1:1:length(model.cond_hist_left)]);
                end
                if length(model.cond_hist_right) ~= length(self.closeLoop_plot_right.XData)
                    set(self.closeLoop_plot_right, 'XData', [1:1:length(model.cond_hist_right)]);
                end
                
                set(self.closeLoop_plot_left, 'YData', model.cond_hist_left);
                set(self.closeLoop_plot_right, 'YData', model.cond_hist_right);
                num_trials = self.runcon.get_num_trials();
                
                % If we are running rescheduled conditions, then the axis
                % needs to go longer than the total number of conditions in
                % the original protocol
                if num_trials < trialinfo(1)
                    num_trials = trialinfo(1);
                    
                end
                self.wbf_axis.XAxis.Limits = [0 num_trials];

                plot(self.wbf_axis, self.current_trial, model.avg_wbf, '.', 'Color', 'k', 'MarkerSize', 12);
                hold(self.wbf_axis, 'on')
                
                if self.current_trial == 1
                    legend(self.wbf_axis, "Minimum", "Conditions", "Intertrials", 'Location', 'south', 'AutoUpdate', 'off');
                end    
                self.current_trial = self.current_trial + 1;
                hold(self.wbf_axis, 'on');
                
                
            else
               
                if length(model.inter_hist_left) ~= length(self.openLoop_plot_left.XData)
                    set(self.openLoop_plot_left, 'XData', [1:1:length(model.inter_hist_left)]);
                end
                if length(model.inter_hist_right) ~= length(self.openLoop_plot_right.XData)
                    set(self.openLoop_plot_right, 'XData', [1:1:length(model.inter_hist_right)]);
                end
                
                set(self.openLoop_plot_left, 'YData', model.inter_hist_left);
                set(self.openLoop_plot_right, 'YData', model.inter_hist_right);
 
               num_trials = self.runcon.get_num_trials();
                
                % If we are running rescheduled conditions, then the axis
                % needs to go longer than the total number of conditions in
                % the original protocol
                if num_trials < trialinfo(1)
                    num_trials = trialinfo(1);
                    
                end
                self.wbf_axis.XAxis.Limits = [0 num_trials];
                plot(self.wbf_axis, self.current_trial, model.avg_wbf, '.', 'Color', 'r', 'MarkerSize', 12);
                hold(self.wbf_axis, 'on');
                if self.current_trial == 2
                        
                    legend(self.wbf_axis, "Minimum", "Conditions", "Intertrials", 'Location', 'south', 'AutoUpdate', 'off');
                end
                self.current_trial = self.current_trial + 1;
                hold(self.wbf_axis, 'on');
                
                
            end
  
            
        end

        function CL_browse(self, ~, ~)
            
            self.runcon.browse_file('CL_cust')

        end

        function OL_browse(self, ~, ~)

            self.runcon.browse_file('OL_cust');
            
        end


        function new_OL_function(self, src, ~)
            
            self.runcon.update_custom_OL_analysis(src.String);
            self.openLoop_axis.XAxis.Limits = [-inf inf];

        end

        function new_CL_function(self, src, ~)

            self.runcon.update_custom_CL_analysis(src.String);
            self.closeLoop_axis.XAxis.Limits = [-inf inf];
        
        end

        function update_custom_OL_function(self)
            self.OL_function_box.String = self.runcon.get_custom_OL_function();
            
        end
        
        function update_custom_CL_function(self)
            self.CL_function_box.String = self.runcon.get_custom_CL_function();

        end


       
        

            
        

    end
    
    
end
