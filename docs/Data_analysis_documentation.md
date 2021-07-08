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

The first step to running analysis on your data is to ensure all settings are as you want them. Open `DA_plot_settings.m`. 

The settings are split into eight different structures.

1. `Exp_settings`
   - These are experiment settings and should be updated each time.
2. `normalize_settings`
   - These are all settings related to the normalization of the data.
3. `histogram_plot_settings`
   - These are settings related to plotting basic histograms. These are not the same as the closed-loop histograms. 
4. `histogram_annotation_settings`
   - These control how the histograms from 2 are annotated – font, line type, and many other things. 
5. `CL_hist_plot_settings`
   - These are the settings for closed-loop histograms
6. `timeseries_plot_settings`
   - Contains appearance settings for the timeseries plots
7. `TC_plot_settings`
   - Appearance settings for tuning curves
8. `save_settings`
   - These settings affect how the results are saved.

The first section includes settings that will likely change with each type of analysis. The second section contains settings that will change less frequently, and mostly have to do with the details of plot appearance. Let's go over the settings and what they mean.  

## Settings in more detail

### Trial options:

This is a 1x3 array of 0's or 1's indicating the presence or absence of a pre-trial, inter-trial, and post-trial. `[1 1 1]` – the experiment had all three. `[0 1 0]` – the experiment had inter trials, but no pre or post trial.

### Field to sort by:

This is a cell array, each element being a regular array. This allows you to only pull flies which match certain metadata values into your data analysis. If you want to sort your flies by genotype and only genotype, you would set this to:

```matlab
field_to_sort_by{1} = ["fly_genotype"];
``` 
Notice that the string `fly_genotype` must match exactly the genotype field name in your metadata.mat file.

```matlab
field_to_sort_by{1} = ["fly_genotype", "fly_age"]
``` 
means you will have one group of flies, narrowed down both by genotype and by age.

```matlab
field_to_sort_by{1} = ["fly_genotype"];
field_to_sort_by{2} = ["fly_genotype", "experimenter"];
```
The above means you will have two groups of flies. One group will be all flies that match a particular genotype. The second field will be all flies that match a particular genotype AND were run by a particular experimenter. These two groups will be plotted on your graphs for comparison.

### Field values:

This is where you provide the values of the above field to match. It is an array just like `field_to_sort_by`, but in place of the field name you will put the value you want to match. So the corresponding `field_values` for the examples above would look something like:

```matlab
field_values{1} = ["emptySplit_JFRC100_JFRC49"];
``` 
The values you give here must match exactly the values in the `metadata.mat` file.

```matlab
field_values{1} = ["emptySplit_JFRC100_JFRC49", "3-6 days"];
``` 
all flies of both this genotype AND this age will be put in the first group.
    
```matlab
field_values{1} = ["emptySplit_JFRC100_JFRC49"];
field_values{2} = ["emptySplit_JFRC100_JFRC49", "taylorl"];
```
Will produce two groups of files to compare – first group has all flies of that genotype. Second group has all flies of that genotype AND run by that user. 

**NOTE** that if `plot_all_genotypes` is set to `1`, field_values can be left empty, because all values will be included. Likewise, if `single_fly` is set to `1`, field_values should be empty.

### Single group:

Set this to 1 if you only want to plot a single group, 0 if you are plotting a single fly or multiple groups

### Single fly:

Set this to 1 if you only want to analyze a single fly, 0 if multiple flies. 

### Plot all genotypes: 

This should be either `0` or `1`. If it is set to `1`, then each fly of a particular value of `field to sort by` will be placed in a group together. All values will be grouped. In addition, each group will be plotted individually against the control. If you haveresults for five genotypes and you set group1 as the control, you'll end up with four sets of graphs – group1 v group2, group1 v group3, etc.  Set this to 0 if you want to only include flies with a subset of values for your field to sort by, or if you want toput them on all one plot together rather than comparing to the control one by one. 

### Control genotype: 

This should be a character vector with the value of your control. It should match exactly the value in the metadata.mat file. Ie if you're grouping by genotype and your control is the empty split, your control genotype might be `'emptySplit_JFRC100_JFRC49'`

**Note:** This should be enclosed in SINGLE quotes.

### Path to protocol:

