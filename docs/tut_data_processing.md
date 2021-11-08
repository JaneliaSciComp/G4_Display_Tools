---
title:  G4 Data Processing
parent: G4 Automated Data Handling
grand_parent: Generation 4
nav_order: 1
---

# Overview

To set up your automatic data processing (which will actually take place after an experiment is finished running via the [Conductor](G4_Conductor_Manual.md)), you will need to edit one file, called `create_processing_settings.m`. You can find it in `G4_Display_Tools/G4_Data_Analysis/new_processing_settings`. Note that there are two folders in `G4_Data_Analysis` called `data_processing` and `data_plotting`. These are older files, compatible with older versions of the Display Tools, but they will not work with the current version on github.

After opening `create_processing_settings.m` you will go through the file and change the settings to match your needs. Notice that the settings are simply MATLAB variables. You can change the value of any given variable, but do not create or delete any. Once the settings are how you want them, you will save the file, and then run it in MATLAB. It should only take a second to run. When it is finished, you should find a new .mat file in your Experiment folder (or wherever you chose to save the file) containing your processing settings. When you use the Conductor to run the experiment, you'll see a textbox that wants a processing file. You will provide the path to this file you just created, and the Conductor will process the data accordingly when the experiment is done running. See more details about this in the [Conductor documentation](G4_Conductor_Manual.md).

# The Settings in Detail

## Save Settings

### Settings File Path

`settings_file_path` is, by default, set equal to a string. Don't worry if you don't know what that means. Simply replace the filepath there with the filepath where you want your settings file to be saved. Include the name of the settings file (no extension), and be sure to leave the path inside the single quotation marks. For example, it should look something like this:

```MATLAB
settings_file_path = '/Users/username/Documents/experiment_folder/processing_settings';
```

## General Settings

### Trial Options

`trial_options` should be set equal to a 1×3 array of 1's and 0's. They represent the presence or absence of a pre-trial, inter-trial, and post-trial. For example, an experiment containing a pre-trial and post-trial, but no inter-trial, would look like this:

```MATLAB
settings.trial_options = [1 0 1];
```

1 indicates it is present, 0 indicates it is absent, and placement follows this pattern: `[pre-trial inter-trial post-trial]`.

### Path to Protocol

`path_to_protocol` is set equal to a filepath string, exactly like number 1. This path, however, should be the path to your experiment's .g4p file. For example:

`settings.path_to_protocol = '/Users/username/Documents/experiment_folder/experiment_file.g4p';`

### Channel Order

`channel_order` should not generally change, except for perhaps when you first set up your arena. This indicates the order of your input channels. The default is as follows:

`settings.channel_order = {'LmR_chan', 'L_chan', 'R_chan', 'F_chan', 'Frame Position', 'LmR', 'LpR'};` where

`LmR_chan` is the channel returning left minus right data
`L_chan` is the channel returning left wing data
`R_chan` is the channel returning right wing data
`F_chan` is the channel returning wing beat frequency data
`Frame Position` is the channel returning the position of the pattern on the screen
`LmR` and `LpR` are empty. These are simply place holders indicating where the final aligned and processed Left minus Right and Left plus Right data will be stored.

So essentially this order indicates channel 1 returns Left minus right data, channel 2 returns left wing only data, channel three returns right wing only data, etc. If your hardware is set up differently to this, you may need to change the order. However, DO NOT change the codes used to indicate each channel. The software will search this array for 'LmR_chan' to figure out which channel number should be associated with LmR_chan, but if you were to change the code to LmR_channel, it would not be able to find it. So rearrange the codes only if necessary, but do not change them.

If any of these channels (besides the last two) are not implemented in your set up, just put the unimplemented codes at the end of the array. Don't remove them.

### Histogram Datatypes

`hist_datatypes` is an array indicating what datatypes should be used for histograms. This is relevant only to closed-loop experiments, and only if you plan to use the data analysis tools to automatically generate histograms of the data. If you are not running a closed-loop experiment or plotting histograms, just leave it as is. The order of the datatypes doesn't matter, so this should probably not be changed except under very specific circumstances.

### Manual First Start

`manual_first_start` should be set to 0 if you are using the Conductor to run your experiment. The only time this would be set to 1 is if you are using Panel_com directly to manually start your trials. If that doesn't make sense to you, don't worry, you'll learn about it in the Conductor documentation. Just leave this set to 0.

### Data Rate

`data_rate` indicates the rate at which data is collected in Hz. It should usually be set to 1000.

### Duration of data to include before trial start

