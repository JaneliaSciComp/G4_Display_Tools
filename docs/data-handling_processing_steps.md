---
title:  G4 Data Processing Step by Step
parent: G4 Automated Data Handling
grand_parent: Generation 4
nav_order: 2
---

# Overview

After each experiment on the arena, the data that was collected will be processed according to the settings you created (see [processing setup](data-handling_processing.md)). What follows is a step by step description of what the processing does - how it splits up the raw data, aligns data and checks the quality, breaks it up into datasets, and all assumptions that are made along the way. If you see anomalies in your data and need to confirm the data processing is doing what you expect it to, this is the place to look. 

If you'd like to follow along in the code, open the file `G4_Display_Tools\G4_Data_Analysis\new_data_processing\process_data.m`. 

# Data Processing Step by Step

## Establishing variables

The first 150 lines of code are setting up variables that will be used throughout the processing. Variables are pulled from the processing settings file and saved for use. Starting around line 47, the code checks for the presence of certain variables in the processing settings, and if they're not present it sets a default value. This is so that an older settings file could be used and still work with the processing even if it was created before those variables were added. Comments in the code describe what each variable does. Around line 125 we load the TDMS Log file with all the raw data, and after that we get the index of each channel so we know which array index in the log is which data type. Finally, we load the metadata file so we can access information about if and how many trials were re-run at the end of the experiment. Around line 160 starts the actual processing of data which is split into a sequence of functions. Next we will go through each function one by one to see what they all do. All functions are separate .m files that can be found in `G4_Display_Tools\G4_Data_Analysis\support\data_processing_modules`.

## Get experiment order - Line 163

`get_exp_order.m` is a function that loads the file `exp_order.mat`, determines the number of conditions and number of repetitions in the experiment, and gets the total number of trials expected in the experiment. It returns four variables. 
`exp_order` is an array of size number of conditions x number of repetitions. It contains the condition numbers so we know it what order the conditions actually displayed. 
`num_conds` is the number of conditions in the experiment.
`num_reps` is the number of repetitions in the experiment.
`total_exp_trials` is the total number of trials (including pre, inter, and post-trials) in the experiment. 

## Get Position Functions - Line 169

`get_position_functions.m` is a function that loads the experiment protocol and saves the data of each position function so it can be easily accessed and used later when checking the alignment and quality of the frame position data. For each condition in the experiment, it gets the mode of that condition and, if applicable, loads the associated position function. If the condition does not have a position function, it leaves a NaN in place of the position function data. This function returns two variables:

`position_functions` is a cell array with an element for each condition in the experiment. Each element contains the position function data for that condition, or a NaN if that condition has no position function.
`exp` is a struct containing the loaded protocol file, saved in case we need to use any other information from the experiment protocol later on. 

## Get Start and Stop Times - Line 176

`get_start_stop_times.m` is a function that finds the indices in the raw data of the start and stop commands, whether those be the `Start-Display` command or the combined command. 

The Log structure containing the raw data has a field called Log.Commands.Name. In line 4 of this function we find the index of each command name that matches the `command_string` variable (which may be 'Start-Display' or the combined command) and save in the variable `start_idx`. We then plug these indices into the Log.Commands.Time array to get the timestamps at which each start command was received. This returns the `start_times` array. 

Since the `Stop-Display` command is not used commonly to end a trial, the `stop_idx` and `stop_times` arrays are found exactly the same way, except that the first index and timestamp found is manually removed. So the stopping point of one trial is the point at which the start command is received for the next trial. This will inevitably lead to some extra noise at the end of each trial which we will deal with later. This also means that there's no stop point found for the last trial of the experiment. Generally the last trial is ended with the 'Stop-Display' command so at line 11 we search for that command, find the index, and add the associated timestamp to the end of the `stop_times` array. If the 'Stop-Display' command cannot be found, we use the 'Stop-Log' command instead. If neither can be found, we simply assume the last data point in the data is the stop time of the last trial. A message is displayed to the user pointing out that the stop time could not be found so the last trial's data may be longer than expected.