This should be the path to the protocol folder which holds all the fly results. Note that fly folders should only be two levels down from this folder. IE protocol_folder -> subfolders -> fly folders.  If your system is not organized this way, you can setpath to protocol equal to whatever folder is two levels above your fly folders. IE if your system is protocol_folder -> subfolders 1 -> subfolders 2 -> fly folders, set path to protocol equal to the path to subfolders 1. If you do this, when you run the dataanalysis you will be prompted to browse to the actual protocol folder so the program can get information from your .g4p file. 

### Genotypes

This is an array of names by which the groups should be labeled. These are intended to be simpler, human readable labels representing the metadata values. If you have set a control group, its label should come first, and the labels should be in the sameorder as field_values. If field_values is empty, it will be generated in the order of the group folders alphabetically. IE if your group folders are named Experiment001 – Experiment005 (each containing fly folders), you should list your genotype labels in that order with the exception of the control coming first.

**Note:** These strings should be encased in DOUBLE quotes. 

### Save path:

A string indicating the path where you'd like your results saved.

### Plot norm and unnorm:

Equals 0 or 1. If 1, whatever analysis you're doing will be done twice, once with unnormalized data and once again with normalized data. You still must pass in a normalization flag to tell the software which normalization you would like done, or you will only get the unnormalized analysis. If it is set to zero, you will only get normalized results if you pass in a normalization flag. If you do not pass in a flag, you will only get unnormalized results. 

### Processed data file: 

This is a character vector equal to the name of your processed file (minus the .mat). Note that all your flies should have identically named processed files or they will be skipped.

**Note** this should be enclosed in SINGLE quotes.

### Group_being_analyzed_name:

A string indicating the name of the group being analyzed. This does not need to match any other files or variables so make it something recognizable to you. It will be used to name the group log file. 

### Annotation text: 

This is the annotation text that will appear on your histograms. Any string you want enclosed in double quotes.

### OL_TS_conds:

This variable allows you to layout your timeseries plot figures exactly how you want them. If you are happy with the default layout, which will put 30 subplots on a figure in 6 rows x by 5 columns, then leave this variable empty (`OL_TS_conds = [];`)

To layout the figures yourself, you will make OL_TS_conds a cell array, with each cell element representing one figure. Each cell array will contain a regular array of condition numbers laid out in the format of the subplots. 

**EXAMPLE:**
```matlab
timeseries_plot_settings.OL_TS_conds{1} = [1 3 5 7; 9 11 13 15];
timeseries_plot_settings.OL_TS_conds{2} = [17 19; 21 23; 25 27; 29 31];
```

The above code will create two figures of timeseries plots, containing two rows of four subplots. The first figure will be laid out like:

| Trial 1 | Trial 3  | Trial 5  | Trial 7  |
| Trial 9 | Trial 11 | Trial 13 | Trial 15 |

The second figure, on the other hand, will contain four rows of two figures each. The first row will contain plots of condition 17 and 19, etc. 

In this way, you can plot any condition in any position on the figure. Note that if you're plotting more than one datatype, a figure is created for each datatype, so the above code, when run on two datatypes, would create four figures. Two for one datatype and two for the other. 

### OL_TS_durations:

The x-axis limits of timeseries plots generally will be the duration of that condition. The OL_TS_durations array should match the OL_TS_conds array exactly in shape and size, but instead of containing the condition numbers, it should contain the corresponding durations of each condition. 

**EXAMPLE:** The durations array corresponding to the above OL_TS_conds array might look something like this:

```matlab
timeseries_plot_settings.OL_TS_durations{1} = [1.5 3.12 1.5 3.12; 1.5 3.12 1.5 3.12]
timeseries_plot_settings.OL_TS_durations{2} = [1 3; 1 3; 1 3; 1 3];
```

…indicating that conditions 1, 5, 9 and 13 have durations of 1.5 seconds, 3, 7, 11, and 15 have durations of 3.12 seconds, 17, 21, 25, 29 have durations of 1 second, etc.

If you left `OL_TS_conds` empty, leave this array empty as well. The program will deduce the condition durations from the processed data and create a default durations array.

### OL_TSconds_axis_labels:

This variable contains the axis labels for timeseries plots in an array [x-label, y-label]. Each timeseries figure should get a set of labels, so to go with the above example it would look something like: 

```matlab
OL_TSconds_axis_labels{1} = ["Time(sec)", "LmR"];
OL_TSconds_axis_labels{2} = ["Time(sec)", "LmR"];
```

### Figure names: 