The raw data returned from the screen is not broken up into trials. It is a single very long array of numbers. It also provides an array of timestamps and times at which commands were received to the screen (like 'start-display'). This information is used by the processing software to align the data to the timestamps and break it up into the appropriate trials. `Pre_dur` tells the software to include some amount of data before the 'start' command is received when aligning the data. This allows for a buffer in case the timestamps and data don't align perfectly. It should be set to something small. Default is 0.05 (in seconds).

### Duration of data to include after trial end

`post_dur`is exactly the same as `pre_dur`, but provides a buffer at the end of the trial. Set it to something small (.05 is default)

### Duration after start of trial to remove from plots

`pre_dur` and `post_dur` allow you to include a bit of buffer data at the beginning and end of a trial when aligning your data. `Da_start` now refers to the actual analysis of your data. If you want your time series or histogram plot to actually start sometime after the 'start' command for the trial was received, set that amount of time here. It should be small - anywhere from 0 to 0.05 (in seconds). Oftentimes, the very beginning or end data of a trial is junk - there is a small lag from the time the command is received to the time the pattern actually displays on the screen, or the fly is still responding to a previous stimulus. You can adjust this and `da_stop` to get rid of some of that noise at the very beginning or end of a trial.

### Duration before end of trial to remove from plots

Exactly the same as `da_start`, but instead `da_stop` is the number of seconds to end a plot before the actual end of the trial.

### Time conversion factor

`time_conv` is just a conversion factor to convert from the units of time used in analysis (seconds) and the time used by the screens (microseconds). This shouldn't generally be changed unless your arena measures time in something other than ms.

### Do conditions have a common duration?

`common_cond_dur` stands for "common condition duration." It should be set to 1 if all conditions in your experiment are the same length, and 0 if they are not all of the same length. This is simply used to check for errors after the software has split the data up into trials.

### File name of processed data

`processed_file_name` should be set to a string indicating what you want your file of processed data to be called (do not include an extension). This does not refer to the processing settings .mat file - that name is assigned in the very first variable. Instead this refers to the file that will be created after an experiment is run and the data has been processed into datasets. Those datasets are saved as a .mat file inside the fly folder that is generated when you run a fly through the protocol. So each fly that is run through this experiment will end up with its own folder, and each fly folder will have a .mat file in it with this name, containing all the data collected for that fly. For example:

`settings.processed_file_name = 'processed_data';`

### Are you using the combined command in your run protocol?

If you are using the default run protocol to run your experiment, `combined_command` should be set to 0. If you're not sure what a run protocol is, don't worry about it. Leave this set to 0 and you will learn about the run protocol in the Conductor documentation. There is a run protocol that utilizes a combined command. What that means is that, instead of sending information to the screens separately (ie, sending the screen the pattern, the function, the condition mode, etc all using separate commands), it sends all information for a particular condition to the arena at once, using one combination command. All the bugs have not been worked out of the combined command yet, and as of right now we don't suggest using it. But if you were to use it in the future to run an experiment, then you should make sure this variable is set to 1 in that experiment's processing settings. Don't worry if this doesn't make sense to you now - see the [Create your own run protocol tutorial](tut_cond_run-protocol.md) to learn about how commands are sent to the screens.

### Percentage by which a trial can need shifting and still be acceptable

It's not uncommon for the trial data and the timestamp data to be slightly misaligned. `percent_to_shift` sets a tolerance for how much trial data can be shifted in either direction for the sake of alignment before the trial is considered bad and tossed out. (don't worry, by tossed out, I don't mean that the data will be deleted - it will just be logged as a failed trial and left out of any plotting or analysis done. It will still be accessible). Default is .015, meaning if we need to shift data by more than 1.5% either direction to get it to align appropriately, then we assume something went wrong in that trial and we mark it as bad.

## Wing Beat Frequency Settings

### Acceptable Wing Beat Frequency Range

`wbf_range` indicates the acceptable minimum and maximum wing beat frequencies. It should be defined as an array, for example:

`settings.wbf_range = [160 260];` This means that wing beat frequencies outside of this range should be considered bad flying. Any trial where too much time is spent outside this range will be marked as bad because the fly stopped flying too much or there was some other error with the wing beat frequency. How much time a fly can spend outside this range before a trial is marked as bad will be set using another variable.

### Wing Beat Frequency Cutoff

`wbf_cutoff` indicates the maximum acceptable percentage of a condition where the fly is not flying (outside the range set above) before a trial is marked as bad. The default, for example looks like:

`settings.wbf_cutoff = .2;` This means that if the fly's wing beat frequency is outside the above range for more than 20% of the trial, the trial will be tossed out as a bad trial.

### Percent of bad wing beat frequency time at the end of the trial