At the end of this function we check one more thing - the `manual_first_start` variable. If this is set to 1, then the first trial was not started by the start command, but instead manually by the user. If this is the case, our method above would not have found the start point of the first trial. Therefore we assume the start time of the first trial is the first data point of the data, and add that associated timestamp to the beginning of the `start_times` array. 

This function returns four variables, all of which have been discussed: `start_idx`, `stop_idx`, `start_times`, and `stop_times`. 

## Separating Original Conditions from Re-runs - Line 188

`separate_originals_from_reruns.m` is a function found on line 188. It determines what data is from the initial protocol and what data comes from trials being re-run at the end of the experiment because the first attempt was marked as bad. This is only relevant if the experiment was run using the streaming protocol and the Conductor was set to re-run bad conditions. 

First it calculates the total number of original trials and the total number of rerun trials. It then compares the sum of these to the length of the `start_times` array created in the last function. If the number of calculated total trials is greater than the length of `start_times`, it's assumed that the experiment was ended early and processing continues, though a warning is provided to the user. It then calculates the number of extra trials that were not run due to the experiment ending early. If the total number of calculated trials is less than the length of `start_times`, the processing also attempts to continue but a warning is provided to the user and an error will likely occur later on, since there's no acceptable reason for there to have been more start commands than the total number of trials and reruns put together. By line 25 there are two more variables that have been set that will be used later on, `ended_early` which is either 1 if the experiment was ended early or 0 if it was not, and `num_extra_trials` which is the number of trials that ended up being missed if an experiment was ended early. 

Next starting at line 28, if there were more trials run than the expected number from the protocol (so there were reruns at the end), we split the `start_times` array into `origin_start_times` which is the start times of all the original trials, and `rerun_start_times` which are all the start times for the rerun trials at the end. Please note that, in the case that no trials were rerun at the end, `origin_start_times` is simply the same as `start_times` and `rerun_start_times` is an empty array. 

At the end, starting at line 78, these arrays are all saved into a struct called `times` for ease of passing them in and out of functions. The function returns three variables, all of which have been discussed: `times`, `ended_early`, and `num_extra_trials`. 

## Get the modes and pattern IDS of conditions in order - Line 192

The function `get_modeID_order.m` works similarly to `get_exp_order.m` except in this one we are getting the pattern and mode IDs. It again gets the index of each time the 'Set Pattern ID' command was recieved from the Log.Commands.Name array, and gets the value that was received with each command by plugging those indices into the Log.Commands.Data array. It does the same with the 'Set Control Mode' command. You end up with two arrays that are returned from the function: 

`modeID_order` is an array with the mode of each trial in the order it was received.
`PatternID_order` is an array of the pattern IDs of each trial in the order it as received. 

## Further differentiate the start and stop times of trials - Line 205

`get_trial_startStop.m` is a function that determines the start and stop times for different trial types (pre, inter, post, conditions, etc). In addition, if any conditions were bad and then rerun at the end of the experiment, it replaces the start times of the bad conditions with those of the rerun conditions. This way, when we use the start times later to pull the data for those trials, we will pull the good run and not the bad one. 

First this function pulls the start and stop times from the `times` struct created earlier. It gets the number of trials run (conditions only) and adjusts the `trial_options` variable if needed. This variable indicates the presence of a pre-trial, inter-trial, and/or post-trial. For example, if the experiment was ended early and was intended to have a post-trial, that needs to be changed since ending the experiment early means the post-trial was not run. It gets the index of the first condition to be run and the last condition to be run in the `origin_start_times` array. At line 39 it creates a new variable, `trial_start_times` which includes only the start times of conditions, not of inter-trials or other types of trials. It does the same for stop times and modes. It also finds the start times in between each condition, or in other words, the intertrial start times, and uses this data to get the modes and durations of each intertrial. It does the same thing for reruns, so we end up with an array for rerun trial start times and rerun intertrial start times. 