An optional array of strings (enclosed in double quotes) providing a figure name for each figure of timeseries plots. Each datatype gets is own figure. If you are using the default layout of timeseries plots, each figure will have a maximum of 30 subplots. 

If you're plotting two datatypes for example, and each has sixty subplots, your figure names should be `["datatype1", "datatype1", "datatype2", "datatype2"]`.

### OL_datatypes:

This should be a cell array of the datatypes you which to plot timeseries data for. You may plot timeseries for as many or few datatypes as you like. 

The datatype options for flying data are: 'LmR_chan', 'L_chan', 'R_chan', 'F_chan', 'Frame Position', 'LmR', 'LpR', and 'faLmR'.

The datatype options for walking data are: 'Vx0_chan', 'Vx1_chan', 'Vy0_chan', 'Vy1_chan', 'Frame Position', 'Turning', 'Forward', and 'Sideslip'.

### Show_individual_flies:

This should be set to 0 or 1, 1 indicating that each individual fly should be plotted on the timeseries plots as well as the average. Default is 0. This should be set to 0 if plotting more than one group.

### Frame_superimpose: 

This should be set to 0 or 1, 1 indicating that the frame position should be plotted in light grey on the timeseries plots 

### Plot_both_directions:

This should be set to 0 or 1, a 1 indicating that each timeseries subplot should plot the condition assigned to it as well as its corresponding condition of the opposite direction. An experiment utilizing two directions, like clockwise and counter clockwise, or up and down, should have all odd conditions be one direction and even directions another. If this variable is set to 1, your `OL_TS_conds` array should have all the odd conditions in it. The software will immediately add its even counter part to each axis. So for the OL_TS_conds array above, if this variable is set to 1, the first figure would look like: 

| Trial 1 and 2  | Trial 3 and 4   | Trial 5 and 6   | Trial 7 and 8   |
| Trial 9 and 10 | Trial 11 and 12 | Trial 13 and 14 | Trial 15 and 16 |

### Cond_name: 

If you would like your timeseries subplots to all have their own titles, this should be an array, matching OL_TS_conds in shape and size, with each element being the plot title for that condition. 

If left empty, the analysis will create default subplot titles combining the condition's pattern and function (if it exists) names. 

If you want your subplots to have no titles, set `cond_name = 0`

### CL_hist_conds:

This array is exactly the same as OL_TS_conds, except it will determine the layout of your closed loop histograms if you're creating any. Leave empty if you are not plotting histograms or would prefer the default layout.

### CL_datatypes:

Like OL_datatypes, this is a cell array of all datatypes you wish to create closed loop histograms for. 

### OL_TC_conds:

While this array is the same in purpose as OL_TS_conds and CL_hist_conds, it works a bit differently. This is because tuning curves plot multiple conditions on one axis.

This is a two dimensional cell array. The first cell dimension is the number of figures. The second is the number of rows in that figure. Each cell element then contains a two dimensional array indicating which conditions should be included on the tuning curve and the tuning curve's placement. It follows the format:

```matlab
OL_TC_conds{fig #}{row #} = [condition #'s on first tuning curve; ...
                             condition #'s on second tuning curve; …];
```

**EXAMPLE:**

```matlab
OL_TC_conds{1}{1} = [1 3 5 7; 9 11 13 15; 17 19 21 23]
OL_TC_conds{1}{2} = [ 25 27 29 31; 33 35 37 39; 41 43 45 47];
OL_TC_conds{2}{1} = [2 4 6 8; 10 12 14 16; 18 20 22 24];
OL_TC_conds{2}{2} = [26 28 30 32; 34 36 38 40; 42 44 46 48];
```

The above code creates two figures, each with two rows. The first figure is laid out as below: 

| TC w/ conds 1,3,5,7     | TC w/ conds 9,11,13,15  | TC w/ conds 17,19,21,23 |
| TC w/ conds 25,27,29,31 | TC w/ conds 33,35,37,39 | TC w/conds 41,43,45,47  |

### Cond_name

This cond_name variable belongs to the TC plot settings (rather than timeseries plot settings) but it serves the same function. If you want to assign custom subplot titles, create an array just like the timeseries cond_name array, giving a title to each subplot. Ie `cond_name{fig#}(col, row) = "title";`

Leave this empty if you would like default names to be created.

Set to 0 if you would like no titles.

### Xaxis_label:

`TC_plot_settings.xaxis_label` is a string indicating the label of the x axis of the tuning curves. This should indicate what is changing between each condition on the curve. 

