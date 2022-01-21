
function  Simple_DA_settings()

%% THIS IS A SIMPLIFIED VERSION OF THE FULL DATA ANALYSIS SET UP. If you want to run automatic data analysis,
% but don't want to fill out the long, complex settings file that goes with
% it, you can instead fill out this much shorter file. You will not get the
% customization options you get with the full data analysis, but it will
% provide a faster and easier way to look at your data for general patterns or
% phenotypes before deciding on a more in-depth analysis. Once the
% variables in this file are set to the correct values, save the file and
% then run it in the command line by calling its function name
% Simple_DA_settings();

%% EXPERIMENT SETTINGS - Paths, analysis type, how to select flies for analysis
    

    % Where do you want to save your settings file for this data analysis? 
    settings_path = 'C:\Users\taylo\Documents\Programming\Reiser\simMel';

    %What filename would you like to give the settings file for this data
    %analysis? 
    filename = 'SingleGroupAnalysis';

    % The path to your processing settings for this protocol
    exp_settings.path_to_processing_settings = 'C:\Users\taylo\Documents\Programming\Reiser\simMel\afterExp_ProcessSettings1.mat';
    
    %The path where you wish to save the results of the data analysis
    save_settings.save_path = 'C:\Users\taylo\Documents\Programming\Reiser\simMel\SingleGroupAnalysis';
    
    %The path where the pdf report of the results should be saved,
    %including the name of the pdf report file and its extension (.pdf). 
    save_settings.report_path = 'C:\Users\taylo\Documents\Programming\Reiser\simMel\SingleGroupAnalysis\DA_report.pdf';        

    %Set this equal to 1 if you will only be analyzing a single fly.
    %Otherwise, set this equal to 0
    exp_settings.single_fly = 0;
    
    % Set this equal to 1 if you are analyzing a single group of flies.
    % Otherwise set it equal to 0
    exp_settings.single_group = 1;
    
    %If you're running a single fly (the above variable single_fly is set to 1), 
    % you need to provide the path to that fly folder
    exp_settings.fly_path = 'C:\Users\taylo\Documents\Programming\Reiser\simMel\OreR-15_28_08';

    %The following variable determines which flies will be included in the
    %analysis. If single_fly = 1, it is irrelevant and can be left as is.
    %Otherwise, field_to_sort_by should contain one or more metada field
    %names, matching them as they are in the metadata file exactly.
    %Field_values should contain the value you want to pull for the
    %corresponding field. Fly group 1 will be flies that have the metadata
    %field field_to_sort_by{1} equal to field_values{1}. Fly group 2 will
    %be flies that have the meatdata field field_to_sort_by{2} equal to
    %field_values{2}. See examples and
    %more details here: 
    % https://reiserlab.github.io/Modular-LED-Display/Generation%204/Display_Tools/docs/data-handling_analysis.html#field-to-sort-by
    
    % NOTE THAT USING MULTIPLE FIELDS PER GROUP WILL NOT WORK! In the full
    % data analysis software, you may create groups by matching multiple
    % metadata fields, i.e. flies of a particular genotype AND age in one
    % group. There are examples of this in the documentation, but it WILL
    % NOT WORK in the simplified data analysis. You are limited to grouping
    % by only one metadata field.
    exp_settings.field_to_sort_by{1} = ["fly_genotype"];
%    exp_settings.field_to_sort_by{2} = ["fly_genotype"];
%     exp_settings.field_to_sort_by{3} = ["fly_genotype", "experimenter"];
%     exp_settings.field_to_sort_by{4} = ["fly_genotype", "experimenter"];

    %If plot_all_genotypes is 1, leave field_values empty.   
%    exp_settings.field_values = {};
    exp_settings.field_values{1} = ["OreR"];