Starting at line 96, the code goes through each rerun trial, get the condition and repetition number that was being rerun, and then finds that in the `exp_order` array to determine which original trial was being repeated. It then goes into `trial_start_times` (and stop times) and replaces the start time of that bad trial with the start time of the rerun trial. 

All arrays created (start/stop times for reruns, intertrials, and conditions) are then saved to the times struct, which is returned from the function as well as several of the other variables discussed.

### Line 209 in processing

Here we have a bit of code not contained in a function. This simply calculates the number of conditions short the data is if the experiment was ended early. Later this will let us use the `exp_order` variable to determine exactly which conditions were skipped by ending early.

## Organize durations and modes by condition - Line 213

The function `organize_durations_modes.m` is found on line 213. This function calculates the measured duration of each condition, the time gaps between conditions (expected to be the length of the intertrial), and organizes start times by condition and repetition. 

At line 27 it adjusts the expected number of trials based on if the experiment was ended early. Then for each trial, it finds condition and repetition number, calculates the duration and saves it to `cond_dur`, gets the mode and saves it to `cond_modes`, and calculates the gap between it and the next condition, saving it to the variable `cond_gaps`. In addition, it creates a variable called `cond_start_times` which reorganizes the start times from a single long array to an array shaped by condition and repetition number. So all of these arrays are of a size number of conditions x number of reps, so data for any given condition/rep pair is easy to find later in these arrays. The four arrays just discussed are returned from the function. 

## Create empty timeseries arrays - Line 218

The function `create_ts_arrays.m` calculates the size and shape of the timeseries data and returns arrays full of NaNs which will later have condition and intertrial timeseries data assigned to them. It first finds the condition with the longest duration (even though most conditions in theory have the same duration, the measured duration will vary slightly). It then sets the `data_period` which is calculated from the variable `data_rate` provided by the user. The data period is the time between one data point and the next, generally 1 ms for behavioral data and 2 ms for frame position data. It then establishes the variable `ts_time`. This variable later becomes the `timestamps` variable and is the x-axis against which timeseries data will be plotted. If the user has provided a value to the variable `pre_dur` in the settings, then the `ts_time` variable is defined as an array of numbers from -pre_dur-data_period to the longest duration plus the post_dur plus the data_period, with steps betwen defined by the data period. This is done on line 9. `ts_data` then is defined on line 10 as an array of size [number of timeseries data types x number of conditions x number of repetitions x length of `ts_time`]. If intertrials are included in the experiment, then the same thing is done for intertrial data. 

The four variables returned then are the `ts_time`, `ts_data`, `inter_ts_time`, and `inter_ts_data`. Note that these variables still only contain NaNs at this point. 

## Get unaligned timeseries data organized by datatype, condition, and repetition - Line 224

The function `get_unaligned_data.m` takes in many of the arrays we've generated up to this point and uses them to split up the behavioral and frame position data from the Log into an array organized by datatype, condition, and repetition. It is unaligned because the start of each trial is defined by when the 'Start-Display' command was received. It has not yet been cross correlated or aligned to when the pattern started moving. Data is saved to the array `unaligned_ts_data` which is 4 dimensional - channel number x condition x repetition x duration of longest condition.

For each trial, whe use the `exp_order` variable to get the condition number and calculate the repetition number. The variable `num_ADC_chans` tells us how many channels there are, so for each channel we find the start index and stop index of that trial by finding the first element in Log.ADC.Time which is greater than or equal to the timestamp given in `trial_start_times` and less than or equal to the timestamp given in `trial_stop_times`. We then, at line 22, use those indices to get the data and time data for that particular trial. 

For formatting purposes, we need each element in the timeseries data array to be the same length, but each condition will vary slightly in the length of the data. So lines 24-31 check for the difference between the length of the data we just pulled and the length of the array we defined earlier. If the data we just pulled is shorter, we add NaNs to the end to fill in the space. If it's longer, we remove data at the end to shorten it. The latter case should not really ever happen, since the array was defined based on the longest condition.

