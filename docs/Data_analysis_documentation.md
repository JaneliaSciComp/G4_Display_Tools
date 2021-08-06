---
title:  G4 Data Analysis
parent: G4 Automated Data Handling
grand_parent: Generation 4
nav_order: 2
---

1. TOC
{:toc}

# Prerequisites

[Data Processing](data_processing_documentation.md). Automated data handling is split into two sections - data processing and data analysis. You cannot analyze the data until it has been processed, so please see the data processing documentation first if you have not been through it. 

# Data Analysis Tools Documentation

The github repository at <https://github.com/JaneliaSciComp/G4_Display_Tools> has a suite of data analysis tools. Have a look at the [software installation guide](G4_Software_Setup.md) on how to set it up.

In the typical use case of these tools, there is one file you need to worry about: `DA_plot_settings.m` at `G4_Display_Tools/G4_Data_Analysis`. This file contains many matlab variables which will dictate the settings of how your data is visualized. You will need to go through this file and update the settings according to your needs. This is the biggest task of setting up data analysis. Once your settings are correct and saved, the analysis itself will take less than a minute to run. 

It is intended that, ideally, the user will create their data analysis settings at the same time that they create an experiment using the Designer and set up their data processing settings. You may want to set up two or three data analysis settings files, each of which will contain the settings for one type of analysis. Most commonly, this would be a settings file for plotting the data of a single fly, a settings file for plotting the data of a single group of flies (like a single genotype), and a settings file for plotting and comparing the data for many groups of flies. Each of these requires its own settings file, so it will be easiest if you create them at the same time as you create the experiment, so you don't have to go back and do it later. Once they've been created and saved, you can use them anytime to plot data. Data analysis settings can also be created and run anytime after an experiment has already been completed, so don't worry if you want to go back and do analysis on a previous experiment. This documentation will cover both scenarios. 
                  

# Plot Appearance Settings:

The first step to running analysis on your data is to create your settinsg file, so let's go over all the settings and what they do. Open `DA_plot_settings.m`. 