%    exp_settings.field_values{2} = ["sim192"];
%     exp_settings.field_values{3} = ["OL0042B_UAS_Kir_JFRC49", "arrudar"];
%     exp_settings.field_values{4} = ["OL0042B_UAS_Kir_JFRC49", "kappagantular"];

    % You may provide a field to sort by and leave field_values empty if
    % you set plot_all_genotypes to 1. This means all flies in the
    % experiment folder will be sorted into groups based on the values for
    % that field, and however many groups that ends up being will be
    % included in the analysis. Set it to 0 if you want to provide the
    % field values you want included in the analysis instead. 

    %1 - each genotype (or value for the given field) will be plotted in its own figure against a control. 
    %0 - only groups with the field values you provided will be plotted 
    exp_settings.plot_all_genotypes = 0; 
   
    % If one of your groups is a control, provide the control value you for
    % the metadata field you are sorting by. It should match one of the
    % values in the field_values array above. If no control, leave empty
    % (meaning control_genotype = '')
    exp_settings.control_genotype = '';

    % Set this equal to 1 if you want two copies of each plot, one
    % normalized and one unnormalized. Set it to 0 if you only want to plot
    % normalized data.
    exp_settings.plot_norm_and_unnorm = 1;  

    % Give your analysis a name. Log file will be named using this
    exp_settings.group_being_analyzed_name = 'simMel OreR';

%% TIMESERIES SETTINGS - if you don't want timeseries plots, can leave as is

    % Which datatypes would you like plotted as timeseries. Options
    % for flying data are: 'LmR_chan', 'L_chan', 'R_chan', 'F_chan', 'Frame Position',
    % 'LmR', 'LpR', and 'faLmR'. The last three are the only ones commonly
    % used for timeseries. Options for walking data are: 'Vx0_chan', 'Vx1_chan', 
    % 'Vy0_chan', 'Vy1_chan', 'Frame Position', 'Turning', 'Forward', 'Sideslip'

    timeseries_plot_settings.OL_datatypes = {'LmR', 'faLmR'};

    % If your conditions come in symmetrical pairs and you want those pairs
    % plotted on the same axis, set this to 1. Otherwise, set it to 0.
    timeseries_plot_settings.plot_both_directions = 1;
    
    % Leave this empty if plot_both_directions is set to 0. You may also leave
    % this empty if plot_both_directions is set to 1 but the condition pairs are consecutive
    % (ie, you want conditions 1-2 on the same axis, 3-4, 5-6, etc). 
    % If you want to pair your conditions in some other way,
    % provide the pairs as shown in the commented out example.
    timeseries_plot_settings.opposing_condition_pairs = [];
%     timeseries_plot_settings.opposing_condition_pairs{1} = [1 6];
%     timeseries_plot_settings.opposing_condition_pairs{2} = [2 5];
%     timeseries_plot_settings.opposing_condition_pairs{3} = [3 8];
%     timeseries_plot_settings.opposing_condition_pairs{4} = [4 7];
%     timeseries_plot_settings.opposing_condition_pairs{5} = [9 10];
%     timeseries_plot_settings.opposing_condition_pairs{6} = [10 9];
%     timeseries_plot_settings.opposing_condition_pairs{7} = [11 12];
%     timeseries_plot_settings.opposing_condition_pairs{8} = [12 11];
%     timeseries_plot_settings.opposing_condition_pairs{9} = [13 18];
%     timeseries_plot_settings.opposing_condition_pairs{10} = [14 17];
%     timeseries_plot_settings.opposing_condition_pairs{11} = [15 20];
%     timeseries_plot_settings.opposing_condition_pairs{12} = [16 19];
%     timeseries_plot_settings.opposing_condition_pairs{13} = [21 26];
%     timeseries_plot_settings.opposing_condition_pairs{14} = [22 25];
%     timeseries_plot_settings.opposing_condition_pairs{15} = [23 28];
%     timeseries_plot_settings.opposing_condition_pairs{16} = [24 27];
    
    % Set this to 1 if you are plotting a single group and want lines
    % plotted for each fly as well as the average. Otherwise leave it at 0
    timeseries_plot_settings.show_individual_flies = 1;
    
    % Set this to 1 if you are plotting only a single fly and want lines
    % plotted for each repetition as well as the fly's average. Otherwise
    % leave it at 0.
    timeseries_plot_settings.show_individual_reps = 0;