Starting at line 39 we do the same process but for the frame position data. Find the start and stop indices, use them to get the data from Log.Frames.Position. At line 51 we start one extra step which is expanding the frame position data. Since generally the frame position data is collected at a data rate of every 2 ms, while the behavioral data is collected at a rate of every 1 ms, the frame position data will only be half the length of the behavioral data. So we create an array called `full_fr_data` which is twice the length of the frame data we just got out of the Log. Then we go through it and fill in the gaps between each data point with the data point previous to it. So for example, frame data of [1 1 2 2 3 3] becomes [1 NaN 1 Nan 2 NaN 2 NaN 3 NaN 3 NaN] and then NaNs get replaced with the number preceding it, so this becomes [1 1 1 1 2 2 2 2 3 3 3 3]. Each of these representing the frame position over 12 milliseconds. This expanded data then is saved to the `unaligned_ts_data` array. 

Next, starting at line 70, we get the unaligned intertrial data, assuming the experiment included intertrials. It is the exact same process as above, using the intertrial start and stop timestamps to pull the correct data from the Log. The array `unaligned_inter_data` is a slightly different size because intertrials do not have repetition or condition numbers, they are simply numbered 1 through the number of intertrials run in the experiment. So this array is 3 dimensions instead of 4 - channel x intertrial number x length of intertrial data. Frame position data for intertrials is expanded using the same method as before. 

This function returns two arrays, `unaligned_ts_data` and `unaligned_inter_data`. 

## Check for conditions with the wrong duration - Line 231

`check_condition_durations.m` is a function that searches for any conditions that had a duration significantly longer or shorter than expected by comparing the `cond_dur` and `intertrial_durs` arrays created earlier to the expected durations stored in the protocol.

We get the expected duration of each condition directly from the loaded experiment protocol, and then go through each element in `cond_dur` and compare the found duration with the expected duration. If the percent difference between them is greater than the limit set by the user in the variable `duration_diff_limit`, then we add that condition and rep pair to the `bad_conds` variable.  The same is done for intertrials. 

Two variables are returned from this function, `bad_duration_conds` and `bad_duration_intertrials` which may or may not be empty. `bad_duration_conds` contains two element arrays that look like [repeptition condition] where as the `bad_duration_intertrials` is just a one dimensional array of intertrial numbers.

## Check for flat conditions if relevant - Line 233

If the experiment does not contain any intentionally static conditions, then the function `check_flat_conditions.m` looks for any conditions where the frame position data is flat, meaning the screen did not move at all. 

It cycles through the `unaligned_ts_data` array and looks at the frame position data for each. It goes through each data point in the frame position data, and if there is never a difference between one and the next, then the data is completely flat and that repetition condition pair are added to the `bad_slope_conds` variable, which is returned. 

## Find conditions where the fly wasn't flying if relevant - Line 238

Assuming this is a flying experiment, and the variable `remove_nonflying_trials` has been set to 1, the function `find_bad_wbf_trials.m` runs and searches the unaligned data for flies where the wing beat frequency falls out of range too much. 

The variable `F_chan_idx` tells us which channel contains the wing beat frequency data, so we use that to pull the right data from `unaligned_ts_data`. We go through the wing beat frequency data for each condition and repetition comparing each data point to the wbf range provided by the user. For every data point that falls outside of that range, we add it to the `bad_indices` variable. At line 34 we compare the percentage of bad data points to the cutoff determined by the user. If the percentage of data points outside of range is too high, we then check to see if these bad data points are clustered at the end of the trial at line 39. If a larger percentage of the bad data points are clustered at the end than set by the `wbf_end_percent` limit, then we keep the trial, but if the portion of them clustered at the end falls below that limit, then that repetition and condition pair are added to the variable `bad_trials`. 

This function returns the variables `bad_WBF_conds` and `wbf_data` which contains all the wing beat frequency data for easy use later. 

## Consolidate bad conditions - Line 248

