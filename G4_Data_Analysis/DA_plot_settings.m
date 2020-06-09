
function [exp_settings, histogram_plot_settings, histogram_annotation_settings, ...
    CL_hist_plot_settings, timeseries_plot_settings, TC_plot_settings, ...
    MP_plot_settings, pos_plot_settings, save_settings, comp_settings, gen_settings] = DA_plot_settings()

%% Settings which need updating regularly (more static settings below)

%[pretrial, intertrial, posttrial]
    exp_settings.trial_options = [1 1 1];
%% Settings for exp_folder generation
    
    exp_settings.field_to_sort_by{1} = ["fly_genotype"];
    exp_settings.field_to_sort_by{2} = ["fly_genotype"];
%    exp_settings.field_to_sort_by{3} = ["fly_genotype"];
%        exp_settings.field_to_sort_by{2} = ["fly_genotype"];

    %if plot_all_genotypes is 1, leave field_values empty.
    
%    exp_settings.field_values = {};
     exp_settings.field_values{1} = ["emptySplit_UAS_Kir_JFRC49"];      
     exp_settings.field_values{2} = ["OL0010B_UAS_Kir_JFRC49"];
%    exp_settings.field_values{2} = ["OL0042B_UAS_Kir_JFRC49"];
%   exp_settings.field_values{1} = ["SS00324_JFRC100_JFRC49"];

    exp_settings.single_group = 0;%1-all flies should be in one group, so exp_folder should be 1xX cell array
    exp_settings.single_fly = 0;%1- only a single fly is being analyzed, the exp_folder will simply be the path to the fly

    %1 - each genotype will be plotted in its own figure against a control. 
    %0 - groups will be plotted as laid out below. 
    exp_settings.plot_all_genotypes = 0; 
   
     %control must match exactly the metadata genotype value. 
    exp_settings.control_genotype = 'emptySplit_UAS_Kir_JFRC49';

    %This is the path to the protocol
    save_settings.path_to_protocol = "/Users/taylorl/Desktop/bad_flies";
    
    exp_settings.genotypes = ["ES", "T4-T5"];
    %genotypes = ["empty-split", "LPLC-2", "LC-18", "T4_T5", "LC-15", "LC-25", "LC-11", "LC-17", "LC-4"];

%% Save settings
    
% Save settings   
    %The path where you wish to save the results of the data analysis
    save_settings.save_path = '/Users/taylorl/Desktop/bad_flies';

%% Experiment settings

    exp_settings.plot_norm_and_unnorm = 1;%1 or 0.

    exp_settings.processed_data_file = 'testing_new_processing';

    %Log file will be named using this
    exp_settings.group_being_analyzed_name = 'smallfield_Kir';
    
%% Histogram settings 

    %Date range displayed on histograms
    histogram_annotation_settings.annotation_text = "Annotation text here.";

%% Timeseries plot settings
    %OL_TS_conds indicates the layout of your timeseries figures. See
    %documentation for example. Leave empty ([]) for default layout.
    timeseries_plot_settings.OL_TS_conds{1} = [1 2 3 4; 5 6 7 8; 9 10 11 12];
    timeseries_plot_settings.OL_TS_conds{2} = [13 14 15 16; 17 18 19 20; 21 22 23 24];

    % Durations inform the x axis limits on timeseries plots. Leave empty
    %for the software to pull durations from the processed data, or create
    %an array like OL_TS_conds with x limit values instead of condition
    %#'s. See documentation for example.
    timeseries_plot_settings.OL_TS_durations = []; 

    %Axis labels for the timeseries plots [x, y]. For multiple figures,
    %make it a cell array with each cell element corresponding to that
    %figure in the OL_TS_conds array. See documentation for example.
    timeseries_plot_settings.axis_labels = {};

    %An array of figure names for each figure of timeseries plots. 
    timeseries_plot_settings.figure_names = ["LmR", "LpR"];
    
    timeseries_plot_settings.subplot_figure_names{1} = ["LmR Conds 1-12"; "LpR Conds 1-12"]; %Cell array with same num cell elements as OL_TS_conds. 
    %Each cell should have one name for each datatype
    timeseries_plot_settings.subplot_figure_names{2} = ["LmR Conds 13-24"; "LpR Conds 13-24"];
    
