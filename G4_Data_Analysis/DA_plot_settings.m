
function [exp_settings, histogram_plot_settings, histogram_annotation_settings, ...
    CL_hist_plot_settings, timeseries_plot_settings, TC_plot_settings, ...
    MP_plot_settings, pos_plot_settings, save_settings] = DA_plot_settings()

%% Settings which need updating regularly (more static settings below)

%[pretrial, intertrial, posttrial]
    exp_settings.trial_options = [1 1 1];
%% Settings for exp_folder generation
    
    exp_settings.field_to_sort_by{1} = ["fly_genotype"];
%   exp_settings.field_to_sort_by{2} = ["fly_genotype"];
%   exp_settings.field_to_sort_by{3} = ["fly_genotype"];
   
    %if plot_all_genotypes is 1, leave field_values empty.
    exp_settings.field_values = {};
%   exp_settings.field_values{1} = ["emptySplit_UAS_Kir_JFRC49"];
%   exp_settings.field_values{2} = ["SS01001_JFRC100_JFRC49"];
%   exp_settings.field_values{1} = ["SS00324_JFRC100_JFRC49"];

    exp_settings.single_group = 0;%1-all flies should be in one group, so exp_folder should be 1xX cell array
    exp_settings.single_fly = 0;%1- only a single fly is being analyzed, the exp_folder will simply be the path to the fly

    %1 - each genotype will be plotted in its own figure against a control. 
    %0 - groups will be plotted as laid out below. 
    exp_settings.plot_all_genotypes = 1; 
   
     %control must match exactly the metadata genotype value. 
    exp_settings.control_genotype = 'emptySplit_UAS_Kir_JFRC49';

    %This is the path to the protocol
    save_settings.path_to_protocol = "/Users/taylorl/Desktop/bad_flies";
    
    exp_settings.genotypes = ["Empty Split"];
    %genotypes = ["empty-split", "LPLC-2", "LC-18", "T4_T5", "LC-15", "LC-25", "LC-11", "LC-17", "LC-4"];

%% Save settings
    
% Save settings   
    %The path where you wish to save the results of the data analysis
    save_settings.save_path = '/Users/taylorl/Desktop/bad_flies';

%% Experiment settings

    exp_settings.plot_norm_and_unnorm = 1;%1 or 0.

    exp_settings.processed_data_file = 'testing_new_processing';

    %Log file will be named using this
    exp_settings.group_being_analyzed_name = 'Empty split test';
    
%% Histogram settings 

    %Date range displayed on histograms
    histogram_annotation_settings.annotation_text = "Annotation text here.";

%% Timeseries plot settings
    %OL_TS_conds indicates the layout of your timeseries figures. See
    %documentation for example. Leave empty ([]) for default layout.
    timeseries_plot_settings.OL_TS_conds = [];

    %Durations inform the x axis limits on timeseries plots. Leave empty
    %for the software to pull durations from the processed data, or create
    %an array like OL_TS_conds with x limit values instead of condition
    %#'s. See documentation for example.
    timeseries_plot_settings.OL_TS_durations = []; 

    %Axis labels for the timeseries plots [x, y]. For multiple figures,
    %make it a cell array with each cell element corresponding to that
    %figure in the OL_TS_conds array. See documentation for example.
    timeseries_plot_settings.OL_TSconds_axis_labels = {};

    %An array of figure names for each figure of timeseries plots. 
    timeseries_plot_settings.figure_names = ["LmR"];
    
%datatype options for flying data: 'LmR_chan', 'L_chan', 'R_chan', 'F_chan', 'Frame Position', 'LmR', 'LpR', 'faLmR'
%datatype options for walking data: 'Vx0_chan', 'Vx1_chan', 'Vy0_chan', 'Vy1_chan', 'Frame Position', 'Turning', 'Forward', 'Sideslip'
    
    %The datatype to plot as timeseries
    timeseries_plot_settings.OL_datatypes = {'LmR'};
    
    %Set this to 1 if you are plotting only a single group and want lines
    %plotted for each fly as well as the average.
    timeseries_plot_settings.show_individual_flies = 0;
    
    %plot the frame position under each timeseries plot
    timeseries_plot_settings.frame_superimpose = 0;
    
    %plot both directions for each condition on the same axis. 
    timeseries_plot_settings.plot_both_directions = 1;

    %If you want the plots to have their own plot titles, make a cell array
    %of titles corresponding to the OL_TS_conds array. Else leave empty or
    %set to 0 (no titles).
    timeseries_plot_settings.cond_name = [];

