function setup_simple_da_settings(exp_settings, save_settings, timeseries_plot_settings, ...
        CL_hist_plot_settings, TC_plot_settings, settings_path, filename)

%% This function takes in variables created in Simple_DA_settings.m and generates
% The rest of the variables needed for a full data analysis with default
% values.

%% Get processing settings from path provided
process_settings = load(exp_settings.path_to_processing_settings);
proc_settings = process_settings.settings;
[proc_settings.protocol_folder, ~, ~] = fileparts(proc_settings.path_to_protocol);

%% Create Array of genotype names for labeling
if exp_settings.single_fly % if it's a single fly analysis, just get genotype from metadata. No control

    metadata = load(fullfile(exp_settings.fly_path, 'metadata.mat'));
    exp_settings.genotypes = [metadata.fly_genotype];

elseif exp_settings.single_group % if it's a single group, a field value must 
    % be provided (and no more than one) so just copy it. No control

    exp_settings.genotypes = exp_settings.field_values{1};

elseif ~exp_settings.plot_all_genotypes % If it's multiple groups but not all genotypes, 
    % then there must be a field value for every group, but one may be a
    % control. Put control at front of genotypes, then copy the rest from
    % field values

    exp_settings.genotypes = [];
    if ~isempty(exp_settings.control_genotype)
        exp_settings.genotypes = [string(exp_settings.control_genotype)];
    end
    
    for f = 1:length(exp_settings.field_values)
        match = [];
        for g = 1:length(exp_settings.genotypes)
            match(g) = strcmp(exp_settings.field_values{f}, exp_settings.genotypes(g));
        end
        if sum(match) > 0
            continue;
        end
        exp_settings.genotypes(end+1) = exp_settings.field_values{f};
    end

else %if using plot_all_genotypes, the actual analysis generates its own labels based on what it finds.

    exp_settings.genotypes = [];
end

    
%% Histogram settings ('-hist')

    %Date range displayed on histograms
    histogram_annotation_settings.annotation_text = "";

%% Timeseries plot settings ('-TSplot')

    timeseries_plot_settings.OL_TS_conds = [];
    timeseries_plot_settings.OL_TS_durations = [];     
    timeseries_plot_settings.cond_name = [];
    timeseries_plot_settings.axis_labels = {};
    timeseries_plot_settings.subplot_figure_title = {};
    timeseries_plot_settings.figure_names = []; %will be adjusted if timeseries are being plotted

    for dt = 1:length(timeseries_plot_settings.OL_datatypes)
        timeseries_plot_settings.figure_names(dt) = string(timeseries_plot_settings.OL_datatypes{dt});
    end

    timeseries_plot_settings.pattern_motion_indicator = 1;
    timeseries_plot_settings.other_indicators = [];
    timeseries_plot_settings.cutoff_time = 0;
    timeseries_plot_settings.frame_superimpose = 0;    
    timeseries_plot_settings.faLmR_conds = [];
    timeseries_plot_settings.faLmR_figure_names = ["faLmR"];
    timeseries_plot_settings.faLmR_subplot_figure_titles = [];
    timeseries_plot_settings.faLmR_cond_name = [];


%% Closed loop histogram settings ('-CLhist')
   
    CL_hist_plot_settings.CL_hist_conds = [];
    CL_hist_plot_settings.axis_labels = {};
    

%% Tuning Curve plot settings ('-TCplot')
    
    TC_plot_settings.cond_name = [];
    TC_plot_settings.plot_both_directions = 0;
    TC_plot_settings.axis_labels = {}; % will be adjusted if tuning curves are being done
    TC_plot_settings.subplot_figure_title = {};   
    TC_plot_settings.figure_names = [];

    for tc = 1:length(TC_plot_settings.TC_datatypes)
        TC_plot_settings.axis_labels{tc} = [TC_plot_settings.xaxis_label, string(TC_plot_settings.TC_datatypes{tc})];
    end
    