%% FALMR TIMESERIES SETTINGS - if faLmR is not included in your timeseries datatypes, you may ignore these
        
    % If you'd like your faLmR data (which has already been flipped and
    % averaged) plotted in pairs, two lines per axis, set this equal to 1. You
    % will need to provide the pairings below. Otherwise, set this to 0 and
    % skip the next variable, faLmR_pairs.
    timeseries_plot_settings.faLmR_plot_both_directions = 0;
    
    % Your data processing already flipped and averaged the correct conditions together
    % to generate the faLmR dataset. If you'd like to plot these pairs on
    % the same axis - ie, if in the processing step conditions 1 and 6 were
    % flipped and averaged together and conditions 2 and 5 were flipped and
    % averaged together and now you'd like to plot both these averages on
    % the same axis - that's what faLmR_pairs is for. It will look just
    % like the opposing_condition_pairs above, but will reference the
    % pairing in your processing settings. So for example, a 1 here refers
    % to your first pair in the processing settings instead of the first condition. 2 refers to the second
    % pair, etc. 

    % If this is empty and faLmR_plot_both_directions = 1, it will by default plot the first two pairs
    % together, the second two pairs together, etc. I would recommend
    % setting your pairing in processing settings up that way so that you
    % don't have to dictate pairs here as well.
    timeseries_plot_settings.faLmR_pairs = [];
%     timeseries_plot_settings.faLmR_pairs{1} = [1 4];
%     timeseries_plot_settings.faLmR_pairs{2} = [2 3];
%     etc...

%% CLOSED LOOP HISTOGRAM SETTINGS - you may skip these if you do not want to plot closed-loop histograms

    % Datatypes for which to plot closed-loop histograms. Options are the
    % same as for timeseries datatypes.
    CL_hist_plot_settings.CL_datatypes = {'Frame Position'};     

%% TUNING CURVE SETTINGS - you may skip these if you do not want to plot tuning curves

    % Datatypes for which to plot tuning curves. Options are the same as
    % for timeseries datatypes
    TC_plot_settings.TC_datatypes = {'LmR'};

    % The x-axis values for tuning curves
    TC_plot_settings.xaxis_values = [0.625 1.25 2.5 5 10 20 40 60];

    % For tuning curves you must provide the label for the x axis
    TC_plot_settings.xaxis_label = "Frequency (Hz)";

    % For tuning curves, you must indicate what conditions should be
    % included in each curve. The following array follows this pattern: 
    % OL_TC_conds{figure #}{row #} = [condition #'s on first tuning curve;
    % condition #'s on second tuning curve; ...]; The commented out example
    % creates two figures, each with three rows, one tuning curve on each row and
    % 8 conditions included in each tuning curve. You may adjust this as
    % needed. Note that the number of conditions in each curve should match
    % the number of xaxis values provided above. 

%    TC_plot_settings.OL_TC_conds = [];
      TC_plot_settings.OL_TC_conds{1}{1} = [1 2 3 4 5 6 7 8];
      TC_plot_settings.OL_TC_conds{1}{2} = [9 10 11 12 13 14 15 16];
      TC_plot_settings.OL_TC_conds{1}{3} = [17 18 19 20 21 22 23 24];
      TC_plot_settings.OL_TC_conds{2}{1} = [25 26 27 28 29 30 31 32];
      TC_plot_settings.OL_TC_conds{2}{2} = [33 34 35 36 37 38 39 40];
      TC_plot_settings.OL_TC_conds{2}{3} = [41 42 43 44 45 46 47 48];

%% DO NOT EDIT BELOW HERE - this code runs separate functions that generate
% values for all the customizable options in the full data analyis
% that are not found here. 

    setup_simple_da_settings(exp_settings, save_settings, timeseries_plot_settings, ...
        CL_hist_plot_settings, TC_plot_settings, settings_path, filename);
    
end