%% Closed loop histogram settings
    %Create array to dictate layout of CL histograms or leave empty for def
    CL_hist_plot_settings.CL_hist_conds = [];
    
    %Datatypes for which to plot closed-loop histograms
    CL_hist_plot_settings.CL_datatypes = {'Frame Position'}; %datatypes to plot as histograms          

%% Tuning Curve plot settings
    %Create the layout of tuning curves in this array. It works differently
    %than OL_TS_conds - see documentation for details.
    TC_plot_settings.OL_TC_conds = [];
    
    %If you want your tuning curves to have their own plot titles, make an
    %array of titles for each PLOT (not each condition). So this should be
    %a cell array like with the timeseries. A cell element for each figure,
    %and each cell having an array matching the layout of the figure. If you want no
    %plot titles, set cond_name = 0
    TC_plot_settings.cond_name = [];
    
    %The xaxis label for tuning curves
%     TC_plot_settings.TC_axis_labels{1} = ["Frequency(Hz)","LmR"];
%     TC_plot_settings.TC_axis_labels{2} = ["Frequency(Hz)", "LpR"];
    TC_plot_settings.TC_axis_labels = {};
    TC_plot_settings.figure_names = [];
    
    %The x-axis values for tuning curves
    TC_plot_settings.xaxis_values = [0.625 1.25 2.5 5 10 20 40];
    
    %Datatypes for which to plot tuning curves
    TC_plot_settings.TC_datatypes = {'LmR','LpR'}; 
    
    %Plots tuning curves for both directions on the same axis
    TC_plot_settings.plot_both_directions = 1; 
    
%% Position-Series P and M Plot Settings

    MP_plot_settings.mp_conds{1} = [1 3 5 7; 9 11 13 15];
    MP_plot_settings.mp_conds{2} = [17 19 21 23; 25 27 29 31];   
    MP_plot_settings.xaxis = [1:192];
    MP_plot_settings.plot_MandP = 1;
    MP_plot_settings.figure_names =  ["M", "P"]; 
    MP_plot_settings.axis_labels{1} = ["M X Label", "M Y Label"]; %{xlabel, ylabel}
    MP_plot_settings.axis_labels{2} = ["P X Label", "P Y Label"];
    MP_plot_settings.cond_name{1} = ["Conds12" "Conds34" "Conds56" "Conds78"; ...
        "Conds910" "Conds1112" "Conds1314" "Conds1516"]; %Titles of subplots - correspond to pos_conds
    MP_plot_settings.cond_name{2} = ["Conds1718" "Conds1920" "Conds2122" "Conds2324"; ...
        "Conds2526" "Conds2728" "Conds2930" "Conds3132"];
    MP_plot_settings.show_ind_flies = 1;
    MP_plot_settings.ylimits = [0 0; 0 0]; %[ylimits for M; ylimits for P];
    
    
%% Position-Series Averages Plot Settings
    
    pos_plot_settings.plot_pos_averaged = 0;
    pos_plot_settings.pos_conds = [];
    pos_plot_settings.new_xaxis = [];
    
%% Further settings that may not need adjusting often 

%% Position series settings

    
    %% Normalization Settings