At this point in the processing, we've done all the quality checks that can be done before alignment. There will be more quality checks after alignment, but because cross correlation and alignment take the largest chunk of time when processing data, we want to remove as much bad data as possible before doing the cross correlation. This way we don't waste time aligning data we already know is bad. Therefore, we next consolidate the bad conditions we've collected so far, and remove them, before then moving on to the cross correlation. This does mean that after cross correlation and alignment steps, we may find more bad conditions and will have to repeat these steps. 

The function `consolidate_bad_conds.m` takes in the various arrays of bad conditions produced by the last few sections, combines them into one array of bad conditions, and removes any duplicates. The function returns three variables, `bad_conds`, `bad_reps`, and `bad_intertrials`. `bad_conds` and `bad_reps` are each a one dimensional array of condition and repetition numbers of bad trials. They line up such that `bad_conds(1)` and `bad_reps(1)` are, together, the condition repetition pair of the first bad trial. `bad_intertrials` is a one dimensional list of bad intertrials. 

## Remove bad trial data - Line 255

The function `remove_bad_conditions.m` takes in the dataset you want data removed from, as well as the list of bad conditions and repetitions. It sets the data for those conditions and repetitions to NaNs. It only removes condition data, not data for intertrials. 

## Cross correlation of position data - Line 265

The function `position_cross_corr.m` cross correlates the collected frame position data with the expected position function data and gets a lag number indicating how the data should be shifted to best line up with the expected position function. 

It goes through each condition in `unaligned_ts_data` and checks the mode first. If the condition is in a mode that does not use a position function, then no cross correlation can be done and that condition is skipped. The matlab function `xcorr` is used to get the lag. A few different numbers are saved. `shift_numbers` is an array of size number conditions x number repetitions that gives the lag for that condition and repetition. We also create `avg_shift_numbers`, which contains the average lag, and `percent_off_zero` which gives the percentage by which the data needs to be shifted.

We compare the percentage off zero to the correlation tolerance provided by the user, and if it's too high then that condition and repetition pair is saved in the array `conds_outside_corr_tolerance`. If the data to be cross correlated is all NaNs (meaning it has been removed because the data was bad), then these arrays get NaN values for that condition and rep pair. These arrays are saved in a struct called `alignment_data` which is returned by the function. 

## Compile bad conditions from the cross correlation - Line 271

Though we have collected the condition/repetition pairs that fell outside of the correlation tolerance, they're formatted to be easily viewed by the user in the processed data, not to easily be removed by the function that removes bad data. So in `compile_bad_xcorr_conds.m` the bad conditions are reformatted into `bad_corr_conds` and `bad_corr_reps`. 

## Remove bad conditions - Line 276

The same function from line 255, used here to remove any conditions that fell outside of the cross correlation tolerance. 

## Shift data by its cross correlation lag - Line 281

The function `shift_xcorrelated_data.m` actually shifts the data by the lag values found by the cross correlation. It saves the shifted data in an array called `shifted_ts_data` which is the same size as `unaligned_ts_data`. We use matlab's circshift function in order to do this shift. The code goes through each channel of each condition/repetition pair. It gets the unshifted data from the `unaligned_ts_data` array. 

Assuming the data is not all NaNs, meaning it's already been removed, we then check the lag value for that condition/repetition. If it's greater than zero, that means the data needs to be shifted to the right. We use circshift to get `shifted_data`. Circshift shifts in a circular pattern, meaning if you shift data to the right, the data at the end of the array is moved to fill the space left at the beginning of the array. We don't want this data there, so after shifting, the datapoints from index 1 to the lag value are set to NaNs. 

If the lag is less than zero, that means the data needs to shift to the left. We use circshift again, and in this case, the data from the beginnig of the array will be moved to the end. We don't want that data at the end, we want it gone, so we then set the data points from the end minus the lag to the end of the array to NaNs. 

Filling in the gaps with NaNs after shifting the data ensures that the array itself will remain the same size, since the lag value may be different for each trial.

The function returns `shifted_ts_data`, an array of all the timeseries data after it has been shifted according to the cross correlation lag. 

## Get the pattern movement times - Line 291

