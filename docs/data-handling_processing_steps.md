---
title:  G4 Data Processing Step by Step
parent: G4 Automated Data Handling
grand_parent: Generation 4
nav_order: 1
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