### Figure names:

`TC_plot_settings.figure_names` works exactly like the timeseries figure names. 

### Xaxis_values:

`TC_plot_settings.xaxis_values` is an array of numbers indicating what values should be associated with each condition in the tuning curve on the xaxis. For example, if the conditions on your tuning curve are changing in frequency, then the x label would be frequency and the x values might be `[10, 100, 500, 1000]` indicating that the frequency of the first condition was 10 hz, the second was 100 hz, etc. 

### TC_datatypes

Like the other datatypes variables, this is a cell array of all the datatypes you wish to display as tuning curves. 

### Plot_both_directions

Part of the TC_plotting_settings struct, this variable behaves exactly the same way as the timeseries version, but refers to the tuning curve plots. 

This covers the settings that should be regularly updated. Below this section in `DA_plot_settings.m` you will find many more settings which mostly affect the appearance of the plots. You will find a full list with explanations in the appendix of this document. 

## Creating your data analysis settings file:

Now that you have your settings as you want them, you need to create a .mat file which contains all your settings preferences. This will be used to actually run the data analysis. We do it this way because it is likely you will have only a few configurations of settings that you will use over and over again, in which case it is easier to create them once and be done. 

In G4_data_analysis/support there is a function called `create_settings_file`. This function takes in two parameters, the name of your settings file and the path where you would like to save it.

Run this function to create a .mat file at the location you specific. This file will be passed in to run the data analysis. Note that if a .mat file already exists with the name and filepath you specify, it will be replaced.

Now you are ready to create your data analysis object and run an analysis!

## Running a typical analysis:

There are two steps to running data analysis – the first is to run the file `create_data_analysis_tool.m.` This is not a regular script or function, so opening the file and hitting run in the MATLAB environment will not work. It is a class and when you run it, it creates an object. You should run it from the matlab command line. Here's an example:

```matlab
da = create_data_analysis_tool(path_to_settings_file, '-group', '-tsplot');
```

The first input is the path to the settings file which you just created. This will tell the class what specifications to use in the analysis. After this are multiple optional inputs, or flags, which tell the `create_data_analysis_tool` function what analysis to do. The currently accepted flags are as follows:

- `'-group'` – Include this if you're analyzing many flies
- `'-single'` – include this if you're analyzing a single fly. **NOTE:** You must include either single or group flag!
- `'-normfly'` – normalize the data over each fly
- `'-normgroup'` – normalize the data over groups
- `'-hist'` – plot basic histograms
- `'-TSplot'` – plot open loop timeseries data
- `'-CLhist'` – plot closed loop histograms
- `'-TCplot'` – plot tuning curves

Make sure not to leave out the apostrophes or the dash. Any subset of these can be passed in, in any order. They are not case-sensitive. 

When you run create_data_analysis_tool, you want to store it in a variable. In the example above, I called this variable `da`. 

This in itself will not run the analysis. What it does is creates an object, da, with all of your settings stored in it and the options for whatever flags you passed in turned on. You can use this object to double check if everything is correct if you would like. For example, you could now type `da.save_settings` into the command line to review your save settings. If you forgot to pass in a flag, you could say `da.TC_plot_option = 1` to retroactively tell it you want to make tuning curves as well. If you forgot to update the colors of your timeseries plot, you could say `da.timeseries_plot_settings.rep_colors = [0 0 0; 0 1 0; 0 0 1]` and update them.

It is not likely you will want to update variables this way if there are many – it would be easier to create a new settings file. But when this tool needs to be called by other pieces of software, this system makes it much easier to automatically run the correct analysis without the software having to edit or create any settings files. 

Once you know there are no adjustments to be made, simply type in the command da.run_analysis, and this will start the analysis running. Assuming no adjustments after creating your data analysis tool, your commandline command will look something like this:

```matlab
Create_settings_file(filename, filepath) % If you were creating a new settings file
da = create_data_analysis_tool(path_to_settings, ...
            '-group', '-hist', '-TSplot', '-tcplot', '-normgroup');
da.run_analysis
```

This will produce a number of graphs, automatically saving them at the save path you entered, then closing so you don't end up with a large number of windows to x out of. They will be automatically saved in the following way:

`Datatype_groupNames_plotType_#.pdf`

# Adding new modules:

Coming soon


# Appendix: Full list of settings:

Coming soon

{::comment}this was copied from the original file Data_analysis_documentation.docx{:/comment}