`get_pattern_move_times.m` is a function that goes through the shifted frame position data to determine at what point the pattern on the screens actually started moving. We will later align our data to "start" at this point. 

Please note that there are some old functions in the folder which have similar names to this one. These were older methods for finding the pattern movement time but are not currently in use, so please make sure you're looking at `get_pattern_move_times.m`. These extra functions may be removed in future releases. 
{:.info}

For each condition/repetition pair, this function looks at the loaded position function data and finds the first movement of the pattern. For example, a position function may stay static for some amount of time and then start moving. We find the first movement and save it as an array, such as [1 2] if the first change in the frame position is from frame 1 to frame 2. It then looks at the frame position data in the `shifted_ts_data` array and searches from the beginning of the array for the first movement from frame 1 to 2 (or whatever movement it found in the position function). The index of first motion is the index of the changed value (the 2, rather than the 1). This index is saved in the array `pattern_movement_times` which is of the size number of conditions x number of repetitions.

In the case that a change in frame position matching the position function is never found, a warning is put out to the user alerting them that the movement time could not be found for that condition/repetition pair, and it is added to an array called `bad_conds_movement`. This means the frame position data never follows the intended position function but was not caught in other quality checks. 

In the case that there is no position function for that condition (due to it being a different mode, for example), then we search the frame position data for the first time it changes frames without comparing to any position function data. In this case, we skip the first 11 data points in the frame position data because there tends to be noise at the very beginning where the frame position can jump around. The first time after the first 11 datapoints that the frame position changes will be marked as the pattern's movement time. 

This function returns several variables. `pattern_movement_times`, `pos_func_movement_times`, `bad_conds_movement`, and `bad_reps_movement`. `Pos_func_movement_times` are the indices in the position function where movement happened, as compared to the `pattern_movement_times` which contains the indices in the collected frame position data where movement happened. We save both just in case we want to use them for any kind of quality analysis in the future. 

## Get intertrial movement times - Line 293

For each intertrial, this function finds the index of the first datapoint where the frame position changes. It returns one variable, `intertrial_move_times`, which is a one dimensional array giving one index value per intertrial. 

## Remove bad movement conditions - Line 297

The `remove_bad_conditions.m` function is used one more time to remove any bad conditions found when getting the pattern movement times. 

## Align data to pattern movement time - Line 302

`shift_data_to_movement.m` is the alignment function that actually shifts the data so each condition's data starts at the point that the pattern started moving.

It uses the same general method as the function that shifted data according to its cross correlation lags. The shift value now is the movement time (which is not a timestamp, but the index at which movement happens). Like before, it uses circshift and then removes the data that was shifted from the front of the array to the back. In this case, we are never really going to be shifting right, but only to the left. 

The second half of the function shifts the intertrial data based on its movement time. It first checks if the percentage to be shifted is greater than the limit set by the user. If so, the intertrial is added to a list of bad intertrials and the data is set to NaNs. Otherwise, the data is shifted using the same method as before. 

This function returns three variables. `ts_data` is the final, aligned timeseries array. `inter_ts_data` is the aligned intertrial timeseries data, and `bad_movement_intertrials` which is the list of bad intertrials, if any.

## Re-formatting all bad conditions for the text file report - Line 307

Lines 307 - 330 are spent reformatting the bad trials. This is only done so that older code that generates the text report can be re-used. It was simpler than re-writing the text report data. But that's it, there's no fundamental reason it needs to be formatted this way. 

Bad conditions are assigned to an array named for the reason they were tossed out. So we end up with `duration_conds`, `slope_conds`, `xcorr_conds`, `posfunc_conds`, `wbf_conds`, `duration_intertrials`, and `movement_intertrials`. Each of these are a list of repetition/condition pairs, or intertrial numbers. These are all then saved to a struct called bad_trials_summary for ease of passing the data in and out of functions. 

## Preparing the report of bad conditions - Line 332