%     normalize_settings.normalize_to_baseline = {'LpR'};%datatypes to normalize by setting the baseline value to 1
%     normalize_settings.baseline_startstop = [0 1]; %start and stop times to use for baseline normalization
%     normalize_settings.normalize_to_max = {'LmR'}; %datatypes to normalize by setting the maximum (or minimum) values to +1 (or -1)
%     normalize_settings.max_startstop = [1 3]; %start and stop times to use for max normalization
%     normalize_settings.max_prctile = 98; %percentile to use as a more robust estimate of the maximum value

    %% Plot Settings for basic Histograms

    histogram_plot_settings.histogram_ylimits = [0 100; -6 6; 2 10];
    histogram_plot_settings.subtitle_FontSize = 8;
    histogram_plot_settings.rep_colors = [0.5 0.5 0.5; 1 0.5 0.5; 0.25 0.75 0.25; 0.5 0.5 1; 1 0.75 0.25; 0.75 0.5 1; 0.5 1 0.5; 0.5 1 1; 1 0.5 1; 1 1 0.5]; %default 10 colors supports up to 10 groups (add more colors for more groups)
    histogram_plot_settings.mean_colors = [0 0 0; 1 0 0; 0 0.5 0; 0 0 1; 1 0.5 0; .75 0 1; 0 1 0; 0 1 1; 1 0 1; 1 1 0]; %default 10 colors supports up to 10 groups (add more colors for more groups)
    histogram_plot_settings.rep_LineWidth = 0.05;
    histogram_plot_settings.mean_LineWidth = 1;
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

    CL_hist_plot_settings.rep_colors = [0.5 0.5 0.5; 1 0.5 0.5; 0.5 0.5 1];
    CL_hist_plot_settings.rep_lineWidth = 0.05;
    CL_hist_plot_settings.mean_colors = [0 0 0;1 0 0; 0 0 1];
    CL_hist_plot_settings.mean_lineWidth = 1;
    CL_hist_plot_settings.histogram_ylimits = [0 100; -6 6; 2 10];
    CL_hist_plot_settings.subtitle_fontSize = 8;

    %% Plot settings for Open-Loop timeseries plots
    
%datatype options for flying data: 'LmR_chan', 'L_chan', 'R_chan', 'F_chan', 'Frame Position', 'LmR', 'LpR', 'faLmR'
%datatype options for walking data: 'Vx0_chan', 'Vx1_chan', 'Vy0_chan', 'Vy1_chan', 'Frame Position', 'Turning', 'Forward', 'Sideslip'

    timeseries_plot_settings.timeseries_ylimits = [-1.1 1.1; -1 6; -1 6; -1 6; 1 192; 0 0; 0 0; 0 0]; %[min max] y limits for each datatype (including 1 additional for 'faLmR' option)
    timeseries_plot_settings.timeseries_xlimits = [0 4];
    timeseries_plot_settings.subtitle_fontSize = 8;
    timeseries_plot_settings.legend_fontSize = 6;
    timeseries_plot_settings.yLabel_fontSize = 6;
    timeseries_plot_settings.xLabel_fontSize = 6;
    timeseries_plot_settings.axis_num_fontSize = 6;
    timeseries_plot_settings.overlap = 0; %not working
    timeseries_plot_settings.fly_colors = [.95 .95 .95; .9 .9 .9; .85 .85 .85; .8 .8 .8; .75 .75 .75; .7 .7 .7; .65 .65 .65; .6 .6 .6; .55 .55 .55; .5 .5 .5; .45 .45 .45;  .4 .4 .4; .35 .35 .35; .3 .3 .3; .25 .25 .25; .2 .2 .2; .15 .15 .15; .1 .1 .1]; %Colors assigned to individual fly lines
    timeseries_plot_settings.rep_colors = [0 0 0; 1 0 0; 0 0.5 0; 0 0 1; 1 0.5 0; .75 0 1; 0 1 0; 0 1 1; 1 0 1; 1 1 0]; %default 10 colors supports up to 10 groups (add more colors for more groups)
    timeseries_plot_settings.rep_lineWidth = 0.05;
    timeseries_plot_settings.mean_colors = [1 0 0; 0 0 1; 0 0.5 0; 1 0.5 0; .75 0 1; 0 1 0;  1 0.5 1; 0 1 1; 1 0 1; 1 1 0]; %default 10 colors supports up to 10 groups (add more colors for more groups)
    timeseries_plot_settings.control_color = [0 0 0];
    timeseries_plot_settings.mean_lineWidth = 1;
    timeseries_plot_settings.edgeColor = 'none';
    timeseries_plot_settings.patch_alpha = 0.3; %sets the level of transparency for patch region around timeseries data
    timeseries_plot_settings.frame_scale = .5;
    timeseries_plot_settings.frame_color = [0.7 0.7 0.7];
    
    %% Plot settings for tuning curves

    TC_plot_settings.rep_lineWidth = 0.05;
    TC_plot_settings.mean_lineWidth = 1;
    TC_plot_settings.timeseries_ylimits = [-1.1 1.1; -1 6; -1 6; -1 6; 1 192; 0 0; 0 0; 0 0];
    TC_plot_settings.axis_label_fontSize = 6; 
    TC_plot_settings.xtick_label_fontSize = 6;
    TC_plot_settings.rep_colors = [0 0 0; 0.75 0 0; 0 0.25 0; 0 0 0.75; 0.75 0.25 0; .5 0 0.75; 0 0.75 0; 0 0.75 0.75; 0.75 0 0.75; 0.75 0.75 0]; %default 10 colors supports up to 10 groups (add more colors for more groups)
    TC_plot_settings.mean_colors = [1 0 0; 0 0 1; 0 0.5 0; 1 0.5 0; .75 0 1; 0 1 0;  1 0.5 1; 0 1 1; 1 0 1; 1 1 0]; %default 10 colors supports up to 10 groups (add more colors for more groups)
    TC_plot_settings.control_color = [0 0 0];
    TC_plot_settings.subtitle_fontSize = 8;
    TC_plot_settings.marker_type = 'o';
    TC_plot_settings.legend_FontSize = 6;
    