%% Position-Series M and P Plot Settings ('-posplot)

    MP_plot_settings.plot_MandP = 0;   
    MP_plot_settings.mp_conds = [];
    MP_plot_settings.cond_name = [];
    MP_plot_settings.xaxis = [1:192]; 
    MP_plot_settings.new_xaxis = circshift((360/MP_plot_settings.xaxis(end))*[(MP_plot_settings.xaxis) - 96], 96); %use
    MP_plot_settings.axis_labels{1} = []; %{xlabel, ylabel}
    MP_plot_settings.axis_labels{2} = [];
    MP_plot_settings.ylimits = []; 
    MP_plot_settings.xlimits = []; 
    MP_plot_settings.subplot_figure_title = [];
    MP_plot_settings.figure_names =  []; 
    MP_plot_settings.show_individual_flies = 0;
        
%% Position-Series Averages Plot Settings ('-posplot)
    
    pos_plot_settings.plot_pos_averaged = 1;
    pos_plot_settings.pos_conds = [];
    pos_plot_settings.cond_name = [];
    pos_plot_settings.xaxis = [1:192];
    pos_plot_settings.new_xaxis = circshift((360/MP_plot_settings.xaxis(end))*[(MP_plot_settings.xaxis) - 96], 96); 
    pos_plot_settings.axis_labels = [];
    pos_plot_settings.ylimits = [];
    pos_plot_settings.xlimits = [];
    pos_plot_settings.figure_names = [];
    pos_plot_settings.subplot_figure_title = [];
    pos_plot_settings.show_individual_flies = 0;
    pos_plot_settings.plot_opposing_directions = 0;

%% Comparison figure settings
    
    % Comparison plots should not be attempted with the simplified data
    % analysis!!! These values cannot really be determined by default

    comp_settings.plot_order = {};
    comp_settings.conditions = [];
    comp_settings.cond_name = {};
    comp_settings.rows_per_fig = 4;
    comp_settings.ylimits = [0 0];
    comp_settings.subplot_figure_title = {};
    comp_settings.figure_names = {};
    comp_settings.norm = 1;
    

%% GENERAL PLOT SETTINGS
    
%Arrangement of datatype options for flying data: 'LmR_chan', 'L_chan', 'R_chan', 'F_chan', 'Frame Position', 'LmR', 'LpR', 'faLmR'
%Arrangement of datatype options for walking data: 'Vx0_chan', 'Vx1_chan', 'Vy0_chan', 'Vy1_chan', 'Frame Position', 'Turning', 'Forward', 'Sideslip'
    
    gen_settings.figTitle_fontSize = 12;
    gen_settings.subtitle_fontSize = 8;
    gen_settings.legend_fontSize = 6;
    gen_settings.yLabel_fontSize = 6;
    gen_settings.xLabel_fontSize = 6;
    gen_settings.axis_num_fontSize = 6;
    gen_settings.axis_label_fontSize = 6;
    gen_settings.fly_colors = [.95 .95 .95; .9 .9 .9; .85 .85 .85; .8 .8 .8; .75 .75 .75; .7 .7 .7; .65 .65 .65; .6 .6 .6; .55 .55 .55; .5 .5 .5; .45 .45 .45;  .4 .4 .4; .35 .35 .35; .3 .3 .3; .25 .25 .25; .2 .2 .2; .15 .15 .15; .1 .1 .1;.95 .95 .95; .9 .9 .9; .85 .85 .85; .8 .8 .8; .75 .75 .75; .7 .7 .7; .65 .65 .65; .6 .6 .6; .55 .55 .55; .5 .5 .5; .45 .45 .45;  .4 .4 .4; .35 .35 .35; .3 .3 .3; .25 .25 .25; .2 .2 .2; .15 .15 .15; .1 .1 .1]; %Colors assigned to individual fly lines
    gen_settings.rep_colors = [0.5 0.5 0.5; 1 0.5 0.5; 0.25 0.75 0.25; 0.5 0.5 1; 1 0.75 0.25; 0.75 0.5 1; 0.5 1 0.5; 0.5 1 1; 1 0.5 1; 1 1 0.5]; %default 10 colors supports up to 10 groups (add more colors for more groups)
    gen_settings.rep_lineWidth = 0.05;
    gen_settings.mean_colors = [0 0 0; 1 0 0; 0 0.5 0; 0 0 1; 1 0.5 0; .75 0 1; 0 1 0; 0 1 1; 1 0 1; 1 1 0]; %default 10 colors supports up to 10 groups (add more colors for more groups)
    gen_settings.control_color = [0 0 0];
    gen_settings.mean_lineWidth = 1;
    gen_settings.edgeColor = 'none';
    gen_settings.patch_alpha = 0.3; %sets the level of transparency for patch region around timeseries data

%% Plot Settings for basic Histograms

    histogram_plot_settings.histogram_ylimits = [0 100; -6 6; 2 10];
    histogram_plot_settings.xlimits = [-7, 7; 0 16]; % [LmR limits, LpR limits]
    histogram_plot_settings.inter_in_degrees = 1;

    %% Annotation settings for basic Histograms

    histogram_annotation_settings.textbox = [0.3 0.0001 0.7 0.027];
    histogram_annotation_settings.font_size = 10;
    histogram_annotation_settings.font_name = 'Arial';
    histogram_annotation_settings.line_style = '-';
    histogram_annotation_settings.edge_color = [1 1 1];
    histogram_annotation_settings.line_width = 1;
    histogram_annotation_settings.background_color = [1 1 1];
    histogram_annotation_settings.color = [0 0 0];
    histogram_annotation_settings.interpreter = 'none';

    %% Plot settings for Closed-Loop histograms

    CL_hist_plot_settings.histogram_ylimits = [0 100; -6 6; 2 10];

    %% Plot settings for Open-Loop timeseries plots
    
    timeseries_plot_settings.timeseries_ylimits = [-1.1 1.1; -1 6; -1 6; -1 6; 1 192; 0 0; 0 0; 0 0]; %[min max] y limits for each datatype (including 1 additional for 'faLmR' option)
    timeseries_plot_settings.timeseries_xlimits = [0 4];  
    timeseries_plot_settings.frame_scale = .5;
    timeseries_plot_settings.frame_color = [0.7 0.7 0.7];
    
    %% Plot settings for tuning curves

    TC_plot_settings.timeseries_ylimits = [-1.1 1.1; -1 6; -1 6; -1 6; 1 192; 0 0; 0 0; 0 0];   
    TC_plot_settings.marker_type = 'o';
    TC_plot_settings.default_conds_per_curve = 7; %If the conditions are not provided in a layout, it will by default include 7 conditions in each curve

    
%% Plot settings for M and P

   
%% Plot settings for position series


    %% Save settings
    save_settings.report_plotType_order = {'_hist_','timeseries', 'TC', 'M_', 'P_', 'MeanPositionSeries', 'Comparison'};
    save_settings.norm_order = {'unnormalized', 'normalized'};
    save_settings.paperunits = 'inches';
    save_settings.x_width = 8; 
    save_settings.y_width = 10;
    save_settings.orientation = 'landscape';
    save_settings.high_resolution = 0;

    
     save(fullfile(settings_path, filename), 'exp_settings', 'histogram_plot_settings', ...
        'histogram_annotation_settings','CL_hist_plot_settings', 'proc_settings',...
        'timeseries_plot_settings', 'TC_plot_settings', 'MP_plot_settings', ...
        'pos_plot_settings', 'save_settings','comp_settings', 'gen_settings');





end