After the reformatting is done, `create_bad_conditions_report.m` is called. This function creates a cell array called `Summary` where each element is a line of text that will later be printed in a txt file. For each bad condition, an element is added to `Summary` with the condition and repetition number and a code telling the user why that trial was tossed. It then does the same thing with the intertrials. 

This returns the `summary` variable which will be used at the end of processing when everything is saved to produce a text file reporting on all conditions and intertrials that were removed from the data. 

## Add buffer data back to beginning of timeseries - Line 339

If the variable `pre_dur` is set to something other than 0, then a certain amount of data needs to be tacked back on to the front of the timeseries data. The data will be plotted so that x=0 is the point at which the pattern started moving, and this data added back on to the front will align with x = -pre_dur:0.

`add_pre_dur.m` is the function that does this process. The variable `ts_time`, which holds the timestamps against which timeseries data are plotted, has already been created with the `pre_dur` value in mind, meaning it starts at `-pre_dur` and goes through the length of the longest condition in steps of 1 ms. We find the index at which `ts_time=0`. This index minus 1 will give us the number of data points (or number of milliseconds) that needs to be added to the front of the timeseries data.

Then for each channel, condition, and repetition, we get the previously found time at which movement occurred. We then access the raw `unaligned_data` variable, find the index at which movement occurred, and then copy the data preceding that index back to whatever amount of time `pre_dur` indicates. Assuming there is enough data, that data is pulled and saved in a variable called `data_to_add`. If not, say movement happened sooner than the `pre_dur` amount of time, we take what data is there and then tack NaNs on to the front of it so it is still the required lenth. We then go thorugh the `ts_data` array and add this data to the front. Again, to maintain each element of the array having the same length, we use circshift to shift the data to the right and then replace the first `pre_dur` number of milliseconds with the `data_to_add`.

This function returns `ts_data` after adding the data indicated by the `pre_dur` variable. 

## Get normalization parameters - Line 354

The function `get_max_process_normalization.m` is just a few lines of code which gets the max values (based on the percentile provided by the user) from the timeseries data which will then be used to normalize the data. 

## Normalize timseries data - Line 357

The function `normalize_ts_data.m` takes the max values just calculated and normalizes the timeseries data. First it gets the maximum value from the list of max values for the left wing channela nd the right wing channel. It then establishes the datatypes to normalize, which are simply the left and right wing channels. Then for each of these, each data point in the timeseries data is divided by the max value. 

This function returns the normalized timeseries data array and the max value used. 

## Calculating data sets - Lines 365-398

The next set of code is not divided into functions but executed here in the `process_data.m` function. First, at line 365 and 366, we calculate the Left minus Right (LmR) and Left plus Right (LpR) data sets by subtracting or adding the left and right channel data. 

Next, at lines 370 and 371 we do the same, but with the normalized data. 

The code commented out from lines 374-389 is old and will likely be removed in future releases. 

Starting at line 392 we create some more datasets which don't contain any new information but are likely to be useful to the user. These are: 

`ts_avg_reps` which is the timeseries data averaged over the repetitions.
`LmR_avg_over_reps` which is specifically the LmR data averaged over repetitions. 
`LpR_avg_over_reps` which is specifically the LpR data averaged over repetitions. 
`ts_avg_reps_norm` which is the same as `ts_avg_reps` but using normalized data. 
`LmR_avg_reps_norm` is `LmR_avg_over_reps` using normalized data
`LpR_avg_reps_norm` is `LpR_avg_over_reps` using normalized data

## Calculating flipped and averaged LmR data - Line 405

On line 405 you'll find the function `get_falmr.m`. Assuming the faLmR setting is turned on, this will run and return both normalized and unnormalized faLmR data. 

If the `condition_pairs` setting, which tells the software which trials to flip and average together, is empty then by default it pairs conditions with the one that follows it (condtions 1 and 2, 3 and 4, 5 and 6, etc). Lines 4-14 create the default pairs assuming none were provided. Lines 16 and 17 establish variables to hold the faLmR data. Lines 19-30 actually generate hte faLmR data.