`wbf_end_percent` acts as an adjustment to the previous variable. Sometimes, a fly may stop flying for more than 20% of the condition (or whatever number 18 is set to) but that non-flying time is all clustered at the end of the condition. Oftentimes, the first 80% of the trial is good and the last 20% the fly doesn't fly well because it is just tired from the condition. In this case, you may still want to keep the condition's data. So this variable sets the percentage of non-flying time that must be clustered at the end of the condition in order for you to KEEP the condition if the cutoff percentage in 18 was triggered. That's a little confusing, so here's an example:

`settings.wbf_end_percent = .8;`   This means if 80% or more of the total non-flying time of a condition is found in the last 10% of the condition, then the trial should be kept as good because the first 90% of the condition is probably okay. That 10% is not adjustable, the 80% is. If you do not want this exception, and you want to get rid of any trial where the fly spent 20% or more of its time not flying (20% being set in number 18), then set this variable to 1. If you want it more stringent, change it to something like .95, in which case a condition will only be kept if 95% of the fly's non-flying time is found in the last 10% of the condition.

## Normalization Settings

### Max Percentile for Normalization

`max_prctile` is used in the normalization of your data. The data is normalized by setting the maximum value throughout the data equal to 1 and minimum to -1 and adjusting the rest of the data accordingly. However, in an experiment, it is quite likely that somewhere there will be an outlier value much higher or lower than the rest, due to screen glitch or bad fly. As such, we set this to indicate the value we use as "maximum" and "minimum" should not be the absolutely highest or lowest value, but instead should be the value of the 98th percentile (and therefore 2nd percentile for the minimum). You can change this to 1 if you do not want to implement this precaution, but we recommend .98 or .99.

## Position Series Settings

### Enable Position Series

Position series data is when we create plots similar to time series plots, but instead of plotting against time, we plot against of the position of the pattern on the screen. This only makes sense for certain types of patterns, like sweeps. If you want to generate this data, set `enable_pos_series` equal to 1. It is set to 0 by default. If you leave this set to 0, you can ignore the rest of the settings in the position series section.

### Conditions to include in position series

`pos_conditions` should be set equal to an array indicating what condition numbers to include in the position series data if it is enabled. If enable_pos_series is set to 0, then leave this at its default value - it won't be used. If position series is enabled and you want all of your conditions to be included in the position series data, then you can leave this as an empty array, which would look like:

`settings.pos_conditions = [];`

If position series is enabled and you only want certain conditions to be used, then fill the array with the appropriate condition numbers. For example, `[1:28]` would indicate conditions 1 through 28, or `[1 3 5 7 9 11 13 15 17 19]` would indicate only condition numbers listed in the brackets should be included.

### Sensorimotor Delay

`sm_delay` is set to 0 by default but if you expect a sensorimotor delay, you can set this to a number (in ms) to account for that delay when creating position series data.

### Number of possible positions on screen

`num_positions` indicates how many possible positions there are for your pattern when making position series, and will dictate the x-axis in position series plots. It is set by default to 192 as our sweep patterns have 192 position from left to right.

### Data pad

`data_pad` is a number in milliseconds. It is applied only to position series data and gives a small buffer at the beginning and the end of a condition to account for lag between the time the screen receives the command and the time the pattern is actually visible. It is set to 10 ms by default.

## Flipping and averaging of LmR data settings

### Enable FaLmR

Sometimes it is useful to generate an faLmR dataset, meaning a dataset where the left minus right data of two different conditions are averaged together after flipping the sign of one of them. This can be useful if you are running two conditions that are exactly the same except symmetrical to each other in some way. If you want this kind of data set, set `enable_faLmR` to 1. If this is enabled, you will have to provide information about which conditions should be paired together.

### faLmR Condition Pairs

If `enable_faLmR` is set to 0, you can ignore `condition_pairs`. If it is set to 1, you should adjust this setting accordingly.

`condition_pairs` is a cell array. If you're not sure what that is, don't worry. There is an example in the code comments. Leave everything the same and just change the condition numbers.

You may leave `condition_pairs` empty, like this:

`settings.condition_pairs = {};`  Note the curly brackets, not regular brackets. If you leave it empty, the software will pair conditions sequentially, meaning condition 1 will be paired with 2, 3 with 4, 5 with 6, etc. This means that in addition to the normal Left minus right dataset, you will get a dataset with only half of the data points, where condition 2's sign has been flipped and then it has been averaged with condition 1, 4 has been flipped and averaged with 3, etc.

If your experiment is not set up this way, where symmetrical conditions are right next to each other, then you will need to manually define which conditions should be flipped and averaged together. That will look something like this:

```MATLAB
settings.condition_pairs{1} = [1 6];
settings.condition_pairs{2} = [2 5];
settings.condition_pairs{3} = [3 8];
```

This means that the first pair is conditions 1 and 6. The second condition listed, 6 in this case, is the one that will have its sign flipped. Do this for as many pairs as you want flipped and averaged.

## Summary Settings

### Filename for summary of bad trials

You might have noticed by now that the data processing does some automatic error checking where it looks for trials where the data looks like it has errors in it. A trial can be marked as "bad" for several reasons.

1. If the fly stopped flying for too much time during the trial
2. If the data is too badly misaligned
3. If the length of the data for a particular condition is significantly different than expected
4. If the slope of the results for the trial is 0 all the way through (meaning 0 motion was measured)

Once all the data has been processing, any trials that were bad will have their condition and repetition number logged in a text file, along with an error code indicating why that particular trial was removed from the dataset. The data is not lost, you can still find that trial in the raw data to look at it if you want to analyze it yourself, but when you create plots using the processed data, any trials listed in this text file will not be included in the data. It's not unusual for one or two trials to be bad in a particular experiment, but if you notice that a certain condition is always being tossed out, then you may want to look deeper into why.

`summary_filename` is where you can set the filename for this text file. It should be a string. Default is:

`settings.summary_filename = 'Summary_of_bad_trials';`

### Save path to the summary file

By default, this summary file of bad trials will be saved inside the fly folder, where that fly's raw data and processed results are saved. If this is what you want, simply leave this variable empty, like this:

`settings.summary_save_path = [];`

However, if you want to save this file elsewhere, you should set this variable equal to a string containing the filepath, like this:

`settings.summary_save_path = '\Users\username\Documents\bad_trials';`

# Okay I've adjusted all the settings. Now what?

Once all your processing settings are correct. Save the file and then click `Run`. You'll find it at the top of your MATLAB editor with a green triangle on it. After the file runs, be sure you check that the file was saved. A .mat file should appear at the settings filepath you provided way at the beginning of the file, under the name you provided. Don't forget where this file is - you'll need it when it comes time to run the experiment on the Conductor. Unless you change your mind about how you want your data processed, you should not have to go through this file again - the same processing should be done for every fly put through this protocol.

# What if I've already run my experiment and I want to process the data later?

You can do that! After you run a fly through a protocol, that fly gets its own folder inside the experiment folder where that fly's data is saved. If you have not run any data processing, then when you open the fly folder, you should see a subfolder containing a set of .TDMS files as well as a .mat file called `G4_TDMS_Logs_[numbers and stuff]`. If you were to open this .mat file, you'd see it contains a single MATLAB struct called Log that contains all your raw data. This data is not broken up or labeled in any way - it's just the stream of data that was collected over the course of the whole experiment.

First if you haven't done it, you should go through the processing settings exactly as described above, and when they are the way you want them, run `create_processing_settings.m` so you have a saved .mat file with your settings. This part has not changed, but there is another step that would normally be done by the Conductor.

Making sure all the files in `G4_Display_Tools` is on your MATLAB path, type the following into your MATLAB command window:

`process_data('path to fly folder', 'path to processing settings file');`

Replace the text inside the single quotes with the path to your fly's folder (not to the TDMS files or .mat file) and the path to the settings file you just saved, respectively. This command will start the data processing, and it may take a minute or two to run. When it is finished running, a new .mat file should have appeared in your fly folder containing your data.

# What does the processed data look like?

Once processing has been done, you will end up with a new .mat file in your fly folder with the name you provided in your settings. If you open it in MATLAB, you'll see many different variables are saved in this .mat file. Let's go through them.

The first five variables you will see are:

```MATLAB
bad_crossCorr_conds
bad_duration_conds
bad_duration_intertrials
bad_slope_conds
bad_WBF_conds
```

As you might guess, these variables hold the condition and repetition numbers of any trials that were marked as bad for a particular reason. Any conditions in the first one were tossed because they were unable to be aligned. In the second array, it was due to the data being significantly longer or shorter than the expected duration. The third is the same but contains any inter-trials that were tossed (this will simply be empty if your experiment did not have an inter-trial). The fourth because the data was completely flat, and the fifth because the fly stopped flying too much during the trial.  These arrays have two columns and a variable number of rows. The first column indicates repetition number, the second column indicates condition number.

`channelNames` is a struct with two cell arrays, indicating the channel order for both time series data and histogram data. These are simply copies of what you put in the processing settings, saved for your information.

`cond_frame_move_time` is an array of times given in milliseconds. It has a number of columns matching the number of repetitions in the experiment, and a number of rows matching the number of conditions in the experiment. Each number is an estimate of exactly how much time passed between the moment the screens received the 'start-display' command and the moment the pattern on the screen actually moved for the first time.