%% Plot settings for position series

    MP_plot_settings.rep_colors = [0 0 0; 1 0 0; 0 0.5 0; 0 0 1; 1 0.5 0; ...
        .75 0 1; 0 1 0; 0 1 1; 1 0 1; 1 1 0]; %default 10 colors supports up to 10 groups (add more colors for more groups)
    MP_plot_settings.mean_colors = [1 0 0; 0 0 1; 0 0.5 0; 1 0.5 0; .75 0 1; ...
        0 1 0;  1 0.5 1; 0 1 1; 1 0 1; 1 1 0]; %default 10 colors supports up to 10 groups (add more colors for more groups)
    MP_plot_settings.control_color = [0 0 0];
    MP_plot_settings.mean_lineWidth = 1;
    MP_plot_settings.edgeColor = 'none';
    MP_plot_settings.patch_alpha = 0.3;
    MP_plot_settings.subtitle_fontSize = 8;
    MP_plot_settings.legend_fontSize = 6;
    MP_plot_settings.ylimits = []; %[M ymin ymax; P ylmin ymax];
    MP_plot_settings.xlimits = []; %[M xmin xmax; P xmin xmax];
    MP_plot_settings.rep_lineWidth = 0.05;
    MP_plot_settings.yLabel_fontSize = 6;
    MP_plot_settings.xLabel_fontSize = 6;
    MP_plot_settings.fly_colors = [.95 .95 .95; .9 .9 .9; .85 .85 .85; .8 .8 .8; ...
        .75 .75 .75; .7 .7 .7; .65 .65 .65; .6 .6 .6; .55 .55 .55; .5 .5 .5; .45 .45 .45;  .4 .4 .4; .35 .35 .35; .3 .3 .3; .25 .25 .25; .2 .2 .2; .15 .15 .15; .1 .1 .1]; %Colors assigned to individual fly lines
    MP_plot_settings.axis_num_fontSize = 6;


    %% Save settings

    save_settings.paperunits = 'inches';
    save_settings.x_width = 8; 
    save_settings.y_width = 10;
    save_settings.orientation = 'landscape';
    save_settings.high_resolution = 0;
    
    
        %% TO ADD A NEW MODULE
        %If there are any settings necessary for new module, add them to
        %one of the existing settings structs or create a new struct (more
        %work)
        
    %% This will generate your exp_folder, do not edit. 
    
   exp_settings.exp_folder = get_exp_folder(exp_settings.field_to_sort_by, exp_settings.field_values, exp_settings.single_group, ...
        exp_settings.single_fly, save_settings.path_to_protocol, exp_settings.control_genotype);

end