This function returns two variables, `faLmR_data` and `faLmR_data_norm`.

Lines 406-407 in the main processing function then use these to create `faLmR_avg_over_reps` and `faLmR_avg_reps_norm` which simply takes the mean of each output over all the repetitions. 

## Calculate data for tuning curves - Line 416

Lines 416-417 create the tuning curve datasets, which are simply the `ts_data` averaged over the 4th dimension (the dimension with the actual data). 

## Calculating histograms of pattern position data - Line 422

Assuming the user provided datatypes for which to create histograms, the function `calculate_histograms.m` will run and generate the histogram data. 

Line 6 gets the max value of the frame position data. We then manipulate the arrays a bit and get an array of 1:max position value. Line 15 then gives us the indices at which the data is equal to each value in that array. In line 16, we sum them all up and save them to `hist_data` which ends up being a total sum for each value from 1:max position value. 

This function returns one variable, `hist_data`, which is a four dimensional array of size [num datatypes, num conditions, num repetitions, max frame position]. 

## Calculate intertrial histograms - Line 433

Next we check to see if intertrials were run. If so, we calculate histograms for them using the `calculate_intertrial_histograms.m` function. Before calling the function, we pull the data we need out of the `inter_ts_data` array, and then pass it into the function. Just like the last function, we simply get the maximum frame position value among the intertrials, create an array of 1:max value, and then get the indices where the data is equal to each point in that array. Summing up those indices tells us how many data points are of each value. We save this to `inter_hist_data` and return it. 

## Calculate position series if relevant - Line 443

Assuming the setting for position series is set to 1, the function `get_position_series.m` is called at line 443. 

If `pos_conditions`, the variable determining which conditions you want position series for, is empty, then the function uses all conditions. First it checks the entire frame position dataset for non-integer numbers, which would cause an error if present.  Then in lines 28-31 we get the indices of the actual data we want to use, assuming there may be NaNs at the beginning and/or end, removing any data set by `data_pad`, etc.

At line 34 it finds all indices were there is a "big step", or a change greater than 1, in the position data. If only one big step is found, it determines whether it happens more toward the beginning or end of the trial. If there are more than one big steps, then it searches for the big steps where the latter value is more than four times the previous value. It then finds all the step candidates (all indices where the frame position changes at all) but removes the data before and after a "big step", meaning it leaves us with just one cycle of frame position data, assuming at some point the frame position makes a large jump.  We get the median step size and then for each step, check to see if the change is within 50% of the median. If not, we skip it, otherwise we get the mean step value. In the end we get `pos_series` where the first dimension is condition, second dimension is repetition, third dimension is the frame position steps, and the fourth dimension is the LmR data. This allows us to plot LmR data gainst the change in frame position instead of the change in time (hence position series instead of time series).

The function returns `pos_series`, discussed earlier, and `mean_pos_series` which is the position series averaged over repetitions. 

## Saving the processed data - Lines 455-484

Lines 455-468 simply save some of the variables produced throughout the processing as new variables which have names that are more easily understood by the user. These variables will all be saved in a .mat file and the goal is for a user to be able to understand what they are by their variable name alone, rather than having to reference the documentation every time. 

After the re-naming, we save a long list of variables in the experiment folder, under the processed filename given by the user. 

Note the `else` statement at 486, tied to the `if` statement started at line 347. Most of the dataset creation listed above is for flying experiments, and this if statement separates flying experiments from other types (walking). After this `else` comes the dataset generation done for non-flying experiments, and a new save command saving different variables. The dataset generation is not nearly as extensive for non-flying experiments. We still average the timeseries data over repetitions, get the tuning curve data, and create histogram data for the intertrials (all done the same way). The rest is not included. As such, there are many fewer variables being saved for a non-flying experiment. 

## Bad conditions reporting - Line 525

The last thing done is creating a text file in which the bad conditions are summarized. This uses the variable created earlier in the processing, `bad_conds_summary` which is a cell arrray of text lines that are printed into a text file and saved based on the file path and name provided by the user. 