`conditionModes` is simply a list showing the experiment mode of each condition.

Next you have four variables relating to flipped and averaged data, assuming faLmR was enabled in your settings. If it was not, then you will not have these variables, or they will be empty. They are:

```MATLAB
faLmR_avg_over_reps
faLmR_avg_reps_norm
faLmR_timeseries
faLmR_timeseries_normalized
```

These are arrays of data with a number of rows matching half of the number of conditions in an experiment, and many columns. See the faLmR settings explanation above for a refresher on how we calculate this data. These four arrays use the same data, but have had some basic things done to it for your convenience. `faLmR_timeseries` is the full, original data, and it has a third dimension, the size of which matches the number of repetitions in the experiment. This contains the flipped and averaged data for every condition and every repetition. `faLmR_timeseries_normalized` is the same, but the data has been normalized to the max/min values in the dataset. `faLmR_avg_over_reps`, you'll notice, does not have the third dimension. Here, the different repetitions of a single condition have all been averaged together. So each condition only has one data point -- the average of each time that condition was repeated. `faLmR_avg_reps_norm` is the same, but the data has also been normalized.

Note that we tried to keep this naming scheme the same for different datatypes (LmR, LpR, etc). Knowing this may help you understand what the other arrays are without having to look them up in the documentation.

`histograms_CL` will only be relevant if you ran closed-loop conditions. This data has already been adjusted to be plotted directly as a histogram.

`interhistogram` contains your inter-trial data, adjusted to plot as a histogram. Its dimension are the number of inter-trials run by the number of positions the pattern can have across the screen.

Next are four variables, similar to faLmR but containing LmR and LpR data:

```MATLAB
LmR_avg_over_reps
LmR_avg_reps_norm
LpR_avg_over_reps
LpR_avg_reps_norm
```

These variables are the same as `faLmR_avg_over_reps` and `faLmR_avg_reps_norm`, but for LmR and Lpr data instead.

`mean_pos_series` will be empty if position series was not enabled. Otherwise it will contain your position series data, averaged over repetitions.

`normalization_max` is the maximum value from the data that was used for normalization.

`pattern_movement_time_avg` is the same as `cond_frame_move_time` but averaged over the repetitions, so there is just one average "command to movement" time for each condition, in milliseconds.

`pos_conditions` is simply a copy of the conditions you included in your position series. It is irrelevant if position series was not enabled.

`pos_series` is the position series data with no averaging.

`summaries` is data intended for creating tuning curves. Its dimensions should be number of datatypes by number of condition by number of repetitions. It averages all the data collected during each trial, resulting in one data point per datatype per condition per repetition.

`summaries_normalized` is a normalized version of `summaries`.

`timeseries` is the most basic variable containing most of the data unaltered. Its size is number of datatypes × number of conditions × number of repetitions × data length. It contains the collected data for each datatype for every condition and repetition. The datatypes follow the order in channelNames. So looking at the first dimension of `timeseries`, the 1 is the first datatype listed in channelNames, 2 is the second datatype in channelNames, etc. So `timeseries(6,1,3,:)` would represent the unaltered LmR data (assuming you kept LmR as your sixth channel in channelNames) for the first condition, third repetition. `LmR_avg_over_reps`, then, is simply `timeseries(6,:,:,:)` averaged over the third dimension (repetitions). We have just done this averaging for you and saved it under a new name for your convenience because it is very commonly needed.

`timeseries_normalized` is just the same as `timeseries` but has been normalized to the maximum value saved in `normalization_max`.

`timestamps` is simply an iterative list starting at a certain number and increasing by one millisecond at a time. It used in alignment.

`ts_avg_reps` is the `timeseries` array, but averaged over repetitions.

`ts_avg_reps_norm` is the `timeseries` array, both averaged over repetitions and normalized.

# Final Notes

If you are interested in the code which actually runs the data processing, it is located at `G4_Display_Tools/G4_Data_Analysis/new_data_processing/process_data.m`.  This file calls many different functions that are used throughout processing. These functions can all be found in `G4_Display_Tools/G4_Data_Analysis/support/data_processing_modules`.

*Please do not edit or alter this code in any way unless you are very confident in your changes. Alterations to one function can have impacts on any other code that uses that function!*

Now that your data processing is set up and you know what to expect out of it, you can move on to [data analysis](tut_data_analysis.md). There, you will create settings dictating what types of plots you want to be automatically generated, using the processed datasets, after an experiment runs. You can also set up analysis settings to quickly generate plots for groups of flies later.
