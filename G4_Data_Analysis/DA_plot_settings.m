
function [exp_settings, normalize_settings, histogram_plot_settings, histogram_annotation_settings, ...
    CL_hist_plot_settings, timeseries_plot_settings, TC_plot_settings, save_settings] = DA_plot_settings()

%% Settings which need updating regularly (more static settings below)


   
    
% Save settings   
    %The path where you wish to save the results of the data analysis
    save_settings.save_path = '/Users/taylorl/Desktop';
    
    %The path to the protocol file, where group log files will be saved
    save_settings.results_path = "/Users/taylorl/Desktop/Protocol004_OpticFlow_KirShibire_01-09-20_13-23-42";
    
% Experiment settings
    %Genotypes (or values for the group) that are being analyzed. Note that
    %should be in the same order as the genotypes list in get_exp_folder.m
    exp_settings.genotypes = ["EmptySplit JFRC", "EmptySplit UAS", "Kir 1 Rearing"];
    %genotypes = ["empty-split", "LPLC-2", "LC-18", "T4_T5", "LC-15", "LC-25", "LC-11", "LC-17", "LC-4"];

    %If there is a control genotype, set it here
    exp_settings.control_genotype = '';
    
    %Name of the processed file it should pull data from (note processed
    %files in all fly folders should be named the same way)
    exp_settings.processed_data_file = 'KS_opticflow_G4_Processed_Data';
    

    
    %Log file will be named using this
    exp_settings.group_being_analyzed_name = 'OpticFlow_Kirshibire';
    
% Plot settings 

    %Date range displayed on histograms
    histogram_annotation_settings.date_range = "01/21/20 to 01/30/20";
    
    %OL_TS_conds indicates the layout of your timeseries figures. See
    %documentation for example. Leave empty ([]) for default layout.
    timeseries_plot_settings.OL_TS_conds = [];
    
%   timeseries_plot_settings.OL_TS_conds{1} = [1 3 5 7 9 11 13; 15 17 19 21 23 25 27; ...
%       29 31 33 34 35 36 37; 38 39 40 41 43 1 3; 5 7 9 11 13 15 17;...
%       19 21 23 25 27 29 31; 33 34 35 36 37 38 39]; %3x1, 3x3, 3x3 ON, 8x8 (4 x 2 plots)
%   timeseries_plot_settings.OL_TS_conds{2} = [17 19; 21 23; 25 27; 29 31]; %16x16, 64x3, 64x3 ON, 64x16 (4 x 2 plots)
%   timeseries_plot_settings.OL_TS_conds{3} = [33 34; 35 36; 37 38; 39 40]; %left and right Looms (4 x 2 plots)
%   timeseries_plot_settings.OL_TS_conds{4} = [41; 43]; %yaw and sideslip (2 x 1 plots)

    
    %Durations inform the x axis limits on timeseries plots. Leave empty
    %for the software to pull durations from the processed data, or create
    %an array like OL_TS_conds with x limit values instead of condition #'s
    timeseries_plot_settings.OL_TS_durations = []; 
    
%   timeseries_plot_settings.OL_TS_durations{1} = [3.5 1.62 3.5 1.62 3.5 1.62 3.5; 1.62 3.5 1.62 3.5 1.62 3.5 1.62; ...
%                  3.5 1.62 0.75 1.35 1.65 0.95 0.75; 1.35 1.65 0.95 2.35 2.35 3.5 1.62; 3.5 1.62 3.5 1.62 3.5 1.62 3.5; ...
%                  1.62 3.5 1.62 3.5 1.62 3.5 1.62; 0.75 1.35 1.65 0.95 0.75 1.35 1.65];
%   timeseries_plot_settings.OL_TS_durations{2} = [3.5 1.62; 3.5 1.62; 3.5 1.62; 3.5 1.62];
%   timeseries_plot_settings.OL_TS_durations{3} = [0.75 1.35; 1.65 0.95; 0.75 1.35; 1.65 0.95];
%   timeseries_plot_settings.OL_TS_durations{4} = [2.35; 2.35];

    
    %Axis labels for the timeseries plots [x, y]. For multiple figures,
    %make it a cell array with each cell element corresponding to that
    %figure in the OL_TS_conds array.
