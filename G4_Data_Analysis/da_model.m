classdef da_model < handle
   
    properties
        
        % For figure layout
        top_left_place
        
        timeseries_bottom_left_places %one per figure
        timeseries_left_column_places %all places in far left column per figure

        falmr_bottom_left_places
        falmr_left_column_places
        
        CL_bottom_left_places
        CL_left_column_places
        
        MP_bottom_left_places
        MP_left_column_places
        
        pos_bottom_left_places
        pos_left_column_places
        
        % Important index tracking
        datatype_indices
        
        
        % file tracking
        files_excluded
        
        % basic info
        num_groups
        num_exps
        g4p_path
        bad_trials
        bad_intertrials
        trials_removed
        
        
    end
    
    
    methods
        
        function self = da_model(da)
            %% Get some basic information
            
            [self.num_groups, self.num_exps] = size(da.exp_settings.exp_folder);
            
             
            self.top_left_place = 1; %true for all figures
            
            
            
            %% Get the indices of different datatypes in the raw data
            [self.datatype_indices.Frame_ind, self.datatype_indices.OL_inds,...
                self.datatype_indices.CL_inds, self.datatype_indices.TC_inds]...
                = get_datatype_indices(da.CombData.channelNames, ...
                da.timeseries_plot_settings.OL_datatypes, ...
                da.CL_hist_plot_settings.CL_datatypes, da.TC_plot_settings.TC_datatypes);
            
            %% Get location of the .g4p file
            
            self.g4p_path = da.proc_settings.path_to_protocol;
            
            
        end
        
        function update_model(self, da)
            %% Get placements of subplots, so we know which ones should have enabled axes    
                %Determine which graphs are in the leftmost column so we know
            %to keep their y-axes turned on.
            
            %place refers to the count of the graph in order from top left
            %to bottom right. So for example, an OL_conds of [1 3 5; 7 8 9;
            %11 13 15;] shows a three by three grid of plots of those
            %condition numbers. The places would be [ 1 4 7; 2 5 8; 3 6 9;]
            %so conditions 1 7, and 11 would be in places 1, 2, and 3 and
            %would be marked as being the leftmost plots. The bottom row,
            %conditions 11, 13, and 15, would be in places 3, 6, and 9.
            %It's done this way because of the indexing in MATLAB. In this
            %example OL_conds, OL_conds(4) would be 3, because it goes down
            %columns, not across rows, as index increases. 

            %Top left place and bottom left place (1 and 3 in the above
            %example, or conditions 1 and 11), are calculated separately
            %because these two positions will additionally have a label on
            %their y and x-axes. 
            
            
            %timeseries
            if da.timeseries_plot_option == 1
                [self.timeseries_bottom_left_places, self.timeseries_left_column_places] = ...
                   get_plot_placements(da.timeseries_plot_settings.OL_TS_conds);
            else
                self.timeseries_bottom_left_places = [];
                self.timeseries_left_column_places = [];
            end
            
            %faLmR timeseries
            if da.faLmR == 1 && da.timeseries_plot_option ==1
                if ~isempty(da.timeseries_plot_settings.faLmR_conds)
                    [self.falmr_bottom_left_places, self.falmr_left_column_places] = ...
                        get_plot_placements(da.timeseries_plot_settings.faLmR_conds);
                end
            else
                self.falmr_bottom_left_places = [];
                self.falmr_left_column_places = [];
            end
            
            %M and P position series plots
            if da.pos_plot_option == 1
            
              [self.MP_bottom_left_places, self.MP_left_column_places] = ...
                 get_plot_placements(da.MP_plot_settings.mp_conds);
            else
                self.MP_bottom_left_places = [];
                self.MP_left_column_places = [];
            end
            
            %standard position series plots
            if da.pos_plot_option && da.pos_plot_settings.plot_pos_averaged
                [self.pos_bottom_left_places, self.pos_left_column_places] = ...
                    get_plot_placements(da.pos_plot_settings.pos_conds);
            else
                self.pos_bottom_left_places = [];
                self.pos_left_column_places = [];
            end
            
            %Closed loop histograms
            if da.CL_histogram_plot_option
                [self.CL_bottom_left_places, self.CL_left_column_places] = ...
                    get_plot_placements(da.CL_hist_plot_settings.CL_hist_conds);
            else
                self.CL_bottom_left_places = [];
                self.CL_left_column_places = [];
            end
            
            
        end
        
        function get_removed_trials(self, CombData)
            
%            badcorr = CombData.bad_crossCorr_conds;
            baddur = CombData.bad_duration_conds;
            badint = CombData.bad_duration_intertrials;
%            badslope = CombData.bad_slope_conds;
            badwbf = CombData.bad_WBF_conds;
            
            self.bad_intertrials = badint;
            self.bad_trials = [baddur; badwbf];

            for i = size(self.bad_trials):-1:1
                for j = size(self.bad_trials):-1:1
                    if i == j
                        continue;
                    elseif self.bad_trials(i,:) == self.bad_trials(j,:)
                        self.bad_trials(i,:) = [];
                        break;
                    end
                end
            end

        end
        
    end
    
    methods (Static)
        
        function [bottom_left_places, left_column_places] = get_plot_placements(conds)
            
            for i = 1:length(conds)
                a = ~isnan(conds{i});
                bottom_left_places{i} = sum(a(:,1));

                if size(conds{i},1) ~= 1

                    for m = 1:size(conds{i},1)
                        left_column_places{i}(m) = m;
                    end


                else

                    left_column_places{i} = 1;
                end
            end
            
        end
        
        function [Frame_ind, OL_inds, CL_inds, TC_inds] = get_datatype_indices(channelNames, ...
            OL_datatypes, CL_datatypes, TC_datatypes) 

            Frame_ind = find(strcmpi(channelNames.timeseries,'Frame Position'));
            for i = 1:length(OL_datatypes)
                if strcmp(OL_datatypes{i}, 'faLmR')
                    continue;
                end
                ind = find(strcmpi(channelNames.timeseries,OL_datatypes{i}));
                assert(~isempty(ind),['could not find ' OL_datatypes{i} ' datatype'])
                OL_inds(i) = ind;
            end
            for i = 1:length(CL_datatypes)
                ind = find(strcmpi(channelNames.histograms,CL_datatypes{i}));
                assert(~isempty(ind),['could not find ' CL_datatypes{i} ' datatype'])
                CL_inds(i) = ind;
            end
            for i = 1:length(TC_datatypes)
                ind = find(strcmpi(channelNames.timeseries,TC_datatypes{i}));
                assert(~isempty(ind),['could not find ' TC_datatypes{i} ' datatype'])
                TC_inds(i) = ind;
            end


        end
        
      
        
        

        
        
    end
    
    
end