%datatype options for flying data: 'LmR_chan', 'L_chan', 'R_chan', 'F_chan', 'Frame Position', 'LmR', 'LpR', 'faLmR'
%datatype options for walking data: 'Vx0_chan', 'Vx1_chan', 'Vy0_chan', 'Vy1_chan', 'Frame Position', 'Turning', 'Forward', 'Sideslip'
    
    %The datatype to plot as timeseries
    timeseries_plot_settings.OL_datatypes = {'LmR', 'LpR'};
    
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
    CL_hist_plot_settings.axis_labels = {};
    
    %Datatypes for which to plot closed-loop histograms
    CL_hist_plot_settings.CL_datatypes = {'Frame Position'}; %datatypes to plot as histograms          

%% Tuning Curve plot settings
    %Create the layout of tuning curves in this array. It works differently
    %than OL_TS_conds - see documentation for details.
    TC_plot_settings.OL_TC_conds{1}{1} = [1 3 5 7];
    TC_plot_settings.OL_TC_conds{1}{2} = [9 11 13 15];
    TC_plot_settings.OL_TC_conds{2}{1} = [17 19 21 23];
    TC_plot_settings.OL_TC_conds{2}{2} = [25 27 29 31];
    
    %If you want your tuning curves to have their own plot titles, make an
    %array of titles for each PLOT (not each condition). So this should be
    %a cell array like with the timeseries. A cell element for each figure,
    %and each cell having an array matching the layout of the figure. If you want no
    %plot titles, set cond_name = 0
    TC_plot_settings.cond_name = [];
    
    %The xaxis label for tuning curves
%     TC_plot_settings.TC_axis_labels{1} = ["Frequency(Hz)","LmR"];
%     TC_plot_settings.TC_axis_labels{2} = ["Frequency(Hz)", "LpR"];
    TC_plot_settings.axis_labels = {};
    TC_plot_settings.figure_names = [];
    TC_plot_settings.subplot_figure_names{1} = ["LmR Conds 1-15"; "LpR Conds 1-15"];
    TC_plot_settings.subplot_figure_names{2} = ["LmR Conds 17-31"; "LpR Conds 17-31"];
    
    %The x-axis values for tuning curves
    TC_plot_settings.xaxis_values = [0.625 1.25 2.5 5 10 20 40];
    
    %Datatypes for which to plot tuning curves
    TC_plot_settings.TC_datatypes = {'LmR','LpR'}; 
    
    %Plots tuning curves for both directions on the same axis
    TC_plot_settings.plot_both_directions = 1; 
    
%% Position-Series P and M Plot Settings

    MP_plot_settings.mp_conds{1} = [1 3 5 7; 9 11 13 15];
    MP_plot_settings.mp_conds{2} = [17 19 21 23; 25 27 29 31];
    
    MP_plot_settings.xaxis = [1:192]; %Standard x axis, only change if the number of frames has changed
    
    %MP_plot_settings.new_xaxis = [];
%    MP_plot_settings.new_xaxis = (360/MP_plot_settings.xaxis(end))*[(MP_plot_settings.xaxis) - 96]; %use this option to
    %plot M and P against angular position, left being negative, right
    %being positive
    
    MP_plot_settings.new_xaxis = circshift((360/MP_plot_settings.xaxis(end))*[(MP_plot_settings.xaxis) - 96], 96); %use
    %this option to plot M and P against angular position, centered so left
    %is positive and right is negative. 
    MP_plot_settings.plot_MandP = 1;
    MP_plot_settings.figure_names =  ["M", "P"]; 
    MP_plot_settings.subplot_figure_names{1} = ["M conds 1-15"; "M conds 16-31"];
    MP_plot_settings.subplot_figure_names{2} = ["P conds 1-15"; "P conds 16-31"];
    MP_plot_settings.axis_labels{1} = ["Frame Position", "Motion-Dependent Response"]; %{xlabel, ylabel}
    MP_plot_settings.axis_labels{2} = ["Frame Position", "Position-Dependent Response"];
    MP_plot_settings.cond_name{1} = ["3x1 Sweep 0.35 Hz", "3x1 Sweep 1.07 Hz" ,"3x3 Sweep 0.35 Hz", "3x3 Sweep 1.07 Hz"; ...
        "3x3 ON Sweep 0.35 Hz" ,"3x3 ON Sweep 1.07 Hz" ,"8x8 Sweep 0.35" ,"8x8 Sweep 1.07"]; %Titles of subplots - correspond to pos_conds
    MP_plot_settings.cond_name{2} = ["16x16 Sweep 0.35 Hz", "16x16 Sweep 1.07 Hz", "64x3 Sweep 0.35Hz", "64x3 Sweep 1.07 Hz"; ...
        "64x3 ON Sweep 0.35 Hz", "64x3 ON Sweep 1.07 Hz", "64x16 Sweep 0.35 Hz", "64x16 Sweep 1.07 Hz"];
    MP_plot_settings.show_individual_flies = 0;
    MP_plot_settings.ylimits = []; %[M ymin ymax; P ylmin ymax];
    MP_plot_settings.xlimits = []; %[M xmin xmax; P xmin xmax];

    
    