%     timeseries_plot_settings.OL_TSconds_axis_labels{1} = ["Time(sec)", "LmR"];
%     timeseries_plot_settings.OL_TSconds_axis_labels{2} = ["Time(sec)", "faLmR"];

    timeseries_plot_settings.OL_TSconds_axis_labels = {};

    
    %An array of figure names for each figure of timeseries plots. This is
    %per datatype. If you are using the default timseries layout, it will
    %plot 30 timeseries subplots per figure, so divide your total number of
    %plotted conditions by 30 to determine how many figures there will be. 
    %Should correspond to datatypes.
    timeseries_plot_settings.figure_names = ["LmR"];
    
%datatype options for flying data: 'LmR_chan', 'L_chan', 'R_chan', 'F_chan', 'Frame Position', 'LmR', 'LpR', 'faLmR'
%datatype options for walking data: 'Vx0_chan', 'Vx1_chan', 'Vy0_chan', 'Vy1_chan', 'Frame Position', 'Turning', 'Forward', 'Sideslip'
    
    %The datatype to plot as timeseries
    timeseries_plot_settings.OL_datatypes = {'LmR'};
    
    %Set this to 1 if you are plotting only a single group and want lines
    %plotted for each fly as well as the average.
    timeseries_plot_settings.show_individual_flies = 0;
    
    %plot the frame position under each timeseries plot
    timeseries_plot_settings.frame_superimpose = 1;
    
    %plot both directions for each condition on the same axis. 
    timeseries_plot_settings.plot_both_directions = 1;
    
    %If you want the plots to have their own plot titles, make a cell array
    %of titles corresponding to the OL_TS_conds array. IF left empty, a
    %default array will be made by combining the pattern and function name of that condition. If you want no
    %plot titles, set cond_name = 0
    timeseries_plot_settings.cond_name = [];
    

    %Create array to dictate layout of CL histograms or leave empty for def
    CL_hist_plot_settings.CL_hist_conds = [];
    
    %Datatypes for which to plot closed-loop histograms
    CL_hist_plot_settings.CL_datatypes = {'Frame Position'}; %datatypes to plot as histograms          
    
    %Create the layout of tuning curves in this array. It works differently
    %than OL_TS_conds - see documentation for details.
    TC_plot_settings.OL_TC_conds = [];
    
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
    

%Further settings that may not need adjusting often    
    %% Normalization Settings

    normalize_settings.normalize_to_baseline = {'LpR'};%datatypes to normalize by setting the baseline value to 1
    normalize_settings.baseline_startstop = [0 1]; %start and stop times to use for baseline normalization
    normalize_settings.normalize_to_max = {'LmR'}; %datatypes to normalize by setting the maximum (or minimum) values to +1 (or -1)
    normalize_settings.max_startstop = [1 3]; %start and stop times to use for max normalization
    normalize_settings.max_prctile = 98; %percentile to use as a more robust estimate of the maximum value

    %% Plot Settings for basic Histograms

    histogram_plot_settings.histogram_ylimits = [0 100; -6 6; 2 10];
    histogram_plot_settings.subtitle_FontSize = 8;
    histogram_plot_settings.rep_colors = [0.5 0.5 0.5; 1 0.5 0.5; 0.25 0.75 0.25; 0.5 0.5 1; 1 0.75 0.25; 0.75 0.5 1; 0.5 1 0.5; 0.5 1 1; 1 0.5 1; 1 1 0.5]; %default 10 colors supports up to 10 groups (add more colors for more groups)
    histogram_plot_settings.mean_colors = [0 0 0; 1 0 0; 0 0.5 0; 0 0 1; 1 0.5 0; .75 0 1; 0 1 0; 0 1 1; 1 0 1; 1 1 0]; %default 10 colors supports up to 10 groups (add more colors for more groups)
    histogram_plot_settings.rep_LineWidth = 0.05;
    histogram_plot_settings.mean_LineWidth = 1;

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
    timeseries_plot_settings.yLabel_fontSize = 10;
    timeseries_plot_settings.xLabel_fontSize = 10;
    timeseries_plot_settings.overlap = 0; %not working
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
       

    %% Save settings

    save_settings.paperunits = 'inches';
    save_settings.x_width = 8; 
    save_settings.y_width = 10;
    save_settings.orientation = 'landscape';
    
    
        %% TO ADD A NEW MODULE
        %If there are any settings necessary for new module, add them to
        %one of the existing settings structs or create a new struct (more
        %work)

end