The settings are split into eight different structures (not necessarily listed in the same order as you'll find them in the file). Keep in mind you may not need all of them. That's okay, you don't have to use them all.

1. `Exp_settings`
   - These are experiment settings and should be updated each time you create a settings file.
2. `normalize_settings`
   - These are all settings related to the normalization of the data.
3. `histogram_plot_settings`
   - These are settings related to plotting basic histograms of your inter-trial data, or stripe fixation data. These are not the same as the closed-loop histograms. 
4. `histogram_annotation_settings`
   - These control how the histograms from 3 are annotated – font, line type, and many other things. 
5. `CL_hist_plot_settings`
   - These are the settings for closed-loop histograms
6. `timeseries_plot_settings`
   - Contains appearance settings for the timeseries plots
7. `TC_plot_settings`
   - Appearance settings for tuning curves
8. `save_settings`
   - These settings affect how the results are saved.
9. `MP_plot_settings`
   - These settings are for a particular kind of plot, referred as M and P plots. These stand for Motion-Dependent response and Position-Dependent response. They are related to position series. 
10. `pos_plot_settings`
   - Plot settings for basic position series plots (plotting your data against the position of the pattern on the screen instead of against time)
11. `comp_settings`
   - These are settings for a comparison plot. The comparison plot is a figure which places four plots side by side for each condition - LmR timeseries, position series, M plot and P plot.
12. `proc_settings`
   - These are settings retrieved from your data processing - you will not edit these, so you don't need to worry about them.   

We have tried to place all the settings that are regularly changed first in the file, meaning not all settings for each group are together. There is a second section toward the bottom of the file which contains settings from all of the above groups that will change less frequently. Let's go over the settings and what they mean in the order you will find them in `DA_plot_settings.m`.  

# Settings in more detail

Notice that we have tried to leave examples of each setting commented out. Rather than typing any code, you may just be able to uncomment the line which most closely matches your need then replace the actual values of the variable. Make sure if you do this, you comment out any other lines setting the same variable. For example, at approximately lines 25-30 you'll see this: 

`%    exp_settings.field_values = {};`
`   exp_settings.field_values{1} = ["metadata_field_value_1"];`
`%    exp_settings.field_values{2} = ["metadata_field_value_2"];`
`%     exp_settings.field_values{3} = ["metadata_field_value_1", "metadata_field_value_2"];`
`%     exp_settings.field_values{4} = ["metadata_field_value_1", "metadata_field_value_3"];`

In this case, all lines are commented out except for the second. If you wanted to leave this variable empty, you would simply type a `%` at the beginning of line 2 and remove the `%` at the beginning of line 1, creating this:

`    exp_settings.field_values = {};`
`%    exp_settings.field_values{1} = ["metadata_field_value_1"];`
`%    exp_settings.field_values{2} = ["metadata_field_vaue_2"];`
`%    exp_settings.field_values{3} = ["metadata_field_value_1", "metadata_field_value_2"];`
`%    exp_settings.field_values{4} = ["metadata_field_value_1", "metadata_field_value_3"];`

Alternatively, you may have more than one metadata field by which to sort your data (see the below section on Field Values for an explanation of what this setting does). In that case you would comment out line 1 and uncomment lines 1-4 (or however many you need)

`%    exp_settings.field_values = {};`
`    exp_settings.field_values{1} = ["metadata_field_value_1"];`
`    exp_settings.field_values{2} = ["metadata_field_vaue_2"];`
`%    exp_settings.field_values{3} = ["metadata_field_value_1", "metadata_field_value_2"];`
`%    exp_settings.field_values{4} = ["metadata_field_value_1", "metadata_field_value_3"];`

After uncommenting the lines you want, then you simply need to replace the text metadata_field_value_x with your value. The quotation marks, brackets, and other code elements can be left untouched. Much of the file can be filled out this way. 

Following is an explanation of each variable and what it does. 

## General experiment settings

### Path To Processing Settings

`exp_settings.path_to_processing_settings` is a character vector indicating the processing settings file you created for this protocol. 

Example: 
`exp_settings.path_to_processing_settings = '/Users/username/experiment_folder/processing_settings.mat';`

**NOTE** This path is used to get information from your processing settings, including the path to your protocol folder. This folder must be organized in a certain way for data analysis to work correctly. If you've maintained the default organization created when you run a fly through an experiment using the G4 Conductor, then you won't have to worry about this, but if you have manually changed the organization of your folder, you should ensure that your fly folders are two levels below your protocol folder. i.e. your folder's heirarchy should be protocl_folder -> subfolders -> fly folders -> individual fly data. If there are more or fewer levels than this, you may get a browse window during the analysis run wanting you to browse to the protocol folder, or you could get errors.

### Save Path

`save_settings.save_path` is a character vector indicating where you wish to save the results of your data analysis. Note that the results will likely include several figures and a final pdf report. 

Example: 
`save_settings.save_path = '/Users/username/experiment_folder/fly_folder/analysis';`

### Report Path

The results of your data analysis will be summarized in a final pdf report which will contain all your plots. `save_settings.report_path` is a character vector that indicates the path where you'd like that report. Note you should include in this path the name that you want to give the report and the '.pdf' extension. Please don't change the extension to this file as only .pdf is supported. 

Example:
`save_settings.report_path = '/Users/username/experiment_folder/group_folder/group_analysis_report.pdf';`


### Field to sort by:

`exp_settings.field_to_sort_by` is a cell array, each element being a regular array containing a string (note the double quotation marks instead of single). The "field" the variable name refers to is a metadata field. The metadata you fill out for your fly in the G4 Conductor is saved to a file for later use. This allows you to use metadata to pick only certain flies to be included in an analysis. This is not useful when analyzing a single fly but can be very useful when analyzing one or more groups of flies. This allows you to only pull flies which match certain metadata values into your data analysis. If you want to sort your flies by genotype and only genotype, you would set this to:

Example 1:
`exp_settings.field_to_sort_by{1} = ["fly_genotype"];`

Notice that the string `fly_genotype` must match exactly the field name for genotype in your metadata.mat file.

You can also group flies using more than one metadata field. Say you want only flies that are both of a certain genotype and of a certain age.
Example 2:
`exp_settings.field_to_sort_by{1} = ["fly_genotype", "fly_age"];`

This means you will have one group of flies, narrowed down both by genotype and by age (you will provide the values for these things later).

Now imagine you want to have two groups of flies. One group will be all flies that match a particular genotype. The second group will be all flies that match a particular genotype AND were run by a particular experimenter. These two groups will be plotted on your graphs for comparison. (Note in this case the second group would be a subgroup of the first). It would look like this: 
Example 3:
`exp_settings.field_to_sort_by{1} = ["fly_genotype"];`
`exp_settings.field_to_sort_by{2} = ["fly_genotype", "experimenter"];`

### Field values:

`exp_settings.field_values` is where you provide what values of the above fields you'd like included. It is an array just like `field_to_sort_by`, but in place of the field name you will put the value you want to match. So the corresponding `field_values` for the examples above would look something like:

Example1:
`field_values{1} = ["genotype_1"];`
The values you give here must match exactly the values in the `metadata.mat` file, and should be in double quotation marks.

Example 2: 
`exp_settings.field_values{1} = ["genotype_1", "3-6 days"];`
All flies of both this genotype AND this age will be put in a single group. Note "3-6 days" in this case is the value for "age" for a single fly. It does not tell the software to find all flies with metadata age values of 3,4, 5, or 6. 

Example 3: 
`exp_settings.field_values{1} = ["genotype_1"];`
`exp_settings.field_values{2} = ["genotype_1", "taylorl"];`
Will produce two groups of files to compare – first group has all flies of that genotype. Second group has all flies of that genotype AND run by that user. 

Please note that if you want multiple groups, even if each group is only determined by genotype, then you must have that many groups defined in field_to_sort_by AND field_values. So for example, if you have four different genotypes you want to plot against each other, these two variables together would look like this: 

`exp_settings.field_to_sort_by{1} = ["fly_genotype"];`
`exp_settings.field_to_sort_by{2} = ["fly_genotype"];`
`exp_settings.field_to_sort_by{3} = ["fly_genotype"];`
`exp_settings.field_to_sort_by{4} = ["fly_genotype"];`

`exp_settings.field_values{1} = ["genotype1"];`
`exp_settings.field_values{2} = ["genotype2"];`
`exp_settings.field_values{3} = ["genotype3"];`
`exp_settings.field_values{4} = ["genotype4"];`

HOWEVER, if those four genotypes are the ONLY genotypes of fly you have run through the protocol (so all flies in your experiment folder match one of those genotypes), then the easier way to do it is to set `exp_settings.plot_all_genotypes = 1` (covered below) and leave the field_values empty and field_to_sort_by as only `exp_settings.field_to_sort_by{1} = ["fly_genotype"];`. If you do this, each different genotype that can be found in the experiment folder will be plotted on its own axis against whichever genotype you establish as the control. 

**NOTE** If you are analyzing only a single fly, field_values should be empty.

### Single group:

Set `exp_settings.single_group` to 1 if you only want to plot a single group, 0 if you are plotting a single fly or multiple groups

Example: 
`exp_settings.single_group = 0;`

### Single fly:

Set `exp_settings.single_fly` to 1 if you only want to analyze a single fly, 0 if multiple flies/groups. 

Example:
`exp_settings.single_fly = 0;`

### Plot all genotypes: 

`exp_settings.plot_all_genotypes` should be either `0` or `1`. If it is set to `1`, then each fly of a particular value of `field to sort by` will be placed in a group together. All values will be grouped. This does not only apply to genotypes. If your `field_to_sort_by` is fly age, then this will separate all flies that have been run through the protocol by the age field into groups.  In addition, each group will be plotted individually against the control. If you have results for five genotypes and you set group1 as the control, you'll end up with four sets of graphs – group1 v group2, group1 v group3, etc.  Set this to 0 if you want to only include a subset of your total flies, or if you want to put them on all one plot together rather than comparing to the control one by one. 

### Control genotype: 

`exp_settings.control_genotype` should be a character vector with the value of your control. It should match exactly the value in the metadata.mat file. Ie if you're grouping by genotype and your control is the one with genotype2, your control genotype might be `'genotype2'`. If you do not want to compare against a control, leave this empty, meaning leave the single quotes with nothing in between them. 

Example: 
`exp_settings.control_genotype = 'genotype1';` or `exp_settings.control_genotype = '';`

### Genotypes

`exp_settings.genotypes` is an array of names, in double quotations, by which your groups should be labeled. These are intended to be simpler, human readable labels representing the metadata values. If you have set a control group, its label should come first, and the labels should otherwise be in the same order as `field_values`. If `field_values` is empty and `plot_all_genotypes` is set to 1, then the groups will be generated in the order than they are found in the file system. So in your first group folder (named as a date if you're using the default saving scheme), the first fly will dictate the first  and will get the first (non-control) label, the second fly will dictate the second group, etc. The label for the control should still go first.

Example: 
`exp_settings.genotypes = ["Control_genotype", "Genotype2", "Genotype3"];` for two groups being compared to a third control group

**Note:** When running an experiment through the Conductor, you have the option of running analysis on that single fly automatically when the experiment is over. If you do this, the Condcutor will automatically update this field (and a few others) to match the genotype of the fly being run, so don't worry about this being accurate in that case. 

### Plot norm and unnorm:

`exp_settings.plot_norm_and_unnorm` should be set to 0 or 1. If 1, whatever analysis you're doing will be done twice, once with unnormalized data and once again with normalized data. If it is set to zero, you will only get normalized results. 

Example:
`exp_settings.plot_norm_and_unnorm = 1;`

### Group_being_analyzed_name:

`exp_settings.group_being_analyzed_name` is a character vector (it should be inside single quotation marks) indicating the name of the group being analyzed. This does not need to match any other files or variables so make it something recognizable to you. It will be used to name the group log file. It could be the name of a single fly, a name defining the single group being analyzed, or a name that will remind you what groups are included in the analysis. Or you could simply give your different analyses unique names using this variable. 

Example: 
`exp_settings.group_being_analyzed_name = 'Protocol 1 all genotypes';`

### Annotation text: 

`histogram_annotation_settings.annotation_text` is text that will appear on the graph of your intertrial histograms. Any string you want enclosed in double quotes, or it can be left empty.

Example:
`histogram_annotation_settings.annotation_text = "important text for histogram";` or `histogram_annotation_settings.annotation_text = "";`

## Settings relating to timeseries plots

### Datatypes for which to create timeseries plots

`timeseries_plot_settings.OL_datatypes` should be a cell array of the datatypes for which to plot timeseries data. You may plot timeseries for as many or few datatypes as you like. 

The datatype options for flying data are: 'LmR_chan', 'L_chan', 'R_chan', 'F_chan', 'Frame Position', 'LmR', 'LpR', and 'faLmR'.

The datatype options for walking data are: 'Vx0_chan', 'Vx1_chan', 'Vy0_chan', 'Vy1_chan', 'Frame Position', 'Turning', 'Forward', and 'Sideslip'.

**Note** The last three datatypes of each are most likely the data you'd want to plot as timeseries, as these have been processed and aligned properly. The first five are raw data. 

Example: 
`timeseries_plot_settings.OL_datatypes = {'LmR', 'faLmR'};` Note the use of single quotes, curly brackets, and the comma. Capitalization DOES matter. 

### Timeseries conditions

`timeseries_plot_settings.OL_TS_conds` is a variable allows you to layout your timeseries plot figures exactly how you want them. If you are happy with the default layout, which will put 30 subplots on a figure in 6 rows x by 5 columns, then leave this variable empty (`OL_TS_conds = [];`)

To layout the figures yourself, you will make OL_TS_conds a cell array, with each cell element representing one figure. Each cell array will contain a regular array of condition numbers laid out in the format of the subplots. 

Example: 
`timeseries_plot_settings.OL_TS_conds{1} = [1 3 5 7; 9 11 13 15];`
`timeseries_plot_settings.OL_TS_conds{2} = [17 19; 21 23; 25 27; 29 31];`

The above code will create two figures, each containing 8 timeseries plots. The first figure will have two rows of four plots, and be laid out like:

| Condition 1 | Condition 3  | Condition 5  | Condition 7  |
| Condition 9 | Condition 11 | Condition 13 | Condition 15 |

The second figure, on the other hand, will contain four rows of two figures each and look like this: 

| Condition 17 | Condition 19 |
| Condition 21 | Condition 23 |
| Condition 25 | Condition 27 |
| Condition 29 | Condition 31 |

The placement of the semi-colons determines where the break in row occurs. Note that each row in a set of square brackets must be the same length (so you could not make this [17 19; 21 23 25; 27 29; 31] for example).

In this way, you can plot any condition in any position on the figure. They do not have to be in numerical order. Note that if you're plotting more than one datatype, a figure is created for each datatype, so the above code, when run on two datatypes, would create four figures. Two for one datatype and two for the other. 

**Note: Later you will be given the option to pair conditions up so that two conditions are plotted on each axis for comparison instead of one. In this case, your conds array should only contain the first condition of each pair. This is why our example shows only odd conditions. In this example, the even conditions are plotted on the same axis as the condition before them, so we do not need to list them in this array. This will make more sense when you reach the `opposing_condition_pairs` setting.**

### Timeseries durations

`timeseries_plot_settings.OL_TS_durations` is an array just like `OL_TS_conds` above but provides the duration of that condition. This array can usually be left empty. The software will pull the duration of each condition from the experiment protocol and use this as the x-limit for the condition's timeseries plot. However, if you want the x-limit of one or more of your timeseries plots to be different than the plotted condition's duration, then you would need to create this array yourself. It will match OL_TS_conds in size and shape exactly, but instead of condition number, you would provide the maximum x limit for the plot (in seconds). 

Example:
The durations array corresponding to the above OL_TS_conds array might look something like this:

`timeseries_plot_settings.OL_TS_durations{1} = [1.5 3.12 1.5 3.12; 1.5 3.12 1.5 3.12]`
`timeseries_plot_settings.OL_TS_durations{2} = [1 3; 1 3; 1 3; 1 3];`

…indicating that conditions 1, 5, 9 and 13 have durations of 1.5 seconds, 3, 7, 11, and 15 have durations of 3.12 seconds, 17, 21, 25, 29 have durations of 1 second, etc.

If you left `OL_TS_conds` empty, leave this array empty as well (`timeseries_plot_settings.OL_TS_durations = [];`). The program will deduce the condition durations from the processed data and create a default durations array.


### Condition Names

`timeseries_plot_settings.cond_name` is a cell array that also corresponds to `OL_TS_conds` in shape and size. In this case, instead of condition number, you would provide a string (in double quotation marks) that will act as the title for that plot. These titles will be generated by default if you leave the array empty (`timeseries_plot_settings.cond_name = [];`) using the names of the pattern and/or function implemented in that condition. If you would like no titles for your individual plots, then set this to 0 (`timeseries_plot_settings.cond_name = 0;`). 

Example: 
The title array correspending to the above conditions and durations example might be: 

`timeseries_plot_settings.cond_name{1} = ["Condition 1", "Condition 3", "Condition 5", "Condition 7"; "Condition 9", "Condition 11", "Condition 13", "Condition 15"]`
`timeseries_plot_settings.cond_name{2} = ["Condition 17", "Condition 19"; "Condition 21", "Condition 23"; "Condition 25", "Condition 27"; "Condition 29", "Condition 31"]`

### Axis Labels

`timeseries_plot_settings.axis_labels` is a variable that contains the axis labels for timeseries plots in an array [x-label, y-label]. You should provide a set of labels for each datatype. Even if there are multipe LmR figures, they cannot have differing axis labels. You may leave this empty to use the default axis labels (`timeseries_plot_settings.axis_labels = {};` - note the curly brackets, not square brackets). The default axis labels are "Time(sec)" for the x axis and the datatype for the y-axis.


Example:
To match the above timeseries examples, it would look like this: 
`timeseries_plot_settings.axis_labels{1} = ["Time(sec)", "LmR"];` Because we are only plotting one datatype, LmR. If we were plotting both LmR and LpR, it would look like this: 

`timeseries_plot_settings.axis_labels{1} = ["Time(sec)", "LmR"];`
`timeseries-plot_settings.axis_labels{2} = ["Time(sec)", "LpR"];`

### Subplot Figure Titles

`timeseries_plot_settings.subplot_figure_title` is an array which can provide each of your figures with its own title (in addition to each subplot's title and/or the title in the figure's menu bar up top). It is optional, and can be left empty (`timeseries_plot_settings.subplot_figure_title = {};`) for no title. If you'd like each of your figures to have a title, you will need to provide them in this array (there is no default option). It should be a cell array where each element in the cell array contains a regular array containing one string for each figure. Figures will be repeated for each datatype, so you will need one cell array element for each datatype you are plotting. 

Example: 
In the previous timeseries examples, we have been plotting one datatype (LmR) and splitting the plots up between two different figures. In this case, the corresponding `subplot_figure_title` variable would look like this: 
`timeseries_plot_settings.subplot_figure_title{1} = ["LmR Figure 1 Title", "LmR Figure 2 title"];`

If we were plotting two datatypes, LmR and LpR, it would look like this: 
`timeseries_plot_settings.subplot_figure_title{1} = ["LmR Figure 1 Title", "LmR Figure 2 title"];`
`timeseries_plot_settings.subplot_figure_title{2} = ["LpR Figure 1 Title", "LpR Figure 2 title"];`

Note that it follows the same order as the datatypes array. LmR, if it is being plotted, should be first, followed by LpR. **faLmR should not be included here. It has its own version of all of these settings listed below** 

### Figure names: 

`timeseries_plot_settings.figure_names`, not to be confused with the previous variable, is an optional array of strings providing a figure name for each datatype of timeseries plots. This name will not be printed on the figure but be in the title bar along the top of the figure. We generally use the datatype being plotted as the figure name, but you can use any string you want. Just keep in mind that everything is done in the order LmR -> LpR, so if you are plotting both LmR and LpR, your LmR figure name should always come first. **Note that if your plots of a particular datatype are spread over multiple figures, those figures will all have the same figure name. This is not intended to identify any given figure but only to identify all figures of a given datatype.**

Example:
Continuing with the same timeseries example as above, the corresponding figure names would look like this: 

`timeseries_plot_settings.figure_names = ["LmR"];` Even though the LmR data is split over two figures, only one datatype is being plotted so this will be applied to both figures. 

If we were plotting two datatypes instead, LmR and LpR, with each being split across two figures, it would look like this: 
`timeseries_plot_settings.figure_names = ["LmR", "LpR"];`

**faLmR should not be included here. It has its own version of all of these settings listed below** 

### Pattern Motion Indicator

`timeseries_plot_settings.pattern_motion_indicator` is a variable that should be set to either 0 or 1. The pattern motion indicator is a vertical line which will be placed on all timeseries plots indicating the moment at which your pattern actually started moving (which is generally some number of milliseconds after the official start of the condition). If you would like this vertical line to be present, set this variable equal to 1. If you would not like it, set it to 0. 

Example:
`timeseries_plot_settings.pattern_motion_indicator = 0;`

### Other Indicators

This setting has not actually been implemented as of 8/4/2021 but will be in the coming weeks. `timeseries_plot_settings.other_indicators` is an array which should match in shape and size the other timeseries arrays like `OL_TS_conds`. This allows you to place an indicator (vertical line) at any point of each condition's plot. Instead of the condition number, as provided in `OL_TS_conds` you would provide the x value at which you want a vertical line to appear. If you want no vertical line on that particular condition, you would enter 0. 

Example: 
corresponding with the `OL_TS_conds` example above:
`timeseries_plot_settings.other_indicators{1} = [1 2 1 2; 1 2 1 2];`
`timeseries_plot_settings.other_indicators{2} = [1 0; 1 0; 2 0; 2 0];`

Indicating that conditions 1, 5, 9, 13, 17, and 21 will have vertical lines at x = 1, conditions 3, 7, 11, 15, 25, and 29 will have one at x = 2, and conditions 19 and 23 will have no vertical line. These are in addition to the pattern motion indicator, if it is set to 1. 

### Cutoff Time

`timeseries_plot_settings.cutoff_time` allows you to set an x-value at which the plot should end, so that small variations in the duration of each condition do not cause the timeseries plots to all vary by small amounts in the length of their x-axis. If the duration of a condition is less than this cutoff value, then that condition's x-axis will end at the duration - it will not extend longer. But if the condition's duration is longer than this cutoff value, then the x-axis maximum value will be changed to this cutoff time. Set to 0 if you do not want a cutoff limit. 

Example: 
`timeseries_plot_settings.cutoff_time = 2;` means that each timeseries plot will not have an x-axis longer than 2 seconds. 

### Show individual flies

`timeseries_plot_settings.show_individaul_flies` should be set to 0 or 1. 1 indicates that each individual fly should be plotted on the timeseries plots as well as the average, which is useful when plotting one group of flies. This should be set to 0 if you are analyzing only a single fly or multiple groups of flies. 

Example: 
`timeseries_plot_settings.show_individual_flies = 0;`

### Show Individual Reps

`timeseries_plot_settings.show_individual_reps` is similar to the previous setting, except this should only be used when analyzing a single fly. Noramlly when you analyze a fly, all the repetitions of the protocol done by that fly are averaged into one dataset. If you set this 1, you will get the average of all repetitions for that fly plus each individual repetition plotted in various shades of gray in the background. Set it to 1 to plot each repetition, 0 to plot only the average. 

Example: 
`timeseries_plot_settings.show_individual_reps = 1;`

### Frame superimpose: 

`timeseries_plot_settings.frame_superimpose` should be set to 0 or 1. 1 indicates that the frame position (meaning the position of your pattern on the arena screen at x time) should be plotted in light grey on each timeseries axis, in addition to the timeseries data. 0 turns this feature off. (Default is 0)

Example: 
`timeseries_plot_settings.frame_superimpose = 0;`

### Plot both directions

`timeseries_plot_settings.plot_both_directions` should be set to 0 or 1. 1 indicates that each timeseries plot on your figure should plot the condition assigned to it as well as its corresponding condition of the opposite direction. Some experiments utilize two symmetric directions, like clockwise and counter-clockwise, or up and down, and it's helpful in this case to plot conditions that are symmetrical to each other on the same axis. To do this, set this variable equal to 1. Next, you will have the opportunity to define which conditions should be paired together. 

Example: 
`timeseries_plot_settings.plot_both_directions = 1;`

| Trial 1 and 2  | Trial 3 and 4   | Trial 5 and 6   | Trial 7 and 8   |
| Trial 9 and 10 | Trial 11 and 12 | Trial 13 and 14 | Trial 15 and 16 |

### Opposing Condition Pairs

`timeseries_plot_settings.opposing_condition_pairs` is where you will set which conditions are symmetrical pairs if plotting both directions is set to 1. You can leave it empty (`timeseries_plot_settings.opposing_condition_pairs = [];`), in which case the software will assume the pairs are even/odd - 1-2, 3-4, 5-6, etc through the number of conditions in the experiment. However, you can pair conditions manually however you like. It should be laid out as a cell array. Each cell element should have a 1x2 array containing the condition numbers that make up that pair. So the number of cell array elements should match the number of apirs. Note that you can repeat conditions if multiple pairs if you have a more complicated matching scheme than 1 to 1. 

Example: 
`timeseries_plot_settings.opposing_condition_pairs{1} = [1 6];`
`timeseries_plot_settings.opposing_condition_pairs{2} = [2 5];`
`timeseries_plot_settings.opposing_condition_pairs{3} = [3 8];`
`timeseries_plot_settings.opposing_condition_pairs{4} = [4 7];`
`timeseries_plot_settings.opposing_condition_pairs{5} = [9 10];`
`timeseries_plot_settings.opposing_condition_pairs{6} = [10 9];`
`timeseries_plot_settings.opposing_condition_pairs{7} = [11 12];`
`timeseries_plot_settings.opposing_condition_pairs{8} = [12 11];`

Note that the first condition in the pair will always be plotted first on the axis. 

## Settings relating to faLmR timeseries plots

### faLmR Pairs
`timeseries_plot_settings.faLmR_pairs` is only relevant if you enabled faLmR in your processing settings. If you did enable faLmR, then remember that in your processing settings, you indicated what condition pairs should be flipped and averaged together (or you allowed the software to use the default pairings). So your faLmR data will already have only half the number of plots as your LmR data, as each plot is two conditions averaged together. Sometimes experiments are symmetrical in more than one direction, and you might want to plot two of these averaged pairs on the same axis for comparison. You can do that here. If you'd like to plot two faLmR datasets per axis, here you can create an array indicating which ones to pair together. 

In `opposing_condition_pairs` you provide the condition number of each condition in the pair. In this case, condition numbers are no longer accurate because each faLmR dataset is already a combination of two conditions. So instead, you will provide the pair number as it is shown in the processing settings. For example: 

If your processing settings shows the following as your condition pairs: 
`settings.condition_pairs{1} = [1 6];`
`settings.condition_pairs{2} = [2 5];`
`settings.condition_pairs{3} = [3 8];`
`settings.condition_pairs{4} = [4 7];`
`settings.condition_pairs{5} = [9 10];`
`settings.condition_pairs{6} = [10 9];`
`settings.condition_pairs{7} = [11 12];`
`settings.condition_pairs{8} = [12 11];`

Then  your `timeseries_plot_settings.faLmR_pairs` might look like: 

`timeseries_plot_settings.faLmR_pairs{1} = [1 2];`
`timeseries_plot_settings.faLmR_pairs{2} = [3 4];`
`timeseries_plot_settings.faLmR_pairs{3} = [5 6];`
`timeseries_plot_settings.faLmR_pairs{4} = [7 8];`

Meaning that the first axis will plot the flipped and averaged data of conditions 1 and 6 and the flipped and averaged data of conditions 2 and 5 together. These two pairs are now pairs 1 and 2. The second row indicates that pairs 3 ([3 8]) and 4 ([4 7]) will be plotted on the same axis. Etc. 

If you do not wish to plot multiple faLmR datasets on the same axis, or are not using faLmR, simply leave this variable empty:

`timeseries_plot_settings.faLmR_pairs = [];`

### faLmR Plot Both Directons

`timeseries_plot_settings.faLmR_plot_both_directions`, similar to the LmR version, should be set to 1 if you plan on plotting two faLmR datasets on each axis, and set to 0 if you do not. 0

### faLmR Conds
`timeseries_plot_settings.faLmR_conds` works exactly like the variable `OL_TS_conds` discussed earlier. The only difference is that instead of providing condition number, you will provide pair number, as defined in the processing settings (see faLmR Pairs for an explanation of this). 

Example:
`timeseries_plot_settings.faLmR_conds{1} = [1 2; 3 4];`
`timeseries_plot_settings.faLmR_conds{2} = [5 6; 7 8];`

Indicates there will be two figures of 2 rows and 2 columns each. The first will show faLmR data for condition pairs 1,2,3, and 4, etc. 

### faLmR Figure Names

`timeseries_plot_settings.faLmR_figure_names` works exactly like the figure names variable discussed above, but will be applied to faLmR plots. As such it is just an array with a single string - whatever figure name you want applied to all your faLmR figures.  

### faLmR Subplot Figure Titles

`timeseries_plot_settings.faLmR_subplot_figure_titles` works exactly like the `subplot_figure_titles` variable discussed above. The only difference is that it is not a cell array. Since this only applies to faLmR data, there can not be additional sets of figures from other datatypes. You will need to be aware of exactly how many faLmR figures you will be producing, so you can give them each a title. The number of figures should equal the number of cell array elements in `faLmR_conds`. 

Example:
`timeseries_plot_settings.faLmR_subplot_figure_titles = ["Conds 1-4", "Conds 5-8"];` Would go along with the faLmR_conds example above. 

### faLmR Cond Name

`timeseries_plot_settings.faLmR_cond_name` works exactly like the earlier `cond_name` variable. This provides titles for each axis on a figure. It will be a cell array with the number of cell elements matching the total number of faLmR figures you expect to create. 

Example: 
`timeseries_plot_settings.faLmR_cond_name{1} = ["Pair 1", "Pair 2"; "Pair 3", "Pair 4"];`
`timeseries_plot_settings.faLmR_cond_name{2} = ["Pair 5", "Pair 6"; "Pair 7", "Pair 8"];` Would go along with the examples above. 

## Settings pertaining to Closed Loop Data

### Closed loop datatypes

`CL_hist_plot_settings.CL_datatypes` is a cell array containing the datatypes you'd like to plot as closed loop histograms. The datatype options are exactly the same as for timeseries above, and should be in the same order. 

Example: 
`CL_hist_plot_settings.CL_datatypes = {'Frame Position'};`

 array is exactly the same as OL_TS_conds, except it will determine the layout of your closed loop histograms if you're creating any. Leave empty if you are not plotting histograms or would prefer the default layout.

### Closed loop histogram conditions

`CL_hist_plot_settings.CL_hist_conds` is just like the `OL_TS_conds` variable described above, but instead controls the layout of your figures containing histograms of your closed loop conditions. Only include conditions in this array that are closed loop and should be plotted as histograms. 

### Axis labels

`CL_hist_plot_settings.axis_labels` works exactly like the timeseries axis labels variable discussed above. However, there are no default axis labels if you choose not to provide any. 

## Settings related to Tuning Curves

### Tuning curve datatypes

Like the other datatypes variables, `TC_plot_settings.TC_datatypes` is a cell array of all the datatypes you wish to display as tuning curves, drawing from the same list provided in the timeseries datatypes section.

### open loop tuning curve conditions

While `TC_plot_settings.OL_TC_conds` is the same in purpose as `OL_TS_conds` and `CL_hist_conds`, it works a bit differently. This is because tuning curves plot multiple conditions on one axis.

This is a two dimensional cell array. The first cell dimension is the number of figures. The second is the number of rows in that figure. Each cell element then contains a two dimensional array indicating which conditions should be included on the tuning curve and the tuning curve's placement. It follows the format:


OL_TC_conds{fig #}{row #} = [condition #'s on first tuning curve; ...
                             condition #'s on second tuning curve; …];


Example:

`TC_plot_settings.OL_TC_conds{1}{1} = [1 3 5 7; 9 11 13 15; 17 19 21 23];`
`TC_plot_settings.OL_TC_conds{1}{2} = [25 27 29 31; 33 35 37 39; 41 43 45 47];`
`TC_plot_settings.OL_TC_conds{2}{1} = [2 4 6 8; 10 12 14 16; 18 20 22 24];`
`TC_plot_settings.OL_TC_conds{2}{2} = [26 28 30 32; 34 36 38 40; 42 44 46 48];`

The above code creates two figures, each with two rows. The first figure is laid out as below: 

| TC w/ conds 1,3,5,7     | TC w/ conds 9,11,13,15  | TC w/ conds 17,19,21,23 |
| TC w/ conds 25,27,29,31 | TC w/ conds 33,35,37,39 | TC w/conds 41,43,45,47  |

**Note: Each tuning curve must have the same number of conditions in it.**

### Tuning curve condition name

`TC_plot_settings.cond_name` serves the same function as the timeseries cond_name variable, but each title will be given to a tuning curve, rather than a condition, since each axis plots multiple conditions. If you want to assign custom subplot titles, create an array just like the timeseries cond_name array, giving a title to each subplot. Leave this empty (`TC_plot_settings.cond_name = [];`) if you would like default names to be created. Set to 0 if you would like no titles for each tuning curve. 

Example: 
`TC_plot_settings.cond_name{1} = ["Conds 1-7", "Conds 9-15", "Conds 17-23"; "Conds 25-31", "Conds 33-39", "Conds 41-47"];`
`TC_plot_settings.cond_name{2} = ["Conds 2-8", "Conds 10-16", "Conds 18-24"; "Conds 26-32", "Conds 34-40", "Conds 42-48"];`

This would go with the above example. Notice we are back to a one dimensional cell array where the cell element represents the figure number, and a semi-colon indicates moving to the next row. 

### Tuning curve X axis values

`TC_plot_settings.xaxis_values` is an array of numbers indicating what values should be associated with each condition in the tuning curve on the xaxis. A tuning curve generally includes conditions that are the same except for one aspect that changes between them, to see how that aspect affected the outcome. Each condition then only has one datapoint. Each condition in the tuning curve needs a number on the xaxis indicating which condition that is. For example, if your conditions are varying by frequency, then each condition should have a number in Hz on the x-axis indicating what frequency its pattern was played at. The length of this array should match the number of conditions in each tuning curve. 

Example: 
`TC_plot_settings.xaxis_values = [1, 10, 100, 1000];` This would go along with the above example. Each tuning curve contains four conditions, each one played at 1, 10, 100, or 1000 Hz. 

### Axis labels

`TC_plot_settings.axis_labels` is a cell array much like the other axis_labels variables discussed above. If you are creating tuning curves for more than one datatype, then you'll need a cell array element for each datatype. 

### Tuning curve Subplot Figure titles

`TC_plot_settings.subplot_figure_titles` works exactly like the timeseries equivalent discussed above. You should know how many total figures you expect to create for each datatype you're analyzing in order to provide the correct number of figure titles. 

### Tuning curve figure names:

`TC_plot_settings.figure_names` works exactly like the timeseries figure names. 

### Tuning curve plot both directions

`TC_plot_settings.plot_both_directions` is more limited than the equivalent feature for timeseries. You can not set your own custom pairings. If this is set to 1, it will assume every condition is followed by its symmetric counterpart (meaning condition pairs are 1-2, 3-4, 5-6, etc). On each tuning curve axis, the software will take the conditions listed in `OL_TC_conds` for that axis, and add 1 to each number. It will then create a second tuning curve for those conditions and plot it on the same axis. So in the above example, the first tuning curve contains conditions 1, 3, 5, and 7. If this variable is set to 1, an additional tuning curve with conditions 2, 4, 6, and 8 will be plotted on that axis. If your conditions are not set up this way, then as of right now this feature will not be much use to you. 

## Settings for Position Series Plots - M and P

Position series data is generated by the data processing. This data shows the fly's motion against the position of the pattern on the arena screen (rather than against time). There are a few different ways to use this data. 

One type of plot you can generate are Motion-Dependent (M) and Position-Dependent (P) position series plots. These are only relevant to certain types of experiments, namely one that passes a single bar around the arena in a clockwise or counter-clockwise direction. Put simply, P is calculated by adding the fly response to each direction together and dividing by two. M is calculated by subtracting the counter-clockwise (or negative) direction from the clockwise direction and dividing by two. For more details on the origin and purpose of these equations, see [Object tracking in motion-blind flies](https://www.nature.com/articles/nn.3386)[^1]. For additional reading on the subject, see [A theory of the pattern induced flight orientation of the fly Musca domestica](https://pubmed.ncbi.nlm.nih.gov/4718020/)[^2] The following settings relate to these M and P plots.

### Plot M and P

`MP_plot_settings.plot_MandP` should be set to either 1 or 0. 1 indicates that you would like to generate M and P plots (which are only one type of position series plot) while 0 indicates you do not wish to generate these plots. If this setting is set to 0, you can ignore the rest of the `MP_plot_settings` struct. 

### M and P conditions

`MP_plot_settings.mp_conds` is a variable that allows you to lay out which conditions should be where on your figure, exactly like `OL_TS_conds`. [see that section](#timeseries-conditions) for a detailed description of how this setting works. 

### M and P condition names

`MP_plot_settings.cond_name` works exactly like the timeseries settings `cond_name` variable, providing a title for each subplot on each figure. Please see that section for a description of how the setting works. 

### M and P x axis range

`MP_plot_settings.xaxis` should provide your xaxis range. Using the G4 arena, the standard x-axis would be [1:192] since there are 192 frames in our patterns. The x axis is position of the pattern on the arena screen so from left to right, there are 192 possible positions normally. However, if this is different for your set up or particular experiment, change this range to 1 through however many possible positions there are for your bar or pattern. 

Example: 
`MP_plot_settings.xaxis = [1:192];`

### M and P conversion applied to x axis 

Sometimes you might not want to plot your data against the straight frame number, as discussed above, but you might want to convert that frame number to an angular position or percentage or some other representation of the pattern's position. `MP_plot_settings.new_xaxis`, in this case, should be set equal to whatever equation you want applied to the xaxis range set in the previous setting. By default, our lab changes this to angular position, using the equation below: 

`MP_plot_settings.new_xaxis = circshift((360/MP_plot_settings.xaxis(end))*[(MP_plot_settings.xaxis) - 96], 96);`

If you don't wish to apply any conversion to your x-axis, simply leave this setting empty (`MP_plot_settings.new_xaxis = [];`). 

### M and P axis labels

`MP_plot_settings.axis_labels` works slightly differently than previous axis_labels variables. That's because you are not setting a datatype so there is not a variable number of figures (or sets of figures). In this case you'll always get one figure (or set of figures) for M and one for P. So axis_labels is a cell array with two cell elements. THe first element should contain the axis labels for M plots [x label, y label], and the second cell element should contain the axis labels for P plots. 

Example:
`MP_plot_settings.axis_labels{1} = ["Frame Position", "Motion-Dependent Response"];` 
`MP_plot_settings.axis_labels{2} = ["Frame Position", "Position-Dependent Response"];`

### M and P x and y limits

`MP_plot_settings.ylimits` and `MP_plot_settings.xlimits` should each be a 2x2 array providing the y or x min and max values for each M and P plots. They can also be left empty, in which case matlab will determine the x and y limits based on the data. The setup is [M-ymin M-ymax; P-ymin P-ymax] and similar for x axis. 

Example: 
`MP_plot_settings.ylimits = [-10 10; 0 20];`
`MP_plot_settings.xlimits = [1 192; 1 192];`

By default our lab leaves these values empty (`MP_plot_settings.ylimits = [];`).

### M and P subplot figure titles 

`MP_plot_settings.subplot_figure_title` works exactly like the timeseries `subplot_figure_title` variable. [See that section above](#Subplot-Figure-Titles) for a detailed explanation of how it works. 

### M and p figure names

`MP_plot_settings.figure_names` works just like `figure_names` for the timeseries plots, except that you will always have two sets of figures in this case - one for M plots and one for P plots (even if each of those are split among multiple figures, all M figures will have the same figure name). So you'll provide two strings which will be in the figure's title bar at the top.

Example:
`MP_plot_settings.figure_names = ["M", "P"];`

### M and P show individual flies 

`MP_plot_settings.show_individual_flies`, much like previous versions of this setting, should be set to either 1 or 0. If it is 1, individual fly data will be plotted behind the average data. If it is set to 0, only the average for the group will be plotted. 

## Settings for other position series plots

### Plot averaged position series

In this case, "averaged position series" just refers to regular position series plots, where the fly's response is plotted against the position of the pattern on the screen. `pos_plot_settings.plot_pos_averaged` should be set to either 1 or 0. 1 indicates that you would like plots of this position series data. 0 indicates that, while you may or may not want to generate M and P plots, you don't want to generate regular position series plots.

### Position series conditions

`pos_plot_settings.pos_conds` works exactly like `OL_TS_conds`. Please [see that section](#timeseries-conditions) for a detailed explanation. 

### Position series condition names

`pos_plot_settings.cond_name` provides titles for each subplot per figure. Please [see the timeseries version](#condition-names) for a detailed explanation of how this setting works. 

### Position series xaxis 

`pos_plot_settings.xaxis` is exactly the same as the xaxis variable in the M and P settings. It should simply be a range of numbers. [See the MP version](#m-and-p-x-axis-range) for details and an example. 

### Position series conversion to x axis

Like the [M and P settings](#m-and-p-conversion-applied-to-x-axis) above, `pos_plot_settings.new_xaxis` can be set equal to an equation you'd like applied to your x-axis values, if you'd like to convert them from straight frame position to something else like angular position. It can also be left empty. Ours is generally set exactly the same way as the M and P version: 

`pos_plot_settings.new_xaxis = circshift((360/MP_plot_settings.xaxis(end))*[(MP_plot_settings.xaxis) - 96], 96);`

### Position series axis labels

`pos_plot_settings.axis_labels` works just like the axis labels setting for M and P plots, but in this case there is only one figure or set of figures. As such, you'll only ever need to provide one set of x and y labels. This set will be applied to all the position series plots. 

Example:
`pos_plot_settings.axis_labels = ["Position", "Volts"];`

### Position series X and y limits

`pos_plot_settings.ylimits` and `pos_plot_settings.xlimits` are the same as in the M and P settings, but again are only needed for one figure or set of figures, not two. So they will each be a 1x2 array instead of 2x2, each containing one set of limits. They can also be left empty in order to allow matlab to set the limits based on the data. 

Example: 
`pos_plot_settings.ylimits = [-10 10];`
`pos_plot_settings.xlimits = [1 192];`

### Position series figure names

`pos_plot_settings.figure_names` is the same as other `figure_names` settings, but simpler because there is only one figure or set of figures to name. Therefore you'll provide just a single string to be printed in the title bar of your position series figures. 

Example: 
`pos_plot_settings.figure_names = ["Position Series"];`

### Position series subplot figure titles

`pos_plot_settings.subplot_figure_title`, like other versions, provides a figure title for each figure. Unlike figure names, you'll need a title for each figure if you have set up your position series plots to be spread over multiple figures. Note that because there are not multiple datatypes in this case, this is not a cell array. It is a regular array containing a string for each figure. 

Example: 
`pos_plot_settings.subplot_figure_title = ["Pos Series Conds 1-15"; Pos Series Conds 17-31"];` If your pos_conds setting splits your conditions among two figures. 

### Position series show individual flies

`pos_plot_settings.show_individual_flies`, like other settings of the same name, should be set to 0 if you only want to plot the average of all flies in the group, or 1 if you'd like to plot each individual fly's data behind the average. 

### Position series plot opposing directions

This setting is not yet implented but will be in the coming weeks. `pos_plot_settings.plot_opposing_directions`, like [the timeseries version](#plot-both-directions), should be set to either 0 or 1. If it is set to 1, it will use the same pairings provided for the timeseries plots, so even if you are not plotting timeseries, make sure to fill out the pairings [as described above](#opposing-condition-pairs) if you want to plot symmetrical conditions on the same axis in your position series figures. Set this to 0 if you do not want to plot symmetrical conditions on the same axis. 

## Settings for creating a comparison figure

A comparison figure is a figure in which multiple plots are generated in the same figure side by side for a given condition. So the layout of a comparison figure might be: 

Figure 1: 

Cond 1: | LmR timeseries | Position series | M | P |
Cond 2: | LmR timeseries | Position series | M | P |
Cond 3: | LmR timeseries | Position series | M | P |
Cond 4: | LmR timeseries | Position series | M | P |

To do this, you'll provide the type of plots you want and in what order, which conditions you want included, and how many rows per figure, as well as some of the same settings we've seen before. We recommend no more than four rows per figure, as it can get crowded. Each row, in this case, contains all plots for a single condition.

### Comparison plot order

`comp_settings.plot_order` is a cell array with character vectors indicating the order and type of plots you'd like included in your comparison figure. Options for the comparison figure are: 

'LmR' - timeseries plot of LmR data
'LpR' - timeseries plot of LpR data
'faLmR' - timeseries plot of faLmR data
'pos' - position series plot
'M' - Motion-dependent position series plot
'P' - Position-dependent position series plot

We recommend choosing no more than four for a comparison plot for ease of reading. 

Example:
`comp_settings.plot_order = {'LmR', 'pos', 'M', 'P'};` This means each row in the comparison figure will contain these plots, in this order, for a particular condition.

You may leave this empty (`comp_settings.plot_order = {};`). If you do, and request a comparison plot, the default plots included will be LmR, Pos, M and P. 

### Conditions to be included

`comp_settings.conditions` is an array listing all condition numbers you'd like to be included in the comparison plot. Unlike previous settings like `OL_TS_conds` it is not a cell array and doesn't require a particular layout, because in a comparison plot there is only one condition per row. 

Example:
`comp_settings.conditions = [1,3,5,7,9,11,13,17,19,21,23,25,27,29,31];`

### Comparison figure condition names

`comp_settings.cond_name`, like other settings of the same name, provide a title for each plot across all figures. You'll need to count the number of conditions included (as set by you in the previous setting) and divide by the number of rows per figure, which you will set directly after this, to find out how many figures you will have. Cond name will be a cell array with a cell element per figure. Each cell element will contain an array of strings. The number of columns of this array corresponds to the number of plots per row, and the number of rows corresponds to the number of rows per figure. 

Example - Assuming the default plot order, the conditions in the example above being included, and four rows per figure:

`comp_settings.cond_name{1} = ["Cond1 LmR", "Cond1 Pos Series", "Cond1 M", "Cond1 P";...`
        `"Cond3 LmR", "Cond3 Pos Series", "Cond3 M", "Cond3 P"; "Cond5 LmR", "Cond5 Pos Series", "Cond5 M", "Cond5 P";...`
        `"Cond7 LmR", "Cond7 Pos Series", "Cond7 M", "Cond7 P"];`
`comp_settings.cond_name{2} = ["Cond9 LmR", "Cond9 Pos Series", "Cond9 M", "Cond9 P";...`
        `"Cond11 LmR", "Cond11 Pos Series", "Cond11 M", "Cond11 P"; "Cond13 LmR", "Cond13 Pos Series", "Cond13 M", "Cond13 P";...`
        `"Cond15 LmR", "Cond15 Pos Series", "Cond15 M", "Cond15 P"];`
`comp_settings.cond_name{3} = ["Cond17 LmR", "Cond17 Pos Series", "Cond17 M", "Cond17 P";...`
        `"Cond19 LmR", "Cond19 Pos Series", "Cond19 M", "Cond19 P"; "Cond21 LmR", "Cond21 Pos Series", "Cond21 M", "Cond21 P";...`
        `"Cond23 LmR", "Cond23 Pos Series", "Cond23 M", "Cond23 P"];`
`comp_settings.cond_name{4} = ["Cond25 LmR", "Cond25 Pos Series", "Cond25 M", "Cond25 P"; ...`
        `"Cond27 LmR", "Cond27 Pos Series", "Cond27 M", "Cond27 P"; "Cond29 LmR", "Cond29 Pos Series", "Cond29 M", "Cond29 P";...`
        `"Cond31 LmR", "Cond31 Pos Series", "Cond31 M", "Cond31 P"];`


### Comparison rows per figure

`comp_settings.rows_per_fig` should be set to a single number indicating how many rows you want included on each figure for your comparison plots. We recommend no more than 4. 

Example: 

`comp_settings.rows_per_fig = 4;`

### Y axis limits 

`comp_settings.ylimits` is an optional setting where you can provide a y limit that you want applied across all plots. This may not always make sense, so if you want y limits to be set by matlab, you should set this to [0 0]. Otherwise, you can provide whatever numbers make sense for you. 

Example: 
`comp_settings.ylimits = [0 0];`

### Comparison subplot figure titles

Like previous plot types, you can use `comp_settings.subplot_figure_title` to provide a unique title for each of your comparison plot figures. You must, again, figure out how many figures you're going to have, because if you provide too many or too few, it may cause an error. This should be a cell array containing a character vector for each figure you will create. Note the commas between charactor vectors and curly bracket locations - as always, make sure you do not change these. 

Example - continuing on the above example:
`comp_settings.subplot_figure_title = {'LmR, Pos, M, P 1-7', 'LmR, Pos, M, P 9-15', 'LmR, Pos M, P 17-23', 'LmR, Pos, M, P 25-31'};`

### Comparison figure names

Unlike previous figure names settings, with `comp_settings.figure_names` you will provide a different title for each comparison figure you create. These titles will not be printed on the figure but, as usual, will be in the title bar at the top of the figure. 

Continuing the last example:
`comp_settings.figure_names = {'Comparison1-7', 'Comparison9-15', 'Comparison17-23', 'Comparison25-31'};`

### Comparison plot normalization

`comp_settings.norm` should be set either to 0 or 1. 1 indicates you want all data plotted on the comparison plot to be normalized. 0 indicates you would like unnormalized data. As of yet there is no option to do both, and your `plot_norm_and_unnorm` setting from the timeseries section does not apply here.

## Further settings (which may not need changing as often)

This covers the settings that should be regularly updated. At this point `DA_plot_settings.m` you will find many more settings which mostly affect the appearance of the plots. If their variable names are not self explanatory, comments in the file will explain their function. For the most part, they are things like fonts, font sizes, and line colors, as well as some axis limits for some of the plots. You can find a complete list in the [Appendix](#appendix-full-list-of-settings) of this document.

# Creating your data analysis settings file:

Now that you have your settings as you want them, you need to create a .mat file which contains all your preferences.  This will be used to actually run the data analysis. We do it this way because it is likely you will have only a few configurations of settings that you will use over and over again, in which case it is easier to create them once and be done. Be sure you save `DA_plot_settings.m` with all of your changes.

In `G4_data_analysis/support` there is a function called `create_settings_file`. This function takes in two parameters, the name of your settings file and the path where you would like to save it. Run this function to create a .mat file at the location you specify. The .mat file will contain all the settings present in the `DA_plot_settings.m` file you've just adjusted. Do this by typing the following command into the matlab command window and hitting enter: 

`create_settings_file('name of file', 'path to file');` You should give your file a meaningful name that indicates whether it is for a single fly, a particular group, or multiple groups. I recommend saving it inside your experiment folder so you do not forget which experiment it was made for.

**Note: When you run an experiment through the Conductor, you may have it run single fly analysis automatically after the data has been processed. If you do this, the conductor will open the settings file you provide and replace things specific to the current fly with updated values (ie, the genotype or path to the fly folder). It will then save a new analysis settings file for that particular fly inside the fly folder, and use that to run its analysis. So if you plan to use this feature, you can create one single-fly analysis settings file which is generic and save it in your experiment folder. The conductor will then use this to create a new analysis settings file for each specific fly and run the analysis automatically. Group analysis, however, must be done after the fact by you.**

This settings file will be usedto run the data analysis. Note that if a .mat file already exists with the name and filepath you specify, it will be replaced.

Now you are ready to run an analysis!

## Running a typical analysis:

There are two steps to running data analysis – the first is to run the file `create_data_analysis_tool.m.` This is not a regular script or function, so opening the file and hitting run in the MATLAB environment will not work. It is a class and when you run it, it creates an object. You should run it from the matlab command line. Here's an example:

`da = create_data_analysis_tool('path to the settings file', '-group', '-hist', '-tsplot');`

The first input is the path to the settings file which you just created. This will tell the class what settings to use in the analysis. After this are multiple inputs, or flags, which tell the `create_data_analysis_tool` function what analysis to do. The currently accepted flags are as follows:

- `'-group'` – Include this if you're analyzing multiple flies
- `'-single'` – include this if you're analyzing a single fly. **NOTE:** You MUST include either single or group flag!
- `'-hist'` – plot basic histograms of your intertrial (or stripe fixation) data
- `'-tsplot'` – plot open loop timeseries data
- `'-clhist'` – plot closed loop histograms
- `'-tcplot'` – plot tuning curves
- `'-posplot'` - plot position series data (this includes M and P plots)
- `'-compplot'` - plot comparison figures

We ask you to pass in these flags in order to minimize the number of settings files you need to create. In this way, one settings file can contain the settings for all different types of analyisis, but at any given time, if you only want to look at the timeseries plots, you can run an analysis with only the -tsplot flag passed in, and the software will then only pay attention to the settings required for timeseries plots. Or you can pass in all or most of the flags to do all your analyses at the same time. 

Make sure not to leave out the apostrophes or the dash. Any subset of these flags can be passed in, in any order. They are not case-sensitive. 

When you run create_data_analysis_tool, you want to store it in a variable. In the example above, I called this variable `da`. 

This in itself will not run the analysis. What it does is creates an object, da, with all of your settings stored in it and the options for whatever flags you passed in turned on. You can use this object to double check if everything is correct if you would like. For example, you could now type `da.save_settings` into the command line to review your save settings. If you forgot to pass in a flag, you could say `da.TC_plot_option = 1` to retroactively tell it you want to make tuning curves as well. If you forgot to update the colors of your timeseries plot, you could say `da.timeseries_plot_settings.rep_colors = [0 0 0; 0 1 0; 0 0 1]` and update them.

It is not likely you will want to update variables this way – it would be easier to create a new settings file. But when this tool needs to be called by other pieces of software, this system makes it much easier to automatically run the correct analysis without the software having to edit or create any settings files. 

Once you know there are no adjustments to be made, simply type in the command `da.run_analysis`, and this will start the analysis running. Assuming no adjustments after creating your data analysis tool, your command will look something like this:

`Create_settings_file(filename, filepath)` If you were creating a new settings file, rather than using an existing one
`da = create_data_analysis_tool(path_to_settings, '-group', '-hist', '-TSplot', '-tcplot');`
`da.run_analysis`

This will produce a number of graphs, automatically saving them at the save path you entered, then closing so you don't end up with a large number of windows to x out of. They will be automatically saved in the following way:

`Datatype_groupNames_plotType_#.pdf`

A matlab figure version of each will also be saved, so you can open the figures in matlab and continue to edit them on your own. Additionally, a .pdf report will be generated containing a copy of each figure for easy browsing. 

# Adding new modules:

Coming soon


# Appendix: Full list of settings:

Coming soon

{::comment}this was copied from the original file Data_analysis_documentation.docx{:/comment}

# Citations 

[^1]: Bahl, A., Ammer, G., Schilling, T. et al. Object tracking in motion-blind flies. Nat Neurosci 16, 730–738 (2013). https://doi.org/10.1038/nn.3386
[^2]: Poggio, T. & Reichardt, W. A theory of the pattern induced flight orientation of the fly Musca domestica. Kybernetik 12, 185–203 (1973).