%% Position-Series Averages Plot Settings
    
    pos_plot_settings.plot_pos_averaged = 1;
    pos_plot_settings.plot_opposing_directions = 0;
%    pos_plot_settings.pos_conds = [];
    pos_plot_settings.pos_conds{1} = [1 3 5 7; 9 11 13 15];
    pos_plot_settings.pos_conds{2} = [17 19 21 23; 25 27 29 31];
    pos_plot_settings.figure_names = [];
    
    pos_plot_settings.subplot_figure_names = ["Pos Series 1-15"; "Pos Series 17-31"];

    pos_plot_settings.axis_labels = ["X Label", "Y Label"];
%     pos_plot_settings.cond_name{1} = ["3x1 Sweep 0.35 Hz", "3x1 Sweep 1.07 Hz" ,"3x3 Sweep 0.35 Hz", "3x3 Sweep 1.07 Hz"; ...
%         "3x3 ON Sweep 0.35 Hz" ,"3x3 ON Sweep 1.07 Hz" ,"8x8 Sweep 0.35" ,"8x8 Sweep 1.07"];
%     pos_plot_settings.cond_name{2} = ["16x16 Sweep 0.35 Hz", "16x16 Sweep 1.07 Hz", "64x3 Sweep 0.35Hz", "64x3 Sweep 1.07 Hz"; ...
%         "64x3 ON Sweep 0.35 Hz", "64x3 ON Sweep 1.07 Hz", "64x16 Sweep 0.35 Hz", "64x16 Sweep 1.07 Hz"];
    pos_plot_settings.cond_name = [];
    pos_plot_settings.show_individual_flies = 0;
    pos_plot_settings.ylimits = [];
    pos_plot_settings.xlimits = [];
    pos_plot_settings.xaxis = [1:192];%Standard x axis, only change if the number of frames has changed
    pos_plot_settings.new_xaxis = circshift((360/MP_plot_settings.xaxis(end))*[(MP_plot_settings.xaxis) - 96], 96); %use
    %this option to plot M and P against angular position, centered so left;

%    pos_plot_settings.new_xaxis = (360/MP_plot_settings.xaxis(end))*[(MP_plot_settings.xaxis) - 96]; %use this option to
%    plot position series against angular position, left being negative, right
%    being positive
    
    %pos_plot_settings.new_xaxis = [];
    
    
%% Comparison figure settings

    comp_settings.plot_order = {'LmR','pos','M','P'};
    comp_settings.conditions = [1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31];
    comp_settings.rows_per_fig = 4;
    comp_settings.ylimits = [0 0];
    comp_settings.figure_names = {'Comparison1-7', ...
        'Comparison9-15', 'Comparison17-23', 'Comparison25-31'};
    comp_settings.subplot_figure_names = {'LmR, Pos, M, P 1-7', 'LmR, Pos, M, P 9-15', ...
        'LmR, Pos, M, P 17-23', 'LmR, Pos, M, P 25-31'};
    comp_settings.cond_name{1} = ["Cond1 LmR", "Cond1 Pos Series", "Cond1 M", "Cond1 P";...
        "Cond3 LmR", "Cond3 Pos Series", "Cond3 M", "Cond3 P"; "Cond5 LmR", "Cond5 Pos Series", "Cond5 M", "Cond5 P";...
        "Cond7 LmR", "Cond7 Pos Series", "Cond7 M", "Cond7 P"];
     comp_settings.cond_name{2} = ["Cond9 LmR", "Cond9 Pos Series", "Cond9 M", "Cond9 P";...
        "Cond11 LmR", "Cond11 Pos Series", "Cond11 M", "Cond11 P"; "Cond13 LmR", "Cond13 Pos Series", "Cond13 M", "Cond13 P";...
        "Cond15 LmR", "Cond15 Pos Series", "Cond15 M", "Cond15 P"];
     comp_settings.cond_name{3} = ["Cond17 LmR", "Cond17 Pos Series", "Cond17 M", "Cond17 P";...
        "Cond19 LmR", "Cond19 Pos Series", "Cond19 M", "Cond19 P"; "Cond21 LmR", "Cond21 Pos Series", "Cond21 M", "Cond21 P";...
        "Cond23 LmR", "Cond23 Pos Series", "Cond23 M", "Cond23 P"];
    comp_settings.cond_name{4} = ["Cond25 LmR", "Cond25 Pos Series", "Cond25 M", "Cond25 P"; ...
        "Cond27 LmR", "Cond27 Pos Series", "Cond27 M", "Cond27 P"; "Cond29 LmR", "Cond29 Pos Series", "Cond29 M", "Cond29 P"; ...
        "Cond31 LmR", "Cond31 Pos Series", "Cond31 M", "Cond31 P"];
    comp_settings.norm = 1;
    
    

%% Further settings that may not need adjusting often 

%% Position series settings

    
    %% Normalization Settings

%     normalize_settings.normalize_to_baseline = {'LpR'};%datatypes to normalize by setting the baseline value to 1
%     normalize_settings.baseline_startstop = [0 1]; %start and stop times to use for baseline normalization
%     normalize_settings.normalize_to_max = {'LmR'}; %datatypes to normalize by setting the maximum (or minimum) values to +1 (or -1)
%     normalize_settings.max_startstop = [1 3]; %start and stop times to use for max normalization
%     normalize_settings.max_prctile = 98; %percentile to use as a more robust estimate of the maximum value

%% GENERAL PLOT SETTINGS
    gen_settings.figTitle_fontSize = 12;
    gen_settings.subtitle_fontSize = 8;
    gen_settings.legend_fontSize = 6;
    gen_settings.yLabel_fontSize = 6;
    gen_settings.xLabel_fontSize = 6;
    gen_settings.axis_num_fontSize = 6;
    gen_settings.axis_label_fontSize = 6;
    gen_settings.fly_colors = [.95 .95 .95; .9 .9 .9; .85 .85 .85; .8 .8 .8; .75 .75 .75; .7 .7 .7; .65 .65 .65; .6 .6 .6; .55 .55 .55; .5 .5 .5; .45 .45 .45;  .4 .4 .4; .35 .35 .35; .3 .3 .3; .25 .25 .25; .2 .2 .2; .15 .15 .15; .1 .1 .1]; %Colors assigned to individual fly lines
    gen_settings.rep_colors = [0 0 0; 1 0 0; 0 0.5 0; 0 0 1; 1 0.5 0; .75 0 1; 0 1 0; 0 1 1; 1 0 1; 1 1 0]; %default 10 colors supports up to 10 groups (add more colors for more groups)
    gen_settings.rep_lineWidth = 0.05;
    gen_settings.mean_colors = [1 0 0; 0 0 1; 0 0.5 0; 1 0.5 0; .75 0 1; 0 1 0;  1 0.5 1; 0 1 1; 1 0 1; 1 1 0]; %default 10 colors supports up to 10 groups (add more colors for more groups)
    gen_settings.control_color = [0 0 0];
    gen_settings.mean_lineWidth = 1;
    gen_settings.edgeColor = 'none';
    gen_settings.patch_alpha = 0.3; %sets the level of transparency for patch region around timeseries data


%% Plot Settings for basic Histograms

    histogram_plot_settings.histogram_ylimits = [0 100; -6 6; 2 10];
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
    
%datatype options for flying data: 'LmR_chan', 'L_chan', 'R_chan', 'F_chan', 'Frame Position', 'LmR', 'LpR', 'faLmR'
%datatype options for walking data: 'Vx0_chan', 'Vx1_chan', 'Vy0_chan', 'Vy1_chan', 'Frame Position', 'Turning', 'Forward', 'Sideslip'

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